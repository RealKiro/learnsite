<%@ page language="C#" autoeventwireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        Response.ContentEncoding = System.Text.Encoding.UTF8;

        try
        {
            int grade = 0;
            int cls = 0;

            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); }
                    catch { }
                }

                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                    System.Reflection.PropertyInfo gradeProp = ct.GetProperty("Sgrade");
                    System.Reflection.PropertyInfo clsProp = ct.GetProperty("Sclass");

                    if (gradeProp != null)
                    {
                        object gradeVal = gradeProp.GetValue(m, null);
                        if (gradeVal != null) int.TryParse(gradeVal.ToString(), out grade);
                    }

                    if (clsProp != null)
                    {
                        object clsVal = clsProp.GetValue(m, null);
                        if (clsVal != null) int.TryParse(clsVal.ToString(), out cls);
                    }
                }
            }

            if (grade > 0 && cls > 0)
            {
                string cs = GetConnStr();
                if (!string.IsNullOrEmpty(cs))
                {
                    using (SqlConnection conn = new SqlConnection(cs))
                    {
                        conn.Open();
                        string sql = "SELECT ISNULL(Rgame, 1) FROM Room WHERE Rgrade=@Grade AND Rclass=@Class";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Grade", grade);
                            cmd.Parameters.AddWithValue("@Class", cls);
                            cmd.CommandTimeout = 5;

                            object result = cmd.ExecuteScalar();
                            if (result != null)
                            {
                                bool enabled = Convert.ToBoolean(result);
                                Response.Write("{\"gameEnabled\":" + (enabled ? "true" : "false") + "}");
                                Response.Flush();
                                HttpContext.Current.ApplicationInstance.CompleteRequest();
                                return;
                            }
                        }
                    }
                }
            }

            Response.Write("{\"gameEnabled\":true}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"gameEnabled\":true,\"error\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }

        Response.Flush();
        HttpContext.Current.ApplicationInstance.CompleteRequest();
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
        {
            try
            {
                cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch { }
        }

        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";

        return cs;
    }
</script>
