<%@ Page Title="" Language="C#" MasterPageFile="~/student/Scm.master" StylesheetTheme="Student" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int surveyId = 0;
    protected int courseId = 0;
    protected string surveyTitle = "";
    protected string surveyContent = "";
    protected string pageMsg = "";
    protected string pageMsgType = "info";
    protected DataTable questionsTable = null;
    protected bool hasSubmitted = false;
    protected int totalScore = 0;
    
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
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(Request.QueryString["sid"]))
            int.TryParse(Request.QueryString["sid"], out surveyId);
        
        if (!string.IsNullOrEmpty(Request.QueryString["cid"]))
            int.TryParse(Request.QueryString["cid"], out courseId);
        
        // 已知路由修正：sid=17&cid=5 应重定向到编程页面
        if (surveyId == 17 && courseId == 5)
        {
            Response.Redirect("program.aspx?lid=29&mid=16&mcid=5", true);
            return;
        }
        
        // 每次请求都加载数据（PostBack 时也需要标题和题目用于渲染）
        LoadSurveyInfo();
        LoadQuestions();
        CheckSubmissionStatus();
    }
    
    private void LoadSurveyInfo()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || surveyId <= 0) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // 首先从 SurveyQuestion 表获取正确的课程ID
                if (courseId == 0)
                {
                    string qcidSql = "SELECT TOP 1 Qcid FROM SurveyQuestion WHERE Qvid=@vid";
                    using (SqlCommand qcidCmd = new SqlCommand(qcidSql, conn))
                    {
                        qcidCmd.Parameters.AddWithValue("@vid", surveyId);
                        object qcidResult = qcidCmd.ExecuteScalar();
                        if (qcidResult != null && qcidResult != DBNull.Value)
                        {
                            courseId = Convert.ToInt32(qcidResult);
                        }
                    }
                }
                
                // 从 Listmenu 表获取调查问卷标题
                string sql = @"
                    SELECT TOP 1 L.Ltitle, L.Lcid
                    FROM Listmenu L
                    WHERE L.Lxid = @vid AND L.Ltype = '14'
                    ORDER BY L.Lid DESC
                ";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@vid", surveyId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            object ltitleObj = reader["Ltitle"];
                            if (ltitleObj != DBNull.Value)
                            {
                                byte[] bytes = ltitleObj as byte[];
                                if (bytes != null)
                                    surveyTitle = System.Text.Encoding.Unicode.GetString(bytes);
                                else
                                    surveyTitle = ltitleObj.ToString();
                            }
                            
                            // 如果之前没有获取到课程ID，尝试从Listmenu获取
                            if (courseId == 0 && reader["Lcid"] != DBNull.Value)
                            {
                                courseId = Convert.ToInt32(reader["Lcid"]);
                            }
                            
                            if (string.IsNullOrEmpty(surveyTitle))
                                surveyTitle = "调查问卷";
                        }
                        else
                        {
                            surveyTitle = "调查问卷";
                        }
                    }
                }
                
                // 内容留空或使用默认文本
                surveyContent = "";
            }
        }
        catch (Exception ex)
        {
            pageMsg = "加载调查信息失败: " + ex.Message;
            pageMsgType = "error";
            surveyTitle = "调查问卷";
        }
    }
    
    private void LoadQuestions()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || surveyId <= 0) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"
                    SELECT Qid, Qtitle, Qblack, Qcount 
                    FROM SurveyQuestion 
                    WHERE Qvid=@vid 
                    ORDER BY Qid
                ";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@vid", surveyId);
                questionsTable = new DataTable();
                da.Fill(questionsTable);
                
                // 处理 ntext 字段
                foreach (DataRow row in questionsTable.Rows)
                {
                    if (row["Qtitle"] != DBNull.Value)
                    {
                        byte[] bytes = row["Qtitle"] as byte[];
                        if (bytes != null)
                            row["Qtitle"] = System.Text.Encoding.Unicode.GetString(bytes);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            pageMsg = "加载题目失败: " + ex.Message;
            pageMsgType = "error";
        }
    }
    
    private void CheckSubmissionStatus()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || surveyId <= 0) return;
        
        string studentNum = GetStudentNum();
        if (string.IsNullOrEmpty(studentNum)) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Fscore FROM SurveyFinish WHERE Fvid=@vid AND Fsnum=@snum";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@vid", surveyId);
                    cmd.Parameters.AddWithValue("@snum", studentNum);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        hasSubmitted = true;
                        totalScore = Convert.ToInt32(result);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // SurveyFinish 表可能不存在，记录但不阻塞页面
            System.Diagnostics.Debug.WriteLine("CheckSubmissionStatus error: " + ex.Message);
        }
    }
    
    // 安全地解析 Qblack 字段为布尔值
    private bool ParseQblack(object val)
    {
        if (val == null || val == DBNull.Value) return false;
        if (val is bool) return (bool)val;
        string s = val.ToString().Trim();
        if (s == "1" || s.Equals("True", StringComparison.OrdinalIgnoreCase)) return true;
        if (s == "0" || s.Equals("False", StringComparison.OrdinalIgnoreCase) || s == "") return false;
        try { return Convert.ToBoolean(val); } catch { return false; }
    }
    
    // 统一获取学生学号（Session -> Cookie）
    private string GetStudentNum()
    {
        // 方式1：从 Session 获取
        if (Session["Snum"] != null)
        {
            string snum = Session["Snum"].ToString();
            if (!string.IsNullOrEmpty(snum)) return snum;
        }
        
        // 方式2：从 Cookie 获取
        try
        {
            HttpCookie cookie = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
            {
                string cookieVal = cookie.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { }
                }
                
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | 
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null)
                    {
                        mi.Invoke(m, new object[] { cookieVal });
                        System.Reflection.PropertyInfo pNum = ct.GetProperty("Snum");
                        if (pNum != null)
                        {
                            object numVal = pNum.GetValue(m, null);
                            if (numVal != null && !string.IsNullOrEmpty(numVal.ToString()))
                                return numVal.ToString();
                        }
                    }
                }
            }
        }
        catch { }
        
        return "";
    }
    
    // 统一获取学生姓名
    private string GetStudentName()
    {
        if (Session["Sname"] != null)
        {
            string sname = Session["Sname"].ToString();
            if (!string.IsNullOrEmpty(sname)) return sname;
        }
        
        try
        {
            HttpCookie cookie = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
            {
                string cookieVal = cookie.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { }
                }
                
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | 
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null)
                    {
                        mi.Invoke(m, new object[] { cookieVal });
                        System.Reflection.PropertyInfo pName = ct.GetProperty("Sname");
                        if (pName != null)
                        {
                            object nameVal = pName.GetValue(m, null);
                            if (nameVal != null) return nameVal.ToString();
                        }
                    }
                }
            }
        }
        catch { }
        
        return "";
    }
    
    protected void BtnSubmit_Click(object sender, EventArgs e)
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || surveyId <= 0)
        {
            pageMsg = "提交失败：参数错误";
            pageMsgType = "error";
            return;
        }
        
        string studentNum = GetStudentNum();
        string studentName = GetStudentName();
        
        if (string.IsNullOrEmpty(studentNum))
        {
            pageMsg = "请先登录后再提交";
            pageMsgType = "error";
            return;
        }
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // 检查是否已提交
                string checkSql = "SELECT COUNT(*) FROM SurveyFinish WHERE Fvid=@vid AND Fsnum=@snum";
                using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@vid", surveyId);
                    checkCmd.Parameters.AddWithValue("@snum", studentNum);
                    int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (count > 0)
                    {
                        pageMsg = "您已经提交过此调查问卷";
                        pageMsgType = "warning";
                        hasSubmitted = true;
                        
                        // 获取之前的得分
                        string scoreSql = "SELECT Fscore FROM SurveyFinish WHERE Fvid=@vid AND Fsnum=@snum";
                        using (SqlCommand scoreCmd = new SqlCommand(scoreSql, conn))
                        {
                            scoreCmd.Parameters.AddWithValue("@vid", surveyId);
                            scoreCmd.Parameters.AddWithValue("@snum", studentNum);
                            object scoreResult = scoreCmd.ExecuteScalar();
                            if (scoreResult != null && scoreResult != DBNull.Value)
                            {
                                totalScore = Convert.ToInt32(scoreResult);
                            }
                        }
                        return;
                    }
                }
                
                // 获取所有题目和答案，计算分数
                int score = 0;
                
                // 获取所有题目
                string questionSql = "SELECT Qid, Qblack FROM SurveyQuestion WHERE Qvid=@vid";
                using (SqlCommand qCmd = new SqlCommand(questionSql, conn))
                {
                    qCmd.Parameters.AddWithValue("@vid", surveyId);
                    using (SqlDataReader qReader = qCmd.ExecuteReader())
                    {
                        System.Collections.Generic.List<System.Collections.Generic.KeyValuePair<int, bool>> qidList = 
                            new System.Collections.Generic.List<System.Collections.Generic.KeyValuePair<int, bool>>();
                        while (qReader.Read())
                        {
                            int qid = Convert.ToInt32(qReader["Qid"]);
                            bool isBlank = ParseQblack(qReader["Qblack"]);
                            qidList.Add(new System.Collections.Generic.KeyValuePair<int, bool>(qid, isBlank));
                        }
                        qReader.Close();
                        
                        // 遍历所有题目，计算分数
                        foreach (System.Collections.Generic.KeyValuePair<int, bool> qPair in qidList)
                        {
                            int qid = qPair.Key;
                            bool isBlank = qPair.Value;
                            
                            if (isBlank)
                            {
                                // 填空题：收集所有填空答案，与选项答案进行匹配
                                System.Collections.Generic.List<string> blankAnswers = new System.Collections.Generic.List<string>();
                                int blankIndex = 0;
                                while (true)
                                {
                                    string blankKey = "blank_" + qid + "_" + blankIndex;
                                    string blankAnswer = Request.Form[blankKey];
                                    if (string.IsNullOrEmpty(blankAnswer)) break;
                                    blankAnswers.Add(blankAnswer.Trim().ToLower());
                                    blankIndex++;
                                }
                                
                                // 查询该题的所有选项，看是否有匹配的答案
                                if (blankAnswers.Count > 0)
                                {
                                    string itemSql = "SELECT Mitem, Mscore FROM SurveyItem WHERE Mqid=@qid";
                                    using (SqlCommand iCmd = new SqlCommand(itemSql, conn))
                                    {
                                        iCmd.Parameters.AddWithValue("@qid", qid);
                                        using (SqlDataReader iReader = iCmd.ExecuteReader())
                                        {
                                            while (iReader.Read())
                                            {
                                                string correctAnswer = "";
                                                if (iReader["Mitem"] != DBNull.Value)
                                                {
                                                    byte[] bytes = iReader["Mitem"] as byte[];
                                                    if (bytes != null)
                                                        correctAnswer = System.Text.Encoding.Unicode.GetString(bytes);
                                                    else
                                                        correctAnswer = iReader["Mitem"].ToString();
                                                }
                                                
                                                correctAnswer = correctAnswer.Trim().ToLower();
                                                
                                                // 检查学生答案是否包含正确答案
                                                bool isCorrect = false;
                                                foreach (string studentAnswer in blankAnswers)
                                                {
                                                    if (studentAnswer == correctAnswer || correctAnswer.Contains(studentAnswer) || studentAnswer.Contains(correctAnswer))
                                                    {
                                                        isCorrect = true;
                                                        break;
                                                    }
                                                }
                                                
                                                if (isCorrect && iReader["Mscore"] != DBNull.Value)
                                                {
                                                    score += Convert.ToInt32(iReader["Mscore"]);
                                                    break; // 找到匹配答案后跳出
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                // 单选题：原有逻辑
                                string answer = Request.Form["q_" + qid];
                                
                                if (!string.IsNullOrEmpty(answer))
                                {
                                    // 查询选项分值
                                    string scoreSql = "SELECT Mscore FROM SurveyItem WHERE Mid=@mid";
                                    using (SqlCommand sCmd = new SqlCommand(scoreSql, conn))
                                    {
                                        int mid;
                                        if (int.TryParse(answer, out mid))
                                        {
                                            sCmd.Parameters.AddWithValue("@mid", mid);
                                            object scoreResult = sCmd.ExecuteScalar();
                                            if (scoreResult != null && scoreResult != DBNull.Value)
                                            {
                                                score += Convert.ToInt32(scoreResult);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 保存提交记录
                string insertSql = @"
                    INSERT INTO SurveyFinish (Fvid, Fsnum, Fsname, Fscore, Ftime) 
                    VALUES (@vid, @snum, @sname, @score, @time)
                ";
                using (SqlCommand insertCmd = new SqlCommand(insertSql, conn))
                {
                    insertCmd.Parameters.AddWithValue("@vid", surveyId);
                    insertCmd.Parameters.AddWithValue("@snum", studentNum);
                    insertCmd.Parameters.Add("@sname", SqlDbType.NText).Value = studentName;
                    insertCmd.Parameters.AddWithValue("@score", score);
                    insertCmd.Parameters.AddWithValue("@time", DateTime.Now);
                    insertCmd.ExecuteNonQuery();
                }
                
                totalScore = score;
                hasSubmitted = true;
                pageMsg = "提交成功！您的得分：" + score + " 分 (学号：" + studentNum + ")";
                pageMsgType = "success";
            }
        }
        catch (Exception ex)
        {
            pageMsg = "提交失败: " + ex.Message;
            pageMsgType = "error";
        }
    }
    
    protected DataTable GetQuestionOptions(int qid)
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return null;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Mid, Mitem, Mscore FROM SurveyItem WHERE Mqid=@qid ORDER BY Mid";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@qid", qid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                // 处理 ntext 字段
                foreach (DataRow row in dt.Rows)
                {
                    if (row["Mitem"] != DBNull.Value)
                    {
                        byte[] bytes = row["Mitem"] as byte[];
                        if (bytes != null)
                            row["Mitem"] = System.Text.Encoding.Unicode.GetString(bytes);
                    }
                }
                
                return dt;
            }
        }
        catch
        {
            return null;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" runat="Server">
<!-- Survey Page v3.0 - Wider Glass Layout -->
<style>
    body .studmasterhead,
    body .studmasterhead .stu,
    body .studmasterhead .placeauto,
    body #student,
    body .ccontent {
        width: 100% !important;
        max-width: none !important;
    }
    body .studmasterhead {
        margin: 0 !important;
        padding-left: 0 !important;
    }
    body .studmasterhead .stu,
    body .studmasterhead .placeauto {
        overflow: visible !important;
    }
    body .studmasterhead .placeauto {
        padding: 0 0 24px !important;
    }
    .survey-layout {
        max-width: 1780px;
        margin: 0 auto;
        padding: 24px 24px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
        color: #1f2937;
        animation: surveyFadeIn .45s ease;
    }
    .survey-shell {
        position: relative;
        border-radius: 28px;
        background: linear-gradient(180deg, #f8fbff 0%, #eef4ff 100%);
        box-shadow: 0 24px 60px rgba(15, 23, 42, 0.10);
        overflow: hidden;
    }
    .survey-shell::before {
        content: '';
        position: absolute;
        inset: 0;
        background:
            radial-gradient(circle at top right, rgba(59, 130, 246, 0.16), transparent 28%),
            radial-gradient(circle at left center, rgba(14, 165, 233, 0.14), transparent 22%),
            linear-gradient(135deg, rgba(255,255,255,.72), rgba(255,255,255,.22));
        pointer-events: none;
    }
    .survey-show-page {
        position: relative;
        z-index: 1;
        padding: 36px;
    }
    @keyframes surveyFadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .survey-hero {
        display: grid;
        grid-template-columns: minmax(0, 1.55fr) minmax(300px, .9fr);
        gap: 24px;
        margin-bottom: 28px;
    }
    .survey-hero-main,
    .survey-hero-side,
    .survey-card,
    .survey-question,
    .survey-result,
    .survey-empty {
        border: 1px solid rgba(148, 163, 184, 0.18);
        background: rgba(255,255,255,.82);
        backdrop-filter: blur(14px);
        -webkit-backdrop-filter: blur(14px);
        box-shadow: 0 16px 36px rgba(30, 41, 59, 0.08);
    }
    .survey-hero-main {
        border-radius: 26px;
        padding: 34px 36px;
        min-height: 220px;
        background: linear-gradient(135deg, #0f172a 0%, #1d4ed8 58%, #38bdf8 100%);
        color: #fff;
        position: relative;
        overflow: hidden;
    }
    .survey-hero-main::before,
    .survey-hero-main::after {
        content: '';
        position: absolute;
        border-radius: 999px;
        background: rgba(255,255,255,.10);
    }
    .survey-hero-main::before {
        width: 220px;
        height: 220px;
        top: -70px;
        right: -40px;
    }
    .survey-hero-main::after {
        width: 140px;
        height: 140px;
        bottom: -48px;
        left: -36px;
    }
    .survey-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        border-radius: 999px;
        background: rgba(255,255,255,.14);
        border: 1px solid rgba(255,255,255,.18);
        font-size: 13px;
        letter-spacing: .08em;
        text-transform: uppercase;
    }
    .survey-header-title {
        position: relative;
        z-index: 1;
        margin: 18px 0 12px;
        font-size: 34px;
        line-height: 1.3;
        font-weight: 700;
    }
    .survey-header-desc {
        position: relative;
        z-index: 1;
        max-width: 860px;
        font-size: 15px;
        line-height: 1.85;
        color: rgba(255,255,255,.88);
    }
    .survey-meta-list {
        position: relative;
        z-index: 1;
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 24px;
    }
    .survey-meta-pill {
        min-width: 132px;
        padding: 12px 14px;
        border-radius: 18px;
        background: rgba(255,255,255,.12);
        border: 1px solid rgba(255,255,255,.16);
    }
    .survey-meta-label {
        display: block;
        margin-bottom: 6px;
        font-size: 12px;
        color: rgba(255,255,255,.72);
    }
    .survey-meta-value {
        display: block;
        font-size: 20px;
        font-weight: 700;
        color: #fff;
    }
    .survey-hero-side {
        border-radius: 26px;
        padding: 28px;
    }
    .survey-side-title {
        font-size: 18px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 18px;
    }
    .survey-side-list {
        list-style: none;
        margin: 0;
        padding: 0;
    }
    .survey-side-list li {
        position: relative;
        padding: 0 0 0 18px;
        margin-bottom: 14px;
        font-size: 14px;
        line-height: 1.75;
        color: #475569;
    }
    .survey-side-list li::before {
        content: '';
        position: absolute;
        left: 0;
        top: 10px;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: linear-gradient(135deg, #2563eb, #38bdf8);
        box-shadow: 0 0 0 5px rgba(59, 130, 246, 0.10);
    }
    .survey-msg {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 16px 20px;
        border-radius: 18px;
        margin-bottom: 20px;
        font-size: 14px;
        border: 1px solid transparent;
    }
    .survey-msg::before {
        flex: 0 0 auto;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        font-weight: 700;
    }
    .survey-msg-success {
        background: #ecfdf5;
        border-color: #a7f3d0;
        color: #065f46;
    }
    .survey-msg-success::before {
        content: '✓';
        background: #10b981;
        color: #fff;
    }
    .survey-msg-error {
        background: #fef2f2;
        border-color: #fecaca;
        color: #991b1b;
    }
    .survey-msg-error::before {
        content: '!';
        background: #ef4444;
        color: #fff;
    }
    .survey-msg-warning {
        background: #fffbeb;
        border-color: #fde68a;
        color: #92400e;
    }
    .survey-msg-warning::before {
        content: '!';
        background: #f59e0b;
        color: #fff;
    }
    .survey-card {
        border-radius: 24px;
        padding: 28px 30px;
        margin-bottom: 24px;
    }
    .survey-card-title {
        font-size: 18px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 14px;
    }
    .survey-content-text {
        font-size: 15px;
        line-height: 1.9;
        color: #475569;
    }
    .survey-questions {
        display: grid;
        gap: 26px;
    }
    .survey-question {
        border-radius: 28px;
        padding: 0;
        background: rgba(255,255,255,.92);
        border: 1px solid #dde5ec;
        overflow: hidden;
        box-shadow: 0 14px 36px rgba(148, 163, 184, .12);
        transition: box-shadow .18s ease, transform .18s ease, border-color .18s ease;
    }
    .survey-question:hover {
        transform: translateY(-1px);
        border-color: #d0dbe5;
        box-shadow: 0 18px 42px rgba(148, 163, 184, .16);
    }
    .survey-question-topbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        min-height: 68px;
        padding: 0 22px;
        background: #f3f4f6;
        border-bottom: 1px solid #e5e7eb;
        color: #6b7280;
        font-size: 18px;
    }
    .survey-question-toptext {
        flex: 1;
        font-weight: 500;
        line-height: 1.6;
        text-align: left;
    }
    .survey-question-flag {
        width: 26px;
        height: 26px;
        opacity: .35;
        flex-shrink: 0;
    }
    .survey-question-body {
        padding: 26px 18px 22px;
        background: #fff;
    }
    .survey-question-header {
        display: block !important;
        margin-bottom: 20px !important;
        text-align: center !important;
    }
    .survey-question-num {
        display: none !important;
    }
    .survey-question-title {
        display: block !important;
        max-width: 1120px;
        margin: 0 auto !important;
        padding: 0 12px !important;
        font-size: 24px !important;
        font-weight: 500 !important;
        color: #1f2937 !important;
        line-height: 1.9 !important;
        text-align: left !important;
        word-break: break-word;
    }
    .survey-blank-input {
        display: inline-flex;
        min-width: 160px;
        height: 42px;
        padding: 0 14px;
        margin: 0 6px;
        border-radius: 12px;
        border: 1px solid #bfdbfe;
        background: #fff;
        font-size: 14px;
        font-family: inherit;
        color: #0f172a;
        transition: border-color .18s ease, box-shadow .18s ease, transform .18s ease;
    }
    .survey-blank-input:focus {
        outline: none;
        border-color: #3b82f6;
        box-shadow: 0 0 0 4px rgba(59, 130, 246, .15);
        transform: translateY(-1px);
    }
    .survey-blank-input::placeholder {
        color: #94a3b8;
    }
    .survey-options {
        display: grid !important;
        grid-template-columns: 1fr !important;
        gap: 16px !important;
        max-width: 1240px;
        margin: 0 auto;
    }
    .survey-option {
        display: flex !important;
        align-items: center !important;
        gap: 16px !important;
        min-height: 78px !important;
        padding: 0 22px !important;
        border-radius: 14px !important;
        border: 1px solid #eceff3 !important;
        background: #fff !important;
        cursor: pointer !important;
        position: relative !important;
        transition: border-color .18s ease, box-shadow .18s ease, transform .18s ease, background .18s ease !important;
    }
    .survey-option:hover {
        transform: none;
        border-color: #d6dde5 !important;
        background: #fcfcfd !important;
        box-shadow: 0 8px 18px rgba(148, 163, 184, 0.08) !important;
    }
    .survey-option input[type="radio"] {
        position: static;
        opacity: 1;
        pointer-events: auto;
        width: 24px;
        height: 24px;
        accent-color: #d1d5db;
        flex-shrink: 0;
        margin: 0;
    }
    .survey-option-prefix {
        width: auto !important;
        height: auto !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        min-width: 44px !important;
        padding: 0 !important;
        background: transparent !important;
        color: #6b7280 !important;
        font-size: 17px !important;
        font-weight: 500 !important;
        transition: all .18s ease !important;
    }
    .survey-option-label {
        flex: 1;
        font-size: 17px;
        line-height: 1.7;
        color: #374151;
        text-align: left;
        padding-right: 0;
    }
    .survey-option input[type="radio"]:checked {
        accent-color: #9ca3af;
    }
    .survey-option input[type="radio"]:checked ~ .survey-option-label {
        color: #0f172a;
        font-weight: 500;
    }
    .survey-actions {
        display: flex;
        justify-content: center;
        margin-top: 28px;
        padding-top: 4px;
    }
    .survey-btn {
        min-width: 220px;
        height: 54px;
        padding: 0 34px;
        border: none;
        border-radius: 999px;
        font-family: inherit;
        font-size: 16px;
        font-weight: 700;
        letter-spacing: .03em;
        cursor: pointer;
        transition: transform .18s ease, box-shadow .18s ease, opacity .18s ease;
    }
    .survey-btn-primary {
        background: linear-gradient(135deg, #0f172a 0%, #2563eb 55%, #38bdf8 100%);
        color: #fff;
        box-shadow: 0 18px 32px rgba(37, 99, 235, 0.22);
    }
    .survey-btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 24px 38px rgba(37, 99, 235, 0.28);
    }
    .survey-btn-primary:disabled {
        opacity: .65;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
    }
    .survey-result,
    .survey-empty {
        border-radius: 26px;
        padding: 42px 28px;
        text-align: center;
    }
    .survey-result {
        background: linear-gradient(135deg, rgba(236, 253, 245, .96) 0%, rgba(220, 252, 231, .92) 100%);
        border-color: rgba(52, 211, 153, .28);
    }
    .survey-result-icon,
    .survey-empty-icon {
        font-size: 60px;
        margin-bottom: 18px;
    }
    .survey-result-title,
    .survey-empty-text {
        font-size: 24px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 10px;
    }
    .survey-result-score {
        font-size: 48px;
        font-weight: 800;
        color: #059669;
        margin-bottom: 10px;
    }
    .survey-result-text,
    .survey-empty-desc {
        font-size: 15px;
        line-height: 1.8;
        color: #475569;
    }
    @media (max-width: 1366px) {
        .survey-layout {
            max-width: 1600px;
            padding: 20px 18px 34px;
        }
        .survey-show-page {
            padding: 28px;
        }
    }
    @media (max-width: 1180px) {
        .survey-hero {
            grid-template-columns: 1fr;
        }
        .survey-options {
            grid-template-columns: 1fr !important;
        }
    }
    @media (max-width: 768px) {
        .survey-layout {
            padding: 14px 8px 24px;
        }
        .survey-show-page {
            padding: 18px;
        }
        .survey-hero-main,
        .survey-hero-side,
        .survey-card,
        .survey-question,
        .survey-result,
        .survey-empty {
            border-radius: 20px;
        }
        .survey-header-title {
            font-size: 26px;
        }
        .survey-question-topbar {
            min-height: 58px;
            padding: 0 14px;
            font-size: 15px;
        }
        .survey-question-title {
            font-size: 16px !important;
            line-height: 1.8 !important;
        }
        .survey-option {
            min-height: 68px !important;
            padding: 0 14px !important;
        }
        .survey-option input[type="radio"] {
            width: 20px;
            height: 20px;
        }
        .survey-option-prefix {
            font-size: 16px !important;
        }
        .survey-option-label {
            font-size: 16px;
        }
        .survey-btn {
            width: 100%;
            min-width: 0;
        }
    }
</style>

<div class="survey-layout survey-page-root">
    <div class="survey-shell">
        <div class="survey-show-page">
            <div class="survey-hero">
                <div class="survey-hero-main">
                    <span class="survey-badge">问卷中心</span>
                    <div class="survey-header-title"><%= Server.HtmlEncode(surveyTitle) %></div>
                    <div class="survey-header-desc">请认真阅读每一道题目后再作答。页面已调整为更宽的阅读版式，在大屏下可以更舒适地浏览题目与选项。</div>
                    <div class="survey-meta-list">
                        <div class="survey-meta-pill">
                            <span class="survey-meta-label">问卷编号</span>
                            <span class="survey-meta-value"><%= surveyId > 0 ? surveyId.ToString() : "--" %></span>
                        </div>
                        <div class="survey-meta-pill">
                            <span class="survey-meta-label">课程编号</span>
                            <span class="survey-meta-value"><%= courseId > 0 ? courseId.ToString() : "--" %></span>
                        </div>
                        <div class="survey-meta-pill">
                            <span class="survey-meta-label">题目数量</span>
                            <span class="survey-meta-value"><%= questionsTable != null ? questionsTable.Rows.Count.ToString() : "0" %></span>
                        </div>
                    </div>
                </div>
                <div class="survey-hero-side">
                    <div class="survey-side-title">作答说明</div>
                    <ul class="survey-side-list">
                        <li>单选题请点击卡片直接选择答案，当前项会高亮显示。</li>
                        <li>填空题请在题目中的输入框填写内容后再提交。</li>
                        <li>提交后系统会记录结果；若已提交，将直接显示当前成绩。</li>
                    </ul>
                </div>
            </div>

            <% if (!string.IsNullOrEmpty(pageMsg)) { %>
            <div class="survey-msg survey-msg-<%= pageMsgType %>">
                <span><%= Server.HtmlEncode(pageMsg) %></span>
            </div>
            <% } %>

            <% if (!string.IsNullOrEmpty(surveyContent)) { %>
            <div class="survey-card">
                <div class="survey-card-title">问卷说明</div>
                <div class="survey-content-text"><%= surveyContent %></div>
            </div>
            <% } %>

            <% if (hasSubmitted) { %>
            <div class="survey-result">
                <div class="survey-result-icon">🎉</div>
                <div class="survey-result-title">问卷已提交</div>
                <div class="survey-result-score"><%= totalScore %> 分</div>
                <div class="survey-result-text">系统已保存您的答卷，感谢参与本次调查。</div>
            </div>
            <% } else if (questionsTable != null && questionsTable.Rows.Count > 0) { %>
            <div class="survey-questions">
                <%
                int questionIndex = 1;
                foreach (DataRow question in questionsTable.Rows)
                {
                    int qid = Convert.ToInt32(question["Qid"]);
                    string qtitle = question["Qtitle"] != DBNull.Value ? question["Qtitle"].ToString() : "";
                    bool isBlank = ParseQblack(question["Qblack"]);
                    DataTable options = GetQuestionOptions(qid);
                %>
                <div class="survey-question">
                    <div class="survey-question-topbar">
                        <div class="survey-question-toptext"><%= questionIndex %>、<% if (isBlank) { %>填空题<% } else { %>单选题<% } %>：根据题干信息，在选项中选择合适的答案。</div>
                        <svg class="survey-question-flag" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M5 3a1 1 0 0 1 1 1v16a1 1 0 1 1-2 0V4a1 1 0 0 1 1-1zm3 2h9.5a1 1 0 0 1 .8 1.6L16 9l2.3 2.4A1 1 0 0 1 17.5 13H8V5z"/></svg>
                    </div>
                    <div class="survey-question-body">
                    <div class="survey-question-header">
                        <div class="survey-question-num"><%= questionIndex %></div>
                        <div class="survey-question-title">
                            <% if (isBlank) {
                                string[] parts = qtitle.Split(new string[] { "_____" }, StringSplitOptions.None);
                                for (int i = 0; i < parts.Length; i++) {
                                    Response.Write(parts[i]);
                                    if (i < parts.Length - 1) {
                                        Response.Write("<input type='text' name='blank_" + qid + "_" + i + "' class='survey-blank-input' placeholder='请填写答案' required />");
                                    }
                                }
                            } else {
                                Response.Write(qtitle);
                            } %>
                        </div>
                    </div>

                    <% if (!isBlank && options != null && options.Rows.Count > 0) { %>
                    <div class="survey-options">
                        <%
                        string[] optionLabels = new string[] { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" };
                        int optionIndex = 0;
                        foreach (DataRow option in options.Rows) {
                            int mid = Convert.ToInt32(option["Mid"]);
                            string mitem = option["Mitem"].ToString();
                            string optLabel = optionIndex < optionLabels.Length ? optionLabels[optionIndex] : (optionIndex + 1).ToString();
                            optionIndex++;
                        %>
                        <label class="survey-option">
                            <input type="radio" name="q_<%= qid %>" value="<%= mid %>" required />
                            <span class="survey-option-prefix"><%= optLabel %></span>
                            <span class="survey-option-label"><%= mitem %></span>
                        </label>
                        <% } %>
                    </div>
                    <% } %>
                    </div>
                </div>
                <%
                    questionIndex++;
                }
                %>
            </div>

            <div class="survey-actions">
                <asp:Button ID="BtnSubmit" runat="server" Text="提交答卷" OnClick="BtnSubmit_Click" CssClass="survey-btn survey-btn-primary" />
            </div>
            <% } else { %>
            <div class="survey-empty">
                <div class="survey-empty-icon">📝</div>
                <div class="survey-empty-text">此调查问卷暂无题目</div>
                <div class="survey-empty-desc">请稍后再试，或返回课程页面查看其他学习任务。</div>
            </div>
            <% } %>
        </div>
    </div>
</asp:Content>
