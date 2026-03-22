<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
    protected int myGrade = 0;
    protected int myClass = 0;
    protected int myTotalCredits = 0;  // 总学分（个人+小组）
    protected int myPersonalCredits = 0;  // 个人学分
    protected int myGroupCredits = 0;  // 小组学分
    protected int myUsedCredits = 0;  // 已使用学分
    protected int myAvailableCredits = 0;  // 可用学分
    protected int myBadgeCount = 0;
    protected System.Data.DataTable dtMyBadges = null;

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
                    string gradeStr = GetProp(m, "Sgrade");
                    if (!string.IsNullOrEmpty(gradeStr)) int.TryParse(gradeStr, out myGrade);
                    string classStr = GetProp(m, "Sclass");
                    if (!string.IsNullOrEmpty(classStr)) int.TryParse(classStr, out myClass);
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

                // 获取学生的个人学分和小组学分
                using (System.Data.SqlClient.SqlCommand cmdCredits = new System.Data.SqlClient.SqlCommand(
                    @"SELECT ISNULL(Sallscore, 0) AS PersonalCredits, 
                             ISNULL(Sgscore, 0) AS GroupCredits
                      FROM Students 
                      WHERE Sid=@sid", conn))
                {
                    cmdCredits.Parameters.AddWithValue("@sid", mySid);
                    using (System.Data.SqlClient.SqlDataReader reader = cmdCredits.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            myPersonalCredits = reader["PersonalCredits"] == DBNull.Value ? 0 : Convert.ToInt32(reader["PersonalCredits"]);
                            myGroupCredits = reader["GroupCredits"] == DBNull.Value ? 0 : Convert.ToInt32(reader["GroupCredits"]);
                            myTotalCredits = myPersonalCredits + myGroupCredits;
                        }
                    }
                }

                // 获取我的徽章列表
                string sql = @"SELECT a.Aid, a.Adate, a.Areason,
                    b.Bid, b.Bname, b.Bicon, b.Bdesc, b.Bcategory, ISNULL(b.Bpoints,0) AS Bpoints
                    FROM BadgeAward a
                    LEFT JOIN Badge b ON a.Abid=b.Bid
                    WHERE a.Asid=@sid
                    ORDER BY a.Adate DESC, a.Aid DESC";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@sid", mySid);
                dtMyBadges = new System.Data.DataTable();
                da.Fill(dtMyBadges);

                myBadgeCount = dtMyBadges.Rows.Count;

                // 计算已使用学分（已通过的兑换）
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(SUM(ISNULL(Epoints,0)),0) FROM BadgeExchange WHERE Esid=@sid AND Estatus IN (0,1)", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) myUsedCredits = Convert.ToInt32(r);
                }

                myAvailableCredits = myTotalCredits - myUsedCredits;
                if (myAvailableCredits < 0) myAvailableCredits = 0;
            }
        }
        catch (Exception ex)
        {
            // 调试信息
            System.Diagnostics.Debug.WriteLine("LoadData Error: " + ex.Message);
        }
    }

    protected string RenderBadgeIcon(string icon)
    {
        if (!string.IsNullOrEmpty(icon) && (icon.Contains("/") || icon.Contains(".")))
            return "<img src=\"" + Server.HtmlEncode(icon) + "\" style=\"width:48px;height:48px;object-fit:contain;\" />";
        return "<svg viewBox=\"0 0 24 24\" style=\"width:32px;height:32px;\"><circle cx=\"12\" cy=\"8\" r=\"6\" fill=\"none\" stroke=\"#f59e0b\" stroke-width=\"2\"/><path d=\"M15.477 12.89L17 22l-5-3-5 3 1.523-9.11\" fill=\"none\" stroke=\"#f59e0b\" stroke-width=\"2\"/></svg>";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" runat="Server">
<style>
    .mb-page { animation: mbFade .4s ease; }
    @keyframes mbFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 统计卡片 */
    .mb-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 20px; }
    .mb-stat-card {
        background: #fff; border-radius: 14px; border: 1px solid #e5e7eb; padding: 20px 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); position: relative; overflow: hidden;
    }
    .mb-stat-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; }
    .mb-stat-card:nth-child(1)::before { background: linear-gradient(90deg, #f59e0b, #fbbf24); }
    .mb-stat-card:nth-child(2)::before { background: linear-gradient(90deg, #6366f1, #818cf8); }
    .mb-stat-card:nth-child(3)::before { background: linear-gradient(90deg, #10b981, #34d399); }
    .mb-stat-label { font-size: 12px; color: #94a3b8; font-weight: 500; margin-bottom: 6px; }
    .mb-stat-value { font-size: 28px; font-weight: 800; line-height: 1; }
    .mb-stat-card:nth-child(1) .mb-stat-value { color: #d97706; }
    .mb-stat-card:nth-child(2) .mb-stat-value { color: #6366f1; }
    .mb-stat-card:nth-child(3) .mb-stat-value { color: #10b981; }
    .mb-stat-unit { font-size: 13px; font-weight: 500; margin-left: 4px; }

    /* 徽章列表 */
    .mb-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; }
    .mb-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .mb-card-head svg { width: 18px; height: 18px; fill: none; stroke: #f59e0b; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mb-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .mb-card-head .mb-count { font-size: 12px; color: #94a3b8; margin-left: auto; }

    .mb-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px; padding: 20px 24px; }
    .mb-badge-item {
        border: 1px solid #e5e7eb; border-radius: 14px; padding: 20px 16px;
        text-align: center; transition: all .2s; background: #fff;
    }
    .mb-badge-item:hover { border-color: #fde68a; box-shadow: 0 4px 16px rgba(245,158,11,.12); transform: translateY(-2px); }
    .mb-badge-icon { width: 64px; height: 64px; margin: 0 auto 12px; background: #fef3c7; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
    .mb-badge-icon img { width: 48px; height: 48px; object-fit: contain; }
    .mb-badge-name { font-size: 14px; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
    .mb-badge-cat { display: inline-block; padding: 2px 10px; border-radius: 10px; font-size: 11px; font-weight: 500; background: #eef2ff; color: #4f46e5; margin-bottom: 6px; }
    .mb-badge-pts { font-size: 13px; font-weight: 700; color: #f59e0b; margin-bottom: 4px; }
    .mb-badge-date { font-size: 11px; color: #94a3b8; }
    .mb-badge-reason { font-size: 11px; color: #64748b; margin-top: 4px; max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-left: auto; margin-right: auto; }

    .mb-empty { padding: 60px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
    .mb-empty svg { width: 48px; height: 48px; stroke: #d1d5db; fill: none; stroke-width: 1.5; margin-bottom: 12px; }
    .mb-empty p { margin: 0; }

    .mb-actions { display: flex; gap: 10px; padding: 0 24px 20px; }
    .mb-link {
        display: inline-flex; align-items: center; gap: 6px; padding: 8px 20px;
        border-radius: 8px; font-size: 13px; font-weight: 500; text-decoration: none;
        border: 1px solid #e2e8f0; color: #475569; transition: all .18s;
    }
    .mb-link:hover { background: #f8fafc; border-color: #cbd5e1; color: #334155; }
    .mb-link svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    @media (max-width: 768px) {
        .mb-stats { grid-template-columns: 1fr; }
        .mb-grid { grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 12px; padding: 16px; }
    }
</style>

<div class="mb-page">
    <!-- 统计 -->
    <div class="mb-stats">
        <div class="mb-stat-card">
            <div class="mb-stat-label">总学分</div>
            <div class="mb-stat-value"><%= myTotalCredits %><span class="mb-stat-unit">分</span></div>
        </div>
        <div class="mb-stat-card">
            <div class="mb-stat-label">可用学分</div>
            <div class="mb-stat-value"><%= myAvailableCredits %><span class="mb-stat-unit">分</span></div>
        </div>
        <div class="mb-stat-card">
            <div class="mb-stat-label">已获徽章</div>
            <div class="mb-stat-value"><%= myBadgeCount %><span class="mb-stat-unit">枚</span></div>
        </div>
    </div>

    <!-- 徽章列表 -->
    <div class="mb-card">
        <div class="mb-card-head">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>
            <h3>我的徽章</h3>
            <span class="mb-count">共 <%= myBadgeCount %> 枚</span>
        </div>
        <% if (dtMyBadges != null && dtMyBadges.Rows.Count > 0) { %>
        <div class="mb-grid">
            <% foreach (System.Data.DataRow row in dtMyBadges.Rows) {
                string bname = row["Bname"] == DBNull.Value ? "" : row["Bname"].ToString();
                string bicon = row["Bicon"] == DBNull.Value ? "" : row["Bicon"].ToString();
                string bcat = row["Bcategory"] == DBNull.Value ? "" : row["Bcategory"].ToString();
                int bpts = row["Bpoints"] == DBNull.Value ? 0 : Convert.ToInt32(row["Bpoints"]);
                string reason = row["Areason"] == DBNull.Value ? "" : row["Areason"].ToString();
                string adate = row["Adate"] == DBNull.Value ? "" : Convert.ToDateTime(row["Adate"]).ToString("yyyy-MM-dd");
            %>
            <div class="mb-badge-item">
                <div class="mb-badge-icon"><%= RenderBadgeIcon(bicon) %></div>
                <div class="mb-badge-name"><%= Server.HtmlEncode(bname) %></div>
                <% if (!string.IsNullOrEmpty(bcat)) { %><span class="mb-badge-cat"><%= Server.HtmlEncode(bcat) %></span><% } %>
                <div class="mb-badge-pts">+<%= bpts %> 学分</div>
                <div class="mb-badge-date"><%= adate %></div>
                <% if (!string.IsNullOrEmpty(reason)) { %><div class="mb-badge-reason" title="<%= Server.HtmlEncode(reason) %>"><%= Server.HtmlEncode(reason) %></div><% } %>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="mb-empty">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>
            <p>暂无徽章，继续努力学习吧！</p>
        </div>
        <% } %>
        <div class="mb-actions">
            <a href="../profile/badgestore.aspx" class="mb-link"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>徽章图鉴</a>
            <a href="../profile/badgeshop.aspx" class="mb-link"><svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>学分商城</a>
            <a href="../profile/badgeexchange.aspx" class="mb-link"><svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>兑换记录</a>
        </div>
    </div>
</div>
</asp:Content>
