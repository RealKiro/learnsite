<%@ page language="C#" autoeventwireup="true" stylesheettheme="Student" inherits="Student_register, LearnSite" %>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>新学员注册</title>
    <link href="../js/pub-header.css" rel="stylesheet" type="text/css" />
    <link href="../js/pub-footer.css?v=final" rel="stylesheet" type="text/css" />
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { margin:0; padding: 0; background: #f8f9fa; min-height: 100vh; font-family: 'Microsoft YaHei','Segoe UI',sans-serif; }
    .rg-body-inner { padding: 40px 24px 60px; display:flex; align-items:flex-start; justify-content:center; min-height: calc(100vh - 80px); }
    .rg-page { width: 100%; max-width: 1400px; animation: rgF .6s cubic-bezier(0.4, 0, 0.2, 1); display: flex; flex-direction: column; gap: 32px; }
    .rg-main { width: 100%; }
    .rg-side { width: 100%; display: grid; grid-template-columns: 1fr 1fr; gap: 32px; }
    @media (max-width: 968px) { .rg-side { grid-template-columns: 1fr; gap: 24px; } }
    @media (max-width: 768px) { .rg-body-inner { padding: 24px 16px 40px; } .rg-page { gap: 24px; } }
    @keyframes rgF { from{opacity:0;transform:translateY(20px) scale(0.98)} to{opacity:1;transform:translateY(0) scale(1)} }

    .rg-card { background: #fff; border-radius: 24px; box-shadow: 0 4px 24px rgba(0,0,0,.08), 0 0 0 1px rgba(0,0,0,.04); border: none; overflow: hidden; }

    .rg-banner { background: linear-gradient(135deg,#667eea 0%,#764ba2 100%); padding: 40px 32px; position: relative; overflow: hidden; text-align: center; }
    .rg-banner::before { content:''; position:absolute; top:-50px; right:-50px; width:200px; height:200px; border-radius:50%; background:rgba(255,255,255,.08); animation: float 8s ease-in-out infinite; }
    .rg-banner::after { content:''; position:absolute; bottom:-60px; left:-20px; width:150px; height:150px; border-radius:50%; background:rgba(255,255,255,.06); animation: float 10s ease-in-out infinite reverse; }
    .rg-banner-icon { width:64px; height:64px; margin:0 auto 14px; background:rgba(255,255,255,.25); border-radius:18px; display:flex; align-items:center; justify-content:center; backdrop-filter:blur(10px); position:relative; z-index:1; box-shadow: 0 8px 32px rgba(0,0,0,.1); }
    .rg-banner-icon svg { width:32px; height:32px; fill:none; stroke:#fff; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
    .rg-banner h2 { font-size:24px; font-weight:800; color:#fff; letter-spacing:0.5px; position:relative; z-index:1; margin-bottom: 6px; text-shadow: 0 2px 10px rgba(0,0,0,.1); }
    .rg-banner p { margin:0; font-size:14px; color:rgba(255,255,255,.9); position:relative; z-index:1; font-weight: 500; }

    .rg-body { padding: 36px 32px; }
    
    /* 表单两列布局 */
    .rg-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px 24px; }
    .rg-form-full { grid-column: 1 / -1; }
    
    @media (max-width: 768px) {
        .rg-form-grid { grid-template-columns: 1fr; gap: 20px; }
        .rg-form-full { grid-column: 1; }
    }
    .rg-field { margin-bottom: 0; }
    .rg-field label { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; font-size: 14px; font-weight: 700; color: #1e293b; }
    .rg-field label svg { width:16px; height:16px; fill:none; stroke:#667eea; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; transition: all .3s cubic-bezier(0.4, 0, 0.2, 1); }
    .rg-field:focus-within label svg { stroke: #764ba2; transform: scale(1.15) rotate(5deg); }
    .rg-field select, .rg-field input[type="text"] {
        width: 100%!important; padding: 12px 16px!important; border: 2px solid #e2e8f0!important;
        border-radius: 12px!important; font-size: 14px!important; font-family: inherit!important;
        background: #ffffff!important; transition: all .3s cubic-bezier(0.4, 0, 0.2, 1)!important; box-sizing: border-box!important;
        height: auto!important; font-weight: 500!important;
    }
    .rg-field select:hover, .rg-field input[type="text"]:hover {
        border-color: #cbd5e1!important;
    }
    .rg-field select:focus, .rg-field input[type="text"]:focus {
        border-color: #667eea!important; outline: none!important;
        box-shadow: 0 0 0 3px rgba(102,126,234,.12)!important;
        transform: translateY(-1px)!important;
    }

    .rg-msg { text-align: center; margin-bottom: 16px; min-height: 20px; }

    .rg-actions { display: flex; gap: 12px; justify-content: center; padding-top: 8px; }
    input.rg-btn { display:inline-block!important; padding:14px 40px!important; border-radius:50px!important; border:none!important; background:linear-gradient(135deg,#667eea,#764ba2)!important; color:#fff!important; font-size:15px!important; font-weight:700!important; cursor:pointer!important; font-family:inherit!important; letter-spacing:0.5px; box-shadow:0 6px 20px rgba(102,126,234,.3); transition:all .3s cubic-bezier(0.4, 0, 0.2, 1); height:auto!important; width:auto!important; background-image:linear-gradient(135deg,#667eea,#764ba2)!important; line-height:1.4!important; text-indent:0!important; -webkit-appearance:none!important; appearance:none!important; position: relative; overflow: hidden; }
    input.rg-btn::before { content: ''; position: absolute; top: 50%; left: 50%; width: 0; height: 0; border-radius: 50%; background: rgba(255,255,255,.3); transform: translate(-50%, -50%); transition: width .6s, height .6s; }
    input.rg-btn:hover { transform:translateY(-2px); box-shadow:0 10px 28px rgba(102,126,234,.4); }
    input.rg-btn:hover::before { width: 300px; height: 300px; }
    input.rg-btn-sec { display:inline-block!important; padding:14px 40px!important; border-radius:50px!important; border:2px solid #e2e8f0!important; background:#fff!important; color:#64748b!important; font-size:15px!important; font-weight:700!important; cursor:pointer!important; font-family:inherit!important; letter-spacing:0.5px; transition:all .3s cubic-bezier(0.4, 0, 0.2, 1); height:auto!important; width:auto!important; background-image:none!important; line-height:1.4!important; text-indent:0!important; -webkit-appearance:none!important; appearance:none!important; }
    input.rg-btn-sec:hover { background:#f8fafc!important; border-color:#cbd5e1!important; transform:translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,.08); color:#475569!important; }

    .rg-tip { display:flex; align-items:flex-start; gap:10px; padding:16px 18px; background:linear-gradient(135deg, #eff6ff 0%, #e0e7ff 100%); border:2px solid #c7d2fe; border-radius:14px; margin-top:20px; box-shadow: 0 2px 8px rgba(99,102,241,.08); }
    .rg-tip svg { width:18px; height:18px; fill:none; stroke:#667eea; stroke-width:2.5; flex-shrink:0; margin-top:2px; stroke-linecap:round; stroke-linejoin:round; }
    .rg-tip span { font-size:13px; color:#4338ca; line-height:1.7; font-weight: 500; }

    /* 说明侧栏 */
    .rg-info-card { background:#fff; border-radius:20px; padding:28px 24px; border:none; box-shadow:0 4px 24px rgba(0,0,0,.08), 0 0 0 1px rgba(0,0,0,.04); transition: all .3s cubic-bezier(0.4, 0, 0.2, 1); }
    .rg-info-card:hover { box-shadow:0 8px 32px rgba(0,0,0,.12), 0 0 0 1px rgba(0,0,0,.06); transform: translateY(-2px); }
    .rg-info-card h3 { font-size:17px; font-weight:800; color:#1e293b; margin:0 0 20px; display:flex; align-items:center; gap:10px; }
    .rg-info-card h3 svg { width:20px; height:20px; fill:none; stroke:#667eea; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
    .rg-step-list { list-style:none; padding:0; margin:0; }
    .rg-step-list li { display:flex; align-items:flex-start; gap:14px; padding:14px 0; border-bottom:1px solid #f1f5f9; transition: all .3s; }
    .rg-step-list li:hover { background: #f8fafc; margin: 0 -14px; padding: 14px 14px; border-radius: 12px; border-bottom: 1px solid transparent; }
    .rg-step-list li:last-child { border-bottom:none; }
    .rg-step-num { width:28px; height:28px; border-radius:50%; background:linear-gradient(135deg,#667eea,#764ba2); display:flex; align-items:center; justify-content:center; color:#fff; font-size:13px; font-weight:800; flex-shrink:0; margin-top:2px; box-shadow: 0 4px 12px rgba(102,126,234,.3); }
    .rg-step-text { font-size:14px; color:#475569; line-height:1.7; font-weight: 500; }
    .rg-step-text strong { color:#1e293b; font-weight:700; }
    .rg-faq-item { padding:14px 0; border-bottom:1px solid #f1f5f9; transition: all .3s; }
    .rg-faq-item:hover { background: #f8fafc; margin: 0 -14px; padding: 14px 14px; border-radius: 12px; border-bottom: 1px solid transparent; }
    .rg-faq-item:last-child { border-bottom:none; }
    .rg-faq-q { font-size:14px; font-weight:700; color:#1e293b; margin:0 0 6px; }
    .rg-faq-a { font-size:13px; color:#64748b; line-height:1.7; margin:0; font-weight: 500; }

    /* 验证码字段样式 */
    .rg-field-code { position: relative; }
    .rg-code-group { display: flex; gap: 12px; align-items: stretch; }
    .rg-code-input { flex: 1!important; }
    input.rg-btn-code {
        display: inline-flex!important; align-items: center!important; justify-content: center!important;
        padding: 0 24px!important; border-radius: 14px!important; border: 2px solid #667eea!important;
        background: linear-gradient(135deg, #667eea, #764ba2)!important; color: #fff!important; font-size: 14px!important;
        font-weight: 700!important; cursor: pointer!important; font-family: inherit!important;
        transition: all .3s cubic-bezier(0.4, 0, 0.2, 1)!important; height: auto!important; width: auto!important;
        white-space: nowrap!important; min-width: 130px!important; background-image: linear-gradient(135deg, #667eea, #764ba2)!important;
        line-height: 1.4!important; text-indent: 0!important; flex-shrink: 0!important;
        -webkit-appearance: none!important; appearance: none!important; box-shadow: 0 4px 12px rgba(102,126,234,.25)!important;
    }
    input.rg-btn-code:hover { transform: translateY(-2px)!important; box-shadow: 0 6px 20px rgba(102,126,234,.35)!important; }
    input.rg-btn-code:disabled {
        opacity: 0.6!important; cursor: not-allowed!important;
        background: #e2e8f0!important; border-color: #cbd5e1!important; color: #94a3b8!important;
        transform: none!important; box-shadow: none!important; background-image: none!important;
    }

    /* 验证码字段样式 */
    .rg-field-code { position: relative; }
    .rg-code-group { display: flex; gap: 10px; align-items: stretch; }
    .rg-code-input { flex: 1!important; }
    input.rg-btn-code {
        display: inline-flex!important; align-items: center!important; justify-content: center!important;
        padding: 0 20px!important; border-radius: 12px!important; border: 2px solid #667eea!important;
        background: linear-gradient(135deg, #667eea, #764ba2)!important; color: #fff!important; font-size: 13px!important;
        font-weight: 700!important; cursor: pointer!important; font-family: inherit!important;
        transition: all .3s cubic-bezier(0.4, 0, 0.2, 1)!important; height: auto!important; width: auto!important;
        white-space: nowrap!important; min-width: 120px!important; background-image: linear-gradient(135deg, #667eea, #764ba2)!important;
        line-height: 1.4!important; text-indent: 0!important; flex-shrink: 0!important;
        -webkit-appearance: none!important; appearance: none!important; box-shadow: 0 2px 8px rgba(102,126,234,.2)!important;
    }
    input.rg-btn-code:hover { transform: translateY(-1px)!important; box-shadow: 0 4px 16px rgba(102,126,234,.3)!important; }
    input.rg-btn-code:disabled {
        opacity: 0.6!important; cursor: not-allowed!important;
        background: #e2e8f0!important; border-color: #cbd5e1!important; color: #94a3b8!important;
        transform: none!important; box-shadow: none!important; background-image: none!important;
    }

    /* 输入框图标动画 */
    .rg-field input[type="text"]:focus + .rg-field-icon,
    .rg-field select:focus + .rg-field-icon {
        transform: scale(1.1);
        color: #667eea;
    }

    /* 成功/错误提示样式 */
    .rg-alert { padding: 16px 20px; border-radius: 16px; margin-bottom: 20px; display: flex; align-items: flex-start; gap: 12px; animation: slideDown .4s cubic-bezier(0.4, 0, 0.2, 1); font-weight: 500; }
    .rg-alert svg { width: 20px; height: 20px; fill: none; stroke-width: 2.5; flex-shrink: 0; margin-top: 2px; }
    .rg-alert-success { background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%); border: 2px solid #6ee7b7; color: #065f46; box-shadow: 0 4px 12px rgba(16,185,129,.15); }
    .rg-alert-success svg { stroke: #059669; }
    .rg-alert-error { background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%); border: 2px solid #fca5a5; color: #991b1b; box-shadow: 0 4px 12px rgba(239,68,68,.15); }
    .rg-alert-error svg { stroke: #dc2626; }
    @keyframes slideDown { from { opacity: 0; transform: translateY(-15px) scale(0.95); } to { opacity: 1; transform: translateY(0) scale(1); } }

    /* 成功/错误提示样式 */
    .rg-alert { padding: 12px 16px; border-radius: 12px; margin-bottom: 16px; display: flex; align-items: flex-start; gap: 10px; animation: slideDown .3s ease; }
    .rg-alert svg { width: 18px; height: 18px; fill: none; stroke-width: 2; flex-shrink: 0; margin-top: 1px; }
    .rg-alert-success { background: #d1fae5; border: 1px solid #6ee7b7; color: #065f46; }
    .rg-alert-success svg { stroke: #059669; }
    .rg-alert-error { background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; }
    .rg-alert-error svg { stroke: #dc2626; }
    @keyframes slideDown { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }

    /* 增强的卡片阴影 */
    .rg-card { transition: all .4s cubic-bezier(0.4, 0, 0.2, 1); }
    .rg-card:hover { box-shadow: 0 8px 32px rgba(0,0,0,.12), 0 0 0 1px rgba(0,0,0,.06); transform: translateY(-2px); }

    /* 占位符样式 */
    .rg-field input::placeholder { color: #94a3b8; font-size: 14px; font-weight: 500; }

    /* 加载动画 */
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }

    /* 增强的渐变背景 */
    .rg-banner { position: relative; overflow: hidden; }
    .rg-banner::before {
        animation: float 6s ease-in-out infinite;
    }
    .rg-banner::after {
        animation: float 8s ease-in-out infinite reverse;
    }
    @keyframes float {
        0%, 100% { transform: translateY(0) translateX(0); }
        50% { transform: translateY(-10px) translateX(10px); }
    }

    /* 输入框聚焦动画 */
    .rg-field input[type="text"], .rg-field select {
        position: relative;
    }
    .rg-field input[type="text"]:focus, .rg-field select:focus {
        transform: translateY(-2px);
    }

    /* 加载状态动画 */
    @keyframes shimmer {
        0% { background-position: -1000px 0; }
        100% { background-position: 1000px 0; }
    }

    /* 滚动条美化 */
    .rg-info-card::-webkit-scrollbar { width: 6px; }
    .rg-info-card::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 10px; }
    .rg-info-card::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
    .rg-info-card::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

    /* 按钮点击效果 */
    input.rg-btn:active { transform: translateY(-1px) scale(0.98)!important; box-shadow: 0 4px 16px rgba(102,126,234,.3)!important; }
    input.rg-btn-sec:active { transform: translateY(0) scale(0.98)!important; }
    input.rg-btn-code:active { transform: scale(0.96)!important; }

    /* 提示框脉冲动画 */
    .rg-tip { animation: fadeIn 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px) scale(0.98); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }

    /* 侧边栏卡片淡入 */
    .rg-info-card:nth-child(1) { animation: rgF .6s cubic-bezier(0.4, 0, 0.2, 1) .25s both; }
    .rg-info-card:nth-child(2) { animation: rgF .6s cubic-bezier(0.4, 0, 0.2, 1) .4s both; }

    /* 响应式优化 */
    @media (max-width: 768px) {
        .rg-body-inner { padding: 24px 16px 40px; }
        .rg-body { padding: 28px 24px; }
        .rg-banner { padding: 36px 24px; }
        .rg-banner h2 { font-size: 22px; }
        .rg-banner-icon { width: 56px; height: 56px; }
        .rg-banner-icon svg { width: 28px; height: 28px; }
        .rg-code-group { flex-direction: column; }
        input.rg-btn-code { width: 100%!important; }
        .rg-actions { flex-direction: column; }
        input.rg-btn, input.rg-btn-sec { width: 100%!important; }
        .rg-info-card { padding: 24px 20px; }
        .rg-info-card h3 { font-size: 16px; margin-bottom: 18px; }
    }

    /* 优化文本框高度一致性 */
    .rg-field input[type="text"], .rg-field select {
        min-height: 46px!important;
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
            <a href="/index.aspx" class="pub-btn-login">登录</a>
            <% } %>
        </div>
    </div>
    <div class="rg-body-inner">
    <div class="rg-page">
        <div class="rg-main">
        <div class="rg-card">
            <div class="rg-banner">
                <div class="rg-banner-icon"><svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg></div>
                <h2>新学员注册</h2>
                <p>填写信息完成注册</p>
            </div>
            <div class="rg-body">
                <div class="rg-form-grid">
                    <div class="rg-field">
                        <label><svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg> 年级选择</label>
                        <asp:DropDownList ID="DDLgrade" runat="server" Width="100%"></asp:DropDownList>
                    </div>
                    <div class="rg-field">
                        <label><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg> 班级选择</label>
                        <asp:DropDownList ID="DDLclass" runat="server" Width="100%"></asp:DropDownList>
                    </div>
                    <div class="rg-field">
                        <label><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg> 性别选择</label>
                        <asp:DropDownList ID="DDLsex" runat="server" Font-Size="9pt" Width="100%" BackColor="White"></asp:DropDownList>
                    </div>
                    <div class="rg-field">
                        <label><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg> 姓名</label>
                        <asp:TextBox ID="Tsname" runat="server" Width="100%" Height="20px"></asp:TextBox>
                    </div>
                    <div class="rg-field rg-form-full">
                        <label><svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg> 电子邮箱</label>
                        <asp:TextBox ID="TxtEmail" runat="server" Width="100%" Height="20px" placeholder="用于接收验证码"></asp:TextBox>
                    </div>
                    <div class="rg-field rg-field-code rg-form-full">
                        <label><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg> 邮箱验证码</label>
                        <div class="rg-code-group">
                            <asp:TextBox ID="TxtVerifyCode" runat="server" Width="100%" Height="20px" placeholder="请输入验证码" CssClass="rg-code-input"></asp:TextBox>
                            <asp:Button ID="BtnSendCode" runat="server" Text="发送验证码" CssClass="rg-btn-code" OnClientClick="return sendVerifyCode();" />
                        </div>
                    </div>
                </div>
                <asp:HiddenField ID="HiddenEmailVerified" runat="server" Value="false" />
                <div class="rg-msg">
                    <asp:Label ID="labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
                </div>
                <div class="rg-actions">
                    <asp:Button ID="BtnRegister" runat="server" onclick="BtnRegister_Click" Text="确定注册" CssClass="rg-btn" OnClientClick="return validateForm();" />
                    <asp:Button ID="BtnReturn" runat="server" onclick="BtnReturn_Click" Text="返回" CssClass="rg-btn-sec" />
                </div>
                <div class="rg-tip">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <span>请选择老师指定的年级和班级进行注册，以免错班而无法处理！</span>
                </div>
            </div>
        </div>
        </div><!-- /rg-main -->
        <div class="rg-side">
            <div class="rg-info-card">
                <h3><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>注册流程</h3>
                <ul class="rg-step-list">
                    <li><span class="rg-step-num">1</span><span class="rg-step-text">选择老师指定的<strong>年级和班级</strong>，确保信息正确</span></li>
                    <li><span class="rg-step-num">2</span><span class="rg-step-text">选择性别，填写<strong>真实姓名</strong>，不可使用昵称</span></li>
                    <li><span class="rg-step-num">3</span><span class="rg-step-text">输入<strong>有效邮箱</strong>并获取验证码进行验证</span></li>
                    <li><span class="rg-step-num">4</span><span class="rg-step-text">点击"确定注册"完成，系统将自动分配学号</span></li>
                    <li><span class="rg-step-num">5</span><span class="rg-step-text">使用分配的学号和<strong>初始密码</strong>登录系统</span></li>
                </ul>
            </div>
            <div class="rg-info-card">
                <h3><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>常见问题</h3>
                <div class="rg-faq-item">
                    <p class="rg-faq-q">收不到验证码怎么办？</p>
                    <p class="rg-faq-a">请检查邮箱地址是否正确，查看垃圾邮件箱，或稍后重试发送验证码。</p>
                </div>
                <div class="rg-faq-item">
                    <p class="rg-faq-q">注册后如何登录？</p>
                    <p class="rg-faq-a">在首页输入学号和初始密码即可登录，初始密码可在学号查询页面获取。</p>
                </div>
                <div class="rg-faq-item">
                    <p class="rg-faq-q">选错班级怎么办？</p>
                    <p class="rg-faq-a">请联系老师协助处理，切勿自行重复注册新账号。</p>
                </div>
                <div class="rg-faq-item">
                    <p class="rg-faq-q">忘记密码怎么办？</p>
                    <p class="rg-faq-a">可通过注册邮箱重置密码，或联系老师协助重置。</p>
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
                    <a href="../index.aspx" class="site-footer-logo">
                        <% if (!string.IsNullOrEmpty(pubLogoUrl)) { %>
                        <span class="site-footer-logo-icon"><img src="<%= pubLogoUrl %>" alt="Logo" /></span>
                        <% } else { %>
                        <span class="site-footer-logo-icon site-footer-logo-text">L</span>
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
    
<script type="text/javascript">
    var countdownTimer = null;
    var countdown = 60;

    function sendVerifyCode() {
        var emailInput = document.getElementById('<%= TxtEmail.ClientID %>');
        var sendBtn = document.getElementById('<%= BtnSendCode.ClientID %>');

        if (!emailInput || !sendBtn) return false;

        var email = emailInput.value.trim();

        // 验证邮箱格式
        var emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        if (!email) {
            showAlert('请输入电子邮箱', 'error');
            emailInput.focus();
            return false;
        }
        if (!emailRegex.test(email)) {
            showAlert('请输入有效的电子邮箱地址', 'error');
            emailInput.focus();
            return false;
        }

        // 禁用按钮
        sendBtn.disabled = true;
        var originalText = sendBtn.value;
        sendBtn.value = '发送中...';

        // 使用 AJAX 调用后端
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'SendEmailCode.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            showAlert(response.message, 'success');
                            startCountdown(sendBtn);
                        } else {
                            showAlert(response.message, 'error');
                            sendBtn.disabled = false;
                            sendBtn.value = originalText;
                        }
                    } catch (e) {
                        showAlert('发送失败，请稍后重试', 'error');
                        sendBtn.disabled = false;
                        sendBtn.value = originalText;
                    }
                } else {
                    showAlert('网络错误，请稍后重试', 'error');
                    sendBtn.disabled = false;
                    sendBtn.value = originalText;
                }
            }
        };

        xhr.send('email=' + encodeURIComponent(email));
        return false; // 阻止默认提交
    }

    function startCountdown(btn) {
        countdown = 60;
        updateButtonText(btn);

        countdownTimer = setInterval(function() {
            countdown--;
            if (countdown <= 0) {
                clearInterval(countdownTimer);
                btn.disabled = false;
                btn.value = '发送验证码';
            } else {
                updateButtonText(btn);
            }
        }, 1000);
    }

    function updateButtonText(btn) {
        btn.value = countdown + '秒后重试';
    }

    function showAlert(message, type) {
        var msgContainer = document.querySelector('.rg-msg');
        if (!msgContainer) return;

        var iconPath = type === 'success'
            ? '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>'
            : '<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>';

        var alertClass = type === 'success' ? 'rg-alert-success' : 'rg-alert-error';
        var alertHtml = '<div class="rg-alert ' + alertClass + '">' +
            '<svg viewBox="0 0 24 24">' + iconPath + '</svg>' +
            '<span>' + message + '</span>' +
            '</div>';

        msgContainer.innerHTML = alertHtml;

        // 3秒后自动消失（成功消息）
        if (type === 'success') {
            setTimeout(function() {
                if (msgContainer.innerHTML.indexOf(message) > -1) {
                    msgContainer.innerHTML = '';
                }
            }, 3000);
        }
    }

    // 表单提交前验证
    function validateForm() {
        var email = document.getElementById('<%= TxtEmail.ClientID %>').value.trim();
        var code = document.getElementById('<%= TxtVerifyCode.ClientID %>').value.trim();
        var name = document.getElementById('<%= Tsname.ClientID %>').value.trim();

        if (!name) {
            showAlert('请输入姓名', 'error');
            return false;
        }

        if (!email) {
            showAlert('请输入电子邮箱', 'error');
            return false;
        }

        var emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        if (!emailRegex.test(email)) {
            showAlert('请输入有效的电子邮箱地址', 'error');
            return false;
        }

        if (!code) {
            showAlert('请输入邮箱验证码', 'error');
            return false;
        }

        // 验证验证码是否正确
        return verifyCodeBeforeSubmit(email, code);
    }

    // 提交前验证验证码
    function verifyCodeBeforeSubmit(email, code) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'VerifyEmailCode.ashx', false); // 同步请求
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

        var result = false;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        document.getElementById('<%= HiddenEmailVerified.ClientID %>').value = 'true';
                        result = true;
                    } else {
                        showAlert(response.message, 'error');
                        result = false;
                    }
                } catch (e) {
                    showAlert('验证失败，请重试', 'error');
                    result = false;
                }
            }
        };

        xhr.send('email=' + encodeURIComponent(email) + '&code=' + encodeURIComponent(code));
        return result;
    }

    // 页面加载完成后添加事件监听
    window.onload = function() {
        // 监听邮箱输入框变化，如果邮箱改变则清除验证状态
        var emailInput = document.getElementById('<%= TxtEmail.ClientID %>');
        if (emailInput) {
            var lastEmail = emailInput.value;
            emailInput.addEventListener('input', function() {
                if (this.value !== lastEmail) {
                    document.getElementById('<%= HiddenEmailVerified.ClientID %>').value = 'false';
                    lastEmail = this.value;
                }
            });
        }
    };
</script>
<script src="../js/pub-footer.js"></script>
    </form>
</body>
</html>
