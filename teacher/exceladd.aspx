<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" validaterequest="false" autoeventwireup="true" inherits="teacher_exceladd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<link rel="stylesheet" type="text/css" href="addpage-common.css" />
<style>
    /* ── exceladd 增强样式 ── */
    .ex-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; animation: exFadeIn .5s ease; }
    @keyframes exFadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

    .ex-header {
        display: flex; align-items: center; gap: 20px;
        margin-bottom: 28px; padding: 28px 32px;
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
        border-radius: 16px; position: relative; overflow: hidden;
        box-shadow: 0 4px 20px rgba(5,150,105,.25);
    }
    .ex-header::before {
        content: ''; position: absolute; top: -30px; right: -30px;
        width: 120px; height: 120px; border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .ex-header::after {
        content: ''; position: absolute; bottom: -40px; right: 60px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .ex-header-icon {
        width: 52px; height: 52px; background: rgba(255,255,255,.18);
        border-radius: 14px; display: flex; align-items: center; justify-content: center;
        backdrop-filter: blur(10px); flex-shrink: 0;
    }
    .ex-header-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ex-header-text { position: relative; z-index: 1; }
    .ex-header-title { font-size: 22px; font-weight: 700; color: #fff; margin-bottom: 4px; }
    .ex-header-sub { font-size: 13px; color: rgba(255,255,255,.75); }

    /* 卡片 */
    .ex-card {
        background: #fff; border-radius: 14px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,.04); margin-bottom: 20px;
        overflow: hidden; transition: box-shadow .2s, transform .2s;
    }
    .ex-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); transform: translateY(-1px); }
    .ex-card-head {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; gap: 10px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
    }
    .ex-card-head .ex-dot {
        width: 8px; height: 8px; border-radius: 50%;
        background: linear-gradient(135deg, #059669, #34d399);
        flex-shrink: 0;
    }
    .ex-card-head h3 {
        font-size: 15px; font-weight: 600; color: #334155; margin: 0;
        display: flex; align-items: center; gap: 8px; flex: 1;
    }
    .ex-card-head h3 svg { width: 18px; height: 18px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ex-card-body { padding: 24px 28px; }

    /* 表单 */
    .ex-form-row { display: flex; align-items: flex-end; gap: 24px; flex-wrap: wrap; margin-bottom: 18px; }
    .ex-form-row:last-child { margin-bottom: 0; }
    .ex-field { display: flex; flex-direction: column; gap: 6px; }
    .ex-field label {
        font-size: 12px; font-weight: 600; color: #64748b;
        text-transform: uppercase; letter-spacing: .5px;
    }
    .ex-field input[type="text"] {
        padding: 10px 16px; border-radius: 10px; border: 1.5px solid #e2e8f0;
        font-size: 14px; color: #1e293b; background: #fff; outline: none;
        transition: all .2s; font-family: inherit; min-width: 380px;
    }
    .ex-field input[type="text"]:focus {
        border-color: #34d399; box-shadow: 0 0 0 4px rgba(5,150,105,.08);
    }
    .ex-field input[type="text"]::placeholder { color: #cbd5e1; }
    .ex-field select {
        padding: 10px 36px 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: all .2s; font-family: inherit; cursor: pointer;
        appearance: none; -webkit-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23059669' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 12px center;
    }
    .ex-field select:focus {
        border-color: #34d399; box-shadow: 0 0 0 4px rgba(5,150,105,.08);
    }

    /* 自定义复选框 */
    .ex-check-wrap { display: flex; align-items: center; gap: 8px; cursor: pointer; user-select: none; padding-bottom: 2px; }
    .ex-check-wrap input[type="checkbox"] {
        width: 18px; height: 18px; border-radius: 5px; border: 1.5px solid #d1d5db;
        appearance: none; -webkit-appearance: none; outline: none; cursor: pointer;
        transition: all .15s; position: relative; background: #fff; flex-shrink: 0;
    }
    .ex-check-wrap input[type="checkbox"]:checked {
        background: linear-gradient(135deg, #059669, #10b981); border-color: #059669;
    }
    .ex-check-wrap input[type="checkbox"]:checked::after {
        content: ''; position: absolute; left: 5px; top: 2px;
        width: 5px; height: 9px; border: solid #fff; border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }
    .ex-check-wrap input[type="checkbox"]:focus { box-shadow: 0 0 0 3px rgba(5,150,105,.15); }
    .ex-check-wrap span, .ex-check-wrap label {
        font-size: 13px; color: #475569; font-weight: 500; cursor: pointer;
    }

    /* 文件上传 */
    .ex-upload-zone {
        display: flex; align-items: center; gap: 14px;
        padding: 14px 20px; border-radius: 10px;
        background: #f0fdf4; border: 1.5px dashed #86efac;
        transition: all .2s;
    }
    .ex-upload-zone:hover { border-color: #34d399; background: #ecfdf5; }
    .ex-upload-zone .ex-upload-icon {
        width: 36px; height: 36px; border-radius: 8px;
        background: linear-gradient(135deg, #059669, #10b981);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .ex-upload-zone .ex-upload-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; }
    .ex-upload-info { display: flex; flex-direction: column; gap: 2px; }
    .ex-upload-info .ex-upload-title { font-size: 13px; font-weight: 600; color: #334155; }
    .ex-upload-info .ex-upload-hint { font-size: 11px; color: #94a3b8; }

    /* 编辑器 */
    .ex-editor-label {
        display: flex; align-items: center; gap: 6px;
        margin-bottom: 10px; font-size: 12px; color: #94a3b8;
    }
    .ex-editor-label svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; }
    .sa-editor-wrap .ke-container {
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 12px !important;
        overflow: hidden !important;
        box-shadow: 0 2px 8px rgba(0,0,0,.03) !important;
        transition: border-color .2s, box-shadow .2s;
    }
    .sa-editor-wrap .ke-container:focus-within {
        border-color: #34d399 !important;
        box-shadow: 0 0 0 4px rgba(5,150,105,.08), 0 2px 8px rgba(0,0,0,.03) !important;
    }
    .sa-editor-wrap .ke-toolbar .ke-outline:hover {
        background: rgba(5,150,105,.08) !important;
        border-color: rgba(5,150,105,.18) !important;
    }
    .sa-editor-wrap .ke-toolbar .ke-on,
    .sa-editor-wrap .ke-toolbar .ke-selected {
        background: rgba(5,150,105,.12) !important;
        border-color: #34d399 !important;
    }

    /* 消息 */
    .ex-msg {
        font-size: 13px; color: #ef4444; margin-bottom: 14px; display: block;
        padding: 8px 14px; background: #fef2f2; border: 1px solid #fecaca;
        border-radius: 8px;
    }
    .ex-msg:empty { display: none; }

    /* 按钮 */
    .ex-actions { display: flex; align-items: center; gap: 12px; }
    .ex-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 7px;
        padding: 10px 28px; border-radius: 10px; font-size: 14px; font-weight: 600;
        border: 1.5px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .2s; font-family: inherit;
    }
    .ex-btn:hover { background: #f8fafc; border-color: #cbd5e1; transform: translateY(-1px); }
    .ex-btn-primary {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%); color: #fff;
        border-color: transparent; box-shadow: 0 3px 12px rgba(5,150,105,.25);
    }
    .ex-btn-primary:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%);
        box-shadow: 0 6px 20px rgba(5,150,105,.35); transform: translateY(-1px); color: #fff;
    }

    /* 提示条 */
    .ex-info-bar {
        display: flex; align-items: center; gap: 10px;
        padding: 12px 18px; border-radius: 10px;
        background: linear-gradient(135deg, #ecfdf5 0%, #f0fdf4 100%);
        border: 1px solid #bbf7d0; margin-bottom: 20px;
    }
    .ex-info-bar svg { width: 18px; height: 18px; stroke: #059669; fill: none; stroke-width: 2; flex-shrink: 0; }
    .ex-info-bar span { font-size: 12px; color: #047857; line-height: 1.5; }
</style>

<div class="ex-page">
    <!-- 渐变标题栏 -->
    <div class="ex-header">
        <div class="ex-header-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/><line x1="15" y1="3" x2="15" y2="21"/></svg>
        </div>
        <div class="ex-header-text">
            <div class="ex-header-title">添加表格处理主题</div>
            <div class="ex-header-sub">创建表格处理任务，上传实例文件并编写任务说明</div>
        </div>
    </div>

    <!-- 提示条 -->
    <div class="ex-info-bar">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <span>填写主题名称和任务内容，可上传 Excel/WPS 实例文件供学生下载练习。评价标准用于对学生作品进行等级评定。</span>
    </div>

    <!-- 基本信息 -->
    <div class="ex-card">
        <div class="ex-card-head">
            <span class="ex-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                基本信息
            </h3>
        </div>
        <div class="ex-card-body">
            <div class="ex-form-row">
                <div class="ex-field" style="flex:1; min-width:300px;">
                    <label>主题名称</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="100%" placeholder="请输入表格处理主题名称"></asp:TextBox>
                </div>
                <div class="ex-field">
                    <label>&nbsp;</label>
                    <div class="ex-check-wrap">
                        <asp:CheckBox ID="CheckPublish" runat="server" Checked="True" />
                        <label for="<%=CheckPublish.ClientID %>">发布主题</label>
                    </div>
                </div>
            </div>
            <div class="ex-form-row">
                <div class="ex-field" style="flex:1;">
                    <label>上传实例文件</label>
                    <div class="ex-upload-zone">
                        <div class="ex-upload-icon">
                            <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        </div>
                        <div class="ex-upload-info">
                            <span class="ex-upload-title">表格处理实例文件</span>
                            <span class="ex-upload-hint">支持 .xls、.xlsx、.et 等表格格式</span>
                        </div>
                        <asp:FileUpload ID="Fupload" runat="server" Font-Size="10pt" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 任务内容 -->
    <div class="ex-card">
        <div class="ex-card-head">
            <span class="ex-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                任务内容
            </h3>
        </div>
        <div class="ex-card-body">
            <div class="ex-editor-label">
                <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                使用富文本编辑器编写任务说明和操作步骤
            </div>
            <div class="sa-editor-wrap">
                <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                <script>
                    var editor;
                    var cid= <%=myCid() %>;
                    var ty="Course";
                    var upjs= '../kindeditor/aspnet/upload_json.aspx?cid='+cid+'&ty='+ty;
                    var fmjs='../kindeditor/aspnet/file_manager_json.aspx?cid='+cid+'&ty='+ty;
                    KindEditor.ready(function (K) {
                        editor = K.create('textarea[name="textareaItem"]', {
                            resizeType: 1,
                            newlineTag: "br",
                            uploadJson : upjs,
                            fileManagerJson : fmjs,
                            allowFileManager : true,
                            filterMode : false,
                            afterCreate : function() {
                                this.loadPlugin('autoheight');
                            }
                        });
                    });
                </script>
                <textarea name="textareaItem" style="width:100%; height:450px;"></textarea>
            </div>
        </div>
    </div>

    <!-- 提交设置 -->
    <div class="ex-card">
        <div class="ex-card-head">
            <span class="ex-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                提交设置
            </h3>
        </div>
        <div class="ex-card-body">
            <asp:Label ID="Labelmsg" runat="server" CssClass="ex-msg"></asp:Label>
            <div class="ex-form-row">
                <div class="ex-field">
                    <label>评价标准</label>
                    <asp:DropDownList ID="DDLMgid" runat="server" Width="200px"></asp:DropDownList>
                </div>
            </div>
            <div style="height:16px;"></div>
            <div class="ex-actions">
                <asp:Button ID="Btnadd" runat="server" Text="✦ 添加主题" OnClick="Btnadd_Click" CssClass="ex-btn ex-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="返回学案" OnClick="BtnCourse_Click" CssClass="ex-btn" />
            </div>
        </div>
    </div>
</div>

</asp:Content>

