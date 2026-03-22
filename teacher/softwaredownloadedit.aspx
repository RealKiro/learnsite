<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected int editId = 0;

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
            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int.TryParse(Request.QueryString["id"], out editId);
                if (editId > 0) LoadSoftwareData();
            }
            else
            {
                Response.Redirect("~/teacher/softwaredownload.aspx");
            }
        }
    }

    private void LoadSoftwareData()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    @"SELECT Sid,Sname,Sversion,Sicon,Sdesc,Sdownloadurl,SdownloadurlWin,SdownloadurlMac,SdownloadurlLinux 
                      FROM SoftwareDownload WHERE Sid=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", editId);
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            TxtName.Text = dr["Sname"] == DBNull.Value ? "" : dr["Sname"].ToString();
                            TxtVersion.Text = dr["Sversion"] == DBNull.Value ? "" : dr["Sversion"].ToString();
                            TxtIcon.Text = dr["Sicon"] == DBNull.Value ? "" : dr["Sicon"].ToString();
                            TxtDesc.Text = dr["Sdesc"] == DBNull.Value ? "" : dr["Sdesc"].ToString();
                            TxtDownloadUrl.Text = dr["Sdownloadurl"] == DBNull.Value ? "" : dr["Sdownloadurl"].ToString();
                            TxtDownloadUrlWin.Text = dr["SdownloadurlWin"] == DBNull.Value ? "" : dr["SdownloadurlWin"].ToString();
                            TxtDownloadUrlMac.Text = dr["SdownloadurlMac"] == DBNull.Value ? "" : dr["SdownloadurlMac"].ToString();
                            TxtDownloadUrlLinux.Text = dr["SdownloadurlLinux"] == DBNull.Value ? "" : dr["SdownloadurlLinux"].ToString();
                        }
                        else
                        {
                            pageMsg = "软件不存在";
                        }
                    }
                }
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; }
    }

    protected void BtnUpdate_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            int.TryParse(Request.QueryString["id"], out editId);
        }
        if (editId <= 0) { pageMsg = "无效的软件ID"; return; }

        string name = TxtName.Text.Trim();
        if (string.IsNullOrEmpty(name)) { pageMsg = "请输入软件名称"; return; }

        string iconPath = TxtIcon.Text.Trim();
        string downloadUrl = TxtDownloadUrl.Text.Trim();
        string downloadUrlWin = TxtDownloadUrlWin.Text.Trim();
        string downloadUrlMac = TxtDownloadUrlMac.Text.Trim();
        string downloadUrlLinux = TxtDownloadUrlLinux.Text.Trim();

        // 处理图标上传
        if (FileUploadIcon.HasFile)
        {
            try
            {
                string iconFileName = FileUploadIcon.FileName;
                string iconFileExt = System.IO.Path.GetExtension(iconFileName).ToLower();
                if (iconFileExt != ".jpg" && iconFileExt != ".jpeg" && iconFileExt != ".png" && iconFileExt != ".gif")
                { pageMsg = "图标只支持 JPG、PNG、GIF 格式"; return; }
                if (FileUploadIcon.PostedFile.ContentLength > 2 * 1024 * 1024)
                { pageMsg = "图标大小不能超过 2MB"; return; }
                string newIconName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + iconFileExt;
                string uploadFolder = Server.MapPath("~/images/software/");
                if (!System.IO.Directory.Exists(uploadFolder)) System.IO.Directory.CreateDirectory(uploadFolder);
                string iconFilePath = System.IO.Path.Combine(uploadFolder, newIconName);
                FileUploadIcon.SaveAs(iconFilePath);
                iconPath = "~/images/software/" + newIconName;
            }
            catch (Exception ex) { pageMsg = "图标上传失败: " + ex.Message; return; }
        }

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    @"UPDATE SoftwareDownload SET Sname=@name,Sversion=@version,Sicon=@icon,Sdesc=@desc,
                      Sdownloadurl=@url,SdownloadurlWin=@urlWin,SdownloadurlMac=@urlMac,SdownloadurlLinux=@urlLinux 
                      WHERE Sid=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@version", TxtVersion.Text.Trim());
                    cmd.Parameters.AddWithValue("@icon", iconPath);
                    cmd.Parameters.AddWithValue("@desc", TxtDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@url", downloadUrl);
                    cmd.Parameters.AddWithValue("@urlWin", downloadUrlWin);
                    cmd.Parameters.AddWithValue("@urlMac", downloadUrlMac);
                    cmd.Parameters.AddWithValue("@urlLinux", downloadUrlLinux);
                    cmd.Parameters.AddWithValue("@id", editId);
                    cmd.ExecuteNonQuery();
                }
            }
            Response.Redirect("~/teacher/softwaredownload.aspx");
        }
        catch (Exception ex) { pageMsg = "更新失败: " + ex.Message; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .swde-page { max-width: 1200px; width: 100%; margin: 0 auto; }
    .swde-header { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .swde-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .swde-title .swde-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#f59e0b,#fbbf24); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .swde-title .swde-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .swde-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .swde-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; }
    .swde-main-tabs { display: flex; border-bottom: 2px solid #e8ecf1; margin-bottom: 0; background: #fafbfc; border-radius: 12px 12px 0 0; overflow: hidden; }
    .swde-main-tab { flex: 1; padding: 16px 24px; border: none; background: transparent; color: #64748b; font-size: 14px; font-weight: 500; cursor: pointer; border-bottom: 3px solid transparent; transition: all .2s; display: flex; align-items: center; justify-content: center; gap: 10px; position: relative; }
    .swde-main-tab:hover { color: #334155; background: #f1f5f9; }
    .swde-main-tab.active { color: #f59e0b; border-bottom-color: #f59e0b; background: #fff; font-weight: 600; }
    .swde-main-tab svg { width: 20px; height: 20px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swde-main-tab-content { display: none; padding: 32px; background: #fff; }
    .swde-main-tab-content.active { display: block; }
    .swde-sub-tabs { display: flex; border-bottom: 2px solid #f1f5f9; margin-bottom: 24px; gap: 4px; }
    .swde-sub-tab { padding: 10px 20px; border: none; background: transparent; color: #64748b; font-size: 13px; font-weight: 500; cursor: pointer; border-bottom: 2px solid transparent; transition: all .2s; display: flex; align-items: center; gap: 8px; border-radius: 6px 6px 0 0; }
    .swde-sub-tab:hover { color: #334155; background: #f8fafc; }
    .swde-sub-tab.active { color: #f59e0b; border-bottom-color: #f59e0b; background: #fffbeb; }
    .swde-sub-tab svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swde-sub-tab-content { display: none; }
    .swde-sub-tab-content.active { display: block; }
    .swde-form-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 20px; }
    .swde-form-group label { font-size: 13px; font-weight: 600; color: #475569; }
    .swde-form-group label .required { color: #ef4444; margin-left: 2px; }
    .swde-form-group input, .swde-form-group textarea { padding: 10px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; font-family: inherit; }
    .swde-form-group input:focus, .swde-form-group textarea:focus { border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,.1); }
    .swde-form-group textarea { resize: vertical; min-height: 80px; }
    .swde-form-group small { font-size: 11px; color: #94a3b8; margin-top: 2px; }
    .swde-file-upload { padding: 10px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; width: 100%; cursor: pointer; }
    .swde-file-upload::-webkit-file-upload-button { padding: 6px 12px; border-radius: 6px; border: 1px solid #e2e8f0; background: #f8fafc; color: #475569; font-size: 12px; cursor: pointer; margin-right: 10px; }
    .swde-file-upload::-webkit-file-upload-button:hover { background: #f1f5f9; }
    .swde-btn { display: inline-flex; align-items: center; gap: 6px; padding: 10px 24px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; }
    .swde-btn:hover { background: #f8fafc; }
    .swde-btn-primary { background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff; border-color: #f59e0b; }
    .swde-btn-primary:hover { background: linear-gradient(135deg,#d97706,#f59e0b); color: #fff; }
    .swde-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swde-actions { display: flex; gap: 12px; padding: 24px 32px 24px 52px; border-top: 1px solid #f1f5f9; margin-top: 24px; margin-left: -32px; margin-right: -32px; border-radius: 0 0 12px 12px; }
    .swde-msg { padding: 12px 16px; border-radius: 8px; background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; font-size: 13px; margin-bottom: 20px; }
    .swde-tip { background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px; font-size: 12px; color: #92400e; line-height: 1.6; }
</style>

<div class="swde-page">
    <div class="swde-header">
        <div class="swde-title">
            <span class="swde-icon">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
            </span>
            编辑软件
        </div>
        <div class="swde-subtitle">修改软件信息和下载设置</div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="swde-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <div class="swde-card">
        <div class="swde-main-tabs">
            <button type="button" class="swde-main-tab active" onclick="switchMainTab(event, 'main-tab-basic')">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                基本信息
            </button>
            <button type="button" class="swde-main-tab" onclick="switchMainTab(event, 'main-tab-icon')">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                软件图标
            </button>
            <button type="button" class="swde-main-tab" onclick="switchMainTab(event, 'main-tab-download')">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                下载设置
            </button>
        </div>

        <!-- 基本信息 Tab -->
        <div id="main-tab-basic" class="swde-main-tab-content active">
            <div class="swde-form-group">
                <label>软件名称<span class="required">*</span></label>
                <asp:TextBox ID="TxtName" runat="server" MaxLength="200" placeholder="如：Visual Studio Code" />
            </div>
            <div class="swde-form-group">
                <label>版本号</label>
                <asp:TextBox ID="TxtVersion" runat="server" MaxLength="50" placeholder="如：1.85.0" />
                <small>可选，用于标识软件版本</small>
            </div>
            <div class="swde-form-group">
                <label>软件描述</label>
                <asp:TextBox ID="TxtDesc" runat="server" MaxLength="2000" TextMode="MultiLine" Rows="6" placeholder="请输入软件的详细介绍..." />
            </div>
        </div>

        <!-- 软件图标 Tab -->
        <div id="main-tab-icon" class="swde-main-tab-content">
            <div class="swde-tip">
                <strong>提示：</strong>可以输入图标的网络地址，或者上传本地图标文件。如果上传新图标，将替换原有图标。
            </div>
            <div class="swde-form-group">
                <label>图标URL</label>
                <asp:TextBox ID="TxtIcon" runat="server" MaxLength="500" placeholder="如：https://example.com/icon.png" />
                <small>可以输入图标的网络地址</small>
            </div>
            <div class="swde-form-group">
                <label>或上传新图标（JPG/PNG/GIF，最大2MB）</label>
                <asp:FileUpload ID="FileUploadIcon" runat="server" CssClass="swde-file-upload" accept="image/*" />
                <small>上传新图标将替换原有图标</small>
            </div>
        </div>

        <!-- 下载设置 Tab -->
        <div id="main-tab-download" class="swde-main-tab-content">
            <div class="swde-tip">
                <strong>提示：</strong>可以修改不同操作系统的下载地址。留空表示该平台不提供下载。
            </div>
            <div class="swde-sub-tabs">
                <button type="button" class="swde-sub-tab active" onclick="switchSubTab(event, 'sub-tab-general')">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    通用版本
                </button>
                <button type="button" class="swde-sub-tab" onclick="switchSubTab(event, 'sub-tab-windows')">
                    <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    Windows
                </button>
                <button type="button" class="swde-sub-tab" onclick="switchSubTab(event, 'sub-tab-macos')">
                    <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"/><line x1="7" y1="2" x2="7" y2="22"/><line x1="17" y1="2" x2="17" y2="22"/></svg>
                    macOS
                </button>
                <button type="button" class="swde-sub-tab" onclick="switchSubTab(event, 'sub-tab-linux')">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>
                    Linux
                </button>
            </div>
            <div id="sub-tab-general" class="swde-sub-tab-content active">
                <div class="swde-form-group">
                    <label>下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrl" runat="server" MaxLength="500" placeholder="如：https://example.com/software.exe" />
                    <small>通用版本下载地址</small>
                </div>
            </div>
            <div id="sub-tab-windows" class="swde-sub-tab-content">
                <div class="swde-form-group">
                    <label>Windows 下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrlWin" runat="server" MaxLength="500" placeholder="如：https://example.com/software-win.exe" />
                    <small>Windows 平台专用下载地址</small>
                </div>
            </div>
            <div id="sub-tab-macos" class="swde-sub-tab-content">
                <div class="swde-form-group">
                    <label>macOS 下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrlMac" runat="server" MaxLength="500" placeholder="如：https://example.com/software-mac.dmg" />
                    <small>macOS 平台专用下载地址</small>
                </div>
            </div>
            <div id="sub-tab-linux" class="swde-sub-tab-content">
                <div class="swde-form-group">
                    <label>Linux 下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrlLinux" runat="server" MaxLength="500" placeholder="如：https://example.com/software-linux.tar.gz" />
                    <small>Linux 平台专用下载地址</small>
                </div>
            </div>
        </div>

        <div class="swde-actions">
            <asp:Button ID="BtnUpdate" runat="server" Text="保存修改" OnClick="BtnUpdate_Click" CssClass="swde-btn swde-btn-primary" />
            <asp:HyperLink ID="HlkCancel" runat="server" NavigateUrl="~/teacher/softwaredownload.aspx" CssClass="swde-btn">取消</asp:HyperLink>
        </div>
    </div>
</div>

<script type="text/javascript">
    function switchMainTab(event, tabId) {
        if (event) event.preventDefault();
        var tabs = document.querySelectorAll('.swde-main-tab');
        tabs.forEach(function(tab) { tab.classList.remove('active'); });
        var contents = document.querySelectorAll('.swde-main-tab-content');
        contents.forEach(function(content) { content.classList.remove('active'); });
        if (event && event.currentTarget) event.currentTarget.classList.add('active');
        var targetContent = document.getElementById(tabId);
        if (targetContent) targetContent.classList.add('active');
    }

    function switchSubTab(event, tabId) {
        if (event) event.preventDefault();
        var tabs = document.querySelectorAll('.swde-sub-tab');
        tabs.forEach(function(tab) { tab.classList.remove('active'); });
        var contents = document.querySelectorAll('.swde-sub-tab-content');
        contents.forEach(function(content) { content.classList.remove('active'); });
        if (event && event.currentTarget) event.currentTarget.classList.add('active');
        var targetContent = document.getElementById(tabId);
        if (targetContent) targetContent.classList.add('active');
    }
</script>
</asp:Content>
