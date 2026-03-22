<%@ Page Language="C#" MasterPageFile="~/student/Stud.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int currentStudentId = 0;
    protected bool hasResources = false;
    protected string statTotalFiles = "0";
    protected string statTotalFolders = "0";
    protected string statTotalSize = "0 B";
    
    private string GetConnStr()
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
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }
    
    private int GetCurrentStudentId()
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
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null)
                        {
                            int sid;
                            if (int.TryParse(v.ToString(), out sid)) return sid;
                        }
                    }
                }
            }
        }
        catch { }
        return 0;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        currentStudentId = GetCurrentStudentId();
        
        if (!IsPostBack)
        {
            LoadStatistics();
            BindFileList();
        }
    }

    protected void LoadStatistics()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Files", conn);
            statTotalFiles = cmd.ExecuteScalar().ToString();
            
            cmd.CommandText = "SELECT COUNT(*) FROM Folders";
            statTotalFolders = cmd.ExecuteScalar().ToString();
            
            cmd.CommandText = "SELECT ISNULL(SUM(FileSize), 0) FROM Files";
            long totalBytes = Convert.ToInt64(cmd.ExecuteScalar());
            statTotalSize = FormatFileSize(totalBytes);
        }
    }

    protected void BindFileList()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        string searchKeyword = Request.QueryString["q"];
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string sql = @"SELECT TOP 100 
                          f.FileId, f.FileName, f.FileSize, f.CreateTime, f.RelativePath, f.UserSnum,
                          ISNULL(d.FolderName, N'未分类') as FolderName
                          FROM Files f
                          LEFT JOIN Folders d ON f.FolderId = d.FolderId";
            
            if (!string.IsNullOrEmpty(searchKeyword))
            {
                sql += " WHERE f.FileName LIKE @Keyword";
            }
            
            sql += " ORDER BY f.CreateTime DESC";
            
            SqlCommand cmd = new SqlCommand(sql, conn);
            
            if (!string.IsNullOrEmpty(searchKeyword))
            {
                cmd.Parameters.AddWithValue("@Keyword", "%" + searchKeyword + "%");
            }
            
            try
            {
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                hasResources = dt.Rows.Count > 0;
                
                rptResources.DataSource = dt;
                rptResources.DataBind();
            }
            catch (Exception ex)
            {
                hasResources = false;
                System.Diagnostics.Debug.WriteLine("Error loading files: " + ex.Message);
            }
        }
    }

    protected string FormatFileSize(object size)
    {
        if (size == null || size == DBNull.Value) return "0 B";
        long bytes = Convert.ToInt64(size);
        return FormatFileSize(bytes);
    }

    protected string FormatFileSize(long bytes)
    {
        if (bytes >= 1073741824L) return (bytes / 1073741824.0).ToString("F2") + " GB";
        if (bytes >= 1048576L) return (bytes / 1048576.0).ToString("F1") + " MB";
        if (bytes >= 1024L) return (bytes / 1024.0).ToString("F1") + " KB";
        return bytes + " B";
    }

    protected string GetFileExtension(object fileName)
    {
        if (fileName == null || fileName == DBNull.Value) return "";
        string name = fileName.ToString();
        int dotIndex = name.LastIndexOf('.');
        if (dotIndex >= 0 && dotIndex < name.Length - 1)
            return name.Substring(dotIndex + 1).ToUpper();
        return "FILE";
    }

    protected string GetFileIconColor(object fileName)
    {
        string ext = GetFileExtension(fileName).ToLower();
        switch (ext)
        {
            case "pdf": return "#e74c3c";
            case "doc": case "docx": return "#2b579a";
            case "xls": case "xlsx": return "#217346";
            case "ppt": case "pptx": return "#d24726";
            case "zip": case "rar": case "7z": return "#f39c12";
            case "jpg": case "jpeg": case "png": case "gif": case "bmp": return "#9b59b6";
            case "mp4": case "avi": case "mov": case "wmv": return "#e91e63";
            case "mp3": case "wav": case "flac": return "#00bcd4";
            case "txt": case "md": return "#607d8b";
            case "cs": case "js": case "py": case "java": case "cpp": case "html": case "css": return "#4caf50";
            default: return "#64748b";
        }
    }

    protected string FormatDate(object date)
    {
        if (date == null || date == DBNull.Value) return "";
        DateTime dt = Convert.ToDateTime(date);
        return dt.ToString("yyyy-MM-dd HH:mm");
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="server">
<style>
    *, *::before, *::after { box-sizing: border-box; }
    .mf-wrap { max-width: 1600px; margin: 0 auto; padding: 22px 28px 48px; }
    .resource-browse-container::before{
        content:'';position:fixed;inset:0;z-index:-1;
        background:
            radial-gradient(1000px 500px at 10% -10%, rgba(99,102,241,.10), transparent 70%),
            radial-gradient(900px 500px at 100% 0%, rgba(14,165,233,.10), transparent 70%),
            #f8fafc;
    }
    
    /* === Hero bar === */
    .mf-hero {
        background:#fff; border-radius:16px; padding:20px 28px; margin-bottom:14px;
        box-shadow:0 1px 8px rgba(0,0,0,.05);
        display:flex; align-items:center; gap:0;
    }
    .mf-hero-left { flex:1; min-width:0; }
    .mf-hero-left h1 {
        font-size:19px; font-weight:700; color:#0f172a;
        margin:0 0 4px; display:flex; align-items:center; gap:9px;
    }
    .mf-hero-left h1 svg { flex-shrink:0; }
    .mf-hero-left p { font-size:13px; color:#94a3b8; margin:0; }
    .mf-stats { display:flex; flex-shrink:0; }
    .mf-stat {
        padding:0 24px; text-align:center;
        border-left:1px solid #f1f5f9;
    }
    .mf-stat-n {
        font-size:20px; font-weight:800; color:#1e293b;
        line-height:1; letter-spacing:-0.5px;
    }
    .mf-stat-l {
        font-size:11px; color:#94a3b8; margin-top:5px;
        font-weight:500; text-transform:uppercase; letter-spacing:0.05em;
    }
    /* === View toggle === */
    .mf-view-tog { display:flex; gap:3px; flex-shrink:0; background:#f1f5f9; border-radius:9px; padding:3px; }
    .mf-vbtn {
        width:34px; height:34px; border:none; border-radius:7px;
        background:transparent; cursor:pointer; transition:all .15s;
        display:flex; align-items:center; justify-content:center; color:#94a3b8;
    }
    .mf-vbtn svg { width:16px; height:16px; }
    .mf-vbtn.active { background:#fff; color:#6366f1; box-shadow:0 1px 4px rgba(0,0,0,.1); }
    .mf-vbtn:hover:not(.active) { color:#64748b; }
    /* === Toolbar === */
    .mf-toolbar {
        display:flex; align-items:center; gap:10px;
        background:#fff; border-radius:14px;
        padding:12px 18px; margin-bottom:14px;
        box-shadow:0 1px 8px rgba(0,0,0,.05);
    }
    .mf-srch {
        flex:1; display:flex; align-items:center; gap:8px;
        background:#f8fafc; border:1.5px solid #e8ecf2;
        border-radius:9px; padding:8px 12px; transition:all .2s;
    }
    .mf-srch:focus-within {
        background:#fff; border-color:#6366f1;
        box-shadow:0 0 0 3px rgba(99,102,241,.1);
    }
    .mf-srch svg { width:15px; height:15px; color:#94a3b8; flex-shrink:0; }
    .mf-srch input {
        border:none; outline:none; background:transparent;
        font-size:14px; color:#334155; width:100%; font-family:inherit;
    }
    .mf-srch input::placeholder { color:#c0c8d8; }
    .mf-btn-s {
        padding:9px 20px; background:#6366f1; color:#fff;
        border:none; border-radius:9px; font-size:13px; font-weight:600;
        cursor:pointer; transition:all .2s; font-family:inherit; white-space:nowrap;
    }
    .mf-btn-s:hover { background:#4f46e5; transform:translateY(-1px); }
    .mf-btn-r {
        padding:9px 14px; background:#f1f5f9; color:#64748b;
        border:none; border-radius:9px; font-size:13px; font-weight:500;
        cursor:pointer; transition:all .2s; font-family:inherit;
        text-decoration:none; display:inline-flex; align-items:center; white-space:nowrap;
    }
    .mf-btn-r:hover { background:#e2e8f0; color:#334155; }
    /* === Content wrapper === */
    .mf-content { background:#fff; border-radius:16px; box-shadow:0 1px 8px rgba(0,0,0,.05); overflow:hidden; }
    /* === Table header === */
    .mf-th {
        display:grid;
        grid-template-columns:minmax(0,1fr) 120px 160px 100px 72px;
        padding:10px 24px;
        font-size:11px; font-weight:600; color:#94a3b8;
        text-transform:uppercase; letter-spacing:.06em;
        background:#fafbfc; border-bottom:1px solid #f1f5f9;
    }
    .view-card .mf-th { display:none; }
    /* === Items wrap (card grid) === */
    .view-card .mf-items-wrap {
        display:grid;
        grid-template-columns:repeat(auto-fill, minmax(240px, 1fr));
        gap:20px; padding:20px;
    }
    /* === Item: CARD mode === */
    .view-card .mf-item {
        border-radius:14px; overflow:hidden; cursor:pointer;
        border:1.5px solid #f1f5f9; background:#fff;
        transition:all .25s cubic-bezier(.4,0,.2,1);
    }
    .view-card .mf-item:hover {
        border-color:#6366f1;
        box-shadow:0 8px 24px rgba(99,102,241,.18);
        transform:translateY(-3px);
    }
    .view-card .mf-item .lp { display:none; }
    /* === Item: LIST mode === */
    .view-list .mf-item {
        display:grid;
        grid-template-columns:minmax(0,1fr) 120px 160px 100px 72px;
        align-items:center;
        border-bottom:1px solid #f8fafc;
        cursor:pointer; transition:background .1s;
    }
    .view-list .mf-item:last-child { border-bottom:none; }
    .view-list .mf-item:hover { background:#fafaff; }
    .view-list .mf-item .cp { display:none; }
    .view-list .mf-item .lp { display:contents; }
    /* === Card part (cp) === */
    .cp-cover {
        width:100%; height:130px;
        display:flex; align-items:center; justify-content:center;
        position:relative; overflow:hidden;
    }
    .cp-cover::before {
        content:''; position:absolute; inset:0;
        background:radial-gradient(circle at 25% 40%, rgba(255,255,255,.2), transparent 60%);
    }
    .cp-cover svg { position:relative; z-index:1; filter:drop-shadow(0 2px 8px rgba(0,0,0,.25)); }
    .cp-ext {
        position:absolute; top:10px; left:10px;
        background:rgba(255,255,255,.95); border-radius:6px;
        padding:3px 8px; font-size:10px; font-weight:800; letter-spacing:.04em;
        box-shadow:0 2px 6px rgba(0,0,0,.1); backdrop-filter:blur(8px);
    }
    .cp-body { padding:14px 16px 16px; }
    .cp-name {
        font-size:13.5px; font-weight:700; color:#1e293b; margin-bottom:10px;
        display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
        line-height:1.45;
    }
    .cp-info { display:flex; flex-wrap:wrap; gap:6px; margin-bottom:10px; }
    .cp-tag {
        display:inline-flex; align-items:center; gap:4px;
        background:#f8fafc; border-radius:6px; padding:4px 8px;
        font-size:11.5px; color:#64748b; font-weight:500;
    }
    .cp-tag svg { width:11px; height:11px; }
    .cp-footer {
        display:flex; align-items:center; justify-content:space-between;
        padding-top:10px; border-top:1px solid #f1f5f9;
    }
    .cp-date { font-size:11px; color:#94a3b8; }
    .cp-act { display:flex; gap:2px; }
    .cp-ab {
        width:28px; height:28px; border-radius:7px; border:none;
        background:transparent; cursor:pointer; transition:all .15s;
        display:flex; align-items:center; justify-content:center; text-decoration:none;
    }
    .cp-ab svg { width:14px; height:14px; }
    .cp-abv { color:#6366f1; }
    .cp-abv:hover { background:#eef2ff; }
    .cp-abd { color:#10b981; }
    .cp-abd:hover { background:#ecfdf5; }
    /* === List part cells === */
    .lp-file { display:flex; align-items:center; gap:12px; min-width:0; padding:13px 24px; }
    .lp-cat,.lp-date,.lp-size { padding:13px 0; }
    .lp-act { display:flex; gap:3px; justify-content:flex-end; padding-right:24px; }
    .mf-ficon {
        width:36px; height:36px; border-radius:8px; flex-shrink:0;
        display:flex; align-items:center; justify-content:center;
        font-size:8.5px; font-weight:800; letter-spacing:.03em; color:#fff;
    }
    .mf-fn { font-size:13.5px; font-weight:600; color:#1e293b; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .mf-fu { font-size:11.5px; color:#94a3b8; margin-top:2px; display:flex; align-items:center; gap:3px; }
    .mf-fu svg { width:10px; height:10px; }
    .lp-cat { font-size:12.5px; color:#64748b; }
    .lp-date { font-size:12px; color:#94a3b8; }
    .lp-size { font-size:12.5px; color:#475569; font-weight:500; }
    .mf-ab {
        width:28px; height:28px; border-radius:7px; border:none;
        background:transparent; cursor:pointer; transition:all .15s;
        display:flex; align-items:center; justify-content:center; text-decoration:none;
    }
    .mf-ab svg { width:14px; height:14px; }
    .mf-abv { color:#6366f1; }
    .mf-abv:hover { background:#eef2ff; }
    .mf-abd { color:#10b981; }
    .mf-abd:hover { background:#ecfdf5; }
    /* === Empty === */
    .mf-empty { padding:60px 24px; text-align:center; }
    .mf-empty-icon {
        width:64px; height:64px; border-radius:16px; background:#f8fafc;
        display:inline-flex; align-items:center; justify-content:center; margin-bottom:16px;
    }
    .mf-empty-icon svg { width:28px; height:28px; }
    .mf-empty p { margin:0 0 6px; font-size:15px; font-weight:600; color:#475569; }
    .mf-empty span { font-size:13px; color:#94a3b8; }
    @media(max-width:1100px){
        .mf-th { grid-template-columns:minmax(0,1fr) 100px 100px 80px 64px; }
        .view-list .mf-item { grid-template-columns:minmax(0,1fr) 100px 100px 80px 64px; }
    }
    @media(max-width:800px){
        .mf-th { display:none !important; }
        .view-list .mf-item { grid-template-columns:minmax(0,1fr) 80px 60px; }
        .view-list .lp-date { display:none; }
        .view-card .mf-items-wrap { grid-template-columns:repeat(auto-fill, minmax(200px,1fr)); gap:14px; padding:14px; }
    }
    @media(max-width:600px){
        .mf-stats { display:none; }
        .mf-wrap { padding:14px 14px 32px; }
        .view-card .mf-items-wrap { grid-template-columns:repeat(2,1fr); }
        .view-list .lp-cat { display:none; }
        .view-list .mf-item { grid-template-columns:minmax(0,1fr) 60px; }
    }
</style>

<div class="mf-wrap">

    <%-- Hero bar with stats --%>
    <div class="mf-hero">
        <div class="mf-hero-left">
            <h1>
                <svg viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" style="width:20px;height:20px">
                    <path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/>
                </svg>
                学习资源库
            </h1>
            <p>浏览和下载各类教学资源</p>
        </div>
        <div class="mf-stats">
            <div class="mf-stat">
                <div class="mf-stat-n"><%= statTotalFiles %></div>
                <div class="mf-stat-l">文件</div>
            </div>
            <div class="mf-stat">
                <div class="mf-stat-n"><%= statTotalFolders %></div>
                <div class="mf-stat-l">分类</div>
            </div>
            <div class="mf-stat">
                <div class="mf-stat-n"><%= statTotalSize %></div>
                <div class="mf-stat-l">总大小</div>
            </div>
        </div>
    </div>

    <%-- Toolbar with search + view toggle --%>
    <div class="mf-toolbar">
        <label class="mf-srch">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input type="text" id="mfSrchQ" placeholder="搜索文件名..."
                   value="<%= Server.HtmlEncode(Request.QueryString["q"] ?? "") %>"
                   onkeydown="if(event.keyCode===13)location='myfile.aspx?q='+encodeURIComponent(this.value)" />
        </label>
        <button type="button" class="mf-btn-s"
                onclick="location='myfile.aspx?q='+encodeURIComponent(document.getElementById('mfSrchQ').value)">搜索</button>
        <a href="myfile.aspx" class="mf-btn-r">重置</a>
        <div class="mf-view-tog">
            <button id="btnListView" type="button" class="mf-vbtn" onclick="mfSetView('list')" title="列表视图">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/>
                    <line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>
                </svg>
            </button>
            <button id="btnCardView" type="button" class="mf-vbtn" onclick="mfSetView('card')" title="卡片视图">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
                    <rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
                </svg>
            </button>
        </div>
    </div>

    <%-- Content area: class toggles between view-list / view-card --%>
    <div class="mf-content view-list" id="mfContent">
        <div class="mf-th">
            <span>文件</span><span>分类</span><span>上传时间</span><span>大小</span><span></span>
        </div>
        <div class="mf-items-wrap">
            <asp:Repeater ID="rptResources" runat="server">
                <ItemTemplate>
                    <div class="mf-item" onclick="window.location='resourcedetail.aspx?fid=<%# Eval("FileId") %>'">

                        <%-- Card part --%>
                        <div class="cp">
                            <div class="cp-cover" style='background:linear-gradient(135deg,<%# GetFileIconColor(Eval("FileName")) %> 0%,#0f172a 100%)'>
                                <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5" style="width:48px;height:48px">
                                    <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                                </svg>
                                <div class="cp-ext" style='color:<%# GetFileIconColor(Eval("FileName")) %>'><%# GetFileExtension(Eval("FileName")) %></div>
                            </div>
                            <div class="cp-body">
                                <div class="cp-name"><%# Eval("FileName") %></div>
                                <div class="cp-info">
                                    <span class="cp-tag">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/></svg>
                                        <%# Eval("FolderName") %>
                                    </span>
                                    <span class="cp-tag">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"/></svg>
                                        <%# FormatFileSize(Eval("FileSize")) %>
                                    </span>
                                </div>
                                <div class="cp-footer">
                                    <span class="cp-date"><%# FormatDate(Eval("CreateTime")) %></span>
                                    <div class="cp-act">
                                        <a href='resourcedetail.aspx?fid=<%# Eval("FileId") %>' class="cp-ab cp-abv" onclick="event.stopPropagation()" title="查看详情">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                        </a>
                                        <a href='<%# Eval("RelativePath") %>' class="cp-ab cp-abd" download onclick="event.stopPropagation()" title="下载">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- List part (display:contents in list mode) --%>
                        <div class="lp">
                            <div class="lp-file">
                                <div class="mf-ficon" style='background:<%# GetFileIconColor(Eval("FileName")) %>'><%# GetFileExtension(Eval("FileName")) %></div>
                                <div style="min-width:0">
                                    <div class="mf-fn"><%# Eval("FileName") %></div>
                                    <div class="mf-fu">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                        <%# Eval("UserSnum") %>
                                    </div>
                                </div>
                            </div>
                            <span class="lp-cat"><%# Eval("FolderName") %></span>
                            <span class="lp-date"><%# FormatDate(Eval("CreateTime")) %></span>
                            <span class="lp-size"><%# FormatFileSize(Eval("FileSize")) %></span>
                            <div class="lp-act">
                                <a href='resourcedetail.aspx?fid=<%# Eval("FileId") %>' class="mf-ab mf-abv" onclick="event.stopPropagation()" title="查看详情">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                </a>
                                <a href='<%# Eval("RelativePath") %>' class="mf-ab mf-abd" download onclick="event.stopPropagation()" title="下载">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
                                </a>
                            </div>
                        </div>

                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <% if (!hasResources) { %>
        <div class="mf-empty">
            <div class="mf-empty-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.5"><path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/></svg>
            </div>
            <p>暂无匹配资源</p>
            <span>尝试更换关键词，或稍后再来查看</span>
        </div>
        <% } %>
    </div>

</div>

<script type="text/javascript">
function mfSetView(mode) {
    var el = document.getElementById('mfContent');
    if (!el) return;
    el.classList.remove('view-list', 'view-card');
    el.classList.add('view-' + mode);
    var bL = document.getElementById('btnListView');
    var bC = document.getElementById('btnCardView');
    if (bL) bL.classList.toggle('active', mode === 'list');
    if (bC) bC.classList.toggle('active', mode === 'card');
    try { localStorage.setItem('mf_view_mode', mode); } catch(e) {}
}
(function() {
    var pref = 'list';
    try { var s = localStorage.getItem('mf_view_mode'); if (s) pref = s; } catch(e) {}
    mfSetView(pref);
})();
</script>

</asp:Content>
