<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="System.Web.UI.Page" enableeventvalidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadUserStatistics();
            LoadUsers();
        }
    }
    
    // 获取连接字符串
    private string GetConnStr()
    {
        ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["constr"]
            ?? ConfigurationManager.ConnectionStrings["SqlServer"];
        return cfg != null ? cfg.ConnectionString : null;
    }

    // 检查指定表中某列是否存在（兼容未升级的数据库）
    private bool ColumnExists(SqlConnection conn, string tableName, string columnName)
    {
        const string sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@T AND COLUMN_NAME=@C";
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@T", tableName);
            cmd.Parameters.AddWithValue("@C", columnName);
            return (int)cmd.ExecuteScalar() > 0;
        }
    }

    private void LoadUserStatistics()
    {
        try
        {
            string connStr = GetConnStr();
            if (connStr == null) return;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                int studentCount = (int)new SqlCommand("SELECT COUNT(*) FROM Students", conn).ExecuteScalar();
                int teacherCount = (int)new SqlCommand("SELECT COUNT(*) FROM Teacher",  conn).ExecuteScalar();
                lblStudentCount.Text = studentCount.ToString();
                lblTeacherCount.Text = teacherCount.ToString();
                lblTotalCount.Text   = (studentCount + teacherCount).ToString();
            }
        }
        catch
        {
            lblStudentCount.Text = "0";
            lblTeacherCount.Text = "0";
            lblTotalCount.Text   = "0";
        }
    }
    
    private void LoadUsers()
    {
        try
        {
            string userType = ddlUserType.SelectedValue;
            string keyword  = txtKeyword.Text.Trim();
            
            string connStr = GetConnStr();
            if (connStr == null) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 动态检测可选扩展列是否存在（兼容未升级的数据库）
                bool stuHasSchoolId = ColumnExists(conn, "Students", "SchoolId");
                bool teaHasSchoolId = ColumnExists(conn, "Teacher",  "SchoolId");
                bool teaHasHemail   = ColumnExists(conn, "Teacher",  "Hemail");

                DataTable dt = new DataTable();
                dt.Columns.Add("UserType",     typeof(string));
                dt.Columns.Add("UserId",       typeof(string));
                dt.Columns.Add("UserName",     typeof(string));
                dt.Columns.Add("NickName",     typeof(string));
                dt.Columns.Add("SchoolName",   typeof(string));
                dt.Columns.Add("ClassName",    typeof(string));
                dt.Columns.Add("Email",        typeof(string));
                dt.Columns.Add("LastLogin",    typeof(string));
                dt.Columns.Add("EditUrl",      typeof(string));
                dt.Columns.Add("UserTypeCode", typeof(string));
                
                // ---- 加载学生 ----
                if (userType == "all" || userType == "student")
                {
                    string schJoin = stuHasSchoolId
                        ? "LEFT JOIN School SCH ON S.SchoolId = SCH.SchoolId"
                        : "";
                    string schCol  = stuHasSchoolId ? "SCH.SchoolName" : "'' AS SchoolName";

                    string studentSql = string.Format(
                        "SELECT S.Sid, S.Snum, S.Sname, S.Sgrade, S.Sclass, S.Semail, {0} FROM Students S {1}",
                        schCol, schJoin);

                    if (!string.IsNullOrEmpty(keyword))
                        studentSql += " WHERE (S.Snum LIKE @Keyword OR S.Sname LIKE @Keyword)";

                    studentSql += " ORDER BY S.Sgrade, S.Sclass, S.Snum";

                    using (SqlCommand cmd = new SqlCommand(studentSql, conn))
                    {
                        if (!string.IsNullOrEmpty(keyword))
                            cmd.Parameters.AddWithValue("@Keyword", "%" + keyword + "%");

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                DataRow row = dt.NewRow();
                                row["UserType"]     = "学生";
                                row["UserTypeCode"] = "student";
                                row["UserId"]   = reader["Sid"]   != DBNull.Value ? reader["Sid"].ToString()   : "";
                                row["UserName"] = reader["Snum"]  != DBNull.Value ? reader["Snum"].ToString()  : "";
                                row["NickName"] = reader["Sname"] != DBNull.Value ? reader["Sname"].ToString() : "";
                                row["SchoolName"] = reader["SchoolName"] != DBNull.Value ? reader["SchoolName"].ToString() : "";
                                string grade = reader["Sgrade"] != DBNull.Value ? reader["Sgrade"].ToString() : "";
                                string cls   = reader["Sclass"] != DBNull.Value ? reader["Sclass"].ToString() : "";
                                row["ClassName"] = (grade != "" && cls != "") ? grade + "年级" + cls + "班" : "";
                                row["Email"]     = reader["Semail"] != DBNull.Value ? reader["Semail"].ToString() : "";
                                row["LastLogin"] = "";
                                row["EditUrl"]   = "studentedit.aspx?sid=" + reader["Sid"].ToString();
                                dt.Rows.Add(row);
                            }
                        }
                    }
                }
                
                // ---- 加载教师 ----
                if (userType == "all" || userType == "teacher")
                {
                    string emailCol = teaHasHemail   ? "T.Hemail"       : "'' AS Hemail";
                    string schJoin  = teaHasSchoolId ? "LEFT JOIN School SCH ON T.SchoolId = SCH.SchoolId" : "";
                    string schCol   = teaHasSchoolId ? "SCH.SchoolName" : "'' AS SchoolName";

                    string teacherSql = string.Format(
                        "SELECT T.Hid, T.Hname, T.Hnick, {0}, T.Hpermiss, {1} FROM Teacher T {2}",
                        emailCol, schCol, schJoin);

                    if (!string.IsNullOrEmpty(keyword))
                        teacherSql += " WHERE (T.Hname LIKE @Keyword OR T.Hnick LIKE @Keyword)";

                    teacherSql += " ORDER BY T.Hid";

                    using (SqlCommand cmd = new SqlCommand(teacherSql, conn))
                    {
                        if (!string.IsNullOrEmpty(keyword))
                            cmd.Parameters.AddWithValue("@Keyword", "%" + keyword + "%");

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                DataRow row = dt.NewRow();
                                row["UserType"]     = "教师";
                                row["UserTypeCode"] = "teacher";
                                row["UserId"]   = reader["Hid"]   != DBNull.Value ? reader["Hid"].ToString()   : "";
                                row["UserName"] = reader["Hname"] != DBNull.Value ? reader["Hname"].ToString() : "";
                                row["NickName"] = reader["Hnick"] != DBNull.Value ? reader["Hnick"].ToString() : "";
                                row["SchoolName"] = reader["SchoolName"] != DBNull.Value ? reader["SchoolName"].ToString() : "";
                                string permiss = reader["Hpermiss"] != DBNull.Value ? reader["Hpermiss"].ToString() : "";
                                row["ClassName"] = GetPermissionName(permiss);
                                row["Email"]     = reader["Hemail"] != DBNull.Value ? reader["Hemail"].ToString() : "";
                                row["LastLogin"] = "";
                                row["EditUrl"]   = "teacheredit.aspx?hid=" + reader["Hid"].ToString();
                                dt.Rows.Add(row);
                            }
                        }
                    }
                }
                
                GVUsers.DataSource = dt;
                GVUsers.DataBind();
                lblResultCount.Text = "共找到 " + dt.Rows.Count + " 个用户";
            }
        }
        catch (Exception ex)
        {
            lblResultCount.Text = "加载失败：" + ex.Message;
            lblResultCount.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    private string GetPermissionName(string permiss)
    {
        // Hpermiss 原始类型为 bit，读取后 ToString() 为 "True"/"False"
        if (permiss == "True" || permiss == "1") return "管理员";
        return "普通教师";
    }
    
    protected void BtnSearch_Click(object sender, EventArgs e)
    {
        LoadUsers();
    }
    
    protected void DdlUserType_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadUsers();
    }
    
    protected void BtnExport_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.ContentEncoding = System.Text.Encoding.UTF8;
            Response.Charset = "UTF-8";
            Response.AddHeader("Content-Disposition", "attachment;filename=users_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xls");
            
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><body>");
            sb.Append("<table border='1'>");
            sb.Append("<tr><th>用户类型</th><th>用户ID</th><th>账号</th><th>昵称</th><th>学校</th><th>班级/权限</th><th>邮箱</th></tr>");
            
            foreach (GridViewRow row in GVUsers.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    sb.Append("<tr>");
                    for (int i = 0; i < row.Cells.Count - 1; i++) // 排除最后的操作列
                    {
                        sb.Append("<td>" + Server.HtmlEncode(row.Cells[i].Text) + "</td>");
                    }
                    sb.Append("</tr>");
                }
            }
            
            sb.Append("</table></body></html>");
            
            Response.Write(sb.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            lblResultCount.Text = "导出失败：" + ex.Message;
            lblResultCount.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    protected void GVUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeleteUser")
        {
            try
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userType = args[0];
                string userId = args[1];
                
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
                    
                    string sql = "";
                    if (userType == "student")
                    {
                        sql = "DELETE FROM Students WHERE Sid = @Id";
                    }
                    else if (userType == "teacher")
                    {
                        sql = "DELETE FROM Teacher WHERE Hid = @Id";
                    }
                    
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Id", int.Parse(userId));
                    cmd.ExecuteNonQuery();
                    
                    lblResultCount.Text = "删除成功！";
                    lblResultCount.ForeColor = System.Drawing.Color.Green;
                    
                    LoadUserStatistics();
                    LoadUsers();
                }
            }
            catch (Exception ex)
            {
                lblResultCount.Text = "删除失败：" + ex.Message;
                lblResultCount.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .pg{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .pg-hd{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:24px;flex-wrap:wrap;}
    .pg-hd-left{display:flex;align-items:center;gap:16px;}
    .pg-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#8b5cf6,#a78bfa);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(139,92,246,.25);flex-shrink:0;}
    .pg-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .pg-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .pg-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    
    /* 统计卡片 */
    .stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:24px;}
    .stat-card{background:#fff;border-radius:12px;border:1px solid #e2e8f0;padding:20px;display:flex;align-items:center;gap:16px;transition:all .2s;}
    .stat-card:hover{box-shadow:0 4px 12px rgba(0,0,0,.08);transform:translateY(-2px);}
    .stat-icon{width:48px;height:48px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .stat-icon svg{width:24px;height:24px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .stat-icon.purple{background:linear-gradient(135deg,#8b5cf6,#a78bfa);}
    .stat-icon.blue{background:linear-gradient(135deg,#3b82f6,#60a5fa);}
    .stat-icon.green{background:linear-gradient(135deg,#10b981,#34d399);}
    .stat-content h3{font-size:28px;font-weight:700;color:#0f172a;margin:0 0 4px;}
    .stat-content p{font-size:13px;color:#64748b;margin:0;}
    
    /* 搜索区域 */
    .search-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;padding:20px;margin-bottom:20px;}
    .search-row{display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
    .search-select{padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;color:#334155;background:#fff;cursor:pointer;transition:all .2s;min-width:150px;}
    .search-select:focus{outline:none;border-color:#8b5cf6;box-shadow:0 0 0 3px rgba(139,92,246,.1);}
    .search-input{flex:1;min-width:200px;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;color:#334155;transition:all .2s;}
    .search-input:focus{outline:none;border-color:#8b5cf6;box-shadow:0 0 0 3px rgba(139,92,246,.1);}
    .btn-search{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 20px;background:linear-gradient(135deg,#8b5cf6,#a78bfa);color:#fff!important;border:none;border-radius:8px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(139,92,246,.3);}
    .btn-search:hover{box-shadow:0 4px 12px rgba(139,92,246,.4);transform:translateY(-1px);}
    .btn-export{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 20px;background:#fff;color:#8b5cf6;border:1.5px solid #8b5cf6;border-radius:8px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;}
    .btn-export:hover{background:#f5f3ff;border-color:#7c3aed;}
    
    /* 表格卡片 */
    .t-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;}
    .t-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;justify-content:space-between;}
    .t-wrap{overflow-x:auto;}
    .t-wrap table{width:100%;border-collapse:collapse;font-size:13px;}
    .t-wrap th{background:#f8fafc;color:#475569;font-weight:600;padding:11px 16px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;white-space:nowrap;}
    .t-wrap td{padding:11px 16px;color:#334155;border-bottom:1px solid #f1f5f9;white-space:nowrap;}
    .t-wrap tr:last-child td{border-bottom:none;}
    .t-wrap tr:hover td{background:#f8fafc;}
    .t-wrap a{color:#6366f1;text-decoration:none;font-weight:500;padding:4px 12px;border-radius:6px;transition:all .15s;display:inline-block;margin:0 2px;}
    .t-wrap a:hover{background:#eef2ff;color:#4f46e5;}
    .t-wrap .del-link{color:#ef4444;}
    .t-wrap .del-link:hover{background:#fef2f2;color:#dc2626;}
    
    .badge{display:inline-block;padding:4px 10px;border-radius:6px;font-size:12px;font-weight:500;}
    .badge-student{background:#dbeafe;color:#1e40af;}
    .badge-teacher{background:#fce7f3;color:#9f1239;}
    .badge-school{background:#eef2ff;color:#4338ca;}
</style>

<div class="pg">
    <div class="pg-hd">
        <div class="pg-hd-left">
            <div class="pg-hd-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
            </div>
            <div class="pg-hd-text">
                <h1>用户管理</h1>
                <p>查看和管理系统中的所有用户（学生和教师）</p>
            </div>
        </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon purple">
                <svg viewBox="0 0 24 24">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
            </div>
            <div class="stat-content">
                <h3><asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label></h3>
                <p>总用户数</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon blue">
                <svg viewBox="0 0 24 24">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
            </div>
            <div class="stat-content">
                <h3><asp:Label ID="lblStudentCount" runat="server" Text="0"></asp:Label></h3>
                <p>学生用户</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">
                <svg viewBox="0 0 24 24">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                </svg>
            </div>
            <div class="stat-content">
                <h3><asp:Label ID="lblTeacherCount" runat="server" Text="0"></asp:Label></h3>
                <p>教师用户</p>
            </div>
        </div>
    </div>
    
    <!-- 搜索区域 -->
    <div class="search-card">
        <div class="search-row">
            <asp:DropDownList ID="ddlUserType" runat="server" CssClass="search-select" AutoPostBack="true" OnSelectedIndexChanged="DdlUserType_SelectedIndexChanged">
                <asp:ListItem Value="all" Selected="True">全部用户</asp:ListItem>
                <asp:ListItem Value="student">学生</asp:ListItem>
                <asp:ListItem Value="teacher">教师</asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtKeyword" runat="server" CssClass="search-input" placeholder="搜索账号、姓名或昵称..."></asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="搜索" CssClass="btn-search" OnClick="BtnSearch_Click" />
            <asp:Button ID="btnExport" runat="server" Text="导出Excel" CssClass="btn-export" OnClick="BtnExport_Click" />
        </div>
    </div>
    
    <!-- 用户列表 -->
    <div class="t-card">
        <div class="t-card-hd">
            <span>用户列表</span>
            <asp:Label ID="lblResultCount" runat="server" Text="" style="font-size:13px;font-weight:400;color:#64748b;"></asp:Label>
        </div>
        <div class="t-wrap">
            <asp:GridView ID="GVUsers" runat="server" 
                AutoGenerateColumns="False" CellPadding="0" GridLines="None" Width="100%" 
                EnableModelValidation="True" BorderWidth="0" BorderStyle="None" Font-Size="13px"
                OnRowCommand="GVUsers_RowCommand">
                <Columns>
                    <asp:TemplateField HeaderText="类型">
                        <ItemTemplate>
                            <span class='badge <%# Eval("UserType").ToString()=="学生"?"badge-student":"badge-teacher" %>'>
                                <%# Eval("UserType") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="UserId" HeaderText="ID" />
                    <asp:BoundField DataField="UserName" HeaderText="账号" />
                    <asp:BoundField DataField="NickName" HeaderText="昵称" />
                    <asp:TemplateField HeaderText="学校">
                        <ItemTemplate>
                            <%# string.IsNullOrEmpty(Eval("SchoolName").ToString()) ? 
                                "<span style='color:#94a3b8;'>未设置</span>" : 
                                "<span class='badge badge-school'>" + Eval("SchoolName") + "</span>" %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ClassName" HeaderText="班级/权限" />
                    <asp:BoundField DataField="Email" HeaderText="邮箱" />
                    <asp:TemplateField HeaderText="操作">
                        <ItemTemplate>
                            <a href='<%# Eval("EditUrl") %>'>编辑</a>
                            <asp:LinkButton ID="btnDelete" runat="server" 
                                CommandName="DeleteUser" 
                                CommandArgument='<%# Eval("UserTypeCode") + "|" + Eval("UserId") %>'
                                CssClass="del-link"
                                OnClientClick="return confirm('确定要删除这个用户吗？删除后无法恢复！');"
                                Text="删除">
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle CssClass="" />
                <RowStyle CssClass="" />
                <AlternatingRowStyle CssClass="alt" />
            </asp:GridView>
        </div>
    </div>
</div>
</asp:Content>
