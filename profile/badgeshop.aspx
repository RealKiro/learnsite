<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
    protected System.Data.DataTable dtShopItems = null;
    protected string pageMsg = "";
    protected string pageMsgType = ""; // success / error

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private string GetProp(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo p = model.GetType().GetProperty(propName);
        if (p == null) return "";
        object v = p.GetValue(model, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, System.Text.Encoding.UTF8); } catch { } }
        return s;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadStudent();
        if (mySid <= 0) { pageMsg = "请先登录学生账号"; pageMsgType = "error"; }
        LoadShopItems();
    }

    private void LoadStudent()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    string sidStr = GetProp(m, "Sid");
                    if (!string.IsNullOrEmpty(sidStr)) int.TryParse(sidStr, out mySid);
                }
            }
        }
        catch { }
    }

    private void LoadShopItems()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(
                    "SELECT Sid,Sname,Sdesc,Sicon,Scost,Sstock FROM BadgeShopItem WHERE ISNULL(Sactive,1)=1 ORDER BY Sid", conn);
                dtShopItems = new System.Data.DataTable();
                da.Fill(dtShopItems);
            }
        }
        catch { }
    }

    protected string RenderItemIcon(string icon)
    {
        // 如果为空，使用emoji作为默认图标
        if (string.IsNullOrEmpty(icon))
        {
            return "🎁";
        }
        
        // 如果是emoji或单个字符（不包含路径分隔符和文件扩展名），直接返回
        if (icon.Length <= 2 && !icon.Contains("/") && !icon.Contains("."))
        {
            return icon;
        }
        
        // 处理图片路径
        string imgPath = icon;
        
        // 如果不是完整URL，处理相对路径
        if (!icon.StartsWith("http://") && !icon.StartsWith("https://"))
        {
            // 如果以~/开头，使用ResolveUrl处理
            if (icon.StartsWith("~/"))
            {
                imgPath = ResolveUrl(icon);
            }
            // 如果以../开头，保持原样（相对路径）
            else if (icon.StartsWith("../"))
            {
                imgPath = icon;
            }
            // 如果以/开头，保持原样（绝对路径）
            else if (icon.StartsWith("/"))
            {
                imgPath = icon;
            }
            // 否则，假设是相对于根目录的路径，添加/
            else
            {
                imgPath = "/" + icon;
            }
        }
        
        // 返回img标签，加载失败时显示emoji
        return "<img src=\"" + Server.HtmlEncode(imgPath) + "\" onerror=\"this.outerHTML='🎁';\" alt=\"商品图片\" />";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" runat="Server">
<style>
    .bshop-page { animation: bshopFade .4s ease; }
    @keyframes bshopFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 卡片钱包 */
    .bshop-wallet {
        background: linear-gradient(135deg, #f59e0b 0%, #fbbf24 50%, #f97316 100%);
        border-radius: 16px; padding: 24px 28px; margin-bottom: 20px; color: #fff;
        display: flex; align-items: center; gap: 20px; position: relative; overflow: hidden;
    }
    .bshop-wallet::before { content: ''; position: absolute; top: -30px; right: -10px; width: 100px; height: 100px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .bshop-wallet-icon { font-size: 36px; line-height: 1; position: relative; z-index: 1; }
    .bshop-wallet-info { position: relative; z-index: 1; }
    .bshop-wallet-info h2 { font-size: 18px; font-weight: 700; margin: 0 0 4px; }
    .bshop-wallet-info .bshop-pts { font-size: 32px; font-weight: 800; line-height: 1; }
    .bshop-wallet-info .bshop-pts-unit { font-size: 14px; font-weight: 500; margin-left: 4px; }
    .bshop-wallet-detail { margin-left: auto; display: flex; gap: 20px; position: relative; z-index: 1; }
    .bshop-wallet-stat { text-align: center; }
    .bshop-wallet-stat .ws-label { font-size: 11px; opacity: .8; }
    .bshop-wallet-stat .ws-value { font-size: 20px; font-weight: 700; }

    /* 消息 */
    .bshop-msg { padding: 12px 18px; border-radius: 10px; font-size: 13px; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
    .bshop-msg svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2; flex-shrink: 0; }
    .bshop-msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .bshop-msg-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }

    /* 商品网格 */
    .bshop-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; }
    .bshop-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .bshop-card-head svg { width: 18px; height: 18px; fill: none; stroke: #ec4899; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bshop-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }

    .bshop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; padding: 20px 24px; }
    .bshop-item {
        border: 1px solid #e5e7eb; border-radius: 14px; padding: 20px 16px;
        text-align: center; transition: all .2s; background: #fff; display: flex; flex-direction: column; align-items: center;
    }
    .bshop-item:hover { border-color: #fbcfe8; box-shadow: 0 4px 16px rgba(236,72,153,.1); transform: translateY(-2px); }
    .bshop-item-icon {
        width: 64px; height: 64px; margin-bottom: 12px; background: #fdf2f8; border-radius: 14px;
        display: flex; align-items: center; justify-content: center; font-size: 36px;
    }
    .bshop-item-icon img { width: 48px; height: 48px; object-fit: contain; }
    .bshop-item-icon svg { width: 28px; height: 28px; fill: none; stroke: #ec4899; stroke-width: 1.5; }
    .bshop-item-name { font-size: 14px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
    .bshop-item-desc { font-size: 11px; color: #64748b; margin-bottom: 10px; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .bshop-item-cost { font-size: 18px; font-weight: 800; color: #ec4899; margin-bottom: 4px; }
    .bshop-item-cost-unit { font-size: 12px; font-weight: 500; }
    .bshop-item-stock { font-size: 11px; color: #94a3b8; margin-bottom: 12px; }
    .bshop-item-btn {
        display: inline-flex; align-items: center; gap: 6px; padding: 8px 24px;
        border-radius: 8px; font-size: 13px; font-weight: 600; border: none;
        background: linear-gradient(135deg, #ec4899, #f472b6); color: #fff;
        cursor: pointer; transition: all .18s; font-family: inherit;
        box-shadow: 0 2px 8px rgba(236,72,153,.2);
    }
    .bshop-item-btn:hover { background: linear-gradient(135deg, #db2777, #ec4899); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(236,72,153,.3); }
    .bshop-item-btn:disabled { background: #e2e8f0; color: #94a3b8; cursor: not-allowed; box-shadow: none; transform: none; }
    .bshop-item-btn svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; }

    .bshop-empty { padding: 60px 20px; text-align: center; color: #94a3b8; font-size: 14px; }

    /* 卡片提示 */
    .bshop-tip-box {
        background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px;
        padding: 10px 16px; font-size: 12px; color: #92400e;
        display: flex; align-items: center; gap: 8px; margin-bottom: 16px;
    }

    @media (max-width: 768px) {
        .bshop-wallet { flex-direction: column; align-items: flex-start; gap: 12px; }
        .bshop-wallet-detail { margin-left: 0; }
        .bshop-grid { grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 12px; padding: 16px; }
    }
</style>

<div class="bshop-page">
    <!-- 宠物卡片钱包 -->
    <div class="bshop-wallet">
        <div class="bshop-wallet-icon">🎴</div>
        <div class="bshop-wallet-info">
            <h2>宠物卡片兑换商城</h2>
            <div class="bshop-pts"><span id="shopCardCount">…</span><span class="bshop-pts-unit"> 张可用卡片</span></div>
        </div>
        <div class="bshop-wallet-detail">
            <div class="bshop-wallet-stat">
                <div class="ws-label">获取方式</div>
                <div class="ws-value">🐾</div>
            </div>
            <div class="bshop-wallet-stat">
                <div class="ws-label">培养宠物至全属性满值</div>
                <div class="ws-value" style="font-size:12px;">宠物乐园毕业</div>
            </div>
        </div>
    </div>
    <!-- 卡片获取提示 -->
    <div class="bshop-tip-box">💡 前往 <a href="mypet.aspx" style="color:#92400e;font-weight:700;">宠物乐园</a> 培养宠物，将健康、清洁、心情、饱食四项属性全部养满至100，宠物即可毕业并获得宠物卡片。</div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="bshop-msg <%= pageMsgType == "success" ? "bshop-msg-success" : "bshop-msg-error" %>">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= Server.HtmlEncode(pageMsg) %>
    </div>
    <% } %>
    <div id="shopMsgArea"></div>

    <!-- 商品列表 -->
    <div class="bshop-card">
        <div class="bshop-card-head">
            <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
            <h3>卡片兑换商品</h3>
        </div>
        <% if (dtShopItems != null && dtShopItems.Rows.Count > 0) { %>
        <div class="bshop-grid">
            <% foreach (System.Data.DataRow row in dtShopItems.Rows) {
                int sid = Convert.ToInt32(row["Sid"]);
                string sname = row["Sname"] == DBNull.Value ? "" : row["Sname"].ToString();
                string sdesc = row["Sdesc"] == DBNull.Value ? "" : row["Sdesc"].ToString();
                string sicon = row["Sicon"] == DBNull.Value ? "" : row["Sicon"].ToString();
                int scost = row["Scost"] == DBNull.Value ? 1 : Convert.ToInt32(row["Scost"]);
                if (scost < 1) scost = 1;
                int sstock = row["Sstock"] == DBNull.Value ? -1 : Convert.ToInt32(row["Sstock"]);
                bool canExchange = mySid > 0 && sstock != 0;
            %>
            <div class="bshop-item">
                <div class="bshop-item-icon"><%= RenderItemIcon(sicon) %></div>
                <div class="bshop-item-name"><%= Server.HtmlEncode(sname) %></div>
                <% if (!string.IsNullOrEmpty(sdesc)) { %><div class="bshop-item-desc" title="<%= Server.HtmlEncode(sdesc) %>"><%= Server.HtmlEncode(sdesc) %></div><% } %>
                <div class="bshop-item-cost"><%= scost %><span class="bshop-item-cost-unit"> 张卡片</span></div>
                <div class="bshop-item-stock"><%= sstock < 0 ? "库存充足" : (sstock > 0 ? "剩余 " + sstock + " 件" : "已售罄") %></div>
                <input type="button" value="🎴 卡片兑换" class="bshop-item-btn"
                    onclick="doCardExchange(<%= sid %>, '<%= Server.HtmlEncode(sname).Replace("'","") %>', <%= scost %>)"
                    <%= canExchange ? "" : "disabled=\"disabled\"" %> />
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="bshop-empty">暂无商品，请等待老师添加兑换项目</div>
        <% } %>
    </div>
</div>

<script type="text/javascript">
var SID_SHOP = <%= mySid %>;
var K_CARDS_SHOP = "ls_pet_cards_" + SID_SHOP;

function getShopCardCount() {
    try {
        var cards = JSON.parse(localStorage.getItem(K_CARDS_SHOP) || "[]");
        return Array.isArray(cards) ? cards.length : 0;
    } catch(e) { return 0; }
}

function updateShopCardDisplay() {
    var el = document.getElementById("shopCardCount");
    if (el) el.textContent = getShopCardCount();
}

function showShopMsg(msg, ok) {
    var el = document.getElementById("shopMsgArea");
    if (!el) return;
    var cls = ok ? "bshop-msg-success" : "bshop-msg-error";
    var icon = ok
        ? '<svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>'
        : '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>';
    el.innerHTML = '<div class="bshop-msg ' + cls + '">' + icon + msg + '</div>';
    setTimeout(function() { el.innerHTML = ''; }, 6000);
}

function doCardExchange(itemId, itemName, cardCost) {
    if (SID_SHOP <= 0) { showShopMsg('请先登录学生账号', false); return; }
    var count = getShopCardCount();
    if (count < cardCost) {
        showShopMsg('宠物卡片不足，需要 ' + cardCost + ' 张，当前只有 ' + count + ' 张。\n请在宠物乐园将宠物全属性养满后毕业获取卡片。', false);
        return;
    }
    if (!confirm('确定要用 ' + cardCost + ' 张宠物卡片兑换「' + itemName + '」吗？')) return;

    var fd = new FormData();
    fd.append('itemId', String(itemId));
    fd.append('cardCost', String(cardCost));

    fetch('petcardexchange.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res && res.success) {
                try {
                    var cards = JSON.parse(localStorage.getItem(K_CARDS_SHOP) || '[]');
                    if (Array.isArray(cards)) {
                        cards.splice(0, cardCost);
                        localStorage.setItem(K_CARDS_SHOP, JSON.stringify(cards));
                    }
                } catch(e) {}
                updateShopCardDisplay();
                showShopMsg('🎉 兑换成功！「' + (res.itemName || itemName) + '」已提交申请，等待老师审核发放', true);
            } else {
                showShopMsg((res && res.msg) ? res.msg : '兑换失败，请重试', false);
            }
        })
        .catch(function() { showShopMsg('网络错误，请稍后重试', false); });
}

document.addEventListener('DOMContentLoaded', updateShopCardDisplay);
</script>
</asp:Content>
