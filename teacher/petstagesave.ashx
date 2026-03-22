<%@ WebHandler Language="C#" Class="petstagesave" %>

using System;
using System.Web;

public class petstagesave : IHttpHandler
{
    private void WriteJson(HttpContext ctx, string json)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        byte[] b = System.Text.Encoding.UTF8.GetBytes(json);
        ctx.Response.OutputStream.Write(b, 0, b.Length);
    }

    public void ProcessRequest(HttpContext ctx)
    {
        // Only accept POST
        if (!ctx.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"Method not allowed\"}");
            return;
        }

        // Validate teacher cookie
        HttpCookie cookie = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
        if (cookie == null || string.IsNullOrEmpty(cookie.Value))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u8bf7\u5148\u767b\u5f55\"}");
            return;
        }

        string json = ctx.Request.Form["json"];
        if (string.IsNullOrEmpty(json))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u7f3a\u5c11\u53c2\u6570\"}");
            return;
        }

        // Validate JSON structure (.NET 2.0 compatible - no JavaScriptSerializer)
        if (!json.TrimStart().StartsWith("{") || json.IndexOf("\"stageExp\"") < 0)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"JSON\u683c\u5f0f\u9519\u8bef\"}");
            return;
        }

        try
        {
            string dataDir = ctx.Server.MapPath("~/App_Data");
            if (!System.IO.Directory.Exists(dataDir))
                System.IO.Directory.CreateDirectory(dataDir);
            string fpath = System.IO.Path.Combine(dataDir, "petstages.json");
            System.IO.File.WriteAllText(fpath, json, System.Text.Encoding.UTF8);
            WriteJson(ctx, "{\"success\":true}");
        }
        catch (Exception ex)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u5199\u5165\u5931\u8d25: " + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    public bool IsReusable { get { return false; } }
}
