<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_grouping, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== 分组管理 V3 ===== */
    .grouping-page { width: 100%; margin: 0 auto; }

    /* ---- 页面标题 ---- */
    .gp-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 24px; flex-wrap: wrap; gap: 14px;
    }
    .gp-title { display: flex; align-items: center; gap: 14px; }
    .gp-title .t-icon {
        width: 46px; height: 46px;
        background: linear-gradient(135deg, #6366f1 0%, #a78bfa 100%);
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 6px 16px rgba(99,102,241,0.28);
    }
    .gp-title .t-icon svg { width: 24px; height: 24px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gp-title .t-text { font-size: 22px; font-weight: 700; color: #0f172a; }
    .gp-title .t-sub { font-size: 13px; font-weight: 400; color: #94a3b8; margin-top: 2px; }

    /* ---- 排序切换 ---- */
    .sort-bar {
        display: inline-flex; align-items: center;
        background: #f1f5f9; border: 1px solid #e2e8f0;
        border-radius: 10px; padding: 3px; gap: 2px;
    }
    .sort-bar > span { display: inline-flex; align-items: center; gap: 2px; }
    .sort-bar input[type="radio"] { position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none; }
    .sort-bar label {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 7px 20px; border-radius: 8px;
        font-size: 13px; font-weight: 500; color: #64748b;
        cursor: pointer; transition: all 0.18s;
        white-space: nowrap; user-select: none;
    }
    .sort-bar label:hover { background: #e2e8f0; color: #334155; }
    .sort-bar input[type="radio"]:checked + label {
        background: #fff; color: #4f46e5; font-weight: 600;
        box-shadow: 0 1px 4px rgba(0,0,0,0.08);
    }

    /* ---- 卡片容器 ---- */
    .gp-card {
        background: #fff; border: 1px solid #e2e8f0;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 6px 24px rgba(0,0,0,0.02);
        padding: 24px 28px; margin-bottom: 22px;
    }
    .gp-card-head {
        display: flex; align-items: center; gap: 10px;
        margin-bottom: 4px;
    }
    .gp-card-head .ci {
        width: 34px; height: 34px; background: #eef2ff; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .gp-card-head .ci svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gp-card-head .ct { font-size: 16px; font-weight: 700; color: #0f172a; }
    .gp-card-desc { font-size: 13px; color: #94a3b8; margin-bottom: 18px; line-height: 1.5; }

    /* ---- 学生网格：横向条状卡片 ---- */
    .stu-grid { text-align: center; }
    .stu-grid table { margin: 0 auto; border-collapse: separate !important; border-spacing: 10px 12px !important; }
    .stu-grid td { padding: 6px 5px !important; }

    .stu-chip {
        display: flex; align-items: center; gap: 0;
        width: 160px; height: 48px;
        background: #f8fafc;
        border: 1.5px solid #e2e8f0;
        border-radius: 12px;
        overflow: hidden;
        transition: all 0.18s;
        cursor: default;
    }
    .stu-chip:hover {
        border-color: #818cf8;
        background: #eef2ff;
        box-shadow: 0 4px 16px rgba(99,102,241,0.15);
        transform: translateY(-2px);
    }
    .stu-chip .sc-ck {
        width: 36px; display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .stu-chip .sc-ck input[type="checkbox"],
    .stu-chip .sc-ck span input[type="checkbox"] {
        accent-color: #6366f1; width: 16px; height: 16px; cursor: pointer; margin: 0;
    }
    .stu-chip .sc-info {
        flex: 1; min-width: 0;
        display: flex; flex-direction: column; justify-content: center;
        padding: 4px 0; line-height: 1.25;
    }
    .stu-chip .sc-name {
        font-size: 14px; font-weight: 600; color: #1e293b;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .stu-chip .sc-num {
        font-size: 10px; color: #94a3b8; margin-top: 1px;
        font-family: 'Consolas','Courier New',monospace;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .stu-chip .sc-score {
        width: 38px; flex-shrink: 0;
        display: flex; align-items: center; justify-content: center;
        font-size: 13px; font-weight: 700; color: #6366f1;
        background: #eef2ff;
        height: 100%;
    }

    /* ---- 提示条 ---- */
    .gp-tip {
        display: flex; align-items: flex-start; gap: 10px;
        background: linear-gradient(135deg, #eff6ff, #f0f9ff);
        border: 1px solid #bfdbfe; border-radius: 10px;
        padding: 12px 16px; margin-bottom: 18px;
        font-size: 13px; color: #1e40af; line-height: 1.6;
    }
    .gp-tip .ti {
        width: 26px; height: 26px; background: #dbeafe; border-radius: 7px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .gp-tip .ti svg { width: 14px; height: 14px; stroke: #3b82f6; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gp-tip strong { font-weight: 600; color: #1d4ed8; }

    /* ---- GridView ---- */
    .gp-card .gv-groups { width: 100% !important; border-collapse: separate; border-spacing: 0; }
    .gp-card .gv-groups th {
        background: #f8fafc !important; color: #64748b;
        font-size: 12px; font-weight: 600; text-transform: uppercase;
        letter-spacing: 0.5px; padding: 14px 16px !important;
        border-bottom: 2px solid #e2e8f0 !important; text-align: left;
    }
    .gp-card .gv-groups th:first-child { border-radius: 10px 0 0 0; }
    .gp-card .gv-groups th:last-child { border-radius: 0 10px 0 0; }
    .gp-card .gv-groups td {
        padding: 14px 16px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        border-left: none !important; border-right: none !important; border-top: none !important;
        font-size: 13px; color: #334155; vertical-align: middle;
    }
    .gp-card .gv-groups tr { border: none !important; height: auto !important; transition: background 0.15s; }
    .gp-card .gv-groups tbody tr:hover td { background: #fafaff; }
    .gp-card .gv-groups tbody tr:last-child td { border-bottom: none !important; }

    .group-flag {
        display: inline-flex; align-items: center; justify-content: center;
        width: 24px; height: 24px; background: #fef3c7; border-radius: 7px;
        margin-right: 8px; vertical-align: middle;
    }
    .group-flag svg { width: 14px; height: 14px; stroke: #d97706; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .leader-badge {
        display: inline-flex; align-items: center; gap: 4px;
        background: #fff7ed; border: 1px solid #fed7aa;
        padding: 3px 10px; border-radius: 14px;
        font-size: 12px; font-weight: 600; color: #c2410c;
    }
    .leader-badge::before { content: '\2605'; font-size: 11px; color: #f59e0b; }

    .gp-card .gv-groups input[type="text"] {
        border: 1.5px solid #cbd5e1; border-radius: 8px;
        padding: 7px 12px; font-size: 13px; outline: none;
        transition: all 0.15s; width: 130px;
    }
    .gp-card .gv-groups input[type="text"]:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.12); }

    .gp-card .gv-groups input[type="image"] {
        width: 28px; height: 28px; padding: 5px; border-radius: 6px;
        transition: all 0.15s; vertical-align: middle; opacity: 0.65;
    }
    .gp-card .gv-groups input[type="image"]:hover { background: #eef2ff; opacity: 1; }

    .gp-card .gv-groups a { color: #6366f1; text-decoration: none; font-weight: 500; transition: all 0.12s; }
    .gp-card .gv-groups a:hover { color: #4338ca; }

    .gp-card .gv-groups .member-list-wrap { min-height: 28px; }
    .gp-card .gv-groups .member-list-wrap table { margin: 0; }
    .gp-card .gv-groups .member-list-wrap td { padding: 3px 4px !important; border: none !important; }
    .gp-card .gv-groups .member-list-wrap a {
        display: inline-flex; align-items: center;
        background: #eef2ff; color: #4f46e5;
        padding: 4px 12px; border-radius: 14px;
        font-size: 12px; font-weight: 500;
        transition: all 0.15s; text-decoration: none;
    }
    .gp-card .gv-groups .member-list-wrap a:hover { background: #e0e7ff; color: #4338ca; box-shadow: 0 1px 4px rgba(99,102,241,0.15); text-decoration: none; }

    .gp-card .gv-groups a[id*="LinkBtnAdd"] {
        display: inline-flex; align-items: center; gap: 4px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff !important; padding: 6px 18px; border-radius: 8px;
        font-size: 12px; font-weight: 600; text-decoration: none !important;
        transition: all 0.18s; box-shadow: 0 2px 6px rgba(99,102,241,0.2);
    }
    .gp-card .gv-groups a[id*="LinkBtnAdd"]:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1);
        box-shadow: 0 4px 14px rgba(99,102,241,0.3); transform: translateY(-1px);
    }

    /* 交替行 */
    .gp-card .gv-groups tr[style*="background-color"] td { background: #fafbfd !important; }

    /* ---- 底部操作 ---- */
    .gp-actions {
        display: flex; align-items: center; justify-content: center;
        gap: 20px; padding: 18px 0 4px;
        border-top: 1px solid #f1f5f9; margin-top: 12px; flex-wrap: wrap;
    }
    .gp-actions label, .gp-actions > span {
        display: inline-flex; align-items: center; gap: 7px;
        font-size: 13px; color: #475569; cursor: pointer;
    }
    .gp-actions input[type="checkbox"] { accent-color: #6366f1; width: 16px; height: 16px; }
    .gp-actions input[type="submit"], .gp-actions .btn-auto {
        background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff;
        border: none; padding: 10px 30px; border-radius: 10px;
        font-size: 14px; font-weight: 600; cursor: pointer;
        transition: all 0.2s; box-shadow: 0 2px 8px rgba(99,102,241,0.2);
    }
    .gp-actions input[type="submit"]:hover, .gp-actions .btn-auto:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1);
        box-shadow: 0 6px 20px rgba(99,102,241,0.3); transform: translateY(-1px);
    }
</style>

<div class="grouping-page">
    <!-- 页面头部 -->
    <div class="gp-header">
        <div class="gp-title">
            <span class="t-icon">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </span>
            <div>
                <div class="t-text"><asp:Label ID="labelclass" runat="server"></asp:Label>分组管理</div>
                <div class="t-sub">管理班级学生分组，支持手动分配与自动分组</div>
            </div>
        </div>
        <div class="sort-bar">
            <asp:RadioButtonList ID="RBsort" runat="server" AutoPostBack="True" 
                Font-Size="9pt" onselectedindexchanged="RBsort_SelectedIndexChanged" 
                RepeatDirection="Horizontal" RepeatLayout="Flow">
                <Items>
                <asp:ListItem Value="0" Selected="True">学分排序</asp:ListItem>
                <asp:ListItem Value="1">学号排序</asp:ListItem>
                </Items>
            </asp:RadioButtonList>
        </div>
    </div>

    <!-- 学生列表 -->
    <div class="gp-card">
        <div class="gp-card-head">
            <span class="ci"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
            <span class="ct">学生列表</span>
        </div>
        <div class="gp-card-desc">勾选学生后，在下方小组表中点击「+ 参加」将其加入对应小组。左侧复选框用于选择，右侧数字为当前学分。</div>
        <div class="stu-grid">
            <asp:DataList ID="DLclass" runat="server" RepeatColumns="7" 
                RepeatDirection="Horizontal" DataKeyField="Sid" CellPadding="5" CellSpacing="4" HorizontalAlign="Center">
                <ItemTemplate>
                    <div class="stu-chip">
                        <div class="sc-ck"><asp:CheckBox ID="SelectStu" runat="server"/></div>
                        <div class="sc-info">
                            <span class="sc-name"><asp:Label ID="LabelSname" runat="server" Text='<%# Eval("Sname") %>'></asp:Label></span>
                            <span class="sc-num"><asp:Label ID="LabelSnum" runat="server" Text='<%# Eval("Snum") %>'></asp:Label></span>
                        </div>
                        <div class="sc-score"><asp:Label ID="LabelSscore" runat="server" Text='<%# Eval("Sscore") %>'></asp:Label></div>
                        <asp:Label ID="LabelSid" runat="server" Text='<%# Eval("Sid") %>' Visible="false"></asp:Label>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- 小组管理 -->
    <div class="gp-card">
        <div class="gp-card-head">
            <span class="ci"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></span>
            <span class="ct">小组管理</span>
        </div>
        <div class="gp-tip">
            <span class="ti"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>
            <div><strong>操作说明：</strong>先在上方勾选学生，再点击对应小组的「+ 参加」将学生加入该组。点击组内成员姓名可退组。</div>
        </div>
        <asp:GridView ID="GVGroups" runat="server" AutoGenerateColumns="False" 
            CellPadding="3" EnableModelValidation="True" 
            GridLines="None" HorizontalAlign="Center" CssClass="gv-groups"
            onrowdatabound="GVGroups_RowDataBound" onrowcommand="GVGroups_RowCommand" 
            Width="100%" DataKeyNames="Sid" BorderColor="Transparent" BorderStyle="None" 
            BorderWidth="0" onrowcancelingedit="GVGroups_RowCancelingEdit" 
            onrowediting="GVGroups_RowEditing" onrowupdating="GVGroups_RowUpdating">
            <AlternatingRowStyle BackColor="#FAFBFD" />
            <Columns>
                <asp:TemplateField HeaderText="小组名称">
                    <ItemTemplate>
                        <span class="group-flag"><svg viewBox="0 0 24 24"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg></span>
                        <asp:Label ID="LabelSgtitle" runat="server" Text='<%# Bind("Sgtitle") %>'></asp:Label>
                    </ItemTemplate>                
                    <EditItemTemplate>
                         <asp:TextBox ID="TBoxSgtitle" runat="server" Text='<%# Bind("Sgtitle") %>'></asp:TextBox>
                    </EditItemTemplate>                
                    <ItemStyle Width="160px" HorizontalAlign="Left" />
                </asp:TemplateField>
                <asp:CommandField CancelImageUrl="~/images/c.gif" EditImageUrl="~/images/e.gif" 
                    ShowEditButton="True" UpdateImageUrl="~/images/u.gif" ButtonType="Image">
                <ItemStyle Width="60px" />
                </asp:CommandField>
                <asp:TemplateField HeaderText="组长">
                    <ItemTemplate>
                        <span class="leader-badge">
                            <asp:Label ID="LabelSname" runat="server" Text='<%# Bind("Sname") %>'></asp:Label>
                        </span>
                    </ItemTemplate>
                    <ItemStyle Width="90px" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="成员">
                    <ItemTemplate>
                    <div class="member-list-wrap">
                        <asp:DataList ID="DLgstu" runat="server" RepeatColumns="12" CellPadding="3" 
                            onitemcommand="DLgstu_ItemCommand">
                            <ItemTemplate>
                                <asp:LinkButton ID="Gstu" runat="server" CommandName="Q" CommandArgument='<%# Eval("Sid") %>' Text='<%# Eval("Sname") %>' ToolTip="点击退组"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:DataList>
                    </div>
                    </ItemTemplate>
                    <ItemStyle Width="460px"/>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="平均分">
                    <ItemTemplate>
                        <asp:Label ID="LabelSscores" runat="server"></asp:Label>
                    </ItemTemplate>
                    <ItemStyle Width="60px" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="操作" ShowHeader="False">
                    <ItemTemplate>
                        <asp:LinkButton ID="LinkBtnAdd" runat="server" CausesValidation="false" 
                            CommandName="A" CommandArgument='<%# Eval("Sid") %>' Text="+ 参加"></asp:LinkButton>
                    </ItemTemplate>
                    <ItemStyle Width="90px" HorizontalAlign="Center" />
                </asp:TemplateField>
            </Columns>
            <HeaderStyle BackColor="#F8FAFC" />
            <RowStyle BorderColor="Transparent" BorderStyle="None" BorderWidth="0" 
                Height="48px" />
        </asp:GridView>

        <!-- 底部操作 -->
        <div class="gp-actions">
            <asp:CheckBox ID="CkQuit" runat="server" Checked="True" Text="锁定成员退组" 
                ToolTip="默认选中锁定，无法退组；如果要退组请取消" />
            <asp:Button ID="Btnauto" runat="server" SkinID="BtnNormal" Text="自动分组"  
                ToolTip="根据小组限制人数自动分组，积分最高为组长，如果小组限制人数为0则自动默认为4人" onclick="Btnauto_Click" CssClass="btn-auto" />
        </div>
    </div>
</div>
</asp:Content>

