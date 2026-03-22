<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_studentimport, LearnSite" enableeventvalidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected void Page_PreRender(object sender, EventArgs e)
    {
        // 在 PreRender 阶段加载校区，确保在所有事件处理后执行
        if (ddlSchool.Items.Count == 0)
        {
            LoadSchoolsToDropDown();
        }
    }
    
    private void LoadSchoolsToDropDown()
    {
        try
        {
            // 获取连接字符串
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
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                ddlSchool.Items.Clear();
                ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem("不设置校区", ""));
                
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
        catch (Exception ex)
        {
            // 添加错误提示到页面
            ddlSchool.Items.Clear();
            ddlSchool.Items.Add(new System.Web.UI.WebControls.ListItem("加载失败: " + ex.Message, ""));
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .si-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .si-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .si-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .si-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .si-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .si-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .si-grid{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
    .si-full{grid-column:1/-1;}
    @media(max-width:860px){.si-grid{grid-template-columns:1fr;}}
    .si-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .si-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .si-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .si-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .si-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.purple{background:#eef2ff;} .ci.purple svg{stroke:#6366f1;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .ci.rose{background:#fff1f2;} .ci.rose svg{stroke:#f43f5e;}
    .si-card-bd{padding:20px 22px;}
    .si-steps{display:flex;flex-direction:column;gap:20px;}
    .si-step{display:flex;align-items:flex-start;gap:14px;}
    .si-step-num{width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#6366f1,#818cf8);color:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;flex-shrink:0;}
    .si-step-num.disabled{background:#e2e8f0;color:#94a3b8;}
    .si-step-body{flex:1;padding-top:4px;}
    .si-step-title{font-size:14px;font-weight:600;color:#1e293b;margin-bottom:8px;}
    .si-card input[type="file"]{font-size:12px;color:#475569;}
    .si-card input[type="file"]::file-selector-button{height:32px;padding:0 14px;background:#f1f5f9;color:#334155;border:1.5px solid #e2e8f0;border-radius:8px;font-size:12px;cursor:pointer;transition:all .2s;margin-right:8px;}
    .si-card input[type="file"]::file-selector-button:hover{background:#e2e8f0;border-color:#cbd5e1;}
    .si-card input[type="checkbox"]{width:17px;height:17px;accent-color:#6366f1;cursor:pointer;vertical-align:middle;}
    .si-card label{cursor:pointer;color:#475569;font-size:13px;user-select:none;vertical-align:middle;margin-left:4px;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,.3);}
    .btn-primary:hover{box-shadow:0 4px 14px rgba(99,102,241,.4);transform:translateY(-1px);}
    .btn-primary:disabled,.btn-primary[disabled]{background:#cbd5e1;box-shadow:none;cursor:not-allowed;transform:none;}
    .btn-danger{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:#fef2f2;color:#ef4444;border:1px solid #fecaca;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;}
    .btn-danger:hover{background:#fee2e2;border-color:#fca5a5;color:#dc2626;}
    .si-info{background:#f0f9ff;border:1px solid #bae6fd;border-radius:10px;padding:14px 18px;font-size:12.5px;color:#0369a1;line-height:1.7;}
    .si-info a{color:#6366f1;font-weight:500;}
    .si-info a:hover{text-decoration:underline;}
    .si-table-wrap{border-radius:10px;overflow:hidden;border:1px solid #e2e8f0;margin-top:16px;}
    .si-table-wrap table{width:100%;border-collapse:collapse;font-size:13px;}
    .si-table-wrap th{background:#f8fafc;color:#475569;font-weight:600;padding:10px 14px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;}
    .si-table-wrap td{padding:10px 14px;color:#334155;border-bottom:1px solid #f1f5f9;}
    .si-table-wrap tr:hover td{background:#f8fafc;}
    #Loading{text-align:center;font-size:13px;color:#ef4444;padding:8px 0;}
    
    /* 校区下拉菜单样式修复 */
    .school-select{
        appearance:none;
        -webkit-appearance:none;
        -moz-appearance:none;
        background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23475569' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
        background-repeat:no-repeat;
        background-position:right 12px center;
        padding-right:36px !important;
    }
    .school-select:focus{
        outline:none;
        border-color:#6366f1;
        box-shadow:0 0 0 3px rgba(99,102,241,0.1);
    }
    .school-select option{
        padding:8px 12px;
        font-size:13px;
        color:#334155;
        background:#fff;
    }
</style>

<script type="text/javascript">
    // 页面加载完成后检查校区下拉框
    window.addEventListener('DOMContentLoaded', function() {
        var ddl = document.getElementById('<%= ddlSchool.ClientID %>');
        if (ddl) {
            // 总是尝试加载校区数据
            loadSchoolsViaAjax(ddl);
        }
    });
    
    function loadSchoolsViaAjax(ddl) {
        // 使用 XMLHttpRequest 加载校区数据
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'GetSchools.aspx?t=' + new Date().getTime(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            // 清空现有选项
                            ddl.options.length = 0;
                            
                            // 添加默认选项
                            var defaultOpt = document.createElement('option');
                            defaultOpt.value = '';
                            defaultOpt.text = '不设置校区';
                            ddl.add(defaultOpt);
                            
                            // 添加校区选项
                            for (var i = 0; i < response.schools.length; i++) {
                                var opt = document.createElement('option');
                                opt.value = response.schools[i].id;
                                opt.text = response.schools[i].name;
                                ddl.add(opt);
                            }
                            
                            console.log('成功加载 ' + response.schools.length + ' 个校区');
                        } else {
                            console.error('加载校区失败: ' + response.message);
                            // 确保至少有默认选项
                            if (ddl.options.length === 0) {
                                var opt = document.createElement('option');
                                opt.value = '';
                                opt.text = '不设置校区';
                                ddl.add(opt);
                            }
                        }
                    } catch (e) {
                        console.error('解析校区数据失败: ' + e.message);
                    }
                } else {
                    console.error('请求失败: ' + xhr.status);
                }
            }
        };
        xhr.send();
    }
</script>

<div class="si-page">
    <div class="si-hd">
        <div class="si-hd-icon"><svg viewBox="0 0 24 24"><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/><path d="M3 21V3"/></svg></div>
        <div class="si-hd-text"><h1>新生导入</h1><p>通过Excel文件批量导入学生数据到平台</p></div>
    </div>

    <div class="si-grid">

    <!-- 导入操作 -->
    <div class="si-card">
        <div class="si-card-hd">
            <span class="ci purple"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></span>
            导入操作
        </div>
        <div class="si-card-bd">
            <div class="si-steps">
                <div class="si-step">
                    <div class="si-step-num">1</div>
                    <div class="si-step-body">
                        <div class="si-step-title">选择校区（可选）</div>
                        <asp:DropDownList ID="ddlSchool" runat="server" CssClass="school-select" 
                            style="width:100%;max-width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;color:#334155;background:#fff;cursor:pointer;transition:all .2s;overflow:visible;">
                        </asp:DropDownList>
                        <div style="font-size:12px;color:#64748b;margin-top:6px;">
                            选择学生所属校区，留空则不设置校区
                        </div>
                    </div>
                </div>
                <div class="si-step">
                    <div class="si-step-num">2</div>
                    <div class="si-step-body">
                        <div class="si-step-title">选择Excel文件</div>
                        <asp:FileUpload ID="FileUpExcel" runat="server" />
                        <div style="margin-top:10px;">
                            <asp:CheckBox ID="CheckBox1" runat="server" Text="密码转换为姓名拼音缩写" 
                                ToolTip="是否在获取数据时自动将密码转换为学生姓名拼音缩写" />
                        </div>
                        <div style="margin-top:12px;">
                            <asp:Button ID="ButtonInsert" runat="server" OnClick="ButtonInsert_Click"
                                Text="上传 Excel" CssClass="btn-primary" ToolTip="上传并导入临时学生表" />
                        </div>
                    </div>
                </div>
                <div class="si-step">
                    <div class="si-step-num disabled">3</div>
                    <div class="si-step-body">
                        <div class="si-step-title">导入到平台</div>
                        <asp:Button ID="ButtonAppend" runat="server" OnClick="ButtonAppend_Click"
                            Text="导入数据" CssClass="btn-primary" Enabled="False"
                            ToolTip="将上传的学生临时表数据导入平台学生表中" />
                    </div>
                </div>
            </div>
            <div id="Loading" style="display:none;">
                <asp:Image ID="Image2" runat="server" ImageUrl="~/images/load2.gif" />
                <input id="Textcmd" style="border-style:none" type="text" />
            </div>
        </div>
    </div>

    <!-- 说明与操作 -->
    <div class="si-card">
        <div class="si-card-hd">
            <span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>
            导入说明
        </div>
        <div class="si-card-bd">
            <div class="si-info">
                <strong>必填字段：</strong>学号、入学年度、年级、班级、姓名、密码、性别<br/>
                <strong>格式要求：</strong>入学年度、年级、班级必须为数字；学号必须为数字且不超过12位<br/><br/>
                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/说明必读/学生导入模板.xls" 
                    Target="_blank">📄 下载学生导入Excel模板</asp:HyperLink>
            </div>
            <div style="margin-top:18px;">
                <asp:Button ID="ButtonClear" runat="server" OnClick="ButtonClear_Click"
                    Text="清除最近导入" CssClass="btn-danger"
                    ToolTip="只删除刚才导入的数据，以方便重新导入！" />
            </div>
            <div style="margin-top:14px;">
                <asp:Label ID="Labelmsg" runat="server" Font-Size="12px" ForeColor="Red"></asp:Label>
            </div>
        </div>
    </div>

    <!-- 重复检验 -->
    <div class="si-card si-full">
        <div class="si-card-hd">
            <span class="ci rose"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
            导入数据检验重复列表
        </div>
        <div class="si-card-bd" style="padding:0;">
            <div class="si-table-wrap">
                <asp:GridView ID="GVrepeat" runat="server" 
                    CellPadding="0" GridLines="None" Width="100%" PageSize="25" 
                    EnableTheming="False" EnableViewState="False"
                    BorderWidth="0" BorderStyle="None" Font-Size="13px">
                    <HeaderStyle CssClass="" />
                    <RowStyle CssClass="" />
                    <AlternatingRowStyle CssClass="" />
                    <PagerStyle CssClass="" />
                </asp:GridView>
            </div>
        </div>
    </div>

    </div>
</div>
</asp:Content>

