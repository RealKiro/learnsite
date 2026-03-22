<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Seat_house, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .hs-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .hs-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .hs-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#0ea5e9,#38bdf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(14,165,233,.25);flex-shrink:0;}
    .hs-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .hs-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .hs-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .hs-grid{display:flex;flex-direction:column;gap:24px;}
    .hs-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .hs-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .hs-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .hs-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .hs-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .ci.purple{background:#eef2ff;} .ci.purple svg{stroke:#6366f1;}
    .hs-card-bd{padding:22px;}
    .t-wrap{overflow-x:auto;}
    .t-wrap table{width:100%;border-collapse:collapse;font-size:13px;}
    .t-wrap th{background:#f8fafc;color:#475569;font-weight:600;padding:10px 14px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;}
    .t-wrap td{padding:10px 14px;color:#334155;border-bottom:1px solid #f1f5f9;}
    .t-wrap tr:hover td{background:#f8fafc;}
    .t-wrap a{color:#0ea5e9;text-decoration:none;font-weight:500;}
    .t-wrap a:hover{text-decoration:underline;}
    .hs-add{display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
    .hs-add label{font-size:13px;font-weight:600;color:#374151;}
    .hs-add input[type="text"]{padding:8px 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;color:#1e293b;background:#f8fafc;transition:border-color .2s,box-shadow .2s;outline:none;}
    .hs-add input[type="text"]:focus{border-color:#38bdf8;box-shadow:0 0 0 3px rgba(14,165,233,.12);background:#fff;}
    .btn-sky{display:inline-flex;align-items:center;justify-content:center;height:38px;padding:0 22px;background:linear-gradient(135deg,#0ea5e9,#0284c7);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(14,165,233,.3);}
    .btn-sky:hover{box-shadow:0 4px 14px rgba(14,165,233,.4);transform:translateY(-1px);}
    .hs-opt{display:flex;align-items:center;gap:8px;padding:14px 22px;background:#f8fafc;border-top:1px solid #f1f5f9;}
    .hs-opt input[type="checkbox"]{width:17px;height:17px;accent-color:#0ea5e9;cursor:pointer;vertical-align:middle;}
    .hs-opt label{cursor:pointer;color:#475569;font-size:13px;user-select:none;vertical-align:middle;margin-left:4px;}
    .hs-del{color:#ef4444!important;font-size:13px;text-decoration:none;cursor:pointer;}
    .hs-del:hover{text-decoration:underline;}
</style>

<div class="hs-page">
    <div class="hs-hd">
        <div class="hs-hd-icon"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
        <div class="hs-hd-text"><h1>机房布置</h1><p>管理机房信息，布置电脑并配置IP对应表</p></div>
    </div>

    <div class="hs-grid">

    <!-- 添加机房 -->
    <div class="hs-card">
        <div class="hs-card-hd">
            <span class="ci purple"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></span>
            添加机房
        </div>
        <div class="hs-card-bd">
            <div class="hs-add">
                <label>机房名称：</label>
                <asp:TextBox ID="TextBoxHname" runat="server" placeholder="请输入机房名称"></asp:TextBox>
                <asp:Button ID="Buttonadd" runat="server" Text="添加" CssClass="btn-sky" onclick="Buttonadd_Click" />
            </div>
        </div>
        <div class="hs-opt">
            <asp:CheckBox ID="CkBox" runat="server" oncheckedchanged="CkBox_CheckedChanged" 
                Text="启用手工机房布置" AutoPostBack="True" />
        </div>
    </div>

    <!-- 机房列表 -->
    <div class="hs-card">
        <div class="hs-card-hd">
            <span class="ci sky"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></span>
            机房列表
        </div>
        <div class="hs-card-bd" style="padding:0;">
            <div class="t-wrap">
                <asp:GridView ID="GVHouse" runat="server" 
                    AutoGenerateColumns="False" CellPadding="0" GridLines="None" Width="100%" 
                    onrowdatabound="GVHouse_RowDataBound" EnableModelValidation="True" 
                    onrowcommand="GVHouse_RowCommand"
                    EnableTheming="False" BorderWidth="0" BorderStyle="None" Font-Size="13px">
                    <Columns>
                        <asp:BoundField HeaderText="序号" />
                        <asp:BoundField DataField="Hname" HeaderText="机房名称" />
                        <asp:HyperLinkField DataNavigateUrlFields="hid" 
                            DataNavigateUrlFormatString="computer.aspx?Hid={0}" HeaderText="电脑" 
                            Text="布置" Target="_blank" />
                        <asp:HyperLinkField DataNavigateUrlFields="hid" 
                            DataNavigateUrlFormatString="ip.aspx?Hid={0}" HeaderText="IP表" 
                            Text="对应" Target="_blank" />
                        <asp:TemplateField ShowHeader="False" HeaderText="操作">
                            <ItemTemplate>
                                <asp:LinkButton ID="LinkButtonDel" runat="server" CausesValidation="false" 
                                    CommandArgument='<%# Bind("hid") %>' CommandName="Del" Text="删除"
                                    CssClass="hs-del"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <HeaderStyle CssClass="" />
                    <RowStyle CssClass="" />
                    <AlternatingRowStyle CssClass="" />
                </asp:GridView>
            </div>
        </div>
    </div>

    </div>
</div>
</asp:Content>

