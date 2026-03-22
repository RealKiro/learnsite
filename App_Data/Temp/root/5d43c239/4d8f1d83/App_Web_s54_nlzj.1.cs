#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\exammonitorapi.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "AA56D1BF287AB97DAB2FF51FB50C8084"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\exammonitorapi.ashx"


using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Reflection;
using System.Configuration;
using System.Collections.Generic;

public class exammonitorapi : IHttpHandler
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
        { 
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } 
            catch { } 
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string eidStr = context.Request.QueryString["eid"];
            if (string.IsNullOrEmpty(eidStr))
            {
                context.Response.Write("{\"success\":false,\"message\":\"参数缺失\"}");
                return;
            }

            int eid = 0;
            if (!int.TryParse(eidStr, out eid) || eid <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"参数无效\"}");
                return;
            }

            string cs = GetConnStr();
            if (string.IsNullOrEmpty(cs))
            {
                context.Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
                return;
            }

            SqlConnection conn = null;
            try
            {
                conn = new SqlConnection(cs);
                conn.Open();

                // 获取考试信息
                int pid = 0;
                int grade = 0;
                int classNum = 0;
                
                SqlCommand cmd1 = new SqlCommand("SELECT Epid, Egrade, Eclass FROM ExamPublish WHERE Eid=@eid", conn);
                cmd1.Parameters.AddWithValue("@eid", eid);
                SqlDataReader dr1 = cmd1.ExecuteReader();
                if (dr1.Read())
                {
                    if (dr1["Epid"] != DBNull.Value) pid = Convert.ToInt32(dr1["Epid"]);
                    if (dr1["Egrade"] != DBNull.Value) grade = Convert.ToInt32(dr1["Egrade"]);
                    if (dr1["Eclass"] != DBNull.Value) classNum = Convert.ToInt32(dr1["Eclass"]);
                }
                dr1.Close();
                cmd1.Dispose();

                if (pid == 0)
                {
                    context.Response.Write("{\"success\":false,\"message\":\"考试不存在\"}");
                    conn.Close();
                    return;
                }

                // 获取已提交学生
                List<StudentInfo> submitted = new List<StudentInfo>();
                
                // 检查ExamAnswer表
                SqlCommand chk1 = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='ExamAnswer' AND xtype='U'", conn);
                bool hasExamAnswer = Convert.ToInt32(chk1.ExecuteScalar()) > 0;
                chk1.Dispose();

                if (hasExamAnswer)
                {
                    string sql = "SELECT DISTINCT s.Snum, s.Sname, " +
                                "(SELECT TOP 1 EAdate FROM ExamAnswer WHERE EAeid=@eid AND EAsid=s.Sid ORDER BY EAdate DESC) AS SubmitTime " +
                                "FROM Students s INNER JOIN ExamAnswer ea ON s.Sid = ea.EAsid " +
                                "WHERE ea.EAeid = @eid ORDER BY SubmitTime DESC";
                    
                    SqlCommand cmd2 = new SqlCommand(sql, conn);
                    cmd2.Parameters.AddWithValue("@eid", eid);
                    SqlDataReader dr2 = cmd2.ExecuteReader();
                    while (dr2.Read())
                    {
                        StudentInfo si = new StudentInfo();
                        si.Snum = dr2["Snum"] != DBNull.Value ? dr2["Snum"].ToString() : "";
                        si.Sname = dr2["Sname"] != DBNull.Value ? dr2["Sname"].ToString() : "";
                        if (dr2["SubmitTime"] != DBNull.Value)
                        {
                            si.SubmitTime = Convert.ToDateTime(dr2["SubmitTime"]).ToString("MM-dd HH:mm");
                        }
                        submitted.Add(si);
                    }
                    dr2.Close();
                    cmd2.Dispose();
                }
                
                // 如果没有数据，尝试SurveyFeedback
                if (submitted.Count == 0)
                {
                    SqlCommand chk2 = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='SurveyFeedback' AND xtype='U'", conn);
                    bool hasSurveyFeedback = Convert.ToInt32(chk2.ExecuteScalar()) > 0;
                    chk2.Dispose();

                    if (hasSurveyFeedback)
                    {
                        string sql = "SELECT DISTINCT s.Snum, s.Sname, " +
                                    "(SELECT TOP 1 Fdate FROM SurveyFeedback WHERE Fvid=@pid AND Fsid=s.Sid ORDER BY Fdate DESC) AS SubmitTime " +
                                    "FROM Students s INNER JOIN SurveyFeedback sf ON s.Sid = sf.Fsid " +
                                    "WHERE sf.Fvid = @pid AND sf.Fvtype = 2 ORDER BY SubmitTime DESC";
                        
                        SqlCommand cmd3 = new SqlCommand(sql, conn);
                        cmd3.Parameters.AddWithValue("@pid", pid);
                        SqlDataReader dr3 = cmd3.ExecuteReader();
                        while (dr3.Read())
                        {
                            StudentInfo si = new StudentInfo();
                            si.Snum = dr3["Snum"] != DBNull.Value ? dr3["Snum"].ToString() : "";
                            si.Sname = dr3["Sname"] != DBNull.Value ? dr3["Sname"].ToString() : "";
                            if (dr3["SubmitTime"] != DBNull.Value)
                            {
                                si.SubmitTime = Convert.ToDateTime(dr3["SubmitTime"]).ToString("MM-dd HH:mm");
                            }
                            submitted.Add(si);
                        }
                        dr3.Close();
                        cmd3.Dispose();
                    }
                }

                // 获取班级所有学生
                List<StudentInfo> allStudents = new List<StudentInfo>();
                string allSql = "SELECT Sid, Snum, Sname FROM Students WHERE Sgrade=@grade AND Sclass=@class ORDER BY Snum";
                
                SqlCommand cmd4 = new SqlCommand(allSql, conn);
                cmd4.Parameters.AddWithValue("@grade", grade);
                cmd4.Parameters.AddWithValue("@class", classNum);
                SqlDataReader dr4 = cmd4.ExecuteReader();
                while (dr4.Read())
                {
                    StudentInfo si = new StudentInfo();
                    if (dr4["Sid"] != DBNull.Value) si.Sid = Convert.ToInt32(dr4["Sid"]);
                    si.Snum = dr4["Snum"] != DBNull.Value ? dr4["Snum"].ToString() : "";
                    si.Sname = dr4["Sname"] != DBNull.Value ? dr4["Sname"].ToString() : "";
                    allStudents.Add(si);
                }
                dr4.Close();
                cmd4.Dispose();

                // 计算未提交学生
                Dictionary<string, bool> submittedMap = new Dictionary<string, bool>();
                for (int i = 0; i < submitted.Count; i++)
                {
                    if (!submittedMap.ContainsKey(submitted[i].Snum))
                    {
                        submittedMap.Add(submitted[i].Snum, true);
                    }
                }

                List<StudentInfo> unsubmitted = new List<StudentInfo>();
                for (int j = 0; j < allStudents.Count; j++)
                {
                    if (!submittedMap.ContainsKey(allStudents[j].Snum))
                    {
                        unsubmitted.Add(allStudents[j]);
                    }
                }

                // 构建JSON
                StringBuilder json = new StringBuilder();
                json.Append("{\"success\":true,");
                json.Append("\"totalCount\":").Append(allStudents.Count).Append(",");
                json.Append("\"submittedCount\":").Append(submitted.Count).Append(",");
                json.Append("\"unsubmittedCount\":").Append(unsubmitted.Count).Append(",");
                
                json.Append("\"submitted\":[");
                for (int k = 0; k < submitted.Count; k++)
                {
                    if (k > 0) json.Append(",");
                    json.Append("{");
                    json.Append("\"snum\":\"").Append(JsonEscape(submitted[k].Snum)).Append("\",");
                    json.Append("\"sname\":\"").Append(JsonEscape(submitted[k].Sname)).Append("\",");
                    json.Append("\"submitTime\":\"").Append(JsonEscape(submitted[k].SubmitTime)).Append("\"");
                    json.Append("}");
                }
                json.Append("],");
                
                json.Append("\"unsubmitted\":[");
                for (int m = 0; m < unsubmitted.Count; m++)
                {
                    if (m > 0) json.Append(",");
                    json.Append("{");
                    json.Append("\"snum\":\"").Append(JsonEscape(unsubmitted[m].Snum)).Append("\",");
                    json.Append("\"sname\":\"").Append(JsonEscape(unsubmitted[m].Sname)).Append("\"");
                    json.Append("}");
                }
                json.Append("]}");

                context.Response.Write(json.ToString());
                
                conn.Close();
            }
            catch (Exception ex)
            {
                if (conn != null && conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
                context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }

    private string JsonEscape(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";
        return str.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n").Replace("\t", "\\t");
    }

    public bool IsReusable 
    { 
        get { return false; } 
    }
}

public class StudentInfo
{
    public int Sid;
    public string Snum;
    public string Sname;
    public string SubmitTime;
    
    public StudentInfo()
    {
        Sid = 0;
        Snum = "";
        Sname = "";
        SubmitTime = "";
    }
}


#line default
#line hidden
