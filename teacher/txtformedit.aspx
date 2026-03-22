<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_txtformedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<style>
    /* ===== 表单编辑页面样式 ===== */
    .tfe-container {
        max-width: 1440px !important;
        width: 100% !important;
        margin: 0 auto !important;
        padding: 0 !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: tfeFadeIn 0.5s ease;
    }
    
    @keyframes tfeFadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* ===== 渐变标题栏 (绿色主题) ===== */
    .tfe-title-card {
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
    
    .tfe-title-card::before {
        content: '' !important;
        position: absolute !important;
        top: -30px !important;
        right: -30px !important;
        width: 120px !important;
        height: 120px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.08) !important;
    }
    
    .tfe-title-card::after {
        content: '' !important;
        position: absolute !important;
        bottom: -40px !important;
        right: 60px !important;
        width: 160px !important;
        height: 160px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.05) !important;
    }
    
    .tfe-title-icon {
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
    
    .tfe-title-icon svg {
        width: 26px !important;
        height: 26px !important;
        stroke: #fff !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .tfe-title-text {
        position: relative !important;
        z-index: 1 !important;
        flex: 1 !important;
    }
    
    .tfe-title {
        font-size: 22px !important;
        font-weight: 700 !important;
        color: #fff !important;
        margin: 0 0 4px 0 !important;
        line-height: 1.3 !important;
    }
    
    .tfe-title-sub {
        font-size: 13px !important;
        color: rgba(255,255,255,.75) !important;
        margin: 0 !important;
    }
    
    /* ===== 表单设置卡片 ===== */
    .tfe-form-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
        transition: box-shadow .2s, transform .2s !important;
    }
    
    .tfe-form-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
        transform: translateY(-1px) !important;
    }
    
    .tfe-card-head {
        padding: 16px 24px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important;
        align-items: center !important;
        gap: 10px !important;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%) !important;
    }
    
    .tfe-card-head .tfe-dot {
        width: 8px !important;
        height: 8px !important;
        border-radius: 50% !important;
        background: linear-gradient(135deg, #059669, #34d399) !important;
        flex-shrink: 0 !important;
    }
    
    .tfe-card-head h3 {
        font-size: 15px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        margin: 0 !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        flex: 1 !important;
    }
    
    .tfe-card-head h3 svg {
        width: 18px !important;
        height: 18px !important;
        stroke: #059669 !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .tfe-card-body {
        padding: 24px 28px !important;
    }
    
    /* ===== 表单字段 ===== */
    .tfe-form-group {
        margin-bottom: 20px !important;
    }
    
    .tfe-form-group:last-child {
        margin-bottom: 0 !important;
    }
    
    .tfe-form-label {
        display: block !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        margin-bottom: 8px !important;
    }
    
    .tfe-form-input {
        width: 100% !important;
        max-width: 400px !important;
        padding: 10px 14px !important;
        font-size: 14px !important;
        border: 1px solid #d1d5db !important;
        border-radius: 8px !important;
        transition: all 0.2s ease !important;
        font-family: inherit !important;
    }
    
    .tfe-form-input:focus {
        outline: none !important;
        border-color: #10b981 !important;
        box-shadow: 0 0 0 3px rgba(16,185,129,0.1) !important;
    }
    
    .tfe-checkbox-group {
        display: flex !important;
        align-items: center !important;
        gap: 24px !important;
        flex-wrap: wrap !important;
        margin-top: 16px !important;
    }
    
    .tfe-checkbox-item {
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
    }
    
    .tfe-checkbox-item input[type="checkbox"] {
        width: 18px !important;
        height: 18px !important;
        cursor: pointer !important;
        accent-color: #10b981 !important;
    }
    
    .tfe-checkbox-item label {
        font-size: 14px !important;
        color: #475569 !important;
        cursor: pointer !important;
        margin: 0 !important;
    }
    
    /* ===== 编辑器容器 ===== */
    .tfe-editor-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
        transition: box-shadow .2s, transform .2s !important;
    }
    
    .tfe-editor-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
        transform: translateY(-1px) !important;
    }
    
    .tfe-editor-body {
        padding: 24px 28px !important;
    }
    
    .tfe-editor-wrapper {
        border: 1px solid #e5e7eb !important;
        border-radius: 10px !important;
        overflow: hidden !important;
        background: #fff !important;
    }
    
    /* ===== 消息提示 ===== */
    .tfe-message {
        padding: 12px 16px !important;
        border-radius: 8px !important;
        margin-bottom: 20px !important;
        font-size: 14px !important;
    }
    
    .tfe-message.success {
        background: #f0fdf4 !important;
        border: 1px solid #86efac !important;
        color: #166534 !important;
    }
    
    .tfe-message.error {
        background: #fef2f2 !important;
        border: 1px solid #fca5a5 !important;
        color: #991b1b !important;
    }
    
    /* ===== 操作按钮 ===== */
    .tfe-actions {
        display: flex !important;
        align-items: center !important;
        gap: 12px !important;
        padding: 20px 0 !important;
    }
    
    .tfe-btn {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 10px 20px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        border-radius: 8px !important;
        border: none !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        text-decoration: none !important;
        font-family: inherit !important;
    }
    
    .tfe-btn-primary {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
        color: #fff !important;
        box-shadow: 0 2px 8px rgba(5,150,105,.2) !important;
    }
    
    .tfe-btn-primary:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 4px 12px rgba(5,150,105,.3) !important;
        transform: translateY(-1px) !important;
    }
    
    .tfe-btn-secondary {
        background: #fff !important;
        color: #475569 !important;
        border: 1px solid #d1d5db !important;
    }
    
    .tfe-btn-secondary:hover {
        background: #f9fafb !important;
        border-color: #9ca3af !important;
        transform: translateY(-1px) !important;
    }
    
    /* ===== 响应式设计 ===== */
    @media (max-width: 768px) {
        .tfe-title-card {
            padding: 20px 24px !important;
        }
        
        .tfe-title {
            font-size: 18px !important;
        }
        
        .tfe-card-body,
        .tfe-editor-body {
            padding: 20px !important;
        }
        
        .tfe-checkbox-group {
            flex-direction: column !important;
            align-items: flex-start !important;
            gap: 12px !important;
        }
        
        .tfe-actions {
            flex-direction: column !important;
        }
        
        .tfe-btn {
            width: 100% !important;
        }
    }
</style>

<div class="tfe-container">
    <!-- 标题栏 -->
    <div class="tfe-title-card">
        <div class="tfe-title-icon">
            <svg viewBox="0 0 24 24">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10 9 9 9 8 9"/>
            </svg>
        </div>
        <div class="tfe-title-text">
            <h1 class="tfe-title">编辑表单</h1>
            <p class="tfe-title-sub">创建或修改表格表单，设置发布和协同选项</p>
        </div>
    </div>
    
    <!-- 表单设置卡片 -->
    <div class="tfe-form-card">
        <div class="tfe-card-head">
            <span class="tfe-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                表单设置
            </h3>
        </div>
        <div class="tfe-card-body">
            <div class="tfe-form-group">
                <label class="tfe-form-label" for="<%=Texttitle.ClientID%>">表格名称</label>
                <asp:TextBox ID="Texttitle" runat="server" CssClass="tfe-form-input" />
            </div>
            
            <div class="tfe-checkbox-group">
                <div class="tfe-checkbox-item">
                    <asp:CheckBox ID="CheckPublish" runat="server" Checked="True" />
                    <label for="<%=CheckPublish.ClientID%>">是否发布</label>
                </div>
                <div class="tfe-checkbox-item">
                    <asp:CheckBox ID="CheckCollabo" runat="server" Checked="True" />
                    <label for="<%=CheckCollabo.ClientID%>">是否协同</label>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 编辑器卡片 -->
    <div class="tfe-editor-card">
        <div class="tfe-card-head">
            <span class="tfe-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
                表单内容
            </h3>
        </div>
        <div class="tfe-editor-body">
            <div class="tfe-editor-wrapper">
                <script type="text/javascript" charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
                <script type="text/javascript" charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
                <script type="text/javascript">
                    var editor;
                    var cid = <%=myCid() %>;
                    var ty = "Course";
                    var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&ty=' + ty;
                    var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?cid=' + cid + '&ty=' + ty;
                    KindEditor.ready(function (K) {
                        editor = K.create('textarea[name="ctl00$Content$mcontent"]', {
                            resizeType: 1,
                            newlineTag: "br",
                            uploadJson: upjs,
                            fileManagerJson: fmjs,
                            allowFileManager: true,
                            filterMode: false,
                            autoHeightMode: true,
                            afterCreate: function() {
                                this.loadPlugin('autoheight');
                            }
                        });
                    });
                </script>
                <textarea id="mcontent" runat="server" style="width: 100%; min-height: 450px;"></textarea>
            </div>
        </div>
    </div>
    
    <!-- 消息提示 -->
    <div class="tfe-message" style="display: none;" id="messageContainer">
        <asp:Label ID="Labelmsg" runat="server"></asp:Label>
    </div>
    
    <!-- 操作按钮 -->
    <div class="tfe-actions">
        <asp:Button ID="Btnedit" runat="server" Text="修改表单" OnClick="Btnedit_Click" CssClass="tfe-btn tfe-btn-primary" />
        <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click" CssClass="tfe-btn tfe-btn-secondary" />
    </div>
</div>

<script type="text/javascript">
    // 显示/隐藏消息提示
    (function() {
        var msgLabel = document.getElementById('<%=Labelmsg.ClientID%>');
        if (msgLabel && msgLabel.textContent.trim() !== '') {
            var msgContainer = document.getElementById('messageContainer');
            if (msgContainer) {
                msgContainer.style.display = 'block';
                if (msgLabel.textContent.indexOf('成功') !== -1 || msgLabel.textContent.indexOf('完成') !== -1) {
                    msgContainer.className = 'tfe-message success';
                } else if (msgLabel.textContent.indexOf('错误') !== -1 || msgLabel.textContent.indexOf('失败') !== -1) {
                    msgContainer.className = 'tfe-message error';
                }
            }
        }
    })();
</script>

</asp:Content>

