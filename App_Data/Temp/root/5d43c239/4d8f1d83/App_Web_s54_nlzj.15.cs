#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\getexamwork.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "4327D5320F0405921CBE935144512853"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\getexamwork.ashx"


using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Text;

/// <summary>
/// 教师端API：查询学生编程作品信息
/// 参数：sid=学生ID, qid=题目ID（PaperQuestion Qid）
/// 返回JSON：{wid, wtype, wcode, wthumbnail, wdate, wpass}
/// </summary>
public class getexamwork : IHttpHandler
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

    private bool IsTeacher(HttpContext context)
    {
        try
        {
            HttpCookie tc = context.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value)) return true;
        }
        catch { }
        return false;
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
                case '\b': sb.Append("\\b"); break;
                case '\f': sb.Append("\\f"); break;
                default: sb.Append(c); break;
            }
        }
        return sb.ToString();
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Charset = "utf-8";

        if (!IsTeacher(context))
        {
            context.Response.Write("{\"error\":\"未授权\"}");
            return;
        }

        string sidStr = context.Request.QueryString["sid"];
        string qidStr = context.Request.QueryString["qid"];
        int sid = 0, qid = 0;
        if (!string.IsNullOrEmpty(sidStr)) int.TryParse(sidStr, out sid);
        if (!string.IsNullOrEmpty(qidStr)) int.TryParse(qidStr, out qid);

        if (sid <= 0 || qid <= 0)
        {
            context.Response.Write("{\"error\":\"参数无效\"}");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("{\"error\":\"数据库连接失败\"}");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 获取学生信息
                string sname = "", snum = "";
                int sgrade = 0, sclass = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT Sname, Snum, Sgrade, Sclass FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sid);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            sname = dr["Sname"] != DBNull.Value ? dr["Sname"].ToString() : "";
                            snum = dr["Snum"] != DBNull.Value ? dr["Snum"].ToString() : "";
                            sgrade = dr["Sgrade"] != DBNull.Value ? Convert.ToInt32(dr["Sgrade"]) : 0;
                            sclass = dr["Sclass"] != DBNull.Value ? Convert.ToInt32(dr["Sclass"]) : 0;
                        }
                        dr.Close();
                    }
                }

                // 多种方式查找作品：
                // 1. 通过 Wsid + Wmid（任务ID）精确匹配
                // 2. 通过 Wsid + Wlid（课程ID）精确匹配
                // 3. 通过 Wsid + 题目类型 + Wmid范围匹配（±5）
                // 4. 通过 Wsid + 题目类型 + 最近24小时
                // 5. 通过 Wsid + 题目类型 + 最新作品
                
                // 首先获取题目类型
                string qtype = "";
                using (SqlCommand cmd = new SqlCommand("SELECT Qtype FROM PaperQuestion WHERE Qid=@qid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", qid);
                    object result = cmd.ExecuteScalar();
                    if (result != null) qtype = result.ToString().ToLower();
                }
                
                // 确定作品类型（包括别名）
                string wtype = "";
                string[] wtypes = new string[0];
                if (qtype.Contains("scratch")) 
                {
                    wtype = "scratch";
                    wtypes = new string[] { "scratch", "sb3", "sb2" }; // Scratch的多种格式
                }
                else if (qtype.Contains("python")) 
                {
                    wtype = "python";
                    wtypes = new string[] { "python", "py" }; // Python的多种格式
                }
                
                string sql = @"SELECT TOP 1 Wid, Wtype, Wcode, Wthumbnail, Wdate, Wpass 
                    FROM Works WHERE Wsid=@sid AND Wmid=@qid ORDER BY Wdate DESC, Wid DESC";
                
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                {
                    da.SelectCommand.Parameters.AddWithValue("@sid", sid);
                    da.SelectCommand.Parameters.AddWithValue("@qid", qid);
                    da.Fill(dt);
                }

                // 如果 Wmid 没找到，尝试用 Wlid
                if (dt.Rows.Count == 0)
                {
                    sql = @"SELECT TOP 1 Wid, Wtype, Wcode, Wthumbnail, Wdate, Wpass 
                        FROM Works WHERE Wsid=@sid AND Wlid=@qid ORDER BY Wdate DESC, Wid DESC";
                    dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                    {
                        da.SelectCommand.Parameters.AddWithValue("@sid", sid);
                        da.SelectCommand.Parameters.AddWithValue("@qid", qid);
                        da.Fill(dt);
                    }
                }
                
                // 如果还是没找到，尝试范围匹配（Wmid在qid±10范围内，且类型匹配）
                if (dt.Rows.Count == 0 && wtypes.Length > 0)
                {
                    // 构建类型匹配条件
                    string typeCondition = "Wtype IN (";
                    for (int i = 0; i < wtypes.Length; i++)
                    {
                        if (i > 0) typeCondition += ",";
                        typeCondition += "@wtype" + i;
                    }
                    typeCondition += ")";
                    
                    sql = @"SELECT TOP 1 Wid, Wtype, Wcode, Wthumbnail, Wdate, Wpass 
                        FROM Works WHERE Wsid=@sid AND " + typeCondition + @"
                        AND Wmid BETWEEN @qidMin AND @qidMax
                        ORDER BY ABS(Wmid - @qid), Wdate DESC, Wid DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        for (int i = 0; i < wtypes.Length; i++)
                        {
                            cmd.Parameters.AddWithValue("@wtype" + i, wtypes[i]);
                        }
                        cmd.Parameters.AddWithValue("@qid", qid);
                        cmd.Parameters.AddWithValue("@qidMin", qid - 10);
                        cmd.Parameters.AddWithValue("@qidMax", qid + 10);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            dt = new DataTable();
                            dt.Load(dr);
                        }
                    }
                }
                
                // 如果还是没找到，根据题目类型查找该学生最近24小时内的对应类型作品
                if (dt.Rows.Count == 0 && wtypes.Length > 0)
                {
                    // 构建类型匹配条件
                    string typeCondition = "Wtype IN (";
                    for (int i = 0; i < wtypes.Length; i++)
                    {
                        if (i > 0) typeCondition += ",";
                        typeCondition += "@wtype" + i;
                    }
                    typeCondition += ")";
                    
                    sql = @"SELECT TOP 1 Wid, Wtype, Wcode, Wthumbnail, Wdate, Wpass 
                        FROM Works WHERE Wsid=@sid AND " + typeCondition + @"
                        AND Wdate >= DATEADD(HOUR, -24, GETDATE())
                        ORDER BY Wdate DESC, Wid DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        for (int i = 0; i < wtypes.Length; i++)
                        {
                            cmd.Parameters.AddWithValue("@wtype" + i, wtypes[i]);
                        }
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            dt = new DataTable();
                            dt.Load(dr);
                        }
                    }
                    
                    // 如果24小时内没有，查找最近的作品
                    if (dt.Rows.Count == 0)
                    {
                        sql = @"SELECT TOP 1 Wid, Wtype, Wcode, Wthumbnail, Wdate, Wpass 
                            FROM Works WHERE Wsid=@sid AND " + typeCondition + @"
                            ORDER BY Wdate DESC, Wid DESC";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            for (int i = 0; i < wtypes.Length; i++)
                            {
                                cmd.Parameters.AddWithValue("@wtype" + i, wtypes[i]);
                            }
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                dt = new DataTable();
                                dt.Load(dr);
                            }
                        }
                    }
                }

                if (dt.Rows.Count == 0)
                {
                    // 返回详细的调试信息
                    StringBuilder debugInfo = new StringBuilder();
                    debugInfo.Append("{\"found\":false,\"debug\":{");
                    debugInfo.AppendFormat("\"sid\":{0},", sid);
                    debugInfo.AppendFormat("\"qid\":{0},", qid);
                    debugInfo.AppendFormat("\"qtype\":\"{0}\",", JsonEscape(qtype));
                    debugInfo.AppendFormat("\"expectedWtype\":\"{0}\",", JsonEscape(wtype));
                    
                    // 检查该学生是否有任何作品
                    int totalWorks = 0;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Works WHERE Wsid=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        totalWorks = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    debugInfo.AppendFormat("\"totalWorks\":{0},", totalWorks);
                    
                    // 检查该学生最近的作品
                    if (totalWorks > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT TOP 1 Wid, Wmid, Wlid, Wtype, Wdate FROM Works WHERE Wsid=@sid ORDER BY Wdate DESC", conn))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    debugInfo.AppendFormat("\"latestWork\":{{\"wid\":{0},\"wmid\":{1},\"wlid\":{2},\"wtype\":\"{3}\",\"wdate\":\"{4}\"}}",
                                        dr["Wid"] != DBNull.Value ? Convert.ToInt32(dr["Wid"]) : 0,
                                        dr["Wmid"] != DBNull.Value ? Convert.ToInt32(dr["Wmid"]) : 0,
                                        dr["Wlid"] != DBNull.Value ? Convert.ToInt32(dr["Wlid"]) : 0,
                                        JsonEscape(dr["Wtype"] != DBNull.Value ? dr["Wtype"].ToString() : ""),
                                        dr["Wdate"] != DBNull.Value ? Convert.ToDateTime(dr["Wdate"]).ToString("yyyy-MM-dd HH:mm") : "");
                                }
                                dr.Close();
                            }
                        }
                        
                        // 尝试最后的兜底策略：查找Wmid最接近的作品（不限类型，扩大到±10范围）
                        sql = @"SELECT TOP 1 Wid, Wtype, Wcode, Wthumbnail, Wdate, Wpass 
                            FROM Works WHERE Wsid=@sid 
                            AND Wmid BETWEEN @qidMin AND @qidMax
                            ORDER BY ABS(Wmid - @qid), Wdate DESC, Wid DESC";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.Parameters.AddWithValue("@qid", qid);
                            cmd.Parameters.AddWithValue("@qidMin", qid - 10);
                            cmd.Parameters.AddWithValue("@qidMax", qid + 10);
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                dt = new DataTable();
                                dt.Load(dr);
                            }
                        }
                        
                        if (dt.Rows.Count > 0)
                        {
                            debugInfo.Append(",\"fallbackUsed\":true");
                        }
                    }
                    
                    debugInfo.Append("}}");
                    
                    // 如果兜底策略找到了作品，返回作品数据而不是错误
                    if (dt.Rows.Count > 0)
                    {
                        // 继续处理，不返回错误
                    }
                    else
                    {
                        context.Response.Write(debugInfo.ToString());
                        return;
                    }
                }

                DataRow row = dt.Rows[0];
                StringBuilder json = new StringBuilder();
                json.Append("{");
                json.Append("\"found\":true,");
                json.AppendFormat("\"wid\":{0},", Convert.ToInt32(row["Wid"]));
                json.AppendFormat("\"wtype\":\"{0}\",", JsonEscape(row["Wtype"] != DBNull.Value ? row["Wtype"].ToString() : ""));
                json.AppendFormat("\"wcode\":\"{0}\",", JsonEscape(row["Wcode"] != DBNull.Value ? row["Wcode"].ToString() : ""));
                json.AppendFormat("\"wthumbnail\":\"{0}\",", JsonEscape(row["Wthumbnail"] != DBNull.Value ? row["Wthumbnail"].ToString() : ""));
                json.AppendFormat("\"wdate\":\"{0}\",", row["Wdate"] != DBNull.Value ? Convert.ToDateTime(row["Wdate"]).ToString("yyyy-MM-dd HH:mm") : "");
                json.AppendFormat("\"wpass\":{0},", (row["Wpass"] != DBNull.Value && Convert.ToBoolean(row["Wpass"])) ? "true" : "false");
                json.AppendFormat("\"sname\":\"{0}\",", JsonEscape(sname));
                json.AppendFormat("\"snum\":\"{0}\",", JsonEscape(snum));
                json.AppendFormat("\"sgrade\":{0},", sgrade);
                json.AppendFormat("\"sclass\":{0}", sclass);
                json.Append("}");

                context.Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"error\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }

    public bool IsReusable { get { return false; } }
}



#line default
#line hidden
