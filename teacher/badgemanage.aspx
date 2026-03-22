<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";

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

    private void LoadTeacher()
    {
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out myHid); }
                }
            }
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadTeacher();
        if (!IsPostBack)
        {
            LoadGrades();
            LoadBadgeFilter();
            LoadAwards();
        }
    }

    private void LoadGrades()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                DDLGrade.Items.Clear();
                DDLGrade.Items.Add(new System.Web.UI.WebControls.ListItem("全部年级", "0"));
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT DISTINCT Agrade FROM BadgeAward WHERE Agrade>0 ORDER BY Agrade", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    { while (r.Read()) DDLGrade.Items.Add(new System.Web.UI.WebControls.ListItem(r.GetInt32(0) + "年级", r.GetInt32(0).ToString())); }
                }
            }
        }
        catch { }
    }

    private void LoadClasses()
    {
        int grade = 0; int.TryParse(DDLGrade.SelectedValue, out grade);
        DDLClass.Items.Clear();
        DDLClass.Items.Add(new System.Web.UI.WebControls.ListItem("全部班级", "0"));
        if (grade <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT DISTINCT Aclass FROM BadgeAward WHERE Agrade=@g AND Aclass>0 ORDER BY Aclass", conn))
                {
                    cmd.Parameters.AddWithValue("@g", grade);
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    { while (r.Read()) DDLClass.Items.Add(new System.Web.UI.WebControls.ListItem(r.GetInt32(0) + "班", r.GetInt32(0).ToString())); }
                }
            }
        }
        catch { }
    }

    private void LoadBadgeFilter()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                DDLBadge.Items.Clear();
                DDLBadge.Items.Add(new System.Web.UI.WebControls.ListItem("全部徽章", "0"));
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Bid,Bname FROM Badge ORDER BY Bsort,Bid", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    { while (r.Read()) DDLBadge.Items.Add(new System.Web.UI.WebControls.ListItem(r["Bname"].ToString(), r["Bid"].ToString())); }
                }
            }
        }
        catch { }
    }

    private void LoadAwards()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int grade = 0; int.TryParse(DDLGrade.SelectedValue, out grade);
        int cls = 0; int.TryParse(DDLClass.SelectedValue, out cls);
        int badgeId = 0; int.TryParse(DDLBadge.SelectedValue, out badgeId);
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT a.Aid, a.Adate, a.Areason, a.Agrade, a.Aclass,
                    b.Bname, b.Bpoints, b.Bcategory, b.Bicon,
                    s.Sname, s.Snum
                    FROM BadgeAward a
                    LEFT JOIN Badge b ON a.Abid=b.Bid
                    LEFT JOIN Students s ON a.Asid=s.Sid
                    WHERE 1=1"
                    + (grade > 0 ? " AND a.Agrade=@grade" : "")
                    + (cls > 0 ? " AND a.Aclass=@class" : "")
                    + (badgeId > 0 ? " AND a.Abid=@bid" : "")
                    + " ORDER BY a.Aid DESC";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                if (grade > 0) da.SelectCommand.Parameters.AddWithValue("@grade", grade);
                if (cls > 0) da.SelectCommand.Parameters.AddWithValue("@class", cls);
                if (badgeId > 0) da.SelectCommand.Parameters.AddWithValue("@bid", badgeId);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                RptAwards.DataSource = dt;
                RptAwards.DataBind();
                LblCount.Text = dt.Rows.Count.ToString();
            }
        }
        catch { }
    }

    protected void DDLGrade_Changed(object sender, EventArgs e)
    {
        LoadClasses();
        LoadAwards();
    }

    protected void BtnFilter_Click(object sender, EventArgs e)
    {
        LoadAwards();
    }

    protected void RptAwards_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "Revoke")
        {
            int aid = 0; int.TryParse(e.CommandArgument.ToString(), out aid);
            if (aid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("DELETE FROM BadgeAward WHERE Aid=@aid", conn))
                    {
                        cmd.Parameters.AddWithValue("@aid", aid);
                        cmd.ExecuteNonQuery();
                    }
                }
                pageMsg = "已撤销";
            }
            catch (Exception ex) { pageMsg = "撤销失败: " + ex.Message; }
            LoadAwards();
        }
    }

    protected string FormatClass(object gradeObj, object classObj)
    {
        int g = gradeObj == DBNull.Value ? 0 : Convert.ToInt32(gradeObj);
        int c = classObj == DBNull.Value ? 0 : Convert.ToInt32(classObj);
        return g > 0 ? g + "年" + c + "班" : "";
    }

    protected string FormatDate(object dateObj)
    {
        if (dateObj == DBNull.Value || dateObj == null) return "";
        return Convert.ToDateTime(dateObj).ToString("yyyy-MM-dd");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .bm-page { max-width: 1600px; width: 100%; margin: 0 auto; }
    .bm-header { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .bm-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .bm-title .bm-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .bm-title .bm-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bm-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .bm-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden; }
    .bm-toolbar { display: flex; align-items: center; gap: 12px; padding: 16px 24px; background: #fafbfc; border-bottom: 1px solid #f1f5f9; flex-wrap: wrap; }
    .bm-toolbar label { font-size: 13px; color: #64748b; font-weight: 500; }
    .bm-toolbar select { padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; }
    .bm-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; font-family: inherit; }
    .bm-btn:hover { background: #f8fafc; }
    .bm-btn-primary { background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff; border-color: #6366f1; }
    .bm-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); }
    .bm-btn-sm { padding: 4px 12px; font-size: 12px; border-radius: 6px; }
    .bm-btn-danger { color: #ef4444; border-color: #fecaca; }
    .bm-btn-danger:hover { background: #fef2f2; }
    .bm-table { width: 100%; border-collapse: collapse; }
    .bm-table th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 12px; padding: 12px 16px; border-bottom: 2px solid #e8ecf1; text-align: left; }
    .bm-table td { padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155; }
    .bm-table tr:hover td { background: #f8fafc; }
    .bm-table tr:last-child td { border-bottom: none; }
    .bm-cat { display: inline-block; padding: 2px 10px; border-radius: 10px; font-size: 11px; font-weight: 500; background: #eef2ff; color: #4f46e5; }
    .bm-msg { padding: 10px 16px; border-radius: 8px; background: #eef2ff; border: 1px solid #c7d2fe; color: #3730a3; font-size: 13px; margin-bottom: 16px; }
    .bm-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
    .bm-count { font-size: 13px; color: #64748b; margin-left: auto; }
    .bm-count strong { color: #6366f1; }
</style>

<div class="bm-page">
    <div class="bm-header">
        <div class="bm-title">
            <span class="bm-icon"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg></span>
            徽章管理
        </div>
        <div class="bm-subtitle">查看所有已颁发的徽章记录，支持按年级、班级、徽章筛选，可撤销颁发</div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="bm-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <div class="bm-card">
        <div class="bm-toolbar">
            <label>年级：</label>
            <asp:DropDownList ID="DDLGrade" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DDLGrade_Changed" />
            <label>班级：</label>
            <asp:DropDownList ID="DDLClass" runat="server" />
            <label>徽章：</label>
            <asp:DropDownList ID="DDLBadge" runat="server" />
            <asp:Button ID="BtnFilter" runat="server" Text="筛选" OnClick="BtnFilter_Click" CssClass="bm-btn bm-btn-primary" />
            <span class="bm-count">共 <strong><asp:Label ID="LblCount" runat="server" Text="0" /></strong> 条记录</span>
        </div>
        <div>
            <asp:Repeater ID="RptAwards" runat="server" OnItemCommand="RptAwards_ItemCommand">
                <HeaderTemplate>
                    <table class="bm-table">
                    <thead><tr><th>ID</th><th>学生</th><th>学号</th><th>徽章</th><th>类别</th><th>积分</th><th>原因</th><th>班级</th><th>时间</th><th>操作</th></tr></thead>
                    <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("Aid") %></td>
                        <td><strong><%# Server.HtmlEncode(Eval("Sname") == DBNull.Value ? "" : Eval("Sname").ToString()) %></strong></td>
                        <td><%# Server.HtmlEncode(Eval("Snum") == DBNull.Value ? "" : Eval("Snum").ToString()) %></td>
                        <td><%# Server.HtmlEncode(Eval("Bname") == DBNull.Value ? "" : Eval("Bname").ToString()) %></td>
                        <td><%# Eval("Bcategory") != DBNull.Value && Eval("Bcategory").ToString().Length > 0 ? "<span class=\"bm-cat\">" + Server.HtmlEncode(Eval("Bcategory").ToString()) + "</span>" : "" %></td>
                        <td style="font-weight:700;color:#f59e0b;"><%# Eval("Bpoints") == DBNull.Value ? 0 : Eval("Bpoints") %></td>
                        <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%# Server.HtmlEncode(Eval("Areason") == DBNull.Value ? "" : Eval("Areason").ToString()) %></td>
                        <td><%# FormatClass(Eval("Agrade"), Eval("Aclass")) %></td>
                        <td><%# FormatDate(Eval("Adate")) %></td>
                        <td>
                            <asp:Button runat="server" Text="撤销" CssClass="bm-btn bm-btn-sm bm-btn-danger"
                                CommandName="Revoke" CommandArgument='<%# Eval("Aid") %>'
                                OnClientClick="return confirm('确定要撤销该颁发记录吗？');" />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody></table>
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="PnlEmpty" runat="server" Visible="false">
                <div class="bm-empty">暂无颁发记录</div>
            </asp:Panel>
        </div>
    </div>
</div>

<script type="text/javascript">
    // Show empty panel if no rows
    (function(){
        var tbl = document.querySelector('.bm-table');
        if (tbl && tbl.querySelectorAll('tbody tr').length === 0) {
            var empty = document.querySelector('.bm-empty');
            if (empty) empty.parentElement.style.display = 'block';
        }
    })();
</script>
</asp:Content>
