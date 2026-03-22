<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .terms-page, .terms-page * { margin-right: unset !important; margin-left: unset !important; }

    .terms-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: termsFadeIn .4s ease; padding-bottom: 40px;
    }
    @keyframes termsFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* 横幅 */
    .terms-banner {
        background: linear-gradient(135deg, #d97706 0%, #ea580c 50%, #dc2626 100%) !important;
        border-radius: 16px; padding: 52px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .terms-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 180px; height: 180px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .terms-banner-deco2 { top: auto; bottom: -50px; right: auto; left: -40px; width: 140px; height: 140px; background: rgba(255,255,255,.04); }
    .terms-banner h1 { font-size: 28px; font-weight: 700; color: #fff !important; margin: 0 0 10px !important; position: relative; z-index: 1; }
    .terms-banner p { font-size: 15px; color: rgba(255,255,255,.85) !important; margin: 0 !important; position: relative; z-index: 1; }
    .terms-banner-icon { margin-bottom: 16px; position: relative; z-index: 1; }
    .terms-banner-icon svg { width: 48px; height: 48px; stroke: rgba(255,255,255,.9); fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .terms-update { display: inline-block; margin-top: 14px; padding: 5px 16px; border-radius: 16px; background: rgba(255,255,255,.12); font-size: 12px; color: rgba(255,255,255,.8) !important; position: relative; z-index: 1; }

    /* 面包屑 */
    .terms-breadcrumb { display: flex !important; align-items: center; gap: 8px; margin-bottom: 28px; font-size: 13px; }
    .terms-breadcrumb a { color: #6366f1 !important; text-decoration: none !important; font-weight: 500; transition: color .15s; }
    .terms-breadcrumb a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .terms-breadcrumb span { color: #94a3b8; }
    .terms-breadcrumb .terms-bc-current { color: #475569; font-weight: 600; }

    /* 摘要提示 */
    .terms-highlight {
        background: linear-gradient(135deg, #fff7ed, #ffedd5) !important;
        border: 1px solid #fed7aa; border-radius: 14px;
        padding: 24px 28px; margin-bottom: 28px;
        display: flex !important; align-items: flex-start; gap: 16px;
    }
    .terms-highlight-icon {
        width: 40px; height: 40px; border-radius: 12px;
        background: linear-gradient(135deg, #ea580c, #f97316);
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .terms-highlight-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .terms-highlight-text h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 0 6px !important; }
    .terms-highlight-text p { font-size: 13px; color: #475569 !important; margin: 0 !important; line-height: 1.7; }

    /* 目录导航 */
    .terms-toc {
        background: #fff !important; border-radius: 14px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        padding: 20px 24px; margin-bottom: 28px;
    }
    .terms-toc h3 { font-size: 14px; font-weight: 700; color: #1e293b !important; margin: 0 0 12px !important; }
    .terms-toc-list { list-style: none !important; padding: 0 !important; margin: 0 !important; display: flex !important; flex-wrap: wrap; gap: 8px; }
    .terms-toc-item {
        display: inline-flex !important; align-items: center; gap: 6px;
        padding: 6px 14px; border-radius: 8px;
        font-size: 12px; font-weight: 600; color: #475569 !important;
        background: #f8fafc !important; border: 1px solid #e2e8f0;
        cursor: pointer; transition: all .15s; text-decoration: none !important;
    }
    .terms-toc-item:hover { background: #eef2ff !important; color: #4f46e5 !important; border-color: #c7d2fe; }

    /* 内容区块 */
    .terms-section {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden; margin-bottom: 20px;
        transition: box-shadow .2s;
    }
    .terms-section:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); }

    .terms-section-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
        cursor: pointer; user-select: none; transition: background .12s;
    }
    .terms-section-head:hover { background: #fafbfc; }

    .terms-sh-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .terms-sh-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tsi-accept { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }     .tsi-accept svg { stroke: #2563eb; }
    .tsi-account { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }    .tsi-account svg { stroke: #7c3aed; }
    .tsi-behavior { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }   .tsi-behavior svg { stroke: #059669; }
    .tsi-content { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }    .tsi-content svg { stroke: #d97706; }
    .tsi-ip { background: linear-gradient(135deg, #fce7f3, #fbcfe8) !important; }         .tsi-ip svg { stroke: #db2777; }
    .tsi-liability { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }   .tsi-liability svg { stroke: #ea580c; }
    .tsi-terminate { background: linear-gradient(135deg, #fee2e2, #fecaca) !important; }   .tsi-terminate svg { stroke: #dc2626; }
    .tsi-change { background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important; }     .tsi-change svg { stroke: #4f46e5; }

    .terms-section-head h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .terms-section-head .terms-arrow {
        width: 18px; height: 18px; stroke: #94a3b8; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        transition: transform .25s; flex-shrink: 0;
    }
    .terms-section.open .terms-arrow { transform: rotate(180deg); stroke: #6366f1; }

    .terms-section-body {
        max-height: 0; overflow: hidden;
        transition: max-height .4s ease, padding .3s ease;
        padding: 0 24px;
    }
    .terms-section.open .terms-section-body {
        max-height: 600px; padding: 20px 24px;
    }

    .terms-text { font-size: 13px; color: #475569 !important; line-height: 1.8; margin: 0 0 10px !important; }
    .terms-text:last-child { margin-bottom: 0 !important; }

    .terms-list { padding-left: 20px !important; margin: 8px 0 12px !important; }
    .terms-list li {
        font-size: 13px; color: #475569 !important; line-height: 1.8;
        margin-bottom: 4px; padding-left: 4px;
    }
    .terms-list li::marker { color: #ea580c; }

    /* 重要提示 */
    .terms-warning {
        background: #fef2f2 !important; border: 1px solid #fecaca;
        border-radius: 10px; padding: 14px 18px; margin: 10px 0;
        display: flex !important; align-items: flex-start; gap: 10px;
    }
    .terms-warning svg { width: 18px; height: 18px; stroke: #dc2626; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 2px; }
    .terms-warning p { font-size: 12px; color: #991b1b !important; margin: 0 !important; line-height: 1.6; font-weight: 500; }

    /* 底部链接 */
    .terms-footer {
        display: flex !important; align-items: center; justify-content: center;
        gap: 16px; margin-top: 12px; flex-wrap: wrap;
    }
    .terms-footer-link {
        display: inline-flex !important; align-items: center; gap: 8px;
        padding: 12px 24px; border-radius: 10px;
        background: #fff !important; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        font-size: 13px; font-weight: 600; color: #475569 !important;
        text-decoration: none !important; transition: all .15s;
    }
    .terms-footer-link:hover {
        border-color: #c7d2fe !important; background: #eef2ff !important;
        color: #4f46e5 !important; transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(99,102,241,.1);
    }
    .terms-footer-link svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
</style>

<div class="terms-page">
    <!-- 横幅 -->
    <div class="terms-banner">
        <div class="terms-banner-deco"></div>
        <div class="terms-banner-deco terms-banner-deco2"></div>
        <div class="terms-banner-icon">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        </div>
        <h1>使用条款</h1>
        <p>使用 LearnSite 学习平台前，请仔细阅读以下条款。</p>
        <span class="terms-update">最后更新：2026 年 1 月</span>
    </div>

    <!-- 面包屑 -->
    <div class="terms-breadcrumb">
        <a href="../about/index.aspx">关于我们</a>
        <span>/</span>
        <span class="terms-bc-current">使用条款</span>
    </div>

    <!-- 摘要提示 -->
    <div class="terms-highlight">
        <div class="terms-highlight-icon">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        </div>
        <div class="terms-highlight-text">
            <h3>使用须知</h3>
            <p>LearnSite 学习平台供学校教学使用。登录并使用本平台即表示你同意遵守以下条款。这些条款旨在维护良好的教学秩序和平台安全，请认真阅读。</p>
        </div>
    </div>

    <!-- 目录导航 -->
    <div class="terms-toc">
        <h3>条款目录</h3>
        <ul class="terms-toc-list">
            <li><a class="terms-toc-item" onclick="openTermsSection(0)">一、接受条款</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(1)">二、账号管理</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(2)">三、使用规范</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(3)">四、内容管理</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(4)">五、知识产权</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(5)">六、免责声明</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(6)">七、违规处理</a></li>
            <li><a class="terms-toc-item" onclick="openTermsSection(7)">八、条款变更</a></li>
        </ul>
    </div>

    <!-- 1. 接受条款 -->
    <div class="terms-section open">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-accept"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
            <h3>一、接受条款</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">欢迎使用 LearnSite 信息学习平台（以下简称"本平台"）。本平台由学校信息技术教学团队搭建和维护，为在校师生提供信息技术教学服务。</p>
            <p class="terms-text">使用本平台即表示你已阅读、理解并同意接受本使用条款的所有内容。如果你不同意这些条款中的任何部分，请停止使用本平台并联系老师。</p>
            <p class="terms-text">对于未成年学生用户，本条款的接受视为已获得其监护人的知情同意。</p>
        </div>
    </div>

    <!-- 2. 账号管理 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-account"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            <h3>二、账号管理</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">关于你的平台账号，请注意以下事项：</p>
            <ul class="terms-list">
                <li>账号由教师或管理员统一创建和分配，不支持自助注册</li>
                <li>你有责任妥善保管自己的账号和密码，不得将账号借给他人使用</li>
                <li>首次登录后应及时修改初始密码</li>
                <li>因个人原因导致的账号安全问题，由账号持有人自行承担责任</li>
                <li>如发现账号被盗用或异常，应立即通知老师进行处理</li>
            </ul>
        </div>
    </div>

    <!-- 3. 使用规范 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-behavior"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
            <h3>三、使用规范</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">使用本平台时，你应当遵守以下行为规范：</p>
            <ul class="terms-list">
                <li>遵守国家法律法规和学校规章制度</li>
                <li>按照教师要求正常使用平台的各项功能</li>
                <li>不得利用平台传播违法、不良或与教学无关的信息</li>
                <li>不得干扰或破坏平台的正常运行</li>
                <li>不得尝试非法访问他人账号或平台后台系统</li>
                <li>不得在小组讨论中发布侮辱、骚扰他人的内容</li>
            </ul>
            <div class="terms-warning">
                <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                <p>严禁利用平台进行任何违法活动或恶意破坏行为，违者将被取消使用资格并承担相应责任。</p>
            </div>
        </div>
    </div>

    <!-- 4. 内容管理 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-content"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></span>
            <h3>四、内容管理</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">关于平台上的内容，请注意：</p>
            <ul class="terms-list">
                <li>你提交的作品、发表的评论等内容应为原创或已获得合法授权</li>
                <li>不得提交包含恶意代码、病毒或有害程序的文件</li>
                <li>教师和管理员有权查看、管理和删除不当内容</li>
                <li>平台上的学案、课件等教学资源的版权归创作教师和学校所有</li>
            </ul>
            <p class="terms-text">使用 AI 对话功能时，生成的内容仅供学习参考，不保证其完全准确。请勿将 AI 生成内容直接作为作业提交。</p>
        </div>
    </div>

    <!-- 5. 知识产权 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-ip"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M14.31 8l5.74 9.94M9.69 8h11.48M7.38 12l5.74-9.94M9.69 16L3.95 6.06M14.31 16H2.83M16.62 12l-5.74 9.94"/></svg></span>
            <h3>五、知识产权</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">关于知识产权的约定：</p>
            <ul class="terms-list">
                <li>LearnSite 平台程序代码为开源软件，遵循相应的开源协议</li>
                <li>平台上的教学内容（学案、课件、测试题目等）版权归其创作者所有</li>
                <li>学生提交的原创作品，其知识产权归学生本人所有</li>
                <li>未经授权，不得复制、转载或传播平台上的教学资源</li>
            </ul>
        </div>
    </div>

    <!-- 6. 免责声明 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-liability"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></span>
            <h3>六、免责声明</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">在法律允许的范围内，请注意以下免责事项：</p>
            <ul class="terms-list">
                <li>平台"按现状"提供服务，不对服务的不间断性或无错误性作出保证</li>
                <li>因网络故障、设备问题、不可抗力等导致的服务中断，平台不承担责任</li>
                <li>因用户自身操作不当导致的数据丢失，平台不承担责任</li>
                <li>AI 功能生成的内容不代表平台或学校的立场和观点</li>
                <li>平台会尽最大努力保障数据安全，但无法做出绝对安全的承诺</li>
            </ul>
        </div>
    </div>

    <!-- 7. 违规处理 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-terminate"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></span>
            <h3>七、违规处理</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">如发现违反本条款的行为，平台管理方有权采取以下措施：</p>
            <ul class="terms-list">
                <li>警告并要求立即纠正违规行为</li>
                <li>删除违规内容（作品、评论、讨论消息等）</li>
                <li>暂时冻结或永久停用违规账号</li>
                <li>将严重违规行为报告给学校和班主任</li>
            </ul>
            <p class="terms-text">处理措施将根据违规行为的严重程度而定。涉及违法行为的，将配合相关部门依法处理。</p>
        </div>
    </div>

    <!-- 8. 条款变更 -->
    <div class="terms-section">
        <div class="terms-section-head" onclick="toggleTerms(this)">
            <span class="terms-sh-icon tsi-change"><svg viewBox="0 0 24 24"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg></span>
            <h3>八、条款变更</h3>
            <svg class="terms-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
        <div class="terms-section-body">
            <p class="terms-text">本使用条款可能会根据实际需要进行修订和更新。条款变更时，我们会在平台适当位置发布通知。</p>
            <p class="terms-text">继续使用本平台即表示你同意接受修订后的条款内容。如不同意变更后的条款，应停止使用本平台。</p>
            <p class="terms-text">建议你定期查看本页面，以了解条款的最新变化。如对使用条款有任何疑问，请联系班级信息技术老师或平台管理员。</p>
        </div>
    </div>

    <!-- 底部链接 -->
    <div class="terms-footer">
        <a href="../about/index.aspx" class="terms-footer-link">
            <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
            关于我们
        </a>
        <a href="../about/privacy.aspx" class="terms-footer-link">
            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            隐私政策
        </a>
        <a href="../help/contact.aspx" class="terms-footer-link">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            联系我们
        </a>
    </div>
</div>

<script type="text/javascript">
    function toggleTerms(el) {
        var section = el.parentElement;
        if (section.classList.contains('open')) {
            section.classList.remove('open');
        } else {
            section.classList.add('open');
        }
    }

    function openTermsSection(index) {
        var sections = document.querySelectorAll('.terms-section');
        if (index >= 0 && index < sections.length) {
            // 展开目标区块
            sections[index].classList.add('open');
            // 滚动到目标区块
            sections[index].scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    }
</script>
</asp:Content>
