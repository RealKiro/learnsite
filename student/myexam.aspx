<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" CodeFile="myexam.aspx.cs" inherits="student_myexam" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<style>
    .me-page * { margin-right: unset !important; margin-left: unset !important; }
    .me-page { width: 100%; max-width: 1200px; margin: 0 24px 0 270px !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: meFadeIn .4s ease; }
    @keyframes meFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* ======== 左侧固定侧栏 ======== */
    .me-sidebar { position: fixed; left: 12px; top: 96px; width: 245px; z-index: 1002; display: flex; flex-direction: column; gap: 14px; animation: meFadeIn .4s ease; }

    /* 侧栏卡片通用 */
    .me-side-card { background: #fff; border-radius: 14px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; }
    .me-side-title { font-size: 13px; font-weight: 700; color: #64748b; padding: 14px 16px 8px; letter-spacing: .5px; }

    /* 考试信息 */
    .me-exam-stats { padding: 0 16px 14px; display: flex; flex-direction: column; gap: 10px; }
    .me-stat-row { display: flex; align-items: center; gap: 10px; }
    .me-stat-icon { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; box-shadow: 0 2px 6px rgba(0,0,0,.06); }
    .me-stat-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .me-stat-icon-time { background: linear-gradient(135deg, #dbeafe, #93c5fd); }
    .me-stat-icon-time svg { stroke: #2563eb; }
    .me-stat-icon-score { background: linear-gradient(135deg, #fef3c7, #fcd34d); }
    .me-stat-icon-score svg { stroke: #d97706; }
    .me-stat-icon-count { background: linear-gradient(135deg, #d1fae5, #6ee7b7); }
    .me-stat-icon-count svg { stroke: #059669; }
    .me-stat-text { flex: 1; }
    .me-stat-label { font-size: 12px; color: #94a3b8; line-height: 1.3; }
    .me-stat-val { font-size: 15px; font-weight: 700; color: #1e293b; line-height: 1.4; }

    /* 倒计时 */
    .me-countdown-bar { margin: 0 16px 14px; padding: 10px 8px 12px; border-radius: 12px; text-align: center; background: #fff; }
    .me-countdown-label { font-size: 10px; color: #94a3b8; font-weight: 600; letter-spacing: 1px; margin-bottom: 6px; }
    .me-countdown-digits { display: flex; align-items: center; justify-content: center; gap: 4px; }
    .me-cd-block { background: #f1f5f9; border-radius: 8px; padding: 4px 0; min-width: 44px; display: flex; flex-direction: column; align-items: center; }
    .me-cd-num { font-size: 20px; font-weight: 800; color: #1e40af; font-variant-numeric: tabular-nums; line-height: 1.2; }
    .me-cd-unit { font-size: 9px; color: #94a3b8; font-weight: 500; margin-top: 1px; }
    .me-cd-colon { font-size: 18px; font-weight: 700; color: #cbd5e1; line-height: 1; padding-bottom: 10px; }
    .me-countdown-bar.me-danger { background: #fef2f2; border-color: #fecaca; }
    .me-countdown-bar.me-danger .me-cd-block { background: #fee2e2; }
    .me-countdown-bar.me-danger .me-cd-num { color: #dc2626; }
    .me-countdown-bar.me-danger .me-cd-colon { color: #fca5a5; }

    /* 题号导航 */
    .me-nav-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 6px; padding: 0 16px 14px; }
    .me-nav-btn { width: 100%; aspect-ratio: 1; border: 1.5px solid #e2e8f0; border-radius: 8px; background: #fff; color: #475569; font-size: 13px; font-weight: 600; cursor: pointer; transition: all .15s; display: flex; align-items: center; justify-content: center; }
    .me-nav-btn:hover { border-color: #3b82f6; color: #2563eb; background: #eff6ff; transform: scale(1.08); }
    .me-nav-btn.me-nav-active { border-color: #3b82f6; background: #2563eb; color: #fff; box-shadow: 0 2px 8px rgba(37,99,235,.3); }
    .me-nav-btn.me-nav-done { border-color: #10b981; background: #d1fae5; color: #059669; }


    /* 卡片 */
    .me-card {
        position: relative;
        background: radial-gradient(circle at top left, #f9fafb 0, #ffffff 45%) !important;
        border-radius: 18px;
        border: 1px solid #e5e7eb !important;
        box-shadow: none;
        margin-bottom: 24px;
        overflow: hidden;
        transition: border-color .18s ease;
    }
    .me-page > #student > .me-card:first-child {
        margin-top: 50px;
    }
    .me-card:hover {
        transform: none;
        box-shadow: none;
        border-color: #d1d5db !important;
    }
    .me-card-head {
        padding: 18px 26px;
        border-bottom: 1px solid #eef2f7 !important;
        display: flex !important;
        align-items: center;
        gap: 14px;
        background: linear-gradient(135deg, rgba(239, 246, 255, .9), #ffffff) !important;
    }
    .me-card-head .me-head-icon {
        width: 44px;
        height: 44px;
        border-radius: 14px;
        display: flex !important;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 8px 18px rgba(37, 99, 235, .18);
    }
    .me-head-icon svg { width: 22px; height: 22px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .me-head-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .me-head-icon-blue svg { stroke: #2563eb !important; }
    .me-head-icon-teal { background: linear-gradient(135deg, #ccfbf1, #99f6e4) !important; }
    .me-head-icon-teal svg { stroke: #0d9488 !important; }
    .me-card-head h3 { font-size: 16px !important; font-weight: 700; color: #0f172a !important; margin: 0 !important; flex: 1; }
    .me-card-body { padding: 18px 24px 20px; }

    /* 信息栏 */
    .me-info-bar { display: flex; flex-wrap: wrap; row-gap: 10px; column-gap: 32px; align-items: center; justify-content: space-between; }
    .me-info-item { display: flex; align-items: center; gap: 6px; font-size: 14px; color: #475569; }
    .me-info-label { color: #94a3b8; font-size: 13px; }
    .me-info-value { color: #1e293b; font-weight: 600; }
    
    /* 已提交状态标签 - 全新设计 */
    .me-info-check {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 20px;
        border-radius: 24px;
        background: linear-gradient(135deg, #10b981, #059669);
        border: none;
        color: #fff;
        font-weight: 700;
        font-size: 14px;
        white-space: nowrap;
        box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4), 0 0 0 3px rgba(16, 185, 129, 0.1);
        position: relative;
        overflow: hidden;
        animation: checkPulse 2s ease-in-out infinite;
    }
    
    .me-info-check::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 100%;
        height: 100%;
        background: radial-gradient(circle, rgba(255,255,255,0.3) 0%, transparent 70%);
        transform: translate(-50%, -50%) scale(0);
        animation: checkRipple 2s ease-out infinite;
    }
    
    .me-info-check-icon {
        width: 20px;
        height: 20px;
        background: rgba(255, 255, 255, 0.3);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    
    .me-info-check-icon svg {
        width: 12px;
        height: 12px;
        stroke: #fff;
        fill: none;
        stroke-width: 3;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    @keyframes checkPulse {
        0%, 100% { box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4), 0 0 0 3px rgba(16, 185, 129, 0.1); }
        50% { box-shadow: 0 4px 20px rgba(16, 185, 129, 0.6), 0 0 0 6px rgba(16, 185, 129, 0.15); }
    }
    
    @keyframes checkRipple {
        0% { transform: translate(-50%, -50%) scale(0); opacity: 1; }
        100% { transform: translate(-50%, -50%) scale(2); opacity: 0; }
    }

    /* 内容区 */
    .me-vcontent { text-align: left; padding: 12px 0; line-height: 1.8; color: #334155; }
    .me-vcontent img { max-width: 100%; height: auto; border-radius: 8px; }

    /* 题目区 */
    .me-quiz-area { text-align: left; }
    #questionPage { overflow: auto; text-align: left; }
    .me-page .quizquestion { font-size: 15px; margin: 0; padding: 16px 22px; border: none; border-bottom: 1px solid #f1f5f9; transition: background .15s; scroll-margin-top: 16px; }
    .me-page .quizquestion:last-child { border-bottom: none; }
    .me-page .quizquestion:hover { background: #f8fafc; }
    .me-page .quiztitle { padding: 0 0 10px 0; margin: 0; font-family: 'Microsoft YaHei',sans-serif; font-size: 14.5px; font-weight: 600; color: #1e293b; line-height: 1.7; }
    .me-page .quizraido { padding-left: 28px; margin: 6px 0; font-family: 'Microsoft YaHei',sans-serif; font-size: 14px; color: #475569; line-height: 1.6; display: inline-block; width: 50%; vertical-align: top; box-sizing: border-box !important; }
    .me-page .quizraido input[type="radio"] { margin-right: 8px; accent-color: #2563eb; width: 16px; height: 16px; vertical-align: middle; }
    .me-page .blackword { border: none; outline: none; border-bottom: 2px solid #cbd5e1; display: inline-block; background: #f8fafc; overflow: hidden; text-align: center; white-space: nowrap; width: 100px; font-size: 14px; padding: 4px 8px; border-radius: 4px 4px 0 0; transition: border-color .2s; }
    .me-page .blackword:focus { border-bottom-color: #2563eb; background: #eff6ff; }

    /* 提交按钮 */
    .me-submit-wrap { text-align: center; padding: 20px 22px; }
    .me-btn-submit { display: inline-flex; align-items: center; justify-content: center; gap: 8px; min-width: 180px; padding: 13px 32px; border-radius: 12px; border: none; background: linear-gradient(135deg, #3b82f6, #2563eb); color: #fff; font-size: 15px; font-weight: 600; cursor: pointer; transition: all .15s; box-shadow: 0 4px 14px rgba(37,99,235,.25); font-family: 'Microsoft YaHei',sans-serif; letter-spacing: 1px; }
    .me-btn-submit:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(37,99,235,.35); }
    .me-btn-submit:disabled { background: linear-gradient(135deg, #94a3b8, #64748b); cursor: not-allowed; transform: none; box-shadow: none; }

    /* 空状态 */
    .me-empty { text-align: center; padding: 48px 20px; color: #94a3b8; }
    .me-empty-icon { font-size: 48px; margin-bottom: 12px; }
    .me-empty-text { font-size: 15px; }

    /* 隐藏控件 */
    .me-hidden { display: none !important; }

    /* 覆盖旧样式 */
    .me-page #student { margin: 0 !important; padding: 0 !important; text-align: left !important; font-size: 14px !important; }
    .me-page .linedashed { border: none; padding: 0; }
    .me-page .vcontent { width: 100% !important; margin: 0; padding: 0; }
    .me-page .quizarea { width: 100% !important; margin: 0; padding: 0; box-shadow: none; }
    .me-page .btnsubmit { text-align: center; padding: 0; }
    .me-page .btnwidth { display: none; }

    /* 考试页面：隐藏原 .menu，彻底覆盖 Scm.master + StyleSheet.css 中 :has(.menu) 的全部布局规则 */
    body:has(.me-sidebar) .menu { display: none !important; }
    body:has(.me-sidebar) { padding-left: 0 !important; }
    body:has(.me-sidebar) > center { text-align: left !important; }
    body:has(.me-sidebar) .studmasterhead { padding-left: 0 !important; margin-left: 0 !important; width: 100% !important; }
    body:has(.me-sidebar) .stu { margin-left: 0 !important; width: 100% !important; overflow: visible !important; }
    body:has(.me-sidebar) .stu > center { display: block !important; text-align: left !important; }
    body:has(.me-sidebar) .placeauto { width: 100% !important; max-width: 100% !important; margin: 0 !important; }
    body:has(.me-sidebar) .path { display: none !important; }
    
    /* 确保小组讨论和人工智能对话按钮显示 */
    body:has(.me-sidebar) .chatimg,
    body:has(.me-sidebar) .robotimg {
        display: block !important;
        visibility: visible !important;
        opacity: 0.3 !important;
        z-index: 99999 !important;
    }
    body:has(.me-sidebar) .chatimg:hover,
    body:has(.me-sidebar) .robotimg:hover {
        opacity: 1 !important;
    }
    
    /* 多选 checkbox */
    .me-page .quizraido input[type="checkbox"] { margin-right: 8px; accent-color: #2563eb; width: 16px; height: 16px; vertical-align: middle; }

    /* 题型标签 */
    .me-type-badge { display: inline-block; font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 4px; margin-right: 6px; vertical-align: middle; line-height: 1.6; }
    .me-type-badge.me-tb-choice { background: #dbeafe; color: #1d4ed8; }
    .me-type-badge.me-tb-multi { background: #fce7f3; color: #be185d; }
    .me-type-badge.me-tb-judge { background: #ede9fe; color: #6d28d9; }
    .me-type-badge.me-tb-fill { background: #fef3c7; color: #b45309; }
    .me-type-badge.me-tb-essay { background: #d1fae5; color: #065f46; }
    .me-type-badge.me-tb-scratch { background: #fed7aa; color: #c2410c; }
    .me-type-badge.me-tb-python { background: #c7d2fe; color: #4338ca; }
    .me-type-badge.me-tb-pythonblock { background: #a7f3d0; color: #047857; }

    /* 问答 textarea */
    .me-essay-wrap { padding: 4px 28px 8px; }
    .me-essay-input { width: 100%; min-height: 120px; border: 2px solid #e2e8f0; border-radius: 10px; padding: 12px 14px; font-size: 14px; font-family: 'Microsoft YaHei',sans-serif; line-height: 1.7; resize: vertical; transition: border-color .2s; background: #f8fafc; box-sizing: border-box; }
    .me-essay-input:focus { outline: none; border-color: #3b82f6; background: #fff; }

    /* 编程题 "去作答" 按钮 */
    .me-coding-wrap { padding: 8px 28px 8px; display: flex; align-items: center; gap: 14px; }
    .me-coding-btn { display: inline-flex; align-items: center; gap: 10px; padding: 12px 28px; border-radius: 12px; text-decoration: none; font-size: 15px; font-weight: 700; color: #fff; transition: all .2s; box-shadow: 0 4px 14px rgba(0,0,0,.15); letter-spacing: 1px; }
    .me-coding-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,.2); color: #fff; text-decoration: none; }
    .me-coding-btn svg { width: 22px; height: 22px; }
    .me-coding-scratch { background: linear-gradient(135deg, #f59e0b, #f97316); }
    .me-coding-python { background: linear-gradient(135deg, #6366f1, #8b5cf6); }
    .me-coding-pythonblock { background: linear-gradient(135deg, #10b981, #059669); }
    .me-coding-status { font-size: 13px; color: #94a3b8; font-weight: 500; }
    .me-coding-status.me-done { color: #10b981; font-weight: 600; }
    .me-coding-edit { background: linear-gradient(135deg, #3b82f6, #2563eb); }
    .me-coding-btn-hidden { display: none !important; }

    /* 已提交状态页 */
    #meDonePage { display: none; }
    .me-done-page { 
        display: flex; 
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center; 
        padding: 60px 20px 40px;
    }
    .me-done-icon { 
        width: 88px; 
        height: 88px; 
        border-radius: 50%; 
        background: linear-gradient(135deg, #10b981, #34d399); 
        display: flex !important; 
        align-items: center; 
        justify-content: center; 
        margin: 0 0 24px 0; 
        box-shadow: 0 8px 30px rgba(16,185,129,.3); 
    }
    .me-done-icon svg { width: 44px; height: 44px; stroke: #fff; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
    .me-done-title { font-size: 22px; font-weight: 700; color: #1e293b; margin-bottom: 8px; }
    .me-done-desc { font-size: 14px; color: #64748b; margin-bottom: 28px; line-height: 1.6; }
    .me-done-score { display: inline-block; padding: 12px 32px; border-radius: 12px; background: #f0fdf4; border: 1px solid #bbf7d0; font-size: 18px; font-weight: 700; color: #059669; margin-bottom: 24px; }
    .me-done-back { display: inline-flex; align-items: center; gap: 6px; padding: 10px 24px; border-radius: 10px; background: #f1f5f9; color: #475569; font-size: 14px; font-weight: 500; text-decoration: none; transition: all .15s; border: 1px solid #e2e8f0; }
    .me-done-back:hover { background: #e2e8f0; color: #1e293b; text-decoration: none; }

    /* 响应式：小屏幕隐藏固定侧栏 */
    @media (max-width: 900px) {
        .me-sidebar { display: none; }
    }
</style>

<div class="me-page">
<div id="student">
    <!-- 标题卡片（全宽） -->
    <div class="me-card" id="meTitleCard">
        <div class="me-card-head">
            <span class="me-head-icon me-head-icon-blue"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></span>
            <h3>
                <asp:Image ID="Image1" runat="server" ImageUrl="~/images/clock.gif" style="display:none;" />
                <asp:Label runat="server" ID="Lbtitle" Font-Bold="True"></asp:Label>
            </h3>
        </div>
        <div class="me-card-body">
            <div class="me-info-bar">
                <div class="me-info-item">
                    <span class="me-info-label">姓名：</span>
                    <span class="me-info-value"><asp:Label runat="server" ID="Lbsname"></asp:Label></span>
                </div>
                <div class="me-info-item">
                    <span class="me-info-label">学号：</span>
                    <span class="me-info-value"><asp:Label runat="server" ID="Lbsnum"></asp:Label></span>
                </div>
                <div class="me-info-item">
                    <span class="me-info-label">得分：</span>
                    <span class="me-info-value"><asp:Label runat="server" ID="Lbfscore"></asp:Label></span>
                </div>
                <div class="me-info-item">
                    <span class="me-info-label">类型：</span>
                    <span class="me-info-value"><asp:Label runat="server" ID="Lbtypecn"></asp:Label></span>
                </div>
                <span class="me-info-check" id="meInfoCheck" style="display:none;">
                    <span class="me-info-check-icon">
                        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    </span>
                    <asp:Label runat="server" ID="Lbcheck"></asp:Label>
                </span>
            </div>
            <asp:Label runat="server" ID="Lbtype" Visible="False"></asp:Label>
            <asp:Label ID="LabelCid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelVid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelVtotal" runat="server" Visible="False"></asp:Label>
            <asp:HyperLink ID="Hkscore" runat="server" Target="_blank" Visible="False"
                CssClass="buttonimg" ImageUrl="~/images/vote.png" ToolTip="成绩分析"></asp:HyperLink>
        </div>
    </div>

    <!-- 已提交状态页 -->
    <div class="me-card" id="meDonePage">
        <div class="me-done-page">
            <div class="me-done-icon"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div>
            <div class="me-done-title">答卷已提交</div>
            <div class="me-done-desc">您的答卷已成功提交，请耐心等待老师批改。</div>
            <div class="me-done-score" id="meDoneScore" style="display:none;"></div>
            <div><a href="../student/myinfo.aspx" class="me-done-back">← 返回学习中心</a></div>
        </div>
    </div>

    <!-- 内容区域（全宽） -->
    <div id="vcontent" runat="server" class="me-vcontent"></div>

    <!-- 左侧固定侧栏 -->
    <div class="me-sidebar">
            <!-- 考试信息卡 -->
            <div class="me-side-card">
                <div class="me-side-title">考试信息</div>
                <div class="me-exam-stats">
                    <div class="me-stat-row">
                        <div class="me-stat-icon me-stat-icon-time"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                        <div class="me-stat-text">
                            <div class="me-stat-label">考试时长</div>
                            <div class="me-stat-val" id="meStatTime">--</div>
                        </div>
                    </div>
                    <div class="me-stat-row">
                        <div class="me-stat-icon me-stat-icon-score"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
                        <div class="me-stat-text">
                            <div class="me-stat-label">总分</div>
                            <div class="me-stat-val" id="meStatScore">--</div>
                        </div>
                    </div>
                    <div class="me-stat-row">
                        <div class="me-stat-icon me-stat-icon-count"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></div>
                        <div class="me-stat-text">
                            <div class="me-stat-label">题目数量</div>
                            <div class="me-stat-val" id="meStatCount">--</div>
                        </div>
                    </div>
                </div>
                <!-- 倒计时 -->
                <div class="me-countdown-bar" id="meCountdown" style="display:none;">
                    <div class="me-countdown-label">剩余时间</div>
                    <div class="me-countdown-digits">
                        <div class="me-cd-block"><span class="me-cd-num" id="meCdH">00</span><span class="me-cd-unit">时</span></div>
                        <span class="me-cd-colon">:</span>
                        <div class="me-cd-block"><span class="me-cd-num" id="meCdM">00</span><span class="me-cd-unit">分</span></div>
                        <span class="me-cd-colon">:</span>
                        <div class="me-cd-block"><span class="me-cd-num" id="meCdS">00</span><span class="me-cd-unit">秒</span></div>
                    </div>
                </div>
            </div>

            <!-- 题号导航卡 -->
            <div class="me-side-card">
                <div class="me-side-title">题号导航</div>
                <div class="me-nav-grid" id="meNavGrid"></div>
            </div>
    </div>

    <!-- 题目卡片 -->
    <div class="me-card" id="meQuizCard">
                <div class="me-card-head">
                    <span class="me-head-icon me-head-icon-teal"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                    <h3>答题区域</h3>
                </div>
        <div class="me-quiz-area">
            <div class="quizarea">
                <div id="questionPage"></div>
            </div>
        </div>
        <div class="me-submit-wrap">
            <input id="btnupload" class="me-btn-submit" type="submit" value="✦ 提交答卷" />
        </div>
    </div>
</div>
</div>

<script type="text/javascript" > 
	// ===== 后端数据 =====
	var jsonstr = "<%=questionList %>";
	var isclose = "<%=isClose %>";
	var lidstr = "<%=Lidstr %>";
	var cidstr = "<%=Cidstr %>";
	var vidstr = "<%=Vidstr %>";
	var vtypestr = "<%=Vtypestr %>";
	var isdone = "<%=isDone %>";
	var snumstr = "<%=snumStr %>";
	var _paperTime = parseInt("<%=paperTime %>") || 0;
	var _paperScore = parseInt("<%=paperScore %>") || 0;
	var _paperCount = parseInt("<%=paperCount %>") || 0;
	var _examEnd = "<%=examEnd %>";
	var _examSource = "<%=examSource %>";
	
	console.log('=== 页面加载信息 ===');
	console.log('vidstr:', vidstr);
	console.log('snumstr:', snumstr);
	console.log('_examSource:', _examSource);
	console.log('_paperCount:', _paperCount);
	console.log('isdone:', isdone);
	console.log('isclose:', isclose);

	var jsonquestion = [];
	var qcount = 0;
	try {
		if (jsonstr && jsonstr.length > 0) {
			jsonquestion = JSON.parse(Decode64(jsonstr));
			qcount = parseInt(jsonquestion.length);
		}
	} catch(e) {
		console.warn('题目数据解析失败:', e);
	}

	var div = document.getElementById('questionPage');
	var btnupload = document.getElementById('btnupload');
	var htmlstr = "";
	var idList = [];
	var scoreList = [];
	// 题目 Qid 列表，用于导航
	var qidList = [];

	function toBool(str) {
		if (str === "true" || str === "1" || (str && str.toLowerCase() === "true")) return true;
		if (str === "false" || str === "0" || (str && str.toLowerCase() === "false")) return false;
		return null;
	}

	if(toBool(isclose)||toBool(isdone)){
		btnupload.disabled = true;
	}

	// ===== 已提交状态：隐藏考试内容，显示已提交页 =====
	function showDonePage(scoreText) {
		console.log('=== showDonePage 被调用 ===');
		console.log('scoreText:', scoreText);
		
		var sidebar = document.querySelector('.me-sidebar');
		var titleCard = document.getElementById('meTitleCard');
		var doneCard = document.getElementById('meDonePage');
		var vcontentEl = document.getElementById('vcontent');
		var quizCard = document.getElementById('meQuizCard');
		
		console.log('找到的元素:');
		console.log('- sidebar:', sidebar);
		console.log('- titleCard:', titleCard);
		console.log('- doneCard:', doneCard);
		console.log('- vcontentEl:', vcontentEl);
		console.log('- quizCard:', quizCard);
		
		// 隐藏侧边栏（考试信息和题号导航）
		if (sidebar) {
			sidebar.style.display = 'none';
			console.log('隐藏侧边栏');
		}
		
		// 隐藏内容区域
		if (vcontentEl) {
			vcontentEl.style.display = 'none';
			console.log('隐藏内容区域');
		}
		
		// 隐藏题目卡片
		if (quizCard) {
			quizCard.style.display = 'none';
			console.log('隐藏题目卡片');
		}
		
		// 确保标题卡片显示
		if (titleCard) {
			titleCard.style.display = 'block';
			console.log('显示标题卡片');
		}
		
		// 显示已提交状态页
		if (doneCard) { 
			doneCard.style.display = 'block';
			console.log('显示 doneCard，设置为 block');
			
			var donePage = doneCard.querySelector('.me-done-page');
			if (donePage) {
				donePage.style.display = 'flex';
				console.log('显示 donePage，设置为 flex');
			} else {
				console.error('未找到 .me-done-page 元素！');
			}
		} else {
			console.error('未找到 meDonePage 元素！');
		}
		
		// 显示得分
		if (scoreText) {
			var scoreEl = document.getElementById('meDoneScore');
			if (scoreEl) { 
				scoreEl.textContent = '得分：' + scoreText; 
				scoreEl.style.display = 'inline-block';
				console.log('显示得分:', scoreText);
			}
		}
		
		console.log('=== showDonePage 执行完成 ===');
	}
	if (toBool(isdone)) {
		var doneScoreText = '';
		try { var lbfs = document.querySelector('#Lbfscore'); if (lbfs) doneScoreText = lbfs.textContent || lbfs.innerText; } catch(e2){}
		// 延迟执行showDonePage，确保DOM完全加载
		setTimeout(function() {
			console.log('=== 显示已提交页面 ===');
			console.log('doneScoreText:', doneScoreText);
			console.log('meDonePage元素:', document.getElementById('meDonePage'));
			showDonePage(doneScoreText);
			// 再次确认显示状态
			setTimeout(function() {
				var doneCard = document.getElementById('meDonePage');
				var donePage = doneCard ? doneCard.querySelector('.me-done-page') : null;
				console.log('显示后检查 - doneCard display:', doneCard ? doneCard.style.display : 'null');
				console.log('显示后检查 - donePage display:', donePage ? donePage.style.display : 'null');
			}, 200);
		}, 100);
	}

	if (qcount === 0) {
		var emptyDiv = document.getElementById('meQuizCard');
		if (emptyDiv) {
			var quizBody = emptyDiv.querySelector('.me-quiz-area');
			if (quizBody) quizBody.innerHTML = '<div class="me-empty"><div class="me-empty-icon">📋</div><div class="me-empty-text">暂无题目数据</div></div>';
		}
	}

	// ===== 侧栏：考试信息填充 =====
	(function initSidebar() {
		var elTime = document.getElementById('meStatTime');
		var elScore = document.getElementById('meStatScore');
		var elCount = document.getElementById('meStatCount');
		if (elTime) elTime.textContent = _paperTime > 0 ? _paperTime + ' 分钟' : '--';
		if (elScore) elScore.textContent = _paperScore > 0 ? _paperScore + ' 分' : '--';
		var displayCount = qcount > 0 ? qcount : (_paperCount > 0 ? _paperCount : 0);
		if (elCount) elCount.textContent = displayCount > 0 ? displayCount + ' 题' : '--';
	})();

	// ===== 侧栏：倒计时（按 paperTime 总时长倒计） =====
	(function initCountdown() {
		if (_paperTime <= 0) return;
		var cdBar = document.getElementById('meCountdown');
		var elH = document.getElementById('meCdH');
		var elM = document.getElementById('meCdM');
		var elS = document.getElementById('meCdS');
		if (!cdBar || !elH || !elM || !elS) return;
		cdBar.style.display = '';

		// 从页面加载时开始计时，倒计 paperTime 分钟
		var endTime = new Date().getTime() + _paperTime * 60000;

		function pad(n) { return n < 10 ? '0' + n : '' + n; }
		function tick() {
			var diff = endTime - new Date().getTime();
			if (diff <= 0) {
				elH.textContent = '00'; elM.textContent = '00'; elS.textContent = '00';
				cdBar.classList.add('me-danger');
				btnupload.disabled = true;
				return;
			}
			elH.textContent = pad(Math.floor(diff / 3600000));
			elM.textContent = pad(Math.floor((diff % 3600000) / 60000));
			elS.textContent = pad(Math.floor((diff % 60000) / 1000));
			if (diff < 300000) cdBar.classList.add('me-danger');
			else cdBar.classList.remove('me-danger');
			setTimeout(tick, 1000);
		}
		tick();
	})();

	// ===== 表单提交 =====
	$(document).ready(function(){
		$('form').on('submit', function(event){
			event.preventDefault();
			var formData = $(this).serializeArray();
			var myData = [];
			formData.forEach(function(item, key){
				if(item.name.indexOf("__") > -1){
					delete formData[key];
				} else {
					myData.push(formData[key]);
				}
			});
			checkquestion(myData);
		});
	});

	function checkquestion(dict){
		var answer = [];
		var allscore = 0;
		var wrongList = [];

		// 构建表单数据映射 { name: [value1, value2, ...] }
		var formMap = {};
		for (var fi = 0; fi < dict.length; fi++) {
			if (!dict[fi]) continue;
			var fname = dict[fi].name;
			if (!formMap[fname]) formMap[fname] = [];
			formMap[fname].push(dict[fi].value);
		}

		// 检查未完成数
		var unanswered = 0;
		for (var qi = 0; qi < qcount; qi++) {
			var q = jsonquestion[qi];
			var qid = q.Qid;
			var qtype = q.Qtype || (q.Qblack ? '填空' : '单选');
			if (qtype === 'scratch' || qtype === 'python' || qtype === 'pythonblock') continue;
			if (qtype === '单选' || qtype === '判断') {
				if (!formMap['单选-' + qid]) unanswered++;
			} else if (qtype === '多选') {
				if (!formMap['多选-' + qid]) unanswered++;
			} else if (qtype === '填空') {
				var fitems = JSON.parse(q.Qitem);
				for (var fj = 0; fj < fitems.length; fj++) {
					var fkey = '填空-' + qid + '-' + fitems[fj].Mid;
					if (!formMap[fkey] || !formMap[fkey][0].trim()) unanswered++;
				}
			} else if (qtype === '问答') {
				if (!formMap['问答-' + qid] || !formMap['问答-' + qid][0].trim()) unanswered++;
			}
		}

		if (unanswered > 0) {
			alert('您还有' + unanswered + '道题目未完成？');
			return;
		}

		// 评分
		var overScoreQuestions = []; // 记录超分的题目
		console.log('=== 开始评分检查 ===');
		console.log('题目总数:', qcount);
		
		for (var qi2 = 0; qi2 < qcount; qi2++) {
			var q2 = jsonquestion[qi2];
			var qid2 = q2.Qid;
			var qtype2 = q2.Qtype || (q2.Qblack ? '填空' : '单选');
			var qsc = parseInt(q2.Qscore) || 0;
			var questionScore = 0; // 该题得分
			
			console.log('题目' + (qi2 + 1) + ':', {
				qid: qid2,
				qtype: qtype2,
				maxScore: qsc
			});

			if (qtype2 === '单选' || qtype2 === '判断') {
				var sel = formMap['单选-' + qid2] ? formMap['单选-' + qid2][0] : '';
				if (sel) {
					var sitems = JSON.parse(q2.Qitem);
					var correct = false;
					for (var sj = 0; sj < sitems.length; sj++) {
						if (parseInt(sitems[sj].Mscore) > 0 && String(sitems[sj].Mid) === sel) { correct = true; break; }
					}
					answer.push(sel);
					if (correct) {
						questionScore = qsc;
						allscore += qsc;
					} else {
						wrongList.push('单选-' + qid2);
					}
				}
			} else if (qtype2 === '多选') {
				var msel = (formMap['多选-' + qid2] || []).slice().sort();
				var mitems = JSON.parse(q2.Qitem);
				var correctMids = [];
				for (var mj = 0; mj < mitems.length; mj++) {
					if (parseInt(mitems[mj].Mscore) > 0) correctMids.push(String(mitems[mj].Mid));
				}
				correctMids.sort();
				answer.push(msel.join('|'));
				if (msel.join(',') === correctMids.join(',')) {
					questionScore = qsc;
					allscore += qsc;
				} else {
					wrongList.push('多选-' + qid2);
				}
			} else if (qtype2 === '填空') {
				var bitems = JSON.parse(q2.Qitem);
				console.log('填空题空数:', bitems.length);
				for (var bj = 0; bj < bitems.length; bj++) {
					var bkey = '填空-' + qid2 + '-' + bitems[bj].Mid;
					var bval = formMap[bkey] ? formMap[bkey][0] : '';
					var correctVal = HtmlUtil.htmlDecode(bitems[bj].Mitem);
					var blankScore = parseInt(bitems[bj].Mscore) || 0;
					console.log('  空' + (bj + 1) + ':', {
						key: bkey,
						answer: bval,
						correct: correctVal,
						score: blankScore,
						isCorrect: bval.trim() === correctVal.trim()
					});
					if (bval.trim() === correctVal.trim()) {
						questionScore += blankScore;
						allscore += blankScore;
						answer.push(bitems[bj].Mid);
					} else {
						wrongList.push(bkey);
					}
				}
			} else if (qtype2 === '问答') {
				var eval2 = formMap['问答-' + qid2] ? formMap['问答-' + qid2][0] : '';
				answer.push(eval2); // 存储答案，不自动评分
			}
			
			console.log('题目' + (qi2 + 1) + '得分:', questionScore, '满分:', qsc);
			
			// 检查该题得分是否超过满分
			if (questionScore > qsc && qsc > 0) {
				console.log('!!! 题目' + (qi2 + 1) + '超分了！得分:', questionScore, '满分:', qsc);
				overScoreQuestions.push({
					num: qi2 + 1,
					score: questionScore,
					maxScore: qsc
				});
			}
			// scratch/python/pythonblock: 不处理
		}
		
		console.log('=== 评分检查完成 ===');
		console.log('总分:', allscore);
		console.log('超分题目数:', overScoreQuestions.length);
		console.log('超分题目列表:', overScoreQuestions);
		
		// 如果有题目超分，弹窗提示
		if (overScoreQuestions.length > 0) {
			console.log('准备显示超分弹窗');
			var msg = '警告：以下题目的得分超过了满分！\n\n';
			for (var i = 0; i < overScoreQuestions.length; i++) {
				var oq = overScoreQuestions[i];
				msg += '第' + oq.num + '题：得分 ' + oq.score + ' 分，满分 ' + oq.maxScore + ' 分\n';
			}
			msg += '\n这可能是题目设置错误，请联系老师检查。\n是否继续提交？';
			
			console.log('弹窗消息:', msg);
			if (!confirm(msg)) {
				console.log('用户取消提交');
				btnupload.disabled = false;
				return;
			}
			console.log('用户确认继续提交');
		}

		if (toBool(isclose)) {
			alert('调查测验还未开始！');
		} else {
			// 检查总分是否超过试卷满分
			if (_paperScore > 0 && allscore > _paperScore) {
				var confirmMsg = '警告：您的得分（' + allscore + '分）超过了试卷满分（' + _paperScore + '分）！\n\n';
				confirmMsg += '这可能是因为：\n';
				confirmMsg += '1. 题目设置有误\n';
				confirmMsg += '2. 评分计算错误\n\n';
				confirmMsg += '是否继续提交？';
				
				if (!confirm(confirmMsg)) {
					btnupload.disabled = false;
					return;
				}
			}
			
			noticewrong(wrongList);
			btnupload.disabled = true;
			uploadscore(answer.toString(), allscore);
		}
	}

	// ===== Mid转字母辅助函数 =====
	function midToLetter(mid, qid) {
		// Mid = qid * 10 + optionIndex + 1，optionIndex对应A=0,B=1,C=2,D=3
		var idx = mid - qid * 10 - 1;
		var letters = 'ABCD';
		if (idx >= 0 && idx < letters.length) return letters[idx];
		return '';
	}

	// ===== 构建逐题答案数组 =====
	function buildPerQuestionAnswers(formMap) {
		var perQ = [];
		for (var qi = 0; qi < qcount; qi++) {
			var q = jsonquestion[qi];
			var qid = q.Qid;
			var qtype = q.Qtype || (q.Qblack ? '填空' : '单选');
			var ans = '';

			if (qtype === '单选' || qtype === '判断') {
				var sel = formMap['单选-' + qid] ? formMap['单选-' + qid][0] : '';
				if (sel) ans = midToLetter(parseInt(sel), qid);
			} else if (qtype === '多选') {
				var msel = formMap['多选-' + qid] || [];
				var letters = [];
				for (var mi = 0; mi < msel.length; mi++) {
					var lt = midToLetter(parseInt(msel[mi]), qid);
					if (lt) letters.push(lt);
				}
				letters.sort();
				ans = letters.join('');
			} else if (qtype === '填空') {
				var fitems = JSON.parse(q.Qitem);
				var parts = [];
				for (var fi = 0; fi < fitems.length; fi++) {
					var fkey = '填空-' + qid + '-' + fitems[fi].Mid;
					var fval = formMap[fkey] ? formMap[fkey][0] : '';
					parts.push(fval.trim());
				}
				ans = parts.join('|');
			} else if (qtype === '问答') {
				ans = formMap['问答-' + qid] ? formMap['问答-' + qid][0] : '';
			} else if (qtype === 'scratch' || qtype === 'python' || qtype === 'pythonblock') {
				// 检查localStorage中的编程作答状态
				var lsKey = 'exam_' + vidstr + '_u_' + snumstr + '_q_' + qid;
				if (localStorage.getItem(lsKey) === 'done') ans = '已提交';
			}

			perQ.push({ qid: qid, qtype: qtype, answer: ans });
		}
		return perQ;
	}

	function uploadscore(selectstr, score){
		console.log('=== uploadscore 开始 ===');
		console.log('selectstr:', selectstr);
		console.log('score:', score);
		console.log('_examSource:', _examSource);
		
		var formData = new FormData();
		formData.append('selectstr', selectstr);
		formData.append('score', score);
		formData.append('lidstr', lidstr);
		formData.append('cidstr', cidstr);
		formData.append('vidstr', vidstr);
		formData.append('vtypestr', vtypestr);
		$.ajax({
			url: 'uploadexam.ashx',
			type: 'POST',
			cache: false,
			data: formData,
			processData: false,
			contentType: false
		}).done(function (res) {
			console.log('uploadexam.ashx 响应:', res);
			if (res && res.trim() === 'ok') {
				console.log('uploadexam.ashx 成功');
				// 同步提交逐题答案到ExamAnswer表（用于教师阅卷）
				if (_examSource === 'paper') {
					console.log('检测到 paper 模式，调用 submitPerQuestionAnswers');
					submitPerQuestionAnswers();
				} else {
					console.log('非 paper 模式，直接显示已提交页面');
					// 显示已提交页面
					showDonePage('');
				}
			} else {
				var errMsg = res || '未知错误';
				console.error('提交失败详情:', errMsg);
				alert('提交失败：' + errMsg + '\n\n请截图此错误信息并联系老师。');
				btnupload.disabled = false;
			}
		}).fail(function (xhr, status, error) {
			var errDetail = '状态: ' + status;
			if (xhr.responseText) errDetail += '\n响应: ' + xhr.responseText;
			if (error) errDetail += '\n错误: ' + error;
			console.error('AJAX失败详情:', errDetail, xhr);
			alert('提交失败：网络错误或服务器异常\n\n' + errDetail + '\n\n请检查网络连接或联系老师。');
			btnupload.disabled = false;
		});
	}

	function submitPerQuestionAnswers() {
		console.log('=== submitPerQuestionAnswers 开始 ===');
		// 重新构建formMap
		var allData = $('form').serializeArray();
		var fm = {};
		for (var i = 0; i < allData.length; i++) {
			if (allData[i].name.indexOf('__') > -1) continue;
			if (!fm[allData[i].name]) fm[allData[i].name] = [];
			fm[allData[i].name].push(allData[i].value);
		}
		var perQ = buildPerQuestionAnswers(fm);
		console.log('构建的答案数组:', perQ);
		console.log('答案数量:', perQ.length);
		
		var fd2 = new FormData();
		fd2.append('vid', vidstr);
		fd2.append('answers', JSON.stringify(perQ));
		
		console.log('提交参数 - vid:', vidstr);
		console.log('提交参数 - answers:', JSON.stringify(perQ));
		
		$.ajax({
			url: 'submitexamanswers.ashx',
			type: 'POST',
			cache: false,
			data: fd2,
			processData: false,
			contentType: false
		}).done(function (res) {
			console.log('submitexamanswers.ashx 响应:', res);
			if (res && res.trim() === 'ok') {
				console.log('submitexamanswers.ashx 成功');
				// 显示已提交页面
				showDonePage('');
			} else {
				var errMsg = res || '未知错误';
				console.error('提交答案失败详情:', errMsg);
				alert('提交答案失败：' + errMsg + '\n\n请截图此错误信息并联系老师。\n\n调试信息：\nvid=' + vidstr + '\n答案数量=' + perQ.length);
				btnupload.disabled = false;
			}
		}).fail(function (xhr, status, error) {
			var errDetail = '状态: ' + status;
			if (xhr.responseText) errDetail += '\n响应: ' + xhr.responseText;
			if (error) errDetail += '\n错误: ' + error;
			console.error('AJAX失败详情:', errDetail, xhr);
			alert('提交答案失败：网络错误或服务器异常\n\n' + errDetail + '\n\n请检查网络连接或联系老师。');
			btnupload.disabled = false;
		});
	}

	function noticewrong(wrongList){
		wrongList.forEach(function(wrong){
			var elemid="q"+wrong.split('-')[1];
			var element = document.getElementById(elemid);
			if (element) element.style.boxShadow = '0px 0px 6px red';
		})
	}

	var HtmlUtil = {
		htmlEncode: function(html) {
			var tempDiv = document.createElement('div');
			(tempDiv.textContent != undefined) ? (tempDiv.textContent = html) : (tempDiv.innerText = html);
			var output = tempDiv.innerHTML;
			tempDiv = null;
			return output;
		},
		htmlDecode: function(text) {
			var tempDiv = document.createElement('div');
			tempDiv.innerHTML = text;
			var output = tempDiv.innerText || tempDiv.textContent;
			tempDiv = null;
			return output;
		}
	}

	// ===== 渲染题目 =====
	if(qcount>0){
		for (var i=0;i<qcount;i++){
			try {
				var question = jsonquestion[i];
				qidList.push(question["Qid"]);
				htmlstr=htmlstr+"<div class='quizquestion' id='q"+question["Qid"]+"' data-idx='"+i+"' data-qtype='"+(question["Qtype"]||"")+"'>"+ creatquestion(i,question["Qid"],question["Qtitle"],question["Qblack"],question["Qitem"],question["Qtype"]||"",question["Qtemplate"]||"")+"</div>";
			} catch(eRender) {
				console.error('题目 ' + (i+1) + ' 渲染出错:', eRender);
				qidList.push(jsonquestion[i] ? jsonquestion[i]["Qid"] : 0);
				htmlstr += "<div class='quizquestion'><div class='quiztitle'>第" + (i+1) + "题  （渲染异常）</div></div>";
			}
		}
		div.innerHTML = htmlstr;
		
		// 加载历史答案（如果学生重新开始考试，显示上次提交的结果）
		if (_examSource === 'paper' && !toBool(isdone)) {
			loadHistoryAnswers();
		}
	}

	// ===== 加载历史答案 =====
	function loadHistoryAnswers() {
		if (!vidstr || vidstr === '0') return;
		$.ajax({
			url: 'gethistoryanswers.ashx?vid=' + vidstr,
			type: 'GET',
			dataType: 'json'
		}).done(function(data) {
			if (data && data.success && data.answers && data.answers.length > 0) {
				// 显示历史答案提示
				var hintDiv = document.createElement('div');
				hintDiv.className = 'me-history-hint';
				hintDiv.style.cssText = 'padding:12px 16px;margin-bottom:16px;background:#fffbeb;border:1px solid #fde68a;border-radius:10px;font-size:13px;color:#92400e;';
				hintDiv.innerHTML = '<svg viewBox="0 0 24 24" style="width:16px;height:16px;vertical-align:middle;margin-right:6px;stroke:currentColor;fill:none;stroke-width:2;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>以下显示的是您上次提交的答案，您可以重新作答。';
				var quizCard = document.getElementById('meQuizCard');
				if (quizCard) {
					var quizArea = quizCard.querySelector('.me-quiz-area');
					if (quizArea) quizArea.insertBefore(hintDiv, quizArea.firstChild);
				}
				
				// 填充历史答案
				for (var i = 0; i < data.answers.length; i++) {
					var ans = data.answers[i];
					var qid = ans.qid;
					var answer = ans.answer || '';
					
					// 查找对应的题目
					var qEl = document.getElementById('q' + qid);
					if (!qEl) continue;
					
					var qtype = qEl.getAttribute('data-qtype') || '';
					
					if (qtype === '单选' || qtype === '判断') {
						// 单选/判断：答案是字母格式（A/B/C/D），需要转换为 Mid
						var radios = qEl.querySelectorAll('input[type="radio"][name="单选-' + qid + '"]');
						
						// 如果答案是字母格式，转换为对应的 Mid
						if (answer.match(/^[A-D]$/i)) {
							var letterIndex = answer.toUpperCase().charCodeAt(0) - 65; // A=0, B=1, C=2, D=3
							var targetMid = qid * 10 + letterIndex + 1;
							
							for (var r = 0; r < radios.length; r++) {
								if (parseInt(radios[r].value) === targetMid) {
									radios[r].checked = true;
									break;
								}
							}
						} else {
							// 如果答案已经是 Mid 格式，直接匹配
							for (var r = 0; r < radios.length; r++) {
								if (radios[r].value === answer || parseInt(radios[r].value) === parseInt(answer)) {
									radios[r].checked = true;
									break;
								}
							}
						}
					} else if (qtype === '多选') {
						// 多选：答案可能是 "A,B" 或 "AB" 或 "1,2" 格式
						var checkboxes = qEl.querySelectorAll('input[type="checkbox"][name="多选-' + qid + '"]');
						var ansParts = [];
						
						// 解析答案
						if (answer.indexOf(',') >= 0) {
							// 逗号分隔：A,B 或 1,2
							ansParts = answer.split(',').map(function(s) { return s.trim(); });
						} else if (answer.indexOf('|') >= 0) {
							// 竖线分隔：A|B
							ansParts = answer.split('|').map(function(s) { return s.trim(); });
						} else {
							// 连续字母：AB 或 单个答案
							ansParts = answer.split('');
						}
						
						for (var c = 0; c < checkboxes.length; c++) {
							var cbMid = parseInt(checkboxes[c].value);
							var matched = false;
							
							for (var ap = 0; ap < ansParts.length; ap++) {
								var part = ansParts[ap].trim();
								if (!part) continue;
								
								// 如果是字母格式，转换为 Mid
								if (part.match(/^[A-D]$/i)) {
									var letterIdx = part.toUpperCase().charCodeAt(0) - 65;
									var targetMid = qid * 10 + letterIdx + 1;
									if (cbMid === targetMid) {
										matched = true;
										break;
									}
								} else if (cbMid === parseInt(part) || checkboxes[c].value === part) {
									// 直接匹配 Mid
									matched = true;
									break;
								}
							}
							
							if (matched) checkboxes[c].checked = true;
						}
					} else if (qtype === '填空') {
						// 填空：答案可能是多个值用逗号分隔
						var inputs = qEl.querySelectorAll('input[name^="填空-' + qid + '-"]');
						var ansParts = answer.split(',').map(function(s) { return s.trim(); });
						for (var f = 0; f < inputs.length && f < ansParts.length; f++) {
							inputs[f].value = ansParts[f];
						}
					} else if (qtype === '问答') {
						// 问答：直接填充textarea
						var textarea = qEl.querySelector('textarea[name="问答-' + qid + '"]');
						if (textarea) textarea.value = answer;
					} else if (qtype === 'scratch' || qtype === 'python' || qtype === 'pythonblock') {
						// 编程题：如果答案是"已提交"，显示已作答状态
						if (answer === '已提交' || answer.length > 0) {
							var statusEl = document.getElementById('codingStatus' + qid);
							var editBtn = document.getElementById('codingEditBtn' + qid);
							if (statusEl) {
								statusEl.textContent = '已作答';
								statusEl.classList.add('me-done');
							}
							if (editBtn && !toBool(isclose)) {
								editBtn.classList.remove('me-coding-btn-hidden');
							}
						}
					}
				}
				
				// 更新答题状态
				updateAnsweredState();
			}
		}).fail(function() {
			// 加载失败不影响正常考试
		});
	}

	function creatquestion(qnum,qid,qtitle,qblack,qitem,qtype,qtemplate){
		var title = "";
		var item = "";
		var number = qnum + 1;
		qtype = qtype || (qblack ? '填空' : '单选');

		// 题型标签
		var typeLabels = {'单选':'单选','多选':'多选','判断':'判断','填空':'填空','问答':'问答','scratch':'Scratch','python':'Python','pythonblock':'Python拼图'};
		var typeBadgeCls = {'单选':'me-tb-choice','多选':'me-tb-multi','判断':'me-tb-judge','填空':'me-tb-fill','问答':'me-tb-essay','scratch':'me-tb-scratch','python':'me-tb-python','pythonblock':'me-tb-pythonblock'};
		var typeLabel = typeLabels[qtype] || qtype;
		var badge = '<span class="me-type-badge ' + (typeBadgeCls[qtype]||'') + '">' + typeLabel + '</span>';

		if (qtype === '填空') {
			qtitle = replaceSpanValues(HtmlUtil.htmlDecode(qtitle),qid,qitem);
			title = "<div class='quiztitle'>" + badge + "第" + number + "题  " + qtitle + "</div>";
		} else if (qtype === '问答') {
			title = "<div class='quiztitle'>" + badge + "第" + number + "题  " + HtmlUtil.htmlDecode(qtitle) + "</div>";
			item = '<div class="me-essay-wrap"><textarea class="me-essay-input" name="问答-' + qid + '" placeholder="请输入你的答案..."></textarea></div>';
		} else if (qtype === 'scratch' || qtype === 'python' || qtype === 'pythonblock') {
			title = "<div class='quiztitle'>" + badge + "第" + number + "题  " + HtmlUtil.htmlDecode(qtitle) + "</div>";
			var url = '';
			if (qtype === 'scratch') url = 'coding.aspx?id=' + qid + '&Fpage=' + encodeURIComponent(location.href) + '&examvid=' + vidstr;
			else if (qtype === 'python') url = 'python.aspx?Id=' + qid + '&Fpage=' + encodeURIComponent(location.href) + '&examvid=' + vidstr;
			else url = 'pythonblock.aspx?Id=' + qid + '&Fpage=' + encodeURIComponent(location.href) + '&examvid=' + vidstr;
			if (qtemplate) url += '&sbfile=' + encodeURIComponent(qtemplate);
			var icons = {
				'scratch': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>',
				'python': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>',
				'pythonblock': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>'
			};
			var codingDoneKey = 'exam_' + vidstr + '_u_' + snumstr + '_q_' + qid;
			var isCodingDone = vidstr && localStorage.getItem(codingDoneKey) === 'done';
			var hideActions = toBool(isclose) || toBool(isdone);
			var btnText = isCodingDone ? '重新作答' : '去作答';
			var statusText = isCodingDone ? '已作答' : '未作答';
			var statusCls = 'me-coding-status' + (isCodingDone ? ' me-done' : '');
			// 构建"修改"按钮的URL：通过editsbfile参数加载已保存的项目文件（客户端直接读取，绕过服务端处理）
			var editUrl = '';
			var editSbParam = '&editsbfile=' + encodeURIComponent('getproject.ashx?id=' + qid);
			if (qtype === 'scratch') editUrl = 'coding.aspx?id=' + qid + '&Fpage=' + encodeURIComponent(location.href) + '&examvid=' + vidstr + editSbParam;
			else if (qtype === 'python') editUrl = 'python.aspx?Id=' + qid + '&Fpage=' + encodeURIComponent(location.href) + '&examvid=' + vidstr + editSbParam;
			else editUrl = 'pythonblock.aspx?Id=' + qid + '&Fpage=' + encodeURIComponent(location.href) + '&examvid=' + vidstr + editSbParam;
			if (qtemplate) editUrl += '&sbfile=' + encodeURIComponent(qtemplate);
			var editIcon = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>';
			var actionBtnCls = hideActions ? ' me-coding-btn-hidden' : '';
			var editBtnDisplay = (isCodingDone && !hideActions) ? '' : ' me-coding-btn-hidden';
			item = '<div class="me-coding-wrap">';
			item += '<a class="me-coding-btn me-coding-' + qtype + actionBtnCls + '" href="javascript:void(0)" onclick="openCodingPage(\'' + url + '\')" id="codingBtn' + qid + '">' + (icons[qtype]||'') + '<span>' + btnText + '</span></a>';
			item += '<a class="me-coding-btn me-coding-edit' + editBtnDisplay + '" href="javascript:void(0)" onclick="openCodingPage(\'' + editUrl + '\')" id="codingEditBtn' + qid + '">' + editIcon + '<span>修改</span></a>';
			item += '<span class="' + statusCls + '" id="codingStatus' + qid + '">' + statusText + '</span>';
			item += '</div>';
		} else if (qtype === '多选') {
			var jsonitem = JSON.parse(qitem);
			var itemlen = parseInt(jsonitem.length);
			for (var k = 0; k < itemlen; k++) {
				var itemstr = HtmlUtil.htmlDecode(jsonitem[k].Mitem);
				item += '<div class="quizraido"><input type="checkbox" name="多选-' + qid + '" value="' + jsonitem[k].Mid + '"> ' + itemstr + '</div>';
			}
			title = "<div class='quiztitle'>" + badge + "第" + number + "题  " + HtmlUtil.htmlDecode(qtitle) + "（多选）</div>";
		} else {
			// 单选、判断
			var jsonitem = JSON.parse(qitem);
			// 判断题前端兆底：若选项为空，自动生成"正确"/"错误"
			if (qtype === '判断' && jsonitem.length === 0) {
				jsonitem = [
					{Mid: qid * 10 + 1, Mitem: 'A. 正确', Mscore: 0},
					{Mid: qid * 10 + 2, Mitem: 'B. 错误', Mscore: 0}
				];
			}
			var itemlen = parseInt(jsonitem.length);
			for (var k = 0; k < itemlen; k++) {
				var itemstr = HtmlUtil.htmlDecode(jsonitem[k].Mitem);
				var itemscore = parseInt(jsonitem[k].Mscore);
				if (itemscore > 0) {
					idList.push(jsonitem[k].Mid);
					scoreList.push(itemscore);
				}
				item += '<div class="quizraido"><input type="radio" name="单选-' + qid + '" value="' + jsonitem[k].Mid + '"> ' + itemstr + '</div>';
			}
			title = "<div class='quiztitle'>" + badge + "第" + number + "题  " + HtmlUtil.htmlDecode(qtitle) + "</div>";
		}
		return title + item;
	}

	function replaceSpanValues(htmlString,qid,qitem) {
		var jsonitem = JSON.parse(qitem);
		const regex = new RegExp('<input[^>]+class="[^"]*blackword[^"]*"[^>]*>', 'g');
		const inputs = htmlString.match(regex);
		if (inputs && inputs.length > 0) {
			// Survey 填空题：替换已有的 blackword 输入框
			var count = inputs.length;
			for(var i=0;i<count;i++){
				if (i < jsonitem.length) {
					var sp = ' <input name="填空-'+qid+'-'+jsonitem[i].Mid+'"  class="blackword"  /> ';
					htmlString = htmlString.replace(inputs[i],sp);
					var itemstr =HtmlUtil.htmlDecode(jsonitem[i].Mitem);
					var itemscore = parseInt(jsonitem[i].Mscore);
					idList.push(itemstr);
					scoreList.push(itemscore);
				}
			}
		} else {
			// Paper 填空题：内容无 blackword 标签，在题目后追加输入框
			for (var j = 0; j < jsonitem.length; j++) {
				htmlString += ' <input name="填空-'+qid+'-'+jsonitem[j].Mid+'"  class="blackword"  /> ';
				var jitemstr = HtmlUtil.htmlDecode(jsonitem[j].Mitem);
				var jitemscore = parseInt(jsonitem[j].Mscore);
				idList.push(jitemstr);
				scoreList.push(jitemscore);
			}
		}
		return htmlString;
	}

	// ===== 侧栏：题号导航 =====
	(function initNavGrid() {
		var grid = document.getElementById('meNavGrid');
		if (!grid || qcount === 0) return;
		var html = '';
		for (var i = 0; i < qcount; i++) {
			html += '<button type="button" class="me-nav-btn" data-navidx="' + i + '">' + (i + 1) + '</button>';
		}
		grid.innerHTML = html;

		// 点击跳转
		grid.addEventListener('click', function(e) {
			var btn = e.target.closest('.me-nav-btn');
			if (!btn) return;
			var idx = parseInt(btn.getAttribute('data-navidx'));
			var qid = qidList[idx];
			var el = document.getElementById('q' + qid);
			if (el) {
				el.scrollIntoView({ behavior: 'smooth', block: 'center' });
				// 高亮当前导航按钮
				updateActiveNav(idx);
				// 闪烁题目
				el.style.transition = 'background .2s';
				el.style.background = '#eff6ff';
				setTimeout(function(){ el.style.background = ''; }, 600);
			}
		});

		// 监听选择/输入，标记已答
		var questionPage = document.getElementById('questionPage');
		if (questionPage) {
			questionPage.addEventListener('change', updateAnsweredState);
			questionPage.addEventListener('input', updateAnsweredState);
		}
	})();

	function updateActiveNav(idx) {
		var btns = document.querySelectorAll('.me-nav-btn');
		for (var i = 0; i < btns.length; i++) {
			btns[i].classList.remove('me-nav-active');
		}
		if (btns[idx]) btns[idx].classList.add('me-nav-active');
	}

	function updateAnsweredState() {
		var btns = document.querySelectorAll('.me-nav-btn');
		for (var i = 0; i < qcount; i++) {
			var qid = qidList[i];
			var qEl = document.getElementById('q' + qid);
			if (!qEl) continue;
			var answered = false;
			// 单选/判断：radio
			var radios = qEl.querySelectorAll('input[type="radio"]:checked');
			if (radios.length > 0) answered = true;
			// 多选：checkbox
			if (!answered) {
				var checks = qEl.querySelectorAll('input[type="checkbox"]:checked');
				if (checks.length > 0) answered = true;
			}
			// 填空
			if (!answered) {
				var inputs = qEl.querySelectorAll('input.blackword');
				for (var j = 0; j < inputs.length; j++) {
					if (inputs[j].value.trim() !== '') { answered = true; break; }
				}
			}
			// 问答
			if (!answered) {
				var textareas = qEl.querySelectorAll('textarea.me-essay-input');
				for (var j = 0; j < textareas.length; j++) {
					if (textareas[j].value.trim() !== '') { answered = true; break; }
				}
			}
			// 编程题：检查是否已完成
			if (!answered) {
				var codingDone = qEl.querySelector('.me-coding-status.me-done');
				if (codingDone) answered = true;
			}
			if (btns[i]) {
				if (answered) btns[i].classList.add('me-nav-done');
				else btns[i].classList.remove('me-nav-done');
			}
		}
	}

	// ===== 打开编程页面（保留 opener 引用） =====
	function openCodingPage(url) {
		window.open(url, '_blank');
	}

	// ===== 编程题状态：接收子窗口消息 + localStorage 恢复 + storage 事件 =====
	function markCodingDone(qid) {
		var csEl = document.getElementById('codingStatus' + qid);
		if (csEl && !csEl.classList.contains('me-done')) {
			csEl.textContent = '已作答';
			csEl.classList.add('me-done');
			updateAnsweredState();
		}
		// 将按钮文字从"去作答"改为"重新作答"
		var btnEl = document.getElementById('codingBtn' + qid);
		if (btnEl) {
			var spanEl = btnEl.querySelector('span');
			if (spanEl && spanEl.textContent === '去作答') {
				spanEl.textContent = '重新作答';
			}
		}
		// 显示"修改"按钮（如果考试未结束且未提交）
		var editBtn = document.getElementById('codingEditBtn' + qid);
		if (editBtn && !toBool(isclose) && !toBool(isdone)) {
			editBtn.classList.remove('me-coding-btn-hidden');
		}
	}

	(function initCodingStatus() {
		// 恢复 localStorage 中的编程完成状态
		if (vidstr && qcount > 0) {
			for (var ci = 0; ci < qcount; ci++) {
				var cq = jsonquestion[ci];
				var cqt = cq.Qtype || '';
				if (cqt === 'scratch' || cqt === 'python' || cqt === 'pythonblock') {
				var lsKey = 'exam_' + vidstr + '_u_' + snumstr + '_q_' + cq.Qid;
				var lsVal = localStorage.getItem(lsKey);
					if (lsVal === 'done') {
						markCodingDone(cq.Qid);
					}
				}
			}
			updateAnsweredState();
		}

		// 监听 postMessage（window.open 打开时可用）
		window.addEventListener('message', function(evt) {
			if (evt.data && evt.data.type === 'examCodingSaved') {
				markCodingDone(evt.data.qid);
			}
		});

		// 监听 storage 事件（跨tab可靠通知，当其他tab修改localStorage时触发）
		window.addEventListener('storage', function(evt) {
			if (!evt.key || !vidstr) return;
			var prefix = 'exam_' + vidstr + '_u_' + snumstr + '_q_';
			if (evt.key.indexOf(prefix) === 0 && evt.newValue === 'done') {
				var qid = evt.key.substring(prefix.length);
				markCodingDone(qid);
			}
		});
	})();

	// ===== Base64 工具 =====
	function Encode64(str) {
		return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
			function toSolidBytes(match, p1) {
				return String.fromCharCode('0x' + p1);
			}));
	}
	function Decode64(str) {
		return decodeURIComponent(atob(str).split('').map(function (c) {
			return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
		}).join(''));
	}

	// 初始加载
	$(document).ready(function() {
		console.log('=== 页面加载完成 ===');
		console.log('vidstr=', vidstr);
		console.log('isdone=', isdone);
		console.log('isclose=', isclose);
		
		// 检查是否已提交
		var checkLabel = document.getElementById('<%= Lbcheck.ClientID %>');
		var isSubmitted = checkLabel && checkLabel.textContent.indexOf('已提交') >= 0;
		console.log('是否已提交:', isSubmitted);
		
		// 只有已提交时才显示"已提交"标签
		if (isSubmitted) {
			var checkEl = document.getElementById('meInfoCheck');
			if (checkEl) checkEl.style.display = 'inline-flex';
		}
		
		// ===== 拦截退出登录，添加二次确认 =====
		interceptLogout();
	});
	
	// 拦截退出登录功能
	function interceptLogout() {
		// 保存原始的退出函数
		if (typeof window.parent.doScmLogout !== 'undefined') {
			window.parent.originalDoScmLogout = window.parent.doScmLogout;
			
			// 重写退出函数
			window.parent.doScmLogout = function() {
				showExamExitConfirm();
			};
		}
	}
	
	// 显示退出考试确认对话框
	function showExamExitConfirm() {
		// 创建第一次确认对话框
		var modal1 = document.createElement('div');
		modal1.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:99999;display:flex;align-items:center;justify-content:center;animation:fadeIn 0.2s;';
		
		var dialog1 = document.createElement('div');
		dialog1.style.cssText = 'background:#fff;border-radius:16px;padding:32px;max-width:420px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,0.3);animation:slideUp 0.3s;';
		
		dialog1.innerHTML = `
			<div style="text-align:center;margin-bottom:24px;">
				<div style="width:64px;height:64px;margin:0 auto 16px;background:linear-gradient(135deg,#fef3c7,#fde68a);border-radius:50%;display:flex;align-items:center;justify-content:center;">
					<svg viewBox="0 0 24 24" style="width:32px;height:32px;stroke:#d97706;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;">
						<circle cx="12" cy="12" r="10"/>
						<line x1="12" y1="8" x2="12" y2="12"/>
						<line x1="12" y1="16" x2="12.01" y2="16"/>
					</svg>
				</div>
				<h3 style="font-size:20px;font-weight:700;color:#1e293b;margin:0 0 8px;">确认退出考试？</h3>
				<p style="font-size:14px;color:#64748b;line-height:1.6;margin:0;">退出后您的答案将自动保存<br/>但考试时间仍会继续计时</p>
			</div>
			<div style="display:flex;gap:12px;">
				<button id="examExitCancel1" style="flex:1;height:44px;border:1.5px solid #e2e8f0;border-radius:10px;background:#fff;color:#475569;font-size:15px;font-weight:600;cursor:pointer;transition:all 0.15s;font-family:Microsoft YaHei,sans-serif;">
					取消
				</button>
				<button id="examExitConfirm1" style="flex:1;height:44px;border:none;border-radius:10px;background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff;font-size:15px;font-weight:600;cursor:pointer;transition:all 0.15s;box-shadow:0 4px 12px rgba(245,158,11,0.3);font-family:Microsoft YaHei,sans-serif;">
					确认退出
				</button>
			</div>
		`;
		
		modal1.appendChild(dialog1);
		document.body.appendChild(modal1);
		
		// 添加动画样式
		var style = document.createElement('style');
		style.textContent = `
			@keyframes fadeIn { from { opacity:0; } to { opacity:1; } }
			@keyframes slideUp { from { transform:translateY(20px); opacity:0; } to { transform:translateY(0); opacity:1; } }
			#examExitCancel1:hover { background:#f8fafc; border-color:#cbd5e1; }
			#examExitConfirm1:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(245,158,11,0.4); }
		`;
		document.head.appendChild(style);
		
		// 取消按钮
		document.getElementById('examExitCancel1').onclick = function() {
			document.body.removeChild(modal1);
		};
		
		// 确认按钮 - 显示第二次确认
		document.getElementById('examExitConfirm1').onclick = function() {
			document.body.removeChild(modal1);
			showExamExitSecondConfirm();
		};
	}
	
	// 显示第二次确认对话框
	function showExamExitSecondConfirm() {
		var modal2 = document.createElement('div');
		modal2.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);z-index:99999;display:flex;align-items:center;justify-content:center;animation:fadeIn 0.2s;';
		
		var dialog2 = document.createElement('div');
		dialog2.style.cssText = 'background:#fff;border-radius:16px;padding:32px;max-width:420px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,0.4);animation:slideUp 0.3s;';
		
		dialog2.innerHTML = `
			<div style="text-align:center;margin-bottom:24px;">
				<div style="width:64px;height:64px;margin:0 auto 16px;background:linear-gradient(135deg,#fecaca,#fca5a5);border-radius:50%;display:flex;align-items:center;justify-content:center;">
					<svg viewBox="0 0 24 24" style="width:32px;height:32px;stroke:#dc2626;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;">
						<circle cx="12" cy="12" r="10"/>
						<line x1="15" y1="9" x2="9" y2="15"/>
						<line x1="9" y1="9" x2="15" y2="15"/>
					</svg>
				</div>
				<h3 style="font-size:20px;font-weight:700;color:#dc2626;margin:0 0 8px;">最后确认</h3>
				<p style="font-size:14px;color:#64748b;line-height:1.6;margin:0;">
					<strong style="color:#dc2626;">请再次确认是否要退出考试</strong><br/>
					确认后将<strong style="color:#dc2626;">自动提交试卷</strong>并返回系统首页
				</p>
			</div>
			<div style="display:flex;gap:12px;">
				<button id="examExitCancel2" style="flex:1;height:44px;border:1.5px solid #e2e8f0;border-radius:10px;background:#fff;color:#475569;font-size:15px;font-weight:600;cursor:pointer;transition:all 0.15s;font-family:Microsoft YaHei,sans-serif;">
					我再想想
				</button>
				<button id="examExitConfirm2" style="flex:1;height:44px;border:none;border-radius:10px;background:linear-gradient(135deg,#dc2626,#b91c1c);color:#fff;font-size:15px;font-weight:600;cursor:pointer;transition:all 0.15s;box-shadow:0 4px 12px rgba(220,38,38,0.3);font-family:Microsoft YaHei,sans-serif;">
					提交并退出
				</button>
			</div>
		`;
		
		modal2.appendChild(dialog2);
		document.body.appendChild(modal2);
		
		// 取消按钮
		document.getElementById('examExitCancel2').onclick = function() {
			document.body.removeChild(modal2);
		};
		
		// 最终确认按钮 - 自动提交试卷并退出
		document.getElementById('examExitConfirm2').onclick = function() {
			// 显示提交中提示
			dialog2.innerHTML = `
				<div style="text-align:center;padding:20px;">
					<div style="width:48px;height:48px;margin:0 auto 16px;border:3px solid #e2e8f0;border-top-color:#3b82f6;border-radius:50%;animation:spin 0.8s linear infinite;"></div>
					<p style="font-size:15px;color:#64748b;margin:0;">正在提交试卷并退出...</p>
				</div>
			`;
			
			var spinStyle = document.createElement('style');
			spinStyle.textContent = '@keyframes spin { to { transform:rotate(360deg); } }';
			document.head.appendChild(spinStyle);
			
			// 自动提交试卷
			submitExamAndLogout();
		};
	}
	
	// 提交试卷并退出登录
	function submitExamAndLogout() {
		// 查找提交按钮
		var submitBtn = document.getElementById('btnupload');
		
		if (submitBtn && !submitBtn.disabled) {
			// 模拟点击提交按钮
			console.log('自动提交试卷...');
			
			// 触发提交
			try {
				submitBtn.click();
				
				// 等待提交完成后退出（延迟2秒确保提交请求发送）
				setTimeout(function() {
					executeLogout();
				}, 2000);
			} catch(e) {
				console.error('提交失败:', e);
				// 即使提交失败也执行退出
				executeLogout();
			}
		} else {
			console.log('试卷已提交或按钮不可用，直接退出');
			// 如果试卷已提交或按钮不可用，直接退出
			executeLogout();
		}
	}
	
	// 执行退出登录
	function executeLogout() {
		if (typeof window.parent.originalDoScmLogout !== 'undefined') {
			window.parent.originalDoScmLogout();
		} else {
			// 备用退出方法：清除cookie并跳转到学生登录页
			document.cookie.split(';').forEach(function(c) {
				var eqPos = c.indexOf('=');
				var name = eqPos > -1 ? c.substr(0, eqPos).trim() : c.trim();
				document.cookie = name + '=;expires=' + new Date(0).toUTCString() + ';path=/';
				document.cookie = name + '=;expires=' + new Date(0).toUTCString() + ';path=/student';
			});
			window.top.location.href = '../student/';
		}
	}

</script>

</asp:Content>
