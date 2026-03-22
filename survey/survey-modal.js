// 弹窗管理脚本
var modalOverlay, modalContainer;
var currentQid = 0, currentVid = 0, currentCid = 0;

function initModal() {
    if (!modalOverlay) {
        modalOverlay = document.getElementById('modalOverlay');
        modalContainer = document.getElementById('modalContainer');
        
        // 点击遮罩关闭
        if (modalOverlay) {
            modalOverlay.onclick = closeModal;
        }
    }
}

function openModal() {
    initModal();
    if (modalOverlay && modalContainer) {
        modalOverlay.style.display = 'block';
        modalContainer.style.display = 'block';
        document.body.style.overflow = 'hidden';
    }
}

function closeModal() {
    if (modalOverlay && modalContainer) {
        modalOverlay.style.display = 'none';
        modalContainer.style.display = 'none';
        document.body.style.overflow = 'auto';
    }
}

// HTML转义
function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// 编辑题目
function editQuestion(qid, vid, cid) {
    currentQid = qid;
    currentVid = vid;
    currentCid = cid;
    
    // 加载题目数据
    fetch('survey.aspx?action=getquestion&qid=' + qid)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('modalTitle').textContent = '编辑题目';
                document.getElementById('modalBody').innerHTML = `
                    <div class="modal-form-group">
                        <label class="modal-form-label">题目内容 *</label>
                        <textarea id="questionTitle" class="modal-form-textarea">${escapeHtml(data.title)}</textarea>
                    </div>
                    <div class="modal-form-group">
                        <label class="modal-form-label">题目选项</label>
                        <div class="modal-items-list" id="itemsList">
                            ${data.items.map((item, index) => `
                                <div class="modal-item" data-mid="${item.mid}">
                                    <div class="modal-item-num">${index + 1}</div>
                                    <input type="text" class="modal-item-input" value="${escapeHtml(item.content)}" data-mid="${item.mid}" />
                                    <div class="modal-item-score">${item.score}分</div>
                                    <button type="button" class="modal-item-btn" onclick="deleteItem(${item.mid})">删除</button>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                `;
                
                document.getElementById('modalFooter').innerHTML = `
                    <button type="button" class="modal-btn modal-btn-secondary" onclick="closeModal()">取消</button>
                    <button type="button" class="modal-btn modal-btn-primary" onclick="saveQuestion()">保存</button>
                `;
                
                openModal();
            } else {
                alert('加载题目失败：' + data.message);
            }
        })
        .catch(error => {
            alert('加载题目失败：' + error.message);
        });
}

// 编辑选项
function editItems(qid, vid, cid) {
    currentQid = qid;
    currentVid = vid;
    currentCid = cid;
    
    // 加载选项数据
    fetch('survey.aspx?action=getitems&qid=' + qid)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('modalTitle').textContent = '编辑选项';
                document.getElementById('modalBody').innerHTML = `
                    <div class="modal-form-group">
                        <label class="modal-form-label">题目：${escapeHtml(data.questionTitle)}</label>
                    </div>
                    <div class="modal-form-group">
                        <label class="modal-form-label">选项列表</label>
                        <div class="modal-items-list" id="itemsList">
                            ${data.items.map((item, index) => `
                                <div class="modal-item" data-mid="${item.mid}">
                                    <div class="modal-item-num">${index + 1}</div>
                                    <input type="text" class="modal-item-input" value="${escapeHtml(item.content)}" data-mid="${item.mid}" />
                                    <input type="number" class="modal-item-input" value="${item.score}" data-mid="${item.mid}" data-type="score" style="max-width:80px;" />
                                    <button type="button" class="modal-item-btn" onclick="deleteItem(${item.mid})">删除</button>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                `;
                
                document.getElementById('modalFooter').innerHTML = `
                    <button type="button" class="modal-btn modal-btn-secondary" onclick="closeModal()">取消</button>
                    <button type="button" class="modal-btn modal-btn-primary" onclick="saveItems()">保存</button>
                `;
                
                openModal();
            } else {
                alert('加载选项失败：' + data.message);
            }
        })
        .catch(error => {
            alert('加载选项失败：' + error.message);
        });
}

// 保存题目
function saveQuestion() {
    var title = document.getElementById('questionTitle').value.trim();
    if (!title) {
        alert('请输入题目内容');
        return;
    }
    
    var items = [];
    var inputs = document.querySelectorAll('#itemsList .modal-item-input');
    inputs.forEach(function(input) {
        items.push({
            mid: input.getAttribute('data-mid'),
            content: input.value.trim()
        });
    });
    
    // 提交保存
    fetch('survey.aspx?action=savequestion', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            qid: currentQid,
            title: title,
            items: items
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('保存成功');
            closeModal();
            location.reload();
        } else {
            alert('保存失败：' + data.message);
        }
    })
    .catch(error => {
        alert('保存失败：' + error.message);
    });
}

// 保存选项
function saveItems() {
    var items = [];
    var itemDivs = document.querySelectorAll('#itemsList .modal-item');
    itemDivs.forEach(function(div) {
        var inputs = div.querySelectorAll('.modal-item-input');
        var mid = div.getAttribute('data-mid');
        var content = inputs[0].value.trim();
        var score = inputs[1] ? inputs[1].value : 0;
        
        items.push({
            mid: mid,
            content: content,
            score: score
        });
    });
    
    // 提交保存
    fetch('survey.aspx?action=saveitems', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            qid: currentQid,
            items: items
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('保存成功');
            closeModal();
            location.reload();
        } else {
            alert('保存失败：' + data.message);
        }
    })
    .catch(error => {
        alert('保存失败：' + error.message);
    });
}

// 删除选项
function deleteItem(mid) {
    if (!confirm('确定要删除此选项吗？')) return;
    
    var item = document.querySelector('.modal-item[data-mid="' + mid + '"]');
    if (item) {
        item.remove();
    }
}

// 初始化页面
function initSurveyPage() {
    // 修改GridView中的链接为弹窗
    var editLinks = document.querySelectorAll('a[href*="surveyitemnew.aspx"]');
    editLinks.forEach(function(link) {
        var href = link.getAttribute('href');
        var match = href.match(/qid=(\d+).*qvid=(\d+).*qcid=(\d+)/);
        if (match) {
            var qid = match[1], vid = match[2], cid = match[3];
            link.className = 'modal-link';
            link.onclick = function(e) {
                e.preventDefault();
                editQuestion(qid, vid, cid);
            };
        }
    });
    
    var itemLinks = document.querySelectorAll('a[href*="surveyitem.aspx"]');
    itemLinks.forEach(function(link) {
        var href = link.getAttribute('href');
        var match = href.match(/qid=(\d+).*qvid=(\d+).*qcid=(\d+)/);
        if (match) {
            var qid = match[1], vid = match[2], cid = match[3];
            link.className = 'modal-link';
            link.onclick = function(e) {
                e.preventDefault();
                editItems(qid, vid, cid);
            };
        }
    });
}

// 页面加载完成后初始化
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSurveyPage);
} else {
    initSurveyPage();
}
