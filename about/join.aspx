<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .join-page, .join-page * { margin-right: unset !important; margin-left: unset !important; }

    .join-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: joinFadeIn .4s ease; padding-bottom: 40px;
    }
    @keyframes joinFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* 横幅 */
    .join-banner {
        background: linear-gradient(135deg, #059669 0%, #0d9488 50%, #0891b2 100%) !important;
        border-radius: 16px; padding: 56px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .join-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 180px; height: 180px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .join-banner-deco2 { top: auto; bottom: -50px; right: auto; left: -40px; width: 140px; height: 140px; background: rgba(255,255,255,.04); }
    .join-banner h1 { font-size: 30px; font-weight: 700; color: #fff !important; margin: 0 0 12px !important; position: relative; z-index: 1; }
    .join-banner p { font-size: 15px; color: rgba(255,255,255,.85) !important; margin: 0 !important; position: relative; z-index: 1; line-height: 1.7; }
    .join-banner-icon { margin-bottom: 18px; position: relative; z-index: 1; }
    .join-banner-icon svg { width: 52px; height: 52px; stroke: rgba(255,255,255,.9); fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }

    /* 面包屑 */
    .join-breadcrumb { display: flex !important; align-items: center; gap: 8px; margin-bottom: 28px; font-size: 13px; }
    .join-breadcrumb a { color: #6366f1 !important; text-decoration: none !important; font-weight: 500; transition: color .15s; }
    .join-breadcrumb a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .join-breadcrumb span { color: #94a3b8; }
    .join-breadcrumb .join-bc-current { color: #475569; font-weight: 600; }

    /* 角色卡片 */
    .join-roles {
        display: grid !important; grid-template-columns: repeat(3, 1fr);
        gap: 20px; margin-bottom: 32px;
    }
    @media(max-width:768px) { .join-roles { grid-template-columns: 1fr !important; } }

    .join-role {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        padding: 32px 24px; text-align: center;
        transition: transform .2s ease, box-shadow .2s ease;
        position: relative; overflow: hidden;
    }
    .join-role:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,.08); }
    .join-role-badge {
        position: absolute; top: 14px; right: -28px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff !important; font-size: 11px; font-weight: 700;
        padding: 4px 36px; transform: rotate(45deg);
    }
    .join-role-icon {
        width: 64px; height: 64px; border-radius: 18px;
        display: inline-flex !important; align-items: center; justify-content: center;
        margin-bottom: 18px;
    }
    .join-role-icon svg { width: 28px; height: 28px; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .jri-student { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .jri-student svg { stroke: #2563eb; }
    .jri-teacher { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .jri-teacher svg { stroke: #7c3aed; }
    .jri-admin { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }
    .jri-admin svg { stroke: #ea580c; }

    .join-role h3 { font-size: 17px; font-weight: 700; color: #1e293b !important; margin: 0 0 10px !important; }
    .join-role p { font-size: 13px; color: #64748b !important; margin: 0 0 16px !important; line-height: 1.6; }

    .join-role-features { list-style: none !important; padding: 0 !important; margin: 0 !important; text-align: left; }
    .join-role-features li {
        display: flex !important; align-items: center; gap: 10px;
        padding: 8px 0; font-size: 13px; color: #475569 !important;
        border-bottom: 1px solid #f1f5f9;
    }
    .join-role-features li:last-child { border-bottom: none; }
    .join-role-features li svg {
        width: 16px; height: 16px; stroke: #059669; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }

    /* 加入步骤 */
    .join-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden; margin-bottom: 32px;
    }
    .join-card-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
    }
    .join-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .join-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .jhi-steps { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .jhi-steps svg { stroke: #059669; }
    .jhi-benefit { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .jhi-benefit svg { stroke: #d97706; }
    .jhi-faq { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .jhi-faq svg { stroke: #2563eb; }

    .join-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 !important; }
    .join-card-body { padding: 20px 24px; }

    /* 步骤横排 */
    .join-steps-grid {
        display: grid !important; grid-template-columns: repeat(4, 1fr);
        gap: 20px;
    }
    @media(max-width:768px) { .join-steps-grid { grid-template-columns: repeat(2, 1fr) !important; } }
    @media(max-width:480px) { .join-steps-grid { grid-template-columns: 1fr !important; } }

    .join-step {
        text-align: center; padding: 20px 16px;
        border-radius: 12px; background: #f8fafc; border: 1px solid #f1f5f9;
        transition: all .15s; position: relative;
    }
    .join-step:hover { background: #eef2ff; border-color: #c7d2fe; }
    .join-step-num {
        width: 36px; height: 36px; border-radius: 50%;
        display: inline-flex !important; align-items: center; justify-content: center;
        font-size: 16px; font-weight: 800; color: #fff !important;
        margin-bottom: 12px;
    }
    .jsn-1 { background: linear-gradient(135deg, #6366f1, #818cf8); }
    .jsn-2 { background: linear-gradient(135deg, #059669, #34d399); }
    .jsn-3 { background: linear-gradient(135deg, #d97706, #fbbf24); }
    .jsn-4 { background: linear-gradient(135deg, #db2777, #f472b6); }

    .join-step h4 { font-size: 14px; font-weight: 700; color: #1e293b !important; margin: 0 0 6px !important; }
    .join-step p { font-size: 12px; color: #64748b !important; margin: 0 !important; line-height: 1.5; }

    /* 箭头连接 */
    .join-step::after {
        content: '→'; position: absolute; right: -14px; top: 50%;
        transform: translateY(-50%); font-size: 16px; color: #cbd5e1;
        font-weight: 700;
    }
    .join-step:last-child::after { content: ''; }
    @media(max-width:768px) { .join-step::after { display: none; } }

    /* 双栏 */
    .join-grid {
        display: grid !important; grid-template-columns: 1fr 1fr;
        gap: 24px; margin-bottom: 32px;
    }
    @media(max-width:768px) { .join-grid { grid-template-columns: 1fr !important; } }

    /* 优势列表 */
    .join-benefits { list-style: none !important; padding: 0 !important; margin: 0 !important; }
    .join-benefit-item {
        display: flex !important; align-items: flex-start; gap: 14px;
        padding: 14px 0; border-bottom: 1px solid #f1f5f9;
    }
    .join-benefit-item:last-child { border-bottom: none; }
    .join-benefit-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .join-benefit-icon svg { width: 16px; height: 16px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .jbi-1 { background: #eef2ff; }  .jbi-1 svg { stroke: #6366f1; }
    .jbi-2 { background: #f0fdf4; }  .jbi-2 svg { stroke: #16a34a; }
    .jbi-3 { background: #fff7ed; }  .jbi-3 svg { stroke: #ea580c; }
    .jbi-4 { background: #fdf2f8; }  .jbi-4 svg { stroke: #db2777; }
    .jbi-5 { background: #ecfeff; }  .jbi-5 svg { stroke: #0891b2; }

    .join-benefit-text h4 { font-size: 14px; font-weight: 600; color: #1e293b !important; margin: 0 0 4px !important; }
    .join-benefit-text p { font-size: 13px; color: #64748b !important; margin: 0 !important; line-height: 1.6; }

    /* FAQ */
    .join-faq-item { border-bottom: 1px solid #f1f5f9; }
    .join-faq-item:last-child { border-bottom: none; }
    .join-faq-q {
        display: flex !important; align-items: center; justify-content: space-between;
        padding: 14px 4px; cursor: pointer;
        font-size: 14px; font-weight: 600; color: #334155 !important;
        transition: color .15s; user-select: none;
    }
    .join-faq-q:hover { color: #4f46e5 !important; }
    .join-faq-q svg {
        width: 16px; height: 16px; stroke: #94a3b8;
        fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        transition: transform .25s; flex-shrink: 0; margin-left: 12px;
    }
    .join-faq-item.open .join-faq-q svg { transform: rotate(180deg); }
    .join-faq-item.open .join-faq-q { color: #4f46e5 !important; }
    .join-faq-a {
        max-height: 0; overflow: hidden;
        transition: max-height .3s ease, padding .3s ease;
        padding: 0 4px;
    }
    .join-faq-item.open .join-faq-a { max-height: 300px; padding: 0 4px 14px; }
    .join-faq-a p {
        font-size: 13px; color: #64748b !important; line-height: 1.7;
        margin: 0 !important; background: #f8fafc; border-radius: 8px; padding: 12px 14px;
    }

    /* CTA 区域 */
    .join-cta {
        background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%) !important;
        border-radius: 16px; padding: 40px; text-align: center;
        position: relative; overflow: hidden;
    }
    .join-cta-deco {
        position: absolute; top: -30px; right: -30px;
        width: 140px; height: 140px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .join-cta h3 { font-size: 20px; font-weight: 700; color: #fff !important; margin: 0 0 10px !important; position: relative; z-index: 1; }
    .join-cta p { font-size: 14px; color: rgba(255,255,255,.8) !important; margin: 0 0 22px !important; position: relative; z-index: 1; }
    .join-cta-btn {
        display: inline-flex !important; align-items: center; gap: 8px;
        padding: 12px 32px; border-radius: 10px;
        background: #fff !important; color: #6366f1 !important;
        font-size: 14px; font-weight: 700;
        text-decoration: none !important; transition: all .15s;
        box-shadow: 0 4px 12px rgba(0,0,0,.1);
        position: relative; z-index: 1;
    }
    .join-cta-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,.15); }
    .join-cta-btn svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
</style>

<div class="join-page">
    <!-- 横幅 -->
    <div class="join-banner">
        <div class="join-banner-deco"></div>
        <div class="join-banner-deco join-banner-deco2"></div>
        <div class="join-banner-icon">
            <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
        </div>
        <h1>加入 LearnSite 学习平台</h1>
        <p>无论你是学生、教师还是管理员，都可以快速加入平台，开启高效的信息技术学习之旅。</p>
    </div>

    <!-- 面包屑 -->
    <div class="join-breadcrumb">
        <a href="../about/index.aspx">关于我们</a>
        <span>/</span>
        <span class="join-bc-current">加入我们</span>
    </div>

    <!-- 角色卡片 -->
    <div class="join-roles">
        <div class="join-role">
            <div class="join-role-icon jri-student">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            </div>
            <h3>学生</h3>
            <p>在线学习课程学案，提交作品，参加测试，提升信息素养。</p>
            <ul class="join-role-features">
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>浏览课程学案</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>在线提交作品</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>参与知识测试</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>练习打字技能</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>使用 AI 助手</li>
            </ul>
        </div>
        <div class="join-role">
            <div class="join-role-badge">推荐</div>
            <div class="join-role-icon jri-teacher">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <h3>教师</h3>
            <p>创建和管理课程学案，布置作业，批改评分，掌控教学全流程。</p>
            <ul class="join-role-features">
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>创建课程学案</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>布置与批改作业</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>发布在线测试</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>查看学习统计</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>班级管理功能</li>
            </ul>
        </div>
        <div class="join-role">
            <div class="join-role-icon jri-admin">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
            </div>
            <h3>管理员</h3>
            <p>管理平台系统设置，维护用户数据，配置教学资源和 AI 服务。</p>
            <ul class="join-role-features">
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>系统全局设置</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>用户管理与维护</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>数据备份恢复</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>AI 服务配置</li>
                <li><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>教室环境管理</li>
            </ul>
        </div>
    </div>

    <!-- 加入步骤 -->
    <div class="join-card">
        <div class="join-card-head">
            <span class="join-head-icon jhi-steps"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
            <h3>如何加入？</h3>
        </div>
        <div class="join-card-body">
            <div class="join-steps-grid">
                <div class="join-step">
                    <span class="join-step-num jsn-1">1</span>
                    <h4>联系老师</h4>
                    <p>向班级信息技术老师表达使用平台的意愿</p>
                </div>
                <div class="join-step">
                    <span class="join-step-num jsn-2">2</span>
                    <h4>获取账号</h4>
                    <p>老师会为你创建平台账号并分配初始密码</p>
                </div>
                <div class="join-step">
                    <span class="join-step-num jsn-3">3</span>
                    <h4>首次登录</h4>
                    <p>使用学号和初始密码登录平台，修改密码</p>
                </div>
                <div class="join-step">
                    <span class="join-step-num jsn-4">4</span>
                    <h4>开始学习</h4>
                    <p>浏览学案、提交作品、参与测试，尽情学习</p>
                </div>
            </div>
        </div>
    </div>

    <!-- 双栏 -->
    <div class="join-grid">
        <!-- 平台优势 -->
        <div class="join-card" style="margin-bottom:0;">
            <div class="join-card-head">
                <span class="join-head-icon jhi-benefit"><svg viewBox="0 0 24 24"><path d="M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z"/><path d="M9 18h6"/><path d="M10 22h4"/></svg></span>
                <h3>平台优势</h3>
            </div>
            <div class="join-card-body">
                <ul class="join-benefits">
                    <li class="join-benefit-item">
                        <span class="join-benefit-icon jbi-1"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></span>
                        <div class="join-benefit-text">
                            <h4>校园局域网部署</h4>
                            <p>无需外网连接，校内访问速度快、稳定性高。</p>
                        </div>
                    </li>
                    <li class="join-benefit-item">
                        <span class="join-benefit-icon jbi-2"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
                        <div class="join-benefit-text">
                            <h4>数据安全可控</h4>
                            <p>所有数据存储在校园服务器，隐私安全有保障。</p>
                        </div>
                    </li>
                    <li class="join-benefit-item">
                        <span class="join-benefit-icon jbi-3"><svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></span>
                        <div class="join-benefit-text">
                            <h4>丰富编程环境</h4>
                            <p>内置 Scratch、Python、Blockly 等多种编程工具。</p>
                        </div>
                    </li>
                    <li class="join-benefit-item">
                        <span class="join-benefit-icon jbi-4"><svg viewBox="0 0 24 24"><path d="M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z"/><path d="M9 18h6"/><path d="M10 22h4"/></svg></span>
                        <div class="join-benefit-text">
                            <h4>AI 智能辅助</h4>
                            <p>前沿 AI 技术助力学习，智能问答与创作无缝衔接。</p>
                        </div>
                    </li>
                    <li class="join-benefit-item">
                        <span class="join-benefit-icon jbi-5"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                        <div class="join-benefit-text">
                            <h4>持续更新迭代</h4>
                            <p>十余年不断优化升级，功能日益丰富完善。</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>

        <!-- 常见疑问 -->
        <div class="join-card" style="margin-bottom:0;">
            <div class="join-card-head">
                <span class="join-head-icon jhi-faq"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                <h3>常见疑问</h3>
            </div>
            <div class="join-card-body">
                <div class="join-faq-item">
                    <div class="join-faq-q" onclick="toggleJoinFaq(this)">
                        <span>平台是否免费使用？</span>
                        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="join-faq-a">
                        <p>是的，LearnSite 学习平台对所有在校师生完全免费，无需支付任何费用。</p>
                    </div>
                </div>
                <div class="join-faq-item">
                    <div class="join-faq-q" onclick="toggleJoinFaq(this)">
                        <span>学生可以自己注册账号吗？</span>
                        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="join-faq-a">
                        <p>为保障安全，学生账号由教师或管理员统一创建和管理，暂不支持自助注册。</p>
                    </div>
                </div>
                <div class="join-faq-item">
                    <div class="join-faq-q" onclick="toggleJoinFaq(this)">
                        <span>在家里能使用平台吗？</span>
                        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="join-faq-a">
                        <p>平台默认部署在校园局域网中。如需在家使用，请咨询老师是否开放了外网访问。</p>
                    </div>
                </div>
                <div class="join-faq-item">
                    <div class="join-faq-q" onclick="toggleJoinFaq(this)">
                        <span>支持哪些浏览器？</span>
                        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="join-faq-a">
                        <p>推荐使用最新版 Chrome 或 Edge 浏览器以获得最佳体验，不建议使用 IE 浏览器。</p>
                    </div>
                </div>
                <div class="join-faq-item">
                    <div class="join-faq-q" onclick="toggleJoinFaq(this)">
                        <span>如何让学校也用上这个平台？</span>
                        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="join-faq-a">
                        <p>LearnSite 是开源的信息学习平台，学校的信息技术老师可以自行下载部署。详情可访问项目主页了解更多。</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- CTA -->
    <div class="join-cta">
        <div class="join-cta-deco"></div>
        <h3>准备好开始了吗？</h3>
        <p>联系你的信息技术老师，获取平台账号，开启学习之旅！</p>
        <a href="../help/contact.aspx" class="join-cta-btn">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            联系老师
        </a>
    </div>
</div>

<script type="text/javascript">
    function toggleJoinFaq(el) {
        var item = el.parentElement;
        if (item.classList.contains('open')) {
            item.classList.remove('open');
        } else {
            var items = document.querySelectorAll('.join-faq-item.open');
            for (var i = 0; i < items.length; i++) { items[i].classList.remove('open'); }
            item.classList.add('open');
        }
    }
</script>
</asp:Content>
