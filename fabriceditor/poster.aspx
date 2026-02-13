<%@ page language="C#" autoeventwireup="true" inherits="fabriceditor_poster, LearnSite" %>
<!doctype html>
<html lang="en" style="overflow: hidden">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="renderer" content="webkit" />
    <meta name="force-rendering" content="webkit" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <link rel="icon" href="/fabriceditor/favicon.ico" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>在线图形设计 </title>
    <style>
        ::-webkit-scrollbar
        {
            width: 6px;
            height: 6px;
        }
        ::-webkit-scrollbar-thumb
        {
            border-radius: 8px;
            background: rgba(0,0,0,.2);
        }
        ::-webkit-scrollbar-track
        {
            border-radius: 0;
            background: rgba(0,0,0,.1);
        }
    </style>
    <script type="module" crossorigin src="/fabriceditor/js/index.js"></script>
    <link rel="stylesheet" href="/fabriceditor/assets/index-b3d4c966.css">
</head>
<body>
    <form id="form2" runat="server">
    <div id="app">
    </div>
    <div id="posterId" style="display:none;"></div>
    </form>
</body>
<script type="text/javascript" >
    var id = "<%=Id %>";
    var key = "poster" + id;
    var wurl = "<%=Wurl %>";
    function returnurl() {
        if (confirm('确定要返回吗，记得先保存。') == true) {
            window.location.href = "<%=Fpage %>"
        }
    }
    function showwork() {
        var value = localStorage.getItem(key);
        if (value != null) {
            editor.read(value);
            console.log("读取缓存");
        }
        else {
            if (wurl != "") {
                //console.log(wurl);
                editor.read(wurl);
                console.log("恢复文档");
            }
            else {
                console.log("新建文档");
            }
        }
    }
    document.getElementById("posterId").innerText = id;
    setTimeout(showwork, 1000); //延迟执行加载文档

    // 保存到本地存储的函数
    function saveToLocalStorage(key, value) {
        localStorage.setItem(key, value);
        console.log("自动缓存");
    }

</script>
</html>
