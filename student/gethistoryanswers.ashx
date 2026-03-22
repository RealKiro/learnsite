<%@ WebHandler Language="C#" Class="student.gethistoryanswers" %>

using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Text;

namespace student
{
    public class gethistoryanswers : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Charset = "UTF-8";

            try
            {
                string vidParam = context.Request.QueryString["vid"];
                if (string.IsNullOrEmpty(vidParam))
                {
                    context.Response.Write("{\"error\":\"缺少参数vid\"}");
                    return;
                }
                int vid = 0;
                if (!int.TryParse(vidParam, out vid) || vid <= 0)
                {
                    context.Response.Write("{\"error\":\"无效的vid参数\"}");
                    return;
                }

                int sid = 0;
                LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
                if (cook.IsExist())
                {
                    string sidStr = "";
                    try
                    {
                        System.Reflection.PropertyInfo p = cook.GetType().GetProperty("Sid");
                        if (p != null)
                        {
                            object v = p.GetValue(cook, null);
                            if (v != null) sidStr = v.ToString();
                        }
                    }
                    catch { }
                    if (!string.IsNullOrEmpty(sidStr)) int.TryParse(sidStr, out sid);
                }

                if (sid <= 0)
                {
                    context.Response.Write("{\"error\":\"未登录或学生ID无效\"}");
                    return;
                }

                string cs = GetConnStr();
                if (string.IsNullOrEmpty(cs))
                {
                    context.Response.Write("{\"error\":\"数据库连接失败\"}");
                    return;
                }

                // 获取考试ID (eid)
                int eid = 0;
                int sgrade = 0, sclass = 0;
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // 获取学生年级班级
                    using (SqlCommand cmd = new SqlCommand("SELECT Sgrade, Sclass FROM Students WHERE Sid=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                sgrade = dr["Sgrade"] != DBNull.Value ? Convert.ToInt32(dr["Sgrade"]) : 0;
                                sclass = dr["Sclass"] != DBNull.Value ? Convert.ToInt32(dr["Sclass"]) : 0;
                            }
                            dr.Close();
                        }
                    }

                    if (sgrade <= 0 || sclass <= 0)
                    {
                        context.Response.Write("{\"error\":\"学生信息不完整\"}");
                        return;
                    }

                    // 查找对应的 ExamPublish 记录
                    using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 Eid FROM ExamPublish WHERE Epid=@pid AND Egrade=@grade AND Eclass=@class AND Estatus=1 ORDER BY Eid DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", vid);
                        cmd.Parameters.AddWithValue("@grade", sgrade);
                        cmd.Parameters.AddWithValue("@class", sclass);
                        object result = cmd.ExecuteScalar();
                        if (result != null) int.TryParse(result.ToString(), out eid);
                    }

                    if (eid <= 0)
                    {
                        context.Response.Write("{\"error\":\"未找到对应的考试发布记录\"}");
                        return;
                    }

                    // 获取历史答案
                    StringBuilder json = new StringBuilder();
                    json.Append("{\"success\":true,\"answers\":[");
                    bool first = true;

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT EAqid, EAanswer, EAscore, EAgraded FROM ExamAnswer WHERE EAeid=@eid AND EAsid=@sid ORDER BY EAqid", conn))
                    {
                        cmd.Parameters.AddWithValue("@eid", eid);
                        cmd.Parameters.AddWithValue("@sid", sid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                if (!first) json.Append(",");
                                first = false;

                                int qid = Convert.ToInt32(dr["EAqid"]);
                                string answer = dr["EAanswer"] != DBNull.Value ? dr["EAanswer"].ToString() : "";
                                int score = dr["EAscore"] != DBNull.Value ? Convert.ToInt32(dr["EAscore"]) : 0;
                                int graded = dr["EAgraded"] != DBNull.Value ? Convert.ToInt32(dr["EAgraded"]) : 0;

                                // 转义JSON
                                answer = answer.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r");

                                json.AppendFormat("{{\"qid\":{0},\"answer\":\"{1}\",\"score\":{2},\"graded\":{3}}}",
                                    qid, answer, score, graded);
                            }
                            dr.Close();
                        }
                    }

                    json.Append("]}");
                    context.Response.Write(json.ToString());
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"error\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
            }
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
            { try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
            if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
                cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
            return cs;
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}

