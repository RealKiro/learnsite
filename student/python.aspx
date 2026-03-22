<%@ page language="C#" autoeventwireup="true" inherits="Student_python, LearnSite" %>

<script runat="server">
    protected string sUserName = "";
    protected string sUserInitial = "生";
    protected string sUserClass = "";
    protected string sUserNum = "";
    protected string pyQid = "";

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
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        LoadStudentUserInfo();
        // 从 QueryString 直接读取 Id（DLL 可能未暴露 Id 属性）
        string qid = Request.QueryString["Id"];
        if (string.IsNullOrEmpty(qid)) qid = Request.QueryString["id"];
        if (!string.IsNullOrEmpty(qid)) pyQid = qid;
    }

    private void LoadStudentUserInfo()
    {
        string cookieName = "", cookieGrade = "", cookieClass = "", cookieSnum = "";
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
                        else
                        {
                            sql = "SELECT Sname, Sgrade, Sclass FROM Students WHERE Snum=@snum";
                            cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                            cmd.Parameters.AddWithValue("@snum", cookieSnum);
                        }
                        if (cmd != null)
                        {
                            using (cmd)
                            using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
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
            catch { }
        }
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Python在线编程</title>
    <link rel="icon" type="image/svg+xml" href="../images/favicon.svg" />
  <link href="../code/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
  <link href="../code/turtle.css" rel="stylesheet" type="text/css" />
    <script src="../kindeditor/plugins/code/prettify.js" type="text/javascript"></script>
    <link href="../kindeditor/plugins/code/prettify.css?ver=621" rel="stylesheet" type="text/css" />
  <style>
    /* ===== 美化 banner ===== */
    .banner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 54px;
      line-height: 54px;
      padding: 0 16px;
      box-sizing: border-box;
      width: 100%;
      background: linear-gradient(135deg, #2d3436 0%, #3a4a4e 100%);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
      user-select: none;
      position: relative;
      z-index: 1001;
      overflow: visible;
    }
    .banner-left {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .banner-left .fa-codepen {
      font-size: 22px;
      color: #fce383;
    }
    .banner-right {
      display: flex;
      align-items: center;
      gap: 6px;
      flex-shrink: 0;
    }

    /* ===== 按钮美化 ===== */
    .banner .button {
      background: rgba(255,255,255,0.08);
      border: 1px solid rgba(255,255,255,0.18);
      border-radius: 6px;
      color: #e0e0e0;
      font-size: 13px;
      padding: 5px 12px;
      cursor: pointer;
      transition: all 0.2s;
      margin: 0;
      white-space: nowrap;
      line-height: 1.4;
    }
    .banner .button:hover {
      background: rgba(252,227,131,0.18);
      border-color: rgba(252,227,131,0.4);
      color: #fce383;
    }
    .banner .button i {
      padding: 0 4px 0 0;
    }
    .btn-run {
      background: rgba(76,175,80,0.2) !important;
      border-color: rgba(76,175,80,0.4) !important;
    }
    .btn-run:hover {
      background: rgba(76,175,80,0.35) !important;
      border-color: rgba(76,175,80,0.6) !important;
      color: #81c784 !important;
    }
    .btn-save {
      background: rgba(33,150,243,0.2) !important;
      border-color: rgba(33,150,243,0.4) !important;
    }
    .btn-save:hover {
      background: rgba(33,150,243,0.35) !important;
      border-color: rgba(33,150,243,0.6) !important;
      color: #64b5f6 !important;
    }

    /* ===== 用户信息 ===== */
    .py-user-wrap {
      position: relative;
      display: inline-flex;
      align-items: center;
      margin-left: 8px;
    }
    .py-user-trigger {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 3px 10px;
      cursor: pointer;
      user-select: none;
      background: rgba(255,255,255,0.12);
      border: none;
      border-radius: 16px;
      transition: all 0.2s;
    }
    .py-user-trigger:hover {
      background: rgba(255,255,255,0.22);
    }
    .py-user-trigger.open {
      background: rgba(255,255,255,0.18);
    }
    .py-avatar {
      width: 26px;
      height: 26px;
      background: linear-gradient(135deg, #6366f1, #a78bfa);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 12px;
      font-weight: 700;
      line-height: 26px;
    }
    .py-user-name {
      color: #e0e0e0;
      font-size: 13px;
      font-weight: 500;
      white-space: nowrap;
      line-height: 1;
    }
    .py-user-arrow {
      width: 14px;
      height: 14px;
      fill: none;
      stroke: #bbb;
      stroke-width: 2;
      stroke-linecap: round;
      stroke-linejoin: round;
      transition: transform 0.2s;
    }
    .py-user-trigger.open .py-user-arrow {
      transform: rotate(180deg);
    }
    .py-dropdown {
      display: none;
      position: absolute;
      top: calc(100% + 6px);
      right: 0;
      min-width: 180px;
      background: #2d3436;
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 10px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.4);
      z-index: 9999;
      overflow: hidden;
    }
    .py-dropdown.show { display: block; }
    .py-dd-top {
      padding: 14px 16px 10px;
      border-bottom: 1px solid rgba(255,255,255,0.08);
    }
    .py-dd-name {
      font-size: 15px;
      font-weight: 600;
      color: #fff;
    }
    .py-dd-role {
      font-size: 12px;
      color: #999;
      margin-top: 2px;
    }
    .py-dd-list { padding: 6px 0; }
    .py-dd-item {
      display: block;
      padding: 8px 16px;
      font-size: 13px;
      color: #ccc;
      text-decoration: none;
      transition: background 0.15s;
    }
    .py-dd-item:hover {
      background: rgba(255,255,255,0.06);
      color: #fff;
    }
    .py-dd-item.logout { color: #e57373; }
    .py-dd-item.logout:hover { background: rgba(229,115,115,0.1); }
    .py-dd-divider {
      height: 1px;
      background: rgba(255,255,255,0.08);
      margin: 0 12px;
    }

    /* ===== 覆盖 #sideby 使其不显示（按钮已移入 banner） ===== */
    #sideby { display: none !important; }

    /* ===== main 区域微调 ===== */
    .main {
      margin-top: 0;
      height: calc(100vh - 54px);
      border-top: 1px solid rgba(255,255,255,0.05);
    }

    /* ===== 分隔线 ===== */
    .btn-sep {
      width: 1px;
      height: 22px;
      background: rgba(255,255,255,0.15);
      margin: 0 2px;
    }
  </style>
</head>

<body  onload="prettyPrint(); ">

<div class="banner">
  <div class="banner-left">
    <i class="fa fa-codepen"></i>
    <a id="title"><%=Titles%></a>
  </div>
  <div class="banner-right">
    <button onclick="fullide()" class="button"><i class="fa fa-expand" aria-hidden="true"></i>全屏</button>
    <button onclick="remember()" class="button"><i class="fa fa-video-camera" aria-hidden="true"></i>回忆</button>
    <div class="btn-sep"></div>
    <button onclick="runit()" class="button btn-run"><i class="fa fa-play-circle" aria-hidden="true"></i>运行</button>
    <button onclick="checkright()" class="button btn-save"><i class="fa fa-save" aria-hidden="true"></i>保存</button>
    <div class="btn-sep"></div>
    <button onclick="returnurl()" class="button"><i class="fa fa-reply" aria-hidden="true"></i>返回</button>
    <div class="py-user-wrap" id="pyUserWrap">
      <div class="py-user-trigger" id="pyUserTrigger" onclick="togglePyDropdown()">
        <div class="py-avatar"><%= Server.HtmlEncode(sUserInitial) %></div>
        <span class="py-user-name"><%= !string.IsNullOrEmpty(sUserName) ? Server.HtmlEncode(sUserName) : "学生" %></span>
        <svg class="py-user-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="py-dropdown" id="pyDropdown">
        <div class="py-dd-top">
          <div class="py-dd-name"><%= !string.IsNullOrEmpty(sUserName) ? Server.HtmlEncode(sUserName) : "学生" %></div>
          <div class="py-dd-role"><%= !string.IsNullOrEmpty(sUserClass) ? Server.HtmlEncode(sUserClass) : "学生用户" %></div>
        </div>
        <div class="py-dd-list">
          <a href="../profile/mygroup.aspx" class="py-dd-item">我的小组</a>
          <a href="../profile/mypwd.aspx" class="py-dd-item">修改密码</a>
          <a href="../profile/myphoto.aspx" class="py-dd-item">修改头像</a>
        </div>
        <div class="py-dd-divider"></div>
        <div class="py-dd-list">
          <a href="javascript:void(0)" class="py-dd-item logout" onclick="doPyLogout()">退出登录</a>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="main" >
	<div id="done"><img src="../images/sucessed.png"></img></div>
	<div class="description">
        <div class="map"><img class="mapimg" src="<%=Midurl %>" alt=""/></div> 
		<div id="content" >
		  <%=Mcontents %>
		  <br /><br /> <br><br />
		</div>	
	</div>
	<div class="left" id="editor"></div>
	<div class="right">
		<div id="result">
		<pre id="output" ></pre>
		 <div class="fullimg"><img src="<%=MidurlFull %>" /></div> 
		<div id="cv" ></div>
		</div>
	</div>
</div>

<div  id="big" onclick="fontbig()" title="放大代码"> </div>
<div  id="small" onclick="fontsmall()" title="缩小代码"> </div>
<div id="colorbox"></div>
<div id="codexample">
	<div id="codeplace"></div>
	<div id="codebutton">
	<button class="btncode" id="prev">上一页</button>&nbsp;&nbsp;&nbsp;&nbsp;<button class="btncode"  id="next">下一页</button>
	</div>
</div>
<div class="tooltip"></div>

<div id="savemsg"></div>

<div  id="sideby">
<button  onclick="fullide()" class="button"  >
<i class="fa fa-expand" aria-hidden="true"></i>全屏</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="remember()" class="button"  >
<i class="fa fa-video-camera" aria-hidden="true"></i>回忆</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="runit()" class="button"  >
<i class="fa fa-play-circle" aria-hidden="true"></i>运行</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="checkright()" class="button"  >
<i class="fa fa-save" aria-hidden="true"></i>保存</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="returnurl()" class="button">
<i class="fa fa-reply" aria-hidden="true"></i>返回</button>
</div>

<script src="../code/skulpt.min.js?ver=20211202" type="text/javascript"></script>
<script src="../code/skulpt-stdlib.js" type="text/javascript"></script>
<script src="../code/html2canvas.min.js" type="text/javascript"></script>
<script src="../code/jquery.min.js" type="text/javascript"></script>

<script src="../code/build/src/ace.js" type="text/javascript"></script>
<script src="../code/build/src/ext-language_tools.js" type="text/javascript"></script>
<script src="../code/build/src/ext-beautify.js" type="text/javascript"></script>

<script type="text/javascript">

    var snum = "<%=Snum %>";
    // 确保学号可靠（DLL 的 Snum 可能为空，用自定义 cookie 读取值覆盖）
    var _pyUserNum = '<%= Server.HtmlEncode(sUserNum) %>';
    if (_pyUserNum) snum = _pyUserNum;
    var cvbg = "<%=mback %>";
    var cf = "<%=codefile %>";
    var id = "<%=Id %>";
    // DLL 可能未设置 Id，用服务端从 QueryString 直接读取的值覆盖
    var _pyQid = '<%= Server.HtmlEncode(pyQid) %>';
    if (_pyQid) id = _pyQid;

    var testn = 0;
    var testg = 0;
    var argck = [0, 0, 0];
    var argcodestr = "<%=argcode %>";

    var arginstr = "<%=argin %>";
    var argin = arginstr.split("#");

    var argout0 = "<%=argout0 %>";
    var argout1 = "<%=argout1 %>";
    var argout2 = "<%=argout2 %>";
    var argout = new Array();
    argout[0] = decodeURIComponent(window.atob(argout0));
    argout[1] = decodeURIComponent(window.atob(argout1));
    argout[2] = decodeURIComponent(window.atob(argout2));
    var argimg = "<%=argimg %>";
    var mhelp = "<%=mhelp %>";

    var fpage = "<%=Fpage %>";

    var mypre = document.getElementById("output");
    var result = document.getElementById("result");
    var savemsg = document.getElementById("savemsg");
    var cv = document.getElementById("cv");
    var dictvalue = new Array(); //定义新字典
    var codedict = new Array(); //定义新字典
    var codefile = decodeURIComponent(window.atob(cf)); //定义字典 
    var codearg = decodeURIComponent(window.atob(argcodestr)); //定义字典 

</script>
<script src="../code/turtle.js" type="text/javascript"></script>
<script src="../code/colorbox.js" type="text/javascript"></script>
<script src="../code/example.js" type="text/javascript"></script>
<script type="text/javascript">
  // 用户下拉菜单交互
  function togglePyDropdown() {
    var trigger = document.getElementById('pyUserTrigger');
    var dropdown = document.getElementById('pyDropdown');
    if (trigger && dropdown) {
      trigger.classList.toggle('open');
      dropdown.classList.toggle('show');
    }
  }
  document.addEventListener('click', function(e) {
    var wrap = document.getElementById('pyUserWrap');
    if (wrap && !wrap.contains(e.target)) {
      var trigger = document.getElementById('pyUserTrigger');
      var dropdown = document.getElementById('pyDropdown');
      if (trigger) trigger.classList.remove('open');
      if (dropdown) dropdown.classList.remove('show');
    }
  });
  function doPyLogout() {
    window.location.href = '../student/myinfo.aspx?logout=1';
  }
  
  // 考试模式：覆盖returnurl函数，返回前自动保存
  (function() {
    var examvid = (location.search.match(/[?&]examvid=([^&]*)/) || [])[1];
    if (examvid && id) {
      console.log('[考试模式] 启用自动保存功能');
      
      // 保存原始returnurl函数
      var originalReturnUrl = window.returnurl;
      
      // 覆盖returnurl函数
      window.returnurl = function() {
        var prog = editor.getValue();
        var trimmedProg = $.trim(prog);
        
        // 如果有代码内容，自动保存
        if (trimmedProg && trimmedProg.length > 0) {
          console.log('[考试模式] 检测到代码，自动保存中...');
          
          // 显示保存提示
          if (savemsg) {
            savemsg.innerHTML = '正在自动保存...';
            savemsg.style.display = 'block';
          }
          
          // 构造保存请求
          var urls = 'uploadpython.ashx?id=' + id;
          var formData = new FormData();
          
          // 创建一个空白图片作为封面
          var emptyCanvas = document.createElement('canvas');
          emptyCanvas.width = 1;
          emptyCanvas.height = 1;
          var emptyBlob = null;
          emptyCanvas.toBlob(function(blob) {
            emptyBlob = blob;
          });
          
          formData.append('cover', emptyBlob || new Blob());
          formData.append('codefile', window.btoa(encodeURIComponent(prog)));
          formData.append('codedict', '');
          formData.append('pass', 0);
          
          $.ajax({
            url: urls,
            type: 'POST',
            cache: false,
            data: formData,
            processData: false,
            contentType: false,
            async: false  // 同步请求，确保保存完成后再返回
          }).done(function(res) {
            console.log('[考试模式] 自动保存成功');
            // 写入localStorage标记
            localStorage.setItem('exam_' + examvid + '_u_' + snum + '_q_' + id, 'done');
            // 通知父窗口
            if (window.opener && !window.opener.closed) {
              window.opener.postMessage({type:'examCodingSaved', qid:id, examvid:examvid}, '*');
            }
            // 返回考试页面
            window.location.href = fpage;
          }).fail(function() {
            console.error('[考试模式] 自动保存失败');
            // 即使保存失败也返回，但提示用户
            if (confirm('代码保存失败，是否仍要返回？')) {
              window.location.href = fpage;
            }
          });
        } else {
          // 没有代码，直接返回
          console.log('[考试模式] 无代码内容，直接返回');
          window.location.href = fpage;
        }
      };
    }
  })();
</script>
</body>
</html>
