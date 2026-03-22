#pragma checksum "C:\inetpub\wwwroot\LearnSite\manager\uploadsiteimg.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "63D3A78E039823EFB8C040EEF60710C6"

#line 1 "C:\inetpub\wwwroot\LearnSite\manager\uploadsiteimg.ashx"


using System;
using System.IO;
using System.Web;

public class uploadsiteimg : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";

        // 验证管理员登录（管理员或教师身份均可）
        if (context.Request.Cookies[LearnSite.Common.CookieHelp.mngCookieNname] == null
            && context.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname] == null)
        {
            context.Response.Write("{\"success\":0,\"message\":\"未登录或无权限\"}");
            return;
        }

        string type = context.Request.QueryString["type"]; // "logo" or "favicon"
        if (string.IsNullOrEmpty(type))
        {
            context.Response.Write("{\"success\":0,\"message\":\"缺少类型参数\"}");
            return;
        }

        if (context.Request.Files.Count == 0)
        {
            context.Response.Write("{\"success\":0,\"message\":\"未选择文件\"}");
            return;
        }

        HttpPostedFile file = context.Request.Files[0];
        if (file == null || file.ContentLength == 0)
        {
            context.Response.Write("{\"success\":0,\"message\":\"文件为空\"}");
            return;
        }

        string ext = Path.GetExtension(file.FileName).ToLower();

        try
        {
            if (type == "logo")
            {
                string[] allowedExts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
                if (Array.IndexOf(allowedExts, ext) == -1)
                {
                    context.Response.Write("{\"success\":0,\"message\":\"仅支持 PNG/JPG/GIF/SVG/WEBP 格式\"}");
                    return;
                }

                // 删除旧的 Logo 文件
                foreach (string oldExt in allowedExts)
                {
                    string oldFile = context.Server.MapPath("~/images/site-logo" + oldExt);
                    if (File.Exists(oldFile))
                        File.Delete(oldFile);
                }

                string savePath = context.Server.MapPath("~/images/site-logo" + ext);
                file.SaveAs(savePath);

                string url = context.Request.Url.GetLeftPart(UriPartial.Authority)
                    + context.Request.ApplicationPath.TrimEnd('/')
                    + "/images/site-logo" + ext + "?t=" + DateTime.Now.Ticks;

                context.Response.Write("{\"success\":1,\"message\":\"Logo上传成功\",\"url\":\"" + url + "\"}");
            }
            else if (type == "favicon")
            {
                if (ext != ".ico" && ext != ".png")
                {
                    context.Response.Write("{\"success\":0,\"message\":\"仅支持 ICO/PNG 格式\"}");
                    return;
                }

                string savePath;
                string url;
                if (ext == ".ico")
                {
                    savePath = context.Server.MapPath("~/favicon.ico");
                    file.SaveAs(savePath);
                    url = context.Request.Url.GetLeftPart(UriPartial.Authority)
                        + context.Request.ApplicationPath.TrimEnd('/')
                        + "/favicon.ico?t=" + DateTime.Now.Ticks;
                }
                else
                {
                    savePath = context.Server.MapPath("~/favicon.png");
                    file.SaveAs(savePath);
                    url = context.Request.Url.GetLeftPart(UriPartial.Authority)
                        + context.Request.ApplicationPath.TrimEnd('/')
                        + "/favicon.png?t=" + DateTime.Now.Ticks;
                }

                context.Response.Write("{\"success\":1,\"message\":\"图标上传成功\",\"url\":\"" + url + "\"}");
            }
            else
            {
                context.Response.Write("{\"success\":0,\"message\":\"未知的上传类型\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":0,\"message\":\"上传失败：" + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
