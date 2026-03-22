<%@ page title="" language="C#" validaterequest="false" autoeventwireup="true" inherits="Lessons_thinkedit, LearnSite" %>

<script runat="server">
    protected string tUserName = "";
    protected string tUserInitial = "\u5E08";
    protected string tUserAvatarUrl = "";
    private static System.Reflection.BindingFlags _bf = System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        int hid = 0;
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", _bf);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo pn = ct.GetProperty("Hname");
                    if (pn != null) { string n = pn.GetValue(m, null) as string; if (!string.IsNullOrEmpty(n)) { tUserName = n; tUserInitial = n.Substring(0, 1); } }
                    System.Reflection.PropertyInfo pi = ct.GetProperty("Hid");
                    if (pi != null) { string s = (pi.GetValue(m, null) ?? "").ToString(); int.TryParse(s, out hid); }
                }
            }
        }
        catch { }
        if (hid > 0)
        {
            string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
            foreach (string ext in exts)
            {
                string fp = Server.MapPath("~/images/avatars/" + hid + ext);
                if (System.IO.File.Exists(fp)) { tUserAvatarUrl = ResolveUrl("~/images/avatars/" + hid + ext) + "?t=" + System.IO.File.GetLastWriteTime(fp).Ticks; break; }
            }
        }
    }
</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>编辑反思</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script src="../js/MenuCookie.js" type="text/javascript"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; width: 100%; overflow: hidden; margin: 0; }
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
            background: #f0f2f5; color: #1e293b;
        }
        #form1 { width: 100%; height: 100%; margin: 0; padding: 0; }
        .layout-wrapper { display: flex; width: 100%; height: 100vh; overflow: hidden; position: relative; }

        /* ===== Sidebar ===== */
        .sidebar {
            width: 220px; min-width: 220px; max-width: 220px; height: 100vh;
            background: #fff; border-right: 1px solid #e8ecf1;
            display: flex; flex-direction: column; flex-shrink: 0; flex-grow: 0;
            transition: width 0.3s ease, min-width 0.3s ease, max-width 0.3s ease;
            z-index: 100; position: relative; box-shadow: 2px 0 8px rgba(0,0,0,0.03);
        }
        .sidebar.collapsed { width: 64px; min-width: 64px; max-width: 64px; }
        .sidebar.collapsed .sidebar-brand-text,
        .sidebar.collapsed .nav-text,
        .sidebar.collapsed .nav-group-label,
        .sidebar.collapsed .sidebar-footer-text { display: none; }
        .sidebar.collapsed .nav-item { justify-content: center; padding: 0; }
        .sidebar.collapsed .nav-icon { margin-right: 0; }
        .sidebar.collapsed .sidebar-brand { justify-content: center; padding: 0 8px; }

        .sidebar-brand {
            height: 60px; display: flex; align-items: center; padding: 0 20px;
            border-bottom: 1px solid #f1f5f9; flex-shrink: 0; gap: 10px; cursor: pointer;
        }
        .sidebar-brand-logo {
            width: 32px; height: 32px; display: flex; align-items: center;
            justify-content: center; flex-shrink: 0;
        }
        .sidebar-brand-text {
            font-size: 15px; font-weight: 700; color: #1e293b;
            white-space: nowrap; overflow: hidden;
        }
        .sidebar-nav { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 12px 8px; }
        .sidebar-nav::-webkit-scrollbar { width: 4px; }
        .sidebar-nav::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 4px; }
        .nav-group-label {
            font-size: 11px; font-weight: 600; color: #94a3b8;
            text-transform: uppercase; letter-spacing: 0.5px;
            padding: 16px 12px 6px; white-space: nowrap;
        }
        .nav-item {
            display: flex; align-items: center; padding: 0 12px; height: 40px;
            border-radius: 8px; color: #64748b; text-decoration: none;
            font-size: 13.5px; font-weight: 500; transition: all 0.15s ease;
            margin-bottom: 2px; white-space: nowrap; cursor: pointer;
        }
        .nav-item:hover { background: #f1f5f9; color: #334155; }
        .nav-item.active {
            background: linear-gradient(135deg, #eef2ff, #e0e7ff);
            color: #4f46e5; font-weight: 600;
        }
        .nav-item.active .nav-icon { color: #6366f1; }
        .nav-icon {
            width: 32px; height: 32px; display: flex; align-items: center;
            justify-content: center; margin-right: 10px; flex-shrink: 0;
            border-radius: 8px; background: #f1f5f9; transition: all 0.15s;
        }
        .nav-icon svg {
            width: 18px; height: 18px; stroke: #94a3b8; fill: none;
            stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
            transition: stroke 0.15s;
        }
        .nav-item:hover .nav-icon { background: #e2e8f0; }
        .nav-item:hover .nav-icon svg { stroke: #475569; }
        .nav-item.active .nav-icon { background: #e0e7ff; }
        .nav-item.active .nav-icon svg { stroke: #6366f1; }
        .nav-text { white-space: nowrap; }
        .sidebar-footer { padding: 12px; border-top: 1px solid #f1f5f9; flex-shrink: 0; }
        .sidebar-footer-text { font-size: 11px; color: #94a3b8; text-align: center; padding: 4px 0 0; }

        /* ===== Main Area ===== */
        .main-area {
            flex: 1 1 0%; display: flex; flex-direction: column;
            overflow: hidden; min-width: 0; width: 0;
        }
        .top-header {
            height: 60px; background: #fff; border-bottom: 1px solid #e8ecf1;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 24px; flex-shrink: 0; box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .header-left { display: flex; align-items: center; gap: 16px; }
        .toggle-btn {
            width: 36px; height: 36px; border: none; background: #f1f5f9;
            border-radius: 8px; cursor: pointer; display: flex; align-items: center;
            justify-content: center; font-size: 18px; color: #64748b; transition: all 0.2s;
        }
        .toggle-btn:hover { background: #e2e8f0; color: #334155; }
        .header-title { font-size: 15px; font-weight: 600; color: #1e293b; }
        .header-right { display: flex; align-items: center; gap: 16px; }
        .header-time { font-size: 12px; color: #94a3b8; display: flex; align-items: center; gap: 4px; }
        .user-dropdown-wrap { position: relative; }
        .user-trigger {
            display: flex; align-items: center; gap: 8px;
            padding: 4px 10px 4px 4px; background: #f8fafc;
            border-radius: 24px; border: 1px solid #e2e8f0;
            cursor: pointer; transition: all 0.2s; user-select: none;
        }
        .user-trigger:hover { border-color: #cbd5e1; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        .user-trigger.open { border-color: #818cf8; box-shadow: 0 2px 8px rgba(99,102,241,0.12); }
        .user-avatar {
            width: 32px; height: 32px; background: linear-gradient(135deg, #6366f1, #a78bfa);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 14px; font-weight: 700; flex-shrink: 0; overflow: hidden;
        }
        .user-avatar img { width:100%; height:100%; object-fit:cover; }
        .user-trigger-name {
            font-size: 13px; font-weight: 500; color: #475569;
            max-width: 80px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .user-trigger-arrow {
            width: 16px; height: 16px; stroke: #94a3b8; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; transition: transform 0.2s;
        }
        .user-trigger.open .user-trigger-arrow { transform: rotate(180deg); }
        .user-dropdown {
            position: absolute; top: calc(100% + 8px); right: 0; width: 200px;
            background: #fff; border: 1px solid #e2e8f0; border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1), 0 2px 8px rgba(0,0,0,0.04);
            padding: 6px; opacity: 0; visibility: hidden; transform: translateY(-6px);
            transition: all 0.2s ease; z-index: 999;
        }
        .user-dropdown.show { opacity: 1; visibility: visible; transform: translateY(0); }
        .dropdown-header { padding: 10px 12px 8px; border-bottom: 1px solid #f1f5f9; margin-bottom: 4px; }
        .dropdown-header .dh-name { font-size: 13px; font-weight: 600; color: #1e293b; }
        .dropdown-header .dh-role { font-size: 11px; color: #94a3b8; margin-top: 1px; }
        .dropdown-item {
            display: flex; align-items: center; gap: 10px; padding: 9px 12px;
            border-radius: 8px; font-size: 13px; color: #475569;
            text-decoration: none; transition: all 0.12s; cursor: pointer;
        }
        .dropdown-item:hover { background: #f1f5f9; color: #1e293b; }
        .dropdown-item svg {
            width: 16px; height: 16px; stroke: #94a3b8; fill: none;
            stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
            flex-shrink: 0; transition: stroke 0.12s;
        }
        .dropdown-item:hover svg { stroke: #475569; }
        .dropdown-divider { height: 1px; background: #f1f5f9; margin: 4px 0; }
        .dropdown-item.logout { color: #ef4444; }
        .dropdown-item.logout:hover { background: #fef2f2; color: #dc2626; }
        .dropdown-item.logout svg { stroke: #f87171; }
        .dropdown-item.logout:hover svg { stroke: #dc2626; }
        .content-area { flex: 1; overflow-y: auto; overflow-x: auto; padding: 20px 24px; }
        .content-area::-webkit-scrollbar { width: 6px; }
        .content-area::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }

        /* ===== Edit Page ===== */
        .edit-page { max-width: 1400px; margin: 0 auto; }
        .page-title-bar {
            display: flex; align-items: center; margin-bottom: 20px;
        }
        .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #f59e0b, #fbbf24);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }

        /* 卡片容器 */
        .form-card {
            background: #fff; border-radius: 14px; border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.02);
            overflow: hidden;
        }
        .form-card-header {
            padding: 20px 28px;
            background: #fff; color: #1e293b;
            border-bottom: 1px solid #e8ecf1;
        }
        .form-card-header h3 {
            font-size: 18px; font-weight: 700;
            display: flex; align-items: center; gap: 10px;
        }
        .form-card-header h3 svg {
            width: 22px; height: 22px; stroke: #f59e0b; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .form-card-header .course-name {
            font-size: 13px; color: #64748b; margin-top: 6px; font-weight: 400;
        }
        .form-card-body { padding: 28px; }
        .field-label { font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block; }
        .editor-wrap {
            margin-top: 20px; border: 1px solid #e8ecf1; border-radius: 10px; overflow: hidden;
        }
        /* KindEditor 美化 */
        .editor-wrap .ke-container { border: none !important; }
        .editor-wrap .ke-toolbar {
            background: #f8fafc !important; border-bottom: 1px solid #e8ecf1 !important;
            padding: 8px 12px !important;
        }
        .editor-wrap .ke-toolbar .ke-outline {
            border-radius: 6px !important; padding: 2px !important;
            transition: all 0.15s ease;
        }
        .editor-wrap .ke-toolbar .ke-outline:hover {
            background: #e2e8f0 !important; border-color: #cbd5e1 !important;
        }
        .editor-wrap .ke-edit { border: none !important; }
        .editor-wrap .ke-statusbar { background: #f8fafc !important; border-top: 1px solid #e8ecf1 !important; }
        .form-card-footer {
            padding: 18px 28px; background: #f8fafc; border-top: 1px solid #e8ecf1;
            display: flex; align-items: center; justify-content: space-between;
        }
        .form-card-footer .msg-area { font-size: 13px; color: #64748b; }
        .form-card-footer .btn-group { display: flex; gap: 10px; }
        .btn-submit {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 10px 28px; border-radius: 10px; border: none;
            background: linear-gradient(135deg, #f59e0b, #fbbf24);
            color: #fff; font-size: 14px; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(245,158,11,0.25);
        }
        .btn-submit:hover {
            background: linear-gradient(135deg, #d97706, #f59e0b);
            box-shadow: 0 4px 16px rgba(245,158,11,0.35); transform: translateY(-1px);
        }
        .btn-back {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 10px 24px; border-radius: 10px;
            border: 1px solid #d1d5db; background: #fff;
            color: #475569; font-size: 14px; font-weight: 500;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-back:hover { border-color: #818cf8; color: #4f46e5; background: #f5f3ff; }

        /* ===== 说明板块 ===== */
        .info-banner {
            display: flex; align-items: flex-start; gap: 16px;
            padding: 18px 22px; margin-bottom: 20px; position: relative;
            background: #fff;
            border: 1px solid #e8ecf1; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            animation: bannerIn 0.35s ease;
        }
        @keyframes bannerIn { from { opacity:0; transform:translateY(-8px); } to { opacity:1; transform:translateY(0); } }
        .info-banner-icon {
            width: 40px; height: 40px; flex-shrink: 0;
            background: linear-gradient(135deg, #f59e0b, #fbbf24);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .info-banner-icon svg {
            width: 22px; height: 22px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .info-banner-body { flex: 1; }
        .info-banner-title { font-size: 15px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
        .info-banner-desc { font-size: 13px; color: #64748b; line-height: 1.8; }
        .info-banner-desc ul { margin: 4px 0 0 18px; padding: 0; }
        .info-banner-desc ul li { margin-bottom: 2px; }
        .info-banner-close {
            position: absolute; top: 10px; right: 10px;
            width: 28px; height: 28px; border: none;
            background: #f1f5f9; border-radius: 6px;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: all 0.2s;
        }
        .info-banner-close:hover { background: #e2e8f0; }
        .info-banner-close svg {
            width: 16px; height: 16px; stroke: #94a3b8; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }

        @media (max-width: 900px) {
            .sidebar { width: 64px; min-width: 64px; max-width: 64px; }
            .sidebar .sidebar-brand-text, .sidebar .nav-text,
            .sidebar .nav-group-label, .sidebar .sidebar-footer-text { display: none; }
            .sidebar .nav-item { justify-content: center; padding: 0; }
            .sidebar .nav-icon { margin-right: 0; }
            .sidebar .sidebar-brand { justify-content: center; }
            .user-trigger-name { display: none; }
            .form-card-body { padding: 18px; }
            .form-card-footer { padding: 14px 18px; flex-direction: column; gap: 10px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="layout-wrapper">

    <!-- ========== Sidebar ========== -->
    <div class="sidebar" id="sidebarEl">
        <div class="sidebar-brand" onclick="toggleSidebar()">
            <div class="sidebar-brand-logo">
                <svg viewBox="0 0 32 32" width="32" height="32" fill="none"><rect width="32" height="32" rx="8" fill="#6366f1"/><text x="16" y="22" text-anchor="middle" fill="#fff" font-size="16" font-weight="bold">T</text></svg>
            </div>
            <span class="sidebar-brand-text">教师平台</span>
        </div>
        <div class="sidebar-nav">
            <div class="nav-group-label">课堂教学</div>
            <a href="../teacher/start.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg></span>
                <span class="nav-text">上课</span>
            </a>
            <a href="../teacher/course.aspx" class="nav-item active">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
                <span class="nav-text">备课</span>
            </a>
            <a href="../teacher/gauge.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg></span>
                <span class="nav-text">量规</span>
            </a>
            <div class="nav-group-label">作品管理</div>
            <a href="../teacher/works.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></span>
                <span class="nav-text">作品</span>
            </a>
            <a href="../teacher/signin.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg></span>
                <span class="nav-text">签到</span>
            </a>
            <a href="../teacher/student.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
                <span class="nav-text">学生</span>
            </a>
            <div class="nav-group-label">测评练习</div>
            <a href="../quiz/quiz.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                <span class="nav-text">常识</span>
            </a>
            <a href="../teacher/typer.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><polyline points="4 7 4 4 20 4 20 7"/><line x1="9" y1="20" x2="15" y2="20"/><line x1="12" y1="4" x2="12" y2="20"/></svg></span>
                <span class="nav-text">中文打字</span>
            </a>
            <a href="../teacher/typechinese.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2" ry="2"/><path d="M6 8h.01"/><path d="M10 8h.01"/><path d="M14 8h.01"/><path d="M18 8h.01"/><path d="M8 12h.01"/><path d="M12 12h.01"/><path d="M16 12h.01"/><path d="M7 16h10"/></svg></span>
                <span class="nav-text">拼音打字</span>
            </a>
            <div class="nav-group-label">资源工具</div>
            <a href="../teacher/soft.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg></span>
                <span class="nav-text">资源</span>
            </a>
            <div class="nav-group-label">系统</div>
            <a href="../teacher/infomation.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                <span class="nav-text">个人信息</span>
            </a>
            <a href="../teacher/systeminfo.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></span>
                <span class="nav-text">系统状态</span>
            </a>
            <a href="../teacher/helper.aspx" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                <span class="nav-text">帮助</span>
            </a>
        </div>
        <div class="sidebar-footer">
            <div class="sidebar-footer-text">LearnSite 教师平台</div>
        </div>
    </div>

    <!-- ========== Main ========== -->
    <div class="main-area">
        <div class="top-header">
            <div class="header-left">
                <button type="button" class="toggle-btn" onclick="toggleSidebar()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                </button>
                <span class="header-title">编辑反思</span>
            </div>
            <div class="header-right">
                <div class="header-time"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:4px;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg><span id="clockSpan"></span></div>
                <div class="user-dropdown-wrap" id="userDropdownWrap">
                    <div class="user-trigger" id="userTrigger" onclick="toggleUserDropdown()">
                        <% if (!string.IsNullOrEmpty(tUserAvatarUrl)) { %>
                        <div class="user-avatar"><img src="<%= tUserAvatarUrl %>" /></div>
                        <% } else { %>
                        <div class="user-avatar"><%= Server.HtmlEncode(tUserInitial) %></div>
                        <% } %>
                        <span class="user-trigger-name"><%= !string.IsNullOrEmpty(tUserName) ? Server.HtmlEncode(tUserName) : "\u6559\u5E08" %></span>
                        <svg class="user-trigger-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="user-dropdown" id="userDropdown">
                        <div class="dropdown-header">
                            <div class="dh-name"><%= !string.IsNullOrEmpty(tUserName) ? Server.HtmlEncode(tUserName) : "\u6559\u5E08" %></div>
                            <div class="dh-role">Teacher</div>
                        </div>
                        <a href="../teacher/course.aspx" class="dropdown-item">
                            <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                            返回备课
                        </a>
                        <a href="../teacher/infomation.aspx" class="dropdown-item">
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            个人信息
                        </a>
                        <div class="dropdown-divider"></div>
                        <a href="../teacher/infomation.aspx?logout=1" class="dropdown-item logout">
                            <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                            退出系统
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="content-area">
            <div class="edit-page">
                <div class="page-title-bar">
                    <h2>
                        <span class="title-icon">
                            <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </span>
                        修改课后反思
                    </h2>
                </div>

                <!-- 说明板块 -->
                <div class="info-banner" id="infoBanner">
                    <div class="info-banner-icon">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>
                    </div>
                    <div class="info-banner-body">
                        <div class="info-banner-title">编辑反思小贴士</div>
                        <div class="info-banner-desc">
                            <ul>
                                <li>支持富文本编辑，可插入图片、表格等多媒体素材，让反思内容更加丰富</li>
                                <li>建议围绕 <b>教学目标达成</b>、<b>学生课堂表现</b>、<b>教学方法优化</b> 等方面撰写</li>
                                <li>修改完成后请点击「保存修改」按钮，点击「返回」将放弃本次修改</li>
                            </ul>
                        </div>
                    </div>
                    <button type="button" class="info-banner-close" onclick="closeBanner()" title="关闭提示">
                        <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    </button>
                </div>

                <div class="form-card">
                    <div class="form-card-header">
                        <h3>
                            <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            修改课后反思
                        </h3>
                        <div class="course-name">
                            学案：<asp:TextBox ID="Texttitle" runat="server" BorderStyle="None"
                                ReadOnly="True" BackColor="Transparent" ForeColor="#64748b"
                                Font-Size="13px" Width="400px"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-card-body">
                        <label class="field-label">反思内容</label>
                        <div class="editor-wrap">
                            <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                            <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                            <script>
                                var editor;
                                var cid = <%=myCid() %>;
                                var ty = "Course";
                                var upjs = '../kindeditor/aspnet/upload_json.aspx?Cid=' + cid + '&Ty=' + ty;
                                var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?Cid=' + cid + '&Ty=' + ty;
                                KindEditor.ready(function (K) {
                                    editor = K.create('textarea[name="mcontent"]', {
                                        resizeType: 1,
                                        newlineTag: "br",
                                        uploadJson: upjs,
                                        fileManagerJson: fmjs,
                                        allowFileManager: true,
                                        filterMode: false
                                    });
                                });
                            </script>
                            <textarea id="mcontent" runat="server" style="width:100%; height:380px;"></textarea>
                        </div>
                    </div>

                    <div class="form-card-footer">
                        <div class="msg-area">
                            <asp:Label ID="Labelmsg" runat="server"></asp:Label>
                        </div>
                        <div class="btn-group">
                            <asp:Button ID="BtnCourse" runat="server" Text="返回"
                                OnClick="BtnCourse_Click" CssClass="btn-back" />
                            <asp:Button ID="BtnEdit" runat="server" Text="✔ 保存修改"
                                OnClick="BtnEdit_Click" CssClass="btn-submit" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    </div><!-- /layout-wrapper -->

    <script type="text/javascript">
        function toggleSidebar() {
            var sb = document.getElementById('sidebarEl');
            sb.classList.toggle('collapsed');
            try { localStorage.setItem('teachSidebarCollapsed', sb.classList.contains('collapsed') ? '1' : '0'); } catch(e){}
        }
        (function(){
            try {
                if (localStorage.getItem('teachSidebarCollapsed') === '1') {
                    document.getElementById('sidebarEl').classList.add('collapsed');
                }
            } catch(e){}
        })();

        // Clock
        function updateClock() {
            var now = new Date();
            var h = now.getHours(); h = h < 10 ? '0' + h : '' + h;
            var m = now.getMinutes(); m = m < 10 ? '0' + m : '' + m;
            var d = (now.getMonth()+1) + '月' + now.getDate() + '日';
            var el = document.getElementById('clockSpan');
            if (el) el.textContent = d + ' ' + h + ':' + m;
        }
        updateClock(); setInterval(updateClock, 30000);

        // User dropdown
        function toggleUserDropdown() {
            document.getElementById('userTrigger').classList.toggle('open');
            document.getElementById('userDropdown').classList.toggle('show');
        }
        document.addEventListener('click', function(e) {
            var wrap = document.getElementById('userDropdownWrap');
            if (wrap && !wrap.contains(e.target)) {
                document.getElementById('userTrigger').classList.remove('open');
                document.getElementById('userDropdown').classList.remove('show');
            }
        });

        // 说明板块关闭
        function closeBanner() {
            var b = document.getElementById('infoBanner');
            if (b) b.style.display = 'none';
            try { localStorage.setItem('editInfoBannerHidden', '1'); } catch(e){}
        }
        (function(){
            try {
                if (localStorage.getItem('editInfoBannerHidden') === '1') {
                    var b = document.getElementById('infoBanner');
                    if (b) b.style.display = 'none';
                }
            } catch(e){}
        })();
    </script>

    </form>
</body>
</html>
