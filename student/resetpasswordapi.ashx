<%@ WebHandler Language="C#" Class="studentresetpasswordapi" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;
using System.Text;
using System.Reflection;
using System.Configuration;
using System.Net.Mail;
using System.Net;

public class studentresetpasswordapi : IHttpHandler, IRequiresSessionState
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

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string action = context.Request.QueryString["action"];
            
            if (action == "checkstudent")
            {
                CheckStudent(context);
            }
            else if (action == "sendcode")
            {
                SendVerifyCode(context);
            }
            else if (action == "verifycode")
            {
                VerifyCode(context);
            }
            else if (action == "resetstudent")
            {
                ResetStudentPassword(context);
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

    private void CheckStudent(HttpContext context)
    {
        string snum = context.Request.QueryString["snum"];
        string sname = context.Request.QueryString["sname"];
        
        if (string.IsNullOrEmpty(snum) || string.IsNullOrEmpty(sname))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Student number and name required\"}");
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

            SqlCommand cmd = new SqlCommand("SELECT Sid, Semail FROM Students WHERE Snum=@snum AND Sname=@sname", conn);
            cmd.Parameters.AddWithValue("@snum", snum);
            cmd.Parameters.AddWithValue("@sname", sname);
            SqlDataReader dr = cmd.ExecuteReader();
            
            if (dr.Read())
            {
                int sid = dr["Sid"] != DBNull.Value ? Convert.ToInt32(dr["Sid"]) : 0;
                string email = dr["Semail"] != DBNull.Value ? dr["Semail"].ToString() : "";
                dr.Close();
                cmd.Dispose();
                
                if (sid == 0)
                {
                    context.Response.Write("{\"success\":false,\"message\":\"Student info error\"}");
                    conn.Close();
                    return;
                }
                
                if (string.IsNullOrEmpty(email))
                {
                    context.Response.Write("{\"success\":false,\"message\":\"Email not bound, contact admin\"}");
                    conn.Close();
                    return;
                }
                
                string token = Guid.NewGuid().ToString("N");
                context.Session["StudentResetToken"] = token;
                context.Session["StudentResetSnum"] = snum;
                context.Session["StudentResetSname"] = sname;
                context.Session["StudentResetSid"] = sid;
                context.Session["StudentResetEmail"] = email;
                
                context.Response.Write("{\"success\":true,\"email\":\"" + JsonEscape(email) + "\",\"token\":\"" + token + "\"}");
                conn.Close();
                return;
            }
            
            dr.Close();
            cmd.Dispose();
            context.Response.Write("{\"success\":false,\"message\":\"Student number or name incorrect\"}");
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

    private void SendVerifyCode(HttpContext context)
    {
        string snum = context.Request.QueryString["snum"];
        string sname = context.Request.QueryString["sname"];
        string token = context.Request.QueryString["token"];
        
        if (string.IsNullOrEmpty(snum) || string.IsNullOrEmpty(sname) || string.IsNullOrEmpty(token))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Parameter error\"}");
            return;
        }
        
        string sessionToken = context.Session["StudentResetToken"] as string;
        string sessionSnum = context.Session["StudentResetSnum"] as string;
        string sessionSname = context.Session["StudentResetSname"] as string;
        string email = context.Session["StudentResetEmail"] as string;
        
        if (sessionToken != token || sessionSnum != snum || sessionSname != sname || string.IsNullOrEmpty(email))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Session expired\"}");
            return;
        }
        
        Random rand = new Random();
        string code = rand.Next(100000, 999999).ToString();
        
        context.Session["StudentVerifyCode"] = code;
        context.Session["StudentCodeExpireTime"] = DateTime.Now.AddMinutes(10);
        
        try
        {
            SendEmail(email, "Password Reset Code", 
                "Your verification code: <b>" + code + "</b><br><br>Valid for 10 minutes.<br><br>Ignore if not requested.");
            
            context.Response.Write("{\"success\":true,\"message\":\"Code sent\"}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Email send error: " + JsonEscape(ex.Message) + "\"}");
        }
    }

    private void VerifyCode(HttpContext context)
    {
        string snum = context.Request.QueryString["snum"];
        string sname = context.Request.QueryString["sname"];
        string code = context.Request.QueryString["code"];
        string token = context.Request.QueryString["token"];
        
        if (string.IsNullOrEmpty(snum) || string.IsNullOrEmpty(sname) || 
            string.IsNullOrEmpty(code) || string.IsNullOrEmpty(token))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Parameter error\"}");
            return;
        }
        
        string sessionToken = context.Session["StudentResetToken"] as string;
        string sessionSnum = context.Session["StudentResetSnum"] as string;
        string sessionSname = context.Session["StudentResetSname"] as string;
        string sessionCode = context.Session["StudentVerifyCode"] as string;
        object expireTimeObj = context.Session["StudentCodeExpireTime"];
        
        if (sessionToken != token || sessionSnum != snum || sessionSname != sname)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Session expired\"}");
            return;
        }
        
        if (string.IsNullOrEmpty(sessionCode))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Get code first\"}");
            return;
        }
        
        if (expireTimeObj != null)
        {
            DateTime expireTime = (DateTime)expireTimeObj;
            if (DateTime.Now > expireTime)
            {
                context.Response.Write("{\"success\":false,\"message\":\"Code expired\"}");
                return;
            }
        }
        
        if (sessionCode != code)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Code incorrect\"}");
            return;
        }
        
        context.Session["StudentCodeVerified"] = true;
        context.Response.Write("{\"success\":true,\"message\":\"Verified\"}");
    }

    private void ResetStudentPassword(HttpContext context)
    {
        string snum = context.Request.QueryString["snum"];
        string sname = context.Request.QueryString["sname"];
        string code = context.Request.QueryString["code"];
        string password = context.Request.QueryString["password"];
        string token = context.Request.QueryString["token"];
        
        if (string.IsNullOrEmpty(snum) || string.IsNullOrEmpty(sname) || 
            string.IsNullOrEmpty(code) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(token))
        {
            context.Response.Write("{\"success\":false,\"message\":\"Parameter error\"}");
            return;
        }
        
        string sessionToken = context.Session["StudentResetToken"] as string;
        string sessionSnum = context.Session["StudentResetSnum"] as string;
        string sessionSname = context.Session["StudentResetSname"] as string;
        object sidObj = context.Session["StudentResetSid"];
        object verifiedObj = context.Session["StudentCodeVerified"];
        
        if (sessionToken != token || sessionSnum != snum || sessionSname != sname || sidObj == null)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Session expired\"}");
            return;
        }
        
        if (verifiedObj == null || !(bool)verifiedObj)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Verify email first\"}");
            return;
        }
        
        int sid = (int)sidObj;
        
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

            SqlCommand cmd = new SqlCommand("UPDATE Students SET Spwd=@pwd WHERE Sid=@sid", conn);
            cmd.Parameters.AddWithValue("@pwd", password);
            cmd.Parameters.AddWithValue("@sid", sid);
            int rows = cmd.ExecuteNonQuery();
            cmd.Dispose();
            
            if (rows > 0)
            {
                context.Session.Remove("StudentResetToken");
                context.Session.Remove("StudentResetSnum");
                context.Session.Remove("StudentResetSname");
                context.Session.Remove("StudentResetSid");
                context.Session.Remove("StudentResetEmail");
                context.Session.Remove("StudentVerifyCode");
                context.Session.Remove("StudentCodeExpireTime");
                context.Session.Remove("StudentCodeVerified");
                
                context.Response.Write("{\"success\":true,\"message\":\"Password reset success\"}");
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"Password reset failed\"}");
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
