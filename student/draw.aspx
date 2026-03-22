<%@ page language="C#" autoeventwireup="true" inherits="student_draw, LearnSite" %>

<html lang="zh-cn">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title>在线画布 Excalidraw</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover,shrink-to-fit=no" />
    <meta name="referrer" content="origin" />
    <meta name="mobile-web-app-capable" content="yes" />
    <meta name="theme-color" content="#121212" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" />
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
		/* ===== draw.aspx 浮动工具栏 ===== */
		.dw-toolbar {
			position: fixed;
			top: 16px;
			right: 16px;
			z-index: 9999;
			display: flex;
			gap: 8px;
			align-items: center;
			background: rgba(255,255,255,0.92);
			backdrop-filter: blur(12px);
			-webkit-backdrop-filter: blur(12px);
			border: 1px solid rgba(99,102,241,0.15);
			border-radius: 12px;
			padding: 8px 10px;
			box-shadow: 0 4px 24px rgba(99,102,241,0.13), 0 1px 4px rgba(0,0,0,0.07);
		}
		html.dark .dw-toolbar {
			background: rgba(30,30,46,0.92);
			border-color: rgba(99,102,241,0.25);
			box-shadow: 0 4px 24px rgba(0,0,0,0.35);
		}
		.dw-btn {
			display: flex;
			align-items: center;
			gap: 6px;
			padding: 7px 14px;
			border: none;
			border-radius: 8px;
			font-family: 'Inter', 'Microsoft YaHei', sans-serif;
			font-size: 13px;
			font-weight: 500;
			cursor: pointer;
			transition: background 0.18s, transform 0.12s, box-shadow 0.18s;
			outline: none;
			line-height: 1;
		}
		.dw-btn:active { transform: scale(0.96); }
		.dw-btn-save {
			background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
			color: #fff;
			box-shadow: 0 2px 8px rgba(99,102,241,0.35);
		}
		.dw-btn-save:hover {
			background: linear-gradient(135deg, #818cf8 0%, #6366f1 100%);
			box-shadow: 0 4px 14px rgba(99,102,241,0.45);
		}
		.dw-btn-save.saving {
			opacity: 0.75;
			cursor: not-allowed;
		}
		.dw-btn-back {
			background: rgba(100,116,139,0.1);
			color: #475569;
		}
		html.dark .dw-btn-back {
			background: rgba(148,163,184,0.12);
			color: #94a3b8;
		}
		.dw-btn-back:hover {
			background: rgba(100,116,139,0.18);
			color: #1e293b;
		}
		html.dark .dw-btn-back:hover { color: #e2e8f0; }
		.dw-btn svg {
			width: 15px; height: 15px;
			flex-shrink: 0;
		}
		/* Toast 通知 */
		.dw-toast {
			position: fixed;
			top: 68px;
			right: 16px;
			z-index: 9999;
			display: flex;
			align-items: center;
			gap: 8px;
			padding: 10px 16px;
			border-radius: 10px;
			font-family: 'Inter', 'Microsoft YaHei', sans-serif;
			font-size: 13px;
			font-weight: 500;
			color: #fff;
			box-shadow: 0 4px 16px rgba(0,0,0,0.15);
			opacity: 0;
			transform: translateY(-8px);
			transition: opacity 0.25s, transform 0.25s;
			pointer-events: none;
		}
		.dw-toast.show {
			opacity: 1;
			transform: translateY(0);
		}
		.dw-toast.success { background: linear-gradient(135deg, #22c55e, #16a34a); }
		.dw-toast.error   { background: linear-gradient(135deg, #ef4444, #dc2626); }
    </style>
  <script type="module" crossorigin src="../Plugins/excalidraw/assets/index-DMdoekNJ.js"></script>
    <link rel="stylesheet" crossorigin href="../Plugins/excalidraw/assets/index.css">
    <link rel="manifest" href="../Plugins/excalidraw/manifest.webmanifest">
    <script src="../code/jquery.min.js"></script>
</head>
<body>
    <!-- 浮动工具栏 -->
    <div class="dw-toolbar">
        <button class="dw-btn dw-btn-save" id="btnSave" onclick="savework();">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
                <polyline points="17 21 17 13 7 13 7 21"/>
                <polyline points="7 3 7 8 15 8"/>
            </svg>
            保存
        </button>
        <button class="dw-btn dw-btn-back" onclick="returnurl();">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="15 18 9 12 15 6"/>
            </svg>
            返回
        </button>
    </div>
    <!-- Toast 通知 -->
    <div class="dw-toast" id="dwToast"></div>
    <div id="drawUrl" class="hide"><%=Wurl %></div>
    <div id="root">
    </div>
<script type="text/javascript" >    

var id = "<%=Id %>";

function showToast(msg, type) {
    var t = document.getElementById('dwToast');
    t.textContent = msg;
    t.className = 'dw-toast ' + (type || 'success') + ' show';
    clearTimeout(t._timer);
    t._timer = setTimeout(function() { t.className = 'dw-toast ' + (type || 'success'); }, 2400);
}
function returnurl() {
    if (confirm('是否要离开此页面？') == true) {
        window.location.href = "<%=Fpage %>"
    }
}
async function savework() {
    var btn = document.getElementById('btnSave');
    if (btn.classList.contains('saving')) return;
    btn.classList.add('saving');
    btn.textContent = '保存中…';
    try {
        var title = "";
        var Cover = await getmyPng();
        var jsonstr = await getmyJson();
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
        }).done(function(res) {
            showToast('✓ 保存成功！', 'success');
            console.log(res);
        }).fail(function() {
            showToast('✗ 保存失败，请重试', 'error');
        }).always(function() {
            btn.classList.remove('saving');
            btn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:15px;height:15px"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>保存';
        });
    } catch(e) {
        showToast('✗ 保存失败：' + e.message, 'error');
        btn.classList.remove('saving');
        btn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:15px;height:15px"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>保存';
    }
}
      
</script>
</body>
</html>
