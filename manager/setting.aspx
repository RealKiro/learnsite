<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_setting, LearnSite" %>

<script runat="server">
    protected string GetExistingLogoUrl()
    {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
        foreach (string ext in exts)
        {
            string path = Server.MapPath("~/images/site-logo" + ext);
            if (System.IO.File.Exists(path))
                return ResolveUrl("~/images/site-logo" + ext) + "?v=" + System.IO.File.GetLastWriteTime(path).Ticks;
        }
        return "";
    }

    protected string GetExistingFaviconUrl()
    {
        string icoPath = Server.MapPath("~/favicon.ico");
        if (System.IO.File.Exists(icoPath))
        {
            byte[] bytes = System.IO.File.ReadAllBytes(icoPath);
            return "data:image/x-icon;base64," + Convert.ToBase64String(bytes);
        }
        string pngPath = Server.MapPath("~/favicon.png");
        if (System.IO.File.Exists(pngPath))
            return ResolveUrl("~/favicon.png") + "?v=" + System.IO.File.GetLastWriteTime(pngPath).Ticks;
        return "";
    }

    // 编程页面 Logo 现有地址（Scratch / 编程页面使用）
    protected string GetCodingLogoUrl()
    {
        string logoPath = Server.MapPath("~/scratch/logo.png");
        if (System.IO.File.Exists(logoPath))
            return ResolveUrl("~/scratch/logo.png") + "?v=" + System.IO.File.GetLastWriteTime(logoPath).Ticks;
        return "";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== Modern Setting Page Styles v2 ===== */
    .setting-page {
        max-width: 100%;
        margin: 0;
        padding: 28px 32px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }

    /* Page header */
    .page-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 28px;
    }
    .page-header-icon {
        width: 48px; height: 48px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(99,102,241,0.25);
        flex-shrink: 0;
    }
    .page-header-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .page-header-text h1 {
        font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 2px;
    }
    .page-header-text p {
        font-size: 13px; color: #94a3b8; margin: 0;
    }

    /* Card grid — two column on wide screens */
    .card-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }
    .card-full { grid-column: 1 / -1; }
    @media (max-width: 860px) {
        .card-grid { grid-template-columns: 1fr; }
    }

    /* Card */
    .s-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        overflow: hidden;
        transition: box-shadow 0.25s, transform 0.25s;
    }
    .s-card:hover {
        box-shadow: 0 8px 24px rgba(0,0,0,0.07);
        transform: translateY(-2px);
    }
    .s-card-header {
        padding: 16px 22px;
        font-size: 15px;
        font-weight: 600;
        color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .card-icon {
        width: 34px; height: 34px;
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .card-icon svg {
        width: 19px; height: 19px;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
        fill: none;
    }
    /* Card icon color themes */
    .card-icon.purple  { background: #eef2ff; }
    .card-icon.purple svg  { stroke: #6366f1; }
    .card-icon.emerald { background: #ecfdf5; }
    .card-icon.emerald svg { stroke: #10b981; }
    .card-icon.amber   { background: #fffbeb; }
    .card-icon.amber svg   { stroke: #f59e0b; }
    .card-icon.sky     { background: #f0f9ff; }
    .card-icon.sky svg     { stroke: #0ea5e9; }

    .s-card-body {
        padding: 12px 22px 18px;
    }

    /* Form rows */
    .s-row {
        display: flex;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #f8fafc;
        gap: 14px;
        font-size: 13.5px;
    }
    .s-row:last-child { border-bottom: none; }
    .s-label {
        min-width: 110px;
        font-weight: 500;
        color: #475569;
        flex-shrink: 0;
        text-align: right;
        font-size: 13px;
    }
    .s-control { flex: 1; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .s-hint {
        font-size: 11.5px;
        color: #94a3b8;
        margin-top: 3px;
        line-height: 1.5;
    }

    /* Override ASP.NET controls */
    .s-card input[type="text"] {
        height: 36px;
        padding: 0 14px;
        border: 1.5px solid #e2e8f0;
        border-radius: 9px;
        font-size: 13.5px;
        font-family: inherit;
        outline: none;
        transition: border-color 0.2s, box-shadow 0.2s;
        background: #f8fafc;
        min-width: 220px;
    }
    .s-card input[type="text"]:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.08);
        background: #fff;
    }
    .s-card select {
        height: 36px;
        padding: 0 12px;
        border: 1.5px solid #e2e8f0;
        border-radius: 9px;
        font-size: 13px;
        font-family: inherit;
        background: #f8fafc;
        outline: none;
        cursor: pointer;
        transition: border-color 0.2s, box-shadow 0.2s;
        -webkit-appearance: none;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        padding-right: 30px;
    }
    .s-card select:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.08);
        background-color: #fff;
    }

    /* Buttons */
    .btn-primary {
        display: inline-flex;
        align-items: center; justify-content: center;
        gap: 6px;
        height: 36px;
        padding: 0 20px;
        background: linear-gradient(135deg, #6366f1, #7c3aed);
        color: #fff !important;
        border: none;
        border-radius: 9px;
        font-size: 13px;
        font-family: inherit;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 6px rgba(99,102,241,0.3);
        letter-spacing: 0.3px;
    }
    .btn-primary:hover {
        box-shadow: 0 4px 14px rgba(99,102,241,0.4);
        transform: translateY(-1px);
    }
    .btn-primary:active { transform: translateY(0); }
    .btn-warning {
        display: inline-flex;
        align-items: center; justify-content: center;
        height: 36px;
        padding: 0 20px;
        background: linear-gradient(135deg, #f59e0b, #d97706);
        color: #fff !important;
        border: none;
        border-radius: 9px;
        font-size: 13px;
        font-family: inherit;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 6px rgba(245,158,11,0.3);
    }
    .btn-warning:hover {
        box-shadow: 0 4px 14px rgba(245,158,11,0.4);
        transform: translateY(-1px);
    }

    /* Checkbox / label styling */
    .s-card input[type="checkbox"] {
        width: 17px; height: 17px;
        accent-color: #6366f1;
        cursor: pointer;
        border-radius: 4px;
    }
    .s-card label {
        cursor: pointer;
        color: #475569;
        font-size: 13px;
        user-select: none;
    }

    /* ===== Brand Visual Cards ===== */
    .brand-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-top: 4px;
    }
    .brand-grid .brand-card-wide { grid-column: 1 / -1; }
    @media (max-width: 700px) { .brand-grid { grid-template-columns: 1fr; } }

    .brand-card {
        position: relative;
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        overflow: hidden;
        transition: box-shadow 0.3s, transform 0.3s;
    }
    .brand-card:hover {
        box-shadow: 0 8px 28px rgba(99,102,241,0.12);
        transform: translateY(-2px);
    }
    /* Top gradient bar */
    .brand-card-bar {
        height: 4px;
        background: linear-gradient(90deg, #6366f1, #a78bfa, #f472b6);
    }
    .brand-card-body {
        padding: 20px;
        text-align: center;
    }
    .brand-card-title {
        font-size: 12px;
        font-weight: 600;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 14px;
    }
    /* Preview container */
    .brand-preview-wrap {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
    }
    .brand-preview-wrap input[type="file"] { display: none; }
    .brand-preview-logo {
        width: 200px;
        height: 80px;
        background: linear-gradient(135deg, #f8fafc, #f1f5f9);
        border-radius: 12px;
        border: 1.5px dashed #d1d5db;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;
        overflow: hidden;
    }
    .brand-preview-logo.has-img {
        border-style: solid;
        border-color: #e2e8f0;
        background: #fff;
    }
    .brand-preview-favicon {
        width: 72px;
        height: 72px;
        background: linear-gradient(135deg, #f8fafc, #f1f5f9);
        border-radius: 16px;
        border: 1.5px dashed #d1d5db;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;
        overflow: hidden;
    }
    .brand-preview-favicon.has-img {
        border-style: solid;
        border-color: #e2e8f0;
        background: #fff;
    }
    .brand-preview-logo img, .brand-preview-favicon img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
    }
    .brand-ph {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
    }
    .brand-ph svg {
        width: 28px; height: 28px;
        stroke: #c7d2fe;
        fill: none;
        stroke-width: 1.5;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    .brand-ph span {
        font-size: 11px;
        color: #a5b4c8;
    }
    /* Hover overlay */
    .brand-overlay {
        position: absolute;
        inset: 0;
        background: rgba(99,102,241,0.85);
        border-radius: inherit;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 4px;
        opacity: 0;
        transition: opacity 0.25s;
        pointer-events: none;
    }
    .brand-preview-wrap:hover .brand-overlay { opacity: 1; }
    .brand-overlay svg {
        width: 22px; height: 22px;
        stroke: #fff;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    .brand-overlay span {
        font-size: 11px;
        color: rgba(255,255,255,0.9);
        font-weight: 500;
    }
    /* Drag active */
    .brand-card.dragover {
        box-shadow: 0 0 0 3px rgba(99,102,241,0.25), 0 8px 28px rgba(99,102,241,0.15);
    }
    .brand-card.dragover .brand-preview-logo,
    .brand-card.dragover .brand-preview-favicon {
        border-color: #6366f1;
        background: #eef2ff;
    }
    /* Meta info */
    .brand-meta {
        font-size: 11.5px;
        color: #94a3b8;
        margin-top: 12px;
        line-height: 1.6;
    }
    /* Status toast */
    .brand-toast {
        margin-top: 8px;
        font-size: 12px;
        font-weight: 500;
        min-height: 18px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 2px 10px;
        border-radius: 6px;
        transition: all 0.3s;
    }
    .brand-toast.success { color: #059669; background: #ecfdf5; }
    .brand-toast.error { color: #dc2626; background: #fef2f2; }
    .brand-toast.loading { color: #6366f1; background: #eef2ff; }
    .brand-toast svg {
        width: 14px; height: 14px;
        flex-shrink: 0;
    }
    /* Progress ring */
    @keyframes spin { to { transform: rotate(360deg); } }
    .brand-spinner {
        width: 14px; height: 14px;
        border: 2px solid #c7d2fe;
        border-top-color: #6366f1;
        border-radius: 50%;
        animation: spin 0.6s linear infinite;
        flex-shrink: 0;
    }
    /* Upload progress bar on card bottom */
    .brand-progress {
        position: absolute;
        bottom: 0;
        left: 0;
        height: 3px;
        background: linear-gradient(90deg, #6366f1, #a78bfa);
        border-radius: 0 2px 2px 0;
        transition: width 0.3s;
        width: 0;
    }

    /* Inline description tags */
    .s-tag {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        font-size: 11.5px;
        color: #64748b;
        background: #f1f5f9;
        padding: 3px 10px;
        border-radius: 6px;
    }

    /* Global message */
    .global-msg {
        text-align: center;
        padding: 10px;
        font-size: 13px;
        margin-top: 8px;
    }

    /* ===== Tab Navigation ===== */
    .tab-nav-wrap {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        padding: 8px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .tab-nav {
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
    }
    .tab-btn {
        flex: 1;
        min-width: 140px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        height: 44px;
        padding: 0 20px;
        background: #f8fafc;
        color: #64748b;
        border: 1.5px solid transparent;
        border-radius: 10px;
        font-size: 13.5px;
        font-family: inherit;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        white-space: nowrap;
    }
    .tab-btn svg {
        width: 18px;
        height: 18px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }
    .tab-btn:hover {
        background: #eef2ff;
        color: #6366f1;
    }
    .tab-btn.active {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff;
        border-color: #6366f1;
        box-shadow: 0 2px 8px rgba(99,102,241,0.25);
    }
    @media (max-width: 760px) {
        .tab-btn {
            flex: 1 1 calc(50% - 3px);
            min-width: 0;
        }
        .tab-btn span {
            font-size: 12px;
        }
    }

    /* ===== Tab Content ===== */
    .tab-content-wrap {
        position: relative;
        min-height: 400px;
    }
    .tab-pane {
        display: none;
        animation: fadeIn 0.3s ease;
    }
    .tab-pane.active {
        display: block;
    }
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    /* ===== Brand Sub Tabs ===== */
    .brand-sub-tabs {
        display: flex;
        gap: 8px;
        margin: 20px 0 16px;
        padding: 6px;
        background: #f8fafc;
        border-radius: 12px;
        flex-wrap: wrap;
    }
    .brand-tab-btn {
        flex: 1;
        min-width: 120px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        height: 38px;
        padding: 0 16px;
        background: transparent;
        color: #64748b;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-family: inherit;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        white-space: nowrap;
    }
    .brand-tab-btn svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }
    .brand-tab-btn:hover {
        background: #e0e7ff;
        color: #6366f1;
    }
    .brand-tab-btn.active {
        background: #fff;
        color: #6366f1;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        font-weight: 600;
    }
    .brand-tab-content {
        margin-top: 16px;
    }
    .brand-tab-pane {
        display: none;
        animation: fadeIn 0.3s ease;
    }
    .brand-tab-pane.active {
        display: block;
    }
    .brand-tab-pane .brand-card {
        max-width: 600px;
        margin: 0 auto;
    }
    @media (max-width: 600px) {
        .brand-tab-btn {
            flex: 1 1 100%;
            min-width: 0;
        }
    }
</style>

<div class="setting-page">
    <!-- Page header -->
    <div class="page-header">
        <div class="page-header-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        </div>
        <div class="page-header-text">
            <h1>系统设置</h1>
            <p>管理平台基础配置、登录安全、学期设定与资源策略</p>
        </div>
    </div>

    <div class="card-grid">

    <!-- Tab 导航 -->
    <div class="tab-nav-wrap card-full">
        <div class="tab-nav">
            <button type="button" class="tab-btn active" data-tab="brand" onclick="switchTab('brand')">
                <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
                <span>品牌与外观</span>
            </button>
            <button type="button" class="tab-btn" data-tab="security" onclick="switchTab('security')">
                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span>登录与安全</span>
            </button>
            <button type="button" class="tab-btn" data-tab="semester" onclick="switchTab('semester')">
                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                <span>学期与教学</span>
            </button>
            <button type="button" class="tab-btn" data-tab="resource" onclick="switchTab('resource')">
                <svg viewBox="0 0 24 24"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><polyline points="13 2 13 9 20 9"/></svg>
                <span>资源与作品</span>
            </button>
        </div>
    </div>

    <!-- Tab 内容区域 -->
    <div class="tab-content-wrap card-full">

    <!-- ============ 品牌与外观 ============ -->
    <div class="tab-pane active" id="tab-brand">
    <div class="s-card card-full">
        <div class="s-card-header">
            <span class="card-icon purple"><svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg></span>
            品牌与外观
        </div>
        <div class="s-card-body">
            <!-- 网站名称行 -->
            <div class="s-row">
                <div class="s-label">网站名称</div>
                <div class="s-control">
                    <asp:TextBox ID="TextBoxsite" runat="server" BorderColor="#cbd5e1"
                        BorderStyle="Solid" BorderWidth="1px" Width="280px"></asp:TextBox>
                    <asp:Button ID="Buttonsite" runat="server" Text="保存名称"
                        CssClass="btn-primary" onclick="Buttonsite_Click" />
                </div>
            </div>
            
            <!-- 子Tab导航 -->
            <div class="brand-sub-tabs">
                <button type="button" class="brand-tab-btn active" data-brand-tab="logo" onclick="switchBrandTab('logo')">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    网站 LOGO
                </button>
                <button type="button" class="brand-tab-btn" data-brand-tab="favicon" onclick="switchBrandTab('favicon')">
                    <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                    浏览器图标
                </button>
                <button type="button" class="brand-tab-btn" data-brand-tab="coding" onclick="switchBrandTab('coding')">
                    <svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
                    编程页面 LOGO
                </button>
            </div>
            
            <!-- 子Tab内容 -->
            <div class="brand-tab-content">
                <!-- Logo 卡片 -->
                <div class="brand-tab-pane active" id="brand-tab-logo">
                    <div class="brand-card" id="brandCardLogo">
                        <div class="brand-card-bar"></div>
                        <div class="brand-card-body">
                            <div class="brand-card-title">网站 LOGO</div>
                            <div class="brand-preview-wrap" id="wrapLogo">
                                <input type="file" id="fileInputLogo" accept=".png,.jpg,.jpeg,.gif,.svg,.webp" />
                                <div class="brand-preview-logo" id="previewLogo">
                                    <div class="brand-ph" id="phLogo">
                                        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                        <span>暂无Logo</span>
                                    </div>
                                    <img id="imgPreviewLogo" style="display:none;" alt="Logo" />
                                </div>
                                <div class="brand-overlay">
                                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                    <span>点击更换</span>
                                </div>
                            </div>
                            <div class="brand-meta">建议 240×60px · PNG / JPG / GIF / SVG / WEBP</div>
                            <div class="brand-toast" id="toastLogo"></div>
                        </div>
                        <div class="brand-progress" id="progressLogo"></div>
                    </div>
                </div>
                
                <!-- Favicon 卡片 -->
                <div class="brand-tab-pane" id="brand-tab-favicon">
                    <div class="brand-card" id="brandCardFavicon">
                        <div class="brand-card-bar"></div>
                        <div class="brand-card-body">
                            <div class="brand-card-title">浏览器图标</div>
                            <div class="brand-preview-wrap" id="wrapFavicon">
                                <input type="file" id="fileInputFavicon" accept=".ico,.png" />
                                <div class="brand-preview-favicon" id="previewFavicon">
                                    <div class="brand-ph" id="phFavicon">
                                        <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                                        <span>暂无图标</span>
                                    </div>
                                    <img id="imgPreviewFavicon" style="display:none;" alt="Favicon" />
                                </div>
                                <div class="brand-overlay">
                                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                    <span>点击更换</span>
                                </div>
                            </div>
                            <div class="brand-meta">建议 32×32 或 64×64px · ICO / PNG</div>
                            <div class="brand-toast" id="toastFavicon"></div>
                        </div>
                        <div class="brand-progress" id="progressFavicon"></div>
                    </div>
                </div>

                <!-- 编程页面 Logo 卡片 -->
                <div class="brand-tab-pane" id="brand-tab-coding">
                    <div class="brand-card brand-card-wide" id="brandCardCoding">
                        <div class="brand-card-bar"></div>
                        <div class="brand-card-body">
                            <div class="brand-card-title">编程页面 LOGO</div>
                            <div class="brand-preview-wrap" id="wrapCoding">
                                <input type="file" id="fileInputCoding" accept=".png,.jpg,.jpeg,.gif,.svg,.webp" />
                                <div class="brand-preview-logo" id="previewCoding">
                                    <div class="brand-ph" id="phCoding">
                                        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                        <span>Scratch / 编程页面 Logo</span>
                                    </div>
                                    <img id="imgPreviewCoding" style="display:none;" alt="Coding Logo" />
                                </div>
                                <div class="brand-overlay">
                                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                    <span>点击更换</span>
                                </div>
                            </div>
                            <div class="brand-meta">用于学生编程页面左上角展示 · 建议 240×60px · PNG / JPG / GIF / SVG / WEBP</div>
                            <div class="brand-toast" id="toastCoding"></div>
                        </div>
                        <div class="brand-progress" id="progressCoding"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div><!-- /tab-brand -->

    <!-- ============ 登录与安全 ============ -->
    <div class="tab-pane" id="tab-security">
    <div class="s-card">
        <div class="s-card-header">
            <span class="card-icon emerald"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
            登录与安全
        </div>
        <div class="s-card-body">
            <div class="s-row">
                <div class="s-label">登录方式</div>
                <div class="s-control">
                    <asp:DropDownList ID="DDLLoginMode" runat="server" Font-Size="9pt"
                        EnableTheming="True" AutoPostBack="True"
                        onselectedindexchanged="DDLLoginMode_SelectedIndexChanged"
                        ToolTip="选择学生登录方式">
                        <asp:ListItem Value="0">个人密码</asp:ListItem>
                        <asp:ListItem Value="1">班级密码</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">单点登录</div>
                <div class="s-control">
                    <asp:CheckBox ID="CheckBoxSingleLogin" runat="server" AutoPostBack="True"
                        Font-Size="9pt" oncheckedchanged="CheckBoxSingleLogin_CheckedChanged"
                        Text="同一账号仅限一台设备登录"
                        ToolTip="选中则一个学生账号不能在多台电脑登录同个平台" />
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">会话有效期</div>
                <div class="s-control">
                    <asp:DropDownList ID="DDLCookiesPeriod" runat="server"
                        AutoPostBack="True" Font-Size="9pt"
                        onselectedindexchanged="DDLCookiesPeriod_SelectedIndexChanged">
                        <asp:ListItem Value="0">关闭失效</asp:ListItem>
                        <asp:ListItem Value="1">45分钟</asp:ListItem>
                        <asp:ListItem Value="2">1小时</asp:ListItem>
                        <asp:ListItem Value="3">3小时</asp:ListItem>
                        <asp:ListItem Value="4">5小时</asp:ListItem>
                        <asp:ListItem Value="5">永久</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">教师登录</div>
                <div class="s-control">
                    <asp:CheckBox ID="CheckBoxLogin" runat="server"
                        oncheckedchanged="CheckBoxLogin_CheckedChanged"
                        Text="限制同网段才能登录"
                        AutoPostBack="True" />
                    <asp:Image ID="ImageLogin" runat="server" ImageUrl="~/images/green.gif"
                        Width="14px" Height="14px" />
                </div>
            </div>
        </div>
    </div>
    </div><!-- /tab-security -->

    <!-- ============ 学期与教学 ============ -->
    <div class="tab-pane" id="tab-semester">
    <div class="s-card">
        <div class="s-card-header">
            <span class="card-icon amber"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
            学期与教学
        </div>
        <div class="s-card-body">
            <div class="s-row">
                <div class="s-label">当前学期</div>
                <div class="s-control">
                    <asp:DropDownList ID="DDLterm" runat="server" Font-Size="9pt"
                        EnableTheming="True" AutoPostBack="True"
                        onselectedindexchanged="DDLterm_SelectedIndexChanged"
                        ToolTip="选择当前学期">
                        <asp:ListItem Value="1">第一学期</asp:ListItem>
                        <asp:ListItem Value="2">第二学期</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">学案收回</div>
                <div class="s-control">
                    <asp:Button ID="Btnpublish" runat="server" Text="一键全部收回"
                        CssClass="btn-warning"
                        onclick="Btnpublish_Click"
                        ToolTip="收回的学案只是在学生界面不显示，教师界面仍显示并可再设置成发布状态" />
                    <div class="s-hint">收回后学生端不可见，教师端可再次发布</div>
                </div>
            </div>
        </div>
    </div>
    </div><!-- /tab-semester -->

    <!-- ============ 资源与作品 ============ -->
    <div class="tab-pane" id="tab-resource">
    <div class="s-card card-full">
        <div class="s-card-header">
            <span class="card-icon sky"><svg viewBox="0 0 24 24"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><polyline points="13 2 13 9 20 9"/></svg></span>
            资源与作品
        </div>
        <div class="s-card-body">
            <div class="s-row">
                <div class="s-label">下载限制</div>
                <div class="s-control">
                    <asp:CheckBox ID="CheckBoxDownCan" runat="server" AutoPostBack="True"
                        Font-Size="9pt" oncheckedchanged="CheckBoxDownCan_CheckedChanged"
                        Text="启用资源下载限制" />
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">等待时间</div>
                <div class="s-control">
                    <asp:DropDownList ID="DDLDownTime" runat="server" AutoPostBack="True"
                        Font-Size="9pt"
                        onselectedindexchanged="DDLDownTime_SelectedIndexChanged">
                        <asp:ListItem Value="10">10分钟</asp:ListItem>
                        <asp:ListItem Value="20">20分钟</asp:ListItem>
                        <asp:ListItem Value="30">30分钟</asp:ListItem>
                        <asp:ListItem Value="40">40分钟</asp:ListItem>
                        <asp:ListItem Value="50">50分钟</asp:ListItem>
                        <asp:ListItem Value="60">60分钟</asp:ListItem>
                    </asp:DropDownList>
                    <span class="s-tag">课后方可下载</span>
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">查看延迟</div>
                <div class="s-control">
                    <asp:DropDownList ID="DDLworkdowntime" runat="server" Font-Size="9pt"
                        EnableTheming="True" AutoPostBack="True"
                        onselectedindexchanged="DDLworkdowntime_SelectedIndexChanged"
                        ToolTip="选择查看天数">
                        <asp:ListItem>0</asp:ListItem>
                        <asp:ListItem>1</asp:ListItem>
                        <asp:ListItem>2</asp:ListItem>
                        <asp:ListItem>3</asp:ListItem>
                        <asp:ListItem>4</asp:ListItem>
                        <asp:ListItem>5</asp:ListItem>
                        <asp:ListItem>6</asp:ListItem>
                        <asp:ListItem>7</asp:ListItem>
                        <asp:ListItem>8</asp:ListItem>
                        <asp:ListItem>9</asp:ListItem>
                        <asp:ListItem>10</asp:ListItem>
                        <asp:ListItem>11</asp:ListItem>
                        <asp:ListItem>12</asp:ListItem>
                    </asp:DropDownList>
                    <span class="s-tag">天后可查看作品</span>
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">提交限制</div>
                <div class="s-control">
                    <asp:CheckBox ID="CheckBoxWorkIp" runat="server" AutoPostBack="True"
                        Font-Size="9pt" oncheckedchanged="CheckBoxWorkIp_CheckedChanged"
                        Text="同班同IP限制提交一份作品"
                        ToolTip="同班一个Ip限制提交一份作品" />
                </div>
            </div>
            <div class="s-row">
                <div class="s-label">上传方式</div>
                <div class="s-control">
                    <asp:DropDownList ID="DDLUploadMode" runat="server"
                        AutoPostBack="True" Font-Size="9pt"
                        onselectedindexchanged="DDLUploadMode_SelectedIndexChanged">
                        <asp:ListItem Value="0">普通无刷新方式上传</asp:ListItem>
                        <asp:ListItem Value="1">Plupload方式上传</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>
    </div><!-- /tab-resource -->

    </div><!-- /tab-content-wrap -->

    </div><!-- /card-grid -->

    <!-- Global message -->
    <div class="global-msg">
        <asp:Label ID="Labelmsg" runat="server" ForeColor="Red"></asp:Label>
    </div>
</div>

<script type="text/javascript">
// ===== Tab 切换功能 =====
function switchTab(tabName) {
    // 移除所有active类
    var allBtns = document.querySelectorAll('.tab-btn');
    var allPanes = document.querySelectorAll('.tab-pane');
    
    for (var i = 0; i < allBtns.length; i++) {
        allBtns[i].classList.remove('active');
    }
    for (var j = 0; j < allPanes.length; j++) {
        allPanes[j].classList.remove('active');
    }
    
    // 添加active类到当前tab
    var currentBtn = document.querySelector('.tab-btn[data-tab="' + tabName + '"]');
    var currentPane = document.getElementById('tab-' + tabName);
    
    if (currentBtn) currentBtn.classList.add('active');
    if (currentPane) currentPane.classList.add('active');
    
    // 保存当前tab到localStorage
    try {
        localStorage.setItem('settingActiveTab', tabName);
    } catch(e) {}
}

// ===== Brand Sub Tab 切换功能 =====
function switchBrandTab(tabName) {
    // 移除所有active类
    var allBtns = document.querySelectorAll('.brand-tab-btn');
    var allPanes = document.querySelectorAll('.brand-tab-pane');
    
    for (var i = 0; i < allBtns.length; i++) {
        allBtns[i].classList.remove('active');
    }
    for (var j = 0; j < allPanes.length; j++) {
        allPanes[j].classList.remove('active');
    }
    
    // 添加active类到当前tab
    var currentBtn = document.querySelector('.brand-tab-btn[data-brand-tab="' + tabName + '"]');
    var currentPane = document.getElementById('brand-tab-' + tabName);
    
    if (currentBtn) currentBtn.classList.add('active');
    if (currentPane) currentPane.classList.add('active');
    
    // 保存当前brand tab到localStorage
    try {
        localStorage.setItem('settingActiveBrandTab', tabName);
    } catch(e) {}
}

// 页面加载时恢复上次选择的tab
(function() {
    try {
        var savedTab = localStorage.getItem('settingActiveTab');
        if (savedTab) {
            switchTab(savedTab);
        }
        
        var savedBrandTab = localStorage.getItem('settingActiveBrandTab');
        if (savedBrandTab) {
            switchBrandTab(savedBrandTab);
        }
    } catch(e) {}
})();

// ===== Logo上传功能 =====
(function () {
    var uploadUrl = '<%= ResolveUrl("~/teacher/uploadsiteimg.ashx") %>';
    var existingLogoUrl = '<%= GetExistingLogoUrl() %>';
    var existingFaviconUrl = '<%= GetExistingFaviconUrl() %>';
    var existingCodingLogoUrl = '<%= GetCodingLogoUrl() %>';

    // ---- 显示预览 ----
    function showPreview(suffix, src) {
        var img = document.getElementById('imgPreview' + suffix);
        var ph = document.getElementById('ph' + suffix);
        var preview = document.getElementById('preview' + suffix);
        if (!img) return;
        img.onload = function () {
            img.style.display = 'block';
            if (ph) ph.style.display = 'none';
            if (preview) preview.classList.add('has-img');
        };
        img.onerror = function () {
            img.style.display = 'none';
            // ICO 文件无法在 <img> 中预览，显示"已上传"状态
            if (src && (src.indexOf('.ico') !== -1 || src.indexOf('image/x-icon') !== -1) && ph) {
                ph.innerHTML = '<svg viewBox="0 0 24 24" style="width:32px;height:32px;stroke:#10b981;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg><span style="color:#10b981;font-size:11px">ICO 已上传</span>';
                ph.style.display = '';
                if (preview) preview.classList.add('has-img');
            } else {
                if (ph) ph.style.display = '';
                if (preview) preview.classList.remove('has-img');
            }
        };
        img.src = src;
    }

    // ---- 本地预览 ----
    function localPreview(suffix, file) {
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function (e) { showPreview(suffix, e.target.result); };
        reader.readAsDataURL(file);
    }

    // ---- Toast 提示 ----
    function showToast(suffix, type, msg) {
        var toast = document.getElementById('toast' + suffix);
        if (!toast) return;
        toast.className = 'brand-toast ' + type;
        if (type === 'loading') {
            toast.innerHTML = '<span class="brand-spinner"></span> ' + msg;
        } else if (type === 'success') {
            toast.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg> ' + msg;
            setTimeout(function () { toast.className = 'brand-toast'; toast.innerHTML = ''; }, 3000);
        } else {
            toast.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg> ' + msg;
        }
    }

    // ---- 上传逻辑 ----
    function uploadFile(file, type, suffix) {
        var progress = document.getElementById('progress' + suffix);
        progress.style.width = '0%';
        showToast(suffix, 'loading', '正在上传...');

        var formData = new FormData();
        formData.append('file', file);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', uploadUrl + '?type=' + type, true);

        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) {
                progress.style.width = Math.round((e.loaded / e.total) * 100) + '%';
            }
        };

        xhr.onload = function () {
            try {
                var res = JSON.parse(xhr.responseText);
                if (res.success === 1) {
                    progress.style.width = '100%';
                    showToast(suffix, 'success', res.message);
                    if (res.url) showPreview(suffix, res.url);
                    setTimeout(function () { progress.style.width = '0%'; }, 1500);
                } else {
                    progress.style.width = '0%';
                    showToast(suffix, 'error', res.message);
                }
            } catch (e) {
                progress.style.width = '0%';
                showToast(suffix, 'error', '响应解析错误');
            }
        };

        xhr.onerror = function () {
            progress.style.width = '0%';
            showToast(suffix, 'error', '网络错误，请重试');
        };

        xhr.send(formData);
    }

    // ---- 绑定事件 ----
    function setupBrandCard(suffix, type, acceptExts) {
        var card = document.getElementById('brandCard' + suffix);
        var wrap = document.getElementById('wrap' + suffix);
        var input = document.getElementById('fileInput' + suffix);

        // 点击预览区触发选择
        wrap.addEventListener('click', function (e) {
            if (e.target === input) return;
            input.click();
        });

        // 选择后自动上传
        input.addEventListener('change', function () {
            if (input.files.length > 0) {
                localPreview(suffix, input.files[0]);
                uploadFile(input.files[0], type, suffix);
            }
        });

        // 拖拽到整个卡片
        card.addEventListener('dragover', function (e) {
            e.preventDefault();
            card.classList.add('dragover');
        });
        card.addEventListener('dragleave', function (e) {
            e.preventDefault();
            card.classList.remove('dragover');
        });
        card.addEventListener('drop', function (e) {
            e.preventDefault();
            card.classList.remove('dragover');
            var files = e.dataTransfer.files;
            if (files.length > 0) {
                var file = files[0];
                var ext = '.' + file.name.split('.').pop().toLowerCase();
                if (acceptExts.indexOf(ext) === -1) {
                    showToast(suffix, 'error', '不支持的文件格式');
                    return;
                }
                localPreview(suffix, file);
                uploadFile(file, type, suffix);
            }
        });
    }

    // ---- 初始化 ----
    if (existingLogoUrl) showPreview('Logo', existingLogoUrl);
    if (existingFaviconUrl) showPreview('Favicon', existingFaviconUrl);
    if (existingCodingLogoUrl) showPreview('Coding', existingCodingLogoUrl);
    setupBrandCard('Logo', 'logo', ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp']);
    setupBrandCard('Favicon', 'favicon', ['.ico', '.png']);
    setupBrandCard('Coding', 'codinglogo', ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp']);
})();
</script>

</asp:Content>
