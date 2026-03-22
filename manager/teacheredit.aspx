<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    // 页面加载时读取教师信息
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSchools();
            LoadTeacherInfo();
        }
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
                
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                ddlSchool.Items.Clear();
                ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem("不设置学校", ""));
                
                if (tableExists > 0)
                {
                    string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    SqlDataReader reader = cmd.ExecuteReader();
                    
                    while (reader.Read())
                    {
                        ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem(
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
    
    // 加载教师信息
    private void LoadTeacherInfo()
    {
        try
        {
            int hid = 0;
            if (Request.QueryString["hid"] != null)
            {
                int.TryParse(Request.QueryString["hid"], out hid);
            }
            
            if (hid > 0)
            {
                DataRow row = GetTeacherInfo(hid);
                if (row != null)
                {
                    Texthname.Text = row["Hname"].ToString();
                    Texthnick.Text = row["Hnick"] != DBNull.Value ? row["Hnick"].ToString() : "";
                    Texthpwd.Text = ""; // 密码不显示
                    Ckhpermiss.Checked = Convert.ToBoolean(row["Hpermiss"]);
                    Texthnote.Text = row["Hnote"] != DBNull.Value ? row["Hnote"].ToString() : "";
                    
                    // 加载邮箱（如果字段存在）
                    if (row.Table.Columns.Contains("Hemail"))
                    {
                        Texthemail.Text = row["Hemail"] != DBNull.Value ? row["Hemail"].ToString() : "";
                    }
                    
                    // 加载学校（如果字段存在）
                    if (row.Table.Columns.Contains("SchoolId") && row["SchoolId"] != DBNull.Value)
                    {
                        string schoolId = row["SchoolId"].ToString();
                        if (ddlSchool.Items.FindByValue(schoolId) != null)
                        {
                            ddlSchool.SelectedValue = schoolId;
                        }
                    }
                }
                // GetTeacherInfo 已经设置了错误消息，这里不需要再设置
            }
            else
            {
                Labelmsg.Text = "错误：无效的教师ID";
                Labelmsg.ForeColor = System.Drawing.Color.Red;
            }
        }
        catch (Exception ex)
        {
            Labelmsg.Text = "加载教师信息失败：" + ex.Message;
            Labelmsg.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    // 获取教师信息
    private DataRow GetTeacherInfo(int hid)
    {
        try
        {
            // 尝试多个连接字符串名称
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null)
            {
                Labelmsg.Text = "数据库配置错误：未找到连接字符串";
                Labelmsg.ForeColor = System.Drawing.Color.Red;
                return null;
            }
            
            string connStr = connStrConfig.ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查 Hemail 字段是否存在
                bool hasEmailField = CheckEmailFieldExists(conn);
                
                // 检查 SchoolId 字段是否存在
                bool hasSchoolField = CheckFieldExists(conn, "SchoolId");
                
                // 检查 Hdelete 字段是否存在
                bool hasDeleteField = CheckFieldExists(conn, "Hdelete");
                
                // 首先尝试查询不带删除过滤的记录，以确定记录是否存在
                string sqlCheck;
                if (hasEmailField && hasSchoolField)
                {
                    sqlCheck = "SELECT Hid, Hname, Hnick, Hpwd, Hpermiss, Hnote, Hemail, SchoolId" + 
                              (hasDeleteField ? ", Hdelete" : "") + " FROM Teacher WHERE Hid=@hid";
                }
                else if (hasEmailField)
                {
                    sqlCheck = "SELECT Hid, Hname, Hnick, Hpwd, Hpermiss, Hnote, Hemail" + 
                              (hasDeleteField ? ", Hdelete" : "") + " FROM Teacher WHERE Hid=@hid";
                }
                else if (hasSchoolField)
                {
                    sqlCheck = "SELECT Hid, Hname, Hnick, Hpwd, Hpermiss, Hnote, SchoolId" + 
                              (hasDeleteField ? ", Hdelete" : "") + " FROM Teacher WHERE Hid=@hid";
                }
                else
                {
                    sqlCheck = "SELECT Hid, Hname, Hnick, Hpwd, Hpermiss, Hnote" + 
                              (hasDeleteField ? ", Hdelete" : "") + " FROM Teacher WHERE Hid=@hid";
                }
                
                using (SqlCommand cmdCheck = new SqlCommand(sqlCheck, conn))
                {
                    cmdCheck.Parameters.AddWithValue("@hid", hid);
                    
                    using (SqlDataAdapter daCheck = new SqlDataAdapter(cmdCheck))
                    {
                        DataTable dtCheck = new DataTable();
                        daCheck.Fill(dtCheck);
                        
                        if (dtCheck.Rows.Count > 0)
                        {
                            DataRow row = dtCheck.Rows[0];
                            
                            // 检查是否被标记为删除
                            if (hasDeleteField && dtCheck.Columns.Contains("Hdelete"))
                            {
                                object deleteVal = row["Hdelete"];
                                if (deleteVal != DBNull.Value && Convert.ToBoolean(deleteVal))
                                {
                                    Labelmsg.Text = "该教师已被标记为删除，无法编辑。如需恢复，请在数据库中将 Hdelete 字段设置为 0。";
                                    Labelmsg.ForeColor = System.Drawing.Color.Orange;
                                    return null;
                                }
                            }
                            
                            // 记录存在且未删除，返回数据
                            return row;
                        }
                        else
                        {
                            // 记录不存在
                            Labelmsg.Text = "数据库中不存在 ID 为 " + hid + " 的教师记录";
                            Labelmsg.ForeColor = System.Drawing.Color.Red;
                            return null;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Labelmsg.Text = "数据库查询错误：" + ex.Message;
            Labelmsg.ForeColor = System.Drawing.Color.Red;
        }
        
        return null;
    }
    
    // 检查字段是否存在（通用方法）
    private bool CheckFieldExists(SqlConnection conn, string fieldName)
    {
        try
        {
            string checkSql = @"
                SELECT COUNT(*) 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = 'Teacher' 
                AND COLUMN_NAME = @fieldName";
            
            using (SqlCommand cmd = new SqlCommand(checkSql, conn))
            {
                cmd.Parameters.AddWithValue("@fieldName", fieldName);
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }
        catch
        {
            return false;
        }
    }
    
    // 检查 Hemail 字段是否存在
    private bool CheckEmailFieldExists(SqlConnection conn)
    {
        try
        {
            string checkSql = @"
                SELECT COUNT(*) 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = 'Teacher' 
                AND COLUMN_NAME = 'Hemail'";
            
            using (SqlCommand cmd = new SqlCommand(checkSql, conn))
            {
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }
        catch
        {
            return false;
        }
    }
    
    // 验证邮箱格式
    private bool IsValidEmail(string email)
    {
        if (string.IsNullOrEmpty(email))
        {
            return true; // 空邮箱也是有效的（可选字段）
        }
        
        try
        {
            System.Net.Mail.MailAddress addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch
        {
            return false;
        }
    }
    
    // 保存修改
    protected void Btnedit_Click(object sender, EventArgs e)
    {
        try
        {
            int hid = 0;
            if (Request.QueryString["hid"] != null)
            {
                hid = int.Parse(Request.QueryString["hid"]);
            }
            
            if (hid <= 0)
            {
                Labelmsg.Text = "错误：无效的教师ID";
                Labelmsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            // 验证必填字段
            if (string.IsNullOrEmpty(Texthname.Text.Trim()))
            {
                Labelmsg.Text = "错误：教师姓名不能为空";
                Labelmsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            // 验证邮箱格式
            string email = Texthemail.Text.Trim();
            if (!string.IsNullOrEmpty(email) && !IsValidEmail(email))
            {
                Labelmsg.Text = "错误：邮箱格式不正确";
                Labelmsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            // 更新教师信息
            bool success = UpdateTeacherInfo(
                hid,
                Texthname.Text.Trim(),
                Texthnick.Text.Trim(),
                Texthpwd.Text.Trim(),
                Ckhpermiss.Checked,
                Texthnote.Text.Trim(),
                email,
                ddlSchool.SelectedValue
            );
            
            if (success)
            {
                // 保存成功后直接跳转到教师列表页面
                Response.Redirect("teacher.aspx");
            }
            else
            {
                Labelmsg.Text = "修改失败，请重试";
                Labelmsg.ForeColor = System.Drawing.Color.Red;
            }
        }
        catch (Exception ex)
        {
            Labelmsg.Text = "修改失败：" + ex.Message;
            Labelmsg.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    // 更新教师信息
    private bool UpdateTeacherInfo(int hid, string hname, string hnick, string hpwd, bool hpermiss, string hnote, string hemail, string schoolId)
    {
        // 尝试多个连接字符串名称
        ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
        if (connStrConfig == null)
        {
            connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
        }
        
        if (connStrConfig == null)
        {
            return false;
        }
        
        string connStr = connStrConfig.ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            // 检查 Hemail 字段是否存在
            bool hasEmailField = CheckEmailFieldExists(conn);
            
            // 检查 SchoolId 字段是否存在
            bool hasSchoolField = CheckFieldExists(conn, "SchoolId");
            
            string sql;
            
            // 构建 SQL 语句
            System.Text.StringBuilder sqlBuilder = new System.Text.StringBuilder();
            sqlBuilder.Append("UPDATE Teacher SET Hname=@hname, Hnick=@hnick");
            
            if (!string.IsNullOrEmpty(hpwd))
            {
                sqlBuilder.Append(", Hpwd=@hpwd");
            }
            
            sqlBuilder.Append(", Hpermiss=@hpermiss, Hnote=@hnote");
            
            if (hasEmailField)
            {
                sqlBuilder.Append(", Hemail=@hemail");
            }
            
            if (hasSchoolField)
            {
                sqlBuilder.Append(", SchoolId=@schoolId");
            }
            
            sqlBuilder.Append(" WHERE Hid=@hid");
            sql = sqlBuilder.ToString();
            
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@hid", hid);
                cmd.Parameters.AddWithValue("@hname", hname);
                cmd.Parameters.AddWithValue("@hnick", string.IsNullOrEmpty(hnick) ? (object)DBNull.Value : hnick);
                cmd.Parameters.AddWithValue("@hpermiss", hpermiss);
                cmd.Parameters.AddWithValue("@hnote", string.IsNullOrEmpty(hnote) ? (object)DBNull.Value : hnote);
                
                if (!string.IsNullOrEmpty(hpwd))
                {
                    cmd.Parameters.AddWithValue("@hpwd", hpwd);
                }
                
                if (hasEmailField)
                {
                    cmd.Parameters.AddWithValue("@hemail", string.IsNullOrEmpty(hemail) ? (object)DBNull.Value : hemail);
                }
                
                if (hasSchoolField)
                {
                    if (string.IsNullOrEmpty(schoolId))
                    {
                        cmd.Parameters.AddWithValue("@schoolId", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@schoolId", int.Parse(schoolId));
                    }
                }
                
                int result = cmd.ExecuteNonQuery();
                return result > 0;
            }
        }
    }
    
    // 返回列表（已废弃，保留以防基类调用）
    protected void Btnreturn_Click(object sender, EventArgs e)
    {
        Response.Redirect("teacher.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .te-page {
        max-width: 1400px;
        margin: 0 auto;
        padding: 28px 32px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }
    
    .te-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 32px;
    }
    
    .te-header-icon {
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
    
    .te-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .te-header-text h1 {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 2px;
    }
    
    .te-header-text p {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
    }
    
    .te-card {
        background: #fff;
        border-radius: 16px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        overflow: hidden;
    }
    
    .te-card-body {
        padding: 32px;
    }
    
    .te-form-group {
        margin-bottom: 24px;
    }
    
    .te-form-group:last-child {
        margin-bottom: 0;
    }
    
    .te-label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .te-label-icon {
        width: 18px;
        height: 18px;
        stroke: #8b5cf6;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .te-input {
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
    
    .te-input:focus {
        outline: none;
        border-color: #8b5cf6;
        box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
    }
    
    .te-textarea {
        min-height: 100px;
        resize: vertical;
    }
    
    .te-checkbox-wrapper {
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
    
    .te-checkbox-wrapper:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
    }
    
    .te-checkbox-wrapper input[type="checkbox"] {
        width: 20px;
        height: 20px;
        cursor: pointer;
        accent-color: #8b5cf6;
    }
    
    .te-checkbox-label {
        font-size: 14px;
        color: #334155;
        font-weight: 500;
        cursor: pointer;
        user-select: none;
    }
    
    .te-hint {
        font-size: 12px;
        color: #94a3b8;
        margin-top: 6px;
        line-height: 1.5;
    }
    
    .te-btn-group {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-top: 32px;
        padding-top: 24px;
        border-top: 1px solid #f1f5f9;
    }
    
    .te-btn {
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
    }
    
    .te-btn-primary {
        background: linear-gradient(135deg, #8b5cf6, #6366f1);
        color: #fff;
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
    }
    
    .te-btn-primary:hover {
        box-shadow: 0 4px 16px rgba(139, 92, 246, 0.4);
        transform: translateY(-1px);
    }
    
    .te-btn-secondary {
        background: #f8fafc;
        color: #64748b;
        border: 1px solid #e2e8f0;
    }
    
    .te-btn-secondary:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
        color: #475569;
    }
    
    .te-btn svg {
        width: 18px;
        height: 18px;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        fill: none;
    }
    
    .te-message {
        margin-top: 20px;
        padding: 14px 18px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 500;
        display: none;
    }
    
    .te-message.show {
        display: block;
    }
    
    .te-message.success {
        background: #f0fdf4;
        border: 1px solid #bbf7d0;
        color: #166534;
    }
    
    .te-message.error {
        background: #fef2f2;
        border: 1px solid #fecaca;
        color: #991b1b;
    }
    
    .te-message.info {
        background: #eff6ff;
        border: 1px solid #bfdbfe;
        color: #1e40af;
    }
    
    /* 响应式设计 */
    @media (max-width: 768px) {
        .te-page {
            padding: 20px 16px;
        }
        
        .te-card-body {
            padding: 24px 20px;
        }
        
        .te-btn-group {
            flex-direction: column;
        }
        
        .te-btn {
            width: 100%;
        }
    }
</style>

<div class="te-page">
    <!-- 页面标题 -->
    <div class="te-header">
        <div class="te-header-icon">
            <svg viewBox="0 0 24 24">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
        </div>
        <div class="te-header-text">
            <h1>编辑教师信息</h1>
            <p>修改教师的基本信息和权限设置</p>
        </div>
    </div>
    
    <!-- 表单卡片 -->
    <div class="te-card">
        <div class="te-card-body">
            <!-- 姓名 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                        <circle cx="12" cy="7" r="4"/>
                    </svg>
                    教师姓名
                </label>
                <asp:TextBox ID="Texthname" runat="server" CssClass="te-input" placeholder="请输入教师姓名"></asp:TextBox>
                <div class="te-hint">教师的真实姓名，用于系统显示和识别</div>
            </div>
            
            <!-- 昵称 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2z"/>
                        <path d="M8 14s1.5 2 4 2 4-2 4-2"/>
                        <line x1="9" y1="9" x2="9.01" y2="9"/>
                        <line x1="15" y1="9" x2="15.01" y2="9"/>
                    </svg>
                    昵称
                </label>
                <asp:TextBox ID="Texthnick" runat="server" CssClass="te-input" placeholder="请输入昵称（可选）"></asp:TextBox>
                <div class="te-hint">显示在个人资料中的昵称，可以与姓名不同</div>
            </div>
            
            <!-- 邮箱 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                        <polyline points="22,6 12,13 2,6"/>
                    </svg>
                    邮箱地址
                </label>
                <asp:TextBox ID="Texthemail" runat="server" CssClass="te-input" placeholder="请输入邮箱地址（可选）"></asp:TextBox>
                <div class="te-hint">用于找回密码和接收系统通知，建议绑定常用邮箱</div>
            </div>
            
            <!-- 学校 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                        <polyline points="9 22 9 12 15 12 15 22"/>
                    </svg>
                    所属学校
                </label>
                <asp:DropDownList ID="ddlSchool" runat="server" CssClass="te-input" 
                    style="cursor:pointer;appearance:none;-webkit-appearance:none;-moz-appearance:none;background-image:url('data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2712%27 height=%2712%27 viewBox=%270 0 12 12%27%3E%3Cpath fill=%27%23475569%27 d=%27M6 9L1 4h10z%27/%3E%3C/svg%3E');background-repeat:no-repeat;background-position:right 12px center;padding-right:36px;">
                </asp:DropDownList>
                <div class="te-hint">选择教师所属的校区，留空则不设置</div>
            </div>
            
            <!-- 密码 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    登录密码
                </label>
                <asp:TextBox ID="Texthpwd" runat="server" CssClass="te-input" placeholder="请输入新密码（留空则不修改）"></asp:TextBox>
                <div class="te-hint">留空表示不修改密码，建议使用6位以上的强密码</div>
            </div>
            
            <!-- 权限 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                    管理员权限
                </label>
                <div class="te-checkbox-wrapper">
                    <asp:CheckBox ID="Ckhpermiss" runat="server" />
                    <label class="te-checkbox-label" for="<%= Ckhpermiss.ClientID %>">
                        设置为管理员（拥有系统管理权限）
                    </label>
                </div>
                <div class="te-hint">管理员可以访问后台管理功能，包括用户管理、系统设置等</div>
            </div>
            
            <!-- 备注 -->
            <div class="te-form-group">
                <label class="te-label">
                    <svg class="te-label-icon" viewBox="0 0 24 24">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/>
                        <polyline points="10 9 9 9 8 9"/>
                    </svg>
                    备注信息
                </label>
                <asp:TextBox ID="Texthnote" runat="server" CssClass="te-input te-textarea" 
                             TextMode="MultiLine" placeholder="请输入备注信息（可选）"></asp:TextBox>
                <div class="te-hint">可以记录教师的联系方式、任教科目等额外信息</div>
            </div>
            
            <!-- 按钮组 -->
            <div class="te-btn-group">
                <asp:Button ID="Btnedit" runat="server" CssClass="te-btn te-btn-primary" 
                            Text="保存修改" onclick="Btnedit_Click" />
            </div>
        </div>
    </div>
    
    <!-- 消息提示 -->
    <asp:Label ID="Labelmsg" runat="server" CssClass="te-message"></asp:Label>
</div>

<script type="text/javascript">
    // 显示消息提示
    window.onload = function() {
        var msgLabel = document.getElementById('<%= Labelmsg.ClientID %>');
        if (msgLabel && msgLabel.innerText.trim() !== '') {
            msgLabel.classList.add('show');
            
            // 根据消息内容判断类型
            var text = msgLabel.innerText.toLowerCase();
            if (text.indexOf('成功') !== -1 || text.indexOf('完成') !== -1) {
                msgLabel.classList.add('success');
            } else if (text.indexOf('错误') !== -1 || text.indexOf('失败') !== -1) {
                msgLabel.classList.add('error');
            } else {
                msgLabel.classList.add('info');
            }
            
            // 3秒后自动隐藏
            setTimeout(function() {
                msgLabel.style.opacity = '0';
                msgLabel.style.transition = 'opacity 0.3s';
                setTimeout(function() {
                    msgLabel.style.display = 'none';
                }, 300);
            }, 3000);
        }
    };
</script>
</asp:Content>
