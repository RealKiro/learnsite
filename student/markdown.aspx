<%@ page language="C#" autoeventwireup="true" inherits="student_markdown, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head runat="server">
        <meta charset="utf-8" />
        <title>Markdown写作</title>
        <link rel="stylesheet" href="../markdown/css/editormd.css" />
        <link rel="shortcut icon" href="../markdown/favicon.ico" type="image/x-icon" />
    </head>
    <body>
        <div id="layout">
            <div style="display:flex;padding-bottom:6px;">
				<img src="../markdown/favicon.png" />
				<div id="mdTitle" contenteditable="true"><%=Mytitle%></div>
				<button style="margin-left: auto;width:60px;" onclick="savemd()" title="保存写作">保存</button>
				<button style="margin-left:20px;width:60px;" onclick="returnurl()" title="返回学案">返回</button>
            </div>
			<div >
				<div id="editormd" >
					<textarea style="display:none;"><%=codefile %></textarea>
				</div>
			</div>
        </div>
        <script src="../js/jquery.min.js"></script>
        <script src="../code/html2canvas.min.js" type="text/javascript"></script>
        <script src="../markdown/editormd.js"></script>
<script type="text/javascript">
    var mdEditor;

    $(function () {
        mdEditor = editormd("editormd", {
            height: 640,
            syncScrolling: "single",
            path: "../markdown/lib/",
            toolbarIcons: "me",
            table: true,
			imageUpload: true, // 开启图片上传功能
			imageFormats: ["jpg", "jpeg", "gif", "png", "bmp", "webp"], // 允许上传的图片格式
			imageUploadURL: "uploadmd.ashx", // 图片上传接口的 URL
			onload: function () {
				console.log('编辑器准备就绪.');
			}
        });
    });

//---------------------------------------------------------------------------//
	var docurl = document.URL;
    var ipurl = docurl.substring(0, docurl.lastIndexOf("/"));
    var id = "<%=Id %>";
    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            window.location.href = "<%=Fpage %>"
        }
    }

    function savemd() { 
	    var preview = document.getElementById("md-preview");
	    var mdTitle = document.getElementById("mdTitle");
        // 获取 Markdown 内容       
        var htmlcode =mdEditor.getMarkdown(); // 使用缩略图预览 mdTitle
        // 获取 HTML 内容
        //var htmlContent = mdEditor.getHTML();
        if (htmlcode) {
            html2canvas(preview).then(pic => {					
        	    var urls = '../student/uploadtopic.ashx?id=' + id;
			    var title = mdTitle.innerText;
			    var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			    var Content = htmlcode;
			    var Extension = "markdown";
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
        else{
            alert("请先写作，才可以保存！");
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
