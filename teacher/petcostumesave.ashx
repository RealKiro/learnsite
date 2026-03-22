<%@ WebHandler Language="C#" Class="petcostumesave" %>

using System;
using System.IO;
using System.Web;

public class petcostumesave : IHttpHandler
{
    private void WriteJson(HttpContext ctx, string json)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        byte[] b = System.Text.Encoding.UTF8.GetBytes(json);
        ctx.Response.OutputStream.Write(b, 0, b.Length);
    }

    public void ProcessRequest(HttpContext ctx)
    {
        // Auth
        HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
        if (tc == null || string.IsNullOrEmpty(tc.Value))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u8bf7\u5148\u767b\u5f55\"}");
            return;
        }

        if (!ctx.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"Method not allowed\"}");
            return;
        }

        string json = ctx.Request.Form["json"];
        if (string.IsNullOrEmpty(json))
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u7f3a\u5c11\u53c2\u6570\"}");
            return;
        }

        // Validate JSON structure (no JavaScriptSerializer needed - .NET 2.0 compatible)
        if (!json.TrimStart().StartsWith("{") || json.IndexOf("\"costumes\"") < 0)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"JSON\u683c\u5f0f\u9519\u8bef\"}");
            return;
        }

        try
        {
            string dataDir = ctx.Server.MapPath("~/App_Data");
            if (!Directory.Exists(dataDir)) Directory.CreateDirectory(dataDir);
            string fpath = Path.Combine(dataDir, "petcostumes.json");
            File.WriteAllText(fpath, json, System.Text.Encoding.UTF8);
            WriteJson(ctx, "{\"success\":true}");
        }
        catch (Exception ex)
        {
            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u5199\u5165\u5931\u8d25: " + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    public bool IsReusable { get { return false; } }
}
