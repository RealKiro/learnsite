#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\getsubmittedstudents.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "D1AAF2BF26EBB1C08DFFDCF50C151F9E"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\getsubmittedstudents.ashx"


using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Reflection;
using System.Configuration;

public class getsubmittedstudents : IHttpHandler
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
        { try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";

        string vidStr = context.Request.QueryString["vid"];
        if (string.IsNullOrEmpty(vidStr))
        {
            context.Response.Write("{\"success\":false,\"message\":\"参数缺失\"}");
            return;
        }

        int vid = 0;
        if (!int.TryParse(vidStr, out vid) || vid <= 0)
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

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 检查 SurveyFeedback 表是否存在
                bool feedbackTableExists = false;
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='SurveyFeedback' AND xtype='U'", conn))
                {
                    feedbackTableExists = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                }

                if (!feedbackTableExists)
                {
                    context.Response.Write("{\"success\":true,\"submitted\":[],\"unsubmitted\":[]}");
                    return;
                }

                // 查询已提交和未提交的学生信息
                StringBuilder json = new StringBuilder();
                json.Append("{\"success\":true,\"submitted\":[");

                // 已提交学生
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT DISTINCT sf.Fnum, sf.Fdate 
                      FROM SurveyFeedback sf 
                      WHERE sf.Fvid=@vid 
                      ORDER BY sf.Fdate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@vid", vid);
                    
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        bool first = true;
                        while (reader.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;

                            string snum = reader["Fnum"] != DBNull.Value ? reader["Fnum"].ToString() : "";
                            DateTime fdate = reader["Fdate"] != DBNull.Value ? Convert.ToDateTime(reader["Fdate"]) : DateTime.Now;
                            string fdateStr = fdate.ToString("MM-dd HH:mm");

                            json.Append("{");
                            json.AppendFormat("\"snum\":\"{0}\",", JsonEscape(snum));
                            json.AppendFormat("\"time\":\"{0}\"", JsonEscape(fdateStr));
                            json.Append("}");
                        }
                    }
                }

                json.Append("],\"unsubmitted\":[");

                // 未提交学生：尝试多个可能的表名和字段名
                string unsubmittedQuery = "";
                bool studentsTableExists = false;
                bool studentTableExists = false;
                
                // 检查 Students 表
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='Students' AND xtype='U'", conn))
                {
                    studentsTableExists = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                }
                
                // 检查 Student 表
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='Student' AND xtype='U'", conn))
                {
                    studentTableExists = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                }

                if (studentsTableExists)
                {
                    unsubmittedQuery = @"SELECT s.Snum, s.Sname 
                                        FROM Students s 
                                        WHERE s.Snum NOT IN (
                                            SELECT DISTINCT sf.Fnum 
                                            FROM SurveyFeedback sf 
                                            WHERE sf.Fvid=@vid
                                        )
                                        ORDER BY s.Snum";
                }
                else if (studentTableExists)
                {
                    unsubmittedQuery = @"SELECT s.Snum, s.Sname 
                                        FROM Student s 
                                        WHERE s.Snum NOT IN (
                                            SELECT DISTINCT sf.Fnum 
                                            FROM SurveyFeedback sf 
                                            WHERE sf.Fvid=@vid
                                        )
                                        ORDER BY s.Snum";
                }

                if (!string.IsNullOrEmpty(unsubmittedQuery))
                {
                    using (SqlCommand cmd2 = new SqlCommand(unsubmittedQuery, conn))
                    {
                        cmd2.Parameters.AddWithValue("@vid", vid);
                        
                        using (SqlDataReader reader2 = cmd2.ExecuteReader())
                        {
                            bool first2 = true;
                            while (reader2.Read())
                            {
                                if (!first2) json.Append(",");
                                first2 = false;

                                string snum = reader2["Snum"] != DBNull.Value ? reader2["Snum"].ToString() : "";
                                string sname = reader2["Sname"] != DBNull.Value ? reader2["Sname"].ToString() : "";

                                json.Append("{");
                                json.AppendFormat("\"snum\":\"{0}\",", JsonEscape(snum));
                                json.AppendFormat("\"sname\":\"{0}\"", JsonEscape(sname));
                                json.Append("}");
                            }
                        }
                    }
                }

                json.Append("]}");
                context.Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }

    private string JsonEscape(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        StringBuilder sb = new StringBuilder();
        foreach (char c in s)
        {
            switch (c)
            {
                case '\\': sb.Append("\\\\"); break;
                case '"': sb.Append("\\\""); break;
                case '\n': sb.Append("\\n"); break;
                case '\r': sb.Append("\\r"); break;
                case '\t': sb.Append("\\t"); break;
                default: sb.Append(c); break;
            }
        }
        return sb.ToString();
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
