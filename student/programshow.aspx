<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" autoeventwireup="true" inherits="Student_programshow_new" validaterequest="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
    <link href="../kindeditor/themes/me/me.css" rel="stylesheet" type="text/css" />
    <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
    <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
    <style>
        /* ===== 编程任务详情页面样式 - 使用母版页 ===== */
        .sm-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0;
        }
        
        /* 标题区域 */
        .sm-title-card {
            background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
            border-radius: 20px;
            padding: 32px 40px;
            margin-bottom: 32px;
            box-shadow: 0 8px 32px rgba(5,150,105,.35);
            position: relative;
            overflow: hidden;
        }
        
        .sm-title-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,.15) 0%, transparent 60%);
            animation: float 6s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translate(0, 0); }
            50% { transform: translate(30px, 30px); }
        }
        
        .sm-title {
            font-size: 28px;
            font-weight: 800;
            color: #fff;
            margin: 0 0 8px 0;
            position: relative;
            z-index: 1;
            text-shadow: 0 2px 8px rgba(0,0,0,.15);
        }
        
        .sm-title-sub {
            font-size: 14px;
            color: rgba(255,255,255,.85);
            margin: 0;
            position: relative;
            z-index: 1;
        }
        
        /* 内容区域 */
        .sm-content-wrapper {
            display: grid;
            grid-template-columns: 0.5fr 1.5fr 320px;
            gap: 24px;
            margin-bottom: 32px;
        }
        
        @media (max-width: 1200px) {
            .sm-content-wrapper {
                grid-template-columns: 0.5fr 1.5fr;
            }
            .sm-sidebar {
                grid-column: 1 / -1;
                position: static;
            }
        }
        
        @media (max-width: 968px) {
            .sm-content-wrapper {
                grid-template-columns: 1fr;
            }
        }
        
        /* 左侧课程信息区域 */
        .sm-left-column {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }
        
        /* 课程标题和信息合并版块 */
        .sm-course-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px;
            padding: 32px 40px;
            color: #fff;
            box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
        }
        .sm-course-header-top {
            margin-bottom: 24px;
            padding-bottom: 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .sm-course-header-title {
            font-size: 28px;
            font-weight: 700;
            margin: 0 0 12px 0;
            line-height: 1.3;
        }
        .sm-course-header-meta {
            display: flex;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
            font-size: 14px;
            opacity: 0.95;
        }
        .sm-course-header-meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .sm-course-header-meta-item svg {
            width: 16px;
            height: 16px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
        }
        .sm-course-header-info {
            margin-top: 24px;
        }
        .sm-course-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }
        .sm-course-info-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .sm-course-info-label {
            font-size: 13px;
            color: rgba(255, 255, 255, 0.8);
            font-weight: 500;
        }
        .sm-course-info-value {
            font-size: 20px;
            font-weight: 700;
            color: #fff;
        }
        
        /* 进度条 */
        .sm-course-progress {
            margin-top: 20px;
        }
        .sm-course-progress-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }
        .sm-course-progress-label {
            font-size: 14px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
        }
        .sm-course-progress-text {
            font-size: 16px;
            font-weight: 700;
            color: #fff;
        }
        .sm-course-progress-bar-wrapper {
            height: 10px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            overflow: hidden;
            position: relative;
        }
        .sm-course-progress-bar {
            height: 100%;
            background: linear-gradient(90deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
            border-radius: 10px;
            transition: width 0.3s ease;
            position: relative;
        }
        .sm-course-progress-bar::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 2s infinite;
        }
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        /* 任务列表 */
        .sm-course-tasks {
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 1px solid #e5e7eb;
        }
        .sm-course-tasks-title {
            font-size: 20px;
            font-weight: 700;
            color: #1f2937;
            margin: 0 0 20px 0;
            padding-bottom: 12px;
            border-bottom: 2px solid #e5e7eb;
        }
        .sm-course-tasks-list {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
        }
        .sm-course-task-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            text-decoration: none;
            color: inherit;
            transition: all 0.2s;
            position: relative;
            overflow: hidden;
        }
        .sm-course-task-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: #6366f1;
            transform: scaleY(0);
            transition: transform 0.2s;
        }
        .sm-course-task-item:hover {
            background: #f3f4f6;
            border-color: #6366f1;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.15);
        }
        .sm-course-task-item:hover::before {
            transform: scaleY(1);
        }
        .sm-course-task-number {
            width: 28px;
            height: 28px;
            background: #6366f1;
            color: #fff;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0;
        }
        .sm-course-task-icon {
            width: 36px;
            height: 36px;
            background: #eef2ff;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            color: #6366f1;
        }
        .sm-course-task-icon svg {
            width: 18px;
            height: 18px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
        }
        .sm-course-task-content {
            flex: 1;
            min-width: 0;
        }
        .sm-course-task-title {
            font-size: 14px;
            font-weight: 600;
            color: #1f2937;
            margin: 0 0 4px 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .sm-course-task-type {
            font-size: 12px;
            color: #6b7280;
        }
        .sm-course-tasks-empty {
            text-align: center;
            padding: 40px 20px;
            color: #9ca3af;
        }
        .sm-course-tasks-empty-icon {
            font-size: 36px;
            margin-bottom: 12px;
        }
        .sm-course-tasks-empty-text {
            font-size: 14px;
        }
        
        /* 主内容区 */
        .sm-main-content {
            background: #ffffff;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,.04), 0 8px 24px rgba(0,0,0,.03);
            border: 1px solid rgba(229,231,235,.8);
        }
        
        /* 任务信息卡片 */
        .sm-task-info-card {
            background: #f8fafc;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 32px;
            border: 1px solid #e5e7eb;
        }
        .sm-task-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .sm-task-info-item {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .sm-task-info-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            background: #fff;
            border: 1px solid #e5e7eb;
        }
        .sm-task-info-icon svg {
            width: 20px;
            height: 20px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
        }
        .sm-task-info-icon.date svg { stroke: #3b82f6; }
        .sm-task-info-icon.type svg { stroke: #10b981; }
        .sm-task-info-icon.example svg { stroke: #8b5cf6; }
        .sm-task-info-icon.standard svg { stroke: #f59e0b; }
        .sm-task-info-content {
            flex: 1;
        }
        .sm-task-info-label {
            font-size: 12px;
            color: #6b7280;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .sm-task-info-value {
            font-size: 14px;
            color: #1f2937;
            font-weight: 600;
        }
        .sm-task-info-value a {
            color: #10b981;
            text-decoration: none;
            transition: all 0.2s;
        }
        .sm-task-info-value a:hover {
            color: #059669;
            text-decoration: underline;
        }
        
        /* 隐藏图片 */
        .sm-task-info-item img,
        img[id*="ImageType"] {
            display: none !important;
        }
        
        .sm-task-content {
            font-size: 16px;
            color: #334155;
            line-height: 1.9;
        }
        
        .sm-task-content h1,
        .sm-task-content h2,
        .sm-task-content h3 {
            color: #1e293b;
            font-weight: 700;
            margin-top: 32px;
            margin-bottom: 16px;
            padding-left: 20px;
            border-left: 5px solid #10b981;
        }
        
        .sm-task-content h1 { font-size: 32px; }
        .sm-task-content h2 { font-size: 26px; }
        .sm-task-content h3 { font-size: 22px; }
        
        .sm-task-content p {
            margin-bottom: 16px;
        }
        
        .sm-task-content img {
            max-width: 100%;
            height: auto;
            border-radius: 12px;
            margin: 24px 0;
        }
        
        /* 侧边栏 */
        .sm-sidebar {
            background: #ffffff;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,.04), 0 8px 24px rgba(0,0,0,.03);
            border: 1px solid rgba(229,231,235,.8);
            height: fit-content;
            position: sticky;
            top: 24px;
        }
        
        .sm-sidebar-section {
            margin-bottom: 24px;
            padding-bottom: 24px;
            border-bottom: 1px solid #f1f5f9;
        }
        
        .sm-sidebar-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .sm-sidebar-title {
            font-size: 16px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .sm-sidebar-title::before {
            content: '';
            width: 4px;
            height: 16px;
            background: linear-gradient(180deg, #10b981, #34d399);
            border-radius: 2px;
        }
        
        /* 按钮样式 */
        .sm-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 24px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            margin-bottom: 12px;
        }
        
        .sm-btn-primary {
            background: linear-gradient(135deg, #10b981, #059669);
            color: #fff;
            box-shadow: 0 4px 12px rgba(16,185,129,.3);
        }
        
        .sm-btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(16,185,129,.4);
        }
        
        .sm-btn-secondary {
            background: #f8fafc;
            color: #475569;
            border: 1px solid #e2e8f0;
        }
        
        .sm-btn-secondary:hover {
            background: #f1f5f9;
            border-color: #cbd5e1;
        }
        
        .sm-btn svg {
            width: 16px;
            height: 16px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
        }
        .sm-debug {
            margin-top: 8px;
            padding: 10px 12px;
            border-radius: 10px;
            background: #fff7ed;
            border: 1px solid #fdba74;
            color: #9a3412;
            font-size: 12px;
            line-height: 1.5;
            word-break: break-all;
        }
        
        /* 响应式 */
        @media (max-width: 768px) {
            .sm-container {
                padding: 16px;
            }
            
            .sm-title-card {
                padding: 24px;
            }
            
            .sm-title {
                font-size: 24px;
            }
            
            .sm-main-content {
                padding: 24px;
            }
            
            .sm-sidebar {
                position: static;
            }
            
            .sm-course-header {
                padding: 24px 20px;
            }
            
            .sm-course-header-top {
                margin-bottom: 20px;
                padding-bottom: 20px;
            }
            
            .sm-course-header-title {
                font-size: 22px;
            }
            
            .sm-course-header-info {
                margin-top: 20px;
            }
            
            .sm-course-info-grid {
                grid-template-columns: 1fr;
                gap: 16px;
                margin-bottom: 20px;
            }
            
            .sm-task-info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    
    <div class="sm-container">
        <!-- 标题区域 -->
        <div class="sm-title-card">
            <h1 class="sm-title">
                <asp:Label ID="LabelMtitle" runat="server"></asp:Label>
            </h1>
            <p class="sm-title-sub">查看编程任务详情，包括任务要求、实例和评价标准</p>
        </div>
        
        <div class="sm-content-wrapper">
            <!-- 左侧：课程信息和任务列表 -->
            <div class="sm-left-column">
                <!-- 课程标题和信息合并版块 -->
                <div class="sm-course-header">
                    <div class="sm-course-header-top">
                        <h1 class="sm-course-header-title" id="courseName" runat="server">加载中...</h1>
                        <div class="sm-course-header-meta">
                            <div class="sm-course-header-meta-item">
                                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                <span id="courseTeacher" runat="server">教师</span>
                            </div>
                            <div class="sm-course-header-meta-item">
                                <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                                <span>任务数: <span id="taskCount" runat="server">0</span></span>
                            </div>
                        </div>
                    </div>
                    <div class="sm-course-header-info">
                        <div class="sm-course-info-grid">
                            <div class="sm-course-info-item">
                                <span class="sm-course-info-label">已完成任务</span>
                                <span class="sm-course-info-value" id="taskCompleted" runat="server">0</span>
                            </div>
                            <div class="sm-course-info-item">
                                <span class="sm-course-info-label">总任务数</span>
                                <span class="sm-course-info-value" id="taskTotal" runat="server">0</span>
                            </div>
                        </div>
                        <div class="sm-course-progress">
                            <div class="sm-course-progress-header">
                                <span class="sm-course-progress-label">学习进度</span>
                                <span class="sm-course-progress-text" id="progressText" runat="server">0%</span>
                            </div>
                            <div class="sm-course-progress-bar-wrapper">
                                <div class="sm-course-progress-bar" id="progressBar" runat="server" style="width: 0%;"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 任务列表 -->
                <div class="sm-course-tasks">
                    <h2 class="sm-course-tasks-title">课程任务</h2>
                    <div class="sm-course-tasks-list" id="courseTasks" runat="server">
                        <div class="sm-course-tasks-empty">
                            <div class="sm-course-tasks-empty-icon">📋</div>
                            <div class="sm-course-tasks-empty-text">加载中...</div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- 主内容区 -->
            <div class="sm-main-content">
                <!-- 任务信息卡片 -->
                <div class="sm-task-info-card">
                    <div class="sm-task-info-grid">
                        <!-- 日期 -->
                        <div class="sm-task-info-item">
                            <div class="sm-task-info-icon date">
                                <svg viewBox="0 0 24 24">
                                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                                    <line x1="16" y1="2" x2="16" y2="6"/>
                                    <line x1="8" y1="2" x2="8" y2="6"/>
                                    <line x1="3" y1="10" x2="21" y2="10"/>
                                </svg>
                            </div>
                            <div class="sm-task-info-content">
                                <div class="sm-task-info-label">日期</div>
                                <div class="sm-task-info-value">
                                    <asp:Label ID="LabelMdate" runat="server"></asp:Label>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 作品类型 -->
                        <div class="sm-task-info-item">
                            <div class="sm-task-info-icon type">
                                <svg viewBox="0 0 24 24">
                                    <polyline points="16 18 22 12 16 6"/>
                                    <polyline points="8 6 2 12 8 18"/>
                                </svg>
                            </div>
                            <div class="sm-task-info-content">
                                <div class="sm-task-info-label">作品类型</div>
                                <div class="sm-task-info-value">
                                    <asp:Image ID="ImageType" runat="server" Visible="False" />
                                    <asp:Label ID="LabelMfiletype" runat="server"></asp:Label>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 实例 -->
                        <div class="sm-task-info-item">
                            <div class="sm-task-info-icon example">
                                <svg viewBox="0 0 24 24">
                                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                    <polyline points="14 2 14 8 20 8"/>
                                    <line x1="16" y1="13" x2="8" y2="13"/>
                                    <line x1="16" y1="17" x2="8" y2="17"/>
                                    <polyline points="10 9 9 9 8 9"/>
                                </svg>
                            </div>
                            <div class="sm-task-info-content">
                                <div class="sm-task-info-label">实例</div>
                                <div class="sm-task-info-value">
                                    <asp:HyperLink ID="Hlexample" runat="server">查看实例</asp:HyperLink>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 评价标准 -->
                        <div class="sm-task-info-item">
                            <div class="sm-task-info-icon standard">
                                <svg viewBox="0 0 24 24">
                                    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                                </svg>
                            </div>
                            <div class="sm-task-info-content">
                                <div class="sm-task-info-label">评价标准</div>
                                <div class="sm-task-info-value">
                                    <asp:HyperLink ID="HLMgid" runat="server">查看标准</asp:HyperLink>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 任务内容 -->
                <div id="Mcontent" class="sm-task-content" runat="server"></div>
            </div>
            
            <!-- 侧边栏 -->
            <div class="sm-sidebar">
                <!-- 隐藏字段 -->
                <asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
                <asp:Label ID="LabelMid" runat="server" Visible="False"></asp:Label>
                <asp:Label ID="LabelMcid" runat="server" Visible="False"></asp:Label>
                
                <!-- 快捷操作 -->
                <div class="sm-sidebar-section">
                    <div class="sm-sidebar-title">快捷操作</div>
                    <button type="button" class="sm-btn sm-btn-secondary" onclick="showShare()">
                        <svg viewBox="0 0 24 24">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                            <polyline points="17 8 12 3 7 8"/>
                            <line x1="12" y1="3" x2="12" y2="15"/>
                        </svg>
                        我的网盘
                    </button>
                </div>
                
                <!-- 返回按钮 -->
                <div class="sm-sidebar-section">
                    <div class="sm-sidebar-title">导航</div>
                    <asp:LinkButton ID="LinkBtn" runat="server" OnClick="LinkBtn_Click" CssClass="sm-btn sm-btn-primary">
                        <svg viewBox="0 0 24 24">
                            <path d="M19 12H5M12 19l-7-7 7-7"/>
                        </svg>
                        返回课程
                    </asp:LinkButton>
                    <% if ("1".Equals(Request.QueryString["debug"])) { %>
                    <div class="sm-debug">
                        DEBUG: return =&gt;
                        <%=
                            "/student/txtformresult.aspx?lid=" + Server.UrlEncode(Request.QueryString["lid"] ?? "") +
                            "&mid=" + Server.UrlEncode(Request.QueryString["mid"] ?? "") +
                            "&mcid=" + Server.UrlEncode(Request.QueryString["mcid"] ?? "") +
                            "&debug=" + Server.UrlEncode(string.IsNullOrEmpty(Request.QueryString["debug"]) ? "1" : Request.QueryString["debug"]) +
                            "&from=programshow"
                        %>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        // 页面加载时检查网盘状态并更新按钮
        (function() {
            fetch('CheckNetdiskStatus.ashx')
                .then(response => response.json())
                .then(data => {
                    if (!data.enabled) {
                        var shareButtons = document.querySelectorAll('#share, .sharedisk');
                        shareButtons.forEach(function(btn) {
                            btn.disabled = true;
                            btn.value = '网盘未开启';
                            btn.style.background = '#e5e7eb';
                            btn.style.color = '#9ca3af';
                            btn.style.cursor = 'not-allowed';
                            btn.style.opacity = '0.6';
                            btn.style.borderColor = '#d1d5db';
                        });
                    }
                })
                .catch(err => {
                    console.error('检查网盘状态失败:', err);
                });
        })();
        
        function showShare() {
            // 检查网盘开关状态
            fetch('CheckNetdiskStatus.ashx')
                .then(response => response.json())
                .then(data => {
                    if (data.enabled) {
                        window.location.href = "groupshare.aspx";
                    } else {
                        // 禁用状态下不执行任何操作
                        return;
                    }
                })
                .catch(err => {
                    console.error('检查网盘状态失败:', err);
                    // 出错时默认允许访问
                    window.location.href = "groupshare.aspx";
                });
        }
    </script>
</asp:Content>
