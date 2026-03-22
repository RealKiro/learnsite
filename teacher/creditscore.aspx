<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected int myGrade = 0;
    protected int myClass = 0;

    private string CsGetConnStr()
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
            if (DDLgrade.Items.Count > 0)
            {
                LoadClasses();
                BindStudents();
            }
        }
    }

    private void LoadGrades()
    {
        string cs = CsGetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // Get grades this teacher teaches
                string sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade>0 ORDER BY Sgrade";
                if (myHid > 0)
                {
                    sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade IN (SELECT DISTINCT Rgrade FROM Room WHERE Rhid=" + myHid + ") ORDER BY Sgrade";
                }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader();
                    DDLgrade.Items.Clear();
                    while (dr.Read())
                    {
                        DDLgrade.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Sgrade"].ToString(), dr["Sgrade"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    private void LoadClasses()
    {
        if (DDLgrade.Items.Count == 0) return;
        int grade = int.Parse(DDLgrade.SelectedValue);
        string cs = CsGetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade + " ORDER BY Sclass";
                if (myHid > 0)
                {
                    sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade +
                          " AND Sclass IN (SELECT DISTINCT Rclass FROM Room WHERE Rhid=" + myHid + " AND Rgrade=" + grade + ") ORDER BY Sclass";
                }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader();
                    DDLclass.Items.Clear();
                    while (dr.Read())
                    {
                        DDLclass.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Sclass"].ToString(), dr["Sclass"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    private void BindStudents()
    {
        if (DDLgrade.Items.Count == 0 || DDLclass.Items.Count == 0) return;
        int grade = int.Parse(DDLgrade.SelectedValue);
        int cls = int.Parse(DDLclass.SelectedValue);
        string cs = CsGetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // 先同步表现分，再把表现分自动累计进学分总分
                try
                {
                    string syncAttitudeSql = @"UPDATE Students
                        SET Sattitude = ISNULL((
                            SELECT SUM(ISNULL(si.Qattitude,0))
                            FROM Signin si
                            WHERE si.Qnum = Students.Snum
                              AND ISNULL(si.Qgrade,0) = Students.Sgrade
                              AND ISNULL(si.Qclass,0) = Students.Sclass
                        ), 0)
                        WHERE Sgrade=@sg AND Sclass=@sc";
                    using (System.Data.SqlClient.SqlCommand syncAttitudeCmd = new System.Data.SqlClient.SqlCommand(syncAttitudeSql, conn))
                    {
                        syncAttitudeCmd.Parameters.AddWithValue("@sg", grade);
                        syncAttitudeCmd.Parameters.AddWithValue("@sc", cls);
                        syncAttitudeCmd.CommandTimeout = 10;
                        syncAttitudeCmd.ExecuteNonQuery();
                    }

                    string syncSql = @"UPDATE Students
                        SET Sscore = ISNULL((
                            SELECT SUM(ISNULL(w.Wscore,0) + ISNULL(w.Wdscore,0))
                            FROM Works w
                            WHERE w.Wnum = Students.Snum AND w.Wscore > 0
                        ), 0) + ISNULL(Students.Sattitude,0)
                        WHERE Sgrade=@sg AND Sclass=@sc";
                    using (System.Data.SqlClient.SqlCommand syncCmd = new System.Data.SqlClient.SqlCommand(syncSql, conn))
                    {
                        syncCmd.Parameters.AddWithValue("@sg", grade);
                        syncCmd.Parameters.AddWithValue("@sc", cls);
                        syncCmd.CommandTimeout = 10;
                        syncCmd.ExecuteNonQuery();
                    }
                }
                catch { }
                string sql = "SELECT Snum, Sname, ISNULL(Sattitude,0) AS Sattitude, ISNULL(Sscore,0) AS Sscore, ISNULL(Sgroup,0) AS Sgroup FROM Students WHERE Sgrade=" + grade + " AND Sclass=" + cls + " ORDER BY Snum";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                GVStudents.DataSource = dt;
                GVStudents.DataBind();
                LabelCount.Text = dt.Rows.Count.ToString();

                // Calculate total and average
                int total = 0;
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    total += Convert.ToInt32(row["Sscore"]);
                }
                LabelTotal.Text = total.ToString();
                LabelAvg.Text = dt.Rows.Count > 0 ? (total * 1.0 / dt.Rows.Count).ToString("F1") : "0";
            }
        }
        catch (Exception ex)
        {
            LabelCount.Text = "错误:" + ex.Message;
        }
    }

    protected void DDLgrade_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadClasses();
        BindStudents();
    }

    protected void DDLclass_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindStudents();
    }

    protected string GetScoreClass(object score)
    {
        int s = 0;
        if (score != null && score != DBNull.Value) int.TryParse(score.ToString(), out s);
        if (s >= 50) return "cs-score-high";
        if (s >= 20) return "cs-score-mid";
        if (s > 0) return "cs-score-low";
        return "cs-score-zero";
    }

    protected string GetAttitudeClass(object score)
    {
        int s = 0;
        if (score != null && score != DBNull.Value) int.TryParse(score.ToString(), out s);
        if (s > 0) return "cs-attitude-positive";
        if (s < 0) return "cs-attitude-negative";
        return "cs-attitude-zero";
    }

    protected string GetSignedScoreText(object score)
    {
        int s = 0;
        if (score != null && score != DBNull.Value) int.TryParse(score.ToString(), out s);
        return s > 0 ? "+" + s.ToString() : s.ToString();
    }

    protected string GetBarClass(object score)
    {
        int s = 0;
        if (score != null && score != DBNull.Value) int.TryParse(score.ToString(), out s);
        if (s >= 50) return "high";
        if (s >= 20) return "mid";
        if (s > 0) return "low";
        return "zero";
    }

    protected string GetBarWidth(object score)
    {
        int s = 0;
        if (score != null && score != DBNull.Value) int.TryParse(score.ToString(), out s);
        int maxScore = 100;
        int pct = s > maxScore ? 100 : (s * 100 / maxScore);
        if (s > 0 && pct < 5) pct = 5;
        return pct.ToString() + "%";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .cs-page { max-width: 1200px; width: 96%; margin: 0 auto; padding: 10px 0; font-family: 'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }

    /* === 页面头部 === */
    .cs-header {
        display: flex; align-items: center; gap: 20px;
        margin-bottom: 24px; padding: 28px 32px;
        background: linear-gradient(135deg, #6366f1 0%, #7c3aed 50%, #a855f7 100%);
        border-radius: 20px; position: relative; overflow: hidden;
        box-shadow: 0 10px 40px rgba(99,102,241,0.25), 0 2px 8px rgba(0,0,0,0.06);
    }
    .cs-header::before {
        content: ''; position: absolute; top: -60%; right: -15%;
        width: 350px; height: 350px; border-radius: 50%;
        background: rgba(255,255,255,0.06);
    }
    .cs-header::after {
        content: ''; position: absolute; bottom: -40%; left: -10%;
        width: 200px; height: 200px; border-radius: 50%;
        background: rgba(255,255,255,0.04);
    }
    .cs-header-icon {
        width: 56px; height: 56px; background: rgba(255,255,255,0.18);
        backdrop-filter: blur(12px); border-radius: 16px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; box-shadow: 0 4px 16px rgba(0,0,0,0.12);
        position: relative; z-index: 1;
    }
    .cs-header-icon svg { width: 28px; height: 28px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cs-header-info { position: relative; z-index: 1; }
    .cs-header-title { font-size: 24px; font-weight: 800; color: #fff; margin-bottom: 6px; letter-spacing: 0.5px; }
    .cs-header-sub { font-size: 13px; color: rgba(255,255,255,0.75); font-weight: 400; }

    /* === 统计卡片 === */
    .cs-stats {
        display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;
    }
    .cs-stat-card {
        background: #fff; border-radius: 16px; padding: 22px 24px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04), 0 1px 3px rgba(0,0,0,0.02);
        display: flex; align-items: center; gap: 18px;
        border: 1px solid #f1f5f9;
        transition: all 0.25s ease;
    }
    .cs-stat-card:hover {
        box-shadow: 0 8px 28px rgba(0,0,0,0.08);
        transform: translateY(-2px);
    }
    .cs-stat-icon {
        width: 52px; height: 52px; border-radius: 14px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .cs-stat-icon svg { width: 24px; height: 24px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cs-stat-icon.blue { background: linear-gradient(135deg, #eef2ff, #e0e7ff); }
    .cs-stat-icon.blue svg { stroke: #6366f1; }
    .cs-stat-icon.green { background: linear-gradient(135deg, #ecfdf5, #d1fae5); }
    .cs-stat-icon.green svg { stroke: #10b981; }
    .cs-stat-icon.amber { background: linear-gradient(135deg, #fffbeb, #fef3c7); }
    .cs-stat-icon.amber svg { stroke: #f59e0b; }
    .cs-stat-num { font-size: 28px; font-weight: 800; color: #1e293b; letter-spacing: -0.5px; }
    .cs-stat-label { font-size: 12px; color: #94a3b8; font-weight: 500; margin-top: 3px; letter-spacing: 0.3px; }

    /* === 筛选栏 === */
    .cs-card {
        background: #fff; border-radius: 18px;
        box-shadow: 0 2px 16px rgba(0,0,0,0.05), 0 1px 3px rgba(0,0,0,0.02);
        overflow: hidden;
        border: 1px solid #f1f5f9;
    }
    .cs-filter {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9;
        background: linear-gradient(135deg, #fafbfc, #f8fafc);
    }
    .cs-filter-label {
        font-size: 14px; font-weight: 700; color: #334155;
        display: flex; align-items: center; gap: 8px;
    }
    .cs-filter-label svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cs-filter select {
        height: 38px; padding: 0 14px; border-radius: 10px;
        border: 1.5px solid #e2e8f0; background: #fff; font-size: 14px;
        color: #334155; font-weight: 500; outline: none; cursor: pointer;
        transition: all 0.2s;
    }
    .cs-filter select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.12); }

    /* === 表格 === */
    .cs-table-wrap { padding: 0; overflow-x: auto; }
    .cs-table-wrap table { width: 100%; border-collapse: collapse; }
    .cs-table-wrap table th {
        background: linear-gradient(135deg, #f8fafc, #eef2ff);
        color: #64748b; font-weight: 700; font-size: 12px;
        padding: 16px 20px; border-bottom: 2px solid #e0e7ff;
        text-align: center; letter-spacing: 0.5px;
        text-transform: uppercase;
        position: sticky; top: 0; z-index: 1;
    }
    .cs-table-wrap table td {
        padding: 0; border-bottom: 1px solid #f1f5f9;
        font-size: 14px; color: #334155; text-align: center;
        vertical-align: middle;
    }
    .cs-table-wrap table tr { transition: all 0.2s ease; }
    .cs-table-wrap table tr:hover td { background: linear-gradient(135deg, #fafaff, #f5f3ff); }
    .cs-table-wrap table tr:last-child td { border-bottom: none; }

    /* 行内单元格样式 */
    .cs-table-wrap table td .cs-cell {
        display: flex; align-items: center; justify-content: center;
        padding: 14px 20px; min-height: 56px;
    }
    .cs-table-wrap table td:first-child .cs-cell {
        justify-content: center;
    }

    /* 序号列 */
    .cs-rank {
        display: inline-flex; align-items: center; justify-content: center;
        width: 32px; height: 32px; border-radius: 10px;
        font-size: 13px; font-weight: 700;
        background: #f1f5f9; color: #94a3b8;
    }
    .cs-rank-1 {
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #92400e;
        box-shadow: 0 2px 8px rgba(245,158,11,0.2);
    }
    .cs-rank-2 {
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
        color: #475569;
        box-shadow: 0 2px 6px rgba(0,0,0,0.06);
    }
    .cs-rank-3 {
        background: linear-gradient(135deg, #fed7aa, #fdba74);
        color: #9a3412;
        box-shadow: 0 2px 6px rgba(251,146,60,0.2);
    }

    /* 姓名列 */
    .cs-name {
        font-weight: 700; color: #1e293b; font-size: 14px;
    }

    /* 学分分值标签 - 增强版 */
    .cs-score-high {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 52px; padding: 6px 16px; border-radius: 22px;
        font-size: 15px; font-weight: 800;
        background: linear-gradient(135deg, #ecfdf5, #d1fae5); color: #059669;
        border: 1.5px solid #a7f3d0;
        box-shadow: 0 2px 8px rgba(16,185,129,0.12);
    }
    .cs-score-mid {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 52px; padding: 6px 16px; border-radius: 22px;
        font-size: 15px; font-weight: 800;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff); color: #4f46e5;
        border: 1.5px solid #c7d2fe;
        box-shadow: 0 2px 8px rgba(99,102,241,0.1);
    }
    .cs-score-low {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 52px; padding: 6px 16px; border-radius: 22px;
        font-size: 15px; font-weight: 800;
        background: linear-gradient(135deg, #fffbeb, #fef3c7); color: #d97706;
        border: 1.5px solid #fde68a;
        box-shadow: 0 2px 8px rgba(245,158,11,0.1);
    }
    .cs-score-zero {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 52px; padding: 6px 16px; border-radius: 22px;
        font-size: 15px; font-weight: 700;
        background: #f8fafc; color: #cbd5e1;
        border: 1.5px solid #e2e8f0;
    }

    .cs-attitude-positive,
    .cs-attitude-negative,
    .cs-attitude-zero {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 62px; padding: 6px 14px; border-radius: 22px;
        font-size: 14px; font-weight: 800;
        letter-spacing: 0.2px;
    }
    .cs-attitude-positive {
        background: linear-gradient(135deg, #ecfdf5, #d1fae5);
        color: #059669;
        border: 1.5px solid #a7f3d0;
        box-shadow: 0 2px 8px rgba(16,185,129,0.12);
    }
    .cs-attitude-negative {
        background: linear-gradient(135deg, #fff1f2, #ffe4e6);
        color: #e11d48;
        border: 1.5px solid #fecdd3;
        box-shadow: 0 2px 8px rgba(244,63,94,0.1);
    }
    .cs-attitude-zero {
        background: #f8fafc;
        color: #94a3b8;
        border: 1.5px solid #e2e8f0;
    }

    /* 学分进度条 */
    .cs-bar-wrap {
        display: flex; align-items: center; gap: 10px;
        padding: 0 20px;
    }
    .cs-bar {
        flex: 1; height: 8px; background: #f1f5f9; border-radius: 4px;
        overflow: hidden; max-width: 120px;
    }
    .cs-bar-fill {
        height: 100%; border-radius: 4px;
        transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .cs-bar-fill.high { background: linear-gradient(90deg, #10b981, #34d399); }
    .cs-bar-fill.mid { background: linear-gradient(90deg, #6366f1, #818cf8); }
    .cs-bar-fill.low { background: linear-gradient(90deg, #f59e0b, #fbbf24); }
    .cs-bar-fill.zero { background: #e2e8f0; }

    /* 小组标签 */
    .cs-group {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 28px; padding: 4px 12px; border-radius: 14px;
        font-size: 12px; font-weight: 700;
        background: linear-gradient(135deg, #f5f3ff, #ede9fe); color: #7c3aed;
        border: 1px solid #ddd6fe;
    }

    /* 空数据 */
    .cs-empty {
        padding: 80px 20px; text-align: center;
        color: #94a3b8; font-size: 14px;
    }
    .cs-empty svg { width: 56px; height: 56px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; margin-bottom: 16px; display: block; margin: 0 auto 16px; }

    /* === 响应式 === */
    @media (max-width: 768px) {
        .cs-stats { grid-template-columns: 1fr; }
        .cs-header { padding: 20px; }
        .cs-stat-num { font-size: 22px; }
    }
</style>

<div class="cs-page">
    <!-- 页面头部 -->
    <div class="cs-header">
        <div class="cs-header-icon">
            <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
        </div>
        <div class="cs-header-info">
            <div class="cs-header-title">学分管理</div>
            <div class="cs-header-sub">查看授课班级学生的学分情况</div>
        </div>
    </div>

    <!-- 统计卡片 -->
    <div class="cs-stats">
        <div class="cs-stat-card">
            <div class="cs-stat-icon blue"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
            <div>
                <div class="cs-stat-num"><asp:Label ID="LabelCount" runat="server" Text="0" /></div>
                <div class="cs-stat-label">学生人数</div>
            </div>
        </div>
        <div class="cs-stat-card">
            <div class="cs-stat-icon green"><svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg></div>
            <div>
                <div class="cs-stat-num"><asp:Label ID="LabelTotal" runat="server" Text="0" /></div>
                <div class="cs-stat-label">总学分</div>
            </div>
        </div>
        <div class="cs-stat-card">
            <div class="cs-stat-icon amber"><svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></div>
            <div>
                <div class="cs-stat-num"><asp:Label ID="LabelAvg" runat="server" Text="0" /></div>
                <div class="cs-stat-label">平均学分</div>
            </div>
        </div>
    </div>

    <!-- 数据卡片 -->
    <div class="cs-card">
        <div class="cs-filter">
            <span class="cs-filter-label">
                <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
                班级筛选
            </span>
            <asp:DropDownList ID="DDLgrade" runat="server" AutoPostBack="True" OnSelectedIndexChanged="DDLgrade_SelectedIndexChanged" />
            <span style="color:#64748b;font-size:13px;">年级</span>
            <asp:DropDownList ID="DDLclass" runat="server" AutoPostBack="True" OnSelectedIndexChanged="DDLclass_SelectedIndexChanged" />
            <span style="color:#64748b;font-size:13px;">班</span>
        </div>
        <div class="cs-table-wrap">
            <asp:GridView ID="GVStudents" runat="server" AutoGenerateColumns="False"
                Width="100%" CellPadding="0" Font-Size="9pt" GridLines="None"
                ShowHeaderWhenEmpty="true" EmptyDataText="暂无学生数据">
                <Columns>
                    <asp:TemplateField HeaderText="学号">
                        <ItemTemplate>
                            <div class="cs-cell">
                                <span style="font-family:'Consolas','Monaco',monospace;font-size:13px;color:#64748b;font-weight:600;letter-spacing:0.5px;"><%# Eval("Snum") %></span>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="120px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="姓名">
                        <ItemTemplate>
                            <div class="cs-cell">
                                <span class="cs-name"><%# Server.HtmlEncode(Eval("Sname") == DBNull.Value ? "" : Eval("Sname").ToString()) %></span>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="140px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="小组">
                        <ItemTemplate>
                            <div class="cs-cell">
                                <span class="cs-group"><%# Eval("Sgroup") %></span>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="80px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="表现">
                        <ItemTemplate>
                            <div class="cs-cell">
                                <span class='<%# GetAttitudeClass(Eval("Sattitude")) %>'><%# GetSignedScoreText(Eval("Sattitude")) %></span>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="100px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="学分">
                        <ItemTemplate>
                            <div class="cs-cell">
                                <span class='<%# GetScoreClass(Eval("Sscore")) %>'><%# Eval("Sscore") %></span>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="100px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="进度">
                        <ItemTemplate>
                            <div class="cs-bar-wrap">
                                <div class="cs-bar">
                                    <div class='cs-bar-fill <%# GetBarClass(Eval("Sscore")) %>' style='width:<%# GetBarWidth(Eval("Sscore")) %>'></div>
                                </div>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="160px" />
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle Height="48px" />
                <RowStyle Height="56px" />
                <AlternatingRowStyle BackColor="#fafbfc" />
                <EmptyDataRowStyle HorizontalAlign="Center" Height="120px" ForeColor="#94a3b8" />
            </asp:GridView>
        </div>
    </div>
</div>
</asp:Content>
