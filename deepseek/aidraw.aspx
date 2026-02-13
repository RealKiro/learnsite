<%@ page language="C#" autoeventwireup="true" inherits="deepseek_aidraw, LearnSite" %>

<html lang="zh-CN">
<head id="Head1"  runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI绘画- 探索未知之境</title>
    <link rel="stylesheet" href="deepseek.css">
    <!-- Font Awesome 图标库 -->
    <link rel="stylesheet" href="all.min.css">
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
	
</head>
<body>
    <div class="container" id="maincontainer">		
        <div class="left-column">		
			<!-- 聊天区域 -->
				<h2 style="text-align:center;" ><img class ="logo"  src="draw.png" /> AI绘画，想象与创意</h2>			
			<!-- 输入框区域 -->
			<div class="loading-container">
			<!-- 加载状态 -->
			<div id="loading" style="display: none;"><img src="loading.gif" />思考中...</div>
			
			</div>
                <div class="prompt-helper">
                    <h3>绘画提示词</h3>
                    <div class="prompt-tags-container">
                        <div class="prompt-tag" data-prompt="一只可爱的猫咪在玩毛线球">🐱猫咪玩毛线球</div>
                        <div class="prompt-tag" data-prompt="一条彩色的小鱼在海底游泳，周围有珊瑚">🐟彩色小鱼游泳</div>
                        <div class="prompt-tag" data-prompt="一个宇航员在太空中漂浮">👨‍🚀宇航员太空漂浮</div>
                        <div class="prompt-tag" data-prompt="一座魔法城堡周围有绿色的森林和小精灵">🏰魔法城堡和精灵</div>
                        <div class="prompt-tag" data-prompt="一只恐龙在森林里吃水果">🍎恐龙吃水果</div>
                        <div class="prompt-tag" data-prompt="一个卡通风格小女孩在堆雪人">⛄小女孩堆雪人</div>
                        <div class="prompt-tag" data-prompt="一艘宇宙飞船正在星际航行">🚀宇宙飞船航行</div>
                        <div class="prompt-tag" data-prompt="一只热气球飞越山脉，山下有小村庄">🎈热气球飞行</div>
                        <div class="prompt-tag" data-prompt="一个机器人在玩足球">⚽机器人踢足球</div>
                        <div class="prompt-tag" data-prompt="一个水下城市，有鱼儿和美人鱼">🏰水下城市</div>
                        <div class="prompt-tag" data-prompt="一个童话森林，有大大的蘑菇房子和小动物">🍄童话森林</div>
                    </div>
                </div>
				
			<!-- 输入框区域 -->
			<div class="input-container">
				<textarea id="userInput" placeholder="一只可爱的小狗在草地上玩耍，旁边有蝴蝶在飞舞" rows="1"></textarea>
				<button id="btnphoto"   onclick="aiPhoto()" title="文本生成图片">生成图片</button>
				<button  type = "button" onclick="savechat()" class="buttonsave"  title="保存到服务器上" >
				<i class="fa fa-save" aria-hidden="true"></i> 保存</button>
				<button  onclick="returnurl()" class="button" title="返回到学案页面">
				<i class="fa fa-reply" aria-hidden="true"></i> 返回</button> 
			</div>
			
			<div class="photo-container" id="chatHistory">
				<!-- 聊天记录将动态加载到这里🐳  -->
			</div>
        </div>	
		
        <div class="right-column">
			<!-- 导航栏 -->
			<div class="photobar">
			绘画作品列表
			</div>
			<!-- 聊天记录栏 -->
			<div id ="chatbar">			
			</div>			
            <div id="footbar">           
            </div>
        </div>

 </div>
    <script>
		
		const userTextarea = document.getElementById("userInput");
		const chatHistory = document.getElementById("chatHistory");
		const userchatbar = document.getElementById("chatbar");
        const sendButtonphoto = document.getElementById("btnphoto");
		var imgload = new Image();
		imgload.src = "loading.gif";
        var count =0;
        var myprompt = "";
		var port=":2000";//端口
		var lor=location.origin+port;// http://192.168.1.3
		console.log(location.origin);
		
        const apiPhotoUrl = lor+"/photo";
		
		//文生图
		async function aiPhoto(){
			sendButtonphoto.disabled = true;
			chatHistory.innerHTML ="";
			chatHistory.appendChild(imgload);
			var prompt = userTextarea.value.trim();
            width = 640;
            height = 480;
            seed = 30;
			model = 'flux';	
			
			myprompt = prompt;
            const userMessage = { role: "user", content: prompt };
			
			response = await fetch(apiPhotoUrl, {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({ messages: userMessage }) // 改为发送完整对话历史
			});
			
			const data = await response.json();
			addMessage(data.response);
		}
	
	
	function addMessage(content){
			
		// 获取canvas元素和绘图上下文
		var canvas = document.createElement('canvas');
		canvas.width = width;
		canvas.height = height;
		var ctx = canvas.getContext('2d');		
					// 创建一个新的Image对象
		var img = new Image();
		img.src = content;
		img.title = myprompt;
		// 当图片加载完成后，将其绘制到canvas上
		img.onload = function() {				 
			// 在canvas上绘制图片，可以根据需要调整位置和大小
			chatHistory.innerHTML ="";
			img.id="photoview";
			chatHistory.appendChild(img);										
				
            // 平滑滚动到顶部表单区域
            window.scrollTo({
                top: userTextarea.offsetTop - 200,
                behavior: 'smooth'
            });
			count++;
            myprompt = prompt
			sendButtonphoto.disabled = false;
		};
			
		// 创建缩略图img元素
		var thumb = document.createElement('img');
		thumb.src = img.src;
		thumb.width = 160; 
		thumb.title = myprompt;
		// 添加onclick事件
		thumb.onclick = function() {
			var photoview = document.getElementById("photoview");
			photoview.src = this.src;
		};
		userchatbar.appendChild(thumb);	
	}
	
	
	// 自动调整输入框高度
	document.getElementById("userInput").addEventListener("input", (event) => {
		event.target.style.height = "auto";
		event.target.style.height = event.target.scrollHeight + "px";
	});
		
		
	initPromptTags();
	initStyleSelector();
	
	    /**
     * 初始化提示词标签
     */
    function initPromptTags() {
        // 获取提示词容器
        const promptTagsContainer = document.querySelector('.prompt-tags-container');
        if (!promptTagsContainer) {
            console.error('找不到提示词容器元素');
            return;
        }
        
        // 克隆并替换容器以移除之前的事件监听器
        const newContainer = promptTagsContainer.cloneNode(true);
        promptTagsContainer.parentNode.replaceChild(newContainer, promptTagsContainer);
        
        // 获取所有提示词标签
        const promptTags = newContainer.querySelectorAll('.prompt-tag');
        
        // 为每个提示词标签添加点击事件
        promptTags.forEach(tag => {
            tag.addEventListener('click', function(event) {
                // 阻止事件冒泡
                event.stopPropagation();
                
                // 获取提示词内容
                const promptText = this.getAttribute('data-prompt');
                if (!promptText) return;
                
                // 获取提示词输入框
                const promptInput = document.getElementById('userInput');
                if (!promptInput) return;
                
                // 填充到输入框
                promptInput.value = promptText;
                               
                // 让输入框获得焦点
                promptInput.focus();
                
                // 添加简单的动画效果
                this.style.transform = 'scale(0.9)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 200);                
                
            });
        });
        
    }
	
	/**
     * 初始化风格选择器
     */
    function initStyleSelector() {
        // 获取所有风格标签及其父元素
        const styleLabels = document.querySelectorAll('.style-tag');
        
        // 找到默认选中的风格并添加active类
        const defaultStyle = document.querySelector('.style-tag input:checked');
        if (defaultStyle) {
            defaultStyle.parentElement.classList.add('active');
        }
        
        // 清除并重新添加点击事件
        styleLabels.forEach(label => {
            // 清除可能存在的原有事件监听
            const newLabel = label.cloneNode(true);
            label.parentNode.replaceChild(newLabel, label);
            
            // 获取标签中的radio input元素
            const radioInput = newLabel.querySelector('input[type="radio"]');
            
            // 为标签添加点击事件（不是为radio添加change事件）
            newLabel.addEventListener('click', (e) => {
                // 阻止事件冒泡
                e.stopPropagation();
                
                // 确保radio被选中
                if (radioInput) {
                    radioInput.checked = true;
                    
                    // 触发一个人工的change事件
                    const changeEvent = new Event('change', { bubbles: true });
                    radioInput.dispatchEvent(changeEvent);
                    
                    // 高亮显示选中的标签
                    document.querySelectorAll('.style-tag').forEach(el => {
                        el.classList.remove('active');
                    });
                    newLabel.classList.add('active');
                    
                    // 显示提示
                    const styleName = newLabel.querySelector('span').textContent.trim();
					defaultstyle = styleName;
                    // 如果用户正在输入提示词，可以提示风格已改变
                    const promptInput = document.getElementById('prompt');
                    if (promptInput && promptInput.value.trim() !== '') {
                        // 已禁用弹窗提示
                    }
                }
            });
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
            var htmlcode ="";// preview.innerHTML;使用缩略图预览
        	if (count > 0) {
                html2canvas(preview, { allowTaint: true }).then(pic => {					
        	        var urls = '../student/uploadtopic.ashx?id=' + id;
			        var title = "";//绘画提示词
			        var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			        var Content = htmlcode;
			        var Extension = "text-to-image";
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

