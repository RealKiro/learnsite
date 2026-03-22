<%@ WebHandler Language="C#" Class="HtmleditFixHandler" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;

/// <summary>
/// htmledit.aspx 类型检查处理程序
/// 检查当前lid对应的任务类型是否为9(Html/网页)，如不匹配则返回正确页面URL
/// </summary>
public class HtmleditFixHandler : IHttpHandler
{
    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11":
            case "17":
            case "18":
            case "19":
            case "20":
            case "21":
            case "22":
            case "23":
            case "24":
            case "25":
            case "26":
            case "27":
            case "28":
            case "29":
            case "30":
            case "31":
            case "32":
            case "33":
            case "34":
            case "35":
            case "36":
            case "37":
                return true;
            default:
                return false;
        }
    }
    public bool IsReusable { get { return false; } }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        int lid = 0;
        int mid = 0;
        int mcid = 0;
        int.TryParse(context.Request.QueryString["lid"], out lid);
        int.TryParse(context.Request.QueryString["mid"], out mid);
        int.TryParse(context.Request.QueryString["mcid"], out mcid);

        if (lid <= 0)
        {
            context.Response.Write("{\"typeMismatch\":false,\"error\":\"no lid\"}");
            return;
        }

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr))
        {
            context.Response.Write("{\"typeMismatch\":false,\"error\":\"no connstr\"}");
            return;
        }

        bool typeMismatch = false;
        string correctPage = "";
        string normalizedLtype = "";
        string error = "";

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"SELECT Ltype, Lxid, Lcid, M.Msort,
                    CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion WHERE Qvid=Lxid AND Qcid=Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                    CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss WHERE Tid=Lxid AND Tcid=Lcid) THEN 1 ELSE 0 END AS IsTopic,
                    CASE WHEN EXISTS(SELECT 1 FROM TxtForm WHERE Mid=Lxid AND Mcid=Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                    FROM Listmenu L LEFT JOIN Mission M ON L.Lxid=M.Mid WHERE L.Lid=@Lid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                            int lcid = reader["Lcid"] != DBNull.Value ? Convert.ToInt32(reader["Lcid"]) : 0;
                            string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            bool isSurvey = Convert.ToInt32(reader["IsSurvey"]) == 1;
                            bool isTopic = Convert.ToInt32(reader["IsTopic"]) == 1;
                            bool isTxtForm = Convert.ToInt32(reader["IsTxtForm"]) == 1;

                            reader.Close();

                            normalizedLtype = NormalizeLtype(ltype);
                            normalizedLtype = ApplyKnownLtypeOverrides(normalizedLtype, lid, lcid);

                            int nType;
                            if (int.TryParse(normalizedLtype, out nType) && nType >= 1 && nType <= 12)
                            {
                                try
                                {
                                    using (SqlCommand cmd2 = new SqlCommand("SELECT TOP 1 1 FROM SurveyQuestion WHERE Qvid=@Qvid AND Qcid=@Lcid", conn))
                                    {
                                        cmd2.Parameters.AddWithValue("@Qvid", lxid);
                                        cmd2.Parameters.AddWithValue("@Lcid", lcid);
                                        object obj = cmd2.ExecuteScalar();
                                        if (obj != null && obj != DBNull.Value)
                                            normalizedLtype = "14";
                                    }
                                }
                                catch { }

                                if (normalizedLtype != "14")
                                {
                                    try
                                    {
                                        using (SqlCommand cmd2 = new SqlCommand("SELECT TOP 1 1 FROM TopicDiscuss WHERE Tid=@Tid AND Tcid=@Lcid", conn))
                                        {
                                            cmd2.Parameters.AddWithValue("@Tid", lxid);
                                            cmd2.Parameters.AddWithValue("@Lcid", lcid);
                                            object obj = cmd2.ExecuteScalar();
                                            if (obj != null && obj != DBNull.Value)
                                                normalizedLtype = "13";
                                        }
                                    }
                                    catch { }
                                }

                                if (normalizedLtype != "14" && normalizedLtype != "13")
                                {
                                    try
                                    {
                                        using (SqlCommand cmd2 = new SqlCommand("SELECT TOP 1 1 FROM TxtForm WHERE Mid=@Mid AND Mcid=@Lcid", conn))
                                        {
                                            cmd2.Parameters.AddWithValue("@Mid", lxid);
                                            cmd2.Parameters.AddWithValue("@Lcid", lcid);
                                            object obj = cmd2.ExecuteScalar();
                                            if (obj != null && obj != DBNull.Value)
                                                normalizedLtype = "15";
                                        }
                                    }
                                    catch { }
                                }
                            }
                            if (IsPixelAddProgramSubtype(msort))
                                normalizedLtype = "8";

                            // htmledit.aspx 对应类型 "9"
                            if (normalizedLtype != "9")
                            {
                                typeMismatch = true;
                                int courseId = lcid > 0 ? lcid : mcid;
                                correctPage = GetCorrectStudentPage(normalizedLtype, lid, lxid, courseId);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            error = ex.Message;
        }

        context.Response.Write("{\"typeMismatch\":" + (typeMismatch ? "true" : "false") +
            ",\"correctPageForType\":" + JsonStr(correctPage) +
            ",\"normalizedLtype\":" + JsonStr(normalizedLtype) +
            ",\"error\":" + JsonStr(error) + "}");
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo connField = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (connField != null)
                    cs = connField.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        return cs;
    }

    private string NormalizeLtype(string ltype)
    {
        if (string.IsNullOrEmpty(ltype)) return "0";
        ltype = ltype.Trim();
        switch (ltype)
        {
            case "活动": return "1";
            case "主题": return "2";
            case "练习": return "3";
            case "积木": case "积木编程": return "4";
            case "Python": case "代码": case "仓库": return "5";
            case "测评": return "6";
            case "流程": case "流程图": return "7";
            case "应用": case "像素": case "拼图": case "绘图": return "8";
            case "Html": case "网页": return "9";
            case "导图": case "脑图": return "10";
            case "表格": return "11";
            case "课件": return "12";
            case "讨论": return "13";
            case "调查": case "调查问卷": return "14";
            case "填表": return "15";
            default: return ltype;
        }
    }

    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 23 && lcid == 5) return "14";
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5";
        if (lid == 53 && lcid == 11) return "4";
        if (lid == 58 && lcid == 12) return "4";
        if (lid == 47 && lcid == 9) return "6"; // 测评，非Html
        if (lid == 48 && lcid == 9) return "8"; // 像素，非表格
        if (lid == 49 && lcid == 9) return "9"; // Html，非课件
        return normalized;
    }

    private string GetCorrectStudentPage(string ltype, int lid, int lxid, int courseId)
    {
        switch (ltype)
        {
            case "1": case "2": case "3":
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "4":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "6":
                return string.Format("console.aspx?lid={0}", lid);
            case "5": case "7": case "8": case "9": case "10": case "11": case "12":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "13":
                return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, courseId);
            case "14":
                return string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, courseId);
            case "15":
                return string.Format("txtform.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            default:
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
        }
    }

    private string JsonStr(string val)
    {
        if (val == null) return "null";
        return "\"" + val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    }
}
