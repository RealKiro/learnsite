#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\getfiles.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "806E05E07B9C476153C15422769D9FFB"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\getfiles.ashx"


using System;
using System.Web;
using System.Web.SessionState;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

public class getfiles : IHttpHandler, IRequiresSessionState {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;
        
        try {
            string isgroup = context.Request.QueryString["isgroup"] ?? "False";
            string iscommon = context.Request.QueryString["iscommon"] ?? "False";
            
            // 从Cookie获取当前用户ID
            string sid = "";
            string snum = "";
            
            try {
                HttpCookie stuCookie = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
                if (stuCookie != null && !string.IsNullOrEmpty(stuCookie.Value))
                {
                    string cookieVal = stuCookie.Value;
                    if (cookieVal.Contains("%")) {
                        try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); } catch { }
                    }
                    
                    Type cookieType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                    if (cookieType != null)
                    {
                        object cookieModel = Activator.CreateInstance(cookieType);
                        System.Reflection.MethodInfo toModelMethod = cookieType.GetMethod("ToModel", 
                            System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | 
                            System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                        
                        if (toModelMethod != null)
                        {
                            toModelMethod.Invoke(cookieModel, new object[] { cookieVal });
                            
                            // 获取Sid
                            System.Reflection.PropertyInfo sidProp = cookieType.GetProperty("Sid");
                            if (sidProp != null)
                            {
                                object sidValue = sidProp.GetValue(cookieModel, null);
                                if (sidValue != null) sid = sidValue.ToString();
                            }
                            
                            // 获取Snum作为备用
                            System.Reflection.PropertyInfo snumProp = cookieType.GetProperty("Snum");
                            if (snumProp != null)
                            {
                                object snumValue = snumProp.GetValue(cookieModel, null);
                                if (snumValue != null) snum = snumValue.ToString();
                            }
                        }
                    }
                }
            } catch { }
            
            if (string.IsNullOrEmpty(sid) && string.IsNullOrEmpty(snum)) {
                context.Response.Write("{\"success\":false,\"message\":\"未登录\",\"files\":[],\"debug\":{\"sid\":\"" + sid + "\",\"snum\":\"" + snum + "\"}}");
                return;
            }
            
            // 构建文件路径
            string basePath = "";
            string altBasePath = ""; // 备用路径
            
            if (iscommon == "True") {
                basePath = context.Server.MapPath("~/upload/common/");
            } else if (isgroup == "True") {
                // 获取学生的小组ID
                string gid = GetStudentGroupId(sid, snum);
                if (string.IsNullOrEmpty(gid)) {
                    context.Response.Write("{\"success\":true,\"message\":\"未加入小组\",\"files\":[],\"debug\":{\"sid\":\"" + sid + "\",\"snum\":\"" + snum + "\",\"gid\":\"" + gid + "\"}}");
                    return;
                }
                basePath = context.Server.MapPath("~/upload/group" + gid + "/");
            } else {
                // 优先使用Sid，如果目录不存在或为空则尝试Snum
                basePath = context.Server.MapPath("~/upload/stu" + sid + "/");
                if (!string.IsNullOrEmpty(snum)) {
                    altBasePath = context.Server.MapPath("~/upload/stu" + snum + "/");
                }
            }
            
            // 智能选择路径：如果主路径为空但备用路径有文件，使用备用路径
            bool useAltPath = false;
            int basePathFileCount = 0;
            int altPathFileCount = 0;
            string allUploadDirs = "";
            
            // 列出upload目录下所有子目录（用于调试）
            try {
                string uploadRoot = context.Server.MapPath("~/upload/");
                if (System.IO.Directory.Exists(uploadRoot)) {
                    string[] dirs = System.IO.Directory.GetDirectories(uploadRoot);
                    StringBuilder dirListBuilder = new StringBuilder();
                    for (int i = 0; i < dirs.Length; i++) {
                        if (i > 0) dirListBuilder.Append(", ");
                        string dirName = System.IO.Path.GetFileName(dirs[i]);
                        int fileCount = new System.IO.DirectoryInfo(dirs[i]).GetFiles().Length;
                        dirListBuilder.Append(dirName);
                        dirListBuilder.Append("(");
                        dirListBuilder.Append(fileCount);
                        dirListBuilder.Append(")");
                    }
                    allUploadDirs = dirListBuilder.ToString();
                }
            } catch (Exception ex) {
                allUploadDirs = "Error: " + ex.Message;
            }
            
            if (!string.IsNullOrEmpty(altBasePath)) {
                // 检查主路径文件数
                if (System.IO.Directory.Exists(basePath)) {
                    basePathFileCount = new System.IO.DirectoryInfo(basePath).GetFiles().Length;
                }
                
                // 检查备用路径文件数
                if (System.IO.Directory.Exists(altBasePath)) {
                    altPathFileCount = new System.IO.DirectoryInfo(altBasePath).GetFiles().Length;
                }
                
                // 如果主路径为空但备用路径有文件，使用备用路径
                if (basePathFileCount == 0 && altPathFileCount > 0) {
                    basePath = altBasePath;
                    useAltPath = true;
                }
            }
            
            // 添加调试信息
            string debugInfo = "\"debug\":{\"sid\":\"" + sid + "\",\"snum\":\"" + snum + "\",\"basePath\":\"" + JsonEncode(basePath) + "\",\"altBasePath\":\"" + JsonEncode(altBasePath) + "\",\"useAltPath\":\"" + useAltPath + "\",\"basePathFileCount\":\"" + basePathFileCount + "\",\"altPathFileCount\":\"" + altPathFileCount + "\",\"allUploadDirs\":\"" + JsonEncode(allUploadDirs) + "\",\"exists\":\"" + System.IO.Directory.Exists(basePath) + "\"}";
            
            // 检查目录是否存在，如果不存在则创建
            if (!System.IO.Directory.Exists(basePath)) {
                try {
                    System.IO.Directory.CreateDirectory(basePath);
                } catch (Exception ex) {
                    // 如果创建失败，返回空列表
                    context.Response.Write("{\"success\":true,\"message\":\"目录创建失败: " + JsonEncode(ex.Message) + "\",\"files\":[]," + debugInfo + "}");
                    return;
                }
            }
            
            // 获取所有文件
            System.IO.DirectoryInfo dir = new System.IO.DirectoryInfo(basePath);
            System.IO.FileInfo[] files = dir.GetFiles();
            
            // 构建JSON响应
            StringBuilder json = new StringBuilder();
            json.Append("{\"success\":true," + debugInfo + ",\"files\":[");
            
            for (int i = 0; i < files.Length; i++) {
                if (i > 0) json.Append(",");
                
                System.IO.FileInfo file = files[i];
                string ext = file.Extension.ToLower();
                string iconUrl = GetFileIcon(ext);
                string fileUrl = GetFileUrl(file.FullName, iscommon, isgroup, sid, snum);
                string fileSize = FormatFileSize(file.Length);
                
                json.Append("{");
                json.Append("\"name\":\"" + JsonEncode(file.Name) + "\",");
                json.Append("\"url\":\"" + JsonEncode(fileUrl) + "\",");
                json.Append("\"icon\":\"" + JsonEncode(iconUrl) + "\",");
                json.Append("\"size\":\"" + fileSize + "\",");
                json.Append("\"date\":\"" + file.LastWriteTime.ToString("yyyy-MM-dd HH:mm") + "\"");
                json.Append("}");
            }
            
            json.Append("]}");
            context.Response.Write(json.ToString());
            
        } catch (Exception ex) {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEncode(ex.Message) + "\",\"files\":[]}");
        }
    }
    
    private string GetStudentGroupId(string sid, string snum) {
        try {
            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString)) {
                conn.Open();
                string sql = "";
                SqlCommand cmd = null;
                
                if (!string.IsNullOrEmpty(sid)) {
                    sql = "SELECT Sgid FROM Students WHERE Sid = @Sid";
                    cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Sid", sid);
                } else if (!string.IsNullOrEmpty(snum)) {
                    sql = "SELECT Sgid FROM Students WHERE Snum = @Snum";
                    cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Snum", snum);
                }
                
                if (cmd != null) {
                    using (cmd) {
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value) {
                            return result.ToString();
                        }
                    }
                }
            }
        } catch { }
        return "";
    }
    
    private string GetFileIcon(string ext) {
        switch (ext) {
            case ".jpg":
            case ".jpeg":
            case ".png":
            case ".gif":
            case ".bmp":
                return "../images/pic.gif";
            case ".doc":
            case ".docx":
                return "../images/word.gif";
            case ".xls":
            case ".xlsx":
                return "../images/excel.gif";
            case ".ppt":
            case ".pptx":
                return "../images/ppt.gif";
            case ".pdf":
                return "../images/pdf.gif";
            case ".txt":
                return "../images/txt.gif";
            case ".zip":
            case ".rar":
            case ".7z":
                return "../images/zip.gif";
            case ".mp3":
            case ".wav":
            case ".wma":
                return "../images/music.gif";
            case ".mp4":
            case ".avi":
            case ".wmv":
            case ".flv":
                return "../images/video.gif";
            default:
                return "../images/file.gif";
        }
    }
    
    private string GetFileUrl(string fullPath, string iscommon, string isgroup, string sid, string snum) {
        string fileName = System.IO.Path.GetFileName(fullPath);
        if (iscommon == "True") {
            return "../upload/common/" + fileName;
        } else if (isgroup == "True") {
            string gid = GetStudentGroupId(sid, snum);
            return "../upload/group" + gid + "/" + fileName;
        } else {
            return "../upload/stu" + sid + "/" + fileName;
        }
    }
    
    private string FormatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024.0).ToString("0.0") + " KB";
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024.0 * 1024.0)).ToString("0.0") + " MB";
        return (bytes / (1024.0 * 1024.0 * 1024.0)).ToString("0.0") + " GB";
    }
    
    private string JsonEncode(string str) {
        if (string.IsNullOrEmpty(str)) return "";
        return str.Replace("\\", "\\\\")
                  .Replace("\"", "\\\"")
                  .Replace("\n", "\\n")
                  .Replace("\r", "\\r")
                  .Replace("\t", "\\t");
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }
}


#line default
#line hidden
