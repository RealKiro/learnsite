<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";

    // 统计数据
    protected int statTotal = 0;
    protected int statSubmitted = 0;
    protected double statAvg = 0;
    protected int statMax = 0;
    protected int statMin = 0;
    protected double statPassRate = 0;
    protected int statExcellent = 0;
    protected int statGood = 0;
    protected int statPass = 0;
    protected int statFail = 0;
    protected int statPaperScore = 100;

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
            EnsureTables();
            LoadExams();
            BindScores();
        }
    }

    private void EnsureTables()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='ExamScore' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[ExamScore](
                            [ESid] [int] IDENTITY(1,1) NOT NULL,
                            [ESeid] [int] NULL,
                            [ESpid] [int] NULL,
                            [ESsid] [int] NULL,
                            [ESscore] [int] NULL DEFAULT(0),
                            [ESgraded] [int] NULL DEFAULT(0),
                            [ESdate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([ESid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
            }
        }
        catch { }
    }

    private void LoadExams()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT ep.Eid, ep.Egrade, ep.Eclass,
                    ISNULL(p.Ptitle,'[已删除]') AS Ptitle, ISNULL(p.Pscore,0) AS Pscore, ISNULL(p.Pcount,0) AS Pcount
                    FROM ExamPublish ep LEFT JOIN Paper p ON ep.Epid=p.Pid
                    WHERE ep.Ehid=@hid ORDER BY ep.Edate DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLexam.Items.Clear();
                    DDLexam.Items.Add(new System.Web.UI.WebControls.ListItem("-- 请选择考试 --", "0"));
                    while (dr.Read())
                    {
                        string text = dr["Ptitle"].ToString() + " (" + dr["Egrade"] + "年级" + dr["Eclass"] + "班 / " + dr["Pscore"] + "分)";
                        DDLexam.Items.Add(new System.Web.UI.WebControls.ListItem(text, dr["Eid"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    protected void DDLexam_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindScores();
    }

    private void BindScores()
    {
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (eid <= 0)
        {
            RptScores.DataSource = null; RptScores.DataBind();
            statTotal = 0; statSubmitted = 0;
            return;
        }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 获取试卷满分
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(p.Pscore,100) FROM ExamPublish ep LEFT JOIN Paper p ON ep.Epid=p.Pid WHERE ep.Eid=@eid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    object v = cmd.ExecuteScalar();
                    if (v != null && v != DBNull.Value) statPaperScore = Convert.ToInt32(v);
                }
                if (statPaperScore <= 0) statPaperScore = 100;

                // 获取学生成绩列表
                string sql = @"SELECT s.Sid, s.Snum, s.Sname, s.Sgrade, s.Sclass,
                    ISNULL(es.ESscore, -1) AS Score,
                    ISNULL(es.ESgraded, 0) AS Graded,
                    (SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=s.Sid) AS AnswerCount
                    FROM Students s
                    INNER JOIN ExamPublish ep ON s.Sgrade=ep.Egrade AND s.Sclass=ep.Eclass
                    LEFT JOIN ExamScore es ON es.ESeid=@eid AND es.ESsid=s.Sid
                    WHERE ep.Eid=@eid
                    ORDER BY ISNULL(es.ESscore,0) DESC, s.Snum";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@eid", eid);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // 添加排名列
                dt.Columns.Add("Rank", typeof(int));
                int rank = 0;
                foreach (DataRow row in dt.Rows)
                {
                    rank++;
                    row["Rank"] = rank;
                }

                RptScores.DataSource = dt;
                RptScores.DataBind();

                // 计算统计数据
                statTotal = dt.Rows.Count;
                double passLine = statPaperScore * 0.6;
                double goodLine = statPaperScore * 0.8;
                double excellentLine = statPaperScore * 0.9;

                System.Collections.Generic.List<int> scores = new System.Collections.Generic.List<int>();
                foreach (DataRow row in dt.Rows)
                {
                    int sc = Convert.ToInt32(row["Score"]);
                    int ac = Convert.ToInt32(row["AnswerCount"]);
                    if (ac > 0 && sc >= 0)
                    {
                        scores.Add(sc);
                        if (sc >= excellentLine) statExcellent++;
                        else if (sc >= goodLine) statGood++;
                        else if (sc >= passLine) statPass++;
                        else statFail++;
                    }
                }
                statSubmitted = scores.Count;
                if (scores.Count > 0)
                {
                    int sumScore = 0; int maxS = 0; int minS = int.MaxValue;
                    for (int i = 0; i < scores.Count; i++)
                    {
                        sumScore += scores[i];
                        if (scores[i] > maxS) maxS = scores[i];
                        if (scores[i] < minS) minS = scores[i];
                    }
                    statAvg = Math.Round((double)sumScore / scores.Count, 1);
                    statMax = maxS;
                    statMin = minS;
                    statPassRate = Math.Round((double)(statExcellent + statGood + statPass) / scores.Count * 100, 1);
                }
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; pageMsgType = "error"; }
    }

    // ========== 导出 Excel ==========
    protected void BtnExport_Click(object sender, EventArgs e)
    {
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (eid <= 0) { pageMsg = "请先选择考试"; pageMsgType = "error"; BindScores(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            DataTable dt;
            string examTitle = "考试成绩";
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(p.Ptitle,'考试') FROM ExamPublish ep LEFT JOIN Paper p ON ep.Epid=p.Pid WHERE ep.Eid=@eid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    object v = cmd.ExecuteScalar();
                    if (v != null && v != DBNull.Value) examTitle = v.ToString();
                }
                string sql = @"SELECT s.Snum AS 学号, s.Sname AS 姓名,
                    CAST(s.Sgrade AS VARCHAR) + '年级' + CAST(s.Sclass AS VARCHAR) + '班' AS 班级,
                    ISNULL(es.ESscore, 0) AS 成绩,
                    CASE WHEN ISNULL(es.ESgraded,0)=1 THEN '已批完' WHEN ISNULL(es.ESgraded,0)=0 AND (SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=s.Sid)>0 THEN '批改中' ELSE '未提交' END AS 状态
                    FROM Students s
                    INNER JOIN ExamPublish ep ON s.Sgrade=ep.Egrade AND s.Sclass=ep.Eclass
                    LEFT JOIN ExamScore es ON es.ESeid=@eid AND es.ESsid=s.Sid
                    WHERE ep.Eid=@eid
                    ORDER BY s.Snum";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@eid", eid);
                dt = new DataTable();
                da.Fill(dt);
            }

            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", "attachment;filename=" + Server.UrlEncode(examTitle + "_成绩.xls"));
            Response.Charset = "utf-8";
            Response.ContentEncoding = System.Text.Encoding.UTF8;

            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("<html><head><meta charset='utf-8'/></head><body>");
            sb.Append("<table border='1' cellspacing='0' cellpadding='5' style='border-collapse:collapse;'>");
            // 表头
            sb.Append("<tr style='background:#f0f0f0;font-weight:bold;'>");
            foreach (DataColumn col in dt.Columns)
                sb.Append("<td>" + col.ColumnName + "</td>");
            sb.Append("</tr>");
            // 数据行
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("<tr>");
                foreach (DataColumn col in dt.Columns)
                    sb.Append("<td>" + Server.HtmlEncode(row[col].ToString()) + "</td>");
                sb.Append("</tr>");
            }
            sb.Append("</table></body></html>");
            Response.Write(sb.ToString());
            Response.End();
        }
        catch (System.Threading.ThreadAbortException) { /* Response.End causes this */ }
        catch (Exception ex) { pageMsg = "导出失败: " + ex.Message; pageMsgType = "error"; BindScores(); }
    }

    // ========== 辅助方法 ==========
    protected string GetScoreLevel(object scoreObj, object answerCountObj)
    {
        int ac = answerCountObj != null && answerCountObj != DBNull.Value ? Convert.ToInt32(answerCountObj) : 0;
        if (ac == 0) return "nosubmit";
        int sc = scoreObj != null && scoreObj != DBNull.Value ? Convert.ToInt32(scoreObj) : 0;
        if (sc < 0) sc = 0;
        double ratio = (double)sc / statPaperScore;
        if (ratio >= 0.9) return "excellent";
        if (ratio >= 0.8) return "good";
        if (ratio >= 0.6) return "pass";
        return "fail";
    }
    protected string GetScoreLevelText(object scoreObj, object answerCountObj)
    {
        string level = GetScoreLevel(scoreObj, answerCountObj);
        switch (level)
        {
            case "excellent": return "优秀";
            case "good": return "良好";
            case "pass": return "及格";
            case "fail": return "不及格";
            case "nosubmit": return "未提交";
            default: return "";
        }
    }
    protected string GetGradeText(object graded, object answerCountObj)
    {
        int ac = answerCountObj != null && answerCountObj != DBNull.Value ? Convert.ToInt32(answerCountObj) : 0;
        if (ac == 0) return "未提交";
        int g = graded != null && graded != DBNull.Value ? Convert.ToInt32(graded) : 0;
        return g == 1 ? "已批完" : "批改中";
    }
    protected int GetBarWidth(object scoreObj)
    {
        int sc = scoreObj != null && scoreObj != DBNull.Value ? Convert.ToInt32(scoreObj) : 0;
        if (sc < 0) sc = 0;
        if (statPaperScore <= 0) return 0;
        int w = (int)Math.Round((double)sc / statPaperScore * 100);
        if (w > 100) w = 100;
        if (w < 0) w = 0;
        return w;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .sc-page { max-width: 1400px; width: 100%; margin: 0 auto; }
    .sc-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; }
    .sc-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .sc-title-icon { width: 42px; height: 42px; background: linear-gradient(135deg, #6366f1, #818cf8); border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(99,102,241,0.25); }
    .sc-title-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sc-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 54px; }

    .sc-msg { padding: 12px 18px; border-radius: 10px; font-size: 13px; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .sc-msg svg { width: 18px; height: 18px; flex-shrink: 0; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sc-msg-info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
    .sc-msg-info svg { stroke: #3b82f6; fill: none; }
    .sc-msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .sc-msg-success svg { stroke: #22c55e; fill: none; }
    .sc-msg-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .sc-msg-error svg { stroke: #ef4444; fill: none; }

    .sc-card { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.02); margin-bottom: 20px; overflow: hidden; }
    .sc-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; background: linear-gradient(180deg, #fafbfc, #f8f9fb); font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 10px; }
    .sc-card-head svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sc-card-body { padding: 24px; }

    .sc-filter { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .sc-filter-group { display: flex; align-items: center; gap: 8px; }
    .sc-filter-group label { font-size: 13px; font-weight: 600; color: #475569; white-space: nowrap; }
    .sc-filter-group select { padding: 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0; font-size: 13.5px; color: #334155; background: #f8fafc; outline: none; transition: all 0.2s; font-family: inherit; min-width: 320px; }
    .sc-filter-group select:focus { border-color: #818cf8; background: #fff; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }

    .sc-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 22px; border-radius: 10px; font-size: 13.5px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; font-family: inherit; text-decoration: none; }
    .sc-btn:hover { transform: translateY(-1px); }
    .sc-btn-outline { background: #fff; color: #475569; border: 1.5px solid #e2e8f0; box-shadow: none; }
    .sc-btn-outline:hover { border-color: #818cf8; color: #6366f1; background: #f5f3ff; }

    /* 统计卡片 */
    .sc-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .sc-stat { padding: 20px; border-radius: 14px; text-align: center; border: 1px solid #f1f5f9; background: #fff; transition: all 0.2s; }
    .sc-stat:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.06); }
    .sc-stat-num { font-size: 30px; font-weight: 800; margin-bottom: 4px; font-variant-numeric: tabular-nums; }
    .sc-stat-label { font-size: 12px; color: #94a3b8; font-weight: 500; }
    .sc-stat-avg .sc-stat-num { color: #6366f1; }
    .sc-stat-max .sc-stat-num { color: #059669; }
    .sc-stat-min .sc-stat-num { color: #f59e0b; }
    .sc-stat-pass .sc-stat-num { color: #0891b2; }
    .sc-stat-submit .sc-stat-num { color: #8b5cf6; }
    .sc-stat-total .sc-stat-num { color: #64748b; }

    /* 分布条 */
    .sc-dist { display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; }
    .sc-dist-item { flex: 1; min-width: 100px; padding: 14px 16px; border-radius: 12px; text-align: center; }
    .sc-dist-excellent { background: linear-gradient(135deg, #ecfdf5, #d1fae5); border: 1px solid #a7f3d0; }
    .sc-dist-good { background: linear-gradient(135deg, #eff6ff, #dbeafe); border: 1px solid #93c5fd; }
    .sc-dist-pass { background: linear-gradient(135deg, #fffbeb, #fef3c7); border: 1px solid #fde68a; }
    .sc-dist-fail { background: linear-gradient(135deg, #fef2f2, #fee2e2); border: 1px solid #fecaca; }
    .sc-dist-num { font-size: 24px; font-weight: 700; margin-bottom: 2px; }
    .sc-dist-excellent .sc-dist-num { color: #059669; }
    .sc-dist-good .sc-dist-num { color: #2563eb; }
    .sc-dist-pass .sc-dist-num { color: #d97706; }
    .sc-dist-fail .sc-dist-num { color: #ef4444; }
    .sc-dist-label { font-size: 11px; font-weight: 600; color: #64748b; }
    .sc-dist-range { font-size: 10px; color: #94a3b8; margin-top: 2px; }

    /* 成绩列表 */
    .sc-list { display: flex; flex-direction: column; gap: 6px; }
    .sc-item { display: flex; align-items: center; padding: 14px 20px; border-radius: 10px; border: 1px solid #f1f5f9; background: #fff; transition: all 0.15s; gap: 16px; }
    .sc-item:hover { border-color: #c7d2fe; box-shadow: 0 2px 8px rgba(99,102,241,0.06); }
    .sc-rank { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 700; flex-shrink: 0; }
    .sc-rank-1 { background: linear-gradient(135deg, #fbbf24, #f59e0b); color: #fff; box-shadow: 0 2px 8px rgba(245,158,11,0.3); }
    .sc-rank-2 { background: linear-gradient(135deg, #94a3b8, #64748b); color: #fff; box-shadow: 0 2px 8px rgba(100,116,139,0.3); }
    .sc-rank-3 { background: linear-gradient(135deg, #f97316, #ea580c); color: #fff; box-shadow: 0 2px 8px rgba(249,115,22,0.3); }
    .sc-rank-other { background: #f1f5f9; color: #64748b; }
    .sc-stu-info { flex: 1; min-width: 0; }
    .sc-stu-name { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 2px; }
    .sc-stu-num { font-size: 12px; color: #94a3b8; }
    .sc-score-bar-wrap { flex: 2; min-width: 120px; display: flex; align-items: center; gap: 12px; }
    .sc-score-bar { flex: 1; height: 8px; background: #f1f5f9; border-radius: 4px; overflow: hidden; }
    .sc-score-bar-fill { height: 100%; border-radius: 4px; transition: width 0.5s ease; }
    .sc-bar-excellent { background: linear-gradient(90deg, #059669, #34d399); }
    .sc-bar-good { background: linear-gradient(90deg, #2563eb, #60a5fa); }
    .sc-bar-pass { background: linear-gradient(90deg, #d97706, #fbbf24); }
    .sc-bar-fail { background: linear-gradient(90deg, #ef4444, #f87171); }
    .sc-bar-nosubmit { background: #e2e8f0; }
    .sc-score-num { font-size: 18px; font-weight: 700; min-width: 60px; text-align: right; flex-shrink: 0; }
    .sc-score-excellent { color: #059669; }
    .sc-score-good { color: #2563eb; }
    .sc-score-pass { color: #d97706; }
    .sc-score-fail { color: #ef4444; }
    .sc-score-nosubmit { color: #cbd5e1; }
    .sc-level-tag { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; min-width: 50px; justify-content: center; flex-shrink: 0; }
    .sc-level-excellent { background: #dcfce7; color: #166534; }
    .sc-level-good { background: #dbeafe; color: #1e40af; }
    .sc-level-pass { background: #fef3c7; color: #92400e; }
    .sc-level-fail { background: #fee2e2; color: #991b1b; }
    .sc-level-nosubmit { background: #f1f5f9; color: #94a3b8; }

    .sc-empty { text-align: center; padding: 60px 20px; }
    .sc-empty-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #f1f5f9, #e2e8f0); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
    .sc-empty-icon svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .sc-empty-text { font-size: 15px; color: #64748b; font-weight: 500; }
    .sc-empty-hint { font-size: 13px; color: #94a3b8; margin-top: 6px; }

    .sc-list-head { display: flex; align-items: center; padding: 10px 20px; font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.3px; gap: 16px; border-bottom: 2px solid #f1f5f9; margin-bottom: 6px; }
    .sc-list-head-rank { width: 36px; text-align: center; flex-shrink: 0; }
    .sc-list-head-name { flex: 1; }
    .sc-list-head-bar { flex: 2; min-width: 120px; }
    .sc-list-head-score { min-width: 60px; text-align: right; flex-shrink: 0; }
    .sc-list-head-level { min-width: 50px; text-align: center; flex-shrink: 0; }

    @media (max-width: 768px) {
        .sc-filter { flex-direction: column; align-items: stretch; }
        .sc-filter-group select { min-width: 100%; }
        .sc-stats { grid-template-columns: repeat(3, 1fr); }
        .sc-score-bar-wrap { display: none; }
        .sc-list-head-bar { display: none; }
    }
</style>

<div class="sc-page">
    <div class="sc-header">
        <div>
            <div class="sc-title">
                <span class="sc-title-icon">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                </span>
                成绩管理
            </div>
            <div class="sc-subtitle">查看考试成绩、成绩统计分析和分布情况，支持导出 Excel</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="sc-msg sc-msg-<%= pageMsgType %>">
        <% if (pageMsgType == "success") { %>
        <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <% } else if (pageMsgType == "error") { %>
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <% } else { %>
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <% } %>
        <%= Server.HtmlEncode(pageMsg) %>
    </div>
    <% } %>

    <!-- 选择考试 -->
    <div class="sc-card">
        <div class="sc-card-head">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
            选择考试
        </div>
        <div class="sc-card-body">
            <div class="sc-filter">
                <div class="sc-filter-group">
                    <label>考试：</label>
                    <asp:DropDownList ID="DDLexam" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DDLexam_SelectedIndexChanged" />
                </div>
                <asp:Button ID="BtnExport" runat="server" Text="导出 Excel" OnClick="BtnExport_Click" CssClass="sc-btn sc-btn-outline" />
            </div>
        </div>
    </div>

    <% if (statSubmitted > 0) { %>
    <!-- 统计概览 -->
    <div class="sc-stats">
        <div class="sc-stat sc-stat-avg">
            <div class="sc-stat-num"><%= statAvg %></div>
            <div class="sc-stat-label">平均分</div>
        </div>
        <div class="sc-stat sc-stat-max">
            <div class="sc-stat-num"><%= statMax %></div>
            <div class="sc-stat-label">最高分</div>
        </div>
        <div class="sc-stat sc-stat-min">
            <div class="sc-stat-num"><%= statMin %></div>
            <div class="sc-stat-label">最低分</div>
        </div>
        <div class="sc-stat sc-stat-pass">
            <div class="sc-stat-num"><%= statPassRate %>%</div>
            <div class="sc-stat-label">及格率</div>
        </div>
        <div class="sc-stat sc-stat-submit">
            <div class="sc-stat-num"><%= statSubmitted %></div>
            <div class="sc-stat-label">已提交</div>
        </div>
        <div class="sc-stat sc-stat-total">
            <div class="sc-stat-num"><%= statTotal %></div>
            <div class="sc-stat-label">总人数</div>
        </div>
    </div>

    <!-- 成绩分布 -->
    <div class="sc-dist">
        <div class="sc-dist-item sc-dist-excellent">
            <div class="sc-dist-num"><%= statExcellent %></div>
            <div class="sc-dist-label">优秀</div>
            <div class="sc-dist-range">≥ <%= (int)(statPaperScore * 0.9) %> 分</div>
        </div>
        <div class="sc-dist-item sc-dist-good">
            <div class="sc-dist-num"><%= statGood %></div>
            <div class="sc-dist-label">良好</div>
            <div class="sc-dist-range">≥ <%= (int)(statPaperScore * 0.8) %> 分</div>
        </div>
        <div class="sc-dist-item sc-dist-pass">
            <div class="sc-dist-num"><%= statPass %></div>
            <div class="sc-dist-label">及格</div>
            <div class="sc-dist-range">≥ <%= (int)(statPaperScore * 0.6) %> 分</div>
        </div>
        <div class="sc-dist-item sc-dist-fail">
            <div class="sc-dist-num"><%= statFail %></div>
            <div class="sc-dist-label">不及格</div>
            <div class="sc-dist-range">&lt; <%= (int)(statPaperScore * 0.6) %> 分</div>
        </div>
    </div>
    <% } %>

    <!-- 成绩列表 -->
    <div class="sc-card">
        <div class="sc-card-head">
            <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            成绩列表（满分 <%= statPaperScore %> 分）
        </div>
        <div class="sc-card-body">
            <asp:Repeater ID="RptScores" runat="server">
                <HeaderTemplate>
                    <div class="sc-list-head">
                        <span class="sc-list-head-rank">排名</span>
                        <span class="sc-list-head-name">学生</span>
                        <span class="sc-list-head-bar">成绩</span>
                        <span class="sc-list-head-score">分数</span>
                        <span class="sc-list-head-level">等级</span>
                    </div>
                    <div class="sc-list">
                </HeaderTemplate>
                <ItemTemplate>
                    <div class="sc-item">
                        <div class='sc-rank <%# Convert.ToInt32(Eval("Rank")) == 1 ? "sc-rank-1" : (Convert.ToInt32(Eval("Rank")) == 2 ? "sc-rank-2" : (Convert.ToInt32(Eval("Rank")) == 3 ? "sc-rank-3" : "sc-rank-other")) %>'>
                            <%# Eval("Rank") %>
                        </div>
                        <div class="sc-stu-info">
                            <div class="sc-stu-name"><%# Server.HtmlEncode(Eval("Sname").ToString()) %></div>
                            <div class="sc-stu-num"><%# Eval("Snum") %></div>
                        </div>
                        <div class="sc-score-bar-wrap">
                            <div class="sc-score-bar">
                                <div class='sc-score-bar-fill sc-bar-<%# GetScoreLevel(Eval("Score"), Eval("AnswerCount")) %>' style='width:<%# GetBarWidth(Eval("Score")) %>%'></div>
                            </div>
                        </div>
                        <div class='sc-score-num sc-score-<%# GetScoreLevel(Eval("Score"), Eval("AnswerCount")) %>'>
                            <%# Convert.ToInt32(Eval("AnswerCount")) > 0 ? (Convert.ToInt32(Eval("Score")) >= 0 ? Eval("Score").ToString() : "0") : "-" %>
                        </div>
                        <span class='sc-level-tag sc-level-<%# GetScoreLevel(Eval("Score"), Eval("AnswerCount")) %>'><%# GetScoreLevelText(Eval("Score"), Eval("AnswerCount")) %></span>
                    </div>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>

            <asp:Panel ID="PanelEmpty" runat="server" Visible='<%# RptScores.Items.Count == 0 %>'>
                <div class="sc-empty">
                    <div class="sc-empty-icon">
                        <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                    </div>
                    <div class="sc-empty-text">请先选择一场考试</div>
                    <div class="sc-empty-hint">在上方选择已发布的考试，即可查看成绩统计和排名</div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>
</asp:Content>
