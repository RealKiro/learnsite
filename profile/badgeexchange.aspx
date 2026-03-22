<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
    protected int myTotalPoints = 0;
    protected int myUsedPoints = 0;
    protected int myAvailablePoints = 0;
    protected System.Data.DataTable dtExchanges = null;
    protected int pendingCount = 0;
    protected int approvedCount = 0;
    protected int rejectedCount = 0;

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
        LoadData();
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

    private void LoadData()
    {
        if (mySid <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();

                // 积分统计
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(SUM(ISNULL(b.Bpoints,0)),0) FROM BadgeAward a LEFT JOIN Badge b ON a.Abid=b.Bid WHERE a.Asid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) myTotalPoints = Convert.ToInt32(r);
                }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(SUM(Epoints),0) FROM BadgeExchange WHERE Esid=@sid AND Estatus IN (0,1)", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) myUsedPoints = Convert.ToInt32(r);
                }
                myAvailablePoints = myTotalPoints - myUsedPoints;
                if (myAvailablePoints < 0) myAvailablePoints = 0;

                // 兑换记录
                string sql = @"SELECT e.Eid, e.Edate, e.Epoints, e.Estatus, e.Enote, e.Ereviewdate,
                    i.Sname AS ItemName, i.Sicon AS ItemIcon
                    FROM BadgeExchange e
                    LEFT JOIN BadgeShopItem i ON e.Eitemid=i.Sid
                    WHERE e.Esid=@sid
                    ORDER BY e.Eid DESC";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@sid", mySid);
                dtExchanges = new System.Data.DataTable();
                da.Fill(dtExchanges);

                // 统计各状态
                foreach (System.Data.DataRow row in dtExchanges.Rows)
                {
                    int status = row["Estatus"] == DBNull.Value ? 0 : Convert.ToInt32(row["Estatus"]);
                    if (status == 0) pendingCount++;
                    else if (status == 1) approvedCount++;
                    else if (status == 2) rejectedCount++;
                }
            }
        }
        catch { }
    }

    protected string GetStatusText(int status)
    {
        if (status == 0) return "待审核";
        if (status == 1) return "已通过";
        if (status == 2) return "已拒绝";
        return "未知";
    }

    protected string GetStatusClass(int status)
    {
        if (status == 0) return "bex-status-pending";
        if (status == 1) return "bex-status-approved";
        if (status == 2) return "bex-status-rejected";
        return "";
    }

    protected string GetStatusIcon(int status)
    {
        if (status == 0) return "<svg viewBox=\"0 0 24 24\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><polyline points=\"12 6 12 12 16 14\"/></svg>";
        if (status == 1) return "<svg viewBox=\"0 0 24 24\"><path d=\"M22 11.08V12a10 10 0 11-5.93-9.14\"/><polyline points=\"22 4 12 14.01 9 11.01\"/></svg>";
        if (status == 2) return "<svg viewBox=\"0 0 24 24\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><line x1=\"15\" y1=\"9\" x2=\"9\" y2=\"15\"/><line x1=\"9\" y1=\"9\" x2=\"15\" y2=\"15\"/></svg>";
        return "";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" runat="Server">
<style>
    .bex-page { animation: bexFade .4s ease; }
    @keyframes bexFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 统计 */
    .bex-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 20px; }
    .bex-stat-card {
        background: #fff; border-radius: 12px; border: 1px solid #e5e7eb; padding: 16px 18px;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); text-align: center;
    }
    .bex-stat-label { font-size: 11px; color: #94a3b8; font-weight: 500; margin-bottom: 4px; }
    .bex-stat-value { font-size: 22px; font-weight: 800; line-height: 1; }
    .bex-stat-card:nth-child(1) .bex-stat-value { color: #6366f1; }
    .bex-stat-card:nth-child(2) .bex-stat-value { color: #f59e0b; }
    .bex-stat-card:nth-child(3) .bex-stat-value { color: #10b981; }
    .bex-stat-card:nth-child(4) .bex-stat-value { color: #ef4444; }

    /* 记录列表 */
    .bex-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; }
    .bex-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .bex-card-head svg { width: 18px; height: 18px; fill: none; stroke: #3b82f6; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bex-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }

    .bex-list { padding: 0; }
    .bex-item {
        display: flex; align-items: center; gap: 16px; padding: 16px 24px;
        border-bottom: 1px solid #f1f5f9; transition: background .1s;
    }
    .bex-item:last-child { border-bottom: none; }
    .bex-item:hover { background: #f8fafc; }
    .bex-item-icon {
        width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .bex-item-icon img { width: 32px; height: 32px; object-fit: contain; }
    .bex-item-icon svg { width: 20px; height: 20px; fill: none; stroke: #3b82f6; stroke-width: 1.5; }
    .bex-item-icon-default { background: #eff6ff; }
    .bex-item-meta { flex: 1; min-width: 0; }
    .bex-item-name { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 2px; }
    .bex-item-date { font-size: 11px; color: #94a3b8; }
    .bex-item-note { font-size: 11px; color: #64748b; margin-top: 2px; }
    .bex-item-pts { font-size: 15px; font-weight: 700; color: #ec4899; flex-shrink: 0; white-space: nowrap; }
    .bex-item-pts span { font-size: 11px; font-weight: 500; color: #94a3b8; }

    .bex-status { display: inline-flex; align-items: center; gap: 4px; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; flex-shrink: 0; }
    .bex-status svg { width: 12px; height: 12px; fill: none; stroke: currentColor; stroke-width: 2; }
    .bex-status-pending { background: #fef3c7; color: #92400e; }
    .bex-status-approved { background: #dcfce7; color: #16a34a; }
    .bex-status-rejected { background: #fee2e2; color: #dc2626; }

    .bex-empty { padding: 60px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
    .bex-empty svg { width: 48px; height: 48px; stroke: #d1d5db; fill: none; stroke-width: 1.5; margin-bottom: 12px; }

    .bex-actions { display: flex; gap: 10px; padding: 16px 24px; border-top: 1px solid #f1f5f9; }
    .bex-link {
        display: inline-flex; align-items: center; gap: 6px; padding: 8px 20px;
        border-radius: 8px; font-size: 13px; font-weight: 500; text-decoration: none;
        border: 1px solid #e2e8f0; color: #475569; transition: all .18s;
    }
    .bex-link:hover { background: #f8fafc; border-color: #cbd5e1; color: #334155; }
    .bex-link-primary { background: linear-gradient(135deg, #ec4899, #f472b6); color: #fff; border-color: #ec4899; }
    .bex-link-primary:hover { background: linear-gradient(135deg, #db2777, #ec4899); color: #fff; }
    .bex-link svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    @media (max-width: 768px) {
        .bex-stats { grid-template-columns: repeat(2, 1fr); }
        .bex-item { flex-wrap: wrap; gap: 10px; }
        .bex-item-pts { order: 3; }
    }
</style>

<div class="bex-page">
    <!-- 统计 -->
    <div class="bex-stats">
        <div class="bex-stat-card">
            <div class="bex-stat-label">可用积分</div>
            <div class="bex-stat-value"><%= myAvailablePoints %></div>
        </div>
        <div class="bex-stat-card">
            <div class="bex-stat-label">待审核</div>
            <div class="bex-stat-value"><%= pendingCount %></div>
        </div>
        <div class="bex-stat-card">
            <div class="bex-stat-label">已通过</div>
            <div class="bex-stat-value"><%= approvedCount %></div>
        </div>
        <div class="bex-stat-card">
            <div class="bex-stat-label">已拒绝</div>
            <div class="bex-stat-value"><%= rejectedCount %></div>
        </div>
    </div>

    <!-- 记录 -->
    <div class="bex-card">
        <div class="bex-card-head">
            <svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
            <h3>兑换记录</h3>
        </div>
        <% if (dtExchanges != null && dtExchanges.Rows.Count > 0) { %>
        <div class="bex-list">
            <% foreach (System.Data.DataRow row in dtExchanges.Rows) {
                int eid = Convert.ToInt32(row["Eid"]);
                string itemName = row["ItemName"] == DBNull.Value ? "未知商品" : row["ItemName"].ToString();
                string itemIcon = row["ItemIcon"] == DBNull.Value ? "" : row["ItemIcon"].ToString();
                // 解析 ASP.NET 虚路径 ~/，浏览器无法直接识别 ~/
                string resolvedIcon = string.IsNullOrEmpty(itemIcon) ? ""
                    : (itemIcon.StartsWith("~/") ? ResolveUrl(itemIcon) : itemIcon);
                int epoints = row["Epoints"] == DBNull.Value ? 0 : Convert.ToInt32(row["Epoints"]);
                int estatus = row["Estatus"] == DBNull.Value ? 0 : Convert.ToInt32(row["Estatus"]);
                string enote = row["Enote"] == DBNull.Value ? "" : row["Enote"].ToString();
                string edate = row["Edate"] == DBNull.Value ? "" : Convert.ToDateTime(row["Edate"]).ToString("yyyy-MM-dd HH:mm");
                string rdate = row["Ereviewdate"] == DBNull.Value ? "" : Convert.ToDateTime(row["Ereviewdate"]).ToString("MM-dd HH:mm");
            %>
            <div class="bex-item">
                <div class="bex-item-icon <%= string.IsNullOrEmpty(resolvedIcon) ? "bex-item-icon-default" : "" %>">
                    <% if (!string.IsNullOrEmpty(resolvedIcon)) { %>
                    <img src="<%= Server.HtmlEncode(resolvedIcon) %>" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'" />
                    <span style="display:none;align-items:center;justify-content:center;width:100%;height:100%">
                    <svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
                    </span>
                    <% } else { %>
                    <svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
                    <% } %>
                </div>
                <div class="bex-item-meta">
                    <div class="bex-item-name"><%= Server.HtmlEncode(itemName) %></div>
                    <div class="bex-item-date"><%= edate %><% if (!string.IsNullOrEmpty(rdate) && estatus > 0) { %> · 审核于 <%= rdate %><% } %></div>
                    <% if (!string.IsNullOrEmpty(enote)) { %><div class="bex-item-note">备注：<%= Server.HtmlEncode(enote) %></div><% } %>
                </div>
                <div class="bex-item-pts">-<%= epoints %> <span>积分</span></div>
                <span class="bex-status <%= GetStatusClass(estatus) %>"><%= GetStatusIcon(estatus) %><%= GetStatusText(estatus) %></span>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="bex-empty">
            <svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
            <p>暂无兑换记录</p>
        </div>
        <% } %>
        <div class="bex-actions">
            <a href="../profile/badgeshop.aspx" class="bex-link bex-link-primary"><svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>去商城兑换</a>
            <a href="../profile/mybadge.aspx" class="bex-link"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>我的徽章</a>
        </div>
    </div>
</div>
</asp:Content>
