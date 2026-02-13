<%@ page language="C#" autoeventwireup="true" inherits="student_draw, LearnSite" %>

<html lang="zh-cn">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title>在线画布 Excalidraw</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover,shrink-to-fit=no" />
    <meta name="referrer" content="origin" />
    <meta name="mobile-web-app-capable" content="yes" />
    <meta name="theme-color" content="#121212" />
    <script type="text/javascript" > 
    try {
        function setTheme(theme) {
          if (theme === "dark") {
            document.documentElement.classList.add("dark");
          } else {
            document.documentElement.classList.remove("dark");
          }
        }

        function getTheme() {
          const theme = window.localStorage.getItem("excalidraw-theme");

          if (theme && theme === "system") {
            return window.matchMedia("(prefers-color-scheme: dark)").matches
              ? "dark"
              : "light";
          } else {
            return theme || "light";
          }
        }

        setTheme(getTheme());
      } catch (e) {
        console.error("Error setting dark mode", e);
      }</script>
      
    <style>
        html.dark
        {
            background-color: #121212;
            color: #fff;
        }
    </style>
    <link rel="preload" href="../../Plugins/Excalidraw/assets/Muyao.ttf" as="font" type="font/ttf" crossorigin="anonymous" />
    <link rel="icon" type="image/png" sizes="32x32" href="../../Plugins/Excalidraw/favicon-32x32.png" />
    <link rel="icon" type="image/png" sizes="16x16" href="../../Plugins/Excalidraw/favicon-16x16.png" />
    <meta name="version" content="2024-10-17T10:46:07.618Z-none" />
    <script>        // setting this so that libraries installation reuses this window tab.
        window.name = "_excalidraw";</script>
    <style>
        body, html
        {
            margin: 0;
            -webkit-text-size-adjust: 100%;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        .visually-hidden
        {
            position: absolute !important;
            height: 1px;
            width: 1px;
            overflow: hidden;
            clip: rect(1px,1px,1px,1px);
            white-space: nowrap;
            user-select: none;
        }
        #root
        {
            height: 100%;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            -khtml-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }
        @media screen and (min-width:1200px)
        {
            #root
            {
                -webkit-touch-callout: default;
                -webkit-user-select: auto;
                -khtml-user-select: auto;
                -moz-user-select: auto;
                -ms-user-select: auto;
                user-select: auto;
            }
        }
		.mybtn {
			position:absolute; width:60px;right:20px;top:20px; z-index:1000;
		}
    </style>
  <script type="module" crossorigin src="../Plugins/excalidraw/assets/index-DMdoekNJ.js"></script>
    <link rel="stylesheet" crossorigin href="../Plugins/excalidraw/assets/index.css">
    <link rel="manifest" href="../Plugins/excalidraw/manifest.webmanifest">
    <script src="../code/jquery.min.js"></script>
</head>
<body>
    <div>
    <button class="mybtn" style="right:120px;" onclick="savework();" >保存</button>&nbsp;
    <button class="mybtn" style="right:20px;" onclick="returnurl();" >返回</button>
    </div>
    <div id="drawUrl" class="hide"><%=Wurl %></div>
    <div id="root">
    </div>
<script type="text/javascript" >    

var id = "<%=Id %>";

function returnurl() {
    if (confirm('是否要离开此页面？') == true) {
        window.location.href = "<%=Fpage %>"
    }
}
async function savework() {
    var title = "";
    var Cover = await getmyPng();
	var jsonstr =  await getmyJson();  
    var Content = window.btoa(encodeURIComponent(jsonstr));
    var Extension = "excalidraw";
    var urls = 'uploadtopic.ashx?id=' + id;
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
        console.log(res)
    });
}
      
</script>
</body>
</html>
