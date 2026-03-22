<%@ WebHandler Language="C#" Class="getprojectedit" %>

using System;
using System.Web;
using System.IO;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;

/// <summary>
/// 获取学生已保存的Scratch项目文件（用于考试修改功能）
/// 通过直接查询数据库获取文件路径，不依赖BLL层
/// </summary>
public class getprojectedit : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/octet-stream";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        string qid = context.Request.QueryString["id"];
        if (string.IsNullOrEmpty(qid))
        {
            context.Response.StatusCode = 400;
            context.Response.ContentType = "text/plain";
            context.Response.Write("missing id");
            return;
        }

        // 获取学生学号（从Cookie）
        string snum = "";
        try
        {
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
                    MethodInfo mi = ct.GetMethod("ToModel",
                        BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    PropertyInfo p = ct.GetProperty("Snum");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null)
                        {
                            snum = v.ToString();
                            if (snum.Contains("%"))
                            {
                                try { snum = HttpUtility.UrlDecode(snum, System.Text.Encoding.UTF8); } catch { }
                            }
                        }
                    }
                }
            }
        }
        catch { }

        if (string.IsNullOrEmpty(snum))
        {
            context.Response.StatusCode = 401;
            context.Response.ContentType = "text/plain";
            context.Response.Write("not logged in");
            return;
        }

        // 获取数据库连接字符串
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr))
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "text/plain";
            context.Response.Write("db config error");
            return;
        }

        // 查询Works表获取文件路径
        string wurl = "";
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 Wurl FROM Works WHERE Wmid=@mid AND Wnum=@num ORDER BY Wid DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@mid", int.Parse(qid));
                    cmd.Parameters.AddWithValue("@num", snum);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        wurl = result.ToString();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "text/plain";
            context.Response.Write("db error: " + ex.Message);
            return;
        }

        if (string.IsNullOrEmpty(wurl))
        {
            context.Response.StatusCode = 404;
            context.Response.ContentType = "text/plain";
            context.Response.Write("no saved project");
            return;
        }

        // 将相对路径映射为物理路径
        string physicalPath = "";
        try
        {
            if (wurl.StartsWith("~") || wurl.StartsWith("/"))
            {
                physicalPath = context.Server.MapPath(wurl);
            }
            else
            {
                // 尝试加上 ~/ 前缀
                physicalPath = context.Server.MapPath("~/" + wurl);
            }
        }
        catch
        {
            physicalPath = wurl; // fallback：直接使用
        }

        if (!File.Exists(physicalPath))
        {
            context.Response.StatusCode = 404;
            context.Response.ContentType = "text/plain";
            context.Response.Write("file not found: " + wurl);
            return;
        }

        // 读取文件并输出
        try
        {
            byte[] data = File.ReadAllBytes(physicalPath);
            context.Response.ContentType = "application/octet-stream";
            context.Response.AddHeader("Content-Disposition", "inline; filename=project.sb3");
            context.Response.BinaryWrite(data);
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "text/plain";
            context.Response.Write("read error: " + ex.Message);
        }
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        return cs;
    }

    public bool IsReusable { get { return false; } }
}
