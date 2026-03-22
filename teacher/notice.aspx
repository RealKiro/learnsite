<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;
    protected string myHname = "";
    protected string pageMsg = "";
    protected string pageMsgType = "info";
    protected int editNid = 0;

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
                    System.Reflection.PropertyInfo pn = ct.GetProperty("Hname");
                    if (pn != null) { object vn = pn.GetValue(m, null); if (vn != null) myHname = vn.ToString(); }
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
            EnsureTables();
            LoadGrades();
            if (DDLgrade.Items.Count > 0)
                LoadClasses();
            BindNotices();
        }
    }

    // ========== 自动建表 ==========
    private void EnsureTables()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='Notice' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[Notice](
                            [Nid] [int] IDENTITY(1,1) NOT NULL,
                            [Ntitle] [nvarchar](200) NULL,
                            [Ncontent] [ntext] NULL,
                            [Nhid] [int] NULL,
                            [Nhname] [nvarchar](50) NULL,
                            [Ngrade] [int] NULL,
                            [Nclass] [int] NULL,
                            [Nstatus] [int] NULL DEFAULT(1),
                            [Ndate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([Nid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
            }
        }
        catch { }
    }

    // ========== 加载年级 ==========
    private void LoadGrades()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade>0 ORDER BY Sgrade";
                if (myHid > 0)
                    sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade IN (SELECT DISTINCT Rgrade FROM Room WHERE Rhid=" + myHid + ") ORDER BY Sgrade";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLgrade.Items.Clear();
                    DDLgrade.Items.Add(new System.Web.UI.WebControls.ListItem("全部年级", "0"));
                    while (dr.Read())
                    {
                        DDLgrade.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Sgrade"].ToString() + "年级", dr["Sgrade"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    // ========== 加载班级 ==========
    private void LoadClasses()
    {
        DDLclass.Items.Clear();
        DDLclass.Items.Add(new System.Web.UI.WebControls.ListItem("全部班级", "0"));
        int grade = 0;
        int.TryParse(DDLgrade.SelectedValue, out grade);
        if (grade <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade + " ORDER BY Sclass";
                if (myHid > 0)
                    sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade +
                          " AND Sclass IN (SELECT DISTINCT Rclass FROM Room WHERE Rhid=" + myHid + " AND Rgrade=" + grade + ") ORDER BY Sclass";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        DDLclass.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Sclass"].ToString() + "班", dr["Sclass"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    protected void DDLgrade_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadClasses();
        BindNotices();
    }

    // ========== 发布通知 ==========
    protected void BtnPublish_Click(object sender, EventArgs e)
    {
        string title = TxtTitle.Text.Trim();
        string content = TxtContent.Text.Trim();
        if (string.IsNullOrEmpty(title))
        { pageMsg = "请输入通知标题"; pageMsgType = "error"; BindNotices(); return; }
        if (string.IsNullOrEmpty(content))
        { pageMsg = "请输入通知内容"; pageMsgType = "error"; BindNotices(); return; }

        int grade = 0; int.TryParse(DDLgrade.SelectedValue, out grade);
        int cls = 0; int.TryParse(DDLclass.SelectedValue, out cls);

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int nid = 0;
                int.TryParse(HiddenNid.Value, out nid);

                if (nid > 0)
                {
                    // 编辑模式
                    string sql = "UPDATE Notice SET Ntitle=@title, Ncontent=@content, Ngrade=@grade, Nclass=@cls WHERE Nid=@nid AND Nhid=@hid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@content", content);
                        cmd.Parameters.AddWithValue("@grade", grade);
                        cmd.Parameters.AddWithValue("@cls", cls);
                        cmd.Parameters.AddWithValue("@nid", nid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.ExecuteNonQuery();
                    }
                    pageMsg = "通知已更新"; pageMsgType = "success";
                }
                else
                {
                    // 新建模式
                    string sql = "INSERT INTO Notice(Ntitle,Ncontent,Nhid,Nhname,Ngrade,Nclass,Nstatus,Ndate) VALUES(@title,@content,@hid,@hname,@grade,@cls,1,GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@content", content);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.Parameters.AddWithValue("@hname", myHname);
                        cmd.Parameters.AddWithValue("@grade", grade);
                        cmd.Parameters.AddWithValue("@cls", cls);
                        cmd.ExecuteNonQuery();
                    }
                    pageMsg = "通知发布成功"; pageMsgType = "success";
                }
            }
        }
        catch (Exception ex)
        { pageMsg = "操作失败：" + ex.Message; pageMsgType = "error"; }

        // 重置表单
        TxtTitle.Text = "";
        TxtContent.Text = "";
        HiddenNid.Value = "0";
        BindNotices();
    }

    // ========== 绑定通知列表 ==========
    private void BindNotices()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string where = "WHERE Nhid=@hid";
                string sql = "SELECT Nid, Ntitle, Ncontent, Ngrade, Nclass, Nstatus, Ndate FROM Notice " + where + " ORDER BY Ndate DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    RptNotices.DataSource = dt;
                    RptNotices.DataBind();
                    LblCount.Text = dt.Rows.Count.ToString();
                }
            }
        }
        catch { }
    }

    // ========== 通知操作（编辑/删除/切换状态）==========
    protected void RptNotices_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int nid = 0; int.TryParse(e.CommandArgument.ToString(), out nid);
        if (nid <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;

        if (e.CommandName == "EditNotice")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = "SELECT Nid, Ntitle, Ncontent, Ngrade, Nclass FROM Notice WHERE Nid=@nid AND Nhid=@hid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@nid", nid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        SqlDataReader dr = cmd.ExecuteReader();
                        if (dr.Read())
                        {
                            TxtTitle.Text = dr["Ntitle"].ToString();
                            TxtContent.Text = dr["Ncontent"].ToString();
                            HiddenNid.Value = nid.ToString();
                            int g = 0; int.TryParse(dr["Ngrade"].ToString(), out g);
                            int c = 0; int.TryParse(dr["Nclass"].ToString(), out c);
                            if (g > 0)
                            {
                                try { DDLgrade.SelectedValue = g.ToString(); } catch { }
                                LoadClasses();
                                if (c > 0) { try { DDLclass.SelectedValue = c.ToString(); } catch { } }
                            }
                            else
                            {
                                DDLgrade.SelectedIndex = 0;
                                LoadClasses();
                            }
                            editNid = nid;
                        }
                        dr.Close();
                    }
                }
            }
            catch { }
        }
        else if (e.CommandName == "DeleteNotice")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = "DELETE FROM Notice WHERE Nid=@nid AND Nhid=@hid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@nid", nid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.ExecuteNonQuery();
                    }
                }
                pageMsg = "通知已删除"; pageMsgType = "success";
            }
            catch { pageMsg = "删除失败"; pageMsgType = "error"; }
        }
        else if (e.CommandName == "ToggleStatus")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = "UPDATE Notice SET Nstatus = CASE WHEN Nstatus=1 THEN 0 ELSE 1 END WHERE Nid=@nid AND Nhid=@hid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@nid", nid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.ExecuteNonQuery();
                    }
                }
                pageMsg = "状态已更新"; pageMsgType = "success";
            }
            catch { pageMsg = "操作失败"; pageMsgType = "error"; }
        }

        BindNotices();
    }

    // ========== 取消编辑 ==========
    protected void BtnCancel_Click(object sender, EventArgs e)
    {
        TxtTitle.Text = "";
        TxtContent.Text = "";
        HiddenNid.Value = "0";
        editNid = 0;
        BindNotices();
    }

    protected string GetTargetText(object gradeObj, object classObj)
    {
        int grade = 0; int cls = 0;
        if (gradeObj != null && gradeObj != DBNull.Value) int.TryParse(gradeObj.ToString(), out grade);
        if (classObj != null && classObj != DBNull.Value) int.TryParse(classObj.ToString(), out cls);
        if (grade <= 0) return "全部";
        if (cls <= 0) return grade + "年级（全部班级）";
        return grade + "年级" + cls + "班";
    }

    protected string GetStatusText(object statusObj)
    {
        int status = 0;
        if (statusObj != null && statusObj != DBNull.Value) int.TryParse(statusObj.ToString(), out status);
        return status == 1 ? "已发布" : "已停用";
    }

    protected string GetStatusClass(object statusObj)
    {
        int status = 0;
        if (statusObj != null && statusObj != DBNull.Value) int.TryParse(statusObj.ToString(), out status);
        return status == 1 ? "nt-status-active" : "nt-status-inactive";
    }

    protected string GetToggleText(object statusObj)
    {
        int status = 0;
        if (statusObj != null && statusObj != DBNull.Value) int.TryParse(statusObj.ToString(), out status);
        return status == 1 ? "停用" : "启用";
    }

    protected string FormatDate(object dateObj)
    {
        if (dateObj == null || dateObj == DBNull.Value) return "";
        try
        {
            DateTime dt = Convert.ToDateTime(dateObj);
            return dt.ToString("yyyy-MM-dd HH:mm");
        }
        catch { return ""; }
    }

    protected string TruncateContent(object contentObj, int maxLen)
    {
        if (contentObj == null || contentObj == DBNull.Value) return "";
        string s = contentObj.ToString();
        if (s.Length > maxLen) return s.Substring(0, maxLen) + "...";
        return s;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<style>
    .nt-page { max-width: 1600px; margin: 0 auto; }
    .nt-header { margin-bottom: 24px; }
    .nt-header h2 { font-size: 22px; font-weight: 700; color: #1e293b; margin: 0 0 4px; }
    .nt-header p { font-size: 13px; color: #94a3b8; margin: 0; }

    /* 消息提示 */
    .nt-msg { padding: 12px 16px; border-radius: 10px; font-size: 13px; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
    .nt-msg-success { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }
    .nt-msg-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
    .nt-msg-info { background: #eff6ff; color: #1e40af; border: 1px solid #bfdbfe; }

    /* 表单卡片 */
    .nt-form-card {
        background: #fff; border-radius: 14px; padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.06); border: 1px solid #e8ecf1;
        margin-bottom: 24px;
    }
    .nt-form-title { font-size: 16px; font-weight: 600; color: #334155; margin: 0 0 20px; display: flex; align-items: center; gap: 8px; }
    .nt-form-title svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }

    .nt-form-row { display: flex; gap: 16px; margin-bottom: 16px; flex-wrap: wrap; }
    .nt-form-group { display: flex; flex-direction: column; gap: 6px; }
    .nt-form-group.full { flex: 1 1 100%; }
    .nt-form-group.half { flex: 1 1 200px; }
    .nt-form-label { font-size: 13px; font-weight: 600; color: #475569; }
    .nt-form-input, .nt-form-select, .nt-form-textarea {
        padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 10px;
        font-size: 13.5px; color: #334155; background: #fff;
        transition: border-color 0.2s, box-shadow 0.2s; outline: none;
        font-family: inherit;
    }
    .nt-form-input:focus, .nt-form-select:focus, .nt-form-textarea:focus {
        border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .nt-form-textarea { min-height: 120px; resize: vertical; width: 100%; }
    .nt-form-select { cursor: pointer; }

    .nt-form-actions { display: flex; gap: 10px; margin-top: 4px; }
    .nt-btn {
        padding: 10px 24px; border-radius: 10px; font-size: 13.5px; font-weight: 600;
        border: none; cursor: pointer; transition: all 0.2s; display: inline-flex;
        align-items: center; gap: 6px;
    }
    .nt-btn-primary { background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff; }
    .nt-btn-primary:hover { box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px); }
    .nt-btn-secondary { background: #f1f5f9; color: #64748b; }
    .nt-btn-secondary:hover { background: #e2e8f0; color: #334155; }
    .nt-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 通知列表卡片 */
    .nt-list-card {
        background: #fff; border-radius: 14px; padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.06); border: 1px solid #e8ecf1;
    }
    .nt-list-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
    .nt-list-title { font-size: 16px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .nt-list-title svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .nt-list-count { font-size: 12px; background: #eef2ff; color: #6366f1; padding: 3px 10px; border-radius: 20px; font-weight: 600; }

    .nt-table { width: 100%; border-collapse: collapse; }
    .nt-table th {
        text-align: left; font-size: 11px; font-weight: 600; color: #94a3b8;
        text-transform: uppercase; letter-spacing: 0.5px;
        padding: 10px 12px; border-bottom: 2px solid #f1f5f9; background: #fafbfc;
    }
    .nt-table td {
        padding: 14px 12px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
        vertical-align: middle;
    }
    .nt-table tr:hover td { background: #fafbfc; }
    .nt-table tr:last-child td { border-bottom: none; }

    .nt-notice-title { font-weight: 600; color: #1e293b; }
    .nt-notice-content { color: #64748b; font-size: 12px; margin-top: 4px; line-height: 1.5; }
    .nt-target-badge {
        display: inline-block; padding: 3px 10px; border-radius: 6px;
        font-size: 12px; font-weight: 500; background: #f1f5f9; color: #475569;
    }
    .nt-status-active { color: #16a34a; background: #f0fdf4; padding: 3px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .nt-status-inactive { color: #dc2626; background: #fef2f2; padding: 3px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .nt-date { font-size: 12px; color: #94a3b8; white-space: nowrap; }

    .nt-action-btn {
        padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #64748b;
        cursor: pointer; transition: all 0.15s; margin-right: 4px;
    }
    .nt-action-btn:hover { border-color: #818cf8; color: #6366f1; background: #eef2ff; }
    .nt-action-btn-danger:hover { border-color: #fca5a5; color: #dc2626; background: #fef2f2; }

    .nt-empty { text-align: center; padding: 48px 20px; color: #94a3b8; }
    .nt-empty svg { width: 48px; height: 48px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; margin-bottom: 12px; }
    .nt-empty p { font-size: 14px; margin: 0; }

    @media (max-width: 768px) {
        .nt-form-row { flex-direction: column; }
        .nt-table th:nth-child(3), .nt-table td:nth-child(3) { display: none; }
    }
</style>

<div class="nt-page">
    <div class="nt-header">
        <h2>通知发布</h2>
        <p>发布通知公告给指定年级和班级的学生</p>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="nt-msg nt-msg-<%= pageMsgType %>">
        <% if (pageMsgType == "success") { %>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <% } else if (pageMsgType == "error") { %>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <% } else { %>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <% } %>
        <%= Server.HtmlEncode(pageMsg) %>
    </div>
    <% } %>

    <!-- 发布/编辑表单 -->
    <div class="nt-form-card">
        <div class="nt-form-title">
            <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            <%= (editNid > 0) ? "编辑通知" : "发布新通知" %>
        </div>
        <asp:HiddenField ID="HiddenNid" runat="server" Value="0" />

        <div class="nt-form-row">
            <div class="nt-form-group full">
                <span class="nt-form-label">通知标题</span>
                <asp:TextBox ID="TxtTitle" runat="server" CssClass="nt-form-input" placeholder="请输入通知标题" MaxLength="200" />
            </div>
        </div>

        <div class="nt-form-row">
            <div class="nt-form-group full">
                <span class="nt-form-label">通知内容</span>
                <asp:TextBox ID="TxtContent" runat="server" CssClass="nt-form-textarea" TextMode="MultiLine" placeholder="请输入通知内容..." />
            </div>
        </div>

        <div class="nt-form-row">
            <div class="nt-form-group half">
                <span class="nt-form-label">目标年级</span>
                <asp:DropDownList ID="DDLgrade" runat="server" CssClass="nt-form-select" AutoPostBack="true" OnSelectedIndexChanged="DDLgrade_SelectedIndexChanged" />
            </div>
            <div class="nt-form-group half">
                <span class="nt-form-label">目标班级</span>
                <asp:DropDownList ID="DDLclass" runat="server" CssClass="nt-form-select" />
            </div>
        </div>

        <div class="nt-form-actions">
            <asp:Button ID="BtnPublish" runat="server" CssClass="nt-btn nt-btn-primary" Text="发布通知" OnClick="BtnPublish_Click" />
            <asp:Button ID="BtnCancel" runat="server" CssClass="nt-btn nt-btn-secondary" Text="重置" OnClick="BtnCancel_Click" />
        </div>
    </div>

    <!-- 已发布通知列表 -->
    <div class="nt-list-card">
        <div class="nt-list-header">
            <div class="nt-list-title">
                <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                已发布通知
            </div>
            <span class="nt-list-count">共 <asp:Label ID="LblCount" runat="server" Text="0" /> 条</span>
        </div>

        <asp:Repeater ID="RptNotices" runat="server" OnItemCommand="RptNotices_ItemCommand">
            <HeaderTemplate>
                <table class="nt-table">
                <tr>
                    <th style="min-width:200px;">标题 / 内容</th>
                    <th>目标范围</th>
                    <th>状态</th>
                    <th>发布时间</th>
                    <th style="text-align:right;">操作</th>
                </tr>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td>
                        <div class="nt-notice-title"><%# Server.HtmlEncode(Eval("Ntitle").ToString()) %></div>
                        <div class="nt-notice-content"><%# Server.HtmlEncode(TruncateContent(Eval("Ncontent"), 80)) %></div>
                    </td>
                    <td><span class="nt-target-badge"><%# GetTargetText(Eval("Ngrade"), Eval("Nclass")) %></span></td>
                    <td><span class='<%# GetStatusClass(Eval("Nstatus")) %>'><%# GetStatusText(Eval("Nstatus")) %></span></td>
                    <td><span class="nt-date"><%# FormatDate(Eval("Ndate")) %></span></td>
                    <td style="text-align:right; white-space:nowrap;">
                        <asp:LinkButton ID="BtnEdit" runat="server" CommandName="EditNotice" CommandArgument='<%# Eval("Nid") %>' CssClass="nt-action-btn">编辑</asp:LinkButton>
                        <asp:LinkButton ID="BtnToggle" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("Nid") %>' CssClass="nt-action-btn"><%# GetToggleText(Eval("Nstatus")) %></asp:LinkButton>
                        <asp:LinkButton ID="BtnDel" runat="server" CommandName="DeleteNotice" CommandArgument='<%# Eval("Nid") %>' CssClass="nt-action-btn nt-action-btn-danger" OnClientClick="return confirm('确定要删除这条通知吗？');">删除</asp:LinkButton>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>

        <% if (RptNotices.Items.Count == 0) { %>
        <div class="nt-empty">
            <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
            <p>暂无通知，点击上方"发布通知"按钮创建第一条通知</p>
        </div>
        <% } %>
    </div>
</div>
</asp:Content>
