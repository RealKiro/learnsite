<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_soft, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .soft-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .soft-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .soft-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .soft-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .soft-title .soft-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .soft-title .soft-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .soft-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .soft-header-actions { display: flex; gap: 10px; align-items: flex-start; padding-top: 4px; }

    .soft-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 36px; line-height: 1; white-space: nowrap;
    }
    .soft-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .soft-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .soft-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.3); color: #fff; }
    .soft-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .soft-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .soft-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .soft-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .soft-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .soft-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .soft-card-body { padding: 0; }

    /* 工具栏 */
    .soft-toolbar {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 16px 24px; background: #fafbfc; border-bottom: 1px solid #f1f5f9;
    }
    .soft-toolbar-group {
        display: flex; align-items: center; gap: 8px;
    }
    .soft-toolbar-group label { font-size: 13px; color: #64748b; font-weight: 500; white-space: nowrap; }
    .soft-toolbar-divider { width: 1px; height: 24px; background: #e2e8f0; }
    .soft-toolbar .soft-msg { font-size: 13px; color: #ef4444; }
    .soft-select {
        padding: 8px 16px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; cursor: pointer; font-family: inherit;
        min-width: 240px;
    }
    .soft-select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }

    /* 说明板块 */
    .soft-info-box {
        background: linear-gradient(135deg, #eef2ff, #f5f3ff);
        border: 1px solid #e0e7ff; border-radius: 12px;
        padding: 20px 24px; margin-bottom: 24px;
        display: flex; align-items: flex-start; gap: 14px;
    }
    .soft-info-icon {
        width: 40px; height: 40px; border-radius: 10px;
        background: linear-gradient(135deg,#6366f1,#818cf8);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .soft-info-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .soft-info-content h4 { font-size: 14px; font-weight: 600; color: #4338ca; margin: 0 0 8px; }
    .soft-info-content p { font-size: 13px; color: #6366f1; line-height: 1.7; margin: 0; }
    .soft-info-content ul {
        margin: 6px 0 0; padding-left: 16px;
        font-size: 13px; color: #6366f1; line-height: 1.8;
    }

    /* 链接样式 */
    .soft-link {
        display: inline-flex; align-items: center; gap: 4px;
        font-size: 13px; color: #6366f1; text-decoration: none; font-weight: 500;
        padding: 6px 12px; border-radius: 6px; transition: all .15s;
    }
    .soft-link:hover { background: #eef2ff; color: #4f46e5; }
    .soft-link svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 表格美化 */
    .soft-card-body table { width: 100%; border-collapse: collapse; }
    .soft-card-body table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 16px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .soft-card-body table td {
        padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
        transition: background .1s;
    }
    .soft-card-body table tr:hover td { background: #f8fafc; }
    .soft-card-body table tr:last-child td { border-bottom: none; }
    .soft-card-body table a { color: #6366f1; text-decoration: none; font-weight: 500; transition: color .15s; }
    .soft-card-body table a:hover { color: #4f46e5; text-decoration: underline; }
    .soft-card-body table input[type="checkbox"] { width: 16px; height: 16px; accent-color: #6366f1; cursor: default; }
    .soft-card-body table img { vertical-align: middle; cursor: pointer; opacity: .7; transition: opacity .15s; }
    .soft-card-body table img:hover { opacity: 1; }

    /* 分页 */
    .soft-pager {
        display: flex; align-items: center; justify-content: center; gap: 6px;
        padding: 14px 0; font-size: 13px; color: #64748b;
    }
    .soft-pager a {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 5px 12px; border-radius: 6px; background: #f1f5f9;
        color: #475569; text-decoration: none; font-weight: 500; font-size: 12px;
        transition: all .15s; border: 1px solid transparent;
    }
    .soft-pager a:hover { background: #e0e7ff; color: #4f46e5; border-color: #c7d2fe; }
    .soft-pager span { color: #94a3b8; }

    /* 统计入口卡片 */
    .soft-stats {
        display: flex; gap: 16px; margin-bottom: 24px;
    }
    .soft-stat-item {
        flex: 1; padding: 16px 20px; border-radius: 10px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: center; gap: 14px;
        box-shadow: 0 1px 3px rgba(0,0,0,.03); text-decoration: none;
        transition: all .18s; cursor: pointer;
    }
    .soft-stat-item:hover { border-color: #c7d2fe; box-shadow: 0 4px 12px rgba(99,102,241,.1); }
    .soft-stat-icon {
        width: 42px; height: 42px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .soft-stat-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .soft-stat-icon.purple { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .soft-stat-icon.blue { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .soft-stat-icon.green { background: linear-gradient(135deg,#10b981,#34d399); }
    .soft-stat-info { display: flex; flex-direction: column; }
    .soft-stat-label { font-size: 12px; color: #94a3b8; margin-bottom: 2px; }
    .soft-stat-value { font-size: 13px; font-weight: 600; color: #1e293b; }
</style>

<div class="soft-page">
    <!-- 页面标题 -->
    <div class="soft-header">
        <div class="soft-title-wrap">
            <div class="soft-title">
                <span class="soft-icon">
                    <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                </span>
                自学资源管理
            </div>
            <div class="soft-subtitle">管理自学资源的分类、添加、查看与评价，支持按分类筛选浏览</div>
        </div>
        <div class="soft-header-actions">
            <asp:HyperLink ID="Hlkadd" runat="server" CssClass="soft-btn soft-btn-primary" 
                NavigateUrl="~/teacher/softadd.aspx" Target="_self">＋ 资源添加</asp:HyperLink>
        </div>
    </div>

    <!-- 说明板块 -->
    <div class="soft-info-box">
        <div class="soft-info-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        </div>
        <div class="soft-info-content">
            <h4>使用说明</h4>
            <ul>
                <li>点击「资源添加」上传新的自学资源文件，支持多种格式</li>
                <li>通过「分类设置」管理资源分类目录，方便学生按类别浏览</li>
                <li>在资源列表中可以切换「发布/隐藏」状态，控制学生是否可见</li>
                <li>学分数值表示学生完成该资源学习后获得的学分奖励</li>
            </ul>
        </div>
    </div>

    <!-- 快捷入口 -->
    <div class="soft-stats">
        <asp:HyperLink ID="HlkaddStat" runat="server" NavigateUrl="~/teacher/softadd.aspx" CssClass="soft-stat-item">
            <div class="soft-stat-icon purple">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </div>
            <div class="soft-stat-info">
                <span class="soft-stat-label">添加资源</span>
                <span class="soft-stat-value">上传新的自学资源文件</span>
            </div>
        </asp:HyperLink>
        <asp:HyperLink ID="Hlkcategory" runat="server" NavigateUrl="~/teacher/softcategory.aspx" CssClass="soft-stat-item">
            <div class="soft-stat-icon blue">
                <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            </div>
            <div class="soft-stat-info">
                <span class="soft-stat-label">分类设置</span>
                <span class="soft-stat-value">管理资源分类目录</span>
            </div>
        </asp:HyperLink>
        <asp:HyperLink ID="Hlkcgscore" runat="server" NavigateUrl="~/teacher/softnomic.aspx" CssClass="soft-stat-item">
            <div class="soft-stat-icon green">
                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div class="soft-stat-info">
                <span class="soft-stat-label">自学评价</span>
                <span class="soft-stat-value">查看学生自学评分情况</span>
            </div>
        </asp:HyperLink>
    </div>

    <!-- 资源列表卡片 -->
    <div class="soft-card">
        <div class="soft-card-header">
            <div>
                <div class="soft-card-title">
                    <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    资源列表
                </div>
                <div class="soft-card-desc">按分类浏览和管理所有自学资源</div>
            </div>
        </div>
        <!-- 筛选工具栏 -->
        <div class="soft-toolbar">
            <div class="soft-toolbar-group">
                <label>资源分类：</label>
                <asp:DropDownList ID="ddlcategory" runat="server" AutoPostBack="True" 
                    onselectedindexchanged="ddlcategory_SelectedIndexChanged" CssClass="soft-select">
                </asp:DropDownList>
            </div>
            <div class="soft-toolbar-divider"></div>
            <asp:Label ID="Label1" runat="server" CssClass="soft-msg"></asp:Label>
        </div>
        <!-- 表格 -->
        <div class="soft-card-body">
            <asp:GridView ID="GVSource" runat="server" AllowPaging="True" 
                AutoGenerateColumns="False" CellPadding="5" 
                PageSize="20" SkinID="GridViewInfo" Width="100%"
                onpageindexchanging="GVSource_PageIndexChanging" 
                onrowdatabound="GVSource_RowDataBound" EnableModelValidation="True" 
                onrowcommand="GVSource_RowCommand">
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:BoundField DataField="Fclass" HeaderText="属性" />
                    <asp:HyperLinkField DataNavigateUrlFields="Fid" 
                        DataNavigateUrlFormatString="~/teacher/softview.aspx?fid={0}" 
                        DataTextField="Ftitle" HeaderText="标题" />
                    <asp:BoundField DataField="Ffiletype" HeaderText="格式" />
                    <asp:BoundField DataField="Fhit" HeaderText="次数" />
                    <asp:BoundField DataField="Fopen" HeaderText="学分" />
                    <asp:HyperLinkField DataNavigateUrlFields="Furl" HeaderText="下载" Text="点击" 
                        Target="_blank" />
                    <asp:CheckBoxField DataField="Fhide" HeaderText="隐藏" ReadOnly="True" />
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:ImageButton ID="ImageButton1" runat="server" CausesValidation="False" 
                                CommandArgument='<%# Eval("Fid") %>' CommandName="Change" 
                                ImageUrl="~/images/refresh.gif" Text="更新" ToolTip="发布：无或隐藏：√" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Fdate" HeaderText="日期" />
                    <asp:HyperLinkField DataNavigateUrlFields="Fid,Furl" 
                        DataNavigateUrlFormatString="~/teacher/softdel.aspx?fid={0}&amp;&amp;furl={1}" 
                        Text="删除" />
                </Columns>
                <pagertemplate>
                    <div class="soft-pager">
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

