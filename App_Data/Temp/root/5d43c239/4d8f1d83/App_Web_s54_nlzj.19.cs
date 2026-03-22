#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\paperapi.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "23FD15B1E4841995704B3079809CA50E"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\paperapi.ashx"


using System;
using System.IO;
using System.Text;
using System.Web;
using System.Data.SqlClient;

public class paperapi : IHttpHandler
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

    // 简单 JSON 字符串编码
    private string JsonEncode(string s)
    {
        if (s == null) return "\"\"";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t") + "\"";
    }

    // 从 JSON 字符串中提取指定键的字符串值
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
        // 数字值
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

    // 提取 JSON 数组中的对象列表
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

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AddHeader("Cache-Control", "no-cache");

        int hid = GetTeacherHid(context);
        if (hid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"未登录\"}");
            return;
        }

        string action = context.Request.QueryString["action"];

        if (action == "addquestions")
        {
            // 批量添加试题
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

            // 验证试卷属于当前教师
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
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid);
                        chk.Parameters.AddWithValue("@hid", hid);
                        int cnt = Convert.ToInt32(chk.ExecuteScalar());
                        if (cnt == 0)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                            return;
                        }
                    }

                    // 获取当前最大排序值
                    int maxSort = 0;
                    using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM PaperQuestion WHERE Qpid=@pid", conn))
                    {
                        cmdMax.Parameters.AddWithValue("@pid", pid);
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
                            "INSERT INTO PaperQuestion(Qpid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@pid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                        {
                            cmd.Parameters.AddWithValue("@pid", pid);
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
                    using (SqlCommand cmdCnt = new SqlCommand("UPDATE Paper SET Pcount=(SELECT COUNT(*) FROM PaperQuestion WHERE Qpid=@pid) WHERE Pid=@pid", conn))
                    { cmdCnt.Parameters.AddWithValue("@pid", pid); cmdCnt.ExecuteNonQuery(); }

                    context.Response.Write("{\"success\":true,\"added\":" + added + ",\"message\":\"成功添加" + added + "道试题\"}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("保存失败: " + ex.Message) + "}");
            }
        }
        else if (action == "importfrombank")
        {
            // 从题库导入选定题目到试卷
            string body2;
            using (StreamReader reader2 = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { body2 = reader2.ReadToEnd(); }

            string pidStr2 = ExtractJsonString(body2, "pid");
            int pid2 = 0; int.TryParse(pidStr2, out pid2);
            if (pid2 <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少试卷ID\"}");
                return;
            }

            // 提取 qids 数组
            System.Collections.Generic.List<int> qids = new System.Collections.Generic.List<int>();
            string qidsSearch = "\"qids\"";
            int qidsIdx = body2.IndexOf(qidsSearch);
            if (qidsIdx >= 0)
            {
                int arrS = body2.IndexOf('[', qidsIdx);
                int arrE = body2.IndexOf(']', arrS);
                if (arrS >= 0 && arrE > arrS)
                {
                    string arrStr = body2.Substring(arrS + 1, arrE - arrS - 1);
                    string[] parts = arrStr.Split(',');
                    foreach (string p in parts)
                    {
                        int v = 0;
                        if (int.TryParse(p.Trim(), out v) && v > 0) qids.Add(v);
                    }
                }
            }
            if (qids.Count == 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"未选择题目\"}");
                return;
            }

            string cs2 = GetConnStr();
            if (string.IsNullOrEmpty(cs2))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(cs2))
                {
                    conn.Open();
                    // 验证试卷所有权
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid2);
                        chk.Parameters.AddWithValue("@hid", hid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                            return;
                        }
                    }

                    int maxSort2 = 0;
                    using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM PaperQuestion WHERE Qpid=@pid", conn))
                    {
                        cmdMax.Parameters.AddWithValue("@pid", pid2);
                        object v = cmdMax.ExecuteScalar();
                        if (v != null && v != DBNull.Value) maxSort2 = Convert.ToInt32(v);
                    }

                    int added2 = 0;
                    foreach (int qid in qids)
                    {
                        using (SqlCommand cmdQ = new SqlCommand("SELECT Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore FROM QuestionBankItem WHERE Qid=@qid", conn))
                        {
                            cmdQ.Parameters.AddWithValue("@qid", qid);
                            using (SqlDataReader dr = cmdQ.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    maxSort2++;
                                    string qt = dr["Qtype"] != DBNull.Value ? dr["Qtype"].ToString() : "";
                                    string qc = dr["Qcontent"] != DBNull.Value ? dr["Qcontent"].ToString() : "";
                                    string oa = dr["Qoption_a"] != DBNull.Value ? dr["Qoption_a"].ToString() : "";
                                    string ob = dr["Qoption_b"] != DBNull.Value ? dr["Qoption_b"].ToString() : "";
                                    string oc = dr["Qoption_c"] != DBNull.Value ? dr["Qoption_c"].ToString() : "";
                                    string od = dr["Qoption_d"] != DBNull.Value ? dr["Qoption_d"].ToString() : "";
                                    string ans = dr["Qanswer"] != DBNull.Value ? dr["Qanswer"].ToString() : "";
                                    int sc = 5;
                                    if (dr["Qscore"] != DBNull.Value) sc = Convert.ToInt32(dr["Qscore"]);
                                    dr.Close();

                                    using (SqlCommand cmdIns = new SqlCommand(
                                        "INSERT INTO PaperQuestion(Qpid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@pid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                                    {
                                        cmdIns.Parameters.AddWithValue("@pid", pid2);
                                        cmdIns.Parameters.AddWithValue("@type", qt);
                                        cmdIns.Parameters.AddWithValue("@content", qc);
                                        cmdIns.Parameters.AddWithValue("@a", oa);
                                        cmdIns.Parameters.AddWithValue("@b", ob);
                                        cmdIns.Parameters.AddWithValue("@c", oc);
                                        cmdIns.Parameters.AddWithValue("@d", od);
                                        cmdIns.Parameters.AddWithValue("@ans", ans);
                                        cmdIns.Parameters.AddWithValue("@score", sc);
                                        cmdIns.Parameters.AddWithValue("@sort", maxSort2);
                                        cmdIns.ExecuteNonQuery();
                                        added2++;
                                    }
                                    continue;
                                }
                                dr.Close();
                            }
                        }
                    }

                    // 更新试卷题目数量
                    using (SqlCommand cmdCnt = new SqlCommand("UPDATE Paper SET Pcount=(SELECT COUNT(*) FROM PaperQuestion WHERE Qpid=@pid) WHERE Pid=@pid", conn))
                    { cmdCnt.Parameters.AddWithValue("@pid", pid2); cmdCnt.ExecuteNonQuery(); }

                    context.Response.Write("{\"success\":true,\"added\":" + added2 + ",\"message\":\"成功从题库导入" + added2 + "道试题\"}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("导入失败: " + ex.Message) + "}");
            }
        }
        else if (action == "batchdelete")
        {
            // 批量删除试题
            string body3;
            using (StreamReader reader3 = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { body3 = reader3.ReadToEnd(); }

            string pidStr3 = ExtractJsonString(body3, "pid");
            int pid3 = 0; int.TryParse(pidStr3, out pid3);
            if (pid3 <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少试卷ID\"}");
                return;
            }

            // 提取 qids 数组
            System.Collections.Generic.List<int> delQids = new System.Collections.Generic.List<int>();
            string qidsSearch3 = "\"qids\"";
            int qidsIdx3 = body3.IndexOf(qidsSearch3);
            if (qidsIdx3 >= 0)
            {
                int arrS3 = body3.IndexOf('[', qidsIdx3);
                int arrE3 = body3.IndexOf(']', arrS3);
                if (arrS3 >= 0 && arrE3 > arrS3)
                {
                    string arrStr3 = body3.Substring(arrS3 + 1, arrE3 - arrS3 - 1);
                    string[] parts3 = arrStr3.Split(',');
                    foreach (string p3 in parts3)
                    {
                        int v3 = 0;
                        if (int.TryParse(p3.Trim(), out v3) && v3 > 0) delQids.Add(v3);
                    }
                }
            }
            if (delQids.Count == 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"未选择试题\"}");
                return;
            }

            string cs3 = GetConnStr();
            if (string.IsNullOrEmpty(cs3))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(cs3))
                {
                    conn.Open();
                    // 验证试卷所有权
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid3);
                        chk.Parameters.AddWithValue("@hid", hid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                            return;
                        }
                    }

                    int deleted = 0;
                    foreach (int qid in delQids)
                    {
                        using (SqlCommand cmd = new SqlCommand("DELETE FROM PaperQuestion WHERE Qid=@qid AND Qpid=@pid", conn))
                        {
                            cmd.Parameters.AddWithValue("@qid", qid);
                            cmd.Parameters.AddWithValue("@pid", pid3);
                            deleted += cmd.ExecuteNonQuery();
                        }
                    }

                    // 更新试卷题目数量
                    using (SqlCommand cmdCnt = new SqlCommand("UPDATE Paper SET Pcount=(SELECT COUNT(*) FROM PaperQuestion WHERE Qpid=@pid) WHERE Pid=@pid", conn))
                    { cmdCnt.Parameters.AddWithValue("@pid", pid3); cmdCnt.ExecuteNonQuery(); }

                    context.Response.Write("{\"success\":true,\"deleted\":" + deleted + ",\"message\":\"成功删除" + deleted + "道试题\"}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("删除失败: " + ex.Message) + "}");
            }
        }
        else if (action == "updatescore")
        {
            // 更新单个试题分值
            string body5;
            using (StreamReader reader5 = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { body5 = reader5.ReadToEnd(); }

            string pidStr5 = ExtractJsonString(body5, "pid");
            string qidStr5 = ExtractJsonString(body5, "qid");
            string scoreStr5 = ExtractJsonString(body5, "score");
            int pid5 = 0; int.TryParse(pidStr5, out pid5);
            int qid5 = 0; int.TryParse(qidStr5, out qid5);
            int score5 = 0; int.TryParse(scoreStr5, out score5);
            if (pid5 <= 0 || qid5 <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"参数错误\"}");
                return;
            }
            if (score5 < 1 || score5 > 999)
            {
                context.Response.Write("{\"success\":false,\"message\":\"分值必须在1-999之间\"}");
                return;
            }

            string cs5 = GetConnStr();
            if (string.IsNullOrEmpty(cs5))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(cs5))
                {
                    conn.Open();
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid5);
                        chk.Parameters.AddWithValue("@hid", hid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                            return;
                        }
                    }
                    using (SqlCommand cmd = new SqlCommand("UPDATE PaperQuestion SET Qscore=@score WHERE Qid=@qid AND Qpid=@pid", conn))
                    {
                        cmd.Parameters.AddWithValue("@score", score5);
                        cmd.Parameters.AddWithValue("@qid", qid5);
                        cmd.Parameters.AddWithValue("@pid", pid5);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            context.Response.Write("{\"success\":true,\"message\":\"分值已更新\"}");
                        else
                            context.Response.Write("{\"success\":false,\"message\":\"未找到该试题\"}");
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("更新失败: " + ex.Message) + "}");
            }
        }
        else if (action == "batchupdatescore")
        {
            // 按类型批量更新分值
            string body6;
            using (StreamReader reader6 = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { body6 = reader6.ReadToEnd(); }

            string pidStr6 = ExtractJsonString(body6, "pid");
            string qtype6 = ExtractJsonString(body6, "qtype");
            string scoreStr6 = ExtractJsonString(body6, "score");
            int pid6 = 0; int.TryParse(pidStr6, out pid6);
            int score6 = 0; int.TryParse(scoreStr6, out score6);
            if (pid6 <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少试卷ID\"}");
                return;
            }
            if (score6 < 1 || score6 > 999)
            {
                context.Response.Write("{\"success\":false,\"message\":\"分值必须在1-999之间\"}");
                return;
            }

            string cs6 = GetConnStr();
            if (string.IsNullOrEmpty(cs6))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(cs6))
                {
                    conn.Open();
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid6);
                        chk.Parameters.AddWithValue("@hid", hid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                            return;
                        }
                    }
                    string sql6 = "UPDATE PaperQuestion SET Qscore=@score WHERE Qpid=@pid";
                    if (!string.IsNullOrEmpty(qtype6)) sql6 += " AND Qtype=@qtype";
                    using (SqlCommand cmd = new SqlCommand(sql6, conn))
                    {
                        cmd.Parameters.AddWithValue("@score", score6);
                        cmd.Parameters.AddWithValue("@pid", pid6);
                        if (!string.IsNullOrEmpty(qtype6)) cmd.Parameters.AddWithValue("@qtype", qtype6);
                        int rows = cmd.ExecuteNonQuery();
                        context.Response.Write("{\"success\":true,\"updated\":" + rows + ",\"message\":\"成功更新" + rows + "道试题的分值\"}");
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("批量更新失败: " + ex.Message) + "}");
            }
        }
        else if (action == "paperinfo")
        {
            // 获取试卷分值统计信息
            string pidStr4 = context.Request.QueryString["pid"];
            int pid4 = 0; int.TryParse(pidStr4, out pid4);
            if (pid4 <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少试卷ID\"}");
                return;
            }
            string cs4 = GetConnStr();
            if (string.IsNullOrEmpty(cs4))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }
            try
            {
                using (SqlConnection conn = new SqlConnection(cs4))
                {
                    conn.Open();
                    // 验证试卷所有权
                    int totalScore = 100;
                    using (SqlCommand chk = new SqlCommand("SELECT Pscore FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid4);
                        chk.Parameters.AddWithValue("@hid", hid);
                        object v = chk.ExecuteScalar();
                        if (v == null)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该试卷\"}");
                            return;
                        }
                        if (v != DBNull.Value) int.TryParse(v.ToString(), out totalScore);
                    }
                    int qCount = 0;
                    int scoreSum = 0;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) AS cnt, ISNULL(SUM(Qscore),0) AS total FROM PaperQuestion WHERE Qpid=@pid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid4);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                qCount = Convert.ToInt32(dr["cnt"]);
                                scoreSum = Convert.ToInt32(dr["total"]);
                            }
                        }
                    }
                    context.Response.Write("{\"success\":true,\"count\":" + qCount + ",\"scoreSum\":" + scoreSum + ",\"totalScore\":" + totalScore + "}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("查询失败: " + ex.Message) + "}");
            }
        }
        else
        {
            context.Response.Write("{\"success\":false,\"message\":\"未知操作\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
