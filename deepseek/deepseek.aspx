<%@ page language="C#" autoeventwireup="true" inherits="deepseek_deepseek, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="zh-CN">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>人工智能 - 探索未知之境</title>
    <link rel="stylesheet" href="deepseek.css">
    <!-- Markdown 渲染库 -->
    <script src="marked.min.js"></script>
    <!-- 代码高亮库 -->
    <link rel="stylesheet" href="github-dark.min.css">
    <script src="highlight.min.js"></script>
    <!-- Font Awesome 图标库 -->
    <link rel="stylesheet" href="all.min.css">
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
	
</head>
<body>
    <div class="container" id="maincontainer">		
        <div class="left-column">		
			<!-- 聊天区域 -->
			<div class="chat-container" id="chatHistory">
				<!-- 聊天记录将动态加载到这里🐳  -->
				<div class="wall">
				<h2><img class ="logo" src="deepseek.svg" /> 我是 人工智能 DeepSeek，很高兴见到你！</h2>
				<div>我可以帮你写作、编程、绘画等各种创意内容，请把你的任务交给我吧~</div>
				</div>
			</div>
			
			<!-- 输入框区域 -->
			<div class="loading-container">
			<!-- 加载状态 -->
			<div id="loading" style="display: none;"><img src="loading.gif" />思考中...</div>
			
			</div>

			<!-- 输入框区域 -->
			<div class="input-container">
				<textarea id="userInput" placeholder="输入你的问题..." rows="2" maxlength="500"></textarea>
				<button id="btnmsg" onclick="sendMessage()" title="人工智能聊天">对话</button>
				<button id="btntran" onclick="sendChinese()" title="中文翻译为英文">翻译</button>
				<button id="btnphoto"  style="display: none;" onclick="sendPhoto()" title="文本生成图片">图片</button>
			</div>
        </div>	
		
        <div class="right-column">
			<!-- 导航栏 -->
			<div class="navbar">
			<img class ="logo" src="deepseek.svg" /> 人工智能 DeepSeek
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
		
        const apiChatUrl = lor+"/chat";
        const apiPhotoUrl = lor+"/photo";
        const apiTranUrl = lor+"/translator";
			
		const userTextarea = document.getElementById("userInput");
        const sendButtonmsg = document.getElementById("btnmsg");
        const sendButtonphoto = document.getElementById("btnphoto");
        const sendButtontran = document.getElementById("btntran");
		const chatHistory = document.getElementById("chatHistory");
		const userchatbar = document.getElementById("chatbar");
		
		function restoreHistory(){
			var mychatHistory = localStorage.getItem("chatHistory");
			var mychatbar = localStorage.getItem("chatbar");
			if(mychatbar){
				userchatbar.innerHTML=mychatbar;
				chatHistory.innerHTML =mychatHistory;
			}		
		}
		//restoreHistory();//恢复聊天记录

        async function sendChinese() {
            const userInput = document.getElementById("userInput").value.trim();
            if (!userInput) return;
			
			userTextarea.disabled = true;
			sendButtontran.disabled = true;
            // 新增：将用户消息添加到历史记录
            const userMessage = { role: "user", content: userInput };
            messageHistory.push(userMessage);
            addMessage("user", userInput);

            try {
                document.getElementById("loading").style.display = "block";
                const response = await fetch(apiTranUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ messages: userMessage }) // 改为发送完整对话历史
                });
                
                const data = await response.json();
                
                // 新增：将AI回复添加到历史记录
                const botMessage = { role: "assistant", content: data.response };
                messageHistory.push(botMessage);
                addMessage("tran", data.response);
			
				const chatTitle = document.createElement("div");
				chatTitle.className="chattitle";
				chatTitle.innerHTML=userInput;
				userchatbar.appendChild(chatTitle);
			
            } catch (error) {
                console.error("Error:", error);
                const errorMessage = { role: "assistant", content: `Error: ${error.message}` };
                messageHistory.push(errorMessage);
                addMessage("tran", `Error: ${error.message}`);
            } finally {
                document.getElementById("loading").style.display = "none";
				userTextarea.disabled = false;
				sendButtontran.disabled = false;
                document.getElementById("userInput").value = "";
            }
        }

async function sendMessage() {
    const userInput = document.getElementById("userInput").value.trim();
    if (!userInput) return;
    
    sendButtonmsg.disabled = true;
    sendButtonphoto.disabled = true;
    userTextarea.disabled = true;

    // 将用户消息添加到历史记录
    const userMessage = { role: "user", content: userInput };
    messageHistory.push(userMessage);
    addMessage("user", userInput);

    // 创建聊天标题
    const chatTitle = document.createElement("div");
    chatTitle.className = "chattitle";
    chatTitle.innerHTML = userInput;
    userchatbar.appendChild(chatTitle);

    try {
        document.getElementById("loading").style.display = "block";
        
        // 为AI回复创建占位消息
        const messageId = Date.now();
        const botMessage = { role: "assistant", content: "" };
        messageHistory.push(botMessage);
        addPosMessage("bot", "", messageId); // 空内容，等待流式填充

        const response = await fetch(apiChatUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ messages: messageHistory })
        });

        if (!response.ok) {
            throw new Error(`请求失败: ${response.status}`);
        }

        // 流式处理响应
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let buffer = '';
        let fullResponse = '';

        while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            
            buffer += decoder.decode(value, { stream: true });
            
            // 处理SSE格式或JSON流格式
            const lines = buffer.split('\n');
            for (let i = 0; i < lines.length - 1; i++) {
                const line = lines[i].trim();
                if (!line) continue;
                
                try {
                    // 处理可能的SSE格式 (data: {...})
                    const jsonStr = line.startsWith('data: ') ? line.substring(6) : line;
                    if (jsonStr === '[DONE]') continue;
                    
                    const data = JSON.parse(jsonStr);
                    if (data.content || data.response) {
                        const content = data.content || data.response || '';
                        fullResponse += content;
                        
                        // 更新UI中的消息内容
						//console.log("返回结果：",fullResponse);
                        updateMessage(messageId, "bot", fullResponse);
                        
                        // 实时更新历史记录中的最后一条消息
                        if (messageHistory.length > 0) {
                            messageHistory[messageHistory.length - 1].content = fullResponse;
                        }
                    }
                } catch (e) {
                    console.error('解析消息失败:', e);
                }
            }
            
            buffer = lines[lines.length - 1]; // 保留未处理完的部分
        }

    } catch (error) {
        console.error("Error:", error);
        const errorMessage = { role: "assistant", content: `Error: ${error.message}` };
        // 如果之前已经添加了空消息，则更新它
        if (messageHistory.length > 0 && messageHistory[messageHistory.length - 1].content === "") {
            messageHistory[messageHistory.length - 1] = errorMessage;
            updateMessage(messageId, "bot", errorMessage.content);
        } else {
            messageHistory.push(errorMessage);
            addMessage("bot", errorMessage.content);
        }
    } finally {
        document.getElementById("loading").style.display = "none";
        sendButtonmsg.disabled = false;
        sendButtonphoto.disabled = false;
        userTextarea.disabled = false;
        document.getElementById("userInput").value = "";
		localStorage.setItem("chatbar",userchatbar.innerHTML);		
		localStorage.setItem("chatHistory",chatHistory.innerHTML);
    }
}

// 使用 marked.js 改进的 Markdown 解析器
function parseMarkdown(text) {
    // 配置 marked.js
    marked.setOptions({
        breaks: true,       // 转换 \n 为 <br>
        gfm: true,          // 支持 GitHub Flavored Markdown
        highlight: function(code, lang) {
            if (window.hljs) {
                const language = hljs.getLanguage(lang) ? lang : 'plaintext';
                return hljs.highlight(code, { language }).value;
            }
            return code;
        },
        sanitize: false,    // 不进行 HTML 转义（因为我们会在后面处理）
        // 其他配置...
    });

    try {
        // 先转义 HTML 特殊字符（防止 XSS）
        const escaped = escapeHtml(text);
        // 然后解析 Markdown
        return marked.parse(escaped);
    } catch (e) {
        console.error('Markdown 解析错误:', e);
        return text; // 解析失败时返回原始文本
    }
}

// HTML 转义函数（防止 XSS）
function escapeHtml(unsafe) {
    return unsafe
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function addPosMessage(role, content, id) {
    const messageDiv = document.createElement("div");
    messageDiv.id = `msg-${id || Date.now()}`;
    messageDiv.className = `message ${role}`;
    
    // 使用单独的markdown-content容器
    messageDiv.innerHTML = `<div><img class ='avatar' src='deepseek.svg' /></div>
	<div class="markdown-content">${parseMarkdown(content)}</div>`;
    
    chatHistory.appendChild(messageDiv);
    chatHistory.scrollTop = chatHistory.scrollHeight;
    
    // 高亮代码块
    if (role === 'bot') {
        setTimeout(() => {
            const blocks = messageDiv.querySelectorAll('pre code');
            blocks.forEach(block => {
                if (window.hljs) {
                    hljs.highlightElement(block);
                }
            });
        }, 100);
    }
    return messageDiv.id;
}

// 修改后的updateMessage函数（支持Markdown）maincontainer
const maincontainer = document.getElementById("maincontainer");
let updateTimer;
function updateMessage(id, role, content) {
    const messageElement = document.getElementById(`msg-${id}`);
    if (!messageElement) return;
    
    // 防抖处理（避免频繁重绘）
    clearTimeout(updateTimer);
    updateTimer = setTimeout(() => {
        const contentDiv = messageElement.querySelector('.markdown-content');
        if (contentDiv) {
            // 保存当前滚动位置
            const wasScrolledToBottom = 
                chatHistory.scrollTop + chatHistory.clientHeight >= 
                chatHistory.scrollHeight;
            
            contentDiv.innerHTML = parseMarkdown(content);
            
            // 高亮代码块
            if (window.hljs) {
                document.querySelectorAll(`#msg-${id} pre code`).forEach(block => {
                    hljs.highlightElement(block);
                });
            }
            
            // 恢复滚动位置
            if (wasScrolledToBottom) {
                chatHistory.scrollIntoView({ behavior: 'smooth', block: 'end' });
            }
        }
    }, 60); // 50ms防抖阈值
	
}
		
		
        async function sendPhoto() {
			let photoHistory = []; // 新增：存储对话历史的数组
            const userInput = document.getElementById("userInput").value.trim();
            if (!userInput) return;
			
            sendButtonmsg.disabled = true;
            sendButtonphoto.disabled = true;
			userTextarea.disabled = true;

            // 新增：将用户消息添加到历史记录
            const userMessage = { role: "user", content: userInput };
            photoHistory.push(userMessage);
            addMessage("user", userInput);
			
			const chatTitle = document.createElement("div");
			chatTitle.className="chattitle";
			chatTitle.innerHTML=userInput;
			userchatbar.appendChild(chatTitle);

            try {
                document.getElementById("loading").style.display = "block";
                const response = await fetch(apiPhotoUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ messages: photoHistory }) // 改为发送完整对话历史
                });
                
                const data = await response.json();
                
                // 新增：将AI回复添加到历史记录
                addMessage("bot", data.response);
            } catch (error) {
                console.error("Error:", error);
                const errorMessage = { role: "assistant", content: `Error: ${error.message}` };
                addMessage("bot", `Error: ${error.message}`);
            } finally {
                document.getElementById("loading").style.display = "none";
                sendButtonmsg.disabled = false;
                sendButtonphoto.disabled = false;
				userTextarea.disabled = false;
                document.getElementById("userInput").value = "";
            }
        }

		function addMessage(role, content,id) {
			const messageDiv = document.createElement("div");
			messageDiv.id = `msg-${id || Date.now()}`;
			messageDiv.className = `message ${role}`;

			// 如果是机器人消息，则渲染 Markdown
			if (role === "bot") {
				// 使用 marked.parse 渲染 Markdown
				const renderedContent = marked.parse(content);
				messageDiv.innerHTML = `<span class="content">${renderedContent}</span>`;

				// 高亮代码块
				setTimeout(() => {
					document.querySelectorAll('pre code').forEach((block) => {
						hljs.highlightBlock(block);
					});

					// 为每个代码块添加复制图标
					document.querySelectorAll('pre').forEach((pre) => {
						const copyIcon = document.createElement('i');
						copyIcon.className = 'fas fa-copy copy-icon';
						copyIcon.title = '复制代码';
						copyIcon.onclick = () => {
							const code = pre.querySelector('code').innerText;
							if (navigator.clipboard) {
								navigator.clipboard.writeText(code).then(() => {
									copyIcon.style.color = '#4CAF50'; // 复制成功后改变颜色
									setTimeout(() => {
										copyIcon.style.color = '#fff'; // 恢复颜色
									}, 1000);
								}).catch((err) => {
									console.error('复制失败:', err);
								});
							} else {
								// 如果不支持 clipboard API，使用备用方法
								const textarea = document.createElement('textarea');
								textarea.value = code;
								document.body.appendChild(textarea);
								textarea.select();
								document.execCommand('copy');
								document.body.removeChild(textarea);
								copyIcon.style.color = '#4CAF50'; // 复制成功后改变颜色
								setTimeout(() => {
									copyIcon.style.color = '#fff'; // 恢复颜色
								}, 1000);
							}
						};
						pre.appendChild(copyIcon);
					});
				}, 30);
			} else {
				messageDiv.innerHTML = `<span class="content">${content}</span>`;
			}

			chatHistory.appendChild(messageDiv);

			// 滚动到底部
			chatHistory.scrollTop = chatHistory.scrollHeight;
			
		}

        // 监听输入框的 Enter 键
        document.getElementById("userInput").addEventListener("keydown", (event) => {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault(); // 阻止默认换行行为
                sendMessage();
            }
        });

        // 自动调整输入框高度
        document.getElementById("userInput").addEventListener("input", (event) => {
            event.target.style.height = "auto";
            event.target.style.height = event.target.scrollHeight + "px";
        });
		

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
			        var Extension = "ai";
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
