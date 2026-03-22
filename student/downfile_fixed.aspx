<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_downfile, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">
<style>
.df-page { width: 100%; max-width: 1200px; margin: 0 auto; padding: 20px; font-family: 'Microsoft YaHei',Arial,sans-serif; }
.df-card { background: #fff; border-radius: 12px; border: 1px solid #e5e7eb; box-shadow: 0 2px 8px rgba(0,0,0,.08); margin-bottom: 20px; padding: 24px; }
.df-title { font-size: 24px; font-weight: 700; color: #1e293b; margin-bottom: 16px; }
.df-meta { background: #f8fafc; padding: 16px; border-radius: 8px; margin-bottom: 20px; }
.df-meta span { margin-right: 20px; color: #64748b; }
.df-content { line-height: 1.8; color: #334155; margin: 20px 0; }
.df-btn { display: inline-block; padding: 10px 24px; background: #3b82f6; color: #fff; border-radius: 8px; text-decoration: none; font-weight: 600; }
.df-btn:hover { background: #2563eb; }
</style>

<div class="df-page">
    <div class="df-card">
        <h1 class="df-title"><asp:Label ID="Labeltitle" runat="server"></asp:Label></h1>
        
        <div class="df-meta">
            <span><strong>属性:</strong> <asp:Label ID="Labelclass" runat="server"></asp:Label></span>
            <span><strong>格式:</strong> <asp:Image ID="ImageType" runat="server" /> <asp:Label ID="Labelfiletype" runat="server"></asp:Label></span>
            <span><strong>点击:</strong> <asp:Label ID="Labelhit" runat="server"></asp:Label></span>
            <span><strong>日期:</strong> <asp:Label ID="Labeldate" runat="server"></asp:Label></span>
            <span><strong>学分:</strong> <asp:Label ID="Labelopen" runat="server"></asp:Label></span>
        </div>
        
        <div class="df-content">
            <asp:Literal ID="Labelcontent" runat="server"></asp:Literal>
        </div>
        
        <div style="margin:20px 0;">
            <asp:Image ID="ImageDown" runat="server" ImageUrl="~/images/down1.gif" style="display:none;" />
            <asp:LinkButton ID="LBtnfile" runat="server" OnClick="LBtnfile_Click" Visible="False" CssClass="df-btn">⬇ 点击下载</asp:LinkButton>
            <asp:HyperLink ID="HLurl" runat="server" Visible="false" CssClass="df-btn"></asp:HyperLink>
        </div>
        
        <div><asp:Label ID="Labelmsg" runat="server"></asp:Label></div>
    </div>
    
    <asp:Label ID="LabelFyid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="LabelFid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="LabelSid" runat="server" Visible="False"></asp:Label>
    
    <div style="display:none;">
        <asp:GridView ID="GVSoft" runat="server" AllowPaging="True" AutoGenerateColumns="False"
            OnPageIndexChanging="GVSoft_PageIndexChanging" OnRowDataBound="GVSoft_RowDataBound">
            <Columns>
                <asp:TemplateField HeaderText="标题">
                    <ItemTemplate>
                        <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# Eval("fid", "downfile.aspx?Fid={0}") %>'
                            Text='<%# Eval("Ftitle") %>'></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
    
    <asp:Panel ID="Panelswfupload" runat="server">
        <asp:Image runat="server" ID="upFileType" Visible="False" />
        <asp:HyperLink ID="upFileUrl" runat="server" Visible="False" Target="_blank"></asp:HyperLink>
        <asp:HyperLink ID="Hltonomic" runat="server" NavigateUrl="~/student/autonomic.aspx" Target="_blank" CssClass="df-btn">作品园</asp:HyperLink>
    </asp:Panel>
</div>
</asp:Content>
