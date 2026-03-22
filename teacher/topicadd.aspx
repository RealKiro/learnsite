<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_topicadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ── topicadd 增强样式 (参照 exceladd) ── */
    .ta-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; animation: taFadeIn .5s ease; }
    @keyframes taFadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

    /* 渐变标题栏 (绿色主题) */
    .ta-header {
        display: flex; align-items: center; gap: 20px;
        margin-bottom: 28px; padding: 28px 32px;
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
        border-radius: 16px; position: relative; overflow: hidden;
        box-shadow: 0 4px 20px rgba(5,150,105,.25);
    }
    .ta-header::before {
        content: ''; position: absolute; top: -30px; right: -30px;
        width: 120px; height: 120px; border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .ta-header::after {
        content: ''; position: absolute; bottom: -40px; right: 60px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .ta-header-icon {
        width: 52px; height: 52px; background: rgba(255,255,255,.18);
        border-radius: 14px; display: flex; align-items: center; justify-content: center;
        backdrop-filter: blur(10px); flex-shrink: 0;
    }
    .ta-header-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ta-header-text { position: relative; z-index: 1; }
    .ta-header-title { font-size: 22px; font-weight: 700; color: #fff; margin-bottom: 4px; }
    .ta-header-sub { font-size: 13px; color: rgba(255,255,255,.75); }

    /* 提示条 */
    .ta-info-bar {
        display: flex; align-items: center; gap: 10px;
        padding: 12px 18px; border-radius: 10px;
        background: linear-gradient(135deg, #ecfdf5 0%, #f0fdf4 100%);
        border: 1px solid #bbf7d0; margin-bottom: 20px;
    }
    .ta-info-bar svg { width: 18px; height: 18px; stroke: #059669; fill: none; stroke-width: 2; flex-shrink: 0; }
    .ta-info-bar span { font-size: 12px; color: #047857; line-height: 1.5; }

    /* 卡片 */
    .ta-card {
        background: #fff; border-radius: 14px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,.04); margin-bottom: 20px;
        overflow: hidden; transition: box-shadow .2s, transform .2s;
    }
    .ta-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); transform: translateY(-1px); }
    .ta-card-head {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; gap: 10px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
    }
    .ta-card-head .ta-dot {
        width: 8px; height: 8px; border-radius: 50%;
        background: linear-gradient(135deg, #059669, #34d399);
        flex-shrink: 0;
    }
    .ta-card-head h3 {
        font-size: 15px; font-weight: 600; color: #334155; margin: 0;
        display: flex; align-items: center; gap: 8px; flex: 1;
    }
    .ta-card-head h3 svg { width: 18px; height: 18px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ta-card-body { padding: 24px 28px; }

    /* 表单 */
    .ta-form-row { display: flex; align-items: flex-end; gap: 24px; flex-wrap: wrap; margin-bottom: 18px; }
    .ta-form-row:last-child { margin-bottom: 0; }
    .ta-field { display: flex; flex-direction: column; gap: 6px; }
    .ta-field label {
        font-size: 12px; font-weight: 600; color: #64748b;
        text-transform: uppercase; letter-spacing: .5px;
    }
    .ta-field input[type="text"] {
        padding: 10px 16px !important; border-radius: 10px !important; border: 1.5px solid #e2e8f0 !important;
        font-size: 14px !important; color: #1e293b !important; background: #fff !important; outline: none;
        transition: all .2s; font-family: inherit !important; min-width: 380px;
    }
    .ta-field input[type="text"]:focus {
        border-color: #34d399 !important; box-shadow: 0 0 0 4px rgba(5,150,105,.08) !important;
    }
    .ta-field input[type="text"]::placeholder { color: #cbd5e1; }

    /* 自定义复选框 */
    .ta-check-wrap { display: flex; align-items: center; gap: 8px; cursor: pointer; user-select: none; padding-bottom: 2px; }
    .ta-check-wrap input[type="checkbox"] {
        width: 18px; height: 18px; border-radius: 5px; border: 1.5px solid #d1d5db;
        appearance: none; -webkit-appearance: none; outline: none; cursor: pointer;
        transition: all .15s; position: relative; background: #fff; flex-shrink: 0;
    }
    .ta-check-wrap input[type="checkbox"]:checked {
        background: linear-gradient(135deg, #059669, #10b981); border-color: #059669;
    }
    .ta-check-wrap input[type="checkbox"]:checked::after {
        content: ''; position: absolute; left: 5px; top: 2px;
        width: 5px; height: 9px; border: solid #fff; border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }
    .ta-check-wrap input[type="checkbox"]:focus { box-shadow: 0 0 0 3px rgba(5,150,105,.15); }
    .ta-check-wrap span, .ta-check-wrap label {
        font-size: 13px; color: #475569; font-weight: 500; cursor: pointer;
    }

    /* 编辑器 */
    .ta-editor-label {
        display: flex; align-items: center; gap: 6px;
        margin-bottom: 10px; font-size: 12px; color: #94a3b8;
    }
    .ta-editor-label svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; }
    .ta-editor-wrap .ke-container {
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 12px !important;
        overflow: hidden !important;
        box-shadow: 0 2px 8px rgba(0,0,0,.03) !important;
        transition: border-color .2s, box-shadow .2s;
    }
    .ta-editor-wrap .ke-container:focus-within {
        border-color: #34d399 !important;
        box-shadow: 0 0 0 4px rgba(5,150,105,.08), 0 2px 8px rgba(0,0,0,.03) !important;
    }
    .ta-editor-wrap .ke-toolbar .ke-outline:hover {
        background: rgba(5,150,105,.08) !important;
        border-color: rgba(5,150,105,.18) !important;
    }
    .ta-editor-wrap .ke-toolbar .ke-on,
    .ta-editor-wrap .ke-toolbar .ke-selected {
        background: rgba(5,150,105,.12) !important;
        border-color: #34d399 !important;
    }

    /* 消息 */
    .ta-msg {
        font-size: 13px; color: #ef4444; margin-bottom: 14px; display: block;
        padding: 8px 14px; background: #fef2f2; border: 1px solid #fecaca;
        border-radius: 8px; text-align: center;
    }
    .ta-msg:empty { display: none; }

    /* 按钮 */
    .ta-actions { display: flex; align-items: center; justify-content: center; gap: 12px; }
    .ta-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 7px;
        padding: 10px 28px; border-radius: 10px; font-size: 14px; font-weight: 600;
        border: 1.5px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .2s; font-family: inherit;
    }
    .ta-btn:hover { background: #f8fafc; border-color: #cbd5e1; transform: translateY(-1px); }
    .ta-btn-primary {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%); color: #fff;
        border-color: transparent; box-shadow: 0 3px 12px rgba(5,150,105,.25);
    }
    .ta-btn-primary:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%);
        box-shadow: 0 6px 20px rgba(5,150,105,.35); transform: translateY(-1px); color: #fff;
    }
    .ta-actions input[type="submit"] {
        padding: 10px 28px !important; border-radius: 10px !important;
        font-size: 14px !important; font-weight: 600 !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
        cursor: pointer; transition: all .2s ease;
        height: auto !important; width: auto !important; line-height: 1.4 !important;
    }
    .ta-btn-primary input[type="submit"] {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
        color: #fff !important; border: none !important;
        box-shadow: 0 3px 12px rgba(5,150,105,.25) !important;
    }
    .ta-btn-primary input[type="submit"]:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 6px 20px rgba(5,150,105,.35) !important;
        transform: translateY(-1px);
    }
    .ta-btn-secondary input[type="submit"] {
        background: #fff !important; color: #475569 !important;
        border: 1.5px solid #e2e8f0 !important;
    }
    .ta-btn-secondary input[type="submit"]:hover {
        background: #f8fafc !important; border-color: #cbd5e1 !important;
        transform: translateY(-1px);
    }
</style>

<div class="ta-page">
    <!-- 渐变标题栏 -->
    <div class="ta-header">
        <div class="ta-header-icon">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </div>
        <div class="ta-header-text">
            <div class="ta-header-title">添加讨论主题</div>
            <div class="ta-header-sub">创建新的课堂讨论主题，学生可在线参与交流</div>
        </div>
    </div>

    <!-- 提示条 -->
    <div class="ta-info-bar">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <span>填写讨论主题和内容，学生可在线查看并参与讨论。勾选"是否暂停"可临时关闭该主题的讨论功能。</span>
    </div>

    <!-- 基本信息 -->
    <div class="ta-card">
        <div class="ta-card-head">
            <span class="ta-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                基本信息
            </h3>
        </div>
        <div class="ta-card-body">
            <div class="ta-form-row">
                <div class="ta-field" style="flex:1; min-width:300px;">
                    <label>讨论主题</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="100%" placeholder="请输入讨论主题名称"></asp:TextBox>
                </div>
                <div class="ta-field">
                    <label>&nbsp;</label>
                    <div class="ta-check-wrap">
                        <asp:CheckBox ID="CheckPublish" runat="server" />
                        <label for="<%=CheckPublish.ClientID %>">是否暂停</label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 讨论内容 -->
    <div class="ta-card">
        <div class="ta-card-head">
            <span class="ta-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                讨论内容
            </h3>
        </div>
        <div class="ta-card-body">
            <div class="ta-editor-label">
                <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                使用富文本编辑器编写讨论内容和引导问题
            </div>
            <div class="ta-editor-wrap">
                <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                <script>
                    var editor;
                    var cid = <%=myCid() %>;
                    var ty = "Course";
                    var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
                    var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?cid=' + cid + '&ty=' + ty;
                    KindEditor.ready(function (K) {
                        editor = K.create('textarea[name="textareaItem"]', {
                            resizeType: 1,
                            newlineTag: "br",
                            uploadJson: upjs,
                            fileManagerJson: fmjs,
                            allowFileManager: true,
                            filterMode: false,
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
    <div class="ta-card">
        <div class="ta-card-head">
            <span class="ta-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                提交设置
            </h3>
        </div>
        <div class="ta-card-body">
            <asp:Label ID="Labelmsg" runat="server" CssClass="ta-msg"></asp:Label>
            <div style="height:16px;"></div>
            <div class="ta-actions">
                <span class="ta-btn-primary">
                    <asp:Button ID="Btnadd" runat="server" Text="✦ 添加主题" OnClick="Btnadd_Click" SkinID="BtnNormal" />
                </span>
                <span class="ta-btn-secondary">
                    <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click" SkinID="BtnNormal" />
                </span>
            </div>
        </div>
    </div>
</div>
</asp:Content>

