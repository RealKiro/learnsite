<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_createroom, LearnSite" %>

<script runat="server">
    // ─── 获取连接字符串 ───
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type t = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (t != null)
            {
                System.Reflection.FieldInfo f = t.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString; } catch { } }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        return cs;
    }

    private bool TableExists(System.Data.SqlClient.SqlConnection conn, string table)
    {
        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@T", conn))
        { cmd.Parameters.AddWithValue("@T", table); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
    }

    private bool ColumnExists(System.Data.SqlClient.SqlConnection conn, string table, string col)
    {
        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@T AND COLUMN_NAME=@C", conn))
        { cmd.Parameters.AddWithValue("@T", table); cmd.Parameters.AddWithValue("@C", col); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
    }

    // ─── 确保 Room 表有 SchoolId 列 ───
    private void EnsureSchoolIdColumn()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                if (!ColumnExists(conn, "Room", "SchoolId"))
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "ALTER TABLE Room ADD SchoolId INT NULL DEFAULT 0", conn))
                    { cmd.ExecuteNonQuery(); }
                }
            }
        }
        catch { }
    }

    // ─── 加载学校下拉 ───
    private void LoadSchoolDropdown()
    {
        DDLSchool.Items.Clear();
        DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem("── 全部学校/校区 ──", "0"));
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                if (!TableExists(conn, "School")) return;
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId", conn))
                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem(
                            reader["SchoolName"].ToString(), reader["SchoolId"].ToString()));
                }
            }
        }
        catch { }
    }

    // ─── Page_Load（覆盖基类）───
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            for (int i = 1; i <= 30; i++)
                DDLclassmax.Items.Add(new System.Web.UI.WebControls.ListItem(i.ToString(), i.ToString()));
            if (DDLclassmax.Items.Count >= 8) DDLclassmax.SelectedIndex = 7;
            EnsureSchoolIdColumn();
            LoadSchoolDropdown();
        }
        BindRoomGrid();
    }

    private int SelectedSchoolId
    { get { int v; int.TryParse(DDLSchool.SelectedValue, out v); return v; } }

    // ─── 绑定班级列表（支持学校筛选）───
    private void BindRoomGrid()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int sid = SelectedSchoolId;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                bool hasSchool = TableExists(conn, "School") && ColumnExists(conn, "Room", "SchoolId");
                string sql;
                if (hasSchool && sid > 0)
                    sql = @"SELECT r.Rid, ISNULL(s.SchoolName,N'未指定') AS SchoolName,
                            ISNULL(t.Hname,N'未分配') AS TeacherName, r.Rgrade, r.Rclass
                            FROM Room r LEFT JOIN Teacher t ON r.Rhid=t.Hid
                            LEFT JOIN School s ON r.SchoolId=s.SchoolId
                            WHERE r.SchoolId=@S ORDER BY r.Rgrade, r.Rclass";
                else if (hasSchool)
                    sql = @"SELECT r.Rid, ISNULL(s.SchoolName,N'未指定') AS SchoolName,
                            ISNULL(t.Hname,N'未分配') AS TeacherName, r.Rgrade, r.Rclass
                            FROM Room r LEFT JOIN Teacher t ON r.Rhid=t.Hid
                            LEFT JOIN School s ON r.SchoolId=s.SchoolId
                            ORDER BY ISNULL(r.SchoolId,0), r.Rgrade, r.Rclass";
                else
                    sql = @"SELECT r.Rid, N'—' AS SchoolName,
                            ISNULL(t.Hname,N'未分配') AS TeacherName, r.Rgrade, r.Rclass
                            FROM Room r LEFT JOIN Teacher t ON r.Rhid=t.Hid
                            ORDER BY r.Rgrade, r.Rclass";

                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    if (hasSchool && sid > 0) cmd.Parameters.AddWithValue("@S", sid);
                    System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable();
                    da.Fill(dt);
                    GVclass.DataSource = dt;
                    GVclass.DataBind();
                }
            }
        }
        catch (Exception ex) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "加载失败：" + ex.Message; }
    }

    // ─── 学校切换 ───
    protected void DDLSchool_SelectedIndexChanged(object sender, EventArgs e)
    {
        GVclass.PageIndex = 0;
        BindRoomGrid();
    }

    // ─── 批量创建（带学校）───
    protected void BatchCreateWithSchool_Click(object sender, EventArgs e)
    {
        int sid = SelectedSchoolId;
        if (sid <= 0) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "请先选择一个具体的学校/校区！"; return; }
        int gMin = int.Parse(DDLgrademin.SelectedValue), gMax = int.Parse(DDLgrademax.SelectedValue);
        int cMax = int.Parse(DDLclassmax.SelectedValue);
        if (gMin > gMax) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "最低年级不能大于最高年级！"; return; }

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int created = 0, skipped = 0;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                for (int g = gMin; g <= gMax; g++)
                {
                    for (int c = 1; c <= cMax; c++)
                    {
                        using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                            "SELECT COUNT(*) FROM Room WHERE Rgrade=@G AND Rclass=@C AND SchoolId=@S", conn))
                        {
                            chk.Parameters.AddWithValue("@G", g);
                            chk.Parameters.AddWithValue("@C", c);
                            chk.Parameters.AddWithValue("@S", sid);
                            if (Convert.ToInt32(chk.ExecuteScalar()) > 0) { skipped++; continue; }
                        }
                        using (System.Data.SqlClient.SqlCommand ins = new System.Data.SqlClient.SqlCommand(
                            "INSERT INTO Room (Rgrade,Rclass,Rhid,SchoolId) VALUES (@G,@C,0,@S)", conn))
                        {
                            ins.Parameters.AddWithValue("@G", g);
                            ins.Parameters.AddWithValue("@C", c);
                            ins.Parameters.AddWithValue("@S", sid);
                            ins.ExecuteNonQuery(); created++;
                        }
                    }
                }
            }
            Labelmsg.ForeColor = System.Drawing.Color.Green;
            string msg = "成功创建 " + created + " 个班级";
            if (skipped > 0) msg += "（跳过 " + skipped + " 个已存在）";
            Labelmsg.Text = msg;
        }
        catch (Exception ex) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "创建失败：" + ex.Message; }
        BindRoomGrid();
    }

    // ─── 手动创建（带学校）───
    protected void SingleCreateWithSchool_Click(object sender, EventArgs e)
    {
        int sid = SelectedSchoolId;
        if (sid <= 0) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "请先选择一个具体的学校/校区！"; return; }
        int grade, cls;
        if (!int.TryParse(TextBoxGrade.Text.Trim(), out grade) || grade <= 0)
        { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "请输入有效的年级数字！"; return; }
        if (!int.TryParse(TextBoxClass.Text.Trim(), out cls) || cls <= 0)
        { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "请输入有效的班级数字！"; return; }

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM Room WHERE Rgrade=@G AND Rclass=@C AND SchoolId=@S", conn))
                {
                    chk.Parameters.AddWithValue("@G", grade);
                    chk.Parameters.AddWithValue("@C", cls);
                    chk.Parameters.AddWithValue("@S", sid);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                    { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "该学校的 " + grade + " 年级 " + cls + " 班已存在！"; return; }
                }
                using (System.Data.SqlClient.SqlCommand ins = new System.Data.SqlClient.SqlCommand(
                    "INSERT INTO Room (Rgrade,Rclass,Rhid,SchoolId) VALUES (@G,@C,0,@S)", conn))
                {
                    ins.Parameters.AddWithValue("@G", grade);
                    ins.Parameters.AddWithValue("@C", cls);
                    ins.Parameters.AddWithValue("@S", sid);
                    ins.ExecuteNonQuery();
                }
            }
            Labelmsg.ForeColor = System.Drawing.Color.Green;
            Labelmsg.Text = "成功添加 " + grade + " 年级 " + cls + " 班！";
        }
        catch (Exception ex) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "添加失败：" + ex.Message; }
        BindRoomGrid();
    }

    // ─── GridView 分页 ───
    protected new void GVclass_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
    {
        GVclass.PageIndex = e.NewPageIndex;
        BindRoomGrid();
    }

    // ─── GridView 行绑定 ───
    protected new void GVclass_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
    {
        if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
            e.Row.Cells[0].Text = (e.Row.RowIndex + 1 + GVclass.PageIndex * GVclass.PageSize).ToString();
    }

    // ─── GridView 行命令（删除）───
    protected new void GVclass_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Del")
        {
            int idx = Convert.ToInt32(e.CommandArgument);
            int rid = Convert.ToInt32(GVclass.DataKeys[idx].Value);
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("DELETE FROM Room WHERE Rid=@Rid", conn))
                    { cmd.Parameters.AddWithValue("@Rid", rid); cmd.ExecuteNonQuery(); }
                }
                Labelmsg.ForeColor = System.Drawing.Color.Green; Labelmsg.Text = "删除成功！";
            }
            catch (Exception ex) { Labelmsg.ForeColor = System.Drawing.Color.Red; Labelmsg.Text = "删除失败：" + ex.Message; }
            BindRoomGrid();
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cr-page { max-width: 100%; padding: 28px 32px 40px; font-family: 'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .cr-header { display:flex; align-items:center; gap:16px; margin-bottom:24px; }
    .cr-header-icon { width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,0.25);flex-shrink:0; }
    .cr-header-icon svg { width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round; }
    .cr-header-text h1 { font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px; }
    .cr-header-text p { font-size:13px;color:#94a3b8;margin:0; }

    .cr-grid { display:grid; grid-template-columns:1fr 1fr; gap:20px; }
    .cr-full { grid-column:1/-1; }
    @media(max-width:860px){ .cr-grid{grid-template-columns:1fr;} }

    .cr-card { background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,0.04);overflow:hidden;transition:box-shadow .25s,transform .25s; }
    .cr-card:hover { box-shadow:0 8px 24px rgba(0,0,0,0.07);transform:translateY(-2px); }
    .cr-card-hd { padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px; }
    .cr-card-hd .ci { width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0; }
    .cr-card-hd .ci svg { width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none; }
    .ci.purple { background:#eef2ff; } .ci.purple svg { stroke:#6366f1; }
    .ci.emerald { background:#ecfdf5; } .ci.emerald svg { stroke:#10b981; }
    .ci.sky { background:#f0f9ff; } .ci.sky svg { stroke:#0ea5e9; }
    .ci.amber { background:#fffbeb; } .ci.amber svg { stroke:#f59e0b; }
    .cr-card-bd { padding:18px 22px; }

    .cr-school-select select { min-width:220px; font-size:14px!important; font-weight:500; }
    .cr-school-hint { font-size:12px; color:#94a3b8; margin-left:8px; }

    /* Form row */
    .cr-row { display:flex;align-items:center;gap:12px;padding:10px 0;flex-wrap:wrap;font-size:13.5px; }
    .cr-lbl { font-weight:500;color:#475569;font-size:13px;white-space:nowrap; }
    .cr-sep { color:#cbd5e1;font-size:13px; }

    /* Controls */
    .cr-card select { height:36px;padding:0 30px 0 12px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;background:#f8fafc;outline:none;cursor:pointer;transition:border-color .2s,box-shadow .2s;-webkit-appearance:none;appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 10px center; }
    .cr-card select:focus { border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,0.08);background-color:#fff; }
    .cr-card input[type="text"] { height:36px;padding:0 12px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13.5px;font-family:inherit;outline:none;background:#f8fafc;transition:border-color .2s,box-shadow .2s;width:60px;text-align:center; }
    .cr-card input[type="text"]:focus { border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,0.08);background:#fff; }

    .btn-primary { display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,0.3);letter-spacing:.3px; }
    .btn-primary:hover { box-shadow:0 4px 14px rgba(99,102,241,0.4);transform:translateY(-1px); }
    .btn-primary:active { transform:translateY(0); }
    .btn-emerald { display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(16,185,129,0.3); }
    .btn-emerald:hover { box-shadow:0 4px 14px rgba(16,185,129,0.4);transform:translateY(-1px); }

    /* GridView table */
    .cr-table-wrap { margin-top:16px;border-radius:10px;overflow:hidden;border:1px solid #e2e8f0; }
    .cr-table-wrap table { width:100%;border-collapse:collapse;font-size:13px; }
    .cr-table-wrap th { background:#f8fafc;color:#475569;font-weight:600;padding:10px 16px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0; }
    .cr-table-wrap td { padding:10px 16px;color:#334155;border-bottom:1px solid #f1f5f9; }
    .cr-table-wrap tr:last-child td { border-bottom:none; }
    .cr-table-wrap tr:hover td { background:#f8fafc; }
    .cr-table-wrap tr.alt td { background:#fafbfc; }
    .cr-table-wrap a { color:#6366f1;text-decoration:none;font-weight:500;padding:4px 12px;border-radius:6px;transition:all .15s; }
    .cr-table-wrap a:hover { background:#eef2ff;color:#4f46e5; }
    .cr-table-wrap input[type="submit"] { background:#fef2f2;color:#ef4444;border:1px solid #fecaca;border-radius:6px;padding:4px 14px;font-size:12px;cursor:pointer;transition:all .15s;font-family:inherit; }
    .cr-table-wrap input[type="submit"]:hover { background:#fee2e2;border-color:#fca5a5;color:#dc2626; }
    /* Pager */
    .cr-table-wrap .pager-row { background:#f8fafc;padding:10px 16px;font-size:12.5px;color:#64748b; }
    .cr-table-wrap .pager-row a { color:#6366f1;margin:0 4px;padding:4px 10px;border-radius:6px; }
    .cr-table-wrap .pager-row a:hover { background:#eef2ff; }

    .cr-msg { text-align:center;padding:10px;font-size:13px;margin-top:12px; }
</style>

<div class="cr-page">
    <div class="cr-header">
        <div class="cr-header-icon">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        </div>
        <div class="cr-header-text">
            <h1>班级设置</h1>
            <p>选择学校/校区后，批量创建或单独添加班级</p>
        </div>
    </div>

    <div class="cr-grid">

    <!-- 学校/校区选择 -->
    <div class="cr-card cr-full">
        <div class="cr-card-hd">
            <span class="ci amber"><svg viewBox="0 0 24 24"><path d="M3 21h18"/><path d="M5 21V7l8-4v18"/><path d="M19 21V11l-6-4"/><path d="M9 9v.01"/><path d="M9 12v.01"/><path d="M9 15v.01"/><path d="M9 18v.01"/></svg></span>
            选择学校/校区
        </div>
        <div class="cr-card-bd cr-school-select">
            <div class="cr-row">
                <span class="cr-lbl">学校/校区</span>
                <asp:DropDownList ID="DDLSchool" runat="server" AutoPostBack="True"
                    OnSelectedIndexChanged="DDLSchool_SelectedIndexChanged" />
                <span class="cr-school-hint">创建班级前请先选择具体学校</span>
            </div>
        </div>
    </div>

    <!-- 批量创建 -->
    <div class="cr-card">
        <div class="cr-card-hd">
            <span class="ci purple"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></span>
            批量创建班级
        </div>
        <div class="cr-card-bd">
            <div class="cr-row">
                <span class="cr-lbl">年级范围</span>
                <asp:DropDownList ID="DDLgrademin" runat="server" Font-Size="9pt" Width="56px">
                    <asp:ListItem>1</asp:ListItem><asp:ListItem>2</asp:ListItem><asp:ListItem>3</asp:ListItem>
                    <asp:ListItem>4</asp:ListItem><asp:ListItem>5</asp:ListItem><asp:ListItem>6</asp:ListItem>
                    <asp:ListItem Selected="True">7</asp:ListItem><asp:ListItem>8</asp:ListItem><asp:ListItem>9</asp:ListItem>
                    <asp:ListItem>10</asp:ListItem><asp:ListItem>11</asp:ListItem><asp:ListItem>12</asp:ListItem>
                    <asp:ListItem>13</asp:ListItem><asp:ListItem>14</asp:ListItem><asp:ListItem>15</asp:ListItem><asp:ListItem>16</asp:ListItem>
                </asp:DropDownList>
                <span class="cr-sep">—</span>
                <asp:DropDownList ID="DDLgrademax" runat="server" Font-Size="9pt" Width="56px">
                    <asp:ListItem>1</asp:ListItem><asp:ListItem>2</asp:ListItem><asp:ListItem>3</asp:ListItem>
                    <asp:ListItem>4</asp:ListItem><asp:ListItem>5</asp:ListItem><asp:ListItem>6</asp:ListItem>
                    <asp:ListItem>7</asp:ListItem><asp:ListItem>8</asp:ListItem><asp:ListItem Selected="True">9</asp:ListItem>
                    <asp:ListItem>10</asp:ListItem><asp:ListItem>11</asp:ListItem><asp:ListItem>12</asp:ListItem>
                    <asp:ListItem>13</asp:ListItem><asp:ListItem>14</asp:ListItem><asp:ListItem>15</asp:ListItem><asp:ListItem>16</asp:ListItem>
                </asp:DropDownList>
                <span class="cr-lbl">年级</span>
            </div>
            <div class="cr-row">
                <span class="cr-lbl">每级班数</span>
                <asp:DropDownList ID="DDLclassmax" runat="server" Font-Size="11pt" Width="56px"></asp:DropDownList>
            </div>
            <div class="cr-row" style="padding-top:16px;">
                <asp:Button ID="Btncreate" runat="server" Text="批量创建" CssClass="btn-primary" onclick="BatchCreateWithSchool_Click" />
            </div>
        </div>
    </div>

    <!-- 手动添加 -->
    <div class="cr-card">
        <div class="cr-card-hd">
            <span class="ci emerald"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg></span>
            手动添加班级
        </div>
        <div class="cr-card-bd">
            <div class="cr-row">
                <span class="cr-lbl">年级</span>
                <asp:TextBox ID="TextBoxGrade" runat="server" Width="60px"></asp:TextBox>
            </div>
            <div class="cr-row">
                <span class="cr-lbl">班级</span>
                <asp:TextBox ID="TextBoxClass" runat="server" Width="60px"></asp:TextBox>
            </div>
            <div class="cr-row" style="padding-top:16px;">
                <asp:Button ID="BtncreateOne" runat="server" Text="添加该班级" CssClass="btn-emerald" onclick="SingleCreateWithSchool_Click" />
            </div>
        </div>
    </div>

    <!-- 班级列表 -->
    <div class="cr-card cr-full">
        <div class="cr-card-hd">
            <span class="ci sky"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
            班级列表
        </div>
        <div class="cr-card-bd" style="padding:0;">
            <div class="cr-table-wrap">
                <asp:GridView ID="GVclass" runat="server" AllowPaging="True" 
                    AutoGenerateColumns="False" CellPadding="0" GridLines="None" Width="100%" 
                    onpageindexchanging="GVclass_PageIndexChanging" 
                    onrowdatabound="GVclass_RowDataBound" PageSize="15" DataKeyNames="Rid" 
                    onrowcommand="GVclass_RowCommand" EnableModelValidation="True"
                    BorderWidth="0" BorderStyle="None" Font-Size="13px">
                    <Columns>
                        <asp:BoundField HeaderText="序号" />
                        <asp:BoundField DataField="SchoolName" HeaderText="学校/校区" />
                        <asp:BoundField DataField="TeacherName" HeaderText="教师" />
                        <asp:BoundField DataField="Rgrade" HeaderText="年级" />
                        <asp:BoundField DataField="Rclass" HeaderText="班级" />
                        <asp:ButtonField CommandName="Del" HeaderText="操作" Text="删除" />
                    </Columns>
                    <pagertemplate>
                        <div class="pager-row">
                            第<asp:Label ID="lblPageIndex" runat="server" 
                                text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1  %>" />页
                            / 共<asp:Label ID="lblPageCount" runat="server" 
                                text="<%# ((GridView)Container.Parent.Parent).PageCount  %>" />页
                            &nbsp;&nbsp;
                            <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False" 
                                commandargument="First" commandname="Page" text="首页" />
                            <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False" 
                                commandargument="Prev" commandname="Page" text="上一页" />
                            <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False" 
                                commandargument="Next" commandname="Page" text="下一页" />
                            <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False" 
                                commandargument="Last" commandname="Page" text="尾页" />
                        </div>
                    </pagertemplate>
                    <HeaderStyle CssClass="" />
                    <RowStyle CssClass="" />
                    <AlternatingRowStyle CssClass="alt" />
                    <PagerStyle CssClass="" />
                </asp:GridView>
            </div>
        </div>
    </div>

    </div><!-- /cr-grid -->

    <div class="cr-msg">
        <asp:Label ID="Labelmsg" runat="server" ForeColor="Red"></asp:Label>
    </div>
</div>
</asp:Content>

