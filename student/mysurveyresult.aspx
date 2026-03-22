<%@ page language="C#" autoeventwireup="true" inherits="student_mysurveyresult, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
            <asp:Label runat="server" ID="Lbtitle" Font-Bold="True" Font-Size="16px"></asp:Label>
    <br />
    <br />
    <div style="border-width: 1px; border-color: #808080; border-bottom-style: dashed; padding-bottom: 2px;">
    　姓名：<asp:Label runat="server" ID="Lbsname" ForeColor="#0066FF"></asp:Label>
    　学号：<asp:Label runat="server" ID="Lbsnum" ForeColor="#0066FF"></asp:Label>
    &nbsp;得分：<asp:Label runat="server" ID="Lbfscore" ForeColor="#0066FF"></asp:Label>
    　类型：<asp:Label runat="server" ID="Lbtypecn" ForeColor="#0066FF" ></asp:Label>
			<asp:Label ID="LabelCid" runat="server" Visible="False"></asp:Label>
			<asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelVid" runat="server" Visible="False"></asp:Label> 
    </div>
        <div style="width: 980px; margin: auto; padding: 2px; text-align: left;">
    <asp:DataList ID="DataListonly" runat="server" DataKeyField="Qid" 
                    RepeatColumns="1" RepeatLayout="Flow" 
            onitemdatabound="DataListonly_ItemDataBound" >
                    <ItemTemplate>
                        <div  style="margin: auto;">
                           <div style=" background-color:#fff;" >
                          第<asp:Label ID="Labelnum" Text='<%# Container.ItemIndex + 1%> ' runat="server" ></asp:Label>题
                          &nbsp;&nbsp;<asp:Label ID="Labelquestion" runat="server" Text='<%# HttpUtility.HtmlDecode( Eval("Qtitle").ToString()) %>'></asp:Label>
                          </div>
						  <div>
                          <asp:RadioButtonList ID="RBLselect" runat="server" RepeatColumns="1" RepeatDirection="Horizontal" 
                                CellPadding="6" CellSpacing="2" RepeatLayout="table">
                                </asp:RadioButtonList>  
						  </div>
                            <asp:Panel ID="Blanks" runat="server">
                            </asp:Panel>
                          </div>
                    </ItemTemplate>
                </asp:DataList>    
    </div>


    </div>
    </form>
</body>
</html>
