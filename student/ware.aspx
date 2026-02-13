<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_ware, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" runat="Server">
    <div class="left">
        <div id="previewArea">
            <iframe id="wareframe" src="<%=WareUrl %>" style="width:100%;min-height:80vh; border: none;"></iframe>
        </div>
    </div>
    <div class="right">
        <center>
            <asp:Image ID="Thumbnail" runat="server"  style=" max-width:240px; "/>
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <input id="Btnform" type="button" value="保存" onclick="SaveIframe();" />
            <br />
            <div id="msg" style="color: #FF0000">
            </div>
            <br />
            <br />
            <br />
            <br />
        </center>
    </div>
    <br />

<script src="../code/html2canvas.min.js" type="text/javascript"></script>
<script type="text/javascript">
	var id = "<%=Id %>";
	var wareframe = document.getElementById("wareframe");
	var msg = document.getElementById("msg");
    var quiztitle="";
    var quizvalue=0;

    function setIframeHeight(iframe) {
        if (iframe) {
            var iframeWin = iframe.contentWindow || iframe.contentDocument.parentWindow;
            if (iframeWin.document.body) {
                iframe.height = iframeWin.document.documentElement.scrollHeight || iframeWin.document.body.scrollHeight;
            }
        }
    };
 
    window.onload = function () {
        setIframeHeight(document.getElementById('wareframe'));
    };

    function SaveIframe() { 
        var htmlcode ="";// 使用缩略图预览
        var iframeContent = wareframe.contentDocument || wareframe.contentWindow.document;
		html2canvas(iframeContent.body, {
                        allowTaint: false,
                        useCORS: true,
                        scale: 1,
                        logging: false
                    }).then(pic => {					
			var urls = '../student/uploadtopic.ashx?id=' + id;
			var title = "";
			var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			var Content = htmlcode;
			var Extension = "ware";
			var formData = new FormData();
			formData.append('title', title);
			formData.append('cover', Cover);
			formData.append('content', Content);
			formData.append('ext', Extension);
			formData.append('score', quizvalue);

			$.ajax({
				url: urls,
				type: 'POST',
				cache: false,
				data: formData,
				processData: false,
				contentType: false
			}).done(function (res) {
                var message = "保存成功！  "+quiztitle+" ："+quizvalue;
				alert(message);
                location.reload();

			}).fail(function (res) {
				console.log(res)
			}); 	
		
		});	
    }
                
    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            window.location.href = courseurl;
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

    //从iframe中的页面向父页面传递数据
    window.addEventListener("message", receiveMessage, false);
    function receiveMessage(event) {
        var data = JSON.parse(event.data);
        quiztitle = data.name;
        quizvalue = data.value;
        //console.log("接收到的数据：", data);
    }

    /*
    // 假设你想发送一个消息
    const message = { name: "示例", value: "数据" };
    // 向父页面发送消息
    window.parent.postMessage(JSON.stringify(message), "*");
    */

</script>
</asp:Content>
