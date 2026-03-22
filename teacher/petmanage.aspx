<%@ page title="宠物管理" language="C#" masterpagefile="~/teacher/Teach.master"
    autoeventwireup="true" inherits="System.Web.UI.Page" enableeventvalidation="false" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected DataTable _classes = new DataTable();
    protected int _teacherId = 0;
    protected string _schoolsJson = "[]";

    private string JsEsc(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"");
    }

    private string GetConnStr()
    {
        System.Configuration.ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["constr"];
        if (cfg == null) cfg = ConfigurationManager.ConnectionStrings["SqlServer"];
        return cfg != null ? cfg.ConnectionString : null;
    }

    private static readonly System.Reflection.BindingFlags _rf =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    private object DecodeCookie(string typeName, string val)
    {
        System.Type t = typeof(LearnSite.Common.CookieHelp).Assembly.GetType(typeName);
        if (t == null) return null;
        object obj = Activator.CreateInstance(t);
        System.Reflection.MethodInfo mi = t.GetMethod("ToModel", _rf);
        if (mi != null) mi.Invoke(obj, new object[] { val });
        return obj;
    }

    private string GetProp(object m, string p)
    {
        if (m == null) return "";
        System.Reflection.PropertyInfo pi = m.GetType().GetProperty(p);
        if (pi == null) return "";
        object v = pi.GetValue(m, null);
        return v != null ? v.ToString() : "";
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                object model = DecodeCookie("LearnSite.Model.TeaCook", tc.Value);
                int.TryParse(GetProp(model, "Hid"), out _teacherId);
            }
        }
        catch { }
        LoadSchools();   // 与 start.aspx 相同的校区源
        LoadClasses();
    }

    // 加载校区列表（与 start.aspx 完全相同：School 表 → Students.Scampus 备用）
    private void LoadSchools()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        System.Text.StringBuilder sb = new System.Text.StringBuilder("[");
        bool first = true;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 检查 School 表是否存在
                bool hasSchoolTable = false;
                try
                {
                    object v = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='School'", conn).ExecuteScalar();
                    hasSchoolTable = (v != null && Convert.ToInt32(v) > 0);
                }
                catch { }

                if (hasSchoolTable)
                {
                    // 与 start.aspx 一致：读 School 表
                    SqlCommand cmd = new SqlCommand(
                        "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId", conn);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            if (!first) sb.Append(",");
                            sb.Append("{\"id\":\"" + JsEsc(dr["SchoolId"].ToString()) +
                                      "\",\"name\":\"" + JsEsc(dr["SchoolName"].ToString()) + "\"}");
                            first = false;
                        }
                    }
                }
                else
                {
                    // 第二优先：Campus 表（与 roomselect.aspx 保持一致）
                    bool hasCampusTable = false;
                    try
                    {
                        object v2 = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Campus'", conn).ExecuteScalar();
                        hasCampusTable = (v2 != null && Convert.ToInt32(v2) > 0);
                    }
                    catch { }

                    if (hasCampusTable)
                    {
                        SqlCommand cmd = new SqlCommand(
                            "SELECT Cid, Cname FROM Campus WHERE Cdelete=0 OR Cdelete IS NULL ORDER BY Cid", conn);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                if (!first) sb.Append(",");
                                sb.Append("{\"id\":\"" + JsEsc(dr["Cid"].ToString()) +
                                          "\",\"name\":\"" + JsEsc(dr["Cname"].ToString()) + "\"}");
                                first = false;
                            }
                        }
                    }
                    else
                    {
                        // 最后备用：Students.Scampus
                        bool hasStu = false;
                        try
                        {
                            object v3 = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Students'", conn).ExecuteScalar();
                            hasStu = (v3 != null && Convert.ToInt32(v3) > 0);
                        }
                        catch { }
                        if (hasStu)
                        {
                            SqlCommand cmd = new SqlCommand(
                                "SELECT DISTINCT Scampus FROM Students WHERE Scampus IS NOT NULL AND Scampus<>'' ORDER BY Scampus", conn);
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                while (dr.Read())
                                {
                                    if (!first) sb.Append(",");
                                    string campus = JsEsc(dr["Scampus"].ToString());
                                    sb.Append("{\"id\":\"" + campus + "\",\"name\":\"" + campus + "\"}");
                                    first = false;
                                }
                            }
                        }
                    }
                }
            }
        }
        catch { }
        sb.Append("]");
        _schoolsJson = sb.ToString();
    }

    private void LoadClasses()
    {
        _classes.Columns.Add("Rid",      typeof(int));
        _classes.Columns.Add("Name",     typeof(string));
        _classes.Columns.Add("Grade",    typeof(string));
        _classes.Columns.Add("SchoolId", typeof(string));  // "0" = 无学校, "1"/"2"... = 有效学校
        if (_teacherId <= 0) return;
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 与 roomselect.aspx FilterClassesByCampus 保持一致：
                // 优先 Room.SchoolId，若为 0/NULL 则回退 Teacher.SchoolId
                bool roomHasSchoolId = false, teacherHasSchoolId = false;
                string chkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@T AND COLUMN_NAME='SchoolId'";
                try
                {
                    using (SqlCommand c = new SqlCommand(chkSql, conn)) { c.Parameters.AddWithValue("@T", "Room");    roomHasSchoolId    = Convert.ToInt32(c.ExecuteScalar()) > 0; }
                    using (SqlCommand c = new SqlCommand(chkSql, conn)) { c.Parameters.AddWithValue("@T", "Teacher"); teacherHasSchoolId = Convert.ToInt32(c.ExecuteScalar()) > 0; }
                }
                catch { }

                string sql;
                if (roomHasSchoolId && teacherHasSchoolId)
                    // 与 roomselect.aspx 完全相同的 COALESCE 逻辑
                    sql = "SELECT r.Rid, r.Rgrade, r.Rclass, CAST(COALESCE(NULLIF(r.SchoolId,0), t.SchoolId, 0) AS VARCHAR(50)) AS SchoolId " +
                          "FROM Room r LEFT JOIN Teacher t ON r.Rhid=t.Hid WHERE r.Rhid=@Hid ORDER BY r.Rgrade, r.Rclass";
                else if (roomHasSchoolId)
                    sql = "SELECT Rid, Rgrade, Rclass, CAST(ISNULL(SchoolId,0) AS VARCHAR(50)) AS SchoolId FROM Room WHERE Rhid=@Hid ORDER BY Rgrade, Rclass";
                else if (teacherHasSchoolId)
                    sql = "SELECT r.Rid, r.Rgrade, r.Rclass, CAST(ISNULL(t.SchoolId,0) AS VARCHAR(50)) AS SchoolId " +
                          "FROM Room r LEFT JOIN Teacher t ON r.Rhid=t.Hid WHERE r.Rhid=@Hid ORDER BY r.Rgrade, r.Rclass";
                else
                    sql = "SELECT Rid, Rgrade, Rclass, '0' AS SchoolId FROM Room WHERE Rhid=@Hid ORDER BY Rgrade, Rclass";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Hid", _teacherId);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string grade    = reader["Rgrade"].ToString();
                        string cls      = reader["Rclass"].ToString();
                        string schoolId = reader["SchoolId"].ToString();
                        DataRow row = _classes.NewRow();
                        row["Rid"]      = reader["Rid"];
                        row["Name"]     = grade + "年级" + cls + "班";
                        row["Grade"]    = grade;
                        row["SchoolId"] = schoolId;
                        _classes.Rows.Add(row);
                    }
                }
            }
        }
        catch { }
    }

    // classList JSON：grade/schoolId 均为引号字符串
    protected string GetClassesJson()
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder("[");
        bool first = true;
        foreach (DataRow row in _classes.Rows)
        {
            if (!first) sb.Append(",");
            sb.Append("{\"id\":"     + row["Rid"] +
                      ",\"name\":\""    + JsEsc(row["Name"].ToString())     + "\"" +
                      ",\"grade\":\""   + JsEsc(row["Grade"].ToString())    + "\"" +
                      ",\"schoolId\":\"" + JsEsc(row["SchoolId"].ToString()) + "\"}");
            first = false;
        }
        sb.Append("]");
        return sb.ToString();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
.pm { max-width: 1400px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

/* ---- 页头 ---- */
.pm-hd { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.pm-hd-left { display: flex; align-items: center; gap: 16px; }
.pm-hd-icon { width: 52px; height: 52px; background: linear-gradient(135deg,#ec4899,#f472b6); border-radius: 14px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(236,72,153,.25); flex-shrink: 0; }
.pm-hd-icon svg { width: 28px; height: 28px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.pm-hd-text h1 { font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 3px; }
.pm-hd-text p { font-size: 13px; color: #94a3b8; margin: 0; }
.pm-hd-stats { display: flex; gap: 16px; flex-wrap: wrap; }
.pm-hd-stat { text-align: center; }
.pm-hd-stat .val { font-size: 20px; font-weight: 700; color: #1e293b; }
.pm-hd-stat .lbl { font-size: 11px; color: #94a3b8; }

/* ---- 标签页 ---- */
.pm-tabs { display: flex; gap: 4px; background: #f1f5f9; border-radius: 12px; padding: 5px; margin-bottom: 24px; overflow-x: auto; }
.pm-tab { flex: none; padding: 9px 16px; border-radius: 8px; border: none; background: transparent; font-size: 13px; font-weight: 500; color: #64748b; cursor: pointer; transition: all .18s; white-space: nowrap; display: flex; align-items: center; gap: 6px; font-family: inherit; }
.pm-tab svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.pm-tab.active { background: #fff; color: #4f46e5; box-shadow: 0 1px 4px rgba(0,0,0,.08); font-weight: 600; }
.pm-panel { display: none; }
.pm-panel.active { display: block; }

/* ---- 宠物卡片 ---- */
.pet-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(270px, 1fr)); gap: 16px; margin-bottom: 24px; }
.pet-card { background: #fff; border-radius: 16px; border: 1px solid #e8ecf1; padding: 20px; position: relative; overflow: hidden; transition: all .2s; box-shadow: 0 2px 8px rgba(0,0,0,.04); }
.pet-card:hover { box-shadow: 0 6px 24px rgba(0,0,0,.09); transform: translateY(-2px); }
.pet-card-bg { position: absolute; top: -30px; right: -30px; width: 110px; height: 110px; border-radius: 50%; opacity: .07; }
.pet-level { position: absolute; top: 14px; right: 14px; background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff; font-size: 11px; font-weight: 700; padding: 3px 9px; border-radius: 20px; }
.pet-header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
.pet-emoji { width: 56px; height: 56px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 30px; flex-shrink: 0; }
.pet-info .pet-name { font-size: 15px; font-weight: 700; color: #1e293b; }
.pet-info .pet-class { font-size: 12px; color: #94a3b8; margin-top: 2px; }
.pet-info .pet-state { font-size: 12px; margin-top: 4px; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
.pet-info .pet-state svg { flex-shrink: 0; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.pet-state.happy { color: #10b981; }
.pet-state.neutral { color: #f59e0b; }
.pet-state.sad { color: #ef4444; }

/* stat bars */
.pet-stats { display: flex; flex-direction: column; gap: 7px; margin-bottom: 16px; }
.stat-row { display: flex; align-items: center; gap: 7px; }
.stat-lbl { font-size: 11px; color: #64748b; width: 28px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; }
.stat-lbl svg { flex-shrink: 0; overflow: visible; }
.stat-track { flex: 1; height: 6px; background: #f1f5f9; border-radius: 3px; overflow: hidden; }
.stat-fill { height: 100%; border-radius: 3px; transition: width .6s ease; }
.stat-fill.hp  { background: linear-gradient(90deg,#10b981,#34d399); }
.stat-fill.mood { background: linear-gradient(90deg,#6366f1,#818cf8); }
.stat-fill.food { background: linear-gradient(90deg,#f59e0b,#fbbf24); }
.stat-fill.clean { background: linear-gradient(90deg,#06b6d4,#22d3ee); }
.stat-val { font-size: 11px; font-weight: 600; color: #334155; width: 26px; text-align: right; }

/* pet card buttons */
.pet-actions { display: flex; gap: 6px; }
.pet-btn { flex: 1; padding: 7px 4px; border-radius: 8px; border: 1.5px solid #e2e8f0; background: #fff; font-size: 12px; font-weight: 500; color: #475569; cursor: pointer; transition: all .15s; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; gap: 5px; }
.pet-btn svg { width: 13px; height: 13px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
.pet-btn:hover { border-color: #818cf8; color: #4f46e5; background: #f5f3ff; }
.pet-btn.prim { background: linear-gradient(135deg,#6366f1,#818cf8); border-color: transparent; color: #fff; }
.pet-btn.prim:hover { box-shadow: 0 3px 10px rgba(99,102,241,.35); }
.pet-btn.pink { background: linear-gradient(135deg,#ec4899,#f472b6); border-color: transparent; color: #fff; }
.pet-btn.pink:hover { box-shadow: 0 3px 10px rgba(236,72,153,.35); }

/* ---- 通用卡片 ---- */
.sec { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 2px 8px rgba(0,0,0,.03); margin-bottom: 20px; overflow: hidden; }
.sec-hd { padding: 16px 20px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between; background: #fafbfc; }
.sec-title { font-size: 14px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
.sec-title svg { width: 17px; height: 17px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.sec-body { padding: 20px; }
.sec-desc { font-size: 13px; color: #64748b; margin-bottom: 16px; line-height: 1.6; }

/* ---- 表格 ---- */
.pm-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.pm-table th { background: #f8fafc; color: #475569; font-weight: 600; padding: 10px 14px; text-align: left; font-size: 12px; border-bottom: 1px solid #e2e8f0; white-space: nowrap; }
.pm-table td { padding: 10px 14px; color: #334155; border-bottom: 1px solid #f8fafc; vertical-align: middle; }
.pm-table tr:last-child td { border-bottom: none; }
.pm-table tr:hover td { background: #f8fafc; }

/* ---- 标签 ---- */
.tag { display: inline-block; padding: 3px 9px; border-radius: 6px; font-size: 11px; font-weight: 500; }
.tag-red { background: #fef2f2; color: #dc2626; }
.tag-green { background: #f0fdf4; color: #16a34a; }
.tag-blue { background: #eff6ff; color: #2563eb; }
.tag-amber { background: #fffbeb; color: #d97706; }
.tag-purple { background: #f5f3ff; color: #7c3aed; }
.tag-pink { background: #fdf2f8; color: #be185d; }

/* ---- 表单 ---- */
.pm-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px; }
.pm-form-row.c3 { grid-template-columns: 1fr 1fr 1fr; }
.pm-form-row.c1 { grid-template-columns: 1fr; }
.pm-form-row.c4 { grid-template-columns: 1fr 1fr 1fr 1fr; }
.fg label { display: block; font-size: 12px; font-weight: 600; color: #374151; margin-bottom: 6px; }
.pm-input, .pm-select, .pm-textarea {
    width: 100%; padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px;
    font-size: 13px; color: #334155; font-family: inherit; transition: all .2s; box-sizing: border-box; background: #fff;
}
.pm-input:focus, .pm-select:focus, .pm-textarea:focus {
    outline: none; border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1);
}
.pm-textarea { resize: vertical; min-height: 80px; }

/* ---- 按钮 ---- */
.pm-btn { display: inline-flex; align-items: center; gap: 6px; padding: 9px 18px; border-radius: 8px; font-size: 13px; font-weight: 500; font-family: inherit; cursor: pointer; transition: all .2s; border: none; }
.pm-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; flex-shrink: 0; }
.pm-btn-primary { background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff; box-shadow: 0 2px 6px rgba(99,102,241,.3); }
.pm-btn-primary:hover { box-shadow: 0 4px 12px rgba(99,102,241,.4); transform: translateY(-1px); }
.pm-btn-outline { background: #fff; color: #475569; border: 1.5px solid #e2e8f0; }
.pm-btn-outline:hover { border-color: #818cf8; color: #4f46e5; }
.pm-btn-danger { background: #fff; color: #dc2626; border: 1.5px solid #fecaca; }
.pm-btn-danger:hover { background: #fef2f2; }
.pm-btn-success { background: linear-gradient(135deg,#10b981,#34d399); color: #fff; box-shadow: 0 2px 6px rgba(16,185,129,.25); }
.pm-btn-success:hover { box-shadow: 0 4px 12px rgba(16,185,129,.35); transform: translateY(-1px); }
.pm-btn-pink { background: linear-gradient(135deg,#ec4899,#f472b6); color: #fff; box-shadow: 0 2px 6px rgba(236,72,153,.25); }
.pm-btn-pink:hover { box-shadow: 0 4px 12px rgba(236,72,153,.35); transform: translateY(-1px); }
.pm-btn-sm { padding: 6px 12px; font-size: 12px; }

/* ---- 开关 ---- */
.tog {
    position: relative;
    display: inline-block;
    width: 58px;
    height: 32px;
    cursor: pointer;
    vertical-align: middle;
}
.tog input {
    position: absolute;
    opacity: 0;
    width: 0;
    height: 0;
}
.tog-s {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    border-radius: 999px;
    border: 1px solid #dbe2ea;
    background: linear-gradient(180deg, #f8fafc 0%, #e5ebf3 100%);
    box-shadow: inset 0 2px 5px rgba(15,23,42,.08), 0 6px 16px rgba(148,163,184,.14);
    transition: background .22s ease, border-color .22s ease, box-shadow .22s ease, transform .22s ease;
}
.tog-s::before {
    content: '';
    position: absolute;
    top: 4px;
    left: 4px;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
    box-shadow: 0 4px 10px rgba(15,23,42,.18);
    transition: transform .22s ease, box-shadow .22s ease;
}
.tog-s::after {
    content: '';
    position: absolute;
    top: 50%;
    right: 11px;
    width: 6px;
    height: 6px;
    margin-top: -3px;
    border-radius: 50%;
    background: #cbd5e1;
    box-shadow: 0 0 0 4px rgba(203,213,225,.22);
    transition: opacity .22s ease, transform .22s ease, background .22s ease, box-shadow .22s ease;
}
.tog:hover .tog-s {
    border-color: #c7d2fe;
    box-shadow: inset 0 2px 5px rgba(15,23,42,.08), 0 10px 24px rgba(99,102,241,.14);
}
.tog input:focus + .tog-s {
    box-shadow: 0 0 0 4px rgba(99,102,241,.14), inset 0 2px 5px rgba(15,23,42,.08);
}
.tog input:checked + .tog-s {
    border-color: #6d78ff;
    background: linear-gradient(135deg, #5b63f6 0%, #7c88ff 55%, #8aa7ff 100%);
    box-shadow: inset 0 1px 0 rgba(255,255,255,.18), 0 12px 24px rgba(99,102,241,.25);
}
.tog input:checked + .tog-s::before {
    transform: translateX(26px);
    box-shadow: 0 6px 14px rgba(49,46,129,.24);
}
.tog input:checked + .tog-s::after {
    right: auto;
    left: 12px;
    background: rgba(255,255,255,.9);
    box-shadow: 0 0 0 4px rgba(255,255,255,.16);
    transform: scale(.9);
}

/* ---- 范围滑块 ---- */
.rg-group { margin-bottom: 14px; }
.rg-label { display: flex; justify-content: space-between; margin-bottom: 7px; }
.rg-label .rg-name { font-size: 13px; font-weight: 500; color: #374151; display: flex; align-items: center; gap: 6px; }
.rg-label .rg-name .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
.rg-label .rg-num { font-size: 14px; font-weight: 700; color: #4f46e5; min-width: 30px; text-align: right; }
input[type=range].pm-range { width: 100%; height: 6px; appearance: none; background: #e2e8f0; border-radius: 3px; outline: none; cursor: pointer; }
input[type=range].pm-range::-webkit-slider-thumb { appearance: none; width: 18px; height: 18px; border-radius: 50%; background: #6366f1; box-shadow: 0 2px 6px rgba(99,102,241,.4); cursor: pointer; transition: transform .15s; }
input[type=range].pm-range::-webkit-slider-thumb:hover { transform: scale(1.25); }

/* ---- 事件日志 ---- */
.ev-log { max-height: 300px; overflow-y: auto; }
.ev-item { display: flex; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f1f5f9; align-items: flex-start; }
.ev-item:last-child { border-bottom: none; }
.ev-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; margin-top: 5px; }
.ev-dot.pos { background: #10b981; }
.ev-dot.neg { background: #ef4444; }
.ev-dot.neu { background: #6366f1; }
.ev-content .ev-title { font-size: 13px; font-weight: 500; color: #1e293b; }
.ev-content .ev-meta { font-size: 11px; color: #94a3b8; margin-top: 2px; }
.ev-effect { margin-left: auto; flex-shrink: 0; }

/* ---- 统计图 ---- */
.chart-row { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.chart-lbl { font-size: 12px; color: #475569; width: 80px; flex-shrink: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.chart-track { flex: 1; height: 8px; background: #f1f5f9; border-radius: 4px; overflow: hidden; }
.chart-fill { height: 100%; border-radius: 4px; transition: width .8s ease; }
.chart-val { font-size: 12px; font-weight: 600; color: #334155; width: 28px; text-align: right; }

/* ---- 双列布局 ---- */
.two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.two-col-left { grid-column: 1; }
.two-col-right { grid-column: 2; }

/* ---- 空状态 ---- */
.empty-state { text-align: center; padding: 40px 20px; color: #94a3b8; }
.empty-state .es-icon { margin-bottom: 12px; display: flex; align-items: center; justify-content: center; }
.empty-state .es-icon svg { opacity: 0.55; }
.empty-state .es-text { font-size: 14px; }

/* ---- Toast Modal ---- */
.pm-toast-mask {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, .34);
    backdrop-filter: blur(3px);
    z-index: 99998;
    opacity: 0;
    visibility: hidden;
    transition: opacity .22s ease, visibility .22s ease;
}
.pm-toast-mask.show {
    opacity: 1;
    visibility: visible;
}
.pm-toast {
    position: fixed;
    top: 50%;
    left: 50%;
    width: 360px;
    max-width: calc(100vw - 32px);
    min-height: 132px;
    padding: 24px 24px 20px;
    border-radius: 20px;
    background: linear-gradient(180deg, #ffffff 0%, #f8fbff 100%);
    border: 1px solid rgba(226, 232, 240, .9);
    color: #0f172a;
    z-index: 99999;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    text-align: center;
    opacity: 0;
    visibility: hidden;
    box-shadow: 0 24px 64px rgba(15, 23, 42, .18), 0 4px 12px rgba(15, 23, 42, .06);
    transform: translate(-50%, -50%) scale(.94);
    transition: opacity .22s ease, visibility .22s ease, transform .22s cubic-bezier(.4,0,.2,1);
}
.pm-toast.show {
    opacity: 1;
    visibility: visible;
    transform: translate(-50%, -50%) scale(1);
}
.pm-toast-icon {
    width: 52px;
    height: 52px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg,#10b981,#34d399);
    color: #fff;
    box-shadow: 0 12px 24px rgba(16,185,129,.22);
    flex-shrink: 0;
}
.pm-toast.error .pm-toast-icon {
    background: linear-gradient(135deg,#ef4444,#f97316);
    box-shadow: 0 12px 24px rgba(239,68,68,.22);
}
.pm-toast-icon svg {
    width: 24px;
    height: 24px;
    stroke: currentColor;
    fill: none;
    stroke-width: 2.1;
    stroke-linecap: round;
    stroke-linejoin: round;
}
.pm-toast-text {
    font-size: 14px;
    line-height: 1.8;
    font-weight: 600;
    color: #334155;
    word-break: break-word;
}

/* ---- 摘要统计 ---- */
.pm-summary { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 24px; }
.pm-sum-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; padding: 16px 20px; display: flex; align-items: center; gap: 14px; }
.pm-sum-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.pm-sum-icon svg { flex-shrink: 0; }
.pm-sum-info .val { font-size: 22px; font-weight: 700; color: #1e293b; }
.pm-sum-info .lbl { font-size: 12px; color: #94a3b8; }

@media (max-width: 900px) {
    .pm-summary { grid-template-columns: 1fr 1fr; }
    .two-col { grid-template-columns: 1fr; }
    .pm-form-row.c3, .pm-form-row.c4 { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 600px) {
    .pm-summary { grid-template-columns: 1fr 1fr; }
    .pm-form-row { grid-template-columns: 1fr; }
}
/* ---- 同步规则弹窗 ---- */
.sr-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.45); z-index: 10000; display: none; }
.sr-modal { position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%); background: #fff; border-radius: 16px; padding: 24px; width: 380px; max-width: 95vw; z-index: 10001; box-shadow: 0 20px 60px rgba(0,0,0,0.18); display: none; }
.sr-modal-title { font-size: 15px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
.sr-modal-info { font-size: 12px; color: #94a3b8; margin-bottom: 16px; }
.sr-cls-grid { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; max-height: 200px; overflow-y: auto; }
.sr-cls-label { display: flex; align-items: center; gap: 5px; cursor: pointer; font-size: 12px; color: #374151; background: #f8fafc; padding: 5px 10px; border-radius: 6px; border: 1px solid #e2e8f0; }
.sr-cls-label:hover { border-color: #818cf8; background: #f5f3ff; }
</style>

<div class="pm">

<!-- ===== 页头 ===== -->
<div class="pm-hd">
    <div class="pm-hd-left">
        <div class="pm-hd-icon">
            <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
        </div>
        <div class="pm-hd-text">
            <h1>班级宠物管理</h1>
            <p>通过宠物激励机制，监控班级行为、配置规则与任务、发布班级事件</p>
        </div>
    </div>
</div>

<!-- ===== 汇总统计 ===== -->
<div class="pm-summary" id="pmSummary">
    <div class="pm-sum-card">
        <div class="pm-sum-icon" style="background:#f5f3ff;"><svg width="26" height="26" viewBox="0 0 24 24" fill="#8b5cf6" stroke="none"><ellipse cx="5.5" cy="5" rx="1.7" ry="2.1"/><ellipse cx="9.5" cy="3.3" rx="1.7" ry="2.1"/><ellipse cx="14.5" cy="3.3" rx="1.7" ry="2.1"/><ellipse cx="18.5" cy="5" rx="1.7" ry="2.1"/><path d="M12 9c-3.5 0-5.5 2.6-5.5 5.2 0 2 1.5 3.6 5.5 3.6s5.5-1.6 5.5-3.6C17.5 11.6 15.5 9 12 9z"/></svg></div>
        <div class="pm-sum-info"><div class="val" id="sumClasses">0</div><div class="lbl">班级宠物数</div></div>
    </div>
    <div class="pm-sum-card">
        <div class="pm-sum-icon" style="background:#f0fdf4;"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg></div>
        <div class="pm-sum-info"><div class="val" id="sumAvgHP">--</div><div class="lbl">平均健康值</div></div>
    </div>
    <div class="pm-sum-card">
        <div class="pm-sum-icon" style="background:#eff6ff;"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></div>
        <div class="pm-sum-info"><div class="val" id="sumHappy">0</div><div class="lbl">开心班级</div></div>
    </div>
    <div class="pm-sum-card">
        <div class="pm-sum-icon" style="background:#fef2f2;"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></div>
        <div class="pm-sum-info"><div class="val" id="sumSad">0</div><div class="lbl">需关注班级</div></div>
    </div>
</div>

<!-- ===== 标签导航 ===== -->
<div class="pm-tabs">
    <button type="button" class="pm-tab active" onclick="switchTab(0)">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        宠物概览
    </button>
    <button type="button" class="pm-tab" onclick="switchTab(1)">
        <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        行为规则
    </button>
    <button type="button" class="pm-tab" onclick="switchTab(2)">
        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
        任务奖励
    </button>
    <button type="button" class="pm-tab" onclick="switchTab(3)">
        <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        干预与事件
    </button>
    <button type="button" class="pm-tab" onclick="switchTab(4)">
        <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
        统计分析
    </button>
</div>

<!-- ===================== TAB 0: 概览 ===================== -->
<div id="tab0" class="pm-panel active">
    <div id="petGrid" class="pet-grid"></div>
    <div class="sec">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                近期行为记录
            </div>
            <button type="button" class="pm-btn pm-btn-outline pm-btn-sm" onclick="clearEventLog()">清空记录</button>
        </div>
        <div class="sec-body" style="padding:0 20px;">
            <div class="ev-log" id="eventLog">
                <div class="empty-state"><div class="es-icon"><svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/><line x1="8" y1="12" x2="16" y2="12"/><line x1="8" y1="16" x2="13" y2="16"/></svg></div><div class="es-text">暂无行为记录</div></div>
            </div>
        </div>
    </div>
</div>

<!-- ===================== TAB 1: 行为规则 ===================== -->
<div id="tab1" class="pm-panel">
    <!-- 评分管理同步规则 -->
    <div class="sec">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                评分管理同步规则
            </div>
            <button type="button" class="pm-btn pm-btn-outline pm-btn-sm" onclick="loadSyncedRules(true)">
                <svg viewBox="0 0 24 24"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
                刷新同步
            </button>
        </div>
        <div class="sec-body">
            <p class="sec-desc">以下规则来自“<a href="attitudetype.aspx" style="color:#6366f1;text-decoration:none;font-weight:600;">评分管理</a>”页面配置的评分类型。为每条规则选择影响的宠物属性，点击“应用至班级”可快速调整宠物状态。</p>
            <div id="syncRulesWrap">
                <div class="empty-state"><div class="es-icon"><svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div><div class="es-text">切换到此标签时将自动加载，或点击“刷新同步”手动加载</div></div>
            </div>
        </div>
    </div>
    <div class="sec">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                自定义行为规则
            </div>
            <button type="button" class="pm-btn pm-btn-primary pm-btn-sm" onclick="showAddRule()">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加规则
            </button>
        </div>
        <div class="sec-body">
            <p class="sec-desc">定义学生行为对班级宠物属性的影响规则。正值表示增加，负值表示减少。当触发对应行为时，宠物状态将自动更新。</p>
            <div style="overflow-x:auto;">
                <table class="pm-table" id="rulesTable">
                    <thead>
                        <tr>
                            <th>行为描述</th>
                            <th>分类</th>
                            <th>影响属性</th>
                            <th>变化值</th>
                            <th>启用</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody id="rulesTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- 添加规则表单 -->
    <div class="sec" id="addRuleForm" style="display:none;">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                新建规则
            </div>
        </div>
        <div class="sec-body">
            <div class="pm-form-row c3">
                <div class="fg"><label>行为描述</label><input type="text" id="ruleDesc" class="pm-input" placeholder="如：课堂举手发言"></div>
                <div class="fg">
                    <label>分类</label>
                    <select id="ruleCategory" class="pm-select">
                        <option value="study">学习</option>
                        <option value="discipline">纪律</option>
                        <option value="performance">课堂表现</option>
                        <option value="attendance">出勤</option>
                        <option value="award">荣誉</option>
                    </select>
                </div>
                <div class="fg">
                    <label>影响属性</label>
                    <select id="ruleStat" class="pm-select">
                        <option value="hp">健康值</option>
                        <option value="mood">心情值</option>
                        <option value="food">饱食度</option>
                        <option value="clean">清洁度</option>
                        <option value="exp">经验值</option>
                    </select>
                </div>
            </div>
            <div class="pm-form-row">
                <div class="fg"><label>变化值（正数增加，负数减少）</label><input type="number" id="ruleValue" class="pm-input" placeholder="-10 ~ 20" min="-50" max="50"></div>
                <div class="fg" style="display:flex;align-items:flex-end;gap:10px;">
                    <button type="button" class="pm-btn pm-btn-primary" onclick="saveRule()">
                        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                        保存规则
                    </button>
                    <button type="button" class="pm-btn pm-btn-outline" onclick="document.getElementById('addRuleForm').style.display='none'">取消</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ===================== TAB 2: 任务奖励 ===================== -->
<div id="tab2" class="pm-panel">
    <div class="sec">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                任务配置
            </div>
            <button type="button" class="pm-btn pm-btn-primary pm-btn-sm" onclick="showAddTask()">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加任务
            </button>
        </div>
        <div class="sec-body">
            <p class="sec-desc">配置每日/每周任务。当班级完成任务目标时，宠物将获得对应奖励，激励学生共同努力。</p>
            <div style="overflow-x:auto;">
                <table class="pm-table" id="tasksTable">
                    <thead>
                        <tr>
                            <th>任务名称</th>
                            <th>类型</th>
                            <th>奖励属性</th>
                            <th>奖励值</th>
                            <th>启用</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody id="tasksTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- 添加任务表单 -->
    <div class="sec" id="addTaskForm" style="display:none;">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                新建任务
            </div>
        </div>
        <div class="sec-body">
            <div class="pm-form-row c4">
                <div class="fg"><label>任务名称</label><input type="text" id="taskTitle" class="pm-input" placeholder="如：全班完成签到"></div>
                <div class="fg">
                    <label>任务类型</label>
                    <select id="taskType" class="pm-select">
                        <option value="daily">每日任务</option>
                        <option value="weekly">每周任务</option>
                        <option value="special">特别任务</option>
                    </select>
                </div>
                <div class="fg">
                    <label>奖励属性</label>
                    <select id="taskStat" class="pm-select">
                        <option value="hp">健康值</option>
                        <option value="mood">心情值</option>
                        <option value="food">饱食度</option>
                        <option value="clean">清洁度</option>
                        <option value="exp">经验值</option>
                    </select>
                </div>
                <div class="fg"><label>奖励值</label><input type="number" id="taskValue" class="pm-input" placeholder="1 ~ 50" min="1" max="100"></div>
            </div>
            <div style="display:flex;gap:10px;">
                <button type="button" class="pm-btn pm-btn-success" onclick="saveTask()">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    保存任务
                </button>
                <button type="button" class="pm-btn pm-btn-outline" onclick="document.getElementById('addTaskForm').style.display='none'">取消</button>
            </div>
        </div>
    </div>

    <!-- 完成任务面板 -->
    <div class="sec">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                标记任务完成
            </div>
        </div>
        <div class="sec-body">
            <div class="pm-form-row">
                <div class="fg">
                    <label>选择班级</label>
                    <select id="completeClass" class="pm-select"></select>
                </div>
                <div class="fg">
                    <label>选择任务</label>
                    <select id="completeTask" class="pm-select"></select>
                </div>
            </div>
            <button type="button" class="pm-btn pm-btn-success" onclick="completeTask()">
                <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                确认完成，发放奖励
            </button>
        </div>
    </div>
</div>

<!-- ===================== TAB 3: 干预与事件 ===================== -->
<div id="tab3" class="pm-panel">
    <div class="two-col">
        <!-- 干预宠物状态 -->
        <div>
            <div class="sec">
                <div class="sec-hd">
                    <div class="sec-title">
                        <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                        干预宠物状态
                    </div>
                </div>
                <div class="sec-body">
                    <p class="sec-desc">直接调整指定班级宠物的属性值。请谨慎操作，建议填写干预原因。</p>
                    <div class="pm-form-row c3" style="margin-bottom:16px;">
                        <div class="fg">
                            <label>校区</label>
                            <select id="intSchool" class="pm-select" onchange="onIntSchoolChange()"></select>
                        </div>
                        <div class="fg">
                            <label>年级</label>
                            <select id="intGrade" class="pm-select" onchange="onIntGradeChange()"></select>
                        </div>
                        <div class="fg">
                            <label>班级</label>
                            <select id="intClass" class="pm-select" onchange="loadIntSliders()"></select>
                        </div>
                    </div>
                    <div id="intSliders">
                        <div class="rg-group">
                            <div class="rg-label">
                                <span class="rg-name"><span class="dot" style="background:#10b981;"></span>健康值</span>
                                <span class="rg-num" id="intHPVal">80</span>
                            </div>
                            <input type="range" class="pm-range" id="intHP" min="0" max="100" value="80" oninput="document.getElementById('intHPVal').textContent=this.value">
                        </div>
                        <div class="rg-group">
                            <div class="rg-label">
                                <span class="rg-name"><span class="dot" style="background:#6366f1;"></span>心情值</span>
                                <span class="rg-num" id="intMoodVal">75</span>
                            </div>
                            <input type="range" class="pm-range" id="intMood" min="0" max="100" value="75" oninput="document.getElementById('intMoodVal').textContent=this.value">
                        </div>
                        <div class="rg-group">
                            <div class="rg-label">
                                <span class="rg-name"><span class="dot" style="background:#f59e0b;"></span>饱食度</span>
                                <span class="rg-num" id="intFoodVal">60</span>
                            </div>
                            <input type="range" class="pm-range" id="intFood" min="0" max="100" value="60" oninput="document.getElementById('intFoodVal').textContent=this.value">
                        </div>
                        <div class="rg-group">
                            <div class="rg-label">
                                <span class="rg-name"><span class="dot" style="background:#06b6d4;"></span>清洁度</span>
                                <span class="rg-num" id="intCleanVal">90</span>
                            </div>
                            <input type="range" class="pm-range" id="intClean" min="0" max="100" value="90" oninput="document.getElementById('intCleanVal').textContent=this.value">
                        </div>
                        <div class="fg" style="margin: 12px 0;">
                            <label>干预原因（选填）</label>
                            <input type="text" id="intReason" class="pm-input" placeholder="如：本周全勤奖励">
                        </div>
                        <button type="button" class="pm-btn pm-btn-pink" onclick="applyIntervention()">
                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                            应用干预
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 发布班级事件 -->
        <div>
            <div class="sec">
                <div class="sec-hd">
                    <div class="sec-title">
                        <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                        发布班级事件
                    </div>
                </div>
                <div class="sec-body">
                    <p class="sec-desc">发布一个影响班级宠物的特殊事件，可同时影响多个班级。</p>
                    <div class="pm-form-row c1">
                        <div class="fg"><label>事件标题</label><input type="text" id="evtTitle" class="pm-input" placeholder="如：期中考试全班进步"></div>
                    </div>
                    <div class="pm-form-row c1">
                        <div class="fg"><label>事件描述</label><textarea id="evtDesc" class="pm-textarea" placeholder="描述事件详情..."></textarea></div>
                    </div>
                    <div class="pm-form-row">
                        <div class="fg">
                            <label>影响属性</label>
                            <select id="evtStat" class="pm-select">
                                <option value="hp">健康值</option>
                                <option value="mood">心情值</option>
                                <option value="food">饱食度</option>
                                <option value="clean">清洁度</option>
                                <option value="exp">经验值</option>
                                <option value="all">全属性</option>
                            </select>
                        </div>
                        <div class="fg"><label>变化值（正数奖励，负数惩罚）</label><input type="number" id="evtValue" class="pm-input" placeholder="如：+15 或 -10" min="-50" max="50"></div>
                    </div>
                    <div class="fg" style="margin-bottom:16px;">
                        <label>影响范围</label>
                        <div id="evtClasses" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:6px;"></div>
                    </div>
                    <button type="button" class="pm-btn pm-btn-primary" onclick="publishEvent()">
                        <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                        发布事件
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- 近期事件 -->
    <div class="sec">
        <div class="sec-hd">
            <div class="sec-title">
                <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                已发布的事件
            </div>
        </div>
        <div class="sec-body" style="padding:0 20px;">
            <div class="ev-log" id="publishedEvents">
                <div class="empty-state"><div class="es-icon"><svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg></div><div class="es-text">暂无发布的事件</div></div>
            </div>
        </div>
    </div>
</div>

<!-- ===================== TAB 4: 统计分析 ===================== -->
<div id="tab4" class="pm-panel">
    <div class="two-col">
        <div>
            <div class="sec">
                <div class="sec-hd">
                    <div class="sec-title">
                        <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                        班级健康值对比
                    </div>
                </div>
                <div class="sec-body" id="chartHP"></div>
            </div>
            <div class="sec">
                <div class="sec-hd">
                    <div class="sec-title">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
                        班级心情值对比
                    </div>
                </div>
                <div class="sec-body" id="chartMood"></div>
            </div>
        </div>
        <div>
            <div class="sec">
                <div class="sec-hd">
                    <div class="sec-title">
                        <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                        班级数据总览
                    </div>
                </div>
                <div class="sec-body" style="padding:0;">
                    <table class="pm-table" id="statsTable">
                        <thead>
                            <tr>
                                <th>班级</th>
                                <th>宠物</th>
                                <th>Lv.</th>
                                <th><svg width="12" height="12" viewBox="0 0 24 24" fill="#ef4444" stroke="none"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg> 健康</th>
                                <th><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg> 心情</th>
                                <th>状态</th>
                            </tr>
                        </thead>
                        <tbody id="statsTbody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

</div><!-- /pm -->

<!-- Toast -->
<div class="pm-toast-mask" id="pmToastMask"></div>
<div class="pm-toast" id="pmToast">
    <div class="pm-toast-icon" id="pmToastIcon">
        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>
    </div>
    <div class="pm-toast-text" id="pmToastText"></div>
</div>

<script type="text/javascript">
// ============================================================
// 数据 & 常量
// ============================================================
var classList   = <%=GetClassesJson()%>;
var schoolsList  = <%=_schoolsJson%>;
// Room/Teacher.SchoolId 是否有有效学校（COALESCE 返回 '0' 表示无学校）
var _clsHasSchoolId = classList.some(function(c) { return c.schoolId && c.schoolId !== '0'; });

var PET_KEY   = 'ls_pets_v1';
var RULES_KEY = 'ls_pet_rules_v1';
var TASKS_KEY = 'ls_pet_tasks_v1';
var EVTS_KEY  = 'ls_pet_events_v1';
// ============================================================
// SVG 图标常量
// ============================================================
var _IC = {
    paw:     '<svg width="40" height="40" viewBox="0 0 24 24" fill="#8b5cf6" stroke="none"><ellipse cx="5.5" cy="5" rx="1.7" ry="2.1"/><ellipse cx="9.5" cy="3.3" rx="1.7" ry="2.1"/><ellipse cx="14.5" cy="3.3" rx="1.7" ry="2.1"/><ellipse cx="18.5" cy="5" rx="1.7" ry="2.1"/><path d="M12 9c-3.5 0-5.5 2.6-5.5 5.2 0 2 1.5 3.6 5.5 3.6s5.5-1.6 5.5-3.6C17.5 11.6 15.5 9 12 9z"/></svg>',
    hp:      '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>',
    mood:    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>',
    food:    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3zm0 0v7"/></svg>',
    clean:   '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#06b6d4" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/></svg>',
    feed:    '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3zm0 0v7"/></svg>',
    play:    '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg>',
    gear:    '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>',
    clip:    '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/><line x1="8" y1="12" x2="16" y2="12"/><line x1="8" y1="16" x2="13" y2="16"/></svg>',
    mega:    '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>',
    happy:   '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>',
    neutral: '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="8" y1="15" x2="16" y2="15"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>',
    sad:     '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>'
};


var PET_EMOJIS = ['🐱','🐶','🐰','🦊','🐼','🐨','🐸','🦁','🐯','🐺','🦋','🐧','🦄','🐲','🐻'];
var PET_NAMES  = ['小喵','旺财','糯米','小橘','花花','澳澳','跳跳','狮子','小虎','灰灰','蝴蝶','企鹅','独角兽','小龙','熊宝'];
var PET_COLORS = ['#f5f3ff','#eff6ff','#f0fdf4','#fffbeb','#fdf2f8','#ecfeff','#fff7ed','#fef2f2','#f0fdf4','#f8fafc'];
var PET_BCOLORS= ['#6366f1','#3b82f6','#10b981','#f59e0b','#ec4899','#06b6d4','#f97316','#ef4444','#8b5cf6','#64748b'];

var CAT_LABELS = {study:'学习',discipline:'纪律',performance:'课堂表现',attendance:'出勤',award:'荣誉'};
var STAT_LABELS = {hp:'健康值',mood:'心情值',food:'饱食度',clean:'清洁度',exp:'经验值',all:'全属性'};
var TYPE_LABELS = {daily:'每日',weekly:'每周',special:'特别'};

// ============================================================
// 存储
// ============================================================
function loadPets() {
    try { return JSON.parse(localStorage.getItem(PET_KEY)) || {}; } catch(e) { return {}; }
}
function savePets(data) { try { localStorage.setItem(PET_KEY, JSON.stringify(data)); } catch(e) {} }

function loadRules() {
    try {
        var r = JSON.parse(localStorage.getItem(RULES_KEY));
        return r || getDefaultRules();
    } catch(e) { return getDefaultRules(); }
}
function saveRules(data) { try { localStorage.setItem(RULES_KEY, JSON.stringify(data)); } catch(e) {} }

function loadTasks() {
    try {
        var t = JSON.parse(localStorage.getItem(TASKS_KEY));
        return t || getDefaultTasks();
    } catch(e) { return getDefaultTasks(); }
}
function saveTasks(data) { try { localStorage.setItem(TASKS_KEY, JSON.stringify(data)); } catch(e) {} }

function normalizeEvent(evt) {
    if (!evt || typeof evt !== 'object') return null;

    var classes = [];
    if (Array.isArray(evt.classes)) {
        classes = evt.classes.filter(function(c) { return c !== null && c !== undefined && c !== ''; });
    } else if (typeof evt.classes === 'string' || typeof evt.classes === 'number') {
        classes = [evt.classes];
    } else if (Array.isArray(evt.classIds)) {
        classes = evt.classIds.filter(function(c) { return c !== null && c !== undefined && c !== ''; });
    } else if (typeof evt.classId === 'string' || typeof evt.classId === 'number') {
        classes = [evt.classId];
    }

    return {
        id: evt.id || Date.now(),
        _log: !!evt._log,
        title: evt.title || '',
        desc: evt.desc || '',
        stat: evt.stat || '',
        value: parseInt(evt.value, 10) || 0,
        classes: classes,
        time: evt.time || '',
        effect: evt.effect || '',
        type: evt.type || 'neu'
    };
}
function loadEvents() {
    try {
        var raw = JSON.parse(localStorage.getItem(EVTS_KEY));
        if (!Array.isArray(raw)) return [];
        return raw.map(normalizeEvent).filter(function(evt) { return evt !== null; });
    } catch(e) { return []; }
}
function saveEvents(data) { try { localStorage.setItem(EVTS_KEY, JSON.stringify(data)); } catch(e) {} }

// ============================================================
// 默认数据
// ============================================================
function getDefaultRules() {
    return [
        {id:1, desc:'迟到',      category:'discipline',  stat:'mood',  value:-5,  enabled:true},
        {id:2, desc:'旷课',      category:'discipline',  stat:'hp',    value:-10, enabled:true},
        {id:3, desc:'完成作业',  category:'study',       stat:'hp',    value:8,   enabled:true},
        {id:4, desc:'未完成作业',category:'study',       stat:'food',  value:-8,  enabled:true},
        {id:5, desc:'课堂表现优秀',category:'performance',stat:'mood', value:10,  enabled:true},
        {id:6, desc:'全班签到',  category:'attendance',  stat:'hp',    value:5,   enabled:true},
        {id:7, desc:'完成测验',  category:'study',       stat:'exp',   value:20,  enabled:true},
        {id:8, desc:'作品获推荐',category:'award',       stat:'mood',  value:15,  enabled:true},
        {id:9, desc:'课堂纪律差',category:'discipline',  stat:'clean', value:-5,  enabled:true},
        {id:10,desc:'小组合作获奖',category:'award',     stat:'food',  value:12,  enabled:true},
    ];
}
function getDefaultTasks() {
    return [
        {id:1, title:'全班100%签到',    type:'daily',   stat:'hp',   value:10, enabled:true},
        {id:2, title:'全班提交作业',     type:'daily',   stat:'mood', value:12, enabled:true},
        {id:3, title:'本周无迟到',       type:'weekly',  stat:'mood', value:20, enabled:true},
        {id:4, title:'完成一节完整课程', type:'weekly',  stat:'exp',  value:50, enabled:true},
        {id:5, title:'全班答题正确率>80%',type:'special',stat:'hp',  value:25, enabled:true},
    ];
}

// ============================================================
// 宠物初始化
// ============================================================
function getPetData(rid, idx) {
    var pets = loadPets();
    var key = 'r' + rid;
    if (!pets[key]) {
        var i = idx % PET_EMOJIS.length;
        pets[key] = {
            rid: rid, emoji: PET_EMOJIS[i], name: PET_NAMES[i],
            color: PET_COLORS[i], bcolor: PET_BCOLORS[i],
            level: 1, exp: 0,
            hp: 80, mood: 75, food: 60, clean: 90
        };
        savePets(pets);
    }
    return pets[key];
}

function clamp(v) { return Math.max(0, Math.min(100, v)); }

function applyStatChange(rid, stat, delta) {
    var pets = loadPets();
    var key = 'r' + rid;
    if (!pets[key]) return;
    var p = pets[key];
    if (stat === 'all') {
        p.hp   = clamp(p.hp   + delta);
        p.mood = clamp(p.mood + delta);
        p.food = clamp(p.food + delta);
        p.clean= clamp(p.clean+ delta);
    } else if (stat === 'exp') {
        p.exp = (p.exp || 0) + Math.abs(delta);
        var threshold = p.level * 100;
        if (p.exp >= threshold) { p.exp -= threshold; p.level++; }
    } else {
        p[stat] = clamp((p[stat]||0) + delta);
    }
    pets[key] = p;
    savePets(pets);
}

function getPetState(pet) {
    var avg = (pet.hp + pet.mood + pet.food + pet.clean) / 4;
    if (avg >= 70) return {label:_IC.happy+' 开心活泼', cls:'happy'};
    if (avg >= 45) return {label:_IC.neutral+' 状态一般', cls:'neutral'};
    return {label:_IC.sad+' 需要关注', cls:'sad'};
}

// ============================================================
// 渲染概览
// ============================================================
function renderPetGrid() {
    var grid = document.getElementById('petGrid');
    if (!classList || classList.length === 0) {
        grid.innerHTML = '<div class="empty-state"><div class="es-icon">'+_IC.paw+'</div><div class="es-text">暂无班级数据，请确认教师账号已分配班级</div></div>';
        return;
    }
    var html = '';
    classList.forEach(function(cls, idx) {
        var p = getPetData(cls.id, idx);
        var state = getPetState(p);
        html += '<div class="pet-card" id="pc_' + cls.id + '">';
        html += '<div class="pet-card-bg" style="background:' + p.bcolor + ';"></div>';
        html += '<span class="pet-level">Lv.' + p.level + '</span>';
        html += '<div class="pet-header">';
        html += '<div class="pet-emoji" style="background:' + p.color + ';">' + p.emoji + '</div>';
        html += '<div class="pet-info">';
        html += '<div class="pet-name">' + p.name + '</div>';
        html += '<div class="pet-class">' + cls.name + '</div>';
        html += '<div class="pet-state ' + state.cls + '">' + state.label + '</div>';
        html += '</div></div>';
        html += '<div class="pet-stats">';
        html += statBarHtml('hp',   p.hp,    _IC.hp);
        html += statBarHtml('mood', p.mood,  _IC.mood);
        html += statBarHtml('food', p.food,  _IC.food);
        html += statBarHtml('clean',p.clean, _IC.clean);
        html += '</div>';
        html += '<div class="pet-actions">';
        html += '<button type="button" class="pet-btn" onclick="quickFeed(' + cls.id + ')">'+_IC.feed+' 喂食</button>';
        html += '<button type="button" class="pet-btn" onclick="quickPlay(' + cls.id + ')">'+_IC.play+' 互动</button>';
        html += '<button type="button" class="pet-btn prim" onclick="goIntervene(' + cls.id + ')">'+_IC.gear+' 干预</button>';
        html += '</div>';
        html += '</div>';
    });
    grid.innerHTML = html;
    updateSummary();
}

function statBarHtml(stat, val, icon) {
    return '<div class="stat-row">'
        + '<span class="stat-lbl">' + icon + '</span>'
        + '<div class="stat-track"><div class="stat-fill ' + stat + '" style="width:' + val + '%"></div></div>'
        + '<span class="stat-val">' + val + '</span>'
        + '</div>';
}

function updateSummary() {
    if (!classList || classList.length === 0) return;
    var pets = loadPets();
    var total = classList.length;
    var sumHP = 0, happy = 0, sad = 0;
    classList.forEach(function(cls, idx) {
        var p = getPetData(cls.id, idx);
        sumHP += p.hp;
        var state = getPetState(p);
        if (state.cls === 'happy') happy++;
        if (state.cls === 'sad') sad++;
    });
    document.getElementById('sumClasses').textContent = total;
    document.getElementById('sumAvgHP').textContent = Math.round(sumHP / total);
    document.getElementById('sumHappy').textContent = happy;
    document.getElementById('sumSad').textContent = sad;
}

// ============================================================
// 快捷操作
// ============================================================
function quickFeed(rid) {
    applyStatChange(rid, 'food', 15);
    applyStatChange(rid, 'hp', 5);
    addEventLog('喂食', rid, 'neu', '+15 饱食度, +5 健康值');
    renderPetGrid();
    toast('喂食成功！宠物吃得很开心 🍖');
}
function quickPlay(rid) {
    applyStatChange(rid, 'mood', 12);
    applyStatChange(rid, 'food', -5);
    addEventLog('互动玩耍', rid, 'pos', '+12 心情值');
    renderPetGrid();
    toast('互动成功！宠物心情提升了 🎮');
}
function goIntervene(rid) {
    switchTab(3);
    // 找到目标班级，自动回填校区/年级确保 rid 一定在下拉中
    var found = null;
    classList.forEach(function(c) { if (String(c.id) === String(rid)) found = c; });
    if (found && _clsHasSchoolId && found.schoolId) {
        document.getElementById('intSchool').value = found.schoolId;
        buildIntGrades(found.schoolId);
        document.getElementById('intGrade').value = found.grade || '';
        buildIntClasses(found.schoolId, found.grade || '');
    } else if (found && found.grade) {
        document.getElementById('intSchool').value = '';
        buildIntGrades('');
        document.getElementById('intGrade').value = found.grade;
        buildIntClasses('', found.grade);
    } else {
        document.getElementById('intSchool').value = '';
        buildIntGrades('');
    }
    document.getElementById('intClass').value = rid;
    loadIntSliders();
}

// ============================================================
// 规则
// ============================================================
function renderRules() {
    var rules = loadRules();
    var tbody = document.getElementById('rulesTbody');
    if (!rules.length) { tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:20px;">暂无规则</td></tr>'; return; }
    tbody.innerHTML = rules.map(function(r) {
        var catTag = '<span class="tag tag-blue">' + (CAT_LABELS[r.category]||r.category) + '</span>';
        var statTag = '<span class="tag tag-purple">' + (STAT_LABELS[r.stat]||r.stat) + '</span>';
        var valTag = r.value >= 0
            ? '<span class="tag tag-green">+' + r.value + '</span>'
            : '<span class="tag tag-red">' + r.value + '</span>';
        return '<tr>'
            + '<td><strong>' + escHtml(r.desc) + '</strong></td>'
            + '<td>' + catTag + '</td>'
            + '<td>' + statTag + '</td>'
            + '<td>' + valTag + '</td>'
            + '<td><label class="tog"><input type="checkbox"' + (r.enabled?' checked':'') + ' onchange="toggleRule(' + r.id + ',this.checked)"><span class="tog-s"></span></label></td>'
            + '<td><button type="button" class="pm-btn pm-btn-danger pm-btn-sm" onclick="deleteRule(' + r.id + ')">删除</button></td>'
            + '</tr>';
    }).join('');
}

function showAddRule() {
    var f = document.getElementById('addRuleForm');
    f.style.display = f.style.display === 'none' ? 'block' : 'none';
}
function saveRule() {
    var desc = document.getElementById('ruleDesc').value.trim();
    var val  = parseInt(document.getElementById('ruleValue').value);
    if (!desc) { toast('请输入行为描述', true); return; }
    if (isNaN(val)) { toast('请输入有效的变化值', true); return; }
    var rules = loadRules();
    var maxId = rules.reduce(function(m, r) { return Math.max(m, r.id); }, 0);
    rules.push({
        id: maxId + 1,
        desc: desc,
        category: document.getElementById('ruleCategory').value,
        stat: document.getElementById('ruleStat').value,
        value: val,
        enabled: true
    });
    saveRules(rules);
    renderRules();
    document.getElementById('ruleDesc').value = '';
    document.getElementById('ruleValue').value = '';
    document.getElementById('addRuleForm').style.display = 'none';
    toast('规则已保存 ✅');
}
function toggleRule(id, checked) {
    var rules = loadRules();
    rules.forEach(function(r) { if (r.id === id) r.enabled = checked; });
    saveRules(rules);
}
function deleteRule(id) {
    if (!confirm('确定要删除此规则吗？')) return;
    var rules = loadRules().filter(function(r) { return r.id !== id; });
    saveRules(rules);
    renderRules();
    toast('规则已删除');
}

// ============================================================
// 任务
// ============================================================
function renderTasks() {
    var tasks = loadTasks();
    var tbody = document.getElementById('tasksTbody');
    tbody.innerHTML = tasks.map(function(t) {
        var typeTag = t.type === 'daily'   ? '<span class="tag tag-blue">'  + TYPE_LABELS[t.type] + '</span>'
                   : t.type === 'weekly'   ? '<span class="tag tag-amber">' + TYPE_LABELS[t.type] + '</span>'
                   :                         '<span class="tag tag-pink">'  + TYPE_LABELS[t.type] + '</span>';
        return '<tr>'
            + '<td><strong>' + escHtml(t.title) + '</strong></td>'
            + '<td>' + typeTag + '</td>'
            + '<td><span class="tag tag-purple">' + (STAT_LABELS[t.stat]||t.stat) + '</span></td>'
            + '<td><span class="tag tag-green">+' + t.value + '</span></td>'
            + '<td><label class="tog"><input type="checkbox"' + (t.enabled?' checked':'') + ' onchange="toggleTask(' + t.id + ',this.checked)"><span class="tog-s"></span></label></td>'
            + '<td><button type="button" class="pm-btn pm-btn-danger pm-btn-sm" onclick="deleteTask(' + t.id + ')">删除</button></td>'
            + '</tr>';
    }).join('');
}

function showAddTask() {
    var f = document.getElementById('addTaskForm');
    f.style.display = f.style.display === 'none' ? 'block' : 'none';
}
function saveTask() {
    var title = document.getElementById('taskTitle').value.trim();
    var val   = parseInt(document.getElementById('taskValue').value);
    if (!title) { toast('请输入任务名称', true); return; }
    if (isNaN(val) || val <= 0) { toast('请输入有效的奖励值', true); return; }
    var tasks = loadTasks();
    var maxId = tasks.reduce(function(m, t) { return Math.max(m, t.id); }, 0);
    tasks.push({
        id: maxId + 1,
        title: title,
        type: document.getElementById('taskType').value,
        stat: document.getElementById('taskStat').value,
        value: val,
        enabled: true
    });
    saveTasks(tasks);
    renderTasks();
    refreshCompleteTaskSelect();
    document.getElementById('taskTitle').value = '';
    document.getElementById('taskValue').value = '';
    document.getElementById('addTaskForm').style.display = 'none';
    toast('任务已保存 ✅');
}
function toggleTask(id, checked) {
    var tasks = loadTasks();
    tasks.forEach(function(t) { if (t.id === id) t.enabled = checked; });
    saveTasks(tasks);
}
function deleteTask(id) {
    if (!confirm('确定要删除此任务吗？')) return;
    var tasks = loadTasks().filter(function(t) { return t.id !== id; });
    saveTasks(tasks);
    renderTasks();
    refreshCompleteTaskSelect();
    toast('任务已删除');
}
function refreshCompleteTaskSelect() {
    var sel = document.getElementById('completeTask');
    var tasks = loadTasks().filter(function(t) { return t.enabled; });
    sel.innerHTML = tasks.map(function(t) {
        return '<option value="' + t.id + '">[' + TYPE_LABELS[t.type] + '] ' + escHtml(t.title) + '（+' + t.value + ' ' + (STAT_LABELS[t.stat]||t.stat) + '）</option>';
    }).join('');
}
function completeTask() {
    var rid = document.getElementById('completeClass').value;
    var tid = parseInt(document.getElementById('completeTask').value);
    if (!rid) { toast('请选择班级', true); return; }
    var tasks = loadTasks();
    var task = null;
    tasks.forEach(function(t) { if (t.id === tid) task = t; });
    if (!task) { toast('未找到任务', true); return; }
    applyStatChange(rid, task.stat, task.value);
    var clsName = getClassName(rid);
    addEventLog('完成任务：' + task.title, rid, 'pos', '+' + task.value + ' ' + STAT_LABELS[task.stat]);
    renderPetGrid();
    renderStats();
    toast('🎉 ' + clsName + ' 完成任务「' + task.title + '」，宠物获得奖励！');
}

// ============================================================
// 干预
// ============================================================
function loadIntSliders() {
    var rid = document.getElementById('intClass').value;
    if (!rid) return;
    var idx = 0;
    classList.forEach(function(c, i) { if (String(c.id) === String(rid)) idx = i; });
    var p = getPetData(rid, idx);
    document.getElementById('intHP').value    = p.hp;    document.getElementById('intHPVal').textContent  = p.hp;
    document.getElementById('intMood').value  = p.mood;  document.getElementById('intMoodVal').textContent= p.mood;
    document.getElementById('intFood').value  = p.food;  document.getElementById('intFoodVal').textContent= p.food;
    document.getElementById('intClean').value = p.clean; document.getElementById('intCleanVal').textContent=p.clean;
}
function applyIntervention() {
    var rid = document.getElementById('intClass').value;
    if (!rid) { toast('请选择班级', true); return; }
    var hp    = parseInt(document.getElementById('intHP').value);
    var mood  = parseInt(document.getElementById('intMood').value);
    var food  = parseInt(document.getElementById('intFood').value);
    var clean = parseInt(document.getElementById('intClean').value);
    var reason= document.getElementById('intReason').value.trim() || '教师干预';
    var pets = loadPets();
    var key = 'r' + rid;
    var idx = 0;
    classList.forEach(function(c, i) { if (String(c.id) === String(rid)) idx = i; });
    if (!pets[key]) getPetData(rid, idx);
    pets = loadPets();
    pets[key].hp = clamp(hp); pets[key].mood = clamp(mood);
    pets[key].food = clamp(food); pets[key].clean = clamp(clean);
    savePets(pets);
    addEventLog('教师干预：' + reason, rid, 'neu', '已更新属性');
    renderPetGrid();
    renderStats();
    document.getElementById('intReason').value = '';
    toast('✅ 干预已应用，宠物状态已更新');
}

// ============================================================
// 发布事件
// ============================================================
function renderEvtClasses() {
    var el = document.getElementById('evtClasses');
    if (!classList || !classList.length) { el.innerHTML = '<span style="color:#94a3b8;font-size:13px;">暂无班级</span>'; return; }
    el.innerHTML = classList.map(function(c) {
        return '<label style="display:flex;align-items:center;gap:5px;cursor:pointer;font-size:13px;">'
            + '<input type="checkbox" value="' + c.id + '" checked style="accent-color:#6366f1;">'
            + c.name + '</label>';
    }).join('');
}
function publishEvent() {
    var title = document.getElementById('evtTitle').value.trim();
    var desc  = document.getElementById('evtDesc').value.trim();
    var stat  = document.getElementById('evtStat').value;
    var val   = parseInt(document.getElementById('evtValue').value);
    if (!title) { toast('请输入事件标题', true); return; }
    if (isNaN(val)) { toast('请输入有效的变化值', true); return; }

    var checked = [];
    document.querySelectorAll('#evtClasses input[type=checkbox]:checked').forEach(function(cb) {
        checked.push(cb.value);
    });
    if (!checked.length) { toast('请至少选择一个班级', true); return; }

    checked.forEach(function(rid) { applyStatChange(rid, stat, val); });

    var evts = loadEvents();
    evts.unshift({
        id: Date.now(), title: title, desc: desc, stat: stat, value: val,
        classes: checked,
        time: new Date().toLocaleString('zh-CN')
    });
    if (evts.length > 50) evts = evts.slice(0, 50);
    saveEvents(evts);

    var clsNames = checked.map(getClassName).join('、');
    addEventLog('发布事件：' + title, null, val >= 0 ? 'pos' : 'neg',
        (val >= 0 ? '+' : '') + val + ' ' + STAT_LABELS[stat] + ' → ' + clsNames);

    document.getElementById('evtTitle').value = '';
    document.getElementById('evtDesc').value  = '';
    document.getElementById('evtValue').value = '';
    renderPetGrid();
    renderPublishedEvents();
    renderStats();
    toast('📢 事件已发布，影响 ' + checked.length + ' 个班级');
}

function renderPublishedEvents() {
    var evts = loadEvents().filter(function(ev) { return !ev._log; });
    var el = document.getElementById('publishedEvents');
    if (!evts.length) {
        el.innerHTML = '<div class="empty-state"><div class="es-icon">'+_IC.mega+'</div><div class="es-text">暂无发布的事件</div></div>';
        return;
    }
    el.innerHTML = evts.map(function(ev) {
        var dot = ev.value >= 0 ? 'pos' : 'neg';
        var clsList = Array.isArray(ev.classes) ? ev.classes : [];
        var clsNames = clsList.length ? clsList.map(getClassName).join('、') : '未指定班级';
        return '<div class="ev-item">'
            + '<div class="ev-dot ' + dot + '"></div>'
            + '<div class="ev-content">'
            + '<div class="ev-title">' + escHtml(ev.title) + '</div>'
            + '<div class="ev-meta">' + ev.time + ' · 影响：' + escHtml(clsNames) + '</div>'
            + '</div>'
            + '<div class="ev-effect"><span class="tag ' + (ev.value>=0?'tag-green':'tag-red') + '">'
            + (ev.value>=0?'+':'') + ev.value + ' ' + (STAT_LABELS[ev.stat]||ev.stat) + '</span></div>'
            + '</div>';
    }).join('');
}

// ============================================================
// 事件日志
// ============================================================
function addEventLog(action, rid, type, effect) {
    var logs = loadEvents();
    var clsName = rid ? getClassName(rid) : '';
    logs.unshift({
        id: Date.now(), _log: true,
        title: action + (clsName ? ' · ' + clsName : ''),
        effect: effect,
        type: type,
        time: new Date().toLocaleTimeString('zh-CN', {hour:'2-digit', minute:'2-digit'})
    });
    if (logs.length > 100) logs = logs.slice(0, 100);
    saveEvents(logs);
    renderEventLog();
}
function renderEventLog() {
    var all = loadEvents();
    var logs = all.filter(function(e) { return e._log; }).slice(0, 30);
    var el = document.getElementById('eventLog');
    if (!logs.length) {
        el.innerHTML = '<div class="empty-state"><div class="es-icon">'+_IC.clip+'</div><div class="es-text">暂无行为记录</div></div>';
        return;
    }
    el.innerHTML = logs.map(function(e) {
        return '<div class="ev-item">'
            + '<div class="ev-dot ' + e.type + '"></div>'
            + '<div class="ev-content">'
            + '<div class="ev-title">' + escHtml(e.title) + '</div>'
            + '<div class="ev-meta">' + e.time + '</div>'
            + '</div>'
            + '<div class="ev-effect"><span style="font-size:12px;color:#64748b;">' + escHtml(e.effect) + '</span></div>'
            + '</div>';
    }).join('');
}
function clearEventLog() {
    if (!confirm('确定要清空所有行为记录吗？')) return;
    var evts = loadEvents().filter(function(e) { return !e._log; });
    saveEvents(evts);
    renderEventLog();
    toast('行为记录已清空');
}

// ============================================================
// 统计分析
// ============================================================
function renderStats() {
    if (!classList || !classList.length) return;

    // HP 对比图
    var hpDiv = document.getElementById('chartHP');
    hpDiv.innerHTML = classList.map(function(cls, idx) {
        var p = getPetData(cls.id, idx);
        var color = p.hp >= 70 ? '#10b981' : p.hp >= 40 ? '#f59e0b' : '#ef4444';
        return '<div class="chart-row">'
            + '<div class="chart-lbl">' + cls.name + '</div>'
            + '<div class="chart-track"><div class="chart-fill" style="width:' + p.hp + '%;background:' + color + ';"></div></div>'
            + '<div class="chart-val">' + p.hp + '</div>'
            + '</div>';
    }).join('');

    // Mood 对比图
    var moodDiv = document.getElementById('chartMood');
    moodDiv.innerHTML = classList.map(function(cls, idx) {
        var p = getPetData(cls.id, idx);
        var color = p.mood >= 70 ? '#6366f1' : p.mood >= 40 ? '#a78bfa' : '#c4b5fd';
        return '<div class="chart-row">'
            + '<div class="chart-lbl">' + cls.name + '</div>'
            + '<div class="chart-track"><div class="chart-fill" style="width:' + p.mood + '%;background:' + color + ';"></div></div>'
            + '<div class="chart-val">' + p.mood + '</div>'
            + '</div>';
    }).join('');

    // 数据表格
    var tbody = document.getElementById('statsTbody');
    tbody.innerHTML = classList.map(function(cls, idx) {
        var p = getPetData(cls.id, idx);
        var s = getPetState(p);
        var badge = s.cls === 'happy'   ? '<span class="tag tag-green">开心</span>'
                  : s.cls === 'neutral' ? '<span class="tag tag-amber">一般</span>'
                  :                       '<span class="tag tag-red">需关注</span>';
        return '<tr>'
            + '<td>' + cls.name + '</td>'
            + '<td>' + p.emoji + ' ' + p.name + '</td>'
            + '<td><strong>' + p.level + '</strong></td>'
            + '<td>' + hpBar(p.hp) + '</td>'
            + '<td>' + moodBar(p.mood) + '</td>'
            + '<td>' + badge + '</td>'
            + '</tr>';
    }).join('');
}
function hpBar(v) {
    var c = v >= 70 ? '#10b981' : v >= 40 ? '#f59e0b' : '#ef4444';
    return '<div style="display:flex;align-items:center;gap:5px;">'
        + '<div style="flex:1;height:6px;background:#f1f5f9;border-radius:3px;overflow:hidden;min-width:60px;">'
        + '<div style="width:' + v + '%;height:100%;background:' + c + ';border-radius:3px;"></div></div>'
        + '<span style="font-size:12px;font-weight:600;color:#334155;">' + v + '</span></div>';
}
function moodBar(v) {
    var c = v >= 70 ? '#6366f1' : v >= 40 ? '#a78bfa' : '#c4b5fd';
    return '<div style="display:flex;align-items:center;gap:5px;">'
        + '<div style="flex:1;height:6px;background:#f1f5f9;border-radius:3px;overflow:hidden;min-width:60px;">'
        + '<div style="width:' + v + '%;height:100%;background:' + c + ';border-radius:3px;"></div></div>'
        + '<span style="font-size:12px;font-weight:600;color:#334155;">' + v + '</span></div>';
}

// ============================================================
// 工具
// ============================================================
function getClassName(rid) {
    var name = '未知班级';
    classList.forEach(function(c) { if (String(c.id) === String(rid)) name = c.name; });
    return name;
}
function escHtml(s) {
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
var _pmToastTimer = 0;
function toast(msg, isErr) {
    var el = document.getElementById('pmToast');
    var mask = document.getElementById('pmToastMask');
    var txt = document.getElementById('pmToastText');
    if (!el || !mask || !txt) return;
    if (_pmToastTimer) {
        clearTimeout(_pmToastTimer);
        _pmToastTimer = 0;
    }
    txt.textContent = msg;
    if (isErr) el.classList.add('error');
    else el.classList.remove('error');
    mask.classList.add('show');
    el.classList.add('show');
    _pmToastTimer = setTimeout(function() {
        el.classList.remove('show');
        mask.classList.remove('show');
    }, 2200);
}

// ============================================================
// 评分管理同步规则
// ============================================================
var SYNC_STAT_KEY = 'ls_attype_stat_v1';
var _syncRulesLoaded = false, _syncRulesLoading = false;
var _syncedTypes = [], _srTid = 0, _srScore = 0, _srName = '', _srStat = '';
function loadSyncRuleStat(tid) {
    try { var m = JSON.parse(localStorage.getItem(SYNC_STAT_KEY)) || {}; return m['t' + tid] || ''; } catch(e) { return ''; }
}
function saveSyncRuleStat(tid, stat) {
    try { var m = JSON.parse(localStorage.getItem(SYNC_STAT_KEY)) || {}; m['t' + tid] = stat; localStorage.setItem(SYNC_STAT_KEY, JSON.stringify(m)); } catch(e) {}
}
function loadSyncedRules(force) {
    if (_syncRulesLoading) return;
    if (_syncRulesLoaded && !force) return;
    _syncRulesLoading = true;
    var wrap = document.getElementById('syncRulesWrap');
    if (wrap) wrap.innerHTML = '<div style="color:#94a3b8;font-size:13px;padding:16px 0;">正在从服务器同步...</div>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'attitudecatajax.ashx?action=list_types&_=' + Date.now(), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        _syncRulesLoading = false;
        if (xhr.status === 200) {
            try {
                var res = JSON.parse(xhr.responseText);
                if (res.success) { _syncRulesLoaded = true; renderSyncedRules(res.data || []); }
                else { if (wrap) wrap.innerHTML = '<div style="color:#ef4444;font-size:13px;padding:12px 0;">加载失败：' + escHtml(res.msg || '未知错误') + '</div>'; }
            } catch(e) { if (wrap) wrap.innerHTML = '<div style="color:#ef4444;font-size:13px;padding:12px 0;">数据解析错误，请检查服务器配置</div>'; }
        } else { if (wrap) wrap.innerHTML = '<div style="color:#ef4444;font-size:13px;padding:12px 0;">请求失败（HTTP ' + xhr.status + '）</div>'; }
    };
    xhr.send();
}
function renderSyncedRules(types) {
    _syncedTypes = types;
    var wrap = document.getElementById('syncRulesWrap');
    if (!wrap) return;
    if (!types || !types.length) {
        wrap.innerHTML = '<div class="empty-state"><div class="es-icon"><svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div><div class="es-text">评分管理暂无数据，请先在“评分管理”页面添加评分类型</div></div>';
        return;
    }
    var html = '<div style="overflow-x:auto;"><table class="pm-table"><thead><tr><th>行为名称</th><th>分值</th><th>状态</th><th>影响宠物属性</th><th>操作</th></tr></thead><tbody>';
    types.forEach(function(t) {
        var stat = loadSyncRuleStat(t.id) || (t.score >= 0 ? 'mood' : 'hp');
        var scoreTag = t.score > 0 ? '<span class="tag tag-green">+' + t.score + '</span>' : t.score < 0 ? '<span class="tag tag-red">' + t.score + '</span>' : '<span class="tag tag-blue">±0</span>';
        var statusBadge = t.active ? '<span class="tag tag-green">启用</span>' : '<span class="tag tag-amber">停用</span>';
        var dot = t.color ? '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:' + escHtml(t.color) + ';margin-right:5px;vertical-align:middle;"></span>' : '';
        var opts = ['hp','mood','food','clean','exp'].map(function(v) { return '<option value="' + v + '"' + (stat===v?' selected':'') + '>' + (STAT_LABELS[v]||v) + '</option>'; }).join('');
        var applyBtn = t.active ? '<button type="button" class="pm-btn pm-btn-sm pm-btn-primary" onclick="applySyncRule(' + t.id + ')">应用至班级</button>' : '<span style="color:#94a3b8;font-size:12px;">已停用</span>';
        html += '<tr><td>' + dot + '<strong>' + escHtml(t.name) + '</strong></td><td>' + scoreTag + '</td><td>' + statusBadge + '</td>'
            + '<td><select class="pm-select" style="padding:5px 8px;font-size:12px;width:auto;min-width:80px;" id="sr_stat_' + t.id + '" onchange="saveSyncRuleStat(' + t.id + ',this.value)">' + opts + '</select></td>'
            + '<td>' + applyBtn + '</td></tr>';
    });
    html += '</tbody></table></div>';
    wrap.innerHTML = html;
}
function applySyncRule(tid) {
    var t = null;
    for (var i = 0; i < _syncedTypes.length; i++) { if (_syncedTypes[i].id == tid) { t = _syncedTypes[i]; break; } }
    if (!t) return;
    _srTid = t.id; _srScore = t.score; _srName = t.name;
    var statEl = document.getElementById('sr_stat_' + tid);
    _srStat = statEl ? statEl.value : (t.score >= 0 ? 'mood' : 'hp');
    document.getElementById('srModalTitle').textContent = '应用规则：' + t.name;
    document.getElementById('srModalInfo').textContent = '分值 ' + (_srScore >= 0 ? '+' : '') + _srScore + '  →  影响属性：' + (STAT_LABELS[_srStat] || _srStat);
    var html = '<label class="sr-cls-label"><input type="checkbox" id="sr_all_cb" onchange="toggleAllSR(this.checked)" style="accent-color:#6366f1;">全部班级</label>';
    html += classList.map(function(c) { return '<label class="sr-cls-label"><input type="checkbox" class="sr_cls_cb" value="' + c.id + '" checked style="accent-color:#6366f1;">' + escHtml(c.name) + '</label>'; }).join('');
    document.getElementById('srClsGrid').innerHTML = html || '<span style="color:#94a3b8;font-size:12px;">暂无班级</span>';
    document.getElementById('srOverlay').style.display = 'block';
    document.getElementById('srModal').style.display = 'block';
}
function closeApplySR() {
    document.getElementById('srOverlay').style.display = 'none';
    document.getElementById('srModal').style.display = 'none';
}
function toggleAllSR(checked) {
    document.querySelectorAll('.sr_cls_cb').forEach(function(cb) { cb.checked = checked; });
}
function confirmApplySR() {
    var checked = [];
    document.querySelectorAll('.sr_cls_cb:checked').forEach(function(cb) { checked.push(cb.value); });
    if (!checked.length) { toast('请至少选择一个班级', true); return; }
    checked.forEach(function(rid) {
        applyStatChange(rid, _srStat, _srScore);
        addEventLog('触发规则：' + _srName, rid, _srScore >= 0 ? 'pos' : 'neg', (_srScore >= 0 ? '+' : '') + _srScore + ' ' + (STAT_LABELS[_srStat] || _srStat));
    });
    renderPetGrid();
    closeApplySR();
    toast((checked.length > 1 ? checked.length + ' 个班级已应用规则' : '规则已应用') + ' ✅');
}

// ============================================================
// 标签切换
// ============================================================
var PM_PANELS = ['tab0','tab1','tab2','tab3','tab4'];
function switchTab(idx) {
    // 限定在 .pm-tabs 容器内查找 tab 按钮，避免 master page 同类名干扰
    var tabs = document.querySelectorAll('.pm-tabs .pm-tab');
    for (var ti = 0; ti < tabs.length; ti++) {
        if (tabs[ti].classList) {
            if (ti === idx) tabs[ti].classList.add('active');
            else            tabs[ti].classList.remove('active');
        }
    }
    // 直接用 ID 切换面板，彻底排除索引偏移
    for (var pi = 0; pi < PM_PANELS.length; pi++) {
        var panel = document.getElementById(PM_PANELS[pi]);
        if (!panel) continue;
        if (pi === idx) panel.classList.add('active');
        else            panel.classList.remove('active');
    }
    if (idx === 4) renderStats();
    if (idx === 1) loadSyncedRules();
}

// ============================================================
// 干预区域：校区→年级→班级联动（与 start.aspx 保持一致）
// ============================================================
function buildIntSelects() {
    var schoolSel = document.getElementById('intSchool');
    if (!schoolSel) return;

    // 直接使用服务端注入的 schoolsList（与 start.aspx 相同数据源）
    var opts = '<option value="">全部校区</option>';
    if (schoolsList && schoolsList.length) {
        schoolsList.forEach(function(s) {
            opts += '<option value="' + s.id + '">' + escHtml(s.name) + '</option>';
        });
    }
    schoolSel.innerHTML = opts;

    buildIntGrades('');
}

function buildIntGrades(schoolId) {
    // 仅当 classList 实际有 schoolId 数据且指定了校区时才过滤
    var useSchoolFilter = _clsHasSchoolId && !!schoolId;
    var grades = [];
    classList.forEach(function(c) {
        var matchSchool = !useSchoolFilter || String(c.schoolId) === schoolId;
        if (matchSchool && grades.indexOf(c.grade) < 0) grades.push(c.grade);
    });
    grades.sort(function(a, b) { return parseInt(a) - parseInt(b) || (a < b ? -1 : a > b ? 1 : 0); });

    var gradeSel = document.getElementById('intGrade');
    if (!gradeSel) return;
    var opts = '<option value="">\u5168\u90e8\u5e74\u7ea7</option>';
    grades.forEach(function(g) {
        // 防止 Rgrade 已含「\u5e74\u7ea7\u300d导致显示重复
        var lbl = /\u5e74\u7ea7/.test(g) ? g : g + '\u5e74\u7ea7';
        opts += '<option value="' + g + '">' + escHtml(lbl) + '</option>';
    });
    gradeSel.innerHTML = opts;

    buildIntClasses(schoolId, '');
}

function buildIntClasses(schoolId, grade) {
    var classSel = document.getElementById('intClass');
    if (!classSel) return;
    var useSchoolFilter = _clsHasSchoolId && !!schoolId;
    var opts = '';
    classList.forEach(function(c) {
        var matchSchool = !useSchoolFilter || String(c.schoolId) === schoolId;
        var matchGrade  = !grade || String(c.grade) === grade;
        if (matchSchool && matchGrade)
            opts += '<option value="' + c.id + '">' + escHtml(c.name) + '</option>';
    });
    classSel.innerHTML = opts || '<option value="">\u6682\u65e0\u73ed\u7ea7</option>';
    loadIntSliders();
}

function onIntSchoolChange() {
    buildIntGrades(document.getElementById('intSchool').value);
}
function onIntGradeChange() {
    buildIntClasses(
        document.getElementById('intSchool').value,
        document.getElementById('intGrade').value
    );
}

// ============================================================
// 初始化类选择器
// ============================================================
function initClassSelects() {
    // 干预区：三级联动
    buildIntSelects();

    // 任务完成区：平铺所有班级
    var completeClassSel = document.getElementById('completeClass');
    if (completeClassSel) {
        completeClassSel.innerHTML = classList.map(function(c) {
            return '<option value="' + c.id + '">' + escHtml(c.name) + '</option>';
        }).join('');
    }
}

// ============================================================
// 入口
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    // 确保默认数据写入
    if (!localStorage.getItem(RULES_KEY)) saveRules(getDefaultRules());
    if (!localStorage.getItem(TASKS_KEY)) saveTasks(getDefaultTasks());

    renderPetGrid();
    renderRules();
    renderTasks();
    renderEventLog();
    renderPublishedEvents();
    renderEvtClasses();
    initClassSelects();
    refreshCompleteTaskSelect();

    if (classList.length > 0) {
        loadIntSliders();
    }
});
</script>
<!-- Apply Synced Rule Modal -->
<div class="sr-overlay" id="srOverlay" onclick="closeApplySR()"></div>
<div class="sr-modal" id="srModal">
    <div class="sr-modal-title" id="srModalTitle">应用规则</div>
    <div class="sr-modal-info" id="srModalInfo"></div>
    <div style="font-size:12px;font-weight:600;color:#374151;margin-bottom:8px;">选择应用班级</div>
    <div class="sr-cls-grid" id="srClsGrid"></div>
    <div style="display:flex;gap:10px;flex-wrap:wrap;">
        <button type="button" class="pm-btn pm-btn-primary" onclick="confirmApplySR()">
            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
            确认应用
        </button>
        <button type="button" class="pm-btn pm-btn-outline" onclick="closeApplySR()">取消</button>
    </div>
</div>
</asp:Content>
