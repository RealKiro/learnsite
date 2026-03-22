<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_missionadd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<link rel="stylesheet" type="text/css" href="addpage-common.css" />
<div class="sa-page">
    <div class="sa-header">
        <div class="sa-title-wrap">
            <div class="sa-title">
                <span class="sa-icon"><svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg></span>
                添加活动
            </div>
            <div class="sa-subtitle">设置活动内容与选项，添加后可在学案中管理</div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                基本信息
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>活动名称</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="400px"></asp:TextBox>
                </div>
                <div class="sa-form-group">
                    <label>作品类型</label>
                    <asp:DropDownList ID="DDLmfiletype" runat="server" Width="80px" Font-Names="Arial"></asp:DropDownList>
                </div>
            </div>
            <div class="sa-form-row">
                <div class="sa-form-checks">
                    <asp:CheckBox ID="CheckUpload" runat="server" Text="是否提交" Checked="True" />
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Checked="True" />
                    <asp:CheckBox ID="CheckGroup" runat="server" Text="小组合作" />
                    <asp:CheckBox ID="CheckRemote" runat="server" Text="远程图片" ToolTip="自动下载远程图片，有时失效！" />
                    <asp:CheckBox ID="CheckMicoWorld" runat="server" Text="上次作品" Checked="False" ToolTip="显示上一节课作品，适合项目学习" />
                </div>
            </div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                活动内容
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-editor-wrap">
                <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                <script>
                    var editor;
                    var cid= <%=myCid() %>;
                    var ty="Course";
                    var upjs= '../kindeditor/aspnet/upload_json.aspx?cid='+cid+'&Ty='+ty;
                    var fmjs='../kindeditor/aspnet/file_manager_json.aspx?cid='+cid+'&Ty='+ty;
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
                <textarea name="textareaItem" style="width:100%; height:550px;"></textarea>
            </div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                提交设置
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>选择自定义评价标准</label>
                    <asp:DropDownList ID="DDLMgid" runat="server" Font-Size="9pt" Width="160px" Font-Names="Arial"></asp:DropDownList>
                </div>
            </div>
            <asp:Label ID="Labelmsg" runat="server" CssClass="sa-msg"></asp:Label>
            <div class="sa-actions">
                <asp:Button ID="Btnadd" runat="server" Text="添加活动" OnClick="Btnadd_Click" CssClass="sa-btn sa-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click" CssClass="sa-btn" />
            </div>
        </div>
    </div>
</div>
</asp:Content>

