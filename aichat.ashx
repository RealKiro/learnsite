<%@ WebHandler Language="C#" Class="aichat" %>

using System;
using System.IO;
using System.Web;
using System.Text;
using System.Net;
using System.Xml;
using System.Web.Script.Serialization;

public class aichat : IHttpHandler
{
    private void WriteJson(HttpContext context, string json)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
        byte[] data = Encoding.UTF8.GetBytes(json);
        context.Response.OutputStream.Write(data, 0, data.Length);
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n");
    }

    /// <summary>
    /// 从 website.xml 读取指定 key 的值
    /// </summary>
    private string GetWebsiteConfig(HttpContext context, string key)
    {
        try
        {
            string xmlPath = context.Server.MapPath("~/website.xml");
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value;
        }
        catch { }
        return "";
    }

    /// <summary>
    /// 调用AI API
    /// </summary>
    private string CallAiApi(string apiUrl, string apiKey, string model, string systemPrompt, double temperature, int maxTokens, string messagesJson, out string error)
    {
        error = "";
        try
        {
            // 解析消息数组并添加系统提示词
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            System.Collections.ArrayList messagesList = null;
            
            try
            {
                var messagesObj = serializer.DeserializeObject(messagesJson);
                if (messagesObj is System.Collections.ArrayList)
                {
                    messagesList = (System.Collections.ArrayList)messagesObj;
                }
                else if (messagesObj is System.Array)
                {
                    messagesList = new System.Collections.ArrayList();
                    foreach (var item in (System.Array)messagesObj)
                    {
                        messagesList.Add(item);
                    }
                }
                else
                {
                    error = "消息格式无效，期望数组格式";
                    return "";
                }
            }
            catch (Exception ex)
            {
                error = "消息格式解析失败: " + ex.Message;
                return "";
            }
            
            if (messagesList == null)
            {
                error = "消息格式无效";
                return "";
            }
            
            // 如果有系统提示词，添加到消息列表开头
            if (!string.IsNullOrEmpty(systemPrompt))
            {
                var systemMsg = new System.Collections.Generic.Dictionary<string, object>();
                systemMsg["role"] = "system";
                systemMsg["content"] = systemPrompt;
                messagesList.Insert(0, systemMsg);
            }
            
            string messagesArray = serializer.Serialize(messagesList);

            // 构建完整的请求体JSON
            StringBuilder jsonBody = new StringBuilder();
            jsonBody.Append("{");
            jsonBody.Append("\"model\":\"").Append(EscapeJson(model)).Append("\",");
            jsonBody.Append("\"messages\":").Append(messagesArray).Append(",");
            jsonBody.Append("\"temperature\":").Append(temperature.ToString("F1")).Append(",");
            jsonBody.Append("\"max_tokens\":").Append(maxTokens);
            jsonBody.Append("}");

            string jsonBodyStr = jsonBody.ToString();
            
            // 发送HTTP请求
            string fullUrl = apiUrl.TrimEnd('/') + "/chat/completions";
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(fullUrl);
            request.Method = "POST";
            request.ContentType = "application/json";
            request.Headers.Add("Authorization", "Bearer " + apiKey);
            request.Timeout = 60000; // 60秒超时

            byte[] data = Encoding.UTF8.GetBytes(jsonBodyStr);
            request.ContentLength = data.Length;

            using (Stream stream = request.GetRequestStream())
            {
                stream.Write(data, 0, data.Length);
            }

            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    string responseText = reader.ReadToEnd();
                    
                    // 简单解析JSON响应
                    JavaScriptSerializer serializer = new JavaScriptSerializer();
                    var result = serializer.Deserialize<System.Collections.Generic.Dictionary<string, object>>(responseText);
                    
                    if (result != null && result.ContainsKey("choices"))
                    {
                        var choices = result["choices"];
                        if (choices != null)
                        {
                            System.Collections.ArrayList choicesList = choices as System.Collections.ArrayList;
                            if (choicesList != null && choicesList.Count > 0)
                            {
                                var firstChoice = choicesList[0] as System.Collections.Generic.Dictionary<string, object>;
                                if (firstChoice != null && firstChoice.ContainsKey("message"))
                                {
                                    var message = firstChoice["message"] as System.Collections.Generic.Dictionary<string, object>;
                                    if (message != null && message.ContainsKey("content"))
                                    {
                                        return message["content"].ToString();
                                    }
                                }
                            }
                        }
                    }
                    
                    error = "API返回格式异常: " + responseText.Substring(0, Math.Min(200, responseText.Length));
                    return "";
                }
            }
        }
        catch (WebException ex)
        {
            if (ex.Response != null)
            {
                using (StreamReader reader = new StreamReader(ex.Response.GetResponseStream(), Encoding.UTF8))
                {
                    error = "API调用失败: " + reader.ReadToEnd();
                }
            }
            else
            {
                error = "API调用失败: " + ex.Message;
            }
            return "";
        }
        catch (Exception ex)
        {
            error = "处理失败: " + ex.Message;
            return "";
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        try
        {
            // 检查是否是获取配置信息的请求
            string action = context.Request.QueryString["action"];
            if (action == "getconfig")
            {
                string aiEnabled = GetWebsiteConfig(context, "AiEnabled");
                string model = GetWebsiteConfig(context, "AiModel");
                string systemPrompt = GetWebsiteConfig(context, "AiSystemPrompt");
                
                WriteJson(context, "{\"success\":1,\"enabled\":\"" + (aiEnabled.ToLower() == "true" ? "1" : "0") + 
                    "\",\"model\":\"" + EscapeJson(model) + 
                    "\",\"systemPrompt\":\"" + EscapeJson(systemPrompt) + "\"}");
                return;
            }
            
            // 读取AI配置
            string aiEnabled = GetWebsiteConfig(context, "AiEnabled");
            if (aiEnabled.ToLower() != "true")
            {
                WriteJson(context, "{\"success\":0,\"message\":\"AI功能未启用，请在系统设置中启用\"}");
                return;
            }

            string apiUrl = GetWebsiteConfig(context, "AiApiUrl");
            string apiKey = GetWebsiteConfig(context, "AiApiKey");
            string model = GetWebsiteConfig(context, "AiModel");
            string tempStr = GetWebsiteConfig(context, "AiTemperature");
            string maxTokensStr = GetWebsiteConfig(context, "AiMaxTokens");
            string systemPrompt = GetWebsiteConfig(context, "AiSystemPrompt");

            if (string.IsNullOrEmpty(apiUrl) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(model))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"AI配置不完整，请检查系统设置\"}");
                return;
            }

            // 解析参数
            double temperature = 0.7;
            if (!string.IsNullOrEmpty(tempStr))
                double.TryParse(tempStr, out temperature);

            int maxTokens = 2000;
            if (!string.IsNullOrEmpty(maxTokensStr))
                int.TryParse(maxTokensStr, out maxTokens);

            // 读取POST数据（期望是JSON格式：{"messages": [...]}）
            string requestJson = "";
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            {
                requestJson = reader.ReadToEnd();
            }

            if (string.IsNullOrEmpty(requestJson))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"消息内容为空\"}");
                return;
            }

            // 解析请求JSON，提取messages数组
            string messagesJson = "";
            try
            {
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                var requestObj = serializer.Deserialize<System.Collections.Generic.Dictionary<string, object>>(requestJson);
                if (requestObj != null && requestObj.ContainsKey("messages"))
                {
                    var messages = requestObj["messages"];
                    messagesJson = serializer.Serialize(messages);
                }
                else
                {
                    // 如果直接是数组格式
                    messagesJson = requestJson;
                }
            }
            catch
            {
                // 如果解析失败，尝试直接使用
                messagesJson = requestJson;
            }

            // 调用AI API
            string error;
            string response = CallAiApi(apiUrl, apiKey, model, systemPrompt, temperature, maxTokens, messagesJson, out error);

            if (string.IsNullOrEmpty(response))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"" + EscapeJson(error) + "\"}");
                return;
            }

            WriteJson(context, "{\"success\":1,\"response\":\"" + EscapeJson(response) + "\"}");
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}

