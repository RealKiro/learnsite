<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .privacy-page, .privacy-page * { margin-right: unset !important; margin-left: unset !important; }

    .privacy-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: privacyFadeIn .4s ease; padding-bottom: 40px;
    }
    @keyframes privacyFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* 横幅 */
    .privacy-banner {
        background: linear-gradient(135deg, #2563eb 0%, #6366f1 50%, #7c3aed 100%) !important;
        border-radius: 16px; padding: 52px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .privacy-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 180px; height: 180px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .privacy-banner-deco2 { top: auto; bottom: -50px; right: auto; left: -40px; width: 140px; height: 140px; background: rgba(255,255,255,.04); }
    .privacy-banner h1 { font-size: 28px; font-weight: 700; color: #fff !important; margin: 0 0 10px !important; position: relative; z-index: 1; }
    .privacy-banner p { font-size: 15px; color: rgba(255,255,255,.85) !important; margin: 0 !important; position: relative; z-index: 1; }
    .privacy-banner-icon { margin-bottom: 16px; position: relative; z-index: 1; }
    .privacy-banner-icon svg { width: 48px; height: 48px; stroke: rgba(255,255,255,.9); fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .privacy-update { display: inline-block; margin-top: 14px; padding: 5px 16px; border-radius: 16px; background: rgba(255,255,255,.12); font-size: 12px; color: rgba(255,255,255,.8) !important; position: relative; z-index: 1; }

    /* 面包屑 */
    .privacy-breadcrumb { display: flex !important; align-items: center; gap: 8px; margin-bottom: 28px; font-size: 13px; }
    .privacy-breadcrumb a { color: #6366f1 !important; text-decoration: none !important; font-weight: 500; transition: color .15s; }
    .privacy-breadcrumb a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .privacy-breadcrumb span { color: #94a3b8; }
    .privacy-breadcrumb .privacy-bc-current { color: #475569; font-weight: 600; }

    /* 摘要高亮 */
    .privacy-highlight {
        background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
        border: 1px solid #c7d2fe; border-radius: 14px;
        padding: 24px 28px; margin-bottom: 28px;
        display: flex !important; align-items: flex-start; gap: 16px;
    }
    .privacy-highlight-icon {
        width: 40px; height: 40px; border-radius: 12px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .privacy-highlight-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .privacy-highlight-text h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 0 6px !important; }
    .privacy-highlight-text p { font-size: 13px; color: #475569 !important; margin: 0 !important; line-height: 1.7; }

    /* 内容区块 */
    .privacy-section {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden; margin-bottom: 20px;
        transition: box-shadow .2s;
    }
    .privacy-section:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); }

    .privacy-section-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
        cursor: pointer; user-select: none; transition: background .12s;
    }
    .privacy-section-head:hover { background: #fafbfc; }

    .privacy-sh-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .privacy-sh-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .psi-collect { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }  .psi-collect svg { stroke: #2563eb; }
    .psi-use { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }      .psi-use svg { stroke: #7c3aed; }
    .psi-store { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }    .psi-store svg { stroke: #059669; }
    .psi-share { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }    .psi-share svg { stroke: #d97706; }
    .psi-protect { background: linear-gradient(135deg, #fce7f3, #fbcfe8) !important; }  .psi-protect svg { stroke: #db2777; }
    .psi-rights { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }   .psi-rights svg { stroke: #ea580c; }
    .psi-minor { background: linear-gradient(135deg, #ccfbf1, #99f6e4) !important; }    .psi-minor svg { stroke: #0d9488; }
    .psi-update { background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important; }   .psi-update svg { stroke: #4f46e5; }

    .privacy-section-head h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .privacy-section-head .privacy-arrow {
        width: 18px; height: 18px; stroke: #94a3b8; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        transition: transform .25s; flex-shrink: 0;
    }
    .privacy-section.open .privacy-arrow { transform: rotate(180deg); stroke: #6366f1; }

    .privacy-section-body {
        max-height: 0; overflow: hidden;
        transition: max-height .4s ease, padding .3s ease;
        padding: 0 24px;
    }
    .privacy-section.open .privacy-section-body {
        max-height: 600px; padding: 20px 24px;
    }

    .privacy-text { font-size: 13px; color: #475569 !important; line-height: 1.8; margin: 0 0 10px !important; }
    .privacy-text:last-child { margin-bottom: 0 !important; }

    .privacy-list { padding-left: 20px !important; margin: 8px 0 12px !important; }
    .privacy-list li {
        font-size: 13px; color: #475569 !important; line-height: 1.8;
        margin-bottom: 4px; padding-left: 4px;
    }
    .privacy-list li::marker { color: #6366f1; }

    /* 底部链接 */
    .privacy-footer {
        display: flex !important; align-items: center; justify-content: center;
        gap: 16px; margin-top: 12px; flex-wrap: wrap;
    }
    .privacy-footer-link {
        display: inline-flex !important; align-items: center; gap: 8px;
        padding: 12px 24px; border-radius: 10px;
        background: #fff !important; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        font-size: 13px; font-weight: 600; color: #475569 !important;
        text-decoration: none !important; transition: all .15s;
    }
    .privacy-footer-link:hover {
        border-color: #c7d2fe !important; background: #eef2ff !important;
        color: #4f46e5 !important; transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(99,102,241,.1);
    }
    .privacy-footer-link svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
</style>

<div class="privacy-page">
    <!-- 横幅 -->
    <div class="privacy-banner">
        <div class="privacy-banner-deco"></div>
        <div class="privacy-banner-deco privacy-banner-deco2"></div>
        <div class="privacy-banner-icon">
            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
        <h1>隐私政策</h1>
        <p>我们重视并保护每一位用户的个人信息安全。</p>
        <span class="privacy-update">最后更新：2026 年 1 月</span>
    </div>

    <!-- 面包屑 -->
    <div class="privacy-breadcrumb">
        <a href="../about/index.aspx">关于我们</a>
        <span>/</span>
        <span class="privacy-bc-current">隐私政策</span>
    </div>

    <!-- 摘要 -->
    <div class="privacy-highlight">
        <div class="privacy-highlight-icon">
            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
        <div class="privacy-highlight-text">
            <h3>隐私保护承诺</h3>
            <p>LearnSite 学习平台部署在校园局域网内，所有数据存储在学校服务器中，不会上传至任何外部服务器。我们仅收集教学所必需的最少信息，并采取严格的安全措施保护你的隐私。</p>
        </div>
    </div>

    <!-- 1. 信息收集 -->
    <div class="privacy-section open">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-collect"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
            <h3>一、我们收集哪些信息</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">为提供正常的教学服务，平台可能收集以下信息：</p>
            <ul class="privacy-list">
                <li><strong>账号信息</strong>：学号、姓名、班级等由教师录入的基本信息</li>
                <li><strong>学习数据</strong>：课程浏览记录、学案学习进度、作品提交记录</li>
                <li><strong>测试数据</strong>：答题记录、成绩与正确率统计</li>
                <li><strong>操作日志</strong>：登录时间、操作行为等系统日志</li>
            </ul>
            <p class="privacy-text">我们不会主动收集与教学无关的个人信息，也不要求学生提供手机号、身份证号等敏感信息。</p>
        </div>
    </div>

    <!-- 2. 信息使用 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-use"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>
            <h3>二、信息的使用方式</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">收集的信息仅用于以下教学目的：</p>
            <ul class="privacy-list">
                <li>提供课程学习、作品提交、在线测试等核心教学服务</li>
                <li>记录和展示学习进度，帮助教师了解学生学习情况</li>
                <li>生成学习统计报告，辅助教学改进</li>
                <li>维护平台安全和正常运行</li>
            </ul>
            <p class="privacy-text">我们不会将用户信息用于商业推广、广告投放或任何与教学无关的用途。</p>
        </div>
    </div>

    <!-- 3. 信息存储 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-store"><svg viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg></span>
            <h3>三、信息的存储与安全</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">平台采用以下方式保障数据安全：</p>
            <ul class="privacy-list">
                <li><strong>本地存储</strong>：所有数据存储在学校自有服务器中，不会传输至外部</li>
                <li><strong>校园网络</strong>：平台运行在校园局域网内，外部网络默认无法访问</li>
                <li><strong>定期备份</strong>：管理员定期对数据库进行备份，防止数据丢失</li>
                <li><strong>访问控制</strong>：不同角色拥有不同权限，学生仅能访问自己的数据</li>
            </ul>
        </div>
    </div>

    <!-- 4. 信息共享 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-share"><svg viewBox="0 0 24 24"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg></span>
            <h3>四、信息的共享与披露</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">我们承诺不会向任何第三方出售、出租或共享用户个人信息。在以下情况下，信息可能会在有限范围内被使用：</p>
            <ul class="privacy-list">
                <li>教师可查看所授班级学生的学习数据和作品</li>
                <li>管理员可在系统维护和管理需要时访问用户数据</li>
                <li>在法律法规要求的情况下，可能需要配合相关部门提供必要信息</li>
            </ul>
            <p class="privacy-text">使用 AI 对话功能时，对话内容可能会发送至 AI 服务提供商进行处理。我们建议用户在使用 AI 功能时不要输入真实的个人隐私信息。</p>
        </div>
    </div>

    <!-- 5. 信息保护 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-protect"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
            <h3>五、账号与密码安全</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">为保护你的账号安全，我们建议：</p>
            <ul class="privacy-list">
                <li>首次登录后及时修改初始密码</li>
                <li>不要将密码分享给他人或在多台设备上同时登录</li>
                <li>在公共电脑上使用完毕后，务必退出登录</li>
                <li>如发现账号异常，请立即联系老师重置密码</li>
            </ul>
            <p class="privacy-text">平台会对用户密码进行加密存储，管理员和教师均无法直接查看用户的明文密码。</p>
        </div>
    </div>

    <!-- 6. 用户权利 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-rights"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            <h3>六、用户权利</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">你享有以下关于个人信息的权利：</p>
            <ul class="privacy-list">
                <li><strong>查看权</strong>：你可以查看自己的学习数据、成绩记录和作品信息</li>
                <li><strong>修改权</strong>：你可以修改自己的密码和头像</li>
                <li><strong>知情权</strong>：你有权了解平台收集和使用你的信息的方式</li>
                <li><strong>删除权</strong>：毕业或转学后，可联系管理员删除个人数据</li>
            </ul>
            <p class="privacy-text">如需行使以上权利，请联系班级信息技术老师或平台管理员。</p>
        </div>
    </div>

    <!-- 7. 未成年人保护 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-minor"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
            <h3>七、未成年人保护</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">LearnSite 的主要用户为中小学生，我们特别重视未成年人的隐私保护：</p>
            <ul class="privacy-list">
                <li>平台不收集未成年人的敏感个人信息</li>
                <li>学生账号由教师统一管理，确保使用安全</li>
                <li>平台不包含任何广告或商业推广内容</li>
                <li>不会向学生发送任何营销信息</li>
            </ul>
        </div>
    </div>

    <!-- 8. 政策更新 -->
    <div class="privacy-section">
        <div class="privacy-section-head" onclick="togglePrivacy(this)">
            <span class="privacy-sh-icon psi-update"><svg viewBox="0 0 24 24"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg></span>
            <h3>八、政策更新</h3>
            <svg class="privacy-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="privacy-section-body">
            <p class="privacy-text">我们可能会根据法律法规变化或平台功能更新对本隐私政策进行修订。重大变更会在平台首页进行公告通知。</p>
            <p class="privacy-text">建议你定期查看本页面以了解最新的隐私保护措施。如对隐私政策有任何疑问，请联系学校信息技术老师或平台管理员。</p>
        </div>
    </div>

    <!-- 底部链接 -->
    <div class="privacy-footer">
        <a href="../about/index.aspx" class="privacy-footer-link">
            <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
            关于我们
        </a>
        <a href="../about/terms.aspx" class="privacy-footer-link">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            使用条款
        </a>
        <a href="../help/contact.aspx" class="privacy-footer-link">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            联系我们
        </a>
    </div>
</div>

<script type="text/javascript">
    function togglePrivacy(el) {
        var section = el.parentElement;
        if (section.classList.contains('open')) {
            section.classList.remove('open');
        } else {
            section.classList.add('open');
        }
    }
</script>
</asp:Content>
