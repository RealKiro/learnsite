<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_teacheradd, LearnSite" enableeventvalidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (ddlSchool.Items.Count == 0)
        {
            LoadSchools();
        }
    }
    
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
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ta-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .ta-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .ta-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .ta-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .ta-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .ta-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .ta-card{max-width:960px;background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s;}
    .ta-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);}
    .ta-card-hd{padding:16px 24px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .ta-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:#eef2ff;}
    .ta-card-hd .ci svg{width:19px;height:19px;stroke:#6366f1;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ta-card-bd{padding:24px;}
    .ta-form{display:flex;flex-direction:column;gap:18px;}
    .ta-field{display:flex;flex-direction:column;gap:6px;}
    .ta-field label{font-size:13px;font-weight:600;color:#374151;}
    .ta-field .ta-hint{font-size:12px;color:#94a3b8;font-weight:400;margin-top:-2px;}
    .ta-field input[type="text"],.ta-field textarea{width:100%;padding:9px 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;color:#1e293b;background:#f8fafc;transition:border-color .2s,box-shadow .2s;outline:none;box-sizing:border-box;}
    .ta-field input[type="text"]:focus,.ta-field textarea:focus{border-color:#818cf8;box-shadow:0 0 0 3px rgba(99,102,241,.12);background:#fff;}
    .ta-field textarea{min-height:80px;resize:vertical;}
    .ta-check{display:flex;align-items:center;gap:8px;padding:12px 16px;background:#faf5ff;border:1px solid #e9d5ff;border-radius:10px;}
    .ta-check input[type="checkbox"]{width:18px;height:18px;accent-color:#7c3aed;cursor:pointer;}
    .ta-check label{font-size:13px;color:#6b21a8;font-weight:500;cursor:pointer;user-select:none;}
    .ta-check-hint{font-size:12px;color:#a78bfa;margin-top:4px;padding-left:26px;}
    .ta-actions{display:flex;align-items:center;gap:10px;padding-top:6px;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;height:38px;padding:0 24px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(99,102,241,.3);}
    .btn-primary:hover{box-shadow:0 4px 16px rgba(99,102,241,.4);transform:translateY(-1px);}
    .btn-back{display:inline-flex;align-items:center;justify-content:center;height:38px;padding:0 24px;background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;}
    .btn-back:hover{background:#e2e8f0;color:#334155;border-color:#cbd5e1;}
    .ta-msg{margin-top:16px;font-size:13px;}
    .ta-tip{margin-top:20px;background:#f0f9ff;border:1px solid #bae6fd;border-radius:10px;padding:14px 18px;font-size:12.5px;color:#0369a1;line-height:1.8;}
    .ta-tip strong{color:#0c4a6e;}
</style>

<div class="ta-page">
    <div class="ta-hd">
        <div class="ta-hd-icon"><svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg></div>
        <div class="ta-hd-text"><h1>添加教师</h1><p>创建新的教师账号并分配权限</p></div>
    </div>

    <div class="ta-card">
        <div class="ta-card-hd">
            <span class="ci"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            教师信息
        </div>
        <div class="ta-card-bd">
            <div class="ta-form">
                <div class="ta-field">
                    <label>账号</label>
                    <div class="ta-hint">教师登录平台时使用的唯一标识，建议使用姓名拼音或工号</div>
                    <asp:TextBox ID="Texthname" runat="server" CssClass="" placeholder="例如：zhangsan 或 T001"></asp:TextBox>
                </div>
                <div class="ta-field">
                    <label>昵称</label>
                    <div class="ta-hint">教师的显示名称，将在平台各处展示</div>
                    <asp:TextBox ID="Texthnick" runat="server" CssClass="" placeholder="例如：张老师"></asp:TextBox>
                </div>
                <div class="ta-field">
                    <label>密码</label>
                    <div class="ta-hint">初始登录密码，教师登录后可自行修改</div>
                    <asp:TextBox ID="Texthpwd" runat="server" CssClass="" placeholder="请设置初始密码"></asp:TextBox>
                </div>
                <div class="ta-field">
                    <label>所属学校</label>
                    <div class="ta-hint">选择教师所属的校区，留空则不设置</div>
                    <asp:DropDownList ID="ddlSchool" runat="server" CssClass="" 
                        style="width:100%;padding:9px 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13px;color:#1e293b;background:#f8fafc;cursor:pointer;transition:all .2s;outline:none;">
                    </asp:DropDownList>
                </div>
                <div class="ta-check">
                    <asp:CheckBox ID="Ckhpermiss" runat="server" Text="设置为管理员" />
                    <div class="ta-check-hint">勾选后该教师将拥有后台管理权限</div>
                </div>
                <div class="ta-field">
                    <label>备注</label>
                    <div class="ta-hint">可填写任课科目、联系方式等附加信息</div>
                    <asp:TextBox ID="Texthnote" runat="server" TextMode="MultiLine" CssClass="" placeholder="选填，例如：信息技术教师，负责三年级"></asp:TextBox>
                </div>
                <div class="ta-actions">
                    <asp:Button ID="Btnadd" runat="server" Text="确认添加" CssClass="btn-primary" onclick="Btnadd_Click" />
                    <asp:Button ID="Btnreturn" runat="server" Text="返回" CssClass="btn-back" onclick="Btnreturn_Click" />
                </div>
            </div>
            <div class="ta-msg">
                <asp:Label ID="Labelmsg" runat="server" ForeColor="Red"></asp:Label>
            </div>
            <div class="ta-tip">
                <strong>提示：</strong>添加成功后，教师即可使用账号和密码登录平台。教师默认拥有教学管理权限（布置作业、查看学生作品等），如需后台管理权限请勾选「设置为管理员」。
            </div>
        </div>
    </div>
</div>
</asp:Content>

