#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\getcoursecard.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "9EDBDC8451E913A4954E4598D758E971"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\getcoursecard.ashx"


using System;
using System.Web;
using System.Data.SqlClient;

/// <summary>
/// 返回课程信息卡片数据（课程名称、任务总数、已完成数、进度百分比）
/// 参数: cid - 课程ID
/// </summary>
public class GetCourseCard : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";

        try
        {
            string cidStr = context.Request.QueryString["cid"];
            if (string.IsNullOrEmpty(cidStr))
            {
                context.Response.Write("null");
                return;
            }
            int courseId;
            if (!int.TryParse(cidStr, out courseId))
            {
                context.Response.Write("null");
                return;
            }

            string cs = GetConnStr(context);
            if (string.IsNullOrEmpty(cs))
            {
                context.Response.Write("null");
                return;
            }

            // 获取学生学号
            string snum = "";
            if (context.Session != null && context.Session["Snum"] != null)
                snum = context.Session["Snum"].ToString();
            if (string.IsNullOrEmpty(snum))
            {
                try
                {
                    HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
                    if (sc != null && !string.IsNullOrEmpty(sc.Value))
                    {
                        string cv = sc.Value;
                        if (cv.Contains("%"))
                        {
                            try { cv = HttpUtility.UrlDecode(cv, System.Text.Encoding.UTF8); } catch { }
                        }
                        Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                        if (ct != null)
                        {
                            object m = Activator.CreateInstance(ct);
                            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                                System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                            if (mi != null) mi.Invoke(m, new object[] { cv });
                            System.Reflection.PropertyInfo p = ct.GetProperty("Snum");
                            if (p != null)
                            {
                                object v = p.GetValue(m, null);
                                if (v != null) snum = v.ToString();
                            }
                        }
                    }
                }
                catch { }
            }

            string courseName = "";
            int taskTotal = 0;
            int taskCompleted = 0;

            SqlConnection conn = new SqlConnection(cs);
            try
            {
                conn.Open();

                // 查询课程名称
                SqlCommand cmd1 = new SqlCommand(
                    "SELECT Ctitle FROM Courses WHERE Cid=@Cid AND (Cdelete=0 OR Cdelete IS NULL)", conn);
                try
                {
                    cmd1.Parameters.AddWithValue("@Cid", courseId);
                    cmd1.CommandTimeout = 5;
                    object r = cmd1.ExecuteScalar();
                    if (r != null && r != DBNull.Value) courseName = r.ToString();
                }
                finally { cmd1.Dispose(); }

                if (string.IsNullOrEmpty(courseName))
                {
                    context.Response.Write("null");
                    return;
                }

                // 查询任务总数
                SqlCommand cmd2 = new SqlCommand(
                    "SELECT COUNT(*) FROM Listmenu WHERE Lcid=@Lcid AND (lshow IS NULL OR CONVERT(nvarchar(10),lshow) IN ('1','True','true'))", conn);
                try
                {
                    cmd2.Parameters.AddWithValue("@Lcid", courseId);
                    cmd2.CommandTimeout = 5;
                    taskTotal = Convert.ToInt32(cmd2.ExecuteScalar());
                }
                finally { cmd2.Dispose(); }

                // 查询已完成任务数
                if (!string.IsNullOrEmpty(snum))
                {
                    SqlCommand cmd3 = new SqlCommand(
                        "SELECT COUNT(DISTINCT L.Lid) FROM Listmenu L"
                        + " INNER JOIN Summary S ON L.Lid=S.Slid"
                        + " WHERE L.Lcid=@Lcid"
                        + " AND (L.lshow IS NULL OR CONVERT(nvarchar(10),L.lshow) IN ('1','True','true'))"
                        + " AND S.Snum=@Snum AND (S.Sshow=1 OR S.Sshow IS NULL)", conn);
                    try
                    {
                        cmd3.Parameters.AddWithValue("@Lcid", courseId);
                        cmd3.Parameters.AddWithValue("@Snum", snum);
                        cmd3.CommandTimeout = 5;
                        taskCompleted = Convert.ToInt32(cmd3.ExecuteScalar());
                    }
                    finally { cmd3.Dispose(); }
                }
            }
            finally { conn.Dispose(); }

            int pct = taskTotal > 0 ? (int)Math.Round((double)taskCompleted / taskTotal * 100.0) : 0;
            if (pct > 100) pct = 100;

            string safeName = courseName.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", " ").Replace("\r", "");
            context.Response.Write(string.Format("{{\"name\":\"{0}\",\"completed\":{1},\"total\":{2},\"pct\":{3}}}",
                safeName, taskCompleted, taskTotal, pct));
        }
        catch (Exception ex)
        {
            context.Response.Write("null");
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
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
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


#line default
#line hidden
