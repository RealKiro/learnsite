<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_printtyper, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== 排行榜打印页面美化 ===== */
    .ptr-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    /* 页面标题 */
    .ptr-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .ptr-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .ptr-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .ptr-title .ptr-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#f59e0b,#fbbf24);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .ptr-title .ptr-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ptr-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .ptr-back {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 36px;
    }
    .ptr-back:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .ptr-back svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 卡片 */
    .ptr-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .ptr-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .ptr-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .ptr-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ptr-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .ptr-card-body { padding: 20px 24px; }

    /* 筛选栏 */
    .ptr-filters {
        display: flex; flex-wrap: wrap; align-items: center; gap: 16px;
    }
    .ptr-filter-group {
        display: flex; align-items: center; gap: 8px;
    }
    .ptr-filter-group label {
        font-size: 13px; color: #64748b; font-weight: 500; white-space: nowrap;
    }
    .ptr-select {
        padding: 7px 12px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff;
        outline: none; transition: border-color .15s; cursor: pointer;
        font-family: inherit; height: 36px;
    }
    .ptr-select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .ptr-filter-divider { width: 1px; height: 24px; background: #e2e8f0; }

    /* 按钮 */
    .ptr-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 36px; line-height: 1;
    }
    .ptr-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .ptr-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.18);
    }
    .ptr-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.28); color: #fff; }
    .ptr-btn-print {
        background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff;
        border-color: #f59e0b; box-shadow: 0 2px 8px rgba(245,158,11,.18);
    }
    .ptr-btn-print:hover { background: linear-gradient(135deg,#d97706,#f59e0b); border-color: #d97706; box-shadow: 0 4px 12px rgba(245,158,11,.28); color: #fff; }
    .ptr-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 提示信息 */
    .ptr-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;
        background: #eef2ff; border: 1px solid #e0e7ff; font-size: 13px; color: #4338ca; line-height: 1.6;
    }
    .ptr-tip svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }

    /* 结果展示区 */
    .ptr-result-area {
        min-height: 200px;
    }
    .ptr-empty {
        display: flex; flex-direction: column; align-items: center; justify-content: center;
        padding: 60px 20px; color: #94a3b8;
    }
    .ptr-empty svg { width: 48px; height: 48px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; margin-bottom: 12px; }
    .ptr-empty-text { font-size: 14px; color: #94a3b8; }

    /* DataList 卡片项 */
    .ptr-result-area table { width: 100%; }
    .ptr-result-area td { vertical-align: top; padding: 8px; }

    .ptr-rank-card {
        background: #fff; border: 1px solid #e8ecf1; border-radius: 12px;
        padding: 20px; text-align: center; transition: all .2s;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); width: 320px; margin: 6px auto;
    }
    .ptr-rank-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.08); transform: translateY(-2px); }

    .ptr-rank-avatar {
        width: 220px; height: 310px; border-radius: 10px; object-fit: cover;
        border: 3px solid #f1f5f9; margin-bottom: 14px;
    }

    .ptr-rank-info { margin-top: 8px; }
    .ptr-rank-name {
        font-size: 22px; font-weight: 700; color: #1e293b;
        font-family: '黑体','Microsoft YaHei',sans-serif;
    }
    .ptr-rank-meta {
        font-size: 13px; color: #94a3b8; margin-top: 4px;
    }
    .ptr-rank-score {
        display: inline-flex; align-items: baseline; gap: 4px;
        margin-top: 10px; padding: 6px 16px; border-radius: 20px;
        background: linear-gradient(135deg,#fef3c7,#fef9c3); border: 1px solid #fde68a;
    }
    .ptr-rank-score-num {
        font-size: 24px; font-weight: 800; color: #d97706;
        font-family: '黑体','Microsoft YaHei',sans-serif;
    }
    .ptr-rank-score-unit { font-size: 12px; color: #b45309; font-weight: 500; }

    /* ========== 打印样式 ========== */
    @media print {
        /* 隐藏母版页元素 */
        .sidebar, .top-header, .toggle-btn { display: none !important; }
        .layout-wrapper { display: block !important; }
        .main-area { display: block !important; overflow: visible !important; }
        .content-area { padding: 0 !important; overflow: visible !important; }
        html, body { overflow: visible !important; height: auto !important; }
        #form1 { height: auto !important; }

        /* 隐藏非打印区域 */
        .ptr-header, .ptr-filter-card, .ptr-tip, .no-print { display: none !important; }

        /* 打印卡片样式 */
        .ptr-card { border: none !important; box-shadow: none !important; }
        .ptr-card-header { display: none !important; }
        .ptr-card-body { padding: 0 !important; }
        .ptr-rank-card { box-shadow: none; border: 1px solid #ddd; break-inside: avoid; page-break-inside: avoid; }
        .ptr-rank-card:hover { transform: none; box-shadow: none; }
    }
</style>

<div class="ptr-page">
    <!-- 页面标题 -->
    <div class="ptr-header">
        <div class="ptr-title-wrap">
            <div class="ptr-title">
                <span class="ptr-icon">
                    <svg viewBox="0 0 24 24"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                </span>
                打字排行榜打印
            </div>
            <div class="ptr-subtitle">选择打字类型、年级和每班上榜人数，预览排行榜并打印奖状</div>
        </div>
        <a href="typer.aspx" class="ptr-back">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回打字管理
        </a>
    </div>

    <!-- 筛选条件卡片 -->
    <div class="ptr-card ptr-filter-card">
        <div class="ptr-card-header">
            <div>
                <div class="ptr-card-title">
                    <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
                    筛选条件
                </div>
                <div class="ptr-card-desc">选择打字类型、年级和每班上榜人数，点击「预览排行榜」查看结果</div>
            </div>
        </div>
        <div class="ptr-card-body">
            <div class="ptr-filters">
                <div class="ptr-filter-group">
                    <label>打字类型</label>
                    <asp:DropDownList ID="DDLtype" runat="server" CssClass="ptr-select" ToolTip="打字选择">
                        <asp:ListItem Selected="True" Value="0">中文打字</asp:ListItem>
                        <asp:ListItem Value="1">英文指法</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="ptr-filter-divider"></div>
                <div class="ptr-filter-group">
                    <label>年级选择</label>
                    <asp:DropDownList ID="DDLgrade" runat="server" CssClass="ptr-select" ToolTip="年级选择">
                    </asp:DropDownList>
                </div>
                <div class="ptr-filter-divider"></div>
                <div class="ptr-filter-group">
                    <label>每班上榜人数</label>
                    <asp:DropDownList ID="DDLtop" runat="server" CssClass="ptr-select" ToolTip="人数选择">
                        <asp:ListItem>1</asp:ListItem>
                        <asp:ListItem>2</asp:ListItem>
                        <asp:ListItem>3</asp:ListItem>
                        <asp:ListItem>4</asp:ListItem>
                        <asp:ListItem>5</asp:ListItem>
                        <asp:ListItem>6</asp:ListItem>
                        <asp:ListItem Selected="True">7</asp:ListItem>
                        <asp:ListItem>8</asp:ListItem>
                        <asp:ListItem>9</asp:ListItem>
                        <asp:ListItem>10</asp:ListItem>
                        <asp:ListItem>11</asp:ListItem>
                        <asp:ListItem>12</asp:ListItem>
                        <asp:ListItem>13</asp:ListItem>
                        <asp:ListItem>14</asp:ListItem>
                        <asp:ListItem>15</asp:ListItem>
                        <asp:ListItem>16</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="ptr-filter-divider"></div>
                <div class="ptr-filter-group">
                    <asp:Button ID="Btnbrowse" runat="server" Text="预览排行榜"
                        onclick="Btnbrowse_Click" CssClass="ptr-btn ptr-btn-primary" />
                    <input type="button" value="🖨 打印排行榜" class="ptr-btn ptr-btn-print" onclick="doPrint()" />
                </div>
            </div>
        </div>
    </div>

    <!-- 操作提示 -->
    <div class="ptr-tip no-print">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <div>使用步骤：① 选择打字类型（中文/英文指法）→ ② 选择年级 → ③ 设置每班上榜人数 → ④ 点击「预览排行榜」查看结果 → ⑤ 点击「打印排行榜」打印奖状。每张奖状包含学生头像、姓名、班级和打字速度。</div>
    </div>

    <!-- 排行榜结果卡片 -->
    <div class="ptr-card">
        <div class="ptr-card-header no-print">
            <div>
                <div class="ptr-card-title">
                    <svg viewBox="0 0 24 24"><path d="M12 15l-2 5l9-11h-5l2-5L7 15z"/></svg>
                    排行榜预览
                </div>
                <div class="ptr-card-desc">以下是根据筛选条件生成的打字排行榜奖状预览</div>
            </div>
        </div>
        <div class="ptr-card-body">
            <div class="ptr-result-area">
                <!--startprint-->
                <asp:DataList ID="DataList_A4" runat="server" RepeatColumns="2"
                    RepeatDirection="Horizontal" HorizontalAlign="Center"
                    onitemdatabound="DataList_A4_ItemDataBound">
                    <ItemTemplate>
                        <div class="ptr-rank-card">
                            <asp:Image ID="Image1" runat="server" CssClass="ptr-rank-avatar" Height="300px" Width="210px" />
                            <div class="ptr-rank-info">
                                <div class="ptr-rank-name">
                                    <asp:Label ID="sname" runat="server" Text='<%# Eval("Sname") %>'></asp:Label>
                                </div>
                                <asp:Label ID="psnum" runat="server" Text='<%# Eval("Psnum") %>' Visible="false"></asp:Label>
                                <div class="ptr-rank-meta">
                                    <asp:Label ID="sgrade" runat="server" Text='<%# Eval("Sgrade") %>'></asp:Label>年级
                                    <asp:Label ID="sclass" runat="server" Text='<%# Eval("Sclass") %>'></asp:Label>班
                                </div>
                                <div class="ptr-rank-score">
                                    <span class="ptr-rank-score-num">
                                        <asp:Label ID="ps" runat="server" Text='<%# Eval("Pscore") %>'></asp:Label>
                                    </span>
                                    <span class="ptr-rank-score-unit">字/分钟</span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
                <!--endprint-->
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function doPrint() {
        window.print();
    }
</script>
</asp:Content>
