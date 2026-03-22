<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Quiz_quizadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== 简洁题目编辑器 ===== */
    .qa-wrap { max-width: 98%; margin: 0 auto; padding: 12px 16px 40px; }

    /* 页头 */
    .qa-header {
        display: flex; align-items: center; gap: 12px;
        margin-bottom: 16px; padding-bottom: 12px;
        border-bottom: 2px solid #eef0f8;
    }
    .qa-header-icon {
        width: 36px; height: 36px; border-radius: 10px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 3px 10px rgba(99,102,241,0.15);
    }
    .qa-header-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .qa-header-title { font-size: 19px; font-weight: 700; color: #1e293b; }

    /* 设置栏 */
    .qa-settings {
        display: flex; flex-wrap: wrap; gap: 20px; align-items: center;
        margin-bottom: 14px; padding: 10px 20px;
        background: #fff; border-radius: 10px;
        border: 1px solid #eef0f5;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    }
    .qa-set { display: flex; align-items: center; gap: 8px; }
    .qa-set .s-label { font-size: 13px; font-weight: 600; color: #64748b; white-space: nowrap; }
    .qa-set select {
        padding: 6px 12px; border: 1px solid #e2e8f0; border-radius: 6px;
        font-size: 13px; color: #334155; background: #fafbfc;
        outline: none; cursor: pointer; transition: border-color 0.2s;
    }
    .qa-set select:focus { border-color: #6366f1; box-shadow: 0 0 0 2px rgba(99,102,241,0.1); }

    /* 主卡片 */
    .qa-main {
        background: #fff; border-radius: 12px;
        border: 1px solid #eef0f5;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
    }

    /* 题干区域 */
    .qa-question { padding: 22px 28px 18px; }
    .qa-q-label {
        font-size: 14px; font-weight: 600; color: #1e293b;
        margin-bottom: 12px; display: flex; align-items: center; gap: 4px;
    }
    .qa-q-label .req { color: #ef4444; font-size: 16px; line-height: 1; }

    /* KindEditor 样式 */
    .qa-question .ke-container {
        border-radius: 8px !important; border: 1px solid #e2e8f0 !important;
        overflow: hidden; transition: border-color 0.2s, box-shadow 0.2s;
    }
    .qa-question .ke-container:focus-within {
        border-color: #818cf8 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.08);
    }
    .qa-question .ke-toolbar {
        background: #f8f9fc !important;
        border-bottom: 1px solid #e8eaef !important;
        padding: 4px 6px !important;
    }
    .qa-question .ke-toolbar .ke-outline {
        border-radius: 4px !important; border: 1px solid transparent !important;
        padding: 2px !important; margin: 1px !important;
    }
    .qa-question .ke-toolbar .ke-outline:hover { background: #e8eaef !important; }
    .qa-question .ke-toolbar .ke-on { background: #ddd6fe !important; }
    .qa-question .ke-toolbar .ke-separator { background: #e2e8f0 !important; width: 1px !important; }
    .qa-question .ke-edit { background: #fff !important; }
    .qa-question .ke-statusbar {
        background: #f8f9fc !important; border-top: 1px solid #f0f2f5 !important;
        height: 14px !important;
    }

    /* 分割线 */
    .qa-div { height: 1px; background: #f0f2f5; margin: 0 28px; }

    /* 选项区域 */
    .qa-options { padding: 18px 28px 20px; }
    .qa-opt-hint {
        font-size: 12px; color: #94a3b8; margin-bottom: 14px;
        display: flex; align-items: center; gap: 6px;
    }
    .qa-opt-hint svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .qa-opt {
        display: flex; align-items: center; gap: 14px;
        padding: 11px 16px; margin-bottom: 6px; border-radius: 8px;
        border: 1.5px solid transparent; cursor: pointer;
        transition: all 0.18s;
    }
    .qa-opt:last-child { margin-bottom: 0; }
    .qa-opt:hover { background: #f8f9fc; }
    .qa-opt.active { background: #f0fdf4; border-color: #bbf7d0; }

    /* 选项指示器（圆圈） */
    .qa-oi {
        width: 20px; height: 20px; border-radius: 50%;
        border: 2px solid #cbd5e1; flex-shrink: 0;
        display: flex; align-items: center; justify-content: center;
        transition: all 0.18s; position: relative;
    }
    .qa-opt.active .qa-oi { border-color: #22c55e; background: #22c55e; }
    .qa-opt.active .qa-oi::after {
        content: ''; width: 8px; height: 8px;
        border-radius: 50%; background: #fff;
    }
    /* 多选模式方形指示器 */
    .qa-oi.check { border-radius: 4px; }
    .qa-opt.active .qa-oi.check { border-color: #6366f1; background: #6366f1; }
    .qa-opt.active .qa-oi.check::after {
        content: '✓'; width: auto; height: auto;
        background: none; border-radius: 0;
        color: #fff; font-size: 12px; font-weight: 700;
    }

    /* 选项字母 */
    .qa-ol { font-size: 15px; font-weight: 600; color: #64748b; min-width: 18px; transition: color 0.18s; }
    .qa-opt.active .qa-ol { color: #16a34a; }
    .qa-opt.active .qa-oi.check + .qa-ol { color: #4f46e5; }

    /* 选项内容区（支持图文） */
    .qa-opt-content {
        flex: 1; min-height: 26px; padding: 4px 8px;
        font-size: 14px; color: #1e293b; line-height: 1.6;
        border-bottom: 1.5px solid #e5e7eb;
        outline: none; transition: border-color 0.2s;
        word-break: break-word;
    }
    .qa-opt-content:focus { border-bottom-color: #6366f1; }
    .qa-opt-content:empty::before {
        content: attr(data-placeholder); color: #cbd5e1; pointer-events: none;
    }
    .qa-opt-content img {
        max-height: 100px; vertical-align: middle;
        margin: 2px 4px; border-radius: 4px; cursor: default;
    }
    .qa-opt-content.readonly {
        color: #64748b; cursor: default; border-bottom-style: dashed;
    }

    /* 选项操作按钮 */
    .qa-opt-btn {
        width: 28px; height: 28px; border-radius: 6px;
        border: 1px solid #e5e7eb; background: #fff;
        display: flex; align-items: center; justify-content: center;
        cursor: pointer; transition: all 0.15s; flex-shrink: 0;
    }
    .qa-opt-btn svg {
        width: 14px; height: 14px; stroke: #94a3b8; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .qa-opt-btn.img-btn:hover { border-color: #818cf8; background: #f5f3ff; }
    .qa-opt-btn.img-btn:hover svg { stroke: #6366f1; }
    .qa-opt-btn.del-btn:hover { border-color: #fca5a5; background: #fef2f2; }
    .qa-opt-btn.del-btn:hover svg { stroke: #ef4444; }

    /* 添加选项按钮 */
    .qa-add-opt {
        display: flex; align-items: center; justify-content: center; gap: 6px;
        padding: 10px; margin-top: 10px; border-radius: 8px;
        border: 1.5px dashed #d1d5db; background: transparent;
        color: #94a3b8; font-size: 13px; cursor: pointer;
        transition: all 0.18s; width: 100%;
    }
    .qa-add-opt:hover { border-color: #818cf8; color: #6366f1; background: #f5f3ff; }
    .qa-add-opt svg {
        width: 16px; height: 16px; stroke: currentColor; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* 分析区域 */
    .qa-analysis { padding: 18px 28px; }
    .qa-analysis-label { font-size: 13px; font-weight: 600; color: #64748b; margin-bottom: 8px; }
    .qa-analysis-box {
        width: 100% !important; min-height: 68px !important;
        padding: 10px 14px !important; border: 1px solid #e5e7eb !important;
        border-radius: 8px !important; font-size: 13px !important;
        color: #334155; background: #fafbfc !important; outline: none;
        resize: vertical; line-height: 1.6;
        transition: border-color 0.2s, box-shadow 0.2s;
    }
    .qa-analysis-box:focus {
        border-color: #6366f1 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.08);
        background: #fff !important;
    }
    .qa-analysis-hint { font-size: 12px; color: #94a3b8; margin-top: 6px; }

    /* 操作按钮 */
    .qa-actions {
        padding: 16px 28px 22px;
        display: flex; align-items: center; gap: 12px;
        border-top: 1px solid #f0f2f5;
    }
    .qa-btn-p input[type="submit"] {
        padding: 9px 28px !important; border: none !important;
        border-radius: 8px !important; font-size: 14px !important;
        font-weight: 600 !important; cursor: pointer;
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important; box-shadow: 0 2px 8px rgba(99,102,241,0.2);
        height: auto !important; width: auto !important; line-height: 1.5 !important;
        transition: all 0.2s;
    }
    .qa-btn-p input[type="submit"]:hover {
        box-shadow: 0 4px 14px rgba(99,102,241,0.3); transform: translateY(-1px);
    }
    .qa-btn-s input[type="submit"] {
        padding: 9px 28px !important; border: 1px solid #e2e8f0 !important;
        border-radius: 8px !important; font-size: 14px !important;
        font-weight: 500 !important; cursor: pointer;
        background: #fff !important; color: #64748b !important;
        height: auto !important; width: auto !important; line-height: 1.5 !important;
        transition: all 0.2s;
    }
    .qa-btn-s input[type="submit"]:hover {
        background: #f8fafc !important; color: #334155 !important;
        border-color: #cbd5e1 !important;
    }
    .qa-msg { padding: 0 28px 16px; font-size: 13px; }
    .qa-msg span { padding: 8px 16px; border-radius: 8px; display: inline-block; background: #fef3c7; color: #92400e; }
    .qa-msg span:empty { display: none; }

    /* 隐藏控件 */
    .qa-hidden { display: none; }

    @media (max-width: 768px) {
        .qa-wrap { padding: 8px 8px 24px; }
        .qa-settings { padding: 10px 14px; gap: 10px; }
        .qa-question, .qa-options, .qa-analysis, .qa-actions { padding-left: 16px; padding-right: 16px; }
        .qa-div { margin: 0 16px; }
    }
</style>

<script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
<script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>

<div class="qa-wrap">
    <!-- 页头 -->
    <div class="qa-header">
        <span class="qa-header-icon">
            <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </span>
        <span class="qa-header-title">添加测评题目</span>
    </div>

    <!-- 设置栏 -->
    <div class="qa-settings">
        <div class="qa-set">
            <span class="s-label">题型</span>
            <asp:DropDownList ID="DDLqtype" runat="server" AutoPostBack="True"
                Font-Size="9pt" onselectedindexchanged="DDLqtype_SelectedIndexChanged">
                <asp:ListItem Selected="True" Value="0">单选题</asp:ListItem>
                <asp:ListItem Value="1">多选题</asp:ListItem>
                <asp:ListItem Value="2">判断题</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="qa-set">
            <span class="s-label">学案</span>
            <asp:DropDownList ID="DDLclass" runat="server" Width="120px" Font-Size="9pt">
            </asp:DropDownList>
        </div>
        <div class="qa-set">
            <span class="s-label">分值</span>
            <asp:DropDownList ID="DDLqscore" runat="server" Font-Size="9pt">
                <asp:ListItem Value="1">1分</asp:ListItem>
                <asp:ListItem Selected="True" Value="2">2分</asp:ListItem>
                <asp:ListItem Value="3">3分</asp:ListItem>
                <asp:ListItem Value="4">4分</asp:ListItem>
                <asp:ListItem Value="5">5分</asp:ListItem>
                <asp:ListItem Value="6">6分</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <!-- 主编辑区 -->
    <div class="qa-main">
        <!-- 隐藏字段 -->
        <textarea name="textareaItem" id="hiddenQuizData" style="display:none;"></textarea>
        <div class="qa-hidden">
            <asp:RadioButtonList ID="RBLselect" runat="server"
                RepeatDirection="Horizontal" Visible="True" Height="35px">
                <asp:ListItem Selected="True">A</asp:ListItem>
                <asp:ListItem>B</asp:ListItem>
                <asp:ListItem>C</asp:ListItem>
                <asp:ListItem>D</asp:ListItem>
            </asp:RadioButtonList>
            <asp:CheckBoxList ID="CBLselect" runat="server" RepeatDirection="Horizontal" Visible="False">
                <asp:ListItem>A</asp:ListItem>
                <asp:ListItem>B</asp:ListItem>
                <asp:ListItem>C</asp:ListItem>
                <asp:ListItem>D</asp:ListItem>
            </asp:CheckBoxList>
            <asp:RadioButtonList ID="RBLjudge" runat="server" RepeatDirection="Horizontal" Visible="False" Height="35px">
                <asp:ListItem Selected="True">对</asp:ListItem>
                <asp:ListItem>错</asp:ListItem>
            </asp:RadioButtonList>
        </div>

        <!-- 题干 -->
        <div class="qa-question">
            <div class="qa-q-label"><span class="req">*</span> 题目内容</div>
            <textarea id="editorStem" style="width:100%; height:200px;"></textarea>
        </div>

        <div class="qa-div"></div>

        <!-- 选项 -->
        <div class="qa-options" id="optionsPanel">
            <div class="qa-opt-hint">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                点击圆圈标记正确答案 · 支持输入文字和插入图片
            </div>
            <div class="qa-opt active" data-idx="0" onclick="selectOpt(this)">
                <span class="qa-oi"></span>
                <span class="qa-ol">A</span>
                <div class="qa-opt-content" contenteditable="true" data-placeholder="输入选项A" onclick="event.stopPropagation()"></div>
                <span class="qa-opt-btn img-btn" onclick="uploadOptImg(this.parentNode,event)" title="插入图片">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                </span>
                <span class="qa-opt-btn del-btn" onclick="removeOpt(this.parentNode,event)" title="删除选项">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </span>
            </div>
            <div class="qa-opt" data-idx="1" onclick="selectOpt(this)">
                <span class="qa-oi"></span>
                <span class="qa-ol">B</span>
                <div class="qa-opt-content" contenteditable="true" data-placeholder="输入选项B" onclick="event.stopPropagation()"></div>
                <span class="qa-opt-btn img-btn" onclick="uploadOptImg(this.parentNode,event)" title="插入图片">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                </span>
                <span class="qa-opt-btn del-btn" onclick="removeOpt(this.parentNode,event)" title="删除选项">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </span>
            </div>
            <div class="qa-opt" data-idx="2" onclick="selectOpt(this)">
                <span class="qa-oi"></span>
                <span class="qa-ol">C</span>
                <div class="qa-opt-content" contenteditable="true" data-placeholder="输入选项C" onclick="event.stopPropagation()"></div>
                <span class="qa-opt-btn img-btn" onclick="uploadOptImg(this.parentNode,event)" title="插入图片">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                </span>
                <span class="qa-opt-btn del-btn" onclick="removeOpt(this.parentNode,event)" title="删除选项">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </span>
            </div>
            <div class="qa-opt" data-idx="3" onclick="selectOpt(this)">
                <span class="qa-oi"></span>
                <span class="qa-ol">D</span>
                <div class="qa-opt-content" contenteditable="true" data-placeholder="输入选项D" onclick="event.stopPropagation()"></div>
                <span class="qa-opt-btn img-btn" onclick="uploadOptImg(this.parentNode,event)" title="插入图片">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                </span>
                <span class="qa-opt-btn del-btn" onclick="removeOpt(this.parentNode,event)" title="删除选项">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </span>
            </div>
            <button type="button" class="qa-add-opt" id="addOptBtn" onclick="addOpt()">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                添加选项
            </button>
        </div>

        <div class="qa-div"></div>

        <!-- 解析 -->
        <div class="qa-analysis">
            <div class="qa-analysis-label">解析说明</div>
            <asp:TextBox ID="TextBoxqanalyze" runat="server" TextMode="MultiLine"
                CssClass="qa-analysis-box" Rows="3"></asp:TextBox>
            <div class="qa-analysis-hint">选填，填写解题思路或知识点说明</div>
        </div>

        <!-- 操作按钮 -->
        <div class="qa-actions">
            <span class="qa-btn-p">
                <asp:Button ID="Btnadd" runat="server" Text="添加题目" OnClick="Btnadd_Click" OnClientClick="return prepareSubmit();" SkinID="BtnNormal" />
            </span>
            <span class="qa-btn-s">
                <asp:Button ID="Btnreturn" runat="server" Text="返回列表" OnClick="Btnreturn_Click" SkinID="BtnNormal" />
            </span>
        </div>
        <div class="qa-msg">
            <asp:Label ID="Labelmsg" runat="server"></asp:Label>
        </div>
    </div>
</div>

<script type="text/javascript">
    var edStem;
    var _cid = '-1', _ty = 'Quiz';
    var _upjs = '../kindeditor/aspnet/upload_json.aspx?Cid=' + _cid + '&Ty=' + _ty;
    var _fmjs = '../kindeditor/aspnet/file_manager_json.aspx?Cid=' + _cid + '&Ty=' + _ty;
    var _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // 检测题型
    function isMulti() { return document.querySelectorAll('input[type="checkbox"][name$="CBLselect"]').length > 0; }
    function isJudge() { return document.querySelectorAll('input[type="radio"][name$="RBLjudge"]').length > 0; }

    // 获取可见选项
    function getVisibleOpts() {
        return Array.from(document.querySelectorAll('#optionsPanel .qa-opt')).filter(function (o) {
            return o.style.display !== 'none';
        });
    }

    // 答案选择
    function selectOpt(el) {
        var idx = parseInt(el.getAttribute('data-idx'));
        var opts = getVisibleOpts();
        if (isMulti()) {
            el.classList.toggle('active');
            var checks = document.querySelectorAll('input[type="checkbox"][name$="CBLselect"]');
            opts.forEach(function (o, i) { if (checks[i]) checks[i].checked = o.classList.contains('active'); });
        } else {
            opts.forEach(function (o) { o.classList.remove('active'); });
            el.classList.add('active');
            if (isJudge()) {
                var r = document.querySelectorAll('input[type="radio"][name$="RBLjudge"]');
                if (r[idx]) r[idx].checked = true;
            } else {
                var r = document.querySelectorAll('input[type="radio"][name$="RBLselect"]');
                if (r[idx]) r[idx].checked = true;
            }
        }
    }

    // 选项图片上传
    function uploadOptImg(optEl, e) {
        e.stopPropagation();
        var fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.accept = 'image/*';
        fileInput.style.display = 'none';
        document.body.appendChild(fileInput);
        fileInput.onchange = function () {
            if (!fileInput.files || !fileInput.files[0]) { done(); return; }
            var fd = new FormData();
            fd.append('imgFile', fileInput.files[0]);
            var xhr = new XMLHttpRequest();
            xhr.open('POST', _upjs);
            xhr.onload = function () {
                try {
                    var res = JSON.parse(xhr.responseText);
                    if (res.error === 0) {
                        var box = optEl.querySelector('.qa-opt-content');
                        if (box) {
                            var img = document.createElement('img');
                            img.src = res.url;
                            box.appendChild(img);
                            box.focus();
                        }
                    } else { alert(res.message || '上传失败'); }
                } catch (ex) { alert('上传失败'); }
                done();
            };
            xhr.onerror = function () { alert('网络错误'); done(); };
            xhr.send(fd);
        };
        function done() { if (fileInput.parentNode) fileInput.parentNode.removeChild(fileInput); }
        fileInput.click();
    }

    // 删除选项
    function removeOpt(optEl, e) {
        e.stopPropagation();
        if (getVisibleOpts().length <= 2) { alert('至少保留2个选项'); return; }
        var wasActive = optEl.classList.contains('active');
        optEl.remove();
        reindexOptions();
        if (wasActive) {
            var first = document.querySelector('#optionsPanel .qa-opt');
            if (first) { first.classList.add('active'); selectOpt(first); }
        }
    }

    // 添加选项
    function addOpt() {
        var allOpts = document.querySelectorAll('#optionsPanel .qa-opt');
        var n = allOpts.length;
        if (n >= 10) { alert('最多支持10个选项'); return; }
        var letter = _letters[n];
        var isM = isMulti();
        var checkCls = isM ? ' check' : '';

        var div = document.createElement('div');
        div.className = 'qa-opt';
        div.setAttribute('data-idx', n);
        div.setAttribute('onclick', 'selectOpt(this)');
        div.innerHTML =
            '<span class="qa-oi' + checkCls + '"></span>' +
            '<span class="qa-ol">' + letter + '</span>' +
            '<div class="qa-opt-content" contenteditable="true" data-placeholder="输入选项' + letter + '" onclick="event.stopPropagation()"></div>' +
            '<span class="qa-opt-btn img-btn" onclick="uploadOptImg(this.parentNode,event)" title="插入图片">' +
                '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>' +
            '</span>' +
            '<span class="qa-opt-btn del-btn" onclick="removeOpt(this.parentNode,event)" title="删除选项">' +
                '<svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
            '</span>';

        var addBtn = document.getElementById('addOptBtn');
        addBtn.parentNode.insertBefore(div, addBtn);
        div.querySelector('.qa-opt-content').focus();
    }

    // 重新编号
    function reindexOptions() {
        var opts = document.querySelectorAll('#optionsPanel .qa-opt');
        opts.forEach(function (o, i) {
            o.setAttribute('data-idx', i);
            var lbl = o.querySelector('.qa-ol');
            var box = o.querySelector('.qa-opt-content');
            if (lbl) lbl.textContent = _letters[i];
            if (box) box.setAttribute('data-placeholder', '输入选项' + _letters[i]);
        });
    }

    // 初始化选项显示
    function initOptions() {
        var panel = document.getElementById('optionsPanel');
        var opts = panel.querySelectorAll('.qa-opt');
        var indicators = panel.querySelectorAll('.qa-oi');
        var addBtn = document.getElementById('addOptBtn');

        if (isJudge()) {
            var labels = ['对', '错'];
            opts.forEach(function (o, i) {
                if (i < 2) {
                    o.style.display = 'flex';
                    o.querySelector('.qa-ol').textContent = labels[i];
                    var c = o.querySelector('.qa-opt-content');
                    if (c) { c.textContent = labels[i]; c.contentEditable = 'false'; c.classList.add('readonly'); }
                    o.querySelectorAll('.qa-opt-btn').forEach(function (b) { b.style.display = 'none'; });
                } else {
                    o.style.display = 'none';
                }
            });
            indicators.forEach(function (ind) { ind.className = 'qa-oi'; });
            if (addBtn) addBtn.style.display = 'none';
        } else {
            opts.forEach(function (o, i) {
                o.style.display = 'flex';
                o.querySelector('.qa-ol').textContent = _letters[i];
                var c = o.querySelector('.qa-opt-content');
                if (c) { c.contentEditable = 'true'; c.classList.remove('readonly'); c.setAttribute('data-placeholder', '输入选项' + _letters[i]); }
                o.querySelectorAll('.qa-opt-btn').forEach(function (b) { b.style.display = 'flex'; });
            });
            if (isMulti()) {
                indicators.forEach(function (ind) { ind.classList.add('check'); });
            } else {
                indicators.forEach(function (ind) { ind.classList.remove('check'); });
            }
            if (addBtn) addBtn.style.display = 'flex';
        }
        opts.forEach(function (o) { o.classList.remove('active'); });
        if (opts[0]) opts[0].classList.add('active');
    }

    // 提交前准备数据（由按钮 OnClientClick 和表单 submit 事件双重调用）
    function prepareSubmit() {
        try {
            // 先同步 KindEditor 内容到原始 textarea
            if (typeof edStem !== 'undefined' && edStem) {
                edStem.sync();
            }
            var stem = (typeof edStem !== 'undefined' && edStem) ? edStem.html() : '';
            var combined = stem || '';
            if (!isJudge()) {
                var opts = getVisibleOpts();
                var parts = [];
                opts.forEach(function (o) {
                    var letter = o.querySelector('.qa-ol').textContent;
                    var box = o.querySelector('.qa-opt-content');
                    var html = box ? box.innerHTML.trim() : '';
                    if (html === '<br>') html = '';
                    parts.push('<p>' + letter + '．' + html + '</p>');
                });
                if (parts.length > 0) {
                    combined += '<br/>' + parts.join('');
                }
            }
            // 去除纯空白内容
            var stripped = combined.replace(/<br\s*\/?>/gi, '').replace(/<p>\s*[A-Z]．\s*<\/p>/gi, '').replace(/\s+/g, '').trim();
            if (!stripped) {
                alert('请填写题目内容后再提交');
                return false;
            }
            var el = document.getElementById('hiddenQuizData');
            if (el) {
                el.value = combined;
            }
        } catch (e) {
            alert('数据准备失败: ' + e.message);
            return false;
        }
        return true;
    }

    document.addEventListener('DOMContentLoaded', initOptions);

    KindEditor.ready(function (K) {
        edStem = K.create('#editorStem', {
            resizeType: 1, newlineTag: 'br',
            uploadJson: _upjs, fileManagerJson: _fmjs, allowFileManager: true,
            filterMode: false
        });

        // 表单 submit 事件也调用一次（双保险）
        var form = document.getElementById('form1') || document.forms[0];
        if (form) {
            form.addEventListener('submit', function (e) {
                if (!prepareSubmit()) { e.preventDefault(); }
            }, true);
        }
    });
</script>
</asp:Content>

