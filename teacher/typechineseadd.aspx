<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typechineseadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .tca-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .tca-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .tca-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .tca-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .tca-title .tca-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#f59e0b,#fbbf24);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .tca-title .tca-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tca-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .tca-back {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; height: 36px;
    }
    .tca-back:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .tca-back svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .tca-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .tca-card-body { padding: 24px; }

    /* 标签页 */
    .tca-tabs {
        display: flex; border-bottom: 2px solid #f1f5f9; padding: 0 24px;
        background: #fafbfc;
    }
    .tca-tab {
        padding: 14px 24px; font-size: 14px; font-weight: 500; color: #94a3b8;
        cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px;
        transition: all .15s; display: flex; align-items: center; gap: 8px;
        user-select: none;
    }
    .tca-tab:hover { color: #64748b; }
    .tca-tab.active { color: #f59e0b; border-bottom-color: #f59e0b; font-weight: 600; }
    .tca-tab svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tca-tab-panel { display: none; }
    .tca-tab-panel.active { display: block; }

    /* 表单 */
    .tca-form-group { margin-bottom: 18px; }
    .tca-form-label {
        display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px;
    }
    .tca-form-hint { font-size: 12px; color: #94a3b8; font-weight: 400; margin-left: 6px; }
    .tca-input {
        width: 100%; padding: 9px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; font-family: inherit;
    }
    .tca-input:focus { border-color: #fbbf24; box-shadow: 0 0 0 3px rgba(245,158,11,.1); }
    .tca-textarea {
        width: 100%; min-height: 260px; padding: 12px 14px; border-radius: 8px;
        border: 1px solid #e2e8f0; font-size: 14px; color: #334155; background: #fff;
        outline: none; transition: border-color .15s; font-family: inherit;
        resize: vertical; line-height: 1.8;
    }
    .tca-textarea:focus { border-color: #fbbf24; box-shadow: 0 0 0 3px rgba(245,158,11,.1); }

    /* 按钮 */
    .tca-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 22px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 38px; line-height: 1;
    }
    .tca-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .tca-btn-primary {
        background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff;
        border-color: #f59e0b; box-shadow: 0 2px 8px rgba(245,158,11,.18);
    }
    .tca-btn-primary:hover { background: linear-gradient(135deg,#d97706,#f59e0b); border-color: #d97706; box-shadow: 0 4px 12px rgba(245,158,11,.28); color: #fff; }
    .tca-btn-green {
        background: linear-gradient(135deg,#10b981,#34d399); color: #fff;
        border-color: #10b981; box-shadow: 0 2px 8px rgba(16,185,129,.18);
    }
    .tca-btn-green:hover { background: linear-gradient(135deg,#059669,#10b981); border-color: #059669; box-shadow: 0 4px 12px rgba(16,185,129,.28); color: #fff; }
    .tca-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tca-btn-actions { display: flex; gap: 10px; margin-top: 20px; }

    /* 提示 */
    .tca-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px; margin-bottom: 18px;
        font-size: 13px; line-height: 1.6;
    }
    .tca-tip svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }
    .tca-tip-amber { background: #fffbeb; border: 1px solid #fef3c7; color: #92400e; }
    .tca-tip-amber svg { stroke: #f59e0b; }
    .tca-tip-green { background: #ecfdf5; border: 1px solid #d1fae5; color: #065f46; }
    .tca-tip-green svg { stroke: #10b981; }
    .tca-tip-blue { background: #eef2ff; border: 1px solid #e0e7ff; color: #4338ca; }
    .tca-tip-blue svg { stroke: #6366f1; }

    /* 文件上传区 */
    .tca-dropzone {
        border: 2px dashed #d1d5db; border-radius: 10px; padding: 36px 20px;
        text-align: center; cursor: pointer; transition: all .2s;
        background: #fafbfc; margin-bottom: 18px;
    }
    .tca-dropzone:hover, .tca-dropzone.dragover { border-color: #fbbf24; background: #fffbeb; }
    .tca-dropzone svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; margin-bottom: 10px; }
    .tca-dropzone:hover svg, .tca-dropzone.dragover svg { stroke: #f59e0b; }
    .tca-dropzone-text { font-size: 14px; color: #64748b; }
    .tca-dropzone-hint { font-size: 12px; color: #94a3b8; margin-top: 4px; }
    .tca-dropzone-btn {
        display: inline-flex; align-items: center; gap: 6px; margin-top: 12px;
        padding: 7px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #f59e0b;
        cursor: pointer; transition: all .15s;
    }
    .tca-dropzone-btn:hover { background: #fffbeb; border-color: #fde68a; }

    /* 批量导入预览 */
    .tca-batch-list { max-height: 400px; overflow-y: auto; margin-top: 16px; }
    .tca-batch-item {
        display: flex; align-items: flex-start; gap: 14px; padding: 14px 16px;
        border: 1px solid #f1f5f9; border-radius: 8px; margin-bottom: 8px;
        transition: all .15s; background: #fff;
    }
    .tca-batch-item:hover { border-color: #fde68a; background: #fffdf5; }
    .tca-batch-num {
        width: 28px; height: 28px; border-radius: 50%; background: #fffbeb;
        color: #f59e0b; font-size: 12px; font-weight: 700;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .tca-batch-content { flex: 1; min-width: 0; }
    .tca-batch-title { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 4px; }
    .tca-batch-text {
        font-size: 12px; color: #64748b; line-height: 1.5;
        overflow: hidden; text-overflow: ellipsis; display: -webkit-box;
        -webkit-line-clamp: 2; -webkit-box-orient: vertical;
    }
    .tca-batch-meta { font-size: 11px; color: #94a3b8; margin-top: 4px; }
    .tca-batch-remove {
        width: 24px; height: 24px; border: none; background: none; cursor: pointer;
        color: #cbd5e1; transition: color .15s; display: flex; align-items: center;
        justify-content: center; flex-shrink: 0; margin-top: 2px;
    }
    .tca-batch-remove:hover { color: #ef4444; }
    .tca-batch-remove svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; }

    .tca-batch-status {
        padding: 14px 16px; border-radius: 8px; margin-top: 14px;
        font-size: 13px; display: none;
    }
    .tca-batch-status.show { display: flex; align-items: center; gap: 10px; }
    .tca-batch-status.success { background: #ecfdf5; color: #065f46; border: 1px solid #d1fae5; }
    .tca-batch-status.progress { background: #fffbeb; color: #92400e; border: 1px solid #fef3c7; }
    .tca-batch-status.error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

    .tca-msg { min-height: 20px; }
</style>

<div class="tca-page">
    <!-- 页面标题 -->
    <div class="tca-header">
        <div class="tca-title-wrap">
            <div class="tca-title">
                <span class="tca-icon">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                </span>
                添加拼音词语
            </div>
            <div class="tca-subtitle">支持手动输入、从TXT文件导入单篇词语，或批量导入多篇词语练习内容</div>
        </div>
        <a href="typechinese.aspx" class="tca-back">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回词语管理
        </a>
    </div>

    <!-- 主卡片 -->
    <div class="tca-card">
        <!-- 标签页导航 -->
        <div class="tca-tabs">
            <div class="tca-tab active" onclick="tcaSwitchTab('manual')">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                手动添加
            </div>
            <div class="tca-tab" onclick="tcaSwitchTab('import')">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                从TXT导入
            </div>
            <div class="tca-tab" onclick="tcaSwitchTab('batch')">
                <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="2" ry="2"/><line x1="8" y1="6" x2="16" y2="6"/><line x1="8" y1="10" x2="16" y2="10"/><line x1="8" y1="14" x2="12" y2="14"/></svg>
                批量导入
            </div>
        </div>

        <!-- 标签页 1：手动添加 -->
        <div id="tca-panel-manual" class="tca-tab-panel active">
            <div class="tca-card-body">
                <div class="tca-tip tca-tip-amber">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>词语之间请使用 <strong>中文逗号、句号或空格</strong> 作为分隔符。文章长度无限制，可自由编写词语练习内容。如有特殊格式可点击「清除格式」按钮。</div>
                </div>
                <div class="tca-form-group">
                    <label class="tca-form-label">词语标题 <span class="tca-form-hint">必填，建议使用“年级+内容”格式</span></label>
                    <asp:TextBox ID="Ttitle" runat="server" CssClass="tca-input" MaxLength="50"
                        placeholder="请输入词语标题，例如：三年级上册词语练习"></asp:TextBox>
                </div>
                <div class="tca-form-group">
                    <label class="tca-form-label">词语内容 <span class="tca-form-hint">长度无限制</span></label>
                    <asp:TextBox ID="Tcontent" runat="server" TextMode="MultiLine" CssClass="tca-textarea"
                        placeholder="请输入词语内容，例如：大家好，今天天气真好，我们一起去公园玩。"></asp:TextBox>
                </div>
                <div class="tca-msg">
                    <asp:Label ID="Labelmsg" runat="server" ForeColor="#f59e0b" Font-Size="12px"></asp:Label>
                </div>
                <div class="tca-btn-actions">
                    <asp:Button ID="BtnAdd" runat="server" Text="添加词语" OnClick="BtnAdd_Click"
                        CssClass="tca-btn tca-btn-primary" />
                    <asp:Button ID="BtnNoSet" runat="server" Text="清除格式" OnClick="BtnNoSet_Click"
                        CssClass="tca-btn" ToolTip="清除文本中的特殊格式和多余空格" />
                    <asp:Button ID="Btnreturn" runat="server" Text="返回列表" OnClick="Btnreturn_Click"
                        CssClass="tca-btn" />
                </div>
            </div>
        </div>

        <!-- 标签页 2：从TXT导入 -->
        <div id="tca-panel-import" class="tca-tab-panel">
            <div class="tca-card-body">
                <div class="tca-tip tca-tip-green">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>从本地选择一个 <strong>.txt 文本文件</strong>，系统会自动读取文件名作为标题、文件内容作为词语内容填入表单。确认无误后点击「添加词语」保存。</div>
                </div>
                <div class="tca-dropzone" id="tcaDropSingle" onclick="document.getElementById('tcaFileSingle').click()">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <div class="tca-dropzone-text">点击选择或拖拽 TXT 文件到此处</div>
                    <div class="tca-dropzone-hint">支持 .txt 格式，文件内容将自动填入手动添加表单</div>
                    <div class="tca-dropzone-btn">选择文件</div>
                </div>
                <input type="file" id="tcaFileSingle" accept=".txt" style="display:none" onchange="tcaHandleSingle(this)" />
                <div id="tcaImportPreview" style="display:none;">
                    <div class="tca-form-group">
                        <label class="tca-form-label">导入预览</label>
                        <div class="tca-batch-item">
                            <div class="tca-batch-num">✓</div>
                            <div class="tca-batch-content">
                                <div class="tca-batch-title" id="tcaImpTitle"></div>
                                <div class="tca-batch-text" id="tcaImpText"></div>
                                <div class="tca-batch-meta" id="tcaImpMeta"></div>
                            </div>
                        </div>
                    </div>
                    <div class="tca-tip tca-tip-amber">
                        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <div>文件内容已填入「手动添加」表单，请切换到「手动添加」标签页检查并点击「添加词语」保存。</div>
                    </div>
                    <button type="button" class="tca-btn tca-btn-primary" onclick="tcaSwitchTab('manual')">去手动添加页提交</button>
                </div>
            </div>
        </div>

        <!-- 标签页 3：批量导入 -->
        <div id="tca-panel-batch" class="tca-tab-panel">
            <div class="tca-card-body">
                <div class="tca-tip tca-tip-green">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>
                        准备一个 <strong>.txt 文本文件</strong>，每篇词语用一行 <code style="background:#d1fae5;padding:1px 6px;border-radius:4px;">---</code> 分隔。格式示例：<br />
                        <code style="display:block;margin-top:8px;padding:10px 14px;background:#f0fdf4;border-radius:6px;font-size:12px;line-height:1.8;color:#065f46;">
                        三年级上册第一单元<br/>
                        大家好，今天天气真好，我们一起去公园玩。<br/>
                        ---<br/>
                        三年级上册第二单元<br/>
                        春天来了，小草绿了，花儿开了，小鸟唱歌了。
                        </code>
                        第一行为标题，第二行起为词语内容，三个横线 <code style="background:#d1fae5;padding:1px 6px;border-radius:4px;">---</code> 表示下一篇。
                    </div>
                </div>
                <div class="tca-dropzone" id="tcaDropBatch" onclick="document.getElementById('tcaFileBatch').click()">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <div class="tca-dropzone-text">点击选择或拖拽 TXT 文件到此处（含多篇词语）</div>
                    <div class="tca-dropzone-hint">支持 .txt 格式，多篇词语用 --- 分隔</div>
                    <div class="tca-dropzone-btn">选择文件</div>
                </div>
                <input type="file" id="tcaFileBatch" accept=".txt" style="display:none" onchange="tcaHandleBatch(this)" />

                <div id="tcaBatchPreview" style="display:none;">
                    <div class="tca-form-group">
                        <label class="tca-form-label">解析结果 <span class="tca-form-hint" id="tcaBatchCount"></span></label>
                    </div>
                    <div class="tca-batch-list" id="tcaBatchList"></div>
                    <div class="tca-batch-status" id="tcaBatchStatus"></div>
                    <div class="tca-btn-actions">
                        <button type="button" class="tca-btn tca-btn-green" id="tcaBtnBatchSubmit" onclick="tcaStartBatch()">
                            <svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
                            开始批量导入
                        </button>
                        <button type="button" class="tca-btn" onclick="tcaClearBatch()">清除列表</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    // === 标签页切换 ===
    function tcaSwitchTab(name) {
        var tabs = document.querySelectorAll('.tca-tab');
        var panels = document.querySelectorAll('.tca-tab-panel');
        for (var i = 0; i < tabs.length; i++) tabs[i].className = 'tca-tab';
        for (var i = 0; i < panels.length; i++) panels[i].className = 'tca-tab-panel';
        if (name === 'manual') { tabs[0].className = 'tca-tab active'; }
        else if (name === 'import') { tabs[1].className = 'tca-tab active'; }
        else if (name === 'batch') { tabs[2].className = 'tca-tab active'; }
        document.getElementById('tca-panel-' + name).className = 'tca-tab-panel active';
    }

    // === 单文件导入 ===
    function tcaHandleSingle(input) {
        if (!input.files || !input.files[0]) return;
        var file = input.files[0];
        var fname = file.name.replace(/\.txt$/i, '');
        var reader = new FileReader();
        reader.onload = function (e) {
            var text = e.target.result.replace(/\r\n/g, '\n').replace(/\r/g, '\n').trim();
            var titleEl = document.querySelector('input[id$="Ttitle"]');
            var contentEl = document.querySelector('textarea[id$="Tcontent"]');
            if (titleEl) titleEl.value = fname;
            if (contentEl) contentEl.value = text;
            document.getElementById('tcaImportPreview').style.display = 'block';
            document.getElementById('tcaImpTitle').textContent = fname;
            document.getElementById('tcaImpText').textContent = text.substring(0, 120) + (text.length > 120 ? '...' : '');
            document.getElementById('tcaImpMeta').textContent = text.length + ' 个字符';
        };
        reader.readAsText(file, 'UTF-8');
    }

    // === 拖拽支持 ===
    function tcaSetupDrop(id, handler) {
        var dz = document.getElementById(id);
        if (!dz) return;
        dz.addEventListener('dragover', function (e) { e.preventDefault(); dz.classList.add('dragover'); });
        dz.addEventListener('dragleave', function () { dz.classList.remove('dragover'); });
        dz.addEventListener('drop', function (e) {
            e.preventDefault(); dz.classList.remove('dragover');
            if (e.dataTransfer.files && e.dataTransfer.files[0]) handler({ files: e.dataTransfer.files });
        });
    }
    tcaSetupDrop('tcaDropSingle', tcaHandleSingle);
    tcaSetupDrop('tcaDropBatch', tcaHandleBatch);

    // === 批量导入 ===
    var tcaBatchArticles = [];

    function tcaHandleBatch(input) {
        if (!input.files || !input.files[0]) return;
        var reader = new FileReader();
        reader.onload = function (e) {
            var text = e.target.result.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
            var blocks = text.split(/\n---\n|\n---$/);
            tcaBatchArticles = [];
            for (var i = 0; i < blocks.length; i++) {
                var block = blocks[i].trim();
                if (!block) continue;
                var lines = block.split('\n');
                var title = lines[0].trim();
                var content = lines.slice(1).join('\n').trim();
                if (title && content) {
                    tcaBatchArticles.push({ title: title, content: content });
                }
            }
            tcaRenderBatch();
        };
        reader.readAsText(input.files[0], 'UTF-8');
    }

    function tcaRenderBatch() {
        var list = document.getElementById('tcaBatchList');
        var html = '';
        for (var i = 0; i < tcaBatchArticles.length; i++) {
            var a = tcaBatchArticles[i];
            html += '<div class="tca-batch-item" id="tcaBatch-' + i + '">' +
                '<div class="tca-batch-num">' + (i + 1) + '</div>' +
                '<div class="tca-batch-content">' +
                '<div class="tca-batch-title">' + tcaEsc(a.title) + '</div>' +
                '<div class="tca-batch-text">' + tcaEsc(a.content.substring(0, 100)) + (a.content.length > 100 ? '...' : '') + '</div>' +
                '<div class="tca-batch-meta">' + a.content.length + ' 个字符</div>' +
                '</div>' +
                '<button type="button" class="tca-batch-remove" onclick="tcaRemoveBatch(' + i + ')" title="移除">' +
                '<svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>' +
                '</div>';
        }
        list.innerHTML = html;
        document.getElementById('tcaBatchCount').textContent = '共解析出 ' + tcaBatchArticles.length + ' 篇词语';
        document.getElementById('tcaBatchPreview').style.display = tcaBatchArticles.length > 0 ? 'block' : 'none';
        tcaSetStatus('', '');
    }

    function tcaRemoveBatch(idx) {
        tcaBatchArticles.splice(idx, 1);
        tcaRenderBatch();
    }

    function tcaClearBatch() {
        tcaBatchArticles = [];
        tcaRenderBatch();
        document.getElementById('tcaFileBatch').value = '';
    }

    function tcaEsc(s) {
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(s));
        return d.innerHTML;
    }

    function tcaSetStatus(msg, type) {
        var el = document.getElementById('tcaBatchStatus');
        if (!msg) { el.className = 'tca-batch-status'; return; }
        el.className = 'tca-batch-status show ' + type;
        el.innerHTML = msg;
    }

    // 批量提交：通过 sessionStorage 持久化状态，逐条填写表单提交
    var tcaBatchIdx = 0;
    var tcaBatchOk = 0;

    function tcaStartBatch() {
        if (tcaBatchArticles.length === 0) return;
        tcaBatchIdx = 0;
        tcaBatchOk = 0;
        sessionStorage.setItem('tcaBatchImport', JSON.stringify({
            articles: tcaBatchArticles, index: 0, success: 0
        }));
        tcaSubmitNext();
    }

    function tcaSubmitNext() {
        if (tcaBatchIdx >= tcaBatchArticles.length) {
            sessionStorage.removeItem('tcaBatchImport');
            tcaSetStatus('✅ 批量导入完成！成功导入 ' + tcaBatchOk + ' 篇词语。<a href="typechinese.aspx" style="color:inherit;font-weight:600;margin-left:8px;">返回词语列表查看 →</a>', 'success');
            return;
        }
        var a = tcaBatchArticles[tcaBatchIdx];
        tcaSetStatus('⏳ 正在导入第 ' + (tcaBatchIdx + 1) + '/' + tcaBatchArticles.length + ' 篇：' + tcaEsc(a.title), 'progress');

        var items = document.querySelectorAll('.tca-batch-item');
        for (var i = 0; i < items.length; i++) items[i].style.borderColor = '';
        var cur = document.getElementById('tcaBatch-' + tcaBatchIdx);
        if (cur) { cur.style.borderColor = '#fbbf24'; cur.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }

        var titleEl = document.querySelector('input[id$="Ttitle"]');
        var contentEl = document.querySelector('textarea[id$="Tcontent"]');
        if (titleEl) titleEl.value = a.title;
        if (contentEl) contentEl.value = a.content;

        sessionStorage.setItem('tcaBatchImport', JSON.stringify({
            articles: tcaBatchArticles, index: tcaBatchIdx, success: tcaBatchOk
        }));

        setTimeout(function () {
            var addBtn = document.querySelector('input[id$="BtnAdd"]');
            if (addBtn) __doPostBack(addBtn.name, '');
        }, 300);
    }

    // 页面加载后检查是否在批量导入中
    (function () {
        try {
            var stored = sessionStorage.getItem('tcaBatchImport');
            if (stored) {
                var data = JSON.parse(stored);
                tcaBatchArticles = data.articles || [];
                tcaBatchIdx = data.index + 1;
                tcaBatchOk = data.success + 1;
                if (tcaBatchIdx < tcaBatchArticles.length) {
                    tcaSwitchTab('batch');
                    tcaRenderBatch();
                    sessionStorage.setItem('tcaBatchImport', JSON.stringify({
                        articles: tcaBatchArticles, index: tcaBatchIdx, success: tcaBatchOk
                    }));
                    setTimeout(tcaSubmitNext, 500);
                } else {
                    tcaSwitchTab('batch');
                    tcaRenderBatch();
                    tcaSetStatus('✅ 批量导入完成！成功导入 ' + tcaBatchOk + ' 篇词语。<a href="typechinese.aspx" style="color:inherit;font-weight:600;margin-left:8px;">返回词语列表查看 →</a>', 'success');
                    sessionStorage.removeItem('tcaBatchImport');
                }
            }
        } catch (e) { }
    })();
</script>
</asp:Content>

