<%@ WebHandler Language="C#" Class="FileManager" %>

using System;
using System.Web;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

public class FileManager : IHttpHandler
{
    // 定义允许的文件类型 - 添加了.html
    private static readonly string[] AllowedExtensions = { ".txt", ".pdf", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".mp3", ".wav", ".mp4", ".avi", ".doc", ".docx", ".pptx", ".xlsx", ".html" };
    private static readonly string UploadSave = "webstore";
    LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
    private static string mysnum = "test11";
    private static string UploadFolder = "webstore/"+mysnum;
    
    // 数据库连接字符串 - 从web.config中读取
    private string GetConnectionString()
    {
        return ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
    }
    
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


    // 保存文件信息到数据库 - 确保路径一致性
    private void SaveFileToDatabase(string fileName, string filePath, long fileSize, string folderPath)
    {
        string connectionString = GetConnectionString();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            // 获取文件夹ID - 简化版本，只处理根目录和单层文件夹
            int folderId = 0; // 默认根目录

            if (!string.IsNullOrEmpty(folderPath))
            {
                // 查找对应的文件夹ID
                string getFolderIdQuery = @"SELECT FolderId FROM Folders 
                                      WHERE UserSnum = @UserSnum AND FolderName = @FolderName 
                                      AND (ParentFolderId = 0 OR ParentFolderId IS NULL)";

                using (SqlCommand getFolderIdCommand = new SqlCommand(getFolderIdQuery, connection))
                {
                    getFolderIdCommand.Parameters.AddWithValue("@UserSnum", mysnum);
                    getFolderIdCommand.Parameters.AddWithValue("@FolderName", folderPath);

                    connection.Open();
                    object result = getFolderIdCommand.ExecuteScalar();

                    if (result != null)
                    {
                        folderId = Convert.ToInt32(result);
                    }
                }
            }

            // 构建相对路径 - 确保与删除时使用的路径格式一致
            string relativePath = string.IsNullOrEmpty(folderPath) ? fileName : folderPath + "\\" + fileName;

            System.Diagnostics.Debug.WriteLine("保存文件到数据库 - 相对路径: " + relativePath);

            string query = @"INSERT INTO Files 
                       (FolderId, FileName, FileSize, CreateTime, UpdateTime, RelativePath, UserSnum)
                       VALUES 
                       (@FolderId, @FileName, @FileSize, @CreateTime, @UpdateTime, @RelativePath, @UserSnum)";

            using (SqlCommand command = new SqlCommand(query, connection))
            {
                // 如果folderId为0，插入NULL（根目录）
                
                command.Parameters.AddWithValue("@FolderId", folderId);
                command.Parameters.AddWithValue("@FileName", fileName);
                command.Parameters.AddWithValue("@FileSize", fileSize);
                command.Parameters.AddWithValue("@CreateTime", DateTime.Now);
                command.Parameters.AddWithValue("@UpdateTime", DateTime.Now);
                command.Parameters.AddWithValue("@RelativePath", relativePath);
                command.Parameters.AddWithValue("@UserSnum", mysnum);

                // 如果连接已关闭，重新打开
                if (connection.State != System.Data.ConnectionState.Open)
                {
                    connection.Open();
                }

                command.ExecuteNonQuery();
            }
        }
    }

    // 从数据库删除文件记录 - 修正版本
    private void DeleteFileFromDatabase(string relativePath)
    {
        //相对路径要改为绝对路径
        relativePath = relativePath.Replace("/", "\\");
        //LearnSite.Common.Log.Addlog("路径", relativePath);
        string connectionString = GetConnectionString();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            string query = "DELETE FROM Files WHERE RelativePath = @RelativePath AND UserSnum = @UserSnum";

            using (SqlCommand command = new SqlCommand(query, connection))
            {
                command.Parameters.AddWithValue("@RelativePath", relativePath);
                command.Parameters.AddWithValue("@UserSnum", mysnum);

                connection.Open();
                int rowsAffected = command.ExecuteNonQuery();
                // 可选：记录删除结果用于调试
                if (rowsAffected == 0)
                {
                    System.Diagnostics.Debug.WriteLine("未找到要删除的文件记录: " + relativePath);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("成功删除文件记录: " + relativePath);
                }
            }
        }
    }

    private void DeleteFolderFromDatabase(string folderPath)
    {
        string connectionString = GetConnectionString();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            // 首先获取要删除的文件夹ID
            string getFolderIdQuery = @"SELECT FolderId FROM Folders 
                                  WHERE UserSnum = @UserSnum AND FolderName = @FolderName 
                                  AND (ParentFolderId = 0 OR ParentFolderId IS NULL)";
            int folderId = 0;

            using (SqlCommand getFolderIdCommand = new SqlCommand(getFolderIdQuery, connection))
            {
                getFolderIdCommand.Parameters.AddWithValue("@UserSnum", mysnum);
                getFolderIdCommand.Parameters.AddWithValue("@FolderName", folderPath);
                connection.Open();
                object result = getFolderIdCommand.ExecuteScalar();

                if (result != null)
                {
                    folderId = Convert.ToInt32(result);
                }
                else
                {
                    // 文件夹在数据库中不存在，直接返回
                    return;
                }
            }

            // 删除该文件夹下的所有文件记录
            string deleteFilesQuery = "DELETE FROM Files WHERE FolderId = @FolderId";
            using (SqlCommand deleteFilesCommand = new SqlCommand(deleteFilesQuery, connection))
            {
                deleteFilesCommand.Parameters.AddWithValue("@FolderId", folderId);
                deleteFilesCommand.ExecuteNonQuery();
            }

            // 删除文件夹记录
            string deleteFolderQuery = "DELETE FROM Folders WHERE FolderId = @FolderId";
            using (SqlCommand deleteFolderCommand = new SqlCommand(deleteFolderQuery, connection))
            {
                deleteFolderCommand.Parameters.AddWithValue("@FolderId", folderId);
                deleteFolderCommand.ExecuteNonQuery();
            }
        }
    }

    // 从数据库获取文件列表
    private List<Dictionary<string, object>> GetFilesFromDatabase(string folderPath)
    {
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();

        try
        {
            string connectionString = GetConnectionString();

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string query;
                SqlCommand command;

                if (string.IsNullOrEmpty(folderPath))
                {
                    // 根目录下的文件
                    query = @"SELECT FileName, RelativePath, FileSize, CreateTime 
                     FROM Files 
                     WHERE UserSnum = @UserSnum AND (FolderId = 0 OR FolderId IS NULL)
                     ORDER BY CreateTime DESC";
                    command = new SqlCommand(query, connection);
                }
                else
                {
                    // 特定文件夹下的文件
                    query = @"SELECT f.FileName, f.RelativePath, f.FileSize, f.CreateTime 
                     FROM Files f
                     INNER JOIN Folders fd ON f.FolderId = fd.FolderId
                     WHERE f.UserSnum = @UserSnum AND fd.FolderName = @FolderName
                     ORDER BY f.CreateTime DESC";
                    command = new SqlCommand(query, connection);
                    command.Parameters.AddWithValue("@FolderName", folderPath);
                }

                // 添加用户参数
                command.Parameters.AddWithValue("@UserSnum", mysnum);

                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Dictionary<string, object> fileData = new Dictionary<string, object>();
                        fileData["name"] = reader["FileName"].ToString();
                        fileData["path"] = reader["RelativePath"].ToString();
                        fileData["size"] = Convert.ToInt64(reader["FileSize"]);
                        fileData["date"] = Convert.ToDateTime(reader["CreateTime"]).ToLongDateString();
                        files.Add(fileData);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("从数据库获取文件列表失败: " + ex.Message);
        }

        return files;
    }

    // 从文件系统获取文件列表
    private List<Dictionary<string, object>> GetFilesFromFileSystem(string folderPath)
    {
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        
        try
        {
            string uploadFolder = GetUploadFolder(HttpContext.Current);
            
            // 组合完整路径
            string fullPath = string.IsNullOrEmpty(folderPath) ? uploadFolder : Path.Combine(uploadFolder, folderPath);

            if (!Directory.Exists(fullPath))
                return files;

            foreach (string file in Directory.GetFiles(fullPath))
            {
                string fileName = Path.GetFileName(file);
                FileInfo fileInfo = new FileInfo(file);
                
                Dictionary<string, object> fileData = new Dictionary<string, object>();
                fileData["name"] = fileName;
                
                // 构建相对路径
                fileData["path"] = string.IsNullOrEmpty(folderPath) ? fileName : folderPath + "\\" + fileName;
                fileData["size"] = fileInfo.Length;
                fileData["date"] = fileInfo.CreationTime.ToLongDateString();
                
                files.Add(fileData);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("从文件系统读取文件错误: " + ex.Message);
        }
        
        return files;
    }

    // 将文件系统中的文件同步到数据库 - 修正版本
    private void SyncFilesToDatabase(List<Dictionary<string, object>> files, string folderPath)
    {
        try
        {
            foreach (Dictionary<string, object> fileData in files)
            {
                string fileName = fileData["name"].ToString();
                string relativePath = fileData["path"].ToString();
                long fileSize = Convert.ToInt64(fileData["size"]);

                // 检查文件是否已在数据库中
                if (!FileExistsInDatabase(relativePath))
                {
                    // 保存到数据库 - 使用修正后的方法
                    SaveFileToDatabase(fileName, relativePath, fileSize, folderPath);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("同步文件到数据库错误: " + ex.Message);
        }
    }

    // 检查文件是否已在数据库中
    private bool FileExistsInDatabase(string relativePath)
    {
        string connectionString = GetConnectionString();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            string query = "SELECT COUNT(1) FROM Files WHERE RelativePath = @RelativePath";
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                command.Parameters.AddWithValue("@RelativePath", relativePath);
                connection.Open();
                int count = Convert.ToInt32(command.ExecuteScalar());
                return count > 0;
            }
        }
    }

    private void GetFolders(HttpContext context)
    {
        try
        {
            // 从数据库获取文件夹结构 - 只获取根目录下的文件夹
            List<Dictionary<string, object>> folderStructure = GetFolderStructureFromDatabase();
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

    // 从数据库获取文件夹结构 - 只获取根目录下的文件夹
    private List<Dictionary<string, object>> GetFolderStructureFromDatabase()
    {
        List<Dictionary<string, object>> structure = new List<Dictionary<string, object>>();

        try
        {
            string connectionString = GetConnectionString();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                // 只查询根目录下的文件夹（ParentFolderId为0或NULL）
                string query = @"SELECT FolderId, FolderName, Path 
                         FROM Folders 
                         WHERE UserSnum = @UserSnum AND (ParentFolderId = 0 OR ParentFolderId IS NULL)
                         ORDER BY FolderName";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@UserSnum", mysnum);

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Dictionary<string, object> folderInfo = new Dictionary<string, object>();
                            string folderName = reader["FolderName"].ToString();
                            string folderPath = reader["FolderName"].ToString(); // 路径就是文件夹名

                            folderInfo["name"] = folderName;
                            folderInfo["path"] = folderPath;
                            folderInfo["children"] = new List<Dictionary<string, object>>(); // 空子文件夹，不递归

                            structure.Add(folderInfo);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("从数据库获取文件夹结构失败: " + ex.Message);
        }

        return structure;
    }

    private void GetFiles(HttpContext context)
    {
        try
        {
            string path = context.Request.QueryString["path"] ?? "";
            // 对路径进行 URL 解码
            path = HttpUtility.UrlDecode(path, Encoding.UTF8);

            // 首先尝试从数据库获取文件列表
            List<Dictionary<string, object>> files = GetFilesFromDatabase(path);
            /*
            // 如果数据库中没有文件，尝试从文件系统获取并同步到数据库
            if (files.Count == 0)
            {
                files = GetFilesFromFileSystem(path);

                // 如果文件系统中有文件，将它们同步到数据库
                if (files.Count > 0)
                {
                    SyncFilesToDatabase(files, path);
                }
            }
            */
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

            // 检查总文件大小（限制为50MB）
            long totalSize = 0;
            long maxTotalSize = 50 * 1024 * 1024; // 50MB

            for (int i = 0; i < context.Request.Files.Count; i++)
            {
                HttpPostedFile file = context.Request.Files[i];
                if (file != null && file.ContentLength > 0)
                {
                    totalSize += file.ContentLength;
                }
            }

            // 检查总大小是否超过限制
            if (totalSize > maxTotalSize)
            {
                WriteResponse(context, false, "文件总大小超过限制（最大50MB）");
                return;
            }

            for (int i = 0; i < context.Request.Files.Count; i++)
            {
                HttpPostedFile file = context.Request.Files[i];

                // 检查文件是否有效
                if (file != null && file.ContentLength > 0 && !string.IsNullOrEmpty(file.FileName))
                {
                    string fileName = Path.GetFileName(file.FileName);

                    // 检查单个文件大小（限制为20MB）
                    long maxFileSize = 20 * 1024 * 1024; // 20MB
                    if (file.ContentLength > maxFileSize)
                    {
                        WriteResponse(context, false, "文件 " + fileName + " 大小超过限制（最大20MB）");
                        return;
                    }

                    // 检查文件类型
                    if (IsAllowedFile(fileName))
                    {
                        string safeFileName = GetSafeFileName(targetPath, fileName);

                        // 修复：使用 Path.Combine 的两个参数版本
                        string filePath = Path.Combine(targetPath, safeFileName);

                        try
                        {
                            long finalFileSize = file.ContentLength;
                            
                            file.SaveAs(filePath);

                            // 保存文件信息到数据库
                            SaveFileToDatabase(safeFileName, filePath, finalFileSize, path);

                            uploadedCount++;
                            uploadedFiles.Add(safeFileName);
                        }
                        catch (HttpException httpEx)
                        {
                            // 捕获文件大小超过服务器限制的异常
                            if (httpEx.ErrorCode == -2147467259) // 文件大小超过限制的错误代码
                            {
                                WriteResponse(context, false, "文件大小超过服务器限制，请在web.config中调整maxRequestLength设置");
                                return;
                            }
                            WriteResponse(context, false, "保存文件 " + fileName + " 时出错: " + httpEx.Message);
                            return;
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
        catch (HttpException httpEx)
        {
            // 捕获上传大小超过服务器配置的异常
            if (httpEx.ErrorCode == -2147467259)
            {
                WriteResponse(context, false, "文件大小超过服务器限制，请联系管理员调整服务器配置");
            }
            else
            {
                WriteResponse(context, false, "上传过程中发生错误: " + httpEx.Message);
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

            // 对名称进行 URL 解码
            name = HttpUtility.UrlDecode(name, Encoding.UTF8);

            // 强制只能在根目录创建，忽略传入的path参数
            path = "";

            string uploadFolder = GetUploadFolder(context);

            if (string.IsNullOrEmpty(name) || name.Trim().Length == 0)
            {
                WriteResponse(context, false, "文件夹名称不能为空");
                return;
            }

            // 安全检查 - 防止创建多级目录
            if (name.Contains("..") || name.Contains("/") || name.Contains("\\") || name.Contains(":") ||
                name.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
            {
                WriteResponse(context, false, "文件夹名称包含非法字符");
                return;
            }

            // 检查文件夹名称长度
            if (name.Length > 50)
            {
                WriteResponse(context, false, "文件夹名称不能超过50个字符");
                return;
            }

            // 组合完整路径 - 直接在根目录下创建
            string newFolderPath = Path.Combine(uploadFolder, name);

            if (Directory.Exists(newFolderPath))
            {
                WriteResponse(context, false, "文件夹已存在");
                return;
            }

            // 创建物理文件夹
            Directory.CreateDirectory(newFolderPath);

            // 创建数据库记录 - 强制在根目录下创建
            CreateFolderInRoot(name);

            WriteResponse(context, true, "文件夹创建成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "创建文件夹失败: " + ex.Message);
        }
    }

    // 在根目录下创建文件夹
    private void CreateFolderInRoot(string folderName)
    {
        string connectionString = GetConnectionString();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            // 检查是否已存在同名文件夹
            string checkQuery = @"SELECT COUNT(1) FROM Folders 
                            WHERE UserSnum = @UserSnum AND FolderName = @FolderName 
                            AND (ParentFolderId = 0 OR ParentFolderId IS NULL)";

            using (SqlCommand checkCommand = new SqlCommand(checkQuery, connection))
            {
                checkCommand.Parameters.AddWithValue("@UserSnum", mysnum);
                checkCommand.Parameters.AddWithValue("@FolderName", folderName);

                connection.Open();
                int count = Convert.ToInt32(checkCommand.ExecuteScalar());

                if (count > 0)
                {
                    throw new Exception("文件夹已存在");
                }
            }

            // 插入新文件夹记录
            string insertQuery = @"INSERT INTO Folders 
                             (ParentFolderId, FolderName, Path, UserSnum, CreateTime, UpdateTime)
                             VALUES 
                             (NULL, @FolderName, @FolderName, @UserSnum, @CreateTime, @UpdateTime)";

            using (SqlCommand command = new SqlCommand(insertQuery, connection))
            {
                command.Parameters.AddWithValue("@FolderName", folderName);
                command.Parameters.AddWithValue("@UserSnum", mysnum);
                command.Parameters.AddWithValue("@CreateTime", DateTime.Now);
                command.Parameters.AddWithValue("@UpdateTime", DateTime.Now);

                command.ExecuteNonQuery();
            }
        }
    }

    private void RenameFolder(HttpContext context)
    {
        try
        {
            string oldPath = context.Request.Form["oldPath"] ?? "";
            string newName = context.Request.Form["newName"] ?? "";

            // 对名称进行 URL 解码
            oldPath = HttpUtility.UrlDecode(oldPath, Encoding.UTF8);
            newName = HttpUtility.UrlDecode(newName, Encoding.UTF8);

            string uploadFolder = GetUploadFolder(context);

            // 组合完整路径
            string oldFullPath = Path.Combine(uploadFolder, oldPath);
            string newFullPath = Path.Combine(uploadFolder, newName);

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

            // 重命名物理文件夹
            Directory.Move(oldFullPath, newFullPath);

            // 更新数据库中的文件夹信息
            RenameFolderInDatabase(oldPath, newName);

            WriteResponse(context, true, "文件夹重命名成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "重命名文件夹失败: " + ex.Message);
        }
    }

    // 重命名文件夹在数据库中
    private void RenameFolderInDatabase(string oldName, string newName)
    {
        string connectionString = GetConnectionString();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            // 更新文件夹名称
            string updateQuery = @"UPDATE Folders 
                             SET FolderName = @NewName, Path = @NewName, UpdateTime = @UpdateTime
                             WHERE UserSnum = @UserSnum AND FolderName = @OldName 
                             AND (ParentFolderId = 0 OR ParentFolderId IS NULL)";

            using (SqlCommand updateCommand = new SqlCommand(updateQuery, connection))
            {
                updateCommand.Parameters.AddWithValue("@NewName", newName);
                updateCommand.Parameters.AddWithValue("@UpdateTime", DateTime.Now);
                updateCommand.Parameters.AddWithValue("@UserSnum", mysnum);
                updateCommand.Parameters.AddWithValue("@OldName", oldName);

                connection.Open();
                int rowsAffected = updateCommand.ExecuteNonQuery();

                if (rowsAffected == 0)
                {
                    throw new Exception("文件夹在数据库中不存在");
                }
            }
        }
    }

    private void DeleteFolder(HttpContext context)
    {
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

            // 检查文件夹是否为空
            if (Directory.GetFiles(folderPath).Length > 0 || Directory.GetDirectories(folderPath).Length > 0)
            {
                WriteResponse(context, false, "文件夹不为空，无法删除");
                return;
            }

            // 从数据库删除文件夹记录
            DeleteFolderFromDatabase(path);
            
            // 删除物理文件夹
            Directory.Delete(folderPath);
            
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
            
            // 设置响应头
            context.Response.ContentType = GetContentType(filePath);
            context.Response.AddHeader("Content-Disposition", 
                "attachment; filename=" + HttpUtility.UrlEncode(fileName, Encoding.UTF8));
            context.Response.AddHeader("Content-Length", new FileInfo(filePath).Length.ToString());
            
            // 传输文件
            context.Response.TransmitFile(filePath);
            context.Response.Flush();
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
            
            // 从数据库删除文件记录 - 使用正确的相对路径
            // 注意：这里应该使用传入的path参数，这是相对于用户文件夹的路径
            DeleteFileFromDatabase(path);
            // 删除物理文件
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            WriteResponse(context, true, "文件删除成功");
        }
        catch (Exception ex)
        {
            WriteResponse(context, false, "文件删除失败: " + ex.Message);
        }
    }

    // 根据文件扩展名获取 Content-Type
    private string GetContentType(string filePath)
    {
        string extension = Path.GetExtension(filePath).ToLower();
        switch (extension)
        {
            case ".txt": return "text/plain";
            case ".pdf": return "application/pdf";
            case ".png": return "image/png";
            case ".jpg":
            case ".jpeg": return "image/jpeg";
            case ".gif": return "image/gif";
            case ".webp": return "image/webp";
            case ".mp3": return "audio/mpeg";
            case ".wav": return "audio/wav";
            case ".mp4": return "video/mp4";
            case ".avi": return "video/x-msvideo";
            case ".doc": return "application/msword";
            case ".docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case ".pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case ".xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case ".html":
            case ".htm": return "text/html";
            default: return "application/octet-stream";
        }
    }

    // 其他辅助方法保持不变...
    private void EnsureUploadFolderExists(string uploadFolder)
    {
        if (!Directory.Exists(uploadFolder))
        {
            Directory.CreateDirectory(uploadFolder);
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