<%@ Page Title="游戏中心" Language="C#" MasterPageFile="~/student/Stud.master"
    AutoEventWireup="true" Inherits="System.Web.UI.Page" %>

<script runat="server">
    protected class GameItem
    {
        public string Id = "";
        public string Name = "";
        public string Url = "";
        public string Description = "";
        public string AddedDate = "";
        public int CreditCost = 0;
    }

    protected System.Collections.Generic.List<GameItem> Games =
        new System.Collections.Generic.List<GameItem>();
    protected bool GamesEnabled = true;

    // Credit exchange fields
    protected int mySid = 0;
    protected int myEarnedScore = 0;
    protected int mySpentScore = 0;
    protected System.Collections.Generic.Dictionary<string, bool> myPurchasedGames =
        new System.Collections.Generic.Dictionary<string, bool>(System.StringComparer.Ordinal);

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        LoadGames();
        CheckRgame();
        LoadStudent();
        LoadPurchasedGames();
    }

    // ── 解析 games.json ────────────────────────────────────────
    private void LoadGames()
    {
        try
        {
            string path = Server.MapPath("~/App_Data/games.json");
            if (!System.IO.File.Exists(path)) return;
            string json = System.IO.File.ReadAllText(path, System.Text.Encoding.UTF8);

            System.Text.RegularExpressions.Match am =
                System.Text.RegularExpressions.Regex.Match(
                    json, "\"games\"\\s*:\\s*(\\[.*\\])",
                    System.Text.RegularExpressions.RegexOptions.Singleline);
            if (!am.Success) return;
            string arr = am.Groups[1].Value;

            int depth = 0, start = -1;
            for (int i = 0; i < arr.Length; i++)
            {
                char c = arr[i];
                if (c == '{') { if (depth == 0) start = i; depth++; }
                else if (c == '}')
                {
                    depth--;
                    if (depth == 0 && start >= 0)
                    {
                        string obj = arr.Substring(start, i - start + 1);
                        if (GetField(obj, "enabled") == "true")
                        {
                            GameItem gi = new GameItem();
                            gi.Id          = GetField(obj, "id");
                            gi.Name        = JsonUnescape(GetField(obj, "name"));
                            gi.Url         = JsonUnescape(GetField(obj, "url"));
                            gi.Description = JsonUnescape(GetField(obj, "description"));
                            gi.AddedDate   = GetField(obj, "addedDate");
                            string costStr = GetField(obj, "creditCost");
                            if (!string.IsNullOrEmpty(costStr)) { int cost = 0; if (int.TryParse(costStr, out cost)) gi.CreditCost = cost; }
                            Games.Add(gi);
                        }
                        start = -1;
                    }
                }
            }
        }
        catch { }
    }

    private string GetField(string objJson, string key)
    {
        System.Text.RegularExpressions.Match m =
            System.Text.RegularExpressions.Regex.Match(
                objJson, "\"" + key + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        if (m.Success) return m.Groups[1].Value;
        System.Text.RegularExpressions.Match mb =
            System.Text.RegularExpressions.Regex.Match(
                objJson, "\"" + key + "\"\\s*:\\s*(true|false)");
        if (mb.Success) return mb.Groups[1].Value;
        return "";
    }

    private string JsonUnescape(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\\"", "\"").Replace("\\\\", "\\")
                .Replace("\\n", " ").Replace("\\r", "").Replace("\\/", "/");
    }

    // ── 检查班级游戏权限 ───────────────────────────────────────
    private void CheckRgame()
    {
        try
        {
            int grade = 0, cls = 0;
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value)) return;
            string cookieVal = sc.Value;
            if (cookieVal.Contains("%"))
            {
                try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { }
            }
            Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
            if (ct == null) return;
            object m = Activator.CreateInstance(ct);
            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
            if (mi != null) mi.Invoke(m, new object[] { cookieVal });
            System.Reflection.PropertyInfo gp = ct.GetProperty("Sgrade");
            System.Reflection.PropertyInfo cp = ct.GetProperty("Sclass");
            if (gp != null) { object v = gp.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out grade); }
            if (cp != null) { object v = cp.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out cls); }
            if (grade <= 0 || cls <= 0) return;

            string cs = GetConnStr();
            if (string.IsNullOrEmpty(cs)) return;
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Rgame,1) FROM Room WHERE Rgrade=@g AND Rclass=@c", conn);
                cmd.Parameters.AddWithValue("@g", grade);
                cmd.Parameters.AddWithValue("@c", cls);
                cmd.CommandTimeout = 5;
                object result = cmd.ExecuteScalar();
                if (result != null && !Convert.ToBoolean(result))
                    GamesEnabled = false;
            }
        }
        catch { }
    }

    // ── 加载学生 Sid ——————————————————————————————————————————————————
    private void LoadStudent()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value)) return;
            string cookieVal = sc.Value;
            if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
            Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
            if (ct == null) return;
            object m = Activator.CreateInstance(ct);
            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
            if (mi != null) mi.Invoke(m, new object[] { cookieVal });
            System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
            if (p == null) return;
            object v = p.GetValue(m, null);
            if (v != null) int.TryParse(v.ToString(), out mySid);
        }
        catch { }
    }

    // ―― 加载已兑换游戏列表和学分信息 ——————————————————————————————
    private void LoadPurchasedGames()
    {
        if (mySid <= 0) return;
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // Auto-create GamePurchase table if needed
                try
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        @"IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='GamePurchase' AND xtype='U')
                        CREATE TABLE GamePurchase (
                            GPid     INT IDENTITY(1,1) PRIMARY KEY,
                            GPsid    INT NOT NULL,
                            GPgameid NVARCHAR(100) NOT NULL,
                            GPcost   INT NOT NULL DEFAULT 0,
                            GPdate   DATETIME NOT NULL DEFAULT GETDATE()
                        )", conn))
                    { cmd.CommandTimeout = 10; cmd.ExecuteNonQuery(); }
                }
                catch { }

                // Load purchased game IDs
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT GPgameid FROM GamePurchase WHERE GPsid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    { while (dr.Read()) { string gid = dr[0].ToString(); if (!myPurchasedGames.ContainsKey(gid)) myPurchasedGames.Add(gid, true); } }
                }

                // Load student earned score
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Sscore,0) FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) myEarnedScore = Convert.ToInt32(r);
                }

                // Load total credits already spent on games
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(SUM(GPcost),0) FROM GamePurchase WHERE GPsid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) mySpentScore = Convert.ToInt32(r);
                }
            }
        }
        catch { }
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connect timeout") < 0 &&
            cs.ToLower().IndexOf("connection timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    // 卡片颜色主题（按 index % 6）
    static readonly string[] CardBg   = { "#fffbeb","#eff6ff","#f0fdf4","#f5f3ff","#fff1f2","#f0f9ff" };
    static readonly string[] CardBdr  = { "#fde68a","#bfdbfe","#bbf7d0","#ddd6fe","#fecdd3","#bae6fd" };
    static readonly string[] CardIcBg = {
        "linear-gradient(135deg,#fde68a,#fcd34d)",
        "linear-gradient(135deg,#bfdbfe,#93c5fd)",
        "linear-gradient(135deg,#bbf7d0,#6ee7b7)",
        "linear-gradient(135deg,#ddd6fe,#c4b5fd)",
        "linear-gradient(135deg,#fecdd3,#fda4af)",
        "linear-gradient(135deg,#bae6fd,#7dd3fc)"
    };
    static readonly string[] CardIcStroke = { "#92400e","#1d4ed8","#065f46","#5b21b6","#9f1239","#0369a1" };
    static readonly string[] CardBtnBg    = { "#f59e0b","#3b82f6","#10b981","#8b5cf6","#f43f5e","#0ea5e9" };
    static readonly string[] CardNameClr  = { "#78350f","#1e3a8a","#14532d","#3b0764","#881337","#0c4a6e" };
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">
<style>
/* ===== 游戏中心 ===== */
.gl { max-width:1000px; margin:0 auto; font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

/* 页头 */
.gl-hd {
    display:flex; align-items:center; justify-content:space-between;
    flex-wrap:wrap; gap:12px; margin-bottom:24px;
}
.gl-hd-left  { display:flex; align-items:center; gap:14px; }
.gl-hd-icon {
    width:52px; height:52px; border-radius:14px; flex-shrink:0;
    background:linear-gradient(135deg,#fbbf24,#f59e0b);
    display:flex; align-items:center; justify-content:center;
    box-shadow:0 4px 14px rgba(245,158,11,.28);
}
.gl-hd-icon svg { width:28px; height:28px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.gl-hd-title { font-size:20px; font-weight:800; color:#1e293b; margin:0 0 3px; }
.gl-hd-sub   { font-size:12px; color:#94a3b8; margin:0; }
.gl-hd-back  {
    display:flex; align-items:center; gap:5px; padding:8px 16px;
    border-radius:9px; background:#f1f5f9; border:none; color:#475569;
    font-size:12px; font-weight:600; text-decoration:none; transition:all .15s;
    font-family:inherit; cursor:pointer;
}
.gl-hd-back:hover  { background:#e2e8f0; color:#0f172a; }
.gl-hd-back svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }

/* 禁用提示 */
.gl-banned {
    display:flex; align-items:flex-start; gap:12px;
    background:#fff7ed; border:1.5px solid #fed7aa; border-radius:14px;
    padding:16px 20px; margin-bottom:20px;
}
.gl-banned-ico {
    width:36px; height:36px; border-radius:10px; flex-shrink:0;
    background:linear-gradient(135deg,#fed7aa,#fdba74);
    display:flex; align-items:center; justify-content:center;
}
.gl-banned-ico svg { width:18px; height:18px; stroke:#ea580c; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.gl-banned-title { font-size:14px; font-weight:700; color:#9a3412; margin:0 0 4px; }
.gl-banned-desc  { font-size:12px; color:#c2410c; margin:0; line-height:1.6; }

/* 空状态 */
.gl-empty {
    text-align:center; padding:60px 20px; color:#94a3b8;
}
.gl-empty-ico { margin-bottom:14px; }
.gl-empty-ico svg { width:56px; height:56px; stroke:#cbd5e1; fill:none; stroke-width:1.2; stroke-linecap:round; stroke-linejoin:round; }
.gl-empty-title { font-size:16px; font-weight:700; color:#64748b; margin:0 0 6px; }
.gl-empty-sub   { font-size:13px; margin:0; }

/* 游戏卡片网格 */
.gl-grid {
    display:grid;
    grid-template-columns:repeat(auto-fill, minmax(220px,1fr));
    gap:16px;
}

/* 游戏卡片 */
.gl-card {
    border-radius:16px; border:1.5px solid;
    overflow:hidden; display:flex; flex-direction:column;
    box-shadow:0 2px 8px rgba(0,0,0,.04);
    transition:all .2s; text-decoration:none;
    position:relative;
}
.gl-card:hover {
    transform:translateY(-3px);
    box-shadow:0 8px 24px rgba(0,0,0,.10);
}
.gl-card.gl-disabled {
    opacity:.6; pointer-events:none; filter:grayscale(.4);
}
.gl-card-top {
    padding:20px 20px 14px;
    display:flex; align-items:center; gap:12px;
}
.gl-card-icon {
    width:44px; height:44px; border-radius:12px; flex-shrink:0;
    display:flex; align-items:center; justify-content:center;
    box-shadow:0 2px 8px rgba(0,0,0,.10);
}
.gl-card-icon svg { width:22px; height:22px; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.gl-card-meta { flex:1; min-width:0; }
.gl-card-name {
    font-size:14px; font-weight:800; margin:0 0 3px;
    overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
    line-height:1.3;
}
.gl-card-date { font-size:10px; color:#94a3b8; margin:0; }

.gl-card-desc {
    padding:0 20px 14px;
    font-size:12px; color:#64748b; line-height:1.6; flex:1;
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical;
    overflow:hidden;
}
.gl-card-nodesc {
    padding:0 20px 8px; font-size:12px; color:#cbd5e1; font-style:italic;
}

/* 开始按钮 */
.gl-card-btn {
    display:flex; align-items:center; justify-content:center; gap:6px;
    margin:0 16px 16px; padding:10px;
    border-radius:10px; color:#fff;
    font-size:12px; font-weight:700; text-decoration:none; letter-spacing:.3px;
    box-shadow:0 2px 8px rgba(0,0,0,.15); transition:all .15s;
}
.gl-card-btn:hover { filter:brightness(1.08); transform:none; }
.gl-card-btn svg { width:14px; height:14px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }

/* 禁用角标 */
.gl-card-lock {
    position:absolute; top:10px; right:10px;
    width:22px; height:22px; border-radius:6px;
    background:rgba(0,0,0,.12); display:flex; align-items:center; justify-content:center;
}
.gl-card-lock svg { width:12px; height:12px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }

/* 学分信息栏 */
.gl-credit-bar {
    display:flex; align-items:center; gap:10px; flex-wrap:wrap;
    background:linear-gradient(135deg,#fffbeb,#fef3c7);
    border:1.5px solid #fde68a; border-radius:12px;
    padding:10px 16px; margin-bottom:16px; font-size:13px;
}
.gl-credit-bar-ico { font-size:18px; flex-shrink:0; }
.gl-credit-avail { font-weight:700; color:#92400e; font-size:15px; }
.gl-credit-detail { color:#78350f; font-size:12px; }

/* 兑换按钮 */
.gl-card-btn-buy {
    display:flex; align-items:center; justify-content:center; gap:6px;
    margin:0 16px 16px; padding:10px;
    border-radius:10px; color:#fff; border:none; cursor:pointer; font-family:inherit;
    font-size:12px; font-weight:700; letter-spacing:.3px;
    box-shadow:0 2px 8px rgba(0,0,0,.15); transition:all .15s; width:calc(100% - 32px);
}
.gl-card-btn-buy:hover:not(:disabled) { filter:brightness(1.08); }
.gl-card-btn-buy:disabled { opacity:.5; cursor:not-allowed; box-shadow:none; }

/* 已兑换等待开启按钮样式 */
.gl-card-btn-waiting {
    opacity:.7 !important; cursor:default !important;
    pointer-events:none;
}

/* 需兑换标记 */
.gl-card-need-buy {
    position:absolute; top:10px; right:10px;
    background:linear-gradient(135deg,#fde68a,#f59e0b);
    border-radius:8px; padding:2px 7px;
    font-size:10px; font-weight:700; color:#78350f;
    box-shadow:0 1px 4px rgba(245,158,11,.3);
}

@media(max-width:480px){ .gl-grid { grid-template-columns:1fr 1fr; } }
@media(max-width:340px){ .gl-grid { grid-template-columns:1fr; } }
</style>

<div class="gl">
    <!-- 页头 -->
    <div class="gl-hd">
        <div class="gl-hd-left">
            <div class="gl-hd-icon">
                <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/><line x1="8" y1="14" x2="12" y2="14"/><line x1="10" y1="12" x2="10" y2="16"/><circle cx="16" cy="13" r="1" fill="#fff" stroke="none"/><circle cx="18" cy="15" r="1" fill="#fff" stroke="none"/></svg>
            </div>
            <div>
                <div class="gl-hd-title">游戏中心</div>
                <div class="gl-hd-sub">
                    <% if (Games.Count > 0) { %>共 <%= Games.Count %> 款游戏
                    <% } else { %>暂无游戏，请联系老师添加<% } %>
                </div>
            </div>
        </div>
        <a href="../student/myfinger.aspx" class="gl-hd-back">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
            返回打字练习
        </a>
    </div>

    <!-- 游戏禁用提示 -->
    <% if (!GamesEnabled) { %>
    <div class="gl-banned">
        <div class="gl-banned-ico">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div>
            <div class="gl-banned-title">游戏功能已被老师暂时关闭</div>
            <div class="gl-banned-desc">老师正在上课，游戏暂不可用。请认真完成学习任务，游戏开放后即可界玩！</div>
        </div>
    </div>
    <% } %>

    <!-- 学分信息栏（有需兑换的游戏时显示） -->
    <% bool anyPaidGames = false;
       foreach (GameItem gCheck in Games) { if (gCheck.CreditCost > 0) { anyPaidGames = true; break; } }
       if (anyPaidGames) {
           int availCred = Math.Max(0, myEarnedScore - mySpentScore); %>
    <div class="gl-credit-bar">
        <span class="gl-credit-bar-ico">&#128176;</span>
        <span>我的可用学分：<span class="gl-credit-avail"><%= availCred %></span></span>
        <% if (mySid > 0) { %>
        <span class="gl-credit-detail">（共获得 <%= myEarnedScore %> 学分，已兑换游戏消耗 <%= mySpentScore %> 学分）</span>
        <% } else { %>
        <span class="gl-credit-detail">请先登录学生账号兑换游戏</span>
        <% } %>
    </div>
    <% } %>

    <!-- 空状态 -->
    <% if (Games.Count == 0) { %>
    <div class="gl-empty">
        <div class="gl-empty-ico">
            <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg>
        </div>
        <div class="gl-empty-title">还没有游戏</div>
        <div class="gl-empty-sub">老师还未添加任何游戏，请耐心等待~</div>
    </div>
    <% } else { %>

    <!-- 游戏网格 -->
    <div class="gl-grid">
        <% int myAvailableCredits = Math.Max(0, myEarnedScore - mySpentScore);
           for (int i = 0; i < Games.Count; i++) {
            GameItem g = Games[i];
            int ci   = i % 6;
            string btnStyle = "background:" + CardBtnBg[ci] + ";box-shadow:0 2px 8px " + CardBtnBg[ci] + "44";
            // Credit exchange state
            bool purchased     = myPurchasedGames.ContainsKey(g.Id);
            bool needsPurchase = (g.CreditCost > 0) && !purchased;
            bool canPlay       = !needsPurchase && GamesEnabled;
            bool isGrey        = !needsPurchase && !canPlay; // teacher disabled, but already unlocked/free
            bool canAfford     = mySid > 0 && myAvailableCredits >= g.CreditCost;
            string gameUrl     = canPlay ? Server.HtmlEncode(g.Url) : "javascript:void(0);";
        %>
        <div class="gl-card<%= isGrey?" gl-disabled":"" %>"
             style="background:<%= CardBg[ci] %>;border-color:<%= CardBdr[ci] %>">
            <% if (needsPurchase) { %>
            <div class="gl-card-need-buy">&#128176; <%= g.CreditCost %> 学分</div>
            <% } else if (isGrey) { %>
            <div class="gl-card-lock">
                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <% } %>
            <div class="gl-card-top">
                <div class="gl-card-icon" style="background:<%= CardIcBg[ci] %>">
                    <svg viewBox="0 0 24 24" style="stroke:<%= CardIcStroke[ci] %>">
                        <rect x="2" y="7" width="20" height="15" rx="2" ry="2"/>
                        <polyline points="17 2 12 7 7 2"/>
                        <line x1="8" y1="14" x2="12" y2="14"/>
                        <line x1="10" y1="12" x2="10" y2="16"/>
                        <circle cx="16" cy="13" r="1" fill="<%= CardIcStroke[ci] %>" stroke="none"/>
                        <circle cx="18" cy="15" r="1" fill="<%= CardIcStroke[ci] %>" stroke="none"/>
                    </svg>
                </div>
                <div class="gl-card-meta">
                    <div class="gl-card-name" style="color:<%= CardNameClr[ci] %>">
                        <%= Server.HtmlEncode(g.Name) %>
                    </div>
                    <% if (!string.IsNullOrEmpty(g.AddedDate)) { %>
                    <div class="gl-card-date"><%= g.AddedDate %>
                        <% if (g.CreditCost > 0 && purchased) { %>
                        &nbsp;<span style="color:#16a34a;font-weight:600;">&#10003; 已兑换</span>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
            <% if (!string.IsNullOrEmpty(g.Description)) { %>
            <div class="gl-card-desc"><%= Server.HtmlEncode(g.Description) %></div>
            <% } else { %>
            <div class="gl-card-nodesc">暂无介绍</div>
            <% } %>
            <% if (needsPurchase) { %>
            <% string buyDisabled = canAfford ? "" : "disabled=\"disabled\""; %>
            <% string buyOnclick = canAfford
                   ? "onclick=\"buyGame(this,'" + g.Id.Replace("'","&#39;").Replace("\\","\\\\") + "','"
                     + Server.HtmlEncode(g.Name).Replace("'","&#39;") + "'," + g.CreditCost + ")\""
                   : ""; %>
            <button type="button" class="gl-card-btn-buy" style="<%= btnStyle %>" <%= buyOnclick %> <%= buyDisabled %>>
                &#128176; 兑换 <%= g.CreditCost %> 学分
                <% if (!canAfford && mySid <= 0) { %>（请先登录）<% } else if (!canAfford) { %>（学分不足）<% } %>
            </button>
            <% } else if (canPlay) { %>
            <a href="<%= gameUrl %>" target="_blank" class="gl-card-btn"
               style="<%= btnStyle %>">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polygon points="10 8 16 12 10 16 10 8" fill="#fff" stroke="none"/></svg>
                开始游戏
            </a>
            <% } else { %>
            <a href="javascript:void(0);" class="gl-card-btn gl-card-btn-waiting"
               style="<%= btnStyle %>">
                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <% if (purchased) { %>已兑换——等待老师开启<% } else { %>老师暂未开启<% } %>
            </a>
            <% } %>
        </div>
        <% } %>
    </div>

    <% } %>
</div>
<script type="text/javascript">
var GL_MY_SID = <%= mySid %>;

function buyGame(btn, gameId, gameName, cost) {
    if (GL_MY_SID <= 0) { alert('请先登录学生账号'); return; }
    if (!confirm('确定花费 ' + cost + ' 学分兑换『' + gameName + '』的游戏权限？\n\n兑换后需老师开启游戏才可游玩。')) return;
    btn.disabled = true;
    btn.innerHTML = '兑换中…';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'gamepurchase.ashx', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        var t = xhr.responseText || '';
        if (t.charCodeAt(0) === 0xFEFF) t = t.slice(1);
        var r;
        try { r = JSON.parse(t); } catch(e) { r = {ok:false, msg:'服务器响应异常'}; }
        if (r.ok) {
            btn.style.background = '#10b981';
            btn.innerHTML = '&#10003; 兑换成功！刷新中…';
            setTimeout(function() { location.reload(); }, 1000);
        } else {
            btn.disabled = false;
            btn.innerHTML = '&#128176; 兑换 ' + cost + ' 学分';
            alert('兑换失败：' + (r.msg || '未知错误'));
        }
    };
    xhr.send('action=buy&gameId=' + encodeURIComponent(gameId));
}
</script>
</asp:Content>
