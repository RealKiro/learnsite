<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="Student_pixel, LearnSite" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <title>Pixel Art Maker 像素艺术画</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <link rel="stylesheet" href="../pixelartmaker/style.css"/>  
</head>
<body>

<div id="main">
  <div id="pick">
	  <div class="left">  
		<img id="logo" src="../pixelartmaker/logo.png"  alt="像素蘑菇小兵！"/>  
	  </div>
	  <div class="right">
		<h1 > 
		Pixel Art Maker 像素画 <input type="color" id="colorPicker"/>&nbsp;&nbsp;&nbsp;&nbsp;	
		<button id="savebtn"  class="savetext" >保存</button>&nbsp;	&nbsp;&nbsp;
		<button id="playbtn"  class="savetext" >播放</button>&nbsp;	&nbsp;&nbsp;
		<button id="returnbtn"  class="savetext" >返回</button>
		 </h1>
			<table id="palette"></table> 		 
	  </div>
  </div>
<div id="petcolor" >
	<table id="paletteB"></table>
</div>
 
<table id="pixel_canvas"></table>

<div id="framelist">
	<div id="frameadd" >
		<div id="plus" title="复制当前帧">+</div>
		<div id="minus" title="删除当前帧">-</div>
	</div>
		<div id="fm1" class="frame"></div>
</div>
</div>

<audio id="myaudio" src="../pixelartmaker/music.mp3" autoplay="autoplay" hidden="true" ></audio>	

<script type="text/javascript" >
    var id = "<%=Id %>";
    var pixfile = "<%=PixFile %>";

    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            window.location.href = "<%=Fpage %>"
        }
    }
</script>
<script src='../pixelartmaker/lz-string-1.4.4.js' type="text/javascript" ></script>
<script src='../pixelartmaker/jquery.min.js' type="text/javascript" ></script>
<script src='../pixelartmaker/jquery-ui.js' type="text/javascript" ></script>
<script src="../pixelartmaker/html2canvas.min.js" type="text/javascript" ></script>
<script src="../pixelartmaker/pixelartmaker.js" type="text/javascript" ></script>
<script src='../pixelartmaker/gif.js' type="text/javascript" ></script>
<script src='../pixelartmaker/gif.worker.js' type="text/javascript" ></script>
</body>
</html>

