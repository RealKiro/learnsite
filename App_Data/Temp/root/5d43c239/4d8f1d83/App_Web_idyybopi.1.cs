#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\uploadsiteimg.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "26D0DC2BA3599B963726222D9EA72CE2"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\uploadsiteimg.ashx"


using System;
using System.IO;
using System.Web;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;

public class uploadsiteimg : IHttpHandler
{
    private void WriteJson(HttpContext context, string json)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        byte[] data = Encoding.UTF8.GetBytes(json);
        context.Response.OutputStream.Write(data, 0, data.Length);
    }

    public void ProcessRequest(HttpContext context)
    {
        try
        {
            string type = context.Request.QueryString["type"];
            if (string.IsNullOrEmpty(type))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"missing type\"}");
                return;
            }

            if (context.Request.Files.Count == 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"no file\"}");
                return;
            }

            HttpPostedFile file = context.Request.Files[0];
            if (file == null || file.ContentLength == 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"empty file\"}");
                return;
            }

            string ext = Path.GetExtension(file.FileName).ToLower();
            string appPath = context.Request.ApplicationPath.TrimEnd('/');

            if (type == "logo")
            {
                string[] allowedExts = new string[] { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
                if (Array.IndexOf(allowedExts, ext) == -1)
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"\u4EC5\u652F\u6301 PNG/JPG/GIF/SVG/WEBP \u683C\u5F0F\"}");
                    return;
                }

                for (int i = 0; i < allowedExts.Length; i++)
                {
                    string oldFile = context.Server.MapPath("~/images/site-logo" + allowedExts[i]);
                    if (File.Exists(oldFile))
                        File.Delete(oldFile);
                }

                string savePath = context.Server.MapPath("~/images/site-logo" + ext);
                file.SaveAs(savePath);

                string url = appPath + "/images/site-logo" + ext + "?t=" + DateTime.Now.Ticks.ToString();
                WriteJson(context, "{\"success\":1,\"message\":\"Logo \u4E0A\u4F20\u6210\u529F\",\"url\":\"" + url + "\"}");
            }
            else if (type == "favicon")
            {
                if (ext != ".ico" && ext != ".png")
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"\u4EC5\u652F\u6301 ICO/PNG \u683C\u5F0F\"}");
                    return;
                }

                string savePath = "";
                string url = "";
                if (ext == ".ico")
                {
                    // 删除旧的 PNG favicon
                    string oldPng = context.Server.MapPath("~/favicon.png");
                    if (File.Exists(oldPng)) File.Delete(oldPng);

                    savePath = context.Server.MapPath("~/favicon.ico");
                    file.SaveAs(savePath);
                    byte[] saved = File.ReadAllBytes(savePath);
                    url = "data:image/x-icon;base64," + Convert.ToBase64String(saved);
                }
                else
                {
                    // 删除旧的 ICO favicon
                    string oldIco = context.Server.MapPath("~/favicon.ico");
                    if (File.Exists(oldIco)) File.Delete(oldIco);

                    savePath = context.Server.MapPath("~/favicon.png");
                    file.SaveAs(savePath);
                    url = appPath + "/favicon.png?t=" + DateTime.Now.Ticks.ToString();
                }

                WriteJson(context, "{\"success\":1,\"message\":\"Favicon \u4E0A\u4F20\u6210\u529F\",\"url\":\"" + url + "\"}");
            }
            else if (type == "scratchlogo" || type == "codinglogo")
            {
                string[] allowedExts = new string[] { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
                if (Array.IndexOf(allowedExts, ext) == -1)
                {
                    WriteJson(context, "{\"success\":0,\"message\":\"\u4EC5\u652F\u6301 PNG/JPG/GIF/SVG/WEBP \u683C\u5F0F\"}");
                    return;
                }

                // 保存为logo.png（统一使用PNG格式）
                string savePath = context.Server.MapPath("~/scratch/logo.png");
                
                // 尝试使用System.Drawing转换非PNG格式为PNG
                if (ext == ".png")
                {
                    file.SaveAs(savePath);
                }
                else
                {
                    try
                    {
                        // 尝试使用System.Drawing转换图片格式
                        System.Drawing.Image img = System.Drawing.Image.FromStream(file.InputStream);
                        img.Save(savePath, System.Drawing.Imaging.ImageFormat.Png);
                        img.Dispose();
                    }
                    catch
                    {
                        // 如果转换失败，直接保存（可能格式不匹配，但先尝试）
                        file.SaveAs(savePath);
                    }
                }

                string url = appPath + "/scratch/logo.png?t=" + DateTime.Now.Ticks.ToString();
                WriteJson(context, "{\"success\":1,\"message\":\"\u7F16\u7A0B\u9875\u9762 Logo \u4E0A\u4F20\u6210\u529F\",\"url\":\"" + url + "\"}");
            }
            else
            {
                WriteJson(context, "{\"success\":0,\"message\":\"\u672A\u77E5\u7C7B\u578B\"}");
            }
        }
        catch (Exception ex)
        {
            string msg = ex.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ");
            WriteJson(context, "{\"success\":0,\"message\":\"" + msg + "\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
