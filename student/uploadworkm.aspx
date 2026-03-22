<%@ page language="C#" autoeventwireup="true" validaterequest="false" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Web" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        // KindEditor upload handler - returns JSON
        Response.ContentType = "text/html";
        Response.ContentEncoding = System.Text.Encoding.UTF8;

        try
        {
            string lid = Request.QueryString["lid"];
            if (string.IsNullOrEmpty(lid))
            {
                WriteJson(1, "缺少任务参数");
                return;
            }

            int listId;
            if (!int.TryParse(lid, out listId))
            {
                WriteJson(1, "无效的任务参数");
                return;
            }

            // 获取学生信息
            string snum = "";
            string sname = "";
            string sid = "";
            string sclass = "";
            string sgrade = "";
            try
            {
                HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
                if (sc != null && !string.IsNullOrEmpty(sc.Value))
                {
                    string cookieVal = sc.Value;
                    if (cookieVal.Contains("%"))
                    {
                        try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); }
                        catch { }
                    }
                    Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                    if (ct != null)
                    {
                        object m = Activator.CreateInstance(ct);
                        System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                            System.Reflection.BindingFlags.Public |
                            System.Reflection.BindingFlags.NonPublic |
                            System.Reflection.BindingFlags.Instance);
                        if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                        System.Reflection.PropertyInfo pn;
                        pn = ct.GetProperty("Snum");
                        if (pn != null) { object v = pn.GetValue(m, null); if (v != null) snum = v.ToString(); }
                        pn = ct.GetProperty("Sname");
                        if (pn != null) { object v = pn.GetValue(m, null); if (v != null) sname = v.ToString(); }
                        pn = ct.GetProperty("Sid");
                        if (pn != null) { object v = pn.GetValue(m, null); if (v != null) sid = v.ToString(); }
                        pn = ct.GetProperty("Sclass");
                        if (pn != null) { object v = pn.GetValue(m, null); if (v != null) sclass = v.ToString(); }
                        pn = ct.GetProperty("Sgrade");
                        if (pn != null) { object v = pn.GetValue(m, null); if (v != null) sgrade = v.ToString(); }
                    }
                }
            }
            catch { }

            if (string.IsNullOrEmpty(snum))
            {
                WriteJson(1, "未登录或登录已过期，请重新登录");
                return;
            }

            // 检查文件
            if (Request.Files.Count == 0 || Request.Files[0] == null || Request.Files[0].ContentLength == 0)
            {
                WriteJson(1, "请选择要上传的文件");
                return;
            }

            HttpPostedFile file = Request.Files[0];

            // 文件大小限制 30MB
            if (file.ContentLength > 30 * 1024 * 1024)
            {
                WriteJson(1, "文件大小不能超过30MB");
                return;
            }

            // 获取文件扩展名
            string fileName = Path.GetFileName(file.FileName);
            string ext = Path.GetExtension(fileName).ToLower().TrimStart('.');
            string fileType = ext;

            // 获取任务信息
            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            string allowedType = "";
            int mcid = 0;
            int msort = 0;
            int wmid = 0;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT L.Lcid, M.Mid, M.Mfiletype, M.Msort
                    FROM Listmenu L
                    LEFT JOIN Mission M ON L.Lxid = M.Mid
                    WHERE L.Lid = @Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["Lcid"] != DBNull.Value) mcid = Convert.ToInt32(reader["Lcid"]);
                            if (reader["Mid"] != DBNull.Value) wmid = Convert.ToInt32(reader["Mid"]);
                            if (reader["Mfiletype"] != DBNull.Value) allowedType = reader["Mfiletype"].ToString();
                            if (reader["Msort"] != DBNull.Value) msort = Convert.ToInt32(reader["Msort"]);
                        }
                    }
                }

                // 验证文件类型
                if (!string.IsNullOrEmpty(allowedType) && allowedType != "*")
                {
                    string[] allowed = allowedType.ToLower().Split(new char[] { ',', '|', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    bool typeOk = false;
                    foreach (string a in allowed)
                    {
                        if (a.Trim() == ext || a.Trim() == "." + ext)
                        {
                            typeOk = true;
                            break;
                        }
                    }
                    if (!typeOk)
                    {
                        WriteJson(1, "只允许上传 " + allowedType + " 格式的文件");
                        return;
                    }
                }

                // 构建保存目录: ~/upload/works/lid/
                string relDir = "upload/works/" + listId + "/";
                string absDir = Server.MapPath("~/" + relDir);
                if (!Directory.Exists(absDir))
                    Directory.CreateDirectory(absDir);

                string saveFileName = snum + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "." + ext;
                string savePath = Path.Combine(absDir, saveFileName);
                file.SaveAs(savePath);

                string fileUrl = "../upload/works/" + listId + "/" + saveFileName;

                int wyear = DateTime.Now.Year;
                int wterm = DateTime.Now.Month >= 8 ? 1 : 2;

                // 检查是否已有作品记录
                int existingWid = 0;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 Wid FROM Works WHERE Wlid = @Lid AND Wnum = @Snum ORDER BY Wid DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    cmd.Parameters.AddWithValue("@Snum", snum);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        existingWid = Convert.ToInt32(result);
                }

                if (existingWid > 0)
                {
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE Works SET Wurl = @Wurl, Wfilename = @Wfilename, Wtype = @Wtype,
                            Wlength = @Wlength, Wdate = @Wdate, Wip = @Wip, Wtime = @Wtime
                        WHERE Wid = @Wid", conn))
                    {
                        cmd.Parameters.AddWithValue("@Wurl", fileUrl);
                        cmd.Parameters.AddWithValue("@Wfilename", fileName);
                        cmd.Parameters.AddWithValue("@Wtype", fileType);
                        cmd.Parameters.AddWithValue("@Wlength", file.ContentLength);
                        cmd.Parameters.AddWithValue("@Wdate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@Wip", Request.UserHostAddress ?? "");
                        cmd.Parameters.AddWithValue("@Wtime", DateTime.Now.ToString("HH:mm:ss"));
                        cmd.Parameters.AddWithValue("@Wid", existingWid);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO Works (Wnum, Wcid, Wmid, Wmsort, Wfilename, Wurl, Wlength,
                            Wdate, Wip, Wtime, Wtype, Wname, Wyear, Wterm, Wlid, Wsid, Wclass, Wgrade)
                        VALUES (@Wnum, @Wcid, @Wmid, @Wmsort, @Wfilename, @Wurl, @Wlength,
                            @Wdate, @Wip, @Wtime, @Wtype, @Wname, @Wyear, @Wterm, @Wlid, @Wsid, @Wclass, @Wgrade)", conn))
                    {
                        cmd.Parameters.AddWithValue("@Wnum", snum);
                        cmd.Parameters.AddWithValue("@Wcid", mcid);
                        cmd.Parameters.AddWithValue("@Wmid", wmid);
                        cmd.Parameters.AddWithValue("@Wmsort", msort);
                        cmd.Parameters.AddWithValue("@Wfilename", fileName);
                        cmd.Parameters.AddWithValue("@Wurl", fileUrl);
                        cmd.Parameters.AddWithValue("@Wlength", file.ContentLength);
                        cmd.Parameters.AddWithValue("@Wdate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@Wip", Request.UserHostAddress ?? "");
                        cmd.Parameters.AddWithValue("@Wtime", DateTime.Now.ToString("HH:mm:ss"));
                        cmd.Parameters.AddWithValue("@Wtype", fileType);
                        cmd.Parameters.AddWithValue("@Wname", sname);
                        cmd.Parameters.AddWithValue("@Wyear", wyear);
                        cmd.Parameters.AddWithValue("@Wterm", wterm);
                        cmd.Parameters.AddWithValue("@Wlid", listId);
                        cmd.Parameters.AddWithValue("@Wsid", string.IsNullOrEmpty(sid) ? (object)DBNull.Value : Convert.ToInt32(sid));
                        cmd.Parameters.AddWithValue("@Wclass", string.IsNullOrEmpty(sclass) ? (object)DBNull.Value : Convert.ToInt32(sclass));
                        cmd.Parameters.AddWithValue("@Wgrade", string.IsNullOrEmpty(sgrade) ? (object)DBNull.Value : Convert.ToInt32(sgrade));
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            WriteJson(0, "");
        }
        catch (Exception ex)
        {
            WriteJson(1, "上传失败: " + ex.Message);
        }
    }

    private void WriteJson(int error, string message)
    {
        string json;
        if (error == 0)
            json = "{\"error\":0}";
        else
            json = "{\"error\":1,\"message\":\"" + message.Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "") + "\"}";
        
        Response.Clear();
        Response.ContentType = "text/html";
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        Response.Write(json);
        Response.Flush();
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }
</script>
