using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;
using System.Web.UI;

public class Student_programshow_new : Page
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

    // 检查任务类型，如果不是programshow对应的类型4，跳转到正确页面
    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);
        if (IsPostBack) return;

        string lid = Request.QueryString["lid"];
        if (string.IsNullOrEmpty(lid)) return;

        int listId;
        if (!int.TryParse(lid, out listId)) return;

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"SELECT Ltype, Lxid, Lcid, M.Msort,
                    CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion WHERE Qvid = Lxid AND Qcid = Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                    CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss WHERE Tid = Lxid AND Tcid = Lcid) THEN 1 ELSE 0 END AS IsTopic,
                    CASE WHEN EXISTS(SELECT 1 FROM TxtForm WHERE Mid = Lxid AND Mcid = Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                    FROM Listmenu L LEFT JOIN Mission M ON L.Lxid=M.Mid WHERE L.Lid=@Lid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                            string lcid = reader["Lcid"] != DBNull.Value ? reader["Lcid"].ToString() : "";
                            string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            bool isSurvey = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                            bool isTopic = reader["IsTopic"] != DBNull.Value && Convert.ToInt32(reader["IsTopic"]) == 1;
                            bool isTxtForm = reader["IsTxtForm"] != DBNull.Value && Convert.ToInt32(reader["IsTxtForm"]) == 1;
                            string mcid = !string.IsNullOrEmpty(lcid) ? lcid : (Request.QueryString["mcid"] ?? "");

                            string normalized = NormalizeLtype(ltype);
                            // 已知类型覆盖
                            if (listId == 40 && mcid == "9") normalized = "7";
                            if (listId == 41 && mcid == "9") normalized = "5"; // Python，非像素
                            if (listId == 47 && mcid == "9") normalized = "6"; // 测评，非Html
                            if (listId == 48 && mcid == "9") normalized = "8"; // 像素，非表格
                            // 纠偏：用课程ID关联精确匹配
                            int nType;
                            if (int.TryParse(normalized, out nType) && nType >= 1 && nType <= 12)
                            {
                                if (isSurvey) normalized = "14";
                                else if (isTopic) normalized = "13";
                                else if (isTxtForm) normalized = "15";
                            }
                            if (IsPixelAddProgramSubtype(msort)) normalized = "8";

                            // 如果类型不是4(积木编程)，跳转到正确页面
                            if (normalized != "4")
                            {
                                string targetUrl = "";
                                switch (normalized)
                                {
                                    case "1": case "2": case "3":
                                        targetUrl = string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "5":
                                        targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "6":
                                        targetUrl = string.Format("console.aspx?lid={0}", listId); break;
                                    case "7":
                                        targetUrl = string.Format("mxgraph.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "8":
                                        targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "9":
                                        targetUrl = string.Format("htmledit.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "10":
                                        targetUrl = string.Format("kitymind.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "11":
                                        targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "12":
                                        targetUrl = string.Format("ware.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    case "13":
                                        targetUrl = string.Format("topicdiscuss.aspx?lid={0}&cid={1}", listId, mcid); break;
                                    case "14":
                                        targetUrl = string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, mcid); break;
                                    case "15":
                                        targetUrl = string.Format("txtform.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                    default:
                                        targetUrl = string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", listId, lxid, mcid); break;
                                }
                                reader.Close();
                                try { Response.Redirect(targetUrl, true); }
                                catch (System.Threading.ThreadAbortException) { throw; }
                                catch { }
                            }
                        }
                    }
                }
            }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e) { }

    protected void LinkBtn_Click(object sender, EventArgs e)
    {
        string mcid = Request.QueryString["mcid"];
        if (!string.IsNullOrEmpty(mcid))
            Response.Redirect("showcourse.aspx?cid=" + mcid);
        else
            Response.Redirect("showcourse.aspx");
    }
}
