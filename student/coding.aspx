<%@ page language="C#" autoeventwireup="true" inherits="Student_coding, LearnSite" %>

<script runat="server">
    protected string GetCodingLogoUrl()
    {
        string logoPath = Server.MapPath("~/scratch/logo.png");
        if (System.IO.File.Exists(logoPath))
            return ResolveUrl("~/scratch/logo.png") + "?v=" + System.IO.File.GetLastWriteTime(logoPath).Ticks;
        return "../scratch/logo.png"; // 默认路径
    }

    protected string sUserName = "";
    protected string sUserInitial = "生";
    protected string sUserClass = "";
    protected string sUserNum = "";
    protected string editProjectUrl = "";
    protected string editDebugInfo = "";

    private static System.Reflection.BindingFlags sFlags =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    private string GetPropStr(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo p = model.GetType().GetProperty(propName);
        if (p == null) return "";
        object v = p.GetValue(model, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, System.Text.Encoding.UTF8); } catch { } }
        return s;
    }

    private int GetPropInt(object model, string propName)
    {
        string s = GetPropStr(model, propName);
        if (string.IsNullOrEmpty(s)) return 0;
        int result;
        if (int.TryParse(s, out result)) return result;
        return 0;
    }

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
            try
            {
                cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    /// <summary>
    /// 覆盖 OnLoad 以拦截基类 Page_Load 中的自动重定向回 program.aspx。
    /// 基类的 Page_Load 在某些条件不满足时会调用 Response.Redirect，
    /// 我们在这里捕获并取消该重定向，然后手动调用 ShowMission 初始化页面数据。
    /// </summary>
    protected override void OnLoad(EventArgs e)
    {
        bool redirectCancelled = false;
        try
        {
            base.OnLoad(e);
        }
        catch (System.Threading.ThreadAbortException)
        {
            System.Threading.Thread.ResetAbort();
            Response.Clear();
            Response.ClearHeaders();
            Response.StatusCode = 200;
            Response.ContentType = "text/html; charset=utf-8";
            redirectCancelled = true;
        }

        // 如果重定向被取消，说明基类的 ShowMission 没有被调用，
        // 页面数据未初始化。手动通过反射调用 ShowMission。
        if (redirectCancelled && string.IsNullOrEmpty(Id))
        {
            try
            {
                System.Reflection.MethodInfo mi = typeof(Student_coding).GetMethod("ShowMission",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (mi != null)
                    mi.Invoke(this, null);
            }
            catch (System.Threading.ThreadAbortException)
            {
                System.Threading.Thread.ResetAbort();
                Response.Clear();
                Response.ClearHeaders();
                Response.StatusCode = 200;
                Response.ContentType = "text/html; charset=utf-8";
            }
            catch (System.Reflection.TargetInvocationException tie)
            {
                if (tie.InnerException is System.Threading.ThreadAbortException)
                {
                    System.Threading.Thread.ResetAbort();
                    Response.Clear();
                    Response.ClearHeaders();
                    Response.StatusCode = 200;
                    Response.ContentType = "text/html; charset=utf-8";
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("ShowMission reflection error: " + tie.InnerException);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ShowMission call error: " + ex);
            }
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        LoadStudentUserInfo();
        FixExamId();
        LoadEditProjectUrl();
    }

    /// <summary>
    /// 考试模式下 DLL 的 Page_Load 读取 QueryString["lid"]，但考试传的是 id 参数，
    /// 导致 ShowMission 不运行，Id 字段为空。这里补充设置以确保保存功能正常。
    /// </summary>
    private void FixExamId()
    {
        if (!string.IsNullOrEmpty(Id)) return; // 正常流程已设置
        string examvid = Request.QueryString["examvid"];
        string qid = Request.QueryString["id"];
        if (!string.IsNullOrEmpty(examvid) && !string.IsNullOrEmpty(qid))
        {
            // SaveProject 按 '-' 分割 Id，格式为 Wcid-Wmid-Wmsort
            // parts[0]=Wcid, parts[1]=Wmid, parts[2]=Wmsort
            Id = "0-" + qid + "-0";
        }
    }

    private void LoadEditProjectUrl()
    {
        string editParam = Request.QueryString["editsbfile"];
        if (string.IsNullOrEmpty(editParam)) { editDebugInfo = "no editsbfile param"; return; }
        if (string.IsNullOrEmpty(sUserNum)) { editDebugInfo = "no sUserNum (cookie)"; return; }
        string qid = Request.QueryString["id"];
        if (string.IsNullOrEmpty(qid)) { editDebugInfo = "no id param"; return; }
        int mid;
        if (!int.TryParse(qid, out mid)) { editDebugInfo = "id not int: " + qid; return; }

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) { editDebugInfo = "no db conn"; return; }

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT TOP 1 Wurl FROM Works WHERE Wmid=@mid AND Wnum=@num ORDER BY Wid DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@mid", mid);
                    cmd.Parameters.AddWithValue("@num", sUserNum);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string wurl = result.ToString();
                        // 使用 getproject.ashx 读取文件（绕过IIS不识别.sb3的问题）
                        editProjectUrl = "getproject.ashx?id=" + mid;
                        editDebugInfo = "ok: wurl=" + wurl + " handler=" + editProjectUrl;
                    }
                    else
                    {
                        // 找不到精确记录，查询该学生最近的所有记录用于调试
                        string allInfo = "no record: Wmid=" + mid + " Wnum=" + sUserNum;
                        try
                        {
                            using (System.Data.SqlClient.SqlCommand cmd2 = new System.Data.SqlClient.SqlCommand(
                                "SELECT TOP 5 Wid, Wmid, Wurl, Wfilename FROM Works WHERE Wnum=@num ORDER BY Wid DESC", conn))
                            {
                                cmd2.Parameters.AddWithValue("@num", sUserNum);
                                using (System.Data.SqlClient.SqlDataReader dr = cmd2.ExecuteReader())
                                {
                                    int cnt = 0;
                                    while (dr.Read())
                                    {
                                        cnt++;
                                        allInfo += " | row" + cnt + ": Wid=" + dr["Wid"] + " Wmid=" + dr["Wmid"] + " file=" + dr["Wfilename"] + " url=" + dr["Wurl"];
                                    }
                                    if (cnt == 0) allInfo += " | NO RECORDS AT ALL for this student";
                                }
                            }
                        }
                        catch (Exception ex2) { allInfo += " | debug err: " + ex2.Message; }
                        editDebugInfo = allInfo;
                    }
                }
            }
        }
        catch (Exception ex) { editDebugInfo = "db error: " + ex.Message; }
    }

    private void LoadStudentUserInfo()
    {
        string cookieName = "";
        string cookieGrade = "";
        string cookieClass = "";
        string cookieSnum = "";
        int cookieSid = 0;
        bool hasCookie = false;
        
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                hasCookie = true;
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", sFlags);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    
                    cookieName = GetPropStr(m, "Sname");
                    cookieGrade = GetPropStr(m, "Sgrade");
                    cookieClass = GetPropStr(m, "Sclass");
                    cookieSnum = GetPropStr(m, "Snum");
                    cookieSid = GetPropInt(m, "Sid");
                    sUserNum = cookieSnum;
                    
                    if (!string.IsNullOrEmpty(cookieName))
                    {
                        sUserName = cookieName;
                        sUserInitial = cookieName.Substring(0, 1);
                    }
                    
                    if (!string.IsNullOrEmpty(cookieGrade) && cookieGrade != "0" && !string.IsNullOrEmpty(cookieClass) && cookieClass != "0")
                        sUserClass = cookieGrade + "年级" + cookieClass + "班";
                    else if (!string.IsNullOrEmpty(cookieClass) && cookieClass != "0")
                        sUserClass = cookieClass + "班";
                }
            }
        }
        catch { }
        
        bool dbLoaded = false;
        if (hasCookie && (cookieSid > 0 || !string.IsNullOrEmpty(cookieSnum)))
        {
            try
            {
                string connStr = GetConnStr();
                if (!string.IsNullOrEmpty(connStr))
                {
                    using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
                    {
                        conn.Open();
                        string sql = "";
                        System.Data.SqlClient.SqlCommand cmd = null;
                        
                        if (cookieSid > 0)
                        {
                            sql = "SELECT Sname, Sgrade, Sclass FROM Students WHERE Sid=@sid";
                            cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                            cmd.Parameters.AddWithValue("@sid", cookieSid);
                        }
                        else if (!string.IsNullOrEmpty(cookieSnum))
                        {
                            sql = "SELECT Sname, Sgrade, Sclass FROM Students WHERE Snum=@snum";
                            cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                            cmd.Parameters.AddWithValue("@snum", cookieSnum);
                        }
                        
                        if (cmd != null)
                        {
                            using (cmd)
                            {
                                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        dbLoaded = true;
                                        if (!reader.IsDBNull(0))
                                        {
                                            string dbName = reader.GetString(0);
                                            if (!string.IsNullOrEmpty(dbName))
                                            {
                                                sUserName = dbName;
                                                sUserInitial = dbName.Substring(0, 1);
                                            }
                                        }
                                        
                                        if (!reader.IsDBNull(1) && !reader.IsDBNull(2))
                                        {
                                            int dbGrade = reader.GetInt32(1);
                                            int dbClass = reader.GetInt32(2);
                                            if (dbGrade > 0 && dbClass > 0)
                                                sUserClass = dbGrade + "年级" + dbClass + "班";
                                            else if (dbClass > 0)
                                                sUserClass = dbClass + "班";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch { }
        }
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Scratch3在线编程</title>
    <link rel="icon" type="image/svg+xml" href="../images/favicon.svg" />
    <script src="../js/jquery.min.js" type="text/javascript"></script>
	<style>
        ::-webkit-scrollbar { width: 6px; } 
        ::-webkit-scrollbar-track {border-radius: 3px; } 
        ::-webkit-scrollbar-thumb { 
            border-radius: 3px; 
            height: 30px; 
            background-color: #eee; 
        }

        /* 用户下拉菜单样式 */
        .coding-user-wrap {
            position: relative;
            display: inline-flex;
            align-items: center;
            margin-left: 12px;
        }
        .coding-user-trigger {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 3px 10px;
            cursor: pointer;
            user-select: none;
            background: rgba(255, 255, 255, 0.2);
            border: none;
            border-radius: 16px;
            transition: all 0.2s;
        }
        .coding-user-trigger:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        .coding-user-trigger.open {
            background: rgba(255, 255, 255, 0.25);
        }
        .coding-avatar {
            width: 24px;
            height: 24px;
            background: linear-gradient(135deg, #6366f1, #a78bfa);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0;
            overflow: hidden;
            line-height: 24px;
        }
        .coding-user-name {
            font-size: 12px;
            font-weight: 600;
            color: #fff;
            max-width: 100px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            line-height: 1.2;
        }
        .coding-user-arrow {
            width: 12px;
            height: 12px;
            stroke: #fff;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
            transition: transform 0.2s;
            flex-shrink: 0;
        }
        .coding-user-trigger.open .coding-user-arrow {
            transform: rotate(180deg);
        }
        .coding-dropdown {
            display: none;
            position: absolute;
            top: calc(100% + 10px);
            right: 0;
            width: 200px;
            z-index: 10000;
        }
        .coding-dropdown.show {
            display: block;
        }
        .coding-dd-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 8px 30px rgba(0,0,0,.12);
        }
        .coding-dd-top {
            padding: 16px 18px;
            border-bottom: 1px solid #f3f4f6;
        }
        .coding-dd-top .dd-name {
            font-size: 15px;
            font-weight: 700;
            color: #111827;
            line-height: 1.3;
        }
        .coding-dd-top .dd-role {
            font-size: 12px;
            color: #9ca3af;
            margin-top: 3px;
        }
        .coding-dd-list {
            padding: 6px 0;
        }
        .coding-dd-item {
            display: block;
            padding: 10px 18px;
            font-size: 14px;
            color: #374151;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.1s;
        }
        .coding-dd-item:hover {
            background: #f9fafb;
            color: #111827;
        }
        .coding-dd-divider {
            height: 1px;
            background: #f3f4f6;
            margin: 0;
        }
        .coding-dd-item.logout {
            color: #dc2626;
        }
        .coding-dd-item.logout:hover {
            background: #fef2f2;
        }

        /* 查看学案弹窗样式 */
        #mcontext {
            display: none;
            position: fixed;
            width: 600px;
            min-width: 400px;
            max-width: 95vw;
            height: 500px;
            min-height: 300px;
            max-height: 90vh;
            z-index: 99999; /* 确保在最上层 */
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3), 0 0 0 1px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            animation: modalFadeIn 0.3s ease-out;
            opacity: 1;
            pointer-events: auto; /* 弹窗本身可以交互 */
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                transform: translate(-50%, -48%);
            }
            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }


        /* 弹窗初始状态 */
        #mcontext {
            opacity: 0;
            transition: opacity 0.3s ease-out;
        }

        /* 弹窗标题栏 */
        .mission-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: none;
            cursor: move;
            user-select: none;
        }

        .mission-header h4 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #ffffff;
            line-height: 1.4;
            flex: 1;
        }

        /* 关闭按钮 */
        .mission-close {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            border: none;
            background: rgba(255, 255, 255, 0.2);
            color: #ffffff;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            flex-shrink: 0;
            margin-left: 16px;
            padding: 0;
            position: relative;
            z-index: 10002;
        }

        .mission-close:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
        }

        .mission-close:active {
            transform: scale(0.95);
        }

        .mission-close svg {
            width: 18px;
            height: 18px;
            stroke: currentColor;
            stroke-width: 2.5;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        /* 弹窗内容区域 */
        .mission-content {
            padding: 24px;
            height: calc(100% - 80px);
            overflow-y: auto;
            overflow-x: hidden;
            background: #ffffff;
        }

        /* 调整大小手柄 */
        .resize-handle {
            position: absolute;
            background: transparent;
            z-index: 10001;
            transition: background 0.2s;
        }

        .resize-handle:hover {
            background: rgba(102, 126, 234, 0.2);
        }

        .resize-handle.n {
            top: 0;
            left: 20px;
            right: 20px;
            height: 8px;
            cursor: ns-resize;
        }

        .resize-handle.s {
            bottom: 0;
            left: 20px;
            right: 20px;
            height: 8px;
            cursor: ns-resize;
        }

        .resize-handle.e {
            top: 20px;
            right: 0;
            bottom: 20px;
            width: 8px;
            cursor: ew-resize;
        }

        .resize-handle.w {
            top: 20px;
            left: 0;
            bottom: 20px;
            width: 8px;
            cursor: ew-resize;
        }

        .resize-handle.ne {
            top: 0;
            right: 0;
            width: 20px;
            height: 20px;
            cursor: nesw-resize;
        }

        .resize-handle.nw {
            top: 0;
            left: 0;
            width: 20px;
            height: 20px;
            cursor: nwse-resize;
        }

        .resize-handle.se {
            bottom: 0;
            right: 0;
            width: 20px;
            height: 20px;
            cursor: nwse-resize;
        }

        .resize-handle.sw {
            bottom: 0;
            left: 0;
            width: 20px;
            height: 20px;
            cursor: nesw-resize;
        }

        /* 拖动时的样式 */
        #mcontext.dragging {
            transition: none;
            cursor: move;
        }

        #mcontext.resizing {
            transition: none;
        }

        /* 美化滚动条 */
        .mission-content::-webkit-scrollbar {
            width: 8px;
        }

        .mission-content::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 4px;
        }

        .mission-content::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
            transition: background 0.2s;
        }

        .mission-content::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }

        /* 内容文本样式 */
        .mission-content h1,
        .mission-content h2,
        .mission-content h3,
        .mission-content h4,
        .mission-content h5,
        .mission-content h6 {
            color: #1e293b;
            margin-top: 20px;
            margin-bottom: 12px;
            font-weight: 600;
            line-height: 1.5;
        }

        .mission-content h1 {
            font-size: 24px;
        }

        .mission-content h2 {
            font-size: 20px;
        }

        .mission-content h3 {
            font-size: 18px;
        }

        .mission-content p {
            color: #475569;
            line-height: 1.8;
            margin-bottom: 16px;
            font-size: 15px;
        }

        .mission-content ul,
        .mission-content ol {
            color: #475569;
            line-height: 1.8;
            margin-bottom: 16px;
            padding-left: 24px;
        }

        .mission-content li {
            margin-bottom: 8px;
        }

        .mission-content a {
            color: #667eea;
            text-decoration: none;
            transition: color 0.2s;
        }

        .mission-content a:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        .mission-content img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 16px 0;
        }

        .mission-content code {
            background: #f1f5f9;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            color: #e11d48;
        }

        .mission-content pre {
            background: #f8fafc;
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 16px 0;
            border: 1px solid #e2e8f0;
        }

        .mission-content pre code {
            background: none;
            padding: 0;
            color: #334155;
        }

        .mission-content blockquote {
            border-left: 4px solid #667eea;
            padding-left: 16px;
            margin: 16px 0;
            color: #64748b;
            font-style: italic;
        }

        .mission-content table {
            width: 100%;
            border-collapse: collapse;
            margin: 16px 0;
        }

        .mission-content table th,
        .mission-content table td {
            padding: 12px;
            border: 1px solid #e2e8f0;
            text-align: left;
        }

        .mission-content table th {
            background: #f8fafc;
            font-weight: 600;
            color: #1e293b;
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            #mcontext {
                width: 95vw;
                max-height: 85vh;
            }

            .mission-header {
                padding: 16px 20px;
            }

            .mission-header h4 {
                font-size: 18px;
            }

            .mission-content {
                padding: 20px;
            }
        }
	</style>
<script>
    // 编辑模式加载已保存项目的公共函数
    window._doEditLoad = function() {
        var url = "<%=editProjectUrl %>";
        if (!url) { console.warn('[edit] editProjectUrl为空，无法加载'); return; }
        console.log('[edit] 开始加载: ' + url);
        fetch(url, {credentials: 'same-origin'}).then(function(resp) {
            console.log('[edit] 响应: ' + resp.status + ' type=' + resp.headers.get('content-type'));
            if (!resp.ok) throw new Error('HTTP ' + resp.status);
            return resp.arrayBuffer();
        }).then(function(buf) {
            console.log('[edit] 数据: ' + buf.byteLength + ' bytes');
            return window.vm.loadProject(buf);
        }).then(function() {
            console.log('[edit] 加载成功');
            window.scratch.setProjectName("<%=sbtitle %>");
        }).catch(function(err) {
            console.error('[edit] 加载失败:', err);
        });
    };
    window.scratchConfig = {
      logo: {
        show: true
        , url: "<%= GetCodingLogoUrl() %>"
        , handleClickLogo: () => {
        }
      }, 
      menuBar: {
        color: 'hsla(215, 100%, 65%, 1)'
      }, 
      shareButton: {
        show: true,
        buttonName: "立即保存",
        handleClick: () => {
          window.scratch.getProjectCoverBlob(cover => {
              //TODO 获取到作品截图
              var projectName = window.scratch.getProjectName()
              var projectCover=cover
              console.log(projectName);

              window.scratch.getProjectFile(file => {              
                console.log(projectCover)
                //TODO 获取到项目文件
                console.log(file)
                //TODO 获取到项目文件
                var id = "<%=Id %>";
                var urls = 'uploadproject.ashx?id=' + id;
                var formData = new FormData();
                formData.append('cover', projectCover);
                formData.append('file', file);
                formData.append('title', projectName);

                $.ajax({
                    url: urls,
                    type: 'POST',
                    cache: false,
                    data: formData,
                    processData: false,
                    contentType: false
                }).done(function (res) {
                    console.log(res)
                    // 考试模式：通知考试页面已保存 + 自动返回
                    var _ev = (location.search.match(/[?&]examvid=([^&]*)/) || [])[1];
                    try {
                        var _eq = (location.search.match(/[?&]id=([^&]*)/) || [])[1];
                        var _snum = codingUserNum;
                        if (_ev && _eq) {
                            localStorage.setItem('exam_' + _ev + '_u_' + _snum + '_q_' + _eq, 'done');
                            if (window.opener && !window.opener.closed) {
                                window.opener.postMessage({type:'examCodingSaved', qid:_eq, examvid:_ev}, '*');
                            }
                        }
                    } catch(ex){}
                    if (_ev) {
                        $(window).unbind('beforeunload');
                        alert("保存成功！即将返回考试页面...");
                        // 尝试关闭当前窗口（由 window.open 打开的页面可以被关闭）
                        window.close();
                        // 如果浏览器阻止了 window.close()（例如非 window.open 打开的页面），则回退跳转
                        setTimeout(function() {
                            window.location.href = "<%=Fpage %>";
                        }, 300);
                    } else {
                        alert("保存成功！");
                    }
                }).fail(function (res) {
                    alert("保存失败！");
                    console.log(res)
                }); 
            
              })
          
          })
        }
      }, 
      profileButton: {
        show: true,
        buttonName: "查看学案",
        handleClick:()=>{
          //查看学案
          showMissionModal();
        }
      }, 
      taskButton: {
        show: true,
        buttonName: "返回学案",
        handleClick:()=>{
          //返回学案
          window.location.href="<%=Fpage %>"
        }
      }, 
      handleVmInitialized: (vm) => {
        window.vm = vm
        console.log("VM初始化完毕")
        
        // 等待菜单栏加载完成后插入用户信息
        setTimeout(function() {
          insertUserInfo();
        }, 500);

        // 编辑模式调试信息
        var _editProjectUrl = "<%=editProjectUrl %>";
        var _editDebug = "<%=editDebugInfo %>";
        console.log('[edit-debug] editProjectUrl=' + (_editProjectUrl || '(empty)') + ' | ' + _editDebug);

        // 后备加载：如果 handleDefaultProjectLoaded 不触发（默认项目404时），3秒后自动加载
        if (_editProjectUrl) {
            window._editLoaded = false;
            window._editTimer = setTimeout(function() {
                if (!window._editLoaded) {
                    console.log('[edit] handleDefaultProjectLoaded 未触发，后备加载启动');
                    window._doEditLoad();
                }
            }, 3000);
        }
      },
      handleDefaultProjectLoaded:() => {
          var _editProjectUrl = "<%=editProjectUrl %>";
          if (_editProjectUrl) {
              console.log('[edit] handleDefaultProjectLoaded 触发，立即加载');
              window._editLoaded = true;
              if (window._editTimer) clearTimeout(window._editTimer);
              window._doEditLoad();
          } else {
              window.scratch.loadProject("<%=sbfile %>", () => { 
                 console.log("项目加载完毕")
                 window.scratch.setProjectName("<%=sbtitle %>")
              })
          }
      },
      //若使用官方素材库请删除本配置项
    }

    $(window).bind('beforeunload',function(){return '确定离开当前页面吗？';} );

    // 用户信息变量
    var codingUserName = '<%= !string.IsNullOrEmpty(sUserName) ? Server.HtmlEncode(sUserName) : "学生" %>';
    var codingUserInitial = '<%= Server.HtmlEncode(sUserInitial) %>';
    var codingUserClass = '<%= !string.IsNullOrEmpty(sUserClass) ? Server.HtmlEncode(sUserClass) : "学生用户" %>';
    var codingUserNum = '<%= Server.HtmlEncode(sUserNum) %>';

    // 插入用户信息到菜单栏
    function insertUserInfo() {
      // 如果已经插入过，不再重复插入
      if (document.getElementById('codingUserWrap')) {
        return;
      }

      // 尝试多种方式查找菜单栏
      var menuBar = document.querySelector('.scratch-gui_menu-bar') ||
                    document.querySelector('[class*="menu-bar"]') ||
                    document.querySelector('[class*="menuBar"]') ||
                    document.querySelector('.gui_menu-bar');
      
      if (!menuBar) {
        // 如果找不到菜单栏，稍后重试（最多重试10次）
        if (!window.codingUserRetryCount) window.codingUserRetryCount = 0;
        if (window.codingUserRetryCount < 10) {
          window.codingUserRetryCount++;
          setTimeout(function() {
            insertUserInfo();
          }, 500);
        }
        return;
      }
      
      // 查找"返回学案"按钮
      var buttons = menuBar.querySelectorAll('button');
      var taskButton = null;
      for (var i = 0; i < buttons.length; i++) {
        var btnText = buttons[i].textContent || buttons[i].innerText || '';
        if (btnText.indexOf('返回学案') !== -1 || btnText.indexOf('返回') !== -1) {
          taskButton = buttons[i];
          break;
        }
      }
      
      // 创建用户信息HTML
      var userHtml = '<div class="coding-user-wrap" id="codingUserWrap">' +
        '<div class="coding-user-trigger" id="codingUserTrigger" onclick="toggleCodingDropdown()">' +
        '<div class="coding-avatar">' + codingUserInitial + '</div>' +
        '<span class="coding-user-name">' + codingUserName + '</span>' +
        '<svg class="coding-user-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>' +
        '</div>' +
        '<div class="coding-dropdown" id="codingDropdown">' +
        '<div class="coding-dd-card">' +
        '<div class="coding-dd-top">' +
        '<div class="dd-name">' + codingUserName + '</div>' +
        '<div class="dd-role">' + codingUserClass + '</div>' +
        '</div>' +
        '<div class="coding-dd-list">' +
        '<a href="../profile/mygroup.aspx" class="coding-dd-item">我的小组</a>' +
        '<a href="../profile/mypwd.aspx" class="coding-dd-item">修改密码</a>' +
        '<a href="../profile/myphoto.aspx" class="coding-dd-item">修改头像</a>' +
        '</div>' +
        '<div class="coding-dd-divider"></div>' +
        '<div class="coding-dd-list">' +
        '<a href="javascript:void(0)" class="coding-dd-item logout" onclick="doCodingLogout()">退出登录</a>' +
        '</div>' +
        '</div>' +
        '</div>' +
        '</div>';
      
      // 创建临时容器来解析HTML
      var tempDiv = document.createElement('div');
      tempDiv.innerHTML = userHtml;
      var userElement = tempDiv.firstChild;
      
      // 如果找到了"返回学案"按钮，在其后插入
      if (taskButton && taskButton.parentNode) {
        // 尝试插入到按钮后面
        if (taskButton.nextSibling) {
          taskButton.parentNode.insertBefore(userElement, taskButton.nextSibling);
        } else {
          taskButton.parentNode.appendChild(userElement);
        }
      } else {
        // 如果找不到按钮，添加到菜单栏的右侧
        // 查找菜单栏右侧的容器
        var rightContainer = menuBar.querySelector('[class*="right"]') ||
                            menuBar.querySelector('[class*="end"]') ||
                            menuBar;
        
        // 确保右侧容器有flex布局
        if (rightContainer && rightContainer !== menuBar) {
          rightContainer.style.display = 'flex';
          rightContainer.style.alignItems = 'center';
          rightContainer.style.gap = '8px';
        }
        
        // 添加到容器末尾
        if (rightContainer) {
          rightContainer.appendChild(userElement);
        } else {
          menuBar.appendChild(userElement);
        }
      }
    }

    // 切换下拉菜单
    function toggleCodingDropdown() {
      var trigger = document.getElementById('codingUserTrigger');
      var dropdown = document.getElementById('codingDropdown');
      if (trigger && dropdown) {
        trigger.classList.toggle('open');
        dropdown.classList.toggle('show');
      }
    }

    // 点击外部关闭下拉菜单
    document.addEventListener('click', function(e) {
      var wrap = document.getElementById('codingUserWrap');
      if (wrap && !wrap.contains(e.target)) {
        var trigger = document.getElementById('codingUserTrigger');
        var dropdown = document.getElementById('codingDropdown');
        if (trigger) trigger.classList.remove('open');
        if (dropdown) dropdown.classList.remove('show');
      }
    });

    // 退出登录
    function doCodingLogout() {
      window.location.href = '../student/myinfo.aspx?logout=1';
    }

    // 显示学案弹窗
    function showMissionModal() {
      var modal = document.getElementById('mcontext');
      if (!modal) return;
      
      // 显示弹窗
      modal.style.display = 'block';
      // 不阻止背景滚动，允许下层页面操作
      // document.body.style.overflow = 'hidden'; // 已移除
      
      // 确保弹窗在最上层
      modal.style.zIndex = '99999';
      
      // 初始化拖动和调整大小功能
      initModalDragAndResize(modal);
      
      // 触发动画
      setTimeout(function() {
        modal.style.opacity = '1';
      }, 10);
    }

    // 初始化弹窗拖动和调整大小功能
    function initModalDragAndResize(modal) {
      if (modal.dataset.initialized === 'true') return;
      modal.dataset.initialized = 'true';

      var header = modal.querySelector('.mission-header');
      if (!header) return;

      // 创建调整大小手柄
      var handles = ['n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw'];
      handles.forEach(function(direction) {
        var handle = document.createElement('div');
        handle.className = 'resize-handle ' + direction;
        modal.appendChild(handle);
      });

      // 拖动功能
      var isDragging = false;
      var dragStartX = 0;
      var dragStartY = 0;
      var modalStartX = 0;
      var modalStartY = 0;

      header.addEventListener('mousedown', function(e) {
        // 如果点击的是关闭按钮，不触发拖动
        if (e.target.closest('.mission-close')) return;
        
        isDragging = true;
        modal.classList.add('dragging');
        dragStartX = e.clientX;
        dragStartY = e.clientY;
        
        var rect = modal.getBoundingClientRect();
        modalStartX = rect.left;
        modalStartY = rect.top;
        
        e.preventDefault();
      });

      // 调整大小功能
      var isResizing = false;
      var resizeDirection = '';
      var resizeStartX = 0;
      var resizeStartY = 0;
      var resizeStartWidth = 0;
      var resizeStartHeight = 0;
      var resizeStartLeft = 0;
      var resizeStartTop = 0;

      handles.forEach(function(direction) {
        var handle = modal.querySelector('.resize-handle.' + direction);
        if (handle) {
          handle.addEventListener('mousedown', function(e) {
            isResizing = true;
            resizeDirection = direction;
            modal.classList.add('resizing');
            resizeStartX = e.clientX;
            resizeStartY = e.clientY;
            
            var rect = modal.getBoundingClientRect();
            resizeStartWidth = rect.width;
            resizeStartHeight = rect.height;
            resizeStartLeft = rect.left;
            resizeStartTop = rect.top;
            
            e.preventDefault();
            e.stopPropagation();
          });
        }
      });

      // 鼠标移动事件
      document.addEventListener('mousemove', function(e) {
        if (isDragging) {
          var deltaX = e.clientX - dragStartX;
          var deltaY = e.clientY - dragStartY;
          
          var newLeft = modalStartX + deltaX;
          var newTop = modalStartY + deltaY;
          
          // 限制在视窗内
          var maxLeft = window.innerWidth - modal.offsetWidth;
          var maxTop = window.innerHeight - modal.offsetHeight;
          
          newLeft = Math.max(0, Math.min(newLeft, maxLeft));
          newTop = Math.max(0, Math.min(newTop, maxTop));
          
          modal.style.left = newLeft + 'px';
          modal.style.top = newTop + 'px';
          modal.style.transform = 'none';
        } else if (isResizing) {
          var deltaX = e.clientX - resizeStartX;
          var deltaY = e.clientY - resizeStartY;
          
          var newWidth = resizeStartWidth;
          var newHeight = resizeStartHeight;
          var newLeft = resizeStartLeft;
          var newTop = resizeStartTop;
          
          // 根据方向调整大小
          if (resizeDirection.indexOf('e') !== -1) {
            newWidth = resizeStartWidth + deltaX;
          }
          if (resizeDirection.indexOf('w') !== -1) {
            newWidth = resizeStartWidth - deltaX;
            newLeft = resizeStartLeft + deltaX;
          }
          if (resizeDirection.indexOf('s') !== -1) {
            newHeight = resizeStartHeight + deltaY;
          }
          if (resizeDirection.indexOf('n') !== -1) {
            newHeight = resizeStartHeight - deltaY;
            newTop = resizeStartTop + deltaY;
          }
          
          // 限制最小和最大尺寸
          var minWidth = parseInt(modal.style.minWidth) || 400;
          var minHeight = parseInt(modal.style.minHeight) || 300;
          var maxWidth = window.innerWidth * 0.95;
          var maxHeight = window.innerHeight * 0.9;
          
          newWidth = Math.max(minWidth, Math.min(newWidth, maxWidth));
          newHeight = Math.max(minHeight, Math.min(newHeight, maxHeight));
          
          // 限制位置
          if (resizeDirection.indexOf('w') !== -1) {
            var maxLeft = resizeStartLeft + resizeStartWidth - minWidth;
            newLeft = Math.max(0, Math.min(newLeft, maxLeft));
            newWidth = resizeStartWidth - (newLeft - resizeStartLeft);
          }
          if (resizeDirection.indexOf('n') !== -1) {
            var maxTop = resizeStartTop + resizeStartHeight - minHeight;
            newTop = Math.max(0, Math.min(newTop, maxTop));
            newHeight = resizeStartHeight - (newTop - resizeStartTop);
          }
          
          modal.style.width = newWidth + 'px';
          modal.style.height = newHeight + 'px';
          if (resizeDirection.indexOf('w') !== -1) {
            modal.style.left = newLeft + 'px';
          }
          if (resizeDirection.indexOf('n') !== -1) {
            modal.style.top = newTop + 'px';
          }
          modal.style.transform = 'none';
        }
      });

      // 鼠标释放事件
      document.addEventListener('mouseup', function() {
        if (isDragging) {
          isDragging = false;
          modal.classList.remove('dragging');
        }
        if (isResizing) {
          isResizing = false;
          resizeDirection = '';
          modal.classList.remove('resizing');
        }
      });
    }

    // 隐藏学案弹窗
    function hideMissionModal() {
      var modal = document.getElementById('mcontext');
      
      if (modal) {
        modal.style.opacity = '0';
        setTimeout(function() {
          modal.style.display = 'none';
          // 不需要恢复滚动，因为我们没有阻止它
          // document.body.style.overflow = ''; // 已移除
        }, 300);
      }
    }

    // ESC键关闭弹窗
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' || e.keyCode === 27) {
        var modal = document.getElementById('mcontext');
        if (modal && modal.style.display === 'block') {
          hideMissionModal();
        }
      }
    });

  </script>

</head>
<body>
   
  <div id="scratch">
    加载中……
  </div>
    <script src="../scratch/lib.min.js" type="text/javascript"></script>
    <script src="../scratch/chunks/gui.js" type="text/javascript"></script>
    
   <!-- 查看学案弹窗 -->
   <div id="mcontext">
        <div class="mission-header">
            <h4><%=Titles%></h4>
            <button class="mission-close" onclick="hideMissionModal();" title="关闭">
                <svg viewBox="0 0 24 24" fill="none">
                    <path d="M18 6L6 18M6 6l12 12"/>
                </svg>
            </button>
        </div>
        <div class="mission-content">
            <%=Mcontents %>
        </div>
    </div>
</body>
</html>