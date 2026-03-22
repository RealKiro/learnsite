<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mysign, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
    /* ===== mysign 签到记录 ===== */
    .sn-page { max-width: 1440px; animation: sn-fadeIn .4s ease; }
    @keyframes sn-fadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

    .sn-card { background: #fff; border-radius: 20px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 8px 24px rgba(0,0,0,.04); overflow: hidden; margin-bottom: 24px; }

    /* 渐变头部 */
    .sn-head { padding: 20px 24px; display: flex !important; align-items: center; gap: 14px; position: relative; overflow: hidden; }
    .sn-head::after { content: ''; position: absolute; top: -20px; right: -20px; width: 80px; height: 80px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .sn-head-green { background: linear-gradient(135deg, #10b981, #059669, #047857); }
    .sn-head-rose { background: linear-gradient(135deg, #f43f5e, #e11d48, #be123c); }
    .sn-head-icon { width: 42px; height: 42px; background: rgba(255,255,255,.2); border-radius: 12px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; backdrop-filter: blur(4px); }
    .sn-head-icon svg { width: 20px; height: 20px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sn-head-text { flex: 1; position: relative; z-index: 1; }
    .sn-head h3 { margin: 0; font-size: 16px; font-weight: 700; color: #fff; letter-spacing: .5px; }
    .sn-head p { margin: 3px 0 0; font-size: 12px; color: rgba(255,255,255,.75); }
    .sn-head-badge { padding: 5px 14px; border-radius: 20px; background: rgba(255,255,255,.2); backdrop-filter: blur(4px); font-size: 12px; color: #fff; font-weight: 600; white-space: nowrap; }
    .sn-head-badge span { font-size: 12px !important; color: #fff !important; }

    /* 表格区域 */
    .sn-tbody { padding: 0; overflow-x: auto; }
    .sn-tbody table { width: 100% !important; border-collapse: collapse !important; border: none !important; min-width: 700px; }
    .sn-tbody table th {
        padding: 13px 16px !important; font-size: 11px !important; font-weight: 700 !important;
        color: #6b7280 !important; text-align: left !important; background: #f9fafb !important;
        border-bottom: 2px solid #e5e7eb !important; border-top: none !important;
        border-left: none !important; border-right: none !important;
        font-family: 'Microsoft YaHei',sans-serif !important;
        text-transform: uppercase; letter-spacing: .5px;
    }
    .sn-tbody table td {
        padding: 12px 16px !important; font-size: 13px !important; color: #374151 !important;
        border-bottom: 1px solid #f3f4f6 !important; border-top: none !important;
        border-left: none !important; border-right: none !important;
        background: transparent !important; font-family: 'Microsoft YaHei',sans-serif !important;
        vertical-align: middle !important;
    }
    .sn-tbody table tr { background: #fff !important; transition: background .15s ease; height: auto !important; }
    .sn-tbody table tr:hover { background: #f0fdf4 !important; }
    .sn-card-rose .sn-tbody table tr:hover { background: #fff1f2 !important; }
    .sn-tbody table tr:last-child td { border-bottom: none !important; }
    .sn-tbody table caption { font-size: 0; height: 0; overflow: hidden; }

    /* 第一列序号 */
    .sn-tbody table td:first-child, .sn-tbody table th:first-child { text-align: center !important; width: 48px; color: #9ca3af !important; font-size: 12px !important; }
    /* 姓名列加粗 */
    .sn-tbody table td:nth-child(5) { font-weight: 600 !important; color: #1e293b !important; }

    /* 分页 */
    .sn-tbody .pagediv {
        padding: 14px 20px !important; font-size: 13px !important; color: #6b7280 !important;
        display: flex !important; align-items: center; gap: 4px; flex-wrap: wrap;
        border-top: 1px solid #f3f4f6 !important; background: #f9fafb !important;
    }
    .sn-tbody .pagediv span { color: #374151 !important; font-weight: 600 !important; font-size: 13px !important; }
    .sn-tbody .pagediv a {
        color: #059669 !important; text-decoration: none !important; font-size: 13px !important;
        padding: 5px 12px; border-radius: 8px; transition: all .15s; font-weight: 500;
    }
    .sn-tbody .pagediv a:hover { background: #ecfdf5 !important; color: #047857 !important; }

    /* 空状态 */
    .sn-empty { padding: 40px 20px; text-align: center; color: #9ca3af; font-size: 14px; }
    .sn-empty svg { width: 48px; height: 48px; fill: none; stroke: #d1d5db; stroke-width: 1.5; margin-bottom: 12px; }
</style>

<div class="sn-page">

<div class="sn-card">
    <div class="sn-head sn-head-green">
        <span class="sn-head-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
        <div class="sn-head-text">
            <h3>签到列表</h3>
            <p>记录每次课堂签到信息</p>
        </div>
        <span class="sn-head-badge"><asp:Label ID="Labelsignin" runat="server" Font-Size="9pt"></asp:Label></span>
    </div>
    <div class="sn-tbody">
        <asp:GridView ID="GVSignin" runat="server" AutoGenerateColumns="False" CellPadding="6" PageSize="15"
            Width="100%" ToolTip="签到记录" SkinID="GridViewInfo" onrowdatabound="GVSignin_RowDataBound"
            AllowPaging="True" onpageindexchanging="GVSignin_PageIndexChanging" EnableModelValidation="True">
            <Columns>
                <asp:BoundField />
                <asp:BoundField DataField="Qnum" HeaderText="学号" />
                <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                <asp:BoundField DataField="Sclass" HeaderText="班级" />
                <asp:BoundField DataField="Sname" HeaderText="姓名"><ItemStyle HorizontalAlign="Left" /></asp:BoundField>
                <asp:BoundField DataField="Qwork" HeaderText="作品" />
                <asp:BoundField DataField="Qattitude" HeaderText="表现" />
                <asp:BoundField DataField="Qnote" HeaderText="备注" />
                <asp:BoundField DataField="Qip" HeaderText="IP地址" />
                <asp:BoundField DataField="Qdate" HeaderText="日期"><ItemStyle Width="180px" HorizontalAlign="Left" /></asp:BoundField>
            </Columns>
            <PagerTemplate>
                <div class="pagediv">
                    第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>
                    页 共<asp:Label ID="lblPageCount" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                    <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                    <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上一页"></asp:LinkButton>
                    <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下一页"></asp:LinkButton>
                    <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                </div>
            </PagerTemplate>
        </asp:GridView>
    </div>
</div>

<div class="sn-card sn-card-rose">
    <div class="sn-head sn-head-rose">
        <span class="sn-head-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></span>
        <div class="sn-head-text">
            <h3>缺席列表</h3>
            <p>未签到同学记录</p>
        </div>
        <span class="sn-head-badge"><asp:Label ID="Labelnosign" runat="server" Font-Size="9pt"></asp:Label></span>
    </div>
    <div class="sn-tbody">
        <asp:GridView ID="GVNoSign" runat="server" AutoGenerateColumns="False" CellPadding="2" Width="100%"
            ToolTip="缺席记录" SkinID="GridViewInfo" onrowdatabound="GVNoSign_RowDataBound" DataKeyNames="Snum" EnableModelValidation="True">
            <Columns>
                <asp:BoundField />
                <asp:BoundField DataField="Snum" HeaderText="学号" />
                <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                <asp:BoundField DataField="Sclass" HeaderText="班级" />
                <asp:BoundField DataField="Sname" HeaderText="姓名"><ItemStyle HorizontalAlign="Left" /></asp:BoundField>
                <asp:BoundField DataField="Sex" HeaderText="性别" />
                <asp:BoundField DataField="Sheadtheacher" HeaderText="班主任" />
                <asp:BoundField HeaderText="缺席原因" DataField="Nnote" />
                <asp:BoundField DataField="Ndate" HeaderText="日期"><ItemStyle HorizontalAlign="Left" Width="120px" /></asp:BoundField>
            </Columns>
        </asp:GridView>
    </div>
</div>

</div>
</asp:Content>

