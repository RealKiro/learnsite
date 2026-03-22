<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" CodeFile="coursetemplate.aspx.cs" Inherits="LearnSite.Teacher_coursetemplate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .tpl-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .tpl-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .tpl-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .tpl-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .tpl-title .tpl-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .tpl-title .tpl-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tpl-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    /* 卡片 */
    .tpl-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .tpl-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .tpl-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .tpl-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tpl-card-body { padding: 24px; }

    /* Tab切换 */
    .tpl-tabs { display: flex; gap: 0; margin-bottom: 0; }
    .tpl-tab {
        padding: 12px 24px; font-size: 14px; font-weight: 500; color: #64748b;
        cursor: pointer; border-bottom: 2px solid transparent; transition: all 0.2s;
        background: none; border: none; border-bottom: 2px solid transparent;
        font-family: inherit;
    }
    .tpl-tab:hover { color: #4f46e5; }
    .tpl-tab.active { color: #4f46e5; border-bottom-color: #6366f1; font-weight: 600; }
    .tpl-tab-content { display: none; }
    .tpl-tab-content.active { display: block; }

    /* 表单 */
    .tpl-form-group { margin-bottom: 16px; }
    .tpl-form-group label {
        display: block; font-size: 13px; font-weight: 600; color: #374151;
        margin-bottom: 8px;
    }
    .tpl-form-group input[type="text"] {
        width: 100%; height: 42px; padding: 0 14px; font-size: 14px; color: #1e293b;
        background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 10px;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        font-family: inherit; box-sizing: border-box;
    }
    .tpl-form-group input[type="text"]:focus {
        border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); background: #fff;
    }
    .tpl-form-group textarea {
        width: 100%; min-height: 300px; padding: 14px; font-size: 13px; color: #1e293b;
        background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 10px;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        font-family: 'Consolas', 'Microsoft YaHei', monospace; box-sizing: border-box;
        resize: vertical; line-height: 1.6;
    }
    .tpl-form-group textarea:focus {
        border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); background: #fff;
    }
    .tpl-upload-area {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 16px 20px; background: #f8fafc; border: 1px dashed #d1d5db;
        border-radius: 10px;
    }

    /* 按钮 */
    .tpl-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 10px 24px; border-radius: 8px; font-size: 14px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .tpl-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .tpl-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8) !important; color: #fff !important;
        border-color: #6366f1 !important; box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .tpl-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1) !important; border-color: #4f46e5 !important; box-shadow: 0 4px 12px rgba(99,102,241,.3) !important; }

    /* 消息 */
    .tpl-msg { font-size: 13px; margin-top: 12px; display: block; min-height: 20px; }

    /* 模板列表 */
    .tpl-table { width: 100%; border-collapse: collapse; }
    .tpl-table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        padding: 12px 16px; border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .tpl-table td {
        padding: 12px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
    }
    .tpl-table tr:hover td { background: #f8fafc; }

    /* 徽章 */
    .tpl-badge {
        display: inline-flex; align-items: center; padding: 3px 10px;
        border-radius: 6px; font-size: 12px; font-weight: 500;
    }
    .tpl-badge-builtin { background: #dbeafe; color: #1d4ed8; }
    .tpl-badge-create { background: #dcfce7; color: #15803d; }
    .tpl-badge-upload { background: #fef3c7; color: #b45309; }
    .tpl-badge-other { background: #f1f5f9; color: #64748b; }

    /* 操作按钮 */
    .tpl-action-link {
        display: inline-flex; align-items: center; gap: 4px;
        font-size: 12px; color: #6366f1; text-decoration: none; font-weight: 500;
        padding: 4px 10px; border-radius: 6px; transition: all .15s;
        background: none; border: none; cursor: pointer; font-family: inherit;
    }
    .tpl-action-link:hover { background: #eef2ff; color: #4f46e5; }
    .tpl-delete-btn {
        background: none; border: none; cursor: pointer;
        display: inline-flex; align-items: center; gap: 4px;
        font-size: 12px; color: #ef4444; font-weight: 500;
        padding: 4px 10px; border-radius: 6px; transition: all .15s;
        font-family: inherit;
    }
    .tpl-delete-btn:hover { background: #fef2f2; color: #dc2626; }

    .tpl-count { font-size: 13px; color: #94a3b8; }

    /* 预览弹窗 - 使用视口单位确保不受父容器影响 */
    .tpl-preview-overlay {
        display: none !important;
        position: fixed !important;
        top: 0 !important; left: 0 !important;
        width: 100vw !important; height: 100vh !important;
        right: auto !important; bottom: auto !important;
        background: rgba(15,23,42,0.55) !important;
        backdrop-filter: blur(4px) !important;
        -webkit-backdrop-filter: blur(4px) !important;
        z-index: 10000 !important;
        justify-content: center !important;
        align-items: center !important;
        margin: 0 !important; padding: 0 !important;
        overflow: auto !important;
        opacity: 0;
        transition: opacity 0.25s ease !important;
    }
    .tpl-preview-overlay.show { display: flex !important; opacity: 1; }
    @keyframes previewSlideIn {
        from { transform: translateY(30px) scale(0.97); opacity: 0; }
        to   { transform: translateY(0) scale(1); opacity: 1; }
    }
    .tpl-preview-box {
        background: #fff !important;
        border-radius: 20px !important;
        width: 80vw !important;
        max-width: 860px !important;
        min-width: 320px !important;
        max-height: 82vh !important;
        overflow: hidden !important;
        display: flex !important;
        flex-direction: column !important;
        box-shadow: 0 25px 60px rgba(15,23,42,0.22), 0 8px 24px rgba(15,23,42,0.1), 0 0 0 1px rgba(15,23,42,0.05) !important;
        margin: auto !important;
        flex-shrink: 0 !important;
        animation: previewSlideIn 0.3s ease-out !important;
    }
    .tpl-preview-header {
        padding: 20px 28px !important;
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: space-between !important;
        flex-shrink: 0 !important;
        width: 100% !important;
        box-sizing: border-box !important;
        border-bottom: none !important;
        position: relative !important;
    }
    .tpl-preview-header::after {
        content: '' !important;
        position: absolute !important;
        bottom: 0 !important; left: 0 !important; right: 0 !important;
        height: 3px !important;
        background: linear-gradient(90deg, #c7d2fe, #a5b4fc, #c7d2fe) !important;
    }
    .tpl-preview-header h3 {
        margin: 0 !important; font-size: 17px !important; color: #fff !important;
        white-space: normal !important; word-break: normal !important;
        font-weight: 600 !important; letter-spacing: 0.3px !important;
        display: flex !important; align-items: center !important; gap: 10px !important;
    }
    .tpl-preview-header h3::before {
        content: '\1F4C4' !important;
        font-size: 20px !important;
    }
    .tpl-preview-close {
        width: 34px !important; height: 34px !important; min-width: 34px !important;
        border: 2px solid rgba(255,255,255,0.3) !important;
        background: rgba(255,255,255,0.15) !important;
        border-radius: 10px !important; cursor: pointer !important;
        font-size: 18px !important; color: #fff !important;
        display: flex !important; align-items: center !important; justify-content: center !important;
        transition: all 0.2s !important; flex-shrink: 0 !important;
        backdrop-filter: blur(8px) !important;
    }
    .tpl-preview-close:hover {
        background: rgba(255,255,255,0.3) !important;
        border-color: rgba(255,255,255,0.5) !important;
        transform: rotate(90deg) !important;
    }
    .tpl-preview-body {
        padding: 32px 36px !important;
        overflow-y: auto !important;
        flex: 1 1 auto !important;
        font-size: 14.5px !important;
        line-height: 1.9 !important;
        color: #334155 !important;
        width: 100% !important;
        box-sizing: border-box !important;
        white-space: normal !important;
        word-break: normal !important;
        word-wrap: break-word !important;
        background: linear-gradient(180deg, #fafbff 0%, #fff 80px) !important;
    }
    /* 自定义滚动条 */
    .tpl-preview-body::-webkit-scrollbar { width: 6px !important; }
    .tpl-preview-body::-webkit-scrollbar-track { background: transparent !important; }
    .tpl-preview-body::-webkit-scrollbar-thumb {
        background: #c7d2fe !important; border-radius: 3px !important;
    }
    .tpl-preview-body::-webkit-scrollbar-thumb:hover { background: #a5b4fc !important; }
    /* 内容排版 */
    .tpl-preview-body h2, .tpl-preview-body h3, .tpl-preview-body h4 {
        color: #1e293b !important; position: relative !important;
    }
    .tpl-preview-body h2 {
        font-size: 20px !important; margin: 24px 0 12px !important;
        padding-bottom: 10px !important;
        border-bottom: 2px solid #e0e7ff !important;
    }
    .tpl-preview-body h3 {
        font-size: 16px !important; margin: 20px 0 8px !important;
        padding-left: 12px !important;
        border-left: 3px solid #818cf8 !important;
    }
    .tpl-preview-body h4 {
        font-size: 14.5px !important; margin: 16px 0 6px !important;
        color: #475569 !important;
    }
    .tpl-preview-body p {
        margin: 8px 0 !important;
        white-space: normal !important; word-break: normal !important;
    }
    .tpl-preview-body ol, .tpl-preview-body ul {
        padding-left: 24px !important; margin: 8px 0 !important;
    }
    .tpl-preview-body li {
        margin: 4px 0 !important;
        white-space: normal !important; word-break: normal !important;
    }
    .tpl-preview-body strong, .tpl-preview-body b {
        color: #1e293b !important; font-weight: 600 !important;
    }
    .tpl-preview-body hr {
        border: none !important; height: 2px !important;
        background: linear-gradient(90deg, #e0e7ff, #c7d2fe, #e0e7ff) !important;
        margin: 16px 0 !important;
    }
    .tpl-preview-body table {
        width: 100% !important; border-collapse: collapse !important; margin: 12px 0 !important;
        border: 1px solid #e2e8f0 !important; border-radius: 8px !important;
        overflow: hidden !important;
    }
    .tpl-preview-body th {
        background: #f1f5f9 !important; font-weight: 600 !important;
        padding: 10px 14px !important; text-align: left !important;
        border: 1px solid #e2e8f0 !important; font-size: 13px !important;
        white-space: normal !important; word-break: normal !important;
    }
    .tpl-preview-body td {
        padding: 10px 14px !important; border: 1px solid #e2e8f0 !important;
        font-size: 13.5px !important;
        white-space: normal !important; word-break: normal !important;
    }
    /* 底部关闭栏 */
    .tpl-preview-footer {
        padding: 14px 28px !important;
        border-top: 1px solid #f1f5f9 !important;
        display: flex !important;
        justify-content: flex-end !important;
        flex-shrink: 0 !important;
        background: #fafbff !important;
        width: 100% !important;
        box-sizing: border-box !important;
    }
    .tpl-preview-footer-btn {
        padding: 8px 24px !important; border-radius: 8px !important;
        border: 1px solid #e2e8f0 !important; background: #fff !important;
        color: #475569 !important; font-size: 13px !important; font-weight: 500 !important;
        cursor: pointer !important; transition: all 0.18s !important;
        font-family: inherit !important;
    }
    .tpl-preview-footer-btn:hover {
        background: #f1f5f9 !important; border-color: #cbd5e1 !important;
        color: #1e293b !important;
    }

    .tpl-hint {
        font-size: 12px; color: #94a3b8; margin-top: 6px;
    }

    /* AI 生成 */
    .ai-tpl-btn {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 24px; border: none; border-radius: 10px;
        background: linear-gradient(135deg, #8b5cf6, #6366f1);
        color: #fff; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: all 0.2s; font-family: inherit;
        box-shadow: 0 2px 8px rgba(99,102,241,0.25);
    }
    .ai-tpl-btn:hover { box-shadow: 0 4px 16px rgba(99,102,241,0.4); transform: translateY(-1px); }
    .ai-tpl-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
    .ai-tpl-btn svg {
        width: 18px; height: 18px; fill: none; stroke: currentColor;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .ai-tpl-type-row { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 16px; }
    .ai-tpl-type-tag {
        padding: 6px 16px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1.5px solid #e2e8f0; background: #f8fafc; color: #475569;
        cursor: pointer; transition: all 0.15s; font-family: inherit;
    }
    .ai-tpl-type-tag:hover { border-color: #c7d2fe; background: #eef2ff; color: #4f46e5; }
    .ai-tpl-type-tag.active { border-color: #6366f1; background: #eef2ff; color: #4f46e5; font-weight: 600; }
    .ai-tpl-preview {
        min-height: 200px; max-height: 400px; overflow-y: auto;
        padding: 16px; border: 1.5px solid #e2e8f0; border-radius: 10px;
        background: #f8fafc; font-size: 14px; line-height: 1.8; color: #334155;
        margin-bottom: 16px;
    }
    .ai-tpl-preview h2 { font-size: 20px; color: #1e293b; margin: 12px 0 6px; }
    .ai-tpl-preview h3 { font-size: 16px; color: #1e293b; margin: 10px 0 4px; }
    .ai-tpl-preview h4 { font-size: 14px; color: #334155; margin: 8px 0 4px; }
    .ai-tpl-preview:empty::before {
        content: 'AI 生成的模板内容将在此显示...';
        color: #94a3b8; font-style: italic;
    }
    .ai-tpl-status {
        font-size: 13px; color: #6366f1; margin-bottom: 12px;
        display: flex; align-items: center; gap: 8px; min-height: 24px;
    }
    .ai-tpl-spinner {
        width: 16px; height: 16px; border: 2px solid #e0e7ff;
        border-top-color: #6366f1; border-radius: 50%;
        animation: aiTplSpin 0.6s linear infinite; display: inline-block;
    }
    @keyframes aiTplSpin { to { transform: rotate(360deg); } }
    .ai-tpl-actions { display: flex; gap: 10px; align-items: center; }
</style>

<div class="tpl-page">
    <!-- 页面标题 -->
    <div class="tpl-header">
        <div class="tpl-title-wrap">
            <div class="tpl-title">
                <span class="tpl-icon">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                </span>
                学案模板管理
            </div>
            <div class="tpl-subtitle">创建和管理学案模板，用于快速生成标准化学案</div>
        </div>
    </div>

    <!-- 创建/上传卡片 -->
    <div class="tpl-card">
        <div class="tpl-card-header">
            <div class="tpl-tabs">
                <button type="button" class="tpl-tab active" onclick="switchTab('create', this)">创建模板</button>
                <button type="button" class="tpl-tab" onclick="switchTab('upload', this)">上传模板</button>
                <button type="button" class="tpl-tab" onclick="switchTab('ai', this)">
                    <span style="display:inline-flex;align-items:center;gap:4px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.07A7.002 7.002 0 0 1 14 23h-4a7.002 7.002 0 0 1-6.93-4H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z"/><circle cx="9" cy="15" r="1"/><circle cx="15" cy="15" r="1"/></svg>
                        AI 创建
                    </span>
                </button>
            </div>
        </div>
        <div class="tpl-card-body">
            <!-- 创建模板 -->
            <div id="tabCreate" class="tpl-tab-content active">
                <div class="tpl-form-group">
                    <label>模板名称</label>
                    <asp:TextBox ID="TxtName" runat="server" MaxLength="100" placeholder="请输入模板名称，如：新授课学案模板"></asp:TextBox>
                </div>
                <div class="tpl-form-group">
                    <label>模板内容（HTML格式）</label>
                    <asp:TextBox ID="TxtContent" runat="server" TextMode="MultiLine" Rows="12"
                        placeholder="请输入HTML格式的模板内容，例如：&#10;<h2>【学案名称】</h2>&#10;<h3>一、学习目标</h3>&#10;<ol><li></li></ol>"></asp:TextBox>
                    <div class="tpl-hint">支持HTML标签，如 &lt;h2&gt;、&lt;h3&gt;、&lt;p&gt;、&lt;ol&gt;、&lt;ul&gt;、&lt;table&gt; 等</div>
                </div>
                <asp:Button ID="BtnCreate" runat="server" Text="创建模板" OnClick="BtnCreate_Click" CssClass="tpl-btn tpl-btn-primary" />
            </div>

            <!-- 上传模板 -->
            <div id="tabUpload" class="tpl-tab-content">
                <div class="tpl-form-group">
                    <label>模板名称</label>
                    <asp:TextBox ID="TxtUploadName" runat="server" MaxLength="100" placeholder="请输入模板名称"></asp:TextBox>
                </div>
                <div class="tpl-form-group">
                    <label>选择文件</label>
                    <div class="tpl-upload-area">
                        <asp:FileUpload ID="FUtemplate" runat="server" onchange="handleExcelPreview(this)" />
                        <span class="tpl-hint">支持 HTML、HTM、TXT、Excel（XLS/XLSX）格式，最大 2MB</span>
                    </div>
                </div>
                <asp:HiddenField ID="HiddenExcelHtml" runat="server" />
                <asp:Button ID="BtnUpload" runat="server" Text="上传模板" OnClick="BtnUpload_Click" CssClass="tpl-btn tpl-btn-primary" />
            </div>

            <!-- AI 创建模板 -->
            <div id="tabAi" class="tpl-tab-content">
                <div class="tpl-form-group">
                    <label>模板主题 <span style="color:#ef4444">*</span></label>
                    <input type="text" id="aiTplTopic" placeholder="请输入模板主题，如：Python基础教学、Scratch动画设计、计算机网络基础" />
                </div>
                <div class="tpl-form-group">
                    <label>模板类型</label>
                    <div class="ai-tpl-type-row">
                        <button type="button" class="ai-tpl-type-tag active" onclick="selectAiType(this,'新授课')">新授课</button>
                        <button type="button" class="ai-tpl-type-tag" onclick="selectAiType(this,'复习课')">复习课</button>
                        <button type="button" class="ai-tpl-type-tag" onclick="selectAiType(this,'实践课')">实践课</button>
                        <button type="button" class="ai-tpl-type-tag" onclick="selectAiType(this,'信息科技课')">信息科技课</button>
                        <button type="button" class="ai-tpl-type-tag" onclick="selectAiType(this,'项目实践课')">项目实践课</button>
                    </div>
                </div>
                <button type="button" class="ai-tpl-btn" id="aiTplGenBtn" onclick="startAiTplGenerate()">
                    <svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                    AI 生成模板
                </button>
                <div class="ai-tpl-status" id="aiTplStatus"></div>
                <div class="ai-tpl-preview" id="aiTplPreview"></div>
                <div class="ai-tpl-actions" id="aiTplActions" style="display:none;">
                    <button type="button" class="tpl-btn tpl-btn-primary" onclick="applyAiTemplate()">应用到创建模板</button>
                    <button type="button" class="tpl-btn" onclick="startAiTplGenerate()">重新生成</button>
                </div>
            </div>

            <asp:Label ID="LabelMsg" runat="server" CssClass="tpl-msg"></asp:Label>
        </div>
    </div>

    <!-- 模板列表 -->
    <div class="tpl-card">
        <div class="tpl-card-header">
            <div class="tpl-card-title">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                模板列表
            </div>
            <span class="tpl-count">共 <asp:Label ID="LabelCount" runat="server" Text="0"></asp:Label> 个模板</span>
        </div>
        <div class="tpl-card-body" style="padding: 0;">
            <asp:Repeater ID="RptTemplates" runat="server" OnItemCommand="RptTemplates_ItemCommand">
                <HeaderTemplate>
                    <table class="tpl-table">
                        <thead>
                            <tr>
                                <th style="width:50px">#</th>
                                <th>模板名称</th>
                                <th style="width:80px">类型</th>
                                <th style="width:100px">创建者</th>
                                <th style="width:150px">创建时间</th>
                                <th style="width:160px">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("Index") %></td>
                        <td style="font-weight:600;"><%# Server.HtmlEncode(Eval("Name").ToString()) %></td>
                        <td><span class="tpl-badge <%# Eval("TypeClass") %>"><%# Eval("TypeText") %></span></td>
                        <td><%# Server.HtmlEncode(Eval("Creator").ToString()) %></td>
                        <td><%# Eval("CreateTime") %></td>
                        <td>
                            <button type="button" class="tpl-action-link" onclick="previewTemplate(this)" data-name="<%# Server.HtmlEncode(Eval("Name").ToString()) %>" data-content-b64="<%# Eval("ContentBase64") %>">
                                预览
                            </button>
                            <asp:LinkButton ID="BtnDelete" runat="server" CommandName="DeleteTemplate"
                                CommandArgument='<%# Eval("Id") %>' CssClass="tpl-delete-btn"
                                OnClientClick="return confirm('确定要删除这个模板吗？');">
                                删除
                            </asp:LinkButton>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>

<!-- 预览弹窗 -->
<div class="tpl-preview-overlay" id="previewOverlay" onclick="closePreviewIfBg(event)">
    <div class="tpl-preview-box">
        <div class="tpl-preview-header">
            <h3 id="previewTitle">模板预览</h3>
            <button type="button" class="tpl-preview-close" onclick="closePreview()">&times;</button>
        </div>
        <div class="tpl-preview-body" id="previewBody"></div>
        <div class="tpl-preview-footer">
            <button type="button" class="tpl-preview-footer-btn" onclick="closePreview()">关闭预览</button>
        </div>
    </div>
</div>

<script src="https://cdn.sheetjs.com/xlsx-0.20.0/package/dist/xlsx.full.min.js"></script>
<script type="text/javascript">
    var _aiTplType = '新授课';
    var _aiTplHtml = '';

    function switchTab(tab, el) {
        var tabs = document.querySelectorAll('.tpl-tab');
        var contents = document.querySelectorAll('.tpl-tab-content');
        for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('active');
        for (var i = 0; i < contents.length; i++) contents[i].classList.remove('active');
        el.classList.add('active');
        var map = { 'create': 'tabCreate', 'upload': 'tabUpload', 'ai': 'tabAi' };
        document.getElementById(map[tab]).classList.add('active');
    }

    // === AI 创建模板 ===
    function selectAiType(el, type) {
        _aiTplType = type;
        var tags = document.querySelectorAll('.ai-tpl-type-tag');
        for (var i = 0; i < tags.length; i++) tags[i].classList.remove('active');
        el.classList.add('active');
    }

    function startAiTplGenerate() {
        var topic = document.getElementById('aiTplTopic').value.trim();
        if (!topic) { alert('请输入模板主题'); return; }

        _aiTplHtml = '';
        var preview = document.getElementById('aiTplPreview');
        preview.innerHTML = '';
        document.getElementById('aiTplStatus').innerHTML = '<span class="ai-tpl-spinner"></span> 正在生成中，请稍候...';
        document.getElementById('aiTplActions').style.display = 'none';
        document.getElementById('aiTplGenBtn').disabled = true;

        var body = JSON.stringify({ topic: topic, templateType: _aiTplType });
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'aigentemplate.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/json');

        var buffer = '';
        var lastIndex = 0;

        xhr.onprogress = function() {
            var newData = xhr.responseText.substring(lastIndex);
            lastIndex = xhr.responseText.length;
            buffer += newData;
            var lines = buffer.split('\n');
            buffer = lines.pop();
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (!line) continue;
                if (line.indexOf('data: ') === 0) {
                    var jsonStr = line.substring(6).trim();
                    if (jsonStr === '[DONE]') { onAiTplDone(); return; }
                    try {
                        var chunk = JSON.parse(jsonStr);
                        if (chunk.content) {
                            _aiTplHtml += chunk.content;
                            preview.innerHTML = _aiTplHtml;
                            preview.scrollTop = preview.scrollHeight;
                        }
                    } catch(e) {}
                }
            }
        };

        xhr.onload = function() {
            if (buffer.trim()) {
                var rem = buffer.trim();
                if (rem.indexOf('data: ') === 0) {
                    var js = rem.substring(6).trim();
                    if (js !== '[DONE]') {
                        try { var c = JSON.parse(js); if (c.content) { _aiTplHtml += c.content; preview.innerHTML = _aiTplHtml; } } catch(e) {}
                    }
                }
            }
            onAiTplDone();
        };

        xhr.onerror = function() {
            document.getElementById('aiTplStatus').innerHTML = '<span style="color:#ef4444">生成失败，请重试</span>';
            document.getElementById('aiTplGenBtn').disabled = false;
        };

        xhr.send(body);
    }

    function onAiTplDone() {
        document.getElementById('aiTplStatus').innerHTML = '<span style="color:#16a34a">✓ 生成完成</span>';
        document.getElementById('aiTplGenBtn').disabled = false;
        if (_aiTplHtml) {
            document.getElementById('aiTplActions').style.display = 'flex';
        }
    }

    function applyAiTemplate() {
        if (!_aiTplHtml) { alert('没有可应用的内容'); return; }
        // 切换到创建模板Tab
        var createTab = document.querySelectorAll('.tpl-tab')[0];
        switchTab('create', createTab);
        // 填充名称和内容
        var nameInput = document.querySelector('input[id$="TxtName"]');
        var contentArea = document.querySelector('textarea[id$="TxtContent"]');
        if (nameInput && !nameInput.value) {
            var topic = document.getElementById('aiTplTopic').value.trim();
            nameInput.value = topic ? topic + '学案模板' : 'AI生成模板';
        }
        if (contentArea) contentArea.value = _aiTplHtml;
        alert('已应用到创建模板表单，请检查并点击“创建模板”保存。');
    }

    // === Excel 客户端解析 ===
    function handleExcelPreview(input) {
        if (!input.files || !input.files[0]) return;
        var file = input.files[0];
        var ext = file.name.split('.').pop().toLowerCase();
        if (ext !== 'xls' && ext !== 'xlsx') {
            // 非Excel文件，清空hidden
            var hf = document.querySelector('input[id$="HiddenExcelHtml"]');
            if (hf) hf.value = '';
            return;
        }
        if (typeof XLSX === 'undefined') {
            alert('Excel解析库加载中，请稍后再试');
            return;
        }
        var reader = new FileReader();
        reader.onload = function(e) {
            try {
                var data = new Uint8Array(e.target.result);
                var workbook = XLSX.read(data, { type: 'array' });
                var firstSheet = workbook.Sheets[workbook.SheetNames[0]];
                var html = XLSX.utils.sheet_to_html(firstSheet);
                // 提取table部分
                var idx = html.indexOf('<table');
                if (idx >= 0) html = html.substring(idx);
                var hf = document.querySelector('input[id$="HiddenExcelHtml"]');
                if (hf) hf.value = html;
            } catch(ex) {
                alert('Excel解析失败：' + ex.message);
            }
        };
        reader.readAsArrayBuffer(file);
    }

    function previewTemplate(btn) {
        var name = btn.getAttribute('data-name');
        var b64 = btn.getAttribute('data-content-b64');
        var content = '';
        if (b64) {
            try {
                content = decodeURIComponent(Array.prototype.map.call(atob(b64), function(c) {
                    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                }).join(''));
            } catch(e) {
                try { content = atob(b64); } catch(e2) { content = '解码失败'; }
            }
        }
        document.getElementById('previewTitle').textContent = name;
        document.getElementById('previewBody').innerHTML = content;
        document.getElementById('previewOverlay').classList.add('show');
    }

    function closePreview() {
        document.getElementById('previewOverlay').classList.remove('show');
    }

    function closePreviewIfBg(e) {
        if (e.target === document.getElementById('previewOverlay')) closePreview();
    }

    // 消息样式
    (function () {
        var msgEl = document.querySelector('.tpl-msg');
        if (msgEl && msgEl.textContent) {
            var txt = msgEl.textContent.trim();
            if (txt.indexOf('成功') >= 0 || txt.indexOf('已删除') >= 0) {
                msgEl.style.color = '#16a34a';
            } else if (txt.length > 0) {
                msgEl.style.color = '#ef4444';
            }
        }
    })();
</script>
</asp:Content>
