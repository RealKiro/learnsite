<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" AutoEventWireup="true" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    public class AboutChangeEntry
    {
        private string _version;
        private string _tag;
        private string _date;
        private string _firstItem;
        private string _summary;

        public string Version { get { return _version; } set { _version = value; } }
        public string Tag { get { return _tag; } set { _tag = value; } }
        public string Date { get { return _date; } set { _date = value; } }
        public string FirstItem { get { return _firstItem; } set { _firstItem = value; } }
        public string Summary { get { return _summary; } set { _summary = value; } }
    }

    private List<AboutChangeEntry> changeEntries;

    protected void Page_Load(object sender, EventArgs e)
    {
        changeEntries = LoadRecentChanges(4);
    }

    private List<AboutChangeEntry> LoadRecentChanges(int count)
    {
        List<AboutChangeEntry> entries = new List<AboutChangeEntry>();
        try
        {
            string xmlPath = Server.MapPath("~/changelog.xml");
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            XmlNodeList versions = doc.SelectNodes("/changelog/version");
            if (versions == null) return entries;

            int total = Math.Min(count, versions.Count);
            for (int i = 0; i < total; i++)
            {
                XmlNode ver = versions[i];
                AboutChangeEntry entry = new AboutChangeEntry();
                entry.Version = ver.Attributes["ver"] != null ? ver.Attributes["ver"].Value : "";
                entry.Tag = ver.Attributes["tag"] != null ? ver.Attributes["tag"].Value : "";
                entry.Date = ver.Attributes["date"] != null ? ver.Attributes["date"].Value : "";

                XmlNodeList items = ver.SelectNodes("item");
                if (items != null && items.Count > 0)
                {
                    entry.FirstItem = items[0].InnerText;
                    // Build summary from remaining items (up to 3 more)
                    List<string> parts = new List<string>();
                    int summaryCount = Math.Min(items.Count, 4);
                    for (int j = 1; j < summaryCount; j++)
                    {
                        parts.Add(items[j].InnerText);
                    }
                    if (items.Count > 4)
                        parts.Add("等 " + items.Count + " 项更新");
                    entry.Summary = parts.Count > 0 ? string.Join("；", parts.ToArray()) : "";
                }
                else
                {
                    entry.FirstItem = entry.Version;
                    entry.Summary = "";
                }
                entries.Add(entry);
            }
        }
        catch { }
        return entries;
    }

    private string GetDotClass(int index)
    {
        string[] dots = new string[] { "atd-1", "atd-2", "atd-3", "atd-4" };
        return dots[index % dots.Length];
    }

    private string GetTagLabel(string tag)
    {
        switch (tag)
        {
            case "new": return "🆕 新功能";
            case "improve": return "✨ 改进";
            case "fix": return "🔧 修复";
            case "stable": return "✅ 稳定版";
            default: return "";
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .about-page, .about-page * { margin-right: unset !important; margin-left: unset !important; }

    .about-page {
        width: 100%; max-width: 1400px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: aboutFadeIn .4s ease; padding-bottom: 40px;
    }
    @keyframes aboutFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* 横幅 */
    .about-banner {
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%) !important;
        border-radius: 16px; padding: 56px 40px; margin-bottom: 32px;
        position: relative; overflow: hidden; text-align: center;
    }
    .about-banner-deco {
        position: absolute; top: -30px; right: -30px;
        width: 180px; height: 180px; border-radius: 50%;
        background: rgba(255,255,255,.06); pointer-events: none;
    }
    .about-banner-deco2 { top: auto; bottom: -50px; right: auto; left: -40px; width: 140px; height: 140px; background: rgba(255,255,255,.04); }
    .about-banner-deco3 { top: 40%; left: 60%; width: 100px; height: 100px; background: rgba(255,255,255,.03); }
    .about-banner h1 { font-size: 30px; font-weight: 700; color: #fff !important; margin: 0 0 12px !important; position: relative; z-index: 1; }
    .about-banner p { font-size: 15px; color: rgba(255,255,255,.85) !important; margin: 0 !important; position: relative; z-index: 1; line-height: 1.7; max-width: 600px; display: inline-block; }
    .about-banner-icon { margin-bottom: 18px; position: relative; z-index: 1; }
    .about-banner-icon svg { width: 52px; height: 52px; stroke: rgba(255,255,255,.9); fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }

    /* 统计数据 */
    .about-stats {
        display: grid !important; grid-template-columns: repeat(4, 1fr);
        gap: 20px; margin-bottom: 32px;
    }
    @media(max-width:768px) { .about-stats { grid-template-columns: repeat(2, 1fr) !important; } }
    @media(max-width:480px) { .about-stats { grid-template-columns: 1fr !important; } }

    .about-stat {
        background: #fff !important; border-radius: 14px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        padding: 28px 20px; text-align: center;
        transition: transform .2s ease, box-shadow .2s ease;
    }
    .about-stat:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(99,102,241,.12); }
    .about-stat-icon {
        width: 48px; height: 48px; border-radius: 14px;
        display: inline-flex !important; align-items: center; justify-content: center;
        margin-bottom: 14px;
    }
    .about-stat-icon svg { width: 22px; height: 22px; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .asi-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .asi-blue svg { stroke: #2563eb; }
    .asi-purple { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .asi-purple svg { stroke: #7c3aed; }
    .asi-green { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .asi-green svg { stroke: #059669; }
    .asi-orange { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }
    .asi-orange svg { stroke: #ea580c; }

    .about-stat h3 { font-size: 28px; font-weight: 800; color: #1e293b !important; margin: 0 0 4px !important; }
    .about-stat p { font-size: 13px; color: #64748b !important; margin: 0 !important; font-weight: 500; }

    /* 双栏布局 */
    .about-grid {
        display: grid !important; grid-template-columns: 1fr 1fr;
        gap: 24px; margin-bottom: 32px;
    }
    @media(max-width:768px) { .about-grid { grid-template-columns: 1fr !important; } }

    /* 卡片 */
    .about-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden; transition: transform .2s ease, box-shadow .2s ease;
    }
    .about-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04); }
    .about-card-head {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
    }
    .about-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .about-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ahi-mission { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .ahi-mission svg { stroke: #2563eb; }
    .ahi-feature { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .ahi-feature svg { stroke: #7c3aed; }
    .ahi-tech { background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important; }
    .ahi-tech svg { stroke: #059669; }
    .ahi-update { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .ahi-update svg { stroke: #d97706; }

    .about-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b !important; margin: 0 !important; }
    .about-card-body { padding: 20px 24px; }

    /* 特性列表 */
    .about-features { list-style: none !important; padding: 0 !important; margin: 0 !important; }
    .about-feature-item {
        display: flex !important; align-items: flex-start; gap: 14px;
        padding: 14px 0; border-bottom: 1px solid #f1f5f9;
        transition: background .12s;
    }
    .about-feature-item:last-child { border-bottom: none; }
    .about-feature-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .about-feature-icon svg { width: 16px; height: 16px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .afi-1 { background: #eef2ff; }  .afi-1 svg { stroke: #6366f1; }
    .afi-2 { background: #f0fdf4; }  .afi-2 svg { stroke: #16a34a; }
    .afi-3 { background: #fff7ed; }  .afi-3 svg { stroke: #ea580c; }
    .afi-4 { background: #fdf2f8; }  .afi-4 svg { stroke: #db2777; }
    .afi-5 { background: #ecfeff; }  .afi-5 svg { stroke: #0891b2; }

    .about-feature-text h4 { font-size: 14px; font-weight: 600; color: #1e293b !important; margin: 0 0 4px !important; }
    .about-feature-text p { font-size: 13px; color: #64748b !important; margin: 0 !important; line-height: 1.6; }

    /* 理念段落 */
    .about-paragraph { font-size: 13px; color: #475569 !important; line-height: 1.8; margin: 0 0 12px !important; }
    .about-paragraph:last-child { margin-bottom: 0 !important; }

    /* 技术标签 */
    .about-tags { display: flex !important; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
    .about-tag {
        display: inline-flex !important; align-items: center; gap: 5px;
        padding: 6px 14px; border-radius: 18px;
        font-size: 12px; font-weight: 600;
        background: #f1f5f9 !important; color: #475569 !important;
        border: 1px solid #e2e8f0;
        transition: all .15s;
    }
    .about-tag:hover { background: #eef2ff !important; color: #4f46e5 !important; border-color: #c7d2fe; }

    /* 更新日志 */
    .about-timeline { list-style: none !important; padding: 0 !important; margin: 0 !important; }
    .about-timeline-item {
        display: flex !important; gap: 14px; padding: 14px 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .about-timeline-item:last-child { border-bottom: none; }
    .about-tl-dot {
        width: 10px; height: 10px; border-radius: 50%;
        flex-shrink: 0; margin-top: 5px;
    }
    .atd-1 { background: linear-gradient(135deg, #6366f1, #818cf8); }
    .atd-2 { background: linear-gradient(135deg, #059669, #34d399); }
    .atd-3 { background: linear-gradient(135deg, #d97706, #fbbf24); }
    .atd-4 { background: linear-gradient(135deg, #db2777, #f472b6); }

    .about-tl-content h4 { font-size: 13px; font-weight: 600; color: #1e293b !important; margin: 0 0 3px !important; }
    .about-tl-content p { font-size: 12px; color: #64748b !important; margin: 0 !important; line-height: 1.5; }
    .about-tl-date { font-size: 11px; color: #94a3b8 !important; font-weight: 500; }

    /* 底部链接 */
    .about-footer {
        display: flex !important; align-items: center; justify-content: center;
        gap: 16px; flex-wrap: wrap;
    }
    .about-footer-link {
        display: inline-flex !important; align-items: center; gap: 8px;
        padding: 12px 24px; border-radius: 10px;
        background: #fff !important; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04);
        font-size: 13px; font-weight: 600; color: #475569 !important;
        text-decoration: none !important; transition: all .15s;
    }
    .about-footer-link:hover {
        border-color: #c7d2fe !important; background: #eef2ff !important;
        color: #4f46e5 !important; transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(99,102,241,.1);
    }
    .about-footer-link svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
</style>

<div class="about-page">
    <!-- 横幅 -->
    <div class="about-banner">
        <div class="about-banner-deco"></div>
        <div class="about-banner-deco about-banner-deco2"></div>
        <div class="about-banner-deco about-banner-deco3"></div>
        <div class="about-banner-icon">
            <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
        </div>
        <h1>关于 LearnSite 学习平台</h1>
        <p>LearnSite 是一款专为中小学信息技术课程打造的综合学习平台，致力于为师生提供高效、便捷、有趣的教学互动体验。</p>
    </div>

    <!-- 统计数据 -->
    <div class="about-stats">
        <div class="about-stat">
            <div class="about-stat-icon asi-blue">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <h3>10,000+</h3>
            <p>累计服务师生</p>
        </div>
        <div class="about-stat">
            <div class="about-stat-icon asi-purple">
                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            </div>
            <h3>500+</h3>
            <p>精品课程学案</p>
        </div>
        <div class="about-stat">
            <div class="about-stat-icon asi-green">
                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            </div>
            <h3>15+</h3>
            <p>年持续迭代</p>
        </div>
        <div class="about-stat">
            <div class="about-stat-icon asi-orange">
                <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
            </div>
            <h3>20+</h3>
            <p>教学功能模块</p>
        </div>
    </div>

    <!-- 双栏 -->
    <div class="about-grid">
        <!-- 平台理念 -->
        <div class="about-card">
            <div class="about-card-head">
                <span class="about-head-icon ahi-mission"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
                <h3>平台理念</h3>
            </div>
            <div class="about-card-body">
                <p class="about-paragraph">LearnSite 信息学习平台始终秉持"让信息技术教学更高效"的核心理念，为教师提供丰富的教学管理工具，为学生营造轻松有趣的学习环境。</p>
                <p class="about-paragraph">我们相信技术可以赋能教育，通过不断创新和优化，帮助每一位师生在信息技术课堂上获得更好的体验。平台将传统课堂教学与数字化工具相结合，实现教学资源的高效管理和互动学习。</p>
                <p class="about-paragraph">无论是课堂学案、作品提交、知识测试，还是 AI 辅助学习、Scratch 编程、Python 实验，我们都致力于提供一站式的解决方案。</p>
            </div>
        </div>

        <!-- 核心功能 -->
        <div class="about-card">
            <div class="about-card-head">
                <span class="about-head-icon ahi-feature"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                <h3>核心功能</h3>
            </div>
            <div class="about-card-body">
                <ul class="about-features">
                    <li class="about-feature-item">
                        <span class="about-feature-icon afi-1"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
                        <div class="about-feature-text">
                            <h4>学案管理</h4>
                            <p>支持图文、视频、交互式学案创建与发布，学生可在线浏览学习。</p>
                        </div>
                    </li>
                    <li class="about-feature-item">
                        <span class="about-feature-icon afi-2"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></span>
                        <div class="about-feature-text">
                            <h4>作品提交与评价</h4>
                            <p>学生在线提交作品，教师可批量查阅、评分和反馈。</p>
                        </div>
                    </li>
                    <li class="about-feature-item">
                        <span class="about-feature-icon afi-3"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                        <div class="about-feature-text">
                            <h4>在线测试</h4>
                            <p>自动评阅的知识测试系统，支持多种题型和成绩统计。</p>
                        </div>
                    </li>
                    <li class="about-feature-item">
                        <span class="about-feature-icon afi-4"><svg viewBox="0 0 24 24"><path d="M12 2a7 7 0 0 0-4 12.7V17h8v-2.3A7 7 0 0 0 12 2z"/><path d="M9 18h6"/><path d="M10 22h4"/></svg></span>
                        <div class="about-feature-text">
                            <h4>AI 智能助手</h4>
                            <p>集成 AI 对话、OCR 识别、语音实验等前沿智能功能。</p>
                        </div>
                    </li>
                    <li class="about-feature-item">
                        <span class="about-feature-icon afi-5"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2" ry="2"/><path d="M7 16h10"/></svg></span>
                        <div class="about-feature-text">
                            <h4>编程实践</h4>
                            <p>内置 Scratch、Python、Blockly 等编程环境，让学生随时动手实践。</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- 双栏 下 -->
    <div class="about-grid">
        <!-- 技术架构 -->
        <div class="about-card">
            <div class="about-card-head">
                <span class="about-head-icon ahi-tech"><svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></span>
                <h3>技术架构</h3>
            </div>
            <div class="about-card-body">
                <p class="about-paragraph">LearnSite 基于 ASP.NET WebForms 架构开发，采用轻量级部署方案，支持在校园网络环境中稳定运行。</p>
                <div class="about-tags">
                    <span class="about-tag">ASP.NET</span>
                    <span class="about-tag">C#</span>
                    <span class="about-tag">SQL Server</span>
                    <span class="about-tag">HTML5</span>
                    <span class="about-tag">CSS3</span>
                    <span class="about-tag">JavaScript</span>
                    <span class="about-tag">Scratch</span>
                    <span class="about-tag">Python</span>
                    <span class="about-tag">Blockly</span>
                    <span class="about-tag">AI / DeepSeek</span>
                </div>
            </div>
        </div>

        <!-- 更新日志 -->
        <div class="about-card">
            <div class="about-card-head">
                <span class="about-head-icon ahi-update"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                <h3>近期更新</h3>
            </div>
            <div class="about-card-body">
                <ul class="about-timeline">
<% if (changeEntries != null) { for (int i = 0; i < changeEntries.Count; i++) { AboutChangeEntry entry = changeEntries[i]; %>
                    <li class="about-timeline-item">
                        <span class="about-tl-dot <%= GetDotClass(i) %>"></span>
                        <div class="about-tl-content">
                            <h4><%= Server.HtmlEncode(entry.Version) %> <%= GetTagLabel(entry.Tag) %></h4>
                            <p><%= Server.HtmlEncode(entry.FirstItem) %><% if (!string.IsNullOrEmpty(entry.Summary)) { %>；<%= Server.HtmlEncode(entry.Summary) %><% } %></p>
                            <span class="about-tl-date"><%= Server.HtmlEncode(entry.Date) %></span>
                        </div>
                    </li>
                    <% } } %>
                </ul>
            </div>
        </div>
    </div>

    <!-- 底部链接 -->
    <div class="about-footer">
        <a href="../about/join.aspx" class="about-footer-link">
            <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
            加入我们
        </a>
        <a href="../about/privacy.aspx" class="about-footer-link">
            <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            隐私政策
        </a>
        <a href="../about/terms.aspx" class="about-footer-link">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            使用条款
        </a>
        <a href="../help/index.aspx" class="about-footer-link">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            帮助中心
        </a>
    </div>
</div>
</asp:Content>
