#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\CheckNetdiskStatus.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "EEF928AD017C52B348F3E8CD4AB65859"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\CheckNetdiskStatus.ashx"


using System;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;
using System.Configuration;

public class CheckNetdiskStatus : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        bool isEnabled = true; // 默认启用
        
        try
        {
            // 从Session获取学生信息
            if (context.Session["Snum"] == null)
            {
                context.Response.Write("{\"enabled\": false, \"message\": \"未登录\"}");
                return;
            }
            
            string snum = context.Session["Snum"].ToString();
            
            // 获取当前学生所在的教室ID和网盘开关状态
            string connStr = ConfigurationManager.ConnectionStrings["LearnSite"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 查询学生当前课程的教室网盘开关状态
                string sql = @"
                    SELECT TOP 1 R.Rshare
                    FROM Students S
                    INNER JOIN Classes C ON S.Scid = C.Cid
                    INNER JOIN Courses CO ON C.Cid = CO.Cid
                    INNER JOIN Rooms R ON CO.Crid = R.Rid
                    WHERE S.Snum = @Snum
                    ORDER BY CO.Cid DESC
                ";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Snum", snum);
                    object result = cmd.ExecuteScalar();
                    
                    if (result != null && result != DBNull.Value)
                    {
                        isEnabled = Convert.ToBoolean(result);
                    }
                }
            }
            
            context.Response.Write("{\"enabled\": " + isEnabled.ToString().ToLower() + "}");
        }
        catch (Exception ex)
        {
            // 出错时默认启用，避免影响正常使用
            System.Diagnostics.Debug.WriteLine("CheckNetdiskStatus Error: " + ex.ToString());
            context.Response.Write("{\"enabled\": true, \"error\": \"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
