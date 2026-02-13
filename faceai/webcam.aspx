<%@ page language="C#" autoeventwireup="true" inherits="faceai_webcam, LearnSite" %>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <link rel="stylesheet" href="../faceai/index.css">
  <link rel="stylesheet" href="../../machine/font-awesome.css">
</head>

<body>
  <div class="main">
    <div class="container">
      <h1 id="hc">➀ <a href="face.aspx?lid=<%=Lid %>">人脸识别探秘</a></h1>
      <h1 id="hd"> → ➁ <a href="meme.aspx?lid=<%=Lid %>">魔法表情包</a></h1>
      <h1 id="he"> → ➂ <a href="webcam.aspx?lid=<%=Lid %>">扫脸应用</a></h1>
      <h1 id="hf"> →  <a href="../student/program.aspx?lid=<%=Lid %>">返回</a></h1>
    </div>
    
	  <input type="file" id="image-input" multiple class="fileinput"/>	
    <input type="file" id="image-obj" class="fileinput"/>
    <div class="container">
        <div class="facestore">
          <div class="category">
            <span class="counter" id="collector">人脸仓库照片: 0张</span>
            <button class="dataCollector" ><i class="fa fa-camera"></i>采集照片</button>
            <button class="dataup" data-up="0"><i class="fa fa-picture-o" aria-hidden="true" ></i>上传照片</button>
          </div>
          <div id="output" class="outpic"></div>
      </div>
          <div class="facevideo">
              <div class="status">
                <i id="upimg" class="fa fa-picture-o" aria-hidden="true" title="上传照片"  style="display: none;"></i>
                <span id="status"> 请把脸移入框内</span>
                <i id="switch" class="" aria-hidden="true" ></i>
                <span class="videoicon"><i id="enable-voice" class="fa fa-volume-off" aria-hidden="true"  title="语音播报" ></i></span>
              </div>
              <div style="position: relative;">                
                <video  id="webcam-container" autoplay muted></video>                          
                <canvas id="overlay" class="overlay" /> 
              </div>
              <div class="center">
                <button class="start-btn" style="display: none;" onclick="faceDetector()">人脸扫描</button>
                <span id="pass">&nbsp; </span>
              </div>
          </div>          

    </div>

  </div>

  <script type="text/javascript" src="../faceai/jquery.min.js"></script>
  <script type="text/javascript" src="../faceai/face-api.js"></script>
  <script type="text/javascript" src="../faceai/webcam.js"></script>
</body>

</html>
