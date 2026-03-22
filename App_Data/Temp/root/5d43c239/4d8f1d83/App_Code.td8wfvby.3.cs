#pragma checksum "C:\inetpub\wwwroot\LearnSite\App_Code\showcourse_new.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "DA6751CDAF380DD4C5F6004D36F6D537"

#line 1 "C:\inetpub\wwwroot\LearnSite\App_Code\showcourse_new.cs"
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Reflection;

// 新课程展示页面代码隐藏类
public class Student_showcourse_new : System.Web.UI.Page
{
    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11": // 像素画
            case "18": case "19": case "20": case "21": case "22":
            case "23": case "24": case "25": case "26": case "27":
            case "28": case "29": case "30": case "31": case "32":
            case "33": case "34": case "35":
            case "36": // 素材库 → 经 program.aspx 展示任务说明再跳转
            case "37": // 网站设计 → 经 program.aspx 展示任务说明再跳转
                return true;
            case "17": // 二维码任务，独立处理
                return false;
            default:
                return false;
        }
    }
    // 获取数据库连接字符串
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            // 尝试从DLL中获取连接字符串（与编译页面保持一致）
            System.Reflection.Assembly lsAsm = null;
            foreach (System.Reflection.Assembly a in AppDomain.CurrentDomain.GetAssemblies())
            {
                if (a.GetType("LearnSite.DBUtility.DbHelperSQL") != null)
                {
                    lsAsm = a;
                    break;
                }
            }
            Type dbType = lsAsm != null ? lsAsm.GetType("LearnSite.DBUtility.DbHelperSQL") : null;
            if (dbType != null)
            {
                FieldInfo connField = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (connField != null)
                {
                    cs = connField.GetValue(null) as string;
                }
            }
        }
        catch { }
        
        // 如果从DLL获取失败，使用web.config
        if (string.IsNullOrEmpty(cs))
        {
            try
            {
                cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch { }
        }
        
        // 添加连接超时设置
        if (!string.IsNullOrEmpty(cs) && 
            cs.ToLower().IndexOf("connection timeout") < 0 && 
            cs.ToLower().IndexOf("connect timeout") < 0)
        {
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        }
        
        return cs;
    }
    // 侧边栏任务类型映射JSON（lid → {typeName, typeClass}）
    protected string _taskTypeMapJson = "{}";
    
    // 控件引用
    private HtmlGenericControl _courseName;
    private HtmlGenericControl _courseTeacher;
    private HtmlGenericControl _taskCount;
    private HtmlGenericControl _taskCompleted;
    private HtmlGenericControl _taskTotal;
    private HtmlGenericControl _progressBar;
    private HtmlGenericControl _progressText;
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
    
    // 初始化控件引用
    private void InitializeControls()
    {
        try
        {
            _courseName = FindControlRecursive((System.Web.UI.Control)this, "courseName") as HtmlGenericControl;
            _courseTeacher = FindControlRecursive((System.Web.UI.Control)this, "courseTeacher") as HtmlGenericControl;
            _taskCount = FindControlRecursive((System.Web.UI.Control)this, "taskCount") as HtmlGenericControl;
            _taskCompleted = FindControlRecursive((System.Web.UI.Control)this, "taskCompleted") as HtmlGenericControl;
            _taskTotal = FindControlRecursive((System.Web.UI.Control)this, "taskTotal") as HtmlGenericControl;
            _progressBar = FindControlRecursive((System.Web.UI.Control)this, "progressBar") as HtmlGenericControl;
            _progressText = FindControlRecursive((System.Web.UI.Control)this, "progressText") as HtmlGenericControl;
            _courseTasks = FindControlRecursive((System.Web.UI.Control)this, "courseTasks") as HtmlGenericControl;
            _ccontent = FindControlRecursive((System.Web.UI.Control)this, "Ccontent") as HtmlGenericControl;
            _labelCtitle = FindControlRecursive((System.Web.UI.Control)this, "LabelCtitle") as Label;
        }
        catch (Exception ex)
        {
            throw new Exception("初始化控件时出错: " + ex.Message, ex);
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            InitializeControls();
            
            if (!IsPostBack)
            {
                LoadCourseInfo();
                LoadCourseContent();
                LoadCourseTasks();
            }
        }
        catch (Exception ex)
        {
            // 尝试显示错误信息
            try
            {
                if (_ccontent != null)
                {
                    _ccontent.InnerHtml = string.Format(
                        @"<div style='color: #dc2626; padding: 24px; border: 2px solid #fca5a5; background: #fef2f2; border-radius: 12px; margin: 20px;'>
                            <div style='display: flex; align-items: center; gap: 12px; margin-bottom: 12px;'>
                                <svg style='width: 24px; height: 24px; flex-shrink: 0;' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>
                                    <circle cx='12' cy='12' r='10'/>
                                    <line x1='12' y1='8' x2='12' y2='12'/>
                                    <line x1='12' y1='16' x2='12.01' y2='16'/>
                                </svg>
                                <h3 style='margin: 0; font-size: 16px; font-weight: 600;'>页面加载错误</h3>
                            </div>
                            <p style='margin: 0 0 12px 0; line-height: 1.6;'>{0}</p>
                            <details style='font-size: 12px; color: #7f1d1d; margin-top: 12px;'>
                                <summary style='cursor: pointer; user-select: none;'>查看详细信息</summary>
                                <pre style='margin-top: 8px; padding: 12px; background: #fff; border: 1px solid #fca5a5; border-radius: 6px; overflow-x: auto; white-space: pre-wrap; word-wrap: break-word;'>{1}</pre>
                            </details>
                            <p style='margin: 12px 0 0; font-size: 12px; color: #7f1d1d;'>
                                课程ID: {2}<br/>
                                请刷新页面重试，或联系管理员。
                            </p>
                        </div>",
                        Server.HtmlEncode(ex.Message),
                        Server.HtmlEncode(ex.StackTrace),
                        Server.HtmlEncode(Request.QueryString["cid"] ?? "未提供")
                    );
                }
                else
                {
                    // 如果连_ccontent都找不到，尝试直接写入Response
                    Response.Write(string.Format(
                        @"<div style='color: #dc2626; padding: 24px; background: #fef2f2; border: 2px solid #fca5a5; border-radius: 12px; margin: 20px;'>
                            <h3>页面加载错误</h3>
                            <p>{0}</p>
                            <details style='font-size: 12px; margin-top: 10px;'>
                                <summary>堆栈跟踪</summary>
                                <pre style='margin-top: 8px; white-space: pre-wrap;'>{1}</pre>
                            </details>
                        </div>",
                        Server.HtmlEncode(ex.Message),
                        Server.HtmlEncode(ex.StackTrace)
                    ));
                }
            }
            catch
            {
                // 如果连错误显示都失败，至少记录到响应
                Response.Write("<div style='color: #dc2626; padding: 20px; background: #fef2f2; margin: 20px;'>页面加载时发生严重错误，请联系管理员。</div>");
            }
        }
    }
    
    private void LoadCourseInfo()
    {
        string cid = Request.QueryString["cid"];
        
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
        
        string connectionString = GetConnStr();
        if (string.IsNullOrEmpty(connectionString))
        {
            SetErrorInfo("数据库配置错误: 无法获取连接字符串");
            return;
        }
        
        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;
        
        try
        {
            conn = new SqlConnection(connectionString);
            conn.Open();
            
            // 查询课程完整信息（与教师端保持一致）
            string sql = @"
                SELECT C.Cid, C.Ctitle, C.Cdate, C.Cclass, C.Cobj, C.Cterm, C.Cks, C.Cbanner, C.Chid, T.Hname as TeacherName
                FROM Courses C
                LEFT JOIN Teacher T ON C.Chid = T.Hid
                WHERE C.Cid = @Cid AND (C.Cdelete = 0 OR C.Cdelete IS NULL)
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Cid", courseId);
            cmd.CommandTimeout = 10;
            
            reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                string courseNameValue = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "未命名课程";
                string teacherName = reader["TeacherName"] != DBNull.Value ? reader["TeacherName"].ToString() : "未指定";
                string cdate = reader["Cdate"] != DBNull.Value ? reader["Cdate"].ToString() : "";
                string cclass = reader["Cclass"] != DBNull.Value ? reader["Cclass"].ToString() : "";
                string cobj = reader["Cobj"] != DBNull.Value ? reader["Cobj"].ToString() : "";
                string cterm = reader["Cterm"] != DBNull.Value ? reader["Cterm"].ToString() : "";
                string cks = reader["Cks"] != DBNull.Value ? reader["Cks"].ToString() : "";
                
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
                cmd.CommandTimeout = 10;
                object taskResult = cmd.ExecuteScalar();
                if (taskResult != null && taskResult != DBNull.Value)
                {
                    taskCountValue = Convert.ToInt32(taskResult);
                }
                cmd.Dispose();
                
                // 查询学习进度
                int completedTasks = 0;
                string studentNum = "";
                
                // 尝试从Session获取学号
                try
                {
                    if (Session["Snum"] != null)
                    {
                        studentNum = Session["Snum"].ToString();
                    }
                }
                catch { }
                
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
                    cmd.CommandTimeout = 10;
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
                
                // 更新控件 - 基本信息
                if (_courseName != null)
                    _courseName.InnerText = courseNameValue;
                
                if (_courseTeacher != null)
                    _courseTeacher.InnerText = teacherName;
                
                if (_taskCount != null)
                    _taskCount.InnerText = taskCountValue.ToString();
                
                if (_taskCompleted != null)
                    _taskCompleted.InnerText = completedTasks.ToString();
                
                if (_taskTotal != null)
                    _taskTotal.InnerText = taskCountValue.ToString();
                
                if (_progressBar != null)
                    _progressBar.Style["width"] = progressPercent + "%";
                
                if (_progressText != null)
                    _progressText.InnerText = progressPercent + "%";
                
                // 设置页面标题（与教师端一致）
                if (_labelCtitle != null)
                    _labelCtitle.Text = courseNameValue;
                
                Page.Title = courseNameValue;
            }
            else
            {
                SetErrorInfo("未找到课程记录 (CID: " + courseId + ")");
            }
        }
        catch (Exception ex)
        {
            SetErrorInfo("加载课程信息时出错: " + ex.Message + "<br/>堆栈: " + ex.StackTrace);
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
        
        string connectionString = GetConnStr();
        if (string.IsNullOrEmpty(connectionString))
        {
            ShowError("数据库配置错误: 无法获取连接字符串");
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
                        // 显示友好的空内容提示
                        _ccontent.InnerHtml = string.Format(@"
                            <div style='display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 60px 20px; color: #9ca3af;'>
                                <svg style='width: 80px; height: 80px; margin-bottom: 24px; opacity: 0.3;' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'>
                                    <path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/>
                                    <polyline points='14 2 14 8 20 8'/>
                                    <line x1='12' y1='11' x2='12' y2='17'/>
                                    <line x1='9' y1='14' x2='15' y2='14'/>
                                </svg>
                                <h3 style='font-size: 18px; font-weight: 600; color: #64748b; margin: 0 0 12px 0;'>暂无课程内容</h3>
                                <p style='font-size: 14px; color: #94a3b8; margin: 0 0 8px 0;'>教师尚未添加课程内容</p>
                                <p style='font-size: 12px; color: #cbd5e1; margin: 0;'>课程ID: {0} | 标题: {1}</p>
                            </div>",
                            courseId,
                            Server.HtmlEncode(title)
                        );
                    }
                    else
                    {
                        // 确保内容正确显示
                        _ccontent.InnerHtml = NormalizeCourseContent(content);
                    }
                }
                else
                {
                    // 如果控件未找到，尝试直接写入
                    Response.Write(string.Format(
                        @"<div style='color: #dc2626; padding: 20px; background: #fef2f2; border: 2px solid #fca5a5; border-radius: 8px; margin: 20px;'>
                            <h3>控件错误</h3>
                            <p>Ccontent 控件未找到</p>
                            <p style='font-size: 12px; margin-top: 10px;'>课程ID: {0}</p>
                        </div>",
                        courseId
                    ));
                }
                
                Page.Title = title;
            }
            else
            {
                ShowError("未找到课程记录 (CID: " + courseId + ")");
            }
        }
        catch (Exception ex)
        {
            ShowError("加载课程内容时出错: " + ex.Message + "<br/>堆栈: " + ex.StackTrace);
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
            return;
        }
        
        string connectionString = GetConnStr();
        if (string.IsNullOrEmpty(connectionString))
        {
            _courseTasks.InnerHtml = @"<div class=""course-tasks-empty""><div class=""course-tasks-empty-icon"">⚠️</div><div class=""course-tasks-empty-text"" style=""color: #dc2626;"">数据库配置错误: 无法获取连接字符串</div></div>";
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
                SELECT L.Lid, L.Lxid, L.Ltype, L.Ltitle, M.Msort
                FROM Listmenu L
                LEFT JOIN Mission M ON M.Mid = L.Lxid
                WHERE L.Lcid = @Lcid AND (CONVERT(nvarchar(10), L.lshow) IN ('1','True','true'))
                ORDER BY L.Lsort
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lcid", courseId);
            
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
                string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                
                // 特殊处理：二维码任务（Msort=17）
                if (msort == "17")
                {
                    ltype = "17";  // 设置为特殊的类型标识
                }
                // 其他像素画子类型
                else if (IsPixelAddProgramSubtype(msort))
                {
                    ltype = "8";
                }
                
                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "未命名任务";
                
                string taskTypeName = GetTaskTypeName(ltype, msort);
                string taskTypeClass = GetTaskTypeClass(ltype, msort);
                string url = GetTaskUrl(ltype, lid, lxid, courseId, msort);
                string iconSvg = GetTaskIconSvg(ltype, msort);
                
                // 构建JSON映射: lid → {n: typeName, t: typeClass}
                if (!firstJson) jsonMap.Append(",");
                firstJson = false;
                jsonMap.AppendFormat("\"{0}\":{{\"n\":\"{1}\",\"t\":\"{2}\"}}",
                    lid,
                    taskTypeName.Replace("\"", "\\\""),
                    taskTypeClass);
                
                html.AppendFormat(
                    @"<a href=""{0}"" class=""course-task-item"">
                        <div class=""course-task-number"">{5}</div>
                        <div class=""course-task-icon type-{6}"">
                            {2}
                        </div>
                        <div class=""course-task-content"">
                            <div class=""course-task-title"">{3}</div>
                            <div class=""course-task-type"">{4}</div>
                        </div>
                    </a>",
                    url,
                    "",
                    iconSvg,
                    Server.HtmlEncode(ltitle),
                    Server.HtmlEncode(taskTypeName),
                    count,
                    taskTypeClass
                );
            }
            
            jsonMap.Append("}");
            _taskTypeMapJson = jsonMap.ToString();
            
            if (count == 0)
            {
                _courseTasks.InnerHtml = @"<div class=""course-tasks-empty""><div class=""course-tasks-empty-icon"">📋</div><div class=""course-tasks-empty-text"">暂无课程任务</div></div>";
            }
            else
            {
                _courseTasks.InnerHtml = html.ToString();
            }
        }
        catch (Exception ex)
        {
            _courseTasks.InnerHtml = @"<div class=""course-tasks-empty""><div class=""course-tasks-empty-icon"">⚠️</div><div class=""course-tasks-empty-text"" style=""color: #dc2626;"">加载任务列表失败: " + Server.HtmlEncode(ex.Message) + "</div></div>";
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
                @"<div style='padding: 24px; background: #fef2f2; border: 2px solid #fca5a5; border-radius: 12px; color: #991b1b; margin: 20px 0;'>
                    <div style='display: flex; align-items: center; gap: 12px; margin-bottom: 12px;'>
                        <svg style='width: 24px; height: 24px; flex-shrink: 0;' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>
                            <circle cx='12' cy='12' r='10'/>
                            <line x1='12' y1='8' x2='12' y2='12'/>
                            <line x1='12' y1='16' x2='12.01' y2='16'/>
                        </svg>
                        <h3 style='margin: 0; font-size: 16px; font-weight: 600;'>页面加载错误</h3>
                    </div>
                    <p style='margin: 0; line-height: 1.6;'>{0}</p>
                    <p style='margin: 12px 0 0; font-size: 12px; color: #7f1d1d;'>
                        请刷新页面重试，或联系管理员。<br/>
                        课程ID: {1}
                    </p>
                </div>",
                Server.HtmlEncode(message),
                Server.HtmlEncode(Request.QueryString["cid"] ?? "未提供")
            );
        }
        else
        {
            // 如果 _ccontent 控件未找到，尝试直接写入响应
            try
            {
                Response.Write(string.Format(
                    @"<div style='padding: 24px; background: #fef2f2; border: 2px solid #fca5a5; border-radius: 12px; color: #991b1b; margin: 20px;'>
                        <h3>页面加载错误</h3>
                        <p>{0}</p>
                        <p style='font-size: 12px; margin-top: 10px;'>Ccontent 控件未找到</p>
                    </div>",
                    Server.HtmlEncode(message)
                ));
            }
            catch { }
        }
    }
    
    // 获取任务类型CSS类（与教师端 iconMap type 保持一致）
    private string GetTaskTypeClass(string ltype)
    {
        return GetTaskTypeClass(ltype, "");
    }
    
    private string GetTaskTypeClass(string ltype, string msort)
    {
        // 二维码任务特殊处理
        if (ltype == "17" || msort == "17")
        {
            return "code";  // 使用 code 类型的样式
        }
        
        switch (ltype)
        {
            case "1": return "code";     // 活动
            case "2": return "code";     // 主题
            case "3": return "survey";   // 练习
            case "4": return "code";     // 积木编程
            case "5": return "code";     // Python
            case "6": return "survey";   // 测评
            case "7": return "flow";     // 流程图
            case "8": return "code";     // 应用
            case "9": return "html";     // Html
            case "10": return "mind";    // 导图
            case "11": return "excel";   // 表格
            case "12": return "ware";    // 课件
            case "13": return "discuss"; // 讨论
            case "14": return "survey";  // 调查
            case "15": return "form";    // 填表
            default: return "code";
        }
    }
    
    // 获取任务类型名称（与教师端 GetTypeName 保持一致）
    private string GetTaskTypeName(string ltype)
    {
        return GetTaskTypeName(ltype, "");
    }
    
    private string GetTaskTypeName(string ltype, string msort)
    {
        // 二维码任务特殊处理
        if (ltype == "17" || msort == "17")
            return "二维码";
        // Msort 18-35 专属类型名称
        if (!string.IsNullOrEmpty(msort))
        {
            switch (msort.Trim())
            {
                case "18": return "在线文档";
                case "19": return "演示文稿";
                case "20": return "海报设计";
                case "21": return "风格迁移";
                case "22": return "图像分类";
                case "23": return "人脸识别";
                case "24": return "物联网MQTT";
                case "25": return "手绘画布";
                case "26": return "推箱子地图";
                case "27": return "人工智能对话";
                case "28": return "语音合成";
                case "29": return "文字识别";
                case "30": return "声音分析";
                case "31": return "井字棋";
                case "32": return "手写数字识别";
                case "33": return "Markdown写作";
                case "34": return "嵌入本地网页";
                case "35": return "文生图";
                case "36": return "素材库";
                case "37": return "网站设计";
            }
        }
        
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
    
    // 获取任务URL（与教师端 GetNavigateUrl 及 student/showcourse.aspx.cs 保持一致）
    private string GetTaskUrl(string ltype, int lid, int lxid, int courseId)
    {
        return GetTaskUrl(ltype, lid, lxid, courseId, "");
    }
    
    private string GetTaskUrl(string ltype, int lid, int lxid, int courseId, string msort)
    {
        // Msort 18-37 专属类型：全部先到 program.aspx 展示任务说明，再由「开始创作」跳转对应编辑器
        // 包括：素材库(36)、网站设计(37)
        if (!string.IsNullOrEmpty(msort))
        {
            int _msortNum;
            if (int.TryParse(msort.Trim(), out _msortNum) && _msortNum >= 18 && _msortNum <= 37)
                return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}&msort={3}", lid, lxid, courseId, msort.Trim());
        }
        // 二维码任务特殊处理：跳转到 program.aspx
        if (ltype == "17" || msort == "17")
        {
            return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, courseId);
        }
        
        // 讨论类型直接指向讨论页面，与 student/showcourse.aspx.cs 保持一致
        if (ltype == "13")
        {
            return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, courseId);
        }
        
        string baseUrl = "showmission.aspx";
        switch (ltype)
        {
            case "1": baseUrl = "showmission.aspx"; break;
            case "2": baseUrl = "topicshow.aspx"; break;
            case "3": baseUrl = "showmission.aspx"; break;
            case "4": baseUrl = "program.aspx"; break;
            case "5": baseUrl = "program.aspx"; break;
            case "6":
                return string.Format("console.aspx?lid={0}", lid);
            case "7": baseUrl = "graphshow.aspx"; break;
            case "8": baseUrl = "program.aspx"; break;  // pixeladd类型统一指向program.aspx
            case "9": baseUrl = "htmlshow.aspx"; break;
            case "10": baseUrl = "program.aspx"; break;  // 思维导图：先到 program.aspx 看任务说明，与 taskredirect.ashx 一致
            case "11": baseUrl = "excel.aspx"; break;  // 表格：直接跳转到 excel.aspx
            case "12": baseUrl = "ware.aspx"; break;
            case "14": baseUrl = "surveyshow.aspx"; break;
            case "15": baseUrl = "txtform.aspx"; break;
            case "17": baseUrl = "program.aspx"; break;  // 二维码任务
        }
        return string.Format("{0}?lid={1}&mid={2}&mcid={3}", baseUrl, lid, lxid, courseId);
    }
    
    // 获取任务图标SVG（与教师端工具栏图标保持一致）
    private string GetTaskIconSvg(string ltype)
    {
        return GetTaskIconSvg(ltype, "");
    }
    
    private string GetTaskIconSvg(string ltype, string msort)
    {
        // 二维码任务特殊处理
        if (ltype == "17" || msort == "17")
        {
            return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""7"" height=""7""/><rect x=""14"" y=""3"" width=""7"" height=""7""/><rect x=""14"" y=""14"" width=""7"" height=""7""/><rect x=""3"" y=""14"" width=""7"" height=""7""/></svg>";
        }
        
        switch (ltype)
        {
            case "1": // 活动
                return @"<svg viewBox=""0 0 24 24""><path d=""M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z""/><polyline points=""14 2 14 8 20 8""/><line x1=""12"" y1=""18"" x2=""12"" y2=""12""/><line x1=""9"" y1=""15"" x2=""15"" y2=""15""/></svg>";
            case "2": // 主题
                return @"<svg viewBox=""0 0 24 24""><path d=""M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z""/><path d=""M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z""/></svg>";
            case "3": // 练习
                return @"<svg viewBox=""0 0 24 24""><path d=""M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z""/><polyline points=""14 2 14 8 20 8""/><line x1=""16"" y1=""13"" x2=""8"" y2=""13""/><line x1=""16"" y1=""17"" x2=""8"" y2=""17""/><polyline points=""10 9 9 9 8 9""/></svg>";
            case "4": // 积木编程
                return @"<svg viewBox=""0 0 24 24""><rect x=""2"" y=""6"" width=""8"" height=""6"" rx=""1""/><rect x=""14"" y=""6"" width=""8"" height=""6"" rx=""1""/><rect x=""8"" y=""14"" width=""8"" height=""6"" rx=""1""/></svg>";
            case "5": // Python
                return @"<svg viewBox=""0 0 24 24""><polyline points=""16 18 22 12 16 6""/><polyline points=""8 6 2 12 8 18""/><line x1=""14"" y1=""4"" x2=""10"" y2=""20""/></svg>";
            case "6": // 测评
                return @"<svg viewBox=""0 0 24 24""><rect x=""2"" y=""3"" width=""20"" height=""14"" rx=""2"" ry=""2""/><line x1=""8"" y1=""21"" x2=""16"" y2=""21""/><line x1=""12"" y1=""17"" x2=""12"" y2=""21""/></svg>";
            case "7": // 流程图
                return @"<svg viewBox=""0 0 24 24""><path d=""M12 2L2 7l10 5 10-5-10-5z""/><path d=""M2 17l10 5 10-5""/><path d=""M2 12l10 5 10-5""/></svg>";
            case "8": // 应用
                return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""7"" height=""7""/><rect x=""14"" y=""3"" width=""7"" height=""7""/><rect x=""14"" y=""14"" width=""7"" height=""7""/><rect x=""3"" y=""14"" width=""7"" height=""7""/></svg>";
            case "9": // Html
                return @"<svg viewBox=""0 0 24 24""><polyline points=""16 18 22 12 16 6""/><polyline points=""8 6 2 12 8 18""/></svg>";
            case "10": // 导图
                return @"<svg viewBox=""0 0 24 24""><circle cx=""12"" cy=""12"" r=""3""/><line x1=""12"" y1=""2"" x2=""12"" y2=""9""/><line x1=""12"" y1=""15"" x2=""12"" y2=""22""/><line x1=""2"" y1=""12"" x2=""9"" y2=""12""/><line x1=""15"" y1=""12"" x2=""22"" y2=""12""/></svg>";
            case "11": // 表格
                return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""18"" height=""18"" rx=""2"" ry=""2""/><line x1=""3"" y1=""9"" x2=""21"" y2=""9""/><line x1=""9"" y1=""3"" x2=""9"" y2=""21""/></svg>";
            case "12": // 课件
                return @"<svg viewBox=""0 0 24 24""><polygon points=""23 7 16 12 23 17 23 7""/><rect x=""1"" y=""5"" width=""15"" height=""14"" rx=""2"" ry=""2""/></svg>";
            case "13": // 讨论
                return @"<svg viewBox=""0 0 24 24""><path d=""M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z""/></svg>";
            case "14": // 调查
                return @"<svg viewBox=""0 0 24 24""><path d=""M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2""/><rect x=""8"" y=""2"" width=""8"" height=""4"" rx=""1"" ry=""1""/></svg>";
            case "15": // 填表
                return @"<svg viewBox=""0 0 24 24""><rect x=""3"" y=""3"" width=""18"" height=""18"" rx=""2"" ry=""2""/><line x1=""3"" y1=""9"" x2=""21"" y2=""9""/><line x1=""3"" y1=""15"" x2=""21"" y2=""15""/><line x1=""9"" y1=""3"" x2=""9"" y2=""21""/></svg>";
            default: // 默认
                return @"<svg viewBox=""0 0 24 24""><path d=""M9 11l3 3L22 4""/><path d=""M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11""/></svg>";
        }
    }
}


#line default
#line hidden
