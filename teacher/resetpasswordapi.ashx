<%@ WebHandler Language="C#" Class="resetpasswordapi" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;
using System.Text;
using System.Reflection;
using System.Configuration;
using System.Net.Mail;
using System.Net;

public class resetpasswordapi : IHttpHandler, IRequiresSessionState
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
            
            if (action == "checkuser")
            {
                CheckUser(context);
            }
            else if (action == "sendcode")
            {
                SendVerifyCode(context);
            }
            else if (action == "verifycode")
            {
                VerifyCode(context);
            }
            else if (action == "reset")
            {
                ResetPassword(context);
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"无效的操作\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }

    private void CheckUser(HttpContext context)
    {
        string username = context.Request.QueryString["username"];
        if (string.IsNullOrEmpty(username))
        {
            context.Response.Write("{\"success\":false,\"message\":\"用户名不能为空\"}");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }

        SqlConnection conn = null;
        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            // 检查Teacher表
            SqlCommand cmd = new SqlCommand("SELECT Hid, Hemail FROM Teacher WHERE Hname=@username", conn);
            cmd.Parameters.AddWithValue("@username", username);
            SqlDataReader dr = cmd.ExecuteReader();
            
            if (dr.Read())
            {
                string email = dr["Hemail"] != DBNull.Value ? dr["Hemail"].ToString() : "";
                int hid = dr["Hid"] != DBNull.Value ? Convert.ToInt32(dr["Hid"]) : 0;
                dr.Close();
                cmd.Dispose();
                
                if (string.IsNullOrEmpty(email))
                {
                    context.Response.Write("{\"success\":false,\"message\":\"该账号未绑定邮箱，请联系管理员\"}");
                    conn.Close();
                    return;
                }
                
                // 生成会话令牌
                string token = Guid.NewGuid().ToString("N");
                context.Session["ResetToken"] = token;
                context.Session["ResetUsername"] = username;
                context.Session["ResetHid"] = hid;
                context.Session["ResetEmail"] = email;
                
                context.Response.Write("{\"success\":true,\"email\":\"" + JsonEscape(email) + "\",\"token\":\"" + token + "\"}");
                conn.Close();
                return;
            }
            
            dr.Close();
            cmd.Dispose();
            context.Response.Write("{\"success\":false,\"message\":\"用户名不存在\"}");
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
        string username = context.Request.QueryString["username"];
        string token = context.Request.QueryString["token"];
        
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(token))
        {
            context.Response.Write("{\"success\":false,\"message\":\"参数错误\"}");
            return;
        }
        
        // 验证会话令牌
        string sessionToken = context.Session["ResetToken"] as string;
        string sessionUsername = context.Session["ResetUsername"] as string;
        string email = context.Session["ResetEmail"] as string;
        
        if (sessionToken != token || sessionUsername != username || string.IsNullOrEmpty(email))
        {
            context.Response.Write("{\"success\":false,\"message\":\"会话已过期，请重新开始\"}");
            return;
        }
        
        // 生成6位验证码
        Random rand = new Random();
        string code = rand.Next(100000, 999999).ToString();
        
        // 保存验证码到Session
        context.Session["VerifyCode"] = code;
        context.Session["CodeExpireTime"] = DateTime.Now.AddMinutes(10);
        
        // 发送邮件
        try
        {
            SendEmail(email, "密码重置验证码", 
                "您的验证码是：<b>" + code + "</b><br><br>验证码10分钟内有效，请勿泄露给他人。<br><br>如非本人操作，请忽略此邮件。");
            
            context.Response.Write("{\"success\":true,\"message\":\"验证码已发送\"}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"邮件发送失败: " + JsonEscape(ex.Message) + "\"}");
        }
    }

    private void VerifyCode(HttpContext context)
    {
        string username = context.Request.QueryString["username"];
        string code = context.Request.QueryString["code"];
        string token = context.Request.QueryString["token"];
        
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(code) || string.IsNullOrEmpty(token))
        {
            context.Response.Write("{\"success\":false,\"message\":\"参数错误\"}");
            return;
        }
        
        // 验证会话
        string sessionToken = context.Session["ResetToken"] as string;
        string sessionUsername = context.Session["ResetUsername"] as string;
        string sessionCode = context.Session["VerifyCode"] as string;
        object expireTimeObj = context.Session["CodeExpireTime"];
        
        if (sessionToken != token || sessionUsername != username)
        {
            context.Response.Write("{\"success\":false,\"message\":\"会话已过期，请重新开始\"}");
            return;
        }
        
        if (string.IsNullOrEmpty(sessionCode))
        {
            context.Response.Write("{\"success\":false,\"message\":\"请先获取验证码\"}");
            return;
        }
        
        if (expireTimeObj != null)
        {
            DateTime expireTime = (DateTime)expireTimeObj;
            if (DateTime.Now > expireTime)
            {
                context.Response.Write("{\"success\":false,\"message\":\"验证码已过期，请重新获取\"}");
                return;
            }
        }
        
        if (sessionCode != code)
        {
            context.Response.Write("{\"success\":false,\"message\":\"验证码错误\"}");
            return;
        }
        
        // 验证成功，标记已验证
        context.Session["CodeVerified"] = true;
        context.Response.Write("{\"success\":true,\"message\":\"验证成功\"}");
    }

    private void ResetPassword(HttpContext context)
    {
        string username = context.Request.QueryString["username"];
        string code = context.Request.QueryString["code"];
        string password = context.Request.QueryString["password"];
        string token = context.Request.QueryString["token"];
        
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(code) || 
            string.IsNullOrEmpty(password) || string.IsNullOrEmpty(token))
        {
            context.Response.Write("{\"success\":false,\"message\":\"参数错误\"}");
            return;
        }
        
        // 验证会话
        string sessionToken = context.Session["ResetToken"] as string;
        string sessionUsername = context.Session["ResetUsername"] as string;
        object hidObj = context.Session["ResetHid"];
        object verifiedObj = context.Session["CodeVerified"];
        
        if (sessionToken != token || sessionUsername != username || hidObj == null)
        {
            context.Response.Write("{\"success\":false,\"message\":\"会话已过期，请重新开始\"}");
            return;
        }
        
        if (verifiedObj == null || !(bool)verifiedObj)
        {
            context.Response.Write("{\"success\":false,\"message\":\"请先验证邮箱\"}");
            return;
        }
        
        int hid = (int)hidObj;
        
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            return;
        }

        SqlConnection conn = null;
        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            // 更新密码
            SqlCommand cmd = new SqlCommand("UPDATE Teacher SET Hpwd=@pwd WHERE Hid=@hid", conn);
            cmd.Parameters.AddWithValue("@pwd", password);
            cmd.Parameters.AddWithValue("@hid", hid);
            int rows = cmd.ExecuteNonQuery();
            cmd.Dispose();
            
            if (rows > 0)
            {
                // 清除会话
                context.Session.Remove("ResetToken");
                context.Session.Remove("ResetUsername");
                context.Session.Remove("ResetHid");
                context.Session.Remove("ResetEmail");
                context.Session.Remove("VerifyCode");
                context.Session.Remove("CodeExpireTime");
                context.Session.Remove("CodeVerified");
                
                context.Response.Write("{\"success\":true,\"message\":\"密码重置成功\"}");
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"密码重置失败\"}");
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
        // 从 website.xml 读取邮件配置
        string smtpServer = "";
        int smtpPort = 587;
        string fromEmail = "";
        string fromPassword = "";
        bool enableSsl = true;
        string fromName = "信息科技学习平台";
        
        try
        {
            string configPath = HttpContext.Current.Server.MapPath("~/website.xml");
            if (!System.IO.File.Exists(configPath))
            {
                throw new Exception("Config file not found");
            }
            
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(configPath);
            
            // 读取SMTP配置
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
            
            // 验证必填配置
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
            smtp.Timeout = 30000; // 30秒超时
            
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
