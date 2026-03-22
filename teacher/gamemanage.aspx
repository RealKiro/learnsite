<%@ Page Title="游戏管理" Language="C#" MasterPageFile="~/teacher/Teach.master"
    AutoEventWireup="true" Inherits="System.Web.UI.Page" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected string gamesJson = "{\"games\":[]}";
    // 游戏开关状态：直接查询数据库 Room.Rgame，不依赖 games.json
    protected int roomTotal   = 0; // 总班级数
    protected int roomEnabled = 0; // Rgame=1 的班级数
    // 0=无数据  1=全开  2=部分关  3=全关
    protected int gameStatus  = 0;

    protected string BannerClass
    {
        get {
            if (gameStatus == 1) return "gm-ctrl-banner-on";
            if (gameStatus == 2) return "gm-ctrl-banner-partial";
            if (gameStatus == 3) return "gm-ctrl-banner-off";
            return "gm-ctrl-banner-on";
        }
    }
    protected string BannerTitle
    {
        get {
            if (gameStatus == 1) return "&#9989; 游戏功能已全部开启";
            if (gameStatus == 2) return "&#9888; 部分班级游戏已关闭（" + roomEnabled + "/" + roomTotal + " 班级已开启）";
            if (gameStatus == 3) return "&#9940; 游戏功能已全部关闭";
            return "&#8505; 暂无班级数据";
        }
    }
    protected string BannerDesc
    {
        get {
            if (gameStatus == 1) return "学生当前可以访问游戏。如需关闭，请前往上课页面关闭游戏开关。";
            if (gameStatus == 2) return "共 " + roomTotal + " 个班级，" + roomEnabled + " 个已开启、" + (roomTotal - roomEnabled) + " 个已关闭。请前往上课页面按班级调整游戏开关。";
            if (gameStatus == 3) return "共 " + roomTotal + " 个班级均已关闭游戏，学生无法访问游戏。请前往上课页面开启游戏开关。";
            return "游戏访问权限由上课页面（start.aspx）的游戏开关统一控制。";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) { LoadGames(); LoadRoomGameStatus(); }
    }

    private void LoadGames()
    {
        string path = Server.MapPath("~/App_Data/games.json");
        try
        {
            if (File.Exists(path))
                gamesJson = File.ReadAllText(path, System.Text.Encoding.UTF8);
        }
        catch { }
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly
                .GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public |
                    System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
            try { cs = System.Configuration.ConfigurationManager
                .ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        if (cs != null &&
            cs.ToLower().IndexOf("connection timeout") < 0 &&
            cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private void LoadRoomGameStatus()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 检查 Rgame 列是否存在
                SqlCommand chk = new SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME='Room' AND COLUMN_NAME='Rgame'", conn);
                chk.CommandTimeout = 5;
                int colExists = (int)chk.ExecuteScalar();
                if (colExists == 0)
                {
                    // 列不存在：查总班级数，视为全开
                    SqlCommand cnt = new SqlCommand("SELECT COUNT(*) FROM Room", conn);
                    cnt.CommandTimeout = 5;
                    roomTotal   = (int)cnt.ExecuteScalar();
                    roomEnabled = roomTotal;
                    gameStatus  = roomTotal > 0 ? 1 : 0;
                    return;
                }
                // 列存在：统计开/关班级数
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) AS T, " +
                    "SUM(CASE WHEN ISNULL(Rgame,1)=1 THEN 1 ELSE 0 END) AS E " +
                    "FROM Room", conn);
                cmd.CommandTimeout = 5;
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        roomTotal   = dr["T"] == DBNull.Value ? 0 : Convert.ToInt32(dr["T"]);
                        roomEnabled = dr["E"] == DBNull.Value ? 0 : Convert.ToInt32(dr["E"]);
                    }
                }
                if      (roomTotal == 0)            gameStatus = 0;
                else if (roomEnabled == roomTotal)   gameStatus = 1; // 全开
                else if (roomEnabled == 0)           gameStatus = 3; // 全关
                else                                 gameStatus = 2; // 部分关
            }
        }
        catch { gameStatus = 0; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
/* ===== 游戏管理页 ===== */
.gm { width:100%; font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif; padding-bottom:48px; }

/* ── 英雄页头 ─────────────────────────────────────────── */
.gm-hero {
    position:relative; overflow:hidden;
    background:linear-gradient(135deg,#1a1060 0%,#2d1b8f 50%,#4f46e5 100%);
    border-radius:20px; padding:24px 28px;
    display:flex; align-items:center; justify-content:space-between;
    flex-wrap:wrap; gap:16px; margin-bottom:24px;
    box-shadow:0 8px 32px rgba(79,70,229,.35);
}
.gm-hero::before,.gm-hero::after {
    content:''; position:absolute; border-radius:50%;
    background:rgba(255,255,255,.06); pointer-events:none;
}
.gm-hero::before { width:260px; height:260px; top:-80px; right:-60px; }
.gm-hero::after  { width:160px; height:160px; bottom:-60px; right:120px; }
.gm-hero-left { display:flex; align-items:center; gap:16px; position:relative; z-index:1; }
.gm-hero-ico {
    width:56px; height:56px; border-radius:16px; flex-shrink:0;
    background:rgba(255,255,255,.15); backdrop-filter:blur(8px);
    border:1.5px solid rgba(255,255,255,.25);
    display:flex; align-items:center; justify-content:center;
    box-shadow:0 4px 16px rgba(0,0,0,.2);
}
.gm-hero-ico svg { width:28px; height:28px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.gm-hero-title { font-size:22px; font-weight:800; color:#fff; margin:0 0 4px; letter-spacing:-.3px; }
.gm-hero-sub   { font-size:13px; color:rgba(255,255,255,.65); margin:0; }
.gm-hero-actions { display:flex; gap:10px; align-items:center; flex-wrap:wrap; position:relative; z-index:1; }

/* 添加游戏按钮 */
.gm-btn-add {
    display:inline-flex; align-items:center; gap:6px;
    padding:10px 22px; border:none;
    background:linear-gradient(135deg,#6d28d9,#a78bfa);
    color:#fff; border-radius:10px; font-size:13px; font-weight:600;
    cursor:pointer; font-family:inherit; text-decoration:none;
    box-shadow:0 3px 10px rgba(109,40,217,.3); transition:all .18s;
}
.gm-btn-add:hover { box-shadow:0 5px 16px rgba(109,40,217,.45); transform:translateY(-1px); }
.gm-btn-add svg { width:15px; height:15px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; }
.gm-hero .gm-btn-add {
    background:rgba(255,255,255,.15); backdrop-filter:blur(8px);
    border:1.5px solid rgba(255,255,255,.3); box-shadow:none;
}
.gm-hero .gm-btn-add:hover { background:rgba(255,255,255,.25); border-color:rgba(255,255,255,.5); box-shadow:none; }


/* ── 统计卡片行 ──────────────────────────────────────── */
.gm-stats { display:flex; gap:14px; margin-bottom:20px; flex-wrap:wrap; }
.gm-stat {
    flex:1; min-width:150px;
    background:#fff; border-radius:16px; border:1px solid #e8ecf1;
    padding:16px 20px; display:flex; align-items:center; gap:14px;
    box-shadow:0 2px 8px rgba(0,0,0,.05);
    transition:box-shadow .2s, transform .2s;
}
.gm-stat:hover { box-shadow:0 6px 20px rgba(0,0,0,.1); transform:translateY(-2px); }
.gm-stat-ico { width:46px; height:46px; border-radius:13px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.gm-stat-ico svg { width:22px; height:22px; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.gm-stat-ico.purple { background:linear-gradient(135deg,#ede9fe,#ddd6fe); } .gm-stat-ico.purple svg { stroke:#7c3aed; }
.gm-stat-ico.green  { background:linear-gradient(135deg,#d1fae5,#a7f3d0); } .gm-stat-ico.green  svg { stroke:#059669; }
.gm-stat-ico.slate  { background:linear-gradient(135deg,#f1f5f9,#e2e8f0); } .gm-stat-ico.slate  svg { stroke:#475569; }
.gm-stat-val { font-size:28px; font-weight:800; color:#0f172a; line-height:1; }
.gm-stat-lbl { font-size:12px; color:#94a3b8; margin-top:3px; font-weight:500; }

/* ── 空状态 ──────────────────────────────────────────── */
.gm-empty {
    text-align:center; padding:72px 20px;
    background:#fff; border-radius:20px; border:2px dashed #e2e8f0;
}
.gm-empty svg { width:64px; height:64px; stroke:#cbd5e1; fill:none; stroke-width:1.5; stroke-linecap:round; stroke-linejoin:round; margin-bottom:20px; }
.gm-empty h3 { font-size:17px; font-weight:700; color:#334155; margin:0 0 8px; }
.gm-empty p  { font-size:13px; color:#94a3b8; margin:0 0 24px; }

/* ── 游戏卡片网格 ─────────────────────────────────────── */
.gm-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:18px; }
.gm-card {
    background:#fff; border-radius:18px; border:1px solid #e8ecf1;
    box-shadow:0 2px 10px rgba(0,0,0,.05); overflow:hidden;
    transition:box-shadow .22s, transform .22s;
    display:flex; flex-direction:column;
}
.gm-card:hover { box-shadow:0 10px 32px rgba(0,0,0,.12); transform:translateY(-3px); }
.gm-card.disabled { opacity:.68; }

/* 卡片色条 — CSS 变量由 JS 调色板注入 */
.gm-card-bar { height:5px; background:var(--card-bar,linear-gradient(90deg,#6d28d9,#a78bfa)); }
.gm-card-bar.disabled { background:#e2e8f0; }

/* 卡片头部 */
.gm-card-head { padding:16px 16px 10px; display:flex; align-items:flex-start; gap:13px; }
.gm-card-ico {
    width:46px; height:46px; border-radius:13px; flex-shrink:0;
    background:var(--card-ico,linear-gradient(135deg,#ede9fe,#ddd6fe));
    display:flex; align-items:center; justify-content:center;
    font-size:22px; overflow:hidden;
}
.gm-card-ico svg { width:24px; height:24px; stroke:var(--card-stroke,#7c3aed); fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.gm-card-info { flex:1; min-width:0; }
.gm-card-name { font-size:15px; font-weight:700; color:#0f172a; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.gm-card-url  { font-size:11px; color:#94a3b8; margin-top:3px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.gm-card-date { font-size:11px; color:#cbd5e1; margin-top:2px; }

/* 游戏开关拨打 */
.gm-toggle {
    position:relative; width:44px; height:26px; flex-shrink:0; cursor:pointer;
}
.gm-toggle input { opacity:0; width:0; height:0; position:absolute; }
.gm-toggle-track {
    position:absolute; inset:0; border-radius:13px;
    background:#e2e8f0; transition:background .2s;
}
.gm-toggle input:checked + .gm-toggle-track { background:var(--card-solid,#7c3aed); }
.gm-toggle-thumb {
    position:absolute; top:3px; left:3px;
    width:20px; height:20px; border-radius:50%;
    background:#fff; box-shadow:0 1px 4px rgba(0,0,0,.25);
    transition:transform .25s cubic-bezier(.34,1.56,.64,1);
}
.gm-toggle input:checked ~ .gm-toggle-thumb { transform:translateX(18px); }
.gm-toggle input:disabled + .gm-toggle-track { opacity:.5; cursor:not-allowed; }

/* 卡片底部操作 */
.gm-card-foot {
    padding:8px 12px 12px; display:flex; align-items:center; gap:5px;
    border-top:1px solid #f8fafc; margin-top:auto;
    flex-wrap:nowrap; overflow:hidden;
}
.gm-tag {
    display:inline-flex; align-items:center; gap:3px;
    padding:3px 8px; border-radius:20px; font-size:10px; font-weight:700;
    white-space:nowrap; flex-shrink:0; letter-spacing:.3px; text-transform:uppercase;
}
.gm-tag svg { width:11px; height:11px; stroke:currentColor; fill:none; stroke-width:2.5; }
.gm-tag.on  { background:#f5f3ff; color:#6d28d9; }
.gm-tag.off { background:#f1f5f9; color:#94a3b8; }
.gm-spacer { flex:1; min-width:0; }
.gm-btn {
    display:inline-flex; align-items:center; gap:4px;
    padding:4px 9px; border-radius:7px; font-size:11px; font-weight:600;
    border:1.5px solid; cursor:pointer; font-family:inherit; transition:all .15s;
    text-decoration:none; white-space:nowrap; flex-shrink:0;
}
.gm-btn svg { width:12px; height:12px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
.gm-btn-preview { background:#f0f9ff; color:#0369a1; border-color:#bae6fd; }
.gm-btn-preview:hover { background:#e0f2fe; }
.gm-btn-edit { background:#f5f3ff; color:#6d28d9; border-color:#ddd6fe; }
.gm-btn-edit:hover { background:#ede9fe; }
.gm-btn-del { background:#fff1f2; color:#be123c; border-color:#fecdd3; }
.gm-btn-del:hover { background:#ffe4e6; }

/* ── 编辑弹窗 ────────────────────────────────────────── */
.gm-overlay {
    display:none; position:fixed;
    top:0; right:0; bottom:0; left:0;
    width:100%; height:100%; z-index:9998;
    background:rgba(15,23,42,.55); backdrop-filter:blur(4px);
    align-items:center; justify-content:center;
}
.gm-overlay.show { display:flex; }
.gm-modal {
    width:480px; max-width:95vw;
    background:#fff; border-radius:18px;
    box-shadow:0 32px 80px rgba(0,0,0,.25); overflow:hidden;
    animation:gmIn .28s cubic-bezier(.34,1.4,.64,1);
}
@keyframes gmIn { from{opacity:0;transform:scale(.88) translateY(16px)} to{opacity:1;transform:scale(1) translateY(0)} }
.gm-modal-hd {
    background:linear-gradient(135deg,#1a1060 0%,#2d1b8f 50%,#4f46e5 100%);
    padding:18px 22px; display:flex; align-items:center; gap:13px;
}
.gm-modal-hd-ico {
    width:40px; height:40px; border-radius:11px; flex-shrink:0;
    background:rgba(255,255,255,.18); border:1px solid rgba(255,255,255,.25);
    display:flex; align-items:center; justify-content:center;
}
.gm-modal-hd-ico svg { width:20px; height:20px; stroke:#fff; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.gm-modal-hd-title { font-size:15px; font-weight:700; color:#fff; flex:1; letter-spacing:.2px; }
.gm-modal-hd-close {
    width:30px; height:30px; border-radius:8px; border:none;
    background:rgba(255,255,255,.15); cursor:pointer;
    display:flex; align-items:center; justify-content:center; transition:background .15s;
}
.gm-modal-hd-close:hover { background:rgba(255,255,255,.3); }
.gm-modal-hd-close svg { width:15px; height:15px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; }
.gm-modal-body { padding:22px; display:flex; flex-direction:column; gap:16px; }
.gm-field { display:flex; flex-direction:column; gap:6px; }
.gm-field label { font-size:11px; font-weight:700; color:#374151; letter-spacing:.6px; text-transform:uppercase; }
.gm-field input, .gm-field textarea {
    padding:10px 13px; border:2px solid #e2e8f0; border-radius:9px;
    font-size:13px; font-family:inherit; outline:none; transition:border .2s, box-shadow .2s;
    width:100%; box-sizing:border-box; color:#1e293b; background:#fafbfc;
}
.gm-field input:focus, .gm-field textarea:focus { border-color:#6d28d9; background:#fff; box-shadow:0 0 0 3px rgba(109,40,217,.12); }
.gm-field textarea { resize:vertical; min-height:68px; }
.gm-modal-msg { font-size:12px; font-weight:500; min-height:16px; }
.gm-field-hint { font-size:11px; color:#94a3b8; line-height:1.5; margin-top:2px; }
.gm-field-row { display:flex; align-items:center; gap:8px; }
.gm-field-row input[type=number] { width:110px; flex-shrink:0; }
.gm-field-row-unit { font-size:12px; color:#64748b; white-space:nowrap; }
.gm-modal-msg.err { color:#dc2626; }
.gm-modal-msg.ok  { color:#059669; }
.gm-modal-foot {
    padding:16px 22px; border-top:1px solid #f1f5f9;
    display:flex; justify-content:flex-end; gap:10px;
}
.gm-modal-btn {
    padding:9px 24px; border-radius:9px; font-size:13px; font-weight:700;
    font-family:inherit; cursor:pointer; border:none; transition:all .15s;
}
.gm-modal-btn-cancel { background:#f1f5f9; color:#64748b; }
.gm-modal-btn-cancel:hover { background:#e2e8f0; }
.gm-modal-btn-save {
    background:linear-gradient(135deg,#4f46e5,#6d28d9); color:#fff;
    box-shadow:0 3px 10px rgba(79,70,229,.3);
}
.gm-modal-btn-save:hover { box-shadow:0 5px 18px rgba(79,70,229,.45); transform:translateY(-1px); }
.gm-modal-btn-save:disabled { opacity:.6; transform:none; box-shadow:none; cursor:not-allowed; }


/* ── 游戏开关状态横幅（由 start.aspx 控制）───────────────── */
.gm-ctrl-banner {
    display:flex; align-items:center; gap:14px; flex-wrap:wrap;
    border-radius:14px; padding:14px 20px; margin-bottom:18px;
    box-shadow:0 2px 8px rgba(0,0,0,.06);
}
.gm-ctrl-banner-on  { background:linear-gradient(135deg,#ecfdf5,#d1fae5); border:1.5px solid #6ee7b7; }
.gm-ctrl-banner-off { background:linear-gradient(135deg,#fff7ed,#ffedd5); border:1.5px solid #fed7aa; }
.gm-ctrl-banner-ico {
    width:38px; height:38px; border-radius:11px; flex-shrink:0;
    display:flex; align-items:center; justify-content:center;
}
.gm-ctrl-banner-on  .gm-ctrl-banner-ico { background:linear-gradient(135deg,#6ee7b7,#34d399); box-shadow:0 2px 6px rgba(16,185,129,.3); }
.gm-ctrl-banner-off .gm-ctrl-banner-ico { background:linear-gradient(135deg,#fed7aa,#fdba74); box-shadow:0 2px 6px rgba(251,146,60,.3); }
.gm-ctrl-banner-on  .gm-ctrl-banner-ico svg { stroke:#047857; }
.gm-ctrl-banner-off .gm-ctrl-banner-ico svg { stroke:#ea580c; }
.gm-ctrl-banner-ico svg { width:18px; height:18px; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.gm-ctrl-banner-body { flex:1; min-width:0; }
.gm-ctrl-banner-title { font-size:13px; font-weight:700; margin:0 0 2px; }
.gm-ctrl-banner-on  .gm-ctrl-banner-title { color:#065f46; }
.gm-ctrl-banner-off .gm-ctrl-banner-title { color:#9a3412; }
.gm-ctrl-banner-desc { font-size:12px; margin:0; line-height:1.5; }
.gm-ctrl-banner-on  .gm-ctrl-banner-desc { color:#047857; }
.gm-ctrl-banner-off .gm-ctrl-banner-desc { color:#c2410c; }
.gm-ctrl-banner-btn {
    display:inline-flex; align-items:center; gap:5px;
    padding:8px 16px; border-radius:9px;
    font-size:12px; font-weight:600; text-decoration:none;
    transition:all .15s; white-space:nowrap; flex-shrink:0;
}
.gm-ctrl-banner-btn svg { width:13px; height:13px; fill:none; stroke:currentColor; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
.gm-ctrl-banner-on  .gm-ctrl-banner-btn { background:#d1fae5; color:#065f46; border:1.5px solid #6ee7b7; }
.gm-ctrl-banner-on  .gm-ctrl-banner-btn:hover { background:#a7f3d0; }
.gm-ctrl-banner-off .gm-ctrl-banner-btn { background:#ffedd5; color:#9a3412; border:1.5px solid #fed7aa; }
.gm-ctrl-banner-off .gm-ctrl-banner-btn:hover { background:#fde68a; }
.gm-ctrl-banner-partial { background:linear-gradient(135deg,#fffbeb,#fef3c7); border:1.5px solid #fde68a; }
.gm-ctrl-banner-partial .gm-ctrl-banner-ico { background:linear-gradient(135deg,#fde68a,#fbbf24); box-shadow:0 2px 6px rgba(245,158,11,.3); }
.gm-ctrl-banner-partial .gm-ctrl-banner-ico svg { stroke:#92400e; }
.gm-ctrl-banner-partial .gm-ctrl-banner-title { color:#78350f; }
.gm-ctrl-banner-partial .gm-ctrl-banner-desc  { color:#92400e; }
.gm-ctrl-banner-partial .gm-ctrl-banner-btn { background:#fef3c7; color:#78350f; border:1.5px solid #fde68a; }
.gm-ctrl-banner-partial .gm-ctrl-banner-btn:hover { background:#fde68a; }

@media(max-width:600px){
    .gm-grid { grid-template-columns:1fr; }
    .gm-stats { flex-direction:column; }
    .gm-hero { border-radius:14px; padding:18px 16px; }
}
</style>

<div class="gm">
    <!-- 英雄页头 -->
    <div class="gm-hero">
        <div class="gm-hero-left">
            <div class="gm-hero-ico">
                <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg>
            </div>
            <div>
                <div class="gm-hero-title">游戏管理</div>
                <div class="gm-hero-sub">管理平台上所有游戏的展示与隐藏设置</div>
            </div>
        </div>
        <div class="gm-hero-actions">
            <a href="../teacher/gameupdate.aspx" class="gm-btn-add">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加游戏
            </a>
        </div>
    </div>

    <!-- 游戏开关状态（只读，直接反映 Room.Rgame 数据库字段） -->
    <div class="gm-ctrl-banner <%=BannerClass%>">
        <div class="gm-ctrl-banner-ico">
            <svg viewBox="0 0 24 24"><path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/></svg>
        </div>
        <div class="gm-ctrl-banner-body">
            <div class="gm-ctrl-banner-title"><%=BannerTitle%></div>
            <div class="gm-ctrl-banner-desc"><%=BannerDesc%></div>
        </div>
        <a href="../teacher/start.aspx" class="gm-ctrl-banner-btn">
            <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            前往上课页面设置
        </a>
    </div>

    <!-- 统计行 -->
    <div class="gm-stats" id="gmStats">
        <div class="gm-stat">
            <div class="gm-stat-ico purple"><svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg></div>
            <div><div class="gm-stat-val" id="statTotal">0</div><div class="gm-stat-lbl">游戏总数</div></div>
        </div>
        <div class="gm-stat">
            <div class="gm-stat-ico green"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="10 15 12 17 16 11"/></svg></div>
            <div><div class="gm-stat-val" id="statOn">0</div><div class="gm-stat-lbl">已显示</div></div>
        </div>
        <div class="gm-stat">
            <div class="gm-stat-ico slate"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></div>
            <div><div class="gm-stat-val" id="statOff">0</div><div class="gm-stat-lbl">已隐藏</div></div>
        </div>
    </div>

    <!-- 游戏列表容器 -->
    <div id="gmList"></div>
</div>

<!-- 编辑弹窗 -->
<div class="gm-overlay" id="editOverlay">
    <div class="gm-modal">
        <div class="gm-modal-hd">
            <div class="gm-modal-hd-ico">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            </div>
            <span class="gm-modal-hd-title">编辑游戏信息</span>
            <button type="button" class="gm-modal-hd-close" onclick="closeEdit()">
                <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="gm-modal-body">
            <input type="hidden" id="editId" />
            <div class="gm-field">
                <label>游戏名称 <span style="color:#ef4444">*</span></label>
                <input type="text" id="editName" placeholder="例如：推箱子" maxlength="100" />
            </div>
            <div class="gm-field">
                <label>游戏链接 <span style="color:#ef4444">*</span></label>
                <input type="text" id="editUrl" placeholder="例如：/sokoban/index.html 或 https://example.com/game" maxlength="500" />
            </div>
            <div class="gm-field">
                <label>备注说明（可选）</label>
                <textarea id="editDesc" placeholder="游戏简介…" maxlength="200"></textarea>
            </div>
            <div class="gm-field">
                <label>兑换学分</label>
                <div class="gm-field-row">
                    <input type="number" id="editCreditCost" min="0" max="9999" value="0" placeholder="0" />
                    <span class="gm-field-row-unit">学分&nbsp;（0&nbsp;=&nbsp;免费）</span>
                </div>
                <div class="gm-field-hint">设为 0 则学生免费游玩；设为正数则学生需花费对应学分兑换后才能解锁此游戏。</div>
            </div>
            <div class="gm-modal-msg" id="editMsg"></div>
        </div>
        <div class="gm-modal-foot">
            <button type="button" class="gm-modal-btn gm-modal-btn-cancel" onclick="closeEdit()">取消</button>
            <button type="button" class="gm-modal-btn gm-modal-btn-save" id="editSaveBtn" onclick="doEdit()">保存</button>
        </div>
    </div>
</div>

<script type="text/javascript">
(function(){
    // ── 初始数据（服务器端注入） ──────────────────────────────────
    var RAW = <%= gamesJson %>;
    var games = (RAW && RAW.games) ? RAW.games : [];

    // ── 工具函数 ─────────────────────────────────────────────────
    function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
    function post(url, params, cb){
        var parts = [];
        for(var k in params) parts.push(encodeURIComponent(k)+'='+encodeURIComponent(params[k]));
        var xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
        xhr.onreadystatechange = function(){
            if(xhr.readyState!==4) return;
            var t = xhr.responseText || '';
            if(t.charCodeAt(0)===0xFEFF) t = t.slice(1);
            try{ cb(JSON.parse(t)); }
            catch(e){
                // 提取 HTML 错误页面中的标题，避免显示原始 HTML
                var errMsg = 'HTTP ' + xhr.status + ' 服务器错误';
                var titleM = t.match(/<title[^>]*>([^<]{1,80})<\/title>/i);
                if(titleM) errMsg = titleM[1].trim();
                var descM  = t.match(/说明[：:][\s\S]{0,120}?(?=<br|<\/p|<\/div)/i);
                if(descM)  errMsg += '：' + descM[0].replace(/<[^>]+>/g,'').replace(/说明[：:]/,'').trim().substring(0,80);
                cb({ok:false,msg:errMsg});
            }
        };
        xhr.send(parts.join('&'));
    }

    // ── 渲染统计 ───────────────────────────────────────────────
    function renderStats(){
        var total = games.length;
        var on = 0;
        for(var i=0;i<games.length;i++) if(games[i].enabled!==false) on++;
        document.getElementById('statTotal').textContent = total;
        document.getElementById('statOn').textContent    = on;
        document.getElementById('statOff').textContent   = total - on;
    }

    // ── 调色板（每张卡片按序循环） ────────────────────────────
    var PAL = [
      {bar:'linear-gradient(90deg,#6d28d9,#a78bfa)',ico:'linear-gradient(135deg,#ede9fe,#ddd6fe)',stroke:'#7c3aed',solid:'#7c3aed'},
      {bar:'linear-gradient(90deg,#1d4ed8,#60a5fa)',ico:'linear-gradient(135deg,#dbeafe,#bfdbfe)',stroke:'#2563eb',solid:'#2563eb'},
      {bar:'linear-gradient(90deg,#065f46,#34d399)',ico:'linear-gradient(135deg,#d1fae5,#a7f3d0)',stroke:'#059669',solid:'#059669'},
      {bar:'linear-gradient(90deg,#92400e,#fcd34d)',ico:'linear-gradient(135deg,#fef3c7,#fde68a)',stroke:'#d97706',solid:'#d97706'},
      {bar:'linear-gradient(90deg,#9f1239,#fb7185)',ico:'linear-gradient(135deg,#ffe4e6,#fecdd3)',stroke:'#e11d48',solid:'#e11d48'},
      {bar:'linear-gradient(90deg,#075985,#38bdf8)',ico:'linear-gradient(135deg,#e0f2fe,#bae6fd)',stroke:'#0284c7',solid:'#0284c7'}
    ];
    // ── 渲染游戏列表 ──────────────────────────────────────────
    function renderList(){
        renderStats();
        var container = document.getElementById('gmList');
        if(games.length === 0){
            container.innerHTML =
                '<div class="gm-empty">'
              + '<svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg>'
              + '<h3>暂无游戏</h3><p>点击右上角按钮添加游戏</p>'
              + '<a href="../teacher/gameupdate.aspx" class="gm-btn-add" style="display:inline-flex;margin:0 auto;">'
              + '<svg viewBox="0 0 24 24" style="width:15px;height:15px;stroke:#fff;fill:none;stroke-width:2.5;stroke-linecap:round;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>添加游戏</a>'
              + '</div>';
            return;
        }
        var html = '<div class="gm-grid">';
        for(var i=0;i<games.length;i++){
            var g = games[i];
            var on = g.enabled !== false;
            var cost = (g.creditCost !== undefined && g.creditCost !== null) ? (parseInt(g.creditCost)||0) : 0;
            var p = PAL[i % PAL.length];
            var cStyle = on ? '--card-bar:'+p.bar+';--card-ico:'+p.ico+';--card-stroke:'+p.stroke+';--card-solid:'+p.solid+';' : '';
            html += '<div class="gm-card'+(on?'':' disabled')+'" id="card-'+esc(g.id)+'"'+(cStyle?' style="'+cStyle+'"':'')+'>'
              + '<div class="gm-card-bar '+(on?'enabled':'disabled')+'"></div>'
              + '<div class="gm-card-head">'
              + '  <div class="gm-card-ico"><svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg></div>'
              + '  <div class="gm-card-info">'
              + '    <div class="gm-card-name" title="'+esc(g.name)+'">'+esc(g.name)+'</div>'
              + '    <div class="gm-card-url"  title="'+esc(g.url)+'">'+esc(g.url)+'</div>'
              + '    <div class="gm-card-date">'+(g.addedDate||'')
              +       (cost>0?' &middot; <span style="color:#d97706;font-weight:600;">&#128176; '+cost+' 学分兑换</span>':'')
              + '    </div>'
              + '  </div>'
              + '  <label class="gm-toggle" title="'+(on?'点击隐藏此游戏':'点击展示此游戏')+'">'
              + '    <input type="checkbox" '+(on?'checked':'')+' onchange="doToggle(\''+esc(g.id)+'\',this)" />'
              + '    <div class="gm-toggle-track"></div><div class="gm-toggle-thumb"></div>'
              + '  </label>'
              + '</div>'
              + '<div class="gm-card-foot">'
              + '  <span class="gm-tag '+(on?'on':'off')+'" id="tag-'+esc(g.id)+'">'
              + '    <svg viewBox="0 0 24 24">'+(on?'<polyline points="20 6 9 17 4 12"/>':'<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>')+'</svg>'
              + '    '+(on?'已显示':'已隐藏')
              + '  </span>'
              + '  <span class="gm-spacer"></span>'
              + '  <a href="'+esc(g.url)+'" target="_blank" class="gm-btn gm-btn-preview">'
              + '    <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>预览'
              + '  </a>'
              + '  <button type="button" class="gm-btn gm-btn-edit" onclick="openEdit(\''+esc(g.id)+'\')">'
              + '    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>编辑'
              + '  </button>'
              + '  <button type="button" class="gm-btn gm-btn-del" onclick="doDelete(\''+esc(g.id)+'\')">'
              + '    <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>删除'
              + '  </button>'
              + '</div>'
              + '</div>';
        }
        html += '</div>';
        container.innerHTML = html;
    }


    // ── 单个开关切换 ───────────────────────────────────────────────
    window.doToggle = function(id, chk){
        var origChecked = chk.checked;
        chk.disabled = true;
        post('gamesave.ashx', {action:'toggle', id:id}, function(r){
            chk.disabled = false;
            if(!r.ok){ chk.checked = !origChecked; alert('操作失败：' + (r.msg||'')); return; }
            for(var i=0;i<games.length;i++){
                if(games[i].id===id){ games[i].enabled = r.enabled; break; }
            }
            renderList();
        });
    };

    // ── 删除 ─────────────────────────────────────────────
    window.doDelete = function(id){
        var g = null;
        for(var i=0;i<games.length;i++) if(games[i].id===id){ g=games[i]; break; }
        if(!g) return;
        if(!confirm('确认删除游戏"' + g.name + '"？\n\n（注意：仅从列表中移除，服务器文件不会被删除）')) return;
        post('gamesave.ashx', {action:'delete', id:id}, function(r){
            if(!r.ok){ alert('删除失败：' + (r.msg||'')); return; }
            for(var i=0;i<games.length;i++) if(games[i].id===id){ games.splice(i,1); break; }
            renderList();
        });
    };

    // ── 编辑弹窗 ─────────────────────────────────────────────
    window.openEdit = function(id){
        for(var i=0;i<games.length;i++){
            if(games[i].id===id){
                document.getElementById('editId').value          = games[i].id;
                document.getElementById('editName').value         = games[i].name||'';
                document.getElementById('editUrl').value          = games[i].url||'';
                document.getElementById('editDesc').value         = games[i].description||'';
                document.getElementById('editCreditCost').value   = (games[i].creditCost !== undefined && games[i].creditCost !== null) ? (parseInt(games[i].creditCost)||0) : 0;
                document.getElementById('editMsg').textContent = '';
                document.getElementById('editMsg').className = 'gm-modal-msg';
                document.getElementById('editSaveBtn').disabled = false;
                document.getElementById('editOverlay').classList.add('show');
                return;
            }
        }
    };
    window.closeEdit = function(){
        document.getElementById('editOverlay').classList.remove('show');
    };
    window.doEdit = function(){
        var id         = document.getElementById('editId').value.trim();
        var name       = document.getElementById('editName').value.trim();
        var url        = document.getElementById('editUrl').value.trim();
        var desc       = document.getElementById('editDesc').value.trim();
        var creditCost = parseInt(document.getElementById('editCreditCost').value)||0;
        if(creditCost < 0) creditCost = 0;
        var msg  = document.getElementById('editMsg');
        if(!name){ msg.textContent='请填写游戏名称'; msg.className='gm-modal-msg err'; return; }
        if(!url) { msg.textContent='请填写游戏链接'; msg.className='gm-modal-msg err'; return; }
        var btn = document.getElementById('editSaveBtn');
        btn.disabled = true; btn.textContent = '保存中…';
        post('gamesave.ashx', {action:'edit', id:id, name:name, url:url, desc:desc, creditCost:creditCost}, function(r){
            btn.disabled = false; btn.textContent = '保存';
            if(!r.ok){ msg.textContent='保存失败：'+(r.msg||''); msg.className='gm-modal-msg err'; return; }
            for(var i=0;i<games.length;i++){
                if(games[i].id===id){
                    games[i].name = name; games[i].url = url; games[i].description = desc; games[i].creditCost = creditCost; break;
                }
            }
            closeEdit(); renderList();
        });
    };

    // 点击遮罩关闭
    document.getElementById('editOverlay').addEventListener('click', function(e){
        if(e.target === this) closeEdit();
    });
    // ESC 关闭
    document.addEventListener('keydown', function(e){
        if(e.key==='Escape') closeEdit();
    });


    // ── 初始渲染 ─────────────────────────────────────────────────────
    renderList();

    // 将遮罩层移到 body 最末，避免父容器 overflow/stacking context 影响 fixed 定位
    (function(){
        var ov = document.getElementById('editOverlay');
        if (ov && ov.parentNode !== document.body) document.body.appendChild(ov);
    })();
})();
</script>
</asp:Content>
