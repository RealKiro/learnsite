<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mygroup, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
    <div>
    <div style="margin: auto; " >
        <asp:Panel ID="Panelapply" runat="server">
            <asp:GridView ID="GVgroup" runat="server" 
                AutoGenerateColumns="False" Caption="小组申请" 
                onrowdatabound="GVgroup_RowDataBound" SkinID="GridViewInfo" 
                Width="98%" EnableModelValidation="True" CellPadding="5" 
                DataKeyNames="Sid" onrowcommand="GVgroup_RowCommand">
                <Columns>
                    <asp:BoundField HeaderText="序号" Visible="false">
                    <ItemStyle Width="40px" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Sgtitle" HeaderText="小组名称"   >
                    <ItemStyle Width="120px" Font-Size="11pt" HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="组长">
                        <ItemTemplate>
                            <asp:Image ID="Imageflag" runat="server" ImageUrl="~/images/gflag.gif" />
                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("Sname") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle Width="80px"   Font-Size="11pt" HorizontalAlign="Left"  />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="成员">
                        <ItemTemplate>
                            <asp:Label ID="Labelmember" runat="server"></asp:Label>
                        </ItemTemplate>
                        <ItemStyle   Font-Size="9pt" HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="组队" ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="false" 
                            CommandArgument='<%# Eval("Sid") %>'  CommandName="AddGroup" Text="参加" ></asp:LinkButton>
                            <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="false" 
                            CommandArgument='<%# Eval("Sid") %>'  CommandName="outGroup" Text="退组" ></asp:LinkButton>
                        </ItemTemplate>
                    <ItemStyle Width="90px"   />
                    </asp:TemplateField>
                </Columns>
                
                <RowStyle Height="40px" />
                
            </asp:GridView>
        </asp:Panel>
        <asp:Panel ID="PanelSgtitle" runat="server">
        <div>我的小组名称：<asp:TextBox ID="TextBox1" runat="server" BorderColor="#CCCCCC" 
                BorderStyle="Dashed" BorderWidth="1px"></asp:TextBox>
            &nbsp;
            <asp:Button ID="BtnSgtitle" runat="server" onclick="BtnSgtitle_Click" 
                SkinID="buttonSkin" Text="修改" />
            </div>
        </asp:Panel>
        <br />
        <div style=" text-align:left; padding:10px;">
            当前未参加的同学：<br />
        <asp:Label ID="Labelfree" runat="server" ></asp:Label>
        </div>
    <br />		
</div>
<br />
</div>
</asp:Content>

