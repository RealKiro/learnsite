<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_problem, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style type="text/css">
    /* ===== Python编程测评页面美化 ===== */
    .prob-container {
        max-width: 1600px;
        margin: 0 auto;
        padding: 0 16px 40px;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
    }
    
    /* 页头 */
    .prob-header {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
        padding: 24px 28px;
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
        border-radius: 16px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(5,150,105,.25);
    }
    
    .prob-header::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -30px;
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    
    .prob-header-icon {
        width: 52px;
        height: 52px;
        background: rgba(255,255,255,.18);
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        backdrop-filter: blur(10px);
        flex-shrink: 0;
        position: relative;
        z-index: 1;
    }
    
    .prob-header-icon svg {
        width: 26px;
        height: 26px;
        stroke: #fff;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .prob-header-text {
        position: relative;
        z-index: 1;
        flex: 1;
    }
    
    .prob-header-title {
        font-size: 22px;
        font-weight: 700;
        color: #fff;
        margin: 0 0 4px 0;
        line-height: 1.3;
    }
    
    .prob-header-sub {
        font-size: 13px;
        color: rgba(255,255,255,.75);
        margin: 0;
    }
    
    /* 设置栏 */
    .prob-settings {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 20px;
        padding: 14px 20px;
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,.04);
    }
    
    .prob-set-label {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
    }
    
    .prob-settings select {
        padding: 6px 12px;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        font-size: 13px;
        color: #334155;
        background: #fafbfc;
        outline: none;
        cursor: pointer;
        transition: border-color 0.2s;
    }
    
    .prob-settings select:focus {
        border-color: #10b981;
        box-shadow: 0 0 0 2px rgba(16,185,129,0.1);
    }
    
    /* 题目内容卡片 */
    .prob-content-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,.04);
        margin-bottom: 20px;
        overflow: hidden;
    }
    
    .prob-content-head {
        padding: 16px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
    }
    
    .prob-content-head .prob-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: linear-gradient(135deg, #059669, #34d399);
        flex-shrink: 0;
    }
    
    .prob-content-head h3 {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
    }
    
    .prob-content-head h3 svg {
        width: 18px;
        height: 18px;
        stroke: #059669;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .prob-content-body {
        padding: 20px 24px;
    }
    
    /* KindEditor样式 */
    .prob-content-body .ke-container {
        border-radius: 8px !important;
        border: 1px solid #e2e8f0 !important;
        overflow: hidden;
    }
    
    .prob-content-body .ke-toolbar {
        background: #f8f9fc !important;
        border-bottom: 1px solid #e8eaef !important;
    }
    
    /* 编辑器区域 */
    .prob-editor-section {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
        align-items: stretch;
    }
    
    .prob-editor-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,.04);
        overflow: hidden;
        display: flex;
        flex-direction: column;
        min-height: 500px;
    }
    
    .prob-editor-head {
        padding: 14px 20px;
        background: linear-gradient(135deg, #1e293b, #334155);
        color: #fff;
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
    }
    
    .prob-editor-head svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .prob-editor-body {
        flex: 1;
        display: flex;
        flex-direction: column;
        position: relative;
        min-height: 450px;
    }
    
    #editor {
        height: 100%;
        min-height: 450px;
        background-color: #1e293b;
        border: none;
        flex: 1;
    }
    
    #result {
        height: 100%;
        min-height: 450px;
        background-color: #1e293b;
        color: #e2e8f0;
        border: none;
        overflow: auto;
        flex: 1;
    }
    
    #output {
        text-align: left;
        padding: 16px;
        font-family: 'Consolas', 'Monaco', monospace;
        font-size: 14px;
        line-height: 1.6;
        white-space: pre-wrap;
        word-wrap: break-word;
    }
    
    .input {
        font-size: 14px;
        height: 24px;
        border: 1px solid #10b981;
        background: #fff;
        color: #1e293b;
        padding: 4px 8px;
        border-radius: 4px;
        outline: none;
        font-family: 'Consolas', 'Monaco', monospace;
    }
    
    .input:focus {
        border-color: #059669;
        box-shadow: 0 0 0 2px rgba(16,185,129,0.2);
    }
    
    /* 控制栏 */
    #centerbar {
        position: absolute;
        right: 24px;
        top: 50%;
        transform: translateY(-50%);
        z-index: 10;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    
    #centerbar button {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 10px 20px;
        border: none;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        white-space: nowrap;
    }
    
    #centerbar button:first-child {
        background: linear-gradient(135deg, #10b981, #059669);
        color: #fff;
    }
    
    #centerbar button:first-child:hover {
        background: linear-gradient(135deg, #059669, #047857);
        box-shadow: 0 4px 12px rgba(16,185,129,0.3);
        transform: translateY(-2px);
    }
    
    #centerbar button:last-child {
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
        color: #475569;
    }
    
    #centerbar button:last-child:hover {
        background: linear-gradient(135deg, #e2e8f0, #cbd5e1);
        color: #334155;
        transform: translateY(-2px);
    }
    
    /* 操作按钮 */
    .prob-actions {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 20px 24px;
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,.04);
    }
    
    .prob-actions input[type="submit"] {
        padding: 10px 28px !important;
        border: none !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        cursor: pointer;
        transition: all 0.2s;
        height: auto !important;
        width: auto !important;
        line-height: 1.5 !important;
    }
    
    .prob-actions #Btnadd {
        background: linear-gradient(135deg, #10b981, #059669) !important;
        color: #fff !important;
        box-shadow: 0 2px 8px rgba(16,185,129,0.2);
    }
    
    .prob-actions #Btnadd:hover {
        background: linear-gradient(135deg, #059669, #047857) !important;
        box-shadow: 0 4px 14px rgba(16,185,129,0.3);
        transform: translateY(-1px);
    }
    
    .prob-actions #Btnreturn {
        background: #fff !important;
        color: #64748b !important;
        border: 1px solid #e2e8f0 !important;
    }
    
    .prob-actions #Btnreturn:hover {
        background: #f8fafc !important;
        color: #334155 !important;
        border-color: #cbd5e1 !important;
    }
    
    /* 响应式 */
    @media (max-width: 1200px) {
        .prob-editor-section {
            grid-template-columns: 1fr;
        }
        
        #centerbar {
            position: static;
            transform: none;
            flex-direction: row;
            justify-content: center;
            margin: 16px 0;
        }
    }
    
    @media (max-width: 768px) {
        .prob-container {
            padding: 0 8px 24px;
        }
        
        .prob-header {
            padding: 20px 16px;
        }
        
        .prob-settings {
            flex-direction: column;
            align-items: stretch;
        }
        
        #editor,
        #result {
            height: 300px;
        }
    }
</style>

<div class="prob-container">
    <!-- 页头 -->
    <div class="prob-header">
        <div class="prob-header-icon">
            <svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/><line x1="14" y1="4" x2="10" y2="20"/></svg>
        </div>
        <div class="prob-header-text">
            <h1 class="prob-header-title">Python编程测评</h1>
            <p class="prob-header-sub">在线编写和测试Python代码，支持实时运行和结果查看</p>
        </div>
    </div>
    
    <!-- 设置栏 -->
    <div class="prob-settings">
        <span class="prob-set-label">分值：</span>
        <asp:DropDownList ID="ddscore" runat="server">
            <asp:ListItem Value="1">1分</asp:ListItem>
            <asp:ListItem Selected="True" Value="2">2分</asp:ListItem>
            <asp:ListItem Value="3">3分</asp:ListItem>
            <asp:ListItem Value="4">4分</asp:ListItem>
            <asp:ListItem Value="5">5分</asp:ListItem>
        </asp:DropDownList>
    </div>
    
    <!-- 题目内容 -->
    <div class="prob-content-card">
        <div class="prob-content-head">
            <span class="prob-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                试题内容
            </h3>
        </div>
        <div class="prob-content-body">
            <textarea id="mcontent" runat="server" name="textareaWord" style="width: 100%; height:120px;"></textarea>
        </div>
    </div>
    
    <!-- 编辑器区域 -->
    <div class="prob-editor-section">
        <!-- 代码编辑器 -->
        <div class="prob-editor-card">
            <div class="prob-editor-head">
                <svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
                Python代码编辑器
            </div>
            <div class="prob-editor-body">
                <div id="editor"></div>
                <div id="centerbar">
                    <button onclick="runit()" type="button">
                        <svg viewBox="0 0 24 24" style="width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                        运行
                    </button>
                    <button onclick="clearit()" type="button">
                        <svg viewBox="0 0 24 24" style="width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                        清空
                    </button>
                </div>
            </div>
        </div>
        
        <!-- 运行结果 -->
        <div class="prob-editor-card">
            <div class="prob-editor-head">
                <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                运行结果
            </div>
            <div class="prob-editor-body">
                <div id="result">
                    <pre id="output"></pre>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 操作按钮 -->
    <div class="prob-actions">
        <asp:Button ID="Btnadd" runat="server" OnClick="Btnadd_Click" Text="添加题目" />
        <asp:Button ID="Btnreturn" runat="server" OnClick="Btnreturn_Click" Text="返回列表" />
    </div>
    
    <!-- 隐藏字段 -->
    <div style="display: none;">
        <asp:HiddenField ID="code" runat="server" />
        <asp:HiddenField ID="print" runat="server" />
    </div>
</div>
  <!-- 主要文件 -->
  <script src="../code/build/src/ace.js" type="text/javascript"></script>
  <!-- 用来提供代码提示和自动补全的插件 -->
  <script src="../code/build/src/ext-language_tools.js" type="text/javascript"></script>
  <script src="../code/build/src/ext-beautify.js" type="text/javascript"></script>
  <script type="text/javascript">
    // ace.require("ace/ext/language_tools");
    // 初始化editor(）
    var aeditor = ace.edit("editor");
    aeditor.setOptions({
      // 默认:false
      wrap: true, // 换行
      // autoScrollEditorIntoView: false, // 自动滚动编辑器视图
      enableLiveAutocompletion: true, // 智能补全
      enableSnippets: true, // 启用代码段
      //enableBasicAutocompletion: true, // 启用基本完成 不推荐使用
    });
    // 设置主题  cobalt monokai vscode xcode textmate sqlserver  twilight
    aeditor.setTheme("ace/theme/monokai");
    // 设置编辑语言
    aeditor.getSession().setMode("ace/mode/python");
    aeditor.setFontSize(16);
    aeditor.setReadOnly(false)
    aeditor.getSession().setTabSize(4);

  </script>


<script src="../code/skulpt.min.js" type="text/javascript"></script>
<script src="../code/skulpt-stdlib.js" type="text/javascript"></script>
<script src="../code/html2canvas.min.js" type="text/javascript"></script>
<script src="../code/jquery.min.js" type="text/javascript"></script>

<script type="text/javascript">
    var mycode = document.getElementById("code");
    var pprint = document.getElementById("print");

    var mypre = document.getElementById("output");
    var result = document.getElementById("result");

    function outf(text) {
        mypre.innerText = mypre.innerText + text;
    }
    function builtinRead(x) {
        if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][x] === undefined)
            throw "File not found: '" + x + "'";
        return Sk.builtinFiles["files"][x];
    }

    result.onclick = function () {
        output.focus();
    }

    function initedit() {
        var cc = mycode.value;
        var pp = pprint.value;
        if (cc.length > 0) {
            aeditor.setValue(cc);
            mypre.innerText = pp;
        }
    }

    window.onload = function () {
        mycode = document.getElementById("code");
        pprint = document.getElementById("print");
        console.log(mycode);
        console.log(pprint);
        initedit();
    }

    function myfun() {
        return new Promise(function (resolve, reject) {
            var myinput = document.createElement("input");
            myinput.setAttribute("type", "text");
            myinput.setAttribute("class", "input");
            mypre.appendChild(myinput);
            myinput.focus();
            result.onclick = function () {
                myinput.focus();
            }

            myinput.onkeypress = function () {
                if (event.keyCode == 13) {
                    args = myinput.value;
                    console.log(args);
                    resolve(args);
                    mypre.removeChild(myinput);
                    temp = mypre.innerText;
                    temp = temp + args;
                    mypre.innerHTML = temp + "\n";
                }
            }
        })
    }
    function clearit() {
        output.innerHTML = '';
        mypre.innerHTML = '';
        pprint.value = '';
    }
    function runit() {
        var prog = aeditor.getValue();
        mypre.innerHTML = '';
        output.innerHTML = '';
        Sk.pre = "output";
        Sk.configure({ output: outf, read: builtinRead, __future__: Sk.python3, inputfun: myfun });

        var myPromise = Sk.misceval.asyncToPromise(function () {
            return Sk.importMainWithBody("<stdin>", false, prog, true);
        });

        myPromise.then(function (mod) {
            console.log('运行成功!');
            mycode.value = prog;
            pprint.value = output.innerText;
            console.log('代码：');
            console.log(mycode.value);
            console.log('输出结果：');
            console.log(pprint.value);
            //getsvg();
        },
    function (err) {
        var msg = err.toString();
        console.log(msg);
        mypre.innerHTML = msg;
    });
    }

    function getsvg() {
        var op = output.innerHTML;
        if (op == '') {
            var canvas = document.createElement("canvas");
            if (canvas != null) {
                var dataUrl = canvas.toDataURL('image/jpeg');
                pprint.value = dataUrl;
                console.log(dataUrl);
            }
        }
    }

    document.onkeyup = keyUp;
    function keyUp() {
        var prog = aeditor.getValue();
        mycode.value = prog;
        voice();
    }
    function voice() {
        var audio = document.createElement("audio");
        audio.src = '../code/code.ogg';
        audio.play();
    }
</script>
<script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
<script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>
<script>
	var keditor;
	var cid= <%=myCid() %>;
	var ty="Course";
	var upjs= '../kindeditor/aspnet/upload_json.aspx?cid='+cid+'&ty='+ty;
	var fmjs='../kindeditor/aspnet/file_manager_json.aspx?cid='+cid+'&ty='+ty;
	KindEditor.ready(function (K) {
		keditor = K.create('textarea[name="mcontent"]', {
		    resizeType: 1,
		    pasteType: 1,
		    newlineTag: "br",				
			uploadJson : upjs,
			fileManagerJson : fmjs,
			allowFileManager : true,
		    allowImageUpload: true,
		    items: ['fontname', 'fontsize', '|', 'bold', 'italic','removeformat','image','about']
		});
	});
</script> 
</asp:Content>