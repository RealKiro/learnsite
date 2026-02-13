<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="student_kitymind, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    	<meta charset=utf-8>
	<!-- bower:css -->
	<link rel="stylesheet" href="../../Plugins/km/bower_components/bootstrap/dist/css/bootstrap.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/codemirror/lib/codemirror.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/hotbox/hotbox.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/kityminder-core/dist/kityminder.core.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/color-picker/dist/color-picker.min.css" />
	<!-- endbower -->

	<link rel="stylesheet" href="../../Plugins/km/kityminder.editor.css">
		<style>
		div.minder-editor-container {
			top: 0px;
		}
		.export{
            position: absolute;
            z-index: 999;
            top: 0px;
			height: 30px;
			line-height: 30px;
			margin: 2px;
			float: right;
			right:160px;
			color: #333;
			overflow: hidden;
			position: relative;
			cursor:pointer;
		}
		.return{
            position: absolute;
            z-index: 999;
            top: 0px;
			height: 30px;
			line-height: 30px;
			margin: 2px;
			float: right;
			right:30px;
			color: #333;
			overflow: hidden;
			position: relative;
			cursor:pointer;
		}
	</style>
</head>

<body ng-app="kityminderDemo" >
    <form id="form1" runat="server">
       <div id="mcontext" style="display: none; background: #fffdea; overflow-y: auto; overflow-x: hidden;
            position: absolute;  width: 500px; height: 50%; z-index: 999;opacity:0.9; font-size: 16px;
            right: 0px; bottom: 0px; padding: 2px;">
            <div style="margin:10px; ">
            <h4><%=Titles%></h4>
            <%=Mcontents %>
            </div>
        </div>
    </form>
<div>
<a class="export" href="#" onclick="return downfile(this);">
   保存
</a>
<a class="return" href="#" onclick="returnurl();">
   返回
</a>
</div>
<kityminder-editor on-init="initEditor(editor, minder)" data-theme="fresh-green"></kityminder-editor>

<!-- bower:js -->
<script src="../../Plugins/km/bower_components/jquery/dist/jquery.js"></script>
<script src="../../Plugins/km/bower_components/bootstrap/dist/js/bootstrap.js"></script>
<script src="../../Plugins/km/bower_components/angular/angular.js"></script>
<script src="../../Plugins/km/bower_components/angular-bootstrap/ui-bootstrap-tpls.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/lib/codemirror.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/xml/xml.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/javascript/javascript.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/css/css.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/htmlmixed/htmlmixed.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/markdown/markdown.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/addon/mode/overlay.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/gfm/gfm.js"></script>
<script src="../../Plugins/km/bower_components/angular-ui-codemirror/ui-codemirror.js"></script>
<script src="../../Plugins/km/bower_components/marked/lib/marked.js"></script>
<script src="../../Plugins/km/bower_components/kity/dist/kity.min.js"></script>
<script src="../../Plugins/km/bower_components/hotbox/hotbox.js"></script>
<script src="../../Plugins/km/bower_components/json-diff/json-diff.js"></script>
<script src="../../Plugins/km/bower_components/kityminder-core/dist/kityminder.core.min.js"></script>
<script src="../../Plugins/km/bower_components/color-picker/dist/color-picker.min.js"></script>
<!-- endbower -->

<script src="../../Plugins/km/kityminder.editor.js"></script>
<script >
    window.onload = function () {
        var codefile = "<%=codefile %>";
        if (codefile != "") {
            codefile = decodeURIComponent(codefile);
            console.log(codefile);
            var fileType = 'json'
            editor.minder.importData(fileType, codefile).then(function (data) {
                console.log(data)
            });
        }
    }
    var fpage = "<%=Fpage %>";
    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            window.location.href = "<%=Fpage %>"
        }
    }
    //点击导出链接自动下载
    function downfile(link) {
        var title = editor.minder.getRoot().getData("text");
        exportType = 'json';
        console.log("保存信息");

        var content = editor.minder.exportData(exportType);
        var strJson = content.fulfillValue;

        exportType = 'png';
        editor.minder.exportData(exportType).then(function (content) {
            var blob = new Blob();
            blob = dataURLtoBlob(content); //将base64编码转换为blob对象

            var id = "<%=Id %>";
            var urls = 'uploadkitymind.ashx?id=' + id;
            var formData = new FormData();
            //console.log("编码信息");
            var km = encodeURIComponent(strJson);

            formData.append('title', title);
            formData.append('km', km);
            formData.append('thumb', blob);
            //console.log(km);
            //console.log(blob);

            $.ajax({
                url: urls,
                type: 'POST',
                cache: false,
                data: formData,
                processData: false,
                contentType: false
            }).done(function (res) {
                alert("保存成功！");
                $(".export").attr("disabled", "false");
                console.log(res)
            }).fail(function (res) {
                alert("保存失败！");
                console.log(res)
            });

        });
    }

    //base64转换为图片blob
    function dataURLtoBlob(dataurl) {
        var arr = dataurl.split(',');
        //注意base64的最后面中括号和引号是不转译的
        var _arr = arr[1].substring(0, arr[1].length - 2);
        var mime = arr[0].match(/:(.*?);/)[1],
    bstr = atob(_arr),
    n = bstr.length,
    u8arr = new Uint8Array(n);
        while (n--) {
            u8arr[n] = bstr.charCodeAt(n);
        }
        return new Blob([u8arr], {
            type: mime
        });
    }

</script>

<script>
    angular.module('kityminderDemo', ['kityminderEditor'])
	.controller('MainController', function ($scope) {
	    $scope.initEditor = function (editor, minder) {
	        window.editor = editor;
	        window.minder = minder;
	    };
	});
</script>


</body>
</html>
