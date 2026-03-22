<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_courseold, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        /* ===== 学案仓库页面美化 ===== */
        .courseold-page { max-width: 1400px; margin: 0 auto; }

        /* 页面标题 */
        .courseold-page .page-title-bar {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px;
        }
        .courseold-page .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .courseold-page .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #f59e0b, #fbbf24);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .courseold-page .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }

        /* 卡片容器 */
        .courseold-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            border: 1px solid #e8ecf1; overflow: hidden;
        }

        /* 筛选栏 */
        .courseold-page .filter-bar {
            display: flex; align-items: center; flex-wrap: wrap; gap: 12px;
            padding: 16px 20px; background: #fff;
            border-bottom: 1px solid #e8ecf1;
        }
        .courseold-page .filter-group {
            display: flex; align-items: center; gap: 6px;
            font-size: 13px; color: #475569;
        }
        .courseold-page .filter-group .filter-label {
            font-weight: 600; color: #334155; white-space: nowrap;
        }
        .courseold-page .filter-bar select,
        .courseold-page .filter-group select {
            height: 34px; padding: 0 10px; border: 1px solid #d1d5db;
            border-radius: 8px; background: #fff; font-size: 13px; color: #334155;
            outline: none; cursor: pointer; transition: all 0.2s;
        }
        .courseold-page .filter-bar select:hover { border-color: #f59e0b; }
        .courseold-page .filter-bar select:focus {
            border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245,158,11,0.1);
        }
        .courseold-page .filter-msg { font-size: 12px; color: #94a3b8; }
        .courseold-page .filter-spacer { flex: 1; }

        /* 返回按钮 */
        .courseold-page .btn-return {
            height: 34px; padding: 0 20px; border: 1px solid #d1d5db; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            background: #fff; color: #475569;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
            display: inline-flex; align-items: center; gap: 6px;
        }
        .courseold-page .btn-return:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
            box-shadow: 0 2px 8px rgba(99,102,241,0.12);
        }

        /* GridView 表格 */
        .courseold-page .table-wrap { padding: 0; }
        .courseold-page .table-wrap table { width: 100%; border-collapse: collapse; }
        .courseold-page .table-wrap th {
            background: #f8fafc !important; color: #64748b !important;
            font-size: 12px !important; font-weight: 600 !important;
            text-transform: uppercase; letter-spacing: 0.3px;
            padding: 12px 16px !important; border-bottom: 2px solid #e8ecf1 !important;
            white-space: nowrap; vertical-align: middle !important;
            text-align: center !important;
        }
        .courseold-page .table-wrap td {
            padding: 12px 16px !important; font-size: 13px; color: #334155;
            border-bottom: 1px solid #f1f5f9 !important;
            vertical-align: middle !important; text-align: center;
        }
        .courseold-page .table-wrap tr { background: #fff !important; transition: background 0.15s; }
        .courseold-page .table-wrap tbody tr:hover { background: #f8fafc !important; }
        .courseold-page .table-wrap tr:nth-child(even) { background: #fafbfc !important; }
        .courseold-page .table-wrap tr:nth-child(even):hover { background: #f1f5f9 !important; }

        /* 表格链接 */
        .courseold-page .table-wrap a {
            color: #6366f1; text-decoration: none; font-weight: 500; transition: color 0.15s;
        }
        .courseold-page .table-wrap a:hover { color: #4f46e5; text-decoration: underline; }

        /* 启用按钮特殊样式 */
        .courseold-page .table-wrap a[title*="启用"],
        .courseold-page .table-wrap .btn-enable {
            color: #059669; font-weight: 600;
        }
        .courseold-page .table-wrap a[title*="启用"]:hover,
        .courseold-page .table-wrap .btn-enable:hover {
            color: #047857;
        }

        /* 删除链接 */
        .courseold-page .table-wrap a[href*="coursedel"] {
            color: #ef4444; font-weight: 500;
        }
        .courseold-page .table-wrap a[href*="coursedel"]:hover {
            color: #dc2626;
        }

        /* 分页器 */
        .courseold-page .pager-bar {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 6px; padding: 14px 20px; background: #f8fafc;
            border-top: 1px solid #e8ecf1; font-size: 13px; color: #64748b;
        }
        .courseold-page .pager-bar a {
            padding: 5px 12px; border-radius: 6px; font-size: 12px;
            color: #475569 !important; text-decoration: none !important; border: 1px solid #d1d5db;
            background: #fff; cursor: pointer; transition: all 0.15s;
            font-weight: 500; display: inline-block; line-height: 1.5;
        }
        .courseold-page .pager-bar a:hover {
            background: #f5f3ff; border-color: #818cf8; color: #6366f1 !important;
        }
        .courseold-page .pager-info {
            font-size: 12px; color: #94a3b8; margin-right: 8px;
        }

        /* 底部提示 */
        .courseold-page .hint-bar {
            display: flex; align-items: center; justify-content: center;
            gap: 8px; margin-top: 16px; padding: 12px 20px;
            background: #fff; border: 1px solid #e8ecf1;
            border-radius: 10px; font-size: 13px; color: #92400e;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .courseold-page .hint-bar svg {
            width: 18px; height: 18px; stroke: #f59e0b; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
            flex-shrink: 0;
        }

        /* 文字说明板块 */
        .courseold-page .info-section {
            margin-top: 16px; padding: 20px 24px;
            background: #fff; border: 1px solid #e8ecf1;
            border-radius: 12px; font-size: 13px; color: #475569;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
        }
        .courseold-page .info-section h3 {
            font-size: 15px; font-weight: 700; color: #1e293b; margin: 0 0 12px;
            display: flex; align-items: center; gap: 8px;
        }
        .courseold-page .info-section h3 svg {
            width: 18px; height: 18px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
            flex-shrink: 0;
        }
        .courseold-page .info-section ul {
            margin: 0; padding: 0 0 0 20px; line-height: 2;
        }
        .courseold-page .info-section li {
            color: #475569;
        }
        .courseold-page .info-section li strong {
            color: #334155; font-weight: 600;
        }
        .courseold-page .info-section li .text-green { color: #059669; font-weight: 600; }
        .courseold-page .info-section li .text-red { color: #ef4444; font-weight: 600; }
        .courseold-page .info-section li .text-indigo { color: #6366f1; font-weight: 600; }
    </style>

    <div class="courseold-page">
        <!-- 页面标题 -->
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M21 8v13H3V8"/><path d="M1 3h22v5H1z"/><path d="M10 12h4"/></svg>
                </span>
                学案仓库
            </h2>
        </div>

        <!-- 筛选卡片 -->
        <div class="courseold-card">
            <div class="filter-bar">
                <div class="filter-group">
                    <span class="filter-label">年级</span>
                    <asp:DropDownList ID="DDLgrade" runat="server" 
                        Width="80px" EnableTheming="True" AutoPostBack="True" 
                        onselectedindexchanged="DDLgrade_SelectedIndexChanged" />
                </div>
                <div class="filter-group">
                    <span class="filter-label">学期</span>
                    <asp:DropDownList ID="DDLterm" runat="server" 
                        EnableTheming="True" AutoPostBack="True" 
                        onselectedindexchanged="DDLterm_SelectedIndexChanged" 
                        ToolTip="选择要显示学案的学期，不改变后台默认学期设置">
                        <asp:ListItem Value="1">第一学期</asp:ListItem>
                        <asp:ListItem Value="2">第二学期</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <span class="filter-msg">
                    <asp:Label ID="Labelmsg" runat="server"></asp:Label>
                </span>
                <span class="filter-msg">
                    <asp:Label ID="Labelspace" runat="server"></asp:Label>
                </span>
                <span class="filter-spacer"></span>
                <asp:Button ID="Btnreturn" runat="server" Text="← 返回学案" 
                    onclick="Btnreturn_Click" CssClass="btn-return" />
            </div>

            <!-- 数据表格 -->
            <div class="table-wrap">
                <asp:GridView ID="GVCourse" runat="server" AllowPaging="True"
                    AutoGenerateColumns="False" DataKeyNames="Cid"  
                    PageSize="20" Width="100%"
                    onpageindexchanging="GVCourse_PageIndexChanging" 
                    onrowdatabound="GVCourse_RowDataBound" CellPadding="0" 
                    EnableModelValidation="True" 
                    onrowcommand="GVCourse_RowCommand" ForeColor="#334155" GridLines="None" >
                    <AlternatingRowStyle BackColor="#fafbfc" />
                    <Columns>
                        <asp:BoundField DataField="Cobj" HeaderText="年级">
                            <ControlStyle Width="20px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="Cterm" HeaderText="学期" />
                        <asp:BoundField DataField="Cks" HeaderText="课节">
                            <ControlStyle Width="20px" />
                        </asp:BoundField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid" 
                            DataNavigateUrlFormatString="~/teacher/courseshow.aspx?cid={0}&amp;cold=T" 
                            DataTextField="Ctitle" HeaderText="仓库学案" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:HyperLinkField>
                        <asp:BoundField DataField="Cclass" HeaderText="类型" SortExpression="Cclass" />
                        <asp:TemplateField HeaderText="操作" ShowHeader="False">
                            <ItemTemplate>
                                <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="false" 
                                    CommandArgument='<%# Bind("Cid") %>' CommandName="U" 
                                    ToolTip="将此学案重新启用，在学案列表中显示出来" Text="启用" 
                                    CssClass="btn-enable" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="日期" SortExpression="Cdate">
                            <ItemTemplate>
                                <asp:Label ID="Label2" runat="server" 
                                    Text='<%# DataBinder.Eval(Container.DataItem,"Cdate","{0:d}")%>' />
                            </ItemTemplate>
                            <ControlStyle Width="70px" />
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid" 
                            DataNavigateUrlFormatString="~/teacher/coursedel.aspx?cid={0}" Text="删除">
                            <ItemStyle Width="60px" />
                        </asp:HyperLinkField>
                    </Columns>
                    <FooterStyle BackColor="#f8fafc" Font-Bold="True" ForeColor="#64748b" />
                    <HeaderStyle BackColor="#f8fafc" Font-Bold="True" ForeColor="#64748b" />
                    <PagerStyle BackColor="#f8fafc" ForeColor="#475569" HorizontalAlign="Right" />
                    <pagertemplate>
                        <div class="pager-bar">
                            <span class="pager-info">
                                第 <asp:Label ID="lblPageIndex" runat="server" 
                                    text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>" /> 页
                                / 共 <asp:Label ID="lblPageCount" runat="server" 
                                    text="<%# ((GridView)Container.Parent.Parent).PageCount %>" /> 页
                            </span>
                            <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False" 
                                commandargument="First" commandname="Page" Font-Underline="False" 
                                text="首页" />
                            <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False" 
                                commandargument="Prev" commandname="Page" Font-Underline="False" 
                                text="上一页" />
                            <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False" 
                                commandargument="Next" commandname="Page" Font-Underline="False" 
                                text="下一页" />
                            <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False" 
                                commandargument="Last" commandname="Page" Font-Underline="False" 
                                text="尾页" />
                        </div>
                    </pagertemplate>
                    <RowStyle BackColor="#ffffff" />
                    <SelectedRowStyle BackColor="#eef2ff" Font-Bold="True" ForeColor="#4f46e5" />
                </asp:GridView>
            </div>
        </div>

        <!-- 底部提示 -->
        <div class="hint-bar">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            仓库中学案只能浏览，不能编辑！如需使用，请点击「启用」将学案恢复到学案列表。
        </div>

        <!-- 文字说明板块 -->
        <div class="info-section">
            <h3>
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                使用说明
            </h3>
            <ul>
                <li><strong>学案仓库</strong>用于存放已归档的历史学案，方便教师查阅和管理往期教学资料。</li>
                <li>仓库中的学案<strong>仅支持浏览</strong>，无法直接编辑内容。</li>
                <li>点击学案标题可以<span class="text-indigo">预览</span>学案的详细内容。</li>
                <li>如需重新使用某个学案，请点击对应行的<span class="text-green">「启用」</span>按钮，学案将恢复到备课列表中。</li>
                <li>如确认不再需要某个学案，可点击<span class="text-red">「删除」</span>将其永久移除（请谨慎操作）。</li>
                <li>使用顶部的<strong>年级</strong>和<strong>学期</strong>筛选器，可以快速定位到特定时段的学案。</li>
            </ul>
        </div>
    </div>
</asp:Content>

