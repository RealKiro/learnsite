<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected System.Data.DataTable dtStudents = null;
    protected string pageMsg = "";
    protected int selGrade = 0;
    protected int selClass = 0;

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
            LoadGrades();
            LoadBadges();
        }
    }

    private void LoadBadges()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                DDLBadge.Items.Clear();
                DDLBadge.Items.Add(new System.Web.UI.WebControls.ListItem("--选择徽章--", "0"));
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Bid,Bname,Bpoints FROM Badge WHERE ISNULL(Bactive,1)=1 ORDER BY Bsort,Bid", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string text = r["Bname"].ToString() + " (" + r["Bpoints"] + "分)";
                            DDLBadge.Items.Add(new System.Web.UI.WebControls.ListItem(text, r["Bid"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }
    }

    private void LoadGrades()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade>0 ORDER BY Sgrade", conn))
                {
                    DDLGrade.Items.Clear();
                    DDLGrade.Items.Add(new System.Web.UI.WebControls.ListItem("--年级--", "0"));
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    { while (r.Read()) { DDLGrade.Items.Add(new System.Web.UI.WebControls.ListItem(r.GetInt32(0) + "年级", r.GetInt32(0).ToString())); } }
                }
            }
        }
        catch { }
    }

    protected void DDLGrade_Changed(object sender, EventArgs e)
    {
        int grade = 0; int.TryParse(DDLGrade.SelectedValue, out grade);
        DDLClass.Items.Clear();
        DDLClass.Items.Add(new System.Web.UI.WebControls.ListItem("--班级--", "0"));
        if (grade <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=@g AND Sclass>0 ORDER BY Sclass", conn))
                {
                    cmd.Parameters.AddWithValue("@g", grade);
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    { while (r.Read()) { DDLClass.Items.Add(new System.Web.UI.WebControls.ListItem(r.GetInt32(0) + "班", r.GetInt32(0).ToString())); } }
                }
            }
        }
        catch { }
    }

    protected void BtnQuery_Click(object sender, EventArgs e)
    {
        int grade = 0; int.TryParse(DDLGrade.SelectedValue, out grade);
        int cls = 0; int.TryParse(DDLClass.SelectedValue, out cls);
        selGrade = grade; selClass = cls;
        if (grade <= 0 || cls <= 0) { pageMsg = "请选择年级和班级"; return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(
                    "SELECT Sid,Snum,Sname FROM Students WHERE Sgrade=@g AND Sclass=@c ORDER BY Snum,Sname", conn);
                da.SelectCommand.Parameters.AddWithValue("@g", grade);
                da.SelectCommand.Parameters.AddWithValue("@c", cls);
                dtStudents = new System.Data.DataTable();
                da.Fill(dtStudents);
            }
        }
        catch { }
    }

    protected void BtnAward_Click(object sender, EventArgs e)
    {
        int badgeId = 0; int.TryParse(DDLBadge.SelectedValue, out badgeId);
        if (badgeId <= 0) { pageMsg = "请选择徽章"; BtnQuery_Click(sender, e); return; }
        string reason = TxtReason.Text.Trim();
        int grade = 0; int.TryParse(DDLGrade.SelectedValue, out grade);
        int cls = 0; int.TryParse(DDLClass.SelectedValue, out cls);

        // Collect checked student IDs
        System.Collections.Generic.List<int> sids = new System.Collections.Generic.List<int>();
        string selectedSids = HiddenSelectedSids.Value;
        if (!string.IsNullOrEmpty(selectedSids))
        {
            foreach (string s in selectedSids.Split(','))
            {
                int sid = 0; if (int.TryParse(s.Trim(), out sid) && sid > 0) sids.Add(sid);
            }
        }
        if (sids.Count == 0) { pageMsg = "请勾选至少一名学生"; BtnQuery_Click(sender, e); return; }

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int count = 0;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                foreach (int sid in sids)
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "INSERT INTO BadgeAward(Abid,Asid,Ahid,Areason,Adate,Agrade,Aclass) VALUES(@bid,@sid,@hid,@reason,GETDATE(),@grade,@class)", conn))
                    {
                        cmd.Parameters.AddWithValue("@bid", badgeId);
                        cmd.Parameters.AddWithValue("@sid", sid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.Parameters.AddWithValue("@reason", reason);
                        cmd.Parameters.AddWithValue("@grade", grade);
                        cmd.Parameters.AddWithValue("@class", cls);
                        cmd.ExecuteNonQuery();
                        count++;
                    }
                }
            }
            pageMsg = "成功颁发给 " + count + " 名学生";
        }
        catch (Exception ex) { pageMsg = "颁发失败: " + ex.Message; }
        BtnQuery_Click(sender, e);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .ba-page { max-width: 1600px; width: 100%; margin: 0 auto; }
    .ba-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .ba-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .ba-title .ba-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#10b981,#34d399); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .ba-title .ba-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ba-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .ba-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden; }
    .ba-card-head { padding: 16px 24px; border-bottom: 1px solid #f1f5f9; background: #fafbfc; font-size: 15px; font-weight: 600; color: #334155; }
    .ba-toolbar { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; padding: 16px 24px; background: #fafbfc; border-bottom: 1px solid #f1f5f9; }
    .ba-toolbar label { font-size: 13px; color: #64748b; font-weight: 500; }
    .ba-toolbar select, .ba-toolbar input { padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; }
    .ba-toolbar select:focus, .ba-toolbar input:focus { border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,.1); }
    .ba-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; font-family: inherit; }
    .ba-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .ba-btn-primary { background: linear-gradient(135deg,#10b981,#34d399); color: #fff; border-color: #10b981; box-shadow: 0 2px 8px rgba(16,185,129,.2); }
    .ba-btn-primary:hover { background: linear-gradient(135deg,#059669,#10b981); }
    .ba-table { width: 100%; border-collapse: collapse; }
    .ba-table th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 12px; padding: 12px 16px; border-bottom: 2px solid #e8ecf1; text-align: left; }
    .ba-table td { padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155; }
    .ba-table tr:hover td { background: #ecfdf5; }
    .ba-table tr:last-child td { border-bottom: none; }
    .ba-table input[type="checkbox"] { width: 16px; height: 16px; accent-color: #10b981; cursor: pointer; }
    .ba-msg { padding: 10px 16px; border-radius: 8px; background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; font-size: 13px; margin-bottom: 16px; }
    .ba-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
    .ba-award-bar { padding: 16px 24px; background: #f0fdf4; border-top: 1px solid #a7f3d0; display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
    .ba-award-bar label { font-size: 13px; color: #065f46; font-weight: 500; }
    .ba-award-bar select, .ba-award-bar input { padding: 8px 14px; border-radius: 8px; border: 1px solid #a7f3d0; font-size: 13px; color: #334155; background: #fff; outline: none; }
</style>

<div class="ba-page">
    <div class="ba-header">
        <div>
            <div class="ba-title">
                <span class="ba-icon"><svg viewBox="0 0 24 24"><path d="M12 15l-3.5 2 .67-3.89L6 10.11l3.94-.57L12 6l2.06 3.54 3.94.57-3.17 3L16.5 17z"/><path d="M5 21h14"/></svg></span>
                徽章颁发
            </div>
            <div class="ba-subtitle">选择班级和学生，颁发荣誉徽章</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="ba-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <div class="ba-card">
        <div class="ba-toolbar">
            <label>年级：</label>
            <asp:DropDownList ID="DDLGrade" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DDLGrade_Changed" />
            <label>班级：</label>
            <asp:DropDownList ID="DDLClass" runat="server" />
            <asp:Button ID="BtnQuery" runat="server" Text="查询学生" OnClick="BtnQuery_Click" CssClass="ba-btn ba-btn-primary" />
        </div>

        <div style="padding:0;">
            <% if (dtStudents != null && dtStudents.Rows.Count > 0) { %>
            <table class="ba-table">
                <thead><tr><th style="width:40px;"><input type="checkbox" id="chkAll" onclick="toggleAll(this)" /></th><th>学号</th><th>姓名</th></tr></thead>
                <tbody>
                <% foreach (System.Data.DataRow row in dtStudents.Rows) {
                    int sid = Convert.ToInt32(row["Sid"]);
                    string snum = row["Snum"] == DBNull.Value ? "" : row["Snum"].ToString();
                    string sname = row["Sname"] == DBNull.Value ? "" : row["Sname"].ToString();
                %>
                <tr>
                    <td><input type="checkbox" class="stu-chk" value="<%= sid %>" /></td>
                    <td><%= Server.HtmlEncode(snum) %></td>
                    <td><%= Server.HtmlEncode(sname) %></td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <div class="ba-award-bar">
                <label>选择徽章：</label>
                <asp:DropDownList ID="DDLBadge" runat="server" />
                <label>颁发原因（可选）：</label>
                <asp:TextBox ID="TxtReason" runat="server" MaxLength="200" placeholder="如：编程比赛优秀" style="width:200px;" />
                <asp:HiddenField ID="HiddenSelectedSids" runat="server" />
                <asp:Button ID="BtnAward" runat="server" Text="颁 发 徽 章" OnClick="BtnAward_Click" CssClass="ba-btn ba-btn-primary"
                    OnClientClick="collectChecked(); return true;" />
            </div>
            <% } else if (IsPostBack) { %>
            <div class="ba-empty">未找到学生，请选择年级和班级后查询</div>
            <% } else { %>
            <div class="ba-empty">请选择年级和班级后点击「查询学生」</div>
            <% } %>
        </div>
    </div>
</div>

<script type="text/javascript">
    function toggleAll(el) {
        var chks = document.querySelectorAll('.stu-chk');
        for (var i = 0; i < chks.length; i++) chks[i].checked = el.checked;
    }
    function collectChecked() {
        var chks = document.querySelectorAll('.stu-chk:checked');
        var ids = [];
        for (var i = 0; i < chks.length; i++) ids.push(chks[i].value);
        document.getElementById('<%= HiddenSelectedSids.ClientID %>').value = ids.join(',');
    }
</script>
</asp:Content>
