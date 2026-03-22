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
        return Server.MapPath("~/App_Data/creditlevel.xml");
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
            AddDefaultCreditLevels();
        }
    }

    private void BindToForm()
    {
        HiddenLevelCount.Value = levels.Count.ToString();
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

            saveMsg = "✔ 积分等级设置已保存成功！";
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
        AddDefaultCreditLevels();
        BindToForm();

        saveMsg = "✔ 已恢复默认设置";
        saveMsgColor = "#059669";
    }

    private void AddDefaultCreditLevels()
    {
        levels.Add(new LevelItem(0, "学习新手", "🌱", "#94a3b8"));
        levels.Add(new LevelItem(20, "勤奋学生", "🌿", "#10b981"));
        levels.Add(new LevelItem(50, "优秀学子", "🌳", "#22c55e"));
        levels.Add(new LevelItem(100, "学习达人", "🌟", "#f59e0b"));
        levels.Add(new LevelItem(200, "学习精英", "🏆", "#8b5cf6"));
        levels.Add(new LevelItem(350, "学习大师", "👑", "#ec4899"));
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<asp:HiddenField ID="HiddenLevelCount" runat="server" Value="0" />
<asp:HiddenField ID="HiddenLevelData" runat="server" Value="" />
<style>
/* === 积分等级设置 美化版 === */
.clm-page { max-width:1400px; padding:28px 32px 48px; font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }

/* 标题区 */
.clm-hd { display:flex; align-items:center; gap:20px; margin-bottom:28px; padding:24px 28px; background:linear-gradient(135deg,#fffbeb 0%,#fef3c7 55%,#fffdf7 100%); border:1.5px solid #fde68a; border-radius:20px; position:relative; overflow:hidden; }
.clm-hd::before { content:''; position:absolute; width:280px; height:280px; border-radius:50%; background:radial-gradient(circle,rgba(251,191,36,.13) 0%,transparent 70%); right:-60px; top:-60px; pointer-events:none; }
.clm-hd-icon { width:66px; height:66px; flex-shrink:0; background:linear-gradient(135deg,#d97706,#f59e0b); border-radius:18px; display:flex; align-items:center; justify-content:center; box-shadow:0 8px 24px rgba(245,158,11,.38); }
.clm-hd-body { flex:1; min-width:0; }
.clm-hd h1 { font-size:23px; font-weight:700; color:#0f172a; margin:0 0 5px; }
.clm-hd-desc { font-size:13px; color:#78716c; margin:0; line-height:1.5; }
.clm-hd-stats { flex-shrink:0; }
.clm-stat { text-align:center; padding:12px 22px; background:rgba(255,255,255,.75); border-radius:14px; border:1px solid rgba(253,230,138,.9); }
.clm-stat-num { font-size:28px; font-weight:700; color:#d97706; line-height:1; }
.clm-stat-lbl { font-size:11px; color:#92400e; margin-top:3px; opacity:.7; font-weight:500; }

/* 卡片 */
.clm-card { background:#fff; border-radius:18px; border:1px solid #e8ecf1; box-shadow:0 2px 12px rgba(0,0,0,.04); overflow:hidden; margin-bottom:22px; transition:box-shadow .2s; }
.clm-card:hover { box-shadow:0 4px 20px rgba(0,0,0,.07); }
.clm-card-hd { padding:16px 24px; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:12px; background:linear-gradient(135deg,#f8fafc,#fff); }
.clm-card-hd-icon { width:34px; height:34px; background:linear-gradient(135deg,#d97706,#f59e0b); border-radius:10px; display:flex; align-items:center; justify-content:center; box-shadow:0 3px 10px rgba(245,158,11,.28); flex-shrink:0; }
.clm-card-hd-title { font-size:15px; font-weight:600; color:#1e293b; }
.clm-card-bd { padding:24px; }

/* 预览网格 */
.clm-preview { display:grid; grid-template-columns:repeat(auto-fill,minmax(158px,1fr)); gap:16px; }
.clm-preview-item { padding:26px 14px 20px; border-radius:16px; border:2px solid; text-align:center; transition:all .25s cubic-bezier(.4,0,.2,1); position:relative; overflow:hidden; cursor:default; }
.clm-preview-item:hover { transform:translateY(-5px); }
.clm-preview-glow { position:absolute; top:-40px; right:-40px; width:120px; height:120px; border-radius:50%; filter:blur(22px); opacity:.15; pointer-events:none; }
.clm-preview-bar { position:absolute; bottom:0; left:0; right:0; height:3px; }
.clm-preview-badge { position:absolute; top:10px; left:10px; padding:2px 9px; border-radius:20px; font-size:10px; font-weight:700; color:#fff; line-height:1.7; letter-spacing:.3px; }
.clm-preview-icon { font-size:44px; margin-bottom:10px; line-height:1.2; display:block; }
.clm-preview-icon img { width:46px; height:46px; object-fit:contain; vertical-align:middle; }
.clm-preview-name { font-size:14.5px; font-weight:700; color:#1e293b; margin-bottom:5px; }
.clm-preview-score { font-size:11.5px; color:#94a3b8; }

/* 编辑表格 */
.clm-table { width:100%; border-collapse:collapse; }
.clm-table th { padding:11px 16px; font-size:11px; font-weight:700; color:#64748b; text-align:left; background:#f8fafc; border-bottom:2px solid #e8ecf1; text-transform:uppercase; letter-spacing:.6px; }
.clm-table td { padding:11px 16px; border-bottom:1px solid #f1f5f9; vertical-align:middle; }
.clm-table tr:last-child td { border-bottom:none; }
.clm-table tbody tr:hover { background:#fafbff; }
.clm-table input[type="text"], .clm-table input[type="number"] { height:40px; padding:0 13px; border:1.5px solid #e2e8f0; border-radius:10px; font-size:13.5px; font-family:inherit; outline:none; transition:all .2s; background:#f8fafc; }
.clm-table input:focus { border-color:#f59e0b; background:#fff; box-shadow:0 0 0 3px rgba(245,158,11,.1); }
.clm-table .clm-input-name { width:190px; }
.clm-table .clm-input-score { width:100px; }
.clm-table .clm-input-color { width:52px; height:40px; border:1.5px solid #e2e8f0; border-radius:10px; padding:2px; cursor:pointer; transition:border-color .2s; background:#f8fafc; }
.clm-table .clm-input-color:hover { border-color:#f59e0b; }
.clm-level-num { display:inline-flex; align-items:center; justify-content:center; width:30px; height:30px; border-radius:9px; background:linear-gradient(135deg,#d97706,#f59e0b); color:#fff; font-size:12px; font-weight:700; box-shadow:0 3px 8px rgba(245,158,11,.28); }
.clm-icon-cell { display:flex; align-items:center; gap:8px; }
.clm-icon-preview { width:42px; height:42px; border-radius:12px; border:1.5px solid #e5e7eb; display:flex; align-items:center; justify-content:center; font-size:24px; background:#f8fafc; flex-shrink:0; overflow:hidden; transition:all .2s; }
.clm-icon-preview:hover { border-color:#f59e0b; background:#fffbeb; }
.clm-icon-preview img { width:100%; height:100%; object-fit:contain; }
.clm-input-icon { width:82px; text-align:center; font-size:17px; }
.clm-btn-upload { width:40px; height:40px; border:1.5px dashed #fde68a; background:#fffbeb; border-radius:12px; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:all .2s; flex-shrink:0; color:#d97706; }
.clm-btn-upload:hover { background:#fef3c7; border-color:#fbbf24; transform:scale(1.06); }

/* 操作按钮 */
.clm-actions { display:flex; align-items:center; gap:12px; margin-top:22px; flex-wrap:wrap; padding-top:20px; border-top:1px solid #f1f5f9; }
.clm-btn-save { display:inline-flex; align-items:center; gap:8px; height:44px; padding:0 30px; background:linear-gradient(135deg,#d97706,#f59e0b); color:#fff; border:none; border-radius:12px; font-size:14.5px; font-family:inherit; font-weight:600; cursor:pointer; transition:all .2s; box-shadow:0 4px 14px rgba(245,158,11,.38); }
.clm-btn-save:hover { box-shadow:0 6px 22px rgba(245,158,11,.48); transform:translateY(-2px); }
.clm-btn-save:active { transform:translateY(0); }
.clm-btn-add { display:inline-flex; align-items:center; gap:7px; height:38px; padding:0 18px; background:#fffbeb; color:#d97706; border:1.5px solid #fde68a; border-radius:10px; font-size:13.5px; font-family:inherit; font-weight:600; cursor:pointer; transition:all .2s; }
.clm-btn-add:hover { background:#fef3c7; border-color:#fbbf24; transform:translateY(-1px); box-shadow:0 3px 10px rgba(245,158,11,.18); }
.clm-btn-del { width:32px; height:32px; border:none; background:#fef2f2; border-radius:9px; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:all .2s; color:#ef4444; }
.clm-btn-del:hover { background:#fee2e2; transform:scale(1.1); }
.clm-btn-reset { height:44px; padding:0 26px; background:#fff; color:#64748b; border:1.5px solid #e2e8f0; border-radius:12px; font-size:14.5px; font-family:inherit; font-weight:500; cursor:pointer; transition:all .2s; }
.clm-btn-reset:hover { background:#f8fafc; border-color:#cbd5e1; box-shadow:0 2px 8px rgba(0,0,0,.06); }
.clm-msg { font-size:13.5px; font-weight:600; padding:9px 16px; border-radius:10px; display:inline-flex; align-items:center; gap:6px; }

/* 提示区 */
.clm-tip { margin-top:20px; padding:18px 20px; background:linear-gradient(135deg,#fffbeb,#fef9ee); border:1.5px solid #fde68a; border-radius:14px; font-size:13px; color:#78716c; }
.clm-tip-row { display:flex; align-items:flex-start; gap:10px; line-height:1.75; }
.clm-tip-row + .clm-tip-row { margin-top:8px; }
.clm-tip-dot { width:6px; height:6px; border-radius:50%; background:#f59e0b; flex-shrink:0; margin-top:8px; }
.clm-tip strong { color:#d97706; font-weight:600; }
</style>
<input type="file" id="clmIconFileInput" accept="image/png,image/jpeg,image/gif,image/webp,image/svg+xml" style="display:none" />

<div class="clm-page">

    <!-- 标题区 -->
    <div class="clm-hd">
        <div class="clm-hd-icon">
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/>
            </svg>
        </div>
        <div class="clm-hd-body">
            <h1>积分等级设置</h1>
            <p class="clm-hd-desc">管理学分等级名称、图标和积分阈值，设置后同步到学生端展示</p>
        </div>
        <div class="clm-hd-stats">
            <div class="clm-stat">
                <div class="clm-stat-num" id="clmLevelCount">0</div>
                <div class="clm-stat-lbl">等级数量</div>
            </div>
        </div>
    </div>

    <!-- 预览 -->
    <div class="clm-card">
        <div class="clm-card-hd">
            <div class="clm-card-hd-icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                </svg>
            </div>
            <span class="clm-card-hd-title">等级预览</span>
        </div>
        <div class="clm-card-bd">
            <div class="clm-preview" id="previewArea"></div>
        </div>
    </div>

    <!-- 编辑 -->
    <div class="clm-card">
        <div class="clm-card-hd">
            <div class="clm-card-hd-icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/>
                    <line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>
                </svg>
            </div>
            <span class="clm-card-hd-title">等级配置</span>
            <button type="button" class="clm-btn-add" onclick="addLevel()" style="margin-left:auto;">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                新增等级
            </button>
        </div>
        <div class="clm-card-bd">
            <table class="clm-table">
                <thead>
                    <tr>
                        <th style="width:50px">序号</th>
                        <th style="width:210px">图标</th>
                        <th>等级名称</th>
                        <th style="width:120px">积分阈值</th>
                        <th style="width:70px">颜色</th>
                        <th style="width:50px">操作</th>
                    </tr>
                </thead>
                <tbody id="levelTableBody"></tbody>
            </table>

            <div class="clm-actions">
                <asp:Button ID="BtnSave" runat="server" Text="✔ 保存设置" CssClass="clm-btn-save" OnClick="BtnSave_Click" OnClientClick="return prepareSubmit();" />
                <asp:Button ID="BtnReset" runat="server" Text="恢复默认" CssClass="clm-btn-reset" OnClick="BtnReset_Click" OnClientClick="return confirm('确定要恢复默认等级设置吗？');" />
                <% if (!string.IsNullOrEmpty(saveMsg)) {
                   bool isSaveOk = (saveMsgColor == "#059669");
                %>
                <span class="clm-msg" style="color:<%= saveMsgColor %>;background:<%= isSaveOk ? "#f0fdf4" : "#fef2f2" %>;border:1px solid <%= isSaveOk ? "#bbf7d0" : "#fecaca" %>"><%= saveMsg %></span>
                <% } %>
            </div>

            <div class="clm-tip">
                <div class="clm-tip-row"><div class="clm-tip-dot"></div><div><strong>图标：</strong>支持直接输入 Emoji 表情符号，也可以点击上传按钮上传自定义图片（PNG/JPG/GIF/SVG，不超过 512KB）。</div></div>
                <div class="clm-tip-row"><div class="clm-tip-dot"></div><div><strong>积分阈值：</strong>表示达到该总学分后升级到对应等级，第一个等级建议设为 0（起始等级）。</div></div>
                <div class="clm-tip-row"><div class="clm-tip-dot"></div><div><strong>颜色：</strong>用于等级标签的展示颜色，设置后将同步应用到学生个人中心的积分等级页面。</div></div>
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
                { threshold: 0, name: '学习新手', icon: '🌱', color: '#94a3b8' },
                { threshold: 20, name: '勤奋学生', icon: '🌿', color: '#10b981' },
                { threshold: 50, name: '优秀学子', icon: '🌳', color: '#22c55e' },
                { threshold: 100, name: '学习达人', icon: '🌟', color: '#f59e0b' },
                { threshold: 200, name: '学习精英', icon: '🏆', color: '#8b5cf6' },
                { threshold: 350, name: '学习大师', icon: '👑', color: '#ec4899' }
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

    function renderTable() {
        var tbody = document.getElementById('levelTableBody');
        var svgUpload = '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>';
        var svgDel = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
        var html = '';
        for (var i = 0; i < levelData.length; i++) {
            var d = levelData[i];
            html += '<tr>'
                + '<td><span class="clm-level-num">' + (i + 1) + '</span></td>'
                + '<td><div class="clm-icon-cell">'
                +   '<div class="clm-icon-preview" id="iconPrev_' + i + '">' + renderIconHtml(d.icon, 28) + '</div>'
                +   '<input type="text" class="clm-input-icon" value="' + escHtml(d.icon) + '" onchange="updateField(' + i + ',\'icon\',this.value);updateIconPreview(' + i + ',this.value)" />'
                +   '<button type="button" class="clm-btn-upload" onclick="triggerUpload(' + i + ')" title="上传图片">' + svgUpload + '</button>'
                + '</div></td>'
                + '<td><input type="text" class="clm-input-name" value="' + escHtml(d.name) + '" onchange="updateField(' + i + ',\'name\',this.value)" /></td>'
                + '<td><input type="number" class="clm-input-score" value="' + d.threshold + '" min="0" onchange="updateField(' + i + ',\'threshold\',parseInt(this.value)||0)" /></td>'
                + '<td><input type="color" class="clm-input-color" value="' + d.color + '" onchange="updateField(' + i + ',\'color\',this.value)" /></td>'
                + '<td>' + (levelData.length > 1 ? '<button type="button" class="clm-btn-del" onclick="removeLevel(' + i + ')" title="删除">' + svgDel + '</button>' : '') + '</td>'
                + '</tr>';
        }
        tbody.innerHTML = html;
    }

    function updateIconPreview(idx, val) {
        var el = document.getElementById('iconPrev_' + idx);
        if (el) el.innerHTML = renderIconHtml(val, 28);
    }

    var uploadTargetIdx = -1;
    function triggerUpload(idx) {
        uploadTargetIdx = idx;
        document.getElementById('clmIconFileInput').click();
    }

    document.getElementById('clmIconFileInput').onchange = function() {
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
            var c = d.color;
            html += '<div class="clm-preview-item" style="border-color:' + c + '40;background:linear-gradient(145deg,' + c + '14 0%,#ffffff 65%);">'
                + '<div class="clm-preview-glow" style="background:' + c + ';"></div>'
                + '<div class="clm-preview-badge" style="background:' + c + ';box-shadow:0 2px 8px ' + c + '60;">Lv.' + (i + 1) + '</div>'
                + '<div class="clm-preview-icon">' + renderIconHtml(d.icon, 40) + '</div>'
                + '<div class="clm-preview-name">' + escHtml(d.name) + '</div>'
                + '<div class="clm-preview-score">' + (d.threshold === 0 ? '起始等级' : '&ge;&nbsp;' + d.threshold + '&nbsp;分') + '</div>'
                + '<div class="clm-preview-bar" style="background:linear-gradient(90deg,' + c + ',transparent);"></div>'
                + '</div>';
        }
        area.innerHTML = html;
        var statEl = document.getElementById('clmLevelCount');
        if (statEl) statEl.textContent = levelData.length;
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
                levelData[i].icon = inputs[0].value;
                levelData[i].name = inputs[1].value;
                levelData[i].threshold = parseInt(inputs[2].value) || 0;
                levelData[i].color = inputs[3].value;
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
