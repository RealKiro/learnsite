<%@ page title="" language="C#" stylesheettheme="Student" autoeventwireup="true" inherits="Student_mynum, LearnSite" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>学号查询</title>
    <link href="../App_Themes/Student/StyleSheet.css" rel="stylesheet" type="text/css" />
    <link href="../js/tooltip.css" rel="stylesheet" type="text/css" />
    <script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>

</head>
<body class="ground">
    <form id="form1" runat="server">
    <center>
        <div class="studmasterhead">
            <div class="banner">
            </div>
            <center>
                <div class="menu">
                </div>
            </center>
            <center>
                <div class="placeauto">
                    <div >
                        <div class="path">
                        </div>
                        <div id="student">
                                <br />
                            <div style="line-height: 20px; font-size: 11pt; font-family: 宋体, Arial, Helvetica, sans-serif;">
                                年级：<asp:DropDownList 
                                    ID="DDLgrade" runat="server" Width="50px" AutoPostBack="True" 
                                    onselectedindexchanged="DDLgrade_SelectedIndexChanged">
                                </asp:DropDownList>
                                &nbsp; 班级：<asp:DropDownList ID="DDLclass" runat="server" Width="50px" 
                                    AutoPostBack="True" onselectedindexchanged="DDLclass_SelectedIndexChanged">
                                </asp:DropDownList>
                                &nbsp;
                                <asp:Button ID="BtnSearch" runat="server" OnClick="BtnSearch_Click" Text="查询" BorderStyle="None"
                                    CssClass="buttonimg" Font-Size="Larger" Height="28px" />
                                &nbsp;密码：<asp:TextBox ID="TextBoxPwd" runat="server" ReadOnly="True" CssClass="textboxcenter"
                                    Width="80px" BorderColor="#999999" BorderStyle="Dashed" BorderWidth="1px" 
                                    onClick="copy()" Font-Bold="True" Font-Size="X-Large" ForeColor="#FF6666">123</asp:TextBox>
                            </div>
                            <div>
                            <center>
                                <asp:DataList ID="DataListsnum" runat="server" RepeatDirection="Horizontal" RepeatColumns="10"
                                    CellPadding="8" OnItemDataBound="DataListsnum_ItemDataBound" 
                                    HorizontalAlign="Center" CellSpacing="2">
                                    <ItemTemplate>
                                        <div class="stunum">
                                            <asp:Image ID="ImageStu" class="stuimg" runat="server" Visible="True" /><br />
                                            <asp:HyperLink ID="HLSnum" runat="server" Text='<%# Eval("Sname") %>' ToolTip='<%# Eval("Snum") %>'  CssClass="stulink"></asp:HyperLink>
                                        </div>
                                    </ItemTemplate>
                                </asp:DataList>
                                </center>
                            </div>
                        </div>
                    </div>
                </div>
            </center>
        </div>
    </center>
    <script src="../js/ToolTip.js" type="text/javascript"></script>
    <script type="text/javascript">
        var msg = document.getElementById("TextBoxPwd");  
        msg.title ='点击复制';
        function copy() {          
            // 使用示例
            copyTextToClipboard(msg.value);
            msg.title ='已复制';
        }
        async function copyTextToClipboard(text) {
            try {
                await navigator.clipboard.writeText(text);
                console.log('已复制');
            } catch (err) {
                console.error('Failed to copy: ', err);
            }
        }
    </script>
    </form>
</body>
</html>
