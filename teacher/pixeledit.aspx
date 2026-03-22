<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_pixeledit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<div  class="cplace">
    <div  class="cleft">
        <asp:DropDownList ID="DDLTitle" runat="server" 
            Font-Size="Medium" Enabled="False" AutoPostBack="True">
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
        主题：<asp:TextBox ID="Texttitle" runat="server"  SkinID="TextBoxNormal" 
            Width="200px" ></asp:TextBox>
        <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布"  Checked="True" />
        <asp:CheckBoxList ID="Ckdevice" runat="server" RepeatLayout="Flow" 
            Visible="False" RepeatDirection="Horizontal" Font-Size="Small">
            <asp:ListItem Value="led">小灯</asp:ListItem>
            <asp:ListItem Value="fan">风扇</asp:ListItem>
            <asp:ListItem Value="pump">水泵</asp:ListItem>
            <asp:ListItem Value="temperature">温度</asp:ListItem>
            <asp:ListItem Value="humidity">湿度</asp:ListItem>
            <asp:ListItem Value="sound">声音</asp:ListItem>
            <asp:ListItem Value="light">亮度</asp:ListItem>
            <asp:ListItem Value="distance">距离</asp:ListItem>
        </asp:CheckBoxList>

        <asp:TextBox ID="Texturl" runat="server"  SkinID="TextBoxNormal" Width="200px"  Visible="False">https://image.baidu.com</asp:TextBox>

        </div> 
        <div  >
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
                filterMode : false,
					afterCreate : function() {
						this.loadPlugin('autoheight');
					}
		        });
		    });
		</script>
    <textarea  id ="mcontent" runat ="server" style="width: 830px; height:450px;" ></textarea> 
    </div>
     <div  class="placehold">
               <asp:Label ID="Labelmsg" runat="server" ></asp:Label>
               <br />
               选择自定义评价标准：<asp:DropDownList ID="DDLMgid" runat="server" Font-Size="9pt"
            Width="160px" Font-Names="Arial">
        </asp:DropDownList>
               <br />
         <br />
              <asp:Button ID="Btnedit" runat="server"  Text="修改主题" OnClick="Btnedit_Click"  SkinID="BtnNormal" />&nbsp;&nbsp;&nbsp;
              <asp:Button ID="BtnCourse" runat="server"  Text="学案返回" OnClick="BtnCourse_Click"  SkinID="BtnNormal" /><br />
         <br />
         </div>
           
        </div>
</asp:Content>


