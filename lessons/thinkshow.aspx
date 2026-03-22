<%@ page title="" language="C#" autoeventwireup="true" inherits="Lessons_thinkshow, LearnSite" %>

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
    <title>课后反思</title>
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

        /* ===== Think Page ===== */
        .think-page { max-width: 1400px; margin: 0 auto; }
        .page-title-bar {
            display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;
        }
        .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .page-title-bar .subtitle { font-size: 14px; color: #64748b; margin-top: 4px; }

        /* ===== Info Banner ===== */
        .info-banner {
            background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 50%, #ede9fe 100%);
            border: 1px solid #c7d2fe; border-radius: 14px;
            padding: 20px 24px; margin-bottom: 22px;
            display: flex; gap: 16px; align-items: flex-start;
            position: relative; overflow: hidden;
        }
        .info-banner::before {
            content: ''; position: absolute; right: -30px; top: -30px;
            width: 120px; height: 120px; border-radius: 50%;
            background: rgba(99,102,241,0.08);
        }
        .info-banner::after {
            content: ''; position: absolute; right: 40px; bottom: -20px;
            width: 80px; height: 80px; border-radius: 50%;
            background: rgba(139,92,246,0.06);
        }
        .info-banner-icon {
            width: 42px; height: 42px; border-radius: 12px; flex-shrink: 0;
            background: linear-gradient(135deg, #6366f1, #818cf8);
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 2px 8px rgba(99,102,241,0.3);
        }
        .info-banner-icon svg {
            width: 22px; height: 22px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .info-banner-body { flex: 1; position: relative; z-index: 1; }
        .info-banner-title {
            font-size: 15px; font-weight: 700; color: #3730a3;
            margin-bottom: 8px; display: flex; align-items: center; gap: 6px;
        }
        .info-banner-desc {
            font-size: 13px; line-height: 1.75; color: #4338ca;
        }
        .info-banner-desc ul {
            margin: 6px 0 0 0; padding-left: 18px;
        }
        .info-banner-desc ul li {
            margin-bottom: 3px; color: #4f46e5;
        }
        .info-banner-desc ul li::marker { color: #818cf8; }
        .info-banner-close {
            position: absolute; top: 12px; right: 12px; z-index: 2;
            width: 28px; height: 28px; border: none; border-radius: 8px;
            background: rgba(99,102,241,0.1); cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.15s; color: #6366f1;
        }
        .info-banner-close:hover { background: rgba(99,102,241,0.2); }
        .info-banner-close svg {
            width: 16px; height: 16px; stroke: currentColor; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .info-banner.hidden { display: none; }

        /* ===== Stats Bar ===== */
        .stats-bar {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px; flex-wrap: wrap; gap: 12px;
        }
        .stats-bar-left { display: flex; gap: 12px; flex-wrap: wrap; }
        .stat-chip {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 20px;
            background: #fff; border: 1px solid #e8ecf1;
            font-size: 12.5px; color: #64748b; font-weight: 500;
        }
        .stat-chip svg {
            width: 14px; height: 14px; stroke: #94a3b8; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .stat-chip .stat-val { color: #6366f1; font-weight: 700; }

        /* 编辑按钮 */
        .btn-edit-wrap {
            position: relative; display: inline-flex; align-items: center; justify-content: center;
            width: 40px; height: 40px; border-radius: 10px;
            background: linear-gradient(135deg, #6366f1, #818cf8);
            box-shadow: 0 2px 8px rgba(99,102,241,0.25);
            cursor: pointer; transition: all 0.2s; flex-shrink: 0;
        }
        .btn-edit-wrap:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            box-shadow: 0 4px 16px rgba(99,102,241,0.35); transform: translateY(-1px);
        }
        .btn-edit-wrap svg { pointer-events: none; }
        .btn-edit-hidden {
            position: absolute !important; top: 0 !important; left: 0 !important;
            width: 100% !important; height: 100% !important;
            opacity: 0 !important; cursor: pointer !important;
            border: none !important; padding: 0 !important; margin: 0 !important;
        }

        .think-list { display: flex; flex-direction: column; gap: 16px; }
        .think-card {
            background: #fff; border-radius: 14px; border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.02);
            overflow: hidden; transition: all 0.25s ease; position: relative;
        }
        .think-card:hover {
            box-shadow: 0 4px 20px rgba(0,0,0,0.06), 0 2px 8px rgba(99,102,241,0.08);
            transform: translateY(-2px); border-color: #c7d2fe;
        }
        .think-card::before {
            content: ''; position: absolute; left: 0; top: 0; bottom: 0;
            width: 4px; background: linear-gradient(180deg, #6366f1, #a78bfa);
            border-radius: 4px 0 0 4px;
        }
        .think-card-body { padding: 24px 28px 20px; min-height: 60px; }
        .think-card .think-content {
            font-size: 14.5px; line-height: 1.85; color: #334155;
            text-align: left; word-break: break-word;
        }
        .think-card .think-content:empty::after {
            content: '暂无反思内容'; color: #cbd5e1; font-style: italic;
        }
        .think-card .think-content img { max-width: 100%; border-radius: 8px; margin: 8px 0; }
        .think-card-footer {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 28px; background: #fafbfd; border-top: 1px solid #f1f5f9;
        }
        .think-card-footer .think-index {
            display: inline-flex; align-items: center; gap: 8px;
            font-size: 12.5px; color: #6366f1; font-weight: 600;
            background: #eef2ff; padding: 5px 14px; border-radius: 20px;
        }
        .think-card-footer .think-index .idx-dot {
            width: 7px; height: 7px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 50%; box-shadow: 0 0 0 2px rgba(99,102,241,0.2);
        }
        .think-card-footer .think-date {
            font-size: 12px; color: #94a3b8; display: flex; align-items: center; gap: 5px;
            background: #f1f5f9; padding: 5px 12px; border-radius: 20px;
        }
        .think-card-footer .think-date svg {
            width: 13px; height: 13px; stroke: #94a3b8; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .page-footer-msg { text-align: center; padding: 24px; font-size: 13px; color: #94a3b8; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(16px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .think-card { animation: fadeInUp 0.4s ease both; }
        .think-card:nth-child(1) { animation-delay: 0.05s; }
        .think-card:nth-child(2) { animation-delay: 0.1s; }
        .think-card:nth-child(3) { animation-delay: 0.15s; }
        .think-card:nth-child(4) { animation-delay: 0.2s; }
        .think-card:nth-child(5) { animation-delay: 0.25s; }

        @media (max-width: 900px) {
            .sidebar { width: 64px; min-width: 64px; max-width: 64px; }
            .sidebar .sidebar-brand-text, .sidebar .nav-text,
            .sidebar .nav-group-label, .sidebar .sidebar-footer-text { display: none; }
            .sidebar .nav-item { justify-content: center; padding: 0; }
            .sidebar .nav-icon { margin-right: 0; }
            .sidebar .sidebar-brand { justify-content: center; }
            .user-trigger-name { display: none; }
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
                <span class="header-title">课后反思</span>
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
            <div class="think-page">
                <div class="page-title-bar">
                    <div>
                        <h2>
                            <span class="title-icon">
                                <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </span>
                            课后反思
                        </h2>
                        <div class="subtitle">
                            <asp:Label ID="LabelTitle" runat="server" Text=""></asp:Label>
                        </div>
                    </div>
                </div>

                <!-- 说明板块 -->
                <div class="info-banner" id="infoBanner">
                    <div class="info-banner-icon">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    </div>
                    <div class="info-banner-body">
                        <div class="info-banner-title">关于课后反思</div>
                        <div class="info-banner-desc">
                            课后反思是教师专业成长的重要环节，帮助您回顾教学过程、总结经验、发现不足并持续改进。
                            <ul>
                                <li>点击右上角 <b>编辑按钮</b> 可添加或修改反思内容</li>
                                <li>每节课可记录多篇反思，系统自动保存时间</li>
                                <li>建议从教学目标达成、学生参与度、教学方法等方面进行反思</li>
                            </ul>
                        </div>
                    </div>
                    <button type="button" class="info-banner-close" onclick="closeBanner()" title="关闭说明">
                        <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    </button>
                </div>

                <!-- 统计条 -->
                <div class="stats-bar">
                    <div class="stats-bar-left">
                    <span class="stat-chip">
                        <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        反思篇数 <span class="stat-val"><asp:Label ID="LabelCount" runat="server" Text="0"></asp:Label></span>
                    </span>
                    <span class="stat-chip">
                        <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                        所属学案 <span class="stat-val"><asp:Label ID="LabelCourse" runat="server" Text="-"></asp:Label></span>
                    </span>
                    </div>
                    <span class="btn-edit-wrap" title="添加/修改反思">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        <asp:ImageButton ID="BtnEdit" runat="server" ToolTip="添加/修改反思"
                            ImageUrl="~/images/edit.gif" onclick="BtnEdit_Click" CssClass="btn-edit-hidden" />
                    </span>
                </div>

                <div class="think-list">
                    <asp:Repeater ID="Repeater1" runat="server">
                        <ItemTemplate>
                            <div class="think-card">
                                <div class="think-card-body">
                                    <div class="think-content">
                                        <%# HttpUtility.HtmlDecode(Eval("Fcontent").ToString())%>
                                    </div>
                                </div>
                                <div class="think-card-footer">
                                    <span class="think-index">
                                        <span class="idx-dot"></span>
                                        第 <%# Container.ItemIndex + 1 %> 篇
                                    </span>
                                    <span class="think-date">
                                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                        <%# Eval("Fdate")%>
                                    </span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="page-footer-msg">
                    <asp:Label ID="Labelmsg" runat="server"></asp:Label>
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

        function goBack() {
            try {
                if (parent && parent.TINY && parent.TINY.box) {
                    parent.TINY.box.hide();
                } else if (window.history.length > 1) {
                    window.history.back();
                } else {
                    window.close();
                }
            } catch (e) {
                window.history.back();
            }
        }
        function closeThinkWindow() { goBack(); }

        // Info banner
        function closeBanner() {
            var b = document.getElementById('infoBanner');
            if (b) b.classList.add('hidden');
            try { localStorage.setItem('thinkInfoBannerHidden', '1'); } catch(e){}
        }
        (function(){
            try {
                if (localStorage.getItem('thinkInfoBannerHidden') === '1') {
                    var b = document.getElementById('infoBanner');
                    if (b) b.classList.add('hidden');
                }
            } catch(e){}
        })();
    </script>
    </form>
</body>
</html>
