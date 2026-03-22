<%@ page language="C#" autoeventwireup="true" inherits="student_htmleditor, LearnSite" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head >  
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
		* {
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		
		body {
			margin: 0;
			overflow: hidden;
			font-family: 'Segoe UI', 'Microsoft YaHei', -apple-system, BlinkMacSystemFont, sans-serif;
			background: #f8fafc;
		}
		
		/* 顶部工具栏 */
		.html_banner {
			height: 56px;
			display: flex;
			align-items: center;
			padding: 0 24px;
			background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
			color: #fff;
			user-select: none;
			box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
			position: relative;
			z-index: 1000;
		}
		
		.html_banner .icon {
			background: rgba(255, 255, 255, 0.2);
			color: #fff;
			padding: 8px 16px;
			border-radius: 8px;
			font-weight: 600;
			font-size: 14px;
			backdrop-filter: blur(10px);
			display: flex;
			align-items: center;
			gap: 8px;
		}
		
		.html_banner .icon::before {
			content: '🌐';
			font-size: 18px;
		}
		
		#main {
			display: flex;
			height: calc(100vh - 56px);
			background: #f1f5f9;
		}
		
		/* 左侧编辑器区域 */
		#left {
			width: calc(55% - 6px);
			background: #1e293b;
			position: relative;
			box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
		}
		
		/* 分隔条 */
		#resize {
			width: 6px;
			height: 100%;
			cursor: ew-resize;
			background: linear-gradient(90deg, #e2e8f0 0%, #cbd5e1 50%, #e2e8f0 100%);
			position: relative;
			transition: all 0.2s;
		}
		
		#resize::before {
			content: '';
			position: absolute;
			left: 50%;
			top: 50%;
			transform: translate(-50%, -50%);
			width: 3px;
			height: 40px;
			background: #94a3b8;
			border-radius: 2px;
		}
		
		#resize:hover {
			background: linear-gradient(90deg, #cbd5e1 0%, #94a3b8 50%, #cbd5e1 100%);
		}
		
		#resize:hover::before {
			background: #64748b;
		}
		
		/* 右侧预览区域 */
		#right {
			width: 45%;
			background: #ffffff;
			position: relative;
			box-shadow: inset 0 0 0 1px #e2e8f0;
		}
		
		/* 关键词工具栏 */
		#tooltip {
			position: absolute;
			top: 12px;
			left: 180px;
			right: 420px;
			height: 40px;
			display: flex;
			align-items: center;
			gap: 8px;
			user-select: none;
			background: rgba(255, 255, 255, 0.15);
			backdrop-filter: blur(10px);
			padding: 0 16px;
			border-radius: 10px;
			z-index: 999;
			overflow-x: auto;
			overflow-y: hidden;
		}
		
		#tooltip::-webkit-scrollbar {
			height: 4px;
		}
		
		#tooltip::-webkit-scrollbar-thumb {
			background: rgba(255, 255, 255, 0.3);
			border-radius: 2px;
		}
		
		.keyword {
			display: inline-flex;
			align-items: center;
			padding: 6px 12px;
			color: #fff;
			background: rgba(255, 255, 255, 0.15);
			border: 1px solid rgba(255, 255, 255, 0.2);
			border-radius: 6px;
			font-size: 13px;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.2s;
			white-space: nowrap;
			backdrop-filter: blur(5px);
		}
		
		.keyword:hover {
			background: rgba(255, 255, 255, 0.25);
			border-color: rgba(255, 255, 255, 0.4);
			transform: translateY(-1px);
			box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
		}
		
		/* 左侧工具栏 */
		#tool {
			position: absolute;
			left: 16px;
			bottom: 24px;
			z-index: 1000;
			background: rgba(30, 41, 59, 0.95);
			padding: 12px;
			border-radius: 12px;
			box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
			backdrop-filter: blur(10px);
		}
		
		#tool i {
			color: #94a3b8;
			font-size: 20px;
			cursor: pointer;
			transition: all 0.2s;
			display: block;
			padding: 8px;
			border-radius: 6px;
		}
		
		#tool i:hover {
			color: #fff;
			background: rgba(255, 255, 255, 0.1);
			transform: scale(1.1);
		}
		
		#tool br {
			display: block;
			height: 8px;
		}
		
		/* 右侧操作按钮 */
		#sideby {
			position: absolute;
			right: 24px;
			top: 12px;
			z-index: 999;
			display: flex;
			align-items: center;
			gap: 10px;
		}
		
		button {
			display: inline-flex;
			align-items: center;
			gap: 8px;
			padding: 10px 18px;
			background: rgba(255, 255, 255, 0.15);
			color: #fff;
			border: 1px solid rgba(255, 255, 255, 0.2);
			border-radius: 8px;
			font-size: 14px;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.2s;
			backdrop-filter: blur(10px);
			font-family: inherit;
		}
		
		button:hover {
			background: rgba(255, 255, 255, 0.25);
			border-color: rgba(255, 255, 255, 0.4);
			transform: translateY(-1px);
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
		}
		
		button.buttonsave {
			background: linear-gradient(135deg, #10b981 0%, #059669 100%);
			border-color: transparent;
			box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
		}
		
		button.buttonsave:hover {
			background: linear-gradient(135deg, #059669 0%, #047857 100%);
			box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
		}
		
		button.button {
			background: rgba(239, 68, 68, 0.15);
			border-color: rgba(239, 68, 68, 0.3);
		}
		
		button.button:hover {
			background: rgba(239, 68, 68, 0.25);
			border-color: rgba(239, 68, 68, 0.5);
		}
		
		.sp {
			width: 0;
			display: none;
		}
		
		.spl {
			width: 16px;
			display: inline-block;
		}
		
		/* 文件名输入框 */
		#html_page {
			border: 0;
			outline: none;
			font-size: 15px;
			background: rgba(255, 255, 255, 0.15);
			color: #fff;
			padding: 8px 16px;
			width: 150px;
			border-radius: 8px;
			font-weight: 500;
			backdrop-filter: blur(10px);
			border: 1px solid rgba(255, 255, 255, 0.2);
			transition: all 0.2s;
		}
		
		#html_page:hover {
			background: rgba(255, 255, 255, 0.2);
			border-color: rgba(255, 255, 255, 0.3);
		}
		
		#html_page::placeholder {
			color: rgba(255, 255, 255, 0.6);
		}
		
		/* 底部固定操作栏 */
		#bottom-actions {
			position: fixed;
			bottom: 0;
			left: 0;
			right: 0;
			height: 64px;
			background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
			display: flex;
			align-items: center;
			justify-content: center;
			gap: 16px;
			box-shadow: 0 -4px 12px rgba(102, 126, 234, 0.25);
			z-index: 1001;
			padding: 0 24px;
		}
		
		#bottom-actions button {
			padding: 12px 32px;
			font-size: 15px;
			font-weight: 600;
			min-width: 140px;
		}
		
		#bottom-actions .btn-save {
			background: linear-gradient(135deg, #10b981 0%, #059669 100%);
			border-color: transparent;
			box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
		}
		
		#bottom-actions .btn-save:hover {
			background: linear-gradient(135deg, #059669 0%, #047857 100%);
			box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
			transform: translateY(-2px);
		}
		
		#bottom-actions .btn-return {
			background: rgba(255, 255, 255, 0.2);
			border-color: rgba(255, 255, 255, 0.3);
		}
		
		#bottom-actions .btn-return:hover {
			background: rgba(255, 255, 255, 0.3);
			border-color: rgba(255, 255, 255, 0.5);
			transform: translateY(-2px);
		}
		
		/* 调整主内容区域，为底部按钮留出空间 */
		#main {
			height: calc(100vh - 56px - 64px);
		}
		
		/* 预览iframe */
		#preview-frame {
			width: 100%;
			height: 100%;
			border: 0;
			background: #fff;
		}
		
		/* 学案面板 */
		#mcontext {
			display: none;
			background: #ffffff;
			overflow-y: auto;
			overflow-x: hidden;
			position: absolute;
			max-height: 500px;
			z-index: 888;
			bottom: 0;
			right: 0;
			border-radius: 16px 16px 0 0;
			box-shadow: 0 -4px 24px rgba(0, 0, 0, 0.15);
			border: 1px solid #e2e8f0;
			border-bottom: none;
		}
		
		#mcontext > div {
			margin: 24px;
			color: #334155;
			line-height: 1.8;
		}
		
		#mcontext::-webkit-scrollbar {
			width: 8px;
		}
		
		#mcontext::-webkit-scrollbar-track {
			background: #f1f5f9;
		}
		
		#mcontext::-webkit-scrollbar-thumb {
			background: #cbd5e1;
			border-radius: 4px;
		}
		
		#mcontext::-webkit-scrollbar-thumb:hover {
			background: #94a3b8;
		}
		
		/* 编辑器美化 */
		.ace_editor {
			font-family: 'Consolas', 'Monaco', 'Courier New', monospace !important;
		}
		
		/* 响应式 */
		@media (max-width: 1200px) {
			#tooltip {
				left: 160px;
				right: 380px;
			}
		}
		
		@media (max-width: 900px) {
			.html_banner {
				padding: 0 16px;
			}
			
			#tooltip {
				display: none;
			}
			
			#sideby {
				right: 16px;
			}
			
			button {
				padding: 8px 14px;
				font-size: 13px;
			}
			
			button i {
				display: none;
			}
		}
	</style>
<link href="../code/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
<script src="../code/jquery.min.js" type="text/javascript"></script>
<script src="../code/build/src/ace.js" type="text/javascript"></script>
<script src="../code/build/src/ext-language_tools.js" type="text/javascript"></script>
<link href="../js/tinybox.css" rel="stylesheet" type="text/css" />
<script src="../js/tinybox.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
</head>
<body>
    <div>
    <div class="html_banner">
	    <span class="icon">网页</span>	 
        <span class="spl"></span>
		<input type="text" id="html_page" name="pagename" readonly title="网页文件名称">
    </div>
<div id="tooltip">
	<span class="keyword" title="样式">style</span>
	<span class="keyword" title="居中">center</span>
	<span class="keyword" title="一级标题">h1</span>
	<span class="keyword" title="超链接">a</span>	
	<span class="keyword" title="段落">p</span>
	<span class="keyword" title="层">div</span>
	<span class="keyword" title="图片">img</span>
	<span class="keyword" title="视频">video</span>
	<span class="keyword" title="音频">audio</span>
	<span class="keyword" title="表单">form</span>
	<span class="keyword" title="换行">br</span>
	<span class="keyword" title="文本框">input</span>
	<span class="keyword" title="用户名 文本框">username</span>
	<span class="keyword" title="内容 文本框">content</span>
	<span class="keyword" title="提交按钮">submit</span>
</div>	
<div id="tool">
	<i class="fa fa-plus" aria-hidden="true" onclick="fontbig()" title="放大代码"></i>
	<br>
	<i class="fa fa-minus" aria-hidden="true" onclick="fontsmall()" title="缩小代码"></i>
	<br><br>
	<i class="fa fa-undo" aria-hidden="true" onclick="backward()" title="撤销"></i>
	<br>
	<i class="fa fa-rotate-right" aria-hidden="true" onclick="forward()" title="重做"></i>
</div>
	
        <div id="main">
        <div id="left"></div>
        <div id="resize" title="左右拖动"></div>
        <div id="right">
			<iframe id="preview-frame" ></iframe>
		</div>
        </div>
<div  id="sidebyleft">
</div>

<div id="sideby">
	<button onclick="example()" class="buttonshow" title="网页模板">
		<i class="fa fa-file-code-o" aria-hidden="true"></i> 模板
	</button>
	<button onclick="showMission()" class="buttonshow" title="查看学案">
		<i class="fa fa-book" aria-hidden="true"></i> 学案
	</button>
	<button onclick="showShare()" class="buttonshow" title="网页空间">
		<i class="fa fa-hdd-o" aria-hidden="true"></i> 空间
	</button>
	<button type="button" onclick="savehtml()" class="buttonsave" title="立即保存到服务器上">
		<i class="fa fa-save" aria-hidden="true"></i> 保存
	</button>
	<button onclick="returnurl()" class="button" title="返回到学案页面">
		<i class="fa fa-reply" aria-hidden="true"></i> 返回
	</button>
</div>

   <div id="mcontext" style="display: none; background: #D1D1D1; overflow-y: auto; overflow-x: hidden;
        position: absolute;   height: 420px; z-index: 888;  bottom: 64px; right:0px;opacity:99%; ">
        <div style="margin:6px; ">
        <%=Mcontents %><br />
        </div>
    </div>
	
	<!-- 底部固定操作栏 -->
	<div id="bottom-actions">
		<button type="button" onclick="savehtml()" class="btn-save" title="保存当前网页代码">
			<i class="fa fa-save" aria-hidden="true"></i> 保存作品
		</button>
		<button type="button" onclick="returnurl()" class="btn-return" title="返回到任务说明页面">
			<i class="fa fa-reply" aria-hidden="true"></i> 返回学案
		</button>
	</div>

	<script type="text/javascript" >
	    var editor = ace.edit("left", {
	        theme: "ace/theme/chrome",
	        mode: "ace/mode/html"
	    });
        var fontsize=15;
		editor.setShowPrintMargin(false);
	    editor.setFontSize(fontsize);
	    editor.focus();
		//editor.setOption("dragEnabled", false);
		editor.getSession().setUseWorker(false);
	    editor.setOptions({
	        wrap: true,
			enableBasicAutocompletion: true,
			enableSnippets: true,
	        enableLiveAutocompletion: true
	    });

		function backward(){
			editor.undo();
		}
		
		function forward(){
			editor.redo();
		}
		
        function fontbig(){
	        fontsize+=1;
	        editor.setFontSize(fontsize);	
        }

        function fontsmall(){
	        fontsize-=1;
	        if (fontsize<16){
		        fontsize=16;
	        }
	        editor.setFontSize(fontsize);	
        }

	    var previewFrame = document.getElementById("preview-frame");
		const frameDoc = previewFrame.contentDocument || previewFrame.contentWindow.document;
		var htmlpage = document.getElementById("html_page");
	    var snum = "<%=Snum %>";
	    var id = "<%=Id %>";
	    var cf = "<%=codefile %>";
	    var fpage = "<%=Fpage %>";
        var mypage= "<%=Mypage %>";
		htmlpage.value = mypage;
        var myweb="../website/"+snum+"/"+mypage;
	    var codefile = decodeURIComponent(window.atob(cf)); //定义字典

	    var sessionkey = "htmlcode" + snum + "-" + id + "-" + mypage;

		// 更新预览函数
		function updatePreview(htmlCode) {
                frameDoc.open();
                htmlCode = updateImgsrc(htmlCode);
                frameDoc.write(htmlCode);//同步预览
				document.title = frameDoc.title;//同步标题
                frameDoc.close();
        }
                
        function updateImgsrc(html){            
            let doc = new DOMParser().parseFromString(html, 'text/html');
            let root = "../website/"+snum+"/";

            // 处理图片
            let imgs = doc.querySelectorAll('img');
            imgs.forEach(img => {
                let src = img.getAttribute('src')?.trim(); // 清除前后空格
                if (!src) return;
                if (!src.startsWith(root)) {
                    let normalizedSrc = src.startsWith('/') ? src.substring(1) : src;
                    img.setAttribute('src', root + normalizedSrc);
                }
            });

            // 处理音频
            let audios = doc.querySelectorAll('audio');
            audios.forEach(audio => {
                let src = audio.getAttribute('src')?.trim(); // 清除前后空格
                if (!src) return;
                if (!src.startsWith(root)) {
                    let normalizedSrc = src.startsWith('/') ? src.substring(1) : src;
                    audio.setAttribute('src', root + normalizedSrc);
                }
            });

            // 处理视频
            let videos = doc.querySelectorAll('video');
            videos.forEach(video => {
                let src = video.getAttribute('src')?.trim(); // 清除前后空格;
                if (!src) return;
                if (!src.startsWith(root)) {
                    let normalizedSrc = src.startsWith('/') ? src.substring(1) : src;
                    video.setAttribute('src', root + normalizedSrc);
                }
            });

            // 处理脚本
            let scripts = doc.querySelectorAll('script[src]');
            scripts.forEach(script => {
                let src = script.getAttribute('src')?.trim(); // 清除前后空格;
                if (!src) return;
                if (!src.startsWith(root)) {
                    let normalizedSrc = src.startsWith('/') ? src.substring(1) : src;
                    script.setAttribute('src', root + normalizedSrc);
                }
            });

            // 处理样式表
            let links = doc.querySelectorAll('link[rel="stylesheet"][href]');
            links.forEach(link => {
                let href = link.getAttribute('href')?.trim(); // 清除前后空格;
                if (!href) return;
                if (!href.startsWith(root)) {
                    let normalizedHref = href.startsWith('/') ? href.substring(1) : href;
                    link.setAttribute('href', root + normalizedHref);
                }
            });

            // 处理链接
            let anchors = doc.querySelectorAll('a[href]');
            anchors.forEach(anchor => {
                let href = anchor.getAttribute('href')?.trim(); // 清除前后空格;
                if (!href) return;
                if (!href.startsWith(root)) {        
                    let normalizedHref = href.startsWith('/') ? href.substring(1) : href;
                    anchor.setAttribute('href', root + normalizedHref);
                }
            });

          // 获取 body 内的所有内容（包括 title 等标签）
          //console.log(doc.documentElement.outerHTML);
          return doc.documentElement.outerHTML;  
          // 或者只获取 body 内容
          // return doc.body.innerHTML;
        }
		
		function autosaving(){
			var codestr = editor.getValue();
	        localStorage .setItem(sessionkey, codestr);//如果行数大于模板数量8行就自动保存
			//console.log("自动保存");	        
		}
		
	    function autopreview() {
	        var codestr = editor.getValue();
	        if (codestr != null && codestr != "") {
				updatePreview(codestr);
	        }
	    }
	    function getsession() {
	        var codestr = localStorage.getItem(sessionkey);
	        if (codestr != null && codestr != "") {
	            editor.setValue(codestr, 1);
	            //localStorage .clear();//读取后清除，防止污染
	            updatePreview(codestr);
				console.log("读取临时缓存");
				console.log(codestr);
	        }
			else{
				console.log("读取临时缓存无");
			}
	    }
		
		editor.getSession().on('change', function() {
			autopreview();
			autosaving();
            $(".buttonsave").css("background-color","#FF8080" );
		  }
		);

	    if (codefile != '' && codefile != null) {
	        setcode(codefile);
	        updatePreview(codefile);       
	        console.log("读取数据库储存程序");
			//console.log(codefile);			
			$(".buttonsave").css("background-color","" );
	    }
		else{
			getsession();	       
		}
		
	    function setcode() {
	        editor.setValue(codefile, 1);
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

	    function savehtml() { 
        	var htmlcode = editor.getValue();
        	if (htmlcode != null && htmlcode != "") {
                html2canvas(frameDoc.body, {
                    useCORS: true
                }).then(pic => {
                    var dataURL=pic.toDataURL("image/jpg",0.5);
                    var cover=blob(dataURL);
					
        	        localStorage .setItem(sessionkey, htmlcode); //保存时更新临时数据
        	        var urls = 'uploadhtml.ashx?id=' + id;
        	        var formData = new FormData();
        	        var encodehtml = window.btoa(encodeURIComponent(htmlcode));
        	        formData.append('codefile', encodehtml);
        	        formData.append('mypage', mypage);
                    formData.append('cover', cover);

        	        $.ajax({
        	            url: urls,
        	            type: 'POST',
        	            cache: false,
        	            data: formData,
        	            processData: false,
        	            contentType: false
        	        }).done(function (res) {
        	            alert("保存成功！");
						$(".buttonsave").css("background-color","" );
        	            //console.log(res);
        	        }).fail(function (res) {
        	            console.log(res)
        	        }); 	
            
                });		
        	}
        }

        function showhtml(){
            window.open(myweb,"blank");  
           // window.location.href=mypage;
        }

		function downhtml(){
			var filename="mypage";
			var type="text/html";
			var content= editor.getValue();
			var ele = document.createElement('a');// 创建下载链接
			ele.download = filename;//设置下载的名称
			ele.style.display = 'none';// 隐藏的可下载链接
			// 字符内容转变成blob地址
			var blober = new Blob([content],{type});
			ele.href = URL.createObjectURL(blober);
			// 绑定点击时间
			document.body.appendChild(ele);
			ele.click();
			// 然后移除
			document.body.removeChild(ele);
		}

        function returnurl() {
			localStorage .clear(); //返回后清除，防止污染
            if (confirm('是否要离开此页面？') == true) {
                window.location.href = fpage;
            }
        }
        
        function example() {
			if( editor.session.getLength()<8)
			{
				var examplecode = "JTNDaHRtbCUzRSUwRCUwQSUyMCUyMCUyMCUyMCUzQ2hlYWQlM0UlMEQlMEElMjAlMjAlMjAlMjAlMjAlMjAlMjAlMjAlM0N0aXRsZSUzRSVFNyVCRCU5MSVFOSVBMSVCNSVFNiVBMCU4NyVFOSVBMiU5OCUzQyUyRnRpdGxlJTNFJTBEJTBBJTIwJTIwJTIwJTIwJTNDJTJGaGVhZCUzRSUwRCUwQSUyMCUyMCUyMCUyMCUzQ2JvZHklM0UlMEQlMEElMjAlMjAlMjAlMjAlMjAlMjAlMjAlMjAlM0NoMSUzRSVFNSU4NiU4NSVFNSVBRSVCOSVFNiVBMCU4NyVFOSVBMiU5OCUzQyUyRmgxJTNFJTBEJTBBJTIwJTIwJTIwJTIwJTIwJTIwJTIwJTIwJTNDcCUzRSUwRCUwQSUyMCUyMCUyMCUyMCUyMCUyMCUyMCUyMCUyMCUyMCUyMCUyMCVFOCVCRiU5OSVFNiU5OCVBRiVFNiVBRSVCNSVFOCU5MCVCRCUwRCUwQSUyMCUyMCUyMCUyMCUyMCUyMCUyMCUyMCUzQyUyRnAlM0UlMEQlMEElMjAlMjAlMjAlMjAlM0MlMkZib2R5JTNFJTBEJTBBJTNDJTJGaHRtbCUzRQ";
				var exampledecode = decodeURIComponent(window.atob(examplecode)); //网页模板
				updatePreview(exampledecode);
				editor.setValue(exampledecode, 1);
			}
        }

	</script>

    <script type="text/javascript" >
        window.onload = function () {
            var main = document.getElementById('main');
            var resize = document.getElementById('resize');
            var left = document.getElementById('left');
            var right = document.getElementById('right');
            var minwidth = 400;
            // 初始化布局
            resize.style.left = (main.clientWidth / 2) + 'px';

            resize.onmousedown = function (e) {
                e.preventDefault();
                // 添加拖动样式
                resize.classList.add('dragging');
                // 临时禁用iframe的指针事件
                previewFrame.style.pointerEvents = 'none';
                // 记录初始位置
                var startX = e.clientX;
                var startLeftWidth = left.offsetWidth;
                document.onmousemove = function (e) {
                    // 计算宽度变化
                    var deltaX = e.clientX - startX;
                    var newLeftWidth = startLeftWidth + deltaX;
                    // 应用最小宽度限制
                    if (newLeftWidth < minwidth) newLeftWidth = minwidth;
                    if (newLeftWidth > main.clientWidth - minwidth) newLeftWidth = main.clientWidth - minwidth;

                    // 设置左侧宽度
                    left.style.width = newLeftWidth + 'px';
                    // 设置右侧宽度
                    right.style.width = (main.clientWidth - newLeftWidth - resize.offsetWidth) + 'px';
                    editor.resize(); // 重新调整编辑器大小
                };
                document.onmouseup = function () {
                    // 移除拖动样式
                    resize.classList.remove('dragging');
                    // 恢复iframe的指针事件
                    previewFrame.style.pointerEvents = 'auto';
                    // 清除事件监听
                    document.onmousemove = null;
                    document.onmouseup = null;
                };
            };
        };


        $(".keyword").click(function () {
            var keytxts = $(this).html();
            var keystr = keytxts.split('<br>');
            var keytxt = keystr[0];
            console.log(keytxt);
            var cmdstr = "";
            switch (keytxt) {
                case "html":
                    cmdstr = "<html>\r\n\n\n</html>";
                    break;
                case "head":
                    cmdstr = "<head>\r\n\t</head>";
                    break;
                case "title":
                    cmdstr = "<title></title>";
                    break;
                case "style":
                    cmdstr = "\r\n\t<style>\r\n\n\t</style>";
                    break;
                case "body":
                    cmdstr = '<body bgcolor=" " background=" ">\r\n\t</body>';
                    break;
                case "center":
                    cmdstr = "\r\n\t<center>\r\n\n\t</center>";
                    break;
                case "h1":
                    cmdstr = "\r\n\t\t<h1> </h1>";
                    break;
                case "a":
                    cmdstr = '\r\n\t\t\t<a href=" #链接网址 ">链接文字</a>';
                    break;
                case "font":
                    cmdstr = '<font face="宋体" size=16  color="red">文字</font>';
                    break;
                case "p":
                    cmdstr = "\r\n\t\t<p>\r\n\n\t\t</p>";
                    break;
                case "div":
                    cmdstr = "\r\n\t<div>\r\n\n\t</div>";
                    break;
                case "img":
                    cmdstr = '\r\n\t\t<img src=" " width="300" ></img>';
                    break;
                case "video":
                    cmdstr = '\r\n\t\t<video src=" " width="500"  controls></video>';
                    break;
                case "audio":
                    cmdstr = '\r\n\t\t<audio src=" " controls></audio>';
                    break;
                case "form":
                    cmdstr = '\r\n\t<form action="../../website/post.html" target="_blank">\r\n\n\t</form>';
                    break;
                case "br":
                    cmdstr = '\r\n\t<br>';
                    break;
                case "input":
                    cmdstr = '\r\n\t\t<input type="text" name="userinput" >';
                    break;
                case "username":
                    cmdstr = '\r\n\t\t<input type="text" name="username" >';
                    break;
                case "content":
                    cmdstr = '\r\n\t\t<input type="text" name="content" >';
                    break;
                case "submit":
                    cmdstr = '\r\n\t\t<input type="submit" value="提交" >';
                    break;
                default:
                    break;
            }

            var cursorPosition = editor.getCursorPosition();
            editor.session.insert(cursorPosition, cmdstr);
            editor.focus();

        });
		
	</script>
    <script type="text/javascript">
        // 页面加载时检查网盘状态并更新按钮
        (function() {
            fetch('CheckNetdiskStatus.ashx')
                .then(response => response.json())
                .then(data => {
                    if (!data.enabled) {
                        var shareButtons = document.querySelectorAll('#share, .sharedisk');
                        shareButtons.forEach(function(btn) {
                            btn.disabled = true;
                            btn.value = '网盘未开启';
                            btn.style.background = '#e5e7eb';
                            btn.style.color = '#9ca3af';
                            btn.style.cursor = 'not-allowed';
                            btn.style.opacity = '0.6';
                            btn.style.borderColor = '#d1d5db';
                        });
                    }
                })
                .catch(err => {
                    console.error('检查网盘状态失败:', err);
                });
        })();
        
        function showShare() {
            // 检查网盘开关状态
            fetch('CheckNetdiskStatus.ashx')
                .then(response => response.json())
                .then(data => {
                    if (data.enabled) {
                        var urlat = "webspace.aspx";
                        TINY.box.show({ iframe: urlat, boxid: 'frameless', width: 550, height: 400, fixed: false, maskopacity: 100, close: true })
                    } else {
                        // 禁用状态下不执行任何操作
                        return;
                    }
                })
                .catch(err => {
                    console.error('检查网盘状态失败:', err);
                    // 出错时默认允许访问
                    var urlat = "webspace.aspx";
                    TINY.box.show({ iframe: urlat, boxid: 'frameless', width: 550, height: 400, fixed: false, maskopacity: 100, close: true })
                });
        }
        function showMission() {
            $("#mcontext").slideToggle();
        }
    </script>
	
    </div>
</body>
</html>