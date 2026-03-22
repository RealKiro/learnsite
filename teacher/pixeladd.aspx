<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_pixeladd, LearnSite" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<link rel="stylesheet" type="text/css" href="addpage-common.css" />
<div class="sa-page">
    <div class="sa-header">
        <div class="sa-title-wrap">
            <div class="sa-title">
                <span class="sa-icon"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg></span>
                添加主题
            </div>
            <div class="sa-subtitle">选择活动类型并设置内容，添加后可在学案中管理</div>
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
                    <label>活动类型</label>
                    <asp:DropDownList ID="DDLTitle" runat="server" Font-Size="Medium" onselectedindexchanged="DDLTitle_SelectedIndexChanged" AutoPostBack="True">
                        <asp:ListItem Value="11">像素画</asp:ListItem>
                        <asp:ListItem Value="36">素材库</asp:ListItem>
                        <asp:ListItem Value="37">网站设计</asp:ListItem>
                        <asp:ListItem Value="17">二维码</asp:ListItem>
                        <asp:ListItem Value="18">在线文档</asp:ListItem>
                        <asp:ListItem Value="19">演示文稿</asp:ListItem>
                        <asp:ListItem Value="20">海报设计</asp:ListItem>
                        <asp:ListItem Value="21">风格迁移</asp:ListItem>
                        <asp:ListItem Value="22">图像分类</asp:ListItem>
                        <asp:ListItem Value="23">人脸识别</asp:ListItem>
                        <asp:ListItem Value="24">物联网MQTT</asp:ListItem>
                        <asp:ListItem Value="25">手绘画布</asp:ListItem>
                        <asp:ListItem Value="26">推箱子地图</asp:ListItem>
                        <asp:ListItem Value="27">人工智能对话</asp:ListItem>
                        <asp:ListItem Value="28">语音合成</asp:ListItem>
                        <asp:ListItem Value="29">文字识别</asp:ListItem>
                        <asp:ListItem Value="30">声音分析</asp:ListItem>
                        <asp:ListItem Value="31">井字棋</asp:ListItem>
                        <asp:ListItem Value="32">手写数字识别</asp:ListItem>
                        <asp:ListItem Value="33">Markdown写作</asp:ListItem>
                        <asp:ListItem Value="34">嵌入本地网页</asp:ListItem>
                        <asp:ListItem Value="35">文生图</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>主题</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="400px"></asp:TextBox>
                </div>
                <div class="sa-form-checks">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Checked="True" />
                </div>
            </div>
            <div class="sa-form-row">
                <asp:CheckBoxList ID="Ckdevice" runat="server" RepeatLayout="Flow" Visible="False" RepeatDirection="Horizontal" Font-Size="Small">
                    <asp:ListItem Value="led">小灯</asp:ListItem>
                    <asp:ListItem Value="fan">风扇</asp:ListItem>
                    <asp:ListItem Value="pump">水泵</asp:ListItem>
                    <asp:ListItem Value="temperature">温度</asp:ListItem>
                    <asp:ListItem Value="humidity">湿度</asp:ListItem>
                    <asp:ListItem Value="sound">声音</asp:ListItem>
                    <asp:ListItem Value="light">亮度</asp:ListItem>
                    <asp:ListItem Value="distance">距离</asp:ListItem>
                </asp:CheckBoxList>
                <asp:TextBox ID="Texturl" runat="server" SkinID="TextBoxNormal" Width="200px" Visible="False">https://image.baidu.com</asp:TextBox>
            </div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                主题内容
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
                <asp:Button ID="Btnadd" runat="server" Text="添加主题" OnClick="Btnadd_Click" CssClass="sa-btn sa-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click" CssClass="sa-btn" />
            </div>
        </div>
    </div>
</div>
</asp:Content>
