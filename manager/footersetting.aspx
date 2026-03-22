<%@ Page Title="" Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LabelMsg.Visible = false;
            LoadSettings();
        }
    }
    private void LoadSettings()
    {
        try
        {
            string xmlPath = Server.MapPath("~/App_Data/footersetting.xml");
            if (System.IO.File.Exists(xmlPath))
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(xmlPath);
                TxtDescription.Text = ReadNode(doc, "description");
                TxtCopyright.Text = ReadNode(doc, "copyright");
                TxtIcp.Text = ReadNode(doc, "icp");
                TxtIcpUrl.Text = ReadNode(doc, "icpUrl");
                TxtGithub.Text = ReadNode(doc, "githubUrl");
                TxtTwitter.Text = ReadNode(doc, "twitterUrl");
                TxtEmail.Text = ReadNode(doc, "emailUrl");
                TxtRss.Text = ReadNode(doc, "rssUrl");
                TxtProduct1.Text = ReadNode(doc, "product1");
                TxtProduct2.Text = ReadNode(doc, "product2");
                TxtProduct3.Text = ReadNode(doc, "product3");
                TxtProduct4.Text = ReadNode(doc, "product4");
                TxtSupport1.Text = ReadNode(doc, "support1");
                TxtSupport2.Text = ReadNode(doc, "support2");
                TxtSupport3.Text = ReadNode(doc, "support3");
                TxtSupport4.Text = ReadNode(doc, "support4");
                TxtAbout1.Text = ReadNode(doc, "about1");
                TxtAbout2.Text = ReadNode(doc, "about2");
                TxtAbout3.Text = ReadNode(doc, "about3");
                TxtAbout4.Text = ReadNode(doc, "about4");
                ChkShowPoweredBy.Checked = ReadNode(doc, "showPoweredBy") != "false";
                ChkFooterEnabled.Checked = ReadNode(doc, "footerEnabled") != "false";
            }
            else SetDefaultValues();
        }
        catch (Exception ex) { SetMessage("加载设置失败: " + Server.HtmlEncode(ex.Message), "msg msg-danger"); }
    }
    private void SetDefaultValues()
    {
        TxtDescription.Text = "专业在线学习平台，致力于为学生和教师提供优质的教学体验和学习资源。";
        TxtCopyright.Text = "© {year} LearnSite. All rights reserved";
        TxtGithub.Text = "#"; TxtTwitter.Text = "#"; TxtEmail.Text = "#"; TxtRss.Text = "#";
        TxtProduct1.Text = "../default.aspx|在线课程"; TxtProduct2.Text = "../student/mywork.aspx|作业系统";
        TxtProduct3.Text = "../student/myquiz.aspx|考试测评"; TxtProduct4.Text = "../student/myfile.aspx|学习资源";
        TxtSupport1.Text = "../help/index.aspx|帮助中心"; TxtSupport2.Text = "../help/docs.aspx|使用文档";
        TxtSupport3.Text = "../help/faq.aspx|常见问题"; TxtSupport4.Text = "../help/contact.aspx|联系我们";
        TxtAbout1.Text = "../about/index.aspx|关于我们"; TxtAbout2.Text = "../about/join.aspx|加入我们";
        TxtAbout3.Text = "../about/privacy.aspx|隐私政策"; TxtAbout4.Text = "../about/terms.aspx|服务条款";
        ChkShowPoweredBy.Checked = true; ChkFooterEnabled.Checked = true;
    }
    private string ReadNode(System.Xml.XmlDocument doc, string name)
    {
        System.Xml.XmlNode node = doc.SelectSingleNode("//" + name);
        return node != null ? node.InnerText : "";
    }
    private void AddNode(System.Xml.XmlDocument doc, System.Xml.XmlElement parent, string name, string value)
    {
        System.Xml.XmlElement element = doc.CreateElement(name);
        element.InnerText = value ?? "";
        parent.AppendChild(element);
    }
    private void SetMessage(string text, string cssClass)
    {
        LabelMsg.Text = text;
        LabelMsg.CssClass = cssClass;
        LabelMsg.Visible = true;
    }
    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string xmlPath = Server.MapPath("~/App_Data/footersetting.xml");
            string dirPath = Server.MapPath("~/App_Data");
            if (!System.IO.Directory.Exists(dirPath)) System.IO.Directory.CreateDirectory(dirPath);
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.AppendChild(doc.CreateXmlDeclaration("1.0", "UTF-8", null));
            System.Xml.XmlElement root = doc.CreateElement("footerSettings");
            doc.AppendChild(root);
            AddNode(doc, root, "description", TxtDescription.Text);
            AddNode(doc, root, "copyright", TxtCopyright.Text);
            AddNode(doc, root, "icp", TxtIcp.Text);
            AddNode(doc, root, "icpUrl", TxtIcpUrl.Text);
            AddNode(doc, root, "githubUrl", TxtGithub.Text);
            AddNode(doc, root, "twitterUrl", TxtTwitter.Text);
            AddNode(doc, root, "emailUrl", TxtEmail.Text);
            AddNode(doc, root, "rssUrl", TxtRss.Text);
            AddNode(doc, root, "product1", TxtProduct1.Text);
            AddNode(doc, root, "product2", TxtProduct2.Text);
            AddNode(doc, root, "product3", TxtProduct3.Text);
            AddNode(doc, root, "product4", TxtProduct4.Text);
            AddNode(doc, root, "support1", TxtSupport1.Text);
            AddNode(doc, root, "support2", TxtSupport2.Text);
            AddNode(doc, root, "support3", TxtSupport3.Text);
            AddNode(doc, root, "support4", TxtSupport4.Text);
            AddNode(doc, root, "about1", TxtAbout1.Text);
            AddNode(doc, root, "about2", TxtAbout2.Text);
            AddNode(doc, root, "about3", TxtAbout3.Text);
            AddNode(doc, root, "about4", TxtAbout4.Text);
            AddNode(doc, root, "showPoweredBy", ChkShowPoweredBy.Checked ? "true" : "false");
            AddNode(doc, root, "footerEnabled", ChkFooterEnabled.Checked ? "true" : "false");
            doc.Save(xmlPath);
            SetMessage("保存成功！", "msg msg-success");
        }
        catch (Exception ex) { SetMessage("保存失败: " + Server.HtmlEncode(ex.Message), "msg msg-danger"); }
    }
    protected void BtnReset_Click(object sender, EventArgs e)
    {
        SetDefaultValues();
        SetMessage("已重置为默认值，请点击保存按钮保存更改。", "msg msg-info");
    }
</script>
<style>
    .fs,*{box-sizing:border-box}.fs{max-width:1400px;margin:0 auto;padding:28px;color:#0f172a;font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif}
    .hero{display:grid;grid-template-columns:minmax(0,1.45fr) 300px;gap:20px;padding:28px;border-radius:28px;background:linear-gradient(135deg,#fffdf7,#eef6ff 52%,#f0fdf4);color:#0f172a;border:1px solid #dbe6f2;box-shadow:0 18px 38px rgba(148,163,184,.14)}
    .hero h2{margin:14px 0 10px;font-size:32px;color:#0f172a}.hero p{margin:0;font-size:15px;line-height:1.8;color:#475569}
    .tag{display:inline-flex;padding:8px 12px;border-radius:999px;background:rgba(255,255,255,.82);border:1px solid #bfdbfe;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb}
    .tips{padding:20px;border-radius:22px;background:rgba(255,255,255,.78);border:1px solid #dbe6f2}.tips h4{margin:0 0 12px;font-size:12px;color:#2563eb;letter-spacing:.08em;text-transform:uppercase}
    .tips div{display:flex;gap:10px;line-height:1.75;margin-top:10px;color:#475569}.tips b{display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:9px;background:#dbeafe;color:#1d4ed8;font-size:11px;flex-shrink:0}
    .msg{display:block;margin:18px 0;padding:14px 16px;border-radius:16px;font-size:14px;line-height:1.7}.msg-success{background:#dcfce7;color:#166534;border:1px solid #86efac}.msg-danger{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5}.msg-info{background:#dbeafe;color:#1d4ed8;border:1px solid #93c5fd}
    .layout{display:grid;grid-template-columns:minmax(0,1fr) 300px;gap:22px;margin-top:22px}
    .main{display:grid;gap:18px}.side{display:grid;gap:18px;align-self:start;position:sticky;top:18px}
    .card{background:#fff;border:1px solid #e2e8f0;border-radius:24px;box-shadow:0 12px 26px rgba(15,23,42,.05);overflow:hidden}
    .head{display:flex;gap:14px;padding:20px 22px 16px;background:linear-gradient(180deg,#fff,#f8fafc);border-bottom:1px solid #eef2f7}.head h3{margin:0;font-size:17px}.head p{margin:5px 0 0;font-size:13px;color:#64748b;line-height:1.7}
    .ico{width:42px;height:42px;border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0}.ico svg{width:20px;height:20px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
    .blue{background:#dbeafe;color:#2563eb}.green{background:#d1fae5;color:#047857}.amber{background:#fef3c7;color:#d97706}.violet{background:#ede9fe;color:#6d28d9}.rose{background:#ffe4e6;color:#e11d48}
    .body{padding:20px 22px 22px}.grid2{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px 18px}
    .field{margin-bottom:16px}.field:last-child{margin-bottom:0}.field label{display:flex;align-items:center;gap:8px;margin-bottom:9px;font-size:14px;font-weight:700;color:#334155}
    .field input[type=text],.field textarea{width:100%;padding:13px 14px;border:1px solid #d7e1ea;border-radius:14px;background:linear-gradient(180deg,#fff,#f8fafc);font-size:14px;color:#0f172a;transition:border-color .18s,box-shadow .18s}
    .field input[type=text]:focus,.field textarea:focus{outline:none;border-color:#2563eb;box-shadow:0 0 0 4px rgba(37,99,235,.12);background:#fff}.field textarea{min-height:96px;resize:vertical;line-height:1.7}
    .mini{margin-top:8px;font-size:12px;line-height:1.7;color:#64748b}.hint{display:inline-flex;padding:3px 8px;border-radius:999px;background:#eff6ff;color:#2563eb;font-size:11px;font-weight:700}
    .note{margin-bottom:16px;padding:13px 14px;border-radius:16px;border:1px solid #dbeafe;background:#eff6ff;font-size:13px;line-height:1.75;color:#1d4ed8}.note code{padding:2px 8px;border-radius:999px;background:rgba(255,255,255,.82);color:#0f172a;font-family:Consolas,monospace}
    .switch{display:flex;align-items:center;justify-content:space-between;gap:18px;padding:18px 20px;border:1px solid #dbe6f2;border-radius:20px;background:linear-gradient(135deg,#fff,#f8fbff)}
    .switch strong{display:block;font-size:16px}.switch span.txt{display:block;margin-top:4px;font-size:13px;line-height:1.7;color:#64748b}
    .swrap{position:relative;flex-shrink:0}.swrap>input[type=checkbox],.swrap>span>input[type=checkbox]{position:absolute;opacity:0;pointer-events:none}
    .track{position:relative;display:inline-flex;width:52px;height:30px;border-radius:999px;background:#e2e8f0;border:1px solid #cbd5e1;cursor:pointer;transition:all .25s}.track:before{content:"";position:absolute;top:3px;left:3px;width:22px;height:22px;border-radius:50%;background:#fff;box-shadow:0 2px 4px rgba(15,23,42,.16);transition:transform .25s}.track.on{background:linear-gradient(135deg,#2563eb,#0f766e);border-color:#2563eb}.track.on:before{transform:translateX(22px)}
    .check{display:flex;align-items:flex-start;gap:12px;padding:14px 16px;border:1px solid #dbe6f2;border-radius:16px;background:linear-gradient(135deg,#fff,#f8fafc)}.check input[type=checkbox]{width:18px;height:18px;accent-color:#2563eb;flex-shrink:0;margin-top:1px}
    .check strong{display:block;font-size:14px}.check span{display:block;margin-top:4px;font-size:12px;line-height:1.7;color:#64748b}
    .panel{padding:20px 22px;border-radius:22px;border:1px solid #e2e8f0;background:#fff;box-shadow:0 12px 24px rgba(15,23,42,.05)}.panel h4{margin:0 0 12px;font-size:15px}.panel div{display:flex;gap:10px;align-items:flex-start;margin-top:10px;font-size:13px;line-height:1.75;color:#64748b}
    .panel b{display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:8px;background:#eff6ff;color:#2563eb;font-size:11px;flex-shrink:0}
    .actions{padding:20px 22px;border-radius:22px;background:linear-gradient(135deg,#fffdf7,#eff6ff 55%,#f8fafc);color:#0f172a;border:1px solid #dbe6f2;box-shadow:0 12px 24px rgba(148,163,184,.12)}.actions h4{margin:0 0 8px;font-size:16px;color:#0f172a}.actions p{margin:0 0 16px;font-size:13px;line-height:1.8;color:#475569}
    .btns{display:flex;flex-wrap:wrap;gap:12px}.btn{display:inline-flex;align-items:center;justify-content:center;min-width:140px;padding:14px 20px;border-radius:14px;border:none;font-size:14px;font-weight:700;cursor:pointer;transition:transform .15s,box-shadow .15s}.btn:hover{transform:translateY(-1px)}.btn-save{background:linear-gradient(135deg,#22c55e,#16a34a);color:#fff;box-shadow:0 10px 20px rgba(34,197,94,.24)}.btn-reset{background:#fff;border:1px solid #cbd5e1;color:#334155;box-shadow:0 8px 18px rgba(148,163,184,.16)}
    @media (max-width:1100px){.hero,.layout{grid-template-columns:1fr}.side{position:static}} @media (max-width:768px){.fs{padding:16px}.hero{padding:20px}.hero h2{font-size:26px}.grid2{grid-template-columns:1fr}.btns{flex-direction:column}.btn{width:100%}.switch{flex-direction:column;align-items:flex-start}}
</style>
<div class="fs">
    <div class="hero">
        <div>
            <span class="tag">Footer Control Center</span>
            <h2>底部设置</h2>
            <p>统一管理站点底部的描述文案、版权信息、社交链接和栏目链接。现在这个页面改成了更适合后台持续维护的结构，字段更清楚，操作也更集中。</p>
        </div>
        <div class="tips">
            <h4>维护建议</h4>
            <div><b>01</b><span>先决定底部是否启用，再整理描述、版权和备案信息。</span></div>
            <div><b>02</b><span>链接统一使用 “地址|标题” 格式，避免前台解析异常。</span></div>
            <div><b>03</b><span>社交图标不需要展示时，留空或填写 `#` 即可。</span></div>
        </div>
    </div>

    <asp:Label ID="LabelMsg" runat="server"></asp:Label>

    <div class="layout">
        <div class="main">
            <div class="card">
                <div class="head">
                    <span class="ico blue"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg></span>
                    <div><h3>显示控制</h3><p>先决定站点底部是否对前台开放，再继续调整下面的内容配置。</p></div>
                </div>
                <div class="body">
                    <div class="switch">
                        <div>
                            <strong>显示网站底部</strong>
                            <span class="txt">开启后，学生端页面底部正常显示；关闭后，底部区域整体隐藏。</span>
                        </div>
                        <span class="swrap">
                            <asp:CheckBox ID="ChkFooterEnabled" runat="server" />
                            <span class="track" id="ftrSwitchVis"></span>
                        </span>
                    </div>
                    <div class="mini">建议在底部内容尚未确认时先关闭，等链接和文案都检查完成后再启用。</div>
                </div>
            </div>

            <div class="card">
                <div class="head">
                    <span class="ico green"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M12 16v-4"></path><path d="M12 8h.01"></path></svg></span>
                    <div><h3>基本信息</h3><p>这些字段决定底部最核心的品牌信息和备案信息。</p></div>
                </div>
                <div class="body">
                    <div class="field">
                        <label>网站描述</label>
                        <asp:TextBox ID="TxtDescription" runat="server" TextMode="MultiLine" placeholder="专业在线学习平台，致力于为学生和教师提供优质的教学体验和学习资源。"></asp:TextBox>
                        <div class="mini">显示在底部 Logo 附近，建议控制在 50 字以内。</div>
                    </div>
                    <div class="field">
                        <label>版权信息 <span class="hint">{year} 表示当前年份</span></label>
                        <asp:TextBox ID="TxtCopyright" runat="server" placeholder="© {year} LearnSite. All rights reserved"></asp:TextBox>
                    </div>
                    <div class="grid2">
                        <div class="field">
                            <label>ICP备案号</label>
                            <asp:TextBox ID="TxtIcp" runat="server" placeholder="京ICP备12345678号"></asp:TextBox>
                        </div>
                        <div class="field">
                            <label>ICP备案链接</label>
                            <asp:TextBox ID="TxtIcpUrl" runat="server" placeholder="https://beian.miit.gov.cn/"></asp:TextBox>
                        </div>
                    </div>
                    <div class="check">
                        <asp:CheckBox ID="ChkShowPoweredBy" runat="server" />
                        <div><strong>显示 “Powered by LearnSite” 标识</strong><span>如果你希望底部只呈现学校或平台品牌，可以关闭这一项。</span></div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="head">
                    <span class="ico amber"><svg viewBox="0 0 24 24"><path d="M17 2H7a5 5 0 0 0-5 5v10a5 5 0 0 0 5 5h10a5 5 0 0 0 5-5V7a5 5 0 0 0-5-5z"></path><circle cx="12" cy="12" r="4"></circle></svg></span>
                    <div><h3>社交媒体链接</h3><p>用于展示 GitHub、Twitter、Email 和 RSS 等外部入口。</p></div>
                </div>
                <div class="body">
                    <div class="grid2">
                        <div class="field"><label>GitHub</label><asp:TextBox ID="TxtGithub" runat="server" placeholder="https://github.com/yourname"></asp:TextBox></div>
                        <div class="field"><label>Twitter</label><asp:TextBox ID="TxtTwitter" runat="server" placeholder="https://twitter.com/yourname"></asp:TextBox></div>
                        <div class="field"><label>Email</label><asp:TextBox ID="TxtEmail" runat="server" placeholder="mailto:contact@example.com"></asp:TextBox></div>
                        <div class="field"><label>RSS</label><asp:TextBox ID="TxtRss" runat="server" placeholder="/rss.xml"></asp:TextBox></div>
                    </div>
                    <div class="mini">留空或填写 `#` 表示不显示对应图标。</div>
                </div>
            </div>

            <div class="card">
                <div class="head">
                    <span class="ico violet"><svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg></span>
                    <div><h3>产品链接</h3><p>适合放课程入口、作业系统、资源中心等核心功能导航。</p></div>
                </div>
                <div class="body">
                    <div class="note">格式统一使用 <code>链接地址|显示文字</code>，例如 <code>../default.aspx|在线课程</code>。</div>
                    <div class="grid2">
                        <div class="field"><label>产品链接 1</label><asp:TextBox ID="TxtProduct1" runat="server" placeholder="../default.aspx|在线课程"></asp:TextBox></div>
                        <div class="field"><label>产品链接 2</label><asp:TextBox ID="TxtProduct2" runat="server" placeholder="../student/mywork.aspx|作业系统"></asp:TextBox></div>
                        <div class="field"><label>产品链接 3</label><asp:TextBox ID="TxtProduct3" runat="server" placeholder="../student/myquiz.aspx|考试测评"></asp:TextBox></div>
                        <div class="field"><label>产品链接 4</label><asp:TextBox ID="TxtProduct4" runat="server" placeholder="../student/myfile.aspx|学习资源"></asp:TextBox></div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="head">
                    <span class="ico rose"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg></span>
                    <div><h3>支持链接</h3><p>通常放帮助中心、文档、FAQ、联系方式等服务型入口。</p></div>
                </div>
                <div class="body">
                    <div class="note">格式统一使用 <code>链接地址|显示文字</code>，例如 <code>../help/index.aspx|帮助中心</code>。</div>
                    <div class="grid2">
                        <div class="field"><label>支持链接 1</label><asp:TextBox ID="TxtSupport1" runat="server" placeholder="../help/index.aspx|帮助中心"></asp:TextBox></div>
                        <div class="field"><label>支持链接 2</label><asp:TextBox ID="TxtSupport2" runat="server" placeholder="../help/docs.aspx|使用文档"></asp:TextBox></div>
                        <div class="field"><label>支持链接 3</label><asp:TextBox ID="TxtSupport3" runat="server" placeholder="../help/faq.aspx|常见问题"></asp:TextBox></div>
                        <div class="field"><label>支持链接 4</label><asp:TextBox ID="TxtSupport4" runat="server" placeholder="../help/contact.aspx|联系我们"></asp:TextBox></div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="head">
                    <span class="ico blue"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg></span>
                    <div><h3>关于链接</h3><p>适合放关于我们、隐私政策、服务条款等品牌与合规信息。</p></div>
                </div>
                <div class="body">
                    <div class="note">格式统一使用 <code>链接地址|显示文字</code>，例如 <code>../about/index.aspx|关于我们</code>。</div>
                    <div class="grid2">
                        <div class="field"><label>关于链接 1</label><asp:TextBox ID="TxtAbout1" runat="server" placeholder="../about/index.aspx|关于我们"></asp:TextBox></div>
                        <div class="field"><label>关于链接 2</label><asp:TextBox ID="TxtAbout2" runat="server" placeholder="../about/join.aspx|加入我们"></asp:TextBox></div>
                        <div class="field"><label>关于链接 3</label><asp:TextBox ID="TxtAbout3" runat="server" placeholder="../about/privacy.aspx|隐私政策"></asp:TextBox></div>
                        <div class="field"><label>关于链接 4</label><asp:TextBox ID="TxtAbout4" runat="server" placeholder="../about/terms.aspx|服务条款"></asp:TextBox></div>
                    </div>
                </div>
            </div>

            <div class="actions">
                <h4>保存与重置</h4>
                <p>保存会写入 `/App_Data/footersetting.xml`。如果当前配置需要回到默认模板，可以先恢复默认，再点击保存正式生效。</p>
                <div class="btns">
                    <asp:Button ID="BtnSave" runat="server" Text="保存设置" CssClass="btn btn-save" OnClick="BtnSave_Click" />
                    <asp:Button ID="BtnReset" runat="server" Text="恢复默认" CssClass="btn btn-reset" OnClick="BtnReset_Click" />
                </div>
            </div>
        </div>

        <div class="side">
            <div class="panel">
                <h4>填写规则</h4>
                <div><b>1</b><span>链接项统一使用 `地址|标题`，不要只填标题。</span></div>
                <div><b>2</b><span>不需要显示的链接可以直接留空。</span></div>
                <div><b>3</b><span>版权文案建议保留 `{year}`，避免每年手工修改。</span></div>
            </div>
            <div class="panel">
                <h4>发布前检查</h4>
                <div><b>A</b><span>确认备案号与备案链接对应正确。</span></div>
                <div><b>B</b><span>确认外部链接能正常打开，避免 404。</span></div>
                <div><b>C</b><span>确认前台底部在移动端没有过长文案。</span></div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    window.onload = function () {
        var msg = document.getElementById('<%= LabelMsg.ClientID %>');
        if (msg && msg.innerText) setTimeout(function () { msg.style.display = 'none'; }, 5000);
        var ftrChk = document.getElementById('<%= ChkFooterEnabled.ClientID %>');
        if (ftrChk && ftrChk.tagName !== 'INPUT') ftrChk = ftrChk.querySelector('input[type="checkbox"]');
        var ftrVis = document.getElementById('ftrSwitchVis');
        if (ftrChk && ftrVis) {
            ftrVis.classList.toggle('on', ftrChk.checked);
            ftrVis.addEventListener('click', function () {
                ftrChk.checked = !ftrChk.checked;
                ftrVis.classList.toggle('on', ftrChk.checked);
            });
        }
    };
</script>
</asp:Content>
