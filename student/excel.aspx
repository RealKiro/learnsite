<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="student_excel, LearnSite" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="UTF-8">
    <title></title>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/pluginsCss.css'/>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/plugins.css'/>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/luckysheet.css'/>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/iconfont.css'/>
    <script type="text/javascript" src="../../Plugins/luckysheet/static/plugin.js"></script>
    <script type="text/javascript" src="../../Plugins/luckysheet/static/luckysheet.umd.js"></script>
    <script type="text/javascript" src="../../Plugins/luckysheet/static/luckyexcel.umd.js"></script>
	<style>
		.save{
            position: absolute;
            z-index: 999;
            top: 13px;
			margin: 2px;
			float: right;
			right:360px;
		}
		.returnurl{
            position: absolute;
            z-index: 999;
            top: 13px;
			margin: 2px;
			float: right;
			right:240px;
		}

	</style>
</head>
<body> 
<button  onclick="save()" class="save"  > 立即保存</button> 
<button  onclick="returnurl()" class="returnurl"  > 返回学案</button> 
<div id="lucky" style="margin:0px;padding:0px;position:absolute;width:100%;height:100%;left: 0px;top: 0px; font-size:16px;"></div>
</body>

<script type="text/javascript">

	var port=":8180";//端口
	var str=location.host+port;//location.host;192.168.1.3
	console.log(str);
	var lor=location.origin+port;// location.origin;http://192.168.1.3
	console.log(lor);

    var title="";//"<%=Titles%>";
	var reurl="<%=Fpage %>";
	var user="<%=Owner%>";
    var serverip = "<%=serverIp %>";
    if (serverip != "") {
        str = serverip+port;
        lor = "http://"+serverip+port;
    }

    options = {
	    userInfo:user,
	    container: 'lucky',
	    title: title,
	    lang: 'zh',
	    plugins:['chart'],
	    showsheetbar:false,
	    myFolderUrl:"#",
		allowUpdate: true,
		loadUrl: lor+"/load",
		updateUrl: "ws://" + str + "/update?name="+user
    }
    //window.luckysheet.create(options);

    function returnurl() {
        window.location.href = "<%=Fpage %>";    
    }

    function save(){
	    console.log("保存信息");
		window.luckysheet.exitEditMode();
	    var excel = window.luckysheet.toJson(); 
        //console.log("保存",excel); 
		console.log("在线保存！"); 

        var id = "<%=Id %>";
        var urls = 'uploadexcel.ashx?id=' + id;
        var formData = new FormData();
        excel = JSON.stringify(excel);//将json对象转换成json对符串
        excel = encodeURIComponent(excel);//url编码
		
        formData.append('title', title);
        formData.append('excel', excel);

        $.ajax({
            url: urls,
            type: 'POST',
            cache: false,
            data: formData,
            processData: false,
            contentType: false
        }).done(function (res) {
            alert("保存成功！");
            //console.log(res)
        }).fail(function (res) {
            alert("保存失败！");
            //console.log(res)
        });
    }
    /*
    导出的json字符串可以直接当作`luckysheet.create(options)`初始化工作簿时的参数`options`使用，
    使用场景在用户自己操作表格后想要手动保存全部的参数，再去别处初始化这个表格使用，类似一个luckysheet专有格式的导入导出
  
*/  

   window.onload = function () {
        var codefile = "<%=codefile %>";
        var example="<%=Exampleurl %>";	
		var xhr = new XMLHttpRequest();
		var liveurl=location.origin+port+"/islive";
		xhr.open("GET", liveurl, true);
		xhr.onreadystatechange = function() {
			var response = xhr.responseText;
			if (xhr.readyState === 4 && xhr.status === 200) {
				// 在这里处理返回的数据
				if(response){			
					options['allowUpdate']=true;
					options['loadUrl']=lor+"/load",
					options['updateUrl']= "ws://" + str + "/update?name="+user			
					
					window.luckysheet.create(options);
					console.log("在线协作正常");
				}
			}
			else{
				if (codefile != "") {
					//console.log("读取",codefile);
					codefile = decodeURIComponent(codefile);
					codefile=JSON.parse(codefile);//将json字符串转换成json对象 
					//console.log("读取",codefile);
					window.luckysheet.create(codefile);
					console.log("读取存档！");
				}
				else{
					if(example!=""){                
						loadHandler(example);
						console.log("读取实例");
					}  
				}
			}
		};
		xhr.send();	


		function loadHandler(url) {
			//url = "demo.xlsx"; //文件链接"demo.xlsx"
			var name = ""; //文件名
			if (url == "") {
				return;
			}
			LuckyExcel.transformExcelToLuckyByUrl(url, name, function (exportJson, luckysheetfile) {

				if (exportJson.sheets == null || exportJson.sheets.length == 0) {
					alert("只支持xlsx格式文档!");
					return;
				}
				//console.log(exportJson, luckysheetfile);
				//window.luckysheet.destroy();
				
				options['data']=exportJson.sheets;
				window.luckysheet.create(options);
			});

		}
	
	}
</script>
</html>