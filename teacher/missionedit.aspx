<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_missionedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<!-- Mission Edit Page v2.0 - Purple Theme -->
<style>
    /* 整体布局 */
    .mission-edit-layout {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
        animation: fadeIn 0.4s ease;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* 页面头部 */
    .mission-edit-header {
        background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 50%, #6d28d9 100%);
        border-radius: 16px;
        padding: 32px;
        margin-bottom: 28px;
        box-shadow: 0 4px 20px rgba(139,92,246,.25);
        position: relative;
        overflow: hidden;
    }
    
    .mission-edit-header::before {
        content: '';
        position: absolute;
        top: -40px;
        right: -40px;
        width: 140px;
        height: 140px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    
    .mission-edit-header-icon {
        font-size: 42px;
        margin-bottom: 12px;
        position: relative;
        z-index: 1;
    }
    
    .mission-edit-header-title {
        font-size: 26px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 8px;
        position: relative;
        z-index: 1;
    }
    
    .mission-edit-header-desc {
        font-size: 14px;
        color: rgba(255,255,255,.85);
        position: relative;
        z-index: 1;
    }
    
    /* 基本信息卡片 */
    .mission-basic-card {
        background: #fff;
        border-radius: 14px;
        border: 1.5px solid #e2e8f0;
        padding: 24px;
        margin-bottom: 24px;
        box-shadow: 0 2px 8px rgba(0,0,0,.04);
    }
    
    .mission-card-title {
        font-size: 18px;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 20px;
        padding-bottom: 12px;
        border-bottom: 2px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .mission-form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
    }
    
    .mission-form-item {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    
    .mission-form-label {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .mission-form-input {
        padding: 10px 14px !important;
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 8px !important;
        font-size: 14px !important;
        color: #1e293b !important;
        transition: all 0.2s !important;
        font-family: 'Microsoft YaHei', Arial, sans-serif !important;
    }
    
    .mission-form-input:focus {
        border-color: #8b5cf6 !important;
        box-shadow: 0 0 0 3px rgba(139,92,246,.1) !important;
        outline: none !important;
    }
    
    .mission-form-select {
        padding: 10px 14px !important;
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 8px !important;
        font-size: 14px !important;
        color: #1e293b !important;
        background: #fff !important;
        transition: all 0.2s !important;
        cursor: pointer !important;
        font-family: 'Microsoft YaHei', Arial, sans-serif !important;
    }
    
    .mission-form-select:focus {
        border-color: #8b5cf6 !important;
        box-shadow: 0 0 0 3px rgba(139,92,246,.1) !important;
        outline: none !important;
    }
    
    /* 选项区域 */
    .mission-options-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 16px;
        padding: 20px;
        background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
        border-radius: 10px;
        border: 1.5px solid #e9d5ff;
        margin-top: 20px;
    }
    
    .mission-checkbox-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #475569;
        font-weight: 500;
    }
    
    .mission-checkbox-item input[type="checkbox"] {
        width: 18px;
        height: 18px;
        accent-color: #8b5cf6;
        cursor: pointer;
    }
    
    .mission-checkbox-item label {
        cursor: pointer;
        user-select: none;
    }
    
    /* 编辑器卡片 */
    .mission-editor-card {
        background: #fff;
        border-radius: 14px;
        border: 1.5px solid #e2e8f0;
        padding: 0;
        margin-bottom: 24px;
        box-shadow: 0 2px 8px rgba(0,0,0,.04);
        overflow: hidden;
    }
    
    .mission-editor-header {
        background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
        border-bottom: 2px solid #e9d5ff;
        padding: 20px 24px;
    }
    
    .mission-editor-title {
        font-size: 18px;
        font-weight: 700;
        color: #5b21b6;
        margin: 0;
    }
    
    .mission-editor-body {
        padding: 24px;
    }
    
    /* 底部操作区 */
    .mission-footer-card {
        background: #fff;
        border-radius: 14px;
        border: 1.5px solid #e2e8f0;
        padding: 24px;
        box-shadow: 0 2px 8px rgba(0,0,0,.04);
    }
    
    .mission-message {
        padding: 12px 16px;
        background: #f0f9ff;
        border: 1px solid #bae6fd;
        border-radius: 8px;
        color: #0c4a6e;
        font-size: 13px;
        margin-bottom: 20px;
        display: none;
    }
    
    .mission-message.show {
        display: block;
    }
    
    .mission-grade-section {
        margin-bottom: 20px;
    }
    
    .mission-grade-label {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 8px;
        display: block;
    }
    
    .mission-actions {
        display: flex;
        gap: 12px;
        padding-top: 20px;
        border-top: 2px solid #f1f5f9;
    }
    
    .mission-btn {
        display: inline-flex !important;
        align-items: center !important;
        gap: 8px !important;
        padding: 12px 28px !important;
        border: none !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        text-decoration: none !important;
        transition: all 0.2s !important;
        cursor: pointer !important;
        font-family: 'Microsoft YaHei', Arial, sans-serif !important;
    }
    
    .mission-btn-primary {
        background: linear-gradient(135deg, #8b5cf6, #7c3aed) !important;
        color: #fff !important;
        box-shadow: 0 4px 14px rgba(139,92,246,.3) !important;
    }
    
    .mission-btn-primary:hover {
        background: linear-gradient(135deg, #7c3aed, #6d28d9) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 20px rgba(139,92,246,.4) !important;
    }
    
    .mission-btn-secondary {
        background: #f8fafc !important;
        color: #475569 !important;
        border: 1.5px solid #e2e8f0 !important;
    }
    
    .mission-btn-secondary:hover {
        background: #f1f5f9 !important;
        color: #1e293b !important;
        border-color: #cbd5e1 !important;
    }
    
    /* 响应式设计 */
    @media (max-width: 768px) {
        .mission-edit-layout {
            padding: 16px;
        }
        
        .mission-edit-header {
            padding: 24px;
        }
        
        .mission-edit-header-title {
            font-size: 22px;
        }
        
        .mission-form-grid {
            grid-template-columns: 1fr;
        }
        
        .mission-options-grid {
            grid-template-columns: 1fr;
        }
        
        .mission-actions {
            flex-direction: column;
        }
        
        .mission-btn {
            width: 100%;
            justify-content: center !important;
        }
    }
</style>


<div class="mission-edit-layout">
    <!-- 页面头部 -->
    <div class="mission-edit-header">
        <div class="mission-edit-header-icon">✏️</div>
        <div class="mission-edit-header-title">编辑活动任务</div>
        <div class="mission-edit-header-desc">修改活动信息、内容和设置</div>
    </div>
    
    <!-- 基本信息卡片 -->
    <div class="mission-basic-card">
        <div class="mission-card-title">
            📋 基本信息
        </div>
        
        <div class="mission-form-grid">
            <!-- 活动名称 -->
            <div class="mission-form-item">
                <label class="mission-form-label">
                    📝 活动名称
                </label>
                <asp:TextBox ID="Texttitle" runat="server" CssClass="mission-form-input" Width="100%"></asp:TextBox>
            </div>
            
            <!-- 作品类型 -->
            <div class="mission-form-item">
                <label class="mission-form-label">
                    🎨 作品类型
                </label>
                <asp:DropDownList ID="DDLmfiletype" runat="server" CssClass="mission-form-select" Width="100%">
                </asp:DropDownList>
            </div>
        </div>
        
        <!-- 选项设置 -->
        <div class="mission-options-grid">
            <div class="mission-checkbox-item">
                <asp:CheckBox ID="CheckUpload" runat="server" Checked="True" />
                <label>是否提交</label>
            </div>
            <div class="mission-checkbox-item">
                <asp:CheckBox ID="CheckPublish" runat="server" Checked="True" />
                <label>是否发布</label>
            </div>
            <div class="mission-checkbox-item">
                <asp:CheckBox ID="CheckGroup" runat="server" />
                <label>小组合作</label>
            </div>
            <div class="mission-checkbox-item">
                <asp:CheckBox ID="CheckRemote" runat="server" />
                <label title="自动下载远程图片，有时失效！">远程图片</label>
            </div>
            <div class="mission-checkbox-item">
                <asp:CheckBox ID="CheckMicoWorld" runat="server" Checked="False" />
                <label title="显示上一节课作品提供下载，适合项目学习连续制作">上次作品</label>
            </div>
        </div>
    </div>
    
    <!-- 内容编辑器卡片 -->
    <div class="mission-editor-card">
        <div class="mission-editor-header">
            <h2 class="mission-editor-title">📝 活动内容</h2>
        </div>
        <div class="mission-editor-body">
            <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
            <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
            <script>
                var editor;
                var cid = <%=myCid() %>;
                var ty = "Course";
                var upjs = '../kindeditor/aspnet/upload_json.aspx?cid=' + cid + '&Ty=' + ty;
                var fmjs = '../kindeditor/aspnet/file_manager_json.aspx?cid=' + cid + '&Ty=' + ty;
                KindEditor.ready(function (K) {
                    editor = K.create('textarea[name="ctl00$Content$mcontent"]', {
                        resizeType: 1,
                        newlineTag: "br",
                        uploadJson: upjs,
                        fileManagerJson: fmjs,
                        allowFileManager: true,
                        filterMode: false,
                        afterCreate: function () {
                            this.loadPlugin('autoheight');
                        }
                    });
                });
            </script>
            <textarea id="mcontent" runat="server" style="width: 100%; height:550px;"></textarea>
        </div>
    </div>
    
    <!-- 底部操作区 -->
    <div class="mission-footer-card">
        <!-- 消息提示 -->
        <div class="mission-message" id="missionMessage">
            <asp:Label ID="Labelmsg" runat="server"></asp:Label>
        </div>
        
        <!-- 评价标准 -->
        <div class="mission-grade-section">
            <label class="mission-grade-label">⭐ 选择自定义评价标准</label>
            <asp:DropDownList ID="DDLMgid" runat="server" CssClass="mission-form-select" Width="300px">
            </asp:DropDownList>
        </div>
        
        <!-- 操作按钮 -->
        <div class="mission-actions">
            <asp:Button ID="Btnedit" runat="server" Text="💾 保存修改" OnClick="Btnedit_Click" CssClass="mission-btn mission-btn-primary" />
            <asp:Button ID="BtnCourse" runat="server" Text="← 返回学案" OnClick="BtnCourse_Click" CssClass="mission-btn mission-btn-secondary" />
        </div>
    </div>
</div>

<script type="text/javascript">
    // 显示消息
    (function() {
        var msgLabel = document.getElementById('<%= Labelmsg.ClientID %>');
        var msgDiv = document.getElementById('missionMessage');
        if (msgLabel && msgDiv && msgLabel.textContent.trim() !== '') {
            msgDiv.classList.add('show');
        }
    })();
</script>

</asp:Content>
