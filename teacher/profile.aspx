<%@ Page Title="个人中心" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" CodeFile="profile.aspx.cs" Inherits="teacher_profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    /* ========== CSS Variables ========== */
    :root {
        --primary: #6366f1;
        --primary-light: #818cf8;
        --primary-dark: #4f46e5;
        --primary-bg: rgba(99, 102, 241, 0.08);
        --accent: #a78bfa;
        --surface: #ffffff;
        --text: #1e293b;
        --text-secondary: #64748b;
        --text-muted: #94a3b8;
        --border: #e2e8f0;
        --border-light: #f1f5f9;
        --success: #10b981;
        --error: #ef4444;
        --info: #3b82f6;
        --radius: 16px;
        --radius-sm: 10px;
        --shadow-sm: 0 1px 3px rgba(0,0,0,0.04);
        --shadow-md: 0 4px 16px rgba(0,0,0,0.06);
        --shadow-lg: 0 12px 40px rgba(0,0,0,0.08);
        --ease: cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* ========== Animations ========== */
    @keyframes fadeUp {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* ========== Page Container ========== */
    .p-page {
        max-width: 1600px;
        margin: 0 auto;
        padding: 8px 24px 40px;
        animation: fadeUp 0.5s var(--ease);
    }

    /* ========== Profile Header ========== */
    .p-header {
        display: flex;
        align-items: center;
        gap: 32px;
        padding: 32px 40px;
        margin-bottom: 28px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: var(--radius);
        box-shadow: 0 8px 32px rgba(102, 126, 234, 0.25);
        border: none;
        position: relative;
        overflow: hidden;
    }
    .p-header::before {
        content: '';
        position: absolute;
        left: -50px;
        top: -50px;
        width: 200px;
        height: 200px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 50%;
    }
    .p-header::after {
        content: '';
        position: absolute;
        right: -30px;
        bottom: -30px;
        width: 150px;
        height: 150px;
        background: rgba(255, 255, 255, 0.08);
        border-radius: 50%;
    }

    /* Avatar in Header */
    .p-avatar-wrap { position: relative; flex-shrink: 0; z-index: 1; }
    .p-avatar {
        width: 88px;
        height: 88px;
        border-radius: 22px;
        background: linear-gradient(135deg, #ffd89b 0%, #19547b 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 36px;
        font-weight: 700;
        color: #fff;
        overflow: hidden;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
        transition: all 0.3s var(--ease);
        border: 4px solid rgba(255, 255, 255, 0.3);
    }
    .p-avatar:hover {
        transform: scale(1.05) rotate(2deg);
        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.3);
    }
    .p-avatar img { width: 100%; height: 100%; object-fit: cover; }
    .p-avatar-badge {
        position: absolute;
        bottom: -6px;
        right: -6px;
        width: 32px;
        height: 32px;
        background: linear-gradient(135deg, #667eea, #764ba2);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        transition: all 0.3s var(--ease);
        z-index: 2;
        border: 3px solid #fff;
    }
    .p-avatar-badge:hover {
        transform: scale(1.15) rotate(15deg);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
    }
    .p-avatar-badge svg {
        width: 16px; height: 16px;
        stroke: #fff; fill: none; stroke-width: 2.5;
    }

    /* Header Info */
    .p-header-info { flex: 1; min-width: 0; z-index: 1; }
    .p-name {
        font-size: 28px;
        font-weight: 800;
        color: #fff;
        margin: 0 0 12px;
        letter-spacing: -0.5px;
        text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    }
    .p-meta { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
    .p-tag {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: rgba(255, 255, 255, 0.25);
        backdrop-filter: blur(10px);
        color: #fff;
        font-size: 14px;
        font-weight: 600;
        border-radius: 24px;
        transition: all 0.3s var(--ease);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }
    .p-tag:hover { 
        background: rgba(255, 255, 255, 0.35);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }
    .p-tag svg {
        width: 16px; height: 16px;
        stroke: currentColor; fill: none; stroke-width: 2;
    }

    /* ========== Cards Grid ========== */
    .p-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
        gap: 24px;
    }

    /* ========== Card (shared base) ========== */
    .p-card {
        background: var(--surface);
        border-radius: var(--radius);
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border-light);
        overflow: hidden;
        transition: all 0.3s var(--ease);
        animation: fadeUp 0.5s var(--ease) both;
    }
    .p-card:nth-child(1) { animation-delay: 0.05s; }
    .p-card:nth-child(2) { animation-delay: 0.12s; }
    .p-card:hover {
        box-shadow: var(--shadow-lg);
        border-color: rgba(99,102,241,0.15);
        transform: translateY(-3px);
    }

    /* Card hero header */
    .p-card-hero {
        padding: 28px 24px 22px;
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    .p-card-hero::before {
        content: '';
        position: absolute;
        top: -30px; right: -30px;
        width: 120px; height: 120px;
        border-radius: 50%;
        background: rgba(99,102,241,0.06);
    }
    .p-card-hero::after {
        content: '';
        position: absolute;
        bottom: -20px; left: -20px;
        width: 80px; height: 80px;
        border-radius: 50%;
        background: rgba(167,139,250,0.08);
    }
    .p-card-hero--avatar { background: linear-gradient(135deg, #fef3c7 0%, #fde68a 50%, #fcd34d 100%); }
    .p-card-hero--pwd { background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 50%, #93c5fd 100%); }
    .p-card-hero-icon {
        width: 56px; height: 56px;
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 12px;
        position: relative;
        z-index: 1;
        box-shadow: 0 4px 14px rgba(0,0,0,0.1);
    }
    .p-card-hero--avatar .p-card-hero-icon {
        background: linear-gradient(135deg, #f59e0b, #fbbf24);
    }
    .p-card-hero--pwd .p-card-hero-icon {
        background: linear-gradient(135deg, #3b82f6, #60a5fa);
    }
    .p-card-hero-icon svg {
        width: 26px; height: 26px;
        stroke: #fff; fill: none; stroke-width: 2;
    }
    .p-card-hero-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--text);
        margin: 0 0 3px;
        position: relative;
        z-index: 1;
    }
    .p-card-hero-desc {
        font-size: 13px;
        color: var(--text-muted);
        position: relative;
        z-index: 1;
    }
    .p-card-body { padding: 24px; }

    /* ========== Alert ========== */
    .p-alert {
        display: none;
        align-items: center;
        gap: 10px;
        padding: 0;
        font-size: 14px;
        font-weight: 500;
        margin-bottom: 12px;
        animation: fadeUp 0.3s var(--ease);
        background: none !important;
        border: none !important;
        box-shadow: none !important;
    }
    .p-alert.show { display: flex; }
    .p-alert svg {
        width: 20px; 
        height: 20px; 
        flex-shrink: 0;
        stroke: currentColor; 
        fill: none; 
        stroke-width: 2.5;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    .p-alert span { 
        flex: 1; 
        min-width: 0; 
        line-height: 1.5;
        white-space: nowrap;
        background: none !important;
        border: none !important;
        padding: 0 !important;
    }
    .p-alert-success { color: var(--success); background: none !important; }
    .p-alert-error { color: var(--error); background: none !important; }
    .p-alert-info { color: var(--info); background: none !important; }

    /* ========== Form ========== */
    .p-field { margin-bottom: 18px; }
    .p-label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        color: var(--text-secondary);
        margin-bottom: 6px;
    }
    .p-label .req { color: var(--error); margin-left: 2px; }
    .p-input {
        width: 100%;
        padding: 11px 14px;
        border: 1.5px solid var(--border);
        border-radius: var(--radius-sm);
        font-size: 14px;
        color: var(--text);
        font-family: inherit;
        background: var(--surface);
        outline: none;
        transition: all 0.3s var(--ease);
    }
    .p-input:hover { border-color: #cbd5e1; }
    .p-input:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 3px var(--primary-bg);
    }
    .p-input:disabled {
        background: var(--border-light);
        color: var(--text-muted);
        cursor: not-allowed;
    }
    .p-hint {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 12px;
        color: var(--text-muted);
        margin-top: 6px;
    }
    .p-hint svg {
        width: 13px; height: 13px;
        stroke: currentColor; fill: none; stroke-width: 2;
    }

    /* ========== Avatar Preview ========== */
    .p-avatar-card {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--primary), var(--accent));
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 40px;
        font-weight: 700;
        color: #fff;
        margin: 0 auto 18px;
        overflow: hidden;
        border: 3px solid #e0e7ff;
        box-shadow: 0 4px 16px rgba(99,102,241,0.2);
        transition: all 0.3s var(--ease);
    }
    .p-avatar-card:hover {
        transform: scale(1.05);
        box-shadow: 0 8px 24px rgba(99,102,241,0.3);
    }
    .p-avatar-card img { width: 100%; height: 100%; object-fit: cover; }

    /* File Upload */
    .p-upload { position: relative; display: block; width: 100%; }
    .p-upload-hidden { position: absolute; left: -9999px; }
    .p-upload-label {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 12px 20px;
        background: var(--border-light);
        color: var(--text-secondary);
        border-radius: var(--radius-sm);
        cursor: pointer;
        font-size: 13px;
        font-weight: 600;
        border: 2px dashed var(--border);
        transition: all 0.3s var(--ease);
    }
    .p-upload-label:hover {
        background: var(--primary-bg);
        border-color: var(--primary-light);
        color: var(--primary);
    }
    .p-upload-label svg {
        width: 18px; height: 18px;
        stroke: currentColor; fill: none; stroke-width: 2;
    }

    /* ========== Code Row ========== */
    .p-code-row { display: flex; gap: 10px; align-items: stretch; }
    .p-code-input { flex: 1; min-width: 0; }
    .p-code-input .p-input { width: 100%; height: 100%; }
    .p-send-btn {
        min-width: 120px;
        padding: 0 16px;
        border: none;
        border-radius: var(--radius-sm);
        background: linear-gradient(135deg, var(--primary), var(--primary-light));
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        font-family: inherit;
        cursor: pointer;
        white-space: nowrap;
        transition: all 0.3s var(--ease);
        flex-shrink: 0;
    }
    .p-send-btn:hover {
        background: linear-gradient(135deg, var(--primary-dark), var(--primary));
        box-shadow: 0 2px 10px rgba(99,102,241,0.3);
    }
    .p-send-btn:disabled {
        background: var(--border);
        color: var(--text-muted);
        cursor: not-allowed;
        box-shadow: none;
    }

    /* ========== Email Card Special ========== */
    .p-email-card {
        background: var(--surface);
        border-radius: var(--radius);
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border-light);
        overflow: hidden;
        transition: all 0.3s var(--ease);
        animation: fadeUp 0.5s var(--ease) 0.19s both;
    }
    .p-email-card:hover {
        box-shadow: var(--shadow-lg);
        border-color: rgba(99,102,241,0.15);
        transform: translateY(-3px);
    }
    .p-email-hero {
        background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 50%, #ede9fe 100%);
        padding: 32px 24px 24px;
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    .p-email-hero::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -30px;
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background: rgba(99,102,241,0.08);
    }
    .p-email-hero::after {
        content: '';
        position: absolute;
        bottom: -20px;
        left: -20px;
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: rgba(167,139,250,0.1);
    }
    .p-email-hero-icon {
        width: 56px;
        height: 56px;
        border-radius: 16px;
        background: linear-gradient(135deg, var(--primary), var(--accent));
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 14px;
        box-shadow: 0 4px 14px rgba(99,102,241,0.25);
        position: relative;
        z-index: 1;
    }
    .p-email-hero-icon svg {
        width: 26px; height: 26px;
        stroke: #fff; fill: none; stroke-width: 2;
    }
    .p-email-hero-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--text);
        margin: 0 0 4px;
        position: relative;
        z-index: 1;
    }
    .p-email-hero-desc {
        font-size: 13px;
        color: var(--text-muted);
        position: relative;
        z-index: 1;
    }
    .p-email-body {
        padding: 24px;
    }

    /* Email Display (bound state) */
    .p-email-box {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 14px 0;
    }
    .p-email-box svg {
        width: 20px; height: 20px;
        stroke: var(--primary); fill: none; stroke-width: 2;
        flex-shrink: 0;
    }
    .p-email-text {
        flex: 1;
        font-size: 15px;
        color: var(--text);
        font-weight: 600;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .p-email-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 10px;
        background: #ecfdf5;
        color: var(--success);
        font-size: 12px;
        font-weight: 600;
        border-radius: 20px;
        flex-shrink: 0;
    }
    .p-email-badge svg {
        width: 12px; height: 12px;
        stroke: var(--success);
    }

    /* ========== Buttons ========== */
    .p-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 11px 24px;
        border: none;
        border-radius: var(--radius-sm);
        font-size: 14px;
        font-weight: 600;
        font-family: inherit;
        cursor: pointer;
        transition: all 0.3s var(--ease);
        position: relative;
        overflow: hidden;
    }
    .p-btn svg {
        width: 16px; height: 16px;
        stroke: currentColor; fill: none; stroke-width: 2;
    }
    .p-btn-primary {
        background: linear-gradient(135deg, var(--primary), var(--primary-light));
        color: #fff;
        box-shadow: 0 2px 10px rgba(99,102,241,0.25);
    }
    .p-btn-primary:hover {
        background: linear-gradient(135deg, var(--primary-dark), var(--primary));
        box-shadow: 0 4px 18px rgba(99,102,241,0.35);
        transform: translateY(-1px);
    }
    .p-btn-primary:active { transform: translateY(0); }
    .p-btn-ghost {
        background: var(--border-light);
        color: var(--text-secondary);
    }
    .p-btn-ghost:hover { background: var(--border); color: var(--text); }
    .p-btn-block { width: 100%; }
    .p-btn.loading { pointer-events: none; opacity: 0.7; }

    /* ========== Footer ========== */
    .p-footer {
        margin-top: 28px;
        display: flex;
        justify-content: flex-end;
    }

    /* ========== Responsive ========== */
    @media (max-width: 768px) {
        .p-page { padding: 8px 10px 32px; }
        .p-header {
            flex-direction: column;
            text-align: center;
            padding: 24px 20px;
            gap: 16px;
        }
        .p-header::before { width: 100%; height: 4px; bottom: auto; right: 0; }
        .p-avatar { width: 64px; height: 64px; font-size: 24px; border-radius: 16px; }
        .p-name { font-size: 20px; }
        .p-meta { justify-content: center; }
        .p-grid { grid-template-columns: 1fr; gap: 16px; }
        .p-card-body { padding: 16px 18px 20px; }
    }
</style>

<div class="p-page">

    <!-- ===== Profile Header ===== -->
    <div class="p-header">
        <div class="p-avatar-wrap">
            <div class="p-avatar" id="headerAvatar">
                <asp:Literal ID="LitHeaderAvatar" runat="server" />
            </div>
            <div class="p-avatar-badge" onclick="document.getElementById('<%= FileAvatar.ClientID %>').click();" title="更换头像">
                <svg viewBox="0 0 24 24"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
            </div>
        </div>
        <div class="p-header-info">
            <h1 class="p-name"><asp:Literal ID="LitTeacherName" runat="server" /></h1>
            <div class="p-meta">
                <span class="p-tag">
                    <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                    <asp:Literal ID="LitTeacherEmail" runat="server" Text="未绑定邮箱" />
                </span>
                <span class="p-tag" id="schoolTag" runat="server">
                    <svg viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                    <asp:Literal ID="LitSchoolDisplay" runat="server" Text="未设置学校" />
                </span>
                <span class="p-tag" id="campusTag" runat="server">
                    <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                    <asp:Literal ID="LitCampusDisplay" runat="server" Text="未设置校区" />
                </span>
            </div>
        </div>
    </div>

    <!-- ===== Cards ===== -->
    <div class="p-grid">

        <!-- Card: Avatar Upload -->
        <div class="p-card">
            <div class="p-card-hero p-card-hero--avatar">
                <div class="p-card-hero-icon">
                    <svg viewBox="0 0 24 24"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                </div>
                <h2 class="p-card-hero-title">更换头像</h2>
                <p class="p-card-hero-desc">上传一张喜欢的图片作为头像</p>
            </div>
            <div class="p-card-body">
                <div id="avatarAlert" class="p-alert"></div>

                <div class="p-avatar-card" id="avatarPreview">
                    <asp:Literal ID="LitAvatarPreview" runat="server" />
                </div>

                <div class="p-upload">
                    <asp:FileUpload ID="FileAvatar" runat="server" CssClass="p-upload-hidden" onchange="previewAvatar(this)" accept="image/*" />
                    <label for="<%= FileAvatar.ClientID %>" class="p-upload-label">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        选择图片文件
                    </label>
                </div>
                <div class="p-hint">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    支持 JPG、PNG、GIF、WebP，不超过 2MB
                </div>

                <div style="margin-top: 20px;">
                    <asp:Button ID="BtnUploadAvatar" runat="server" Text="上传头像" CssClass="p-btn p-btn-primary p-btn-block" OnClick="BtnUploadAvatar_Click" />
                </div>
            </div>
        </div>

        <!-- Card: Change Password -->
        <div class="p-card">
            <div class="p-card-hero p-card-hero--pwd">
                <div class="p-card-hero-icon">
                    <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <h2 class="p-card-hero-title">修改密码</h2>
                <p class="p-card-hero-desc">定期修改密码以保障账户安全</p>
            </div>
            <div class="p-card-body">
                <div id="passwordAlert" class="p-alert"></div>

                <div class="p-field">
                    <label class="p-label">当前密码<span class="req">*</span></label>
                    <asp:TextBox ID="TxtOldPassword" runat="server" TextMode="Password" CssClass="p-input" placeholder="请输入当前密码" />
                </div>
                <div class="p-field">
                    <label class="p-label">新密码<span class="req">*</span></label>
                    <asp:TextBox ID="TxtNewPassword" runat="server" TextMode="Password" CssClass="p-input" placeholder="请输入新密码（至少6位）" />
                    <div class="p-hint">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        建议包含字母和数字，至少6位
                    </div>
                </div>
                <div class="p-field">
                    <label class="p-label">确认新密码<span class="req">*</span></label>
                    <asp:TextBox ID="TxtConfirmPassword" runat="server" TextMode="Password" CssClass="p-input" placeholder="请再次输入新密码" />
                </div>

                <div style="margin-top: 20px;">
                    <asp:Button ID="BtnChangePassword" runat="server" Text="修改密码" CssClass="p-btn p-btn-primary p-btn-block" OnClick="BtnChangePassword_Click" />
                </div>
            </div>
        </div>

        <!-- Card: Bind Email -->
        <div class="p-email-card">
            <div class="p-email-hero">
                <div class="p-email-hero-icon">
                    <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                </div>
                <h2 class="p-email-hero-title">绑定邮箱</h2>
                <p class="p-email-hero-desc">用于找回密码和接收系统通知</p>
            </div>
            <div class="p-email-body">
                <div id="emailAlert" class="p-alert"></div>

                <!-- Bound state -->
                <asp:Panel ID="PnlEmailSummary" runat="server" Visible="false">
                    <div class="p-email-box">
                        <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <asp:Label ID="LblBoundEmail" runat="server" CssClass="p-email-text"></asp:Label>
                        <span class="p-email-badge">
                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                            已绑定
                        </span>
                    </div>
                    <div style="margin-top: 20px;">
                        <asp:Button ID="BtnEditEmail" runat="server" Text="修改邮箱" CssClass="p-btn p-btn-ghost p-btn-block" OnClick="BtnEditEmail_Click" />
                    </div>
                </asp:Panel>

                <!-- Unbound / editing state -->
                <asp:Panel ID="PnlEmailForm" runat="server">
                    <div class="p-field">
                        <label class="p-label">邮箱地址<span class="req">*</span></label>
                        <asp:TextBox ID="TxtEmail" runat="server" CssClass="p-input" placeholder="请输入邮箱地址" />
                    </div>
                    <div class="p-field">
                        <label class="p-label">验证码<span class="req">*</span></label>
                        <div class="p-code-row">
                            <div class="p-code-input">
                                <asp:TextBox ID="TxtEmailCaptcha" runat="server" CssClass="p-input" placeholder="请输入邮箱验证码" MaxLength="6" />
                            </div>
                            <button type="button" id="btnSendCode" class="p-send-btn" onclick="sendEmailCode()">发送验证码</button>
                        </div>
                        <div class="p-hint" style="margin-top: 8px;">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                            验证码将发送到您输入的邮箱，5分钟内有效
                        </div>
                    </div>

                    <div style="margin-top: 20px;">
                        <asp:Button ID="BtnBindEmail" runat="server" Text="绑定邮箱" CssClass="p-btn p-btn-primary p-btn-block" OnClick="BtnBindEmail_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>

    </div>

</div>

<script type="text/javascript">
    // Preview avatar
    function previewAvatar(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            if (file.size > 2 * 1024 * 1024) {
                showAlert('error', '图片大小不能超过 2MB', 'avatarAlert');
                input.value = '';
                return;
            }
            var validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
            if (validTypes.indexOf(file.type) === -1) {
                showAlert('error', '只支持 JPG、PNG、GIF、WebP 格式', 'avatarAlert');
                input.value = '';
                return;
            }
            var reader = new FileReader();
            reader.onload = function (e) {
                var preview = document.getElementById('avatarPreview');
                var header = document.getElementById('headerAvatar');
                var imgHtml = '<img src="' + e.target.result + '" />';
                if (preview) preview.innerHTML = imgHtml;
                if (header) header.innerHTML = imgHtml;
                showAlert('info', '图片已选择，点击"上传头像"按钮保存', 'avatarAlert');
            };
            reader.readAsDataURL(file);
        }
    }

    // Send email verification code via AJAX
    var _sendCooldown = 0;
    function sendEmailCode() {
        var emailInput = document.querySelector('[id$="TxtEmail"]');
        if (!emailInput) return;
        var email = emailInput.value.trim();
        if (!email) {
            showAlert('error', '请先输入邮箱地址', 'emailAlert');
            return;
        }
        if (email.indexOf('@') < 0 || email.indexOf('.') < 0) {
            showAlert('error', '邮箱格式不正确', 'emailAlert');
            return;
        }

        var btn = document.getElementById('btnSendCode');
        btn.disabled = true;
        btn.textContent = '发送中...';

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'SendEmailCode.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                try {
                    var resp = JSON.parse(xhr.responseText);
                    if (resp.success) {
                        showAlert('success', resp.message, 'emailAlert');
                        startCountdown(60);
                    } else {
                        showAlert('error', resp.message, 'emailAlert');
                        btn.disabled = false;
                        btn.textContent = '发送验证码';
                    }
                } catch (e) {
                    showAlert('error', '发送失败，请稍后重试', 'emailAlert');
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                }
            }
        };
        xhr.send('email=' + encodeURIComponent(email));
    }

    function startCountdown(sec) {
        var btn = document.getElementById('btnSendCode');
        _sendCooldown = sec;
        btn.disabled = true;
        btn.textContent = _sendCooldown + 's 后重发';
        var timer = setInterval(function () {
            _sendCooldown--;
            if (_sendCooldown <= 0) {
                clearInterval(timer);
                btn.disabled = false;
                btn.textContent = '发送验证码';
            } else {
                btn.textContent = _sendCooldown + 's 后重发';
            }
        }, 1000);
    }

    // Show alert message
    function showAlert(type, message, containerId) {
        var el = document.getElementById(containerId);
        if (!el) return;
        var icons = {
            success: '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>',
            error: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
            info: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
        };
        el.innerHTML = (icons[type] || icons.info);
        var sp = document.createElement('span');
        sp.textContent = message;
        el.appendChild(sp);
        el.className = 'p-alert p-alert-' + type + ' show';
        el.title = message;
        setTimeout(function () { el.classList.remove('show'); }, 5000);
    }

    // Init
    window.onload = function () {
        var urlParams = new URLSearchParams(window.location.search);
        var msg = urlParams.get('msg');
        var type = urlParams.get('type');
        var target = urlParams.get('target');
        if (msg && type && target) {
            showAlert(type, decodeURIComponent(msg), target + 'Alert');
        }

        document.querySelectorAll('.p-input').forEach(function (input) {
            input.addEventListener('focus', function () { this.style.borderColor = ''; });
            input.addEventListener('blur', function () {
                var v = this.value.trim();
                if (this.type === 'password' && v && v.length < 6) {
                    this.style.borderColor = 'var(--error)';
                } else {
                    this.style.borderColor = '';
                }
            });
        });
    };
</script>

</asp:Content>
