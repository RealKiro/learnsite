<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typeadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ta-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    /* 页面标题 */
    .ta-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .ta-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .ta-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .ta-title .ta-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#10b981,#34d399);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .ta-title .ta-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ta-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .ta-back {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; height: 36px;
    }
    .ta-back:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .ta-back svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 卡片 */
    .ta-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .ta-card-body { padding: 24px; }

    /* 标签页 */
    .ta-tabs {
        display: flex; border-bottom: 2px solid #f1f5f9; padding: 0 24px;
        background: #fafbfc;
    }
    .ta-tab {
        padding: 14px 24px; font-size: 14px; font-weight: 500; color: #94a3b8;
        cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px;
        transition: all .15s; display: flex; align-items: center; gap: 8px;
        user-select: none;
    }
    .ta-tab:hover { color: #64748b; }
    .ta-tab.active { color: #6366f1; border-bottom-color: #6366f1; font-weight: 600; }
    .ta-tab svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ta-tab-panel { display: none; }
    .ta-tab-panel.active { display: block; }

    /* 表单 */
    .ta-form-group { margin-bottom: 18px; }
    .ta-form-label {
        display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px;
    }
    .ta-form-hint { font-size: 12px; color: #94a3b8; font-weight: 400; margin-left: 6px; }
    .ta-input {
        width: 100%; padding: 9px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; font-family: inherit;
    }
    .ta-input:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .ta-textarea {
        width: 100%; min-height: 200px; padding: 12px 14px; border-radius: 8px;
        border: 1px solid #e2e8f0; font-size: 14px; color: #334155; background: #fff;
        outline: none; transition: border-color .15s; font-family: inherit;
        resize: vertical; line-height: 1.7;
    }
    .ta-textarea:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .ta-char-count { font-size: 12px; color: #94a3b8; margin-top: 4px; text-align: right; }
    .ta-char-count .over { color: #ef4444; font-weight: 600; }

    /* 按钮 */
    .ta-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 22px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 38px; line-height: 1;
    }
    .ta-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .ta-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.18);
    }
    .ta-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.28); color: #fff; }
    .ta-btn-green {
        background: linear-gradient(135deg,#10b981,#34d399); color: #fff;
        border-color: #10b981; box-shadow: 0 2px 8px rgba(16,185,129,.18);
    }
    .ta-btn-green:hover { background: linear-gradient(135deg,#059669,#10b981); border-color: #059669; box-shadow: 0 4px 12px rgba(16,185,129,.28); color: #fff; }
    .ta-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ta-btn-actions { display: flex; gap: 10px; margin-top: 20px; }

    /* 提示 */
    .ta-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px; margin-bottom: 18px;
        background: #eef2ff; border: 1px solid #e0e7ff; font-size: 13px; color: #4338ca; line-height: 1.6;
    }
    .ta-tip svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }
    .ta-tip-green { background: #ecfdf5; border-color: #d1fae5; color: #065f46; }
    .ta-tip-green svg { stroke: #10b981; }
    .ta-tip-amber { background: #fffbeb; border-color: #fef3c7; color: #92400e; }
    .ta-tip-amber svg { stroke: #f59e0b; }

    /* 文件上传区 */
    .ta-dropzone {
        border: 2px dashed #d1d5db; border-radius: 10px; padding: 36px 20px;
        text-align: center; cursor: pointer; transition: all .2s;
        background: #fafbfc; margin-bottom: 18px;
    }
    .ta-dropzone:hover, .ta-dropzone.dragover { border-color: #818cf8; background: #eef2ff; }
    .ta-dropzone svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; margin-bottom: 10px; }
    .ta-dropzone:hover svg, .ta-dropzone.dragover svg { stroke: #6366f1; }
    .ta-dropzone-text { font-size: 14px; color: #64748b; }
    .ta-dropzone-hint { font-size: 12px; color: #94a3b8; margin-top: 4px; }
    .ta-dropzone-btn {
        display: inline-flex; align-items: center; gap: 6px; margin-top: 12px;
        padding: 7px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #6366f1;
        cursor: pointer; transition: all .15s;
    }
    .ta-dropzone-btn:hover { background: #eef2ff; border-color: #c7d2fe; }

    /* 批量导入预览列表 */
    .ta-batch-list { max-height: 400px; overflow-y: auto; margin-top: 16px; }
    .ta-batch-item {
        display: flex; align-items: flex-start; gap: 14px; padding: 14px 16px;
        border: 1px solid #f1f5f9; border-radius: 8px; margin-bottom: 8px;
        transition: all .15s; background: #fff;
    }
    .ta-batch-item:hover { border-color: #e0e7ff; background: #fafbff; }
    .ta-batch-num {
        width: 28px; height: 28px; border-radius: 50%; background: #eef2ff;
        color: #6366f1; font-size: 12px; font-weight: 700;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .ta-batch-content { flex: 1; min-width: 0; }
    .ta-batch-title { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 4px; }
    .ta-batch-text {
        font-size: 12px; color: #64748b; line-height: 1.5;
        overflow: hidden; text-overflow: ellipsis; display: -webkit-box;
        -webkit-line-clamp: 2; -webkit-box-orient: vertical;
    }
    .ta-batch-meta { font-size: 11px; color: #94a3b8; margin-top: 4px; }
    .ta-batch-remove {
        width: 24px; height: 24px; border: none; background: none; cursor: pointer;
        color: #cbd5e1; transition: color .15s; display: flex; align-items: center;
        justify-content: center; flex-shrink: 0; margin-top: 2px;
    }
    .ta-batch-remove:hover { color: #ef4444; }
    .ta-batch-remove svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }

    .ta-batch-status {
        padding: 14px 16px; border-radius: 8px; margin-top: 14px;
        font-size: 13px; display: none;
    }
    .ta-batch-status.show { display: flex; align-items: center; gap: 10px; }
    .ta-batch-status.success { background: #ecfdf5; color: #065f46; border: 1px solid #d1fae5; }
    .ta-batch-status.progress { background: #eef2ff; color: #4338ca; border: 1px solid #e0e7ff; }
    .ta-batch-status.error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

    /* 消息 */
    .ta-msg { min-height: 20px; }
</style>

<div class="ta-page">
    <!-- 页面标题 -->
    <div class="ta-header">
        <div class="ta-title-wrap">
            <div class="ta-title">
                <span class="ta-icon">
                    <svg viewBox="0 0 24 24"><path d="M12 5v14"/><path d="M5 12h14"/></svg>
                </span>
                添加打字练习文章
            </div>
            <div class="ta-subtitle">支持手动输入、从TXT文件导入单篇文章，或批量导入多篇文章（每篇不超过210个汉字）</div>
        </div>
        <a href="typer.aspx" class="ta-back">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回打字管理
        </a>
    </div>

    <!-- 主卡片 -->
    <div class="ta-card">
        <!-- 标签页导航 -->
        <div class="ta-tabs">
            <div class="ta-tab active" onclick="switchTab('manual')">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                手动添加
            </div>
            <div class="ta-tab" onclick="switchTab('import')">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                从TXT导入
            </div>
            <div class="ta-tab" onclick="switchTab('batch')">
                <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="2" ry="2"/><line x1="8" y1="6" x2="16" y2="6"/><line x1="8" y1="10" x2="16" y2="10"/><line x1="8" y1="14" x2="12" y2="14"/></svg>
                批量导入
            </div>
        </div>

        <!-- 标签页 1：手动添加 -->
        <div id="panel-manual" class="ta-tab-panel active">
            <div class="ta-card-body">
                <div class="ta-tip">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>系统限制每篇文章最多 <strong>210个汉字</strong>，添加时会自动去除空格并裁剪超出部分。请确保输入的是纯文本内容，如有特殊格式可点击「清除格式」按钮。</div>
                </div>
                <div class="ta-form-group">
                    <label class="ta-form-label">文章标题 <span class="ta-form-hint">必填，为文章起一个简短的名称</span></label>
                    <asp:TextBox ID="Ttitle" runat="server" CssClass="ta-input" MaxLength="50"
                        placeholder="请输入文章标题，例如：春天的故事"></asp:TextBox>
                </div>
                <div class="ta-form-group">
                    <label class="ta-form-label">文章内容 <span class="ta-form-hint">最多210个汉字</span></label>
                    <asp:TextBox ID="Tcontent" runat="server" TextMode="MultiLine" CssClass="ta-textarea"
                        MaxLength="300" placeholder="请输入或粘贴文章内容..."
                        onkeyup="updateCharCount()"></asp:TextBox>
                    <div class="ta-char-count" id="charCount">已输入 <span id="charNum">0</span>/210 字</div>
                </div>
                <div class="ta-msg">
                    <asp:Label ID="Labelmsg" runat="server" ForeColor="#6366f1" Font-Size="12px"></asp:Label>
                </div>
                <div class="ta-btn-actions">
                    <asp:Button ID="BtnAdd" runat="server" Text="添加文章" OnClick="BtnAdd_Click"
                        CssClass="ta-btn ta-btn-primary" />
                    <asp:Button ID="BtnNoSet" runat="server" Text="清除格式" OnClick="BtnNoSet_Click"
                        CssClass="ta-btn" ToolTip="清除文本中的特殊格式和多余空格" />
                    <asp:Button ID="Btnreturn" runat="server" Text="返回列表" OnClick="Btnreturn_Click"
                        CssClass="ta-btn" />
                </div>
            </div>
        </div>

        <!-- 标签页 2：从TXT导入 -->
        <div id="panel-import" class="ta-tab-panel">
            <div class="ta-card-body">
                <div class="ta-tip ta-tip-green">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>从本地选择一个 <strong>.txt 文本文件</strong>，系统会自动读取文件名作为标题、文件内容作为文章内容填入表单。确认无误后点击「添加文章」保存。</div>
                </div>
                <div class="ta-dropzone" id="dropzoneSingle" onclick="document.getElementById('fileSingle').click()">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <div class="ta-dropzone-text">点击选择或拖拽 TXT 文件到此处</div>
                    <div class="ta-dropzone-hint">支持 .txt 格式，文件内容将自动填入上方表单</div>
                    <div class="ta-dropzone-btn">选择文件</div>
                </div>
                <input type="file" id="fileSingle" accept=".txt" style="display:none" onchange="handleSingleFile(this)" />
                <div id="importPreview" style="display:none;">
                    <div class="ta-form-group">
                        <label class="ta-form-label">导入预览</label>
                        <div class="ta-batch-item">
                            <div class="ta-batch-num">✓</div>
                            <div class="ta-batch-content">
                                <div class="ta-batch-title" id="importTitle"></div>
                                <div class="ta-batch-text" id="importText"></div>
                                <div class="ta-batch-meta" id="importMeta"></div>
                            </div>
                        </div>
                    </div>
                    <div class="ta-tip ta-tip-amber">
                        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <div>文件内容已填入「手动添加」表单，请切换到「手动添加」标签页检查并点击「添加文章」保存。</div>
                    </div>
                    <button type="button" class="ta-btn ta-btn-primary" onclick="switchTab('manual')">  去手动添加页提交</button>
                </div>
            </div>
        </div>

        <!-- 标签页 3：批量导入 -->
        <div id="panel-batch" class="ta-tab-panel">
            <div class="ta-card-body">
                <div class="ta-tip ta-tip-green">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>
                        准备一个 <strong>.txt 文本文件</strong>，每篇文章用一行 <code style="background:#d1fae5;padding:1px 6px;border-radius:4px;">---</code> 分隔。格式示例：<br />
                        <code style="display:block;margin-top:8px;padding:10px 14px;background:#f0fdf4;border-radius:6px;font-size:12px;line-height:1.8;color:#065f46;">
                        春天的故事<br/>
                        春天来了，小草从地里探出了头，花儿也开了...<br/>
                        ---<br/>
                        夏日风光<br/>
                        夏天的太阳照射着大地，知了在树上欢快地歌唱...
                        </code>
                        第一行为标题，第二行起为文章内容，三个横线 <code style="background:#d1fae5;padding:1px 6px;border-radius:4px;">---</code> 表示下一篇。
                    </div>
                </div>
                <div class="ta-dropzone" id="dropzoneBatch" onclick="document.getElementById('fileBatch').click()">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <div class="ta-dropzone-text">点击选择或拖拽 TXT 文件到此处（含多篇文章）</div>
                    <div class="ta-dropzone-hint">支持 .txt 格式，多篇文章用 --- 分隔</div>
                    <div class="ta-dropzone-btn">选择文件</div>
                </div>
                <input type="file" id="fileBatch" accept=".txt" style="display:none" onchange="handleBatchFile(this)" />

                <div id="batchPreview" style="display:none;">
                    <div class="ta-form-group">
                        <label class="ta-form-label">解析结果 <span class="ta-form-hint" id="batchCount"></span></label>
                    </div>
                    <div class="ta-batch-list" id="batchList"></div>
                    <div class="ta-batch-status" id="batchStatus"></div>
                    <div class="ta-btn-actions">
                        <button type="button" class="ta-btn ta-btn-green" id="btnBatchSubmit" onclick="startBatchImport()">
                            <svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
                            开始批量导入
                        </button>
                        <button type="button" class="ta-btn" onclick="clearBatch()">清除列表</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    // === 标签页切换 ===
    function switchTab(name) {
        var tabs = document.querySelectorAll('.ta-tab');
        var panels = document.querySelectorAll('.ta-tab-panel');
        for (var i = 0; i < tabs.length; i++) tabs[i].className = 'ta-tab';
        for (var i = 0; i < panels.length; i++) panels[i].className = 'ta-tab-panel';
        if (name === 'manual') { tabs[0].className = 'ta-tab active'; }
        else if (name === 'import') { tabs[1].className = 'ta-tab active'; }
        else if (name === 'batch') { tabs[2].className = 'ta-tab active'; }
        document.getElementById('panel-' + name).className = 'ta-tab-panel active';
    }

    // === 字数统计 ===
    function updateCharCount() {
        var el = document.querySelector('textarea[id$="Tcontent"]');
        if (!el) return;
        var len = el.value.replace(/\s/g, '').length;
        var numEl = document.getElementById('charNum');
        if (numEl) {
            numEl.textContent = len;
            numEl.className = len > 210 ? 'over' : '';
        }
    }
    // 初始化
    setTimeout(updateCharCount, 300);

    // === 单文件导入 ===
    function handleSingleFile(input) {
        if (!input.files || !input.files[0]) return;
        var file = input.files[0];
        var fname = file.name.replace(/\.txt$/i, '');
        var reader = new FileReader();
        reader.onload = function (e) {
            var text = e.target.result.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
            text = text.replace(/\s+/g, '').substring(0, 210);
            // 填入表单
            var titleEl = document.querySelector('input[id$="Ttitle"]');
            var contentEl = document.querySelector('textarea[id$="Tcontent"]');
            if (titleEl) titleEl.value = fname;
            if (contentEl) contentEl.value = text;
            updateCharCount();
            // 显示预览
            document.getElementById('importPreview').style.display = 'block';
            document.getElementById('importTitle').textContent = fname;
            document.getElementById('importText').textContent = text.substring(0, 100) + (text.length > 100 ? '...' : '');
            document.getElementById('importMeta').textContent = text.length + ' 个字符';
        };
        reader.readAsText(file, 'UTF-8');
    }

    // === 拖拽支持 ===
    function setupDropzone(id, handler) {
        var dz = document.getElementById(id);
        if (!dz) return;
        dz.addEventListener('dragover', function (e) { e.preventDefault(); dz.classList.add('dragover'); });
        dz.addEventListener('dragleave', function () { dz.classList.remove('dragover'); });
        dz.addEventListener('drop', function (e) {
            e.preventDefault(); dz.classList.remove('dragover');
            if (e.dataTransfer.files && e.dataTransfer.files[0]) handler({ files: e.dataTransfer.files });
        });
    }
    setupDropzone('dropzoneSingle', handleSingleFile);
    setupDropzone('dropzoneBatch', handleBatchFile);

    // === 批量导入 ===
    var batchArticles = [];

    function handleBatchFile(input) {
        if (!input.files || !input.files[0]) return;
        var reader = new FileReader();
        reader.onload = function (e) {
            var text = e.target.result.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
            var blocks = text.split(/\n---\n|\n---$/);
            batchArticles = [];
            for (var i = 0; i < blocks.length; i++) {
                var block = blocks[i].trim();
                if (!block) continue;
                var lines = block.split('\n');
                var title = lines[0].trim();
                var content = lines.slice(1).join('').replace(/\s+/g, '').substring(0, 210);
                if (title && content) {
                    batchArticles.push({ title: title, content: content });
                }
            }
            renderBatchList();
        };
        reader.readAsText(input.files[0], 'UTF-8');
    }

    function renderBatchList() {
        var list = document.getElementById('batchList');
        var html = '';
        for (var i = 0; i < batchArticles.length; i++) {
            var a = batchArticles[i];
            html += '<div class="ta-batch-item" id="batch-' + i + '">' +
                '<div class="ta-batch-num">' + (i + 1) + '</div>' +
                '<div class="ta-batch-content">' +
                '<div class="ta-batch-title">' + escHtml(a.title) + '</div>' +
                '<div class="ta-batch-text">' + escHtml(a.content.substring(0, 80)) + (a.content.length > 80 ? '...' : '') + '</div>' +
                '<div class="ta-batch-meta">' + a.content.length + ' 个字符</div>' +
                '</div>' +
                '<button type="button" class="ta-batch-remove" onclick="removeBatchItem(' + i + ')" title="移除">' +
                '<svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>' +
                '</div>';
        }
        list.innerHTML = html;
        document.getElementById('batchCount').textContent = '共解析出 ' + batchArticles.length + ' 篇文章';
        document.getElementById('batchPreview').style.display = batchArticles.length > 0 ? 'block' : 'none';
        setBatchStatus('', '');
    }

    function removeBatchItem(idx) {
        batchArticles.splice(idx, 1);
        renderBatchList();
    }

    function clearBatch() {
        batchArticles = [];
        renderBatchList();
        document.getElementById('fileBatch').value = '';
    }

    function escHtml(s) {
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(s));
        return d.innerHTML;
    }

    function setBatchStatus(msg, type) {
        var el = document.getElementById('batchStatus');
        if (!msg) { el.className = 'ta-batch-status'; return; }
        el.className = 'ta-batch-status show ' + type;
        el.innerHTML = msg;
    }

    // 批量提交：透过填写表单逐条提交
    var batchIndex = 0;
    var batchSuccess = 0;

    function startBatchImport() {
        if (batchArticles.length === 0) return;
        batchIndex = 0;
        batchSuccess = 0;
        document.getElementById('btnBatchSubmit').disabled = true;
        submitNextArticle();
    }

    function submitNextArticle() {
        if (batchIndex >= batchArticles.length) {
            setBatchStatus('✅ 批量导入完成！成功导入 ' + batchSuccess + ' 篇文章。<a href="typer.aspx" style="color:inherit;font-weight:600;margin-left:8px;">返回文章列表查看 →</a>', 'success');
            document.getElementById('btnBatchSubmit').disabled = false;
            return;
        }
        var a = batchArticles[batchIndex];
        setBatchStatus('⏳ 正在导入第 ' + (batchIndex + 1) + '/' + batchArticles.length + ' 篇：' + escHtml(a.title), 'progress');

        // 高亮当前项
        var items = document.querySelectorAll('.ta-batch-item');
        for (var i = 0; i < items.length; i++) items[i].style.borderColor = '';
        var cur = document.getElementById('batch-' + batchIndex);
        if (cur) { cur.style.borderColor = '#818cf8'; cur.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }

        // 填写表单并提交
        var titleEl = document.querySelector('input[id$="Ttitle"]');
        var contentEl = document.querySelector('textarea[id$="Tcontent"]');
        if (titleEl) titleEl.value = a.title;
        if (contentEl) contentEl.value = a.content;

        // 触发服务端添加按钮
        setTimeout(function () {
            var addBtn = document.querySelector('input[id$="BtnAdd"]');
            if (addBtn) {
                // 通过 __doPostBack 提交
                var btnName = addBtn.name;
                __doPostBack(btnName, '');
            }
        }, 200);
    }

    // 页面加载后检查是否在批量导入中
    (function () {
        try {
            var stored = sessionStorage.getItem('batchImport');
            if (stored) {
                var data = JSON.parse(stored);
                batchArticles = data.articles || [];
                batchIndex = data.index + 1;
                batchSuccess = data.success + 1;
                if (batchIndex < batchArticles.length) {
                    switchTab('batch');
                    renderBatchList();
                    sessionStorage.setItem('batchImport', JSON.stringify({
                        articles: batchArticles, index: batchIndex, success: batchSuccess
                    }));
                    setTimeout(submitNextArticle, 500);
                } else {
                    switchTab('batch');
                    renderBatchList();
                    setBatchStatus('✅ 批量导入完成！成功导入 ' + batchSuccess + ' 篇文章。<a href="typer.aspx" style="color:inherit;font-weight:600;margin-left:8px;">返回文章列表查看 →</a>', 'success');
                    sessionStorage.removeItem('batchImport');
                }
            }
        } catch (e) { }
    })();

    // 重写 startBatchImport 使用 sessionStorage
    function startBatchImport() {
        if (batchArticles.length === 0) return;
        batchIndex = 0;
        batchSuccess = 0;
        sessionStorage.setItem('batchImport', JSON.stringify({
            articles: batchArticles, index: 0, success: 0
        }));
        submitNextArticle();
    }

    function submitNextArticle() {
        if (batchIndex >= batchArticles.length) {
            sessionStorage.removeItem('batchImport');
            setBatchStatus('✅ 批量导入完成！成功导入 ' + batchSuccess + ' 篇文章。<a href="typer.aspx" style="color:inherit;font-weight:600;margin-left:8px;">返回文章列表查看 →</a>', 'success');
            return;
        }
        var a = batchArticles[batchIndex];
        setBatchStatus('⏳ 正在导入第 ' + (batchIndex + 1) + '/' + batchArticles.length + ' 篇：' + escHtml(a.title), 'progress');

        var titleEl = document.querySelector('input[id$="Ttitle"]');
        var contentEl = document.querySelector('textarea[id$="Tcontent"]');
        if (titleEl) titleEl.value = a.title;
        if (contentEl) contentEl.value = a.content;

        sessionStorage.setItem('batchImport', JSON.stringify({
            articles: batchArticles, index: batchIndex, success: batchSuccess
        }));

        setTimeout(function () {
            var addBtn = document.querySelector('input[id$="BtnAdd"]');
            if (addBtn) __doPostBack(addBtn.name, '');
        }, 300);
    }
</script>
</asp:Content>

