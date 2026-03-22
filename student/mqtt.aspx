<%@ page language="C#" autoeventwireup="true" inherits="student_mqtt, LearnSite" %>
<script runat="server">
    protected string stuName = "";
    private string GetProp(object model, string propName)
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
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    stuName = GetProp(m, "Sname");
                }
            }
        }
        catch { }
    }
</script>
<!DOCTYPE html>
<html >
<head runat="server">
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>物联网MQTT服务</title>
	<script src="../code/mqtt/mqtt.min.js" ></script>
    <script src="../code/jquery.min.js"></script>
    <link href="../code/mqtt/mqtt.css" rel="stylesheet" type="text/css" />
	<script src="../code/chart.js"></script>
</head>

<body>
<div class="banner"></div>
<div class="mqttset">

	<!-- 连接设置栏 -->
	<div class="mq-conn-bar">
		<div class="mq-conn-info">
			<img id="broker" src="../code/mqtt/ready.png" title="Mqtt状态" />
			<div class="mq-field"><span class="mq-lbl">服务器</span><input id="txtIp" type="text" readonly/></div>
			<div class="mq-field"><span class="mq-lbl">端口</span><input id="txtPort" type="text" readonly/></div>
			<input id="txtId" type="hidden" />
			<div class="mq-field"><span class="mq-lbl">学号</span><input id="txtUser" type="text" readonly/></div>
			<input id="txtPwd" type="hidden" />
			<% if (!string.IsNullOrEmpty(stuName)) { %>
			<div class="mq-field mq-user-tag" id="mqUserTag"><span class="mq-lbl">姓名</span><span id="mqUserName" class="mq-user-name"><%= stuName %></span></div>
			<% } %>
		</div>
		<div class="mq-conn-btns">
			<button id="btnConnect">
				<svg viewBox="0 0 24 24"><path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><circle cx="12" cy="20" r="1" fill="currentColor"/></svg>
				点击连接
			</button>
			<button id="savebtn" onclick="savework()">
				<svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
				保存
			</button>
			<button id="returnbtn" onclick="returnurl()">
				<svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
				返回
			</button>
		</div>
	</div>

	<!-- 主区域 -->
	<div class="mq-main">

		<!-- 左：消息日志 -->
		<div class="mq-panel">
			<div class="mq-panel-head">
				<svg viewBox="0 0 24 24"><polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/></svg>
				消息日志
			</div>
			<div class="messages"></div>
		</div>

		<!-- 中：设备控制 -->
		<div class="mq-panel">
			<div class="mq-panel-head">
				<svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
				设备控制
			</div>
			<div class="center">
				<div class="mq-devices">
					<img id="led"  class="device" src="../code/mqtt/led.png"  title="灯光控制 led" />
					<img id="fan"  class="device" src="../code/mqtt/fan.png"  title="风扇控制 fan" />
					<img id="pump" class="device" src="../code/mqtt/pump.png" title="水泵控制 pump" />
				</div>
				<div class="mq-topic-row">
					<div class="mq-field-row">
						<span class="mq-lbl">主题</span>
						<input id="txtTopic" type="text" readonly/>
					</div>
					<div class="mq-field-row">
						<span class="mq-lbl">消息</span>
						<input id="txtPayload" type="text" value="off" readonly/>
					</div>
				</div>
				<div class="mq-pub-btns">
					<button id="btnPublish" disabled="true">
						<svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
						发布
					</button>
					<button id="btnSub" disabled="true">
						<svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
						订阅
					</button>
				</div>
				<div class="sesor">
					<div class="mq-sensors">
						<div class="mq-sensor-item">
							<img id="distance"    class="measure" src="../code/mqtt/distance.png"    title="距离 dist" />
							<div id="distancenum"    class="data">0</div>
						</div>
						<div class="mq-sensor-item">
							<img id="temperature" class="measure" src="../code/mqtt/temperature.png" title="温度 temp" />
							<div id="temperaturenum" class="data">0</div>
						</div>
						<div class="mq-sensor-item">
							<img id="humidity"    class="measure" src="../code/mqtt/humidity.png"    title="湿度 humi" />
							<div id="humiditynum"    class="data">0</div>
						</div>
						<div class="mq-sensor-item">
							<img id="light"       class="measure" src="../code/mqtt/light.png"       title="亮度 light" />
							<div id="lightnum"       class="data">0</div>
						</div>
						<div class="mq-sensor-item">
							<img id="sound"       class="measure" src="../code/mqtt/mic.png"          title="声音 sound" />
							<div id="soundnum"       class="data">0</div>
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- 右：连接日志 + 订阅 -->
		<div class="mq-panel">
			<div class="mq-panel-head">
				<svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
				连接日志
			</div>
			<div class="linkuser"></div>
			<div class="divleft mq-sub-area">
				<span class="mq-lbl">已订阅主题</span>
				<select class="subtopics"></select>
				<button id="btnUnSub" disabled="true">
					<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
					取消订阅
				</button>
			</div>
		</div>

	</div>

	<!-- 图表 -->
	<div class="mq-panel mq-chart-panel">
		<div class="mq-panel-head">
			<svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
			传感器数据图表
		</div>
		<div class="mq-chart-wrap">
			<canvas id="myChart" height="60"></canvas>
		</div>
		<div class="mq-chart-footer">
			<span id="msg"></span>
			<div class="mq-alert-row">
				<img class="volume" src="../code/mqtt/volume.png" title="声音警报" />
				<span class="mq-lbl">警报阈值</span>
				<input class="alert" type="text" value="16000" />
			</div>
		</div>
		<audio id="audio" controls hidden></audio>
	</div>

</div>
<div class="mq-toast" id="mqToast"></div>
</body>
<script type="text/javascript">
	function showToast(msg, type) {
		var t = document.getElementById('mqToast');
		t.textContent = msg;
		t.className = 'mq-toast ' + (type || 'success') + ' show';
		clearTimeout(t._t);
		t._t = setTimeout(function(){ t.className = 'mq-toast ' + (type || 'success'); }, 2400);
	}

	const ctx = document.getElementById('myChart');
    var id = "<%=Id %>";
	var user= "<%=Snum %>"; 
	var workdevice= "<%=workDevice %>"; 
    var serverip="<%=serverIp %>";

    function returnurl() {
        if (confirm('确定要返回吗，记得先保存。') == true) {
            window.location.href = "<%=Fpage %>";
        }
    }
    
	var count=0;//信息数据

    function savework() {
        //var workcount=count-pubcount;
        if(count>0)
        {
            var title = "";
            var Content=$(".messages").html();
            var Cover = blob(ctx.toDataURL());
            var Extension = "mqtt";
            var urls = 'uploadmqtt.ashx?id=' + id;
            var formData = new FormData();
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
            });
        }
        else{
            showToast('请先连接控制板进行实验，发布主题后才能保存！', 'error');
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

    var clientId = 'stu'+ user+ Math.random().toString(16).substr(2, 6);//添加随机数，方便多开页面，mqtt支持不验证连接
	var pwsd='123456';
	var webip=window.location.host;
    if(serverip!=""){
        webip=serverip;
    }

	// 根据页面协议自动适配 ws / wss，避免 HTTPS 页面连接 ws:// 被浏览器拦截
	var isHttps = (location.protocol === 'https:');
	var wsProto = isHttps ? 'wss://' : 'ws://';
	var wsPort  = isHttps ? 5001 : 5000;  // wss 用 5001，ws 用 5000，按实际服务器配置调整

	$('#txtIp').val(webip);
	$('#txtPort').val(wsPort);
	$('#txtId').val('m'+user);
	$('#txtUser').val(user);
	$('#txtPwd').val(pwsd);

	
	
	var client;
	var host = wsProto + webip + ':' + wsPort + '/mqtt';

    const options = {
        keepalive: 30,
        clientId: clientId,
	    username: user,
	    password: pwsd,
        protocolId: 'MQTT',
        protocolVersion: 4,
        clean: true
    }

	console.log('物联网实验室');	
	var isled=false;
	var countlist=[];
	var msglist=[];
	var islive=false;//是否连接
    var pubcount=0;//自己发布主题数量	
	var begintime = "";//连接时间
	var startime="";//采样时间
	var sampling="";//当前采样时间
	
	var machine=['led','fan','pump','temperature','humidity','sound','light','distance'];//配置设备列表
	var work=['led','fan','pump','temperature','humidity','sound','light','distance'];//使用设备列表，选择一个即可
	
    if(workdevice){
        work=workdevice.split(',');
		console.log(work);
    }
        
    function getWork(mea){
    	switch(mea){
			case 'distance':
				mea='dist';
				break;
			case 'temperature':
				mea='temp';
				break;
			case 'humidity':
				mea='humi';
				break;
		}
        return mea;
    }

	var topicset=getWork(work[0]) +'/'+user;//设置设备主题名称
	$('#txtTopic').val(topicset);

	machine.forEach(function(dev){
		var mach='#'+dev;
		$(mach).hide();
		var machnum=mach+'num';
		$(machnum).hide();		
	});
	
	work.forEach(function(dev){
		if(dev){
			var wk='#'+dev;
			console.log("工作设备",wk)
			$(wk).show();
			var wknum=wk+'num';
			$(wknum).show();	
		}		
	});
	
    
    $("#myChart").dblclick(function(){
	  const el = document.createElement('a');
	  el.href = ctx.toDataURL();
	  el.download = '传感器采样图表';
	  const event = new MouseEvent('click');
	  el.dispatchEvent(event);
	});
	
	$('input').on('focus', function() {
        // 在input获得焦点时，选择所有文本
        $(this).select();
    });
	
	$('#btnConnect').click(function () {		
		console.log('正在连接mqtt服务……');		
		client = mqtt.connect(host, options);
		$(this).attr('disabled',true);	
	
	$('.measure').click(function () {
		var mea="";
		switch(this.id){
			case 'distance':
				mea='dist';
				break;
			case 'temperature':
				mea='temp';
				break;
			case 'humidity':
				mea='humi';
				break;
			case 'sound':
				mea='sound';
				break;
			case 'light':
				mea='light';
				break;		
		}
		$('#txtTopic').val(mea+"/"+user);
    });

		
	$('.device').click(function () {
		$('#txtTopic').val(this.id+'/'+user);
		console.log(isled);
		if(isled){		
			$('#txtPayload').val("off");
			var icon=this.src.replace('gif','png');
			$(this).attr("src",icon);
			isled=false;
		}	
		else{
			$('#txtPayload').val("on");	
			var icon=this.src.replace('png','gif');
			$(this).attr("src",icon);
			isled=true;	
			cur	=this.id;		
		}
    });

	var cur='led';
	
	$('#btnSub').click(function () {
		var mytopic= $('#txtTopic').val();		
		console.log("订阅主题：",mytopic);		
        client.subscribe(mytopic, { qos: 0 });	
		addsubtopic(mytopic);
    });	
	
	function addsubtopic(topic){
		var exists = false; 
		$('.subtopics option').each(function(){
		  if (this.value == topic) {
			exists = true;
		  }
		});
		if(!exists){
			var op="<option>"+topic+"</option>";
			$('.subtopics').append(op);
			$('.linkuser').append("已订阅主题："+topic+"<br>");
			$('#btnUnSub').attr('disabled',false);
		}
	}
	
	$('#btnUnSub').click(function () {
		var mytopic= $('.subtopics').find("option:selected").text();
		if(mytopic){		
			console.log("取消订阅：",mytopic);		
			client.unsubscribe(mytopic, { qos: 0 })	
			$('.linkuser').append("已取消订阅："+mytopic+"<br>");	
			$(".subtopics option:selected").remove(); 
		}
		mytopic= $('.subtopics').find("option:selected").text();
		if(!mytopic){
			$(this).attr('disabled',true);
		}
    });	
	
	$('#btnPublish').click(function () {
        pubcount++;
		var mytopic= $('#txtTopic').val();		
		console.log("发布主题：",mytopic);
		
		var mypayload= $('#txtPayload').val();		
		console.log("负载消息：",mypayload);
		
		client.publish(mytopic, mypayload, { qos: 0, retain: false });//发布		
    });
	
	
    client.on('error', function (err) {
		$('.linkuser').append("连接Mqtt服务失败！");
        console.log(err);
        client.end();
    })

    client.on('connect', function () {
		var str= " MQTT服务已连接.<br>";
		islive=true;
        console.log(clientId+"已连接.");
		begintime= Date.now();
		$('.linkuser').append(str);
		$('#broker').attr("src","../code/mqtt/run.png");
        client.subscribe(topicset, { qos: 0 });//订阅默认Led主题
		addsubtopic(topicset);
        //client.publish(topic, 'wss secure connection 成功 demo...!', { qos: 0, retain: false })
		$('#btnPublish').attr('disabled',false);
		$('#btnSub').attr('disabled',false);
		$('#btnUnSub').attr('disabled',false);
		$('#btnConnect').text("已经连接");
		$(".device").css("filter",'grayscale(0)');
		$(".measure").css("filter",'grayscale(0)');
    })

    client.on('message', function (topic, message, packet) {
		const decoder = new TextDecoder();//字节转字符串
        //console.log(packet.topic,decoder.decode(packet.payload));
		receiveMessage(topic,message,packet);		
    })

    client.on('close', function () {
		if(islive){
			var str='MQTT服务已断开！';
			console.log(str);
			$('.linkuser').append(str+"<br>");
			$(".linkuser").scrollTop($(".linkuser").height()*count);
			$('#broker').attr("src","../code/mqtt/ready.png");
		}
		islive=false;
    })
	
	receiveMessage = function (topic, message, type) {
		if(count==0){
			startime=Date.now();//采样开始时间
		}
		count++;
		sampling=Date.now();
		
		const decoder = new TextDecoder();//字节转字符串		
		message=decoder.decode(message);//字节转字符串
		
		if(isNum(message)){
			countlist.push(count);
			msglist.push(message);//记录消息
			notice(message);//是否发警报声
		}				
		//console.log('计数：',countlist);
		//console.log('信息：',msglist);
		updateChartData();//更新图表
		//var d = new Date();//d.toLocaleString()
		//adding new message
		$(".messages").append(count+'. 主题： ' + topic + '  消息： ' + message + '<hr>');
		//autoscrolling to the bottom
		$(".messages").scrollTop($(".messages").height()*count);
		
		if(topic.includes('led')){
			//console.log(topic,message);
			switch(message){
				case 'off':
					$('#led').attr("src","../code/mqtt/led.png");
					break;
				case 'on':
					$('#led').attr("src","../code/mqtt/led.gif");
					break;
			}			
		}
		if(topic.includes('fan')){
			//console.log(topic,message);
			switch(message){
				case 'off':
					$('#fan').attr("src","../code/mqtt/fan.png");
					break;
				case 'on':
					$('#fan').attr("src","../code/mqtt/fan.gif");
					break;
			}			
		}
		
		if(topic.includes('pump')){
			//console.log(topic,message);
			switch(message){
				case 'off':
					$('#pump').attr("src","../code/mqtt/pump.png");
					break;
				case 'on':
					$('#pump').attr("src","../code/mqtt/pump.gif");
					break;
			}			
		}
		
		if(topic.includes('dist')){
			$('#distancenum').text(message);
		}
		if(topic.includes('light')){
			$('#lightnum').text(message);
		}
		if(topic.includes('sound')){
			$('#soundnum').text(message);
		}
		if(topic.includes('temp')){
			$('#temperaturenum').text(message);
		}
		if(topic.includes('humi')){
			$('#humiditynum').text(message);
		}
		
	}	
	
    });
	function isNum(val) {
	  return !isNaN(val)
	}	
	
	function notice(message) {
		var currentvalue=parseInt(message);
		var setalert= parseInt($('.alert').val());	
		if(currentvalue<setalert){
			var audio = document.getElementById("audio");
			audio.src = '../code/mqtt/help.mp3';
			var playPromise = audio.play();

			if (playPromise) {
				playPromise.then(() => {
					// 音频加载成功
					// 音频的播放需要耗时
					setTimeout(() => {
						// 后续操作
						//console.log("play.");
					}, audio.duration * 1000); // audio.duration 为音频的时长单位为秒

				}).catch((e) => {
					// 音频加载失败
				});
			}
		}		
	}
</script>

<script type="text/javascript" >
    // 创建图表实例 line bar 
    var myChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: countlist, // X轴标签
            datasets: [{
                label: '传感器数据采样图表', // 数据集名称
                data: msglist, // 初始数据
                backgroundColor: 'rgba(68, 187, 109, 0.6)', // 数据集颜色
                borderColor: 'rgba(68, 187, 109, 0.8)', // 数据集边框颜色
                borderWidth: 1,
                pointRadius: 1 // 设置点的半径为2
            }]
        },
        options: {
            title: {
                display: true,
                text: "Custom Chart Title"
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    // 更新图表数据的函数
    function updateChartData() {
        // 假设我们获取了新的数据
        var labels = countlist;
        var newData = msglist;
        var se = parseInt((sampling - startime) / 1000);
        var mu = parseInt(se / 60);
        var sd = se - mu * 60;
        //console.log('采样持续时间：',mu,'秒');
        $("#msg").html('采样持续时间：' + mu + '分' + sd + '秒');
        // 使用Chart.js的update方法更新数据
        myChart.data.labels = labels;
        myChart.data.datasets.data = newData;
        //myChart.data.datasets.forEach(function (dataset) {
        //    dataset.data = newData;
        //});

        // 重绘图表
        myChart.update();

        return "已更新"
    }
</script>
</html>