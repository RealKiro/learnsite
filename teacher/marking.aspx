<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";

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
            BindStudentList();
        }
    }

    // ========== 自动建表 ==========
    private void EnsureTables()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // ExamAnswer 表：学生答题记录
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='ExamAnswer' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[ExamAnswer](
                            [EAid] [int] IDENTITY(1,1) NOT NULL,
                            [EAeid] [int] NULL,
                            [EApid] [int] NULL,
                            [EAsid] [int] NULL,
                            [EAqid] [int] NULL,
                            [EAanswer] [nvarchar](2000) NULL,
                            [EAscore] [int] NULL DEFAULT(0),
                            [EAgraded] [int] NULL DEFAULT(0),
                            [EAdate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([EAid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
                // ExamScore 表：学生考试总分
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

    // ========== 加载考试列表 ==========
    private void LoadExams()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT ep.Eid, ep.Egrade, ep.Eclass, ep.Estart, ep.Eend,
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
                        string text = dr["Ptitle"].ToString() + " (" + dr["Egrade"] + "年级" + dr["Eclass"] + "班 / " + dr["Pcount"] + "题 / " + dr["Pscore"] + "分)";
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
        BindStudentList();
    }

    // ========== 一键自动阅卷 ==========
    protected void BtnAutoGrade_Click(object sender, EventArgs e)
    {
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (eid <= 0) { pageMsg = "请先选择考试"; pageMsgType = "error"; BindStudentList(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int gradedCount = 0;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int pid = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT Epid FROM ExamPublish WHERE Eid=@eid AND Ehid=@hid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out pid);
                }
                if (pid <= 0) { pageMsg = "考试信息无效"; pageMsgType = "error"; BindStudentList(); return; }

                // 获取试卷标准答案
                DataTable dtQuestions = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT Qid, Qtype, Qanswer, Qscore FROM PaperQuestion WHERE Qpid=@pid", conn))
                {
                    da.SelectCommand.Parameters.AddWithValue("@pid", pid);
                    da.Fill(dtQuestions);
                }

                // 获取所有待阅卷的答题记录
                DataTable dtAnswers = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT EAid, EAqid, EAanswer, EAgraded FROM ExamAnswer WHERE EAeid=@eid AND EAgraded=0", conn))
                {
                    da.SelectCommand.Parameters.AddWithValue("@eid", eid);
                    da.Fill(dtAnswers);
                }

                foreach (DataRow ansRow in dtAnswers.Rows)
                {
                    int qid = Convert.ToInt32(ansRow["EAqid"]);
                    string studentAnswer = ansRow["EAanswer"] != DBNull.Value ? ansRow["EAanswer"].ToString().Trim() : "";
                    DataRow[] qRows = dtQuestions.Select("Qid=" + qid);
                    if (qRows.Length == 0) continue;

                    string qtype = qRows[0]["Qtype"].ToString();
                    string correctAnswer = qRows[0]["Qanswer"] != DBNull.Value ? qRows[0]["Qanswer"].ToString().Trim() : "";
                    int qscore = Convert.ToInt32(qRows[0]["Qscore"]);

                    // 客观题自动阅卷（兼容中英文题型名）
                    if (qtype == "single" || qtype == "multiple" || qtype == "truefalse"
                        || qtype == "单选" || qtype == "多选" || qtype == "判断")
                    {
                        int awardScore = 0;
                        if (string.Equals(studentAnswer, correctAnswer, StringComparison.OrdinalIgnoreCase))
                            awardScore = qscore;
                        using (SqlCommand cmd = new SqlCommand("UPDATE ExamAnswer SET EAscore=@score, EAgraded=1 WHERE EAid=@eaid", conn))
                        {
                            cmd.Parameters.AddWithValue("@score", awardScore);
                            cmd.Parameters.AddWithValue("@eaid", Convert.ToInt32(ansRow["EAid"]));
                            cmd.ExecuteNonQuery();
                            gradedCount++;
                        }
                    }
                    // 填空题自动阅卷
                    else if (qtype == "fill" || qtype == "填空")
                    {
                        int awardScore = 0;
                        if (!string.IsNullOrEmpty(studentAnswer) && !string.IsNullOrEmpty(correctAnswer)
                            && string.Equals(studentAnswer.Trim(), correctAnswer.Trim(), StringComparison.OrdinalIgnoreCase))
                            awardScore = qscore;
                        using (SqlCommand cmd = new SqlCommand("UPDATE ExamAnswer SET EAscore=@score, EAgraded=1 WHERE EAid=@eaid", conn))
                        {
                            cmd.Parameters.AddWithValue("@score", awardScore);
                            cmd.Parameters.AddWithValue("@eaid", Convert.ToInt32(ansRow["EAid"]));
                            cmd.ExecuteNonQuery();
                            gradedCount++;
                        }
                    }
                }
                UpdateAllScores(conn, eid, pid);
            }
            pageMsg = "自动阅卷完成！共批改 " + gradedCount + " 道客观题"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "自动阅卷失败: " + ex.Message; pageMsgType = "error"; }
        BindStudentList();
    }

    // ========== 更新学生总分 ==========
    private void UpdateAllScores(SqlConnection conn, int eid, int pid)
    {
        DataTable dtStudents = new DataTable();
        using (SqlDataAdapter da = new SqlDataAdapter("SELECT DISTINCT EAsid FROM ExamAnswer WHERE EAeid=@eid", conn))
        {
            da.SelectCommand.Parameters.AddWithValue("@eid", eid);
            da.Fill(dtStudents);
        }
        foreach (DataRow row in dtStudents.Rows)
        {
            int sid = Convert.ToInt32(row["EAsid"]);
            int totalScore = 0;
            int ungradedCount = 0;
            
            // 修改：只统计每个题目的最新答案
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT ISNULL(SUM(EAscore),0) 
                FROM (
                    SELECT EAscore, 
                        ROW_NUMBER() OVER (PARTITION BY EAqid ORDER BY ISNULL(EAdate, '1900-01-01') DESC, EAid DESC) AS RowNum
                    FROM ExamAnswer 
                    WHERE EAeid=@eid AND EAsid=@sid
                ) AS LatestAnswers
                WHERE RowNum = 1", conn))
            {
                cmd.Parameters.AddWithValue("@eid", eid); cmd.Parameters.AddWithValue("@sid", sid);
                totalScore = Convert.ToInt32(cmd.ExecuteScalar());
            }
            
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM (
                    SELECT EAgraded, 
                        ROW_NUMBER() OVER (PARTITION BY EAqid ORDER BY ISNULL(EAdate, '1900-01-01') DESC, EAid DESC) AS RowNum
                    FROM ExamAnswer 
                    WHERE EAeid=@eid AND EAsid=@sid
                ) AS LatestAnswers
                WHERE RowNum = 1 AND EAgraded=0", conn))
            {
                cmd.Parameters.AddWithValue("@eid", eid); cmd.Parameters.AddWithValue("@sid", sid);
                ungradedCount = Convert.ToInt32(cmd.ExecuteScalar());
            }
            int graded = ungradedCount == 0 ? 1 : 0;
            using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamScore WHERE ESeid=@eid AND ESsid=@sid", conn))
            {
                chk.Parameters.AddWithValue("@eid", eid); chk.Parameters.AddWithValue("@sid", sid);
                int exists = Convert.ToInt32(chk.ExecuteScalar());
                if (exists > 0)
                {
                    using (SqlCommand cmd = new SqlCommand("UPDATE ExamScore SET ESscore=@score, ESgraded=@graded, ESdate=GETDATE() WHERE ESeid=@eid AND ESsid=@sid", conn))
                    { cmd.Parameters.AddWithValue("@score", totalScore); cmd.Parameters.AddWithValue("@graded", graded); cmd.Parameters.AddWithValue("@eid", eid); cmd.Parameters.AddWithValue("@sid", sid); cmd.ExecuteNonQuery(); }
                }
                else
                {
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO ExamScore(ESeid,ESpid,ESsid,ESscore,ESgraded,ESdate) VALUES(@eid,@pid,@sid,@score,@graded,GETDATE())", conn))
                    { cmd.Parameters.AddWithValue("@eid", eid); cmd.Parameters.AddWithValue("@pid", pid); cmd.Parameters.AddWithValue("@sid", sid); cmd.Parameters.AddWithValue("@score", totalScore); cmd.Parameters.AddWithValue("@graded", graded); cmd.ExecuteNonQuery(); }
                }
            }
        }
    }

    // ========== 学生答卷列表 ==========
    private void BindStudentList()
    {
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (eid <= 0) { RptStudents.DataSource = null; RptStudents.DataBind(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT s.Sid, s.Snum, s.Sname, s.Sgrade, s.Sclass,
                    ISNULL(es.ESscore, 0) AS TotalScore,
                    ISNULL(es.ESgraded, 0) AS Graded,
                    (SELECT COUNT(DISTINCT EAqid) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=s.Sid) AS AnswerCount,
                    (SELECT COUNT(*) FROM (
                        SELECT EAgraded, ROW_NUMBER() OVER (PARTITION BY EAqid ORDER BY ISNULL(EAdate, '1900-01-01') DESC, EAid DESC) AS RowNum
                        FROM ExamAnswer WHERE EAeid=@eid AND EAsid=s.Sid
                    ) AS Latest WHERE RowNum=1 AND EAgraded=0) AS UngradedCount
                    FROM Students s
                    INNER JOIN ExamPublish ep ON s.Sgrade=ep.Egrade AND s.Sclass=ep.Eclass
                    LEFT JOIN ExamScore es ON es.ESeid=@eid AND es.ESsid=s.Sid
                    WHERE ep.Eid=@eid
                    ORDER BY s.Snum";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@eid", eid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptStudents.DataSource = dt;
                RptStudents.DataBind();
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; pageMsgType = "error"; }
    }

    // ========== 查看学生答卷 ==========
    protected void RptStudents_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "ViewAnswer")
        {
            int sid = 0; int.TryParse(e.CommandArgument.ToString(), out sid);
            if (sid <= 0) return;
            HiddenStudentId.Value = sid.ToString();
            BindStudentAnswers(sid);
            PanelList.Visible = false;
            PanelDetail.Visible = true;
        }
        else if (e.CommandName == "ResetExam")
        {
            int sid = 0; int.TryParse(e.CommandArgument.ToString(), out sid);
            int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
            if (sid <= 0 || eid <= 0) { pageMsg = "参数错误"; pageMsgType = "error"; BindStudentList(); return; }
            ResetStudentExam(eid, sid);
        }
    }

    // ========== 重新开始考试 ==========
    private void ResetStudentExam(int eid, int sid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
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
                if (pid <= 0) { pageMsg = "考试信息无效"; pageMsgType = "error"; BindStudentList(); return; }

                // 1. 删除 SurveyFeedback 记录，让学生可以重新考试
                int deletedFB = 0;
                using (SqlCommand cmd = new SqlCommand("DELETE FROM SurveyFeedback WHERE Fvid=@pid AND Fsid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", pid);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    deletedFB = cmd.ExecuteNonQuery();
                }
                
                // 2. 保留 ExamAnswer 表中的答案数据，但清除评分和批改状态
                int updatedEA = 0;
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE ExamAnswer 
                    SET EAscore = 0, 
                        EAgraded = 0
                    WHERE EAeid=@eid AND EAsid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    updatedEA = cmd.ExecuteNonQuery();
                }
                
                // 3. 删除 ExamScore 表中的记录
                int deletedES = 0;
                using (SqlCommand cmd = new SqlCommand("DELETE FROM ExamScore WHERE ESeid=@eid AND ESsid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    deletedES = cmd.ExecuteNonQuery();
                }
                
                pageMsg = string.Format("重置成功！学生可以重新开始考试，上次答案已保留。已删除：SurveyFeedback({0}条)、ExamScore({1}条)，已清除批改数据：ExamAnswer({2}条)。", 
                    deletedFB, deletedES, updatedEA);
                pageMsgType = "success";
            }
        }
        catch (Exception ex) { 
            pageMsg = "重置失败: " + ex.Message; 
            pageMsgType = "error"; 
        }
        
        // 如果当前正在查看该学生的答卷，返回到列表页面
        int currentSid = 0;
        if (!string.IsNullOrEmpty(HiddenStudentId.Value))
        {
            int.TryParse(HiddenStudentId.Value, out currentSid);
        }
        
        if (currentSid == sid && PanelDetail.Visible)
        {
            // 正在查看该学生的答卷，返回列表
            PanelList.Visible = true;
            PanelDetail.Visible = false;
            HiddenStudentId.Value = "";
        }
        
        BindStudentList();
    }

    private void BindStudentAnswers(int sid)
    {
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (eid <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT Sname, Snum FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read()) { LblStudentName.Text = dr["Sname"].ToString() + "（" + dr["Snum"].ToString() + "）"; }
                    dr.Close();
                }
                
                // 修改查询：只获取每个题目的最新答案（按EAdate降序，取每个题目的第一条）
                string sql = @"
                    SELECT ea.EAid, ea.EAqid, ea.EAanswer, ea.EAscore, ea.EAgraded,
                        pq.Qtype, pq.Qcontent, pq.Qoption_a, pq.Qoption_b, pq.Qoption_c, pq.Qoption_d,
                        pq.Qanswer, pq.Qscore AS MaxScore, pq.Qsort
                    FROM (
                        SELECT EAid, EAqid, EAanswer, EAscore, EAgraded,
                            ROW_NUMBER() OVER (PARTITION BY EAqid ORDER BY ISNULL(EAdate, '1900-01-01') DESC, EAid DESC) AS RowNum
                        FROM ExamAnswer
                        WHERE EAeid=@eid AND EAsid=@sid
                    ) ea
                    INNER JOIN PaperQuestion pq ON ea.EAqid=pq.Qid
                    WHERE ea.RowNum = 1
                    ORDER BY pq.Qsort, pq.Qid";
                    
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@eid", eid);
                da.SelectCommand.Parameters.AddWithValue("@sid", sid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptAnswers.DataSource = dt;
                RptAnswers.DataBind();
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; pageMsgType = "error"; }
    }

    protected void BtnBackToList_Click(object sender, EventArgs e)
    {
        PanelList.Visible = true;
        PanelDetail.Visible = false;
        BindStudentList();
    }

    // ========== 保存评分 ==========
    protected void BtnSaveGrade_Click(object sender, EventArgs e)
    {
        int sid = 0; int.TryParse(HiddenStudentId.Value, out sid);
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (sid <= 0 || eid <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int pid = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT Epid FROM ExamPublish WHERE Eid=@eid", conn))
                { cmd.Parameters.AddWithValue("@eid", eid); object v = cmd.ExecuteScalar(); if (v != null) int.TryParse(v.ToString(), out pid); }

                // 获取题目满分信息
                DataTable dtMaxScores = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT Qid, Qscore FROM PaperQuestion WHERE Qpid=@pid", conn))
                {
                    da.SelectCommand.Parameters.AddWithValue("@pid", pid);
                    da.Fill(dtMaxScores);
                }

                foreach (System.Web.UI.WebControls.RepeaterItem item in RptAnswers.Items)
                {
                    System.Web.UI.WebControls.HiddenField hfEAid = (System.Web.UI.WebControls.HiddenField)item.FindControl("HfEAid");
                    System.Web.UI.WebControls.HiddenField hfQid = (System.Web.UI.WebControls.HiddenField)item.FindControl("HfQid");
                    System.Web.UI.WebControls.TextBox txtScore = (System.Web.UI.WebControls.TextBox)item.FindControl("TxtItemScore");
                    if (hfEAid == null || txtScore == null) continue;
                    int eaid = 0; int.TryParse(hfEAid.Value, out eaid);
                    int qid = 0; if (hfQid != null) int.TryParse(hfQid.Value, out qid);
                    int score = 0; int.TryParse(txtScore.Text.Trim(), out score);
                    if (score < 0) score = 0;
                    
                    // 验证分数不超过满分
                    if (qid > 0)
                    {
                        DataRow[] rows = dtMaxScores.Select("Qid=" + qid);
                        if (rows.Length > 0)
                        {
                            int maxScore = 0;
                            int.TryParse(rows[0]["Qscore"].ToString(), out maxScore);
                            if (score > maxScore) score = maxScore; // 自动限制为满分
                        }
                    }
                    
                    using (SqlCommand cmd = new SqlCommand("UPDATE ExamAnswer SET EAscore=@score, EAgraded=2 WHERE EAid=@eaid", conn))
                    { cmd.Parameters.AddWithValue("@score", score); cmd.Parameters.AddWithValue("@eaid", eaid); cmd.ExecuteNonQuery(); }
                }
                UpdateAllScores(conn, eid, pid);
            }
            pageMsg = "评分保存成功！"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "保存失败: " + ex.Message; pageMsgType = "error"; }
        BindStudentAnswers(sid);
    }

    // ========== 导入历史答卷 ==========
    protected void BtnImportAnswers_Click(object sender, EventArgs e)
    {
        int eid = 0; int.TryParse(DDLexam.SelectedValue, out eid);
        if (eid <= 0) { pageMsg = "请先选择考试"; pageMsgType = "error"; BindStudentList(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int importCount = 0;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int pid = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT Epid FROM ExamPublish WHERE Eid=@eid", conn))
                { cmd.Parameters.AddWithValue("@eid", eid); object v = cmd.ExecuteScalar(); if (v != null) int.TryParse(v.ToString(), out pid); }
                if (pid <= 0) { pageMsg = "考试信息无效"; pageMsgType = "error"; BindStudentList(); return; }

                // 获取试卷题目列表（按顺序）
                DataTable dtQ = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT Qid, Qtype, Qanswer FROM PaperQuestion WHERE Qpid=@pid ORDER BY Qsort, Qid", conn))
                { da.SelectCommand.Parameters.AddWithValue("@pid", pid); da.Fill(dtQ); }
                if (dtQ.Rows.Count == 0) { pageMsg = "试卷无题目"; pageMsgType = "error"; BindStudentList(); return; }

                // 获取 ExamPublish 的年级班级
                int egrade = 0, eclass = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT Egrade, Eclass FROM ExamPublish WHERE Eid=@eid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    { if (dr.Read()) { egrade = Convert.ToInt32(dr["Egrade"]); eclass = Convert.ToInt32(dr["Eclass"]); } dr.Close(); }
                }

                // 获取已提交的 SurveyFeedback
                DataTable dtFB = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT sf.Fsid, sf.Fselect FROM SurveyFeedback sf INNER JOIN Students s ON sf.Fsid=s.Sid WHERE sf.Fvid=@pid AND s.Sgrade=@grade AND s.Sclass=@class", conn))
                {
                    da.SelectCommand.Parameters.AddWithValue("@pid", pid);
                    da.SelectCommand.Parameters.AddWithValue("@grade", egrade);
                    da.SelectCommand.Parameters.AddWithValue("@class", eclass);
                    da.Fill(dtFB);
                }

                foreach (DataRow fbRow in dtFB.Rows)
                {
                    int sid = Convert.ToInt32(fbRow["Fsid"]);
                    // 检查是否已有 ExamAnswer
                    int existCnt = 0;
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=@sid", conn))
                    { chk.Parameters.AddWithValue("@eid", eid); chk.Parameters.AddWithValue("@sid", sid); existCnt = Convert.ToInt32(chk.ExecuteScalar()); }
                    if (existCnt > 0) continue; // 已有记录，跳过

                    string fselect = fbRow["Fselect"] != DBNull.Value ? fbRow["Fselect"].ToString() : "";
                    string[] parts = fselect.Split(new char[] { ',' }, StringSplitOptions.None);
                    int partIdx = 0;

                    for (int qi = 0; qi < dtQ.Rows.Count; qi++)
                    {
                        int qid = Convert.ToInt32(dtQ.Rows[qi]["Qid"]);
                        string qtype = dtQ.Rows[qi]["Qtype"] != DBNull.Value ? dtQ.Rows[qi]["Qtype"].ToString() : "";
                        string answer = "";

                        if (qtype == "scratch" || qtype == "python" || qtype == "pythonblock")
                        {
                            answer = "已提交"; // 编程题答案不在 Fselect 中
                        }
                        else if (partIdx < parts.Length)
                        {
                            answer = parts[partIdx].Trim();
                            partIdx++;
                        }

                        using (SqlCommand ins = new SqlCommand(
                            "INSERT INTO ExamAnswer(EAeid,EApid,EAsid,EAqid,EAanswer,EAscore,EAgraded,EAdate) VALUES(@eid,@pid,@sid,@qid,@answer,0,0,GETDATE())", conn))
                        {
                            ins.Parameters.AddWithValue("@eid", eid); ins.Parameters.AddWithValue("@pid", pid);
                            ins.Parameters.AddWithValue("@sid", sid); ins.Parameters.AddWithValue("@qid", qid);
                            ins.Parameters.AddWithValue("@answer", answer);
                            ins.ExecuteNonQuery();
                            importCount++;
                        }
                    }
                }
            }
            pageMsg = "导入完成！共导入 " + importCount + " 条答题记录"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "导入失败: " + ex.Message; pageMsgType = "error"; }
        BindStudentList();
    }

    // ========== 辅助方法 ==========
    protected string GetTypeName(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "未知";
        switch (typeVal.ToString())
        {
            case "single": case "单选": return "单选题";
            case "multiple": case "多选": return "多选题";
            case "truefalse": case "判断": return "判断题";
            case "fill": case "填空": return "填空题";
            case "essay": case "问答": return "简答题";
            case "scratch": return "Scratch编程";
            case "python": return "Python编程";
            case "pythonblock": return "Python拼图";
            default: return typeVal.ToString();
        }
    }
    protected string GetTypeColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "#94a3b8";
        switch (typeVal.ToString())
        {
            case "single": case "单选": return "#6366f1";
            case "multiple": case "多选": return "#8b5cf6";
            case "truefalse": case "判断": return "#0891b2";
            case "fill": case "填空": return "#059669";
            case "essay": case "问答": return "#d97706";
            case "scratch": return "#f97316";
            case "python": return "#7c3aed";
            case "pythonblock": return "#059669";
            default: return "#94a3b8";
        }
    }
    protected string GetTypeBgColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "#f1f5f9";
        switch (typeVal.ToString())
        {
            case "single": case "单选": return "#eef2ff";
            case "multiple": case "多选": return "#f5f3ff";
            case "truefalse": case "判断": return "#ecfeff";
            case "fill": case "填空": return "#ecfdf5";
            case "essay": case "问答": return "#fffbeb";
            case "scratch": return "#fff7ed";
            case "python": return "#f5f3ff";
            case "pythonblock": return "#ecfdf5";
            default: return "#f1f5f9";
        }
    }
    protected bool IsCodingType(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return false;
        string t = typeVal.ToString();
        return t == "scratch" || t == "python" || t == "pythonblock";
    }
    protected bool IsEssayType(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return false;
        string t = typeVal.ToString();
        return t == "essay" || t == "问答";
    }
    protected string FormatOptions(object a, object b, object c, object d)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        if (a != null && a != DBNull.Value && a.ToString().Trim().Length > 0) sb.Append("A. " + Server.HtmlEncode(a.ToString()) + "&emsp;");
        if (b != null && b != DBNull.Value && b.ToString().Trim().Length > 0) sb.Append("B. " + Server.HtmlEncode(b.ToString()) + "&emsp;");
        if (c != null && c != DBNull.Value && c.ToString().Trim().Length > 0) sb.Append("C. " + Server.HtmlEncode(c.ToString()) + "&emsp;");
        if (d != null && d != DBNull.Value && d.ToString().Trim().Length > 0) sb.Append("D. " + Server.HtmlEncode(d.ToString()));
        return sb.ToString();
    }
    protected bool IsCorrect(object studentAnswer, object correctAnswer)
    {
        string sa = studentAnswer != null && studentAnswer != DBNull.Value ? studentAnswer.ToString().Trim() : "";
        string ca = correctAnswer != null && correctAnswer != DBNull.Value ? correctAnswer.ToString().Trim() : "";
        return string.Equals(sa, ca, StringComparison.OrdinalIgnoreCase);
    }
    protected string GetGradeStatusText(object graded)
    {
        if (graded == null || graded == DBNull.Value) return "未批改";
        int g = Convert.ToInt32(graded);
        switch (g) { case 0: return "未批改"; case 1: return "自动批改"; case 2: return "手动批改"; default: return "未知"; }
    }
    protected string GetGradeStatusClass(object graded)
    {
        if (graded == null || graded == DBNull.Value) return "mk-gs-pending";
        int g = Convert.ToInt32(graded);
        switch (g) { case 0: return "mk-gs-pending"; case 1: return "mk-gs-auto"; case 2: return "mk-gs-manual"; default: return "mk-gs-pending"; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .mk-page { max-width: 1400px; width: 100%; margin: 0 auto; }
    .mk-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; }
    .mk-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .mk-title-icon { width: 42px; height: 42px; background: linear-gradient(135deg, #f59e0b, #fbbf24); border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(245,158,11,0.25); }
    .mk-title-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mk-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 54px; }

    .mk-msg { padding: 12px 18px; border-radius: 10px; font-size: 13px; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .mk-msg svg { width: 18px; height: 18px; flex-shrink: 0; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mk-msg-info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
    .mk-msg-info svg { stroke: #3b82f6; fill: none; }
    .mk-msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .mk-msg-success svg { stroke: #22c55e; fill: none; }
    .mk-msg-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .mk-msg-error svg { stroke: #ef4444; fill: none; }

    .mk-card { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.02); margin-bottom: 20px; overflow: hidden; }
    .mk-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; background: linear-gradient(180deg, #fafbfc, #f8f9fb); font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 10px; }
    .mk-card-head svg { width: 20px; height: 20px; stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mk-card-body { padding: 24px; }

    .mk-filter { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; flex-wrap: wrap; }
    .mk-filter-group { display: flex; align-items: center; gap: 8px; }
    .mk-filter-group label { font-size: 13px; font-weight: 600; color: #475569; white-space: nowrap; }
    .mk-filter-group select { padding: 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0; font-size: 13.5px; color: #334155; background: #f8fafc; outline: none; transition: all 0.2s; font-family: inherit; min-width: 320px; }
    .mk-filter-group select:focus { border-color: #fbbf24; background: #fff; box-shadow: 0 0 0 3px rgba(245,158,11,0.1); }

    .mk-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 22px; border-radius: 10px; font-size: 13.5px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; font-family: inherit; text-decoration: none; }
    .mk-btn:hover { transform: translateY(-1px); }
    .mk-btn-primary { background: linear-gradient(135deg, #f59e0b, #fbbf24); color: #fff; box-shadow: 0 4px 14px rgba(245,158,11,0.3); }
    .mk-btn-primary:hover { box-shadow: 0 6px 20px rgba(245,158,11,0.4); }
    .mk-btn-success { background: linear-gradient(135deg, #059669, #10b981); color: #fff; box-shadow: 0 4px 14px rgba(5,150,105,0.3); }
    .mk-btn-success:hover { box-shadow: 0 6px 20px rgba(5,150,105,0.4); }
    .mk-btn-row { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }

    .mk-list { display: flex; flex-direction: column; gap: 8px; }
    .mk-stu-item { display: flex; align-items: center; padding: 16px 20px; border-radius: 12px; border: 1px solid #f1f5f9; background: #fff; transition: all 0.2s; gap: 16px; }
    .mk-stu-item:hover { border-color: #fde68a; box-shadow: 0 4px 16px rgba(245,158,11,0.08); transform: translateY(-1px); }
    .mk-stu-avatar { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 16px; font-weight: 700; color: #fff; }
    .mk-stu-avatar-done { background: linear-gradient(135deg, #059669, #34d399); }
    .mk-stu-avatar-partial { background: linear-gradient(135deg, #f59e0b, #fbbf24); }
    .mk-stu-avatar-none { background: linear-gradient(135deg, #94a3b8, #cbd5e1); }
    .mk-stu-info { flex: 1; min-width: 0; }
    .mk-stu-name { font-size: 15px; font-weight: 600; color: #1e293b; margin-bottom: 4px; display: flex; align-items: center; gap: 10px; }
    .mk-stu-meta { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .mk-stu-meta-tag { font-size: 12px; color: #64748b; display: flex; align-items: center; gap: 4px; }
    .mk-stu-meta-tag svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mk-stu-score { font-size: 24px; font-weight: 700; min-width: 80px; text-align: center; flex-shrink: 0; }
    .mk-stu-score-done { color: #059669; }
    .mk-stu-score-partial { color: #f59e0b; }
    .mk-stu-score-none { color: #94a3b8; }
    .mk-stu-score small { font-size: 12px; font-weight: 500; color: #94a3b8; }
    .mk-stu-actions { display: flex; gap: 6px; flex-shrink: 0; }

    .mk-tag { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
    .mk-tag-done { background: #dcfce7; color: #166534; }
    .mk-tag-partial { background: #fef3c7; color: #92400e; }
    .mk-tag-none { background: #f1f5f9; color: #64748b; }
    .mk-tag-nosubmit { background: #fef2f2; color: #991b1b; }

    .mk-act-btn { display: inline-flex; align-items: center; justify-content: center; gap: 4px; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.15s; text-decoration: none; font-family: inherit; }
    .mk-act-btn:hover { background: #f1f5f9; border-color: #cbd5e1; }
    .mk-act-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mk-act-btn-view { color: #6366f1; border-color: #c7d2fe; }
    .mk-act-btn-view:hover { background: #eef2ff; }
    .mk-act-btn-reset { color: #f59e0b; border-color: #fde68a; }
    .mk-act-btn-reset:hover { background: #fffbeb; border-color: #fbbf24; }

    .mk-empty { text-align: center; padding: 60px 20px; }
    .mk-empty-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #f1f5f9, #e2e8f0); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
    .mk-empty-icon svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .mk-empty-text { font-size: 15px; color: #64748b; font-weight: 500; }
    .mk-empty-hint { font-size: 13px; color: #94a3b8; margin-top: 6px; }

    .mk-back-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 500; color: #64748b; background: #f1f5f9; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.15s; margin-bottom: 16px; text-decoration: none; font-family: inherit; }
    .mk-back-btn:hover { background: #e2e8f0; color: #334155; }

    .mk-detail-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
    .mk-detail-student { font-size: 16px; font-weight: 600; color: #1e293b; display: flex; align-items: center; gap: 10px; }
    .mk-detail-student svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; }

    .mk-q-list { display: flex; flex-direction: column; gap: 16px; }
    .mk-q-item { padding: 20px; border-radius: 12px; border: 2px solid #f1f5f9; background: #fafbfc; transition: all 0.2s; }
    .mk-q-item:hover { border-color: #fde68a; background: #fff; }
    /* 题目状态样式 - 根据得分区分 */
    .mk-q-item.mk-q-correct { border-color: #86efac; background: linear-gradient(to right, #f0fdf4, #fff); }
    .mk-q-item.mk-q-wrong { border-color: #fca5a5; background: linear-gradient(to right, #fef2f2, #fff); }
    .mk-q-item.mk-q-partial { border-color: #fde047; background: linear-gradient(to right, #fefce8, #fff); }
    .mk-q-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; flex-wrap: wrap; gap: 8px; }
    .mk-q-num { display: inline-flex; align-items: center; gap: 8px; }
    .mk-q-badge { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
    .mk-q-content { font-size: 14px; color: #1e293b; line-height: 1.7; margin-bottom: 10px; word-break: break-word; }
    .mk-q-content img { max-width: 100%; height: auto; border-radius: 8px; margin: 8px 0; display: block; border: 1px solid #e2e8f0; }
    .mk-q-options { font-size: 13px; color: #475569; line-height: 1.8; padding: 8px 14px; background: #f8fafc; border-radius: 8px; margin-bottom: 10px; }
    .mk-q-answer-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 10px; }
    .mk-q-answer-box { flex: 1; min-width: 200px; padding: 10px 14px; border-radius: 8px; font-size: 13px; }
    .mk-q-std-answer { background: #ecfdf5; border: 1px solid #a7f3d0; color: #166534; }
    .mk-q-stu-answer-wrong { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .mk-q-stu-answer-correct { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .mk-q-answer-label { font-size: 11px; font-weight: 600; color: #94a3b8; margin-bottom: 4px; text-transform: uppercase; }
    .mk-q-grade-row { display: flex; align-items: center; gap: 10px; padding: 10px 14px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; }
    .mk-q-grade-row label { font-size: 12px; font-weight: 600; color: #92400e; white-space: nowrap; }
    .mk-q-grade-row input[type="text"] { width: 70px; padding: 6px 10px; border-radius: 6px; border: 1.5px solid #fbbf24; font-size: 13px; text-align: center; color: #92400e; font-weight: 600; background: #fff; outline: none; transition: all 0.2s; font-family: inherit; }
    .mk-q-grade-row input[type="text"]:focus { border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,0.15); }
    .mk-q-grade-row span { font-size: 12px; color: #94a3b8; }

    .mk-gs { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 600; }
    .mk-gs-pending { background: #fef2f2; color: #ef4444; }
    .mk-gs-auto { background: #eff6ff; color: #3b82f6; }
    .mk-gs-manual { background: #f0fdf4; color: #059669; }

    /* 问答题答案显示 */
    .mk-q-essay-box { padding: 14px 18px; border-radius: 10px; background: #fafbfc; border: 1px solid #e2e8f0; font-size: 13.5px; line-height: 1.8; color: #334155; white-space: pre-wrap; word-break: break-word; margin-bottom: 10px; min-height: 60px; }

    /* 编程题预览区 */
    .mk-q-coding-area { margin-bottom: 10px; }
    .mk-q-coding-info { display: flex; align-items: center; gap: 10px; padding: 12px 16px; border-radius: 10px; background: #f8fafc; border: 1px solid #e2e8f0; margin-bottom: 8px; flex-wrap: wrap; }
    .mk-q-coding-tag { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
    .mk-q-coding-tag-scratch { background: #fff7ed; color: #c2410c; }
    .mk-q-coding-tag-python { background: #f5f3ff; color: #7c3aed; }
    .mk-q-coding-tag-pythonblock { background: #ecfdf5; color: #047857; }
    .mk-q-coding-tag-pass { background: #dcfce7; color: #166534; }
    .mk-q-coding-tag-nopass { background: #fef2f2; color: #991b1b; }
    .mk-q-coding-tag-nowork { background: #f1f5f9; color: #64748b; }
    .mk-q-preview-btn { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 600; border: 1px solid #c7d2fe; background: #eef2ff; color: #4f46e5; cursor: pointer; transition: all .15s; text-decoration: none; }
    .mk-q-preview-btn:hover { background: #ddd6fe; border-color: #a5b4fc; }
    .mk-q-preview-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; }
    .mk-q-code-box { padding: 14px 18px; border-radius: 10px; background: #1e293b; color: #e2e8f0; font-family: 'Consolas','Courier New',monospace; font-size: 13px; line-height: 1.7; white-space: pre-wrap; word-break: break-all; overflow-x: auto; max-height: 400px; overflow-y: auto; margin-bottom: 10px; }
    .mk-q-scratch-frame { width: 100%; height: 420px; border: 1px solid #e2e8f0; border-radius: 10px; margin-bottom: 10px; background: #fff; }

    /* 弹窗预览 */
    .mk-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); z-index: 9999; align-items: center; justify-content: center; }
    .mk-modal.mk-modal-show { display: flex; }
    .mk-modal-content { background: #fff; border-radius: 16px; width: 90%; max-width: 1200px; max-height: 90vh; overflow: hidden; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
    .mk-modal-header { padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; background: linear-gradient(135deg, #f8fafc, #fff); }
    .mk-modal-title { font-size: 16px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 10px; }
    .mk-modal-title svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; }
    .mk-modal-close { width: 32px; height: 32px; border-radius: 8px; border: none; background: #f1f5f9; color: #64748b; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s; }
    .mk-modal-close:hover { background: #e2e8f0; color: #1e293b; }
    .mk-modal-close svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
    .mk-modal-body { padding: 24px; overflow-y: auto; flex: 1; }
    .mk-modal-scratch-frame { width: 100%; height: 600px; border: 1px solid #e2e8f0; border-radius: 12px; background: #fff; }
    .mk-modal-python-frame { width: 100%; height: 600px; border: 1px solid #e2e8f0; border-radius: 12px; background: #1e1e1e; }
    .mk-modal-code-box { padding: 18px 22px; border-radius: 12px; background: #1e293b; color: #e2e8f0; font-family: 'Consolas','Courier New',monospace; font-size: 14px; line-height: 1.8; white-space: pre-wrap; word-break: break-all; overflow-x: auto; max-height: 600px; overflow-y: auto; }

    /* 弹窗学生信息 */
    .mk-modal-student-info { display: flex; align-items: center; gap: 16px; padding: 16px 20px; background: linear-gradient(135deg, #f8fafc, #fff); border-radius: 12px; border: 1px solid #e2e8f0; height: 100%; }
    .mk-modal-student-avatar { width: 52px; height: 52px; border-radius: 12px; background: linear-gradient(135deg, #dbeafe, #bfdbfe); display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 700; color: #2563eb; flex-shrink: 0; }
    .mk-modal-student-details { flex: 1; min-width: 0; }
    .mk-modal-student-name { font-size: 16px; font-weight: 700; color: #1e293b; margin-bottom: 6px; }
    .mk-modal-student-meta { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .mk-modal-student-tag { display: inline-flex; align-items: center; gap: 4px; font-size: 12px; color: #64748b; }
    .mk-modal-student-tag svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; }

    /* 顶部两列布局容器 */
    .mk-modal-top-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px; align-items: stretch; }
    @media (max-width: 900px) {
        .mk-modal-top-grid { grid-template-columns: 1fr; }
    }

    /* 弹窗打分区 */
    .mk-modal-grade-section { padding: 16px 20px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; display: flex; flex-direction: column; justify-content: center; height: 100%; }
    .mk-modal-grade-title { font-size: 14px; font-weight: 700; color: #92400e; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
    .mk-modal-grade-title svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
    .mk-modal-grade-row { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
    .mk-modal-grade-input { display: flex; align-items: center; gap: 8px; }
    .mk-modal-grade-input label { font-size: 13px; font-weight: 600; color: #92400e; white-space: nowrap; }
    .mk-modal-grade-input input[type="text"] { width: 80px; padding: 8px 12px; border-radius: 8px; border: 1.5px solid #fbbf24; font-size: 14px; text-align: center; color: #92400e; font-weight: 700; background: #fff; outline: none; transition: all 0.2s; font-family: inherit; }
    .mk-modal-grade-input input[type="text"]:focus { border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,0.15); }
    .mk-modal-grade-input span { font-size: 13px; color: #94a3b8; }
    .mk-modal-grade-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 20px; border-radius: 8px; border: none; background: linear-gradient(135deg, #059669, #10b981); color: #fff; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; font-family: inherit; }
    .mk-modal-grade-btn:hover { transform: translateY(-1px); box-shadow: 0 4px 14px rgba(5,150,105,0.3); }
    .mk-modal-grade-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }
    .mk-modal-grade-msg { margin-top: 10px; padding: 8px 12px; border-radius: 6px; font-size: 12px; display: none; }
    .mk-modal-grade-msg.mk-msg-success { background: #dcfce7; color: #166534; display: block; }
    .mk-modal-grade-msg.mk-msg-error { background: #fef2f2; color: #991b1b; display: block; }

    /* 统计板块 */
    .mk-stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 20px; }
    .mk-stat-card { padding: 18px 20px; border-radius: 12px; border: 1px solid #e8ecf1; background: linear-gradient(135deg, #fafbfc, #fff); display: flex; align-items: center; gap: 14px; transition: all 0.2s; }
    .mk-stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.06); }
    .mk-stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .mk-stat-icon svg { width: 24px; height: 24px; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; fill: none; }
    .mk-stat-icon-total { background: linear-gradient(135deg, #dbeafe, #bfdbfe); }
    .mk-stat-icon-total svg { stroke: #2563eb; }
    .mk-stat-icon-correct { background: linear-gradient(135deg, #d1fae5, #a7f3d0); }
    .mk-stat-icon-correct svg { stroke: #059669; }
    .mk-stat-icon-wrong { background: linear-gradient(135deg, #fecaca, #fca5a5); }
    .mk-stat-icon-wrong svg { stroke: #dc2626; }
    .mk-stat-icon-score { background: linear-gradient(135deg, #fde68a, #fcd34d); }
    .mk-stat-icon-score svg { stroke: #d97706; }
    .mk-stat-info { flex: 1; min-width: 0; }
    .mk-stat-label { font-size: 12px; color: #64748b; margin-bottom: 4px; }
    .mk-stat-value { font-size: 24px; font-weight: 700; color: #1e293b; line-height: 1; }
    .mk-stat-value small { font-size: 14px; font-weight: 500; color: #94a3b8; margin-left: 4px; }

    /* 题目分组 */
    .mk-q-section { margin-bottom: 24px; }
    .mk-q-section-header { display: flex; align-items: center; gap: 10px; padding: 12px 18px; border-radius: 10px; margin-bottom: 12px; font-size: 15px; font-weight: 600; }
    .mk-q-section-header svg { width: 20px; height: 20px; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; fill: none; }
    .mk-q-section-correct { background: linear-gradient(135deg, #ecfdf5, #d1fae5); color: #166534; border: 1px solid #a7f3d0; }
    .mk-q-section-correct svg { stroke: #059669; }
    .mk-q-section-wrong { background: linear-gradient(135deg, #fef2f2, #fecaca); color: #991b1b; border: 1px solid #fca5a5; }
    .mk-q-section-wrong svg { stroke: #dc2626; }
    .mk-q-section-subjective { background: linear-gradient(135deg, #fffbeb, #fef3c7); color: #92400e; border: 1px solid #fde68a; }
    .mk-q-section-subjective svg { stroke: #f59e0b; }

    .mk-btn-outline { background: #fff; color: #475569; border: 1.5px solid #e2e8f0; box-shadow: none; }
    .mk-btn-outline:hover { border-color: #fbbf24; background: #fffbeb; box-shadow: 0 2px 8px rgba(245,158,11,0.1); }

    @media (max-width: 768px) {
        .mk-filter { flex-direction: column; align-items: stretch; }
        .mk-filter-group select { min-width: 100%; }
        .mk-stu-item { flex-direction: column; align-items: flex-start; }
        .mk-stu-actions { width: 100%; justify-content: flex-end; }
        .mk-q-answer-row { flex-direction: column; }
    }
</style>
<script src="../js/jquery.min.js" type="text/javascript"></script>

<div class="mk-page">
    <asp:HiddenField ID="HiddenStudentId" runat="server" Value="" />

    <div class="mk-header">
        <div>
            <div class="mk-title">
                <span class="mk-title-icon">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                </span>
                阅卷管理
            </div>
            <div class="mk-subtitle">查看学生答卷，自动批改客观题，手动评分主观题</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="mk-msg mk-msg-<%= pageMsgType %>">
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

    <!-- ========== 学生列表面板 ========== -->
    <asp:Panel ID="PanelList" runat="server" Visible="true">
        <div class="mk-card">
            <div class="mk-card-head">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                选择考试
            </div>
            <div class="mk-card-body">
                <div class="mk-filter">
                    <div class="mk-filter-group">
                        <label>考试：</label>
                        <asp:DropDownList ID="DDLexam" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DDLexam_SelectedIndexChanged" />
                    </div>
                </div>
                <div class="mk-btn-row">
                    <asp:Button ID="BtnAutoGrade" runat="server" Text="一键自动阅卷（客观题）" OnClick="BtnAutoGrade_Click" CssClass="mk-btn mk-btn-primary"
                        OnClientClick="return confirm('确定要自动批改所有未阅卷的客观题吗？');" />
                    <asp:Button ID="BtnImportAnswers" runat="server" Text="导入历史答卷" OnClick="BtnImportAnswers_Click" CssClass="mk-btn mk-btn-outline"
                        OnClientClick="return confirm('将从 SurveyFeedback 导入未录入的学生答卷到 ExamAnswer 表，确定继续吗？');" />
                </div>
            </div>
        </div>

        <div class="mk-card">
            <div class="mk-card-head">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                学生答卷列表
            </div>
            <div class="mk-card-body">
                <!-- 统计板块 -->
                <div class="mk-stats-grid" id="mkListStatsGrid" style="margin-bottom: 20px; display: none;">
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #dbeafe, #bfdbfe);">
                            <svg viewBox="0 0 24 24" style="stroke: #2563eb;"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">总学生数</div>
                            <div class="mk-stat-value" id="statTotalStudents">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #d1fae5, #a7f3d0);">
                            <svg viewBox="0 0 24 24" style="stroke: #059669;"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">已提交</div>
                            <div class="mk-stat-value" id="statSubmittedStudents" style="color: #059669;">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #fef3c7, #fde68a);">
                            <svg viewBox="0 0 24 24" style="stroke: #d97706;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">未提交</div>
                            <div class="mk-stat-value" id="statUnsubmittedStudents" style="color: #d97706;">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #e9d5ff, #d8b4fe);">
                            <svg viewBox="0 0 24 24" style="stroke: #9333ea;"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">平均分</div>
                            <div class="mk-stat-value" id="statAverageScore" style="color: #9333ea;">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #fecaca, #fca5a5);">
                            <svg viewBox="0 0 24 24" style="stroke: #dc2626;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">待批改</div>
                            <div class="mk-stat-value" id="statUngradedCount" style="color: #dc2626;">0</div>
                        </div>
                    </div>
                </div>

                <asp:Repeater ID="RptStudents" runat="server" OnItemCommand="RptStudents_ItemCommand">
                    <HeaderTemplate><div class="mk-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="mk-stu-item">
                            <div class='mk-stu-avatar <%# Convert.ToInt32(Eval("AnswerCount")) == 0 ? "mk-stu-avatar-none" : (Convert.ToInt32(Eval("UngradedCount")) == 0 ? "mk-stu-avatar-done" : "mk-stu-avatar-partial") %>'>
                                <%# Server.HtmlEncode(Eval("Sname").ToString().Length > 0 ? Eval("Sname").ToString().Substring(0, 1) : "?") %>
                            </div>
                            <div class="mk-stu-info">
                                <div class="mk-stu-name">
                                    <%# Server.HtmlEncode(Eval("Sname").ToString()) %>
                                    <%# Convert.ToInt32(Eval("AnswerCount")) == 0
                                        ? "<span class='mk-tag mk-tag-nosubmit'>未提交</span>"
                                        : (Convert.ToInt32(Eval("UngradedCount")) == 0
                                            ? "<span class='mk-tag mk-tag-done'>已批完</span>"
                                            : "<span class='mk-tag mk-tag-partial'>待批改 " + Eval("UngradedCount") + " 题</span>") %>
                                </div>
                                <div class="mk-stu-meta">
                                    <span class="mk-stu-meta-tag">
                                        <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                                        学号：<%# Eval("Snum") %>
                                    </span>
                                    <span class="mk-stu-meta-tag">
                                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                        答题：<%# Eval("AnswerCount") %> 题
                                    </span>
                                </div>
                            </div>
                            <div class="mk-stu-score <%# Convert.ToInt32(Eval("AnswerCount")) == 0 ? "mk-stu-score-none" : (Convert.ToInt32(Eval("UngradedCount")) == 0 ? "mk-stu-score-done" : "mk-stu-score-partial") %>">
                                <%# Eval("TotalScore") %><small>分</small>
                            </div>
                            <div class="mk-stu-actions">
                                <asp:LinkButton runat="server" CssClass="mk-act-btn mk-act-btn-view" CausesValidation="false"
                                    CommandName="ViewAnswer" CommandArgument='<%# Eval("Sid") %>'
                                    Visible='<%# Convert.ToInt32(Eval("AnswerCount")) > 0 %>'>
                                    <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                    查看答卷
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="mk-act-btn mk-act-btn-reset" CausesValidation="false"
                                    CommandName="ResetExam" CommandArgument='<%# Eval("Sid") %>'
                                    Visible='<%# Convert.ToInt32(Eval("AnswerCount")) > 0 %>'
                                    OnClientClick='return confirm("确定要让该学生重新开始考试吗？\n\n重新开始后：\n• 学生可以重新答题\n• 上次提交的答案将保留并显示\n• 批改数据将被清除\n• 得分将重置为0\n• 批改状态将重置为未批改");'>
                                    <svg viewBox="0 0 24 24"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M3 21v-5h5"/></svg>
                                    重新开始
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="PanelEmpty" runat="server" Visible='<%# RptStudents.Items.Count == 0 %>'>
                    <div class="mk-empty">
                        <div class="mk-empty-icon">
                            <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                        </div>
                        <div class="mk-empty-text">请先选择一场考试</div>
                        <div class="mk-empty-hint">在上方选择已发布的考试，即可查看学生答卷情况</div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <!-- ========== 答卷详情面板 ========== -->
    <asp:Panel ID="PanelDetail" runat="server" Visible="false">
        <asp:Button ID="BtnBackToList" runat="server" Text="← 返回列表" OnClick="BtnBackToList_Click" CssClass="mk-back-btn" CausesValidation="false" />

        <div class="mk-card">
            <div class="mk-card-head">
                <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                答卷详情
            </div>
            <div class="mk-card-body">
                <!-- 统计板块 -->
                <div class="mk-stats-grid" id="mkStatsGrid" style="display: none;">
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #dbeafe, #bfdbfe);">
                            <svg viewBox="0 0 24 24" style="stroke: #2563eb;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">总题数</div>
                            <div class="mk-stat-value" id="statTotalQuestions">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #d1fae5, #a7f3d0);">
                            <svg viewBox="0 0 24 24" style="stroke: #059669;"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">正确题数</div>
                            <div class="mk-stat-value" id="statCorrectQuestions" style="color: #059669;">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #fee2e2, #fecaca);">
                            <svg viewBox="0 0 24 24" style="stroke: #dc2626;"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">错误题数</div>
                            <div class="mk-stat-value" id="statWrongQuestions" style="color: #dc2626;">0</div>
                        </div>
                    </div>
                    <div class="mk-stat-card">
                        <div class="mk-stat-icon" style="background: linear-gradient(135deg, #fef3c7, #fde68a);">
                            <svg viewBox="0 0 24 24" style="stroke: #d97706;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        </div>
                        <div class="mk-stat-body">
                            <div class="mk-stat-label">当前得分</div>
                            <div class="mk-stat-value" id="statCurrentScore" style="color: #d97706;">0</div>
                        </div>
                    </div>
                </div>

                <div class="mk-detail-header">
                    <div class="mk-detail-student">
                        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        <asp:Label ID="LblStudentName" runat="server" />
                    </div>
                    <asp:Button ID="BtnSaveGrade" runat="server" Text="保存评分" OnClick="BtnSaveGrade_Click" CssClass="mk-btn mk-btn-success" />
                </div>

                <asp:Repeater ID="RptAnswers" runat="server">
                    <HeaderTemplate><div class="mk-q-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="mk-q-item">
                            <asp:HiddenField ID="HfEAid" runat="server" Value='<%# Eval("EAid") %>' />
                            <asp:HiddenField ID="HfQid" runat="server" Value='<%# Eval("EAqid") %>' />
                            <div class="mk-q-header">
                                <div class="mk-q-num">
                                    <span class="mk-q-badge" style="background:<%# GetTypeBgColor(Eval("Qtype")) %>;color:<%# GetTypeColor(Eval("Qtype")) %>;"><%# GetTypeName(Eval("Qtype")) %></span>
                                    <span class='mk-gs <%# GetGradeStatusClass(Eval("EAgraded")) %>'><%# GetGradeStatusText(Eval("EAgraded")) %></span>
                                </div>
                                <div style="font-size:12px;color:#64748b;">
                                    得分：<strong style="color:#f59e0b;"><%# Eval("EAscore") %></strong> / <%# Eval("MaxScore") %> 分
                                </div>
                            </div>
                            <div class="mk-q-content"><%# Eval("Qcontent") %></div>
                            <%# (Eval("Qtype").ToString() == "single" || Eval("Qtype").ToString() == "multiple" || Eval("Qtype").ToString() == "单选" || Eval("Qtype").ToString() == "多选" || Eval("Qtype").ToString() == "判断" || Eval("Qtype").ToString() == "truefalse") ? "<div class='mk-q-options'>" + FormatOptions(Eval("Qoption_a"), Eval("Qoption_b"), Eval("Qoption_c"), Eval("Qoption_d")) + "</div>" : "" %>

                            <% /* 问答题显示 */ %>
                            <%# IsEssayType(Eval("Qtype")) ? "<div class='mk-q-essay-box'>" + Server.HtmlEncode(Eval("EAanswer") != DBNull.Value ? Eval("EAanswer").ToString() : "未作答") + "</div>" : "" %>

                            <% /* 编程题显示 */ %>
                            <%# IsCodingType(Eval("Qtype")) ? "<div class='mk-q-coding-area' data-sid='" + HiddenStudentId.Value + "' data-qid='" + Eval("EAqid") + "' data-qtype='" + Eval("Qtype") + "'><div class='mk-q-coding-info'><span class='mk-q-coding-tag mk-q-coding-tag-" + Eval("Qtype") + "'>" + GetTypeName(Eval("Qtype")) + "</span><span style='font-size:12px;color:#64748b;'>点击“加载预览”查看学生作品</span><button type='button' class='mk-q-preview-btn' onclick='loadCodingPreview(this)'><svg viewBox='0 0 24 24'><path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/></svg>加载预览</button></div><div class='mk-q-coding-preview'></div></div>" : "" %>

                            <% /* 客观题答案对比 */ %>
                            <%# !IsCodingType(Eval("Qtype")) && !IsEssayType(Eval("Qtype")) ? "<div class='mk-q-answer-row'><div class='mk-q-answer-box mk-q-std-answer'><div class='mk-q-answer-label'>标准答案</div>" + Server.HtmlEncode(Eval("Qanswer") != DBNull.Value ? Eval("Qanswer").ToString() : "无") + "</div><div class='mk-q-answer-box " + (IsCorrect(Eval("EAanswer"), Eval("Qanswer")) ? "mk-q-stu-answer-correct" : "mk-q-stu-answer-wrong") + "'><div class='mk-q-answer-label'>学生答案</div>" + Server.HtmlEncode(Eval("EAanswer") != DBNull.Value ? Eval("EAanswer").ToString() : "未作答") + "</div></div>" : "" %>

                            <div class="mk-q-grade-row">
                                <label>评分：</label>
                                <asp:TextBox ID="TxtItemScore" runat="server" Text='<%# Eval("EAscore") %>' MaxLength="4" />
                                <span>满分 <%# Eval("MaxScore") %> 分</span>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>

                <div style="margin-top: 20px; text-align: right;">
                    <asp:Button ID="BtnSaveGrade2" runat="server" Text="保存评分" OnClick="BtnSaveGrade_Click" CssClass="mk-btn mk-btn-success" />
                </div>
            </div>
        </div>
    </asp:Panel>
</div>

<!-- 编程作品预览弹窗 -->
<div class="mk-modal" id="mkPreviewModal">
    <div class="mk-modal-content">
        <div class="mk-modal-header">
            <div class="mk-modal-title">
                <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                <span id="mkModalTitle">作品预览</span>
            </div>
            <button class="mk-modal-close" onclick="closePreviewModal()">
                <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="mk-modal-body" id="mkModalBody">
            <div style="text-align:center;padding:40px;color:#94a3b8;">加载中...</div>
        </div>
    </div>
</div>

<script type="text/javascript">
    // 页面加载完成后，分组显示题目并统计
    $(document).ready(function() {
        organizeQuestions();
    });

    function organizeQuestions() {
        var originalList = $('#mkOriginalList');
        if (originalList.length === 0) return;

        var correctList = $('#mkCorrectList');
        var wrongList = $('#mkWrongList');
        var subjectiveList = $('#mkSubjectiveList');

        var correctCount = 0, wrongCount = 0, subjectiveCount = 0, totalScore = 0;

        originalList.find('.mk-q-item').each(function() {
            var item = $(this);
            var isSubjective = item.data('is-subjective') === 'True' || item.data('is-subjective') === true;
            var isCorrect = item.data('is-correct') === 'True' || item.data('is-correct') === true;
            var qtype = item.data('qtype') || '';
            
            // 获取得分
            var scoreText = item.find('.mk-q-header div:last').text();
            var scoreMatch = scoreText.match(/得分：(\d+)/);
            if (scoreMatch) {
                totalScore += parseInt(scoreMatch[1]);
            }

            var clonedItem = item.clone(true);

            if (isSubjective) {
                // 主观题（问答题、编程题）
                subjectiveList.append(clonedItem);
                subjectiveCount++;
            } else if (isCorrect) {
                // 正确的客观题
                correctList.append(clonedItem);
                correctCount++;
            } else {
                // 错误的客观题
                wrongList.append(clonedItem);
                wrongCount++;
            }
        });

        var totalCount = correctCount + wrongCount + subjectiveCount;

        // 更新统计数据
        $('#statTotal').text(totalCount);
        $('#statCorrect').text(correctCount);
        $('#statWrong').text(wrongCount);
        $('#statScore').text(totalScore);

        // 更新分组标题
        $('#correctCount').text(correctCount);
        $('#wrongCount').text(wrongCount);
        $('#subjectiveCount').text(subjectiveCount);

        // 显示/隐藏分组
        if (correctCount > 0) $('#mkCorrectSection').show();
        if (wrongCount > 0) $('#mkWrongSection').show();
        if (subjectiveCount > 0) $('#mkSubjectiveSection').show();

        // 隐藏原始列表
        originalList.hide();
    }

    // 编程题作品预览加载
    var currentPreviewData = null; // 保存当前预览的数据，用于打分

    function loadCodingPreview(btn) {
        var area = $(btn).closest('.mk-q-coding-area');
        var sid = area.data('sid');
        var qid = area.data('qid');
        var qtype = area.data('qtype');

        $(btn).text('加载中...').prop('disabled', true);

        $.ajax({
            url: 'getexamwork.ashx?sid=' + sid + '&qid=' + qid,
            type: 'GET',
            dataType: 'json'
        }).done(function(data) {
            if (data.error) {
                alert('加载失败：' + data.error);
                return;
            }
            if (!data.found) {
                var msg = '未找到该学生的编程作品。\n\n';
                
                // 显示调试信息
                if (data.debug) {
                    msg += '调试信息：\n';
                    msg += '- 学生ID: ' + data.debug.sid + '\n';
                    msg += '- 题目ID: ' + data.debug.qid + '\n';
                    msg += '- 题目类型: ' + data.debug.qtype + '\n';
                    msg += '- 该学生作品总数: ' + data.debug.totalWorks + '\n';
                    
                    if (data.debug.latestWork) {
                        msg += '- 最近作品: Wid=' + data.debug.latestWork.wid + 
                               ', Wmid=' + data.debug.latestWork.wmid + 
                               ', Wlid=' + data.debug.latestWork.wlid + 
                               ', 类型=' + data.debug.latestWork.wtype + 
                               ', 时间=' + data.debug.latestWork.wdate + '\n';
                    }
                    msg += '\n';
                }
                
                msg += '可能原因：\n';
                msg += '1. 学生尚未提交该题目的作品\n';
                msg += '2. 作品保存时题目ID不匹配（Wmid或Wlid与题目ID不一致）\n';
                msg += '3. 学生使用了不同的账号提交\n\n';
                msg += '建议：\n';
                msg += '- 请确认学生是否已在考试页面完成并保存该编程题\n';
                msg += '- 如果学生确实已保存，可能是系统题目ID映射问题\n';
                msg += '- 可以尝试查看该学生的最近作品（如果有的话）';
                
                alert(msg);
                return;
            }

            // 保存数据并在弹窗中显示
            currentPreviewData = { data: data, qtype: qtype, sid: sid, qid: qid };
            showPreviewModal(data, qtype, sid, qid);
        }).fail(function(xhr, status, error) {
            alert('网络请求失败：' + error);
        }).always(function() {
            $(btn).html('<svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>加载预览').prop('disabled', false);
        });
    }

    // 显示预览弹窗
    function showPreviewModal(data, qtype, sid, qid) {
        var modal = document.getElementById('mkPreviewModal');
        var modalTitle = document.getElementById('mkModalTitle');
        var modalBody = document.getElementById('mkModalBody');

        var typeNames = {
            'scratch': 'Scratch作品预览',
            'python': 'Python代码预览',
            'pythonblock': 'Python拼图代码预览'
        };
        modalTitle.textContent = typeNames[qtype] || '作品预览';

        var html = '';
        
        // 两列布局容器开始
        html += '<div class="mk-modal-top-grid">';
        
        // 左列：学生信息
        var studentName = data.sname || '未知';
        var studentNum = data.snum || '未知';
        var studentGrade = data.sgrade || 0;
        var studentClass = data.sclass || 0;
        var studentInitial = studentName.length > 0 ? studentName.substring(0, 1) : '?';
        
        html += '<div class="mk-modal-student-info">';
        html += '<div class="mk-modal-student-avatar">' + studentInitial + '</div>';
        html += '<div class="mk-modal-student-details">';
        html += '<div class="mk-modal-student-name">' + studentName + '</div>';
        html += '<div class="mk-modal-student-meta">';
        html += '<span class="mk-modal-student-tag"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>学号：' + studentNum + '</span>';
        html += '<span class="mk-modal-student-tag"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>班级：' + studentGrade + '年级' + studentClass + '班</span>';
        html += '</div></div></div>';
        
        // 右列：打分区域
        html += '<div class="mk-modal-grade-section">';
        html += '<div class="mk-modal-grade-title">';
        html += '<svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';
        html += '作品评分';
        html += '</div>';
        html += '<div class="mk-modal-grade-row">';
        html += '<div class="mk-modal-grade-input">';
        html += '<label>得分：</label>';
        html += '<input type="text" id="mkModalScore" placeholder="0" maxlength="4" />';
        html += '<span id="mkModalMaxScore">/ -- 分</span>';
        html += '</div>';
        html += '<button class="mk-modal-grade-btn" onclick="saveModalGrade()">';
        html += '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>';
        html += '保存评分';
        html += '</button>';
        html += '</div>';
        html += '<div class="mk-modal-grade-msg" id="mkModalGradeMsg"></div>';
        html += '</div>';
        
        // 两列布局容器结束
        html += '</div>';
        
        // 提交时间信息
        if (data.wdate) {
            html += '<div class="mk-q-coding-info" style="margin-bottom:20px;">';
            html += '<span style="font-size:12px;color:#94a3b8;">提交时间：' + data.wdate + '</span>';
            html += '</div>';
        }

        // 作品内容展示区域
        html += '<div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:20px;margin-bottom:20px;">';
        
        if (qtype === 'scratch') {
            // Scratch: 用 iframe 加载完整编辑器（显示代码块和舞台）
            if (data.wid > 0) {
                // 使用自定义查看器，可以看到代码块和舞台
                var viewerUrl = '../scratch/viewer.html?project=../student/getproject.ashx?id=' + data.wid;
                html += '<iframe class="mk-modal-scratch-frame" src="' + viewerUrl + '" frameborder="0" allowfullscreen></iframe>';
                html += '<div style="font-size:12px;color:#94a3b8;margin-top:12px;text-align:center;">提示：如编辑器未正确加载，可 <a href="../student/getproject.ashx?id=' + data.wid + '" target="_blank" style="color:#6366f1;text-decoration:underline;">下载 .sb3 文件</a> 后手动查看</div>';
            } else {
                html += '<div style="text-align:center;padding:40px;color:#94a3b8;">作品ID无效</div>';
            }
        } else if (qtype === 'python' || qtype === 'pythonblock') {
            // Python / PythonBlock: 用 iframe 加载完整查看器（类似Scratch）
            if (data.wid > 0) {
                // 优先使用wid
                var viewerUrl = '../student/pythonviewer.html?id=' + data.wid;
                html += '<iframe class="mk-modal-python-frame" src="' + viewerUrl + '" frameborder="0"></iframe>';
                html += '<div style="font-size:12px;color:#94a3b8;margin-top:12px;text-align:center;">提示：查看器仅用于代码展示，不支持运行</div>';
            } else {
                // 如果没有wid，尝试通过sid+qid查找
                var viewerUrl = '../student/pythonviewer.html?sid=' + sid + '&qid=' + qid + '&qtype=' + qtype;
                html += '<iframe class="mk-modal-python-frame" src="' + viewerUrl + '" frameborder="0"></iframe>';
                html += '<div style="font-size:12px;color:#94a3b8;margin-top:12px;text-align:center;">提示：查看器仅用于代码展示，不支持运行</div>';
            }
        } else {
            // 其他类型：显示代码文本
            var code = data.wcode || '';
            // 尝试解码（存储时可能是 base64 + encodeURIComponent）
            try {
                if (code && !code.match(/[\n\r ]/) && code.match(/^[A-Za-z0-9+\/=]+$/)) {
                    code = decodeURIComponent(atob(code));
                }
            } catch(e) { /* 保持原样 */ }
            
            if (code) {
                html += '<div class="mk-modal-code-box">' + $('<span/>').text(code).html() + '</div>';
            } else {
                html += '<div style="text-align:center;padding:40px;color:#94a3b8;">代码内容为空</div>';
            }
        }
        
        html += '</div>';

        modalBody.innerHTML = html;
        
        // 获取当前题目的得分和满分
        loadCurrentScore(sid, qid);
        
        modal.classList.add('mk-modal-show');
    }

    // 加载当前题目的得分和满分
    function loadCurrentScore(sid, qid) {
        // 从页面中查找对应题目的得分信息
        var qItem = $('[data-sid="' + sid + '"][data-qid="' + qid + '"]').closest('.mk-q-item');
        if (qItem.length > 0) {
            var scoreText = qItem.find('.mk-q-header div:last').text();
            var scoreMatch = scoreText.match(/得分：(\d+)\s*\/\s*(\d+)/);
            if (scoreMatch) {
                var currentScore = scoreMatch[1];
                var maxScore = scoreMatch[2];
                $('#mkModalScore').val(currentScore).attr('max', maxScore);
                $('#mkModalMaxScore').text('/ ' + maxScore + ' 分').attr('data-max', maxScore);
                
                // 添加实时验证
                $('#mkModalScore').off('input').on('input', function() {
                    var val = parseInt($(this).val());
                    var max = parseInt(maxScore);
                    if (!isNaN(val) && !isNaN(max) && val > max) {
                        $(this).css('border-color', '#ef4444');
                        $('#mkModalGradeMsg').removeClass('mk-msg-success').addClass('mk-msg-error').text('评分不能超过满分（' + max + '分）');
                    } else {
                        $(this).css('border-color', '');
                        $('#mkModalGradeMsg').removeClass('mk-msg-error mk-msg-success').text('');
                    }
                });
            }
        }
    }

    // 保存弹窗中的评分
    function saveModalGrade() {
        if (!currentPreviewData) {
            alert('数据错误，请重新打开预览');
            return;
        }

        var score = $('#mkModalScore').val().trim();
        if (score === '') {
            alert('请输入分数');
            return;
        }

        var scoreNum = parseInt(score);
        if (isNaN(scoreNum) || scoreNum < 0) {
            alert('请输入有效的分数');
            return;
        }

        var sid = currentPreviewData.sid;
        var qid = currentPreviewData.qid;

        // 找到对应题目的输入框并更新
        var qItem = $('[data-sid="' + sid + '"][data-qid="' + qid + '"]').closest('.mk-q-item');
        if (qItem.length > 0) {
            var scoreInput = qItem.find('input[id*="TxtItemScore"]');
            if (scoreInput.length > 0) {
                // 获取满分
                var maxScoreText = qItem.find('.mk-q-grade-row span').text();
                var maxScore = parseInt(maxScoreText.match(/\d+/));
                
                // 验证分数不超过满分
                if (!isNaN(maxScore) && scoreNum > maxScore) {
                    alert('评分不能超过满分（' + maxScore + '分）');
                    return;
                }
                
                scoreInput.val(scoreNum);
                
                // 显示成功消息
                var msgDiv = $('#mkModalGradeMsg');
                msgDiv.removeClass('mk-msg-error').addClass('mk-msg-success');
                msgDiv.text('评分已更新！请点击页面底部的"保存评分"按钮保存所有修改。');
                
                // 3秒后隐藏消息
                setTimeout(function() {
                    msgDiv.removeClass('mk-msg-success');
                }, 3000);
            } else {
                var msgDiv = $('#mkModalGradeMsg');
                msgDiv.removeClass('mk-msg-success').addClass('mk-msg-error');
                msgDiv.text('未找到评分输入框');
            }
        } else {
            var msgDiv = $('#mkModalGradeMsg');
            msgDiv.removeClass('mk-msg-success').addClass('mk-msg-error');
            msgDiv.text('未找到对应题目');
        }
    }

    // 关闭预览弹窗
    function closePreviewModal() {
        var modal = document.getElementById('mkPreviewModal');
        modal.classList.remove('mk-modal-show');
        currentPreviewData = null;
    }

    // 点击弹窗背景关闭
    $(document).on('click', '#mkPreviewModal', function(e) {
        if (e.target.id === 'mkPreviewModal') {
            closePreviewModal();
        }
    });

    // ESC键关闭弹窗
    $(document).on('keydown', function(e) {
        if (e.key === 'Escape' || e.keyCode === 27) {
            closePreviewModal();
        }
    });

    // ========== 页面加载时计算统计数据并分类题目 ==========
    $(document).ready(function() {
        calculateStatistics();
        classifyQuestions();
        calculateListStatistics();
    });

    // 计算学生列表统计数据
    function calculateListStatistics() {
        var totalStudents = 0;
        var submittedStudents = 0;
        var unsubmittedStudents = 0;
        var totalScore = 0;
        var ungradedCount = 0;

        $('.mk-stu-item').each(function() {
            totalStudents++;
            
            // 获取答题数量
            var answerCountText = $(this).find('.mk-stu-meta-tag:contains("答题")').text();
            var answerMatch = answerCountText.match(/(\d+)/);
            var answerCount = answerMatch ? parseInt(answerMatch[1]) : 0;
            
            if (answerCount > 0) {
                submittedStudents++;
            } else {
                unsubmittedStudents++;
            }
            
            // 获取得分
            var scoreText = $(this).find('.mk-stu-score').text();
            var scoreMatch = scoreText.match(/(\d+)/);
            if (scoreMatch) {
                totalScore += parseInt(scoreMatch[1]);
            }
            
            // 检查是否有待批改的题目
            var tagText = $(this).find('.mk-tag').text();
            if (tagText.indexOf('待批改') >= 0) {
                var ungradedMatch = tagText.match(/待批改\s*(\d+)/);
                if (ungradedMatch) {
                    ungradedCount += parseInt(ungradedMatch[1]);
                }
            }
        });

        // 计算平均分
        var averageScore = submittedStudents > 0 ? Math.round(totalScore / submittedStudents * 10) / 10 : 0;

        // 更新统计显示
        $('#statTotalStudents').text(totalStudents);
        $('#statSubmittedStudents').text(submittedStudents);
        $('#statUnsubmittedStudents').text(unsubmittedStudents);
        $('#statAverageScore').text(averageScore);
        $('#statUngradedCount').text(ungradedCount);
        
        // 显示/隐藏统计板块：只有在有已提交学生时才显示
        if (submittedStudents > 0) {
            $('#mkListStatsGrid').show();
        } else {
            $('#mkListStatsGrid').hide();
        }
    }

    // 计算统计数据
    function calculateStatistics() {
        var totalQuestions = 0;
        var correctQuestions = 0;
        var wrongQuestions = 0;
        var currentScore = 0;

        $('.mk-q-item').each(function() {
            totalQuestions++;
            
            // 获取得分和满分
            var scoreText = $(this).find('.mk-q-header div:last').text();
            var scoreMatch = scoreText.match(/得分：(\d+)\s*\/\s*(\d+)/);
            
            if (scoreMatch) {
                var score = parseInt(scoreMatch[1]);
                var maxScore = parseInt(scoreMatch[2]);
                currentScore += score;
                
                // 判断是否正确（得满分为正确）
                if (score === maxScore && maxScore > 0) {
                    correctQuestions++;
                } else if (score === 0) {
                    wrongQuestions++;
                }
            }
        });

        // 更新统计显示
        $('#statTotalQuestions').text(totalQuestions);
        $('#statCorrectQuestions').text(correctQuestions);
        $('#statWrongQuestions').text(wrongQuestions);
        $('#statCurrentScore').text(currentScore);
        
        // 显示/隐藏统计板块：只有在有题目时才显示
        if (totalQuestions > 0) {
            $('#mkStatsGrid').show();
        } else {
            $('#mkStatsGrid').hide();
        }
    }

    // 为题目添加分类样式
    function classifyQuestions() {
        $('.mk-q-item').each(function() {
            var scoreText = $(this).find('.mk-q-header div:last').text();
            var scoreMatch = scoreText.match(/得分：(\d+)\s*\/\s*(\d+)/);
            
            if (scoreMatch) {
                var score = parseInt(scoreMatch[1]);
                var maxScore = parseInt(scoreMatch[2]);
                
                // 移除所有状态类
                $(this).removeClass('mk-q-correct mk-q-wrong mk-q-partial');
                
                // 根据得分添加状态类
                if (score === maxScore && maxScore > 0) {
                    // 满分 - 正确
                    $(this).addClass('mk-q-correct');
                } else if (score === 0) {
                    // 零分 - 错误
                    $(this).addClass('mk-q-wrong');
                } else if (score > 0 && score < maxScore) {
                    // 部分得分 - 部分正确
                    $(this).addClass('mk-q-partial');
                }
            }
        });
    }

    // 当评分改变时重新计算统计并验证满分
    $(document).on('input', 'input[id*="TxtItemScore"]', function() {
        var input = $(this);
        var val = parseInt(input.val());
        
        // 获取满分
        var maxScoreText = input.closest('.mk-q-grade-row').find('span').text();
        var maxScore = parseInt(maxScoreText.match(/\d+/));
        
        // 验证分数不超过满分
        if (!isNaN(val) && !isNaN(maxScore) && val > maxScore) {
            input.css('border-color', '#ef4444');
            input.css('background-color', '#fef2f2');
            // 显示提示
            var existingTip = input.next('.mk-score-tip');
            if (existingTip.length === 0) {
                input.after('<span class="mk-score-tip" style="color:#ef4444;font-size:12px;margin-left:8px;">不能超过' + maxScore + '分</span>');
            }
        } else {
            input.css('border-color', '');
            input.css('background-color', '');
            input.next('.mk-score-tip').remove();
        }
        
        // 延迟计算，等待输入完成
        clearTimeout(window.statsUpdateTimer);
        window.statsUpdateTimer = setTimeout(function() {
            calculateStatistics();
            classifyQuestions();
        }, 500);
    });
</script>
</asp:Content>
