<%@ WebHandler Language="C#" Class="uploadmd" %>

using System;
using System.IO;
using System.Web;

public class uploadmd : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        // 设置响应的内容类型为 JSON
        context.Response.ContentType = "application/json";

        // 检查是否有文件上传
        if (context.Request.Files.Count > 0)
        {
            HttpPostedFile file = context.Request.Files[0];

            // 检查文件是否为空
            if (file != null && file.ContentLength > 0)
            {
                try
                {
                    // 定义允许上传的图片格式
                    string[] allowedExtensions = { ".jpg", ".jpeg", ".gif", ".png", ".bmp", ".webp" };
                    string fileExtension = Path.GetExtension(file.FileName).ToLower();

                    // 检查文件格式是否允许
                    if (Array.IndexOf(allowedExtensions, fileExtension) != -1)
                    {
                        // 生成新的文件名，避免文件名冲突
                        string newFileName = Guid.NewGuid().ToString() + fileExtension;
                        // 定义图片存储的路径
                        string uploadPath = context.Server.MapPath("~/markdown/uploads/");

                        // 确保上传目录存在
                        if (!Directory.Exists(uploadPath))
                        {
                            Directory.CreateDirectory(uploadPath);
                        }

                        // 保存文件到指定路径
                        string filePath = Path.Combine(uploadPath, newFileName);
                        file.SaveAs(filePath);

                        // 构建图片的访问 URL
                        string imageUrl = context.Request.Url.GetLeftPart(UriPartial.Authority) + context.Request.ApplicationPath + "/markdown/uploads/" + newFileName;

                        // 返回成功响应的 JSON 数据
                        string responseJson = "{\"success\": 1, \"message\": \"上传成功\", \"url\": \"" + imageUrl + "\"}";
                        context.Response.Write(responseJson);
                    }
                    else
                    {
                        // 文件格式不允许，返回错误响应的 JSON 数据
                        string responseJson = "{\"success\": 0, \"message\": \"不允许的文件格式\"}";
                        context.Response.Write(responseJson);
                    }
                }
                catch (Exception ex)
                {
                    // 上传过程中出现异常，返回错误响应的 JSON 数据
                    string responseJson = "{\"success\": 0, \"message\": \"上传失败: " + ex.Message + "\"}";
                    context.Response.Write(responseJson);
                }
            }
            else
            {
                // 文件为空，返回错误响应的 JSON 数据
                string responseJson = "{\"success\": 0, \"message\": \"未选择图片\"}";
                context.Response.Write(responseJson);
            }
        }
        else
        {
            // 没有文件上传，返回错误响应的 JSON 数据
            string responseJson = "{\"success\": 0, \"message\": \"未选择图片\"}";
            context.Response.Write(responseJson);
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
