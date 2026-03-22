<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" codefile="wareshow.aspx.cs" inherits="LearnSite.teacher_wareshow" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link href="show-common.css" rel="stylesheet" type="text/css" />

<style>
/* ===== 课件页面专属样式 ===== */

/* 预览区卡片 */
.ware-preview-card {
    background: #fff;
    border-radius: 16px;
    border: 1px solid #e8ecf1;
    box-shadow: 0 2px 8px rgba(0,0,0,.05);
    margin-bottom: 24px;
    overflow: hidden;
    transition: box-shadow .25s, transform .25s;
}
.ware-preview-card:hover {
    box-shadow: 0 6px 24px rgba(99,102,241,.12);
    transform: translateY(-1px);
}

/* 预览头部（紫/靛蓝渐变，与标题绿色形成对比） */
.ware-preview-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 22px;
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
    position: relative;
    overflow: hidden;
}
.ware-preview-header::before {
    content: '';
    position: absolute;
    top: -20px; right: -20px;
    width: 80px; height: 80px;
    border-radius: 50%;
    background: rgba(255,255,255,.08);
}
.ware-preview-header-left {
    display: flex;
    align-items: center;
    gap: 10px;
    position: relative;
    z-index: 1;
}
.ware-preview-header-left svg {
    width: 20px; height: 20px;
    stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    flex-shrink: 0;
}
.ware-preview-title {
    font-size: 14px;
    font-weight: 600;
    color: #fff;
    letter-spacing: .3px;
}

/* 全屏按钮 */
.ware-fullscreen-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    background: rgba(255,255,255,.18);
    border: 1px solid rgba(255,255,255,.3);
    border-radius: 8px;
    color: #fff;
    font-size: 12.5px;
    font-weight: 500;
    cursor: pointer;
    text-decoration: none;
    transition: background .18s, transform .18s;
    position: relative;
    z-index: 1;
    font-family: 'Microsoft YaHei', sans-serif;
}
.ware-fullscreen-btn:hover {
    background: rgba(255,255,255,.28);
    transform: translateY(-1px);
    color: #fff;
    text-decoration: none;
}
.ware-fullscreen-btn svg {
    width: 14px; height: 14px;
    stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}

/* iframe 容器 */
.ware-iframe-wrap {
    width: 100%;
    position: relative;
    background: #f8fafc;
}
.ware-iframe-wrap iframe {
    width: 100%;
    height: 78vh;
    min-height: 480px;
    border: none;
    display: block;
}

/* 空状态（URL 为空时显示） */
.ware-empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 64px 24px;
    color: #94a3b8;
    gap: 14px;
}
.ware-empty-state svg {
    width: 52px; height: 52px;
    stroke: #cbd5e1; fill: none;
    stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
}
.ware-empty-state p {
    font-size: 14px;
    margin: 0;
}

/* 发布状态徽章 */
.ware-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}
.ware-badge-published {
    background: #dcfce7;
    color: #16a34a;
    border: 1px solid #bbf7d0;
}
.ware-badge-unpublished {
    background: #f1f5f9;
    color: #64748b;
    border: 1px solid #e2e8f0;
}
.ware-badge svg {
    width: 12px; height: 12px;
    stroke: currentColor; fill: none;
    stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round;
}

/* 学生端预览按钮 */
.ware-student-btn {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    padding: 7px 16px !important;
    background: linear-gradient(135deg, #ecfdf5, #d1fae5) !important;
    color: #059669 !important;
    border: 1px solid #6ee7b7 !important;
    border-radius: 8px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    text-decoration: none !important;
    transition: all .18s !important;
    font-family: 'Microsoft YaHei', sans-serif !important;
}
.ware-student-btn:hover {
    background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important;
    color: #047857 !important;
    border-color: #34d399 !important;
    transform: translateY(-1px) !important;
    box-shadow: 0 4px 10px rgba(5,150,105,.15) !important;
    text-decoration: none !important;
}
.ware-student-btn svg {
    width: 14px; height: 14px;
    stroke: currentColor; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}

/* 链接按钮（课件首页） */
.ware-link-btn {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    padding: 7px 16px !important;
    background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
    color: #4f46e5 !important;
    border: 1px solid #c7d2fe !important;
    border-radius: 8px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    text-decoration: none !important;
    transition: all .18s !important;
}
.ware-link-btn:hover {
    background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important;
    color: #3730a3 !important;
    border-color: #a5b4fc !important;
    transform: translateY(-1px) !important;
    box-shadow: 0 4px 10px rgba(99,102,241,.15) !important;
    text-decoration: none !important;
}
.ware-link-btn svg {
    width: 14px; height: 14px;
    stroke: currentColor; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}
</style>

<div class="show-container">

    <!-- ① 渐变标题栏（绿色，复用通用样式） -->
    <div class="show-title-card">
        <div class="show-title-icon">
            <svg viewBox="0 0 24 24">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
            </svg>
        </div>
        <div class="show-title-text">
            <h1 class="show-title"><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
            <p class="show-title-sub">网页课件查看 · 可在下方预览或点击课件首页在新标签打开</p>
        </div>
    </div>

    <!-- ② 信息 + 操作卡片（与标题栏合并） -->
    <div class="show-info-card-merged">
        <div class="show-card-head">
            <span class="show-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                课件信息
            </h3>
        </div>
        <div class="show-card-body">
            <div class="show-info-row">

                <!-- 日期 -->
                <div class="show-info-item">
                    <svg style="width:15px;height:15px;stroke:#059669;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0" viewBox="0 0 24 24">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8" y1="2" x2="8" y2="6"/>
                        <line x1="3" y1="10" x2="21" y2="10"/>
                    </svg>
                    <label>日期：</label>
                    <asp:Label ID="LabelMdate" runat="server"></asp:Label>
                </div>

                <!-- 作品类型 -->
                <div class="show-info-item">
                    <svg style="width:15px;height:15px;stroke:#059669;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0" viewBox="0 0 24 24">
                        <polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/>
                    </svg>
                    <label>类型：</label>
                    <asp:Image ID="ImageType" runat="server" />
                    <asp:Label ID="LabelMfiletype" runat="server"></asp:Label>
                </div>

                <!-- 发布状态（用隐藏的 CheckBox 驱动 JS 徽章） -->
                <div class="show-info-item" style="padding:6px 12px">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="" Enabled="False" style="display:none" />
                    <span id="spnPublish" class="ware-badge ware-badge-unpublished">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        未发布
                    </span>
                </div>

                <!-- 课件首页链接 -->
                <div class="show-info-item" style="background:transparent;border-color:transparent;padding:4px 0">
                    <asp:HyperLink ID="HyperLinkHtml" runat="server" Target="_blank" CssClass="ware-link-btn">
                        <svg viewBox="0 0 24 24"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/>
                        </svg>
                        课件首页
                    </asp:HyperLink>
                </div>

            </div>

            <!-- 操作按钮 -->
            <div class="show-actions">
                <asp:ImageButton ID="BtnEdit" runat="server"
                    onclick="BtnEdit_Click"
                    ImageUrl="~/images/edit.gif"
                    CssClass="show-btn show-btn-primary"
                    AlternateText="修改课件" />
<% if (!string.IsNullOrEmpty(StudentUrl)) { %>
                <a href="<%=StudentUrl%>" target="_blank" class="ware-student-btn">
                    <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    学生端预览
                </a>
<% } %>
                <asp:ImageButton ID="BtnReturnSmall" runat="server"
                    onclick="BtnReturnSmall_Click"
                    ImageUrl="~/images/return.gif"
                    CssClass="show-btn"
                    AlternateText="返回列表" />
            </div>
        </div>
    </div>

    <!-- ③ 课件预览卡片 -->
    <div class="ware-preview-card">
        <div class="ware-preview-header">
            <div class="ware-preview-header-left">
                <svg viewBox="0 0 24 24">
                    <polygon points="23 7 16 12 23 17 23 7"/>
                    <rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
                </svg>
                <span class="ware-preview-title">课件预览</span>
            </div>
            <a id="btnFullscreen" href="<%=WareUrl %>" target="_blank" class="ware-fullscreen-btn">
                <svg viewBox="0 0 24 24">
                    <polyline points="15 3 21 3 21 9"/>
                    <polyline points="9 21 3 21 3 15"/>
                    <line x1="21" y1="3" x2="14" y2="10"/>
                    <line x1="3" y1="21" x2="10" y2="14"/>
                </svg>
                全屏打开
            </a>
        </div>
        <div class="ware-iframe-wrap" id="iframeWrap">
            <iframe id="htmliframe" src="<%=WareUrl %>" allowfullscreen></iframe>
        </div>
    </div>

    </div>

    <!-- ⑤ 课件文件列表卡片 -->
    <div class="ware-preview-card">
        <div class="ware-preview-header">
            <div class="ware-preview-header-left">
                <svg viewBox="0 0 24 24">
                    <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/>
                    <polyline points="13 2 13 9 20 9"/>
                </svg>
                <span class="ware-preview-title">课件文件</span>
            </div>
        </div>
        <div style="padding: 16px 24px; min-height: 60px;">
            <div id="wareFileList"><p style="color:#94a3b8;font-size:13px;">加载中…</p></div>
        </div>
    </div>

</div>

<!-- 原始内容（隐藏） -->
<div class="courseshow"></div>

<style>
/* 文件列表行 */
.wf-item { display:flex; align-items:center; gap:12px; padding:10px 0; border-bottom:1px solid #f1f5f9; border-left:3px solid transparent; padding-left:6px; transition:background .12s; }
.wf-item:last-child { border-bottom:none; }
.wf-item:hover { background:#f8fafc; }
.wf-item.wf-html { border-left-color:#818cf8; background:#fafafe; }
.wf-item.wf-html:hover { background:#eef2ff; }
.wf-item.wf-active { border-left-color:#6366f1; background:#eef2ff !important; }
.wf-icon { font-size:26px; flex-shrink:0; width:34px; text-align:center; }
.wf-info { flex:1; min-width:0; }
.wf-name { font-size:13px; font-weight:600; color:#334155; word-break:break-all; }
.wf-name a { color:#334155; text-decoration:none; }
.wf-name a:hover { color:#4f46e5; }
.wf-html .wf-name a { color:#4f46e5; }
.wf-meta { font-size:12px; color:#94a3b8; margin-top:2px; }
.wf-empty { padding:32px; text-align:center; color:#94a3b8; font-size:13px; }
/* HTML 预览按钮 */
.wf-prev-btn {
    display:inline-flex; align-items:center; gap:4px;
    padding:4px 12px; border-radius:6px; font-size:12px; font-weight:500;
    background:linear-gradient(135deg,#6366f1,#818cf8); color:#fff;
    border:none; cursor:pointer; white-space:nowrap; flex-shrink:0;
    transition:all .15s; box-shadow:0 1px 4px rgba(99,102,241,.2);
}
.wf-prev-btn:hover { background:linear-gradient(135deg,#4f46e5,#6366f1); box-shadow:0 3px 8px rgba(99,102,241,.35); }
.wf-prev-btn.wf-active-btn { background:linear-gradient(135deg,#059669,#34d399); box-shadow:0 1px 4px rgba(5,150,105,.2); }
</style>

<script type="text/javascript">
(function () {
    // ─── 按钮文字（替换 ImageButton 默认图片显示） ───
    var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
    if (btnEdit) { btnEdit.value = '✏ 修改课件'; }

    var btnReturn = document.getElementById('<%= BtnReturnSmall.ClientID %>');
    if (btnReturn) { btnReturn.value = '← 返回列表'; }

    // ─── 发布状态徽章 ───
    var cb = document.getElementById('<%= CheckPublish.ClientID %>');
    var badge = document.getElementById('spnPublish');
    if (cb && badge) {
        if (cb.checked) {
            badge.className = 'ware-badge ware-badge-published';
            badge.innerHTML = '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg> 已发布';
        }
    }

    // ─── iframe URL 为空时显示占位 ───
    var wrap   = document.getElementById('iframeWrap');
    var iframe = document.getElementById('htmliframe');
    var fsBtn  = document.getElementById('btnFullscreen');
    var rawSrc = iframe ? (iframe.getAttribute('src') || '') : '';
    if (!rawSrc || rawSrc === 'about:blank') {
        if (iframe) iframe.style.display = 'none';
        if (fsBtn) fsBtn.style.display = 'none';
        if (wrap) {
            wrap.innerHTML = '<div class="ware-empty-state">'
                + '<svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>'
                + '<line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>'
                + '<p>请在 <b>修改课件</b> 中点击「设置」将 HTML 文件设为课件首页</p></div>';
        }
    }

    // ─── 课件文件列表 ───
    // cid 用课程 ID（Mission.Mcid），与 wareadd/wareedit 中 store 文件夹保持一致
    var mid = '<%=CourseId %>';
    var fileIcons = {
        'jpg':'🖼️','jpeg':'🖼️','png':'🖼️','gif':'🖼️','bmp':'🖼️','webp':'🖼️',
        'pdf':'📕','doc':'📄','docx':'📄','pptx':'📊','xlsx':'📊',
        'mp4':'🎬','avi':'🎬','mov':'🎬','mkv':'🎬',
        'mp3':'🎵','wav':'🎵','flac':'🎵',
        'txt':'📝','html':'🌐','htm':'🌐',
        'zip':'📦','rar':'📦','7z':'📦'
    };
    function fmtSize(b) {
        if (!b) return '0 B';
        var u = ['B','KB','MB','GB'], i = Math.floor(Math.log(b) / Math.log(1024));
        return (b / Math.pow(1024, i)).toFixed(1) + ' ' + u[i];
    }
    function getIcon(name) {
        var ext = (name.split('.').pop() || '').toLowerCase();
        return fileIcons[ext] || '📄';
    }
    function isHtml(name) {
        var ext = (name.split('.').pop() || '').toLowerCase();
        return ext === 'html' || ext === 'htm';
    }

    // 点击预览按钮将 HTML 文件加载到 iframe
    function previewHtml(url, btn) {
        var ifrWrap = document.getElementById('iframeWrap');
        var ifr     = document.getElementById('htmliframe');
        var fs      = document.getElementById('btnFullscreen');
        // 显示 iframe（移除占位）
        if (ifrWrap) {
            ifrWrap.innerHTML = '<iframe id="htmliframe" src="' + url + '" allowfullscreen style="width:100%;height:78vh;min-height:480px;border:none;display:block;"></iframe>';
        }
        // 更新全屏按钮链接
        if (fs) { fs.href = url; fs.style.display = ''; }
        // 按钮状态切换
        var allBtns = document.querySelectorAll('.wf-prev-btn');
        for (var b = 0; b < allBtns.length; b++) allBtns[b].className = 'wf-prev-btn';
        var allItems = document.querySelectorAll('.wf-item');
        for (var it = 0; it < allItems.length; it++) allItems[it].classList.remove('wf-active');
        if (btn) {
            btn.className = 'wf-prev-btn wf-active-btn';
            btn.textContent = '● 预览中';
            var row = btn.closest ? btn.closest('.wf-item') : btn.parentNode.parentNode;
            if (row) row.classList.add('wf-active');
        }
    }

    function loadWareFiles() {
        if (!mid || mid === '0') return;
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'ware.ashx?action=files&cid=' + mid + '&t=' + Date.now(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4 || xhr.status !== 200) return;
            var list = document.getElementById('wareFileList');
            if (!list) return;
            try {
                var files = JSON.parse(xhr.responseText);
                if (!files || !files.length) {
                    list.innerHTML = '<div class="wf-empty">还没有上传任何文件，请在「修改课件」中上传</div>';
                    return;
                }
                var html = '';
                var firstHtmlUrl = null;
                for (var i = 0; i < files.length; i++) {
                    var f = files[i];
                    var fname   = encodeURIComponent(f.path.replace(/\\/g, '/'));
                    var furl    = '../store/' + mid + '/' + fname;
                    var htmlFile = isHtml(f.name);
                    if (htmlFile && !firstHtmlUrl) firstHtmlUrl = furl;
                    var rowCls  = 'wf-item' + (htmlFile ? ' wf-html' : '');
                    var prevBtn = htmlFile
                        ? '<button type="button" class="wf-prev-btn" onclick="previewHtml(\'' + furl + '\',this)">▶ 预览</button>'
                        : '';
                    html += '<div class="' + rowCls + '">'
                        + '<div class="wf-icon">' + getIcon(f.name) + '</div>'
                        + '<div class="wf-info">'
                        + '<div class="wf-name"><a href="' + furl + '" target="_blank">' + f.name + '</a></div>'
                        + '<div class="wf-meta">' + fmtSize(f.size) + ' &nbsp;|&nbsp; ' + f.date + '</div>'
                        + '</div>'
                        + prevBtn
                        + '</div>';
                }
                list.innerHTML = html;
                // 如果 iframe 当前为空且存在 HTML 文件，自动加载第一个
                var curSrc = document.getElementById('htmliframe')
                              ? (document.getElementById('htmliframe').getAttribute('src') || '') : '';
                if ((!curSrc || curSrc === 'about:blank') && firstHtmlUrl) {
                    var firstBtn = list.querySelector('.wf-prev-btn');
                    previewHtml(firstHtmlUrl, firstBtn);
                }
            } catch(e) {
                document.getElementById('wareFileList').innerHTML = '<div class="wf-empty">文件列表加载失败</div>';
            }
        };
        xhr.send();
    }
    loadWareFiles();
}());
</script>

</asp:Content>
