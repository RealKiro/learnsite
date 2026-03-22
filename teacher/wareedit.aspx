<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" validaterequest="false" autoeventwireup="true" inherits="teacher_wareedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<link rel="stylesheet" type="text/css" href="addpage-common.css" />
<style>
    /* 课件上传区域专属样式 */
    .wa-file-area { display: flex; gap: 24px; min-height: 380px; }
    .wa-upload-sidebar { width: 260px; flex-shrink: 0; position: relative; }
    .wa-upload-zone {
        border: 2px dashed #c7d2fe; border-radius: 12px; padding: 30px 20px;
        text-align: center; background: linear-gradient(180deg, #eef2ff 0%, #e0e7ff 100%);
        cursor: pointer; transition: all 0.3s; position: sticky; top: 20px;
    }
    .wa-upload-zone:hover { background: linear-gradient(180deg, #e0e7ff 0%, #c7d2fe 100%); border-color: #818cf8; }
    .wa-upload-zone.dragover { background: #c7d2fe; border-color: #6366f1; }
    .wa-upload-zone .wa-upload-icon { font-size: 42px; margin-bottom: 8px; }
    .wa-upload-zone h3 { font-size: 14px; font-weight: 600; color: #4338ca; margin: 8px 0; }
    .wa-upload-zone p { font-size: 12px; color: #6366f1; margin: 8px 0 0; }
    .wa-upload-zone .wa-select-btn {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500;
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border: none; cursor: pointer; transition: all .18s; margin-top: 6px;
        box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .wa-upload-zone .wa-select-btn:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); box-shadow: 0 4px 12px rgba(99,102,241,.3); }
    .wa-file-content { flex: 1; min-width: 0; }

    /* 文件列表 */
    .file-list.list-view { border: 1px solid #e8ecf1; border-radius: 10px; overflow: hidden; }
    .file-item.list-view {
        display: flex; justify-content: space-between; align-items: center;
        padding: 10px 14px; border-bottom: 1px solid #f1f5f9; transition: background .12s;
    }
    .file-item.list-view:last-child { border-bottom: none; }
    .file-item.list-view:hover { background: #f8fafc; }
    .file-info.list-view { display: flex; align-items: center; flex: 1; }
    .file-thumbnail.list-view {
        width: 52px; height: 52px; margin-right: 12px; border-radius: 8px;
        overflow: hidden; display: flex; align-items: center; justify-content: center;
        background: #f1f5f9;
    }
    .file-thumbnail.list-view img { max-width: 100%; max-height: 100%; object-fit: contain; }
    .file-details.list-view { flex: 1; text-align: left; }
    .file-name.list-view { font-weight: 600; font-size: 13px; margin-bottom: 3px; word-break: break-all; color: #334155; }
    .file-name.list-view a { color: #334155; text-decoration: none; }
    .file-name.list-view a:hover { color: #6366f1; }
    .file-meta.list-view { color: #94a3b8; font-size: 12px; }
    .empty-state { padding: 40px; text-align: center; color: #94a3b8; font-size: 14px; }

    /* 文件操作按钮 */
    .btn-danger {
        background: #fee2e2; color: #dc2626; border: 1px solid #fecaca;
        border-radius: 6px; padding: 4px 10px; font-size: 12px; cursor: pointer; transition: all .15s;
    }
    .btn-danger:hover { background: #dc2626; color: #fff; border-color: #dc2626; }
    .btn-success {
        background: #dcfce7; color: #16a34a; border: 1px solid #bbf7d0;
        border-radius: 6px; padding: 4px 10px; font-size: 12px; cursor: pointer; transition: all .15s; margin-right: 6px;
    }
    .btn-success:hover { background: #16a34a; color: #fff; border-color: #16a34a; }

    /* 进度条 */
    .wa-progress-wrap { margin-top: 16px; }
    .wa-progress-info { display: flex; justify-content: space-between; margin-bottom: 4px; font-size: 11px; color: #6366f1; }
    .wa-progress-bar { width: 100%; height: 6px; background: #e0e7ff; border-radius: 3px; overflow: hidden; }
    .wa-progress-bar-inner { height: 100%; background: #6366f1; transition: width 0.3s ease; border-radius: 3px; }
    .wa-progress-status { font-size: 11px; text-align: center; margin-top: 4px; color: #818cf8; }
</style>

<div class="sa-page">
    <div class="sa-header">
        <div class="sa-title-wrap">
            <div class="sa-title">
                <span class="sa-icon"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></span>
                修改课件
            </div>
            <div class="sa-subtitle">修改课件主题信息，管理课件文件，设置课件首页</div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                基本信息
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>课件主题</label>
                    <asp:TextBox ID="Texttitle" runat="server" SkinID="TextBoxNormal" Width="400px"></asp:TextBox>
                </div>
                <div class="sa-form-checks">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Checked="True" />
                </div>
            </div>
            <div class="sa-form-row">
                <div class="sa-form-group">
                    <label>课件首页</label>
                    <asp:TextBox ID="TextBoxHtml" runat="server" Width="400px"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                文件管理
            </div>
        </div>
        <div class="sa-card-body">
            <div class="wa-file-area">
                <div class="wa-upload-sidebar">
                    <div class="wa-upload-zone" id="uploadZone">
                        <div class="wa-upload-icon">📄</div>
                        <h3>拖放文件到此处上传</h3>
                        <input type="file" id="fileInput" multiple style="display: none;">
                        <button type="button" class="wa-select-btn" onclick="document.getElementById('fileInput').click()">选择文件</button>
                        <p>支持图片、文档、音频、视频文件</p>
                        <div id="uploadProgressContainer" class="wa-progress-wrap" style="display: none;">
                            <div class="wa-progress-info">
                                <span id="uploadFileName"></span>
                                <span id="uploadPercent">0%</span>
                            </div>
                            <div class="wa-progress-bar">
                                <div id="uploadProgressBar" class="wa-progress-bar-inner" style="width: 0%;"></div>
                            </div>
                            <div id="uploadStatus" class="wa-progress-status"></div>
                        </div>
                    </div>
                </div>
                <div class="wa-file-content">
                    <div class="file-list" id="fileList">
                        <div class="empty-state">当前文件夹为空</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="sa-card">
        <div class="sa-card-header">
            <div class="sa-card-title">
                <svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
                提交
            </div>
        </div>
        <div class="sa-card-body">
            <div class="sa-actions">
                <asp:Button ID="Btnedit" runat="server" Text="修改主题" OnClick="Btnedit_Click" CssClass="sa-btn sa-btn-primary" />
                <asp:Button ID="BtnCourse" runat="server" Text="学案返回" OnClick="BtnCourse_Click" CssClass="sa-btn" />
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
        var cid = "<%=Cid %>";
    
        // 页面加载完成后初始化
        window.onload = function() {
            loadFiles();
            setupDragAndDrop();
            document.getElementById('fileInput').onchange = handleFileSelect;
        };
        // 加载文件列表 - 关键修复：直接使用路径，不进行编码
        function loadFiles() {
            var xhr = new XMLHttpRequest();
            // 关键修复：直接使用路径参数，不进行encodeURIComponent编码
            xhr.open('GET', 'ware.ashx?action=files&cid=' + cid + '&t=' + new Date().getTime(), true);
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    try {
                        var files = JSON.parse(xhr.responseText);
                        //console.error('文件列表结构:', files);
                        renderFileList(files);
                    } catch (e) {
                        console.error('解析文件列表失败:', e);
                        alert('加载文件列表失败: ' + xhr.responseText);
                    }
                }
            };
            xhr.send();
        }

        // 渲染文件列表 - 关键修复：图片显示缩略图
         function renderFileList(files) {
            const fileList = document.getElementById('fileList');
            
            if (files && files.length > 0) {
                let html = '';
                
                for (let i = 0; i < files.length; i++) {
                    const file = files[i];
                    const icon = getFileIcon(file.name);
                    const size = formatFileSize(file.size);
                    const isImage = isImageFile(file.name);
                    const isHtml = isHtmlFile(file.name);
                    const date = file.date;
                    //console.log("测试：\r\n",date);

                    const fname = encodeURIComponent(file.path.replace(/\\/g, '/'));//文件名编码
                    // 使用真实文件URL
                    let fileUrl = `../store/${cid}/${fname}`;
                    const filedel = file.path.replace(/\\/g, '/');
                    let filecopy = `${fname}`;
                                        

                    // 根据当前视图生成不同的HTML结构
                    
                        html += `
                        <div class="file-item list-view">
                            <div class="file-info list-view">
                                <div class="file-thumbnail list-view">
                                    ${isImage ? `<img src="${fileUrl}" alt="${file.name}"  >` : `<div style="font-size: 24px; color: #6c757d;">${icon}</div>`}
                                </div>
                                <div class="file-details list-view">
                                    <div class="file-name list-view"><a href="${fileUrl}" target="_blank">${file.name}</a></div>
                                    <div class="file-meta list-view">文件大小 ${size} 日期 ${date}</div>
                                </div>
                            </div>
                            <div class="file-actions">
                                ${isHtml ? `<button type="button" class="btn-success"  onclick="selectFile('${file.name}','${fileUrl}')" title="设置为首页">设置</button>` : ""}
                                <button type="button" class="btn-danger" onclick="deleteFile('${filedel}')" title="删除">✖</button>
                            </div>
                        </div>`;
                    
                }
                
                fileList.innerHTML = html;
            } else {
                fileList.innerHTML = '<div class="empty-state"><i>📂</i><p>当前文件夹为空</p></div>';
            }
        }


        // 判断是否为图片文件
        function isImageFile(filename) {
            var imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
            var ext = (filename.split('.').pop() || '').toLowerCase();
            return imageExtensions.indexOf('.' + ext) !== -1;
        }
        
        // 判断是否为HTML文件
        function isHtmlFile(filename) {
            var ext = (filename.split('.').pop() || '').toLowerCase();
            return ext === 'html' || ext === 'htm';
        }

        // 获取文件图标
        function getFileIcon(filename) {
            var ext = (filename.split('.').pop() || '').toLowerCase();
            var icons = {
                'jpg': '🖼️', 'jpeg': '🖼️', 'png': '🖼️', 'gif': '🖼️', 'bmp': '🖼️', 'webp': '🖼️',
                'pdf': '📕',
                'doc': '📄', 'docx': '📄',
                'mp4': '🎬', 'avi': '🎬', 'mov': '🎬', 'mkv': '🎬',
                'mp3': '🎵', 'wav': '🎵', 'flac': '🎵',
                'txt': '📝',
                'html': '🌐', 'htm': '🌐',
                'zip': '📦', 'rar': '📦', '7z': '📦',
                'default': '📄'
            };
            
            return icons[ext] || icons.default;
        }
        
        // 格式化文件大小
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 B';
            var k = 1024;
            var sizes = ['B', 'KB', 'MB', 'GB'];
            var i = Math.floor(Math.log(bytes) / Math.log(k));
            return (bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i];
        }

    // 设置拖放功能
    function setupDragAndDrop() {
        var uploadZone = document.getElementById('uploadZone');

        uploadZone.ondragover = function (e) {
            e.preventDefault();
            this.className += ' dragover';
        };

        uploadZone.ondragleave = function () {
            this.className = this.className.replace(' dragover', '');
        };

        uploadZone.ondrop = function (e) {
            e.preventDefault();
            this.className = this.className.replace(' dragover', '');
            handleDroppedFiles(e.dataTransfer.files);
        };
    }

    // 处理拖放的文件
    function handleDroppedFiles(files) {
        uploadFiles(files);
    }

    // 处理选择的文件
    function handleFileSelect(e) {
        uploadFiles(e.target.files);
        e.target.value = '';
    }
// 上传文件 - 关键修复：直接使用当前路径，不进行编码
function uploadFiles(files) {
    if (!files || files.length === 0) return;
    
    // 显示进度条
    var progressContainer = document.getElementById('uploadProgressContainer');
    var progressBar = document.getElementById('uploadProgressBar');
    var progressPercent = document.getElementById('uploadPercent');
    var uploadStatus = document.getElementById('uploadStatus');
    var fileName = document.getElementById('uploadFileName');
    
    // 检查单个文件大小
    var maxFileSize = 100 ; // 200MB
    var filesize = Math.trunc(files[0].size/1024/1024);
    if (filesize > maxFileSize) {
        alert(files[0].name + '\r\n\r\n 文件大小'+filesize+'MB，超过限制（最大'+maxFileSize+'MB）');
        return;
    }

    // 显示第一个文件名
    fileName.textContent = files[0].name;
    progressContainer.style.display = 'block';
    progressBar.style.width = '0%';
    progressPercent.textContent = '0%';
    uploadStatus.textContent = '准备上传...';
    
    var formData = new FormData();
    for (var i = 0; i < files.length; i++) {
        formData.append('files', files[i]);
    }
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'ware.ashx?action=upload&cid='+cid, true);
    
    // 添加上传进度监听
    xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
            var percentComplete = (e.loaded / e.total) * 100;
            var roundedPercent = Math.round(percentComplete);
            
            progressBar.style.width = percentComplete + '%';
            progressPercent.textContent = roundedPercent + '%';
            
            if (percentComplete < 100) {
                uploadStatus.textContent = '上传中...';
            }
        }
    };
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        progressBar.style.width = '100%';
                        progressPercent.textContent = '100%';
                        uploadStatus.textContent = '上传完成！';
                        
                        // 延迟隐藏进度条，让用户看到完成状态
                        setTimeout(function() {
                            progressContainer.style.display = 'none';
                            loadFiles();
                        }, 1000);
                    } else {
                        uploadStatus.textContent = '上传失败: ' + data.message;
                        progressBar.style.backgroundColor = '#dc3545';
                        setTimeout(function() {
                            progressContainer.style.display = 'none';
                            alert('上传失败: ' + data.message);
                        }, 2000);
                    }
                } catch (e) {
                    uploadStatus.textContent = '上传失败，解析响应错误';
                    progressBar.style.backgroundColor = '#dc3545';
                    setTimeout(function() {
                        progressContainer.style.display = 'none';
                        alert('上传失败，解析响应错误');
                    }, 2000);
                }
            } else {
                uploadStatus.textContent = '上传失败，文件过大，状态码: ' + xhr.status;
                progressBar.style.backgroundColor = '#dc3545';
                setTimeout(function() {
                    progressContainer.style.display = 'none';
                    alert('上传失败，文件过大，状态码: ' + xhr.status);
                }, 2000);
            }
        }
    };
    
    xhr.send(formData);
}

// 删除文件 - 关键修复：直接使用文件路径，不进行编码
function deleteFile(filePath) {
    if (confirm('确定要删除这个文件吗？')) {
        var xhr = new XMLHttpRequest();
        console.log('删除文件，原始路径:', filePath);
        xhr.open('GET', 'ware.ashx?action=delete&cid='+cid+'&path=' + filePath, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        loadFiles();
                    } else {
                        alert('删除失败: ' + data.message);
                    }
                } catch (e) {
                    alert('删除失败，解析响应错误');
                }
            }
        };
        xhr.send();
    }
}
    
function selectFile(fileName, filePath) {
    // 使用服务端动态输出的客户端 ID，避免硬编码导致找不到元素
    var box = document.getElementById('<%= TextBoxHtml.ClientID %>');
    if (!box) {
        alert('找不到课件首页输入框，请刷新页面再试');
        return;
    }
    var decoded = decodeURIComponent(filePath);
    box.value = decoded;
    // 视觉反馈：输入框闪烁提示设置成功
    box.style.transition = 'all .2s';
    box.style.borderColor = '#6366f1';
    box.style.background  = '#eef2ff';
    box.style.color       = '#4f46e5';
    setTimeout(function() {
        box.style.borderColor = '';
        box.style.background  = '';
        box.style.color       = '';
    }, 1200);
    // 按钮状态
    var btns = document.querySelectorAll('.btn-success');
    for (var i = 0; i < btns.length; i++) {
        btns[i].textContent = '设置';
        btns[i].style.background = '';
    }
    if (event && event.target) {
        event.target.textContent = '✓ 已设置';
        event.target.style.background = '#16a34a';
    }
    console.log('课件首页已设置：', decoded);
}
</script>


</asp:Content>