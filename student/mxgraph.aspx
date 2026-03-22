<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="Student_mxgraph, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>流程图</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link rel="stylesheet" type="text/css" href="../mxgraph/styles/grapheditor.css">
	<script type="text/javascript">
	    // Parses URL parameters. Supported parameters are:
	    // - lang=xy: Specifies the language of the user interface.
	    // - touch=1: Enables a touch-style user interface.
	    // - storage=local: Enables HTML5 local storage.
	    // - chrome=0: Chromeless mode.
	    var urlParams = (function (url) {
	        var result = new Object();
	        var idx = url.lastIndexOf('?');

	        if (idx > 0) {
	            var params = url.substring(idx + 1).split('&');

	            for (var i = 0; i < params.length; i++) {
	                idx = params[i].indexOf('=');

	                if (idx > 0) {
	                    result[params[i].substring(0, idx)] = params[i].substring(idx + 1);
	                }
	            }
	        }

	        return result;
	    })(window.location.href);

	    // Default resources are included in grapheditor resources
	    mxLoadResources = false;
	</script>
	<script type="text/javascript" src="../mxgraph/js/Init.js"></script>
	<script type="text/javascript" src="../mxgraph/deflate/pako.min.js"></script>
	<script type="text/javascript" src="../mxgraph/deflate/base64.js"></script>
	<script type="text/javascript" src="../mxgraph/jscolor/jscolor.js"></script>
	<script type="text/javascript" src="../mxgraph/sanitizer/sanitizer.min.js"></script>
	<script type="text/javascript" src="../mxgraph/mxClient.js"></script>
	<script type="text/javascript" src="../mxgraph/js/EditorUi.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Editor.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Sidebar.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Graph.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Format.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Shapes.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Actions.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Menus.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Toolbar.js"></script>
	<script type="text/javascript" src="../mxgraph/js/Dialogs.js"></script>
    <script src="../code/jquery.min.js" type="text/javascript"></script>
	<style>		
		.savetext{
			position: fixed;
			top: 2px;
			right: 350px;
			z-index: 888;  
			width:100px;
		}
		.savetext:hover{
			background:#a8e083;
			border:1px solid;
		}
		.contentbtn{
			position: fixed;
			top: 2px;
			right: 200px;
			z-index: 888;  
			width:100px;
		}
		.contentbtn:hover{
			background:#a8e083;
			border:1px solid;
		}
		.returnbtn{
			position: fixed;
			top: 2px;
			right: 50px;
			z-index: 888;  
			width:100px;
		}
		.returnbtn:hover{
			background:#a8e083;
			border:1px solid;
		}
		::-webkit-scrollbar {  display: none; /* Chrome Safari */  }
	</style>
</head>
<body class="geEditor">
<button class="savetext"  onclick="savetoxml()" type="button"  >保存流程图</button>
<button  onclick="showcontent()" type="button" class="contentbtn" > 查看学案</button>
<button  onclick="returnurl()" type="button" class="returnbtn" > 返回</button>
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

	<script type="text/javascript">
	    var editor;

	    mxResources.loadDefaultBundle = false;
	    var bundle = mxResources.getDefaultBundle(RESOURCE_BASE, mxLanguage) ||
				mxResources.getSpecialBundle(RESOURCE_BASE, mxLanguage);

	    // Fixes possible asynchronous requests
	    mxUtils.getAll([bundle, STYLE_PATH + '/default.xml'], function (xhr) {
	        // Adds bundle text to resources
	        mxResources.parse(xhr[0].getText());

	        // Configures the default graph theme
	        var themes = new Object();
	        themes[Graph.prototype.defaultThemeName] = xhr[1].getDocumentElement();

	        // Main
	        editor = new Editor(urlParams['chrome'] == '0', themes);
	        new EditorUi(editor);
	        readfromnet();
	    }, function () {
	        document.body.innerHTML = '<center style="margin-top:10%;">Error loading resource files. Please check browser console.</center>';
	    });
	    //})();

	    var snum = "<%=Snum+Id %>";
	    var savekey = "wzsxgraph" + snum;
	    var savemsg = document.getElementById("savemsg");

	    function savetoxml() {
	        $(".savetext").attr("disabled", "true");
	        var format = "png";
	        var bg = '#ffffff';
	        var scale = 1;
	        var b = 1;

	        var graph = editor.graph;
	        var xml = mxUtils.getXml(new mxCodec().encode(graph.getModel()));
	        console.log(xml);
	        console.log("保存xml成功")
	        if (xml.indexOf("mxGeometry") != -1) {
	            console.log("有内容");
	            sessionStorage.setItem(savekey, xml); //sessionStorage  localStorage
	            //var filename='mxgraph'+ parseInt(Math.random()*100)+'.xml';
	            //downFile(xml,filename)

	            // New image export
	            var imgExport = new mxImageExport();
	            var bounds = graph.getGraphBounds();
	            var vs = graph.view.scale;
	            var xmlDoc = mxUtils.createXmlDocument();
	            var root = xmlDoc.createElement('output');
	            xmlDoc.appendChild(root);
	            // Renders graph. Offset will be multiplied with state's scale when painting state.
	            var xmlCanvas = new mxXmlCanvas2D(root);
	            xmlCanvas.translate(Math.floor((b / scale - bounds.x) / vs), Math.floor((b / scale - bounds.y) / vs));
	            xmlCanvas.scale(scale / vs);
	            imgExport.drawState(graph.getView().getState(graph.model.root), xmlCanvas);
	            // Puts request data together
	            var w = Math.ceil(bounds.width * scale / vs + 2 * b);
	            var h = Math.ceil(bounds.height * scale / vs + 2 * b);
	            var exml = mxUtils.getXml(root);

	            if (bg != null) {
	                bg = '&bg=' + bg;
	            }

	            var id = window._mxgraphFixedId || "<%=Id %>";
	            console.log('[mxgraph-fix] 保存使用Id=' + id);
	            var urls = 'uploadgraph.ashx?id=' + id;
	            var formData = new FormData();
                xml=encodeURIComponent(xml);
                exml=encodeURIComponent(exml);//编码

	            formData.append('xml', xml);
	            formData.append('exml', exml);
	            formData.append('w', w);
	            formData.append('h', h);
	            formData.append('bg', bg);

	            $.ajax({
	                url: urls,
	                type: 'POST',
	                cache: false,
	                data: formData,
	                processData: false,
	                contentType: false
	            }).done(function (res) {
	                alert("保存成功！");
	                $(".savetext").attr("disabled", "false");
	                console.log(res)
	            }).fail(function (res) {
	                alert("保存失败！");
	                console.log(res)
	            });
	        } else {
	            console.log("无内容");
	        }
	    }

	    function readfromxml() {
	        var valuexml = sessionStorage.getItem(savekey);
	        if (valuexml != null) {
	            //console.log(valuexml);
	            var doc = mxUtils.parseXml(valuexml);
	            var codec = new mxCodec(doc);
	            var root = doc.documentElement;
	            var graph = editor.graph;
	            codec.decode(root, graph.getModel());
	            console.log("读取xml成功")
	        }
	    }
	    function readfromnet() {
	        var sessionxml = sessionStorage.getItem(savekey);
	        console.log("本地存储：");
	        //console.log(sessionxml);
	        var codefile = "<%=codefile %>";
	        //console.log(codefile);
	        codefile = decodeURIComponent(codefile);
	        codefile = decodeURIComponent(codefile);//二次加密，所以这里要二次解密
	        console.log("读取作品：");
	        //console.log(codefile);
	        var viewxml;
	        if (codefile != null) viewxml = codefile;
	        if (sessionxml != null) viewxml = sessionxml;

	        if (viewxml != null) {
	            var doc = mxUtils.parseXml(viewxml);
	            var codec = new mxCodec(doc);
	            var root = doc.documentElement;
	            var graph = editor.graph;
	            codec.decode(root, graph.getModel());
	        }
	    }
	    function returnurl() {
	        var fpage = window._mxgraphFixedFpage || "<%=Fpage %>";
	        console.log('[mxgraph-fix] 返回URL: ' + fpage);
	        window.location.href = fpage;
	    }

	    function downFile(content, filename) {
	        var ele = document.createElement('a'); // 创建下载链接
	        ele.download = filename; //设置下载的名称
	        ele.style.display = 'none'; // 隐藏的可下载链接
	        // 字符内容转变成blob地址
	        var blob = new Blob([content]);
	        ele.href = URL.createObjectURL(blob);
	        // 绑定点击时间
	        document.body.appendChild(ele);
	        ele.click();
	        // 然后移除
	        document.body.removeChild(ele);
	    };

	    function showcontent() {
	        $("#mcontext").slideToggle();
	    }
	</script>

<script>
    // ========== 类型验证与修复模块（mxgraph流程图） ==========
    (function() {
        function _getParam(name) {
            var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)');
            var r = window.location.search.substr(1).match(reg);
            return r ? decodeURIComponent(r[2]) : '';
        }
        var _lid = _getParam('lid'), _mid = _getParam('mid'), _mcid = _getParam('mcid');
        var _isDebug = _getParam('debug') === '1';
        var _serverId = "<%=Id %>";
        var _serverFpage = "<%=Fpage %>";
        var _calcId = _mcid + '-' + _mid + '-' + _lid;
        var _fixData = null;

        console.log('[mxgraph-debug] URL参数: lid=' + _lid + ', mid=' + _mid + ', mcid=' + _mcid);
        console.log('[mxgraph-debug] DLL值: Id=' + _serverId + ', Fpage=' + _serverFpage);
        if (_serverId !== _calcId) console.warn('[mxgraph-fix] Id不一致! DLL=' + _serverId + ', 计算=' + _calcId);

        // 调试面板
        function _createDebugPanel() {
            var p = document.createElement('div');
            p.id = 'mxgraph-debug-panel';
            p.style.cssText = 'display:none;position:fixed;z-index:9999;top:36px;right:0;width:480px;max-height:70vh;overflow-y:auto;' +
                'background:#eff6ff;border:2px solid #3b82f6;border-radius:0 0 0 12px;padding:14px 16px;font-size:12px;line-height:1.7;color:#1e40af;' +
                'box-shadow:0 4px 24px rgba(0,0,0,0.15);font-family:Consolas,Monaco,monospace;';
            p.innerHTML = '<div style="font-weight:700;font-size:14px;margin-bottom:8px;border-bottom:1px solid #93c5fd;padding-bottom:6px;">' +
                '🔍 mxgraph 调试面板 (流程图) <span id="_mdbg_close" style="float:right;cursor:pointer;font-size:16px;">&times;</span></div>' +
                '<div id="_mdbg_content">加载中...</div>';
            document.body.appendChild(p);
            document.getElementById('_mdbg_close').onclick = function() { p.style.display = 'none'; };
            return p;
        }

        function _updateDebugPanel(d) {
            var el = document.getElementById('_mdbg_content');
            if (!el) return;
            var h = '';
            h += '<b>== URL参数 ==</b><br/>lid=' + _lid + ', mid=' + _mid + ', mcid=' + _mcid + '<br/><br/>';
            h += '<b>== DLL值 ==</b><br/>Id=<code>' + _serverId + '</code><br/>Fpage=<code>' + _serverFpage + '</code><br/><br/>';
            if (d) {
                h += '<b>== 任务类型检查 ==</b><br/>';
                h += '当前页面=<code>' + d.currentPage + '</code> (期望Ltype=<code>' + d.expectedLtype + '</code> 流程图)<br/>';
                h += '数据库Ltype=<code>' + d.dbLtype + '</code> → 归一化=<code>' + d.normalizedLtype + '</code> (' + d.normalizedLtypeName + ')<br/>';
                if (d.typeMismatch) {
                    h += '<div style="margin:6px 0;padding:8px 12px;background:#fef2f2;border:1px solid #fca5a5;border-radius:6px;color:#dc2626;font-weight:700;">';
                    h += '⚠ 类型不匹配! 数据库实际类型=<code>' + d.normalizedLtypeName + '</code>(Ltype=' + d.normalizedLtype + ')';
                    h += '，当前页面是 mxgraph.aspx(流程图, Ltype=7)<br/>';
                    h += '应跳转: <a href="' + d.correctPageForType + '" style="color:#2563eb;">' + d.correctPageForType + '</a></div>';
                } else {
                    h += '<span style="color:#059669;font-weight:700;">✅ 类型匹配正确(流程图)</span><br/>';
                }
                h += '<br/><b>== 数据库 ==</b><br/>';
                h += 'Lxid=<code>' + d.dbLxid + '</code>, Lcid=<code>' + d.dbLcid + '</code><br/>';
                h += 'Ltitle=<code>' + (d.dbLtitle||'') + '</code><br/>';
                h += 'Mission=<code>' + (d.missionTitle||'') + '</code><br/>';
                h += 'snum=<code>' + (d.snum||'未登录') + '</code>, Works.Wid=<code>' + (d.worksWid||'无') + '</code><br/>';
                h += '<br/><b>== 修正 ==</b><br/>';
                var idOk = (_serverId === d.correctId);
                h += 'correctId=<code>' + d.correctId + '</code> ' + (idOk ? '✅' : '🔧 DLL原值=' + _serverId) + '<br/>';
                if (d.error) h += '<br/><b style="color:#dc2626;">⚠ ' + d.error + '</b><br/>';
            } else {
                h += '<b style="color:#dc2626;">⚠ handler请求失败</b>';
            }
            el.innerHTML = h;
        }

        // Ctrl+Shift+D 打开调试面板
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.shiftKey && e.keyCode === 68) {
                var p = document.getElementById('mxgraph-debug-panel') || _createDebugPanel();
                p.style.display = p.style.display === 'none' ? 'block' : 'none';
                if (p.style.display === 'block' && _fixData) _updateDebugPanel(_fixData);
                e.preventDefault();
            }
        });

        // 页面加载后调用handler验证类型
        $(function() {
            $.ajax({
                url: 'mxgraph-fix.ashx?lid=' + _lid + '&mid=' + _mid + '&mcid=' + _mcid,
                type: 'GET', dataType: 'json', timeout: 8000
            }).done(function(data) {
                _fixData = data;
                console.log('[mxgraph-debug] handler返回:', data);
                console.log('[mxgraph-debug] 类型: dbLtype=' + data.dbLtype +
                    ', normalized=' + data.normalizedLtype + '(' + data.normalizedLtypeName + ')' +
                    ', expected=' + data.expectedLtype + ', mismatch=' + data.typeMismatch);

                // 类型不匹配时自动跳转
                if (data.typeMismatch && data.correctPageForType) {
                    console.warn('[mxgraph-fix] 类型不匹配! 跳转到: ' + data.correctPageForType);
                    if (_isDebug) {
                        var p = _createDebugPanel(); p.style.display = 'block';
                        _updateDebugPanel(data);
                        return;
                    }
                    window.location.href = data.correctPageForType;
                    return;
                }

                // Id修正 — 覆盖DLL的savetoxml中使用的id
                if (data.correctId && data.correctId !== _serverId) {
                    console.log('[mxgraph-fix] 修正Id: ' + _serverId + ' → ' + data.correctId);
                    // 重写savetoxml函数中使用的id
                    window._mxgraphFixedId = data.correctId;
                }

                if (_isDebug) {
                    var p = _createDebugPanel(); p.style.display = 'block';
                    _updateDebugPanel(data);
                }
            }).fail(function(xhr, st, err) {
                console.error('[mxgraph-fix] handler失败:', st, err);
                if (_isDebug) {
                    var p = _createDebugPanel(); p.style.display = 'block';
                    _updateDebugPanel(null);
                }
            });
        });

        // 覆盖原始savetoxml中的id获取（安全补丁）
        var _origSavetoxml = window.savetoxml;
        window.savetoxml = function() {
            if (window._mxgraphFixedId) {
                console.log('[mxgraph-fix] 保存使用修正Id: ' + window._mxgraphFixedId);
            }
            _origSavetoxml.apply(this, arguments);
        };
    })();
</script>

</body>
</html>
