<%@ page language="C#" autoeventwireup="true" inherits="student_iframe, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="zh-CN">
<head id="Head1" runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI图片处理</title>
    <link rel="stylesheet" href="../deepseek/all.min.css">
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../Plupload/plupload.full.min.js" type="text/javascript"></script>
	<style>
	#footbar{
		padding: 10px;
		text-align:center;
		min-width:800px;
	}

	#footbar button {
	  padding: 8px 16px;
	  background: #3371B2;
	  color: white;
	  border: none;
	  border-radius: 4px;
	  cursor: pointer;
	  transition: background 0.3s;
	  margin-left:30px;
	}

	#footbar button:hover {
	  background: #3D9AFD;
	}
	.sp{
		display: inline-block;
		width:100px;
	}
	#homeframe{
		min-width:1280px;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);		
		border: 0px solid #eee;
		padding:20px;
	}
	#Mcontents{
		text-align:left;
		min-width:1280px;
		width:90%;
		margin:auto;
		padding:20px;
		min-height:50px;
	}
	
	</style>
</head>
<body>				
	<div id="footbar">
	
		<button onclick="homeland()"><i class="fa fa-home" aria-hidden="true" /></i> 首页</button>
		<button onclick="backward()"><i class="fa fa-arrow-left" aria-hidden="true" /></i> 后退</button>
		<button onclick="forward()"><i class="fa fa-arrow-right" aria-hidden="true" /></i> 前进</button>		
		<span class="sp">             </span>
		<button id="savebtn" type = "button" class="button"  title="将PSD格式图片上传到服务器上" >
		<i class="fa fa-upload" aria-hidden="true"></i> 提交作品</button>
		<button  onclick="returnurl()" class="button" title="返回到学案页面">
		<i class="fa fa-reply" aria-hidden="true"></i> 返回</button>  
		
	</div>	
    <div >		
		<div id="chatHistory" style="text-align:center;">
		<iframe id="homeframe"  width="90%" height="700" >
		  您的浏览器不支持iframe。 sandbox="allow-scripts allow-same-origin allow-forms allow-popups" 
		</iframe>			
		</div>
	</div>
    <script type="text/javascript" >
		var id = "<%=Id %>";
		var courseurl = "<%=Fpage %>";
		var homeurl= "<%=Mexample %>"; 

		var homeframe = document.getElementById("homeframe");		
		homeland();
		
		function homeland(){
			homeframe.src=homeurl;
			//console.log("首页",homeurl);			
		}
		function backward(){
			window.history.back();
			console.log("后退");			
		}
		function forward(){
			window.history.forward();
			console.log("前进");			
		}	
        var docurl = document.URL;
		var ipurl = docurl.substring(0, docurl.lastIndexOf("/"));
		
        function returnurl() {
            if (confirm('是否要离开此页面？') == true) {
                window.location.href = courseurl;
            }
        }

        // 上传图片
        var isup = false;
        var urlstr = "uploadworkm.aspx?lid=" + "<%=Lid %>";
        var uploader = new plupload.Uploader({
            runtimes: 'html5,html4',
            browse_button: 'savebtn', // you can pass an id...
            url: urlstr,
            multi_selection: false,
            filters: {
                max_file_size: '60mb',
                mime_types: [
			        { title: "work files", extensions: "<%=Ext %>" }
		        ]
            },
            init: {
                FilesAdded: function (up, files) {
                    uploader.start();
                },
                UploadProgress: function (up, file) {
                    if (file.percent == 100 && !isup) {
                        isup = true;
                    }
                },
                UploadComplete: function (up, file) {
                    alert("作品已经提交成功！");
                }
            }
        });

        uploader.init();
</script>
</body>
</html>

