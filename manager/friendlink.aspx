<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    private string jsonPath;

    protected void Page_Load(object sender, EventArgs e)
    {
        jsonPath = Server.MapPath("~/App_Data/friendlinks.json");
        if (!IsPostBack)
        {
            LoadLinks();
        }
    }

    private void LoadLinks()
    {
        try
        {
            if (File.Exists(jsonPath))
            {
                string json = File.ReadAllText(jsonPath, System.Text.Encoding.UTF8);
                HiddenLinks.Value = json;
                return;
            }
        }
        catch { }
        HiddenLinks.Value = "[]";
    }

    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string dir = Path.GetDirectoryName(jsonPath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            string json = HiddenLinks.Value;
            if (string.IsNullOrEmpty(json)) json = "[]";
            File.WriteAllText(jsonPath, json, System.Text.Encoding.UTF8);

            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "&#10004; 友情链接已保存";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "保存失败: " + ex.Message;
        }
    }

    protected string GetLinksJson()
    {
        if (!string.IsNullOrEmpty(HiddenLinks.Value))
            return HiddenLinks.Value;
        return "[]";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .fl-page { max-width:100%; padding:28px 32px 40px; font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .fl-hd { display:flex; align-items:center; gap:16px; margin-bottom:28px; }
    .fl-hd-icon { width:48px; height:48px; background:linear-gradient(135deg,#3b82f6,#2563eb); border-radius:14px; display:flex; align-items:center; justify-content:center; box-shadow:0 4px 12px rgba(59,130,246,.25); flex-shrink:0; }
    .fl-hd-icon svg { width:26px; height:26px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .fl-hd h1 { font-size:22px; font-weight:700; color:#0f172a; margin:0 0 2px; }
    .fl-hd p { font-size:13px; color:#94a3b8; margin:0; }

    .fl-grid { display:grid; grid-template-columns:1fr 320px; gap:20px; }
    @media (max-width:960px) { .fl-grid { grid-template-columns:1fr; } }

    .fl-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:20px; }
    .fl-card:hover { box-shadow:0 8px 24px rgba(0,0,0,.07); }
    .fl-card-hd { padding:16px 22px; font-size:15px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:12px; }
    .fl-card-hd .ci { width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
    .fl-card-hd .ci svg { width:19px; height:19px; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; fill:none; }
    .ci.blue { background:#eff6ff; } .ci.blue svg { stroke:#3b82f6; }
    .ci.emerald { background:#ecfdf5; } .ci.emerald svg { stroke:#10b981; }
    .fl-card-bd { padding:22px; }

    /* Add form */
    .fl-add-form { display:flex; gap:10px; align-items:flex-end; flex-wrap:wrap; margin-bottom:20px; padding:18px; background:#f8fafc; border-radius:12px; border:1px solid #e2e8f0; }
    .fl-field { display:flex; flex-direction:column; gap:4px; }
    .fl-field label { font-size:12px; font-weight:600; color:#64748b; }
    .fl-field input[type="text"] {
        height:38px; padding:0 14px; border:1.5px solid #e2e8f0; border-radius:9px;
        font-size:13.5px; font-family:inherit; outline:none; background:#fff;
        transition: border-color .2s, box-shadow .2s;
    }
    .fl-field input[type="text"]:focus { border-color:#3b82f6; box-shadow:0 0 0 3px rgba(59,130,246,.08); }
    .fl-field input.fl-name { width:180px; }
    .fl-field input.fl-url { width:320px; }
    .btn-add {
        display:inline-flex; align-items:center; justify-content:center; gap:6px;
        height:38px; padding:0 20px;
        background:linear-gradient(135deg,#3b82f6,#2563eb); color:#fff;
        border:none; border-radius:9px; font-size:13px; font-family:inherit; font-weight:600;
        cursor:pointer; transition:all .2s; box-shadow:0 2px 6px rgba(59,130,246,.3);
    }
    .btn-add:hover { box-shadow:0 4px 14px rgba(59,130,246,.4); transform:translateY(-1px); }

    /* Links table */
    .fl-empty { text-align:center; padding:40px 20px; color:#94a3b8; font-size:14px; }
    .fl-empty svg { width:48px; height:48px; stroke:#d1d5db; fill:none; stroke-width:1.5; stroke-linecap:round; stroke-linejoin:round; margin-bottom:12px; }

    .fl-list { list-style:none; padding:0; margin:0; }
    .fl-item {
        display:flex; align-items:center; gap:14px; padding:14px 16px;
        border-radius:12px; margin-bottom:8px; border:1px solid #f1f5f9;
        transition: all .2s; background:#fff;
    }
    .fl-item:hover { border-color:#bfdbfe; background:#f0f9ff; }
    .fl-item-num { width:28px; height:28px; border-radius:8px; background:linear-gradient(135deg,#dbeafe,#bfdbfe); display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; color:#1d4ed8; flex-shrink:0; }
    .fl-item-info { flex:1; min-width:0; }
    .fl-item-name { font-size:14px; font-weight:600; color:#1e293b; margin-bottom:2px; }
    .fl-item-url { font-size:12px; color:#94a3b8; word-break:break-all; }
    .fl-item-url a { color:#3b82f6; text-decoration:none; }
    .fl-item-url a:hover { text-decoration:underline; }
    .btn-del {
        width:30px; height:30px; border:none; background:#fef2f2; border-radius:8px;
        display:flex; align-items:center; justify-content:center; cursor:pointer;
        transition:all .15s; flex-shrink:0;
    }
    .btn-del:hover { background:#fee2e2; }
    .btn-del svg { width:16px; height:16px; stroke:#ef4444; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }

    /* Actions */
    .fl-actions { padding:16px 22px; border-top:1px solid #f1f5f9; display:flex; align-items:center; gap:14px; }
    .btn-save {
        display:inline-flex; align-items:center; justify-content:center; gap:6px;
        height:40px; padding:0 28px;
        background:linear-gradient(135deg,#3b82f6,#2563eb); color:#fff!important;
        border:none; border-radius:10px; font-size:14px; font-family:inherit; font-weight:600;
        cursor:pointer; transition:all .2s; box-shadow:0 2px 8px rgba(59,130,246,.3);
    }
    .btn-save:hover { box-shadow:0 4px 16px rgba(59,130,246,.4); transform:translateY(-1px); }
    .fl-msg { font-size:13px; }
    .fl-count { font-size:13px; color:#64748b; margin-left:auto; }
    .fl-count strong { color:#3b82f6; font-weight:700; }

    /* Side */
    .fl-side-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:16px; }
    .fl-side-hd { padding:14px 18px; font-size:14px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:10px; }
    .fl-side-bd { padding:16px 18px; font-size:13px; color:#64748b; line-height:2; }
    .fl-side-bd li { margin-bottom:4px; }

    .fl-tip-card { background:linear-gradient(135deg,#eff6ff,#dbeafe); border:1px solid #bfdbfe; border-radius:14px; padding:18px; }
    .fl-tip-card h4 { font-size:14px; color:#1e40af; margin:0 0 8px; display:flex; align-items:center; gap:8px; }
    .fl-tip-card p { font-size:12.5px; color:#1e40af; line-height:1.8; margin:0; opacity:.8; }
</style>

<div class="fl-page">
    <div class="fl-hd">
        <div class="fl-hd-icon"><svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg></div>
        <div><h1>友情链接设置</h1><p>管理网站底部展示的友情链接，添加后保存即可生效</p></div>
    </div>

    <asp:HiddenField ID="HiddenLinks" runat="server" Value="[]" />

    <div class="fl-grid">
        <div>
            <div class="fl-card">
                <div class="fl-card-hd">
                    <span class="ci blue"><svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg></span>
                    链接列表
                    <span class="fl-count">共 <strong id="linkCountSpan">0</strong> 个链接</span>
                </div>
                <div class="fl-card-bd">
                    <!-- Add form -->
                    <div class="fl-add-form">
                        <div class="fl-field">
                            <label>链接名称</label>
                            <input type="text" id="inputName" class="fl-name" placeholder="如：教育资源网" />
                        </div>
                        <div class="fl-field">
                            <label>链接地址</label>
                            <input type="text" id="inputUrl" class="fl-url" placeholder="https://example.com" />
                        </div>
                        <button type="button" class="btn-add" onclick="addLink()">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            添加
                        </button>
                    </div>

                    <!-- Links list -->
                    <div id="linksList"></div>
                </div>
                <div class="fl-actions">
                    <asp:Button ID="BtnSave" runat="server" Text="保存链接" CssClass="btn-save" OnClick="BtnSave_Click" OnClientClick="syncToHidden();" />
                    <span class="fl-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></span>
                </div>
            </div>
        </div>

        <div>
            <div class="fl-side-card">
                <div class="fl-side-hd">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    使用说明
                </div>
                <div class="fl-side-bd">
                    <ul style="padding-left:16px;">
                        <li>输入链接名称和完整URL地址</li>
                        <li>点击"添加"按钮加入列表</li>
                        <li>点击链接右侧的删除按钮可移除</li>
                        <li>修改完成后点击<strong>保存链接</strong></li>
                        <li>链接将展示在网站底部区域</li>
                    </ul>
                </div>
            </div>

            <div class="fl-tip-card">
                <h4>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1e40af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    温馨提示
                </h4>
                <p>友情链接有助于增强网站之间的互联互通。建议添加教育类相关网站链接，确保链接安全有效。</p>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
(function() {
    var links = [];
    var hiddenId = '<%= HiddenLinks.ClientID %>';

    // Load initial data
    try {
        var raw = document.getElementById(hiddenId).value;
        if (raw) links = JSON.parse(raw);
        if (!Array.isArray(links)) links = [];
    } catch(e) { links = []; }

    function render() {
        var container = document.getElementById('linksList');
        var countEl = document.getElementById('linkCountSpan');
        countEl.textContent = links.length;

        if (links.length === 0) {
            container.innerHTML = '<div class="fl-empty"><svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg><br/>暂无友情链接，请添加</div>';
            return;
        }

        var html = '<div class="fl-list">';
        for (var i = 0; i < links.length; i++) {
            var lk = links[i];
            var safeName = (lk.name || '').replace(/</g,'&lt;').replace(/>/g,'&gt;');
            var safeUrl = (lk.url || '').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
            html += '<div class="fl-item">';
            html += '<span class="fl-item-num">' + (i+1) + '</span>';
            html += '<div class="fl-item-info"><div class="fl-item-name">' + safeName + '</div>';
            html += '<div class="fl-item-url"><a href="' + safeUrl + '" target="_blank">' + safeUrl + '</a></div></div>';
            html += '<button type="button" class="btn-del" onclick="window._flDel(' + i + ')" title="删除"><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>';
            html += '</div>';
        }
        html += '</div>';
        container.innerHTML = html;
    }

    window.addLink = function() {
        var nameEl = document.getElementById('inputName');
        var urlEl = document.getElementById('inputUrl');
        var name = nameEl.value.trim();
        var url = urlEl.value.trim();

        if (!name) { nameEl.focus(); return; }
        if (!url) { urlEl.focus(); return; }
        if (url.indexOf('http') !== 0) url = 'https://' + url;

        links.push({ name: name, url: url });
        nameEl.value = '';
        urlEl.value = '';
        nameEl.focus();
        render();
    };

    window._flDel = function(idx) {
        if (idx >= 0 && idx < links.length) {
            links.splice(idx, 1);
            render();
        }
    };

    window.syncToHidden = function() {
        document.getElementById(hiddenId).value = JSON.stringify(links);
    };

    // Enter key support
    document.getElementById('inputName').addEventListener('keypress', function(e) { if (e.key === 'Enter') { e.preventDefault(); document.getElementById('inputUrl').focus(); } });
    document.getElementById('inputUrl').addEventListener('keypress', function(e) { if (e.key === 'Enter') { e.preventDefault(); window.addLink(); } });

    render();
})();
</script>
</asp:Content>
