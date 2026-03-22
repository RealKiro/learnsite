<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" AutoEventWireup="true" %>

<script runat="server">
    private int pageSize = 24;
    private int pageIndex = 0;
    private int totalCount = 0;
    private string filterGrade = "";
    private string filterTerm = "";
    private string filterScope = "class"; // class, grade, all
    private int myGrade = 0;
    private int myClass = 0;
    private string myName = "";
    private System.Data.DataTable dtWorks = null;

    private static System.Reflection.BindingFlags sFlags =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    private string GetPropStr(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo p = model.GetType().GetProperty(propName);
        if (p == null) return "";
        object v = p.GetValue(model, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, System.Text.Encoding.UTF8); } catch { } }
        return s;
    }

    private int GetPropInt(object model, string propName)
    {
        string s = GetPropStr(model, propName);
        if (string.IsNullOrEmpty(s)) return 0;
        int result;
        if (int.TryParse(s, out result)) return result;
        return 0;
    }

    private void LoadStudentCookie()
    {
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
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", sFlags);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                    myName = GetPropStr(m, "Sname");
                    string sg = GetPropStr(m, "Sgrade");
                    string sc2 = GetPropStr(m, "Sclass");
                    if (!string.IsNullOrEmpty(sg)) int.TryParse(sg, out myGrade);
                    if (!string.IsNullOrEmpty(sc2)) int.TryParse(sc2, out myClass);
                }
            }
        }
        catch { }
    }

    private string GetConnStr()
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

    protected void Page_Load(object sender, EventArgs e)
    {
        // 读取当前学生信息
        LoadStudentCookie();

        // 解析分页参数
        if (!string.IsNullOrEmpty(Request.QueryString["p"]))
        {
            int.TryParse(Request.QueryString["p"], out pageIndex);
            if (pageIndex < 0) pageIndex = 0;
        }
        filterGrade = Request.QueryString["grade"] ?? "";
        filterTerm = Request.QueryString["term"] ?? "";

        // 解析范围参数，默认为本班级
        string scopeParam = Request.QueryString["scope"] ?? "";
        if (scopeParam == "grade" || scopeParam == "all")
            filterScope = scopeParam;
        else
            filterScope = "class";

        // 如果学生未登录（无法获取年级班级），回退到全部
        if (myGrade <= 0 && filterScope != "all")
            filterScope = "all";

        LoadExcellentWorks();
    }

    private void LoadExcellentWorks()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();

                // 构建 WHERE 条件
                string where = "WHERE w.Wgood=1";
                System.Collections.Generic.List<System.Data.SqlClient.SqlParameter> parms = new System.Collections.Generic.List<System.Data.SqlClient.SqlParameter>();

                // 根据范围筛选
                if (filterScope == "class" && myGrade > 0 && myClass > 0)
                {
                    where += " AND w.Wgrade=@mygrade AND w.Wclass=@myclass";
                    parms.Add(new System.Data.SqlClient.SqlParameter("@mygrade", myGrade));
                    parms.Add(new System.Data.SqlClient.SqlParameter("@myclass", myClass));
                }
                else if (filterScope == "grade" && myGrade > 0)
                {
                    where += " AND w.Wgrade=@mygrade";
                    parms.Add(new System.Data.SqlClient.SqlParameter("@mygrade", myGrade));
                }
                else if (filterScope == "all")
                {
                    // 全部模式下仍支持手动年级筛选
                    if (!string.IsNullOrEmpty(filterGrade) && filterGrade != "0")
                    {
                        int g;
                        if (int.TryParse(filterGrade, out g) && g > 0)
                        {
                            where += " AND w.Wgrade=@grade";
                            parms.Add(new System.Data.SqlClient.SqlParameter("@grade", g));
                        }
                    }
                }

                if (!string.IsNullOrEmpty(filterTerm) && filterTerm != "0")
                {
                    int t;
                    if (int.TryParse(filterTerm, out t) && t > 0)
                    {
                        where += " AND w.Wterm=@term";
                        parms.Add(new System.Data.SqlClient.SqlParameter("@term", t));
                    }
                }

                // 获取总数
                string countSql = "SELECT COUNT(*) FROM Works w " + where;
                using (System.Data.SqlClient.SqlCommand cmdCount = new System.Data.SqlClient.SqlCommand(countSql, conn))
                {
                    foreach (System.Data.SqlClient.SqlParameter p in parms) cmdCount.Parameters.Add(new System.Data.SqlClient.SqlParameter(p.ParameterName, p.Value));
                    totalCount = (int)cmdCount.ExecuteScalar();
                }

                // 分页查询
                string dataSql = "SELECT w.Wid, w.Wname, w.Wurl, w.Wtype, w.Wgrade, w.Wclass, w.Wscore, w.Wvote, w.Whit, w.Wdate, w.Wthumbnail, w.Wtitle, c.Ctitle "
                    + "FROM Works w LEFT JOIN Courses c ON w.Wcid=c.Cid "
                    + where
                    + " ORDER BY w.Wdate DESC "
                    + "OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY";

                using (System.Data.SqlClient.SqlCommand cmdData = new System.Data.SqlClient.SqlCommand(dataSql, conn))
                {
                    foreach (System.Data.SqlClient.SqlParameter p in parms) cmdData.Parameters.Add(new System.Data.SqlClient.SqlParameter(p.ParameterName, p.Value));
                    cmdData.Parameters.AddWithValue("@offset", pageIndex * pageSize);
                    cmdData.Parameters.AddWithValue("@pageSize", pageSize);

                    System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmdData);
                    dtWorks = new System.Data.DataTable();
                    da.Fill(dtWorks);
                }
            }
        }
        catch { }
    }

    protected string GetWorkThumbnailUrl(object thumbnailObj, object typeObj)
    {
        string thumbnail = thumbnailObj == null || thumbnailObj == DBNull.Value ? "" : thumbnailObj.ToString();
        if (!string.IsNullOrEmpty(thumbnail))
            return ResolveUrl("~/" + thumbnail.TrimStart('/'));

        // 使用与母版页一致的网站logo
        return GetSiteLogoUrl();
    }
    
    protected string GetSiteLogoUrl()
    {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
        foreach (string ext in exts)
        {
            string path = Server.MapPath("~/images/site-logo" + ext);
            if (System.IO.File.Exists(path))
                return ResolveUrl("~/images/site-logo" + ext);
        }
        // 如果没有找到site-logo，返回默认图标
        return ResolveUrl("~/images/logo.png");
    }

    protected string BuildPageUrl(int p)
    {
        string url = "excellentwork.aspx?p=" + p;
        url += "&scope=" + Server.UrlEncode(filterScope);
        if (filterScope == "all" && !string.IsNullOrEmpty(filterGrade) && filterGrade != "0") url += "&grade=" + Server.UrlEncode(filterGrade);
        if (!string.IsNullOrEmpty(filterTerm) && filterTerm != "0") url += "&term=" + Server.UrlEncode(filterTerm);
        return url;
    }

    protected int TotalPages { get { return totalCount <= 0 ? 1 : (int)Math.Ceiling((double)totalCount / pageSize); } }
    protected int CurrentPage { get { return pageIndex; } }
    protected int TotalRecords { get { return totalCount; } }
    protected System.Data.DataTable WorksData { get { return dtWorks; } }
    protected string FilterScope { get { return filterScope; } }
    protected int MyGrade { get { return myGrade; } }
    protected int MyClass { get { return myClass; } }
    protected bool IsLoggedIn { get { return myGrade > 0; } }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">
<style>
    .ew-page, .ew-page * { margin-right: unset !important; margin-left: unset !important; }
    .ew-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: ewFadeIn .4s ease;
    }
    @keyframes ewFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 顶部标题区 */
    .ew-hero {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 20px; padding: 36px 40px; margin-bottom: 28px;
        color: #fff; position: relative; overflow: hidden;
    }
    .ew-hero::before {
        content: ''; position: absolute; top: -60px; right: -40px;
        width: 200px; height: 200px; border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .ew-hero::after {
        content: ''; position: absolute; bottom: -40px; left: 30%;
        width: 140px; height: 140px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .ew-hero h2 {
        font-size: 24px !important; font-weight: 800; margin: 0 0 8px !important;
        display: flex; align-items: center; gap: 12px; position: relative; z-index: 1;
    }
    .ew-hero h2 svg {
        width: 28px; height: 28px; fill: none; stroke: #fbbf24;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .ew-hero p {
        font-size: 14px; opacity: .85; margin: 0 !important; position: relative; z-index: 1;
    }

    /* 筛选栏 */
    .ew-filter-bar {
        display: flex; align-items: center; gap: 16px; margin-bottom: 24px;
        flex-wrap: wrap;
    }
    .ew-filter-bar .ew-filter-label {
        font-size: 13px; color: #64748b; font-weight: 500;
    }
    .ew-filter-bar select {
        padding: 8px 16px; border-radius: 10px; border: 1.5px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff;
        font-family: 'Microsoft YaHei',sans-serif; cursor: pointer;
        transition: border-color .15s; outline: none;
    }
    .ew-filter-bar select:focus { border-color: #6366f1; }
    .ew-filter-bar .ew-filter-btn {
        padding: 8px 20px; border-radius: 10px; border: none;
        background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff;
        font-size: 13px; font-weight: 600; cursor: pointer;
        transition: all .15s; font-family: 'Microsoft YaHei',sans-serif;
    }
    .ew-filter-bar .ew-filter-btn:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1);
        box-shadow: 0 2px 8px rgba(99,102,241,.3);
    }
    .ew-stat {
        margin-left: auto; font-size: 13px; color: #94a3b8;
    }

    /* 范围切换按钮组 */
    .ew-scope-tabs {
        display: inline-flex; border-radius: 10px; overflow: hidden;
        border: 1.5px solid #e2e8f0; background: #fff;
    }
    .ew-scope-tabs button {
        padding: 7px 18px; border: none; background: transparent;
        font-size: 13px; font-weight: 500; color: #64748b;
        cursor: pointer; transition: all .15s;
        font-family: 'Microsoft YaHei',sans-serif;
        position: relative;
    }
    .ew-scope-tabs button:not(:last-child)::after {
        content: ''; position: absolute; right: 0; top: 20%; height: 60%;
        width: 1px; background: #e2e8f0;
    }
    .ew-scope-tabs button:hover { background: #f8fafc; color: #334155; }
    .ew-scope-tabs button.active {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff; font-weight: 600;
    }
    .ew-scope-tabs button.active::after { display: none; }
    .ew-scope-tabs button.disabled {
        opacity: .4; cursor: not-allowed;
    }
    .ew-scope-hint {
        font-size: 12px; color: #818cf8; font-weight: 500;
        background: #eef2ff; padding: 4px 12px; border-radius: 8px;
    }

    /* 作品网格 */
    .ew-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 20px; margin-bottom: 28px;
    }

    /* 单个作品卡片 */
    .ew-card {
        background: #fff; border-radius: 16px; border: 1px solid #e5e7eb;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden; transition: all .2s ease; cursor: pointer;
        text-decoration: none !important;
    }
    .ew-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 30px rgba(99,102,241,.12), 0 2px 8px rgba(0,0,0,.06);
        border-color: #c7d2fe;
    }
    .ew-card-thumb {
        width: 100%; aspect-ratio: 4/3;
        background: linear-gradient(145deg, #f0f4ff 0%, #e8ecf8 40%, #f5f0ff 100%);
        display: flex; align-items: center; justify-content: center;
        overflow: hidden; position: relative;
    }
    .ew-card-thumb::before {
        content: ''; position: absolute; inset: 0; z-index: 1;
        background: radial-gradient(ellipse at 30% 20%, rgba(99,102,241,.06) 0%, transparent 60%);
        pointer-events: none;
    }
    .ew-card-thumb::after {
        content: ''; position: absolute; inset: 0; z-index: 2;
        box-shadow: inset 0 0 0 1px rgba(0,0,0,.04), inset 0 -20px 30px -15px rgba(0,0,0,.03);
        border-radius: 16px 16px 0 0;
        pointer-events: none;
    }
    .ew-card-thumb img {
        width: 82%; height: 82%; object-fit: contain;
        transition: all .35s cubic-bezier(.4,0,.2,1);
        filter: drop-shadow(0 4px 12px rgba(0,0,0,.1));
        border-radius: 10px;
        position: relative; z-index: 1;
    }
    .ew-card-thumb img.has-thumbnail {
        width: 100%; height: 100%; object-fit: cover;
        border-radius: 0;
        filter: none;
    }
    .ew-card:hover .ew-card-thumb img {
        transform: scale(1.08);
        filter: drop-shadow(0 6px 20px rgba(99,102,241,.18));
    }
    .ew-card:hover .ew-card-thumb img.has-thumbnail {
        filter: brightness(1.03) saturate(1.1);
    }
    .ew-card-badge {
        position: absolute; top: 10px; right: 10px;
        background: linear-gradient(135deg, #f59e0b, #f97316); color: #fff;
        font-size: 11px; font-weight: 700; padding: 3px 10px;
        border-radius: 20px; display: flex; align-items: center; gap: 4px;
    }
    .ew-card-badge svg {
        width: 12px; height: 12px; fill: none; stroke: #fff;
        stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round;
    }
    .ew-card-info { padding: 14px 16px; }
    .ew-card-title {
        font-size: 14px; font-weight: 700; color: #1e293b;
        margin: 0 0 6px; overflow: hidden; text-overflow: ellipsis;
        white-space: nowrap; line-height: 1.4;
    }
    .ew-card-course {
        font-size: 12px; color: #64748b; margin: 0 0 10px;
        overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }
    .ew-card-meta {
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .ew-card-tag {
        font-size: 11px; padding: 2px 8px; border-radius: 6px;
        font-weight: 500;
    }
    .ew-tag-grade { background: #eef2ff; color: #4f46e5; }
    .ew-tag-class { background: #f0fdf4; color: #16a34a; }
    .ew-tag-vote { background: #fef3c7; color: #d97706; }
    .ew-card-author {
        font-size: 12px; color: #94a3b8; margin-left: auto;
        overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        max-width: 80px;
    }

    /* 空状态 */
    .ew-empty {
        text-align: center; padding: 80px 20px; color: #94a3b8;
    }
    .ew-empty svg {
        width: 64px; height: 64px; stroke: #d1d5db; fill: none;
        stroke-width: 1.2; stroke-linecap: round; stroke-linejoin: round;
        margin-bottom: 16px;
    }
    .ew-empty p { font-size: 15px; margin: 0; }

    /* 分页 */
    .ew-pager {
        display: flex; align-items: center; justify-content: center;
        gap: 6px; padding: 20px 0 10px;
    }
    .ew-pager a, .ew-pager span {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 36px; height: 36px; padding: 0 12px;
        border-radius: 10px; font-size: 13px; font-weight: 500;
        text-decoration: none !important; transition: all .15s;
    }
    .ew-pager a {
        color: #475569; background: #fff; border: 1px solid #e2e8f0;
    }
    .ew-pager a:hover {
        background: #eef2ff; border-color: #c7d2fe; color: #4f46e5;
    }
    .ew-pager span.ew-pager-current {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff; border: none; font-weight: 700;
    }
    .ew-pager span.ew-pager-info {
        color: #94a3b8; font-size: 12px; padding: 0 8px;
    }

    @media (max-width: 768px) {
        .ew-hero { padding: 24px 20px; border-radius: 14px; }
        .ew-hero h2 { font-size: 18px !important; }
        .ew-grid { grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 12px; }
        .ew-filter-bar { gap: 10px; }
        .ew-stat { margin-left: 0; width: 100%; }
    }
</style>

<div class="ew-page">
    <!-- 顶部标题 -->
    <div class="ew-hero">
        <h2>
            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            优秀作品展示
        </h2>
        <p>汇聚同学们的优秀创作，展示精彩作品，互相学习、共同进步</p>
    </div>

    <!-- 筛选栏 -->
    <div class="ew-filter-bar">
        <% if (IsLoggedIn) { %>
        <div class="ew-scope-tabs">
            <button type="button" onclick="switchScope('class')" class="<%= FilterScope=="class"?"active":"" %>">本班级</button>
            <button type="button" onclick="switchScope('grade')" class="<%= FilterScope=="grade"?"active":"" %>">本年级</button>
            <button type="button" onclick="switchScope('all')" class="<%= FilterScope=="all"?"active":"" %>">全部</button>
        </div>
        <% if (FilterScope == "class" && MyGrade > 0 && MyClass > 0) { %>
        <span class="ew-scope-hint"><%= MyGrade %>年级<%= MyClass %>班</span>
        <% } else if (FilterScope == "grade" && MyGrade > 0) { %>
        <span class="ew-scope-hint"><%= MyGrade %>年级</span>
        <% } %>
        <% } %>

        <% if (!IsLoggedIn || FilterScope == "all") { %>
        <select id="selGrade">
            <option value="0">全部年级</option>
            <option value="1" <%= filterGrade=="1"?"selected":"" %>>1年级</option>
            <option value="2" <%= filterGrade=="2"?"selected":"" %>>2年级</option>
            <option value="3" <%= filterGrade=="3"?"selected":"" %>>3年级</option>
            <option value="4" <%= filterGrade=="4"?"selected":"" %>>4年级</option>
            <option value="5" <%= filterGrade=="5"?"selected":"" %>>5年级</option>
            <option value="6" <%= filterGrade=="6"?"selected":"" %>>6年级</option>
            <option value="7" <%= filterGrade=="7"?"selected":"" %>>7年级</option>
            <option value="8" <%= filterGrade=="8"?"selected":"" %>>8年级</option>
            <option value="9" <%= filterGrade=="9"?"selected":"" %>>9年级</option>
        </select>
        <% } %>

        <select id="selTerm">
            <option value="0">全部学期</option>
            <option value="1" <%= filterTerm=="1"?"selected":"" %>>第1学期</option>
            <option value="2" <%= filterTerm=="2"?"selected":"" %>>第2学期</option>
        </select>
        <button type="button" class="ew-filter-btn" onclick="doFilter()">筛选</button>
        <span class="ew-stat">共 <strong><%= TotalRecords %></strong> 件优秀作品</span>
    </div>

    <!-- 作品网格 -->
    <% if (WorksData != null && WorksData.Rows.Count > 0) { %>
    <div class="ew-grid">
        <% foreach (System.Data.DataRow row in WorksData.Rows) {
            string wid = row["Wid"].ToString();
            string wname = row["Wname"] == DBNull.Value ? "" : row["Wname"].ToString();
            string wtitle = row["Wtitle"] == DBNull.Value ? "" : row["Wtitle"].ToString();
            string ctitle = row["Ctitle"] == DBNull.Value ? "" : row["Ctitle"].ToString();
            string wgrade = row["Wgrade"] == DBNull.Value ? "" : row["Wgrade"].ToString();
            string wclass = row["Wclass"] == DBNull.Value ? "" : row["Wclass"].ToString();
            int wvote = row["Wvote"] == DBNull.Value ? 0 : Convert.ToInt32(row["Wvote"]);
            string thumbUrl = GetWorkThumbnailUrl(row["Wthumbnail"], row["Wtype"]);
            string rawThumb = row["Wthumbnail"] == DBNull.Value ? "" : row["Wthumbnail"].ToString();
            bool hasThumbnail = !string.IsNullOrEmpty(rawThumb);
            string displayTitle = !string.IsNullOrEmpty(wtitle) ? wtitle : (!string.IsNullOrEmpty(ctitle) ? ctitle : "优秀作品");
            string detailUrl = "downwork.aspx?Wid=" + wid;
        %>
        <a href="<%= detailUrl %>" target="_blank" class="ew-card">
            <div class="ew-card-thumb">
                <img src="<%= thumbUrl %>" alt="<%= Server.HtmlEncode(displayTitle) %>" class="<%= hasThumbnail ? "has-thumbnail" : "" %>" onerror="this.src='<%= GetSiteLogoUrl() %>';this.classList.remove('has-thumbnail');" />
                <div class="ew-card-badge">
                    <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                    优秀
                </div>
            </div>
            <div class="ew-card-info">
                <div class="ew-card-title"><%= Server.HtmlEncode(displayTitle) %></div>
                <% if (!string.IsNullOrEmpty(ctitle)) { %>
                <div class="ew-card-course">📖 <%= Server.HtmlEncode(ctitle) %></div>
                <% } %>
                <div class="ew-card-meta">
                    <% if (!string.IsNullOrEmpty(wgrade) && wgrade != "0") { %>
                    <span class="ew-card-tag ew-tag-grade"><%= wgrade %>年级</span>
                    <% } %>
                    <% if (!string.IsNullOrEmpty(wclass) && wclass != "0") { %>
                    <span class="ew-card-tag ew-tag-class"><%= wclass %>班</span>
                    <% } %>
                    <% if (wvote > 0) { %>
                    <span class="ew-card-tag ew-tag-vote">🌸 <%= wvote %></span>
                    <% } %>
                    <span class="ew-card-author"><%= Server.HtmlEncode(wname) %></span>
                </div>
            </div>
        </a>
        <% } %>
    </div>

    <!-- 分页 -->
    <% if (TotalPages > 1) { %>
    <div class="ew-pager">
        <% if (CurrentPage > 0) { %>
        <a href="<%= BuildPageUrl(0) %>">首页</a>
        <a href="<%= BuildPageUrl(CurrentPage - 1) %>">上一页</a>
        <% } %>

        <% 
        int startP = Math.Max(0, CurrentPage - 3);
        int endP = Math.Min(TotalPages - 1, CurrentPage + 3);
        for (int i = startP; i <= endP; i++) {
            if (i == CurrentPage) { %>
                <span class="ew-pager-current"><%= i + 1 %></span>
            <% } else { %>
                <a href="<%= BuildPageUrl(i) %>"><%= i + 1 %></a>
            <% }
        } %>

        <% if (CurrentPage < TotalPages - 1) { %>
        <a href="<%= BuildPageUrl(CurrentPage + 1) %>">下一页</a>
        <a href="<%= BuildPageUrl(TotalPages - 1) %>">尾页</a>
        <% } %>
        <span class="ew-pager-info">第 <%= CurrentPage + 1 %>/<%= TotalPages %> 页</span>
    </div>
    <% } %>

    <% } else { %>
    <!-- 空状态 -->
    <div class="ew-empty">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
        <p>暂无优秀作品，快去创作属于你的精彩作品吧！</p>
    </div>
    <% } %>
</div>

<script type="text/javascript">
    var currentScope = '<%= Server.HtmlEncode(FilterScope) %>';

    function switchScope(scope) {
        var url = 'excellentwork.aspx?p=0&scope=' + scope;
        var termEl = document.getElementById('selTerm');
        if (termEl) {
            var term = termEl.value;
            if (term && term !== '0') url += '&term=' + term;
        }
        window.location.href = url;
    }

    function doFilter() {
        var term = document.getElementById('selTerm').value;
        var url = 'excellentwork.aspx?p=0&scope=' + currentScope;
        if (currentScope === 'all') {
            var gradeEl = document.getElementById('selGrade');
            if (gradeEl) {
                var grade = gradeEl.value;
                if (grade && grade !== '0') url += '&grade=' + grade;
            }
        }
        if (term && term !== '0') url += '&term=' + term;
        window.location.href = url;
    }
</script>
</asp:Content>
