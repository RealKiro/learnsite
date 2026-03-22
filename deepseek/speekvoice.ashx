<%@ WebHandler Language="C#" Class="speekvoice" %>

using System;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Xml;
using System.Globalization;

/// <summary>
/// 语音合成 Handler — 读取 website.xml 通用模型配置，
/// 调用 OpenAI 兼容的 TTS 端点 {AiApiUrl}/audio/speech，
/// 将音频流直接返回浏览器。
/// </summary>
public class speekvoice : IHttpHandler
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
        context.Response.AddHeader("Access-Control-Allow-Origin", "*");

        // OPTIONS 预检
        if (context.Request.HttpMethod == "OPTIONS")
        {
            context.Response.AddHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");
            context.Response.StatusCode = 204;
            return;
        }

        string xmlPath = context.Server.MapPath("~/website.xml");
        string text = "";
        string voice = "";

        try
        {

            // 读取请求体
            string requestBody;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                requestBody = reader.ReadToEnd();
            text  = ExtractJsonString(requestBody, "text");
            voice = ExtractJsonString(requestBody, "voice");
            string voice = ExtractJsonString(requestBody, "voice");

            if (string.IsNullOrEmpty(text))
            {
                WriteJsonError(context, 400, "文本内容不能为空");
                return;
            }

            // voice 默认值：OpenAI 格式用 alloy；若保留原始微软神经声音名则原样传入
            if (string.IsNullOrEmpty(voice)) voice = "alloy";

            // 检查 AI 是否启用/配置
            string aiEnabled = GetXmlValue(xmlPath, "AiEnabled");
            string apiUrl = GetXmlValue(xmlPath, "AiApiUrl");
            string apiKey = GetXmlValue(xmlPath, "AiApiKey");

            bool canUseRemote = (aiEnabled.ToLower() == "true")
                && !string.IsNullOrEmpty(apiUrl)
                && !string.IsNullOrEmpty(apiKey);

            if (!canUseRemote)
            {
                if (TryLocalSpeech(context, text, voice)) return;
                if (aiEnabled.ToLower() != "true")
                    WriteJsonError(context, 503, "AI 功能未启用，且本地语音合成不可用");
                else
                    WriteJsonError(context, 503, "AI 配置不完整，且本地语音合成不可用");
                return;
            }

            // 构建 TTS 请求 URL：{apiUrl}/audio/speech
            string ttsUrl = apiUrl.TrimEnd('/');
            if (!ttsUrl.EndsWith("/audio/speech"))
                ttsUrl += "/audio/speech";

            // 从 website.xml 读取模型名；TTS 通常用 tts-1 / tts-1-hd
            // 若通用模型填的是对话模型（如 deepseek-chat），则退回 tts-1
            string cfgModel = GetXmlValue(xmlPath, "AiModel");
            string ttsModel = (cfgModel.ToLower().Contains("tts") ? cfgModel : "tts-1");

            // 构建 OpenAI 兼容 TTS 请求体
            string ttsBody = "{\"model\":" + JsonEncode(ttsModel)
                + ",\"input\":"  + JsonEncode(text)
                + ",\"voice\":"  + JsonEncode(voice)
                + ",\"response_format\":\"mp3\"}";

            // 确保 TLS 1.2+
            try { ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072 | (SecurityProtocolType)768 | SecurityProtocolType.Tls; }
            catch { ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls; }

            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(ttsUrl);
            req.Method      = "POST";
            req.ContentType = "application/json";
            req.Headers.Add("Authorization", "Bearer " + apiKey);
            req.Timeout          = 60000;
            req.ReadWriteTimeout = 60000;

            byte[] bodyBytes = Encoding.UTF8.GetBytes(ttsBody);
            req.ContentLength = bodyBytes.Length;
            using (Stream s = req.GetRequestStream())
                s.Write(bodyBytes, 0, bodyBytes.Length);

            // 读取 TTS 响应并原样转发给浏览器
            using (HttpWebResponse resp = (HttpWebResponse)req.GetResponse())
            {
                // 判断响应类型
                string ct = resp.ContentType ?? "";
                if (ct.Contains("audio") || ct.Contains("mpeg") || ct.Contains("octet"))
                {
                    context.Response.ContentType = "audio/mpeg";
                    context.Response.AddHeader("Content-Disposition", "inline; filename=\"speech.mp3\"");
                    context.Response.Buffer = false;

                    using (Stream respStream = resp.GetResponseStream())
                    {
                        byte[] buf = new byte[8192];
                        int bytesRead;
                        while ((bytesRead = respStream.Read(buf, 0, buf.Length)) > 0)
                            context.Response.OutputStream.Write(buf, 0, bytesRead);
                    }
                    context.Response.Flush();
                }
                else
                {
                    // API 返回了非音频（可能是错误 JSON）
                    string errBody;
                    using (StreamReader sr = new StreamReader(resp.GetResponseStream(), Encoding.UTF8))
                        errBody = sr.ReadToEnd();
                    if (TryLocalSpeech(context, text, voice)) return;
                    WriteJsonError(context, 502, "TTS 接口返回非音频内容：" + errBody);
                }
            }
        }
        catch (WebException wex)
        {
            if (TryLocalSpeech(context, text, voice)) return;
            string errorMsg = "TTS 服务请求失败";
            if (wex.Response != null)
            {
                try
                {
                    using (StreamReader sr = new StreamReader(wex.Response.GetResponseStream(), Encoding.UTF8))
                        errorMsg += "：" + sr.ReadToEnd();
                }
                catch { errorMsg += "：" + wex.Message; }
            }
            else
            {
                errorMsg += "：" + wex.Message;
            }
            WriteJsonError(context, 502, errorMsg);
        }
        catch (Exception ex)
        {
            if (TryLocalSpeech(context, text, voice)) return;
            WriteJsonError(context, 500, "服务器错误：" + ex.Message);
        }
    }

    private void WriteJsonError(HttpContext context, int statusCode, string message)
    {
        context.Response.TrySkipIisCustomErrors = true;
        context.Response.StatusCode  = statusCode;
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.Write("{\"error\":" + JsonEncode(message) + "}");
    }

    private string JsonEncode(string s)
    {
        if (s == null) return "\"\"";
        return "\"" + s
            .Replace("\\", "\\\\")
            .Replace("\"",  "\\\"")
            .Replace("\n",  "\\n")
            .Replace("\r",  "\\r")
            .Replace("\t",  "\\t") + "\"";
    }

    /// <summary>简单提取 JSON 字符串字段值（无需引入 JSON 库）</summary>
    private string ExtractJsonString(string json, string key)
    {
        try
        {
            int idx = json.IndexOf("\"" + key + "\"");
            if (idx < 0) return null;
            int colonIdx = json.IndexOf(':', idx);
            if (colonIdx < 0) return null;

            int valStart = colonIdx + 1;
            while (valStart < json.Length && json[valStart] == ' ') valStart++;
            if (valStart >= json.Length || json[valStart] != '"') return null;

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
                                sb.Append((char)Convert.ToInt32(json.Substring(i + 1, 4), 16));
                                i += 4;
                            }
                            break;
                        default: sb.Append(json[i]); break;
                    }
                    escaped = false;
                }
                else if (json[i] == '\\') { escaped = true; }
                else if (json[i] == '"')  { return sb.ToString(); }
                else                       { sb.Append(json[i]); }
            }
        }
        catch { }
        return null;
    }

    /// <summary>本地语音合成（System.Speech），生成 wav 音频</summary>
    private bool TryLocalSpeech(HttpContext context, string text, string voice)
    {
        object synth = null;
        Type synthType = null;
        try
        {
            synthType = Type.GetType("System.Speech.Synthesis.SpeechSynthesizer, System.Speech");
            if (synthType == null) return false;
            synth = Activator.CreateInstance(synthType);

            try
            {
                string cultureName = "zh-CN";
                if (voice.StartsWith("zh-TW")) cultureName = "zh-TW";
                else if (voice.StartsWith("zh-HK")) cultureName = "zh-HK";

                bool isFemale = voice.IndexOf("Xiao", StringComparison.OrdinalIgnoreCase) >= 0
                             || voice.IndexOf("Hiu", StringComparison.OrdinalIgnoreCase) >= 0
                             || voice.IndexOf("Xiaobei", StringComparison.OrdinalIgnoreCase) >= 0
                             || voice.IndexOf("Xiaoni", StringComparison.OrdinalIgnoreCase) >= 0;
                bool isMale = voice.IndexOf("Yun", StringComparison.OrdinalIgnoreCase) >= 0
                           || voice.IndexOf("WanLung", StringComparison.OrdinalIgnoreCase) >= 0;

                Type genderType = synthType.Assembly.GetType("System.Speech.Synthesis.VoiceGender");
                Type ageType = synthType.Assembly.GetType("System.Speech.Synthesis.VoiceAge");
                object gender = (genderType != null) ? genderType.GetField("NotSet").GetValue(null) : null;
                if (genderType != null)
                {
                    if (isFemale) gender = genderType.GetField("Female").GetValue(null);
                    else if (isMale) gender = genderType.GetField("Male").GetValue(null);
                }
                object age = (ageType != null) ? ageType.GetField("Adult").GetValue(null) : null;

                System.Reflection.MethodInfo selectVoice = synthType.GetMethod("SelectVoiceByHints",
                    new Type[] { genderType, ageType, typeof(int), typeof(CultureInfo) });
                if (selectVoice != null && genderType != null && ageType != null)
                {
                    selectVoice.Invoke(synth, new object[] { gender, age, 0, new CultureInfo(cultureName) });
                }
            }
            catch { }

            using (MemoryStream ms = new MemoryStream())
            {
                System.Reflection.MethodInfo setOutput = synthType.GetMethod("SetOutputToWaveStream");
                System.Reflection.MethodInfo speak = synthType.GetMethod("Speak", new Type[] { typeof(string) });
                if (setOutput == null || speak == null) return false;

                setOutput.Invoke(synth, new object[] { ms });
                speak.Invoke(synth, new object[] { text });

                byte[] buf = ms.ToArray();
                if (buf.Length == 0) return false;

                context.Response.Clear();
                context.Response.ContentType = "audio/wav";
                context.Response.AddHeader("Content-Disposition", "inline; filename=\"speech.wav\"");
                context.Response.BinaryWrite(buf);
                context.Response.Flush();
                return true;
            }
        }
        catch { return false; }
        finally
        {
            try
            {
                if (synth != null && synthType != null)
                {
                    System.Reflection.MethodInfo disp = synthType.GetMethod("Dispose");
                    if (disp != null) disp.Invoke(synth, null);
                }
            }
            catch { }
        }
    }

    public bool IsReusable { get { return false; } }
}
