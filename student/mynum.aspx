<%@ page title="" language="C#" stylesheettheme="Student" autoeventwireup="true" inherits="Student_mynum, LearnSite" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>学号查询</title>
    <link href="../js/tooltip.css" rel="stylesheet" type="text/css" />
    <link href="../js/pub-header.css" rel="stylesheet" type="text/css" />
    <link href="../js/pub-footer.css?v=final" rel="stylesheet" type="text/css" />
    <script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
<style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { margin: 0; padding: 0; background: #f0f2f5; min-height: 100vh; font-family: 'Microsoft YaHei','Segoe UI',sans-serif; }
    .mn-body-inner { padding: 24px; }
    .mn-page { max-width: 1400px; margin: 0 auto; animation: mnFade .4s ease; }
    @keyframes mnFade { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }

    /* 搜索卡片 */
    .mn-search-card { background: #fff; border-radius: 18px; padding: 24px 28px; margin-bottom: 24px; box-shadow: 0 2px 12px rgba(0,0,0,.05); border: 1px solid #e5e7eb; }
    .mn-search-head { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
    .mn-search-icon { width: 40px; height: 40px; border-radius: 12px; background: linear-gradient(135deg, #6366f1, #818cf8); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .mn-search-icon svg { width: 20px; height: 20px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mn-search-head h2 { margin: 0; font-size: 18px; font-weight: 700; color: #1e293b; }
    .mn-search-row { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .mn-field { display: flex; align-items: center; gap: 8px; }
    .mn-field label { font-size: 14px; color: #475569; font-weight: 600; white-space: nowrap; }
    .mn-field select { padding: 9px 14px; border: 1.5px solid #e2e8f0; border-radius: 10px; font-size: 14px; font-family: inherit; background: #f9fafb; min-width: 70px; }
    .mn-field select:focus { border-color: #6366f1; outline: none; box-shadow: 0 0 0 3px rgba(99,102,241,.12); }
    input.mn-search-btn { padding: 9px 28px !important; border-radius: 10px !important; border: none !important; background: linear-gradient(135deg, #6366f1, #818cf8) !important; color: #fff !important; font-size: 14px !important; font-weight: 600 !important; cursor: pointer; font-family: inherit !important; box-shadow: 0 2px 8px rgba(99,102,241,.2); transition: all .2s; height: auto !important; width: auto !important; background-image: linear-gradient(135deg, #6366f1, #818cf8) !important; line-height: 1.4 !important; text-indent: 0 !important; -webkit-appearance: none !important; appearance: none !important; }
    input.mn-search-btn:hover { transform: translateY(-1px); box-shadow: 0 4px 14px rgba(99,102,241,.3); }
    .mn-pwd-box { display: flex; align-items: center; gap: 8px; margin-left: 8px; padding: 6px 14px; background: #fef3c7; border: 1.5px solid #fde68a; border-radius: 10px; }
    .mn-pwd-label { font-size: 13px; color: #92400e; font-weight: 600; }
    .mn-pwd-box input[type="text"] { border: none !important; background: transparent !important; font-size: 18px !important; font-weight: 700 !important; color: #dc2626 !important; width: 70px !important; text-align: center; cursor: pointer; padding: 0 !important; }

    /* 学生卡片网格 */
    .mn-grid-card { background: #fff; border-radius: 18px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,.05); border: 1px solid #e5e7eb; }
    .mn-grid-card table { border: none !important; border-spacing: 8px !important; width: 100% !important; }
    .mn-grid-card table td { border: none !important; padding: 0 !important; background: none !important; vertical-align: top !important; }
    .mn-grid-card table tr { background: none !important; }
    .mn-grid-card .stunum { text-align: center; padding: 14px 8px; border-radius: 14px; background: #f8fafc; border: 1px solid #f1f5f9; transition: all .2s; }
    .mn-grid-card .stunum:hover { background: #eef2ff; border-color: #c7d2fe; transform: translateY(-3px); box-shadow: 0 6px 16px rgba(99,102,241,.1); }
    .mn-grid-card .stuimg { width: 52px !important; height: 52px !important; border-radius: 50% !important; object-fit: cover; border: 2px solid #e2e8f0 !important; transition: all .2s; background: linear-gradient(135deg,#eef2ff,#f8fafc); }
    .mn-grid-card .stunum:hover .stuimg { border-color: #a5b4fc !important; }
    .mn-grid-card .stulink { display: block; margin-top: 8px; font-size: 13px !important; font-weight: 600; color: #334155 !important; text-decoration: none !important; }
    .mn-grid-card .stunum:hover .stulink { color: #4338ca !important; }

    /* 说明板块 */
    .mn-info-bar { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
    .mn-info-item { flex: 1; min-width: 200px; background: #fff; border-radius: 14px; padding: 18px 20px; border: 1px solid #e5e7eb; box-shadow: 0 1px 6px rgba(0,0,0,.03); display: flex; align-items: flex-start; gap: 12px; }
    .mn-info-icon { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .mn-info-icon svg { width: 18px; height: 18px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mn-info-icon.ic1 { background: linear-gradient(135deg, #6366f1, #818cf8); }
    .mn-info-icon.ic2 { background: linear-gradient(135deg, #f59e0b, #fbbf24); }
    .mn-info-icon.ic3 { background: linear-gradient(135deg, #10b981, #34d399); }
    .mn-info-icon.ic4 { background: linear-gradient(135deg, #f43f5e, #fb7185); }
    .mn-info-body h4 { font-size: 13px; font-weight: 700; color: #1e293b; margin: 0 0 4px; }
    .mn-info-body p { font-size: 12px; color: #64748b; line-height: 1.6; margin: 0; }

    /* 隐藏原始元素 */
    .mn-page .studmasterhead, .mn-page .banner, .mn-page .menu, .mn-page .path { display: none !important; }
</style>
</head>
<script runat="server">
    protected string pubUserName = "";
    protected string pubUserInitial = "";
    protected string pubUserClass = "";
    protected bool pubLoggedIn = false;
    protected string pubSiteTitle = "LearnSite";
    protected string pubLogoUrl = "";

    // Footer settings from ~/App_Data/footersetting.xml
    protected string footerCopyright = "";
    protected string footerIcp = "";
    protected string footerIcpUrl = "";
    protected string footerCustomHtml = "";
    protected bool footerShowPoweredBy = true;
    protected string footerBgColor = "#1e293b";
    protected string footerTextColor = "#94a3b8";
    protected bool footerHasSettings = false;

    private void LoadFooterSettings() {
        try {
            string xmlPath = Server.MapPath("~/App_Data/footersetting.xml");
            if (!System.IO.File.Exists(xmlPath)) return;
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            footerCopyright = ReadFooterNode(doc, "copyright");
            footerIcp = ReadFooterNode(doc, "icp");
            footerIcpUrl = ReadFooterNode(doc, "icpUrl");
            footerCustomHtml = ReadFooterNode(doc, "customHtml");
            string pb = ReadFooterNode(doc, "showPoweredBy");
            footerShowPoweredBy = (pb != "false");
            string bg = ReadFooterNode(doc, "bgColor");
            if (!string.IsNullOrEmpty(bg)) footerBgColor = bg;
            string tc = ReadFooterNode(doc, "textColor");
            if (!string.IsNullOrEmpty(tc)) footerTextColor = tc;
            footerHasSettings = true;
        } catch { }
    }

    private string ReadFooterNode(System.Xml.XmlDocument doc, string name) {
        System.Xml.XmlNode node = doc.SelectSingleNode("//" + name);
        if (node != null) return node.InnerText;
        return "";
    }

    protected string GetSiteTitle() {
        try {
            string xmlPath = Server.MapPath("~/website.xml");
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            System.Xml.XmlNode node = doc.SelectSingleNode("//add[@key='SiteTitle']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value;
        } catch { }
        return "LearnSite";
    }

    protected string GetSiteLogoUrl() {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
        foreach (string ext in exts) {
            string path = Server.MapPath("~/images/site-logo" + ext);
            if (System.IO.File.Exists(path))
                return ResolveUrl("~/images/site-logo" + ext) + "?v=" + System.IO.File.GetLastWriteTime(path).Ticks;
        }
        return "";
    }

    protected string GetStudentAvatarUrl(object snumObj) {
        string snum = snumObj == null ? "" : snumObj.ToString().Trim();
        string[] exts = { ".jpg", ".png", ".jpeg", ".gif", ".webp" };

        if (!string.IsNullOrEmpty(snum)) {
            foreach (string ext in exts) {
                string rel1 = "~/code/imgchat/head/" + snum + ext;
                string path1 = Server.MapPath(rel1);
                if (System.IO.File.Exists(path1)) {
                    return ResolveUrl(rel1) + "?v=" + System.IO.File.GetLastWriteTime(path1).Ticks;
                }
            }

            foreach (string ext in exts) {
                string rel2 = "~/images/avatars/" + snum + ext;
                string path2 = Server.MapPath(rel2);
                if (System.IO.File.Exists(path2)) {
                    return ResolveUrl(rel2) + "?v=" + System.IO.File.GetLastWriteTime(path2).Ticks;
                }
            }
        }

        return ResolveUrl("~/images/face.png") + "?temp=" + DateTime.Now.Ticks;
    }

    protected override void OnPreRender(EventArgs e) {
        pubSiteTitle = GetSiteTitle();
        pubLogoUrl = GetSiteLogoUrl();
        LoadFooterSettings();
        base.OnPreRender(e);
        try {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value)) {
                string cv = sc.Value;
                if (cv.Contains("%")) try { cv = HttpUtility.UrlDecode(cv, System.Text.Encoding.UTF8); } catch {}
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null) {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", System.Reflection.BindingFlags.Public|System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[]{cv});
                    System.Reflection.PropertyInfo pn = ct.GetProperty("Sname");
                    if (pn != null) { object v = pn.GetValue(m,null); if(v!=null) { string s=v.ToString(); if(s.Contains("%")) try{s=HttpUtility.UrlDecode(s,System.Text.Encoding.UTF8);}catch{} pubUserName=s; if(s.Length>0) pubUserInitial=s.Substring(0,1); pubLoggedIn=true; } }
                    System.Reflection.PropertyInfo pg = ct.GetProperty("Sgrade"); System.Reflection.PropertyInfo pc = ct.GetProperty("Sclass");
                    string g="",c=""; if(pg!=null){object gv=pg.GetValue(m,null);if(gv!=null)g=gv.ToString();} if(pc!=null){object cv2=pc.GetValue(m,null);if(cv2!=null)c=cv2.ToString();}
                    if(!string.IsNullOrEmpty(g)&&g!="0"&&!string.IsNullOrEmpty(c)&&c!="0") pubUserClass=g+"\u5E74\u7EA7"+c+"\u73ED"; else if(!string.IsNullOrEmpty(c)&&c!="0") pubUserClass=c+"\u73ED";
                }
            }
        } catch {}
    }
</script>
<body>
    <form id="form1" runat="server">
    <!-- 顶栏 -->
    <div class="pub-hdr">
        <a href="../index.aspx" class="pub-hdr-logo">
            <% if (!string.IsNullOrEmpty(pubLogoUrl)) { %>
            <img src="<%= pubLogoUrl %>" alt="Logo" />
            <% } else { %>
            <span class="pub-hdr-logo-fb">L</span>
            <% } %>
            <span><%= Server.HtmlEncode(pubSiteTitle) %></span>
        </a>
        <div class="pub-hdr-space"></div>
        <div class="pub-hdr-actions">
            <% if (pubLoggedIn) { %>
            <div class="pub-user">
                <div class="pub-user-avatar"><%= Server.HtmlEncode(pubUserInitial) %></div>
                <span class="pub-user-name"><%= Server.HtmlEncode(pubUserName) %></span>
                <% if (!string.IsNullOrEmpty(pubUserClass)) { %><span class="pub-user-class"><%= Server.HtmlEncode(pubUserClass) %></span><% } %>
            </div>
            <% } else { %>
            <a href="/index.aspx" class="pub-btn-login">登录</a>
            <a href="../student/register.aspx" class="pub-btn-reg">注册</a>
            <% } %>
        </div>
    </div>
    <div class="mn-body-inner">
    <div class="mn-page">
        <!-- 使用说明 -->
        <div class="mn-info-bar">
            <div class="mn-info-item">
                <span class="mn-info-icon ic1"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></span>
                <div class="mn-info-body"><h4>查询学号</h4><p>选择年级和班级，点击查询按钮即可查看班级同学的学号信息</p></div>
            </div>
            <div class="mn-info-item">
                <span class="mn-info-icon ic2"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                <div class="mn-info-body"><h4>初始密码</h4><p>右侧红色数字为初始密码，点击即可一键复制到剪贴板</p></div>
            </div>
            <div class="mn-info-item">
                <span class="mn-info-icon ic3"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                <div class="mn-info-body"><h4>头像自动显示</h4><p>页面会优先显示同学已上传头像，没有头像时自动回退为默认头像</p></div>
            </div>
            <div class="mn-info-item">
                <span class="mn-info-icon ic4"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></span>
                <div class="mn-info-body"><h4>安全提醒</h4><p>请登录后及时修改初始密码，保护个人账号安全</p></div>
            </div>
        </div>
        <div class="mn-search-card">
            <div class="mn-search-head">
                <span class="mn-search-icon"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></span>
                <h2>学号查询</h2>
            </div>
            <div class="mn-search-row">
                <div class="mn-field">
                    <label>年级</label>
                    <asp:DropDownList ID="DDLgrade" runat="server" Width="70px" AutoPostBack="True" 
                        onselectedindexchanged="DDLgrade_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="mn-field">
                    <label>班级</label>
                    <asp:DropDownList ID="DDLclass" runat="server" Width="70px" 
                        AutoPostBack="True" onselectedindexchanged="DDLclass_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <asp:Button ID="BtnSearch" runat="server" OnClick="BtnSearch_Click" Text="查询" CssClass="mn-search-btn" />
                <div class="mn-pwd-box">
                    <span class="mn-pwd-label">密码</span>
                    <asp:TextBox ID="TextBoxPwd" runat="server" ReadOnly="True"
                        Width="60px" BorderStyle="None"
                        onClick="copy()" Font-Bold="True" Font-Size="X-Large" ForeColor="#dc2626">123</asp:TextBox>
                </div>
            </div>
        </div>
        <div class="mn-grid-card">
            <asp:DataList ID="DataListsnum" runat="server" RepeatDirection="Horizontal" RepeatColumns="8"
                CellPadding="4" OnItemDataBound="DataListsnum_ItemDataBound" 
                HorizontalAlign="Center" CellSpacing="4">
                <ItemTemplate>
                    <div class="stunum">
                        <asp:Image ID="ImageStu" class="stuimg" runat="server" Visible="True" ImageUrl='<%# GetStudentAvatarUrl(Eval("Snum")) %>' /><br />
                        <asp:HyperLink ID="HLSnum" runat="server" Text='<%# Eval("Sname") %>' ToolTip='<%# Eval("Snum") %>' CssClass="stulink"></asp:HyperLink>
                    </div>
                </ItemTemplate>
            </asp:DataList>
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
    
    <script src="../js/ToolTip.js" type="text/javascript"></script>
    <script src="../js/pub-footer.js"></script>
    <script type="text/javascript">
        var msg = document.getElementById("TextBoxPwd");  
        msg.title ='点击复制';
        function copy() {
            copyTextToClipboard(msg.value);
            msg.title ='已复制';
        }
        async function copyTextToClipboard(text) {
            try {
                await navigator.clipboard.writeText(text);
            } catch (err) {
                console.error('Failed to copy: ', err);
            }
        }

        $(function () {
            $('.stuimg').on('error', function () {
                this.onerror = null;
                this.src = '../images/face.png';
            });
        });
    </script>
    </form>
</body>
</html>
