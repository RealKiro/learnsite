<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private void LoadTeacher()
    {
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out myHid); }
                }
            }
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadTeacher();
        if (!IsPostBack)
        {
            CreateTableIfNotExists();
            LoadSoftwareList();
        }
    }

    private void CreateTableIfNotExists()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 检查表是否存在，不存在则创建
                string checkTable = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SoftwareDownload]') AND type in (N'U'))
                    BEGIN
                        CREATE TABLE [dbo].[SoftwareDownload](
                            [Sid] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
                            [Sname] [nvarchar](200) NOT NULL,
                            [Sversion] [nvarchar](50) NULL,
                            [Sicon] [nvarchar](500) NULL,
                            [Sdesc] [nvarchar](2000) NULL,
                            [Sdownloadurl] [nvarchar](500) NULL,
                            [Sfilename] [nvarchar](200) NULL,
                            [Sfilesize] [bigint] NULL,
                            [Sdownloads] [int] NULL DEFAULT 0,
                            [Sactive] [bit] NULL DEFAULT 1,
                            [Shid] [int] NULL,
                            [Sdate] [datetime] NULL DEFAULT GETDATE(),
                            [SdownloadurlWin] [nvarchar](500) NULL,
                            [SdownloadurlMac] [nvarchar](500) NULL,
                            [SdownloadurlLinux] [nvarchar](500) NULL,
                            [SfilenameWin] [nvarchar](200) NULL,
                            [SfilenameMac] [nvarchar](200) NULL,
                            [SfilenameLinux] [nvarchar](200) NULL,
                            [SfilesizeWin] [bigint] NULL,
                            [SfilesizeMac] [bigint] NULL,
                            [SfilesizeLinux] [bigint] NULL
                        )
                    END";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(checkTable, conn))
                {
                    cmd.ExecuteNonQuery();
                }
                
                // 检查并添加缺失的列
                string addColumns = @"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[SoftwareDownload]') AND name = 'SdownloadurlWin')
                    BEGIN
                        ALTER TABLE [dbo].[SoftwareDownload] ADD 
                            [SdownloadurlWin] [nvarchar](500) NULL,
                            [SdownloadurlMac] [nvarchar](500) NULL,
                            [SdownloadurlLinux] [nvarchar](500) NULL,
                            [SfilenameWin] [nvarchar](200) NULL,
                            [SfilenameMac] [nvarchar](200) NULL,
                            [SfilenameLinux] [nvarchar](200) NULL,
                            [SfilesizeWin] [bigint] NULL,
                            [SfilesizeMac] [bigint] NULL,
                            [SfilesizeLinux] [bigint] NULL
                    END";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(addColumns, conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex) { pageMsg = "数据库初始化失败: " + ex.Message; }
    }

    private void LoadSoftwareList()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(
                    @"SELECT Sid,Sname,Sversion,Sicon,Sdesc,Sdownloadurl,Sfilename,Sfilesize,Sdownloads,Sactive,Sdate,
                      SdownloadurlWin,SdownloadurlMac,SdownloadurlLinux,SfilenameWin,SfilenameMac,SfilenameLinux,
                      SfilesizeWin,SfilesizeMac,SfilesizeLinux FROM SoftwareDownload ORDER BY Sid DESC", conn);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                RptSoftware.DataSource = dt;
                RptSoftware.DataBind();
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; }
    }

    protected void RptSoftware_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int id = 0; int.TryParse(e.CommandArgument.ToString(), out id);
        if (id <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;

        if (e.CommandName == "Del")
        {
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("DELETE FROM SoftwareDownload WHERE Sid=@id", conn))
                    { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "已删除";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; }
        }
        else if (e.CommandName == "Toggle")
        {
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "UPDATE SoftwareDownload SET Sactive=CASE WHEN ISNULL(Sactive,1)=1 THEN 0 ELSE 1 END WHERE Sid=@id", conn))
                    { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
        }
        LoadSoftwareList();
    }

    protected string FormatFileSize(object sizeObj)
    {
        if (sizeObj == DBNull.Value) return "-";
        long size = Convert.ToInt64(sizeObj);
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return (size / 1024.0).ToString("F2") + " KB";
        if (size < 1024 * 1024 * 1024) return (size / 1024.0 / 1024.0).ToString("F2") + " MB";
        return (size / 1024.0 / 1024.0 / 1024.0).ToString("F2") + " GB";
    }

    protected string GetDownloadButtons(string urlWin, string urlMac, string urlLinux, string urlGeneral)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        bool hasWin = !string.IsNullOrEmpty(urlWin);
        bool hasMac = !string.IsNullOrEmpty(urlMac);
        bool hasLinux = !string.IsNullOrEmpty(urlLinux);
        bool hasGeneral = !string.IsNullOrEmpty(urlGeneral);

        if (hasWin)
        {
            sb.Append("<a href='" + urlWin + "' target='_blank' class='swd-btn swd-btn-sm' title='Windows版本'>");
            sb.Append("<svg viewBox='0 0 24 24'><rect x='2' y='3' width='20' height='14' rx='2' ry='2'/><line x1='8' y1='21' x2='16' y2='21'/><line x1='12' y1='17' x2='12' y2='21'/></svg>");
            sb.Append("Win</a>");
        }
        if (hasMac)
        {
            sb.Append("<a href='" + urlMac + "' target='_blank' class='swd-btn swd-btn-sm' title='macOS版本'>");
            sb.Append("<svg viewBox='0 0 24 24'><rect x='2' y='2' width='20' height='20' rx='2.18' ry='2.18'/><line x1='7' y1='2' x2='7' y2='22'/><line x1='17' y1='2' x2='17' y2='22'/></svg>");
            sb.Append("Mac</a>");
        }
        if (hasLinux)
        {
            sb.Append("<a href='" + urlLinux + "' target='_blank' class='swd-btn swd-btn-sm' title='Linux版本'>");
            sb.Append("<svg viewBox='0 0 24 24'><circle cx='12' cy='12' r='10'/><line x1='2' y1='12' x2='22' y2='12'/></svg>");
            sb.Append("Linux</a>");
        }
        if (hasGeneral && !hasWin && !hasMac && !hasLinux)
        {
            sb.Append("<a href='" + urlGeneral + "' target='_blank' class='swd-btn swd-btn-sm'>");
            sb.Append("<svg viewBox='0 0 24 24'><path d='M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'/><polyline points='7 10 12 15 17 10'/><line x1='12' y1='15' x2='12' y2='3'/></svg>");
            sb.Append("下载</a>");
        }
        return sb.ToString();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .swd-page { max-width: 1600px; width: 100%; margin: 0 auto; }
    .swd-header { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; display: flex; align-items: flex-start; justify-content: space-between; }
    .swd-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .swd-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .swd-title .swd-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#10b981,#34d399); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .swd-title .swd-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .swd-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .swd-header-actions { display: flex; gap: 10px; align-items: flex-start; padding-top: 4px; }
    
    .swd-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; }
    .swd-btn:hover { background: #f8fafc; }
    .swd-btn-primary { background: linear-gradient(135deg,#10b981,#34d399); color: #fff; border-color: #10b981; }
    .swd-btn-primary:hover { background: linear-gradient(135deg,#059669,#10b981); color: #fff; }
    .swd-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swd-btn-sm { padding: 4px 12px; font-size: 12px; }
    .swd-btn-danger { color: #ef4444; border-color: #fecaca; }
    .swd-btn-danger:hover { background: #fef2f2; }
    
    .swd-info-box { background: linear-gradient(135deg, #d1fae5, #a7f3d0); border: 1px solid #6ee7b7; border-radius: 12px; padding: 20px 24px; margin-bottom: 24px; display: flex; align-items: flex-start; gap: 14px; }
    .swd-info-icon { width: 40px; height: 40px; border-radius: 10px; background: linear-gradient(135deg,#10b981,#34d399); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .swd-info-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; }
    .swd-info-content h4 { font-size: 14px; font-weight: 600; color: #065f46; margin: 0 0 8px; }
    .swd-info-content ul { margin: 6px 0 0; padding-left: 16px; font-size: 13px; color: #047857; line-height: 1.8; }
    
    .swd-msg { padding: 10px 16px; border-radius: 8px; background: #d1fae5; border: 1px solid #6ee7b7; color: #065f46; font-size: 13px; margin-bottom: 16px; }
    
    .swd-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; }
    .swd-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); overflow: visible; transition: all .2s; }
    .swd-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,.08); border-color: #6ee7b7; }
    .swd-card-icon { width: 100%; height: 160px; background: linear-gradient(135deg, #f0fdf4, #dcfce7); display: flex; align-items: center; justify-content: center; border-bottom: 1px solid #e8ecf1; position: relative; overflow: hidden; border-radius: 12px 12px 0 0; }
    .swd-card-icon img { max-width: 80%; max-height: 80%; object-fit: contain; }
    .swd-card-icon svg { width: 64px; height: 64px; stroke: #10b981; fill: none; stroke-width: 1.5; }
    .swd-card-status { position: absolute; top: 12px; right: 12px; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
    .swd-card-status-on { background: #dcfce7; color: #16a34a; }
    .swd-card-status-off { background: #fee2e2; color: #dc2626; }
    .swd-card-body { padding: 16px; }
    .swd-card-title { font-size: 15px; font-weight: 600; color: #1e293b; margin-bottom: 4px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
    .swd-card-version { display: inline-block; padding: 2px 8px; background: #f1f5f9; color: #64748b; font-size: 11px; border-radius: 4px; font-weight: 500; }
    .swd-card-desc { font-size: 12px; color: #64748b; line-height: 1.6; margin: 8px 0; min-height: 38px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    .swd-card-meta { display: flex; gap: 16px; margin: 12px 0; padding-top: 12px; border-top: 1px solid #f1f5f9; }
    .swd-card-meta-item { display: flex; align-items: center; gap: 4px; font-size: 11px; color: #94a3b8; }
    .swd-card-meta-item svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swd-card-actions { display: flex; gap: 6px; flex-wrap: wrap; padding-top: 12px; border-top: 1px solid #f1f5f9; margin-top: 12px; }
    .swd-empty { padding: 60px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
</style>

<div class="swd-page">
    <div class="swd-header">
        <div class="swd-title-wrap">
            <div class="swd-title">
                <span class="swd-icon">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                </span>
                软件下载管理
            </div>
            <div class="swd-subtitle">管理教学软件资源，支持上传软件文件和设置下载链接</div>
        </div>
        <div class="swd-header-actions">
            <asp:HyperLink ID="HlkAdd" runat="server" CssClass="swd-btn swd-btn-primary" 
                NavigateUrl="~/teacher/softwaredownloadadd.aspx">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加软件
            </asp:HyperLink>
        </div>
    </div>

    <div class="swd-info-box">
        <div class="swd-info-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        </div>
        <div class="swd-info-content">
            <h4>使用说明</h4>
            <ul>
                <li>点击「添加软件」上传新的软件资源，支持本地文件上传或外部下载链接</li>
                <li>可以为每个软件设置名称、版本号、图标和详细介绍</li>
                <li>通过「发布/隐藏」按钮控制软件是否对学生可见</li>
                <li>系统自动统计软件下载次数，方便了解使用情况</li>
            </ul>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="swd-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <asp:Repeater ID="RptSoftware" runat="server" OnItemCommand="RptSoftware_ItemCommand">
        <HeaderTemplate><div class="swd-grid"></HeaderTemplate>
        <ItemTemplate>
            <div class="swd-card">
                <div class="swd-card-icon">
                    <%# !string.IsNullOrEmpty(Eval("Sicon") as string) ? 
                        "<img src='" + Eval("Sicon") + "' alt='软件图标' />" : 
                        "<svg viewBox='0 0 24 24'><rect x='4' y='4' width='16' height='16' rx='2' ry='2'/><rect x='9' y='9' width='6' height='6'/><line x1='9' y1='1' x2='9' y2='4'/><line x1='15' y1='1' x2='15' y2='4'/><line x1='9' y1='20' x2='9' y2='23'/><line x1='15' y1='20' x2='15' y2='23'/><line x1='20' y1='9' x2='23' y2='9'/><line x1='20' y1='14' x2='23' y2='14'/><line x1='1' y1='9' x2='4' y2='9'/><line x1='1' y1='14' x2='4' y2='14'/></svg>" 
                    %>
                    <span class='<%# Convert.ToBoolean(Eval("Sactive") == DBNull.Value ? true : Eval("Sactive")) ? "swd-card-status swd-card-status-on" : "swd-card-status swd-card-status-off" %>'>
                        <%# Convert.ToBoolean(Eval("Sactive") == DBNull.Value ? true : Eval("Sactive")) ? "已发布" : "已隐藏" %>
                    </span>
                </div>
                <div class="swd-card-body">
                    <div class="swd-card-title">
                        <%# Server.HtmlEncode(Eval("Sname") == DBNull.Value ? "" : Eval("Sname").ToString()) %>
                        <%# !string.IsNullOrEmpty(Eval("Sversion") as string) ? 
                            "<span class='swd-card-version'>" + Eval("Sversion") + "</span>" : "" 
                        %>
                    </div>
                    <div class="swd-card-desc"><%# Server.HtmlEncode(Eval("Sdesc") == DBNull.Value ? "暂无描述" : Eval("Sdesc").ToString()) %></div>
                    <div class="swd-card-meta">
                        <div class="swd-card-meta-item">
                            <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                            <%# Eval("Sdownloads") == DBNull.Value ? 0 : Eval("Sdownloads") %> 次
                        </div>
                        <div class="swd-card-meta-item">
                            <svg viewBox="0 0 24 24"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><polyline points="13 2 13 9 20 9"/></svg>
                            <%# FormatFileSize(Eval("Sfilesize")) %>
                        </div>
                    </div>
                    <div class="swd-card-actions">
                        <%# GetDownloadButtons(
                            Eval("SdownloadurlWin") as string,
                            Eval("SdownloadurlMac") as string,
                            Eval("SdownloadurlLinux") as string,
                            Eval("Sdownloadurl") as string
                        ) %>
                        <asp:HyperLink runat="server" NavigateUrl='<%# "~/teacher/softwaredownloadedit.aspx?id=" + Eval("Sid") %>' CssClass="swd-btn swd-btn-sm" ToolTip="编辑">
                            <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                            编辑
                        </asp:HyperLink>
                        <asp:Button runat="server" Text="切换" CssClass="swd-btn swd-btn-sm"
                            CommandName="Toggle" CommandArgument='<%# Eval("Sid") %>' />
                        <asp:Button runat="server" Text="删除" CssClass="swd-btn swd-btn-sm swd-btn-danger"
                            CommandName="Del" CommandArgument='<%# Eval("Sid") %>'
                            OnClientClick="return confirm('确定要删除该软件吗？');" />
                    </div>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="PnlEmpty" runat="server" Visible="false">
        <div class="swd-empty">暂无软件，请点击上方「添加软件」按钮添加</div>
    </asp:Panel>
</div>

<script type="text/javascript">
    (function(){
        var rpt = document.querySelector('.swd-grid');
        if (!rpt || rpt.children.length === 0) {
            var empty = document.querySelector('.swd-empty');
            if (empty) empty.parentElement.style.display = 'block';
            if (rpt) rpt.style.display = 'none';
        }
    })();
</script>
</asp:Content>
