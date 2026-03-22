<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .faq-page, .faq-page * { margin-right: unset !important; margin-left: unset !important; }

    .faq-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: faqFadeIn .4s ease; padding-bottom: 40px;
    }
    @keyframes faqFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* 横幅 */
    .faq-banner {
        background: linear-gradient(135deg, #f59e0b 0%, #ef4444 100%) !important;
        border-radius: 16px; padding: 48px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .faq-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .faq-banner-deco2 { top: auto; bottom: -50px; right: auto; left: -40px; width: 120px; height: 120px; background: rgba(255,255,255,.04); }
    .faq-banner h1 { font-size: 28px; font-weight: 700; color: #fff !important; margin: 0 0 10px !important; position: relative; z-index: 1; }
    .faq-banner p { font-size: 15px; color: rgba(255,255,255,.85) !important; margin: 0 !important; position: relative; z-index: 1; }
    .faq-banner-icon { margin-bottom: 16px; position: relative; z-index: 1; }
    .faq-banner-icon svg { width: 48px; height: 48px; stroke: rgba(255,255,255,.9); fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }

    /* 面包屑 */
    .faq-breadcrumb { display: flex !important; align-items: center; gap: 8px; margin-bottom: 28px; font-size: 13px; }
    .faq-breadcrumb a { color: #6366f1 !important; text-decoration: none !important; font-weight: 500; transition: color .15s; }
    .faq-breadcrumb a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .faq-breadcrumb span { color: #94a3b8; }
    .faq-breadcrumb .faq-bc-current { color: #475569; font-weight: 600; }

    /* 分类标签 */
    .faq-tabs {
        display: flex !important; align-items: center; gap: 8px;
        margin-bottom: 28px; flex-wrap: wrap;
    }
    .faq-tab {
        display: inline-flex !important; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 20px;
        font-size: 13px; font-weight: 600; cursor: pointer;
        border: 1.5px solid #e2e8f0; background: #fff !important;
        color: #64748b !important; transition: all .15s;
        text-decoration: none !important;
    }
    .faq-tab:hover { border-color: #c7d2fe; background: #f8fafc !important; color: #4f46e5 !important; }
    .faq-tab.active { background: linear-gradient(135deg, #6366f1, #818cf8) !important; color: #fff !important; border-color: transparent; box-shadow: 0 2px 8px rgba(99,102,241,.2); }
    .faq-tab svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 分类区块 */
    .faq-category { margin-bottom: 28px; }
    .faq-category-head {
        display: flex !important; align-items: center; gap: 12px;
        margin-bottom: 14px; padding-bottom: 12px; border-bottom: 2px solid #f1f5f9;
    }
    .faq-cat-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .faq-cat-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .faq-ci-account { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .faq-ci-account svg { stroke: #2563eb; }
    .faq-ci-course { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .faq-ci-course svg { stroke: #7c3aed; }
    .faq-ci-work { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .faq-ci-work svg { stroke: #059669; }
    .faq-ci-quiz { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .faq-ci-quiz svg { stroke: #d97706; }
    .faq-ci-typing { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }
    .faq-ci-typing svg { stroke: #ea580c; }
    .faq-ci-other { background: linear-gradient(135deg, #fce7f3, #fbcfe8) !important; }
    .faq-ci-other svg { stroke: #db2777; }

    .faq-category-head h2 { font-size: 16px; font-weight: 700; color: #1e293b !important; margin: 0 !important; }
    .faq-category-head .faq-count {
        font-size: 12px; font-weight: 600; color: #94a3b8;
        background: #f1f5f9; padding: 2px 10px; border-radius: 10px; margin-left: auto !important;
    }

    /* FAQ 卡片 */
    .faq-card {
        background: #fff !important; border-radius: 12px; border: 1px solid #e5e7eb !important;
        margin-bottom: 10px; overflow: hidden;
        transition: box-shadow .2s ease, border-color .2s ease;
    }
    .faq-card:hover { box-shadow: 0 2px 10px rgba(0,0,0,.04); border-color: #d1d5db !important; }
    .faq-card.open { border-color: #c7d2fe !important; box-shadow: 0 2px 12px rgba(99,102,241,.08); }

    .faq-q {
        display: flex !important; align-items: center; justify-content: space-between;
        padding: 16px 20px; cursor: pointer; transition: background .12s; user-select: none;
    }
    .faq-q:hover { background: #fafbfc; }
    .faq-q-text { font-size: 14px; font-weight: 600; color: #334155 !important; flex: 1; line-height: 1.5; }
    .faq-card.open .faq-q-text { color: #4f46e5 !important; }
    .faq-q-arrow {
        width: 20px; height: 20px; flex-shrink: 0; margin-left: 16px;
        stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        transition: transform .25s, stroke .25s;
    }
    .faq-card.open .faq-q-arrow { transform: rotate(180deg); stroke: #6366f1; }

    .faq-a {
        max-height: 0; overflow: hidden;
        transition: max-height .35s ease, padding .3s ease;
        padding: 0 20px;
    }
    .faq-card.open .faq-a { max-height: 500px; padding: 0 20px 18px; }
    .faq-a-inner {
        background: #f8fafc; border-radius: 10px; padding: 14px 18px;
        font-size: 13px; color: #64748b !important; line-height: 1.8;
    }
    .faq-a-inner p { margin: 0 0 8px !important; }
    .faq-a-inner p:last-child { margin-bottom: 0 !important; }
    .faq-a-inner ol, .faq-a-inner ul { padding-left: 20px !important; margin: 6px 0 !important; }
    .faq-a-inner li { margin-bottom: 4px; font-size: 13px; color: #64748b !important; line-height: 1.7; }

    /* 底部提示 */
    .faq-footer {
        background: #fff !important; border-radius: 14px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        padding: 28px 32px; text-align: center; margin-top: 12px;
    }
    .faq-footer h3 { font-size: 16px; font-weight: 700; color: #1e293b !important; margin: 0 0 8px !important; }
    .faq-footer p { font-size: 13px; color: #64748b !important; margin: 0 0 16px !important; }
    .faq-footer-link {
        display: inline-flex !important; align-items: center; gap: 6px;
        padding: 10px 24px; border-radius: 8px;
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important; font-size: 13px; font-weight: 600;
        text-decoration: none !important; transition: all .15s;
        box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .faq-footer-link:hover { background: linear-gradient(135deg, #4f46e5, #6366f1) !important; box-shadow: 0 4px 12px rgba(99,102,241,.3); }
    .faq-footer-link svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
</style>

<div class="faq-page">
    <!-- 横幅 -->
    <div class="faq-banner">
        <div class="faq-banner-deco"></div>
        <div class="faq-banner-deco faq-banner-deco2"></div>
        <div class="faq-banner-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        </div>
        <h1>常见问题</h1>
        <p>汇总同学们最常遇到的问题，快速找到你需要的答案。</p>
    </div>

    <!-- 面包屑 -->
    <div class="faq-breadcrumb">
        <a href="../help/index.aspx">帮助中心</a>
        <span>/</span>
        <span class="faq-bc-current">常见问题</span>
    </div>

    <!-- 分类标签 -->
    <div class="faq-tabs">
        <span class="faq-tab active" onclick="faqFilter('all',this)">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            全部
        </span>
        <span class="faq-tab" onclick="faqFilter('account',this)">
            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            账号相关
        </span>
        <span class="faq-tab" onclick="faqFilter('course',this)">
            <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            学案课程
        </span>
        <span class="faq-tab" onclick="faqFilter('work',this)">
            <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
            作品提交
        </span>
        <span class="faq-tab" onclick="faqFilter('quiz',this)">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            答题测试
        </span>
        <span class="faq-tab" onclick="faqFilter('other',this)">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            其他问题
        </span>
    </div>

    <!-- 账号相关 -->
    <div class="faq-category" data-cat="account">
        <div class="faq-category-head">
            <span class="faq-cat-icon faq-ci-account"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            <h2>账号相关</h2>
            <span class="faq-count">5 个问题</span>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何登录学习平台？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>打开学习平台网站，在登录页面输入你的学号和密码即可登录。学号和初始密码由班级老师分配。如果是第一次使用，请使用老师提供的初始密码登录。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">忘记密码怎么办？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>如果忘记密码，请联系班级的信息技术老师进行密码重置。老师重置后会提供新的初始密码，登录后请立即修改为自己的密码。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何修改密码？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>点击页面右上角的用户头像，在下拉菜单中选择"修改密码"。</p>
                <ol>
                    <li>输入当前使用的旧密码</li>
                    <li>输入你想设置的新密码</li>
                    <li>再次确认新密码</li>
                    <li>点击保存完成修改</li>
                </ol>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何修改个人头像？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>点击右上角用户头像，选择"修改头像"，选择一张本地图片上传即可。建议使用正面清晰的照片，方便老师和同学识别。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">可以在多台电脑上同时登录吗？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>一般情况下，同一个账号在同一时间只能在一台设备上使用。如果在新设备登录，之前的登录状态可能会失效。请不要将账号密码分享给他人。</p>
            </div></div>
        </div>
    </div>

    <!-- 学案课程 -->
    <div class="faq-category" data-cat="course">
        <div class="faq-category-head">
            <span class="faq-cat-icon faq-ci-course"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
            <h2>学案课程</h2>
            <span class="faq-count">4 个问题</span>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">在哪里可以查看课程学案？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>登录平台后，默认进入"我的学案"页面。你也可以点击顶部导航栏中的"我的学案"随时访问。页面上方显示未学学案，下方显示已学学案。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">学案进度是如何计算的？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>已学学案列表中会显示学习进度条。进度根据你在学案页面中完成的步骤来计算，每完成一个学习步骤进度会相应增加。完成所有步骤后进度显示为100%。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">"本节课"标签是什么意思？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>"本节课"标签出现在未学学案的第一条记录旁边，表示这是老师当前正在教授的课程内容。你应该优先完成这个学案的学习。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">学案页面打不开或加载很慢怎么办？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>可以尝试以下方法：</p>
                <ol>
                    <li>刷新页面（按 F5 或 Ctrl+R）</li>
                    <li>清除浏览器缓存后重新访问</li>
                    <li>检查网络连接是否正常</li>
                    <li>尝试使用其他浏览器（推荐 Chrome 或 Edge）</li>
                    <li>如仍无法解决，请告知老师</li>
                </ol>
            </div></div>
        </div>
    </div>

    <!-- 作品提交 -->
    <div class="faq-category" data-cat="work">
        <div class="faq-category-head">
            <span class="faq-cat-icon faq-ci-work"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></span>
            <h2>作品提交</h2>
            <span class="faq-count">4 个问题</span>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何提交课程作品？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>进入"我的作品"页面，找到对应课程，点击上传按钮选择本地文件进行上传。上传成功后，文件会出现在你的作品列表中。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">支持上传哪些格式的文件？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>平台支持常见的文件格式，具体允许的格式由老师在发布作业时设定。常见支持的格式包括：</p>
                <ul>
                    <li>文档类：doc、docx、pdf、ppt、pptx、xls、xlsx</li>
                    <li>图片类：jpg、png、gif、bmp</li>
                    <li>程序类：sb3、py、html 等</li>
                    <li>压缩包：zip、rar</li>
                </ul>
                <p>具体要求请参照老师的作业说明。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">提交后还能修改作品吗？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>在老师未关闭提交功能前，你可以重新上传作品来覆盖之前的版本。新上传的文件会替代旧文件。建议在提交前仔细检查作品内容。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">上传失败怎么办？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>上传失败可能有以下原因：</p>
                <ol>
                    <li>文件大小超过限制——尝试压缩文件后重新上传</li>
                    <li>文件格式不被允许——检查是否符合老师要求的格式</li>
                    <li>网络不稳定——检查网络连接后重试</li>
                    <li>浏览器问题——尝试刷新页面或换个浏览器</li>
                </ol>
                <p>如多次尝试仍然失败，请及时联系老师。</p>
            </div></div>
        </div>
    </div>

    <!-- 答题测试 -->
    <div class="faq-category" data-cat="quiz">
        <div class="faq-category-head">
            <span class="faq-cat-icon faq-ci-quiz"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
            <h2>答题测试</h2>
            <span class="faq-count">3 个问题</span>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何开始答题？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>进入"常识积累"页面，在答题列表中选择一项可用的测试，点击进入即可开始答题。按照页面提示逐题作答，完成后点击提交。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">答题有时间限制吗？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>是否有时间限制由老师在发布测试时设定。如有限制，页面上会显示倒计时。建议合理分配时间，先完成有把握的题目。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">可以重复答题吗？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>是否可以重复答题取决于老师的设置。部分测试可能只允许答一次，部分测试允许多次作答并取最高分。具体规则请参照测试说明或咨询老师。</p>
            </div></div>
        </div>
    </div>

    <!-- 其他问题 -->
    <div class="faq-category" data-cat="other">
        <div class="faq-category-head">
            <span class="faq-cat-icon faq-ci-other"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>
            <h2>其他问题</h2>
            <span class="faq-count">3 个问题</span>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">推荐使用什么浏览器？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>推荐使用最新版的 Google Chrome 或 Microsoft Edge 浏览器，它们对平台的兼容性最好。不建议使用 IE 浏览器，可能会出现页面显示异常。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何使用小组讨论功能？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>有两种方式进入小组讨论：</p>
                <ol>
                    <li>点击页面右上角的聊天图标按钮</li>
                    <li>点击用户头像下拉菜单中的"小组讨论"</li>
                </ol>
                <p>在讨论窗口中可以发送文字消息，与小组成员实时交流。</p>
            </div></div>
        </div>
        <div class="faq-card" onclick="toggleFaqCard(this)">
            <div class="faq-q">
                <span class="faq-q-text">如何安全退出平台？</span>
                <svg class="faq-q-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
            </div>
            <div class="faq-a"><div class="faq-a-inner">
                <p>点击右上角用户头像，在下拉菜单底部选择"退出登录"。在公共电脑上使用完毕后，请务必退出登录以保护账号安全，不要直接关闭浏览器。</p>
            </div></div>
        </div>
    </div>

    <!-- 底部提示 -->
    <div class="faq-footer">
        <h3>没有找到你的问题？</h3>
        <p>如果以上内容没有解答你的疑问，请联系老师获取帮助。</p>
        <a href="../help/contact.aspx" class="faq-footer-link">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            联系我们
        </a>
    </div>
</div>

<script type="text/javascript">
    function toggleFaqCard(card) {
        var wasOpen = card.classList.contains('open');
        // 关闭同区块其他展开项
        var parent = card.parentElement;
        var cards = parent.querySelectorAll('.faq-card.open');
        for (var i = 0; i < cards.length; i++) { cards[i].classList.remove('open'); }
        if (!wasOpen) card.classList.add('open');
    }

    function faqFilter(cat, el) {
        var tabs = document.querySelectorAll('.faq-tab');
        for (var i = 0; i < tabs.length; i++) { tabs[i].classList.remove('active'); }
        el.classList.add('active');

        var cats = document.querySelectorAll('.faq-category');
        for (var j = 0; j < cats.length; j++) {
            if (cat === 'all' || cats[j].getAttribute('data-cat') === cat) {
                cats[j].style.display = '';
            } else {
                cats[j].style.display = 'none';
            }
        }
    }
</script>
</asp:Content>
