<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="teacher_wareshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<div class="courseshow">
    <br />
        <div   class="missiontitle">
    <asp:Label ID="LabelMtitle"  runat="server" ></asp:Label>
   </div><br />
    <div class="courseother">
       日期：<asp:Label ID="LabelMdate"  runat="server" ></asp:Label>
			&nbsp;作品类型：<asp:Image ID="ImageType" runat="server" />
			<asp:Label ID="LabelMfiletype" runat="server" ></asp:Label>
            &nbsp;<asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" 
            Enabled="False" /> 
             &nbsp;&nbsp; 
            <asp:HyperLink ID="HyperLinkHtml" runat="server" Target="_blank">课件首页</asp:HyperLink>    
            &nbsp;&nbsp; 
            <asp:ImageButton ID="BtnEdit" runat="server" ToolTip="点击修改" 
            ImageUrl="~/images/edit.gif" onclick="BtnEdit_Click" 
           style="width: 16px" />
   &nbsp;<asp:ImageButton ID="BtnReturnSmall" runat="server" ToolTip="返回" 
            ImageUrl="~/images/return.gif" onclick="BtnReturnSmall_Click" 
           style="width: 16px" />
   </div>
        <iframe id="htmliframe" src="<%=WareUrl %>" style="width:100%;height:80vh"></iframe>
		<br />
		<br />

</div> 
    <br />
</asp:Content>

