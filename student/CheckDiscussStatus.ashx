<%@ WebHandler Language="C#" Class="CheckDiscussStatus" %>

using System;
using System.Web;
using System.Data.SqlClient;

/// <summary>
/// 检查小组讨论开关状态
/// </summary>
public class CheckDiscussStatus : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            // 获取当前学生的年级和班级
            int grade = 0;
            int cls = 0;
            
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { }
                }
                
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    
                    System.Reflection.PropertyInfo gradeProp = ct.GetProperty("Sgrade");
                    System.Reflection.PropertyInfo clsProp = ct.GetProperty("Sclass");
                    
                    if (gradeProp != null)
                    {
                        object gradeVal = gradeProp.GetValue(m, null);
                        if (gradeVal != null) int.TryParse(gradeVal.ToString(), out grade);
                    }
                    
                    if (clsProp != null)
                    {
                        object clsVal = clsProp.GetValue(m, null);
                        if (clsVal != null) int.TryParse(clsVal.ToString(), out cls);
                    }
                }
            }
            
            if (grade > 0 && cls > 0)
            {
                // 查询Room表获取Rdiscuss状态
                string cs = GetConnStr(context);
                if (!string.IsNullOrEmpty(cs))
                {
                    using (SqlConnection conn = new SqlConnection(cs))
                    {
                        conn.Open();
                        // 先检查 Rdiscuss 列是否存在：列不存在表示未配置，默认开启
                        using (SqlCommand chk = new SqlCommand(
                            "SELECT COUNT(*) FROM sys.columns WHERE object_id=OBJECT_ID(N'Room') AND name='Rdiscuss'", conn))
                        {
                            chk.CommandTimeout = 5;
                            int exists = Convert.ToInt32(chk.ExecuteScalar());
                            if (exists == 0)
                            {
                                context.Response.Write("{\"enabled\":true}");
                                return;
                            }
                        }
                        string sql = "SELECT ISNULL(Rdiscuss, 1) FROM Room WHERE Rgrade=@Grade AND Rclass=@Class";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Grade", grade);
                            cmd.Parameters.AddWithValue("@Class", cls);
                            cmd.CommandTimeout = 5;
                            
                            object result = cmd.ExecuteScalar();
                            if (result != null)
                            {
                                bool enabled = Convert.ToBoolean(result);
                                context.Response.Write("{\"enabled\":" + (enabled ? "true" : "false") + "}");
                                return;
                            }
                        }
                    }
                }
            }
            
            // 默认返回关闭状态（无法确定班级时安全关闭）
            context.Response.Write("{\"enabled\":false}");
        }
        catch (Exception ex)
        {
            // 出错时默认返回关闭状态（安全策略：失败关闭）
            context.Response.Write("{\"enabled\":false,\"error\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
    }
    
    private string GetConnStr(HttpContext context)
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
        {
            try
            {
                cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch { }
        }
        
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        
        return cs;
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}
