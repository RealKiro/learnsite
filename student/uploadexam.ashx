<%@ WebHandler Language="C#" Class="uploadexam" %>

using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;

public class uploadexam : IHttpHandler
{
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
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

    public void ProcessRequest (HttpContext context) {
        LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
        if (cook.IsExist())
        {
            string selectstr = HttpContext.Current.Request.Form["selectstr"];
            string score = HttpContext.Current.Request.Form["score"];
            string lidstr = HttpContext.Current.Request.Form["lidstr"];
            string cidstr = HttpContext.Current.Request.Form["cidstr"];
            string vidstr = HttpContext.Current.Request.Form["vidstr"];
            string vtypestr = HttpContext.Current.Request.Form["vtypestr"];

            string Wtime = cook.LoginTime;
            DateTime Wdate = DateTime.Now;
            LearnSite.Model.SurveyFeedback fmodel = new LearnSite.Model.SurveyFeedback();
            fmodel.Fnum = cook.Snum;
            fmodel.Fyear = cook.Syear;
            fmodel.Fgrade = cook.Sgrade;
            fmodel.Fclass = cook.Sclass;
            fmodel.Fterm = cook.ThisTerm;
            fmodel.Fcid = Int32.Parse(cidstr);
            fmodel.Fvid = Int32.Parse(vidstr);
            fmodel.Fvtype = Int32.Parse(vtypestr);
            fmodel.Fselect = selectstr;
            fmodel.Fscore = Int32.Parse(score);
            fmodel.Fdate = DateTime.Now;
            fmodel.Fsid = cook.Sid;
            fmodel.Flid = Int32.Parse(lidstr);

            LearnSite.BLL.SurveyFeedback fbll = new LearnSite.BLL.SurveyFeedback();
            if (fbll.Add(fmodel) > 0)
            {
                //添加课堂活动记录
                LearnSite.Model.MenuWorks kmodel = new LearnSite.Model.MenuWorks();
                kmodel.Klid = Int32.Parse(lidstr);
                kmodel.Ksid = cook.Sid;
                kmodel.Ktime = LearnSite.Common.Computer.GoneMinute(DateTime.Parse(Wtime), Wdate);
                kmodel.Kcheck = false;
                LearnSite.BLL.MenuWorks kbll = new LearnSite.BLL.MenuWorks();
                kbll.Add(kmodel);

                // 试卷考试(vtype=2)：同步写入 ExamAnswer 表，确保教师阅卷页能看到提交记录
                try
                {
                    int vtype = Int32.Parse(vtypestr);
                    int vid = Int32.Parse(vidstr);
                    int sid = cook.Sid;
                    if (vtype == 2 && vid > 0 && sid > 0)
                    {
                        SyncExamAnswer(vid, sid, cook.Sgrade, cook.Sclass, selectstr);
                    }
                }
                catch { } // ExamAnswer 写入失败不影响主流程

                context.Response.Write("ok");
            }
            else
            {
                context.Response.Write("no");
            }
        }
    }

    /// <summary>将答案同步写入 ExamAnswer 表</summary>
    private void SyncExamAnswer(int pid, int sid, int sgrade, int sclass, string fselect)
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        using (SqlConnection conn = new SqlConnection(cs))
        {
            conn.Open();

            // 检查 ExamAnswer 表是否存在
            using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='ExamAnswer' AND xtype='U'", conn))
            { if (Convert.ToInt32(chk.ExecuteScalar()) == 0) return; }

            // 查找 ExamPublish 记录
            int eid = 0;
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 Eid FROM ExamPublish WHERE Epid=@pid AND Egrade=@g AND Eclass=@c AND Estatus=1 ORDER BY Eid DESC", conn))
            {
                cmd.Parameters.AddWithValue("@pid", pid);
                cmd.Parameters.AddWithValue("@g", sgrade);
                cmd.Parameters.AddWithValue("@c", sclass);
                object v = cmd.ExecuteScalar();
                if (v != null) int.TryParse(v.ToString(), out eid);
            }
            if (eid <= 0)
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 Eid FROM ExamPublish WHERE Epid=@pid ORDER BY Eid DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", pid);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out eid);
                }
            }
            if (eid <= 0) return;

            // 检查是否已有记录
            int existCount = 0;
            using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=@sid", conn))
            {
                chk.Parameters.AddWithValue("@eid", eid);
                chk.Parameters.AddWithValue("@sid", sid);
                existCount = Convert.ToInt32(chk.ExecuteScalar());
            }

            // 获取试卷题目
            DataTable dtQ = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Qid, Qtype, Qanswer FROM PaperQuestion WHERE Qpid=@pid ORDER BY Qsort, Qid", conn))
            {
                cmd.Parameters.AddWithValue("@pid", pid);
                using (SqlDataReader dr = cmd.ExecuteReader()) { dtQ.Load(dr); }
            }
            if (dtQ.Rows.Count == 0) return;

            // 解析答案并写入 ExamAnswer
            string[] parts = (fselect ?? "").Split(new char[] { ',' }, StringSplitOptions.None);
            int partIdx = 0;
            
            if (existCount > 0)
            {
                // 已有记录，更新（可能是 submitexamanswers.ashx 已经写入，这里更新确保数据一致）
                for (int i = 0; i < dtQ.Rows.Count; i++)
                {
                    int qid = Convert.ToInt32(dtQ.Rows[i]["Qid"]);
                    string qtype = dtQ.Rows[i]["Qtype"] != DBNull.Value ? dtQ.Rows[i]["Qtype"].ToString() : "";
                    string answer = "";

                    if (qtype == "scratch" || qtype == "python" || qtype == "pythonblock")
                    {
                        answer = "已提交";
                    }
                    else if (partIdx < parts.Length)
                    {
                        answer = parts[partIdx].Trim();
                        partIdx++;
                    }

                    // 检查该题是否已有记录
                    int qExists = 0;
                    using (SqlCommand chk2 = new SqlCommand("SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=@sid AND EAqid=@qid", conn))
                    {
                        chk2.Parameters.AddWithValue("@eid", eid);
                        chk2.Parameters.AddWithValue("@sid", sid);
                        chk2.Parameters.AddWithValue("@qid", qid);
                        qExists = Convert.ToInt32(chk2.ExecuteScalar());
                    }

                    if (qExists > 0)
                    {
                        // 更新现有记录
                        using (SqlCommand upd = new SqlCommand(
                            "UPDATE ExamAnswer SET EAanswer=@answer, EAdate=GETDATE() WHERE EAeid=@eid AND EAsid=@sid AND EAqid=@qid", conn))
                        {
                            upd.Parameters.AddWithValue("@answer", answer);
                            upd.Parameters.AddWithValue("@eid", eid);
                            upd.Parameters.AddWithValue("@sid", sid);
                            upd.Parameters.AddWithValue("@qid", qid);
                            upd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // 插入新记录
                        using (SqlCommand ins = new SqlCommand(
                            "INSERT INTO ExamAnswer(EAeid,EApid,EAsid,EAqid,EAanswer,EAscore,EAgraded,EAdate) VALUES(@eid,@pid,@sid,@qid,@answer,0,0,GETDATE())", conn))
                        {
                            ins.Parameters.AddWithValue("@eid", eid);
                            ins.Parameters.AddWithValue("@pid", pid);
                            ins.Parameters.AddWithValue("@sid", sid);
                            ins.Parameters.AddWithValue("@qid", qid);
                            ins.Parameters.AddWithValue("@answer", answer);
                            ins.ExecuteNonQuery();
                        }
                    }
                }
            }
            else
            {
                // 首次提交，批量插入
                for (int i = 0; i < dtQ.Rows.Count; i++)
                {
                    int qid = Convert.ToInt32(dtQ.Rows[i]["Qid"]);
                    string qtype = dtQ.Rows[i]["Qtype"] != DBNull.Value ? dtQ.Rows[i]["Qtype"].ToString() : "";
                    string answer = "";

                    if (qtype == "scratch" || qtype == "python" || qtype == "pythonblock")
                    {
                        answer = "已提交";
                    }
                    else if (partIdx < parts.Length)
                    {
                        answer = parts[partIdx].Trim();
                        partIdx++;
                    }

                    using (SqlCommand ins = new SqlCommand(
                        "INSERT INTO ExamAnswer(EAeid,EApid,EAsid,EAqid,EAanswer,EAscore,EAgraded,EAdate) VALUES(@eid,@pid,@sid,@qid,@answer,0,0,GETDATE())", conn))
                    {
                        ins.Parameters.AddWithValue("@eid", eid);
                        ins.Parameters.AddWithValue("@pid", pid);
                        ins.Parameters.AddWithValue("@sid", sid);
                        ins.Parameters.AddWithValue("@qid", qid);
                        ins.Parameters.AddWithValue("@answer", answer);
                        ins.ExecuteNonQuery();
                    }
                }
            }
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}
