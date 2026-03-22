#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\examanalysis.aspx.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "BE347ADB0A8A2D79C97DD3C2B6804F1D"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\examanalysis.aspx.cs"
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class teacher_examanalysis : System.Web.UI.Page
{
    protected int myHid = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadTeacher();
        if (!IsPostBack)
        {
            LoadExams();
        }
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
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null) int.TryParse(v.ToString(), out myHid);
                    }
                }
            }
        }
        catch { }
    }

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
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        return cs;
    }

    // 加载考试列表
    private void LoadExams()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 修改：不依赖Edate字段，使用Eid降序
                string sql = @"SELECT ep.Eid, p.Ptitle, ep.Egrade, ep.Eclass
                    FROM ExamPublish ep
                    INNER JOIN Paper p ON ep.Epid = p.Pid
                    WHERE ep.Ehid = @hid
                    ORDER BY ep.Eid DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLExam.Items.Clear();
                    DDLExam.Items.Add(new ListItem("-- 请选择考试 --", "0"));

                    int count = 0;
                    while (dr.Read())
                    {
                        string text = dr["Ptitle"].ToString() + " (" +
                            dr["Egrade"] + "年级" + dr["Eclass"] + "班)";
                        DDLExam.Items.Add(new ListItem(text, dr["Eid"].ToString()));
                        count++;
                    }
                    dr.Close();
                    
                    // 调试：如果没有考试，记录日志
                    if (count == 0)
                    {
                        Response.Write("<!-- 调试：未找到考试，Hid=" + myHid + " -->");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // 调试：输出错误信息
            Response.Write("<!-- 加载考试列表错误: " + ex.Message + " -->");
        }
    }

    // 考试选择改变
    protected void DDLExam_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadGradesAndClasses();
        LoadAnalysisData();
    }

    // 筛选范围改变
    protected void DDLScope_SelectedIndexChanged(object sender, EventArgs e)
    {
        string scope = DDLScope.SelectedValue;
        gradeFilterGroup.Visible = (scope == "grade" || scope == "class");
        classFilterGroup.Visible = (scope == "class");

        if (scope == "grade" || scope == "class")
        {
            LoadGradesAndClasses();
        }

        LoadAnalysisData();
    }

    // 年级选择改变
    protected void DDLGrade_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (DDLScope.SelectedValue == "class")
        {
            LoadClasses();
        }
        LoadAnalysisData();
    }

    // 班级选择改变
    protected void DDLClass_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadAnalysisData();
    }

    // 加载年级和班级列表
    private void LoadGradesAndClasses()
    {
        int eid = 0;
        int.TryParse(DDLExam.SelectedValue, out eid);
        if (eid <= 0) return;

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 获取考试的年级和班级
                string sql = "SELECT Egrade, Eclass FROM ExamPublish WHERE Eid=@eid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        int examGrade = Convert.ToInt32(dr["Egrade"]);
                        int examClass = Convert.ToInt32(dr["Eclass"]);
                        dr.Close();

                        // 加载年级列表
                        DDLGrade.Items.Clear();
                        DDLGrade.Items.Add(new ListItem("-- 选择年级 --", "0"));
                        DDLGrade.Items.Add(new ListItem(examGrade + "年级", examGrade.ToString()));
                        DDLGrade.SelectedValue = examGrade.ToString();

                        // 加载班级列表
                        LoadClasses();
                    }
                    else
                    {
                        dr.Close();
                    }
                }
            }
        }
        catch { }
    }

    // 加载班级列表
    private void LoadClasses()
    {
        int eid = 0;
        int.TryParse(DDLExam.SelectedValue, out eid);
        if (eid <= 0) return;

        int grade = 0;
        int.TryParse(DDLGrade.SelectedValue, out grade);
        if (grade <= 0) return;

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=@grade ORDER BY Sclass";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@grade", grade);
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLClass.Items.Clear();
                    DDLClass.Items.Add(new ListItem("-- 选择班级 --", "0"));

                    while (dr.Read())
                    {
                        int classNum = Convert.ToInt32(dr["Sclass"]);
                        DDLClass.Items.Add(new ListItem(classNum + "班", classNum.ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    // 加载分析数据
    private void LoadAnalysisData()
    {
        int eid = 0;
        int.TryParse(DDLExam.SelectedValue, out eid);
        
        // 调试信息
        Response.Write("<!-- 调试：eid=" + eid + ", DDLExam.SelectedValue=" + DDLExam.SelectedValue + " -->");
        
        if (eid <= 0)
        {
            PanelEmpty.Visible = true;
            PanelStats.Visible = false;
            PanelQuestions.Visible = false;
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            Response.Write("<!-- 调试：连接字符串为空 -->");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 获取试卷ID
                int pid = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT Epid FROM ExamPublish WHERE Eid=@eid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out pid);
                }

                Response.Write("<!-- 调试：pid=" + pid + " -->");

                if (pid <= 0)
                {
                    Response.Write("<!-- 调试：未找到试卷ID -->");
                    PanelEmpty.Visible = true;
                    PanelStats.Visible = false;
                    PanelQuestions.Visible = false;
                    return;
                }

                // 构建学生筛选条件
                string studentFilter = BuildStudentFilter(conn, eid);
                Response.Write("<!-- 调试：studentFilter=" + studentFilter + " -->");

                // 加载整体统计
                LoadOverallStats(conn, eid, pid, studentFilter);

                // 加载题目分析
                LoadQuestionAnalysis(conn, eid, pid, studentFilter);

                PanelEmpty.Visible = false;
                PanelStats.Visible = true;
                PanelQuestions.Visible = true;
                
                Response.Write("<!-- 调试：数据加载完成 -->");
            }
        }
        catch (Exception ex)
        {
            // 错误处理
            Response.Write("<!-- 调试：LoadAnalysisData错误: " + ex.Message + " -->");
            Response.Write("<!-- 调试：StackTrace: " + ex.StackTrace + " -->");
            PanelEmpty.Visible = true;
            PanelStats.Visible = false;
            PanelQuestions.Visible = false;
        }
    }

    // 构建学生筛选条件
    private string BuildStudentFilter(SqlConnection conn, int eid)
    {
        string scope = DDLScope.SelectedValue;
        string filter = "";

        // 获取考试的年级和班级
        int examGrade = 0, examClass = 0;
        using (SqlCommand cmd = new SqlCommand("SELECT Egrade, Eclass FROM ExamPublish WHERE Eid=@eid", conn))
        {
            cmd.Parameters.AddWithValue("@eid", eid);
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                examGrade = Convert.ToInt32(dr["Egrade"]);
                examClass = Convert.ToInt32(dr["Eclass"]);
            }
            dr.Close();
        }

        if (scope == "grade")
        {
            int grade = 0;
            int.TryParse(DDLGrade.SelectedValue, out grade);
            if (grade > 0)
            {
                filter = " AND s.Sgrade = " + grade;
            }
        }
        else if (scope == "class")
        {
            int grade = 0, classNum = 0;
            int.TryParse(DDLGrade.SelectedValue, out grade);
            int.TryParse(DDLClass.SelectedValue, out classNum);
            if (grade > 0 && classNum > 0)
            {
                filter = " AND s.Sgrade = " + grade + " AND s.Sclass = " + classNum;
            }
        }
        else
        {
            // 全部学生：使用考试的年级班级
            filter = " AND s.Sgrade = " + examGrade + " AND s.Sclass = " + examClass;
        }

        return filter;
    }

    // 加载整体统计
    private void LoadOverallStats(SqlConnection conn, int eid, int pid, string studentFilter)
    {
        string sql = @"
            SELECT 
                COUNT(DISTINCT es.ESsid) AS Participants,
                ISNULL(AVG(CAST(es.ESscore AS FLOAT)), 0) AS AvgScore,
                ISNULL(MAX(es.ESscore), 0) AS MaxScore,
                ISNULL(MIN(es.ESscore), 0) AS MinScore,
                (SELECT Pscore FROM Paper WHERE Pid=@pid) AS TotalScore
            FROM ExamScore es
            INNER JOIN Students s ON es.ESsid = s.Sid
            WHERE es.ESeid = @eid " + studentFilter;

        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@eid", eid);
            cmd.Parameters.AddWithValue("@pid", pid);
            SqlDataReader dr = cmd.ExecuteReader();

            if (dr.Read())
            {
                int participants = Convert.ToInt32(dr["Participants"]);
                double avgScore = Convert.ToDouble(dr["AvgScore"]);
                int maxScore = Convert.ToInt32(dr["MaxScore"]);
                int minScore = participants > 0 ? Convert.ToInt32(dr["MinScore"]) : 0;
                int totalScore = dr["TotalScore"] != DBNull.Value ? Convert.ToInt32(dr["TotalScore"]) : 100;

                LblParticipants.Text = participants.ToString();
                LblAvgScore.Text = avgScore.ToString("F1");
                LblMaxScore.Text = maxScore.ToString();
                LblMinScore.Text = minScore.ToString();

                // 计算及格率（60%为及格线）
                double passLine = totalScore * 0.6;
                dr.Close();

                string passSql = @"
                    SELECT COUNT(*) 
                    FROM ExamScore es
                    INNER JOIN Students s ON es.ESsid = s.Sid
                    WHERE es.ESeid = @eid AND es.ESscore >= @passLine " + studentFilter;

                using (SqlCommand passCmd = new SqlCommand(passSql, conn))
                {
                    passCmd.Parameters.AddWithValue("@eid", eid);
                    passCmd.Parameters.AddWithValue("@passLine", passLine);
                    int passCount = Convert.ToInt32(passCmd.ExecuteScalar());
                    double passRate = participants > 0 ? (passCount * 100.0 / participants) : 0;
                    LblPassRate.Text = passRate.ToString("F1");
                }
            }
            else
            {
                dr.Close();
                LblParticipants.Text = "0";
                LblAvgScore.Text = "0";
                LblMaxScore.Text = "0";
                LblMinScore.Text = "0";
                LblPassRate.Text = "0";
            }
        }
    }

    // 加载题目分析
    private void LoadQuestionAnalysis(SqlConnection conn, int eid, int pid, string studentFilter)
    {
        try
        {
            // 简化SQL查询，分步处理
            string sql = @"
                SELECT 
                    pq.Qid,
                    pq.Qtype,
                    pq.Qcontent,
                    pq.Qscore,
                    pq.Qsort
                FROM PaperQuestion pq
                WHERE pq.Qpid = @pid
                ORDER BY pq.Qsort, pq.Qid";

            DataTable dt = new DataTable();
            dt.Columns.Add("Qid", typeof(int));
            dt.Columns.Add("Qtype", typeof(string));
            dt.Columns.Add("Qcontent", typeof(string));
            dt.Columns.Add("Qscore", typeof(int));
            dt.Columns.Add("Qsort", typeof(int));
            dt.Columns.Add("AvgScore", typeof(string));
            dt.Columns.Add("CorrectCount", typeof(int));
            dt.Columns.Add("WrongCount", typeof(int));
            dt.Columns.Add("CorrectRate", typeof(string));
            dt.Columns.Add("WrongRate", typeof(string));

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@pid", pid);
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    DataRow row = dt.NewRow();
                    int qid = Convert.ToInt32(dr["Qid"]);
                    int qscore = Convert.ToInt32(dr["Qscore"]);

                    row["Qid"] = qid;
                    row["Qtype"] = dr["Qtype"].ToString();
                    row["Qcontent"] = dr["Qcontent"].ToString();
                    row["Qscore"] = qscore;
                    row["Qsort"] = dr["Qsort"];

                    dt.Rows.Add(row);
                }
                dr.Close();
            }

            // 为每道题计算统计数据
            foreach (DataRow row in dt.Rows)
            {
                int qid = Convert.ToInt32(row["Qid"]);
                int qscore = Convert.ToInt32(row["Qscore"]);

                // 获取该题的答题统计（只取最新答案）
                string statSql = @"
                    SELECT 
                        COUNT(DISTINCT ea.EAsid) AS TotalAnswers,
                        ISNULL(AVG(CAST(ea.EAscore AS FLOAT)), 0) AS AvgScore,
                        SUM(CASE WHEN ea.EAscore = @qscore THEN 1 ELSE 0 END) AS CorrectCount,
                        SUM(CASE WHEN ea.EAscore = 0 THEN 1 ELSE 0 END) AS WrongCount
                    FROM (
                        SELECT EAsid, EAscore,
                            ROW_NUMBER() OVER (PARTITION BY EAsid ORDER BY ISNULL(EAdate, '1900-01-01') DESC, EAid DESC) AS RowNum
                        FROM ExamAnswer
                        WHERE EAeid = @eid AND EAqid = @qid
                    ) ea
                    INNER JOIN Students s ON ea.EAsid = s.Sid
                    WHERE ea.RowNum = 1 " + studentFilter;

                using (SqlCommand statCmd = new SqlCommand(statSql, conn))
                {
                    statCmd.Parameters.AddWithValue("@eid", eid);
                    statCmd.Parameters.AddWithValue("@qid", qid);
                    statCmd.Parameters.AddWithValue("@qscore", qscore);

                    SqlDataReader statDr = statCmd.ExecuteReader();
                    if (statDr.Read())
                    {
                        int totalAnswers = Convert.ToInt32(statDr["TotalAnswers"]);
                        double avgScore = Convert.ToDouble(statDr["AvgScore"]);
                        int correctCount = statDr["CorrectCount"] != DBNull.Value ? Convert.ToInt32(statDr["CorrectCount"]) : 0;
                        int wrongCount = statDr["WrongCount"] != DBNull.Value ? Convert.ToInt32(statDr["WrongCount"]) : 0;

                        double correctRate = totalAnswers > 0 ? (correctCount * 100.0 / totalAnswers) : 0;
                        double wrongRate = totalAnswers > 0 ? (wrongCount * 100.0 / totalAnswers) : 0;

                        row["AvgScore"] = avgScore.ToString("F1");
                        row["CorrectCount"] = correctCount;
                        row["WrongCount"] = wrongCount;
                        row["CorrectRate"] = correctRate.ToString("F1");
                        row["WrongRate"] = wrongRate.ToString("F1");
                    }
                    else
                    {
                        row["AvgScore"] = "0.0";
                        row["CorrectCount"] = 0;
                        row["WrongCount"] = 0;
                        row["CorrectRate"] = "0.0";
                        row["WrongRate"] = "0.0";
                    }
                    statDr.Close();
                }
            }

            LblQuestionCount.Text = dt.Rows.Count.ToString();
            RptQuestions.DataSource = dt;
            RptQuestions.DataBind();
        }
        catch (Exception ex)
        {
            // 调试：输出错误
            Response.Write("<!-- 加载题目分析错误: " + ex.Message + " -->");
            LblQuestionCount.Text = "0";
        }
    }

    // 获取题型名称
    protected string GetTypeName(string qtype)
    {
        switch (qtype.ToLower())
        {
            case "single":
            case "单选": return "单选题";
            case "multiple":
            case "多选": return "多选题";
            case "truefalse":
            case "判断": return "判断题";
            case "fill":
            case "填空": return "填空题";
            case "essay":
            case "问答": return "问答题";
            case "scratch": return "Scratch";
            case "python": return "Python";
            case "pythonblock": return "Python拼图";
            default: return qtype;
        }
    }

    // 获取题型样式类
    protected string GetTypeClass(string qtype)
    {
        switch (qtype.ToLower())
        {
            case "single":
            case "单选": return "ea-q-type-choice";
            case "multiple":
            case "多选": return "ea-q-type-multi";
            case "truefalse":
            case "判断": return "ea-q-type-judge";
            case "fill":
            case "填空": return "ea-q-type-fill";
            case "essay":
            case "问答": return "ea-q-type-essay";
            case "scratch":
            case "python":
            case "pythonblock": return "ea-q-type-coding";
            default: return "ea-q-type-choice";
        }
    }

    // 去除HTML标签
    protected string StripHtml(string html)
    {
        if (string.IsNullOrEmpty(html)) return "";
        string text = Regex.Replace(html, @"<[^>]+>", "");
        text = text.Replace("&nbsp;", " ").Replace("&lt;", "<").Replace("&gt;", ">").Replace("&amp;", "&");
        return text.Trim();
    }
}


#line default
#line hidden
