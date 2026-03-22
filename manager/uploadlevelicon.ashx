<%@ WebHandler Language="C#" Class="uploadlevelicon" %>

using System;
using System.IO;
using System.Web;
using System.Text;

public class uploadlevelicon : IHttpHandler
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

            string iconDir = context.Server.MapPath("~/images/levelicons");
            if (!Directory.Exists(iconDir))
            {
                Directory.CreateDirectory(iconDir);
            }

            string fileName = "lv_" + DateTime.Now.Ticks.ToString() + ext;
            string savePath = Path.Combine(iconDir, fileName);
            file.SaveAs(savePath);

            string appPath = context.Request.ApplicationPath.TrimEnd('/');
            string url = appPath + "/images/levelicons/" + fileName;
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
