<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_softadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .sa-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .sa-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .sa-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .sa-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .sa-title .sa-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .sa-title .sa-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sa-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .sa-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .sa-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .sa-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .sa-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sa-card-body { padding: 24px; }

    /* 表单布局 */
    .sa-form-row {
        display: flex; align-items: center; gap: 20px;
        margin-bottom: 18px; flex-wrap: wrap;
    }
    .sa-form-group { display: flex; align-items: center; gap: 8px; }
    .sa-form-group label {
        font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap;
    }
    .sa-form-group input[type="text"],
    .sa-form-group select {
        padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; font-family: inherit;
    }
    .sa-form-group input[type="text"]:focus,
    .sa-form-group select:focus {
        border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1);
    }
    .sa-form-group input[type="text"] { min-width: 400px; }
    .sa-form-group .sa-select { min-width: 260px; }
    .sa-form-checks { display: flex; align-items: center; gap: 16px; }
    .sa-form-checks label, .sa-form-checks span { font-size: 13px; color: #475569; }

    /* 编辑器区域 */
    .sa-editor-wrap { margin-bottom: 20px; }
    .sa-editor-wrap textarea { width: 100% !important; }

    /* ── KindEditor 现代化美化 ── */
    .sa-editor-wrap .ke-container {
        border: 1px solid #e2e8f0 !important;
        border-radius: 10px !important;
        overflow: hidden !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        transition: border-color .2s, box-shadow .2s;
    }
    .sa-editor-wrap .ke-container:focus-within {
        border-color: #818cf8 !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,.1), 0 1px 4px rgba(0,0,0,.04) !important;
    }
    /* 工具栏 */
    .sa-editor-wrap .ke-toolbar {
        background: linear-gradient(180deg, #f8f9fc 0%, #f1f3f8 100%) !important;
        border-bottom: 1px solid #e5e7f0 !important;
        padding: 6px 10px !important;
    }
    .sa-editor-wrap .ke-toolbar .ke-outline {
        border: 1px solid transparent !important;
        border-radius: 6px !important;
        margin: 2px 1px !important;
        padding: 3px 4px !important;
        transition: all .15s ease;
    }
    .sa-editor-wrap .ke-toolbar .ke-outline:hover {
        background: rgba(99,102,241,.08) !important;
        border-color: rgba(99,102,241,.18) !important;
    }
    .sa-editor-wrap .ke-toolbar .ke-on,
    .sa-editor-wrap .ke-toolbar .ke-selected {
        background: rgba(99,102,241,.12) !important;
        border-color: #818cf8 !important;
    }
    .sa-editor-wrap .ke-toolbar .ke-separator {
        border-left: 1px solid #d5d9e4 !important;
        border-right: none !important;
        margin: 3px 5px !important;
        opacity: .6;
    }
    /* 编辑区 */
    .sa-editor-wrap .ke-edit {
        background: #fff !important;
    }
    /* 状态栏 */
    .sa-editor-wrap .ke-statusbar {
        background: #f8f9fc !important;
        border-top: 1px solid #e5e7f0 !important;
    }

    /* 上传区域 */
    .sa-upload-area {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 16px 20px; background: #f8fafc; border: 1px dashed #d1d5db;
        border-radius: 10px; margin-bottom: 18px;
    }
    .sa-upload-area label { font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap; }

    /* 消息 */
    .sa-msg { font-size: 13px; color: #ef4444; margin-bottom: 14px; display: block; }

    /* 按钮 */
    .sa-actions { display: flex; align-items: center; gap: 12px; margin-top: 6px; }
    .sa-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 24px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .sa-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .sa-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .sa-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.3); color: #fff; }

    /* 提示 */
    .sa-tip {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 16px; border-radius: 8px;
        background: #eff6ff; border: 1px solid #dbeafe; color: #1d4ed8;
        font-size: 12px; line-height: 1.5;
    }
    .sa-tip svg { width: 16px; height: 16px; stroke: #3b82f6; fill: none; stroke-width: 2; flex-shrink: 0; }
</style>

<div class="sa-page">
    <!-- 页面标题 -->
    <div class="sa-header">
        <div class="sa-title-wrap">
            <div class="sa-title">
                <span class="sa-icon">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                </span>
                添加自学资源
            </div>
            <div class="sa-subtitle">填写资源信息并上传文件，添加后可在资源列表中管理</div>
        </div>
    </div>

    <!-- 基本信息卡片 -->
    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                基本信息
            </div>
        </div>
        <div class="sa-card-body">
            <!-- 资源名称 -->
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>资源名称</label>
                    <asp:TextBox ID="Texttitle" runat="server" Width="500px" SkinID="TextBoxNormal"></asp:TextBox>
                </div>
            </div>
            <!-- 分类/属性/学分 -->
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>资源分类</label>
                    <asp:DropDownList ID="ddlcategory" runat="server" CssClass="sa-select"></asp:DropDownList>
                </div>
                <div class="sa-form-group">
                    <label>资源属性</label>
                    <asp:DropDownList ID="DDLclass" runat="server" Font-Size="9pt" Width="80px">
                        <asp:ListItem Selected="True">教程</asp:ListItem>
                        <asp:ListItem>微课</asp:ListItem>
                        <asp:ListItem>资料</asp:ListItem>
                        <asp:ListItem>软件</asp:ListItem>
                        <asp:ListItem>游戏</asp:ListItem>
                        <asp:ListItem>课程</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="sa-form-group">
                    <label>学分限制</label>
                    <asp:DropDownList ID="DDLopen" runat="server" Font-Size="9pt">
                        <asp:ListItem Value="10">A</asp:ListItem>
                        <asp:ListItem Value="8">B</asp:ListItem>
                        <asp:ListItem Value="6">C</asp:ListItem>
                        <asp:ListItem Value="4">D</asp:ListItem>
                        <asp:ListItem Value="2">E</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <!-- 选项 -->
            <div class="sa-form-row">
                <div class="sa-form-checks">
                    <asp:CheckBox ID="CheckBoxFhide" runat="server" Text="是否隐藏" />
                    <asp:CheckBox ID="CheckBoxFhid" runat="server" Text="是否共享" />
                </div>
            </div>
        </div>
    </div>

    <!-- 资源内容卡片 -->
    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                资源内容
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-editor-wrap">
                <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                <script>
                    var editor;
                    var cid = '-1';
                    var ty = "Soft";
                    var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
                    var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?cid=' + cid + '&ty=' + ty;
                    KindEditor.ready(function (K) {
                        editor = K.create('textarea[name="textareaItem"]', {
                            resizeType: 1,
                            newlineTag: "br",
                            uploadJson: upjs,
                            fileManagerJson: fmjs,
                            allowFileManager: true,
                            filterMode: false
                        });
                    });
                </script>
                <textarea name="textareaItem" style="width:100%; height:300px;"></textarea>
            </div>
        </div>
    </div>

    <!-- 上传与提交卡片 -->
    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                上传与提交
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-upload-area">
                <label>上传可限制资源：</label>
                <asp:FileUpload ID="FUsoft" runat="server" BorderColor="#DBDBDB" BorderWidth="1px" Font-Size="9pt" BorderStyle="Solid" />
            </div>
            <asp:Label ID="Labelmsg" runat="server" CssClass="sa-msg"></asp:Label>
            <div class="sa-actions">
                <asp:Button ID="Btnadd" runat="server" Text="添 加" OnClick="Btnadd_Click" CssClass="sa-btn sa-btn-primary" />
                <asp:Button ID="Btnreturn" runat="server" Text="返 回" OnClick="Btnreturn_Click" CssClass="sa-btn" />
            </div>
            <div style="margin-top: 16px;">
                <div class="sa-tip">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    资源属性为「教程」和「微课」时，学生在浏览学习时能提交自学作品
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>

