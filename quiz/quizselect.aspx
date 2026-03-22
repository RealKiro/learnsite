<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Quiz_quizselect, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .qs-wrapper {
        max-width: 1200px;
        margin: 0 auto;
        padding: 12px 16px 40px;
    }
    /* Header */
    .qs-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 2px solid #eef2ff;
    }
    .qs-header .qs-title {
        font-size: 22px;
        font-weight: 700;
        color: #1e293b;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .qs-header .qs-title-icon {
        width: 40px; height: 40px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(99,102,241,0.2);
    }
    .qs-header .qs-title-icon svg {
        width: 22px; height: 22px;
        stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .qs-header .qs-subtitle {
        font-size: 13px;
        color: #94a3b8;
        margin-top: 2px;
    }

    /* Card */
    .qs-card {
        background: #fff;
        border-radius: 16px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03), 0 4px 16px rgba(0,0,0,0.02);
        padding: 28px 36px;
        margin-bottom: 18px;
        transition: box-shadow 0.2s;
    }
    .qs-card:hover {
        box-shadow: 0 2px 6px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.03);
    }
    .qs-card-title {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 20px;
        padding-bottom: 12px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .qs-card-title .ct-icon {
        width: 28px; height: 28px;
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .qs-card-title .ct-icon svg {
        width: 16px; height: 16px;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        fill: none;
    }
    .ct-blue { background: #eef2ff; }
    .ct-blue svg { stroke: #6366f1; }
    .ct-green { background: #ecfdf5; }
    .ct-green svg { stroke: #10b981; }
    .ct-amber { background: #fffbeb; }
    .ct-amber svg { stroke: #f59e0b; }
    .ct-rose { background: #fff1f2; }
    .ct-rose svg { stroke: #f43f5e; }

    /* Grade Selector */
    .qs-grade-selector {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
    }
    .qs-grade-selector .qs-label {
        font-size: 13px;
        font-weight: 600;
        color: #64748b;
    }
    .qs-grade-selector select {
        padding: 7px 14px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 13px;
        color: #334155;
        background: #fff;
        outline: none;
        transition: border-color 0.2s, box-shadow 0.2s;
        cursor: pointer;
    }
    .qs-grade-selector select:focus {
        border-color: #818cf8;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .qs-grade-selector .qs-label-suffix {
        font-size: 13px;
        color: #94a3b8;
    }

    /* DataList Grid */
    .qs-grade-list {
        background: #f8fafc;
        border: 1px solid #f1f5f9;
        border-radius: 12px;
        padding: 12px;
    }
    .qs-grade-list table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 8px;
    }
    .qs-grade-list .typerset {
        background: #fff !important;
        border: 1px solid #e8ecf1;
        border-radius: 10px;
        padding: 10px 16px;
        height: auto;
        text-align: left;
        transition: all 0.15s;
        cursor: pointer;
    }
    .qs-grade-list .typerset:hover {
        border-color: #c7d2fe;
        background: #eef2ff !important;
        box-shadow: 0 2px 6px rgba(99,102,241,0.08);
    }
    .qs-grade-list input[type="checkbox"] {
        accent-color: #6366f1;
        width: 16px; height: 16px;
        cursor: pointer;
        vertical-align: middle;
    }
    .qs-grade-list label {
        font-size: 13px;
        color: #334155;
        cursor: pointer;
        vertical-align: middle;
        margin-left: 4px;
    }

    /* Switch Row */
    .qs-switch-row {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        align-items: center;
    }
    .qs-switch-item {
        display: flex;
        align-items: center;
        gap: 8px;
        background: #f8fafc;
        padding: 10px 18px;
        border-radius: 10px;
        border: 1px solid #f1f5f9;
        transition: all 0.15s;
    }
    .qs-switch-item:hover {
        border-color: #e2e8f0;
        background: #f1f5f9;
    }
    .qs-switch-item input[type="checkbox"] {
        accent-color: #6366f1;
        width: 16px; height: 16px;
        cursor: pointer;
    }
    .qs-switch-item label {
        font-size: 13px;
        font-weight: 500;
        color: #334155;
        cursor: pointer;
    }
    .qs-switch-hint {
        font-size: 11px;
        color: #94a3b8;
        margin-left: 2px;
    }

    /* Question Count */
    .qs-count-row {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        align-items: center;
    }
    .qs-count-item {
        display: flex;
        align-items: center;
        gap: 8px;
        background: #f8fafc;
        padding: 8px 16px;
        border-radius: 10px;
        border: 1px solid #f1f5f9;
        transition: all 0.15s;
    }
    .qs-count-item:hover {
        border-color: #e2e8f0;
        background: #f1f5f9;
    }
    .qs-count-item .qs-clabel {
        font-size: 13px;
        font-weight: 500;
        color: #475569;
        white-space: nowrap;
    }
    .qs-count-item select {
        padding: 6px 12px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 13px;
        color: #334155;
        background: #fff;
        outline: none;
        cursor: pointer;
        min-width: 70px;
        transition: border-color 0.2s, box-shadow 0.2s;
    }
    .qs-count-item select:focus {
        border-color: #818cf8;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .qs-count-item .qs-unit {
        font-size: 12px;
        color: #94a3b8;
    }

    /* Buttons */
    .qs-btn-row {
        display: flex;
        align-items: center;
        gap: 14px;
        margin-top: 28px;
        padding-top: 22px;
        border-top: 1px solid #f1f5f9;
    }
    .qs-btn-row input[type="submit"] {
        padding: 10px 32px !important;
        border: none !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        cursor: pointer;
        transition: all 0.2s;
        height: auto !important;
        width: auto !important;
        line-height: 1.5 !important;
        letter-spacing: 0.3px;
    }
    .qs-btn-primary input[type="submit"] {
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important;
        box-shadow: 0 2px 8px rgba(99,102,241,0.25);
    }
    .qs-btn-primary input[type="submit"]:hover {
        box-shadow: 0 6px 20px rgba(99,102,241,0.35);
        transform: translateY(-1px);
    }
    .qs-btn-primary input[type="submit"]:active {
        transform: translateY(0);
    }
    .qs-btn-secondary input[type="submit"] {
        background: #f1f5f9 !important;
        color: #475569 !important;
        border: 1px solid #e2e8f0 !important;
    }
    .qs-btn-secondary input[type="submit"]:hover {
        background: #e2e8f0 !important;
        color: #1e293b !important;
    }

    /* Message */
    .qs-msg { margin-top: 16px; font-size: 13px; }
    .qs-msg span {
        padding: 10px 18px;
        border-radius: 10px;
        display: inline-block;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .qs-wrapper { padding: 8px 8px 24px; }
        .qs-card { padding: 20px 18px; }
        .qs-switch-row, .qs-count-row { flex-direction: column; align-items: flex-start; }
    }
</style>

<div class="qs-wrapper">
    <!-- 页面标题 -->
    <div class="qs-header">
        <div>
            <div class="qs-title">
                <span class="qs-title-icon">
                    <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                </span>
                测验设置
            </div>
            <div class="qs-subtitle">配置年级测验参数，选择题库范围和试题数量</div>
        </div>
    </div>

    <!-- 年级选择 -->
    <div class="qs-card">
        <div class="qs-card-title">
            <span class="ct-icon ct-blue"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
            选择年级
        </div>
        <div class="qs-grade-selector">
            <span class="qs-label">年级</span>
            <asp:DropDownList ID="DDLgrade" runat="server" Font-Size="9pt" 
                EnableTheming="True" Font-Names="Arial" AutoPostBack="True" 
                onselectedindexchanged="DDLgrade_SelectedIndexChanged">
            </asp:DropDownList>
        </div>
        <div class="qs-grade-list">
            <asp:DataList ID="DataListGrade" runat="server" RepeatColumns="5" Width="100%" 
                    CellPadding="3" CellSpacing="3" 
                    onitemdatabound="DataListGrade_ItemDataBound">
                <ItemTemplate>
                    <div class="typerset">
                        <asp:CheckBox ID="ChkGrade" runat="server" 
                            Text='<%# Container.DataItem.ToString() %>' />
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- 测验开关 -->
    <div class="qs-card">
        <div class="qs-card-title">
            <span class="ct-icon ct-green"><svg viewBox="0 0 24 24"><path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/></svg></span>
            测验控制
        </div>
        <div class="qs-switch-row">
            <div class="qs-switch-item">
                <asp:CheckBox ID="Quizpower" runat="server" Text="测验开关" 
                    ToolTip="当前年级测验开关：选中表示启用测验，未选表示停用测验" Font-Size="9pt" />
                <span class="qs-switch-hint">启用/停用测验</span>
            </div>
            <div class="qs-switch-item">
                <asp:CheckBox ID="Quizanswer" runat="server" Text="参考答案" 
                    ToolTip="当前年级考后参考答案开关：选中表示显示，未选表示隐藏" Font-Size="9pt" />
                <span class="qs-switch-hint">考后显示答案</span>
            </div>
        </div>
    </div>

    <!-- 试题数量 -->
    <div class="qs-card">
        <div class="qs-card-title">
            <span class="ct-icon ct-amber"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
            试题数量
        </div>
        <div class="qs-count-row">
            <div class="qs-count-item">
                <span class="qs-clabel">单选题</span>
                <asp:DropDownList ID="DDLOnly" runat="server" Font-Size="9pt">
                    <asp:ListItem>5</asp:ListItem>
                    <asp:ListItem>8</asp:ListItem>
                    <asp:ListItem>10</asp:ListItem>
                    <asp:ListItem Value="12"></asp:ListItem>
                    <asp:ListItem>15</asp:ListItem>
                    <asp:ListItem>18</asp:ListItem>
                    <asp:ListItem>20</asp:ListItem>
                    <asp:ListItem>25</asp:ListItem>
                    <asp:ListItem>30</asp:ListItem>
                </asp:DropDownList>
                <span class="qs-unit">题</span>
            </div>
            <div class="qs-count-item">
                <span class="qs-clabel">多选题</span>
                <asp:DropDownList ID="DDLMore" runat="server" Font-Size="9pt">
                    <asp:ListItem>0</asp:ListItem>
                    <asp:ListItem>1</asp:ListItem>
                    <asp:ListItem>2</asp:ListItem>
                    <asp:ListItem>3</asp:ListItem>
                    <asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>5</asp:ListItem>
                    <asp:ListItem>10</asp:ListItem>
                    <asp:ListItem>15</asp:ListItem>
                    <asp:ListItem>20</asp:ListItem>
                    <asp:ListItem>25</asp:ListItem>
                    <asp:ListItem>30</asp:ListItem>
                </asp:DropDownList>
                <span class="qs-unit">题</span>
            </div>
            <div class="qs-count-item">
                <span class="qs-clabel">判断题</span>
                <asp:DropDownList ID="DDLJudge" runat="server" Font-Size="9pt">
                    <asp:ListItem>0</asp:ListItem>
                    <asp:ListItem>1</asp:ListItem>
                    <asp:ListItem>2</asp:ListItem>
                    <asp:ListItem>3</asp:ListItem>
                    <asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>5</asp:ListItem>
                    <asp:ListItem>8</asp:ListItem>
                    <asp:ListItem>10</asp:ListItem>
                    <asp:ListItem Value="12"></asp:ListItem>
                    <asp:ListItem>15</asp:ListItem>
                    <asp:ListItem>18</asp:ListItem>
                    <asp:ListItem>20</asp:ListItem>
                    <asp:ListItem>25</asp:ListItem>
                    <asp:ListItem>30</asp:ListItem>
                </asp:DropDownList>
                <span class="qs-unit">题</span>
            </div>
        </div>

        <!-- 操作按钮 -->
        <div class="qs-btn-row">
            <span class="qs-btn-primary">
                <asp:Button ID="BtnSelect" runat="server" Text="提交设置" onclick="BtnSelect_Click" 
                    SkinID="BtnNormal" />
            </span>
            <span class="qs-btn-secondary">
                <asp:Button ID="BtnReturn" runat="server" Text="返回列表" onclick="BtnReturn_Click" 
                    SkinID="BtnNormal" />
            </span>
        </div>
        <div class="qs-msg">
            <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
        </div>
    </div>
</div>
</asp:Content>

