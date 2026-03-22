<%@ page language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" codefile="learnrate.aspx.cs" inherits="LearnSite.teacher_learnrate" %>
<%@ Register assembly="Anthem" namespace="Anthem" tagprefix="anthem" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .lr { width: 98%; margin: 0 auto; }
    .lr-card {
        background: #fff; border-radius: 14px; border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03), 0 4px 12px rgba(0,0,0,0.02);
        overflow: hidden;
    }
    .lr-head {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        padding: 16px 20px; border-bottom: 1px solid #f1f5f9;
    }
    .lr-head .lr-icon {
        width: 32px; height: 32px; border-radius: 9px;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .lr-head .lr-icon svg { width: 17px; height: 17px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .lr-head .lr-title { font-size: 15px; font-weight: 600; color: #1e293b; }
    .lr-head select {
        height: 34px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 12px; padding: 0 10px; background: #f8fafc;
    }
    .lr-head select:hover { border-color: #a5b4fc; }
    .lr-body { padding: 20px; text-align: center; }
    .lr-body table { border-collapse: collapse; margin: 0 auto; }
    .lr-body th {
        background: linear-gradient(135deg, #6366f1, #7c3aed) !important;
        color: #fff !important; font-weight: 600; font-size: 12px;
        padding: 10px 12px !important; border: none !important;
    }
    .lr-body td {
        padding: 8px 12px !important; font-size: 12px;
        border-bottom: 1px solid #f1f5f9 !important;
        border-left: none !important; border-right: none !important;
    }
    .lr-body tr:hover td { background: #f8fafc; }
</style>

<div class="lr">
    <div class="lr-card">
        <div class="lr-head">
            <div class="lr-icon"><svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg></div>
            <span class="lr-title">学习进度</span>
            <asp:Label ID="LabelGradeClass" runat="server" Font-Size="11pt" />
            <asp:DropDownList ID="DDLCid" runat="server" Font-Names="Arial" AutoPostBack="True"
                onselectedindexchanged="DDLCid_SelectedIndexChanged" />
            <asp:Label ID="Label1" runat="server" style="display:none">学习进度</asp:Label>
        </div>
        <div class="lr-body">
            <anthem:GridView ID="GridViewclass" runat="server" OnRowDataBound="GridViewclass_RowDataBound"
                TabIndex="1" CellPadding="2" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None"
                BorderWidth="2px" Font-Names="Arial" HorizontalAlign="Center"
                EnableModelValidation="True">
                <RowStyle HorizontalAlign="Center" BorderStyle="None" />
                <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                <HeaderStyle BackColor="#305E9C" Font-Bold="True" ForeColor="White" />
            </anthem:GridView>
            <asp:ImageButton ID="Btnreflash" runat="server" ImageUrl="~/images/none.gif" OnClick="Btnreflash_Click" style="display:none" />
        </div>
    </div>
    <asp:Label ID="Labelmsg" runat="server" style="font-size:xx-small" ForeColor="White" />
</div>

<script type="text/javascript">
    function myrefresh() {
        document.getElementById("<%= Btnreflash.ClientID %>").click();
    }
    setTimeout("myrefresh()", 5000);
</script>
</asp:Content>
