<%@ page language="C#" autoeventwireup="true" inherits="student_qrcode, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head id="Head1" runat="server">
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>二维码创作</title>
<script src="../plugins/qrcode/vue.min.js"></script>
<script src="../plugins/qrcode/qrcanvas-proxy.aspx"></script>
<script src="../plugins/qrcode/jsQR.js"></script>
<script src="../code/jquery.min.js"></script>
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: "Segoe UI", "Microsoft YaHei", "PingFang SC", sans-serif;
  background: #f0f2f7;
  min-height: 100vh;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ─── Header ─── */
.qr-header {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 60%, #9333ea 100%);
  padding: 14px 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 16px rgba(79,70,229,0.35);
  flex-shrink: 0;
}
.qr-header-brand { display: flex; align-items: center; gap: 12px; }
.qr-header-icon {
  width: 40px; height: 40px;
  background: rgba(255,255,255,0.18);
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
}
.qr-header-title { font-size: 18px; font-weight: 700; color: #fff; line-height: 1.2; }
.qr-header-sub   { font-size: 12px; color: rgba(255,255,255,0.72); margin-top: 1px; }
.qr-header-actions { display: flex; gap: 8px; }

/* ─── Main layout ─── */
.qr-main {
  flex: 1;
  display: flex;
  gap: 20px;
  padding: 24px 28px;
  max-width: 1100px;
  margin: 0 auto;
  width: 100%;
}

/* ─── Settings column ─── */
.qr-col-settings {
  width: 360px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* ─── Preview column ─── */
.qr-col-preview {
  flex: 1;
  display: flex;
  align-items: flex-start;
}

/* ─── Card ─── */
.qr-card {
  background: #fff;
  border-radius: 16px;
  padding: 18px 20px;
  box-shadow: 0 1px 8px rgba(0,0,0,0.07), 0 0 0 1px rgba(0,0,0,0.04);
}
.qr-card-heading {
  font-size: 11.5px;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.9px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* ─── Textarea ─── */
.qr-textarea {
  width: 100%;
  min-height: 90px;
  padding: 10px 12px;
  border: 1.5px solid #e2e8f0;
  border-radius: 10px;
  font-size: 13.5px;
  font-family: inherit;
  color: #1e293b;
  resize: vertical;
  outline: none;
  transition: border-color 0.18s, box-shadow 0.18s;
  line-height: 1.5;
}
.qr-textarea:focus {
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99,102,241,0.14);
}

/* ─── Theme buttons ─── */
.qr-theme-row { display: flex; gap: 8px; flex-wrap: wrap; }
.qr-theme-btn {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 14px;
  border-radius: 8px;
  border: 1.5px solid #e2e8f0;
  background: #fff;
  font-size: 13px; font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  color: #475569;
  transition: all 0.15s;
}
.qr-theme-btn:hover {
  border-color: #6366f1; color: #6366f1;
  background: #f5f3ff;
}
.qr-theme-dot {
  width: 11px; height: 11px;
  border-radius: 50%;
  display: inline-block;
  flex-shrink: 0;
  border: 1px solid rgba(0,0,0,0.1);
}

/* ─── Toggle switch ─── */
.qr-logo-header {
  display: flex; align-items: center; justify-content: space-between;
}
.qr-logo-header.has-content { margin-bottom: 14px; }
.qr-logo-label {
  font-size: 13.5px; font-weight: 600; color: #374151;
  display: flex; align-items: center; gap: 6px;
}
.qr-switch { position: relative; width: 38px; height: 22px; flex-shrink: 0; }
.qr-switch input { opacity: 0; width: 0; height: 0; position: absolute; }
.qr-switch-track {
  position: absolute; inset: 0;
  background: #cbd5e1; border-radius: 22px; cursor: pointer;
  transition: background 0.2s;
}
.qr-switch-track::before {
  content: '';
  position: absolute;
  width: 16px; height: 16px; top: 3px; left: 3px;
  background: #fff; border-radius: 50%;
  transition: transform 0.2s;
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}
.qr-switch input:checked ~ .qr-switch-track { background: #6366f1; }
.qr-switch input:checked ~ .qr-switch-track::before { transform: translateX(16px); }

/* ─── Logo type tabs ─── */
.qr-logo-tabs {
  display: flex; gap: 2px;
  background: #f1f5f9;
  border-radius: 9px;
  padding: 3px;
  margin-bottom: 14px;
}
.qr-logo-tab {
  flex: 1; padding: 5px 0;
  border-radius: 7px; border: none;
  font-size: 13px; font-weight: 500; font-family: inherit;
  cursor: pointer; transition: all 0.15s;
  background: transparent; color: #64748b;
}
.qr-logo-tab.active {
  background: #fff; color: #6366f1;
  box-shadow: 0 1px 4px rgba(0,0,0,0.1);
}

/* ─── Form fields ─── */
.qr-field { margin-bottom: 10px; }
.qr-field:last-child { margin-bottom: 0; }
.qr-field-label {
  display: block; font-size: 12px; font-weight: 600;
  color: #64748b; margin-bottom: 4px;
}
.qr-input {
  width: 100%; padding: 7px 11px;
  border: 1.5px solid #e2e8f0; border-radius: 8px;
  font-size: 13px; color: #1e293b;
  font-family: inherit; outline: none;
  transition: border-color 0.18s, box-shadow 0.18s;
}
.qr-input:focus {
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
}
.qr-inline-row { display: flex; gap: 12px; align-items: flex-end; }
.qr-inline-row > .qr-field { flex: 1; margin-bottom: 0; }
.qr-checkboxes { display: flex; gap: 14px; padding: 7px 0 1px; }
.qr-check-label {
  display: flex; align-items: center; gap: 5px;
  font-size: 13px; color: #374151; cursor: pointer;
}
.qr-check-label input { accent-color: #6366f1; cursor: pointer; }
.qr-logo-img-preview {
  max-width: 100%; max-height: 72px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  margin-bottom: 8px;
  display: block;
}

/* ─── Preview card ─── */
.qr-preview-card {
  background: #fff;
  border-radius: 20px;
  padding: 28px 24px 24px;
  box-shadow: 0 1px 8px rgba(0,0,0,0.07), 0 0 0 1px rgba(0,0,0,0.04);
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  position: sticky;
  top: 24px;
}
.qr-preview-title {
  align-self: flex-start;
  font-size: 13px; font-weight: 700; color: #1e293b;
  display: flex; align-items: center; gap: 7px;
  margin-bottom: 20px;
}
.qr-canvas-wrap {
  padding: 14px;
  background: #f8fafc;
  border-radius: 16px;
  border: 1.5px dashed #e2e8f0;
  transition: border-color 0.2s, box-shadow 0.2s;
  margin-bottom: 10px;
}
.qr-canvas-wrap:hover {
  border-color: #a5b4fc;
  box-shadow: 0 4px 18px rgba(99,102,241,0.13);
}
.qr-canvas-wrap canvas { display: block; border-radius: 6px; }
.qr-canvas-hint {
  font-size: 11.5px; color: #94a3b8;
  text-align: center;
  margin-bottom: 22px;
  display: flex; align-items: center; justify-content: center; gap: 4px;
}
.qr-canvas-hint svg {
  width: 12px; height: 12px;
  stroke: currentColor; fill: none; stroke-width: 2;
  stroke-linecap: round; stroke-linejoin: round;
  flex-shrink: 0;
}

/* ─── Buttons ─── */
.qr-btn {
  display: inline-flex; align-items: center; gap: 7px;
  padding: 10px 22px; border-radius: 10px;
  font-size: 13.5px; font-weight: 600; font-family: inherit;
  cursor: pointer; transition: all 0.18s;
  border: none; outline: none;
  white-space: nowrap;
}
.qr-btn svg {
  width: 15px; height: 15px;
  stroke: currentColor; fill: none;
  stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
  flex-shrink: 0;
}
.qr-btn-primary {
  background: linear-gradient(135deg, #6366f1 0%, #7c3aed 100%);
  color: #fff;
  box-shadow: 0 3px 10px rgba(99,102,241,0.3);
}
.qr-btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 5px 16px rgba(99,102,241,0.42);
}
.qr-btn-primary:active { transform: translateY(0); }
.qr-btn-ghost {
  background: transparent;
  border: 1.5px solid rgba(255,255,255,0.42);
  color: #fff;
}
.qr-btn-ghost:hover {
  background: rgba(255,255,255,0.15);
  border-color: rgba(255,255,255,0.72);
}
.qr-btn-header-save {
  background: rgba(255,255,255,0.2);
  border: 1.5px solid rgba(255,255,255,0.42);
  color: #fff;
  box-shadow: none;
}
.qr-btn-header-save:hover {
  background: rgba(255,255,255,0.32);
  transform: translateY(-1px);
}
.qr-btn-outline {
  background: #fff;
  border: 1.5px solid #e2e8f0;
  color: #475569;
}
.qr-btn-outline:hover { background: #f8fafc; border-color: #94a3b8; color: #1e293b; }
.qr-preview-btns { display: flex; gap: 10px; width: 100%; }
.qr-preview-btns .qr-btn-primary { flex: 1; justify-content: center; }

/* ─── Toast ─── */
.qr-toast {
  position: fixed; bottom: 24px; left: 50%;
  transform: translateX(-50%) translateY(70px);
  background: #1e293b; color: #fff;
  padding: 11px 18px; border-radius: 10px;
  font-size: 13.5px; font-weight: 500;
  display: flex; align-items: center; gap: 8px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.22);
  z-index: 9999; opacity: 0;
  transition: transform 0.32s cubic-bezier(0.34,1.56,0.64,1), opacity 0.28s ease;
  pointer-events: none;
}
.qr-toast.visible {
  transform: translateX(-50%) translateY(0);
  opacity: 1;
}
.qr-toast svg {
  width: 17px; height: 17px;
  stroke: #34d399; fill: none;
  stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round;
  flex-shrink: 0;
}

/* ─── Responsive ─── */
@media (max-width: 720px) {
  .qr-main { flex-direction: column; padding: 16px; }
  .qr-col-settings { width: 100%; }
}
</style>
</head>
<body>

<div id="app" style="display:none" v-show="true">

  <%-- ── Header ── --%>
  <header class="qr-header">
    <div class="qr-header-brand">
      <div class="qr-header-icon">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
          <rect x="3" y="14" width="7" height="7"/>
          <path d="M14 14h3v3M14 20h7M20 17v3"/>
        </svg>
      </div>
      <div>
        <div class="qr-header-title">二维码创作</div>
        <div class="qr-header-sub">设计并生成你的专属二维码</div>
      </div>
    </div>
    <div class="qr-header-actions">
      <button id="returnbtn" class="qr-btn qr-btn-ghost">
        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
        返回
      </button>
      <button id="savebtn" class="qr-btn qr-btn-header-save">
        <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
        保存作品
      </button>
    </div>
  </header>

  <%-- ── Main ── --%>
  <main class="qr-main">

    <%-- Left: settings column --%>
    <div class="qr-col-settings">

      <%-- Content card --%>
      <div class="qr-card">
        <div class="qr-card-heading">
          <svg width="14" height="14" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="13" y2="17"/></svg>
          二维码内容
        </div>
        <textarea id="inputText" class="qr-textarea" v-model="settings.qrtext" placeholder="输入网址、文字或任意内容…"></textarea>
      </div>

      <%-- Color theme card --%>
      <div class="qr-card">
        <div class="qr-card-heading">
          <svg width="14" height="14" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
          颜色主题
        </div>
        <div class="qr-theme-row">
          <button class="qr-theme-btn" v-for="theme in themes" :key="theme" @click.prevent="loadTheme(theme)">
            <span class="qr-theme-dot" :style="'background:' + (theme==='黑码'?'#222':theme==='绿码'?'#00AC00':theme==='红码'?'#D00000':'#0055ff')"></span>
            {{ theme }}
          </button>
        </div>
      </div>

      <%-- Logo card --%>
      <div class="qr-card">
        <div class="qr-logo-header" :class="{ 'has-content': settings.logo }">
          <span class="qr-logo-label">
            <svg width="15" height="15" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
            徽标
          </span>
          <label class="qr-switch">
            <input type="checkbox" v-model="settings.logo">
            <span class="qr-switch-track"></span>
          </label>
        </div>

        <div v-show="settings.logo">
          <div class="qr-logo-tabs">
            <button class="qr-logo-tab" :class="{ active: settings.logoType === 'image' }" @click.prevent="settings.logoType = 'image'">图片</button>
            <button class="qr-logo-tab" :class="{ active: settings.logoType === 'text'  }" @click.prevent="settings.logoType = 'text'">文字</button>
          </div>

          <%-- Logo: image --%>
          <div v-show="settings.logoType === 'image'">
            <img src="../plugins/qrcode/logo.png" ref="logo" @load="update" class="qr-logo-img-preview">
            <input class="qr-input" type="file" @change="loadImage($event,'logo')" accept="image/*">
          </div>

          <%-- Logo: text --%>
          <div v-show="settings.logoType === 'text'">
            <div class="qr-field">
              <label class="qr-field-label">文字内容</label>
              <input class="qr-input" v-model="settings.logoText">
            </div>
            <div class="qr-field">
              <label class="qr-field-label">字体</label>
              <input class="qr-input" placeholder="如：微软雅黑" v-model="settings.logoFont">
            </div>
            <div class="qr-inline-row">
              <div class="qr-field">
                <label class="qr-field-label">颜色</label>
                <input class="qr-input" type="color" v-model="settings.logoColor" style="height:36px;padding:3px 6px;cursor:pointer;">
              </div>
              <div class="qr-field">
                <label class="qr-field-label">样式</label>
                <div class="qr-checkboxes">
                  <label class="qr-check-label"><input type="checkbox" v-model="settings.logoBold"> 粗体</label>
                  <label class="qr-check-label"><input type="checkbox" v-model="settings.logoItalic"> 斜体</label>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div><%-- /col-settings --%>

    <%-- Right: preview column --%>
    <div class="qr-col-preview">
      <div class="qr-preview-card">
        <div class="qr-preview-title">
          <svg width="17" height="17" viewBox="0 0 24 24" stroke="#6366f1" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
            <rect x="3" y="14" width="7" height="7"/>
            <path d="M14 14h3v3M14 20h7M20 17v3"/>
          </svg>
          二维码预览
        </div>

        <div class="qr-canvas-wrap">
          <qr-canvas :options="options"></qr-canvas>
        </div>
        <p class="qr-canvas-hint">
          <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          双击可下载图片
        </p>

        <div class="qr-preview-btns">
          <button id="savebtn2" class="qr-btn qr-btn-primary">
            <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            保存作品
          </button>
          <button id="returnbtn2" class="qr-btn qr-btn-outline">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
            返回
          </button>
        </div>
      </div>
    </div>

  </main>
</div>

<%-- Toast notification --%>
<div class="qr-toast" id="qrToast">
  <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
  保存成功！
</div>

<script type="text/javascript">
    var id    = "<%=Id %>";
    var words = unescape("<%=Words %>");
    var thumb = "<%=Thumb %>";
</script>
<script src="../plugins/qrcode/index.js" type="text/javascript"></script>
<script type="text/javascript">
    function showToast() {
        var t = document.getElementById('qrToast');
        t.classList.add('visible');
        setTimeout(function () { t.classList.remove('visible'); }, 2800);
    }

    function returnurl() {
        if (confirm('确定要返回吗，记得先保存。') == true) {
            window.location.href = "<%=Fpage %>";
        }
    }

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
            console.log(res);
        });
    }

    $(function () {
        $("#savebtn, #savebtn2").on("click", function () {
            savework();
            showToast();
        });
        $("#returnbtn, #returnbtn2").on("click", function () {
            returnurl();
        });
    });
</script>
</body>
</html>
