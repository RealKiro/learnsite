#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\aigentemplate.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "6A19D69AD725CD9C76E711FCEC6BCA88"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\aigentemplate.ashx"


using System;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Web;
using System.Xml;

public class aigentemplate : IHttpHandler
{
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
        context.Response.ContentType = "text/event-stream";
        context.Response.AddHeader("Cache-Control", "no-cache");
        context.Response.AddHeader("Access-Control-Allow-Origin", "*");
        context.Response.BufferOutput = false;

        if (context.Request.HttpMethod == "OPTIONS")
        {
            context.Response.AddHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");
            context.Response.StatusCode = 204;
            return;
        }

        try
        {
            string websiteXml = context.Server.MapPath("~/website.xml");

            // 检查 AI 学案功能是否启用（优先学案开关，回退通用开关）
            string lessonEnabled = GetXmlValue(websiteXml, "AiLessonEnabled");
            string aiEnabled = GetXmlValue(websiteXml, "AiEnabled");
            if (lessonEnabled.ToLower() != "true" && aiEnabled.ToLower() != "true")
            {
                WriteError(context, "AI 功能未启用，请联系管理员在后台开启");
                return;
            }

            // 优先使用学案专用配置，为空则回退通用配置
            string apiUrl = GetXmlValue(websiteXml, "AiLessonApiUrl");
            if (string.IsNullOrEmpty(apiUrl)) apiUrl = GetXmlValue(websiteXml, "AiApiUrl");

            string apiKey = GetXmlValue(websiteXml, "AiLessonApiKey");
            if (string.IsNullOrEmpty(apiKey)) apiKey = GetXmlValue(websiteXml, "AiApiKey");

            string model = GetXmlValue(websiteXml, "AiLessonModel");
            if (string.IsNullOrEmpty(model)) model = GetXmlValue(websiteXml, "AiModel");

            string temperatureStr = GetXmlValue(websiteXml, "AiLessonTemperature");
            if (string.IsNullOrEmpty(temperatureStr)) temperatureStr = GetXmlValue(websiteXml, "AiTemperature");

            string maxTokensStr = GetXmlValue(websiteXml, "AiLessonMaxTokens");
            if (string.IsNullOrEmpty(maxTokensStr)) maxTokensStr = GetXmlValue(websiteXml, "AiMaxTokens");

            if (string.IsNullOrEmpty(apiUrl) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(model))
            {
                WriteError(context, "AI 配置不完整，请管理员在后台设置 API 地址、密钥和模型");
                return;
            }

            double temperature = 0.7;
            double.TryParse(temperatureStr, out temperature);
            int maxTokens = 4000;
            int.TryParse(maxTokensStr, out maxTokens);
            if (maxTokens <= 0) maxTokens = 4000;

            // 读取请求参数
            string requestBody;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            {
                requestBody = reader.ReadToEnd();
            }

            string topic = ExtractJsonValue(requestBody, "topic");
            string templateType = ExtractJsonValue(requestBody, "templateType");

            if (string.IsNullOrEmpty(topic))
            {
                WriteError(context, "请输入模板主题");
                return;
            }

            // 构建 prompt
            string systemPrompt = "你是一位经验丰富的信息科技教师，擅长设计高质量的学案模板。"
                + "请根据用户提供的主题和类型，生成一份通用的学案模板框架。"
                + "要求：\n"
                + "1. 模板要具有通用性，适用于该类型的各种具体课题\n"
                + "2. 用占位符（如【课题名称】、【学习目标】等）标记需要填写的内容\n"
                + "3. 直接输出HTML格式，不要使用Markdown格式\n"
                + "4. 使用 <h2>、<h3>、<h4>、<p>、<ol>、<ul>、<li>、<strong>、<table> 等HTML标签\n"
                + "5. 不要输出```html等代码块标记，直接输出HTML内容\n"
                + "6. 结构要清晰完整，包含教学各环节";

            // 读取后台配置的学案系统提示词
            string lessonSystemPrompt = GetXmlValue(websiteXml, "AiLessonSystemPrompt");
            if (!string.IsNullOrEmpty(lessonSystemPrompt))
            {
                systemPrompt = lessonSystemPrompt + "\n\n" + "要求：直接输出HTML格式模板，不要使用Markdown格式，不要输出```html等代码块标记。";
            }

            StringBuilder userPrompt = new StringBuilder();
            userPrompt.Append("请为以下主题生成一份学案模板：\n\n");
            userPrompt.Append("主题：" + topic + "\n");
            if (!string.IsNullOrEmpty(templateType))
            {
                userPrompt.Append("模板类型：" + templateType + "\n");
            }
            userPrompt.Append("\n请生成包含完整教学环节的HTML格式学案模板。");

            // 构建 OpenAI 请求
            string messagesJson = "[{\"role\":\"system\",\"content\":" + JsonEncode(systemPrompt) + "},"
                + "{\"role\":\"user\",\"content\":" + JsonEncode(userPrompt.ToString()) + "}]";

            string openAiBody = "{\"model\":" + JsonEncode(model)
                + ",\"messages\":" + messagesJson
                + ",\"temperature\":" + temperature.ToString("F1", System.Globalization.CultureInfo.InvariantCulture)
                + ",\"max_tokens\":" + maxTokens
                + ",\"stream\":true}";

            string chatUrl = apiUrl.TrimEnd('/');
            if (!chatUrl.EndsWith("/chat/completions"))
            {
                chatUrl += "/chat/completions";
            }

            // TLS
            try
            {
                ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072 | (SecurityProtocolType)768 | SecurityProtocolType.Tls;
            }
            catch
            {
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
            }

            HttpWebRequest apiRequest = (HttpWebRequest)WebRequest.Create(chatUrl);
            apiRequest.Method = "POST";
            apiRequest.ContentType = "application/json";
            apiRequest.Headers.Add("Authorization", "Bearer " + apiKey);
            apiRequest.Timeout = 180000;
            apiRequest.ReadWriteTimeout = 180000;

            byte[] bodyBytes = Encoding.UTF8.GetBytes(openAiBody);
            apiRequest.ContentLength = bodyBytes.Length;
            using (Stream reqStream = apiRequest.GetRequestStream())
            {
                reqStream.Write(bodyBytes, 0, bodyBytes.Length);
            }

            using (HttpWebResponse apiResponse = (HttpWebResponse)apiRequest.GetResponse())
            using (Stream respStream = apiResponse.GetResponseStream())
            using (StreamReader respReader = new StreamReader(respStream, Encoding.UTF8))
            {
                string line;
                while ((line = respReader.ReadLine()) != null)
                {
                    if (string.IsNullOrEmpty(line)) continue;

                    if (line.StartsWith("data: "))
                    {
                        string jsonStr = line.Substring(6).Trim();
                        if (jsonStr == "[DONE]")
                        {
                            context.Response.Write("data: [DONE]\n\n");
                            context.Response.Flush();
                            break;
                        }

                        string content = ExtractDeltaContent(jsonStr);
                        if (content != null)
                        {
                            context.Response.Write("data: {\"content\":" + JsonEncode(content) + "}\n\n");
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

    private void WriteError(HttpContext context, string message)
    {
        string chunk = "data: {\"content\":" + JsonEncode(message) + "}\n\ndata: [DONE]\n\n";
        context.Response.Write(chunk);
        context.Response.Flush();
    }

    private string JsonEncode(string s)
    {
        if (s == null) return "\"\"";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t") + "\"";
    }

    private string ExtractJsonValue(string json, string key)
    {
        try
        {
            string searchKey = "\"" + key + "\"";
            int idx = json.IndexOf(searchKey);
            if (idx < 0) return "";

            int colonIdx = json.IndexOf(':', idx + searchKey.Length);
            if (colonIdx < 0) return "";

            int valStart = colonIdx + 1;
            while (valStart < json.Length && (json[valStart] == ' ' || json[valStart] == '\t')) valStart++;

            if (valStart >= json.Length) return "";

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
        }
        catch { }
        return "";
    }

    private string ExtractDeltaContent(string json)
    {
        try
        {
            int deltaIdx = json.IndexOf("\"delta\"");
            if (deltaIdx < 0) return null;

            int contentIdx = json.IndexOf("\"content\"", deltaIdx);
            if (contentIdx < 0) return null;

            int colonIdx = json.IndexOf(':', contentIdx);
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


#line default
#line hidden
