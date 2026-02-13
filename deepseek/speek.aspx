<%@ page language="C#" autoeventwireup="true" inherits="deepseek_speek, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="zh-CN">
<head  runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>人工智能 - 语音合成技术</title>
    <link rel="stylesheet" href="deepseek.css">
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
	
</head>
<body>
    <div class="container">		
        <div class="left-column">		
			<!-- 聊天区域 -->
			<div class="chat-container" >
				<!-- 聊天记录将动态加载到这里🐳  -->
				<div class="wall">
				<h2><img  src="../deepseek/speek.png" onclick="example()" /> 人工智能 - 语音合成，很高兴遇见你！
				</h2>
				</div>
				<div id="chatHistory">
				
				</div>
			</div>
			
			<!-- 输入框区域 -->
			<div class="loading-container">
			<!-- 加载状态 -->
			<div id="loading" style="display: none;"><img src="../deepseek/loading.gif" />语音合成中...</div>
			
			</div>

			<!-- 输入框区域 -->
			<div class="input-container">
				<textarea id="userInput" placeholder="输入你的问题..." rows="3"  maxlength="1000" ></textarea>
				<div>
				<button id="btnmsg" onclick="sendText()" title="合成语音">合成语音</button>
				<div style="margin-top:10px;">
				<select id="voiceSelect" title="选择发音人">
					<option value="zh-CN-XiaoxiaoNeural">晓晓 温暖 女</option>
					<option value="zh-CN-XiaoyiNeural">小艺 活泼 女</option>
					<option value="zh-CN-YunjianNeural">云健 稳重 男</option>
					<option value="zh-CN-YunxiNeural">云溪 阳光 男</option>
					<option value="zh-CN-YunxiaNeural">云夏 可爱 男</option>
					<option value="zh-CN-YunyangNeural">云阳 专业 男</option>
					<option value="zh-CN-liaoning-XiaobeiNeural">辽宁 小北 女</option>
					<option value="zh-CN-shaanxi-XiaoniNeural">陕西 小妮 女</option>
					<option value="zh-HK-HiuGaaiNeural">香港 晓佳 女</option>
					<option value="zh-HK-HiuMaanNeural">香港 晓文 女</option>
					<option value="zh-HK-WanLungNeural">香港 万龙 男</option>
					<option value="zh-TW-HsiaoChenNeural">台湾 晓晨 女</option>
					<option value="zh-TW-HsiaoYuNeural">台湾 晓雨 女</option>
					<option value="zh-TW-YunJheNeural">台湾 云哲 男</option>
				</select>
				</div>
				</div>
				
			</div>
        </div>	
		
        <div class="right-column">
			<!-- 导航栏 -->
			<div class="navbar">
			<img src="speek.png" /> 历史对话记录
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
		var lor=location.origin+port;// http://192.168.1.3
		console.log(location.origin);
		
        const apiChatUrl = lor+"/voice";
			
		const userTextarea = document.getElementById("userInput");
		const userchatbar = document.getElementById("chatbar");
        const sendButtonmsg = document.getElementById("btnmsg");
		const selectElement = document.getElementById("voiceSelect");

        async function sendText() {
            const userInput = userTextarea.value;
            const selectedValue = selectElement.value;
            if (!userInput) return;
			
            sendButtonmsg.disabled = true;
			userTextarea.disabled = true;

            // 新增：将用户消息添加到历史记录
			const userMessage = { role: selectedValue, content: userInput };
            messageHistory.push(userMessage);
            addMessage("user", userInput);

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
				chatTitle.innerHTML=userInput;
				userchatbar.appendChild(chatTitle);
			
            } catch (error) {
                console.error("Error:", error);
                const errorMessage = { role: "assistant", content: `Error: ${error.message}` };
                addMessage("sys", `Error: ${error.message}`);
            } finally {
                document.getElementById("loading").style.display = "none";
                sendButtonmsg.disabled = false;
				userTextarea.disabled = false;
                document.getElementById("userInput").value = "";
            }
        }
		
		
		function addMessage(role, content) {
			const chatHistory = document.getElementById("chatHistory");
			const messageDiv = document.createElement("div");
			messageDiv.className = `message ${role}`;
			if (role === "bot") {
				pauseAllAudio();//暂停所有
				content = "../deepseek/"+ content;
				messageDiv.innerHTML = ` <audio src="${content}" autoplay controls ></audio> <img class="download" src="../deepseek/down.gif" onclick="download('${content}')" title="点击下载语音" />`;
			}else {
				messageDiv.innerHTML = `<div class="user">📝 ${content}</div>`;
			}
			chatHistory.appendChild(messageDiv);

			// 滚动到底部
			chatHistory.scrollTop = chatHistory.scrollHeight;
			userTextarea.style.height = "auto";
		}

        // 自动调整输入框高度
        document.getElementById("userInput").addEventListener("input", (event) => {
            event.target.style.height = "auto";
            event.target.style.height = event.target.scrollHeight + "px";
        });
		
		function pauseAllAudio() {
			// 获取页面中的所有音频元素
			const audioElements = document.getElementsByTagName('audio');
			
			// 遍历每个音频元素，调用 pause 方法
			for (let audio of audioElements) {
				audio.pause(); // 暂停当前音频
			}
		}
		
		function download(url) {
			fetch(url)
				.then(response => response.blob())
				.then(blob => {
					const link = document.createElement('a');
					link.href = URL.createObjectURL(blob);
					var lastOf = url.lastIndexOf('/');
					var filename = url.substr(lastOf + 1); 
					link.download = filename;
					link.click();
				});
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
            var htmlcode = preview.innerHTML; //使用缩略图预览
        	if (messageHistory.length>0) {
                html2canvas(preview).then(pic => {					
        	        var urls = '../student/uploadtopic.ashx?id=' + id;
			        var title = "";
			        var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
                    //var encodehtml = window.btoa(encodeURIComponent(htmlcode));
			        var Content = htmlcode;
			        var Extension = "speek";
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
        
		function example(){
			fetch("example.txt")
			　　.then((res) => res.text())
			　　.then(data => {
			　　	userTextarea.value = data;//文章样本
				})
		}

    </script>
</body>
</html>
