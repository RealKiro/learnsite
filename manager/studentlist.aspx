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
            LoadStudents();
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
                
                // 检查 School 表是否存在
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                ddlSchool.Items.Clear();
                ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem("全部校区", ""));
                
                ddlBatchSchool.Items.Clear();
                
                if (tableExists > 0)
                {
                    string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    SqlDataReader reader = cmd.ExecuteReader();
                    
                    while (reader.Read())
                    {
                        string schoolId = reader["SchoolId"].ToString();
                        string schoolName = reader["SchoolName"].ToString();
                        
                        // 添加到筛选下拉框
                        ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem(schoolName, schoolId));
                        
                        // 添加到批量操作下拉框
                        ddlBatchSchool.Items.Add(new System.Web.UI.WebControls.ListItem(schoolName, schoolId));
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
                
                string sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade IS NOT NULL ORDER BY Sgrade";
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
        LoadStudents();
    }
    
    // 加载学生列表
    private void LoadStudents()
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
                whereClause.Append(" WHERE 1=1 ");
                
                // 校区筛选
                if (!string.IsNullOrEmpty(ddlSchool.SelectedValue))
                {
                    whereClause.Append(" AND st.SchoolId = @SchoolId ");
                }
                
                // 年级筛选
                if (!string.IsNullOrEmpty(ddlGrade.SelectedValue))
                {
                    whereClause.Append(" AND st.Sgrade = @Sgrade ");
                }
                
                // 关键词搜索
                if (!string.IsNullOrEmpty(txtKeyword.Text.Trim()))
                {
                    whereClause.Append(" AND (st.Snum LIKE @Keyword OR st.Sname LIKE @Keyword) ");
                }
                
                // 获取总数
                string countSql = "SELECT COUNT(*) FROM Students st " + whereClause.ToString();
                SqlCommand cmdCount = new SqlCommand(countSql, conn);
                
                if (!string.IsNullOrEmpty(ddlSchool.SelectedValue))
                    cmdCount.Parameters.AddWithValue("@SchoolId", int.Parse(ddlSchool.SelectedValue));
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
                    SELECT st.Sid, st.Snum, st.Syear, st.Sgrade, st.Sclass, st.Sname, 
                           st.Sex, st.Sphone, st.SchoolId, s.SchoolName
                    FROM Students st
                    LEFT JOIN School s ON st.SchoolId = s.SchoolId
                    " + whereClause.ToString() + @"
                    ORDER BY st.Sgrade, st.Sclass, st.Snum
                    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                
                if (!string.IsNullOrEmpty(ddlSchool.SelectedValue))
                    cmd.Parameters.AddWithValue("@SchoolId", int.Parse(ddlSchool.SelectedValue));
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
    
    // 删除学生
    protected void BtnDelete_Click(object sender, EventArgs e)
    {
        try
        {
            int sid = int.Parse(hidSid.Value);
            
            string connStr = GetConnectionString();
            if (connStr == null) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string sql = "DELETE FROM Students WHERE Sid = @Sid";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Sid", sid);
                cmd.ExecuteNonQuery();
                
                lblMessage.Text = "删除成功！";
                lblMessage.ForeColor = System.Drawing.Color.Green;
                
                LoadStudents();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "删除失败：" + ex.Message;
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
                whereClause.Append(" WHERE 1=1 ");
                
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
                
                LoadStudents();
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
    .sl-page {
        max-width: 100%;
        padding: 28px 32px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }
    
    .sl-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
    }
    
    .sl-header-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #0ea5e9, #38bdf8);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 12px rgba(14, 165, 233, 0.25);
        flex-shrink: 0;
    }
    
    .sl-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .sl-header-text h1 {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 2px;
    }
    
    .sl-header-text p {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
    }
    
    .sl-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        overflow: hidden;
        margin-bottom: 20px;
    }
    
    .sl-card-header {
        padding: 16px 22px;
        background: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .sl-card-title {
        font-size: 15px;
        font-weight: 600;
        color: #1e293b;
    }
    
    .sl-card-body {
        padding: 20px 22px;
    }
    
    .sl-filter-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
        margin-bottom: 16px;
    }
    
    .sl-form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    
    .sl-label {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
    }
    
    .sl-select, .sl-input {
        padding: 10px 14px;
        border: 1.5px solid #e2e8f0;
        border-radius: 8px;
        font-size: 13px;
        color: #334155;
        background: #fff;
        transition: all 0.2s;
    }
    
    .sl-select:focus, .sl-input:focus {
        outline: none;
        border-color: #0ea5e9;
        box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
    }
    
    .sl-btn {
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
    
    .sl-btn-primary {
        background: linear-gradient(135deg, #0ea5e9, #38bdf8);
        color: #fff;
        box-shadow: 0 2px 6px rgba(14, 165, 233, 0.3);
    }
    
    .sl-btn-primary:hover {
        box-shadow: 0 4px 12px rgba(14, 165, 233, 0.4);
        transform: translateY(-1px);
    }
    
    .sl-btn-success {
        background: linear-gradient(135deg, #10b981, #059669);
        color: #fff;
        box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
    }
    
    .sl-btn-success:hover {
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
        transform: translateY(-1px);
    }
    
    .sl-btn-danger {
        background: #ef4444;
        color: #fff;
        padding: 6px 12px;
        height: auto;
        font-size: 12px;
    }
    
    .sl-btn-danger:hover {
        background: #dc2626;
    }
    
    .sl-table-wrap {
        overflow-x: auto;
    }
    
    .sl-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }
    
    .sl-table thead {
        background: #f8fafc;
    }
    
    .sl-table th {
        padding: 12px 14px;
        text-align: left;
        font-weight: 600;
        color: #64748b;
        border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }
    
    .sl-table td {
        padding: 12px 14px;
        color: #334155;
        border-bottom: 1px solid #f1f5f9;
        white-space: nowrap;
    }
    
    .sl-table tbody tr:hover {
        background: #f8fafc;
    }
    
    .sl-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .sl-badge-school {
        background: #dbeafe;
        color: #1e40af;
    }
    
    .sl-badge-none {
        background: #f1f5f9;
        color: #64748b;
    }
    
    .sl-pagination {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 16px 22px;
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        font-size: 13px;
    }
    
    .sl-pagination-info {
        color: #64748b;
    }
    
    .sl-pagination-btns {
        display: flex;
        gap: 6px;
    }
    
    .sl-pagination-btns a {
        padding: 6px 12px;
        border-radius: 6px;
        text-decoration: none;
        color: #475569;
        background: #fff;
        border: 1px solid #e2e8f0;
        transition: all 0.2s;
    }
    
    .sl-pagination-btns a:hover {
        background: #e0f2fe;
        color: #0369a1;
        border-color: #bae6fd;
    }
    
    .sl-pagination-btns a.active {
        background: #0ea5e9;
        color: #fff;
        border-color: #0ea5e9;
    }
    
    .sl-message {
        margin-top: 16px;
        padding: 12px 16px;
        border-radius: 8px;
        font-size: 13px;
    }
    
    .sl-stats {
        display: flex;
        gap: 12px;
        margin-bottom: 16px;
    }
    
    .sl-stat {
        flex: 1;
        padding: 16px;
        background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
        border: 1px solid #bae6fd;
        border-radius: 10px;
        text-align: center;
    }
    
    .sl-stat-value {
        font-size: 24px;
        font-weight: 700;
        color: #0369a1;
        margin-bottom: 4px;
    }
    
    .sl-stat-label {
        font-size: 12px;
        color: #64748b;
    }
</style>

<div class="sl-page">
    <!-- 页面标题 -->
    <div class="sl-header">
        <div class="sl-header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
        </div>
        <div class="sl-header-text">
            <h1>学生管理</h1>
            <p>按校区查看和管理学生信息</p>
        </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="sl-stats">
        <div class="sl-stat">
            <div class="sl-stat-value"><asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></div>
            <div class="sl-stat-label">学生总数</div>
        </div>
    </div>
    
    <!-- 筛选卡片 -->
    <div class="sl-card">
        <div class="sl-card-header">
            <span class="sl-card-title">筛选条件</span>
        </div>
        <div class="sl-card-body">
            <div class="sl-filter-grid">
                <div class="sl-form-group">
                    <label class="sl-label">校区</label>
                    <asp:DropDownList ID="ddlSchool" runat="server" CssClass="sl-select"></asp:DropDownList>
                </div>
                <div class="sl-form-group">
                    <label class="sl-label">年级</label>
                    <asp:DropDownList ID="ddlGrade" runat="server" CssClass="sl-select"></asp:DropDownList>
                </div>
                <div class="sl-form-group">
                    <label class="sl-label">关键词</label>
                    <asp:TextBox ID="txtKeyword" runat="server" CssClass="sl-input" 
                                 placeholder="学号或姓名"></asp:TextBox>
                </div>
                <div class="sl-form-group" style="justify-content: flex-end;">
                    <label class="sl-label" style="opacity:0;">操作</label>
                    <asp:Button ID="btnSearch" runat="server" Text="搜索" 
                                CssClass="sl-btn sl-btn-primary" OnClick="BtnSearch_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- 批量操作卡片 -->
    <div class="sl-card">
        <div class="sl-card-header">
            <span class="sl-card-title">批量操作</span>
        </div>
        <div class="sl-card-body">
            <div class="sl-filter-grid">
                <div class="sl-form-group">
                    <label class="sl-label">设置校区</label>
                    <asp:DropDownList ID="ddlBatchSchool" runat="server" CssClass="sl-select"></asp:DropDownList>
                </div>
                <div class="sl-form-group" style="justify-content: flex-end;">
                    <label class="sl-label" style="opacity:0;">操作</label>
                    <asp:Button ID="btnBatchSetSchool" runat="server" Text="批量设置当前筛选结果" 
                                CssClass="sl-btn sl-btn-success" OnClick="BtnBatchSetSchool_Click" />
                </div>
            </div>
            <div style="font-size:12px;color:#64748b;margin-top:8px;">
                提示：将根据当前筛选条件（年级）批量设置学生的校区
            </div>
        </div>
    </div>
    
    <!-- 学生列表卡片 -->
    <div class="sl-card">
        <div class="sl-card-header">
            <span class="sl-card-title">学生列表</span>
        </div>
        <div class="sl-table-wrap">
            <table class="sl-table">
                <thead>
                    <tr>
                        <th>学号</th>
                        <th>姓名</th>
                        <th>年级</th>
                        <th>班级</th>
                        <th>性别</th>
                        <th>校区</th>
                        <th>联系电话</th>
                        <th>操作</th>
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
                                    <%# Eval("SchoolName") == DBNull.Value || string.IsNullOrEmpty(Eval("SchoolName").ToString()) 
                                        ? "<span class='sl-badge sl-badge-none'>未设置</span>" 
                                        : "<span class='sl-badge sl-badge-school'>" + Eval("SchoolName") + "</span>" %>
                                </td>
                                <td><%# Eval("Sphone") == DBNull.Value ? "-" : Eval("Sphone") %></td>
                                <td>
                                    <button type="button" class="sl-btn sl-btn-danger" 
                                            onclick="deleteStudent(<%# Eval("Sid") %>, '<%# Eval("Sname") %>')">
                                        删除
                                    </button>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
        <div class="sl-pagination">
            <div class="sl-pagination-info">
                第 <%= currentPage %> 页，共 <%= totalPages %> 页
            </div>
            <div class="sl-pagination-btns">
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
    
    <asp:Label ID="lblMessage" runat="server" CssClass="sl-message"></asp:Label>
    
    <asp:HiddenField ID="hidSid" runat="server" />
    <asp:Button ID="btnDelete" runat="server" OnClick="BtnDelete_Click" style="display:none;" />
</div>

<script type="text/javascript">
    function deleteStudent(sid, sname) {
        if (confirm('确定要删除学生"' + sname + '"吗？\n\n此操作不可恢复！')) {
            document.getElementById('<%= hidSid.ClientID %>').value = sid;
            document.getElementById('<%= btnDelete.ClientID %>').click();
        }
    }
</script>
</asp:Content>
