<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
    protected System.Data.DataTable dtBadges = null;
    protected System.Collections.Generic.Dictionary<int, bool> myOwnedBadgeIds = new System.Collections.Generic.Dictionary<int, bool>();
    protected System.Collections.Generic.List<string> categories = new System.Collections.Generic.List<string>();
    protected int totalBadgeCount = 0;
    protected int myOwnedCount = 0;

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
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();

                // 获取所有启用的徽章
                string sql = "SELECT Bid,Bname,Bicon,Bdesc,Bcategory,ISNULL(Bpoints,0) AS Bpoints FROM Badge WHERE ISNULL(Bactive,1)=1 ORDER BY Bsort,Bid";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                dtBadges = new System.Data.DataTable();
                da.Fill(dtBadges);
                totalBadgeCount = dtBadges.Rows.Count;

                // 收集类别
                System.Collections.Generic.Dictionary<string, bool> catSet = new System.Collections.Generic.Dictionary<string, bool>();
                foreach (System.Data.DataRow row in dtBadges.Rows)
                {
                    string cat = row["Bcategory"] == DBNull.Value ? "" : row["Bcategory"].ToString();
                    if (!string.IsNullOrEmpty(cat) && !catSet.ContainsKey(cat))
                    { catSet[cat] = true; categories.Add(cat); }
                }

                // 获取学生已拥有的徽章ID
                if (mySid > 0)
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT DISTINCT Abid FROM BadgeAward WHERE Asid=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", mySid);
                        using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                int bid = r.GetInt32(0);
                                myOwnedBadgeIds[bid] = true;
                            }
                        }
                    }
                    myOwnedCount = myOwnedBadgeIds.Count;
                }
            }
        }
        catch { }
    }

    protected string RenderBadgeIcon(string icon, bool owned)
    {
        string opacity = owned ? "" : "opacity:.4;";
        if (!string.IsNullOrEmpty(icon) && (icon.Contains("/") || icon.Contains(".")))
            return "<img src=\"" + Server.HtmlEncode(icon) + "\" style=\"width:72px;height:72px;object-fit:contain;" + opacity + "\" />";
        string color = owned ? "#f59e0b" : "#cbd5e1";
        return "<svg viewBox=\"0 0 24 24\" style=\"width:48px;height:48px;" + opacity + "\"><circle cx=\"12\" cy=\"8\" r=\"6\" fill=\"none\" stroke=\"" + color + "\" stroke-width=\"2\"/><path d=\"M15.477 12.89L17 22l-5-3-5 3 1.523-9.11\" fill=\"none\" stroke=\"" + color + "\" stroke-width=\"2\"/></svg>";
    }

    protected System.Data.DataRow[] GetBadgesByCategory(string category)
    {
        if (dtBadges == null) return new System.Data.DataRow[0];
        return dtBadges.Select("Bcategory='" + category.Replace("'", "''") + "'");
    }

    protected System.Data.DataRow[] GetBadgesWithoutCategory()
    {
        if (dtBadges == null) return new System.Data.DataRow[0];
        return dtBadges.Select("Bcategory IS NULL OR Bcategory=''");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" runat="Server">
<style>
    .bst-page { animation: bstFade .4s ease; }
    @keyframes bstFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 进度概览 */
    .bst-overview {
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
        border-radius: 16px; padding: 24px 28px; margin-bottom: 20px; color: #fff;
        position: relative; overflow: hidden;
    }
    .bst-overview::before { content: ''; position: absolute; top: -40px; right: -20px; width: 120px; height: 120px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .bst-overview-top { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; position: relative; z-index: 1; }
    .bst-overview-icon { font-size: 36px; line-height: 1; }
    .bst-overview-info h2 { font-size: 20px; font-weight: 800; margin: 0 0 4px; }
    .bst-overview-info p { font-size: 13px; opacity: .9; margin: 0; }
    .bst-progress-wrap { position: relative; z-index: 1; }
    .bst-progress-labels { display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 8px; opacity: .9; }
    .bst-progress-bar { height: 8px; background: rgba(255,255,255,.2); border-radius: 8px; overflow: hidden; }
    .bst-progress-fill { height: 100%; background: rgba(255,255,255,.85); border-radius: 8px; transition: width .6s ease; }

    /* 类别区块 */
    .bst-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; }
    .bst-card-head { padding: 16px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .bst-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .bst-card-head .bst-tag { display: inline-flex; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; background: #eef2ff; color: #4f46e5; }

    .bst-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; padding: 20px 24px; }
    .bst-badge-item {
        border: 1px solid #e5e7eb; border-radius: 14px; padding: 20px 14px;
        text-align: center; transition: all .2s; position: relative;
    }
    .bst-badge-item:hover { border-color: #c7d2fe; box-shadow: 0 4px 16px rgba(99,102,241,.1); transform: translateY(-2px); }
    .bst-badge-item.bst-owned { border-color: #fde68a; background: #fffbeb; }
    .bst-badge-item.bst-locked { background: #f8fafc; }
    .bst-badge-check {
        position: absolute; top: 10px; right: 10px; width: 22px; height: 22px;
        background: #10b981; border-radius: 50%; display: flex; align-items: center; justify-content: center;
    }
    .bst-badge-check svg { width: 12px; height: 12px; fill: none; stroke: #fff; stroke-width: 3; }
    .bst-badge-icon { width: 80px; height: 80px; margin: 0 auto 10px; background: none; border-radius: 0; display: flex; align-items: center; justify-content: center; }
    .bst-badge-item.bst-owned .bst-badge-icon { background: none; }
    .bst-badge-name { font-size: 13px; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
    .bst-badge-item.bst-locked .bst-badge-name { color: #94a3b8; }
    .bst-badge-pts { font-size: 12px; font-weight: 600; color: #f59e0b; margin-bottom: 4px; }
    .bst-badge-item.bst-locked .bst-badge-pts { color: #cbd5e1; }
    .bst-badge-desc { font-size: 11px; color: #64748b; max-width: 160px; margin: 0 auto; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

    .bst-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }

    @media (max-width: 768px) {
        .bst-grid { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 12px; padding: 16px; }
    }
</style>

<div class="bst-page">
    <!-- 收集进度 -->
    <div class="bst-overview">
        <div class="bst-overview-top">
            <div class="bst-overview-icon">🏅</div>
            <div class="bst-overview-info">
                <h2>徽章图鉴</h2>
                <p>已收集 <strong><%= myOwnedCount %></strong> / <%= totalBadgeCount %> 枚徽章</p>
            </div>
        </div>
        <div class="bst-progress-wrap">
            <div class="bst-progress-labels">
                <span>收集进度</span>
                <span><%= totalBadgeCount > 0 ? ((double)myOwnedCount / totalBadgeCount * 100).ToString("F0") : "0" %>%</span>
            </div>
            <div class="bst-progress-bar">
                <div class="bst-progress-fill" style="width:<%= totalBadgeCount > 0 ? ((double)myOwnedCount / totalBadgeCount * 100).ToString("F0") : "0" %>%"></div>
            </div>
        </div>
    </div>

    <% if (dtBadges != null && dtBadges.Rows.Count > 0) { %>

    <!-- 按类别显示 -->
    <% foreach (string cat in categories) {
        System.Data.DataRow[] catRows = GetBadgesByCategory(cat);
        if (catRows.Length == 0) continue;
    %>
    <div class="bst-card">
        <div class="bst-card-head">
            <h3><%= Server.HtmlEncode(cat) %></h3>
            <span class="bst-tag"><%= catRows.Length %> 枚</span>
        </div>
        <div class="bst-grid">
            <% foreach (System.Data.DataRow row in catRows) {
                int bid = Convert.ToInt32(row["Bid"]);
                string bname = row["Bname"] == DBNull.Value ? "" : row["Bname"].ToString();
                string bicon = row["Bicon"] == DBNull.Value ? "" : row["Bicon"].ToString();
                string bdesc = row["Bdesc"] == DBNull.Value ? "" : row["Bdesc"].ToString();
                int bpts = row["Bpoints"] == DBNull.Value ? 0 : Convert.ToInt32(row["Bpoints"]);
                bool owned = myOwnedBadgeIds.ContainsKey(bid);
            %>
            <div class="bst-badge-item <%= owned ? "bst-owned" : "bst-locked" %>">
                <% if (owned) { %><div class="bst-badge-check"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div><% } %>
                <div class="bst-badge-icon"><%= RenderBadgeIcon(bicon, owned) %></div>
                <div class="bst-badge-name"><%= Server.HtmlEncode(bname) %></div>
                <div class="bst-badge-pts"><%= bpts %> 积分</div>
                <% if (!string.IsNullOrEmpty(bdesc)) { %><div class="bst-badge-desc" title="<%= Server.HtmlEncode(bdesc) %>"><%= Server.HtmlEncode(bdesc) %></div><% } %>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- 未分类 -->
    <% System.Data.DataRow[] noCatRows = GetBadgesWithoutCategory();
       if (noCatRows.Length > 0) { %>
    <div class="bst-card">
        <div class="bst-card-head">
            <h3>其他徽章</h3>
            <span class="bst-tag"><%= noCatRows.Length %> 枚</span>
        </div>
        <div class="bst-grid">
            <% foreach (System.Data.DataRow row in noCatRows) {
                int bid = Convert.ToInt32(row["Bid"]);
                string bname = row["Bname"] == DBNull.Value ? "" : row["Bname"].ToString();
                string bicon = row["Bicon"] == DBNull.Value ? "" : row["Bicon"].ToString();
                string bdesc = row["Bdesc"] == DBNull.Value ? "" : row["Bdesc"].ToString();
                int bpts = row["Bpoints"] == DBNull.Value ? 0 : Convert.ToInt32(row["Bpoints"]);
                bool owned = myOwnedBadgeIds.ContainsKey(bid);
            %>
            <div class="bst-badge-item <%= owned ? "bst-owned" : "bst-locked" %>">
                <% if (owned) { %><div class="bst-badge-check"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div><% } %>
                <div class="bst-badge-icon"><%= RenderBadgeIcon(bicon, owned) %></div>
                <div class="bst-badge-name"><%= Server.HtmlEncode(bname) %></div>
                <div class="bst-badge-pts"><%= bpts %> 积分</div>
                <% if (!string.IsNullOrEmpty(bdesc)) { %><div class="bst-badge-desc" title="<%= Server.HtmlEncode(bdesc) %>"><%= Server.HtmlEncode(bdesc) %></div><% } %>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <% } else { %>
    <div class="bst-card">
        <div class="bst-empty">暂无徽章，请等待老师添加</div>
    </div>
    <% } %>
</div>
</asp:Content>
