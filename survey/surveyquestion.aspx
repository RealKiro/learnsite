<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Survey_surveyquestion, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link href="../teacher/show-common.css" rel="stylesheet" type="text/css" />

<style>
    /* ===== 调查题添加页面样式 (参照 topicadd) ===== */
    .sq-page {
        max-width: 1440px;
        width: 100%;
        margin: 0 auto;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif;
        animation: sqFadeIn .5s ease;
    }
    
    @keyframes sqFadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* 渐变标题栏 (绿色主题) */
    .sq-header {
        display: flex;
        align-items: center;
        gap: 20px;
        margin-bottom: 28px;
        padding: 28px 32px;
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
        border-radius: 16px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(5,150,105,.25);
    }
    
    .sq-header::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -30px;
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    
    .sq-header::after {
        content: '';
        position: absolute;
        bottom: -40px;
        right: 60px;
        width: 160px;
        height: 160px;
        border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    
    .sq-header-icon {
        width: 52px;
        height: 52px;
        background: rgba(255,255,255,.18);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        backdrop-filter: blur(10px);
        flex-shrink: 0;
        position: relative;
        z-index: 1;
    }
    
    .sq-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .sq-header-text {
        position: relative;
        z-index: 1;
    }
    
    .sq-header-title {
        font-size: 22px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 4px;
    }
    
    .sq-header-sub {
        font-size: 13px;
        color: rgba(255,255,255,.75);
    }
    
    /* 提示条 */
    .sq-info-bar {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px 18px;
        border-radius: 10px;
        background: linear-gradient(135deg, #ecfdf5 0%, #f0fdf4 100%);
        border: 1px solid #bbf7d0;
        margin-bottom: 20px;
    }
    
    .sq-info-bar svg {
        width: 18px;
        height: 18px;
        stroke: #059669;
        fill: none;
        stroke-width: 2;
        flex-shrink: 0;
    }
    
    .sq-info-bar span {
        font-size: 12px;
        color: #047857;
        line-height: 1.5;
    }
    
    /* 卡片 */
    .sq-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,.04);
        margin-bottom: 20px;
        overflow: hidden;
        transition: box-shadow .2s, transform .2s;
    }
    
    .sq-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06);
        transform: translateY(-1px);
    }
    
    .sq-card-head {
        padding: 16px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
    }
    
    .sq-card-head .sq-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: linear-gradient(135deg, #059669, #34d399);
        flex-shrink: 0;
    }
    
    .sq-card-head h3 {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
    }
    
    .sq-card-head h3 svg {
        width: 18px;
        height: 18px;
        stroke: #059669;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .sq-card-body {
        padding: 24px 28px;
    }
    
    /* 表单 */
    .sq-form-row {
        display: flex;
        align-items: flex-start;
        gap: 16px;
        margin-bottom: 18px;
    }
    
    .sq-form-label {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        min-width: 120px;
        padding-top: 8px;
    }
    
    .sq-form-content {
        flex: 1;
    }
    
    /* 题型选择按钮组 */
    .sq-type-group {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
    }
    
    .sq-type-btn {
        padding: 12px 24px;
        border: 2px solid #e2e8f0;
        border-radius: 12px;
        background: #fff;
        color: #64748b;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        display: flex;
        align-items: center;
        gap: 10px;
        position: relative;
        overflow: hidden;
    }
    
    .sq-type-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, rgba(16,185,129,0.05), rgba(5,150,105,0.05));
        opacity: 0;
        transition: opacity 0.3s;
    }
    
    .sq-type-btn:hover {
        border-color: #10b981;
        color: #059669;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(16,185,129,0.15);
    }
    
    .sq-type-btn:hover::before {
        opacity: 1;
    }
    
    .sq-type-btn.active {
        border-color: #10b981;
        background: linear-gradient(135deg, #ecfdf5, #d1fae5);
        color: #059669;
        box-shadow: 0 4px 16px rgba(16,185,129,0.2);
    }
    
    .sq-type-btn.active::before {
        opacity: 1;
    }
    
    /* CSS图标样式 */
    .sq-type-btn .icon {
        width: 24px;
        height: 24px;
        position: relative;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    /* 单选题图标 - 圆形单选框 */
    .sq-type-btn[data-type="single"] .icon::before {
        content: '';
        width: 20px;
        height: 20px;
        border: 2.5px solid currentColor;
        border-radius: 50%;
        position: absolute;
        transition: all 0.3s;
    }
    
    .sq-type-btn[data-type="single"] .icon::after {
        content: '';
        width: 10px;
        height: 10px;
        background: currentColor;
        border-radius: 50%;
        position: absolute;
        opacity: 0;
        transform: scale(0);
        transition: all 0.3s;
    }
    
    .sq-type-btn[data-type="single"].active .icon::after {
        opacity: 1;
        transform: scale(1);
    }
    
    /* 多选题图标 - 方形复选框 */
    .sq-type-btn[data-type="multiple"] .icon::before {
        content: '';
        width: 20px;
        height: 20px;
        border: 2.5px solid currentColor;
        border-radius: 4px;
        position: absolute;
        transition: all 0.3s;
    }
    
    .sq-type-btn[data-type="multiple"] .icon::after {
        content: '';
        width: 6px;
        height: 12px;
        border-right: 3px solid currentColor;
        border-bottom: 3px solid currentColor;
        position: absolute;
        transform: rotate(45deg) scale(0);
        transform-origin: center;
        opacity: 0;
        transition: all 0.3s;
        margin-top: -3px;
    }
    
    .sq-type-btn[data-type="multiple"].active .icon::after {
        opacity: 1;
        transform: rotate(45deg) scale(1);
    }
    
    /* 判断题图标 - 对勾 */
    .sq-type-btn[data-type="judge"] .icon::before {
        content: '';
        width: 8px;
        height: 16px;
        border-right: 3px solid currentColor;
        border-bottom: 3px solid currentColor;
        position: absolute;
        transform: rotate(45deg);
        transition: all 0.3s;
    }
    
    .sq-type-btn[data-type="judge"].active .icon::before {
        animation: checkBounce 0.5s ease;
    }
    
    @keyframes checkBounce {
        0%, 100% { transform: rotate(45deg) scale(1); }
        50% { transform: rotate(45deg) scale(1.2); }
    }
    
    /* 填空题图标 - 下划线 */
    .sq-type-btn[data-type="blank"] .icon::before {
        content: '';
        width: 18px;
        height: 3px;
        background: currentColor;
        position: absolute;
        border-radius: 2px;
        transition: all 0.3s;
    }
    
    .sq-type-btn[data-type="blank"] .icon::after {
        content: '';
        width: 18px;
        height: 3px;
        background: currentColor;
        position: absolute;
        border-radius: 2px;
        margin-top: 8px;
        transition: all 0.3s;
    }
    
    .sq-type-btn[data-type="blank"].active .icon::before {
        width: 22px;
    }
    
    .sq-type-btn[data-type="blank"].active .icon::after {
        width: 14px;
    }
    
    /* 选项设置区域 */
    .sq-options-area {
        margin-top: 20px;
        padding: 20px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
    }
    
    .sq-options-title {
        font-size: 14px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .sq-option-item {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 12px;
        padding: 12px;
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
    }
    
    .sq-option-label {
        font-size: 14px;
        font-weight: 600;
        color: #64748b;
        min-width: 60px;
    }
    
    .sq-option-input {
        flex: 1;
        padding: 8px 12px;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        font-size: 14px;
        transition: all 0.2s;
    }
    
    .sq-option-input:focus {
        outline: none;
        border-color: #10b981;
        box-shadow: 0 0 0 3px rgba(16,185,129,0.1);
    }
    
    .sq-option-score {
        width: 80px;
        padding: 8px 12px;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        font-size: 14px;
        text-align: center;
    }
    
    .sq-option-score:focus {
        outline: none;
        border-color: #10b981;
        box-shadow: 0 0 0 3px rgba(16,185,129,0.1);
    }
    
    .sq-correct-check {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: #f1f5f9;
        border-radius: 6px;
        cursor: pointer;
        user-select: none;
    }
    
    .sq-correct-check input[type="checkbox"],
    .sq-correct-check input[type="radio"] {
        width: 16px;
        height: 16px;
        cursor: pointer;
    }
    
    .sq-correct-check label {
        font-size: 13px;
        color: #64748b;
        cursor: pointer;
        margin: 0;
    }
    
    /* 快速设置区 */
    .sq-quick-setup {
        margin-top: 16px;
        padding: 16px;
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
    }
    
    .sq-quick-title {
        font-size: 13px;
        font-weight: 600;
        color: #64748b;
        margin-bottom: 12px;
    }
    
    .sq-quick-btns {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    
    .sq-quick-btn {
        padding: 6px 14px;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        background: #fff;
        color: #64748b;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s;
    }
    
    .sq-quick-btn:hover {
        border-color: #10b981;
        color: #059669;
        background: #f0fdf4;
    }
    
    /* 自定义复选框 */
    .sq-check-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        user-select: none;
        padding: 8px 16px;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        transition: all 0.2s ease;
    }
    
    .sq-check-wrap:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
    }
    
    .sq-check-wrap input[type="checkbox"] {
        width: 18px;
        height: 18px;
        border-radius: 5px;
        border: 1.5px solid #d1d5db;
        appearance: none;
        -webkit-appearance: none;
        outline: none;
        cursor: pointer;
        transition: all .15s;
        position: relative;
        background: #fff;
        flex-shrink: 0;
    }
    
    .sq-check-wrap input[type="checkbox"]:checked {
        background: linear-gradient(135deg, #059669, #10b981);
        border-color: #059669;
    }
    
    .sq-check-wrap input[type="checkbox"]:checked::after {
        content: '';
        position: absolute;
        left: 5px;
        top: 2px;
        width: 5px;
        height: 9px;
        border: solid #fff;
        border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }
    
    .sq-check-wrap input[type="checkbox"]:focus {
        box-shadow: 0 0 0 3px rgba(5,150,105,.15);
    }
    
    .sq-check-wrap label {
        font-size: 13px;
        color: #475569;
        font-weight: 500;
        cursor: pointer;
    }
    
    /* 编辑器 */
    .sq-editor-wrap {
        margin-top: 10px;
    }
    
    .sq-editor-wrap .ke-container {
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 12px !important;
        overflow: hidden !important;
        box-shadow: 0 2px 8px rgba(0,0,0,.03) !important;
        transition: border-color .2s, box-shadow .2s;
    }
    
    .sq-editor-wrap .ke-container:focus-within {
        border-color: #34d399 !important;
        box-shadow: 0 0 0 4px rgba(5,150,105,.08), 0 2px 8px rgba(0,0,0,.03) !important;
    }
    
    /* 消息 */
    .sq-msg {
        font-size: 13px;
        color: #ef4444;
        margin-bottom: 14px;
        display: block;
        padding: 8px 14px;
        background: #fef2f2;
        border: 1px solid #fecaca;
        border-radius: 8px;
        text-align: center;
    }
    
    .sq-msg:empty {
        display: none;
    }
    
    /* 按钮 */
    .sq-actions {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        margin-top: 20px;
    }
    
    .sq-actions input[type="submit"] {
        padding: 10px 28px !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
        cursor: pointer;
        transition: all .2s ease;
        height: auto !important;
        width: auto !important;
        line-height: 1.4 !important;
    }
    
    .sq-actions input[type="submit"]:first-of-type {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
        color: #fff !important;
        border: none !important;
        box-shadow: 0 3px 12px rgba(5,150,105,.25) !important;
    }
    
    .sq-actions input[type="submit"]:first-of-type:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 6px 20px rgba(5,150,105,.35) !important;
        transform: translateY(-1px);
    }
    
    .sq-actions input[type="submit"]:last-of-type {
        background: #fff !important;
        color: #475569 !important;
        border: 1.5px solid #e2e8f0 !important;
    }
    
    .sq-actions input[type="submit"]:last-of-type:hover {
        background: #f8fafc !important;
        border-color: #cbd5e1 !important;
        transform: translateY(-1px);
    }
    
    /* 隐藏元素 */
    .sq-hidden {
        display: none !important;
    }
    
    /* 隐藏旧样式 */
    .cplace {
        display: none !important;
    }
</style>

<div class="sq-page">
    <!-- 渐变标题栏 -->
    <div class="sq-header">
        <div class="sq-header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                <path d="M9 12h6m-6 4h6"/>
            </svg>
        </div>
        <div class="sq-header-text">
            <div class="sq-header-title">添加调查试题</div>
            <div class="sq-header-sub">创建新的调查问题，收集学生反馈</div>
        </div>
    </div>
    
    <!-- 提示条 -->
    <div class="sq-info-bar">
        <svg viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="16" x2="12" y2="12"/>
            <line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <span><strong>重要提示：</strong>此页面只保存题目，不保存选项！题目添加成功后，请返回列表，点击题目的"编辑"链接，使用"快速添加"功能来添加选项（ABCD或正确/错误）。详细说明请查看"说明必读/题目添加完整指南.md"文件。</span>
    </div>
    
    <!-- 试题类型选择卡片 -->
    <div class="sq-card">
        <div class="sq-card-head">
            <span class="sq-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="3"/>
                    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                </svg>
                题型选择
            </h3>
        </div>
        <div class="sq-card-body">
            <div class="sq-form-row">
                <span class="sq-form-label">选择题型：</span>
                <div class="sq-form-content">
                    <div class="sq-type-group">
                        <button type="button" class="sq-type-btn active" data-type="single">
                            <span class="icon"></span>
                            <span>单选题</span>
                        </button>
                        <button type="button" class="sq-type-btn" data-type="multiple">
                            <span class="icon"></span>
                            <span>多选题</span>
                        </button>
                        <button type="button" class="sq-type-btn" data-type="judge">
                            <span class="icon"></span>
                            <span>判断题</span>
                        </button>
                        <button type="button" class="sq-type-btn" data-type="blank">
                            <span class="icon"></span>
                            <span>填空题</span>
                        </button>
                    </div>
                    
                    <!-- 隐藏字段存储题型 -->
                    <input type="hidden" id="questionType" value="single" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- 试题内容卡片 -->
    <div class="sq-card">
        <div class="sq-card-head">
            <span class="sq-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
                试题描述
            </h3>
        </div>
        <div class="sq-card-body">
            <div class="sq-editor-wrap">
                <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                <script>
                    var editor;
                    var cid = <%=myCid() %>;
                    var ty = "Course";
                    var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
                    var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?cid=' + cid + '&ty=' + ty;
                    KindEditor.ready(function (K) {
                        editor = K.create('textarea[name="ctl00$Content$mcontent"]', {
                            cssData: '.blackword{text-align: center;border:none;outline:none;border-bottom: 1px solid #999;width: 60px;display: inline-block;}',
                            resizeType: 1,
                            newlineTag: "br",
                            uploadJson: upjs,
                            fileManagerJson: fmjs,
                            allowFileManager: true,
                            filterMode: false
                        });
                    });
                </script>
                <textarea id="mcontent" runat="server" style="width:100%; height:200px;"></textarea>
            </div>
        </div>
    </div>
    
    <!-- 选项设置卡片 -->
    <div class="sq-card" id="optionsCard">
        <div class="sq-card-head">
            <span class="sq-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <path d="M9 11l3 3L22 4"/>
                    <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
                </svg>
                选项设置
            </h3>
        </div>
        <div class="sq-card-body">
            <div class="sq-options-area">
                <div class="sq-options-title">
                    <span>📋</span>
                    <span id="optionsTitle">单选题选项（请设置正确答案）</span>
                </div>
                
                <!-- 选项列表容器 -->
                <div id="optionsList"></div>
                
                <!-- 快速设置 -->
                <div class="sq-quick-setup">
                    <div class="sq-quick-title">💡 快速设置正确答案</div>
                    <div class="sq-quick-btns" id="quickAnswerBtns"></div>
                </div>
            </div>
            
            <!-- 隐藏字段存储选项数据 -->
            <input type="hidden" id="optionsData" />
        </div>
    </div>
    
    <!-- 提交卡片 -->
    <div class="sq-card">
        <div class="sq-card-head">
            <span class="sq-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <polyline points="9 11 12 14 22 4"/>
                    <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                </svg>
                提交试题
            </h3>
        </div>
        <div class="sq-card-body">
            <asp:Label ID="Labelmsg" runat="server" CssClass="sq-msg"></asp:Label>
            <div class="sq-actions">
                <asp:Button ID="BtnaddAjax" runat="server" Text="添加题目（含选项）" OnClientClick="return submitWithAjax();" CssClass="sq-btn-ajax" style="display:none;" />
                <asp:Button ID="Btnadd" runat="server" Text="添加试题" OnClick="Btnadd_Click" SkinID="BtnNormal" OnClientClick="return prepareSubmit();" />
                <asp:Button ID="BtnSurvey" runat="server" Text="返回" OnClick="BtnSurvey_Click" SkinID="BtnNormal" />
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
(function() {
    // 插入填空占位符到编辑器
    window.insertBlankPlaceholder = function() {
        if (typeof editor !== 'undefined' && editor) {
            // 插入5个下划线作为填空占位符
            editor.insertHtml('_____');
            
            // 显示成功提示
            alert('✅ 已插入填空占位符！\n\n请继续在题目中添加更多填空位置，或保存题目后在"选项"页面添加答案。');
        } else {
            alert('编辑器未就绪，请稍后再试');
        }
    };
    
    // 检查是否使用AJAX提交
    var useAjax = true; // 设置为true使用AJAX提交
    
    // 页面加载后显示/隐藏按钮
    window.addEventListener('load', function() {
        var btnAjax = document.getElementById('<%= BtnaddAjax.ClientID %>');
        var btnNormal = document.getElementById('<%= Btnadd.ClientID %>');
        
        if (useAjax && btnAjax && btnNormal) {
            btnAjax.style.display = 'inline-block';
            btnNormal.style.display = 'none';
        }
    });
    
    // AJAX提交函数
    window.submitWithAjax = function() {
        // 验证题目内容
        if (editor && editor.html().trim() === '') {
            alert('请输入试题描述！');
            return false;
        }
        
        // 如果不是填空题，验证选项
        if (currentType !== 'blank') {
            // 检查是否有空选项
            var hasEmpty = currentOptions.some(function(opt) {
                return !opt.content || opt.content.trim() === '';
            });
            
            if (hasEmpty) {
                alert('请填写所有选项内容！');
                return false;
            }
            
            // 检查是否设置了正确答案
            var hasCorrect = currentOptions.some(function(opt) {
                return opt.correct;
            });
            
            if (!hasCorrect) {
                alert('请设置正确答案！');
                return false;
            }
        }
        
        // 准备数据
        var data = {
            vid: '<%= Request.QueryString["vid"] %>',
            cid: '<%= Request.QueryString["cid"] %>',
            content: editor.html(),
            isBlank: currentType === 'blank',
            options: JSON.stringify({
                type: currentType,
                options: currentOptions
            })
        };
        
        // 显示加载提示
        var msgLabel = document.getElementById('<%= Labelmsg.ClientID %>');
        msgLabel.textContent = '正在保存，请稍候...';
        msgLabel.style.background = '#eff6ff';
        msgLabel.style.borderColor = '#bfdbfe';
        msgLabel.style.color = '#1e40af';
        
        // 禁用按钮
        var btnAjax = document.getElementById('<%= BtnaddAjax.ClientID %>');
        if (btnAjax) btnAjax.disabled = true;
        
        // 发送AJAX请求
        fetch('addquestionwithopt.aspx', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(function(response) {
            // 检查响应类型
            var contentType = response.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                // 不是JSON响应，可能是错误页面
                return response.text().then(function(text) {
                    throw new Error('服务器返回了非JSON响应。可能是页面编译错误。请检查浏览器控制台的Network标签查看详细错误。');
                });
            }
            return response.json();
        })
        .then(function(result) {
            if (result.success) {
                msgLabel.textContent = '题目和选项添加成功！';
                msgLabel.style.background = '#f0fdf4';
                msgLabel.style.borderColor = '#bbf7d0';
                msgLabel.style.color = '#166534';
                
                // 询问是否继续添加
                setTimeout(function() {
                    if (confirm('题目和选项添加成功！\n\n点击"确定"返回列表，点击"取消"继续添加下一个题目。')) {
                        window.location.href = 'survey.aspx?cid=' + data.cid + '&vid=' + data.vid;
                    } else {
                        // 清空表单
                        editor.html('');
                        msgLabel.textContent = '';
                        currentOptions = JSON.parse(JSON.stringify(questionTypes[currentType].options));
                        renderOptions();
                        if (btnAjax) btnAjax.disabled = false;
                    }
                }, 500);
            } else {
                msgLabel.textContent = '保存失败：' + result.message;
                msgLabel.style.background = '#fef2f2';
                msgLabel.style.borderColor = '#fecaca';
                msgLabel.style.color = '#991b1b';
                if (btnAjax) btnAjax.disabled = false;
            }
        })
        .catch(function(error) {
            msgLabel.textContent = '保存失败：' + error.message;
            msgLabel.style.background = '#fef2f2';
            msgLabel.style.borderColor = '#fecaca';
            msgLabel.style.color = '#991b1b';
            if (btnAjax) btnAjax.disabled = false;
        });
        
        return false; // 阻止表单提交
    };
    
    // 题型配置
    var questionTypes = {
        single: {
            title: '单选题选项（请设置正确答案）',
            options: [
                { label: 'A', content: '选项A', score: 0, correct: false },
                { label: 'B', content: '选项B', score: 0, correct: false },
                { label: 'C', content: '选项C', score: 0, correct: false },
                { label: 'D', content: '选项D', score: 0, correct: false }
            ],
            inputType: 'radio',
            quickAnswers: ['A', 'B', 'C', 'D']
        },
        multiple: {
            title: '多选题选项（可设置多个正确答案）',
            options: [
                { label: 'A', content: '选项A', score: 0, correct: false },
                { label: 'B', content: '选项B', score: 0, correct: false },
                { label: 'C', content: '选项C', score: 0, correct: false },
                { label: 'D', content: '选项D', score: 0, correct: false }
            ],
            inputType: 'checkbox',
            quickAnswers: ['A', 'B', 'C', 'D', 'AB', 'AC', 'AD', 'BC', 'BD', 'CD', 'ABC', 'ABD', 'ACD', 'BCD', 'ABCD']
        },
        judge: {
            title: '判断题选项（请设置正确答案）',
            options: [
                { label: '正确', content: '正确', score: 0, correct: false },
                { label: '错误', content: '错误', score: 0, correct: false }
            ],
            inputType: 'radio',
            quickAnswers: ['正确', '错误']
        },
        blank: {
            title: '填空题提示',
            options: [],
            inputType: 'none',
            quickAnswers: []
        }
    };
    
    var currentType = 'single';
    var currentOptions = JSON.parse(JSON.stringify(questionTypes.single.options));
    
    function isDefaultOptionText(option) {
        return option && option.content && (
            option.content === '选项A' ||
            option.content === '选项B' ||
            option.content === '选项C' ||
            option.content === '选项D'
        );
    }
    
    // 初始化
    function init() {
        renderOptions();
        bindTypeButtons();
        updateQuickAnswers();
    }
    
    // 绑定题型按钮
    function bindTypeButtons() {
        var btns = document.querySelectorAll('.sq-type-btn');
        btns.forEach(function(btn) {
            btn.addEventListener('click', function() {
                var type = this.getAttribute('data-type');
                switchType(type);
            });
        });
    }
    
    // 切换题型
    function switchType(type) {
        currentType = type;
        document.getElementById('questionType').value = type;
        
        // 更新按钮状态
        var btns = document.querySelectorAll('.sq-type-btn');
        btns.forEach(function(btn) {
            if (btn.getAttribute('data-type') === type) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
        
        // 更新选项
        currentOptions = JSON.parse(JSON.stringify(questionTypes[type].options));
        
        // 更新标题
        document.getElementById('optionsTitle').textContent = questionTypes[type].title;
        
        // 渲染选项
        renderOptions();
        
        // 更新快速答案按钮
        updateQuickAnswers();
        
        // 显示/隐藏选项卡片
        var optionsCard = document.getElementById('optionsCard');
        if (type === 'blank') {
            optionsCard.classList.add('sq-hidden');
            // 填空题自动勾选QBlack
            var qblack = document.getElementById('<%= QBlack.ClientID %>');
            if (qblack) qblack.checked = true;
        } else {
            optionsCard.classList.remove('sq-hidden');
            var qblack = document.getElementById('<%= QBlack.ClientID %>');
            if (qblack) qblack.checked = false;
        }
    }
    
    // 渲染选项列表
    function renderOptions() {
        var container = document.getElementById('optionsList');
        container.innerHTML = '';
        
        if (currentType === 'blank') {
            // 填空题：显示填空占位符插入工具
            container.innerHTML = `
                <div style="padding: 24px; background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%); border: 2px solid #fbbf24; border-radius: 12px;">
                    <div style="display: flex; align-items: flex-start; gap: 12px; margin-bottom: 16px;">
                        <svg viewBox="0 0 24 24" style="width: 24px; height: 24px; stroke: #f59e0b; fill: none; stroke-width: 2; flex-shrink: 0;">
                            <circle cx="12" cy="12" r="10"/>
                            <line x1="12" y1="16" x2="12" y2="12"/>
                            <line x1="12" y1="8" x2="12.01" y2="8"/>
                        </svg>
                        <div>
                            <div style="font-size: 15px; font-weight: 700; color: #92400e; margin-bottom: 8px;">
                                📝 填空题设置说明
                            </div>
                            <div style="font-size: 13px; color: #78350f; line-height: 1.7;">
                                填空题需要在题目内容中插入填空占位符。请按照以下步骤操作：
                            </div>
                        </div>
                    </div>
                    
                    <div style="background: #fff; border-radius: 10px; padding: 20px; margin-bottom: 16px;">
                        <div style="font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 12px;">
                            步骤1：在题目中插入填空占位符
                        </div>
                        <div style="font-size: 13px; color: #64748b; margin-bottom: 12px; line-height: 1.6;">
                            在题目编辑器中，将光标放在需要填空的位置，然后点击下方按钮插入占位符：
                        </div>
                        <button type="button" onclick="insertBlankPlaceholder()" 
                            style="padding: 10px 24px; background: linear-gradient(135deg, #f59e0b, #f97316); color: #fff; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; box-shadow: 0 2px 8px rgba(245,158,11,0.3); transition: all 0.2s;">
                            ➕ 插入填空占位符 _____
                        </button>
                    </div>
                    
                    <div style="background: #fff; border-radius: 10px; padding: 20px;">
                        <div style="font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 12px;">
                            步骤2：在"选项"页面添加答案
                        </div>
                        <div style="font-size: 13px; color: #64748b; line-height: 1.6;">
                            保存题目后，点击"选项"按钮，为每个填空添加对应的答案和分值。<br/>
                            <strong style="color: #f59e0b;">注意：</strong>答案的顺序要与题目中填空占位符的顺序一致！
                        </div>
                    </div>
                    
                    <div style="margin-top: 16px; padding: 12px 16px; background: rgba(255,255,255,0.5); border-radius: 8px; font-size: 12px; color: #78350f;">
                        <strong>示例：</strong>题目"中国的首都是_____，最大的城市是_____"需要添加2个选项答案："北京"和"上海"
                    </div>
                </div>
            `;
            return;
        }
        
        var config = questionTypes[currentType];
        
        currentOptions.forEach(function(option, index) {
            var item = document.createElement('div');
            item.className = 'sq-option-item';
            
            // 选项标签
            var label = document.createElement('div');
            label.className = 'sq-option-label';
            label.textContent = option.label;
            
            // 选项内容输入框
            var input = document.createElement('input');
            input.type = 'text';
            input.className = 'sq-option-input';
            input.placeholder = '请输入选项内容';
            input.value = option.content;
            input.setAttribute('data-index', index);
            input.addEventListener('input', function() {
                currentOptions[index].content = this.value;
            });
            input.addEventListener('focus', function() {
                if (isDefaultOptionText(currentOptions[index]) && this.value === currentOptions[index].content) {
                    this.value = '';
                    currentOptions[index].content = '';
                }
            });
            input.addEventListener('blur', function() {
                var val = this.value.replace(/^\s+|\s+$/g, '');
                if (val === '' && option.label && option.label.length === 1 && /^[A-Z]$/.test(option.label)) {
                    var defaultText = '选项' + option.label;
                    this.value = defaultText;
                    currentOptions[index].content = defaultText;
                } else {
                    currentOptions[index].content = val;
                    this.value = val;
                }
            });
            
            // 分值输入框
            var scoreInput = document.createElement('input');
            scoreInput.type = 'number';
            scoreInput.className = 'sq-option-score';
            scoreInput.placeholder = '分值';
            scoreInput.value = option.score;
            scoreInput.setAttribute('data-index', index);
            scoreInput.addEventListener('input', function() {
                currentOptions[index].score = parseFloat(this.value) || 0;
            });
            
            // 正确答案复选框
            var correctWrap = document.createElement('div');
            correctWrap.className = 'sq-correct-check';
            
            var correctInput = document.createElement('input');
            correctInput.type = config.inputType;
            correctInput.name = 'correctAnswer';
            correctInput.id = 'correct_' + index;
            correctInput.checked = option.correct;
            correctInput.setAttribute('data-index', index);
            correctInput.addEventListener('change', function() {
                if (config.inputType === 'radio') {
                    // 单选：清除其他选项
                    currentOptions.forEach(function(opt) { opt.correct = false; });
                    currentOptions[index].correct = true;
                } else {
                    // 多选
                    currentOptions[index].correct = this.checked;
                }
            });
            
            var correctLabel = document.createElement('label');
            correctLabel.setAttribute('for', 'correct_' + index);
            correctLabel.textContent = '正确';
            
            correctWrap.appendChild(correctInput);
            correctWrap.appendChild(correctLabel);
            
            item.appendChild(label);
            item.appendChild(input);
            item.appendChild(scoreInput);
            item.appendChild(correctWrap);
            
            container.appendChild(item);
        });
    }
    
    // 更新快速答案按钮
    function updateQuickAnswers() {
        var container = document.getElementById('quickAnswerBtns');
        container.innerHTML = '';
        
        if (currentType === 'blank') {
            return;
        }
        
        var config = questionTypes[currentType];
        config.quickAnswers.forEach(function(answer) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'sq-quick-btn';
            btn.textContent = answer;
            btn.addEventListener('click', function() {
                setQuickAnswer(answer);
            });
            container.appendChild(btn);
        });
    }
    
    // 快速设置答案
    function setQuickAnswer(answer) {
        // 清除所有正确答案
        currentOptions.forEach(function(opt) { opt.correct = false; });
        
        // 设置新的正确答案
        if (currentType === 'single' || currentType === 'judge') {
            // 单选或判断
            currentOptions.forEach(function(opt) {
                if (opt.label === answer) {
                    opt.correct = true;
                }
            });
        } else if (currentType === 'multiple') {
            // 多选
            for (var i = 0; i < answer.length; i++) {
                var letter = answer.charAt(i);
                currentOptions.forEach(function(opt) {
                    if (opt.label === letter) {
                        opt.correct = true;
                    }
                });
            }
        }
        
        // 重新渲染
        renderOptions();
    }
    
    // 准备提交
    window.prepareSubmit = function() {
        // 验证题目内容
        if (editor && editor.html().trim() === '') {
            alert('请输入试题描述！');
            return false;
        }
        
        // 如果不是填空题，验证选项
        if (currentType !== 'blank') {
            // 检查是否有空选项
            var hasEmpty = currentOptions.some(function(opt) {
                return !opt.content || opt.content.trim() === '';
            });
            
            if (hasEmpty) {
                alert('请填写所有选项内容！');
                return false;
            }
            
            // 检查是否设置了正确答案
            var hasCorrect = currentOptions.some(function(opt) {
                return opt.correct;
            });
            
            if (!hasCorrect) {
                alert('请设置正确答案！');
                return false;
            }
        }
        
        // 将选项数据保存到隐藏字段
        var data = {
            type: currentType,
            options: currentOptions
        };
        document.getElementById('optionsData').value = JSON.stringify(data);
        
        // 标记需要保存选项
        sessionStorage.setItem('pendingOptions', JSON.stringify(data));
        sessionStorage.setItem('pendingCid', '<%= Request.QueryString["cid"] %>');
        sessionStorage.setItem('pendingVid', '<%= Request.QueryString["vid"] %>');
        
        return true;
    };
    
    // 页面加载后检查是否需要保存选项
    function checkAndSaveOptions() {
        var pendingOptions = sessionStorage.getItem('pendingOptions');
        var pendingCid = sessionStorage.getItem('pendingCid');
        var pendingVid = sessionStorage.getItem('pendingVid');
        
        if (pendingOptions && pendingCid && pendingVid) {
            // 检查页面是否显示成功消息
            var msgLabel = document.getElementById('<%= Labelmsg.ClientID %>');
            if (msgLabel && msgLabel.textContent.indexOf('成功') > -1) {
                // 清除标记
                sessionStorage.removeItem('pendingOptions');
                sessionStorage.removeItem('pendingCid');
                sessionStorage.removeItem('pendingVid');
                
                // 获取最新添加的题目ID（从URL或其他方式）
                // 由于无法直接获取新题目ID，我们需要通过其他方式
                // 这里我们假设题目已经添加成功，用户需要手动刷新或跳转
                
                alert('题目添加成功！请点击"编辑"按钮来添加选项。');
            }
        }
    }
    
    // 页面加载完成后初始化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            init();
            setTimeout(checkAndSaveOptions, 500);
        });
    } else {
        init();
        setTimeout(checkAndSaveOptions, 500);
    }
    
    // 检查并自动保存选项
    function checkAndSaveOptions() {
        var msgLabel = document.getElementById('<%= Labelmsg.ClientID %>');
        if (!msgLabel) return;
        
        var msgText = msgLabel.textContent || msgLabel.innerText || '';
        
        // 检查是否显示成功消息
        if (msgText.indexOf('成功') > -1 || msgText.indexOf('添加') > -1) {
            // 从sessionStorage获取待保存的选项数据
            var pendingOptions = sessionStorage.getItem('pendingOptions');
            var pendingCid = sessionStorage.getItem('pendingCid');
            var pendingVid = sessionStorage.getItem('pendingVid');
            
            if (pendingOptions && pendingCid && pendingVid) {
                // 尝试从URL获取新添加的题目ID
                var urlParams = new URLSearchParams(window.location.search);
                var qid = urlParams.get('qid');
                
                if (!qid) {
                    // 如果URL中没有qid，尝试从页面中查找
                    // 这里需要根据实际情况调整
                    // 暂时显示提示让用户手动操作
                    sessionStorage.removeItem('pendingOptions');
                    sessionStorage.removeItem('pendingCid');
                    sessionStorage.removeItem('pendingVid');
                    
                    setTimeout(function() {
                        if (confirm('题目添加成功！\n\n重要提示：请点击"确定"返回列表，然后点击题目的"编辑"链接来添加选项。\n\n点击"取消"继续添加下一个题目。')) {
                            window.location.href = 'survey.aspx?cid=' + pendingCid + '&vid=' + pendingVid;
                        } else {
                            // 清空表单，准备添加下一个题目
                            if (editor) editor.html('');
                            msgLabel.textContent = '';
                            currentOptions = JSON.parse(JSON.stringify(questionTypes[currentType].options));
                            renderOptions();
                        }
                    }, 100);
                    return;
                }
                
                // 有qid，自动保存选项
                var optionsData = JSON.parse(pendingOptions);
                
                // 调用API保存选项
                saveOptionsToServer(qid, pendingVid, pendingCid, optionsData);
            }
        }
    }
    
    // 保存选项到服务器
    function saveOptionsToServer(qid, vid, cid, optionsData) {
        var data = {
            qid: qid,
            vid: vid,
            cid: cid,
            options: JSON.stringify(optionsData)
        };
        
        fetch('savequestionoptions.aspx', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(function(response) {
            return response.json();
        })
        .then(function(result) {
            // 清除sessionStorage
            sessionStorage.removeItem('pendingOptions');
            sessionStorage.removeItem('pendingCid');
            sessionStorage.removeItem('pendingVid');
            
            if (result.success) {
                alert('题目和选项添加成功！');
                // 跳转回列表
                window.location.href = 'survey.aspx?cid=' + cid + '&vid=' + vid;
            } else {
                alert('题目添加成功，但选项保存失败：' + result.message + '\n\n请手动点击"编辑"按钮添加选项。');
                window.location.href = 'survey.aspx?cid=' + cid + '&vid=' + vid;
            }
        })
        .catch(function(error) {
            // 清除sessionStorage
            sessionStorage.removeItem('pendingOptions');
            sessionStorage.removeItem('pendingCid');
            sessionStorage.removeItem('pendingVid');
            
            alert('题目添加成功，但选项保存失败：' + error.message + '\n\n请手动点击"编辑"按钮添加选项。');
            window.location.href = 'survey.aspx?cid=' + cid + '&vid=' + vid;
        });
    }
})();
</script>

<!-- 原始内容（隐藏） -->
<div class="cplace">
    <div class="cleft">
        &nbsp;调查试题描述：&nbsp;<asp:CheckBox ID="QBlack" runat="server" Text="是否填空" />
    </div>
    <div>
        <textarea id="mcontent_old" runat="server" style="width: 960px; height:200px;"></textarea>
    </div>
    <div class="placehold">
        <asp:Label ID="Labelmsg_old" runat="server"></asp:Label>
        <br />
        <br />
        友情提示：如果是填空题，请在题目内添加填空占位符，对应选项答案。<br />
        <br />
    </div>
</div>
</asp:Content>