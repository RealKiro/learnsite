<%@ page language="C#" autoeventwireup="true" inherits="student_pptist, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="zh-CN">
	<head id="Head1" runat="server">
    <meta charset="UTF-8">
    <link rel="icon" href="../../Plugins/pptist/favicon.ico">        
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta name="renderer" content="webkit">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PPTist - 在线演示文稿</title>

    <style>
      .first-screen-loading {
        width: 200px;
        height: 200px;
        position: fixed;
        top: 50%;
        left: 50%;
        margin-top: -100px;
        margin-left: -100px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
      }
      .first-screen-loading-spinner {
        width: 36px;
        height: 36px;
        border: 3px solid #d14424;
        border-top-color: transparent;
        border-radius: 50%;
        animation: spinner .8s linear infinite;
      }
      .first-screen-loading-text {
        margin-top: 20px;
        color: #d14424;
      }
      @keyframes spinner {
        0% {
          transform: rotate(0deg);
        }
        100% {
          transform: rotate(360deg);
        }
      }
      .hide {
        display: none;
      }
    </style>
  </head>
  <body>
      <div id="pptId" class="hide"><%=Id %></div>
      <div id="pptUrl" class="hide"><%=Ppturl %></div>
      <div id="stuNum" class="hide"><%=Snum %></div>
    <div id="app">
      <div class="first-screen-loading">
        <div class="first-screen-loading-spinner"></div>
        <div class="first-screen-loading-text">正在加载中，请稍等 ...</div>
      </div>
    </div>
  </body>

    <script type="module" crossorigin src="../../Plugins/pptist/assets/index.js"></script>
    <link rel="stylesheet" crossorigin href="../../Plugins/pptist/assets/index.css">
<script type="text/javascript" >
    function returnurl() {
        window.location.href = "<%=Fpage %>"
    }
</script>

</html>