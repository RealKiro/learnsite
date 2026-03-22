<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Seat_ip, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* IP page */
    .ip-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .ip-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .ip-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#0ea5e9,#38bdf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(14,165,233,.25);flex-shrink:0;}
    .ip-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .ip-hd h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .ip-hd p{font-size:13px;color:#94a3b8;margin:0;}
    .ip-grid{display:flex;flex-direction:column;gap:24px;}
    .ip-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .ip-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .ip-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .ip-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .ip-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.sky{background:#f0f9ff;}.ci.sky svg{stroke:#0ea5e9;}
    .ci.purple{background:#eef2ff;}.ci.purple svg{stroke:#6366f1;}
    .ci.amber{background:#fffbeb;}.ci.amber svg{stroke:#f59e0b;}
    .ip-card-bd{padding:22px;}
    .ip-row{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
    .ip-label{font-size:13px;color:#64748b;font-weight:500;}
    .ip-card input[type="text"]{padding:7px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;font-family:inherit;color:#1e293b;background:#f8fafc;transition:border-color .2s,box-shadow .2s;outline:none;}
    .ip-card input[type="text"]:focus{border-color:#38bdf8;box-shadow:0 0 0 3px rgba(14,165,233,.12);background:#fff;}
    .btn-sky{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#0ea5e9,#0284c7);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(14,165,233,.3);}
    .btn-sky:hover{box-shadow:0 4px 14px rgba(14,165,233,.4);transform:translateY(-1px);}
    .btn-purple{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(99,102,241,.3);}
    .btn-purple:hover{box-shadow:0 4px 14px rgba(99,102,241,.4);transform:translateY(-1px);}
    .t-wrap{overflow-x:auto;}.t-wrap table{width:100%;border-collapse:collapse;font-size:13px;}
    .t-wrap th{background:#f8fafc;color:#475569;font-weight:600;padding:10px 14px;text-align:left;font-size:12.5px;border-bottom:1px solid #e2e8f0;}
    .t-wrap td{padding:9px 14px;color:#334155;border-bottom:1px solid #f1f5f9;}
    .t-wrap tr:hover td{background:#f8fafc;}
    .t-wrap a{color:#0ea5e9;text-decoration:none;font-weight:500;font-size:13px;}.t-wrap a:hover{text-decoration:underline;}
    .ip-hint{margin-top:14px;padding:12px 16px;background:#f0f9ff;border:1px solid #bae6fd;border-radius:10px;font-size:12.5px;color:#0369a1;line-height:1.7;}.ip-hint a{color:#6366f1;font-weight:500;}
    .ip-sample{margin-top:8px;}.ip-sample-title{font-size:13px;font-weight:600;color:#475569;margin-bottom:8px;}
    .ip-sample table{border-collapse:collapse;font-size:13px;}.ip-sample th{background:#f8fafc;color:#475569;font-weight:600;padding:8px 18px;text-align:left;border:1px solid #e2e8f0;}
    .ip-sample td{padding:8px 18px;color:#334155;border:1px solid #f1f5f9;}
    .ip-msg{margin-top:14px;font-size:13px;color:#1e40af;}
    .ip-card input[type="file"]{font-size:12px;color:#475569;}.ip-card input[type="file"]::file-selector-button{height:32px;padding:0 14px;background:#f1f5f9;color:#334155;border:1.5px solid #e2e8f0;border-radius:8px;font-size:12px;cursor:pointer;transition:all .2s;margin-right:8px;}.ip-card input[type="file"]::file-selector-button:hover{background:#e2e8f0;}
    .ip-card-list{border-color:#dbeafe;box-shadow:0 12px 28px rgba(59,130,246,.08),0 1px 3px rgba(15,23,42,.04);}
    .ip-card-list .ip-card-hd{justify-content:space-between;padding:18px 22px;background:linear-gradient(135deg,#f8fbff,#eef4ff);}
    .ip-list-head{display:flex;align-items:center;gap:12px;min-width:0;}
    .ip-list-copy{display:flex;flex-direction:column;gap:4px;}
    .ip-list-copy small{font-size:12px;color:#64748b;font-weight:500;}
    .ip-list-badge{display:inline-flex;align-items:center;justify-content:center;padding:0 12px;height:32px;border-radius:999px;background:linear-gradient(135deg,#dbeafe,#e0e7ff);border:1px solid #bfdbfe;color:#4338ca;font-size:12px;font-weight:700;white-space:nowrap;}
    .ip-list-body{padding:18px 18px 20px;background:linear-gradient(180deg,#ffffff 0%,#f8fbff 100%);}
    .ip-list-toolbar{display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap;margin-bottom:16px;padding:14px 16px;border:1px solid #e0ecff;border-radius:14px;background:linear-gradient(135deg,#f8fbff,#ffffff);}
    .ip-list-title{font-size:14px;font-weight:700;color:#1e293b;}
    .ip-list-desc{font-size:12px;color:#64748b;line-height:1.6;}
    .ip-list-chip{display:inline-flex;align-items:center;gap:8px;height:34px;padding:0 14px;border-radius:999px;background:#fff;border:1px solid #dbeafe;color:#2563eb;font-size:12px;font-weight:700;box-shadow:0 4px 12px rgba(59,130,246,.08);}
    .ip-list-chip::before{content:'';width:8px;height:8px;border-radius:50%;background:#38bdf8;box-shadow:0 0 0 4px rgba(56,189,248,.14);}
    .ip-table-shell{border:1px solid #dbeafe;border-radius:18px;background:#fff;box-shadow:0 10px 24px rgba(148,163,184,.12);overflow:hidden;}
    .ip-gridview{width:100%!important;border-collapse:separate!important;border-spacing:0!important;background:#fff;}
    .ip-gridview th{padding:14px 18px!important;background:linear-gradient(135deg,#eff6ff,#f8fafc)!important;color:#475569!important;font-size:12px!important;font-weight:800!important;letter-spacing:.4px;text-align:left!important;border-bottom:1px solid #dbeafe!important;text-transform:uppercase;}
    .ip-gridview td{padding:14px 18px!important;border-bottom:1px solid #eef2ff!important;color:#1e293b!important;font-size:14px!important;vertical-align:middle!important;background:#fff;}
    .ip-gridview tr:last-child td{border-bottom:none!important;}
    .ip-gridview tr:hover td{background:linear-gradient(135deg,#f8fbff,#fdfefe)!important;}
    .ip-gridview td:nth-child(1){width:108px!important;font-family:'Consolas','Monaco',monospace;font-weight:800;color:#4338ca;font-size:15px!important;}
    .ip-gridview td:nth-child(2){font-family:'Consolas','Monaco',monospace;font-size:15px!important;color:#0f172a;}
    .ip-gridview td:nth-child(2) span{display:inline-flex;align-items:center;min-height:36px;padding:0 14px;border-radius:999px;background:linear-gradient(135deg,#eff6ff,#f8fafc);border:1px solid #dbeafe;box-shadow:inset 0 1px 0 rgba(255,255,255,.8);}
    .ip-gridview td:last-child{width:140px!important;white-space:nowrap;}
    .ip-gridview td:last-child a{display:inline-flex;align-items:center;justify-content:center;height:34px;min-width:64px;padding:0 14px;margin-right:8px;border-radius:10px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;text-decoration:none!important;font-size:12px!important;font-weight:700;box-shadow:0 6px 14px rgba(99,102,241,.22);transition:all .2s;}
    .ip-gridview td:last-child a:last-child{margin-right:0;}
    .ip-gridview td:last-child a:hover{transform:translateY(-1px);box-shadow:0 10px 18px rgba(99,102,241,.28);}
    .ip-gridview input[type="text"]{width:240px;max-width:100%;height:38px;background:#fff;}
    @media (max-width: 900px){
        .ip-page{padding:22px 16px 32px;}
        .ip-list-toolbar{align-items:flex-start;}
        .ip-gridview td,.ip-gridview th{padding:12px 12px!important;}
        .ip-gridview input[type="text"]{width:180px;}
    }
</style>

<div class="ip-page">
    <div class="ip-hd">
        <div class="ip-hd-icon"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2z"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg></div>
        <div><h1>电脑编号与IP对应表</h1><p>配置机房电脑编号与IP地址的对应关系</p></div>
    </div>
    <div class="ip-grid">
    <div class="ip-card">
        <div class="ip-card-hd"><span class="ci sky"><svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></span>自动创建IP列表</div>
        <div class="ip-card-bd">
            <div class="ip-row">
                <span class="ip-label">网段：</span>
                <asp:TextBox ID="TextBoxIpGate" runat="server" BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" Font-Size="9pt" Width="100px">192.168.0</asp:TextBox>
                <span class="ip-label">IP范围从</span>
                <asp:TextBox ID="TextBoxIpBegin" runat="server" BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" Font-Size="9pt" Width="45px">11</asp:TextBox>
                <span class="ip-label">到</span>
                <asp:TextBox ID="TextBoxIpEnd" runat="server" BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" Font-Size="9pt" Width="45px">50</asp:TextBox>
                <asp:Button ID="ButtonIpAdd" runat="server" Font-Size="9pt" Text="根据范围创建IP列表" CssClass="btn-sky" ToolTip="点击后将清除原机房IP列表，并自动创建新IP列表" onclick="ButtonIp_Click" />
            </div>
        </div>
    </div>
    <div class="ip-card ip-card-list">
        <div class="ip-card-hd">
            <div class="ip-list-head">
                <span class="ci purple"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
                <div class="ip-list-copy">
                    <span>本机房IP列表</span>
                    <small>支持逐条编辑电脑编号与 IP 地址对应关系</small>
                </div>
            </div>
            <span class="ip-list-badge">可直接在线维护</span>
        </div>
        <div class="ip-card-bd ip-list-body">
            <div class="ip-list-toolbar">
                <div>
                    <div class="ip-list-title">当前机房地址清单</div>
                    <div class="ip-list-desc">点击右侧“编辑”即可修改单台电脑 IP，保存后会立即更新当前机房配置。</div>
                </div>
                <span class="ip-list-chip">按编号顺序显示</span>
            </div>
            <div class="t-wrap ip-table-shell">
        <asp:GridView ID="GVip" runat="server" 
            AutoGenerateColumns="False" BorderColor="#E7E7E7" BorderStyle="Solid" 
            BorderWidth="1px" CellPadding="2" Font-Size="9pt" GridLines="None" 
            Width="100%" PageSize="15" DataKeyNames="Iid" EnableModelValidation="True" 
            onrowdatabound="GVip_RowDataBound" 
            onrowcancelingedit="GVip_RowCancelingEdit" onrowediting="GVip_RowEditing" 
            onrowupdating="GVip_RowUpdating" HorizontalAlign="Center" 
            EnableTheming="False" CssClass="ip-gridview" EmptyDataText="当前机房还没有配置 IP 列表">
                <Columns>
                    <asp:BoundField HeaderText="电脑编号" DataField="Inum" ReadOnly="True" >
                    <HeaderStyle Width="60px" />
                    <ItemStyle Width="60px" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="本机房IP列表">
                        <EditItemTemplate>
                            <asp:TextBox ID="TextBoxIp" runat="server" Text='<%# Bind("Iip") %>'></asp:TextBox>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="LabelIp" runat="server" Text='<%# Bind("Iip") %>'></asp:Label>
                        </ItemTemplate>
                        <HeaderStyle Width="160px" />
                        <ItemStyle Width="160px" />
                    </asp:TemplateField>
                     <asp:CommandField ShowEditButton="True" HeaderText="操作" />
                </Columns>
                <RowStyle BorderStyle="None" Font-Names="Arial" Font-Size="9pt" 
                    ForeColor="Black" Height="20px" />
                <HeaderStyle BackColor="#EEEEEE" Font-Bold="False" Font-Names="Arial" 
                    Font-Size="9pt" />
                <AlternatingRowStyle BackColor="#E7E7E7" />
            </asp:GridView>
            </div>
        </div>
    </div>
    <div class="ip-card">
        <div class="ip-card-hd"><span class="ci amber"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></span>从Excel导入</div>
        <div class="ip-card-bd">
            <div class="ip-row">
                <asp:FileUpload ID="FileUploadip" runat="server" Font-Size="9pt" />
                <asp:Button ID="ButtonIpExcel" runat="server" Font-Size="9pt" Text="从Excel导入IP列表" CssClass="btn-purple" ToolTip="点击后将清除原机房IP列表，并自动创建新IP列表" onclick="ButtonIpExcel_Click" />
            </div>
            <div class="ip-msg"><asp:Label ID="Labelmsg" runat="server" ForeColor="#000099"></asp:Label></div>
            <div class="ip-sample">
                <div class="ip-sample-title">Excel导入模板参考：</div>
                <table><tr><th>电脑编号</th><th>IP列表</th></tr><tr><td>1</td><td>192.168.0.11</td></tr><tr><td>2</td><td>192.168.0.12</td></tr></table>
            </div>
            <div class="ip-hint">
                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/Seat/getip.aspx" Target="_blank">右键复制快捷方式将此链接用极域远程命令在学生机打开，显示IP后记录参考</asp:HyperLink>
            </div>
        </div>
    </div>
    </div>
</div>
</asp:Content>
