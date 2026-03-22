<%@ page language="C#" autoeventwireup="true" inherits="deepseek_ocr, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html runat="server" lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>人工智能 - 文字识别技术 OCR</title>
    <link rel="stylesheet" href="deepseek.css">
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
	
</head>
<body>
    <div class="container">		
        <div class="left-column">		
			<!-- 聊天区域 -->
			<div class="chat-container" id="chatHistory">
				<!-- 聊天记录将动态加载到这里🐳  -->
				<div class="wall">
				<h2><img  src="ocr.png" /> 人工智能 - 文字识别 OCR，很高兴见到你！
				</h2>
				</div>
			</div>
			
			<!-- 输入框区域 -->
			<div class="loading-container">
			<!-- 加载状态 -->
			<div id="loading" style="display: none;"><img src="loading.gif" />文字识别中...</div>
			
			</div>

			<!-- 输入框区域 -->
			<div class="input-container">
				<div class="other">
					<input type="file" name="file" id="userfile" accept="image/*" hidden>
					<button id="uploadbtn" >上传图片</button>
					<button id="btnmsg" onclick="sendText()" title="文字识别">文字识别</button>
				</div>
				
			</div>
        </div>	
		
        <div class="right-column">
			<!-- 导航栏 -->
			<div class="navbar">
			<img src="ocr.png" /> 历史对话记录
			</div>
			<!-- 聊天记录栏 -->
			<div id ="chatbar">			
			</div>			
            <div id="footbar">
				<button  type = "button" onclick="savechat()" class="buttonsave"  title="保存到服务器上" >
				<i class="fa fa-save" aria-hidden="true"></i> 保存</button>
				<span class="sp"></span>
				<button  onclick="returnurl()" class="button" title="返回到学案页面">
				<i class="fa fa-reply" aria-hidden="true"></i> 返回</button>            
            </div>
        </div>

 </div>
    <script>
        let messageHistory = []; // 新增：存储对话历史的数组
		
		var port=":2000";//端口
		var lor =location.origin + port;// http://192.168.1.3
		console.log(lor);
		
        const apiUploadUrl = lor+"/upload";
        const apiChatUrl = lor+"/ocr";
			
		const userfile = document.getElementById("userfile");
		const uploadbtn = document.getElementById("uploadbtn");
		const userchatbar = document.getElementById("chatbar");
        const sendButtonmsg = document.getElementById("btnmsg");
		let imgfilename ;
        sendButtonmsg.disabled = true;
		
		//console.log(userform.action);
		// 为表单添加提交事件监听器
        userfile.addEventListener('change', async (event) => {
			  const files = event.target.files;
			  if (!files) return;

			  // 创建图片对象					
				//console.log("上传文件是",files[0]);
				var formData = new FormData(); // 创建FormData对象
				formData.append("file",files[0]);
				// 使用Fetch API发送POST请求
				fetch(apiUploadUrl, {
					method: 'POST',
					body: formData
				})
				.then(response => response.json()) // 将响应解析为JSON
				.then(data => {
					// 在页面上显示服务器响应
					var result =  JSON.parse(JSON.stringify(data));
					imgfilename = result["response"];
					console.log(imgfilename);
					addMessage("upload", imgfilename);				
					sendButtonmsg.disabled = false;
				})
				.catch(error => {
					console.error('Error:', error); // 在控制台显示错误信息
				});
        });
		
		uploadbtn.addEventListener('click', function() {
			userfile.click();
		});

        async function sendText() {
            const userInput = imgfilename;
            if (!userInput) return;
			
            sendButtonmsg.disabled = true;
			uploadbtn.disabled = true;

            // 新增：将用户消息添加到历史记录
			const userMessage = { role: "upload", content: userInput };
            messageHistory.push(userMessage);

            try {
                document.getElementById("loading").style.display = "block";
                const response = await fetch(apiChatUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ messages: userMessage }) 
                });
                
                const data = await response.json();
                
                // 新增：将AI回复添加到历史记录
                const botMessage = { role: "assistant", content: data.response };
                addMessage("bot", data.response);
			
				const chatTitle = document.createElement("div");
				chatTitle.className="chattitle";
				chatTitle.innerHTML=data.response;
				userchatbar.appendChild(chatTitle);
			
            } catch (error) {
                console.error("Error:", error);
                const errorMessage = { role: "assistant", content: `Error: ${error.message}` };
                addMessage("sys", `Error: ${error.message}`);
            } finally {
                document.getElementById("loading").style.display = "none";				
				uploadbtn.disabled  = false;
				imgfilename ="";
            }
        }
		
		
		function addMessage(role, content) {
			const chatHistory = document.getElementById("chatHistory");
			const messageDiv = document.createElement("div");
			messageDiv.className = `message ${role}`;
			if (role === "upload") {				
				messageDiv.innerHTML = `<img class="upimg" src="../deepseek/uploads/${content}" />`;
			}else {
				messageDiv.innerHTML = `<div class="user">${content}</div>`;
			}
			chatHistory.appendChild(messageDiv);

			// 滚动到底部
			chatHistory.scrollTop = chatHistory.scrollHeight;
		}


        var docurl = document.URL;
		var ipurl = docurl.substring(0, docurl.lastIndexOf("/"));
		var id = "<%=Id %>";
        function returnurl() {
            if (confirm('是否要离开此页面？') == true) {
                window.location.href = "<%=Fpage %>"
            }
        }

        function savechat() { 
	        var preview = document.getElementById("chatHistory");
            var htmlcode ="";// preview.innerHTML;使用缩略图预览
        	if (messageHistory.length>0) {
                html2canvas(preview).then(pic => {					
        	        var urls = '../student/uploadtopic.ashx?id=' + id;
			        var title = "";
			        var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			        var Content = htmlcode;
			        var Extension = "ocr";
			        var formData = new FormData();
			        formData.append('title', title);
			        formData.append('cover', Cover);
			        formData.append('content', Content);
			        formData.append('ext', Extension);

        	        $.ajax({
        	            url: urls,
        	            type: 'POST',
        	            cache: false,
        	            data: formData,
        	            processData: false,
        	            contentType: false
        	        }).done(function (res) {
        	            alert("保存成功！");
        	        }).fail(function (res) {
        	            console.log(res)
        	        }); 	
            
                });		
        	}
        }

		function blob(dataURI) {
            var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
            var byteString = atob(dataURI.split(',')[1]);
            var arrayBuffer = new ArrayBuffer(byteString.length);
            var intArray = new Uint8Array(arrayBuffer);

            for (var i = 0; i < byteString.length; i++) {
                intArray[i] = byteString.charCodeAt(i);
            }
            return new Blob([intArray], { type: mimeString });
        }
			

    </script>
</body>
</html>
