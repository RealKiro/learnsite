<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_myinfo, LearnSite" %>

<script runat="server">
    protected int miSid = 0;
    protected int miGscore = 0;
    protected int miAllscore = 0;
    protected string miGroupLevelName = "见习组员";
    protected string miGroupLevelIcon = "🌱";
    protected int miGroupLevelNum = 1;
    protected string miCreditLevelName = "学习新手";
    protected string miCreditLevelIcon = "🌱";
    protected int miCreditLevelNum = 1;

    // 近日考试数据
    protected int miSgrade = 0;
    protected int miSclass = 0;
    protected System.Data.DataTable miExamDt = null;
    protected string miExcludeCidsJson = "[]";

    private string MiGetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                    cs = connField.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        MiLoadLevels();
        MiLoadExams();
        MiLoadEmail();
        MiLoadNewCourses(); // 修复：Chid不匹配时未学学案为空
        MiFilterArchivedCourses();
    }

    // 当编译的 shownew()因 Chid 过滤导致空结果时，改用不带 Chid 的备用查询
    private void MiLoadNewCourses()
    {
        if (GridViewnewkc.Rows.Count > 0) return; // 已有数据，无需修复
        if (miSgrade <= 0) return;

        int cterm = 0;
        try { int.TryParse(LearnSite.Common.XmlHelp.GetTerm(), out cterm); } catch { }
        if (cterm <= 0) return;

        string connStr = MiGetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        string cids = LabelCids.Text.Trim();

        string sql = "SELECT Cid, Ctitle, CONVERT(nvarchar(10), Cdate, 120) AS Cdate " +
                     "FROM Courses WHERE Cobj=@grade AND Cterm=@term " +
                     "AND ISNULL(Cpublish,0)=1 AND ISNULL(Cdelete,0)=0 AND ISNULL(Cold,0)=0";
        if (!string.IsNullOrEmpty(cids))
            sql += " AND Cid NOT IN (" + cids + ")";
        sql += " ORDER BY Cdate DESC, Cid DESC";

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@grade", miSgrade);
                    cmd.Parameters.AddWithValue("@term", cterm);
                    System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable();
                    da.Fill(dt);
                    if (dt.Rows.Count > 0)
                    {
                        GridViewnewkc.DataSource = dt;
                        GridViewnewkc.DataBind();
                    }
                }
            }
        }
        catch { }
    }

    // ========== 过滤已归档/已删除学案 ==========
    private void MiFilterArchivedCourses()
    {
        string connStr = MiGetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        System.Collections.Generic.Dictionary<int,bool> excludeCids = new System.Collections.Generic.Dictionary<int,bool>();
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Cid FROM Courses WHERE ISNULL(Cold,0)<>0 OR ISNULL(Cdelete,0)<>0", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int cid;
                            if (int.TryParse(reader["Cid"].ToString(), out cid))
                                excludeCids[cid] = true;
                        }
                    }
                }
            }
        }
        catch { return; }

        if (excludeCids.Count == 0) return;

        // 保存以便 JS 备用
        System.Text.StringBuilder sb = new System.Text.StringBuilder("[");
        bool first = true;
        foreach (int c in excludeCids.Keys)
        {
            if (!first) sb.Append(',');
            sb.Append(c);
            first = false;
        }
        sb.Append(']');
        miExcludeCidsJson = sb.ToString();

        MiFilterGridViewDS(GridViewnewkc, "cid", excludeCids);
        MiFilterGridViewDS(GridViewdonekc, "Cid", excludeCids);
    }

    private void MiFilterGridViewDS(System.Web.UI.WebControls.GridView gv, string cidCol,
        System.Collections.Generic.Dictionary<int,bool> excludeCids)
    {
        if (gv == null) return;

        System.Data.DataTable dt = null;
        if (gv.DataSource is System.Data.DataView)
            dt = ((System.Data.DataView)gv.DataSource).Table;
        else if (gv.DataSource is System.Data.DataTable)
            dt = (System.Data.DataTable)gv.DataSource;
        else if (gv.DataSource is System.Data.DataSet)
        {
            System.Data.DataSet ds = (System.Data.DataSet)gv.DataSource;
            if (ds.Tables.Count > 0) dt = ds.Tables[0];
        }

        if (dt == null || !dt.Columns.Contains(cidCol)) return;

        // 构建过滤后的数据表
        System.Data.DataTable filtered = dt.Clone();
        foreach (System.Data.DataRow row in dt.Rows)
        {
            int cid;
            if (!int.TryParse(row[cidCol].ToString(), out cid) || !excludeCids.ContainsKey(cid))
                filtered.ImportRow(row);
        }

        if (filtered.Rows.Count == dt.Rows.Count) return; // 无需过滤

        // 调整页码防止越界
        int maxPage = gv.PageSize > 0
            ? (int)Math.Ceiling((double)filtered.Rows.Count / gv.PageSize) - 1
            : 0;
        if (maxPage < 0) maxPage = 0;
        if (gv.PageIndex > maxPage) gv.PageIndex = maxPage;

        gv.DataSource = filtered;
        gv.DataBind();
    }

    private void MiLoadEmail()
    {
        if (miSid <= 0) return;
        string connStr = MiGetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Semail FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", miSid);
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string email = reader["Semail"] != DBNull.Value ? reader["Semail"].ToString() : "";
                            if (!string.IsNullOrEmpty(email))
                            {
                                semail.Text = email;
                            }
                            else
                            {
                                semail.Text = "未绑定";
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }

    private void MiLoadLevels()
    {
        // 从 Cookie 获取 Sid
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
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
                        if (v != null) int.TryParse(v.ToString(), out miSid);
                    }
                    // 获取年级和班级
                    System.Reflection.PropertyInfo pGrade = ct.GetProperty("Sgrade");
                    if (pGrade != null)
                    {
                        object vg = pGrade.GetValue(m, null);
                        if (vg != null) int.TryParse(vg.ToString(), out miSgrade);
                    }
                    System.Reflection.PropertyInfo pClass = ct.GetProperty("Sclass");
                    if (pClass != null)
                    {
                        object vc = pClass.GetValue(m, null);
                        if (vc != null) int.TryParse(vc.ToString(), out miSclass);
                    }
                }
            }
        }
        catch { }

        if (miSid <= 0) return;
        string connStr = MiGetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Sgscore,0), ISNULL(Sallscore,0) FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", miSid);
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            miGscore = reader.GetInt32(0);
                            miAllscore = reader.GetInt32(1);
                        }
                    }
                }
            }
        }
        catch { }

        // 从XML配置计算小组等级
        MiCalcLevelFromXml(Server.MapPath("~/App_Data/grouplevel.xml"), miGscore,
            ref miGroupLevelName, ref miGroupLevelIcon, ref miGroupLevelNum,
            "见习组员", "🌱");

        // 从XML配置计算学分等级
        MiCalcLevelFromXml(Server.MapPath("~/App_Data/creditlevel.xml"), miAllscore,
            ref miCreditLevelName, ref miCreditLevelIcon, ref miCreditLevelNum,
            "学习新手", "🌱");
    }

    private void MiCalcLevelFromXml(string xmlPath, int score,
        ref string levelName, ref string levelIcon, ref int levelNum,
        string defaultName, string defaultIcon)
    {
        try
        {
            if (System.IO.File.Exists(xmlPath))
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(xmlPath);
                System.Xml.XmlNodeList nodes = doc.SelectNodes("//levels/level");
                if (nodes != null && nodes.Count > 0)
                {
                    string matchedName = "";
                    string matchedIcon = "";
                    int matchedNum = 1;
                    for (int i = nodes.Count - 1; i >= 0; i--)
                    {
                        System.Xml.XmlNode node = nodes[i];
                        int threshold = 0;
                        if (node.Attributes["threshold"] != null)
                            int.TryParse(node.Attributes["threshold"].Value, out threshold);
                        if (score >= threshold)
                        {
                            matchedName = node.Attributes["name"] != null ? node.Attributes["name"].Value : defaultName;
                            matchedIcon = node.Attributes["icon"] != null ? node.Attributes["icon"].Value : defaultIcon;
                            matchedNum = i + 1;
                            break;
                        }
                    }
                    if (!string.IsNullOrEmpty(matchedName))
                    {
                        levelName = matchedName;
                        levelIcon = matchedIcon;
                        levelNum = matchedNum;
                        return;
                    }
                    System.Xml.XmlNode first = nodes[0];
                    levelName = first.Attributes["name"] != null ? first.Attributes["name"].Value : defaultName;
                    levelIcon = first.Attributes["icon"] != null ? first.Attributes["icon"].Value : defaultIcon;
                    levelNum = 1;
                    return;
                }
            }
        }
        catch { }
        MiCalcLevelDefault(score, ref levelName, ref levelIcon, ref levelNum, xmlPath.Contains("grouplevel"));
    }

    private void MiCalcLevelDefault(int score, ref string name, ref string icon, ref int num, bool isGroup)
    {
        if (isGroup)
        {
            if (score >= 150) { name = "明星组员"; icon = "👑"; num = 6; }
            else if (score >= 100) { name = "资深组员"; icon = "💎"; num = 5; }
            else if (score >= 60) { name = "高级组员"; icon = "🌟"; num = 4; }
            else if (score >= 30) { name = "中级组员"; icon = "⭐"; num = 3; }
            else if (score >= 10) { name = "初级组员"; icon = "🌿"; num = 2; }
            else { name = "见习组员"; icon = "🌱"; num = 1; }
        }
        else
        {
            if (score >= 350) { name = "学习大师"; icon = "👑"; num = 6; }
            else if (score >= 200) { name = "学习精英"; icon = "🏆"; num = 5; }
            else if (score >= 100) { name = "学习达人"; icon = "🌟"; num = 4; }
            else if (score >= 50) { name = "优秀学子"; icon = "🌳"; num = 3; }
            else if (score >= 20) { name = "勤奋学生"; icon = "🌿"; num = 2; }
            else { name = "学习新手"; icon = "🌱"; num = 1; }
        }
    }

    protected string MiRenderIcon(string icon)
    {
        if (string.IsNullOrEmpty(icon)) return "";
        if (icon.Contains("/") || icon.Contains(".png") || icon.Contains(".jpg") || icon.Contains(".gif") || icon.Contains(".svg") || icon.Contains(".webp"))
            return "<img src=\"" + icon + "\" style=\"width:16px;height:16px;object-fit:contain;vertical-align:middle;\" />";
        return Server.HtmlEncode(icon);
    }

    // ========== 近日考试 ==========
    private void MiLoadExams()
    {
        if (miSgrade <= 0 || miSclass <= 0) return;
        string connStr = MiGetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        try
        {
            // 先检查 ExamPublish 表是否存在
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='ExamPublish' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0) return;
                }
                // 查询该年级该班级的有效考试（状态=1，结束时间未过期或近7天内的）
                string sql = @"SELECT ep.Eid, ep.Epid, ep.Estart, ep.Eend, ep.Estatus,
                    ISNULL(p.Ptitle,'[未知试卷]') AS Ptitle, ISNULL(p.Pcount,0) AS Pcount,
                    ISNULL(p.Ptime,0) AS Ptime, ISNULL(p.Pscore,0) AS Pscore
                    FROM ExamPublish ep LEFT JOIN Paper p ON ep.Epid=p.Pid
                    WHERE ep.Egrade=@grade AND ep.Eclass=@cls AND ep.Estatus=1
                    AND ep.Eend >= DATEADD(DAY,-7,GETDATE())
                    ORDER BY ep.Estart DESC";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@grade", miSgrade);
                da.SelectCommand.Parameters.AddWithValue("@cls", miSclass);
                miExamDt = new System.Data.DataTable();
                da.Fill(miExamDt);
            }
        }
        catch { }
    }

    protected string MiGetExamStatus(object startObj, object endObj)
    {
        DateTime now = DateTime.Now;
        if (startObj != null && startObj != DBNull.Value && endObj != null && endObj != DBNull.Value)
        {
            DateTime start = Convert.ToDateTime(startObj);
            DateTime end = Convert.ToDateTime(endObj);
            if (now < start) return "未开始";
            if (now > end) return "已结束";
            return "考试中";
        }
        return "未知";
    }

    protected string MiGetExamStatusClass(object startObj, object endObj)
    {
        string ts = MiGetExamStatus(startObj, endObj);
        switch (ts)
        {
            case "考试中": return "mi-exam-active";
            case "未开始": return "mi-exam-pending";
            case "已结束": return "mi-exam-ended";
            default: return "mi-exam-pending";
        }
    }

    protected string MiFormatTime(object dateVal)
    {
        if (dateVal == null || dateVal == DBNull.Value) return "";
        try { return Convert.ToDateTime(dateVal).ToString("MM-dd HH:mm"); } catch { return ""; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* === 覆盖Student主题冲突 === */
    .mi-page, .mi-page * { margin-right: unset !important; margin-left: unset !important; }
    .mi-page .onlinediv {
        border: none !important; width: auto !important; height: auto !important;
        vertical-align: top !important;
    }
    .mi-page .onlinebg { background-color: transparent !important; }
    .mi-page .pagediv {
        font-size: 12px !important; width: auto !important; height: auto !important;
        text-align: left !important;
    }
    .mi-page .buttonimg, .mi-page .buttonnone {
        background-image: none !important; border-width: 0 !important;
        width: auto !important; height: auto !important;
    }
    .mi-sidebar {
        position: static !important; width: auto !important;
        top: auto !important; right: auto !important;
        z-index: auto !important; background: none !important;
    }
    .mi-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .mi-page table[cellpadding] { border: none !important; }

    /* === 页面布局 === */
    .mi-page {
        width: 100%; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: miFadeIn .4s ease;
    }
    @keyframes miFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    .mi-grid { display: grid !important; grid-template-columns: 1fr 320px; gap: 24px; }
    @media(max-width:900px) { .mi-grid { grid-template-columns: 1fr !important; } }

    /* === 卡片 === */
    .mi-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        margin-bottom: 22px; overflow: hidden;
        transition: transform .2s ease, box-shadow .2s ease;
    }
    .mi-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04);
    }
    .mi-card-head {
        padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
        background: #fff !important;
    }
    .mi-card-head .mi-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .mi-head-icon-new { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .mi-head-icon-new svg { stroke: #d97706 !important; }
    .mi-head-icon-done { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .mi-head-icon-done svg { stroke: #059669 !important; }
    .mi-head-icon-online { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .mi-head-icon-online svg { stroke: #2563eb !important; }
    .mi-head-icon-info { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .mi-head-icon-info svg { stroke: #7c3aed !important; }
    .mi-card-head .mi-head-icon svg {
        width: 18px; height: 18px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .mi-card-head h3 {
        font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important;
        display: flex !important; align-items: center; gap: 8px; flex: 1;
    }
    .mi-card-head h3 svg { display: none; }
    .mi-card-body { padding: 4px 6px 6px; }

    /* === GridView 美化 === */
    .mi-card-body table {
        width: 100% !important; border-collapse: collapse !important;
        border-spacing: 0 !important; border: none !important;
    }
    .mi-page .mi-card-body table th,
    .mi-card-body table th {
        padding: 12px 20px !important; font-size: 12px !important; font-weight: 600 !important;
        color: #64748b !important; text-align: left !important;
        letter-spacing: .3px;
        background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important;
        border-top: none !important; border-left: none !important; border-right: none !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
    }
    .mi-page .mi-card-body table td,
    .mi-card-body table td {
        padding: 12px 20px !important; font-size: 13px !important; color: #334155 !important;
        border-bottom: 1px solid #f1f5f9 !important;
        border-top: none !important; border-left: none !important; border-right: none !important;
        background-color: #fff !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        white-space: nowrap !important;
        vertical-align: middle !important;
    }
    /* 嵌套进度条表格单元格 - 不覆盖原始颜色 */
    .mi-card-body td > table,
    .mi-card-body td > table td {
        background-color: transparent !important;
        background: none !important;
        padding: 0 !important;
        border: none !important;
        border-bottom: none !important;
        white-space: normal !important;
        font-size: 0 !important;
        min-width: 0 !important;
        width: auto !important;
        height: 8px !important;
    }
    .mi-page .mi-card-body table td:nth-child(3),
    .mi-card-body table td:nth-child(3) {
        white-space: normal !important;
    }
    /* 日期列不换行 */
    .mi-page .mi-card-body table td:last-child,
    .mi-card-body table td:last-child {
        white-space: nowrap !important;
        min-width: 90px !important;
    }
    .mi-page .mi-card-body table tr,
    .mi-card-body table tr {
        transition: all .15s ease;
        background-color: #fff !important; background: #fff !important;
        font-size: 13px !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
    }
    /* 覆盖 PagerStyle 内联样式 */
    .mi-page .mi-card-body table tr[style*='WhiteSmoke'],
    .mi-card-body table tr[align='center'] {
        background-color: #fff !important;
    }
    .mi-page .mi-card-body table tr:hover td,
    .mi-card-body table tr:hover td {
        background-color: #f8faff !important;
    }
    .mi-card-body table tr:last-child td { border-bottom: none !important; }

    /* === 进度条新样式 === */
    .mi-card:nth-child(2) .mi-card-body table td:nth-child(3),
    .mi-card-body table td:nth-child(3) {
        padding: 10px 20px !important;
        min-width: 260px !important;
        vertical-align: middle !important;
        white-space: normal !important;
        overflow: visible !important;
        position: relative !important;
    }
    .mi-card-body table td.mi-progress-cell {
        padding: 10px 20px !important;
        overflow: visible !important;
    }

    /* 进度条整体容器 */
    .mi-progress {
        display: flex !important;
        align-items: center !important;
        gap: 12px !important;
        min-height: 32px !important;
    }

    /* 进度条轨道 */
    .mi-progress-track {
        position: relative;
        flex: 1 1 0;
        height: 22px;
        border-radius: 12px;
        background: #f1f5f9;
        overflow: hidden;
        box-shadow: inset 0 1px 3px rgba(0,0,0,.06);
    }
    .mi-progress-track-inner {
        position: absolute;
        left: 0; top: 0; height: 100%;
        border-radius: 12px;
        background: linear-gradient(90deg, #22c55e 0%, #4ade80 100%);
        width: 0;
        transition: width .6s cubic-bezier(.4,0,.2,1);
        box-shadow: 0 2px 6px rgba(34,197,94,.3);
    }
    /* 进度条内百分比文字 */
    .mi-progress-track-text {
        position: absolute;
        left: 0; top: 0; right: 0; bottom: 0;
        display: flex !important;
        align-items: center;
        justify-content: center;
        font-size: 11px;
        font-weight: 700;
        color: #334155;
        z-index: 1;
        letter-spacing: .3px;
        pointer-events: none;
    }
    /* 进度高时文字变白 */
    .mi-progress-track.mi-track-high .mi-progress-track-text {
        color: #fff;
        text-shadow: 0 1px 2px rgba(0,0,0,.2);
    }

    /* 右侧百分比徽标 */
    .mi-progress-badge {
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        min-width: 52px;
        height: 26px;
        padding: 0 10px;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: .3px;
        flex-shrink: 0;
        white-space: nowrap !important;
        line-height: 26px;
    }
    .mi-progress-badge.mi-badge-green {
        background: linear-gradient(135deg, #dcfce7, #bbf7d0);
        color: #15803d;
        border: 1px solid #86efac;
    }
    .mi-progress-badge.mi-badge-yellow {
        background: linear-gradient(135deg, #fef9c3, #fef08a);
        color: #a16207;
        border: 1px solid #fde047;
    }
    .mi-progress-badge.mi-badge-red {
        background: linear-gradient(135deg, #fef2f2, #fecaca);
        color: #b91c1c;
        border: 1px solid #fca5a5;
    }
    .mi-progress-badge.mi-badge-full {
        background: linear-gradient(135deg, #22c55e, #16a34a);
        color: #fff;
        border: 1px solid #16a34a;
        box-shadow: 0 2px 6px rgba(22,163,74,.3);
    }

    /* 隐藏旧的 segments / label（不再使用） */
    .mi-progress-segments,
    .mi-progress-label,
    .mi-progress-dot { display: none !important; }

    .mi-card-body table tr:hover td.mi-progress-cell .mi-progress-track-inner {
        box-shadow: 0 2px 10px rgba(34,197,94,.4);
    }

    /* 叶子/果实图标隐藏，用CSS圆形标记替代 */
    .mi-card-body table td img[src*='leaf'],
    .mi-card-body table td img[src*='fruit'] {
        display: none !important;
    }
    .mi-card-body table td:first-child {
        position: relative;
        width: 20px !important; min-width: 20px !important;
        padding-left: 24px !important; padding-right: 4px !important;
    }
    /* 未学学案圆点标记 */
    .mi-card:nth-child(1) table td:first-child::after {
        content: ''; position: absolute; left: 20px; top: 50%; transform: translateY(-50%);
        width: 8px; height: 8px; border-radius: 50%;
        background: #f59e0b;
    }
    /* 未学第一行 = 本节课学案，特殊高亮 */
    .mi-card:nth-child(1) table tbody tr:first-child td {
        background-color: #fffbeb !important;
    }
    .mi-card:nth-child(1) table tbody tr:first-child td:first-child::after {
        width: 10px; height: 10px;
        background: linear-gradient(135deg, #f59e0b, #ef4444);
        box-shadow: 0 0 0 3px rgba(245,158,11,.2);
    }
    .mi-card:nth-child(1) table tbody tr:first-child td:nth-child(3) a::after {
        content: '本节课'; display: inline-block; margin-left: 8px;
        font-size: 10px; font-weight: 700; color: #fff;
        background: linear-gradient(135deg, #f59e0b, #ef4444);
        padding: 1px 8px; border-radius: 10px;
        vertical-align: middle; letter-spacing: .5px;
    }
    /* 已学学案圆点标记 */
    .mi-card:nth-child(2) table td:first-child::after {
        content: ''; position: absolute; left: 20px; top: 50%; transform: translateY(-50%);
        width: 8px; height: 8px; border-radius: 50%;
        background: #10b981;
    }

    .mi-card-body table a {
        color: #4f46e5 !important; text-decoration: none !important; font-weight: 600;
        transition: color .12s; font-size: 13px !important;
    }
    .mi-card-body table a:hover { color: #818cf8 !important; text-decoration: none !important; }
    .mi-card-body .pagediv {
        padding: 12px 20px 8px !important; font-size: 12px !important; color: #94a3b8 !important;
        display: flex !important; align-items: center; gap: 6px; flex-wrap: wrap;
        border-top: 1px solid #f1f5f9 !important;
        background: #fff !important;
    }
    .mi-card-body .pagediv a {
        color: #6366f1 !important; text-decoration: none !important; font-size: 12px !important;
        padding: 4px 10px; border-radius: 6px; transition: all .12s;
    }
    .mi-card-body .pagediv a:hover { background: #eef2ff !important; text-decoration: none !important; }

    /* === 签到列表 === */
    .mi-card-body .onlinediv {
        display: inline-flex !important; flex-direction: row; align-items: center;
        padding: 8px 12px 8px 10px !important; border-radius: 40px !important; transition: all .2s;
        border: 1px solid #e2e8f0 !important; width: auto !important; height: auto !important;
        background: #fff !important; margin: 4px 3px !important; gap: 6px;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
    }
    .mi-card-body .onlinediv:hover {
        background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
        border-color: #a5b4fc !important;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(99,102,241,.12);
    }
    /* 隐藏旗子图标 */
    .mi-card-body .onlinediv img { display: none !important; }
    /* 名字前加圆形头像占位 */
    .mi-card-body .onlinebg {
        background-color: transparent !important;
        position: relative;
        padding-left: 24px !important;
    }
    .mi-card-body .onlinebg::before {
        content: '';
        position: absolute; left: 0; top: 50%; transform: translateY(-50%);
        width: 20px; height: 20px; border-radius: 50%;
        background: linear-gradient(135deg, #6366f1, #a78bfa);
        display: flex; align-items: center; justify-content: center;
    }
    .mi-card-body .onlinebg::after {
        content: '';
        position: absolute; left: 5px; top: 50%; transform: translateY(-50%);
        width: 10px; height: 10px;
        background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'/%3E%3Ccircle cx='12' cy='7' r='4'/%3E%3C/svg%3E") no-repeat center / contain;
    }
    .mi-card-body .onlinebg a {
        color: #1e293b !important; font-size: 12px !important; font-weight: 600;
        text-decoration: none !important; letter-spacing: .2px;
    }
    .mi-card-body .onlinediv:hover .onlinebg a {
        color: #4338ca !important;
    }
    .mi-card-body .onlinediv span[id$='Labeltime'] {
        color: #94a3b8 !important; font-size: 10px !important; margin-top: 0;
        font-family: 'Segoe UI', Arial, sans-serif !important;
        background: #f1f5f9; padding: 2px 6px; border-radius: 10px;
        display: inline-block !important; min-width: 58px !important; width: 58px !important;
        text-align: center !important; box-sizing: border-box !important;
    }
    .mi-card-body .onlinediv:hover span[id$='Labeltime'] {
        background: rgba(99,102,241,.1); color: #6366f1 !important;
    }
    .mi-card-body [id$='DataListonline'] {
        width: auto !important;
        margin: 0 auto !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
    }
    .mi-card-body [id$='DataListonline'] > tbody {
        display: block !important;
    }
    .mi-card-body [id$='DataListonline'] > tbody > tr {
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        align-items: center !important;
        gap: 10px !important;
    }
    .mi-card-body [id$='DataListonline'] > tbody > tr > td {
        width: auto !important;
        min-width: 0 !important;
        padding: 0 !important;
        border: none !important;
        background: transparent !important;
        flex: 0 0 auto !important;
        vertical-align: top !important;
    }
    .mi-card-body [id$='DataListonline'] .onlinediv {
        min-width: 0 !important;
        margin: 0 !important;
    }
    @media (max-width: 900px) {
        .mi-card-body [id$='DataListonline'] > tbody > tr {
            justify-content: flex-start !important;
        }
    }

/* === 右侧侧边栏 === */
    .mi-sidebar {
        display: flex !important; flex-direction: column; gap: 20px;
        position: static !important; background: none !important;
    }

    /* === 个人信息卡片 - 全新学习名片样式 === */
    .mi-profile {
        background: rgba(255,255,255,.96) !important; border-radius: 28px; border: 1px solid #e2e8f0 !important;
        box-shadow: 0 18px 38px rgba(15,23,42,.07); overflow: hidden;
        transition: transform .22s ease, box-shadow .22s ease;
    }
    .mi-profile:hover {
        transform: translateY(-3px);
        box-shadow: 0 24px 44px rgba(15,23,42,.10);
    }
    .mi-profile-top {
        position: relative; overflow: hidden;
        padding: 26px 24px 22px !important;
        background:
            radial-gradient(circle at top right, rgba(244,114,182,.14), transparent 28%),
            radial-gradient(circle at bottom left, rgba(59,130,246,.16), transparent 30%),
            linear-gradient(145deg, #fff7ed 0%, #eff6ff 48%, #ecfeff 100%) !important;
        border-bottom: 1px solid rgba(226,232,240,.95);
    }
    .mi-profile-deco {
        position: absolute; right: -24px; top: -28px;
        width: 138px; height: 138px; border-radius: 32px;
        background: linear-gradient(135deg, rgba(255,255,255,.52), rgba(255,255,255,.08));
        transform: rotate(18deg);
        pointer-events: none;
    }
    .mi-profile-deco2 {
        top: auto !important; right: auto !important; left: -36px; bottom: -54px;
        width: 116px; height: 116px; border-radius: 28px;
        background: linear-gradient(135deg, rgba(255,255,255,.44), rgba(255,255,255,.04)) !important;
        transform: rotate(-14deg);
    }
    .mi-profile-top-grid {
        position: relative; z-index: 1;
        display: grid; grid-template-columns: 1fr; gap: 18px; align-items: start; justify-items: center; text-align: center;
    }
    .mi-profile-visual {
        display: flex; flex-direction: column; align-items: center; gap: 12px;
    }
    .mi-profile-avatar-wrap {
        position: relative; display: inline-flex; align-items: center; justify-content: center;
        width: 118px; height: 118px; padding: 8px;
        border-radius: 32px;
        background: linear-gradient(135deg, rgba(255,255,255,.96), rgba(255,255,255,.62));
        box-shadow: 0 18px 34px rgba(59,130,246,.14), inset 0 1px 0 rgba(255,255,255,.9);
    }
    .mi-profile-avatar-wrap:before {
        content: ""; position: absolute; inset: 6px;
        border-radius: 26px; border: 1px dashed rgba(99,102,241,.22);
        pointer-events: none;
    }
    .mi-profile-avatar {
        width: 100% !important; height: 100% !important; border-radius: 24px !important;
        border: 1px solid rgba(191,219,254,.88) !important;
        overflow: hidden; background: linear-gradient(180deg, #f8fbff 0%, #eef2ff 100%);
        position: relative;
    }
    .mi-profile-avatar img {
        width: 100% !important; height: 100% !important; object-fit: cover !important;
        max-width: none !important; max-height: none !important; display: block !important;
    }
    .mi-profile-copy { display: grid; gap: 12px; min-width: 0; width: 100%; align-content: start; justify-items: center; }
    .mi-profile-kicker {
        display: inline-flex; align-items: center; justify-content: center; width: fit-content;
        padding: 8px 12px; border-radius: 999px;
        background: rgba(255,255,255,.84); border: 1px solid rgba(191,219,254,.95);
        font-size: 12px; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; color: #2563eb;
    }
    .mi-profile-title {
        margin: 0; font-size: 27px; line-height: 1.1; font-weight: 800; color: #0f172a;
    }
    .mi-profile-sub {
        margin: 0; max-width: 28rem; font-size: 13px; line-height: 1.8; color: #475569;
    }
    .mi-profile-rank {
        position: relative; z-index: 1;
        display: none !important; align-items: center; justify-content: center; gap: 8px;
        min-height: 32px; padding: 7px 12px; border-radius: 999px;
        background: rgba(255,255,255,.78); border: 1px solid rgba(191,219,254,.95);
        color: #1d4ed8; font-size: 12px; font-weight: 700;
        backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
    }
    .mi-profile-rank.has-rank { display: none !important; }
    .mi-profile-rank img {
        max-height: 24px; vertical-align: middle;
        filter: drop-shadow(0 2px 6px rgba(59,130,246,.16));
        transition: transform .15s;
        display: block !important;
    }
    .mi-profile-rank img:hover { transform: scale(1.08); }
    .mi-profile-glance {
        display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 10px; width: 100%;
    }
    .mi-profile-glance-item {
        display: flex; flex-direction: column; gap: 4px;
        padding: 12px 14px; border-radius: 18px;
        background: rgba(255,255,255,.82); border: 1px solid rgba(219,234,254,.95);
        box-shadow: 0 10px 22px rgba(15,23,42,.04);
    }
    .mi-profile-glance-item em {
        font-style: normal; font-size: 11px; font-weight: 700; letter-spacing: .08em;
        text-transform: uppercase; color: #64748b;
    }
    .mi-profile-glance-item strong {
        font-size: 21px; line-height: 1; color: #0f172a; font-weight: 800;
    }

    /* 等级徽章 */
    .mi-level-badges {
        display: grid !important; grid-template-columns: 1fr;
        gap: 10px; position: relative; z-index: 1; margin-top: 2px; width: 100%;
    }
    .mi-level-badge {
        display: inline-flex !important; align-items: center; gap: 10px;
        padding: 10px 14px; border-radius: 18px;
        font-size: 12px; font-weight: 700;
        transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
        cursor: pointer; text-decoration: none !important; line-height: 1.4;
        border: 1px solid rgba(255,255,255,.85);
        box-shadow: 0 10px 20px rgba(15,23,42,.06);
        min-width: 0; width: 100%; justify-content: flex-start;
    }
    .mi-level-badge:hover {
        transform: translateY(-2px);
        box-shadow: 0 14px 24px rgba(15,23,42,.10);
    }
    .mi-level-badge-icon {
        width: 30px; height: 30px; border-radius: 10px;
        display: inline-flex; align-items: center; justify-content: center;
        background: rgba(255,255,255,.36); font-size: 16px; line-height: 1; flex-shrink: 0;
    }
    .mi-level-badge-icon img {
        width: 16px !important; height: 16px !important; object-fit: contain !important; display: block;
    }
    .mi-level-badge-text {
        display: flex; flex-direction: column; line-height: 1.18; min-width: 0;
    }
    .mi-level-badge-label {
        font-size: 10px; font-weight: 700; opacity: .78; letter-spacing: .08em; text-transform: uppercase;
    }
    .mi-level-badge-value {
        font-size: 14px; font-weight: 800; white-space: normal; overflow: visible;
        text-overflow: clip; word-break: keep-all; overflow-wrap: normal; line-height: 1.45;
    }
    .mi-level-badge-group {
        background: linear-gradient(135deg, #34d399, #0f766e);
        color: #fff;
    }
    .mi-level-badge-group:hover {
        color: #fff !important;
    }
    .mi-level-badge-credit {
        background: linear-gradient(135deg, #f59e0b, #ea580c);
        color: #fff;
    }
    .mi-level-badge-credit:hover {
        color: #fff !important;
    }

    .mi-profile-body { padding: 18px 18px 18px; background: linear-gradient(180deg,#ffffff 0,#f8fbff 100%); }
    .mi-info-grid { display: grid; gap: 12px; }
    .mi-info-row {
        display: grid !important; grid-template-columns: 40px minmax(0,1fr);
        grid-template-areas:
            "icon label"
            "icon value";
        align-items: start; column-gap: 12px; row-gap: 4px;
        padding: 14px 16px !important; border-radius: 18px; margin: 0;
        transition: transform .15s, box-shadow .15s, border-color .15s;
        border: 1px solid #e2e8f0 !important;
        background: linear-gradient(180deg,#fff 0,#f8fafc 100%);
    }
    .mi-info-row:hover {
        transform: translateY(-1px);
        box-shadow: 0 12px 22px rgba(15,23,42,.05);
        border-color: #dbe7f0 !important;
    }
    .mi-info-icon {
        width: 40px; height: 40px; border-radius: 14px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0; margin-right: 0 !important; grid-area: icon;
    }
    .mi-info-icon svg {
        width: 18px; height: 18px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .mi-icon-id { background: linear-gradient(135deg,#ede9fe,#ddd6fe); }
    .mi-icon-id svg { stroke: #7c3aed; }
    .mi-icon-class { background: linear-gradient(135deg,#dbeafe,#bfdbfe); }
    .mi-icon-class svg { stroke: #2563eb; }
    .mi-icon-name { background: linear-gradient(135deg,#fce7f3,#fbcfe8); }
    .mi-icon-name svg { stroke: #db2777; }
    .mi-icon-email { background: linear-gradient(135deg,#fef3c7,#fde68a); }
    .mi-icon-email svg { stroke: #d97706; }
    .mi-icon-group { background: linear-gradient(135deg,#d1fae5,#bbf7d0); }
    .mi-icon-group svg { stroke: #059669; }
    .mi-icon-team { background: linear-gradient(135deg,#ffedd5,#fed7aa); }
    .mi-icon-team svg { stroke: #ea580c; }
    .mi-info-label { font-size: 13px !important; color: #64748b !important; font-weight: 600; min-width: 0; grid-area: label; align-self: end; }
    .mi-info-value {
        font-size: 15px !important; color: #0f172a !important; font-weight: 800;
        margin-left: 0 !important;
        display: flex !important; align-items: center; justify-content: flex-start; gap: 8px;
        min-width: 0; text-align: left; white-space: normal; overflow-wrap: anywhere; grid-area: value; flex-wrap: wrap;
    }
        .mi-info-value#emailDisplay {
            width: 100%;
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            align-items: center;
            gap: 12px;
            flex-wrap: nowrap;
            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .mi-info-value#emailDisplay .mi-btn-bind {
            flex: 0 0 auto;
            justify-self: end;
        }

        .mi-level-badges {
            display: grid !important;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)) !important;
            gap: 16px !important;
            align-items: stretch;
        }

        .mi-level-badges > * {
            min-width: 0;
        }

        .mi-level-badges .mi-level-badge {
            min-width: 0;
            min-height: 88px;
            padding: 14px 16px !important;
            border-radius: 22px !important;
            display: grid !important;
            grid-template-columns: 46px minmax(0, 1fr) !important;
            align-items: center !important;
            gap: 12px !important;
        }

        .mi-level-badges .mi-level-badge,
        .mi-level-badges .mi-level-badge * {
            writing-mode: horizontal-tb !important;
            text-orientation: mixed !important;
        }

        .mi-level-badges .mi-level-badge > :first-child {
            width: 46px;
            height: 46px;
            border-radius: 14px;
            display: grid;
            place-items: center;
            flex: 0 0 auto;
        }

        .mi-level-badges .mi-level-badge > :last-child {
            min-width: 0;
            display: grid;
            gap: 4px;
            align-content: center;
        }

        .mi-level-badges .mi-level-badge strong,
        .mi-level-badges .mi-level-badge b,
        .mi-level-badges .mi-level-badge span,
        .mi-level-badges .mi-level-badge div {
            word-break: break-word;
            overflow-wrap: anywhere;
        }

        .mi-level-badges .mi-level-badge-label {
            white-space: nowrap;
            overflow-wrap: normal;
            word-break: keep-all;
        }

        .mi-level-badges .mi-level-badge-value {
            white-space: normal;
            overflow-wrap: normal !important;
            word-break: keep-all !important;
        }

        @media (max-width: 640px) {
            .mi-level-badges {
                grid-template-columns: minmax(0, 1fr) !important;
            }
        }
    .mi-info-value a { color: #6366f1 !important; text-decoration: none !important; }
    .mi-info-value a:hover { text-decoration: underline !important; }

    /* 成员区域独立布局 */
    .mi-team-section {
        padding: 14px 16px 16px; margin-top: 12px;
        border-radius: 22px; border: 1px solid #e2e8f0;
        background: linear-gradient(180deg,#fff 0,#f8fafc 100%);
    }
    .mi-team-header { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
    .mi-team-header .mi-info-icon { margin-right: 0 !important; }
    .mi-team-header .mi-info-label { min-width: auto; font-size: 14px !important; color: #0f172a !important; font-weight: 800; }
    .mi-team-tags { display: flex; flex-wrap: wrap; gap: 10px; padding-left: 0; }
    .mi-team-tag {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 8px 14px; border-radius: 999px;
        font-size: 12px; font-weight: 700;
        background: #fff; border: 1px solid #dbe7f0;
        color: #334155; transition: all .15s;
        box-shadow: 0 8px 16px rgba(15,23,42,.04);
    }
    .mi-team-tag:hover { background: #eff6ff; border-color: #93c5fd; color: #1d4ed8; transform: translateY(-1px); }
    @media (max-width:860px){
        .mi-profile-top{padding:22px 20px 20px!important;}
        .mi-profile-title{font-size:24px;}
        .mi-profile-sub{max-width:540px;}
        .mi-profile-body{padding:16px;}
    }
    @media (max-width:640px){
        .mi-profile-top{padding:18px 16px 18px!important;}
        .mi-profile-avatar-wrap{width:108px;height:108px;}
        .mi-profile-title{font-size:22px;}
        .mi-profile-sub{font-size:12px;line-height:1.75;}
        .mi-profile-glance{grid-template-columns:1fr;}
        .mi-info-label{font-size:12px!important;}
        .mi-info-value{font-size:14px!important;}
        .mi-team-section{padding:14px;}
    }

    /* === 评语卡片 === */
    .mi-review {
        background: #fff !important; border-radius: 14px; border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04); overflow: hidden;
    }
    .mi-review-body { padding: 16px 20px; }
    .mi-review-content {
        padding: 12px 14px !important; border-radius: 8px !important;
        background: #f8fafc !important; border: 1px solid #e8ecf1 !important;
        font-size: 13px !important; color: #475569 !important; line-height: 1.6; margin-bottom: 14px;
    }
    .mi-review-content a {
        color: #6366f1 !important; text-decoration: none !important; margin-left: 8px !important;
    }

    /* === 按钮 === */
    .mi-actions { display: flex !important; gap: 10px; flex-wrap: wrap; padding-top: 4px; }
    .mi-btn {
        display: inline-flex !important; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 24px !important; border-radius: 8px !important; font-size: 13px !important;
        font-weight: 600; border: 1.5px solid #e2e8f0 !important; background: #fff !important;
        color: #475569 !important; cursor: pointer; transition: all .15s; font-family: inherit;
        background-image: none !important; height: auto !important; width: auto !important;
        line-height: 1.3 !important; text-align: center !important;
    }
    .mi-btn:hover { background: #f8fafc !important; border-color: #cbd5e1 !important; }
    .mi-btn-primary {
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important; border-color: transparent !important;
        box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .mi-btn-primary:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
        box-shadow: 0 4px 12px rgba(99,102,241,.3); color: #fff !important;
    }
    .mi-btn-danger {
        border-color: #fecaca !important; color: #ef4444 !important; background: #fff !important;
    }
    .mi-btn-danger:hover { background: #fef2f2 !important; border-color: #f87171 !important; }

    /* === 近日考试卡片 === */
    .mi-head-icon-exam { background: linear-gradient(135deg, #fce7f3, #fbcfe8) !important; }
    .mi-head-icon-exam svg { stroke: #db2777 !important; }
    .mi-exam-list { display: flex; flex-direction: column; gap: 0; padding: 0; }
    .mi-exam-item {
        display: flex; align-items: center; padding: 14px 20px; gap: 14px;
        border-bottom: 1px solid #f1f5f9; transition: all .15s;
        text-decoration: none !important; cursor: pointer;
    }
    .mi-exam-item:last-child { border-bottom: none; }
    .mi-exam-item:hover { background: #fdf2f8 !important; }
    .mi-exam-icon {
        width: 42px; height: 42px; border-radius: 10px; flex-shrink: 0;
        display: flex !important; align-items: center; justify-content: center;
        background: linear-gradient(135deg, #fdf2f8, #fce7f3);
    }
    .mi-exam-icon svg {
        width: 20px; height: 20px; fill: none; stroke: #db2777;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .mi-exam-item.mi-exam-item-ended .mi-exam-icon {
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
    }
    .mi-exam-item.mi-exam-item-ended .mi-exam-icon svg { stroke: #94a3b8; }
    .mi-exam-info { flex: 1; min-width: 0; }
    .mi-exam-title {
        font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 4px;
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .mi-exam-item:hover .mi-exam-title { color: #db2777; }
    .mi-exam-meta {
        font-size: 12px; color: #94a3b8; display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
    }
    .mi-exam-meta span { display: inline-flex; align-items: center; gap: 3px; }
    .mi-exam-meta svg {
        width: 12px; height: 12px; fill: none; stroke: #cbd5e1;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .mi-exam-status {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;
        flex-shrink: 0;
    }
    .mi-exam-active { background: #dcfce7; color: #166534; }
    .mi-exam-active::before {
        content: ''; width: 6px; height: 6px; border-radius: 50%;
        background: #22c55e; animation: miExamPulse 2s infinite;
    }
    @keyframes miExamPulse { 0%,100% { opacity:1; } 50% { opacity:.4; } }
    .mi-exam-pending { background: #eff6ff; color: #1e40af; }
    .mi-exam-ended { background: #f1f5f9; color: #64748b; }
    .mi-exam-enter {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 6px 16px; border-radius: 8px; font-size: 12px; font-weight: 600;
        background: linear-gradient(135deg, #ec4899, #db2777); color: #fff !important;
        text-decoration: none !important; flex-shrink: 0; transition: all .15s;
        box-shadow: 0 2px 6px rgba(219,39,119,.2);
    }
    .mi-exam-enter:hover {
        transform: translateY(-1px); box-shadow: 0 4px 12px rgba(219,39,119,.3);
    }
    .mi-exam-enter-disabled {
        background: #e2e8f0 !important; color: #94a3b8 !important;
        cursor: not-allowed; box-shadow: none !important;
    }
    .mi-exam-enter-disabled:hover { transform: none; box-shadow: none !important; }
    .mi-exam-empty {
        text-align: center; padding: 28px 20px; color: #94a3b8; font-size: 13px;
    }
/* === 右侧栏显示修复：覆盖前面残缺样式，保证整列完整显示 === */
.mi-grid {
    grid-template-columns: minmax(0, 1fr) 380px !important;
    gap: 28px !important;
    align-items: start !important;
}

.mi-sidebar {
    width: 100% !important;
    min-width: 0 !important;
    display: flex !important;
    flex-direction: column !important;
    gap: 20px !important;
    position: static !important;
    overflow: visible !important;
    align-self: start !important;
}

.mi-profile,
.mi-profile-top,
.mi-profile-top-grid,
.mi-profile-copy,
.mi-profile-body,
.mi-profile-glance,
.mi-level-badges,
.mi-info-grid {
    width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

.mi-profile {
    overflow: visible !important;
}

.mi-profile-top {
    padding: 30px 28px 20px !important;
}

.mi-profile-top-grid {
    grid-template-columns: 1fr !important;
    gap: 18px !important;
}

.mi-avatar-wrap {
    margin: 0 auto !important;
}

.mi-profile-copy {
    text-align: center !important;
}

.mi-profile-glance {
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
    gap: 12px !important;
}

.mi-level-badges {
    grid-template-columns: 1fr !important;
    gap: 14px !important;
}

.mi-level-card,
.mi-level-badge,
.mi-info-card,
.mi-info-row {
    width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

.mi-level-card {
    padding: 18px 20px !important;
}

.mi-level-badge {
    grid-template-columns: 64px minmax(0, 1fr) !important;
    gap: 14px !important;
    align-items: center !important;
}

.mi-level-badge-copy,
.mi-level-copy,
.mi-profile-title,
.mi-profile-sub,
.mi-info-value,
.mi-info-label {
    min-width: 0 !important;
    overflow-wrap: anywhere !important;
    word-break: break-word !important;
}

.mi-info-grid {
    gap: 14px !important;
}

.mi-info-row {
    grid-template-columns: 48px minmax(0, 1fr) !important;
    gap: 14px !important;
    align-items: center !important;
    padding: 16px 18px !important;
}

.mi-info-label {
    font-size: 12px !important;
    white-space: nowrap !important;
}

.mi-info-value {
    line-height: 1.35 !important;
    font-size: 13px !important;
}

@media (max-width: 1440px) {
    .mi-grid {
        grid-template-columns: minmax(0, 1fr) 352px !important;
    }
}

@media (max-width: 1180px) {
    .mi-grid {
        grid-template-columns: 1fr !important;
    }

    .mi-sidebar {
        max-width: none !important;
    }
}
</style>

<div class="mi-page">
    <div class="mi-grid">
        <!-- 左侧主内容 -->
        <div class="mi-main">
            <!-- 未学学案 -->
            <div class="mi-card">
                <div class="mi-card-head">
                    <span class="mi-head-icon mi-head-icon-new"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
                    <h3>未学学案</h3>
                </div>
                <div class="mi-card-body">
                    <asp:GridView ID="GridViewnewkc" runat="server" Width="100%"
                        SkinID="GridViewInfo" onrowdatabound="GridViewnewkc_RowDataBound"
                        AutoGenerateColumns="False"
                        EnableModelValidation="True" PageSize="5" AllowPaging="True"
                        onpageindexchanging="GridViewnewkc_PageIndexChanging" >
                        <Columns>
                            <asp:BoundField DataField="cid" Visible="false">
                            <ItemStyle Width="30px" ForeColor="White" />
                            </asp:BoundField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Image ID="ImageLeaf" runat="server" ImageUrl="~/images/leaf.gif" />
                                </ItemTemplate>
                                <ItemStyle Width="40px" />
                            </asp:TemplateField>
                            <asp:HyperLinkField DataNavigateUrlFields="cid"
                                DataNavigateUrlFormatString="~/student/showcourse.aspx?cid={0}" DataTextField="ctitle"
                                HeaderText="未学学案" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                            </asp:HyperLinkField>
                            <asp:BoundField DataField="Cdate" HeaderText="日期" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" Width="100px" />
                            </asp:BoundField>
                        </Columns>
                        <PagerTemplate>
                            <div class="pagediv">
                                第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black"
                                    Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>页
                                共<asp:Label ID="lblPageCount" runat="server" ForeColor="Black"
                                    Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                                <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False"
                                    CommandArgument="First" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="首页"></asp:LinkButton>
                                <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False"
                                    CommandArgument="Prev" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="上一页"></asp:LinkButton>
                                <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False"
                                    CommandArgument="Next" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="下一页"></asp:LinkButton>
                                <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False"
                                    CommandArgument="Last" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="尾页"></asp:LinkButton>
                            </div>
                        </PagerTemplate>
                        <RowStyle Height="36px" />
                    </asp:GridView>
                </div>
            </div>

            <!-- 已学学案 -->
            <div class="mi-card">
                <div class="mi-card-head">
                    <span class="mi-head-icon mi-head-icon-done"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                    <h3>已学学案</h3>
                </div>
                <div class="mi-card-body">
                    <asp:GridView ID="GridViewdonekc" runat="server" AllowPaging="True"
                        AutoGenerateColumns="False"
                        EnableModelValidation="True"
                        OnPageIndexChanging="GridViewdonekc_PageIndexChanging"
                        onrowdatabound="GridViewdonekc_RowDataBound" SkinID="GridViewInfo"
                        Width="100%" PageSize="5" DataKeyNames="Cid">
                        <Columns>
                            <asp:BoundField DataField="Cid" Visible="false">
                            <ItemStyle ForeColor="White" Width="30px" />
                            </asp:BoundField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Image ID="ImageLeaf" runat="server" ImageUrl="~/images/fruit.gif" Height="16px" />
                                </ItemTemplate>
                                <ItemStyle Width="40px" />
                            </asp:TemplateField>
                            <asp:HyperLinkField DataNavigateUrlFields="Cid"
                                DataNavigateUrlFormatString="~/student/showcourse.aspx?cid={0}"
                                DataTextField="ctitle" HeaderText="已学学案">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                            </asp:HyperLinkField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Literal ID="Process" runat="server"></asp:Literal>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="Cdate" HeaderText="日期" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" Width="100px" />
                            </asp:BoundField>
                        </Columns>
                        <PagerTemplate>
                            <div class="pagediv">
                                第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black"
                                    Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>页
                                共<asp:Label ID="lblPageCount" runat="server" ForeColor="Black"
                                    Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                                <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False"
                                    CommandArgument="First" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="首页"></asp:LinkButton>
                                <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False"
                                    CommandArgument="Prev" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="上一页"></asp:LinkButton>
                                <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False"
                                    CommandArgument="Next" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="下一页"></asp:LinkButton>
                                <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False"
                                    CommandArgument="Last" CommandName="Page" Font-Underline="False"
                                    ForeColor="Black" Text="尾页"></asp:LinkButton>
                            </div>
                        </PagerTemplate>
                        <RowStyle Height="36px" />
                    </asp:GridView>
                </div>
            </div>

            <!-- 近日考试 -->
            <% if (miExamDt != null && miExamDt.Rows.Count > 0) { %>
            <div class="mi-card">
                <div class="mi-card-head">
                    <span class="mi-head-icon mi-head-icon-exam"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></span>
                    <h3>近日考试</h3>
                </div>
                <div class="mi-card-body">
                    <div class="mi-exam-list">
                    <% foreach (System.Data.DataRow exRow in miExamDt.Rows) {
                        string exStatus = MiGetExamStatus(exRow["Estart"], exRow["Eend"]);
                        string exStatusCls = MiGetExamStatusClass(exRow["Estart"], exRow["Eend"]);
                        bool canEnter = (exStatus == "考试中");
                        string exPid = exRow["Epid"].ToString();
                        string exEid = exRow["Eid"].ToString();
                    %>
                        <div class="mi-exam-item<%= exStatus == "已结束" ? " mi-exam-item-ended" : "" %>">
                            <div class="mi-exam-icon">
                                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                            </div>
                            <div class="mi-exam-info">
                                <div class="mi-exam-title">
                                    <%= Server.HtmlEncode(exRow["Ptitle"].ToString()) %>
                                    <span class="mi-exam-status <%= exStatusCls %>"><%= exStatus %></span>
                                </div>
                                <div class="mi-exam-meta">
                                    <span><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg><%= MiFormatTime(exRow["Estart"]) %> ~ <%= MiFormatTime(exRow["Eend"]) %></span>
                                    <span><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg><%= exRow["Ptime"] %>分钟</span>
                                    <span><svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-6"/></svg><%= exRow["Pcount"] %>题/<%= exRow["Pscore"] %>分</span>
                                </div>
                            </div>
                            <% if (canEnter) { %>
                            <a href="myexam.aspx?vid=<%= exPid %>" class="mi-exam-enter" target="_blank">进入考试</a>
                            <% } else if (exStatus == "未开始") { %>
                            <span class="mi-exam-enter mi-exam-enter-disabled">未开始</span>
                            <% } else { %>
                            <span class="mi-exam-enter mi-exam-enter-disabled">已结束</span>
                            <% } %>
                        </div>
                    <% } %>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- 今日签到 -->
            <div class="mi-card">
                <div class="mi-card-head">
                    <span class="mi-head-icon mi-head-icon-online"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
                    <h3>今天签到的同学</h3>
                </div>
                <div class="mi-card-body">
                    <asp:DataList ID="DataListonline" runat="server" DataKeyField="Qid"
                        RepeatColumns="8" RepeatDirection="Horizontal"
                        CaptionAlign="Left" onitemdatabound="DataListonline_ItemDataBound"
                        Width="100%">
                        <ItemTemplate>
                            <div class="onlinediv">
                                <div class="onlinebg">
                                    <asp:HyperLink ID="HyperQname" runat="server" Font-Size="10pt" Font-Underline="False"
                                        Height="20px" Text='<%# Eval("Sname") %>'
                                        ToolTip='<%# Eval("Qip") %>' Target="_blank" ></asp:HyperLink>
                                </div>
                                <asp:Image ID="Imageflag" runat="server" BorderStyle="None" BorderWidth="0" />
                                <asp:Label ID="Labeltime" runat="server" Text='<%# Eval("Qdate") %>' Font-Names="Arial" Font-Size="8pt" Width="40px"></asp:Label>
                            </div>
                            <asp:Label ID="LabelSleader" runat="server" Text='<%# Eval("Sleader") %>' Visible="false" ></asp:Label>
                            <asp:Label ID="LabelSgroup" runat="server" Text='<%# Eval("Sgroup") %>' Visible="false" ></asp:Label>
                            <asp:Label ID="LabelQnum" runat="server" Text='<%# Eval("Qnum") %>' Visible="false" ></asp:Label>
                        </ItemTemplate>
                    </asp:DataList>
                </div>
            </div>
        </div>

        <!-- 右侧侧边栏 -->
        <div class="mi-sidebar">
            <!-- 个人信息 -->
            <div class="mi-profile">
                <div class="mi-profile-top">
                    <div class="mi-profile-deco"></div>
                    <div class="mi-profile-deco mi-profile-deco2"></div>
                    <div class="mi-profile-top-grid">
                        <div class="mi-profile-visual">
                            <div class="mi-profile-avatar-wrap">
                                <div class="mi-profile-avatar">
                                    <asp:Image ID="Imageface" runat="server" style="width:100%;height:100%;object-fit:cover;border-width:0px;" />
                                </div>
                            </div>
                            <div class="mi-profile-rank">
                                <asp:Label ID="LabelRank" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="mi-profile-copy">
                            <span class="mi-profile-kicker">Learning Passport</span>
                            <h2 class="mi-profile-title">我的成长名片</h2>
                            <div class="mi-profile-glance">
                                <span class="mi-profile-glance-item">
                                    <em>小组学分</em>
                                    <strong><%= miGscore %></strong>
                                </span>
                                <span class="mi-profile-glance-item">
                                    <em>总学分</em>
                                    <strong><%= miAllscore %></strong>
                                </span>
                            </div>
                            <div class="mi-level-badges">
                                <a href="../profile/grouplevel.aspx" class="mi-level-badge mi-level-badge-group" title="小组学分：<%= miGscore %> 分">
                                    <span class="mi-level-badge-icon"><%= MiRenderIcon(miGroupLevelIcon) %></span>
                                    <span class="mi-level-badge-text">
                                        <span class="mi-level-badge-label">小组等级</span>
                                        <span class="mi-level-badge-value">Lv.<%= miGroupLevelNum %> <%= miGroupLevelName %></span>
                                    </span>
                                </a>
                                <a href="../profile/creditlevel.aspx" class="mi-level-badge mi-level-badge-credit" title="总学分：<%= miAllscore %> 分">
                                    <span class="mi-level-badge-icon"><%= MiRenderIcon(miCreditLevelIcon) %></span>
                                    <span class="mi-level-badge-text">
                                        <span class="mi-level-badge-label">学分等级</span>
                                        <span class="mi-level-badge-value">Lv.<%= miCreditLevelNum %> <%= miCreditLevelName %></span>
                                    </span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mi-profile-body">
                    <div class="mi-info-grid">
                        <div class="mi-info-row">
                            <span class="mi-info-icon mi-icon-id"><svg viewBox="0 0 24 24"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg></span>
                            <span class="mi-info-label">学号</span>
                            <span class="mi-info-value"><asp:Label ID="snum" runat="server"></asp:Label></span>
                        </div>
                        <div class="mi-info-row">
                            <span class="mi-info-icon mi-icon-class"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></span>
                            <span class="mi-info-label">班级</span>
                            <span class="mi-info-value"><asp:Label ID="sclass" runat="server"></asp:Label></span>
                        </div>
                        <div class="mi-info-row">
                            <span class="mi-info-icon mi-icon-name"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                            <span class="mi-info-label">姓名</span>
                            <span class="mi-info-value"><asp:Label ID="sname" runat="server"></asp:Label></span>
                        </div>
                        <div class="mi-info-row">
                            <span class="mi-info-icon mi-icon-email"><svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></span>
                            <span class="mi-info-label">邮箱</span>
                            <span class="mi-info-value" id="emailDisplay">
                                <asp:Label ID="semail" runat="server" Text="未绑定"></asp:Label>
                                <button type="button" class="mi-btn-bind" onclick="showEmailModal()" title="绑定/修改邮箱">
                                    <svg viewBox="0 0 24 24" width="14" height="14"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                </button>
                            </span>
                        </div>
                        <div class="mi-info-row">
                            <span class="mi-info-icon mi-icon-group"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
                            <span class="mi-info-label">小组</span>
                            <span class="mi-info-value"><asp:HyperLink ID="HLgroup" runat="server">[HLgroup]</asp:HyperLink></span>
                        </div>
                    </div>
                    <div class="mi-team-section">
                        <div class="mi-team-header">
                            <span class="mi-info-icon mi-icon-team"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></span>
                            <span class="mi-info-label">成员</span>
                        </div>
                        <div class="mi-team-tags">
                            <asp:Label ID="Labelteam" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 最新评语 -->
            <div class="mi-review">
                <div class="mi-card-head">
                    <span class="mi-head-icon mi-head-icon-info"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></span>
                    <h3>最新评语</h3>
                </div>
                <div class="mi-review-body">
                    <div class="mi-review-content">
                        <asp:Label ID="LabelWself" runat="server"></asp:Label>
                        <asp:HyperLink ID="Hlwork" runat="server" ForeColor="#6366f1" Target="_blank">查看作品</asp:HyperLink>
                    </div>
                    <div class="mi-actions">
                        <asp:Button ID="BtnProfile" runat="server" OnClick="BtnProfile_Click"
                            Text="我的资料" CausesValidation="False" CssClass="mi-btn mi-btn-primary" />
                        <asp:Button ID="BtnExit" runat="server" onclick="BtnExit_Click"
                            Enabled="False" Text="" CssClass="mi-btn mi-btn-danger" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<asp:Label ID="LabelCids" runat="server" ForeColor="White" Visible="false"></asp:Label>

<!-- 邮箱绑定弹窗 -->
<div id="emailModal" class="email-modal" style="display:none;">
    <div class="email-modal-content">
        <div class="email-modal-header">
            <h3>绑定邮箱</h3>
            <button class="email-modal-close" onclick="closeEmailModal()">&times;</button>
        </div>
        <div class="email-modal-body">
            <div id="emailAlert" class="email-alert" style="display:none;"></div>
            
            <div class="email-form-group">
                <label>邮箱地址</label>
                <input type="email" id="emailInput" placeholder="请输入您的邮箱地址" />
            </div>
            
            <div class="email-form-group">
                <label>验证码</label>
                <div class="email-code-group">
                    <input type="text" id="emailCode" placeholder="请输入6位验证码" maxlength="6" />
                    <button type="button" id="sendEmailCodeBtn" onclick="sendEmailCode()">发送验证码</button>
                </div>
            </div>
            
            <button type="button" class="email-btn-primary" onclick="bindEmail()">确认绑定</button>
        </div>
    </div>
</div>

<style>
.mi-btn-bind {
    padding: 6px;
    background: linear-gradient(135deg, #eff6ff, #dbeafe);
    color: #1d4ed8;
    border: 1px solid #bfdbfe;
    border-radius: 10px;
    font-size: 0;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    transition: all 0.2s;
    flex-shrink: 0;
}
.mi-btn-bind:hover {
    transform: translateY(-1px);
    box-shadow: 0 10px 18px rgba(59,130,246,0.18);
    border-color: #93c5fd;
}
.mi-btn-bind svg {
    fill: none;
    stroke: currentColor;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
}
.email-modal {
    position: fixed;
    z-index: 9999;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
}
.email-modal-content {
    background: #fff;
    border-radius: 16px;
    width: 90%;
    max-width: 500px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    animation: slideIn 0.3s ease;
}
@keyframes slideIn {
    from { transform: translateY(-50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}
.email-modal-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.email-modal-header h3 {
    font-size: 20px;
    font-weight: 700;
    color: #1e293b;
    margin: 0;
}
.email-modal-close {
    width: 32px;
    height: 32px;
    border: none;
    background: #f1f5f9;
    border-radius: 8px;
    font-size: 24px;
    color: #64748b;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
}
.email-modal-close:hover {
    background: #e2e8f0;
    transform: rotate(90deg);
}
.email-modal-body {
    padding: 24px;
}
.email-alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 14px;
}
.email-alert.success {
    background: #d1fae5;
    color: #065f46;
    border: 1px solid #10b981;
}
.email-alert.error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #ef4444;
}
.email-form-group {
    margin-bottom: 20px;
}
.email-form-group label {
    display: block;
    font-size: 14px;
    font-weight: 600;
    color: #475569;
    margin-bottom: 8px;
}
.email-form-group input[type="email"],
.email-form-group input[type="text"] {
    width: 100%;
    padding: 10px 14px;
    border: 1.5px solid #e2e8f0;
    border-radius: 8px;
    font-size: 14px;
    transition: all 0.2s;
}
.email-form-group input:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
}
.email-code-group {
    display: flex;
    gap: 10px;
}
.email-code-group input {
    flex: 1;
}
.email-code-group button {
    padding: 10px 20px;
    background: linear-gradient(135deg, #10b981, #059669);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    white-space: nowrap;
    transition: all 0.2s;
}
.email-code-group button:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(16,185,129,0.4);
}
.email-code-group button:disabled {
    background: #cbd5e1;
    cursor: not-allowed;
    transform: none;
}
.email-btn-primary {
    width: 100%;
    padding: 12px;
    background: linear-gradient(135deg, #6366f1, #8b5cf6);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}
.email-btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(99,102,241,0.4);
}
</style>

<script type="text/javascript">
    var i = 2;
    var emailCountdown = 60;
    var emailCountdownTimer = null;
    
    function showEmailModal() {
        document.getElementById('emailModal').style.display = 'flex';
        // 如果已绑定邮箱，预填充到输入框
        var currentEmail = document.getElementById('<%=semail.ClientID%>').innerText;
        if (currentEmail && currentEmail !== '未绑定') {
            document.getElementById('emailInput').value = currentEmail;
        }
    }
    
    function closeEmailModal() {
        document.getElementById('emailModal').style.display = 'none';
        document.getElementById('emailInput').value = '';
        document.getElementById('emailCode').value = '';
        document.getElementById('emailAlert').style.display = 'none';
    }
    
    function showEmailAlert(message, type) {
        var alert = document.getElementById('emailAlert');
        alert.textContent = message;
        alert.className = 'email-alert ' + type;
        alert.style.display = 'block';
        
        setTimeout(function() {
            alert.style.display = 'none';
        }, 5000);
    }
    
    function sendEmailCode() {
        var email = document.getElementById('emailInput').value.trim();
        var btn = document.getElementById('sendEmailCodeBtn');
        
        if (!email) {
            showEmailAlert('请输入邮箱地址', 'error');
            return;
        }
        
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            showEmailAlert('请输入有效的邮箱地址', 'error');
            return;
        }
        
        if (btn.disabled) return;
        
        btn.disabled = true;
        btn.textContent = '发送中...';
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'bindemail.ashx?action=sendcode&email=' + encodeURIComponent(email), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.success) {
                            showEmailAlert('验证码已发送到您的邮箱', 'success');
                            startEmailCountdown();
                        } else {
                            var msg = data.message || '发送失败';
                            // 翻译英文错误信息
                            if (msg === 'Not logged in') msg = '未登录';
                            else if (msg === 'Email required') msg = '邮箱地址不能为空';
                            else if (msg === 'Code sent') msg = '验证码已发送';
                            else if (msg.indexOf('Email send error') === 0) msg = '邮件发送失败';
                            showEmailAlert(msg, 'error');
                            btn.disabled = false;
                            btn.textContent = '发送验证码';
                        }
                    } catch(e) {
                        showEmailAlert('服务器响应错误', 'error');
                        btn.disabled = false;
                        btn.textContent = '发送验证码';
                    }
                } else {
                    showEmailAlert('网络错误，请稍后重试', 'error');
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                }
            }
        };
        xhr.send();
    }
    
    function startEmailCountdown() {
        var btn = document.getElementById('sendEmailCodeBtn');
        emailCountdown = 60;
        
        emailCountdownTimer = setInterval(function() {
            emailCountdown--;
            btn.textContent = emailCountdown + '秒后重发';
            
            if (emailCountdown <= 0) {
                clearInterval(emailCountdownTimer);
                btn.disabled = false;
                btn.textContent = '发送验证码';
            }
        }, 1000);
    }
    
    function bindEmail() {
        var email = document.getElementById('emailInput').value.trim();
        var code = document.getElementById('emailCode').value.trim();
        
        if (!email) {
            showEmailAlert('请输入邮箱地址', 'error');
            return;
        }
        
        if (!code || code.length !== 6) {
            showEmailAlert('请输入6位验证码', 'error');
            return;
        }
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'bindemail.ashx?action=bind&email=' + encodeURIComponent(email) + '&code=' + encodeURIComponent(code), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.success) {
                            showEmailAlert('邮箱绑定成功！', 'success');
                            setTimeout(function() {
                                location.reload();
                            }, 1500);
                        } else {
                            var msg = data.message || '绑定失败';
                            // 翻译英文错误信息
                            if (msg === 'Not logged in') msg = '未登录';
                            else if (msg === 'Parameter error') msg = '参数错误';
                            else if (msg === 'Get code first') msg = '请先获取验证码';
                            else if (msg === 'Session error') msg = '会话错误';
                            else if (msg === 'Code expired') msg = '验证码已过期';
                            else if (msg === 'Code incorrect') msg = '验证码错误';
                            else if (msg === 'Database connection failed') msg = '数据库连接失败';
                            else if (msg === 'Bind failed') msg = '绑定失败';
                            else if (msg === 'Email bound') msg = '邮箱已绑定';
                            showEmailAlert(msg, 'error');
                        }
                    } catch(e) {
                        showEmailAlert('服务器响应错误', 'error');
                    }
                } else {
                    showEmailAlert('网络错误，请稍后重试', 'error');
                }
            }
        };
        xhr.send();
    }
    
    function setbar() {
        i--;
        var btnid = "<%= BtnExit.ClientID %>";
        var el = document.getElementById(btnid);
        if (!el) return;
        if (el.value != "") el.value = "平台退出";
        if (i < 0) {
            el.disabled = false;
            if (el.value != "") el.value = "平台退出";
            return;
        } else {
            el.disabled = true;
        }
        setTimeout("setbar()", 1000);
    }
    setbar();

    // 将成员文本拆分为标签
    (function(){
        var box = document.querySelector('.mi-team-tags');
        if(!box) return;
        var raw = box.textContent.trim();
        if(!raw) return;
        var names = raw.split(/[\u3001,\uff0c]+/).filter(function(n){ return n.trim(); });
        if(names.length === 0) return;
        box.innerHTML = '';
        names.forEach(function(name){
            var tag = document.createElement('span');
            tag.className = 'mi-team-tag';
            tag.textContent = name.trim();
            box.appendChild(tag);
        });
    })();

    // === 进度条美化 v4 - 增强颜色检测 ===
    (function(){
        // 解析颜色值为 RGB 数组，失败返回 null
        function parseColorRGB(v){
            if(!v) return null;
            v = (v+'').toLowerCase().replace(/\s+/g,'');
            // 命名颜色映射（常见的）
            var named = {
                'green':[0,128,0],'lime':[0,255,0],'limegreen':[50,205,50],'forestgreen':[34,139,34],
                'seagreen':[46,139,87],'mediumseagreen':[60,179,113],'springgreen':[0,255,127],
                'darkgreen':[0,100,0],'yellowgreen':[154,205,50],'lawngreen':[124,252,0],
                'chartreuse':[127,255,0],'olivedrab':[107,142,35],'olive':[128,128,0],
                'lightgreen':[144,238,144],'palegreen':[152,251,152],'greenyellow':[173,255,47],
                'red':[255,0,0],'darkred':[139,0,0],'crimson':[220,20,60],'orangered':[255,69,0],
                'blue':[0,0,255],'darkblue':[0,0,139],'royalblue':[65,105,225],'dodgerblue':[30,144,255],
                'orange':[255,165,0],'darkorange':[255,140,0],'coral':[255,127,80],
                'tomato':[255,99,71],'salmon':[250,128,114],'gold':[255,215,0],'yellow':[255,255,0],
                'cyan':[0,255,255],'teal':[0,128,128],'purple':[128,0,128],'magenta':[255,0,255],
                'indigo':[75,0,130],'violet':[238,130,238],'deeppink':[255,20,147],
                'white':[255,255,255],'whitesmoke':[245,245,245],'gainsboro':[220,220,220],
                'silver':[192,192,192],'lightgray':[211,211,211],'lightgrey':[211,211,211],
                'darkgray':[169,169,169],'darkgrey':[169,169,169],'gray':[128,128,128],'grey':[128,128,128],
                'ghostwhite':[248,248,255],'snow':[255,250,250],'ivory':[255,255,240],
                'floralwhite':[255,250,240],'linen':[250,240,230],'beige':[245,245,220],
                'oldlace':[253,245,230],'antiquewhite':[250,235,215],'bisque':[255,228,196],
                'blanchedalmond':[255,235,205],'cornsilk':[255,248,220],'lemonchiffon':[255,250,205],
                'aliceblue':[240,248,255],'azure':[240,255,255],'mintcream':[245,255,250],
                'honeydew':[240,255,240],'lavender':[230,230,250],'lavenderblush':[255,240,245],
                'mistyrose':[255,228,225],'seashell':[255,245,238],'papayawhip':[255,239,213],
                'wheat':[245,222,179],'peachpuff':[255,218,185],'navajowhite':[255,222,173],
                'moccasin':[255,228,181],'khaki':[240,230,140]
            };
            if(named[v]) return named[v];
            // 6位hex
            var h6 = v.match(/^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/);
            if(h6) return [parseInt(h6[1],16),parseInt(h6[2],16),parseInt(h6[3],16)];
            // 3位hex
            var h3 = v.match(/^#?([0-9a-f])([0-9a-f])([0-9a-f])$/);
            if(h3) return [parseInt(h3[1]+h3[1],16),parseInt(h3[2]+h3[2],16),parseInt(h3[3]+h3[3],16)];
            // rgb/rgba
            var rr = v.match(/rgba?\((\d+),(\d+),(\d+)/);
            if(rr) return [+rr[1],+rr[2],+rr[3]];
            return null;
        }

        // 判断颜色是否为中性色（白/灰/透明/浅底色）
        function isNeutralColor(v){
            if(!v) return true;
            v = (v+'').toLowerCase().replace(/\s+/g,'');
            if(!v || v==='transparent' || v==='initial' || v==='inherit' || v==='unset' || v==='none') return true;
            var rgb = parseColorRGB(v);
            if(!rgb) return true; // 无法解析的颜色视为中性
            var r=rgb[0], g=rgb[1], b=rgb[2];
            var max=Math.max(r,g,b), min=Math.min(r,g,b), diff=max-min;
            // 纯灰色系（几乎无色差）
            if(diff < 15) return true;
            // 接近白色且饱和度低
            if(min > 200 && diff < 40) return true;
            return false;
        }

        // 判断颜色值是否为「已完成」色（非中性色 = 有明显色彩的颜色）
        function isDoneColor(v){
            return !isNeutralColor(v);
        }

        // 从元素提取原始颜色值（优先读HTML属性，忽略CSS覆盖）
        function extractCellColor(el){
            // 1. 优先读 bgcolor 属性
            var bg = el.getAttribute('bgcolor');
            if(bg) return bg;
            // 2. 读 inline style 中的 background-color/background
            var st = el.getAttribute('style') || '';
            var m = st.match(/background(?:-color)?\s*:\s*([^;!]+)/i);
            if(m) return m[1].replace(/\s+/g,'');
            return null;
        }

        // 判断元素是否为已完成色
        function isCellDone(el){
            var color = extractCellColor(el);
            if(color) return isDoneColor(color);
            // 最后尝试 computedStyle（可能被CSS覆盖，仅作备用）
            try {
                var cs = window.getComputedStyle(el).backgroundColor;
                if(cs && cs!=='transparent' && cs!=='rgba(0, 0, 0, 0)' && cs!=='rgb(255, 255, 255)'){
                    return isDoneColor(cs);
                }
            } catch(e){}
            return false;
        }

        // 策略A：从innerHTML中用正则提取所有颜色段
        function detectFromHTML(html){
            html = (html+'').toLowerCase();
            var colors = [];
            var re1 = /bgcolor\s*=\s*["']?\s*([^"'\s>]+)/gi;
            var m;
            while((m = re1.exec(html)) !== null) colors.push(m[1]);
            var re2 = /background(?:-color)?\s*:\s*([^;"'!]+)/gi;
            while((m = re2.exec(html)) !== null) {
                var val = m[1].replace(/\s+/g,'');
                if(val && val !== 'transparent' && val !== 'none') colors.push(val);
            }
            if(colors.length < 2) return null;
            var done = 0;
            for(var i=0;i<colors.length;i++){ if(isDoneColor(colors[i])) done++; }
            return {total:colors.length, done:done};
        }

        // 策略B：DOM遍历所有带背景色的子元素
        function detectFromDOM(cell){
            var allEls = cell.getElementsByTagName('*');
            var segs = [];
            for(var i=0;i<allEls.length;i++){
                var el = allEls[i];
                var tag = el.tagName;
                if(tag==='TABLE'||tag==='TBODY'||tag==='TR'||tag==='SCRIPT'||tag==='STYLE') continue;
                if(el.className && /mi-progress/.test(el.className)) continue;
                var color = extractCellColor(el);
                if(color) segs.push(el);
            }
            if(segs.length < 2) return null;
            var done = 0;
            for(var i=0;i<segs.length;i++){ if(isCellDone(segs[i])) done++; }
            return {total:segs.length, done:done};
        }

        // 构建新进度条替换原内容
        function buildBar(cell, total, done){
            var pct = Math.round((done/total)*100);
            cell.className = (cell.className||'') + ' mi-progress-cell';
            var w = document.createElement('div'); w.className = 'mi-progress';
            var track = document.createElement('div');
            track.className = 'mi-progress-track' + (pct>=50?' mi-track-high':'');
            var inner = document.createElement('div'); inner.className = 'mi-progress-track-inner';
            track.appendChild(inner);
            var txt = document.createElement('div'); txt.className = 'mi-progress-track-text';
            txt.innerText = done + ' / ' + total; track.appendChild(txt);
            var badge = document.createElement('span'); badge.className = 'mi-progress-badge';
            badge.innerText = pct + '%';
            if(pct===100)    badge.className += ' mi-badge-full';
            else if(pct>=60) badge.className += ' mi-badge-green';
            else if(pct>=30) badge.className += ' mi-badge-yellow';
            else             badge.className += ' mi-badge-red';
            w.appendChild(track); w.appendChild(badge);
            while(cell.firstChild) cell.removeChild(cell.firstChild);
            cell.appendChild(w);
            cell.setAttribute('data-pg','1');
            setTimeout(function(){ inner.style.width = pct + '%'; }, 50);
        }

        // 查找GridView表格
        function findGridView(){
            // 方法1：按ID后缀匹配
            var gv = document.querySelector("table[id$='GridViewdonekc']");
            if(gv) {
                console.log('[Progress Bar] Found GridView by ID:', gv.id);
                return gv;
            }
            console.log('[Progress Bar] GridView not found by ID, scanning cards...');
            // 方法2：扫描所有卡片，找含有彩色内容的表格
            var cards = document.getElementsByClassName('mi-card');
            console.log('[Progress Bar] Found ' + cards.length + ' cards');
            for(var i=0;i<cards.length;i++){
                var cb = cards[i].querySelector('.mi-card-body');
                if(!cb) continue;
                var tbls = cb.getElementsByTagName('table');
                console.log('[Progress Bar] Card ' + i + ' has ' + tbls.length + ' tables');
                for(var j=0;j<tbls.length;j++){
                    var t = tbls[j];
                    if(!t.rows || t.rows.length < 2) continue;
                    // 检查是否有含彩色内容的行
                    for(var r=0;r<t.rows.length;r++){
                        var cs = t.rows[r].cells;
                        if(!cs || cs.length < 3) continue;
                        for(var c=0;c<cs.length;c++){
                            var h = cs[c].innerHTML;
                            if(h && h.length > 10 && /bgcolor|background/i.test(h)){
                                console.log('[Progress Bar] Found table with colored content in card ' + i);
                                return t;
                            }
                        }
                    }
                }
            }
            console.log('[Progress Bar] No suitable table found');
            return null;
        }

        function run(){
            var gv = findGridView();
            var processed = 0;

            console.log('[Progress Bar] Run: GridView found:', !!gv);
            if(!gv) return 0;
            console.log('[Progress Bar] GridView rows:', gv.rows.length);

            for(var ri=0;ri<gv.rows.length;ri++){
                var row = gv.rows[ri];
                var cells = row.cells;
                if(!cells || cells.length < 2) continue;
                if(cells[0] && cells[0].tagName === 'TH') continue;

                var cell = null;
                for(var ci=0;ci<cells.length;ci++){
                    if(cells[ci].getAttribute('data-pg')==='1') continue;
                    var h = cells[ci].innerHTML;
                    if(h && h.length > 10 && /bgcolor|background/i.test(h)){
                        cell = cells[ci];
                        console.log('[Progress Bar] Row ' + ri + ': Found colored cell at index ' + ci);
                        break;
                    }
                }
                if(!cell){
                    if(cells.length >= 3 && cells[2].getAttribute('data-pg')!=='1'){
                        var kids = cells[2].getElementsByTagName('*');
                        if(kids.length >= 2) {
                            cell = cells[2];
                            console.log('[Progress Bar] Row ' + ri + ': Using cell[2] with ' + kids.length + ' children');
                        }
                    }
                }
                if(!cell) {
                    console.log('[Progress Bar] Row ' + ri + ': No suitable cell found');
                    continue;
                }

                var origHTML = cell.innerHTML;
                console.log('[Progress Bar] Row ' + ri + ': Cell HTML length:', origHTML.length);
                var result = detectFromHTML(origHTML);
                if(!result) result = detectFromDOM(cell);

                if(result && result.total > 0){
                    console.log('[Progress Bar] Row ' + ri + ': Building bar - ' + result.done + '/' + result.total);
                    buildBar(cell, result.total, result.done);
                    processed++;
                } else {
                    console.log('[Progress Bar] Row ' + ri + ': No progress data detected');
                }
            }
            console.log('[Progress Bar] Total processed:', processed);
            return processed;
        }

        function init(){
            try {
                console.log('[Progress Bar] Initializing...');
                var n = run();
                console.log('[Progress Bar] Processed ' + n + ' rows');
                if(!n || n === 0){
                    console.log('[Progress Bar] No rows processed, retrying...');
                    setTimeout(function(){ 
                        try{
                            var n2 = run();
                            console.log('[Progress Bar] Retry 1: Processed ' + n2 + ' rows');
                        }catch(e){
                            console.error('[Progress Bar] Retry 1 error:', e);
                        } 
                    }, 800);
                    setTimeout(function(){ 
                        try{
                            var n3 = run();
                            console.log('[Progress Bar] Retry 2: Processed ' + n3 + ' rows');
                        }catch(e){
                            console.error('[Progress Bar] Retry 2 error:', e);
                        } 
                    }, 2000);
                }
            } catch(e){
                if(window.console) console.error('[Progress Bar] Init error:', e);
            }
        }

        if(document.readyState === 'loading'){
            document.addEventListener('DOMContentLoaded', init);
        } else {
            init();
        }
        window.addEventListener('load', function(){ setTimeout(init, 500); });

        // 监听DOM变化
        if(typeof MutationObserver !== 'undefined'){
            setTimeout(function(){
                var obs = new MutationObserver(function(muts){
                    var need = false;
                    for(var i=0;i<muts.length;i++){ if(muts[i].addedNodes.length>0){need=true;break;} }
                    if(need) setTimeout(function(){ try{run();}catch(e){} }, 200);
                });
                var bds = document.getElementsByClassName('mi-card-body');
                for(var i=0;i<bds.length;i++){
                    obs.observe(bds[i], {childList:true, subtree:true});
                }
            }, 100);
        }
    })();
</script>
<script>
// JS备用：服务端 DataSource 为 null 时隐藏已归档/已删除学案行
(function(){
    var ex = <%= miExcludeCidsJson %>;
    if(!ex || !ex.length) return;
    function hideArchived(){
        var links = document.querySelectorAll('.mi-card-body a[href*="showcourse.aspx?cid="]');
        for(var i=0;i<links.length;i++){
            var m = links[i].href.match(/cid=(\d+)/);
            if(m){
                var cid = parseInt(m[1],10);
                for(var j=0;j<ex.length;j++){
                    if(ex[j]===cid){
                        var tr = links[i].closest('tr');
                        if(tr) tr.style.display='none';
                        break;
                    }
                }
            }
        }
    }
    if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',hideArchived);
    else hideArchived();
})();
</script>
</asp:Content>


