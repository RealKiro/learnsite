<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mychange, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">

<div>
    <br />
    <asp:Image ID="Image1" runat="server" ImageUrl="~/images/profile.gif" />
    <strong>推荐组长</strong><br />
    <br />
    <asp:DataList ID="DataListstu" runat="server" DataKeyField="Sid" 
        RepeatColumns="8"  Width="100%" onitemcommand="DataListstu_ItemCommand" 
        onitemdatabound="DataListstu_ItemDataBound">
            <ItemTemplate>
                <div style="margin: auto; border: 1px solid #E3E3E3; width: 100px" >
                <div class="onlinebg">
                    <asp:HyperLink ID="HyperQname" runat="server"  Font-Underline="False"
                        Height="20px" Text='<%# Eval("Sname") %>' ></asp:HyperLink>
                    
                    <asp:ImageButton ID="ImageBtnGroup" runat="server" CausesValidation="False" 
                        CommandArgument='<%# Eval("Sid") %>' CommandName="ChangeGroup" 
                        ImageUrl="~/images/gcard.gif"  />
                </div><br/>
                    <asp:Label ID="Labelvote" runat="server" Text='<%# Eval("Steam") %>' ToolTip="组长票数！" ></asp:Label>票<br/>
                    <asp:Label ID="LabelSleader" runat="server" Text='<%# Bind("Sleader") %>' Visible="false" ></asp:Label>   
                    <asp:Label ID="LabelSnum" runat="server" Text='<%# Bind("Snum") %>' Visible="false" ></asp:Label>   
                                     
                    <asp:ImageButton ID="LinkBtnVote" runat="server" CommandArgument='<%# Eval("Sid") %>' 
                        CommandName="Vote" ToolTip="点击推荐组长！"  ImageUrl="~/images/good.png" CausesValidation="False"  CssClass="leadvote" />
					<br/>
               </div>
			   <br/>
            </ItemTemplate>
     </asp:DataList>
    <br />		
</div>
</asp:Content>

