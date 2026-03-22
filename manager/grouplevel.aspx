<%@ Page Title="" Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>

<script runat="server">
    protected class LevelItem
    {
        public int Threshold;
        public string Name;
        public string Icon;
        public string Color;

        public LevelItem() { }
        public LevelItem(int threshold, string name, string icon, string color)
        {
            Threshold = threshold;
            Name = name;
            Icon = icon;
            Color = color;
        }
    }

    private static int CompareLevelByThreshold(LevelItem a, LevelItem b)
    {
        return a.Threshold.CompareTo(b.Threshold);
    }

    protected System.Collections.Generic.List<LevelItem> levels = new System.Collections.Generic.List<LevelItem>();
    protected string saveMsg = "";
    protected string saveMsgColor = "";

    private string GetXmlPath()
    {
        return Server.MapPath("~/App_Data/grouplevel.xml");
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadLevels();
            BindToForm();
        }
    }

    private void LoadLevels()
    {
        levels.Clear();
        string xmlPath = GetXmlPath();
        if (System.IO.File.Exists(xmlPath))
        {
            try
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(xmlPath);
                System.Xml.XmlNodeList nodes = doc.SelectNodes("//levels/level");
                if (nodes != null)
                {
                    foreach (System.Xml.XmlNode node in nodes)
                    {
                        LevelItem item = new LevelItem();
                        item.Threshold = node.Attributes["threshold"] != null ? int.Parse(node.Attributes["threshold"].Value) : 0;
                        item.Name = node.Attributes["name"] != null ? node.Attributes["name"].Value : "";
                        item.Icon = node.Attributes["icon"] != null ? node.Attributes["icon"].Value : "";
                        item.Color = node.Attributes["color"] != null ? node.Attributes["color"].Value : "#94a3b8";
                        levels.Add(item);
                    }
                }
            }
            catch { }
        }

        // 如果没有配置，使用默认值
        if (levels.Count == 0)
        {
            AddDefaultGroupLevels();
        }
    }

    private void BindToForm()
    {
        HiddenLevelCount.Value = levels.Count.ToString();
        // 通过隐藏字段传递数据到前端
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        foreach (LevelItem item in levels)
        {
            if (sb.Length > 0) sb.Append("|");
            sb.Append(item.Threshold + "," + item.Name + "," + item.Icon + "," + item.Color);
        }
        HiddenLevelData.Value = sb.ToString();
    }

    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string data = HiddenLevelData.Value;
            if (string.IsNullOrEmpty(data))
            {
                saveMsg = "没有等级数据可保存";
                saveMsgColor = "#ef4444";
                LoadLevels();
                return;
            }

            string[] items = data.Split('|');
            levels.Clear();
            foreach (string item in items)
            {
                string[] parts = item.Split(',');
                if (parts.Length >= 4)
                {
                    LevelItem lv = new LevelItem();
                    int.TryParse(parts[0], out lv.Threshold);
                    lv.Name = parts[1].Trim();
                    lv.Icon = parts[2].Trim();
                    lv.Color = parts[3].Trim();
                    if (!string.IsNullOrEmpty(lv.Name) && !string.IsNullOrEmpty(lv.Icon))
                        levels.Add(lv);
                }
            }

            if (levels.Count == 0)
            {
                saveMsg = "至少需要一个等级";
                saveMsgColor = "#ef4444";
                LoadLevels();
                BindToForm();
                return;
            }

            // 按阈值排序
            levels.Sort(CompareLevelByThreshold);

            // 保存到XML
            string xmlPath = GetXmlPath();
            string dir = System.IO.Path.GetDirectoryName(xmlPath);
            if (!System.IO.Directory.Exists(dir))
                System.IO.Directory.CreateDirectory(dir);

            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.AppendChild(doc.CreateXmlDeclaration("1.0", "utf-8", null));
            System.Xml.XmlElement root = doc.CreateElement("levels");
            doc.AppendChild(root);

            foreach (LevelItem lv in levels)
            {
                System.Xml.XmlElement el = doc.CreateElement("level");
                el.SetAttribute("threshold", lv.Threshold.ToString());
                el.SetAttribute("name", lv.Name);
                el.SetAttribute("icon", lv.Icon);
                el.SetAttribute("color", lv.Color);
                root.AppendChild(el);
            }

            doc.Save(xmlPath);

            saveMsg = "✔ 小组等级设置已保存成功！";
            saveMsgColor = "#059669";
            BindToForm();
        }
        catch (System.Exception ex)
        {
            saveMsg = "保存失败：" + ex.Message;
            saveMsgColor = "#ef4444";
            LoadLevels();
            BindToForm();
        }
    }

    protected void BtnReset_Click(object sender, EventArgs e)
    {
        try
        {
            string xmlPath = GetXmlPath();
            if (System.IO.File.Exists(xmlPath))
                System.IO.File.Delete(xmlPath);
        }
        catch { }

        levels.Clear();
        AddDefaultGroupLevels();
        BindToForm();

        saveMsg = "✔ 已恢复默认设置";
        saveMsgColor = "#059669";
    }

    private void AddDefaultGroupLevels()
    {
        levels.Add(new LevelItem(0, "见习组员", "🌱", "#94a3b8"));
        levels.Add(new LevelItem(10, "初级组员", "🌿", "#10b981"));
        levels.Add(new LevelItem(30, "中级组员", "⭐", "#f59e0b"));
        levels.Add(new LevelItem(60, "高级组员", "🌟", "#f97316"));
        levels.Add(new LevelItem(100, "资深组员", "💎", "#8b5cf6"));
        levels.Add(new LevelItem(150, "明星组员", "👑", "#ec4899"));
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<asp:HiddenField ID="HiddenLevelCount" runat="server" Value="0" />
<asp:HiddenField ID="HiddenLevelData" runat="server" Value="" />
<style>
    .glm-page { max-width: 1400px; padding: 28px 32px 52px; font-family: 'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }

    /* ===== 页头 ===== */
    .glm-hd { display: flex; align-items: center; gap: 20px; margin-bottom: 32px; }
    .glm-hd-icon {
        width: 62px; height: 62px;
        background: linear-gradient(135deg, #047857 0%, #059669 55%, #10b981 100%);
        border-radius: 18px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 8px 24px rgba(5,150,105,.28), 0 2px 6px rgba(5,150,105,.12);
        flex-shrink: 0;
    }
    .glm-hd-icon svg { width: 32px; height: 32px; stroke: rgba(255,255,255,.95); fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .glm-hd h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin: 0 0 5px; letter-spacing: -.3px; }
    .glm-hd p  { font-size: 14px; color: #94a3b8; margin: 0; line-height: 1.6; }

    /* ===== 卡片 ===== */
    .glm-card { background: #fff; border-radius: 18px; border: 1px solid #e8ecf2; box-shadow: 0 2px 12px rgba(0,0,0,.05), 0 1px 3px rgba(0,0,0,.03); overflow: hidden; margin-bottom: 24px; }
    .glm-card-hd {
        padding: 16px 22px; font-size: 15px; font-weight: 600; color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; gap: 12px;
        background: linear-gradient(to bottom, #f9fafb, #ffffff);
    }
    .glm-card-hd-icon {
        width: 34px; height: 34px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .glm-card-hd-icon svg { width: 17px; height: 17px; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .glm-card-hd-icon.ic-green  { background: #ecfdf5; }
    .glm-card-hd-icon.ic-green  svg { stroke: #059669; }
    .glm-card-hd-icon.ic-indigo { background: #eef2ff; }
    .glm-card-hd-icon.ic-indigo svg { stroke: #4f46e5; }
    .glm-card-bd { padding: 24px; }

    /* ===== 预览网格 ===== */
    .glm-preview { display: grid; grid-template-columns: repeat(auto-fill, minmax(148px, 1fr)); gap: 14px; }
    .glm-preview-item {
        padding: 22px 14px 18px; border-radius: 16px;
        border: 2px solid transparent; text-align: center;
        transition: transform .22s ease, box-shadow .22s ease;
        position: relative; overflow: hidden;
    }
    .glm-preview-item:hover { transform: translateY(-5px); box-shadow: 0 14px 30px rgba(0,0,0,.10); }
    .glm-preview-icon { font-size: 44px; margin-bottom: 10px; line-height: 1; }
    .glm-preview-icon img { width: 44px; height: 44px; object-fit: contain; vertical-align: middle; }
    .glm-preview-lv {
        display: inline-block; font-size: 11px; font-weight: 700; color: #fff;
        padding: 2px 11px; border-radius: 20px; margin-bottom: 8px;
    }
    .glm-preview-name  { font-size: 14px; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
    .glm-preview-score { font-size: 12px; color: #94a3b8; }

    /* ===== 编辑表格 ===== */
    .glm-table-wrap { overflow-x: auto; margin: 0 -2px; padding: 0 2px; }
    .glm-table { width: 100%; border-collapse: collapse; min-width: 620px; }
    .glm-table th {
        padding: 10px 14px; font-size: 11.5px; font-weight: 700;
        color: #64748b; text-align: left;
        background: #f8fafc; border-bottom: 2px solid #e8ecf1;
        text-transform: uppercase; letter-spacing: .5px; white-space: nowrap;
    }
    .glm-table td { padding: 11px 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    .glm-table tbody tr:last-child td { border-bottom: none; }
    .glm-table tbody tr { transition: background .12s; }
    .glm-table tbody tr:hover { background: #fafbfc; }
    .glm-table input[type="text"], .glm-table input[type="number"] {
        height: 40px; padding: 0 12px;
        border: 1.5px solid #e2e8f0; border-radius: 10px;
        font-size: 14px; font-family: inherit; color: #1e293b;
        outline: none; background: #fff;
        transition: border-color .18s, box-shadow .18s;
    }
    .glm-table input:focus { border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,.10); }
    .glm-table .glm-input-icon  { width: 78px; text-align: center; font-size: 20px; }
    .glm-table .glm-input-name  { width: 170px; }
    .glm-table .glm-input-score { width: 100px; }
    .glm-input-color {
        width: 50px !important; height: 40px;
        border: 1.5px solid #e2e8f0 !important; border-radius: 10px !important;
        padding: 4px !important; cursor: pointer; display: block;
        transition: border-color .18s;
    }
    .glm-input-color:hover { border-color: #10b981 !important; }

    .glm-lv-badge {
        display: inline-flex; align-items: center; justify-content: center;
        width: 30px; height: 30px; border-radius: 8px;
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff; font-size: 13px; font-weight: 700;
        box-shadow: 0 2px 6px rgba(16,185,129,.28);
    }

    /* 图标单元格 */
    .glm-icon-cell { display: flex; align-items: center; gap: 8px; }
    .glm-icon-prev {
        width: 40px; height: 40px; border-radius: 10px;
        border: 1.5px solid #e5e7eb;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; background: #f8fafc; flex-shrink: 0; overflow: hidden;
        transition: border-color .18s, background .18s;
    }
    .glm-icon-prev:hover { border-color: #10b981; background: #ecfdf5; }
    .glm-icon-prev img { width: 100%; height: 100%; object-fit: contain; }
    .glm-btn-upload {
        width: 40px; height: 40px; flex-shrink: 0;
        border: 1.5px dashed #a7f3d0; background: #ecfdf5;
        border-radius: 10px; cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        transition: all .18s; color: #059669;
    }
    .glm-btn-upload svg { width: 17px; height: 17px; stroke: currentColor; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .glm-btn-upload:hover { background: #d1fae5; border-color: #6ee7b7; transform: scale(1.06); }
    .glm-btn-del {
        width: 34px; height: 34px; border: none;
        background: #fef2f2; border-radius: 9px;
        cursor: pointer; display: flex; align-items: center; justify-content: center;
        transition: all .18s; color: #ef4444;
    }
    .glm-btn-del svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .glm-btn-del:hover { background: #fee2e2; transform: scale(1.08); }

    /* ===== 操作栏 ===== */
    .glm-actions { display: flex; align-items: center; gap: 12px; margin-top: 22px; flex-wrap: wrap; }
    .glm-btn-save {
        height: 44px; padding: 0 30px;
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff; border: none; border-radius: 12px;
        font-size: 15px; font-family: inherit; font-weight: 600;
        cursor: pointer; transition: all .2s;
        box-shadow: 0 4px 14px rgba(5,150,105,.30);
    }
    .glm-btn-save:hover  { box-shadow: 0 6px 20px rgba(5,150,105,.42); transform: translateY(-2px); }
    .glm-btn-save:active { transform: translateY(0); box-shadow: 0 2px 8px rgba(5,150,105,.22); }
    .glm-btn-add {
        display: inline-flex; align-items: center; gap: 6px;
        height: 38px; padding: 0 18px;
        background: #f0fdf4; color: #059669;
        border: 1.5px solid #a7f3d0; border-radius: 10px;
        font-size: 14px; font-family: inherit; font-weight: 600;
        cursor: pointer; transition: all .18s;
    }
    .glm-btn-add svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2.3; stroke-linecap: round; flex-shrink: 0; }
    .glm-btn-add:hover { background: #dcfce7; border-color: #6ee7b7; box-shadow: 0 2px 8px rgba(16,185,129,.15); }
    .glm-btn-reset {
        height: 44px; padding: 0 24px;
        background: #fff; color: #64748b;
        border: 1.5px solid #e2e8f0; border-radius: 12px;
        font-size: 15px; font-family: inherit; font-weight: 500;
        cursor: pointer; transition: all .2s;
    }
    .glm-btn-reset:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 2px 8px rgba(0,0,0,.06); }

    /* 保存消息 */
    .glm-msg {
        display: inline-flex; align-items: center; gap: 8px;
        font-size: 13.5px; font-weight: 600;
        padding: 10px 16px; border-radius: 10px;
        animation: glmFadeUp .3s ease;
    }
    .glm-msg svg { width: 16px; height: 16px; flex-shrink: 0; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    @keyframes glmFadeUp { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
    .glm-msg-ok  { background: #f0fdf4; color: #059669; border: 1px solid #bbf7d0; }
    .glm-msg-ok  svg { stroke: #059669; }
    .glm-msg-err { background: #fef2f2; color: #ef4444; border: 1px solid #fecaca; }
    .glm-msg-err svg { stroke: #ef4444; }

    /* 提示框 */
    .glm-tip {
        margin-top: 20px; padding: 16px 18px;
        background: linear-gradient(135deg, #f0fdf4, #ecfdf5);
        border: 1.5px solid #bbf7d0; border-radius: 14px;
        font-size: 13px; color: #15803d; line-height: 1.9;
        display: flex; gap: 13px; align-items: flex-start;
    }
    .glm-tip-icon { flex-shrink: 0; margin-top: 1px; }
    .glm-tip-icon svg { width: 20px; height: 20px; stroke: #059669; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .glm-tip strong { color: #059669; font-weight: 700; }
</style>
<input type="file" id="glmIconFileInput" accept="image/png,image/jpeg,image/gif,image/webp,image/svg+xml" style="display:none" />

<div class="glm-page">

    <!-- 页头 -->
    <div class="glm-hd">
        <div class="glm-hd-icon">
            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div>
            <h1>小组等级设置</h1>
            <p>管理小组学分等级名称、图标和积分阈值，设置后同步到学生端展示</p>
        </div>
    </div>

    <!-- 预览 -->
    <div class="glm-card">
        <div class="glm-card-hd">
            <div class="glm-card-hd-icon ic-green">
                <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            </div>
            等级预览
        </div>
        <div class="glm-card-bd">
            <div class="glm-preview" id="previewArea"></div>
        </div>
    </div>

    <!-- 配置 -->
    <div class="glm-card">
        <div class="glm-card-hd">
            <div class="glm-card-hd-icon ic-indigo">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            </div>
            等级配置
            <button type="button" class="glm-btn-add" onclick="addLevel()" style="margin-left:auto;">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                新增等级
            </button>
        </div>
        <div class="glm-card-bd">
            <div class="glm-table-wrap">
                <table class="glm-table">
                    <thead>
                        <tr>
                            <th style="width:52px">序号</th>
                            <th style="width:220px">图标</th>
                            <th>名称</th>
                            <th style="width:130px">积分阈值</th>
                            <th style="width:72px">颜色</th>
                            <th style="width:52px">操作</th>
                        </tr>
                    </thead>
                    <tbody id="levelTableBody"></tbody>
                </table>
            </div>

            <div class="glm-actions">
                <asp:Button ID="BtnSave" runat="server" Text="保存设置" CssClass="glm-btn-save" OnClick="BtnSave_Click" OnClientClick="return prepareSubmit();" />
                <asp:Button ID="BtnReset" runat="server" Text="恢复默认" CssClass="glm-btn-reset" OnClick="BtnReset_Click" OnClientClick="return confirm('确定要恢复默认等级设置吗？');" />
                <% if (!string.IsNullOrEmpty(saveMsg)) { %>
                <span class="glm-msg <%= saveMsgColor == "#ef4444" ? "glm-msg-err" : "glm-msg-ok" %>">
                    <% if (saveMsgColor == "#ef4444") { %>
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    <% } else { %>
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    <% } %>
                    <%= saveMsg %>
                </span>
                <% } %>
            </div>

            <div class="glm-tip">
                <div class="glm-tip-icon">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                </div>
                <div>
                    <strong>图标：</strong>支持直接输入 Emoji 表情符号，也可以点击上传按钮上传自定义图片（PNG / JPG / GIF / SVG，不超过 512KB）。<br />
                    <strong>积分阈值：</strong>表示达到该分数后可以升级到对应等级。<br />
                    <strong>颜色：</strong>用于等级标签的展示颜色，设置后将同步应用到学生个人中心的小组等级页面。
                </div>
            </div>
        </div>
    </div>

</div>

<script type="text/javascript">
    var levelData = [];

    function initData() {
        var raw = document.getElementById('<%= HiddenLevelData.ClientID %>').value;
        levelData = [];
        if (raw) {
            var items = raw.split('|');
            for (var i = 0; i < items.length; i++) {
                var parts = items[i].split(',');
                if (parts.length >= 4) {
                    levelData.push({ threshold: parseInt(parts[0]) || 0, name: parts[1], icon: parts[2], color: parts[3] });
                }
            }
        }
        if (levelData.length === 0) {
            levelData = [
                { threshold: 0,   name: '见习组员', icon: '🌱', color: '#94a3b8' },
                { threshold: 10,  name: '初级组员', icon: '🌿', color: '#10b981' },
                { threshold: 30,  name: '中级组员', icon: '⭐', color: '#f59e0b' },
                { threshold: 60,  name: '高级组员', icon: '🌟', color: '#f97316' },
                { threshold: 100, name: '资深组员', icon: '💎', color: '#8b5cf6' },
                { threshold: 150, name: '明星组员', icon: '👑', color: '#ec4899' }
            ];
        }
        renderAll();
    }

    function renderAll() {
        renderTable();
        renderPreview();
    }

    function isImageUrl(s) {
        if (!s) return false;
        return s.indexOf('/') >= 0 || s.indexOf('.png') >= 0 || s.indexOf('.jpg') >= 0 || s.indexOf('.gif') >= 0 || s.indexOf('.svg') >= 0 || s.indexOf('.webp') >= 0;
    }

    function renderIconHtml(icon, size) {
        if (isImageUrl(icon)) {
            return '<img src="' + escHtml(icon) + '" style="width:' + size + 'px;height:' + size + 'px;object-fit:contain;" />';
        }
        return escHtml(icon);
    }

    var svgUpload = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>';
    var svgTrash  = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>';

    function renderTable() {
        var tbody = document.getElementById('levelTableBody');
        var html = '';
        for (var i = 0; i < levelData.length; i++) {
            var d = levelData[i];
            html += '<tr>'
                + '<td><span class="glm-lv-badge">' + (i + 1) + '</span></td>'
                + '<td><div class="glm-icon-cell">'
                +   '<div class="glm-icon-prev" id="iconPrev_' + i + '">' + renderIconHtml(d.icon, 26) + '</div>'
                +   '<input type="text" class="glm-input-icon" value="' + escHtml(d.icon) + '" onchange="updateField(' + i + ',\'icon\',this.value);updateIconPreview(' + i + ',this.value)" />'
                +   '<button type="button" class="glm-btn-upload" onclick="triggerUpload(' + i + ')" title="上传图片">' + svgUpload + '</button>'
                + '</div></td>'
                + '<td><input type="text" class="glm-input-name" value="' + escHtml(d.name) + '" onchange="updateField(' + i + ',\'name\',this.value)" /></td>'
                + '<td><input type="number" class="glm-input-score" value="' + d.threshold + '" min="0" onchange="updateField(' + i + ',\'threshold\',parseInt(this.value)||0)" /></td>'
                + '<td><input type="color" class="glm-input-color" value="' + d.color + '" onchange="updateField(' + i + ',\'color\',this.value)" /></td>'
                + '<td>' + (levelData.length > 1 ? '<button type="button" class="glm-btn-del" onclick="removeLevel(' + i + ')" title="删除">' + svgTrash + '</button>' : '') + '</td>'
                + '</tr>';
        }
        tbody.innerHTML = html;
    }

    function updateIconPreview(idx, val) {
        var el = document.getElementById('iconPrev_' + idx);
        if (el) el.innerHTML = renderIconHtml(val, 26);
    }

    var uploadTargetIdx = -1;
    function triggerUpload(idx) {
        uploadTargetIdx = idx;
        document.getElementById('glmIconFileInput').click();
    }

    document.getElementById('glmIconFileInput').onchange = function() {
        var file = this.files[0];
        if (!file || uploadTargetIdx < 0) return;
        var fd = new FormData();
        fd.append('file', file);
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'uploadlevelicon.ashx', true);
        var idx = uploadTargetIdx;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                try {
                    var resp = eval('(' + xhr.responseText + ')');
                    if (resp.success === 1) {
                        levelData[idx].icon = resp.url;
                        renderAll();
                    } else {
                        alert(resp.message || '上传失败');
                    }
                } catch(e) { alert('上传失败'); }
            }
        };
        xhr.send(fd);
        this.value = '';
    };

    function renderPreview() {
        var area = document.getElementById('previewArea');
        var html = '';
        for (var i = 0; i < levelData.length; i++) {
            var d = levelData[i];
            var bgTint    = d.color + '18';
            var borderClr = d.color + '40';
            html += '<div class="glm-preview-item" style="background:linear-gradient(135deg,' + bgTint + ',transparent 70%);border-color:' + borderClr + ';">' 
                + '<div class="glm-preview-icon">' + renderIconHtml(d.icon, 38) + '</div>'
                + '<div><span class="glm-preview-lv" style="background:' + d.color + ';">Lv.' + (i + 1) + '</span></div>'
                + '<div class="glm-preview-name">' + escHtml(d.name) + '</div>'
                + '<div class="glm-preview-score">' + d.threshold + ' 分起</div>'
                + '</div>';
        }
        area.innerHTML = html;
    }

    function updateField(idx, field, val) {
        levelData[idx][field] = val;
        renderPreview();
    }

    function addLevel() {
        var lastThreshold = levelData.length > 0 ? levelData[levelData.length - 1].threshold : 0;
        levelData.push({ threshold: lastThreshold + 50, name: '新等级', icon: '⭐', color: '#6366f1' });
        renderAll();
    }

    function removeLevel(idx) {
        if (levelData.length <= 1) return;
        levelData.splice(idx, 1);
        renderAll();
    }

    function prepareSubmit() {
        var tbody = document.getElementById('levelTableBody');
        var rows = tbody.getElementsByTagName('tr');
        for (var i = 0; i < rows.length && i < levelData.length; i++) {
            var inputs = rows[i].getElementsByTagName('input');
            if (inputs.length >= 4) {
                levelData[i].icon      = inputs[0].value;
                levelData[i].name      = inputs[1].value;
                levelData[i].threshold = parseInt(inputs[2].value) || 0;
                levelData[i].color     = inputs[3].value;
            }
        }
        var parts = [];
        for (var i = 0; i < levelData.length; i++) {
            var d = levelData[i];
            parts.push(d.threshold + ',' + d.name + ',' + d.icon + ',' + d.color);
        }
        document.getElementById('<%= HiddenLevelData.ClientID %>').value = parts.join('|');
        return true;
    }

    function escHtml(s) {
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(s));
        return div.innerHTML;
    }

    initData();
</script>
</asp:Content>
