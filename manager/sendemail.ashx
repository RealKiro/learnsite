<%@ WebHandler Language="C#" Class="sendemail" %>

using System;
using System.IO;
using System.Web;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Data.SqlClient;
using System.Configuration;
using System.Xml;

public class sendemail : IHttpHandler
{
    private void WriteJson(HttpContext context, string json)
    {
        try
        {
            if (context == null || context.Response == null)
                return;
                
            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.ContentEncoding = Encoding.UTF8;
            context.Response.Charset = "utf-8";
            
            byte[] data = Encoding.UTF8.GetBytes(json ?? "{\"success\":0,\"message\":\"空响应\"}");
            context.Response.OutputStream.Write(data, 0, data.Length);
            context.Response.Flush();
        }
        catch (Exception)
        {
            // 如果写入失败，尝试简单写入
            try
            {
                if (context != null && context.Response != null)
                {
                    context.Response.Write(json ?? "{\"success\":0,\"message\":\"错误\"}");
                }
            }
            catch
            {
                // 静默失败
            }
        }
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) 
            return "";
        try
        {
            return s.Replace("\\", "\\\\")
                    .Replace("\"", "\\\"")
                    .Replace("\r", "")
                    .Replace("\n", " ")
                    .Replace("\t", " ");
        }
        catch
        {
            return "转义失败";
        }
    }

    /// <summary>
    /// 从 website.xml 读取指定 key 的值
    /// </summary>
    private string GetWebsiteConfig(HttpContext context, string key)
    {
        try
        {
            if (context == null || string.IsNullOrEmpty(key))
                return "";
                
            string xmlPath = context.Server.MapPath("~/website.xml");
            if (string.IsNullOrEmpty(xmlPath) || !System.IO.File.Exists(xmlPath))
                return "";
                
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
            if (node != null && node.Attributes["value"] != null)
            {
                string value = node.Attributes["value"].Value;
                return value ?? "";
            }
        }
        catch (Exception)
        {
            // 静默处理异常，返回空字符串
        }
        return "";
    }

    /// <summary>
    /// 生成6位随机数字验证码
    /// </summary>
    private string GenerateCode()
    {
        Random rnd = new Random();
        return rnd.Next(100000, 999999).ToString();
    }

    /// <summary>
    /// 脱敏邮箱地址 user@domain.com -> u***r@domain.com
    /// </summary>
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

    /// <summary>
    /// 验证邮箱地址格式
    /// </summary>
    private bool IsValidEmail(string email)
    {
        if (string.IsNullOrEmpty(email)) return false;
        try
        {
            var addr = new MailAddress(email);
            return addr.Address == email.Trim();
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// 清理和规范化邮箱地址（去除空格、URL解码等）
    /// </summary>
    private string CleanEmail(string email)
    {
        if (string.IsNullOrEmpty(email)) return "";
        // 去除首尾空格
        email = email.Trim();
        // URL 解码（处理 %40 等编码）
        try
        {
            email = HttpUtility.UrlDecode(email, Encoding.UTF8);
        }
        catch { }
        // 再次去除空格（URL解码后可能产生空格）
        email = email.Trim();
        // 去除所有空白字符（包括换行符、制表符等）
        email = email.Replace("\r", "").Replace("\n", "").Replace("\t", "");
        return email;
    }

    /// <summary>
    /// 发送邮件
    /// </summary>
    private bool SendMail(HttpContext context, string toEmail, string subject, string body, out string error)
    {
        error = "";
        try
        {
            // 清理和验证收件人邮箱
            toEmail = CleanEmail(toEmail);
            if (string.IsNullOrEmpty(toEmail) || !IsValidEmail(toEmail))
            {
                error = "收件人邮箱地址格式不正确";
                return false;
            }

            string host = GetWebsiteConfig(context, "SmtpHost");
            string portStr = GetWebsiteConfig(context, "SmtpPort");
            string user = GetWebsiteConfig(context, "SmtpUser");
            string pass = GetWebsiteConfig(context, "SmtpPass");
            string sslStr = GetWebsiteConfig(context, "SmtpSsl");
            string from = GetWebsiteConfig(context, "SmtpFrom");

            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
            {
                error = "SMTP邮箱服务未配置，请联系管理员";
                return false;
            }

            // 清理和验证发件人邮箱
            if (string.IsNullOrEmpty(from)) from = user;
            from = CleanEmail(from);
            if (string.IsNullOrEmpty(from) || !IsValidEmail(from))
            {
                error = "发件人邮箱地址格式不正确";
                return false;
            }

            int port = 587;
            if (!int.TryParse(portStr, out port) || port <= 0 || port > 65535)
            {
                port = 587; // 默认端口
            }
            bool ssl = sslStr != null && sslStr.ToLower() == "true";

            SmtpClient smtp = null;
            MailMessage msg = null;
            
            try
            {
                // 验证端口范围
                if (port <= 0 || port > 65535)
                {
                    error = "SMTP端口号无效（范围：1-65535）";
                    return false;
                }
                
                smtp = new SmtpClient(host, port);
                smtp.EnableSsl = ssl;
                smtp.Credentials = new NetworkCredential(user, pass);
                smtp.Timeout = 15000;

                msg = new MailMessage();
                try
                {
                    msg.From = new MailAddress(from, "LearnSite");
                }
                catch (Exception ex)
                {
                    error = "发件人邮箱格式错误：" + ex.Message;
                    return false;
                }
                
                try
                {
                    msg.To.Add(new MailAddress(toEmail));
                }
                catch (Exception ex)
                {
                    error = "收件人邮箱格式错误：" + ex.Message;
                    return false;
                }
                
                msg.Subject = subject ?? "";
                msg.Body = body ?? "";
                msg.IsBodyHtml = true;
                msg.BodyEncoding = Encoding.UTF8;
                msg.SubjectEncoding = Encoding.UTF8;

                smtp.Send(msg);
                return true;
            }
            catch (SmtpException ex)
            {
                error = "SMTP发送失败：" + ex.Message;
                return false;
            }
            catch (Exception ex)
            {
                error = "邮件发送异常：" + ex.Message;
                return false;
            }
            finally
            {
                // .NET 2.0 不支持 Dispose，资源会自动释放
            }
        }
        catch (Exception ex)
        {
            error = ex.Message;
            return false;
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        // 最外层异常捕获
        try
        {
            // 设置响应类型
            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.ContentEncoding = Encoding.UTF8;
            
            string action = "";
            try
            {
                action = context.Request.QueryString["action"] ?? "";
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"获取参数失败：" + EscapeJson(ex.Message) + "\"}");
                return;
            }

            string connStr = "";
            
            // 安全获取连接字符串
            try
            {
                if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
                {
                    connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
                    if (string.IsNullOrEmpty(connStr))
                    {
                        WriteJson(context, "{\"success\":0,\"message\":\"数据库连接字符串为空，请检查Web.config配置\"}");
                        return;
                    }
                }
                else
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"未找到SqlServer连接字符串配置，请检查Web.config\"}");
                    return;
                }
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"数据库配置错误：" + EscapeJson(ex.Message) + "\"}");
                return;
            }

            try
            {
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
                    case "testsmtp":
                        HandleTestSmtp(context);
                        break;
                    default:
                        WriteJson(context, "{\"success\":0,\"message\":\"未知操作\"}");
                        break;
                }
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"操作失败：" + EscapeJson(ex.Message) + "\"}");
            }
        }
        catch (Exception ex)
        {
            try
            {
                if (context != null && context.Response != null)
                {
                    context.Response.ContentType = "application/json; charset=utf-8";
                    string msg = ex.Message ?? "未知错误";
                    msg = msg.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
                    context.Response.Write("{\"success\":0,\"message\":\"服务器错误：" + msg + "\"}");
                }
            }
            catch
            {
                // 最后的保护措施
                if (context != null && context.Response != null)
                {
                    try
                    {
                        context.Response.ContentType = "application/json";
                        context.Response.Write("{\"success\":0,\"message\":\"服务器错误\"}");
                    }
                    catch { }
                }
            }
        }
    }

    /// <summary>
    /// 根据用户名查询绑定的邮箱（脱敏显示）
    /// </summary>
    private void HandleLookup(HttpContext context, string connStr)
    {
        try
        {
            if (string.IsNullOrEmpty(connStr))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"数据库连接未配置\"}");
                return;
            }

            string username = context.Request.QueryString["username"] ?? "";
            if (string.IsNullOrEmpty(username))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"请输入用户名\"}");
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
                    WriteJson(context, "{\"success\":0,\"message\":\"该用户未绑定邮箱，无法找回密码\"}");
                    return;
                }

                string masked = MaskEmail(result.ToString());
                WriteJson(context, "{\"success\":1,\"email\":\"" + EscapeJson(masked) + "\"}");
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"查询失败：" + EscapeJson(ex.Message) + "\"}");
        }
    }

    /// <summary>
    /// 发送验证码到用户绑定的邮箱
    /// </summary>
    private void HandleSendCode(HttpContext context, string connStr)
    {
        try
        {
            string username = context.Request.QueryString["username"] ?? "";
            if (string.IsNullOrEmpty(username))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"请输入用户名\"}");
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
                    email = result.ToString();
            }

            if (string.IsNullOrEmpty(email))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"该用户未绑定邮箱\"}");
                return;
            }

            // 清理邮箱地址（从数据库读取的可能包含空格等）
            email = CleanEmail(email);
            if (string.IsNullOrEmpty(email) || !IsValidEmail(email))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"该用户绑定的邮箱地址格式不正确\"}");
                return;
            }

            // 检查发送频率（同一用户名60秒内只能发一次）
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM EmailVerifyCode WHERE Hname=@name AND CreatedAt>@t", conn);
                chk.Parameters.AddWithValue("@name", username);
                chk.Parameters.AddWithValue("@t", DateTime.Now.AddSeconds(-60));
                int cnt = (int)chk.ExecuteScalar();
                if (cnt > 0)
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"发送太频繁，请60秒后重试\"}");
                    return;
                }
            }

            // 生成验证码
            string code = GenerateCode();

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
            string subject = "LearnSite 密码找回验证码";
            string body = "<div style='font-family:Microsoft YaHei,Arial;max-width:480px;margin:0 auto;'>"
                + "<h2 style='color:#4f46e5;'>LearnSite 密码找回</h2>"
                + "<p>您好，您正在找回 <strong>" + EscapeJson(username) + "</strong> 的密码。</p>"
                + "<p>您的验证码为：</p>"
                + "<div style='font-size:32px;font-weight:bold;color:#4f46e5;letter-spacing:8px;padding:16px 0;'>" + code + "</div>"
                + "<p style='color:#94a3b8;font-size:13px;'>验证码10分钟内有效，请勿将验证码告知他人。</p>"
                + "<hr style='border:none;border-top:1px solid #e2e8f0;margin:16px 0;'/>"
                + "<p style='color:#94a3b8;font-size:12px;'>此邮件由 LearnSite 系统自动发送，请勿回复。</p>"
                + "</div>";

            string error;
            bool sent = SendMail(context, email, subject, body, out error);
            if (sent)
            {
                WriteJson(context, "{\"success\":1,\"message\":\"验证码已发送到绑定邮箱\"}");
            }
            else
            {
                WriteJson(context, "{\"success\":0,\"message\":\"邮件发送失败：" + EscapeJson(error) + "\"}");
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
        }
    }

    /// <summary>
    /// 校验验证码并重置密码
    /// </summary>
    private void HandleVerifyCode(HttpContext context, string connStr)
    {
        try
        {
            string username = context.Request.QueryString["username"] ?? "";
            string code = context.Request.QueryString["code"] ?? "";
            string newpwd = context.Request.QueryString["newpwd"] ?? "";

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(code) || string.IsNullOrEmpty(newpwd))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"参数不完整\"}");
                return;
            }

            if (newpwd.Length < 3)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"密码长度不能少于3位\"}");
                return;
            }

            // 校验验证码（10分钟有效）
            bool valid = false;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 Id FROM EmailVerifyCode WHERE Hname=@name AND Code=@code AND Used=0 AND CreatedAt>@t ORDER BY Id DESC", conn);
                cmd.Parameters.AddWithValue("@name", username);
                cmd.Parameters.AddWithValue("@code", code);
                cmd.Parameters.AddWithValue("@t", DateTime.Now.AddMinutes(-10));
                object result = cmd.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    valid = true;
                    // 标记为已使用
                    int id = (int)result;
                    SqlCommand upd = new SqlCommand("UPDATE EmailVerifyCode SET Used=1 WHERE Id=@id", conn);
                    upd.Parameters.AddWithValue("@id", id);
                    upd.ExecuteNonQuery();
                }
            }

            if (!valid)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"验证码无效或已过期\"}");
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
                    WriteJson(context, "{\"success\":1,\"message\":\"密码重置成功\"}");
                }
                else
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"用户不存在\"}");
                }
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
        }
    }

    /// <summary>
    /// 测试SMTP发送
    /// </summary>
    private void HandleTestSmtp(HttpContext context)
    {
        try
        {
            if (context == null)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"上下文为空\"}");
                return;
            }

            string toEmail = "";
            try
            {
                toEmail = (context.Request.QueryString["to"] ?? "").Trim();
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"获取参数失败：" + EscapeJson(ex.Message) + "\"}");
                return;
            }

            if (string.IsNullOrEmpty(toEmail))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"请输入收件邮箱\"}");
                return;
            }

            // 清理和规范化邮箱地址
            try
            {
                toEmail = CleanEmail(toEmail);
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"邮箱清理失败：" + EscapeJson(ex.Message) + "\"}");
                return;
            }
            
            // 验证邮箱格式
            if (string.IsNullOrEmpty(toEmail) || !IsValidEmail(toEmail))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"邮箱地址格式不正确\"}");
                return;
            }

            // 读取SMTP配置
            string host = "";
            string portStr = "";
            string user = "";
            string pass = "";
            string sslStr = "";
            string from = "";

            try
            {
                string xmlPath = context.Server.MapPath("~/website.xml");
                if (!System.IO.File.Exists(xmlPath))
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"配置文件不存在，请先保存SMTP配置\"}");
                    return;
                }

                XmlDocument doc = new XmlDocument();
                doc.Load(xmlPath);
                
                XmlNode hostNode = doc.SelectSingleNode("//add[@key='SmtpHost']");
                if (hostNode != null && hostNode.Attributes["value"] != null)
                    host = hostNode.Attributes["value"].Value;

                XmlNode portNode = doc.SelectSingleNode("//add[@key='SmtpPort']");
                if (portNode != null && portNode.Attributes["value"] != null)
                    portStr = portNode.Attributes["value"].Value;

                XmlNode userNode = doc.SelectSingleNode("//add[@key='SmtpUser']");
                if (userNode != null && userNode.Attributes["value"] != null)
                    user = userNode.Attributes["value"].Value;

                XmlNode passNode = doc.SelectSingleNode("//add[@key='SmtpPass']");
                if (passNode != null && passNode.Attributes["value"] != null)
                    pass = passNode.Attributes["value"].Value;

                XmlNode sslNode = doc.SelectSingleNode("//add[@key='SmtpSsl']");
                if (sslNode != null && sslNode.Attributes["value"] != null)
                    sslStr = sslNode.Attributes["value"].Value;

                XmlNode fromNode = doc.SelectSingleNode("//add[@key='SmtpFrom']");
                if (fromNode != null && fromNode.Attributes["value"] != null)
                    from = fromNode.Attributes["value"].Value;
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"读取配置失败：" + EscapeJson(ex.Message) + "\"}");
                return;
            }

            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"SMTP配置不完整，请先保存配置\"}");
                return;
            }

            if (string.IsNullOrEmpty(from)) from = user;

            int port = 587;
            if (!int.TryParse(portStr, out port) || port <= 0 || port > 65535)
            {
                port = 587;
            }
            bool ssl = sslStr != null && sslStr.ToLower() == "true";

            // 发送测试邮件
            try
            {
                SmtpClient smtp = new SmtpClient(host, port);
                smtp.EnableSsl = ssl;
                smtp.Credentials = new NetworkCredential(user, pass);
                smtp.Timeout = 15000;

                MailMessage msg = new MailMessage();
                msg.From = new MailAddress(from, "LearnSite");
                msg.To.Add(new MailAddress(toEmail));
                msg.Subject = "LearnSite SMTP 测试邮件";
                msg.Body = "<div style='font-family:Microsoft YaHei,Arial;'>"
                    + "<h2 style='color:#4f46e5;'>SMTP 测试成功</h2>"
                    + "<p>如果您收到此邮件，说明 LearnSite 的邮箱服务配置正确。</p>"
                    + "<p style='color:#94a3b8;font-size:12px;'>发送时间：" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "</p>"
                    + "</div>";
                msg.IsBodyHtml = true;
                msg.BodyEncoding = Encoding.UTF8;
                msg.SubjectEncoding = Encoding.UTF8;

                smtp.Send(msg);

                WriteJson(context, "{\"success\":1,\"message\":\"测试邮件发送成功\"}");
            }
            catch (SmtpException ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"SMTP错误：" + EscapeJson(ex.Message) + "\"}");
            }
            catch (Exception ex)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"发送失败：" + EscapeJson(ex.Message) + "\"}");
            }
        }
        catch (Exception ex)
        {
            try
            {
                WriteJson(context, "{\"success\":0,\"message\":\"系统错误：" + EscapeJson(ex.Message) + "\"}");
            }
            catch
            {
                // 如果连写入JSON都失败了，尝试直接写入
                if (context != null && context.Response != null)
                {
                    context.Response.ContentType = "application/json";
                    context.Response.Write("{\"success\":0,\"message\":\"系统错误\"}");
                }
            }
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
