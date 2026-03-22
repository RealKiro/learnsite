<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" autoeventwireup="true" inherits="Student_showcourse_new" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* ===== 新课程展示页面样式 - 不使用StyleSheet.css ===== */
    /* 覆盖母版页中的StyleSheet.css样式 */
    .course-new-page,
    .course-new-page * {
        box-sizing: border-box !important;
    }
    
    .course-new-page {
        width: 100%;
        max-width: 1400px;
        margin: 0 auto;
        padding: 0;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
    }

    /* 两列布局容器 */
    .course-layout {
        display: grid;
        grid-template-columns: 0.5fr 1.5fr;
        gap: 24px;
        align-items: start;
    }

    /* 左列：课程标题和任务列表 */
    .course-left-column {
        display: flex;
        flex-direction: column;
        gap: 24px;
    }

    /* 右列：课程内容 */
    .course-right-column {
        position: sticky;
        top: 24px;
        height: fit-content;
        max-height: calc(100vh - 48px);
        overflow-y: auto;
    }
    .course-right-column::-webkit-scrollbar {
        width: 8px;
    }
    .course-right-column::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 4px;
    }
    .course-right-column::-webkit-scrollbar-thumb {
        background: #c1c1c1;
        border-radius: 4px;
    }
    .course-right-column::-webkit-scrollbar-thumb:hover {
        background: #a8a8a8;
    }

    /* 课程标题和信息合并版块 */
    .course-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 16px;
        padding: 32px 40px;
        margin-bottom: 0;
        color: #fff;
        box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
    }
    .course-header-top {
        margin-bottom: 24px;
        padding-bottom: 24px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.2);
    }
    .course-header-title {
        font-size: 28px;
        font-weight: 700;
        margin: 0 0 12px 0;
        line-height: 1.3;
    }
    .course-header-meta {
        display: flex;
        align-items: center;
        gap: 24px;
        flex-wrap: wrap;
        font-size: 14px;
        opacity: 0.95;
    }
    .course-header-meta-item {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .course-header-meta-item svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
    }
    .course-header-info {
        margin-top: 24px;
    }
    .course-info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 24px;
    }
    .course-info-item {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    .course-info-label {
        font-size: 13px;
        color: rgba(255, 255, 255, 0.8);
        font-weight: 500;
    }
    .course-info-value {
        font-size: 20px;
        font-weight: 700;
        color: #fff;
    }

    /* 进度条 */
    .course-progress {
        margin-top: 20px;
    }
    .course-progress-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
    }
    .course-progress-label {
        font-size: 14px;
        font-weight: 600;
        color: rgba(255, 255, 255, 0.9);
    }
    .course-progress-text {
        font-size: 16px;
        font-weight: 700;
        color: #fff;
    }
    .course-progress-bar-wrapper {
        height: 10px;
        background: rgba(255, 255, 255, 0.2);
        border-radius: 10px;
        overflow: hidden;
        position: relative;
    }
    .course-progress-bar {
        height: 100%;
        background: linear-gradient(90deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
        border-radius: 10px;
        transition: width 0.3s ease;
        position: relative;
    }
    .course-progress-bar::after {
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

    /* 课程内容区域 */
    .course-content-wrapper {
        background: #fff;
        border-radius: 12px;
        padding: 32px;
        margin-bottom: 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        border: 1px solid #e5e7eb;
    }
    .course-content-title {
        font-size: 20px;
        font-weight: 700;
        color: #1f2937;
        margin: 0 0 20px 0;
        padding-bottom: 12px;
        border-bottom: 2px solid #e5e7eb;
    }
    .course-content-body {
        font-size: 15px;
        line-height: 1.8;
        color: #374151;
    }
    .course-content-body * {
        max-width: 100%;
    }
    .course-content-body img {
        border-radius: 8px;
        margin: 16px 0;
    }
    .course-content-body p {
        margin: 12px 0;
    }
    .course-content-body h1,
    .course-content-body h2,
    .course-content-body h3 {
        margin: 20px 0 12px 0;
        color: #1f2937;
    }

    /* 任务列表 */
    .course-tasks {
        background: #fff;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        border: 1px solid #e5e7eb;
    }
    .course-tasks-title {
        font-size: 20px;
        font-weight: 700;
        color: #1f2937;
        margin: 0 0 20px 0;
        padding-bottom: 12px;
        border-bottom: 2px solid #e5e7eb;
    }
    .course-tasks-list {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 16px;
    }
    .course-task-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 16px;
        background: #f9fafb;
        border: 1px solid #e5e7eb;
        border-radius: 10px;
        text-decoration: none;
        color: inherit;
        transition: all 0.2s;
        position: relative;
        overflow: hidden;
    }
    .course-task-item::before {
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
    .course-task-item:hover {
        background: #f3f4f6;
        border-color: #6366f1;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.15);
    }
    .course-task-item:hover::before {
        transform: scaleY(1);
    }
    .course-task-number {
        width: 32px;
        height: 32px;
        background: #6366f1;
        color: #fff;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        font-weight: 700;
        flex-shrink: 0;
    }
    .course-task-icon {
        width: 40px;
        height: 40px;
        background: #eef2ff;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        color: #6366f1;
    }
    .course-task-icon svg {
        width: 20px;
        height: 20px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
    }
    .course-task-content {
        flex: 1;
        min-width: 0;
    }
    .course-task-title {
        font-size: 15px;
        font-weight: 600;
        color: #1f2937;
        margin: 0 0 4px 0;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
    .course-task-type {
        font-size: 12px;
        color: #6b7280;
    }
    .course-tasks-empty {
        text-align: center;
        padding: 60px 20px;
        color: #9ca3af;
    }
    .course-tasks-empty-icon {
        font-size: 48px;
        margin-bottom: 12px;
    }
    .course-tasks-empty-text {
        font-size: 15px;
    }

    /* 响应式设计 */
    @media (max-width: 1024px) {
        .course-layout {
            grid-template-columns: 1fr;
        }
        .course-right-column {
            position: static;
            max-height: none;
        }
    }
    @media (max-width: 768px) {
        .course-header {
            padding: 24px 20px;
        }
        .course-header-top {
            margin-bottom: 20px;
            padding-bottom: 20px;
        }
        .course-header-title {
            font-size: 22px;
        }
        .course-header-info {
            margin-top: 20px;
        }
        .course-info-grid {
            grid-template-columns: 1fr;
            gap: 16px;
            margin-bottom: 20px;
        }
        .course-content-wrapper {
            padding: 20px;
        }
        .course-tasks-list {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="course-new-page">
    <div class="course-layout">
        <!-- 左列：课程标题和任务列表 -->
        <div class="course-left-column">
            <!-- 课程标题和信息合并版块 -->
            <div class="course-header">
                <div class="course-header-top">
                    <h1 class="course-header-title" id="courseName" runat="server">加载中...</h1>
                    <div class="course-header-meta">
                        <div class="course-header-meta-item">
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <span id="courseTeacher" runat="server">教师</span>
                        </div>
                        <div class="course-header-meta-item">
                            <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                            <span>任务数: <span id="taskCount" runat="server">0</span></span>
                        </div>
                    </div>
                </div>
                <div class="course-header-info">
                    <div class="course-info-grid">
                        <div class="course-info-item">
                            <span class="course-info-label">已完成任务</span>
                            <span class="course-info-value" id="taskCompleted" runat="server">0</span>
                        </div>
                        <div class="course-info-item">
                            <span class="course-info-label">总任务数</span>
                            <span class="course-info-value" id="taskTotal" runat="server">0</span>
                        </div>
                    </div>
                    <div class="course-progress">
                        <div class="course-progress-header">
                            <span class="course-progress-label">学习进度</span>
                            <span class="course-progress-text" id="progressText" runat="server">0%</span>
                        </div>
                        <div class="course-progress-bar-wrapper">
                            <div class="course-progress-bar" id="progressBar" runat="server" style="width: 0%;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 任务列表 -->
            <div class="course-tasks">
                <h2 class="course-tasks-title">课程任务</h2>
                <div class="course-tasks-list" id="courseTasks" runat="server">
                    <div class="course-tasks-empty">
                        <div class="course-tasks-empty-icon">📋</div>
                        <div class="course-tasks-empty-text">加载中...</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 右列：课程内容区域 -->
        <div class="course-right-column">
            <div class="course-content-wrapper">
                <h2 class="course-content-title">
                    <asp:Label ID="LabelCtitle" runat="server" Text="课程内容"></asp:Label>
                </h2>
                <div class="course-content-body" id="Ccontent" runat="server">
                    <div style="text-align: center; padding: 40px; color: #9ca3af;">加载中...</div>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>

