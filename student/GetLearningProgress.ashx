<%@ WebHandler Language="C#" Class="GetLearningProgress" %>

using System;
using System.Web;
using System.Data.SqlClient;

public class GetLearningProgress : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            int studentId = GetCurrentStudentId(context);
            if (studentId <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"未登录\"}");
                return;
            }
            
            int resourceId = 0;
            int.TryParse(context.Request["resourceId"], out resourceId);
            
            if (resourceId <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"资源ID无效\"}");
                return;
            }
            
            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string sql = @"SELECT 
                              (SELECT COUNT(*) FROM ResourceChapters WHERE ResourceId = @ResourceId) as TotalChapters,
                              (SELECT COUNT(DISTINCT ChapterId) FROM ResourceLearningProgress 
                               WHERE StudentId = @StudentId 
                               AND ChapterId IN (SELECT ChapterId FROM ResourceChapters WHERE ResourceId = @ResourceId)
                               AND IsCompleted = 1) as CompletedChapters";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ResourceId", resourceId);
                
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int total = reader.GetInt32(0);
                        int completed = reader.GetInt32(1);
                        decimal progress = total > 0 ? (decimal)completed / total * 100 : 0;
                        
                        context.Response.Write("{\"success\":true,\"progress\":" + progress.ToString("F2") + 
                                             ",\"totalChapters\":" + total + 
                                             ",\"completedChapters\":" + completed + "}");
                        return;
                    }
                }
            }
            
            context.Response.Write("{\"success\":false,\"message\":\"获取进度失败\"}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
    }
    
    private int GetCurrentStudentId(HttpContext context)
    {
        try
        {
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null)
                        {
                            int sid;
                            if (int.TryParse(v.ToString(), out sid)) return sid;
                        }
                    }
                }
            }
        }
        catch { }
        return 0;
    }
    
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}
