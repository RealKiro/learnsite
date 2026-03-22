<%@ Page Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
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

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                EnsureResourceCategoriesTable();
                LoadCategories();
            }
            catch
            {
                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new System.Web.UI.WebControls.ListItem("资源分类初始化失败", "0"));
            }
        }
    }

    private string GetResourceType(string fileName)
    {
        string ext = Path.GetExtension(fileName).ToLower();
        
        string[] videoExts = new string[] { ".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".webm", ".m4v" };
        string[] audioExts = new string[] { ".mp3", ".wav", ".flac", ".aac", ".ogg", ".wma", ".m4a" };
        string[] imageExts = new string[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".webp" };
        string[] docExts = new string[] { ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".txt" };
        string[] codeExts = new string[] { ".html", ".css", ".js", ".py", ".java", ".cpp", ".c", ".cs", ".php" };
        string[] archiveExts = new string[] { ".zip", ".rar", ".7z", ".tar", ".gz" };
        
        foreach (string e in videoExts) { if (ext == e) return "视频"; }
        foreach (string e in audioExts) { if (ext == e) return "音频"; }
        foreach (string e in imageExts) { if (ext == e) return "图片"; }
        foreach (string e in docExts) { if (ext == e) return "文档"; }
        foreach (string e in codeExts) { if (ext == e) return "代码"; }
        foreach (string e in archiveExts) { if (ext == e) return "压缩包"; }
        
        return "其他";
    }

    protected void LoadCategories()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT CategoryId, CategoryName FROM ResourceCategories WHERE IsActive = 1 ORDER BY SortOrder, CategoryId";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                ddlCategory.DataSource = dt;
                ddlCategory.DataTextField = "CategoryName";
                ddlCategory.DataValueField = "CategoryId";
                ddlCategory.DataBind();
                ddlCategory.Items.Insert(0, new System.Web.UI.WebControls.ListItem("请选择分类", "0"));
            }
        }
        catch
        {
            ddlCategory.Items.Clear();
            ddlCategory.Items.Add(new System.Web.UI.WebControls.ListItem("资源分类初始化失败", "0"));
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        string resourceName = txtResourceName.Text.Trim();
        if (string.IsNullOrEmpty(resourceName))
        {
            ShowMessage("请输入资源名称", "error");
            return;
        }
        
        if (ddlCategory.SelectedValue == "0")
        {
            ShowMessage("请选择资源分类", "error");
            return;
        }
        
        if (!fileUploadResource.HasFile)
        {
            ShowMessage("请上传资源文件", "error");
            return;
        }
        
        try
        {
            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                ShowMessage("数据库连接失败", "error");
                return;
            }
            
            string coverImagePath = "";
            if (fileUploadCover.HasFile)
            {
                string coverDir = Server.MapPath("~/uploads/covers/");
                if (!Directory.Exists(coverDir)) Directory.CreateDirectory(coverDir);
                
                string coverExt = Path.GetExtension(fileUploadCover.FileName);
                string coverFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_cover" + coverExt;
                string coverPhysicalPath = Path.Combine(coverDir, coverFileName);
                fileUploadCover.SaveAs(coverPhysicalPath);
                coverImagePath = "/uploads/covers/" + coverFileName;
            }
            
            string resourceDir = Server.MapPath("~/uploads/resources/");
            if (!Directory.Exists(resourceDir)) Directory.CreateDirectory(resourceDir);
            
            string resourceExt = Path.GetExtension(fileUploadResource.FileName);
            string resourceFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + resourceExt;
            string resourcePhysicalPath = Path.Combine(resourceDir, resourceFileName);
            fileUploadResource.SaveAs(resourcePhysicalPath);
            string resourceRelativePath = "/uploads/resources/" + resourceFileName;
            
            long fileSize = fileUploadResource.PostedFile.ContentLength;
            string resourceType = GetResourceType(fileUploadResource.FileName);
            
            string userSnum = "admin";
            try
            {
                HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
                if (tc != null && !string.IsNullOrEmpty(tc.Value))
                {
                    object t = DecodeCookie("LearnSite.Model.TeaCook", tc.Value);
                    userSnum = GetProp(t, "Hname");
                }
            }
            catch { }
            
            int viewCredits = 0;
            int downloadCredits = 0;
            int.TryParse(txtViewCredits.Text.Trim(), out viewCredits);
            int.TryParse(txtDownloadCredits.Text.Trim(), out downloadCredits);
            
            bool hasChapters = chkHasChapters.Checked;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                string sql = @"INSERT INTO Files (FileName, FileSize, CreateTime, UpdateTime, RelativePath, UserSnum, FolderId,
                              ResourceName, CategoryId, CoverImage, ViewCredits, DownloadCredits, Description, 
                              ResourceType, ViewCount, DownloadCount, HasChapters, IsPublished)
                              VALUES (@FileName, @FileSize, @CreateTime, @UpdateTime, @RelativePath, @UserSnum, 0,
                              @ResourceName, @CategoryId, @CoverImage, @ViewCredits, @DownloadCredits, @Description,
                              @ResourceType, 0, 0, @HasChapters, 1);
                              SELECT SCOPE_IDENTITY();";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@FileName", fileUploadResource.FileName);
                cmd.Parameters.AddWithValue("@FileSize", fileSize);
                cmd.Parameters.AddWithValue("@CreateTime", DateTime.Now);
                cmd.Parameters.AddWithValue("@UpdateTime", DateTime.Now);
                cmd.Parameters.AddWithValue("@RelativePath", resourceRelativePath);
                cmd.Parameters.AddWithValue("@UserSnum", userSnum);
                cmd.Parameters.AddWithValue("@ResourceName", resourceName);
                cmd.Parameters.AddWithValue("@CategoryId", ddlCategory.SelectedValue);
                cmd.Parameters.AddWithValue("@CoverImage", coverImagePath);
                cmd.Parameters.AddWithValue("@ViewCredits", viewCredits);
                cmd.Parameters.AddWithValue("@DownloadCredits", downloadCredits);
                cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                cmd.Parameters.AddWithValue("@ResourceType", resourceType);
                cmd.Parameters.AddWithValue("@HasChapters", hasChapters);
                
                int resourceId = Convert.ToInt32(cmd.ExecuteScalar());
                
                txtResourceName.Text = "";
                txtDescription.Text = "";
                txtViewCredits.Text = "0";
                txtDownloadCredits.Text = "0";
                ddlCategory.SelectedIndex = 0;
                chkHasChapters.Checked = false;
                
                if (hasChapters)
                {
                    ShowMessageAndRedirect("资源创建成功！正在跳转到章节管理...", "success", "resourcechapters.aspx?rid=" + resourceId);
                }
                else
                {
                    ShowMessageAndRedirect("资源创建成功！正在跳转到资源管理...", "success", "resourcemanage.aspx");
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("创建失败：" + ex.Message, "error");
        }
    }
    
    private void ShowMessage(string message, string type)
    {
        string script = string.Format("showToast('{0}', '{1}');", message.Replace("'", "\\'"), type);
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
    }
    
    private void ShowMessageAndRedirect(string message, string type, string url)
    {
        string script = string.Format("showToast('{0}', '{1}'); setTimeout(function(){{ window.location.href='{2}'; }}, 1500);", 
            message.Replace("'", "\\'"), type, url);
        ClientScript.RegisterStartupScript(this.GetType(), "toastRedirect", script, true);
    }
    
    private static System.Reflection.BindingFlags tFlags =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    private object DecodeCookie(string typeName, string cookieValue)
    {
        Type cookType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType(typeName);
        if (cookType == null) return null;
        object model = Activator.CreateInstance(cookType);
        System.Reflection.MethodInfo toModel = cookType.GetMethod("ToModel", tFlags);
        if (toModel != null) toModel.Invoke(model, new object[] { cookieValue });
        return model;
    }

    private string GetProp(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo prop = model.GetType().GetProperty(propName);
        if (prop == null) return "";
        object val = prop.GetValue(model, null);
        return val != null ? val.ToString() : "";
    }

    private void EnsureResourceCategoriesTable()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        string sql = @"
IF OBJECT_ID(N'dbo.ResourceCategories', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ResourceCategories](
        [CategoryId] [int] IDENTITY(1,1) NOT NULL,
        [CategoryName] [nvarchar](50) NOT NULL,
        [CategoryIcon] [nvarchar](50) NULL,
        [CategoryColor] [nvarchar](20) NULL,
        [Description] [nvarchar](200) NULL,
        [SortOrder] [int] NOT NULL CONSTRAINT [DF_ResourceCategories_SortOrder] DEFAULT ((0)),
        [IsActive] [bit] NOT NULL CONSTRAINT [DF_ResourceCategories_IsActive] DEFAULT ((1)),
        [CreateTime] [datetime] NOT NULL CONSTRAINT [DF_ResourceCategories_CreateTime] DEFAULT (getdate()),
        CONSTRAINT [PK_ResourceCategories] PRIMARY KEY CLUSTERED ([CategoryId] ASC)
    );
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[ResourceCategories])
BEGIN
    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'Video', N'video', N'#ef4444', N'Video resources', 1, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'Document', N'doc', N'#3b82f6', N'Document and courseware', 2, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'Image', N'image', N'#10b981', N'Image materials', 3, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'Audio', N'audio', N'#8b5cf6', N'Audio resources', 4, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'Code', N'code', N'#f59e0b', N'Code examples', 5, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'Archive', N'archive', N'#64748b', N'Compressed files', 6, 1);
END";

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<style>
    /* ===== 创建资源页面 ===== */
    * { box-sizing: border-box; }
    .rc-page { max-width: 1360px; margin: 0 auto; }

    /* 左右双栏布局 */
    .rc-layout { display: grid; grid-template-columns: 1fr 400px; gap: 24px; align-items: start; }
    
    /* 页面标题 */
    .rc-header {
        display: flex; align-items: center; gap: 14px;
        margin-bottom: 24px;
    }
    .rc-header .rc-icon {
        width: 48px; height: 48px; border-radius: 14px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        box-shadow: 0 4px 12px rgba(99,102,241,0.3);
    }
    .rc-header .rc-icon svg { width: 24px; height: 24px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .rc-header h2 { font-size: 22px; font-weight: 700; color: #1e293b; margin: 0; }
    .rc-header .rc-desc { font-size: 13px; color: #94a3b8; margin: 3px 0 0; }
    
    /* 通用卡片 */
    .rc-card {
        background: #fff; border-radius: 14px; padding: 26px 28px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.06);
        border: 1px solid #e8ecf1; margin-bottom: 18px;
    }

    /* 卡片分区标题 */
    .rc-section-title {
        display: flex; align-items: center; gap: 10px;
        font-size: 15px; font-weight: 700; color: #1e293b;
        margin-bottom: 20px; padding-bottom: 14px;
        border-bottom: 1px solid #f1f5f9;
    }
    .rc-section-icon {
        width: 30px; height: 30px; border-radius: 8px; background: #eef2ff;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .rc-section-icon svg { width: 15px; height: 15px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 表单组 */
    .rc-form-group { margin-bottom: 18px; }
    .rc-form-group:last-child { margin-bottom: 0; }
    .rc-form-group > label {
        display: flex; align-items: center; gap: 6px;
        font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 8px;
    }
    .rc-form-group > label svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    .rc-required { color: #ef4444; margin-left: 2px; }

    /* 输入框 */
    .rc-input {
        width: 100%; padding: 10px 14px;
        border: 1.5px solid #e2e8f0; border-radius: 10px;
        font-size: 13.5px; color: #334155; background: #f8fafc;
        font-family: inherit; outline: none; transition: all 0.2s;
    }
    .rc-input:hover { border-color: #cbd5e1; }
    .rc-input:focus { border-color: #818cf8; background: #fff; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
    textarea.rc-input { resize: vertical; min-height: 100px; line-height: 1.65; }

    /* 下拉框 */
    .rc-select {
        width: 100%;
        appearance: none; -webkit-appearance: none; -moz-appearance: none;
        background: #f8fafc url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E") no-repeat right 12px center;
        border: 1.5px solid #e2e8f0; border-radius: 10px;
        padding: 10px 36px 10px 14px; font-size: 13.5px; color: #334155;
        font-family: inherit; outline: none; transition: all 0.2s; cursor: pointer;
    }
    .rc-select:hover { border-color: #cbd5e1; }
    .rc-select:focus { border-color: #818cf8; background-color: #fff; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }

    /* 双列布局 */
    .rc-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
    
    /* 文件上传区 */
    .rc-upload-box {
        border: 2px dashed #cbd5e1; border-radius: 12px;
        padding: 36px 24px; text-align: center; background: #f8fafc;
        transition: all 0.25s; cursor: pointer;
    }
    .rc-upload-box:hover {
        border-color: #818cf8; background: #f5f3ff;
        box-shadow: 0 4px 16px rgba(99,102,241,0.1);
    }
    .rc-upload-box.has-file {
        border-color: #10b981; border-style: solid;
        background: #f0fdf4; padding: 18px 24px;
    }
    .rc-upload-icon {
        width: 60px; height: 60px; margin: 0 auto 14px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 14px; display: flex; align-items: center;
        justify-content: center; box-shadow: 0 6px 18px rgba(99,102,241,0.25);
        transition: all 0.25s;
    }
    .rc-upload-box:hover .rc-upload-icon { transform: translateY(-4px) scale(1.05); }
    .rc-upload-icon svg { width: 28px; height: 28px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .rc-upload-title { font-size: 15px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
    .rc-upload-text { font-size: 13px; color: #64748b; line-height: 1.6; }
    .rc-upload-hint {
        display: inline-block; margin-top: 12px; padding: 5px 14px;
        background: #eef2ff; border-radius: 20px;
        font-size: 12px; font-weight: 600; color: #4338ca;
    }
    /* 已选文件信息 */
    .rc-file-info {
        display: flex; align-items: center; gap: 14px;
        background: #fff; border-radius: 10px; padding: 14px 18px;
        border: 1.5px solid #10b981;
        box-shadow: 0 2px 8px rgba(16,185,129,0.1); text-align: left;
    }
    .rc-file-info-icon {
        width: 46px; height: 46px; flex-shrink: 0;
        background: linear-gradient(135deg, #10b981, #059669);
        border-radius: 12px; display: flex; align-items: center;
        justify-content: center; font-size: 22px;
        box-shadow: 0 4px 12px rgba(16,185,129,0.25);
    }
    .rc-file-info-details { flex: 1; min-width: 0; }
    .rc-file-info-name { font-size: 13px; font-weight: 700; color: #059669; margin-bottom: 4px; word-break: break-all; }
    .rc-file-type-badge {
        display: inline-block; padding: 2px 7px; border-radius: 4px;
        background: #d1fae5; font-size: 11px; font-weight: 600; color: #065f46; margin-left: 5px;
    }
    .rc-file-info-size { font-size: 12px; color: #64748b; display: flex; align-items: center; gap: 4px; }
    .rc-file-info-size svg { width: 12px; height: 12px; stroke: #94a3b8; fill: none; stroke-width: 2; }
    .rc-file-change {
        padding: 6px 12px; background: #f1f5f9; border: 1px solid #e2e8f0;
        border-radius: 8px; font-size: 12px; font-weight: 600; color: #475569;
        cursor: pointer; transition: all 0.2s; white-space: nowrap;
        display: flex; align-items: center; gap: 4px; flex-shrink: 0;
    }
    .rc-file-change svg { width: 12px; height: 12px; stroke: currentColor; fill: none; stroke-width: 2; }
    .rc-file-change:hover { background: #e2e8f0; transform: translateY(-1px); }
    /* 封面上传 */
    .rc-cover-box {
        border: 2px dashed #cbd5e1; border-radius: 12px;
        padding: 20px; text-align: center; background: #f8fafc;
        transition: all 0.25s; cursor: pointer;
        min-height: 90px; display: flex; align-items: center; justify-content: center;
    }
    .rc-cover-box:hover { border-color: #818cf8; background: #f5f3ff; }
    .rc-cover-text { font-size: 13px; color: #64748b; font-weight: 500; display: flex; align-items: center; gap: 7px; }
    .rc-cover-text svg { width: 17px; height: 17px; stroke: #94a3b8; fill: none; stroke-width: 2; }
    .rc-cover-preview { position: relative; width: 100%; }
    .rc-cover-preview img { width: 100%; height: 170px; object-fit: cover; border-radius: 8px; display: block; }
    .rc-cover-overlay {
        position: absolute; inset: 0; background: rgba(0,0,0,0.48);
        display: flex; align-items: center; justify-content: center;
        color: #fff; font-size: 13px; font-weight: 600; border-radius: 8px;
        opacity: 0; transition: opacity 0.2s;
    }
    .rc-cover-preview:hover .rc-cover-overlay { opacity: 1; }
    /* 提示框 */
    .rc-info-box {
        background: #f0f9ff; border-left: 3px solid #0284c7;
        border-radius: 10px; padding: 12px 16px; margin-bottom: 16px;
    }
    .rc-info-box-title { font-size: 13px; font-weight: 700; color: #0c4a6e; margin-bottom: 4px; display: flex; align-items: center; gap: 5px; }
    .rc-info-box-title svg { width: 13px; height: 13px; stroke: #0284c7; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .rc-info-box-text { font-size: 12.5px; color: #075985; line-height: 1.65; }
    /* 复选框 */
    .rc-checkbox-wrap {
        display: flex; align-items: flex-start; gap: 12px;
        padding: 14px 18px; background: #f8fafc; border-radius: 10px;
        border: 1.5px solid #e2e8f0; cursor: pointer;
        transition: all 0.2s; user-select: none;
    }
    .rc-checkbox-wrap:hover { border-color: #818cf8; background: #f5f3ff; }
    .rc-checkbox-wrap input[type="checkbox"] {
        width: 17px; height: 17px; margin-top: 2px; cursor: pointer;
        accent-color: #6366f1; flex-shrink: 0; pointer-events: none;
    }
    .rc-checkbox-body { flex: 1; }
    .rc-checkbox-label { font-size: 14px; font-weight: 600; color: #334155; }
    .rc-checkbox-hint { font-size: 12px; color: #94a3b8; margin-top: 3px; }
    /* 操作区 */
    .rc-actions { display: flex; gap: 12px; }
    .rc-btn-submit {
        flex: 1; background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff; border: none; padding: 13px 32px;
        border-radius: 12px; font-size: 15px; font-weight: 700;
        cursor: pointer; transition: all 0.25s;
        box-shadow: 0 4px 16px rgba(99,102,241,0.35);
        display: inline-flex; align-items: center; justify-content: center; gap: 8px;
        font-family: inherit; line-height: 1;
    }
    .rc-btn-submit:hover { background: linear-gradient(135deg, #4f46e5, #6366f1); box-shadow: 0 6px 22px rgba(99,102,241,0.45); transform: translateY(-2px); }
    .rc-btn-submit:active { transform: translateY(0); }
    .rc-btn-submit svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
    .rc-btn-back {
        padding: 13px 20px; background: #f1f5f9; border: 1.5px solid #e2e8f0;
        border-radius: 12px; font-size: 14px; font-weight: 600; color: #475569;
        cursor: pointer; transition: all 0.2s; text-decoration: none;
        display: inline-flex; align-items: center; gap: 6px; line-height: 1;
        white-space: nowrap;
    }
    .rc-btn-back:hover { background: #e2e8f0; border-color: #cbd5e1; color: #334155; }
    .rc-btn-back svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; }
    /* Toast */
    .rc-toast {
        position: fixed; top: 24px; right: 24px;
        background: #fff; padding: 14px 20px; border-radius: 12px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.14); z-index: 9999;
        display: none; align-items: center; gap: 12px;
        min-width: 260px; border-left: 4px solid;
        animation: rcToastIn 0.35s cubic-bezier(0.4,0,0.2,1);
    }
    @keyframes rcToastIn {
        from { transform: translateX(100%); opacity: 0; }
        to   { transform: translateX(0); opacity: 1; }
    }
    .rc-toast.success { border-left-color: #10b981; }
    .rc-toast.error   { border-left-color: #ef4444; }
    .rc-toast-icon { width: 30px; height: 30px; border-radius: 8px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; }
    .rc-toast.success .rc-toast-icon { background: #d1fae5; }
    .rc-toast.success .rc-toast-icon svg { stroke: #059669; }
    .rc-toast.error   .rc-toast-icon { background: #fee2e2; }
    .rc-toast.error   .rc-toast-icon svg { stroke: #dc2626; }
    .rc-toast-icon svg { width: 16px; height: 16px; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
    .rc-toast-msg { font-size: 13.5px; font-weight: 500; color: #1e293b; flex: 1; }
    /* 响应式 */
    @media (max-width: 900px) {
        .rc-layout { grid-template-columns: 1fr; }
    }
    @media (max-width: 640px) {
        .rc-form-row { grid-template-columns: 1fr; }
        .rc-card { padding: 18px; }
        .rc-actions { flex-direction: column; }
    }
</style>

<div class="rc-page">
    <!-- 页面标题 -->
    <div class="rc-header">
        <div class="rc-icon">
            <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </div>
        <div>
            <h2>创建资源</h2>
            <p class="rc-desc">创建新的教学资源，支持设置分类、封面、积分和多章节内容</p>
        </div>
    </div>

    <!-- 双栏布局开始 -->
    <div class="rc-layout">
    <!-- 左栏：基本信息 -->
    <div>
    <div class="rc-card">
        <div class="rc-section-title">
            <div class="rc-section-icon">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            </div>
            基本信息
        </div>

        <div class="rc-form-group">
            <label>
                <svg viewBox="0 0 24 24"><path d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/></svg>
                资源名称 <span class="rc-required">*</span>
            </label>
            <asp:TextBox ID="txtResourceName" runat="server" CssClass="rc-input"
                         placeholder="输入资源名称，例如：Python编程入门教程"></asp:TextBox>
        </div>

        <div class="rc-form-group">
            <label>
                <svg viewBox="0 0 24 24"><path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/></svg>
                资源分类 <span class="rc-required">*</span>
            </label>
            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="rc-select"></asp:DropDownList>
        </div>

        <div class="rc-form-group">
            <label>
                <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                资源描述
            </label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="rc-input"
                         TextMode="MultiLine" placeholder="详细描述资源内容、适用对象、学习目标等"></asp:TextBox>
        </div>

        <div class="rc-form-group">
            <label>
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                上传资源文件 <span class="rc-required">*</span>
            </label>
            <div class="rc-upload-box" id="resourceUploadBox" onclick="document.getElementById('<%= fileUploadResource.ClientID %>').click();">
                <div id="resourceUploadDefault">
                    <div class="rc-upload-icon">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    </div>
                    <div class="rc-upload-title">点击选择资源文件</div>
                    <div class="rc-upload-text">支持视频、音频、文档、图片、代码、压缩包等多种格式，系统将自动识别文件类型</div>
                    <div class="rc-upload-hint">MP4 &middot; PDF &middot; ZIP &middot; MP3 &middot; DOC &middot; PPT &middot; ...</div>
                </div>
                <div class="rc-file-info" id="resourceFileInfo" style="display:none;">
                    <div class="rc-file-info-icon">✓</div>
                    <div class="rc-file-info-details">
                        <div class="rc-file-info-name">
                            <span id="resourceFileName"></span>
                            <span class="rc-file-type-badge" id="resourceFileType"></span>
                        </div>
                        <div class="rc-file-info-size">
                            <svg viewBox="0 0 24 24"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                            <span id="resourceFileSize"></span>
                        </div>
                    </div>
                    <div class="rc-file-change" onclick="event.stopPropagation(); document.getElementById('<%= fileUploadResource.ClientID %>').click();">
                        <svg viewBox="0 0 24 24"><path d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/></svg>
                        更换
                    </div>
                </div>
            </div>
            <asp:FileUpload ID="fileUploadResource" runat="server" style="display:none;" onchange="handleResourceFileSelect(this)" />
        </div>

        <div class="rc-form-group">
            <label>
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                资源封面（可选）
            </label>
            <div class="rc-cover-box" id="coverUploadBox" onclick="document.getElementById('<%= fileUploadCover.ClientID %>').click();">
                <div class="rc-cover-preview" id="coverPreview" style="display:none;">
                    <img id="coverPreviewImg" src="" alt="封面预览" />
                    <div class="rc-cover-overlay">点击更换封面</div>
                </div>
                <div class="rc-cover-text" id="coverUploadText">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    点击选择封面图片（建议 800&times;600 或 16:9 比例）
                </div>
            </div>
            <asp:FileUpload ID="fileUploadCover" runat="server" style="display:none;" onchange="handleCoverFileSelect(this)" accept="image/*" />
        </div>
    </div>

    </div><!-- /左栏 -->
    <!-- 右栏：积分/章节/操作 -->
    <div>
    <!-- 积分设置 -->
    <div class="rc-card">
        <div class="rc-section-title">
            <div class="rc-section-icon">
                <svg viewBox="0 0 24 24"><path d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            积分设置
        </div>
        <div class="rc-info-box">
            <div class="rc-info-box-title">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                积分说明
            </div>
            <div class="rc-info-box-text">设置学生学习该资源可获得的积分奖励。<b>观看积分</b>：学生观看/浏览资源后获得；<b>下载积分</b>：学生下载资源后获得。填 0 表示不奖励积分。</div>
        </div>
        <div class="rc-form-row">
            <div class="rc-form-group">
                <label>
                    <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    观看积分
                </label>
                <asp:TextBox ID="txtViewCredits" runat="server" CssClass="rc-input" Text="0" placeholder="0"></asp:TextBox>
            </div>
            <div class="rc-form-group">
                <label>
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    下载积分
                </label>
                <asp:TextBox ID="txtDownloadCredits" runat="server" CssClass="rc-input" Text="0" placeholder="0"></asp:TextBox>
            </div>
        </div>
    </div>

    <!-- 章节设置 -->
    <div class="rc-card">
        <div class="rc-section-title">
            <div class="rc-section-icon">
                <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
            </div>
            章节设置
        </div>
        <div class="rc-info-box">
            <div class="rc-info-box-title">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                多章节功能
            </div>
            <div class="rc-info-box-text">如果您的资源包含多个章节（如视频教程系列、分章节的文档等），请勾选此选项。创建资源后，系统会引导您添加各章节内容。</div>
        </div>
        <div class="rc-checkbox-wrap" onclick="toggleCheckbox()">
            <asp:CheckBox ID="chkHasChapters" runat="server" />
            <div class="rc-checkbox-body">
                <div class="rc-checkbox-label">该资源包含多个章节</div>
                <div class="rc-checkbox-hint">勾选后，创建完成将自动跳转到章节管理页面</div>
            </div>
        </div>
    </div>

    <!-- 操作按钮 -->
    <div class="rc-card">
        <div class="rc-actions">
            <a href="resourcemanage.aspx" class="rc-btn-back">
                <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                返回资源管理
            </a>
            <asp:Button ID="btnCreate" runat="server" CssClass="rc-btn-submit" OnClick="btnCreate_Click" Text="创建资源" />
        </div>
    </div>
    </div><!-- /右栏 -->
    </div><!-- /rc-layout -->
</div>

<!-- Toast 通知 -->
<div id="rcToast" class="rc-toast">
    <div class="rc-toast-icon">
        <svg id="rcToastSvg" viewBox="0 0 24 24"></svg>
    </div>
    <span class="rc-toast-msg" id="rcToastMsg"></span>
</div>

<script type="text/javascript">
    function showToast(message, type) {
        var toast = document.getElementById('rcToast');
        var svg   = document.getElementById('rcToastSvg');
        var msg   = document.getElementById('rcToastMsg');
        toast.className = 'rc-toast ' + type;
        svg.innerHTML = (type === 'success')
            ? '<polyline points="20 6 9 17 4 12"/>'
            : '<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>';
        msg.textContent = message;
        toast.style.display = 'flex';
        setTimeout(function () { toast.style.display = 'none'; }, 3000);
    }

    function toggleCheckbox() {
        var cb = document.getElementById('<%= chkHasChapters.ClientID %>');
        if (cb) cb.checked = !cb.checked;
    }

    function handleResourceFileSelect(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            document.getElementById('resourceUploadDefault').style.display = 'none';
            var info = document.getElementById('resourceFileInfo');
            info.style.display = 'flex';
            document.getElementById('resourceFileName').textContent = file.name;
            document.getElementById('resourceFileSize').textContent = formatFileSize(file.size);
            document.getElementById('resourceFileType').textContent = getFileType(file.name);
            document.getElementById('resourceUploadBox').classList.add('has-file');
        }
    }

    function handleCoverFileSelect(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById('coverPreview').style.display = 'block';
                document.getElementById('coverPreviewImg').src = e.target.result;
                document.getElementById('coverUploadText').style.display = 'none';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function getFileType(fileName) {
        var ext = fileName.split('.').pop().toLowerCase();
        var types = {
            'mp4':'视频','avi':'视频','mkv':'视频','mov':'视频','wmv':'视频','flv':'视频','webm':'视频',
            'mp3':'音频','wav':'音频','flac':'音频','aac':'音频','ogg':'音频','wma':'音频',
            'pdf':'文档','doc':'文档','docx':'文档','xls':'文档','xlsx':'文档','ppt':'文档','pptx':'文档','txt':'文档',
            'jpg':'图片','jpeg':'图片','png':'图片','gif':'图片','bmp':'图片','svg':'图片','webp':'图片',
            'zip':'压缩包','rar':'压缩包','7z':'压缩包','tar':'压缩包','gz':'压缩包',
            'html':'代码','css':'代码','js':'代码','py':'代码','java':'代码','cpp':'代码','c':'代码','cs':'代码'
        };
        return types[ext] || '文件';
    }

    function formatFileSize(bytes) {
        if (bytes === 0) return '0 B';
        var k = 1024, sizes = ['B', 'KB', 'MB', 'GB'];
        var i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }
</script>
</asp:Content>
