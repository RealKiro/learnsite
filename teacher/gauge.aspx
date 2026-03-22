<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_gauge, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .gauge-page { width: 98%; margin: 0 auto; padding: 0 20px; }

    /* 页面标题栏 */
    .gauge-page .page-title-bar {
        display: flex; align-items: center; margin-bottom: 20px;
    }
    .gauge-page .page-title-bar h2 {
        font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
        display: flex; align-items: center; gap: 10px;
    }
    .gauge-page .page-title-bar h2 .title-icon {
        width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .gauge-page .page-title-bar h2 .title-icon svg {
        width: 20px; height: 20px; stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* 说明面板 */
    .gauge-info-panel {
        background: linear-gradient(135deg, #eff6ff 0%, #f5f3ff 100%);
        border: 1px solid #c7d2fe; border-radius: 12px;
        padding: 20px 28px; margin-bottom: 20px;
        display: flex; gap: 16px; align-items: flex-start;
    }
    .gauge-info-panel .info-icon {
        width: 40px; height: 40px; min-width: 40px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .gauge-info-panel .info-icon svg {
        width: 20px; height: 20px; stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .gauge-info-panel .info-body h4 {
        font-size: 15px; font-weight: 700; color: #3730a3; margin: 0 0 8px 0;
    }
    .gauge-info-panel .info-body p {
        font-size: 13px; color: #4338ca; line-height: 1.7; margin: 0;
    }
    .gauge-info-panel .info-tips {
        display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px;
    }
    .gauge-info-panel .info-tips .tip-tag {
        display: inline-flex; align-items: center; gap: 4px;
        background: #fff; border: 1px solid #c7d2fe; border-radius: 6px;
        padding: 4px 10px; font-size: 12px; color: #4f46e5; font-weight: 500;
    }
    .gauge-info-panel .info-tips .tip-tag svg {
        width: 12px; height: 12px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* 主卡片 */
    .gauge-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
        overflow: hidden;
    }
    .gauge-card-head {
        display: flex; align-items: center; gap: 10px;
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
    }
    .gauge-card-head .card-icon {
        width: 32px; height: 32px; border-radius: 9px;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .gauge-card-head .card-icon svg {
        width: 17px; height: 17px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .gauge-card-head .card-title {
        font-size: 15px; font-weight: 600; color: #1e293b;
    }
    .gauge-card-body { padding: 20px 24px; }

    /* 表格美化 */
    .gauge-card-body table { border-collapse: collapse; width: 100%; }
    .gauge-card-body th {
        background: linear-gradient(135deg, #6366f1, #7c3aed) !important;
        color: #fff !important; font-weight: 600; font-size: 13px;
        padding: 11px 14px !important; border: none !important;
    }
    .gauge-card-body th:first-child { border-radius: 8px 0 0 0; }
    .gauge-card-body th:last-child { border-radius: 0 8px 0 0; }
    .gauge-card-body td {
        padding: 10px 14px !important; font-size: 13px; color: #334155;
        border-bottom: 1px solid #f1f5f9 !important;
        border-left: none !important; border-right: none !important;
    }
    .gauge-card-body tr:hover td { background: #f8fafc; }
    .gauge-card-body a {
        color: #6366f1; text-decoration: none; font-weight: 500;
        transition: color 0.15s;
    }
    .gauge-card-body a:hover { color: #4f46e5; text-decoration: underline; }

    /* 添加表单区 */
    .gauge-add-bar {
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        padding: 16px 24px; background: #f8fafc;
        border-top: 1px solid #f1f5f9;
    }
    .gauge-add-bar .form-label {
        font-size: 13px; font-weight: 500; color: #475569;
    }
    .gauge-add-bar select, .gauge-add-bar input[type="text"] {
        height: 36px; border-radius: 8px; border: 1px solid #d1d5db;
        font-size: 13px; padding: 0 12px; background: #fff;
        outline: none; transition: all 0.2s;
    }
    .gauge-add-bar select:hover, .gauge-add-bar input[type="text"]:hover {
        border-color: #a5b4fc;
    }
    .gauge-add-bar select:focus, .gauge-add-bar input[type="text"]:focus {
        border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .gauge-add-bar input[type="submit"], .gauge-add-bar .aspNetDisabled {
        height: 36px; padding: 0 20px; border-radius: 8px; border: none;
        background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff;
        font-size: 13px; font-weight: 600; cursor: pointer;
        transition: all 0.2s; box-shadow: 0 1px 3px rgba(99,102,241,0.3);
    }
    .gauge-add-bar input[type="submit"]:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1);
        box-shadow: 0 2px 8px rgba(99,102,241,0.4);
    }

    /* 注意事项 */
    .gauge-notes {
        margin-top: 20px; display: flex; flex-direction: column; gap: 10px;
    }
    .gauge-note-item {
        display: flex; align-items: flex-start; gap: 10px;
        background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px;
        padding: 12px 18px;
    }
    .gauge-note-item .note-icon {
        width: 28px; height: 28px; min-width: 28px;
        background: linear-gradient(135deg, #f59e0b, #fbbf24);
        border-radius: 7px; display: flex; align-items: center; justify-content: center;
    }
    .gauge-note-item .note-icon svg {
        width: 14px; height: 14px; stroke: #fff; fill: none;
        stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round;
    }
    .gauge-note-item .note-text {
        font-size: 13px; color: #92400e; line-height: 1.6; font-weight: 500;
        padding-top: 3px;
    }
</style>

<div class="gauge-page">
    <!-- 页面标题 -->
    <div class="page-title-bar">
        <h2>
            <span class="title-icon">
                <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            </span>
            量化评价标准
        </h2>
    </div>

    <!-- 功能说明 -->
    <div class="gauge-info-panel">
        <div class="info-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        </div>
        <div class="info-body">
            <h4>功能说明</h4>
            <p>本页面用于管理自定义量化评价标准（量规）。您可以为不同作品类型创建评价量规，每个量规包含若干评价维度和对应分值，在学生互评活动中使用。点击量规标题可编辑其评价维度与分值明细。</p>
            <div class="info-tips">
                <span class="tip-tag">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    创建评价量规
                </span>
                <span class="tip-tag">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    编辑评价维度
                </span>
                <span class="tip-tag">
                    <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    用于学生互评
                </span>
                <span class="tip-tag">
                    <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                    量化打分
                </span>
            </div>
        </div>
    </div>

    <!-- 量规列表卡片 -->
    <div class="gauge-card">
        <div class="gauge-card-head">
            <div class="card-icon">
                <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            </div>
            <span class="card-title">评价标准列表</span>
        </div>
        <div class="gauge-card-body">
            <asp:GridView ID="GVGauge" runat="server" SkinID="GridViewInfo"
                AutoGenerateColumns="False" DataKeyNames="Gid" Width="100%" CellPadding="5"
                Font-Size="9pt" onrowcommand="GVGauge_RowCommand"
                EnableModelValidation="True" onrowdatabound="GVGauge_RowDataBound">
                <Columns>
                    <asp:BoundField HeaderText="序号">
                        <HeaderStyle Width="50px" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Gtype" HeaderText="分类">
                        <HeaderStyle Width="60px" />
                    </asp:BoundField>
                    <asp:HyperLinkField DataNavigateUrlFields="Gid"
                        DataNavigateUrlFormatString="~/teacher/gaugeitem.aspx?gid={0}"
                        DataTextField="Gtitle" HeaderText="标题">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:HyperLinkField>
                    <asp:BoundField DataField="Gcount" HeaderText="使用">
                        <HeaderStyle Width="60px" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Gdate" HeaderText="日期">
                        <HeaderStyle Width="160px" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="操作">
                        <ItemTemplate>
                            <asp:LinkButton ID="BtnEdit" runat="server" CausesValidation="false"
                                CommandArgument='<%# Eval("Gid") %>' CommandName="Del" Text="删除"></asp:LinkButton>
                        </ItemTemplate>
                        <HeaderStyle Width="60px" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
        <div class="gauge-add-bar">
            <span class="form-label">作品类型：</span>
            <asp:DropDownList ID="DDLtype" runat="server" Font-Size="9pt" />
            <span class="form-label">量规标题：</span>
            <asp:TextBox ID="TextBoxGtitle" runat="server" SkinID="TextBoxNormal" Width="280px" />
            <asp:Button ID="Btnadd" runat="server" Text="添加量规" onclick="Btnadd_Click" SkinID="BtnNormal" />
        </div>
    </div>

    <!-- 注意事项 -->
    <div class="gauge-notes">
        <div class="gauge-note-item">
            <div class="note-icon">
                <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
            <span class="note-text">评价标准一旦被活动使用后，将无法删除，请慎重填写评价内容与分值。</span>
        </div>
        <div class="gauge-note-item">
            <div class="note-icon">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            </div>
            <span class="note-text">当活动中未指定互评评价标准时，系统将自动选取相应作品类型中的第一条评价标准。建议每种作品类型至少创建一条量规。</span>
        </div>
    </div>
</div>
</asp:Content>

