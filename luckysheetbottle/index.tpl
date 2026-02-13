<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <link rel='stylesheet' href='/static/pluginsCss.css'/>
    <link rel='stylesheet' href='/static/plugins.css'/>
    <link rel='stylesheet' href='/static/luckysheet.css'/>
    <link rel='stylesheet' href='/static/iconfont.css'/>
    <script src="/static/plugin.js"></script>
    <script src="/static/luckysheet.umd.js"></script>
</head>
<body>
<div id="lucky" style="margin:0px;padding:0px;position:absolute;width:100%;height:100%;left: 0px;top: 20px;"></div>
</body>
<script>
options = {
  container: 'lucky',
  title: "在线表格",
  lang: 'zh',
  allowUpdate: true,
  loadUrl: "/load",
  updateUrl: `ws://${document.location.host}/update`,
}
window.luckysheet.create(options);
</script>
</html>