#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\VerifyEmailCode.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "4E386677CEF778B49E4DB09171BC9EF7"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\VerifyEmailCode.ashx"


using System;
using System.Web;
using System.Web.SessionState;

public class VerifyEmailCode : IHttpHandler, IRequiresSessionState {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;

        try {
            string email = context.Request.Form["email"];
            string code = context.Request.Form["code"];

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(code)) {
                context.Response.Write("{\"success\":false,\"message\":\"参数不完整\"}");
                return;
            }

            // 从Session中获取验证码信息
            string sessionCode = context.Session["EmailVerifyCode"] as string;
            string sessionEmail = context.Session["EmailVerifyCodeEmail"] as string;
            object sessionTimeObj = context.Session["EmailVerifyCodeTime"];

            if (string.IsNullOrEmpty(sessionCode) || string.IsNullOrEmpty(sessionEmail)) {
                context.Response.Write("{\"success\":false,\"message\":\"请先获取验证码\"}");
                return;
            }

            // 检查验证码是否过期
            if (sessionTimeObj != null) {
                DateTime expireTime = (DateTime)sessionTimeObj;
                if (DateTime.Now > expireTime) {
                    context.Session.Remove("EmailVerifyCode");
                    context.Session.Remove("EmailVerifyCodeEmail");
                    context.Session.Remove("EmailVerifyCodeTime");
                    context.Response.Write("{\"success\":false,\"message\":\"验证码已过期，请重新获取\"}");
                    return;
                }
            }

            // 验证邮箱是否匹配
            if (!sessionEmail.Equals(email, StringComparison.OrdinalIgnoreCase)) {
                context.Response.Write("{\"success\":false,\"message\":\"邮箱地址不匹配\"}");
                return;
            }

            // 验证验证码是否正确
            if (!sessionCode.Equals(code)) {
                context.Response.Write("{\"success\":false,\"message\":\"验证码错误\"}");
                return;
            }

            // 验证成功，标记为已验证
            context.Session["EmailVerified"] = true;
            context.Session["VerifiedEmail"] = email;

            context.Response.Write("{\"success\":true,\"message\":\"验证成功\"}");

        } catch (Exception ex) {
            context.Response.Write("{\"success\":false,\"message\":\"系统错误：" + ex.Message + "\"}");
        }
    }

    public bool IsReusable {
        get { return false; }
    }
}


#line default
#line hidden
