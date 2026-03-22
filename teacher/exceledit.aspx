<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" validaterequest="false" autoeventwireup="true" inherits="teacher_exceledit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ee-page { display: flex; flex-direction: column; gap: 16px; max-width: 1600px; width: 100%; }
    /* Page header */
    .ee-header {
        display: flex; align-items: center; gap: 12px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e8ecf1;
    }
    .ee-header-icon {
        width: 40px; height: 40px; border-radius: 10px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .ee-header-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .ee-header-title { font-size: 18px; font-weight: 700; color: #1e293b; }
    .ee-header-sub { font-size: 12px; color: #94a3b8; margin-top: 2px; }
    /* Card */
    .ee-card {
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        overflow: hidden;
    }
    .ee-card-header {
        padding: 14px 20px;
        border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; gap: 8px;
        background: #fafbfc;
    }
    .ee-card-header-label {
        font-size: 13px; font-weight: 600; color: #374151;
    }
    .ee-card-header svg { width: 16px; height: 16px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    .ee-card-body { padding: 20px; }
    /* Form row */
    .ee-form-row {
        display: flex; flex-wrap: wrap; align-items: center; gap: 16px;
    }
    .ee-form-item {
        display: flex; align-items: center; gap: 8px;
    }
    .ee-label {
        font-size: 13px; font-weight: 500; color: #374151; white-space: nowrap;
    }
    .ee-form-item input[type="text"],
    .ee-form-item input.TextBoxNormal {
        height: 34px; padding: 0 10px;
        border: 1px solid #d1d5db; border-radius: 7px;
        font-size: 13px; color: #1e293b;
        outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        background: #fff;
    }
    .ee-form-item input[type="text"]:focus,
    .ee-form-item input.TextBoxNormal:focus {
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.10);
    }
    /* Publish badge */
    .ee-publish-wrap { display: flex; align-items: center; gap: 6px; }
    .ee-publish-wrap input[type="checkbox"] { width: 15px; height: 15px; accent-color: #6366f1; cursor: pointer; }
    .ee-publish-wrap label { font-size: 13px; color: #374151; cursor: pointer; }
    /* Example link */
    .ee-example-link {
        display: inline-flex; align-items: center; gap: 5px;
        font-size: 12px; color: #6366f1; text-decoration: none;
        padding: 4px 10px; border-radius: 6px;
        border: 1px solid #e0e7ff; background: #f5f3ff;
        transition: all 0.15s;
    }
    .ee-example-link:hover { background: #e0e7ff; border-color: #a5b4fc; color: #4f46e5; }
    .ee-example-link svg { width: 13px; height: 13px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    /* File upload */
    .ee-upload-wrap {
        display: flex; align-items: center; gap: 8px;
        padding: 8px 12px;
        border: 1px dashed #c7d2fe; border-radius: 8px;
        background: #f5f3ff;
    }
    .ee-upload-wrap svg { width: 16px; height: 16px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    .ee-upload-wrap span { font-size: 12px; color: #6366f1; }
    /* Editor wrapper */
    .ee-editor-wrap { padding: 16px 20px; }
    /* Action bar */
    .ee-action-bar {
        padding: 16px 20px;
        border-top: 1px solid #f1f5f9;
        display: flex; flex-wrap: wrap; align-items: center; gap: 12px;
        background: #fafbfc;
    }
    .ee-action-left { display: flex; align-items: center; gap: 10px; flex: 1; flex-wrap: wrap; }
    .ee-action-right { display: flex; align-items: center; gap: 8px; }
    /* Message label */
    .ee-msg {
        font-size: 13px; font-weight: 500;
        padding: 6px 12px; border-radius: 6px;
        background: #f0fdf4; color: #16a34a;
        border: 1px solid #bbf7d0;
        display: inline-block;
    }
    .ee-msg:empty { display: none; }
    /* Gauge select */
    .ee-gauge-item { display: flex; align-items: center; gap: 7px; }
    .ee-gauge-item select {
        height: 32px; padding: 0 8px;
        border: 1px solid #d1d5db; border-radius: 7px;
        font-size: 12px; color: #374151; background: #fff;
        outline: none; cursor: pointer;
        transition: border-color 0.2s;
    }
    .ee-gauge-item select:focus { border-color: #6366f1; }
    /* Buttons */
    .ee-btn {
        display: inline-flex; align-items: center; gap: 6px;
        height: 36px; padding: 0 18px;
        border-radius: 8px; border: none; cursor: pointer;
        font-size: 13px; font-weight: 600; font-family: inherit;
        transition: all 0.18s ease;
        text-decoration: none;
    }
    .ee-btn svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ee-btn-primary {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff;
        box-shadow: 0 2px 8px rgba(99,102,241,0.25);
    }
    .ee-btn-primary:hover { background: linear-gradient(135deg, #4f46e5, #6366f1); box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px); }
    .ee-btn-secondary {
        background: #f1f5f9; color: #475569;
        border: 1px solid #e2e8f0;
    }
    .ee-btn-secondary:hover { background: #e2e8f0; color: #334155; transform: translateY(-1px); }
    /* Override ASP.NET button defaults */
    input.ee-btn { font-family: inherit; }
</style>

<div class="ee-page">
    <%-- Page Header --%>
    <div class="ee-header">
        <div class="ee-header-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="9" x2="9" y2="21"/><line x1="15" y1="9" x2="15" y2="21"/></svg>
        </div>
        <div>
            <div class="ee-header-title">表格处理</div>
            <div class="ee-header-sub">编辑并修改表格学案内容</div>
        </div>
    </div>

    <%-- Main editing card --%>
    <div class="ee-card">
        <%-- Card header: basic settings --%>
        <div class="ee-card-header">
            <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            <span class="ee-card-header-label">基本信息</span>
        </div>
        <div class="ee-card-body">
            <div class="ee-form-row">
                <div class="ee-form-item">
                    <span class="ee-label">标题</span>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="220px" />
                </div>
                <div class="ee-publish-wrap">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="发布" Checked="True" />
                </div>
                <div class="ee-form-item">
                    <asp:HyperLink ID="HlExample" runat="server" Target="_blank" CssClass="ee-example-link">
                        <svg viewBox="0 0 24 24"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/>
                        </svg>查看实例
                    </asp:HyperLink>
                </div>
                <div class="ee-form-item">
                    <div class="ee-upload-wrap">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        <span>上传文件</span>
                        <asp:FileUpload ID="Fupload" runat="server" Font-Size="10pt" />
                    </div>
                </div>
            </div>
        </div>

        <%-- Editor section --%>
        <div class="ee-card-header" style="border-top:1px solid #f1f5f9;">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="9" x2="9" y2="21"/><line x1="15" y1="9" x2="15" y2="21"/></svg>
            <span class="ee-card-header-label">内容编辑</span>
        </div>
        <div class="ee-editor-wrap">
            <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
            <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
            <script>
                var editor;
                var cid = <%=myCid() %>;
                var ty = "Course";
                var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
                var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?cid=' + cid + '&ty=' + ty;
                KindEditor.ready(function (K) {
                    editor = K.create('textarea[name="ctl00$Content$mcontent"]', {
                        resizeType: 1,
                        newlineTag: "br",
                        uploadJson: upjs,
                        fileManagerJson: fmjs,
                        allowFileManager: true,
                        filterMode: false,
                        afterCreate: function () {
                            this.loadPlugin('autoheight');
                        }
                    });
                });
            </script>
            <textarea id="mcontent" runat="server" style="width:100%; height:450px;"></textarea>
        </div>

        <%-- Action bar --%>
        <div class="ee-action-bar">
            <div class="ee-action-left">
                <asp:Label ID="Labelmsg" runat="server" CssClass="ee-msg" />
                <div class="ee-gauge-item">
                    <span class="ee-label">评价标准</span>
                    <asp:DropDownList ID="DDLMgid" runat="server" Font-Size="9pt" Width="160px" Font-Names="Arial" />
                </div>
            </div>
            <div class="ee-action-right">
                <asp:Button ID="Btnedit" runat="server" Text="修改主题" OnClick="Btnedit_Click"
                    SkinID="BtnNormal" CssClass="ee-btn ee-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click"
                    SkinID="BtnNormal" CssClass="ee-btn ee-btn-secondary" />
            </div>
        </div>
    </div>
</div>
</asp:Content>


