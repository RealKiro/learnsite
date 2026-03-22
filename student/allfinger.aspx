<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_allfinger, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .af-page, .af-page * { margin-right: unset !important; margin-left: unset !important; }
    .af-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .af-page { width: 100%; max-width: 900px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: afFadeIn .4s ease; }
    @keyframes afFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .af-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .af-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .af-card-head .af-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .af-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .af-head-icon-indigo { background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important; }
    .af-head-icon-indigo svg { stroke: #4f46e5 !important; }
    .af-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .af-card-body { padding: 16px 22px; }
    .af-filter { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; }
    .af-filter-label { font-size: 13px; color: #64748b; font-weight: 500; }
    .af-page select { padding: 8px 14px !important; border-radius: 8px !important; border: 1.5px solid #e2e8f0 !important; font-size: 13px !important; color: #334155 !important; background: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; outline: none; cursor: pointer; transition: border-color .15s; }
    .af-page select:focus { border-color: #4f46e5 !important; }
    .af-card-body table { width: 100% !important; border-collapse: collapse !important; border-spacing: 0 !important; border: none !important; }
    .af-page .af-card-body table th { padding: 12px 16px !important; font-size: 12px !important; font-weight: 600 !important; color: #64748b !important; text-align: left !important; letter-spacing: .3px; background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important; border-top: none !important; border-left: none !important; border-right: none !important; font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important; }
    .af-page .af-card-body table td { padding: 11px 16px !important; font-size: 13px !important; color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important; border-top: none !important; border-left: none !important; border-right: none !important; background-color: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; vertical-align: middle !important; }
    .af-page .af-card-body table tr { background-color: #fff !important; transition: all .12s; font-size: 13px !important; }
    .af-page .af-card-body table tr:hover td { background-color: #f8faff !important; }
    .af-card-body table tr:last-child td { border-bottom: none !important; }
    .af-card-body .pagediv { padding: 12px 16px 8px !important; font-size: 12px !important; color: #94a3b8 !important; display: flex !important; align-items: center; gap: 6px; flex-wrap: wrap; border-top: 1px solid #f1f5f9 !important; background: #fff !important; }
    .af-card-body .pagediv a { color: #6366f1 !important; text-decoration: none !important; font-size: 12px !important; padding: 4px 10px; border-radius: 6px; transition: all .12s; }
    .af-card-body .pagediv a:hover { background: #eef2ff !important; }
    .af-page .af-card-body table td:last-child { white-space: nowrap !important; min-width: 90px !important; }
    .af-link { display: inline-flex; align-items: center; gap: 6px; margin-top: 4px; padding: 10px 20px; border-radius: 10px; background: linear-gradient(135deg, #6366f1, #4f46e5); color: #fff !important; font-size: 13px !important; font-weight: 600; text-decoration: none !important; transition: all .15s; box-shadow: 0 2px 6px rgba(99,102,241,.2); }
    .af-link:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99,102,241,.3); }
    .af-link svg { width: 16px; height: 16px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .af-card-foot { padding: 14px 22px; border-top: 1px solid #f1f5f9 !important; text-align: center; background: #fff !important; }
</style>

<div class="af-page">
    <div class="af-card">
        <div class="af-card-head">
            <span class="af-head-icon af-head-icon-indigo"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
            <h3>英文输入英雄榜</h3>
        </div>
        <div class="af-card-body">
            <div class="af-filter">
                <span class="af-filter-label">范围</span>
                <asp:DropDownList ID="DDLselect" runat="server" AutoPostBack="True" 
                    onselectedindexchanged="DDLselect_SelectedIndexChanged">
                    <asp:ListItem Value="1">全校排行显示</asp:ListItem>
                    <asp:ListItem Value="2">年级排行显示</asp:ListItem>
                    <asp:ListItem Selected="True" Value="3">班级排行显示</asp:ListItem>
                </asp:DropDownList>
            </div>
            <asp:GridView ID="GVFinger" runat="server" AutoGenerateColumns="False" CellPadding="2" 
                Width="100%" PageSize="40" 
                OnRowDataBound="GVFinger_RowDataBound" AllowPaging="True" 
                onpageindexchanging="GVFinger_PageIndexChanging" SkinID="GridViewInfo" 
                EnableModelValidation="True">
                <Columns>
                    <asp:BoundField HeaderText="名次">
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Psnum" HeaderText="学号">
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Sname" HeaderText="姓名">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Sgrade" HeaderText="年级">
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Sclass" HeaderText="班级">
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Pspd" HeaderText="速度">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle Font-Bold="True" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Pdate" HeaderText="日期">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle Width="120px" HorizontalAlign="Left" />
                    </asp:BoundField>
                </Columns>
                <PagerTemplate>
                    <div class="pagediv">
                        第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>/
                        <asp:Label ID="lblPageCount" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                        <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                        <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上页"></asp:LinkButton>
                        <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下页"></asp:LinkButton>
                        <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                    </div>
                </PagerTemplate>
            </asp:GridView>
        </div>
        <div class="af-card-foot">
            <asp:HyperLink ID="HLtyperank" runat="server" CssClass="af-link" NavigateUrl="~/student/typerank.aspx" Target="_blank"><svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>打字擂台榜</asp:HyperLink>
        </div>
    </div>
</div>
</asp:Content>
