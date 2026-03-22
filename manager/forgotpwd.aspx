<%@ page language="C#" autoeventwireup="true" %>

<script runat="server">
    protected string GetSiteTitle()
    {
        try
        {
            string xmlPath = Server.MapPath("~/website.xml");
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            System.Xml.XmlNode node = doc.SelectSingleNode("//add[@key='SiteTitle']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value;
        }
        catch { }
        return "LearnSite";
    }

    protected string GetFaviconLinkTag()
    {
        string icoPath = Server.MapPath("~/favicon.ico");
        if (System.IO.File.Exists(icoPath))
            return "<link rel=\"icon\" type=\"image/x-icon\" href=\"" + ResolveUrl("~/favicon.ico") + "?v=" + System.IO.File.GetLastWriteTime(icoPath).Ticks + "\" />";
        string pngPath = Server.MapPath("~/favicon.png");
        if (System.IO.File.Exists(pngPath))
            return "<link rel=\"icon\" type=\"image/png\" href=\"" + ResolveUrl("~/favicon.png") + "?v=" + System.IO.File.GetLastWriteTime(pngPath).Ticks + "\" />";
        return "";
    }
</script>

+<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title><%= GetSiteTitle() %> - 找回密码</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <%= GetFaviconLinkTag() %>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;
            min-height:100vh;
            background:#ffffff;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:0;
            overflow:hidden;
        }
        .forgot-container {
            display:flex;
            width:100%;
            max-width:1200px;
            min-height:100vh;
            background:#fff;
        }
        .forgot-left {
            flex:1;
            background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:center;
            padding:60px 40px;
            position:relative;
            overflow:hidden;
        }
        .forgot-left::before {
            content:'';
            position:absolute;
            width:400px;
            height:400px;
            background:rgba(255,255,255,0.1);
            border-radius:50%;
            top:-100px;
            right:-100px;
        }
        .forgot-left::after {
            content:'';
            position:absolute;
            width:300px;
            height:300px;
            background:rgba(255,255,255,0.08);
            border-radius:50%;
            bottom:-80px;
            left:-80px;
        }
        .logo-section {
            text-align:center;
            position:relative;
            z-index:1;
        }
        .logo-icon {
            width:120px;
            height:120px;
            background:rgba(255,255,255,0.2);
            backdrop-filter:blur(10px);
            border-radius:30px;
            display:flex;
            align-items:center;
            justify-content:center;
            margin:0 auto 24px;
            box-shadow:0 8px 32px rgba(0,0,0,0.1);
        }
        .logo-icon svg {
            width:60px;
            height:60px;
            stroke:#fff;
            fill:none;
            stroke-width:1.5;
            stroke-linecap:round;
            stroke-linejoin:round;
        }
        .logo-title {
            font-size:32px;
            font-weight:700;
            color:#fff;
            margin-bottom:12px;
            text-shadow:0 2px 8px rgba(0,0,0,0.1);
        }
        .logo-subtitle {
            font-size:16px;
            color:rgba(255,255,255,0.9);
            line-height:1.6;
            max-width:360px;
            margin:0 auto;
        }
        .forgot-right {
            flex:1;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:40px;
            background:#fafbfc;
        }
        .forgot-card {
            width:100%;
            max-width:440px;
            background:#fff;
            border-radius:16px;
            border:1px solid #e2e8f0;
            padding:40px 36px;
            box-shadow:0 4px 12px rgba(0,0,0,0.05);
        }
        @media (max-width: 968px) {
            .forgot-container {
                flex-direction:column;
            }
            .forgot-left {
                min-height:300px;
                padding:40px 20px;
            }
            .logo-icon {
                width:80px;
                height:80px;
            }
            .logo-icon svg {
                width:40px;
                height:40px;
            }
            .logo-title {
                font-size:24px;
            }
            .logo-subtitle {
                font-size:14px;
            }
            .forgot-right {
                padding:30px 20px;
            }
        }
        .forgot-header {
            text-align:center;
            margin-bottom:28px;
        }
        .forgot-header-icon {
            width:56px;height:56px;
            background:linear-gradient(135deg,#6366f1,#a78bfa);
            border-radius:16px;
            display:inline-flex;align-items:center;justify-content:center;
            box-shadow:0 4px 14px rgba(99,102,241,.3);
            margin-bottom:14px;
        }
        .forgot-header-icon svg { width:28px;height:28px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round; }
        .forgot-header h1 { font-size:22px;font-weight:700;color:#1e293b;margin:0 0 4px; }
        .forgot-header p { font-size:13px;color:#94a3b8; }

        /* Steps indicator */
        .steps { display:flex; align-items:center; justify-content:center; gap:0; margin-bottom:28px; }
        .step-dot { width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;
            font-size:13px;font-weight:700;color:#94a3b8;background:#f1f5f9;border:2px solid #e2e8f0;transition:all .3s;flex-shrink:0; }
        .step-dot.active { background:linear-gradient(135deg,#6366f1,#a78bfa);color:#fff;border-color:#6366f1;box-shadow:0 2px 8px rgba(99,102,241,.3); }
        .step-dot.done { background:#10b981;color:#fff;border-color:#10b981; }
        .step-line { width:40px;height:2px;background:#e2e8f0;transition:background .3s; }
        .step-line.active { background:#6366f1; }

        /* Form fields */
        .form-group { margin-bottom:18px; }
        .form-label { display:block;font-size:13px;font-weight:500;color:#475569;margin-bottom:6px; }
        .form-input {
            width:100%;height:42px;padding:0 16px;border:1.5px solid #e2e8f0;border-radius:10px;
            font-size:14px;font-family:inherit;outline:none;background:#f8fafc;transition:all .2s;
        }
        .form-input:focus { border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.08);background:#fff; }
        .form-input:disabled { background:#f1f5f9;color:#94a3b8;cursor:not-allowed; }

        .email-display {
            padding:10px 16px;background:#eef2ff;border-radius:10px;font-size:13.5px;color:#4f46e5;
            display:flex;align-items:center;gap:8px;margin-bottom:18px;
        }
        .email-display svg { width:18px;height:18px;stroke:#6366f1;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0; }

        .btn-primary {
            width:100%;height:44px;border:none;border-radius:10px;
            background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff;
            font-size:14px;font-family:inherit;font-weight:600;cursor:pointer;
            transition:all .2s;box-shadow:0 4px 12px rgba(99,102,241,.3);
            display:flex;align-items:center;justify-content:center;gap:6px;
        }
        .btn-primary:hover { box-shadow:0 6px 20px rgba(99,102,241,.4);transform:translateY(-1px); }
        .btn-primary:disabled { opacity:.5;cursor:not-allowed;transform:none; }

        .btn-secondary {
            width:100%;height:44px;border:1.5px solid #e2e8f0;border-radius:10px;
            background:#fff;color:#475569;font-size:14px;font-family:inherit;font-weight:500;
            cursor:pointer;transition:all .2s;margin-top:10px;
            display:flex;align-items:center;justify-content:center;gap:6px;
        }
        .btn-secondary:hover { background:#f8fafc;border-color:#cbd5e1; }

        .code-row { display:flex; gap:10px; margin-bottom:18px; }
        .code-row .form-input { flex:1; }
        .btn-sendcode {
            height:42px;padding:0 16px;border:none;border-radius:10px;
            background:linear-gradient(135deg,#10b981,#059669);color:#fff;
            font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;
            transition:all .2s;white-space:nowrap;flex-shrink:0;
        }
        .btn-sendcode:hover { box-shadow:0 4px 12px rgba(16,185,129,.3); }
        .btn-sendcode:disabled { opacity:.5;cursor:not-allowed; }

        .msg { margin-top:14px;padding:8px 14px;border-radius:8px;font-size:13px;display:none;text-align:center; }
        .msg.err { display:block;background:#fef2f2;color:#dc2626; }
        .msg.ok { display:block;background:#ecfdf5;color:#059669; }
        .msg.info { display:block;background:#eef2ff;color:#6366f1; }

        .back-link {
            display:block;text-align:center;margin-top:20px;font-size:13px;color:#94a3b8;text-decoration:none;transition:color .2s;
        }
        .back-link:hover { color:#6366f1; }

        /* 成功页 */
        .success-icon { text-align:center;margin-bottom:16px; }
        .success-icon .circle { width:72px;height:72px;border-radius:50%;background:linear-gradient(135deg,#10b981,#34d399);
            display:inline-flex;align-items:center;justify-content:center;box-shadow:0 4px 14px rgba(16,185,129,.3); }
        .success-icon svg { width:36px;height:36px;stroke:#fff;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round; }
        .success-text { text-align:center;font-size:16px;font-weight:600;color:#1e293b;margin-bottom:6px; }
        .success-hint { text-align:center;font-size:13px;color:#94a3b8;margin-bottom:24px; }
    </style>
</head>
<body>
    <div class="forgot-container">
        <!-- 左侧Logo区域 -->
        <div class="forgot-left">
            <div class="logo-section">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M12 2L2 7l10 5 10-5-10-5z"/>
                        <path d="M2 17l10 5 10-5"/>
                        <path d="M2 12l10 5 10-5"/>
                    </svg>
                </div>
                <h1 class="logo-title"><%= GetSiteTitle() %></h1>
                <p class="logo-subtitle">安全、便捷的密码找回服务<br/>通过邮箱验证快速重置您的账户密码</p>
            </div>
        </div>
        
        <!-- 右侧表单区域 -->
        <div class="forgot-right">
    <div class="forgot-card">
        <div class="forgot-header">
            <div class="forgot-header-icon">
                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <h1>找回密码</h1>
            <p>通过绑定的邮箱验证身份并重置密码</p>
        </div>

        <!-- Steps -->
        <div class="steps">
            <div class="step-dot active" id="s1">1</div>
            <div class="step-line" id="sl1"></div>
            <div class="step-dot" id="s2">2</div>
            <div class="step-line" id="sl2"></div>
            <div class="step-dot" id="s3">3</div>
        </div>

        <!-- Step 1: 输入用户名 -->
        <div id="panel1">
            <div class="form-group">
                <label class="form-label">用户名（教师/管理员登录名）</label>
                <input type="text" class="form-input" id="inputUsername" placeholder="请输入您的用户名" autocomplete="off" />
            </div>
            <button type="button" class="btn-primary" id="btnLookup" onclick="doLookup()">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                查询绑定邮箱
            </button>
            <div class="msg" id="msg1"></div>
        </div>

        <!-- Step 2: 发送验证码 -->
        <div id="panel2" style="display:none;">
            <div class="email-display" id="emailDisplay">
                <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                <span id="maskedEmail"></span>
            </div>
            <div class="code-row">
                <input type="text" class="form-input" id="inputCode" placeholder="输入6位验证码" maxlength="6" autocomplete="off" />
                <button type="button" class="btn-sendcode" id="btnSendCode" onclick="doSendCode()">发送验证码</button>
            </div>
            <div class="form-group">
                <label class="form-label">新密码</label>
                <input type="password" class="form-input" id="inputNewPwd" placeholder="请输入新密码（至少3位）" />
            </div>
            <div class="form-group">
                <label class="form-label">确认新密码</label>
                <input type="password" class="form-input" id="inputConfirmPwd" placeholder="请再次输入新密码" />
            </div>
            <button type="button" class="btn-primary" id="btnReset" onclick="doReset()">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                重置密码
            </button>
            <button type="button" class="btn-secondary" onclick="goStep1()">返回上一步</button>
            <div class="msg" id="msg2"></div>
        </div>

        <!-- Step 3: 成功 -->
        <div id="panel3" style="display:none;">
            <div class="success-icon">
                <div class="circle">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
            </div>
            <div class="success-text">密码重置成功</div>
            <div class="success-hint">请使用新密码登录系统</div>
            <a href="index.aspx" class="btn-primary" style="text-decoration:none;">返回登录</a>
        </div>

        <a href="index.aspx" class="back-link" id="backLink">← 返回登录页</a>
    </div>
        </div>
    </div>

    <script type="text/javascript">
        var apiUrl = '<%= ResolveUrl("~/manager/sendemail_new.ashx") %>';
        var currentUsername = '';
        var countdown = 0;
        var countdownTimer = null;

        function showMsg(id, type, text) {
            var el = document.getElementById(id);
            el.className = 'msg ' + type;
            el.textContent = text;
        }
        function hideMsg(id) {
            document.getElementById(id).className = 'msg';
        }

        function setStep(n) {
            for (var i = 1; i <= 3; i++) {
                var dot = document.getElementById('s' + i);
                dot.className = 'step-dot' + (i < n ? ' done' : (i === n ? ' active' : ''));
                if (i < n) dot.innerHTML = '&#10003;';
            }
            var sl1 = document.getElementById('sl1');
            var sl2 = document.getElementById('sl2');
            sl1.className = 'step-line' + (n >= 2 ? ' active' : '');
            sl2.className = 'step-line' + (n >= 3 ? ' active' : '');

            document.getElementById('panel1').style.display = n === 1 ? '' : 'none';
            document.getElementById('panel2').style.display = n === 2 ? '' : 'none';
            document.getElementById('panel3').style.display = n === 3 ? '' : 'none';
            document.getElementById('backLink').style.display = n === 3 ? 'none' : '';
        }

        function goStep1() {
            setStep(1);
            hideMsg('msg1');
            hideMsg('msg2');
        }

        // Step 1: 查询邮箱
        function doLookup() {
            var username = document.getElementById('inputUsername').value.trim();
            if (!username) {
                showMsg('msg1', 'err', '请输入用户名');
                return;
            }
            hideMsg('msg1');
            var btn = document.getElementById('btnLookup');
            btn.disabled = true;
            btn.innerHTML = '查询中...';

            var xhr = new XMLHttpRequest();
            xhr.open('GET', apiUrl + '?action=lookup&username=' + encodeURIComponent(username), true);
            xhr.onload = function() {
                btn.disabled = false;
                btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg> 查询绑定邮箱';
                try {
                    if (xhr.status !== 200) {
                        showMsg('msg1', 'err', '服务器错误 ' + xhr.status + '，响应内容：' + xhr.responseText.substring(0, 200));
                        return;
                    }
                    var res = JSON.parse(xhr.responseText);
                    if (res.success === 1) {
                        currentUsername = username;
                        document.getElementById('maskedEmail').textContent = '验证码将发送至：' + res.email;
                        setStep(2);
                    } else {
                        showMsg('msg1', 'err', res.message || '请求失败');
                    }
                } catch(e) {
                    showMsg('msg1', 'err', '解析错误：' + (e.message || '未知错误') + '。响应：' + xhr.responseText.substring(0, 200));
                }
            };
            xhr.onerror = function() {
                btn.disabled = false;
                btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg> 查询绑定邮箱';
                showMsg('msg1', 'err', '网络错误，无法连接服务器');
            };
            xhr.send();
        }

        // Step 2: 发送验证码
        function doSendCode() {
            var btn = document.getElementById('btnSendCode');
            if (countdown > 0) return;

            btn.disabled = true;
            btn.textContent = '发送中...';
            hideMsg('msg2');

            var xhr = new XMLHttpRequest();
            xhr.open('GET', apiUrl + '?action=sendcode&username=' + encodeURIComponent(currentUsername), true);
            xhr.onload = function() {
                try {
                    if (xhr.status !== 200) {
                        btn.disabled = false;
                        btn.textContent = '发送验证码';
                        showMsg('msg2', 'err', '服务器错误 ' + xhr.status);
                        return;
                    }
                    var res = JSON.parse(xhr.responseText);
                    if (res.success === 1) {
                        showMsg('msg2', 'ok', res.message || '验证码已发送');
                        startCountdown();
                    } else {
                        btn.disabled = false;
                        btn.textContent = '发送验证码';
                        showMsg('msg2', 'err', res.message || '发送失败');
                    }
                } catch(e) {
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                    showMsg('msg2', 'err', '请求失败：' + (e.message || '未知错误'));
                }
            };
            xhr.onerror = function() {
                btn.disabled = false;
                btn.textContent = '发送验证码';
                showMsg('msg2', 'err', '网络错误，无法连接服务器');
            };
            xhr.send();
        }

        function startCountdown() {
            countdown = 60;
            var btn = document.getElementById('btnSendCode');
            btn.disabled = true;
            btn.textContent = countdown + '秒后重发';
            countdownTimer = setInterval(function() {
                countdown--;
                if (countdown <= 0) {
                    clearInterval(countdownTimer);
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                } else {
                    btn.textContent = countdown + '秒后重发';
                }
            }, 1000);
        }

        // Step 2: 重置密码
        function doReset() {
            var code = document.getElementById('inputCode').value.trim();
            var newpwd = document.getElementById('inputNewPwd').value;
            var confirm = document.getElementById('inputConfirmPwd').value;
            hideMsg('msg2');

            if (!code) { showMsg('msg2', 'err', '请输入验证码'); return; }
            if (!newpwd) { showMsg('msg2', 'err', '请输入新密码'); return; }
            if (newpwd.length < 3) { showMsg('msg2', 'err', '密码长度不能少于3位'); return; }
            if (newpwd !== confirm) { showMsg('msg2', 'err', '两次输入的密码不一致'); return; }

            var btn = document.getElementById('btnReset');
            btn.disabled = true;
            btn.innerHTML = '重置中...';

            var xhr = new XMLHttpRequest();
            xhr.open('GET', apiUrl + '?action=verifycode&username=' + encodeURIComponent(currentUsername) + '&code=' + encodeURIComponent(code) + '&newpwd=' + encodeURIComponent(newpwd), true);
            xhr.onload = function() {
                btn.disabled = false;
                btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg> 重置密码';
                try {
                    if (xhr.status !== 200) {
                        showMsg('msg2', 'err', '服务器错误 ' + xhr.status);
                        return;
                    }
                    var res = JSON.parse(xhr.responseText);
                    if (res.success === 1) {
                        setStep(3);
                    } else {
                        showMsg('msg2', 'err', res.message || '重置失败');
                    }
                } catch(e) {
                    showMsg('msg2', 'err', '请求失败：' + (e.message || '未知错误'));
                }
            };
            xhr.onerror = function() {
                btn.disabled = false;
                btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg> 重置密码';
                showMsg('msg2', 'err', '网络错误，无法连接服务器');
            };
            xhr.send();
        }

        // 回车键支持
        document.getElementById('inputUsername').addEventListener('keydown', function(e) {
            if (e.keyCode === 13) { e.preventDefault(); doLookup(); }
        });
        document.getElementById('inputCode').addEventListener('keydown', function(e) {
            if (e.keyCode === 13) { e.preventDefault(); doReset(); }
        });
    </script>
</body>
</html>
