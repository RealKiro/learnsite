<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Workshow_studentworks, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<!-- Flot 图表库（母版已加载 jQuery） -->
<script src="../js/flot/excanvas.min.js" type="text/javascript"></script>
<script src="../js/flot/jquery.flot.min.js" type="text/javascript"></script>

<style>
    /* ===== 页面容器 ===== */
    .sw-page-wrapper {
        max-width: 1800px;
        width: 100%;
        margin: 0 auto;
        padding: 0 8px;
    }

    /* ===== 页面标题区域 ===== */
    .sw-page-header {
        display: flex;
        align-items: center;
        gap: 18px;
        margin-bottom: 24px;
        padding: 20px 24px;
        background: #fff;
        border-radius: 16px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.02);
    }
    .sw-page-icon {
        width: 52px; height: 52px;
        background: linear-gradient(135deg, #6366f1, #a78bfa);
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 4px 14px rgba(99,102,241,0.25);
    }
    .sw-page-icon svg {
        width: 28px; height: 28px;
        stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .sw-page-title {
        font-size: 22px;
        font-weight: 700;
        color: #1e293b;
        line-height: 1.3;
    }
    .sw-page-subtitle {
        font-size: 13.5px;
        color: #94a3b8;
        margin-top: 4px;
    }

    /* ===== 图表卡片 ===== */
    .sw-chart-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.02);
        margin-bottom: 24px;
        overflow: hidden;
    }
    .sw-chart-card-header {
        padding: 16px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .sw-chart-card-header svg {
        width: 18px; height: 18px;
        stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }
    .sw-chart-card-title {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
    }
    .sw-chart-body {
        padding: 20px 24px;
    }
    /* Flot 图表容器 */
    .sw-chart-container {
        box-sizing: border-box;
        height: 200px;
        width: 100%;
        border: 1px solid #f1f5f9;
        border-radius: 10px;
        background: #fafbfc;
    }
    .sw-chart-container .demo-placeholder {
        width: 100%;
        height: 100%;
        font-size: 14px;
        line-height: 1.2em;
    }

    /* ===== 表格卡片 ===== */
    .sw-table-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.02);
        overflow: hidden;
        margin-bottom: 24px;
    }
    .sw-table-card-header {
        padding: 16px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .sw-table-card-title {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .sw-table-card-title svg {
        width: 18px; height: 18px;
        stroke: #64748b; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .sw-table-card-title .badge {
        background: #eef2ff;
        color: #4f46e5;
        font-size: 11px;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 12px;
        border: 1px solid #c7d2fe;
    }
    .sw-table-body {
        padding: 0;
        overflow-x: auto;
    }

    /* ===== GridView 表格美化 ===== */
    .sw-table-body table {
        width: 100%;
        border-collapse: collapse;
    }
    .sw-table-body th {
        background: #f8fafc;
        color: #64748b;
        font-size: 12.5px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 14px 18px;
        text-align: left;
        border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }
    .sw-table-body td {
        padding: 13px 18px;
        font-size: 14px;
        color: #334155;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }
    .sw-table-body tr:last-child td {
        border-bottom: none;
    }
    .sw-table-body tr {
        transition: background-color 0.12s;
    }
    .sw-table-body tr:hover td {
        background: #f8fafc;
    }
    .sw-table-body tr:nth-child(even) td {
        background: #fafbfd;
    }
    .sw-table-body tr:nth-child(even):hover td {
        background: #f1f5f9;
    }

    /* 链接按钮 */
    .sw-table-body a {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 12px;
        background: #eef2ff;
        color: #4f46e5;
        border: 1px solid #c7d2fe;
        border-radius: 6px;
        font-size: 12.5px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.18s;
    }
    .sw-table-body a:hover {
        background: #e0e7ff;
        box-shadow: 0 2px 8px rgba(79,70,229,0.12);
        transform: translateY(-1px);
    }

    /* 复选框列 */
    .sw-table-body input[type="checkbox"] {
        width: 16px; height: 16px;
        accent-color: #6366f1;
        cursor: default;
    }

    /* ===== 底部操作栏 ===== */
    .sw-footer-actions {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        padding: 16px 20px;
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    }
    .sw-footer-actions .btn-close-page {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 26px;
        background: #fff;
        color: #475569;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.18s;
    }
    .sw-footer-actions .btn-close-page:hover {
        background: #f8fafc;
        border-color: #cbd5e1;
        box-shadow: 0 3px 10px rgba(0,0,0,0.06);
        transform: translateY(-1px);
    }
    .sw-footer-hint {
        font-size: 12.5px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .sw-footer-hint svg {
        width: 15px; height: 15px;
        stroke: #94a3b8; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }
</style>

<div class="sw-page-wrapper">

    <!-- 页面标题 -->
    <div class="sw-page-header">
        <div class="sw-page-icon">
            <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
        </div>
        <div>
            <div class="sw-page-title">
                <asp:Label ID="LabelSname" runat="server" Font-Bold="True"></asp:Label> 的作品记录
            </div>
            <div class="sw-page-subtitle">查看该学生的所有课堂作品、学分及评价详情</div>
        </div>
    </div>

    <!-- 学分趋势图表 -->
    <div class="sw-chart-card">
        <div class="sw-chart-card-header">
            <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            <span class="sw-chart-card-title">学分趋势</span>
        </div>
        <div class="sw-chart-body">
            <div class="sw-chart-container">
                <div id="placeholder" class="demo-placeholder"></div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        $(function () {
            var scores = [<%=msg %>];
            $.plot("#placeholder", [scores], {
                series: {
                    lines: { show: true, lineWidth: 2, fill: true, fillColor: { colors: [{ opacity: 0.05 }, { opacity: 0.15 }] } },
                    points: { show: true, radius: 3 }
                },
                colors: ["#6366f1"],
                grid: {
                    borderWidth: 0,
                    hoverable: true,
                    backgroundColor: { colors: ["#fafbfc", "#fff"] }
                }
            });
        });
    </script>

    <!-- 作品列表表格 -->
    <div class="sw-table-card">
        <div class="sw-table-card-header">
            <div class="sw-table-card-title">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                作品列表 <span class="badge">详细记录</span>
            </div>
        </div>
        <div class="sw-table-body">
            <asp:GridView ID="GridViewworks" runat="server" Width="100%"
                AutoGenerateColumns="False" EnableModelValidation="True"
                CellPadding="0" GridLines="None" SkinID="GridViewInfo"
                OnRowDataBound="GridViewworks_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="Wgrade" HeaderText="年级" />
                    <asp:BoundField DataField="Wclass" HeaderText="班级" />
                    <asp:BoundField DataField="Wterm" HeaderText="学期" />
                    <asp:BoundField DataField="Ctitle" HeaderText="学案" />
                    <asp:BoundField DataField="Mtitle" HeaderText="活动" />
                    <asp:BoundField DataField="Wscore" HeaderText="学分" />
                    <asp:BoundField DataField="Wdscore" HeaderText="加分" />
                    <asp:BoundField DataField="Wvote" HeaderText="鲜花" />
                    <asp:TemplateField HeaderText="查看">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLinkWurl" runat="server" Target="_blank"
                                ToolTip='<%# Eval("Wurl") %>' Text="&#x1F4E5; 下载"></asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLinkView" runat="server" NavigateUrl="" Text="&#x1F441; 预览" Target="_blank"></asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="日期">
                        <ItemTemplate>
                            <asp:Label ID="LabelWdate" runat="server" Text='<%# Bind("Wdate") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:CheckBoxField DataField="Wcheck" HeaderText="评价" ReadOnly="True" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- 底部操作栏 -->
    <div class="sw-footer-actions">
        <asp:Button ID="Btnclose" runat="server" Text="关闭页面" CssClass="btn-close-page" />
        <div class="sw-footer-hint">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            学分数据仅供教学参考，点击下载或预览可查看具体作品
        </div>
    </div>

</div>

</asp:Content>
