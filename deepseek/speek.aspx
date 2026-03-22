<%@ page language="C#" autoeventwireup="true" inherits="deepseek_speek, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="zh-CN">
<head  runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>人工智能 - 语音合成技术</title>
    <link rel="stylesheet" href="deepseek.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" />
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
			<div class="input-container sp-input">
				<textarea id="userInput" placeholder="输入要合成的文本..." rows="3" maxlength="1000"></textarea>
				<div class="sp-controls">
					<div class="sp-control-row">
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
						<button id="btnmsg" onclick="sendText()" title="合成语音">
							<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;flex-shrink:0"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>
							合成语音
						</button>
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
				<button type="button" onclick="savechat()" class="buttonsave" title="保存">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>保存</button>
				<button onclick="returnurl()" class="button" title="返回">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px"><polyline points="15 18 9 12 15 6"/></svg>返回</button>
            </div>
        </div>

 </div>
    <div class="ds-toast" id="dsToast"></div>
    <script>
        function showToast(msg, type) {
            var t = document.getElementById('dsToast');
            t.textContent = msg;
            t.className = 'ds-toast ' + (type||'success') + ' show';
            clearTimeout(t._t);
            t._t = setTimeout(function(){ t.className = 'ds-toast ' + (type||'success'); }, 2400);
        }

		// 音频重播按钮
		function replayAudio(btn) {
			var url = btn.getAttribute('data-audio');
			if (!url) return;
			stopSpeech();
			pauseAllAudio();
			var wrap = btn.parentNode && btn.parentNode.parentNode;
			var audio = wrap ? wrap.querySelector('audio') : null;
			if (audio) {
				audio.currentTime = 0;
				audio.play().catch(function(){});
			} else {
				playAudioUrl(url);
			}
		}

		function downloadAudio(btn) {
			var url = btn.getAttribute('data-audio');
			if (!url) return;
			var a = document.createElement('a');
			a.href = url;
			a.download = "speech.mp3";
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
		}
        let messageHistory = [];

		const userTextarea  = document.getElementById("userInput");
		const userchatbar   = document.getElementById("chatbar");
        const sendButtonmsg = document.getElementById("btnmsg");
		const selectElement = document.getElementById("voiceSelect");
		const loadingEl     = document.getElementById("loading");

        // 使用浏览器内置 Web Speech API (speechSynthesis)
        // Windows/Edge 内置 Microsoft Neural 语音，与声音列表完全对应
        async function sendText() {
            const userInput     = userTextarea.value.trim();
            const selectedVoice = selectElement.value;
            if (!userInput) return;

            sendButtonmsg.disabled = true;
            userTextarea.disabled  = true;
			if (loadingEl) loadingEl.style.display = "flex";

            try {
                addMessage("user", userInput);

				let audioUrl = "";
				try {
					audioUrl = await requestTtsAudio(userInput, selectedVoice);
				} catch (e) {
					console.log(e);
					showToast("语音合成服务不可用，已切换为浏览器语音播放", "error");
				}

				if (audioUrl) {
					addMessage("bot", userInput, selectedVoice, audioUrl);
				} else {
					if (!window.speechSynthesis) {
						addMessage("sys", "您的浏览器不支持语音合成，请使用 Edge 或 Chrome");
					} else {
						window.speechSynthesis.cancel();
						// 开始朗读（fire-and-forget，错误通过回调显示）
						speakText(userInput, selectedVoice).catch(function(e) {
							addMessage("sys", "语音合成失败：" + e.message);
						});
					}
					addMessage("bot", userInput, selectedVoice, "");
				}

                const chatTitle = document.createElement("div");
                chatTitle.className = "chattitle";
                chatTitle.textContent = userInput;
				chatTitle.setAttribute("data-text", userInput);
				chatTitle.setAttribute("data-voice", selectedVoice);
				if (audioUrl) chatTitle.setAttribute("data-audio", audioUrl);
				chatTitle.onclick = function(){ playHistoryItem(this); };
                userchatbar.appendChild(chatTitle);

                messageHistory.push({ voice: selectedVoice, text: userInput, audio: audioUrl });
            } finally {
				if (loadingEl) loadingEl.style.display = "none";
                sendButtonmsg.disabled = false;
                userTextarea.disabled  = false;
                userTextarea.value     = "";
            }
        }

        // 封装 speechSynthesis，加载声音后朗读，返回 Promise
        function speakText(text, voiceName) {
            return new Promise(function(resolve, reject) {
                var utterance = new SpeechSynthesisUtterance(text);
                utterance.lang  = voiceName.indexOf('zh-HK') === 0 ? 'zh-HK' :
                                  voiceName.indexOf('zh-TW') === 0 ? 'zh-TW' : 'zh-CN';
                utterance.rate  = 1.0;
                utterance.pitch = 1.0;

                function doSpeak() {
                    var vs = window.speechSynthesis.getVoices();
                    var v  = vs.find(function(x) { return x.name === voiceName; });
                    if (v) utterance.voice = v;
                    utterance.onend   = function() { resolve(); };
                    // interrupted = 主动 cancel() 触发，不是真正错误
                    utterance.onerror = function(e) {
                        if (e.error === 'interrupted' || e.error === 'canceled') { resolve(); }
                        else { reject(new Error(e.error)); }
                    };
                    window.speechSynthesis.speak(utterance);
                }

                var vs = window.speechSynthesis.getVoices();
                if (vs.length > 0) { doSpeak(); }
                else { window.speechSynthesis.onvoiceschanged = doSpeak; }
            });
        }
		// 请求服务器语音合成，返回可播放的音频 URL
		async function requestTtsAudio(text, voice) {
			const resp = await fetch("speekvoice.ashx", {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({ text: text, voice: voice })
			});
			const ct = (resp.headers.get("content-type") || "").toLowerCase();
			if (!resp.ok || ct.indexOf("audio") === -1) {
				let errMsg = "语音合成失败";
				try {
					if (ct.indexOf("json") > -1) {
						const data = await resp.json();
						if (data && data.error) errMsg = data.error;
					} else {
						const t = await resp.text();
						if (t) errMsg = t;
					}
				} catch (e) { }
				throw new Error(errMsg);
			}
			const blob = await resp.blob();
			return URL.createObjectURL(blob);
		}

		function stopSpeech() {
			if (window.speechSynthesis) window.speechSynthesis.cancel();
		}

		function replayText(text, voice) {
			stopSpeech();
			setTimeout(function() {
				speakText(text, voice).catch(function(e) {
					addMessage("sys", "重播失败：" + e.message);
				});
			}, 50);
		}

		function playAudioUrl(url) {
			stopSpeech();
			pauseAllAudio();
			try {
				var audio = new Audio(url);
				audio.play().catch(function(){});
			} catch(e) {}
		}

		function playHistoryItem(el) {
			if (!el) return;
			var audioUrl = el.getAttribute("data-audio");
			var text = el.getAttribute("data-text");
			var voice = el.getAttribute("data-voice");
			if (audioUrl) playAudioUrl(audioUrl);
			else if (text && voice) replayText(text, voice);
		}

        // 重播按钮回调
        function replayMsg(btn) {
            var text  = btn.getAttribute('data-text');
            var voice = btn.getAttribute('data-voice');
			if (text && voice) replayText(text, voice);
        }
		
		
		// role: "user" | "bot" | "sys"
		// bot 调用：addMessage("bot", text, voiceName)
		function addMessage(role, content, voiceName, audioUrl) {
			const chatHistory = document.getElementById("chatHistory");
			const messageDiv  = document.createElement("div");
			messageDiv.className = 'message ' + role;

			if (role === "bot") {
				// 显示声音标签 + 重播按钮
				var opt = selectElement.querySelector('option[value="' + voiceName + '"]');
				var vLabel = opt ? opt.textContent : voiceName;
				var safeText = content.replace(/"/g, '&quot;').replace(/'/g, '&#39;');
				if (audioUrl) {
					messageDiv.innerHTML =
						'<div class="sp-bot-msg">'
						+ '<span class="sp-voice-lbl">🔊 ' + vLabel + '</span>'
						+ '<audio class="sp-audio" src="' + audioUrl + '" controls preload="none"></audio>'
						+ '<div class="sp-audio-actions">'
						+ '<button class="sp-replay-btn" data-audio="' + audioUrl + '" onclick="replayAudio(this)">↻ 重播</button>'
						+ '<button class="sp-download-btn" data-audio="' + audioUrl + '" onclick="downloadAudio(this)">⬇ 下载</button>'
						+ '</div>'
						+ '</div>';
				} else {
					messageDiv.innerHTML =
						'<div class="sp-bot-msg">'
						+ '<span class="sp-voice-lbl">🔊 ' + vLabel + '</span>'
						+ '<button class="sp-replay-btn" data-text="' + safeText + '" data-voice="' + voiceName + '" onclick="replayMsg(this)">↻ 重播</button>'
						+ '</div>';
				}
			} else if (role === "sys") {
				messageDiv.innerHTML = '<div style="color:#ef4444;font-size:13px;padding:8px 12px;background:#fef2f2;border-radius:8px;border:1px solid #fecaca">⚠️ ' + content + '</div>';
			} else {
				messageDiv.innerHTML = '<div class="user">📝 ' + content + '</div>';
			}

			chatHistory.appendChild(messageDiv);
			if (role === "bot" && audioUrl) {
				var audio = messageDiv.querySelector('audio');
				if (audio) {
					stopSpeech();
					pauseAllAudio();
					audio.play().catch(function(){});
				}
			}
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
			for (let audio of audioElements) {
				audio.pause();
			}
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
        	            showToast('✓ 保存成功！', 'success');
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
