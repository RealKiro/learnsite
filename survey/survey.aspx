<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Survey_survey, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link href="../teacher/show-common.css" rel="stylesheet" type="text/css" />

<style>
    /* ===== 调查页面特殊样式 ===== */
    .survey-stats {
        display: grid !important;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)) !important;
        gap: 16px !important;
        margin-bottom: 20px !important;
    }
    
    .survey-stat-item {
        display: flex !important;
        flex-direction: column !important;
        gap: 8px !important;
        padding: 16px !important;
        background: linear-gradient(135deg, #f8fafc, #f1f5f9) !important;
        border: 1px solid #e5e7eb !important;
        border-radius: 10px !important;
        transition: all 0.2s ease !important;
    }
    
    .survey-stat-item:hover {
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08) !important;
    }
    
    .survey-stat-label {
        font-size: 12px !important;
        color: #64748b !important;
        font-weight: 600 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    
    .survey-stat-value {
        font-size: 20px !important;
        color: #1e293b !important;
        font-weight: 700 !important;
    }
    
    /* GridView 样式优化 */
    .survey-grid-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
    }
    
    .survey-grid-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
    }
    
    .survey-grid-card .GridViewInfo {
        width: 100% !important;
        border: none !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
    }
    
    .survey-grid-card .GridViewInfo th {
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%) !important;
        color: #334155 !important;
        font-weight: 600 !important;
        font-size: 13px !important;
        padding: 14px 16px !important;
        text-align: left !important;
        border-bottom: 2px solid #e5e7eb !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    
    .survey-grid-card .GridViewInfo td {
        padding: 14px 16px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        color: #475569 !important;
        font-size: 14px !important;
        vertical-align: middle !important;
    }
    
    .survey-grid-card .GridViewInfo tr:hover td {
        background: #f8fafc !important;
    }
    
    .survey-grid-card .GridViewInfo tr:last-child td {
        border-bottom: none !important;
    }
    
    .survey-grid-card .GridViewInfo a {
        color: #10b981 !important;
        text-decoration: none !important;
        font-weight: 600 !important;
        padding: 6px 12px !important;
        border-radius: 6px !important;
        transition: all 0.2s ease !important;
        display: inline-block !important;
    }
    
    .survey-grid-card .GridViewInfo a:hover {
        background: #d1fae5 !important;
        color: #059669 !important;
    }
    
    /* 按钮组样式 */
    .survey-button-group {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 12px !important;
        margin: 24px 0 !important;
    }
    
    /* 修复 Button 控件样式 - 使用更高优先级 */
    .survey-button-group input[type="submit"] {
        min-width: 120px !important;
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
        height: auto !important;
        line-height: normal !important;
    }
    
    .survey-button-group input[type="submit"]:hover {
        background: #f8fafc !important;
        border-color: #cbd5e1 !important;
        transform: translateY(-1px) !important;
    }
    
    /* 主按钮样式 - 第一个按钮 */
    .survey-button-group input[type="submit"]#<%= Btnadd.ClientID %> {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
        color: #fff !important;
        border-color: transparent !important;
        box-shadow: 0 3px 12px rgba(5,150,105,.25) !important;
    }
    
    .survey-button-group input[type="submit"]#<%= Btnadd.ClientID %>:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 6px 20px rgba(5,150,105,.35) !important;
    }
    
    /* 批量操作工具栏样式 */
    .batch-toolbar {
        padding: 16px !important;
        border-bottom: 1px solid #e5e7eb !important;
        background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%) !important;
        display: flex !important;
        align-items: center !important;
        gap: 12px !important;
    }
    
    .batch-toolbar label {
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        cursor: pointer !important;
        user-select: none !important;
        padding: 6px 12px !important;
        background: white !important;
        border: 1.5px solid #e2e8f0 !important;
        border-radius: 8px !important;
        transition: all 0.2s ease !important;
    }
    
    .batch-toolbar label:hover {
        background: #f8fafc !important;
        border-color: #10b981 !important;
    }
    
    .batch-toolbar input[type="checkbox"] {
        width: 18px !important;
        height: 18px !important;
        cursor: pointer !important;
        accent-color: #10b981 !important;
    }
    
    .batch-toolbar span {
        font-size: 14px !important;
        font-weight: 600 !important;
        color: #475569 !important;
    }
    
    #btnBatchDelete {
        padding: 8px 20px !important;
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%) !important;
        color: white !important;
        border: none !important;
        border-radius: 8px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        box-shadow: 0 2px 8px rgba(239,68,68,0.25) !important;
    }
    
    #btnBatchDelete:hover {
        background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%) !important;
        box-shadow: 0 4px 12px rgba(239,68,68,0.35) !important;
        transform: translateY(-1px) !important;
    }
    
    #btnBatchDelete:disabled {
        background: #9ca3af !important;
        cursor: not-allowed !important;
        box-shadow: none !important;
        transform: none !important;
    }
    
    #selectedCount {
        font-size: 13px !important;
        color: #64748b !important;
        margin-left: 8px !important;
        padding: 6px 12px !important;
        background: white !important;
        border: 1px solid #e2e8f0 !important;
        border-radius: 6px !important;
    }
    
    #selectedCount strong {
        color: #10b981 !important;
        font-size: 16px !important;
    }
    
    /* 表格内复选框样式 */
    .question-checkbox {
        width: 18px !important;
        height: 18px !important;
        cursor: pointer !important;
        accent-color: #10b981 !important;
    }
    
    /* 强制限制复选框列和序号列的宽度 */
    .GridViewInfo th:first-child,
    .GridViewInfo td:first-child {
        width: 40px !important;
        max-width: 40px !important;
        min-width: 40px !important;
        padding: 8px 8px 8px 12px !important; /* 左边padding 12px，右边8px */
        text-align: left !important;
    }
    
    .GridViewInfo th:nth-child(2),
    .GridViewInfo td:nth-child(2) {
        width: 35px !important;
        max-width: 35px !important;
        min-width: 35px !important;
        padding: 8px 0px 8px 4px !important; /* 右边padding改为0，更紧凑 */
        text-align: left !important; /* 左对齐 */
    }
    
    /* 调查试题列 - 让它自动扩展 */
    .GridViewInfo th:nth-child(3),
    .GridViewInfo td:nth-child(3) {
        width: auto !important;
        min-width: 300px !important;
        padding-left: 0px !important; /* 移除左边距，向左移动 */
    }
    
    /* 删除按钮美化 */
    .GridViewInfo a[id*="BtnDel"] {
        color: #ef4444 !important;
        background: #fef2f2 !important;
        padding: 6px 14px !important;
        border-radius: 6px !important;
        font-weight: 600 !important;
        transition: all 0.2s ease !important;
        border: 1px solid #fecaca !important;
    }
    
    .GridViewInfo a[id*="BtnDel"]:hover {
        background: #fee2e2 !important;
        color: #dc2626 !important;
        border-color: #fca5a5 !important;
        transform: translateY(-1px) !important;
        box-shadow: 0 2px 8px rgba(239,68,68,0.15) !important;
    }
    }
    
    .survey-button-group input[type="submit"]#<%= Btnadd.ClientID %>:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 6px 20px rgba(5,150,105,.35) !important;
        transform: translateY(-1px) !important;
        color: #fff !important;
    }
    
    /* 修复 ImageButton 显示问题 */
    .show-actions img[src],
    .survey-button-group img[src] {
        display: none !important;
    }
    
    .show-actions input[type="image"] {
        background-size: 0 !important;
        background-image: none !important;
        text-indent: 0 !important;
        width: auto !important;
        height: auto !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
        font-size: 14px !important;
    }
    
    /* 按钮包装器样式 */
    .btn-icon-wrapper {
        display: inline-flex !important;
        align-items: center !important;
    }
    
    .btn-icon-wrapper:hover {
        transform: translateY(-1px) !important;
    }
    
    /* 弹窗样式 */
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: 9998;
        animation: fadeIn 0.2s ease;
    }
    
    .modal-container {
        display: none;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: #fff;
        border-radius: 16px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        z-index: 9999;
        max-width: 900px;
        width: 90%;
        max-height: 85vh;
        overflow: hidden;
        animation: slideUp 0.3s ease;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    @keyframes slideUp {
        from { opacity: 0; transform: translate(-50%, -45%); }
        to { opacity: 1; transform: translate(-50%, -50%); }
    }
    
    .modal-header {
        padding: 20px 28px;
        border-bottom: 1px solid #e5e7eb;
        background: linear-gradient(135deg, #059669 0%, #10b981 100%);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 700;
        color: #fff;
    }
    
    .modal-close {
        width: 32px;
        height: 32px;
        border: none;
        background: rgba(255,255,255,0.2);
        border-radius: 8px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s;
        color: #fff;
        font-size: 20px;
        line-height: 1;
    }
    
    .modal-close:hover {
        background: rgba(255,255,255,0.3);
        transform: rotate(90deg);
    }
    
    .modal-body {
        padding: 0;
        height: calc(85vh - 140px);
        overflow: hidden;
    }
    
    .modal-iframe {
        width: 100%;
        height: 100%;
        border: none;
    }
    
    .modal-footer {
        padding: 16px 28px;
        border-top: 1px solid #e5e7eb;
        display: flex;
        gap: 12px;
        justify-content: flex-end;
        background: #f8fafc;
    }
    
    .modal-btn {
        padding: 10px 24px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        transition: all 0.2s;
        font-family: 'Microsoft YaHei', sans-serif;
    }
    
    .modal-btn-primary {
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff;
        box-shadow: 0 3px 12px rgba(5,150,105,.25);
    }
    
    .modal-btn-primary:hover {
        background: linear-gradient(135deg, #047857, #059669);
        box-shadow: 0 6px 20px rgba(5,150,105,.35);
        transform: translateY(-1px);
    }
    
    .modal-btn-secondary {
        background: #fff;
        color: #475569;
        border: 1.5px solid #e2e8f0;
    }
    
    .modal-btn-secondary:hover {
        background: #f8fafc;
        border-color: #cbd5e1;
    }
    
    /* GridView 列宽优化 */
    .survey-grid-card .GridViewInfo td:nth-child(1) {
        width: 60px !important;
        white-space: nowrap !important;
    }
    
    .survey-grid-card .GridViewInfo td:nth-child(2) {
        width: auto !important;
        min-width: 300px !important;
        white-space: normal !important;
        word-wrap: break-word !important;
    }
    
    .survey-grid-card .GridViewInfo td:nth-child(3) {
        width: 100px !important;
        white-space: nowrap !important;
    }
    
    .survey-grid-card .GridViewInfo td:nth-child(4),
    .survey-grid-card .GridViewInfo td:nth-child(5),
    .survey-grid-card .GridViewInfo td:nth-child(6),
    .survey-grid-card .GridViewInfo td:nth-child(7) {
        width: 80px !important;
        white-space: nowrap !important;
    }
    
    /* 链接按钮样式 */
    .survey-grid-card .GridViewInfo a.modal-link {
        display: inline-block;
        padding: 6px 14px;
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff !important;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        font-size: 13px;
        transition: all 0.2s;
        cursor: pointer;
    }
    
    .survey-grid-card .GridViewInfo a.modal-link:hover {
        background: linear-gradient(135deg, #047857, #059669);
        box-shadow: 0 4px 12px rgba(5,150,105,.3);
        transform: translateY(-1px);
    }
</style>

<script type="text/javascript">
    // 弹窗管理
    var modalOverlay, modalContainer, modalIframe;
    
    function initModal() {
        if (!modalOverlay) {
            modalOverlay = document.getElementById('modalOverlay');
            modalContainer = document.getElementById('modalContainer');
            modalIframe = document.getElementById('modalIframe');
            
            // 点击遮罩关闭
            if (modalOverlay) {
                modalOverlay.onclick = function(e) {
                    if (e.target === modalOverlay) {
                        closeModal();
                    }
                };
            }
        }
    }
    
    function openModal(url, title) {
        initModal();
        if (modalOverlay && modalContainer && modalIframe) {
            document.getElementById('modalTitle').textContent = title || '编辑';
            modalIframe.src = url;
            modalOverlay.style.display = 'block';
            modalContainer.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
    }
    
    function closeModal() {
        if (modalOverlay && modalContainer && modalIframe) {
            modalOverlay.style.display = 'none';
            modalContainer.style.display = 'none';
            modalIframe.src = 'about:blank';
            document.body.style.overflow = 'auto';
        }
    }
    
    function refreshAndClose() {
        closeModal();
        location.reload();
    }
    
    // ===== 批量删除功能 =====
    
    // 全选/取消全选
    function toggleAllCheckboxes(checkbox) {
        var checkboxes = document.querySelectorAll('.question-checkbox');
        checkboxes.forEach(function(cb) {
            cb.checked = checkbox.checked;
        });
        updateSelectedCount();
    }
    
    // 更新选中数量
    function updateSelectedCount() {
        var checkboxes = document.querySelectorAll('.question-checkbox:checked');
        var count = checkboxes.length;
        var countSpan = document.getElementById('selectedCount');
        if (countSpan) {
            countSpan.innerHTML = '已选择 <strong>' + count + '</strong> 项';
        }
        
        // 更新表头全选复选框状态
        var allCheckboxes = document.querySelectorAll('.question-checkbox');
        var checkAll = document.getElementById('checkAll');
        if (checkAll && allCheckboxes.length > 0) {
            checkAll.checked = (count === allCheckboxes.length && count > 0);
            checkAll.indeterminate = (count > 0 && count < allCheckboxes.length);
        }
    }
    
    // 批量删除
    function batchDeleteQuestions() {
        var checkboxes = document.querySelectorAll('.question-checkbox:checked');
        if (checkboxes.length === 0) {
            alert('请先选择要删除的题目！');
            return;
        }
        
        if (!confirm('确定要删除选中的 ' + checkboxes.length + ' 个题目吗？\n\n删除后将无法恢复！')) {
            return;
        }
        
        // 收集选中的题目ID
        var qids = [];
        checkboxes.forEach(function(cb) {
            qids.push(cb.getAttribute('data-qid'));
        });
        
        // 显示加载提示
        var btn = document.getElementById('btnBatchDelete');
        var originalText = btn.innerHTML;
        btn.innerHTML = '⏳ 删除中...';
        btn.disabled = true;
        
        // 发送删除请求
        fetch('batchdelete.aspx', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                qids: qids,
                vid: '<%= Request.QueryString["vid"] %>',
                cid: '<%= Request.QueryString["cid"] %>'
            })
        })
        .then(function(response) {
            return response.json();
        })
        .then(function(result) {
            if (result.success) {
                alert('成功删除 ' + result.deleted + ' 个题目！');
                // 刷新页面
                window.location.reload();
            } else {
                alert('删除失败：' + result.message);
                btn.innerHTML = originalText;
                btn.disabled = false;
            }
        })
        .catch(function(error) {
            alert('删除失败：' + error.message);
            btn.innerHTML = originalText;
            btn.disabled = false;
        });
    }
    
    window.onload = function() {
        // 初始化选中数量
        updateSelectedCount();
        
        // 调试并动态添加复选框
        setTimeout(function() {
            var checkboxes = document.querySelectorAll('.question-checkbox');
            var checkAll = document.getElementById('checkAll');
            
            console.log('=== 复选框调试信息 ===');
            console.log('找到的行复选框数量:', checkboxes.length);
            console.log('全选复选框存在:', checkAll !== null);
            
            if (checkboxes.length === 0) {
                console.warn('❌ ItemTemplate复选框未渲染，使用JavaScript动态添加');
                
                // 找到GridView的所有数据行
                var gridView = document.querySelector('.GridViewInfo');
                if (gridView) {
                    var rows = gridView.querySelectorAll('tr');
                    console.log('GridView行数:', rows.length);
                    
                    // 跳过表头，从第二行开始
                    for (var i = 1; i < rows.length; i++) {
                        var row = rows[i];
                        var firstCell = row.cells[0];
                        
                        if (firstCell) {
                            // 检查第一个单元格是否为空或只有空白
                            if (!firstCell.querySelector('input[type="checkbox"]')) {
                                // 尝试从"编辑"链接获取Qid
                                var editLink = row.querySelector('a[href*="surveyitemnew.aspx"]');
                                var qid = i; // 默认使用行号
                                
                                if (editLink) {
                                    var match = editLink.href.match(/qid=(\d+)/);
                                    if (match) {
                                        qid = match[1];
                                    }
                                }
                                
                                // 创建复选框
                                firstCell.innerHTML = '<input type="checkbox" class="question-checkbox" data-qid="' + qid + '" onclick="updateSelectedCount()" style="width: 18px; height: 18px; cursor: pointer; accent-color: #10b981;" />';
                                console.log('✅ 为行 ' + i + ' 添加了复选框 (qid=' + qid + ')');
                            }
                        }
                    }
                    
                    // 重新统计
                    checkboxes = document.querySelectorAll('.question-checkbox');
                    console.log('✅ 动态添加后的复选框数量:', checkboxes.length);
                    updateSelectedCount();
                }
            } else {
                console.log('✅ 复选框正常加载');
            }
        }, 500);
        
        // 修改调查按钮
        var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
        if (btnEdit) {
            btnEdit.value = '✏️ 修改调查';
            btnEdit.style.width = 'auto';
            btnEdit.style.height = 'auto';
            
            var wrapper = document.createElement('span');
            wrapper.className = 'btn-icon-wrapper';
            wrapper.innerHTML = '<svg viewBox="0 0 24 24" style="width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;margin-right:6px;vertical-align:middle;"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg><span>修改调查</span>';
            btnEdit.parentNode.insertBefore(wrapper, btnEdit);
            wrapper.appendChild(btnEdit);
            btnEdit.style.display = 'none';
            wrapper.style.cssText = 'display:inline-flex;align-items:center;padding:10px 28px;border-radius:10px;font-size:14px;font-weight:600;background:linear-gradient(135deg, #059669 0%, #10b981 100%);color:#fff;border:none;box-shadow:0 3px 12px rgba(5,150,105,.25);cursor:pointer;transition:all 0.2s ease;font-family:Microsoft YaHei,sans-serif;';
            wrapper.onclick = function() { btnEdit.click(); };
        }
        
        // 计时管理按钮
        var btnClock = document.getElementById('<%= Btnclock.ClientID %>');
        if (btnClock) {
            btnClock.value = '⏱️ 计时管理';
            btnClock.style.width = 'auto';
            btnClock.style.height = 'auto';
            
            var wrapper2 = document.createElement('span');
            wrapper2.className = 'btn-icon-wrapper';
            wrapper2.innerHTML = '<svg viewBox="0 0 24 24" style="width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;margin-right:6px;vertical-align:middle;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg><span>计时管理</span>';
            btnClock.parentNode.insertBefore(wrapper2, btnClock);
            wrapper2.appendChild(btnClock);
            btnClock.style.display = 'none';
            wrapper2.style.cssText = 'display:inline-flex;align-items:center;padding:10px 28px;border-radius:10px;font-size:14px;font-weight:600;background:#fff;color:#475569;border:1.5px solid #e2e8f0;cursor:pointer;transition:all 0.2s ease;font-family:Microsoft YaHei,sans-serif;';
            wrapper2.onclick = function() { btnClock.click(); };
            
            wrapper2.onmouseover = function() {
                this.style.background = '#f8fafc';
                this.style.borderColor = '#cbd5e1';
                this.style.transform = 'translateY(-1px)';
            };
            wrapper2.onmouseout = function() {
                this.style.background = '#fff';
                this.style.borderColor = '#e2e8f0';
                this.style.transform = 'translateY(0)';
            };
        }
        
        // 拦截"编辑"链接，使用弹窗打开
        var editLinks = document.querySelectorAll('a[href*="surveyitemnew.aspx"]');
        editLinks.forEach(function(link) {
            link.className = 'modal-link';
            link.onclick = function(e) {
                e.preventDefault();
                var url = this.getAttribute('href');
                openModal(url, '📝 编辑题目和选项');
                return false;
            };
        });
        
        // 拦截"选项"链接，使用弹窗打开
        var itemLinks = document.querySelectorAll('a[href*="surveyitem.aspx"]');
        itemLinks.forEach(function(link) {
            link.className = 'modal-link';
            link.onclick = function(e) {
                e.preventDefault();
                var url = this.getAttribute('href');
                openModal(url, '✏️ 编辑选项');
                return false;
            };
        });
    };
    
    // 监听iframe内的消息（用于关闭弹窗）
    window.addEventListener('message', function(event) {
        if (event.data === 'closeModal') {
            refreshAndClose();
        }
    });
</script>

<div class="show-container">
    <!-- 渐变标题栏 -->
    <div class="show-title-card">
        <div class="show-title-icon">
            <svg viewBox="0 0 24 24">
                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                <path d="M9 12h6m-6 4h6"/>
            </svg>
        </div>
        <div class="show-title-text">
            <h1 class="show-title"><asp:Label runat="server" ID="Lbtitle"></asp:Label></h1>
            <p class="show-title-sub">查看调查问卷详情，管理调查试题</p>
        </div>
    </div>
    
    <!-- 信息卡片 -->
    <div class="show-info-card">
        <div class="show-card-head">
            <span class="show-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                调查信息
            </h3>
        </div>
        <div class="show-card-body">
            <!-- 统计数据 -->
            <div class="survey-stats">
                <div class="survey-stat-item">
                    <span class="survey-stat-label">类型</span>
                    <span class="survey-stat-value"><asp:Label runat="server" ID="Lbtype"></asp:Label></span>
                </div>
                <div class="survey-stat-item">
                    <span class="survey-stat-label">试题数</span>
                    <span class="survey-stat-value"><asp:Label runat="server" ID="Labeltotal"></asp:Label></span>
                </div>
                <div class="survey-stat-item">
                    <span class="survey-stat-label">总分</span>
                    <span class="survey-stat-value"><asp:Label runat="server" ID="Lbscore"></asp:Label></span>
                </div>
                <div class="survey-stat-item">
                    <span class="survey-stat-label">平均分</span>
                    <span class="survey-stat-value"><asp:Label runat="server" ID="Lbave"></asp:Label></span>
                </div>
                <div class="survey-stat-item">
                    <span class="survey-stat-label">日期</span>
                    <span class="survey-stat-value"><asp:Label runat="server" ID="Lbdate"></asp:Label></span>
                </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="show-actions">
                <asp:ImageButton ID="BtnEdit" runat="server" 
                    onclick="BtnEdit_Click" 
                    ImageUrl="~/images/edit.gif" 
                    AlternateText="修改调查" />
                <asp:ImageButton ID="Btnclock" runat="server" 
                    onclick="Btnclock_Click" 
                    ImageUrl="~/images/clock.gif"
                    AlternateText="计时管理" />
            </div>
        </div>
    </div>
    
    <!-- 内容卡片 -->
    <div class="show-content-card">
        <div id="vcontent" runat="server" class="show-content"></div>
    </div>
    
    <!-- 按钮组 -->
    <div class="survey-button-group">
        <asp:Button ID="Btnadd" runat="server" 
            onclick="Btnadd_Click" 
            SkinID="BtnNormal" 
            Text="添加试题" />
        <asp:Button ID="Btnreturn" runat="server" 
            onclick="Btnreturn_Click" 
            SkinID="BtnNormal" 
            Text="返回" />
    </div>
    
    <!-- 试题列表卡片 -->
    <div class="survey-grid-card">
        <!-- 批量操作工具栏 -->
        <div class="batch-toolbar">
            <button type="button" id="btnBatchDelete" onclick="batchDeleteQuestions()">
                🗑️ 批量删除
            </button>
            <span id="selectedCount">
                已选择 <strong>0</strong> 项
            </span>
            <span style="font-size: 12px; color: #94a3b8; margin-left: auto;">
                💡 提示：点击表头复选框可全选
            </span>
        </div>
        
        <asp:GridView ID="GVQuestion" runat="server" 
            SkinID="GridViewInfo"
            AutoGenerateColumns="False" 
            DataKeyNames="Qid" 
            Width="100%" 
            CellPadding="5" 
            Font-Size="9pt" 
            EnableModelValidation="True" 
            HorizontalAlign="Center" 
            onrowcommand="GVQuestion_RowCommand" 
            onrowdatabound="GVQuestion_RowDataBound"
            CssClass="GridViewInfo">
            <Columns>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <input type="checkbox" id="checkAll" onclick="toggleAllCheckboxes(this)" 
                            style="width: 18px; height: 18px; cursor: pointer; accent-color: #10b981;" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <input type="checkbox" class="question-checkbox" 
                            data-qid='<%# Eval("Qid") %>' 
                            onclick="updateSelectedCount()" 
                            style="width: 18px; height: 18px; cursor: pointer; accent-color: #10b981;" />
                    </ItemTemplate>
                    <HeaderStyle Width="40px" HorizontalAlign="Left" />
                    <ItemStyle HorizontalAlign="Left" Width="40px" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="序号">
                    <ItemTemplate>
                        <%# Container.DataItemIndex + 1 %>
                    </ItemTemplate>
                    <HeaderStyle Width="35px" HorizontalAlign="Left" />
                    <ItemStyle HorizontalAlign="Left" Width="35px" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="调查试题">
                    <ItemTemplate>
                        <asp:Label ID="LabelQtitle" runat="server" 
                            Text='<%# HttpUtility.HtmlDecode(DataBinder.Eval(Container.DataItem,"Qtitle").ToString()) %>'>
                        </asp:Label>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Left" />
                </asp:TemplateField>
                <asp:BoundField DataField="Qcount" HeaderText="正确率">
                    <HeaderStyle Width="80px" />
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:HyperLinkField 
                    DataNavigateUrlFields="Qid,Qvid,Qcid" 
                    DataNavigateUrlFormatString="~/survey/surveyitemnew.aspx?qid={0}&amp;qvid={1}&amp;qcid={2}" 
                    HeaderText="选项" 
                    Text="选项">
                    <ItemStyle Width="70px" HorizontalAlign="Center" />
                </asp:HyperLinkField>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:Label ID="Labelcount" runat="server"></asp:Label>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:HyperLinkField 
                    DataNavigateUrlFields="Qid,Qvid,Qcid" 
                    DataNavigateUrlFormatString="~/survey/surveyitemnew.aspx?qid={0}&amp;qvid={1}&amp;qcid={2}" 
                    Text="编辑">
                    <ItemStyle Width="70px" HorizontalAlign="Center" />
                </asp:HyperLinkField>
                <asp:TemplateField HeaderText="操作">
                    <ItemTemplate>
                        <asp:LinkButton ID="BtnDel" runat="server" 
                            CausesValidation="false" 
                            CommandArgument='<%# Eval("Qid") %>' 
                            CommandName="Del" 
                            Text="删除">
                        </asp:LinkButton>
                    </ItemTemplate>
                    <HeaderStyle Width="70px" />
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</div>

<!-- 原始内容（隐藏） -->
<div style="display: none;">
    <div>
        <br />
        <asp:ImageButton ID="Btnclock_old" runat="server" ImageUrl="~/images/clock.gif" onclick="Btnclock_Click" />
        调查名称：<asp:Label runat="server" ID="Lbtitle_old" Font-Bold="True"></asp:Label>
        <br /><br />
        <div style="border-width: 1px; border-color: #808080; border-bottom-style: dashed; padding-bottom: 2px;">
            类型：<asp:Label runat="server" ID="Lbtype_old"></asp:Label>&nbsp; &nbsp;
            试题数：<asp:Label runat="server" ID="Labeltotal_old"></asp:Label> &nbsp; &nbsp;
            总分：<asp:Label runat="server" ID="Lbscore_old"></asp:Label> &nbsp; &nbsp;
            平均分：<asp:Label runat="server" ID="Lbave_old"></asp:Label> &nbsp;&nbsp;
            日期：<asp:Label runat="server" ID="Lbdate_old"></asp:Label> &nbsp;&nbsp;
        </div>
        <br />
        <div id="vcontent_old" runat="server" style="margin: auto; padding: 6px; text-align: left; width: 980px;"></div>
        <br />
    </div>
</div>

<!-- 弹窗HTML结构 -->
<div id="modalOverlay" class="modal-overlay"></div>
<div id="modalContainer" class="modal-container">
    <div class="modal-header">
        <h3 id="modalTitle">编辑</h3>
        <button type="button" class="modal-close" onclick="closeModal()">×</button>
    </div>
    <div class="modal-body">
        <iframe id="modalIframe" class="modal-iframe" src="about:blank"></iframe>
    </div>
    <div class="modal-footer">
        <button type="button" class="modal-btn modal-btn-secondary" onclick="closeModal()">关闭</button>
        <button type="button" class="modal-btn modal-btn-primary" onclick="refreshAndClose()">保存并关闭</button>
    </div>
</div>

</asp:Content>

