<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" validaterequest="false" autoeventwireup="true" inherits="teacher_htmledit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
.he-wrap { max-width: 1100px; }
.he-header { margin-bottom: 18px; }
.he-title {
    font-size: 20px; font-weight: 700; color: #1e293b;
    display: flex; align-items: center; gap: 10px;
}
.he-title-icon {
    width: 36px; height: 36px;
    background: linear-gradient(135deg, #6366f1, #a78bfa);
    border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.he-title-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.he-subtitle { font-size: 13px; color: #94a3b8; margin-top: 4px; }
.he-card {
    background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
    box-shadow: 0 1px 4px rgba(0,0,0,0.05); margin-bottom: 16px;
}
.he-settings { padding: 14px 20px; display: flex; align-items: center; flex-wrap: wrap; gap: 18px; }
.he-field { display: flex; align-items: center; gap: 8px; }
.he-label { font-size: 13px; font-weight: 500; color: #64748b; white-space: nowrap; }
.he-input {
    height: 34px !important; padding: 0 10px !important;
    border: 1px solid #e2e8f0 !important; border-radius: 8px !important;
    font-size: 13px !important; color: #334155 !important;
    background: #f8fafc !important; font-family: inherit !important;
    transition: border-color 0.2s, box-shadow 0.2s; outline: none;
    box-sizing: border-box !important;
}
.he-input:focus {
    border-color: #818cf8 !important;
    box-shadow: 0 0 0 3px rgba(99,102,241,0.1) !important;
    background: #fff !important;
}
.he-select {
    height: 34px; padding: 0 8px;
    border: 1px solid #e2e8f0; border-radius: 8px;
    font-size: 13px; color: #334155; background: #f8fafc;
    font-family: inherit; cursor: pointer; transition: border-color 0.2s;
}
.he-select:focus { border-color: #818cf8; outline: none; }
.he-check-wrap { display: flex; align-items: center; gap: 6px; }
.he-check-wrap input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: #6366f1; margin: 0; }
.he-check-wrap label { font-size: 13px; color: #475569; cursor: pointer; margin: 0; font-weight: 500; }
.he-editor-area { padding: 14px 16px; }
.he-actions { padding: 14px 20px; display: flex; align-items: center; flex-wrap: wrap; gap: 12px; }
.he-msg { flex: 1; min-width: 0; font-size: 13px; font-weight: 500; color: #10b981; }
.he-actions-right { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.he-btn {
    display: inline-flex !important; align-items: center !important; justify-content: center !important;
    height: 36px !important; padding: 0 18px !important; border-radius: 8px !important;
    cursor: pointer !important; font-size: 13px !important; font-weight: 500 !important;
    font-family: inherit !important; transition: all 0.2s !important;
    width: auto !important; line-height: normal !important;
}
.he-btn-primary {
    background: linear-gradient(135deg, #6366f1, #818cf8) !important;
    color: #fff !important; border: none !important;
    box-shadow: 0 2px 6px rgba(99,102,241,0.30) !important;
}
.he-btn-primary:hover {
    background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
    box-shadow: 0 4px 12px rgba(99,102,241,0.40) !important;
}
.he-btn-secondary {
    background: #f1f5f9 !important; color: #475569 !important;
    border: 1px solid #e2e8f0 !important;
}
.he-btn-secondary:hover { background: #e2e8f0 !important; color: #334155 !important; }
/* Divider line inside settings card */
.he-divider { width: 1px; height: 24px; background: #e8ecf1; flex-shrink: 0; }
</style>

<div class="he-wrap">

    <!-- Page Header -->
    <div class="he-header">
        <div class="he-title">
            <div class="he-title-icon">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            </div>
            网页编辑器
        </div>
        <div class="he-subtitle">编辑网页内容，设置标题、文件名及发布状态</div>
    </div>

    <!-- Settings Card -->
    <div class="he-card">
        <div class="he-settings">
            <div class="he-field">
                <span class="he-label">网页主题</span>
                <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="220px" CssClass="he-input"></asp:TextBox>
            </div>
            <div class="he-divider"></div>
            <div class="he-check-wrap">
                <asp:CheckBox ID="CheckPublish" runat="server" Text="" Checked="True" />
                <label for="<%= CheckPublish.ClientID %>">是否发布</label>
            </div>
            <div class="he-divider"></div>
            <div class="he-field">
                <span class="he-label">网页文件名</span>
                <asp:DropDownList ID="DDLfilename" runat="server" CssClass="he-select">
                    <asp:ListItem>index.html</asp:ListItem>
                    <asp:ListItem>w1.html</asp:ListItem>
                    <asp:ListItem>w2.html</asp:ListItem>
                    <asp:ListItem>w3.html</asp:ListItem>
                    <asp:ListItem>w4.html</asp:ListItem>
                    <asp:ListItem>w5.html</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- Editor Card -->
    <div class="he-card">
        <div class="he-editor-area">
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
            <textarea id="mcontent" runat="server" style="width: 100%; height: 450px;"></textarea>
        </div>
    </div>

    <!-- Actions Card -->
    <div class="he-card">
        <div class="he-actions">
            <div class="he-msg"><asp:Label ID="Labelmsg" runat="server"></asp:Label></div>
            <div class="he-actions-right">
                <div class="he-field">
                    <span class="he-label">自定义评价标准</span>
                    <asp:DropDownList ID="DDLMgid" runat="server" CssClass="he-select" Font-Size="9pt" Width="160px" Font-Names="Arial"></asp:DropDownList>
                </div>
                <asp:Button ID="Btnedit" runat="server" Text="修改主题" OnClick="Btnedit_Click" SkinID="BtnNormal" CssClass="he-btn he-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click" SkinID="BtnNormal" CssClass="he-btn he-btn-secondary" />
            </div>
        </div>
    </div>

</div>
</asp:Content>

