<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    private string xmlPath;

    protected void Page_Load(object sender, EventArgs e)
    {
        xmlPath = Server.MapPath("~/App_Data/helpcenter.xml");
        if (!IsPostBack)
        {
            LoadSettings();
        }
    }

    private void LoadSettings()
    {
        try
        {
            if (File.Exists(xmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(xmlPath);
                XmlNode helpNode = doc.SelectSingleNode("//helpHtml");
                if (helpNode != null) TextBoxHelp.Text = helpNode.InnerText;
                XmlNode linksNode = doc.SelectSingleNode("//linksHtml");
                if (linksNode != null) TextBoxLinks.Text = linksNode.InnerText;
                return;
            }
        }
        catch { }
        // Defaults - match the original helper.aspx content
        TextBoxHelp.Text = "1、安装和使用请先仔细阅读说明必读目录中的相关资料\n" +
            "2、LearnSite学习平台 QQ羧5847120\n" +
            "3、Learnsite帮助网站：<a href=\"http://www.openlearnsite.com\" target=\"_blank\">www.openlearnsite.com</a>（上海 倪老师）";
        TextBoxLinks.Text = "ITtools3信息技术教学辅助平台（温岭 陈老师）：QQ群号 176809529";
    }

    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string dir = Path.GetDirectoryName(xmlPath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            XmlDocument doc = new XmlDocument();
            doc.AppendChild(doc.CreateXmlDeclaration("1.0", "utf-8", null));
            XmlElement root = doc.CreateElement("helpcenter");
            doc.AppendChild(root);

            XmlElement helpEl = doc.CreateElement("helpHtml");
            helpEl.AppendChild(doc.CreateCDataSection(TextBoxHelp.Text.Trim()));
            root.AppendChild(helpEl);

            XmlElement linksEl = doc.CreateElement("linksHtml");
            linksEl.AppendChild(doc.CreateCDataSection(TextBoxLinks.Text.Trim()));
            root.AppendChild(linksEl);

            doc.Save(xmlPath);

            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "&#10004; 帮助中心内容已保存";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "保存失败: " + ex.Message;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .hs-page { max-width:100%; padding:28px 32px 40px; font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .hs-hd { display:flex; align-items:center; gap:16px; margin-bottom:28px; }
    .hs-hd-icon { width:48px; height:48px; background:linear-gradient(135deg,#6366f1,#818cf8); border-radius:14px; display:flex; align-items:center; justify-content:center; box-shadow:0 4px 12px rgba(99,102,241,.25); flex-shrink:0; }
    .hs-hd-icon svg { width:26px; height:26px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .hs-hd h1 { font-size:22px; font-weight:700; color:#0f172a; margin:0 0 2px; }
    .hs-hd p { font-size:13px; color:#94a3b8; margin:0; }

    .hs-grid { display:grid; grid-template-columns:1fr 320px; gap:20px; }
    @media (max-width:960px) { .hs-grid { grid-template-columns:1fr; } }

    .hs-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:20px; }
    .hs-card:hover { box-shadow:0 8px 24px rgba(0,0,0,.07); }
    .hs-card-hd { padding:16px 22px; font-size:15px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:12px; }
    .hs-card-hd .ci { width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
    .hs-card-hd .ci svg { width:19px; height:19px; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; fill:none; }
    .ci.indigo { background:#eef2ff; } .ci.indigo svg { stroke:#6366f1; }
    .ci.sky { background:#f0f9ff; } .ci.sky svg { stroke:#0ea5e9; }
    .ci.emerald { background:#ecfdf5; } .ci.emerald svg { stroke:#10b981; }
    .hs-card-bd { padding:22px; }

    .hs-card textarea {
        width:100%; min-height:180px; padding:16px; border:1.5px solid #e2e8f0; border-radius:12px;
        font-size:13.5px; font-family:'Microsoft YaHei',sans-serif; line-height:2; color:#334155;
        background:#f8fafc; outline:none; resize:vertical;
        transition: border-color .2s, box-shadow .2s;
    }
    .hs-card textarea:focus { border-color:#6366f1; box-shadow:0 0 0 3px rgba(99,102,241,.08); background:#fff; }

    .hs-hint { font-size:12px; color:#94a3b8; margin-top:10px; line-height:1.8; }
    .hs-hint code { background:#f1f5f9; padding:1px 6px; border-radius:4px; font-size:11.5px; color:#64748b; }

    .hs-actions { padding:16px 22px; border-top:1px solid #f1f5f9; display:flex; align-items:center; gap:14px; }
    .btn-save {
        display:inline-flex; align-items:center; justify-content:center; gap:6px;
        height:40px; padding:0 28px;
        background:linear-gradient(135deg,#6366f1,#4f46e5); color:#fff!important;
        border:none; border-radius:10px; font-size:14px; font-family:inherit; font-weight:600;
        cursor:pointer; transition:all .2s; box-shadow:0 2px 8px rgba(99,102,241,.3);
    }
    .btn-save:hover { box-shadow:0 4px 16px rgba(99,102,241,.4); transform:translateY(-1px); }
    .hs-msg { font-size:13px; }

    /* Side */
    .hs-side-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:16px; }
    .hs-side-hd { padding:14px 18px; font-size:14px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:10px; }
    .hs-side-bd { padding:16px 18px; font-size:13px; color:#64748b; line-height:2; }
    .hs-side-bd li { margin-bottom:4px; }

    .hs-tip-card { background:linear-gradient(135deg,#eef2ff,#e0e7ff); border:1px solid #c7d2fe; border-radius:14px; padding:18px; margin-bottom:16px; }
    .hs-tip-card h4 { font-size:14px; color:#3730a3; margin:0 0 8px; display:flex; align-items:center; gap:8px; }
    .hs-tip-card p { font-size:12.5px; color:#4338ca; line-height:1.8; margin:0; opacity:.85; }

    /* Preview card */
    .hs-pv-card { background:#fff; border-radius:12px; border:1px solid #e8ecf1; box-shadow:0 1px 3px rgba(0,0,0,.04); overflow:hidden; margin-bottom:12px; }
    .hs-pv-hd { padding:10px 16px; background:#fafbfc; border-bottom:1px solid #f1f5f9; font-size:13px; font-weight:600; color:#334155; display:flex; align-items:center; gap:6px; }
    .hs-pv-hd svg { width:14px; height:14px; stroke:#6366f1; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .hs-pv-bd { padding:12px 16px; font-size:13px; color:#475569; line-height:2; }
    .hs-pv-bd a { color:#6366f1; text-decoration:none; }
</style>

<div class="hs-page">
    <div class="hs-hd">
        <div class="hs-hd-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
        <div><h1>教师端帮助中心设置</h1><p>编辑教师端「帮助与资源」页面中的帮助说明和友情链接内容</p></div>
    </div>

    <div class="hs-grid">
        <div>
            <!-- 帮助说明 -->
            <div class="hs-card">
                <div class="hs-card-hd">
                    <span class="ci indigo"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
                    帮助说明内容
                </div>
                <div class="hs-card-bd">
                    <asp:TextBox ID="TextBoxHelp" runat="server" TextMode="MultiLine" Rows="8" />
                    <div class="hs-hint">
                        支持 HTML 格式，如 <code>&lt;a href="..." target="_blank"&gt;链接文字&lt;/a&gt;</code><br/>
                        换行使用 <code>&lt;br /&gt;</code> 标签，内容将直接显示在教师端帮助页面的「帮助说明」卡片中
                    </div>
                    
                    <!-- 固定信息区域 -->
                    <div style="margin-top:20px;padding:16px 18px;background:linear-gradient(135deg,#eef2ff,#e0e7ff);border:1px solid #c7d2fe;border-radius:10px;">
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#4f46e5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                            <strong style="color:#4338ca;font-size:14px;">系统信息</strong>
                        </div>
                        <div style="font-size:13px;color:#4338ca;line-height:1.8;">
                            <strong>LearnSite 重庆美化版</strong><br/>
                            技术交流 QQ 群：<strong>565444740</strong>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 友情链接 -->
            <div class="hs-card">
                <div class="hs-card-hd">
                    <span class="ci sky"><svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg></span>
                    友情链接内容
                </div>
                <div class="hs-card-bd">
                    <asp:TextBox ID="TextBoxLinks" runat="server" TextMode="MultiLine" Rows="6" />
                    <div class="hs-hint">
                        支持 HTML 格式，内容将显示在教师端帮助页面的「友情链接」卡片中<br/>
                        可包含多行内容、链接等
                    </div>
                </div>
                <div class="hs-actions">
                    <asp:Button ID="BtnSave" runat="server" Text="保存内容" CssClass="btn-save" OnClick="BtnSave_Click" />
                    <span class="hs-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></span>
                </div>
            </div>
        </div>

        <!-- 右侧 -->
        <div>
            <div class="hs-tip-card">
                <h4>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3730a3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    功能说明
                </h4>
                <p>此处编辑的内容将集中保存在服务端，所有教师登录后在「帮助与资源」页面看到的内容统一由此管理，无需每位教师单独编辑。</p>
            </div>

            <!-- 预览 -->
            <div class="hs-side-card">
                <div class="hs-side-hd">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#475569" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    教师端预览
                </div>
                <div style="padding:12px 18px;">
                    <div class="hs-pv-card">
                        <div class="hs-pv-hd">
                            <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                            帮助说明
                        </div>
                        <div class="hs-pv-bd" id="pvHelp"></div>
                    </div>
                    <div class="hs-pv-card">
                        <div class="hs-pv-hd">
                            <svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                            友情链接
                        </div>
                        <div class="hs-pv-bd" id="pvLinks"></div>
                    </div>
                </div>
            </div>

            <div class="hs-side-card">
                <div class="hs-side-hd">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    编辑说明
                </div>
                <div class="hs-side-bd">
                    <ul style="padding-left:16px;">
                        <li>内容支持 <strong>HTML</strong> 标签</li>
                        <li>换行用 <code style="background:#f1f5f9;padding:1px 5px;border-radius:3px;font-size:12px;">&lt;br/&gt;</code></li>
                        <li>链接用 <code style="background:#f1f5f9;padding:1px 5px;border-radius:3px;font-size:12px;">&lt;a href="..."&gt;</code></li>
                        <li>保存后教师端即时生效</li>
                        <li>「内置工具」卡片由系统维护，无需编辑</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function updatePreview() {
        var helpEl = document.getElementById('<%= TextBoxHelp.ClientID %>');
        var linksEl = document.getElementById('<%= TextBoxLinks.ClientID %>');
        var pvHelp = document.getElementById('pvHelp');
        var pvLinks = document.getElementById('pvLinks');
        if (helpEl && pvHelp) pvHelp.innerHTML = helpEl.value.replace(/\n/g, '<br/>');
        if (linksEl && pvLinks) pvLinks.innerHTML = linksEl.value.replace(/\n/g, '<br/>');
    }
    (function() {
        updatePreview();
        var h = document.getElementById('<%= TextBoxHelp.ClientID %>');
        var l = document.getElementById('<%= TextBoxLinks.ClientID %>');
        if (h) h.addEventListener('input', updatePreview);
        if (l) l.addEventListener('input', updatePreview);
    })();
</script>
</asp:Content>
