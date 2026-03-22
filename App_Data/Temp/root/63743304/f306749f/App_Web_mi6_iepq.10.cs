#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\manager\bindemail.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "9F5D9A8BCBB933D14DF1B00F4F324B63"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\manager\bindemail.ashx"


using System;
using System.Web;
using System.Web.SessionState;
using System.Data;
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

    private static BindingFlags allFlags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static;

    private object DecodeCookieModel(string typeName, string cookieValue)
    {
        try
        {
            Assembly asm = typeof(LearnSite.Common.CookieHelp).Assembly;
            Type cookType = asm.GetType(typeName);
            if (cookType == null) return null;
            object model = Activator.CreateInstance(cookType);
            MethodInfo toModel = cookType.GetMethod("ToModel", allFlags);
            if (toModel != null)
                toModel.Invoke(model, new object[] { cookieValue });
            return model;
        }
        catch
        {
            return null;
        }
    }

    private string GetCookProp(object model, string propName)
    {
        if (model == null) return "";
        try
        {
            PropertyInfo prop = model.GetType().GetProperty(propName);
            if (prop == null) return "";
            object val = prop.GetValue(model, null);
            return val != null ? val.ToString() : "";
        }
        catch
        {
            return "";
        }
    }

    private int GetCookIntProp(object model, string propName)
    {
        string val = GetCookProp(model, propName);
        if (string.IsNullOrEmpty(val)) return 0;
        int result;
        if (int.TryParse(val, out result)) return result;
        return 0;
    }

    private int GetManagerId(HttpContext context)
    {
        try
        {
            string mngName = LearnSite.Common.CookieHelp.mngCookieNname;
            HttpCookie mngCookie = context.Request.Cookies[mngName];
            if (mngCookie != null && !string.IsNullOrEmpty(mngCookie.Value))
            {
                object mcook = DecodeCookieModel("LearnSite.Model.MngCook", mngCookie.Value);
                int hid = GetCookIntProp(mcook, "Hid");
                if (hid > 0) return hid;
            }
        }
        catch { }

        try
        {
            string teaName = LearnSite.Common.CookieHelp.teaCookieNname;
            HttpCookie teaCookie = context.Request.Cookies[teaName];
            if (teaCookie != null && !string.IsNullOrEmpty(teaCookie.Value))
            {
                object tcook = DecodeCookieModel("LearnSite.Model.TeaCook", teaCookie.Value);
                int hid = GetCookIntProp(tcook, "Hid");
                if (hid > 0) return hid;
            }
        }
        catch { }

        return 0;
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
        int hid = GetManagerId(context);
        if (hid <= 0)
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
        context.Session["EmailBindHid"] = hid;
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
        int hid = GetManagerId(context);
        if (hid <= 0)
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
        object sessionHidObj = context.Session["EmailBindHid"];
        object expireObj = context.Session["EmailBindExpire"];
        
        if (string.IsNullOrEmpty(sessionCode) || sessionHidObj == null)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Get code first\"}");
            return;
        }
        
        int sessionHid = (int)sessionHidObj;
        if (sessionHid != hid)
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
        SqlCommand cmd = null;
        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            cmd = new SqlCommand("UPDATE Teacher SET Hemail=@email WHERE Hid=@hid", conn);
            cmd.Parameters.AddWithValue("@email", email);
            cmd.Parameters.AddWithValue("@hid", hid);
            int rows = cmd.ExecuteNonQuery();
            
            if (rows > 0)
            {
                context.Session.Remove("EmailBindCode");
                context.Session.Remove("EmailBindAddress");
                context.Session.Remove("EmailBindHid");
                context.Session.Remove("EmailBindExpire");
                
                context.Response.Write("{\"success\":true,\"message\":\"Email bound\"}");
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"Bind failed\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
        finally
        {
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
            if (conn != null) conn.Dispose();
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
                throw new Exception("Config file not found. Please configure email in /manager/emailsetting.aspx");
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
                throw new Exception("SMTP server not configured. Please configure in /manager/emailsetting.aspx");
            }
            if (string.IsNullOrEmpty(fromEmail))
            {
                throw new Exception("Sender email not configured. Please configure in /manager/emailsetting.aspx");
            }
            if (string.IsNullOrEmpty(fromPassword))
            {
                throw new Exception("Email password not configured. Please configure in /manager/emailsetting.aspx");
            }
        }
        catch (Exception ex)
        {
            throw new Exception("Config error: " + ex.Message);
        }
        
        MailMessage mail = null;
        SmtpClient smtp = null;
        try
        {
            mail = new MailMessage();
            mail.From = new MailAddress(fromEmail, fromName, Encoding.UTF8);
            mail.To.Add(to);
            mail.Subject = subject;
            mail.Body = body;
            mail.IsBodyHtml = true;
            mail.BodyEncoding = Encoding.UTF8;
            mail.SubjectEncoding = Encoding.UTF8;
            mail.Priority = MailPriority.High;
            
            smtp = new SmtpClient(smtpServer, smtpPort);
            smtp.Credentials = new NetworkCredential(fromEmail, fromPassword);
            smtp.EnableSsl = enableSsl;
            smtp.Timeout = 30000;
            
            smtp.Send(mail);
        }
        catch (Exception ex)
        {
            throw new Exception("Email send error: " + ex.Message);
        }
        finally
        {
            if (mail != null) mail.Dispose();
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
