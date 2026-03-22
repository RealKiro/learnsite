<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="student_kitymind, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    	<meta charset=utf-8>
	<!-- bower:css -->
	<link rel="stylesheet" href="../../Plugins/km/bower_components/bootstrap/dist/css/bootstrap.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/codemirror/lib/codemirror.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/hotbox/hotbox.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/kityminder-core/dist/kityminder.core.css" />
	<link rel="stylesheet" href="../../Plugins/km/bower_components/color-picker/dist/color-picker.min.css" />
	<!-- endbower -->

	<link rel="stylesheet" href="../../Plugins/km/kityminder.editor.css">
		<style>
		div.minder-editor-container {
			top: 0px;
		}
		.export{
            position: absolute;
            z-index: 999;
            top: 0px;
			height: 30px;
			line-height: 30px;
			margin: 2px;
			float: right;
			right:160px;
			color: #333;
			overflow: hidden;
			position: relative;
			cursor:pointer;
		}
		.return{
            position: absolute;
            z-index: 999;
            top: 0px;
			height: 30px;
			line-height: 30px;
			margin: 2px;
			float: right;
			right:30px;
			color: #333;
			overflow: hidden;
			position: relative;
			cursor:pointer;
		}
	</style>
</head>

<body ng-app="kityminderDemo" >
<script>
// ===== 1. 同步请求：页面初始化时立即获取 correctId（在 JS 引擎加载其他脚本之前执行）=====
var _syncCorrectId = '';  // 同步请求中从 DB 获取的可靠 ID
(function() {
    var m = window.location.search.substr(1).match(/(?:^|&)lid=([^&]*)/);
    var lid = m ? m[1] : '';
    if (!lid) return;
    var mid  = (window.location.search.match(/(?:^|&)mid=([^&]*)/)  || [])[1] || '';
    var mcid = (window.location.search.match(/(?:^|&)mcid=([^&]*)/) || [])[1] || '';
    try {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'kitymind-fix.ashx?lid=' + lid + '&mid=' + mid + '&mcid=' + mcid, false);
        xhr.send();
        if (xhr.status === 200) {
            var d = (new Function('return ' + xhr.responseText))();
            // 保存 correctId 供保存时使用
            if (d && d.correctId) _syncCorrectId = d.correctId;
            // 类型不匹配时跳转（排除 program.aspx 避免死循环）
            if (window.location.search.indexOf('debug=1') < 0 &&
                d.typeMismatch && d.correctPageForType &&
                d.correctPageForType.indexOf('program.aspx') < 0) {
                window.location.replace(d.correctPageForType);
            }
        }
    } catch(e) {}
})();
</script>
    <form id="form1" runat="server">
       <div id="mcontext" style="display: none; background: #fffdea; overflow-y: auto; overflow-x: hidden;
            position: absolute;  width: 500px; height: 50%; z-index: 999;opacity:0.9; font-size: 16px;
            right: 0px; bottom: 0px; padding: 2px;">
            <div style="margin:10px; ">
            <h4><%=Titles%></h4>
            <%=Mcontents %>
            </div>
        </div>
    </form>
<div>
<a class="export" href="#" onclick="return downfile(this);">
   保存
</a>
<a class="return" href="#" onclick="returnurl();">
   返回
</a>
</div>
<kityminder-editor on-init="initEditor(editor, minder)" data-theme="fresh-green"></kityminder-editor>

<!-- bower:js -->
<script src="../../Plugins/km/bower_components/jquery/dist/jquery.js"></script>
<script src="../../Plugins/km/bower_components/bootstrap/dist/js/bootstrap.js"></script>
<script src="../../Plugins/km/bower_components/angular/angular.js"></script>
<script src="../../Plugins/km/bower_components/angular-bootstrap/ui-bootstrap-tpls.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/lib/codemirror.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/xml/xml.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/javascript/javascript.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/css/css.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/htmlmixed/htmlmixed.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/markdown/markdown.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/addon/mode/overlay.js"></script>
<script src="../../Plugins/km/bower_components/codemirror/mode/gfm/gfm.js"></script>
<script src="../../Plugins/km/bower_components/angular-ui-codemirror/ui-codemirror.js"></script>
<script src="../../Plugins/km/bower_components/marked/lib/marked.js"></script>
<script src="../../Plugins/km/bower_components/kity/dist/kity.min.js"></script>
<script src="../../Plugins/km/bower_components/hotbox/hotbox.js"></script>
<script src="../../Plugins/km/bower_components/json-diff/json-diff.js"></script>
<script src="../../Plugins/km/bower_components/kityminder-core/dist/kityminder.core.min.js"></script>
<script src="../../Plugins/km/bower_components/color-picker/dist/color-picker.min.js"></script>
<!-- endbower -->

<script src="../../Plugins/km/kityminder.editor.js"></script>
<script >
    // ========== 调试与修复模块 ==========
    // 解析URL参数
    function _getUrlParam(name) {
        var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)');
        var r = window.location.search.substr(1).match(reg);
        return r ? decodeURIComponent(r[2]) : '';
    }
    var _urlLid = _getUrlParam('lid');
    var _urlMid = _getUrlParam('mid');
    var _urlMcid = _getUrlParam('mcid');
    var _isDebug = _getUrlParam('debug') === '1';

    // 编译代码提供的原始值
    var _serverId = "<%=Id %>";
    var _serverFpage = "<%=Fpage %>";
    var _serverCodefile = "<%=codefile %>";

    // 根据URL参数计算的正确值（不依赖handler，作为基础修正）
    // DLL的Id格式: "mcid-mid-lid" (如 "9-23-36")
    var _calcId = _urlMcid + '-' + _urlMid + '-' + _urlLid;
    // Fpage: DLL提供的返回地址是正确的，不覆盖

    // 验证 id 格式 "mcid-mid-lid" 是否有效（三部分都必须 > 0）
    function _isValidId(id) {
        if (!id) return false;
        var p = id.split('-');
        if (p.length !== 3) return false;
        return parseInt(p[0], 10) > 0 && parseInt(p[1], 10) > 0 && parseInt(p[2], 10) > 0;
    }

    // 修正后的值
    // 优先选择顺序：有效的 _calcId → 有效的 _serverId → _calcId（兼容旧逻辑）
    // 注意：_calcId="--175" 是 truthy字符串但实际无效，不能直接 || _serverId
    var _fixedId = _isValidId(_calcId) ? _calcId
                 : _isValidId(_serverId) ? _serverId
                 : _calcId;
    var _fixedFpage = _serverFpage; // Fpage保留DLL原始值
    var _fixedCodefile = _serverCodefile;
    var _fixData = null; // handler返回的完整数据

    console.log('[kitymind-debug] URL参数: lid=' + _urlLid + ', mid=' + _urlMid + ', mcid=' + _urlMcid);
    console.log('[kitymind-debug] 编译代码值: Id=' + _serverId + ', Fpage=' + _serverFpage + ', codefile长度=' + _serverCodefile.length);
    console.log('[kitymind-debug] 计算Id=' + _calcId + ', Fpage保留DLL值=' + _serverFpage);
    if (_serverId !== _calcId) console.warn('[kitymind-fix] Id不一致! DLL=' + _serverId + ', 计算=' + _calcId);

    // 调试面板
    function _createDebugPanel() {
        var panel = document.createElement('div');
        panel.id = 'kitymind-debug-panel';
        panel.style.cssText = 'display:none;position:fixed;z-index:9999;top:36px;right:0;width:480px;max-height:70vh;overflow-y:auto;' +
            'background:#fffbeb;border:2px solid #f59e0b;border-radius:0 0 0 12px;padding:14px 16px;font-size:12px;line-height:1.7;color:#92400e;' +
            'box-shadow:0 4px 24px rgba(0,0,0,0.15);font-family:Consolas,Monaco,monospace;';
        panel.innerHTML = '<div style="font-weight:700;font-size:14px;margin-bottom:8px;border-bottom:1px solid #fbbf24;padding-bottom:6px;">' +
            '🔍 kitymind 调试面板 <span id="_dbg_close" style="float:right;cursor:pointer;font-size:16px;">&times;</span></div>' +
            '<div id="_dbg_content">加载中...</div>';
        document.body.appendChild(panel);
        document.getElementById('_dbg_close').onclick = function() { panel.style.display = 'none'; };
        return panel;
    }

    function _updateDebugPanel(fixData) {
        var el = document.getElementById('_dbg_content');
        if (!el) return;
        var html = '';
        html += '<b>== URL参数 ==</b><br/>';
        html += 'lid=' + _urlLid + ', mid=' + _urlMid + ', mcid=' + _urlMcid + '<br/><br/>';
        html += '<b>== 编译代码(DLL)提供的值 ==</b><br/>';
        html += 'Id=<code>' + _serverId + '</code><br/>';
        html += 'Fpage=<code>' + _serverFpage + '</code><br/>';
        html += 'codefile长度=<code>' + _serverCodefile.length + '</code><br/><br/>';

        if (fixData) {
            // === 类型匹配检查（重要！） ===
            html += '<b>== 任务类型检查 ==</b><br/>';
            html += '当前页面=<code>' + (fixData.currentPage||'kitymind') + '</code> (期望Ltype=<code>' + (fixData.expectedLtype||'10') + '</code> 导图)<br/>';
            html += '数据库Ltype=<code>' + (fixData.dbLtype||'') + '</code>';
            html += ' → 归一化=<code>' + (fixData.normalizedLtype||'') + '</code> (' + (fixData.normalizedLtypeName||'') + ')<br/>';
            if (fixData.typeMismatch) {
                html += '<div style="margin:6px 0;padding:8px 12px;background:#fef2f2;border:1px solid #fca5a5;border-radius:6px;color:#dc2626;font-weight:700;">';
                html += '⚠ 类型不匹配! 数据库实际类型为 <code>' + (fixData.normalizedLtypeName||fixData.normalizedLtype) + '</code>(Ltype=' + fixData.normalizedLtype + ')';
                html += '，但当前页面是 kitymind.aspx(导图, Ltype=10)<br/>';
                html += '应跳转到: <a href="' + fixData.correctPageForType + '" style="color:#2563eb;">' + fixData.correctPageForType + '</a>';
                html += '</div>';
                html += '<div style="margin:4px 0;font-size:11px;color:#6b7280;">';
                html += '教师端对应页面: teacher/';
                var teacherPage = _getTeacherPage(fixData.normalizedLtype);
                html += teacherPage + '?mcid=' + _urlMcid + '&mid=' + _urlMid + '&lid=' + _urlLid;
                html += '</div>';
            } else {
                html += '<span style="color:#059669;font-weight:700;">✅ 类型匹配正确</span><br/>';
            }
            html += '<br/>';

            html += '<b>== 数据库实际数据 ==</b><br/>';
            html += 'Listmenu: Lxid=<code>' + fixData.dbLxid + '</code>, Ltype=<code>' + fixData.dbLtype + '</code>, Lcid=<code>' + fixData.dbLcid + '</code><br/>';
            html += 'Listmenu.Ltitle=<code>' + (fixData.dbLtitle||'') + '</code><br/>';
            html += 'Mission.Title=<code>' + (fixData.missionTitle||'') + '</code><br/>';
            html += '学号(snum)=<code>' + (fixData.snum||'未登录') + '</code><br/>';
            html += 'Works.Wid=<code>' + (fixData.worksWid||'无') + '</code><br/>';
            html += 'Works.Wcode长度=<code>' + (fixData.worksCodefile ? fixData.worksCodefile.length : 0) + '</code><br/><br/>';

            html += '<b>== 修正结果 ==</b><br/>';
            var idMatch = (_serverId === fixData.correctId);
            var fpageMatch = (_serverFpage === fixData.correctFpage);
            html += 'Id=<code>' + _fixedId + '</code> ' + (idMatch ? '✅ 一致' : '🔧 <b style="color:#059669">已修正</b> <span style="color:#9ca3af;font-size:11px">(DLL原值=' + _serverId + ')</span>') + '<br/>';
            html += 'Fpage=<code>' + _fixedFpage + '</code> ' + (fpageMatch ? '✅ 一致' : '🔧 <b style="color:#059669">已修正</b> <span style="color:#9ca3af;font-size:11px">(DLL原值=' + _serverFpage + ')</span>') + '<br/>';

            if (fixData.error) {
                html += '<br/><b style="color:#dc2626;">⚠ 错误/警告:</b><br/>' + fixData.error + '<br/>';
            }
        } else {
            html += '<b style="color:#dc2626;">⚠ handler请求失败</b><br/>';
        }
        el.innerHTML = html;
    }

    // 获取教师端对应页面名（用于调试面板对比）
    function _getTeacherPage(ltype) {
        var map = {
            '1': 'missionshow.aspx', '2': 'topicshow.aspx', '3': 'missionshow.aspx',
            '4': 'program.aspx', '5': 'pythonshow.aspx', '6': 'consoleshow.aspx',
            '7': 'graphshow.aspx', '8': 'program.aspx', '9': 'htmlshow.aspx',
            '10': 'kitymindshow.aspx', '11': 'excelshow.aspx', '12': 'ware.aspx',
            '13': '../student/topicdiscuss.aspx', '14': 'missionshow.aspx', '15': 'txtformshow.aspx'
        };
        return map[ltype] || 'missionshow.aspx';
    }

    // 切换调试面板快捷键: Ctrl+Shift+D
    document.addEventListener('keydown', function(e) {
        if (e.ctrlKey && e.shiftKey && e.keyCode === 68) {
            var panel = document.getElementById('kitymind-debug-panel');
            if (!panel) panel = _createDebugPanel();
            panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
            if (panel.style.display === 'block' && _fixData) _updateDebugPanel(_fixData);
            e.preventDefault();
        }
    });

    // 页面加载
    window.onload = function () {
        // 1. 调用handler获取正确数据
        $.ajax({
            url: 'kitymind-fix.ashx?lid=' + _urlLid + '&mid=' + _urlMid + '&mcid=' + _urlMcid,
            type: 'GET',
            dataType: 'json',
            timeout: 8000
        }).done(function(data) {
            _fixData = data;
            console.log('[kitymind-debug] handler返回数据:', data);
            console.log('[kitymind-debug] 任务类型检查: dbLtype=' + data.dbLtype +
                ', normalizedLtype=' + data.normalizedLtype + '(' + data.normalizedLtypeName + ')' +
                ', expectedLtype=' + data.expectedLtype +
                ', typeMismatch=' + data.typeMismatch);

            // === 关键修正：类型不匹配时自动跳转到正确页面 ===
            // 安全护栏：绝不跳转回 program.aspx，避免无限循环 (program -> kitymind -> program)
            if (data.typeMismatch && data.correctPageForType && data.correctPageForType.indexOf('program.aspx') < 0) {
                console.warn('[kitymind-fix] 任务类型不匹配! 当前页面=kitymind(导图,Ltype=10), 数据库Ltype=' +
                    data.dbLtype + '(归一化=' + data.normalizedLtype + '=' + data.normalizedLtypeName + ')' +
                    ', 应跳转到: ' + data.correctPageForType);

                if (_isDebug) {
                    // debug模式不自动跳转，显示调试信息
                    var panel = _createDebugPanel();
                    panel.style.display = 'block';
                    _updateDebugPanel(data);
                    return;
                }
                // 非调试模式自动跳转
                window.location.href = data.correctPageForType;
                return;
            }

            // 2. 修正Id（handler优先，否则用计算值）
            if (data.correctId) {
                _fixedId = data.correctId;
                console.log('[kitymind-fix] Id使用handler值: ' + _fixedId);
            }

            // 3. Fpage保留DLL原始值，不覆盖
            console.log('[kitymind-fix] Fpage保留DLL值: ' + _fixedFpage);

            // 4. 修正codefile（用于加载思维导图数据）
            if ((!_serverCodefile || _serverCodefile === '') && data.worksCodefile && data.worksCodefile !== '') {
                console.warn('[kitymind-fix] 服务端codefile为空, 使用handler查到的数据');
                _fixedCodefile = data.worksCodefile;
            }

            console.log('[kitymind-fix] 最终修正值: Id=' + _fixedId + ', Fpage=' + _fixedFpage);

            // 5. 加载思维导图数据
            _loadMindmapData();

            // 6. debug模式显示面板
            if (_isDebug) {
                var panel = _createDebugPanel();
                panel.style.display = 'block';
                _updateDebugPanel(data);
            }
        }).fail(function(xhr, status, err) {
            console.error('[kitymind-fix] handler请求失败:', status, err);
            console.log('[kitymind-fix] 使用计算值: Id=' + _fixedId + ', Fpage=' + _fixedFpage);
            // handler失败时仍然使用计算值（已在初始化时设置）
            _loadMindmapData();

            if (_isDebug) {
                var panel = _createDebugPanel();
                panel.style.display = 'block';
                _updateDebugPanel(null);
            }
        });
    }

    // 加载思维导图数据
    function _loadMindmapData() {
        var codefile = _fixedCodefile;
        if (codefile != "") {
            codefile = decodeURIComponent(codefile);
            console.log('[kitymind-debug] 加载codefile, 长度=' + codefile.length);
            var fileType = 'json'
            editor.minder.importData(fileType, codefile).then(function (data) {
                console.log('[kitymind-debug] 导入成功', data)
            });
        } else {
            console.log('[kitymind-debug] codefile为空, 显示空白思维导图');
        }
    }

    // 返回功能（使用修正后的Fpage）
    function returnurl() {
        if (confirm('是否要离开此页面？') == true) {
            console.log('[kitymind-fix] 返回URL: ' + _fixedFpage);
            window.location.href = _fixedFpage;
        }
    }

    // 获取最可靠的保存 ID（优先顺序：异步handler结果 > 同步handler结果 > 计算值）
    function _getBestSaveId() {
        if (_fixData && _isValidId(_fixData.correctId)) return _fixData.correctId;
        if (_isValidId(_syncCorrectId)) return _syncCorrectId;
        if (_isValidId(_fixedId)) return _fixedId;
        // 最后兜底：再次同步请求（确保 wcid/wmid 不为0）
        try {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'kitymind-fix.ashx?lid=' + _urlLid + '&mid=' + _urlMid + '&mcid=' + _urlMcid, false);
            xhr.send();
            if (xhr.status === 200) {
                var d = (new Function('return ' + xhr.responseText))();
                if (d && d.correctId) { _syncCorrectId = d.correctId; return d.correctId; }
            }
        } catch(e) {}
        return _fixedId; // 实在没有就用原始值，让服务端报错提示具体原因
    }

    // 保存功能
    function downfile(link) {
        var id = _getBestSaveId();
        var title = '';
        try { title = editor.minder.getRoot().getData('text'); } catch(e) {}
        console.log('[kitymind-fix] 保存, Id=' + id +
            ' (fixData=' + (_fixData ? _fixData.correctId : 'null') +
            ', sync=' + _syncCorrectId + ', fixed=' + _fixedId + ')');

        // 执行实际 POST 保存
        function doPost(formData) {
            var urls = 'uploadkitymind.ashx?id=' + id;
            console.log('[kitymind-fix] POST ' + urls);
            $.ajax({
                url: urls,
                type: 'POST',
                cache: false,
                data: formData,
                processData: false,
                contentType: false
            }).done(function(res) {
                console.log('[kitymind-fix] 保存响应:', res);
                try {
                    var r = (typeof res === 'object') ? res : JSON.parse(res);
                    alert(r.success ? '保存成功！' : '保存失败：' + (r.message || JSON.stringify(res)));
                } catch(e) {
                    var s = typeof res === 'string' ? res : '';
                    alert(s.indexOf('成功') >= 0 ? '保存成功！' : '保存失败（服务端响应）：' + s.substring(0, 300));
                }
                $('.export').attr('disabled', 'false');
            }).fail(function(xhr, status, err) {
                // 显示实际 HTTP 错误，便于诊断根因
                var detail = 'HTTP ' + (xhr ? xhr.status : '?') + ' ' + (err || status);
                var body = xhr && xhr.responseText ? xhr.responseText.substring(0, 300) : '';
                console.error('[kitymind-fix] AJAX失败:', detail, body);
                alert('保存失败（' + detail + '）\n' + body);
            });
        }

        // 导出 JSON（核心数据，失败则中断）
        editor.minder.exportData('json').then(function(strJson) {
            var formData = new FormData();
            formData.append('title', title);
            formData.append('km', encodeURIComponent(strJson));

            // 尝试导出 PNG 缩略图；失败不影响主流程
            try {
                editor.minder.exportData('png').then(function(pngContent) {
                    try { formData.append('thumb', dataURLtoBlob(pngContent)); } catch(e) {}
                    doPost(formData);
                }, function() { doPost(formData); }); // PNG 拒绝时也继续
            } catch(e) {
                doPost(formData); // PNG 抛出异常时也继续
            }
        }, function(e) {
            console.error('[kitymind-fix] JSON导出失败:', e);
            alert('保存失败：无法导出思维导图数据，请刷新页面重试。');
        });
        return false;
    }

    //base64转换为图片blob
    function dataURLtoBlob(dataurl) {
        var arr = dataurl.split(',');
        //注意base64的最后面中括号和引号是不转译的
        var _arr = arr[1].substring(0, arr[1].length - 2);
        var mime = arr[0].match(/:(.*?);/)[1],
    bstr = atob(_arr),
    n = bstr.length,
    u8arr = new Uint8Array(n);
        while (n--) {
            u8arr[n] = bstr.charCodeAt(n);
        }
        return new Blob([u8arr], {
            type: mime
        });
    }

</script>

<script>
    angular.module('kityminderDemo', ['kityminderEditor'])
	.controller('MainController', function ($scope) {
	    $scope.initEditor = function (editor, minder) {
	        window.editor = editor;
	        window.minder = minder;
	    };
	});
</script>


</body>
</html>
