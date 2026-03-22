<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* === 覆盖Student主题冲突 === */
    .docs-page, .docs-page * { margin-right: unset !important; margin-left: unset !important; }

    /* === 页面布局 === */
    .docs-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: docsFadeIn .4s ease;
        padding-bottom: 40px;
    }
    @keyframes docsFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* === 顶部横幅 === */
    .docs-banner {
        background: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%) !important;
        border-radius: 16px; padding: 48px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .docs-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .docs-banner-deco2 {
        top: auto; bottom: -50px; right: auto; left: -40px;
        width: 120px; height: 120px;
        background: rgba(255,255,255,.04);
    }
    .docs-banner h1 {
        font-size: 28px; font-weight: 700; color: #fff !important;
        margin: 0 0 10px !important; position: relative; z-index: 1;
    }
    .docs-banner p {
        font-size: 15px; color: rgba(255,255,255,.8) !important;
        margin: 0 !important; position: relative; z-index: 1;
    }
    .docs-banner-icon {
        margin-bottom: 16px; position: relative; z-index: 1;
    }
    .docs-banner-icon svg {
        width: 48px; height: 48px; stroke: rgba(255,255,255,.9);
        fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
    }

    /* === 面包屑 === */
    .docs-breadcrumb {
        display: flex !important; align-items: center; gap: 8px;
        margin-bottom: 24px; font-size: 13px;
    }
    .docs-breadcrumb a {
        color: #6366f1 !important; text-decoration: none !important;
        font-weight: 500; transition: color .15s;
    }
    .docs-breadcrumb a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .docs-breadcrumb span { color: #94a3b8; }
    .docs-breadcrumb .docs-bc-current { color: #475569; font-weight: 600; }

    /* === 双栏布局 === */
    .docs-grid {
        display: grid !important; grid-template-columns: 240px 1fr;
        gap: 28px;
    }
    @media(max-width:900px) {
        .docs-grid { grid-template-columns: 1fr !important; }
        .docs-sidebar { display: none !important; }
    }

    /* === 左侧导航 === */
    .docs-sidebar {
        position: sticky; top: 24px; align-self: start;
    }
    .docs-sidebar-card {
        background: #fff !important; border-radius: 14px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        overflow: hidden;
    }
    .docs-sidebar-title {
        padding: 16px 18px; font-size: 13px; font-weight: 700;
        color: #1e293b !important; border-bottom: 1px solid #f1f5f9;
        display: flex !important; align-items: center; gap: 8px;
    }
    .docs-sidebar-title svg {
        width: 16px; height: 16px; stroke: #6366f1;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .docs-nav-list { list-style: none !important; padding: 8px 0 !important; margin: 0 !important; }
    .docs-nav-item a {
        display: block !important; padding: 9px 18px;
        font-size: 13px; color: #64748b !important;
        text-decoration: none !important; transition: all .15s;
        border-left: 3px solid transparent;
    }
    .docs-nav-item a:hover {
        background: #f8fafc; color: #334155 !important;
        border-left-color: #e2e8f0;
    }
    .docs-nav-item a.active {
        background: #eef2ff; color: #4f46e5 !important;
        font-weight: 600; border-left-color: #6366f1;
    }

    /* === 右侧内容 === */
    .docs-main { min-width: 0; }

    /* === 文档卡片 === */
    .docs-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        margin-bottom: 24px; overflow: hidden;
        transition: box-shadow .2s ease;
    }
    .docs-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04);
    }
    .docs-card-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
        background: #fff !important;
    }
    .docs-card-head .docs-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .docs-head-icon svg {
        width: 18px; height: 18px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .docs-icon-course { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .docs-icon-course svg { stroke: #2563eb; }
    .docs-icon-work { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .docs-icon-work svg { stroke: #7c3aed; }
    .docs-icon-quiz { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .docs-icon-quiz svg { stroke: #059669; }
    .docs-icon-typing { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }
    .docs-icon-typing svg { stroke: #ea580c; }
    .docs-icon-file { background: linear-gradient(135deg, #fce7f3, #fbcfe8) !important; }
    .docs-icon-file svg { stroke: #db2777; }
    .docs-icon-share { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .docs-icon-share svg { stroke: #d97706; }
    .docs-icon-profile { background: linear-gradient(135deg, #e0f2fe, #bae6fd) !important; }
    .docs-icon-profile svg { stroke: #0284c7; }

    .docs-card-head h3 {
        font-size: 16px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important;
    }
    .docs-card-body { padding: 20px 24px; }

    /* === 文档内容样式 === */
    .docs-section { margin-bottom: 20px; }
    .docs-section:last-child { margin-bottom: 0; }
    .docs-section h4 {
        font-size: 14px; font-weight: 700; color: #334155 !important;
        margin: 0 0 10px !important;
        padding-left: 12px; border-left: 3px solid #6366f1;
    }
    .docs-section p {
        font-size: 13px; color: #64748b !important; line-height: 1.8;
        margin: 0 0 10px !important;
    }
    .docs-section p:last-child { margin-bottom: 0 !important; }

    /* 操作步骤 */
    .docs-ol {
        list-style: none !important; padding: 0 !important; margin: 0 !important;
        counter-reset: docs-step;
    }
    .docs-ol li {
        counter-increment: docs-step;
        display: flex !important; align-items: flex-start; gap: 12px;
        padding: 10px 0; font-size: 13px; color: #475569 !important; line-height: 1.7;
        border-bottom: 1px solid #f8fafc;
    }
    .docs-ol li:last-child { border-bottom: none; }
    .docs-ol li::before {
        content: counter(docs-step);
        width: 24px; height: 24px; border-radius: 50%; flex-shrink: 0;
        background: #eef2ff; color: #4f46e5; font-size: 12px; font-weight: 700;
        display: flex; align-items: center; justify-content: center;
        margin-top: 1px;
    }

    /* 提示框 */
    .docs-tip {
        display: flex !important; align-items: flex-start; gap: 10px;
        background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px;
        padding: 12px 16px; margin-top: 12px;
    }
    .docs-tip-icon {
        width: 20px; height: 20px; flex-shrink: 0; margin-top: 1px;
    }
    .docs-tip-icon svg {
        width: 20px; height: 20px; stroke: #16a34a;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .docs-tip p {
        font-size: 13px; color: #15803d !important; line-height: 1.6;
        margin: 0 !important;
    }

    .docs-warn {
        background: #fffbeb; border-color: #fde68a;
    }
    .docs-warn .docs-tip-icon svg { stroke: #d97706; }
    .docs-warn p { color: #a16207 !important; }

    /* 功能列表 */
    .docs-features {
        list-style: none !important; padding: 0 !important; margin: 8px 0 0 !important;
    }
    .docs-features li {
        display: flex !important; align-items: flex-start; gap: 10px;
        padding: 8px 0; font-size: 13px; color: #475569 !important; line-height: 1.6;
    }
    .docs-feat-dot {
        width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; margin-top: 6px;
    }
    .docs-feat-dot-blue { background: linear-gradient(135deg, #6366f1, #818cf8); }
    .docs-feat-dot-green { background: linear-gradient(135deg, #22c55e, #4ade80); }
    .docs-feat-dot-orange { background: linear-gradient(135deg, #f59e0b, #fbbf24); }
    .docs-feat-dot-pink { background: linear-gradient(135deg, #ec4899, #f472b6); }

    /* === 返回顶部 === */
    .docs-back-top {
        position: fixed; bottom: 80px; right: 32px;
        width: 40px; height: 40px; border-radius: 50%;
        background: #fff; border: 1px solid #e5e7eb;
        box-shadow: 0 2px 8px rgba(0,0,0,.08);
        display: none; align-items: center; justify-content: center;
        cursor: pointer; transition: all .2s; z-index: 100;
    }
    .docs-back-top:hover {
        background: #eef2ff; border-color: #c7d2fe;
        box-shadow: 0 4px 12px rgba(99,102,241,.15);
    }
    .docs-back-top svg {
        width: 18px; height: 18px; stroke: #6366f1;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
</style>

<div class="docs-page">
    <!-- 顶部横幅 -->
    <div class="docs-banner">
        <div class="docs-banner-deco"></div>
        <div class="docs-banner-deco docs-banner-deco2"></div>
        <div class="docs-banner-icon">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <h1>使用文档</h1>
        <p>详细的功能说明与操作指南，帮助你高效使用学习平台的每一项功能。</p>
    </div>

    <!-- 面包屑 -->
    <div class="docs-breadcrumb">
        <a href="../help/index.aspx">帮助中心</a>
        <span>/</span>
        <span class="docs-bc-current">使用文档</span>
    </div>

    <!-- 双栏布局 -->
    <div class="docs-grid">
        <!-- 左侧导航 -->
        <aside class="docs-sidebar">
            <div class="docs-sidebar-card">
                <div class="docs-sidebar-title">
                    <svg viewBox="0 0 24 24"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                    文档目录
                </div>
                <ul class="docs-nav-list">
                    <li class="docs-nav-item"><a href="#doc-course" class="active" onclick="docNavClick(this)">我的学案</a></li>
                    <li class="docs-nav-item"><a href="#doc-work" onclick="docNavClick(this)">我的作品</a></li>
                    <li class="docs-nav-item"><a href="#doc-quiz" onclick="docNavClick(this)">常识积累</a></li>
                    <li class="docs-nav-item"><a href="#doc-typing" onclick="docNavClick(this)">打字宝典</a></li>
                    <li class="docs-nav-item"><a href="#doc-file" onclick="docNavClick(this)">在线资源</a></li>
                    <li class="docs-nav-item"><a href="#doc-share" onclick="docNavClick(this)">我的网盘</a></li>
                    <li class="docs-nav-item"><a href="#doc-profile" onclick="docNavClick(this)">个人设置</a></li>
                </ul>
            </div>
        </aside>

        <!-- 右侧文档内容 -->
        <div class="docs-main">

            <!-- 我的学案 -->
            <div class="docs-card" id="doc-course">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-course"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
                    <h3>我的学案</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>"我的学案"是学习平台的核心模块，用于展示老师发布的课程学案。页面分为"未学学案"和"已学学案"两部分，帮助你清晰了解学习进度。</p>
                    </div>
                    <div class="docs-section">
                        <h4>主要功能</h4>
                        <ul class="docs-features">
                            <li><span class="docs-feat-dot docs-feat-dot-blue"></span>查看未学学案列表，当前课程会有高亮标识</li>
                            <li><span class="docs-feat-dot docs-feat-dot-green"></span>查看已学学案及学习进度（进度条显示完成比例）</li>
                            <li><span class="docs-feat-dot docs-feat-dot-orange"></span>点击学案标题进入详细学习页面</li>
                            <li><span class="docs-feat-dot docs-feat-dot-pink"></span>查看今日签到同学列表</li>
                        </ul>
                    </div>
                    <div class="docs-section">
                        <h4>操作步骤</h4>
                        <ol class="docs-ol">
                            <li>登录平台后自动进入"我的学案"页面</li>
                            <li>在"未学学案"区域查看待学习的课程，标注"本节课"的为当前正在进行的学案</li>
                            <li>点击学案标题进入学习页面，按照页面内容完成学习</li>
                            <li>学习完成后，该学案会自动移至"已学学案"区域，并显示进度</li>
                            <li>在右侧个人信息栏可查看学号、班级、小组等信息</li>
                        </ol>
                    </div>
                    <div class="docs-tip">
                        <span class="docs-tip-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                        <p>建议按照学案的发布顺序依次学习，不要跳过中间的课程内容，这样学习效果最佳。</p>
                    </div>
                </div>
            </div>

            <!-- 我的作品 -->
            <div class="docs-card" id="doc-work">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-work"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></span>
                    <h3>我的作品</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>"我的作品"页面用于管理课程作业的提交与查看。你可以在这里上传作品文件、查看已提交的作品以及下载其他同学分享的优秀作品。</p>
                    </div>
                    <div class="docs-section">
                        <h4>主要功能</h4>
                        <ul class="docs-features">
                            <li><span class="docs-feat-dot docs-feat-dot-blue"></span>上传课程作业文件（支持多种格式）</li>
                            <li><span class="docs-feat-dot docs-feat-dot-green"></span>查看已提交作品的状态与评价</li>
                            <li><span class="docs-feat-dot docs-feat-dot-orange"></span>下载和浏览优秀作品</li>
                            <li><span class="docs-feat-dot docs-feat-dot-pink"></span>查看老师对作品的评语和打分</li>
                        </ul>
                    </div>
                    <div class="docs-section">
                        <h4>操作步骤</h4>
                        <ol class="docs-ol">
                            <li>点击顶部导航栏中的"我的作品"进入页面</li>
                            <li>找到需要提交作品的课程，点击上传按钮</li>
                            <li>选择本地文件并确认上传，等待上传完成</li>
                            <li>上传成功后可在列表中查看作品状态</li>
                            <li>老师批改后，可查看评语和分数</li>
                        </ol>
                    </div>
                    <div class="docs-tip docs-warn">
                        <span class="docs-tip-icon"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                        <p>上传前请检查文件格式和大小是否符合老师的要求，提交后如需修改请在截止时间前重新上传。</p>
                    </div>
                </div>
            </div>

            <!-- 常识积累 -->
            <div class="docs-card" id="doc-quiz">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-quiz"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                    <h3>常识积累</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>"常识积累"是在线答题测评模块，老师可以发布各类知识测试，帮助同学们巩固信息技术基础知识和常识。</p>
                    </div>
                    <div class="docs-section">
                        <h4>主要功能</h4>
                        <ul class="docs-features">
                            <li><span class="docs-feat-dot docs-feat-dot-blue"></span>查看可参加的答题任务列表</li>
                            <li><span class="docs-feat-dot docs-feat-dot-green"></span>在线答题，支持选择题、判断题等题型</li>
                            <li><span class="docs-feat-dot docs-feat-dot-orange"></span>答题完成后自动评分</li>
                            <li><span class="docs-feat-dot docs-feat-dot-pink"></span>查看历史答题记录和正确率统计</li>
                        </ul>
                    </div>
                    <div class="docs-section">
                        <h4>操作步骤</h4>
                        <ol class="docs-ol">
                            <li>点击顶部导航栏中的"常识积累"进入页面</li>
                            <li>在答题列表中选择一项可用的测试</li>
                            <li>仔细阅读每道题目，选择你认为正确的答案</li>
                            <li>所有题目作答完毕后，点击提交按钮</li>
                            <li>系统自动评分，你可以查看每道题的对错情况</li>
                        </ol>
                    </div>
                    <div class="docs-tip">
                        <span class="docs-tip-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                        <p>答题时注意时间限制（如有），建议先做有把握的题目，最后再检查不确定的题目。</p>
                    </div>
                </div>
            </div>

            <!-- 打字宝典 -->
            <div class="docs-card" id="doc-typing">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-typing"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2" ry="2"/><path d="M7 16h10"/></svg></span>
                    <h3>打字宝典</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>"打字宝典"提供在线打字练习功能，支持中英文打字训练，帮助你提升键盘输入速度和准确率。系统会记录每次练习成绩，方便追踪进步。</p>
                    </div>
                    <div class="docs-section">
                        <h4>主要功能</h4>
                        <ul class="docs-features">
                            <li><span class="docs-feat-dot docs-feat-dot-blue"></span>英文打字练习与中文打字练习</li>
                            <li><span class="docs-feat-dot docs-feat-dot-green"></span>实时显示打字速度（字/分钟）和准确率</li>
                            <li><span class="docs-feat-dot docs-feat-dot-orange"></span>查看个人打字成绩排行</li>
                            <li><span class="docs-feat-dot docs-feat-dot-pink"></span>与班级同学的成绩对比</li>
                        </ul>
                    </div>
                    <div class="docs-section">
                        <h4>操作步骤</h4>
                        <ol class="docs-ol">
                            <li>点击顶部导航栏中的"打字宝典"进入页面</li>
                            <li>选择练习类型（英文/中文）</li>
                            <li>准备好后开始打字，屏幕会显示需要输入的文本内容</li>
                            <li>按照提示内容准确输入，注意大小写和标点</li>
                            <li>完成后查看本次打字速度和准确率统计</li>
                        </ol>
                    </div>
                    <div class="docs-tip">
                        <span class="docs-tip-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                        <p>打字练习贵在坚持，建议每天抽出 10-15 分钟练习，注意正确的指法姿势，速度会逐步提高。</p>
                    </div>
                </div>
            </div>

            <!-- 在线资源 -->
            <div class="docs-card" id="doc-file">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-file"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg></span>
                    <h3>在线资源</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>"在线资源"提供老师上传的各类学习资料下载，包括课件、参考文档、软件工具等。你可以根据需要下载到本地使用。</p>
                    </div>
                    <div class="docs-section">
                        <h4>操作步骤</h4>
                        <ol class="docs-ol">
                            <li>点击顶部导航栏中的"在线资源"进入页面</li>
                            <li>浏览可用的资源文件列表</li>
                            <li>找到需要的文件，点击下载按钮保存到本地</li>
                            <li>下载完成后在本地使用对应软件打开文件</li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- 我的网盘 -->
            <div class="docs-card" id="doc-share">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-share"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></span>
                    <h3>我的网盘</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>"我的网盘"是个人文件存储空间，你可以上传文件到网盘进行保存和管理，也可以将文件分享给小组成员。</p>
                    </div>
                    <div class="docs-section">
                        <h4>主要功能</h4>
                        <ul class="docs-features">
                            <li><span class="docs-feat-dot docs-feat-dot-blue"></span>上传个人文件到云端存储</li>
                            <li><span class="docs-feat-dot docs-feat-dot-green"></span>管理已上传的文件（查看、删除）</li>
                            <li><span class="docs-feat-dot docs-feat-dot-orange"></span>与小组成员分享文件</li>
                            <li><span class="docs-feat-dot docs-feat-dot-pink"></span>下载小组成员分享的文件</li>
                        </ul>
                    </div>
                    <div class="docs-section">
                        <h4>操作步骤</h4>
                        <ol class="docs-ol">
                            <li>点击顶部导航栏中的"我的网盘"进入页面</li>
                            <li>点击上传按钮选择本地文件上传到网盘</li>
                            <li>上传成功后可在文件列表中查看和管理</li>
                            <li>选择需要分享的文件，发送给小组成员</li>
                        </ol>
                    </div>
                    <div class="docs-tip docs-warn">
                        <span class="docs-tip-icon"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                        <p>网盘空间有限，请定期清理不需要的文件。不要上传与学习无关的内容。</p>
                    </div>
                </div>
            </div>

            <!-- 个人设置 -->
            <div class="docs-card" id="doc-profile">
                <div class="docs-card-head">
                    <span class="docs-head-icon docs-icon-profile"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                    <h3>个人设置</h3>
                </div>
                <div class="docs-card-body">
                    <div class="docs-section">
                        <h4>功能简介</h4>
                        <p>通过右上角的用户菜单，你可以访问各项个人设置功能，包括查看小组信息、修改密码和更换头像。</p>
                    </div>
                    <div class="docs-section">
                        <h4>修改密码</h4>
                        <ol class="docs-ol">
                            <li>点击右上角用户头像，选择"修改密码"</li>
                            <li>输入当前密码进行身份验证</li>
                            <li>输入新密码并确认，点击保存</li>
                        </ol>
                    </div>
                    <div class="docs-section">
                        <h4>修改头像</h4>
                        <ol class="docs-ol">
                            <li>点击右上角用户头像，选择"修改头像"</li>
                            <li>选择一张图片作为新头像</li>
                            <li>确认上传后头像即时更新</li>
                        </ol>
                    </div>
                    <div class="docs-section">
                        <h4>查看小组</h4>
                        <ol class="docs-ol">
                            <li>点击右上角用户头像，选择"我的小组"</li>
                            <li>查看小组成员列表和小组信息</li>
                            <li>小组讨论功能也可通过此入口访问</li>
                        </ol>
                    </div>
                    <div class="docs-tip">
                        <span class="docs-tip-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                        <p>首次登录后请及时修改初始密码。头像建议使用清晰的正面照片，方便老师和同学识别。</p>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- 返回顶部按钮 -->
<div class="docs-back-top" id="docsBackTop" onclick="docsScrollTop()">
    <svg viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"/></svg>
</div>

<script type="text/javascript">
    // 切换显示对应文档区块，隐藏其他
    function docNavClick(el) {
        // 更新导航高亮
        var links = document.querySelectorAll('.docs-nav-item a');
        for (var i = 0; i < links.length; i++) {
            links[i].classList.remove('active');
        }
        el.classList.add('active');

        // 获取目标 id
        var targetId = el.getAttribute('href').substring(1);

        // 隐藏所有文档卡片，只显示目标
        var cards = document.querySelectorAll('.docs-card[id]');
        for (var j = 0; j < cards.length; j++) {
            if (cards[j].getAttribute('id') === targetId) {
                cards[j].style.display = '';
            } else {
                cards[j].style.display = 'none';
            }
        }

        // 滚动到顶部
        var docsContent = document.querySelector('.stu-content');
        if (docsContent) {
            docsContent.scrollTo({ top: 0, behavior: 'smooth' });
        }
    }

    // 页面加载时：默认只显示第一个文档区块
    (function () {
        var cards = document.querySelectorAll('.docs-card[id]');
        for (var i = 0; i < cards.length; i++) {
            if (i === 0) {
                cards[i].style.display = '';
            } else {
                cards[i].style.display = 'none';
            }
        }
    })();

    // 阻止导航链接默认跳转
    var navLinks = document.querySelectorAll('.docs-nav-item a');
    for (var i = 0; i < navLinks.length; i++) {
        navLinks[i].addEventListener('click', function (e) {
            e.preventDefault();
        });
    }

    // 返回顶部按钮
    var docsContent = document.querySelector('.stu-content');
    if (docsContent) {
        docsContent.addEventListener('scroll', function () {
            var btn = document.getElementById('docsBackTop');
            if (btn) {
                btn.style.display = docsContent.scrollTop > 300 ? 'flex' : 'none';
            }
        });
    }

    // 返回顶部
    function docsScrollTop() {
        var c = document.querySelector('.stu-content');
        if (c) { c.scrollTo({ top: 0, behavior: 'smooth' }); }
    }
</script>
</asp:Content>
