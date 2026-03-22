<%@ WebHandler Language="C#" Class="worksstat" %>
<%@ Import Namespace="System.Collections.Generic" %>

using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Web;

/// <summary>
/// 作业提交统计接口
/// GET/POST: ?cids=1,2,3
/// 返回每个课程的已交人数、未交人数、总人数
/// </summary>
public class worksstat : IHttpHandler
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

        string cidsRaw = (ctx.Request.QueryString["cids"]
                       ?? ctx.Request.Form["cids"] ?? "").Trim();
        if (string.IsNullOrEmpty(cidsRaw))
        { Write(ctx, "{\"ok\":true,\"data\":{}}"); return; }

        // 解析 cid 列表
        List<int> cids = new List<int>();
        foreach (string p in cidsRaw.Split(','))
        {
            int v;
            if (int.TryParse(p.Trim(), out v) && v > 0) cids.Add(v);
        }
        if (cids.Count == 0) { Write(ctx, "{\"ok\":true,\"data\":{}}"); return; }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        { Write(ctx, "{\"ok\":false,\"msg\":\"数据库连接失败\"}"); return; }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 构建 IN 列表（纯数字，无 SQL 注入风险）
                string cidList = string.Join(",",
                    cids.ConvertAll(c => c.ToString()).ToArray());

                // ── 1. 获取每个课程对应的年级 (Cobj) ───────────────────
                Dictionary<int, int> cidToGrade = new Dictionary<int, int>();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Cid, ISNULL(CAST(Cobj AS nvarchar(20)),'0') AS Cobj " +
                    "FROM Courses WHERE Cid IN (" + cidList + ")", conn))
                {
                    cmd.CommandTimeout = 8;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int cid = Convert.ToInt32(dr["Cid"]);
                            int g = 0;
                            if (dr["Cobj"] != DBNull.Value)
                                int.TryParse(dr["Cobj"].ToString().Trim(), out g);
                            cidToGrade[cid] = g;
                        }
                    }
                }

                // ── 2. 按年级统计总学生数 ─────────────────────────────
                Dictionary<int, int> gradeTotals = new Dictionary<int, int>();
                foreach (KeyValuePair<int, int> kv in cidToGrade)
                {
                    int g = kv.Value;
                    if (g > 0 && !gradeTotals.ContainsKey(g))
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT COUNT(*) FROM Students WHERE Sgrade=@g", conn))
                        {
                            cmd.Parameters.AddWithValue("@g", g);
                            cmd.CommandTimeout = 5;
                            object r = cmd.ExecuteScalar();
                            gradeTotals[g] = (r != null && r != DBNull.Value)
                                ? Convert.ToInt32(r) : 0;
                        }
                    }
                }

                // ── 3. 统计每个课程的已交人数 ─────────────────────────
                // 已交 = 该课程下所有 Listmenu 任务中有 Works 记录的不同学生数
                Dictionary<int, int> submits = new Dictionary<int, int>();
                foreach (int cid in cids)
                {
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(DISTINCT Wnum) FROM Works
                          WHERE Wlid IN (
                              SELECT Lid FROM Listmenu WHERE Lcid=@cid
                          )", conn))
                    {
                        cmd.Parameters.AddWithValue("@cid", cid);
                        cmd.CommandTimeout = 8;
                        object r = cmd.ExecuteScalar();
                        submits[cid] = (r != null && r != DBNull.Value)
                            ? Convert.ToInt32(r) : 0;
                    }
                }

                // ── 4. 组装 JSON ──────────────────────────────────────
                StringBuilder sb = new StringBuilder("{\"ok\":true,\"data\":{");
                bool first = true;
                foreach (int cid in cids)
                {
                    int s = submits.ContainsKey(cid) ? submits[cid] : 0;
                    int g = cidToGrade.ContainsKey(cid) ? cidToGrade[cid] : 0;
                    int t = (g > 0 && gradeTotals.ContainsKey(g))
                              ? gradeTotals[g] : 0;
                    int ns = Math.Max(0, t - s);
                    if (!first) sb.Append(",");
                    first = false;
                    sb.AppendFormat(
                        "\"{0}\":{{\"s\":{1},\"t\":{2},\"ns\":{3}}}",
                        cid, s, t, ns);
                }
                sb.Append("}}");
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
