<%@ Page Language="C#" MasterPageFile="~/student/Stud.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    protected int currentStudentId = 0;
    protected decimal currentProgress = 0;
    protected int totalChapters = 0;
    protected int completedChapters = 0;
    
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

    private int GetCurrentStudentId()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null)
                        {
                            int sid;
                            if (int.TryParse(v.ToString(), out sid)) return sid;
                        }
                    }
                }
            }
        }
        catch { }
        return 0;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        currentStudentId = GetCurrentStudentId();
        if (currentStudentId <= 0)
        {
            Response.Redirect("../index.aspx?returnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
            return;
        }
        
        if (!IsPostBack)
        {
            LoadResourceDetail();
        }
    }

    private void LoadResourceDetail()
    {
        string fid = Request.QueryString["fid"];
        if (string.IsNullOrEmpty(fid))
        {
            Response.Redirect("myfile.aspx");
            return;
        }
        
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        bool hasChapters = false;
        bool hasCredits = false;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            bool hasCategoryTable = HasResourceCategoriesTable(conn);
            
            string sql = @"SELECT f.FileId, f.FileName, f.FileSize, f.CreateTime, f.RelativePath,
                          f.FileName as DisplayName,
                          '' as CoverImage,
                          0 as ViewCredits,
                          0 as DownloadCredits,
                          0 as ViewCount,
                          0 as DownloadCount,
                          0 as HasChapters,
                          '' as Description,
                          '' as ResourceType,";
            if (hasCategoryTable)
            {
                sql += @"
                          ISNULL(c.CategoryName, '未分类') as CategoryName,
                          ISNULL(c.CategoryColor, '#64748b') as CategoryColor
                          FROM Files f
                          LEFT JOIN ResourceCategories c ON f.CategoryId = c.CategoryId";
            }
            else
            {
                sql += @"
                          N'未分类' as CategoryName,
                          N'#64748b' as CategoryColor
                          FROM Files f";
            }
            sql += @"
                          WHERE f.FileId = @FileId";
            
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@FileId", fid);
            
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                hasChapters = Convert.ToBoolean(reader["HasChapters"]);
                string displayName = reader["DisplayName"].ToString();
                string description = reader["Description"].ToString();
                string categoryName = reader["CategoryName"].ToString();
                string viewCount = reader["ViewCount"].ToString();
                string downloadCount = reader["DownloadCount"].ToString();
                string fileName = reader["FileName"].ToString();
                string fileSize = FormatFileSize(Convert.ToInt64(reader["FileSize"]));
                string viewCredits = reader["ViewCredits"].ToString();
                string downloadCredits = reader["DownloadCredits"].ToString();
                
                if (hasChapters)
                {
                    divHasChapters.Visible = true;
                    divNoChapters.Visible = false;
                    
                    lblResourceName.Text = displayName;
                    lblDescription.Text = description;
                    lblCategoryName.Text = categoryName;
                    lblViewCount.Text = viewCount;
                    lblDownloadCount.Text = downloadCount;
                    lblFileName.Text = fileName;
                    lblFileSize.Text = fileSize;
                    lblViewCredits.Text = viewCredits;
                    lblDownloadCredits.Text = downloadCredits;
                }
                else
                {
                    divHasChapters.Visible = false;
                    divNoChapters.Visible = true;
                    
                    lblResourceName2.Text = displayName;
                    lblDescription2.Text = description;
                    lblCategoryName2.Text = categoryName;
                    lblViewCount2.Text = viewCount;
                    lblDownloadCount2.Text = downloadCount;
                    lblFileName2.Text = fileName;
                    lblFileSize2.Text = fileSize;
                    lblViewCredits2.Text = viewCredits;
                    lblDownloadCredits2.Text = downloadCredits;
                }
                
                string resourceType = reader["ResourceType"].ToString();
                string relativePath = reader["RelativePath"].ToString();
                
                hdnFileId.Value = fid;
                hdnResourceType.Value = resourceType;
                hdnFilePath.Value = relativePath;
                hdnHasChapters.Value = hasChapters.ToString();
                
                int viewCreditsInt = Convert.ToInt32(reader["ViewCredits"]);
                int downloadCreditsInt = Convert.ToInt32(reader["DownloadCredits"]);
                hasCredits = viewCreditsInt > 0 || downloadCreditsInt > 0;
            }
            else
            {
                reader.Close();
                Response.Redirect("myfile.aspx");
                return;
            }
            reader.Close();
            
            // ViewCount 列不存在于当前 Files 表，跳过浏览次数更新
        }
        
        // 在连接关闭后加载章节数据
        if (hasChapters)
        {
            divCreditsSimple.Visible = hasCredits;
            divChapters.Visible = true;
            LoadChapters(fid);
            LoadRelatedResources(fid); // 加载相关资源
        }
        else
        {
            divCreditsSimple2.Visible = hasCredits;
            LoadRelatedResources(fid); // 加载相关资源（无章节资源也需要）
        }
    }

    private void LoadRelatedResources(string currentFileId)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            bool hasCategoryTable = HasResourceCategoriesTable(conn);
            
            // 获取当前资源的分类ID
            string sql = @"SELECT TOP 5 f.FileId, 
                          f.FileName as ResourceName,
                          '' as CoverImage,
                          0 as ViewCount,";
            if (hasCategoryTable)
            {
                sql += @"
                          ISNULL(c.CategoryName, '未分类') as CategoryName,
                          ISNULL(c.CategoryColor, '#64748b') as CategoryColor
                          FROM Files f
                          LEFT JOIN ResourceCategories c ON f.CategoryId = c.CategoryId";
            }
            else
            {
                sql += @"
                          N'未分类' as CategoryName,
                          N'#64748b' as CategoryColor
                          FROM Files f";
            }
            sql += @"
                          WHERE f.FileId != @CurrentFileId 
                          ORDER BY f.CreateTime DESC";
            
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.SelectCommand.Parameters.AddWithValue("@CurrentFileId", currentFileId);
            
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            // 如果同分类资源不足5个，补充其他热门资源
            if (dt.Rows.Count < 5)
            {
                int needed = 5 - dt.Rows.Count;
                
                // 构建已有ID列表
                string existingIds = "0";
                if (dt.Rows.Count > 0)
                {
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();
                    foreach (DataRow row in dt.Rows)
                    {
                        if (sb.Length > 0) sb.Append(",");
                        sb.Append(row["FileId"].ToString());
                    }
                    existingIds = sb.ToString();
                }
                
                string sql2 = @"SELECT TOP " + needed + @" f.FileId, 
                              f.FileName as ResourceName,
                              '' as CoverImage,
                              0 as ViewCount,";
                if (hasCategoryTable)
                {
                    sql2 += @"
                              ISNULL(c.CategoryName, '未分类') as CategoryName,
                              ISNULL(c.CategoryColor, '#64748b') as CategoryColor
                              FROM Files f
                              LEFT JOIN ResourceCategories c ON f.CategoryId = c.CategoryId";
                }
                else
                {
                    sql2 += @"
                              N'未分类' as CategoryName,
                              N'#64748b' as CategoryColor
                              FROM Files f";
                }
                sql2 += @"
                              WHERE f.FileId != @CurrentFileId 
                              AND f.FileId NOT IN (" + existingIds + @")
                              ORDER BY f.CreateTime DESC";
                
                SqlDataAdapter da2 = new SqlDataAdapter(sql2, conn);
                da2.SelectCommand.Parameters.AddWithValue("@CurrentFileId", currentFileId);
                
                DataTable dt2 = new DataTable();
                da2.Fill(dt2);
                
                // 合并结果
                foreach (DataRow row in dt2.Rows)
                {
                    dt.ImportRow(row);
                }
            }
            
            rptRelatedResources.DataSource = dt;
            rptRelatedResources.DataBind();
            
            // 同时绑定第二个Repeater（用于无章节资源）
            rptRelatedResources2.DataSource = dt;
            rptRelatedResources2.DataBind();
        }
    }

    private bool HasResourceCategoriesTable(SqlConnection conn)
    {
        SqlCommand cmd = new SqlCommand("SELECT OBJECT_ID(N'dbo.ResourceCategories', N'U')", conn);
        object result = cmd.ExecuteScalar();
        return result != null && result != DBNull.Value;
    }

    protected string FormatNumber(object num)
    {
        if (num == null || num == DBNull.Value) return "0";
        int n = Convert.ToInt32(num);
        if (n >= 1000000) return (n / 1000000.0).ToString("F1") + "M";
        if (n >= 1000) return (n / 1000.0).ToString("F1") + "K";
        return n.ToString();
    }

    private void LoadChapters(string resourceId)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string sql = @"SELECT ChapterId, ChapterTitle, ChapterOrder, FilePath, Duration, 
                          Credits, IsFree FROM ResourceChapters 
                          WHERE ResourceId = @ResourceId ORDER BY ChapterOrder";
            
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.SelectCommand.Parameters.AddWithValue("@ResourceId", resourceId);
            
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            totalChapters = dt.Rows.Count;
            
            // 调试信息
            System.Diagnostics.Debug.WriteLine("LoadChapters - ResourceId: " + resourceId);
            System.Diagnostics.Debug.WriteLine("LoadChapters - Total Chapters: " + totalChapters);
            
            rptChapters.DataSource = dt;
            rptChapters.DataBind();
        }
        
        LoadLearningProgress(resourceId);
    }

    private void LoadLearningProgress(string resourceId)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            // 查询已完成的章节数
            string sql = @"SELECT COUNT(DISTINCT ChapterId) 
                          FROM ResourceLearningProgress 
                          WHERE StudentId = @StudentId 
                          AND ChapterId IN (SELECT ChapterId FROM ResourceChapters WHERE ResourceId = @ResourceId)
                          AND IsCompleted = 1";
            
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@StudentId", currentStudentId);
            cmd.Parameters.AddWithValue("@ResourceId", resourceId);
            
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                completedChapters = Convert.ToInt32(result);
            }
            
            if (totalChapters > 0)
            {
                currentProgress = (decimal)completedChapters / totalChapters * 100;
            }
            
            // 调试信息
            System.Diagnostics.Debug.WriteLine("LoadLearningProgress - StudentId: " + currentStudentId);
            System.Diagnostics.Debug.WriteLine("LoadLearningProgress - ResourceId: " + resourceId);
            System.Diagnostics.Debug.WriteLine("LoadLearningProgress - Completed Chapters: " + completedChapters);
            System.Diagnostics.Debug.WriteLine("LoadLearningProgress - Total Chapters: " + totalChapters);
            System.Diagnostics.Debug.WriteLine("LoadLearningProgress - Progress: " + currentProgress.ToString("F2") + "%");
        }
    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        string fid = hdnFileId.Value;
        if (string.IsNullOrEmpty(fid)) return;
        
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        // DownloadCount 列不存在于当前 Files 表，跳过下载次数更新
        
        string filePath = hdnFilePath.Value;
        if (!string.IsNullOrEmpty(filePath))
        {
            string physicalPath = Server.MapPath("~" + filePath);
            if (File.Exists(physicalPath))
            {
                Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + Server.UrlEncode(lblFileName.Text));
                Response.TransmitFile(physicalPath);
                Response.End();
            }
        }
    }

    private string FormatFileSize(long bytes)
    {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024.0).ToString("F2") + " KB";
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024.0 * 1024)).ToString("F2") + " MB";
        return (bytes / (1024.0 * 1024 * 1024)).ToString("F2") + " GB";
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="server">
<asp:HiddenField ID="hdnFileId" runat="server" />
<asp:HiddenField ID="hdnResourceType" runat="server" />
<asp:HiddenField ID="hdnFilePath" runat="server" />
<asp:HiddenField ID="hdnHasChapters" runat="server" />

<style>
    * { box-sizing: border-box; }
    .detail-container { max-width: 1400px; margin: 0 auto; padding: 20px; }
    
    .detail-grid { display: block; }
    
    .main-content-with-chapters {
        display: grid; grid-template-columns: 1fr 280px; gap: 20px;
    }
    
    .player-section {
        background: white; border-radius: 20px; overflow: hidden;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    }
    .player-wrapper {
        position: relative; width: 100%; background: #000;
        padding-top: 56.25%; /* 16:9 比例 */
    }
    .player-wrapper video,
    .player-wrapper audio,
    .player-wrapper iframe,
    .player-wrapper img {
        position: absolute; top: 0; left: 0;
        width: 100%; height: 100%;
    }
    .player-wrapper audio {
        top: 50%; transform: translateY(-50%);
        height: 54px;
    }
    .player-wrapper img {
        object-fit: contain;
    }
    .player-placeholder {
        position: absolute; top: 0; left: 0;
        width: 100%; height: 100%;
        display: flex; flex-direction: column;
        align-items: center; justify-content: center;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }
    .player-placeholder svg {
        width: 80px; height: 80px; margin-bottom: 20px;
        stroke: white; fill: none; stroke-width: 2;
    }
    .player-placeholder h3 {
        margin: 0; font-size: 20px; font-weight: 600;
    }
    
    .resource-info {
        padding: 32px;
    }
    .resource-title {
        font-size: 28px; font-weight: 700; color: #1e293b;
        margin: 0 0 16px 0; line-height: 1.3;
    }
    .resource-meta {
        display: flex; gap: 20px; margin-bottom: 24px;
        padding-bottom: 24px; border-bottom: 2px solid #f1f5f9;
    }
    .meta-item {
        display: flex; align-items: center; gap: 8px;
        font-size: 14px; color: #64748b; font-weight: 500;
    }
    .meta-item svg {
        width: 18px; height: 18px; stroke: currentColor;
    }
    .resource-description {
        font-size: 15px; color: #475569; line-height: 1.8;
        margin-bottom: 32px;
        padding-bottom: 24px; border-bottom: 2px solid #f1f5f9;
    }
    
    .info-sections {
        display: grid; grid-template-columns: repeat(2, 1fr); gap: 32px;
        margin-bottom: 24px;
    }
    
    .info-section-simple {
        display: flex; flex-direction: column; gap: 16px;
    }
    .section-header {
        display: flex; align-items: center; gap: 8px;
        font-size: 15px; font-weight: 700; color: #1e293b;
        margin-bottom: 4px;
    }
    .section-header svg {
        width: 18px; height: 18px;
    }
    .section-header.credits svg {
        stroke: #f59e0b;
    }
    .section-header.info svg {
        stroke: #667eea;
    }
    
    .info-items-simple {
        display: flex; flex-direction: column; gap: 12px;
    }
    .info-items-simple.credits-row {
        flex-direction: row;
        gap: 24px;
    }
    .info-items-simple.file-row {
        flex-direction: row;
        gap: 24px;
        flex-wrap: wrap;
    }
    .info-item-simple {
        display: flex; align-items: center; gap: 12px;
        font-size: 14px;
    }
    .info-item-simple .icon {
        width: 32px; height: 32px;
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        position: relative;
    }
    .info-item-simple .icon::before {
        content: '';
        position: absolute;
        width: 18px; height: 18px;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
    }
    .info-item-simple.credit .icon {
        background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
    }
    .info-item-simple.credit.view .icon::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23d97706' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/%3E%3Ccircle cx='12' cy='12' r='3'/%3E%3C/svg%3E");
    }
    .info-item-simple.credit.download .icon::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23d97706' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3'/%3E%3C/svg%3E");
    }
    .info-item-simple .content {
        display: flex; align-items: baseline; gap: 8px;
        white-space: nowrap;
    }
    .info-item-simple .value {
        font-size: 20px; font-weight: 700;
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    .info-item-simple .label {
        font-size: 14px; color: #64748b; font-weight: 500;
    }
    
    .info-item-simple.file {
        color: #475569;
    }
    .info-item-simple.file .icon {
        background: #f1f5f9;
    }
    .info-item-simple.file.filename .icon::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23667eea' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z'/%3E%3Cpath d='M13 2v7h7'/%3E%3C/svg%3E");
    }
    .info-item-simple.file.filesize .icon::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2310b981' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cellipse cx='12' cy='5' rx='9' ry='3'/%3E%3Cpath d='M21 12c0 1.66-4 3-9 3s-9-1.34-9-3'/%3E%3Cpath d='M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5'/%3E%3C/svg%3E");
    }
    .info-item-simple.file.filetime .icon::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cpath d='M12 6v6l4 2'/%3E%3C/svg%3E");
    }
    .info-item-simple.file .content {
        display: flex; align-items: center; gap: 8px;
        flex: 1;
        min-width: 0;
    }
    .info-item-simple.file .text {
        font-weight: 500;
        flex-shrink: 0;
    }
    .info-item-simple.file .value-text {
        color: #1e293b;
        font-weight: 600;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
    
    .action-buttons-inline {
        display: flex; gap: 12px; margin-top: 24px;
        padding-top: 24px; border-top: 2px solid #f1f5f9;
    }
    .action-buttons-inline .btn-primary,
    .action-buttons-inline .btn-secondary {
        flex: 1;
    }
    
    @media (max-width: 768px) {
        .info-sections {
            grid-template-columns: 1fr;
        }
        .info-items-simple.credits-row {
            flex-direction: column;
            gap: 12px;
        }
    }
    
    .chapters-section {
        background: white; border-radius: 16px; padding: 20px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        border: 1px solid #f1f5f9;
        max-height: calc(100vh - 180px);
        overflow-y: auto;
        position: sticky;
        top: 20px;
    }
    .chapters-section::-webkit-scrollbar {
        width: 6px;
    }
    .chapters-section::-webkit-scrollbar-track {
        background: #f1f5f9;
        border-radius: 3px;
    }
    .chapters-section::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 3px;
    }
    .chapters-section::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }
    
    .learning-progress-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 16px;
        color: white;
        position: relative;
        overflow: hidden;
    }
    .learning-progress-card::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -20px;
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: rgba(255,255,255,0.1);
    }
    
    /* 单资源学习进度条样式 */
    .single-resource-progress {
        background: white;
        border-radius: 12px;
        padding: 16px 20px;
        margin: 20px 0;
    }
    
    /* 完成提示样式 */
    .completion-message {
        display: flex;
        align-items: center;
        gap: 16px;
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        border-radius: 12px;
        padding: 20px 24px;
        margin: 20px 0;
        box-shadow: 0 4px 16px rgba(16, 185, 129, 0.2);
        animation: slideInDown 0.5s ease-out;
    }
    @keyframes slideInDown {
        from {
            opacity: 0;
            transform: translateY(-20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .completion-icon {
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        background: rgba(255, 255, 255, 0.2);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .completion-icon svg {
        stroke: white;
    }
    .completion-text {
        flex: 1;
    }
    .completion-title {
        font-size: 18px;
        font-weight: 700;
        color: white;
        margin-bottom: 4px;
    }
    .completion-subtitle {
        font-size: 13px;
        color: rgba(255, 255, 255, 0.9);
        font-weight: 500;
    }
    .progress-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
    }
    .progress-label {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        font-weight: 600;
        color: #1e293b;
    }
    .progress-label svg {
        stroke: #10b981;
    }
    .progress-time {
        font-size: 13px;
        font-weight: 500;
        color: #64748b;
    }
    .single-progress-bar {
        height: 8px;
        background: #f1f5f9;
        border-radius: 10px;
        overflow: hidden;
        margin-bottom: 8px;
    }
    .single-progress-fill {
        height: 100%;
        background: linear-gradient(90deg, #10b981 0%, #059669 100%);
        border-radius: 10px;
        width: 0%;
        transition: width 0.3s ease;
        box-shadow: 0 0 8px rgba(16, 185, 129, 0.3);
    }
    .progress-percentage-text {
        text-align: right;
        font-size: 12px;
        color: #10b981;
        font-weight: 600;
    }
    
    .progress-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
        position: relative;
        z-index: 1;
    }
    .progress-title {
        font-size: 14px;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .progress-title svg {
        width: 16px;
        height: 16px;
        stroke: white;
    }
    .progress-percentage {
        font-size: 18px;
        font-weight: 800;
    }
    .progress-bar-container {
        height: 8px;
        background: rgba(255,255,255,0.2);
        border-radius: 10px;
        overflow: hidden;
        margin-bottom: 8px;
        position: relative;
        z-index: 1;
    }
    .progress-bar-fill {
        height: 100%;
        background: white;
        border-radius: 10px;
        transition: width 0.5s ease;
    }
    .progress-stats {
        display: flex;
        justify-content: space-between;
        font-size: 12px;
        opacity: 0.9;
        position: relative;
        z-index: 1;
    }
    
    .chapters-title {
        font-size: 15px; font-weight: 700; color: #1e293b;
        margin: 0 0 14px 0; display: flex; align-items: center; gap: 6px;
        padding-bottom: 10px; border-bottom: 2px solid #f1f5f9;
    }
    .chapters-title svg {
        width: 16px; height: 16px; stroke: #667eea;
    }
    .chapter-list {
        display: flex; flex-direction: column; gap: 8px;
    }
    .chapter-item {
        padding: 10px 12px; background: #f8fafc;
        border-radius: 10px; border: 1.5px solid #e2e8f0;
        transition: all 0.3s; cursor: pointer;
        display: flex; align-items: center; gap: 10px;
    }
    .chapter-item:hover {
        border-color: #667eea; background: #f0f4ff;
        transform: translateX(2px);
    }
    .chapter-number {
        width: 28px; height: 28px; border-radius: 8px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; display: flex; align-items: center;
        justify-content: center; font-weight: 700; font-size: 13px;
        flex-shrink: 0;
    }
    .chapter-info {
        flex: 1; min-width: 0;
    }
    .chapter-title {
        font-size: 13px; font-weight: 600; color: #1e293b;
        margin-bottom: 4px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
    .chapter-meta {
        font-size: 11px; color: #64748b;
        display: flex; align-items: center; gap: 8px;
        flex-wrap: wrap;
    }
    
    .sidebar {
        display: flex; flex-direction: column; gap: 20px;
    }
    .info-card {
        background: white; border-radius: 16px; padding: 24px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        border: 1px solid #f1f5f9;
    }
    .info-card-title {
        font-size: 16px; font-weight: 700; color: #1e293b;
        margin: 0 0 20px 0; padding-bottom: 12px;
        border-bottom: 2px solid #f1f5f9;
        display: flex; align-items: center; gap: 8px;
    }
    .info-card-title svg {
        width: 18px; height: 18px; stroke: #667eea;
    }
    .info-row {
        display: flex; justify-content: space-between; align-items: center;
        padding: 12px 0;
    }
    .info-row:not(:last-child) {
        border-bottom: 1px solid #f8fafc;
    }
    .info-label {
        font-size: 13px; color: #94a3b8; font-weight: 500;
    }
    .info-value {
        font-size: 14px; color: #1e293b; font-weight: 600;
        text-align: right; max-width: 60%;
        word-break: break-all;
    }
    
    .credits-card {
        background: transparent;
        border-radius: 0; padding: 0;
        box-shadow: none;
        border: none;
    }
    .credits-title {
        font-size: 15px; font-weight: 700; color: #1e293b;
        margin: 0 0 16px 0; display: flex; align-items: center; gap: 8px;
        padding-bottom: 12px; border-bottom: 2px solid #f1f5f9;
    }
    .credits-title svg {
        width: 18px; height: 18px; stroke: #f59e0b;
    }
    .credits-grid {
        display: grid; grid-template-columns: 1fr 1fr; gap: 12px;
    }
    .credit-item {
        background: white;
        border: 2px solid #f1f5f9;
        border-radius: 12px;
        padding: 16px 12px; text-align: center;
        transition: all 0.3s;
        position: relative;
        overflow: hidden;
    }
    .credit-item::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 3px;
        background: linear-gradient(90deg, #f59e0b, #fbbf24);
        opacity: 0;
        transition: all 0.3s;
    }
    .credit-item:hover {
        border-color: #fbbf24;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(251, 191, 36, 0.15);
    }
    .credit-item:hover::before {
        opacity: 1;
    }
    .credit-value {
        font-size: 28px; font-weight: 800; 
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 6px; line-height: 1;
    }
    .credit-label {
        font-size: 13px; color: #64748b; font-weight: 600;
    }
    
    .action-buttons {
        display: flex; flex-direction: column; gap: 10px;
    }
    .btn-primary {
        width: 100%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; border: none; padding: 14px 20px 14px 48px;
        border-radius: 12px; font-size: 15px; font-weight: 700;
        cursor: pointer; transition: all 0.3s;
        box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
        display: flex; align-items: center; justify-content: center;
        position: relative;
    }
    .btn-primary::before {
        content: '';
        position: absolute; left: 20px; top: 50%;
        transform: translateY(-50%);
        width: 18px; height: 18px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10'/%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
    }
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 24px rgba(102, 126, 234, 0.4);
    }
    .btn-secondary {
        width: 100%; background: white;
        color: #64748b; border: 1.5px solid #e2e8f0; padding: 12px 20px 12px 44px;
        border-radius: 12px; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: all 0.3s;
        display: flex; align-items: center; justify-content: center;
        position: relative;
    }
    .btn-secondary::before {
        content: '';
        position: absolute; left: 18px; top: 50%;
        transform: translateY(-50%);
        width: 16px; height: 16px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M10 19l-7-7m0 0l7-7m-7 7h18'/%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
    }
    .btn-secondary:hover {
        background: #f8fafc; border-color: #cbd5e1;
        color: #475569;
    }
    .btn-secondary:hover::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23475569' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M10 19l-7-7m0 0l7-7m-7 7h18'/%3E%3C/svg%3E");
    }
    
    /* 相关资源推荐 */
    .related-resources-section {
        margin-top: 24px;
        padding-top: 20px;
        border-top: 1px solid #f1f5f9;
    }
    .related-title {
        font-size: 15px;
        font-weight: 700;
        color: #1e293b;
        margin: 0 0 16px 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .related-title svg {
        width: 18px;
        height: 18px;
        stroke: #10b981;
    }
    .related-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .related-item {
        display: flex;
        gap: 12px;
        padding: 12px;
        border-radius: 12px;
        background: #f8fafc;
        border: 1px solid #f1f5f9;
        transition: all 0.3s;
        text-decoration: none;
        color: inherit;
    }
    .related-item:hover {
        background: white;
        border-color: #10b981;
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
        transform: translateX(4px);
    }
    .related-cover {
        width: 60px;
        height: 60px;
        border-radius: 8px;
        overflow: hidden;
        flex-shrink: 0;
        background: #e2e8f0;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .related-cover img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .related-icon {
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .related-icon svg {
        width: 28px;
        height: 28px;
    }
    .related-info {
        flex: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
        gap: 6px;
    }
    .related-name {
        font-size: 13px;
        font-weight: 600;
        color: #1e293b;
        line-height: 1.4;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
    }
    .related-meta {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 11px;
    }
    .related-category {
        font-weight: 600;
        padding: 2px 8px;
        border-radius: 4px;
        background: rgba(16, 185, 129, 0.1);
    }
    .related-views {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #64748b;
    }
    .related-views svg {
        width: 12px;
        height: 12px;
    }
    
    @media (max-width: 1024px) {
        .detail-grid {
            grid-template-columns: 1fr;
        }
        .main-content-with-chapters {
            grid-template-columns: 1fr;
        }
        .chapters-section {
            position: static;
            max-height: none;
        }
    }
</style>

<div class="detail-container">
    <div class="detail-grid">
        <div class="main-content">
            <div id="divHasChapters" runat="server" visible="false">
                <div class="main-content-with-chapters">
                    <div class="player-section">
                        <div class="player-wrapper" id="playerWrapper">
                            <div class="player-placeholder">
                                <svg viewBox="0 0 24 24">
                                    <path d="M14.752 11.168l-6.518-3.761A1 1 0 007 8.237v7.526a1 1 0 001.234.97l6.518-3.761a1 1 0 000-1.804z"/>
                                    <circle cx="12" cy="12" r="10"/>
                                </svg>
                                <h3>准备播放器...</h3>
                            </div>
                        </div>
                        <div class="resource-info">
                            <h1 class="resource-title"><asp:Label ID="lblResourceName" runat="server"></asp:Label></h1>
                            <div class="resource-meta">
                                <div class="meta-item">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
                                    </svg>
                                    <span><asp:Label ID="lblCategoryName" runat="server"></asp:Label></span>
                                </div>
                                <div class="meta-item">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                    <span><asp:Label ID="lblViewCount" runat="server"></asp:Label> 次浏览</span>
                                </div>
                                <div class="meta-item">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/>
                                    </svg>
                                    <span><asp:Label ID="lblDownloadCount" runat="server"></asp:Label> 次下载</span>
                                </div>
                            </div>
                            <div class="resource-description">
                                <asp:Label ID="lblDescription" runat="server"></asp:Label>
                            </div>
                            
                            <div class="info-sections">
                                <div class="info-section-simple" id="divCreditsSimple" runat="server">
                                    <div class="section-header credits">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <circle cx="12" cy="12" r="10"/>
                                            <path d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/>
                                        </svg>
                                        积分奖励
                                    </div>
                                    <div class="info-items-simple credits-row">
                                        <div class="info-item-simple credit view">
                                            <div class="icon"></div>
                                            <div class="content">
                                                <span class="value">+<asp:Label ID="lblViewCredits" runat="server"></asp:Label></span>
                                                <span class="label">观看积分</span>
                                            </div>
                                        </div>
                                        <div class="info-item-simple credit download">
                                            <div class="icon"></div>
                                            <div class="content">
                                                <span class="value">+<asp:Label ID="lblDownloadCredits" runat="server"></asp:Label></span>
                                                <span class="label">下载积分</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="info-section-simple">
                                    <div class="section-header info">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <circle cx="12" cy="12" r="10"/>
                                            <path d="M12 16v-4M12 8h.01"/>
                                        </svg>
                                        资源信息
                                    </div>
                                    <div class="info-items-simple file-row">
                                        <div class="info-item-simple file filename">
                                            <div class="icon"></div>
                                            <div class="content">
                                                <span class="text">文件名</span>
                                                <span class="value-text"><asp:Label ID="lblFileName" runat="server"></asp:Label></span>
                                            </div>
                                        </div>
                                        <div class="info-item-simple file filesize">
                                            <div class="icon"></div>
                                            <div class="content">
                                                <span class="text">文件大小</span>
                                                <span class="value-text"><asp:Label ID="lblFileSize" runat="server"></asp:Label></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="action-buttons-inline">
                                <asp:Button ID="btnDownload" runat="server" CssClass="btn-primary" OnClick="btnDownload_Click" Text="下载资源" />
                                <button type="button" class="btn-secondary" onclick="window.history.back()">返回列表</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="chapters-section" id="divChapters" runat="server" visible="false">
                        <div class="learning-progress-card">
                            <div class="progress-header">
                                <div class="progress-title">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                    </svg>
                                    学习进度
                                </div>
                                <div class="progress-percentage" id="progressPercentage"><%= currentProgress.ToString("F0") %>%</div>
                            </div>
                            <div class="progress-bar-container">
                                <div class="progress-bar-fill" id="progressBarFill" style="width:<%= currentProgress.ToString("F0") %>%"></div>
                            </div>
                            <div class="progress-stats">
                                <span>已完成 <strong id="completedCount"><%= completedChapters %></strong> / <strong id="totalCount"><%= totalChapters %></strong> 章节</span>
                                <span id="progressStatus"><%= currentProgress >= 100 ? "✓ 已完成" : "学习中..." %></span>
                            </div>
                            <!-- 调试信息（开发时使用，生产环境可删除） -->
                            <div style="display:none;" id="debugInfo">
                                <small style="color:rgba(255,255,255,0.7);font-size:10px;">
                                    Debug: StudentId=<%= currentStudentId %>, 
                                    ResourceId=<%= hdnFileId.Value %>, 
                                    Total=<%= totalChapters %>, 
                                    Completed=<%= completedChapters %>
                                </small>
                            </div>
                        </div>
                        
                        <h2 class="chapters-title">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                            </svg>
                            课程章节
                        </h2>
                        <div class="chapter-list">
                            <asp:Repeater ID="rptChapters" runat="server">
                                <ItemTemplate>
                                    <div class="chapter-item" onclick="playChapter('<%# Eval("ChapterId") %>', '<%# Eval("FilePath") %>', '<%# Eval("ChapterTitle") %>')">
                                        <div class="chapter-number"><%# Eval("ChapterOrder") %></div>
                                        <div class="chapter-info">
                                            <div class="chapter-title"><%# Eval("ChapterTitle") %></div>
                                            <div class="chapter-meta">
                                                <%# Convert.ToBoolean(Eval("IsFree")) ? "<span style='color:#10b981;font-weight:600;'>🎁 免费</span>" : "<span style='color:#f59e0b;'>💎 " + Eval("Credits") + " 积分</span>" %>
                                                <%# !string.IsNullOrEmpty(Eval("Duration").ToString()) ? "<span>⏱ " + Eval("Duration") + "</span>" : "" %>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        
                        <!-- 相关资源推荐 -->
                        <div class="related-resources-section">
                            <h3 class="related-title">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M13 10V3L4 14h7v7l9-11h-7z"/>
                                </svg>
                                相关推荐
                            </h3>
                            <div class="related-list">
                                <asp:Repeater ID="rptRelatedResources" runat="server">
                                    <ItemTemplate>
                                        <a href='resourcedetail.aspx?fid=<%# Eval("FileId") %>' class="related-item">
                                            <div class="related-cover">
                                                <%# string.IsNullOrEmpty(Eval("CoverImage").ToString()) ? 
                                                    "<div class='related-icon' style='background:" + Eval("CategoryColor") + "'>" +
                                                    "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2'><path d='M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z'/><polyline points='14 2 14 8 20 8'/></svg>" +
                                                    "</div>" :
                                                    "<img src='" + ResolveUrl("~" + Eval("CoverImage")) + "' alt='封面' />" %>
                                            </div>
                                            <div class="related-info">
                                                <div class="related-name"><%# Eval("ResourceName") %></div>
                                                <div class="related-meta">
                                                    <span class="related-category" style="color:<%# Eval("CategoryColor") %>">
                                                        <%# Eval("CategoryName") %>
                                                    </span>
                                                    <span class="related-views">
                                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                            <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                            <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                                        </svg>
                                                        <%# FormatNumber(Eval("ViewCount")) %>
                                                    </span>
                                                </div>
                                            </div>
                                        </a>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="divNoChapters" runat="server" visible="false">
                <div class="main-content-with-chapters">
                    <div class="player-section">
                        <div class="player-wrapper" id="playerWrapper2">
                            <div class="player-placeholder">
                                <svg viewBox="0 0 24 24">
                                    <path d="M14.752 11.168l-6.518-3.761A1 1 0 007 8.237v7.526a1 1 0 001.234.97l6.518-3.761a1 1 0 000-1.804z"/>
                                    <circle cx="12" cy="12" r="10"/>
                                </svg>
                                <h3>准备播放器...</h3>
                            </div>
                        </div>
                        
                        <!-- 单资源学习进度条 -->
                        <div class="single-resource-progress" id="singleResourceProgress" style="display:none;">
                            <div class="progress-info">
                                <div class="progress-label">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:16px;height:16px;">
                                        <path d="M14.752 11.168l-6.518-3.761A1 1 0 007 8.237v7.526a1 1 0 001.234.97l6.518-3.761a1 1 0 000-1.804z"/>
                                        <circle cx="12" cy="12" r="10"/>
                                    </svg>
                                    <span>播放进度</span>
                                </div>
                                <div class="progress-time">
                                    <span id="currentTime2">00:00</span> / <span id="totalTime2">00:00</span>
                                </div>
                            </div>
                            <div class="single-progress-bar">
                                <div class="single-progress-fill" id="singleProgressFill"></div>
                            </div>
                            <div class="progress-percentage-text" id="singleProgressPercentage">0%</div>
                        </div>
                        
                        <div class="resource-info">
                            <h1 class="resource-title"><asp:Label ID="lblResourceName2" runat="server"></asp:Label></h1>
                            <div class="resource-meta">
                                <div class="meta-item">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
                                </svg>
                                <span><asp:Label ID="lblCategoryName2" runat="server"></asp:Label></span>
                            </div>
                            <div class="meta-item">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                </svg>
                                <span><asp:Label ID="lblViewCount2" runat="server"></asp:Label> 次浏览</span>
                            </div>
                            <div class="meta-item">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/>
                                </svg>
                                <span><asp:Label ID="lblDownloadCount2" runat="server"></asp:Label> 次下载</span>
                            </div>
                        </div>
                        <div class="resource-description">
                            <asp:Label ID="lblDescription2" runat="server"></asp:Label>
                        </div>
                        
                        <div class="info-sections">
                            <div class="info-section-simple" id="divCreditsSimple2" runat="server">
                                <div class="section-header credits">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"/>
                                        <path d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/>
                                    </svg>
                                    积分奖励
                                </div>
                                <div class="info-items-simple credits-row">
                                    <div class="info-item-simple credit view">
                                        <div class="icon"></div>
                                        <div class="content">
                                            <span class="value">+<asp:Label ID="lblViewCredits2" runat="server"></asp:Label></span>
                                            <span class="label">观看积分</span>
                                        </div>
                                    </div>
                                    <div class="info-item-simple credit download">
                                        <div class="icon"></div>
                                        <div class="content">
                                            <span class="value">+<asp:Label ID="lblDownloadCredits2" runat="server"></asp:Label></span>
                                            <span class="label">下载积分</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="info-section-simple">
                                <div class="section-header info">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"/>
                                        <path d="M12 16v-4M12 8h.01"/>
                                    </svg>
                                    资源信息
                                </div>
                                <div class="info-items-simple file-row">
                                    <div class="info-item-simple file filename">
                                        <div class="icon"></div>
                                        <div class="content">
                                            <span class="text">文件名</span>
                                            <span class="value-text"><asp:Label ID="lblFileName2" runat="server"></asp:Label></span>
                                        </div>
                                    </div>
                                    <div class="info-item-simple file filesize">
                                        <div class="icon"></div>
                                        <div class="content">
                                            <span class="text">文件大小</span>
                                            <span class="value-text"><asp:Label ID="lblFileSize2" runat="server"></asp:Label></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="action-buttons-inline">
                            <asp:Button ID="btnDownload2" runat="server" CssClass="btn-primary" OnClick="btnDownload_Click" Text="下载资源" />
                            <button type="button" class="btn-secondary" onclick="window.history.back()">返回列表</button>
                        </div>
                    </div>
                </div>
                
                <!-- 右侧推荐区域 -->
                <div class="chapters-section">
                    <h2 class="chapters-title">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M13 10V3L4 14h7v7l9-11h-7z"/>
                        </svg>
                        相关推荐
                    </h2>
                    <div class="related-list">
                        <asp:Repeater ID="rptRelatedResources2" runat="server">
                            <ItemTemplate>
                                <a href='resourcedetail.aspx?fid=<%# Eval("FileId") %>' class="related-item">
                                    <div class="related-cover">
                                        <%# string.IsNullOrEmpty(Eval("CoverImage").ToString()) ? 
                                            "<div class='related-icon' style='background:" + Eval("CategoryColor") + "'>" +
                                            "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2'><path d='M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z'/><polyline points='14 2 14 8 20 8'/></svg>" +
                                            "</div>" :
                                            "<img src='" + ResolveUrl("~" + Eval("CoverImage")) + "' alt='封面' />" %>
                                    </div>
                                    <div class="related-info">
                                        <div class="related-name"><%# Eval("ResourceName") %></div>
                                        <div class="related-meta">
                                            <span class="related-category" style="color:<%# Eval("CategoryColor") %>">
                                                <%# Eval("CategoryName") %>
                                            </span>
                                            <span class="related-views">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                    <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                                </svg>
                                                <%# FormatNumber(Eval("ViewCount")) %>
                                            </span>
                                        </div>
                                    </div>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    var currentChapterId = 0;
    var currentResourceId = 0;
    var progressUpdateInterval = null;
    var currentVideoElement = null;
    
    window.onload = function() {
        currentResourceId = parseInt(document.getElementById('<%= hdnFileId.ClientID %>').value);
        
        // 显示调试信息
        var debugInfo = document.getElementById('debugInfo');
        if (debugInfo) {
            debugInfo.style.display = 'block';
        }
        
        // 输出初始状态
        console.log('=== 页面加载完成 ===');
        console.log('Current Resource ID:', currentResourceId);
        console.log('Current Student ID:', <%= currentStudentId %>);
        console.log('Total Chapters:', <%= totalChapters %>);
        console.log('Completed Chapters:', <%= completedChapters %>);
        console.log('Current Progress:', <%= currentProgress.ToString("F2") %>);
        
        initPlayer();
    };
    
    function initPlayer() {
        var resourceType = document.getElementById('<%= hdnResourceType.ClientID %>').value;
        var filePath = document.getElementById('<%= hdnFilePath.ClientID %>').value;
        var hasChapters = document.getElementById('<%= hdnHasChapters.ClientID %>').value;
        
        var playerWrapper = hasChapters === 'True' ? 
            document.getElementById('playerWrapper') : 
            document.getElementById('playerWrapper2');
            
        if (!playerWrapper) return;
        
        if (!filePath) {
            console.log('No file path available');
            return;
        }
        
        var playerHtml = createPlayerHtml(filePath, resourceType, false);
        playerWrapper.innerHTML = playerHtml;
        
        if (hasChapters !== 'True') {
            // 单资源，显示进度条并附加监听器
            var progressDiv = document.getElementById('singleResourceProgress');
            if (progressDiv) {
                progressDiv.style.display = 'block';
            }
            attachVideoListeners(playerWrapper, true);
            // 加载上次学习进度
            loadLastProgress();
        }
    }
    
    function loadLastProgress() {
        console.log('Loading last progress for resource:', currentResourceId);
        
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'GetLastProgress.ashx?resourceId=' + currentResourceId, true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    console.log('Last progress response:', data);
                    
                    // 检查是否已完成
                    if (data.success && data.isCompleted) {
                        console.log('Resource already completed, showing completion message');
                        singleResourceCompleted = true; // 标记为已完成，避免再次弹窗
                        
                        // 隐藏进度条
                        var progressDiv = document.getElementById('singleResourceProgress');
                        if (progressDiv) {
                            progressDiv.style.display = 'none';
                        }
                        
                        // 创建并显示完成提示
                        var playerWrapper = document.getElementById('playerWrapper2');
                        if (playerWrapper) {
                            var completionDiv = document.getElementById('completionMessage');
                            if (!completionDiv) {
                                completionDiv = document.createElement('div');
                                completionDiv.id = 'completionMessage';
                                completionDiv.className = 'completion-message';
                                completionDiv.innerHTML = '<div class="completion-icon">' +
                                    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="width:32px;height:32px;">' +
                                    '<path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>' +
                                    '</svg>' +
                                    '</div>' +
                                    '<div class="completion-text">' +
                                    '<div class="completion-title">已完成该课程学习</div>' +
                                    '<div class="completion-subtitle">您可以继续观看复习内容</div>' +
                                    '</div>';
                                
                                // 插入到播放器后面
                                if (playerWrapper.nextElementSibling) {
                                    playerWrapper.parentNode.insertBefore(completionDiv, playerWrapper.nextElementSibling);
                                } else {
                                    playerWrapper.parentNode.appendChild(completionDiv);
                                }
                            }
                            completionDiv.style.display = 'flex';
                        }
                        
                        // 如果有上次播放位置，跳转到该位置
                        if (data.lastPosition > 0) {
                            setTimeout(function() {
                                var video = document.getElementById('videoPlayer');
                                if (video && video.duration > 0) {
                                    video.currentTime = data.lastPosition;
                                    console.log('Resumed from last position:', data.lastPosition);
                                }
                            }, 1000);
                        }
                    } else if (data.success && data.lastPosition > 0) {
                        // 未完成但有上次位置，跳转到上次位置
                        setTimeout(function() {
                            var video = document.getElementById('videoPlayer');
                            if (video && video.duration > 0) {
                                video.currentTime = data.lastPosition;
                                console.log('Resumed from last position:', data.lastPosition);
                            }
                        }, 1000);
                    }
                } catch(e) {
                    console.error('Error parsing last progress:', e);
                }
            }
        };
        xhr.send();
    }
    
    function createPlayerHtml(filePath, resourceType, autoplay) {
        var ext = filePath.split('.').pop().toLowerCase();
        var playerHtml = '';
        var autoplayAttr = autoplay ? ' autoplay' : '';
        
        if (resourceType === '视频' || resourceType === 'video' || ['mp4', 'webm', 'ogg', 'avi', 'mov', 'mkv', 'flv'].indexOf(ext) >= 0) {
            playerHtml = '<video id="videoPlayer" controls controlsList="nodownload" style="width:100%;height:100%;background:#000;"' + autoplayAttr + '>' +
                        '<source src="' + filePath + '" type="video/mp4">' +
                        '您的浏览器不支持视频播放。' +
                        '</video>';
        }
        else if (resourceType === '音频' || resourceType === 'audio' || ['mp3', 'wav', 'ogg', 'aac', 'flac', 'wma'].indexOf(ext) >= 0) {
            playerHtml = '<audio id="videoPlayer" controls controlsList="nodownload" style="width:100%;"' + autoplayAttr + '>' +
                        '<source src="' + filePath + '" type="audio/mpeg">' +
                        '您的浏览器不支持音频播放。' +
                        '</audio>';
        }
        else if (resourceType === '图片' || resourceType === 'image' || ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'].indexOf(ext) >= 0) {
            playerHtml = '<img src="' + filePath + '" alt="图片资源" style="width:100%;height:100%;object-fit:contain;" />';
        }
        else if (ext === 'pdf') {
            playerHtml = '<iframe src="' + filePath + '" style="width:100%;height:100%;border:none;"></iframe>';
        }
        else if (resourceType === '文档' || resourceType === 'document') {
            playerHtml = '<div class="player-placeholder">' +
                        '<svg viewBox="0 0 24 24" style="width:80px;height:80px;stroke:white;fill:none;stroke-width:2;">' +
                        '<path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>' +
                        '</svg>' +
                        '<h3>文档资源</h3>' +
                        '<p style="margin:8px 0 0 0;opacity:0.9;">请点击下载按钮下载查看</p>' +
                        '</div>';
        }
        else {
            playerHtml = '<div class="player-placeholder">' +
                        '<svg viewBox="0 0 24 24" style="width:80px;height:80px;stroke:white;fill:none;stroke-width:2;">' +
                        '<path d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/>' +
                        '</svg>' +
                        '<h3>资源文件</h3>' +
                        '<p style="margin:8px 0 0 0;opacity:0.9;">请点击下载按钮下载查看</p>' +
                        '</div>';
        }
        
        return playerHtml;
    }
    
    function attachVideoListeners(playerWrapper, isSingleResource) {
        setTimeout(function() {
            var video = playerWrapper.querySelector('#videoPlayer');
            if (video) {
                currentVideoElement = video;
                
                console.log('Video element found, attaching listeners');
                console.log('Is single resource:', isSingleResource);
                console.log('Current chapter ID:', currentChapterId);
                console.log('Current resource ID:', currentResourceId);
                
                video.addEventListener('timeupdate', function() {
                    if (video.duration > 0) {
                        var progress = (video.currentTime / video.duration) * 100;
                        
                        // 更新单资源进度条
                        if (isSingleResource) {
                            updateSingleResourceProgress(video.currentTime, video.duration, progress);
                            // 自动保存进度（每5秒）
                            saveProgress(0, progress, Math.floor(video.currentTime));
                        }
                        
                        // 只有当章节ID大于0时才更新章节进度
                        if (currentChapterId > 0) {
                            updateProgress(currentChapterId, progress, Math.floor(video.currentTime));
                        }
                        
                        // 当播放进度超过90%时，自动标记为完成
                        if (progress >= 90 && currentChapterId > 0) {
                            video.removeEventListener('timeupdate', arguments.callee);
                            completeChapter(currentChapterId);
                        }
                        
                        // 单资源播放到90%时标记完成（但不移除监听器，允许继续播放）
                        if (progress >= 90 && isSingleResource && currentChapterId === 0) {
                            completeSingleResource();
                        }
                    }
                });
                
                video.addEventListener('ended', function() {
                    console.log('Video ended');
                    if (currentChapterId > 0) {
                        completeChapter(currentChapterId);
                    } else if (isSingleResource) {
                        completeSingleResource();
                    }
                });
                
                // 页面关闭前保存进度
                window.addEventListener('beforeunload', function() {
                    if (video && video.duration > 0 && isSingleResource) {
                        var progress = (video.currentTime / video.duration) * 100;
                        saveProgress(0, progress, Math.floor(video.currentTime), true);
                    }
                });
            } else {
                console.log('Video element not found');
            }
        }, 500);
    }
    
    var lastProgressSave = 0;
    function saveProgress(chapterId, progress, lastPosition, isSync) {
        var now = Date.now();
        if (!isSync && now - lastProgressSave < 5000) return;
        lastProgressSave = now;
        
        console.log('Saving progress - Position:', lastPosition, 'Progress:', progress.toFixed(2) + '%');
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'UpdateLearningProgress.ashx', isSync ? false : true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        if (!isSync) {
            xhr.onload = function() {
                if (xhr.status === 200) {
                    console.log('Progress saved:', xhr.responseText);
                }
            };
        }
        xhr.send('action=updateProgress&resourceId=' + currentResourceId + 
                 '&chapterId=' + chapterId + '&progress=' + progress + 
                 '&lastPosition=' + lastPosition);
    }
    
    function updateSingleResourceProgress(currentTime, duration, progress) {
        var progressFill = document.getElementById('singleProgressFill');
        var progressPercentage = document.getElementById('singleProgressPercentage');
        var currentTimeEl = document.getElementById('currentTime2');
        var totalTimeEl = document.getElementById('totalTime2');
        
        if (progressFill) {
            progressFill.style.width = progress.toFixed(2) + '%';
        }
        
        if (progressPercentage) {
            progressPercentage.textContent = Math.round(progress) + '%';
        }
        
        if (currentTimeEl) {
            currentTimeEl.textContent = formatTime(currentTime);
        }
        
        if (totalTimeEl) {
            totalTimeEl.textContent = formatTime(duration);
        }
    }
    
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds === Infinity) return '00:00';
        
        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        var secs = Math.floor(seconds % 60);
        
        if (hours > 0) {
            return pad(hours) + ':' + pad(minutes) + ':' + pad(secs);
        }
        return pad(minutes) + ':' + pad(secs);
    }
    
    function pad(num) {
        return (num < 10 ? '0' : '') + num;
    }
    
    var singleResourceCompleted = false;
    function completeSingleResource() {
        if (singleResourceCompleted) {
            console.log('Single resource already marked as completed in this session');
            return;
        }
        
        console.log('Single resource completed');
        singleResourceCompleted = true;
        
        // 保存单资源完成状态
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'UpdateLearningProgress.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log('Single resource completion saved:', xhr.responseText);
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        // 检查是否有积分奖励（只在第一次完成时发放）
                        checkSingleResourceCompletion();
                    }
                } catch(e) {
                    console.error('Error parsing response:', e);
                }
            }
        };
        xhr.send('action=completeChapter&resourceId=' + currentResourceId + '&chapterId=0');
    }
    
    function checkSingleResourceCompletion() {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'UpdateLearningProgress.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log('Single resource completion check:', xhr.responseText);
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success && response.completed && response.credits > 0) {
                        console.log('First time completion! Awarding credits:', response.credits);
                        showCompletionModal(response.credits);
                    } else if (response.success && response.completed && response.credits === 0) {
                        console.log('Already completed before, no credits awarded');
                    }
                } catch(e) {
                    console.error('Error parsing completion response:', e);
                }
            }
        };
        xhr.send('action=checkCompletion&resourceId=' + currentResourceId);
    }
    
    function playChapter(chapterId, filePath, title) {
        currentChapterId = parseInt(chapterId);
        
        console.log('Playing chapter:', currentChapterId, 'File:', filePath, 'Title:', title);
        
        var playerWrapper = document.getElementById('playerWrapper');
        if (!playerWrapper) {
            console.error('Player wrapper not found');
            return;
        }
        
        if (progressUpdateInterval) {
            clearInterval(progressUpdateInterval);
        }
        
        var playerHtml = createPlayerHtml(filePath, '', true);
        playerWrapper.innerHTML = playerHtml;
        
        attachVideoListeners(playerWrapper);
        
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    
    var lastProgressUpdate = 0;
    function updateProgress(chapterId, progress, lastPosition) {
        var now = Date.now();
        if (now - lastProgressUpdate < 5000) return;
        lastProgressUpdate = now;
        
        if (chapterId <= 0) {
            console.log('Invalid chapter ID, skipping progress update');
            return;
        }
        
        console.log('Updating progress - Chapter:', chapterId, 'Progress:', progress.toFixed(2) + '%', 'Position:', lastPosition);
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'UpdateLearningProgress.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log('Progress update response:', xhr.responseText);
            }
        };
        xhr.onerror = function() {
            console.error('Progress update failed');
        };
        xhr.send('action=updateProgress&resourceId=' + currentResourceId + 
                 '&chapterId=' + chapterId + '&progress=' + progress + 
                 '&lastPosition=' + lastPosition);
    }
    
    function completeChapter(chapterId) {
        if (chapterId <= 0) {
            console.log('Invalid chapter ID, skipping completion');
            return;
        }
        
        console.log('Completing chapter:', chapterId);
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'UpdateLearningProgress.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log('Complete chapter response:', xhr.responseText);
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        console.log('Chapter completed successfully, updating display');
                        // 延迟更新进度显示，确保数据库已更新
                        setTimeout(function() {
                            updateProgressDisplay();
                            checkResourceCompletion();
                        }, 500);
                    }
                } catch(e) {
                    console.error('Error parsing response:', e);
                }
            }
        };
        xhr.onerror = function() {
            console.error('Complete chapter request failed');
        };
        xhr.send('action=completeChapter&resourceId=' + currentResourceId + '&chapterId=' + chapterId);
    }
    
    function updateProgressDisplay() {
        console.log('Updating progress display for resource:', currentResourceId);
        
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'GetLearningProgress.ashx?resourceId=' + currentResourceId, true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log('Progress display response:', xhr.responseText);
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        var progressPercentage = document.getElementById('progressPercentage');
                        var progressBarFill = document.getElementById('progressBarFill');
                        var completedCount = document.getElementById('completedCount');
                        var totalCount = document.getElementById('totalCount');
                        var progressStatus = document.getElementById('progressStatus');
                        
                        var progressValue = Math.round(data.progress);
                        
                        console.log('Updating UI - Progress:', progressValue + '%', 'Completed:', data.completedChapters, '/', data.totalChapters);
                        
                        if (progressPercentage) progressPercentage.textContent = progressValue + '%';
                        if (progressBarFill) {
                            progressBarFill.style.width = progressValue + '%';
                            progressBarFill.style.transition = 'width 0.5s ease';
                        }
                        if (completedCount) completedCount.textContent = data.completedChapters;
                        if (totalCount) totalCount.textContent = data.totalChapters;
                        if (progressStatus) progressStatus.textContent = data.progress >= 100 ? '✓ 已完成' : '学习中...';
                    } else {
                        console.error('Progress display error:', data.message);
                    }
                } catch(e) {
                    console.error('Error parsing progress response:', e);
                }
            }
        };
        xhr.onerror = function() {
            console.error('Progress display request failed');
        };
        xhr.send();
    }
    
    function checkResourceCompletion() {
        console.log('Checking resource completion for resource:', currentResourceId);
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'UpdateLearningProgress.ashx', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log('Completion check response:', xhr.responseText);
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success && response.completed) {
                        console.log('Resource completed! Credits:', response.credits);
                        // 只有当有积分奖励时才显示弹窗（第一次完成）
                        if (response.credits > 0) {
                            showCompletionModal(response.credits);
                        } else {
                            console.log('Already completed before, no modal shown');
                        }
                    } else {
                        console.log('Resource not yet completed');
                    }
                } catch(e) {
                    console.error('Error parsing completion response:', e);
                }
            }
        };
        xhr.onerror = function() {
            console.error('Completion check request failed');
        };
        xhr.send('action=checkCompletion&resourceId=' + currentResourceId);
    }
    
    function showCompletionModal(credits) {
        var modal = document.createElement('div');
        modal.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.75);backdrop-filter:blur(8px);z-index:99999;display:flex;align-items:center;justify-content:center;animation:fadeIn 0.4s ease-out;';
        
        var content = document.createElement('div');
        content.style.cssText = 'background:white;border-radius:28px;padding:48px 40px;text-align:center;max-width:480px;width:90%;animation:scaleIn 0.5s cubic-bezier(0.34,1.56,0.64,1);box-shadow:0 24px 80px rgba(0,0,0,0.25);position:relative;overflow:hidden;';
        
        // 添加装饰性背景
        var bgDecor = '<div style="position:absolute;top:-50px;right:-50px;width:200px;height:200px;background:linear-gradient(135deg,rgba(102,126,234,0.1),rgba(118,75,162,0.1));border-radius:50%;"></div>' +
                     '<div style="position:absolute;bottom:-30px;left:-30px;width:150px;height:150px;background:linear-gradient(135deg,rgba(251,191,36,0.1),rgba(245,158,11,0.1));border-radius:50%;"></div>';
        
        content.innerHTML = bgDecor +
                           '<div style="position:relative;z-index:1;">' +
                           '<div style="width:120px;height:120px;margin:0 auto 24px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:50%;display:flex;align-items:center;justify-content:center;box-shadow:0 12px 32px rgba(102,126,234,0.3);animation:bounce 0.6s ease-out 0.3s;">' +
                           '<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" style="width:64px;height:64px;">' +
                           '<path d="M5 3l14 9-14 9V3z" fill="white"/>' +
                           '</svg>' +
                           '</div>' +
                           '<h2 style="font-size:32px;font-weight:900;background:linear-gradient(135deg,#667eea,#764ba2);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;margin:0 0 12px 0;letter-spacing:-0.5px;">恭喜完成学习！</h2>' +
                           '<p style="font-size:16px;color:#64748b;margin:0 0 32px 0;line-height:1.6;">您已完成本资源的全部学习内容</p>' +
                           (credits > 0 ? '<div style="background:linear-gradient(135deg,#fef3c7 0%,#fde68a 100%);border-radius:16px;padding:28px 24px;margin-bottom:32px;box-shadow:0 4px 16px rgba(251,191,36,0.2);border:2px solid #fbbf24;">' +
                           '<div style="font-size:14px;color:#92400e;font-weight:600;margin-bottom:12px;letter-spacing:0.5px;">🎁 获得学分奖励</div>' +
                           '<div style="font-size:48px;font-weight:900;background:linear-gradient(135deg,#f59e0b,#d97706);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;line-height:1;margin-bottom:8px;">+' + credits + '</div>' +
                           '<div style="font-size:14px;color:#92400e;font-weight:600;">积分</div></div>' : '') +
                           '<button onclick="closeCompletionModal()" style="background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;border:none;padding:16px 40px;border-radius:14px;font-size:16px;font-weight:700;cursor:pointer;width:100%;transition:all 0.3s ease;box-shadow:0 6px 20px rgba(102,126,234,0.4);letter-spacing:1px;">太棒了！</button>' +
                           '</div>';
        
        modal.appendChild(content);
        document.body.appendChild(modal);
        
        var style = document.createElement('style');
        style.textContent = '@keyframes fadeIn{from{opacity:0}to{opacity:1}}' +
                           '@keyframes scaleIn{from{transform:scale(0.8);opacity:0}to{transform:scale(1);opacity:1}}' +
                           '@keyframes bounce{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}' +
                           'button:hover{transform:translateY(-2px);box-shadow:0 8px 28px rgba(102,126,234,0.5)!important}' +
                           'button:active{transform:translateY(0)}';
        document.head.appendChild(style);
        
        window.currentCompletionModal = modal;
    }
    
    function closeCompletionModal() {
        if (window.currentCompletionModal) {
            window.currentCompletionModal.style.animation = 'fadeOut 0.3s';
            setTimeout(function() {
                if (window.currentCompletionModal && window.currentCompletionModal.parentNode) {
                    window.currentCompletionModal.parentNode.removeChild(window.currentCompletionModal);
                }
                window.currentCompletionModal = null;
            }, 300);
        }
    }
</script>
<style>
@keyframes fadeOut { from { opacity: 1; } to { opacity: 0; } }
</style>
</asp:Content>
