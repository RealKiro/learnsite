using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;

public partial class Student_showcourse_fixed : System.Web.UI.Page
{
    protected string _taskTypeMapJson = "{}";

    private HtmlGenericControl _courseTasks;
    private HtmlGenericControl _ccontent;
    private Label _labelCtitle;

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch { }

        if (!string.IsNullOrEmpty(cs) &&
            cs.ToLower().IndexOf("connection timeout") < 0 &&
            cs.ToLower().IndexOf("connect timeout") < 0)
        {
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        }

        return cs;
    }

    private Control FindControlRecursive(Control root, string id)
    {
        if (root == null) return null;
        if (root.ID == id) return root;

        foreach (Control child in root.Controls)
        {
            Control found = FindControlRecursive(child, id);
            if (found != null) return found;
        }

        return null;
    }

    private void InitializeControls()
    {
        _courseTasks = FindControlRecursive(this, "courseTasks") as HtmlGenericControl;
        _ccontent = FindControlRecursive(this, "Ccontent") as HtmlGenericControl;
        _labelCtitle = FindControlRecursive(this, "LabelCtitle") as Label;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        InitializeControls();

        if (!IsPostBack)
        {
            LoadCourseContent();
            LoadCourseTasks();
        }
    }

    private bool TryGetCourseId(out int courseId)
    {
        courseId = 0;
        string cid = Request.QueryString["cid"];
        if (string.IsNullOrEmpty(cid)) return false;
        return int.TryParse(cid, out courseId);
    }

    private string NormalizeCourseContent(string content)
    {
        if (string.IsNullOrEmpty(content))
            return string.Empty;

        string normalized = content.Trim();

        for (int i = 0; i < 3; i++)
        {
            string decoded = HttpUtility.HtmlDecode(normalized);
            if (string.IsNullOrEmpty(decoded) || decoded == normalized)
                break;
            normalized = decoded;
        }

        if (normalized.IndexOf("&nbsp;", StringComparison.OrdinalIgnoreCase) >= 0)
            normalized = HttpUtility.HtmlDecode(normalized);

        return normalized;
    }

    private void LoadCourseContent()
    {
        int courseId;
        if (!TryGetCourseId(out courseId))
        {
            ShowError("未提供有效的课程ID参数");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            ShowError("数据库配置错误: 无法获取连接字符串");
            return;
        }

        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;

        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            string sql = @"
                SELECT Ctitle, Ccontent
                FROM Courses
                WHERE Cid = @Cid AND (Cdelete = 0 OR Cdelete IS NULL)
            ";

            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Cid", courseId);
            cmd.CommandTimeout = 10;

            reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                string title = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "未命名课程";
                string content = reader["Ccontent"] != DBNull.Value ? reader["Ccontent"].ToString() : "";

                if (_labelCtitle != null)
                    _labelCtitle.Text = title;

                if (_ccontent != null)
                {
                    if (string.IsNullOrEmpty(content) || content.Trim() == "")
                    {
                        _ccontent.InnerHtml = "<div style='text-align:center;padding:40px;color:#9ca3af;'>暂无课程内容</div>";
                    }
                    else
                    {
                        _ccontent.InnerHtml = NormalizeCourseContent(content);
                    }
                }

                Page.Title = title;
            }
            else
            {
                ShowError("未找到课程记录");
            }
        }
        catch (Exception ex)
        {
            ShowError("加载课程内容时出错: " + ex.Message);
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }

    private void LoadCourseTasks()
    {
        if (_courseTasks == null)
            return;

        int courseId;
        if (!TryGetCourseId(out courseId))
        {
            _courseTasks.InnerHtml = "<div class=\"course-tasks-empty\"><div class=\"course-tasks-empty-icon\">📋</div><div class=\"course-tasks-empty-text\">未提供课程ID</div></div>";
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            _courseTasks.InnerHtml = "<div class=\"course-tasks-empty\"><div class=\"course-tasks-empty-icon\">⚠️</div><div class=\"course-tasks-empty-text\" style=\"color:#f44336;\">数据库配置错误</div></div>";
            return;
        }

        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;

        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            string sql = @"
                SELECT L.Lid, L.Lxid, L.Ltype, L.Ltitle,
                       CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion SQ WHERE SQ.Qvid = L.Lxid AND SQ.Qcid = L.Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                       CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss TD WHERE TD.Tid = L.Lxid AND TD.Tcid = L.Lcid) THEN 1 ELSE 0 END AS IsTopic,
                       CASE WHEN EXISTS(SELECT 1 FROM TxtForm TF WHERE TF.Mid = L.Lxid AND TF.Mcid = L.Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                FROM Listmenu L
                WHERE L.Lcid = @Lcid AND (L.lshow IS NULL OR CONVERT(nvarchar(10), L.lshow) IN ('1','True','true'))
                ORDER BY L.Lsort
            ";

            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lcid", courseId);
            cmd.CommandTimeout = 10;

            reader = cmd.ExecuteReader();

            StringBuilder html = new StringBuilder();
            StringBuilder jsonMap = new StringBuilder();
            jsonMap.Append("{");
            int count = 0;
            bool firstJson = true;

            while (reader.Read())
            {
                count++;
                int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString() : "0";
                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "未命名任务";
                bool isSurvey = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                bool isTopic = reader["IsTopic"] != DBNull.Value && Convert.ToInt32(reader["IsTopic"]) == 1;
                bool isTxtForm = reader["IsTxtForm"] != DBNull.Value && Convert.ToInt32(reader["IsTxtForm"]) == 1;

                ltype = CorrectLtypeByData(ltype, lid, courseId, lxid, isSurvey, isTopic, isTxtForm);

                string taskTypeName = GetTaskTypeName(ltype);
                string taskTypeClass = GetTaskTypeClass(ltype);
                string url = GetTaskUrl(lid, lxid, courseId, ltype);
                string iconSvg = GetTaskIconSvg(ltype);

                if (!firstJson) jsonMap.Append(",");
                firstJson = false;
                jsonMap.AppendFormat("\"{0}\":{{\"n\":\"{1}\",\"t\":\"{2}\",\"u\":\"{3}\"}}",
                    lid,
                    taskTypeName.Replace("\"", "\\\""),
                    taskTypeClass,
                    url.Replace("\"", "\\\""));

                html.AppendFormat(
                    @"<a href=""{0}"" class=""course-task-item"">
                        <div class=""course-task-number"">{1}</div>
                        <div class=""course-task-icon type-{2}"">{3}</div>
                        <div class=""course-task-content"">
                            <div class=""course-task-title"">{4}</div>
                            <div class=""course-task-type"">{5}</div>
                        </div>
                    </a>",
                    url,
                    count,
                    taskTypeClass,
                    iconSvg,
                    Server.HtmlEncode(ltitle),
                    Server.HtmlEncode(taskTypeName));
            }

            jsonMap.Append("}");
            _taskTypeMapJson = jsonMap.ToString();

            if (count == 0)
            {
                _courseTasks.InnerHtml = "<div class=\"course-tasks-empty\"><div class=\"course-tasks-empty-icon\">📋</div><div class=\"course-tasks-empty-text\">暂无课程任务</div></div>";
            }
            else
            {
                _courseTasks.InnerHtml = html.ToString();
            }
        }
        catch (Exception ex)
        {
            _courseTasks.InnerHtml = "<div class=\"course-tasks-empty\"><div class=\"course-tasks-empty-icon\">⚠️</div><div class=\"course-tasks-empty-text\" style=\"color:#f44336;\">加载任务列表失败: " + Server.HtmlEncode(ex.Message) + "</div></div>";
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
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
            case "积木":
            case "积木编程": return "4";
            case "Python": return "5";
            case "测评": return "6";
            case "流程":
            case "流程图": return "7";
            case "应用":
            case "像素":
            case "拼图":
            case "绘图": return "8";
            case "Html":
            case "网页": return "9";
            case "导图":
            case "脑图": return "10";
            case "表格": return "11";
            case "课件": return "12";
            case "讨论": return "13";
            case "调查":
            case "调查问卷": return "14";
            case "填表": return "15";
            case "仓库":
            case "代码": return "5";
            default: return ltype;
        }
    }

    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 23 && lcid == 5) return "14";
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5";
        if (lid == 46 && lcid == 10) return "4";
        if (lid == 53 && lcid == 11) return "4";
        if (lid == 58 && lcid == 12) return "4";
        if (lid == 47 && lcid == 9) return "6";
        if (lid == 48 && lcid == 9) return "8";
        if (lid == 49 && lcid == 9) return "9";
        return normalized;
    }

    private string CorrectLtypeByData(string ltype, int lid, int lcid, int lxid, bool isSurvey, bool isTopic, bool isTxtForm)
    {
        string normalized = NormalizeLtype(ltype);
        normalized = ApplyKnownLtypeOverrides(normalized, lid, lcid);
        int nType;
        if (int.TryParse(normalized, out nType) && nType >= 1 && nType <= 12)
        {
            if (isSurvey) return "14";
            if (isTopic) return "13";
            if (isTxtForm) return "15";
        }
        return normalized;
    }

    private string GetTaskTypeName(string ltype)
    {
        ltype = NormalizeLtype(ltype);
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
            default: return "未知";
        }
    }

    private string GetTaskTypeClass(string ltype)
    {
        ltype = NormalizeLtype(ltype);
        switch (ltype)
        {
            case "1": return "code";
            case "2": return "code";
            case "3": return "survey";
            case "4": return "code";
            case "5": return "code";
            case "6": return "survey";
            case "7": return "flow";
            case "8": return "code";
            case "9": return "html";
            case "10": return "mind";
            case "11": return "excel";
            case "12": return "ware";
            case "13": return "discuss";
            case "14": return "survey";
            case "15": return "form";
            default: return "code";
        }
    }

    private string GetTaskUrl(int lid, int lxid, int courseId, string ltype)
    {
        ltype = NormalizeLtype(ltype);
        switch (ltype)
        {
            case "1":  // 活动
            case "3":  // 练习
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "2":  // 主题
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "4":  // 积木编程
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "5":  // Python
                return string.Format("pythonshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "6":  // 测评
                return string.Format("console.aspx?lid={0}", lid);
            case "7":  // 流程图
                return string.Format("graphshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "8":  // 应用
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "9":  // Html
                return string.Format("htmlshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "10": // 导图
                return string.Format("kitymindshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "11": // 表格
                return string.Format("excel.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "12": // 课件
                return string.Format("ware.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "13": // 讨论
                return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, courseId);
            case "14": // 调查
                return string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, courseId);
            default:
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
        }
    }

    private string GetTaskIconSvg(string ltype)
    {
        ltype = NormalizeLtype(ltype);
        switch (ltype)
        {
            case "1":
                return @"<svg viewBox=""0 0 24 24""><path d=""M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z""/><polyline points=""14 2 14 8 20 8""/><line x1=""12"" y1=""18"" x2=""12"" y2=""12""/><line x1=""9"" y1=""15"" x2=""15"" y2=""15""/></svg>";
            case "2":
                return @"<svg viewBox=""0 0 24 24""><path d=""M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z""/><path d=""M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z""/></svg>";
            case "3":
                return @"<svg viewBox=""0 0 24 24""><path d=""M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z""/><polyline points=""14 2 14 8 20 8""/><line x1=""16"" y1=""13"" x2=""8"" y2=""13""/><line x1=""16"" y1=""17"" x2=""8"" y2=""17""/><polyline points=""10 9 9 9 8 9""/></svg>";
            case "4":
                return @"<svg viewBox=""0 0 24 24""><rect x=""2"" y=""6"" width=""8"" height=""6"" rx=""1""/><rect x=""14"" y=""6"" width=""8"" height=""6"" rx=""1""/><rect x=""8"" y=""14"" width=""8"" height=""6"" rx=""1""/></svg>";
            case "5":
                return @"<svg viewBox=""0 0 24 24""><polyline points=""16 18 22 12 16 6""/><polyline points=""8 6 2 12 8 18""/><line x1=""14"" y1=""4"" x2=""10"" y2=""20""/></svg>";
            case "6":
                return @"<svg viewBox=""0 0 24 24""><rect x=""2"" y=""3"" width=""20"" height=""14"" rx=""2"" ry=""2""/><line x1=""8"" y1=""21"" x2=""16"" y2=""21""/><line x1=""12"" y1=""17"" x2=""12"" y2=""21""/></svg>";
            case "7":
                return @"<svg viewBox=""0 0 24 24""><path d=""M12 2L2 7l10 5 10-5-10-5z""/><path d=""M2 17l10 5 10-5""/><path d=""M2 12l10 5 10-5""/></svg>";
            case "8":
                return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""7"" height=""7""/><rect x=""14"" y=""3"" width=""7"" height=""7""/><rect x=""14"" y=""14"" width=""7"" height=""7""/><rect x=""3"" y=""14"" width=""7"" height=""7""/></svg>";
            case "9":
                return @"<svg viewBox=""0 0 24 24""><polyline points=""16 18 22 12 16 6""/><polyline points=""8 6 2 12 8 18""/></svg>";
            case "10":
                return @"<svg viewBox=""0 0 24 24""><circle cx=""12"" cy=""12"" r=""3""/><line x1=""12"" y1=""2"" x2=""12"" y2=""9""/><line x1=""12"" y1=""15"" x2=""12"" y2=""22""/><line x1=""2"" y1=""12"" x2=""9"" y2=""12""/><line x1=""15"" y1=""12"" x2=""22"" y2=""12""/></svg>";
            case "11":
                return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""18"" height=""18"" rx=""2"" ry=""2""/><line x1=""3"" y1=""9"" x2=""21"" y2=""9""/><line x1=""9"" y1=""3"" x2=""9"" y2=""21""/></svg>";
            case "12":
                return @"<svg viewBox=""0 0 24 24""><polygon points=""23 7 16 12 23 17 23 7""/><rect x=""1"" y=""5"" width=""15"" height=""14"" rx=""2"" ry=""2""/></svg>";
            case "13":
                return @"<svg viewBox=""0 0 24 24""><path d=""M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z""/></svg>";
            case "14":
                return @"<svg viewBox=""0 0 24 24""><path d=""M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2""/><rect x=""8"" y=""2"" width=""8"" height=""4"" rx=""1"" ry=""1""/></svg>";
            case "15":
                return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""18"" height=""18"" rx=""2"" ry=""2""/><line x1=""3"" y1=""9"" x2=""21"" y2=""9""/><line x1=""3"" y1=""15"" x2=""21"" y2=""15""/><line x1=""9"" y1=""3"" x2=""9"" y2=""21""/></svg>";
            default:
                return @"<svg viewBox=""0 0 24 24""><path d=""M9 11l3 3L22 4""/><path d=""M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11""/></svg>";
        }
    }

    private void ShowError(string message)
    {
        if (_labelCtitle != null)
            _labelCtitle.Text = "加载错误";

        if (_ccontent != null)
        {
            _ccontent.InnerHtml = string.Format(
                @"<div style='padding:20px;background:#fee2e2;border:1px solid #fca5a5;border-radius:8px;color:#991b1b;'>
                    <h3>⚠️ 错误</h3>
                    <p>{0}</p>
                </div>",
                Server.HtmlEncode(message));
        }
    }
}
