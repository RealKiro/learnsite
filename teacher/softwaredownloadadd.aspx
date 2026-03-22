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
            EnsureTableStructure();
        }
    }

    private void EnsureTableStructure()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 检查表是否存在
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

    protected void BtnAdd_Click(object sender, EventArgs e)
    {
        string name = TxtName.Text.Trim();
        if (string.IsNullOrEmpty(name)) { pageMsg = "请输入软件名称"; return; }
        string iconPath = TxtIcon.Text.Trim();
        string downloadUrl = TxtDownloadUrl.Text.Trim();
        string fileName = "";
        long fileSize = 0;
        string downloadUrlWin = TxtDownloadUrlWin.Text.Trim();
        string fileNameWin = "";
        long fileSizeWin = 0;
        string downloadUrlMac = TxtDownloadUrlMac.Text.Trim();
        string fileNameMac = "";
        long fileSizeMac = 0;
        string downloadUrlLinux = TxtDownloadUrlLinux.Text.Trim();
        string fileNameLinux = "";
        long fileSizeLinux = 0;

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

        // 处理通用软件文件上传
        if (FileUploadSoftware.HasFile)
        {
            try
            {
                fileName = FileUploadSoftware.FileName;
                fileSize = FileUploadSoftware.PostedFile.ContentLength;
                if (fileSize > 500 * 1024 * 1024) { pageMsg = "软件文件大小不能超过 500MB"; return; }
                string fileExt = System.IO.Path.GetExtension(fileName).ToLower();
                string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + fileExt;
                string uploadFolder = Server.MapPath("~/downloads/software/");
                if (!System.IO.Directory.Exists(uploadFolder)) System.IO.Directory.CreateDirectory(uploadFolder);
                string filePath = System.IO.Path.Combine(uploadFolder, newFileName);
                FileUploadSoftware.SaveAs(filePath);
                downloadUrl = "~/downloads/software/" + newFileName;
            }
            catch (Exception ex) { pageMsg = "软件文件上传失败: " + ex.Message; return; }
        }

        // 处理Windows版本文件上传
        if (FileUploadWin.HasFile)
        {
            try
            {
                fileNameWin = FileUploadWin.FileName;
                fileSizeWin = FileUploadWin.PostedFile.ContentLength;
                if (fileSizeWin > 500 * 1024 * 1024) { pageMsg = "Windows版本文件大小不能超过 500MB"; return; }
                string fileExt = System.IO.Path.GetExtension(fileNameWin).ToLower();
                string newFileName = "win_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + fileExt;
                string uploadFolder = Server.MapPath("~/downloads/software/");
                if (!System.IO.Directory.Exists(uploadFolder)) System.IO.Directory.CreateDirectory(uploadFolder);
                string filePath = System.IO.Path.Combine(uploadFolder, newFileName);
                FileUploadWin.SaveAs(filePath);
                downloadUrlWin = "~/downloads/software/" + newFileName;
            }
            catch (Exception ex) { pageMsg = "Windows版本上传失败: " + ex.Message; return; }
        }

        // 处理Mac版本文件上传
        if (FileUploadMac.HasFile)
        {
            try
            {
                fileNameMac = FileUploadMac.FileName;
                fileSizeMac = FileUploadMac.PostedFile.ContentLength;
                if (fileSizeMac > 500 * 1024 * 1024) { pageMsg = "Mac版本文件大小不能超过 500MB"; return; }
                string fileExt = System.IO.Path.GetExtension(fileNameMac).ToLower();
                string newFileName = "mac_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + fileExt;
                string uploadFolder = Server.MapPath("~/downloads/software/");
                if (!System.IO.Directory.Exists(uploadFolder)) System.IO.Directory.CreateDirectory(uploadFolder);
                string filePath = System.IO.Path.Combine(uploadFolder, newFileName);
                FileUploadMac.SaveAs(filePath);
                downloadUrlMac = "~/downloads/software/" + newFileName;
            }
            catch (Exception ex) { pageMsg = "Mac版本上传失败: " + ex.Message; return; }
        }

        // 处理Linux版本文件上传
        if (FileUploadLinux.HasFile)
        {
            try
            {
                fileNameLinux = FileUploadLinux.FileName;
                fileSizeLinux = FileUploadLinux.PostedFile.ContentLength;
                if (fileSizeLinux > 500 * 1024 * 1024) { pageMsg = "Linux版本文件大小不能超过 500MB"; return; }
                string fileExt = System.IO.Path.GetExtension(fileNameLinux).ToLower();
                string newFileName = "linux_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + fileExt;
                string uploadFolder = Server.MapPath("~/downloads/software/");
                if (!System.IO.Directory.Exists(uploadFolder)) System.IO.Directory.CreateDirectory(uploadFolder);
                string filePath = System.IO.Path.Combine(uploadFolder, newFileName);
                FileUploadLinux.SaveAs(filePath);
                downloadUrlLinux = "~/downloads/software/" + newFileName;
            }
            catch (Exception ex) { pageMsg = "Linux版本上传失败: " + ex.Message; return; }
        }

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    @"INSERT INTO SoftwareDownload(Sname,Sversion,Sicon,Sdesc,Sdownloadurl,Sfilename,Sfilesize,
                      SdownloadurlWin,SdownloadurlMac,SdownloadurlLinux,SfilenameWin,SfilenameMac,SfilenameLinux,
                      SfilesizeWin,SfilesizeMac,SfilesizeLinux,Sdownloads,Shid,Sdate,Sactive) 
                      VALUES(@name,@version,@icon,@desc,@url,@filename,@filesize,
                      @urlWin,@urlMac,@urlLinux,@filenameWin,@filenameMac,@filenameLinux,
                      @filesizeWin,@filesizeMac,@filesizeLinux,0,@hid,GETDATE(),1)", conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@version", TxtVersion.Text.Trim());
                    cmd.Parameters.AddWithValue("@icon", iconPath);
                    cmd.Parameters.AddWithValue("@desc", TxtDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@url", downloadUrl);
                    cmd.Parameters.AddWithValue("@filename", fileName);
                    cmd.Parameters.AddWithValue("@filesize", fileSize);
                    cmd.Parameters.AddWithValue("@urlWin", downloadUrlWin);
                    cmd.Parameters.AddWithValue("@urlMac", downloadUrlMac);
                    cmd.Parameters.AddWithValue("@urlLinux", downloadUrlLinux);
                    cmd.Parameters.AddWithValue("@filenameWin", fileNameWin);
                    cmd.Parameters.AddWithValue("@filenameMac", fileNameMac);
                    cmd.Parameters.AddWithValue("@filenameLinux", fileNameLinux);
                    cmd.Parameters.AddWithValue("@filesizeWin", fileSizeWin);
                    cmd.Parameters.AddWithValue("@filesizeMac", fileSizeMac);
                    cmd.Parameters.AddWithValue("@filesizeLinux", fileSizeLinux);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.ExecuteNonQuery();
                }
            }
            Response.Redirect("~/teacher/softwaredownload.aspx");
        }
        catch (Exception ex) { pageMsg = "添加失败: " + ex.Message; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .swda-page { max-width: 1200px; width: 100%; margin: 0 auto; }
    .swda-header { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .swda-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .swda-title .swda-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#10b981,#34d399); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .swda-title .swda-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .swda-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .swda-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; }
    .swda-main-tabs { display: flex; border-bottom: 2px solid #e8ecf1; margin-bottom: 0; background: #fafbfc; border-radius: 12px 12px 0 0; overflow: hidden; }
    .swda-main-tab { flex: 1; padding: 16px 24px; border: none; background: transparent; color: #64748b; font-size: 14px; font-weight: 500; cursor: pointer; border-bottom: 3px solid transparent; transition: all .2s; display: flex; align-items: center; justify-content: center; gap: 10px; position: relative; }
    .swda-main-tab:hover { color: #334155; background: #f1f5f9; }
    .swda-main-tab.active { color: #10b981; border-bottom-color: #10b981; background: #fff; font-weight: 600; }
    .swda-main-tab svg { width: 20px; height: 20px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swda-main-tab-content { display: none; padding: 32px; background: #fff; }
    .swda-main-tab-content.active { display: block; }
    .swda-sub-tabs { display: flex; border-bottom: 2px solid #f1f5f9; margin-bottom: 24px; gap: 4px; }
    .swda-sub-tab { padding: 10px 20px; border: none; background: transparent; color: #64748b; font-size: 13px; font-weight: 500; cursor: pointer; border-bottom: 2px solid transparent; transition: all .2s; display: flex; align-items: center; gap: 8px; border-radius: 6px 6px 0 0; }
    .swda-sub-tab:hover { color: #334155; background: #f8fafc; }
    .swda-sub-tab.active { color: #10b981; border-bottom-color: #10b981; background: #f0fdf4; }
    .swda-sub-tab svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swda-sub-tab-content { display: none; }
    .swda-sub-tab-content.active { display: block; }
    .swda-form-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 20px; }
    .swda-form-group label { font-size: 13px; font-weight: 600; color: #475569; }
    .swda-form-group label .required { color: #ef4444; margin-left: 2px; }
    .swda-form-group input, .swda-form-group textarea { padding: 10px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; font-family: inherit; }
    .swda-form-group input:focus, .swda-form-group textarea:focus { border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,.1); }
    .swda-form-group textarea { resize: vertical; min-height: 80px; }
    .swda-form-group small { font-size: 11px; color: #94a3b8; margin-top: 2px; }
    .swda-file-upload { padding: 10px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; width: 100%; cursor: pointer; }
    .swda-file-upload::-webkit-file-upload-button { padding: 6px 12px; border-radius: 6px; border: 1px solid #e2e8f0; background: #f8fafc; color: #475569; font-size: 12px; cursor: pointer; margin-right: 10px; }
    .swda-file-upload::-webkit-file-upload-button:hover { background: #f1f5f9; }
    .swda-btn { display: inline-flex; align-items: center; gap: 6px; padding: 10px 24px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; }
    .swda-btn:hover { background: #f8fafc; }
    .swda-btn-primary { background: linear-gradient(135deg,#10b981,#34d399); color: #fff; border-color: #10b981; }
    .swda-btn-primary:hover { background: linear-gradient(135deg,#059669,#10b981); color: #fff; }
    .swda-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .swda-actions { display: flex; gap: 12px; padding: 24px 32px 24px 52px; border-top: 1px solid #f1f5f9; margin-top: 24px; margin-left: -32px; margin-right: -32px; border-radius: 0 0 12px 12px; }
    .swda-msg { padding: 12px 16px; border-radius: 8px; background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; font-size: 13px; margin-bottom: 20px; }
    .swda-tip { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px; font-size: 12px; color: #166534; line-height: 1.6; }
</style>

<div class="swda-page">
    <div class="swda-header">
        <div class="swda-title">
            <span class="swda-icon">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </span>
            添加软件
        </div>
        <div class="swda-subtitle">上传新的软件资源，填写软件信息和下载方式</div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="swda-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <div class="swda-card">
        <div class="swda-main-tabs">
            <button type="button" class="swda-main-tab active" onclick="switchMainTab(event, 'main-tab-basic')">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                基本信息
            </button>
            <button type="button" class="swda-main-tab" onclick="switchMainTab(event, 'main-tab-icon')">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                软件图标
            </button>
            <button type="button" class="swda-main-tab" onclick="switchMainTab(event, 'main-tab-download')">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                下载设置
            </button>
        </div>

        <!-- 基本信息 Tab -->
        <div id="main-tab-basic" class="swda-main-tab-content active">
            <div class="swda-form-group">
                <label>软件名称<span class="required">*</span></label>
                <asp:TextBox ID="TxtName" runat="server" MaxLength="200" placeholder="如：Visual Studio Code" />
            </div>
            <div class="swda-form-group">
                <label>版本号</label>
                <asp:TextBox ID="TxtVersion" runat="server" MaxLength="50" placeholder="如：1.85.0" />
                <small>可选，用于标识软件版本</small>
            </div>
            <div class="swda-form-group">
                <label>软件描述</label>
                <asp:TextBox ID="TxtDesc" runat="server" MaxLength="2000" TextMode="MultiLine" Rows="6" placeholder="请输入软件的详细介绍..." />
            </div>
        </div>

        <!-- 软件图标 Tab -->
        <div id="main-tab-icon" class="swda-main-tab-content">
            <div class="swda-tip">
                <strong>提示：</strong>可以输入图标的网络地址，或者上传本地图标文件。如果同时填写和上传，将优先使用上传的文件。
            </div>
            <div class="swda-form-group">
                <label>图标URL</label>
                <asp:TextBox ID="TxtIcon" runat="server" MaxLength="500" placeholder="如：https://example.com/icon.png" />
                <small>可以输入图标的网络地址</small>
            </div>
            <div class="swda-form-group">
                <label>或上传图标（JPG/PNG/GIF，最大2MB）</label>
                <asp:FileUpload ID="FileUploadIcon" runat="server" CssClass="swda-file-upload" accept="image/*" />
                <small>上传图标将自动保存到 /images/software/ 目录</small>
            </div>
        </div>

        <!-- 下载设置 Tab -->
        <div id="main-tab-download" class="swda-main-tab-content">
            <div class="swda-tip">
                <strong>提示：</strong>可以为不同操作系统设置专用版本，也可以只设置通用版本。每个版本都支持填写外部链接或上传本地文件。
            </div>
            <div class="swda-sub-tabs">
                <button type="button" class="swda-sub-tab active" onclick="switchSubTab(event, 'sub-tab-general')">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    通用版本
                </button>
                <button type="button" class="swda-sub-tab" onclick="switchSubTab(event, 'sub-tab-windows')">
                    <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    Windows
                </button>
                <button type="button" class="swda-sub-tab" onclick="switchSubTab(event, 'sub-tab-macos')">
                    <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"/><line x1="7" y1="2" x2="7" y2="22"/><line x1="17" y1="2" x2="17" y2="22"/></svg>
                    macOS
                </button>
                <button type="button" class="swda-sub-tab" onclick="switchSubTab(event, 'sub-tab-linux')">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>
                    Linux
                </button>
            </div>
            <div id="sub-tab-general" class="swda-sub-tab-content active">
                <div class="swda-form-group">
                    <label>下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrl" runat="server" MaxLength="500" placeholder="如：https://example.com/software.exe" />
                    <small>可以输入外部下载地址（适用于所有平台的通用版本）</small>
                </div>
                <div class="swda-form-group">
                    <label>或上传软件文件（最大500MB）</label>
                    <asp:FileUpload ID="FileUploadSoftware" runat="server" CssClass="swda-file-upload" />
                    <small>上传的软件文件将保存到 /downloads/software/ 目录</small>
                </div>
            </div>

            <div id="sub-tab-windows" class="swda-sub-tab-content">
                <div class="swda-form-group">
                    <label>Windows 下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrlWin" runat="server" MaxLength="500" placeholder="如：https://example.com/software-win.exe" />
                    <small>Windows 平台专用下载地址</small>
                </div>
                <div class="swda-form-group">
                    <label>或上传 Windows 版本文件（最大500MB）</label>
                    <asp:FileUpload ID="FileUploadWin" runat="server" CssClass="swda-file-upload" />
                    <small>支持 .exe、.msi 等 Windows 安装包格式</small>
                </div>
            </div>
            <div id="sub-tab-macos" class="swda-sub-tab-content">
                <div class="swda-form-group">
                    <label>macOS 下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrlMac" runat="server" MaxLength="500" placeholder="如：https://example.com/software-mac.dmg" />
                    <small>macOS 平台专用下载地址</small>
                </div>
                <div class="swda-form-group">
                    <label>或上传 macOS 版本文件（最大500MB）</label>
                    <asp:FileUpload ID="FileUploadMac" runat="server" CssClass="swda-file-upload" />
                    <small>支持 .dmg、.pkg 等 macOS 安装包格式</small>
                </div>
            </div>
            <div id="sub-tab-linux" class="swda-sub-tab-content">
                <div class="swda-form-group">
                    <label>Linux 下载链接</label>
                    <asp:TextBox ID="TxtDownloadUrlLinux" runat="server" MaxLength="500" placeholder="如：https://example.com/software-linux.tar.gz" />
                    <small>Linux 平台专用下载地址</small>
                </div>
                <div class="swda-form-group">
                    <label>或上传 Linux 版本文件（最大500MB）</label>
                    <asp:FileUpload ID="FileUploadLinux" runat="server" CssClass="swda-file-upload" />
                    <small>支持 .deb、.rpm、.tar.gz、.AppImage 等 Linux 安装包格式</small>
                </div>
            </div>
        </div>

        <div class="swda-actions">
            <asp:Button ID="BtnAdd" runat="server" Text="添加软件" OnClick="BtnAdd_Click" CssClass="swda-btn swda-btn-primary" />
            <asp:HyperLink ID="HlkCancel" runat="server" NavigateUrl="~/teacher/softwaredownload.aspx" CssClass="swda-btn">取消</asp:HyperLink>
        </div>
    </div>
</div>

<script type="text/javascript">
    function switchMainTab(event, tabId) {
        if (event) event.preventDefault();
        var tabs = document.querySelectorAll('.swda-main-tab');
        tabs.forEach(function(tab) { tab.classList.remove('active'); });
        var contents = document.querySelectorAll('.swda-main-tab-content');
        contents.forEach(function(content) { content.classList.remove('active'); });
        if (event && event.currentTarget) event.currentTarget.classList.add('active');
        var targetContent = document.getElementById(tabId);
        if (targetContent) targetContent.classList.add('active');
    }

    function switchSubTab(event, tabId) {
        if (event) event.preventDefault();
        var tabs = document.querySelectorAll('.swda-sub-tab');
        tabs.forEach(function(tab) { tab.classList.remove('active'); });
        var contents = document.querySelectorAll('.swda-sub-tab-content');
        contents.forEach(function(content) { content.classList.remove('active'); });
        if (event && event.currentTarget) event.currentTarget.classList.add('active');
        var targetContent = document.getElementById(tabId);
        if (targetContent) targetContent.classList.add('active');
    }
</script>
</asp:Content>
