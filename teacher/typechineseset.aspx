<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typechineseset, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .tcs-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .tcs-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .tcs-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .tcs-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .tcs-title .tcs-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#f59e0b,#fbbf24);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .tcs-title .tcs-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tcs-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .tcs-back {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; height: 36px;
    }
    .tcs-back:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .tcs-back svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .tcs-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .tcs-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .tcs-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .tcs-card-title svg { width: 18px; height: 18px; stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tcs-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .tcs-card-body { padding: 20px 24px; }

    /* 年级选择栏 */
    .tcs-grade-bar {
        display: flex; align-items: center; gap: 12px; margin-bottom: 20px;
        padding: 14px 18px; background: #f8fafc; border-radius: 10px; border: 1px solid #f1f5f9;
    }
    .tcs-grade-bar label { font-size: 14px; font-weight: 600; color: #334155; white-space: nowrap; }
    .tcs-select {
        padding: 7px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; cursor: pointer; font-family: inherit;
    }
    .tcs-select:focus { border-color: #fbbf24; box-shadow: 0 0 0 3px rgba(245,158,11,.1); }
    .tcs-grade-hint { font-size: 12px; color: #94a3b8; }

    /* 复选框网格 */
    .tcs-card-body .typerset {
        height: auto !important; padding: 10px 14px; border-radius: 8px;
        background: #f8fafc; border: 1px solid #f1f5f9 !important;
        border-bottom-style: solid !important; border-right-style: solid !important;
        transition: all .15s; cursor: pointer;
    }
    .tcs-card-body .typerset:hover { background: #fffbeb; border-color: #fde68a !important; }
    .tcs-card-body .typerset input[type="checkbox"] {
        width: 16px; height: 16px; margin-right: 6px; accent-color: #f59e0b;
        vertical-align: middle; cursor: pointer;
    }
    .tcs-card-body .typerset label {
        font-size: 13px; color: #334155; cursor: pointer; vertical-align: middle;
    }
    .tcs-card-body table { width: 100%; border-collapse: separate; border-spacing: 6px; }
    .tcs-card-body table td { padding: 0; vertical-align: top; }

    /* 按钮 */
    .tcs-btn-actions {
        display: flex; gap: 10px; margin-top: 20px; padding-top: 20px;
        border-top: 1px solid #f1f5f9;
    }
    .tcs-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 24px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 38px; line-height: 1;
    }
    .tcs-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .tcs-btn-primary {
        background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff;
        border-color: #f59e0b; box-shadow: 0 2px 8px rgba(245,158,11,.18);
    }
    .tcs-btn-primary:hover { background: linear-gradient(135deg,#d97706,#f59e0b); border-color: #d97706; box-shadow: 0 4px 12px rgba(245,158,11,.28); color: #fff; }
    .tcs-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tcs-quick-btns { display: flex; gap: 8px; }
    .tcs-quick-btn {
        padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #64748b;
        cursor: pointer; transition: all .15s; font-family: inherit;
    }
    .tcs-quick-btn:hover { background: #fffbeb; border-color: #fde68a; color: #d97706; }

    /* 使用说明 */
    .tcs-guide { display: flex; gap: 20px; }
    .tcs-guide-item {
        flex: 1; padding: 18px 20px; border-radius: 10px; background: #f8fafc;
        border: 1px solid #f1f5f9;
    }
    .tcs-guide-step {
        display: inline-flex; align-items: center; justify-content: center;
        width: 28px; height: 28px; border-radius: 50%; font-size: 13px; font-weight: 700;
        margin-bottom: 10px;
    }
    .tcs-guide-step.s1 { background: #fffbeb; color: #f59e0b; }
    .tcs-guide-step.s2 { background: #ecfdf5; color: #10b981; }
    .tcs-guide-step.s3 { background: #eef2ff; color: #6366f1; }
    .tcs-guide-step.s4 { background: #fee2e2; color: #ef4444; }
    .tcs-guide-title { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 6px; }
    .tcs-guide-text { font-size: 13px; color: #64748b; line-height: 1.6; }

    .tcs-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px;
        background: #fffbeb; border: 1px solid #fef3c7; font-size: 13px; color: #92400e; line-height: 1.6;
    }
    .tcs-tip svg { width: 18px; height: 18px; stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }
</style>

<script type="text/javascript">
    function toggleAllChinese(checked) {
        var cbs = document.querySelectorAll('.tcs-card-body input[type="checkbox"]');
        for (var i = 0; i < cbs.length; i++) { cbs[i].checked = checked; }
    }
</script>

<div class="tcs-page">
    <!-- 页面标题 -->
    <div class="tcs-header">
        <div class="tcs-title-wrap">
            <div class="tcs-title">
                <span class="tcs-icon">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                </span>
                拼音词语分配设置
            </div>
            <div class="tcs-subtitle">为每个年级选择适合的拼音词语练习文章，勾选后点击提交即可生效</div>
        </div>
        <a href="typechinese.aspx" class="tcs-back">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回词语管理
        </a>
    </div>

    <!-- 使用说明卡片 -->
    <div class="tcs-card">
        <div class="tcs-card-header">
            <div>
                <div class="tcs-card-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    使用说明
                </div>
                <div class="tcs-card-desc">了解如何为不同年级分配拼音词语打字练习文章</div>
            </div>
        </div>
        <div class="tcs-card-body">
            <div class="tcs-guide">
                <div class="tcs-guide-item">
                    <div class="tcs-guide-step s1">1</div>
                    <div class="tcs-guide-title">选择年级</div>
                    <div class="tcs-guide-text">在下方卡片中选择要设置的年级，系统会自动加载该年级当前已分配的词语（已勾选状态）。</div>
                </div>
                <div class="tcs-guide-item">
                    <div class="tcs-guide-step s2">2</div>
                    <div class="tcs-guide-title">勾选词语</div>
                    <div class="tcs-guide-text">勾选希望该年级学生练习的词语。可以多选，也可取消勾选以移除某篇词语。</div>
                </div>
                <div class="tcs-guide-item">
                    <div class="tcs-guide-step s3">3</div>
                    <div class="tcs-guide-title">提交保存</div>
                    <div class="tcs-guide-text">点击「提交选择」按钮保存设置。保存后，该年级学生登录后就只能看到被选中的词语。</div>
                </div>
                <div class="tcs-guide-item">
                    <div class="tcs-guide-step s4">4</div>
                    <div class="tcs-guide-title">注意事项</div>
                    <div class="tcs-guide-text">每个年级的词语分配独立设置，互不影响。切换年级前请先提交当前更改。</div>
                </div>
            </div>
        </div>
    </div>

    <!-- 词语分配卡片 -->
    <div class="tcs-card">
        <div class="tcs-card-header">
            <div>
                <div class="tcs-card-title">
                    <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                    选择练习词语
                </div>
                <div class="tcs-card-desc">勾选该年级学生可以练习的拼音词语，已勾选表示当前已分配</div>
            </div>
            <div class="tcs-quick-btns">
                <button type="button" class="tcs-quick-btn" onclick="toggleAllChinese(true)">全选</button>
                <button type="button" class="tcs-quick-btn" onclick="toggleAllChinese(false)">全不选</button>
            </div>
        </div>
        <div class="tcs-card-body">
            <!-- 年级选择 -->
            <div class="tcs-grade-bar">
                <label>选择年级：</label>
                <asp:DropDownList ID="DDLgrade" runat="server" Font-Size="9pt" 
                    EnableTheming="True" Font-Names="Arial" AutoPostBack="True" 
                    onselectedindexchanged="DDLgrade_SelectedIndexChanged" CssClass="tcs-select">
                </asp:DropDownList>
                <span class="tcs-grade-hint">选择年级后自动加载该年级已分配的词语</span>
            </div>

            <!-- 词语列表 -->
            <asp:DataList ID="DataListTyper" runat="server" RepeatColumns="5" Width="100%" 
                CellPadding="3" CellSpacing="3" 
                onitemdatabound="DataListTyper_ItemDataBound">
                <ItemTemplate>
                    <div class="typerset">
                        <asp:CheckBox ID="ChkTyper" runat="server" 
                            Text='<%# Eval("Ntitle") %>' />
                        <asp:Label ID="Lbtid" runat="server" Text='<%# Eval("Nid") %>' Visible="False"></asp:Label>
                    </div>
                </ItemTemplate>
            </asp:DataList>

            <!-- 操作按钮 -->
            <div class="tcs-btn-actions">
                <asp:Button ID="BtnSelect" runat="server" Text="提交选择" onclick="BtnSelect_Click" 
                    CssClass="tcs-btn tcs-btn-primary" />
                <asp:Button ID="BtnReturn" runat="server" Text="返回" onclick="BtnReturn_Click" 
                    CssClass="tcs-btn" />
            </div>
        </div>
    </div>

    <asp:Label ID="LabelTids" runat="server" Visible="False"></asp:Label>
</div>
</asp:Content>

