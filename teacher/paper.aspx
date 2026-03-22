<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";
    protected int editPaperId = 0;
    protected int editQuestionCount = 0;
    protected int editScoreSum = 0;
    protected int editTotalScore = 100;

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
            string mode = Request.QueryString["mode"];
            string pidStr = Request.QueryString["pid"];
            if (mode == "edit" && !string.IsNullOrEmpty(pidStr))
            {
                int.TryParse(pidStr, out editPaperId);
                PanelList.Visible = false;
                PanelEdit.Visible = true;
                LoadPaperForEdit(editPaperId);
                BindQuestions(editPaperId);
            }
            else
            {
                PanelList.Visible = true;
                PanelEdit.Visible = false;
                BindPapers();
            }
        }
        else
        {
            if (HiddenPaperId.Value != "")
                int.TryParse(HiddenPaperId.Value, out editPaperId);
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
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='Paper' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[Paper](
                            [Pid] [int] IDENTITY(1,1) NOT NULL,
                            [Ptitle] [nvarchar](200) NULL,
                            [Pdesc] [nvarchar](500) NULL,
                            [Phid] [int] NULL,
                            [Ptime] [int] NULL DEFAULT(60),
                            [Pscore] [int] NULL DEFAULT(100),
                            [Pcount] [int] NULL DEFAULT(0),
                            [Pstatus] [int] NULL DEFAULT(0),
                            [Pdate] [datetime] NULL,
                            [Psort] [int] NULL DEFAULT(0),
                            PRIMARY KEY CLUSTERED ([Pid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='PaperQuestion' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[PaperQuestion](
                            [Qid] [int] IDENTITY(1,1) NOT NULL,
                            [Qpid] [int] NULL,
                            [Qtype] [nvarchar](20) NULL,
                            [Qcontent] [nvarchar](2000) NULL,
                            [Qoption_a] [nvarchar](500) NULL,
                            [Qoption_b] [nvarchar](500) NULL,
                            [Qoption_c] [nvarchar](500) NULL,
                            [Qoption_d] [nvarchar](500) NULL,
                            [Qanswer] [nvarchar](500) NULL,
                            [Qscore] [int] NULL DEFAULT(5),
                            [Qsort] [int] NULL DEFAULT(0),
                            [Qdate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([Qid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
            }
        }
        catch { }
    }

    // ========== 试卷列表 ==========
    private void BindPapers()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Pid,Ptitle,Pdesc,Ptime,Pscore,Pcount,Pstatus,Pdate FROM Paper WHERE Phid=@hid ORDER BY Pdate DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@hid", myHid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptPapers.DataSource = dt;
                RptPapers.DataBind();
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; pageMsgType = "error"; }
    }

    // ========== 创建试卷 ==========
    protected void BtnCreatePaper_Click(object sender, EventArgs e)
    {
        string title = TxtNewTitle.Text.Trim();
        if (string.IsNullOrEmpty(title)) { pageMsg = "请输入试卷标题"; pageMsgType = "error"; BindPapers(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            int newPid = 0;
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int timeLimit = 60; int.TryParse(TxtNewTime.Text.Trim(), out timeLimit);
                if (timeLimit <= 0) timeLimit = 60;
                int totalScore = 100; int.TryParse(TxtNewScore.Text.Trim(), out totalScore);
                if (totalScore <= 0) totalScore = 100;
                string sql = "INSERT INTO Paper(Ptitle,Pdesc,Phid,Ptime,Pscore,Pcount,Pstatus,Pdate,Psort) VALUES(@title,@desc,@hid,@time,@score,0,0,GETDATE(),0);SELECT SCOPE_IDENTITY()";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", TxtNewDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.Parameters.AddWithValue("@time", timeLimit);
                    cmd.Parameters.AddWithValue("@score", totalScore);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out newPid);
                }
            }
            if (newPid > 0)
                Response.Redirect("paper.aspx?mode=edit&pid=" + newPid);
            else
            {
                pageMsg = "创建成功"; pageMsgType = "success";
                TxtNewTitle.Text = ""; TxtNewDesc.Text = ""; TxtNewTime.Text = "60"; TxtNewScore.Text = "100";
                BindPapers();
            }
        }
        catch (Exception ex) { pageMsg = "创建失败: " + ex.Message; pageMsgType = "error"; BindPapers(); }
    }

    // ========== 试卷操作 ==========
    protected void RptPapers_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "DelPaper")
        {
            int pid = 0; int.TryParse(e.CommandArgument.ToString(), out pid);
            if (pid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM PaperQuestion WHERE Qpid=@pid", conn))
                    { cmd.Parameters.AddWithValue("@pid", pid); cmd.ExecuteNonQuery(); }
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    { cmd.Parameters.AddWithValue("@pid", pid); cmd.Parameters.AddWithValue("@hid", myHid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "试卷已删除"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; pageMsgType = "error"; }
            BindPapers();
        }
        else if (e.CommandName == "ToggleStatus")
        {
            int pid = 0; int.TryParse(e.CommandArgument.ToString(), out pid);
            if (pid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // 发布前检查分值是否匹配
                    int curStatus = 0;
                    using (SqlCommand chkS = new SqlCommand("SELECT ISNULL(Pstatus,0) FROM Paper WHERE Pid=@pid AND Phid=@hid", conn))
                    {
                        chkS.Parameters.AddWithValue("@pid", pid); chkS.Parameters.AddWithValue("@hid", myHid);
                        object sv = chkS.ExecuteScalar();
                        if (sv != null && sv != DBNull.Value) curStatus = Convert.ToInt32(sv);
                    }
                    if (curStatus == 0)
                    {
                        // 将要发布，需要验证分值
                        int pScore = 100;
                        using (SqlCommand chkPs = new SqlCommand("SELECT ISNULL(Pscore,100) FROM Paper WHERE Pid=@pid", conn))
                        { chkPs.Parameters.AddWithValue("@pid", pid); object pv = chkPs.ExecuteScalar(); if (pv != null && pv != DBNull.Value) pScore = Convert.ToInt32(pv); }
                        int qScoreSum = 0;
                        int qCnt = 0;
                        using (SqlCommand chkQs = new SqlCommand("SELECT COUNT(*) AS cnt, ISNULL(SUM(Qscore),0) AS total FROM PaperQuestion WHERE Qpid=@pid", conn))
                        {
                            chkQs.Parameters.AddWithValue("@pid", pid);
                            using (SqlDataReader dr = chkQs.ExecuteReader())
                            {
                                if (dr.Read()) { qCnt = Convert.ToInt32(dr["cnt"]); qScoreSum = Convert.ToInt32(dr["total"]); }
                            }
                        }
                        if (qCnt == 0)
                        {
                            pageMsg = "发布失败：试卷没有试题，请先添加题目"; pageMsgType = "error";
                            BindPapers(); return;
                        }
                        if (qScoreSum != pScore)
                        {
                            pageMsg = "发布失败：各题分值合计(" + qScoreSum + "分) ≠ 试卷总分值(" + pScore + "分)，请调整后再发布"; pageMsgType = "error";
                            BindPapers(); return;
                        }
                    }
                    using (SqlCommand cmd = new SqlCommand("UPDATE Paper SET Pstatus=CASE WHEN ISNULL(Pstatus,0)=0 THEN 1 ELSE 0 END WHERE Pid=@pid AND Phid=@hid", conn))
                    { cmd.Parameters.AddWithValue("@pid", pid); cmd.Parameters.AddWithValue("@hid", myHid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "状态已更新"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "操作失败: " + ex.Message; pageMsgType = "error"; }
            BindPapers();
        }
        else if (e.CommandName == "CopyPaper")
        {
            int pid = 0; int.TryParse(e.CommandArgument.ToString(), out pid);
            if (pid <= 0) return;
            CopyPaper(pid);
            BindPapers();
        }
    }

    private void CopyPaper(int pid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                DataTable dtPaper = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Paper WHERE Pid=@pid", conn))
                { da.SelectCommand.Parameters.AddWithValue("@pid", pid); da.Fill(dtPaper); }
                if (dtPaper.Rows.Count == 0) return;
                DataRow r = dtPaper.Rows[0];
                int newPid = 0;
                using (SqlCommand cmd = new SqlCommand("INSERT INTO Paper(Ptitle,Pdesc,Phid,Ptime,Pscore,Pcount,Pstatus,Pdate,Psort) VALUES(@t,@d,@h,@tm,@s,@c,0,GETDATE(),0);SELECT SCOPE_IDENTITY()", conn))
                {
                    cmd.Parameters.AddWithValue("@t", r["Ptitle"].ToString() + "(副本)");
                    cmd.Parameters.AddWithValue("@d", r["Pdesc"]);
                    cmd.Parameters.AddWithValue("@h", myHid);
                    cmd.Parameters.AddWithValue("@tm", r["Ptime"]);
                    cmd.Parameters.AddWithValue("@s", r["Pscore"]);
                    cmd.Parameters.AddWithValue("@c", r["Pcount"]);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out newPid);
                }
                if (newPid > 0)
                {
                    DataTable dtQ = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM PaperQuestion WHERE Qpid=@pid ORDER BY Qsort,Qid", conn))
                    { da.SelectCommand.Parameters.AddWithValue("@pid", pid); da.Fill(dtQ); }
                    foreach (DataRow qr in dtQ.Rows)
                    {
                        using (SqlCommand cmd = new SqlCommand("INSERT INTO PaperQuestion(Qpid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@pid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                        {
                            cmd.Parameters.AddWithValue("@pid", newPid);
                            cmd.Parameters.AddWithValue("@type", qr["Qtype"]);
                            cmd.Parameters.AddWithValue("@content", qr["Qcontent"]);
                            cmd.Parameters.AddWithValue("@a", qr["Qoption_a"] ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@b", qr["Qoption_b"] ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@c", qr["Qoption_c"] ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@d", qr["Qoption_d"] ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@ans", qr["Qanswer"]);
                            cmd.Parameters.AddWithValue("@score", qr["Qscore"]);
                            cmd.Parameters.AddWithValue("@sort", qr["Qsort"]);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                pageMsg = "试卷复制成功"; pageMsgType = "success";
            }
        }
        catch (Exception ex) { pageMsg = "复制失败: " + ex.Message; pageMsgType = "error"; }
    }

    // ========== 编辑试卷 ==========
    private void LoadPaperForEdit(int pid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM Paper WHERE Pid=@pid", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", pid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            TxtEditTitle.Text = reader["Ptitle"] != DBNull.Value ? reader["Ptitle"].ToString() : "";
                            TxtEditDesc.Text = reader["Pdesc"] != DBNull.Value ? reader["Pdesc"].ToString() : "";
                            TxtEditTime.Text = reader["Ptime"] != DBNull.Value ? reader["Ptime"].ToString() : "60";
                            TxtEditScore.Text = reader["Pscore"] != DBNull.Value ? reader["Pscore"].ToString() : "100";
                            HiddenPaperId.Value = pid.ToString();
                            editPaperId = pid;
                            if (reader["Pscore"] != DBNull.Value) int.TryParse(reader["Pscore"].ToString(), out editTotalScore);
                        }
                    }
                }
            }
        }
        catch { }
    }

    protected void BtnSavePaper_Click(object sender, EventArgs e)
    {
        int pid = 0; int.TryParse(HiddenPaperId.Value, out pid);
        if (pid <= 0) return;
        string title = TxtEditTitle.Text.Trim();
        if (string.IsNullOrEmpty(title)) { pageMsg = "请输入试卷标题"; pageMsgType = "error"; editPaperId = pid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(pid); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            int timeLimit = 60; int.TryParse(TxtEditTime.Text.Trim(), out timeLimit);
            int totalScore = 100; int.TryParse(TxtEditScore.Text.Trim(), out totalScore);
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("UPDATE Paper SET Ptitle=@t,Pdesc=@d,Ptime=@tm,Pscore=@s WHERE Pid=@pid AND Phid=@hid", conn))
                {
                    cmd.Parameters.AddWithValue("@t", title);
                    cmd.Parameters.AddWithValue("@d", TxtEditDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@tm", timeLimit);
                    cmd.Parameters.AddWithValue("@s", totalScore);
                    cmd.Parameters.AddWithValue("@pid", pid);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "试卷信息已保存"; pageMsgType = "success";
            editTotalScore = totalScore;
        }
        catch (Exception ex) { pageMsg = "保存失败: " + ex.Message; pageMsgType = "error"; }
        editPaperId = pid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(pid);
        // 保存后检查分值是否匹配
        if (pageMsgType == "success" && editQuestionCount > 0 && editScoreSum != editTotalScore)
        {
            pageMsg = "试卷信息已保存，但分值不匹配：各题分值合计(" + editScoreSum + "分) ≠ 总分值(" + editTotalScore + "分)，请调整";
            pageMsgType = "error";
        }
    }

    protected void BtnBackToList_Click(object sender, EventArgs e)
    {
        Response.Redirect("paper.aspx");
    }

    // ========== 试题管理 ==========
    private void BindQuestions(int pid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter("SELECT Qid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort FROM PaperQuestion WHERE Qpid=@pid ORDER BY Qsort,Qid", conn);
                da.SelectCommand.Parameters.AddWithValue("@pid", pid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptQuestions.DataSource = dt;
                RptQuestions.DataBind();
                editQuestionCount = dt.Rows.Count;
                editScoreSum = 0;
                foreach (DataRow row in dt.Rows)
                {
                    if (row["Qscore"] != DBNull.Value) editScoreSum += Convert.ToInt32(row["Qscore"]);
                }
                using (SqlCommand cmd = new SqlCommand("UPDATE Paper SET Pcount=@c WHERE Pid=@pid", conn))
                {
                    cmd.Parameters.AddWithValue("@c", dt.Rows.Count);
                    cmd.Parameters.AddWithValue("@pid", pid);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    protected void BtnAddQuestion_Click(object sender, EventArgs e)
    {
        int pid = 0; int.TryParse(HiddenPaperId.Value, out pid);
        if (pid <= 0) return;
        string content = TxtQContent.Text.Trim();
        if (string.IsNullOrEmpty(content)) { pageMsg = "请输入题目内容"; pageMsgType = "error"; editPaperId = pid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(pid); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int maxSort = 0;
                using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM PaperQuestion WHERE Qpid=@pid", conn))
                { cmdMax.Parameters.AddWithValue("@pid", pid); object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }
                int qScore = 5; int.TryParse(TxtQScore.Text.Trim(), out qScore);
                if (qScore <= 0) qScore = 5;
                using (SqlCommand cmd = new SqlCommand("INSERT INTO PaperQuestion(Qpid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@pid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", pid);
                    cmd.Parameters.AddWithValue("@type", DDLQType.SelectedValue);
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@a", TxtOptA.Text.Trim());
                    cmd.Parameters.AddWithValue("@b", TxtOptB.Text.Trim());
                    cmd.Parameters.AddWithValue("@c", TxtOptC.Text.Trim());
                    cmd.Parameters.AddWithValue("@d", TxtOptD.Text.Trim());
                    cmd.Parameters.AddWithValue("@ans", TxtQAnswer.Text.Trim());
                    cmd.Parameters.AddWithValue("@score", qScore);
                    cmd.Parameters.AddWithValue("@sort", maxSort + 1);
                    cmd.ExecuteNonQuery();
                }
            }
            TxtQContent.Text = ""; TxtOptA.Text = ""; TxtOptB.Text = ""; TxtOptC.Text = ""; TxtOptD.Text = "";
            TxtQAnswer.Text = ""; TxtQScore.Text = "5";
            pageMsg = "试题添加成功"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "添加失败: " + ex.Message; pageMsgType = "error"; }
        editPaperId = pid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(pid);
    }

    protected void RptQuestions_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int pid = 0; int.TryParse(HiddenPaperId.Value, out pid);
        if (pid <= 0) return;
        if (e.CommandName == "DelQuestion")
        {
            int qid = 0; int.TryParse(e.CommandArgument.ToString(), out qid);
            if (qid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM PaperQuestion WHERE Qid=@qid AND Qpid=@pid", conn))
                    { cmd.Parameters.AddWithValue("@qid", qid); cmd.Parameters.AddWithValue("@pid", pid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "试题已删除"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; pageMsgType = "error"; }
        }
        else if (e.CommandName == "MoveUp" || e.CommandName == "MoveDown")
        {
            int qid = 0; int.TryParse(e.CommandArgument.ToString(), out qid);
            if (qid <= 0) return;
            MoveQuestion(pid, qid, e.CommandName == "MoveUp" ? -1 : 1);
        }
        editPaperId = pid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(pid);
    }

    private void MoveQuestion(int pid, int qid, int direction)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT Qid,Qsort FROM PaperQuestion WHERE Qpid=@pid ORDER BY Qsort,Qid", conn))
                { da.SelectCommand.Parameters.AddWithValue("@pid", pid); da.Fill(dt); }
                int idx = -1;
                for (int i = 0; i < dt.Rows.Count; i++)
                { if (Convert.ToInt32(dt.Rows[i]["Qid"]) == qid) { idx = i; break; } }
                int target = idx + direction;
                if (idx < 0 || target < 0 || target >= dt.Rows.Count) return;
                int qid1 = Convert.ToInt32(dt.Rows[idx]["Qid"]);
                int sort1 = Convert.ToInt32(dt.Rows[idx]["Qsort"]);
                int qid2 = Convert.ToInt32(dt.Rows[target]["Qid"]);
                int sort2 = Convert.ToInt32(dt.Rows[target]["Qsort"]);
                if (sort1 == sort2) sort2 = sort1 + direction;
                using (SqlCommand cmd = new SqlCommand("UPDATE PaperQuestion SET Qsort=@s WHERE Qid=@qid", conn))
                { cmd.Parameters.AddWithValue("@s", sort2); cmd.Parameters.AddWithValue("@qid", qid1); cmd.ExecuteNonQuery(); }
                using (SqlCommand cmd = new SqlCommand("UPDATE PaperQuestion SET Qsort=@s WHERE Qid=@qid", conn))
                { cmd.Parameters.AddWithValue("@s", sort1); cmd.Parameters.AddWithValue("@qid", qid2); cmd.ExecuteNonQuery(); }
            }
        }
        catch { }
    }

    // ========== 导入试题 ==========
    protected void BtnImportQuestions_Click(object sender, EventArgs e)
    {
        int pid = 0; int.TryParse(HiddenPaperId.Value, out pid);
        if (pid <= 0) return;
        if (!FileUploadImport.HasFile) { pageMsg = "请选择要导入的文本文件"; pageMsgType = "error"; editPaperId = pid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(pid); return; }
        string ext = System.IO.Path.GetExtension(FileUploadImport.FileName).ToLower();
        if (ext != ".txt" && ext != ".csv") { pageMsg = "仅支持 .txt 或 .csv 文件"; pageMsgType = "error"; editPaperId = pid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(pid); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            string content = System.Text.Encoding.UTF8.GetString(FileUploadImport.FileBytes);
            // 去除 BOM
            if (content.Length > 0 && content[0] == '\uFEFF') content = content.Substring(1);
            string[] lines = content.Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
            int added = 0;
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int maxSort = 0;
                using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM PaperQuestion WHERE Qpid=@pid", conn))
                { cmdMax.Parameters.AddWithValue("@pid", pid); object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }

                string curType = "single", curContent = "", curA = "", curB = "", curC = "", curD = "", curAnswer = "";
                int curScore = 5;
                bool inBlock = false;

                for (int i = 0; i <= lines.Length; i++)
                {
                    string line = (i < lines.Length) ? lines[i].Trim() : "";
                    // 空行或文件结尾 => 保存当前块
                    if (string.IsNullOrEmpty(line) || i == lines.Length)
                    {
                        if (inBlock && !string.IsNullOrEmpty(curContent))
                        {
                            maxSort++;
                            using (SqlCommand cmd = new SqlCommand("INSERT INTO PaperQuestion(Qpid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@pid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                            {
                                cmd.Parameters.AddWithValue("@pid", pid);
                                cmd.Parameters.AddWithValue("@type", curType);
                                cmd.Parameters.AddWithValue("@content", curContent);
                                cmd.Parameters.AddWithValue("@a", curA);
                                cmd.Parameters.AddWithValue("@b", curB);
                                cmd.Parameters.AddWithValue("@c", curC);
                                cmd.Parameters.AddWithValue("@d", curD);
                                cmd.Parameters.AddWithValue("@ans", curAnswer);
                                cmd.Parameters.AddWithValue("@score", curScore);
                                cmd.Parameters.AddWithValue("@sort", maxSort);
                                cmd.ExecuteNonQuery();
                                added++;
                            }
                        }
                        curType = "single"; curContent = ""; curA = ""; curB = ""; curC = ""; curD = ""; curAnswer = ""; curScore = 5;
                        inBlock = false;
                        continue;
                    }
                    inBlock = true;
                    if (line.StartsWith("题型:") || line.StartsWith("题型：")) { curType = line.Substring(3).Trim(); }
                    else if (line.StartsWith("题目:") || line.StartsWith("题目：")) { curContent = line.Substring(3).Trim(); }
                    else if (line.StartsWith("A:") || line.StartsWith("A：")) { curA = line.Substring(2).Trim(); }
                    else if (line.StartsWith("B:") || line.StartsWith("B：")) { curB = line.Substring(2).Trim(); }
                    else if (line.StartsWith("C:") || line.StartsWith("C：")) { curC = line.Substring(2).Trim(); }
                    else if (line.StartsWith("D:") || line.StartsWith("D：")) { curD = line.Substring(2).Trim(); }
                    else if (line.StartsWith("答案:") || line.StartsWith("答案：")) { curAnswer = line.Substring(3).Trim(); }
                    else if (line.StartsWith("分值:") || line.StartsWith("分值：")) { int.TryParse(line.Substring(3).Trim(), out curScore); if (curScore <= 0) curScore = 5; }
                }
                // 更新题目数量
                using (SqlCommand cmdCnt = new SqlCommand("UPDATE Paper SET Pcount=(SELECT COUNT(*) FROM PaperQuestion WHERE Qpid=@pid) WHERE Pid=@pid", conn))
                { cmdCnt.Parameters.AddWithValue("@pid", pid); cmdCnt.ExecuteNonQuery(); }
            }
            pageMsg = "成功导入 " + added + " 道试题"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "导入失败: " + ex.Message; pageMsgType = "error"; }
        editPaperId = pid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(pid);
    }

    // ========== 辅助方法 ==========
    protected string GetTypeName(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "未知";
        switch (typeVal.ToString())
        {
            case "single": return "单选题";
            case "multiple": return "多选题";
            case "truefalse": return "判断题";
            case "fill": return "填空题";
            case "essay": return "简答题";
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
            case "single": return "#6366f1";
            case "multiple": return "#8b5cf6";
            case "truefalse": return "#0891b2";
            case "fill": return "#059669";
            case "essay": return "#d97706";
            case "scratch": return "#f97316";
            case "python": return "#4338ca";
            case "pythonblock": return "#047857";
            default: return "#94a3b8";
        }
    }
    protected string GetTypeBgColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "#f1f5f9";
        switch (typeVal.ToString())
        {
            case "single": return "#eef2ff";
            case "multiple": return "#f5f3ff";
            case "truefalse": return "#ecfeff";
            case "fill": return "#ecfdf5";
            case "essay": return "#fffbeb";
            case "scratch": return "#fff7ed";
            case "python": return "#eef2ff";
            case "pythonblock": return "#ecfdf5";
            default: return "#f1f5f9";
        }
    }
    protected string GetStatusText(object status)
    {
        if (status == null || status == DBNull.Value) return "草稿";
        return Convert.ToInt32(status) == 1 ? "已发布" : "草稿";
    }
    protected string GetStatusClass(object status)
    {
        if (status == null || status == DBNull.Value) return "pp-status-draft";
        return Convert.ToInt32(status) == 1 ? "pp-status-pub" : "pp-status-draft";
    }
    protected string FormatDate(object dateVal)
    {
        if (dateVal == null || dateVal == DBNull.Value) return "";
        try { return Convert.ToDateTime(dateVal).ToString("yyyy-MM-dd HH:mm"); } catch { return ""; }
    }
    protected string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
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
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .pp-page { max-width: 1400px; width: 100%; margin: 0 auto; }
    .pp-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; }
    .pp-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .pp-title-icon { width: 42px; height: 42px; background: linear-gradient(135deg, #6366f1, #818cf8); border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(99,102,241,0.25); }
    .pp-title-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 54px; }
    .pp-msg { padding: 12px 18px; border-radius: 10px; font-size: 13px; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .pp-msg svg { width: 18px; height: 18px; flex-shrink: 0; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-msg-info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
    .pp-msg-info svg { stroke: #3b82f6; fill: none; }
    .pp-msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .pp-msg-success svg { stroke: #22c55e; fill: none; }
    .pp-msg-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .pp-msg-error svg { stroke: #ef4444; fill: none; }
    .pp-card { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.02); margin-bottom: 20px; overflow: visible !important; height: auto !important; max-height: none !important; position: relative; }
    .pp-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; background: linear-gradient(180deg, #fafbfc, #f8f9fb); font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 10px; border-radius: 14px 14px 0 0; }
    .pp-card-head svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-card-body { padding: 24px; overflow: visible !important; height: auto !important; max-height: none !important; clear: both; }
    .pp-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 20px; }
    .pp-form-full { grid-column: 1 / -1; }
    .pp-form-group { display: flex; flex-direction: column; gap: 6px; }
    .pp-form-group label { font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.3px; }
    .pp-form-group input[type="text"], .pp-form-group textarea, .pp-form-group select {
        padding: 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0; font-size: 13.5px; color: #334155;
        background: #f8fafc; outline: none; transition: all 0.2s; font-family: inherit; resize: vertical;
    }
    .pp-form-group input[type="text"]:focus, .pp-form-group textarea:focus, .pp-form-group select:focus {
        border-color: #818cf8; background: #fff; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .pp-form-group textarea { min-height: 70px; }
    .pp-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 22px; border-radius: 10px; font-size: 13.5px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; font-family: inherit; text-decoration: none; }
    .pp-btn:hover { transform: translateY(-1px); }
    .pp-btn-primary { background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff; box-shadow: 0 4px 14px rgba(99,102,241,0.3); }
    .pp-btn-primary:hover { box-shadow: 0 6px 20px rgba(99,102,241,0.4); }
    .pp-btn-success { background: linear-gradient(135deg, #059669, #10b981); color: #fff; box-shadow: 0 4px 14px rgba(5,150,105,0.3); }
    .pp-list { display: flex; flex-direction: column; gap: 12px; }
    .pp-item { display: flex; align-items: center; padding: 18px 22px; border-radius: 12px; border: 1px solid #f1f5f9; background: #fff; transition: all 0.2s; gap: 20px; }
    .pp-item:hover { border-color: #c7d2fe; box-shadow: 0 4px 16px rgba(99,102,241,0.08); transform: translateY(-1px); }
    .pp-item-icon { width: 48px; height: 48px; background: linear-gradient(135deg, #eef2ff, #e0e7ff); border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .pp-item-icon svg { width: 24px; height: 24px; stroke: #6366f1; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .pp-item-info { flex: 1; min-width: 0; }
    .pp-item-title { font-size: 15px; font-weight: 600; color: #1e293b; margin-bottom: 6px; display: flex; align-items: center; gap: 10px; }
    .pp-item-meta { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .pp-item-meta-tag { font-size: 12px; color: #64748b; display: flex; align-items: center; gap: 4px; }
    .pp-item-meta-tag svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-item-actions { display: flex; gap: 6px; flex-shrink: 0; align-items: center; }
    .pp-status { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
    .pp-status-draft { background: #fef3c7; color: #92400e; }
    .pp-status-pub { background: #dcfce7; color: #166534; }
    .pp-act-btn { display: inline-flex; align-items: center; justify-content: center; gap: 4px; padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.15s; text-decoration: none; font-family: inherit; }
    .pp-act-btn:hover { background: #f1f5f9; border-color: #cbd5e1; }
    .pp-act-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-act-btn-edit { color: #6366f1; border-color: #c7d2fe; }
    .pp-act-btn-edit:hover { background: #eef2ff; }
    .pp-act-btn-copy { color: #0891b2; border-color: #a5f3fc; }
    .pp-act-btn-copy:hover { background: #ecfeff; }
    .pp-act-btn-toggle { color: #d97706; border-color: #fde68a; }
    .pp-act-btn-toggle:hover { background: #fffbeb; }
    .pp-act-btn-del { color: #ef4444; border-color: #fecaca; }
    .pp-act-btn-del:hover { background: #fef2f2; }
    .pp-empty { text-align: center; padding: 60px 20px; }
    .pp-empty-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #f1f5f9, #e2e8f0); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
    .pp-empty-icon svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .pp-empty-text { font-size: 15px; color: #64748b; font-weight: 500; }
    .pp-empty-hint { font-size: 13px; color: #94a3b8; margin-top: 6px; }
    .pp-back-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 500; color: #64748b; background: #f1f5f9; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.15s; margin-bottom: 16px; text-decoration: none; font-family: inherit; }
    .pp-back-btn:hover { background: #e2e8f0; color: #334155; }
    .pp-back-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-list { display: flex; flex-direction: column; gap: 14px; }
    .pp-q-item { padding: 18px 22px; border-radius: 12px; border: 1px solid #f1f5f9; background: #fafbfc; transition: all 0.2s; }
    .pp-q-item:hover { border-color: #e0e7ff; background: #fff; }
    .pp-q-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; }
    .pp-q-num { display: inline-flex; align-items: center; gap: 8px; }
    .pp-q-badge { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
    .pp-q-score-tag { font-size: 12px; font-weight: 700; color: #f59e0b; background: #fffbeb; padding: 2px 10px; border-radius: 6px; }
    .pp-q-score-edit { display: inline-flex; align-items: center; gap: 2px; background: #fffbeb; border: 1.5px solid #fde68a; border-radius: 6px; padding: 1px 6px; transition: all 0.2s; }
    .pp-q-score-edit:focus-within { border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,0.15); background: #fff; }
    .pp-q-score-edit input { width: 36px; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #f59e0b; text-align: center; outline: none; padding: 2px 0; font-family: inherit; }
    .pp-q-score-edit .pp-q-score-unit { font-size: 11px; color: #d97706; font-weight: 500; }
    .pp-q-score-edit.saving { opacity: 0.6; pointer-events: none; }
    .pp-q-score-edit.saved { border-color: #22c55e; background: #f0fdf4; }
    .pp-q-score-edit.saved input { color: #16a34a; }
    .pp-batch-score-bar { display: flex; align-items: center; gap: 10px; padding: 10px 14px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; margin-bottom: 16px; flex-wrap: wrap; }
    .pp-batch-score-bar label { font-size: 12px; font-weight: 600; color: #92400e; white-space: nowrap; }
    .pp-batch-score-bar select, .pp-batch-score-bar input[type="number"] { padding: 5px 10px; border-radius: 6px; border: 1px solid #fde68a; font-size: 12px; color: #334155; background: #fff; outline: none; font-family: inherit; }
    .pp-batch-score-bar select:focus, .pp-batch-score-bar input[type="number"]:focus { border-color: #f59e0b; box-shadow: 0 0 0 2px rgba(245,158,11,0.15); }
    .pp-batch-score-bar input[type="number"] { width: 60px; text-align: center; }
    .pp-batch-score-btn { display: inline-flex; align-items: center; gap: 4px; padding: 5px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; border: 1px solid #f59e0b; background: linear-gradient(135deg, #fbbf24, #f59e0b); color: #fff; cursor: pointer; transition: all 0.15s; font-family: inherit; }
    .pp-batch-score-btn:hover { box-shadow: 0 2px 8px rgba(245,158,11,0.3); transform: translateY(-1px); }
    .pp-batch-score-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; box-shadow: none; }
    .pp-batch-score-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-content { font-size: 14px; color: #1e293b; line-height: 1.7; margin-bottom: 8px; word-break: break-word; }
    .pp-q-options { font-size: 13px; color: #475569; line-height: 1.8; padding: 8px 14px; background: #f8fafc; border-radius: 8px; margin-bottom: 8px; }
    .pp-q-answer { font-size: 12px; color: #059669; background: #ecfdf5; padding: 6px 12px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px; }
    .pp-q-answer svg { width: 14px; height: 14px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-actions { display: flex; gap: 4px; }
    .pp-q-act { display: inline-flex; align-items: center; justify-content: center; width: 30px; height: 30px; border-radius: 6px; border: 1px solid #e2e8f0; background: #fff; color: #64748b; cursor: pointer; transition: all 0.15s; text-decoration: none; font-size: 12px; }
    .pp-q-act:hover { background: #f1f5f9; border-color: #cbd5e1; color: #334155; }
    .pp-q-act-del { color: #ef4444; }
    .pp-q-act-del:hover { background: #fef2f2; border-color: #fecaca; }
    .pp-add-q-area { padding: 24px; background: linear-gradient(180deg, #f8f9fb, #f1f5f9); border-top: 1px solid #e8ecf1; }
    .pp-add-q-title { font-size: 15px; font-weight: 600; color: #334155; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .pp-add-q-title svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-opt-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    /* 导入和AI出题 */
    .pp-tool-row { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
    .pp-tool-btn { display: inline-flex; align-items: center; gap: 6px; padding: 10px 20px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1.5px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.2s; font-family: inherit; }
    .pp-tool-btn:hover { border-color: #818cf8; color: #6366f1; background: #f5f3ff; transform: translateY(-1px); }
    .pp-tool-btn svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-tool-btn-ai { border-color: #c084fc; color: #7c3aed; }
    .pp-tool-btn-ai:hover { border-color: #a855f7; background: #faf5ff; color: #6d28d9; }
    .pp-panel { padding: 20px; border-radius: 12px; border: 1.5px solid #e2e8f0; margin-bottom: 18px; width: 100%; box-sizing: border-box; }
    .pp-panel-import { background: linear-gradient(135deg, #f0fdf4, #ecfdf5); border-color: #86efac; }
    .pp-panel-ai { background: linear-gradient(135deg, #faf5ff, #f5f3ff); border-color: #c4b5fd; }
    .pp-panel-title { font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 14px; display: flex; align-items: center; gap: 8px; white-space: nowrap; overflow: visible !important; }
    .pp-panel-title svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    .pp-import-hint { font-size: 12px; color: #64748b; line-height: 1.8; background: #fff; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 14px; overflow: visible !important; white-space: normal !important; word-break: break-word; height: auto !important; max-height: none !important; position: relative !important; float: none !important; }
    .pp-import-hint code { background: #f1f5f9; padding: 1px 6px; border-radius: 4px; font-size: 11px; color: #334155; white-space: nowrap; }
    .pp-ai-result { margin-top: 14px; padding: 14px; background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; max-height: 300px; overflow-y: auto; display: none; }
    .pp-ai-result-item { padding: 8px 12px; border-radius: 8px; background: #f8fafc; margin-bottom: 6px; font-size: 13px; color: #334155; border: 1px solid #f1f5f9; }
    .pp-ai-loading { display: none; align-items: center; gap: 6px; padding: 0; margin: 0; font-size: 13px; color: #7c3aed; white-space: nowrap; background: none !important; border: none !important; box-shadow: none !important; }
    .pp-ai-loading.show { display: inline-flex; }
    .pp-ai-spinner { width: 16px; height: 16px; min-width: 16px; flex-shrink: 0; border: 2px solid #e9d5ff; border-top-color: #7c3aed; border-radius: 50%; animation: pp-spin 0.8s linear infinite; background: transparent !important; box-shadow: none !important; box-sizing: border-box; }
    @keyframes pp-spin { to { transform: rotate(360deg); } }
    .pp-kw-list { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 12px; }
    .pp-kw-tag { display: inline-flex; align-items: center; padding: 5px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; background: #f5f3ff; border: 1px solid #ddd6fe; color: #7c3aed; cursor: pointer; transition: all 0.15s; }
    .pp-kw-tag:hover { background: #ede9fe; border-color: #c4b5fd; }
    .pp-kw-tag.active { background: #7c3aed; color: #fff; border-color: #7c3aed; }
    /* 知识库选择 */
    .pp-kb-area { margin-bottom: 16px; }
    .pp-kb-label { font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.3px; margin-bottom: 8px; display: flex; align-items: center; gap: 6px; }
    .pp-kb-label svg { width: 15px; height: 15px; stroke: #7c3aed; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-kb-tags { display: flex; flex-wrap: wrap; gap: 6px; }
    .pp-kb-tag { display: inline-flex; align-items: center; gap: 5px; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; background: #fff; border: 1.5px solid #e2e8f0; color: #475569; cursor: pointer; transition: all 0.18s; user-select: none; }
    .pp-kb-tag:hover { border-color: #c4b5fd; background: #faf5ff; color: #7c3aed; }
    .pp-kb-tag.selected { border-color: #7c3aed; background: #f5f3ff; color: #7c3aed; font-weight: 600; }
    .pp-kb-tag.selected::before { content: '\2713'; font-size: 11px; font-weight: 700; color: #7c3aed; }
    .pp-kb-tag .pp-kb-ext { font-size: 10px; padding: 1px 5px; border-radius: 4px; background: #f1f5f9; color: #94a3b8; font-weight: 500; }
    .pp-kb-tag.selected .pp-kb-ext { background: #ede9fe; color: #7c3aed; }
    .pp-kb-empty { font-size: 12px; color: #94a3b8; font-style: italic; padding: 8px 0; }
    .pp-kb-loading { font-size: 12px; color: #7c3aed; display: flex; align-items: center; gap: 6px; padding: 8px 0; }
    /* 题库选择面板 */
    .pp-panel-bank { background: linear-gradient(135deg, #eff6ff, #eef2ff); border-color: #93c5fd; }
    .pp-bank-select-row { display: flex; gap: 12px; align-items: center; margin-bottom: 16px; flex-wrap: wrap; }
    .pp-bank-select-row select { flex: 1; min-width: 200px; padding: 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0; font-size: 13.5px; color: #334155; background: #fff; outline: none; font-family: inherit; }
    .pp-bank-select-row select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
    .pp-bank-qlist { max-height: 400px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 10px; background: #fff; }
    .pp-bank-qlist::-webkit-scrollbar { width: 6px; }
    .pp-bank-qlist::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    .pp-bank-qitem { display: flex; align-items: flex-start; gap: 10px; padding: 12px 16px; border-bottom: 1px solid #f1f5f9; transition: background 0.15s; cursor: pointer; }
    .pp-bank-qitem:last-child { border-bottom: none; }
    .pp-bank-qitem:hover { background: #f8fafc; }
    .pp-bank-qitem input[type="checkbox"] { margin-top: 3px; flex-shrink: 0; width: 16px; height: 16px; accent-color: #6366f1; cursor: pointer; }
    .pp-bank-qitem-info { flex: 1; min-width: 0; }
    .pp-bank-qitem-type { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-right: 6px; }
    .pp-bank-qitem-content { font-size: 13px; color: #334155; line-height: 1.5; word-break: break-word; }
    .pp-bank-qitem-meta { font-size: 11px; color: #94a3b8; margin-top: 4px; }
    .pp-bank-actions { display: flex; gap: 10px; align-items: center; margin-top: 14px; flex-wrap: wrap; }
    .pp-bank-actions .pp-bank-count { font-size: 13px; color: #64748b; }
    .pp-bank-empty { text-align: center; padding: 30px 20px; color: #94a3b8; font-size: 13px; }
    .pp-tool-btn-bank { border-color: #93c5fd; color: #2563eb; }
    .pp-tool-btn-bank:hover { border-color: #60a5fa; background: #eff6ff; color: #1d4ed8; }
    /* 批量操作工具栏 */
    .pp-batch-bar { display: flex; align-items: center; gap: 14px; padding: 12px 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; margin-bottom: 16px; flex-wrap: wrap; }
    .pp-batch-bar label { font-size: 13px; color: #475569; cursor: pointer; display: flex; align-items: center; gap: 6px; font-weight: 500; }
    .pp-batch-bar input[type="checkbox"] { width: 16px; height: 16px; accent-color: #6366f1; cursor: pointer; }
    .pp-batch-count { font-size: 12px; color: #94a3b8; }
    .pp-batch-count strong { color: #6366f1; font-weight: 700; }
    .pp-batch-btn { display: inline-flex; align-items: center; gap: 4px; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 600; border: 1px solid #fecaca; background: #fff; color: #ef4444; cursor: pointer; transition: all 0.15s; font-family: inherit; }
    .pp-batch-btn:hover { background: #fef2f2; border-color: #f87171; }
    .pp-batch-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .pp-batch-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-check { flex-shrink: 0; width: 16px; height: 16px; accent-color: #6366f1; cursor: pointer; margin-right: 8px; }
    /* 分值统计 */
    .pp-score-stats { display: flex; gap: 16px; align-items: stretch; margin-bottom: 20px; flex-wrap: wrap; }
    .pp-score-stat-item { flex: 1; min-width: 140px; padding: 14px 18px; border-radius: 10px; background: #f8fafc; border: 1px solid #e2e8f0; }
    .pp-score-stat-item label { display: block; font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.3px; margin-bottom: 6px; }
    .pp-score-stat-item .pp-stat-value { font-size: 22px; font-weight: 700; color: #1e293b; }
    .pp-score-stat-item .pp-stat-unit { font-size: 13px; font-weight: 500; color: #64748b; margin-left: 2px; }
    .pp-score-stat-item.pp-stat-editable { background: #fff; border-color: #c7d2fe; }
    .pp-score-stat-item.pp-stat-editable input { width: 80px; font-size: 22px; font-weight: 700; color: #1e293b; border: none; background: transparent; outline: none; padding: 0; font-family: inherit; }
    .pp-score-stat-item.pp-stat-editable input:focus { color: #6366f1; }
    .pp-score-verify { display: flex; align-items: center; gap: 8px; padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; font-weight: 500; }
    .pp-score-verify svg { width: 18px; height: 18px; flex-shrink: 0; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; fill: none; }
    .pp-score-verify-ok { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .pp-score-verify-ok svg { stroke: #22c55e; }
    .pp-score-verify-warn { background: #fffbeb; border: 1px solid #fde68a; color: #92400e; }
    .pp-score-verify-warn svg { stroke: #f59e0b; }
    .pp-score-verify-err { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .pp-score-verify-err svg { stroke: #ef4444; }
    @media (max-width: 768px) {
        .pp-form-grid { grid-template-columns: 1fr; }
        .pp-opt-grid { grid-template-columns: 1fr; }
        .pp-item { flex-direction: column; align-items: flex-start; }
        .pp-item-actions { width: 100%; justify-content: flex-end; margin-top: 10px; }
    }
</style>

<div class="pp-page">
    <asp:HiddenField ID="HiddenPaperId" runat="server" Value="" />

    <div class="pp-header">
        <div>
            <div class="pp-title">
                <span class="pp-title-icon">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
                </span>
                试卷管理
            </div>
            <div class="pp-subtitle">创建和管理考试试卷，添加各类题型，组织考试内容</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="pp-msg pp-msg-<%= pageMsgType %>">
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

    <!-- ========== 试卷列表面板 ========== -->
    <asp:Panel ID="PanelList" runat="server" Visible="true">
        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                创建新试卷
            </div>
            <div class="pp-card-body">
                <div class="pp-form-grid">
                    <div class="pp-form-group pp-form-full">
                        <label>试卷标题 *</label>
                        <asp:TextBox ID="TxtNewTitle" runat="server" MaxLength="200" placeholder="请输入试卷标题，如：2026年信息技术期中考试" />
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>试卷描述</label>
                        <asp:TextBox ID="TxtNewDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="简要描述试卷内容和要求（选填）" />
                    </div>
                    <div class="pp-form-group">
                        <label>考试时长（分钟）</label>
                        <asp:TextBox ID="TxtNewTime" runat="server" MaxLength="5" Text="60" placeholder="60" />
                    </div>
                    <div class="pp-form-group">
                        <label>总分值</label>
                        <asp:TextBox ID="TxtNewScore" runat="server" MaxLength="5" Text="100" placeholder="100" />
                    </div>
                </div>
                <asp:Button ID="BtnCreatePaper" runat="server" Text="创建试卷" OnClick="BtnCreatePaper_Click" CssClass="pp-btn pp-btn-primary" />
            </div>
        </div>

        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                我的试卷
            </div>
            <div class="pp-card-body">
                <asp:Repeater ID="RptPapers" runat="server" OnItemCommand="RptPapers_ItemCommand">
                    <HeaderTemplate><div class="pp-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="pp-item">
                            <div class="pp-item-icon">
                                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                            </div>
                            <div class="pp-item-info">
                                <div class="pp-item-title">
                                    <%# Server.HtmlEncode(Eval("Ptitle") == DBNull.Value ? "" : Eval("Ptitle").ToString()) %>
                                    <span class="pp-status <%# GetStatusClass(Eval("Pstatus")) %>"><%# GetStatusText(Eval("Pstatus")) %></span>
                                </div>
                                <div class="pp-item-meta">
                                    <span class="pp-item-meta-tag">
                                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                        <%# Eval("Pcount") %> 题
                                    </span>
                                    <span class="pp-item-meta-tag">
                                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                        <%# Eval("Ptime") %> 分钟
                                    </span>
                                    <span class="pp-item-meta-tag">
                                        <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                                        <%# Eval("Pscore") %> 分
                                    </span>
                                    <span class="pp-item-meta-tag">
                                        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                        <%# FormatDate(Eval("Pdate")) %>
                                    </span>
                                </div>
                            </div>
                            <div class="pp-item-actions">
                                <a href='paper.aspx?mode=edit&pid=<%# Eval("Pid") %>' class="pp-act-btn pp-act-btn-edit">
                                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    编辑
                                </a>
                                <asp:LinkButton runat="server" CssClass="pp-act-btn pp-act-btn-copy" CausesValidation="false"
                                    CommandName="CopyPaper" CommandArgument='<%# Eval("Pid") %>'
                                    OnClientClick="return confirm('确定要复制该试卷吗？');">
                                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                                    复制
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="pp-act-btn pp-act-btn-toggle" CausesValidation="false"
                                    CommandName="ToggleStatus" CommandArgument='<%# Eval("Pid") %>'>
                                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                                    切换
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="pp-act-btn pp-act-btn-del" CausesValidation="false"
                                    CommandName="DelPaper" CommandArgument='<%# Eval("Pid") %>'
                                    OnClientClick="return confirm('确定要删除该试卷吗？删除后试卷及其所有试题都将被永久删除！');">
                                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                    删除
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="PanelEmpty" runat="server" Visible='<%# RptPapers.Items.Count == 0 %>'>
                    <div class="pp-empty">
                        <div class="pp-empty-icon">
                            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
                        </div>
                        <div class="pp-empty-text">还没有创建任何试卷</div>
                        <div class="pp-empty-hint">在上方填写信息创建你的第一份试卷吧</div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <!-- ========== 编辑试卷面板 ========== -->
    <asp:Panel ID="PanelEdit" runat="server" Visible="false">
        <asp:Button ID="BtnBackToList" runat="server" Text="" OnClick="BtnBackToList_Click" CssClass="pp-back-btn" style="display:none;" />
        <a href="paper.aspx" class="pp-back-btn">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回试卷列表
        </a>

        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
                试卷设置
            </div>
            <div class="pp-card-body">
                <div class="pp-form-grid">
                    <div class="pp-form-group pp-form-full">
                        <label>试卷标题 *</label>
                        <asp:TextBox ID="TxtEditTitle" runat="server" MaxLength="200" placeholder="试卷标题" />
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>试卷描述</label>
                        <asp:TextBox ID="TxtEditDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="试卷描述（选填）" />
                    </div>
                    <div class="pp-form-group">
                        <label>考试时长（分钟）</label>
                        <asp:TextBox ID="TxtEditTime" runat="server" MaxLength="5" placeholder="60" />
                    </div>
                </div>

                <!-- 分值统计区域 -->
                <div class="pp-score-stats">
                    <div class="pp-score-stat-item">
                        <label>题目数量</label>
                        <span class="pp-stat-value" id="statQuestionCount"><%= editQuestionCount %></span>
                        <span class="pp-stat-unit">题</span>
                    </div>
                    <div class="pp-score-stat-item">
                        <label>各题分值合计</label>
                        <span class="pp-stat-value" id="statScoreSum"><%= editScoreSum %></span>
                        <span class="pp-stat-unit">分</span>
                    </div>
                    <div class="pp-score-stat-item pp-stat-editable">
                        <label>试卷总分值</label>
                        <asp:TextBox ID="TxtEditScore" runat="server" MaxLength="5" placeholder="100" CssClass="" />
                        <span class="pp-stat-unit">分</span>
                    </div>
                </div>

                <!-- 分值验证提示 -->
                <div id="scoreVerifyBar" class="pp-score-verify <%= editQuestionCount == 0 ? "pp-score-verify-warn" : (editScoreSum == editTotalScore ? "pp-score-verify-ok" : "pp-score-verify-err") %>">
                    <% if (editQuestionCount == 0) { %>
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    暂无试题，请先添加题目
                    <% } else if (editScoreSum == editTotalScore) { %>
                    <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    分值校验通过：各题分值合计 (<%= editScoreSum %>分) = 试卷总分值 (<%= editTotalScore %>分)
                    <% } else { %>
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    分值不匹配：各题分值合计 (<span id="scoreVerifySumVal"><%= editScoreSum %></span>分) ≠ 试卷总分值 (<span id="scoreVerifyTotalVal"><%= editTotalScore %></span>分)，差值 <strong><%= Math.Abs(editScoreSum - editTotalScore) %></strong> 分
                    <% } %>
                </div>

                <asp:Button ID="BtnSavePaper" runat="server" Text="保存设置" OnClick="BtnSavePaper_Click" CssClass="pp-btn pp-btn-primary" />
            </div>
        </div>

        <!-- 导入 & AI 工具栏 -->
        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
                批量添题工具
            </div>
            <div class="pp-card-body">
                <div class="pp-tool-row">
                    <button type="button" class="pp-tool-btn" onclick="togglePanel('importPanel')">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        文本导入
                    </button>
                    <button type="button" class="pp-tool-btn pp-tool-btn-ai" onclick="togglePanel('aiPanel')">
                        <svg viewBox="0 0 24 24"><path d="M12 2a4 4 0 014 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0112 2z"/><circle cx="12" cy="6" r="1"/></svg>
                        AI 智能出题
                    </button>
                    <button type="button" class="pp-tool-btn pp-tool-btn-bank" onclick="togglePanel('bankPanel')">
                        <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                        题库选择
                    </button>
                </div>

                <!-- 导入面板 -->
                <div id="importPanel" class="pp-panel pp-panel-import" style="display:none;">
                    <div class="pp-panel-title">
                        <svg viewBox="0 0 24 24" stroke="#059669"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        从文本文件导入试题
                    </div>
                    <div class="pp-import-hint">
                        <strong>文件格式说明：</strong>每道题之间用<strong>空行</strong>分隔，每行一个字段：<br/>
                        <code>题型:single</code> 题型可选：single(单选) / multiple(多选) / truefalse(判断) / fill(填空) / essay(简答) / scratch(Scratch) / python(Python) / pythonblock(Python拼图)<br/>
                        <code>题目:题目内容</code><br/>
                        <code>A:选项A</code> <code>B:选项B</code> <code>C:选项C</code> <code>D:选项D</code>（选择题需要）<br/>
                        <code>答案:A</code><br/>
                        <code>分值:5</code>（可选，默认5分）
                    </div>
                    <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                        <asp:FileUpload ID="FileUploadImport" runat="server" />
                        <asp:Button ID="BtnImportQuestions" runat="server" Text="开始导入" OnClick="BtnImportQuestions_Click" CssClass="pp-btn pp-btn-success" style="padding:8px 18px;font-size:13px;" />
                    </div>
                </div>

                <!-- 题库选择面板 -->
                <div id="bankPanel" class="pp-panel pp-panel-bank" style="display:none;">
                    <div class="pp-panel-title">
                        <svg viewBox="0 0 24 24" stroke="#2563eb"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                        从题库选择试题
                    </div>
                    <div class="pp-bank-select-row">
                        <select id="bankSelect" onchange="loadBankQuestions()">
                            <option value="">-- 请选择题库 --</option>
                        </select>
                        <label style="font-size:13px;color:#475569;cursor:pointer;display:flex;align-items:center;gap:4px;white-space:nowrap;">
                            <input type="checkbox" id="bankSelectAll" onchange="toggleBankSelectAll()" style="accent-color:#6366f1;width:16px;height:16px;" /> 全选
                        </label>
                    </div>
                    <div id="bankQuestionList" class="pp-bank-qlist" style="display:none;"></div>
                    <div id="bankEmptyMsg" class="pp-bank-empty" style="display:none;">该题库暂无试题</div>
                    <div id="bankActions" class="pp-bank-actions" style="display:none;">
                        <span class="pp-bank-count">已选 <strong id="bankSelectedCount">0</strong> 题</span>
                        <button type="button" id="btnBankImport" class="pp-btn pp-btn-primary" style="padding:8px 20px;font-size:13px;" onclick="bankImportSelected()">添加到试卷</button>
                    </div>
                </div>

                <!-- AI 出题面板 -->
                <div id="aiPanel" class="pp-panel pp-panel-ai" style="display:none;">
                    <div class="pp-panel-title">
                        <svg viewBox="0 0 24 24" stroke="#7c3aed"><path d="M12 2a4 4 0 014 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0112 2z"/><circle cx="12" cy="6" r="1"/></svg>
                        AI 智能出题
                    </div>
                    <div id="aiKeywordsArea" class="pp-kw-list" style="display:none;"></div>
                    <div class="pp-kb-area" id="aiKbArea">
                        <div class="pp-kb-label">
                            <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>
                            知识库参考（可选，可多选，AI将扫描选中内容出题）
                        </div>
                        <div class="pp-kb-tags" id="aiKbTags">
                            <div class="pp-kb-loading"><span class="pp-ai-spinner"></span> 加载知识库...</div>
                        </div>
                        <!-- 关键词输入框 -->
                        <div id="aiKbKeywordArea" style="display:none;margin-top:12px;">
                            <div class="pp-kb-label" style="margin-bottom:6px;">
                                <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                                关键词（可选，帮助AI更精准地从知识库中提取相关内容）
                            </div>
                            <input type="text" id="aiKbKeyword" placeholder="如：变量、循环、函数、数组等关键词，多个关键词用空格分隔" 
                                style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;" />
                            <div style="font-size:11px;color:#94a3b8;margin-top:4px;">💡 提示：输入关键词后，AI将重点关注知识库中包含这些关键词的内容进行出题</div>
                        </div>
                    </div>
                    <div class="pp-form-grid">
                        <div class="pp-form-group pp-form-full">
                            <label>出题主题/知识点 *</label>
                            <input type="text" id="aiTopic" placeholder="如：Python基础语法、Scratch动画制作、计算机网络基础" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;" />
                        </div>
                        <div class="pp-form-group">
                            <label>题目类型</label>
                            <select id="aiQType" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;">
                                <option value="mixed">混合题型</option>
                                <option value="single">单选题</option>
                                <option value="multiple">多选题</option>
                                <option value="truefalse">判断题</option>
                                <option value="fill">填空题</option>
                                <option value="essay">简答题</option>
                                <option value="scratch">Scratch编程</option>
                                <option value="python">Python编程</option>
                                <option value="pythonblock">Python拼图</option>
                            </select>
                        </div>
                        <div class="pp-form-group">
                            <label>出题数量</label>
                            <input type="text" id="aiCount" value="5" placeholder="5" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;" />
                        </div>
                        <div class="pp-form-group">
                            <label>难度</label>
                            <select id="aiDiff" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;">
                                <option value="简单">简单</option>
                                <option value="中等" selected>中等</option>
                                <option value="困难">困难</option>
                            </select>
                        </div>
                    </div>
                    <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                        <button type="button" id="btnAiGenerate" class="pp-btn" style="background:linear-gradient(135deg,#7c3aed,#a855f7);color:#fff;box-shadow:0 4px 14px rgba(124,58,237,0.3);" onclick="aiGenerate()">
                            <svg viewBox="0 0 24 24" width="16" height="16" stroke="#fff" fill="none" stroke-width="2" style="margin-right:4px;"><path d="M12 2a4 4 0 014 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0112 2z"/><circle cx="12" cy="6" r="1"/></svg>
                            开始生成
                        </button>
                        <div class="pp-ai-loading" id="aiLoading">
                            <div class="pp-ai-spinner"></div>
                            <span id="aiLoadingText">AI 正在生成试题，请稍候...</span>
                        </div>
                    </div>
                    <div class="pp-ai-result" id="aiResult">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                            <span style="font-size:13px;font-weight:600;color:#334155;">生成结果 (<span id="aiResultCount">0</span> 题)</span>
                            <button type="button" id="btnAiSave" class="pp-btn pp-btn-success" style="padding:6px 16px;font-size:12px;" onclick="aiSaveAll()">全部添加到试卷</button>
                        </div>
                        <div id="aiResultList"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                试题列表
            </div>
            <div class="pp-card-body">
                <div class="pp-batch-bar" id="batchBar">
                    <label><input type="checkbox" id="qSelectAll" onchange="toggleQSelectAll()" /> 全选</label>
                    <span class="pp-batch-count">已选 <strong id="qSelectedCount">0</strong> 题</span>
                    <button type="button" class="pp-batch-btn" id="btnBatchDel" onclick="batchDeleteQuestions()" disabled>
                        <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                        批量删除
                    </button>
                </div>
                <div class="pp-batch-score-bar" id="batchScoreBar">
                    <label>
                        <svg viewBox="0 0 24 24" width="14" height="14" stroke="#d97706" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        按类型批量设置分值
                    </label>
                    <select id="batchScoreType">
                        <option value="">-- 全部类型 --</option>
                        <option value="single">单选题</option>
                        <option value="multiple">多选题</option>
                        <option value="truefalse">判断题</option>
                        <option value="fill">填空题</option>
                        <option value="essay">简答题</option>
                        <option value="scratch">Scratch编程</option>
                        <option value="python">Python编程</option>
                        <option value="pythonblock">Python拼图</option>
                    </select>
                    <input type="number" id="batchScoreValue" min="1" max="999" value="5" placeholder="分值" />
                    <button type="button" class="pp-batch-score-btn" id="btnBatchScore" onclick="batchUpdateScoreByType()">
                        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                        应用
                    </button>
                </div>
                <asp:Repeater ID="RptQuestions" runat="server" OnItemCommand="RptQuestions_ItemCommand">
                    <HeaderTemplate><div class="pp-q-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="pp-q-item">
                            <div class="pp-q-header">
                                <div class="pp-q-num">
                                    <input type="checkbox" class="pp-q-check" value='<%# Eval("Qid") %>' onchange="updateQSelectCount()" />
                                    <span class="pp-q-badge" style="background:<%# GetTypeBgColor(Eval("Qtype")) %>;color:<%# GetTypeColor(Eval("Qtype")) %>;">
                                        <%# GetTypeName(Eval("Qtype")) %>
                                    </span>
                    <span class="pp-q-score-edit" data-qid='<%# Eval("Qid") %>'><input type="number" min="1" max="999" value='<%# Eval("Qscore") %>' onchange="updateSingleScore(this)" onkeydown="if(event.key==='Enter'){this.blur();return false;}" /><span class="pp-q-score-unit">分</span></span>
                                </div>
                                <div class="pp-q-actions">
                                    <asp:LinkButton runat="server" CssClass="pp-q-act" CausesValidation="false" CommandName="MoveUp" CommandArgument='<%# Eval("Qid") %>' ToolTip="上移">&#9650;</asp:LinkButton>
                                    <asp:LinkButton runat="server" CssClass="pp-q-act" CausesValidation="false" CommandName="MoveDown" CommandArgument='<%# Eval("Qid") %>' ToolTip="下移">&#9660;</asp:LinkButton>
                                    <asp:LinkButton runat="server" CssClass="pp-q-act pp-q-act-del" CausesValidation="false" CommandName="DelQuestion" CommandArgument='<%# Eval("Qid") %>' OnClientClick="return confirm('确定删除此题吗？');" ToolTip="删除">&#10005;</asp:LinkButton>
                                </div>
                            </div>
                            <div class="pp-q-content"><%# Server.HtmlEncode(SafeStr(Eval("Qcontent"))) %></div>
            <asp:Panel runat="server" Visible='<%# Eval("Qtype").ToString() == "single" || Eval("Qtype").ToString() == "multiple" || Eval("Qtype").ToString() == "truefalse" %>'>
                                <div class="pp-q-options"><%# FormatOptions(Eval("Qoption_a"), Eval("Qoption_b"), Eval("Qoption_c"), Eval("Qoption_d")) %></div>
                            </asp:Panel>
                            <div class="pp-q-answer">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                答案：<%# Server.HtmlEncode(SafeStr(Eval("Qanswer"))) %>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>

                <asp:Panel runat="server" Visible='<%# RptQuestions.Items.Count == 0 %>'>
                    <div class="pp-empty" style="padding:40px 20px;">
                        <div class="pp-empty-icon" style="width:60px;height:60px;border-radius:14px;">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        </div>
                        <div class="pp-empty-text">还没有添加试题</div>
                        <div class="pp-empty-hint">在下方添加第一道试题</div>
                    </div>
                </asp:Panel>
            </div>

            <div class="pp-add-q-area">
                <div class="pp-add-q-title">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    添加新试题
                </div>
                <div class="pp-form-grid">
                    <div class="pp-form-group">
                        <label>题目类型</label>
                        <asp:DropDownList ID="DDLQType" runat="server">
                            <asp:ListItem Value="single" Text="单选题" />
                            <asp:ListItem Value="multiple" Text="多选题" />
                            <asp:ListItem Value="truefalse" Text="判断题" />
                            <asp:ListItem Value="fill" Text="填空题" />
                            <asp:ListItem Value="essay" Text="简答题" />
                            <asp:ListItem Value="scratch" Text="Scratch编程" />
                            <asp:ListItem Value="python" Text="Python编程" />
                            <asp:ListItem Value="pythonblock" Text="Python拼图" />
                        </asp:DropDownList>
                    </div>
                    <div class="pp-form-group">
                        <label>分值</label>
                        <asp:TextBox ID="TxtQScore" runat="server" MaxLength="5" Text="5" placeholder="5" />
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>题目内容 *</label>
                        <asp:TextBox ID="TxtQContent" runat="server" MaxLength="2000" TextMode="MultiLine" Rows="3" placeholder="请输入题目内容" />
                    </div>
                </div>
                <div id="optionsArea" style="margin-bottom:18px;">
                    <label style="font-size:12px;font-weight:600;color:#64748b;display:block;margin-bottom:8px;">选项（选择题填写，其他题型可留空）</label>
                    <div class="pp-opt-grid">
                        <div class="pp-form-group">
                            <label style="color:#6366f1;">A</label>
                            <asp:TextBox ID="TxtOptA" runat="server" MaxLength="500" placeholder="选项A" />
                        </div>
                        <div class="pp-form-group">
                            <label style="color:#6366f1;">B</label>
                            <asp:TextBox ID="TxtOptB" runat="server" MaxLength="500" placeholder="选项B" />
                        </div>
                        <div class="pp-form-group">
                            <label style="color:#6366f1;">C</label>
                            <asp:TextBox ID="TxtOptC" runat="server" MaxLength="500" placeholder="选项C" />
                        </div>
                        <div class="pp-form-group">
                            <label style="color:#6366f1;">D</label>
                            <asp:TextBox ID="TxtOptD" runat="server" MaxLength="500" placeholder="选项D" />
                        </div>
                    </div>
                </div>
                <div class="pp-form-group" style="margin-bottom:20px;">
                    <label>正确答案 *</label>
                    <asp:TextBox ID="TxtQAnswer" runat="server" MaxLength="500" placeholder="单选填A/B/C/D，多选填AB/AC等，判断填对/错，填空/简答/编程填参考答案" />
                </div>
                <asp:Button ID="BtnAddQuestion" runat="server" Text="添加试题" OnClick="BtnAddQuestion_Click" CssClass="pp-btn pp-btn-success" />
            </div>
        </div>
    </asp:Panel>
</div>

<script type="text/javascript">
    $(function () {
        var ddl = $('[id$="DDLQType"]');
        function toggleOptions() {
            var val = ddl.val();
            if (val === 'single' || val === 'multiple') {
                $('#optionsArea').slideDown(200);
            } else {
                $('#optionsArea').slideUp(200);
            }
        }
        ddl.on('change', toggleOptions);
        toggleOptions();
        // 加载AI出题配置
        loadQuizConfig();
        // 总分值输入框实时验证
        $('[id$="TxtEditScore"]').on('input', function() { updateScoreVerify(); });
    });

    // 面板切换
    function togglePanel(id) {
        var $panel = $('#' + id);
        if ($panel.is(':visible')) {
            $panel.slideUp(250);
        } else {
            $('.pp-panel:visible').slideUp(250);
            $panel.slideDown(250);
            if (id === 'bankPanel') loadBankList();
        }
    }

    // ========== AI 出题配置 ==========
    var quizConfig = {};
    function loadQuizConfig() {
        $.getJSON('questionbankapi.ashx?action=getquizconfig', function (data) {
            quizConfig = data;
            if (data.keywords) {
                var kws = data.keywords.split(',');
                var html = '';
                for (var i = 0; i < kws.length; i++) {
                    var kw = kws[i].trim();
                    if (kw) html += '<span class="pp-kw-tag" onclick="selectKeyword(this)">' + escapeHtml(kw) + '</span>';
                }
                if (html) {
                    document.getElementById('aiKeywordsArea').innerHTML = '<span style="font-size:12px;color:#64748b;margin-right:6px;">快捷选题：</span>' + html;
                    document.getElementById('aiKeywordsArea').style.display = 'flex';
                }
            }
        });
        // 加载知识库列表
        loadKbList();
    }

    // ========== 知识库加载和选择 ==========
    var kbItems = [];
    var selectedKbIds = [];
    function loadKbList() {
        $.getJSON('questionbankapi.ashx?action=listkb', function (data) {
            if (data.success && data.items && data.items.length > 0) {
                kbItems = data.items;
                var html = '';
                for (var i = 0; i < data.items.length; i++) {
                    var item = data.items[i];
                    html += '<span class="pp-kb-tag" data-id="' + escapeHtml(item.id) + '" onclick="toggleKbTag(this)">';
                    html += escapeHtml(item.title);
                    if (item.ext) html += ' <span class="pp-kb-ext">' + escapeHtml(item.ext) + '</span>';
                    html += '</span>';
                }
                document.getElementById('aiKbTags').innerHTML = html;
            } else {
                document.getElementById('aiKbTags').innerHTML = '<span class="pp-kb-empty">暂无知识库资料，请先在「知识库管理」中上传</span>';
            }
        }).fail(function() {
            document.getElementById('aiKbTags').innerHTML = '<span class="pp-kb-empty">知识库加载失败</span>';
        });
    }
    function toggleKbTag(el) {
        var id = el.getAttribute('data-id');
        if (el.classList.contains('selected')) {
            el.classList.remove('selected');
            selectedKbIds = selectedKbIds.filter(function(x) { return x !== id; });
        } else {
            el.classList.add('selected');
            selectedKbIds.push(id);
        }
        // 显示或隐藏关键词输入框
        var keywordArea = document.getElementById('aiKbKeywordArea');
        if (keywordArea) {
            keywordArea.style.display = selectedKbIds.length > 0 ? 'block' : 'none';
        }
    }
    function selectKeyword(el) {
        var tags = document.querySelectorAll('.pp-kw-tag');
        for (var i = 0; i < tags.length; i++) tags[i].classList.remove('active');
        el.classList.add('active');
        document.getElementById('aiTopic').value = el.textContent;
    }

    // ========== 题库选择功能 ==========
    var bankListLoaded = false;
    function loadBankList() {
        if (bankListLoaded) return;
        $.ajax({
            url: 'questionbankapi.ashx?action=listbanks', dataType: 'json', cache: false,
            success: function(res) {
                if (res.success && res.banks) {
                    var sel = $('#bankSelect');
                    sel.find('option:gt(0)').remove();
                    for (var i = 0; i < res.banks.length; i++) {
                        var b = res.banks[i];
                        sel.append('<option value="' + b.bid + '">' + escapeHtml(b.title) + ' (' + b.count + '题)</option>');
                    }
                    bankListLoaded = true;
                }
            }
        });
    }

    function loadBankQuestions() {
        var bid = $('#bankSelect').val();
        if (!bid) {
            $('#bankQuestionList').hide().html('');
            $('#bankEmptyMsg').hide();
            $('#bankActions').hide();
            return;
        }
        $('#bankQuestionList').html('<div class="pp-bank-empty">加载中...</div>').show();
        $('#bankEmptyMsg').hide();
        $('#bankActions').hide();
        $('#bankSelectAll').prop('checked', false);
        $.ajax({
            url: 'questionbankapi.ashx?action=listquestions&bid=' + bid, dataType: 'json', cache: false,
            success: function(res) {
                if (!res.success || !res.questions || res.questions.length === 0) {
                    $('#bankQuestionList').hide().html('');
                    $('#bankEmptyMsg').show();
                    return;
                }
                var html = '';
                for (var i = 0; i < res.questions.length; i++) {
                    var q = res.questions[i];
                    var tc = getTypeColor(q.type), tbc = getTypeBgColor(q.type);
                    html += '<div class="pp-bank-qitem" onclick="toggleBankCheck(this)">';
                    html += '<input type="checkbox" value="' + q.qid + '" onclick="event.stopPropagation();updateBankCount()" />';
                    html += '<div class="pp-bank-qitem-info">';
                    html += '<span class="pp-bank-qitem-type" style="background:' + tbc + ';color:' + tc + ';">' + getTypeName(q.type) + '</span>';
                    html += '<span class="pp-bank-qitem-content">' + escapeHtml(q.content) + '</span>';
                    var meta = '';
                    if ((q.type === 'single' || q.type === 'multiple') && q.option_a) {
                        meta += 'A.' + escapeHtml(q.option_a);
                        if (q.option_b) meta += '  B.' + escapeHtml(q.option_b);
                        if (q.option_c) meta += '  C.' + escapeHtml(q.option_c);
                        if (q.option_d) meta += '  D.' + escapeHtml(q.option_d);
                        meta += ' | ';
                    }
                    meta += '答案: ' + escapeHtml(q.answer) + ' | ' + q.score + '分';
                    html += '<div class="pp-bank-qitem-meta">' + meta + '</div>';
                    html += '</div></div>';
                }
                $('#bankQuestionList').html(html).show();
                $('#bankActions').show();
                updateBankCount();
            }
        });
    }

    function toggleBankCheck(el) {
        var cb = $(el).find('input[type=checkbox]');
        cb.prop('checked', !cb.prop('checked'));
        updateBankCount();
    }
    function toggleBankSelectAll() {
        var checked = $('#bankSelectAll').prop('checked');
        $('#bankQuestionList input[type=checkbox]').prop('checked', checked);
        updateBankCount();
    }
    function updateBankCount() {
        var cnt = $('#bankQuestionList input[type=checkbox]:checked').length;
        $('#bankSelectedCount').text(cnt);
    }
    function getTypeBgColor(t) {
        var map = {single:'#eef2ff',multiple:'#f5f3ff',truefalse:'#ecfeff',fill:'#ecfdf5',essay:'#fffbeb',scratch:'#fff7ed',python:'#eef2ff',pythonblock:'#ecfdf5'};
        return map[t] || '#f1f5f9';
    }
    function bankImportSelected() {
        var qids = [];
        $('#bankQuestionList input[type=checkbox]:checked').each(function() { qids.push(parseInt($(this).val())); });
        if (qids.length === 0) { alert('请先选择要添加的试题'); return; }
        var pid = $('[id$="HiddenPaperId"]').val();
        if (!pid) { alert('试卷ID丢失'); return; }
        $('#btnBankImport').prop('disabled', true).text('导入中...');
        $.ajax({
            url: 'questionbankapi.ashx?action=importtopaper',
            type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ pid: parseInt(pid), qids: qids }),
            success: function(res) {
                if (res.success) { alert(res.message); location.reload(); }
                else { alert('导入失败: ' + res.message); $('#btnBankImport').prop('disabled', false).text('添加到试卷'); }
            },
            error: function() { alert('请求失败'); $('#btnBankImport').prop('disabled', false).text('添加到试卷'); }
        });
    }

    // AI 出题变量
    var aiQuestions = [];

    function getTypeName(t) {
        var map = { single: '单选题', multiple: '多选题', truefalse: '判断题', fill: '填空题', essay: '简答题', scratch: 'Scratch编程', python: 'Python编程', pythonblock: 'Python拼图' };
        return map[t] || t;
    }

    // AI 生成
    function aiGenerate() {
        var topic = document.getElementById('aiTopic').value.trim();
        if (!topic) { alert('请输入出题主题/知识点'); return; }
        var qtype = document.getElementById('aiQType').value;
        var count = parseInt(document.getElementById('aiCount').value) || 5;
        var score = 5;
        var diff = document.getElementById('aiDiff').value;
        if (count < 1) count = 1;
        if (count > 20) count = 20;

        // 获取关键词
        var keyword = '';
        if (selectedKbIds.length > 0) {
            var keywordInput = document.getElementById('aiKbKeyword');
            if (keywordInput) {
                keyword = keywordInput.value.trim();
            }
        }

        // 如果选择了知识库，先获取内容再生成
        if (selectedKbIds.length > 0) {
            document.getElementById('aiLoading').className = 'pp-ai-loading show';
            document.getElementById('aiLoadingText').textContent = '正在读取知识库内容...';
            document.getElementById('aiResult').style.display = 'none';
            document.getElementById('btnAiGenerate').disabled = true;
            document.getElementById('btnAiGenerate').style.display = 'none';
            
            var url = 'questionbankapi.ashx?action=getkbcontent&ids=' + encodeURIComponent(selectedKbIds.join(','));
            if (keyword) {
                url += '&keyword=' + encodeURIComponent(keyword);
            }
            
            $.getJSON(url, function(data) {
                if (data.success && data.content) {
                    doAiGenerate(topic, qtype, count, score, diff, data.content, keyword);
                } else {
                    doAiGenerate(topic, qtype, count, score, diff, '', keyword);
                }
            }).fail(function() {
                doAiGenerate(topic, qtype, count, score, diff, '', keyword);
            });
        } else {
            doAiGenerate(topic, qtype, count, score, diff, '', keyword);
        }
    }

    function doAiGenerate(topic, qtype, count, score, diff, kbContent, keyword) {
        var typeDesc = qtype === 'mixed' ? '混合题型（包含单选题、多选题、判断题、填空题等）' : getTypeName(qtype);

        var prompt = '';
        if (kbContent) {
            prompt += '以下是知识库参考资料';
            if (keyword) {
                prompt += '（重点关注关键词：' + keyword + '）';
            }
            prompt += '，请基于这些内容出题：\n' + kbContent + '\n\n';
            if (keyword) {
                prompt += '【重要】请特别关注上述资料中与「' + keyword + '」相关的内容，围绕这些关键词出题。\n\n';
            }
        }
        prompt += '请你作为一位专业的信息技术教师，围绕「' + topic + '」这个知识点，出 ' + count + ' 道' + typeDesc + '试题。\n'
            + '难度要求：' + diff + '\n'
            + '每题分值：' + score + '分\n\n'
            + '【重要】请严格按照以下JSON格式返回，不要添加任何其他文字、解释或markdown标记，只返回纯JSON数组：\n'
            + '[\n';
        if (qtype === 'single' || qtype === 'mixed') {
            prompt += '  {"type":"single","content":"题目内容","option_a":"选项A","option_b":"选项B","option_c":"选项C","option_d":"选项D","answer":"A","score":' + score + '},\n';
        }
        if (qtype === 'truefalse' || qtype === 'mixed') {
            prompt += '  {"type":"truefalse","content":"题目内容","option_a":"","option_b":"","option_c":"","option_d":"","answer":"对","score":' + score + '},\n';
        }
        if (qtype === 'fill' || qtype === 'mixed') {
            prompt += '  {"type":"fill","content":"题目内容（用___表示空）","option_a":"","option_b":"","option_c":"","option_d":"","answer":"标准答案","score":' + score + '},\n';
        }
        if (qtype === 'multiple') {
            prompt += '  {"type":"multiple","content":"题目内容","option_a":"选项A","option_b":"选项B","option_c":"选项C","option_d":"选项D","answer":"AB","score":' + score + '},\n';
        }
        if (qtype === 'essay') {
            prompt += '  {"type":"essay","content":"题目内容","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考答案","score":' + score + '},\n';
        }
        if (qtype === 'scratch') {
            prompt += '  {"type":"scratch","content":"编程题目要求","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考思路","score":' + score + '},\n';
        }
        if (qtype === 'python' || qtype === 'mixed') {
            prompt += '  {"type":"python","content":"Python编程题目要求","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考代码","score":' + score + '},\n';
        }
        if (qtype === 'pythonblock') {
            prompt += '  {"type":"pythonblock","content":"Python拼图编程题目要求","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考思路","score":' + score + '},\n';
        }
        prompt += ']\n请确保返回的是合法的JSON数组，每个对象必须包含type,content,option_a,option_b,option_c,option_d,answer,score这些字段。';

        document.getElementById('aiLoading').className = 'pp-ai-loading show';
        document.getElementById('aiResult').style.display = 'none';
        document.getElementById('btnAiGenerate').disabled = true;
        document.getElementById('btnAiGenerate').style.display = 'none';
        aiQuestions = [];

        var fullResponse = '';
        fetch('questionbankapi.ashx?action=aichat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ messages: [{ role: 'user', content: prompt }] })
        }).then(function(response) {
            var reader = response.body.getReader();
            var decoder = new TextDecoder();
            var buffer = '';
            function read() {
                return reader.read().then(function(result) {
                    if (result.done) { parseAiResponse(fullResponse); return; }
                    buffer += decoder.decode(result.value, { stream: true });
                    var lines = buffer.split('\n');
                    for (var i = 0; i < lines.length - 1; i++) {
                        var line = lines[i].trim();
                        if (!line) continue;
                        var jsonStr = line.startsWith('data: ') ? line.substring(6) : line;
                        if (jsonStr === '[DONE]') continue;
                        try { var chunk = JSON.parse(jsonStr); if (chunk.content) fullResponse += chunk.content; } catch(e) {}
                    }
                    buffer = lines[lines.length - 1];
                    document.getElementById('aiLoadingText').textContent = 'AI 正在生成试题... (' + fullResponse.length + ' 字)';
                    return read();
                });
            }
            return read();
        }).catch(function(err) {
            alert('AI 请求失败: ' + err.message);
            document.getElementById('aiLoading').className = 'pp-ai-loading';
            document.getElementById('btnAiGenerate').disabled = false;
            document.getElementById('btnAiGenerate').style.display = '';
        });
    }

    function parseAiResponse(text) {
        document.getElementById('aiLoading').className = 'pp-ai-loading';
        document.getElementById('btnAiGenerate').disabled = false;
        document.getElementById('btnAiGenerate').style.display = '';
        var jsonText = text.replace(/```json\s*/gi, '').replace(/```\s*/g, '').trim();
        var start = jsonText.indexOf('[');
        var end = jsonText.lastIndexOf(']');
        if (start >= 0 && end > start) jsonText = jsonText.substring(start, end + 1);
        try {
            aiQuestions = JSON.parse(jsonText);
            if (!Array.isArray(aiQuestions)) aiQuestions = [aiQuestions];
        } catch(e) {
            alert('AI 返回的内容无法解析为试题格式，请重试。\n\n原始内容：\n' + text.substring(0, 500));
            aiQuestions = [];
            return;
        }
        // 渲染结果
        var html = '';
        for (var i = 0; i < aiQuestions.length; i++) {
            var q = aiQuestions[i];
            html += '<div class="pp-ai-result-item">';
            html += '<strong style="color:' + getTypeColor(q.type) + ';">[' + getTypeName(q.type) + ']</strong> ';
            html += escapeHtml(q.content || '');
            if ((q.type === 'single' || q.type === 'multiple') && q.option_a) {
                html += '<br/><span style="color:#64748b;font-size:12px;">A.' + escapeHtml(q.option_a) + '&emsp;B.' + escapeHtml(q.option_b || '') + '&emsp;C.' + escapeHtml(q.option_c || '') + '&emsp;D.' + escapeHtml(q.option_d || '') + '</span>';
            }
            html += '<br/><span style="color:#059669;font-size:12px;">答案：' + escapeHtml(q.answer || '') + ' | ' + (q.score || 5) + '分</span>';
            html += '</div>';
        }
        document.getElementById('aiResultList').innerHTML = html;
        document.getElementById('aiResultCount').textContent = aiQuestions.length;
        document.getElementById('aiResult').style.display = 'block';
    }

    function getTypeColor(t) {
        var map = { single: '#6366f1', multiple: '#8b5cf6', truefalse: '#0891b2', fill: '#059669', essay: '#d97706', scratch: '#f97316', python: '#4338ca', pythonblock: '#047857' };
        return map[t] || '#94a3b8';
    }

    function escapeHtml(s) {
        if (!s) return '';
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function aiSaveAll() {
        if (!aiQuestions || aiQuestions.length === 0) { alert('没有可保存的试题'); return; }
        var pid = $('[id$="HiddenPaperId"]').val();
        if (!pid) { alert('试卷ID丢失'); return; }
        document.getElementById('btnAiSave').disabled = true;
        document.getElementById('btnAiSave').textContent = '保存中...';
        $.ajax({
            url: 'paperapi.ashx?action=addquestions',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ pid: parseInt(pid), questions: aiQuestions }),
            success: function(res) {
                if (res.success) {
                    alert(res.message);
                    location.reload();
                } else {
                    alert('保存失败: ' + res.message);
                    document.getElementById('btnAiSave').disabled = false;
                    document.getElementById('btnAiSave').textContent = '全部添加到试卷';
                }
            },
            error: function() {
                alert('请求失败，请重试');
                document.getElementById('btnAiSave').disabled = false;
                document.getElementById('btnAiSave').textContent = '全部添加到试卷';
            }
        });
    }

    // ========== 批量操作 ==========
    function toggleQSelectAll() {
        var checked = document.getElementById('qSelectAll').checked;
        var cbs = document.querySelectorAll('.pp-q-check');
        for (var i = 0; i < cbs.length; i++) cbs[i].checked = checked;
        updateQSelectCount();
    }
    function updateQSelectCount() {
        var cbs = document.querySelectorAll('.pp-q-check:checked');
        var cnt = cbs.length;
        document.getElementById('qSelectedCount').textContent = cnt;
        document.getElementById('btnBatchDel').disabled = cnt === 0;
        // 同步全选状态
        var total = document.querySelectorAll('.pp-q-check').length;
        document.getElementById('qSelectAll').checked = total > 0 && cnt === total;
    }
    function batchDeleteQuestions() {
        var cbs = document.querySelectorAll('.pp-q-check:checked');
        if (cbs.length === 0) { alert('请先选择要删除的试题'); return; }
        if (!confirm('确定要删除选中的 ' + cbs.length + ' 道试题吗？此操作不可撤销！')) return;
        var qids = [];
        for (var i = 0; i < cbs.length; i++) qids.push(parseInt(cbs[i].value));
        var pid = $('[id$="HiddenPaperId"]').val();
        if (!pid) { alert('试卷ID丢失'); return; }
        document.getElementById('btnBatchDel').disabled = true;
        document.getElementById('btnBatchDel').textContent = '删除中...';
        $.ajax({
            url: 'paperapi.ashx?action=batchdelete',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ pid: parseInt(pid), qids: qids }),
            success: function(res) {
                if (res.success) {
                    alert(res.message);
                    location.reload();
                } else {
                    alert('删除失败: ' + res.message);
                    document.getElementById('btnBatchDel').disabled = false;
                    document.getElementById('btnBatchDel').innerHTML = '<svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg> 批量删除';
                }
            },
            error: function() {
                alert('请求失败，请重试');
                document.getElementById('btnBatchDel').disabled = false;
                document.getElementById('btnBatchDel').innerHTML = '<svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg> 批量删除';
            }
        });
    }

    // ========== 分值统计与验证 ==========
    function updateScoreVerify() {
        var scoreSum = parseInt($('#statScoreSum').text()) || 0;
        var qCount = parseInt($('#statQuestionCount').text()) || 0;
        var totalScore = parseInt($('[id$="TxtEditScore"]').val()) || 0;
        var bar = document.getElementById('scoreVerifyBar');
        if (!bar) return;
        var cls, icon, msg;
        if (qCount === 0) {
            cls = 'pp-score-verify pp-score-verify-warn';
            icon = '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>';
            msg = '暂无试题，请先添加题目';
        } else if (scoreSum === totalScore) {
            cls = 'pp-score-verify pp-score-verify-ok';
            icon = '<svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>';
            msg = '分值校验通过：各题分值合计 (' + scoreSum + '分) = 试卷总分值 (' + totalScore + '分)';
        } else {
            cls = 'pp-score-verify pp-score-verify-err';
            icon = '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>';
            var diff = Math.abs(scoreSum - totalScore);
            msg = '分值不匹配：各题分值合计 (' + scoreSum + '分) ≠ 试卷总分值 (' + totalScore + '分)，差值 <strong>' + diff + '</strong> 分';
        }
        bar.className = cls;
        bar.innerHTML = icon + ' ' + msg;
    }

    function refreshPaperStats() {
        var pid = $('[id$="HiddenPaperId"]').val();
        if (!pid) return;
        $.getJSON('paperapi.ashx?action=paperinfo&pid=' + pid, function(res) {
            if (!res.success) return;
            $('#statQuestionCount').text(res.count);
            $('#statScoreSum').text(res.scoreSum);
            updateScoreVerify();
        });
    }

    // ========== 内联分值编辑 ==========
    function updateSingleScore(input) {
        var score = parseInt(input.value);
        if (!score || score < 1) { input.value = 1; score = 1; }
        if (score > 999) { input.value = 999; score = 999; }
        var wrap = input.closest('.pp-q-score-edit');
        var qid = parseInt(wrap.getAttribute('data-qid'));
        var pid = $('[id$="HiddenPaperId"]').val();
        if (!pid || !qid) return;
        wrap.classList.add('saving');
        wrap.classList.remove('saved');
        $.ajax({
            url: 'paperapi.ashx?action=updatescore',
            type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ pid: parseInt(pid), qid: qid, score: score }),
            success: function(res) {
                wrap.classList.remove('saving');
                if (res.success) {
                    wrap.classList.add('saved');
                    setTimeout(function() { wrap.classList.remove('saved'); }, 1200);
                    refreshPaperStats();
                } else {
                    alert('更新失败: ' + res.message);
                }
            },
            error: function() {
                wrap.classList.remove('saving');
                alert('请求失败，请重试');
            }
        });
    }

    // ========== 按类型批量修改分值 ==========
    function batchUpdateScoreByType() {
        var qtype = document.getElementById('batchScoreType').value;
        var score = parseInt(document.getElementById('batchScoreValue').value);
        if (!score || score < 1) { alert('请输入有效的分值（1-999）'); return; }
        var pid = $('[id$="HiddenPaperId"]').val();
        if (!pid) { alert('试卷ID丢失'); return; }
        var typeLabel = qtype ? document.querySelector('#batchScoreType option:checked').text : '全部题目';
        if (!confirm('确定将「' + typeLabel + '」的分值全部设为 ' + score + ' 分吗？')) return;
        var btn = document.getElementById('btnBatchScore');
        btn.disabled = true;
        btn.textContent = '更新中...';
        $.ajax({
            url: 'paperapi.ashx?action=batchupdatescore',
            type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ pid: parseInt(pid), qtype: qtype, score: score }),
            success: function(res) {
                btn.disabled = false;
                btn.innerHTML = '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg> 应用';
                if (res.success) {
                    // 更新页面上对应类型的分值输入框
                    var items = document.querySelectorAll('.pp-q-item');
                    for (var i = 0; i < items.length; i++) {
                        var badge = items[i].querySelector('.pp-q-badge');
                        var scoreInput = items[i].querySelector('.pp-q-score-edit input');
                        if (!badge || !scoreInput) continue;
                        if (!qtype || getTypeKeyByName(badge.textContent.trim()) === qtype) {
                            scoreInput.value = score;
                            var wrap = scoreInput.closest('.pp-q-score-edit');
                            wrap.classList.add('saved');
                            setTimeout((function(w) { return function() { w.classList.remove('saved'); }; })(wrap), 1200);
                        }
                    }
                    refreshPaperStats();
                } else {
                    alert('更新失败: ' + res.message);
                }
            },
            error: function() {
                btn.disabled = false;
                btn.innerHTML = '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg> 应用';
                alert('请求失败，请重试');
            }
        });
    }
    function getTypeKeyByName(name) {
        var map = { '单选题':'single', '多选题':'multiple', '判断题':'truefalse', '填空题':'fill', '简答题':'essay', 'Scratch编程':'scratch', 'Python编程':'python', 'Python拼图':'pythonblock' };
        return map[name] || '';
    }
</script>
</asp:Content>
