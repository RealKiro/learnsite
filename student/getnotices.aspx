<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string json = "{\"notices\":[]}";

        try
        {
            int stuGrade = 0, stuClass = 0;
            try { ReadStudentInfo(out stuGrade, out stuClass); } catch { }

            string cs = GetConnStr();
            if (!string.IsNullOrEmpty(cs))
            {
                try { json = QueryNotices(cs, stuGrade, stuClass); } catch { }
            }
        }
        catch { }

        try
        {
            Response.Clear();
            Response.ContentType = "application/json; charset=utf-8";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            Response.Write(json);
            Response.Flush();
            Response.SuppressContent = true;
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch { }
    }

    private void ReadStudentInfo(out int grade, out int cls)
    {
        grade = 0; cls = 0;
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value)) return;
            string val = sc.Value;
            if (val.Contains("%")) { try { val = HttpUtility.UrlDecode(val, System.Text.Encoding.UTF8); } catch { } }
            Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
            if (ct == null) return;
            object m = Activator.CreateInstance(ct);
            System.Reflection.BindingFlags flags = System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;
            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", flags);
            if (mi != null) mi.Invoke(m, new object[] { val });
            System.Reflection.PropertyInfo pg = ct.GetProperty("Sgrade");
            if (pg != null) { object v = pg.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out grade); }
            System.Reflection.PropertyInfo pc = ct.GetProperty("Sclass");
            if (pc != null) { object v = pc.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out cls); }
        }
        catch { }
    }

    private string QueryNotices(string cs, int grade, int cls)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("{\"notices\":[");

        using (SqlConnection conn = new SqlConnection(cs))
        {
            conn.Open();
            using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='Notice' AND xtype='U'", conn))
            {
                if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                    return "{\"notices\":[]}";
            }
            string sql = @"SELECT TOP 20 Nid, Ntitle, Ncontent, Nhname, Ndate 
                FROM Notice WHERE Nstatus=1 
                AND (Ngrade=0 OR Ngrade=@grade) 
                AND (Nclass=0 OR Nclass=@class) 
                ORDER BY Ndate DESC";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@grade", grade);
                cmd.Parameters.AddWithValue("@class", cls);
                bool first = true;
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        if (!first) sb.Append(",");
                        first = false;
                        sb.Append("{\"nid\":").Append(dr.GetInt32(0));
                        sb.Append(",\"title\":").Append(EscJson(dr.IsDBNull(1) ? "" : dr.GetString(1)));
                        string content = "";
                        if (!dr.IsDBNull(2)) { try { content = dr.GetString(2); } catch { try { content = dr.GetValue(2).ToString(); } catch { } } }
                        sb.Append(",\"content\":").Append(EscJson(content));
                        sb.Append(",\"author\":").Append(EscJson(dr.IsDBNull(3) ? "" : dr.GetString(3)));
                        string dateStr = "";
                        if (!dr.IsDBNull(4)) { try { dateStr = dr.GetDateTime(4).ToString("yyyy-MM-dd HH:mm"); } catch { } }
                        sb.Append(",\"date\":").Append(EscJson(dateStr));
                        sb.Append("}");
                    }
                }
            }
        }
        sb.Append("]}");
        return sb.ToString();
    }

    private string EscJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "\"\"";
        System.Text.StringBuilder sb = new System.Text.StringBuilder(s.Length + 2);
        sb.Append('"');
        for (int i = 0; i < s.Length; i++)
        {
            char c = s[i];
            switch (c)
            {
                case '\\': sb.Append("\\\\"); break;
                case '"': sb.Append("\\\""); break;
                case '\n': sb.Append("\\n"); break;
                case '\r': sb.Append("\\r"); break;
                case '\t': sb.Append("\\t"); break;
                case '\b': sb.Append("\\b"); break;
                case '\f': sb.Append("\\f"); break;
                default:
                    if (c < ' ') sb.AppendFormat("\\u{0:x4}", (int)c);
                    else sb.Append(c);
                    break;
            }
        }
        sb.Append('"');
        return sb.ToString();
    }

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
</script>
