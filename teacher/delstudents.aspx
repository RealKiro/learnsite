<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_delstudents, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== 页面卡片容器 ===== */
    .del-page-wrapper {
        max-width: 1800px;
        width: 100%;
        margin: 0 auto;
        padding: 0 8px;
    }

    /* ===== 页面标题区域 ===== */
    .del-page-header {
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
    .del-page-icon {
        width: 52px; height: 52px;
        background: linear-gradient(135deg, #fbbf24, #f59e0b);
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 4px 14px rgba(245,158,11,0.25);
    }
    .del-page-icon svg {
        width: 28px; height: 28px;
        stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .del-page-title {
        font-size: 22px;
        font-weight: 700;
        color: #1e293b;
        line-height: 1.3;
    }
    .del-page-subtitle {
        font-size: 13.5px;
        color: #78716c;
        margin-top: 4px;
    }

    /* ===== 提示/警告横幅统一布局 ===== */
    .del-banners-row {
        display: flex;
        gap: 16px;
        margin-bottom: 24px;
    }
    .del-banners-row > * {
        flex: 1;
        margin-bottom: 0;
    }

    /* ===== 提示信息横幅 ===== */
    .del-info-banner {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 16px 20px;
        margin-bottom: 24px;
        display: flex;
        align-items: flex-start;
        gap: 14px;
        transition: box-shadow 0.2s;
    }
    .del-info-banner:hover {
        box-shadow: 0 4px 16px rgba(59,130,246,0.08);
    }
    .del-info-banner-icon {
        width: 24px; height: 24px;
        flex-shrink: 0;
        margin-top: 1px;
    }
    .del-info-banner-icon svg {
        width: 24px; height: 24px;
        stroke: #3b82f6; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .del-info-banner-text {
        font-size: 13.5px;
        color: #1e40af;
        line-height: 1.8;
    }
    .del-info-banner-text strong {
        font-weight: 600;
    }

    /* ===== 警告横幅 ===== */
    .del-warn-banner {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 16px 20px;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        gap: 12px;
        transition: box-shadow 0.2s;
    }
    .del-warn-banner:hover {
        box-shadow: 0 4px 16px rgba(202,138,4,0.08);
    }
    .del-warn-banner svg {
        width: 22px; height: 22px;
        stroke: #ca8a04; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }
    .del-warn-banner-text {
        font-size: 13.5px;
        color: #854d0e;
        line-height: 1.6;
    }

    /* ===== 表格卡片 ===== */
    .del-table-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 6px 20px rgba(0,0,0,0.025);
        overflow: hidden;
        margin-bottom: 24px;
        transition: box-shadow 0.25s;
    }
    .del-table-card:hover {
        box-shadow: 0 2px 6px rgba(0,0,0,0.06), 0 8px 28px rgba(0,0,0,0.04);
    }
    .del-table-card-header {
        padding: 18px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: #fff;
    }
    .del-table-card-title {
        font-size: 15.5px;
        font-weight: 600;
        color: #334155;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .del-table-card-title .badge {
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #92400e;
        font-size: 11px;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 12px;
        letter-spacing: 0.3px;
        border: 1px solid #fcd34d;
    }
    .del-table-body {
        padding: 0;
        overflow-x: auto;
    }

    /* ===== GridView 表格美化 ===== */
    .del-table-body table {
        width: 100%;
        border-collapse: collapse;
    }
    .del-table-body th {
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
    .del-table-body td {
        padding: 13px 18px;
        font-size: 14px;
        color: #334155;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }
    .del-table-body tr:last-child td {
        border-bottom: none;
    }
    .del-table-body tr {
        transition: background-color 0.12s;
    }
    .del-table-body tr:hover td {
        background: #f8fafc;
    }
    /* 斑马纹 */
    .del-table-body tr:nth-child(even) td {
        background: #fafbfd;
    }
    .del-table-body tr:nth-child(even):hover td {
        background: #f1f5f9;
    }

    /* ===== 操作按钮美化 ===== */
    .del-table-body .btn-revive {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 6px 16px;
        background: linear-gradient(135deg, #ecfdf5, #d1fae5);
        color: #047857;
        border: 1px solid #a7f3d0;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.18s;
        margin-right: 8px;
    }
    .del-table-body .btn-revive:hover {
        background: linear-gradient(135deg, #d1fae5, #a7f3d0);
        box-shadow: 0 3px 10px rgba(4,120,87,0.15);
        transform: translateY(-1px);
    }
    .del-table-body .btn-del-perm {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 6px 16px;
        background: linear-gradient(135deg, #fef2f2, #fee2e2);
        color: #b91c1c;
        border: 1px solid #fecaca;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.18s;
    }
    .del-table-body .btn-del-perm:hover {
        background: linear-gradient(135deg, #fee2e2, #fecaca);
        box-shadow: 0 3px 10px rgba(185,28,28,0.15);
        transform: translateY(-1px);
    }

    /* ===== 空状态提示 ===== */
    .del-empty-state {
        text-align: center;
        padding: 56px 24px;
        color: #94a3b8;
    }
    .del-empty-state svg {
        width: 60px; height: 60px;
        stroke: #cbd5e1; fill: none;
        stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
        margin-bottom: 14px;
    }
    .del-empty-state p {
        font-size: 14.5px;
        margin: 0;
    }

    /* ===== 底部操作栏 ===== */
    .del-footer-actions {
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
    .del-footer-actions .btn-back {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 26px;
        background: linear-gradient(135deg, #f8fafc, #f1f5f9);
        color: #475569;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 500;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.18s;
    }
    .del-footer-actions .btn-back:hover {
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        border-color: #c7d2fe;
        color: #4f46e5;
        box-shadow: 0 3px 10px rgba(79,70,229,0.10);
        transform: translateY(-1px);
    }
    .del-footer-hint {
        font-size: 12.5px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .del-footer-hint svg {
        width: 15px; height: 15px;
        stroke: #94a3b8; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        flex-shrink: 0;
    }

    /* ===== 响应式：小屏横幅堆叠 ===== */
    @media (max-width: 900px) {
        .del-banners-row {
            flex-direction: column;
        }
    }
</style>

<div class="del-page-wrapper">

    <!-- 页面标题 -->
    <div class="del-page-header">
        <div class="del-page-icon">
            <svg viewBox="0 0 24 24"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
        </div>
        <div>
            <div class="del-page-title">
                <asp:Label ID="Labelgradeclass" runat="server"></asp:Label> 已删除的学生列表
            </div>
            <div class="del-page-subtitle">查看并管理已删除的学生记录，可恢复或永久移除</div>
        </div>
    </div>

    <!-- 操作说明 + 警告提示并排 -->
    <div class="del-banners-row">
        <div class="del-info-banner">
            <div class="del-info-banner-icon">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            </div>
            <div class="del-info-banner-text">
                <strong>操作指南：</strong><br />
                ✅ 点击 <strong>「恢复」</strong> 可将已删除的学生重新恢复到学生列表中，恢复后该学生的登录密码将重置为 <strong>12345</strong>。<br />
                ❌ 点击 <strong>「永久删除」</strong> 将彻底移除该学生的所有数据，此操作 <strong>不可撤销</strong>，请谨慎操作。
            </div>
        </div>
        <div class="del-warn-banner">
            <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <span class="del-warn-banner-text">温馨提示：永久删除操作不可恢复，建议优先使用「恢复」功能将学生找回。</span>
        </div>
    </div>

    <!-- 学生列表表格卡片 -->
    <div class="del-table-card">
        <div class="del-table-card-header">
            <div class="del-table-card-title">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                已删除学生 <span class="badge">回收站</span>
            </div>
        </div>
        <div class="del-table-body">
            <asp:GridView ID="GVStudent" runat="server" AutoGenerateColumns="False" 
                Width="100%" CellPadding="3" PageSize="24" SkinID="GridViewInfo"
                OnRowDataBound="GVStudent_RowDataBound" EnableModelValidation="True" 
                DataKeyNames="Did" onrowcommand="GVStudent_RowCommand">
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:BoundField DataField="Dnum" HeaderText="学号" />
                    <asp:BoundField DataField="Dname" HeaderText="姓名" />
                    <asp:BoundField DataField="Dyear" HeaderText="入学年度" />
                    <asp:BoundField DataField="Dgrade" HeaderText="年级" />
                    <asp:BoundField DataField="Dclass" HeaderText="班级" />
                    <asp:BoundField DataField="Dsex" HeaderText="性别" />
                    <asp:BoundField DataField="Dheadtheacher" HeaderText="班主任" />
                    <asp:BoundField DataField="Dparents" HeaderText="父母" />
                    <asp:BoundField DataField="Dphone" HeaderText="联系电话" />
                    <asp:TemplateField HeaderText="操作" ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="BtnRevive" runat="server" CausesValidation="false" 
                                CommandArgument='<%# Eval("Did") %>' CommandName="Revive" 
                                Text="&#x21A9; 恢复" CssClass="btn-revive"></asp:LinkButton>
                            <asp:LinkButton ID="LinkBtnDel" runat="server" CausesValidation="false" 
                                CommandArgument='<%# Eval("Did") %>' CommandName="Del" 
                                Text="&#x2716; 永久删除" CssClass="btn-del-perm"
                                OnClientClick="return confirm('⚠ 确定要永久删除该学生吗？此操作不可撤销！');"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>            
            </asp:GridView>
        </div>
    </div>

    <!-- 底部操作栏 -->
    <div class="del-footer-actions">
        <asp:LinkButton ID="LinkBtncancel" runat="server" OnClick="LinkBtncancel_Click" CssClass="btn-back">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;"><polyline points="15 18 9 12 15 6"/></svg>
            返回学生管理
        </asp:LinkButton>
        <div class="del-footer-hint">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            提示：恢复后的学生密码将被重置为 12345，请通知学生及时修改
        </div>
    </div>

</div>

</asp:Content>

