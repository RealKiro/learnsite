<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>

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
            EnsureCategoryTable();
            EnsureBadgeTable();
            LoadCategories();
            BindGrid();
        }
    }

    /// <summary>
    /// 自动创建 Badge 表（如果不存在）
    /// </summary>
    private void EnsureBadgeTable()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='Badge' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists > 0) return;
                }
                string createSql = @"CREATE TABLE [dbo].[Badge](
                    [Bid]       [int]           IDENTITY(1,1) NOT NULL,
                    [Bname]     [nvarchar](100) NULL,
                    [Bicon]     [nvarchar](500) NULL,
                    [Bdesc]     [nvarchar](500) NULL,
                    [Bcategory] [nvarchar](100) NULL,
                    [Bpoints]   [int]           NULL DEFAULT(0),
                    [Bhid]      [int]           NULL DEFAULT(0),
                    [Bdate]     [datetime]      NULL,
                    [Bsort]     [int]           NULL DEFAULT(0),
                    [Bactive]   [bit]           NULL DEFAULT(1),
                    PRIMARY KEY CLUSTERED ([Bid] ASC))";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(createSql, conn))
                { cmd.ExecuteNonQuery(); }
            }
        }
        catch { }
    }

    /// <summary>
    /// 自动创建 BadgeCategory 表（如果不存在），并插入默认类别
    /// </summary>
    private void EnsureCategoryTable()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='BadgeCategory' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists > 0) return;
                }
                string createSql = @"CREATE TABLE [dbo].[BadgeCategory](
                    [Cid] [int] IDENTITY(1,1) NOT NULL,
                    [Cname] [nvarchar](50) NULL,
                    [Csort] [int] NULL DEFAULT(0),
                    [Cdate] [datetime] NULL,
                    PRIMARY KEY CLUSTERED ([Cid] ASC))";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(createSql, conn))
                { cmd.ExecuteNonQuery(); }
                string[] defaults = { "学业", "品德", "特长", "创新", "合作", "其他" };
                for (int i = 0; i < defaults.Length; i++)
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "INSERT INTO BadgeCategory(Cname,Csort,Cdate) VALUES(@name,@sort,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@name", defaults[i]);
                        cmd.Parameters.AddWithValue("@sort", i + 1);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
        }
        catch { }
    }

    /// <summary>
    /// 从数据库加载类别到下拉列表和 Repeater
    /// </summary>
    private void LoadCategories()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(
                    "SELECT Cid,Cname FROM BadgeCategory ORDER BY Csort,Cid", conn);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);

                DDLCategory.Items.Clear();
                foreach (System.Data.DataRow row in dt.Rows)
                {
                    DDLCategory.Items.Add(new System.Web.UI.WebControls.ListItem(
                        row["Cname"].ToString(), row["Cname"].ToString()));
                }

                RptCategories.DataSource = dt;
                RptCategories.DataBind();
            }
        }
        catch { }
    }

    /// <summary>
    /// 获取类别列表（供 GridView 编辑行使用）
    /// </summary>
    private System.Collections.Generic.List<string> GetCategoryList()
    {
        System.Collections.Generic.List<string> cats = new System.Collections.Generic.List<string>();
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return cats;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Cname FROM BadgeCategory ORDER BY Csort,Cid", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    { while (r.Read()) cats.Add(r.GetString(0)); }
                }
            }
        }
        catch { }
        if (cats.Count == 0) { cats.AddRange(new string[] { "学业", "品德", "特长", "创新", "合作", "其他" }); }
        return cats;
    }

    protected void BtnAddCat_Click(object sender, EventArgs e)
    {
        string catName = TxtNewCat.Text.Trim();
        if (string.IsNullOrEmpty(catName)) { pageMsg = "请输入类别名称"; LoadCategories(); BindGrid(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM BadgeCategory WHERE Cname=@name", conn))
                {
                    chk.Parameters.AddWithValue("@name", catName);
                    int cnt = Convert.ToInt32(chk.ExecuteScalar());
                    if (cnt > 0) { pageMsg = "该类别已存在"; LoadCategories(); BindGrid(); return; }
                }
                int maxSort = 0;
                using (System.Data.SqlClient.SqlCommand cmdMax = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(MAX(Csort),0) FROM BadgeCategory", conn))
                { object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }

                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "INSERT INTO BadgeCategory(Cname,Csort,Cdate) VALUES(@name,@sort,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@name", catName);
                    cmd.Parameters.AddWithValue("@sort", maxSort + 1);
                    cmd.ExecuteNonQuery();
                }
            }
            TxtNewCat.Text = "";
            pageMsg = "类别添加成功";
        }
        catch (Exception ex) { pageMsg = "类别添加失败: " + ex.Message; }
        LoadCategories();
        BindGrid();
    }

    protected void RptCategories_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "DelCat")
        {
            int cid = 0; int.TryParse(e.CommandArgument.ToString(), out cid);
            if (cid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "DELETE FROM BadgeCategory WHERE Cid=@cid", conn))
                    { cmd.Parameters.AddWithValue("@cid", cid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "类别已删除";
            }
            catch (Exception ex) { pageMsg = "类别删除失败: " + ex.Message; }
            LoadCategories();
            BindGrid();
        }
    }

    private void BindGrid()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Bid,Bname,Bicon,Bdesc,Bcategory,Bpoints,Bactive,Bdate,Bsort FROM Badge ORDER BY Bsort,Bid";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                GVBadge.DataSource = dt;
                GVBadge.DataBind();
            }
        }
        catch { }
    }

    protected void BtnAdd_Click(object sender, EventArgs e)
    {
        string name = TxtName.Text.Trim();
        if (string.IsNullOrEmpty(name)) { pageMsg = "请输入徽章名称"; LoadCategories(); BindGrid(); return; }

        // 处理图标上传
        string iconPath = TxtIcon.Text.Trim();
        if (FileUploadIcon.HasFile)
        {
            string ext = Path.GetExtension(FileUploadIcon.FileName).ToLower();
            string[] allowedExts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg" };
            bool valid = false;
            foreach (string ae in allowedExts) { if (ext == ae) { valid = true; break; } }
            if (!valid)
            {
                pageMsg = "图标仅支持 png/jpg/jpeg/gif/webp/svg 格式";
                LoadCategories(); BindGrid(); return;
            }
            string badgeDir = Server.MapPath("~/images/badges/");
            if (!Directory.Exists(badgeDir)) Directory.CreateDirectory(badgeDir);

            string fileName = "badge_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + new Random().Next(1000, 9999) + ext;
            string savePath = Path.Combine(badgeDir, fileName);
            FileUploadIcon.SaveAs(savePath);
            iconPath = "../images/badges/" + fileName;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                int maxSort = 0;
                using (System.Data.SqlClient.SqlCommand cmdMax = new System.Data.SqlClient.SqlCommand("SELECT ISNULL(MAX(Bsort),0) FROM Badge", conn))
                { object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }

                string sql = "INSERT INTO Badge(Bname,Bicon,Bdesc,Bcategory,Bpoints,Bhid,Bdate,Bsort,Bactive) VALUES(@name,@icon,@desc,@cat,@pts,@hid,GETDATE(),@sort,1)";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@icon", iconPath);
                    cmd.Parameters.AddWithValue("@desc", TxtDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@cat", DDLCategory.SelectedValue);
                    int pts = 0; int.TryParse(TxtPoints.Text.Trim(), out pts);
                    cmd.Parameters.AddWithValue("@pts", pts);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.Parameters.AddWithValue("@sort", maxSort + 1);
                    cmd.ExecuteNonQuery();
                }
            }
            TxtName.Text = ""; TxtIcon.Text = ""; TxtDesc.Text = ""; TxtPoints.Text = "";
            pageMsg = "添加成功";
        }
        catch (Exception ex) { pageMsg = "添加失败: " + ex.Message; }
        LoadCategories();
        BindGrid();
    }

    protected void GVBadge_RowEditing(object sender, System.Web.UI.WebControls.GridViewEditEventArgs e)
    {
        GVBadge.EditIndex = e.NewEditIndex;
        BindGrid();
    }

    protected void GVBadge_RowCancelingEdit(object sender, System.Web.UI.WebControls.GridViewCancelEditEventArgs e)
    {
        GVBadge.EditIndex = -1;
        BindGrid();
    }

    protected void GVBadge_RowUpdating(object sender, System.Web.UI.WebControls.GridViewUpdateEventArgs e)
    {
        int bid = Convert.ToInt32(GVBadge.DataKeys[e.RowIndex].Value);
        System.Web.UI.WebControls.GridViewRow row = GVBadge.Rows[e.RowIndex];
        string newName = ((System.Web.UI.WebControls.TextBox)row.FindControl("TBoxBname")).Text.Trim();
        string newIcon = ((System.Web.UI.WebControls.TextBox)row.FindControl("TBoxBicon")).Text.Trim();
        string newDesc = ((System.Web.UI.WebControls.TextBox)row.FindControl("TBoxBdesc")).Text.Trim();
        string newCat = ((System.Web.UI.WebControls.DropDownList)row.FindControl("DDLEditCat")).SelectedValue;
        int newPts = 0;
        int.TryParse(((System.Web.UI.WebControls.TextBox)row.FindControl("TBoxBpoints")).Text.Trim(), out newPts);

        if (string.IsNullOrEmpty(newName)) { pageMsg = "徽章名称不能为空"; return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "UPDATE Badge SET Bname=@name,Bicon=@icon,Bdesc=@desc,Bcategory=@cat,Bpoints=@pts WHERE Bid=@bid", conn))
                {
                    cmd.Parameters.AddWithValue("@name", newName);
                    cmd.Parameters.AddWithValue("@icon", newIcon);
                    cmd.Parameters.AddWithValue("@desc", newDesc);
                    cmd.Parameters.AddWithValue("@cat", newCat);
                    cmd.Parameters.AddWithValue("@pts", newPts);
                    cmd.Parameters.AddWithValue("@bid", bid);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "更新成功";
        }
        catch (Exception ex) { pageMsg = "更新失败: " + ex.Message; }
        GVBadge.EditIndex = -1;
        BindGrid();
    }

    protected void GVBadge_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        int rowIndex = 0;
        if (!int.TryParse(e.CommandArgument.ToString(), out rowIndex)) return;

        if (e.CommandName == "Del")
        {
            int bid = Convert.ToInt32(GVBadge.DataKeys[rowIndex].Value);
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("DELETE FROM Badge WHERE Bid=@bid", conn))
                    { cmd.Parameters.AddWithValue("@bid", bid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "已删除";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; }
            BindGrid();
        }
        else if (e.CommandName == "Toggle")
        {
            int bid = Convert.ToInt32(GVBadge.DataKeys[rowIndex].Value);
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "UPDATE Badge SET Bactive=CASE WHEN ISNULL(Bactive,1)=1 THEN 0 ELSE 1 END WHERE Bid=@bid", conn))
                    { cmd.Parameters.AddWithValue("@bid", bid); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
            BindGrid();
        }
        else if (e.CommandName == "Top" || e.CommandName == "Bottom")
        {
            SwapSort(rowIndex, e.CommandName == "Top" ? -1 : 1);
            BindGrid();
        }
    }

    private void SwapSort(int rowIndex, int direction)
    {
        int targetIndex = rowIndex + direction;
        if (targetIndex < 0 || targetIndex >= GVBadge.Rows.Count) return;
        int bid1 = Convert.ToInt32(GVBadge.DataKeys[rowIndex].Value);
        int bid2 = Convert.ToInt32(GVBadge.DataKeys[targetIndex].Value);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                int sort1 = 0, sort2 = 0;
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT Bsort FROM Badge WHERE Bid=@bid", conn))
                { cmd.Parameters.AddWithValue("@bid", bid1); object v = cmd.ExecuteScalar(); if (v != null && v != DBNull.Value) sort1 = Convert.ToInt32(v); }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT Bsort FROM Badge WHERE Bid=@bid", conn))
                { cmd.Parameters.AddWithValue("@bid", bid2); object v = cmd.ExecuteScalar(); if (v != null && v != DBNull.Value) sort2 = Convert.ToInt32(v); }
                if (sort1 == sort2) sort2 = sort1 + direction;
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("UPDATE Badge SET Bsort=@s WHERE Bid=@bid", conn))
                { cmd.Parameters.AddWithValue("@s", sort2); cmd.Parameters.AddWithValue("@bid", bid1); cmd.ExecuteNonQuery(); }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("UPDATE Badge SET Bsort=@s WHERE Bid=@bid", conn))
                { cmd.Parameters.AddWithValue("@s", sort1); cmd.Parameters.AddWithValue("@bid", bid2); cmd.ExecuteNonQuery(); }
            }
        }
        catch { }
    }

    protected void GVBadge_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
    {
        if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
        {
            if ((e.Row.RowState & System.Web.UI.WebControls.DataControlRowState.Edit) != 0)
            {
                System.Web.UI.WebControls.DropDownList ddl = (System.Web.UI.WebControls.DropDownList)e.Row.FindControl("DDLEditCat");
                if (ddl != null)
                {
                    System.Collections.Generic.List<string> cats = GetCategoryList();
                    ddl.Items.Clear();
                    foreach (string c in cats) ddl.Items.Add(new System.Web.UI.WebControls.ListItem(c, c));
                    string curCat = DataBinder.Eval(e.Row.DataItem, "Bcategory") as string ?? "";
                    if (ddl.Items.FindByValue(curCat) != null) ddl.SelectedValue = curCat;
                }
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .bs-page { max-width: 1600px; width: 100%; margin: 0 auto; }
    .bs-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .bs-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .bs-title .bs-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#f59e0b,#fbbf24); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .bs-title .bs-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bs-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .bs-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden; }
    .bs-card-head { padding: 16px 24px; border-bottom: 1px solid #f1f5f9; background: #fafbfc; font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .bs-card-head svg { width: 18px; height: 18px; stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bs-card-body { padding: 0; }
    .bs-card-body table { width: 100%; border-collapse: collapse; }
    .bs-card-body table th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 12px; padding: 12px 16px; border-bottom: 2px solid #e8ecf1; text-align: left; }
    .bs-card-body table td { padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155; }
    .bs-card-body table tr:hover td { background: #fffbeb; }
    .bs-card-body table tr:last-child td { border-bottom: none; }
    .bs-card-body table input[type="text"] { padding: 6px 12px; border-radius: 6px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fffde7; outline: none; }
    .bs-card-body table input[type="text"]:focus { border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,.1); }
    .bs-card-body table select { padding: 6px 10px; border-radius: 6px; border: 1px solid #e2e8f0; font-size: 13px; background: #fffde7; }
    .bs-card-body table a { color: #3b82f6; text-decoration: none; font-weight: 500; }
    .bs-card-body table a:hover { color: #2563eb; text-decoration: underline; }
    .bs-badge-icon { width: 56px; height: 56px; border-radius: 0; background: none; display: flex; align-items: center; justify-content: center; border: none; box-shadow: none; transition: all .2s ease; position: relative; overflow: visible; }
    .bs-badge-icon::before { display: none; }
    .bs-badge-icon:hover { transform: scale(1.08); }
    .bs-badge-icon img { width: 52px; height: 52px; object-fit: contain; border-radius: 0; position: relative; z-index: 1; filter: drop-shadow(0 1px 2px rgba(0,0,0,.08)); }
    .bs-badge-icon svg { width: 32px; height: 32px; stroke: #f59e0b; fill: none; stroke-width: 2; position: relative; z-index: 1; }
    .bs-status { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
    .bs-status-on { background: #dcfce7; color: #16a34a; }
    .bs-status-off { background: #fee2e2; color: #dc2626; }
    .bs-cat { display: inline-block; padding: 2px 10px; border-radius: 10px; font-size: 11px; font-weight: 500; background: #eef2ff; color: #4f46e5; }
    .bs-pts { font-weight: 700; color: #f59e0b; }
    .bs-add-area { padding: 24px; background: #fafbfc; border-top: 1px solid #f1f5f9; }
    .bs-add-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
    .bs-form-group { display: flex; flex-direction: column; gap: 6px; }
    .bs-form-group label { font-size: 12px; font-weight: 600; color: #64748b; }
    .bs-form-group input, .bs-form-group select, .bs-form-group textarea {
        padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155;
        background: #fff; outline: none; transition: border-color .15s; font-family: inherit;
    }
    .bs-form-group input:focus, .bs-form-group select:focus, .bs-form-group textarea:focus {
        border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,.1);
    }
    .bs-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; font-family: inherit; }
    .bs-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .bs-btn-primary { background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff; border-color: #f59e0b; box-shadow: 0 2px 8px rgba(245,158,11,.2); }
    .bs-btn-primary:hover { background: linear-gradient(135deg,#d97706,#f59e0b); }
    .bs-btn-sm { padding: 4px 12px; font-size: 12px; border-radius: 6px; }
    .bs-btn-danger { color: #ef4444; border-color: #fecaca; }
    .bs-btn-danger:hover { background: #fef2f2; }
    .bs-msg { padding: 10px 16px; border-radius: 8px; background: #fef3c7; border: 1px solid #fde68a; color: #92400e; font-size: 13px; margin-bottom: 16px; }
    /* 类别管理 */
    .bs-cat-area { padding: 20px 24px; }
    .bs-cat-tags { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
    .bs-cat-tag { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 20px; background: #eef2ff; color: #4f46e5; font-size: 13px; font-weight: 500; border: 1px solid #c7d2fe; }
    .bs-cat-tag .bs-cat-del { display: inline-flex; align-items: center; justify-content: center; width: 18px; height: 18px; border-radius: 50%; background: #e0e7ff; color: #6366f1; font-size: 14px; cursor: pointer; border: none; font-family: inherit; line-height: 1; padding: 0; text-decoration: none; }
    .bs-cat-tag .bs-cat-del:hover { background: #fecaca; color: #ef4444; text-decoration: none; }
    .bs-cat-add-row { display: flex; align-items: center; gap: 10px; }
    .bs-cat-add-row input { padding: 7px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; width: 180px; }
    .bs-cat-add-row input:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    /* 图标上传 */
    .bs-upload-group { display: flex; flex-direction: column; gap: 6px; }
    .bs-upload-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .bs-upload-area { padding: 16px; border: 2px dashed #e2e8f0; border-radius: 12px; background: linear-gradient(135deg,#fffbeb 0%,#fefce8 100%); transition: all .2s; }
    .bs-upload-area:hover { border-color: #f59e0b; background: linear-gradient(135deg,#fef3c7 0%,#fefce8 100%); }
    .bs-upload-area-inner { display: flex; align-items: center; gap: 14px; }
    .bs-upload-icon { width: 48px; height: 48px; border-radius: 12px; background: linear-gradient(135deg,#f59e0b,#fbbf24); display: flex; align-items: center; justify-content: center; flex-shrink: 0; box-shadow: 0 2px 8px rgba(245,158,11,.2); }
    .bs-upload-icon svg { width: 24px; height: 24px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bs-upload-info { flex: 1; min-width: 0; }
    .bs-upload-info-title { font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 4px; }
    .bs-upload-hint { font-size: 11px; color: #94a3b8; margin-top: 0; }
    .bs-or-divider { display: flex; align-items: center; gap: 12px; margin: 10px 0 6px; }
    .bs-or-divider::before, .bs-or-divider::after { content: ''; flex: 1; height: 1px; background: #e2e8f0; }
    .bs-or-text { font-size: 12px; color: #94a3b8; font-weight: 500; flex-shrink: 0; }
</style>

<div class="bs-page">
    <div class="bs-header">
        <div>
            <div class="bs-title">
                <span class="bs-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg></span>
                徽章设置
            </div>
            <div class="bs-subtitle">创建和管理各类荣誉徽章，设置徽章名称、图标、类别和积分值</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="bs-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <!-- 类别管理卡片 -->
    <div class="bs-card">
        <div class="bs-card-head">
            <svg viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
            类别管理
        </div>
        <div class="bs-cat-area">
            <div class="bs-cat-tags">
                <asp:Repeater ID="RptCategories" runat="server" OnItemCommand="RptCategories_ItemCommand">
                    <ItemTemplate>
                        <span class="bs-cat-tag">
                            <%# Server.HtmlEncode(Eval("Cname").ToString()) %>
                            <asp:LinkButton runat="server" CssClass="bs-cat-del" CausesValidation="false"
                                CommandName="DelCat" CommandArgument='<%# Eval("Cid") %>'
                                OnClientClick="return confirm('确定删除该类别吗？');" ToolTip="删除">&#215;</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div class="bs-cat-add-row">
                <asp:TextBox ID="TxtNewCat" runat="server" MaxLength="50" placeholder="输入新类别名称" />
                <asp:Button ID="BtnAddCat" runat="server" Text="添加类别" OnClick="BtnAddCat_Click" CssClass="bs-btn bs-btn-sm bs-btn-primary" />
            </div>
        </div>
    </div>

    <!-- 徽章列表卡片 -->
    <div class="bs-card">
        <div class="bs-card-head">
            <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            徽章列表
        </div>
        <div class="bs-card-body">
            <asp:GridView ID="GVBadge" runat="server" AutoGenerateColumns="False"
                DataKeyNames="Bid" Width="100%" CellPadding="0" Font-Size="9pt"
                OnRowCommand="GVBadge_RowCommand" OnRowDataBound="GVBadge_RowDataBound"
                OnRowCancelingEdit="GVBadge_RowCancelingEdit" OnRowEditing="GVBadge_RowEditing"
                OnRowUpdating="GVBadge_RowUpdating" ShowHeaderWhenEmpty="true"
                EmptyDataText="暂无徽章，请在下方添加">
                <Columns>
                    <asp:TemplateField HeaderText="ID">
                        <ItemTemplate>
                            <asp:Label ID="LblBid" runat="server" Text='<%# Eval("Bid") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle Width="40px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="图标">
                        <ItemTemplate>
                            <div class="bs-badge-icon">
                <asp:Image ID="ImgIcon" runat="server" Width="48" Height="48"
                                    ImageUrl='<%# Eval("Bicon") != DBNull.Value && Eval("Bicon").ToString().Length > 0 && (Eval("Bicon").ToString().Contains("/") || Eval("Bicon").ToString().Contains(".")) ? Eval("Bicon").ToString() : "" %>'
                                    Visible='<%# Eval("Bicon") != DBNull.Value && Eval("Bicon").ToString().Length > 0 && (Eval("Bicon").ToString().Contains("/") || Eval("Bicon").ToString().Contains(".")) %>' />
                                <asp:Literal ID="LitIconSvg" runat="server"
                                    Visible='<%# Eval("Bicon") == DBNull.Value || Eval("Bicon").ToString().Length == 0 || !(Eval("Bicon").ToString().Contains("/") || Eval("Bicon").ToString().Contains(".")) %>'
                                    Text='&lt;svg viewBox="0 0 24 24"&gt;&lt;circle cx="12" cy="8" r="6"/&gt;&lt;path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/&gt;&lt;/svg&gt;' />
                            </div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxBicon" runat="server" Text='<%# Bind("Bicon") %>' Width="120px" placeholder="图标URL"></asp:TextBox>
                        </EditItemTemplate>
                <ItemStyle Width="70px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="名称">
                        <ItemTemplate>
                            <strong><%# Server.HtmlEncode(Eval("Bname") == DBNull.Value ? "" : Eval("Bname").ToString()) %></strong>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxBname" runat="server" Text='<%# Bind("Bname") %>' Width="120px"></asp:TextBox>
                        </EditItemTemplate>
                        <ItemStyle Width="120px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="类别">
                        <ItemTemplate>
                            <span class="bs-cat"><%# Server.HtmlEncode(Eval("Bcategory") == DBNull.Value ? "" : Eval("Bcategory").ToString()) %></span>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:DropDownList ID="DDLEditCat" runat="server"></asp:DropDownList>
                        </EditItemTemplate>
                        <ItemStyle Width="80px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="积分">
                        <ItemTemplate>
                            <span class="bs-pts"><%# Eval("Bpoints") %></span>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxBpoints" runat="server" Text='<%# Bind("Bpoints") %>' Width="60px"></asp:TextBox>
                        </EditItemTemplate>
                        <ItemStyle Width="60px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="描述">
                        <ItemTemplate>
                            <span style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;display:inline-block;"><%# Server.HtmlEncode(Eval("Bdesc") == DBNull.Value ? "" : Eval("Bdesc").ToString()) %></span>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxBdesc" runat="server" Text='<%# Bind("Bdesc") %>' Width="180px"></asp:TextBox>
                        </EditItemTemplate>
                        <ItemStyle Width="200px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="状态">
                        <ItemTemplate>
                            <span class='<%# Convert.ToBoolean(Eval("Bactive") == DBNull.Value ? true : Eval("Bactive")) ? "bs-status bs-status-on" : "bs-status bs-status-off" %>'>
                                <%# Convert.ToBoolean(Eval("Bactive") == DBNull.Value ? true : Eval("Bactive")) ? "启用" : "停用" %>
                            </span>
                        </ItemTemplate>
                        <ItemStyle Width="60px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="排序">
                        <ItemTemplate>
                            <asp:LinkButton ID="BtnTop" runat="server" CausesValidation="False" CommandName="Top"
                                CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="&#9650;" ToolTip="上移"
                                Font-Underline="False"></asp:LinkButton>
                            &nbsp;
                            <asp:LinkButton ID="BtnBottom" runat="server" CausesValidation="False" CommandName="Bottom"
                                CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="&#9660;" ToolTip="下移"
                                Font-Underline="False"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="60px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="操作">
                        <ItemTemplate>
                            <asp:LinkButton ID="BtnEdit" runat="server" CausesValidation="False" CommandName="Edit" Text="编辑"
                                Font-Underline="False" style="color:#3b82f6;margin-right:8px;"></asp:LinkButton>
                            <asp:LinkButton ID="BtnToggle" runat="server" CausesValidation="False" CommandName="Toggle"
                                CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="切换"
                                Font-Underline="False" style="color:#f59e0b;margin-right:8px;"></asp:LinkButton>
                            <asp:LinkButton ID="BtnDel" runat="server" CausesValidation="false" CommandName="Del"
                                CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="删除"
                                OnClientClick="return confirm('确定要删除该徽章吗？');" ForeColor="#ef4444"
                                Font-Underline="False"></asp:LinkButton>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:LinkButton ID="BtnUpdate" runat="server" CausesValidation="True" CommandName="Update" Text="保存"
                                Font-Underline="False" style="color:#16a34a;margin-right:8px;"></asp:LinkButton>
                            <asp:LinkButton ID="BtnCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="取消"
                                Font-Underline="False" style="color:#94a3b8;"></asp:LinkButton>
                        </EditItemTemplate>
                        <ItemStyle Width="130px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle Height="30px" />
                <RowStyle Height="40px" />
                <EmptyDataRowStyle HorizontalAlign="Center" Height="80px" ForeColor="#94a3b8" />
            </asp:GridView>
        </div>

        <div class="bs-add-area">
            <h4 style="font-size:14px;font-weight:600;color:#334155;margin:0 0 16px;">添加新徽章</h4>
            <div class="bs-add-grid">
                <div class="bs-form-group">
                    <label>徽章名称 *</label>
                    <asp:TextBox ID="TxtName" runat="server" MaxLength="100" placeholder="如：编程之星" />
                </div>
                <div class="bs-form-group">
                    <label>类别</label>
                    <asp:DropDownList ID="DDLCategory" runat="server" />
                </div>
                <div class="bs-form-group">
                    <label>积分值</label>
                    <asp:TextBox ID="TxtPoints" runat="server" MaxLength="10" placeholder="如：10" />
                </div>
                <div class="bs-upload-group">
                    <label style="font-size:12px;font-weight:600;color:#64748b;">图标</label>
                    <div class="bs-upload-area">
                        <div class="bs-upload-area-inner">
                            <div class="bs-upload-icon">
                                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            </div>
                            <div class="bs-upload-info">
                                <div class="bs-upload-info-title">选择图标文件上传</div>
                                <div class="bs-upload-hint">支持 png / jpg / gif / svg / webp 格式</div>
                                <div style="margin-top:8px;">
                                    <asp:FileUpload ID="FileUploadIcon" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="bs-or-divider">
                        <span class="bs-or-text">或手动输入图标地址</span>
                    </div>
                    <asp:TextBox ID="TxtIcon" runat="server" MaxLength="500" placeholder="如：../images/badges/star.png" />
                </div>
            </div>
            <div class="bs-form-group" style="margin-bottom:16px;">
                <label>描述（可选）</label>
                <asp:TextBox ID="TxtDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="简要描述该徽章的含义" />
            </div>
            <asp:Button ID="BtnAdd" runat="server" Text="添 加 徽 章" OnClick="BtnAdd_Click" CssClass="bs-btn bs-btn-primary" />
        </div>
    </div>
</div>
</asp:Content>
