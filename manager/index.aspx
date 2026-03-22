<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    protected class ChangelogEntry
    {
        public string Version;
        public string Tag;
        public string Date;
        public bool IsLatest;
        public System.Collections.Generic.List<ChangelogItem> Items = new System.Collections.Generic.List<ChangelogItem>();
    }

    protected class ChangelogItem
    {
        public string Type; // feat, ui, fix, or empty
        public string Text;
    }

    protected System.Collections.Generic.List<ChangelogEntry> changelogEntries = new System.Collections.Generic.List<ChangelogEntry>();
    private bool _changelogLoaded = false;
    
    // Pagination
    protected int currentPage = 1;
    protected int pageSize = 6;
    protected int totalPages = 1;
    
    protected System.Collections.Generic.List<ChangelogEntry> GetPagedEntries()
    {
        EnsureChangelogLoaded();
        
        // Get current page from query string
        string pageParam = Request.QueryString["page"];
        if (!string.IsNullOrEmpty(pageParam))
        {
            int.TryParse(pageParam, out currentPage);
        }
        if (currentPage < 1) currentPage = 1;
        
        // Calculate total pages
        totalPages = (int)Math.Ceiling((double)changelogEntries.Count / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        
        // Get entries for current page
        int startIndex = (currentPage - 1) * pageSize;
        int count = Math.Min(pageSize, changelogEntries.Count - startIndex);
        
        if (startIndex >= changelogEntries.Count)
            return new System.Collections.Generic.List<ChangelogEntry>();
        
        System.Collections.Generic.List<ChangelogEntry> pagedList = new System.Collections.Generic.List<ChangelogEntry>();
        for (int i = startIndex; i < startIndex + count; i++)
        {
            pagedList.Add(changelogEntries[i]);
        }
        return pagedList;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Auto-fill date for new version form
            TxtNewDate.Text = DateTime.Now.Year + "年" + DateTime.Now.Month + "月" + DateTime.Now.Day + "日";
        }
    }

    protected void EnsureChangelogLoaded()
    {
        if (_changelogLoaded) return;
        _changelogLoaded = true;
        LoadChangelog();
    }

    private void LoadChangelog()
    {
        try
        {
            string xmlPath = Server.MapPath("~/changelog.xml");
            
            // Debug: Check if file exists
            if (!System.IO.File.Exists(xmlPath))
            {
                // File not found - add debug entry
                ChangelogEntry debugEntry = new ChangelogEntry();
                debugEntry.Version = "DEBUG";
                debugEntry.Tag = "fix";
                debugEntry.Date = "文件未找到";
                debugEntry.IsLatest = true;
                ChangelogItem debugItem = new ChangelogItem();
                debugItem.Type = "fix";
                debugItem.Text = "changelog.xml 文件不存在于路径: " + xmlPath;
                debugEntry.Items.Add(debugItem);
                changelogEntries.Add(debugEntry);
                return;
            }

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNodeList versions = doc.SelectNodes("//changelog/version");
            
            // Debug: Check if versions found
            if (versions == null || versions.Count == 0)
            {
                ChangelogEntry debugEntry = new ChangelogEntry();
                debugEntry.Version = "DEBUG";
                debugEntry.Tag = "fix";
                debugEntry.Date = "XML解析问题";
                debugEntry.IsLatest = true;
                ChangelogItem debugItem = new ChangelogItem();
                debugItem.Type = "fix";
                debugItem.Text = "未找到版本节点，请访问 /manager/test_changelog.aspx 诊断";
                debugEntry.Items.Add(debugItem);
                changelogEntries.Add(debugEntry);
                return;
            }

            bool first = true;
            foreach (XmlNode vNode in versions)
            {
                ChangelogEntry entry = new ChangelogEntry();
                entry.Version = vNode.Attributes["ver"] != null ? vNode.Attributes["ver"].Value : "";
                entry.Tag = vNode.Attributes["tag"] != null ? vNode.Attributes["tag"].Value.ToLower() : "";
                entry.Date = vNode.Attributes["date"] != null ? vNode.Attributes["date"].Value : "";
                entry.IsLatest = first;
                first = false;

                foreach (XmlNode iNode in vNode.SelectNodes("item"))
                {
                    ChangelogItem item = new ChangelogItem();
                    item.Type = iNode.Attributes["type"] != null ? iNode.Attributes["type"].Value.ToLower() : "";
                    item.Text = iNode.InnerText;
                    entry.Items.Add(item);
                }

                changelogEntries.Add(entry);
            }
        }
        catch (System.Exception ex)
        {
            // Debug: Show error
            ChangelogEntry debugEntry = new ChangelogEntry();
            debugEntry.Version = "ERROR";
            debugEntry.Tag = "fix";
            debugEntry.Date = "异常";
            debugEntry.IsLatest = true;
            ChangelogItem debugItem = new ChangelogItem();
            debugItem.Type = "fix";
            debugItem.Text = "加载失败: " + ex.Message;
            debugEntry.Items.Add(debugItem);
            changelogEntries.Add(debugEntry);
        }
    }

    protected string GetTagCss(string tag)
    {
        switch (tag)
        {
            case "new": return "new";
            case "improve": return "improve";
            case "fix": return "fix";
            case "stable": return "fix";
            default: return "improve";
        }
    }

    protected string GetTagLabel(string tag)
    {
        switch (tag)
        {
            case "new": return "NEW";
            case "improve": return "IMPROVE";
            case "fix": return "FIX";
            case "stable": return "STABLE";
            default: return tag.ToUpper();
        }
    }

    protected void BtnAddVersion_Click(object sender, EventArgs e)
    {
        HiddenFormOpen.Value = "1";
        try
        {
            string ver = TxtNewVer.Text.Trim();
            string tag = DdlNewTag.SelectedValue;
            string date = TxtNewDate.Text.Trim();
            string itemsRaw = TxtNewItems.Text.Trim();

            if (string.IsNullOrEmpty(ver) || string.IsNullOrEmpty(itemsRaw))
            {
                LabelClMsg.ForeColor = System.Drawing.Color.Red;
                LabelClMsg.Text = "\u8bf7\u586b\u5199\u7248\u672c\u53f7\u548c\u66f4\u65b0\u5185\u5bb9";
                return;
            }

            string xmlPath = Server.MapPath("~/changelog.xml");
            XmlDocument doc = new XmlDocument();

            if (System.IO.File.Exists(xmlPath))
            {
                doc.Load(xmlPath);
            }
            else
            {
                doc.AppendChild(doc.CreateXmlDeclaration("1.0", "utf-8", null));
                doc.AppendChild(doc.CreateElement("changelog"));
            }

            XmlNode root = doc.SelectSingleNode("//changelog");
            if (root == null)
            {
                root = doc.CreateElement("changelog");
                doc.AppendChild(root);
            }

            XmlElement versionEl = doc.CreateElement("version");
            versionEl.SetAttribute("ver", ver);
            versionEl.SetAttribute("tag", tag);
            versionEl.SetAttribute("date", date);

            string[] lines = itemsRaw.Split(new char[] { '\r', '\n' }, System.StringSplitOptions.RemoveEmptyEntries);
            foreach (string line in lines)
            {
                string trimmed = line.Trim();
                if (trimmed.Length == 0) continue;

                XmlElement itemEl = doc.CreateElement("item");
                string itemType = "";
                string itemText = trimmed;

                // Parse type prefix: [feat] or [ui] or [fix]
                if (trimmed.StartsWith("[feat]") || trimmed.StartsWith("[\u529f\u80fd]"))
                {
                    itemType = "feat";
                    itemText = trimmed.Substring(trimmed.IndexOf(']') + 1).Trim();
                }
                else if (trimmed.StartsWith("[ui]") || trimmed.StartsWith("[\u754c\u9762]"))
                {
                    itemType = "ui";
                    itemText = trimmed.Substring(trimmed.IndexOf(']') + 1).Trim();
                }
                else if (trimmed.StartsWith("[fix]") || trimmed.StartsWith("[\u4fee\u590d]"))
                {
                    itemType = "fix";
                    itemText = trimmed.Substring(trimmed.IndexOf(']') + 1).Trim();
                }

                if (itemType.Length > 0)
                    itemEl.SetAttribute("type", itemType);
                itemEl.InnerText = itemText;
                versionEl.AppendChild(itemEl);
            }

            // Insert as first child (latest version on top)
            if (root.FirstChild != null)
                root.InsertBefore(versionEl, root.FirstChild);
            else
                root.AppendChild(versionEl);

            doc.Save(xmlPath);

            // Clear form
            TxtNewVer.Text = "";
            TxtNewDate.Text = "";
            TxtNewItems.Text = "";
            DdlNewTag.SelectedIndex = 0;

            // Reload changelog
            _changelogLoaded = false;
            changelogEntries.Clear();

            LabelClMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelClMsg.Text = "&#10004; \u7248\u672c " + Server.HtmlEncode(ver) + " \u5df2\u6210\u529f\u6dfb\u52a0";
        }
        catch (System.Exception ex)
        {
            LabelClMsg.ForeColor = System.Drawing.Color.Red;
            LabelClMsg.Text = "\u4fdd\u5b58\u5931\u8d25: " + Server.HtmlEncode(ex.Message);
        }
    }

    protected void BtnDelVersion_Click(object sender, EventArgs e)
    {
        HiddenFormOpen.Value = "0";
        try
        {
            string verToDel = HiddenDelVer.Value.Trim();
            if (string.IsNullOrEmpty(verToDel)) return;

            string xmlPath = Server.MapPath("~/changelog.xml");
            if (!System.IO.File.Exists(xmlPath)) return;

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNode root = doc.SelectSingleNode("//changelog");
            if (root == null) return;

            XmlNode target = root.SelectSingleNode("version[@ver='" + verToDel.Replace("'", "") + "']");
            if (target != null)
            {
                root.RemoveChild(target);
                doc.Save(xmlPath);

                _changelogLoaded = false;
                changelogEntries.Clear();

                LabelClMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
                LabelClMsg.Text = "&#10004; \u7248\u672c " + Server.HtmlEncode(verToDel) + " \u5df2\u5220\u9664";
            }
        }
        catch (System.Exception ex)
        {
            LabelClMsg.ForeColor = System.Drawing.Color.Red;
            LabelClMsg.Text = "\u5220\u9664\u5931\u8d25: " + Server.HtmlEncode(ex.Message);
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .idx-page{max-width:100%;padding:8px 8px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .idx-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .idx-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#a78bfa);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .idx-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .idx-hd h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .idx-hd p{font-size:13px;color:#94a3b8;margin:0;}
    .idx-grid{display:grid;grid-template-columns:1fr 1fr;gap:24px;}
    @media(max-width:860px){.idx-grid{grid-template-columns:1fr;}}
    .idx-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .idx-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .idx-card.full{grid-column:1/-1;}
    .idx-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .idx-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .idx-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.indigo{background:#eef2ff;}.ci.indigo svg{stroke:#6366f1;}
    .ci.sky{background:#f0f9ff;}.ci.sky svg{stroke:#0ea5e9;}
    .ci.emerald{background:#ecfdf5;}.ci.emerald svg{stroke:#10b981;}
    .ci.rose{background:#fff1f2;}.ci.rose svg{stroke:#f43f5e;}
    .idx-card-bd{padding:22px;font-size:13.5px;color:#475569;line-height:1.8;}
    .idx-card-bd p{margin:0 0 8px;}
    .idx-ver{margin-top:12px;padding:12px 16px;background:#f8fafc;border-radius:10px;font-size:12.5px;color:#64748b;line-height:1.7;}
    .idx-ver strong{color:#475569;}
    /* flow */
    .idx-flow{display:flex;align-items:center;gap:0;flex-wrap:wrap;margin:12px 0 0;}
    .idx-flow-step{display:flex;align-items:center;justify-content:center;height:40px;padding:0 20px;background:linear-gradient(135deg,#eef2ff,#e0e7ff);color:#4f46e5;font-size:13px;font-weight:600;border-radius:10px;white-space:nowrap;}
    .idx-flow-arrow{color:#c7d2fe;font-size:20px;margin:0 6px;flex-shrink:0;}
    .idx-flow-details{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-top:20px;}
    @media(max-width:760px){.idx-flow-details{grid-template-columns:repeat(2,1fr);}}
    .idx-flow-item{padding:14px 16px;background:#f8fafc;border-radius:12px;border:1px solid #f1f5f9;transition:all .2s;}
    .idx-flow-item:hover{background:#eef2ff;border-color:#c7d2fe;}
    .idx-flow-item-num{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:7px;background:linear-gradient(135deg,#6366f1,#818cf8);color:#fff;font-size:11px;font-weight:700;margin-bottom:8px;}
    .idx-flow-item-title{font-size:13.5px;font-weight:600;color:#1e293b;margin-bottom:6px;}
    .idx-flow-item-desc{font-size:12.5px;color:#64748b;line-height:1.7;}
    /* roles */
    .idx-role{display:flex;gap:12px;margin-bottom:14px;}
    .idx-role:last-child{margin-bottom:0;}
    .idx-role-badge{flex-shrink:0;width:56px;height:28px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#fff;}
    .idx-role-badge.admin{background:linear-gradient(135deg,#6366f1,#7c3aed);}
    .idx-role-badge.teacher{background:linear-gradient(135deg,#0ea5e9,#0284c7);}
    .idx-role-badge.student{background:linear-gradient(135deg,#10b981,#059669);}
    .idx-role-text{font-size:13px;color:#475569;line-height:1.7;padding-top:3px;}
    .idx-role-text span{color:#94a3b8;margin:0 4px;}
    /* guide two-column layout */
    .idx-guide-layout{display:grid;grid-template-columns:1fr 1fr;gap:28px;}
    @media(max-width:760px){.idx-guide-layout{grid-template-columns:1fr;}}
    .idx-guide-layout .idx-role{padding:14px 16px;background:#f8fafc;border-radius:12px;border:1px solid #f1f5f9;margin-bottom:12px;transition:all .2s;}
    .idx-guide-layout .idx-role:last-child{margin-bottom:0;}
    .idx-guide-layout .idx-role:hover{background:#eef2ff;border-color:#c7d2fe;}
    .idx-guide-desc{padding:14px 16px;background:#f8fafc;border-radius:12px;border:1px solid #f1f5f9;margin-bottom:12px;transition:all .2s;}
    .idx-guide-desc:last-child{margin-bottom:0;}
    .idx-guide-desc:hover{background:#eef2ff;border-color:#c7d2fe;}
    .idx-guide-desc-hd{font-size:13.5px;font-weight:600;color:#1e293b;margin-bottom:6px;display:flex;align-items:center;gap:8px;}
    .idx-guide-desc-bd{font-size:12.5px;color:#64748b;line-height:1.8;}
    /* version summary */
    .idx-ver-info{display:flex;align-items:center;gap:10px;margin-bottom:10px;}
    .idx-ver-num{font-size:18px;font-weight:700;color:#4f46e5;}
    .idx-ver-changes{font-size:12.5px;color:#64748b;line-height:1.8;padding-left:2px;}
    .idx-ver-changes li{list-style:none;position:relative;padding-left:14px;}
    .idx-ver-changes li::before{content:'';position:absolute;left:0;top:8px;width:5px;height:5px;border-radius:50%;background:#818cf8;}
    .idx-ver-history{margin-top:10px;padding-top:10px;border-top:1px dashed #e2e8f0;font-size:12px;color:#94a3b8;line-height:1.7;}
    .idx-hide{position:absolute;left:-9999px;}
    /* changelog */
    .cl-timeline{position:relative;padding-left:28px;}
    .cl-timeline::before{content:'';position:absolute;left:8px;top:6px;bottom:6px;width:2px;background:linear-gradient(to bottom,#c7d2fe,#e2e8f0);border-radius:2px;}
    .cl-entry{position:relative;margin-bottom:24px;}
    .cl-entry:last-child{margin-bottom:0;}
    .cl-entry::before{content:'';position:absolute;left:-24px;top:6px;width:12px;height:12px;border-radius:50%;border:2.5px solid #818cf8;background:#fff;z-index:1;}
    .cl-entry.latest::before{background:#6366f1;border-color:#6366f1;box-shadow:0 0 0 4px rgba(99,102,241,.15);}
    .cl-entry-hd{display:flex;align-items:center;gap:10px;margin-bottom:6px;}
    .cl-ver{font-size:14px;font-weight:700;color:#1e293b;}
    .cl-date{font-size:12px;color:#94a3b8;}
    .cl-tag{display:inline-flex;align-items:center;height:20px;padding:0 8px;border-radius:6px;font-size:11px;font-weight:600;}
    .cl-tag.new{background:#ecfdf5;color:#059669;}
    .cl-tag.fix{background:#fef3c7;color:#d97706;}
    .cl-tag.improve{background:#eef2ff;color:#4f46e5;}
    .cl-changes{list-style:none;padding:0;margin:0;}
    .cl-changes li{position:relative;padding:3px 0 3px 18px;font-size:13px;color:#475569;line-height:1.7;}
    .cl-changes li::before{content:'';position:absolute;left:0;top:11px;width:6px;height:6px;border-radius:50%;background:#cbd5e1;}
    .cl-changes li.feat::before{background:#6366f1;}
    .cl-changes li.fix::before{background:#f59e0b;}
    .cl-changes li.ui::before{background:#0ea5e9;}
    /* changelog add form */
    .cl-add-btn{margin-left:auto;display:inline-flex;align-items:center;gap:5px;height:32px;padding:0 14px;background:linear-gradient(135deg,#6366f1,#818cf8);color:#fff;border:none;border-radius:8px;font-size:12px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,.25);}
    .cl-add-btn:hover{box-shadow:0 4px 12px rgba(99,102,241,.35);transform:translateY(-1px);}
    .cl-add-btn svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;}
    .cl-form-wrap{margin-bottom:20px;padding:20px;background:linear-gradient(135deg,#f8fafc,#eef2ff);border:1.5px solid #c7d2fe;border-radius:14px;}
    .cl-form-title{font-size:14px;font-weight:700;color:#4338ca;margin-bottom:16px;display:flex;align-items:center;gap:8px;width:100%;}
    .cl-form-title svg{width:18px;height:18px;stroke:#6366f1;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0;}
    .cl-form-row{display:flex;gap:12px;margin-bottom:12px;flex-wrap:wrap;width:100%;}
    .cl-form-field{display:flex;flex-direction:column;gap:4px;min-width:0;}
    .cl-form-field.cl-form-field-full{width:100%;}
    .cl-form-field label{font-size:12px;font-weight:600;color:#6366f1;white-space:nowrap;}
    .cl-form-field input[type="text"],.cl-form-field select{height:36px;padding:0 12px;border:1.5px solid #c7d2fe;border-radius:8px;font-size:13px;font-family:inherit;outline:none;background:#fff;transition:border-color .2s,box-shadow .2s;}
    .cl-form-field input[type="text"]:focus,.cl-form-field select:focus{border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.1);}
    .cl-form-field textarea{width:100%;min-height:120px;padding:12px;border:1.5px solid #c7d2fe;border-radius:10px;font-size:13px;font-family:'Microsoft YaHei',monospace;line-height:1.9;outline:none;background:#fff;resize:vertical;transition:border-color .2s,box-shadow .2s;max-width:100%;}
    .cl-form-field textarea:focus{border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.1);}
    .cl-form-hint{font-size:11.5px;color:#818cf8;line-height:1.6;margin-top:4px;}
    .cl-form-hint code{background:#e0e7ff;padding:1px 5px;border-radius:3px;font-size:11px;color:#4338ca;}
    .cl-form-actions{display:flex;align-items:center;gap:12px;margin-top:14px;flex-wrap:wrap;width:100%;}
    .cl-form-save{display:inline-flex;align-items:center;gap:6px;height:38px;padding:0 24px;background:linear-gradient(135deg,#6366f1,#4f46e5);color:#fff;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(99,102,241,.3);}
    .cl-form-save:hover{box-shadow:0 4px 14px rgba(99,102,241,.4);transform:translateY(-1px);}
    .cl-form-cancel{height:38px;padding:0 20px;background:#fff;color:#64748b;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;}
    .cl-form-cancel:hover{background:#f8fafc;border-color:#cbd5e1;}
    .cl-form-msg{font-size:13px;margin-left:4px;}
    /* delete btn */
    .cl-del-btn{opacity:0;margin-left:auto;display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;background:#fff1f2;border:1px solid #fecdd3;border-radius:6px;cursor:pointer;transition:all .15s;flex-shrink:0;}
    .cl-del-btn:hover{background:#fee2e2;border-color:#fca5a5;}
    .cl-del-btn svg{width:13px;height:13px;stroke:#ef4444;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .cl-entry:hover .cl-del-btn{opacity:1;}
    /* pagination */
    .cl-pagination{margin-top:28px;padding-top:20px;border-top:1px solid #e2e8f0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px;}
    .cl-page-info{font-size:13px;color:#64748b;}
    .cl-page-btns{display:flex;align-items:center;gap:6px;flex-wrap:wrap;}
    .cl-page-btn{display:inline-flex;align-items:center;gap:5px;height:34px;padding:0 14px;background:#fff;color:#475569;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;font-weight:500;text-decoration:none;transition:all .2s;cursor:pointer;}
    .cl-page-btn:hover{background:#f8fafc;border-color:#cbd5e1;color:#1e293b;}
    .cl-page-btn.disabled{opacity:.4;cursor:not-allowed;pointer-events:none;}
    .cl-page-btn svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .cl-page-num{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:34px;padding:0 10px;background:#fff;color:#475569;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;font-weight:500;text-decoration:none;transition:all .2s;cursor:pointer;}
    .cl-page-num:hover{background:#f8fafc;border-color:#cbd5e1;color:#1e293b;}
    .cl-page-num.active{background:linear-gradient(135deg,#6366f1,#818cf8);color:#fff;border-color:#6366f1;font-weight:600;box-shadow:0 2px 6px rgba(99,102,241,.25);}
    .cl-page-dots{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:34px;color:#cbd5e1;font-size:13px;font-weight:700;}
</style>

<div class="idx-page">
    <div class="idx-hd">
        <div class="idx-hd-icon"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/></svg></div>
        <div><h1>管理后台总览</h1><p>LearnSite 信息学习平台 — 系统管理中心</p></div>
    </div>

    <div class="idx-grid">

    <!-- 系统说明 -->
    <div class="idx-card">
        <div class="idx-card-hd"><span class="ci indigo"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>系统说明</div>
        <div class="idx-card-bd">
            <p>本系统基于三层架构原理编写，数据库结构优化，可扩展性强。系统分三种角色登录：学生、教师、管理员。</p>
            <p><strong>教师平台：</strong>学案管理、学生管理、作品管理、签到管理、网页管理、打字管理、资源管理</p>
            <p><strong>管理后台：</strong>系统设置、教师管理、班级设置、新生导入、空间生成、学年升班</p>
            <% EnsureChangelogLoaded(); %>
            <div class="idx-ver">
                <% if (changelogEntries.Count > 0) { %>
                <div class="idx-ver-info">
                    <span class="idx-ver-num"><%= Server.HtmlEncode(changelogEntries[0].Version) %></span>
                    <span class="cl-tag <%= GetTagCss(changelogEntries[0].Tag) %>"><%= GetTagLabel(changelogEntries[0].Tag) %></span>
                    <span style="font-size:12px;color:#94a3b8;"><%= Server.HtmlEncode(changelogEntries[0].Date) %></span>
                </div>
                <ul class="idx-ver-changes">
                    <% for (int i = 0; i < changelogEntries[0].Items.Count && i < 3; i++) { %>
                    <li><%= Server.HtmlEncode(changelogEntries[0].Items[i].Text) %></li>
                    <% } %>
                    <% if (changelogEntries[0].Items.Count > 3) { %>
                    <li style="color:#94a3b8;">等 <%= changelogEntries[0].Items.Count %> 项更新…</li>
                    <% } %>
                </ul>
                <div class="idx-ver-history">
                    共 <strong style="color:#475569;"><%= changelogEntries.Count %></strong> 个版本记录 · 
                    历史演进：ITMS 1.0 → Magnet 2.2 → LearnSite 1.100 → 当前版本
                </div>
                <% } else { %>
                <strong>历史版本：</strong>ITMS 1.0 → Magnet 2.2 → LearnSite 1.100 → LearnSite 1.3.3.3<br />
                2009年8月 — 2021年11月 &nbsp;温州水乡
                <% } %>
            </div>
        </div>
    </div>

    <!-- 操作流程 -->
    <div class="idx-card">
        <div class="idx-card-hd"><span class="ci sky"><svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></span>操作流程</div>
        <div class="idx-card-bd">
            <div class="idx-flow">
                <div class="idx-flow-step">班级设置</div><span class="idx-flow-arrow">→</span>
                <div class="idx-flow-step">教师管理</div><span class="idx-flow-arrow">→</span>
                <div class="idx-flow-step">新生导入</div><span class="idx-flow-arrow">→</span>
                <div class="idx-flow-step">空间生成</div>
            </div>
            <div class="idx-flow-details">
                <div class="idx-flow-item">
                    <div class="idx-flow-item-num">1</div>
                    <div class="idx-flow-item-title">班级设置</div>
                    <div class="idx-flow-item-desc">创建年级和班级信息，建立全校完整的班级列表结构</div>
                </div>
                <div class="idx-flow-item">
                    <div class="idx-flow-item-num">2</div>
                    <div class="idx-flow-item-title">教师管理</div>
                    <div class="idx-flow-item-desc">添加教师账号，为每位教师分配所管理的班级</div>
                </div>
                <div class="idx-flow-item">
                    <div class="idx-flow-item-num">3</div>
                    <div class="idx-flow-item-title">新生导入</div>
                    <div class="idx-flow-item-desc">使用 Excel 模板批量导入学生名单到对应班级</div>
                </div>
                <div class="idx-flow-item">
                    <div class="idx-flow-item-num">4</div>
                    <div class="idx-flow-item-title">空间生成</div>
                    <div class="idx-flow-item-desc">为导入的学生批量生成个人学习空间和作品目录</div>
                </div>
            </div>
        </div>
    </div>

    <!-- 使用指南 -->
    <div class="idx-card full">
        <div class="idx-card-hd"><span class="ci emerald"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>角色使用指南</div>
        <div class="idx-card-bd">
            <div class="idx-guide-layout">
                <div>
                    <div class="idx-role">
                        <div class="idx-role-badge admin">管理员</div>
                        <div class="idx-role-text">创建全校完整班级列表<span>→</span>添加教师并指定班级<span>→</span>使用Excel模板导入新生</div>
                    </div>
                    <div class="idx-role">
                        <div class="idx-role-badge teacher">教师</div>
                        <div class="idx-role-text">登录教师平台<span>→</span>备课(学案设计)<span>→</span>上课(签到/作品)<span>→</span>评价<span>→</span>反思</div>
                    </div>
                    <div class="idx-role">
                        <div class="idx-role-badge student">学生</div>
                        <div class="idx-role-text">登录学生平台<span>→</span>浏览学案<span>→</span>导学准备<span>→</span>课堂活动<span>→</span>作品展示<span>→</span>师生小结</div>
                    </div>
                </div>
                <div>
                    <div class="idx-guide-desc">
                        <div class="idx-guide-desc-hd"><span class="idx-role-badge admin" style="width:auto;height:22px;padding:0 10px;font-size:11px;">管理员</span>系统管理与初始化</div>
                        <div class="idx-guide-desc-bd">负责全校基础数据管理，包括创建年级班级、配置教师账号、批量导入学生信息、生成学习空间等。是系统运行的基础保障角色。</div>
                    </div>
                    <div class="idx-guide-desc">
                        <div class="idx-guide-desc-hd"><span class="idx-role-badge teacher" style="width:auto;height:22px;padding:0 10px;font-size:11px;">教师</span>教学设计与评价</div>
                        <div class="idx-guide-desc-bd">负责日常教学活动，包括学案设计与发布、课堂签到管理、学生作品收集与评价、教学资源管理等。是教学流程的核心执行角色。</div>
                    </div>
                    <div class="idx-guide-desc">
                        <div class="idx-guide-desc-hd"><span class="idx-role-badge student" style="width:auto;height:22px;padding:0 10px;font-size:11px;">学生</span>自主学习与展示</div>
                        <div class="idx-guide-desc-bd">参与课堂学习活动，包括浏览教师学案、完成导学准备、参与课堂互动、提交展示作品、参与师生总结等。是学习活动的主体角色。</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 版本更新日志（自动从 ~/changelog.xml 读取） -->
    <div class="idx-card full" id="changelog">
        <div class="idx-card-hd">
            <span class="ci indigo"><svg viewBox="0 0 24 24"><polyline points="12 8 12 12 14 14"/><circle cx="12" cy="12" r="10"/></svg></span>版本更新日志
            <button type="button" class="cl-add-btn" onclick="clToggleForm()">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                新增版本
            </button>
        </div>
        <div class="idx-card-bd">
            <!-- 新增版本表单 -->
            <asp:HiddenField ID="HiddenFormOpen" runat="server" Value="0" />
            <asp:HiddenField ID="HiddenDelVer" runat="server" Value="" />
            <asp:Button ID="BtnDelVersion" runat="server" Text="del" OnClick="BtnDelVersion_Click" style="display:none;" />
            <div class="cl-form-wrap" id="clFormWrap" style="display:<%= HiddenFormOpen.Value == "1" ? "block" : "none" %>;">
                <div class="cl-form-title">
                    <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                    添加新版本记录
                </div>
                <div class="cl-form-row">
                    <div class="cl-form-field">
                        <label>版本号</label>
                        <asp:TextBox ID="TxtNewVer" runat="server" style="width:140px" placeholder="如 v2026.3" />
                    </div>
                    <div class="cl-form-field">
                        <label>版本标签</label>
                        <asp:DropDownList ID="DdlNewTag" runat="server" style="width:130px">
                            <asp:ListItem Value="new" Text="NEW 新功能" />
                            <asp:ListItem Value="improve" Text="IMPROVE 改进" />
                            <asp:ListItem Value="fix" Text="FIX 修复" />
                            <asp:ListItem Value="stable" Text="STABLE 稳定" />
                        </asp:DropDownList>
                    </div>
                    <div class="cl-form-field">
                        <label>发布日期</label>
                        <asp:TextBox ID="TxtNewDate" runat="server" style="width:150px" placeholder="如 2026年3月" />
                    </div>
                </div>
                <div class="cl-form-field cl-form-field-full">
                    <label>更新内容（每行一条）</label>
                    <asp:TextBox ID="TxtNewItems" runat="server" TextMode="MultiLine" Rows="6" placeholder="每行一条更新内容，例如：&#10;[功能] 新增数据仪表盘&#10;[界面] 优化登录页面&#10;[修复] 修复分页问题&#10;普通更新说明（无前缀）" />
                    <div class="cl-form-hint">
                        可选前缀：<code>[功能]</code> 或 <code>[feat]</code> 功能更新 &nbsp;
                        <code>[界面]</code> 或 <code>[ui]</code> 界面优化 &nbsp;
                        <code>[修复]</code> 或 <code>[fix]</code> 问题修复 &nbsp;不加前缀则为默认样式
                    </div>
                </div>
                <div class="cl-form-actions">
                    <asp:Button ID="BtnAddVersion" runat="server" Text="保存版本" CssClass="cl-form-save" OnClick="BtnAddVersion_Click" />
                    <button type="button" class="cl-form-cancel" onclick="clToggleForm()">取消</button>
                    <span class="cl-form-msg"><asp:Label ID="LabelClMsg" runat="server" /></span>
                </div>
            </div>

            <% 
            System.Collections.Generic.List<ChangelogEntry> pagedEntries = GetPagedEntries();
            EnsureChangelogLoaded();
            %>
            <% if (pagedEntries.Count > 0) { %>
            <div class="cl-timeline">
                <% foreach (ChangelogEntry entry in pagedEntries) { %>
                <div class="cl-entry<%= entry.IsLatest && currentPage == 1 ? " latest" : "" %>">
                    <div class="cl-entry-hd">
                        <span class="cl-ver"><%= Server.HtmlEncode(entry.Version) %></span>
                        <span class="cl-tag <%= GetTagCss(entry.Tag) %>"><%= GetTagLabel(entry.Tag) %></span>
                        <span class="cl-date"><%= Server.HtmlEncode(entry.Date) %></span>
                        <span class="cl-del-btn" onclick="clDelVersion('<%= Server.HtmlEncode(entry.Version).Replace("'", "") %>')" title="删除此版本">
                            <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                        </span>
                    </div>
                    <ul class="cl-changes">
                        <% foreach (ChangelogItem item in entry.Items) { %>
                        <li<%= !string.IsNullOrEmpty(item.Type) ? " class=\"" + Server.HtmlEncode(item.Type) + "\"" : "" %>><%= Server.HtmlEncode(item.Text) %></li>
                        <% } %>
                    </ul>
                </div>
                <% } %>
            </div>
            
            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div class="cl-pagination">
                <div class="cl-page-info">
                    第 <%= currentPage %> / <%= totalPages %> 页，共 <%= changelogEntries.Count %> 个版本
                </div>
                <div class="cl-page-btns">
                    <% if (currentPage > 1) { %>
                    <a href="?page=<%= currentPage - 1 %>#changelog" class="cl-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                        上一页
                    </a>
                    <% } else { %>
                    <span class="cl-page-btn disabled">
                        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                        上一页
                    </span>
                    <% } %>
                    
                    <% 
                    int startPage = Math.Max(1, currentPage - 2);
                    int endPage = Math.Min(totalPages, currentPage + 2);
                    
                    if (startPage > 1) { %>
                        <a href="?page=1#changelog" class="cl-page-num">1</a>
                        <% if (startPage > 2) { %>
                        <span class="cl-page-dots">...</span>
                        <% } %>
                    <% } %>
                    
                    <% for (int i = startPage; i <= endPage; i++) { %>
                        <% if (i == currentPage) { %>
                        <span class="cl-page-num active"><%= i %></span>
                        <% } else { %>
                        <a href="?page=<%= i %>#changelog" class="cl-page-num"><%= i %></a>
                        <% } %>
                    <% } %>
                    
                    <% if (endPage < totalPages) { %>
                        <% if (endPage < totalPages - 1) { %>
                        <span class="cl-page-dots">...</span>
                        <% } %>
                        <a href="?page=<%= totalPages %>#changelog" class="cl-page-num"><%= totalPages %></a>
                    <% } %>
                    
                    <% if (currentPage < totalPages) { %>
                    <a href="?page=<%= currentPage + 1 %>#changelog" class="cl-page-btn">
                        下一页
                        <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                    <% } else { %>
                    <span class="cl-page-btn disabled">
                        下一页
                        <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                    </span>
                    <% } %>
                </div>
            </div>
            <% } %>
            
            <% } else { %>
            <div style="text-align:center;padding:24px;color:#94a3b8;font-size:13px;">暂无版本日志，点击上方「新增版本」按钮添加第一条记录</div>
            <% } %>
        </div>
    </div>

    </div>
    <!-- 原始控件隐藏保留 -->
    <div class="idx-hide">
        <asp:TextBox ID="TextBox1" runat="server" SkinID="TextBoxindex" ReadOnly="true" Width="80px">操作流程图：</asp:TextBox>
        <asp:TextBox ID="TextBox3" runat="server" SkinId="TextBoxaa" ReadOnly="True" Width="56px">班级设置</asp:TextBox>
        <asp:TextBox ID="TextBox7" runat="server" SkinId="TextBoxbb" ReadOnly="True" Width="22px">→</asp:TextBox>
        <asp:TextBox ID="TextBox2" runat="server" SkinId="TextBoxaa" ReadOnly="True" Width="56px">教师管理</asp:TextBox>
        <asp:TextBox ID="TextBox8" runat="server" SkinId="TextBoxbb" ReadOnly="True" Width="22px">→</asp:TextBox>
        <asp:TextBox ID="TextBox4" runat="server" SkinId="TextBoxaa" ReadOnly="True" Width="56px">新生导入</asp:TextBox>
        <asp:TextBox ID="TextBox9" runat="server" SkinId="TextBoxbb" ReadOnly="True" Width="22px">→</asp:TextBox>
        <asp:TextBox ID="TextBox5" runat="server" SkinId="TextBoxaa" ReadOnly="True" Width="56px">空间生成</asp:TextBox>
    </div>
</div>

<script type="text/javascript">
    function clToggleForm() {
        var f = document.getElementById('clFormWrap');
        var h = document.getElementById('<%= HiddenFormOpen.ClientID %>');
        if (f.style.display === 'block') {
            f.style.display = 'none';
            if (h) h.value = '0';
        } else {
            f.style.display = 'block';
            if (h) h.value = '1';
            // Auto fill date
            var dateEl = document.getElementById('<%= TxtNewDate.ClientID %>');
            if (dateEl && !dateEl.value) {
                var now = new Date();
                dateEl.value = now.getFullYear() + '\u5e74' + (now.getMonth() + 1) + '\u6708';
            }
        }
    }

    function clDelVersion(ver) {
        if (!confirm('\u786e\u5b9a\u8981\u5220\u9664\u7248\u672c ' + ver + ' \u7684\u66f4\u65b0\u65e5\u5fd7\u5417\uff1f')) return;
        document.getElementById('<%= HiddenDelVer.ClientID %>').value = ver;
        document.getElementById('<%= BtnDelVersion.ClientID %>').click();
    }
</script>
</asp:Content>

