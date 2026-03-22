#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\GetLastProgress.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "4AC2711847B8699F54E546A34400F844"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\GetLastProgress.ashx"


using System;
using System.Web;
using System.Data.SqlClient;

public class GetLastProgress : IHttpHandler
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
                
                // 获取上次学习进度
                string sql = @"SELECT TOP 1 LastPosition, Progress, IsCompleted 
                              FROM ResourceLearningProgress 
                              WHERE StudentId = @StudentId AND ResourceId = @ResourceId 
                              AND ChapterId IS NULL
                              ORDER BY LastUpdateTime DESC";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ResourceId", resourceId);
                
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int lastPosition = reader.GetInt32(0);
                        decimal progress = reader.GetDecimal(1);
                        bool isCompleted = reader.GetBoolean(2);
                        
                        context.Response.Write("{\"success\":true,\"lastPosition\":" + lastPosition + 
                                             ",\"progress\":" + progress.ToString("F2") + 
                                             ",\"isCompleted\":" + (isCompleted ? "true" : "false") + "}");
                        return;
                    }
                }
            }
            
            // 没有找到记录，返回默认值
            context.Response.Write("{\"success\":true,\"lastPosition\":0,\"progress\":0,\"isCompleted\":false}");
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


#line default
#line hidden
