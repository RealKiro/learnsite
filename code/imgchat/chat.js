isconneted=false;// 连接状态
		
function voiceplay(){
	var audio = document.getElementById("audio");
	audio.src = '../code/code.ogg';
	audio.play();
}


function message() {
    var a = $.blinkTitle.show();
    setTimeout(function () {
        $.blinkTitle.clear(a)
    }, 8e3)
}

function Progress(n) {
	var msgstr="上传进度"+n+"%";
	$('#progress').LineProgressbar({
		percentage: 100,radius: '10px'
	});
	//console.log(msgstr);
}

// 上传图片
let upone = new fcup({
  id: "upphoto", // 绑定id
  url: "upchat.ashx", // url地址	  
  type: "jpg,png,jpeg,gif,txt,pdf,mp3,ogg,mp4,wav,docx,xlsx,pptx,py,sb3,psd,rar,zip,md", // 限制上传类型，为空不限制  
  // 上传成功回调，回调会根据切片循环，要终止上传循环，必须要return false，成功的情况下要始终返回true;
  //max_size: "1000", // 上传文件最大M数，单位为M，默认200M
  error_msg: {
     1000: "未找到上传id",
     1001: "允许发送的图片格式和附件格式为jpg,png,jpeg,gif,txt,pdf,mp3,mp4,wav,docx,xlsx,pptx,py,sb3,psd,rar,zip",
	 1002: "上传文件过小",
	 1003: "上传文件过大",
	 1004: "上传请求超时"
  },

  // 上传进度事件
  progress: (num, other) => {
	 Progress(num);
  },
	  
  success: (res) => {
	 let data = res ? eval('(' + res + ')') : '';
	 let url = data.url ;
	 if (data.status == 2) {
			//console.log(url); // 
			var fileName = url.match(/[^\/]*$/)[0];
			var fileExt = fileName.substring(fileName.lastIndexOf('.') + 1);	
			var urlext="../images/FileType/" + fileExt + ".gif";//文件类型图标
            var urlico="<img src='"+urlext+"' />";
			var uploadhtml="";
			switch(fileExt){
				case "jpg":	
				case "jpeg":	
				case "png":	
				case "gif":					
					uploadhtml="<img class='chatpic' src='"+url+"' title='"+fileName+"' />";
					break;
				case "mp3":
					uploadhtml="<audio src='"+url+"' title='"+fileName+"' controls>"+fileName+"</audio>";
					break;
				case "mp4":	
				case "ogg":			
					uploadhtml="<video src='"+url+"'  width='320' height='240' title='"+fileName+"' controls>"+fileName+"</video>";
					break;
				default:
					uploadhtml="<a href='"+url+"' target='_blank' title='点击下载' >"+urlico+fileName+"</a>";
					break;
			}			
			//$(".textarea").focus();
			$(".textarea").append(uploadhtml);
			$('#progress').html("");
	 }
	 // 如果接口没有错误，必须要返回true，才不会终止上传循环
	 return true;
  }
});	


//动态生成的html里事件编写
$(document).on("click",".mes img",function (){
	$('.imgBox').html("<div class='enlargeImg_wrapper'></div>");
	var imgSrc = $(this).attr('src');
	//console.log(imgSrc);
	$(".enlargeImg_wrapper").css("background-image","url(" + encodeURI(imgSrc) + ")");
	$('.enlargeImg_wrapper').fadeIn(200);	

})

$('.imgBox').on('click','.enlargeImg_wrapper',function() {
	$('.enlargeImg_wrapper').fadeOut(200).remove();
	
})

//--------------------------------------------------------------------

$(document).ready(function () {

    var hostip = location.host;
    if(serverip!=""){
        hostip=serverip;
    }
    // create a new websocket and connect
    var wsurl = "ws://" + hostip + ":8188/";
    window.ws = new WebSocket(wsurl);
    console.log(wsurl);
    //当客户端收到服务端发来的消息时，触发onmessage事件
    //参数e.data包含server传递过来的数据
    window.ws.onmessage = function (evt) {
        //console.log("接收小组讨论");
        var msg = JSON.parse(evt.data);
        var idstr = msg[0];
        var textstr = msg[1];
        var snumstr = msg[2];
        var namestr = msg[3];
        var txtform = msg[4];
        var sgroupstr = msg[5];
        var talktimestr = msg[6];

        if (txtform == "chat") {
            if (sgroup == sgroupstr) {
                view(namestr, textstr,talktimestr);
                //console.log(namestr, textstr);
				var idstr="#stu"+snumstr+" label";
				var imgstr="#stu"+snumstr+" img";				
				$(idstr).removeClass("offline").addClass("online");
				$(imgstr).removeClass("offline").addClass("online");				
            }
            else{
                if(snum.charAt(0)=='s'){                    
                    view(namestr, textstr,talktimestr);
                    //模拟学生账号获取所有学生的交流信息
                }            
            }
        }				
    };

    // 当WebSocket创建成功时，触发onopen事件
    window.ws.onopen = function () {
		isconneted=true;
        msg = '.. 已连接\n';
        console.log(msg);
		
		var idstr="#stu"+snum+" label";
		var imgstr="#stu"+snum+" img";
		
		$(idstr).removeClass("offline").addClass("online");
		$(imgstr).removeClass("offline").addClass("online");
        //$(".chat03_content li img").removeClass("offline").addClass("online");
    };

    // 当客户端收到服务端发送的关闭连接请求时，触发onclose事件
    window.ws.onclose = function (e) {
		isconneted=false;
        msg = '.. 已断开\n';
        console.log(msg);
        $(".chat03_content li img").removeClass("online").addClass("offline");
    }

    // 如果出现连接、处理、接收、发送数据失败的时候触发onerror事件
    window.ws.onerror = function (e) {
        console.log("发送失败!");
    }
	
	//心跳检测
	var heartCheck = {
		timeout: 6000,        //6秒发一次心跳
		timeoutObj: null,
		serverTimeoutObj: null,
		reset: function(){
			clearTimeout(this.timeoutObj);
			clearTimeout(this.serverTimeoutObj);
			return this;
		},
		start: function(){
			var self = this;
			this.timeoutObj = setTimeout(function(){
				//这里发送一个心跳，后端收到后，返回一个心跳消息，
				//onmessage拿到返回的心跳就说明连接正常
				ws.send("ping");
				console.log("ping!")
				self.serverTimeoutObj = setTimeout(function(){//如果超过一定时间还没重置，说明后端主动断开了
					ws.close();     //如果onclose会执行reconnect，我们执行ws.close()就行了.如果直接执行reconnect 会触发onclose导致重连两次
				}, self.timeout)
			}, this.timeout)
		}
	}
	
	
	
	showhistory();

	function showhistory(){
		if (historys != "") {
			var temphtml=$(".mes").html();
			var oldh=$(".mes").height();
			$(".mes").html("");
			var hs = decodeURIComponent(historys);
			//console.log(historys);
			console.log("开始加载聊天记录");
			var json = JSON.parse(hs);
			//console.log(json);
			for (h in json) {
				var msg = JSON.parse(json[h]);
				var idstr = msg[0];
				var textstr = msg[1];
				var snumstr = msg[2];
				var namestr = msg[3];
				var txtform = msg[4];
				var sgroupstr = msg[5];
				var talktimestr = msg[6];
				
				if (txtform == "chat") {
					if (sgroup == sgroupstr) {
						view(namestr, textstr,talktimestr);						
					}
				}
			}
			historys="";//清除历史记录
			console.log("聊天记录加载完毕");
			$(".mes").append(temphtml);
			$(".chat01_content").scrollTop($(".mes").height()+oldh);
		}
	}
	
	$(".chat02_title_t").click(function () {
		showhistory();
    });

	//上线下线信息
	function onoffline(msg){		
		var dic = [];
        dic.push("");
        dic.push(msg);
        dic.push(snum);
        dic.push(sname);
        dic.push("isline");
        dic.push(sgroup);
        dic.push("");
		var dicstr = JSON.stringify(dic);
		window.ws.send(dicstr);//发送信息
	}

    $(".chat02_bar li button").click(function () {
		$(".wl_faces_box").hide();
		var word=$(".textarea").html().trim();
		//console.log(word);
		if(word){
			//word=encodeURIComponent(word);
			var da = new Date;
			var talktime = da.toLocaleString();
			
			view(sname, word, talktime);

			var dic = [];
			dic.push(head);
			dic.push(word);
			dic.push(snum);
			dic.push(sname);
			dic.push("chat");
			dic.push(sgroup);
			dic.push(talktime);

			var dicstr = JSON.stringify(dic);
			if(isconneted){
				window.ws.send(dicstr);
				console.log(sname,"在线发送",talktime);
			}
			else{
				console.log(sname,"离线发送",talktime);
			}
			//保存到服务器
			var urls = 'savechat.ashx';
			var formData = new FormData();
			formData.append('dic', dicstr);
			$.ajax({
				url: urls,
				type: 'POST',
				cache: false,
				data: formData,
				processData: false,
				contentType: false
			}).done(function (res) {
				//console.log(res)
				voiceplay();
			});
		}
    });

    function view(user, word,talktime) {	
        var g = word;
        //console.log(g);
        var i = "<div class='message clearfix'>" + "<div class='wrap-text'>" + "<span class='name' >" + user + " </span><span class='time' >" + talktime + "</span>" + "<div>" + g + "</div>" + "</div>" + "</div>";
        //console.log(i);
        if( null != g && "" != g ){		
			$(".mes").append(i), $(".chat01_content").scrollTop($(".mes").height()), $(".textarea").text(""), message() 
		}
    }
	
	$(".wl_emo_main").dblclick(function(){
		var selection=window.getSelection();
		var range  = selection.getRangeAt(0);
		var txt =selection.toString().trim();
		if(txt!=""){
			let span = document.createElement('span');
			span.style.fontSize ="24px";
			span.append(txt);			
			$(".textarea").append(span);
			$(".textarea").append("&nbsp;");
			//console.log(span) ;
			$(".wl_emo_main").hide();
		}		
	}),
	
	$(".textarea").mouseup(function(){
		var selection=window.getSelection();
		var range  = selection.getRangeAt(0);
		var txt =selection.toString();
		if(txt!=""){
			//console.log(txt) ;文字选中处理
			/*
			const docObj = range.extractContents();						
			let span = document.createElement('span');
			span.style.color = 'white' ;
			span.style.backgroundColor = '#0066cc' ;
			span.style.fontSize ="large";
			span.appendChild(docObj);
			range.insertNode(span);
			*/
		}
	}),		
    $(".chat03_title_t").click(function () {
        $(".chat03_content").slideDown();
        $(".chat03_file").slideUp();
    }),
    $(".chat03_title_f").click(function () {
        $(".chat03_content").slideUp ();
        $(".chat03_file").slideDown();
    }),
	
    $(".close_btn").click(function () {
        $(".chatBox").hide()
    }),
    $(".chat03_content li").mouseover(function () {
        $(this).addClass("hover").siblings().removeClass("hover")
    }).mouseout(function () {
        $(this).removeClass("hover").siblings().removeClass("hover")
    }),
    $(".chat03_content li").click(function () {
        $(this).addClass("choosed").siblings().removeClass("choosed")
    }),
    $(".ctb01").mouseover(function () {
        $(".wl_faces_box").show()
    }).mouseout(function () {
        $(".wl_faces_box").hide()
    }),
    $(".wl_faces_box").mouseover(function () {
        $(".wl_faces_box").show()
    }),
	$(".textarea").mouseover(function () {
        $(".wl_faces_box").hide()
		$(".wl_emo_box").hide();
    }),
    $(".wl_faces_close").click(function () {
        $(".wl_faces_box").hide()
    }),
    $(".wl_faces_main img").click(function () {
		var facehtml=$(this).prop('outerHTML');
        $(".textarea").append(facehtml);		
        $(".wl_faces_box").hide();
    }),
	 $(".ctb011").mouseover(function () {
        $(".wl_emo_box").show()
    }).mouseout(function () {
        $(".wl_emo_box").hide()
    }),
    $(".wl_emo_box").mouseover(function () {
        $(".wl_emo_box").show()
    }),
	//onmouseout
	
	$(".wl_emo_main").load("../code/imgchat/emo.html");
	
	
    document.onkeydown = function (a) {
        var b = document.all ? window.event : a;
        return 13 == b.keyCode && b.ctrlKey? ($(".chat02_bar img").click(), !1) : void 0
    },
    $.fn.setCursorPosition = function (a) {
        return 0 == this.lengh ? this : $(this).setSelection(a, a)
    },
    $.fn.setSelection = function (a, b) {
        if (0 == this.lengh)
            return this;
        if (input = this[0], input.createTextRange) {
            var c = input.createTextRange();
            c.collapse(!0),
            c.moveEnd("character", b),
            c.moveStart("character", a),
            c.select()
        } else
            input.setSelectionRange && (input.focus(), input.setSelectionRange(a, b));
        return this
    },
    $.fn.focusEnd = function () {
        this.setCursorPosition(this.val().length)
    }
}), function (a) {
    a.extend({
        blinkTitle: {
            show: function () {
                var a = 0,
                b = document.title;
                if (-1 == document.title.indexOf("\u3010"))
                    var c = setInterval(function () {
                        a++,
                        3 == a && (a = 1),
                        1 == a && (document.title = "\u3010\u3000\u3000\u3000\u3011" + b),
                        2 == a && (document.title = "\u3010\u65b0\u6d88\u606f\u3011" + b)
                    }, 500);
                return [c, b]
            },
            clear: function (a) {
                a && (clearInterval(a[0]), document.title = a[1])
            }
        }
    })
}
(jQuery);
