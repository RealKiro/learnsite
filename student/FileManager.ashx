<%@ WebHandler Language="C#" Class="FileManager" %>

using System;
using System.Web;
using System.IO;
using System.Collections.Generic;
using System.Text;

public class FileManager : IHttpHandler
{
    // 定义允许的文件类型 - 添加了.html
    private static readonly string[] AllowedExtensions = { ".txt", ".pdf", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".mp3", ".wav", ".mp4", ".avi", ".doc", ".docx", ".pptx", ".xlsx", ".html" };
    private static readonly string UploadSave = "webstore";
    LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
    private static string mysnum = "test11";
    private static string UploadFolder = "webstore/"+mysnum;
    
    public void ProcessRequest(HttpContext context)
    {
        // 设置请求和响应编码
        context.Request.ContentEncoding = Encoding.UTF8;
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.Charset = "utf-8";
        
        // 允许跨域
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        
        string action = context.Request.QueryString["action"];

        if (cook.IsExist())
        {
            mysnum = cook.Snum;
            UploadFolder = "webstore/" + mysnum;
        }
        
        try
        {
            switch (action)
            {
                case "folders":
                    GetFolders(context);
                    break;
                case "files":
                    GetFiles(context);
                    break;
                case "upload":
                    UploadFiles(context);
                    break;
                case "createfolder":
                    CreateFolder(context);
                    break;
                case "renamefolder":
                    RenameFolder(context);
                    break;
                case "deletefolder":
                    DeleteFolder(context);
                    break;
                case "download":
                    DownloadFile(context);
                    break;
                case "delete":
                    DeleteFile(context);
                    break;
                default:
                    WriteResponse(context, false, "未知操作");
                    break;
            }
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "服务器错误: " + ex.Message);
        }
    }

    // 辅助方法
    private string GetUploadSave(HttpContext context)
    {
        return context.Server.MapPath("~/" + UploadSave);
    }
    // 辅助方法
    private string GetUploadFolder(HttpContext context)
    {
        return context.Server.MapPath("~/" + UploadFolder);
    }
    // 自定义的路径组合方法，用于替代 Path.Combine 的多参数版本
    private string CombinePaths(params string[] paths)
    {
        if (paths == null || paths.Length == 0)
            return string.Empty;
            
        string result = paths[0];
        for (int i = 1; i < paths.Length; i++)
        {
            result = Path.Combine(result, paths[i]);
        }
        return result;
    }

    private void GetFolders(HttpContext context)
    {
        try
        {
            string uploadsave = GetUploadSave(context);
            EnsureUploadFolderExists(uploadsave);
            
            string uploadFolder = GetUploadFolder(context);
            EnsureUploadFolderExists(uploadFolder);
            
            List<Dictionary<string, object>> folderStructure = GetFolderStructure(uploadFolder, "");
            string json = SerializeToJson(folderStructure);
            
            // 确保输出 UTF-8
            byte[] jsonBytes = Encoding.UTF8.GetBytes(json);
            context.Response.BinaryWrite(jsonBytes);
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "获取文件夹结构失败: " + ex.Message);
        }
    }

    private void GetFiles(HttpContext context)
    {
        try
        {
            string path = context.Request.QueryString["path"] ?? "";
            // 对路径进行 URL 解码
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);
            
            string uploadFolder = GetUploadFolder(context);
            
            // 修复：使用自定义的路径组合方法
            string fullPath = string.IsNullOrEmpty(path) ? uploadFolder : Path.Combine(uploadFolder, path);

            if (!Directory.Exists(fullPath))
            {
                WriteResponse(context, false, "文件夹不存在: " + fullPath);
                return;
            }

            List<Dictionary<string, object>> files = GetFilesInFolder(fullPath, path);
            string json = SerializeToJson(files);
            byte[] jsonBytes = Encoding.UTF8.GetBytes(json);
            context.Response.BinaryWrite(jsonBytes);
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "获取文件列表失败: " + ex.Message);
        }
    }

    private void UploadFiles(HttpContext context)
    {
        try
        {
            // 检查是否有文件
            if (context.Request.Files.Count == 0)
            {
                WriteResponse(context, false, "没有接收到任何文件");
                return;
            }

            string path = context.Request.Form["path"] ?? "";
            // 对路径进行 URL 解码
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);
            
            string uploadFolder = GetUploadFolder(context);
            
            // 确保上传目录存在
            if (!Directory.Exists(uploadFolder))
            {
                Directory.CreateDirectory(uploadFolder);
            }

            // 修复：使用自定义的路径组合方法
            string targetPath = string.IsNullOrEmpty(path) ? uploadFolder : Path.Combine(uploadFolder, path);
            
            // 确保目标目录存在
            if (!Directory.Exists(targetPath))
            {
                Directory.CreateDirectory(targetPath);
            }

            int uploadedCount = 0;
            List<string> uploadedFiles = new List<string>();
            
            for (int i = 0; i < context.Request.Files.Count; i++)
            {
                HttpPostedFile file = context.Request.Files[i];
                
                // 检查文件是否有效
                if (file != null && file.ContentLength > 0 && !string.IsNullOrEmpty(file.FileName))
                {
                    string fileName = Path.GetFileName(file.FileName);
                    
                    // 检查文件类型
                    if (IsAllowedFile(fileName))
                    {
                        string safeFileName = GetSafeFileName(targetPath, fileName);
                        
                        // 修复：使用 Path.Combine 的两个参数版本
                        string filePath = Path.Combine(targetPath, safeFileName);
                        
                        try
                        {
                            // 保存文件
                            file.SaveAs(filePath);
                            uploadedCount++;
                            uploadedFiles.Add(safeFileName);
                        }
                        catch (Exception ex)
                        {
                            WriteResponse(context, false, "保存文件 " + fileName + " 时出错: " + ex.Message);
                            return;
                        }
                    }
                    else
                    {
                        WriteResponse(context, false, "文件类型不被允许: " + fileName);
                        return;
                    }
                }
            }

            if (uploadedCount > 0)
            {
                WriteResponse(context, true, "成功上传 " + uploadedCount + " 个文件: " + string.Join(", ", uploadedFiles.ToArray()));
            }
            else
            {
                WriteResponse(context, false, "没有文件被上传");
            }
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "上传过程中发生错误: " + ex.Message);
        }
    }

    private void CreateFolder(HttpContext context)
    {
        try
        {
            string name = context.Request.Form["name"];
            string path = context.Request.Form["path"] ?? "";

            // 对路径和名称进行 URL 解码
            name = HttpUtility.UrlDecode(name, Encoding.UTF8);
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);

            string uploadFolder = GetUploadFolder(context);

            // 修复：分步组合路径
            string basePath = string.IsNullOrEmpty(path) ? uploadFolder : Path.Combine(uploadFolder, path);
            string newFolderPath = Path.Combine(basePath, name);

            if (string.IsNullOrEmpty(name) || name.Trim().Length == 0)
            {
                WriteResponse(context, false, "文件夹名称不能为空");
                return;
            }

            // 安全检查 - 加强验证，防止创建多级目录
            if (name.Contains("..") || name.Contains("/") || name.Contains("\\") || name.Contains(":") ||
                name.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
            {
                WriteResponse(context, false, "文件夹名称包含非法字符，不能创建多级目录");
                return;
            }

            // 检查文件夹名称长度
            if (name.Length > 50)
            {
                WriteResponse(context, false, "文件夹名称不能超过50个字符");
                return;
            }

            if (Directory.Exists(newFolderPath))
            {
                WriteResponse(context, false, "文件夹已存在");
                return;
            }

            Directory.CreateDirectory(newFolderPath);
            WriteResponse(context, true, "文件夹创建成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "创建文件夹失败: " + ex.Message);
        }
    }

    private void RenameFolder(HttpContext context)
    {
        try
        {
            string oldPath = context.Request.Form["oldPath"] ?? "";
            string newName = context.Request.Form["newName"] ?? "";

            // 对路径和名称进行 URL 解码
            oldPath = HttpUtility.UrlDecode(oldPath, Encoding.UTF8);
            newName = HttpUtility.UrlDecode(newName, Encoding.UTF8);

            string uploadFolder = GetUploadFolder(context);

            // 组合完整路径
            string oldFullPath = Path.Combine(uploadFolder, oldPath);
            string newFullPath = Path.Combine(Path.GetDirectoryName(oldFullPath), newName);

            if (string.IsNullOrEmpty(newName) || newName.Trim().Length == 0)
            {
                WriteResponse(context, false, "新文件夹名称不能为空");
                return;
            }

            // 安全检查
            if (newName.Contains("..") || newName.Contains("/") || newName.Contains("\\") || newName.Contains(":") ||
                newName.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
            {
                WriteResponse(context, false, "新文件夹名称包含非法字符");
                return;
            }

            // 检查文件夹名称长度
            if (newName.Length > 50)
            {
                WriteResponse(context, false, "文件夹名称不能超过50个字符");
                return;
            }

            if (!Directory.Exists(oldFullPath))
            {
                WriteResponse(context, false, "原文件夹不存在");
                return;
            }

            if (Directory.Exists(newFullPath))
            {
                WriteResponse(context, false, "目标文件夹已存在");
                return;
            }

            Directory.Move(oldFullPath, newFullPath);
            WriteResponse(context, true, "文件夹重命名成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "重命名文件夹失败: " + ex.Message);
        }
    }

    private void DeleteFolder(HttpContext context)
    {
        WriteResponse(context, false, "测试");
        try
        {
            string path = context.Request.QueryString["path"] ?? "";
            // 对路径进行 URL 解码
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);

            string uploadFolder = GetUploadFolder(context);

            // 修复：使用 Path.Combine 的两个参数版本
            string folderPath = Path.Combine(uploadFolder, path);

            // 安全检查
            if (!folderPath.StartsWith(uploadFolder))
            {
                WriteResponse(context, false, "非法路径");
                return;
            }

            if (!Directory.Exists(folderPath))
            {
                WriteResponse(context, false, "文件夹不存在");
                return;
            }

            // 删除文件夹及其所有内容
            Directory.Delete(folderPath, true);
            WriteResponse(context, true, "文件夹删除成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "文件夹删除失败: " + ex.Message);
        }
    }

    private void DownloadFile(HttpContext context)
    {
        try
        {
            string path = context.Request.QueryString["path"] ?? "";
            // 对路径进行 URL 解码
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);
            
            string uploadFolder = GetUploadFolder(context);
            
            // 修复：使用 Path.Combine 的两个参数版本
            string filePath = Path.Combine(uploadFolder, path);

            // 安全检查
            if (!filePath.StartsWith(uploadFolder))
            {
                WriteResponse(context, false, "非法路径");
                return;
            }

            if (!File.Exists(filePath))
            {
                WriteResponse(context, false, "文件不存在: " + filePath);
                return;
            }

            string fileName = Path.GetFileName(filePath);
            context.Response.ContentType = "application/octet-stream";
            context.Response.AddHeader("Content-Disposition", 
                "attachment; filename=" + HttpUtility.UrlEncode(fileName, Encoding.UTF8));
            context.Response.TransmitFile(filePath);
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "文件下载失败: " + ex.Message);
        }
    }

    private void DeleteFile(HttpContext context)
    {
        try
        {
            string path = context.Request.QueryString["path"] ?? "";
            // 对路径进行 URL 解码
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);
            
            string uploadFolder = GetUploadFolder(context);
            
            // 修复：使用 Path.Combine 的两个参数版本
            string filePath = Path.Combine(uploadFolder, path);

            // 安全检查
            if (!filePath.StartsWith(uploadFolder))
            {
                WriteResponse(context, false, "非法路径");
                return;
            }

            if (!File.Exists(filePath))
            {
                WriteResponse(context, false, "文件不存在");
                return;
            }

            File.Delete(filePath);
            WriteResponse(context, true, "文件删除成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "文件删除失败: " + ex.Message);
        }
    }


    private void EnsureUploadFolderExists(string uploadFolder)
    {
        if (!Directory.Exists(uploadFolder))
        {
            Directory.CreateDirectory(uploadFolder);
            /*
            // 创建示例文件夹结构（使用中文）
            string[] sampleFolders = {
                "文字资料",
                "图片素材",
                "音频视频",
                "在线文档"
            };
            
            foreach (string folder in sampleFolders)
            {
                // 修复：只创建一级目录
                string fullPath = Path.Combine(uploadFolder, folder);
                if (!Directory.Exists(fullPath))
                {
                    Directory.CreateDirectory(fullPath);
                }
            }
             */
        }
    }

    private List<Dictionary<string, object>> GetFolderStructure(string basePath, string currentPath)
    {
        List<Dictionary<string, object>> structure = new List<Dictionary<string, object>>();
        
        // 修复：使用 Path.Combine 的两个参数版本
        string fullPath = string.IsNullOrEmpty(currentPath) ? basePath : Path.Combine(basePath, currentPath);

        if (!Directory.Exists(fullPath))
            return structure;

        try
        {
            foreach (string dir in Directory.GetDirectories(fullPath))
            {
                string dirName = Path.GetFileName(dir);
                
                // 修复：手动组合相对路径
                string relPath = string.IsNullOrEmpty(currentPath) ? dirName : currentPath + "\\" + dirName;
                
                Dictionary<string, object> folderInfo = new Dictionary<string, object>();
                folderInfo["name"] = dirName;
                folderInfo["path"] = relPath;
                folderInfo["children"] = GetFolderStructure(basePath, relPath);
                
                structure.Add(folderInfo);
            }
        }
        catch (Exception ex)
        {
            // 记录错误但不中断流程
            System.Diagnostics.Debug.WriteLine("读取目录错误: " + ex.Message);
        }

        return structure;
    }

    private List<Dictionary<string, object>> GetFilesInFolder(string folderPath, string relativePath)
    {
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        
        try
        {
            foreach (string file in Directory.GetFiles(folderPath))
            {
                string fileName = Path.GetFileName(file);
                FileInfo fileInfo = new FileInfo(file);
                
                Dictionary<string, object> fileData = new Dictionary<string, object>();
                fileData["name"] = fileName;
                
                // 修复：手动组合文件路径
                fileData["path"] = string.IsNullOrEmpty(relativePath) ? fileName : relativePath + "\\" + fileName;
                fileData["size"] = fileInfo.Length;
                fileData["date"] = fileInfo.CreationTime.ToLongDateString();
                
                files.Add(fileData);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("读取文件错误: " + ex.Message);
        }
        
        return files;
    }

    private bool IsAllowedFile(string fileName)
    {
        if (string.IsNullOrEmpty(fileName)) return false;
        
        string ext = Path.GetExtension(fileName).ToLower();
        foreach (string allowedExt in AllowedExtensions)
        {
            if (allowedExt.Equals(ext, StringComparison.OrdinalIgnoreCase))
                return true;
        }
        return false;
    }

    private string GetSafeFileName(string folder, string fileName)
    {
        string name = Path.GetFileNameWithoutExtension(fileName);
        string ext = Path.GetExtension(fileName);
        string newFileName = fileName;
        int counter = 1;
        
        // 修复：使用 Path.Combine 的两个参数版本
        while (File.Exists(Path.Combine(folder, newFileName)))
        {
            newFileName = string.Format("{0}({1}){2}", name, counter, ext);
            counter++;
        }
        return newFileName;
    }

    private void WriteResponse(HttpContext context, bool success, string message)
    {
        string json = "{\"success\":" + success.ToString().ToLower() + ",\"message\":\"" + EscapeJsonString(message) + "\"}";
        byte[] jsonBytes = Encoding.UTF8.GetBytes(json);
        context.Response.BinaryWrite(jsonBytes);
    }

    // 手动JSON序列化方法
    private string SerializeToJson(List<Dictionary<string, object>> data)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("[");

        for (int i = 0; i < data.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append(SerializeDictionaryToJson(data[i]));
        }

        sb.Append("]");
        return sb.ToString();
    }

    private string SerializeDictionaryToJson(Dictionary<string, object> dict)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("{");

        bool first = true;
        foreach (KeyValuePair<string, object> kvp in dict)
        {
            if (!first) sb.Append(",");
            first = false;

            sb.Append("\"");
            sb.Append(kvp.Key);
            sb.Append("\":");

            if (kvp.Value is string)
            {
                sb.Append("\"");
                sb.Append(EscapeJsonString((string)kvp.Value));
                sb.Append("\"");
            }
            else if (kvp.Value is bool)
            {
                sb.Append(kvp.Value.ToString().ToLower());
            }
            else if (kvp.Value is List<Dictionary<string, object>>)
            {
                sb.Append(SerializeToJson((List<Dictionary<string, object>>)kvp.Value));
            }
            else
            {
                sb.Append(kvp.Value);
            }
        }

        sb.Append("}");
        return sb.ToString();
    }

    private string EscapeJsonString(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        foreach (char c in str)
        {
            switch (c)
            {
                case '\"': sb.Append("\\\""); break;
                case '\\': sb.Append("\\\\"); break;
                case '\b': sb.Append("\\b"); break;
                case '\f': sb.Append("\\f"); break;
                case '\n': sb.Append("\\n"); break;
                case '\r': sb.Append("\\r"); break;
                case '\t': sb.Append("\\t"); break;
                default:
                    int i = (int)c;
                    if (i < 32 || i > 127)
                    {
                        sb.AppendFormat("\\u{0:X04}", i);
                    }
                    else
                    {
                        sb.Append(c);
                    }
                    break;
            }
        }
        return sb.ToString();
    }

    public bool IsReusable
    {
        get { return false; }
    }
}