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
        if (!IsPostBack) LoadExchanges();
    }

    private void LoadExchanges()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int status = -1; int.TryParse(DDLStatus.SelectedValue, out status);
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT e.Eid, e.Edate, e.Epoints, e.Estatus, e.Enote, e.Egrade, e.Eclass, e.Ereviewdate,
                    i.Sname AS ItemName, i.Scost,
                    s.Sname, s.Snum
                    FROM BadgeExchange e
                    LEFT JOIN BadgeShopItem i ON e.Eitemid=i.Sid
                    LEFT JOIN Students s ON e.Esid=s.Sid
                    WHERE 1=1" + (status >= 0 ? " AND e.Estatus=@status" : "") +
                    " ORDER BY e.Eid DESC";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                if (status >= 0) da.SelectCommand.Parameters.AddWithValue("@status", status);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                RptExchanges.DataSource = dt;
                RptExchanges.DataBind();
                LblCount.Text = dt.Rows.Count.ToString();
            }
        }
        catch { }
    }

    protected void BtnFilter_Click(object sender, EventArgs e)
    {
        LoadExchanges();
    }

    protected void RptExchanges_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int eid = 0; int.TryParse(e.CommandArgument.ToString(), out eid);
        if (eid <= 0) return;

        int newStatus = 0;
        if (e.CommandName == "Approve") newStatus = 1;
        else if (e.CommandName == "Reject") newStatus = 2;
        else return;

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // Check current status
                int curStatus = -1;
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Estatus,0) FROM BadgeExchange WHERE Eid=@eid", conn))
                {
                    chk.Parameters.AddWithValue("@eid", eid);
                    object r = chk.ExecuteScalar();
                    if (r != null) curStatus = Convert.ToInt32(r);
                }
                if (curStatus != 0) { pageMsg = "该申请已处理"; LoadExchanges(); return; }

                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "UPDATE BadgeExchange SET Estatus=@status, Ereviewdate=GETDATE(), Ereviewhid=@hid WHERE Eid=@eid", conn))
                {
                    cmd.Parameters.AddWithValue("@status", newStatus);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.Parameters.AddWithValue("@eid", eid);
                    cmd.ExecuteNonQuery();
                }

                // If approved, decrement stock
                if (newStatus == 1)
                {
                    using (System.Data.SqlClient.SqlCommand cmd2 = new System.Data.SqlClient.SqlCommand(
                        @"UPDATE BadgeShopItem SET Sstock=Sstock-1
                          WHERE Sid=(SELECT Eitemid FROM BadgeExchange WHERE Eid=@eid)
                          AND Sstock>0", conn))
                    {
                        cmd2.Parameters.AddWithValue("@eid", eid);
                        cmd2.ExecuteNonQuery();
                    }
                }

                pageMsg = newStatus == 1 ? "已通过" : "已拒绝";
            }
        }
        catch (Exception ex) { pageMsg = "操作失败: " + ex.Message; }
        LoadExchanges();
    }

    protected string GetStatusText(object statusObj)
    {
        int status = statusObj == DBNull.Value ? 0 : Convert.ToInt32(statusObj);
        if (status == 0) return "待审核";
        if (status == 1) return "已通过";
        if (status == 2) return "已拒绝";
        return "未知";
    }

    protected string GetStatusClass(object statusObj)
    {
        int status = statusObj == DBNull.Value ? 0 : Convert.ToInt32(statusObj);
        if (status == 0) return "be-status-pending";
        if (status == 1) return "be-status-approved";
        if (status == 2) return "be-status-rejected";
        return "";
    }

    protected bool IsPending(object statusObj)
    {
        int status = statusObj == DBNull.Value ? 0 : Convert.ToInt32(statusObj);
        return status == 0;
    }

    protected string FormatClass(object gradeObj, object classObj)
    {
        int g = gradeObj == DBNull.Value ? 0 : Convert.ToInt32(gradeObj);
        int c = classObj == DBNull.Value ? 0 : Convert.ToInt32(classObj);
        return g > 0 ? g + "年" + c + "班" : "";
    }

    protected string FormatDate(object dateObj, string fmt)
    {
        if (dateObj == DBNull.Value || dateObj == null) return "";
        return Convert.ToDateTime(dateObj).ToString(fmt);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .be-page { max-width: 1600px; width: 100%; margin: 0 auto; }
    .be-header { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .be-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .be-title .be-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#3b82f6,#60a5fa); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .be-title .be-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .be-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .be-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden; }
    .be-toolbar { display: flex; align-items: center; gap: 12px; padding: 16px 24px; background: #fafbfc; border-bottom: 1px solid #f1f5f9; }
    .be-toolbar label { font-size: 13px; color: #64748b; font-weight: 500; }
    .be-toolbar select { padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; }
    .be-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; font-family: inherit; }
    .be-btn:hover { background: #f8fafc; }
    .be-btn-primary { background: linear-gradient(135deg,#3b82f6,#60a5fa); color: #fff; border-color: #3b82f6; }
    .be-btn-primary:hover { background: linear-gradient(135deg,#2563eb,#3b82f6); }
    .be-btn-sm { padding: 4px 12px; font-size: 12px; border-radius: 6px; }
    .be-btn-success { background: #dcfce7; color: #16a34a; border-color: #86efac; }
    .be-btn-success:hover { background: #bbf7d0; }
    .be-btn-danger { color: #ef4444; border-color: #fecaca; }
    .be-btn-danger:hover { background: #fef2f2; }
    .be-table { width: 100%; border-collapse: collapse; }
    .be-table th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 12px; padding: 12px 16px; border-bottom: 2px solid #e8ecf1; text-align: left; }
    .be-table td { padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155; }
    .be-table tr:hover td { background: #eff6ff; }
    .be-table tr:last-child td { border-bottom: none; }
    .be-status { display: inline-flex; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
    .be-status-pending { background: #fef3c7; color: #92400e; }
    .be-status-approved { background: #dcfce7; color: #16a34a; }
    .be-status-rejected { background: #fee2e2; color: #dc2626; }
    .be-msg { padding: 10px 16px; border-radius: 8px; background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; font-size: 13px; margin-bottom: 16px; }
    .be-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
    .be-actions { display: flex; gap: 6px; }
    .be-count { font-size: 13px; color: #64748b; margin-left: auto; }
    .be-count strong { color: #3b82f6; }
</style>

<div class="be-page">
    <div class="be-header">
        <div class="be-title">
            <span class="be-icon"><svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg></span>
            徽章兑换审核
        </div>
        <div class="be-subtitle">审核学生提交的积分兑换申请，通过或拒绝</div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="be-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <div class="be-card">
        <div class="be-toolbar">
            <label>状态筛选：</label>
            <asp:DropDownList ID="DDLStatus" runat="server">
                <asp:ListItem Value="-1" Text="全部" Selected="True" />
                <asp:ListItem Value="0" Text="待审核" />
                <asp:ListItem Value="1" Text="已通过" />
                <asp:ListItem Value="2" Text="已拒绝" />
            </asp:DropDownList>
            <asp:Button ID="BtnFilter" runat="server" Text="筛选" OnClick="BtnFilter_Click" CssClass="be-btn be-btn-primary" />
            <span class="be-count">共 <strong><asp:Label ID="LblCount" runat="server" Text="0" /></strong> 条记录</span>
        </div>
        <div>
            <asp:Repeater ID="RptExchanges" runat="server" OnItemCommand="RptExchanges_ItemCommand">
                <HeaderTemplate>
                    <table class="be-table">
                    <thead><tr><th>ID</th><th>学生</th><th>学号</th><th>商品</th><th>消耗积分</th><th>班级</th><th>申请时间</th><th>状态</th><th>审核时间</th><th>操作</th></tr></thead>
                    <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("Eid") %></td>
                        <td><strong><%# Server.HtmlEncode(Eval("Sname") == DBNull.Value ? "" : Eval("Sname").ToString()) %></strong></td>
                        <td><%# Server.HtmlEncode(Eval("Snum") == DBNull.Value ? "" : Eval("Snum").ToString()) %></td>
                        <td><%# Server.HtmlEncode(Eval("ItemName") == DBNull.Value ? "" : Eval("ItemName").ToString()) %></td>
                        <td style="font-weight:700;color:#3b82f6;"><%# Eval("Epoints") == DBNull.Value ? 0 : Eval("Epoints") %></td>
                        <td><%# FormatClass(Eval("Egrade"), Eval("Eclass")) %></td>
                        <td><%# FormatDate(Eval("Edate"), "MM-dd HH:mm") %></td>
                        <td><span class='be-status <%# GetStatusClass(Eval("Estatus")) %>'><%# GetStatusText(Eval("Estatus")) %></span></td>
                        <td><%# FormatDate(Eval("Ereviewdate"), "MM-dd HH:mm") %></td>
                        <td>
                            <asp:Panel runat="server" Visible='<%# IsPending(Eval("Estatus")) %>'>
                                <div class="be-actions">
                                    <asp:Button runat="server" Text="通过" CssClass="be-btn be-btn-sm be-btn-success"
                                        CommandName="Approve" CommandArgument='<%# Eval("Eid") %>'
                                        OnClientClick="return confirm('确定通过该兑换申请？');" />
                                    <asp:Button runat="server" Text="拒绝" CssClass="be-btn be-btn-sm be-btn-danger"
                                        CommandName="Reject" CommandArgument='<%# Eval("Eid") %>'
                                        OnClientClick="return confirm('确定拒绝该兑换申请？');" />
                                </div>
                            </asp:Panel>
                            <asp:Panel runat="server" Visible='<%# !IsPending(Eval("Estatus")) %>'>
                                <span style="color:#94a3b8;font-size:12px;">已处理</span>
                            </asp:Panel>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody></table>
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="PnlEmpty" runat="server" Visible="false">
                <div class="be-empty">暂无兑换申请</div>
            </asp:Panel>
        </div>
    </div>
</div>

<script type="text/javascript">
    (function(){
        var tbl = document.querySelector('.be-table');
        if (!tbl || tbl.querySelectorAll('tbody tr').length === 0) {
            var empty = document.querySelector('.be-empty');
            if (empty) empty.parentElement.style.display = 'block';
            if (tbl) tbl.style.display = 'none';
        }
    })();
</script>
</asp:Content>
