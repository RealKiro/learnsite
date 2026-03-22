#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\uploadexcel.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "D54B527EC598CC8F75717E4E0A078713"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\uploadexcel.ashx"


using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Reflection;
using System.Text;
using System.Web;

/// <summary>
/// 表格作品保存接口 — 完整重写版
/// 绕过编译DLL中的 bll.SaveExcel，直接写入数据库 Works.Wcode。
/// 参数: id=mcid-mid-lid (查询字符串), title/excel (FormData POST)
/// 返回: {"success":true/false, "message":"..."}
/// </summary>
public class uploadexcel : IHttpHandler
{
    // ── 入口 ───────────────────────────────────────────────────
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        // 1. 登录检查
        if (context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname] == null)
        {
            WriteJson(context, false, "未登录，请重新登录");
            return;
        }

        // 2. 解析 id 参数 (mcid-mid-lid)
        string idStr = (context.Request.QueryString["id"] ?? "").Trim();
        string[] parts = idStr.Split('-');
        if (parts.Length < 3)
        {
            WriteJson(context, false, "id参数格式错误: " + idStr + " (期期 mcid-mid-lid)");
            return;
        }
        int wcid = 0, wmid = 0, wlid = 0;
        int.TryParse(parts[0], out wcid);
        int.TryParse(parts[1], out wmid);
        int.TryParse(parts[2], out wlid);
        if (wlid <= 0 && wmid <= 0)
        {
            WriteJson(context, false, "id参数无效 (lid=" + wlid + ", mid=" + wmid + ")");
            return;
        }

        // 3. 读取表单数据
        string title   = (context.Request.Form["title"] ?? "").Trim();
        string excelRaw = context.Request.Form["excel"] ?? "";
        if (string.IsNullOrEmpty(excelRaw))
        {
            WriteJson(context, false, "Excel JSON 数据为空");
            return;
        }
        // JS 用 encodeURIComponent 编码，服务端 UrlDecode
        string excelJson = excelRaw;
        try { excelJson = HttpUtility.UrlDecode(excelRaw, Encoding.UTF8); } catch { }

        // 4. 学生信息
        int    sid = 0, sgrade = 0, sclass = 0, sterm = 0;
        string snum = "", sname = "",
               syear = DateTime.Now.Year.ToString(), sip = "", stime = "";
        GetStudentInfo(context, out sid, out snum, out sname,
                       out sgrade, out sclass, out syear, out sterm, out sip, out stime);
        if (string.IsNullOrEmpty(snum))
        {
            WriteJson(context, false, "无法读取学生信息，请重新登录");
            return;
        }

        // 5. 数据库连接
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr))
        {
            WriteJson(context, false, "数据库连接配置错误");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                bool hasWlid  = ColumnExists(conn, "Works", "Wlid");
                bool hasWcode = ColumnExists(conn, "Works", "Wcode");

                // 6. 查找已有记录
                int  existWid      = 0;
                bool alreadyGraded = false;
                {
                    string lookupSql = hasWlid && wlid > 0
                        ? "SELECT TOP 1 Wid, ISNULL(Wcheck,0) AS Wcheck FROM Works WHERE Wnum=@Wnum AND Wlid=@Wlid ORDER BY Wid DESC"
                        : "SELECT TOP 1 Wid, ISNULL(Wcheck,0) AS Wcheck FROM Works WHERE Wnum=@Wnum AND Wmid=@Wmid ORDER BY Wid DESC";

                    using (SqlCommand cmd = new SqlCommand(lookupSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Wnum", snum);
                        if (hasWlid && wlid > 0) cmd.Parameters.AddWithValue("@Wlid", wlid);
                        else                     cmd.Parameters.AddWithValue("@Wmid", wmid);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                existWid      = r["Wid"]    != DBNull.Value ? Convert.ToInt32(r["Wid"])    : 0;
                                alreadyGraded = r["Wcheck"] != DBNull.Value && Convert.ToInt32(r["Wcheck"]) != 0;
                            }
                        }
                    }
                }

                if (alreadyGraded)
                {
                    WriteJson(context, false, "作品已评价，不可修改");
                    return;
                }

                DateTime now = DateTime.Now;

                if (existWid > 0)
                {
                    // UPDATE 已有记录
                    string updSql = hasWcode
                        ? "UPDATE Works SET Wlength=@Wlen, Wdate=@Wdate, Wself=@Wself, Wcode=@Wcode WHERE Wid=@Wid"
                        : "UPDATE Works SET Wlength=@Wlen, Wdate=@Wdate, Wself=@Wself WHERE Wid=@Wid";
                    using (SqlCommand cmd = new SqlCommand(updSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Wlen",  excelJson.Length);
                        cmd.Parameters.AddWithValue("@Wdate", now);
                        cmd.Parameters.AddWithValue("@Wself", title);
                        if (hasWcode) cmd.Parameters.AddWithValue("@Wcode", excelJson);
                        cmd.Parameters.AddWithValue("@Wid",   existWid);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // INSERT 新记录
                    var cols = new StringBuilder(
                        "Wnum,Wcid,Wmid,Wmsort,Wfilename,Wtype,Wurl,Wlength,Wdate,Wip,Wtime,Wcan,Wgrade,Wclass,Wyear,Wterm,Wsid,Wname,Wself");
                    var vals = new StringBuilder(
                        "@Wnum,@Wcid,@Wmid,@Wmsort,@Wfn,@Wtype,@Wurl,@Wlen,@Wdate,@Wip,@Wtime,@Wcan,@Wgrade,@Wclass,@Wyear,@Wterm,@Wsid,@Wname,@Wself");

                    if (hasWlid)  { cols.Append(",Wlid");  vals.Append(",@Wlid"); }
                    if (hasWcode) { cols.Append(",Wcode"); vals.Append(",@Wcode"); }

                    string wfn  = snum + "_" + wcid + "_" + wmid + "_excel.json";
                    string wurl = "/homework/" + syear + "/" + sgrade + "/" + sclass +
                                  "/" + wcid + "/" + wmid + "/" + wfn;

                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Works (" + cols + ") VALUES (" + vals + ")", conn))
                    {
                        cmd.Parameters.AddWithValue("@Wnum",   snum);
                        cmd.Parameters.AddWithValue("@Wcid",   wcid);
                        cmd.Parameters.AddWithValue("@Wmid",   wmid);
                        cmd.Parameters.AddWithValue("@Wmsort", 16);   // 16 = excel / luckysheet
                        cmd.Parameters.AddWithValue("@Wfn",    wfn);
                        cmd.Parameters.AddWithValue("@Wtype",  "luckysheet");
                        cmd.Parameters.AddWithValue("@Wurl",   wurl);
                        cmd.Parameters.AddWithValue("@Wlen",   excelJson.Length);
                        cmd.Parameters.AddWithValue("@Wdate",  now);
                        cmd.Parameters.AddWithValue("@Wip",    sip);
                        cmd.Parameters.AddWithValue("@Wtime",  string.IsNullOrEmpty(stime) ? now.ToString() : stime);
                        cmd.Parameters.AddWithValue("@Wcan",   true);
                        cmd.Parameters.AddWithValue("@Wgrade", sgrade);
                        cmd.Parameters.AddWithValue("@Wclass", sclass);
                        cmd.Parameters.AddWithValue("@Wyear",  syear);
                        cmd.Parameters.AddWithValue("@Wterm",  sterm);
                        cmd.Parameters.AddWithValue("@Wsid",   sid);
                        cmd.Parameters.AddWithValue("@Wname",  sname);
                        cmd.Parameters.AddWithValue("@Wself",  title);
                        if (hasWlid)  cmd.Parameters.AddWithValue("@Wlid",  wlid > 0 ? (object)wlid : (object)wmid);
                        if (hasWcode) cmd.Parameters.AddWithValue("@Wcode", excelJson);
                        cmd.ExecuteNonQuery();
                    }
                }

                WriteJson(context, true, "保存成功");
            }
        }
        catch (Exception ex)
        {
            WriteJson(context, false, "保存失败: " + ex.Message);
        }
    }

    public bool IsReusable { get { return false; } }

    // ── 辅助方法 ─────────────────────────────────────────────────
    private static void WriteJson(HttpContext ctx, bool ok, string msg)
    {
        ctx.Response.Write("{\"success\":" + (ok ? "true" : "false") +
            ",\"message\":\"" +
            msg.Replace("\\", "\\\\").Replace("\"", "\\\"")
               .Replace("\r", "\\r").Replace("\n", "\\n") +
            "\"}");
    }

    private static bool ColumnExists(SqlConnection conn, string table, string col)
    {
        try
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
            {
                cmd.Parameters.AddWithValue("@t", table);
                cmd.Parameters.AddWithValue("@c", col);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    private static void GetStudentInfo(
        HttpContext context,
        out int sid, out string snum, out string sname,
        out int sgrade, out int sclass, out string syear, out int sterm,
        out string sip, out string stime)
    {
        int    _sid = 0, _sg = 0, _sc = 0, _st = 0;
        string _snum = "", _sname = "",
               _syear = DateTime.Now.Year.ToString(), _sip = "", _stime = "";
        try
        {
            HttpCookie cookie = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
            {
                string val = cookie.Value;
                if (val.Contains("%")) { try { val = HttpUtility.UrlDecode(val, Encoding.UTF8); } catch { } }

                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly
                              .GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object     m  = Activator.CreateInstance(ct);
                    MethodInfo mi = ct.GetMethod("ToModel",
                        BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { val });

                    PropertyInfo p; object v;
                    p = ct.GetProperty("Sid");       if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sid); }
                    p = ct.GetProperty("Snum");      if (p != null) { v = p.GetValue(m, null); if (v != null) _snum  = v.ToString(); }
                    p = ct.GetProperty("Sname");     if (p != null) { v = p.GetValue(m, null); if (v != null) _sname = v.ToString(); }
                    p = ct.GetProperty("Sgrade");    if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sg); }
                    p = ct.GetProperty("Sclass");    if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sc); }
                    p = ct.GetProperty("Syear");     if (p != null) { v = p.GetValue(m, null); if (v != null) _syear = v.ToString(); }
                    p = ct.GetProperty("ThisTerm");  if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _st); }
                    p = ct.GetProperty("LoginIp");   if (p != null) { v = p.GetValue(m, null); if (v != null) _sip   = v.ToString(); }
                    p = ct.GetProperty("LoginTime"); if (p != null) { v = p.GetValue(m, null); if (v != null) _stime = v.ToString(); }
                }
            }
        }
        catch { }
        sid = _sid; snum = _snum; sname = _sname;
        sgrade = _sg; sclass = _sc; syear = _syear;
        sterm = _st; sip = _sip; stime = _stime;
    }

    private static string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly
                              .GetType("LearnSite.DBUtility.DbHelperSQL");
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
}


#line default
#line hidden
