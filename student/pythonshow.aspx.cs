using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;

public partial class Student_pythonshow : System.Web.UI.Page
{
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
    private HtmlGenericControl _mcontent;
    
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
    
    // 初始化控件引用
    private void InitializeControls()
    {
        _courseName = FindControlRecursive(this, "courseName") as HtmlGenericControl;
        _courseTeacher = FindControlRecursive(this, "courseTeacher") as HtmlGenericControl;
        _taskCount = FindControlRecursive(this, "taskCount") as HtmlGenericControl;
        _taskCompleted = FindControlRecursive(this, "taskCompleted") as HtmlGenericControl;
        _taskTotal = FindControlRecursive(this, "taskTotal") as HtmlGenericControl;
        _progressBar = FindControlRecursive(this, "progressBar") as HtmlGenericControl;
        _progressText = FindControlRecursive(this, "progressText") as HtmlGenericControl;
        _progressTextBadge = FindControlRecursive(this, "progressTextBadge") as HtmlGenericControl;
        _courseTasks = FindControlRecursive(this, "courseTasks") as HtmlGenericControl;
        _mcontent = FindControlRecursive(this, "Mcontent") as HtmlGenericControl;
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // 初始化控件引用
        InitializeControls();
        
        if (!IsPostBack)
        {
            try
            {
                // 加载课程信息（左侧）
                LoadCourseInfo();
                LoadCourseTasks();
                
                // 加载Python任务内容
                LoadPythonMission();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Page_Load Error: " + ex.ToString());
            }
        }
    }
    
    // 加载课程信息（左侧）
    private void LoadCourseInfo()
    {
        string mcid = Request.QueryString["mcid"];
        
        if (string.IsNullOrEmpty(mcid))
        {
            SetErrorInfo("未提供课程ID参数");
            return;
        }
        
        int courseId;
        if (!int.TryParse(mcid, out courseId))
        {
            SetErrorInfo("无效的课程ID: " + mcid);
            return;
        }
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
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
            
            string sql = @"
                SELECT C.Cid, C.Ctitle, C.Chid, T.Hname as TeacherName
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
                
                reader.Close();
                cmd.Dispose();
                
                // 查询任务数量
                int taskCountValue = 0;
                string taskSql = @"
                    SELECT COUNT(*) as TaskCount
                    FROM Listmenu
                    WHERE Lcid = @Lcid AND (CONVERT(nvarchar(10), lshow) IN ('1','True','true'))
                ";
                
                cmd = new SqlCommand(taskSql, conn);
                cmd.Parameters.AddWithValue("@Lcid", courseId);
                object taskResult = cmd.ExecuteScalar();
                if (taskResult != null && taskResult != DBNull.Value)
                {
                    taskCountValue = Convert.ToInt32(taskResult);
                }
                cmd.Dispose();
                
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
                        AND (CONVERT(nvarchar(10), L.lshow) IN ('1','True','true'))
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
                    double progress = (double)completedTasks / (double)taskCountValue;
                    progressPercent = (int)Math.Round(progress * 100.0, MidpointRounding.AwayFromZero);
                    if (progressPercent < 0) progressPercent = 0;
                    if (progressPercent > 100) progressPercent = 100;
                }
                
                // 更新控件
                if (_courseName != null)
                    _courseName.InnerText = courseNameValue;
                
                if (_courseTeacher != null)
                    _courseTeacher.InnerText = teacherName;
                
                if (_taskCompleted != null)
                    _taskCompleted.InnerText = completedTasks.ToString();
                
                if (_taskTotal != null)
                    _taskTotal.InnerText = taskCountValue.ToString();
                
                if (_progressBar != null)
                    _progressBar.Style["width"] = progressPercent + "%";
                
                if (_progressText != null)
                    _progressText.InnerText = progressPercent + "%";
                
                if (_progressTextBadge != null)
                    _progressTextBadge.InnerText = progressPercent + "%";
            }
            else
            {
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
        
        if (_taskCompleted != null)
            _taskCompleted.InnerText = "0";
        
        if (_taskTotal != null)
            _taskTotal.InnerText = "0";
    }
    
    // 加载课程任务列表（左侧）
    private void LoadCourseTasks()
    {
        string mcid = Request.QueryString["mcid"];
        
        if (string.IsNullOrEmpty(mcid))
        {
            return;
        }
        
        int courseId;
        if (!int.TryParse(mcid, out courseId))
        {
            return;
        }
        
        if (_courseTasks == null)
        {
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
                SELECT Lid, Lxid, Ltype, Ltitle 
                FROM Listmenu 
                WHERE Lcid = @Lcid AND (CONVERT(nvarchar(10), lshow) IN ('1','True','true')) 
                ORDER BY Lsort
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
                        <div class=""task-item-icon {1}"">
                            {2}
                        </div>
                        <div class=""task-item-content"">
                            <div class=""task-item-title"">{3}</div>
                            <div class=""task-item-type"">{4}</div>
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
            
            if (count == 0)
            {
                _courseTasks.InnerHtml = @"<div class=""tasks-empty""><div class=""tasks-empty-icon"">📋</div><div class=""tasks-empty-text"">暂无课程任务</div></div>";
            }
            else
            {
                _courseTasks.InnerHtml = html.ToString();
            }
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
    
    // 获取任务类型名称
    private string GetTaskTypeName(string ltype)
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
            default: return "任务";
        }
    }
    
    // 获取任务URL
    private string GetTaskUrl(string ltype, int lid, int lxid, int courseId)
    {
        // 讨论类型直接指向讨论页面，与 showcourse.aspx.cs 保持一致
        if (ltype == "13")
        {
            return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, courseId);
        }
        
        string baseUrl = "showmission.aspx";
        switch (ltype)
        {
            case "1": baseUrl = "showmission.aspx"; break;
            case "2": baseUrl = "showmission.aspx"; break;
            case "3": baseUrl = "showmission.aspx"; break;
            case "4": baseUrl = "programshow.aspx"; break;
            case "5": baseUrl = "pythonshow.aspx"; break;
            case "6": baseUrl = "console.aspx"; break;
            case "7": baseUrl = "graphshow.aspx"; break;
            case "8": baseUrl = "program.aspx"; break;
            case "9": baseUrl = "htmlshow.aspx"; break;
            case "10": baseUrl = "kitymindshow.aspx"; break;
            case "11": baseUrl = "excel.aspx"; break;
            case "12": baseUrl = "ware.aspx"; break;
            case "14": baseUrl = "showmission.aspx"; break;
            case "15": baseUrl = "txtform.aspx"; break;
        }
        return string.Format("{0}?lid={1}&mid={2}&mcid={3}", baseUrl, lid, lxid, courseId);
    }
    
    // 获取任务图标样式类
    private string GetTaskIconClass(string ltype)
    {
        switch (ltype)
        {
            case "1": return "task-icon-activity";
            case "2": return "task-icon-topic";
            case "3": return "task-icon-practice";
            case "4": return "task-icon-block";
            case "5": return "task-icon-python";
            case "6": return "task-icon-quiz";
            case "7": return "task-icon-flowchart";
            case "8": return "task-icon-app";
            case "9": return "task-icon-html";
            case "10": return "task-icon-mindmap";
            case "11": return "task-icon-table";
            case "12": return "task-icon-ware";
            case "13": return "task-icon-discuss";
            case "14": return "task-icon-survey";
            case "15": return "task-icon-form";
            default: return "task-icon-default";
        }
    }
    
    // 获取任务图标SVG
    private string GetTaskIconSvg(string ltype)
    {
        switch (ltype)
        {
            case "5": // Python
                return @"<svg viewBox=""0 0 24 24"" fill=""none"" xmlns=""http://www.w3.org/2000/svg""><polyline points=""16 18 22 12 16 6""/><polyline points=""8 6 2 12 8 18""/></svg>";
            default:
                return @"<svg viewBox=""0 0 24 24"" fill=""none"" xmlns=""http://www.w3.org/2000/svg""><path d=""M9 11l3 3L22 4"" stroke=""currentColor"" stroke-width=""2"" stroke-linecap=""round"" stroke-linejoin=""round""/><path d=""M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"" stroke=""currentColor"" stroke-width=""2"" stroke-linecap=""round"" stroke-linejoin=""round""/></svg>";
        }
    }
    
    private void LoadPythonMission()
    {
        // 获取URL参数
        string lid = Request.QueryString["lid"];
        string mid = Request.QueryString["mid"];
        string pyid = Request.QueryString["pyid"]; // Python任务ID
        string mcid = Request.QueryString["mcid"]; // 课程ID
        
        // 优先使用pyid，如果没有则使用mid
        string missionId = !string.IsNullOrEmpty(pyid) ? pyid : mid;
        
        if (string.IsNullOrEmpty(missionId))
        {
            ShowError("未提供任务ID参数");
            return;
        }
        
        int pythonId;
        if (!int.TryParse(missionId, out pythonId))
        {
            ShowError("无效的任务ID: " + missionId);
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
            
            // 先通过 Listmenu 表查询，获取任务信息
            // Python任务可能使用 Mission 表，通过 Listmenu 的 Ltype='5' 来标识
            string sql = "";
            int listId;
            if (!string.IsNullOrEmpty(lid) && int.TryParse(lid, out listId))
            {
                // 使用 Lid 查询
                sql = @"
                    SELECT 
                        L.Lid,
                        L.Ltitle,
                        L.Lxid,
                        L.Ltype,
                        L.Lcid,
                        M.Mid,
                        M.Mtitle,
                        M.Mdate,
                        M.Mcontent,
                        M.Mfiletype,
                        M.Mpublish,
                        M.Mback,
                        M.Mhelp,
                        M.Mexample,
                        M.Mgid
                    FROM Listmenu L
                    LEFT JOIN Mission M ON L.Lxid = M.Mid
                    WHERE L.Lid = @Lid AND L.Ltype = '5'
                ";
            }
            else
            {
                // 使用 Lxid 查询
                sql = @"
                    SELECT 
                        L.Lid,
                        L.Ltitle,
                        L.Lxid,
                        L.Ltype,
                        L.Lcid,
                        M.Mid,
                        M.Mtitle,
                        M.Mdate,
                        M.Mcontent,
                        M.Mfiletype,
                        M.Mpublish,
                        M.Mback,
                        M.Mhelp,
                        M.Mexample,
                        M.Mgid
                    FROM Listmenu L
                    LEFT JOIN Mission M ON L.Lxid = M.Mid
                    WHERE L.Lxid = @Lxid AND L.Ltype = '5'
                ";
            }
            
            cmd = new SqlCommand(sql, conn);
            // 根据查询类型设置参数
            if (!string.IsNullOrEmpty(lid) && int.TryParse(lid, out listId))
            {
                cmd.Parameters.AddWithValue("@Lid", listId);
            }
            else
            {
                cmd.Parameters.AddWithValue("@Lxid", pythonId);
            }
            
            reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                // 加载任务标题（优先使用 Listmenu 的 Ltitle，如果没有则使用 Mission 的 Mtitle）
                if (LabelMtitle != null)
                {
                    string title = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : 
                                   (reader["Mtitle"] != DBNull.Value ? reader["Mtitle"].ToString() : "未命名任务");
                    LabelMtitle.Text = title;
                }
                
                // 加载任务日期
                if (LabelMdate != null)
                {
                    if (reader["Mdate"] != DBNull.Value)
                    {
                        DateTime date = Convert.ToDateTime(reader["Mdate"]);
                        LabelMdate.Text = date.ToString("yyyy-MM-dd");
                    }
                    else
                    {
                        LabelMdate.Text = "未设置";
                    }
                }
                
                // 加载作品类型
                if (ImageType != null && LabelMfiletype != null)
                {
                    string fileType = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString() : "";
                    if (!string.IsNullOrEmpty(fileType))
                    {
                        // 根据文件类型设置图标
                        string imageUrl = GetFileTypeImageUrl(fileType);
                        if (!string.IsNullOrEmpty(imageUrl))
                        {
                            ImageType.ImageUrl = imageUrl;
                            ImageType.Visible = true;
                        }
                        else
                        {
                            ImageType.Visible = false;
                        }
                        LabelMfiletype.Text = fileType;
                    }
                    else
                    {
                        ImageType.Visible = false;
                        LabelMfiletype.Text = "未设置";
                    }
                }
                
                // 加载实例链接
                if (Hlexample != null)
                {
                    string example = reader["Mexample"] != DBNull.Value ? reader["Mexample"].ToString() : "";
                    if (!string.IsNullOrEmpty(example))
                    {
                        Hlexample.NavigateUrl = example;
                        Hlexample.Target = "_blank";
                        Hlexample.Visible = true;
                    }
                    else
                    {
                        Hlexample.Visible = false;
                    }
                }
                
                // 加载评价标准链接
                if (HLMgid != null)
                {
                    if (reader["Mgid"] != DBNull.Value)
                    {
                        int gid = Convert.ToInt32(reader["Mgid"]);
                        HLMgid.NavigateUrl = "gidshow.aspx?gid=" + gid;
                        HLMgid.Visible = true;
                    }
                    else
                    {
                        HLMgid.Visible = false;
                    }
                }
                
                // 加载选项复选框
                if (CheckPublish != null)
                {
                    CheckPublish.Checked = SafeConvertToBoolean(reader["Mpublish"]);
                }
                
                if (CheckBack != null)
                {
                    CheckBack.Checked = SafeConvertToBoolean(reader["Mback"]);
                }
                
                if (Checkhelp != null)
                {
                    Checkhelp.Checked = SafeConvertToBoolean(reader["Mhelp"]);
                }
                
                // Mission 表没有 Pyblock 和 Pyblockpy 字段，这些字段可能不存在
                // 如果需要，可以从其他表或字段获取
                if (Checkblock != null)
                {
                    Checkblock.Checked = false; // 默认值，如果数据库中有对应字段可以修改
                }
                
                if (Checkblockpy != null)
                {
                    Checkblockpy.Checked = false; // 默认值，如果数据库中有对应字段可以修改
                }
                
                // 加载任务内容
                if (_mcontent != null)
                {
                    string content = reader["Mcontent"] != DBNull.Value ? reader["Mcontent"].ToString() : "";
                    if (string.IsNullOrEmpty(content))
                    {
                        _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>暂无任务内容</div>";
                    }
                    else
                    {
                        _mcontent.InnerHtml = content;
                    }
                }
                else if (Mcontent != null)
                {
                    string content = reader["Mcontent"] != DBNull.Value ? reader["Mcontent"].ToString() : "";
                    if (string.IsNullOrEmpty(content))
                    {
                        Mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>暂无任务内容</div>";
                    }
                    else
                    {
                        Mcontent.InnerHtml = content;
                    }
                }
                
                // 设置页面标题
                Page.Title = LabelMtitle != null ? LabelMtitle.Text : "Python任务展示";
            }
            else
            {
                ShowError("未找到任务记录。请确认：\n1. 任务ID是否正确\n2. 任务类型是否为Python（Ltype='5'）\n3. 数据库中是否存在对应的记录");
            }
        }
        catch (Exception ex)
        {
            string errorMsg = "加载任务信息时出错: " + ex.Message;
            
            // 提供更详细的错误信息
            if (ex.Message.Contains("无效"))
            {
                errorMsg += "\n\n可能的原因：\n1. 数据库中不存在对应的表或字段\n2. 请检查数据库结构\n3. 确认任务是否已正确创建";
            }
            
            ShowError(errorMsg);
            System.Diagnostics.Debug.WriteLine("LoadPythonMission Error: " + ex.ToString());
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }
    
    // 安全地将数据库值转换为布尔值
    private bool SafeConvertToBoolean(object value)
    {
        if (value == null || value == DBNull.Value)
        {
            return false;
        }
        
        // 如果已经是布尔类型，直接返回
        if (value is bool)
        {
            return (bool)value;
        }
        
        // 如果是整数类型（1或0）
        if (value is int)
        {
            return ((int)value) != 0;
        }
        
        // 如果是字符串类型
        string strValue = value.ToString().Trim();
        if (string.IsNullOrEmpty(strValue))
        {
            return false;
        }
        
        // 尝试解析常见的布尔值表示
        if (strValue.Equals("1", StringComparison.OrdinalIgnoreCase) ||
            strValue.Equals("true", StringComparison.OrdinalIgnoreCase) ||
            strValue.Equals("是", StringComparison.OrdinalIgnoreCase) ||
            strValue.Equals("yes", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }
        
        if (strValue.Equals("0", StringComparison.OrdinalIgnoreCase) ||
            strValue.Equals("false", StringComparison.OrdinalIgnoreCase) ||
            strValue.Equals("否", StringComparison.OrdinalIgnoreCase) ||
            strValue.Equals("no", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }
        
        // 如果无法识别，尝试使用 Convert.ToBoolean（可能会抛出异常）
        try
        {
            return Convert.ToBoolean(value);
        }
        catch
        {
            // 如果转换失败，返回 false
            return false;
        }
    }
    
    private string GetFileTypeImageUrl(string fileType)
    {
        // 根据文件类型返回对应的图标URL
        // 这里需要根据实际系统中的图标路径调整
        switch (fileType.ToLower())
        {
            case "py":
            case "python":
                return "~/images/python.png";
            default:
                return "~/images/file.png";
        }
    }
    
    private void ShowError(string message)
    {
        if (LabelMtitle != null)
        {
            LabelMtitle.Text = "加载错误";
        }
        
        if (Mcontent != null)
        {
            Mcontent.InnerHtml = string.Format(
                @"<div style='padding: 20px; background: #fee2e2; border: 1px solid #fca5a5; border-radius: 8px; color: #991b1b;'>
                    <h3>⚠️ 错误</h3>
                    <p>{0}</p>
                </div>",
                Server.HtmlEncode(message)
            );
        }
    }
    
    protected void LinkBtn_Click(object sender, EventArgs e)
    {
        // 返回学案页面
        string mcid = Request.QueryString["mcid"];
        if (!string.IsNullOrEmpty(mcid))
        {
            Response.Redirect("showcourse.aspx?cid=" + mcid);
        }
        else
        {
            Response.Redirect("mycourse.aspx");
        }
    }
}

