<%@ WebHandler Language="C#" Class="SendEmailHandler" %>

using System;
using System.Web;
using System.Text;
using System.Data.SqlClient;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Xml;

public class SendEmailHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string action = context.Request.QueryString["action"] ?? "";
            
            // 获取连接字符串
            string connStr = "";
            try
            {
                if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
                {
                    connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
                }
            }
            catch { }
            
            if (string.IsNullOrEmpty(connStr))
            {
                WriteJson(context, 0, "数据库连接未配置，请检查Web.config");
                return;
            }
            
            switch (action)
            {
                case "lookup":
                    HandleLookup(context, connStr);
                    break;
                case "sendcode":
                    HandleSendCode(context, connStr);
                    break;
                case "verifycode":
                    HandleVerifyCode(context, connStr);
                    break;
                default:
                    WriteJson(context, 0, "未知操作");
                    break;
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, 0, "系统错误：" + EscapeJson(ex.Message));
        }
    }
    
    private void HandleLookup(HttpContext context, string connStr)
    {
        try
        {
            string username = context.Request.QueryString["username"] ?? "";
            if (string.IsNullOrEmpty(username))
            {
                WriteJson(context, 0, "请输入用户名");
                return;
            }
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("SELECT Hemail FROM Teacher WHERE Hname=@name AND (Hdelete IS NULL OR Hdelete=0)", conn);
                cmd.Parameters.AddWithValue("@name", username);
                object result = cmd.ExecuteScalar();
                
                if (result == null || result == DBNull.Value || string.IsNullOrEmpty(result.ToString()))
                {
                    WriteJson(context, 0, "该用户未绑定邮箱，无法找回密码");
                    return;
                }
                
                string email = result.ToString();
                string masked = MaskEmail(email);
                context.Response.Write("{\"success\":1,\"email\":\"" + EscapeJson(masked) + "\"}");
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, 0, "查询失败：" + EscapeJson(ex.Message));
        }
    }
    
    private void HandleSendCode(HttpContext context, string connStr)
    {
        try
        {
            string username = context.Request.QueryString["username"] ?? "";
            if (string.IsNullOrEmpty(username))
            {
                WriteJson(context, 0, "请输入用户名");
                return;
            }
            
            // 查询用户邮箱
            string email = "";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("SELECT Hemail FROM Teacher WHERE Hname=@name AND (Hdelete IS NULL OR Hdelete=0)", conn);
                cmd.Parameters.AddWithValue("@name", username);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    email = result.ToString().Trim();
            }
            
            if (string.IsNullOrEmpty(email))
            {
                WriteJson(context, 0, "该用户未绑定邮箱");
                return;
            }
            
            // 检查发送频率（60秒内只能发一次）
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查表是否存在
                SqlCommand checkTable = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='EmailVerifyCode'", conn);
                int tableExists = (int)checkTable.ExecuteScalar();
                
                if (tableExists == 0)
                {
                    // 创建表
                    SqlCommand createTable = new SqlCommand(@"
                        CREATE TABLE EmailVerifyCode (
                            Id INT IDENTITY(1,1) PRIMARY KEY,
                            Email NVARCHAR(100),
                            Code NVARCHAR(10),
                            Hname NVARCHAR(50),
                            CreatedAt DATETIME,
                            Used BIT
                        )", conn);
                    createTable.ExecuteNonQuery();
                }
                else
                {
                    // 检查频率
                    SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM EmailVerifyCode WHERE Hname=@name AND CreatedAt>@t", conn);
                    chk.Parameters.AddWithValue("@name", username);
                    chk.Parameters.AddWithValue("@t", DateTime.Now.AddSeconds(-60));
                    int cnt = (int)chk.ExecuteScalar();
                    if (cnt > 0)
                    {
                        WriteJson(context, 0, "发送太频繁，请60秒后重试");
                        return;
                    }
                }
            }
            
            // 生成验证码
            Random rnd = new Random();
            string code = rnd.Next(100000, 999999).ToString();
            
            // 写入数据库
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand ins = new SqlCommand("INSERT INTO EmailVerifyCode(Email,Code,Hname,CreatedAt,Used) VALUES(@email,@code,@name,GETDATE(),0)", conn);
                ins.Parameters.AddWithValue("@email", email);
                ins.Parameters.AddWithValue("@code", code);
                ins.Parameters.AddWithValue("@name", username);
                ins.ExecuteNonQuery();
            }
            
            // 发送邮件
            string error = "";
            bool sent = SendEmail(context, email, code, username, out error);
            
            if (sent)
            {
                WriteJson(context, 1, "验证码已发送到您的邮箱，请查收");
            }
            else
            {
                // 如果邮件发送失败，返回验证码（开发模式）
                WriteJson(context, 1, "邮件发送失败（" + error + "），开发模式验证码：" + code);
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, 0, "发送失败：" + EscapeJson(ex.Message));
        }
    }
    
    private bool SendEmail(HttpContext context, string toEmail, string code, string username, out string error)
    {
        error = "";
        try
        {
            // 读取SMTP配置
            string xmlPath = context.Server.MapPath("~/website.xml");
            if (!System.IO.File.Exists(xmlPath))
            {
                error = "配置文件不存在";
                return false;
            }
            
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            
            string host = GetXmlValue(doc, "SmtpHost");
            string portStr = GetXmlValue(doc, "SmtpPort");
            string user = GetXmlValue(doc, "SmtpUser");
            string pass = GetXmlValue(doc, "SmtpPass");
            string sslStr = GetXmlValue(doc, "SmtpSsl");
            string from = GetXmlValue(doc, "SmtpFrom");
            
            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
            {
                error = "SMTP未配置";
                return false;
            }
            
            if (string.IsNullOrEmpty(from)) from = user;
            
            int port = 587;
            int.TryParse(portStr, out port);
            bool ssl = sslStr != null && sslStr.ToLower() == "true";
            
            // 发送邮件
            SmtpClient smtp = new SmtpClient(host, port);
            smtp.EnableSsl = ssl;
            smtp.Credentials = new NetworkCredential(user, pass);
            smtp.Timeout = 15000;
            
            MailMessage msg = new MailMessage();
            msg.From = new MailAddress(from, "LearnSite");
            msg.To.Add(new MailAddress(toEmail));
            msg.Subject = "LearnSite 密码找回验证码";
            msg.Body = "<div style='font-family:Microsoft YaHei,Arial;max-width:480px;margin:0 auto;'>"
                + "<h2 style='color:#4f46e5;'>LearnSite 密码找回</h2>"
                + "<p>您好，您正在找回 <strong>" + EscapeHtml(username) + "</strong> 的密码。</p>"
                + "<p>您的验证码为：</p>"
                + "<div style='font-size:32px;font-weight:bold;color:#4f46e5;letter-spacing:8px;padding:16px 0;'>" + code + "</div>"
                + "<p style='color:#94a3b8;font-size:13px;'>验证码10分钟内有效，请勿将验证码告知他人。</p>"
                + "<hr style='border:none;border-top:1px solid #e2e8f0;margin:16px 0;'/>"
                + "<p style='color:#94a3b8;font-size:12px;'>此邮件由 LearnSite 系统自动发送，请勿回复。</p>"
                + "</div>";
            msg.IsBodyHtml = true;
            msg.BodyEncoding = Encoding.UTF8;
            msg.SubjectEncoding = Encoding.UTF8;
            
            smtp.Send(msg);
            return true;
        }
        catch (Exception ex)
        {
            error = ex.Message;
            return false;
        }
    }
    
    private string GetXmlValue(XmlDocument doc, string key)
    {
        try
        {
            XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value ?? "";
        }
        catch { }
        return "";
    }
    
    private string EscapeHtml(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
    }
    
    private void HandleVerifyCode(HttpContext context, string connStr)
    {
        try
        {
            string username = context.Request.QueryString["username"] ?? "";
            string code = (context.Request.QueryString["code"] ?? "").Trim();
            string newpwd = context.Request.QueryString["newpwd"] ?? "";
            
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(code) || string.IsNullOrEmpty(newpwd))
            {
                WriteJson(context, 0, "参数不完整");
                return;
            }
            
            if (newpwd.Length < 3)
            {
                WriteJson(context, 0, "密码长度不能少于3位");
                return;
            }
            
            // 校验验证码（10分钟有效）
            bool valid = false;
            int recordId = 0;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 先查询最近的验证码记录用于调试
                SqlCommand debugCmd = new SqlCommand(
                    "SELECT TOP 1 Id, Code, CreatedAt, Used FROM EmailVerifyCode WHERE Hname=@name ORDER BY Id DESC", conn);
                debugCmd.Parameters.AddWithValue("@name", username);
                SqlDataReader reader = debugCmd.ExecuteReader();
                
                string dbCode = "";
                DateTime dbTime = DateTime.MinValue;
                bool dbUsed = false;
                
                if (reader.Read())
                {
                    recordId = (int)reader["Id"];
                    dbCode = reader["Code"].ToString().Trim();
                    dbTime = (DateTime)reader["CreatedAt"];
                    dbUsed = (bool)reader["Used"];
                }
                reader.Close();
                
                // 检查验证码
                if (string.IsNullOrEmpty(dbCode))
                {
                    WriteJson(context, 0, "未找到验证码记录");
                    return;
                }
                
                if (dbUsed)
                {
                    WriteJson(context, 0, "验证码已被使用");
                    return;
                }
                
                if (DateTime.Now.Subtract(dbTime).TotalMinutes > 10)
                {
                    WriteJson(context, 0, "验证码已过期（超过10分钟）");
                    return;
                }
                
                if (dbCode != code)
                {
                    WriteJson(context, 0, "验证码不正确");
                    return;
                }
                
                // 验证通过，标记为已使用
                valid = true;
                SqlCommand upd = new SqlCommand("UPDATE EmailVerifyCode SET Used=1 WHERE Id=@id", conn);
                upd.Parameters.AddWithValue("@id", recordId);
                upd.ExecuteNonQuery();
            }
            
            if (!valid)
            {
                WriteJson(context, 0, "验证码无效");
                return;
            }
            
            // 重置密码
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("UPDATE Teacher SET Hpwd=@pwd WHERE Hname=@name", conn);
                cmd.Parameters.AddWithValue("@pwd", newpwd);
                cmd.Parameters.AddWithValue("@name", username);
                int rows = cmd.ExecuteNonQuery();
                
                if (rows > 0)
                {
                    WriteJson(context, 1, "密码重置成功");
                }
                else
                {
                    WriteJson(context, 0, "用户不存在");
                }
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, 0, "重置失败：" + EscapeJson(ex.Message));
        }
    }
    
    private string MaskEmail(string email)
    {
        if (string.IsNullOrEmpty(email)) return "";
        int at = email.IndexOf('@');
        if (at <= 1) return email;
        string user = email.Substring(0, at);
        string domain = email.Substring(at);
        if (user.Length <= 2)
            return user[0] + "***" + domain;
        return user[0].ToString() + "***" + user[user.Length - 1].ToString() + domain;
    }
    
    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
    }
    
    private void WriteJson(HttpContext context, int success, string message)
    {
        context.Response.Write("{\"success\":" + success + ",\"message\":\"" + EscapeJson(message) + "\"}");
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}
