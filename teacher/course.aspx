<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_course, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        /* ===== 学案管理页面美化 ===== */
        .course-page { max-width: 1400px; margin: 0 auto; }

        /* 页面标题 */
        .page-title-bar {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px;
        }
        .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }

        /* 卡片容器 */
        .course-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            border: 1px solid #e8ecf1; overflow: hidden;
        }

        /* 筛选栏 */
        .filter-bar {
            display: flex; align-items: center; flex-wrap: wrap; gap: 12px;
            padding: 16px 20px; background: #f8fafc;
            border-bottom: 1px solid #e8ecf1;
        }
        .filter-group {
            display: flex; align-items: center; gap: 6px;
            font-size: 13px; color: #475569;
        }
        .filter-group .filter-label {
            font-weight: 600; color: #334155; white-space: nowrap;
        }
        .filter-bar select,
        .filter-group select {
            height: 34px; padding: 0 10px; border: 1px solid #d1d5db;
            border-radius: 8px; background: #fff; font-size: 13px; color: #334155;
            outline: none; cursor: pointer; transition: all 0.2s;
        }
        .filter-bar select:hover, .filter-group select:hover { border-color: #818cf8; }
        .filter-bar select:focus, .filter-group select:focus {
            border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        }
        .filter-msg { font-size: 12px; color: #94a3b8; }
        .filter-spacer { flex: 1; }

        /* 添加按钮 */
        .course-page .btn-add {
            height: 34px; padding: 0 18px; border: none; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            white-space: nowrap; display: inline-flex; align-items: center; gap: 6px;
            background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff !important;
            box-shadow: 0 1px 3px rgba(99,102,241,0.3);
        }
        .course-page .btn-add:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px);
        }

        /* GridView 表格 */
        .table-wrap { padding: 0; }
        .table-wrap table { width: 100%; border-collapse: collapse; }
        .table-wrap th {
            background: #f8fafc !important; color: #64748b !important;
            font-size: 12px !important; font-weight: 600 !important;
            text-transform: uppercase; letter-spacing: 0.3px;
            padding: 12px 16px !important; border-bottom: 2px solid #e8ecf1 !important;
            white-space: nowrap; vertical-align: middle !important;
            text-align: center !important;
        }
        .table-wrap td {
            padding: 12px 16px !important; font-size: 13px; color: #334155;
            border-bottom: 1px solid #f1f5f9 !important;
            vertical-align: middle !important; text-align: center;
            white-space: nowrap;
        }
        .table-wrap td a, .table-wrap td span, .table-wrap td input {
            vertical-align: middle;
        }
        .table-wrap tr { background: #fff !important; transition: background 0.15s; }
        .table-wrap tbody tr:hover { background: #f8fafc !important; }
        .table-wrap tr:nth-child(even) { background: #fafbfc !important; }
        .table-wrap tr:nth-child(even):hover { background: #f1f5f9 !important; }

        /* 表格链接 */
        .table-wrap a {
            color: #6366f1; text-decoration: none; font-weight: 500; transition: color 0.15s;
        }
        .table-wrap a:hover { color: #4f46e5; text-decoration: underline; }

        /* 分页器 */
        .pager-bar {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 6px; padding: 14px 20px; background: #f8fafc;
            border-top: 1px solid #e8ecf1; font-size: 13px; color: #64748b;
        }
        .pager-bar a {
            padding: 5px 12px; border-radius: 6px; font-size: 12px;
            color: #475569 !important; text-decoration: none !important; border: 1px solid #d1d5db;
            background: #fff; cursor: pointer; transition: all 0.15s;
            font-weight: 500; display: inline-block; line-height: 1.5;
        }
        .pager-bar a:hover {
            background: #f5f3ff; border-color: #818cf8; color: #6366f1 !important;
        }
        .pager-info {
            font-size: 12px; color: #94a3b8; margin-right: 8px;
        }

        /* 底部操作栏 */
        .bottom-actions {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 12px; margin-top: 16px; padding-bottom: 10px;
        }
        .bottom-actions .btn-outline {
            height: 36px; padding: 0 20px; border-radius: 8px; font-size: 13px;
            font-weight: 600; cursor: pointer; transition: all 0.2s;
            border: 1px solid #d1d5db; background: #fff; color: #475569;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
        }
        .bottom-actions .btn-outline:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
            box-shadow: 0 2px 8px rgba(99,102,241,0.12);
        }
    </style>

    <div class="course-page">
        <!-- 页面标题 -->
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                </span>
                学案管理
            </h2>
        </div>

        <!-- 筛选卡片 -->
        <div class="course-card">
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
                <asp:Button ID="Btnadd" runat="server" Text="+ 添加学案" onclick="Btnadd_Click" CssClass="btn-add" />
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
                        <asp:BoundField DataField="Cks" HeaderText="课节">
                            <ControlStyle Width="20px" />
                        </asp:BoundField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid" 
                            DataNavigateUrlFormatString="~/teacher/courseshow.aspx?cid={0}" 
                            DataTextField="Ctitle" HeaderText="学案" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:HyperLinkField>
                        <asp:BoundField DataField="Cclass" HeaderText="类型" SortExpression="Cclass" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:BoundField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid"                                     
                            DataNavigateUrlFormatString="~/teacher/package.aspx?cid={0}" HeaderText="打包" 
                            Text="下载" />
                        <asp:TemplateField HeaderText="发布" ShowHeader="False">
                            <ItemTemplate>
                                <asp:LinkButton ID="LbtnCpublish" runat="server" CausesValidation="false" 
                                    CommandArgument='<%# Bind("Cid") %>' CommandName="Cp" Text='<%# Eval("Cpublish") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid" 
                            DataNavigateUrlFormatString="~/teacher/courseanalyse.aspx?cid={0}" 
                            Text="分析" HeaderText="作品" />
                        <asp:TemplateField HeaderText="探讨">
                            <ItemTemplate>                                    
                                <asp:HyperLink ID="Hl" runat="server" Text="反思" ForeColor="#6366f1" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="推荐" ShowHeader="False">
                            <ItemTemplate>
                                <asp:LinkButton ID="LbtnCgood" runat="server" CausesValidation="false" 
                                    CommandArgument='<%# Bind("Cid") %>' CommandName="Cg" 
                                    ToolTip="默认为True，学生平台作品收藏学案列表中显示；False则不显示!" 
                                    Text='<%# Eval("Cgood") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid" 
                            DataNavigateUrlFormatString="~/teacher/courseedit.aspx?cid={0}" Text="编辑" 
                            HeaderText="内容">
                            <ItemStyle Width="40px" />
                        </asp:HyperLinkField>
                        <asp:TemplateField HeaderText="日期" SortExpression="Cdate">
                            <ItemTemplate>
                                <asp:Label ID="Label2" runat="server" 
                                    Text='<%# DataBinder.Eval(Container.DataItem,"Cdate","{0:d}")%>' />
                            </ItemTemplate>
                            <ControlStyle Width="70px" />
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="入库" ShowHeader="False">
                            <ItemTemplate>
                                <asp:LinkButton ID="LbtnCold" runat="server" CausesValidation="false" 
                                    CommandArgument='<%# Bind("Cid") %>' ToolTip="转移到学案仓库中保留" 
                                    CommandName="Cu" Text="转移" />
                            </ItemTemplate>
                            <ControlStyle Width="40px" />
                        </asp:TemplateField>
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

        <!-- 底部操作 -->
        <div class="bottom-actions">
            <asp:Button ID="Btnimport" runat="server" Text="导入学案" onclick="Btnimport_Click" CssClass="btn-outline" />
            <asp:Button ID="Btnold" runat="server" Text="学案仓库" onclick="Btnold_Click" CssClass="btn-outline" />
        </div>
    </div>

    <script type="text/javascript">
        function tshow(c) {
            window.location.href = "../lessons/thinkshow.aspx?cid=" + c;
        }
    </script>
</asp:Content>

