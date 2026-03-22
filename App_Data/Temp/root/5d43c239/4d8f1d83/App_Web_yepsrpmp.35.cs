#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\task-type-debug.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "9861D50F272BDB560931004BE598FC59"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\task-type-debug.ashx"


using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;
using System.Text;

/// <summary>
/// 任务类型一致性调试接口
/// 用于诊断学生端/教师端任务类型不一致问题
/// 参数: lid (必须), mid (可选), mcid (可选)
/// 返回: JSON格式的任务类型诊断信息
///   包括: 数据库原始值, 归一化值, 学生端正确页面, 教师端对应页面, 页面是否存在
/// 用法: task-type-debug.ashx?lid=40&mid=27&mcid=9
/// </summary>
public class TaskTypeDebug : IHttpHandler
{
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

    public void ProcessRequest(HttpContext context)
    {
        string format = (context.Request.QueryString["format"] ?? "").ToLower();
        bool isJson = format == "json";

        if (isJson)
            context.Response.ContentType = "application/json; charset=utf-8";
        else
            context.Response.ContentType = "text/html; charset=utf-8";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        string lidStr = context.Request.QueryString["lid"] ?? "";
        string midStr = context.Request.QueryString["mid"] ?? "";
        string mcidStr = context.Request.QueryString["mcid"] ?? "";
        string currentPageParam = context.Request.QueryString["page"] ?? "";

        int lid = 0, mid = 0, mcid = 0;
        int.TryParse(lidStr, out lid);
        int.TryParse(midStr, out mid);
        int.TryParse(mcidStr, out mcid);

        if (lid <= 0)
        {
            if (isJson)
                context.Response.Write("{\"error\":\"请提供lid参数, 例: task-type-debug.ashx?lid=40&mid=27&mcid=9\"}");
            else
                WriteHtml(context, "请提供lid参数", "例如: task-type-debug.ashx?lid=40&mid=27&mcid=9", "");
            return;
        }

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr))
        {
            if (isJson)
                context.Response.Write("{\"error\":\"无法获取数据库连接字符串\"}");
            else
                WriteHtml(context, "错误", "无法获取数据库连接字符串", "");
            return;
        }

        // 查询数据库
        string dbLtype = "", dbLxid = "", dbLcid = "", dbLtitle = "";
        string missionTitle = "", missionMfiletype = "";
        bool hasSurveyData = false;
        string error = "";

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. Listmenu
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Lid, Lxid, Ltype, Ltitle, Lcid FROM Listmenu WHERE Lid=@Lid", conn))
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
                        }
                        else
                        {
                            error = "Listmenu中未找到Lid=" + lid;
                        }
                    }
                }

                int lxid = 0;
                int.TryParse(dbLxid, out lxid);

                // 2. Mission
                if (lxid > 0)
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Mid, Mtitle, Mfiletype FROM Mission WHERE Mid=@Mid", conn))
                    {
                        cmd.Parameters.AddWithValue("@Mid", lxid);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                missionTitle = reader["Mtitle"] != DBNull.Value ? reader["Mtitle"].ToString() : "";
                                missionMfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString() : "";
                            }
                        }
                    }

                    // 3. 检查SurveyQuestion
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT TOP 1 1 FROM SurveyQuestion WHERE Qvid=@Qvid", conn))
                    {
                        cmd.Parameters.AddWithValue("@Qvid", lxid);
                        object obj = cmd.ExecuteScalar();
                        hasSurveyData = (obj != null && obj != DBNull.Value);
                    }
                }

                // 归一化
                string normalizedLtype = NormalizeLtype(dbLtype);
                string mcidForOverride = mcid > 0 ? mcid.ToString() : dbLcid;
                try { normalizedLtype = StudentRouteFixHelper.ApplyKnownLtypeOverrides(normalizedLtype, lid, mcidForOverride); }
                catch { }

                // 调查问卷纠偏
                if ((normalizedLtype == "1" || normalizedLtype == "2" || normalizedLtype == "3") && hasSurveyData)
                    normalizedLtype = "14";

                string ltypeName = GetLtypeName(normalizedLtype);
                int courseId = mcid > 0 ? mcid : 0;
                if (courseId <= 0) int.TryParse(dbLcid, out courseId);
                int lxidForUrl = lxid > 0 ? lxid : 0;

                // 计算页面
                string studentPage = GetStudentPage(normalizedLtype, lid, lxidForUrl, courseId);
                string teacherPage = GetTeacherPage(normalizedLtype, lid, lxidForUrl, courseId);

                // 页面存在性检查
                string studentPageFile = studentPage.Split('?')[0];
                string teacherPageFile = teacherPage.Split('?')[0];
                bool studentExists = System.IO.File.Exists(context.Server.MapPath("~/student/" + studentPageFile));
                bool teacherExists = System.IO.File.Exists(context.Server.MapPath("~/teacher/" + teacherPageFile));

                // 检测当前页面是否匹配
                string currentPageMismatch = "";
                if (!string.IsNullOrEmpty(currentPageParam))
                {
                    string expectedPage = studentPageFile.Replace(".aspx", "").ToLower();
                    string actual = currentPageParam.ToLower().Replace(".aspx", "");
                    if (actual != expectedPage)
                        currentPageMismatch = "当前页面 " + currentPageParam + " 与正确页面 " + studentPageFile + " 不匹配!";
                }

                if (isJson)
                {
                    StringBuilder json = new StringBuilder();
                    json.Append("{");
                    json.AppendFormat("\"lid\":{0},", lid);
                    json.AppendFormat("\"mid\":{0},", mid);
                    json.AppendFormat("\"mcid\":{0},", mcid);
                    json.AppendFormat("\"dbLtype\":{0},", JsonStr(dbLtype));
                    json.AppendFormat("\"dbLxid\":{0},", JsonStr(dbLxid));
                    json.AppendFormat("\"dbLcid\":{0},", JsonStr(dbLcid));
                    json.AppendFormat("\"dbLtitle\":{0},", JsonStr(dbLtitle));
                    json.AppendFormat("\"missionTitle\":{0},", JsonStr(missionTitle));
                    json.AppendFormat("\"missionMfiletype\":{0},", JsonStr(missionMfiletype));
                    json.AppendFormat("\"hasSurveyData\":{0},", hasSurveyData ? "true" : "false");
                    json.AppendFormat("\"normalizedLtype\":{0},", JsonStr(normalizedLtype));
                    json.AppendFormat("\"ltypeName\":{0},", JsonStr(ltypeName));
                    json.AppendFormat("\"studentPage\":{0},", JsonStr(studentPage));
                    json.AppendFormat("\"teacherPage\":{0},", JsonStr(teacherPage));
                    json.AppendFormat("\"studentPageExists\":{0},", studentExists ? "true" : "false");
                    json.AppendFormat("\"teacherPageExists\":{0},", teacherExists ? "true" : "false");
                    json.AppendFormat("\"currentPageMismatch\":{0},", JsonStr(currentPageMismatch));
                    json.AppendFormat("\"error\":{0}", JsonStr(error));
                    json.Append("}");
                    context.Response.Write(json.ToString());
                }
                else
                {
                    StringBuilder body = new StringBuilder();
                    body.Append("<h2>任务类型诊断 (Lid=" + lid + ")</h2>");

                    // 数据库信息
                    body.Append("<div class='section'>");
                    body.Append("<h3>📋 数据库信息</h3>");
                    body.Append("<div class='row'><span class='label'>Lid:</span><span class='value'>" + lid + "</span></div>");
                    body.Append("<div class='row'><span class='label'>Ltitle:</span><span class='value'>" + S(context, dbLtitle) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>Ltype (原始):</span><span class='value highlight'>" + S(context, dbLtype) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>Lxid:</span><span class='value'>" + S(context, dbLxid) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>Lcid:</span><span class='value'>" + S(context, dbLcid) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>Mission.Mtitle:</span><span class='value'>" + S(context, missionTitle) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>Mission.Mfiletype:</span><span class='value'>" + S(context, missionMfiletype) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>有调查问卷数据:</span><span class='value'>" + (hasSurveyData ? "✅ 是" : "❌ 否") + "</span></div>");
                    body.Append("</div>");

                    // 类型归一化
                    body.Append("<div class='section'>");
                    body.Append("<h3>🔄 类型归一化</h3>");
                    body.Append("<div class='row'><span class='label'>原始 Ltype:</span><span class='value'>" + S(context, dbLtype) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>归一化 Ltype:</span><span class='value highlight'>" + S(context, normalizedLtype) + "</span></div>");
                    body.Append("<div class='row'><span class='label'>类型名称:</span><span class='value highlight'>" + S(context, ltypeName) + "</span></div>");
                    body.Append("</div>");

                    // 页面映射
                    body.Append("<div class='section'>");
                    body.Append("<h3>🔗 页面映射</h3>");
                    string sClass = studentExists ? "ok" : "err";
                    string tClass = teacherExists ? "ok" : "err";
                    body.Append("<div class='row'><span class='label'>学生端页面:</span><span class='value " + sClass + "'>"
                        + S(context, "student/" + studentPage) + (studentExists ? " ✅" : " ❌ 文件不存在!") + "</span></div>");
                    body.Append("<div class='row'><span class='label'>教师端页面:</span><span class='value " + tClass + "'>"
                        + S(context, "teacher/" + teacherPage) + (teacherExists ? " ✅" : " ❌ 文件不存在!") + "</span></div>");

                    if (!string.IsNullOrEmpty(currentPageMismatch))
                    {
                        body.Append("<div class='alert'>" + S(context, currentPageMismatch) + "</div>");
                    }
                    body.Append("</div>");

                    // 完整类型映射表
                    body.Append("<div class='section'>");
                    body.Append("<h3>📑 完整类型映射表</h3>");
                    body.Append("<div style='font-size:12px;line-height:2;'>");
                    string[] types = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15" };
                    foreach (string t in types)
                    {
                        string mark = (t == normalizedLtype) ? " <b style='color:#dc2626;'>← 当前任务</b>" : "";
                        body.Append(t + "=" + GetLtypeName(t)
                            + " → 学生:" + GetStudentPage(t, 0, 0, 0).Split('?')[0]
                            + " / 教师:" + GetTeacherPage(t, 0, 0, 0).Split('?')[0]
                            + mark + "<br/>");
                    }
                    body.Append("</div>");
                    body.Append("</div>");

                    if (!string.IsNullOrEmpty(error))
                    {
                        body.Append("<div class='alert'>" + S(context, error) + "</div>");
                    }

                    WriteHtml(context, "任务类型诊断", "", body.ToString());
                }
            }
        }
        catch (Exception ex)
        {
            if (isJson)
                context.Response.Write("{\"error\":" + JsonStr("异常: " + ex.Message) + "}");
            else
                WriteHtml(context, "异常", ex.Message, "<pre>" + context.Server.HtmlEncode(ex.StackTrace) + "</pre>");
        }
    }

    private void WriteHtml(HttpContext ctx, string title, string subtitle, string body)
    {
        ctx.Response.Write(@"<!DOCTYPE html><html><head><meta charset='utf-8'><title>任务类型调试</title>
<style>
body{font-family:'Segoe UI','Microsoft YaHei',sans-serif;max-width:800px;margin:20px auto;padding:0 16px;color:#1e293b;background:#f8fafc;}
h2{color:#0f172a;border-bottom:2px solid #3b82f6;padding-bottom:8px;}
h3{color:#1e40af;margin:12px 0 8px;}
.section{background:#fff;border:1px solid #e2e8f0;border-radius:10px;padding:16px;margin:12px 0;}
.row{display:flex;padding:4px 0;border-bottom:1px dotted #e2e8f0;}
.label{width:180px;font-weight:600;color:#475569;flex-shrink:0;}
.value{color:#0f172a;}
.value.highlight{font-weight:700;color:#7c3aed;font-size:15px;}
.value.ok{color:#059669;}
.value.err{color:#dc2626;font-weight:700;}
.alert{margin:10px 0;padding:10px 14px;background:#fef2f2;border:1px solid #fca5a5;border-radius:8px;color:#dc2626;font-weight:700;}
pre{background:#f1f5f9;padding:12px;border-radius:6px;overflow-x:auto;font-size:12px;}
</style></head><body>");
        ctx.Response.Write("<h2>" + ctx.Server.HtmlEncode(title) + "</h2>");
        if (!string.IsNullOrEmpty(subtitle))
            ctx.Response.Write("<p>" + ctx.Server.HtmlEncode(subtitle) + "</p>");
        ctx.Response.Write(body);
        ctx.Response.Write("</body></html>");
    }

    private string S(HttpContext ctx, string val) { return ctx.Server.HtmlEncode(val ?? ""); }

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

    private string GetStudentPage(string ltype, int lid, int lxid, int courseId)
    {
        switch (ltype)
        {
            case "1": case "2": case "3":
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "4":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "5":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "6":
                return string.Format("console.aspx?lid={0}", lid);
            case "7":
                return string.Format("mxgraph.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "8":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "9":
                return string.Format("htmledit.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "10":
                return string.Format("kitymind.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "11":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "12":
                return string.Format("ware.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
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

    private string GetTeacherPage(string ltype, int lid, int lxid, int courseId)
    {
        switch (ltype)
        {
            case "1": case "3":
                return string.Format("missionshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "2":
                return string.Format("topicshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "4":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "5":
                return string.Format("pythonshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "6":
                return string.Format("consoleshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "7":
                return string.Format("graphshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "8":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "9":
                return string.Format("htmlshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "10":
                return string.Format("kitymindshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "11":
                return string.Format("excelshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "12":
                return string.Format("ware.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "13":
                return string.Format("topicshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "14":
                return string.Format("missionshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "15":
                return string.Format("txtformshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            default:
                return string.Format("missionshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
        }
    }

    private string JsonStr(string val)
    {
        if (val == null) return "null";
        return "\"" + val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n").Replace("\t", "\\t") + "\"";
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
