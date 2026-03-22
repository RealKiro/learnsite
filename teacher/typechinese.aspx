<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typechinese, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .tc-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .tc-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .tc-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .tc-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .tc-title .tc-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#f59e0b,#fbbf24);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .tc-title .tc-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tc-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .tc-header-actions { display: flex; gap: 10px; align-items: flex-start; padding-top: 4px; }

    .tc-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 36px; line-height: 1; white-space: nowrap;
    }
    .tc-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .tc-btn-primary {
        background: linear-gradient(135deg,#f59e0b,#fbbf24); color: #fff;
        border-color: #f59e0b; box-shadow: 0 2px 8px rgba(245,158,11,.2);
    }
    .tc-btn-primary:hover { background: linear-gradient(135deg,#d97706,#f59e0b); border-color: #d97706; box-shadow: 0 4px 12px rgba(245,158,11,.3); color: #fff; }
    .tc-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .tc-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .tc-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .tc-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .tc-card-title svg { width: 18px; height: 18px; stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tc-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .tc-card-body { padding: 0; }

    .tc-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; margin: 16px 24px; border-radius: 8px;
        background: #fffbeb; border: 1px solid #fef3c7; font-size: 13px; color: #92400e; line-height: 1.6;
    }
    .tc-tip svg { width: 18px; height: 18px; stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }

    /* 表格美化 */
    .tc-card-body table { width: 100%; border-collapse: collapse; }
    .tc-card-body table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 18px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .tc-card-body table td {
        padding: 12px 18px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155;
        transition: background .1s;
    }
    .tc-card-body table tr:hover td { background: #f8fafc; }
    .tc-card-body table tr:last-child td { border-bottom: none; }
    .tc-card-body table a {
        color: #6366f1; text-decoration: none; font-weight: 500; transition: all .15s;
        padding: 4px 10px; border-radius: 5px;
    }
    .tc-card-body table a:hover { color: #4f46e5; background: #eef2ff; }

    /* 分页美化 */
    .tc-pager {
        display: flex; align-items: center; justify-content: center; gap: 6px;
        padding: 14px 0; font-size: 13px; color: #64748b;
    }
    .tc-pager a {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 5px 12px; border-radius: 6px; background: #f1f5f9;
        color: #475569; text-decoration: none; font-weight: 500; font-size: 12px;
        transition: all .15s; border: 1px solid transparent;
    }
    .tc-pager a:hover { background: #fef3c7; color: #d97706; border-color: #fde68a; }
    .tc-pager span { color: #94a3b8; }

    /* 快捷入口 */
    .tc-stats {
        display: flex; gap: 16px; margin-bottom: 24px;
    }
    .tc-stat-item {
        flex: 1; padding: 18px 22px; border-radius: 10px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: center; gap: 14px;
        box-shadow: 0 1px 3px rgba(0,0,0,.03);
    }
    .tc-stat-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .tc-stat-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tc-stat-icon.amber { background: linear-gradient(135deg,#f59e0b,#fbbf24); }
    .tc-stat-icon.indigo { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .tc-stat-icon.emerald { background: linear-gradient(135deg,#10b981,#34d399); }
    .tc-stat-info { display: flex; flex-direction: column; }
    .tc-stat-label { font-size: 12px; color: #94a3b8; margin-bottom: 2px; }
    .tc-stat-value { font-size: 13px; font-weight: 600; color: #1e293b; }
</style>

<div class="tc-page">
    <!-- 页面标题 -->
    <div class="tc-header">
        <div class="tc-title-wrap">
            <div class="tc-title">
                <span class="tc-icon">
                    <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                </span>
                拼音词语打字管理
            </div>
            <div class="tc-subtitle">管理拼音词语打字练习的词语内容，支持添加、编辑、删除与查看详情</div>
        </div>
        <div class="tc-header-actions">
            <asp:Button ID="BtnTypeSet" runat="server" Text="⚙ 打字设置"
                onclick="BtnTypeSet_Click" CssClass="tc-btn" />
            <asp:Button ID="BtnAdd" runat="server" Text="＋ 词语添加"
                onclick="BtnAdd_Click" CssClass="tc-btn tc-btn-primary" />
        </div>
    </div>

    <!-- 快捷入口 -->
    <div class="tc-stats">
        <div class="tc-stat-item">
            <div class="tc-stat-icon amber">
                <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
            </div>
            <div class="tc-stat-info">
                <span class="tc-stat-label">词语管理</span>
                <span class="tc-stat-value">添加或编辑拼音词语练习文章</span>
            </div>
        </div>
        <div class="tc-stat-item">
            <div class="tc-stat-icon indigo">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
            </div>
            <div class="tc-stat-info">
                <span class="tc-stat-label">打字设置</span>
                <span class="tc-stat-value">配置各年级拼音打字练习文章</span>
            </div>
        </div>
        <div class="tc-stat-item">
            <div class="tc-stat-icon emerald">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            </div>
            <div class="tc-stat-info">
                <span class="tc-stat-label">词语内容</span>
                <span class="tc-stat-value">点击标题可查看词语详细内容</span>
            </div>
        </div>
    </div>

    <!-- 词语列表卡片 -->
    <div class="tc-card">
        <div class="tc-card-header">
            <div>
                <div class="tc-card-title">
                    <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                    词语列表
                </div>
                <div class="tc-card-desc">点击标题查看词语内容，点击编辑或删除进行管理操作</div>
            </div>
        </div>
        <div class="tc-tip">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            <div>拼音打字适合低年级学生，支持中文词语的拼音输入练习。点击「词语添加」可新建词语练习内容，点击「打字设置」可将词语分配给各年级。</div>
        </div>
        <div class="tc-card-body">
            <asp:GridView ID="GVType" runat="server" AllowPaging="True" 
                AutoGenerateColumns="False" CellPadding="5" SkinID="GridViewInfo"
                PageSize="20" Width="100%" onpageindexchanging="GVType_PageIndexChanging" 
                onrowdatabound="GVType_RowDataBound" EnableModelValidation="True">
                <Columns>
                    <asp:BoundField HeaderText="序号" >
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" Width="80px" />
                    </asp:BoundField>
                    <asp:HyperLinkField DataNavigateUrlFields="Nid" 
                        DataNavigateUrlFormatString="typechineseshow.aspx?nid={0}" DataTextField="Ntitle" 
                        HeaderText="词语标题">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:HyperLinkField>
                    <asp:HyperLinkField DataNavigateUrlFields="Nid" 
                        DataNavigateUrlFormatString="typechineseedit.aspx?nid={0}" Text="编辑">
                        <ControlStyle Width="50px" />
                        <ItemStyle Width="70px" />
                    </asp:HyperLinkField>
                    <asp:HyperLinkField DataNavigateUrlFields="Nid" 
                        DataNavigateUrlFormatString="typechinesedel.aspx?nid={0}" Text="删除" >
                        <ItemStyle Width="70px" />
                    </asp:HyperLinkField>
                </Columns>
                <pagertemplate>
                    <div class="tc-pager">
                        第<asp:Label ID="lblPageIndex" runat="server" 
                            text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1  %>" />
                        页 / 共<asp:Label ID="lblPageCount" runat="server" 
                            text="<%# ((GridView)Container.Parent.Parent).PageCount  %>" />
                        页
                        <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False" 
                            commandargument="First" commandname="Page" Font-Underline="False" 
                            ForeColor="Black" text="首页" />
                        <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False" 
                            commandargument="Prev" commandname="Page" Font-Underline="False" 
                            ForeColor="Black" text="上一页" />
                        <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False" 
                            commandargument="Next" commandname="Page" Font-Underline="False" 
                            ForeColor="Black" text="下一页" />
                        <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False" 
                            commandargument="Last" commandname="Page" Font-Underline="False" 
                            ForeColor="Black" text="尾页" />
                    </div>
                </pagertemplate>
            </asp:GridView>
        </div>
    </div>
</div>
</asp:Content>

