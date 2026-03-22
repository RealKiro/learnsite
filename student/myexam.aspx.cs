using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Reflection;

public partial class student_myexam : System.Web.UI.Page
{
    protected string questionList = "";
    protected string isClose = "false";
    protected string Lidstr = "0";
    protected string Cidstr = "0";
    protected string Vidstr = "0";
    protected string Vtypestr = "0";
    protected string isDone = "false";
    protected string snumStr = "";

    protected string paperTitle = "";
    protected int paperTime = 0;
    protected int paperCount = 0;
    protected int paperScore = 0;
    protected string examStart = "";
    protected string examEnd = "";
    protected string examSource = "";

    private Label _lbtitle, _lbsname, _lbsnum, _lbfscore, _lbtypecn, _lbtype, _lbcheck;
    private Label _labelCid, _labelLid, _labelVid, _labelVtotal;
    private HyperLink _hkscore;
    private System.Web.UI.HtmlControls.HtmlGenericControl _vcontent;

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (!string.IsNullOrEmpty(cs) && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private Control FindCtrl(Control root, string id)
    {
        if (root == null) return null;
        if (root.ID == id) return root;
        foreach (Control c in root.Controls) { Control f = FindCtrl(c, id); if (f != null) return f; }
        return null;
    }

    private void InitControls()
    {
        _lbtitle = FindCtrl(this, "Lbtitle") as Label;
        _lbsname = FindCtrl(this, "Lbsname") as Label;
        _lbsnum = FindCtrl(this, "Lbsnum") as Label;
        _lbfscore = FindCtrl(this, "Lbfscore") as Label;
        _lbtypecn = FindCtrl(this, "Lbtypecn") as Label;
        _lbtype = FindCtrl(this, "Lbtype") as Label;
        _lbcheck = FindCtrl(this, "Lbcheck") as Label;
        _labelCid = FindCtrl(this, "LabelCid") as Label;
        _labelLid = FindCtrl(this, "LabelLid") as Label;
        _labelVid = FindCtrl(this, "LabelVid") as Label;
        _labelVtotal = FindCtrl(this, "LabelVtotal") as Label;
        _hkscore = FindCtrl(this, "Hkscore") as HyperLink;
        _vcontent = FindCtrl(this, "vcontent") as System.Web.UI.HtmlControls.HtmlGenericControl;
    }

    private string CookProp(object m, string n)
    {
        if (m == null) return "";
        PropertyInfo p = m.GetType().GetProperty(n);
        if (p == null) return "";
        object v = p.GetValue(m, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, Encoding.UTF8); } catch { } }
        return s;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        try { InitControls(); if (!IsPostBack) LoadExamData(); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("myexam Error: " + ex); }
    }

    private void LoadExamData()
    {
        string vidParam = Request.QueryString["vid"];
        if (string.IsNullOrEmpty(vidParam)) return;
        int vid; if (!int.TryParse(vidParam, out vid)) return;
        Vidstr = vid.ToString();
        if (_labelVid != null) _labelVid.Text = Vidstr;

        string sname = "", snum = ""; int sid = 0;
        try
        {
            LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
            if (cook.IsExist())
            {
                sname = CookProp(cook, "Sname"); snum = CookProp(cook, "Snum");
                string s = CookProp(cook, "Sid"); if (!string.IsNullOrEmpty(s)) int.TryParse(s, out sid);
            }
        }
        catch { }
        if (_lbsname != null) _lbsname.Text = sname;
        if (_lbsnum != null) _lbsnum.Text = snum;
        snumStr = snum;

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        SqlConnection conn = null;
        try
        {
            conn = new SqlConnection(cs); conn.Open();
            if (TryPaper(conn, vid, sid)) { examSource = "paper"; return; }
            if (TrySurvey(conn, vid, sid)) { examSource = "survey"; return; }
        }
        catch { }
        finally { if (conn != null && conn.State == ConnectionState.Open) conn.Close(); }
    }

    private bool TableExists(SqlConnection conn, string name)
    {
        using (SqlCommand c = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name=@n AND xtype='U'", conn))
        { c.Parameters.AddWithValue("@n", name); return Convert.ToInt32(c.ExecuteScalar()) > 0; }
    }

    private bool TryPaper(SqlConnection conn, int vid, int sid)
    {
        if (!TableExists(conn, "Paper")) return false;

        string ptitle = "", pdesc = ""; int ptime = 60, pscore = 100, pcount = 0;
        using (SqlCommand cmd = new SqlCommand("SELECT Pid,Ptitle,Pdesc,Ptime,Pscore,Pcount FROM Paper WHERE Pid=@p", conn))
        {
            cmd.Parameters.AddWithValue("@p", vid);
            using (SqlDataReader r = cmd.ExecuteReader())
            { if (!r.Read()) { r.Close(); return false; }
              ptitle = r["Ptitle"] != DBNull.Value ? r["Ptitle"].ToString() : "";
              pdesc = r["Pdesc"] != DBNull.Value ? r["Pdesc"].ToString() : "";
              ptime = r["Ptime"] != DBNull.Value ? Convert.ToInt32(r["Ptime"]) : 60;
              pscore = r["Pscore"] != DBNull.Value ? Convert.ToInt32(r["Pscore"]) : 100;
              pcount = r["Pcount"] != DBNull.Value ? Convert.ToInt32(r["Pcount"]) : 0;
              r.Close(); }
        }

        paperTitle = ptitle; paperTime = ptime; paperScore = pscore; paperCount = pcount;
        if (_lbtitle != null) _lbtitle.Text = ptitle;
        if (_lbtypecn != null) _lbtypecn.Text = "考试";
        if (_lbtype != null) _lbtype.Text = "2";
        Vtypestr = "2";
        if (_vcontent != null && !string.IsNullOrEmpty(pdesc)) _vcontent.InnerHtml = pdesc;

        // ExamPublish 时间
        try
        {
            if (TableExists(conn, "ExamPublish"))
            {
                using (SqlCommand ce = new SqlCommand("SELECT TOP 1 Estart,Eend FROM ExamPublish WHERE Epid=@p AND Estatus=1 ORDER BY Estart DESC", conn))
                { ce.Parameters.AddWithValue("@p", vid);
                  using (SqlDataReader re = ce.ExecuteReader())
                  { if (re.Read())
                    { if (re["Estart"] != DBNull.Value) { DateTime st = Convert.ToDateTime(re["Estart"]); examStart = st.ToString("yyyy-MM-dd HH:mm"); if (DateTime.Now < st) isClose = "true"; }
                      if (re["Eend"] != DBNull.Value) { DateTime en = Convert.ToDateTime(re["Eend"]); examEnd = en.ToString("yyyy-MM-dd HH:mm"); if (DateTime.Now > en) isClose = "true"; }
                    } re.Close(); } }
            }
        }
        catch { }

        // 已提交检查
        CheckDone(conn, vid, sid);

        // PaperQuestion
        if (!TableExists(conn, "PaperQuestion")) return true;

        DataTable dtQ = new DataTable();
        using (SqlCommand cq = new SqlCommand("SELECT Qid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort FROM PaperQuestion WHERE Qpid=@p ORDER BY Qsort,Qid", conn))
        { cq.Parameters.AddWithValue("@p", vid); using (SqlDataReader rq = cq.ExecuteReader()) { dtQ.Load(rq); } }

        if (dtQ.Rows.Count == 0) return true;
        paperCount = dtQ.Rows.Count;

        StringBuilder jb = new StringBuilder(); jb.Append("[");
        for (int i = 0; i < dtQ.Rows.Count; i++)
        {
            DataRow row = dtQ.Rows[i];
            int qid = Convert.ToInt32(row["Qid"]);
            string qtype = row["Qtype"] != DBNull.Value ? row["Qtype"].ToString() : "单选";
            qtype = NormalizeQtype(qtype);
            string qcontent = row["Qcontent"] != DBNull.Value ? row["Qcontent"].ToString() : "";
            string optA = row["Qoption_a"] != DBNull.Value ? row["Qoption_a"].ToString() : "";
            string optB = row["Qoption_b"] != DBNull.Value ? row["Qoption_b"].ToString() : "";
            string optC = row["Qoption_c"] != DBNull.Value ? row["Qoption_c"].ToString() : "";
            string optD = row["Qoption_d"] != DBNull.Value ? row["Qoption_d"].ToString() : "";
            string answer = row["Qanswer"] != DBNull.Value ? row["Qanswer"].ToString() : "";
            int qscore = row["Qscore"] != DBNull.Value ? Convert.ToInt32(row["Qscore"]) : 5;
            bool isBlank = (qtype == "填空");
            string template = "";

            // 判断题：自动补全选项 + 规范化答案
            if (qtype == "判断")
            {
                if (string.IsNullOrEmpty(optA)) optA = "正确";
                if (string.IsNullOrEmpty(optB)) optB = "错误";
                if (!string.IsNullOrEmpty(answer))
                {
                    string al = answer.Trim();
                    if (al == "对" || al == "正确" || al == "√" || al.ToLower() == "true" || al.ToLower() == "t" || al == "1")
                        answer = "A";
                    else if (al == "错" || al == "错误" || al == "×" || al.ToLower() == "false" || al.ToLower() == "f" || al == "0")
                        answer = "B";
                }
            }

            StringBuilder ib = new StringBuilder(); ib.Append("[");
            if (qtype == "问答" || qtype == "scratch" || qtype == "python" || qtype == "pythonblock")
            {
                // 问答题和编程题：Qitem 为空数组，编程题模板路径存 Qoption_a
                if (qtype != "问答") template = optA;
            }
            else if (isBlank)
            {
                ib.AppendFormat("{{\"Mid\":{0},\"Mitem\":\"{1}\",\"Mscore\":{2}}}", qid, JE(answer), qscore);
            }
            else
            {
                // 单选、多选、判断
                string[] opts = { optA, optB, optC, optD };
                string[] labels = { "A", "B", "C", "D" };
                int idx = 0;
                for (int j = 0; j < 4; j++)
                {
                    if (string.IsNullOrEmpty(opts[j])) continue;
                    if (idx > 0) ib.Append(",");
                    int mid = qid * 10 + j + 1;
                    int sc = (!string.IsNullOrEmpty(answer) && answer.ToUpper().Contains(labels[j])) ? qscore : 0;
                    ib.AppendFormat("{{\"Mid\":{0},\"Mitem\":\"{1}\",\"Mscore\":{2}}}", mid, JE(labels[j] + ". " + opts[j]), sc);
                    idx++;
                }
            }
            ib.Append("]");

            if (i > 0) jb.Append(",");
            jb.AppendFormat("{{\"Qid\":{0},\"Qtitle\":\"{1}\",\"Qblack\":{2},\"Qtype\":\"{3}\",\"Qscore\":{4},\"Qitem\":\"{5}\",\"Qtemplate\":\"{6}\"}}",
                qid, JE(qcontent), isBlank ? "true" : "false", JE(qtype), qscore, JE(ib.ToString()), JE(template));
        }
        jb.Append("]");
        questionList = Convert.ToBase64String(Encoding.UTF8.GetBytes(jb.ToString()));

        LoadListMenu(conn, vid);
        return true;
    }

    private bool TrySurvey(SqlConnection conn, int vid, int sid)
    {
        string vtitle = "", vcontent = ""; int vtype = 0, vtotal = 0, vcid = 0; bool vclose = false;
        using (SqlCommand cmd = new SqlCommand("SELECT Vid,Vcid,Vtitle,Vcontent,Vtype,Vtotal,Vclose FROM Survey WHERE Vid=@v", conn))
        {
            cmd.Parameters.AddWithValue("@v", vid);
            using (SqlDataReader r = cmd.ExecuteReader())
            { if (!r.Read()) { r.Close(); return false; }
              vtitle = r["Vtitle"] != DBNull.Value ? r["Vtitle"].ToString() : "";
              vcontent = r["Vcontent"] != DBNull.Value ? r["Vcontent"].ToString() : "";
              vtype = r["Vtype"] != DBNull.Value ? Convert.ToInt32(r["Vtype"]) : 0;
              vtotal = r["Vtotal"] != DBNull.Value ? Convert.ToInt32(r["Vtotal"]) : 0;
              vclose = r["Vclose"] != DBNull.Value && Convert.ToBoolean(r["Vclose"]);
              vcid = r["Vcid"] != DBNull.Value ? Convert.ToInt32(r["Vcid"]) : 0;
              r.Close(); }
        }

        paperTitle = vtitle; isClose = vclose ? "true" : "false"; Vtypestr = vtype.ToString(); Cidstr = vcid.ToString();
        if (_lbtitle != null) _lbtitle.Text = vtitle;
        if (_lbtypecn != null) { switch (vtype) { case 0: _lbtypecn.Text = "调查"; break; case 1: _lbtypecn.Text = "测验"; break; default: _lbtypecn.Text = "考试"; break; } }
        if (_lbtype != null) _lbtype.Text = vtype.ToString();
        if (_labelCid != null) _labelCid.Text = vcid.ToString();
        if (_labelVtotal != null) _labelVtotal.Text = vtotal.ToString();
        if (_vcontent != null && !string.IsNullOrEmpty(vcontent)) _vcontent.InnerHtml = vcontent;

        LoadListMenu(conn, vid);
        CheckDone(conn, vid, sid);

        DataTable dtQ = new DataTable();
        using (SqlCommand cq = new SqlCommand("SELECT Qid,Qtitle,Qblack FROM SurveyQuestion WHERE Qvid=@v ORDER BY Qid", conn))
        { cq.Parameters.AddWithValue("@v", vid); using (SqlDataReader rq = cq.ExecuteReader()) { dtQ.Load(rq); } }

        if (dtQ.Rows.Count == 0) return true;
        paperCount = dtQ.Rows.Count;

        StringBuilder jb = new StringBuilder(); jb.Append("[");
        for (int i = 0; i < dtQ.Rows.Count; i++)
        {
            DataRow qr = dtQ.Rows[i];
            int qid = Convert.ToInt32(qr["Qid"]);
            string qt = qr["Qtitle"] != DBNull.Value ? qr["Qtitle"].ToString() : "";
            bool qb = qr["Qblack"] != DBNull.Value && Convert.ToBoolean(qr["Qblack"]);

            DataTable dtI = new DataTable();
            using (SqlCommand ci = new SqlCommand("SELECT Mid,Mitem,Mscore FROM SurveyItem WHERE Mqid=@m ORDER BY Mid", conn))
            { ci.Parameters.AddWithValue("@m", qid); using (SqlDataReader ri = ci.ExecuteReader()) { dtI.Load(ri); } }

            StringBuilder ib = new StringBuilder(); ib.Append("[");
            for (int j = 0; j < dtI.Rows.Count; j++)
            {
                DataRow mr = dtI.Rows[j];
                if (j > 0) ib.Append(",");
                ib.AppendFormat("{{\"Mid\":{0},\"Mitem\":\"{1}\",\"Mscore\":{2}}}",
                    Convert.ToInt32(mr["Mid"]), JE(mr["Mitem"] != DBNull.Value ? mr["Mitem"].ToString() : ""),
                    mr["Mscore"] != DBNull.Value ? Convert.ToInt32(mr["Mscore"]) : 0);
            }
            ib.Append("]");

            if (i > 0) jb.Append(",");
            jb.AppendFormat("{{\"Qid\":{0},\"Qtitle\":\"{1}\",\"Qblack\":{2},\"Qitem\":\"{3}\"}}", qid, JE(qt), qb ? "true" : "false", JE(ib.ToString()));
        }
        jb.Append("]");
        questionList = Convert.ToBase64String(Encoding.UTF8.GetBytes(jb.ToString()));
        return true;
    }

    private void LoadListMenu(SqlConnection conn, int vid)
    {
        try
        {
            using (SqlCommand c = new SqlCommand("SELECT TOP 1 Lid,Lcid FROM ListMenu WHERE Lxid=@x ORDER BY Lid DESC", conn))
            { c.Parameters.AddWithValue("@x", vid);
              using (SqlDataReader r = c.ExecuteReader())
              { if (r.Read()) { Lidstr = (r["Lid"] != DBNull.Value ? Convert.ToInt32(r["Lid"]) : 0).ToString();
                  if (Cidstr == "0") Cidstr = (r["Lcid"] != DBNull.Value ? Convert.ToInt32(r["Lcid"]) : 0).ToString();
                  if (_labelLid != null) _labelLid.Text = Lidstr;
                  if (_labelCid != null) _labelCid.Text = Cidstr; }
                r.Close(); } }
        }
        catch { }
    }

    private void CheckDone(SqlConnection conn, int vid, int sid)
    {
        if (sid <= 0) return;
        try
        {
            using (SqlCommand c = new SqlCommand("SELECT TOP 1 Fid,Fscore FROM SurveyFeedback WHERE Fvid=@v AND Fsid=@s ORDER BY Fid DESC", conn))
            { c.Parameters.AddWithValue("@v", vid); c.Parameters.AddWithValue("@s", sid);
              using (SqlDataReader r = c.ExecuteReader())
              { if (r.Read()) { isDone = "true"; int fs = r["Fscore"] != DBNull.Value ? Convert.ToInt32(r["Fscore"]) : 0;
                  if (_lbfscore != null) _lbfscore.Text = fs.ToString();
                  if (_lbcheck != null) _lbcheck.Text = " ✓ 已提交"; }
                r.Close(); } }
        }
        catch { }
    }

    /// <summary>将英文题型名规范化为中文（前端JS使用中文类型名）</summary>
    private string NormalizeQtype(string t)
    {
        if (string.IsNullOrEmpty(t)) return "单选";
        switch (t)
        {
            case "single": return "单选";
            case "multiple": return "多选";
            case "truefalse": return "判断";
            case "fill": return "填空";
            case "essay": return "问答";
            default: return t; // scratch/python/pythonblock 保持英文
        }
    }

    private string JE(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        StringBuilder sb = new StringBuilder();
        foreach (char c in s)
        { switch (c) { case '\\': sb.Append("\\\\"); break; case '"': sb.Append("\\\""); break;
            case '\n': sb.Append("\\n"); break; case '\r': sb.Append("\\r"); break; case '\t': sb.Append("\\t"); break;
            default: sb.Append(c); break; } }
        return sb.ToString();
    }
}
