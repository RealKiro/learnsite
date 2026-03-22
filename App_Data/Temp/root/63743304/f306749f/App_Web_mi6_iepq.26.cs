#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\manager\testsmtp.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "BF0C33CEF98E69F62421D40908F65764"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\manager\testsmtp.ashx"


using System;
using System.Web;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Xml;

public class TestSmtp : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string toEmail = (context.Request.QueryString["to"] ?? "").Trim();
            
            if (string.IsNullOrEmpty(toEmail))
            {
                context.Response.Write("{\"success\":0,\"message\":\"请输入收件邮箱\"}");
                return;
            }

            if (!toEmail.Contains("@") || !toEmail.Contains("."))
            {
                context.Response.Write("{\"success\":0,\"message\":\"邮箱格式不正确\"}");
                return;
            }

            string xmlPath = context.Server.MapPath("~/website.xml");
            if (!System.IO.File.Exists(xmlPath))
            {
                context.Response.Write("{\"success\":0,\"message\":\"配置文件不存在\"}");
                return;
            }

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            string host = GetValue(doc, "SmtpHost");
            string portStr = GetValue(doc, "SmtpPort");
            string user = GetValue(doc, "SmtpUser");
            string pass = GetValue(doc, "SmtpPass");
            string sslStr = GetValue(doc, "SmtpSsl");
            string from = GetValue(doc, "SmtpFrom");

            if (string.IsNullOrEmpty(host))
            {
                context.Response.Write("{\"success\":0,\"message\":\"SMTP主机未配置\"}");
                return;
            }
            
            if (string.IsNullOrEmpty(user))
            {
                context.Response.Write("{\"success\":0,\"message\":\"SMTP用户名未配置\"}");
                return;
            }
            
            if (string.IsNullOrEmpty(pass))
            {
                context.Response.Write("{\"success\":0,\"message\":\"SMTP密码未配置\"}");
                return;
            }

            if (string.IsNullOrEmpty(from)) from = user;

            int port = 587;
            if (!string.IsNullOrEmpty(portStr))
            {
                int.TryParse(portStr, out port);
            }
            
            bool ssl = false;
            if (!string.IsNullOrEmpty(sslStr))
            {
                ssl = sslStr.ToLower() == "true";
            }

            try
            {
                SmtpClient smtp = new SmtpClient();
                smtp.Host = host;
                smtp.Port = port;
                smtp.EnableSsl = ssl;
                smtp.UseDefaultCredentials = false;
                smtp.Credentials = new NetworkCredential(user, pass);
                smtp.Timeout = 30000;

                MailMessage msg = new MailMessage();
                msg.From = new MailAddress(from);
                msg.To.Add(toEmail);
                msg.Subject = "LearnSite SMTP Test";
                msg.Body = "<h2>SMTP Test Success</h2><p>Your SMTP configuration is working correctly.</p><p>Time: " + DateTime.Now.ToString() + "</p>";
                msg.IsBodyHtml = true;

                smtp.Send(msg);

                context.Response.Write("{\"success\":1,\"message\":\"发送成功！请检查收件箱\"}");
            }
            catch (SmtpException ex)
            {
                string err = ex.Message.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
                if (err.Contains("timed out") || err.Contains("超时"))
                {
                    err = "连接超时。可能是服务器防火墙阻止了SMTP端口。建议：1)联系服务器管理员开放端口 2)尝试端口587";
                }
                else if (err.Contains("535") || err.Contains("authentication"))
                {
                    err = "认证失败。QQ/163邮箱请使用授权码（不是登录密码）";
                }
                context.Response.Write("{\"success\":0,\"message\":\"" + err + "\"}");
            }
            catch (Exception ex)
            {
                string err = ex.Message.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
                context.Response.Write("{\"success\":0,\"message\":\"" + err + "\"}");
            }
        }
        catch (Exception ex)
        {
            string err = (ex.Message ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
            context.Response.Write("{\"success\":0,\"message\":\"" + err + "\"}");
        }
    }

    private string GetValue(XmlDocument doc, string key)
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

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
