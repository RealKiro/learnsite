<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_mycourse, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .cs-page, .cs-page * { margin-right: unset !important; margin-left: unset !important; }
    .cs-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .cs-page { width: 100%; max-width: 1200px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: csFadeIn .4s ease; }
    @keyframes csFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .cs-grid { display: grid; grid-template-columns: 1fr 280px; gap: 22px; align-items: start; }
    .cs-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .cs-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .cs-card-head .cs-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .cs-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cs-head-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .cs-head-icon-blue svg { stroke: #2563eb !important; }
    .cs-head-icon-green { background: linear-gradient(135deg, #dcfce7, #bbf7d0) !important; }
    .cs-head-icon-green svg { stroke: #16a34a !important; }
    .cs-head-icon-violet { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .cs-head-icon-violet svg { stroke: #7c3aed !important; }
    .cs-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .cs-card-body { padding: 18px 22px; }
    .cs-page .cs-card-body table { width: 100% !important; border-collapse: collapse !important; border-spacing: 0 !important; border: none !important; }
    .cs-page .cs-card-body table th { padding: 11px 14px !important; font-size: 12px !important; font-weight: 600 !important; color: #64748b !important; text-align: left !important; background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important; border-top: none !important; border-left: none !important; border-right: none !important; font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important; }
    .cs-page .cs-card-body table td { padding: 10px 14px !important; font-size: 13px !important; color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important; border-top: none !important; border-left: none !important; border-right: none !important; background-color: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; vertical-align: middle !important; }
    .cs-page .cs-card-body table tr { background-color: #fff !important; transition: all .12s; height: auto !important; }
    .cs-page .cs-card-body table tr:hover td { background-color: #f8faff !important; }
    .cs-card-body table tr:last-child td { border-bottom: none !important; }
    .cs-page .cs-card-body table a { color: #2563eb !important; text-decoration: none !important; font-weight: 500; transition: color .12s; }
    .cs-page .cs-card-body table a:hover { color: #1d4ed8 !important; }
    .cs-card-body .pagediv { padding: 12px 14px 8px !important; font-size: 12px !important; color: #94a3b8 !important; display: flex !important; align-items: center; gap: 6px; flex-wrap: wrap; border-top: 1px solid #f1f5f9 !important; background: #fff !important; }
    .cs-card-body .pagediv a { color: #2563eb !important; text-decoration: none !important; font-size: 12px !important; padding: 4px 10px; border-radius: 6px; transition: all .12s; }
    .cs-card-body .pagediv a:hover { background: #eef2ff !important; }
    .cs-page .cs-card-body table td:last-child { white-space: nowrap !important; }
    /* 侧边栏个人信息 */
    .cs-sidebar { position: sticky; top: 20px; }
    .cs-profile { text-align: center; padding: 8px 0; }
    .cs-profile img { width: 72px !important; height: 72px !important; border-radius: 50% !important; border: 3px solid #f1f5f9; object-fit: cover; margin-bottom: 8px; }
    .cs-rank { font-size: 13px; color: #64748b; margin-bottom: 12px; }
    .cs-info-row { display: flex; align-items: center; border-bottom: 1px solid #f1f5f9; padding: 9px 0; font-size: 13px; }
    .cs-info-row:last-child { border-bottom: none; }
    .cs-info-label { width: 52px; color: #94a3b8; font-weight: 500; flex-shrink: 0; }
    .cs-info-value { color: #1e293b; flex: 1; }
    .cs-page #student { margin: 0 !important; padding: 0 !important; text-align: left !important; }
    .cs-page .left, .cs-page .right { float: none !important; width: 100% !important; text-align: left !important; overflow: visible !important; }
    .cs-page .ccontent { margin: 0 !important; width: 100% !important; }
    .cs-page .divinfo, .cs-page .divinfo1, .cs-page .divinfo2 { float: none !important; width: auto !important; border: none !important; background: none !important; height: auto !important; display: none !important; }
</style>

<div class="cs-page">
<div id="student">
<div class="cs-grid">
    <div class="left">
        <!-- 未学学案 -->
        <div class="cs-card">
            <div class="cs-card-head">
                <span class="cs-head-icon cs-head-icon-blue"><svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></span>
                <h3>未学学案</h3>
            </div>
            <div class="cs-card-body">
                <div class="ccontent">
                <asp:GridView ID="GridViewnewkc" runat="server" Width="100%" 
                    SkinID="GridViewInfo" onrowdatabound="GridViewnewkc_RowDataBound" 
                    AutoGenerateColumns="False" EnableModelValidation="True" PageSize="5" AllowPaging="True" 
                    onpageindexchanging="GridViewnewkc_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="cid" Visible="false"><ItemStyle Width="30px" ForeColor="White" /></asp:BoundField>
                        <asp:BoundField DataField="Cclass" HeaderText="分类"><HeaderStyle HorizontalAlign="Left" /><ItemStyle Width="80px" HorizontalAlign="Left" /></asp:BoundField>
                        <asp:TemplateField><ItemTemplate><asp:Image ID="ImageLeaf" runat="server" ImageUrl="~/images/leaf.gif" /></ItemTemplate><ItemStyle Width="24px" /></asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="cid" DataNavigateUrlFormatString="~/student/showcourse.aspx?cid={0}" DataTextField="ctitle" HeaderText="学案名称"><HeaderStyle HorizontalAlign="Left" /><ItemStyle HorizontalAlign="Left" /></asp:HyperLinkField>
                        <asp:BoundField DataField="Cdate" HeaderText="日期"><HeaderStyle HorizontalAlign="Left" /><ItemStyle HorizontalAlign="Left" Width="100px" /></asp:BoundField>
                    </Columns>
                    <PagerTemplate>
                        <div class="pagediv">
                            第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>/
                            <asp:Label ID="lblPageCount" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                            <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                            <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上一页"></asp:LinkButton>
                            <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下一页"></asp:LinkButton>
                            <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                        </div>
                    </PagerTemplate>
                </asp:GridView>
                </div>
            </div>
        </div>
        <!-- 已学学案 -->
        <div class="cs-card">
            <div class="cs-card-head">
                <span class="cs-head-icon cs-head-icon-green"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></span>
                <h3>已学学案</h3>
            </div>
            <div class="cs-card-body">
                <div class="ccontent">
                <asp:GridView ID="GridViewdonekc" runat="server" AllowPaging="True" 
                    AutoGenerateColumns="False" EnableModelValidation="True" 
                    OnPageIndexChanging="GridViewdonekc_PageIndexChanging" 
                    onrowdatabound="GridViewdonekc_RowDataBound" SkinID="GridViewInfo" Width="100%" PageSize="5">
                    <Columns>
                        <asp:BoundField DataField="cid" Visible="false"><ItemStyle ForeColor="White" Width="30px" /></asp:BoundField>
                        <asp:BoundField DataField="Cclass" HeaderText="分类"><HeaderStyle HorizontalAlign="Left" /><ItemStyle HorizontalAlign="Left" Width="80px" /></asp:BoundField>
                        <asp:TemplateField><ItemTemplate><asp:Image ID="ImageLeaf" runat="server" ImageUrl="~/images/fruit.gif" /></ItemTemplate><ItemStyle Width="24px" /></asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="cid" DataNavigateUrlFormatString="~/student/showcourse.aspx?cid={0}" DataTextField="ctitle" HeaderText="学案名称"><HeaderStyle HorizontalAlign="Left" /><ItemStyle HorizontalAlign="Left" /></asp:HyperLinkField>
                        <asp:BoundField DataField="cobj" HeaderText="年级"><ItemStyle Width="40px" /></asp:BoundField>
                        <asp:BoundField DataField="cterm" HeaderText="学期"><ItemStyle Width="40px" /></asp:BoundField>
                    </Columns>
                    <PagerTemplate>
                        <div class="pagediv">
                            第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>/
                            <asp:Label ID="lblPageCount" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                            <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                            <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上一页"></asp:LinkButton>
                            <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下一页"></asp:LinkButton>
                            <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                        </div>
                    </PagerTemplate>
                </asp:GridView>
                </div>
            </div>
        </div>
    </div>
    <!-- 右侧边栏 -->
    <div class="cs-sidebar right">
        <div class="cs-card">
            <div class="cs-card-head">
                <span class="cs-head-icon cs-head-icon-violet"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                <h3>我的信息</h3>
            </div>
            <div class="cs-card-body">
                <div class="cs-profile">
                    <asp:Image ID="Imageface" runat="server" Height="72px" Width="72px" />
                    <div class="cs-rank"><asp:Label ID="LabelRank" runat="server"></asp:Label></div>
                </div>
                <div id="DivRank" class="divinfo"></div>
                <div class="cs-info-row"><span class="cs-info-label">学号</span><span class="cs-info-value"><asp:Label ID="snum" runat="server"></asp:Label></span></div>
                <div class="cs-info-row"><span class="cs-info-label">班级</span><span class="cs-info-value"><asp:Label ID="sclass" runat="server"></asp:Label></span></div>
                <div class="cs-info-row"><span class="cs-info-label">姓名</span><span class="cs-info-value"><asp:Label ID="sname" runat="server"></asp:Label></span></div>
                <div class="cs-info-row"><span class="cs-info-label">组长</span><span class="cs-info-value"><asp:Label ID="sleadername" runat="server"></asp:Label></span></div>
                <div class="cs-info-row"><span class="cs-info-label">IP</span><span class="cs-info-value"><asp:Label ID="Labelip" runat="server" SkinID="LabelSize8"></asp:Label></span></div>
                <asp:Label ID="LabelCids" runat="server" ForeColor="White" style="display:none;"></asp:Label>
            </div>
        </div>
    </div>
</div>
</div>
</div>
</asp:Content>
