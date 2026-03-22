<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                    cs = connField.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
            cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    protected int totalStudents = 0;
    protected int totalTeachers = 0;
    protected int totalRooms = 0;
    protected int totalCourses = 0;
    protected int totalWorks = 0;
    protected int totalSignins = 0;
    protected bool dbOk = true;
    protected DataTable gradeDistribution = new DataTable();
    protected DataTable recentCourses = new DataTable();
    protected int maxGradeCount = 1;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDashboardData();
        }
    }

    private int SafeCount(SqlConnection conn, string sql)
    {
        try
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    return Convert.ToInt32(result);
            }
        }
        catch { }
        return 0;
    }

    private void LoadDashboardData()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(GetConnStr()))
            {
                conn.Open();
                dbOk = true;

                // 基础统计
                totalStudents = SafeCount(conn, "SELECT COUNT(*) FROM Students");
                totalTeachers = SafeCount(conn, "SELECT COUNT(*) FROM Teacher WHERE Hdelete=0 OR Hdelete IS NULL");
                totalRooms = SafeCount(conn, "SELECT COUNT(*) FROM Room");
                totalCourses = SafeCount(conn, "SELECT COUNT(*) FROM Courses WHERE Cdelete=0 OR Cdelete IS NULL");
                totalWorks = SafeCount(conn, "SELECT COUNT(*) FROM Works");
                totalSignins = SafeCount(conn, "SELECT COUNT(*) FROM Signin");

                // 年级分布
                try
                {
                    string gradeSql = @"SELECT Sgrade AS Grade, COUNT(*) AS Cnt 
                        FROM Students 
                        GROUP BY Sgrade ORDER BY Sgrade";
                    using (SqlDataAdapter da = new SqlDataAdapter(gradeSql, conn))
                    {
                        da.Fill(gradeDistribution);
                    }
                    foreach (DataRow row in gradeDistribution.Rows)
                    {
                        int cnt = Convert.ToInt32(row["Cnt"]);
                        if (cnt > maxGradeCount) maxGradeCount = cnt;
                    }
                }
                catch { }

                // 最近课程
                try
                {
                    string recentSql = @"SELECT TOP 8 C.Ctitle, C.Cdate, T.Hname 
                        FROM Courses C LEFT JOIN Teacher T ON C.Chid = T.hid 
                        WHERE (C.Cdelete=0 OR C.Cdelete IS NULL) 
                        ORDER BY C.Cid DESC";
                    using (SqlDataAdapter da = new SqlDataAdapter(recentSql, conn))
                    {
                        da.Fill(recentCourses);
                    }
                }
                catch { }
            }
        }
        catch
        {
            dbOk = false;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .db-page{max-width:100%;padding:20px 24px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .db-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .db-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#a78bfa);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .db-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .db-hd h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .db-hd p{font-size:13px;color:#94a3b8;margin:0;}

    /* 数据库不可用警告 */
    .db-warn{background:#fef3c7;border:1px solid #fbbf24;border-radius:10px;padding:12px 18px;margin-bottom:18px;display:flex;align-items:center;gap:10px;font-size:13px;color:#92400e;}
    .db-warn svg{width:20px;height:20px;stroke:#f59e0b;fill:none;stroke-width:2;flex-shrink:0;stroke-linecap:round;stroke-linejoin:round;}

    /* 统计卡片网格 */
    .stat-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:24px;}
    @media(max-width:1100px){.stat-grid{grid-template-columns:repeat(2,1fr);}}
    @media(max-width:600px){.stat-grid{grid-template-columns:1fr;}}

    .stat-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;padding:20px 22px;display:flex;align-items:center;gap:16px;transition:box-shadow .25s,transform .25s;box-shadow:0 1px 4px rgba(0,0,0,.04);}
    .stat-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .stat-icon{width:52px;height:52px;border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .stat-icon svg{width:26px;height:26px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .stat-icon.indigo{background:linear-gradient(135deg,#eef2ff,#e0e7ff);} .stat-icon.indigo svg{stroke:#6366f1;}
    .stat-icon.sky{background:linear-gradient(135deg,#f0f9ff,#e0f2fe);} .stat-icon.sky svg{stroke:#0ea5e9;}
    .stat-icon.emerald{background:linear-gradient(135deg,#ecfdf5,#d1fae5);} .stat-icon.emerald svg{stroke:#10b981;}
    .stat-icon.amber{background:linear-gradient(135deg,#fffbeb,#fef3c7);} .stat-icon.amber svg{stroke:#f59e0b;}
    .stat-icon.rose{background:linear-gradient(135deg,#fff1f2,#ffe4e6);} .stat-icon.rose svg{stroke:#f43f5e;}
    .stat-icon.violet{background:linear-gradient(135deg,#f5f3ff,#ede9fe);} .stat-icon.violet svg{stroke:#8b5cf6;}
    .stat-info{flex:1;min-width:0;}
    .stat-label{font-size:12.5px;color:#94a3b8;font-weight:500;margin-bottom:4px;}
    .stat-value{font-size:28px;font-weight:800;color:#0f172a;line-height:1.1;}
    .stat-unit{font-size:14px;font-weight:500;color:#94a3b8;margin-left:4px;}

    /* 内容网格 */
    .content-grid{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
    @media(max-width:900px){.content-grid{grid-template-columns:1fr;}}

    .db-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .db-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .db-card.full{grid-column:1/-1;}
    .db-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .db-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .db-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.indigo{background:#eef2ff;} .ci.indigo svg{stroke:#6366f1;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .db-card-bd{padding:20px 22px;}

    /* 柱状图 */
    .bar-chart{display:flex;align-items:flex-end;gap:12px;height:180px;padding:0 4px;}
    .bar-col{flex:1;display:flex;flex-direction:column;align-items:center;gap:6px;min-width:0;}
    .bar-val{font-size:11px;font-weight:700;color:#475569;}
    .bar-fill{width:100%;max-width:48px;border-radius:8px 8px 4px 4px;transition:height .6s ease;position:relative;min-height:4px;}
    .bar-fill:hover{filter:brightness(1.1);transform:scaleX(1.05);}
    .bar-label{font-size:11px;color:#94a3b8;font-weight:500;white-space:nowrap;margin-top:2px;}
    .bar-colors-0{background:linear-gradient(180deg,#818cf8,#6366f1);}
    .bar-colors-1{background:linear-gradient(180deg,#38bdf8,#0ea5e9);}
    .bar-colors-2{background:linear-gradient(180deg,#34d399,#10b981);}
    .bar-colors-3{background:linear-gradient(180deg,#fbbf24,#f59e0b);}
    .bar-colors-4{background:linear-gradient(180deg,#fb7185,#f43f5e);}
    .bar-colors-5{background:linear-gradient(180deg,#a78bfa,#8b5cf6);}
    .bar-colors-6{background:linear-gradient(180deg,#60a5fa,#3b82f6);}
    .bar-colors-7{background:linear-gradient(180deg,#2dd4bf,#14b8a6);}
    .bar-empty{text-align:center;padding:40px;color:#94a3b8;font-size:13px;}

    /* 最近课程列表 */
    .recent-list{list-style:none;padding:0;margin:0;}
    .recent-item{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid #f1f5f9;}
    .recent-item:last-child{border-bottom:none;}
    .recent-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0;}
    .recent-dot.c0{background:#6366f1;} .recent-dot.c1{background:#0ea5e9;} .recent-dot.c2{background:#10b981;} .recent-dot.c3{background:#f59e0b;}
    .recent-dot.c4{background:#f43f5e;} .recent-dot.c5{background:#8b5cf6;} .recent-dot.c6{background:#3b82f6;} .recent-dot.c7{background:#14b8a6;}
    .recent-title{flex:1;font-size:13px;color:#1e293b;font-weight:500;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;min-width:0;}
    .recent-meta{font-size:11.5px;color:#94a3b8;white-space:nowrap;}
    .recent-teacher{font-size:11.5px;color:#6366f1;background:#eef2ff;padding:2px 8px;border-radius:6px;white-space:nowrap;}

    /* 快速操作 */
    .quick-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;}
    @media(max-width:600px){.quick-grid{grid-template-columns:repeat(2,1fr);}}
    .quick-link{display:flex;flex-direction:column;align-items:center;gap:8px;padding:16px 10px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;text-decoration:none;transition:all .2s;cursor:pointer;}
    .quick-link:hover{background:#eef2ff;border-color:#c7d2fe;transform:translateY(-2px);box-shadow:0 4px 12px rgba(99,102,241,.1);}
    .quick-link .qi{width:40px;height:40px;border-radius:12px;display:flex;align-items:center;justify-content:center;}
    .quick-link .qi svg{width:20px;height:20px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .qi.q-indigo{background:#eef2ff;} .qi.q-indigo svg{stroke:#6366f1;}
    .qi.q-sky{background:#f0f9ff;} .qi.q-sky svg{stroke:#0ea5e9;}
    .qi.q-emerald{background:#ecfdf5;} .qi.q-emerald svg{stroke:#10b981;}
    .qi.q-amber{background:#fffbeb;} .qi.q-amber svg{stroke:#f59e0b;}
    .qi.q-rose{background:#fff1f2;} .qi.q-rose svg{stroke:#f43f5e;}
    .qi.q-violet{background:#f5f3ff;} .qi.q-violet svg{stroke:#8b5cf6;}
    .quick-link span{font-size:12px;color:#475569;font-weight:500;}

</style>

<div class="db-page">
    <!-- 页头 -->
    <div class="db-hd">
        <div class="db-hd-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/></svg>
        </div>
        <div>
            <h1>数据仪表盘</h1>
            <p>实时查看平台运行数据与统计概览</p>
        </div>
    </div>

    <% if (!dbOk) { %>
    <div class="db-warn">
        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        数据库连接不可用，统计数据无法加载。请检查数据库连接配置。
    </div>
    <% } %>

    <!-- 统计卡片 -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-icon indigo">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-label">学生总数</div>
                <div class="stat-value"><%= totalStudents %><span class="stat-unit">人</span></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon sky">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-label">教师总数</div>
                <div class="stat-value"><%= totalTeachers %><span class="stat-unit">人</span></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon emerald">
                <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-label">班级总数</div>
                <div class="stat-value"><%= totalRooms %><span class="stat-unit">个</span></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber">
                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-label">课程/学案</div>
                <div class="stat-value"><%= totalCourses %><span class="stat-unit">个</span></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon rose">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-label">学生作品</div>
                <div class="stat-value"><%= totalWorks %><span class="stat-unit">份</span></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon violet">
                <svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            </div>
            <div class="stat-info">
                <div class="stat-label">签到记录</div>
                <div class="stat-value"><%= totalSignins %><span class="stat-unit">次</span></div>
            </div>
        </div>
    </div>

    <!-- 图表 + 快速操作 -->
    <div class="content-grid">

        <!-- 年级分布 -->
        <div class="db-card">
            <div class="db-card-hd">
                <span class="ci indigo"><svg viewBox="0 0 24 24"><rect x="18" y="3" width="4" height="18" rx="1"/><rect x="11" y="9" width="4" height="12" rx="1"/><rect x="4" y="13" width="4" height="8" rx="1"/></svg></span>
                各年级学生分布
            </div>
            <div class="db-card-bd">
                <% if (gradeDistribution.Rows.Count > 0) { %>
                <div class="bar-chart">
                    <% for (int i = 0; i < gradeDistribution.Rows.Count; i++) {
                        DataRow row = gradeDistribution.Rows[i];
                        int cnt = Convert.ToInt32(row["Cnt"]);
                        int grade = Convert.ToInt32(row["Grade"]);
                        double pct = (double)cnt / maxGradeCount * 100;
                        int colorIdx = i % 8;
                    %>
                    <div class="bar-col">
                        <div class="bar-val"><%= cnt %></div>
                        <div class="bar-fill bar-colors-<%= colorIdx %>" style="height:<%= pct.ToString("F0") %>%;"></div>
                        <div class="bar-label"><%= grade %>年级</div>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="bar-empty">暂无年级分布数据</div>
                <% } %>
            </div>
        </div>

        <!-- 快速操作 -->
        <div class="db-card">
            <div class="db-card-hd">
                <span class="ci emerald"><svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg></span>
                快速操作
            </div>
            <div class="db-card-bd">
                <div class="quick-grid">
                    <a href="../manager/setting.aspx" class="quick-link">
                        <div class="qi q-indigo"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09"/></svg></div>
                        <span>系统设置</span>
                    </a>
                    <a href="../manager/createroom.aspx" class="quick-link">
                        <div class="qi q-sky"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
                        <span>班级设置</span>
                    </a>
                    <a href="../manager/teacher.aspx" class="quick-link">
                        <div class="qi q-emerald"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
                        <span>教师管理</span>
                    </a>
                    <a href="../manager/studentimport.aspx" class="quick-link">
                        <div class="qi q-amber"><svg viewBox="0 0 24 24"><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/><path d="M3 21V3"/></svg></div>
                        <span>新生导入</span>
                    </a>
                    <a href="../manager/backup.aspx" class="quick-link">
                        <div class="qi q-rose"><svg viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg></div>
                        <span>数据备份</span>
                    </a>
                    <a href="../manager/index.aspx" class="quick-link">
                        <div class="qi q-violet"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></div>
                        <span>系统总览</span>
                    </a>
                </div>
            </div>
        </div>

        <!-- 最近课程 -->
        <div class="db-card full">
            <div class="db-card-hd">
                <span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                最近发布的课程
            </div>
            <div class="db-card-bd">
                <% if (recentCourses.Rows.Count > 0) { %>
                <ul class="recent-list">
                    <% for (int i = 0; i < recentCourses.Rows.Count; i++) {
                        DataRow row = recentCourses.Rows[i];
                        string title = row["Ctitle"] != DBNull.Value ? row["Ctitle"].ToString() : "(无标题)";
                        string date = row["Cdate"] != DBNull.Value ? Convert.ToDateTime(row["Cdate"]).ToString("MM-dd HH:mm") : "";
                        string teacher = row["Hname"] != DBNull.Value ? row["Hname"].ToString() : "";
                        int colorIdx = i % 8;
                    %>
                    <li class="recent-item">
                        <span class="recent-dot c<%= colorIdx %>"></span>
                        <span class="recent-title"><%= Server.HtmlEncode(title) %></span>
                        <% if (!string.IsNullOrEmpty(teacher)) { %>
                        <span class="recent-teacher"><%= Server.HtmlEncode(teacher) %></span>
                        <% } %>
                        <span class="recent-meta"><%= date %></span>
                    </li>
                    <% } %>
                </ul>
                <% } else { %>
                <div class="bar-empty">暂无课程数据</div>
                <% } %>
            </div>
        </div>

    </div>
</div>

<script type="text/javascript">
// 柱状图入场动画
(function(){
    var bars = document.querySelectorAll('.bar-fill');
    for(var i = 0; i < bars.length; i++){
        (function(bar, idx){
            var h = bar.style.height;
            bar.style.height = '0%';
            setTimeout(function(){ bar.style.height = h; }, 100 + idx * 80);
        })(bars[i], i);
    }
})();
</script>
</asp:Content>
