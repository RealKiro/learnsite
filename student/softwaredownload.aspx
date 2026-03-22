<%@ Page Title="" Language="C#" MasterPageFile="~/student/Stud.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
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

    private void LoadStudent()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.StuCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { sc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out mySid); }
                }
            }
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadStudent();
        if (!IsPostBack) LoadSoftwareList();
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
                    @"SELECT Sid,Sname,Sversion,Sicon,Sdesc,Sdownloadurl,Sfilename,Sfilesize,Sdownloads,
                      SdownloadurlWin,SdownloadurlMac,SdownloadurlLinux,SfilenameWin,SfilenameMac,SfilenameLinux,
                      SfilesizeWin,SfilesizeMac,SfilesizeLinux,Sdate 
                      FROM SoftwareDownload WHERE Sactive=1 ORDER BY Sid DESC", conn);
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
        if (e.CommandName == "Download")
        {
            int id = 0; int.TryParse(e.CommandArgument.ToString(), out id);
            if (id <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "UPDATE SoftwareDownload SET Sdownloads=ISNULL(Sdownloads,0)+1 WHERE Sid=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }
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

    protected string GetDownloadButtons(int sid, string urlWin, string urlMac, string urlLinux, string urlGeneral)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        bool hasWin = !string.IsNullOrEmpty(urlWin);
        bool hasMac = !string.IsNullOrEmpty(urlMac);
        bool hasLinux = !string.IsNullOrEmpty(urlLinux);
        bool hasGeneral = !string.IsNullOrEmpty(urlGeneral);

        if (hasWin)
        {
            sb.Append("<a href='" + ResolveUrl(urlWin) + "' target='_blank' class='swd-btn swd-btn-download' onclick='recordDownload(" + sid + ")' title='Windows版本'>");
            sb.Append("<svg viewBox='0 0 24 24'><rect x='2' y='3' width='20' height='14' rx='2' ry='2'/><line x1='8' y1='21' x2='16' y2='21'/><line x1='12' y1='17' x2='12' y2='21'/></svg>");
            sb.Append("Windows</a>");
        }
        if (hasMac)
        {
            sb.Append("<a href='" + ResolveUrl(urlMac) + "' target='_blank' class='swd-btn swd-btn-download' onclick='recordDownload(" + sid + ")' title='macOS版本'>");
            sb.Append("<svg viewBox='0 0 24 24'><rect x='2' y='2' width='20' height='20' rx='2.18' ry='2.18'/><line x1='7' y1='2' x2='7' y2='22'/><line x1='17' y1='2' x2='17' y2='22'/></svg>");
            sb.Append("macOS</a>");
        }
        if (hasLinux)
        {
            sb.Append("<a href='" + ResolveUrl(urlLinux) + "' target='_blank' class='swd-btn swd-btn-download' onclick='recordDownload(" + sid + ")' title='Linux版本'>");
            sb.Append("<svg viewBox='0 0 24 24'><circle cx='12' cy='12' r='10'/><line x1='2' y1='12' x2='22' y2='12'/></svg>");
            sb.Append("Linux</a>");
        }
        if (hasGeneral && !hasWin && !hasMac && !hasLinux)
        {
            sb.Append("<a href='" + ResolveUrl(urlGeneral) + "' target='_blank' class='swd-btn swd-btn-download' onclick='recordDownload(" + sid + ")'>");
            sb.Append("<svg viewBox='0 0 24 24'><path d='M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'/><polyline points='7 10 12 15 17 10'/><line x1='12' y1='15' x2='12' y2='3'/></svg>");
            sb.Append("立即下载</a>");
        }
        return sb.ToString();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">
<style>
    .swd-page { max-width: 1400px; width: 100%; margin: 0 auto; padding: 20px; }
    .swd-header { margin-bottom: 32px; text-align: center; }
    .swd-title { font-size: 32px; font-weight: 700; color: #1e293b; margin-bottom: 12px; display: flex; align-items: center; justify-content: center; gap: 16px; }
    .swd-title .swd-icon { width: 48px; height: 48px; background: linear-gradient(135deg,#10b981,#34d399); border-radius: 12px; display: flex; align-items: center; justify-content: center; }
    .swd-title .swd-icon svg { width: 28px; height: 28px; stroke: #fff; fill: none; stroke-width: 2; }
    .swd-subtitle { font-size: 16px; color: #64748b; line-height: 1.6; }

    .swd-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 24px; }
    .swd-card { background: #fff; border-radius: 16px; border: 1px solid #e8ecf1; box-shadow: 0 2px 8px rgba(0,0,0,.06); overflow: visible; transition: all .3s; }
    .swd-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(16,185,129,.15); border-color: #6ee7b7; }
    .swd-card-icon { width: 100%; height: 180px; background: linear-gradient(135deg, #f0fdf4, #dcfce7); display: flex; align-items: center; justify-content: center; border-bottom: 1px solid #e8ecf1; position: relative; overflow: hidden; border-radius: 16px 16px 0 0; }
    .swd-card-icon img { max-width: 70%; max-height: 70%; object-fit: contain; }
    .swd-card-icon svg { width: 72px; height: 72px; stroke: #10b981; fill: none; stroke-width: 1.5; }
    .swd-card-body { padding: 20px; }
    .swd-card-title { font-size: 18px; font-weight: 600; color: #1e293b; margin-bottom: 6px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .swd-card-version { display: inline-block; padding: 3px 10px; background: linear-gradient(135deg,#eef2ff,#e0e7ff); color: #4f46e5; font-size: 12px; border-radius: 6px; font-weight: 600; }
    .swd-card-desc { font-size: 14px; color: #64748b; line-height: 1.7; margin: 12px 0; min-height: 48px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    .swd-card-meta { display: flex; gap: 20px; margin: 16px 0; padding: 12px 0; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; }
    .swd-card-meta-item { display: flex; align-items: center; gap: 6px; font-size: 13px; color: #94a3b8; }
    .swd-card-meta-item svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swd-card-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 16px; }
    .swd-btn { display: inline-flex; align-items: center; gap: 8px; padding: 10px 20px; border-radius: 10px; font-size: 14px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .2s; text-decoration: none; font-family: inherit; }
    .swd-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .swd-btn-download { background: linear-gradient(135deg,#10b981,#34d399); color: #fff; border-color: #10b981; box-shadow: 0 2px 8px rgba(16,185,129,.2); }
    .swd-btn-download:hover { background: linear-gradient(135deg,#059669,#10b981); box-shadow: 0 4px 12px rgba(16,185,129,.3); transform: translateY(-1px); color: #fff; }
    .swd-btn svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swd-empty { padding: 80px 20px; text-align: center; }
    .swd-empty-icon { width: 80px; height: 80px; margin: 0 auto 20px; opacity: 0.3; }
    .swd-empty-icon svg { width: 100%; height: 100%; stroke: #94a3b8; fill: none; stroke-width: 1.5; }
    .swd-empty-text { font-size: 16px; color: #94a3b8; }
    .swd-msg { padding: 12px 20px; border-radius: 10px; background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; font-size: 14px; margin-bottom: 24px; text-align: center; }
</style>

<div class="swd-page">
    <div class="swd-header">
        <div class="swd-title">
            <span class="swd-icon">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            </span>
            软件下载中心
        </div>
        <div class="swd-subtitle">为你提供优质的教学软件资源，支持 Windows、macOS、Linux 多平台下载</div>
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
                        "<img src='" + ResolveUrl(Eval("Sicon").ToString()) + "' alt='软件图标' />" : 
                        "<svg viewBox='0 0 24 24'><rect x='4' y='4' width='16' height='16' rx='2' ry='2'/><rect x='9' y='9' width='6' height='6'/><line x1='9' y1='1' x2='9' y2='4'/><line x1='15' y1='1' x2='15' y2='4'/><line x1='9' y1='20' x2='9' y2='23'/><line x1='15' y1='20' x2='15' y2='23'/><line x1='20' y1='9' x2='23' y2='9'/><line x1='20' y1='14' x2='23' y2='14'/><line x1='1' y1='9' x2='4' y2='9'/><line x1='1' y1='14' x2='4' y2='14'/></svg>" 
                    %>
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
                            <%# Eval("Sdownloads") == DBNull.Value ? 0 : Eval("Sdownloads") %> 次下载
                        </div>
                        <div class="swd-card-meta-item">
                            <svg viewBox="0 0 24 24"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><polyline points="13 2 13 9 20 9"/></svg>
                            <%# FormatFileSize(Eval("Sfilesize")) %>
                        </div>
                    </div>
                    <div class="swd-card-actions">
                        <%# GetDownloadButtons(
                            Convert.ToInt32(Eval("Sid")),
                            Eval("SdownloadurlWin") as string,
                            Eval("SdownloadurlMac") as string,
                            Eval("SdownloadurlLinux") as string,
                            Eval("Sdownloadurl") as string
                        ) %>
                    </div>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="PnlEmpty" runat="server" Visible="false">
        <div class="swd-empty">
            <div class="swd-empty-icon">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            </div>
            <div class="swd-empty-text">暂无可下载的软件</div>
        </div>
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

    function recordDownload(sid) {
        // 异步记录下载次数
        setTimeout(function() {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'softwaredownload.aspx', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.send('action=download&sid=' + sid);
        }, 100);
    }
</script>
</asp:Content>
