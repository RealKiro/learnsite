<%@ Page Title="添加游戏" Language="C#" MasterPageFile="~/teacher/Teach.master"
    AutoEventWireup="true" Inherits="System.Web.UI.Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
/* ===== 添加游戏页 ===== */
.gu { max-width:1400px; width:100%; margin:0 auto; font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif; box-sizing:border-box; }

/* 页头 */
.gu-hd { display:flex; align-items:center; gap:14px; margin-bottom:24px; }
.gu-hd-icon {
    width:48px; height:48px; border-radius:12px; flex-shrink:0;
    background:linear-gradient(135deg,#0ea5e9,#38bdf8);
    display:flex; align-items:center; justify-content:center;
    box-shadow:0 4px 12px rgba(14,165,233,.25);
}
.gu-hd-icon svg { width:26px; height:26px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.gu-hd-title { font-size:20px; font-weight:700; color:#0f172a; margin:0 0 4px; }
.gu-hd-sub   { font-size:13px; color:#94a3b8; margin:0; }

/* 卡片 */
.gu-card {
    background:#fff; border-radius:16px; border:1px solid #e8ecf1;
    box-shadow:0 2px 8px rgba(0,0,0,.04); padding:32px 36px; margin-bottom:16px;
}
.gu-card-title {
    font-size:15px; font-weight:700; color:#0f172a;
    margin:0 0 6px; display:flex; align-items:center; gap:8px;
}
.gu-card-title svg { width:18px; height:18px; stroke:#0ea5e9; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.gu-card-sub { font-size:12px; color:#94a3b8; margin:0 0 20px; }

/* 表单 */
.gu-form { display:flex; flex-direction:column; gap:20px; }
.gu-field { display:flex; flex-direction:column; gap:6px; }
.gu-field label { font-size:12px; font-weight:600; color:#374151; display:flex; align-items:center; gap:5px; }
.gu-field label .req { color:#ef4444; }
.gu-field label .tip { font-size:11px; color:#94a3b8; font-weight:400; }
.gu-input {
    padding:9px 12px; border:1.5px solid #e2e8f0; border-radius:9px;
    font-size:13px; font-family:inherit; outline:none; transition:all .2s;
    width:100%; box-sizing:border-box; color:#1e293b; background:#fff;
}
.gu-input:focus { border-color:#38bdf8; box-shadow:0 0 0 3px rgba(56,189,248,.12); }
.gu-row { display:grid; grid-template-columns:1fr 1fr; gap:24px; }

/* 提示框 */
.gu-tip {
    background:#f0f9ff; border:1px solid #bae6fd; border-radius:9px;
    padding:11px 14px; font-size:12px; color:#0369a1; line-height:1.7;
}
.gu-tip strong { color:#0284c7; }

/* 进度 */
.gu-progress { display:none; }
.gu-progress.show { display:block; }
.gu-progress-bar-wrap {
    height:8px; background:#e0f2fe; border-radius:999px; overflow:hidden; margin-bottom:8px;
}
.gu-progress-bar {
    height:100%; border-radius:999px;
    background:linear-gradient(90deg,#0ea5e9,#38bdf8);
    width:100%; transition:width .3s;
    animation:guPulse 1s ease-in-out infinite;
}
@keyframes guPulse { 0%,100%{opacity:1} 50%{opacity:.7} }
.gu-progress-text { font-size:12px; color:#0369a1; font-weight:500; }

/* 结果 */
.gu-result { display:none; border-radius:12px; padding:18px 20px; margin-top:16px; width:100%; box-sizing:border-box; }
.gu-result.show { display:block; }
.gu-result.ok  { background:#f0fdf4; border:1px solid #bbf7d0; }
.gu-result.err { background:#fff1f2; border:1px solid #fecdd3; }
.gu-result-title {
    font-size:14px; font-weight:700; display:flex; align-items:center; gap:8px; margin-bottom:10px;
    flex-wrap:wrap;
}
.gu-result.ok  .gu-result-title { color:#166534; }
.gu-result.err .gu-result-title { color:#991b1b; }
.gu-result-title svg { width:18px; height:18px; stroke:currentColor; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
.gu-result-msg { font-size:13px; font-weight:400; line-height:1.5; }
.gu-result-link { margin-top:32px; display:flex; flex-wrap:wrap; gap:8px; align-items:center; }
.gu-result-link a {
    display:inline-flex; align-items:center; gap:6px; flex-shrink:0;
    padding:7px 16px; border-radius:8px; background:#0ea5e9; color:#fff;
    font-size:12px; font-weight:600; text-decoration:none; transition:all .15s;
    white-space:nowrap;
}
.gu-result-link a:hover { background:#0284c7; }
.gu-result-link a.sec { background:#e0f2fe; color:#0369a1; }
.gu-result-link a.sec:hover { background:#bae6fd; }
.gu-result-link a svg { width:13px; height:13px; stroke:currentColor; fill:none; stroke-width:2.5; stroke-linecap:round; }

/* 提交按钮 */
.gu-submit-row { display:flex; align-items:center; justify-content:flex-end; gap:12px; padding-top:4px; }
.gu-btn-submit {
    padding:10px 28px; background:linear-gradient(135deg,#0ea5e9,#38bdf8);
    color:#fff; border:none; border-radius:9px; font-size:14px; font-weight:600;
    cursor:pointer; font-family:inherit; display:flex; align-items:center; gap:8px;
    box-shadow:0 2px 8px rgba(14,165,233,.28); transition:all .15s;
}
.gu-btn-submit:hover { box-shadow:0 4px 14px rgba(14,165,233,.38); transform:translateY(-1px); }
.gu-btn-submit:disabled { opacity:.6; transform:none; box-shadow:none; cursor:not-allowed; }
.gu-btn-submit svg { width:16px; height:16px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
.gu-btn-back {
    padding:10px 20px; background:#f1f5f9; color:#475569; border:none; border-radius:9px;
    font-size:13px; font-weight:600; cursor:pointer; font-family:inherit; transition:all .15s; text-decoration:none;
    display:inline-flex; align-items:center; gap:6px;
}
.gu-btn-back:hover { background:#e2e8f0; }
.gu-btn-back svg { width:15px; height:15px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }

@media(max-width:700px){ .gu-row { grid-template-columns:1fr; } }
@media(max-width:900px){ .gu-card { padding:24px 20px; } }
@media(max-width:500px){ .gu-card { padding:16px 14px; } .gu-result { padding:14px 16px; } }
</style>

<div class="gu">
    <!-- 页头 -->
    <div class="gu-hd">
        <div class="gu-hd-icon">
            <svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
        </div>
        <div>
            <h2 class="gu-hd-title">添加游戏</h2>
            <p class="gu-hd-sub">注册已存在于服务器的游戏，或外部游戏链接</p>
        </div>
    </div>

    <!-- 添加链接游戏 -->
    <div class="gu-card">
        <div class="gu-card-title">
            <svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
            添加链接游戏
        </div>
        <p class="gu-card-sub">注册已存在于服务器的游戏，或外部游戏链接（无需上传文件）</p>

        <div class="gu-form">
            <div class="gu-row">
                <div class="gu-field">
                    <label>游戏名称 <span class="req">*</span></label>
                    <input type="text" class="gu-input" id="linkGameName" placeholder="例如：五子棋" maxlength="100" />
                </div>
                <div class="gu-field">
                    <label>备注说明 <span class="tip">（可选）</span></label>
                    <input type="text" class="gu-input" id="linkDesc" placeholder="游戏简介…" maxlength="200" />
                </div>
            </div>

            <div class="gu-field">
                <label>游戏链接 <span class="req">*</span></label>
                <input type="text" class="gu-input" id="linkUrl"
                    placeholder="本站路径如 /wuziqi/index.html，或外链如 https://example.com/game"
                    maxlength="500" />
            </div>

            <div class="gu-tip">
                <strong>常用本站游戏路径参考：</strong><br/>
                推箱子：<code>/sokoban/index.aspx</code>　
                五子棋：<code>/wuziqi/index.html</code>　
                打字：<code>/ztype/index.html</code>　
                钢琴：<code>/Piano/index.html</code><br/>
                Scratch：<code>/scratch/index.html</code>　
                Python：<code>/python/index.html</code>　
                推方块：<code>/blockly/index.html</code>
            </div>

            <!-- 进度/结果 -->
            <div class="gu-progress" id="linkProgress">
                <div class="gu-progress-bar-wrap"><div class="gu-progress-bar"></div></div>
                <div class="gu-progress-text">正在保存…</div>
            </div>
            <div class="gu-result" id="linkResult">
                <div class="gu-result-title">
                    <svg id="linkResultIco" viewBox="0 0 24 24"></svg>
                    <span id="linkResultTitle"></span>
                    <span id="linkResultMsg" class="gu-result-msg"></span>
                </div>
                <div class="gu-result-link" id="linkResultLink"></div>
            </div>

            <div class="gu-submit-row">
                <a href="../teacher/gamemanage.aspx" class="gu-btn-back">
                    <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                    返回游戏管理
                </a>
                <button type="button" class="gu-btn-submit" id="linkSubmitBtn" onclick="doAddLink()">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    添加游戏
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
// ── 显示结果 ─────────────────────────────────────────────────
function showResult(ok, title, msg, linkHtml){
    var r = document.getElementById('linkResult');
    r.className = 'gu-result show ' + (ok ? 'ok' : 'err');
    document.getElementById('linkResultIco').innerHTML = ok
        ? '<polyline points="20 6 9 17 4 12"/>'
        : '<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>';
    document.getElementById('linkResultTitle').textContent = title;
    document.getElementById('linkResultMsg').textContent   = msg;
    document.getElementById('linkResultLink').innerHTML    = linkHtml || '';
}

function doAddLink(){
    var name    = document.getElementById('linkGameName').value.trim();
    var url     = document.getElementById('linkUrl').value.trim();
    var desc    = document.getElementById('linkDesc').value.trim();

    document.getElementById('linkResult').className = 'gu-result';

    if(!name){ showResult(false, '请填写游戏名称', '', ''); return; }
    if(!url)  { showResult(false, '请填写游戏链接', '', ''); return; }

    var btn  = document.getElementById('linkSubmitBtn');
    var prog = document.getElementById('linkProgress');
    btn.disabled = true;
    prog.className = 'gu-progress show';

    var fd = new FormData();
    fd.append('action', 'addlink');
    fd.append('name',   name);
    fd.append('url',    url);
    fd.append('desc',   desc);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '../teacher/gamesave.ashx', true);
    xhr.onreadystatechange = function(){
        if(xhr.readyState !== 4) return;
        prog.className = 'gu-progress';
        btn.disabled   = false;
        var r;
        try{ r = JSON.parse(xhr.responseText); }
        catch(e){ r = {ok:false, msg:'服务器响应异常'}; }
        if(r.ok){
            showResult(true, '添加成功！',
                '游戏《' + name + '》已成功添加。',
                '<a href="'+url+'" target="_blank"><svg viewBox="0 0 24 24" style="width:13px;height:13px;stroke:#fff;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>预览游戏</a>'
                + '<a href="../teacher/gamemanage.aspx" class="sec"><svg viewBox="0 0 24 24" style="width:13px;height:13px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;"><rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/></svg>游戏管理</a>'
            );
            document.getElementById('linkGameName').value = '';
            document.getElementById('linkUrl').value      = '';
            document.getElementById('linkDesc').value     = '';
        } else {
            showResult(false, '添加失败', r.msg || '未知错误', '');
        }
    };
    xhr.send(fd);
}
</script>
</asp:Content>
