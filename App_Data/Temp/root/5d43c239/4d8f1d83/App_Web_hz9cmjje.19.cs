#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\deletefile.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "8E93896664E25FB90AF8BE6C4276EC69"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\deletefile.ashx"


using System;
using System.Web;
using System.Web.SessionState;
using System.Text;
using System.Data.SqlClient;
using System.Configuration;

public class deletefile : IHttpHandler, IRequiresSessionState {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;
        
        try {
            string isgroup = context.Request.QueryString["isgroup"] ?? "False";
            string iscommon = context.Request.QueryString["iscommon"] ?? "False";
            string fileName = context.Request.Form["fileName"];
            
            if (string.IsNullOrEmpty(fileName)) {
                context.Response.Write("{\"success\":false,\"message\":\"文件名不能为空\"}");
                return;
            }
            
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
                context.Response.Write("{\"success\":false,\"message\":\"未登录\"}");
                return;
            }
            
            // 构建文件路径
            string filePath = "";
            if (iscommon == "True") {
                filePath = context.Server.MapPath("~/upload/common/" + fileName);
            } else if (isgroup == "True") {
                string gid = GetStudentGroupId(sid, snum);
                if (string.IsNullOrEmpty(gid)) {
                    context.Response.Write("{\"success\":false,\"message\":\"未加入小组\"}");
                    return;
                }
                filePath = context.Server.MapPath("~/upload/group" + gid + "/" + fileName);
            } else {
                filePath = context.Server.MapPath("~/upload/stu" + sid + "/" + fileName);
            }
            
            // 删除文件
            if (System.IO.File.Exists(filePath)) {
                System.IO.File.Delete(filePath);
                context.Response.Write("{\"success\":true,\"message\":\"删除成功\"}");
            } else {
                context.Response.Write("{\"success\":false,\"message\":\"文件不存在\"}");
            }
            
        } catch (Exception ex) {
            context.Response.Write("{\"success\":false,\"message\":\"删除失败: " + JsonEncode(ex.Message) + "\"}");
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
