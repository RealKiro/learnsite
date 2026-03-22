<%@ WebHandler Language="C#" Class="aichat" %>

using System;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Web;
using System.Xml;

public class aichat : IHttpHandler
{
    // 从 website.xml 读取配置
    private string GetXmlValue(string xmlPath, string key)
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value;
        }
        catch { }
        return "";
    }

    public void ProcessRequest(HttpContext context)
    {
        string xmlPath = context.Server.MapPath("~/website.xml");

        // GET 请求返回 AI 配置信息（不含密钥）
        if (context.Request.HttpMethod == "GET")
        {
            context.Response.ContentType = "application/json";
            context.Response.AddHeader("Access-Control-Allow-Origin", "*");
            string enabled = GetXmlValue(xmlPath, "AiEnabled");
            string model = GetXmlValue(xmlPath, "AiModel");
            string systemPrompt = GetXmlValue(xmlPath, "AiSystemPrompt");
            bool isEnabled = enabled.ToLower() == "true";
            // 返回前端需要的配置（不暴露密钥）
            string json = "{\"enabled\":" + (isEnabled ? "true" : "false")
                + ",\"model\":" + JsonEncode(model)
                + ",\"systemPrompt\":" + JsonEncode(systemPrompt) + "}";
            context.Response.Write(json);
            return;
        }

        // OPTIONS 预检请求
        if (context.Request.HttpMethod == "OPTIONS")
        {
            context.Response.AddHeader("Access-Control-Allow-Origin", "*");
            context.Response.AddHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
            context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");
            context.Response.StatusCode = 204;
            return;
        }

        // POST 请求处理 AI 对话
        context.Response.ContentType = "text/event-stream";
        context.Response.AddHeader("Cache-Control", "no-cache");
        context.Response.AddHeader("Access-Control-Allow-Origin", "*");
        context.Response.BufferOutput = false;

        try
        {
            // 读取 AI 配置
            string aiEnabled = GetXmlValue(xmlPath, "AiEnabled");
            if (aiEnabled.ToLower() != "true")
            {
                WriteError(context, "AI 功能未启用，请联系管理员在后台开启");
                return;
            }

            string apiUrl = GetXmlValue(xmlPath, "AiApiUrl");
            string apiKey = GetXmlValue(xmlPath, "AiApiKey");
            string model = GetXmlValue(xmlPath, "AiModel");
            string temperatureStr = GetXmlValue(xmlPath, "AiTemperature");
            string maxTokensStr = GetXmlValue(xmlPath, "AiMaxTokens");
            string systemPrompt = GetXmlValue(xmlPath, "AiSystemPrompt");

            if (string.IsNullOrEmpty(apiUrl) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(model))
            {
                WriteError(context, "AI 配置不完整，请管理员在后台设置 API 地址、密钥和模型");
                return;
            }

            double temperature = 0.7;
            double.TryParse(temperatureStr, out temperature);
            int maxTokens = 2000;
            int.TryParse(maxTokensStr, out maxTokens);
            if (maxTokens <= 0) maxTokens = 2000;

            // 读取请求体
            string requestBody;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            {
                requestBody = reader.ReadToEnd();
            }

            // 提取 messages 数组
            string messagesJson = ExtractMessages(requestBody);
            if (string.IsNullOrEmpty(messagesJson))
            {
                WriteError(context, "请求格式错误");
                return;
            }

            // 移除末尾的空 assistant 消息（前端流式占位符）
            messagesJson = RemoveTrailingEmptyAssistant(messagesJson);

            // 如果有系统提示词，添加到消息列表最前面
            string fullMessages = messagesJson;
            if (!string.IsNullOrEmpty(systemPrompt))
            {
                string systemMsg = "{\"role\":\"system\",\"content\":" + JsonEncode(systemPrompt) + "}";
                // 在 messages 数组开头插入系统消息
                if (fullMessages.TrimStart().StartsWith("["))
                {
                    fullMessages = "[" + systemMsg + "," + fullMessages.TrimStart().Substring(1);
                }
            }

            // 构建 OpenAI 兼容的请求体
            string openAiBody = "{\"model\":" + JsonEncode(model)
                + ",\"messages\":" + fullMessages
                + ",\"temperature\":" + temperature.ToString("F1", System.Globalization.CultureInfo.InvariantCulture)
                + ",\"max_tokens\":" + maxTokens
                + ",\"stream\":true}";

            // 确保 API URL 以 /chat/completions 结尾
            string chatUrl = apiUrl.TrimEnd('/');
            if (!chatUrl.EndsWith("/chat/completions"))
            {
                chatUrl += "/chat/completions";
            }

            // 确保支持 TLS 1.2（大多数 AI API 要求）
            // .NET 2.0 没有 Tls12/Tls11 枚举，用数值代替: Tls12=3072, Tls11=768
            try {
                ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072 | (SecurityProtocolType)768 | SecurityProtocolType.Tls;
            } catch {
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
            }

            // 发起请求到大模型 API
            HttpWebRequest apiRequest = (HttpWebRequest)WebRequest.Create(chatUrl);
            apiRequest.Method = "POST";
            apiRequest.ContentType = "application/json";
            apiRequest.Headers.Add("Authorization", "Bearer " + apiKey);
            apiRequest.Timeout = 120000; // 2分钟超时
            apiRequest.ReadWriteTimeout = 120000;

            byte[] bodyBytes = Encoding.UTF8.GetBytes(openAiBody);
            apiRequest.ContentLength = bodyBytes.Length;
            using (Stream reqStream = apiRequest.GetRequestStream())
            {
                reqStream.Write(bodyBytes, 0, bodyBytes.Length);
            }

            // 读取流式响应并转发
            using (HttpWebResponse apiResponse = (HttpWebResponse)apiRequest.GetResponse())
            using (Stream respStream = apiResponse.GetResponseStream())
            using (StreamReader respReader = new StreamReader(respStream, Encoding.UTF8))
            {
                string line;
                while ((line = respReader.ReadLine()) != null)
                {
                    if (string.IsNullOrEmpty(line)) continue;

                    // 解析 SSE 格式: data: {...}
                    if (line.StartsWith("data: "))
                    {
                        string jsonStr = line.Substring(6).Trim();
                        if (jsonStr == "[DONE]")
                        {
                            context.Response.Write("data: [DONE]\n\n");
                            context.Response.Flush();
                            break;
                        }

                        // 从 OpenAI 格式提取 content 和 reasoning_content
                        string content = ExtractDeltaContent(jsonStr);
                        string reasoning = ExtractDeltaReasoningContent(jsonStr);
                        if (content != null || reasoning != null)
                        {
                            // 转发为简化的 JSON 格式，与前端兼容
                            StringBuilder chunkBuilder = new StringBuilder("data: {");
                            bool hasField = false;
                            if (content != null)
                            {
                                chunkBuilder.Append("\"content\":" + JsonEncode(content));
                                hasField = true;
                            }
                            if (reasoning != null)
                            {
                                if (hasField) chunkBuilder.Append(",");
                                chunkBuilder.Append("\"reasoning\":" + JsonEncode(reasoning));
                            }
                            chunkBuilder.Append("}\n\n");
                            context.Response.Write(chunkBuilder.ToString());
                            context.Response.Flush();
                        }
                    }
                }
            }
        }
        catch (WebException wex)
        {
            string errorMsg = "AI 服务请求失败";
            if (wex.Response != null)
            {
                try
                {
                    using (StreamReader sr = new StreamReader(wex.Response.GetResponseStream(), Encoding.UTF8))
                    {
                        string errBody = sr.ReadToEnd();
                        errorMsg += "：" + errBody;
                    }
                }
                catch { }
            }
            else
            {
                errorMsg += "：" + wex.Message;
            }
            WriteError(context, errorMsg);
        }
        catch (Exception ex)
        {
            WriteError(context, "服务器错误：" + ex.Message);
        }
    }

    // 写入错误信息（以 SSE 格式）
    private void WriteError(HttpContext context, string message)
    {
        string chunk = "data: {\"content\":" + JsonEncode(message) + "}\n\ndata: [DONE]\n\n";
        context.Response.Write(chunk);
        context.Response.Flush();
    }

    // 简单 JSON 字符串编码
    private string JsonEncode(string s)
    {
        if (s == null) return "\"\"";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t") + "\"";
    }

    // 移除末尾空的 assistant 消息（前端流式占位符）
    private string RemoveTrailingEmptyAssistant(string messagesJson)
    {
        try
        {
            string trimmed = messagesJson.TrimEnd();
            // 前端 JSON.stringify 生成的固定格式
            string emptyAssistant = "{\"role\":\"assistant\",\"content\":\"\"}";
            string trailingWithComma = "," + emptyAssistant + "]";

            if (trimmed.EndsWith(trailingWithComma))
            {
                return trimmed.Substring(0, trimmed.Length - trailingWithComma.Length) + "]";
            }
            // 只有空 assistant 一条消息的情况
            if (trimmed == "[" + emptyAssistant + "]")
            {
                return "[]";
            }
        }
        catch { }
        return messagesJson;
    }

    // 从请求体中提取 messages 数组（正确处理字符串中的括号）
    private string ExtractMessages(string json)
    {
        try
        {
            int idx = json.IndexOf("\"messages\"");
            if (idx < 0) return null;
            int colonIdx = json.IndexOf(':', idx);
            if (colonIdx < 0) return null;

            int start = json.IndexOf('[', colonIdx);
            if (start < 0) return null;

            int depth = 0;
            bool inString = false;
            bool escaped = false;
            for (int i = start; i < json.Length; i++)
            {
                char c = json[i];
                if (escaped) { escaped = false; continue; }
                if (c == '\\' && inString) { escaped = true; continue; }
                if (c == '"') { inString = !inString; continue; }
                if (!inString)
                {
                    if (c == '[' || c == '{') depth++;
                    else if (c == ']' || c == '}') depth--;
                    if (depth == 0) return json.Substring(start, i - start + 1);
                }
            }
        }
        catch { }
        return null;
    }

    // 从 OpenAI SSE JSON 中提取 delta.content
    private string ExtractDeltaContent(string json)
    {
        try
        {
            // 查找 "delta" 对象中的 "content" 字段
            int deltaIdx = json.IndexOf("\"delta\"");
            if (deltaIdx < 0) return null;

            int contentIdx = json.IndexOf("\"content\"", deltaIdx);
            if (contentIdx < 0) return null;

            int colonIdx = json.IndexOf(':', contentIdx);
            if (colonIdx < 0) return null;

            // 跳过冒号后的空白
            int valStart = colonIdx + 1;
            while (valStart < json.Length && json[valStart] == ' ') valStart++;

            if (valStart >= json.Length) return null;

            if (json[valStart] == '"')
            {
                // 字符串值 - 解析到结束引号
                StringBuilder sb = new StringBuilder();
                bool escaped = false;
                for (int i = valStart + 1; i < json.Length; i++)
                {
                    if (escaped)
                    {
                        switch (json[i])
                        {
                            case 'n': sb.Append('\n'); break;
                            case 'r': sb.Append('\r'); break;
                            case 't': sb.Append('\t'); break;
                            case '\\': sb.Append('\\'); break;
                            case '"': sb.Append('"'); break;
                            case '/': sb.Append('/'); break;
                            case 'u':
                                if (i + 4 < json.Length)
                                {
                                    string hex = json.Substring(i + 1, 4);
                                    sb.Append((char)Convert.ToInt32(hex, 16));
                                    i += 4;
                                }
                                break;
                            default: sb.Append(json[i]); break;
                        }
                        escaped = false;
                    }
                    else if (json[i] == '\\')
                    {
                        escaped = true;
                    }
                    else if (json[i] == '"')
                    {
                        return sb.ToString();
                    }
                    else
                    {
                        sb.Append(json[i]);
                    }
                }
            }
            else if (json.Substring(valStart, 4) == "null")
            {
                return null;
            }
        }
        catch { }
        return null;
    }

    // 从 OpenAI SSE JSON 中提取 delta.reasoning_content（用于推理模型如 DeepSeek R1）
    private string ExtractDeltaReasoningContent(string json)
    {
        try
        {
            int deltaIdx = json.IndexOf("\"delta\"");
            if (deltaIdx < 0) return null;

            int rcIdx = json.IndexOf("\"reasoning_content\"", deltaIdx);
            if (rcIdx < 0) return null;

            int colonIdx = json.IndexOf(':', rcIdx + 19);
            if (colonIdx < 0) return null;

            int valStart = colonIdx + 1;
            while (valStart < json.Length && json[valStart] == ' ') valStart++;

            if (valStart >= json.Length) return null;

            if (json[valStart] == '"')
            {
                StringBuilder sb = new StringBuilder();
                bool escaped = false;
                for (int i = valStart + 1; i < json.Length; i++)
                {
                    if (escaped)
                    {
                        switch (json[i])
                        {
                            case 'n': sb.Append('\n'); break;
                            case 'r': sb.Append('\r'); break;
                            case 't': sb.Append('\t'); break;
                            case '\\': sb.Append('\\'); break;
                            case '"': sb.Append('"'); break;
                            case '/': sb.Append('/'); break;
                            case 'u':
                                if (i + 4 < json.Length)
                                {
                                    string hex = json.Substring(i + 1, 4);
                                    sb.Append((char)Convert.ToInt32(hex, 16));
                                    i += 4;
                                }
                                break;
                            default: sb.Append(json[i]); break;
                        }
                        escaped = false;
                    }
                    else if (json[i] == '\\')
                    {
                        escaped = true;
                    }
                    else if (json[i] == '"')
                    {
                        return sb.ToString();
                    }
                    else
                    {
                        sb.Append(json[i]);
                    }
                }
            }
            else if (valStart + 4 <= json.Length && json.Substring(valStart, 4) == "null")
            {
                return null;
            }
        }
        catch { }
        return null;
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
