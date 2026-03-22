<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typerset, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ts-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    /* 页面标题 */
    .ts-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .ts-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .ts-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .ts-title .ts-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .ts-title .ts-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ts-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .ts-back {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; height: 36px;
    }
    .ts-back:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .ts-back svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 卡片 */
    .ts-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .ts-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .ts-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .ts-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ts-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .ts-card-body { padding: 20px 24px; }

    /* 年级选择栏 */
    .ts-grade-bar {
        display: flex; align-items: center; gap: 12px; margin-bottom: 20px;
        padding: 14px 18px; background: #f8fafc; border-radius: 10px; border: 1px solid #f1f5f9;
    }
    .ts-grade-bar label { font-size: 14px; font-weight: 600; color: #334155; white-space: nowrap; }
    .ts-select {
        padding: 7px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; cursor: pointer; font-family: inherit;
    }
    .ts-select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .ts-grade-hint { font-size: 12px; color: #94a3b8; }

    /* 文章复选框网格 */
    .ts-card-body .typerset {
        height: auto !important; padding: 10px 14px; border-radius: 8px;
        background: #f8fafc; border: 1px solid #f1f5f9 !important;
        border-bottom-style: solid !important; border-right-style: solid !important;
        transition: all .15s; cursor: pointer;
    }
    .ts-card-body .typerset:hover { background: #eef2ff; border-color: #c7d2fe !important; }
    .ts-card-body .typerset input[type="checkbox"] {
        width: 16px; height: 16px; margin-right: 6px; accent-color: #6366f1;
        vertical-align: middle; cursor: pointer;
    }
    .ts-card-body .typerset label {
        font-size: 13px; color: #334155; cursor: pointer; vertical-align: middle;
    }

    /* DataList 表格美化 */
    .ts-card-body table { width: 100%; border-collapse: separate; border-spacing: 6px; }
    .ts-card-body table td { padding: 0; vertical-align: top; }

    /* 按钮 */
    .ts-btn-actions {
        display: flex; gap: 10px; margin-top: 20px; padding-top: 20px;
        border-top: 1px solid #f1f5f9;
    }
    .ts-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 24px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 38px; line-height: 1;
    }
    .ts-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .ts-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.18);
    }
    .ts-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.28); color: #fff; }
    .ts-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ts-quick-btns { display: flex; gap: 8px; }
    .ts-quick-btn {
        padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #64748b;
        cursor: pointer; transition: all .15s; font-family: inherit;
    }
    .ts-quick-btn:hover { background: #eef2ff; border-color: #c7d2fe; color: #4f46e5; }

    /* 使用说明 */
    .ts-guide { display: flex; gap: 20px; }
    .ts-guide-item {
        flex: 1; padding: 18px 20px; border-radius: 10px; background: #f8fafc;
        border: 1px solid #f1f5f9;
    }
    .ts-guide-step {
        display: inline-flex; align-items: center; justify-content: center;
        width: 28px; height: 28px; border-radius: 50%; font-size: 13px; font-weight: 700;
        margin-bottom: 10px;
    }
    .ts-guide-step.s1 { background: #eef2ff; color: #6366f1; }
    .ts-guide-step.s2 { background: #ecfdf5; color: #10b981; }
    .ts-guide-step.s3 { background: #fef3c7; color: #f59e0b; }
    .ts-guide-step.s4 { background: #fee2e2; color: #ef4444; }
    .ts-guide-title { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 6px; }
    .ts-guide-text { font-size: 13px; color: #64748b; line-height: 1.6; }

    .ts-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px;
        background: #eef2ff; border: 1px solid #e0e7ff; font-size: 13px; color: #4338ca; line-height: 1.6;
    }
    .ts-tip svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }
</style>

<div class="ts-page">
    <!-- 页面标题 -->
    <div class="ts-header">
        <div class="ts-title-wrap">
            <div class="ts-title">
                <span class="ts-icon">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                </span>
                打字文章分配设置
            </div>
            <div class="ts-subtitle">为每个年级选择适合的中文打字练习文章，勾选后点击提交即可生效</div>
        </div>
        <a href="typer.aspx" class="ts-back">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回打字管理
        </a>
    </div>

    <!-- 使用说明卡片 -->
    <div class="ts-card">
        <div class="ts-card-header">
            <div>
                <div class="ts-card-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    使用说明
                </div>
                <div class="ts-card-desc">了解如何为不同年级分配打字练习文章</div>
            </div>
        </div>
        <div class="ts-card-body">
            <div class="ts-guide">
                <div class="ts-guide-item">
                    <div class="ts-guide-step s1">1</div>
                    <div class="ts-guide-title">选择年级</div>
                    <div class="ts-guide-text">在下方卡片中选择要设置的年级，系统会自动加载该年级当前已分配的文章（已勾选状态）。</div>
                </div>
                <div class="ts-guide-item">
                    <div class="ts-guide-step s2">2</div>
                    <div class="ts-guide-title">勾选文章</div>
                    <div class="ts-guide-text">勾选希望该年级学生练习的文章。可以多选，也可以取消勾选以移除某篇文章。</div>
                </div>
                <div class="ts-guide-item">
                    <div class="ts-guide-step s3">3</div>
                    <div class="ts-guide-title">提交保存</div>
                    <div class="ts-guide-text">点击「提交选择」按钮保存设置。保存后，该年级学生登录后就只能看到被选中的文章。</div>
                </div>
                <div class="ts-guide-item">
                    <div class="ts-guide-step s4">4</div>
                    <div class="ts-guide-title">注意事项</div>
                    <div class="ts-guide-text">每个年级的文章分配独立设置，互不影响。切换年级前请先提交当前更改。</div>
                </div>
            </div>
        </div>
    </div>

    <!-- 文章分配卡片 -->
    <div class="ts-card">
        <div class="ts-card-header">
            <div>
                <div class="ts-card-title">
                    <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                    选择练习文章
                </div>
                <div class="ts-card-desc">勾选该年级学生可以练习的打字文章，已勾选表示当前已分配</div>
            </div>
            <div class="ts-quick-btns">
                <button type="button" class="ts-quick-btn" onclick="toggleAll(true)">全选</button>
                <button type="button" class="ts-quick-btn" onclick="toggleAll(false)">全不选</button>
            </div>
        </div>
        <div class="ts-card-body">
            <!-- 年级选择 -->
            <div class="ts-grade-bar">
                <label>当前年级</label>
                <asp:DropDownList ID="DDLgrade" runat="server" CssClass="ts-select"
                    EnableTheming="True" AutoPostBack="True"
                    onselectedindexchanged="DDLgrade_SelectedIndexChanged">
                </asp:DropDownList>
                <span class="ts-grade-hint">切换年级会自动加载该年级的文章分配情况</span>
            </div>

            <!-- 文章列表 -->
            <asp:DataList ID="DataListTyper" runat="server" RepeatColumns="4" Width="100%"
                CellPadding="3" CellSpacing="3"
                onitemdatabound="DataListTyper_ItemDataBound">
                <ItemTemplate>
                    <div class="typerset">
                        <asp:CheckBox ID="ChkTyper" runat="server"
                            Text='<%# Eval("Ttitle") %>' />
                        <asp:Label ID="Lbtid" runat="server" Text='<%# Eval("Tid") %>' Visible="False"></asp:Label>
                    </div>
                </ItemTemplate>
            </asp:DataList>

            <asp:Label ID="LabelTids" runat="server" Visible="False"></asp:Label>

            <!-- 操作按钮 -->
            <div class="ts-btn-actions">
                <asp:Button ID="BtnSelect" runat="server" Text="提交选择" onclick="BtnSelect_Click"
                    CssClass="ts-btn ts-btn-primary" />
                <asp:Button ID="BtnReturn" runat="server" Text="返回打字管理" onclick="BtnReturn_Click"
                    CssClass="ts-btn" />
            </div>
        </div>
    </div>

    <!-- 常见问题卡片 -->
    <div class="ts-card">
        <div class="ts-card-header">
            <div>
                <div class="ts-card-title">
                    <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    常见问题
                </div>
            </div>
        </div>
        <div class="ts-card-body">
            <div class="ts-tip" style="margin-bottom:12px;">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div><strong>问：学生看不到文章怎么办？</strong><br/>请检查是否已为对应年级分配了文章。切换到该年级，确保至少勾选了一篇文章并点击「提交选择」。</div>
            </div>
            <div class="ts-tip" style="margin-bottom:12px;">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div><strong>问：可以给不同年级分配不同文章吗？</strong><br/>可以。每个年级的文章分配是独立的，可以根据学生水平为不同年级选择难度适当的文章。</div>
            </div>
            <div class="ts-tip">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div><strong>问：切换年级后未提交的更改会保存吗？</strong><br/>不会。切换年级会重新加载该年级的设置，之前未提交的勾选更改会丢失。请先点击「提交选择」再切换年级。</div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function toggleAll(checked) {
        var cbs = document.querySelectorAll('.typerset input[type="checkbox"]');
        for (var i = 0; i < cbs.length; i++) cbs[i].checked = checked;
    }
</script>
</asp:Content>

