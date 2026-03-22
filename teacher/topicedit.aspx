<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_topicedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link rel="stylesheet" type="text/css" href="addpage-common.css" />

<div class="sa-page">
    <!-- 顶部标题区域，与 programedit 保持一致风格 -->
    <div class="sa-header">
        <div class="sa-title-wrap">
            <div class="sa-title">
                <span class="sa-icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5A8.5 8.5 0 0 1 21 11v.5z" />
                    </svg>
                </span>
                修改讨论主题
            </div>
            <div class="sa-subtitle">编辑课堂讨论的标题与内容，修改后学生端将实时更新</div>
        </div>
    </div>

    <!-- 基本信息卡片 -->
    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                </svg>
                基本信息
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>讨论主题</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="400px"></asp:TextBox>
                </div>
            </div>
            <div class="sa-form-row">
                <div class="sa-form-checks">
                    <asp:CheckBox ID="CheckClose" runat="server" Text="是否暂停" />
                </div>
            </div>
        </div>
    </div>

    <!-- 讨论内容卡片（KindEditor） -->
    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                    <polyline points="14 2 14 8 20 8" />
                    <line x1="16" y1="13" x2="8" y2="13" />
                    <line x1="16" y1="17" x2="8" y2="17" />
                </svg>
                讨论内容
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-editor-wrap">
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
                <textarea id="mcontent" runat="server" style="width: 100%; height:550px;"></textarea>
            </div>
        </div>
    </div>

    <!-- 操作卡片 -->
    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24">
                    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
                </svg>
                操作
            </div>
        </div>
        <div class="sa-card-body">
            <asp:Label ID="Labelmsg" runat="server" CssClass="sa-msg"></asp:Label>
            <div class="sa-actions">
                <asp:Button ID="Btnedit" runat="server" Text="保存修改" OnClick="Btnedit_Click" CssClass="sa-btn sa-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="主题返回" OnClick="BtnCourse_Click" CssClass="sa-btn" />
            </div>
        </div>
    </div>
</div>

<style>
    /* 隐藏旧布局（与 programedit 保持一致） */
    .cplace, .cleft, .placehold {
        display: none !important;
    }

    /* 简单的成功/错误提示色，可配合后台文本使用 */
    .sa-msg.success {
        color: #16a34a;
        font-weight: 500;
    }
    .sa-msg.error {
        color: #dc2626;
        font-weight: 500;
    }
</style>

<script>
    // 根据提示文字内容为消息标签添加简易状态样式
    (function () {
        var label = document.getElementById('<%= Labelmsg.ClientID %>');
        if (label) {
            var text = label.innerText || label.textContent || '';
            if (text.trim() !== '') {
                if (text.indexOf('成功') !== -1 || text.indexOf('完成') !== -1) {
                    label.className += ' success';
                } else if (text.indexOf('错误') !== -1 || text.indexOf('失败') !== -1) {
                    label.className += ' error';
                }
            }
        }
    })();
</script>

</asp:Content>
