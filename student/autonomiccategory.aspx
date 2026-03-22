<%@ Page Language="C#" MasterPageFile="~/student/Stud.master" StylesheetTheme="Student" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack) LoadData();
}

private string GetConnectionString()
{
    string cs = null;
    try
    {
        Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
        if (dbType != null)
        {
            System.Reflection.FieldInfo connField = dbType.GetField("connectionString", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
            if (connField != null) cs = connField.GetValue(null) as string;
        }
    }
    catch { }
    if (string.IsNullOrEmpty(cs))
    {
        try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
    }
    return cs;
}

private void LoadData()
{
    string yid = Request.QueryString["yid"];
    if (string.IsNullOrEmpty(yid)) { LabelMessage.Text = "请提供分类ID参数"; return; }
    
    try
    {
        string connStr = GetConnectionString();
        if (string.IsNullOrEmpty(connStr)) { LabelMessage.Text = "无法获取数据库连接"; return; }
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sqlCategory = "SELECT Ytitle FROM AutonomicCategory WHERE Yid=@yid";
            using (SqlCommand cmd = new SqlCommand(sqlCategory, conn))
            {
                cmd.Parameters.AddWithValue("@yid", yid);
                object result = cmd.ExecuteScalar();
                if (result != null) LabelCategoryName.Text = result.ToString();
            }
            
            string sqlWorks = "SELECT Aid, Aname, Adate, Aurl, Atype, Ascore, Agood FROM Autonomic WHERE Ayid=@yid ORDER BY Aid DESC";
            using (SqlCommand cmd = new SqlCommand(sqlWorks, conn))
            {
                cmd.Parameters.AddWithValue("@yid", yid);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                if (dt.Rows.Count > 0)
                {
                    dt.Columns.Add("RowNum", typeof(int));
                    for (int i = 0; i < dt.Rows.Count; i++) dt.Rows[i]["RowNum"] = i + 1;
                    GridView1.DataSource = dt;
                    GridView1.DataBind();
                    LabelMessage.Text = "";
                }
                else { LabelMessage.Text = "该分类下暂无作品"; }
            }
            
            string sqlGood = "SELECT TOP 10 Aid, Aurl, Aname FROM Autonomic WHERE Agood=1 ORDER BY Aid DESC";
            using (SqlCommand cmd = new SqlCommand(sqlGood, conn))
            {
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                if (dt.Rows.Count > 0) { RepGood.DataSource = dt; RepGood.DataBind(); }
            }
        }
    }
    catch (Exception ex) { LabelMessage.Text = "加载数据出错: " + ex.Message; }
}

protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
{
    GridView1.PageIndex = e.NewPageIndex;
    LoadData();
}

protected string GetFileTypeIcon(object type)
{
    if (type == null || type == DBNull.Value) return "~/images/filetype/file.gif";
    string t = type.ToString().ToLower();
    if (t.Contains("scratch")) return "~/images/filetype/scratch.gif";
    if (t.Contains("python")) return "~/images/filetype/python.gif";
    if (t.Contains("html")) return "~/images/filetype/html.gif";
    return "~/images/filetype/file.gif";
}

protected string GetWorkUrl(object url)
{
    if (url == null || url == DBNull.Value) return "#";
    return url.ToString();
}
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">
<style>
.ac-page{width:100%;max-width:1400px;margin:0 auto;padding:20px;font-family:'Microsoft YaHei',Arial,sans-serif}
.ac-layout{display:grid;grid-template-columns:1fr 360px;gap:24px;align-items:start}
.ac-card{background:#fff;border-radius:12px;border:1px solid #e5e7eb;box-shadow:0 2px 8px rgba(0,0,0,.08);margin-bottom:20px;overflow:hidden}
.ac-card-header{display:flex;align-items:center;gap:12px;padding:20px 24px;background:linear-gradient(135deg,#f0fdf4,#dcfce7);border-bottom:2px solid #bbf7d0}
.ac-card-icon{width:40px;height:40px;border-radius:10px;background:linear-gradient(135deg,#86efac,#4ade80);display:flex;align-items:center;justify-content:center;color:#fff;font-size:20px}
.ac-card-title{font-size:18px;font-weight:700;color:#166534;margin:0;flex:1}
.ac-card-body{padding:24px}
.ac-card-body table{width:100%;border-collapse:collapse}
.ac-card-body table th{background:#f8fafc;color:#475569;font-weight:600;padding:12px 16px;text-align:left;border-bottom:2px solid #e2e8f0;font-size:14px}
.ac-card-body table td{padding:14px 16px;border-bottom:1px solid #f1f5f9;color:#334155;font-size:14px}
.ac-card-body table tr:hover{background:#f8fafc}
.ac-card-body table a{color:#2563eb;text-decoration:none;font-weight:500}
.ac-card-body table a:hover{color:#1d4ed8;text-decoration:underline}
.ac-card-body table img{vertical-align:middle}
.ac-message{text-align:center;padding:40px;color:#94a3b8;font-size:14px}
.ac-sidebar{position:sticky;top:20px}
.ac-sidebar-card{background:#fff;border-radius:12px;border:1px solid #e5e7eb;box-shadow:0 2px 8px rgba(0,0,0,.08);overflow:hidden;margin-bottom:20px}
.ac-sidebar-header{padding:16px 20px;background:linear-gradient(135deg,#fef3c7,#fde68a);border-bottom:2px solid #fcd34d}
.ac-sidebar-title{font-size:16px;font-weight:700;color:#92400e;margin:0}
.ac-sidebar-title::before{content:'⭐ '}
.ac-sidebar-body{padding:16px 20px;max-height:500px;overflow-y:auto}
.ac-sidebar-body ul{list-style:none;margin:0;padding:0}
.ac-sidebar-body li{padding:10px 0;border-bottom:1px solid #f1f5f9}
.ac-sidebar-body li:hover{background:#f8fafc;margin:0 -12px;padding:10px 12px}
.ac-sidebar-body li a{color:#334155;text-decoration:none;font-size:14px}
.ac-sidebar-body li a:hover{color:#16a34a}
.ac-btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:12px 28px;background:linear-gradient(135deg,#16a34a,#22c55e);color:#fff!important;border-radius:10px;text-decoration:none!important;font-weight:600;font-size:14px;box-shadow:0 2px 8px rgba(22,163,74,.25);width:100%}
.ac-btn:hover{background:linear-gradient(135deg,#15803d,#16a34a);transform:translateY(-2px)}
.ac-btn::before{content:'🎨 '}
.ac-pager{display:flex;align-items:center;justify-content:center;gap:8px;padding:20px;background:#f8fafc}
.ac-pager a{padding:8px 16px;border-radius:6px;font-size:14px;color:#475569;background:#fff;border:1px solid #e2e8f0;text-decoration:none}
.ac-pager a:hover{background:#16a34a;color:#fff}
@media(max-width:1024px){.ac-layout{grid-template-columns:1fr}}
</style>

<div class="ac-page">
<div class="ac-layout">
<div class="ac-main">
<div class="ac-card">
<div class="ac-card-header">
<div class="ac-card-icon">🏠</div>
<h3 class="ac-card-title"><asp:Label ID="LabelCategoryName" runat="server" Text="资源分类"></asp:Label></h3>
</div>
<div class="ac-card-body">
<asp:Label ID="LabelMessage" runat="server" CssClass="ac-message"></asp:Label>
<asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" Width="100%" AllowPaging="True" PageSize="20" OnPageIndexChanging="GridView1_PageIndexChanging" GridLines="None" ShowHeader="True">
<Columns>
<asp:BoundField DataField="RowNum" HeaderText="序号" ItemStyle-Width="60px" ItemStyle-HorizontalAlign="Center"/>
<asp:TemplateField ItemStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
<ItemTemplate><asp:Image runat="server" ImageUrl='<%#GetFileTypeIcon(Eval("Atype"))%>' Width="24" Height="24"/></ItemTemplate>
</asp:TemplateField>
<asp:TemplateField HeaderText="作品">
<ItemTemplate><asp:HyperLink runat="server" NavigateUrl='<%#GetWorkUrl(Eval("Aurl"))%>' Text='<%#Eval("Aname")%>' Target="_blank"></asp:HyperLink></ItemTemplate>
<ItemStyle HorizontalAlign="Left"/>
</asp:TemplateField>
<asp:BoundField DataField="Ascore" HeaderText="学分" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center"/>
<asp:TemplateField HeaderText="姓名" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center">
<ItemTemplate><asp:Label runat="server" Text='<%#HttpUtility.UrlDecode(Eval("Aname").ToString())%>'></asp:Label></ItemTemplate>
</asp:TemplateField>
<asp:TemplateField HeaderText="日期" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
<ItemTemplate><asp:Label runat="server" Text='<%#Eval("Adate","{0:yyyy-MM-dd}")%>'></asp:Label></ItemTemplate>
</asp:TemplateField>
</Columns>
<PagerStyle CssClass="ac-pager"/>
</asp:GridView>
</div>
</div>
</div>
<div class="ac-sidebar">
<div class="ac-sidebar-card">
<div class="ac-sidebar-header">
<h3 class="ac-sidebar-title">优秀作品榜</h3>
</div>
<div class="ac-sidebar-body">
<ul>
<asp:Repeater ID="RepGood" runat="server">
<ItemTemplate>
<li><a href='<%#GetWorkUrl(Eval("Aurl"))%>' target="_blank"><%#HttpUtility.UrlDecode(Eval("Aname").ToString())%></a></li>
</ItemTemplate>
</asp:Repeater>
</ul>
</div>
</div>
<asp:HyperLink runat="server" CssClass="ac-btn" NavigateUrl="~/student/autonomic.aspx" Target="_self">在线资源</asp:HyperLink>
</div>
</div>
</div>
</asp:Content>
