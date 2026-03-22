<%@ page title="" language="C#" stylesheettheme="Student" autoeventwireup="true" inherits="Student_myrule, LearnSite" %>
    
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>课堂守则</title>
    <link href="../js/pub-header.css" rel="stylesheet" type="text/css" />
    <link href="../js/pub-footer.css?v=final" rel="stylesheet" type="text/css" />
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        margin: 0;
        padding: 0;
        min-height: 100vh;
        font-family: 'Microsoft YaHei','Segoe UI',sans-serif;
        background:
            radial-gradient(circle at top left, rgba(245,158,11,.10), transparent 30%),
            radial-gradient(circle at right center, rgba(251,191,36,.10), transparent 24%),
            linear-gradient(180deg, #f8fafc 0%, #eef2f7 100%);
    }
    .rl-body-inner { padding: 28px 24px 36px; }
    .rl-page { max-width: 1320px; margin: 0 auto; animation: rlF .4s ease; }
    @keyframes rlF { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }

    .rl-layout {
        display: grid;
        grid-template-columns: minmax(0, 1.45fr) minmax(300px, .75fr);
        gap: 22px;
        align-items: start;
    }
    .rl-main,
    .rl-side { min-width: 0; }
    .rl-side {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .rl-card {
        background: rgba(255,255,255,.96);
        border-radius: 24px;
        box-shadow: 0 20px 48px rgba(15,23,42,.07);
        border: 1px solid rgba(226,232,240,.9);
        overflow: hidden;
        backdrop-filter: blur(8px);
    }

    .rl-banner {
        background: linear-gradient(135deg,#f59e0b 0%,#ea580c 58%,#c2410c 100%);
        padding: 34px 30px;
        position: relative;
        overflow: hidden;
    }
    .rl-banner::before {
        content:'';
        position:absolute;
        top:-34px;
        right:-24px;
        width:136px;
        height:136px;
        border-radius:50%;
        background:rgba(255,255,255,.10);
    }
    .rl-banner::after {
        content:'';
        position:absolute;
        bottom:-48px;
        left:26px;
        width:108px;
        height:108px;
        border-radius:50%;
        background:rgba(255,255,255,.07);
    }
    .rl-banner-inner {
        display:flex;
        align-items:center;
        justify-content: space-between;
        gap:18px;
        position:relative;
        z-index:1;
    }
    .rl-banner-copy {
        display:flex;
        align-items:center;
        gap:16px;
        min-width:0;
    }
    .rl-banner-icon {
        width:56px;
        height:56px;
        background:rgba(255,255,255,.18);
        border-radius:18px;
        display:flex;
        align-items:center;
        justify-content:center;
        backdrop-filter:blur(6px);
        flex-shrink:0;
        box-shadow: inset 0 1px 0 rgba(255,255,255,.18);
    }
    .rl-banner-icon svg { width:28px; height:28px; fill:none; stroke:#fff; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .rl-banner h2 { font-size:24px; line-height:1.3; font-weight:700; color:#fff; letter-spacing:1px; }
    .rl-banner p { margin:5px 0 0; font-size:13px; color:rgba(255,255,255,.82); }
    .rl-banner-badge {
        display:inline-flex;
        align-items:center;
        justify-content:center;
        padding:10px 14px;
        border-radius:999px;
        background:rgba(255,255,255,.16);
        border:1px solid rgba(255,255,255,.18);
        color:#fff7ed;
        font-size:12px;
        font-weight:700;
        white-space:nowrap;
        box-shadow: inset 0 1px 0 rgba(255,255,255,.12);
    }

    .rl-body { padding: 28px; }
    .rl-rule-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
    }
    .rl-item {
        display:flex;
        align-items:flex-start;
        gap:14px;
        min-height:112px;
        padding:18px 18px 16px;
        border-radius:18px;
        transition:all .22s ease;
        border:1px solid #f5e7c8;
        background: linear-gradient(180deg, #fffdf6 0%, #fff8e8 100%);
        box-shadow: 0 10px 24px rgba(245,158,11,.07);
    }
    .rl-item:hover {
        border-color:#fbbf24;
        box-shadow: 0 16px 28px rgba(245,158,11,.12);
        transform:translateY(-2px);
    }
    .rl-num {
        width:38px;
        height:38px;
        border-radius:12px;
        background:linear-gradient(135deg,#f59e0b,#fbbf24);
        display:flex;
        align-items:center;
        justify-content:center;
        font-size:15px;
        font-weight:700;
        color:#fff;
        flex-shrink:0;
        box-shadow:0 10px 18px rgba(245,158,11,.18);
    }
    .rl-text { font-size:14px; color:#334155; line-height:1.8; font-weight:500; padding-top:2px; }
    .rl-text strong { color:#dc2626; font-weight:700; }

    .rl-footer { padding:22px 28px 26px; border-top:1px solid #f1f5f9; text-align:left; }
    .rl-footer-note {
        margin-top:10px;
        font-size:12px;
        color:#94a3b8;
        line-height:1.7;
    }

    .rl-notice,
    .rl-side-card {
        background: rgba(255,255,255,.96);
        border-radius: 20px;
        padding: 22px 24px;
        border: 1px solid rgba(226,232,240,.9);
        box-shadow: 0 14px 36px rgba(15,23,42,.05);
        backdrop-filter: blur(8px);
    }
    .rl-notice-head { display:flex; align-items:center; gap:10px; margin-bottom:14px; }
    .rl-notice-dot { width:8px; height:8px; border-radius:50%; background:#f59e0b; flex-shrink:0; }
    .rl-notice-head h3 { font-size:15px; font-weight:700; color:#1e293b; margin:0; }
    .rl-notice-grid { display:grid; grid-template-columns:1fr; gap:12px; }
    .rl-notice-item { display:flex; align-items:flex-start; gap:10px; padding:12px 14px; border-radius:12px; background:#fffbeb; border:1px solid #fef3c7; }
    .rl-notice-item svg { width:16px; height:16px; fill:none; stroke:#d97706; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; margin-top:2px; }
    .rl-notice-item span { font-size:13px; color:#78350f; line-height:1.6; }

    .rl-side-card-head {
        display:flex;
        align-items:center;
        gap:10px;
        margin-bottom:16px;
    }
    .rl-side-icon {
        width:36px;
        height:36px;
        border-radius:12px;
        display:flex;
        align-items:center;
        justify-content:center;
        background:linear-gradient(135deg,#fed7aa,#fdba74);
        flex-shrink:0;
    }
    .rl-side-icon svg {
        width:18px;
        height:18px;
        stroke:#c2410c;
        fill:none;
        stroke-width:2;
        stroke-linecap:round;
        stroke-linejoin:round;
    }
    .rl-side-card-head h3 { font-size:15px; font-weight:700; color:#1e293b; }
    .rl-side-stats {
        display:grid;
        grid-template-columns:repeat(2, minmax(0, 1fr));
        gap:12px;
    }
    .rl-side-stat {
        padding:14px 14px 12px;
        border-radius:14px;
        background:linear-gradient(180deg,#fff7ed 0%,#fffbeb 100%);
        border:1px solid #fed7aa;
    }
    .rl-side-stat-value {
        display:block;
        font-size:22px;
        font-weight:700;
        color:#c2410c;
        line-height:1.2;
    }
    .rl-side-stat-label {
        display:block;
        margin-top:4px;
        font-size:12px;
        color:#7c2d12;
        line-height:1.6;
    }
    .rl-side-list {
        display:grid;
        gap:10px;
        margin-top:14px;
    }
    .rl-side-list-item {
        display:flex;
        align-items:flex-start;
        gap:10px;
        padding:12px 14px;
        border-radius:14px;
        background:#f8fafc;
        border:1px solid #e2e8f0;
    }
    .rl-side-list-item svg {
        width:16px;
        height:16px;
        stroke:#f59e0b;
        fill:none;
        stroke-width:2;
        stroke-linecap:round;
        stroke-linejoin:round;
        flex-shrink:0;
        margin-top:2px;
    }
    .rl-side-list-item span { font-size:13px; color:#475569; line-height:1.65; }
    .rl-side-action {
        display:flex;
        flex-direction:column;
        gap:12px;
        align-items:flex-start;
    }
    .rl-side-action-copy { font-size:13px; color:#64748b; line-height:1.75; }

    input.rl-btn {
        display:inline-flex!important;
        align-items:center!important;
        justify-content:center!important;
        padding:13px 42px!important;
        border-radius:50px!important;
        border:none!important;
        background:linear-gradient(135deg,#f59e0b,#d97706)!important;
        color:#fff!important;
        font-size:15px!important;
        font-weight:700!important;
        cursor:pointer!important;
        font-family:inherit!important;
        letter-spacing:1px;
        box-shadow:0 12px 24px rgba(217,119,6,.22);
        transition:all .2s;
        height:auto!important;
        width:auto!important;
        background-image:linear-gradient(135deg,#f59e0b,#d97706)!important;
        line-height:1.4!important;
        text-indent:0!important;
        -webkit-appearance:none!important;
        appearance:none!important;
    }
    input.rl-btn:hover { transform:translateY(-2px); box-shadow:0 16px 28px rgba(217,119,6,.3); }

    @media (max-width: 1080px) {
        .rl-layout { grid-template-columns: 1fr; }
        .rl-side { order: 2; }
    }
    @media (max-width: 760px) {
        .rl-body-inner { padding: 20px 16px 28px; }
        .rl-banner-inner,
        .rl-banner-copy {
            flex-direction: column;
            align-items: flex-start;
        }
        .rl-rule-grid,
        .rl-side-stats { grid-template-columns: 1fr; }
        .rl-body,
        .rl-footer,
        .rl-notice,
        .rl-side-card {
            padding-left: 18px;
            padding-right: 18px;
        }
    }
</style>
</head>
<script runat="server">
    protected string pubUserName=""; protected string pubUserInitial=""; protected string pubUserClass=""; protected bool pubLoggedIn=false;
    protected string pubSiteTitle="LearnSite"; protected string pubLogoUrl="";
    protected string GetSiteTitle(){try{string xmlPath=Server.MapPath("~/website.xml");System.Xml.XmlDocument doc=new System.Xml.XmlDocument();doc.Load(xmlPath);System.Xml.XmlNode node=doc.SelectSingleNode("//add[@key='SiteTitle']");if(node!=null&&node.Attributes["value"]!=null)return node.Attributes["value"].Value;}catch{}return"LearnSite";}
    protected string GetSiteLogoUrl(){string[] exts={".png",".jpg",".jpeg",".gif",".svg",".webp"};foreach(string ext in exts){string path=Server.MapPath("~/images/site-logo"+ext);if(System.IO.File.Exists(path))return ResolveUrl("~/images/site-logo"+ext)+"?v="+System.IO.File.GetLastWriteTime(path).Ticks;}return"";}
    protected string footerCopyright="";protected string footerIcp="";protected string footerIcpUrl="";protected string footerCustomHtml="";protected bool footerShowPoweredBy=true;protected string footerBgColor="#1e293b";protected string footerTextColor="#94a3b8";protected bool footerHasSettings=false;
    private void LoadFooterSettings(){try{string xmlPath=Server.MapPath("~/App_Data/footersetting.xml");if(!System.IO.File.Exists(xmlPath))return;System.Xml.XmlDocument doc=new System.Xml.XmlDocument();doc.Load(xmlPath);footerCopyright=ReadFooterNode(doc,"copyright");footerIcp=ReadFooterNode(doc,"icp");footerIcpUrl=ReadFooterNode(doc,"icpUrl");footerCustomHtml=ReadFooterNode(doc,"customHtml");string pb=ReadFooterNode(doc,"showPoweredBy");footerShowPoweredBy=(pb!="false");string bg=ReadFooterNode(doc,"bgColor");if(!string.IsNullOrEmpty(bg))footerBgColor=bg;string tc=ReadFooterNode(doc,"textColor");if(!string.IsNullOrEmpty(tc))footerTextColor=tc;footerHasSettings=true;}catch{}}
    private string ReadFooterNode(System.Xml.XmlDocument doc,string name){System.Xml.XmlNode node=doc.SelectSingleNode("//"+name);if(node!=null)return node.InnerText;return"";}

    protected string[] GetRules()
    {
        try
        {
            string filePath = Server.MapPath("~/App_Data/classroomrules.txt");
            if (System.IO.File.Exists(filePath))
            {
                string content = System.IO.File.ReadAllText(filePath, System.Text.Encoding.UTF8);
                if (content.Trim().Length > 0)
                {
                    string[] lines = content.Split(new char[] { '\r', '\n' }, System.StringSplitOptions.RemoveEmptyEntries);
                    if (lines.Length > 0) return lines;
                }
            }
        }
        catch { }
        // Default fallback
        return new string[] {
            "\u65E0\u8BF7\u5047\u7F3A\u5E2D\uFF1A\u6BCF\u4EBA**\u62631\u5206**",
            "\u8FDF\u5230\uFF1A\u6BCF\u4EBA**\u62630.1\u5206**",
            "\u5403\u96F6\u98DF\u5E26\u996E\u6599\uFF1A\u6BCF\u4EBA**\u62630.1\u5206**",
            "\u4E71\u4E22\u5783\u573E\uFF1A\u6BCF\u4EBA**\u62630.1\u5206**\u4E14\u8D1F\u8D23\u62D6\u5730\u4E00\u6B21",
            "\u672A\u7ECF\u8001\u5E08\u5141\u8BB8\u73A9\u6E38\u620F\uFF1A\u6BCF\u4EBA**\u62630.1\u5206**",
            "\u5E26\u5B58\u50A8\u8BBE\u5907\uFF08mp3\u3001U\u76D8\uFF09\u5E76\u4F7F\u7528\uFF1A\u6BCF\u4EBA**\u62630.1\u5206**",
            "\u6545\u610F\u641E\u4E71\u7535\u8111\u786C\u4EF6\uFF1A**\u62631\u5206**",
            "\u672A\u7ECF\u8001\u5E08\u5141\u8BB8\uFF0C\u79C1\u81EA\u4E0B\u5EA7\u4F4D\u6216\u6362\u5EA7\u4F4D\uFF1A**\u62631\u5206**"
        };
    }

    protected string FormatRule(string rule)
    {
        // Convert **text** to <strong>text</strong>
        string result = Server.HtmlEncode(rule);
        result = System.Text.RegularExpressions.Regex.Replace(result, @"\*\*(.+?)\*\*", "<strong>$1</strong>");
        return result;
    }
    protected override void OnPreRender(EventArgs e){base.OnPreRender(e);pubSiteTitle=GetSiteTitle();pubLogoUrl=GetSiteLogoUrl();LoadFooterSettings();try{HttpCookie sc=Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];if(sc!=null&&!string.IsNullOrEmpty(sc.Value)){string cv=sc.Value;if(cv.Contains("%"))try{cv=HttpUtility.UrlDecode(cv,System.Text.Encoding.UTF8);}catch{}Type ct=typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");if(ct!=null){object m=Activator.CreateInstance(ct);System.Reflection.MethodInfo mi=ct.GetMethod("ToModel",System.Reflection.BindingFlags.Public|System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance);if(mi!=null)mi.Invoke(m,new object[]{cv});System.Reflection.PropertyInfo pn=ct.GetProperty("Sname");if(pn!=null){object v=pn.GetValue(m,null);if(v!=null){string s=v.ToString();if(s.Contains("%"))try{s=HttpUtility.UrlDecode(s,System.Text.Encoding.UTF8);}catch{}pubUserName=s;if(s.Length>0)pubUserInitial=s.Substring(0,1);pubLoggedIn=true;}}System.Reflection.PropertyInfo pg=ct.GetProperty("Sgrade");System.Reflection.PropertyInfo pc=ct.GetProperty("Sclass");string g="",c="";if(pg!=null){object gv=pg.GetValue(m,null);if(gv!=null)g=gv.ToString();}if(pc!=null){object cv2=pc.GetValue(m,null);if(cv2!=null)c=cv2.ToString();}if(!string.IsNullOrEmpty(g)&&g!="0"&&!string.IsNullOrEmpty(c)&&c!="0")pubUserClass=g+"\u5E74\u7EA7"+c+"\u73ED";else if(!string.IsNullOrEmpty(c)&&c!="0")pubUserClass=c+"\u73ED";}}}catch{}}
</script>
<body>
    <form id="form1" runat="server">
    <div class="pub-hdr">
        <a href="../index.aspx" class="pub-hdr-logo"><% if(!string.IsNullOrEmpty(pubLogoUrl)){%><img src="<%= pubLogoUrl %>" alt="Logo" /><%}else{%><span class="pub-hdr-logo-fb">L</span><%}%><span><%= Server.HtmlEncode(pubSiteTitle) %></span></a>
        <div class="pub-hdr-space"></div>
        <div class="pub-hdr-actions">
            <% if (pubLoggedIn) { %>
            <div class="pub-user"><div class="pub-user-avatar"><%= Server.HtmlEncode(pubUserInitial) %></div><span class="pub-user-name"><%= Server.HtmlEncode(pubUserName) %></span><% if(!string.IsNullOrEmpty(pubUserClass)){%><span class="pub-user-class"><%= Server.HtmlEncode(pubUserClass) %></span><%}%></div>
            <% } else { %>
            <a href="/index.aspx" class="pub-btn-login">登录</a><a href="../student/register.aspx" class="pub-btn-reg">注册</a>
            <% } %>
        </div>
    </div>
    <div class="rl-body-inner">
    <div class="rl-page">
        <% string[] rules = GetRules(); %>
        <div class="rl-layout">
            <div class="rl-main">
                <div class="rl-card">
                    <div class="rl-banner">
                        <div class="rl-banner-inner">
                            <div class="rl-banner-copy">
                                <span class="rl-banner-icon"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
                                <div><h2>课堂守则</h2><p>遵守纪律，文明课堂，让每一节课都更高效</p></div>
                            </div>
                            <span class="rl-banner-badge">共 <%= rules.Length %> 条课堂约定</span>
                        </div>
                    </div>
                    <div class="rl-body">
                        <div class="rl-rule-grid">
                            <% for (int i = 0; i < rules.Length; i++) { %>
                            <div class="rl-item">
                                <span class="rl-num"><%= i + 1 %></span>
                                <div class="rl-text"><%= FormatRule(rules[i]) %></div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <div class="rl-footer">
                        <asp:Button ID="Btnreturn" runat="server" Text="关闭" CssClass="rl-btn" />
                        <div class="rl-footer-note">文明课堂从每一次自觉开始，守规有礼、专注认真，才能让学习更轻松也更有收获。</div>
                    </div>
                </div>
            </div>
            <div class="rl-side">
                <div class="rl-side-card">
                    <div class="rl-side-card-head">
                        <span class="rl-side-icon"><svg viewBox="0 0 24 24"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4 12.5-12.5z"></path></svg></span>
                        <h3>课堂概览</h3>
                    </div>
                    <div class="rl-side-stats">
                        <div class="rl-side-stat">
                            <span class="rl-side-stat-value"><%= rules.Length %></span>
                            <span class="rl-side-stat-label">守则条数</span>
                        </div>
                        <div class="rl-side-stat">
                            <span class="rl-side-stat-value">100%</span>
                            <span class="rl-side-stat-label">自觉执行更好</span>
                        </div>
                    </div>
                    <div class="rl-side-list">
                        <div class="rl-side-list-item">
                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            <span>课前准备好学习用品和账号环境，进入课堂状态会更快。</span>
                        </div>
                        <div class="rl-side-list-item">
                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            <span>课堂中尊重同学和老师，保持安静、专注和良好的合作氛围。</span>
                        </div>
                        <div class="rl-side-list-item">
                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            <span>有特殊情况及时说明，主动沟通比事后补救更有效。</span>
                        </div>
                    </div>
                </div>
                <div class="rl-notice">
                    <div class="rl-notice-head">
                        <span class="rl-notice-dot"></span>
                        <h3>温馨提示</h3>
                    </div>
                    <div class="rl-notice-grid">
                        <div class="rl-notice-item">
                            <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            <span>课堂守则是维护良好学习环境的基础，希望每位同学自觉遵守。</span>
                        </div>
                        <div class="rl-notice-item">
                            <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            <span>扣分记录将影响个人和小组的综合评价成绩，请认真对待。</span>
                        </div>
                        <div class="rl-notice-item">
                            <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            <span>如有特殊情况请提前向老师请假或说明，避免不必要的扣分。</span>
                        </div>
                        <div class="rl-notice-item">
                            <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            <span>认真学习、积极参与课堂活动，也有机会获得额外加分奖励。</span>
                        </div>
                    </div>
                </div>
                <div class="rl-side-card">
                    <div class="rl-side-card-head">
                        <span class="rl-side-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M12 8v4l3 3"></path></svg></span>
                        <h3>学习建议</h3>
                    </div>
                    <div class="rl-side-action">
                        <div class="rl-side-action-copy">遵守规则不是为了限制，而是为了让每位同学都能在安静、有序、公平的环境中学习和成长。</div>
                        <div class="rl-side-action-copy">先管理好课堂行为，再提高学习效率，很多事情都会顺畅很多。</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
    
    <!-- LearnSite完整底部 -->
    <div class="site-footer">
        <div class="site-footer-inner">
            <!-- 主要内容区域 -->
            <div class="site-footer-main">
                <!-- 左侧品牌区 -->
                <div class="site-footer-brand">
                    <a href="../default.aspx" class="site-footer-logo">
                        <% if (!string.IsNullOrEmpty(pubLogoUrl)) { %>
                        <span class="site-footer-logo-icon"><img src="<%= pubLogoUrl %>" alt="Logo" /></span>
                        <% } else { %>
                        <span class="site-footer-logo-icon">L</span>
                        <% } %>
                        <span><%= Server.HtmlEncode(pubSiteTitle) %></span>
                    </a>
                    <p class="site-footer-desc">
                        专业在线学习平台，致力于为学生和教师提供优质的教学体验和学习资源。
                    </p>
                    <div class="site-footer-social">
                        <a href="#" class="site-footer-social-link" title="GitHub">
                            <svg viewBox="0 0 24 24"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                        </a>
                        <a href="#" class="site-footer-social-link" title="Twitter">
                            <svg viewBox="0 0 24 24"><path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z"/></svg>
                        </a>
                        <a href="#" class="site-footer-social-link" title="Email">
                            <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </a>
                        <a href="#" class="site-footer-social-link" title="RSS">
                            <svg viewBox="0 0 24 24"><path d="M4 11a9 9 0 0 1 9 9"/><path d="M4 4a16 16 0 0 1 16 16"/><circle cx="5" cy="19" r="1"/></svg>
                        </a>
                    </div>
                </div>

                <!-- 链接列 -->
                <div class="site-footer-links">
                    <!-- 产品列 -->
                    <div class="site-footer-column">
                        <h3 class="site-footer-column-title">产品</h3>
                        <ul class="site-footer-column-list">
                            <li class="site-footer-column-item">
                                <a href="../default.aspx" class="site-footer-column-link">在线课程</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../student/mywork.aspx" class="site-footer-column-link">作业系统</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../student/mytest.aspx" class="site-footer-column-link">考试测评</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../student/myresource.aspx" class="site-footer-column-link">学习资源</a>
                            </li>
                        </ul>
                    </div>

                    <!-- 支持列 -->
                    <div class="site-footer-column">
                        <h3 class="site-footer-column-title">支持</h3>
                        <ul class="site-footer-column-list">
                            <li class="site-footer-column-item">
                                <a href="../help/index.aspx" class="site-footer-column-link">帮助中心</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../help/docs.aspx" class="site-footer-column-link">使用文档</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../help/faq.aspx" class="site-footer-column-link">常见问题</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../help/contact.aspx" class="site-footer-column-link">联系我们</a>
                            </li>
                        </ul>
                    </div>

                    <!-- 关于列 -->
                    <div class="site-footer-column">
                        <h3 class="site-footer-column-title">关于</h3>
                        <ul class="site-footer-column-list">
                            <li class="site-footer-column-item">
                                <a href="../about/index.aspx" class="site-footer-column-link">关于我们</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../about/join.aspx" class="site-footer-column-link">加入我们</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../about/privacy.aspx" class="site-footer-column-link">隐私政策</a>
                            </li>
                            <li class="site-footer-column-item">
                                <a href="../about/terms.aspx" class="site-footer-column-link">服务条款</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- 底部栏 -->
            <div class="site-footer-bottom">
                <div class="site-footer-bottom-left">
                    <% if (!string.IsNullOrEmpty(footerCopyright)) { %>
                    <span class="site-footer-copyright"><%= Server.HtmlEncode(footerCopyright) %></span>
                    <% } else { %>
                    <span class="site-footer-copyright">© {year} LearnSite. All rights reserved</span>
                    <% } %>
                    <% if (!string.IsNullOrEmpty(footerIcp)) { %>
                    <span class="site-footer-icp">
                        <% if (!string.IsNullOrEmpty(footerIcpUrl)) { %>
                        <a href="<%= Server.HtmlEncode(footerIcpUrl) %>" target="_blank" rel="noopener"><%= Server.HtmlEncode(footerIcp) %></a>
                        <% } else { %>
                        <%= Server.HtmlEncode(footerIcp) %>
                        <% } %>
                    </span>
                    <% } %>
                </div>
                <div class="site-footer-bottom-right">
                    <% if (footerShowPoweredBy) { %>
                    <span class="site-footer-powered"><a href="https://github.com/learnsite" target="_blank" rel="noopener">LearnSite</a></span>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <script src="../js/pub-footer.js"></script>
    </form>
</body>
</html>
