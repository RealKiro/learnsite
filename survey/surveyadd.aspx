<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Survey_surveyadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<link rel="stylesheet" type="text/css" href="../teacher/addpage-common.css" />
<style>
    /* ── surveyadd 增强样式 ── */
    .sv-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; animation: svFadeIn .5s ease; }
    @keyframes svFadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

    .sv-header {
        display: flex; align-items: center; gap: 20px;
        margin-bottom: 28px; padding: 28px 32px;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
        border-radius: 16px; position: relative; overflow: hidden;
        box-shadow: 0 4px 20px rgba(99,102,241,.25);
    }
    .sv-header::before {
        content: ''; position: absolute; top: -30px; right: -30px;
        width: 120px; height: 120px; border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .sv-header::after {
        content: ''; position: absolute; bottom: -40px; right: 60px;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .sv-header-icon {
        width: 52px; height: 52px; background: rgba(255,255,255,.18);
        border-radius: 14px; display: flex; align-items: center; justify-content: center;
        backdrop-filter: blur(10px); flex-shrink: 0;
    }
    .sv-header-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sv-header-text { position: relative; z-index: 1; }
    .sv-header-title { font-size: 22px; font-weight: 700; color: #fff; margin-bottom: 4px; }
    .sv-header-sub { font-size: 13px; color: rgba(255,255,255,.75); }

    /* 卡片 */
    .sv-card {
        background: #fff; border-radius: 14px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,.04); margin-bottom: 20px;
        overflow: hidden; transition: box-shadow .2s, transform .2s;
    }
    .sv-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); transform: translateY(-1px); }
    .sv-card-head {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; gap: 10px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
    }
    .sv-card-head .sv-dot {
        width: 8px; height: 8px; border-radius: 50%;
        background: linear-gradient(135deg, #6366f1, #a78bfa);
        flex-shrink: 0;
    }
    .sv-card-head h3 {
        font-size: 15px; font-weight: 600; color: #334155; margin: 0;
        display: flex; align-items: center; gap: 8px;
    }
    .sv-card-head h3 svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sv-card-body { padding: 24px 28px; }

    /* 表单行 */
    .sv-form-row { display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
    .sv-field { display: flex; flex-direction: column; gap: 6px; }
    .sv-field-h { display: flex; align-items: center; gap: 10px; }
    .sv-field label, .sv-label {
        font-size: 12px; font-weight: 600; color: #64748b;
        text-transform: uppercase; letter-spacing: .5px;
    }
    .sv-field input[type="text"] {
        padding: 10px 16px; border-radius: 10px; border: 1.5px solid #e2e8f0;
        font-size: 14px; color: #1e293b; background: #fff; outline: none;
        transition: all .2s; font-family: inherit; min-width: 420px;
    }
    .sv-field input[type="text"]:focus {
        border-color: #818cf8; box-shadow: 0 0 0 4px rgba(99,102,241,.08);
    }
    .sv-field input[type="text"]::placeholder { color: #cbd5e1; }
    .sv-field select {
        padding: 10px 36px 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: all .2s; font-family: inherit; cursor: pointer;
        appearance: none; -webkit-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236366f1' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 12px center;
    }
    .sv-field select:focus {
        border-color: #818cf8; box-shadow: 0 0 0 4px rgba(99,102,241,.08);
    }

    /* 自定义复选框 */
    .sv-check-wrap { display: flex; align-items: center; gap: 8px; cursor: pointer; user-select: none; }
    .sv-check-wrap input[type="checkbox"] {
        width: 18px; height: 18px; border-radius: 5px; border: 1.5px solid #d1d5db;
        appearance: none; -webkit-appearance: none; outline: none; cursor: pointer;
        transition: all .15s; position: relative; background: #fff; flex-shrink: 0;
    }
    .sv-check-wrap input[type="checkbox"]:checked {
        background: linear-gradient(135deg, #6366f1, #818cf8); border-color: #6366f1;
    }
    .sv-check-wrap input[type="checkbox"]:checked::after {
        content: ''; position: absolute; left: 5px; top: 2px;
        width: 5px; height: 9px; border: solid #fff; border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }
    .sv-check-wrap input[type="checkbox"]:focus { box-shadow: 0 0 0 3px rgba(99,102,241,.15); }
    .sv-check-wrap span, .sv-check-wrap label {
        font-size: 13px; color: #475569; font-weight: 500; cursor: pointer;
    }

    /* 类型标签 */
    .sv-type-badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 4px 10px; border-radius: 6px;
        background: #f0f0ff; color: #6366f1; font-size: 11px; font-weight: 600;
    }
    .sv-type-badge svg { width: 13px; height: 13px; stroke: currentColor; fill: none; stroke-width: 2; }

    /* 编辑器增强 */
    .sv-editor-section { position: relative; }
    .sv-editor-label {
        display: flex; align-items: center; gap: 6px;
        margin-bottom: 10px; font-size: 12px; color: #94a3b8;
    }
    .sv-editor-label svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; }
    .sa-editor-wrap .ke-container {
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 12px !important;
        overflow: hidden !important;
        box-shadow: 0 2px 8px rgba(0,0,0,.03) !important;
        transition: border-color .2s, box-shadow .2s;
    }
    .sa-editor-wrap .ke-container:focus-within {
        border-color: #818cf8 !important;
        box-shadow: 0 0 0 4px rgba(99,102,241,.08), 0 2px 8px rgba(0,0,0,.03) !important;
    }

    /* 消息 */
    .sv-msg {
        font-size: 13px; color: #ef4444; margin-bottom: 14px; display: block;
        padding: 8px 14px; background: #fef2f2; border: 1px solid #fecaca;
        border-radius: 8px;
    }
    .sv-msg:empty { display: none; }

    /* 按钮区域 */
    .sv-actions { display: flex; align-items: center; gap: 12px; }
    .sv-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 7px;
        padding: 10px 28px; border-radius: 10px; font-size: 14px; font-weight: 600;
        border: 1.5px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .2s; font-family: inherit;
    }
    .sv-btn:hover { background: #f8fafc; border-color: #cbd5e1; transform: translateY(-1px); }
    .sv-btn-primary {
        background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%); color: #fff;
        border-color: transparent; box-shadow: 0 3px 12px rgba(99,102,241,.25);
    }
    .sv-btn-primary:hover {
        background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
        box-shadow: 0 6px 20px rgba(99,102,241,.35); transform: translateY(-1px); color: #fff;
    }
    .sv-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 提示条 */
    .sv-info-bar {
        display: flex; align-items: center; gap: 10px;
        padding: 12px 18px; border-radius: 10px;
        background: linear-gradient(135deg, #eff6ff 0%, #f0f0ff 100%);
        border: 1px solid #dbeafe; margin-bottom: 20px;
    }
    .sv-info-bar svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; flex-shrink: 0; }
    .sv-info-bar span { font-size: 12px; color: #4f46e5; line-height: 1.5; }

    /* 分隔线 */
    .sv-divider { height: 1px; background: #f1f5f9; margin: 16px 0; }
</style>

<div class="sv-page">
    <!-- 渐变标题栏 -->
    <div class="sv-header">
        <div class="sv-header-icon">
            <svg viewBox="0 0 24 24"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>
        </div>
        <div class="sv-header-text">
            <div class="sv-header-title">添加调查</div>
            <div class="sv-header-sub">创建问卷调查或课堂测验，收集学生反馈与评估数据</div>
        </div>
    </div>

    <!-- 提示条 -->
    <div class="sv-info-bar">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <span>填写调查名称和内容后点击「添加调查」即可创建。问卷调查支持收集学生反馈，课堂测验可用于评估学习效果。</span>
    </div>

    <!-- 基本信息 -->
    <div class="sv-card">
        <div class="sv-card-head">
            <span class="sv-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                基本信息
            </h3>
            <span class="sv-type-badge">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                调查配置
            </span>
        </div>
        <div class="sv-card-body">
            <div class="sv-form-row">
                <div class="sv-field" style="flex:1; min-width:300px;">
                    <label>调查名称</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="100%" placeholder="请输入调查或测验的名称"></asp:TextBox>
                </div>
                <div class="sv-field">
                    <label>类型</label>
                    <asp:DropDownList ID="DDLvtype" runat="server">
                        <asp:ListItem Value="0">📋 问卷调查</asp:ListItem>
                        <asp:ListItem Value="1">✏️ 课堂测验</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="sv-field">
                    <label>&nbsp;</label>
                    <div class="sv-check-wrap">
                        <asp:CheckBox ID="CheckClose" runat="server" />
                        <label for="<%=CheckClose.ClientID %>">暂停发布</label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 调查内容 -->
    <div class="sv-card">
        <div class="sv-card-head">
            <span class="sv-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                调查内容
            </h3>
        </div>
        <div class="sv-card-body">
            <div class="sv-editor-section">
                <div class="sv-editor-label">
                    <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                    使用富文本编辑器编写调查内容
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
                            editor = K.create('textarea[name="ctl00$Content$mcontent"]', {
                                resizeType: 1,
                                newlineTag: "br",
                                uploadJson : upjs,
                                fileManagerJson : fmjs,
                                allowFileManager : true,
                                filterMode : false
                            });
                        });
                    </script>
                    <textarea id="mcontent" runat="server" style="width:100%; height:260px;"></textarea>
                </div>
            </div>
        </div>
    </div>

    <!-- 提交 -->
    <div class="sv-card">
        <div class="sv-card-body" style="padding: 20px 28px;">
            <asp:Label ID="Labelmsg" runat="server" CssClass="sv-msg"></asp:Label>
            <div class="sv-actions">
                <asp:Button ID="Btnadd" runat="server" Text="✦ 添加调查" OnClick="Btnadd_Click" CssClass="sv-btn sv-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="返回" OnClick="BtnCourse_Click" CssClass="sv-btn" />
            </div>
        </div>
    </div>
</div>
</asp:Content>

