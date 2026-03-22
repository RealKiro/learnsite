using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;

public partial class Student_showcourse : System.Web.UI.Page
{
    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 111 && lcid == 16) return "8";
        if (lid == 23 && lcid == 5) return "14";
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5";
        if (lid == 47 && lcid == 9) return "6";
        if (lid == 48 && lcid == 9) return "8";
        if (lid == 49 && lcid == 9) return "9";
        if (lid == 46 && lcid == 10) return "4";
        if (lid == 53 && lcid == 11) return "4";
        if (lid == 58 && lcid == 12) return "4";
        // if (lid == 61 && lcid == 12) return "7"; // 撤销错误硬编码
        if (lid == 85 && lcid == 12) return "10";
        return normalized;
    }
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

    private string CorrectLtypeByData(string ltype, int lid, int lcid, int lxid, bool isSurvey, bool isTopic, bool isTxtForm)
    {
        string normalized = NormalizeLtype(ltype);
        normalized = ApplyKnownLtypeOverrides(normalized, lid, lcid);
        // 对 Ltype 1-9 的任务做纠偏，避免 Listmenu.Ltype 错误配置时路由错误
        int nType;
        if (int.TryParse(normalized, out nType) && nType >= 1 && nType <= 9)
        {
            if (isSurvey) return "14";
            if (isTopic) return "13";
            if (isTxtForm) return "15";
        }
        return normalized;
    }
    // 控件引用
    private HtmlGenericControl _courseName;
    private HtmlGenericControl _courseTeacher;
    private HtmlGenericControl _taskCount;
    private HtmlGenericControl _taskCompleted;
    private HtmlGenericControl _taskTotal;
    private HtmlGenericControl _progressBar;
    private HtmlGenericControl _progressText;
    private HtmlGenericControl _progressTextBadge;
    private HtmlGenericControl _courseTasks;
    private HtmlGenericControl _ccontent;
    private Label _labelCtitle;
    
    // 递归查找控件
    private Control FindControlRecursive(Control root, string id)
    {
        if (root == null) return null;
        
        if (root.ID == id)
            return root;
        
        foreach (Control child in root.Controls)
        {
            Control found = FindControlRecursive(child, id);
            if (found != null)
                return found;
        }
        
        return null;
    }
    
    // 初始化控件引用 - 在 Load 阶段查找，确保控件树已完全构建
    private void InitializeControls()
    {
        System.Diagnostics.Debug.WriteLine("=== InitializeControls 开始 ===");
        
        // 在 Load 阶段查找控件，此时控件树已完全构建
        _courseName = FindControlRecursive(this, "courseName") as HtmlGenericControl;
        _courseTeacher = FindControlRecursive(this, "courseTeacher") as HtmlGenericControl;
        _taskCount = FindControlRecursive(this, "taskCount") as HtmlGenericControl;
        _taskCompleted = FindControlRecursive(this, "taskCompleted") as HtmlGenericControl;
        _taskTotal = FindControlRecursive(this, "taskTotal") as HtmlGenericControl;
        _progressBar = FindControlRecursive(this, "progressBar") as HtmlGenericControl;
        _progressText = FindControlRecursive(this, "progressText") as HtmlGenericControl;
        _progressTextBadge = FindControlRecursive(this, "progressTextBadge") as HtmlGenericControl;
        _courseTasks = FindControlRecursive(this, "courseTasks") as HtmlGenericControl;
        _ccontent = FindControlRecursive(this, "Ccontent") as HtmlGenericControl;
        _labelCtitle = FindControlRecursive(this, "LabelCtitle") as Label;
        
        System.Diagnostics.Debug.WriteLine("courseName: " + (_courseName != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("courseTeacher: " + (_courseTeacher != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("taskCount: " + (_taskCount != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("progressBar: " + (_progressBar != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("progressText: " + (_progressText != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("courseTasks: " + (_courseTasks != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("Ccontent: " + (_ccontent != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("LabelCtitle: " + (_labelCtitle != null ? "找到" : "未找到"));
        System.Diagnostics.Debug.WriteLine("=== InitializeControls 完成 ===");
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        System.Diagnostics.Debug.WriteLine("=== Page_Load 开始 ===");
        
        // 在 Load 阶段初始化控件引用
        InitializeControls();
        
        if (!IsPostBack)
        {
            try
            {
                LoadCourseInfo();
                LoadCourseContent();
                LoadCourseTasks();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Page_Load Error: " + ex.ToString());
                
                // 直接写入响应以显示错误
                if (_ccontent != null)
                {
                    _ccontent.InnerHtml = string.Format(
                        @"<div style='color: red; padding: 20px; border: 2px solid red; background: #fee;'>
                            <h3>页面加载错误</h3>
                            <p>{0}</p>
                            <pre style='font-size: 11px; overflow: auto;'>{1}</pre>
                        </div>",
                        Server.HtmlEncode(ex.Message),
                        Server.HtmlEncode(ex.StackTrace)
                    );
                }
            }
        }
        
        System.Diagnostics.Debug.WriteLine("=== Page_Load 结束 ===");
    }
    
    private void LoadCourseInfo()
    {
        string cid = Request.QueryString["cid"];
        
        System.Diagnostics.Debug.WriteLine("LoadCourseInfo 开始, cid=" + (cid ?? "null"));
        
        if (string.IsNullOrEmpty(cid))
        {
            SetErrorInfo("未提供课程ID参数");
            return;
        }
        
        int courseId;
        if (!int.TryParse(cid, out courseId))
        {
            SetErrorInfo("无效的课程ID: " + cid);
            return;
        }
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            System.Diagnostics.Debug.WriteLine("数据库连接字符串获取成功");
        }
        catch (Exception ex)
        {
            SetErrorInfo("数据库配置错误: " + ex.Message);
            return;
        }
        
        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;
        
        try
        {
            conn = new SqlConnection(connectionString);
            conn.Open();
            System.Diagnostics.Debug.WriteLine("数据库连接成功");
            
            string sql = @"
                SELECT C.Cid, C.Ctitle, C.Chid, C.Cbanner, T.Hname as TeacherName
                FROM Courses C
                LEFT JOIN Teacher T ON C.Chid = T.Hid
                WHERE C.Cid = @Cid AND (C.Cdelete = 0 OR C.Cdelete IS NULL)
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Cid", courseId);
            
            reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                string courseNameValue = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "未命名课程";
                string teacherName = reader["TeacherName"] != DBNull.Value ? reader["TeacherName"].ToString() : "未指定";
                string bannerPath = reader["Cbanner"] != DBNull.Value ? reader["Cbanner"].ToString() : "";
                
                System.Diagnostics.Debug.WriteLine("查询到课程: " + courseNameValue + ", 教师: " + teacherName);
                
                // 设置背景图片
                HtmlGenericControl bannerWrapper = FindControlRecursive(this, "CourseBannerWrapper") as HtmlGenericControl;
                if (bannerWrapper != null && !string.IsNullOrEmpty(bannerPath))
                {
                    string bannerUrl = bannerPath.Trim();
                    if (!bannerUrl.StartsWith("http://") && !bannerUrl.StartsWith("https://") && !bannerUrl.StartsWith("/"))
                    {
                        if (!bannerUrl.StartsWith("~/"))
                            bannerUrl = "~/" + bannerUrl;
                        bannerUrl = ResolveUrl(bannerUrl);
                    }
                    bannerWrapper.Style["background-image"] = "url('" + bannerUrl + "')";
                    bannerWrapper.Attributes["class"] = "course-banner-wrapper has-bg";
                }
                else if (bannerWrapper != null)
                {
                    // 如果没有背景图，保持默认渐变背景
                    bannerWrapper.Attributes["class"] = "course-banner-wrapper";
                }
                
                reader.Close();
                cmd.Dispose();
                
                // 查询任务数量
                int taskCountValue = 0;
                string taskSql = @"
                    SELECT COUNT(*) as TaskCount
                    FROM Listmenu
                    WHERE Lcid = @Lcid AND (lshow IS NULL OR CONVERT(nvarchar(10), lshow) IN ('1','True','true'))
                ";
                
                cmd = new SqlCommand(taskSql, conn);
                cmd.Parameters.AddWithValue("@Lcid", courseId);
                object taskResult = cmd.ExecuteScalar();
                if (taskResult != null && taskResult != DBNull.Value)
                {
                    taskCountValue = Convert.ToInt32(taskResult);
                }
                cmd.Dispose();
                
                System.Diagnostics.Debug.WriteLine("任务数量: " + taskCountValue);
                
                // 查询学习进度
                int completedTasks = 0;
                string studentNum = Session["Snum"] != null ? Session["Snum"].ToString() : "";
                
                if (!string.IsNullOrEmpty(studentNum))
                {
                    string progressSql = @"
                        SELECT COUNT(DISTINCT L.Lid) as CompletedCount
                        FROM Listmenu L
                        INNER JOIN Summary S ON L.Lid = S.Slid
                        WHERE L.Lcid = @Lcid 
                        AND (L.lshow IS NULL OR CONVERT(nvarchar(10), L.lshow) IN ('1','True','true'))
                        AND S.Snum = @Snum
                        AND (S.Sshow = 1 OR S.Sshow IS NULL)
                    ";
                    
                    cmd = new SqlCommand(progressSql, conn);
                    cmd.Parameters.AddWithValue("@Lcid", courseId);
                    cmd.Parameters.AddWithValue("@Snum", studentNum);
                    object progressResult = cmd.ExecuteScalar();
                    if (progressResult != null && progressResult != DBNull.Value)
                    {
                        completedTasks = Convert.ToInt32(progressResult);
                    }
                    cmd.Dispose();
                }
                
                int progressPercent = 0;
                if (taskCountValue > 0)
                {
                    // 使用更精确的计算方式，确保进度准确
                    double progress = (double)completedTasks / (double)taskCountValue;
                    progressPercent = (int)Math.Round(progress * 100.0, MidpointRounding.AwayFromZero);
                    // 确保进度在0-100范围内
                    if (progressPercent < 0) progressPercent = 0;
                    if (progressPercent > 100) progressPercent = 100;
                }
                else
                {
                    // 如果没有任务，进度为0
                    progressPercent = 0;
                }
                
                System.Diagnostics.Debug.WriteLine("进度计算: 已完成=" + completedTasks + ", 总任务=" + taskCountValue + ", 百分比=" + progressPercent + "%");
                
                // 更新控件
                if (_courseName != null)
                {
                    _courseName.InnerText = courseNameValue;
                    System.Diagnostics.Debug.WriteLine("✓ 更新 courseName: " + courseNameValue);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ courseName 控件为 null");
                }
                
                if (_courseTeacher != null)
                {
                    _courseTeacher.InnerText = teacherName;
                    System.Diagnostics.Debug.WriteLine("✓ 更新 courseTeacher: " + teacherName);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ courseTeacher 控件为 null");
                }
                
                if (_taskCount != null)
                {
                    _taskCount.InnerText = taskCountValue.ToString();
                    System.Diagnostics.Debug.WriteLine("✓ 更新 taskCount: " + taskCountValue);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ taskCount 控件为 null");
                }
                
                // 更新已完成任务数
                if (_taskCompleted != null)
                {
                    _taskCompleted.InnerText = completedTasks.ToString();
                    System.Diagnostics.Debug.WriteLine("✓ 更新 taskCompleted: " + completedTasks);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ taskCompleted 控件为 null");
                }
                
                // 更新总任务数
                if (_taskTotal != null)
                {
                    _taskTotal.InnerText = taskCountValue.ToString();
                    System.Diagnostics.Debug.WriteLine("✓ 更新 taskTotal: " + taskCountValue);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ taskTotal 控件为 null");
                }
                
                if (_progressBar != null)
                {
                    _progressBar.Style["width"] = progressPercent + "%";
                    System.Diagnostics.Debug.WriteLine("✓ 更新 progressBar: " + progressPercent + "%");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ progressBar 控件为 null");
                }
                
                if (_progressText != null)
                {
                    _progressText.InnerText = progressPercent + "%";
                    System.Diagnostics.Debug.WriteLine("✓ 更新 progressText: " + progressPercent + "%");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ progressText 控件为 null");
                }
                
                if (_progressTextBadge != null)
                {
                    _progressTextBadge.InnerText = progressPercent + "%";
                    System.Diagnostics.Debug.WriteLine("✓ 更新 progressTextBadge: " + progressPercent + "%");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ progressTextBadge 控件为 null");
                }
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("未找到课程记录");
                SetErrorInfo("未找到课程记录");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadCourseInfo Error: " + ex.ToString());
            SetErrorInfo("加载课程信息时出错: " + ex.Message);
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }
    
    private void SetErrorInfo(string message)
    {
        if (_courseName != null)
            _courseName.InnerText = "[加载失败: " + message + "]";
        
        if (_courseTeacher != null)
            _courseTeacher.InnerText = "[加载失败]";
        
        if (_taskCount != null)
            _taskCount.InnerText = "[加载失败]";
        
        if (_taskCompleted != null)
            _taskCompleted.InnerText = "0";
        
        if (_taskTotal != null)
            _taskTotal.InnerText = "0";
        
        System.Diagnostics.Debug.WriteLine("SetErrorInfo: " + message);
    }
    
    private void LoadCourseContent()
    {
        string cid = Request.QueryString["cid"];
        
        if (string.IsNullOrEmpty(cid))
        {
            ShowError("未提供课程ID参数");
            return;
        }
        
        int courseId;
        if (!int.TryParse(cid, out courseId))
        {
            ShowError("无效的课程ID");
            return;
        }
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch (Exception ex)
        {
            ShowError("数据库配置错误: " + ex.Message);
            return;
        }
        
        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;
        
        try
        {
            conn = new SqlConnection(connectionString);
            conn.Open();
            
            string sql = @"
                SELECT Cid, Ctitle, Ccontent 
                FROM Courses 
                WHERE Cid = @Cid AND (Cdelete = 0 OR Cdelete IS NULL)
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Cid", courseId);
            
            reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                string title = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "未命名课程";
                string content = reader["Ccontent"] != DBNull.Value ? reader["Ccontent"].ToString() : "";
                
                System.Diagnostics.Debug.WriteLine("课程标题: " + title);
                System.Diagnostics.Debug.WriteLine("课程内容长度: " + content.Length);
                
                if (_labelCtitle != null)
                {
                    _labelCtitle.Text = title;
                    System.Diagnostics.Debug.WriteLine("✓ 更新 LabelCtitle: " + title);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ LabelCtitle 控件为 null");
                }
                
                if (_ccontent != null)
                {
                    if (string.IsNullOrEmpty(content))
                    {
                        _ccontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>暂无课程内容</div>";
                    }
                    else
                    {
                        _ccontent.InnerHtml = content;
                    }
                    System.Diagnostics.Debug.WriteLine("✓ 更新 Ccontent");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("✗ Ccontent 控件为 null");
                }
                
                Page.Title = title;
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("未找到课程内容记录");
                ShowError("未找到课程记录");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadCourseContent Error: " + ex.ToString());
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
        string cid = Request.QueryString["cid"];
        
        if (string.IsNullOrEmpty(cid))
        {
            return;
        }
        
        int courseId;
        if (!int.TryParse(cid, out courseId))
        {
            return;
        }
        
        if (_courseTasks == null)
        {
            System.Diagnostics.Debug.WriteLine("✗ courseTasks 控件为 null");
            return;
        }
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch (Exception ex)
        {
            _courseTasks.InnerHtml = @"<div class=""tasks-empty""><div class=""tasks-empty-icon"">⚠️</div><div class=""tasks-empty-text"" style=""color: #f44336;"">数据库配置错误</div></div>";
            System.Diagnostics.Debug.WriteLine("LoadCourseTasks ConnectionString Error: " + ex.Message);
            return;
        }
        
        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;
        
        try
        {
            conn = new SqlConnection(connectionString);
            conn.Open();
            
            string sql = @"
                SELECT L.Lid, L.Lxid, L.Ltype, L.Ltitle, M.Mfiletype, M.Msort,
                       CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion SQ WHERE SQ.Qvid = L.Lxid AND SQ.Qcid = L.Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                       CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss TD WHERE TD.Tid = L.Lxid AND TD.Tcid = L.Lcid) THEN 1 ELSE 0 END AS IsTopic,
                       CASE WHEN EXISTS(SELECT 1 FROM TxtForm TF WHERE TF.Mid = L.Lxid AND TF.Mcid = L.Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                FROM Listmenu L
                LEFT JOIN Mission M ON M.Mid = L.Lxid
                WHERE L.Lcid = @Lcid AND (L.lshow IS NULL OR CONVERT(nvarchar(10), L.lshow) IN ('1','True','true'))
                ORDER BY L.Lsort
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lcid", courseId);
            
            reader = cmd.ExecuteReader();
            
            StringBuilder html = new StringBuilder();
            int count = 0;
            
            while (reader.Read())
            {
                count++;
                int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString() : "0";
                string mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim().ToLower() : "";
                string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                bool isSurvey = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                bool isTopic = reader["IsTopic"] != DBNull.Value && Convert.ToInt32(reader["IsTopic"]) == 1;
                bool isTxtForm = reader["IsTxtForm"] != DBNull.Value && Convert.ToInt32(reader["IsTxtForm"]) == 1;
                ltype = CorrectLtypeByData(ltype, lid, courseId, lxid, isSurvey, isTopic, isTxtForm);
                if (IsPixelAddProgramSubtype(msort)) ltype = "8";
                if (mfiletype == "km" || mfiletype == "mm" || mfiletype == "mindmap" || mfiletype == "kitymind") ltype = "10";
                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "未命名任务";
                
                // 获取任务类型名称
                string taskTypeName = GetTaskTypeName(ltype);
                
                // 生成任务URL
                string url = GetTaskUrl(ltype, lid, lxid, courseId);
                
                // 根据任务类型选择图标样式类
                string iconClass = GetTaskIconClass(ltype);
                
                // 根据任务类型选择图标SVG
                string iconSvg = GetTaskIconSvg(ltype);
                
                html.AppendFormat(
                    @"<a href=""{0}"" class=""task-item"">
                        <div class=""task-item-number"">{5}</div>
                        <div class=""task-item-content"">
                            <div class=""task-item-title"">{3}</div>
                            <div class=""sc-task-type type-{1}"">
                                {2}
                                <span>{4}</span>
                            </div>
                        </div>
                    </a>",
                    url,
                    iconClass,
                    iconSvg,
                    Server.HtmlEncode(ltitle),
                    Server.HtmlEncode(taskTypeName),
                    count
                );
            }
            
            System.Diagnostics.Debug.WriteLine("找到 " + count + " 个任务");
            
            if (count == 0)
            {
                _courseTasks.InnerHtml = @"<div class=""tasks-empty""><div class=""tasks-empty-icon"">📋</div><div class=""tasks-empty-text"">暂无课程任务</div></div>";
            }
            else
            {
                _courseTasks.InnerHtml = html.ToString();
            }
            
            System.Diagnostics.Debug.WriteLine("✓ 更新 courseTasks");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadCourseTasks Error: " + ex.ToString());
            _courseTasks.InnerHtml = @"<div class=""tasks-empty""><div class=""tasks-empty-icon"">⚠️</div><div class=""tasks-empty-text"" style=""color: #f44336;"">加载任务列表失败: " + Server.HtmlEncode(ex.Message) + "</div></div>";
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }
    
    private void ShowError(string message)
    {
        if (_labelCtitle != null)
        {
            _labelCtitle.Text = "加载错误";
        }
        
        if (_ccontent != null)
        {
            _ccontent.InnerHtml = string.Format(
                @"<div style='padding: 20px; background: #fee2e2; border: 1px solid #fca5a5; border-radius: 8px; color: #991b1b;'>
                    <h3>⚠️ 错误</h3>
                    <p>{0}</p>
                </div>",
                Server.HtmlEncode(message)
            );
        }
    }
    
    // 获取任务类型名称（同时支持数字编码和中文类型）
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
    
    // 获取任务URL（与教师端taskredirect.ashx保持一致）
    private string GetTaskUrl(string ltype, int lid, int lxid, int courseId)
    {
        ltype = ApplyKnownLtypeOverrides(NormalizeLtype(ltype), lid, courseId);
        switch (ltype)
        {
            case "1": case "活动":
            case "2": case "主题":
            case "3": case "练习":
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "4": case "积木": case "积木编程":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "5": case "Python":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "6": case "测评":
                return string.Format("console.aspx?lid={0}", lid);
            case "7": case "流程": case "流程图":
                return string.Format("graphshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "8": case "应用": case "像素": case "拼图": case "图片": case "图像画":
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "9": case "Html": case "网页":
                return string.Format("htmlshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "10": case "导图": case "脑图":
                return string.Format("kitymind.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "11": case "表格":
                return string.Format("excel.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "12": case "课件":
                return string.Format("ware.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            case "13": case "讨论":
                return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, courseId);
            case "14": case "调查":
                return string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, courseId);
            case "15": case "填表":
                return string.Format("txtform.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
            default:
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
        }
    }
    
    // 获取任务图标样式类（支持数字和中文类型）
    private string GetTaskIconClass(string ltype)
    {
        ltype = NormalizeLtype(ltype);
        switch (ltype)
        {
            case "1": case "活动": return "code";
            case "2": case "主题": return "code";
            case "3": case "练习": return "survey";
            case "4": case "积木": case "积木编程": return "code";
            case "5": case "Python": return "code";
            case "6": case "测评": return "survey";
            case "7": case "流程": case "流程图": return "flow";
            case "8": case "应用": case "像素": case "拼图": return "code";
            case "9": case "Html": case "网页": return "html";
            case "10": case "导图": case "脑图": return "mind";
            case "11": case "表格": return "excel";
            case "12": case "课件": return "ware";
            case "13": case "讨论": return "discuss";
            case "14": case "调查": return "survey";
            case "15": case "填表": return "form";
            default: return "code";
        }
    }
    
    // 获取任务图标SVG（支持数字和中文类型）
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
                return @"<svg viewBox=""0 0 24 24""><path d=""M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z""/><polyline points=""14 2 14 8 20 8""/><line x1=""12"" y1=""18"" x2=""12"" y2=""12""/><line x1=""9"" y1=""15"" x2=""15"" y2=""15""/></svg>";
        }
    }
    
    // 将中文类型名称统一转换为数字编码
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
            case "Python":
            case "python":
            case "代码":
            case "仓库":
                return "5";
            case "测评": return "6";
            case "测试":
            case "lxc":
                return "6";
            case "流程":
            case "流程图":
                return "7";
            case "应用":
            case "像素":
            case "拼图":
            case "绘图":
            case "图片":
            case "图像画":
            case "yy":
                return "8";
            case "Html":
            case "html":
            case "网页":
                return "9";
            case "导图":
            case "脑图":
            case "daotu":
                return "10";
            case "表格": return "11";
            case "课件":
            case "kj":
                return "12";
            case "讨论": return "13";
            case "调查": return "14";
            case "填表": return "15";
            default: return ltype; // 已经是数字则原样返回
        }
    }
}
