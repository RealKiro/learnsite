<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "";
    protected string catJson = "[]";

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
            EnsureTable();
            EnsureColumn();
            EnsureCategoryTable();
            EnsureTcatColumn();
            BindGrid();
        }
        catJson = GetCategoriesJson();
    }

    private void EnsureColumn()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AttitudeType' AND COLUMN_NAME='Tcolor'", conn))
                {
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                    {
                        using (System.Data.SqlClient.SqlCommand add = new System.Data.SqlClient.SqlCommand(
                            "ALTER TABLE AttitudeType ADD Tcolor nvarchar(20) NOT NULL DEFAULT('#6366f1')", conn))
                        { add.ExecuteNonQuery(); }
                    }
                }
            }
        }
        catch { }
    }

    private void EnsureCategoryTable()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='AttitudeCategory' AND xtype='U'", conn))
                { if (Convert.ToInt32(chk.ExecuteScalar()) > 0) return; }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "CREATE TABLE [dbo].[AttitudeCategory]([CatId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY," +
                    "[CatName] NVARCHAR(50) NOT NULL,[CatSort] INT NOT NULL DEFAULT(0)," +
                    "[CatColor] NVARCHAR(20) NOT NULL DEFAULT('#6366f1'))", conn))
                { cmd.ExecuteNonQuery(); }
            }
        }
        catch { }
    }

    private void EnsureTcatColumn()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AttitudeType' AND COLUMN_NAME='Tcatid'", conn))
                {
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                    {
                        using (System.Data.SqlClient.SqlCommand add = new System.Data.SqlClient.SqlCommand(
                            "ALTER TABLE AttitudeType ADD Tcatid INT NULL", conn))
                        { add.ExecuteNonQuery(); }
                    }
                }
            }
        }
        catch { }
    }

    private string JsStr(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
    }

    protected string GetCategoriesJson()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return "[]";
        System.Text.StringBuilder sb = new System.Text.StringBuilder("[");
        bool first = true;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='AttitudeCategory' AND xtype='U'", conn))
                { if (Convert.ToInt32(chk.ExecuteScalar()) == 0) return "[]"; }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT CatId,CatName,ISNULL(CatColor,'#6366f1') FROM AttitudeCategory ORDER BY CatSort,CatId", conn))
                using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        if (!first) sb.Append(",");
                        sb.Append("{\"id\":" + r[0] + ",\"name\":\"" + JsStr(r[1].ToString()) + "\",\"color\":\"" + JsStr(r[2].ToString()) + "\"}");
                        first = false;
                    }
                }
            }
        }
        catch { }
        sb.Append("]");
        return sb.ToString();
    }

    protected string RenderCatTag(object catName, object catColor)
    {
        string name = catName != null ? catName.ToString() : "";
        string color = catColor != null ? catColor.ToString() : "";
        if (string.IsNullOrEmpty(name)) return "<span class='cat-tag-empty'>\u65e0</span>";
        string safeColor = System.Text.RegularExpressions.Regex.Replace(color, "[^#a-zA-Z0-9]", "");
        return "<span class='cat-tag' style='background:" + safeColor + "20;color:" + safeColor + ";border:1px solid " + safeColor + "50;'>" + Server.HtmlEncode(name) + "</span>";
    }

    private void EnsureTable()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='AttitudeType' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists > 0) return;
                }
                string createSql = @"CREATE TABLE [dbo].[AttitudeType](
                    [Tid] [int] IDENTITY(1,1) NOT NULL,
                    [Tname] [nvarchar](50) NULL,
                    [Tscore] [int] NULL DEFAULT(0),
                    [Tsort] [int] NULL DEFAULT(0),
                    [Tactive] [bit] NULL DEFAULT(1),
                    [Tcolor] [nvarchar](20) NOT NULL DEFAULT('#6366f1'),
                    [Tdate] [datetime] NULL,
                    PRIMARY KEY CLUSTERED ([Tid] ASC))";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(createSql, conn))
                { cmd.ExecuteNonQuery(); }
                string[] names = { "乐于助人", "表现优秀", "有开小差", "乱扔垃圾", "上课迟到", "损坏公物" };
                int[] scores = { 2, 1, -1, -2, -3, -4 };
                string[] colors = { "#10b981", "#6366f1", "#f59e0b", "#f97316", "#ef4444", "#dc2626" };
                for (int i = 0; i < names.Length; i++)
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tcolor,Tdate) VALUES(@name,@score,@sort,1,@color,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@name", names[i]);
                        cmd.Parameters.AddWithValue("@score", scores[i]);
                        cmd.Parameters.AddWithValue("@sort", i + 1);
                        cmd.Parameters.AddWithValue("@color", colors[i]);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
        }
        catch { }
    }

    private void BindGrid()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                bool hasCatId = false, hasCatTable = false;
                using (System.Data.SqlClient.SqlCommand c = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AttitudeType' AND COLUMN_NAME='Tcatid'", conn))
                { hasCatId = Convert.ToInt32(c.ExecuteScalar()) > 0; }
                using (System.Data.SqlClient.SqlCommand c = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='AttitudeCategory' AND xtype='U'", conn))
                { hasCatTable = Convert.ToInt32(c.ExecuteScalar()) > 0; }
                string sql = (hasCatId && hasCatTable)
                    ? @"SELECT at.Tid, at.Tname, at.Tscore, at.Tsort, at.Tactive,
                        ISNULL(at.Tcolor,'#6366f1') AS Tcolor,
                        ISNULL(at.Tcatid,0) AS Tcatid,
                        ISNULL(ac.CatName,'') AS CatName,
                        ISNULL(ac.CatColor,'') AS CatColor
                        FROM AttitudeType at
                        LEFT JOIN AttitudeCategory ac ON at.Tcatid=ac.CatId
                        ORDER BY at.Tsort, at.Tid"
                    : "SELECT Tid,Tname,Tscore,Tsort,Tactive,ISNULL(Tcolor,'#6366f1') AS Tcolor," +
                      "0 AS Tcatid,'' AS CatName,'' AS CatColor FROM AttitudeType ORDER BY Tsort,Tid";
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(sql, conn);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                GVTypes.DataSource = dt;
                GVTypes.DataBind();
            }
        }
        catch { }
    }

    protected void BtnAdd_Click(object sender, EventArgs e)
    {
        string name = TxtName.Text.Trim();
        if (string.IsNullOrEmpty(name)) { pageMsg = "请输入评分类型名称"; pageMsgType = "error"; BindGrid(); return; }
        int score = 0; int.TryParse(TxtScore.Text.Trim(), out score);
        string color = HidColorNew.Value.Trim();
        if (string.IsNullOrEmpty(color) || !color.StartsWith("#")) color = "#6366f1";
        if (color.Length > 20) color = color.Substring(0, 20);
        int catId = 0; int.TryParse(HidCatNew.Value, out catId);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                int maxSort = 0;
                using (System.Data.SqlClient.SqlCommand cmdMax = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(MAX(Tsort),0) FROM AttitudeType", conn))
                { object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }
                bool hasCatCol = false;
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AttitudeType' AND COLUMN_NAME='Tcatid'", conn))
                { hasCatCol = Convert.ToInt32(chk.ExecuteScalar()) > 0; }
                string insertSql = hasCatCol
                    ? "INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tcolor,Tdate,Tcatid) VALUES(@name,@score,@sort,1,@color,GETDATE(),@catid)"
                    : "INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tcolor,Tdate) VALUES(@name,@score,@sort,1,@color,GETDATE())";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(insertSql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@score", score);
                    cmd.Parameters.AddWithValue("@sort", maxSort + 1);
                    cmd.Parameters.AddWithValue("@color", color);
                    if (hasCatCol) cmd.Parameters.AddWithValue("@catid", catId > 0 ? (object)catId : DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
            TxtName.Text = ""; TxtScore.Text = ""; HidCatNew.Value = "";
            pageMsg = "添加成功"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "添加失败: " + ex.Message; pageMsgType = "error"; }
        BindGrid();
    }

    protected void GVTypes_RowEditing(object sender, System.Web.UI.WebControls.GridViewEditEventArgs e)
    { GVTypes.EditIndex = e.NewEditIndex; BindGrid(); }

    protected void GVTypes_RowCancelingEdit(object sender, System.Web.UI.WebControls.GridViewCancelEditEventArgs e)
    { GVTypes.EditIndex = -1; BindGrid(); }

    protected void GVTypes_RowUpdating(object sender, System.Web.UI.WebControls.GridViewUpdateEventArgs e)
    {
        int tid = Convert.ToInt32(GVTypes.DataKeys[e.RowIndex].Value);
        System.Web.UI.WebControls.GridViewRow row = GVTypes.Rows[e.RowIndex];
        string newName = ((System.Web.UI.WebControls.TextBox)row.FindControl("TBoxName")).Text.Trim();
        int newScore = 0;
        int.TryParse(((System.Web.UI.WebControls.TextBox)row.FindControl("TBoxScore")).Text.Trim(), out newScore);
        string newColor = "#6366f1";
        System.Web.UI.WebControls.TextBox colorBox = row.FindControl("TBoxColor") as System.Web.UI.WebControls.TextBox;
        if (colorBox != null && !string.IsNullOrEmpty(colorBox.Text) && colorBox.Text.Trim().StartsWith("#"))
            newColor = colorBox.Text.Trim();
        int newCatId = 0;
        System.Web.UI.WebControls.DropDownList ddlCat = row.FindControl("DdlCatEdit") as System.Web.UI.WebControls.DropDownList;
        if (ddlCat != null && !string.IsNullOrEmpty(ddlCat.SelectedValue)) int.TryParse(ddlCat.SelectedValue, out newCatId);

        if (string.IsNullOrEmpty(newName)) { pageMsg = "名称不能为空"; pageMsgType = "error"; return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                bool hasCatCol = false;
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AttitudeType' AND COLUMN_NAME='Tcatid'", conn))
                { hasCatCol = Convert.ToInt32(chk.ExecuteScalar()) > 0; }
                string updSql = hasCatCol
                    ? "UPDATE AttitudeType SET Tname=@name,Tscore=@score,Tcolor=@color,Tcatid=@catid WHERE Tid=@tid"
                    : "UPDATE AttitudeType SET Tname=@name,Tscore=@score,Tcolor=@color WHERE Tid=@tid";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(updSql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", newName);
                    cmd.Parameters.AddWithValue("@score", newScore);
                    cmd.Parameters.AddWithValue("@color", newColor);
                    if (hasCatCol) cmd.Parameters.AddWithValue("@catid", newCatId > 0 ? (object)newCatId : DBNull.Value);
                    cmd.Parameters.AddWithValue("@tid", tid);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "更新成功"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "更新失败: " + ex.Message; pageMsgType = "error"; }
        GVTypes.EditIndex = -1;
        BindGrid();
    }

    protected void GVTypes_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        int rowIndex = 0;
        if (!int.TryParse(e.CommandArgument.ToString(), out rowIndex)) return;
        int tid = Convert.ToInt32(GVTypes.DataKeys[rowIndex].Value);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;

        if (e.CommandName == "Del")
        {
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "DELETE FROM AttitudeType WHERE Tid=@tid", conn))
                    { cmd.Parameters.AddWithValue("@tid", tid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "已删除"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; pageMsgType = "error"; }
            BindGrid();
        }
        else if (e.CommandName == "Toggle")
        {
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "UPDATE AttitudeType SET Tactive=CASE WHEN ISNULL(Tactive,1)=1 THEN 0 ELSE 1 END WHERE Tid=@tid", conn))
                    { cmd.Parameters.AddWithValue("@tid", tid); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
            BindGrid();
        }
        else if (e.CommandName == "Up" || e.CommandName == "Down")
        {
            SwapSort(rowIndex, e.CommandName == "Up" ? -1 : 1);
            BindGrid();
        }
    }

    protected void GVTypes_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
    {
        if (e.Row.RowType != System.Web.UI.WebControls.DataControlRowType.DataRow) return;
        System.Data.DataRowView drv = e.Row.DataItem as System.Data.DataRowView;
        if (drv != null)
        {
            string catId = (drv["Tcatid"] == null || drv["Tcatid"] == DBNull.Value) ? "0" : drv["Tcatid"].ToString();
            e.Row.Attributes["data-catid"] = catId;
        }
        if ((e.Row.RowState & System.Web.UI.WebControls.DataControlRowState.Edit) != 0)
        {
            System.Web.UI.WebControls.DropDownList ddl = e.Row.FindControl("DdlCatEdit") as System.Web.UI.WebControls.DropDownList;
            if (ddl != null)
            {
                ddl.Items.Add(new System.Web.UI.WebControls.ListItem("\u65e0", "0"));
                string cs = GetConnStr();
                if (!string.IsNullOrEmpty(cs))
                {
                    try
                    {
                        using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                        {
                            conn.Open();
                            bool tableExists = false;
                            using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                                "SELECT COUNT(*) FROM sysobjects WHERE name='AttitudeCategory' AND xtype='U'", conn))
                            { tableExists = Convert.ToInt32(chk.ExecuteScalar()) > 0; }
                            if (tableExists)
                            {
                                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                                    "SELECT CatId,CatName FROM AttitudeCategory ORDER BY CatSort,CatId", conn))
                                using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                                {
                                    while (r.Read())
                                        ddl.Items.Add(new System.Web.UI.WebControls.ListItem(r[1].ToString(), r[0].ToString()));
                                }
                            }
                        }
                    }
                    catch { }
                }
                if (drv != null && drv["Tcatid"] != null && drv["Tcatid"] != DBNull.Value && drv["Tcatid"].ToString() != "0")
                {
                    System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(drv["Tcatid"].ToString());
                    if (li != null) li.Selected = true;
                }
            }
        }
    }

    private void SwapSort(int rowIndex, int direction)
    {
        int targetIndex = rowIndex + direction;
        if (targetIndex < 0 || targetIndex >= GVTypes.Rows.Count) return;
        int tid1 = Convert.ToInt32(GVTypes.DataKeys[rowIndex].Value);
        int tid2 = Convert.ToInt32(GVTypes.DataKeys[targetIndex].Value);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                int sort1 = 0, sort2 = 0;
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT ISNULL(Tsort,0) FROM AttitudeType WHERE Tid=@tid", conn))
                { cmd.Parameters.AddWithValue("@tid", tid1); object v = cmd.ExecuteScalar(); if (v != null && v != DBNull.Value) sort1 = Convert.ToInt32(v); }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT ISNULL(Tsort,0) FROM AttitudeType WHERE Tid=@tid", conn))
                { cmd.Parameters.AddWithValue("@tid", tid2); object v = cmd.ExecuteScalar(); if (v != null && v != DBNull.Value) sort2 = Convert.ToInt32(v); }
                if (sort1 == sort2) sort2 = sort1 + direction;
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("UPDATE AttitudeType SET Tsort=@s WHERE Tid=@tid", conn))
                { cmd.Parameters.AddWithValue("@s", sort2); cmd.Parameters.AddWithValue("@tid", tid1); cmd.ExecuteNonQuery(); }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("UPDATE AttitudeType SET Tsort=@s WHERE Tid=@tid", conn))
                { cmd.Parameters.AddWithValue("@s", sort1); cmd.Parameters.AddWithValue("@tid", tid2); cmd.ExecuteNonQuery(); }
            }
        }
        catch { }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
    
    @keyframes slideIn { from { opacity:0; transform:translateY(20px); } to { opacity:1; transform:translateY(0); } }
    @keyframes pulse-soft { 0%,100%{ box-shadow:0 0 0 0 rgba(99,102,241,.15); } 50%{ box-shadow:0 0 0 6px rgba(99,102,241,0); } }
    
    body { background-color: #f8fafc; font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }

    .at-page { 
        max-width: 1400px; width: 96%; margin: 40px auto; padding: 0; 
        display: grid; grid-template-columns: 1fr; gap: 32px;
    }

    /* === Header Section === */
    .at-header-wrap {
        background: linear-gradient(120deg, #4f46e5 0%, #7c3aed 100%);
        border-radius: 24px; padding: 40px;
        position: relative; overflow: hidden;
        box-shadow: 0 20px 40px -12px rgba(79, 70, 229, 0.3);
        display: flex; justify-content: space-between; align-items: center;
    }
    .at-header-wrap::before {
        content: ''; position: absolute; top: -50%; left: -10%;
        width: 400px; height: 400px; border-radius: 50%;
        background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
        pointer-events: none;
    }
    .at-header-wrap::after {
        content: ''; position: absolute; bottom: -30%; right: 5%;
        width: 300px; height: 300px; border-radius: 50%;
        background: radial-gradient(circle, rgba(255,255,255,0.08) 0%, transparent 60%);
        pointer-events: none;
    }
    
    .at-header-content { position: relative; z-index: 2; color: white; }
    .at-title { 
        font-size: 32px; font-weight: 800; margin: 0 0 12px; 
        display: flex; align-items: center; gap: 16px; letter-spacing: -0.5px;
    }
    .at-icon-box {
        width: 56px; height: 56px; background: rgba(255,255,255,0.2);
        backdrop-filter: blur(12px); border-radius: 16px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        border: 1px solid rgba(255,255,255,0.1);
    }
    .at-icon-box svg { width: 30px; height: 30px; stroke: #fff; stroke-width: 2.5; fill: none; }
    
    .at-subtitle { font-size: 15px; opacity: 0.9; max-width: 500px; line-height: 1.6; font-weight: 400; }

    /* === Main Content Grid === */
    .at-main-layout {
        display: grid; grid-template-columns: 2fr 1fr; gap: 32px;
        align-items: start;
    }

    /* === List Card Style === */
    .at-list-section {
        background: white; border-radius: 24px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02), 0 10px 15px -3px rgba(0,0,0,0.03);
        padding: 8px; border: 1px solid #f1f5f9;
        overflow-x: auto; overflow-y: visible;
    }
    .at-list-section table { min-width: 680px; }

    /* GridView Table Styling */
    .at-list-section table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
    .at-list-section table thead { display: none; }
    .at-list-section table tr:has(th) { display: none !important; }
    
    .at-list-section table tr {
        background: #fff; transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
    }
    
    /* Row Card Effect */
    .at-list-section table tr td {
        padding: 12px 8px; border: none;
        border-top: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
        white-space: nowrap;
    }
    .at-list-section table tr td:first-child { 
        border-left: 1px solid #f1f5f9; border-top-left-radius: 16px; border-bottom-left-radius: 16px; padding-left: 16px; 
    }
    .at-list-section table tr td:last-child { 
        border-right: 1px solid #f1f5f9; border-top-right-radius: 16px; border-bottom-right-radius: 16px; padding-right: 16px; 
    }

    /* Hover Effect */
    .at-list-section table tr:hover td {
        background: #f8fafc; border-color: #e2e8f0;
    }
    .at-list-section table tr:hover {
        transform: scale(1.01); 
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
        z-index: 10;
    }

    /* Columns Specifics */
    .col-id { font-weight: 700; color: #cbd5e1; font-size: 14px; width: 40px; }
    .col-name { font-size: 16px; font-weight: 600; color: #1e293b; }
    .col-score { width: 80px; text-align: center; }
    .col-status { width: 80px; text-align: center; }
    .col-sort { width: 60px; text-align: center; }
    .col-action { text-align: right; width: 160px; }

    /* Tags & Badges */
    .tag-score {
        display: inline-flex; width: 36px; height: 36px; border-radius: 10px;
        align-items: center; justify-content: center;
        font-weight: 700; font-size: 14px;
    }
    .tag-score.pos { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .tag-score.neg { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
    .tag-score.zero { background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }

    .tag-status {
        font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 20px;
        display: inline-flex; align-items: center; gap: 6px;
    }
    .tag-status.active { background: #f0fdf4; color: #15803d; border: 1px solid #dcfce7; }
    .tag-status.active::before { content:''; width:6px; height:6px; background:#22c55e; border-radius:50%; }
    .tag-status.inactive { background: #fef2f2; color: #b91c1c; border: 1px solid #fee2e2; }

    /* Color picker */
    .cp-wrap { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
    .cp-presets { display:flex; gap:6px; flex-wrap:wrap; }
    .cp-swatch {
        width:26px; height:26px; border-radius:8px; cursor:pointer;
        border:2px solid transparent; transition:all .15s; display:inline-block;
        box-shadow:0 1px 4px rgba(0,0,0,0.12);
    }
    .cp-swatch:hover { transform:scale(1.15); border-color:rgba(0,0,0,0.2); }
    .cp-swatch.active { border-color:#1e293b; transform:scale(1.1); box-shadow:0 2px 8px rgba(0,0,0,0.2); }
    .col-color { text-align:center; }
    .color-swatch-dot {
        width:28px; height:28px; border-radius:8px; display:inline-block;
        border:2px solid rgba(0,0,0,0.08); box-shadow:0 1px 4px rgba(0,0,0,0.1);
    }

    /* Buttons */
    .btn-icon {
        width: 32px; height: 32px; border-radius: 8px; 
        display: inline-flex; align-items: center; justify-content: center;
        transition: all 0.2s; color: #64748b; background: transparent;
    }
    .btn-icon:hover { background: #e2e8f0; color: #334155; }
    
    .action-group { display: flex; gap: 6px; justify-content: flex-end; flex-wrap: nowrap; }
    .btn-action {
        padding: 5px 10px; border-radius: 8px; font-size: 12px; font-weight: 600;
        text-decoration: none; transition: all 0.2s; white-space: nowrap;
    }
    .btn-edit { background: #eff6ff; color: #3b82f6; }
    .btn-edit:hover { background: #3b82f6; color: white; }
    .btn-toggle { background: #fff7ed; color: #f97316; }
    .btn-toggle:hover { background: #f97316; color: white; }
    .btn-del { background: #fef2f2; color: #ef4444; }
    .btn-del:hover { background: #ef4444; color: white; }

    /* === Add Form Panel === */
    .at-panel {
        background: white; border-radius: 24px; padding: 32px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02), 0 10px 15px -3px rgba(0,0,0,0.03);
        border: 1px solid #f1f5f9; position: sticky; top: 20px;
    }
    .panel-title { 
        font-size: 18px; font-weight: 700; color: #0f172a; margin-bottom: 24px; 
        display: flex; align-items: center; gap: 10px;
    }
    .panel-title svg { width: 20px; height: 20px; stroke: #6366f1; stroke-width: 2.5; }

    .form-field { margin-bottom: 20px; }
    .form-label { display: block; font-size: 13px; font-weight: 600; color: #64748b; margin-bottom: 8px; }
    .form-input {
        width: 100%; padding: 12px 16px; border-radius: 12px;
        border: 2px solid #e2e8f0; background: #f8fafc;
        font-size: 14px; color: #334155; transition: all 0.2s;
        box-sizing: border-box; outline: none;
    }
    .form-input:focus {
        border-color: #6366f1; background: white;
        box-shadow: 0 0 0 4px rgba(99,102,241,0.1);
    }
    
    .btn-submit {
        width: 100%; padding: 14px; border-radius: 12px; border: none;
        background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
        color: white; font-weight: 700; font-size: 15px; cursor: pointer;
        transition: all 0.2s; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
    }
    .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(79, 70, 229, 0.4); }

    /* === Hint Box === */
    .hint-box {
        margin-top: 24px; padding: 20px; border-radius: 16px;
        background: #f0fdfa; border: 1px solid #ccfbf1;
        display: flex; gap: 12px; color: #0f766e;
    }
    .hint-box svg { width: 20px; height: 20px; stroke: #14b8a6; flex-shrink: 0; }
    .hint-text { font-size: 13px; line-height: 1.6; }

    /* === Messages === */
    .msg-toast {
        padding: 16px 20px; border-radius: 12px; font-weight: 600; font-size: 14px;
        margin-bottom: 24px; display: flex; align-items: center; gap: 10px;
        animation: slideIn 0.4s ease;
    }
    .msg-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
    .msg-error { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

    /* Responsive */
    @media (max-width: 900px) {
        .at-main-layout { grid-template-columns: 1fr; }
        .at-panel { position: static; }
        .at-header-wrap { flex-direction: column; text-align: center; gap: 20px; }
        .at-title { justify-content: center; }
        .at-subtitle { margin: 0 auto; }
    }

    /* === Category Tags === */
    .cat-tag {
        font-size: 12px; font-weight: 600; padding: 3px 10px; border-radius: 20px;
        display: inline-block; white-space: nowrap;
    }
    .cat-tag-empty { font-size: 12px; color: #94a3b8; }

    /* === Category Filter Tabs === */
    .cat-filter-bar {
        display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 16px; align-items: center;
        min-height: 36px;
    }
    .cat-filter-btn {
        padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 600;
        border: 1.5px solid #e2e8f0; background: #f8fafc; color: #64748b; cursor: pointer;
        transition: all .15s;
    }
    .cat-filter-btn.active, .cat-filter-btn:hover {
        background: #6366f1; color: white; border-color: #6366f1;
    }

    /* === Manage Category Button === */
    .btn-manage-cat {
        padding: 7px 16px; border-radius: 20px; font-size: 13px; font-weight: 600;
        background: #f0f0ff; color: #6366f1; border: 1.5px solid #c7d2fe; cursor: pointer;
        display: inline-flex; align-items: center; gap: 6px; transition: all .15s; flex-shrink: 0;
    }
    .btn-manage-cat:hover { background: #6366f1; color: white; border-color: #6366f1; }

    /* === Category Modal === */
    .cat-modal-overlay {
        display: none; position: fixed;
        top: 0; right: 0; bottom: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.45);
        z-index: 9999; align-items: center; justify-content: center;
    }
    .cat-modal-overlay.open { display: flex; }
    .cat-modal-card {
        background: white; border-radius: 20px; padding: 32px; width: 460px; max-width: 94vw;
        box-shadow: 0 20px 60px rgba(0,0,0,0.2); max-height: 80vh; overflow-y: auto;
    }
    .cat-modal-title {
        font-size: 18px; font-weight: 700; color: #0f172a; margin-bottom: 24px;
        display: flex; align-items: center; justify-content: space-between;
    }
    .cat-modal-close {
        width: 32px; height: 32px; border-radius: 8px; border: none; background: #f1f5f9;
        color: #64748b; cursor: pointer; font-size: 20px; display: flex;
        align-items: center; justify-content: center; line-height: 1;
    }
    .cat-modal-close:hover { background: #e2e8f0; }
    .cat-add-row { display: flex; gap: 8px; margin-bottom: 10px; align-items: center; }
    .cat-add-row .form-input { flex: 1; padding: 10px 14px; border-width: 1.5px; }
    .cat-color-swatches { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 20px; }
    .cat-list-item {
        display: flex; align-items: center; gap: 10px; padding: 10px 12px;
        border-radius: 10px; border: 1px solid #e2e8f0; margin-bottom: 8px; background: #f8fafc;
    }
    .cat-list-item .cat-name-edit {
        flex: 1; border: 1px solid #e2e8f0; border-radius: 8px; padding: 5px 10px;
        font-size: 14px; background: white;
    }
    .cat-list-dot { width: 14px; height: 14px; border-radius: 50%; flex-shrink: 0; }
    .cat-list-actions { display: flex; gap: 6px; }
    .btn-cat-save {
        font-size: 12px; padding: 4px 10px; border-radius: 6px;
        background: #dcfce7; color: #15803d; border: none; cursor: pointer;
    }
    .btn-cat-del {
        font-size: 12px; padding: 4px 10px; border-radius: 6px;
        background: #fee2e2; color: #b91c1c; border: none; cursor: pointer;
    }
    .cat-form-select {
        width: 100%; padding: 10px 14px; border-radius: 12px;
        border: 2px solid #e2e8f0; background: #f8fafc; font-size: 14px; color: #334155;
        box-sizing: border-box; outline: none; transition: all 0.2s;
    }
    .cat-form-select:focus { border-color: #6366f1; background: white; }
</style>

<div class="at-page">
    <div class="at-header-wrap">
        <div class="at-header-content">
            <h1 class="at-title">
                <div class="at-icon-box">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </div>
                评分管理
            </h1>
            <p class="at-subtitle">自定义课堂评分体系，设置正面奖励与负面扣分，激励学生积极表现。</p>
        </div>
        <div style="display:flex;align-items:flex-start;padding-top:8px;">
            <button type="button" class="btn-manage-cat" onclick="openCatModal()">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                分类管理
            </button>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
        <div class="msg-toast <%= pageMsgType == "success" ? "msg-success" : "msg-error" %>">
            <% if (pageMsgType == "success") { %>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <% } else { %>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <% } %>
            <%= Server.HtmlEncode(pageMsg) %>
        </div>
    <% } %>

    <div class="at-main-layout">
        <!-- List Section -->
        <div class="at-list-section">
            <div id="catFilterBar" class="cat-filter-bar"></div>
            <asp:GridView ID="GVTypes" runat="server" AutoGenerateColumns="False"
                DataKeyNames="Tid" Width="100%" GridLines="None"
                OnRowCommand="GVTypes_RowCommand"
                OnRowCancelingEdit="GVTypes_RowCancelingEdit" OnRowEditing="GVTypes_RowEditing"
                OnRowUpdating="GVTypes_RowUpdating" OnRowDataBound="GVTypes_RowDataBound"
                ShowHeaderWhenEmpty="true"
                EmptyDataText="暂无评分类型，请在右侧添加">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="col-id">#<%# Eval("Tid") %></div>
                        </ItemTemplate>
                        <ItemStyle Width="60px" />
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="col-name"><%# Server.HtmlEncode(Eval("Tname").ToString()) %></div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxName" runat="server" Text='<%# Bind("Tname") %>' CssClass="form-input" style="padding:8px; width:100%; border-width:1px;"></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="col-score">
                                <span class='tag-score <%# Convert.ToInt32(Eval("Tscore")) > 0 ? "pos" : (Convert.ToInt32(Eval("Tscore")) < 0 ? "neg" : "zero") %>'>
                                    <%# Convert.ToInt32(Eval("Tscore")) > 0 ? "+" : "" %><%# Eval("Tscore") %>
                                </span>
                            </div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxScore" runat="server" Text='<%# Bind("Tscore") %>' CssClass="form-input" style="padding:8px; width:60px; text-align:center; border-width:1px;"></asp:TextBox>
                        </EditItemTemplate>
                        <ItemStyle Width="100px" HorizontalAlign="Center" />
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="col-color">
                                <div class="color-swatch-dot" style='background:<%# Server.HtmlEncode(Eval("Tcolor").ToString()) %>;'></div>
                            </div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxColor" runat="server" Text='<%# Bind("Tcolor") %>' style="width:76px;border-radius:8px;border:1.5px solid #e2e8f0;padding:6px 8px;font-size:12px;font-family:monospace;" MaxLength="20" />
                        </EditItemTemplate>
                        <ItemStyle Width="56px" HorizontalAlign="Center" />
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <%# RenderCatTag(Eval("CatName"), Eval("CatColor")) %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:DropDownList ID="DdlCatEdit" runat="server" style="padding:5px 8px;border-radius:8px;border:1.5px solid #e2e8f0;font-size:13px;"></asp:DropDownList>
                        </EditItemTemplate>
                        <ItemStyle Width="100px" />
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="col-status">
                                <span class='tag-status <%# Convert.ToBoolean(Eval("Tactive")) ? "active" : "inactive" %>'>
                                    <%# Convert.ToBoolean(Eval("Tactive")) ? "启用" : "停用" %>
                                </span>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="100px" HorizontalAlign="Center" />
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="col-sort">
                                <asp:LinkButton runat="server" CommandName="Up" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' CssClass="btn-icon" ToolTip="上移">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"/></svg>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="Down" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' CssClass="btn-icon" ToolTip="下移">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                        <ItemStyle Width="80px" HorizontalAlign="Center" />
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <div class="action-group">
                                <asp:LinkButton runat="server" CommandName="Edit" Text="编辑" CssClass="btn-action btn-edit"></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="Toggle" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="切换" CssClass="btn-action btn-toggle"></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="Del" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="删除" CssClass="btn-action btn-del" OnClientClick="return confirm('确定要删除吗？');"></asp:LinkButton>
                            </div>
                        </ItemTemplate>
                        <EditItemTemplate>
                             <div class="action-group">
                                <asp:LinkButton runat="server" CommandName="Update" Text="保存" CssClass="btn-action" style="background:#dcfce7; color:#166534;"></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="Cancel" Text="取消" CssClass="btn-action" style="background:#f1f5f9; color:#64748b;"></asp:LinkButton>
                            </div>
                        </EditItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <!-- Right Side Panel -->
        <div class="at-panel">
            <h3 class="panel-title">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加新类型
            </h3>
            
            <div class="form-field">
                <label class="form-label">类型名称</label>
                <asp:TextBox ID="TxtName" runat="server" MaxLength="50" placeholder="例如：回答正确" CssClass="form-input" />
            </div>
            
            <div class="form-field">
                <label class="form-label">对应分值</label>
                <asp:TextBox ID="TxtScore" runat="server" MaxLength="5" placeholder="例如：2 或 -1" CssClass="form-input" />
            </div>

            <div class="form-field">
                <label class="form-label">显示颜色</label>
                <div class="cp-wrap">
                    <input type="color" id="cpNew" value="#6366f1" style="width:48px;height:48px;border-radius:12px;border:2px solid #e2e8f0;cursor:pointer;padding:3px;" oninput="atSetColor(this.value)">
                    <asp:HiddenField ID="HidColorNew" runat="server" Value="#6366f1" />
                    <div class="cp-presets" id="cpPresets"></div>
                </div>
            </div>

            <div class="form-field">
                <label class="form-label">所属分类</label>
                <select id="selCatNew" class="cat-form-select"></select>
                <asp:HiddenField ID="HidCatNew" runat="server" />
            </div>

            <asp:Button ID="BtnAdd" runat="server" Text="立即添加" OnClick="BtnAdd_Click" CssClass="btn-submit" />

            <div class="hint-box">
                <svg viewBox="0 0 24 24" fill="none" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div class="hint-text">
                    正数表示加分（如 2），负数表示扣分（如 -1）。<br>所有类型默认启用。
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Category Management Modal -->
<div id="catModal" class="cat-modal-overlay" onclick="if(event.target===this)closeCatModal()">
    <div class="cat-modal-card">
        <div class="cat-modal-title">
            <span>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-3px;margin-right:6px;"><path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                分类管理
            </span>
            <button class="cat-modal-close" onclick="closeCatModal()">&#215;</button>
        </div>
        <div style="font-size:13px;color:#64748b;margin-bottom:16px;">为评分类型添加分类标签，便于归类筛选。</div>
        <div class="cat-add-row">
            <input type="text" id="inpCatName" class="form-input" placeholder="分类名称（最多50字）" maxlength="50" onkeydown="if(event.key==='Enter')addCat()" />
            <button type="button" class="btn-cat-save" onclick="addCat()" style="padding:8px 18px;font-size:13px;white-space:nowrap;">+ 添加</button>
        </div>
        <div id="catModalSwatches" class="cat-color-swatches"></div>
        <div style="font-size:12px;font-weight:700;color:#64748b;margin-bottom:10px;letter-spacing:.5px;">已有分类</div>
        <div id="catListContainer"></div>
    </div>
</div>

<script type="text/javascript">
var AT_COLORS = ['#6366f1','#8b5cf6','#ec4899','#ef4444','#f97316','#f59e0b','#10b981','#06b6d4','#3b82f6','#64748b'];
var _catNewColor = '#6366f1';
var _activeCatFilter = 0;

/* ---- existing color picker ---- */
function atSetColor(val) {
    var cp = document.getElementById('cpNew');
    var hid = document.getElementById('<%= HidColorNew.ClientID %>');
    if (cp) cp.value = val;
    if (hid) hid.value = val;
    renderPresets(val);
}
function renderPresets(activeColor) {
    var el = document.getElementById('cpPresets');
    if (!el) return;
    el.innerHTML = AT_COLORS.map(function(c) {
        return '<div class="cp-swatch' + (c === activeColor ? ' active' : '') + '" style="background:' + c + ';" onclick="atSetColor(\'' + c + '\')"></div>';
    }).join('');
}

/* ---- modal open/close ---- */
function openCatModal() {
    var m = document.getElementById('catModal');
    if (m.parentNode !== document.body) document.body.appendChild(m);
    m.classList.add('open');
    loadCats();
}
function closeCatModal() {
    document.getElementById('catModal').classList.remove('open');
}

/* ---- modal color swatches ---- */
function renderCatColorSwatches(active) {
    var el = document.getElementById('catModalSwatches');
    if (!el) return;
    el.innerHTML = AT_COLORS.map(function(c) {
        return '<div class="cp-swatch' + (c === active ? ' active' : '') + '" style="background:' + c + ';" onclick="selectCatColor(\'' + c + '\')"></div>';
    }).join('');
}
function selectCatColor(c) {
    _catNewColor = c;
    renderCatColorSwatches(c);
}

/* ---- CRUD helpers ---- */
function _safeJson(r) {
    return r.text().then(function(t) {
        try { return JSON.parse(t); }
        catch(e) { return {success:false, msg:'\u670d\u52a1\u5668\u9519\u8bef (HTTP ' + r.status + ')'}; }
    });
}

/* ---- CRUD ---- */
function loadCats() {
    fetch('attitudecatajax.ashx?action=list', { credentials: 'same-origin' })
        .then(_safeJson)
        .then(function(res) {
            var cats = (res && res.success && Array.isArray(res.data)) ? res.data : [];
            renderCatList(cats);
            renderCatFilterTabs(cats);
            populateCatSelects(cats);
            if (res && !res.success && res.msg) {
                var el = document.getElementById('catListContainer');
                if (el && !cats.length) el.innerHTML = '<div style="color:#ef4444;font-size:13px;text-align:center;padding:12px 0;">' + escHtml(res.msg) + '</div>';
            }
        })
        .catch(function() {});
}

function renderCatList(cats) {
    var el = document.getElementById('catListContainer');
    if (!el) return;
    if (!cats || cats.length === 0) {
        el.innerHTML = '<div style="color:#94a3b8;font-size:13px;text-align:center;padding:20px 0;">暂无分类，请在上方添加</div>';
        return;
    }
    el.innerHTML = cats.map(function(cat) {
        return '<div class="cat-list-item">' +
            '<div class="cat-list-dot" style="background:' + escHtml(cat.color) + ';"></div>' +
            '<input class="cat-name-edit" id="cname_' + cat.id + '" value="' + escHtml(cat.name) + '" maxlength="50" onkeydown="if(event.key===\'Enter\')updCat(' + cat.id + ')" />' +
            '<div class="cat-list-actions">' +
            '<button class="btn-cat-save" onclick="updCat(' + cat.id + ')">保存</button>' +
            '<button class="btn-cat-del" onclick="delCat(' + cat.id + ')">删除</button>' +
            '</div></div>';
    }).join('');
}

function addCat() {
    var name = (document.getElementById('inpCatName').value || '').trim();
    if (!name) { alert('\u8bf7\u8f93\u5165\u5206\u7c7b\u540d\u79f0'); return; }
    var fd = new FormData();
    fd.append('action', 'add');
    fd.append('name', name);
    fd.append('color', _catNewColor);
    fetch('attitudecatajax.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(_safeJson)
        .then(function(res) {
            if (res && res.success) {
                var inp = document.getElementById('inpCatName');
                if (inp) inp.value = '';
                loadCats();
            } else { alert((res && res.msg) || '\u6dfb\u52a0\u5931\u8d25'); }
        }).catch(function(e) { alert('\u6dfb\u52a0\u5931\u8d25\uff0c\u8bf7\u91cd\u8bd5'); });
}

function delCat(id) {
    if (!confirm('\u786e\u5b9a\u5220\u9664\u6b64\u5206\u7c7b\uff1f\u5df2\u4f7f\u7528\u8be5\u5206\u7c7b\u7684\u7c7b\u578b\u5c06\u53d8\u4e3a\u65e0\u5206\u7c7b\u3002')) return;
    var fd = new FormData();
    fd.append('action', 'del');
    fd.append('id', id);
    fetch('attitudecatajax.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(_safeJson)
        .then(function(res) {
            if (res && res.success) { loadCats(); setTimeout(function() { location.reload(); }, 400); }
            else { alert((res && res.msg) || '\u5220\u9664\u5931\u8d25'); }
        }).catch(function(e) { alert('\u5220\u9664\u5931\u8d25\uff0c\u8bf7\u91cd\u8bd5'); });
}

function updCat(id) {
    var nameEl = document.getElementById('cname_' + id);
    if (!nameEl) return;
    var name = nameEl.value.trim();
    if (!name) { alert('\u540d\u79f0\u4e0d\u80fd\u4e3a\u7a7a'); return; }
    var fd = new FormData();
    fd.append('action', 'upd');
    fd.append('id', id);
    fd.append('name', name);
    fetch('attitudecatajax.ashx', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(_safeJson)
        .then(function(res) {
            if (res && res.success) { loadCats(); }
            else { alert((res && res.msg) || '\u66f4\u65b0\u5931\u8d25'); }
        }).catch(function(e) { alert('\u66f4\u65b0\u5931\u8d25\uff0c\u8bf7\u91cd\u8bd5'); });
}

/* ---- filter tabs ---- */
function renderCatFilterTabs(cats) {
    var bar = document.getElementById('catFilterBar');
    if (!bar) return;
    var html = '<button class="cat-filter-btn' + (_activeCatFilter === 0 ? ' active' : '') + '" data-fid="0" onclick="filterByCat(0)">全部</button>';
    if (cats && cats.length) {
        cats.forEach(function(c) {
            html += '<button class="cat-filter-btn' + (_activeCatFilter === c.id ? ' active' : '') + '" data-fid="' + c.id + '" onclick="filterByCat(' + c.id + ')" style="border-color:' + c.color + '50;">' +
                '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:' + c.color + ';margin-right:5px;vertical-align:middle;"></span>' +
                escHtml(c.name) + '</button>';
        });
    }
    bar.innerHTML = html;
}

function filterByCat(catId) {
    _activeCatFilter = catId;
    var gv = document.getElementById('<%= GVTypes.ClientID %>');
    if (gv) {
        var rows = gv.querySelectorAll('tr[data-catid]');
        rows.forEach(function(r) {
            r.style.display = (catId === 0 || r.getAttribute('data-catid') === String(catId)) ? '' : 'none';
        });
    }
    var bar = document.getElementById('catFilterBar');
    if (bar) {
        bar.querySelectorAll('.cat-filter-btn').forEach(function(b) {
            b.classList.toggle('active', b.getAttribute('data-fid') === String(catId));
        });
    }
}

/* ---- populate add-form select ---- */
function populateCatSelects(cats) {
    var sel = document.getElementById('selCatNew');
    var hid = document.getElementById('<%= HidCatNew.ClientID %>');
    if (!sel) return;
    var current = sel.value || (hid ? hid.value : '0');
    sel.innerHTML = '<option value="0">\u65e0\u5206\u7c7b</option>';
    if (cats && cats.length) {
        cats.forEach(function(c) {
            var opt = document.createElement('option');
            opt.value = c.id;
            opt.textContent = c.name;
            sel.appendChild(opt);
        });
    }
    if (current) sel.value = current;
    if (hid) {
        hid.value = sel.value;
        sel.onchange = function() { hid.value = sel.value; };
    }
}

function escHtml(s) {
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

document.addEventListener('DOMContentLoaded', function() {
    var hid = document.getElementById('<%= HidColorNew.ClientID %>');
    renderPresets(hid ? hid.value : '#6366f1');
    renderCatColorSwatches(_catNewColor);
    loadCats();
});
</script>
</asp:Content>
