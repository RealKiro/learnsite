<%@ Page Title="" Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<script runat="server">
    // ========== Data Model ==========
    protected class NavItem
    {
        public string Icon;
        public string Text;
        public string Url;
        public NavItem() { Icon = ""; Text = ""; Url = ""; }
        public NavItem(string icon, string text, string url) { Icon = icon; Text = text; Url = url; }
    }

    protected System.Collections.Generic.List<NavItem> studentNavItems = new System.Collections.Generic.List<NavItem>();
    protected System.Collections.Generic.List<NavItem> profileSideNavItems = new System.Collections.Generic.List<NavItem>();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSettings();
        }
        else
        {
            // On postback, reload from XML to reflect current state
            LoadFromXml();
        }
    }

    // ========== Default Values ==========
    private System.Collections.Generic.List<NavItem> GetDefaultStudentNav()
    {
        System.Collections.Generic.List<NavItem> list = new System.Collections.Generic.List<NavItem>();
        list.Add(new NavItem("", "我的学案", "../student/myinfo.aspx"));
        list.Add(new NavItem("", "我的作品", "../student/mywork.aspx"));
        list.Add(new NavItem("", "打字宝典", "../student/myfinger.aspx"));
        list.Add(new NavItem("", "常识积累", "../student/myquiz.aspx"));
        list.Add(new NavItem("", "在线资源", "../student/myfile.aspx"));
        list.Add(new NavItem("", "我的网盘", "../student/groupshare.aspx"));
        list.Add(new NavItem("", "优秀作品", "../student/excellentwork.aspx"));
        return list;
    }

    private System.Collections.Generic.List<NavItem> GetDefaultProfileSideNav()
    {
        System.Collections.Generic.List<NavItem> list = new System.Collections.Generic.List<NavItem>();
        list.Add(new NavItem("", "小组", "../profile/mygroup.aspx"));
        list.Add(new NavItem("", "签到", "../profile/mysign.aspx"));
        list.Add(new NavItem("", "密码", "../profile/mypwd.aspx"));
        list.Add(new NavItem("", "班级", "../profile/myclass.aspx"));
        list.Add(new NavItem("", "相片", "../profile/myphoto.aspx"));
        list.Add(new NavItem("", "性别", "../profile/mysex.aspx"));
        list.Add(new NavItem("", "小组等级", "../profile/grouplevel.aspx"));
        list.Add(new NavItem("", "学分等级", "../profile/creditlevel.aspx"));
        return list;
    }

    // ========== Load / Save ==========
    private string GetXmlPath()
    {
        return Server.MapPath("~/App_Data/navsetting.xml");
    }

    private void LoadSettings()
    {
        LoadFromXml();
        if (studentNavItems.Count == 0)
            studentNavItems = GetDefaultStudentNav();
        if (profileSideNavItems.Count == 0)
            profileSideNavItems = GetDefaultProfileSideNav();
    }

    private void LoadFromXml()
    {
        studentNavItems.Clear();
        profileSideNavItems.Clear();
        try
        {
            string xmlPath = GetXmlPath();
            if (!System.IO.File.Exists(xmlPath)) return;
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            LoadNavGroup(doc, "studentNav", studentNavItems);
            LoadNavGroup(doc, "profileSideNav", profileSideNavItems);
        }
        catch { }
    }

    private void LoadNavGroup(System.Xml.XmlDocument doc, string groupName, System.Collections.Generic.List<NavItem> list)
    {
        System.Xml.XmlNodeList items = doc.SelectNodes("//" + groupName + "/item");
        if (items == null) return;
        foreach (System.Xml.XmlNode node in items)
        {
            NavItem item = new NavItem();
            System.Xml.XmlNode iconNode = node.SelectSingleNode("icon");
            System.Xml.XmlNode textNode = node.SelectSingleNode("text");
            System.Xml.XmlNode urlNode = node.SelectSingleNode("url");
            if (iconNode != null) item.Icon = iconNode.InnerText;
            if (textNode != null) item.Text = textNode.InnerText;
            if (urlNode != null) item.Url = urlNode.InnerText;
            list.Add(item);
        }
    }

    private void SaveToXml(System.Collections.Generic.List<NavItem> stuItems, System.Collections.Generic.List<NavItem> pfItems)
    {
        string xmlPath = GetXmlPath();
        string dirPath = Server.MapPath("~/App_Data");
        if (!System.IO.Directory.Exists(dirPath))
            System.IO.Directory.CreateDirectory(dirPath);

        System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
        System.Xml.XmlDeclaration decl = doc.CreateXmlDeclaration("1.0", "UTF-8", null);
        doc.AppendChild(decl);

        System.Xml.XmlElement root = doc.CreateElement("navSettings");
        doc.AppendChild(root);

        SaveNavGroup(doc, root, "studentNav", stuItems);
        SaveNavGroup(doc, root, "profileSideNav", pfItems);

        doc.Save(xmlPath);
    }

    private void SaveNavGroup(System.Xml.XmlDocument doc, System.Xml.XmlElement root, string groupName, System.Collections.Generic.List<NavItem> items)
    {
        System.Xml.XmlElement group = doc.CreateElement(groupName);
        root.AppendChild(group);
        foreach (NavItem ni in items)
        {
            System.Xml.XmlElement itemEl = doc.CreateElement("item");
            System.Xml.XmlElement iconEl = doc.CreateElement("icon");
            iconEl.InnerText = ni.Icon;
            itemEl.AppendChild(iconEl);
            System.Xml.XmlElement textEl = doc.CreateElement("text");
            textEl.InnerText = ni.Text;
            itemEl.AppendChild(textEl);
            System.Xml.XmlElement urlEl = doc.CreateElement("url");
            urlEl.InnerText = ni.Url;
            itemEl.AppendChild(urlEl);
            group.AppendChild(itemEl);
        }
    }

    // ========== Parse Form Data ==========
    private System.Collections.Generic.List<NavItem> ParseFormItems(string prefix)
    {
        System.Collections.Generic.List<NavItem> list = new System.Collections.Generic.List<NavItem>();
        int i = 0;
        while (true)
        {
            string textKey = prefix + "_text_" + i;
            string urlKey = prefix + "_url_" + i;
            string iconKey = prefix + "_icon_" + i;
            string textVal = Request.Form[textKey];
            if (textVal == null) break;
            NavItem item = new NavItem();
            item.Text = textVal.Trim();
            item.Url = (Request.Form[urlKey] ?? "").Trim();
            item.Icon = (Request.Form[iconKey] ?? "").Trim();
            if (!string.IsNullOrEmpty(item.Text) || !string.IsNullOrEmpty(item.Url))
                list.Add(item);
            i++;
        }
        return list;
    }

    // ========== Event Handlers ==========
    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            System.Collections.Generic.List<NavItem> stuItems = ParseFormItems("stu");
            System.Collections.Generic.List<NavItem> pfItems = ParseFormItems("pf");
            SaveToXml(stuItems, pfItems);
            studentNavItems = stuItems;
            profileSideNavItems = pfItems;
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "✓ 导航设置已保存成功";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "保存失败: " + Server.HtmlEncode(ex.Message);
        }
    }

    protected void BtnReset_Click(object sender, EventArgs e)
    {
        try
        {
            System.Collections.Generic.List<NavItem> stuItems = GetDefaultStudentNav();
            System.Collections.Generic.List<NavItem> pfItems = GetDefaultProfileSideNav();
            SaveToXml(stuItems, pfItems);
            studentNavItems = stuItems;
            profileSideNavItems = pfItems;
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "✓ 已恢复默认导航并保存";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "恢复失败: " + Server.HtmlEncode(ex.Message);
        }
    }
</script>

<style>
    .ns-page { max-width: 1600px; margin: 0 auto; padding: 8px 8px 40px; font-family: 'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .ns-hd { display: flex; align-items: center; gap: 16px; margin-bottom: 28px; }
    .ns-hd-icon { width: 48px; height: 48px; background: linear-gradient(135deg,#6366f1,#a78bfa); border-radius: 14px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(99,102,241,.25); flex-shrink: 0; }
    .ns-hd-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .ns-hd h1 { font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 2px; }
    .ns-hd p { font-size: 13px; color: #94a3b8; margin: 0; }

    /* Actions bar */
    .ns-actions { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; }
    .ns-btn-save { display: inline-flex; align-items: center; gap: 6px; height: 40px; padding: 0 28px; background: linear-gradient(135deg,#6366f1,#4f46e5); color: #fff; border: none; border-radius: 10px; font-size: 14px; font-family: inherit; font-weight: 600; cursor: pointer; transition: all .2s; box-shadow: 0 2px 8px rgba(99,102,241,.3); }
    .ns-btn-save:hover { box-shadow: 0 4px 14px rgba(99,102,241,.4); transform: translateY(-1px); }
    .ns-btn-reset { height: 40px; padding: 0 24px; background: #fff; color: #64748b; border: 1.5px solid #e2e8f0; border-radius: 10px; font-size: 14px; font-family: inherit; font-weight: 500; cursor: pointer; transition: all .2s; }
    .ns-btn-reset:hover { background: #f8fafc; border-color: #cbd5e1; }
    .ns-msg { font-size: 13px; margin-left: 8px; }

    /* Section card */
    .ns-section { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 1px 4px rgba(0,0,0,.04); margin-bottom: 28px; overflow: hidden; }
    .ns-section-hd { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 12px; }
    .ns-section-hd .ns-sec-icon { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .ns-section-hd .ns-sec-icon svg { width: 20px; height: 20px; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; fill: none; }
    .ns-sec-icon.indigo { background: #eef2ff; }
    .ns-sec-icon.indigo svg { stroke: #6366f1; }
    .ns-sec-icon.emerald { background: #ecfdf5; }
    .ns-sec-icon.emerald svg { stroke: #10b981; }
    .ns-section-hd h2 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; }
    .ns-section-hd .ns-sec-desc { font-size: 12px; color: #94a3b8; margin-left: auto; }
    .ns-section-bd { padding: 20px 24px; }

    /* Nav item editor */
    .ns-item { display: flex; align-items: flex-start; gap: 12px; padding: 14px 16px; margin-bottom: 10px; background: #f8fafc; border: 1px solid #f1f5f9; border-radius: 12px; transition: all .15s; position: relative; }
    .ns-item:hover { border-color: #c7d2fe; background: #fafafe; }
    .ns-item-num { width: 28px; height: 28px; border-radius: 8px; background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 4px; }
    .ns-item-fields { flex: 1; display: flex; flex-direction: column; gap: 8px; min-width: 0; }
    .ns-item-row { display: flex; gap: 10px; flex-wrap: wrap; }
    .ns-field { display: flex; flex-direction: column; gap: 3px; }
    .ns-field label { font-size: 11px; font-weight: 600; color: #6366f1; }
    .ns-field input[type="text"], .ns-field textarea { padding: 7px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 13px; font-family: inherit; outline: none; transition: border-color .2s, box-shadow .2s; background: #fff; }
    .ns-field input[type="text"]:focus, .ns-field textarea:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .ns-field-text { width: 140px; }
    .ns-field-url { width: 260px; }
    .ns-field-icon { flex: 1; min-width: 200px; }

    /* Icon preview */
    .ns-icon-preview { width: 40px; height: 40px; border-radius: 8px; background: #eef2ff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 4px; overflow: hidden; }
    .ns-icon-preview img { width: 28px; height: 28px; object-fit: contain; }
    .ns-icon-preview svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .ns-icon-preview .ns-icon-placeholder { width: 20px; height: 20px; stroke: #c7d2fe; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }

    /* Upload button */
    .ns-upload-btn { display: inline-flex; align-items: center; gap: 6px; height: 34px; padding: 0 14px; background: #eef2ff; color: #6366f1; border: 1.5px solid #c7d2fe; border-radius: 8px; font-size: 12px; font-family: inherit; font-weight: 600; cursor: pointer; transition: all .2s; }
    .ns-upload-btn:hover { background: #e0e7ff; border-color: #818cf8; }
    .ns-upload-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ns-upload-btn input[type="file"] { display: none; }
    .ns-icon-url-text { font-size: 11px; color: #94a3b8; margin-left: 8px; max-width: 260px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: inline-block; vertical-align: middle; }

    /* Delete button */
    .ns-item-del { width: 28px; height: 28px; border-radius: 7px; background: #fff1f2; border: 1px solid #fecdd3; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all .15s; flex-shrink: 0; margin-top: 4px; opacity: 0; }
    .ns-item:hover .ns-item-del { opacity: 1; }
    .ns-item-del:hover { background: #fee2e2; border-color: #fca5a5; }
    .ns-item-del svg { width: 14px; height: 14px; stroke: #ef4444; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* Add button */
    .ns-add-btn { display: inline-flex; align-items: center; gap: 6px; height: 36px; padding: 0 18px; background: #fff; color: #6366f1; border: 1.5px dashed #c7d2fe; border-radius: 9px; font-size: 13px; font-family: inherit; font-weight: 600; cursor: pointer; transition: all .2s; margin-top: 6px; }
    .ns-add-btn:hover { background: #eef2ff; border-color: #818cf8; }
    .ns-add-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }

    /* Move buttons */
    .ns-item-move { display: flex; flex-direction: column; gap: 2px; flex-shrink: 0; margin-top: 4px; }
    .ns-move-btn { width: 24px; height: 18px; border-radius: 4px; background: #f1f5f9; border: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all .1s; }
    .ns-move-btn:hover { background: #e2e8f0; border-color: #cbd5e1; }
    .ns-move-btn svg { width: 12px; height: 12px; stroke: #64748b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
</style>

<div class="ns-page">
    <div class="ns-hd">
        <div class="ns-hd-icon"><svg viewBox="0 0 24 24"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/><polyline points="15 3 18 6 15 9"/></svg></div>
        <div><h1>导航设置</h1><p>配置学生平台和个人设置页面的导航菜单</p></div>
    </div>

    <div class="ns-actions">
        <asp:Button ID="BtnSave" runat="server" Text="保存设置" CssClass="ns-btn-save" OnClick="BtnSave_Click" />
        <asp:Button ID="BtnReset" runat="server" Text="恢复默认" CssClass="ns-btn-reset" OnClick="BtnReset_Click" OnClientClick="return confirm('确定要恢复为默认导航配置吗？当前设置将被覆盖。');" />
        <span class="ns-msg"><asp:Label ID="LabelMsg" runat="server" /></span>
    </div>

    <!-- ========== Student Top Nav ========== -->
    <div class="ns-section">
        <div class="ns-section-hd">
            <span class="ns-sec-icon indigo"><svg viewBox="0 0 24 24"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg></span>
            <h2>学生平台顶部导航</h2>
            <span class="ns-sec-desc">适用于学生平台和个人设置页面的顶部导航栏</span>
        </div>
        <div class="ns-section-bd" id="stuNavContainer">
            <% for (int i = 0; i < studentNavItems.Count; i++) { %>
            <div class="ns-item" data-group="stu" data-index="<%= i %>">
                <span class="ns-item-num"><%= i + 1 %></span>
                <div class="ns-icon-preview"><% if (!string.IsNullOrEmpty(studentNavItems[i].Icon)) { %><img src="<%= Server.HtmlEncode(studentNavItems[i].Icon) %>" /><% } else { %><svg class="ns-icon-placeholder" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg><% } %></div>
                <div class="ns-item-fields">
                    <div class="ns-item-row">
                        <div class="ns-field ns-field-text">
                            <label>菜单文字</label>
                            <input type="text" name="stu_text_<%= i %>" value="<%= Server.HtmlEncode(studentNavItems[i].Text) %>" placeholder="如：我的学案" />
                        </div>
                        <div class="ns-field ns-field-url">
                            <label>链接地址</label>
                            <input type="text" name="stu_url_<%= i %>" value="<%= Server.HtmlEncode(studentNavItems[i].Url) %>" placeholder="如：../student/myinfo.aspx" />
                        </div>
                        <div class="ns-field ns-field-icon">
                            <label>菜单图标</label>
                            <input type="hidden" name="stu_icon_<%= i %>" value="<%= Server.HtmlEncode(studentNavItems[i].Icon) %>" />
                            <label class="ns-upload-btn" title="上传图标">
                                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                上传图标
                                <input type="file" accept=".png,.jpg,.jpeg,.gif,.webp,.svg" onchange="uploadIcon(this)" />
                            </label>
                            <span class="ns-icon-url-text"><%= !string.IsNullOrEmpty(studentNavItems[i].Icon) ? Server.HtmlEncode(studentNavItems[i].Icon) : "未设置图标" %></span>
                        </div>
                    </div>
                </div>
                <div class="ns-item-move">
                    <span class="ns-move-btn" onclick="moveItem(this,'up')" title="上移"><svg viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"/></svg></span>
                    <span class="ns-move-btn" onclick="moveItem(this,'down')" title="下移"><svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></span>
                </div>
                <span class="ns-item-del" onclick="removeItem(this)" title="删除"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></span>
            </div>
            <% } %>
            <button type="button" class="ns-add-btn" onclick="addItem('stuNavContainer','stu')">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加导航项
            </button>
        </div>
    </div>

    <!-- ========== Profile Sidebar Nav ========== -->
    <div class="ns-section">
        <div class="ns-section-hd">
            <span class="ns-sec-icon emerald"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            <h2>个人设置侧边栏导航</h2>
            <span class="ns-sec-desc">适用于个人设置页面的左侧边栏菜单</span>
        </div>
        <div class="ns-section-bd" id="pfNavContainer">
            <% for (int i = 0; i < profileSideNavItems.Count; i++) { %>
            <div class="ns-item" data-group="pf" data-index="<%= i %>">
                <span class="ns-item-num"><%= i + 1 %></span>
                <div class="ns-icon-preview"><% if (!string.IsNullOrEmpty(profileSideNavItems[i].Icon)) { %><img src="<%= Server.HtmlEncode(profileSideNavItems[i].Icon) %>" /><% } else { %><svg class="ns-icon-placeholder" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg><% } %></div>
                <div class="ns-item-fields">
                    <div class="ns-item-row">
                        <div class="ns-field ns-field-text">
                            <label>菜单文字</label>
                            <input type="text" name="pf_text_<%= i %>" value="<%= Server.HtmlEncode(profileSideNavItems[i].Text) %>" placeholder="如：小组" />
                        </div>
                        <div class="ns-field ns-field-url">
                            <label>链接地址</label>
                            <input type="text" name="pf_url_<%= i %>" value="<%= Server.HtmlEncode(profileSideNavItems[i].Url) %>" placeholder="如：../profile/mygroup.aspx" />
                        </div>
                        <div class="ns-field ns-field-icon">
                            <label>菜单图标</label>
                            <input type="hidden" name="pf_icon_<%= i %>" value="<%= Server.HtmlEncode(profileSideNavItems[i].Icon) %>" />
                            <label class="ns-upload-btn" title="上传图标">
                                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                上传图标
                                <input type="file" accept=".png,.jpg,.jpeg,.gif,.webp,.svg" onchange="uploadIcon(this)" />
                            </label>
                            <span class="ns-icon-url-text"><%= !string.IsNullOrEmpty(profileSideNavItems[i].Icon) ? Server.HtmlEncode(profileSideNavItems[i].Icon) : "未设置图标" %></span>
                        </div>
                    </div>
                </div>
                <div class="ns-item-move">
                    <span class="ns-move-btn" onclick="moveItem(this,'up')" title="上移"><svg viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"/></svg></span>
                    <span class="ns-move-btn" onclick="moveItem(this,'down')" title="下移"><svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></span>
                </div>
                <span class="ns-item-del" onclick="removeItem(this)" title="删除"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></span>
            </div>
            <% } %>
            <button type="button" class="ns-add-btn" onclick="addItem('pfNavContainer','pf')">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加导航项
            </button>
        </div>
    </div>
</div>

<script type="text/javascript">
    function reindexItems(containerId, prefix) {
        var container = document.getElementById(containerId);
        var items = container.querySelectorAll('.ns-item');
        for (var i = 0; i < items.length; i++) {
            items[i].setAttribute('data-index', i);
            items[i].querySelector('.ns-item-num').textContent = i + 1;
            var textInput = items[i].querySelector('input[name^="' + prefix + '_text_"]');
            var urlInput = items[i].querySelector('input[name^="' + prefix + '_url_"]');
            var iconInput = items[i].querySelector('textarea[name^="' + prefix + '_icon_"]');
            if (textInput) textInput.name = prefix + '_text_' + i;
            if (urlInput) urlInput.name = prefix + '_url_' + i;
            if (iconInput) iconInput.name = prefix + '_icon_' + i;
        }
    }

    function addItem(containerId, prefix) {
        var container = document.getElementById(containerId);
        var items = container.querySelectorAll('.ns-item');
        var idx = items.length;
        var html = '<div class="ns-item" data-group="' + prefix + '" data-index="' + idx + '">'
            + '<span class="ns-item-num">' + (idx + 1) + '</span>'
            + '<div class="ns-icon-preview"><svg class="ns-icon-placeholder" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg></div>'
            + '<div class="ns-item-fields">'
            + '<div class="ns-item-row">'
            + '<div class="ns-field ns-field-text"><label>菜单文字</label><input type="text" name="' + prefix + '_text_' + idx + '" value="" placeholder="菜单名称" /></div>'
            + '<div class="ns-field ns-field-url"><label>链接地址</label><input type="text" name="' + prefix + '_url_' + idx + '" value="" placeholder="链接URL" /></div>'
            + '<div class="ns-field ns-field-icon"><label>菜单图标</label>'
            + '<input type="hidden" name="' + prefix + '_icon_' + idx + '" value="" />'
            + '<label class="ns-upload-btn" title="上传图标">'
            + '<svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>'
            + '上传图标<input type="file" accept=".png,.jpg,.jpeg,.gif,.webp,.svg" onchange="uploadIcon(this)" />'
            + '</label>'
            + '<span class="ns-icon-url-text">未设置图标</span>'
            + '</div>'
            + '</div></div>'
            + '<div class="ns-item-move">'
            + '<span class="ns-move-btn" onclick="moveItem(this,\'up\')" title="上移"><svg viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"/></svg></span>'
            + '<span class="ns-move-btn" onclick="moveItem(this,\'down\')" title="下移"><svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></span>'
            + '</div>'
            + '<span class="ns-item-del" onclick="removeItem(this)" title="删除"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></span>'
            + '</div>';
        var addBtn = container.querySelector('.ns-add-btn');
        var temp = document.createElement('div');
        temp.innerHTML = html;
        container.insertBefore(temp.firstChild, addBtn);
    }

    function removeItem(el) {
        var item = el.closest('.ns-item');
        var container = item.parentElement;
        var prefix = item.getAttribute('data-group');
        item.remove();
        reindexItems(container.id, prefix);
    }

    function moveItem(el, direction) {
        var item = el.closest('.ns-item');
        var container = item.parentElement;
        var prefix = item.getAttribute('data-group');
        if (direction === 'up') {
            var prev = item.previousElementSibling;
            if (prev && prev.classList.contains('ns-item')) {
                container.insertBefore(item, prev);
            }
        } else {
            var next = item.nextElementSibling;
            if (next && next.classList.contains('ns-item')) {
                container.insertBefore(next, item);
            }
        }
        reindexItems(container.id, prefix);
    }

    // Upload icon via AJAX
    function uploadIcon(fileInput) {
        if (!fileInput.files || !fileInput.files[0]) return;
        var file = fileInput.files[0];
        if (file.size > 512 * 1024) {
            alert('图标文件大小不能超过512KB');
            fileInput.value = '';
            return;
        }
        var item = fileInput.closest('.ns-item');
        if (!item) return;
        var formData = new FormData();
        formData.append('file', file);
        var btn = fileInput.closest('.ns-upload-btn');
        var origText = btn.childNodes[btn.childNodes.length - 2];
        btn.style.opacity = '0.6';
        btn.style.pointerEvents = 'none';
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'uploadnavicon.ashx', true);
        xhr.onload = function() {
            btn.style.opacity = '';
            btn.style.pointerEvents = '';
            try {
                var res = JSON.parse(xhr.responseText);
                if (res.success === 1) {
                    var hiddenInput = item.querySelector('input[type="hidden"][name*="_icon_"]');
                    if (hiddenInput) hiddenInput.value = res.url;
                    var preview = item.querySelector('.ns-icon-preview');
                    if (preview) preview.innerHTML = '<img src="' + res.url + '" />';
                    var urlText = item.querySelector('.ns-icon-url-text');
                    if (urlText) urlText.textContent = res.url;
                } else {
                    alert(res.message || '上传失败');
                }
            } catch(ex) {
                alert('上传出错');
            }
            fileInput.value = '';
        };
        xhr.onerror = function() {
            btn.style.opacity = '';
            btn.style.pointerEvents = '';
            alert('网络错误，上传失败');
            fileInput.value = '';
        };
        xhr.send(formData);
    }
</script>
</asp:Content>
