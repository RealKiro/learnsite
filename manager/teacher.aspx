<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_teacher, LearnSite" enableeventvalidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    // 在页面初始化时注册事件
    protected void Page_Init(object sender, EventArgs e)
    {
        GVTeacher.RowDataBound += FillSchoolColumn;
        this.PreRender += LoadSchoolDropdown;
    }
    
    // 加载学校下拉列表
    private void LoadSchoolDropdown(object sender, EventArgs e)
    {
        if (ddlBatchSchool == null || ddlBatchSchool.Items.Count > 0) return;
        
        try
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                ddlBatchSchool.Items.Clear();
                ddlBatchSchool.Items.Add(new System.Web.UI.WebControls.ListItem("选择学校", ""));
                
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
    
    // 填充学校列
    private void FillSchoolColumn(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        
        try
        {
            Label lblSchool = e.Row.FindControl("LabelSchool") as Label;
            if (lblSchool == null) return;
            
            DataRowView drv = e.Row.DataItem as DataRowView;
            if (drv != null && drv.Row.Table.Columns.Contains("hid"))
            {
                object hidObj = drv["hid"];
                if (hidObj != null && hidObj != DBNull.Value)
                {
                    int hid = Convert.ToInt32(hidObj);
                    string schoolName = GetSchoolNameByTeacherId(hid);
                    
                    if (!string.IsNullOrEmpty(schoolName))
                    {
                        lblSchool.Text = "<span style='display:inline-block;padding:3px 10px;background:#eef2ff;color:#4338ca;border-radius:6px;font-size:12px;font-weight:500;'>" + Server.HtmlEncode(schoolName) + "</span>";
                    }
                    else
                    {
                        lblSchool.Text = "<span style='color:#94a3b8;font-size:12px;'>未设置</span>";
                    }
                }
            }
        }
        catch { }
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
    
    // 获取教师学校名称
    private string GetSchoolNameByTeacherId(int teacherId)
    {
        try
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return null;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'SchoolId'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int columnExists = (int)cmdCheck.ExecuteScalar();
                
                if (columnExists == 0) return null;
                
                string sql = @"SELECT S.SchoolName 
                    FROM Teacher T 
                    LEFT JOIN School S ON T.SchoolId = S.SchoolId 
                    WHERE T.hid = @TeacherId AND S.IsActive = 1";
                    
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
            }
        }
        catch { }
        
        return null;
    }
    
    // 批量设置学校
    protected void BtnBatchSetSchool_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(ddlBatchSchool.SelectedValue))
            {
                lblBatchMsg.Text = "请选择要设置的学校";
                lblBatchMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            string selectedIds = hdnSelectedTeachers.Value;
            if (string.IsNullOrEmpty(selectedIds) || selectedIds.Trim() == "")
            {
                lblBatchMsg.Text = "请先勾选要设置的教师";
                lblBatchMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            // 验证 selectedIds 格式（防止 SQL 注入）
            string[] ids = selectedIds.Split(',');
            System.Collections.Generic.List<int> validIds = new System.Collections.Generic.List<int>();
            
            foreach (string id in ids)
            {
                int teacherId;
                if (int.TryParse(id.Trim(), out teacherId) && teacherId > 0)
                {
                    validIds.Add(teacherId);
                }
            }
            
            if (validIds.Count == 0)
            {
                lblBatchMsg.Text = "没有有效的教师ID";
                lblBatchMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr))
            {
                lblBatchMsg.Text = "数据库连接配置错误";
                lblBatchMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'SchoolId'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int columnExists = (int)cmdCheck.ExecuteScalar();
                
                if (columnExists == 0)
                {
                    lblBatchMsg.Text = "Teacher 表缺少 SchoolId 字段，请先执行数据库升级脚本";
                    lblBatchMsg.ForeColor = System.Drawing.Color.Red;
                    return;
                }
                
                // 使用参数化查询，安全地构建 IN 子句
                System.Text.StringBuilder sqlBuilder = new System.Text.StringBuilder();
                sqlBuilder.Append("UPDATE Teacher SET SchoolId = @SchoolId WHERE hid IN (");
                
                System.Collections.Generic.List<string> paramNames = new System.Collections.Generic.List<string>();
                for (int i = 0; i < validIds.Count; i++)
                {
                    string paramName = "@hid" + i;
                    paramNames.Add(paramName);
                }
                sqlBuilder.Append(string.Join(",", paramNames.ToArray()));
                sqlBuilder.Append(")");
                
                SqlCommand cmd = new SqlCommand(sqlBuilder.ToString(), conn);
                cmd.Parameters.AddWithValue("@SchoolId", int.Parse(ddlBatchSchool.SelectedValue));
                
                for (int i = 0; i < validIds.Count; i++)
                {
                    cmd.Parameters.AddWithValue("@hid" + i, validIds[i]);
                }
                
                int count = cmd.ExecuteNonQuery();
                
                lblBatchMsg.Text = "成功设置 " + count + " 位教师的学校！";
                lblBatchMsg.ForeColor = System.Drawing.Color.Green;
                
                hdnSelectedTeachers.Value = "";
                
                Response.Redirect(Request.RawUrl);
            }
        }
        catch (Exception ex)
        {
            lblBatchMsg.Text = "批量设置失败：" + ex.Message;
            lblBatchMsg.ForeColor = System.Drawing.Color.Red;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .pg{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .pg-hd{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:24px;flex-wrap:wrap;}
    .pg-hd-left{display:flex;align-items:center;gap:16px;}
    .pg-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .pg-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .pg-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .pg-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;gap:6px;height:38px;padding:0 22px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:10px;font-size:13.5px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(99,102,241,.3);}
    .btn-primary:hover{box-shadow:0 4px 16px rgba(99,102,241,.4);transform:translateY(-1px);}
    .btn-primary svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .t-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;}
    .t-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .t-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:#eef2ff;}
    .t-card-hd .ci svg{width:19px;height:19px;stroke:#6366f1;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .t-wrap{overflow-x:auto;}
    .t-wrap table{width:100%;border-collapse:collapse;font-size:13px;}
    .t-wrap th{background:#f8fafc;color:#475569;font-weight:600;padding:11px 16px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;white-space:nowrap;}
    .t-wrap td{padding:11px 16px;color:#334155;border-bottom:1px solid #f1f5f9;white-space:nowrap;}
    .t-wrap tr:last-child td{border-bottom:none;}
    .t-wrap tr:hover td{background:#f8fafc;}
    .t-wrap tr.alt td,.t-wrap tr:nth-child(even) td{background:#fafbfc;}
    .t-wrap table tr td table{margin:10px auto 0;border-collapse:separate;border-spacing:6px 0;}
    .t-wrap table tr td table td{padding:0;border:none;background:transparent!important;}
    .t-wrap table tr td table td span,
    .t-wrap table tr td table td a{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:34px;padding:0 10px;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;}
    .t-wrap table tr td table td span{background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff;}
    .t-wrap table tr td table td a{background:#f8fafc;color:#6366f1;border:1px solid #e2e8f0;transition:all .2s;}
    .t-wrap table tr td table td a:hover{background:#eef2ff;border-color:#c7d2fe;color:#4f46e5;}
    .t-wrap a{color:#6366f1;text-decoration:none;font-weight:500;padding:4px 12px;border-radius:6px;transition:all .15s;}
    .t-wrap a:hover{background:#eef2ff;color:#4f46e5;}
    .t-wrap .del-link{color:#ef4444;}
    .t-wrap .del-link:hover{background:#fef2f2;color:#dc2626;}
    
    /* 批量操作卡片 */
    .batch-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;margin-bottom:20px;}
    .batch-hd{padding:12px 20px;background:#f8fafc;border-bottom:1px solid #e2e8f0;display:flex;align-items:center;gap:10px;font-size:14px;font-weight:600;color:#1e293b;}
    .batch-bd{padding:16px 20px;}
    .batch-row{display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
    .batch-info{font-size:13px;color:#64748b;}
    .batch-info span{font-weight:700;color:#6366f1;font-size:16px;}
    .batch-actions{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
    .batch-select{padding:8px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;color:#334155;background:#fff;cursor:pointer;transition:all .2s;min-width:150px;}
    .batch-select:focus{outline:none;border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.1);}
    .btn-batch{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:8px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,.3);}
    .btn-batch:hover{box-shadow:0 4px 12px rgba(99,102,241,.4);transform:translateY(-1px);}
    .btn-clear{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:#f1f5f9;color:#64748b;border:1px solid #e2e8f0;border-radius:8px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;}
    .btn-clear:hover{background:#e2e8f0;color:#475569;border-color:#cbd5e1;}
    .batch-msg{display:block;margin-top:12px;font-size:13px;padding:10px 14px;border-radius:8px;}
</style>

<script type="text/javascript">
    // 动态添加复选框列
    function addCheckboxColumn() {
        var table = document.querySelector('#<%= GVTeacher.ClientID %>');
        if (!table) return;
        
        // 查找表头行
        var headerRow = table.querySelector('tr');
        if (!headerRow) return;
        
        // 检查是否已经添加了复选框列
        if (headerRow.querySelector('.chk-header')) return;
        
        // 在表头添加复选框列
        var th = document.createElement('th');
        th.style.cssText = 'background:#f8fafc;color:#475569;font-weight:600;padding:11px 16px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;white-space:nowrap;';
        th.innerHTML = '<input type="checkbox" id="chkAll" class="chk-header" onclick="toggleAll(this)" style="width:16px;height:16px;cursor:pointer;accent-color:#6366f1;" />';
        headerRow.insertBefore(th, headerRow.firstChild);
        
        // 在每个数据行添加复选框
        var rows = table.querySelectorAll('tr');
        for (var i = 1; i < rows.length; i++) {
            var row = rows[i];
            
            // 跳过分页行等非数据行
            if (row.cells.length === 0) continue;
            
            // 尝试从行中获取 hid
            var hid = null;
            
            // 方法1: 从删除链接获取
            var deleteLink = row.querySelector('a[href*="hid="]');
            if (deleteLink) {
                var match = deleteLink.href.match(/hid=(\d+)/);
                if (match) hid = match[1];
            }
            
            // 方法2: 从修改链接获取
            if (!hid) {
                var editLink = row.querySelector('a[href*="teacheredit"]');
                if (editLink) {
                    var match = editLink.href.match(/hid=(\d+)/);
                    if (match) hid = match[1];
                }
            }
            
            if (hid) {
                var td = document.createElement('td');
                td.style.cssText = 'padding:11px 16px;color:#334155;border-bottom:1px solid #f1f5f9;white-space:nowrap;';
                td.innerHTML = '<input type="checkbox" class="chk-teacher" data-hid="' + hid + '" style="width:16px;height:16px;cursor:pointer;accent-color:#6366f1;" />';
                row.insertBefore(td, row.firstChild);
            }
        }
        
        // 为所有复选框添加事件监听
        var checkboxes = document.querySelectorAll('.chk-teacher');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].addEventListener('change', updateSelection);
        }
        
        updateSelection();
    }
    
    // 全选/取消全选
    function toggleAll(checkbox) {
        var checkboxes = document.querySelectorAll('.chk-teacher');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checkbox.checked;
        }
        updateSelection();
    }
    
    // 更新选择状态
    function updateSelection() {
        var checkboxes = document.querySelectorAll('.chk-teacher');
        var selectedIds = [];
        var count = 0;
        
        for (var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked) {
                var hid = checkboxes[i].getAttribute('data-hid');
                if (hid) {
                    selectedIds.push(hid);
                    count++;
                }
            }
        }
        
        // 更新隐藏字段
        var hiddenField = document.getElementById('<%= hdnSelectedTeachers.ClientID %>');
        if (hiddenField) {
            hiddenField.value = selectedIds.join(',');
            console.log('Updated hidden field:', hiddenField.value);
        }
        
        // 更新计数显示
        var countElement = document.getElementById('selectedCount');
        if (countElement) {
            countElement.textContent = count;
        }
        
        // 更新全选复选框状态
        var chkAll = document.getElementById('chkAll');
        if (chkAll && checkboxes.length > 0) {
            chkAll.checked = (count > 0 && count === checkboxes.length);
        }
    }
    
    // 清空选择
    function clearSelection() {
        var checkboxes = document.querySelectorAll('.chk-teacher');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }
        var chkAll = document.getElementById('chkAll');
        if (chkAll) {
            chkAll.checked = false;
        }
        updateSelection();
    }
    
    // 页面加载时初始化
    if (window.addEventListener) {
        window.addEventListener('DOMContentLoaded', function() {
            // 延迟执行以确保 GridView 已渲染
            setTimeout(function() {
                addCheckboxColumn();
            }, 100);
        });
    } else if (window.attachEvent) {
        window.attachEvent('onload', function() {
            setTimeout(function() {
                addCheckboxColumn();
            }, 100);
        });
    }
    
    // 在表单提交前确保隐藏字段有值
    function validateBatchOperation() {
        var hiddenField = document.getElementById('<%= hdnSelectedTeachers.ClientID %>');
        var schoolSelect = document.getElementById('<%= ddlBatchSchool.ClientID %>');
        
        console.log('Hidden field value:', hiddenField ? hiddenField.value : 'null');
        console.log('School select value:', schoolSelect ? schoolSelect.value : 'null');
        
        if (!hiddenField || !hiddenField.value || hiddenField.value.trim() === '') {
            alert('请先勾选要设置的教师');
            return false;
        }
        
        if (!schoolSelect || !schoolSelect.value || schoolSelect.value === '') {
            alert('请选择要设置的学校');
            return false;
        }
        
        return true;
    }
</script>

<div class="pg">
    <div class="pg-hd">
        <div class="pg-hd-left">
            <div class="pg-hd-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
            <div class="pg-hd-text"><h1>教师管理</h1><p>管理教师账号、权限、班级分配与学案信息</p></div>
        </div>
        <asp:Button ID="Btnadd" runat="server" Text="➕ 添加教师" CssClass="btn-primary" onclick="Btnadd_Click" />
    </div>
    
    <!-- 批量操作卡片 -->
    <div class="batch-card">
        <div class="batch-hd">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            批量操作
        </div>
        <div class="batch-bd">
            <div class="batch-row">
                <div class="batch-info">
                    已选择 <span id="selectedCount">0</span> 位教师
                </div>
                <div class="batch-actions">
                    <asp:DropDownList ID="ddlBatchSchool" runat="server" CssClass="batch-select"></asp:DropDownList>
                    <asp:Button ID="btnBatchSetSchool" runat="server" Text="设置学校" CssClass="btn-batch" OnClick="BtnBatchSetSchool_Click" OnClientClick="return validateBatchOperation();" />
                    <button type="button" class="btn-clear" onclick="clearSelection()">清空选择</button>
                </div>
            </div>
            <asp:Label ID="lblBatchMsg" runat="server" CssClass="batch-msg"></asp:Label>
        </div>
    </div>
    <asp:HiddenField ID="hdnSelectedTeachers" runat="server" />

    <div class="t-card">
        <div class="t-card-hd">
            <span class="ci"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
            教师列表
        </div>
        <div class="t-wrap">
            <asp:GridView ID="GVTeacher" runat="server" 
                AutoGenerateColumns="False" CellPadding="0" GridLines="None" Width="100%" 
                AllowPaging="True" PageSize="10"
                onpageindexchanging="GVTeacher_PageIndexChanging" 
                onrowdatabound="GVTeacher_RowDataBound" EnableModelValidation="True" 
                onrowcommand="GVTeacher_RowCommand" BorderWidth="0" BorderStyle="None" Font-Size="13px">
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:BoundField DataField="Hname" HeaderText="账号" />
                    <asp:BoundField DataField="Hnick" HeaderText="昵称" />
                    <asp:BoundField DataField="Hpwd" HeaderText="密码" />
                    <asp:TemplateField HeaderText="权限">
                        <ItemTemplate>
                            <asp:Label ID="LabelHpermiss" runat="server" Text='<%# Bind("Hpermiss") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="学校">
                        <ItemTemplate>
                            <asp:Label ID="LabelSchool" runat="server" Text="<span style='color:#94a3b8;font-size:12px;'>加载中...</span>"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Hnote" HeaderText="备注" />
                    <asp:BoundField DataField="Hcount" HeaderText="学案数" />
                    <asp:TemplateField HeaderText="班级">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLinkRoom" runat="server" 
                                NavigateUrl='<%# Eval("hid", "roomselect.aspx?hid={0}") %>' Text="选择"></asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:HyperLinkField DataNavigateUrlFields="hid" 
                        DataNavigateUrlFormatString="teacheredit.aspx?hid={0}" 
                        Text="修改" HeaderText="操作" />
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkButtonDel" runat="server" CausesValidation="false" 
                                CommandName="D" Text="删除" CommandArgument='<%# Bind("hid") %>' CssClass="del-link"
                                ToolTip="如果删除后想恢复，请手动在数据库Teacher表将该账号的删除标志重置为false！"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle CssClass="" />
                <RowStyle CssClass="" />
                <AlternatingRowStyle CssClass="alt" />
                <PagerStyle HorizontalAlign="Center" />
            </asp:GridView>
        </div>
    </div>
</div>
</asp:Content>

