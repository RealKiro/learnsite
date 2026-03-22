<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_ware, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" runat="Server">
<style>
/* ===== ware.aspx 全宽覆盖：完全对齐 program.aspx 方案（已验证可用） ===== */
body:has(.ware-page) .stu,
body:has(.ware-page) .studmasterhead,
body:has(.ware-page) .placeauto {
    width: 100% !important;
    max-width: none !important;
    margin-left: 0 !important;
    margin-right: 0 !important;
    padding-left: 0 !important;
    padding-right: 0 !important;
}
body:has(.ware-page) .placeauto {
    padding-left: 0 !important;
    padding-right: 0 !important;
    width: calc(100vw - 180px) !important;
    margin: 0 !important;
}
body:has(.ware-page) center,
body:has(.ware-page) .stu > center {
    width: 100% !important;
    max-width: none !important;
    margin: 0 !important;
    padding: 0 !important;
    text-align: left !important;
}
body:has(.ware-page) .stu {
    margin: 0 !important;
    padding: 0 !important;
}
body:has(.ware-page) {
    padding-left: 196px !important;
}

/* ===== 页面根容器 ===== */
.ware-page {
    width: calc(100vw - 220px);
    max-width: calc(100vw - 220px);
    margin: 0 !important;
    padding: 20px 16px 48px 8px;
    box-sizing: border-box;
    font-family: "Segoe UI", "Microsoft YaHei", sans-serif;
    color: #334155;
    animation: wareFadeIn 0.45s cubic-bezier(0.22, 1, 0.36, 1);
}
@keyframes wareFadeIn {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: translateY(0); }
}

/* ===== 顶部标题栏 ===== */
.ware-topbar {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 20px;
}
.ware-topbar-icon {
    width: 46px; height: 46px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(102,126,234,.35);
}
.ware-topbar-icon svg {
    width: 24px; height: 24px;
    stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}
.ware-topbar-text h2 {
    margin: 0 0 2px;
    font-size: 20px; font-weight: 700; color: #1e293b;
    line-height: 1.3;
}
.ware-topbar-text p {
    margin: 0;
    font-size: 13px; color: #94a3b8;
}

/* ===== 主体双栏布局 ===== */
.ware-shell {
    display: flex;
    gap: 20px;
    align-items: flex-start;
}

/* ===== 左侧 iframe 预览区 ===== */
.ware-preview {
    flex: 1;
    min-width: 0;
    background: #fff;
    border-radius: 18px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 20px rgba(0,0,0,.06);
    overflow: hidden;
    transition: box-shadow .3s;
}
.ware-preview:hover {
    box-shadow: 0 8px 32px rgba(0,0,0,.09);
}
.ware-preview-header {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 14px 22px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    font-size: 15px; font-weight: 600;
}
.ware-preview-header svg {
    width: 20px; height: 20px;
    stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    flex-shrink: 0;
}
.ware-preview-header .ware-ph-badge {
    margin-left: auto;
    font-size: 11px; font-weight: 500;
    background: rgba(255,255,255,.2);
    padding: 3px 10px;
    border-radius: 20px;
}
.ware-preview-body iframe {
    width: 100%;
    min-height: 82vh;
    border: none;
    display: block;
}

/* ===== 右侧操作栏 ===== */
.ware-sidebar {
    width: 360px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    gap: 16px;
    position: sticky;
    top: 20px;
}

/* 通用卡片 */
.ware-card {
    background: #fff;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 2px 10px rgba(0,0,0,.04);
    overflow: hidden;
    transition: box-shadow .25s;
}
.ware-card:hover {
    box-shadow: 0 6px 24px rgba(0,0,0,.08);
}
.ware-card-head {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 14px 18px;
    border-bottom: 1px solid #f1f5f9;
    font-size: 14px; font-weight: 600; color: #1e293b;
    background: #fafbfc;
}
.ware-card-head svg {
    width: 17px; height: 17px;
    stroke: #6366f1; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    flex-shrink: 0;
}
.ware-card-body {
    padding: 18px;
}

/* 缩略图预览 */
.ware-thumb-wrap {
    background: #f8fafc;
    border-radius: 10px;
    border: 1px dashed #cbd5e1;
    overflow: hidden;
    min-height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
}
.ware-thumb-wrap img {
    width: 100%; height: auto;
    display: block;
    object-fit: cover;
    transition: transform .35s ease;
}
.ware-thumb-wrap:hover img {
    transform: scale(1.03);
}
.ware-thumb-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    padding: 28px 0;
    color: #cbd5e1;
    font-size: 12px;
}
.ware-thumb-empty svg {
    width: 44px; height: 44px;
    stroke: #cbd5e1; fill: none;
    stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
}

/* 保存按钮 */
.ware-save-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    width: 100%;
    height: 50px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    border-radius: 12px;
    color: #fff;
    font-size: 16px; font-weight: 600;
    font-family: inherit;
    cursor: pointer;
    box-shadow: 0 4px 16px rgba(102,126,234,.35);
    transition: all .25s;
    letter-spacing: .02em;
}
.ware-save-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(102,126,234,.45);
    background: linear-gradient(135deg, #5a6fd6 0%, #6a3d8f 100%);
}
.ware-save-btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 8px rgba(102,126,234,.3);
}
.ware-save-btn svg {
    width: 20px; height: 20px;
    stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}

/* 消息提示 */
.ware-msg {
    display: none;
    margin-top: 12px;
    padding: 10px 14px;
    border-radius: 8px;
    font-size: 13px;
    color: #dc2626;
    background: #fef2f2;
    border: 1px solid #fecaca;
    animation: wareMsgIn .3s ease;
}
.ware-msg.show { display: block; }
@keyframes wareMsgIn {
    from { opacity: 0; transform: translateY(-5px); }
    to   { opacity: 1; transform: translateY(0); }
}

/* 提示卡片 */
.ware-tip-card {
    background: linear-gradient(135deg, #eef2ff 0%, #faf5ff 100%);
    border-radius: 12px;
    border: 1px solid #e0e7ff;
    padding: 14px 16px;
    display: flex;
    align-items: flex-start;
    gap: 10px;
    font-size: 13px;
    color: #4f46e5;
    line-height: 1.6;
}
.ware-tip-card svg {
    width: 16px; height: 16px;
    stroke: #6366f1; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    flex-shrink: 0;
    margin-top: 2px;
}

/* 响应式 */
@media (max-width: 1200px) {
    .ware-sidebar { width: 320px; }
}
@media (max-width: 1024px) {
    .ware-sidebar { width: 280px; }
}
@media (max-width: 900px) {
    .ware-shell { flex-direction: column; }
    .ware-sidebar {
        width: 100%;
        position: static;
        flex-direction: row;
        flex-wrap: wrap;
    }
    .ware-card { flex: 1; min-width: 240px; }
}
</style>

<div class="ware-page">
    <!-- 顶部标题栏 -->
    <div class="ware-topbar">
        <div class="ware-topbar-icon">
            <svg viewBox="0 0 24 24"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>
        </div>
        <div class="ware-topbar-text">
            <h2>课件学习</h2>
            <p>查看学习材料，完成后点击保存作品提交成果</p>
        </div>
    </div>

    <!-- 主体双栏 -->
    <div class="ware-shell">
        <!-- 左侧 iframe 预览 -->
        <div class="ware-preview">
            <div class="ware-preview-header">
                <svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                课件内容
                <span class="ware-ph-badge">在线学习</span>
            </div>
            <div class="ware-preview-body">
                <iframe id="wareframe" src="<%=WareUrl %>"></iframe>
            </div>
        </div>

        <!-- 右侧操作栏 -->
        <div class="ware-sidebar">
            <!-- 我的作品卡片 -->
            <div class="ware-card">
                <div class="ware-card-head">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    我的作品
                </div>
                <div class="ware-card-body">
                    <div class="ware-thumb-wrap">
                        <asp:Image ID="Thumbnail" runat="server" />
                    </div>
                </div>
            </div>

            <!-- 保存操作卡片 -->
            <div class="ware-card">
                <div class="ware-card-head">
                    <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                    提交作品
                </div>
                <div class="ware-card-body">
                    <button type="button" class="ware-save-btn" onclick="SaveIframe();">
                        <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        保存作品
                    </button>
                    <div id="msg" class="ware-msg"></div>
                </div>
            </div>

            <!-- 提示 -->
            <div class="ware-tip-card">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                完成课件学习后，点击「保存作品」按钮提交成果。系统将自动截图生成作品缩略图。
            </div>
        </div>
    </div>
</div>

<script src="../code/html2canvas.min.js" type="text/javascript"></script>
<script type="text/javascript">
	var id = "<%=Id %>";
	var wareframe = document.getElementById("wareframe");
	var msg = document.getElementById("msg");
    var quiztitle="";
    var quizvalue=0;

    function setIframeHeight(iframe) {
        if (iframe) {
            var iframeWin = iframe.contentWindow || iframe.contentDocument.parentWindow;
            if (iframeWin.document.body) {
                iframe.height = iframeWin.document.documentElement.scrollHeight || iframeWin.document.body.scrollHeight;
            }
        }
    };
 
    window.onload = function () {
        setIframeHeight(document.getElementById('wareframe'));
    };

    function SaveIframe() { 
        var htmlcode ="";// 使用缩略图预览
        var iframeContent = wareframe.contentDocument || wareframe.contentWindow.document;
		html2canvas(iframeContent.body, {
                        allowTaint: false,
                        useCORS: true,
                        scale: 1,
                        logging: false
                    }).then(pic => {					
			var urls = '../student/uploadtopic.ashx?id=' + id;
			var title = "";
			var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			var Content = htmlcode;
			var Extension = "ware";
			var formData = new FormData();
			formData.append('title', title);
			formData.append('cover', Cover);
			formData.append('content', Content);
			formData.append('ext', Extension);
			formData.append('score', quizvalue);

			$.ajax({
				url: urls,
				type: 'POST',
				cache: false,
				data: formData,
				processData: false,
				contentType: false
			}).done(function (res) {
                var message = "保存成功！  "+quiztitle+" ："+quizvalue;
				alert(message);
                location.reload();

			}).fail(function (res) {
				console.log(res)
			}); 	
		
		});	
    }
                
    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            window.location.href = courseurl;
        }
    }
	function blob(dataURI) {
        var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
        var byteString = atob(dataURI.split(',')[1]);
        var arrayBuffer = new ArrayBuffer(byteString.length);
        var intArray = new Uint8Array(arrayBuffer);

        for (var i = 0; i < byteString.length; i++) {
            intArray[i] = byteString.charCodeAt(i);
        }
        return new Blob([intArray], { type: mimeString });
    }

    //从iframe中的页面向父页面传递数据
    window.addEventListener("message", receiveMessage, false);
    function receiveMessage(event) {
        var data = JSON.parse(event.data);
        quiztitle = data.name;
        quizvalue = data.value;
        //console.log("接收到的数据：", data);
    }

    /*
    // 假设你想发送一个消息
    const message = { name: "示例", value: "数据" };
    // 向父页面发送消息
    window.parent.postMessage(JSON.stringify(message), "*");
    */

</script>
</asp:Content>
