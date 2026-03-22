<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            CheckAndCreateSchoolTable();
            LoadSchools();
            
            // 检查是否是编辑模式
            string editId = Request.QueryString["edit"];
            if (!string.IsNullOrEmpty(editId))
            {
                LoadSchoolForEdit(int.Parse(editId));
            }
        }
    }
    
    // 检查并创建学校表
    private void CheckAndCreateSchoolTable()
    {
        try
        {
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null) return;
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查 School 表是否存在
                string checkTableSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_NAME = 'School'";
                
                SqlCommand cmdCheck = new SqlCommand(checkTableSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                if (tableExists == 0)
                {
                    // 创建 School 表
                    string createTableSql = @"
                        CREATE TABLE School (
                            SchoolId INT PRIMARY KEY IDENTITY(1,1),
                            SchoolName NVARCHAR(100) NOT NULL,
                            SchoolCode NVARCHAR(50),
                            SchoolAddress NVARCHAR(200),
                            SchoolPhone NVARCHAR(50),
                            SchoolNote NVARCHAR(500),
                            IsActive BIT DEFAULT 1,
                            CreateTime DATETIME DEFAULT GETDATE()
                        )";
                    
                    SqlCommand cmdCreate = new SqlCommand(createTableSql, conn);
                    cmdCreate.ExecuteNonQuery();
                }
                
                // 检查 Students 表是否有 SchoolId 字段
                string checkFieldSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Students' 
                    AND COLUMN_NAME = 'SchoolId'";
                
                SqlCommand cmdCheckField = new SqlCommand(checkFieldSql, conn);
                int fieldExists = (int)cmdCheckField.ExecuteScalar();
                
                if (fieldExists == 0)
                {
                    // 添加 SchoolId 字段到 Students 表
                    string addFieldSql = "ALTER TABLE Students ADD SchoolId INT NULL";
                    SqlCommand cmdAddField = new SqlCommand(addFieldSql, conn);
                    cmdAddField.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }
    
    // 加载学校列表
    private void LoadSchools()
    {
        try
        {
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null) return;
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string sql = @"
                    SELECT SchoolId, SchoolName, SchoolCode, SchoolAddress, 
                           SchoolPhone, SchoolNote, IsActive, CreateTime
                    FROM School 
                    ORDER BY SchoolId";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                rptSchools.DataSource = dt;
                rptSchools.DataBind();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "加载失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    // 添加学校
    protected void BtnAdd_Click(object sender, EventArgs e)
    {
        try
        {
            string schoolName = txtSchoolName.Text.Trim();
            
            if (string.IsNullOrEmpty(schoolName))
            {
                lblMessage.Text = "学校名称不能为空";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null) return;
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查是否是编辑模式
                if (!string.IsNullOrEmpty(hidEditId.Value))
                {
                    // 更新学校
                    string sql = @"
                        UPDATE School 
                        SET SchoolName=@SchoolName, SchoolCode=@SchoolCode, SchoolAddress=@SchoolAddress, 
                            SchoolPhone=@SchoolPhone, SchoolNote=@SchoolNote, IsActive=@IsActive
                        WHERE SchoolId=@SchoolId";
                    
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@SchoolId", int.Parse(hidEditId.Value));
                    cmd.Parameters.AddWithValue("@SchoolName", schoolName);
                    cmd.Parameters.AddWithValue("@SchoolCode", string.IsNullOrEmpty(txtSchoolCode.Text.Trim()) ? (object)DBNull.Value : txtSchoolCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolAddress", string.IsNullOrEmpty(txtSchoolAddress.Text.Trim()) ? (object)DBNull.Value : txtSchoolAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolPhone", string.IsNullOrEmpty(txtSchoolPhone.Text.Trim()) ? (object)DBNull.Value : txtSchoolPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolNote", string.IsNullOrEmpty(txtSchoolNote.Text.Trim()) ? (object)DBNull.Value : txtSchoolNote.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    
                    cmd.ExecuteNonQuery();
                    
                    lblMessage.Text = "更新成功！";
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    
                    // 清空编辑ID
                    hidEditId.Value = "";
                    btnAdd.Text = "添加学校";
                }
                else
                {
                    // 添加新学校
                    string sql = @"
                        INSERT INTO School (SchoolName, SchoolCode, SchoolAddress, SchoolPhone, SchoolNote, IsActive)
                        VALUES (@SchoolName, @SchoolCode, @SchoolAddress, @SchoolPhone, @SchoolNote, @IsActive)";
                    
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@SchoolName", schoolName);
                    cmd.Parameters.AddWithValue("@SchoolCode", string.IsNullOrEmpty(txtSchoolCode.Text.Trim()) ? (object)DBNull.Value : txtSchoolCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolAddress", string.IsNullOrEmpty(txtSchoolAddress.Text.Trim()) ? (object)DBNull.Value : txtSchoolAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolPhone", string.IsNullOrEmpty(txtSchoolPhone.Text.Trim()) ? (object)DBNull.Value : txtSchoolPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolNote", string.IsNullOrEmpty(txtSchoolNote.Text.Trim()) ? (object)DBNull.Value : txtSchoolNote.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    
                    cmd.ExecuteNonQuery();
                    
                    lblMessage.Text = "添加成功！";
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                }
                
                // 清空表单
                txtSchoolName.Text = "";
                txtSchoolCode.Text = "";
                txtSchoolAddress.Text = "";
                txtSchoolPhone.Text = "";
                txtSchoolNote.Text = "";
                chkIsActive.Checked = true;
                
                LoadSchools();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "操作失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    // 加载学校信息用于编辑
    private void LoadSchoolForEdit(int schoolId)
    {
        try
        {
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null) return;
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string sql = "SELECT * FROM School WHERE SchoolId = @SchoolId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@SchoolId", schoolId);
                
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    hidEditId.Value = schoolId.ToString();
                    txtSchoolName.Text = reader["SchoolName"].ToString();
                    txtSchoolCode.Text = reader["SchoolCode"] != DBNull.Value ? reader["SchoolCode"].ToString() : "";
                    txtSchoolAddress.Text = reader["SchoolAddress"] != DBNull.Value ? reader["SchoolAddress"].ToString() : "";
                    txtSchoolPhone.Text = reader["SchoolPhone"] != DBNull.Value ? reader["SchoolPhone"].ToString() : "";
                    txtSchoolNote.Text = reader["SchoolNote"] != DBNull.Value ? reader["SchoolNote"].ToString() : "";
                    chkIsActive.Checked = Convert.ToBoolean(reader["IsActive"]);
                    
                    btnAdd.Text = "保存修改";
                }
                reader.Close();
            }
        }
        catch { }
    }
    
    // 批量删除学校
    protected void BtnBatchDelete_Click(object sender, EventArgs e)
    {
        try
        {
            string ids = hidBatchIds.Value;
            if (string.IsNullOrEmpty(ids))
            {
                lblMessage.Text = "请选择要删除的学校";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null) return;
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string[] idArray = ids.Split(',');
                int successCount = 0;
                int failCount = 0;
                
                foreach (string id in idArray)
                {
                    if (string.IsNullOrEmpty(id)) continue;
                    
                    int schoolId = int.Parse(id);
                    
                    // 检查是否有学生关联
                    string checkSql = "SELECT COUNT(*) FROM Students WHERE SchoolId = @SchoolId";
                    SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                    cmdCheck.Parameters.AddWithValue("@SchoolId", schoolId);
                    int studentCount = (int)cmdCheck.ExecuteScalar();
                    
                    if (studentCount > 0)
                    {
                        failCount++;
                        continue;
                    }
                    
                    // 删除学校
                    string sql = "DELETE FROM School WHERE SchoolId = @SchoolId";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@SchoolId", schoolId);
                    cmd.ExecuteNonQuery();
                    
                    successCount++;
                }
                
                if (successCount > 0)
                {
                    lblMessage.Text = "成功删除 " + successCount + " 个学校";
                    if (failCount > 0)
                    {
                        lblMessage.Text += "，" + failCount + " 个学校因有学生关联无法删除";
                    }
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                }
                else
                {
                    lblMessage.Text = "删除失败：所有选中的学校都有学生关联";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                }
                
                LoadSchools();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "批量删除失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    // 删除学校
    protected void BtnDelete_Click(object sender, EventArgs e)
    {
        try
        {
            int schoolId = int.Parse(hidSchoolId.Value);
            
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null) return;
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查是否有学生关联
                string checkSql = "SELECT COUNT(*) FROM Students WHERE SchoolId = @SchoolId";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                cmdCheck.Parameters.AddWithValue("@SchoolId", schoolId);
                int studentCount = (int)cmdCheck.ExecuteScalar();
                
                if (studentCount > 0)
                {
                    lblMessage.Text = "该学校下还有 " + studentCount + " 名学生，无法删除";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    return;
                }
                
                // 删除学校
                string sql = "DELETE FROM School WHERE SchoolId = @SchoolId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@SchoolId", schoolId);
                cmd.ExecuteNonQuery();
                
                lblMessage.Text = "删除成功！";
                lblMessage.ForeColor = System.Drawing.Color.Green;
                
                LoadSchools();
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "删除失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.Red;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .school-page {
        max-width: 1400px;
        margin: 0 auto;
        padding: 28px 32px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }
    
    .school-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 32px;
    }
    
    .school-header-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #8b5cf6, #6366f1);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 12px rgba(139, 92, 246, 0.25);
        flex-shrink: 0;
    }
    
    .school-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .school-header-text h1 {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 2px;
    }
    
    .school-header-text p {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
    }
    
    .school-grid {
        display: grid;
        grid-template-columns: 1fr 2fr;
        gap: 24px;
        margin-bottom: 24px;
    }
    
    @media (max-width: 1024px) {
        .school-grid {
            grid-template-columns: 1fr;
        }
    }
    
    .school-card {
        background: #fff;
        border-radius: 16px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        overflow: hidden;
    }
    
    .school-card-header {
        padding: 20px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .school-card-header-icon {
        width: 36px;
        height: 36px;
        background: linear-gradient(135deg, #8b5cf6, #6366f1);
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .school-card-header-icon svg {
        width: 20px;
        height: 20px;
        stroke: #fff;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .school-card-title {
        font-size: 16px;
        font-weight: 600;
        color: #1e293b;
    }
    
    .school-card-body {
        padding: 24px;
    }
    
    .school-form-group {
        margin-bottom: 20px;
    }
    
    .school-form-group:last-child {
        margin-bottom: 0;
    }
    
    .school-label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 8px;
    }
    
    .school-input {
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 14px;
        font-family: inherit;
        color: #1e293b;
        transition: all 0.2s;
        background: #fff;
    }
    
    .school-input:focus {
        outline: none;
        border-color: #8b5cf6;
        box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
    }
    
    .school-textarea {
        min-height: 80px;
        resize: vertical;
    }
    
    .school-checkbox-wrapper {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 14px 18px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        cursor: pointer;
        transition: all 0.2s;
    }
    
    .school-checkbox-wrapper:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
    }
    
    .school-checkbox-wrapper input[type="checkbox"] {
        width: 20px;
        height: 20px;
        cursor: pointer;
        accent-color: #8b5cf6;
    }
    
    .school-checkbox-label {
        font-size: 14px;
        color: #334155;
        font-weight: 500;
        cursor: pointer;
        user-select: none;
    }
    
    .school-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        height: 44px;
        padding: 0 32px;
        border: none;
        border-radius: 10px;
        font-size: 14px;
        font-family: inherit;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        width: 100%;
    }
    
    .school-btn-primary {
        background: linear-gradient(135deg, #8b5cf6, #6366f1);
        color: #fff;
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
    }
    
    .school-btn-primary:hover {
        box-shadow: 0 4px 16px rgba(139, 92, 246, 0.4);
        transform: translateY(-1px);
    }
    
    .school-message {
        margin-top: 16px;
        padding: 14px 18px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 500;
    }
    
    .school-table {
        width: 100%;
        border-collapse: collapse;
    }
    
    .school-table thead {
        background: #f8fafc;
    }
    
    .school-table th {
        padding: 14px 16px;
        text-align: left;
        font-size: 13px;
        font-weight: 600;
        color: #64748b;
        border-bottom: 2px solid #e2e8f0;
    }
    
    .school-table td {
        padding: 16px;
        font-size: 14px;
        color: #334155;
        border-bottom: 1px solid #f1f5f9;
    }
    
    .school-table tbody tr:hover {
        background: #f8fafc;
    }
    
    .school-badge {
        display: inline-flex;
        align-items: center;
        padding: 4px 12px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .school-badge-active {
        background: #dcfce7;
        color: #166534;
    }
    
    .school-badge-inactive {
        background: #fee2e2;
        color: #991b1b;
    }
    
    .school-btn-group {
        display: flex;
        gap: 8px;
    }
    
    .school-btn-sm {
        padding: 6px 14px;
        height: auto;
        font-size: 13px;
        border-radius: 6px;
        width: auto;
    }
    
    .school-btn-danger {
        background: #ef4444;
        color: #fff;
    }
    
    .school-btn-danger:hover {
        background: #dc2626;
    }
    
    .school-alert {
        padding: 14px 18px;
        border-radius: 10px;
        margin-bottom: 20px;
        display: flex;
        align-items: flex-start;
        gap: 12px;
        font-size: 14px;
        line-height: 1.6;
        background: #eff6ff;
        border: 1px solid #bfdbfe;
        color: #1e40af;
    }
    
    .school-alert-icon {
        font-size: 18px;
        flex-shrink: 0;
    }
</style>

<div class="school-page">
    <!-- 页面标题 -->
    <div class="school-header">
        <div class="school-header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                <polyline points="9 22 9 12 15 12 15 22"/>
            </svg>
        </div>
        <div class="school-header-text">
            <h1>学校设置</h1>
            <p>管理学校/校区信息，学生将按校区分类显示</p>
        </div>
    </div>
    
    <div class="school-grid">
        <!-- 左侧：添加学校表单 -->
        <div class="school-card">
            <div class="school-card-header">
                <div class="school-card-header-icon">
                    <svg viewBox="0 0 24 24">
                        <line x1="12" y1="5" x2="12" y2="19"/>
                        <line x1="5" y1="12" x2="19" y2="12"/>
                    </svg>
                </div>
                <span class="school-card-title">添加学校/校区</span>
            </div>
            <div class="school-card-body">
                <div class="school-alert">
                    <span class="school-alert-icon">💡</span>
                    <div>
                        添加学校后，在学生导入时可以选择对应的校区，学生将按校区分类显示。
                    </div>
                </div>
                
                <div class="school-form-group">
                    <label class="school-label">学校名称 *</label>
                    <asp:TextBox ID="txtSchoolName" runat="server" CssClass="school-input" 
                                 placeholder="请输入学校名称"></asp:TextBox>
                </div>
                
                <div class="school-form-group">
                    <label class="school-label">学校代码</label>
                    <asp:TextBox ID="txtSchoolCode" runat="server" CssClass="school-input" 
                                 placeholder="请输入学校代码（可选）"></asp:TextBox>
                </div>
                
                <div class="school-form-group">
                    <label class="school-label">学校地址</label>
                    <asp:TextBox ID="txtSchoolAddress" runat="server" CssClass="school-input" 
                                 placeholder="请输入学校地址（可选）"></asp:TextBox>
                </div>
                
                <div class="school-form-group">
                    <label class="school-label">联系电话</label>
                    <asp:TextBox ID="txtSchoolPhone" runat="server" CssClass="school-input" 
                                 placeholder="请输入联系电话（可选）"></asp:TextBox>
                </div>
                
                <div class="school-form-group">
                    <label class="school-label">备注信息</label>
                    <asp:TextBox ID="txtSchoolNote" runat="server" CssClass="school-input school-textarea" 
                                 TextMode="MultiLine" placeholder="请输入备注信息（可选）"></asp:TextBox>
                </div>
                
                <div class="school-form-group">
                    <label class="school-label">状态</label>
                    <div class="school-checkbox-wrapper">
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                        <label class="school-checkbox-label" for="<%= chkIsActive.ClientID %>">
                            启用（学生可选择此校区）
                        </label>
                    </div>
                </div>
                
                <asp:Button ID="btnAdd" runat="server" Text="添加学校" 
                            CssClass="school-btn school-btn-primary" OnClick="BtnAdd_Click" />
                
                <asp:Label ID="lblMessage" runat="server" CssClass="school-message"></asp:Label>
            </div>
        </div>
        
        <!-- 右侧：学校列表 -->
        <div class="school-card">
            <div class="school-card-header">
                <div class="school-card-header-icon">
                    <svg viewBox="0 0 24 24">
                        <line x1="8" y1="6" x2="21" y2="6"/>
                        <line x1="8" y1="12" x2="21" y2="12"/>
                        <line x1="8" y1="18" x2="21" y2="18"/>
                        <line x1="3" y1="6" x2="3.01" y2="6"/>
                        <line x1="3" y1="12" x2="3.01" y2="12"/>
                        <line x1="3" y1="18" x2="3.01" y2="18"/>
                    </svg>
                </div>
                <span class="school-card-title">学校列表</span>
                <div style="margin-left: auto;">
                    <button type="button" class="school-btn school-btn-sm school-btn-danger" 
                            onclick="batchDelete()" style="width: auto;">
                        批量删除
                    </button>
                </div>
            </div>
            <div class="school-card-body">
                <table class="school-table">
                    <thead>
                        <tr>
                            <th style="width: 40px;">
                                <input type="checkbox" id="chkSelectAll" onclick="toggleSelectAll(this)" 
                                       style="width: 18px; height: 18px; cursor: pointer; accent-color: #8b5cf6;" />
                            </th>
                            <th>学校名称</th>
                            <th>学校代码</th>
                            <th>地址</th>
                            <th>电话</th>
                            <th>状态</th>
                            <th style="width: 160px;">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptSchools" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <input type="checkbox" class="chk-school" value="<%# Eval("SchoolId") %>" 
                                               style="width: 18px; height: 18px; cursor: pointer; accent-color: #8b5cf6;" />
                                    </td>
                                    <td><%# Eval("SchoolName") %></td>
                                    <td><%# Eval("SchoolCode") == DBNull.Value ? "-" : Eval("SchoolCode") %></td>
                                    <td><%# Eval("SchoolAddress") == DBNull.Value ? "-" : Eval("SchoolAddress") %></td>
                                    <td><%# Eval("SchoolPhone") == DBNull.Value ? "-" : Eval("SchoolPhone") %></td>
                                    <td>
                                        <span class='school-badge <%# Convert.ToBoolean(Eval("IsActive")) ? "school-badge-active" : "school-badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "启用" : "禁用" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="school-btn-group">
                                            <button type="button" class="school-btn school-btn-sm" 
                                                    onclick="editSchool(<%# Eval("SchoolId") %>)"
                                                    style="background: #3b82f6; color: #fff;">
                                                编辑
                                            </button>
                                            <button type="button" class="school-btn school-btn-sm school-btn-danger" 
                                                    onclick="deleteSchool(<%# Eval("SchoolId") %>, '<%# Eval("SchoolName") %>')">
                                                删除
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <asp:HiddenField ID="hidSchoolId" runat="server" />
    <asp:HiddenField ID="hidEditId" runat="server" />
    <asp:HiddenField ID="hidBatchIds" runat="server" />
    <asp:Button ID="btnDelete" runat="server" OnClick="BtnDelete_Click" style="display:none;" />
    <asp:Button ID="btnBatchDelete" runat="server" OnClick="BtnBatchDelete_Click" style="display:none;" />
</div>

<script type="text/javascript">
    function deleteSchool(schoolId, schoolName) {
        if (confirm('确定要删除学校"' + schoolName + '"吗？\n\n注意：如果该学校下有学生，将无法删除。')) {
            document.getElementById('<%= hidSchoolId.ClientID %>').value = schoolId;
            document.getElementById('<%= btnDelete.ClientID %>').click();
        }
    }
    
    function editSchool(schoolId) {
        window.location.href = 'schoolsetting.aspx?edit=' + schoolId;
    }
    
    function toggleSelectAll(checkbox) {
        var checkboxes = document.getElementsByClassName('chk-school');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checkbox.checked;
        }
    }
    
    function batchDelete() {
        var checkboxes = document.getElementsByClassName('chk-school');
        var selectedIds = [];
        
        for (var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked) {
                selectedIds.push(checkboxes[i].value);
            }
        }
        
        if (selectedIds.length === 0) {
            alert('请选择要删除的学校');
            return;
        }
        
        if (confirm('确定要删除选中的 ' + selectedIds.length + ' 个学校吗？\n\n注意：有学生关联的学校将无法删除。')) {
            document.getElementById('<%= hidBatchIds.ClientID %>').value = selectedIds.join(',');
            document.getElementById('<%= btnBatchDelete.ClientID %>').click();
        }
    }
</script>
</asp:Content>
