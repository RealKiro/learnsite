<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" EnableEventValidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected int totalClassCount = 0;
    protected int totalStudentCount = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSchools();
            LoadGrades();
        }
        LoadClassList();
    }

    // 获取连接字符串 — 与 teacher.aspx 保持一致，优先 ConfigurationManager
    private string GetConnectionString()
    {
        // 方式1：与 teacher.aspx 相同，直接读配置
        try
        {
            ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["constr"];
            if (cfg == null) cfg = ConfigurationManager.ConnectionStrings["SqlServer"];
            if (cfg != null && !string.IsNullOrEmpty(cfg.ConnectionString)) return cfg.ConnectionString;
        }
        catch { }
        // 方式2：通过反射读取 DLL 中已初始化的连接字符串（兼容旧版本）
        try
        {
            Type t = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (t != null)
            {
                System.Reflection.FieldInfo f = t.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null)
                {
                    string cs = f.GetValue(null) as string;
                    if (!string.IsNullOrEmpty(cs)) return cs;
                }
            }
        }
        catch { }
        return null;
    }

    private bool TableExists(SqlConnection conn, string table)
    {
        using (SqlCommand cmd = new SqlCommand(
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@T", conn))
        { cmd.Parameters.AddWithValue("@T", table); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
    }

    private bool ColumnExists(SqlConnection conn, string table, string col)
    {
        using (SqlCommand cmd = new SqlCommand(
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@T AND COLUMN_NAME=@C", conn))
        { cmd.Parameters.AddWithValue("@T", table); cmd.Parameters.AddWithValue("@C", col); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
    }

    // 加载学校列表 — 与 teacher.aspx 相同数据源
    private void LoadSchools()
    {
        try
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                if (!TableExists(conn, "School")) return;

                ddlSchool.Items.Clear();
                ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem("全部学校/校区", ""));

                string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem(
                            reader["SchoolName"].ToString(), reader["SchoolId"].ToString()));
                    }
                }
            }
        }
        catch { }
    }

    // 加载年级列表（如果选中了具体校区，按 Room.SchoolId 筛选，与 createroom.aspx 保持一致）
    private void LoadGrades()
    {
        try
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                ddlGrade.Items.Clear();
                ddlGrade.Items.Add(new System.Web.UI.WebControls.ListItem("全部年级", ""));

                bool filterBySchool = !string.IsNullOrEmpty(ddlSchool.SelectedValue)
                    && TableExists(conn, "School")
                    && ColumnExists(conn, "Room", "SchoolId");

                string sql;
                if (filterBySchool)
                    sql = "SELECT DISTINCT Rgrade FROM Room WHERE SchoolId = @SchoolId ORDER BY Rgrade";
                else
                    sql = "SELECT DISTINCT Rgrade FROM Room ORDER BY Rgrade";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (filterBySchool)
                        cmd.Parameters.AddWithValue("@SchoolId", int.Parse(ddlSchool.SelectedValue));
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string grade = reader["Rgrade"].ToString();
                            ddlGrade.Items.Add(new System.Web.UI.WebControls.ListItem(grade + "年级", grade));
                        }
                    }
                }
            }
        }
        catch { }
    }

    // 校区下拉改变时：重载年级列表并刷新班级列表
    protected void DdlSchool_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlGrade.SelectedIndex = 0;
        LoadGrades();
        LoadClassList();
    }

    // 筛选按鈕点击
    protected void BtnFilter_Click(object sender, EventArgs e)
    {
        LoadClassList();
    }

    // 加载班级列表
    // 学校来源：优先 Room.SchoolId，回退到 Teacher.SchoolId（与 teacher.aspx 同步）
    private void LoadClassList()
    {
        string connStr = GetConnectionString();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                bool hasSchoolTable = TableExists(conn, "School");
                bool roomHasSchoolId = hasSchoolTable && ColumnExists(conn, "Room", "SchoolId");
                bool teacherHasSchoolId = hasSchoolTable && ColumnExists(conn, "Teacher", "SchoolId");

                // 构建筛选条件
                System.Text.StringBuilder where = new System.Text.StringBuilder();
                where.Append(" WHERE 1=1 ");

                bool filterBySchool = !string.IsNullOrEmpty(ddlSchool.SelectedValue) && hasSchoolTable;
                if (filterBySchool)
                {
                    // 同时匹配 Room.SchoolId 或 Teacher.SchoolId，保持与 teacher.aspx 同步
                    if (roomHasSchoolId && teacherHasSchoolId)
                        where.Append(" AND (r.SchoolId = @SchoolId OR (r.SchoolId IS NULL AND t.SchoolId = @SchoolId) OR (r.SchoolId = 0 AND t.SchoolId = @SchoolId)) ");
                    else if (roomHasSchoolId)
                        where.Append(" AND r.SchoolId = @SchoolId ");
                    else if (teacherHasSchoolId)
                        where.Append(" AND t.SchoolId = @SchoolId ");
                }
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                    where.Append(" AND r.Rgrade = @Rgrade ");

                // 构建 SQL — 用 COALESCE 使显示的学校与 teacher.aspx 一致
                string sql;
                if (roomHasSchoolId && teacherHasSchoolId)
                {
                    // Room 有 SchoolId 且 Teacher 也有 SchoolId
                    // 优先用 Room.SchoolId 对应的学校名，没有则回退到 Teacher.SchoolId 对应的学校名
                    sql = @"SELECT r.Rid, r.Rgrade, r.Rclass,
                            COALESCE(s_room.SchoolName, s_teacher.SchoolName, N'未指定') AS SchoolName,
                            ISNULL(t.Hname, N'未分配') AS TeacherName,
                            (SELECT COUNT(*) FROM Students st WHERE st.Sgrade = r.Rgrade AND st.Sclass = r.Rclass) AS StudentCount
                            FROM Room r
                            LEFT JOIN Teacher t ON r.Rhid = t.Hid
                            LEFT JOIN School s_room ON r.SchoolId = s_room.SchoolId AND s_room.IsActive = 1
                            LEFT JOIN School s_teacher ON t.SchoolId = s_teacher.SchoolId AND s_teacher.IsActive = 1"
                        + where.ToString()
                        + " ORDER BY r.Rgrade, r.Rclass";
                }
                else if (roomHasSchoolId)
                {
                    sql = @"SELECT r.Rid, r.Rgrade, r.Rclass,
                            ISNULL(s.SchoolName, N'未指定') AS SchoolName,
                            ISNULL(t.Hname, N'未分配') AS TeacherName,
                            (SELECT COUNT(*) FROM Students st WHERE st.Sgrade = r.Rgrade AND st.Sclass = r.Rclass) AS StudentCount
                            FROM Room r
                            LEFT JOIN Teacher t ON r.Rhid = t.Hid
                            LEFT JOIN School s ON r.SchoolId = s.SchoolId"
                        + where.ToString()
                        + " ORDER BY r.Rgrade, r.Rclass";
                }
                else if (teacherHasSchoolId)
                {
                    // Room 没有 SchoolId，通过教师关联获取学校（与 teacher.aspx 完全一致）
                    sql = @"SELECT r.Rid, r.Rgrade, r.Rclass,
                            ISNULL(s.SchoolName, N'未指定') AS SchoolName,
                            ISNULL(t.Hname, N'未分配') AS TeacherName,
                            (SELECT COUNT(*) FROM Students st WHERE st.Sgrade = r.Rgrade AND st.Sclass = r.Rclass) AS StudentCount
                            FROM Room r
                            LEFT JOIN Teacher t ON r.Rhid = t.Hid
                            LEFT JOIN School s ON t.SchoolId = s.SchoolId"
                        + where.ToString()
                        + " ORDER BY r.Rgrade, r.Rclass";
                }
                else
                {
                    sql = @"SELECT r.Rid, r.Rgrade, r.Rclass,
                            N'—' AS SchoolName,
                            ISNULL(t.Hname, N'未分配') AS TeacherName,
                            (SELECT COUNT(*) FROM Students st WHERE st.Sgrade = r.Rgrade AND st.Sclass = r.Rclass) AS StudentCount
                            FROM Room r
                            LEFT JOIN Teacher t ON r.Rhid = t.Hid"
                        + where.ToString()
                        + " ORDER BY r.Rgrade, r.Rclass";
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (filterBySchool)
                        cmd.Parameters.AddWithValue("@SchoolId", int.Parse(ddlSchool.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                        cmd.Parameters.AddWithValue("@Rgrade", int.Parse(ddlGrade.SelectedValue));

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptClasses.DataSource = dt;
                    rptClasses.DataBind();

                    totalClassCount = dt.Rows.Count;
                    totalStudentCount = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        totalStudentCount += Convert.ToInt32(row["StudentCount"]);
                    }

                    lblClassCount.Text = totalClassCount.ToString();
                    lblStudentCount.Text = totalStudentCount.ToString();
                }
            }
        }
        catch (Exception ex)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = "加载失败：" + ex.Message;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cl-page {
        max-width: 100%;
        padding: 28px 32px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }

    .cl-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
    }

    .cl-header-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
        flex-shrink: 0;
    }

    .cl-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .cl-header-text h1 {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 2px;
    }

    .cl-header-text p {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
    }

    /* 统计卡片 */
    .cl-stats {
        display: flex;
        gap: 16px;
        margin-bottom: 20px;
    }

    .cl-stat {
        flex: 1;
        padding: 20px;
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        text-align: center;
        transition: box-shadow 0.25s, transform 0.25s;
    }

    .cl-stat:hover {
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.07);
        transform: translateY(-2px);
    }

    .cl-stat-icon {
        width: 42px;
        height: 42px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 10px;
    }

    .cl-stat-icon svg {
        width: 22px;
        height: 22px;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
        fill: none;
    }

    .cl-stat-icon.purple {
        background: #eef2ff;
    }

    .cl-stat-icon.purple svg {
        stroke: #6366f1;
    }

    .cl-stat-icon.sky {
        background: #f0f9ff;
    }

    .cl-stat-icon.sky svg {
        stroke: #0ea5e9;
    }

    .cl-stat-value {
        font-size: 28px;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 4px;
    }

    .cl-stat-label {
        font-size: 12px;
        color: #94a3b8;
        font-weight: 500;
    }

    /* 筛选卡片 */
    .cl-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        overflow: hidden;
        margin-bottom: 20px;
        transition: box-shadow 0.25s;
    }

    .cl-card-hd {
        padding: 16px 22px;
        font-size: 15px;
        font-weight: 600;
        color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .cl-card-hd .ci {
        width: 34px;
        height: 34px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .cl-card-hd .ci svg {
        width: 19px;
        height: 19px;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
        fill: none;
    }

    .ci.purple {
        background: #eef2ff;
    }

    .ci.purple svg {
        stroke: #6366f1;
    }

    .ci.sky {
        background: #f0f9ff;
    }

    .ci.sky svg {
        stroke: #0ea5e9;
    }

    .cl-card-bd {
        padding: 20px 22px;
    }

    .cl-filter-row {
        display: flex;
        align-items: flex-end;
        gap: 16px;
        flex-wrap: wrap;
    }

    .cl-form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .cl-label {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
    }

    .cl-select {
        height: 38px;
        padding: 0 32px 0 12px;
        border: 1.5px solid #e2e8f0;
        border-radius: 9px;
        font-size: 13px;
        font-family: inherit;
        background: #f8fafc;
        outline: none;
        cursor: pointer;
        transition: border-color 0.2s, box-shadow 0.2s;
        -webkit-appearance: none;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        min-width: 180px;
    }

    .cl-select:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
        background-color: #fff;
    }

    .cl-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        height: 38px;
        padding: 0 24px;
        background: linear-gradient(135deg, #6366f1, #7c3aed);
        color: #fff !important;
        border: none;
        border-radius: 9px;
        font-size: 13px;
        font-family: inherit;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 6px rgba(99, 102, 241, 0.3);
        letter-spacing: 0.3px;
    }

    .cl-btn:hover {
        box-shadow: 0 4px 14px rgba(99, 102, 241, 0.4);
        transform: translateY(-1px);
    }

    /* 表格 */
    .cl-table-wrap {
        border-radius: 10px;
        overflow: hidden;
        border: 1px solid #e2e8f0;
    }

    .cl-table-wrap table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }

    .cl-table-wrap th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        padding: 12px 16px;
        text-align: left;
        font-size: 12.5px;
        border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }

    .cl-table-wrap td {
        padding: 12px 16px;
        color: #334155;
        border-bottom: 1px solid #f1f5f9;
    }

    .cl-table-wrap tr:last-child td {
        border-bottom: none;
    }

    .cl-table-wrap tbody tr:hover td {
        background: #f8fafc;
    }

    .cl-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
    }

    .cl-badge-school {
        background: #eef2ff;
        color: #4338ca;
    }

    .cl-badge-teacher {
        background: #ecfdf5;
        color: #065f46;
    }

    .cl-badge-none {
        background: #f1f5f9;
        color: #94a3b8;
    }

    .cl-badge-count {
        background: #fff7ed;
        color: #c2410c;
        font-weight: 700;
    }

    .cl-grade-class {
        font-weight: 700;
        font-size: 14px;
        color: #1e293b;
    }

    .cl-empty {
        text-align: center;
        padding: 40px 20px;
        color: #94a3b8;
        font-size: 14px;
    }

    .cl-empty svg {
        width: 48px;
        height: 48px;
        stroke: #cbd5e1;
        fill: none;
        stroke-width: 1.5;
        margin-bottom: 12px;
    }

    .cl-msg {
        text-align: center;
        padding: 10px;
        font-size: 13px;
        margin-top: 12px;
    }

    @media(max-width:600px) {
        .cl-stats { flex-direction: column; }
        .cl-filter-row { flex-direction: column; align-items: stretch; }
    }
</style>

<div class="cl-page">
    <!-- 页面标题 -->
    <div class="cl-header">
        <div class="cl-header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
        </div>
        <div class="cl-header-text">
            <h1>班级列表</h1>
            <p>查看系统中已创建的所有班级信息</p>
        </div>
    </div>

    <!-- 统计卡片 -->
    <div class="cl-stats">
        <div class="cl-stat">
            <div class="cl-stat-icon purple">
                <svg viewBox="0 0 24 24">
                    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                    <line x1="9" y1="3" x2="9" y2="21"/>
                    <line x1="15" y1="3" x2="15" y2="21"/>
                    <line x1="3" y1="9" x2="21" y2="9"/>
                    <line x1="3" y1="15" x2="21" y2="15"/>
                </svg>
            </div>
            <div class="cl-stat-value"><asp:Label ID="lblClassCount" runat="server" Text="0"></asp:Label></div>
            <div class="cl-stat-label">班级总数</div>
        </div>
        <div class="cl-stat">
            <div class="cl-stat-icon sky">
                <svg viewBox="0 0 24 24">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
            </div>
            <div class="cl-stat-value"><asp:Label ID="lblStudentCount" runat="server" Text="0"></asp:Label></div>
            <div class="cl-stat-label">学生总数</div>
        </div>
    </div>

    <!-- 筛选 -->
    <div class="cl-card">
        <div class="cl-card-hd">
            <span class="ci purple">
                <svg viewBox="0 0 24 24">
                    <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
                </svg>
            </span>
            筛选条件
        </div>
        <div class="cl-card-bd">
            <div class="cl-filter-row">
                <div class="cl-form-group">
                    <label class="cl-label">学校/校区</label>
                    <asp:DropDownList ID="ddlSchool" runat="server" CssClass="cl-select" AutoPostBack="True" OnSelectedIndexChanged="DdlSchool_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="cl-form-group">
                    <label class="cl-label">年级</label>
                    <asp:DropDownList ID="ddlGrade" runat="server" CssClass="cl-select"></asp:DropDownList>
                </div>
                <asp:Button ID="btnFilter" runat="server" Text="筛选" CssClass="cl-btn" OnClick="BtnFilter_Click" />
            </div>
        </div>
    </div>

    <!-- 班级列表 -->
    <div class="cl-card">
        <div class="cl-card-hd">
            <span class="ci sky">
                <svg viewBox="0 0 24 24">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
            </span>
            班级列表
        </div>
        <div class="cl-card-bd" style="padding:0;">
            <div class="cl-table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>序号</th>
                            <th>班级</th>
                            <th>学校/校区</th>
                            <th>任课教师</th>
                            <th>学生人数</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptClasses" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Container.ItemIndex + 1 %></td>
                                    <td>
                                        <span class="cl-grade-class"><%# Eval("Rgrade") %>年级 <%# Eval("Rclass") %>班</span>
                                    </td>
                                    <td>
                                        <%# Eval("SchoolName").ToString() == "未指定" || Eval("SchoolName").ToString() == "—"
                                            ? "<span class='cl-badge cl-badge-none'>" + Eval("SchoolName") + "</span>"
                                            : "<span class='cl-badge cl-badge-school'>" + Eval("SchoolName") + "</span>" %>
                                    </td>
                                    <td>
                                        <%# Eval("TeacherName").ToString() == "未分配"
                                            ? "<span class='cl-badge cl-badge-none'>未分配</span>"
                                            : "<span class='cl-badge cl-badge-teacher'>" + Eval("TeacherName") + "</span>" %>
                                    </td>
                                    <td>
                                        <span class="cl-badge cl-badge-count"><%# Eval("StudentCount") %> 人</span>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <% if (totalClassCount == 0) { %>
            <div class="cl-empty">
                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                    <line x1="9" y1="3" x2="9" y2="21"/>
                    <line x1="15" y1="3" x2="15" y2="21"/>
                    <line x1="3" y1="9" x2="21" y2="9"/>
                    <line x1="3" y1="15" x2="21" y2="15"/>
                </svg>
                <div>暂无班级数据</div>
                <div style="margin-top:8px;font-size:12px;">请前往 <a href="createroom.aspx" style="color:#6366f1;font-weight:600;">班级设置</a> 创建班级</div>
            </div>
            <% } %>
        </div>
    </div>

    <div class="cl-msg">
        <asp:Label ID="lblMessage" runat="server"></asp:Label>
    </div>
</div>
</asp:Content>
