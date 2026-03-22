<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" validaterequest="false" autoeventwireup="true" inherits="Student_topicdiscuss, LearnSite" %>

<%@ Register Assembly="Anthem" Namespace="Anthem" TagPrefix="anthem" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* ===== 讨论页面 - 三列布局 ===== */
    .td-layout {
        display: flex;
        gap: 20px;
        max-width: 1800px;
        margin: 0 auto;
        padding: 0 16px 40px;
        min-height: calc(100vh - 200px);
    }
    
    /* 左侧导航栏 */
    .td-left-sidebar {
        width: 320px;
        flex-shrink: 0;
    }
    
    .td-left-sticky {
        position: sticky;
        top: 80px;
        max-height: calc(100vh - 100px);
        overflow-y: auto;
    }
    
    /* 右侧边栏 */
    .td-right-sidebar {
        width: 300px;
        flex-shrink: 0;
    }
    
    .td-right-sticky {
        position: sticky;
        top: 80px;
        max-height: calc(100vh - 100px);
        overflow-y: auto;
    }
    
    /* ===== 右侧边栏卡片样式 ===== */
    .td-images-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 20px;
        margin-bottom: 20px;
    }
    
    .td-images-title {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .td-images-title svg {
        width: 18px;
        height: 18px;
        stroke: #3b82f6;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-images-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;
    }
    
    .td-image-item {
        position: relative;
        aspect-ratio: 1;
        border-radius: 10px;
        overflow: hidden;
        cursor: pointer;
        transition: all 0.2s;
        border: 2px solid #e8ecf1;
    }
    
    .td-image-item:hover {
        transform: scale(1.05);
        border-color: #3b82f6;
        box-shadow: 0 4px 12px rgba(59,130,246,0.2);
    }
    
    .td-image-item img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    
    .td-image-empty {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 32px 20px;
        text-align: center;
        color: #94a3b8;
        font-size: 13px;
    }
    
    .td-image-empty svg {
        width: 48px;
        height: 48px;
        stroke: #cbd5e1;
        fill: none;
        stroke-width: 2;
        margin: 0 auto 12px;
        display: block;
    }
    
    /* 统计卡片 */
    .td-stats-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 20px;
        margin-bottom: 20px;
    }
    
    .td-stats-title {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .td-stats-title svg {
        width: 18px;
        height: 18px;
        stroke: #10b981;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-stat-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px;
        background: #f8fafc;
        border-radius: 10px;
        margin-bottom: 8px;
    }
    
    .td-stat-item:last-child {
        margin-bottom: 0;
    }
    
    .td-stat-label {
        font-size: 13px;
        color: #64748b;
    }
    
    .td-stat-value {
        font-size: 15px;
        font-weight: 700;
        color: #334155;
    }
    
    /* 快捷操作卡片 */
    .td-actions-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 20px;
    }
    
    .td-actions-title {
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .td-actions-title svg {
        width: 18px;
        height: 18px;
        stroke: #f59e0b;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-action-btn {
        display: flex;
        align-items: center;
        gap: 10px;
        width: 100%;
        padding: 12px 16px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        color: #475569;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        margin-bottom: 8px;
    }
    
    .td-action-btn:last-child {
        margin-bottom: 0;
    }
    
    .td-action-btn:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
        color: #334155;
    }
    
    .td-action-btn svg {
        width: 18px;
        height: 18px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    /* 课程信息卡片 */
    .td-course-card {
        background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%);
        border-radius: 16px;
        padding: 24px;
        margin-bottom: 20px;
        color: #fff;
        box-shadow: 0 4px 20px rgba(99,102,241,0.25);
        position: relative;
        overflow: hidden;
    }
    
    .td-course-card::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -30px;
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background: rgba(255,255,255,0.08);
    }
    
    .td-course-title {
        font-size: 18px;
        font-weight: 700;
        color: #fff;
        margin: 0 0 16px 0;
        line-height: 1.4;
        position: relative;
        z-index: 1;
    }
    
    .td-course-meta {
        display: flex;
        flex-direction: column;
        gap: 8px;
        position: relative;
        z-index: 1;
    }
    
    .td-meta-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: rgba(255,255,255,0.9);
    }
    
    .td-meta-item svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }
    
    /* 课程内容导航卡片 */
    .td-nav-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        overflow: hidden;
    }
    
    .td-nav-head {
        padding: 16px 20px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .td-nav-head svg {
        width: 18px;
        height: 18px;
        stroke: #6366f1;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-nav-head h3 {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        margin: 0;
    }
    
    .td-nav-list {
        padding: 12px;
    }
    
    /* GridView样式重置 */
    .td-nav-list table {
        width: 100% !important;
        border: none !important;
        border-collapse: collapse !important;
    }
    
    .td-nav-list table tr {
        background: none !important;
        border: none !important;
    }
    
    .td-nav-list table td {
        padding: 0 !important;
        border: none !important;
        background: none !important;
    }
    
    .td-nav-item-wrapper {
        margin-bottom: 6px;
    }
    
    .td-nav-item {
        display: flex !important;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        border-radius: 10px;
        text-decoration: none !important;
        color: #475569 !important;
        font-size: 14px;
        transition: all 0.2s;
        border: 1px solid transparent;
        cursor: pointer;
    }
    
    .td-nav-item:hover {
        background: #f8fafc;
        color: #6366f1 !important;
        border-color: #e0e7ff;
    }
    
    .td-nav-item.active {
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        color: #4f46e5 !important;
        font-weight: 600;
        border-color: #c7d2fe;
    }
    
    .td-nav-icon {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        background: #f1f5f9;
        display: flex !important;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    
    .td-nav-item.active .td-nav-icon {
        background: #6366f1;
    }
    
    .td-nav-icon svg {
        width: 16px;
        height: 16px;
        stroke: #64748b;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-nav-item.active .td-nav-icon svg {
        stroke: #fff;
    }
    
    .td-nav-text {
        flex: 1;
        min-width: 0;
    }
    
    .td-nav-title {
        font-size: 14px;
        font-weight: 500;
        margin-bottom: 2px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    
    .td-nav-status {
        font-size: 12px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    /* 完成状态标识 */
    .td-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 10px;
        border-radius: 12px;
        font-size: 11px;
        font-weight: 600;
        line-height: 1.4;
    }
    
    .td-status-completed {
        background: #d1fae5;
        color: #059669;
    }
    
    .td-status-completed::before {
        content: '✓';
        font-size: 12px;
        font-weight: 700;
    }
    
    .td-status-pending {
        background: #fee2e2;
        color: #dc2626;
    }
    
    .td-status-pending::before {
        content: '○';
        font-size: 10px;
    }
    
    /* 右侧内容区 */
    .td-main {
        flex: 1;
        min-width: 0;
    }
    
    /* 主题内容卡片 */
    .td-content-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 28px 32px;
        margin-bottom: 20px;
    }
    
    .td-content-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 16px;
        border-bottom: 2px solid #f1f5f9;
    }
    
    .td-content-title-wrap {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .td-content-title-wrap svg {
        width: 24px;
        height: 24px;
        stroke: #3b82f6;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-content-actions {
        display: flex;
        gap: 8px;
    }
    
    .td-icon-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 36px;
        height: 36px;
        border-radius: 8px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        cursor: pointer;
        transition: all 0.2s;
    }
    
    .td-icon-btn:hover {
        background: #eef2ff;
        border-color: #c7d2fe;
    }
    
    .td-icon-btn img {
        width: 16px;
        height: 16px;
    }
    
    /* 讨论帖子样式 */
    .topictext {
        user-select: none;
        padding: 16px;
        border-radius: 10px;
        transition: all 0.2s;
    }
    
    .topictext:hover {
        background-color: #f8fafc;
    }
    
    .topictext img {
        max-height: 400px;
        border-radius: 12px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        margin: 12px 0;
    }
    
    .imgstu {
        width: 32px;
        height: 32px;
        border-radius: 16px;
        opacity: 0.9;
        transition: opacity 0.2s;
    }
    
    .imgstu:hover {
        opacity: 1;
    }
    
    .topichead {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 16px;
        background: #f8fafc;
        border-radius: 10px 10px 0 0;
        margin-bottom: 0;
    }
    
    .topicleft {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        font-weight: 600;
        color: #334155;
    }
    
    .topicright {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #64748b;
    }
    
    /* 回复编辑器卡片 */
    .td-editor-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 24px 28px;
        margin-bottom: 20px;
    }
    
    .td-editor-title {
        font-size: 16px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .td-editor-title svg {
        width: 20px;
        height: 20px;
        stroke: #3b82f6;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .td-word-count {
        text-align: center;
        color: #64748b;
        font-size: 13px;
        margin: 12px 0;
    }
    
    .word_count {
        color: #3b82f6;
        font-weight: 600;
    }
    
    .td-submit-btn {
        display: inline-block;
        padding: 12px 32px;
        background: linear-gradient(135deg, #3b82f6, #60a5fa);
        color: #fff;
        border: none;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
    }
    
    .td-submit-btn:hover {
        background: linear-gradient(135deg, #2563eb, #3b82f6);
        transform: translateY(-2px);
        box-shadow: 0 4px 16px rgba(59,130,246,0.3);
    }
    
    /* 隐藏字段 */
    .td-hidden-fields {
        display: none;
    }
    
    /* 图片查看器 */
    #outerdiv {
        position: fixed;
        top: 0;
        left: 0;
        background: rgba(0,0,0,0.9);
        z-index: 9999;
        width: 100%;
        height: 100%;
        display: none;
        cursor: pointer;
    }
    
    #innerdiv {
        position: absolute;
    }
    
    #bigimg {
        pointer-events: none;
        border-radius: 8px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.5);
    }
    
    /* 响应式 */
    @media (max-width: 1024px) {
        .td-layout {
            flex-direction: column;
        }
        
        .td-sidebar {
            width: 100%;
        }
        
        .td-sidebar-sticky {
            position: static;
            max-height: none;
        }
    }
    
    @media (max-width: 768px) {
        .td-layout {
            padding: 0 8px 24px;
        }
        
        .td-topic-card,
        .td-stats-card,
        .td-content-card,
        .td-editor-card {
            padding: 20px;
        }
        
        .topichead {
            flex-direction: column;
            align-items: flex-start;
            gap: 8px;
        }
        
        .topicright {
            width: 100%;
            justify-content: space-between;
        }
    }
</style>

<div class="td-layout">
    <!-- 左侧边栏：课程信息 + 导航列表 -->
    <aside class="td-left-sidebar">
        <div class="td-left-sticky">
            <!-- 课程信息卡片 -->
            <div class="td-course-card">
                <h3 class="td-course-title">
                    <asp:Label ID="LabelCourseTitle" runat="server">课程讨论</asp:Label>
                </h3>
                <div class="td-course-meta">
                    <div class="td-meta-item">
                        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        <span>课堂讨论</span>
                    </div>
                    <div class="td-meta-item">
                        <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                        <span>互动交流</span>
                    </div>
                    <div class="td-meta-item">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        <span>实时互动</span>
                    </div>
                </div>
            </div>
            
            <!-- 课程导航列表卡片 -->
            <div class="td-nav-card">
                <div class="td-nav-head">
                    <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                    <h3>课程内容</h3>
                </div>
                <div class="td-nav-list" id="tdNavList" runat="server">
                    <asp:GridView ID="GVlistmenu" runat="server" Width="100%"
                        AutoGenerateColumns="False" ShowHeader="False"
                        GridLines="None" BorderStyle="None" BorderWidth="0">
                        <Columns>
                            <asp:TemplateField Visible="False">
                                <ItemTemplate>
                                    <asp:Label ID="LabelLid" runat="server" Text='<%# Bind("Lid") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField Visible="False">
                                <ItemTemplate>
                                    <asp:Label ID="LabelLxid" runat="server" Text='<%# Bind("Lxid") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField Visible="False">
                                <ItemTemplate>
                                    <asp:Label ID="LabelLtype" runat="server" Text='<%# Bind("Ltype") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div class="td-nav-item-wrapper">
                                        <asp:HyperLink ID="HlLtitle" runat="server" NavigateUrl="" CssClass="td-nav-item">
                                            <div class="td-nav-icon">
                                                <asp:Label ID="Label4" runat="server"></asp:Label>
                                            </div>
                                            <div class="td-nav-text">
                                                <div class="td-nav-title"><%# Eval("Ltitle") %></div>
                                                <div class="td-nav-status"><asp:Label ID="LabelType" runat="server"></asp:Label></div>
                                            </div>
                                        </asp:HyperLink>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </aside>
    
    <!-- 右侧内容区 -->
    <main class="td-main">
        <!-- 主题内容卡片 -->
        <div class="td-content-card" id="topper">
            <div class="td-content-header">
                <div class="td-content-title-wrap">
                    <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    <h3 style="margin:0; font-size:16px; font-weight:600; color:#334155;">讨论主题</h3>
                </div>
                <div class="td-content-actions">
                    <asp:ImageButton ID="Btnclock" runat="server" ImageUrl="~/images/clock.gif" 
                        onclick="Btnclock_Click" Enabled="False" CssClass="td-icon-btn" />
                    <anthem:ImageButton ID="ImageBtnFresh" runat="server" 
                        ImageUrl="~/images/refresh2.gif" onclick="ImageBtnFresh_Click" 
                        ToolTip="刷新贴子" CssClass="td-icon-btn" />
                    <anthem:HyperLink ID="HLbottom" runat="server" 
                        ImageUrl="~/images/bottom.png" NavigateUrl="#bottom" 
                        ToolTip="跳到底部" CssClass="td-icon-btn"></anthem:HyperLink>
                </div>
            </div>
            
            <div ID="Topics" runat="server" style="font: 14pt/180% Arial; padding:16px; background:#f8fafc; border-radius:10px; margin-bottom:20px;"></div>
            <div ID="TopicsResult" runat="server" class="topictext"></div>
        </div>
        
        <!-- 帖子列表 -->
        <div class="td-content-card">
            <anthem:GridView ID="GVtopicDiscuss" runat="server" AutoGenerateColumns="False" 
                CellPadding="0" Width="100%" 
                onrowdatabound="GVtopicDiscuss_RowDataBound"  
                DataKeyNames="rid" PageSize="5" CellSpacing="1" 
                ShowHeader="False" GridLines="None" 
                onrowcommand="GVtopicDiscuss_RowCommand">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>   
                            <div style="border: 1px solid #e8ecf1; border-radius:12px; margin-bottom:16px; overflow:hidden;">
                                <div class="topichead">
                                    <div class="topicleft">
                                        <anthem:Image ID="Imagestu" runat="server" CssClass="imgstu" />                                            
                                        <anthem:Label ID="Labelsname" runat="server" Text='<%# Bind("Sname") %>'></anthem:Label>
                                        <anthem:Image ID="Imageagree" runat="server" Visible="False" ImageUrl="~/images/good16.png" />
                                        <anthem:CheckBox ID="Ckedit" runat="server" Checked='<%# Bind("Redit") %>' Visible="False" />
                                        <anthem:Label ID="Labelsnum" runat="server" Text='<%# Bind("Rsnum") %>' Visible="False"></anthem:Label>
                                        <anthem:CheckBox ID="CheckSleader" runat="server" Checked='<%# Bind("Sleader") %>' Visible="False" />
                                    </div>
                                    <div class="topicright">
                                        <anthem:Image ID="Imagegroup" runat="server" ImageUrl="~/images/gcard.gif" />
                                        <anthem:Label ID="Labelscore" runat="server" Text='<%# Bind("Rscore") %>' ToolTip="学分"></anthem:Label>学分
                                        <anthem:ImageButton ID="ImageButtonAgree" runat="server" 
                                            CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                                            CommandName="Agree" ImageUrl="~/images/good24.gif" ToolTip="点赞"></anthem:ImageButton>
                                        <anthem:Label ID="Labelagree" runat="server" Text='<%# Bind("Ragree") %>'></anthem:Label>赞
                                        <anthem:Image ID="Imageflag" runat="server" ImageUrl="~/images/topicnormal.png" />
                                        <anthem:Label ID="Labelfloor" runat="server"></anthem:Label>楼
                                        <anthem:ImageButton ID="ImageButtonEdit" runat="server" 
                                            CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                                            CommandName="Reply" ImageUrl="~/images/edno.gif" />
                                        <anthem:ImageButton ID="ImageButtonGood" runat="server" 
                                            CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                                            CommandName="Good" ImageUrl="~/images/right.gif" ToolTip="加2分"/>
                                        <anthem:ImageButton ID="ImageButtonless" runat="server" 
                                            CausesValidation="false" CommandArgument='<%# Bind("rid") %>'
                                            CommandName="Less" ImageUrl="~/images/ban.gif" ToolTip="减2分" />
                                        <anthem:ImageButton ID="ImageButtonDel" runat="server" CausesValidation="false" 
                                            CommandArgument='<%# Bind("rid") %>' CommandName="Del" 
                                            ImageUrl="~/images/delete.gif" />
                                    </div>
                                </div>
                                <div class="topictext">
                                    <%# HttpUtility.HtmlDecode(Eval("Rwords").ToString())%>
                                    <div style="text-align:right; color:#94a3b8; font-size:12px; margin-top:12px; padding-top:12px; border-top:1px solid #f1f5f9;">
                                        时间：<anthem:Label ID="Labeldate" runat="server" Text='<%# Bind("Rtime") %>'></anthem:Label> 
                                        &nbsp; IP：<anthem:Label ID="Labelip" runat="server" Text='<%# Bind("Rip") %>'></anthem:Label>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>             
                <HeaderStyle Font-Bold="False" />
            </anthem:GridView>
        </div>
        
        <div id="bottom"></div>
        
        <!-- 回复编辑器 -->
        <div id="plant" runat="server">
            <div class="td-editor-card">
                <div class="td-editor-title">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    发表讨论
                </div>
                
                <textarea name="textareaWord" style="width: 100%; height:260px; border:1px solid #e2e8f0; border-radius:10px; padding:12px; font-size:14px;"></textarea>
                
                <div class="td-word-count">
                    您当前输入了 <span class="word_count">0</span> 个文字（不少于2个汉字，最多为300汉字）
                </div>
                
                <div style="text-align:center;">
                    <asp:Button ID="Btnword" runat="server" Text="发表讨论" 
                        onclick="Btnword_Click" CssClass="td-submit-btn" />
                    <br /><br />
                    <anthem:Label ID="Labeldiscuss" runat="server" style="color:#dc2626; font-size:13px;"></anthem:Label>
                </div>
            </div>
        </div>
        
        <div style="text-align:center; margin-top:20px;">
            <anthem:HyperLink ID="HLtop" runat="server" 
                ImageUrl="~/images/top.png" NavigateUrl="#topper" 
                ToolTip="跳到顶部" CssClass="td-icon-btn"></anthem:HyperLink>
            <anthem:imagebutton ID="ImageBtngoodall" runat="server" 
                ImageUrl="~/images/right.gif" onclick="ImageBtngoodall_Click" 
                ToolTip="给所有未评分的帖子加2分" Visible="False" CssClass="td-icon-btn" />
            <anthem:imagebutton ID="ImageBtngood2" runat="server" 
                ImageUrl="~/images/right.gif" onclick="ImageBtngood2_Click" 
                ToolTip="给所有未评分的帖子加6分" Visible="False" CssClass="td-icon-btn" />
            <anthem:ImageButton ID="ImageBtnFreshtwo" runat="server" 
                ImageUrl="~/images/refresh2.gif" onclick="ImageBtnFresh_Click" 
                ToolTip="刷新贴子" CssClass="td-icon-btn" />
        </div>
    </main>
    
    <!-- 右侧边栏：讨论图片 + 统计 + 快捷操作 -->
    <aside class="td-right-sidebar">
        <div class="td-right-sticky">
            <!-- 讨论图片卡片 -->
            <div class="td-images-card">
                <div class="td-images-title">
                    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    讨论图片
                </div>
                <div class="td-images-grid" id="discussImages">
                    <!-- 图片将通过JavaScript动态加载 -->
                </div>
                <div class="td-image-empty" id="noImages" style="display:none;">
                    <div>
                        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                        <p style="margin:0;">暂无图片</p>
                    </div>
                </div>
            </div>
            
            <!-- 统计信息卡片 -->
            <div class="td-stats-card">
                <div class="td-stats-title">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                    讨论统计
                </div>
                <div class="td-stat-item">
                    <span class="td-stat-label">帖子总数</span>
                    <span class="td-stat-value"><anthem:Label ID="Labelreplycount" runat="server"></anthem:Label></span>
                </div>
                <div class="td-stat-item">
                    <span class="td-stat-label">未参与学生</span>
                    <span class="td-stat-value"><anthem:Label ID="Labelnostu" runat="server"></anthem:Label></span>
                </div>
            </div>
            
            <!-- 快捷操作卡片 -->
            <div class="td-actions-card">
                <div class="td-actions-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                    快捷操作
                </div>
                <a href="#topper" class="td-action-btn">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/></svg>
                    返回顶部
                </a>
                <a href="#bottom" class="td-action-btn">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><polyline points="19 12 12 19 5 12"/></svg>
                    跳到底部
                </a>
                <button type="button" class="td-action-btn" onclick="location.reload();">
                    <svg viewBox="0 0 24 24"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                    刷新页面
                </button>
            </div>
        </div>
    </aside>
</div>

<!-- 隐藏字段 -->
<div class="td-hidden-fields">
    <asp:Label ID="LabelCid" runat="server"></asp:Label>
    <asp:Label ID="LabelLid" runat="server"></asp:Label>
    <asp:Label ID="LabelTid" runat="server"></asp:Label>
    <anthem:CheckBox ID="TcloseCheck" runat="server" />
    <asp:Label ID="Labelreplycountbtm" runat="server"></asp:Label>
</div>

<!-- 图片查看器 -->
<div id="outerdiv">
    <div id="innerdiv">
        <img id="bigimg" src="" />
    </div>
</div>

<script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
<script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>
<script src="../code/jquery.min.js" type="text/javascript"></script>

<script type="text/javascript">
    // 平滑滚动到顶部
    window.scrollTo({ top: 0, behavior: 'smooth' });
    
    // 控制台调试信息
    var debugMode = true; // 设置为 false 关闭调试
    if (debugMode) {
        // 显示当前URL参数
        var cidParam = getQueryParam('cid');
        var lidParam = getQueryParam('lid');
        console.log('=== 讨论页面调试信息 ===');
        console.log('URL参数 - cid:', cidParam, 'lid:', lidParam);
        
        if (!cidParam) {
            console.warn('警告：URL中缺少cid参数，课程内容列表将无法显示');
            console.log('正确的URL格式：topicdiscuss.aspx?lid=2&cid=3');
        }
        
        // 检查GridView是否有数据
        setTimeout(function() {
            var navList = document.getElementById('tdNavList');
            if (navList) {
                var items = navList.querySelectorAll('.td-nav-item-wrapper');
                console.log('找到任务数量:', items.length);
                
                if (items.length === 0) {
                    console.warn('警告：没有找到任务列表项');
                    console.log('可能原因：');
                    console.log('1. URL中缺少cid参数');
                    console.log('2. 数据库中没有对应课程的任务（Listmenu表）');
                    console.log('3. 任务的lshow字段不是True');
                } else {
                    console.log('✓ 任务列表加载成功');
                }
            }
        }, 500);
    }
    
    // 获取URL参数
    function getQueryParam(name) {
        var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i');
        var r = window.location.search.substr(1).match(reg);
        if (r != null) {
            return decodeURIComponent(r[2]);
        }
        return null;
    }
    
    // 活动类型图标映射
    var iconMap = {
        '积木': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', color: '#f59e0b' },
        '活动': { svg: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>', color: '#10b981' },
        '讨论': { svg: '<svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>', color: '#3b82f6' },
        '调查': { svg: '<svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>', color: '#8b5cf6' },
        '填表': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>', color: '#06b6d4' },
        '积木编程': { svg: '<svg viewBox="0 0 24 24"><rect x="2" y="6" width="8" height="6" rx="1"/><rect x="14" y="6" width="8" height="6" rx="1"/><rect x="8" y="14" width="8" height="6" rx="1"/></svg>', color: '#f59e0b' },
        'Python': { svg: '<svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/><line x1="14" y1="4" x2="10" y2="20"/></svg>', color: '#3b82f6' },
        '测评': { svg: '<svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>', color: '#ef4444' },
        '流程图': { svg: '<svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>', color: '#14b8a6' },
        '应用': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', color: '#8b5cf6' },
        'Html': { svg: '<svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>', color: '#f97316' },
        '导图': { svg: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="12" y1="15" x2="12" y2="22"/><line x1="2" y1="12" x2="9" y2="12"/><line x1="15" y1="12" x2="22" y2="12"/></svg>', color: '#ec4899' },
        '表格': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>', color: '#10b981' },
        '课件': { svg: '<svg viewBox="0 0 24 24"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>', color: '#6366f1' },
        '绘图': { svg: '<svg viewBox="0 0 24 24"><path d="M12 19l7-7 3 3-7 7-3-3z"/><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"/></svg>', color: '#f59e0b' },
        '主题': { svg: '<svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>', color: '#8b5cf6' },
        '网页': { svg: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>', color: '#06b6d4' },
        '仓库': { svg: '<svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>', color: '#f59e0b' },
        '代码': { svg: '<svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>', color: '#10b981' },
        '练习': { svg: '<svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>', color: '#3b82f6' },
        '拼图': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>', color: '#ec4899' },
        '像素': { svg: '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>', color: '#8b5cf6' }
    };
    
    // 类型到URL的映射
    var typeUrlMap = {
        '积木': 'program.aspx',
        '活动': 'showmission.aspx',
        '讨论': 'topicdiscuss.aspx',
        '调查': 'mysurvey.aspx',
        '填表': 'txtform.aspx',
        '积木编程': 'program.aspx',
        'Python': 'python.aspx',
        '测评': 'console.aspx',
        '流程图': 'mxgraph.aspx',
        '应用': 'pixel.aspx',
        'Html': 'htmledit.aspx',
        '导图': 'kitymind.aspx',
        '表格': 'program.aspx',
        '课件': 'ware.aspx',
        '绘图': 'draw.aspx',
        '主题': 'showmission.aspx',
        '网页': 'website.aspx',
        '仓库': 'webstore.aspx',
        '代码': 'codeproject.aspx',
        '练习': 'showmission.aspx',
        '拼图': 'pixel.aspx',
        '像素': 'pixel.aspx'
    };
    
    // 加载任务内容
    function loadMissionContent(element) {
        var wrapper = element.closest('.td-nav-item-wrapper');
        if (!wrapper) return;
        
        var ltype = wrapper.getAttribute('data-ltype');
        var lxid = wrapper.getAttribute('data-lxid');
        var lid = wrapper.getAttribute('data-lid');
        var cid = getQueryParam('cid');
        
        if (!ltype || !lxid) return;
        
        // 构建URL
        var url = typeUrlMap[ltype] || 'showmission.aspx';
        
        // 根据不同类型添加不同的参数
        if (ltype === '讨论') {
            url += '?lid=' + lid;
        } else if (ltype === '调查') {
            url += '?sid=' + lxid;
        } else if (ltype === '填表') {
            url += '?fid=' + lxid;
        } else if (ltype === '积木' || ltype === '积木编程') {
            url += '?pid=' + lxid;
        } else if (ltype === 'Python') {
            url += '?pyid=' + lxid;
        } else if (ltype === '测评') {
            url += '?cid=' + lxid;
        } else if (ltype === '流程图') {
            url += '?gid=' + lxid;
        } else if (ltype === '应用' || ltype === '拼图' || ltype === '像素') {
            url += '?pxid=' + lxid;
        } else if (ltype === 'Html') {
            url += '?hid=' + lxid;
        } else if (ltype === '导图') {
            url += '?kid=' + lxid;
        } else if (ltype === '表格') {
            url += '?eid=' + lxid;
        } else if (ltype === '课件') {
            url += '?wid=' + lxid;
        } else if (ltype === '绘图') {
            url += '?did=' + lxid;
        } else if (ltype === '网页') {
            url += '?wsid=' + lxid;
        } else if (ltype === '仓库') {
            url += '?wrid=' + lxid;
        } else if (ltype === '代码') {
            url += '?cpid=' + lxid;
        } else {
            url += '?mid=' + lxid;
        }
        
        // 添加课程ID
        if (cid) {
            url += '&cid=' + cid;
        }
        
        // 跳转到任务页面
        window.location.href = url;
    }
    
    // KindEditor初始化
    var editor;
    var ty = "Topic";
    var cid = "<%=myCid %>";
    var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
    
    KindEditor.ready(function (K) {
        editor = K.create('textarea[name="textareaWord"]', {
            filterMode: false,
            resizeType: 1,
            pasteType: 1,
            newlineTag: "br",
            allowPreviewEmoticons: false,
            uploadJson: upjs,
            allowImageUpload: true,
            items: ['formatblock', 'fontname', 'fontsize', '|', 'bold', 'italic', 'forecolor', 'hilitecolor', 'removeformat', '|', 'justifyleft', 'justifycenter', 'justifyright', 'image'],
            afterChange: function () {
                K('.word_count').html(this.count('text'));
            }
        });
    });
    
    // 初始化课程导航图标
    $(document).ready(function() {
        // 图片点击放大
        $(".topictext img").click(function () {
            var _this = $(this);
            imgShow("#outerdiv", "#innerdiv", "#bigimg", _this);
        });

        $(".topictext img").each(function (i) {
            $(this).attr("oncontextmenu", "return false;");
        });
        
        // 加载课程内容列表
        loadCourseContent();
    });
    
    // 加载课程内容
    function loadCourseContent() {
        var cid = getQueryParam('cid');
        var lid = getQueryParam('lid');
        
        console.log('=== 加载课程内容 ===');
        console.log('CID:', cid, 'LID:', lid);
        
        if (!cid) {
            console.warn('缺少cid参数，无法加载课程内容');
            showEmptyMessage();
            return;
        }
        
        // 隐藏加载消息
        $('#navLoadingMessage').hide();
        
        // 这里应该通过 AJAX 从服务器加载数据
        // 由于后端限制，暂时显示提示信息
        showEmptyMessage();
        
        console.log('提示：需要后端支持才能加载课程内容列表');
        console.log('请联系管理员配置数据加载接口');
    }
    
    // 显示空消息
    function showEmptyMessage() {
        $('#navLoadingMessage').hide();
        $('#navEmptyMessage').show();
    }

    function imgShow(outerdiv, innerdiv, bigimg, _this) {
        var src = _this.attr("src");
        $(bigimg).attr("src", src);
        $("<img/>").attr("src", src).on('load', function () {
            var windowW = $(window).width();
            var windowH = $(window).height();
            var realWidth = this.width;
            var readHeight = this.height;
            var imgWidth, imgHeight;
            var scale = 0.8;
            
            if (realWidth > windowW * scale) {
                imgHeight = windowH * scale;
                imgWidth = imgHeight / readHeight * realWidth;
                if (imgWidth > windowW * scale) {
                    imgWidth = windowW * scale;
                }
            } else if (realWidth > windowW * scale) {
                imgWidth = windowW * scale;
                imgHeight = imgWidth / realWidth * readHeight;
            } else {
                imgWidth = realWidth;
                imgHeight = readHeight;
            }
            
            $(bigimg).css("width", imgWidth);
            var w = (windowW - imgWidth) / 2;
            var h = (windowH - imgHeight) / 2;
            $(innerdiv).css({ "top": h, "left": w });
            $(outerdiv).fadeIn("fast");
        });
        
        $(outerdiv).click(function () {
            $(this).fadeOut("fast");
        });
    }
</script>
</asp:Content>
