<%@ page language="C#" autoeventwireup="true" inherits="student_webspace, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
    .by {margin: 0px;background-color: #E6F0E7}
    .disk{margin: auto; text-align: center; width: 550px; font-size: 11pt; font-family: 宋体, Arial, Helvetica, sans-serif;}
    .dhead{border-width: 1px; border-color: #CCCCCC; padding: 2px; background-color: #CFE4D0; border-bottom-style: solid;}
    .dcontext{margin: auto; padding: 2px;background-color: #FFFFDD; height: 340px; overflow-x: hidden;}
    .dfile{border-width: 1px; border-color: #E6E8E6; height:36px; border-top-style: dashed; text-align: left; padding:4px; font-family: Arial; }
    .txt{ line-height:16px; }
    .leftcss{ float:left; left:10px; width:12px;margin:auto;}
    .rightcss{ float:right; right:2px;width:88%;}
	.leftlist{float:left;width:75%;font-size: 12pt;}
	.rightlist{float:right;width:20%;font-size: 9pt; text-align:right;}
	.nomenu{user-select: none;padding-right:10px;}
	.btnup{right:50%; background-color:#E6F0E7;border-width:1px;}	
	.btnup:hover{background-color:#DAF1DC;}
	.dfile:hover{background-color: #CFE4D0;}
	.dfile img{max-height:32px;max-width:32px;}
	.del{opacity:0.02;}
	.del:hover{opacity:0.9;}
	       
    .btn-info {
        background: #17a2b8;
        color: white;
        opacity:0.8;
        
        padding: 2px 4px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        width:80px;
    }  
    .btn-info:hover {
        opacity: 1;
    }
    </style>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/dropzone/dropzone-min.js" type="text/javascript"></script>
    <link href="../code/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
</head>
<body  class="by">
    <form id="form1" class="dropzone" runat="server">
    <div id="doc_area" class="disk" > 
        <div class="dhead">
             <asp:Label ID="Labeltitle" runat="server" Font-Bold="True" Font-Size="11pt"></asp:Label>
        </div>   
        <div id="file_area" class="dcontext"  > 
                <asp:DataList ID="Dlfilelist" runat="server" 
                    RepeatColumns="1" RepeatDirection="Horizontal" CellPadding="0" 
                    CellSpacing="0" Width="99%" 
                    HorizontalAlign="Center" onitemcommand="Dlfilelist_ItemCommand" 
                    onitemdatabound="Dlfilelist_ItemDataBound" >
                    <ItemTemplate>
                        <div class="dfile"> 
                           <div class="leftlist" >                            
                            <asp:HyperLink ID="HLtype" runat="server"  ImageUrl='<%# Eval("Kftpe") %>' CssClass="nomenu"></asp:HyperLink>
                            <asp:HyperLink ID="HLfname" runat="server" NavigateUrl='<%# Eval("Kfurl") %>' Target="_blank" Text='<%# Eval("KfnameShort") %>' Font-Underline="False" ></asp:HyperLink>                             
                           </div>
						   <div class="rightlist">	
                            <button type="button" class="btn-info" title="复制链接" onclick="copyFileLink('<%# Eval("KfnameShort") %>')">复制链接</button>			
                            <asp:Label ID="Labelnum" runat="server" Text='<%# Eval("Kfnum") %>'  Visible="false"></asp:Label> 
                            <asp:ImageButton ID="ImgBtnDelete" runat="server" CommandArgument='<%# Eval("Kfurl") %>' 
                                CommandName="D" ImageUrl="~/images/delete.gif" ToolTip="删除"  CssClass="del" />
                            </div>
                        </div>
                    </ItemTemplate>
                    <SeparatorStyle BorderColor="Silver" BorderStyle="Dotted" BorderWidth="1px" />
                </asp:DataList>        
        </div>
		<div id="up_area" style="padding-top:10px;">
		  <button type="button" id="btnupload" class="btnup"> <i class="fa fa-upload" aria-hidden="true"></i> 文件上传</button>
          <span id="message"></span>
		<div>
     </div>    
    </div>
    </div>

    </form>
    <script type="text/javascript" >
        var urlstr = "share.ashx?isweb=true";

        $("#btnupload").dropzone({
            url: urlstr,
            method: "POST",
            addRemoveLinks: true,
            maxFiles: 1, //一次性上传的文件数量上限
            maxFilesize: 50, //MB
            uploadMultiple: false,
            parallelUploads: 100,
            acceptedFiles: ".png,.jpg,.jpeg,.gif,.mp4,.mp3",
            previewsContainer: false,
            success: function (file, response, e) {
                location.reload();
            }
        });

        function copyFileLink(fileUrl) {
            // 阻止事件冒泡和默认行为，避免页面刷新
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            // 确保URL是完整的（如果是相对路径）
            //var fullUrl = fileUrl.replaceAll("~/", "");
            copyToClipboard(fileUrl);
        }
        $("#file_area").mouseout(function () {
            $("#message").html("");
        });

        // 复制文本到剪贴板
        function copyToClipboard(text) {
            // 创建临时textarea元素
            var textarea = document.createElement('textarea');
            textarea.value = text;
            document.body.appendChild(textarea);

            // 选择文本并复制
            textarea.select();
            textarea.setSelectionRange(0, 99999); // 对于移动设备

            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    //console.log('复制成功: ' + text);
                    // alert('复制链接成功: ' + text);
                    $("#message").html("复制成功!");
                } else {
                    console.error('复制失败');
                }
            } catch (err) {
                console.error('复制错误: ', err);

                // 如果execCommand失败，尝试使用新的Clipboard API
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(text).then(function () {
                        console.log('使用Clipboard API复制成功');
                    }, function (err) {
                        console.error('使用Clipboard API复制失败: ', err);
                    });
                }
            }

            // 移除临时元素
            document.body.removeChild(textarea);
        }

    </script>
</body>
</html>
