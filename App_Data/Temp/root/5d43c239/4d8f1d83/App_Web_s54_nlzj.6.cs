#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\questionbankapi.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "60F24761C318CF73C310E676A0BF3374"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\questionbankapi.ashx"


using System;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Web;
using System.Data.SqlClient;
using System.Xml;

public class questionbankapi : IHttpHandler
{
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private int GetTeacherHid(HttpContext context)
    {
        int hid = 0;
        try
        {
            HttpCookie tc = context.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out hid); }
                }
            }
        }
        catch { }
        return hid;
    }

    private string JsonEncode(string s)
    {
        if (s == null) return "\"\"";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t") + "\"";
    }

    private string ExtractJsonString(string json, string key)
    {
        string search = "\"" + key + "\"";
        int idx = json.IndexOf(search);
        if (idx < 0) return "";
        int colonIdx = json.IndexOf(':', idx + search.Length);
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
                        case '/': sb.Append('/'); break;
                        default: sb.Append(json[i]); break;
                    }
                    escaped = false;
                }
                else if (json[i] == '\\') { escaped = true; }
                else if (json[i] == '"') { return sb.ToString(); }
                else { sb.Append(json[i]); }
            }
        }
        else
        {
            StringBuilder sb = new StringBuilder();
            for (int i = valStart; i < json.Length; i++)
            {
                if (json[i] == ',' || json[i] == '}' || json[i] == ']') break;
                sb.Append(json[i]);
            }
            return sb.ToString().Trim();
        }
        return "";
    }

    private System.Collections.Generic.List<string> ExtractJsonArray(string json)
    {
        System.Collections.Generic.List<string> items = new System.Collections.Generic.List<string>();
        int arrStart = json.IndexOf('[');
        if (arrStart < 0) return items;
        int depth = 0;
        int objStart = -1;
        bool inString = false;
        bool escaped = false;
        for (int i = arrStart; i < json.Length; i++)
        {
            char c = json[i];
            if (escaped) { escaped = false; continue; }
            if (c == '\\' && inString) { escaped = true; continue; }
            if (c == '"') { inString = !inString; continue; }
            if (!inString)
            {
                if (c == '{')
                {
                    if (depth == 1) objStart = i;
                    depth++;
                }
                else if (c == '}')
                {
                    depth--;
                    if (depth == 1 && objStart >= 0)
                    {
                        items.Add(json.Substring(objStart, i - objStart + 1));
                        objStart = -1;
                    }
                }
                else if (c == '[') { depth++; }
                else if (c == ']') { depth--; }
            }
        }
        return items;
    }

    // 从 JSON 中提取 int 数组（如 [1,2,3]）
    private System.Collections.Generic.List<int> ExtractIntArray(string json, string key)
    {
        System.Collections.Generic.List<int> result = new System.Collections.Generic.List<int>();
        string search = "\"" + key + "\"";
        int idx = json.IndexOf(search);
        if (idx < 0) return result;
        int arrStart = json.IndexOf('[', idx);
        if (arrStart < 0) return result;
        int arrEnd = json.IndexOf(']', arrStart);
        if (arrEnd < 0) return result;
        string arrStr = json.Substring(arrStart + 1, arrEnd - arrStart - 1);
        string[] parts = arrStr.Split(',');
        foreach (string p in parts)
        {
            int v = 0;
            if (int.TryParse(p.Trim(), out v) && v > 0) result.Add(v);
        }
        return result;
    }

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
        context.Response.ContentType = "application/json";
        context.Response.AddHeader("Cache-Control", "no-cache");

        string action = context.Request.QueryString["action"];

    // AI出题配置和知识库列表不需要登录验证
        if (action == "getquizconfig")
        {
            HandleGetQuizConfig(context);
            return;
        }
        if (action == "listkb")
        {
            HandleListKB(context);
            return;
        }
        if (action == "getkbcontent")
        {
            HandleGetKBContent(context);
            return;
        }

        // aichat 需要流式输出
        if (action == "aichat")
        {
            int hid = GetTeacherHid(context);
            if (hid <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"未登录\"}");
                return;
            }
            HandleAiChat(context);
            return;
        }

        int teacherHid = GetTeacherHid(context);
        if (teacherHid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"未登录\"}");
            return;
        }

        switch (action)
        {
            case "addquestions":
                HandleAddQuestions(context, teacherHid);
                break;
            case "importtopaper":
                HandleImportToPaper(context, teacherHid);
                break;
            case "listbanks":
                HandleListBanks(context, teacherHid);
                break;
            case "listquestions":
                HandleListQuestions(context, teacherHid);
                break;
            case "listpapers":
                HandleListPapers(context, teacherHid);
                break;
            default:
                context.Response.Write("{\"success\":false,\"message\":\"未知操作\"}");
                break;
        }
    }

    // ========== 获取AI出题配置 ==========
    private void HandleGetQuizConfig(HttpContext context)
    {
        string xmlPath = context.Server.MapPath("~/website.xml");

        string quizEnabled = GetXmlValue(xmlPath, "AiQuizEnabled");
        string aiEnabled = GetXmlValue(xmlPath, "AiEnabled");

        // 判断是否可用：出题开关 或 通用开关
        bool enabled = quizEnabled.ToLower() == "true" || aiEnabled.ToLower() == "true";

        // 出题专用模型，回退到通用
        string model = GetXmlValue(xmlPath, "AiQuizModel");
        if (string.IsNullOrEmpty(model)) model = GetXmlValue(xmlPath, "AiModel");

        string systemPrompt = GetXmlValue(xmlPath, "AiQuizSystemPrompt");
        string keywords = GetXmlValue(xmlPath, "AiQuizKeywords");

        StringBuilder sb = new StringBuilder();
        sb.Append("{\"enabled\":" + (enabled ? "true" : "false"));
        sb.Append(",\"model\":" + JsonEncode(model));
        sb.Append(",\"systemPrompt\":" + JsonEncode(systemPrompt));
        sb.Append(",\"keywords\":" + JsonEncode(keywords));
        sb.Append("}");
        context.Response.Write(sb.ToString());
    }

    // ========== AI出题代理（使用出题专用配置） ==========
    private void HandleAiChat(HttpContext context)
    {
        context.Response.ContentType = "text/event-stream";
        context.Response.AddHeader("Cache-Control", "no-cache");
        context.Response.BufferOutput = false;

        string xmlPath = context.Server.MapPath("~/website.xml");
        try
        {
            // 优先读出题专用配置，回退到通用
            string apiUrl = GetXmlValue(xmlPath, "AiQuizApiUrl");
            if (string.IsNullOrEmpty(apiUrl)) apiUrl = GetXmlValue(xmlPath, "AiApiUrl");

            string apiKey = GetXmlValue(xmlPath, "AiQuizApiKey");
            if (string.IsNullOrEmpty(apiKey)) apiKey = GetXmlValue(xmlPath, "AiApiKey");

            string model = GetXmlValue(xmlPath, "AiQuizModel");
            if (string.IsNullOrEmpty(model)) model = GetXmlValue(xmlPath, "AiModel");

            string tempStr = GetXmlValue(xmlPath, "AiQuizTemperature");
            if (string.IsNullOrEmpty(tempStr)) tempStr = GetXmlValue(xmlPath, "AiTemperature");

            string maxTokensStr = GetXmlValue(xmlPath, "AiQuizMaxTokens");
            if (string.IsNullOrEmpty(maxTokensStr)) maxTokensStr = GetXmlValue(xmlPath, "AiMaxTokens");

            string systemPrompt = GetXmlValue(xmlPath, "AiQuizSystemPrompt");

            if (string.IsNullOrEmpty(apiUrl) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(model))
            {
                WriteSSEError(context, "AI 出题配置不完整，请管理员在后台设置");
                return;
            }

            double temperature = 0.7;
            double.TryParse(tempStr, out temperature);
            int maxTokens = 4000;
            int.TryParse(maxTokensStr, out maxTokens);
            if (maxTokens <= 0) maxTokens = 4000;

            // 读取请求体
            string requestBody;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { requestBody = reader.ReadToEnd(); }

            string messagesJson = ExtractMessages(requestBody);
            if (string.IsNullOrEmpty(messagesJson))
            {
                WriteSSEError(context, "请求格式错误");
                return;
            }

            // 添加系统提示词
            string fullMessages = messagesJson;
            if (!string.IsNullOrEmpty(systemPrompt))
            {
                string systemMsg = "{\"role\":\"system\",\"content\":" + JsonEncode(systemPrompt) + "}";
                if (fullMessages.TrimStart().StartsWith("["))
                    fullMessages = "[" + systemMsg + "," + fullMessages.TrimStart().Substring(1);
            }

            string openAiBody = "{\"model\":" + JsonEncode(model)
                + ",\"messages\":" + fullMessages
                + ",\"temperature\":" + temperature.ToString("F1", System.Globalization.CultureInfo.InvariantCulture)
                + ",\"max_tokens\":" + maxTokens
                + ",\"stream\":true}";

            string chatUrl = apiUrl.TrimEnd('/');
            if (!chatUrl.EndsWith("/chat/completions"))
                chatUrl += "/chat/completions";

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
            apiRequest.Timeout = 120000;
            apiRequest.ReadWriteTimeout = 120000;

            byte[] bodyBytes = Encoding.UTF8.GetBytes(openAiBody);
            apiRequest.ContentLength = bodyBytes.Length;
            using (Stream reqStream = apiRequest.GetRequestStream())
            { reqStream.Write(bodyBytes, 0, bodyBytes.Length); }

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
            string errorMsg = "AI 出题请求失败";
            if (wex.Response != null)
            {
                try
                {
                    using (StreamReader sr = new StreamReader(wex.Response.GetResponseStream(), Encoding.UTF8))
                    { errorMsg += "：" + sr.ReadToEnd(); }
                }
                catch { }
            }
            else { errorMsg += "：" + wex.Message; }
            WriteSSEError(context, errorMsg);
        }
        catch (Exception ex)
        {
            WriteSSEError(context, "服务器错误：" + ex.Message);
        }
    }

    private void WriteSSEError(HttpContext context, string message)
    {
        context.Response.Write("data: {\"content\":" + JsonEncode(message) + "}\n\ndata: [DONE]\n\n");
        context.Response.Flush();
    }

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
                    else if (json[i] == '\\') { escaped = true; }
                    else if (json[i] == '"') { return sb.ToString(); }
                    else { sb.Append(json[i]); }
                }
            }
            else if (json.Substring(valStart, 4) == "null") { return null; }
        }
        catch { }
        return null;
    }

    // ========== 批量添加题目到题单 ==========
    private void HandleAddQuestions(HttpContext context, int hid)
    {
        string body;
        using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
        { body = reader.ReadToEnd(); }

        string bidStr = ExtractJsonString(body, "bid");
        int bid = 0; int.TryParse(bidStr, out bid);
        if (bid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"缺少题单ID\"}");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 验证所有权
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM QuestionBankList WHERE Bid=@bid AND Bhid=@hid", conn))
                {
                    chk.Parameters.AddWithValue("@bid", bid);
                    chk.Parameters.AddWithValue("@hid", hid);
                    int cnt = Convert.ToInt32(chk.ExecuteScalar());
                    if (cnt == 0)
                    {
                        context.Response.Write("{\"success\":false,\"message\":\"无权操作该题单\"}");
                        return;
                    }
                }

                int maxSort = 0;
                using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM QuestionBankItem WHERE Qbid=@bid", conn))
                {
                    cmdMax.Parameters.AddWithValue("@bid", bid);
                    object v = cmdMax.ExecuteScalar();
                    if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v);
                }

                // 提取 questions 数组
                int qIdx = body.IndexOf("\"questions\"");
                string questionsJson = "";
                if (qIdx >= 0)
                {
                    int arrStart = body.IndexOf('[', qIdx);
                    if (arrStart >= 0)
                    {
                        int depth2 = 0;
                        bool inStr = false;
                        bool esc = false;
                        for (int i = arrStart; i < body.Length; i++)
                        {
                            char ch = body[i];
                            if (esc) { esc = false; continue; }
                            if (ch == '\\' && inStr) { esc = true; continue; }
                            if (ch == '"') { inStr = !inStr; continue; }
                            if (!inStr)
                            {
                                if (ch == '[') depth2++;
                                else if (ch == ']') { depth2--; if (depth2 == 0) { questionsJson = body.Substring(arrStart, i - arrStart + 1); break; } }
                            }
                        }
                    }
                }

                System.Collections.Generic.List<string> items = ExtractJsonArray(questionsJson);
                int added = 0;
                foreach (string item in items)
                {
                    string qtype = ExtractJsonString(item, "type");
                    string qcontent = ExtractJsonString(item, "content");
                    string optA = ExtractJsonString(item, "option_a");
                    string optB = ExtractJsonString(item, "option_b");
                    string optC = ExtractJsonString(item, "option_c");
                    string optD = ExtractJsonString(item, "option_d");
                    string answer = ExtractJsonString(item, "answer");
                    string scoreStr = ExtractJsonString(item, "score");
                    int score = 5; int.TryParse(scoreStr, out score);
                    if (score <= 0) score = 5;
                    if (string.IsNullOrEmpty(qcontent)) continue;

                    maxSort++;
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO QuestionBankItem(Qbid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@bid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@bid", bid);
                        cmd.Parameters.AddWithValue("@type", qtype);
                        cmd.Parameters.AddWithValue("@content", qcontent);
                        cmd.Parameters.AddWithValue("@a", optA);
                        cmd.Parameters.AddWithValue("@b", optB);
                        cmd.Parameters.AddWithValue("@c", optC);
                        cmd.Parameters.AddWithValue("@d", optD);
                        cmd.Parameters.AddWithValue("@ans", answer);
                        cmd.Parameters.AddWithValue("@score", score);
                        cmd.Parameters.AddWithValue("@sort", maxSort);
                        cmd.ExecuteNonQuery();
                        added++;
                    }
                }

                // 更新题目数量
                using (SqlCommand cmdCnt = new SqlCommand("UPDATE QuestionBankList SET Bcount=(SELECT COUNT(*) FROM QuestionBankItem WHERE Qbid=@bid) WHERE Bid=@bid", conn))
                { cmdCnt.Parameters.AddWithValue("@bid", bid); cmdCnt.ExecuteNonQuery(); }

                context.Response.Write("{\"success\":true,\"added\":" + added + ",\"message\":\"成功添加" + added + "道题目\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("保存失败: " + ex.Message) + "}");
        }
    }

    // ========== 从题库导入到试卷 ==========
    private void HandleImportToPaper(HttpContext context, int hid)
    {
        string body;
        using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
        { body = reader.ReadToEnd(); }

        string pidStr = ExtractJsonString(body, "pid");
        int pid = 0; int.TryParse(pidStr, out pid);
        if (pid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"缺少试卷ID\"}");
            return;
        }

        System.Collections.Generic.List<int> qids = ExtractIntArray(body, "qids");
        if (qids.Count == 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"未选择题目\"}");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 验证试卷所有权
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                {
                    chk.Parameters.AddWithValue("@pid", pid);
                    chk.Parameters.AddWithValue("@hid", hid);
                    if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                    {
                        context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                        return;
                    }
                }

                int maxSort = 0;
                using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM PaperQuestion WHERE Qpid=@pid", conn))
                {
                    cmdMax.Parameters.AddWithValue("@pid", pid);
                    object v = cmdMax.ExecuteScalar();
                    if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v);
                }

                int added = 0;
                foreach (int qid in qids)
                {
                    // 从题库读取题目
                    using (SqlCommand cmdQ = new SqlCommand("SELECT Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore FROM QuestionBankItem WHERE Qid=@qid", conn))
                    {
                        cmdQ.Parameters.AddWithValue("@qid", qid);
                        using (SqlDataReader dr = cmdQ.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                maxSort++;
                                string qtype = dr["Qtype"] != DBNull.Value ? dr["Qtype"].ToString() : "";
                                string qcontent = dr["Qcontent"] != DBNull.Value ? dr["Qcontent"].ToString() : "";
                                string optA = dr["Qoption_a"] != DBNull.Value ? dr["Qoption_a"].ToString() : "";
                                string optB = dr["Qoption_b"] != DBNull.Value ? dr["Qoption_b"].ToString() : "";
                                string optC = dr["Qoption_c"] != DBNull.Value ? dr["Qoption_c"].ToString() : "";
                                string optD = dr["Qoption_d"] != DBNull.Value ? dr["Qoption_d"].ToString() : "";
                                string answer = dr["Qanswer"] != DBNull.Value ? dr["Qanswer"].ToString() : "";
                                int score = 5;
                                if (dr["Qscore"] != DBNull.Value) score = Convert.ToInt32(dr["Qscore"]);

                                dr.Close();

                                using (SqlCommand cmdIns = new SqlCommand(
                                    "INSERT INTO PaperQuestion(Qpid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@pid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                                {
                                    cmdIns.Parameters.AddWithValue("@pid", pid);
                                    cmdIns.Parameters.AddWithValue("@type", qtype);
                                    cmdIns.Parameters.AddWithValue("@content", qcontent);
                                    cmdIns.Parameters.AddWithValue("@a", optA);
                                    cmdIns.Parameters.AddWithValue("@b", optB);
                                    cmdIns.Parameters.AddWithValue("@c", optC);
                                    cmdIns.Parameters.AddWithValue("@d", optD);
                                    cmdIns.Parameters.AddWithValue("@ans", answer);
                                    cmdIns.Parameters.AddWithValue("@score", score);
                                    cmdIns.Parameters.AddWithValue("@sort", maxSort);
                                    cmdIns.ExecuteNonQuery();
                                    added++;
                                }
                                continue;
                            }
                            dr.Close();
                        }
                    }
                }

                // 更新试卷题目数量
                using (SqlCommand cmdCnt = new SqlCommand("UPDATE Paper SET Pcount=(SELECT COUNT(*) FROM PaperQuestion WHERE Qpid=@pid) WHERE Pid=@pid", conn))
                { cmdCnt.Parameters.AddWithValue("@pid", pid); cmdCnt.ExecuteNonQuery(); }

                context.Response.Write("{\"success\":true,\"added\":" + added + ",\"message\":\"成功导入" + added + "道题目到试卷\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("导入失败: " + ex.Message) + "}");
        }
    }

    // ========== 获取题单列表 ==========
    private void HandleListBanks(HttpContext context, int hid)
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                StringBuilder sb = new StringBuilder();
                sb.Append("{\"success\":true,\"banks\":[");
                using (SqlCommand cmd = new SqlCommand("SELECT Bid,Btitle,Btype,Bcount FROM QuestionBankList WHERE Bhid=@hid ORDER BY Bdate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@hid", hid);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        bool first = true;
                        while (dr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.Append("{\"bid\":" + dr["Bid"]);
                            sb.Append(",\"title\":" + JsonEncode(dr["Btitle"] != DBNull.Value ? dr["Btitle"].ToString() : ""));
                            string btype = "mixed";
                            try { if (dr["Btype"] != DBNull.Value && dr["Btype"].ToString().Trim().Length > 0) btype = dr["Btype"].ToString().Trim(); } catch { }
                            sb.Append(",\"btype\":" + JsonEncode(btype));
                            sb.Append(",\"count\":" + (dr["Bcount"] != DBNull.Value ? dr["Bcount"].ToString() : "0"));
                            sb.Append("}");
                        }
                    }
                }
                sb.Append("]}");
                context.Response.Write(sb.ToString());
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode(ex.Message) + "}");
        }
    }

    // ========== 获取指定题单的题目列表 ==========
    private void HandleListQuestions(HttpContext context, int hid)
    {
        string bidStr = context.Request.QueryString["bid"];
        int bid = 0; int.TryParse(bidStr, out bid);
        if (bid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"缺少题单ID\"}");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                StringBuilder sb = new StringBuilder();
                sb.Append("{\"success\":true,\"questions\":[");
                using (SqlCommand cmd = new SqlCommand("SELECT Qid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore FROM QuestionBankItem WHERE Qbid=@bid ORDER BY Qsort,Qid", conn))
                {
                    cmd.Parameters.AddWithValue("@bid", bid);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        bool first = true;
                        while (dr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.Append("{\"qid\":" + dr["Qid"]);
                            sb.Append(",\"type\":" + JsonEncode(dr["Qtype"] != DBNull.Value ? dr["Qtype"].ToString() : ""));
                            sb.Append(",\"content\":" + JsonEncode(dr["Qcontent"] != DBNull.Value ? dr["Qcontent"].ToString() : ""));
                            sb.Append(",\"option_a\":" + JsonEncode(dr["Qoption_a"] != DBNull.Value ? dr["Qoption_a"].ToString() : ""));
                            sb.Append(",\"option_b\":" + JsonEncode(dr["Qoption_b"] != DBNull.Value ? dr["Qoption_b"].ToString() : ""));
                            sb.Append(",\"option_c\":" + JsonEncode(dr["Qoption_c"] != DBNull.Value ? dr["Qoption_c"].ToString() : ""));
                            sb.Append(",\"option_d\":" + JsonEncode(dr["Qoption_d"] != DBNull.Value ? dr["Qoption_d"].ToString() : ""));
                            sb.Append(",\"answer\":" + JsonEncode(dr["Qanswer"] != DBNull.Value ? dr["Qanswer"].ToString() : ""));
                            sb.Append(",\"score\":" + (dr["Qscore"] != DBNull.Value ? dr["Qscore"].ToString() : "5"));
                            sb.Append("}");
                        }
                    }
                }
                sb.Append("]}");
                context.Response.Write(sb.ToString());
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode(ex.Message) + "}");
        }
    }

    // ========== 获取教师的试卷列表 ==========
    private void HandleListPapers(HttpContext context, int hid)
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                StringBuilder sb = new StringBuilder();
                sb.Append("{\"success\":true,\"papers\":[");
                using (SqlCommand cmd = new SqlCommand("SELECT Pid,Ptitle,Pcount FROM Paper WHERE Phid=@hid ORDER BY Pdate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@hid", hid);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        bool first = true;
                        while (dr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.Append("{\"pid\":" + dr["Pid"]);
                            sb.Append(",\"title\":" + JsonEncode(dr["Ptitle"] != DBNull.Value ? dr["Ptitle"].ToString() : ""));
                            sb.Append(",\"count\":" + (dr["Pcount"] != DBNull.Value ? dr["Pcount"].ToString() : "0"));
                            sb.Append("}");
                        }
                    }
                }
                sb.Append("]}");
                context.Response.Write(sb.ToString());
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode(ex.Message) + "}");
        }
    }

    // ========== 获取知识库列表 ==========
    private void HandleListKB(HttpContext context)
    {
        try
        {
            string xmlPath = context.Server.MapPath("~/App_Data/knowledge.xml");
            if (!System.IO.File.Exists(xmlPath))
            {
                context.Response.Write("{\"success\":true,\"items\":[]}");
                return;
            }
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            XmlNodeList nodes = doc.SelectNodes("//Item");
            StringBuilder sb = new StringBuilder();
            sb.Append("{\"success\":true,\"items\":[");
            bool first = true;
            if (nodes != null)
            {
                for (int i = nodes.Count - 1; i >= 0; i--)
                {
                    XmlNode node = nodes[i];
                    string id = node.Attributes["id"] != null ? node.Attributes["id"].Value : "";
                    string title = node.Attributes["title"] != null ? node.Attributes["title"].Value : "";
                    string category = node.Attributes["category"] != null ? node.Attributes["category"].Value : "";
                    string ext = node.Attributes["ext"] != null ? node.Attributes["ext"].Value : "";
                    if (!first) sb.Append(",");
                    first = false;
                    sb.Append("{\"id\":" + JsonEncode(id) + ",\"title\":" + JsonEncode(title) + ",\"category\":" + JsonEncode(category) + ",\"ext\":" + JsonEncode(ext) + "}");
                }
            }
            sb.Append("]}");
            context.Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode(ex.Message) + "}");
        }
    }

    // ========== 获取知识库文件内容（用于AI出题参考） ==========
    private void HandleGetKBContent(HttpContext context)
    {
        string ids = context.Request.QueryString["ids"];
        string keyword = context.Request.QueryString["keyword"]; // 获取关键词参数
        
        if (string.IsNullOrEmpty(ids))
        {
            context.Response.Write("{\"success\":false,\"message\":\"缺少知识库ID\"}");
            return;
        }
        try
        {
            string xmlPath = context.Server.MapPath("~/App_Data/knowledge.xml");
            if (!System.IO.File.Exists(xmlPath))
            {
                context.Response.Write("{\"success\":true,\"content\":\"\"}");
                return;
            }
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            string[] idArr = ids.Split(',');
            StringBuilder allContent = new StringBuilder();
            string knowledgeDir = context.Server.MapPath("~/knowledge/");

            // 可读取文本内容的扩展名
            string[] textExts = { ".txt", ".html", ".htm", ".csv", ".json", ".xml", ".py", ".js", ".css", ".md", ".mht" };

            // 处理关键词（支持多个关键词，用空格分隔）
            string[] keywords = null;
            if (!string.IsNullOrEmpty(keyword))
            {
                keywords = keyword.Split(new char[] { ' ', ',', '，', ';', '；' }, StringSplitOptions.RemoveEmptyEntries);
            }

            foreach (string rawId in idArr)
            {
                string kid = rawId.Trim().Replace("'", "");
                if (string.IsNullOrEmpty(kid)) continue;
                XmlNode node = doc.SelectSingleNode("//Item[@id='" + kid + "']");
                if (node == null) continue;

                string title = node.Attributes["title"] != null ? node.Attributes["title"].Value : "";
                string savedName = node.Attributes["savedName"] != null ? node.Attributes["savedName"].Value : "";
                string ext = node.Attributes["ext"] != null ? node.Attributes["ext"].Value.ToLower() : "";

                if (string.IsNullOrEmpty(savedName)) continue;
                string filePath = System.IO.Path.Combine(knowledgeDir, savedName);
                if (!System.IO.File.Exists(filePath)) continue;

                allContent.AppendLine("\n【知识库资料：" + title + "】");

                // 文本类文件直接读取
                bool isText = false;
                foreach (string te in textExts) { if (ext == te) { isText = true; break; } }

                if (isText)
                {
                    try
                    {
                        string text = System.IO.File.ReadAllText(filePath, Encoding.UTF8);
                        
                        // 如果是HTML，先去标签
                        if (ext == ".html" || ext == ".htm" || ext == ".mht")
                            text = System.Text.RegularExpressions.Regex.Replace(text, "<[^>]+>", " ").Trim();
                        
                        // 如果有关键词，进行内容过滤
                        if (keywords != null && keywords.Length > 0)
                        {
                            StringBuilder filteredContent = new StringBuilder();
                            string[] lines = text.Split(new char[] { '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
                            
                            foreach (string line in lines)
                            {
                                // 检查行中是否包含任何关键词
                                bool containsKeyword = false;
                                foreach (string kw in keywords)
                                {
                                    if (!string.IsNullOrEmpty(kw) && line.IndexOf(kw, StringComparison.OrdinalIgnoreCase) >= 0)
                                    {
                                        containsKeyword = true;
                                        break;
                                    }
                                }
                                
                                if (containsKeyword)
                                {
                                    filteredContent.AppendLine(line);
                                }
                            }
                            
                            if (filteredContent.Length > 0)
                            {
                                text = filteredContent.ToString();
                                allContent.AppendLine("(已根据关键词「" + string.Join("、", keywords) + "」筛选相关内容)");
                            }
                            else
                            {
                                // 如果没有匹配的内容，返回前1000字符作为参考
                                text = text.Length > 1000 ? text.Substring(0, 1000) : text;
                                allContent.AppendLine("(未找到包含关键词的内容，以下是文件开头部分)");
                            }
                        }
                        
                        // 限制单个文件最大8000字符
                        if (text.Length > 8000) text = text.Substring(0, 8000) + "\n...(内容已截断)";
                        
                        allContent.AppendLine(text);
                    }
                    catch { allContent.AppendLine("(文件读取失败)"); }
                }
                else if (ext == ".pdf")
                {
                    allContent.AppendLine("(PDF文件，标题：" + title + "，请根据标题相关知识出题)");
                }
                else if (ext == ".doc" || ext == ".docx" || ext == ".ppt" || ext == ".pptx" || ext == ".xls" || ext == ".xlsx")
                {
                    allContent.AppendLine("(Office文件，标题：" + title + "，请根据标题相关知识出题)");
                }
                else
                {
                    allContent.AppendLine("(文件类型 " + ext + "，标题：" + title + "，请根据标题相关知识出题)");
                }
            }

            string result = allContent.ToString();
            // 总长度限制 20000 字符
            if (result.Length > 20000) result = result.Substring(0, 20000) + "\n...(内容已截断)";

            context.Response.Write("{\"success\":true,\"content\":" + JsonEncode(result) + "}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":" + JsonEncode(ex.Message) + "}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
