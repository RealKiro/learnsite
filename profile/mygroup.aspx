<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mygroup, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
        /* 页面容器 - 与 mysign 保持一致 */
    .mg-page { max-width: 1440px; animation: mgFade .4s ease; }

    /* 响应式适配 */
    @media (max-width: 768px) {
        .mg-page { padding: 0 4px; }
        .mg-card-head { padding: 14px 16px; gap: 10px; }
        .mg-card-head h3 { font-size: 15px; }
        .mg-card-body { overflow-x: auto; -webkit-overflow-scrolling: touch; }
        .mg-card-body table th { padding: 10px 12px !important; font-size: 11px !important; }
        .mg-card-body table td { padding: 10px 12px !important; font-size: 12.5px !important; }
        .mg-bottom { padding: 12px 16px; }
        .mg-rename { flex-wrap: wrap; gap: 8px; }
        .mg-rename input[type="text"] { width: 100% !important; }
    }
    @media (max-width: 480px) {
        .mg-page { padding: 0 2px; }
        .mg-card { border-radius: 12px; }
        .mg-card-head { padding: 12px 14px; }
        .mg-card-head .mg-icon { width: 32px; height: 32px; border-radius: 8px; }
        .mg-icon svg { width: 15px; height: 15px; }
        .mg-card-body table th { padding: 8px 10px !important; }
        .mg-card-body table td { padding: 8px 10px !important; font-size: 12px !important; }
        .mg-rename { font-size: 12.5px; }
        .mg-free { padding: 10px 14px; font-size: 12px; }
    }

    .mg-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; animation: mgFade .4s ease; }
    @keyframes mgFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .mg-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex !important; align-items: center; gap: 12px; }
    .mg-card-head .mg-icon { width: 38px; height: 38px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; background: linear-gradient(135deg, #e0e7ff, #c7d2fe); }
    .mg-icon svg { width: 18px; height: 18px; fill: none; stroke: #6366f1; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mg-card-head h3 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; flex: 1; }
    .mg-card-body { padding: 0; }

    /* Table */
    .mg-card-body table { width: 100% !important; border-collapse: collapse !important; border: none !important; border-spacing: 0 !important; }
    .mg-card-body table caption { font-size: 0; height: 0; overflow: hidden; display: none; }
    .mg-card-body table th {
        padding: 12px 20px !important; font-size: 11.5px !important; font-weight: 600 !important;
        color: #94a3b8 !important; text-align: left !important; text-transform: uppercase !important;
        letter-spacing: .5px !important; background: #f8fafc !important;
        border-bottom: 1px solid #e8ecf1 !important; border-top: none !important;
        border-left: none !important; border-right: none !important;
        font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important;
    }
    .mg-card-body table td {
        padding: 14px 20px !important; font-size: 13.5px !important; color: #334155 !important;
        border-bottom: 1px solid #f1f5f9 !important; border-top: none !important;
        border-left: none !important; border-right: none !important;
        background: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important;
        vertical-align: middle !important; white-space: nowrap !important;
    }
    .mg-card-body table tr { background: #fff !important; transition: all .12s; height: auto !important; }
    .mg-card-body table tr:hover td { background: #fafbff !important; }
    .mg-card-body table tr:last-child td { border-bottom: none !important; }

    /* 组长列 (td:nth-child(2)，序号列Visible=false不渲染) */
    .mg-card-body table td:nth-child(2) {
        white-space: nowrap !important;
    }
    .mg-card-body table td:nth-child(2) img { display: none !important; }
    .mg-card-body table td:nth-child(2) span {
        display: inline-flex !important; align-items: center; gap: 6px;
        padding: 4px 12px 4px 8px; border-radius: 20px;
        background: linear-gradient(135deg, #fefce8, #fef9c3); border: 1px solid #fde047;
        font-weight: 600 !important; color: #a16207 !important; font-size: 13px !important;
    }
    .mg-card-body table td:nth-child(2) span::before {
        content: '';
        display: inline-block; width: 18px; height: 18px; flex-shrink: 0;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23ca8a04' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M2 4l3 12h14l3-12-5 4-5-4-5 4z'/%3E%3Cpath d='M5 16h14v4H5z'/%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat;
    }

    /* 成员列 (td:nth-child(3)) */
    .mg-card-body table td:nth-child(3) { white-space: normal !important; color: #334155 !important; font-size: 13px !important; line-height: 1.6 !important; }
    .mg-member-tag {
        display: inline-flex !important; align-items: center; padding: 3px 10px;
        border-radius: 6px; font-size: 12.5px; margin: 2px 3px; white-space: nowrap;
        background: #f8fafc; border: 1px solid #e2e8f0; color: #475569; font-weight: 500;
    }
    .mg-member-tag.mg-leader {
        background: linear-gradient(135deg, #fefce8, #fef9c3); border-color: #fde047;
        color: #a16207; font-weight: 700;
    }
    .mg-member-tag.mg-leader::before {
        content: ''; display: inline-block; width: 14px; height: 14px; margin-right: 4px; flex-shrink: 0;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23ca8a04' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M2 4l3 12h14l3-12-5 4-5-4-5 4z'/%3E%3Cpath d='M5 16h14v4H5z'/%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat;
    }

    /* 操作列 */
    .mg-card-body table td:last-child { white-space: nowrap !important; }
    .mg-card-body table a {
        display: inline-flex !important; align-items: center; padding: 5px 14px;
        border-radius: 6px; font-size: 12.5px !important; font-weight: 500;
        text-decoration: none !important; transition: all .12s; line-height: 1.3;
    }
    .mg-card-body table a[id*="LinkButton1"] {
        background: #eef2ff; color: #4f46e5 !important; border: 1px solid #e0e7ff;
    }
    .mg-card-body table a[id*="LinkButton1"]:hover { background: #e0e7ff; }
    .mg-card-body table a[id*="LinkButton2"] {
        background: #fff1f2; color: #e11d48 !important; border: 1px solid #fecdd3; margin-left: 6px !important;
    }
    .mg-card-body table a[id*="LinkButton2"]:hover { background: #ffe4e6; }

    /* 底部修改 */
    .mg-bottom { padding: 16px 24px; border-top: 1px solid #f1f5f9; }
    .mg-rename { display: flex; align-items: center; gap: 12px; font-size: 13.5px; color: #334155; }
    .mg-rename input[type="text"] { padding: 9px 16px !important; border: 1px solid #e2e8f0 !important; border-radius: 8px !important; font-size: 13px !important; font-family: 'Microsoft YaHei',sans-serif !important; width: 200px !important; transition: all .15s; background: #fff !important; }
    .mg-rename input[type="text"]:focus { border-color: #818cf8 !important; outline: none !important; box-shadow: 0 0 0 3px rgba(99,102,241,.1) !important; }
    .mg-rename input[type="submit"] {
        padding: 9px 24px !important; border-radius: 8px !important; border: none !important;
        background: linear-gradient(135deg, #6366f1, #4f46e5) !important; color: #fff !important;
        font-size: 13px !important; font-weight: 600 !important; cursor: pointer; transition: all .15s;
        box-shadow: 0 2px 6px rgba(79,70,229,.2);
        width: auto !important; height: auto !important; line-height: 1.4 !important;
        background-image: none;
    }
    .mg-rename input[type="submit"]:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(79,70,229,.3); }
    .mg-free { padding: 14px 18px; background: #fffbeb; border-radius: 10px; border: 1px solid #fef3c7; font-size: 13px; color: #92400e; margin-top: 14px; }
    .mg-free-title { font-weight: 600; color: #b45309; margin-bottom: 6px; display: flex; align-items: center; gap: 6px; }
    .mg-free-title::before {
        content: ''; display: inline-block; width: 16px; height: 16px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23b45309' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cline x1='12' y1='8' x2='12' y2='12'/%3E%3Cline x1='12' y1='16' x2='12.01' y2='16'/%3E%3C/svg%3E");
        background-size: contain; flex-shrink: 0;
    }
</style>

<div class="mg-page">
<div class="mg-card">
    <div class="mg-card-head">
        <span class="mg-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
        <h3>小组管理</h3>
    </div>
    <div class="mg-card-body">
        <asp:Panel ID="Panelapply" runat="server">
            <asp:GridView ID="GVgroup" runat="server" 
                AutoGenerateColumns="False" Caption="小组管理" 
                onrowdatabound="GVgroup_RowDataBound" SkinID="GridViewInfo" 
                Width="100%" EnableModelValidation="True" CellPadding="5" 
                DataKeyNames="Sid" onrowcommand="GVgroup_RowCommand">
                <Columns>
                    <asp:BoundField HeaderText="序号" Visible="false"><ItemStyle Width="40px" /></asp:BoundField>
                    <asp:BoundField DataField="Sgtitle" HeaderText="小组名称"><ItemStyle Width="120px" HorizontalAlign="Left" /></asp:BoundField>
                    <asp:TemplateField HeaderText="组长">
                        <ItemTemplate>
                            <asp:Image ID="Imageflag" runat="server" ImageUrl="~/images/gflag.gif" />
                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("Sname") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle Width="80px" HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="成员">
                        <ItemTemplate><asp:Label ID="Labelmember" runat="server"></asp:Label></ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="操作" ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="false" CommandArgument='<%# Eval("Sid") %>' CommandName="AddGroup" Text="参加"></asp:LinkButton>
                            <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="false" CommandArgument='<%# Eval("Sid") %>' CommandName="outGroup" Text="退出"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="90px" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </asp:Panel>
        <div class="mg-bottom">
        <asp:Panel ID="PanelSgtitle" runat="server">
            <div class="mg-rename">
                <span>我的小组名称：</span>
                <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
                <asp:Button ID="BtnSgtitle" runat="server" onclick="BtnSgtitle_Click" SkinID="buttonSkin" Text="修改" />
            </div>
        </asp:Panel>
        <div class="mg-free">
            <div class="mg-free-title">当前未加入的同学</div>
            <asp:Label ID="Labelfree" runat="server"></asp:Label>
        </div>
        </div>
    </div>
</div>

</div>

<script type="text/javascript">
(function(){
    var rows = document.querySelectorAll('.mg-card-body table tbody tr');
    rows.forEach(function(row){
        var cells = row.querySelectorAll('td');
        if (cells.length < 3) return;
        // 组长列(第2列，序号列不渲染)
        var leaderCell = cells[1];
        var leaderSpan = leaderCell.querySelector('span');
        var leaderName = leaderSpan ? leaderSpan.innerText.trim() : '';
        // 成员列(第3列)
        var memberCell = cells[2];
        var memberSpan = memberCell.querySelector('span');
        if (!memberSpan) return;
        var raw = memberSpan.innerText.trim();
        // 用多种分隔符拆分
        var names = raw.split(/[\u3001\uff0c,\s\/\|]+/).filter(function(n){ return n.trim().length > 0; });
        var html = '';
        names.forEach(function(n){
            n = n.trim();
            if (!n) return;
            if (n === leaderName) {
                html += '<span class="mg-member-tag mg-leader">' + n + '</span>';
            } else {
                html += '<span class="mg-member-tag">' + n + '</span>';
            }
        });
        memberSpan.innerHTML = html;
    });
})();
</script>
</asp:Content>

