<%@ page language="C#" autoeventwireup="true" inherits="student_website, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>信息科技素材库</title>
    <link href="../js/website.css" rel="stylesheet" type="text/css" />
    <!-- 引入KindEditor富文本编辑器 -->
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
</head>
<body>
    <!-- 移除了表单标签，避免按钮点击导致表单提交 -->
    <div id="workHistory"  class="container">
        <div class="header">           
            <div class="button-container">                
                <sp class="banner">
                    <img src="../images/weblogo.png" /> <asp:Label ID="Labelname" runat="server" ></asp:Label> 在线网站设计
                </sp> 
                <button class="btn return-button"  onclick="returnurl();" >返回</button>
                <button class="btn save-button" onclick="savework();" >保存</button>
            </div>
        </div>
        <hr class ="hrclass"/>
        <div class="main-content">
            <!-- 左侧文件夹导航 -->
            <div class="sidebar">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <h3 class="root-title" onclick="goToRoot()">📁 网页目录</h3>                    
                    <button type="button" class="btn btn-success" onclick="showCreateFolderModal()" style="display:none">新建目录</button>
                </div>

                <div class="folder-tree" id="folderTree">
                    <div class="empty-state">
                        <i>📁</i>
                        <p>加载中...</p>
                    </div>
                </div>
                <div class="upload-zone" id="uploadZone">
                    <i class="file-icon" style="font-size: 48px; color: #007bff;">📄</i>
                    <h3>拖放文件到此处上传</h3>
                    <input type="file" id="fileInput" multiple style="display: none;">                    
                    <button type="button" class="btn btn-primary" onclick="document.getElementById('fileInput').click()">选择文件</button>
                    <p style="font-size: 13px; ">支持图片、文档、音频、视频文件</p>
                        <!-- 新增：上传进度条 -->
                    <div id="uploadProgressContainer" style="display: none; width: 100%; margin-top: 15px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span id="uploadFileName" style="font-size: 12px;"></span>
                            <span id="uploadPercent" style="font-size: 12px;">0%</span>
                        </div>
                        <div class="progress-bar" style="width: 100%; height: 6px; background-color: #e9ecef; border-radius: 3px; overflow: hidden;">
                            <div id="uploadProgressBar" style="width: 0%; height: 100%; background-color: #007bff; transition: width 0.3s ease;"></div>
                        </div>
                        <div id="uploadStatus" style="font-size: 12px; text-align: center; margin-top: 5px;"></div>
                    </div>
                    
                </div>
            </div>
            
            <!-- 右侧内容区域 -->
            <div class="content">
                <!-- 文档操作按钮区域 -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                    <h3 id="currentFolderTitle" contenteditable="true" onblur="renameFolderOnBlur(this)" ></h3>
                    <div>                      
                    <button type="button" class="btn btn-primary" onclick="showCreateDocModal()">新建网页</button>  
                    </div>
                </div>
                
                
                <div class="file-list" id="fileList">
                    <div class="empty-state">
                        <i>📂</i>
                        <p>当前文件夹为空</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 新建文件夹模态框 -->
    <div class="modal" id="createFolderModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>新建文件夹</h3>
                <button type="button" class="modal-close" onclick="closeCreateFolderModal()">&times;</button>
            </div>
            <div class="form-group">
                <input type="text" class="form-control" id="newFolderName" placeholder="请输入文件夹名称">
            </div>
            <div style="text-align: right;">
                <button type="button" class="btn" onclick="closeCreateFolderModal()" style="margin-right: 10px;">取消</button>
                <button type="button" class="btn btn-primary" onclick="createFolder()">创建</button>
            </div>
        </div>
    </div>
    
    <!-- 新建网页模态框 -->
    <div class="modal" id="createDocModal">
        <div class="modal-content" style="width: 600px; height: 200px; ">
            <div class="modal-header">
                <h3>新建网页文件名</h3>
                <button type="button" class="modal-close" onclick="closeCreateDocModal()">&times;</button>
            </div>
            <div class="form-group">
                <input type="text" class="form-control" id="docTitle" placeholder="请输入网页文件名">
                <label class="docname">示例：
                    <span class="spname" title="首页">index</span>
                    <span class="spname" title="图片">photo</span>
                    <span class="spname" title="音频">audio</span>
                    <span class="spname" title="视频">video</span>
                    <span class="spname" title="关于">about</span>
                </label>
            </div>
            <div style="text-align: right;">
                <button type="button" class="btn" onclick="closeCreateDocModal()" style="margin-right: 10px;">取消</button>
                <button type="button" class="btn btn-primary" onclick="saveDocument()">创建网页</button>
            </div>
        </div>
    </div>
    
    <!-- 提示消息 -->
    <div id="toast" class="toast hidden">链接已复制到剪贴板</div>

    <script type="text/javascript">
        // 全局变量

        var user="<%=mysnum%>";
        var id = "<%=Id %>";
        var lid = "<%=Lid %>";
        var currentFolderPath = '';
        var editorInstance = null;

$(document).ready(function() {
    $('.spname').click(function() {
       var content = $(this).text();
       $('#docTitle').val(content);
    });
});

        
// 显示图片预览
function showImagePreview(event, fileUrl, fileName) {
    // 阻止事件冒泡
    event.stopPropagation();
    
    // 创建预览容器
    var previewContainer = document.getElementById('imagePreviewContainer');
    if (!previewContainer) {
        previewContainer = document.createElement('div');
        previewContainer.id = 'imagePreviewContainer';
        previewContainer.className = 'image-preview-container';
        previewContainer.onclick = hideImagePreview;
        document.body.appendChild(previewContainer);
    }
    
    // 创建预览内容
    var previewContent = document.createElement('div');
    previewContent.className = 'image-preview-content';
    
    // 创建图片元素
    var previewImage = document.createElement('img');
    previewImage.src = fileUrl;
    previewImage.alt = fileName;
    previewImage.className = 'image-preview-img';
    previewImage.onclick = function(e) {
        e.stopPropagation(); // 阻止点击图片时关闭预览
    };
    
    // 创建关闭按钮
    var closeBtn = document.createElement('button');
    closeBtn.innerHTML = '×';
    closeBtn.className = 'image-preview-close';
    closeBtn.onclick = hideImagePreview;
    
    // 创建图片名称显示
    var fileNameDisplay = document.createElement('div');
    fileNameDisplay.textContent = fileName;
    fileNameDisplay.className = 'image-preview-filename';
    
    // 组装预览内容
    previewContent.appendChild(previewImage);
    previewContent.appendChild(closeBtn);
    previewContent.appendChild(fileNameDisplay);
    
    // 清空容器并添加新内容
    previewContainer.innerHTML = '';
    previewContainer.appendChild(previewContent);
    
    // 显示预览
    previewContainer.style.display = 'flex';
}

// 隐藏图片预览
function hideImagePreview() {
    var previewContainer = document.getElementById('imagePreviewContainer');
    if (previewContainer) {
        previewContainer.style.display = 'none';
    }
}

// 键盘事件支持（按ESC关闭预览）
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        hideImagePreview();
    }
});

        function renameFolderOnBlur(element) {
            element.isEditing = false;
            element.style.backgroundColor = '';
            element.style.border = 'none';
    
            var newName = element.textContent.trim();
            var originalName = currentFolderPath;
    
            // 如果名称未改变或为空，恢复原始名称
            if (!newName || newName === originalName) {
                element.textContent = originalName;
                return;
            }
            // 检查是否在根目录（根目录不允许重命名）
            if (!currentFolderPath) {
                console.log('根目录不能重命名！');
                element.textContent = originalName;
                return;
            }
            // 验证文件夹名称
            if (!/^[a-zA-Z0-9\u4e00-\u9fa5]+$/.test(newName)) {
                alert('文件夹名称只能包含数字、字母和中文，不能包含其他符号！');
                element.textContent = originalName;
                return;
            }
    
            // 调用重命名函数
            renameCurrentFolder(newName, originalName, element);
        }

        // 重命名当前文件夹
        function renameCurrentFolder(newName, originalName, element) {
            //console.log("重命名:",newName, originalName);
            var formData = new FormData();
            formData.append('oldPath', currentFolderPath);
            formData.append('newName', newName);
    
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'website.ashx?action=renamefolder', true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    try {
                        console.log(xhr.responseText);
                        var data = JSON.parse(xhr.responseText);
                        console.log(data);
                        if (data.success) {
                            showToast('文件夹重命名成功');
                            // 更新数据属性
                            element.setAttribute('data-original-name', newName);
                            // 重新加载文件夹树和文件列表
                            loadFolderTree();
                            // 更新当前路径
                            //updateCurrentFolderPathAfterRename(newName);
                        } else {
                            alert('重命名失败: ' + data.message);
                            // 恢复原始名称
                            element.textContent = originalName;
                        }
                    } catch (e) {
                        alert('重命名失败，解析响应错误');
                        element.textContent = originalName;
                    }
                }
            };
            xhr.send(formData);
        }

        function returnurl() {
            if (confirm('是否要离开此页面？') == true) {
                window.location.href = "<%=Fpage %>"
            }
        }
        // 页面加载完成后初始化
        window.onload = function() {
            loadFolderTree();
            loadFiles(currentFolderPath);
            setupDragAndDrop();
            document.getElementById('fileInput').onchange = handleFileSelect;
        };
        
        
        // 加载文件夹树
        function loadFolderTree() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'website.ashx?action=folders&t=' + new Date().getTime(), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    if (xhr.status == 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            document.getElementById('folderTree').innerHTML = renderFolderTree(data);
                        } catch (e) {
                            console.error('解析JSON失败:', e);
                            alert('加载文件夹失败: ' + xhr.responseText);
                        }
                    } else {
                        alert('加载文件夹失败，状态码: ' + xhr.status);
                    }
                }
            };
            xhr.send();
        }

        // 渲染文件夹树
        function renderFolderTree(folders, level) {
            if (level == undefined) level = 0;
            var html = '';
            var padding = level * 20;
            
            if (folders && folders.length > 0) {
                for (var i = 0; i < folders.length; i++) {
                    var folder = folders[i];
                    
                    // 关键修复：正确处理中文路径编码
                    // 不对路径进行编码，直接使用服务器返回的路径
                    var safePath = folder.path;
                    var safeName = folder.name;
                    
                    html += '<div class="folder-item" style="padding-left: ' + padding + 'px" ' +
                           'onclick="selectFolder(\'' + escapeSpecialChars(safePath) + '\', \'' + escapeSpecialChars(safeName) + '\')" ' +
                           'data-folder-path="' + escapeSpecialChars(safePath) + '" ' +
                           'data-folder-name="' + escapeSpecialChars(safeName) + '">' +
                           '<span class="folder-icon">📁</span>' +
                           '<span class="folder-name">' + folder.name + '</span>' +
                           '</div>';
                    
                    if (folder.children && folder.children.length > 0) {
                        html += renderFolderTree(folder.children, level + 1);
                    }
                }
            } else {
                html = '<div class="empty-state"></div>';
            }
            
            return html;
        }
        
        // 转义特殊字符，防止JavaScript错误
        function escapeSpecialChars(str) {
            return str.replace(/'/g, "\\'")
                     .replace(/"/g, '\\"')
                     .replace(/\n/g, "\\n")
                     .replace(/\r/g, "\\r")
                     .replace(/\t/g, "\\t");
        }
        
        // 选择文件夹 - 关键修复：正确处理中文路径
        function selectFolder(folderPath, folderName) {
            // 直接使用服务器返回的路径，不需要解码
            currentFolderPath = folderPath;
            //console.log("当前文件夹：",currentFolderPath);
            // 更新当前文件夹标题
            document.getElementById('currentFolderTitle').textContent = folderName || '';
            
            // 高亮选中的文件夹
            var folderItems = document.getElementsByClassName('folder-item');
            for (var i = 0; i < folderItems.length; i++) {
                folderItems[i].className = folderItems[i].className.replace(' active', '');
            }
            var activeItem = document.querySelector('.folder-item[data-folder-path="' + folderPath + '"]');
            if (activeItem) {
                activeItem.className += ' active';
            }
            
            // 加载文件列表 - 关键修复：直接使用路径，不进行编码
            loadFiles(folderPath);
        }
        
        // 返回根目录
        function goToRoot() {
            selectFolder('', '');
            
            // 移除所有文件夹的高亮状态
            var folderItems = document.getElementsByClassName('folder-item');
            for (var i = 0; i < folderItems.length; i++) {
                folderItems[i].className = folderItems[i].className.replace(' active', '');
            }
        }
        
        // 加载文件列表 - 关键修复：直接使用路径，不进行编码
        function loadFiles(folderPath) {
            var xhr = new XMLHttpRequest();
            // 关键修复：直接使用路径参数，不进行encodeURIComponent编码
            xhr.open('GET', 'website.ashx?action=files&path=' + folderPath + '&t=' + new Date().getTime(), true);
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    try {
                        var files = JSON.parse(xhr.responseText);
                        renderFileList(files);
                    } catch (e) {
                        console.error('解析文件列表失败:', e);
                        alert('加载文件列表失败: ' + xhr.responseText);
                    }
                }
            };
            xhr.send();
        }
        
        // 渲染文件列表 - 关键修复：图片显示缩略图，HTML文档显示查看文档按钮
                // 渲染文件列表
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
                    
                    const fname = encodeURIComponent(file.path.replace(/\\/g, '/'));//文件名编码
                    // 使用真实文件URL
                    let fileUrl = `../website/${user}/${fname}`;
                    const filedel = file.path.replace(/\\/g, '/');
                    let filecopy = `${fname}`;
                                        

                    // 根据当前视图生成不同的HTML结构
                    
                        html += `
                        <div class="file-item list-view">
                            <div class="file-info list-view">
                                <div class="file-thumbnail list-view">
                                    ${isImage ? `<img src="${fileUrl}" alt="${file.name}" style="cursor: zoom-in;" onclick="showImagePreview(event, '${fileUrl}', '${file.name}')">` : `<div style="font-size: 24px; color: #6c757d;">${icon}</div>`}
                                </div>
                                <div class="file-details list-view">
                                    <div class="file-name list-view"><a href="${fileUrl}" target="_blank">${file.name}</a></div>
                                    <div class="file-meta list-view">文件大小 ${size} 日期 ${date}</div>
                                </div>
                            </div>
                            <div class="file-actions">
                                ${isHtml ? `<button type="button" class="btn-info" onclick="editDocument('${fileUrl}', event)">✍设计网页</button>` : `<button type="button" class="btn-info" onclick="copyFileLink('${filecopy}', event)">❐复制链接</button>`}
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
        
        // 查看文档 - 在新窗口中打开HTML文档
        function editDocument(fileUrl, event) {
            // 阻止事件冒泡和默认行为，避免页面刷新
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            
            // 确保URL是完整的（如果是相对路径）
            var editUrl = "htmledit.aspx?lid="+lid+"&html="+ btoa(encodeURIComponent(fileUrl));

            // 在新窗口中打开文档
            window.open(editUrl, '_blank');
            
            // 返回false进一步确保不会触发默认行为
            return false;
        }
        // 查看文档 - 在新窗口中打开HTML文档
        function viewDocument(fileUrl, event) {
            // 阻止事件冒泡和默认行为，避免页面刷新
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            
            // 确保URL是完整的（如果是相对路径）
            var fullUrl = fileUrl;
            if (!fileUrl.startsWith('http')) {
                fullUrl = window.location.origin + (fileUrl.startsWith('/') ? '' : '/') + fileUrl;
            }
            
            // 在新窗口中打开文档
            window.open(fullUrl, '_blank');
            
            // 返回false进一步确保不会触发默认行为
            return false;
        }
        
        // 复制文件链接到剪贴板 - 关键修复：阻止事件冒泡和默认行为
        function copyFileLink(fileUrl, event) {
            // 阻止事件冒泡和默认行为，避免页面刷新
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            
            // 确保URL是完整的（如果是相对路径）
            //var fullUrl = fileUrl;
            //if (!fileUrl.startsWith('http')) {                
            //    fullUrl = window.location.origin + (fileUrl.startsWith('/') ? '' : '/') + fileUrl;
           // }
            fileUrl =decodeURIComponent(fileUrl);
            copyToClipboard(fileUrl);
            showToast('文件链接已复制到剪贴板');
            
            // 返回false进一步确保不会触发默认行为
            return false;
        }
        
        // 复制文本到剪贴板
        function copyToClipboard(text) {
            // 创建临时textarea元素
            var textarea = document.createElement('textarea');
            textarea.value = text;
            document.body.appendChild(textarea);
            
            // 选择文本并复制
            textarea.select();
            textarea.setSelectionRange(0, 99999); // 对于移动设备
            
            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    console.log('复制成功: ' + text);
                } else {
                    console.error('复制失败');
                }
            } catch (err) {
                console.error('复制错误: ', err);
                
                // 如果execCommand失败，尝试使用新的Clipboard API
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(text).then(function() {
                        console.log('使用Clipboard API复制成功');
                    }, function(err) {
                        console.error('使用Clipboard API复制失败: ', err);
                    });
                }
            }
            
            // 移除临时元素
            document.body.removeChild(textarea);
        }
        
        // 显示提示消息
        function showToast(message) {
            var toast = document.getElementById('toast');
            toast.textContent = message;
            toast.classList.remove('hidden');
            
            // 3秒后自动隐藏
            setTimeout(function() {
                toast.classList.add('hidden');
            }, 3000);
        }
        
        // 设置拖放功能
        function setupDragAndDrop() {
            var uploadZone = document.getElementById('uploadZone');
            
            uploadZone.ondragover = function(e) {
                e.preventDefault();
                this.className += ' dragover';
            };
            
            uploadZone.ondragleave = function() {
                this.className = this.className.replace(' dragover', '');
            };
            
            uploadZone.ondrop = function(e) {
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
    // 关键修复：直接使用当前路径，不进行编码
    formData.append('path', currentFolderPath);
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'website.ashx?action=upload', true);
    
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
                            showToast(data.message);
                            loadFiles(currentFolderPath);
                            loadFolderTree();
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
        
        // 显示新建文件夹模态框
        function showCreateFolderModal() {
            document.getElementById('createFolderModal').style.display = 'block';
            document.getElementById('newFolderName').value = '';
            document.getElementById('newFolderName').focus();
        }
        
        // 关闭新建文件夹模态框
        function closeCreateFolderModal() {
            document.getElementById('createFolderModal').style.display = 'none';
        }
        
        // 创建文件夹 - 关键修复：只能在根目录创建
        function createFolder() {
            var folderName = document.getElementById('newFolderName').value.trim();
            
            if (!folderName) {
                alert('请输入文件夹名称！');
                return;
            }
            
            // 检查文件夹名称是否包含路径分隔符，防止创建多级目录
            if (folderName.includes('\\') || folderName.includes('/') || folderName.includes(':')) {
                alert('文件夹名称不能包含路径分隔符（\\ / :）！');
                return;
            }
            
            // 检查文件夹名称长度
            if (folderName.length > 8) {
                alert('文件夹名称不能超过8个字符！');
                return;
            }
                
            // 新增：检查文件夹名称是否只包含数字、字母和中文
            if (!/^[a-zA-Z0-9\u4e00-\u9fa5]+$/.test(folderName)) {
                alert('文件夹名称只能包含数字、字母和中文，不能包含其他符号！');
                return;
            }
    
            var formData = new FormData();
            formData.append('name', folderName);
            // 关键修复：固定路径为空字符串，只能在根目录创建
            formData.append('path', '');
            
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'website.ashx?action=createfolder', true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.success) {
                            closeCreateFolderModal();
                            loadFolderTree();
                            showToast(data.message);
                        } else {
                            alert('创建失败: ' + data.message);
                        }
                    } catch (e) {
                        alert('创建失败，解析响应错误');
                    }
                }
            };
            xhr.send(formData);
        }
        
        // 显示新建文档模态框
        function showCreateDocModal() {
            document.getElementById('createDocModal').style.display = 'block';
            document.getElementById('docTitle').value = '';            
            document.getElementById('docTitle').focus();
        }
        
        // 关闭新建文档模态框
        function closeCreateDocModal() {
            document.getElementById('createDocModal').style.display = 'none';
            
            // 销毁KindEditor实例
            if (editorInstance) {
                editorInstance.remove();
                editorInstance = null;
            }
        }
        
        // 保存文档 - 关键修复：保存为HTML格式
        function saveDocument() {
            var title = document.getElementById('docTitle').value.trim();
            
            if (!title) {
                alert('请输入网页文件名！');
                return;
            }
            title.replace(/\s+/g, '');
            // 检查标题是否包含非法字符
            if (title.includes('\\') || title.includes('/') || title.includes(':') || 
                title.includes('*') || title.includes('?') || title.includes('"') || 
                title.includes('<') || title.includes('>') || title.includes('|')) {
                alert('文档标题不能包含以下字符：\\ / : * ? " < > |');
                return;
            }
            // 新增：检查标题是否只包含数字、字母、中文
            if (!/^[a-zA-Z0-9\u4e00-\u9fa5]+$/.test(title)) {
                alert('文件夹名称只能包含数字、字母和中文，不能包含其他符号！');
                return;
            }
            // 确保文件扩展名
            var fileName = title;
            if (!fileName.toLowerCase().endsWith('.html')) {
                fileName += '.html';
            }
            
            // 创建完整的HTML文档
            var fullHtmlContent = `<!DOCTYPE html>
<html>
<head>
    <title> </title>
</head>
<body>

</body>
</html>`;
            
            // 创建Blob对象，类型为text/html
            var blob = new Blob([fullHtmlContent], { type: 'text/html;charset=utf-8' });
            
            // 创建FormData并添加文件
            var formData = new FormData();
            formData.append('files', blob, fileName);
            formData.append('path', currentFolderPath);
            
            // 使用上传接口保存文档
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'website.ashx?action=upload', true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.success) {
                            closeCreateDocModal();
                            loadFiles(currentFolderPath);
                            showToast('文档创建成功');
                        } else {
                            alert('创建文档失败: ' + data.message);
                        }
                    } catch (e) {
                        alert('创建文档失败，解析响应错误');
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
                xhr.open('GET', 'website.ashx?action=delete&path=' + filePath, true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == 4 && xhr.status == 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data.success) {
                                loadFiles(currentFolderPath);
                                showToast(data.message);
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

       function savework() { 
	        var preview = document.getElementById("workHistory");
            var htmlcode ="";// preview.innerHTML;使用缩略图预览        	
            html2canvas(preview).then(pic => {					
        	    var urls = '../student/uploadtopic.ashx?id=' + id;
			    var title = "";
			    var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			    var Content = htmlcode;
			    var Extension = "website";
			    var formData = new FormData();
			    formData.append('title', title);
			    formData.append('cover', Cover);
			    formData.append('content', Content);
			    formData.append('ext', Extension);

        	    $.ajax({
        	        url: urls,
        	        type: 'POST',
        	        cache: false,
        	        data: formData,
        	        processData: false,
        	        contentType: false
        	    }).done(function (res) {
        	        alert("保存成功！");
        	    }).fail(function (res) {
        	        console.log(res)
        	    }); 	
            
            });		
        	
        }

		function blob(dataURI) {
            var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
            var byteString = atob(dataURI.split(',')[1]);
            var arrayBuffer = new ArrayBuffer(byteString.length);
            var intArray = new Uint8Array(arrayBuffer);

            for (var i = 0; i < byteString.length; i++) {
                intArray[i] = byteString.charCodeAt(i);
            }
            return new Blob([intArray], { type: mimeString });
        }

    </script>
</body>
</html>
