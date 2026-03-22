<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_coursedel, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* 删除确认页面美化 */
    .del-page {
        max-width: 600px;
        margin: 60px auto;
        padding: 20px;
        animation: delFadeIn 0.4s ease;
    }
    
    @keyframes delFadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .del-card {
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.08);
        overflow: hidden;
        border: 1px solid #fee;
    }
    
    /* 警告头部 */
    .del-header {
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        padding: 32px;
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    
    .del-header::before {
        content: '';
        position: absolute;
        top: -50px;
        right: -50px;
        width: 150px;
        height: 150px;
        background: rgba(255,255,255,0.1);
        border-radius: 50%;
    }
    
    .del-icon {
        width: 80px;
        height: 80px;
        margin: 0 auto 16px;
        background: rgba(255,255,255,0.2);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        backdrop-filter: blur(4px);
        position: relative;
        z-index: 1;
    }
    
    .del-icon svg {
        width: 40px;
        height: 40px;
        stroke: #fff;
        fill: none;
        stroke-width: 2.5;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .del-header-title {
        font-size: 24px;
        font-weight: 700;
        color: #fff;
        margin: 0;
        position: relative;
        z-index: 1;
        text-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    /* 内容区域 */
    .del-body {
        padding: 40px 32px;
        text-align: center;
    }
    
    .del-course-name {
        font-size: 18px;
        font-weight: 600;
        color: #1e293b;
        margin-bottom: 24px;
        padding: 16px 20px;
        background: #fef2f2;
        border: 2px solid #fecaca;
        border-radius: 12px;
        display: inline-block;
        max-width: 100%;
        word-break: break-word;
    }
    
    .del-message {
        font-size: 16px;
        color: #64748b;
        line-height: 1.6;
        margin-bottom: 32px;
    }
    
    .del-warning {
        background: #fff7ed;
        border: 2px solid #fed7aa;
        border-radius: 12px;
        padding: 16px 20px;
        margin-bottom: 32px;
        display: flex;
        align-items: flex-start;
        gap: 12px;
        text-align: left;
    }
    
    .del-warning-icon {
        width: 24px;
        height: 24px;
        flex-shrink: 0;
        margin-top: 2px;
    }
    
    .del-warning-icon svg {
        width: 24px;
        height: 24px;
        stroke: #f59e0b;
        fill: none;
        stroke-width: 2.5;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    
    .del-warning-text {
        flex: 1;
        font-size: 14px;
        color: #92400e;
        line-height: 1.6;
    }
    
    .del-warning-text strong {
        font-weight: 700;
        color: #78350f;
    }
    
    /* 按钮区域 */
    .del-actions {
        display: flex;
        gap: 12px;
        justify-content: center;
        flex-wrap: wrap;
    }
    
    .del-btn {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 8px !important;
        padding: 14px 32px !important;
        border-radius: 10px !important;
        font-size: 15px !important;
        font-weight: 600 !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        border: none !important;
        min-width: 140px !important;
        text-decoration: none !important;
    }
    
    .del-btn-danger {
        background: linear-gradient(135deg, #ef4444, #dc2626) !important;
        color: #fff !important;
        box-shadow: 0 4px 12px rgba(239,68,68,0.3) !important;
    }
    
    .del-btn-danger:hover {
        background: linear-gradient(135deg, #dc2626, #b91c1c) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 16px rgba(239,68,68,0.4) !important;
    }
    
    .del-btn-danger:active {
        transform: translateY(0) !important;
    }
    
    .del-btn-cancel {
        background: #f1f5f9 !important;
        color: #475569 !important;
        border: 2px solid #e2e8f0 !important;
    }
    
    .del-btn-cancel:hover {
        background: #e2e8f0 !important;
        color: #334155 !important;
        border-color: #cbd5e1 !important;
        transform: translateY(-2px) !important;
    }
    
    .del-btn-cancel:active {
        transform: translateY(0) !important;
    }
    
    /* 响应式 */
    @media (max-width: 640px) {
        .del-page {
            margin: 20px auto;
            padding: 10px;
        }
        
        .del-header {
            padding: 24px 20px;
        }
        
        .del-icon {
            width: 64px;
            height: 64px;
        }
        
        .del-icon svg {
            width: 32px;
            height: 32px;
        }
        
        .del-header-title {
            font-size: 20px;
        }
        
        .del-body {
            padding: 28px 20px;
        }
        
        .del-course-name {
            font-size: 16px;
            padding: 12px 16px;
        }
        
        .del-message {
            font-size: 14px;
        }
        
        .del-actions {
            flex-direction: column;
        }
        
        .del-btn {
            width: 100% !important;
        }
    }
</style>

<div class="del-page">
    <div class="del-card">
        <!-- 警告头部 -->
        <div class="del-header">
            <div class="del-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                    <line x1="12" y1="9" x2="12" y2="13"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
            </div>
            <h1 class="del-header-title">删除课程确认</h1>
        </div>
        
        <!-- 内容区域 -->
        <div class="del-body">
            <div class="del-course-name">
                <asp:Label ID="LabelID" runat="server" Font-Bold="False"></asp:Label>
            </div>
            
            <p class="del-message">
                您确定要删除这个课程吗？
            </p>
            
            <div class="del-warning">
                <div class="del-warning-icon">
                    <svg viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                </div>
                <div class="del-warning-text">
                    <strong>警告：</strong>删除操作不可恢复！课程相关的所有内容（包括活动、讨论、作业等）都将被永久删除。请谨慎操作。
                </div>
            </div>
            
            <div class="del-actions">
                <asp:Button ID="ButtonDel" runat="server" Text="确认删除" 
                    OnClick="ButtonDel_Click" CssClass="del-btn del-btn-danger" />
                <asp:Button ID="ButtonCancle" runat="server" Text="取消" 
                    OnClick="ButtonCancle_Click" CssClass="del-btn del-btn-cancel" />
            </div>
        </div>
    </div>
</div>
</asp:Content>

