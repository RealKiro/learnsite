<%@ page language="C#" autoeventwireup="true" inherits="deepseek_tic_tac_toe, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head runat="server">
	<title>井字棋</title>
	<style>
	.descript{
		margin:auto;padding:10px;width:900px; line-height:1.5;
	}
	#footbar{
		margin:auto;
		padding: 10px;
		text-align:center;
		//box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
	  background: #3D89DA;
	}
	</style>
	<script type="text/javascript" src="tic-tac-toe.js"></script>
    <script src="../code/jquery.min.js" type="text/javascript"></script>
</head>
<body>						
            <div id="footbar">
				<button  type = "button" onclick="savechat()" class="buttonsave"  title="保存到服务器上" >
				<i class="fa fa-save" aria-hidden="true"></i> 保存</button>
				<span class="sp"></span>
				<button  onclick="returnurl()" class="button" title="返回到学案页面">
				<i class="fa fa-reply" aria-hidden="true"></i> 返回</button>            
            </div>
		<div class="descript">
		<strong>❖ 井字棋</strong>：英文名叫Tic-Tac-Toe，是一种在3*3格子上进行的连珠游戏，和五子棋类似，由于棋盘一般不画边框，格线排成井字故得名。游戏需要的工具仅为纸和笔，然后由分别代表O和X的两个游戏者轮流在格子里留下标记（一般来说先手者为X），任意三个标记形成一条直线，则为获胜。
		<br>		
		<strong>❖ 历史</strong>：在三排棋盘上玩的游戏可以追溯到古埃及，在公元前1300年左右的屋瓦上发现了这种游戏板。井字游戏的早期变化是在公元前一世纪左右的罗马帝国开始流行,早期的名字为Terni Lapilli。
		<br>
		<strong>❖ 人工智能</strong>：这种游戏的变化简单，常成为博弈论和游戏树搜寻的教学例子。这个游戏只有765个可能局面，26830个棋局。如果将对称的棋局视作不同，则有255168个棋局。由于这种游戏的结构简单，早期这游戏就成为了人工智能的一个好题目。学生都要从既有的玩法中，归纳出游戏的致胜之道，并将策略演绎成为程序，让电脑与用户对弈。1950年制作的游戏《Bertie the Brain》是早期电子游戏史最初的游戏之一，该游戏便是和人工智能对弈井字棋。
世界上最早的电脑游戏之一，1952年为EDSAC电脑制作的《OXO》游戏，就是以该游戏为题材，可以正确无误地与人类对手下棋。
		</div>
		<div id="mylegend" style="margin-left:35%;">加载中……</div>
</body>
</html>

<script type="text/javascript">

    var mywin = 0;
    var docurl = document.URL;
    var ipurl = docurl.substring(0, docurl.lastIndexOf("/"));
    var id = "<%=Id %>";
    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            window.location.href = "<%=Fpage %>"
        }
    }

    function savechat() {
        var preview = document.getElementById("mylegend_canvas");
        var htmlcode = ""; // preview.innerHTML;使用缩略图预览
        if (mywin > 0) {
            var urls = '../student/uploadtopic.ashx?id=' + id;
            var title = "";
            var Cover = blob(preview.toDataURL("image/jpg", 0.5));
            var Content = htmlcode;
            var Extension = "tic-tac-toe";
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

        }
        else {
            alert("至少要平手，才能保存！");
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