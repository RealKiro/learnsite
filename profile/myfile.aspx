<%@ Page Language="C#" MasterPageFile="~/student/Stud.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int currentStudentId = 0;
    
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
        
        if (!IsPostBack)
        {
            LoadStatistics();
            BindResourceList();
        }
    }

    protected void LoadStatistics()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Files WHERE ResourceName IS NOT NULL AND IsPublished = 1", conn);
            lblTotalResources.Text = cmd.ExecuteScalar().ToString();
            
            cmd.CommandText = "SELECT COUNT(DISTINCT CategoryId) FROM Files WHERE CategoryId IS NOT NULL AND IsPublished = 1";
            lblTotalCategories.Text = cmd.ExecuteScalar().ToString();
            
            cmd.CommandText = "SELECT ISNULL(SUM(ViewCount), 0) FROM Files WHERE IsPublished = 1";
            lblTotalViews.Text = cmd.ExecuteScalar().ToString();
        }
    }

    protected void BindResourceList()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        string categoryFilter = Request.QueryString["cid"];
        string searchKeyword = Request.QueryString["q"];
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string sql = @"SELECT TOP 100 
                          f.FileId, f.FileName, f.FileSize, f.CreateTime,
                          ISNULL(f.ResourceName, f.FileName) as DisplayName,
                          ISNULL(f.CoverImage, '') as CoverImage,
                          ISNULL(f.ViewCredits, 0) as ViewCredits,
                          ISNULL(f.DownloadCredits, 0) as DownloadCredits,
                          ISNULL(f.ViewCount, 0) as ViewCount,
                          ISNULL(f.DownloadCount, 0) as DownloadCount,
                          ISNULL(f.HasChapters, 0) as HasChapters,
                          ISNULL(f.Description, '') as Description,
                          ISNULL(c.CategoryName, '未分类') as CategoryName,
                          ISNULL(c.CategoryIcon, '📄') as CategoryIcon,
                          ISNULL(c.CategoryColor, '#64748b') as CategoryColor,
                          CASE 
                            WHEN f.HasChapters = 1 THEN
                              CASE 
                                WHEN (SELECT COUNT(DISTINCT ChapterId) FROM ResourceLearningProgress 
                                      WHERE StudentId = @StudentId 
                                      AND ChapterId IN (SELECT ChapterId FROM ResourceChapters WHERE ResourceId = f.FileId)
                                      AND IsCompleted = 1) >= 
                                     (SELECT COUNT(*) FROM ResourceChapters WHERE ResourceId = f.FileId)
                                THEN 1 ELSE 0 END
                            ELSE
                              CASE 
                                WHEN EXISTS(SELECT 1 FROM ResourceLearningProgress 
                                           WHERE StudentId = @StudentId AND ResourceId = f.FileId 
                                           AND ChapterId IS NULL AND IsCompleted = 1)
                                THEN 1 ELSE 0 END
                          END as IsLearned
                          FROM Files f
                          LEFT JOIN ResourceCategories c ON f.CategoryId = c.CategoryId
                          WHERE f.ResourceName IS NOT NULL AND f.IsPublished = 1";
            
            if (!string.IsNullOrEmpty(categoryFilter))
            {
                sql += " AND f.CategoryId = @CategoryId";
            }
            
            if (!string.IsNullOrEmpty(searchKeyword))
            {
                sql += " AND (f.ResourceName LIKE @Keyword OR f.Description LIKE @Keyword)";
            }
            
            sql += " ORDER BY f.CreateTime DESC";
            
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@StudentId", currentStudentId);
            
            if (!string.IsNullOrEmpty(categoryFilter))
            {
                cmd.Parameters.AddWithValue("@CategoryId", categoryFilter);
            }
            
            if (!string.IsNullOrEmpty(searchKeyword))
            {
                cmd.Parameters.AddWithValue("@Keyword", "%" + searchKeyword + "%");
            }
            
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            rptResources.DataSource = dt;
            rptResources.DataBind();
        }
    }

    protected string FormatNumber(object num)
    {
        if (num == null || num == DBNull.Value) return "0";
        int n = Convert.ToInt32(num);
        if (n >= 1000000) return (n / 1000000.0).ToString("F1") + "M";
        if (n >= 1000) return (n / 1000.0).ToString("F1") + "K";
        return n.ToString();
    }

    protected string GetCategoryIconSvg(object categoryName)
    {
        if (categoryName == null || categoryName == DBNull.Value) 
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
            
        string name = categoryName.ToString().ToLower();
        
        if (name.Contains("视频") || name.Contains("教程"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z'/></svg>";
        
        if (name.Contains("音频") || name.Contains("音乐"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M9 18V5l12-2v13M9 18c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3zm12-2c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3z'/></svg>";
        
        if (name.Contains("图片") || name.Contains("素材") || name.Contains("图像"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
        
        if (name.Contains("文档") || name.Contains("文件") || name.Contains("资料"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'/></svg>";
        
        if (name.Contains("代码") || name.Contains("编程") || name.Contains("源码"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><polyline points='16 18 22 12 16 6'/><polyline points='8 6 2 12 8 18'/></svg>";
        
        if (name.Contains("压缩") || name.Contains("打包"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
        
        if (name.Contains("课件") || name.Contains("ppt") || name.Contains("演示"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 012 2v14a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z'/><path d='M11 14l2 2 4-4'/></svg>";
        
        if (name.Contains("工具") || name.Contains("软件"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z'/></svg>";
        
        return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:24px;height:24px'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
    }

    protected string GetCategoryIconLarge(object categoryName)
    {
        if (categoryName == null || categoryName == DBNull.Value) 
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
            
        string name = categoryName.ToString().ToLower();
        
        if (name.Contains("视频") || name.Contains("教程"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z'/></svg>";
        
        if (name.Contains("音频") || name.Contains("音乐"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M9 18V5l12-2v13M9 18c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3zm12-2c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3z'/></svg>";
        
        if (name.Contains("图片") || name.Contains("素材") || name.Contains("图像"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
        
        if (name.Contains("文档") || name.Contains("文件") || name.Contains("资料"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'/></svg>";
        
        if (name.Contains("代码") || name.Contains("编程") || name.Contains("源码"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><polyline points='16 18 22 12 16 6'/><polyline points='8 6 2 12 8 18'/></svg>";
        
        if (name.Contains("压缩") || name.Contains("打包"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
        
        if (name.Contains("课件") || name.Contains("ppt") || name.Contains("演示"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 012 2v14a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z'/><path d='M11 14l2 2 4-4'/></svg>";
        
        if (name.Contains("工具") || name.Contains("软件"))
            return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z'/></svg>";
        
        return "<svg viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' style='width:64px;height:64px'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="server">
<style>
    * { box-sizing: border-box; }
    .resource-browse-container { max-width: 1400px; margin: 0 auto; padding: 20px; }
    
    .page-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 20px; padding: 40px; margin-bottom: 32px;
        color: white; box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
        position: relative; overflow: hidden;
    }
    .page-header::before {
        content: ''; position: absolute; top: -50%; right: -10%;
        width: 400px; height: 400px; border-radius: 50%;
        background: rgba(255,255,255,0.1);
    }
    .page-header h1 { 
        margin: 0 0 12px 0; font-size: 32px; font-weight: 700;
        position: relative; z-index: 1;
    }
    .page-header p { 
        margin: 0; opacity: 0.95; font-size: 15px;
        position: relative; z-index: 1;
    }
    
    .stats-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 24px; margin-bottom: 32px;
    }
    .stat-card {
        background: white; border-radius: 20px; padding: 28px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative; overflow: hidden;
    }
    .stat-card::before {
        content: ''; position: absolute; top: 0; right: 0;
        width: 120px; height: 120px; border-radius: 50%;
        opacity: 0.1; transition: all 0.4s;
    }
    .stat-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 40px rgba(0,0,0,0.15);
    }
    .stat-card:hover::before {
        transform: scale(1.2);
    }
    .stat-card:nth-child(1)::before { background: #3b82f6; }
    .stat-card:nth-child(2)::before { background: #10b981; }
    .stat-card:nth-child(3)::before { background: #f59e0b; }

    .stat-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 20px; position: relative; z-index: 1;
    }
    .stat-icon {
        width: 56px; height: 56px; border-radius: 16px;
        display: flex; align-items: center; justify-content: center;
        font-size: 28px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        transition: all 0.3s;
    }
    .stat-card:hover .stat-icon {
        transform: scale(1.1) rotate(5deg);
    }
    .stat-value {
        font-size: 36px; font-weight: 800; color: #1e293b;
        margin-bottom: 6px; position: relative; z-index: 1;
        letter-spacing: -1px;
    }
    .stat-label {
        font-size: 14px; color: #64748b; font-weight: 500;
        position: relative; z-index: 1;
    }
    
    .resources-card {
        background: white; border-radius: 20px; padding: 32px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    }
    .resources-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 28px; padding-bottom: 20px;
        border-bottom: 2px solid #f1f5f9;
    }
    .resources-header h2 {
        margin: 0; font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    
    .resources-grid {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
        gap: 24px;
    }
    .resource-item {
        background: white; border: 2px solid #f1f5f9;
        border-radius: 16px; overflow: hidden;
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: pointer;
    }
    .resource-item:hover {
        border-color: #667eea;
        box-shadow: 0 8px 32px rgba(102, 126, 234, 0.2);
        transform: translateY(-4px);
    }
    .resource-cover {
        width: 100%; height: 200px; 
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex; align-items: center; justify-content: center;
        font-size: 72px; position: relative; overflow: hidden;
    }
    .resource-cover::before {
        content: ''; position: absolute; inset: 0;
        background: radial-gradient(circle at 30% 50%, rgba(255,255,255,0.2), transparent);
    }
    .resource-cover img {
        width: 100%; height: 100%; object-fit: cover;
    }
    .resource-cover svg {
        position: relative; z-index: 1;
        filter: drop-shadow(0 4px 8px rgba(0,0,0,0.2));
    }
    .resource-category-badge {
        position: absolute; top: 16px; left: 16px;
        padding: 8px 16px; border-radius: 24px;
        font-size: 13px; font-weight: 600;
        background: rgba(255,255,255,0.95);
        display: flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        backdrop-filter: blur(10px);
    }
    .resource-category-badge svg {
        flex-shrink: 0;
    }
    .resource-learned-badge {
        position: absolute; top: 16px; right: 16px;
        padding: 8px 16px; border-radius: 24px;
        font-size: 13px; font-weight: 600;
        display: flex; align-items: center; gap: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        backdrop-filter: blur(10px);
    }
    .resource-learned-badge.learned {
        background: rgba(16, 185, 129, 0.95);
        color: white;
    }
    .resource-learned-badge.not-learned {
        background: rgba(148, 163, 184, 0.95);
        color: white;
    }
    .resource-body {
        padding: 24px;
    }
    .resource-title {
        font-size: 17px; font-weight: 700; color: #1e293b;
        margin-bottom: 16px; line-height: 1.4;
        display: -webkit-box; -webkit-line-clamp: 2;
        -webkit-box-orient: vertical; overflow: hidden;
    }
    .resource-meta {
        display: flex; gap: 20px; margin-bottom: 12px;
        font-size: 14px; color: #64748b;
    }
    .resource-meta-item {
        display: flex; align-items: center; gap: 6px;
        padding: 6px 12px; background: #f8fafc;
        border-radius: 8px; font-weight: 500;
    }
    .resource-meta-item svg {
        width: 16px; height: 16px;
    }
    .resource-info-row {
        display: flex; align-items: center; gap: 16px;
        padding: 12px 0; border-top: 1px solid #f1f5f9;
        font-size: 13px; color: #64748b;
    }
    .resource-info-item {
        display: flex; align-items: center; gap: 6px;
        font-weight: 500;
    }
    .resource-info-item svg {
        width: 16px; height: 16px; stroke: currentColor;
    }
    .resource-info-separator {
        width: 1px; height: 16px; background: #e2e8f0;
    }
    .btn-action {
        padding: 8px 16px; border-radius: 8px;
        font-size: 13px; font-weight: 600; cursor: pointer;
        transition: all 0.3s; border: none;
        display: inline-flex; align-items: center; gap: 6px;
        background: transparent; color: #64748b;
        text-decoration: none;
    }
    .btn-action:hover {
        color: #1e293b;
        transform: translateY(-1px);
    }
    .btn-action svg {
        width: 16px; height: 16px;
    }
    .btn-view {
        color: #4f46e5;
    }
    .btn-view:hover { 
        color: #3730a3;
    }
    .btn-download {
        color: #059669;
    }
    .btn-download:hover { 
        color: #047857;
    }
</style>

<div class="resource-browse-container">
    <div class="page-header">
        <h1>📚 学习资源中心</h1>
        <p>浏览和学习各类教学资源，提升你的技能</p>
    </div>
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon" style="background: linear-gradient(135deg, #dbeafe 0%, #93c5fd 100%); color: #1e40af;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:28px;height:28px">
                        <path d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                    </svg>
                </div>
            </div>
            <div class="stat-value"><asp:Label ID="lblTotalResources" runat="server" Text="0"></asp:Label></div>
            <div class="stat-label">可用资源</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon" style="background: linear-gradient(135deg, #dcfce7 0%, #86efac 100%); color: #15803d;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:28px;height:28px">
                        <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                    </svg>
                </div>
            </div>
            <div class="stat-value"><asp:Label ID="lblTotalViews" runat="server" Text="0"></asp:Label></div>
            <div class="stat-label">总浏览量</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon" style="background: linear-gradient(135deg, #f3e8ff 0%, #d8b4fe 100%); color: #6b21a8;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:28px;height:28px">
                        <path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/>
                    </svg>
                </div>
            </div>
            <div class="stat-value"><asp:Label ID="lblTotalCategories" runat="server" Text="0"></asp:Label></div>
            <div class="stat-label">资源分类</div>
        </div>
    </div>
    
    <div class="resources-card">
        <div class="resources-header">
            <h2>📖 资源列表</h2>
        </div>
        
        <div class="resources-grid">
            <asp:Repeater ID="rptResources" runat="server">
                <ItemTemplate>
                    <div class="resource-item">
                        <div class="resource-cover">
                            <%# string.IsNullOrEmpty(Eval("CoverImage").ToString()) ? 
                                GetCategoryIconLarge(Eval("CategoryName")) : 
                                "<img src='" + ResolveUrl("~" + Eval("CoverImage")) + "' alt='封面' />" %>
                            <div class="resource-category-badge" style='color: <%# Eval("CategoryColor") %>;'>
                                <%# GetCategoryIconSvg(Eval("CategoryName")) %>
                                <span><%# Eval("CategoryName") %></span>
                            </div>
                            <%# Convert.ToBoolean(Eval("IsLearned")) ? 
                                "<div class='resource-learned-badge learned'><svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:16px;height:16px;'><path d='M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'/></svg><span>已学习</span></div>" : 
                                "<div class='resource-learned-badge not-learned'><svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' style='width:16px;height:16px;'><circle cx='12' cy='12' r='10'/><path d='M12 8v4m0 4h.01'/></svg><span>未学习</span></div>" %>
                        </div>
                        <div class="resource-body">
                            <div class="resource-title"><%# Eval("DisplayName") %></div>
                            <div class="resource-meta">
                                <div class="resource-meta-item">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                    <span><%# FormatNumber(Eval("ViewCount")) %></span>
                                </div>
                                <div class="resource-meta-item">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/>
                                    </svg>
                                    <span><%# FormatNumber(Eval("DownloadCount")) %></span>
                                </div>
                                <%# Convert.ToBoolean(Eval("HasChapters")) ? "<div class='resource-meta-item'><svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253'/></svg><span>多章节</span></div>" : "" %>
                            </div>
                            <div class="resource-info-row">
                                <div class="resource-info-item" style="color: #1e40af;">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                    <span>观看 +<%# Eval("ViewCredits") %> 分</span>
                                </div>
                                <div class="resource-info-separator"></div>
                                <div class="resource-info-item" style="color: #92400e;">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/>
                                    </svg>
                                    <span>下载 +<%# Eval("DownloadCredits") %> 分</span>
                                </div>
                                <div class="resource-info-separator"></div>
                                <a href='<%# ResolveUrl("~/student/resourcedetail.aspx?fid=" + Eval("FileId")) %>' class="btn-action btn-view">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                    </svg>
                                    查看
                                </a>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>
</asp:Content>
