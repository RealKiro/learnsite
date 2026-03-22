using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Text;

/// <summary>
/// 替换DLL的Student_pixel，直接提供像素编辑器所需属性，跳过任务说明页
/// </summary>
public class Student_pixel_new : Page
{
    // pixel.aspx 使用的属性
    public string Id = "";
    public string PixFile = "";
    public string Fpage = "";

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

    private string GetStudentSnum()
    {
        string snum = "";
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); }
                    catch { }
                }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    MethodInfo mi = ct.GetMethod("ToModel", new Type[] { typeof(string) });
                    if (mi != null)
                    {
                        object model = mi.Invoke(m, new object[] { cookieVal });
                        if (model != null)
                        {
                            PropertyInfo snumProp = ct.GetProperty("Snum");
                            if (snumProp != null)
                            {
                                object val = snumProp.GetValue(model, null);
                                if (val != null) snum = val.ToString();
                            }
                        }
                    }
                }
            }
        }
        catch { }
        return snum;
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
        if (lid == 111 && lcid == 16) return "8";
        if (lid == 23 && lcid == 5) return "14";
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5";
        if (lid == 53 && lcid == 11) return "4";
        if (lid == 58 && lcid == 12) return "4";
        if (lid == 47 && lcid == 9) return "6";
        if (lid == 48 && lcid == 9) return "8"; // 像素，非表格
        if (lid == 49 && lcid == 9) return "9"; // Html，非课件
        return normalized;
    }
    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11": // 像素画
                return true;
            case "36": // 素材库 → 经 program.aspx 再跳转
            case "37": // 网站设计 → 经 program.aspx 再跳转
            case "17": // 二维码任务 → qrcode.aspx
            default:
                return false;
        }
    }

    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);
        if (IsPostBack) return;

        string lidStr = Request.QueryString["lid"];
        if (string.IsNullOrEmpty(lidStr)) return;

        int lid = 0;
        int.TryParse(lidStr, out lid);
        if (lid <= 0) return;

        int mid = 0;
        int.TryParse(Request.QueryString["mid"], out mid);
        int mcid = 0;
        int.TryParse(Request.QueryString["mcid"], out mcid);
        bool forceEditor = (Request.QueryString["editor"] ?? "") == "1";

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. 读取Listmenu获取任务信息
                int lxid = 0;
                int lcid = 0;
                string ltype = "";
                string mfiletype = "";
                bool isSurvey = false, isTopic = false, isTxtForm = false;
                bool isPixelAddSubtype = false;

                string sql = @"SELECT Ltype, Lxid, Lcid, M.Msort, M.Mfiletype,
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
                            ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                            lcid = reader["Lcid"] != DBNull.Value ? Convert.ToInt32(reader["Lcid"]) : 0;
                            string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim() : "";
                            isSurvey = Convert.ToInt32(reader["IsSurvey"]) == 1;
                            isTopic = Convert.ToInt32(reader["IsTopic"]) == 1;
                            isTxtForm = Convert.ToInt32(reader["IsTxtForm"]) == 1;
                            // Msort 18-37 专属类型：统一跳转到 program.aspx（任务说明页），再由「开始创作」跳对应编辑器
                            // 包括：素材库(36)、网站设计(37)，均先过 program.aspx 展示任务说明
                            {
                                int _msortNum;
                                if (int.TryParse(msort, out _msortNum) && _msortNum >= 18 && _msortNum <= 37)
                                {
                                    int _cid2 = lcid > 0 ? lcid : mcid;
                                    string _progUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}&msort={3}", lid, lxid, _cid2, msort);
                                    try { Response.Redirect(_progUrl, false); Context.ApplicationInstance.CompleteRequest(); }
                                    catch (System.Threading.ThreadAbortException) { throw; }
                                    catch { }
                                    return;
                                }
                            }
                            if (IsPixelAddProgramSubtype(msort)) { ltype = "8"; isPixelAddSubtype = true; }
                        }
                    }
                }

                // 2. 纠正类型
                string normalized = NormalizeLtype(ltype);
                normalized = ApplyKnownLtypeOverrides(normalized, lid, lcid);
                int nType;
                if (int.TryParse(normalized, out nType) && nType >= 1 && nType <= 12)
                {
                    if (isSurvey) normalized = "14";
                    else if (isTopic) normalized = "13";
                    else if (isTxtForm) normalized = "15";
                }

                // 2.5. 如果 Mfiletype 是 pxl（像素画），强制设置为类型 8
                // 这样可以修正 Ltype 和 Mfiletype 不一致的情况
                if (!string.IsNullOrEmpty(mfiletype) && mfiletype.ToLower() == "pxl")
                {
                    normalized = "8";
                }

                // 3. 如果是pixeladd子类型（Msort 11-37），默认先进入 program.aspx；
                // 但从“开始创作”进入编辑器时（editor=1）不再回跳。
                if (isPixelAddSubtype && !forceEditor)
                {
                    int courseId2 = lcid > 0 ? lcid : mcid;
                    string targetUrl2 = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId2);
                    try { Response.Redirect(targetUrl2, true); }
                    catch (System.Threading.ThreadAbortException) { throw; }
                    catch { }
                    return;
                }

                // 4. 如果类型不是"8"(像素)，跳转到正确页面
                if (normalized != "8")
                {
                    int courseId = lcid > 0 ? lcid : mcid;
                    string targetUrl = GetCorrectStudentPage(normalized, lid, lxid, courseId);
                    try { Response.Redirect(targetUrl, true); }
                    catch (System.Threading.ThreadAbortException) { throw; }
                    catch { }
                    return;
                }

                // 4. 类型正确，设置像素编辑器属性
                int cid = lcid > 0 ? lcid : mcid;
                int missionId = lxid > 0 ? lxid : mid;
                Id = cid + "-" + missionId + "-" + lid;
                if (forceEditor)
                    Fpage = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, missionId, cid);
                else
                    Fpage = "showcourse.aspx?cid=" + cid;

                // 5. 从Works表加载已保存的像素数据
                string snum = GetStudentSnum();
                PixFile = "";
                if (!string.IsNullOrEmpty(snum))
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT TOP 1 codefile FROM Works WHERE Snum=@Snum AND Wlid=@Lid ORDER BY Wid DESC", conn))
                        {
                            cmd.Parameters.AddWithValue("@Snum", snum);
                            cmd.Parameters.AddWithValue("@Lid", lid);
                            object obj = cmd.ExecuteScalar();
                            if (obj != null && obj != DBNull.Value)
                                PixFile = obj.ToString();
                        }
                    }
                    catch { }
                }
            }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch { }
    }

    private string GetCorrectStudentPage(string ltype, int lid, int lxid, int courseId)
    {
        switch (ltype)
        {
            case "1": case "2": case "3":
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "4":
                    return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "5": case "7": case "8": case "9": case "10": case "11": case "12":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "6":
                return string.Format("console.aspx?lid={0}", lid);
            case "13":
                return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, courseId);
            case "14":
                return string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, courseId);
            case "15":
                return string.Format("txtformresult.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            default:
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
        }
    }

    protected void Page_Load(object sender, EventArgs e) { }
}
