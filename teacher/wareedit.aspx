<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" validaterequest="false" autoeventwireup="true" inherits="teacher_wareedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>    
    .content {
        flex: 1;
        padding: 20px;
    }   
    .main-content {
        display: flex;
        background: white;
        border-radius: 0 0 10px 10px;
        min-height: 50vh;
        background: #f8f9fa;
        border-right: 1px solid #dee2e6;
        padding: 20px;
    }
            
    .sidebar {
        width: 300px;
    }
    .upload-zone {
        border: 2px dashed #007bff;
        border-radius: 10px;
        padding: 30px;
        text-align: center;
        background: #b5dbfa;
        position:fixed;
        cursor: pointer;
        transition: all 0.3s;    
        width: 240px;
        height: 380px;
            
    }
            
    .upload-zone:hover {
        background: #e3f2fd;
        border-color: #0056b3;
    }
            
    .upload-zone.dragover {
        background: #bbdefb;
        border-color: #1976d2;
    }
    /* 进度条样式 */
.progress-bar {
    width: 100%;
    height: 6px;
    background-color: #e9ecef;
    border-radius: 3px;
    overflow: hidden;
}

.progress-bar-inner {
    height: 100%;
    background-color: #007bff;
    transition: width 0.3s ease;
    border-radius: 3px;
}

.upload-progress-info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 5px;
    font-size: 12px;
    color: #6c757d;
}

.upload-status {
    font-size: 12px;
    text-align: center;
    margin-top: 5px;
    color: #6c757d;
}
            
    /* 列表视图样式 */
    .file-list.list-view {
        border: 1px solid #dee2e6;
        border-radius: 5px;
        overflow: hidden;
    }
            
    .file-item.list-view {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 6px 8px;
        border-bottom: 1px solid #eee;
    }
            
    .file-item.list-view:last-child {
        border-bottom: none;
    }
            
    .file-item.list-view:hover {
        background: #f8f9fa;
    }
            
    .file-info.list-view {
        display: flex;
        align-items: center;
        flex: 1;
    }
            
    .file-thumbnail.list-view {
        width: 60px;
        height: 60px;
        margin-right: 10px;
        border-radius: 5px;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
    }
            
    .file-thumbnail.list-view img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
    }
            
    .file-details.list-view {
        flex: 1;
        text-align: left;
    }
            
    .file-name.list-view {
        font-weight: bold;
        margin-bottom: 5px;
        word-break: break-all;
    }
            
    .file-meta.list-view {
        color: #6c757d;
        font-size: 0.85em;
        
    }
    
              
    .btn-info {
        background: #17a2b8;
        color: white;
    }  
            
    .btn-danger {
        background: #dc3545;
        color: white;
        margin-left:10px;
        border: 0px;
        cursor:pointer;
    }
    .btn-danger:hover{        
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.3); /* 添加阴影 */
    }
            
    .btn-success {
        background: #28a745;
        color: white;
        border: 0px;
        cursor:pointer;
    }
    .btn-success:hover {
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.3); /* 添加阴影 */
    }
            
    .btn-primary {
        background: #007bff;
        color: white;
    }
</style>
<div  class="cplace">
    <div  class="cleft">
        课件主题：<asp:TextBox ID="Texttitle" runat="server"  SkinID="TextBoxNormal" 
            Width="220px" ></asp:TextBox>
        <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布"  Checked="True" />
            &nbsp; 课件首页<asp:TextBox ID="TextBoxHtml" runat="server" Width="300px"></asp:TextBox>
        <br /><br />
    </div>
     <div class="main-content">
            <!-- 左侧文件夹导航 -->
            <div class="sidebar">
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
                <div class="file-list" id="fileList">
                    <div class="empty-state">
                    </div>
                </div>
            </div>
        </div>
     <div  class="placehold">
         <br />
              <asp:Button ID="Btnedit" runat="server"  Text="修改主题" OnClick="Btnedit_Click"  SkinID="BtnNormal" />&nbsp;&nbsp;&nbsp;
              <asp:Button ID="BtnCourse" runat="server"  Text="学案返回" OnClick="BtnCourse_Click"  SkinID="BtnNormal" /><br />
         <br />
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
    
function selectFile(fileName,filePath) {

    var TextBoxHtml = document.getElementById('ctl00_Content_TextBoxHtml');
    TextBoxHtml.value = decodeURIComponent(filePath);
    console.log("设置为首页",filePath);
    
}
</script>


</asp:Content>