<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Quiz_quiz, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== Quiz Page ===== */
    .qz { width: 100%; margin: 0 auto; font-size: 13px; color: #334155; }
    .qz *, .qz *::before, .qz *::after { box-sizing: border-box; }

    /* ===== Toolbar ===== */
    .qz-toolbar {
        display: flex; align-items: center; flex-wrap: wrap; gap: 10px;
        padding: 18px 24px;
        background: linear-gradient(135deg, #6366f1 0%, #7c3aed 50%, #8b5cf6 100%);
        border-radius: 16px; margin-bottom: 20px;
        box-shadow: 0 4px 24px rgba(99,102,241,0.25), inset 0 1px 0 rgba(255,255,255,0.12);
        position: relative; overflow: hidden;
    }
    .qz-toolbar::before {
        content: ''; position: absolute; top: -60%; right: -8%; width: 280px; height: 280px;
        background: radial-gradient(circle, rgba(255,255,255,0.10) 0%, transparent 70%);
        pointer-events: none;
    }
    .qz-toolbar::after {
        content: ''; position: absolute; bottom: -50%; left: 10%; width: 180px; height: 180px;
        background: radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%);
        pointer-events: none;
    }
    .qz-toolbar .qz-tb-label {
        font-size: 15px; font-weight: 700; color: #fff;
        display: flex; align-items: center; gap: 8px; position: relative;
    }
    .qz-toolbar .qz-tb-label svg {
        width: 22px; height: 22px; stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .qz-toolbar select {
        height: 36px !important; border-radius: 10px !important;
        border: 1px solid rgba(255,255,255,0.3) !important;
        background: rgba(255,255,255,0.92) !important; color: #312e81 !important;
        font-size: 12.5px !important; font-weight: 500 !important;
        padding: 0 12px !important; outline: none !important;
        box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        transition: all 0.2s;
    }
    .qz-toolbar select:focus {
        border-color: rgba(255,255,255,0.7) !important;
        box-shadow: 0 0 0 3px rgba(255,255,255,0.2), 0 2px 6px rgba(0,0,0,0.1);
    }
    .qz-toolbar input[type="submit"] {
        height: 36px !important; border-radius: 10px !important;
        border: 1px solid rgba(255,255,255,0.25) !important;
        background: rgba(255,255,255,0.15) !important; color: #fff !important;
        font-size: 12.5px !important; font-weight: 600 !important;
        padding: 0 20px !important; cursor: pointer;
        transition: all 0.2s !important; white-space: nowrap;
        backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
    }
    .qz-toolbar input[type="submit"]:hover {
        background: rgba(255,255,255,0.30) !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    .qz-toolbar .qz-btn-add {
        background: rgba(255,255,255,0.95) !important; color: #6366f1 !important;
        font-weight: 700 !important; border: none !important;
        box-shadow: 0 2px 8px rgba(0,0,0,0.12);
    }
    .qz-toolbar .qz-btn-add:hover {
        background: #fff !important;
        box-shadow: 0 4px 16px rgba(0,0,0,0.18);
    }
    .qz-toolbar .qz-tb-info {
        font-size: 12px; color: rgba(255,255,255,0.85); font-weight: 500;
    }
    .qz-tb-sep { width: 1px; height: 28px; background: rgba(255,255,255,0.20); margin: 0 6px; flex-shrink: 0; }
    .qz-tb-spacer { flex: 1; min-width: 10px; }
    .qz-toolbar .qz-help-toggle {
        display: inline-flex; align-items: center; justify-content: center;
        width: 36px; height: 36px; border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.25); background: rgba(255,255,255,0.12);
        cursor: pointer; transition: all 0.2s; position: relative; color: #fff;
    }
    .qz-toolbar .qz-help-toggle:hover { background: rgba(255,255,255,0.28); }
    .qz-toolbar .qz-help-toggle svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* ===== Help / Guide Panel ===== */
    .qz-guide {
        background: #fff; border-radius: 16px; border: 1px solid #e0e7ff;
        margin-bottom: 20px; overflow: hidden;
        box-shadow: 0 1px 4px rgba(99,102,241,0.06), 0 4px 16px rgba(99,102,241,0.04);
        max-height: 800px; opacity: 1;
        transition: max-height 0.4s ease, opacity 0.3s ease, margin 0.3s ease;
    }
    .qz-guide.closed {
        max-height: 0; opacity: 0; margin-top: -10px; margin-bottom: 0;
        border-color: transparent;
    }
    .qz-guide-head {
        display: flex; align-items: center; gap: 10px;
        padding: 16px 22px; border-bottom: 1px solid #eef2ff;
        background: linear-gradient(135deg, #eef2ff 0%, #f5f3ff 100%);
    }
    .qz-guide-head .qz-guide-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        background: linear-gradient(135deg, #6366f1, #8b5cf6); flex-shrink: 0;
    }
    .qz-guide-head .qz-guide-icon svg {
        width: 20px; height: 20px; stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .qz-guide-head-text {
        font-size: 15px; font-weight: 700; color: #312e81;
    }
    .qz-guide-head-sub {
        font-size: 12px; color: #818cf8; font-weight: 500;
    }
    .qz-guide-head .qz-guide-close {
        margin-left: auto; width: 30px; height: 30px; border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        cursor: pointer; border: none; background: rgba(99,102,241,0.08);
        color: #6366f1; transition: all 0.15s;
    }
    .qz-guide-head .qz-guide-close:hover { background: rgba(99,102,241,0.16); }
    .qz-guide-head .qz-guide-close svg { width: 16px; height: 16px; stroke: #6366f1; fill: none; stroke-width: 2.5; stroke-linecap: round; }
    .qz-guide-body { padding: 20px 22px; }
    .qz-guide-grid {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px;
    }
    .qz-guide-item {
        display: flex; gap: 14px; padding: 16px; border-radius: 12px;
        background: #f8fafc; border: 1px solid #f1f5f9;
        transition: all 0.2s;
    }
    .qz-guide-item:hover { background: #eef2ff; border-color: #e0e7ff; transform: translateY(-1px); }
    .qz-guide-step {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        color: #fff; font-size: 14px; font-weight: 700;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .qz-guide-item-title { font-size: 13.5px; font-weight: 600; color: #1e293b; margin-bottom: 4px; }
    .qz-guide-item-desc { font-size: 12px; color: #64748b; line-height: 1.6; }
    .qz-guide-tips {
        margin-top: 18px; padding: 14px 18px; border-radius: 10px;
        background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
        border: 1px solid #fde68a;
        display: flex; align-items: flex-start; gap: 10px;
    }
    .qz-guide-tips .qz-tip-icon {
        width: 24px; height: 24px; flex-shrink: 0;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px;
    }
    .qz-guide-tips-text { font-size: 12px; color: #92400e; line-height: 1.7; }
    .qz-guide-tips-text strong { color: #78350f; }

    /* ===== Card ===== */
    .qz-card {
        background: #fff; border-radius: 16px; border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.03);
        margin-bottom: 20px; overflow: hidden;
        transition: box-shadow 0.3s;
    }
    .qz-card:hover { box-shadow: 0 2px 6px rgba(0,0,0,0.06), 0 8px 24px rgba(0,0,0,0.04); }
    .qz-card-head {
        display: flex; align-items: center; gap: 10px;
        padding: 16px 22px; border-bottom: 1px solid #f1f5f9;
        font-size: 14.5px; font-weight: 600; color: #1e293b;
    }
    .qz-card-head .qz-icon {
        width: 34px; height: 34px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    }
    .qz-card-head .qz-icon svg {
        width: 18px; height: 18px; fill: none; stroke: #6366f1;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .qz-card-head .qz-card-count {
        margin-left: auto; font-size: 12px; font-weight: 500;
        color: #94a3b8; background: #f1f5f9; padding: 4px 12px;
        border-radius: 20px;
    }
    .qz-card-body { padding: 0; }

    /* ===== GridView Table ===== */
    .qz-card-body table { width: 100% !important; border-collapse: collapse; }
    .qz-card-body table th {
        background: #f8fafc !important; color: #475569 !important;
        font-size: 12px !important; font-weight: 600 !important;
        padding: 13px 16px !important; text-align: left !important;
        border-bottom: 2px solid #e2e8f0 !important;
        white-space: nowrap; letter-spacing: 0.3px;
    }
    .qz-card-body table td {
        padding: 12px 16px !important; font-size: 13px !important;
        color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important;
        vertical-align: middle !important;
        transition: background 0.15s;
    }
    .qz-card-body table tr { transition: background 0.15s; }
    .qz-card-body table tr:hover td { background: #fafbff !important; }
    .qz-card-body table tr:last-child td { border-bottom: none !important; }
    /* Alternating rows */
    .qz-card-body table tr[style*="background-color"] td { background: #fafbfd !important; }
    .qz-card-body table tr[style*="background-color"]:hover td { background: #f0f1ff !important; }
    /* Edit link */
    .qz-card-body table td a {
        color: #6366f1; text-decoration: none; font-weight: 600;
        font-size: 12px; padding: 3px 10px; border-radius: 6px;
        background: #eef2ff; transition: all 0.15s;
        display: inline-block;
    }
    .qz-card-body table td a:hover {
        color: #fff; background: #6366f1; text-decoration: none;
        box-shadow: 0 2px 8px rgba(99,102,241,0.3);
    }
    /* Delete button */
    .qz-card-body table td input[type="submit"] {
        background: #fef2f2 !important; border: 1px solid #fecaca !important;
        color: #dc2626 !important; font-size: 12px !important;
        cursor: pointer; padding: 3px 10px !important;
        border-radius: 6px !important; transition: all 0.15s;
        font-weight: 500 !important;
    }
    .qz-card-body table td input[type="submit"]:hover {
        background: #fee2e2 !important; border-color: #fca5a5 !important;
        box-shadow: 0 2px 8px rgba(239,68,68,0.2);
    }
    /* Question column */
    .qz-question-cell {
        max-width: 520px;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        line-height: 1.8; font-size: 13px;
    }
    .qz-question-cell img,
    .qz-question-cell svg,
    .qz-question-cell object,
    .qz-question-cell embed {
        max-height: 22px !important; max-width: 22px !important;
        width: auto !important; height: auto !important;
        object-fit: contain !important; vertical-align: text-bottom;
        border: none !important; padding: 0 !important;
        background: transparent !important; box-shadow: none !important;
        border-radius: 3px; margin: 0 1px;
    }
    .qz-question-cell p {
        margin: 0 !important; display: inline;
    }
    .qz-question-cell br {
        display: none;
    }
    /* Analyze tooltip label */
    .qz-card-body table td span[title] {
        cursor: help; border-bottom: 1px dashed #cbd5e1;
        transition: border-color 0.15s;
    }
    .qz-card-body table td span[title]:hover { border-color: #6366f1; color: #6366f1 !important; }

    /* ===== Pager ===== */
    .qz-card-body table tr:last-child td[colspan] { background: #f8fafc !important; border-bottom: none !important; }
    .qz-pager {
        display: flex; align-items: center; justify-content: flex-end;
        gap: 8px; padding: 12px 16px; font-size: 12px; color: #64748b;
    }
    .qz-pager a {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 6px 14px; border-radius: 8px; font-size: 12px;
        color: #475569 !important; text-decoration: none !important;
        background: #fff; border: 1px solid #e2e8f0;
        transition: all 0.2s; font-weight: 500;
        box-shadow: 0 1px 2px rgba(0,0,0,0.04);
    }
    .qz-pager a:hover {
        background: #eef2ff; color: #4f46e5 !important; border-color: #c7d2fe;
        transform: translateY(-1px); box-shadow: 0 2px 6px rgba(99,102,241,0.12);
    }
    .qz-pager .qz-page-info {
        font-size: 12px; color: #94a3b8; margin-right: 8px;
        background: #f1f5f9; padding: 5px 12px; border-radius: 6px;
    }

    /* ===== Bottom Action Bar ===== */
    .qz-actions {
        display: flex; align-items: center; flex-wrap: wrap; gap: 14px;
        padding: 18px 22px;
        background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        border-radius: 16px; border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    }
    .qz-actions .qz-act-group {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 16px; background: #fff; border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        transition: all 0.2s;
    }
    .qz-actions .qz-act-group:hover { border-color: #c7d2fe; box-shadow: 0 2px 8px rgba(99,102,241,0.08); }
    .qz-actions .qz-act-icon {
        width: 28px; height: 28px; border-radius: 8px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .qz-actions .qz-act-icon svg {
        width: 15px; height: 15px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .qz-act-export .qz-act-icon { background: #ecfdf5; }
    .qz-act-export .qz-act-icon svg { stroke: #059669; }
    .qz-act-import .qz-act-icon { background: #eff6ff; }
    .qz-act-import .qz-act-icon svg { stroke: #2563eb; }
    .qz-actions .qz-act-group-title {
        font-size: 12px; font-weight: 600; color: #64748b;
        margin-right: 2px; white-space: nowrap;
    }
    .qz-actions a {
        color: #6366f1 !important; text-decoration: none !important;
        font-size: 12.5px !important; font-weight: 500;
        padding: 4px 10px; border-radius: 6px;
        transition: all 0.15s;
    }
    .qz-actions a:hover { color: #4f46e5 !important; background: #eef2ff; }
    .qz-actions input[type="submit"] {
        height: 36px !important; border-radius: 10px !important;
        border: 1px solid #e2e8f0 !important;
        background: #fff !important; color: #475569 !important;
        font-size: 12.5px !important; font-weight: 500 !important;
        padding: 0 18px !important; cursor: pointer;
        transition: all 0.2s !important;
        box-shadow: 0 1px 2px rgba(0,0,0,0.04);
    }
    .qz-actions input[type="submit"]:hover {
        background: #eef2ff !important; border-color: #c7d2fe !important;
        color: #4f46e5 !important; transform: translateY(-1px);
        box-shadow: 0 2px 8px rgba(99,102,241,0.12);
    }
    .qz-actions input[type="file"] {
        font-size: 12px !important; color: #64748b;
        max-width: 220px;
    }
    .qz-actions .qz-msg {
        font-size: 12px; color: #ef4444; font-weight: 500;
        padding: 4px 12px; background: #fef2f2; border-radius: 6px; border: 1px solid #fecaca;
    }
    /* Hide empty Labelmsg */
    .qz-actions .qz-msg:empty { display: none; }
    .qz-actions span[id$="Labelmsg"]:empty { display: none; }
    /* Force button text visible in actions */
    .qz-actions input[type="submit"].txtcenter {
        line-height: 36px !important;
        width: auto !important;
        min-width: 120px;
        overflow: visible !important;
    }
    .qz-act-sep {
        width: 1px; height: 32px; background: linear-gradient(180deg, transparent, #e2e8f0, transparent);
        flex-shrink: 0;
    }

    /* ===== Animations ===== */
    @keyframes qzFadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .qz-toolbar { animation: qzFadeIn 0.4s ease; }
    .qz-card { animation: qzFadeIn 0.5s ease 0.1s both; }
    .qz-actions { animation: qzFadeIn 0.5s ease 0.2s both; }
</style>

<div class="qz">
    <!-- Toolbar -->
    <div class="qz-toolbar">
        <span class="qz-tb-label">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            试题管理
        </span>
        <span class="qz-tb-sep"></span>
        <asp:DropDownList ID="DDLqtype" runat="server" 
            Font-Size="9pt" ToolTip="题型">
            <asp:ListItem Selected="True" Value="0">单选题</asp:ListItem>
            <asp:ListItem Value="1">多选题</asp:ListItem>
            <asp:ListItem Value="2">判断题</asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="DDLclass" runat="server" Width="100px" 
            Font-Size="9pt" ToolTip="学案类型">
        </asp:DropDownList>
        <asp:Button ID="Btnlist" runat="server" Text="浏览" onclick="Btnlist_Click" SkinID="BtnNormal" />
        <span class="qz-tb-info"><asp:Label ID="Label1" runat="server"></asp:Label></span>
        <span class="qz-tb-spacer"></span>
        <asp:Button ID="Btnadd" runat="server" Text="+ 添加试题" onclick="Btnadd_Click" SkinID="BtnNormal" CssClass="qz-btn-add" />
        <asp:Button ID="Btngradeset" runat="server" Text="测验设置" onclick="Btngradeset_Click" SkinID="BtnNormal" />
        <button type="button" class="qz-help-toggle" onclick="toggleQuizGuide()" title="使用说明">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        </button>
    </div>

    <!-- Guide / Help Panel -->
    <div class="qz-guide" id="qzGuide">
        <div class="qz-guide-head">
            <span class="qz-guide-icon">
                <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
            </span>
            <div>
                <div class="qz-guide-head-text">试题管理 — 使用说明</div>
                <div class="qz-guide-head-sub">快速上手：创建、管理和分享测验试题</div>
            </div>
            <button type="button" class="qz-guide-close" onclick="toggleQuizGuide()" title="关闭">
                <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="qz-guide-body">
            <div class="qz-guide-grid">
                <div class="qz-guide-item">
                    <span class="qz-guide-step">1</span>
                    <div>
                        <div class="qz-guide-item-title">筛选题型与分类</div>
                        <div class="qz-guide-item-desc">在顶部工具栏中选择<strong>题型</strong>（单选/多选/判断）和<strong>学案类型</strong>，然后点击「浏览」按钮加载对应的试题列表。</div>
                    </div>
                </div>
                <div class="qz-guide-item">
                    <span class="qz-guide-step">2</span>
                    <div>
                        <div class="qz-guide-item-title">添加新试题</div>
                        <div class="qz-guide-item-desc">点击工具栏右侧的「<strong>+ 添加试题</strong>」按钮，进入试题编辑页面，填写题目内容、选项、答案和分值。</div>
                    </div>
                </div>
                <div class="qz-guide-item">
                    <span class="qz-guide-step">3</span>
                    <div>
                        <div class="qz-guide-item-title">编辑与删除</div>
                        <div class="qz-guide-item-desc">在试题列表中点击「<strong>编辑</strong>」链接可修改试题，点击「<strong>删除</strong>」按钮可移除试题。鼠标悬停「提示」可查看分析。</div>
                    </div>
                </div>
                <div class="qz-guide-item">
                    <span class="qz-guide-step">4</span>
                    <div>
                        <div class="qz-guide-item-title">测验设置</div>
                        <div class="qz-guide-item-desc">点击「<strong>测验设置</strong>」按钮，可配置测验的年级、班级范围等参数，设置完成后学生即可在线答题。</div>
                    </div>
                </div>
                <div class="qz-guide-item">
                    <span class="qz-guide-step">5</span>
                    <div>
                        <div class="qz-guide-item-title">导出试题包</div>
                        <div class="qz-guide-item-desc">在底部操作区点击「<strong>生成试题包</strong>」将当前试题导出为 XML 文件，点击「试题包下载」链接可下载已生成的文件。</div>
                    </div>
                </div>
                <div class="qz-guide-item">
                    <span class="qz-guide-step">6</span>
                    <div>
                        <div class="qz-guide-item-title">导入试题包</div>
                        <div class="qz-guide-item-desc">选择本地的试题包 XML 文件，点击「<strong>导入试题包</strong>」即可批量导入试题，方便在不同系统间迁移。</div>
                    </div>
                </div>
            </div>
            <div class="qz-guide-tips">
                <span class="qz-tip-icon">💡</span>
                <div class="qz-guide-tips-text">
                    <strong>小贴士：</strong>每道试题都有<strong>正确率</strong>统计，可帮助您了解学生的掌握情况，针对性地调整教学内容。
                    试题包支持跨系统导入导出，建议定期备份重要试题。
                </div>
            </div>
        </div>
    </div>

    <!-- Quiz Table Card -->
    <div class="qz-card">
        <div class="qz-card-head">
            <span class="qz-icon">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            </span>
            试题列表
        </div>
        <div class="qz-card-body">
            <asp:GridView ID="GVQuiz" runat="server" AllowPaging="True" SkinID="GridViewInfo"
                AutoGenerateColumns="False" DataKeyNames="Qid" Width="100%"
                onpageindexchanging="GVQuiz_PageIndexChanging"
                onrowdatabound="GVQuiz_RowDataBound" onrowcommand="GVQuiz_RowCommand"
                TabIndex="1" CellPadding="3" GridLines="None"
                EnableModelValidation="True" HorizontalAlign="Center">
                <Columns>
                    <asp:BoundField HeaderText="序号" HeaderStyle-Width="50px">
                        <HeaderStyle Width="50px"></HeaderStyle>
                    </asp:BoundField>
                    <asp:HyperLinkField DataNavigateUrlFields="Qid" DataNavigateUrlFormatString="~/quiz/quizedit.aspx?Qid={0}"
                        Text="编辑">
                        <ItemStyle Width="60px" />
                    </asp:HyperLinkField>
                    <asp:TemplateField HeaderText="试题">
                        <ItemTemplate>
                            <div class="qz-question-cell">
                                <asp:Label ID="Labelquestion" runat="server" Text='<%# HttpUtility.HtmlDecode(DataBinder.Eval(Container.DataItem,"Question").ToString()) %>'></asp:Label>
                            </div>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="Qclass" HeaderText="类型" />
                    <asp:BoundField DataField="Qscore" HeaderText="分值" />
                    <asp:BoundField DataField="Qanswer" HeaderText="答案" />
                    <asp:TemplateField HeaderText="分析">
                        <ItemTemplate>
                            <asp:Label ID="Labelqanalyze" runat="server" Text='提示' ToolTip='<%# Bind("Qanalyze") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Qaccuracy" HeaderText="正确率" />
                    <asp:ButtonField Text="删除" CommandName="Del">
                        <ItemStyle Width="60px" />
                    </asp:ButtonField>
                </Columns>
                <PagerTemplate>
                    <div class="qz-pager">
                        <span class="qz-page-info">
                            第 <asp:Label ID="lblPageIndex" runat="server"
                                text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1  %>" />
                            页 / 共 <asp:Label ID="lblPageCount" runat="server"
                                text="<%# ((GridView)Container.Parent.Parent).PageCount  %>" />
                            页
                        </span>
                        <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False"
                            commandargument="First" commandname="Page" Font-Underline="False"
                            text="首页" />
                        <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False"
                            commandargument="Prev" commandname="Page" Font-Underline="False"
                            text="上一页" />
                        <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False"
                            commandargument="Next" commandname="Page" Font-Underline="False"
                            text="下一页" />
                        <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False"
                            commandargument="Last" commandname="Page" Font-Underline="False"
                            text="尾页" />
                    </div>
                </PagerTemplate>
            </asp:GridView>
        </div>
    </div>

    <!-- Bottom Actions -->
    <div class="qz-actions">
        <div class="qz-act-group qz-act-export">
            <span class="qz-act-icon">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            </span>
            <span class="qz-act-group-title">导出</span>
            <asp:Button ID="Btnexport" runat="server" Text="生成试题包"
                SkinID="BtnLong" TabIndex="2" onclick="Btnexport_Click" />
            <asp:HyperLink ID="HlkQuizxml" runat="server" Font-Size="9pt">试题包下载</asp:HyperLink>
        </div>
        <span class="qz-act-sep"></span>
        <div class="qz-act-group qz-act-import">
            <span class="qz-act-icon">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            </span>
            <span class="qz-act-group-title">导入</span>
            <asp:FileUpload ID="FileUploadquiz" runat="server" Font-Size="9pt" />
            <asp:Button ID="Btnimport" runat="server" Text="导入试题包" onclick="Btnimport_Click"
                SkinID="BtnLong" TabIndex="2" />
        </div>
        <asp:Label ID="Labelmsg" runat="server" Font-Size="9pt" CssClass="qz-msg" ForeColor="Red"></asp:Label>
    </div>
</div>

<script type="text/javascript">
    function toggleQuizGuide() {
        var el = document.getElementById('qzGuide');
        if (el) {
            el.classList.toggle('closed');
            try { localStorage.setItem('qzGuideClosed', el.classList.contains('closed') ? '1' : '0'); } catch(e){}
        }
    }
    // Restore guide state: default OPEN, only close if user explicitly closed
    (function(){
        try {
            if (localStorage.getItem('qzGuideClosed') === '1') {
                var el = document.getElementById('qzGuide');
                if (el) el.classList.add('closed');
            }
        } catch(e){}
    })();
</script>
</asp:Content>

