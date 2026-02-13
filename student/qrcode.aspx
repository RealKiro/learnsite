<%@ page language="C#" autoeventwireup="true" inherits="student_qrcode, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head id="Head1"  runat="server">
<meta charset="UTF-8">
<title>二维码生成器</title>
<link rel="stylesheet" href="../plugins/qrcode/spectre.min.css">
<link rel="stylesheet" href="../plugins/qrcode/style.css">
<script src="../plugins/qrcode/vue.min.js"></script>
<script src="../plugins/qrcode/qrcanvas@3"></script>
<script src="../plugins/qrcode/jsQR.js"></script>
<script src="../code/jquery.min.js"></script>
</head>
<body>
<div id="app" class="container" style="display:none" v-show="true">
  <div class="mt-2">
  <br>
  </div>
  <div class="columns">
    <div class="form-horizontal">
    <h1 style="text-align:center;">二维码生成器</h1>
	<br>
      <div class="form-group">
        <div class="column col-3">
          <div class="form-label ">内容:</div>
        </div>
        <div class="column">
          <textarea id="inputText" class="form-input " v-model="settings.qrtext"></textarea>
        </div>
      </div>
      <div class="form-group">
        <div class="column col-3">
          <div class="form-label ">颜色:</div>
        </div>
        <div class="column">
          <div class="text-right">
            <button class="btn btn-link btn-sm mr-1" v-for="theme in themes" v-text="theme" @click.prevent="loadTheme(theme)"></button>
          </div>
        </div>
      </div>
	  <br>
      <div class="form-group">
        <div class="column col-4">
          <label class="form-checkbox ">
            <input type="checkbox" v-model="settings.logo">
            <i class="form-icon"></i>
            徽标
          </label>
        </div>
        <ul class="tab column" v-show="settings.logo">
          <li class="tab-item" :class="{ active: settings.logoType === 'image' }">
            <a href="#" @click.prevent="settings.logoType = 'image'">图片</a>
          </li>
          <li class="tab-item" :class="{ active: settings.logoType === 'text' }">
            <a href="#" @click.prevent="settings.logoType = 'text'">文字</a>
          </li>
        </ul>
      </div>
      <div class="form-group" v-show="settings.logo">
        <div class="column">
          <div class="form-group" v-show="settings.logoType === 'image'">
            <div class="column col-3">
              <label class="form-label label-sm">图片:</label>
            </div>
            <div class="column">
              <img src="../plugins/qrcode/logo.png" ref="logo" @load="update" style="max-width:330px;">
              <input class="form-input input-sm" type="file" @change="loadImage($event,'logo')">
            </div>
          </div>
          <div v-show="settings.logoType === 'text'">
            <div class="form-group">
              <div class="column col-3">
                <label class="form-label label-sm">文字:</label>
              </div>
              <div class="column">
                <input class="form-input input-sm" v-model="settings.logoText">
              </div>
            </div>
            <div class="form-group">
              <div class="column col-3">
                <label class="form-label label-sm">字体:</label>
              </div>
              <div class="column">
                <input class="form-input input-sm" placeholder="CSS font string" v-model="settings.logoFont">
              </div>
            </div>
            <div class="form-group">
              <div class="column col-3">
                <label class="form-label label-sm">颜色:</label>
              </div>
              <div class="column">
                <input class="form-input input-sm" type="color" v-model="settings.logoColor">
              </div>
            </div>
            <div class="form-group">
              <div class="column">
                <label class="form-checkbox ">
                  <input type="checkbox" v-model="settings.logoBold">
                  <i class="form-icon"></i>
                  粗体
                </label>
              </div>
              <div class="column">
                <label class="form-checkbox ">
                  <input type="checkbox" v-model="settings.logoItalic">
                  <i class="form-icon"></i>
                  斜体
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
		

	</div>
	
    <div class="column">
		<center>
		<qr-canvas :options="options"></qr-canvas>		
        <br><br>  
			<button id="savebtn"  class="savetext" >保存</button>&nbsp;	&nbsp;&nbsp;
	        <button id="returnbtn"  class="savetext" >返回</button>
		</center>
    </div>
	
  </div>
</div>
<script type="text/javascript" >
    var id = "<%=Id %>";
    var words = unescape("<%=Words %>");
    var thumb = "<%=Thumb %>";
</script>
<script src="../plugins/qrcode/index.js" type="text/javascript"></script>
<script type="text/javascript" >
    function returnurl() {
        if (confirm('确定要返回吗，记得先保存。') == true) {
            window.location.href = "<%=Fpage %>"
        }
    }
    $("#savebtn").on("click", function (e) {
        savework();
        alert("保存成功！");
    });

    $("#returnbtn").on("click", function (e) {
        returnurl();
    });


    function savework() {
        var title = "";
        var Cover = blob(canvas.toDataURL());
        var Content = escape(document.getElementById("inputText").value);
        var Extension = "qrcode";
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
            //alert("保存成功！");
            console.log(res)
        });
    }
</script>
</body>
</html>
