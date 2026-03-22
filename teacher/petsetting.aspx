<%@ Page Title="宠物图标设置" Language="C#" MasterPageFile="~/teacher/Teach.master"
    AutoEventWireup="true" Inherits="System.Web.UI.Page" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    protected string GetPetImagesJson()
    {
        string[] petIds = { "cat", "dog", "rabbit", "fox", "panda", "frog", "tiger", "bird" };
        string[] exts   = { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
        System.Text.StringBuilder sb = new System.Text.StringBuilder("{");
        bool firstPet = true;
        foreach (string petId in petIds)
        {
            System.Text.StringBuilder tierParts = new System.Text.StringBuilder();
            bool firstTier = true;
        for (int tier = 0; tier <= 4; tier++)
            {
                foreach (string ext in exts)
                {
                    string fname = petId + "_lv" + tier.ToString() + ext;
                    string fpath = Server.MapPath("~/images/pets/" + fname);
                    if (File.Exists(fpath))
                    {
                        string url = ResolveUrl("~/images/pets/" + fname)
                                     + "?v=" + File.GetLastWriteTime(fpath).Ticks.ToString();
                        if (!firstTier) tierParts.Append(",");
                        tierParts.Append("\"" + tier.ToString() + "\":\"" + url + "\"");
                        firstTier = false;
                        break;
                    }
                }
            }
            if (tierParts.Length > 0)
            {
                if (!firstPet) sb.Append(",");
                sb.Append("\"" + petId + "\":{" + tierParts.ToString() + "}");
                firstPet = false;
            }
        }
        sb.Append("}");
        return sb.ToString();
    }

    protected string GetPetStagesJson()
    {
        string fpath = Server.MapPath("~/App_Data/petstages.json");
        try {
            if (System.IO.File.Exists(fpath))
                return System.IO.File.ReadAllText(fpath, System.Text.Encoding.UTF8);
        } catch {}
        return "{\"stageExp\":[100,200,300,400,500,600,700]}";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
.ps { max-width: 100%; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

/* 页头 */
.ps-hd { display: flex; align-items: center; gap: 14px; margin-bottom: 24px; }
.ps-hd-icon {
    width: 48px; height: 48px; border-radius: 12px; flex-shrink: 0;
    background: linear-gradient(135deg,#ec4899,#f472b6);
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 4px 12px rgba(236,72,153,.25);
}
.ps-hd-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.ps-hd-text h1 { font-size: 20px; font-weight: 700; color: #0f172a; margin: 0 0 4px; }
.ps-hd-text p  { font-size: 13px; color: #94a3b8; margin: 0; }

/* 说明卡 */
.ps-tip {
    background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px;
    padding: 12px 16px; font-size: 13px; color: #1d4ed8; margin-bottom: 20px;
    line-height: 1.6;
}

/* 主表格 */
.ps-table-wrap { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 2px 8px rgba(0,0,0,.03); overflow: hidden; }
.ps-table { width: 100%; border-collapse: collapse; }
.ps-table th {
    background: #f8fafc; color: #475569; font-size: 12px; font-weight: 700;
    padding: 12px 16px; text-align: center; border-bottom: 1px solid #e2e8f0;
    white-space: nowrap;
}
.ps-table th.pet-col { text-align: left; width: 130px; }
.ps-table td { padding: 14px 12px; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
.ps-table tr:last-child td { border-bottom: none; }
.ps-table td.pet-cell { padding-left: 16px; }

/* 宠物名称单元格 */
.ps-pet-name { display: flex; align-items: center; gap: 10px; }
.ps-pet-ico { width: 36px; height: 36px; border-radius: 8px; background: #f1f5f9; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ps-pet-ico svg { width: 22px; height: 22px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.ps-pet-lbl { font-size: 13px; font-weight: 600; color: #1e293b; }

/* 图标插槽 */
.ps-slot { text-align: center; }
.ps-slot-img {
    width: 80px; height: 80px; margin: 0 auto 8px;
    border-radius: 10px; border: 2px dashed #e2e8f0;
    background: #f8fafc; overflow: hidden; display: flex; align-items: center; justify-content: center;
    cursor: pointer; transition: border-color .2s;
}
.ps-slot-img:hover { border-color: #818cf8; }
.ps-slot-img.has-img { border-style: solid; border-color: #c7d2fe; background: #fff; }
.ps-slot-img img { width: 100%; height: 100%; object-fit: contain; display: block; }
.ps-slot-img .ps-placeholder svg { width: 28px; height: 28px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; }

.ps-slot-btns { display: flex; gap: 4px; justify-content: center; }

/* 成长阶段设置卡 */
.ps-stages-card { background:#fff; border-radius:14px; border:1px solid #e8ecf1; box-shadow:0 2px 8px rgba(0,0,0,.03); overflow:hidden; margin-top:20px; }
.ps-stages-hd { padding:16px 20px; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:10px; background:#f8fafc; }
.ps-stages-hd svg { width:16px; height:16px; stroke:#6366f1; fill:none; stroke-width:2; }
.ps-stages-hd h3 { font-size:15px; font-weight:700; color:#1e293b; margin:0; }
.ps-stages-desc { font-size:13px; color:#64748b; padding:12px 20px 4px; line-height:1.6; }
.ps-stages-grid { padding:12px 20px; display:grid; gap:8px; }
.ps-stage-row { display:grid; grid-template-columns:180px 1fr 140px; align-items:center; gap:10px; padding:10px 14px; border-radius:10px; background:#f8fafc; border:1px solid #f1f5f9; }
.ps-stage-from { display:flex; align-items:center; gap:6px; }
.ps-stage-badge { color:#fff; font-size:11px; font-weight:700; padding:3px 10px; border-radius:999px; white-space:nowrap; }
.ps-stage-arrow { width:14px; height:14px; stroke:#94a3b8; fill:none; stroke-width:2; flex-shrink:0; }
.ps-stage-tag-label { font-size:12px; font-weight:600; }
.ps-stage-input-wrap { display:flex; align-items:center; gap:6px; justify-content:flex-end; }
.ps-stage-input { width:70px; padding:6px 8px; border:1.5px solid #e2e8f0; border-radius:8px; font-size:13px; text-align:center; font-family:inherit; outline:none; transition:border-color .15s; }
.ps-stage-input:focus { border-color:#818cf8; }
.ps-stage-unit { font-size:12px; color:#64748b; font-weight:600; }
.ps-stages-footer { padding:14px 20px; border-top:1px solid #f1f5f9; display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; }
.ps-stages-save-btn { padding:8px 24px; border-radius:8px; font-size:13px; font-weight:600; background:linear-gradient(135deg,#6366f1,#818cf8); color:#fff; border:none; cursor:pointer; font-family:inherit; box-shadow:0 2px 8px rgba(99,102,241,.25); transition:all .15s; }
.ps-stages-save-btn:hover { box-shadow:0 4px 12px rgba(99,102,241,.35); transform:translateY(-1px); }
.ps-stages-hint { font-size:12px; color:#94a3b8; }

.ps-btn {
    padding: 5px 10px; border-radius: 6px; font-size: 11px; font-weight: 600;
    font-family: inherit; cursor: pointer; transition: all .15s; border: 1.5px solid;
}
.ps-btn-upload { background: #f5f3ff; color: #6d28d9; border-color: #ddd6fe; }
.ps-btn-upload:hover { background: #ede9fe; border-color: #a78bfa; }
.ps-btn-del { background: #fff; color: #dc2626; border-color: #fecaca; }
.ps-btn-del:hover { background: #fef2f2; }

/* === Popup Notification === */
.ps-noti-overlay {
    position: fixed; top: 0; right: 0; bottom: 0; left: 0;
    width: 100vw; height: 100vh; z-index: 99998;
    background: rgba(0,0,0,.32); backdrop-filter: blur(2px);
    display: flex; align-items: center; justify-content: center;
    opacity: 0; pointer-events: none; transition: opacity .22s ease;
}
.ps-noti-overlay.show { opacity: 1; pointer-events: auto; }
.ps-noti {
    width: 300px; max-width: 88vw;
    background: #fff; border-radius: 16px;
    box-shadow: 0 20px 60px rgba(0,0,0,.22);
    padding: 32px 24px 24px; text-align: center;
    transform: scale(.85);
    transition: transform .25s cubic-bezier(.34,1.4,.64,1);
}
.ps-noti-overlay.show .ps-noti { transform: scale(1); }
.ps-noti.ok  { border-top: 4px solid #22c55e; }
.ps-noti.err { border-top: 4px solid #ef4444; }
.ps-noti-ico {
    width: 52px; height: 52px; border-radius: 50%;
    margin: 0 auto 14px; display: flex; align-items: center; justify-content: center;
}
.ps-noti.ok  .ps-noti-ico { background: #dcfce7; }
.ps-noti.err .ps-noti-ico { background: #fee2e2; }
.ps-noti-ico svg { width: 26px; height: 26px; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
.ps-noti.ok  .ps-noti-ico svg { stroke: #16a34a; }
.ps-noti.err .ps-noti-ico svg { stroke: #dc2626; }
.ps-noti-title { text-align: center; font-size: 16px; font-weight: 700; margin-bottom: 8px; }
.ps-noti.ok  .ps-noti-title { color: #166534; }
.ps-noti.err .ps-noti-title { color: #991b1b; }
.ps-noti-msg {
    text-align: center; font-size: 14px; color: #475569;
    line-height: 1.6; margin-bottom: 16px;
    word-break: break-word; white-space: pre-line;
    max-height: 140px; overflow-y: auto;
}
.ps-noti-bar { height: 4px; background: #f1f5f9; border-radius: 999px; overflow: hidden; margin-bottom: 14px; }
.ps-noti-bar-fill { height: 100%; border-radius: 999px; width: 100%; }
.ps-noti.ok  .ps-noti-bar-fill { background: #22c55e; }
.ps-noti.err .ps-noti-bar-fill { background: #ef4444; }
.ps-noti-btn {
    display: block; width: 100%; padding: 10px; border-radius: 10px;
    border: none; font-size: 14px; font-weight: 600;
    cursor: pointer; font-family: inherit; transition: all .15s;
}
.ps-noti.ok  .ps-noti-btn { background: #f0fdf4; color: #166534; }
.ps-noti.ok  .ps-noti-btn:hover { background: #dcfce7; }
.ps-noti.err .ps-noti-btn { background: #fff1f2; color: #991b1b; }
.ps-noti.err .ps-noti-btn:hover { background: #fee2e2; }
</style>

<div class="ps">

    <div class="ps-hd">
        <div class="ps-hd-icon">
            <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
        </div>
        <div class="ps-hd-text">
            <h1>宠物图标设置</h1>
            <p>为每种宠物的不同等级阶段上传自定义图片，学生端宠物乐园将优先显示您上传的图片</p>
        </div>
    </div>

    <div class="ps-tip">
        💡 <strong>图标说明：</strong>每种宠物支持 5 个等级阶段图标（Lv0 初始 / Lv1 基础 / Lv2-3 成长 / Lv4-6 进阶 / Lv7+ 传奇）。
        Lv0 初始图标显示在领养选择界面；若某等级未上传则自动使用低等级图标；若均未上传则显示内置 SVG。
        支持 PNG / JPG / GIF / WebP，每张不超过 2MB，建议尺寸 200×200px 以上。
    </div>

    <div class="ps-table-wrap">
        <table class="ps-table" id="petTable">
            <thead>
                <tr>
                    <th class="pet-col">宠物</th>
                    <th>Lv0<br><span style="font-weight:400;color:#94a3b8;">初始阶段</span></th>
                    <th>Lv1<br><span style="font-weight:400;color:#94a3b8;">基础阶段</span></th>
                    <th>Lv2-3<br><span style="font-weight:400;color:#94a3b8;">成长阶段</span></th>
                    <th>Lv4-6<br><span style="font-weight:400;color:#94a3b8;">进阶阶段</span></th>
                    <th>Lv7+<br><span style="font-weight:400;color:#94a3b8;">传奇阶段</span></th>
                </tr>
            </thead>
            <tbody id="petTbody"></tbody>
        </table>
    </div>

    <!-- 成长阶段设置 -->
    <div class="ps-stages-card">
        <div class="ps-stages-hd">
            <svg viewBox="0 0 24 24"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
            <h3>成长阶段设置</h3>
        </div>
        <div class="ps-stages-desc">配置宠物每个等级升级所需的学分。学生通过投喂、清洁、互动等操作积累学分，达到设定值即可升级。</div>
        <div class="ps-stages-grid" id="stagesGrid"></div>
        <div class="ps-stages-footer">
            <span class="ps-stages-hint">💡 修改后点击保存，学生端下次打开宠物乐园生效</span>
            <button type="button" class="ps-stages-save-btn" onclick="savePetStages()">
                <svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;vertical-align:middle;margin-right:4px;"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                保存阶段设置
            </button>
        </div>
    </div>
</div>

<!-- Hidden file inputs -->
<input type="file" id="fileInput" accept="image/png,image/jpeg,image/gif,image/webp" style="display:none">
<div id="psNotiOverlay" class="ps-noti-overlay" onclick="if(event.target===this)closeNoti()">
    <div id="psNoti" class="ps-noti">
        <div class="ps-noti-ico" id="psNotiIco"></div>
        <div class="ps-noti-title" id="psNotiTitle"></div>
        <div class="ps-noti-msg" id="psNotiMsg"></div>
        <div class="ps-noti-bar"><div class="ps-noti-bar-fill" id="psNotiBarFill"></div></div>
        <button class="ps-noti-btn" onclick="closeNoti()">确认</button>
    </div>
</div>

<script type="text/javascript">
var PET_IMGS = <%=GetPetImagesJson()%>;
var PET_STAGES = <%=GetPetStagesJson()%>;

var PETS = [
    { id:"cat",    name:"奶糖喵" },
    { id:"dog",    name:"旺福汪" },
    { id:"rabbit", name:"跳跳兔" },
    { id:"fox",    name:"小橘狐" },
    { id:"panda",  name:"团团熊" },
    { id:"frog",   name:"呱呱蛙" },
    { id:"tiger",  name:"虎仔"   },
    { id:"bird",   name:"圆圆企鹅" }
];

var TIERS = [
    { tier: 0, label: "Lv0"   },
    { tier: 1, label: "Lv1"   },
    { tier: 2, label: "Lv2-3" },
    { tier: 3, label: "Lv4-6" },
    { tier: 4, label: "Lv7+"  }
];

var STAGE_DEFS = [
    { from:1, to:2,    tag:'基础 → 成长', color:'#6366f1' },
    { from:2, to:3,    tag:'成长期',     color:'#8b5cf6' },
    { from:3, to:4,    tag:'成长 → 进阶', color:'#a78bfa' },
    { from:4, to:5,    tag:'进阶期',     color:'#f59e0b' },
    { from:5, to:6,    tag:'进阶期',     color:'#f97316' },
    { from:6, to:7,    tag:'进阶 → 传奇', color:'#ef4444' },
    { from:7, to:null, tag:'传奇阶段 (Lv7+ 循环使用)', color:'#ec4899' }
];

var PET_SVGS = {
    cat:    '<svg viewBox="0 0 24 24"><path d="M4 16a8 8 0 0 0 16 0"/><path d="M7 9l2-3 3 2 3-2 2 3"/><circle cx="9" cy="14" r="1"/><circle cx="15" cy="14" r="1"/></svg>',
    dog:    '<svg viewBox="0 0 24 24"><path d="M5 10l-2-2m16 2l2-2"/><rect x="6" y="8" width="12" height="10" rx="5"/><circle cx="10" cy="13" r="1"/><circle cx="14" cy="13" r="1"/></svg>',
    rabbit: '<svg viewBox="0 0 24 24"><path d="M9 8V3m6 5V3"/><circle cx="12" cy="14" r="6"/><circle cx="10" cy="14" r="1"/><circle cx="14" cy="14" r="1"/></svg>',
    fox:    '<svg viewBox="0 0 24 24"><path d="M4 10l4-4 4 3 4-3 4 4-2 8H6z"/><circle cx="10" cy="14" r="1"/><circle cx="14" cy="14" r="1"/></svg>',
    panda:  '<svg viewBox="0 0 24 24"><circle cx="12" cy="13" r="6"/><circle cx="8" cy="7" r="2"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="13" r="1"/><circle cx="14" cy="13" r="1"/></svg>',
    frog:   '<svg viewBox="0 0 24 24"><circle cx="8" cy="9" r="2"/><circle cx="16" cy="9" r="2"/><rect x="5" y="10" width="14" height="8" rx="4"/><circle cx="10" cy="14" r="1"/><circle cx="14" cy="14" r="1"/></svg>',
    tiger:  '<svg viewBox="0 0 24 24"><circle cx="12" cy="13" r="6"/><path d="M9 10l-2-2m8 2l2-2"/><path d="M9 16l1-2m4 2l-1-2"/></svg>',
    bird:   '<svg viewBox="0 0 24 24"><circle cx="11" cy="13" r="5"/><path d="M16 13h4l-2 2"/><path d="M9 9l-1-2m4 2l1-2"/></svg>'
};

// Current active upload target
var _uploadPetId = null;
var _uploadTier  = null;

function slotId(petId, tier) { return 'slot_' + petId + '_' + tier; }
function imgId(petId, tier)  { return 'img_'  + petId + '_' + tier; }
function statusId(petId)     { return 'status_' + petId; }

function getStatusHtml(petId) {
    var count = 0;
    var bitsHtml = '';
    for (var ti = 0; ti < TIERS.length; ti++) {
        var tier = TIERS[ti].tier;
        var has = !!(PET_IMGS[petId] && PET_IMGS[petId][tier]);
        if (has) count++;
        bitsHtml += '<span class="ps-tier-badge' + (has ? ' has' : '') + '">' + (has ? '\u2713 ' : '') + TIERS[ti].label + '</span>';
    }
    var barColor = count === 4 ? '#16a34a' : count >= 2 ? '#f59e0b' : count === 1 ? '#f97316' : '#e2e8f0';
    var barW = Math.round(count / 4 * 100);
    var txtCls = count === 4 ? 'ok' : count > 0 ? 'part' : 'none';
    var txtVal = count === 4 ? '\u2705 \u5df2\u5168\u914d\u7f6e' : count === 0 ? '\u2b1c \u672a\u914d\u7f6e' : count + ' / 4 \u9636\u6bb5';
    return '<div class="ps-status-cell">'
         + '<div class="ps-tier-badges">' + bitsHtml + '</div>'
         + '<div class="ps-status-bar"><div class="ps-status-bar-fill" style="width:' + barW + '%;background:' + barColor + ';"></div></div>'
         + '<div class="ps-status-txt ' + txtCls + '">' + txtVal + '</div>'
         + '</div>';
}

function updateStatus(petId) {
    var el = document.getElementById(statusId(petId));
    if (el) el.innerHTML = getStatusHtml(petId);
}

function renderTable() {
    var tbody = document.getElementById('petTbody');
    var html = '';
    for (var pi = 0; pi < PETS.length; pi++) {
        var pet = PETS[pi];
        html += '<tr>';
        // Pet name cell
        html += '<td class="pet-cell"><div class="ps-pet-name">'
              + '<div class="ps-pet-ico">' + (PET_SVGS[pet.id] || '') + '</div>'
              + '<div class="ps-pet-lbl">' + esc(pet.name) + '</div>'
              + '</div></td>';
        // Tier cells
        for (var ti = 0; ti < TIERS.length; ti++) {
            var tier = TIERS[ti].tier;
            var imgUrl = (PET_IMGS[pet.id] && PET_IMGS[pet.id][tier]) ? PET_IMGS[pet.id][tier] : null;
            html += '<td>';
            html += '<div class="ps-slot">';
            // Image preview
            var hasImg = imgUrl ? ' has-img' : '';
            html += '<div class="ps-slot-img' + hasImg + '" id="' + slotId(pet.id, tier) + '" onclick="triggerUpload(\'' + pet.id + '\',' + tier + ')">';
            if (imgUrl) {
                html += '<img id="' + imgId(pet.id, tier) + '" src="' + esc(imgUrl) + '" alt="">';
            } else {
                html += '<div class="ps-placeholder"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></div>';
            }
            html += '</div>';
            // Buttons
            html += '<div class="ps-slot-btns">';
            html += '<button type="button" class="ps-btn ps-btn-upload" onclick="triggerUpload(\'' + pet.id + '\',' + tier + ')">上传</button>';
            if (imgUrl) {
                html += '<button type="button" class="ps-btn ps-btn-del" id="delbtn_' + pet.id + '_' + tier + '" onclick="deleteImg(\'' + pet.id + '\',' + tier + ')">删除</button>';
            } else {
                html += '<button type="button" class="ps-btn ps-btn-del" id="delbtn_' + pet.id + '_' + tier + '" onclick="deleteImg(\'' + pet.id + '\',' + tier + ')" style="display:none">删除</button>';
            }
            html += '</div>';
            html += '</div>';
            html += '</td>';
        }
        html += '</tr>';
    }
    tbody.innerHTML = html;
}

function triggerUpload(petId, tier) {
    _uploadPetId = petId;
    _uploadTier  = tier;
    var fi = document.getElementById('fileInput');
    try { fi.value = ''; } catch(e) {}
    fi.click();
}

document.getElementById('fileInput').onchange = function() {
    var file = this.files[0];
    if (!file || !_uploadPetId || _uploadTier === null) return;
    var fd = new FormData();
    fd.append('file', file);
    fd.append('petId', _uploadPetId);
    fd.append('tier',  _uploadTier);
    fd.append('action', 'upload');
    var pid = _uploadPetId, tir = _uploadTier;
    fetch('petimgupload.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (!res || !res.success) {
                toast((res && res.msg) ? res.msg : '上传失败', true);
                return;
            }
            // Update PET_IMGS cache
            if (!PET_IMGS[pid]) PET_IMGS[pid] = {};
            PET_IMGS[pid][tir] = res.url;
            // Update DOM
            var slotEl = document.getElementById(slotId(pid, tir));
            if (slotEl) {
                slotEl.className = 'ps-slot-img has-img';
                slotEl.innerHTML = '<img id="' + imgId(pid, tir) + '" src="' + esc(res.url) + '" alt="">';
            }
            var delBtn = document.getElementById('delbtn_' + pid + '_' + tir);
            if (delBtn) delBtn.style.display = '';
            updateStatus(pid);
            toast('上传成功 ✅');
        })
        .catch(function() { toast('网络错误，上传失败', true); });
};

function deleteImg(petId, tier) {
    if (!confirm('确定要删除该图标吗？')) return;
    var fd = new FormData();
    fd.append('petId', petId);
    fd.append('tier',  tier);
    fd.append('action', 'delete');
    fetch('petimgupload.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (!res || !res.success) {
                toast((res && res.msg) ? res.msg : '删除失败', true);
                return;
            }
            // Update PET_IMGS cache
            if (PET_IMGS[petId]) delete PET_IMGS[petId][tier];
            // Update DOM
            var slotEl = document.getElementById(slotId(petId, tier));
            if (slotEl) {
                slotEl.className = 'ps-slot-img';
                slotEl.innerHTML = '<div class="ps-placeholder"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></div>';
            }
            var delBtn = document.getElementById('delbtn_' + petId + '_' + tier);
            if (delBtn) delBtn.style.display = 'none';
            updateStatus(petId);
            toast('图标已删除');
        })
        .catch(function() { toast('网络错误，删除失败', true); });
}

function esc(s) {
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

var _psNotiT = null;
function toast(msg, isErr) {
    var overlay = document.getElementById('psNotiOverlay');
    var popup   = document.getElementById('psNoti');
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
    var icoEl   = document.getElementById('psNotiIco');
    var titleEl = document.getElementById('psNotiTitle');
    var msgEl   = document.getElementById('psNotiMsg');
    var barFill = document.getElementById('psNotiBarFill');
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
    popup.className = 'ps-noti ' + cls;
    if (overlay) overlay.className = 'ps-noti-overlay show';
    clearTimeout(_psNotiT);
    _psNotiT = setTimeout(function() { closeNoti(); }, 2800);
}
function closeNoti() {
    var overlay = document.getElementById('psNotiOverlay');
    clearTimeout(_psNotiT);
    if (overlay) overlay.className = 'ps-noti-overlay';
}

renderTable();

function renderStages() {
    var el = document.getElementById('stagesGrid');
    if (!el) return;
    var exp = (PET_STAGES && Array.isArray(PET_STAGES.stageExp)) ? PET_STAGES.stageExp : [];
    el.innerHTML = STAGE_DEFS.map(function(s, i) {
        var val = (exp[i] !== undefined && exp[i] > 0) ? exp[i] : (i + 1) * 100;
        var toLabel = s.to ? 'Lv' + s.to : 'Lv8+';
        return '<div class="ps-stage-row">'
            + '<div class="ps-stage-from">'
            + '<span class="ps-stage-badge" style="background:' + s.color + ';">Lv' + s.from + '</span>'
            + '<svg viewBox="0 0 24 24" class="ps-stage-arrow"><polyline points="9 18 15 12 9 6"/></svg>'
            + '<span class="ps-stage-badge" style="background:' + s.color + ';">' + toLabel + '</span>'
            + '</div>'
            + '<div class="ps-stage-tag"><span class="ps-stage-tag-label" style="color:' + s.color + ';">' + s.tag + '</span></div>'
            + '<div class="ps-stage-input-wrap">'
            + '<input type="number" class="ps-stage-input" id="stageExp_' + i + '" value="' + val + '" min="1" max="9999">'
            + '<span class="ps-stage-unit">学分</span>'
            + '</div>'
            + '</div>';
    }).join('');
}

function savePetStages() {
    var stageExp = [];
    for (var i = 0; i < STAGE_DEFS.length; i++) {
        var inp = document.getElementById('stageExp_' + i);
        var v = inp ? parseInt(inp.value, 10) : 0;
        if (isNaN(v) || v < 1) v = (i + 1) * 100;
        if (v > 9999) v = 9999;
        stageExp.push(v);
    }
    var fd = new FormData();
    fd.append('json', JSON.stringify({ stageExp: stageExp }));
    fetch('petstagesave.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res && res.success) {
                PET_STAGES = { stageExp: stageExp };
                toast('阶段设置已保存 ✅');
            } else {
                toast((res && res.msg) ? res.msg : '保存失败', true);
            }
        })
        .catch(function() { toast('网络错误', true); });
}

renderStages();
</script>
</asp:Content>
