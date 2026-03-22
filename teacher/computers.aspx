<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_computers, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cp-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .cp-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .cp-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .cp-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .cp-title .cp-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .cp-title .cp-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cp-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .cp-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .cp-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .cp-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .cp-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cp-card-body { padding: 0; }

    /* 工具栏 */
    .cp-toolbar {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 14px 24px; background: #fafbfc; border-bottom: 1px solid #f1f5f9;
    }
    .cp-toolbar-label { font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap; }
    .cp-toolbar-divider { width: 1px; height: 24px; background: #e2e8f0; }
    .cp-toolbar span label { font-size: 13px; color: #475569; cursor: pointer; }
    .cp-toolbar span input[type="radio"] { accent-color: #6366f1; }

    /* 表格美化 */
    .cp-card-body table { width: 100%; border-collapse: collapse; }
    .cp-card-body table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 16px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .cp-card-body table td {
        padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
    }
    .cp-card-body table tr:hover td { background: #f8fafc; }
    .cp-card-body table tr:last-child td { border-bottom: none; }
    .cp-card-body table a { color: #6366f1; text-decoration: none; font-weight: 500; }
    .cp-card-body table a:hover { color: #4f46e5; text-decoration: underline; }
    .cp-card-body table input[type="checkbox"] { width: 16px; height: 16px; accent-color: #6366f1; }
    .cp-card-body table img { vertical-align: middle; cursor: pointer; opacity: .7; transition: opacity .15s; }
    .cp-card-body table img:hover { opacity: 1; }

    /* 操作栏 */
    .cp-actions {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        padding: 16px 24px; border-top: 1px solid #f1f5f9; background: #fafbfc;
    }
    .cp-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 5px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .cp-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .cp-btn-danger { border-color: #fecaca; color: #991b1b; background: #fef2f2; }
    .cp-btn-danger:hover { background: #fee2e2; border-color: #fca5a5; }
    .cp-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.15);
    }
    .cp-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; color: #fff; }

    /* 设置区 */
    .cp-settings {
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        padding: 12px 24px; font-size: 13px; color: #475569;
    }
    .cp-settings span label { font-size: 13px; }

    /* 导入卡片 */
    .cp-import-body { padding: 24px; }
    .cp-import-row {
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 14px;
    }
    .cp-import-msg { font-size: 13px; color: #1d4ed8; margin-bottom: 10px; display: block; }
    .cp-sample-table { border-collapse: collapse; margin: 0 auto; }
    .cp-sample-table th, .cp-sample-table td {
        border: 1px solid #e2e8f0; padding: 8px 20px; font-size: 13px; text-align: center;
    }
    .cp-sample-table th { background: #f1f5f9; color: #475569; font-weight: 600; }
    .cp-sample-table td { color: #64748b; }

    .cp-tip {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 16px; border-radius: 8px;
        background: #eef2ff; border: 1px solid #e0e7ff; color: #4338ca;
        font-size: 12px; line-height: 1.5;
    }
    .cp-tip svg { width: 16px; height: 16px; stroke: #6366f1; fill: none; stroke-width: 2; flex-shrink: 0; }
</style>

<div class="cp-page">
    <!-- 页面标题 -->
    <div class="cp-header">
        <div class="cp-title-wrap">
            <div class="cp-title">
                <span class="cp-icon">
                    <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                </span>
                电脑管理
            </div>
            <div class="cp-subtitle">管理机房电脑的IP、主机名、绑定状态和学号分配</div>
        </div>
    </div>

    <!-- 电脑列表卡片 -->
    <div class="cp-card">
        <div class="cp-card-header">
            <div class="cp-card-title">
                <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                电脑列表
            </div>
        </div>
        <!-- 排序工具栏 -->
        <div class="cp-toolbar">
            <span class="cp-toolbar-label">排序方式：</span>
            <asp:RadioButtonList ID="Radiobtnorder" runat="server" AutoPostBack="True" 
                onselectedindexchanged="Radiobtnorder_SelectedIndexChanged" 
                RepeatDirection="Horizontal" RepeatLayout="Flow">
                <asp:ListItem Selected="True" Value="1">IP地址</asp:ListItem>
                <asp:ListItem Value="2">计算机名</asp:ListItem>
                <asp:ListItem Value="3">日期</asp:ListItem>
            </asp:RadioButtonList>
        </div>
        <!-- 表格 -->
        <div class="cp-card-body">
            <asp:GridView ID="GVComputer" runat="server" 
                AutoGenerateColumns="False" CellPadding="2" SkinID="GridViewInfo"
                PageSize="20" Width="100%" EnableModelValidation="True" 
                onrowcommand="GVComputer_RowCommand" 
                onrowdatabound="GVComputer_RowDataBound" DataKeyNames="Pid">
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:HyperLinkField DataNavigateUrlFields="Pip" 
                        DataNavigateUrlFormatString="ipstudent.aspx?qip={0}" DataTextField="Pip" 
                        HeaderText="IP地址" Target="_blank" />
                    <asp:TemplateField HeaderText="计算机名">
                        <ItemTemplate>
                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("Pmachine") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="电脑室">
                        <ItemTemplate>
                            <asp:Label ID="Label2" runat="server" Text='<%# Bind("Pm") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Pnum" HeaderText="分配学号" />
                    <asp:BoundField DataField="Pon" HeaderText="是否登录" Visible="False" />
                    <asp:CheckBoxField DataField="Plock" HeaderText="绑定状态" />
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:ImageButton ID="ImageButton1" runat="server" CausesValidation="false" 
                                CommandArgument='<%# Eval("Pid") %>' CommandName="Lock" 
                                ImageUrl="~/images/lock.png" Text="按钮" ToolTip="更新锁定状态" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Pdate" HeaderText="更新日期" />
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="false" 
                                CommandArgument='<%# Eval("Pid") %>' CommandName="Del" Text="删除" 
                                ToolTip="删除该条记录" ForeColor="#ef4444"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle HorizontalAlign="Left" />
            </asp:GridView>
        </div>
        <!-- 批量操作 -->
        <div class="cp-actions">
            <asp:Button ID="BtnDelAll" runat="server" onclick="BtnDelAll_Click" 
                CssClass="cp-btn cp-btn-danger" Text="全体删除" />
            <asp:Button ID="BtnUnlock" runat="server" onclick="BtnUnlock_Click" 
                CssClass="cp-btn" Text="全体解绑" />
            <asp:Button ID="BtnOnlock" runat="server" onclick="BtnOnlock_Click" 
                CssClass="cp-btn" Text="全体绑定" />
            <asp:Button ID="BtnAssign" runat="server" onclick="BtnAssign_Click" 
                CssClass="cp-btn" Text="自动分配" 
                ToolTip="培训时用，先获取所有学生机IP，然后点自动分配学号" Visible="False" />
            <asp:Button ID="BtnClear" runat="server" onclick="BtnClear_Click" 
                CssClass="cp-btn" Text="清除分配" 
                ToolTip="清除分配的学号" Visible="False" />
            <asp:Button ID="BtnRefresh" runat="server" onclick="BtnRefresh_Click" 
                CssClass="cp-btn cp-btn-primary" Text="刷 新" />
        </div>
        <!-- 设置 -->
        <div class="cp-settings">
            <asp:CheckBox ID="CheckBoxhostname" runat="server" AutoPostBack="True" 
                Font-Size="9pt" oncheckedchanged="CheckBoxhostname_CheckedChanged" 
                Text="自动获取主机名" ToolTip="同网段获取正常，如果跨网段请关闭并导入主机名和IP绑定表格" />
        </div>
    </div>

    <!-- 提示 -->
    <div class="cp-tip" style="margin-bottom: 20px;">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        解除绑定后，学生登录更新记录就会自动绑定
    </div>

    <!-- 导入主机名卡片 -->
    <div class="cp-card">
        <div class="cp-card-header">
            <div class="cp-card-title">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                手工导入主机名与IP对应表
            </div>
        </div>
        <div class="cp-import-body">
            <div class="cp-import-row">
                <asp:FileUpload ID="FuHostnameIp" runat="server" Font-Size="9pt" />
                <asp:Button ID="BtnImport" runat="server" onclick="BtnImport_Click" 
                    CssClass="cp-btn cp-btn-primary" Text="导入Excel" />
            </div>
            <asp:Label ID="Labelmsg" runat="server" ForeColor="#000099" CssClass="cp-import-msg"></asp:Label>
            <p style="font-size: 13px; color: #64748b; margin-bottom: 10px;">Excel 导入样式参考：</p>
            <table class="cp-sample-table">
                <tr><th>ip</th><th>hostname</th></tr>
                <tr><td>192.168.0.20</td><td>pc1</td></tr>
                <tr><td>192.168.0.21</td><td>pc2</td></tr>
            </table>
        </div>
    </div>
</div>
</asp:Content>

