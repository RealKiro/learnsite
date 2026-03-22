<%@ Page Language="C#" %>
<script runat="server">
    private static System.Reflection.BindingFlags bFlags =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    private string GetPropStr(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo p = model.GetType().GetProperty(propName);
        if (p == null) return "";
        object v = p.GetValue(model, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, System.Text.Encoding.UTF8); } catch { } }
        return s;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);

        string userName = "";
        string userClass = "";
        string role = "";

        // 1. Try student cookie
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", bFlags);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                    userName = GetPropStr(m, "Sname");
                    string grade = GetPropStr(m, "Sgrade");
                    string cls = GetPropStr(m, "Sclass");

                    if (!string.IsNullOrEmpty(grade) && grade != "0" && !string.IsNullOrEmpty(cls) && cls != "0")
                        userClass = grade + "年级" + cls + "班";
                    else if (!string.IsNullOrEmpty(cls) && cls != "0")
                        userClass = cls + "班";

                    if (!string.IsNullOrEmpty(userName))
                        role = "student";
                }
            }
        }
        catch { }

        // 2. Try teacher cookie
        if (string.IsNullOrEmpty(userName))
        {
            try
            {
                HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
                if (tc != null && !string.IsNullOrEmpty(tc.Value))
                {
                    string cookieVal = tc.Value;
                    if (cookieVal.Contains("%"))
                    { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                    Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                    if (ct != null)
                    {
                        object m = Activator.CreateInstance(ct);
                        System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", bFlags);
                        if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                        userName = GetPropStr(m, "Hname");
                        role = "teacher";
                        userClass = "教师";
                    }
                }
            }
            catch { }
        }

        // 3. Try manager cookie
        if (string.IsNullOrEmpty(userName))
        {
            try
            {
                HttpCookie mc = Request.Cookies[LearnSite.Common.CookieHelp.mngCookieNname];
                if (mc != null && !string.IsNullOrEmpty(mc.Value))
                {
                    string cookieVal = mc.Value;
                    if (cookieVal.Contains("%"))
                    { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                    Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.MngCook");
                    if (ct != null)
                    {
                        object m = Activator.CreateInstance(ct);
                        System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", bFlags);
                        if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                        userName = GetPropStr(m, "Hname");
                        role = "manager";
                        userClass = "管理员";
                    }
                }
            }
            catch { }
        }

        // Build JSON manually (no external dependency)
        string json;
        if (!string.IsNullOrEmpty(userName))
        {
            json = "{\"loggedIn\":true,\"name\":\"" + JsonEscape(userName)
                + "\",\"class\":\"" + JsonEscape(userClass)
                + "\",\"role\":\"" + JsonEscape(role) + "\"}";
        }
        else
        {
            json = "{\"loggedIn\":false}";
        }

        Response.Write(json);
        Response.End();
    }

    private string JsonEscape(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r");
    }
</script>
