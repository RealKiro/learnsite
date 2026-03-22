<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_txtformshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<style>
    /* ===== 打字文章展示页面 (参照 topicadd) ===== */
    .show-container {
        max-width: 1440px !important;
        width: 100% !important;
        margin: 0 auto !important;
        padding: 0 !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: showFadeIn 0.5s ease;
    }
    
    @keyframes showFadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* ===== 渐变标题栏 (绿色主题) ===== */
    .show-title-card {
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
    
    .show-title-card::before {
        content: '' !important;
        position: absolute !important;
        top: -30px !important;
        right: -30px !important;
        width: 120px !important;
        height: 120px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.08) !important;
    }
    
    .show-title-card::after {
        content: '' !important;
        position: absolute !important;
        bottom: -40px !important;
        right: 60px !important;
        width: 160px !important;
        height: 160px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.05) !important;
    }
    
    .show-title-icon {
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
    
    .show-title-icon svg {
        width: 26px !important;
        height: 26px !important;
        stroke: #fff !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .show-title-text {
        position: relative !important;
        z-index: 1 !important;
        flex: 1 !important;
    }
    
    .show-title {
        font-size: 22px !important;
        font-weight: 700 !important;
        color: #fff !important;
        margin: 0 0 4px 0 !important;
        line-height: 1.3 !important;
    }
    
    .show-title-sub {
        font-size: 13px !important;
        color: rgba(255,255,255,.75) !important;
        margin: 0 !important;
    }
    
    /* ===== 信息卡片 ===== */
    .show-info-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
        transition: box-shadow .2s, transform .2s !important;
    }
    
    .show-info-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
        transform: translateY(-1px) !important;
    }
    
    .show-card-head {
        padding: 16px 24px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important;
        align-items: center !important;
        gap: 10px !important;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%) !important;
    }
    
    .show-card-head .show-dot {
        width: 8px !important;
        height: 8px !important;
        border-radius: 50% !important;
        background: linear-gradient(135deg, #059669, #34d399) !important;
        flex-shrink: 0 !important;
    }
    
    .show-card-head h3 {
        font-size: 15px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        margin: 0 !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        flex: 1 !important;
    }
    
    .show-card-head h3 svg {
        width: 18px !important;
        height: 18px !important;
        stroke: #059669 !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .show-card-body {
        padding: 24px 28px !important;
    }
    
    .show-info-row {
        display: flex !important;
        align-items: center !important;
        gap: 16px !important;
        flex-wrap: wrap !important;
        margin-bottom: 16px !important;
    }
    
    .show-info-item {
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        padding: 8px 16px !important;
        background: #f8fafc !important;
        border: 1px solid #e5e7eb !important;
        border-radius: 8px !important;
        font-size: 13px !important;
        color: #475569 !important;
        transition: all 0.2s ease !important;
    }
    
    .show-info-item:hover {
        background: #f1f5f9 !important;
        border-color: #cbd5e1 !important;
    }
    
    .show-info-item label {
        font-weight: 600 !important;
        color: #64748b !important;
    }
    
    .show-info-item input[type="checkbox"] {
        width: 18px !important;
        height: 18px !important;
        accent-color: #10b981 !important;
    }
    
    /* ===== 操作按钮 ===== */
    .show-actions {
        display: flex !important;
        align-items: center !important;
        gap: 12px !important;
        padding-top: 20px !important;
        border-top: 1px solid #f1f5f9 !important;
        margin-top: 20px !important;
    }
    
    .show-btn {
        padding: 10px 28px !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        text-decoration: none !important;
        transition: all 0.2s ease !important;
        border: 1.5px solid #e2e8f0 !important;
        background: #fff !important;
        color: #475569 !important;
        cursor: pointer !important;
        text-indent: 0 !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
    }
    
    .show-btn:hover {
        background: #f8fafc !important;
        border-color: #cbd5e1 !important;
        transform: translateY(-1px) !important;
    }
    
    .show-btn-primary {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
        color: #fff !important;
        border-color: transparent !important;
        box-shadow: 0 3px 12px rgba(5,150,105,.25) !important;
    }
    
    .show-btn-primary:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 6px 20px rgba(5,150,105,.35) !important;
        transform: translateY(-1px) !important;
        color: #fff !important;
    }
    
    /* ===== 内容卡片 ===== */
    .show-content-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        padding: 44px !important;
        margin-bottom: 24px !important;
        transition: all 0.3s ease;
    }
    
    .show-content-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,0.08), 0 8px 24px rgba(0,0,0,0.04) !important;
    }
    
    .show-content {
        font-size: 16px !important;
        color: #334155 !important;
        line-height: 1.9 !important;
    }
    
    /* 内容排版 */
    .show-content h1,
    .show-content h2,
    .show-content h3,
    .show-content h4 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 20px;
        line-height: 1.3;
        padding-left: 20px;
        border-left: 5px solid #10b981;
    }
    
    .show-content h1 { font-size: 34px; border-left-width: 6px; }
    .show-content h2 { font-size: 28px; }
    .show-content h3 { font-size: 24px; }
    .show-content h4 { font-size: 20px; border-left-width: 4px; }
    
    .show-content p {
        margin-bottom: 18px;
        line-height: 1.9;
    }
    
    .show-content img {
        max-width: 100%;
        height: auto;
        border-radius: 14px;
        box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        margin: 32px 0;
        border: 3px solid #f1f5f9;
    }
    
    /* ===== 底部返回按钮 ===== */
    .show-footer {
        text-align: center !important;
        padding: 24px 0 !important;
    }
    
    .show-footer-btn {
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
        font-family: 'Microsoft YaHei', sans-serif !important;
    }
    
    .show-footer-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 32px rgba(16,185,129,0.45) !important;
        color: #ffffff !important;
        background: linear-gradient(135deg, #059669, #047857) !important;
    }
    
    /* ===== 隐藏旧样式 ===== */
    .courseshow {
        display: none !important;
    }
</style>

<script type="text/javascript">
    window.onload = function() {
        var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
        if (btnEdit) {
            btnEdit.value = '修改任务';
            btnEdit.style.width = 'auto';
            btnEdit.style.height = 'auto';
        }
        
        var btnReturn = document.getElementById('<%= BtnReturnSmall.ClientID %>');
        if (btnReturn) {
            btnReturn.value = '返回列表';
            btnReturn.style.width = 'auto';
            btnReturn.style.height = 'auto';
        }
    };
</script>

<div class="show-container">
    <!-- 渐变标题栏 -->
    <div class="show-title-card">
        <div class="show-title-icon">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        </div>
        <div class="show-title-text">
            <h1 class="show-title"><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
            <p class="show-title-sub">查看打字文章详情，练习打字技能</p>
        </div>
    </div>
    
    <!-- 信息卡片 -->
    <div class="show-info-card">
        <div class="show-card-head">
            <span class="show-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                任务信息
            </h3>
        </div>
        <div class="show-card-body">
            <div class="show-info-row">
                <div class="show-info-item">
                    <label>日期：</label>
                    <asp:Label ID="LabelMdate" runat="server"></asp:Label>
                </div>
                <div class="show-info-item">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Enabled="False" />
                </div>
                <div class="show-info-item">
                    <asp:CheckBox ID="CheckCollabo" runat="server" Text="是否协同" Enabled="False" />
                </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="show-actions">
                <asp:ImageButton ID="BtnEdit" runat="server" 
                    onclick="BtnEdit_Click" 
                    ImageUrl="~/images/edit.gif" 
                    CssClass="show-btn show-btn-primary"
                    AlternateText="修改任务" />
                <asp:ImageButton ID="BtnReturnSmall" runat="server" 
                    onclick="BtnReturnSmall_Click" 
                    ImageUrl="~/images/return.gif"
                    CssClass="show-btn"
                    AlternateText="返回列表" />
            </div>
        </div>
    </div>
    
    <!-- 内容卡片 -->
    <div class="show-content-card">
        <div id="Mcontent" class="show-content" runat="server"></div>
    </div>
    
    <!-- 底部返回按钮 -->
    <div class="show-footer">
        <asp:LinkButton ID="LinkBtn" runat="server" OnClick="LinkBtn_Click" CssClass="show-footer-btn">
            <svg viewBox="0 0 24 24" style="width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;">
                <line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>
            </svg>
            返回学案
        </asp:LinkButton>
    </div>
</div>

<!-- 原始内容（隐藏） -->
<div class="courseshow">
    <br />
    <div class="missiontitle">
        <asp:Label ID="LabelMtitle_old" runat="server"></asp:Label>
    </div><br />
    <div class="courseother">
       日期：<asp:Label ID="LabelMdate_old" runat="server"></asp:Label>
        &nbsp;<asp:CheckBox ID="CheckPublish_old" runat="server" Text="是否发布" Enabled="False" /> 
        <asp:CheckBox ID="CheckCollabo_old" runat="server" Text="是否协同" Enabled="False" />         
    </div>   
    <div id="Mcontent_old" class="coursecontent" runat="server"></div>
    <br />
    <asp:LinkButton ID="LinkBtn_old" runat="server" OnClick="LinkBtn_Click" SkinID="LinkBtn">返回学案</asp:LinkButton>
    <br /><br />
</div> 
<br />
</asp:Content>

