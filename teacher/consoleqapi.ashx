<%@ WebHandler Language="C#" Class="consoleqapi" %>

using System;
using System.IO;
using System.Text;
using System.Web;
using System.Data.SqlClient;

public class consoleqapi : IHttpHandler
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

    // 自动迁移：为 Problems 表添加新列
    private void EnsureColumns(SqlConnection conn)
    {
        string[] migrations = {
            "IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('Problems') AND name='Ptype') ALTER TABLE Problems ADD [Ptype] [nvarchar](20) NULL",
            "IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('Problems') AND name='Poption_a') ALTER TABLE Problems ADD [Poption_a] [nvarchar](500) NULL",
            "IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('Problems') AND name='Poption_b') ALTER TABLE Problems ADD [Poption_b] [nvarchar](500) NULL",
            "IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('Problems') AND name='Poption_c') ALTER TABLE Problems ADD [Poption_c] [nvarchar](500) NULL",
            "IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('Problems') AND name='Poption_d') ALTER TABLE Problems ADD [Poption_d] [nvarchar](500) NULL",
            "IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('Problems') AND name='Panswer') ALTER TABLE Problems ADD [Panswer] [nvarchar](500) NULL"
        };
        foreach (string sql in migrations)
        {
            try { using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); } }
            catch { }
        }
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

        // ===== 添加题目 =====
        if (action == "addquestion")
        {
            string body;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { body = reader.ReadToEnd(); }

            string nidStr = ExtractJsonString(body, "nid");
            int nid = 0; int.TryParse(nidStr, out nid);
            if (nid <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少测评ID\"}");
                return;
            }

            string qtype = ExtractJsonString(body, "type");
            string qtitle = ExtractJsonString(body, "title").Trim();
            if (string.IsNullOrEmpty(qtitle))
            {
                context.Response.Write("{\"success\":false,\"message\":\"题目内容不能为空\"}");
                return;
            }

            string optA = ExtractJsonString(body, "option_a");
            string optB = ExtractJsonString(body, "option_b");
            string optC = ExtractJsonString(body, "option_c");
            string optD = ExtractJsonString(body, "option_d");
            string answer = ExtractJsonString(body, "answer");
            string scoreStr = ExtractJsonString(body, "score");
            int score = 2; int.TryParse(scoreStr, out score);
            if (score <= 0) score = 2;

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

                    // 验证测评属于该教师
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Consoles WHERE Nid=@nid AND Nhid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@nid", nid);
                        chk.Parameters.AddWithValue("@hid", hid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            context.Response.Write("{\"success\":false,\"message\":\"无权操作该测评\"}");
                            return;
                        }
                    }

                    EnsureColumns(conn);

                    // 获取最大排序值
                    int maxSort = 0;
                    using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Psort),0) FROM Problems WHERE Pnid=@nid", conn))
                    {
                        cmdMax.Parameters.AddWithValue("@nid", nid);
                        object v = cmdMax.ExecuteScalar();
                        if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v);
                    }

                    // 获取测评班级ID
                    int ncid = 0;
                    using (SqlCommand cmdCid = new SqlCommand("SELECT ISNULL(Ncid,0) FROM Consoles WHERE Nid=@nid", conn))
                    {
                        cmdCid.Parameters.AddWithValue("@nid", nid);
                        object v = cmdCid.ExecuteScalar();
                        if (v != null && v != DBNull.Value) int.TryParse(v.ToString(), out ncid);
                    }

                    string typeVal = string.IsNullOrEmpty(qtype) ? "single" : qtype;
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Problems(Phid,Pnid,Ptitle,Pcode,Pouput,Pscore,Pdate,Psort,Pcid,Ptype,Poption_a,Poption_b,Poption_c,Poption_d,Panswer) " +
                        "VALUES(@hid,@nid,@title,'','',@score,GETDATE(),@sort,@cid,@type,@a,@b,@c,@d,@ans)", conn))
                    {
                        cmd.Parameters.AddWithValue("@hid", hid);
                        cmd.Parameters.AddWithValue("@nid", nid);
                        cmd.Parameters.AddWithValue("@title", qtitle);
                        cmd.Parameters.AddWithValue("@score", score);
                        cmd.Parameters.AddWithValue("@sort", maxSort + 1);
                        cmd.Parameters.AddWithValue("@cid", ncid);
                        cmd.Parameters.AddWithValue("@type", typeVal);
                        cmd.Parameters.AddWithValue("@a", optA);
                        cmd.Parameters.AddWithValue("@b", optB);
                        cmd.Parameters.AddWithValue("@c", optC);
                        cmd.Parameters.AddWithValue("@d", optD);
                        cmd.Parameters.AddWithValue("@ans", answer);
                        cmd.ExecuteNonQuery();
                    }
                    context.Response.Write("{\"success\":true,\"message\":\"题目添加成功\"}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("添加失败: " + ex.Message) + "}");
            }
        }

        // ===== 获取单道题目 =====
        else if (action == "getquestion")
        {
            string pidStr = context.Request.QueryString["pid"];
            int pid = 0; int.TryParse(pidStr, out pid);
            if (pid <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少题目ID\"}");
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
                    EnsureColumns(conn);
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Pid,Ptitle,Pscore,Ptype,Poption_a,Poption_b,Poption_c,Poption_d,Panswer FROM Problems WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.Parameters.AddWithValue("@hid", hid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                StringBuilder sb = new StringBuilder();
                                sb.Append("{\"success\":true");
                                sb.Append(",\"pid\":" + dr["Pid"]);
                                sb.Append(",\"title\":" + JsonEncode(dr["Ptitle"] != DBNull.Value ? dr["Ptitle"].ToString() : ""));
                                sb.Append(",\"score\":" + (dr["Pscore"] != DBNull.Value ? dr["Pscore"].ToString() : "2"));
                                string ptype = "";
                                try { if (dr["Ptype"] != DBNull.Value) ptype = dr["Ptype"].ToString(); } catch { }
                                sb.Append(",\"type\":" + JsonEncode(string.IsNullOrEmpty(ptype) ? "single" : ptype));
                                string optA = "", optB = "", optC = "", optD = "", panswer = "";
                                try { if (dr["Poption_a"] != DBNull.Value) optA = dr["Poption_a"].ToString(); } catch { }
                                try { if (dr["Poption_b"] != DBNull.Value) optB = dr["Poption_b"].ToString(); } catch { }
                                try { if (dr["Poption_c"] != DBNull.Value) optC = dr["Poption_c"].ToString(); } catch { }
                                try { if (dr["Poption_d"] != DBNull.Value) optD = dr["Poption_d"].ToString(); } catch { }
                                try { if (dr["Panswer"] != DBNull.Value) panswer = dr["Panswer"].ToString(); } catch { }
                                sb.Append(",\"option_a\":" + JsonEncode(optA));
                                sb.Append(",\"option_b\":" + JsonEncode(optB));
                                sb.Append(",\"option_c\":" + JsonEncode(optC));
                                sb.Append(",\"option_d\":" + JsonEncode(optD));
                                sb.Append(",\"answer\":" + JsonEncode(panswer));
                                sb.Append("}");
                                context.Response.Write(sb.ToString());
                            }
                            else
                            {
                                context.Response.Write("{\"success\":false,\"message\":\"未找到题目\"}");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode(ex.Message) + "}");
            }
        }

        // ===== 修改题目 =====
        else if (action == "editquestion")
        {
            string body;
            using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
            { body = reader.ReadToEnd(); }

            string pidStr = ExtractJsonString(body, "pid");
            int pid = 0; int.TryParse(pidStr, out pid);
            if (pid <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"缺少题目ID\"}");
                return;
            }

            string qtype = ExtractJsonString(body, "type");
            string qtitle = ExtractJsonString(body, "title").Trim();
            if (string.IsNullOrEmpty(qtitle))
            {
                context.Response.Write("{\"success\":false,\"message\":\"题目内容不能为空\"}");
                return;
            }
            string optA = ExtractJsonString(body, "option_a");
            string optB = ExtractJsonString(body, "option_b");
            string optC = ExtractJsonString(body, "option_c");
            string optD = ExtractJsonString(body, "option_d");
            string answer = ExtractJsonString(body, "answer");
            string scoreStr = ExtractJsonString(body, "score");
            int score = 2; int.TryParse(scoreStr, out score);
            if (score <= 0) score = 2;

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
                    EnsureColumns(conn);
                    string typeVal = string.IsNullOrEmpty(qtype) ? "single" : qtype;
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Problems SET Ptitle=@title,Pscore=@score,Ptype=@type,Poption_a=@a,Poption_b=@b,Poption_c=@c,Poption_d=@d,Panswer=@ans WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        cmd.Parameters.AddWithValue("@title", qtitle);
                        cmd.Parameters.AddWithValue("@score", score);
                        cmd.Parameters.AddWithValue("@type", typeVal);
                        cmd.Parameters.AddWithValue("@a", optA);
                        cmd.Parameters.AddWithValue("@b", optB);
                        cmd.Parameters.AddWithValue("@c", optC);
                        cmd.Parameters.AddWithValue("@d", optD);
                        cmd.Parameters.AddWithValue("@ans", answer);
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.Parameters.AddWithValue("@hid", hid);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            context.Response.Write("{\"success\":true,\"message\":\"题目修改成功\"}");
                        else
                            context.Response.Write("{\"success\":false,\"message\":\"未找到题目或无权修改\"}");
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":" + JsonEncode("修改失败: " + ex.Message) + "}");
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
