<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_allchinese, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .ar-page, .ar-page * { margin-right: unset !important; margin-left: unset !important; }
    .ar-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .ar-page { width: 100%; max-width: 900px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: arFadeIn .4s ease; }
    @keyframes arFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .ar-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .ar-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .ar-card-head .ar-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .ar-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ar-head-icon-purple { background: linear-gradient(135deg, #f3e8ff, #e9d5ff) !important; }
    .ar-head-icon-purple svg { stroke: #9333ea !important; }
    .ar-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .ar-card-body { padding: 16px 22px; }
    /* 筛选器 */
    .ar-filter { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; }
    .ar-filter-label { font-size: 13px; color: #64748b; font-weight: 500; }
    .ar-page select { padding: 8px 14px !important; border-radius: 8px !important; border: 1.5px solid #e2e8f0 !important; font-size: 13px !important; color: #334155 !important; background: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; outline: none; cursor: pointer; transition: border-color .15s; }
    .ar-page select:focus { border-color: #9333ea !important; }
    /* 表格 */
    .ar-card-body table { width: 100% !important; border-collapse: collapse !important; border-spacing: 0 !important; border: none !important; }
    .ar-page .ar-card-body table th { padding: 12px 16px !important; font-size: 12px !important; font-weight: 600 !important; color: #64748b !important; text-align: left !important; letter-spacing: .3px; background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important; border-top: none !important; border-left: none !important; border-right: none !important; font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important; }
    .ar-page .ar-card-body table td { padding: 11px 16px !important; font-size: 13px !important; color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important; border-top: none !important; border-left: none !important; border-right: none !important; background-color: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; vertical-align: middle !important; }
    .ar-page .ar-card-body table tr { background-color: #fff !important; transition: all .12s; font-size: 13px !important; }
    .ar-page .ar-card-body table tr:hover td { background-color: #f8faff !important; }
    .ar-card-body table tr:last-child td { border-bottom: none !important; }
    /* 分页 */
    .ar-card-body .pagediv { padding: 12px 16px 8px !important; font-size: 12px !important; color: #94a3b8 !important; display: flex !important; align-items: center; gap: 6px; flex-wrap: wrap; border-top: 1px solid #f1f5f9 !important; background: #fff !important; }
    .ar-card-body .pagediv a { color: #6366f1 !important; text-decoration: none !important; font-size: 12px !important; padding: 4px 10px; border-radius: 6px; transition: all .12s; }
    .ar-card-body .pagediv a:hover { background: #eef2ff !important; }
    /* 日期列不换行 */
    .ar-page .ar-card-body table td:last-child { white-space: nowrap !important; min-width: 90px !important; }
</style>

<div class="ar-page">
    <div class="ar-card">
        <div class="ar-card-head">
            <span class="ar-head-icon ar-head-icon-purple"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
            <h3>拼音输入英雄榜</h3>
        </div>
        <div class="ar-card-body">
            <div class="ar-filter">
                <span class="ar-filter-label">范围</span>
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
                    <asp:BoundField HeaderText="名次" />
                    <asp:BoundField DataField="Psnum" HeaderText="学号" />
                    <asp:BoundField DataField="Sname" HeaderText="姓名">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                    <asp:BoundField DataField="Sclass" HeaderText="班级">
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Ptotal" HeaderText="苹果总数">
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
    </div>
</div>
</asp:Content>

