<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* === 覆盖Student主题冲突 === */
    .help-page, .help-page * { margin-right: unset !important; margin-left: unset !important; }

    /* === 页面布局 === */
    .help-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: helpFadeIn .4s ease;
        padding-bottom: 40px;
    }
    @keyframes helpFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* === 顶部横幅 === */
    .help-banner {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
        border-radius: 16px; padding: 48px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .help-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .help-banner-deco2 {
        top: auto; bottom: -50px; right: auto; left: -40px;
        width: 120px; height: 120px;
        background: rgba(255,255,255,.04);
    }
    .help-banner h1 {
        font-size: 28px; font-weight: 700; color: #fff !important;
        margin: 0 0 10px !important; position: relative; z-index: 1;
    }
    .help-banner p {
        font-size: 15px; color: rgba(255,255,255,.8) !important;
        margin: 0 !important; position: relative; z-index: 1;
    }
    .help-banner-icon {
        margin-bottom: 16px; position: relative; z-index: 1;
    }
    .help-banner-icon svg {
        width: 48px; height: 48px; stroke: rgba(255,255,255,.9);
        fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
    }

    /* === 快捷入口网格 === */
    .help-quick-grid {
        display: grid !important; grid-template-columns: repeat(4, 1fr);
        gap: 20px; margin-bottom: 32px;
    }
    @media(max-width:900px) { .help-quick-grid { grid-template-columns: repeat(2, 1fr) !important; } }
    @media(max-width:520px) { .help-quick-grid { grid-template-columns: 1fr !important; } }

    .help-quick-item {
        background: #fff !important; border-radius: 14px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        padding: 28px 22px; text-align: center;
        transition: transform .2s ease, box-shadow .2s ease;
        text-decoration: none !important; display: block !important;
        cursor: pointer;
    }
    .help-quick-item:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(99,102,241,.12);
        border-color: #c7d2fe !important;
    }
    .help-quick-icon {
        width: 52px; height: 52px; border-radius: 14px;
        display: inline-flex !important; align-items: center; justify-content: center;
        margin-bottom: 14px;
    }
    .help-quick-icon svg {
        width: 24px; height: 24px; fill: none;
        stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
    }
    .help-quick-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .help-quick-icon-blue svg { stroke: #2563eb; }
    .help-quick-icon-purple { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .help-quick-icon-purple svg { stroke: #7c3aed; }
    .help-quick-icon-green { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .help-quick-icon-green svg { stroke: #059669; }
    .help-quick-icon-orange { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }
    .help-quick-icon-orange svg { stroke: #ea580c; }

    .help-quick-item h3 {
        font-size: 15px; font-weight: 700; color: #1e293b !important;
        margin: 0 0 6px !important;
    }
    .help-quick-item p {
        font-size: 13px; color: #64748b !important; margin: 0 !important;
        line-height: 1.5;
    }

    /* === 内容区域双栏 === */
    .help-grid {
        display: grid !important; grid-template-columns: 1fr 380px;
        gap: 24px;
    }
    @media(max-width:900px) { .help-grid { grid-template-columns: 1fr !important; } }

    /* === 卡片 === */
    .help-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        margin-bottom: 22px; overflow: hidden;
        transition: transform .2s ease, box-shadow .2s ease;
    }
    .help-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04);
    }
    .help-card-head {
        padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
        background: #fff !important;
    }
    .help-card-head .help-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .help-head-icon svg {
        width: 18px; height: 18px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .help-head-icon-faq { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .help-head-icon-faq svg { stroke: #d97706; }
    .help-head-icon-guide { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .help-head-icon-guide svg { stroke: #2563eb; }
    .help-head-icon-contact { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .help-head-icon-contact svg { stroke: #7c3aed; }
    .help-head-icon-tip { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .help-head-icon-tip svg { stroke: #059669; }

    .help-card-head h3 {
        font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important;
    }
    .help-card-body { padding: 8px 22px 18px; }

    /* === FAQ 折叠列表 === */
    .help-faq-item {
        border-bottom: 1px solid #f1f5f9;
        padding: 0;
    }
    .help-faq-item:last-child { border-bottom: none; }
    .help-faq-q {
        display: flex !important; align-items: center; justify-content: space-between;
        padding: 14px 4px; cursor: pointer;
        font-size: 14px; font-weight: 600; color: #334155 !important;
        transition: color .15s; user-select: none;
    }
    .help-faq-q:hover { color: #4f46e5 !important; }
    .help-faq-q svg {
        width: 16px; height: 16px; stroke: #94a3b8;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        transition: transform .25s; flex-shrink: 0; margin-left: 12px;
    }
    .help-faq-item.open .help-faq-q svg { transform: rotate(180deg); }
    .help-faq-item.open .help-faq-q { color: #4f46e5 !important; }
    .help-faq-a {
        max-height: 0; overflow: hidden;
        transition: max-height .3s ease, padding .3s ease;
        padding: 0 4px;
    }
    .help-faq-item.open .help-faq-a {
        max-height: 300px; padding: 0 4px 14px;
    }
    .help-faq-a p {
        font-size: 13px; color: #64748b !important; line-height: 1.7;
        margin: 0 !important; background: #f8fafc; border-radius: 8px; padding: 12px 14px;
    }

    /* === 操作步骤列表 === */
    .help-steps { list-style: none !important; padding: 0 !important; margin: 8px 0 0 !important; }
    .help-step-item {
        display: flex !important; align-items: flex-start; gap: 14px;
        padding: 12px 4px; border-bottom: 1px solid #f1f5f9;
        transition: background .12s;
    }
    .help-step-item:last-child { border-bottom: none; }
    .help-step-item:hover { background: #f8fafc; border-radius: 8px; }
    .help-step-num {
        width: 28px; height: 28px; border-radius: 50%;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff !important; font-size: 13px; font-weight: 700;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0; margin-top: 1px;
    }
    .help-step-content h4 {
        font-size: 14px; font-weight: 600; color: #1e293b !important;
        margin: 0 0 4px !important;
    }
    .help-step-content p {
        font-size: 13px; color: #64748b !important; margin: 0 !important; line-height: 1.5;
    }

    /* === 联系方式卡片 === */
    .help-contact-item {
        display: flex !important; align-items: center; gap: 14px;
        padding: 14px 8px; border-bottom: 1px solid #f1f5f9;
        transition: background .12s; border-radius: 8px;
    }
    .help-contact-item:last-child { border-bottom: none; }
    .help-contact-item:hover { background: #f8fafc; }
    .help-contact-icon {
        width: 40px; height: 40px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .help-contact-icon svg {
        width: 18px; height: 18px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .help-ci-teacher { background: #eef2ff; }
    .help-ci-teacher svg { stroke: #6366f1; }
    .help-ci-time { background: #f0fdf4; }
    .help-ci-time svg { stroke: #16a34a; }
    .help-ci-place { background: #fff7ed; }
    .help-ci-place svg { stroke: #ea580c; }
    .help-contact-text h4 {
        font-size: 13px; font-weight: 600; color: #1e293b !important; margin: 0 0 2px !important;
    }
    .help-contact-text p {
        font-size: 12px; color: #64748b !important; margin: 0 !important;
    }

    /* === 小贴士 === */
    .help-tips { list-style: none !important; padding: 0 !important; margin: 8px 0 0 !important; }
    .help-tip-item {
        display: flex !important; align-items: flex-start; gap: 10px;
        padding: 10px 4px; font-size: 13px; color: #475569 !important; line-height: 1.6;
    }
    .help-tip-dot {
        width: 8px; height: 8px; border-radius: 50%;
        background: linear-gradient(135deg, #6366f1, #a78bfa);
        flex-shrink: 0; margin-top: 6px;
    }
</style>

<div class="help-page">
    <!-- 顶部横幅 -->
    <div class="help-banner">
        <div class="help-banner-deco"></div>
        <div class="help-banner-deco help-banner-deco2"></div>
        <div class="help-banner-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        </div>
        <h1>帮助中心</h1>
        <p>欢迎使用学习平台！在这里你可以找到常见问题的解答和操作指南。</p>
    </div>

    <!-- 快捷入口 -->
    <div class="help-quick-grid">
        <a href="../student/myinfo.aspx" class="help-quick-item">
            <div class="help-quick-icon help-quick-icon-blue">
                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            </div>
            <h3>我的学案</h3>
            <p>查看和学习课程学案</p>
        </a>
        <a href="../student/mywork.aspx" class="help-quick-item">
            <div class="help-quick-icon help-quick-icon-purple">
                <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
            </div>
            <h3>我的作品</h3>
            <p>提交和管理课程作品</p>
        </a>
        <a href="../student/myquiz.aspx" class="help-quick-item">
            <div class="help-quick-icon help-quick-icon-green">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
            <h3>常识积累</h3>
            <p>在线答题测试知识</p>
        </a>
        <a href="../student/myfinger.aspx" class="help-quick-item">
            <div class="help-quick-icon help-quick-icon-orange">
                <svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2" ry="2"/><path d="M7 16h10"/></svg>
            </div>
            <h3>打字宝典</h3>
            <p>练习打字提升速度</p>
        </a>
    </div>

    <!-- 主内容双栏 -->
    <div class="help-grid">
        <!-- 左侧 -->
        <div class="help-main">
            <!-- 常见问题 -->
            <div class="help-card">
                <div class="help-card-head">
                    <span class="help-head-icon help-head-icon-faq"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                    <h3>常见问题</h3>
                </div>
                <div class="help-card-body">
                    <div class="help-faq-item">
                        <div class="help-faq-q" onclick="toggleFaq(this)">
                            <span>如何登录学习平台？</span>
                            <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="help-faq-a">
                            <p>在登录页面输入你的学号和密码即可登录。初始密码通常由老师分配，登录后建议立即修改密码。如忘记密码，请联系班级老师重置。</p>
                        </div>
                    </div>
                    <div class="help-faq-item">
                        <div class="help-faq-q" onclick="toggleFaq(this)">
                            <span>如何提交作品？</span>
                            <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="help-faq-a">
                            <p>进入"我的作品"页面，找到对应的课程作业，点击上传按钮选择你的作品文件进行提交。支持多种文件格式，请注意文件大小限制。</p>
                        </div>
                    </div>
                    <div class="help-faq-item">
                        <div class="help-faq-q" onclick="toggleFaq(this)">
                            <span>如何查看课程学案？</span>
                            <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="help-faq-a">
                            <p>在"我的学案"页面可以查看所有课程学案。未学的学案会显示在上方列表，点击学案标题即可进入学习页面。学习完成后会自动记录进度。</p>
                        </div>
                    </div>
                    <div class="help-faq-item">
                        <div class="help-faq-q" onclick="toggleFaq(this)">
                            <span>如何修改个人密码？</span>
                            <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="help-faq-a">
                            <p>点击页面右上角的用户头像，在下拉菜单中选择"修改密码"，按提示输入旧密码和新密码即可完成修改。建议定期更换密码以确保账号安全。</p>
                        </div>
                    </div>
                    <div class="help-faq-item">
                        <div class="help-faq-q" onclick="toggleFaq(this)">
                            <span>如何参加常识积累答题？</span>
                            <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="help-faq-a">
                            <p>进入"常识积累"页面，选择可用的答题任务开始答题。答题完成后系统会自动评分并记录成绩。你可以查看历史答题记录和正确率。</p>
                        </div>
                    </div>
                    <div class="help-faq-item">
                        <div class="help-faq-q" onclick="toggleFaq(this)">
                            <span>如何使用小组讨论功能？</span>
                            <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="help-faq-a">
                            <p>点击页面右上角的聊天图标，或在用户菜单中选择"小组讨论"即可打开讨论窗口。你可以与小组成员实时交流学习心得和问题。</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 快速上手 -->
            <div class="help-card">
                <div class="help-card-head">
                    <span class="help-head-icon help-head-icon-guide"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                    <h3>快速上手指南</h3>
                </div>
                <div class="help-card-body">
                    <ul class="help-steps">
                        <li class="help-step-item">
                            <span class="help-step-num">1</span>
                            <div class="help-step-content">
                                <h4>登录平台</h4>
                                <p>使用老师分配的学号和密码登录学习平台，进入学生主页。</p>
                            </div>
                        </li>
                        <li class="help-step-item">
                            <span class="help-step-num">2</span>
                            <div class="help-step-content">
                                <h4>查看学案</h4>
                                <p>在"我的学案"中查看未学和已学课程，点击学案标题开始学习。</p>
                            </div>
                        </li>
                        <li class="help-step-item">
                            <span class="help-step-num">3</span>
                            <div class="help-step-content">
                                <h4>提交作品</h4>
                                <p>完成课程学习后，在"我的作品"页面上传并提交你的作品文件。</p>
                            </div>
                        </li>
                        <li class="help-step-item">
                            <span class="help-step-num">4</span>
                            <div class="help-step-content">
                                <h4>完成测试</h4>
                                <p>前往"常识积累"页面完成老师布置的答题任务，巩固学习成果。</p>
                            </div>
                        </li>
                        <li class="help-step-item">
                            <span class="help-step-num">5</span>
                            <div class="help-step-content">
                                <h4>练习打字</h4>
                                <p>在"打字宝典"中进行打字练习，提升键盘输入速度与准确率。</p>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 右侧 -->
        <div class="help-sidebar">
            <!-- 联系方式 -->
            <div class="help-card">
                <div class="help-card-head">
                    <span class="help-head-icon help-head-icon-contact"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></span>
                    <h3>需要帮助？</h3>
                </div>
                <div class="help-card-body">
                    <div class="help-contact-item">
                        <div class="help-contact-icon help-ci-teacher">
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                        <div class="help-contact-text">
                            <h4>联系老师</h4>
                            <p>遇到问题请及时向班级老师求助</p>
                        </div>
                    </div>
                    <div class="help-contact-item">
                        <div class="help-contact-icon help-ci-time">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                        <div class="help-contact-text">
                            <h4>服务时间</h4>
                            <p>工作日 8:00 - 17:00</p>
                        </div>
                    </div>
                    <div class="help-contact-item">
                        <div class="help-contact-icon help-ci-place">
                            <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        </div>
                        <div class="help-contact-text">
                            <h4>信息教室</h4>
                            <p>现场操作问题可到机房寻求帮助</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 使用小贴士 -->
            <div class="help-card">
                <div class="help-card-head">
                    <span class="help-head-icon help-head-icon-tip"><svg viewBox="0 0 24 24"><path d="M9 18h6"/><path d="M10 22h4"/><path d="M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z"/></svg></span>
                    <h3>使用小贴士</h3>
                </div>
                <div class="help-card-body">
                    <ul class="help-tips">
                        <li class="help-tip-item">
                            <span class="help-tip-dot"></span>
                            <span>登录后请及时修改初始密码，确保账号安全。</span>
                        </li>
                        <li class="help-tip-item">
                            <span class="help-tip-dot"></span>
                            <span>提交作品前检查文件格式与大小是否符合要求。</span>
                        </li>
                        <li class="help-tip-item">
                            <span class="help-tip-dot"></span>
                            <span>学案页面按顺序学习效果更好，不要跳过步骤。</span>
                        </li>
                        <li class="help-tip-item">
                            <span class="help-tip-dot"></span>
                            <span>打字练习建议每天坚持，逐步提高速度目标。</span>
                        </li>
                        <li class="help-tip-item">
                            <span class="help-tip-dot"></span>
                            <span>善用小组讨论功能，与同学互相交流学习。</span>
                        </li>
                        <li class="help-tip-item">
                            <span class="help-tip-dot"></span>
                            <span>定期查看"在线资源"获取更多学习资料。</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    // FAQ 折叠展开
    function toggleFaq(el) {
        var item = el.parentElement;
        if (item.classList.contains('open')) {
            item.classList.remove('open');
        } else {
            // 关闭其他已展开项
            var items = document.querySelectorAll('.help-faq-item.open');
            for (var i = 0; i < items.length; i++) {
                items[i].classList.remove('open');
            }
            item.classList.add('open');
        }
    }
</script>
</asp:Content>
