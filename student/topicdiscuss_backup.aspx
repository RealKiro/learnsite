<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" validaterequest="false" autoeventwireup="true" inherits="Student_showcourse, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* ===== 学案展示页面 - 左右分栏布局 ===== */
    .sc-layout {
        display: flex;
        gap: 24px;
        max-width: 1600px;
        margin: 0 auto;
        padding: 0 16px 40px;
        min-height: calc(100vh - 200px);
    }
    
    /* 左侧导航栏 */
    .sc-sidebar {
        width: 320px;
        flex-shrink: 0;
    }
    
    .sc-sidebar-sticky {
        position: sticky;
        top: 80px;
        max-height: calc(100vh - 100px);
        overflow-y: auto;
    }
    
    /* 课程信息卡片 */
    .sc-course-card {
        background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%);
        border-radius: 16px;
        padding: 24px;
        margin-bottom: 20px;
        color: #fff;
        box-shadow: 0 4px 20px rgba(99,102,241,0.25);
        position: relative;
        overflow: hidden;
    }
    
    .sc-course-card::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -30px;
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background: rgba(255,255,255,0.08);
    }
    
    .sc-course-title {
        font-size: 20px;
        font-weight: 700;
        color: #fff;
        margin: 0 0 16px 0;
        line-height: 1.4;
        position: relative;
        z-index: 1;
    }
    
    .sc-course-meta {
        display: flex;
        flex-direction: column;
        gap: 8px;
        position: relative;
        z-index: 1;
    }
    
    .sc-meta-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: rgba(255,255,255,0.9);
    }
    
    .sc-meta-item svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }
    
    /* 章节导航 */
    .sc-nav-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        overflow: hidden;
    }
    
    .sc-nav-head {
        padding: 16px 20px;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%);
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .sc-nav-head svg {
        width: 18px;
        height: 18px;
        stroke: #6366f1;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .sc-nav-head h3 {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        margin: 0;
    }
    
    .sc-nav-list {
        padding: 12px;
    }
    
    /* GridView样式重置 */
    .sc-nav-list table {
        width: 100% !important;
        border: none !important;
        border-collapse: collapse !important;
    }
    
    .sc-nav-list table tr {
        background: none !important;
        border: none !important;
    }
    
    .sc-nav-list table td {
        padding: 0 !important;
        border: none !important;
        background: none !important;
    }
    
    .sc-nav-item-wrapper {
        margin-bottom: 6px;
    }
    
    .sc-nav-item {
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
    }
    
    .sc-nav-item:hover {
        background: #f8fafc;
        color: #6366f1 !important;
        border-color: #e0e7ff;
    }
    
    .sc-nav-item.active {
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        color: #4f46e5 !important;
        font-weight: 600;
        border-color: #c7d2fe;
    }
    
    .sc-nav-icon {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        background: #f1f5f9;
        display: flex !important;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    
    .sc-nav-item.active .sc-nav-icon {
        background: #6366f1;
    }
    
    .sc-nav-icon svg {
        width: 16px;
        height: 16px;
        stroke: #64748b;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .sc-nav-item.active .sc-nav-icon svg {
        stroke: #fff;
    }
    
    .sc-nav-text {
        flex: 1;
        min-width: 0;
    }
    
    .sc-nav-title {
        font-size: 14px;
        font-weight: 500;
        margin-bottom: 2px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    
    .sc-nav-status {
        font-size: 12px;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .sc-nav-status-dot {
        width: 4px;
        height: 4px;
        border-radius: 50%;
        background: #cbd5e1;
    }
    
    .sc-nav-publish-status {
        font-size: 11px;
        padding: 2px 6px;
        border-radius: 4px;
        font-weight: 500;
    }
    
    .sc-nav-publish-status.published {
        background: #d1fae5;
        color: #059669;
    }
    
    .sc-nav-publish-status.draft {
        background: #fef3c7;
        color: #d97706;
    }
    
    .sc-new-badge {
        display: inline-block;
        font-size: 10px;
        font-weight: 700;
        color: #fff;
        background: linear-gradient(135deg, #ef4444, #f97316);
        padding: 2px 6px;
        border-radius: 4px;
        margin-left: 6px;
        vertical-align: middle;
        animation: newPulse 2s ease-in-out infinite;
    }
    
    @keyframes newPulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.7; }
    }
    
    .sc-nav-icon {
        position: relative;
    }
    
    .sc-nav-icon-svg {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 18px;
        height: 18px;
    }
    
    .sc-nav-icon-svg svg {
        width: 100%;
        height: 100%;
    }
    
    .sc-nav-item.active .sc-nav-status {
        color: #6366f1;
    }
    
    /* 完成状态标识 */
    .sc-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 10px;
        border-radius: 12px;
        font-size: 11px;
        font-weight: 600;
        line-height: 1.4;
    }
    
    .sc-status-completed {
        background: #d1fae5;
        color: #059669;
    }
    
    .sc-status-completed::before {
        content: '✓';
        font-size: 12px;
        font-weight: 700;
    }
    
    .sc-status-pending {
        background: #fee2e2;
        color: #dc2626;
    }
    
    .sc-status-pending::before {
        content: '○';
        font-size: 10px;
    }
    
    /* 右侧内容区 */
    .sc-main {
        flex: 1;
        min-width: 0;
    }
    
    /* 内容标题卡片 */
    .sc-content-header {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 24px 28px;
        margin-bottom: 20px;
    }
    
    .sc-content-title {
        font-size: 24px;
        font-weight: 700;
        color: #1e293b;
        margin: 0 0 12px 0;
        line-height: 1.3;
    }
    
    .sc-content-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        font-size: 13px;
        color: #64748b;
    }
    
    .sc-content-meta-item {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .sc-content-meta-item svg {
        width: 14px;
        height: 14px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    /* 内容卡片 */
    .sc-content-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        padding: 32px 36px;
        margin-bottom: 20px;
        min-height: 400px;
    }
    
    .sc-content-body {
        font-size: 16px;
        color: #334155;
        line-height: 1.8;
    }
    
    .sc-content-body h1,
    .sc-content-body h2,
    .sc-content-body h3,
    .sc-content-body h4 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 32px;
        margin-bottom: 16px;
        line-height: 1.3;
    }
    
    .sc-content-body h1 { font-size: 28px; }
    .sc-content-body h2 { font-size: 24px; }
    .sc-content-body h3 { font-size: 20px; }
    .sc-content-body h4 { font-size: 18px; }
    
    .sc-content-body p {
        margin-bottom: 16px;
    }
    
    .sc-content-body img {
        max-width: 100%;
        height: auto;
        border-radius: 12px;
        margin: 24px 0;
        box-shadow: 0 4px 16px rgba(0,0,0,0.08);
    }
    
    .sc-content-body a {
        color: #6366f1;
        text-decoration: none;
        border-bottom: 1px solid transparent;
        transition: all 0.2s;
    }
    
    .sc-content-body a:hover {
        color: #4f46e5;
        border-bottom-color: #6366f1;
    }
    
    /* 底部导航 */
    .sc-footer-nav {
        display: flex;
        justify-content: space-between;
        gap: 16px;
        padding: 20px 0;
    }
    
    .sc-footer-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 12px 24px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.2s;
        border: 1px solid #e2e8f0;
        background: #fff;
        color: #475569;
    }
    
    .sc-footer-btn:hover {
        background: #f8fafc;
        border-color: #cbd5e1;
        color: #334155;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }
    
    .sc-footer-btn svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .sc-footer-btn.primary {
        background: linear-gradient(135deg, #6366f1, #818cf8);
        color: #fff;
        border-color: transparent;
    }
    
    .sc-footer-btn.primary:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1);
        box-shadow: 0 4px 16px rgba(99,102,241,0.3);
    }
    
    /* 响应式 */
    @media (max-width: 1024px) {
        .sc-layout {
            flex-direction: column;
        }
        
        .sc-sidebar {
            width: 100%;
        }
        
        .sc-sidebar-sticky {
            position: static;
            max-height: none;
        }
        
        .sc-nav-card {
            margin-bottom: 20px;
        }
    }
    
    @media (max-width: 768px) {
        .sc-layout {
            padding: 0 8px 24px;
        }
        
        .sc-course-card {
            padding: 20px;
        }
        
        .sc-content-header,
        .sc-content-card {
            padding: 20px 24px;
        }
        
        .sc-footer-nav {
            flex-direction: column;
        }
        
        .sc-footer-btn {
            width: 100%;
            justify-content: center;
        }
    }
</style>

<div class="sc-layout">
    <!-- 左侧导航栏 -->
    <aside class="sc-sidebar">
        <div class="sc-sidebar-sticky">
            <!-- 课程信息卡片 -->
            <div class="sc-course-card">
                <h2 class="sc-course-title">
                    <asp:Label ID="LabelCtitle" runat="server"></asp:Label>
                </h2>
                <div class="sc-course-meta">
                    <div class="sc-meta-item">
                        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        <span>2024学年</span>
                    </div>
                    <div class="sc-meta-item">
                        <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                        <span>信息技术课程</span>
                    </div>
                    <div class="sc-meta-item">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        <span>共12课时</span>
                    </div>
                </div>
            </div>
            
            <!-- 课程内容导航 -->
            <div class="sc-nav-card">
                <div class="sc-nav-head">
                    <svg viewBox="0 0 24 24" style="width: 20px; height: 20px;"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                    <h3>课程内容</h3>
                </div>
                <div class="sc-nav-list" id="scNavList" runat="server">
                    <!-- 备用静态内容容器 -->
                    <div id="navFallback" style="display:none;">
                        <div style="padding: 32px 20px; text-align: center; color: #94a3b8; font-size: 14px;">
                            <svg viewBox="0 0 24 24" style="width: 48px; height: 48px; stroke: #cbd5e1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; margin: 0 auto 12px; display: block;">
                                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                            </svg>
                            <p style="margin: 0; font-weight: 500;">暂无课程任务</p>
                            <p style="margin: 8px 0 0 0; font-size: 12px;">教师还未添加任务内容</p>
                        </div>
                    </div>
                    
                    <!-- 数据源控件 -->
                    <asp:SqlDataSource ID="SqlDataSourceMissions" runat="server" 
                        ConnectionString="<%$ ConnectionStrings:SqlServer %>"
                        SelectCommand="SELECT Lid, Lxid, Ltype, Lsort, Ltitle, lshow FROM Listmenu WHERE Lcid = @Lcid AND (CONVERT(nvarchar(10), lshow) IN ('1','True','true')) ORDER BY Lsort">
                        <SelectParameters>
                            <asp:QueryStringParameter Name="Lcid" QueryStringField="cid" Type="Int32" DefaultValue="0" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                    
                    <!-- GridView显示课程任务列表 -->
                    <asp:GridView ID="GVlistmenu" runat="server" Width="100%"
                        AutoGenerateColumns="False" ShowHeader="False"
                        GridLines="None" BorderStyle="None" BorderWidth="0"
                        DataSourceID="SqlDataSourceMissions" DataKeyNames="Lid">
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
                            <asp:TemplateField Visible="False">
                                <ItemTemplate>
                                    <asp:Label ID="LabelLsort" runat="server" Text='<%# Bind("Lsort") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField Visible="False">
                                <ItemTemplate>
                                    <asp:Label ID="LabelLshow" runat="server" Text='<%# Bind("lshow") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div class="sc-nav-item-wrapper" data-ltype='<%# Eval("Ltype") %>' data-lxid='<%# Eval("Lxid") %>' data-lid='<%# Eval("Lid") %>'>
                                        <a href="javascript:void(0)" class="sc-nav-item" onclick="loadMissionContent(this)">
                                            <div class="sc-nav-icon" data-type='<%# Eval("Ltype") %>'>
                                                <!-- Icon will be injected by JavaScript -->
                                            </div>
                                            <div class="sc-nav-text">
                                                <div class="sc-nav-title">
                                                    <%# Eval("Ltitle") %>
                                                </div>
                                                <div class="sc-nav-status">
                                                    <span class="sc-status-badge sc-status-pending">未完成</span>
                                                </div>
                                            </div>
                                        </a>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 32px 20px; text-align: center; color: #94a3b8; font-size: 14px;">
                                <svg viewBox="0 0 24 24" style="width: 48px; height: 48px; stroke: #cbd5e1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; margin: 0 auto 12px; display: block;">
                                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                                </svg>
                                <p style="margin: 0; font-weight: 500;">暂无课程任务</p>
                                <p style="margin: 8px 0 0 0; font-size: 12px;">教师还未添加任务内容</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </aside>
    
    <!-- 右侧内容区 -->
    <main class="sc-main">
        <!-- 内容标题 -->
        <div class="sc-content-header">
            <h1 class="sc-content-title">
                <asp:Label ID="LabelContentTitle" runat="server" Text="课程内容"></asp:Label>
            </h1>
            <div class="sc-content-meta">
                <div class="sc-content-meta-item">
                    <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    <span>更新时间：2024-02-13</span>
                </div>
                <div class="sc-content-meta-item">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    <span>预计45分钟</span>
                </div>
            </div>
        </div>
        
        <!-- 课程内容 -->
        <div class="sc-content-card">
            <div id="Ccontent" class="sc-content-body" runat="server"></div>
        </div>
        
        <!-- 底部导航 -->
        <div class="sc-footer-nav">
            <a href="javascript:void(0)" id="btnPrevMission" class="sc-footer-btn" onclick="navigateMission('prev')" style="display:none;">
                <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                上一任务
            </a>
            <a href="javascript:void(0)" id="btnNextMission" class="sc-footer-btn primary" onclick="navigateMission('next')" style="display:none;">
                接下来完成
                <svg viewBox="0 0 24 24"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
            </a>
        </div>
    </main>
</div>

<script type="text/javascript">
    // 平滑滚动到顶部
    window.scrollTo({ top: 0, behavior: 'smooth' });
    
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
    
    // 处理课程任务显示
    (function() {
        // 等待DOM完全加载
        setTimeout(function() {
            // 获取导航列表容器
            var navList = document.getElementById('scNavList');
            if (!navList) return;
            
            // 获取GridView表格
            var gridView = navList.querySelector('table');
            var fallback = document.getElementById('navFallback');
            
            // 检查是否有数据
            var hasData = false;
            
            if (gridView) {
                // 查找所有tr行
                var rows = gridView.querySelectorAll('tr');
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    // 排除空行和隐藏行
                    if (row.style.display !== 'none' && row.querySelector('td')) {
                        hasData = true;
                        break;
                    }
                }
            }
            
            // 如果没有数据，显示备用提示
            if (!hasData && fallback) {
                fallback.style.display = 'block';
                return;
            }
            
            // 如果有数据，处理图标显示
            if (hasData) {
                // 处理所有导航项
                var navItems = navList.querySelectorAll('.sc-nav-item-wrapper');
                
                navItems.forEach(function(wrapper) {
                    var ltype = wrapper.getAttribute('data-ltype');
                    var iconContainer = wrapper.querySelector('.sc-nav-icon');
                    
                    if (ltype && iconContainer && iconMap[ltype]) {
                        var iconData = iconMap[ltype];
                        
                        // 清空并添加SVG图标
                        iconContainer.innerHTML = iconData.svg;
                        iconContainer.style.background = iconData.color + '20';
                        
                        var svg = iconContainer.querySelector('svg');
                        if (svg) {
                            svg.style.stroke = iconData.color;
                            svg.style.fill = 'none';
                            svg.style.strokeWidth = '2';
                            svg.style.strokeLinecap = 'round';
                            svg.style.strokeLinejoin = 'round';
                        }
                    }
                });
            }
        }, 300);
    })();
    
    // 加载任务内容
    function loadMissionContent(element) {
        var wrapper = element.closest('.sc-nav-item-wrapper');
        if (!wrapper) return;
        
        var ltype = wrapper.getAttribute('data-ltype');
        var lxid = wrapper.getAttribute('data-lxid');
        var cid = getQueryParam('cid');
        
        if (!ltype || !lxid) return;
        
        // 移除所有active类
        var allItems = document.querySelectorAll('.sc-nav-item');
        allItems.forEach(function(item) {
            item.classList.remove('active');
        });
        
        // 添加active类到当前项
        element.classList.add('active');
        
        // 构建URL
        var url = typeUrlMap[ltype];
        if (!url) {
            url = 'showmission.aspx'; // 默认URL
        }
        
        // 根据不同类型添加不同的参数
        if (ltype === '讨论') {
            url += '?tid=' + lxid;
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
        } else if (ltype === '网页') {
            url += '?wbid=' + lxid;
        } else if (ltype === '仓库') {
            url += '?wsid=' + lxid;
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
    
    // 获取URL参数
    function getQueryParam(name) {
        var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i');
        var r = window.location.search.substr(1).match(reg);
        if (r != null) {
            return decodeURIComponent(r[2]);
        }
        return null;
    }
</script>

<script type="text/javascript">
// 任务导航功能
var missionList = [];
var currentMissionIndex = -1;

// 初始化任务列表
function initMissionNavigation() {
    var navItems = document.querySelectorAll('.sc-nav-item-wrapper');
    if (navItems.length === 0) return;
    
    navItems.forEach(function(wrapper, index) {
        var link = wrapper.querySelector('.sc-nav-item');
        var title = wrapper.querySelector('.sc-nav-title');
        var ltype = wrapper.getAttribute('data-ltype');
        var lxid = wrapper.getAttribute('data-lxid');
        
        if (link && title && ltype && lxid) {
            missionList.push({
                index: index,
                title: title.textContent.trim(),
                ltype: ltype,
                lxid: lxid,
                element: link
            });
        }
    });
    
    updateNavigationButtons();
}

// 更新导航按钮
function updateNavigationButtons() {
    var btnPrev = document.getElementById('btnPrevMission');
    var btnNext = document.getElementById('btnNextMission');
    
    if (!btnPrev || !btnNext || missionList.length === 0) return;
    
    // 总是显示导航按钮（如果有任务）
    if (missionList.length > 1) {
        btnPrev.style.display = 'inline-flex';
        btnNext.style.display = 'inline-flex';
    }
}

// 导航到任务
function navigateMission(direction) {
    if (missionList.length === 0) {
        initMissionNavigation();
    }
    
    if (missionList.length === 0) return;
    
    // 找到当前active的任务
    var activeIndex = -1;
    var activeItem = document.querySelector('.sc-nav-item.active');
    if (activeItem) {
        var activeWrapper = activeItem.closest('.sc-nav-item-wrapper');
        if (activeWrapper) {
            var activeLxid = activeWrapper.getAttribute('data-lxid');
            for (var i = 0; i < missionList.length; i++) {
                if (missionList[i].lxid === activeLxid) {
                    activeIndex = i;
                    break;
                }
            }
        }
    }
    
    // 如果没有找到active项，默认从第一个开始
    if (activeIndex === -1) {
        activeIndex = 0;
    }
    
    // 计算目标索引
    var targetIndex;
    if (direction === 'prev') {
        targetIndex = activeIndex - 1;
        if (targetIndex < 0) targetIndex = missionList.length - 1; // 循环到最后一个
    } else {
        targetIndex = activeIndex + 1;
        if (targetIndex >= missionList.length) targetIndex = 0; // 循环到第一个
    }
    
    // 触发点击
    var targetMission = missionList[targetIndex];
    if (targetMission && targetMission.element) {
        targetMission.element.click();
    }
}

// 页面加载后初始化
setTimeout(initMissionNavigation, 500);
</script>
</asp:Content>
