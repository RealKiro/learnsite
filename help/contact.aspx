<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .contact-page, .contact-page * { margin-right: unset !important; margin-left: unset !important; }

    .contact-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: contactFadeIn .4s ease; padding-bottom: 40px;
    }
    @keyframes contactFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* 横幅 */
    .contact-banner {
        background: linear-gradient(135deg, #059669 0%, #0284c7 100%) !important;
        border-radius: 16px; padding: 48px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .contact-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .contact-banner-deco2 { top: auto; bottom: -50px; right: auto; left: -40px; width: 120px; height: 120px; background: rgba(255,255,255,.04); }
    .contact-banner h1 { font-size: 28px; font-weight: 700; color: #fff !important; margin: 0 0 10px !important; position: relative; z-index: 1; }
    .contact-banner p { font-size: 15px; color: rgba(255,255,255,.85) !important; margin: 0 !important; position: relative; z-index: 1; }
    .contact-banner-icon { margin-bottom: 16px; position: relative; z-index: 1; }
    .contact-banner-icon svg { width: 48px; height: 48px; stroke: rgba(255,255,255,.9); fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }

    /* 面包屑 */
    .contact-breadcrumb { display: flex !important; align-items: center; gap: 8px; margin-bottom: 28px; font-size: 13px; }
    .contact-breadcrumb a { color: #6366f1 !important; text-decoration: none !important; font-weight: 500; transition: color .15s; }
    .contact-breadcrumb a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .contact-breadcrumb span { color: #94a3b8; }
    .contact-breadcrumb .contact-bc-current { color: #475569; font-weight: 600; }

    /* 联系方式网格 */
    .contact-grid {
        display: grid !important; grid-template-columns: repeat(3, 1fr);
        gap: 20px; margin-bottom: 32px;
    }
    @media(max-width:768px) { .contact-grid { grid-template-columns: 1fr !important; } }

    .contact-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        padding: 32px 24px; text-align: center;
        transition: transform .2s ease, box-shadow .2s ease;
    }
    .contact-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(0,0,0,.08);
    }
    .contact-card-icon {
        width: 60px; height: 60px; border-radius: 16px;
        display: inline-flex !important; align-items: center; justify-content: center;
        margin-bottom: 18px;
    }
    .contact-card-icon svg {
        width: 28px; height: 28px; fill: none;
        stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
    }
    .cci-teacher { background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important; }
    .cci-teacher svg { stroke: #6366f1; }
    .cci-time { background: linear-gradient(135deg, #f0fdf4, #dcfce7) !important; }
    .cci-time svg { stroke: #16a34a; }
    .cci-place { background: linear-gradient(135deg, #fff7ed, #ffedd5) !important; }
    .cci-place svg { stroke: #ea580c; }

    .contact-card h3 { font-size: 16px; font-weight: 700; color: #1e293b !important; margin: 0 0 8px !important; }
    .contact-card p { font-size: 13px; color: #64748b !important; margin: 0 !important; line-height: 1.6; }

    /* 双栏内容 */
    .contact-content {
        display: grid !important; grid-template-columns: 1fr 1fr;
        gap: 24px;
    }
    @media(max-width:768px) { .contact-content { grid-template-columns: 1fr !important; } }

    /* 通用卡片 */
    .contact-section {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden;
    }
    .contact-section-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
    }
    .contact-sh-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .contact-sh-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .csi-steps { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .csi-steps svg { stroke: #2563eb; }
    .csi-feedback { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .csi-feedback svg { stroke: #7c3aed; }

    .contact-section-head h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 !important; }
    .contact-section-body { padding: 20px 24px; }

    /* 步骤列表 */
    .contact-steps { list-style: none !important; padding: 0 !important; margin: 0 !important; }
    .contact-step {
        display: flex !important; align-items: flex-start; gap: 14px;
        padding: 14px 0; border-bottom: 1px solid #f1f5f9;
    }
    .contact-step:last-child { border-bottom: none; }
    .contact-step-num {
        width: 32px; height: 32px; border-radius: 50%; flex-shrink: 0;
        display: flex !important; align-items: center; justify-content: center;
        font-size: 14px; font-weight: 700; margin-top: 1px;
    }
    .csn-1 { background: #eef2ff; color: #4f46e5; }
    .csn-2 { background: #f0fdf4; color: #16a34a; }
    .csn-3 { background: #fff7ed; color: #ea580c; }
    .csn-4 { background: #fdf2f8; color: #db2777; }

    .contact-step-content h4 { font-size: 14px; font-weight: 600; color: #1e293b !important; margin: 0 0 4px !important; }
    .contact-step-content p { font-size: 13px; color: #64748b !important; margin: 0 !important; line-height: 1.6; }

    /* 反馈表单 */
    .contact-form { display: flex !important; flex-direction: column; gap: 16px; }
    .contact-form.hidden { display: none !important; }
    .contact-form-group { display: flex !important; flex-direction: column; gap: 6px; }
    .contact-form-label {
        font-size: 13px; font-weight: 600; color: #334155 !important;
    }
    .contact-form-input, .contact-form-select {
        padding: 10px 14px; border-radius: 8px;
        border: 1.5px solid #e2e8f0 !important; background: #fff !important;
        font-size: 13px; color: #1e293b !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        transition: border-color .15s, box-shadow .15s;
        outline: none; width: 100%;
    }
    .contact-form-input:focus, .contact-form-select:focus {
        border-color: #6366f1 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,.1);
    }
    .contact-form-textarea {
        padding: 10px 14px; border-radius: 8px;
        border: 1.5px solid #e2e8f0 !important; background: #fff !important;
        font-size: 13px; color: #1e293b !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        transition: border-color .15s, box-shadow .15s;
        outline: none; width: 100%; min-height: 100px; resize: vertical;
    }
    .contact-form-textarea:focus {
        border-color: #6366f1 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,.1);
    }
    .contact-form-btn {
        display: inline-flex !important; align-items: center; justify-content: center; gap: 6px;
        padding: 11px 28px; border-radius: 8px; border: none !important;
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: all .15s;
        box-shadow: 0 2px 8px rgba(99,102,241,.2);
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        align-self: flex-start;
    }
    .contact-form-btn:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
        box-shadow: 0 4px 12px rgba(99,102,241,.3);
    }
    .contact-form-btn svg {
        width: 16px; height: 16px; stroke: currentColor;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* 成功提示 */
    .contact-success {
        display: none; align-items: center; gap: 10px;
        background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px;
        padding: 14px 18px;
    }
    .contact-success.show { display: flex !important; width: 100% !important; height: auto !important; background-color: #f0fdf4 !important; border: 1px solid #bbf7d0 !important; font-size: 13px !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; }
    .contact-success svg { width: 20px; height: 20px; stroke: #16a34a; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    .contact-success p { font-size: 13px; color: #15803d !important; margin: 0 !important; font-weight: 500; flex: 1; min-width: 0; }

    /* 反馈历史 */
    .feedback-history { margin-top: 32px; }
    .fh-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden;
    }
    .fh-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
    }
    .fh-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
        background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important;
    }
    .fh-head-icon svg { width: 18px; height: 18px; fill: none; stroke: #2563eb; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .fh-head h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 !important; }
    .fh-body { padding: 0; }
    .fh-empty { padding: 40px 20px; text-align: center; font-size: 13px; color: #94a3b8; }
    .fh-item {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9;
        transition: background .15s;
    }
    .fh-item:last-child { border-bottom: none; }
    .fh-item:hover { background: #fafbff; }
    .fh-item-top { display: flex !important; align-items: center; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
    .fh-tag { display: inline-flex; align-items: center; height: 24px; padding: 0 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .fh-tag-bug { background: #fef2f2; color: #dc2626; }
    .fh-tag-help { background: #eff6ff; color: #2563eb; }
    .fh-tag-suggest { background: #ecfdf5; color: #059669; }
    .fh-tag-other { background: #f8fafc; color: #64748b; }
    .fh-status { display: inline-flex; align-items: center; height: 24px; padding: 0 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .fh-status-pending { background: #fff7ed; color: #ea580c; }
    .fh-status-replied { background: #ecfdf5; color: #059669; }
    .fh-date { font-size: 12px; color: #94a3b8; margin-left: auto; }
    .fh-content {
        font-size: 13px; color: #334155; line-height: 1.8; margin-bottom: 10px;
        white-space: pre-wrap; word-break: break-word;
        background: #f8fafc; padding: 12px 16px; border-radius: 10px; border: 1px solid #f1f5f9;
    }
    .fh-reply-box {
        background: linear-gradient(135deg, #f0fdf4, #ecfdf5); border: 1px solid #bbf7d0;
        border-radius: 10px; padding: 12px 16px;
    }
    .fh-reply-label { font-size: 12px; font-weight: 600; color: #059669; margin-bottom: 6px; display: flex; align-items: center; gap: 6px; }
    .fh-reply-label svg { width: 14px; height: 14px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .fh-reply-text { font-size: 13px; color: #334155; line-height: 1.8; white-space: pre-wrap; word-break: break-word; }
    .fh-reply-date { font-size: 11px; color: #94a3b8; margin-top: 6px; }
    .fh-loading { padding: 40px 20px; text-align: center; font-size: 13px; color: #94a3b8; }

    /* 底部链接 */
    .contact-bottom {
        display: flex !important; align-items: center; justify-content: center;
        gap: 16px; margin-top: 32px; flex-wrap: wrap;
    }
    .contact-bottom-link {
        display: inline-flex !important; align-items: center; gap: 8px;
        padding: 12px 24px; border-radius: 10px;
        background: #fff !important; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        font-size: 13px; font-weight: 600; color: #475569 !important;
        text-decoration: none !important; transition: all .15s;
    }
    .contact-bottom-link:hover {
        border-color: #c7d2fe !important; background: #eef2ff !important;
        color: #4f46e5 !important; transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(99,102,241,.1);
    }
    .contact-bottom-link svg {
        width: 16px; height: 16px; stroke: currentColor;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
</style>

<div class="contact-page">
    <!-- 横幅 -->
    <div class="contact-banner">
        <div class="contact-banner-deco"></div>
        <div class="contact-banner-deco contact-banner-deco2"></div>
        <div class="contact-banner-icon">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </div>
        <h1>联系我们</h1>
        <p>遇到问题或有建议？我们随时为你提供帮助。</p>
    </div>

    <!-- 面包屑 -->
    <div class="contact-breadcrumb">
        <a href="../help/index.aspx">帮助中心</a>
        <span>/</span>
        <span class="contact-bc-current">联系我们</span>
    </div>

    <!-- 联系方式卡片 -->
    <div class="contact-grid">
        <div class="contact-card">
            <div class="contact-card-icon cci-teacher">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            </div>
            <h3>联系老师</h3>
            <p>遇到学习或操作问题<br/>请直接向班级信息技术老师求助</p>
        </div>
        <div class="contact-card">
            <div class="contact-card-icon cci-time">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <h3>服务时间</h3>
            <p>工作日 8:00 — 17:00<br/>课间和信息课时间优先响应</p>
        </div>
        <div class="contact-card">
            <div class="contact-card-icon cci-place">
                <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            </div>
            <h3>信息教室</h3>
            <p>现场操作问题欢迎到机房<br/>老师会面对面帮你解决</p>
        </div>
    </div>

    <!-- 双栏内容 -->
    <div class="contact-content">
        <!-- 求助流程 -->
        <div class="contact-section">
            <div class="contact-section-head">
                <span class="contact-sh-icon csi-steps"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                <h3>求助流程</h3>
            </div>
            <div class="contact-section-body">
                <ul class="contact-steps">
                    <li class="contact-step">
                        <span class="contact-step-num csn-1">1</span>
                        <div class="contact-step-content">
                            <h4>查找帮助文档</h4>
                            <p>先查看<a href="../help/faq.aspx" style="color:#6366f1 !important;text-decoration:none;font-weight:600;">常见问题</a>和<a href="../help/docs.aspx" style="color:#6366f1 !important;text-decoration:none;font-weight:600;">使用文档</a>，很多问题已有详细解答。</p>
                        </div>
                    </li>
                    <li class="contact-step">
                        <span class="contact-step-num csn-2">2</span>
                        <div class="contact-step-content">
                            <h4>请教身边同学</h4>
                            <p>使用小组讨论功能或直接询问身边的同学，也许他们遇到过同样的问题。</p>
                        </div>
                    </li>
                    <li class="contact-step">
                        <span class="contact-step-num csn-3">3</span>
                        <div class="contact-step-content">
                            <h4>联系老师</h4>
                            <p>如果以上方式未能解决，请在课间或信息课时间向老师求助。</p>
                        </div>
                    </li>
                    <li class="contact-step">
                        <span class="contact-step-num csn-4">4</span>
                        <div class="contact-step-content">
                            <h4>提交反馈</h4>
                            <p>你也可以通过右侧的反馈表单描述你的问题，老师会尽快处理。</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>

        <!-- 意见反馈 -->
        <div class="contact-section">
            <div class="contact-section-head">
                <span class="contact-sh-icon csi-feedback"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></span>
                <h3>意见反馈</h3>
            </div>
            <div class="contact-section-body">
                <div class="contact-success" id="contactSuccess">
                    <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    <p>感谢你的反馈！老师会尽快查看并处理。</p>
                </div>
                <div class="contact-form" id="contactForm">
                    <div class="contact-form-group">
                        <label class="contact-form-label">问题类型</label>
                        <select class="contact-form-select" id="feedbackType">
                            <option value="">请选择问题类型</option>
                            <option value="bug">功能异常 / Bug</option>
                            <option value="help">操作求助</option>
                            <option value="suggest">功能建议</option>
                            <option value="other">其他问题</option>
                        </select>
                    </div>
                    <div class="contact-form-group">
                        <label class="contact-form-label">问题描述</label>
                        <textarea class="contact-form-textarea" id="feedbackContent" placeholder="请详细描述你遇到的问题或建议，包括操作步骤和错误信息..."></textarea>
                    </div>
                    <button type="button" class="contact-form-btn" onclick="submitFeedback()">
                        <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                        提交反馈
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- 反馈历史 -->
    <div class="feedback-history">
        <div class="fh-card">
            <div class="fh-head">
                <span class="fh-head-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></span>
                <h3>我的反馈记录</h3>
            </div>
            <div class="fh-body" id="feedbackHistory">
                <div class="fh-loading">加载中...</div>
            </div>
        </div>
    </div>

    <!-- 底部快捷链接 -->
    <div class="contact-bottom">
        <a href="../help/index.aspx" class="contact-bottom-link">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            帮助中心
        </a>
        <a href="../help/docs.aspx" class="contact-bottom-link">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            使用文档
        </a>
        <a href="../help/faq.aspx" class="contact-bottom-link">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            常见问题
        </a>
        <a href="../student/myinfo.aspx" class="contact-bottom-link">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            返回主页
        </a>
    </div>
</div>

<script type="text/javascript">
    function submitFeedback() {
        var type = document.getElementById('feedbackType').value;
        var content = document.getElementById('feedbackContent').value.trim();

        if (!type) {
            alert('请选择问题类型');
            return;
        }
        if (!content) {
            alert('请填写问题描述');
            return;
        }

        var btn = document.querySelector('.contact-form-btn');
        btn.disabled = true;
        btn.style.opacity = '0.6';

        var xhr = new XMLHttpRequest();
        xhr.open('POST', '../help/feedback_handler.ashx?action=submit', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                btn.disabled = false;
                btn.style.opacity = '1';
                try {
                    var res = JSON.parse(xhr.responseText);
                    if (res.success === 1) {
                        document.getElementById('contactForm').classList.add('hidden');
                        document.getElementById('contactSuccess').classList.add('show');
                        loadFeedbackHistory();
                        setTimeout(function () {
                            document.getElementById('contactSuccess').classList.remove('show');
                            document.getElementById('contactForm').classList.remove('hidden');
                            document.getElementById('feedbackType').value = '';
                            document.getElementById('feedbackContent').value = '';
                        }, 5000);
                    } else {
                        alert(res.message || '提交失败，请稍后重试');
                    }
                } catch (e) {
                    alert('提交失败，请稍后重试');
                }
            }
        };
        xhr.send('type=' + encodeURIComponent(type) + '&content=' + encodeURIComponent(content));
    }

    var typeLabels = { 'bug': '功能异常', 'help': '操作求助', 'suggest': '功能建议', 'other': '其他问题' };
    var typeCss = { 'bug': 'fh-tag-bug', 'help': 'fh-tag-help', 'suggest': 'fh-tag-suggest', 'other': 'fh-tag-other' };

    function escapeHtml(s) {
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(s));
        return d.innerHTML;
    }

    function loadFeedbackHistory() {
        var container = document.getElementById('feedbackHistory');
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '../help/feedback_handler.ashx?action=list', true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                try {
                    var res = JSON.parse(xhr.responseText);
                    if (res.success === 1 && res.data && res.data.length > 0) {
                        var html = '';
                        for (var i = 0; i < res.data.length; i++) {
                            var item = res.data[i];
                            var tagClass = typeCss[item.type] || 'fh-tag-other';
                            var tagLabel = typeLabels[item.type] || item.type;
                            var statusClass = item.status === 'replied' ? 'fh-status-replied' : 'fh-status-pending';
                            var statusLabel = item.status === 'replied' ? '已回复' : '待回复';

                            html += '<div class="fh-item">';
                            html += '<div class="fh-item-top">';
                            html += '<span class="fh-tag ' + tagClass + '">' + escapeHtml(tagLabel) + '</span>';
                            html += '<span class="fh-status ' + statusClass + '">' + statusLabel + '</span>';
                            html += '<span class="fh-date">' + escapeHtml(item.submitDate) + '</span>';
                            html += '</div>';
                            html += '<div class="fh-content">' + escapeHtml(item.content) + '</div>';
                            if (item.status === 'replied' && item.reply) {
                                html += '<div class="fh-reply-box">';
                                html += '<div class="fh-reply-label"><svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>管理员回复</div>';
                                html += '<div class="fh-reply-text">' + escapeHtml(item.reply) + '</div>';
                                if (item.replyDate) {
                                    html += '<div class="fh-reply-date">' + escapeHtml(item.replyDate) + '</div>';
                                }
                                html += '</div>';
                            }
                            html += '</div>';
                        }
                        container.innerHTML = html;
                    } else if (res.success === 1) {
                        container.innerHTML = '<div class="fh-empty">暂无反馈记录，提交反馈后可在这里查看</div>';
                    } else {
                        container.innerHTML = '<div class="fh-empty">' + escapeHtml(res.message || '加载失败') + '</div>';
                    }
                } catch (e) {
                    container.innerHTML = '<div class="fh-empty">加载失败</div>';
                }
            }
        };
        xhr.send();
    }

    // 页面加载时获取反馈历史
    loadFeedbackHistory();
</script>
</asp:Content>
