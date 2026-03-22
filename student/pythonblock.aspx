<%@ page language="C#" autoeventwireup="true" inherits="student_pythonblock, LearnSite" %>

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
  <title>Python拼图编程</title>
  <link rel="icon" type="image/svg+xml" href="../images/favicon.svg" />
<link href="../code/block.css" rel="stylesheet" type="text/css" />
<link href="../code/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
    <script src="../js/jquery-ui-1.8.24.custom.min.js" type="text/javascript"></script>
<script src="../code/build/src/ace.js" type="text/javascript"></script>
<script src="../code/build/src/ext-language_tools.js" type="text/javascript"></script>
<script src="../code/skulpt.min.js?ver=20211202" type="text/javascript"></script>
<script src="../code/skulpt-stdlib.js" type="text/javascript"></script>
<script src="../code/html2canvas.min.js" type="text/javascript"></script>
<style>
    /* ===== 美化 banner ===== */
    .banner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 44px;
      line-height: 44px;
      padding: 0 16px;
      box-sizing: border-box;
      width: 100%;
      background: linear-gradient(135deg, #2d3436 0%, #3a4a4e 100%);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
      user-select: none;
      position: relative;
      z-index: 1001;
      overflow: visible;
      font-size: 16px;
    }
    .banner a#title {
      color: #f0f0f0;
      font-size: 16px;
      font-weight: 600;
    }
    .banner-left {
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }
    .banner-left .fa-codepen {
      font-size: 20px;
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
      padding: 4px 10px;
      cursor: pointer;
      transition: all 0.2s;
      margin: 0;
      white-space: nowrap;
      line-height: 1.4;
      height: auto;
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
    .pb-user-wrap {
      position: relative;
      display: inline-flex;
      align-items: center;
      margin-left: 8px;
    }
    .pb-user-trigger {
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
    .pb-user-trigger:hover {
      background: rgba(255,255,255,0.22);
    }
    .pb-user-trigger.open {
      background: rgba(255,255,255,0.18);
    }
    .pb-avatar {
      width: 24px;
      height: 24px;
      background: linear-gradient(135deg, #6366f1, #a78bfa);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 11px;
      font-weight: 700;
      line-height: 24px;
    }
    .pb-user-name {
      color: #e0e0e0;
      font-size: 13px;
      font-weight: 500;
      white-space: nowrap;
      line-height: 1;
    }
    .pb-user-arrow {
      width: 14px;
      height: 14px;
      fill: none;
      stroke: #bbb;
      stroke-width: 2;
      stroke-linecap: round;
      stroke-linejoin: round;
      transition: transform 0.2s;
    }
    .pb-user-trigger.open .pb-user-arrow {
      transform: rotate(180deg);
    }
    .pb-dropdown {
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
    .pb-dropdown.show { display: block; }
    .pb-dd-top {
      padding: 14px 16px 10px;
      border-bottom: 1px solid rgba(255,255,255,0.08);
    }
    .pb-dd-name {
      font-size: 15px;
      font-weight: 600;
      color: #fff;
    }
    .pb-dd-role {
      font-size: 12px;
      color: #999;
      margin-top: 2px;
    }
    .pb-dd-list { padding: 6px 0; }
    .pb-dd-item {
      display: block;
      padding: 8px 16px;
      font-size: 13px;
      color: #ccc;
      text-decoration: none;
      transition: background 0.15s;
    }
    .pb-dd-item:hover {
      background: rgba(255,255,255,0.06);
      color: #fff;
    }
    .pb-dd-item.logout { color: #e57373; }
    .pb-dd-item.logout:hover { background: rgba(229,115,115,0.1); }
    .pb-dd-divider {
      height: 1px;
      background: rgba(255,255,255,0.08);
      margin: 0 12px;
    }

    /* ===== 覆盖 #sideby（按钮已移入 banner） ===== */
    #sideby { display: none !important; }

    /* ===== 分隔线 ===== */
    .btn-sep {
      width: 1px;
      height: 20px;
      background: rgba(255,255,255,0.15);
      margin: 0 2px;
    }
  </style>
</head>
<body>
<div>
<div class="banner">
  <div class="banner-left">
    <i class="fa fa-codepen"></i>
    <a id="title">Python拼图编程：<%=Titles%></a>
  </div>
  <div class="banner-right">
    <button onclick="helper()" class="button"><i class="fa fa-book" aria-hidden="true"></i>学案</button>
    <div class="btn-sep"></div>
    <button onclick="runit()" class="button btn-run"><i class="fa fa-play-circle" aria-hidden="true"></i>运行</button>
    <button onclick="savecode()" class="button btn-save"><i class="fa fa-save" aria-hidden="true"></i>保存</button>
    <div class="btn-sep"></div>
    <button onclick="returnurl()" class="button"><i class="fa fa-reply" aria-hidden="true"></i>返回</button>
    <div class="pb-user-wrap" id="pbUserWrap">
      <div class="pb-user-trigger" id="pbUserTrigger" onclick="togglePbDropdown()">
        <div class="pb-avatar"><%= Server.HtmlEncode(sUserInitial) %></div>
        <span class="pb-user-name"><%= !string.IsNullOrEmpty(sUserName) ? Server.HtmlEncode(sUserName) : "学生" %></span>
        <svg class="pb-user-arrow" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="pb-dropdown" id="pbDropdown">
        <div class="pb-dd-top">
          <div class="pb-dd-name"><%= !string.IsNullOrEmpty(sUserName) ? Server.HtmlEncode(sUserName) : "学生" %></div>
          <div class="pb-dd-role"><%= !string.IsNullOrEmpty(sUserClass) ? Server.HtmlEncode(sUserClass) : "学生用户" %></div>
        </div>
        <div class="pb-dd-list">
          <a href="../profile/mygroup.aspx" class="pb-dd-item">我的小组</a>
          <a href="../profile/mypwd.aspx" class="pb-dd-item">修改密码</a>
          <a href="../profile/myphoto.aspx" class="pb-dd-item">修改头像</a>
        </div>
        <div class="pb-dd-divider"></div>
        <div class="pb-dd-list">
          <a href="javascript:void(0)" class="pb-dd-item logout" onclick="doPbLogout()">退出登录</a>
        </div>
      </div>
    </div>
  </div>
</div>
<div id="main">
<div id="left">
&nbsp;请将第一块积木拖放到这里！
</div>
<div id="right"></div>
</div>

<div id="content" >
	<%=Mcontents %>
	<br /><br />
</div>
<div id="result">
<div id="savemsg"></div>
<pre id="output" ></pre>
</div>
<div id="cv" ></div>
<div  id="big" onclick="fontbig()" title="放大代码"> </div>
<div  id="small" onclick="fontsmall()" title="缩小代码"> </div>
<div class="map"><img class="mapimg" src="<%=Midurl %>" alt=""/></div>
<div id="done"><img src="../images/sucessed.png"></img></div>
<audio id="myaudio" src="../code/adsorb.ogg" controls="controls"  hidden="true" ></audio>
<div  id="sideby">
<button  onclick="helper()" class="button"  >
<i class="fa fa-book" aria-hidden="true"></i>学案</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="runit()" class="button"  >
<i class="fa fa-play-circle" aria-hidden="true"></i> 运行</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="savecode()" class="button"  >
<i class="fa fa-save" aria-hidden="true"></i> 保存</button>&nbsp;&nbsp;
<span class="sp"></span>
<button  onclick="returnurl()" class="button">
<i class="fa fa-reply" aria-hidden="true"></i> 返回</button>
</div>
	<script type="text/javascript" >  
		var fontsize=25;
	    var editor = ace.edit("right", {
	        theme: "ace/theme/chrome",
	        mode: "ace/mode/python"
	    });
	    editor.setFontSize(fontsize);
	    editor.focus();
		editor.setReadOnly(true);

	    var snum = "<%=Snum %>";
	    var _pbUserNum = '<%= Server.HtmlEncode(sUserNum) %>';
	    if (_pbUserNum) snum = _pbUserNum;
	    var id = "<%=Id %>";
	    var _pbQid = '<%= Server.HtmlEncode(pyQid) %>';
	    if (_pbQid) id = _pbQid;
	    var fpage = "<%=Fpage %>";
        var argcodestr = "<%=argcode %>";
        var arginstr = "<%=argin %>";
        var argin = arginstr.split("#");

        var argout0 = "<%=argout0 %>";
        var argout1 = "<%=argout1 %>";
        var argout2 = "<%=argout2 %>";
        
        var mpass = "<%=mpass %>";

        var codearg = decodeURIComponent(window.atob(argcodestr)); //定义字典 
        var example =codetoarray(codearg,true);


	    var sessionkey = "htmlcode" + snum + "-" + id;

	    function savesession() {
	        var codestr = editor.getValue();
	        if (codestr != null && codestr != "") {
	            sessionStorage.setItem(sessionkey, codestr);

	        }
	    }
	    function getsession() {
	        var codestr = sessionStorage.getItem(sessionkey);
	        if (codestr != null && codestr != "") {
	            editor.setValue(codestr, 1);
	        }
	    }
	    document.onkeyup = keyUp;
	    function keyUp() {
	        savesession();
	    }

function fontbig(){
	fontsize+=1;
	editor.setFontSize(fontsize);	
}

function fontsmall(){
	fontsize-=1;
	if (fontsize<25){
		fontsize=25;
	}
	editor.setFontSize(fontsize);	
}

        function returnurl() {
            // 检查是否为考试模式
            var examvid = (location.search.match(/[?&]examvid=([^&]*)/) || [])[1];
            
            if (examvid && id) {
                // 考试模式：自动保存后返回
                console.log('[考试模式] 检测到考试环境，准备自动保存');
                
                var prog = workspace.toXml(Blockly.mainWorkspace);
                var code = Blockly.Python.workspaceToCode(workspace);
                var trimmedCode = $.trim(code);
                
                // 如果有代码内容，自动保存
                if (trimmedCode && trimmedCode.length > 0) {
                    console.log('[考试模式] 检测到代码，自动保存中...');
                    
                    // 显示保存提示
                    $('#savemsg').html('正在自动保存...').show();
                    
                    // 构造保存请求
                    var urls = 'uploadpython.ashx?id=' + id;
                    var formData = new FormData();
                    
                    // 创建空白封面
                    var emptyCanvas = document.createElement('canvas');
                    emptyCanvas.width = 1;
                    emptyCanvas.height = 1;
                    var emptyBlob = null;
                    emptyCanvas.toBlob(function(blob) {
                        emptyBlob = blob;
                    });
                    
                    formData.append('cover', emptyBlob || new Blob());
                    formData.append('codefile', window.btoa(encodeURIComponent(code)));
                    formData.append('codedict', window.btoa(encodeURIComponent(prog)));
                    formData.append('pass', 0);
                    
                    $.ajax({
                        url: urls,
                        type: 'POST',
                        cache: false,
                        data: formData,
                        processData: false,
                        contentType: false,
                        async: false  // 同步请求
                    }).done(function(res) {
                        console.log('[考试模式] 自动保存成功');
                        // 写入localStorage标记
                        localStorage.setItem('exam_' + examvid + '_u_' + snum + '_q_' + id, 'done');
                        // 通知父窗口
                        if (window.opener && !window.opener.closed) {
                            window.opener.postMessage({type:'examCodingSaved', qid:id, examvid:examvid}, '*');
                        }
                        // 清除session并返回
                        sessionStorage.clear();
                        window.location.href = fpage;
                    }).fail(function() {
                        console.error('[考试模式] 自动保存失败');
                        if (confirm('代码保存失败，是否仍要返回？')) {
                            sessionStorage.clear();
                            window.location.href = fpage;
                        }
                    });
                } else {
                    // 没有代码，直接返回
                    console.log('[考试模式] 无代码内容，直接返回');
                    sessionStorage.clear();
                    window.location.href = fpage;
                }
            } else {
                // 非考试模式：原有逻辑
                if (confirm('确定要返回吗？记得先保存。') == true) {
                    sessionStorage.clear();
                    window.location.href = fpage;
                }
            }
        }

		var minleft=360;
		var mintop=42; 
		var toplist=[];
		var leftlist=[];
		var curtop;

        $(function () {
			if(mpass=="1"){
				rightblock();
				$('#done').show();
			}
			else{
				arrayblock();
				$('#done').hide();
			}
            init();
			
            function init() {
				
                $('.brick').draggable({ opacity: 0.3, helper: 'original', grid: [14, 14],
                    containment: "#left", snap: true, snapTolerance: 14,
					start:function(){
						curtop = $(this).offset().top;//获取拖放前的位置					
					},					
                    drag: function (event, ui) {
						var tpos = $(this).offset().top;
						//console.log("设置上边距",tpos);
						if(isoverlap(tpos)){							
							$(this).draggable({revert: true});//重叠
						}
						else{								
							$(this).draggable({revert: false});//空位
						}	
                    },
					stop: function (event, ui) {
                        var x = $(this).offset().left;
                        var y = $(this).offset().top;	
						var lpos=4+60*(Math.floor(x/30)-Math.floor(x/60));//缩进4个空格宽度为60像素
						//var ttpos=28*(Math.floor(y/14)-Math.floor(y/28))-14;//行距28像素
						
						$(this).offset({left:lpos});
						//console.log("设置左边距",lpos);
						if(y<70){
							y=mintop;
						}
						$(this).offset({top:y});
						//console.log(y,"左",lpos,"上",y,ttpos);
						
						if(lpos<minleft){
							minleft=lpos;
						}						
						blocktocode();
						voiceplay();
					}

                });
                $(".brick").css("cursor", "move");
			
            }
			
			
        });
		
		function isoverlap(top){
			var isres=false;
			var str="空位";
			//console.clear();
			for(var i=0;i<toplist.length;i++){
				var item=toplist[i];
				var min=item-2;
				var max=item+2;
				
				//console.log(top,"当前位置",item);
				if(top>=min && top<max && top!=curtop){
					console.log("重叠",min,top,max,curtop);
					return true;
				}
				else{
					//console.log("空位",min,top,max);
				}
			
			}				
			
			return isres;
		}
			
		function blocktocode(){
			//console.log("blocktocode生成代码：");
			var $block=$('.brick');		
			var codestr="";
			var dict={};
			var posi={};
			//console.clear();
			$block.each(function(i){
				var lpos=$(this).offset().left;		
				var tpos=$(this).offset().top;
				dict[tpos]=$(this).text();//记录排序前代码文本位置
				if($(this).text()=="　　　　　　"){
					dict[tpos]="";
				}
				//console.log("左",lpos,"上",tpos," ",dict[tpos]);
				posi[tpos]=lpos;
				toplist[i]=tpos;
				leftlist[i]=lpos;
			})
			
			//console.log(dict);
			var res = Object.keys(dict).sort((a,b)=>a-b);
			for (var key in res){
				var newlpos=posi[res[key]];
				var returnstr="";
				if(key<res.length-1){
					returnstr="\r\n";
				}
				var linecode=tabnum(newlpos)+dict[res[key]]+returnstr;//获取排序后代码文本
				codestr=codestr+linecode;
				//console.log(key,linecode);
			}
			//console.log(posi);
			//console.log(codestr);	
			editor.setValue(codestr, 1);
			$('#result').hide();
		}
		
		function tabnum(newlpos){
			var n=parseInt((newlpos-minleft)/50);
			console.log("左边距",newlpos,"最左边",minleft,n);
			var str="";
			for(var i=0;i<n;i++){
				str=str+"    ";
			}
			return str;
		}
		
		function arrayblock(){
			console.log("arrayblock");
			if(example.length>0){
				var blockplace=document.getElementById("left");
				example.sort(function () {
					return Math.random() - 0.5
				})
				
				for(var i=0;i<example.length;i++){
					var span=document.createElement("span");
					span.innerText=example[i];
					span.className="brick";
					//console.log(i,'上:',mytop,mytop+44)
					span.style.backgroundColor="#76A9DC";	
					if(example[i].indexOf("print")!=-1){
						span.style.backgroundColor="#95CA97";				
					}
					//默认方块为蓝色#76A9DC，如果为输出设置为绿#95CA97，如果为输入设置为红#DDA3C1 紫#A78BD3 淡黄#EFEFDE
					if(example[i].indexOf("input")!=-1){
						span.style.backgroundColor="#DDA3C1";				
					}
					if(example[i].indexOf("from")!=-1){
						span.style.backgroundColor="#A78BD3";				
					}
					if(example[i].indexOf("for ")!=-1){
						span.style.backgroundColor="#D8C07A";				
					}				
					if(example[i].indexOf("while")!=-1){
						span.style.backgroundColor="#D8C07A";				
					}				
					if(example[i].indexOf("if")!=-1){
						span.style.backgroundColor="#B5BB85";				
					}				
					if(example[i].indexOf("else")!=-1){
						span.style.backgroundColor="#B5BB85";				
					}				
					if(example[i].indexOf("elif")!=-1){
						span.style.backgroundColor="#B5BB85";				
					}
					if(example[i]==""){	
						span.style.backgroundColor="#E1E1CD";
						span.innerText="　　　　　　";
					}					
					blockplace.appendChild(span);			
				}
			
				var $block=$('.brick');		
				var dict={};
				var myleft=120;
				var mytop=166;
				$block.each(function(i){				
					mytop=mytop+38;//横幅高40像素，4像素间隙，积木行距38
					
					$(this).offset({left:myleft,top:mytop});
					
					var lpos=$(this).offset().left;
					var tpos=$(this).offset().top;
					
					dict[tpos]=example[i];
					//console.log(i,"左",lpos,"上",tpos,dict[tpos]);
					toplist[i]=tpos;					
					leftlist[i]=lpos;
				})
				
				var footer=document.createElement("span");
				footer.innerText=".";
				footer.className="blank";
				blockplace.appendChild(footer);
				$(".blank").offset({top:mytop+38});
				
				$('#result').hide();//隐藏输出控制台
			}
			else{
				savemsg.innerHTML= "未设定批改程序，请咨询老师！";
			}
		}
			
		function countblank(str){
			var count=0;
			for(var i=0;i<str.length;i++){
				var c=str[i]
				if(c==' '){
					count++;
				}
				else{
					break;
				}
			}
			return count;
		}
		
		function rightblock(){
			var blockplace=document.getElementById("left");
			var codeargarray=codetoarray(codearg,false);
			console.log("已保存的正确拼图");
			//console.log(codeargarray);
			for(var i=0;i<example.length;i++){
				var span=document.createElement("span");
				//console.log(i,"空格数：",blankcount);
				span.innerText=example[i].trim();
				span.className="brick";
				var mytop=4+i*28;
				span.style.top=mytop+"px";
				//console.log(i+1,mytop,example[i]);
								
				span.style.backgroundColor="#76A9DC";	
				if(example[i].indexOf("print")!=-1){
					span.style.backgroundColor="#95CA97";				
				}
				//默认方块为蓝色#76A9DC，如果为输出设置为绿#95CA97，如果为输入设置为红#DDA3C1 紫#A78BD3 淡黄#EFEFDE
				if(example[i].indexOf("input")!=-1){
					span.style.backgroundColor="#DDA3C1";				
				}
				if(example[i].indexOf("from")!=-1){
					span.style.backgroundColor="#A78BD3";				
				}
				if(example[i].indexOf("for ")!=-1){
					span.style.backgroundColor="#D8C07A";				
				}				
				if(example[i].indexOf("while")!=-1){
					span.style.backgroundColor="#D8C07A";				
				}				
				if(example[i].indexOf("if")!=-1){
					span.style.backgroundColor="#B5BB85";				
				}				
				if(example[i].indexOf("else")!=-1){
					span.style.backgroundColor="#B5BB85";				
				}				
				if(example[i].indexOf("elif")!=-1){
					span.style.backgroundColor="#B5BB85";				
				}
				if(example[i]==""){	
						span.style.backgroundColor="#E1E1CD";
						span.innerText="　　　　　　";
					}					
				
				blockplace.appendChild(span);			
			}		
		
			var $block=$('.brick');	
			$block.each(function(i){				
				var codeline=codeargarray[i];
				var blankcount=countblank(codeline);
				
				var myleft=4+15*blankcount;
				var mytop=44+i*28;//横幅高40像素，4像素间隙
				$(this).offset({left:myleft,top:mytop});
				
				var lpos=$(this).offset().left;
				var tpos=$(this).offset().top;
				
				if(lpos<minleft){
					minleft=lpos;
				}
				//console.log(i+1,"空",blankcount,"上",tpos,codeline);
			})
			$('#result').hide();//隐藏输出控制台
			
			editor.setValue(codearg, 1);
		}
		
    	$("#left").click(function(){
		  $("#result").slideUp();
		});
		$("#title").click(function(){
		  $("#result").slideDown();
		  $("#cv").slideDown();
		});

        $("#right").click(function(){
		  $("#content").slideUp();
		  $("#cv").slideUp();
		});

        function  helper(){
	        $("#content").slideToggle();	
        }

		function randomsort(a, b) {
		  return Math.random()>.5 ? -1 : 1; //通过随机产生0到1的数，然后判断是否大于0.5从而影响排序，产生随机性的效果。
		}
	

$("#content").slideDown();

var mypre = document.getElementById("output");
var result = document.getElementById("result");
var savemsg = document.getElementById("savemsg");
function outf(text) {
    mypre.innerHTML = mypre.innerHTML + text;
}
function builtinRead(x) {
    if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][x] === undefined)
            throw "File not found: '" + x + "'";
    return Sk.builtinFiles["files"][x];
}

function myfun() {
	return new Promise(function(resolve,reject){		
		var myinput=document.createElement("input");
		myinput.setAttribute("type","text");
		myinput.setAttribute("class","input");
		mypre.appendChild(myinput);
		myinput.focus();
        result.onclick=function(){
            myinput.focus();
        }

		myinput.onkeypress =function() {
             if (event.keyCode == 13)
             {
				var argv=myinput.value;	
				console.log(argv);
				mypre.removeChild(myinput);
                mypre.innerHTML= mypre.innerHTML+argv+" \n";				
                resolve(argv);
             }
         }
      })
}	
var isrun=false;
var isright=true;
 
function savecode(){
	var prog = editor.getValue();
	if(prog!=null&&prog!=""){		
		if(isrun){
			if(comparecode(prog,codearg)){
			   $('#done').show();
			   alert("恭喜！ 拼图成功！");
			}
			else{
				$('#done').hide();
				alert("拼图失败，请继续努力！");
			}
			uploadblock(prog);			
		}
		else{		
			alert("程序运行正常后，再点击保存！");		
		}				
	}
	else{		
		alert("根据学案代码拼图后再运行程序！");			
	}
	isrun=false;
}

function comparecode(prog,codearg){
	//prog.replace(/\r/g,"");
	var parray=prog.split("\n");
	//console.log("编辑器:\n",parray);
	//codearg.replace(/\r/g,"");
	var carray=codearg.split("\n");
	//console.log("原程序:\n",carray);	
	console.log("代码比对开始");	
	isright=true;
	for(var i=0;i<parray.length;i++){
		var pstr=parray[i].replace("\r","");
		var cstr=carray[i].replace("\r","");
		if(pstr.trim()!=cstr.trim()){
			console.log(i,"错误",pstr,cstr);		
			isright=false;
		}
		else{
			//console.log(i,"正确",pstr,cstr);		
		}
		
	}	
	return isright;
}

function uploadblock(prog){
    var res=document.querySelector("#result");
	var obj=$("#cv").find("canvas")[1];			
	if(!obj) {
		$("#cv").hide();
		console.log("无绘图");
		obj=res;
	}
	var opts = {
		backgroundColor: "transparent", 
    };
	html2canvas(obj).then(pic => {		   
	   var dataURL=pic.toDataURL();
	   //console.log(dataURL);

	   if(dataURL=="data:,"){
			dataURL="data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==";
	   }
       		
	   var Cover=blob(dataURL);	   
	   console.log('保存快照'); 
	   var pass=-1;
	   if(isright){
		   pass=3;
	   }
	   
		var urls = 'uploadblock.ashx?id=' + id;
		var formData = new FormData();
		formData.append('cover', Cover);
		formData.append('codefile', window.btoa(encodeURIComponent(prog)));
		formData.append('codedict', '');
		formData.append('pass',pass);

		$.ajax({
			url: urls,
			type: 'POST',
			cache: false,
			data: formData,
			processData: false,
			contentType: false
		}).done(function (res) { 
			// 考试模式：通知考试页面已保存
			try {
				var _ev = (location.search.match(/[?&]examvid=([^&]*)/) || [])[1];
				if (_ev && id) {
					// 写入 localStorage（含学号，与 myexam.aspx 一致）
					localStorage.setItem('exam_' + _ev + '_u_' + snum + '_q_' + id, 'done');
					// postMessage 备用通道
					if (window.opener && !window.opener.closed) {
						window.opener.postMessage({type:'examCodingSaved', qid:id, examvid:_ev}, '*');
					}
				}
			} catch(ex){}
			if(argcodestr!=""&& argcodestr!=null){
				if(isright){  //如果代码拼图正确，标志为3那么										
					savemsg.innerHTML= "恭喜！ 代码拼图正确，保存成功。";
				}
				else{					
					savemsg.innerHTML= "拼图失败，请继续努力！保存成功。";
				}
			}
			// 考试模式：保存成功后弹窗确认并关闭窗口
			var _evRet = (location.search.match(/[?&]examvid=([^&]*)/) || [])[1];
			if (_evRet && typeof fpage !== 'undefined' && fpage) {
				alert("保存成功！");
				window.close();
				setTimeout(function(){ window.location.href = fpage; }, 300);
			}
		}).fail(function (res) {
			savemsg.innerHTML= "保存失败！";
			console.log(res)
		}); 			

		});	

}

function blob(dataURI) {
        var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]; 
        var byteString = atob(dataURI.split(',')[1]); 
        var arrayBuffer = new ArrayBuffer(byteString.length); 
        var intArray = new Uint8Array(arrayBuffer); 

        for (var i = 0; i < byteString.length; i++) {
            intArray[i] = byteString.charCodeAt(i);
        }
        return new Blob([intArray], {type: mimeString});
}
	
function runit() {
    var prog = editor.getValue();
	if(prog!=null&&prog!=""){
		$("#content").slideUp();
		$("#cv").slideDown();
		$('#result').show();
		mypre.innerHTML = '';
		output.innerHTML = '';
		savemsg.innerHTML='';
		Sk.pre = "output";		
		Sk.configure({ output: outf, read: builtinRead,execLimit: 600000, __future__: Sk.python3, inputfun: myfun});

		(Sk.TurtleGraphics || (Sk.TurtleGraphics = {})).target = 'cv';
		Sk.TurtleGraphics.width=cv.clientWidth;
		Sk.TurtleGraphics.height=cv.clientHeight;
		var dateBegin = new Date();

		var myPromise = Sk.misceval.asyncToPromise(function() {
			return Sk.importMainWithBody("<stdin>", false, prog, true);
		});
	 
		myPromise.then(function(mod) {
			var dateEnd = new Date();
			var dateDiff = (dateEnd.getTime() - dateBegin.getTime())/1000;
			var spendtime='耗时'+dateDiff+"秒"
			console.log(spendtime);			
			
			msgerror="";
			console.log('运行成功!');
			savemsg.innerHTML = spendtime;
            isrun=true;
		},
		function(err) {	
			pass=-1;//如果异常，标志为-1
			var msg=err.toString();
			console.log(msg);
			if(msg.indexOf("TimeLimitError")>0){
				msg="运行超时！";
			}
			savemsg.innerHTML = msg;
			msgerror=msg;
		});
	}	
	else{
		alert("根据学案代码拼图后再运行程序！");
		savemsg.innerHTML= "当前没有代码，无法运行！";
	}
	
}
	
function voiceplay(){
	document.getElementById("myaudio").play();
}
		
function codetoarray(str,istrim){
	if(str !=null&& str.length != 0){
		//str.replace(/\r/g,"");
		var codearray=str.split("\n");		
		//console.log(codearray);
		if(istrim){
			for(c in codearray){
				codearray[c]=codearray[c].trim();
			}
		}
		return codearray;
	}
	else{
		return "";
	}
}

	// ===== 用户下拉菜单 =====
	function togglePbDropdown() {
		var trigger = document.getElementById('pbUserTrigger');
		var dropdown = document.getElementById('pbDropdown');
		if (!trigger || !dropdown) return;
		var isOpen = dropdown.classList.contains('show');
		if (isOpen) {
			dropdown.classList.remove('show');
			trigger.classList.remove('open');
		} else {
			dropdown.classList.add('show');
			trigger.classList.add('open');
		}
	}
	document.addEventListener('click', function(e) {
		var wrap = document.getElementById('pbUserWrap');
		if (wrap && !wrap.contains(e.target)) {
			var trigger = document.getElementById('pbUserTrigger');
			var dropdown = document.getElementById('pbDropdown');
			if (dropdown) dropdown.classList.remove('show');
			if (trigger) trigger.classList.remove('open');
		}
	});
	function doPbLogout() {
		if (confirm('确定退出登录？')) {
			document.cookie.split(';').forEach(function(c) {
				document.cookie = c.replace(/^ +/, '').replace(/=.*/, '=;expires=' + new Date(0).toUTCString() + ';path=/');
			});
			window.location.href = '../index.aspx';
		}
	}
	</script>

    </div>
</body>
</html>
