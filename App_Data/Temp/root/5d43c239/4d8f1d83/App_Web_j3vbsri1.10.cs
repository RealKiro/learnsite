#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\aigenlesson.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "FA9F4540DD4B3236E9A89823536A04B1"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\aigenlesson.ashx"


using System;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Web;
using System.Xml;

public class aigenlesson : IHttpHandler
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

        // OPTIONS
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
                WriteError(context, "AI 学案功能未启用，请联系管理员在后台开启");
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

            // 读取学案专用系统提示词
            string lessonSystemPrompt = GetXmlValue(websiteXml, "AiLessonSystemPrompt");

            if (string.IsNullOrEmpty(apiUrl) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(model))
            {
                WriteError(context, "AI 学案配置不完整，请管理员在后台设置 API 地址、密钥和模型");
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

            string knowledgeIds = ExtractJsonValue(requestBody, "knowledgeIds");
            string templateId = ExtractJsonValue(requestBody, "templateId");
            string courseName = ExtractJsonValue(requestBody, "courseName");

            if (string.IsNullOrEmpty(templateId))
            {
                WriteError(context, "请选择一个学案模板");
                return;
            }

            // 读取知识库资料信息
            string knowledgeInfo = "";
            if (!string.IsNullOrEmpty(knowledgeIds))
            {
                knowledgeInfo = GetKnowledgeInfo(context, knowledgeIds);
            }

            // 读取模板内容
            string templateContent = GetTemplateContent(context, templateId);
            string templateName = GetTemplateName(context, templateId);

            if (string.IsNullOrEmpty(templateContent))
            {
                WriteError(context, "无法读取模板内容");
                return;
            }

            // 构建 prompt（优先使用后台配置的学案系统提示词）
            string defaultPrompt = "你是一位经验丰富的信息科技教师，擅长编写高质量的教学学案。"
                + "请根据用户提供的参考资料和学案模板，生成一份完整的教学学案。"
                + "要求：\n"
                + "1. 严格按照模板的结构和格式来组织内容\n"
                + "2. 内容要具体、实用，适合课堂教学\n"
                + "3. 直接输出HTML格式的学案内容，不要使用Markdown格式\n"
                + "4. 使用 <h2>、<h3>、<h4>、<p>、<ol>、<ul>、<li>、<strong>、<table> 等HTML标签\n"
                + "5. 不要输出```html等代码块标记，直接输出HTML内容\n"
                + "6. 内容要丰富充实，每个板块都要有具体内容";
            string systemPrompt = !string.IsNullOrEmpty(lessonSystemPrompt) ? lessonSystemPrompt : defaultPrompt;

            StringBuilder userPrompt = new StringBuilder();

            if (!string.IsNullOrEmpty(courseName))
            {
                userPrompt.Append("学案名称：" + courseName + "\n\n");
            }

            if (!string.IsNullOrEmpty(knowledgeInfo))
            {
                userPrompt.Append("参考资料：\n" + knowledgeInfo + "\n\n");
            }

            userPrompt.Append("请按照以下模板格式（" + templateName + "）生成学案内容：\n\n");
            userPrompt.Append(templateContent);

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

    private string GetKnowledgeInfo(HttpContext context, string ids)
    {
        string xmlPath = context.Server.MapPath("~/App_Data/knowledge.xml");
        if (!File.Exists(xmlPath)) return "";

        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            string[] idArr = ids.Split(',');
            StringBuilder sb = new StringBuilder();
            int num = 1;

            foreach (string id in idArr)
            {
                string trimId = id.Trim();
                if (string.IsNullOrEmpty(trimId)) continue;

                XmlNode node = doc.SelectSingleNode("//Item[@id='" + trimId.Replace("'", "") + "']");
                if (node != null)
                {
                    string title = GetAttr(node, "title");
                    string category = GetAttr(node, "category");
                    string originalName = GetAttr(node, "originalName");

                    sb.Append(num + ". ");
                    sb.Append("【" + category + "】" + title);
                    if (!string.IsNullOrEmpty(originalName))
                        sb.Append("（文件：" + originalName + "）");
                    sb.Append("\n");
                    num++;
                }
            }

            return sb.ToString();
        }
        catch { }
        return "";
    }

    private string GetTemplateContent(HttpContext context, string templateId)
    {
        string xmlPath = context.Server.MapPath("~/App_Data/coursetemplates.xml");
        if (!File.Exists(xmlPath)) return "";

        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNode node = doc.SelectSingleNode("//Template[@id='" + templateId.Replace("'", "") + "']");
            if (node != null)
                return node.InnerText;
        }
        catch { }
        return "";
    }

    private string GetTemplateName(HttpContext context, string templateId)
    {
        string xmlPath = context.Server.MapPath("~/App_Data/coursetemplates.xml");
        if (!File.Exists(xmlPath)) return "";

        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNode node = doc.SelectSingleNode("//Template[@id='" + templateId.Replace("'", "") + "']");
            if (node != null)
                return GetAttr(node, "name");
        }
        catch { }
        return "";
    }

    private string GetAttr(XmlNode node, string name)
    {
        if (node.Attributes[name] != null)
            return node.Attributes[name].Value;
        return "";
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
