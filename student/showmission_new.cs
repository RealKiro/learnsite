using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.IO;
using System.Reflection;

public class Student_showmission_new : Page
{
    // 用于JS回退重定向（当服务端重定向失败时）
    protected string _jsRedirectUrl = "";
    // 调试信息（debug=1时显示）
    protected string _debugInfoHtml = "";

    // 获取数据库连接字符串（与showcourse_new.cs保持一致）
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
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
    
    
    // 已确认的Listmenu类型配置错误覆盖表
    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 111 && lcid == 16) return "8";
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5"; // Python，非像素
        if (lid == 47 && lcid == 9) return "6"; // 测评，非Html
        if (lid == 48 && lcid == 9) return "8"; // 像素，非表格
        // if (lid == 61 && lcid == 12) return "7"; // 撤销错误硬编码
        if (lid == 85 && lcid == 12) return "10"; // 导图，禁止误判为填表
        return normalized;
    }
    
    // 不需要DB连接的纠偏版本（使用SQL查询中已计算的标志，避免MARSreadert冲突）
    // SQL子查询已用课程ID关联，所以标志是精确匹配的
    private string CorrectLtypeInline(string ltype, int lid, int lcid, bool isSurvey, bool isTopic, bool isTxtForm)
    {
        string normalized = NormalizeLtype(ltype);
        normalized = ApplyKnownLtypeOverrides(normalized, lid, lcid);
        // 仅对通用类型(1-3: 活动/主题/练习)做纠偏，避免专用类型(4-12)因 lxid 撞号被误判
        int nType;
        if (int.TryParse(normalized, out nType) && nType >= 1 && nType <= 3)
        {
            if (isSurvey) return "14";
            if (isTopic) return "13";
            if (isTxtForm) return "15";
        }
        return normalized;
    }
    
    private bool IsDebugMode()
    {
        return string.Equals(Request.QueryString["debug"], "1", StringComparison.Ordinal);
    }
    
    // 将中文/别名类型统一转换为数字编码，保持与教师端一致
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
            case "Python":
            case "代码":
            case "仓库": return "5";
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
            default: return ltype;
        }
    }

    // 控件引用
    private HtmlGenericControl _mcontent;
    private Label _labelMtitle;
    private Label _labelLid;
    private Label _labelMid;
    private Label _labelMcid;
    private Label _labelMsort;
    private CheckBox _ckMupload;
    private CheckBox _ckMgroup;
    private Label _labelMfiletype;
    private HyperLink _upFileUrl;
    private Image _upFileType;
    private HyperLink _upFileUrlGroup;
    private Image _upFileTypeGroup;
    private GridView _gVgwork;
    private HyperLink _voteLink;
    private Panel _panelworks;
    private Panel _panelswfupload;
    private Panel _panelGroupUp;
    private Panel _panelgroup;
    private Label _labelmsg;
    private Label _labelgroupmsg;
    private Label _labelSnum;
    private Label _labelUploadType;
    private Image _imageType;
    private HtmlGenericControl _submittedWork;
    private HtmlGenericControl _submittedGroupWork;

    // 递归查找控件
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

    // 初始化控件引用
    private void InitializeControls()
    {
        _mcontent = FindControlRecursive(this, "Mcontent") as HtmlGenericControl;
        _labelMtitle = FindControlRecursive(this, "LabelMtitle") as Label;
        _labelLid = FindControlRecursive(this, "LabelLid") as Label;
        _labelMid = FindControlRecursive(this, "LabelMid") as Label;
        _labelMcid = FindControlRecursive(this, "LabelMcid") as Label;
        _labelMsort = FindControlRecursive(this, "LabelMsort") as Label;
        _ckMupload = FindControlRecursive(this, "CkMupload") as CheckBox;
        _ckMgroup = FindControlRecursive(this, "CkMgroup") as CheckBox;
        _labelMfiletype = FindControlRecursive(this, "LabelMfiletype") as Label;
        _upFileUrl = FindControlRecursive(this, "upFileUrl") as HyperLink;
        _upFileType = FindControlRecursive(this, "upFileType") as Image;
        _upFileUrlGroup = FindControlRecursive(this, "upFileUrlGroup") as HyperLink;
        _upFileTypeGroup = FindControlRecursive(this, "upFileTypeGroup") as Image;
        _gVgwork = FindControlRecursive(this, "GVgwork") as GridView;
        _voteLink = FindControlRecursive(this, "VoteLink") as HyperLink;
        _panelworks = FindControlRecursive(this, "Panelworks") as Panel;
        _panelswfupload = FindControlRecursive(this, "Panelswfupload") as Panel;
        _panelGroupUp = FindControlRecursive(this, "PanelGroupUp") as Panel;
        _panelgroup = FindControlRecursive(this, "Panelgroup") as Panel;
        _labelmsg = FindControlRecursive(this, "Labelmsg") as Label;
        _labelgroupmsg = FindControlRecursive(this, "Labelgroupmsg") as Label;
        _labelSnum = FindControlRecursive(this, "LabelSnum") as Label;
        _labelUploadType = FindControlRecursive(this, "LabelUploadType") as Label;
        _imageType = FindControlRecursive(this, "ImageType") as Image;
        _submittedWork = FindControlRecursive(this, "submittedWork") as HtmlGenericControl;
        _submittedGroupWork = FindControlRecursive(this, "submittedGroupWork") as HtmlGenericControl;
    }

    // 获取学生学号（从Cookie）
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
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public |
                        System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                    System.Reflection.PropertyInfo pn = ct.GetProperty("Snum");
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

    // 在页面生命周期最早阶段检查任务类型并重定向，确保在主页面DLL代码执行前完成跳转
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
                string sql = @"SELECT Ltype, Lxid, Lcid,
                    CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion WHERE Qvid = Lxid AND Qcid = Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                    CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss WHERE Tid = Lxid AND Tcid = Lcid) THEN 1 ELSE 0 END AS IsTopic,
                    CASE WHEN EXISTS(SELECT 1 FROM TxtForm WHERE Mid = Lxid AND Mcid = Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                    FROM Listmenu WHERE Lid=@Lid";
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
                            bool isSurvey = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                            bool isTopic = reader["IsTopic"] != DBNull.Value && Convert.ToInt32(reader["IsTopic"]) == 1;
                            bool isTxtForm = reader["IsTxtForm"] != DBNull.Value && Convert.ToInt32(reader["IsTxtForm"]) == 1;
                            string mcid = !string.IsNullOrEmpty(lcid) ? lcid : (Request.QueryString["mcid"] ?? "");

                            int lcidInt = 0;
                            int.TryParse(lcid, out lcidInt);
                            string fixedLtype = CorrectLtypeInline(ltype, listId, lcidInt, isSurvey, isTopic, isTxtForm);
                            string target = GetRedirectTarget(fixedLtype, listId, lxid, mcid);
                            if (!string.IsNullOrEmpty(target))
                            {
                                string resolvedUrl = ResolveUrl(target);
                                reader.Close();
                                if (IsDebugMode())
                                {
                                    _debugInfoHtml = string.Format(
                                        "<div style='margin:12px 0;padding:12px 14px;border:1px solid #f59e0b;background:#fffbeb;border-radius:8px;color:#92400e;font-size:13px;line-height:1.7;'>" +
                                        "<div style='font-weight:700;margin-bottom:6px;'>调试模式已开启（未自动跳转）</div>" +
                                        "Lid={0}<br/>Lxid={1}<br/>Lcid={2}<br/>原始Ltype={3}<br/>归一化Ltype={4}<br/>应跳转={5}" +
                                        "</div>",
                                        Server.HtmlEncode(listId.ToString()),
                                        Server.HtmlEncode(lxid.ToString()),
                                        Server.HtmlEncode(mcid ?? ""),
                                        Server.HtmlEncode(ltype ?? ""),
                                        Server.HtmlEncode(fixedLtype),
                                        Server.HtmlEncode(resolvedUrl)
                                    );
                                    return;
                                }
                                // 保存JS回退URL（以防Response.Redirect被拦截）
                                _jsRedirectUrl = resolvedUrl;
                                try
                                {
                                    Response.Redirect(resolvedUrl, true);
                                }
                                catch (System.Threading.ThreadAbortException)
                                {
                                    throw;
                                }
                                catch { } // Response.Redirect失败时，JS回退会生效
                            }
                        }
                    }
                }
            }
        }
        catch (System.Threading.ThreadAbortException)
        {
            throw;
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        InitializeControls();

        if (!IsPostBack)
        {
            try
            {
                LoadMissionContent();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Page_Load Error: " + ex.ToString());
            }
        }
    }

    // 加载任务内容
    private void LoadMissionContent()
    {
        string lid = Request.QueryString["lid"];
        string mid = Request.QueryString["mid"];
        string mcid = Request.QueryString["mcid"];

        if (string.IsNullOrEmpty(lid))
        {
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>未提供任务ID参数</div>";
            return;
        }

        int listId;
        if (!int.TryParse(lid, out listId))
        {
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>无效的任务ID</div>";
            return;
        }

        string connectionString = GetConnStr();
        if (string.IsNullOrEmpty(connectionString))
        {
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: red; padding: 20px;'>数据库配置错误: 无法获取连接字符串</div>";
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
                SELECT L.Lid, L.Ltitle, L.Lxid, L.Ltype, L.Lcid,
                       M.Mid, M.Mtitle, M.Mcontent, M.Mupload, M.Mgroup, M.Mfiletype, M.Msort,
                       CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion SQ WHERE SQ.Qvid = L.Lxid AND SQ.Qcid = L.Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                       CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss TD WHERE TD.Tid = L.Lxid AND TD.Tcid = L.Lcid) THEN 1 ELSE 0 END AS IsTopic,
                       CASE WHEN EXISTS(SELECT 1 FROM TxtForm TF WHERE TF.Mid = L.Lxid AND TF.Mcid = L.Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                FROM Listmenu L
                LEFT JOIN Mission M ON L.Lxid = M.Mid
                WHERE L.Lid = @Lid
            ";

            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lid", listId);

            reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                // 判断任务类型，非活动/主题/练习类型需要跳转到对应的专用页面
                string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : string.Empty;
                string courseIdFromDb = reader["Lcid"] != DBNull.Value ? reader["Lcid"].ToString() : string.Empty;
                int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;

                // 获取课程ID参数（优先数据库中的，其次URL参数）
                string mcidParam = !string.IsNullOrEmpty(courseIdFromDb)
                    ? courseIdFromDb
                    : (Request.QueryString["mcid"] ?? string.Empty);

                // 检查是否需要跳转到其他专用页面
                bool isSurvey2 = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                bool isTopic2 = reader["IsTopic"] != DBNull.Value && Convert.ToInt32(reader["IsTopic"]) == 1;
                bool isTxtForm2 = reader["IsTxtForm"] != DBNull.Value && Convert.ToInt32(reader["IsTxtForm"]) == 1;
                int lcidInt2 = 0;
                int.TryParse(courseIdFromDb, out lcidInt2);
                string fixedLtype2 = CorrectLtypeInline(ltype, listId, lcidInt2, isSurvey2, isTopic2, isTxtForm2);
                string redirectTarget = GetRedirectTarget(fixedLtype2, listId, lxid, mcidParam);
                if (IsDebugMode())
                {
                    string resolvedDbg = string.IsNullOrEmpty(redirectTarget) ? "(本页显示，不跳转)" : ResolveUrl(redirectTarget);
                    _debugInfoHtml = string.Format(
                        "<div style='margin:12px 0;padding:12px 14px;border:1px solid #f59e0b;background:#fffbeb;border-radius:8px;color:#92400e;font-size:13px;line-height:1.7;'>" +
                        "<div style='font-weight:700;margin-bottom:6px;'>调试模式已开启</div>" +
                        "Lid={0}<br/>Lxid={1}<br/>Lcid={2}<br/>原始Ltype={3}<br/>归一化Ltype={4}<br/>跳转判定={5}" +
                        "</div>",
                        Server.HtmlEncode(listId.ToString()),
                        Server.HtmlEncode(lxid.ToString()),
                        Server.HtmlEncode(mcidParam ?? ""),
                        Server.HtmlEncode(ltype ?? ""),
                        Server.HtmlEncode(fixedLtype2),
                        Server.HtmlEncode(resolvedDbg)
                    );
                }
                if (!string.IsNullOrEmpty(redirectTarget))
                {
                    string resolvedUrl = ResolveUrl(redirectTarget);
                    if (IsDebugMode())
                    {
                        _debugInfoHtml = string.Format(
                            "<div style='margin:12px 0;padding:12px 14px;border:1px solid #f59e0b;background:#fffbeb;border-radius:8px;color:#92400e;font-size:13px;line-height:1.7;'>" +
                            "<div style='font-weight:700;margin-bottom:6px;'>调试模式已开启（未自动跳转）</div>" +
                            "Lid={0}<br/>Lxid={1}<br/>Lcid={2}<br/>原始Ltype={3}<br/>归一化Ltype={4}<br/>应跳转={5}" +
                            "</div>",
                            Server.HtmlEncode(listId.ToString()),
                            Server.HtmlEncode(lxid.ToString()),
                            Server.HtmlEncode(mcidParam ?? ""),
                            Server.HtmlEncode(ltype ?? ""),
                            Server.HtmlEncode(fixedLtype2),
                            Server.HtmlEncode(resolvedUrl)
                        );
                    }
                    else
                    {
                    reader.Close();
                    reader = null;
                    // 设置JS回退（以防服务端重定向失败）
                    _jsRedirectUrl = resolvedUrl;
                    try
                    {
                        Response.Redirect(resolvedUrl, true);
                    }
                    catch (System.Threading.ThreadAbortException) { throw; }
                    catch { }
                    return;
                    }
                }

                // 类型 1(活动)、2(主题)、3(练习) 在本页面显示
                // 设置任务标题
                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "未命名任务";
                if (_labelMtitle != null)
                    _labelMtitle.Text = ltitle;

                // 设置隐藏字段
                if (_labelLid != null)
                    _labelLid.Text = listId.ToString();

                if (_labelMid != null && reader["Mid"] != DBNull.Value)
                    _labelMid.Text = reader["Mid"].ToString();

                if (_labelMcid != null && reader["Lcid"] != DBNull.Value)
                    _labelMcid.Text = reader["Lcid"].ToString();

                if (_labelMsort != null && reader["Msort"] != DBNull.Value)
                    _labelMsort.Text = reader["Msort"].ToString();

                // 设置复选框
                bool mupload = false;
                if (reader["Mupload"] != DBNull.Value)
                {
                    mupload = Convert.ToBoolean(reader["Mupload"]);
                    if (_ckMupload != null) _ckMupload.Checked = mupload;
                }

                bool mgroup = false;
                if (reader["Mgroup"] != DBNull.Value)
                {
                    mgroup = Convert.ToBoolean(reader["Mgroup"]);
                    if (_ckMgroup != null) _ckMgroup.Checked = mgroup;
                }

                // 设置文件类型
                string mfiletype = "";
                if (reader["Mfiletype"] != DBNull.Value)
                {
                    mfiletype = reader["Mfiletype"].ToString();
                    if (_labelMfiletype != null) _labelMfiletype.Text = mfiletype;
                }

                // 设置文件类型图标
                if (_imageType != null && !string.IsNullOrEmpty(mfiletype))
                {
                    _imageType.ImageUrl = "~/images/filetype/" + mfiletype.ToLower() + ".gif";
                }

                // 加载任务内容
                if (_mcontent != null)
                {
                    string content = reader["Mcontent"] != DBNull.Value ? reader["Mcontent"].ToString() : "";
                    _mcontent.InnerHtml = string.IsNullOrEmpty(content)
                        ? "<div style='color: #999; text-align: center; padding: 40px;'>暂无任务内容</div>"
                        : content;
                }

                Page.Title = ltitle + " - 任务详情";

                reader.Close();
                reader = null;

                // 控制上传面板可见性
                System.Diagnostics.Debug.WriteLine("Mupload=" + mupload + ", Mgroup=" + mgroup);
                
                if (_panelworks != null)
                {
                    _panelworks.Visible = mupload;
                    System.Diagnostics.Debug.WriteLine("Panelworks.Visible=" + _panelworks.Visible);
                }

                // 控制上传按钮面板可见性
                if (_panelswfupload != null)
                {
                    _panelswfupload.Visible = mupload;
                    System.Diagnostics.Debug.WriteLine("Panelswfupload.Visible=" + _panelswfupload.Visible);
                }

                if (_panelgroup != null)
                {
                    _panelgroup.Visible = mgroup;
                    System.Diagnostics.Debug.WriteLine("Panelgroup.Visible=" + _panelgroup.Visible);
                }

                // 控制小组上传按钮面板可见性
                if (_panelGroupUp != null)
                {
                    _panelGroupUp.Visible = mgroup;
                    System.Diagnostics.Debug.WriteLine("PanelGroupUp.Visible=" + _panelGroupUp.Visible);
                }

                // 加载已提交作品信息
                LoadWorkInfo(conn, listId);

                // 加载小组作品
                if (mgroup)
                    LoadGroupWorkInfo(conn, listId);
            }
            else
            {
                if (_mcontent != null)
                    _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>未找到任务记录</div>";
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadMissionContent Error: " + ex.ToString());
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: red; padding: 20px;'>加载任务内容时出错: " + Server.HtmlEncode(ex.Message) + "</div>";
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }

    // 加载已提交的作品信息
    private void LoadWorkInfo(SqlConnection conn, int lid)
    {
        string snum = GetStudentSnum();
        if (string.IsNullOrEmpty(snum)) return;

        if (_labelSnum != null) _labelSnum.Text = snum;

        SqlCommand cmd = null;
        SqlDataReader reader = null;

        try
        {
            string sql = @"
                SELECT TOP 1 Wurl, Wtype
                FROM Works
                WHERE Wlid = @Lid AND Wnum = @Snum
                ORDER BY Wid DESC
            ";

            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lid", lid);
            cmd.Parameters.AddWithValue("@Snum", snum);

            reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                string wurl = reader["Wurl"] != DBNull.Value ? reader["Wurl"].ToString() : "";
                string wtype = reader["Wtype"] != DBNull.Value ? reader["Wtype"].ToString() : "";

                if (!string.IsNullOrEmpty(wurl))
                {
                    // 显示已提交作品区域
                    if (_submittedWork != null)
                        _submittedWork.Visible = true;

                    if (_upFileUrl != null)
                    {
                        _upFileUrl.NavigateUrl = wurl;
                        _upFileUrl.Text = "📄 查看已提交作品";
                        _upFileUrl.Visible = true;
                    }

                    if (_upFileType != null && !string.IsNullOrEmpty(wtype))
                    {
                        _upFileType.ImageUrl = "~/images/filetype/" + wtype.ToLower() + ".gif";
                        _upFileType.Visible = true;
                    }

                    if (_labelmsg != null)
                        _labelmsg.Text = "已提交作品，可重新提交覆盖";
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadWorkInfo Error: " + ex.ToString());
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
        }
    }

    // 加载小组作品信息
    private void LoadGroupWorkInfo(SqlConnection conn, int lid)
    {
        SqlCommand cmd = null;
        SqlDataReader reader = null;

        try
        {
            string sql = @"
                SELECT W.Wid, W.Wurl, W.Wtype, W.Wname as Sname, W.Wlscore
                FROM Works W
                WHERE W.Wlid = @Lid
                ORDER BY W.Wid DESC
            ";

            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lid", lid);

            reader = cmd.ExecuteReader();

            DataTable dt = new DataTable();
            dt.Columns.Add("wid");
            dt.Columns.Add("Sname");
            dt.Columns.Add("Wurl");
            dt.Columns.Add("Wlscore");

            while (reader.Read())
            {
                DataRow row = dt.NewRow();
                row["wid"] = reader["Wid"] != DBNull.Value ? reader["Wid"].ToString() : "";
                row["Sname"] = reader["Sname"] != DBNull.Value ? reader["Sname"].ToString() : "未知";
                row["Wurl"] = reader["Wurl"] != DBNull.Value ? reader["Wurl"].ToString() : "";
                row["Wlscore"] = reader["Wlscore"] != DBNull.Value ? reader["Wlscore"].ToString() : "";
                dt.Rows.Add(row);
            }

            if (_gVgwork != null && dt.Rows.Count > 0)
            {
                _gVgwork.DataSource = dt;
                _gVgwork.DataBind();
            }
        }
        catch { }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
        }
    }

    // 根据任务类型获取跳转目标URL，与taskredirect.ashx和教师端保持一致
    // 返回空字符串表示不需要跳转（在本页显示）
    private string GetRedirectTarget(string ltype, int lid, int lxid, string mcid)
    {
        ltype = NormalizeLtype(ltype);
        // 兼容修正：已确认 Lid=23（课程5）应为调查问卷
        if (lid == 23 && mcid == "5") ltype = "14";
        // 类型 1(活动)、2(主题)、3(练习) 在showmission页面显示，不跳转
        // 其他类型跳转到对应的专用页面
        string target = "";
        switch (ltype)
        {
            case "1":  // 活动
            case "2":  // 主题
            case "3":  // 练习
                return ""; // 在本页显示

            case "4":  // 积木编程
                target = string.Format("~/student/programshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "5":  // Python
                target = string.Format("~/student/pythonshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "6":  // 测评
                target = string.Format("~/student/console.aspx?lid={0}", lid);
                break;
            case "7":  // 流程图
                target = string.Format("~/student/graphshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "8":  // 应用
                target = string.Format("~/student/program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "9":  // Html
                target = string.Format("~/student/htmlshow.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "10": // 导图
                target = string.Format("~/student/program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "11": // 表格
                target = string.Format("~/student/program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "12": // 课件
                target = string.Format("~/student/ware.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            case "13": // 讨论
                target = !string.IsNullOrEmpty(mcid)
                    ? string.Format("~/student/topicdiscuss.aspx?lid={0}&cid={1}", lid, mcid)
                    : string.Format("~/student/topicdiscuss.aspx?lid={0}", lid);
                break;
            case "14": // 调查
                target = string.Format("~/student/surveyshow.aspx?sid={0}&cid={1}", lxid, mcid);
                break;
            case "15": // 填表
                target = string.Format("~/student/txtform.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, mcid);
                break;
            default:
                return ""; // 未知类型默认在本页显示
        }
        return target;
    }

    // GridView 事件处理方法
    protected void GVgwork_RowCommand(object sender, GridViewCommandEventArgs e)
    {
    }

    protected void GVgwork_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HyperLink link = e.Row.FindControl("HyperLinkWurl") as HyperLink;
            if (link != null && !string.IsNullOrEmpty(link.ToolTip))
            {
                link.NavigateUrl = link.ToolTip;
            }
        }
    }
}
