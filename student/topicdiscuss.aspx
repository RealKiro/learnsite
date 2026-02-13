<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" validaterequest="false" autoeventwireup="true" inherits="Student_topicdiscuss, LearnSite" %>

<%@ Register Assembly="Anthem" Namespace="Anthem" TagPrefix="anthem" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
			<asp:Label ID="LabelCid" runat="server" Visible="False"></asp:Label>
			<asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelTid" runat="server" Visible="False"></asp:Label> 
 <div id="student">
 <style>
	.topictext {
		user-select: none;
	}
	
	.topictext:hover {
		background-color:#FFF4E1;
	}
	.topictext img{
		height:200px;
		-webkit-user-drag: none;
		cursor:pointer;
		//pointer-events: none;
	}
	.imgstu
	{
	    width:24px;
	    height:24px;
	    border-radius:12px;
		opacity:0.8;
	}
	
	.imgstu:hover
	{
		opacity:1;
	}
</style>
  <center>
<div  id="topper"  style=" text-align: left; width: 980px;">
    <div style="text-align: left; width: 960px;">
        <asp:ImageButton ID="Btnclock" runat="server" ImageUrl="~/images/clock.gif" 
            onclick="Btnclock_Click" Enabled="False" />        
       <anthem:Label ID="Labeltopic" runat="server" 
            Font-Size="16pt" Font-Bold="True" Font-Names="宋体, Arial, Helvetica, sans-serif"></anthem:Label>
        <anthem:CheckBox ID="TcloseCheck" runat="server" Visible="False" />
    <br />
    </div>
	<div ID="Topics" runat="server" style="font: 12pt/150% Arial;padding:10px;margin:10px;" >
			</div>
    <div ID="TopicsResult" runat="server"  class="topictext" >
        </div>
    <br />
    <div style="text-align: left; width: 930px;overflow: hidden;">
	<br />
    <div>
    <div  class="topicleft">
        <strong>帖子列表</strong>：<anthem:Label ID="Labelreplycount" runat="server"></anthem:Label>
        &nbsp;<anthem:imagebutton ID="ImageBtngoodall" runat="server" 
            ImageUrl="~/images/right.gif" onclick="ImageBtngoodall_Click" 
            ToolTip="给所有未评分的帖子加2分" Visible="False" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<anthem:imagebutton 
            ID="ImageBtngood2" runat="server" 
            ImageUrl="~/images/right.gif" onclick="ImageBtngood2_Click" 
            ToolTip="给所有未评分的帖子加6分" Visible="False" style="width: 12px" />
        </div>
        <div  class="topicright">
      <anthem:ImageButton ID="ImageBtnFresh" runat="server" 
            ImageUrl="~/images/refresh2.gif" onclick="ImageBtnFresh_Click" ToolTip="刷新贴子" />
      <anthem:HyperLink ID="HLbottom" runat="server" BorderStyle="None" 
             BorderWidth="0px" ImageUrl="~/images/bottom.png" NavigateUrl="#bottom" 
            ToolTip="跳到底部"></anthem:HyperLink>
            </div>
            </div>
            <br />
            <div>
    <anthem:GridView ID="GVtopicDiscuss" runat="server" AutoGenerateColumns="False" 
        CellPadding="0" Width="100%" 
        onrowdatabound="GVtopicDiscuss_RowDataBound"  
        DataKeyNames="rid"  PageSize="5" CellSpacing="1" 
            ShowHeader="False" GridLines="None" 
            onrowcommand="GVtopicDiscuss_RowCommand"  >
             <Columns>
                 <asp:TemplateField>
                     <ItemTemplate>   
                     <div style="border: 1px solid #F7F7F7; text-align: left;margin:auto;">
                     <div  class="topichead">
                     <div  class="topicleft">
                         <anthem:Image ID="Imagestu" runat="server"  CssClass="imgstu" />                                            
                         <anthem:Label ID="Labelsname" runat="server"  Text='<%# Bind("Sname") %> '></anthem:Label>：
                         <anthem:Image ID="Imageagree" runat="server" Visible="False" ImageUrl="~/images/good16.png" />
                        <anthem:CheckBox  ID="Ckedit" runat="server" Checked='<%# Bind("Redit") %> ' Visible="False" />
                        <anthem:Label ID="Labelsnum" runat="server"  Text='<%# Bind("Rsnum") %> ' Visible="False"></anthem:Label>
                        <anthem:CheckBox  ID="CheckSleader" runat="server" Checked='<%# Bind("Sleader") %> ' Visible="False" />
                     </div>
                         <div class="topicright">
                         <anthem:Image ID="Imagegroup" runat="server" ImageUrl="~/images/gcard.gif" /> &nbsp;&nbsp;
							 <anthem:Label ID="Labelscore" runat="server" Text='<%# Bind("Rscore") %> ' ToolTip="学分" ForeColor="#333333"></anthem:Label>学分&nbsp;&nbsp;
                         <anthem:ImageButton ID="ImageButtonAgree" runat="server" 
                             CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                        CommandName="Agree" ImageUrl="~/images/good24.gif" ToolTip="点赞"></anthem:ImageButton>
						<anthem:Label ID="Labelagree" runat="server" Text='<%# Bind("Ragree") %> '></anthem:Label>点赞
                         &nbsp;&nbsp;&nbsp;
                         <anthem:Image ID="Imageflag" runat="server" ImageUrl="~/images/topicnormal.png" />
                         <anthem:Label ID="Labelfloor" runat="server"></anthem:Label>楼&nbsp;&nbsp;
						<anthem:ImageButton ID="ImageButtonEdit" runat="server" 
                             CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                        CommandName="Reply" ImageUrl="~/images/edno.gif" />
                        &nbsp;&nbsp;&nbsp;&nbsp;
                         <anthem:ImageButton ID="ImageButtonGood" runat="server" 
                             CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                        CommandName="Good" ImageUrl="~/images/right.gif" ToolTip="加2分"/>
                        &nbsp;&nbsp; &nbsp;&nbsp;
                        <anthem:ImageButton ID="ImageButtonless" runat="server" 
                             CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                        CommandName="Less" ImageUrl="~/images/ban.gif" ToolTip="减2分" />
                        &nbsp;&nbsp;&nbsp;&nbsp;
                         <anthem:ImageButton ID="ImageButtonDel" runat="server" CausesValidation="false" 
                             CommandArgument='<%# Bind("rid") %>' CommandName="Del" 
                             ImageUrl="~/images/delete.gif" />&nbsp;&nbsp;                          				 
                         </div>
                         &nbsp;
                         </div>
                     <div>
                         <div class="topictext">
                         <%# HttpUtility.HtmlDecode( Eval("Rwords").ToString())%>
						 <div style="text-align:right;color:gray; font-Size:12px;">
						 时间：<anthem:Label ID="Labeldate" runat="server" Text='<%# Bind("Rtime") %> '></anthem:Label> 
                         &nbsp; &nbsp;IP：<anthem:Label ID="Labelip" runat="server"  Text='<%# Bind("Rip") %> '></anthem:Label>
						 
						 </div>
                         </div>
						 
                     </div>                       
                        </div>
                     </ItemTemplate>
                 </asp:TemplateField>
             </Columns>             
             <HeaderStyle Font-Bold="False" />
      </anthem:GridView>
      </div>
      
      <div id="bottom"></div>
        <br />
<div  class="topicleft">
        <strong>讨论回复</strong>：<asp:Label ID="Labelreplycountbtm" runat="server"></asp:Label>
        </div>
<div  class="topicright">
        <anthem:ImageButton ID="ImageBtnFreshtwo" runat="server" 
            ImageUrl="~/images/refresh2.gif" onclick="ImageBtnFresh_Click" 
            ToolTip="刷新贴子" />
     <anthem:HyperLink ID="HLtop" runat="server" BorderStyle="None" BorderWidth="0px" 
            ImageUrl="~/images/top.png" NavigateUrl="#topper" ToolTip="跳到顶部"></anthem:HyperLink>
            </div>

      </div>
<div id="plant" runat="server">
<div style="width: 980px; overflow: hidden;  text-align: center;">        
        <br />
    <textarea  name="textareaWord" style="width: 960px;height:260px;" ></textarea> 
	 <script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
	 <script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>
	<script src="../code/jquery.min.js" type="text/javascript"></script>
	<script>
	    var editor;
	    var ty = "Topic";
	    var cid = "<%=myCid %>";
	    var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
	    KindEditor.ready(function (K) {
	        editor = K.create('textarea[name="textareaWord"]', {
	            filterMode: false,
	            resizeType: 1,
	            pasteType: 1,
	            newlineTag: "br",
	            allowPreviewEmoticons: false,
	            uploadJson: upjs,
	            allowImageUpload: true,
	            items: ['formatblock', 'fontname', 'fontsize', '|', 'bold', 'italic', 'forecolor', 'hilitecolor', 'removeformat', '|', 'justifyleft', 'justifycenter', 'justifyright', 'image'],
	            afterChange: function () {
	                K('.word_count').html(this.count('text'));
	            }
	        });
	    });
	</script>  
	
	<script>
	    $(".topictext img").click(function () {
	        console.log("图片点击");
	        var _this = $(this);
	        imgShow("#outerdiv", "#innerdiv", "#bigimg", _this);
	    });

	    $(".topictext img").each(function (i) {
	        $(this).attr("oncontextmenu", "return false;");
	    });

	    function imgShow(outerdiv, innerdiv, bigimg, _this) {
	        debugger
	        var src = _this.attr("src");
	        $(bigimg).attr("src", src);
	        $("<img/>").attr("src", src).on('load', function () {
	            debugger
	            var windowW = $(window).width()
	            var windowH = $(window).height();
	            var realWidth = this.width;
	            var readHeight = this.height;
	            var imgWidth, imgHeight;
	            var scale = 0.8;
	            if (realWidth > windowW + scale) {
	                imgHeight = windowH * scale;
	                imgWidth = imgHeight / readHeight * realWidth;
	                if (imgWidth > windowW * scale) {
	                    imgWidth = windowW * scale;
	                }
	            } else if (realWidth > windowW * scale) {
	                imgWidth = windowW * scale;
	                imgHeight = imgWidth / realWidth * readHeight;
	            } else {
	                imgWidth = realWidth;
	                imgHeight = readHeight;
	            }
	            $(bigimg).css("width", imgWidth);
	            var w = (windowW - imgWidth) / 2;
	            var h = (windowH - imgHeight) / 2;
	            $(innerdiv).css({ "top": h, "left": w });
	            $(outerdiv).fadeIn("fast");
	        });
	        $(outerdiv).click(function () {
	            $(this).fadeOut("fast");
	        });
	    };
    </script>		
		
<div style="width: 860px; text-align: center;">
    您当前输入了 <span class="word_count">0</span> 个文字（不少于2个汉字，最多为300汉字）
    <br /><br />
            <asp:Button ID="Btnword" runat="server" Text="发表讨论" 
                onclick="Btnword_Click" BorderStyle="None" CssClass="buttonimg" 
            Width="80px" />
    <br />
    <anthem:Label ID="Labeldiscuss" runat="server"  SkinID="LabelMsgRed"></anthem:Label>
            <br />
 </div>
    <br />
</div> 
</div>

    <br />
    <div>    
        <anthem:Label ID="Labelnostu" runat="server" ForeColor="#7D7D7D"></anthem:Label>    
    </div>
    <br />
     </div>
   </center>
 </div>
<div id="outerdiv" style="position:fixed;top:0;left:0;background:rgba(0,0,0,0.8);z-index:2;width:100%;height:100%;display:none;">
<div id="innerdiv" style="position:absolute;">
<img id="bigimg" style="pointer-events: none;"  src="" />
</asp:Content>