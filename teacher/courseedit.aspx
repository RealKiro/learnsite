<%@ page validaterequest="false" title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_courseedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ce-page { max-width: 98%; margin: 0 auto; }
    .ce-card {
        background: #fff;
        border-radius: 14px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.06), 0 4px 16px rgba(0,0,0,0.04);
        padding: 28px 32px 24px;
        margin-bottom: 20px;
    }
    .ce-card-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 22px;
        padding-bottom: 14px;
        border-bottom: 1px solid #f1f5f9;
    }
    .ce-card-icon {
        width: 36px; height: 36px;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .ce-card-icon svg {
        width: 20px; height: 20px;
        stroke: #6366f1; fill: none;
        stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
    }
    .ce-card-title {
        font-size: 16px;
        font-weight: 600;
        color: #1e293b;
    }

    /* 表单行 */
    .ce-form-row {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 16px;
        flex-wrap: wrap;
    }
    .ce-form-group {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .ce-label {
        font-size: 13.5px;
        font-weight: 500;
        color: #475569;
        white-space: nowrap;
        min-width: fit-content;
    }

    /* 统一表单控件样式 */
    .ce-card input[type="text"],
    .ce-card select,
    .ce-card .ce-form-row input[type="text"] {
        height: 36px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 0 12px;
        font-size: 13.5px;
        color: #334155;
        background: #f8fafc;
        transition: all 0.2s;
        outline: none;
    }
    .ce-card input[type="text"]:focus,
    .ce-card select:focus {
        border-color: #818cf8;
        background: #fff;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .ce-card select {
        cursor: pointer;
        padding: 0 8px;
    }
    .ce-title-input { width: 100% !important; max-width: 800px; }
    .ce-class-select { min-width: 120px !important; }

    /* 复选框 */
    .ce-checkbox-wrap {
        display: flex; align-items: center; gap: 6px;
        font-size: 13.5px; color: #475569;
        cursor: pointer;
    }
    .ce-checkbox-wrap input[type="checkbox"] {
        accent-color: #6366f1;
        width: 16px; height: 16px;
    }

    /* 横幅和上传 */
    .ce-banner-link {
        font-size: 13px;
        color: #6366f1;
        text-decoration: none;
        font-weight: 500;
        transition: color 0.15s;
    }
    .ce-banner-link:hover { color: #4f46e5; text-decoration: underline; }
    .ce-upload-wrap input[type="file"] {
        font-size: 12px;
        color: #64748b;
    }
    
    /* 背景图预览区域 */
    .ce-banner-preview {
        margin-top: 12px;
        padding: 16px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        display: none;
    }
    .ce-banner-preview.has-image {
        display: block;
    }
    .ce-banner-preview-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
    }
    .ce-banner-preview-title {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
    }
    .ce-banner-preview-actions {
        display: flex;
        gap: 8px;
    }
    .ce-banner-preview-btn {
        font-size: 12px;
        padding: 4px 10px;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        background: #fff;
        color: #64748b;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.15s;
    }
    .ce-banner-preview-btn:hover {
        border-color: #cbd5e1;
        color: #475569;
        background: #f1f5f9;
    }
    .ce-banner-preview-btn.delete {
        color: #ef4444;
        border-color: #fecaca;
    }
    .ce-banner-preview-btn.delete:hover {
        background: #fef2f2;
        border-color: #fca5a5;
        color: #dc2626;
    }
    .ce-banner-preview-image {
        width: 100%;
        max-width: 600px;
        height: 200px;
        object-fit: cover;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    /* 分隔符 */
    .ce-sep {
        color: #cbd5e1;
        font-size: 13px;
        user-select: none;
    }

    /* 编辑器区域 */
    .ce-editor-wrap {
        border-radius: 10px;
        overflow: hidden;
    }
    .ce-editor-wrap textarea {
        width: 100% !important;
        min-height: 420px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
    }

    /* KindEditor 工具栏美化 */
    .ce-editor-wrap .ke-container {
        border: 1px solid #e2e8f0 !important;
        border-radius: 10px !important;
        overflow: hidden;
    }
    .ce-editor-wrap .ke-toolbar {
        background: linear-gradient(180deg, #f8fafc, #f1f5f9) !important;
        border-bottom: 1px solid #e2e8f0 !important;
        padding: 6px 10px !important;
    }
    .ce-editor-wrap .ke-toolbar .ke-outline {
        border: 1px solid transparent !important;
        border-radius: 6px !important;
        margin: 2px 1px !important;
        padding: 3px 4px !important;
        transition: all 0.15s ease;
    }
    .ce-editor-wrap .ke-toolbar .ke-outline:hover,
    .ce-editor-wrap .ke-toolbar .ke-on {
        border-color: #c7d2fe !important;
        background-color: #eef2ff !important;
    }
    .ce-editor-wrap .ke-toolbar .ke-selected {
        border-color: #a5b4fc !important;
        background-color: #e0e7ff !important;
    }
    .ce-editor-wrap .ke-toolbar .ke-separator {
        border-left: 1px solid #e2e8f0 !important;
        border-right: none !important;
        margin: 4px 6px !important;
        height: 18px !important;
        opacity: 0.7;
    }
    .ce-editor-wrap .ke-statusbar {
        background: #f8fafc !important;
        border-top: 1px solid #e2e8f0 !important;
    }

    /* 消息和按钮区域 */
    .ce-actions {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 16px;
        padding: 20px 0 4px;
    }
    .ce-msg {
        text-align: center;
        padding-bottom: 6px;
        min-height: 22px;
    }
    .ce-msg span { font-size: 13px; }
    .ce-actions input[type="submit"] {
        min-width: 110px;
        height: 40px;
        border: none;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        letter-spacing: 1px;
    }
    .ce-btn-primary {
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important;
        box-shadow: 0 2px 8px rgba(99,102,241,0.25);
    }
    .ce-btn-primary:hover {
        box-shadow: 0 4px 16px rgba(99,102,241,0.35);
        transform: translateY(-1px);
    }
    .ce-btn-secondary {
        background: #f1f5f9 !important;
        color: #475569 !important;
        border: 1px solid #e2e8f0 !important;
    }
    .ce-btn-secondary:hover {
        background: #e2e8f0 !important;
        color: #334155 !important;
    }
</style>

<div class="ce-page">
    <!-- 基本信息卡片 -->
    <div class="ce-card">
        <div class="ce-card-header">
            <div class="ce-card-icon">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            </div>
            <span class="ce-card-title">编辑学案</span>
        </div>

        <div class="ce-form-row">
            <span class="ce-label">学案名称</span>
            <asp:TextBox ID="Texttitle" runat="server" CssClass="ce-title-input" SkinID="TextBoxNormal" />
        </div>

        <div class="ce-form-row">
            <div class="ce-form-group">
                <span class="ce-label">学案分类</span>
                <asp:DropDownList ID="DDLclass" runat="server" CssClass="ce-class-select" />
            </div>
            <span class="ce-sep">|</span>
            <div class="ce-form-group">
                <span class="ce-label">授课年级</span>
                <asp:DropDownList ID="DDLcobj" runat="server" style="min-width:56px;" />
            </div>
            <span class="ce-sep">|</span>
            <div class="ce-form-group">
                <span class="ce-label">第</span>
                <asp:DropDownList ID="DDLCterm" runat="server" style="min-width:52px;">
                    <asp:ListItem>1</asp:ListItem>
                    <asp:ListItem Selected="True">2</asp:ListItem>
                </asp:DropDownList>
                <span class="ce-label">学期</span>
            </div>
            <div class="ce-form-group">
                <span class="ce-label">第</span>
                <asp:DropDownList ID="DDLCks" runat="server" style="min-width:52px;" />
                <span class="ce-label">课节</span>
            </div>
        </div>

        <div class="ce-form-row">
            <div class="ce-checkbox-wrap">
                <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Checked="True" />
            </div>
            <span class="ce-sep">|</span>
            <div class="ce-form-group">
                <span class="ce-label">背景图片</span>
                <asp:FileUpload ID="Fupload" runat="server" accept="image/*" />
                <asp:HyperLink ID="HLbanner" runat="server" Target="_blank" CssClass="ce-banner-link" style="display:none;">查看当前背景</asp:HyperLink>
            </div>
            <span class="ce-sep" style="font-size: 11px; color: #94a3b8;">支持 JPG、PNG、GIF、WEBP、BMP，最大 5MB</span>
        </div>
        
        <!-- 背景图预览区域 -->
        <div id="BannerPreview" class="ce-banner-preview" runat="server">
            <div class="ce-banner-preview-header">
                <span class="ce-banner-preview-title">当前背景图预览</span>
                <div class="ce-banner-preview-actions">
                    <asp:HyperLink ID="HLbannerView" runat="server" Target="_blank" CssClass="ce-banner-preview-btn">查看原图</asp:HyperLink>
                    <a href="javascript:void(0)" class="ce-banner-preview-btn delete" onclick="deleteBanner()">删除背景图</a>
                </div>
            </div>
            <img id="BannerPreviewImg" runat="server" class="ce-banner-preview-image" alt="背景图预览" />
        </div>
        
        <asp:HiddenField ID="HdBannerPath" runat="server" />
    </div>

    <!-- 编辑器卡片 -->
    <div class="ce-card">
        <div class="ce-card-header">
            <div class="ce-card-icon">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            </div>
            <span class="ce-card-title">学案内容</span>
        </div>
        <div class="ce-editor-wrap">
            <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
            <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
            <script>
                var editor;
                var cid= <%=myCid() %>;
                var ty="Course";
                var upjs= '../kindeditor/aspnet/upload_json.aspx?cid='+cid+'&ty='+ty;
                var fmjs='../kindeditor/aspnet/file_manager_json.aspx?cid='+cid+'&ty='+ty;
                KindEditor.ready(function (K) {
                    editor = K.create('textarea[name="ctl00$Content$mcontent"]', {
                        resizeType: 1,
                        newlineTag: "br",
                        cssPath : ['../kindeditor/plugins/code/prettify.css'],
                        uploadJson : upjs,
                        fileManagerJson : fmjs,
                        allowFileManager : true,
                        filterMode : false,
                        afterCreate: function() {
                            // 编辑器创建完成后，检查是否有AI生成的内容
                            checkAndLoadAiContent(this);
                        }
                    });
                });

                // 检查并加载AI生成的内容
                function checkAndLoadAiContent(editorInstance) {
                    try {
                        // 从 sessionStorage 获取AI生成的内容
                        var aiContent = sessionStorage.getItem('aiGeneratedLesson');
                        
                        if (aiContent) {
                            // 检查编辑器当前是否为空或只有默认内容
                            var currentContent = editorInstance.html();
                            var isEmpty = !currentContent || 
                                         currentContent.trim() === '' || 
                                         currentContent.trim() === '<br>' ||
                                         currentContent.trim() === '<p><br></p>' ||
                                         currentContent.trim() === '<p></p>';
                            
                            if (isEmpty) {
                                // 显示确认对话框
                                if (confirm('检测到AI生成的学案内容，是否自动填充到编辑器？\n\n点击"确定"填充内容，点击"取消"清除暂存内容。')) {
                                    // 用户确认，填充内容
                                    editorInstance.html(aiContent);
                                    
                                    // 显示成功提示
                                    showNotification('AI生成的内容已自动填充，请检查并修改后保存。', 'success');
                                    
                                    // 清除 sessionStorage
                                    sessionStorage.removeItem('aiGeneratedLesson');
                                } else {
                                    // 用户取消，清除暂存内容
                                    sessionStorage.removeItem('aiGeneratedLesson');
                                    showNotification('已清除AI生成的暂存内容。', 'info');
                                }
                            } else {
                                // 编辑器已有内容，询问是否覆盖
                                if (confirm('检测到AI生成的学案内容，但编辑器中已有内容。\n\n是否用AI生成的内容覆盖？\n点击"确定"覆盖，点击"取消"保留当前内容并清除暂存。')) {
                                    editorInstance.html(aiContent);
                                    showNotification('AI生成的内容已填充，请检查并修改后保存。', 'success');
                                    sessionStorage.removeItem('aiGeneratedLesson');
                                } else {
                                    sessionStorage.removeItem('aiGeneratedLesson');
                                    showNotification('已保留当前内容，清除AI暂存内容。', 'info');
                                }
                            }
                        }
                    } catch(e) {
                        console.error('加载AI内容失败:', e);
                    }
                }

                // 显示通知消息
                function showNotification(message, type) {
                    var notification = document.createElement('div');
                    notification.style.cssText = 'position:fixed;top:20px;right:20px;z-index:99999;' +
                        'padding:16px 24px;border-radius:12px;box-shadow:0 4px 20px rgba(0,0,0,0.15);' +
                        'font-size:14px;font-weight:500;max-width:400px;animation:slideIn 0.3s ease;';
                    
                    if (type === 'success') {
                        notification.style.background = 'linear-gradient(135deg, #10b981, #059669)';
                        notification.style.color = '#fff';
                    } else if (type === 'info') {
                        notification.style.background = 'linear-gradient(135deg, #6366f1, #4f46e5)';
                        notification.style.color = '#fff';
                    } else {
                        notification.style.background = '#fff';
                        notification.style.color = '#334155';
                        notification.style.border = '1px solid #e2e8f0';
                    }
                    
                    notification.textContent = message;
                    document.body.appendChild(notification);
                    
                    // 3秒后自动消失
                    setTimeout(function() {
                        notification.style.animation = 'slideOut 0.3s ease';
                        setTimeout(function() {
                            if (notification.parentNode) {
                                notification.parentNode.removeChild(notification);
                            }
                        }, 300);
                    }, 3000);
                }

                // 添加动画样式
                if (!document.getElementById('notificationStyles')) {
                    var style = document.createElement('style');
                    style.id = 'notificationStyles';
                    style.textContent = '@keyframes slideIn { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }' +
                        '@keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(400px); opacity: 0; } }';
                    document.head.appendChild(style);
                }
            </script>
            <textarea id="mcontent" runat="server" style="width:100%; height:420px;"></textarea>
        </div>

        <div class="ce-msg">
            <asp:Label ID="Labelmsg" runat="server" />
        </div>
        <div class="ce-actions">
            <asp:Button ID="Btnedit" runat="server" Text="确定保存" onclick="Btnedit_Click" CssClass="ce-btn-primary" />
            <asp:Button ID="Btnreturn" runat="server" Text="返回列表" onclick="Btnreturn_Click" CssClass="ce-btn-secondary" />
        </div>
    </div>
</div>

<script type="text/javascript">
    // 删除背景图
    function deleteBanner() {
        if (confirm('确定要删除当前背景图吗？删除后学生端将不再显示背景图。')) {
            // 设置隐藏字段为空，表示删除
            var hdField = document.getElementById('<%= HdBannerPath.ClientID %>');
            if (hdField) {
                hdField.value = '';
            }
            // 隐藏预览区域
            var preview = document.getElementById('<%= BannerPreview.ClientID %>');
            if (preview) {
                preview.style.display = 'none';
            }
            // 清空文件上传控件
            var fileUpload = document.getElementById('<%= Fupload.ClientID %>');
            if (fileUpload) {
                fileUpload.value = '';
            }
            // 创建一个隐藏的提交按钮来触发保存（删除背景图）
            var form = document.forms[0];
            if (form) {
                // 添加一个标记表示要删除背景图
                var deleteInput = document.createElement('input');
                deleteInput.type = 'hidden';
                deleteInput.name = 'DeleteBanner';
                deleteInput.value = '1';
                form.appendChild(deleteInput);
                // 提交表单
                __doPostBack('<%= Btnedit.UniqueID %>', '');
            }
        }
    }
    
    // 文件选择预览
    (function() {
        var fileUpload = document.getElementById('<%= Fupload.ClientID %>');
        if (fileUpload) {
            fileUpload.addEventListener('change', function(e) {
                var file = e.target.files[0];
                if (file) {
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        var preview = document.getElementById('<%= BannerPreview.ClientID %>');
                        var previewImg = document.getElementById('<%= BannerPreviewImg.ClientID %>');
                        if (preview && previewImg) {
                            previewImg.src = e.target.result;
                            preview.classList.add('has-image');
                            preview.style.display = 'block';
                        }
                    };
                    reader.readAsDataURL(file);
                }
            });
        }
    })();
</script>

</asp:Content>

