<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_showstudent, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ss-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .ss-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .ss-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#0ea5e9,#38bdf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(14,165,233,.25);flex-shrink:0;}
    .ss-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .ss-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .ss-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .ss-hd-right{margin-left:auto;display:flex;align-items:center;gap:12px;}
    .ss-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;}
    .ss-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .ss-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:#f0f9ff;}
    .ss-card-hd .ci svg{width:19px;height:19px;stroke:#0ea5e9;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ss-card-hd .badge{margin-left:auto;background:#f0f9ff;color:#0369a1;font-size:12px;font-weight:500;padding:4px 12px;border-radius:20px;border:1px solid #bae6fd;}
    .t-wrap{overflow-x:auto;}
    .t-wrap table{width:100%;border-collapse:collapse;font-size:13px;}
    .t-wrap th{background:#f8fafc;color:#475569;font-weight:600;padding:10px 14px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;white-space:nowrap;}
    .t-wrap td{padding:10px 14px;color:#334155;border-bottom:1px solid #f1f5f9;white-space:nowrap;}
    .t-wrap tr:hover td{background:#f8fafc;}
    .t-wrap tr:last-child td{border-bottom:none;}
    .ss-pager{display:flex;align-items:center;justify-content:flex-end;gap:6px;padding:14px 20px;background:#f8fafc;border-top:1px solid #e2e8f0;font-size:13px;color:#64748b;}
    .ss-pager a,.ss-pager span{padding:5px 10px;border-radius:6px;text-decoration:none;color:#475569;cursor:pointer;transition:all .2s;}
    .ss-pager a:hover{background:#e0f2fe;color:#0369a1;}
    .btn-back{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 18px;background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;text-decoration:none;}
    .btn-back:hover{background:#e2e8f0;color:#334155;border-color:#cbd5e1;}
    .btn-back svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
</style>

<div class="ss-page">
    <div class="ss-hd">
        <div class="ss-hd-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
        <div class="ss-hd-text"><h1>&#x5B66;&#x751F;&#x6570;&#x636E;&#x67E5;&#x770B;</h1><p>&#x67E5;&#x770B;&#x5DF2;&#x5BFC;&#x5165;&#x4E34;&#x65F6;&#x8868;&#x4E2D;&#x7684;&#x5B66;&#x751F;&#x4FE1;&#x606F;</p></div>
        <div class="ss-hd-right">
            <asp:Button ID="ButtonReturn" runat="server" OnClick="ButtonInsert_Click" Text="&#x2190; &#x8FD4;&#x56DE;" CssClass="btn-back" />
        </div>
    </div>

    <div class="ss-card">
        <div class="ss-card-hd">
            <span class="ci"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></span>
            &#x5B66;&#x751F;&#x5217;&#x8868;
            <span class="badge">&#x4E34;&#x65F6;&#x8868;&#x4EBA;&#x6570; <asp:Label ID="Labelcount" runat="server"></asp:Label></span>
        </div>
        <div class="t-wrap">
           <asp:GridView ID="GVstudent" runat="server"
            CellPadding="0" GridLines="None" Width="100%" AllowPaging="True" PageSize="25"
            OnPageIndexChanging="GVstudent_PageIndexChanging"
            OnRowDataBound="GVstudent_RowDataBound"
            AutoGenerateColumns="False"
            EnableTheming="False" BorderWidth="0" BorderStyle="None" Font-Size="13px">
               <Columns>
                   <asp:BoundField DataField="Snum" HeaderText="&#x5B66;&#x53F7;" />
                   <asp:BoundField DataField="Syear" HeaderText="&#x5165;&#x5B66;&#x5E74;&#x5EA6;" />
                   <asp:BoundField DataField="Sgrade" HeaderText="&#x5E74;&#x7EA7;" />
                   <asp:BoundField DataField="Sclass" HeaderText="&#x73ED;&#x7EA7;" />
                   <asp:BoundField DataField="Sname" HeaderText="&#x59D3;&#x540D;" />
                   <asp:BoundField DataField="Spwd" HeaderText="&#x5BC6;&#x7801;" />
                   <asp:BoundField DataField="Sex" HeaderText="&#x6027;&#x522B;" />
                   <asp:BoundField DataField="Saddress" HeaderText="&#x5BB6;&#x5EAD;&#x4F4F;&#x5740;" />
                   <asp:BoundField DataField="Sphone" HeaderText="&#x8054;&#x7CFB;&#x7535;&#x8BDD;" />
                   <asp:BoundField DataField="Sparents" HeaderText="&#x5BB6;&#x957F;&#x59D3;&#x540D;" />
                   <asp:BoundField DataField="Sheadtheacher" HeaderText="&#x73ED;&#x4E3B;&#x4EFB;" />
               </Columns>
            <pagertemplate>
                <div class="ss-pager">
                    &#x7B2C;<asp:Label id="lblPageIndex" runat="server" text='<%# ((GridView)Container.Parent.Parent).PageIndex + 1  %>' />&#x9875;
                    &#x5171;<asp:Label id="lblPageCount" runat="server" text='<%# ((GridView)Container.Parent.Parent).PageCount  %>' />&#x9875;
                    <asp:linkbutton id="btnFirst" runat="server" causesvalidation="False" commandargument="First" commandname="Page" text="&#x9996;&#x9875;" />
                    <asp:linkbutton id="btnPrev" runat="server" causesvalidation="False" commandargument="Prev" commandname="Page" text="&#x4E0A;&#x4E00;&#x9875;" />
                    <asp:linkbutton id="btnNext" runat="server" causesvalidation="False" commandargument="Next" commandname="Page" text="&#x4E0B;&#x4E00;&#x9875;" />
                    <asp:linkbutton id="btnLast" runat="server" causesvalidation="False" commandargument="Last" commandname="Page" text="&#x5C3E;&#x9875;" />
                </div>
            </pagertemplate>
            <HeaderStyle CssClass="" />
            <RowStyle CssClass="" />
            <AlternatingRowStyle CssClass="" />
            <SelectedRowStyle CssClass="" />
            <PagerStyle CssClass="" />
        </asp:GridView>
        </div>
    </div>
</div>
</asp:Content>
