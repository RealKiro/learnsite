<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typer, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== 打字管理页面美化 ===== */
    .typer-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    /* 页面标题栏 */
    .typer-page-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .typer-page-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .typer-page-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .typer-page-title .title-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .typer-page-title .title-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .typer-page-subtitle { font-size: 13px; color: #94a3b8; font-weight: 400; margin-left: 52px; }
    .typer-header-actions { display: flex; gap: 10px; align-items: flex-start; padding-top: 4px; }

    /* 通用按钮样式覆盖 */
    .typer-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s ease; text-decoration: none;
        font-family: inherit; height: 36px; line-height: 1;
    }
    .typer-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .typer-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .typer-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.3); color: #fff; }
    .typer-btn-danger {
        color: #ef4444; border-color: #fecaca;
    }
    .typer-btn-danger:hover { background: #fef2f2; border-color: #f87171; color: #dc2626; }
    .typer-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 卡片容器 */
    .typer-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .typer-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .typer-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .typer-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .typer-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; font-weight: 400; }
    .typer-card-body { padding: 16px 24px; }

    /* 提示信息条 */
    .typer-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;
        background: #eef2ff; border: 1px solid #e0e7ff; font-size: 13px; color: #4338ca; line-height: 1.6;
    }
    .typer-tip svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }
    .typer-tip-warn {
        background: #fffbeb; border-color: #fef3c7; color: #92400e;
    }
    .typer-tip-warn svg { stroke: #f59e0b; }

    /* 表格美化 */
    .typer-card-body table { width: 100%; border-collapse: collapse; }
    .typer-card-body table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 18px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .typer-card-body table td {
        padding: 12px 18px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155;
        transition: background .1s;
    }
    .typer-card-body table tr:hover td { background: #f8fafc; }
    .typer-card-body table tr:last-child td { border-bottom: none; }
    .typer-card-body table a { color: #6366f1; text-decoration: none; font-weight: 500; transition: color .15s; }
    .typer-card-body table a:hover { color: #4f46e5; text-decoration: underline; }

    /* 分页美化 */
    .typer-pager {
        display: flex; align-items: center; justify-content: center; gap: 6px;
        padding: 14px 0; font-size: 13px; color: #64748b;
    }
    .typer-pager a {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 5px 12px; border-radius: 6px; background: #f1f5f9;
        color: #475569; text-decoration: none; font-weight: 500; font-size: 12px;
        transition: all .15s; border: 1px solid transparent;
    }
    .typer-pager a:hover { background: #e0e7ff; color: #4f46e5; border-color: #c7d2fe; }
    .typer-pager span { color: #94a3b8; }
    .typer-pager .pager-info { font-size: 12px; color: #94a3b8; margin: 0 8px; }

    /* 工具栏卡片 */
    .typer-toolbar {
        display: flex; flex-wrap: wrap; align-items: center; gap: 12px;
    }
    .typer-toolbar-group {
        display: flex; align-items: center; gap: 8px;
        padding: 4px 0;
    }
    .typer-toolbar-divider {
        width: 1px; height: 24px; background: #e2e8f0; margin: 0 4px;
    }
    .typer-toolbar label { font-size: 13px; color: #64748b; font-weight: 500; }

    /* 下拉框美化 */
    .typer-select {
        padding: 6px 10px; border-radius: 6px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff;
        outline: none; transition: border-color .15s; cursor: pointer;
        font-family: inherit;
    }
    .typer-select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }

    /* 链接按钮 */
    .typer-link {
        display: inline-flex; align-items: center; gap: 4px;
        font-size: 13px; color: #6366f1; text-decoration: none; font-weight: 500;
        padding: 6px 12px; border-radius: 6px; transition: all .15s;
    }
    .typer-link:hover { background: #eef2ff; color: #4f46e5; }
    .typer-link svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 消息标签 */
    .typer-msg { min-height: 20px; margin-bottom: 8px; }

    /* 统计卡片行 */
    .typer-stats {
        display: flex; gap: 16px; margin-bottom: 24px;
    }
    .typer-stat-item {
        flex: 1; padding: 18px 22px; border-radius: 10px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: center; gap: 14px;
        box-shadow: 0 1px 3px rgba(0,0,0,.03);
    }
    .typer-stat-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .typer-stat-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .typer-stat-icon.purple { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .typer-stat-icon.blue { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .typer-stat-icon.green { background: linear-gradient(135deg,#10b981,#34d399); }
    .typer-stat-info { display: flex; flex-direction: column; }
    .typer-stat-label { font-size: 12px; color: #94a3b8; margin-bottom: 2px; }
    .typer-stat-value { font-size: 13px; font-weight: 600; color: #1e293b; }
</style>

<div class="typer-page">
    <!-- 页面标题栏 -->
    <div class="typer-page-header">
        <div class="typer-page-title-wrap">
            <div class="typer-page-title">
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><polyline points="4 7 4 4 20 4 20 7"/><line x1="9" y1="20" x2="15" y2="20"/><line x1="12" y1="4" x2="12" y2="20"/></svg>
                </span>
                中文打字管理
            </div>
            <div class="typer-page-subtitle">管理打字练习文章、配置打字参数、查看和清理学生打字成绩</div>
        </div>
        <div class="typer-header-actions">
            <asp:Button ID="BtnTypeSet" runat="server" Text="⚙ 打字设置"
                onclick="BtnTypeSet_Click" CssClass="typer-btn" />
            <asp:Button ID="BtnAdd" runat="server" Text="＋ 文章添加"
                onclick="BtnAdd_Click" CssClass="typer-btn typer-btn-primary" />
        </div>
    </div>

    <!-- 快捷功能入口 -->
    <div class="typer-stats">
        <div class="typer-stat-item">
            <div class="typer-stat-icon purple">
                <svg viewBox="0 0 24 24"><polyline points="4 7 4 4 20 4 20 7"/><line x1="9" y1="20" x2="15" y2="20"/><line x1="12" y1="4" x2="12" y2="20"/></svg>
            </div>
            <div class="typer-stat-info">
                <span class="typer-stat-label">打字设置</span>
                <span class="typer-stat-value">设置打字练习的速度阈值和计时规则</span>
            </div>
        </div>
        <div class="typer-stat-item">
            <div class="typer-stat-icon blue">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            </div>
            <div class="typer-stat-info">
                <span class="typer-stat-label">文章管理</span>
                <span class="typer-stat-value">添加、编辑或删除学生打字练习使用的文章</span>
            </div>
        </div>
        <div class="typer-stat-item">
            <div class="typer-stat-icon green">
                <svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg>
            </div>
            <div class="typer-stat-info">
                <span class="typer-stat-label">成绩管理</span>
                <span class="typer-stat-value">查看排行榜、清除异常成绩数据</span>
            </div>
        </div>
    </div>

    <!-- 文章列表卡片 -->
    <div class="typer-card">
        <div class="typer-card-header">
            <div>
                <div class="typer-card-title">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    打字练习文章列表
                </div>
                <div class="typer-card-desc">点击文章标题可预览内容，点击「编辑」可修改文章，点击「删除」可移除文章</div>
            </div>
        </div>
        <div class="typer-card-body" style="padding:0;">
            <asp:GridView ID="GVType" runat="server" AllowPaging="True"
                AutoGenerateColumns="False" CellPadding="5" SkinID="GridViewInfo"
                PageSize="20" Width="100%" onpageindexchanging="GVType_PageIndexChanging"
                onrowdatabound="GVType_RowDataBound" EnableModelValidation="True"
                GridLines="None" BorderWidth="0">
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:HyperLinkField DataNavigateUrlFields="Tid"
                        DataNavigateUrlFormatString="typeshow.aspx?tid={0}" DataTextField="Ttitle"
                        HeaderText="文章标题">
                    <ItemStyle HorizontalAlign="Left" />
                    </asp:HyperLinkField>
                    <asp:BoundField DataField="Ttype" HeaderText="文章类型" />
                    <asp:BoundField DataField="Tuse" HeaderText="文章范围">
                    <ControlStyle Width="30px" />
                    </asp:BoundField>
                    <asp:HyperLinkField DataNavigateUrlFields="Tid"
                        DataNavigateUrlFormatString="typeedit.aspx?tid={0}" Text="✏ 编辑">
                    <ControlStyle Width="50px" />
                    </asp:HyperLinkField>
                    <asp:HyperLinkField DataNavigateUrlFields="Tid"
                        DataNavigateUrlFormatString="typedel.aspx?tid={0}" Text="🗑 删除" />
                </Columns>
                <HeaderStyle BackColor="#F8FAFC" ForeColor="#64748B" Font-Bold="true" Font-Size="12px" />
                <RowStyle ForeColor="#334155" Font-Size="13px" />
                <AlternatingRowStyle BackColor="#FAFBFC" />
                <pagertemplate>
                    <div class="typer-pager">
                        <span class="pager-info">第
                            <asp:Label ID="lblPageIndex" runat="server"
                                text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>" />
                            页 / 共
                            <asp:Label ID="lblPageCount" runat="server"
                                text="<%# ((GridView)Container.Parent.Parent).PageCount %>" />
                            页
                        </span>
                        <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False"
                            commandargument="First" commandname="Page" Font-Underline="False"
                            text="首页" CssClass="" />
                        <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False"
                            commandargument="Prev" commandname="Page" Font-Underline="False"
                            text="‹ 上一页" CssClass="" />
                        <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False"
                            commandargument="Next" commandname="Page" Font-Underline="False"
                            text="下一页 ›" CssClass="" />
                        <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False"
                            commandargument="Last" commandname="Page" Font-Underline="False"
                            text="尾页" CssClass="" />
                    </div>
                </pagertemplate>
            </asp:GridView>
        </div>
    </div>

    <!-- 成绩管理工具卡片 -->
    <div class="typer-card">
        <div class="typer-card-header">
            <div>
                <div class="typer-card-title">
                    <svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg>
                    成绩管理与数据维护
                </div>
                <div class="typer-card-desc">清除异常打字成绩、打印排行榜、管理指法练习数据</div>
            </div>
            <div style="display:flex;gap:10px;">
                <asp:HyperLink ID="HLprint" runat="server"
                    NavigateUrl="~/teacher/printtyper.aspx" CssClass="typer-link">
                    <svg viewBox="0 0 24 24"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                    排行榜打印
                </asp:HyperLink>
                <asp:HyperLink ID="HLfinger" runat="server"
                    NavigateUrl="~/en.aspx" Target="_blank" CssClass="typer-link">
                    <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    指法英文字典
                </asp:HyperLink>
            </div>
        </div>
        <div class="typer-card-body">
            <div class="typer-msg">
                <asp:Label ID="labelmsg" runat="server" SkinID="LabelMsgRed" Width="160px"></asp:Label>
            </div>

            <!-- 按速度清除 -->
            <div class="typer-tip">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div>如果发现学生打字速度数据异常（如使用复制粘贴导致速度虚高），可以在下方选择速度阈值后清除。清除操作将删除所有超过指定速度的中文打字成绩记录，请谨慎操作。</div>
            </div>
            <div class="typer-toolbar">
                <div class="typer-toolbar-group">
                    <label>速度超过</label>
                    <asp:DropDownList ID="DDLpscore" runat="server" CssClass="typer-select">
                        <asp:ListItem>200</asp:ListItem>
                        <asp:ListItem Selected="True">100</asp:ListItem>
                        <asp:ListItem>300</asp:ListItem>
                        <asp:ListItem>400</asp:ListItem>
                        <asp:ListItem>500</asp:ListItem>
                    </asp:DropDownList>
                    <label>字/分 的成绩</label>
                    <asp:Button ID="ButtonClearThis" runat="server" Text="清除该速度成绩"
                        onclick="ButtonClearThis_Click" CssClass="typer-btn typer-btn-danger"
                        ToolTip="清除超过指定速度的中文打字成绩" />
                </div>
            </div>

            <div style="height:16px;"></div>

            <!-- 批量清除 -->
            <div class="typer-tip typer-tip-warn">
                <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                <div>以下操作将清除全班所有学生的打字成绩数据，此操作不可恢复，请确认后再点击。</div>
            </div>
            <div class="typer-toolbar">
                <div class="typer-toolbar-group">
                    <asp:Button ID="ButtonClearType" runat="server" Text="清除全部中文打字成绩"
                        onclick="ButtonClearType_Click" CssClass="typer-btn typer-btn-danger" />
                    <asp:Button ID="ButtonClearFinger" runat="server" Text="清除全部指法打字成绩"
                        onclick="ButtonClearFinger_Click" CssClass="typer-btn typer-btn-danger" />
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>

