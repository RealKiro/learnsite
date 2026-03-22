<%@ WebHandler Language="C#" Class="uploadfile" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.IO;
using System.Text;

public class uploadfile : IHttpHandler, IRequiresSessionState {
    
    public void ProcessRequest(HttpContext context) {
        context.Response.ContentType = "text/plain";
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
                            
                            System.Reflection.PropertyInfo sidProp = cookieType.GetProperty("Sid");
                            if (sidProp != null)
                            {
                                object sidValue = sidProp.GetValue(cookieModel, null);
                                if (sidValue != null) sid = sidValue.ToString();
                            }
                            
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
            
            if (string.IsNullOrEmpty(sid)) {
                context.Response.Write("上传失败：未登录");
                return;
            }
            
            // 检查是否有文件上传
            if (context.Request.Files.Count == 0) {
                context.Response.Write("上传失败：没有选择文件");
                return;
            }
            
            HttpPostedFile file = context.Request.Files[0];
            if (file == null || file.ContentLength == 0) {
                context.Response.Write("上传失败：文件为空");
                return;
            }
            
            // 检查文件大小（30MB限制）
            if (file.ContentLength > 30 * 1024 * 1024) {
                context.Response.Write("上传失败：文件大小超过30MB");
                return;
            }
            
            // 构建保存路径
            string uploadDir = "";
            if (iscommon == "True") {
                uploadDir = context.Server.MapPath("~/upload/common/");
            } else if (isgroup == "True") {
                string gid = GetStudentGroupId(sid, snum);
                if (string.IsNullOrEmpty(gid)) {
                    context.Response.Write("上传失败：未加入小组");
                    return;
                }
                uploadDir = context.Server.MapPath("~/upload/group" + gid + "/");
            } else {
                uploadDir = context.Server.MapPath("~/upload/stu" + sid + "/");
            }
            
            // 创建目录（如果不存在）
            if (!Directory.Exists(uploadDir)) {
                Directory.CreateDirectory(uploadDir);
            }
            
            // 获取文件名并保存
            string fileName = Path.GetFileName(file.FileName);
            string savePath = Path.Combine(uploadDir, fileName);
            
            // 如果文件已存在，添加时间戳
            if (File.Exists(savePath)) {
                string nameWithoutExt = Path.GetFileNameWithoutExtension(fileName);
                string ext = Path.GetExtension(fileName);
                fileName = nameWithoutExt + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ext;
                savePath = Path.Combine(uploadDir, fileName);
            }
            
            // 保存文件
            file.SaveAs(savePath);
            
            context.Response.Write("保存" + Path.GetFileNameWithoutExtension(fileName) + "文件到网盘成功!");
            
        } catch (Exception ex) {
            context.Response.Write("上传失败：" + ex.Message);
        }
    }
    
    private string GetStudentGroupId(string sid, string snum) {
        try {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connectionString)) {
                conn.Open();
                string sql = "";
                System.Data.SqlClient.SqlCommand cmd = null;
                
                if (!string.IsNullOrEmpty(sid)) {
                    sql = "SELECT Sgid FROM Students WHERE Sid = @Sid";
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Sid", sid);
                } else if (!string.IsNullOrEmpty(snum)) {
                    sql = "SELECT Sgid FROM Students WHERE Snum = @Snum";
                    cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
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
    
    public bool IsReusable {
        get {
            return false;
        }
    }
}
