<%@ WebHandler Language="C#" Class="worksdetail" %>

using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Web;

/// <summary>
/// 作业提交详情接口
/// GET: ?cid=123
/// 返回课程的已交/未交学生名单（学号+姓名+班级）
/// { ok, title, total, grade, submitted:[{num,name,cls}...], notSubmitted:[...] }
/// </summary>
public class worksdetail : IHttpHandler
{
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly
                .GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public |
                    System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
            try { cs = System.Configuration.ConfigurationManager
                .ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        if (!string.IsNullOrEmpty(cs) &&
            cs.ToLower().IndexOf("connect timeout") < 0 &&
            cs.ToLower().IndexOf("connection timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=8;";
        return cs;
    }

    private void Write(HttpContext ctx, string json)
    {
        try { ctx.Response.Clear(); } catch { }
        ctx.Response.ContentType = "application/json";
        ctx.Response.Charset = "utf-8";
        ctx.Response.TrySkipIisCustomErrors = true;
        ctx.Response.Write(json);
    }

    private string Esc(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "").Replace("\n", "\\n");
    }

    public void ProcessRequest(HttpContext ctx)
    {
        // 教师身份校验
        try
        {
            HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc == null || string.IsNullOrEmpty(tc.Value))
            { Write(ctx, "{\"ok\":false,\"msg\":\"请先登录\"}"); return; }
        }
        catch { }

        int cid = 0;
        int.TryParse((ctx.Request.QueryString["cid"] ?? ctx.Request.Form["cid"] ?? "").Trim(), out cid);
        if (cid <= 0)
        { Write(ctx, "{\"ok\":false,\"msg\":\"参数错误\"}"); return; }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        { Write(ctx, "{\"ok\":false,\"msg\":\"数据库连接失败\"}"); return; }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 1. 获取课程标题和年级
                string title = "";
                int grade = 0;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ISNULL(Ctitle,N'(无标题)'), ISNULL(CAST(Cobj AS nvarchar(20)),'0') FROM Courses WHERE Cid=@cid", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", cid);
                    cmd.CommandTimeout = 5;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            title = dr[0].ToString();
                            int.TryParse(dr[1].ToString().Trim(), out grade);
                        }
                    }
                }

                if (grade <= 0)
                { Write(ctx, "{\"ok\":false,\"msg\":\"未找到课程或课程无年级信息\"}"); return; }

                // 2. 获取该年级所有学生（按班级、学号排序）
                List<string[]> students = new List<string[]>(); // [snum, sname, sclass]
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Snum, ISNULL(Sname,N''), ISNULL(CAST(Sclass AS nvarchar(20)),'') " +
                    "FROM Students WHERE Sgrade=@g ORDER BY Sclass, Snum", conn))
                {
                    cmd.Parameters.AddWithValue("@g", grade);
                    cmd.CommandTimeout = 8;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                        while (dr.Read())
                            students.Add(new string[] { dr[0].ToString(), dr[1].ToString(), dr[2].ToString() });
                }

                // 3. 获取该课程已提交学生学号集合
                HashSet<string> submittedNums = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT DISTINCT Wnum FROM Works
                      WHERE Wlid IN (SELECT Lid FROM Listmenu WHERE Lcid=@cid)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", cid);
                    cmd.CommandTimeout = 8;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                        while (dr.Read()) submittedNums.Add(dr[0].ToString());
                }

                // 4. 分类为已交 / 未交
                List<string[]> submitted    = new List<string[]>();
                List<string[]> notSubmitted = new List<string[]>();
                foreach (string[] s in students)
                {
                    if (submittedNums.Contains(s[0]))
                        submitted.Add(s);
                    else
                        notSubmitted.Add(s);
                }

                // 5. 组装 JSON
                StringBuilder sb = new StringBuilder();
                sb.Append("{\"ok\":true");
                sb.Append(",\"title\":\"").Append(Esc(title)).Append("\"");
                sb.Append(",\"total\":").Append(students.Count);
                sb.Append(",\"grade\":").Append(grade);

                // submitted 数组
                sb.Append(",\"submitted\":[");
                for (int i = 0; i < submitted.Count; i++)
                {
                    if (i > 0) sb.Append(",");
                    sb.AppendFormat("{{\"num\":\"{0}\",\"name\":\"{1}\",\"cls\":\"{2}\"}}",
                        Esc(submitted[i][0]), Esc(submitted[i][1]), Esc(submitted[i][2]));
                }
                sb.Append("]");

                // notSubmitted 数组
                sb.Append(",\"notSubmitted\":[");
                for (int i = 0; i < notSubmitted.Count; i++)
                {
                    if (i > 0) sb.Append(",");
                    sb.AppendFormat("{{\"num\":\"{0}\",\"name\":\"{1}\",\"cls\":\"{2}\"}}",
                        Esc(notSubmitted[i][0]), Esc(notSubmitted[i][1]), Esc(notSubmitted[i][2]));
                }
                sb.Append("]}");

                Write(ctx, sb.ToString());
            }
        }
        catch (Exception ex)
        {
            Write(ctx, "{\"ok\":false,\"msg\":\"" + Esc(ex.Message) + "\"}");
        }
    }

    public bool IsReusable { get { return false; } }
}
