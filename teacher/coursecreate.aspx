<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_coursecreate, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cc-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 36px 24px;
        min-height: 100%;
    }
    .cc-card {
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 4px 24px rgba(0,0,0,0.06), 0 1px 4px rgba(0,0,0,0.04);
        width: 96%;
        max-width: 1100px;
        overflow: hidden;
    }
    .cc-header {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        padding: 24px 32px;
        display: flex;
        align-items: center;
        gap: 14px;
    }
    .cc-header-icon {
        width: 44px; height: 44px;
        background: rgba(255,255,255,0.2);
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .cc-header-icon svg {
        width: 24px; height: 24px;
        stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .cc-header h2 {
        margin: 0; font-size: 20px; font-weight: 700; color: #fff;
        letter-spacing: 0.5px;
    }
    .cc-header p {
        margin: 4px 0 0; font-size: 13px; color: rgba(255,255,255,0.75);
    }
    .cc-body {
        padding: 28px 32px 20px;
    }
    .cc-form-group {
        margin-bottom: 22px;
    }
    .cc-form-group > label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        color: #374151;
        margin-bottom: 8px;
        letter-spacing: 0.2px;
    }
    .cc-form-group > label .cc-required {
        color: #ef4444;
        margin-left: 2px;
    }
    .cc-form-group input[type="text"],
    .cc-form-group select {
        width: 100%;
        height: 42px;
        padding: 0 14px;
        font-size: 14px;
        color: #1e293b;
        background: #f8fafc;
        border: 1.5px solid #e2e8f0;
        border-radius: 10px;
        outline: none;
        transition: border-color 0.2s, box-shadow 0.2s;
        font-family: inherit;
        box-sizing: border-box;
    }
    .cc-form-group input[type="text"]:focus,
    .cc-form-group select:focus {
        border-color: #818cf8;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        background: #fff;
    }
    .cc-form-row {
        display: flex;
        gap: 16px;
        align-items: flex-end;
    }
    .cc-form-row .cc-form-group {
        flex: 1;
    }
    .cc-checkbox-wrap {
        display: flex;
        align-items: center;
        height: 42px;
        padding: 0 4px;
    }
    .cc-checkbox-wrap input[type="checkbox"] {
        width: 18px; height: 18px;
        accent-color: #6366f1;
        cursor: pointer;
        margin-right: 6px;
    }
    .cc-checkbox-wrap label {
        font-size: 13px;
        font-weight: 500;
        color: #475569;
        margin: 0;
        cursor: pointer;
    }
    .cc-term-info {
        background: #f0fdf4;
        border: 1px solid #bbf7d0;
        border-radius: 10px;
        padding: 12px 16px;
        font-size: 13px;
        color: #166534;
        text-align: center;
        margin-bottom: 22px;
    }
    .cc-footer {
        padding: 0 32px 28px;
        display: flex;
        gap: 16px;
        justify-content: center;
    }
    .cc-footer input[type="submit"] {
        width: 140px !important;
        height: 44px !important;
        font-size: 15px !important;
        font-weight: 600;
        border: none;
        border-radius: 8px !important;
        cursor: pointer;
        transition: all 0.2s;
        font-family: 'Microsoft YaHei', sans-serif !important;
        letter-spacing: 2px;
    }
    .cc-footer .cc-ai-btn {
        height: 44px;
        padding: 0 24px;
        font-size: 14px;
        border-radius: 8px;
        letter-spacing: 0.5px;
    }
    .cc-footer .cc-ai-btn svg {
        width: 18px; height: 18px;
    }
    .cc-btn-primary {
        background: #6366f1 !important;
        color: #fff !important;
        box-shadow: 0 2px 8px rgba(99,102,241,0.3);
    }
    .cc-btn-primary:hover {
        background: #4f46e5 !important;
        box-shadow: 0 4px 14px rgba(99,102,241,0.4) !important;
        transform: translateY(-1px);
    }
    .cc-btn-secondary {
        background: #fff !important;
        color: #475569 !important;
        border: 1.5px solid #d1d5db !important;
    }
    .cc-btn-secondary:hover {
        background: #f8fafc !important;
        border-color: #9ca3af !important;
        color: #1e293b !important;
    }
    .cc-msg {
        text-align: center;
        padding: 0 32px 20px;
        font-size: 13px;
    }
    /* 底部说明板块 */
    .cc-tips {
        margin: 24px auto 0;
        max-width: 1100px;
        width: 96%;
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 24px 32px;
    }
    .cc-tips-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 15px;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 16px;
    }
    .cc-tips-title svg {
        width: 20px; height: 20px;
        stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }
    .cc-tips-list {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    .cc-tips-list li {
        position: relative;
        padding: 10px 0 10px 28px;
        font-size: 13px;
        color: #475569;
        line-height: 1.6;
        border-bottom: 1px dashed #f1f5f9;
    }
    .cc-tips-list li:last-child {
        border-bottom: none;
    }
    .cc-tips-list li::before {
        content: '';
        position: absolute;
        left: 6px;
        top: 15px;
        width: 8px; height: 8px;
        background: #c7d2fe;
        border-radius: 50%;
    }
    .cc-tips-list li strong {
        color: #334155;
    }

    /* AI 生成按钮 */
    .cc-ai-btn {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 12px 28px; border: none; border-radius: 10px;
        background: linear-gradient(135deg, #8b5cf6, #6366f1, #3b82f6);
        color: #fff; font-size: 15px; font-weight: 600;
        cursor: pointer; transition: all 0.3s; font-family: inherit;
        box-shadow: 0 4px 16px rgba(99,102,241,0.3);
        letter-spacing: 1px;
    }
    .cc-ai-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 28px rgba(99,102,241,0.45);
        filter: brightness(1.06);
    }
    .cc-ai-btn svg {
        width: 20px; height: 20px; fill: none; stroke: currentColor;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .cc-ai-section {
        display: none;
    }

    /* AI 模态对话框 */
    .ai-modal-overlay {
        display: none;
        position: fixed;
        top: 0; left: 0;
        width: 100%; height: 100%;
        background: rgba(0,0,0,0.55);
        z-index: 10000;
        /* 允许小屏滚动，避免弹窗被裁切 */
        overflow: auto;
        -webkit-overflow-scrolling: touch;
        backdrop-filter: blur(4px);
    }
    .ai-modal-overlay.show {
        display: -webkit-flex;
        display: flex;
        -webkit-justify-content: center;
        justify-content: center;
        -webkit-align-items: center;
        align-items: center;
        padding: 16px;
    }
    .ai-modal {
        background: #fff;
        border-radius: 20px;
        width: 100%;
        max-width: 1000px;
        height: 90%;
        max-height: 90vh;
        overflow: hidden;
        display: -webkit-flex;
        display: flex;
        -webkit-flex-direction: column;
        flex-direction: column;
        box-shadow: 0 25px 80px rgba(0,0,0,0.2);
        animation: aiModalIn 0.3s ease-out;
    }
    @keyframes aiModalIn {
        from { opacity: 0; transform: translateY(20px) scale(0.97); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }
    .ai-modal-header {
        padding: 20px 28px; border-bottom: 1px solid #e8ecf1;
        display: flex; align-items: center; justify-content: space-between;
        background: linear-gradient(135deg, #eef2ff, #f5f3ff);
        flex-shrink: 0;
    }
    .ai-modal-header h3 {
        margin: 0; font-size: 18px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 10px;
    }
    .ai-modal-header h3 svg {
        width: 24px; height: 24px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .ai-modal-close {
        width: 36px; height: 36px; border: none; background: rgba(99,102,241,0.1);
        border-radius: 10px; cursor: pointer; font-size: 20px; color: #6366f1;
        display: flex; align-items: center; justify-content: center;
        transition: all 0.2s;
    }
    .ai-modal-close:hover { background: rgba(99,102,241,0.2); }
    .ai-modal-body {
        display: flex; flex: 1; overflow: hidden; min-height: 0;
    }

    /* 左侧知识库 */
    .ai-panel-left {
        flex: 1; border-right: 1px solid #e8ecf1;
        display: flex; flex-direction: column; overflow: hidden;
    }
    .ai-panel-header {
        padding: 14px 20px; border-bottom: 1px solid #f1f5f9;
        font-size: 14px; font-weight: 600; color: #334155;
        display: flex; align-items: center; gap: 8px;
        flex-shrink: 0; background: #fafbfc;
    }
    .ai-panel-header svg {
        width: 16px; height: 16px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .ai-panel-body {
        flex: 1; overflow-y: auto; padding: 12px 16px;
    }
    .ai-kb-item {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 12px; border-radius: 8px; margin-bottom: 4px;
        transition: background 0.15s; cursor: pointer;
    }
    .ai-kb-item:hover { background: #f1f5f9; }
    .ai-kb-item input[type="checkbox"] {
        width: 18px; height: 18px; accent-color: #6366f1;
        cursor: pointer; flex-shrink: 0;
    }
    .ai-kb-info { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
    .ai-kb-title {
        font-size: 13px; font-weight: 500; color: #1e293b;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .ai-kb-meta { font-size: 11px; color: #94a3b8; }
    .ai-kb-badge {
        display: inline-flex; padding: 2px 8px; border-radius: 4px;
        font-size: 11px; font-weight: 500; background: #eef2ff; color: #4f46e5;
        flex-shrink: 0;
    }
    .ai-kb-empty {
        text-align: center; padding: 40px 20px; color: #94a3b8; font-size: 13px;
    }

    /* 右侧模板 */
    .ai-panel-right {
        width: 320px; flex-shrink: 0;
        display: flex; flex-direction: column; overflow: hidden;
    }
    .ai-tpl-item {
        display: flex; align-items: center; gap: 10px;
        padding: 10px 12px; border-radius: 8px; margin-bottom: 4px;
        transition: background 0.15s; cursor: pointer;
    }
    .ai-tpl-item:hover { background: #f1f5f9; }
    .ai-tpl-item.selected { background: #eef2ff; border: 1px solid #c7d2fe; }
    .ai-tpl-item input[type="radio"] {
        width: 18px; height: 18px; accent-color: #6366f1;
        cursor: pointer; flex-shrink: 0;
    }
    .ai-tpl-name { font-size: 13px; font-weight: 500; color: #1e293b; }
    .ai-tpl-type {
        font-size: 11px; color: #94a3b8; margin-left: auto;
    }

    /* 底部操作 */
    .ai-modal-footer {
        padding: 16px 28px; border-top: 1px solid #e8ecf1;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc; flex-shrink: 0;
    }
    .ai-modal-footer .ai-selection-info {
        font-size: 13px; color: #64748b;
    }
    .ai-modal-footer .ai-selection-info strong { color: #6366f1; }
    .ai-gen-btn {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 28px; border: none; border-radius: 10px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: all 0.2s; font-family: inherit;
        box-shadow: 0 2px 8px rgba(99,102,241,0.3);
    }
    .ai-gen-btn:hover { box-shadow: 0 4px 16px rgba(99,102,241,0.4); transform: translateY(-1px); }
    .ai-gen-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
    .ai-gen-btn svg {
        width: 18px; height: 18px; fill: none; stroke: currentColor;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* AI 生成结果区域 */
    .ai-result-overlay {
        display: none;
        position: fixed;
        top: 0; left: 0;
        width: 100%; height: 100%;
        background: rgba(0,0,0,0.55);
        z-index: 10001;
        overflow: auto;
        -webkit-overflow-scrolling: touch;
        backdrop-filter: blur(4px);
    }
    .ai-result-overlay.show {
        display: -webkit-flex;
        display: flex;
        -webkit-justify-content: center;
        justify-content: center;
        -webkit-align-items: center;
        align-items: center;
        padding: 16px;
    }
    .ai-result-box {
        background: #fff;
        border-radius: 20px;
        width: 100%;
        max-width: 900px;
        height: 90%;
        max-height: 90vh;
        overflow: hidden;
        display: -webkit-flex;
        display: flex;
        -webkit-flex-direction: column;
        flex-direction: column;
        box-shadow: 0 25px 80px rgba(0,0,0,0.2);
    }
    .ai-result-header {
        padding: 20px 28px; border-bottom: 1px solid #e8ecf1;
        display: flex; align-items: center; justify-content: space-between;
        background: linear-gradient(135deg, #eef2ff, #f5f3ff);
        flex-shrink: 0;
    }
    .ai-result-header h3 { margin: 0; font-size: 16px; font-weight: 700; color: #1e293b; }
    .ai-result-body {
        flex: 1; overflow-y: auto; padding: 24px 28px;
        font-size: 14px; line-height: 1.8; color: #334155;
    }
    .ai-result-body h2 { font-size: 20px; color: #1e293b; margin: 16px 0 8px; }
    .ai-result-body h3 { font-size: 16px; color: #1e293b; margin: 14px 0 6px; }
    .ai-result-body h4 { font-size: 14px; color: #334155; margin: 12px 0 4px; }
    .ai-result-footer {
        padding: 16px 28px; border-top: 1px solid #e8ecf1;
        display: flex; align-items: center; justify-content: flex-end; gap: 12px;
        background: #fafbfc; flex-shrink: 0;
    }
    .ai-result-status {
        flex: 1; font-size: 13px; color: #6366f1; font-weight: 500;
        display: flex; align-items: center; gap: 8px;
    }
    .ai-result-status .ai-spinner {
        width: 16px; height: 16px; border: 2px solid #e0e7ff;
        border-top-color: #6366f1; border-radius: 50%;
        animation: aiSpin 0.6s linear infinite;
    }
    @keyframes aiSpin { to { transform: rotate(360deg); } }
    .ai-apply-btn {
        padding: 10px 24px; border: none; border-radius: 8px;
        background: #6366f1; color: #fff; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: all 0.2s; font-family: inherit;
    }
    .ai-apply-btn:hover { background: #4f46e5; }
    .ai-apply-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .ai-cancel-btn {
        padding: 10px 24px; border: 1px solid #d1d5db; border-radius: 8px;
        background: #fff; color: #475569; font-size: 14px; font-weight: 500;
        cursor: pointer; transition: all 0.2s; font-family: inherit;
    }
    .ai-cancel-btn:hover { border-color: #9ca3af; background: #f8fafc; }
</style>

<div class="cc-wrapper">
    <div class="cc-card">
        <div class="cc-header">
            <div class="cc-header-icon">
                <svg viewBox="0 0 24 24"><path d="M12 5v14"/><path d="M5 12h14"/></svg>
            </div>
            <div>
                <h2>创建学案</h2>
                <p>填写以下信息来创建新的学案</p>
            </div>
        </div>

        <div class="cc-body">
            <div class="cc-form-group">
                <label>学案名称 <span class="cc-required">*</span></label>
                <asp:TextBox ID="Texttitle" runat="server" Width="100%" SkinID="TextBoxNormal" />
            </div>

            <div class="cc-form-row">
                <div class="cc-form-group">
                    <label>学案分类</label>
                    <asp:DropDownList ID="DDLclass" runat="server" Width="100%" Font-Size="9pt" />
                </div>
                <div class="cc-form-group">
                    <label>教学年级</label>
                    <asp:DropDownList ID="DDLcobj" runat="server" Width="100%" Font-Size="9pt"
                        AutoPostBack="True" onselectedindexchanged="DDLcobj_SelectedIndexChanged" />
                </div>
            </div>

            <div class="cc-form-row">
                <div class="cc-form-group">
                    <label>按排课节</label>
                    <asp:DropDownList ID="DDLCks" runat="server" Font-Size="9pt" Width="100%" Font-Names="Arial" />
                </div>
                <div class="cc-form-group">
                    <label>&nbsp;</label>
                    <div class="cc-checkbox-wrap">
                        <asp:CheckBox ID="Checkcpublish" runat="server" Text="是否发布" Checked="True" />
                    </div>
                </div>
            </div>

            <div class="cc-term-info">
                <asp:Label ID="Labelterm" runat="server" Text="Label" />
            </div>
        </div>

        <div class="cc-footer">
            <button type="button" class="cc-ai-btn" onclick="openAiModal()">
                <svg viewBox="0 0 24 24"><path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.07A7.002 7.002 0 0 1 14 23h-4a7.002 7.002 0 0 1-6.93-4H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z"/><circle cx="9" cy="15" r="1"/><circle cx="15" cy="15" r="1"/></svg>
                AI 智能生成
            </button>
            <asp:Button ID="BtnCreate" runat="server" Text="创建学案" onclick="BtnCreate_Click"
                SkinID="BtnNormal" CssClass="cc-btn-primary" />
            <asp:Button ID="Btnreturn" runat="server" Text="返回列表" onclick="Btnreturn_Click"
                SkinID="BtnNormal" CssClass="cc-btn-secondary" />
        </div>

        <div class="cc-msg">
            <asp:Label ID="Labelmsg" runat="server" />
        </div>
    </div>

    <div class="cc-tips">
        <div class="cc-tips-title">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            使用说明
        </div>
        <ul class="cc-tips-list">
            <li><strong>学案名称：</strong>请输入本次教学活动的学案名称，名称应简洁明了，便于学生识别。</li>
            <li><strong>学案分类：</strong>选择该学案所属的课程分类，方便后续管理和查找。</li>
            <li><strong>教学年级：</strong>选择该学案面向的教学年级，切换年级后课节列表会自动更新。</li>
            <li><strong>按排课节：</strong>选择学案对应的课节编号，系统会按课节顺序排列学案。</li>
            <li><strong>是否发布：</strong>勾选后学案创建即发布，学生可立即查看；取消勾选则保存为草稿。</li>
            <li><strong>创建完成后：</strong>可在备课页面中继续编辑学案内容，添加教学素材和学习任务。</li>
        </ul>
    </div>
</div>
<!-- AI 选择对话框 -->
<div class="ai-modal-overlay" id="aiModalOverlay" onclick="if(event.target===this)closeAiModal()">
    <div class="ai-modal">
        <div class="ai-modal-header">
            <h3>
                <svg viewBox="0 0 24 24"><path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.07A7.002 7.002 0 0 1 14 23h-4a7.002 7.002 0 0 1-6.93-4H2a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z"/><circle cx="9" cy="15" r="1"/><circle cx="15" cy="15" r="1"/></svg>
                AI 智能生成学案
            </h3>
            <button type="button" class="ai-modal-close" onclick="closeAiModal()">&times;</button>
        </div>
        <div class="ai-modal-body">
            <!-- 左侧：知识库资料 -->
            <div class="ai-panel-left">
                <div class="ai-panel-header">
                    <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                    选择知识库资料（可多选）
                </div>
                <div class="ai-panel-body" id="aiKbList">
                    <div class="ai-kb-empty">正在加载知识库资料...</div>
                </div>
            </div>
            <!-- 右侧：模板选择 -->
            <div class="ai-panel-right">
                <div class="ai-panel-header">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                    选择学案模板（必选）
                </div>
                <div class="ai-panel-body" id="aiTplList">
                    <div class="ai-kb-empty">正在加载模板列表...</div>
                </div>
            </div>
        </div>
        <div class="ai-modal-footer">
            <div class="ai-selection-info" id="aiSelectionInfo">请选择资料和模板</div>
            <button type="button" class="ai-gen-btn" id="aiGenBtn" onclick="startAiGenerate()" disabled>
                <svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                开始生成
            </button>
        </div>
    </div>
</div>

<!-- AI 生成结果对话框 -->
<div class="ai-result-overlay" id="aiResultOverlay">
    <div class="ai-result-box">
        <div class="ai-result-header">
            <h3>AI 生成结果</h3>
            <button type="button" class="ai-modal-close" onclick="closeAiResult()">&times;</button>
        </div>
        <div class="ai-result-body" id="aiResultBody">
            <div style="text-align:center;padding:40px;color:#94a3b8;">等待生成...</div>
        </div>
        <div class="ai-result-footer">
            <div class="ai-result-status" id="aiResultStatus">
                <div class="ai-spinner"></div>
                <span>正在生成中...</span>
            </div>
            <button type="button" class="ai-cancel-btn" onclick="closeAiResult()">取消</button>
            <button type="button" class="ai-apply-btn" id="aiApplyBtn" onclick="applyAiResult()" disabled>应用到学案</button>
        </div>
    </div>
</div>

<script type="text/javascript">
var _aiKnowledgeData = [];
var _aiTemplateData = [];
var _aiGeneratedHtml = '';
var _aiEventSource = null;

// 打开 AI 对话框
function openAiModal() {
    document.getElementById('aiModalOverlay').classList.add('show');
    loadKnowledgeList();
    loadTemplateList();
}
function closeAiModal() {
    document.getElementById('aiModalOverlay').classList.remove('show');
}

// 加载知识库列表
function loadKnowledgeList() {
    var container = document.getElementById('aiKbList');
    container.innerHTML = '<div class="ai-kb-empty">正在加载...</div>';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'knowledgeapi.ashx', true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.error) {
                        container.innerHTML = '<div class="ai-kb-empty">' + escHtml(data.error) + '</div>';
                        return;
                    }
                    _aiKnowledgeData = data.items || [];
                    renderKnowledgeList();
                } catch(e) {
                    container.innerHTML = '<div class="ai-kb-empty">解析失败: ' + escHtml(e.message) + '</div>';
                }
            } else {
                var errMsg = '加载失败 (HTTP ' + xhr.status + ')';
                if (xhr.responseText) errMsg += '<br/><small style="word-break:break-all">' + escHtml(xhr.responseText.substring(0, 200)) + '</small>';
                container.innerHTML = '<div class="ai-kb-empty">' + errMsg + '</div>';
            }
        }
    };
    xhr.onerror = function() {
        container.innerHTML = '<div class="ai-kb-empty">网络请求失败，请检查服务器</div>';
    };
    xhr.send();
}

function renderKnowledgeList() {
    var container = document.getElementById('aiKbList');
    if (_aiKnowledgeData.length === 0) {
        container.innerHTML = '<div class="ai-kb-empty">暂无知识库资料<br/>请先在「知识库」页面上传资料</div>';
        return;
    }
    var html = '';
    for (var i = 0; i < _aiKnowledgeData.length; i++) {
        var item = _aiKnowledgeData[i];
        html += '<label class="ai-kb-item">';
        html += '<input type="checkbox" value="' + item.id + '" onchange="updateAiSelection()"/>';
        html += '<div class="ai-kb-info">';
        html += '<span class="ai-kb-title">' + escHtml(item.title) + '</span>';
        html += '<span class="ai-kb-meta">' + escHtml(item.originalName || '') + '</span>';
        html += '</div>';
        html += '<span class="ai-kb-badge">' + escHtml(item.category) + '</span>';
        html += '</label>';
    }
    container.innerHTML = html;
}

// 加载模板列表
function loadTemplateList() {
    var container = document.getElementById('aiTplList');
    container.innerHTML = '<div class="ai-kb-empty">正在加载...</div>';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'templateapi.ashx', true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.error) {
                        container.innerHTML = '<div class="ai-kb-empty">' + escHtml(data.error) + '</div>';
                        return;
                    }
                    _aiTemplateData = data.templates || [];
                    renderTemplateList();
                } catch(e) {
                    container.innerHTML = '<div class="ai-kb-empty">解析失败: ' + escHtml(e.message) + '</div>';
                }
            } else {
                var errMsg = '加载失败 (HTTP ' + xhr.status + ')';
                if (xhr.responseText) errMsg += '<br/><small style="word-break:break-all">' + escHtml(xhr.responseText.substring(0, 200)) + '</small>';
                container.innerHTML = '<div class="ai-kb-empty">' + errMsg + '</div>';
            }
        }
    };
    xhr.onerror = function() {
        container.innerHTML = '<div class="ai-kb-empty">网络请求失败，请检查服务器</div>';
    };
    xhr.send();
}

function renderTemplateList() {
    var container = document.getElementById('aiTplList');
    if (_aiTemplateData.length === 0) {
        container.innerHTML = '<div class="ai-kb-empty">暂无模板<br/>请先在「学案模板」页面创建模板</div>';
        return;
    }
    var html = '';
    for (var i = 0; i < _aiTemplateData.length; i++) {
        var tpl = _aiTemplateData[i];
        var typeText = tpl.type === 'builtin' ? '内置' : (tpl.type === 'create' ? '自建' : '上传');
        html += '<label class="ai-tpl-item">';
        html += '<input type="radio" name="aiTemplate" value="' + tpl.id + '" onchange="updateAiSelection()"/>';
        html += '<span class="ai-tpl-name">' + escHtml(tpl.name) + '</span>';
        html += '<span class="ai-tpl-type">' + typeText + '</span>';
        html += '</label>';
    }
    container.innerHTML = html;
}

// 更新选择状态
function updateAiSelection() {
    var kbChecked = document.querySelectorAll('#aiKbList input[type="checkbox"]:checked');
    var tplSelected = document.querySelector('#aiTplList input[type="radio"]:checked');

    var info = '已选 <strong>' + kbChecked.length + '</strong> 个资料';
    if (tplSelected) {
        var tplLabel = tplSelected.parentElement.querySelector('.ai-tpl-name');
        info += '，模板：<strong>' + (tplLabel ? tplLabel.textContent : '') + '</strong>';
    } else {
        info += '，<span style="color:#ef4444">请选择模板</span>';
    }
    document.getElementById('aiSelectionInfo').innerHTML = info;

    document.getElementById('aiGenBtn').disabled = !tplSelected;

    // 高亮选中的模板
    var tplItems = document.querySelectorAll('.ai-tpl-item');
    for (var i = 0; i < tplItems.length; i++) {
        var radio = tplItems[i].querySelector('input[type="radio"]');
        if (radio && radio.checked) {
            tplItems[i].classList.add('selected');
        } else {
            tplItems[i].classList.remove('selected');
        }
    }
}

// 开始 AI 生成
function startAiGenerate() {
    var kbChecked = document.querySelectorAll('#aiKbList input[type="checkbox"]:checked');
    var tplSelected = document.querySelector('#aiTplList input[type="radio"]:checked');

    if (!tplSelected) {
        alert('请选择一个学案模板');
        return;
    }

    var knowledgeIds = [];
    for (var i = 0; i < kbChecked.length; i++) {
        knowledgeIds.push(kbChecked[i].value);
    }

    var courseName = '';
    var titleInput = document.querySelector('input[id$="Texttitle"]');
    if (titleInput) courseName = titleInput.value;

    // 关闭选择对话框，打开结果对话框
    closeAiModal();
    _aiGeneratedHtml = '';
    document.getElementById('aiResultBody').innerHTML = '';
    document.getElementById('aiResultStatus').innerHTML = '<div class="ai-spinner"></div><span>正在生成中，请稍候...</span>';
    document.getElementById('aiApplyBtn').disabled = true;
    document.getElementById('aiResultOverlay').classList.add('show');

    // 发起 SSE 请求
    var body = JSON.stringify({
        knowledgeIds: knowledgeIds.join(','),
        templateId: tplSelected.value,
        courseName: courseName
    });

    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'aigenlesson.ashx', true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    var buffer = '';
    var lastIndex = 0;

    xhr.onprogress = function() {
        var newData = xhr.responseText.substring(lastIndex);
        lastIndex = xhr.responseText.length;
        buffer += newData;

        var lines = buffer.split('\n');
        buffer = lines.pop(); // 保留不完整的行

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line) continue;

            if (line.indexOf('data: ') === 0) {
                var jsonStr = line.substring(6).trim();
                if (jsonStr === '[DONE]') {
                    onAiComplete();
                    return;
                }
                try {
                    var chunk = JSON.parse(jsonStr);
                    if (chunk.content) {
                        _aiGeneratedHtml += chunk.content;
                        document.getElementById('aiResultBody').innerHTML = _aiGeneratedHtml;
                        // 自动滚动到底部
                        var resultBody = document.getElementById('aiResultBody');
                        resultBody.scrollTop = resultBody.scrollHeight;
                    }
                } catch(e) {}
            }
        }
    };

    xhr.onload = function() {
        // 处理剩余缓冲
        if (buffer.trim()) {
            var remaining = buffer.trim();
            if (remaining.indexOf('data: ') === 0) {
                var jsonStr = remaining.substring(6).trim();
                if (jsonStr !== '[DONE]') {
                    try {
                        var chunk = JSON.parse(jsonStr);
                        if (chunk.content) {
                            _aiGeneratedHtml += chunk.content;
                            document.getElementById('aiResultBody').innerHTML = _aiGeneratedHtml;
                        }
                    } catch(e) {}
                }
            }
        }
        onAiComplete();
    };

    xhr.onerror = function() {
        document.getElementById('aiResultStatus').innerHTML = '<span style="color:#ef4444">生成失败，请重试</span>';
    };

    xhr.send(body);
}

function onAiComplete() {
    document.getElementById('aiResultStatus').innerHTML = '<span style="color:#16a34a">✓ 生成完成</span>';
    document.getElementById('aiApplyBtn').disabled = false;
}

// 应用生成结果到学案
function applyAiResult() {
    if (!_aiGeneratedHtml) {
        alert('没有可应用的内容');
        return;
    }

    // 尝试设置学案名称
    var titleInput = document.querySelector('input[id$="Texttitle"]');
    if (titleInput && !titleInput.value) {
        // 尝试从生成内容中提取标题
        var tempDiv = document.createElement('div');
        tempDiv.innerHTML = _aiGeneratedHtml;
        var h2 = tempDiv.querySelector('h2');
        if (h2 && h2.textContent) {
            var title = h2.textContent.replace(/[【】\[\]]/g, '').trim();
            if (title && title !== '学案名称') {
                titleInput.value = title;
            }
        }
    }

    // 将内容存到 sessionStorage，供后续编辑页面使用
    try {
        sessionStorage.setItem('aiGeneratedLesson', _aiGeneratedHtml);
    } catch(e) {}

    closeAiResult();
    alert('学案内容已生成！请先创建学案，然后在编辑页面中查看和修改内容。\n\n生成的内容已暂存，创建学案后进入编辑页面将自动加载。');
}

function closeAiResult() {
    document.getElementById('aiResultOverlay').classList.remove('show');
}

function escHtml(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
</script>
</asp:Content>

