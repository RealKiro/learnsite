<%@ WebHandler Language="C#" Class="petcosupl" %>

using System;
using System.IO;
using System.Web;
using System.Text;

public class petcosupl : IHttpHandler
{
    private static readonly string[] VALID_IDS  = { "costume_sunglasses", "costume_hat", "costume_bow", "costume_star", "costume_ghost", "costume_crown", "costume_wings" };
    private static readonly string[] VALID_EXTS = { ".png", ".jpg", ".jpeg", ".gif", ".webp" };

    private void WriteJson(HttpContext ctx, string json)
    {
        ctx.Response.ContentType     = "application/json; charset=utf-8";
        ctx.Response.ContentEncoding = Encoding.UTF8;
        byte[] b = Encoding.UTF8.GetBytes(json);
        ctx.Response.OutputStream.Write(b, 0, b.Length);
    }

    private bool ValidId(string s)  { foreach (string v in VALID_IDS)  if (v == s) return true; return false; }
    private bool ValidExt(string s) { foreach (string v in VALID_EXTS) if (v == s) return true; return false; }

    public void ProcessRequest(HttpContext ctx)
    {
        // Auth
        HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
        if (tc == null || string.IsNullOrEmpty(tc.Value))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u8bf7\u5148\u767b\u5f55\"}");
            return;
        }

        string action    = ctx.Request["action"]    ?? "upload";
        string costumeId = ctx.Request["costumeId"] ?? "";

        if (!ValidId(costumeId))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u53c2\u6570\u9519\u8bef\"}");
            return;
        }

        string dir;
        try
        {
            dir = ctx.Server.MapPath("~/images/costumes");
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        }
        catch (Exception ex)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u76ee\u5f55\u521b\u5efa\u5931\u8d25: " + ex.Message.Replace("\"", "'") + "\"}");
            return;
        }

        // ---- DELETE ----
        if (action == "delete")
        {
            try
            {
                bool deleted = false;
                foreach (string ext in VALID_EXTS)
                {
                    string fp = Path.Combine(dir, costumeId + ext);
                    if (File.Exists(fp)) { File.Delete(fp); deleted = true; }
                }
                WriteJson(ctx, deleted ? "{\"success\":true}" : "{\"success\":false,\"msg\":\"\u6587\u4ef6\u4e0d\u5b58\u5728\"}");
            }
            catch (Exception ex) { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u5220\u9664\u5931\u8d25: " + ex.Message.Replace("\"", "'") + "\"}"); }
            return;
        }

        // ---- UPLOAD ----
        if (ctx.Request.Files.Count == 0)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u8bf7\u9009\u62e9\u56fe\u7247\u6587\u4ef6\"}");
            return;
        }
        HttpPostedFile file = ctx.Request.Files[0];
        if (file == null || file.ContentLength == 0)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u6587\u4ef6\u4e3a\u7a7a\"}");
            return;
        }
        if (file.ContentLength > 2 * 1024 * 1024)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u6587\u4ef6\u5927\u5c0f\u4e0d\u80fd\u8d85\u8fc72MB\"}");
            return;
        }
        string origExt = Path.GetExtension(file.FileName).ToLower();
        if (!ValidExt(origExt))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u53ea\u652f\u6301PNG/JPG/GIF/WebP\u683c\u5f0f\"}");
            return;
        }

        try
        {
            // Remove old files for this costume (any extension)
            foreach (string ext in VALID_EXTS)
            {
                string old = Path.Combine(dir, costumeId + ext);
                if (File.Exists(old)) File.Delete(old);
            }
            string newName  = costumeId + origExt;
            string savePath = Path.Combine(dir, newName);
            file.SaveAs(savePath);
            string appPath = ctx.Request.ApplicationPath.TrimEnd('/');
            string url = appPath + "/images/costumes/" + newName + "?v=" + new FileInfo(savePath).LastWriteTime.Ticks.ToString();
            WriteJson(ctx, "{\"success\":true,\"url\":\"" + url + "\"}");
        }
        catch (Exception ex) { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u4e0a\u4f20\u5931\u8d25: " + ex.Message.Replace("\"", "'") + "\"}"); }
    }

    public bool IsReusable { get { return false; } }
}
