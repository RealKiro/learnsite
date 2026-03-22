<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_sitelog, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .sl-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .sl-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .sl-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .sl-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .sl-title .sl-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#ef4444,#f87171);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .sl-title .sl-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sl-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .sl-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .sl-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .sl-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .sl-card-title svg { width: 18px; height: 18px; stroke: #ef4444; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sl-card-body { padding: 0; }

    .sl-msg { padding: 12px 24px; font-size: 13px; color: #ef4444; background: #fef2f2; border-bottom: 1px solid #fecaca; }
    .sl-msg:empty { display: none; }

    /* 表格美化 */
    .sl-card-body table { width: 100%; border-collapse: collapse; }
    .sl-card-body table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 16px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .sl-card-body table td {
        padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
        vertical-align: top;
    }
    .sl-card-body table tr:hover td { background: #fefce8; }
    .sl-card-body table tr:last-child td { border-bottom: none; }

    /* 异常内容样式 */
    .sl-card-body .note {
        text-align: left; padding: 6px 10px; margin: 0;
        color: #dc2626; font-size: 12px; line-height: 1.7;
        background: #fef2f2; border-radius: 6px; border: 1px solid #fecaca;
        word-break: break-all;
    }

    /* 底部提示 */
    .sl-tip {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 16px; border-radius: 8px;
        background: #fef2f2; border: 1px solid #fecaca; color: #991b1b;
        font-size: 12px; line-height: 1.5;
    }
    .sl-tip svg { width: 16px; height: 16px; stroke: #ef4444; fill: none; stroke-width: 2; flex-shrink: 0; }
</style>

<div class="sl-page">
    <!-- 页面标题 -->
    <div class="sl-header">
        <div class="sl-title-wrap">
            <div class="sl-title">
                <span class="sl-icon">
                    <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                </span>
                网站异常日志
            </div>
            <div class="sl-subtitle">查看网站运行过程中的异常信息记录，便于诊断和排查问题</div>
        </div>
    </div>

    <!-- 日志列表卡片 -->
    <div class="sl-card">
        <div class="sl-card-header">
            <div class="sl-card-title">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                异常记录列表
            </div>
            <asp:Label ID="Labelmsg" runat="server" CssClass="sl-msg"></asp:Label>
        </div>
        <div class="sl-card-body">
            <asp:GridView ID="GvLog" runat="server" AutoGenerateColumns="False" 
                EnableModelValidation="True" GridLines="None" Width="100%" 
                BorderWidth="0px">
                <Columns>
                    <asp:BoundField DataField="Fid">
                        <ItemStyle Width="50px" HorizontalAlign="Center" ForeColor="#94a3b8" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Fdate" HeaderText="日期">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle Width="150px" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="异常内容">
                        <ItemTemplate>
                            <div class="note">
                                <asp:Literal ID="Literalnote" runat="server" Text='<%# Bind("Fnote") %>'></asp:Literal>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle Height="30px" />
                <RowStyle />
            </asp:GridView>
        </div>
    </div>

    <!-- 底部提示 -->
    <div class="sl-tip">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        异常信息记录保存在网站 Log 目录中，建议定期查看并清理
    </div>
</div>
</asp:Content>
