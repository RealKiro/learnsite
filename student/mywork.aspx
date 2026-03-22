<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_mywork, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* === 覆盖Student主题冲突 === */
    .mw-page, .mw-page * { margin-right: unset !important; margin-left: unset !important; }
    .mw-page .pagediv {
        font-size: 12px !important; width: auto !important; height: auto !important;
        text-align: left !important;
    }
    .mw-page .buttonimg, .mw-page .buttonnone {
        background-image: none !important; border-width: 0 !important;
        width: auto !important; height: auto !important;
    }
    .mw-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .mw-page table[cellpadding] { border: none !important; }

    /* === 页面布局 === */
    .mw-page {
        width: 100%; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: mwFadeIn .4s ease;
    }
    @keyframes mwFadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    .mw-grid { display: grid !important; grid-template-columns: 1fr 280px; gap: 24px; }
    @media(max-width:960px) { .mw-grid { grid-template-columns: 1fr !important; } }

    /* === 卡片 === */
    .mw-card {
        background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        margin-bottom: 22px; overflow: hidden;
        transition: transform .2s ease, box-shadow .2s ease;
    }
    .mw-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04);
    }
    .mw-card-head {
        padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important; align-items: center; gap: 12px;
        background: #fff !important;
    }
    .mw-card-head .mw-head-icon {
        width: 36px; height: 36px; border-radius: 10px;
        display: flex !important; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .mw-head-icon svg {
        width: 18px; height: 18px; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .mw-head-icon-work { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .mw-head-icon-work svg { stroke: #2563eb !important; }
    .mw-head-icon-star { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .mw-head-icon-star svg { stroke: #d97706 !important; }
    .mw-card-head h3 {
        font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important;
        display: flex !important; align-items: center; gap: 8px; flex: 1;
    }
    .mw-card-body { padding: 4px 6px 6px; }

    /* === GridView 表格美化 === */
    .mw-card-body table {
        width: 100% !important; border-collapse: collapse !important;
        border-spacing: 0 !important; border: none !important;
    }
    .mw-page .mw-card-body table th,
    .mw-card-body table th {
        padding: 12px 16px !important; font-size: 12px !important; font-weight: 600 !important;
        color: #64748b !important; text-align: left !important;
        letter-spacing: .3px;
        background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important;
        border-top: none !important; border-left: none !important; border-right: none !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        white-space: nowrap !important;
    }
    .mw-page .mw-card-body table td,
    .mw-card-body table td {
        padding: 11px 16px !important; font-size: 13px !important; color: #334155 !important;
        border-bottom: 1px solid #f1f5f9 !important;
        border-top: none !important; border-left: none !important; border-right: none !important;
        background-color: #fff !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        vertical-align: middle !important;
    }
    .mw-page .mw-card-body table tr,
    .mw-card-body table tr {
        transition: all .15s ease;
        background-color: #fff !important; background: #fff !important;
        font-size: 13px !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
    }
    .mw-page .mw-card-body table tr[style*='WhiteSmoke'],
    .mw-card-body table tr[align='center'] {
        background-color: #fff !important;
    }
    .mw-page .mw-card-body table tr:hover td,
    .mw-card-body table tr:hover td {
        background-color: #f8faff !important;
    }
    .mw-card-body table tr:last-child td { border-bottom: none !important; }

    /* 隐藏果实图标，用CSS圆点替代 */
    .mw-card-body table td img[src*='fruit'] {
        display: none !important;
    }
    .mw-main .mw-card-body table td:first-child {
        position: relative;
        width: 20px !important; min-width: 20px !important;
        padding-left: 24px !important; padding-right: 4px !important;
    }
    .mw-main .mw-card-body table td:first-child::after {
        content: ''; position: absolute; left: 20px; top: 50%; transform: translateY(-50%);
        width: 8px; height: 8px; border-radius: 50%;
        background: #6366f1;
    }

    /* 学案和活动列允许换行 */
    .mw-main .mw-card-body table td:nth-child(2),
    .mw-main .mw-card-body table td:nth-child(3) {
        white-space: normal !important;
        max-width: 200px;
    }
    /* 其他列不换行居中 */
    .mw-main .mw-card-body table td:nth-child(n+4) {
        white-space: nowrap !important;
        text-align: center !important;
    }
    .mw-main .mw-card-body table th:nth-child(n+4) {
        text-align: center !important;
    }

    /* 链接美化 */
    .mw-card-body table a {
        color: #4f46e5 !important; text-decoration: none !important; font-weight: 600;
        transition: color .12s; font-size: 13px !important;
    }
    .mw-card-body table a:hover { color: #818cf8 !important; text-decoration: none !important; }

    /* 分页美化 */
    .mw-card-body .pagediv {
        padding: 12px 20px 8px !important; font-size: 12px !important; color: #94a3b8 !important;
        display: flex !important; align-items: center; gap: 6px; flex-wrap: wrap;
        border-top: 1px solid #f1f5f9 !important;
        background: #fff !important;
    }
    .mw-card-body .pagediv a {
        color: #6366f1 !important; text-decoration: none !important; font-size: 12px !important;
        padding: 4px 10px; border-radius: 6px; transition: all .12s;
    }
    .mw-card-body .pagediv a:hover { background: #eef2ff !important; text-decoration: none !important; }

    /* === 右侧侧边栏 === */
    .mw-sidebar {
        display: flex !important; flex-direction: column; gap: 20px;
        position: static !important; width: auto !important;
        top: auto !important; right: auto !important;
        z-index: auto !important; background: none !important;
    }

    /* 优秀作品卡片 */
    .mw-sidebar .mw-card-body table caption { display: none !important; }
    .mw-sidebar .mw-card-body table td:first-child,
    .mw-sidebar .mw-card-body table th:first-child {
        width: auto !important; min-width: auto !important;
        padding-left: 16px !important; padding-right: 8px !important;
        text-align: center !important;
    }
    .mw-sidebar .mw-card-body table td:first-child::after { display: none !important; }
    .mw-sidebar .mw-card-body table td:nth-child(2) { font-weight: 600; }
    .mw-sidebar .mw-card-body table td:last-child { text-align: center !important; }

    /* 作品收藏按钮 */
    .mw-collect-btn {
        display: flex !important; align-items: center; justify-content: center; gap: 8px;
        padding: 12px 24px !important; border-radius: 10px !important;
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important; font-size: 13px !important; font-weight: 600;
        text-decoration: none !important; border: none !important;
        box-shadow: 0 2px 8px rgba(99,102,241,.25);
        transition: all .2s ease;
        width: auto !important; height: auto !important;
        text-align: center !important;
    }
    .mw-collect-btn:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
        box-shadow: 0 4px 16px rgba(99,102,241,.35);
        transform: translateY(-1px);
        color: #fff !important; text-decoration: none !important;
    }
    .mw-collect-btn svg {
        width: 16px; height: 16px; fill: none; stroke: #fff;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
</style>

<div class="mw-page">
    <div class="mw-grid">
        <!-- 左侧主内容 -->
        <div class="mw-main">
            <div class="mw-card">
                <div class="mw-card-head">
                    <span class="mw-head-icon mw-head-icon-work"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></span>
                    <h3>我的作品</h3>
                </div>
                <div class="mw-card-body">
                    <asp:GridView ID="GridViewworks" runat="server" AllowPaging="True" OnPageIndexChanging="GridViewworks_PageIndexChanging" 
                        PageSize="15" Width="100%" SkinID="GridViewInfo" 
                        onrowdatabound="GridViewworks_RowDataBound" AutoGenerateColumns="False" EnableModelValidation="True">
                        <Columns>            
                            <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Image ID="ImageLeaf" runat="server" ImageUrl="~/images/fruit.gif" />
                            </ItemTemplate>
                            <ItemStyle Width="60px" />
                            </asp:TemplateField>           
                            <asp:BoundField DataField="Ctitle" HeaderText="学案" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                            </asp:BoundField>           
                            <asp:BoundField DataField="Mtitle" HeaderText="活动" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                            </asp:BoundField>
                            <asp:HyperLinkField DataNavigateUrlFields="wid" 
                                DataNavigateUrlFormatString="downwork.aspx?Wid={0}" HeaderText="作品" 
                                Text="查看下载" Target="_blank">
                            <ControlStyle Font-Underline="True" />
                            <ItemStyle Width="120px" />
                            </asp:HyperLinkField>
                            <asp:BoundField DataField="Wscore" HeaderText="学分">
                            <ItemStyle Width="40px" />
                            </asp:BoundField>
                            <asp:BoundField DataField="Wdscore" HeaderText="加分">
                            <ItemStyle Width="40px" />
                            </asp:BoundField>            
                            <asp:BoundField DataField="Wvote" HeaderText="鲜花">
                            <ItemStyle Width="40px" />
                            </asp:BoundField>            
                            <asp:BoundField DataField="cobj" HeaderText="年级" >
                            <ItemStyle Width="40px" />
                            </asp:BoundField>
                            <asp:BoundField DataField="cterm" HeaderText="学期" >
                            <ItemStyle Width="40px" />
                            </asp:BoundField>
                        </Columns>
                        <PagerTemplate>
                            <div class="pagediv">
                                第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" 
                                    Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>页
                                共<asp:Label ID="lblPageCount" runat="server" ForeColor="Black" 
                                    Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                                <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" 
                                    CommandArgument="First" CommandName="Page" Font-Underline="False" 
                                    ForeColor="Black" Text="首页"></asp:LinkButton>
                                <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" 
                                    CommandArgument="Prev" CommandName="Page" Font-Underline="False" 
                                    ForeColor="Black" Text="上一页"></asp:LinkButton>
                                <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" 
                                    CommandArgument="Next" CommandName="Page" Font-Underline="False" 
                                    ForeColor="Black" Text="下一页"></asp:LinkButton>
                                <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" 
                                    CommandArgument="Last" CommandName="Page" Font-Underline="False" 
                                    ForeColor="Black" Text="尾页"></asp:LinkButton>
                            </div>
                        </PagerTemplate>
                        <RowStyle Height="36px" />
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- 右侧侧边栏 -->
        <div class="mw-sidebar">
            <!-- 最新优秀作品 -->
            <div class="mw-card">
                <div class="mw-card-head">
                    <span class="mw-head-icon mw-head-icon-star"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                    <h3>最新优秀作品</h3>
                </div>
                <div class="mw-card-body">
                    <asp:GridView ID="Topwork" runat="server" AllowPaging="True" Width="100%" 
                        SkinID="GridViewInfo" AutoGenerateColumns="False"
                        EnableModelValidation="True" EmptyDataText=" " 
                        onrowdatabound="Topwork_RowDataBound">
                        <Columns>
                            <asp:BoundField HeaderText="序号" />
                            <asp:BoundField DataField="Wname" HeaderText="姓名" />
                            <asp:HyperLinkField DataNavigateUrlFields="wid" 
                                DataNavigateUrlFormatString="downwork.aspx?Wid={0}" HeaderText="作品" 
                                Text="查看" Target="_blank" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- 作品收藏按钮 -->
            <asp:HyperLink ID="HLworks" runat="server" 
                NavigateUrl="~/student/masterwork.aspx" Target="_blank"
                CssClass="mw-collect-btn">
                <svg viewBox="0 0 24 24"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
                作品收藏
            </asp:HyperLink>
        </div>
    </div>
</div>
</asp:Content>

