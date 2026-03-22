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
    
    /* ========== 左侧课程导航 ========== */
    .td-left-sidebar {
        width: 280px;
        flex-shrink: 0;
    }
    
    .td-left-sticky {
        position: sticky;
        top: 80px;
        max-height: calc(100vh - 100px);
        overflow-y: auto;
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
