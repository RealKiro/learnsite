<%@ Page Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

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
            LoadStatistics();
            BindResourceList();
        }
    }

    protected void LoadStatistics()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 总文件数
                SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Files", conn);
                lblTotalResources.Text = cmd.ExecuteScalar().ToString();
                
                // 总文件大小（字节转 MB）
                cmd.CommandText = "SELECT ISNULL(SUM(FileSize), 0) FROM Files";
                long totalBytes = Convert.ToInt64(cmd.ExecuteScalar());
                lblTotalViews.Text = (totalBytes / 1048576.0).ToString("F1");
                
                // 上传用户数
                cmd.CommandText = "SELECT COUNT(DISTINCT UserSnum) FROM Files";
                lblTotalDownloads.Text = cmd.ExecuteScalar().ToString();
                
                // 文件夹数
                cmd.CommandText = "SELECT COUNT(DISTINCT FolderId) FROM Files";
                lblTotalCategories.Text = cmd.ExecuteScalar().ToString();
            }
        }
        catch { }
    }

    protected void BindResourceList()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT TOP 100 
                              FileId, FileName, FileSize, CreateTime, UserSnum, RelativePath,
                              FileName as DisplayName
                              FROM Files
                              ORDER BY CreateTime DESC";
                
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                rptResources.DataSource = dt;
                rptResources.DataBind();
            }
        }
        catch { }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        System.Web.UI.WebControls.Button btn = (System.Web.UI.WebControls.Button)sender;
        string fileId = btn.CommandArgument;
        
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("DELETE FROM Files WHERE FileId = @FileId", conn);
                cmd.Parameters.AddWithValue("@FileId", fileId);
                cmd.ExecuteNonQuery();
            }
            
            ShowMessage("删除成功！", "success");
        }
        catch (Exception ex)
        {
            ShowMessage("删除失败：" + ex.Message, "error");
        }
        
        LoadStatistics();
        BindResourceList();
    }

    private void ShowMessage(string message, string type)
    {
        string script = string.Format("showToast('{0}', '{1}');", message.Replace("'", "\\'"), type);
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
    }

    protected string FormatFileSize(object size)
    {
        if (size == null || size == DBNull.Value) return "0 B";
        long bytes = Convert.ToInt64(size);
        if (bytes >= 1073741824L) return (bytes / 1073741824.0).ToString("F1") + " GB";
        if (bytes >= 1048576L) return (bytes / 1048576.0).ToString("F1") + " MB";
        if (bytes >= 1024L) return (bytes / 1024.0).ToString("F1") + " KB";
        return bytes.ToString() + " B";
    }
    
    protected string GetFileExtension(object fileName)
    {
        if (fileName == null || fileName == DBNull.Value) return "";
        string name = fileName.ToString();
        int dotIndex = name.LastIndexOf('.');
        if (dotIndex >= 0 && dotIndex < name.Length - 1)
            return name.Substring(dotIndex + 1).ToUpper();
        return "FILE";
    }
    
    protected string GetFileTypeColor(object fileName)
    {
        string ext = GetFileExtension(fileName).ToLower();
        if (ext == "pdf") return "#ef4444";
        if (ext == "doc" || ext == "docx") return "#2563eb";
        if (ext == "xls" || ext == "xlsx") return "#16a34a";
        if (ext == "ppt" || ext == "pptx") return "#ea580c";
        if (ext == "jpg" || ext == "jpeg" || ext == "png" || ext == "gif" || ext == "bmp" || ext == "webp") return "#8b5cf6";
        if (ext == "mp4" || ext == "avi" || ext == "mov" || ext == "wmv" || ext == "flv") return "#ec4899";
        if (ext == "mp3" || ext == "wav" || ext == "ogg") return "#14b8a6";
        if (ext == "zip" || ext == "rar" || ext == "7z") return "#f59e0b";
        if (ext == "txt" || ext == "md") return "#64748b";
        if (ext == "html" || ext == "htm" || ext == "css" || ext == "js") return "#06b6d4";
        if (ext == "py" || ext == "cs" || ext == "java" || ext == "cpp" || ext == "c") return "#059669";
        if (ext == "sb3" || ext == "sb2") return "#f97316";
        return "#6366f1";
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

    protected string GetFileTypeCat(object fileName)
    {
        string ext = GetFileExtension(fileName).ToLower();
        if (ext == "pdf" || ext == "doc" || ext == "docx" || ext == "xls" || ext == "xlsx" ||
            ext == "ppt" || ext == "pptx" || ext == "txt" || ext == "md") return "doc";
        if (ext == "jpg" || ext == "jpeg" || ext == "png" || ext == "gif" ||
            ext == "bmp" || ext == "webp" || ext == "svg") return "img";
        if (ext == "mp4" || ext == "avi" || ext == "mov" || ext == "wmv" ||
            ext == "flv" || ext == "mkv") return "video";
        if (ext == "mp3" || ext == "wav" || ext == "ogg" || ext == "flac" || ext == "aac") return "audio";
        if (ext == "py" || ext == "cs" || ext == "java" || ext == "cpp" || ext == "c" ||
            ext == "js" || ext == "html" || ext == "htm" || ext == "css" ||
            ext == "sb3" || ext == "sb2") return "code";
        if (ext == "zip" || ext == "rar" || ext == "7z" || ext == "tar" || ext == "gz") return "archive";
        return "other";
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<style>
* { box-sizing: border-box; }

/* ── 容器 ── */
.rm-container { max-width: 1400px; margin: 0 auto; }

/* ── 页头 ── */
.rm-page-header {
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
    border-radius: 20px; padding: 30px 36px; margin-bottom: 24px;
    color: white; box-shadow: 0 8px 32px rgba(99,102,241,0.35);
    position: relative; overflow: hidden;
    display: flex; align-items: center; justify-content: space-between; gap: 16px;
}
.rm-page-header::before {
    content: ''; position: absolute; top: -50%; right: -5%;
    width: 320px; height: 320px; border-radius: 50%;
    background: rgba(255,255,255,0.08); pointer-events: none;
}
.rm-page-header::after {
    content: ''; position: absolute; bottom: -60%; left: 35%;
    width: 200px; height: 200px; border-radius: 50%;
    background: rgba(255,255,255,0.05); pointer-events: none;
}
.rm-header-info { position: relative; z-index: 1; }
.rm-header-title {
    margin: 0 0 8px; font-size: 26px; font-weight: 800;
    letter-spacing: -0.5px; display: flex; align-items: center; gap: 12px;
}
.rm-header-icon {
    width: 44px; height: 44px; background: rgba(255,255,255,0.2);
    border-radius: 12px; display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.rm-header-subtitle { margin: 0; opacity: 0.88; font-size: 14px; }
.rm-header-action { position: relative; z-index: 1; flex-shrink: 0; }
.rm-btn-create {
    display: inline-flex; align-items: center; gap: 7px;
    background: rgba(255,255,255,0.18); color: white;
    border: 1.5px solid rgba(255,255,255,0.45); padding: 11px 22px;
    border-radius: 12px; font-size: 14px; font-weight: 600;
    text-decoration: none; cursor: pointer;
    transition: all 0.25s; backdrop-filter: blur(8px);
}
.rm-btn-create:hover {
    background: rgba(255,255,255,0.28); border-color: rgba(255,255,255,0.7);
    transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.15);
    color: white; text-decoration: none;
}

/* ── 统计卡片 ── */
.rm-stats-row {
    display: grid; grid-template-columns: repeat(4, 1fr);
    gap: 18px; margin-bottom: 24px;
}
@media (max-width: 1100px) { .rm-stats-row { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px)  { .rm-stats-row { grid-template-columns: 1fr; } }

.rm-stat {
    background: white; border-radius: 16px; padding: 20px 22px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.06); border: 1px solid #f1f5f9;
    display: flex; align-items: center; gap: 15px;
    transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
    position: relative; overflow: hidden;
}
.rm-stat::after {
    content: ''; position: absolute; bottom: -30px; right: -20px;
    width: 90px; height: 90px; border-radius: 50%; opacity: 0.06;
    transition: all 0.4s;
}
.rm-stat:hover { transform: translateY(-5px); box-shadow: 0 10px 32px rgba(0,0,0,0.10); }
.rm-stat:hover::after { transform: scale(1.3); }
.rm-stat-blue::after  { background: #3b82f6; }
.rm-stat-green::after { background: #10b981; }
.rm-stat-amber::after { background: #f59e0b; }
.rm-stat-purple::after { background: #8b5cf6; }

.rm-stat-icon {
    width: 50px; height: 50px; border-radius: 14px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    transition: transform 0.3s;
}
.rm-stat:hover .rm-stat-icon { transform: scale(1.08) rotate(4deg); }
.rm-stat-icon svg { width: 24px; height: 24px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rm-stat-blue  .rm-stat-icon { background: #dbeafe; }
.rm-stat-blue  .rm-stat-icon svg { stroke: #2563eb; }
.rm-stat-green .rm-stat-icon { background: #dcfce7; }
.rm-stat-green .rm-stat-icon svg { stroke: #16a34a; }
.rm-stat-amber .rm-stat-icon { background: #fef3c7; }
.rm-stat-amber .rm-stat-icon svg { stroke: #d97706; }
.rm-stat-purple .rm-stat-icon { background: #f3e8ff; }
.rm-stat-purple .rm-stat-icon svg { stroke: #9333ea; }

.rm-stat-body { position: relative; z-index: 1; }
.rm-stat-value {
    font-size: 28px; font-weight: 800; color: #0f172a;
    line-height: 1; letter-spacing: -1px;
}
.rm-stat-unit { font-size: 14px; font-weight: 500; color: #94a3b8; margin-left: 2px; }
.rm-stat-label { font-size: 13px; color: #64748b; font-weight: 500; margin-top: 5px; }

/* ── 资源卡片 ── */
.rm-card {
    background: white; border-radius: 20px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.06); border: 1px solid #f1f5f9;
    overflow: hidden;
}
.rm-card-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 22px 28px 18px; border-bottom: 1px solid #f1f5f9;
    flex-wrap: wrap; gap: 12px;
}
.rm-card-title-wrap { display: flex; align-items: center; gap: 10px; }
.rm-card-icon {
    width: 34px; height: 34px;
    background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    border-radius: 10px; display: flex; align-items: center; justify-content: center;
}
.rm-card-icon svg { width: 17px; height: 17px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rm-card-title { font-size: 17px; font-weight: 700; color: #0f172a; margin: 0; }
.rm-count-badge {
    background: #f1f5f9; color: #64748b;
    font-size: 12px; font-weight: 600;
    padding: 3px 10px; border-radius: 20px;
}

/* ── 工具栏 ── */
.rm-toolbar {
    display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
    padding: 14px 28px; background: #fafbfc; border-bottom: 1px solid #f1f5f9;
}
.rm-search-wrap { position: relative; flex: 1; min-width: 180px; max-width: 340px; }
.rm-search-wrap .rm-search-ico {
    position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
    width: 15px; height: 15px; stroke: #94a3b8; fill: none;
    stroke-width: 2; stroke-linecap: round; pointer-events: none;
}
.rm-search {
    width: 100%; padding: 8px 12px 8px 34px;
    border: 1.5px solid #e2e8f0; border-radius: 10px;
    font-size: 13.5px; color: #334155; background: white;
    outline: none; transition: border-color 0.2s, box-shadow 0.2s;
    font-family: inherit;
}
.rm-search:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
.rm-search::placeholder { color: #94a3b8; }

/* 过滤胶囊 */
.rm-filters { display: flex; align-items: center; gap: 7px; flex-wrap: wrap; }
.rm-pill {
    padding: 5px 13px; border-radius: 20px; border: 1.5px solid #e2e8f0;
    font-size: 12px; font-weight: 600; color: #64748b; background: white;
    cursor: pointer; transition: all 0.2s; white-space: nowrap; user-select: none;
    line-height: 1.4;
}
.rm-pill:hover { border-color: #6366f1; color: #6366f1; background: #eef2ff; }
.rm-pill.active { border-color: #6366f1; color: white; background: #6366f1; }

/* ── 表格 ── */
.rm-table-wrap { overflow-x: auto; }
.rm-table { width: 100%; border-collapse: collapse; font-size: 14px; min-width: 640px; }
.rm-table thead tr { border-bottom: 1.5px solid #f1f5f9; }
.rm-table thead th {
    padding: 11px 14px; text-align: left; background: #fafbfc;
    font-size: 11px; font-weight: 700; color: #94a3b8;
    text-transform: uppercase; letter-spacing: 0.5px; white-space: nowrap;
}
.rm-table thead th:first-child { padding-left: 28px; }
.rm-table thead th:last-child  { padding-right: 28px; text-align: right; }
.rm-table tbody tr { border-bottom: 1px solid #f8fafc; transition: background 0.15s; }
.rm-table tbody tr:hover { background: #fafbfd; }
.rm-table tbody tr:last-child { border-bottom: none; }
.rm-table tbody td { padding: 13px 14px; vertical-align: middle; color: #334155; }
.rm-table tbody td:first-child { padding-left: 28px; }
.rm-table tbody td:last-child  { padding-right: 28px; }

/* 文件单元格 */
.rm-file-cell { display: flex; align-items: center; gap: 12px; }
.rm-file-ext {
    width: 40px; height: 40px; border-radius: 10px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: 9px; font-weight: 800; color: white; letter-spacing: 0.3px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.12);
}
.rm-file-info {}
.rm-file-name {
    font-size: 13.5px; font-weight: 600; color: #1e293b;
    max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.rm-file-path {
    font-size: 11.5px; color: #94a3b8; margin-top: 2px;
    max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}

/* 标签样式 */
.rm-tag {
    display: inline-flex; align-items: center; gap: 4px;
    background: #f1f5f9; color: #64748b;
    padding: 4px 10px; border-radius: 6px;
    font-size: 12px; font-weight: 600; white-space: nowrap;
}
.rm-tag svg { width: 12px; height: 12px; flex-shrink: 0; fill: none; stroke: currentColor; stroke-width: 2; }
.rm-tag-user { background: #f0fdf4; color: #16a34a; }
.rm-date { font-size: 12.5px; color: #94a3b8; white-space: nowrap; }

/* 操作列 */
.rm-actions { display: flex; justify-content: flex-end; }
.rm-btn-del {
    display: inline-flex; align-items: center;
    background: white; color: #ef4444;
    border: 1.5px solid #fecaca; padding: 7px 16px;
    border-radius: 8px; font-size: 12.5px; font-weight: 600;
    cursor: pointer; transition: all 0.2s; white-space: nowrap;
    font-family: inherit; line-height: 1.2;
}
.rm-btn-del:hover {
    background: #fef2f2; border-color: #ef4444; color: #dc2626;
    transform: translateY(-1px); box-shadow: 0 3px 10px rgba(239,68,68,0.18);
}
.rm-btn-del:active { transform: translateY(0); }

/* 空状态 */
.rm-empty {
    display: none; text-align: center; padding: 64px 20px;
}
.rm-empty.visible { display: block; }
.rm-empty-icon {
    width: 72px; height: 72px; background: #f8fafc; border-radius: 50%;
    display: flex; align-items: center; justify-content: center; margin: 0 auto 18px;
}
.rm-empty-icon svg { width: 32px; height: 32px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; }
.rm-empty-title { font-size: 15px; font-weight: 600; color: #475569; margin: 0 0 6px; }
.rm-empty-desc  { font-size: 13px; color: #94a3b8; margin: 0; }

/* ── Toast ── */
.toast {
    position: fixed; top: 22px; right: 22px; background: white;
    padding: 14px 20px; border-radius: 14px; min-width: 240px;
    box-shadow: 0 12px 48px rgba(0,0,0,0.14); z-index: 10000;
    display: none; align-items: center; gap: 10px;
    animation: rmSlideIn 0.32s cubic-bezier(0.4, 0, 0.2, 1);
    border-left: 4px solid;
}
@keyframes rmSlideIn {
    from { transform: translateX(110%); opacity: 0; }
    to   { transform: translateX(0);    opacity: 1; }
}
.toast.success { border-left-color: #10b981; }
.toast.error   { border-left-color: #ef4444; }
.toast-icon    { font-size: 18px; flex-shrink: 0; }
.toast-message { font-size: 14px; font-weight: 500; color: #1e293b; line-height: 1.4; }
</style>

<div class="rm-container">

    <%-- ===== 页头 ===== --%>
    <div class="rm-page-header">
        <div class="rm-header-info">
            <h1 class="rm-header-title">
                <div class="rm-header-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:22px;height:22px">
                        <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>
                    </svg>
                </div>
                资源管理中心
            </h1>
            <p class="rm-header-subtitle">管理所有教学资源文件，查看统计数据和资源详情</p>
        </div>
        <div class="rm-header-action">
            <a href="resourcecreate.aspx" class="rm-btn-create">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" style="width:15px;height:15px">
                    <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
                创建资源
            </a>
        </div>
    </div>

    <%-- ===== 统计行 ===== --%>
    <div class="rm-stats-row">
        <div class="rm-stat rm-stat-blue">
            <div class="rm-stat-icon">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
            </div>
            <div class="rm-stat-body">
                <div class="rm-stat-value"><asp:Label ID="lblTotalResources" runat="server" Text="0"></asp:Label></div>
                <div class="rm-stat-label">总文件数</div>
            </div>
        </div>

        <div class="rm-stat rm-stat-green">
            <div class="rm-stat-icon">
                <svg viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
            </div>
            <div class="rm-stat-body">
                <div class="rm-stat-value"><asp:Label ID="lblTotalViews" runat="server" Text="0"></asp:Label><span class="rm-stat-unit">MB</span></div>
                <div class="rm-stat-label">总文件大小</div>
            </div>
        </div>

        <div class="rm-stat rm-stat-amber">
            <div class="rm-stat-icon">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div class="rm-stat-body">
                <div class="rm-stat-value"><asp:Label ID="lblTotalDownloads" runat="server" Text="0"></asp:Label></div>
                <div class="rm-stat-label">上传用户数</div>
            </div>
        </div>

        <div class="rm-stat rm-stat-purple">
            <div class="rm-stat-icon">
                <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
            </div>
            <div class="rm-stat-body">
                <div class="rm-stat-value"><asp:Label ID="lblTotalCategories" runat="server" Text="0"></asp:Label></div>
                <div class="rm-stat-label">文件夹数</div>
            </div>
        </div>
    </div>

    <%-- ===== 资源卡片 ===== --%>
    <div class="rm-card">
        <%-- 卡片头部 --%>
        <div class="rm-card-header">
            <div class="rm-card-title-wrap">
                <div class="rm-card-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                </div>
                <h2 class="rm-card-title">资源列表</h2>
                <span class="rm-count-badge" id="rmCountBadge">加载中&hellip;</span>
            </div>
        </div>

        <%-- 工具栏 --%>
        <div class="rm-toolbar">
            <div class="rm-search-wrap">
                <svg class="rm-search-ico" viewBox="0 0 24 24">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                <input type="text" id="rmSearch" class="rm-search" placeholder="搜索文件名…" oninput="rmFilter()" />
            </div>
            <div class="rm-filters">
                <span class="rm-pill active" onclick="rmSetType(this,'all')">全部</span>
                <span class="rm-pill" onclick="rmSetType(this,'doc')">文档</span>
                <span class="rm-pill" onclick="rmSetType(this,'img')">图片</span>
                <span class="rm-pill" onclick="rmSetType(this,'video')">视频</span>
                <span class="rm-pill" onclick="rmSetType(this,'audio')">音频</span>
                <span class="rm-pill" onclick="rmSetType(this,'code')">代码</span>
                <span class="rm-pill" onclick="rmSetType(this,'archive')">压缩包</span>
                <span class="rm-pill" onclick="rmSetType(this,'other')">其他</span>
            </div>
        </div>

        <%-- 表格 --%>
        <div class="rm-table-wrap">
            <table class="rm-table">
                <thead>
                    <tr>
                        <th>文件</th>
                        <th>大小</th>
                        <th>上传用户</th>
                        <th>创建时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="rmTbody">
                    <asp:Repeater ID="rptResources" runat="server">
                        <ItemTemplate>
                            <tr class="rm-row"
                                data-name="<%# Eval("FileName") %>"
                                data-type="<%# GetFileTypeCat(Eval("FileName")) %>">
                                <td>
                                    <div class="rm-file-cell">
                                        <div class="rm-file-ext"
                                            style="background:<%# GetFileTypeColor(Eval("FileName")) %>">
                                            <%# GetFileExtension(Eval("FileName")) %>
                                        </div>
                                        <div class="rm-file-info">
                                            <div class="rm-file-name" title="<%# Eval("FileName") %>"><%# Eval("DisplayName") %></div>
                                            <div class="rm-file-path"><%# Eval("RelativePath") %></div>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="rm-tag"><%# FormatFileSize(Eval("FileSize")) %></span></td>
                                <td>
                                    <span class="rm-tag rm-tag-user">
                                        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                        <%# Eval("UserSnum") %>
                                    </span>
                                </td>
                                <td><span class="rm-date"><%# Eval("CreateTime", "{0:yyyy-MM-dd HH:mm}") %></span></td>
                                <td>
                                    <div class="rm-actions">
                                        <asp:Button ID="btnDelete" runat="server"
                                            Text="删除" CssClass="rm-btn-del"
                                            CommandArgument='<%# Eval("FileId") %>'
                                            OnClick="btnDelete_Click"
                                            OnClientClick="return confirm('确定要删除此文件吗？此操作不可撤销。');" />
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>

            <%-- 空状态 --%>
            <div class="rm-empty" id="rmEmpty">
                <div class="rm-empty-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                </div>
                <p class="rm-empty-title">暂无匹配的资源</p>
                <p class="rm-empty-desc">尝试修改搜索词或过滤条件，或点击右上角创建新资源</p>
            </div>
        </div>
    </div>

</div>

<%-- Toast --%>
<div id="toast" class="toast">
    <span class="toast-icon" id="toastIcon"></span>
    <span class="toast-message" id="toastMessage"></span>
</div>

<script type="text/javascript">
    /* Toast */
    function showToast(message, type) {
        var t = document.getElementById('toast');
        t.className = 'toast ' + type;
        document.getElementById('toastIcon').textContent    = type === 'success' ? '\u2705' : '\u274C';
        document.getElementById('toastMessage').textContent = message;
        t.style.display = 'flex';
        setTimeout(function () { t.style.display = 'none'; }, 3200);
    }

    /* 搜索 & 类型过滤 */
    var _rmType = 'all';

    function rmSetType(el, type) {
        _rmType = type;
        document.querySelectorAll('.rm-pill').forEach(function (p) { p.classList.remove('active'); });
        el.classList.add('active');
        rmFilter();
    }

    function rmFilter() {
        var q    = (document.getElementById('rmSearch').value || '').toLowerCase().trim();
        var rows = document.querySelectorAll('.rm-row');
        var vis  = 0;
        rows.forEach(function (row) {
            var name = (row.getAttribute('data-name') || '').toLowerCase();
            var cat  = (row.getAttribute('data-type') || '');
            var ok   = (!q || name.indexOf(q) >= 0) && (_rmType === 'all' || cat === _rmType);
            row.style.display = ok ? '' : 'none';
            if (ok) vis++;
        });
        var empty = document.getElementById('rmEmpty');
        if (empty) empty.className = vis === 0 ? 'rm-empty visible' : 'rm-empty';
        var badge = document.getElementById('rmCountBadge');
        if (badge) badge.textContent = '\u5171 ' + vis + ' \u4e2a\u6587\u4ef6';
    }

    /* 初始化计数 */
    (function () {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', rmFilter);
        } else {
            rmFilter();
        }
    })();
</script>
</asp:Content>
