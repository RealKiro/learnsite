<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_courseshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== courseshow 页面美化 ===== */
    .cs-page { max-width: 1600px; margin: 0 auto; padding: 0 12px; }

    /* 课程标题卡片 */
    .cs-header-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 16px;
        padding: 28px 32px 24px;
        margin-bottom: 20px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(102, 126, 234, 0.25);
    }
    .cs-header-card::before {
        content: '';
        position: absolute;
        top: -40px; right: -40px;
        width: 160px; height: 160px;
        background: rgba(255,255,255,0.08);
        border-radius: 50%;
    }
    .cs-header-card::after {
        content: '';
        position: absolute;
        bottom: -60px; left: 30%;
        width: 200px; height: 200px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
    }
    .cs-header-card .coursetitle {
        font-size: 20px !important;
        font-weight: 700 !important;
        color: #fff !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
        position: relative;
        z-index: 1;
        display: block;
        margin-bottom: 16px;
        letter-spacing: 0.5px;
    }
    .cs-meta-row {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px;
        position: relative;
        z-index: 1;
    }
    .cs-meta-tag {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        background: rgba(255,255,255,0.18);
        color: #fff;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12.5px;
        font-weight: 500;
        backdrop-filter: blur(4px);
        white-space: nowrap;
    }
    .cs-meta-tag svg {
        width: 14px; height: 14px;
        stroke: rgba(255,255,255,0.8);
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }
    .cs-header-actions {
        display: flex;
        gap: 8px;
        margin-left: auto;
    }
    .cs-header-card .cs-icon-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 34px; height: 34px;
        background: rgba(255,255,255,0.2);
        border-radius: 10px;
        transition: all 0.2s;
        cursor: pointer;
    }
    .cs-header-card .cs-icon-btn:hover {
        background: rgba(255,255,255,0.35);
        transform: translateY(-1px);
    }
    .cs-header-card .cs-icon-btn img {
        width: 16px; height: 16px;
        filter: brightness(0) invert(1);
    }
    .cs-banner-img {
        height: 22px;
        border-radius: 4px;
        vertical-align: middle;
    }

    /* 工具栏卡片 */
    .cs-toolbar-card {
        background: #fff;
        border-radius: 14px;
        padding: 20px 24px;
        margin-bottom: 20px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .cs-toolbar-title {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 14px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .cs-toolbar-title svg {
        width: 18px; height: 18px;
        stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .cs-toolbar-grid {
        display: flex;
        flex-wrap: nowrap;
        gap: 6px;
        overflow-x: auto;
    }
    .cs-toolbar-grid::-webkit-scrollbar { height: 0; }
    .cs-toolbar-grid .button24 {
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        gap: 6px;
        background: #f8fafc !important;
        color: #475569 !important;
        border: 1px solid #e2e8f0 !important;
        border-radius: 8px !important;
        padding: 7px 13px !important;
        font-size: 13px !important;
        font-weight: 500 !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
        height: auto !important;
        width: auto !important;
        line-height: 1.4 !important;
        text-decoration: none !important;
        transition: all 0.2s ease;
        cursor: pointer;
        white-space: nowrap;
        flex-shrink: 0;
    }
    .cs-toolbar-grid .button24:hover {
        background: #eef2ff !important;
        color: #4f46e5 !important;
        border-color: #c7d2fe !important;
        box-shadow: 0 2px 6px rgba(99,102,241,0.1);
    }
    .cs-toolbar-grid .button24 .tb-icon {
        width: 16px; height: 16px;
        stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }
    .cs-toolbar-grid .button24:hover .tb-icon {
        stroke: #4f46e5;
    }

    /* 导航列表卡片 */
    .cs-list-card {
        background: #fff;
        border-radius: 14px;
        padding: 20px 24px;
        margin-bottom: 20px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .cs-list-title {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 14px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .cs-list-title svg {
        width: 18px; height: 18px;
        stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .cs-list-card .cs-gv-wrap { overflow-x: auto; }
    .cs-list-card .cs-gv-wrap table {
        width: 100% !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
        border: none !important;
    }
    .cs-list-card .cs-gv-wrap th {
        background: #f8fafc !important;
        color: #64748b !important;
        font-size: 12px !important;
        font-weight: 600 !important;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        padding: 10px 14px !important;
        border-bottom: 2px solid #e8ecf1 !important;
        white-space: nowrap;
    }
    .cs-list-card .cs-gv-wrap td {
        padding: 10px 14px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        font-size: 13px !important;
        color: #334155;
        vertical-align: middle;
        background: #fff !important;
    }
    .cs-list-card .cs-gv-wrap tr:last-child td {
        border-bottom: none !important;
    }
    .cs-list-card .cs-gv-wrap tr:hover td {
        background: #f8fafc !important;
    }
    .cs-list-card .cs-gv-wrap tr td:first-child,
    .cs-list-card .cs-gv-wrap tr th:first-child {
        border-radius: 8px 0 0 8px;
    }
    .cs-list-card .cs-gv-wrap tr td:last-child,
    .cs-list-card .cs-gv-wrap tr th:last-child {
        border-radius: 0 8px 8px 0;
    }
    .cs-list-card .cs-gv-wrap a {
        color: #4f46e5;
        text-decoration: none;
        font-weight: 500;
        transition: color 0.15s;
    }
    .cs-list-card .cs-gv-wrap a:hover {
        color: #4338ca;
        text-decoration: underline;
    }

    .cs-list-card .cs-gv-wrap a.cs-publish-link,
    .cs-list-card .cs-gv-wrap a.cs-delete-link {
        text-decoration: none !important;
    }

    .cs-publish-link {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 8px !important;
        min-width: 116px !important;
        padding: 7px 12px !important;
        border-radius: 999px !important;
        border: 1px solid #dbe4f0 !important;
        background: #f8fafc !important;
        color: #475569 !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        transition: all .18s ease !important;
        box-sizing: border-box !important;
    }

    .cs-publish-link:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 14px rgba(15, 23, 42, 0.08);
    }

    .cs-publish-link .cs-switch-core {
        width: 38px;
        height: 22px;
        border-radius: 999px;
        background: #cbd5e1;
        position: relative;
        flex-shrink: 0;
        transition: all .18s ease;
        box-shadow: inset 0 1px 3px rgba(15, 23, 42, 0.18);
    }

    .cs-publish-link .cs-switch-thumb {
        position: absolute;
        top: 3px;
        left: 3px;
        width: 16px;
        height: 16px;
        border-radius: 50%;
        background: #fff;
        box-shadow: 0 2px 6px rgba(15, 23, 42, 0.18);
        transition: all .18s ease;
    }

    .cs-publish-link .cs-switch-text {
        white-space: nowrap;
        line-height: 1;
    }

    .cs-publish-link.is-on {
        background: #ecfdf5 !important;
        border-color: #bbf7d0 !important;
        color: #166534 !important;
    }

    .cs-publish-link.is-on .cs-switch-core {
        background: linear-gradient(135deg, #34d399, #10b981);
    }

    .cs-publish-link.is-on .cs-switch-thumb {
        left: 19px;
    }

    .cs-publish-link.is-off {
        background: #fff7ed !important;
        border-color: #fed7aa !important;
        color: #c2410c !important;
    }

    .cs-publish-link.is-off .cs-switch-core {
        background: #fdba74;
    }

    .cs-delete-link {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        min-width: 78px !important;
        padding: 8px 14px !important;
        border-radius: 12px !important;
        border: 1px solid #fecaca !important;
        background: #fff5f5 !important;
        color: #ef4444 !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        transition: all .18s ease !important;
    }

    .cs-delete-link:hover {
        background: #fee2e2 !important;
        border-color: #fca5a5 !important;
        color: #dc2626 !important;
    }

    .cs-modal-mask {
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.48);
        display: none;
        align-items: center;
        justify-content: center;
        z-index: 99999;
        padding: 20px;
    }

    .cs-modal-mask.is-open {
        display: flex;
    }

    .cs-modal {
        width: min(100%, 420px);
        background: #ffffff;
        border-radius: 20px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 22px 50px rgba(15, 23, 42, 0.18);
        overflow: hidden;
    }

    .cs-modal-head {
        padding: 22px 24px 12px;
        font-size: 18px;
        font-weight: 700;
        color: #0f172a;
    }

    .cs-modal-body {
        padding: 0 24px 24px;
        font-size: 14px;
        line-height: 1.7;
        color: #475569;
    }

    .cs-modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        padding: 16px 24px 24px;
        border-top: 1px solid #f1f5f9;
    }

    .cs-modal-btn {
        border: 1px solid #dbe4f0;
        background: #fff;
        color: #334155;
        min-width: 94px;
        height: 40px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all .18s ease;
    }

    .cs-modal-btn:hover {
        background: #f8fafc;
    }

    .cs-modal-btn-primary {
        border-color: #6366f1;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff;
    }

    .cs-modal-btn-primary:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1);
    }
    
    /* 活动类型图标样式 - 与工具栏保持一致 */
    .cs-activity-icon {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 5px 10px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        transition: all 0.2s ease;
    }
    .cs-activity-icon:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
    }
    .cs-activity-icon svg {
        width: 16px;
        height: 16px;
        stroke: #64748b;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }
    .cs-activity-icon span {
        font-size: 13px;
        font-weight: 400;
        color: #475569;
    }
    
    /* 不同类型的图标颜色 */
    .cs-activity-icon.type-code svg { stroke: #10b981; }
    .cs-activity-icon.type-discuss svg { stroke: #f59e0b; }
    .cs-activity-icon.type-survey svg { stroke: #8b5cf6; }
    .cs-activity-icon.type-form svg { stroke: #3b82f6; }
    .cs-activity-icon.type-flow svg { stroke: #06b6d4; }
    .cs-activity-icon.type-draw svg { stroke: #f97316; }
    .cs-activity-icon.type-html svg { stroke: #ef4444; }
    .cs-activity-icon.type-mind svg { stroke: #84cc16; }
    .cs-activity-icon.type-excel svg { stroke: #059669; }
    .cs-activity-icon.type-ware svg { stroke: #6366f1; }
    
    /* 隐藏原始图片图标 */
    .cs-list-card .cs-gv-wrap img {
        display: none !important;
    }

    /* 课程内容区域 */
    .cs-content-card {
        background: #fff;
        border-radius: 14px;
        padding: 24px 28px;
        margin-bottom: 24px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .cs-content-card .coursecontent {
        border: none !important;
        width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
        font-size: 14px !important;
        line-height: 1.75 !important;
        color: #334155;
    }

    /* 移动端适配 */
    @media (max-width: 768px) {
        .cs-header-card { padding: 20px; border-radius: 12px; }
        .cs-header-card .coursetitle { font-size: 17px !important; }
        .cs-meta-row { gap: 6px; }
        .cs-toolbar-card, .cs-list-card, .cs-content-card { padding: 14px 16px; border-radius: 12px; }
        .cs-toolbar-grid .button24 { padding: 5px 10px !important; font-size: 12px !important; }
    }
</style>

<div class="cs-page">
    <!-- 课程标题与元信息卡片 -->
    <div class="cs-header-card">
        <asp:Label ID="LabelCtitle" runat="server" CssClass="coursetitle"></asp:Label>
        <div class="cs-meta-row">
            <asp:Image ID="Imagebanner" runat="server" Height="22px" ToolTip="横幅图片" CssClass="cs-banner-img" />
            <span class="cs-meta-tag">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <asp:Label ID="LabelCdate" runat="server"></asp:Label>
            </span>
            <span class="cs-meta-tag">
                <svg viewBox="0 0 24 24"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg>
                <asp:Label ID="LabelCclass" runat="server"></asp:Label> 类型
            </span>
            <span class="cs-meta-tag">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                <asp:Label ID="LabelCobj" runat="server"></asp:Label> 年级
            </span>
            <span class="cs-meta-tag">
                <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                第 <asp:Label ID="LabelCterm" runat="server"></asp:Label> 学期
            </span>
            <span class="cs-meta-tag">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                第 <asp:Label ID="LabelCks" runat="server"></asp:Label> 课
            </span>
            <span class="cs-header-actions">
                <asp:ImageButton ID="BtnEdit" runat="server" ToolTip="点击修改"
                    ImageUrl="~/images/edit.gif" onclick="BtnEdit_Click" CssClass="cs-icon-btn" />
                <asp:LinkButton ID="LinkBtnReturn" runat="server"
                    OnClick="LinkBtnReturn_Click" title="返回" CssClass="cs-icon-btn"><img src="../images/return.gif" /></asp:LinkButton>
            </span>
        </div>
    </div>

    <!-- 工具栏 -->
    <div class="cs-toolbar-card">
        <div class="cs-toolbar-title">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
            添加课程内容
        </div>
        <div class="cs-toolbar-grid">
            <asp:LinkButton ID="LinkBtnAdd" runat="server"
                OnClick="LinkBtnAdd_Click" CssClass="button24" title="学习活动"><svg class="tb-icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>活动</asp:LinkButton>
            <asp:LinkButton ID="LinkBtnAddTopic" runat="server"
                OnClick="LinkBtnAddTopic_Click" CssClass="button24" title="课堂讨论板"><svg class="tb-icon" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>讨论</asp:LinkButton>
            <asp:LinkButton ID="LinkBtnAddSurvey" runat="server"
                OnClick="LinkBtnAddSurvey_Click" CssClass="button24" title="课堂调查"><svg class="tb-icon" viewBox="0 0 24 24"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>调查</asp:LinkButton>
            <asp:LinkButton ID="LinkBtnAddTxtForm" runat="server"
                OnClick="LinkBtnAddTxtForm_Click" CssClass="button24" title="表格填写"><svg class="tb-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/></svg>填表</asp:LinkButton>
            <asp:LinkButton ID="LinkBtnProgram" runat="server"
                OnClick="LinkBtnProgram_Click" CssClass="button24" title="Scratch积木编程"><svg class="tb-icon" viewBox="0 0 24 24"><rect x="2" y="6" width="8" height="6" rx="1"/><rect x="14" y="6" width="8" height="6" rx="1"/><rect x="8" y="14" width="8" height="6" rx="1"/></svg>积木编程</asp:LinkButton>
            <asp:LinkButton ID="LinkBtnPython" runat="server"
                OnClick="LinkBtnPython_Click" CssClass="button24" title="在线Python编程"><svg class="tb-icon" viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/><line x1="14" y1="4" x2="10" y2="20"/></svg>Python</asp:LinkButton>
            <asp:LinkButton ID="LinkBtnConsole" runat="server"
                OnClick="LinkBtnConsole_Click" CssClass="button24" title="在线Python测评"><svg class="tb-icon" viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>测评</asp:LinkButton>
            <asp:LinkButton ID="LinkButtonGraph" runat="server"
                OnClick="LinkBtnGraph_Click" CssClass="button24" title="在线流程图"><svg class="tb-icon" viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>流程图</asp:LinkButton>
            <asp:LinkButton ID="LinkButtonPixel" runat="server"
                CssClass="button24" onclick="LinkButtonPixel_Click" title="在线应用"><svg class="tb-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>应用</asp:LinkButton>
            <asp:LinkButton ID="LinkButtonHtml" runat="server"
                CssClass="button24" onclick="LinkButtonHtml_Click" title="单网页设计"><svg class="tb-icon" viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>Html</asp:LinkButton>
            <asp:LinkButton ID="LinkButtonKm" runat="server"
                CssClass="button24" onclick="LinkButtonKm_Click" title="在线思维导图"><svg class="tb-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="12" y1="15" x2="12" y2="22"/><line x1="2" y1="12" x2="9" y2="12"/><line x1="15" y1="12" x2="22" y2="12"/></svg>导图</asp:LinkButton>
            <asp:LinkButton ID="LinkButtonExcel" runat="server"
                CssClass="button24" onclick="LinkButtonExcel_Click" title="在线表格"><svg class="tb-icon" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>表格</asp:LinkButton>
            <asp:LinkButton ID="LinkButtonware" runat="server"
                CssClass="button24" onclick="LinkButtonware_Click" title="嵌入网页小课件"><svg class="tb-icon" viewBox="0 0 24 24"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>课件</asp:LinkButton>
        </div>
    </div>

    <!-- 导航栏目列表 -->
    <div class="cs-list-card">
        <div class="cs-list-title">
            <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            导航栏目
        </div>
        <div class="cs-gv-wrap">
            <asp:GridView ID="GVlistmenu" runat="server" Width="100%" SkinID="GVmission"
                CellPadding="6" AutoGenerateColumns="False"
                EnableModelValidation="True" HorizontalAlign="Center"
                onrowcommand="GVlistmenu_RowCommand"
                onrowdatabound="GVlistmenu_RowDataBound" >
                <Columns>
                    <asp:TemplateField Visible="False">
                        <ItemTemplate>
                            <asp:Label ID="LabelLid" runat="server" Text='<%# Bind("Lid") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField Visible="False">
                        <ItemTemplate>
                            <asp:Label ID="LabelLxid" runat="server" Text='<%# Bind("Lxid") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField Visible="False">
                        <ItemTemplate>
                            <asp:Label ID="LabelLtype" runat="server" Text='<%# Bind("Ltype") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="序号">
                        <ItemTemplate>
                            <asp:Label ID="LabelLsort" runat="server" Text='<%# Bind("Lsort") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle Width="50px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="类型">
                        <ItemTemplate>
                            <asp:Image ID="Image4" runat="server" ImageUrl="~/images/new_none.gif" />
                            <asp:Label ID="Label4" runat="server"></asp:Label>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle Width="160px" HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="导航栏目">
                        <ItemTemplate>
                            <asp:HyperLink ID="HlLtitle" runat="server" NavigateUrl=""
                                Text='<%# Eval("Ltitle") %>'></asp:HyperLink>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="ImageBtnTop" runat="server" CausesValidation="False"
                                CommandName="Top" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>'
                                Text="↑" ToolTip="向上移" Font-Underline="False"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="30px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="ImageBtnBottom" runat="server" CausesValidation="False"
                                CommandName="Bottom" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>'
                                Text="↓" ToolTip="向下移" Font-Underline="False"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="30px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="启用">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkBtnShow" runat="server" CausesValidation="false"
                                CommandName="P" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>'
                                Text='<%# Eval("lshow") %>' ToolTip="True显示，False隐藏"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="60px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="操作">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkBtnDel" runat="server" CausesValidation="false"
                                CommandName="D" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>'
                                Text="删除" ToolTip="请认真确定是否删除，不可恢复！"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="60px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                </Columns>
                <RowStyle Height="40px" />
            </asp:GridView>
        </div>
    </div>

    <!-- 课程内容 -->
    <div class="cs-content-card">
        <div id="Ccontent" class="coursecontent" runat="server"></div>
    </div>
</div>

<div class="cs-modal-mask" id="csActionModal" aria-hidden="true">
    <div class="cs-modal" role="dialog" aria-modal="true" aria-labelledby="csModalTitle">
        <div class="cs-modal-head" id="csModalTitle">操作确认</div>
        <div class="cs-modal-body" id="csModalMessage"></div>
        <div class="cs-modal-actions">
            <button type="button" class="cs-modal-btn" id="csModalCancel">取消</button>
            <button type="button" class="cs-modal-btn cs-modal-btn-primary" id="csModalConfirm">确定</button>
        </div>
    </div>
</div>

<script type="text/javascript">
// 替换活动类型图标为SVG
function replaceActivityIcons() {
    // 定义活动类型与SVG图标的映射
    var iconMap = {
        '积木': { svg: '<svg viewBox="0 0 24 24"><rect x="2" y="6" width="8" height="6" rx="1"/><rect x="14" y="6" width="8" height="6" rx="1"/><rect x="8" y="14" width="8" height="6" rx="1"/></svg>', type: 'code' },
        '活动': { svg: '<svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>', type: 'code' },
        '讨论': { svg: '<svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>', type: 'discuss' },
        '调查': { svg: '<svg viewBox="0 0 24 24"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>', type: 'survey' },
        '填表': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/></svg>', type: 'form' },
        '积木编程': { svg: '<svg viewBox="0 0 24 24"><rect x="2" y="6" width="8" height="6" rx="1"/><rect x="14" y="6" width="8" height="6" rx="1"/><rect x="8" y="14" width="8" height="6" rx="1"/></svg>', type: 'code' },
        'Python': { svg: '<svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/><line x1="14" y1="4" x2="10" y2="20"/></svg>', type: 'code' },
        '测评': { svg: '<svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>', type: 'survey' },
        '流程': { svg: '<svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>', type: 'flow' },
        '流程图': { svg: '<svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>', type: 'flow' },
        '应用': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', type: 'code' },
        'Html': { svg: '<svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>', type: 'html' },
        '导图': { svg: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="12" y1="15" x2="12" y2="22"/><line x1="2" y1="12" x2="9" y2="12"/><line x1="15" y1="12" x2="22" y2="12"/></svg>', type: 'mind' },
        '脑图': { svg: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="12" y1="15" x2="12" y2="22"/><line x1="2" y1="12" x2="9" y2="12"/><line x1="15" y1="12" x2="22" y2="12"/></svg>', type: 'mind' },
        '表格': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>', type: 'excel' },
        '课件': { svg: '<svg viewBox="0 0 24 24"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>', type: 'ware' },
        '绘图': { svg: '<svg viewBox="0 0 24 24"><path d="M12 19l7-7 3 3-7 7-3-3z"/><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"/><path d="M2 2l7.586 7.586"/><circle cx="11" cy="11" r="2"/></svg>', type: 'draw' },
        '主题': { svg: '<svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>', type: 'code' },
        '网页': { svg: '<svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>', type: 'html' },
        '仓库': { svg: '<svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>', type: 'code' },
        '代码': { svg: '<svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>', type: 'code' },
        '练习': { svg: '<svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>', type: 'survey' },
        '拼图': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', type: 'code' },
        '像素': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', type: 'code' }
    };
    
    // 查找所有表格
    var tables = document.getElementsByTagName('table');
    var gridView = null;
    
    // 找到包含GVlistmenu的表格
    for (var t = 0; t < tables.length; t++) {
        if (tables[t].id && tables[t].id.indexOf('GVlistmenu') !== -1) {
            gridView = tables[t];
            break;
        }
    }
    
    if (!gridView) {
        console.log('GridView table not found');
        return;
    }
    
    console.log('Found GridView table:', gridView.id);
    
    // 查找所有行
    var rows = gridView.getElementsByTagName('tr');
    console.log('Total rows:', rows.length);
    
    // 从第二行开始（跳过表头）
    for (var i = 1; i < rows.length; i++) {
        var cells = rows[i].getElementsByTagName('td');
        
        if (cells.length === 0) continue;
        
        console.log('Row ' + i + ' has ' + cells.length + ' cells');
        
        // 遍历所有单元格，找到包含类型信息的单元格
        for (var j = 0; j < cells.length; j++) {
            var cell = cells[j];
            var cellText = (cell.textContent || cell.innerText || '').trim();
            
            // 检查是否匹配任何图标类型
            if (cellText && iconMap[cellText]) {
                console.log('Found match in row ' + i + ', cell ' + j + ': "' + cellText + '"');
                
                var iconData = iconMap[cellText];
                
                // 创建新的图标容器
                var iconWrapper = document.createElement('div');
                iconWrapper.className = 'cs-activity-icon type-' + iconData.type;
                iconWrapper.innerHTML = iconData.svg + '<span>' + cellText + '</span>';
                
                // 替换原有内容
                cell.innerHTML = '';
                cell.appendChild(iconWrapper);
                break; // 找到后跳出单元格循环
            }
        }
    }
    
    console.log('Icon replacement completed');
}

function enhanceListActionLinks() {
    var gridView = document.getElementById('<%= GVlistmenu.ClientID %>');
    if (!gridView) {
        return;
    }

    var showLinks = gridView.querySelectorAll("a[id*='LinkBtnShow']");
    for (var i = 0; i < showLinks.length; i++) {
        var link = showLinks[i];
        var rawText = (link.textContent || link.innerText || '').replace(/\s+/g, '').toLowerCase();
        var isOn = rawText === 'true' || rawText === '1' || rawText === '已启用' || rawText === '启用' || rawText === '显示';
        link.classList.add('cs-publish-link');
        link.classList.toggle('is-on', isOn);
        link.classList.toggle('is-off', !isOn);
        link.setAttribute('data-action-kind', 'toggle');
        link.setAttribute('data-next-state', isOn ? 'off' : 'on');
        link.setAttribute('data-action-label', isOn ? '停用' : '启用');
        link.setAttribute('title', isOn ? '当前已启用，点击后将隐藏此栏目' : '当前未启用，点击后将显示此栏目');
        link.innerHTML = '<span class="cs-switch-core"><span class="cs-switch-thumb"></span></span><span class="cs-switch-text">' + (isOn ? '已启用' : '未启用') + '</span>';
    }

    var deleteLinks = gridView.querySelectorAll("a[id*='LinkBtnDel']");
    for (var j = 0; j < deleteLinks.length; j++) {
        var delLink = deleteLinks[j];
        delLink.classList.add('cs-delete-link');
        delLink.setAttribute('data-action-kind', 'delete');
        delLink.setAttribute('data-action-label', '删除');
    }
}

function initActionDialog() {
    var modal = document.getElementById('csActionModal');
    var titleEl = document.getElementById('csModalTitle');
    var messageEl = document.getElementById('csModalMessage');
    var btnCancel = document.getElementById('csModalCancel');
    var btnConfirm = document.getElementById('csModalConfirm');
    if (!modal || !titleEl || !messageEl || !btnCancel || !btnConfirm) {
        return;
    }

    var pendingLink = null;
    var bypassConfirm = false;

    function closeDialog() {
        modal.classList.remove('is-open');
        modal.setAttribute('aria-hidden', 'true');
        pendingLink = null;
    }

    function submitOriginalLink(link) {
        if (!link) return;
        var href = link.getAttribute('href') || '';
        bypassConfirm = true;
        try {
            if (href.indexOf('javascript:') === 0) {
                eval(href.substring('javascript:'.length));
            } else {
                link.click();
            }
        } finally {
            setTimeout(function () { bypassConfirm = false; }, 0);
        }
    }

    document.addEventListener('click', function (evt) {
        var link = evt.target.closest(".cs-gv-wrap a[id*='LinkBtnShow'], .cs-gv-wrap a[id*='LinkBtnDel']");
        if (!link || bypassConfirm) {
            return;
        }

        evt.preventDefault();

        var row = link.closest('tr');
        var titleLink = row ? row.querySelector("a[id*='HlLtitle']") : null;
        var titleCell = row && row.cells.length > 2 ? row.cells[2] : null;
        var itemName = titleLink
            ? (titleLink.textContent || titleLink.innerText || '').replace(/\s+/g, ' ').trim()
            : (titleCell ? (titleCell.textContent || titleCell.innerText || '').replace(/\s+/g, ' ').trim() : '当前栏目');
        var actionKind = link.getAttribute('data-action-kind') || '';

        if (actionKind === 'toggle') {
            var isOn = link.classList.contains('is-on');
            titleEl.textContent = isOn ? '确认停用栏目' : '确认启用栏目';
            messageEl.textContent = '将要' + (isOn ? '停用' : '启用') + '“' + itemName + '”。操作后学生端将' + (isOn ? '不再显示此栏目。' : '恢复显示此栏目。');
        } else {
            titleEl.textContent = '确认删除栏目';
            messageEl.textContent = '将永久删除“' + itemName + '”，此操作不可恢复。请确认后再继续。';
        }

        pendingLink = link;
        modal.classList.add('is-open');
        modal.setAttribute('aria-hidden', 'false');
    });

    btnCancel.addEventListener('click', closeDialog);
    modal.addEventListener('click', function (evt) {
        if (evt.target === modal) {
            closeDialog();
        }
    });
    btnConfirm.addEventListener('click', function () {
        var link = pendingLink;
        closeDialog();
        submitOriginalLink(link);
    });
    document.addEventListener('keydown', function (evt) {
        if (evt.key === 'Escape' && modal.classList.contains('is-open')) {
            closeDialog();
        }
    });
}

// 多种方式确保代码执行
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
        replaceActivityIcons();
        enhanceListActionLinks();
        initActionDialog();
    });
} else {
    replaceActivityIcons();
    enhanceListActionLinks();
    initActionDialog();
}

// 备用：延迟执行
setTimeout(function () {
    replaceActivityIcons();
    enhanceListActionLinks();
}, 500);
setTimeout(function () {
    replaceActivityIcons();
    enhanceListActionLinks();
}, 1000);
</script>
</asp:Content>

