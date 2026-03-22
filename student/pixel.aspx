<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="Student_pixel_new" %>

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
        <div class="brand-card">
		    <img id="logo" src="../pixelartmaker/logo.png" alt="像素蘑菇小兵！"/>
            <div class="brand-copy">
                <span class="brand-badge">Pixel Studio</span>
                <h1>Pixel Art Maker</h1>
                <p>像素画与逐帧动画创作面板</p>
            </div>
        </div>
	  </div>
	  <div class="right">
          <div class="toolbar-grid">
              <div class="tool-card">
                  <span class="tool-label">当前颜色</span>
                  <div class="color-field">
                      <input type="color" id="colorPicker"/>
                      <span class="tool-hint">点击左侧图标可展开完整色卡，支持自定义颜色。</span>
                  </div>
              </div>
              <div class="tool-card tool-card-size">
                  <span class="tool-label">画布大小</span>
                  <div class="size-fields">
                      <label class="size-field">
                          <span>宽</span>
                          <input type="number" id="canvasWidth" min="8" max="80" value="50"/>
                      </label>
                      <label class="size-field">
                          <span>高</span>
                          <input type="number" id="canvasHeight" min="8" max="80" value="36"/>
                      </label>
                      <button id="resizebtn" class="toolbar-btn toolbar-btn-secondary" type="button">应用画布</button>
                  </div>
              </div>
              <div class="tool-card tool-card-actions">
                  <span class="tool-label">常用操作</span>
                  <div class="action-buttons">
                      <button id="savebtn" class="toolbar-btn toolbar-btn-primary" type="button">保存</button>
                      <button id="playbtn" class="toolbar-btn toolbar-btn-accent" type="button">播放</button>
                      <button id="returnbtn" class="toolbar-btn toolbar-btn-ghost" type="button">返回</button>
                  </div>
              </div>
          </div>
          <div class="palette-wrap">
              <div class="palette-title">常用颜色</div>
		      <table id="palette"></table>
          </div>
	  </div>
  </div>
  <div id="petcolor">
      <div class="drawer-title">扩展色板</div>
	  <table id="paletteB"></table>
  </div>
  <div class="canvas-shell">
      <div class="canvas-toolbar">
          <span class="canvas-label">画布</span>
          <span class="canvas-meta">支持 8 - 80 格尺寸设置，缩小时会保留左上区域内容。</span>
      </div>
      <div class="canvas-board">
          <table id="pixel_canvas"></table>
      </div>
  </div>
  <div class="frames-shell">
      <div class="frames-header">
          <span class="frames-title">动画帧</span>
          <span class="frames-subtitle">点击缩略图切换，拖动可排序。</span>
      </div>
      <div id="framelist">
	      <div id="frameadd">
		      <div id="plus" title="复制当前帧">+</div>
		      <div id="minus" title="删除当前帧">-</div>
	      </div>
		  <div id="fm1" class="frame"></div>
      </div>
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
<script src="../pixelartmaker/PixelArtMaker.js" type="text/javascript" ></script>
<script src='../pixelartmaker/gif.js' type="text/javascript" ></script>
<script src='../pixelartmaker/gif.worker.js' type="text/javascript" ></script>
</body>
</html>

