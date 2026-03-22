<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_programshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<style>
    /* ===== 编程展示页面美化 (参照 topicadd) ===== */
    .ps-container {
        max-width: 1440px !important;
        width: 100% !important;
        margin: 0 auto !important;
        padding: 0 !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: fadeIn 0.5s ease-in-out;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* ===== 渐变标题栏 (绿色主题) ===== */
    .ps-title-card {
        display: flex !important;
        align-items: center !important;
        gap: 20px !important;
        margin-bottom: 28px !important;
        padding: 28px 32px !important;
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%) !important;
        border-radius: 16px !important;
        position: relative !important;
        overflow: hidden !important;
        box-shadow: 0 4px 20px rgba(5,150,105,.25) !important;
    }
    
    .ps-title-card::before {
        content: '' !important;
        position: absolute !important;
        top: -30px !important;
        right: -30px !important;
        width: 120px !important;
        height: 120px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.08) !important;
    }
    
    .ps-title-card::after {
        content: '' !important;
        position: absolute !important;
        bottom: -40px !important;
        right: 60px !important;
        width: 160px !important;
        height: 160px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.05) !important;
    }
    
    .ps-title-icon {
        width: 52px !important;
        height: 52px !important;
        background: rgba(255,255,255,.18) !important;
        border-radius: 14px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        backdrop-filter: blur(10px) !important;
        flex-shrink: 0 !important;
        position: relative !important;
        z-index: 1 !important;
    }
    
    .ps-title-icon svg {
        width: 26px !important;
        height: 26px !important;
        stroke: #fff !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .ps-title-text {
        position: relative !important;
        z-index: 1 !important;
        flex: 1 !important;
    }
    
    .ps-title {
        font-size: 22px !important;
        font-weight: 700 !important;
        color: #fff !important;
        margin: 0 0 4px 0 !important;
        line-height: 1.3 !important;
    }
    
    .ps-title-sub {
        font-size: 13px !important;
        color: rgba(255,255,255,.75) !important;
        margin: 0 !important;
    }
    
    /* ===== 信息卡片 ===== */
    .ps-info-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
        transition: box-shadow .2s, transform .2s !important;
    }
    
    .ps-info-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
        transform: translateY(-1px) !important;
    }
    
    .ps-card-head {
        padding: 16px 24px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important;
        align-items: center !important;
        gap: 10px !important;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%) !important;
    }
    
    .ps-card-head .ps-dot {
        width: 8px !important;
        height: 8px !important;
        border-radius: 50% !important;
        background: linear-gradient(135deg, #059669, #34d399) !important;
        flex-shrink: 0 !important;
    }
    
    .ps-card-head h3 {
        font-size: 15px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        margin: 0 !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        flex: 1 !important;
    }
    
    .ps-card-head h3 svg {
        width: 18px !important;
        height: 18px !important;
        stroke: #059669 !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .ps-card-body {
        padding: 24px 28px !important;
    }
    
    .ps-info-grid {
        display: grid !important;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)) !important;
        gap: 24px !important;
        margin-bottom: 8px !important;
    }
    
    .ps-info-item {
        display: flex !important;
        align-items: center !important;
        gap: 14px !important;
        padding: 12px !important;
        border-radius: 12px !important;
        transition: all 0.3s ease;
    }
    
    .ps-info-item:hover {
        background: #f8fafc !important;
        transform: translateX(4px);
    }
    
    .ps-info-icon {
        width: 48px !important;
        height: 48px !important;
        border-radius: 12px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        flex-shrink: 0 !important;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06) !important;
        transition: all 0.3s ease;
        background: #f8fafc !important;
        border: 1px solid #e2e8f0 !important;
    }
    
    .ps-info-icon:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.1) !important;
        border-color: #cbd5e1 !important;
    }
    
    /* 移除渐变背景，使用统一的浅色背景 */
    .ps-info-icon.date,
    .ps-info-icon.type,
    .ps-info-icon.example,
    .ps-info-icon.standard {
        background: #f8fafc !important;
        border: 1px solid #e2e8f0 !important;
    }
    
    .ps-info-icon svg {
        width: 22px !important;
        height: 22px !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
        fill: none !important;
    }
    
    .ps-info-icon.date svg { stroke: #3b82f6 !important; }
    .ps-info-icon.type svg { stroke: #10b981 !important; }
    .ps-info-icon.example svg { stroke: #8b5cf6 !important; }
    .ps-info-icon.standard svg { stroke: #f59e0b !important; }
    
    /* 隐藏作品类型中的图片 */
    .ps-info-value img {
        display: none !important;
    }
    
    .ps-info-content {
        flex: 1 !important;
        min-width: 0 !important;
    }
    
    .ps-info-label {
        font-size: 12px !important;
        color: #64748b !important;
        font-weight: 600 !important;
        margin-bottom: 6px !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    
    .ps-info-value {
        font-size: 15px !important;
        color: #1e293b !important;
        font-weight: 600 !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
    }
    
    .ps-info-value img {
        width: 20px !important;
        height: 20px !important;
        object-fit: contain !important;
    }
    
    .ps-info-value a {
        color: #10b981 !important;
        text-decoration: none !important;
        border-bottom: 2px solid transparent !important;
        transition: all 0.2s ease !important;
        font-weight: 600 !important;
        padding-bottom: 2px !important;
    }
    
    .ps-info-value a:hover {
        color: #059669 !important;
        border-bottom-color: #10b981 !important;
        transform: translateY(-1px);
    }
    
    /* ===== 选项区域 ===== */
    .ps-options {
        display: flex !important;
        flex-wrap: wrap !important;
        gap: 16px !important;
        padding-top: 20px !important;
        border-top: 1px solid #f1f5f9 !important;
        margin-top: 20px !important;
    }
    
    .ps-option-item {
        display: flex !important;
        align-items: center !important;
        gap: 10px !important;
        padding: 10px 18px !important;
        background: #f8fafc !important;
        border: 1px solid #e5e7eb !important;
        border-radius: 10px !important;
        font-size: 13px !important;
        color: #475569 !important;
        transition: all 0.3s ease !important;
        cursor: default !important;
    }
    
    .ps-option-item:hover {
        background: #f1f5f9 !important;
        border-color: #cbd5e1 !important;
        transform: translateY(-1px);
        box-shadow: 0 2px 8px rgba(0,0,0,0.06) !important;
    }
    
    .ps-option-item input[type="checkbox"] {
        width: 20px !important;
        height: 20px !important;
        cursor: pointer !important;
        accent-color: #10b981 !important;
        border-radius: 4px !important;
    }
    
    .ps-option-item label {
        font-weight: 500 !important;
        cursor: default !important;
    }
    
    .ps-option-item:has(input:checked) {
        background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important;
        border-color: #6ee7b7 !important;
        color: #065f46 !important;
        font-weight: 600 !important;
        box-shadow: 0 2px 8px rgba(16,185,129,0.15) !important;
    }
    
    /* ===== 操作按钮区域 ===== */
    .ps-actions {
        display: flex;
        align-items: center;
        gap: 12px;
        padding-top: 20px;
        border-top: 1px solid #f1f5f9;
        margin-top: 20px;
    }
    
    .ps-btn {
        position: relative;
        padding: 12px 24px 12px 52px;
        border-radius: 12px;
        font-size: 15px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        text-indent: 0 !important;
        overflow: visible !important;
    }
    
    .ps-btn:hover {
        transform: translateY(-2px);
    }
    
    /* 隐藏原始图片 */
    .ps-btn[src] {
        width: auto !important;
        height: auto !important;
        content: attr(alt);
    }
    
    /* 使用伪元素添加SVG图标 */
    .ps-btn::before {
        content: '';
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        width: 20px;
        height: 20px;
        background-size: contain;
        background-position: center;
        background-repeat: no-repeat;
    }
    
    .ps-btn-edit {
        background: linear-gradient(135deg, #fef3c7, #fde68a) !important;
        color: #92400e !important;
        border: 1px solid #fde68a !important;
    }
    
    .ps-btn-edit::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2392400e' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'/%3E%3Cpath d='M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'/%3E%3C/svg%3E");
    }
    
    .ps-btn-edit:hover {
        background: linear-gradient(135deg, #fde68a, #fcd34d) !important;
        box-shadow: 0 6px 16px rgba(245,158,11,0.25) !important;
        color: #92400e !important;
    }
    
    .ps-btn-return {
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0) !important;
        color: #475569 !important;
        border: 1px solid #cbd5e1 !important;
    }
    
    .ps-btn-return::before {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23475569' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cline x1='19' y1='12' x2='5' y2='12'/%3E%3Cpolyline points='12 19 5 12 12 5'/%3E%3C/svg%3E");
    }
    
    .ps-btn-return:hover {
        background: linear-gradient(135deg, #e2e8f0, #cbd5e1) !important;
        color: #334155 !important;
        box-shadow: 0 4px 12px rgba(0,0,0,0.12) !important;
    }
    
    /* ===== 内容卡片 ===== */
    .ps-content-card {
        background: #ffffff !important;
        border-radius: 16px !important;
        border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.02) !important;
        padding: 44px !important;
        margin-bottom: 24px !important;
        transition: all 0.3s ease;
        position: relative;
    }
    
    .ps-content-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #10b981, #34d399);
        border-radius: 16px 16px 0 0;
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .ps-content-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,0.08), 0 8px 24px rgba(0,0,0,0.04) !important;
    }
    
    .ps-content-card:hover::before {
        opacity: 1;
    }
    
    .ps-content {
        font-size: 16px !important;
        color: #334155 !important;
        line-height: 1.9 !important;
    }
    
    /* 内容排版优化 */
    .ps-content h1,
    .ps-content h2,
    .ps-content h3,
    .ps-content h4,
    .ps-content h5,
    .ps-content h6 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 20px;
        line-height: 1.3;
        padding-left: 20px;
        border-left: 5px solid #10b981;
        position: relative;
    }
    
    .ps-content h1::before,
    .ps-content h2::before,
    .ps-content h3::before {
        content: '';
        position: absolute;
        left: -5px;
        top: 0;
        bottom: 0;
        width: 5px;
        background: linear-gradient(180deg, #10b981, #34d399);
        border-radius: 0 3px 3px 0;
    }
    
    .ps-content h1 { font-size: 34px; border-left-width: 6px; }
    .ps-content h2 { font-size: 28px; }
    .ps-content h3 { font-size: 24px; }
    .ps-content h4 { font-size: 20px; border-left-width: 4px; }
    
    .ps-content p {
        margin-bottom: 18px;
        line-height: 1.9;
    }
    
    .ps-content ul,
    .ps-content ol {
        margin: 20px 0;
        padding-left: 32px;
    }
    
    .ps-content li {
        margin-bottom: 10px;
        line-height: 1.9;
        position: relative;
    }
    
    .ps-content ul li::marker {
        color: #10b981;
        font-size: 1.2em;
    }
    
    .ps-content ol li::marker {
        color: #10b981;
        font-weight: 700;
    }
    
    .ps-content img {
        max-width: 100%;
        height: auto;
        border-radius: 14px;
        box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        margin: 32px 0;
        transition: all 0.4s ease;
        display: block;
        border: 3px solid #f1f5f9;
    }
    
    .ps-content img:hover {
        box-shadow: 0 12px 32px rgba(0,0,0,0.15);
        transform: translateY(-4px) scale(1.01);
        border-color: #10b981;
    }
    
    .ps-content a {
        color: #10b981;
        text-decoration: none;
        border-bottom: 1px solid transparent;
        transition: all 0.2s ease;
    }
    
    .ps-content a:hover {
        color: #059669;
        border-bottom-color: #10b981;
    }
    
    .ps-content code {
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #92400e;
        padding: 3px 10px;
        border-radius: 6px;
        font-size: 14px;
        font-family: 'Consolas', 'Monaco', monospace;
        font-weight: 600;
        border: 1px solid #fde68a;
    }
    
    .ps-content pre {
        background: linear-gradient(135deg, #1e293b, #334155);
        color: #e2e8f0;
        padding: 24px;
        border-radius: 14px;
        overflow-x: auto;
        margin: 32px 0;
        box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        border: 1px solid #475569;
        position: relative;
    }
    
    .ps-content pre::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #10b981, #34d399, #6ee7b7);
        border-radius: 14px 14px 0 0;
    }
    
    .ps-content pre code {
        background: transparent;
        color: inherit;
        padding: 0;
        font-size: 14px;
        border: none;
    }
    
    /* ===== 底部返回按钮 ===== */
    .ps-footer {
        text-align: center !important;
        padding: 24px 0 !important;
    }
    
    .ps-footer-btn {
        display: inline-flex !important;
        align-items: center !important;
        gap: 10px !important;
        padding: 16px 42px !important;
        background: linear-gradient(135deg, #10b981, #059669) !important;
        color: #ffffff !important;
        border: none !important;
        border-radius: 14px !important;
        font-size: 16px !important;
        font-weight: 700 !important;
        text-decoration: none !important;
        cursor: pointer !important;
        transition: all 0.3s ease !important;
        box-shadow: 0 6px 20px rgba(16,185,129,0.35) !important;
        position: relative;
        overflow: hidden;
    }
    
    .ps-footer-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .ps-footer-btn:hover::before {
        left: 100%;
    }
    
    .ps-footer-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 32px rgba(16,185,129,0.45) !important;
        color: #ffffff !important;
        background: linear-gradient(135deg, #059669, #047857) !important;
    }
    
    .ps-footer-btn:active {
        transform: translateY(-1px);
    }
    
    .ps-footer-btn svg {
        width: 20px !important;
        height: 20px !important;
        stroke: currentColor !important;
        fill: none !important;
        stroke-width: 2.5 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    /* ===== 响应式设计 ===== */
    @media (max-width: 1024px) {
        .ps-title-card {
            padding: 24px 20px;
        }
        
        .ps-info-card {
            padding: 20px 24px;
        }
        
        .ps-content-card {
            padding: 24px 20px;
        }
        
        .ps-title {
            font-size: 22px;
        }
        
        .ps-title::before,
        .ps-title::after {
            height: 26px;
        }
        
        .ps-info-grid {
            grid-template-columns: 1fr;
        }
    }
    
    @media (max-width: 768px) {
        .ps-title-card {
            padding: 20px 16px;
        }
        
        .ps-info-card {
            padding: 16px 20px;
        }
        
        .ps-content-card {
            padding: 20px 16px;
        }
        
        .ps-title {
            font-size: 20px;
        }
        
        .ps-title::before,
        .ps-title::after {
            width: 4px;
            height: 24px;
        }
        
        .ps-actions {
            flex-direction: column;
            align-items: stretch;
        }
        
        .ps-btn {
            width: 100%;
            justify-content: center;
        }
        
        .ps-footer-btn {
            width: 100%;
            justify-content: center;
        }
    }
    
    /* ===== 隐藏旧样式元素 ===== */
    .courseshow {
        display: none !important;
    }
</style>

<script type="text/javascript">
    // 页面加载后美化按钮
    window.onload = function() {
        // 修改按钮
        var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
        if (btnEdit) {
            btnEdit.value = '修改任务';
            btnEdit.style.width = 'auto';
            btnEdit.style.height = 'auto';
        }
        
        // 返回按钮
        var btnReturn = document.getElementById('<%= BtnReturnSmall.ClientID %>');
        if (btnReturn) {
            btnReturn.value = '返回列表';
            btnReturn.style.width = 'auto';
            btnReturn.style.height = 'auto';
        }
    };
</script>

<div class="ps-container">
    <!-- 渐变标题栏 -->
    <div class="ps-title-card">
        <div class="ps-title-icon">
            <svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
        </div>
        <div class="ps-title-text">
            <h1 class="ps-title"><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
            <p class="ps-title-sub">查看编程任务详情，包括任务要求、实例和评价标准</p>
        </div>
    </div>
    
    <!-- 信息卡片 -->
    <div class="ps-info-card">
        <div class="ps-card-head">
            <span class="ps-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                任务信息
            </h3>
        </div>
        <div class="ps-card-body">
            <div class="ps-info-grid">
            <!-- 日期 -->
            <div class="ps-info-item">
                <div class="ps-info-icon date">
                    <svg viewBox="0 0 24 24">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8" y1="2" x2="8" y2="6"/>
                        <line x1="3" y1="10" x2="21" y2="10"/>
                    </svg>
                </div>
                <div class="ps-info-content">
                    <div class="ps-info-label">日期</div>
                    <div class="ps-info-value">
                        <asp:Label ID="LabelMdate" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
            
            <!-- 作品类型 -->
            <div class="ps-info-item">
                <div class="ps-info-icon type">
                    <svg viewBox="0 0 24 24">
                        <polyline points="16 18 22 12 16 6"/>
                        <polyline points="8 6 2 12 8 18"/>
                    </svg>
                </div>
                <div class="ps-info-content">
                    <div class="ps-info-label">作品类型</div>
                    <div class="ps-info-value">
                        <asp:Image ID="ImageType" runat="server" />
                        <asp:Label ID="LabelMfiletype" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
            
            <!-- 实例 -->
            <div class="ps-info-item">
                <div class="ps-info-icon example">
                    <svg viewBox="0 0 24 24">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/>
                        <polyline points="10 9 9 9 8 9"/>
                    </svg>
                </div>
                <div class="ps-info-content">
                    <div class="ps-info-label">实例</div>
                    <div class="ps-info-value">
                        <asp:HyperLink ID="Hlexample" runat="server">查看实例</asp:HyperLink>
                    </div>
                </div>
            </div>
            
            <!-- 评价标准 -->
            <div class="ps-info-item">
                <div class="ps-info-icon standard">
                    <svg viewBox="0 0 24 24">
                        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                    </svg>
                </div>
                <div class="ps-info-content">
                    <div class="ps-info-label">评价标准</div>
                    <div class="ps-info-value">
                        <asp:HyperLink ID="HLMgid" runat="server">查看标准</asp:HyperLink>
                    </div>
                </div>
            </div>
            </div>
            
            <!-- 选项 -->
            <div class="ps-options">
            <div class="ps-option-item">
                <asp:CheckBox ID="CheckPublish" runat="server" Enabled="False" />
                <label>是否发布</label>
            </div>
            <div class="ps-option-item">
                <asp:CheckBox ID="CheckMicoWorld" runat="server" Enabled="False" />
                <label>作品继承（加载上一节的编程作品，适合项目学习）</label>
            </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="ps-actions">
            <asp:ImageButton ID="BtnEdit" runat="server" 
                onclick="BtnEdit_Click" 
                ImageUrl="~/images/edit.gif" 
                CssClass="ps-btn ps-btn-edit"
                AlternateText="修改任务" />
            <asp:ImageButton ID="BtnReturnSmall" runat="server" 
                onclick="BtnReturnSmall_Click" 
                ImageUrl="~/images/return.gif"
                CssClass="ps-btn ps-btn-return"
                AlternateText="返回列表" />
            </div>
        </div>
    </div>
    
    <!-- 内容卡片 -->
    <div class="ps-content-card">
        <div id="Mcontent" class="ps-content" runat="server"></div>
    </div>
    
    <!-- 底部返回按钮 -->
    <div class="ps-footer">
        <asp:LinkButton ID="LinkBtn" runat="server" OnClick="LinkBtn_Click" CssClass="ps-footer-btn">
            <svg viewBox="0 0 24 24">
                <line x1="19" y1="12" x2="5" y2="12"/>
                <polyline points="12 19 5 12 12 5"/>
            </svg>
            返回学案
        </asp:LinkButton>
    </div>
</div>

<!-- 原始内容（隐藏） -->
<div class="courseshow" style="display: none;">
    <br />
    <div class="missiontitle">
        <asp:Label ID="LabelMtitle_old" runat="server"></asp:Label>
    </div><br />
    <div class="courseother">
        日期：<asp:Label ID="LabelMdate_old" runat="server"></asp:Label>
        &nbsp;作品类型：<asp:Image ID="ImageType_old" runat="server" />
        <asp:Label ID="LabelMfiletype_old" runat="server"></asp:Label>
        &nbsp;实例:<asp:HyperLink ID="Hlexample_old" runat="server"></asp:HyperLink>
        <asp:CheckBox ID="CheckPublish_old" runat="server" Text="是否发布" Enabled="False" />&nbsp;
        <asp:CheckBox ID="CheckMicoWorld_old" runat="server" Text="作品继承" Enabled="False" />
        &nbsp;<asp:HyperLink ID="HLMgid_old" runat="server">评价标准</asp:HyperLink>
    </div>
    <div id="Mcontent_old" class="coursecontent" runat="server"></div>
    <br />
    <asp:LinkButton ID="LinkBtn_old" runat="server" OnClick="LinkBtn_Click" SkinID="LinkBtn">返回学案</asp:LinkButton>
    <br /><br />
</div>

</asp:Content>

