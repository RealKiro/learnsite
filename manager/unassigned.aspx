<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" EnableEventValidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected int totalCount = 0;
    protected int currentPage = 1;
    protected int pageSize = 20;
    protected int totalPages = 1;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSchools();
            LoadGrades();
            LoadUnassignedStudents();
        }
    }
    
    // 获取连接字符串
    private string GetConnectionString()
    {
        ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
        if (connStrConfig == null)
        {
            connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
        }
        return connStrConfig != null ? connStrConfig.ConnectionString : null;
    }
    
    // 加载学校列表
    private void LoadSchools()
    {
        try
        {
            string connStr = GetConnectionString();
            if (connStr == null) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                ddlBatchSchool.Items.Clear();
                
                if (tableExists > 0)
                {
                    string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    SqlDataReader reader = cmd.ExecuteReader();
                    
                    while (reader.Read())
                    {
                        ddlBatchSchool.Items.Add(new System.Web.UI.WebControls.ListItem(
                            reader["SchoolName"].ToString(),
                            reader["SchoolId"].ToString()
                        ));
                    }
                    reader.Close();
                }
            }
        }
        catch { }
    }
    
    // 加载年级列表
    private void LoadGrades()
    {
        try
        {
            string connStr = GetConnectionString();
            if (connStr == null) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                ddlGrade.Items.Clear();
                ddlGrade.Items.Add(new System.Web.UI.WebControls.ListItem("全部年级", ""));
                
                string sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade IS NOT NULL AND SchoolId IS NULL ORDER BY Sgrade";
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataReader reader = cmd.ExecuteReader();
                
                while (reader.Read())
                {
                    string grade = reader["Sgrade"].ToString();
                    ddlGrade.Items.Add(new System.Web.UI.WebControls.ListItem(grade + "年级", grade));
                }
                reader.Close();
            }
        }
        catch { }
    }
    
    // 搜索按钮点击
    protected void BtnSearch_Click(object sender, EventArgs e)
    {
        currentPage = 1;
        LoadUnassignedStudents();
    }
    
    // 加载未分配学生列表
    private void LoadUnassignedStudents()
    {
        try
        {
            string connStr = GetConnectionString();
            if (connStr == null) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 构建查询条件
                System.Text.StringBuilder whereClause = new System.Text.StringBuilder();
                whereClause.Append(" WHERE SchoolId IS NULL ");
                
                // 年级筛选
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                {
                    whereClause.Append(" AND Sgrade = @Sgrade ");
                }
                
                // 关键词搜索
                if (!string.IsNullOrEmpty(txtKeyword.Text.Trim()))
                {
                    whereClause.Append(" AND (Snum LIKE @Keyword OR Sname LIKE @Keyword) ");
                }
                
                // 获取总数
                string countSql = "SELECT COUNT(*) FROM Students " + whereClause.ToString();
                SqlCommand cmdCount = new SqlCommand(countSql, conn);
                
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                    cmdCount.Parameters.AddWithValue("@Sgrade", int.Parse(ddlGrade.SelectedValue));
                if (!string.IsNullOrEmpty(txtKeyword.Text.Trim()))
                    cmdCount.Parameters.AddWithValue("@Keyword", "%" + txtKeyword.Text.Trim() + "%");
                
                totalCount = (int)cmdCount.ExecuteScalar();
                totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
                if (totalPages < 1) totalPages = 1;
                
                // 获取当前页
                string pageParam = Request.QueryString["page"];
                if (!string.IsNullOrEmpty(pageParam))
                {
                    int.TryParse(pageParam, out currentPage);
                }
                if (currentPage < 1) currentPage = 1;
                if (currentPage > totalPages) currentPage = totalPages;
                
                // 查询数据
                string sql = @"
                    SELECT Sid, Snum, Syear, Sgrade, Sclass, Sname, Sex, Sphone
                    FROM Students
                    " + whereClause.ToString() + @"
                    ORDER BY Sgrade, Sclass, Snum
                    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                    cmd.Parameters.AddWithValue("@Sgrade", int.Parse(ddlGrade.SelectedValue));
                if (!string.IsNullOrEmpty(txtKeyword.Text.Trim()))
                    cmd.Parameters.AddWithValue("@Keyword", "%" + txtKeyword.Text.Trim() + "%");
                
                cmd.Parameters.AddWithValue("@Offset", (currentPage - 1) * pageSize);
                cmd.Parameters.AddWithValue("@PageSize", pageSize);
                
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                rptStudents.DataSource = dt;
                rptStudents.DataBind();
                
                lblTotal.Text = totalCount.ToString();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "加载失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    // 批量设置校区
    protected void BtnBatchSetSchool_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(ddlBatchSchool.SelectedValue))
            {
                lblMessage.Text = "请选择要设置的校区";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            string connStr = GetConnectionString();
            if (connStr == null) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 构建更新条件
                System.Text.StringBuilder whereClause = new System.Text.StringBuilder();
                whereClause.Append(" WHERE SchoolId IS NULL ");
                
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                {
                    whereClause.Append(" AND Sgrade = @Sgrade ");
                }
                
                string sql = "UPDATE Students SET SchoolId = @SchoolId " + whereClause.ToString();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@SchoolId", int.Parse(ddlBatchSchool.SelectedValue));
                
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                    cmd.Parameters.AddWithValue("@Sgrade", int.Parse(ddlGrade.SelectedValue));
                
                int count = cmd.ExecuteNonQuery();
                
                lblMessage.Text = "成功设置 " + count + " 名学生的校区！";
                lblMessage.ForeColor = System.Drawing.Color.Green;
                
                LoadGrades();
                LoadUnassignedStudents();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "批量设置失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.Red;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ua-page {
        max-width: 100%;
        padding: 28px 32px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }
    
    .ua-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
    }
    
    .ua-header-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #f59e0b, #f97316);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 12px rgba(245, 158, 11, 0.25);
        flex-shrink: 0;
    }
    
    .ua-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .ua-header-text h1 {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 2px;
    }
    
    .ua-header-text p {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
    }
    
    .ua-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        overflow: hidden;
        margin-bottom: 20px;
    }
    
    .ua-card-header {
        padding: 16px 22px;
        background: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .ua-card-title {
        font-size: 15px;
        font-weight: 600;
        color: #1e293b;
    }
    
    .ua-card-body {
        padding: 20px 22px;
    }
    
    .ua-filter-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
        margin-bottom: 16px;
    }
    
    .ua-form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    
    .ua-label {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
    }
    
    .ua-select, .ua-input {
        padding: 10px 14px;
        border: 1.5px solid #e2e8f0;
        border-radius: 8px;
        font-size: 13px;
        color: #334155;
        background: #fff;
        transition: all 0.2s;
    }
    
    .ua-select:focus, .ua-input:focus {
        outline: none;
        border-color: #f59e0b;
        box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
    }
    
    .ua-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        height: 38px;
        padding: 0 20px;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
    }
    
    .ua-btn-primary {
        background: linear-gradient(135deg, #f59e0b, #f97316);
        color: #fff;
        box-shadow: 0 2px 6px rgba(245, 158, 11, 0.3);
    }
    
    .ua-btn-primary:hover {
        box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4);
        transform: translateY(-1px);
    }
    
    .ua-btn-success {
        background: linear-gradient(135deg, #10b981, #059669);
        color: #fff;
        box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
    }
    
    .ua-btn-success:hover {
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
        transform: translateY(-1px);
    }
    
    .ua-table-wrap {
        overflow-x: auto;
    }
    
    .ua-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }
    
    .ua-table thead {
        background: #f8fafc;
    }
    
    .ua-table th {
        padding: 12px 14px;
        text-align: left;
        font-weight: 600;
        color: #64748b;
        border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }
    
    .ua-table td {
        padding: 12px 14px;
        color: #334155;
        border-bottom: 1px solid #f1f5f9;
        white-space: nowrap;
    }
    
    .ua-table tbody tr:hover {
        background: #fffbeb;
    }
    
    .ua-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
        background: #fef3c7;
        color: #92400e;
    }
    
    .ua-pagination {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 16px 22px;
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        font-size: 13px;
    }
    
    .ua-pagination-info {
        color: #64748b;
    }
    
    .ua-pagination-btns {
        display: flex;
        gap: 6px;
    }
    
    .ua-pagination-btns a {
        padding: 6px 12px;
        border-radius: 6px;
        text-decoration: none;
        color: #475569;
        background: #fff;
        border: 1px solid #e2e8f0;
        transition: all 0.2s;
    }
    
    .ua-pagination-btns a:hover {
        background: #fffbeb;
        color: #92400e;
        border-color: #fde68a;
    }
    
    .ua-pagination-btns a.active {
        background: #f59e0b;
        color: #fff;
        border-color: #f59e0b;
    }
    
    .ua-message {
        margin-top: 16px;
        padding: 12px 16px;
        border-radius: 8px;
        font-size: 13px;
    }
    
    .ua-stats {
        display: flex;
        gap: 12px;
        margin-bottom: 16px;
    }
    
    .ua-stat {
        flex: 1;
        padding: 16px;
        background: linear-gradient(135deg, #fffbeb, #fef3c7);
        border: 1px solid #fde68a;
        border-radius: 10px;
        text-align: center;
    }
    
    .ua-stat-value {
        font-size: 24px;
        font-weight: 700;
        color: #92400e;
        margin-bottom: 4px;
    }
    
    .ua-stat-label {
        font-size: 12px;
        color: #78350f;
    }
    
    .ua-alert {
        padding: 14px 18px;
        border-radius: 10px;
        margin-bottom: 16px;
        display: flex;
        align-items: flex-start;
        gap: 12px;
        font-size: 13px;
        line-height: 1.6;
        background: #fffbeb;
        border: 1px solid #fde68a;
        color: #92400e;
    }
    
    .ua-alert-icon {
        font-size: 18px;
        flex-shrink: 0;
    }
</style>

<div class="ua-page">
    <!-- 页面标题 -->
    <div class="ua-header">
        <div class="ua-header-icon">
            <svg viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/>
                <line x1="15" y1="9" x2="9" y2="15"/>
                <line x1="9" y1="9" x2="15" y2="15"/>
            </svg>
        </div>
        <div class="ua-header-text">
            <h1>未分配学生</h1>
            <p>显示尚未分配校区的学生，可批量设置校区</p>
        </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="ua-stats">
        <div class="ua-stat">
            <div class="ua-stat-value"><asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></div>
            <div class="ua-stat-label">未分配学生数</div>
        </div>
    </div>
    
    <!-- 筛选卡片 -->
    <div class="ua-card">
        <div class="ua-card-header">
            <span class="ua-card-title">筛选条件</span>
        </div>
        <div class="ua-card-body">
            <div class="ua-filter-grid">
                <div class="ua-form-group">
                    <label class="ua-label">年级</label>
                    <asp:DropDownList ID="ddlGrade" runat="server" CssClass="ua-select"></asp:DropDownList>
                </div>
                <div class="ua-form-group">
                    <label class="ua-label">关键词</label>
                    <asp:TextBox ID="txtKeyword" runat="server" CssClass="ua-input" 
                                 placeholder="学号或姓名"></asp:TextBox>
                </div>
                <div class="ua-form-group" style="justify-content: flex-end;">
                    <label class="ua-label" style="opacity:0;">操作</label>
                    <asp:Button ID="btnSearch" runat="server" Text="搜索" 
                                CssClass="ua-btn ua-btn-primary" OnClick="BtnSearch_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- 批量操作卡片 -->
    <div class="ua-card">
        <div class="ua-card-header">
            <span class="ua-card-title">批量操作</span>
        </div>
        <div class="ua-card-body">
            <div class="ua-alert">
                <span class="ua-alert-icon">⚠️</span>
                <div>
                    批量设置将根据当前筛选条件（年级）为所有未分配的学生设置校区。
                    如果未选择年级，将为所有未分配学生设置校区。
                </div>
            </div>
            <div class="ua-filter-grid">
                <div class="ua-form-group">
                    <label class="ua-label">设置校区</label>
                    <asp:DropDownList ID="ddlBatchSchool" runat="server" CssClass="ua-select"></asp:DropDownList>
                </div>
                <div class="ua-form-group" style="justify-content: flex-end;">
                    <label class="ua-label" style="opacity:0;">操作</label>
                    <asp:Button ID="btnBatchSetSchool" runat="server" Text="批量设置当前筛选结果" 
                                CssClass="ua-btn ua-btn-success" OnClick="BtnBatchSetSchool_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- 学生列表卡片 -->
    <div class="ua-card">
        <div class="ua-card-header">
            <span class="ua-card-title">学生列表</span>
        </div>
        <div class="ua-table-wrap">
            <table class="ua-table">
                <thead>
                    <tr>
                        <th>学号</th>
                        <th>姓名</th>
                        <th>年级</th>
                        <th>班级</th>
                        <th>性别</th>
                        <th>校区状态</th>
                        <th>联系电话</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptStudents" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("Snum") %></td>
                                <td><%# Eval("Sname") %></td>
                                <td><%# Eval("Sgrade") %>年级</td>
                                <td><%# Eval("Sclass") %>班</td>
                                <td><%# Eval("Sex") %></td>
                                <td>
                                    <span class="ua-badge">未分配</span>
                                </td>
                                <td><%# Eval("Sphone") == DBNull.Value ? "-" : Eval("Sphone") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
        <div class="ua-pagination">
            <div class="ua-pagination-info">
                第 <%= currentPage %> 页，共 <%= totalPages %> 页
            </div>
            <div class="ua-pagination-btns">
                <% if (currentPage > 1) { %>
                    <a href="?page=1">首页</a>
                    <a href="?page=<%= currentPage - 1 %>">上一页</a>
                <% } %>
                
                <% for (int i = Math.Max(1, currentPage - 2); i <= Math.Min(totalPages, currentPage + 2); i++) { %>
                    <a href="?page=<%= i %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                    <a href="?page=<%= currentPage + 1 %>">下一页</a>
                    <a href="?page=<%= totalPages %>">尾页</a>
                <% } %>
            </div>
        </div>
    </div>
    
    <asp:Label ID="lblMessage" runat="server" CssClass="ua-message"></asp:Label>
</div>
</asp:Content>
