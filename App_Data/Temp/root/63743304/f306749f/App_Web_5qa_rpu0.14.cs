#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\SendEmailCode.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "CF8058517F6435F7AC74962CFE36C243"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\SendEmailCode.ashx"


using System;
using System.Web;
using System.Web.SessionState;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Xml;

/// <summary>
/// 教师端：发送邮箱验证码（读取 website.xml 中的 SMTP 配置）
/// </summary>
public class TeacherSendEmailCode : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;

        try
        {
            string email = (context.Request.Form["email"] ?? context.Request.QueryString["email"] ?? "").Trim();

            if (string.IsNullOrEmpty(email))
            {
                WriteJson(context, false, "邮箱地址不能为空");
                return;
            }

            // 简单格式校验
            if (!email.Contains("@") || !email.Contains("."))
            {
                WriteJson(context, false, "邮箱地址格式不正确");
                return;
            }

            // 防止频繁发送（60秒内只允许一次）
            object lastTime = context.Session["EmailCodeSentTime"];
            if (lastTime != null)
            {
                DateTime last = (DateTime)lastTime;
                double seconds = (DateTime.Now - last).TotalSeconds;
                if (seconds < 60)
                {
                    int remain = (int)(60 - seconds);
                    WriteJson(context, false, "请 " + remain + " 秒后再试");
                    return;
                }
            }

            // 生成6位数字验证码
            Random rnd = new Random();
            string code = rnd.Next(100000, 999999).ToString();

            // 存入 Session（5分钟有效）
            context.Session["EmailVerifyCode"] = code;
            context.Session["EmailVerifyCodeEmail"] = email;
            context.Session["EmailVerifyCodeTime"] = DateTime.Now.AddMinutes(5);
            context.Session["EmailCodeSentTime"] = DateTime.Now;

            // 读取 SMTP 配置并发送
            bool sent = SendVerifyEmail(email, code, context);

            if (sent)
            {
                WriteJson(context, true, "验证码已发送到您的邮箱");
            }
            else
            {
                WriteJson(context, false, "发送失败，请检查SMTP配置或稍后重试");
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, false, "系统错误：" + ex.Message);
        }
    }

    private bool SendVerifyEmail(string toEmail, string code, HttpContext context)
    {
        try
        {
            // 从 website.xml 读取 SMTP 配置
            string xmlPath = context.Server.MapPath("~/website.xml");
            string smtpHost = GetXmlValue(xmlPath, "SmtpHost");
            string smtpPortStr = GetXmlValue(xmlPath, "SmtpPort");
            string smtpUser = GetXmlValue(xmlPath, "SmtpUser");
            string smtpPass = GetXmlValue(xmlPath, "SmtpPass");
            string smtpSslStr = GetXmlValue(xmlPath, "SmtpSsl");
            string smtpFrom = GetXmlValue(xmlPath, "SmtpFrom");
            string siteTitle = GetXmlValue(xmlPath, "SiteTitle");

            if (string.IsNullOrEmpty(siteTitle)) siteTitle = "LearnSite";

            // 未配置 SMTP 时：开发模式，验证码仅存 Session，返回成功
            if (string.IsNullOrEmpty(smtpHost) || string.IsNullOrEmpty(smtpUser))
            {
                System.Diagnostics.Debug.WriteLine("[TeacherSendEmailCode] 开发模式，验证码: " + code);
                return true;
            }

            int smtpPort = 587;
            int.TryParse(smtpPortStr, out smtpPort);
            bool smtpSsl = true;
            if (!string.IsNullOrEmpty(smtpSslStr))
                bool.TryParse(smtpSslStr, out smtpSsl);

            if (string.IsNullOrEmpty(smtpFrom)) smtpFrom = smtpUser;

            // 构造邮件
            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(smtpFrom, siteTitle);
            mail.To.Add(toEmail);
            mail.Subject = "【" + siteTitle + "】邮箱绑定验证码";
            mail.IsBodyHtml = true;

            StringBuilder body = new StringBuilder();
            body.Append("<div style='font-family:Microsoft YaHei,Arial,sans-serif;max-width:520px;margin:0 auto;'>");
            body.Append("<div style='background:linear-gradient(135deg,#6366f1,#a78bfa);padding:28px;border-radius:12px 12px 0 0;text-align:center;'>");
            body.Append("<h2 style='color:#fff;margin:0;font-size:22px;'>邮箱验证码</h2>");
            body.Append("</div>");
            body.Append("<div style='background:#fff;padding:28px;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;'>");
            body.Append("<p style='color:#374151;font-size:15px;margin:0 0 16px;'>您好，</p>");
            body.Append("<p style='color:#374151;font-size:15px;margin:0 0 16px;'>您正在绑定邮箱，验证码为：</p>");
            body.Append("<div style='background:#f5f3ff;padding:18px;text-align:center;border-radius:10px;margin:20px 0;'>");
            body.Append("<span style='font-size:36px;font-weight:bold;color:#6366f1;letter-spacing:8px;'>" + code + "</span>");
            body.Append("</div>");
            body.Append("<p style='color:#9ca3af;font-size:13px;margin:16px 0 0;'>验证码5分钟内有效，请尽快完成验证。</p>");
            body.Append("<p style='color:#9ca3af;font-size:13px;margin:6px 0 0;'>如非您本人操作，请忽略此邮件。</p>");
            body.Append("</div>");
            body.Append("</div>");

            mail.Body = body.ToString();

            SmtpClient smtp = new SmtpClient(smtpHost, smtpPort);
            smtp.EnableSsl = smtpSsl;
            smtp.UseDefaultCredentials = false;
            smtp.Credentials = new NetworkCredential(smtpUser, smtpPass);
            smtp.Send(mail);

            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[TeacherSendEmailCode] 发送邮件失败: " + ex.Message);
            return false;
        }
    }

    /// <summary>
    /// 从 website.xml 读取指定 key 的 value
    /// </summary>
    private string GetXmlValue(string xmlPath, string key)
    {
        try
        {
            if (!System.IO.File.Exists(xmlPath)) return "";
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value;
        }
        catch { }
        return "";
    }

    private void WriteJson(HttpContext context, bool success, string message)
    {
        // 手动转义 JSON 特殊字符
        string safeMsg = (message ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"");
        context.Response.Write("{\"success\":" + (success ? "true" : "false") + ",\"message\":\"" + safeMsg + "\"}");
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
