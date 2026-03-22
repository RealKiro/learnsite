<%@ Page Title="宠物换装设置" Language="C#" MasterPageFile="~/teacher/Teach.master"
    AutoEventWireup="true" Inherits="System.Web.UI.Page" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    protected string GetCostumesJson()
    {
        string fpath = Server.MapPath("~/App_Data/petcostumes.json");
        try {
            if (File.Exists(fpath))
                return File.ReadAllText(fpath, System.Text.Encoding.UTF8);
        } catch {}
        return "{\"costumes\":[]}";
    }

    protected string GetCostumeImagesJson()
    {
        string[] ids  = { "costume_sunglasses","costume_hat","costume_bow","costume_star","costume_ghost","costume_crown","costume_wings" };
        string[] exts = { ".png",".jpg",".jpeg",".gif",".webp" };
        System.Text.StringBuilder sb = new System.Text.StringBuilder("{");
        bool first = true;
        foreach (string id in ids)
        {
            foreach (string ext in exts)
            {
                string fpath = Server.MapPath("~/images/costumes/" + id + ext);
                if (File.Exists(fpath))
                {
                    string url = ResolveUrl("~/images/costumes/" + id + ext)
                                 + "?v=" + File.GetLastWriteTime(fpath).Ticks.ToString();
                    if (!first) sb.Append(",");
                    sb.Append("\"" + id + "\":\"" + url + "\"");
                    first = false;
                    break;
                }
            }
        }
        sb.Append("}");
        return sb.ToString();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
.pc { max-width: 100%; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

/* ── 页头 banner ── */
.pc-hd {
    display: flex; align-items: center; gap: 16px; margin-bottom: 18px;
    background: linear-gradient(135deg, #fff0f9 0%, #fdf4ff 55%, #eff6ff 100%);
    border: 1px solid #fce7f3; border-radius: 14px;
    padding: 18px 22px; box-shadow: 0 2px 14px rgba(236,72,153,.07);
    position: relative; overflow: hidden;
}
.pc-hd::after {
    content: ''; position: absolute; right: -24px; top: -24px;
    width: 130px; height: 130px; border-radius: 50%;
    background: radial-gradient(circle, rgba(244,114,182,.18) 0%, transparent 70%);
    pointer-events: none;
}
.pc-hd-icon {
    width: 48px; height: 48px; border-radius: 12px; flex-shrink: 0;
    background: linear-gradient(135deg,#ec4899,#f472b6);
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 4px 14px rgba(236,72,153,.38);
}
.pc-hd-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.pc-hd-text h1 { font-size: 20px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
.pc-hd-text p  { font-size: 13px; color: #94a3b8; margin: 0; }

/* ── 说明卡 ── */
.pc-tip {
    background: linear-gradient(135deg, #eff6ff, #fdf4ff);
    border: 1px solid #bfdbfe; border-left: 3px solid #60a5fa;
    border-radius: 10px; padding: 11px 16px; font-size: 12px; color: #1e40af;
    margin-bottom: 14px; line-height: 1.75;
}

/* ── 操作条 ── */
.pc-toolbar {
    display: flex; align-items: center; justify-content: flex-end;
    margin-bottom: 14px; gap: 10px;
    background: #fff; border: 1px solid #f0e6fb;
    border-radius: 10px; padding: 9px 14px;
    box-shadow: 0 1px 4px rgba(0,0,0,.04);
}
.pc-toolbar-info { flex: 1; font-size: 12px; color: #94a3b8; }
.pc-toolbar-info strong { color: #ec4899; font-weight: 700; }
.pc-save-btn {
    padding: 8px 22px; border-radius: 8px; font-size: 13px; font-weight: 600;
    background: linear-gradient(135deg,#ec4899,#f472b6); color: #fff; border: none;
    cursor: pointer; font-family: inherit; box-shadow: 0 2px 10px rgba(236,72,153,.32);
    transition: all .15s; display: flex; align-items: center; gap: 6px;
}
.pc-save-btn:hover { box-shadow: 0 4px 16px rgba(236,72,153,.45); transform: translateY(-1px); }
.pc-save-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; }

/* ── 换装网格 ── */
.pc-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 12px; }

/* ── 换装卡片 ── */
.pc-card {
    background: #fff; border-radius: 12px; border: 1px solid #ede9f6;
    box-shadow: 0 2px 8px rgba(236,72,153,.05);
    display: flex; flex-direction: column; overflow: hidden;
    transition: transform .18s, box-shadow .18s, border-color .18s;
    position: relative;
}
.pc-card::before {
    content: ''; display: block; height: 3px; flex-shrink: 0;
    background: linear-gradient(90deg, #ec4899 0%, #a78bfa 100%);
}
.pc-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(236,72,153,.14);
    border-color: #fbcfe8;
}
.pc-card-hd { padding: 8px 10px 0; display: flex; align-items: center; gap: 6px; }
.pc-card-ico {
    width: 28px; height: 28px; border-radius: 8px;
    background: linear-gradient(135deg,#fdf4ff,#fce7f3);
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    box-shadow: 0 1px 4px rgba(236,72,153,.15);
}
.pc-card-ico svg { width: 15px; height: 15px; stroke: #ec4899; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.pc-card-id {
    font-size: 9px; color: #a855f7; flex: 1;
    overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    background: #fdf4ff; border-radius: 4px; padding: 1px 5px;
    border: 1px solid #f3e8ff;
}

/* ── 图片预览区 ── */
.pc-img-wrap {
    margin: 8px 10px 6px; width: calc(100% - 20px); aspect-ratio: 1 / 1;
    border-radius: 8px; border: 2px dashed #e2e8f0;
    background: linear-gradient(135deg, #fafafa 0%, #fdf4ff 100%);
    overflow: hidden; display: flex; align-items: center; justify-content: center;
    cursor: pointer; transition: all .2s; position: relative;
}
.pc-img-wrap:hover { border-color: #f472b6; background: linear-gradient(135deg,#fff0f9,#fdf4ff); }
.pc-img-wrap.has-img { border-style: solid; border-color: #fbcfe8; background: #fff; }
.pc-img-wrap img { width: 100%; height: 100%; object-fit: contain; display: block; }
.pc-img-placeholder { display: flex; flex-direction: column; align-items: center; gap: 5px; }
.pc-img-placeholder svg { width: 22px; height: 22px; stroke: #d1d5db; fill: none; stroke-width: 1.5; transition: stroke .2s; }
.pc-img-placeholder span { font-size: 10px; color: #d1d5db; }
.pc-img-wrap:hover .pc-img-placeholder svg { stroke: #f472b6; }
.pc-img-wrap:hover .pc-img-placeholder span { color: #f472b6; }

/* ── 表单区 ── */
.pc-form { padding: 3px 10px 10px; display: flex; flex-direction: column; gap: 6px; flex: 1; }
.pc-field { display: flex; flex-direction: column; gap: 2px; }
.pc-label { font-size: 10px; font-weight: 600; color: #64748b; letter-spacing: .3px; }
.pc-input {
    padding: 4px 7px; border: 1.5px solid #e8ecf1; border-radius: 7px;
    font-size: 12px; font-family: inherit; outline: none; transition: all .15s;
    width: 100%; box-sizing: border-box; color: #1e293b; background: #f8fafc;
}
.pc-input:focus { border-color: #f472b6; background: #fff; box-shadow: 0 0 0 3px rgba(244,114,182,.1); }
.pc-input-row { display: flex; gap: 5px; }
.pc-input-row .pc-field { flex: 1; }
.pc-select {
    padding: 4px 7px; border: 1.5px solid #e8ecf1; border-radius: 7px;
    font-size: 12px; font-family: inherit; outline: none; transition: all .15s;
    width: 100%; box-sizing: border-box; background: #f8fafc; cursor: pointer; color: #1e293b;
}
.pc-select:focus { border-color: #f472b6; background: #fff; box-shadow: 0 0 0 3px rgba(244,114,182,.1); }

/* ── 图片按钮 ── */
.pc-img-btns { display: flex; gap: 4px; }
.pc-btn {
    flex: 1; padding: 4px 0; border-radius: 6px; font-size: 10px; font-weight: 600;
    font-family: inherit; cursor: pointer; transition: all .15s; border: 1.5px solid; text-align: center;
}
.pc-btn-upload {
    background: linear-gradient(135deg,#f5f3ff,#fdf4ff); color: #7c3aed; border-color: #ddd6fe;
}
.pc-btn-upload:hover { background: linear-gradient(135deg,#ede9fe,#fce7f3); border-color: #a78bfa; }
.pc-btn-del { background: #fff; color: #dc2626; border-color: #fecaca; }
.pc-btn-del:hover { background: #fef2f2; border-color: #fca5a5; }

/* === Popup Notification === */
.pc-noti-overlay {
    position: fixed; top: 0; right: 0; bottom: 0; left: 0;
    width: 100vw; height: 100vh; z-index: 99998;
    background: rgba(0,0,0,.32); backdrop-filter: blur(2px);
    display: flex; align-items: center; justify-content: center;
    opacity: 0; pointer-events: none; transition: opacity .22s ease;
}
.pc-noti-overlay.show { opacity: 1; pointer-events: auto; }
.pc-noti {
    width: 300px; max-width: 88vw;
    background: #fff; border-radius: 16px;
    box-shadow: 0 20px 60px rgba(0,0,0,.22);
    padding: 32px 24px 24px; text-align: center;
    transform: scale(.85);
    transition: transform .25s cubic-bezier(.34,1.4,.64,1);
}
.pc-noti-overlay.show .pc-noti { transform: scale(1); }
.pc-noti.ok  { border-top: 4px solid #22c55e; }
.pc-noti.err { border-top: 4px solid #ef4444; }
.pc-noti-ico {
    width: 52px; height: 52px; border-radius: 50%;
    margin: 0 auto 14px; display: flex; align-items: center; justify-content: center;
}
.pc-noti.ok  .pc-noti-ico { background: #dcfce7; }
.pc-noti.err .pc-noti-ico { background: #fee2e2; }
.pc-noti-ico svg { width: 26px; height: 26px; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
.pc-noti.ok  .pc-noti-ico svg { stroke: #16a34a; }
.pc-noti.err .pc-noti-ico svg { stroke: #dc2626; }
.pc-noti-title { text-align: center; font-size: 16px; font-weight: 700; margin-bottom: 8px; }
.pc-noti.ok  .pc-noti-title { color: #166534; }
.pc-noti.err .pc-noti-title { color: #991b1b; }
.pc-noti-msg {
    text-align: center; font-size: 14px; color: #475569;
    line-height: 1.6; margin-bottom: 16px;
    word-break: break-word; white-space: pre-line;
    max-height: 140px; overflow-y: auto;
}
.pc-noti-bar { height: 4px; background: #f1f5f9; border-radius: 999px; overflow: hidden; margin-bottom: 14px; }
.pc-noti-bar-fill { height: 100%; border-radius: 999px; width: 100%; }
.pc-noti.ok  .pc-noti-bar-fill { background: #22c55e; }
.pc-noti.err .pc-noti-bar-fill { background: #ef4444; }
.pc-noti-btn {
    display: block; width: 100%; padding: 10px; border-radius: 10px;
    border: none; font-size: 14px; font-weight: 600;
    cursor: pointer; font-family: inherit; transition: all .15s;
}
.pc-noti.ok  .pc-noti-btn { background: #f0fdf4; color: #166534; }
.pc-noti.ok  .pc-noti-btn:hover { background: #dcfce7; }
.pc-noti.err .pc-noti-btn { background: #fff1f2; color: #991b1b; }
.pc-noti.err .pc-noti-btn:hover { background: #fee2e2; }

@media (max-width: 1100px) {
    .pc-grid { grid-template-columns: repeat(4, 1fr); }
}
@media (max-width: 800px) {
    .pc-grid { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 540px) {
    .pc-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>

<div class="pc">

    <div class="pc-hd">
        <div class="pc-hd-icon">
            <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
        </div>
        <div class="pc-hd-text">
            <h1>宠物换装设置</h1>
            <p>配置换装道具的名称、学分消耗、解锁等级，并可上传自定义图标</p>
        </div>
    </div>

    <div class="pc-tip">
        💡 <strong>说明：</strong>修改名称、学分、解锁等级后点击右上角「保存设置」生效；
        点击图片预览区或「上传图」可为每件换装上传自定义图标（PNG/JPG/GIF/WebP，≤2MB）；
        图标删除后将自动恢复为内置 SVG 图标。
    </div>

    <div class="pc-toolbar">
        <span class="pc-toolbar-info">共 <strong>7</strong> 件换装道具，修改后点击保存生效</span>
        <button type="button" class="pc-save-btn" onclick="saveSettings()">
            <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            保存设置
        </button>
    </div>

    <div class="pc-grid" id="cstGrid"></div>

</div>

<input type="file" id="pcFileInput" accept="image/png,image/jpeg,image/gif,image/webp" style="display:none">
<div id="pcNotiOverlay" class="pc-noti-overlay" onclick="if(event.target===this)closeNoti()">
    <div id="pcNoti" class="pc-noti">
        <div class="pc-noti-ico" id="pcNotiIco"></div>
        <div class="pc-noti-title" id="pcNotiTitle"></div>
        <div class="pc-noti-msg" id="pcNotiMsg"></div>
        <div class="pc-noti-bar"><div class="pc-noti-bar-fill" id="pcNotiBarFill"></div></div>
        <button class="pc-noti-btn" onclick="closeNoti()">确认</button>
    </div>
</div>

<script type="text/javascript">
var COSTUME_CFG = <%=GetCostumesJson()%>;
var COSTUME_IMG = <%=GetCostumeImagesJson()%>;

var CST_DEFS = [
    { id:"costume_sunglasses", defaultName:"\u9177\u70ab\u58a8\u955c", defaultCost:30, defaultLv:2, svgKey:"sunglasses" },
    { id:"costume_hat",        defaultName:"\u7ecd\u58eb\u793c\u5e3d", defaultCost:40, defaultLv:2, svgKey:"hat" },
    { id:"costume_bow",        defaultName:"\u5143\u6c14\u8774\u8776\u7ed3", defaultCost:35, defaultLv:2, svgKey:"bow" },
    { id:"costume_star",       defaultName:"\u6d41\u661f\u62ab\u98ce", defaultCost:50, defaultLv:3, svgKey:"star" },
    { id:"costume_ghost",      defaultName:"\u5357\u74dc\u5e7d\u7075", defaultCost:60, defaultLv:3, svgKey:"ghost" },
    { id:"costume_crown",      defaultName:"\u738b\u8005\u7687\u51a0", defaultCost:80, defaultLv:4, svgKey:"crown" },
    { id:"costume_wings",      defaultName:"\u5929\u4f7f\u7fc5\u818a", defaultCost:100, defaultLv:4, svgKey:"wings" }
];

function iconSvg(k) {
    switch (k) {
        case "sunglasses": return '<svg viewBox="0 0 24 24"><rect x="3" y="9" width="7" height="4" rx="1"/><rect x="14" y="9" width="7" height="4" rx="1"/><path d="M10 11h4"/></svg>';
        case "hat":        return '<svg viewBox="0 0 24 24"><path d="M5 18h14"/><path d="M7 18l2-8h6l2 8"/><path d="M10 10V7h4v3"/></svg>';
        case "bow":        return '<svg viewBox="0 0 24 24"><path d="M12 12l-6-4a3 3 0 1 0 0 8z"/><path d="M12 12l6-4a3 3 0 1 1 0 8z"/><circle cx="12" cy="12" r="1.5"/></svg>';
        case "star":       return '<svg viewBox="0 0 24 24"><polygon points="12 3 15 9 22 10 17 14 18 21 12 18 6 21 7 14 2 10 9 9 12 3"/></svg>';
        case "ghost":      return '<svg viewBox="0 0 24 24"><path d="M5 18V9a7 7 0 0 1 14 0v9l-3-2-2 2-2-2-2 2-2-2z"/><circle cx="10" cy="10" r="1"/><circle cx="14" cy="10" r="1"/></svg>';
        case "crown":      return '<svg viewBox="0 0 24 24"><path d="M3 18h18l-2-8-4 3-3-5-3 5-4-3z"/></svg>';
        case "wings":      return '<svg viewBox="0 0 24 24"><path d="M12 13c-2-4-6-6-9-6 0 4 2 8 7 9"/><path d="M12 13c2-4 6-6 9-6 0 4-2 8-7 9"/><path d="M12 13v7"/></svg>';
        default:           return '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/></svg>';
    }
}

// Merge server config into CST_DEFS
var _cfg = {};
if (COSTUME_CFG && Array.isArray(COSTUME_CFG.costumes)) {
    for (var ci = 0; ci < COSTUME_CFG.costumes.length; ci++) {
        var c = COSTUME_CFG.costumes[ci];
        if (c && c.id) _cfg[c.id] = c;
    }
}

var _uploadId = null;

function getVal(id, field) {
    var def = null;
    for (var i = 0; i < CST_DEFS.length; i++) if (CST_DEFS[i].id === id) { def = CST_DEFS[i]; break; }
    if (!def) return '';
    if (_cfg[id] && _cfg[id][field] !== undefined && _cfg[id][field] !== null && _cfg[id][field] !== '')
        return _cfg[id][field];
    if (field === 'name')   return def.defaultName;
    if (field === 'cost')   return def.defaultCost;
    if (field === 'needLv') return def.defaultLv;
    return '';
}

function esc(s) {
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function renderGrid() {
    var el = document.getElementById('cstGrid');
    var html = '';
    for (var i = 0; i < CST_DEFS.length; i++) {
        var d   = CST_DEFS[i];
        var cid = d.id;
        var nm  = getVal(cid, 'name');
        var co  = getVal(cid, 'cost');
        var lv  = getVal(cid, 'needLv');
        var img = COSTUME_IMG && COSTUME_IMG[cid] ? COSTUME_IMG[cid] : null;
        var hasImg = img ? ' has-img' : '';
        var shortId = cid.replace('costume_', '');

        html += '<div class="pc-card" id="card_' + cid + '">';

        // Card header
        html += '<div class="pc-card-hd">'
              + '<div class="pc-card-ico">' + iconSvg(d.svgKey) + '</div>'
              + '<span class="pc-card-id">' + esc(shortId) + '</span>'
              + '</div>';

        // Image preview
        html += '<div class="pc-img-wrap' + hasImg + '" id="imgwrap_' + cid + '" onclick="triggerUpload(\'' + cid + '\')">';
        if (img) {
            html += '<img id="img_' + cid + '" src="' + esc(img) + '" alt="">';
        } else {
            html += '<div class="pc-img-placeholder">'
                  + '<svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>'
                  + '<polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>'
                  + '<span>点击上传</span>'
                  + '</div>';
        }
        html += '</div>';

        // Form
        html += '<div class="pc-form">';

        // Name
        html += '<div class="pc-field">'
              + '<span class="pc-label">换装名称</span>'
              + '<input type="text" class="pc-input" id="nm_' + cid + '" value="' + esc(nm) + '" maxlength="20">'
              + '</div>';

        // Cost + Level row
        html += '<div class="pc-input-row">';
        html += '<div class="pc-field">'
              + '<span class="pc-label">学分消耗</span>'
              + '<input type="number" class="pc-input" id="co_' + cid + '" value="' + esc(co) + '" min="1" max="9999" style="width:100%;">'
              + '</div>';
        html += '<div class="pc-field">'
              + '<span class="pc-label">解锁等级</span>'
              + '<select class="pc-select" id="lv_' + cid + '">'
              + '<option value="2"' + (lv == 2 ? ' selected' : '') + '>Lv2</option>'
              + '<option value="3"' + (lv == 3 ? ' selected' : '') + '>Lv3</option>'
              + '<option value="4"' + (lv == 4 ? ' selected' : '') + '>Lv4</option>'
              + '</select>'
              + '</div>';
        html += '</div>';

        // Image buttons
        html += '<div class="pc-img-btns">'
              + '<button type="button" class="pc-btn pc-btn-upload" onclick="triggerUpload(\'' + cid + '\')">上传图</button>'
              + '<button type="button" class="pc-btn pc-btn-del" id="delbtn_' + cid + '" onclick="deleteImg(\'' + cid + '\')"'
              + (img ? '' : ' style="display:none"') + '>删除图</button>'
              + '</div>';

        html += '</div>'; // .pc-form
        html += '</div>'; // .pc-card
    }
    el.innerHTML = html;
}

function triggerUpload(cid) {
    _uploadId = cid;
    var fi = document.getElementById('pcFileInput');
    fi.value = '';
    fi.click();
}

document.getElementById('pcFileInput').onchange = function() {
    var file = this.files[0];
    if (!file || !_uploadId) return;
    var cid = _uploadId;
    var fd = new FormData();
    fd.append('file', file);
    fd.append('costumeId', cid);
    fd.append('action', 'upload');
    fetch('petcosupl.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (!res || !res.success) { toast((res && res.msg) ? res.msg : '上传失败', true); return; }
            if (!COSTUME_IMG) COSTUME_IMG = {};
            COSTUME_IMG[cid] = res.url;
            var wrap = document.getElementById('imgwrap_' + cid);
            if (wrap) {
                wrap.className = 'pc-img-wrap has-img';
                wrap.innerHTML = '<img id="img_' + cid + '" src="' + esc(res.url) + '" alt="">';
            }
            var db = document.getElementById('delbtn_' + cid);
            if (db) db.style.display = '';
            toast('图片上传成功 ✅');
        })
        .catch(function() { toast('网络错误，上传失败', true); });
};

function deleteImg(cid) {
    if (!confirm('确定要删除该换装图片吗？')) return;
    var fd = new FormData();
    fd.append('costumeId', cid);
    fd.append('action', 'delete');
    fetch('petcosupl.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (!res || !res.success) { toast((res && res.msg) ? res.msg : '删除失败', true); return; }
            if (COSTUME_IMG) delete COSTUME_IMG[cid];
            var wrap = document.getElementById('imgwrap_' + cid);
            if (wrap) {
                wrap.className = 'pc-img-wrap';
                wrap.innerHTML = '<div class="pc-img-placeholder">'
                    + '<svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>'
                    + '<polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>'
                    + '<span>点击上传</span>'
                    + '</div>';
            }
            var db = document.getElementById('delbtn_' + cid);
            if (db) db.style.display = 'none';
            toast('图片已删除');
        })
        .catch(function() { toast('网络错误，删除失败', true); });
}

function saveSettings() {
    var costumes = [];
    for (var i = 0; i < CST_DEFS.length; i++) {
        var cid = CST_DEFS[i].id;
        var nmEl = document.getElementById('nm_' + cid);
        var coEl = document.getElementById('co_' + cid);
        var lvEl = document.getElementById('lv_' + cid);
        var nm = nmEl ? nmEl.value.trim() : CST_DEFS[i].defaultName;
        var co = coEl ? parseInt(coEl.value, 10) : CST_DEFS[i].defaultCost;
        var lv = lvEl ? parseInt(lvEl.value, 10) : CST_DEFS[i].defaultLv;
        if (!nm) nm = CST_DEFS[i].defaultName;
        if (isNaN(co) || co < 1) co = 1;
        if (co > 9999) co = 9999;
        if (lv !== 2 && lv !== 3 && lv !== 4) lv = 2;
        costumes.push({ id: cid, name: nm, cost: co, needLv: lv });
    }
    var json = JSON.stringify({ costumes: costumes });
    var fd = new FormData();
    fd.append('json', json);
    fetch('petcostumesave.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res && res.success) {
                _cfg = {};
                for (var i = 0; i < costumes.length; i++) _cfg[costumes[i].id] = costumes[i];
                COSTUME_CFG = { costumes: costumes };
                toast('换装设置已保存 ✅');
            } else {
                toast((res && res.msg) ? res.msg : '保存失败', true);
            }
        })
        .catch(function() { toast('网络错误，保存失败', true); });
}

var _pcNotiT = null;
function toast(msg, isErr) {
    var overlay = document.getElementById('pcNotiOverlay');
    var popup   = document.getElementById('pcNoti');
    // Ensure overlay is at document.body level and force full-viewport inline styles
    if (overlay) {
        if (overlay.parentNode !== document.body) document.body.appendChild(overlay);
        overlay.style.setProperty('position','fixed','important');
        overlay.style.setProperty('top','0','important');
        overlay.style.setProperty('left','0','important');
        overlay.style.setProperty('right','0','important');
        overlay.style.setProperty('bottom','0','important');
        overlay.style.setProperty('width','100vw','important');
        overlay.style.setProperty('height','100vh','important');
        overlay.style.setProperty('display','flex','important');
        overlay.style.setProperty('align-items','center','important');
        overlay.style.setProperty('justify-content','center','important');
    }
    var icoEl   = document.getElementById('pcNotiIco');
    var titleEl = document.getElementById('pcNotiTitle');
    var msgEl   = document.getElementById('pcNotiMsg');
    var barFill = document.getElementById('pcNotiBarFill');
    if (!popup) return;
    var cls = isErr ? 'err' : 'ok';
    if (icoEl) icoEl.innerHTML = isErr
        ? '<svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
        : '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>';
    if (titleEl) titleEl.textContent = isErr ? '\u64cd\u4f5c\u5931\u8d25' : '\u64cd\u4f5c\u6210\u529f';
    if (msgEl) msgEl.textContent = msg || '';
    if (barFill) {
        barFill.style.transition = 'none';
        barFill.style.width = '100%';
        barFill.offsetWidth;
        barFill.style.transition = 'width 2.8s linear';
        barFill.style.width = '0%';
    }
    popup.className = 'pc-noti ' + cls;
    if (overlay) overlay.className = 'pc-noti-overlay show';
    clearTimeout(_pcNotiT);
    _pcNotiT = setTimeout(function() { closeNoti(); }, 2800);
}
function closeNoti() {
    var overlay = document.getElementById('pcNotiOverlay');
    clearTimeout(_pcNotiT);
    if (overlay) overlay.className = 'pc-noti-overlay';
}

renderGrid();
</script>
</asp:Content>
