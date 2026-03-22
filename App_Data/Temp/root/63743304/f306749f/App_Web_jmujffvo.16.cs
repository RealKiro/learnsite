#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\mxgraph-fix.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "44F392C13E9672C13EE91A19D5CDDA4D"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\mxgraph-fix.ashx"


using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;
using System.Text;

/// <summary>
/// 流程图页面(mxgraph.aspx)数据修正接口
/// 用于：1. 验证任务类型一致性  2. 提供调试信息  3. 返回正确的 codefile/Id/Fpage 等数据
/// 参数：lid, mid, mcid, debug(可选)
/// 当前页面期望 Ltype=7 (流程图)
/// </summary>
public class MxgraphFix : IHttpHandler
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

    private string GetStudentSnum(HttpContext context)
    {
        string snum = "";
        try
        {
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
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
                    MethodInfo mi = ct.GetMethod("ToModel",
                        BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    PropertyInfo pn = ct.GetProperty("Snum");
                    if (pn != null)
                    {
                        object v = pn.GetValue(m, null);
                        if (v != null) snum = v.ToString();
                    }
                }
            }
        }
        catch { }
        return snum;
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        string lidStr = context.Request.QueryString["lid"] ?? "";
        string midStr = context.Request.QueryString["mid"] ?? "";
        string mcidStr = context.Request.QueryString["mcid"] ?? "";

        int lid = 0, mid = 0, mcid = 0;
        int.TryParse(lidStr, out lid);
        int.TryParse(midStr, out mid);
        int.TryParse(mcidStr, out mcid);

        string snum = GetStudentSnum(context);

        string dbLxid = "";
        string dbLtype = "";
        string dbLcid = "";
        string dbLtitle = "";
        string missionTitle = "";
        string missionContent = "";
        string missionFileType = "";
        string worksCodefile = "";
        string worksWid = "";
        string correctId = "";
        string correctFpage = "";
        string error = "";

        // 类型验证
        string normalizedLtype = "";
        string correctPageForType = "";
        string currentPage = "mxgraph";
        string expectedLtype = "7";  // mxgraph.aspx 对应 Ltype=7(流程图)
        bool typeMismatch = false;

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr))
        {
            error = "无法获取数据库连接字符串";
        }
        else if (lid <= 0)
        {
            error = "lid参数无效: " + lidStr;
        }
        else
        {
            SqlConnection conn = null;
            try
            {
                conn = new SqlConnection(connStr);
                conn.Open();

                // 1. 查询 Listmenu
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT L.Lid, L.Lxid, L.Ltype, L.Ltitle, L.Lcid, M.Msort FROM Listmenu L LEFT JOIN Mission M ON L.Lxid=M.Mid WHERE L.Lid=@Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            dbLxid = reader["Lxid"] != DBNull.Value ? reader["Lxid"].ToString() : "";
                            dbLtype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            dbLcid = reader["Lcid"] != DBNull.Value ? reader["Lcid"].ToString() : "";
                            dbLtitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "";
                            string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            if (IsPixelAddProgramSubtype(msort)) dbLtype = "8";
                        }
                        else
                        {
                            error = "Listmenu中未找到Lid=" + lid + "的记录";
                        }
                    }
                }

                if (string.IsNullOrEmpty(error))
                {
                    int lxid = 0;
                    int.TryParse(dbLxid, out lxid);
                    // 2. 查询 Mission
                    if (lxid > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT Mid, Mtitle, Mcontent, Mfiletype FROM Mission WHERE Mid=@Mid", conn))
                        {
                            cmd.Parameters.AddWithValue("@Mid", lxid);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    missionTitle = reader["Mtitle"] != DBNull.Value ? reader["Mtitle"].ToString() : "";
                                    missionContent = reader["Mcontent"] != DBNull.Value ? reader["Mcontent"].ToString() : "";
                                    missionFileType = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim() : "";
                                }
                            }
                        }
                    }

                    // === 归一化Ltype并计算正确页面 ===
                    normalizedLtype = NormalizeLtype(dbLtype);
                    string mcidForOverride = mcid > 0 ? mcid.ToString() : dbLcid;
                    normalizedLtype = ApplyKnownLtypeOverrides(normalizedLtype, lid, mcidForOverride);
                    int lcidForCorrect = 0;
                    int.TryParse(dbLcid, out lcidForCorrect);
                    normalizedLtype = CorrectLtypeByData(conn, normalizedLtype, lxid, lcidForCorrect, lid);
                    normalizedLtype = PreferEditorLtype(normalizedLtype, missionFileType);

                    int courseIdForUrl = mcid > 0 ? mcid : 0;
                    if (courseIdForUrl <= 0) int.TryParse(dbLcid, out courseIdForUrl);
                    int lxidForUrl = lxid > 0 ? lxid : 0;

                    correctPageForType = GetCorrectStudentPage(normalizedLtype, lid, lxidForUrl, courseIdForUrl);
                    typeMismatch = (normalizedLtype != expectedLtype);

                    // 3. 查询学生已保存的流程图（Works表，Wcode字段存储XML）
                    string worksLookupInfo = "";
                    if (!string.IsNullOrEmpty(snum))
                    {
                        // 方式A: 按 Wlid=lid 查找
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT TOP 1 Wid, Wurl, Wcode, Wthumbnail FROM Works WHERE Wlid=@Wlid AND Wnum=@Wnum ORDER BY Wid DESC", conn))
                        {
                            cmd.Parameters.AddWithValue("@Wlid", lid);
                            cmd.Parameters.AddWithValue("@Wnum", snum);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    worksWid = reader["Wid"] != DBNull.Value ? reader["Wid"].ToString() : "";
                                    worksCodefile = reader["Wcode"] != DBNull.Value ? reader["Wcode"].ToString() : "";
                                    worksLookupInfo = "按Wlid=lid(" + lid + ")找到";
                                }
                            }
                        }

                        // 方式B: 按 Wmid=mid 查找
                        if (string.IsNullOrEmpty(worksWid) && mid > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "SELECT TOP 1 Wid, Wurl, Wcode, Wthumbnail FROM Works WHERE Wmid=@Wmid AND Wnum=@Wnum ORDER BY Wid DESC", conn))
                            {
                                cmd.Parameters.AddWithValue("@Wmid", mid);
                                cmd.Parameters.AddWithValue("@Wnum", snum);
                                using (SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        worksWid = reader["Wid"] != DBNull.Value ? reader["Wid"].ToString() : "";
                                        worksCodefile = reader["Wcode"] != DBNull.Value ? reader["Wcode"].ToString() : "";
                                        worksLookupInfo = "按Wmid=mid(" + mid + ")找到";
                                    }
                                }
                            }
                        }

                        // 方式C: 按 Wlid=mid 查找（兼容旧数据）
                        if (string.IsNullOrEmpty(worksWid) && mid > 0 && mid != lid)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "SELECT TOP 1 Wid, Wurl, Wcode, Wthumbnail FROM Works WHERE Wlid=@Wlid AND Wnum=@Wnum ORDER BY Wid DESC", conn))
                            {
                                cmd.Parameters.AddWithValue("@Wlid", mid);
                                cmd.Parameters.AddWithValue("@Wnum", snum);
                                using (SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        worksWid = reader["Wid"] != DBNull.Value ? reader["Wid"].ToString() : "";
                                        worksCodefile = reader["Wcode"] != DBNull.Value ? reader["Wcode"].ToString() : "";
                                        worksLookupInfo = "按Wlid=mid(" + mid + ")找到(兼容旧数据)";
                                    }
                                }
                            }
                        }

                        if (!string.IsNullOrEmpty(worksLookupInfo))
                        {
                            error = (string.IsNullOrEmpty(error) ? "" : error + "; ") + "Works查找: " + worksLookupInfo;
                        }
                    }

                    // 计算正确的ID (格式: mcid-mid-lid)
                    int courseId = mcid > 0 ? mcid : 0;
                    if (courseId <= 0) int.TryParse(dbLcid, out courseId);
                    int missionId = mid > 0 ? mid : 0;
                    if (missionId <= 0) int.TryParse(dbLxid, out missionId);
                    correctId = courseId + "-" + missionId + "-" + lid;

                    correctFpage = "";

                    // 类型不匹配时记录警告
                    if (typeMismatch)
                    {
                        string typeWarning = "类型不匹配! 当前页面=mxgraph(流程图,期望Ltype=7), 数据库Ltype=" + dbLtype + "(归一化=" + normalizedLtype + "," + GetLtypeName(normalizedLtype) + "), 应跳转=" + correctPageForType;
                        error = (string.IsNullOrEmpty(error) ? "" : error + "; ") + typeWarning;
                    }
                }
            }
            catch (Exception ex)
            {
                error = (string.IsNullOrEmpty(error) ? "" : error + "; ") + "数据库查询错误: " + ex.Message;
            }
            finally
            {
                if (conn != null && conn.State == System.Data.ConnectionState.Open) conn.Close();
            }
        }

        // 构建JSON响应
        StringBuilder json = new StringBuilder();
        json.Append("{");
        json.AppendFormat("\"lid\":{0},", lid);
        json.AppendFormat("\"mid\":{0},", mid);
        json.AppendFormat("\"mcid\":{0},", mcid);
        json.AppendFormat("\"snum\":{0},", JsonStr(snum));
        json.AppendFormat("\"dbLxid\":{0},", JsonStr(dbLxid));
        json.AppendFormat("\"dbLtype\":{0},", JsonStr(dbLtype));
        json.AppendFormat("\"dbLcid\":{0},", JsonStr(dbLcid));
        json.AppendFormat("\"dbLtitle\":{0},", JsonStr(dbLtitle));
        json.AppendFormat("\"normalizedLtype\":{0},", JsonStr(normalizedLtype));
        json.AppendFormat("\"normalizedLtypeName\":{0},", JsonStr(GetLtypeName(normalizedLtype)));
        json.AppendFormat("\"expectedLtype\":{0},", JsonStr(expectedLtype));
        json.AppendFormat("\"currentPage\":{0},", JsonStr(currentPage));
        json.AppendFormat("\"typeMismatch\":{0},", typeMismatch ? "true" : "false");
        json.AppendFormat("\"correctPageForType\":{0},", JsonStr(correctPageForType));
        json.AppendFormat("\"missionTitle\":{0},", JsonStr(missionTitle));
        json.AppendFormat("\"missionFileType\":{0},", JsonStr(missionFileType));
        json.AppendFormat("\"missionContentLen\":{0},", missionContent.Length);
        json.AppendFormat("\"worksWid\":{0},", JsonStr(worksWid));
        json.AppendFormat("\"worksCodefile\":{0},", JsonStr(worksCodefile));
        json.AppendFormat("\"correctId\":{0},", JsonStr(correctId));
        json.AppendFormat("\"correctFpage\":{0},", JsonStr(correctFpage));
        json.AppendFormat("\"error\":{0}", JsonStr(error));
        json.Append("}");

        context.Response.Write(json.ToString());
    }

    private string JsonStr(string val)
    {
        if (val == null) return "null";
        return "\"" + val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n").Replace("\t", "\\t") + "\"";
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

    private string ApplyKnownLtypeOverrides(string ltype, int lid, string mcid)
    {
        return ltype;
    }

    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5"; // Python，非像素
        if (lid == 47 && lcid == 9) return "6"; // 测评，非Html
        if (lid == 53 && lcid == 11) return "4";
        if (lid == 58 && lcid == 12) return "4";
        // if (lid == 61 && lcid == 12) return "7"; // 撤销错误硬编码
        if (lid == 48 && lcid == 9) return "8"; // 像素，非表格
        if (lid == 49 && lcid == 9) return "9"; // Html，非课件
        if (lid == 85 && lcid == 12) return "10"; // 导图，禁止误判为填表
        return normalized;
    }

    private string PreferEditorLtype(string normalizedLtype, string missionFileType)
    {
        string editorLtype = GetLtypeByFileType(missionFileType);
        return string.IsNullOrEmpty(editorLtype) ? normalizedLtype : editorLtype;
    }

    private string GetLtypeByFileType(string fileType)
    {
        if (string.IsNullOrEmpty(fileType)) return "";
        string ft = fileType.Trim().ToLower();
        switch (ft)
        {
            case "py":
                return "5";
            case "sb":
            case "sb2":
            case "sb3":
            case "scratch":
                return "4";
            case "xml":
                return "7";
            case "pxl":
                return "8";
            case "html":
            case "htm":
                return "9";
            case "km":
            case "mm":
            case "mindmap":
            case "kitymind":
                return "10";
            case "xls":
            case "xlsx":
            case "et":
            case "ett":
            case "csv":
            case "excel":
            case "sheet":
            case "luckysheet":
                return "11";
            case "ppt":
            case "pptx":
                return "12";
            default:
                return "";
        }
    }
    
    private string CorrectLtypeByData(SqlConnection conn, string normalizedLtype, int lxid, int lcid, int lid)
    {
        normalizedLtype = ApplyKnownLtypeOverrides(normalizedLtype, lid, lcid);
        // 仅对通用类型(1-3)做纠偏，避免专用类型(4-12)因 lxid 撞号被误判
        int nType;
        if (int.TryParse(normalizedLtype, out nType) && nType >= 1 && nType <= 3)
        {
            // 用课程ID关联精确匹配，避免跨表ID碰撞
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 1 FROM SurveyQuestion WHERE Qvid=@Qvid AND Qcid=@Lcid", conn))
                {
                    cmd.Parameters.AddWithValue("@Qvid", lxid);
                    cmd.Parameters.AddWithValue("@Lcid", lcid);
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return "14";
                }
            }
            catch { }
            
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 1 FROM TopicDiscuss WHERE Tid=@Tid AND Tcid=@Lcid", conn))
                {
                    cmd.Parameters.AddWithValue("@Tid", lxid);
                    cmd.Parameters.AddWithValue("@Lcid", lcid);
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return "13";
                }
            }
            catch { }
            
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 1 FROM TxtForm WHERE Mid=@Mid AND Mcid=@Lcid", conn))
                {
                    cmd.Parameters.AddWithValue("@Mid", lxid);
                    cmd.Parameters.AddWithValue("@Lcid", lcid);
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return "15";
                }
            }
            catch { }
        }
        return normalizedLtype;
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

    private string GetLtypeName(string ltype)
    {
        switch (ltype)
        {
            case "1": return "活动";
            case "2": return "主题";
            case "3": return "练习";
            case "4": return "积木编程";
            case "5": return "Python";
            case "6": return "测评";
            case "7": return "流程图";
            case "8": return "应用";
            case "9": return "Html";
            case "10": return "导图";
            case "11": return "表格";
            case "12": return "课件";
            case "13": return "讨论";
            case "14": return "调查";
            case "15": return "填表";
            default: return "未知(" + ltype + ")";
        }
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
