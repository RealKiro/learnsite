#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\bindemail.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "FF1AA70C4BEDFBB081A52DA6EC63B7B8"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\bindemail.ashx"


using System;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;
using System.Text;
using System.Reflection;
using System.Configuration;
using System.Net.Mail;
using System.Net;

public class bindemail : IHttpHandler, IRequiresSessionState
{
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { 
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } 
            catch { } 
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private int GetStudentId(HttpContext context)
    {
        int sid = 0;
        try
        {
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); }
                    catch { }
                }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    MethodInfo mi = ct.GetMethod("ToModel",
                        BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    PropertyInfo p = ct.GetProperty("Sid");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null) int.TryParse(v.ToString(), out sid);
                    }
                }
            }
        }
        catch { }
        return sid;
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string action = context.Request.QueryString["action"];
            
            if (action == "sendcode")
            {
                SendCode(context);
            }
            else if (action == "bind")
            {
                BindEmail(context);
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }

    private void SendCode(HttpContext context)
    {
        int sid = GetStudentId(context);
        if (sid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        string email = context.Request.QueryString["email"];
        if (string.IsNullOrEmpty(email))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Email required\"}");
            return;
        }

        Random rand = new Random();
        string code = rand.Next(100000, 999999).ToString();
        
        context.Session["EmailBindCode"] = code;
        context.Session["EmailBindAddress"] = email;
        context.Session["EmailBindSid"] = sid;
        context.Session["EmailBindExpire"] = DateTime.Now.AddMinutes(10);
        
        try
        {
            SendEmail(email, "Email Verification Code", 
                "Your verification code: <b>" + code + "</b><br><br>Valid for 10 minutes.<br><br>Ignore if not requested.");
            
            context.Response.Write("{\"success\":true,\"message\":\"Code sent\"}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Email send error: " + JsonEscape(ex.Message) + "\"}");
        }
    }

    private void BindEmail(HttpContext context)
    {
        int sid = GetStudentId(context);
        if (sid <= 0)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }

        string email = context.Request.QueryString["email"];
        string code = context.Request.QueryString["code"];
        
        if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(code))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Parameter error\"}");
            return;
        }

        string sessionCode = context.Session["EmailBindCode"] as string;
        string sessionEmail = context.Session["EmailBindAddress"] as string;
        object sessionSidObj = context.Session["EmailBindSid"];
        object expireObj = context.Session["EmailBindExpire"];
        
        if (string.IsNullOrEmpty(sessionCode) || sessionSidObj == null)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Get code first\"}");
            return;
        }
        
        int sessionSid = (int)sessionSidObj;
        if (sessionSid != sid)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Session error\"}");
            return;
        }
        
        if (expireObj != null)
        {
            DateTime expireTime = (DateTime)expireObj;
            if (DateTime.Now > expireTime)
            {
                context.Response.Write("{\"success\":false,\"message\":\"Code expired\"}");
                return;
            }
        }
        
        if (sessionCode != code || sessionEmail != email)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Code incorrect\"}");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Database connection failed\"}");
            return;
        }

        SqlConnection conn = null;
        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            SqlCommand cmd = new SqlCommand("UPDATE Students SET Semail=@email WHERE Sid=@sid", conn);
            cmd.Parameters.AddWithValue("@email", email);
            cmd.Parameters.AddWithValue("@sid", sid);
            int rows = cmd.ExecuteNonQuery();
            cmd.Dispose();
            
            if (rows > 0)
            {
                context.Session.Remove("EmailBindCode");
                context.Session.Remove("EmailBindAddress");
                context.Session.Remove("EmailBindSid");
                context.Session.Remove("EmailBindExpire");
                
                context.Response.Write("{\"success\":true,\"message\":\"Email bound\"}");
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"Bind failed\"}");
            }
            
            conn.Close();
        }
        catch (Exception ex)
        {
            if (conn != null && conn.State == System.Data.ConnectionState.Open)
            {
                conn.Close();
            }
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }

    private void SendEmail(string to, string subject, string body)
    {
        string smtpServer = "";
        int smtpPort = 587;
        string fromEmail = "";
        string fromPassword = "";
        bool enableSsl = true;
        string fromName = "LearnSite";
        
        try
        {
            string configPath = HttpContext.Current.Server.MapPath("~/website.xml");
            if (!System.IO.File.Exists(configPath))
            {
                throw new Exception("Config file not found");
            }
            
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(configPath);
            
            System.Xml.XmlNode hostNode = doc.SelectSingleNode("//add[@key='SmtpHost']");
            System.Xml.XmlNode portNode = doc.SelectSingleNode("//add[@key='SmtpPort']");
            System.Xml.XmlNode userNode = doc.SelectSingleNode("//add[@key='SmtpUser']");
            System.Xml.XmlNode passNode = doc.SelectSingleNode("//add[@key='SmtpPass']");
            System.Xml.XmlNode sslNode = doc.SelectSingleNode("//add[@key='SmtpSsl']");
            System.Xml.XmlNode fromNode = doc.SelectSingleNode("//add[@key='SmtpFrom']");
            
            if (hostNode != null && hostNode.Attributes["value"] != null)
                smtpServer = hostNode.Attributes["value"].Value.Trim();
            
            if (portNode != null && portNode.Attributes["value"] != null)
                int.TryParse(portNode.Attributes["value"].Value.Trim(), out smtpPort);
            
            if (userNode != null && userNode.Attributes["value"] != null)
                fromEmail = userNode.Attributes["value"].Value.Trim();
            
            if (passNode != null && passNode.Attributes["value"] != null)
                fromPassword = passNode.Attributes["value"].Value.Trim();
            
            if (sslNode != null && sslNode.Attributes["value"] != null)
                enableSsl = sslNode.Attributes["value"].Value.Trim().ToLower() == "true";
            
            if (fromNode != null && fromNode.Attributes["value"] != null && !string.IsNullOrEmpty(fromNode.Attributes["value"].Value.Trim()))
                fromEmail = fromNode.Attributes["value"].Value.Trim();
            
            if (string.IsNullOrEmpty(smtpServer))
            {
                throw new Exception("SMTP server not configured");
            }
            if (string.IsNullOrEmpty(fromEmail))
            {
                throw new Exception("Sender email not configured");
            }
            if (string.IsNullOrEmpty(fromPassword))
            {
                throw new Exception("Email password not configured");
            }
        }
        catch (Exception ex)
        {
            throw new Exception("Config read error: " + ex.Message);
        }
        
        try
        {
            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(fromEmail, fromName, Encoding.UTF8);
            mail.To.Add(to);
            mail.Subject = subject;
            mail.Body = body;
            mail.IsBodyHtml = true;
            mail.BodyEncoding = Encoding.UTF8;
            mail.SubjectEncoding = Encoding.UTF8;
            mail.Priority = MailPriority.High;
            
            SmtpClient smtp = new SmtpClient(smtpServer, smtpPort);
            smtp.Credentials = new NetworkCredential(fromEmail, fromPassword);
            smtp.EnableSsl = enableSsl;
            smtp.Timeout = 30000;
            
            smtp.Send(mail);
            
            mail.Dispose();
        }
        catch (Exception ex)
        {
            throw new Exception("Email send error: " + ex.Message);
        }
    }

    private string JsonEscape(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";
        return str.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n").Replace("\t", "\\t");
    }

    public bool IsReusable 
    { 
        get { return false; } 
    }
}


#line default
#line hidden
