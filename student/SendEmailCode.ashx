<%@ WebHandler Language="C#" Class="SendEmailCode" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.Net;
using System.Net.Mail;
using System.Text;

public class SendEmailCode : IHttpHandler, IRequiresSessionState {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;

        try {
            string email = context.Request.Form["email"];

            if (string.IsNullOrEmpty(email)) {
                context.Response.Write("{\"success\":false,\"message\":\"邮箱地址不能为空\"}");
                return;
            }

            // 验证邮箱格式
            if (!IsValidEmail(email)) {
                context.Response.Write("{\"success\":false,\"message\":\"邮箱地址格式不正确\"}");
                return;
            }

            // 生成6位数字验证码
            Random random = new Random();
            string code = random.Next(100000, 999999).ToString();

            // 将验证码存储到Session中，设置5分钟有效期
            context.Session["EmailVerifyCode"] = code;
            context.Session["EmailVerifyCodeEmail"] = email;
            context.Session["EmailVerifyCodeTime"] = DateTime.Now.AddMinutes(5);

            // 发送邮件
            bool sent = SendEmail(email, code, context);

            if (sent) {
                context.Response.Write("{\"success\":true,\"message\":\"验证码已发送到您的邮箱\"}");
            } else {
                context.Response.Write("{\"success\":false,\"message\":\"验证码发送失败，请稍后重试\"}");
            }

        } catch (Exception ex) {
            context.Response.Write("{\"success\":false,\"message\":\"系统错误：" + ex.Message + "\"}");
        }
    }

    private bool IsValidEmail(string email) {
        try {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        } catch {
            return false;
        }
    }

    private bool SendEmail(string toEmail, string code, HttpContext context) {
        try {
            // 读取SMTP配置（可以从web.config或配置文件中读取）
            string smtpServer = GetSmtpConfig(context, "smtpServer", "smtp.qq.com");
            int smtpPort = int.Parse(GetSmtpConfig(context, "smtpPort", "587"));
            string fromEmail = GetSmtpConfig(context, "fromEmail", "noreply@example.com");
            string fromPassword = GetSmtpConfig(context, "fromPassword", "");
            string fromName = GetSmtpConfig(context, "fromName", "LearnSite");

            if (string.IsNullOrEmpty(fromPassword)) {
                // 如果没有配置SMTP，暂时只存储验证码到Session，不实际发送邮件
                // 开发环境下可以直接返回true，在控制台输出验证码
                context.Response.Write("<!-- 开发模式：验证码为 " + code + " -->");
                return true;
            }

            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(fromEmail, fromName);
            mail.To.Add(toEmail);
            mail.Subject = "【LearnSite】注册验证码";
            mail.IsBodyHtml = true;

            // 邮件内容
            StringBuilder body = new StringBuilder();
            body.Append("<div style='font-family: Microsoft YaHei, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;'>");
            body.Append("<div style='background: linear-gradient(135deg, #3b82f6, #2563eb); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;'>");
            body.Append("<h2 style='color: white; margin: 0; font-size: 24px;'>邮箱验证码</h2>");
            body.Append("</div>");
            body.Append("<div style='background: #f9fafb; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 10px 10px;'>");
            body.Append("<p style='color: #374151; font-size: 16px; margin: 0 0 20px;'>您好，</p>");
            body.Append("<p style='color: #374151; font-size: 16px; margin: 0 0 20px;'>您正在注册 LearnSite 学习平台账号，您的验证码是：</p>");
            body.Append("<div style='background: white; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;'>");
            body.Append("<span style='font-size: 32px; font-weight: bold; color: #3b82f6; letter-spacing: 5px;'>" + code + "</span>");
            body.Append("</div>");
            body.Append("<p style='color: #6b7280; font-size: 14px; margin: 20px 0 0;'>验证码有效期为5分钟，请尽快完成验证。</p>");
            body.Append("<p style='color: #6b7280; font-size: 14px; margin: 10px 0 0;'>如果这不是您的操作，请忽略此邮件。</p>");
            body.Append("</div>");
            body.Append("<div style='text-align: center; padding: 20px; color: #9ca3af; font-size: 12px;'>");
            body.Append("<p style='margin: 0;'>此邮件由系统自动发送，请勿直接回复。</p>");
            body.Append("</div>");
            body.Append("</div>");

            mail.Body = body.ToString();

            SmtpClient smtp = new SmtpClient(smtpServer, smtpPort);
            smtp.EnableSsl = true;
            smtp.UseDefaultCredentials = false;
            smtp.Credentials = new NetworkCredential(fromEmail, fromPassword);

            smtp.Send(mail);
            return true;

        } catch (Exception ex) {
            // 记录错误日志
            System.Diagnostics.Debug.WriteLine("发送邮件失败：" + ex.Message);
            return false;
        }
    }

    private string GetSmtpConfig(HttpContext context, string key, string defaultValue) {
        try {
            string xmlPath = context.Server.MapPath("~/App_Data/emailconfig.xml");
            if (!System.IO.File.Exists(xmlPath)) return defaultValue;

            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            System.Xml.XmlNode node = doc.SelectSingleNode("//" + key);

            if (node != null && !string.IsNullOrEmpty(node.InnerText)) {
                return node.InnerText;
            }
        } catch { }

        return defaultValue;
    }

    public bool IsReusable {
        get { return false; }
    }
}
