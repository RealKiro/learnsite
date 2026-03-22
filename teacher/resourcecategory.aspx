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
            EnsureResourceCategoriesTable();
            BindCategories();
        }
    }

    protected void BindCategories()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT CategoryId, CategoryName, CategoryIcon, CategoryColor, Description, 
                              SortOrder, IsActive, CreateTime,
                              (SELECT COUNT(*) FROM Files WHERE CategoryId = ResourceCategories.CategoryId) as ResourceCount
                              FROM ResourceCategories 
                              ORDER BY SortOrder, CategoryId";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                rptCategories.DataSource = dt;
                rptCategories.DataBind();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("资源分类加载失败：" + ex.Message, "error");
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        string name = txtCategoryName.Text.Trim();
        if (string.IsNullOrEmpty(name))
        {
            ShowMessage("请输入分类名称", "error");
            return;
        }
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = @"INSERT INTO ResourceCategories (CategoryName, CategoryIcon, CategoryColor, Description, SortOrder, IsActive)
                          VALUES (@Name, @Icon, @Color, @Desc, @Sort, 1)";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Name", name);
            cmd.Parameters.AddWithValue("@Icon", txtCategoryIcon.Text.Trim());
            cmd.Parameters.AddWithValue("@Color", txtCategoryColor.Text.Trim());
            cmd.Parameters.AddWithValue("@Desc", txtCategoryDesc.Text.Trim());
            cmd.Parameters.AddWithValue("@Sort", string.IsNullOrEmpty(txtSortOrder.Text) ? 0 : int.Parse(txtSortOrder.Text));
            cmd.ExecuteNonQuery();
        }
        
        txtCategoryName.Text = "";
        txtCategoryIcon.Text = "";
        txtCategoryColor.Text = "#3b82f6";
        txtCategoryDesc.Text = "";
        txtSortOrder.Text = "0";
        
        ShowMessage("分类添加成功！", "success");
        BindCategories();
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        string categoryId = btn.CommandArgument;
        
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            string checkSql = "SELECT COUNT(*) FROM Files WHERE CategoryId = @CategoryId";
            SqlCommand checkCmd = new SqlCommand(checkSql, conn);
            checkCmd.Parameters.AddWithValue("@CategoryId", categoryId);
            int count = (int)checkCmd.ExecuteScalar();
            
            if (count > 0)
            {
                ShowMessage("该分类下还有资源，无法删除", "error");
                return;
            }
            
            string sql = "DELETE FROM ResourceCategories WHERE CategoryId = @CategoryId";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@CategoryId", categoryId);
            cmd.ExecuteNonQuery();
        }
        
        ShowMessage("删除成功！", "success");
        BindCategories();
    }

    protected string GetCategoryIcon(object categoryName)
    {
        string name = categoryName.ToString().ToLower();
        
        if (name.Contains("视频") || name.Contains("教程") || name == "video")
            return "<svg viewBox='0 0 24 24'><path d='M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z'/></svg>";
        
        if (name.Contains("音频") || name.Contains("音乐") || name == "audio")
            return "<svg viewBox='0 0 24 24'><path d='M9 18V5l12-2v13M9 18c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3zm12-2c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3z'/></svg>";
        
        if (name.Contains("图片") || name.Contains("素材") || name.Contains("图像") || name == "image")
            return "<svg viewBox='0 0 24 24'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
        
        if (name.Contains("文档") || name.Contains("文件") || name.Contains("资料") || name == "doc")
            return "<svg viewBox='0 0 24 24'><path d='M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'/></svg>";
        
        if (name.Contains("代码") || name.Contains("编程") || name.Contains("源码") || name == "code")
            return "<svg viewBox='0 0 24 24'><polyline points='16 18 22 12 16 6'/><polyline points='8 6 2 12 8 18'/></svg>";
        
        if (name.Contains("压缩") || name.Contains("打包") || name == "zip")
            return "<svg viewBox='0 0 24 24'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
        
        if (name.Contains("课件") || name.Contains("ppt") || name.Contains("演示"))
            return "<svg viewBox='0 0 24 24'><path d='M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 012 2v14a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z'/><path d='M11 14l2 2 4-4'/></svg>";
        
        if (name.Contains("工具") || name.Contains("软件"))
            return "<svg viewBox='0 0 24 24'><path d='M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z'/></svg>";
        
        return "<svg viewBox='0 0 24 24'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
    }

    protected string GetCardIcon(object iconField, object nameField)
    {
        string icon = (iconField ?? "").ToString().Trim();
        string key = string.IsNullOrEmpty(icon) ? (nameField ?? "").ToString() : icon;
        return "<span class='rc-svg-icon'>" + GetCategoryIcon(key) + "</span>";
    }

    private void ShowMessage(string message, string type)
    {
        string script = string.Format("showToast('{0}', '{1}');", message.Replace("'", "\\'"), type);
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
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
    VALUES (N'视频教程', N'video', N'#ef4444', N'视频类教学资源', 1, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'文档资料', N'doc', N'#3b82f6', N'文档与课件资源', 2, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'图片素材', N'image', N'#10b981', N'图片与素材资源', 3, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'音频资源', N'audio', N'#8b5cf6', N'音频与配乐资源', 4, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'代码示例', N'code', N'#f59e0b', N'代码与程序资源', 5, 1);

    INSERT INTO [dbo].[ResourceCategories] ([CategoryName], [CategoryIcon], [CategoryColor], [Description], [SortOrder], [IsActive])
    VALUES (N'压缩文件', N'zip', N'#64748b', N'压缩包与打包资源', 6, 1);
END";

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { /* 表已存在或初始化失败，忽略 */ }
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<style>
* { box-sizing: border-box; }

/* ── 容器 ── */
.rc-wrap { max-width: 1400px; margin: 0 auto; }
    
/* ── 页头 ── */
.rc-hdr {
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
    border-radius: 20px; padding: 28px 36px; margin-bottom: 22px;
    color: white; box-shadow: 0 8px 32px rgba(99,102,241,0.35);
    position: relative; overflow: hidden;
    display: flex; align-items: center; gap: 14px;
}
.rc-hdr::before {
    content: ''; position: absolute; top: -50%; right: -5%;
    width: 280px; height: 280px; border-radius: 50%;
    background: rgba(255,255,255,0.08); pointer-events: none;
}
.rc-hdr::after {
    content: ''; position: absolute; bottom: -55%; left: 42%;
    width: 180px; height: 180px; border-radius: 50%;
    background: rgba(255,255,255,0.05); pointer-events: none;
}
.rc-hdr-ico {
    width: 46px; height: 46px; background: rgba(255,255,255,0.2);
    border-radius: 13px; display: flex; align-items: center; justify-content: center;
    flex-shrink: 0; position: relative; z-index: 1;
}
.rc-hdr-ico svg { width: 22px; height: 22px; stroke: white; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rc-hdr-txt { position: relative; z-index: 1; }
.rc-hdr-title { margin: 0 0 5px; font-size: 24px; font-weight: 800; letter-spacing: -0.3px; }
.rc-hdr-sub   { margin: 0; opacity: 0.85; font-size: 14px; }

/* ── 双栏布局 ── */
.rc-layout { display: flex; gap: 22px; align-items: flex-start; }
.rc-aside  { width: 318px; min-width: 318px; flex-shrink: 0; }
.rc-main   { flex: 1; min-width: 0; }
@media (max-width: 960px) {
    .rc-layout { flex-direction: column; }
    .rc-aside  { width: 100%; min-width: 0; }
}

/* ── 表单卡片 ── */
.rc-form-card {
    background: white; border-radius: 20px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.06); border: 1px solid #f1f5f9;
    overflow: hidden; position: sticky; top: 14px;
}
.rc-form-head {
    padding: 18px 22px 14px; border-bottom: 1px solid #f1f5f9;
    display: flex; align-items: center; gap: 10px;
}
.rc-form-head-ico {
    width: 32px; height: 32px;
    background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    border-radius: 9px; display: flex; align-items: center; justify-content: center;
}
.rc-form-head-ico svg { width: 15px; height: 15px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rc-form-head-title { font-size: 15px; font-weight: 700; color: #0f172a; margin: 0; }
.rc-form-body { padding: 18px 22px 22px; }

/* 表单字段 */
.rc-fld { margin-bottom: 14px; }
.rc-lbl { display: block; margin-bottom: 6px; font-size: 12.5px; font-weight: 600; color: #475569; }
.rc-req { color: #ef4444; margin-left: 2px; }
.rc-inp {
    width: 100%; padding: 8px 12px;
    border: 1.5px solid #e2e8f0; border-radius: 9px;
    font-size: 13.5px; color: #334155; background: #fafbfc;
    outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
    font-family: inherit;
}
.rc-inp:focus { border-color: #6366f1; background: white; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
.rc-inp::placeholder { color: #94a3b8; }

/* 颜色选择 */
.rc-clr-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 7px; }
.rc-clr-lbl { font-size: 12.5px; font-weight: 600; color: #475569; }
.rc-clr-dot { width: 22px; height: 22px; border-radius: 6px; border: 2px solid #e2e8f0; transition: background 0.2s; flex-shrink: 0; }
.rc-swatches { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 9px; }
.rc-sw {
    width: 26px; height: 26px; border-radius: 7px; cursor: pointer;
    border: 2.5px solid transparent; transition: all 0.18s;
    box-shadow: 0 1px 4px rgba(0,0,0,0.12); flex-shrink: 0;
}
.rc-sw:hover { transform: scale(1.18); border-color: white; box-shadow: 0 3px 8px rgba(0,0,0,0.22); }
.rc-sw.on {
    border-color: white;
    box-shadow: 0 0 0 2.5px #6366f1, 0 2px 8px rgba(0,0,0,0.15);
    transform: scale(1.1);
}

/* 实时预览 */
.rc-prev-lbl { font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.6px; margin: 16px 0 8px; }
.rc-prev {
    border-radius: 12px; overflow: hidden;
    border: 1px solid #f1f5f9; box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.rc-prev-top {
    height: 54px; display: flex; align-items: center; justify-content: center;
    transition: background 0.25s;
}
.rc-prev-bot { padding: 10px 13px; background: white; }
.rc-prev-name { font-size: 13px; font-weight: 700; color: #1e293b; }
.rc-prev-desc { font-size: 11.5px; color: #94a3b8; margin-top: 2px; }

/* 提交按钮 */
.rc-btn-add {
    width: 100%; margin-top: 16px; padding: 11px 16px;
    background: linear-gradient(135deg, #6366f1, #8b5cf6);
    color: white; border: none; border-radius: 11px;
    font-size: 14px; font-weight: 700; cursor: pointer;
    transition: all 0.22s; font-family: inherit;
    box-shadow: 0 4px 14px rgba(99,102,241,0.32);
}
.rc-btn-add:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(99,102,241,0.42); }
.rc-btn-add:active { transform: translateY(0); }

/* ── 列表卡片 ── */
.rc-list-card {
    background: white; border-radius: 20px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.06); border: 1px solid #f1f5f9;
    overflow: hidden;
}
.rc-list-head {
    display: flex; align-items: center; gap: 10px;
    padding: 18px 24px 14px; border-bottom: 1px solid #f1f5f9;
}
.rc-list-head-ico {
    width: 32px; height: 32px;
    background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    border-radius: 9px; display: flex; align-items: center; justify-content: center;
}
.rc-list-head-ico svg { width: 15px; height: 15px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rc-list-title  { font-size: 15px; font-weight: 700; color: #0f172a; margin: 0; flex: 1; }
.rc-total-badge { background: #f1f5f9; color: #64748b; font-size: 12px; font-weight: 600; padding: 3px 10px; border-radius: 20px; }

/* 分类卡片网格 */
.rc-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
    gap: 16px; padding: 18px 20px 22px;
}

/* 单个分类卡片 */
.rc-cat {
    border-radius: 14px; overflow: hidden;
    border: 1.5px solid #f1f5f9; background: white;
    transition: all 0.28s cubic-bezier(0.4,0,0.2,1);
    position: relative;
}
.rc-cat:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 32px rgba(0,0,0,0.10);
    border-color: transparent;
}

/* 卡片彩色头部 */
.rc-cat-top {
    height: 78px; display: flex; align-items: center; justify-content: center;
    position: relative;
}
/* SVG图标样式 */
.rc-svg-icon svg {
    width: 34px; height: 34px; stroke: white; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    filter: drop-shadow(0 2px 5px rgba(0,0,0,0.2));
}
/* 预览区SVG图标 */
.rc-prev-icon svg {
    width: 26px; height: 26px; stroke: white; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    filter: drop-shadow(0 2px 4px rgba(0,0,0,0.18));
}

/* 删除按钮（悬浮在卡片右上角，悬停时显示） */
.rc-del-btn {
    position: absolute; top: 7px; right: 7px;
    width: 24px; height: 24px; border-radius: 7px; padding: 0;
    background-color: rgba(255,255,255,0.22);
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cline x1='18' y1='6' x2='6' y2='18'/%3E%3Cline x1='6' y1='6' x2='18' y2='18'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: center; background-size: 12px;
    border: 1px solid rgba(255,255,255,0.35); cursor: pointer;
    font-size: 0; color: transparent;
    opacity: 0; transition: all 0.2s;
    backdrop-filter: blur(4px); font-family: inherit;
}
.rc-cat:hover .rc-del-btn { opacity: 1; }
.rc-del-btn:hover {
    background-color: rgba(239,68,68,0.8);
    border-color: rgba(239,68,68,0.4);
    transform: scale(1.12); opacity: 1 !important;
}

/* 卡片主体 */
.rc-cat-body { padding: 12px 14px 14px; }
.rc-cat-name { font-size: 14px; font-weight: 700; color: #1e293b; margin: 0 0 5px; }
.rc-cat-desc { font-size: 11.5px; color: #94a3b8; line-height: 1.5; min-height: 26px; margin: 0 0 10px; }
.rc-cat-foot { display: flex; gap: 5px; flex-wrap: wrap; }
.rc-badge {
    display: inline-flex; align-items: center; gap: 3px;
    padding: 3px 8px; border-radius: 20px;
    font-size: 11px; font-weight: 600; white-space: nowrap;
}
.rc-badge svg { width: 10px; height: 10px; fill: none; stroke: currentColor; stroke-width: 2; flex-shrink: 0; }
.rc-badge-res  { background: #f1f5f9; color: #64748b; }
.rc-badge-sort { background: #faf5ff; color: #9333ea; }
.rc-badge-on   { background: #f0fdf4; color: #16a34a; }
.rc-badge-off  { background: #fef2f2; color: #ef4444; }

/* 空状态 */
.rc-empty { text-align: center; padding: 56px 20px; display: none; }
.rc-empty.show { display: block; }
.rc-empty-ico {
    width: 68px; height: 68px; background: #f8fafc; border-radius: 50%;
    display: flex; align-items: center; justify-content: center; margin: 0 auto 14px;
}
.rc-empty-ico svg { width: 28px; height: 28px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; }
.rc-empty-title { font-size: 15px; font-weight: 600; color: #475569; margin: 0 0 5px; }
.rc-empty-desc  { font-size: 13px; color: #94a3b8; margin: 0; }

/* Toast */
.toast {
    position: fixed; top: 22px; right: 22px; background: white;
    padding: 14px 20px; border-radius: 14px; min-width: 240px;
    box-shadow: 0 12px 48px rgba(0,0,0,0.14); z-index: 10000;
    display: none; align-items: center; gap: 10px;
    animation: rcToastIn 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    border-left: 4px solid;
}
@keyframes rcToastIn {
    from { transform: translateX(110%); opacity: 0; }
    to   { transform: translateX(0);    opacity: 1; }
}
.toast.success { border-left-color: #10b981; }
.toast.error   { border-left-color: #ef4444; }
.toast-icon { width: 20px; height: 20px; flex-shrink: 0; display: flex; align-items: center; }
.toast-icon svg { width: 20px; height: 20px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.toast.success .toast-icon svg { stroke: #10b981; }
.toast.error   .toast-icon svg { stroke: #ef4444; }
.toast-message { font-size: 14px; font-weight: 500; color: #1e293b; line-height: 1.4; }
</style>

<div class="rc-wrap">

    <%-- 页头 --%>
    <div class="rc-hdr">
        <div class="rc-hdr-ico">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
        </div>
        <div class="rc-hdr-txt">
            <h1 class="rc-hdr-title">资源分类管理</h1>
            <p class="rc-hdr-sub">管理资源分类，为教学资源建立清晰的分类体系</p>
        </div>
    </div>

    <div class="rc-layout">

        <%-- 左栏：表单面板 --%>
        <div class="rc-aside">
            <div class="rc-form-card">
                <div class="rc-form-head">
                    <div class="rc-form-head-ico">
                        <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    </div>
                    <h2 class="rc-form-head-title">新建分类</h2>
                </div>
                <div class="rc-form-body">

                    <div class="rc-fld">
                        <label class="rc-lbl">分类名称<span class="rc-req">*</span></label>
                        <asp:TextBox ID="txtCategoryName" runat="server" CssClass="rc-inp" placeholder="例如：视频教程" oninput="rcPreview()"></asp:TextBox>
                    </div>

                    <div class="rc-fld">
                        <label class="rc-lbl">分类图标（SVG关键词）</label>
                        <asp:TextBox ID="txtCategoryIcon" runat="server" CssClass="rc-inp" placeholder="video / doc / image / audio / code / zip" oninput="rcPreview()"></asp:TextBox>
                    </div>

                    <%-- 颜色选择器 --%>
                    <div class="rc-fld">
                        <div class="rc-clr-row">
                            <span class="rc-clr-lbl">分类颜色</span>
                            <div class="rc-clr-dot" id="rcClrDot" style="background:#6366f1"></div>
                        </div>
                        <div class="rc-swatches">
                            <div class="rc-sw on" style="background:#6366f1" data-c="#6366f1" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#8b5cf6" data-c="#8b5cf6" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#3b82f6" data-c="#3b82f6" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#06b6d4" data-c="#06b6d4" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#10b981" data-c="#10b981" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#22c55e" data-c="#22c55e" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#f59e0b" data-c="#f59e0b" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#f97316" data-c="#f97316" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#ef4444" data-c="#ef4444" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#ec4899" data-c="#ec4899" onclick="rcPickClr(this)"></div>
                            <div class="rc-sw"    style="background:#64748b" data-c="#64748b" onclick="rcPickClr(this)"></div>
                        </div>
                        <asp:TextBox ID="txtCategoryColor" runat="server" CssClass="rc-inp" Text="#6366f1" placeholder="#6366f1" oninput="rcHexInput(this)"></asp:TextBox>
                    </div>

                    <div class="rc-fld">
                        <label class="rc-lbl">分类描述</label>
                        <asp:TextBox ID="txtCategoryDesc" runat="server" CssClass="rc-inp" placeholder="描述该分类的用途…" oninput="rcPreview()"></asp:TextBox>
                    </div>

                    <div class="rc-fld">
                        <label class="rc-lbl">排序权重（数字越小越靠前）</label>
                        <asp:TextBox ID="txtSortOrder" runat="server" CssClass="rc-inp" Text="0"></asp:TextBox>
                    </div>

                    <%-- 实时预览 --%>
                    <div class="rc-prev-lbl">预览效果</div>
                    <div class="rc-prev">
                        <div class="rc-prev-top" id="rcPrevTop" style="background:linear-gradient(135deg,#6366f1,#8b5cf6)">
                            <span id="rcPrevIco" class="rc-prev-icon">
                                <svg viewBox="0 0 24 24"><path d="M3 7v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-6l-2-2H5a2 2 0 0 0-2 2z"/></svg>
                            </span>
                        </div>
                        <div class="rc-prev-bot">
                            <div class="rc-prev-name" id="rcPrevName">分类名称</div>
                            <div class="rc-prev-desc" id="rcPrevDesc">分类描述</div>
                        </div>
                    </div>

                    <asp:Button ID="btnSave" runat="server" CssClass="rc-btn-add" Text="添加分类" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>

        <%-- 右栏：分类列表 --%>
        <div class="rc-main">
            <div class="rc-list-card">
                <div class="rc-list-head">
                    <div class="rc-list-head-ico">
                        <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                    </div>
                    <h2 class="rc-list-title">分类列表</h2>
                    <span class="rc-total-badge" id="rcTotalBadge">&hellip;</span>
                </div>

                <div class="rc-grid" id="rcGrid">
                    <asp:Repeater ID="rptCategories" runat="server">
                        <ItemTemplate>
                            <div class="rc-cat">
                                <div class="rc-cat-top"
                                    style='background:linear-gradient(135deg,<%# Eval("CategoryColor") %>,<%# Eval("CategoryColor") %>bb)'>
                                    <asp:Button ID="btnDelete" runat="server"
                                        CssClass="rc-del-btn"
                                        CommandArgument='<%# Eval("CategoryId") %>'
                                        OnClick="btnDelete_Click"
                                        OnClientClick='<%# "return confirm(\"\u786e\u5b9a\u5220\u9664\u300c" + Eval("CategoryName") + "\u300d\uff1f\");" %>'
                                        Text="x" />
                                    <%# GetCardIcon(Eval("CategoryIcon"), Eval("CategoryName")) %>
                                </div>
                                <div class="rc-cat-body">
                                    <div class="rc-cat-name"><%# Eval("CategoryName") %></div>
                                    <div class="rc-cat-desc"><%# string.IsNullOrEmpty(Eval("Description").ToString()) ? "暂无描述" : Eval("Description") %></div>
                                    <div class="rc-cat-foot">
                                        <span class="rc-badge rc-badge-res">
                                            <svg viewBox="0 0 24 24"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                                            <%# Eval("ResourceCount") %> 个
                                        </span>
                                        <span class="rc-badge rc-badge-sort">
                                            <svg viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"/></svg>
                                            <%# Eval("SortOrder") %>
                                        </span>
                                        <%# Convert.ToBoolean(Eval("IsActive"))
                                            ? "<span class=\"rc-badge rc-badge-on\">&#x25cf; 启用</span>"
                                            : "<span class=\"rc-badge rc-badge-off\">&#x25cf; 停用</span>" %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="rc-empty" id="rcEmpty">
                    <div class="rc-empty-ico">
                        <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                    </div>
                    <p class="rc-empty-title">暂无分类</p>
                    <p class="rc-empty-desc">在左侧表单创建第一个分类</p>
                </div>
            </div>
        </div>

    </div>
</div>

<div id="toast" class="toast">
    <span class="toast-icon" id="toastIcon"></span>
    <span class="toast-message" id="toastMessage"></span>
</div>

<script type="text/javascript">
    /* Toast */
    function showToast(msg, type) {
        var t = document.getElementById('toast');
        t.className = 'toast ' + type;
        var _svgOk  = "<svg viewBox='0 0 24 24'><path d='M22 11.08V12a10 10 0 11-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>";
        var _svgErr = "<svg viewBox='0 0 24 24'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>";
        document.getElementById('toastIcon').innerHTML = type === 'success' ? _svgOk : _svgErr;
        document.getElementById('toastMessage').textContent = msg;
        t.style.display = 'flex';
        setTimeout(function () { t.style.display = 'none'; }, 3200);
    }

    /* 颜色色块点击 */
    var _rcClr = '#6366f1';
    function rcPickClr(el) {
        _rcClr = el.getAttribute('data-c');
        document.querySelectorAll('.rc-sw').forEach(function (s) { s.classList.remove('on'); });
        el.classList.add('on');
        var hexEl = document.getElementById('<%= txtCategoryColor.ClientID %>');
        if (hexEl) hexEl.value = _rcClr;
        rcApplyClr(_rcClr);
    }
    function rcHexInput(el) {
        var v = el.value.trim();
        if (/^#[0-9a-fA-F]{3,6}$/.test(v)) {
            _rcClr = v;
            document.querySelectorAll('.rc-sw').forEach(function (s) {
                s.classList.toggle('on', s.getAttribute('data-c').toLowerCase() === v.toLowerCase());
            });
            rcApplyClr(v);
        }
    }
    function rcApplyClr(c) {
        var dot = document.getElementById('rcClrDot');
        if (dot) dot.style.background = c;
        var top = document.getElementById('rcPrevTop');
        if (top) top.style.background = 'linear-gradient(135deg,' + c + ',' + c + 'bb)';
        var on = document.querySelector('.rc-sw.on');
        if (on) on.style.boxShadow = '0 0 0 2.5px ' + c + ',0 2px 8px rgba(0,0,0,0.15)';
    }

    /* SVG图标映射 */
    function rcGetSvgIcon(iv, nv) {
        var s = (iv || '').trim().toLowerCase() || (nv || '').trim().toLowerCase();
        if (s === 'video' || s.indexOf('视频') >= 0 || s.indexOf('教程') >= 0)
            return "<svg viewBox='0 0 24 24'><path d='M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z'/></svg>";
        if (s === 'audio' || s.indexOf('音频') >= 0 || s.indexOf('音乐') >= 0)
            return "<svg viewBox='0 0 24 24'><path d='M9 18V5l12-2v13M9 18c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3zm12-2c0 1.657-1.343 3-3 3s-3-1.343-3-3 1.343-3 3-3 3 1.343 3 3z'/></svg>";
        if (s === 'image' || s.indexOf('图片') >= 0 || s.indexOf('素材') >= 0 || s.indexOf('图像') >= 0)
            return "<svg viewBox='0 0 24 24'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
        if (s === 'doc' || s.indexOf('文档') >= 0 || s.indexOf('资料') >= 0 || s.indexOf('文件') >= 0)
            return "<svg viewBox='0 0 24 24'><path d='M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'/></svg>";
        if (s === 'code' || s.indexOf('代码') >= 0 || s.indexOf('编程') >= 0 || s.indexOf('源码') >= 0)
            return "<svg viewBox='0 0 24 24'><polyline points='16 18 22 12 16 6'/><polyline points='8 6 2 12 8 18'/></svg>";
        if (s === 'zip' || s.indexOf('压缩') >= 0 || s.indexOf('打包') >= 0)
            return "<svg viewBox='0 0 24 24'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
        if (s.indexOf('课件') >= 0 || s.indexOf('ppt') >= 0 || s.indexOf('演示') >= 0)
            return "<svg viewBox='0 0 24 24'><path d='M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 012 2v14a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z'/><path d='M11 14l2 2 4-4'/></svg>";
        if (s.indexOf('工具') >= 0 || s.indexOf('软件') >= 0)
            return "<svg viewBox='0 0 24 24'><path d='M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z'/></svg>";
        return "<svg viewBox='0 0 24 24'><path d='M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z'/></svg>";
    }
    /* 实时预览 */
    function rcPreview() {
        var n = (document.getElementById('<%= txtCategoryName.ClientID %>') || {}).value || '';
        var i = (document.getElementById('<%= txtCategoryIcon.ClientID %>') || {}).value || '';
        var d = (document.getElementById('<%= txtCategoryDesc.ClientID %>') || {}).value || '';
        var pn = document.getElementById('rcPrevName');
        var pi = document.getElementById('rcPrevIco');
        var pd = document.getElementById('rcPrevDesc');
        if (pn) pn.textContent = n.trim() || '分类名称';
        if (pi) pi.innerHTML = rcGetSvgIcon(i, n);
        if (pd) pd.textContent = d.trim() || '分类描述';
    }

    /* 分类总数徽章 + 空状态 */
    (function () {
        function rcCount() {
            var grid  = document.getElementById('rcGrid');
            var badge = document.getElementById('rcTotalBadge');
            var empty = document.getElementById('rcEmpty');
            if (!grid) return;
            var n = grid.querySelectorAll('.rc-cat').length;
            if (badge) badge.textContent = '\u5171 ' + n + ' \u4e2a';
            if (empty) empty.className = n === 0 ? 'rc-empty show' : 'rc-empty';
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', rcCount);
        } else { rcCount(); }
    })();
</script>
</asp:Content>
