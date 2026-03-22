#pragma checksum "C:\inetpub\wwwroot\LearnSite\manager\uploadnavicon.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "06C4DE915BE2D9AF6C33E7395126591E"

#line 1 "C:\inetpub\wwwroot\LearnSite\manager\uploadnavicon.ashx"


using System;
using System.IO;
using System.Web;
using System.Text;

public class uploadnavicon : IHttpHandler
{
    private void WriteJson(HttpContext context, string json)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        byte[] data = Encoding.UTF8.GetBytes(json);
        context.Response.OutputStream.Write(data, 0, data.Length);
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
    }

    public void ProcessRequest(HttpContext context)
    {
        try
        {
            if (context.Request.Files.Count == 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"未选择文件\"}");
                return;
            }

            HttpPostedFile file = context.Request.Files[0];
            if (file == null || file.ContentLength == 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"文件为空\"}");
                return;
            }

            if (file.ContentLength > 512 * 1024)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"图标文件大小不能超过512KB\"}");
                return;
            }

            string ext = Path.GetExtension(file.FileName).ToLower();
            string[] allowedExts = new string[] { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg" };
            if (Array.IndexOf(allowedExts, ext) == -1)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"仅支持 PNG/JPG/GIF/WEBP/SVG 格式\"}");
                return;
            }

            string iconDir = context.Server.MapPath("~/images/navicons");
            if (!Directory.Exists(iconDir))
            {
                Directory.CreateDirectory(iconDir);
            }

            string fileName = "nav_" + DateTime.Now.Ticks.ToString() + ext;
            string savePath = Path.Combine(iconDir, fileName);
            file.SaveAs(savePath);

            string appPath = context.Request.ApplicationPath.TrimEnd('/');
            string url = appPath + "/images/navicons/" + fileName;
            WriteJson(context, "{\"success\":1,\"message\":\"图标上传成功\",\"url\":\"" + EscapeJson(url) + "\"}");
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
