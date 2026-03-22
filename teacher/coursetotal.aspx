<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" enableeventvalidation="false" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_coursetotal, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ct { width: 98%; margin: 0 auto; }
    .ct-card {
        background: #fff; border-radius: 14px; border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03), 0 4px 12px rgba(0,0,0,0.02);
        overflow: hidden; margin-bottom: 16px;
    }
    .ct-head {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        padding: 16px 20px; border-bottom: 1px solid #f1f5f9;
    }
    .ct-head .ct-icon {
        width: 32px; height: 32px; border-radius: 9px;
        background: linear-gradient(135deg, #f0fdf4, #dcfce7);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .ct-head .ct-icon svg { width: 17px; height: 17px; stroke: #16a34a; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ct-head .ct-title { font-size: 15px; font-weight: 600; color: #1e293b; }
    .ct-head select {
        height: 34px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 12px; padding: 0 10px; background: #f8fafc;
    }
    .ct-body { padding: 20px; text-align: center; }

    /* 小组卡片 */
    .ct-body .ct-group-item {
        display: inline-block; border: 1px solid #e2e8f0; border-radius: 10px;
        padding: 10px 12px; width: 130px; margin: 4px; text-align: left;
        font-size: 12px; background: linear-gradient(135deg, #f8fafc, #eef2ff);
        transition: all 0.15s; vertical-align: top;
    }
    .ct-body .ct-group-item:hover { border-color: #818cf8; box-shadow: 0 2px 8px rgba(99,102,241,0.1); }
    .ct-body .ct-group-name { font-weight: 700; color: #4338ca; font-size: 13px; margin-bottom: 4px; }
    .ct-body .ct-group-row { color: #64748b; line-height: 1.8; }

    /* 排序控件 */
    .ct-controls {
        display: flex; align-items: center; flex-wrap: wrap; gap: 8px;
        padding: 12px 20px; border-top: 1px solid #f1f5f9;
        background: linear-gradient(135deg, #fafbfc, #f5f3ff); font-size: 12px;
    }
    .ct-controls label {
        display: inline-flex; align-items: center; gap: 4px; cursor: pointer; white-space: nowrap;
        background: #fff; border: 1px solid #e2e8f0; border-radius: 20px;
        padding: 5px 12px 5px 8px; transition: all 0.15s;
    }
    .ct-controls label:hover { border-color: #a5b4fc; background: #eef2ff; }
    .ct-controls input[type="radio"] { accent-color: #6366f1; width: 14px; height: 14px; margin: 0; }

    /* GridView */
    .ct-body table { border-collapse: collapse; margin: 0 auto; }
    .ct-body th {
        background: linear-gradient(135deg, #6366f1, #7c3aed) !important;
        color: #fff !important; font-weight: 600; font-size: 12px;
        padding: 10px 12px !important; border: none !important;
    }
    .ct-body td {
        padding: 8px 10px !important; font-size: 12px;
        border-bottom: 1px solid #f1f5f9 !important;
        border-left: none !important; border-right: none !important;
    }
    .ct-body tr:hover td { background: #f8fafc; }

    /* 底部工具 */
    .ct-footer {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        padding: 12px 20px; border-top: 1px solid #f1f5f9; font-size: 12px;
    }
</style>

<div class="ct">
    <!-- 小组汇总卡片 -->
    <div class="ct-card">
        <div class="ct-head">
            <div class="ct-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
            <span class="ct-title">学习汇总</span>
            <asp:Label ID="LabelGradeClass" runat="server" Font-Bold="True" Font-Size="12pt" />
            <asp:DropDownList ID="DDLCid" runat="server" Font-Names="Arial" AutoPostBack="True"
                onselectedindexchanged="DDLCid_SelectedIndexChanged" />
            <asp:Label ID="Label1" runat="server" style="display:none">学习汇总</asp:Label>
        </div>
        <div class="ct-body">
            <asp:DataList ID="DataList1" runat="server" RepeatColumns="6"
                RepeatDirection="Horizontal" CellPadding="3"
                onitemdatabound="DataList1_ItemDataBound">
                <ItemTemplate>
                    <div class="ct-group-item">
                        <div class="ct-group-name"><asp:Label ID="LabelName" runat="server" Text='<%# Eval("Sgtitle") %>' /></div>
                        <div class="ct-group-row">总分：<asp:Label ID="LabelGroup" runat="server" Text='<%# Eval("Sgscore") %>' /></div>
                        <div class="ct-group-row">平均：<asp:Label ID="LabelAvg" runat="server" Text='<%# Eval("Svscore") %>' /></div>
                        <div class="ct-group-row">合作：<asp:Label ID="LabelCooperation" runat="server" Text='<%# Eval("Sgwork") %>' /></div>
                        <div class="ct-group-row">表现：<asp:Label ID="Labelattitude" runat="server" Text='<%# Eval("Sgattitude") %>' /></div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
        <div class="ct-controls">
            <asp:RadioButtonList ID="RBsortGroup" runat="server" AutoPostBack="True"
                onselectedindexchanged="RBsortGroup_SelectedIndexChanged"
                RepeatDirection="Horizontal" RepeatLayout="Flow">
                <Items>
                    <asp:ListItem Value="0" Selected="True">默认排序</asp:ListItem>
                    <asp:ListItem Value="1">总分排序</asp:ListItem>
                    <asp:ListItem Value="2">均分排序</asp:ListItem>
                    <asp:ListItem Value="3">合作排序</asp:ListItem>
                    <asp:ListItem Value="4">表现排序</asp:ListItem>
                </Items>
            </asp:RadioButtonList>
        </div>
    </div>

    <!-- 学生明细卡片 -->
    <div class="ct-card">
        <div class="ct-body">
            <asp:GridView ID="GridViewclass" runat="server" OnRowDataBound="GridViewclass_RowDataBound"
                TabIndex="1" CellPadding="3" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None"
                BorderWidth="1px" Font-Names="Arial" HorizontalAlign="Center"
                EnableModelValidation="True">
                <RowStyle ForeColor="#000066" />
                <Columns>
                    <asp:BoundField HeaderText="序号">
                        <ItemStyle Width="40px" />
                    </asp:BoundField>
                </Columns>
                <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                <HeaderStyle BackColor="#305E9C" Font-Bold="True" ForeColor="White" />
            </asp:GridView>
        </div>
        <div class="ct-footer">
            <asp:RadioButtonList ID="RBsort" runat="server" AutoPostBack="True"
                onselectedindexchanged="RBsort_SelectedIndexChanged"
                RepeatDirection="Horizontal" RepeatLayout="Flow">
                <Items>
                    <asp:ListItem Value="学号" Selected="True">学号排序</asp:ListItem>
                    <asp:ListItem Value="汇总">汇总排序</asp:ListItem>
                </Items>
            </asp:RadioButtonList>
            <asp:ImageButton ID="ImageBtnExcel" runat="server" ImageUrl="~/images/down.gif"
                onclick="ImageBtnExcel_Click" ToolTip="将汇总表导出为Excel格式" />
            <asp:ImageButton ID="Btnreflash" runat="server" ImageUrl="~/images/refresh.gif" OnClick="Btnreflash_Click" />
            <asp:Button ID="Btnreturn" runat="server" Text="关闭" SkinID="buttonSkin" Height="20px"
                Width="80px" style="display:none" />
        </div>
    </div>
    <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgBlack" />
</div>
</asp:Content>
