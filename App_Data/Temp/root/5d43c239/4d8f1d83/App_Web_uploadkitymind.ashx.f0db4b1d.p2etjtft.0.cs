#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\uploadkitymind.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "8056B01EC35B91EC83FBA741F776403F"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\uploadkitymind.ashx"


using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;
using System.Text;
using System.IO;

/// <summary>
/// 思维导图保存接口 — 完整重写版
/// 直接操作数据库，绕过编译DLL中Savekitymind不保存Wcode的问题
/// 参数: id=mcid-mid-lid (QueryString), title/km/thumb (FormData POST)
/// 返回: {"success":true/false,"message":"..."}
/// </summary>
public class uploadkitymind : IHttpHandler
{
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

    private void GetStudentInfo(HttpContext context,
        out int sid, out string snum, out string sname,
        out int sgrade, out int sclass, out string syear, out int sterm,
        out string sip, out string stime)
    {
        // C# does not allow capturing out/ref params in lambdas — use local variables
        int    _sid = 0,  _sgrade = 0, _sclass = 0, _sterm = 0;
        string _snum = "", _sname = "", _syear = DateTime.Now.Year.ToString(), _sip = "", _stime = "";
        try
        {
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string val = sc.Value;
                if (val.Contains("%")) { try { val = HttpUtility.UrlDecode(val, Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    MethodInfo mi = ct.GetMethod("ToModel",
                        BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { val });
                    PropertyInfo p; object v;

                    p = ct.GetProperty("Sid");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sid); }

                    p = ct.GetProperty("Snum");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) _snum = v.ToString(); }

                    p = ct.GetProperty("Sname");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) _sname = v.ToString(); }

                    p = ct.GetProperty("Sgrade");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sgrade); }

                    p = ct.GetProperty("Sclass");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sclass); }

                    p = ct.GetProperty("Syear");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) _syear = v.ToString(); }

                    p = ct.GetProperty("ThisTerm");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out _sterm); }

                    p = ct.GetProperty("LoginIp");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) _sip = v.ToString(); }

                    p = ct.GetProperty("LoginTime");
                    if (p != null) { v = p.GetValue(m, null); if (v != null) _stime = v.ToString(); }
                }
            }
        }
        catch { }
        sid = _sid; snum = _snum; sname = _sname;
        sgrade = _sgrade; sclass = _sclass; syear = _syear; sterm = _sterm;
        sip = _sip; stime = _stime;
    }

    private bool ColumnExists(SqlConnection conn, string table, string column)
    {
        try
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
            {
                cmd.Parameters.AddWithValue("@t", table);
                cmd.Parameters.AddWithValue("@c", column);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    private void WriteJson(HttpContext ctx, bool success, string message)
    {
        ctx.Response.Write("{\"success\":" + (success ? "true" : "false") +
            ",\"message\":\"" + message
                .Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "\\r").Replace("\n", "\\n") + "\"}");
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.TrySkipIisCustomErrors = true;

        bool debug = string.Equals(context.Request.QueryString["debug"], "1");

        // === 1. 登录检查 ===
        if (context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname] == null)
        {
            WriteJson(context, false, "未登录，请重新登录");
            return;
        }

        // === 2. 解析 id 参数 (格式: mcid-mid-lid) ===
        string idStr = (context.Request.QueryString["id"] ?? "").Trim();
        string[] parts = idStr.Split('-');
        if (parts.Length < 3)
        {
            WriteJson(context, false, "参数id格式错误: " + idStr);
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

        // === 3. 读取表单数据 ===
        string title = (context.Request.Form["title"] ?? "").Trim();
        string kmRaw = context.Request.Form["km"] ?? "";
        if (string.IsNullOrEmpty(kmRaw))
        {
            WriteJson(context, false, "思维导图数据为空");
            return;
        }
        // JS 用 encodeURIComponent 编码，服务端 UrlDecode
        string kmJson = kmRaw;
        try { kmJson = HttpUtility.UrlDecode(kmRaw, Encoding.UTF8); } catch { }

        // === 4. 获取学生信息 ===
        int sid, sgrade, sclass, sterm;
        string snum, sname, syear, sip, stime;
        GetStudentInfo(context, out sid, out snum, out sname,
                       out sgrade, out sclass, out syear, out sterm, out sip, out stime);
        if (string.IsNullOrEmpty(snum))
        {
            WriteJson(context, false, "无法读取学生信息，请重新登录");
            return;
        }

        // === 5. 数据库连接 ===
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr))
        {
            WriteJson(context, false, "数据库连接配置错误");
            return;
        }

        // === 6. 保存缩略图（失败不影响主流程）===
        string wthumbnail = "";
        try
        {
            HttpPostedFile thumb = context.Request.Files["thumb"];
            if (thumb != null && thumb.ContentLength > 0)
            {
                string dir = "/homework/" + syear + "/" + sgrade + "/" + sclass + "/" + wcid + "/" + wmid;
                string physDir = context.Server.MapPath(dir);
                if (!Directory.Exists(physDir)) Directory.CreateDirectory(physDir);
                string fname = snum + "_" + wcid + "_" + wmid + "_km.png";
                thumb.SaveAs(Path.Combine(physDir, fname));
                wthumbnail = dir + "/" + fname;
            }
        }
        catch { /* 缩略图失败不影响主流程 */ }

        string wurl = "/homework/" + syear + "/" + sgrade + "/" + sclass + "/" + wcid + "/" + wmid +
                      "/" + snum + "_" + wcid + "_" + wmid + "_km.km";
        string wfilename = snum + "_" + wcid + "_" + wmid + "_km.km";

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 检查可选列是否存在（一次性）
                bool hasWlid       = ColumnExists(conn, "Works", "Wlid");
                bool hasWcode      = ColumnExists(conn, "Works", "Wcode");
                bool hasWthumbnail = ColumnExists(conn, "Works", "Wthumbnail");

                // === 7. 查找已有记录 ===
                int  existWid      = 0;
                bool alreadyGraded = false;
                {
                    string lookupSql;
                    if (hasWlid && wlid > 0)
                        lookupSql = "SELECT TOP 1 Wid, ISNULL(Wcheck,0) AS Wcheck FROM Works WHERE Wnum=@Wnum AND Wlid=@Wlid ORDER BY Wid DESC";
                    else if (wmid > 0)
                        lookupSql = "SELECT TOP 1 Wid, ISNULL(Wcheck,0) AS Wcheck FROM Works WHERE Wnum=@Wnum AND Wmid=@Wmid ORDER BY Wid DESC";
                    else
                        lookupSql = "SELECT TOP 1 Wid, ISNULL(Wcheck,0) AS Wcheck FROM Works WHERE Wnum=@Wnum AND Wcid=@Wcid ORDER BY Wid DESC";

                    using (SqlCommand cmd = new SqlCommand(lookupSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Wnum", snum);
                        if (hasWlid && wlid > 0) cmd.Parameters.AddWithValue("@Wlid", wlid);
                        else if (wmid > 0)        cmd.Parameters.AddWithValue("@Wmid", wmid);
                        else                      cmd.Parameters.AddWithValue("@Wcid", wcid);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                existWid = r["Wid"] != DBNull.Value ? Convert.ToInt32(r["Wid"]) : 0;
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
                    // === 8a. UPDATE ===
                    StringBuilder updCols = new StringBuilder(
                        "Wurl=@Wurl, Wfilename=@Wfilename, Wlength=@Wlength, Wdate=@Wdate, Wself=@Wself");
                    if (hasWcode) updCols.Append(", Wcode=@Wcode");
                    if (hasWthumbnail && wthumbnail != "") updCols.Append(", Wthumbnail=@Wthumbnail");

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Works SET " + updCols + " WHERE Wid=@Wid", conn))
                    {
                        cmd.Parameters.AddWithValue("@Wurl",      wurl);
                        cmd.Parameters.AddWithValue("@Wfilename", wfilename);
                        cmd.Parameters.AddWithValue("@Wlength",   kmJson.Length);
                        cmd.Parameters.AddWithValue("@Wdate",     now);
                        cmd.Parameters.AddWithValue("@Wself",     title);
                        if (hasWcode) cmd.Parameters.AddWithValue("@Wcode", kmJson);
                        if (hasWthumbnail && wthumbnail != "")
                            cmd.Parameters.AddWithValue("@Wthumbnail", wthumbnail);
                        cmd.Parameters.AddWithValue("@Wid", existWid);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // === 8b. INSERT ===
                    StringBuilder cols = new StringBuilder(
                        "Wnum,Wcid,Wmid,Wmsort,Wfilename,Wtype,Wurl,Wlength,Wdate,Wip,Wtime,Wcan,Wgrade,Wclass,Wyear,Wterm,Wsid,Wname,Wself");
                    StringBuilder vals = new StringBuilder(
                        "@Wnum,@Wcid,@Wmid,@Wmsort,@Wfilename,@Wtype,@Wurl,@Wlength,@Wdate,@Wip,@Wtime,@Wcan,@Wgrade,@Wclass,@Wyear,@Wterm,@Wsid,@Wname,@Wself");

                    if (hasWlid)                           { cols.Append(",Wlid");       vals.Append(",@Wlid"); }
                    if (hasWcode)                          { cols.Append(",Wcode");      vals.Append(",@Wcode"); }
                    if (hasWthumbnail && wthumbnail != "") { cols.Append(",Wthumbnail"); vals.Append(",@Wthumbnail"); }

                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Works (" + cols + ") VALUES (" + vals + ")", conn))
                    {
                        cmd.Parameters.AddWithValue("@Wnum",      snum);
                        cmd.Parameters.AddWithValue("@Wcid",      wcid);
                        cmd.Parameters.AddWithValue("@Wmid",      wmid);
                        cmd.Parameters.AddWithValue("@Wmsort",    15);    // 15 = km
                        cmd.Parameters.AddWithValue("@Wfilename", wfilename);
                        cmd.Parameters.AddWithValue("@Wtype",     "km");
                        cmd.Parameters.AddWithValue("@Wurl",      wurl);
                        cmd.Parameters.AddWithValue("@Wlength",   kmJson.Length);
                        cmd.Parameters.AddWithValue("@Wdate",     now);
                        cmd.Parameters.AddWithValue("@Wip",       sip);
                        cmd.Parameters.AddWithValue("@Wtime",     string.IsNullOrEmpty(stime) ? now.ToString() : stime);
                        cmd.Parameters.AddWithValue("@Wcan",      true);
                        cmd.Parameters.AddWithValue("@Wgrade",    sgrade);
                        cmd.Parameters.AddWithValue("@Wclass",    sclass);
                        cmd.Parameters.AddWithValue("@Wyear",     syear);
                        cmd.Parameters.AddWithValue("@Wterm",     sterm);
                        cmd.Parameters.AddWithValue("@Wsid",      sid);
                        cmd.Parameters.AddWithValue("@Wname",     sname);
                        cmd.Parameters.AddWithValue("@Wself",     title);
                        if (hasWlid) cmd.Parameters.AddWithValue("@Wlid",
                            wlid > 0 ? (object)wlid : (object)wmid);
                        if (hasWcode) cmd.Parameters.AddWithValue("@Wcode", kmJson);
                        if (hasWthumbnail && wthumbnail != "")
                            cmd.Parameters.AddWithValue("@Wthumbnail", wthumbnail);
                        cmd.ExecuteNonQuery();
                    }
                }

                WriteJson(context, true, "保存成功");
            }
        }
        catch (Exception ex)
        {
            string msg = "保存失败: " + ex.Message;
            if (debug) msg += " | " + ex.StackTrace;
            WriteJson(context, false, msg);
        }
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
