<%@ page language="C#" autoeventwireup="true" inherits="faceai_meme, LearnSite" %>

<!DOCTYPE html>
<html lang="en">

<head id="Head1" runat="server">
  <meta charset="UTF-8" />
  <script type="application/x-javascript" src="../faceai/face-api.js"></script>
  <link rel="stylesheet" href="../faceai/index.css">
</head>
<script type="text/javascript" >
    var id = "<%=Id %>";
</script>
<body>
  <div class="main">
    <div class="container">
      <h1 id="hc">➀ <a href="face.aspx?lid=<%=Lid %>">人脸识别探秘</a></h1>
      <h1 id="hd"> → ➁ <a href="meme.aspx?lid=<%=Lid %>">魔法表情包</a></h1>
      <h1 id="he"> → ➂ <a href="webcam.aspx?lid=<%=Lid %>">扫脸应用</a></h1>
    </div>
  <input id="uploadimg" type="file" accept="image/*" >
  <div class="container">
    <div class="left">
        <img class="upimgIcon"  src="upimg.png" title="图片上传"/>
    </div>
    <div class="right">       
    </div>
  </div>
    <div class="container">
      <div id="facediv" class="left">
        <img id="faceimg" class="faceimg" src="images/fame/1.jpg" />
        <canvas id="overlay" class="overlay" />
        
      </div>
      <div class="right">
        <div style="display: flex;">
            <div class="half">
                <img class="cartoon" src="images/cartoon/p1.png" />
                <img class="cartoon"  src="images/cartoon/p2.png" />
                <img class="cartoon"  src="images/cartoon/p3.png" />
                <img class="cartoon"  src="images/cartoon/p4.png" />
                <img class="cartoon"  src="images/cartoon/p5.png" />
                <img class="cartoon"  src="images/cartoon/p6.png" />
                <img class="cartoon"  src="images/cartoon/p7.png" />
                <img class="cartoon"  src="images/cartoon/p8.png" />
                <img class="cartoon"  src="images/cartoon/p9.png" />
            </div>
            <div class="half">
                <img class="cartoon" src="images/cartoon/h1.png" />
                <img class="cartoon"  src="images/cartoon/h2.png" />
                <img class="cartoon"  src="images/cartoon/h3.png" />
                <img class="cartoon"  src="images/cartoon/e5.png" />
                <img class="cartoon"  src="images/cartoon/m6.png" />
                <img class="cartoon" src="images/cartoon/l1.png" />
                <img class="cartoon" src="images/cartoon/x1.png" />
            </div>
            <div class="half">
                <div id="landmarks" title="68个特征点坐标(x,y)"></div>
                <button class="start-btn" onclick="faceDetector()">人脸检测</button>
                <button class="save-btn" onclick="faceSave()">保存表情</button>
            </div>
        </div>
        <div>          
        </div>
      </div>
    </div>

  </div>
  <div id="test"></div>

  <script type="text/javascript"  src="../faceai/jquery.min.js"></script>
  <script type="text/javascript"  src="../faceai/meme.js"></script>
</body>

</html>
