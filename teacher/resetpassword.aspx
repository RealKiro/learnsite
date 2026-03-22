<%@ Page Language="C#" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>找回密码 - 信息科技学习平台</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
            background: #ffffff;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            display: flex;
            max-width: 1200px;
            width: 100%;
            background: #fff;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        
        /* 左侧信息区 */
        .info-section {
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 60px 50px;
            color: #fff;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .logo {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .logo svg {
            width: 40px;
            height: 40px;
        }
        
        .logo img {
            width: 48px;
            height: 48px;
            object-fit: contain;
            border-radius: 8px;
        }
        
        .tagline {
            font-size: 18px;
            margin-bottom: 50px;
            opacity: 0.9;
        }
        
        .features {
            display: flex;
            flex-direction: column;
            gap: 30px;
        }
        
        .feature {
            display: flex;
            gap: 20px;
            align-items: flex-start;
        }
        
        .feature-icon {
            width: 50px;
            height: 50px;
            background: rgba(255,255,255,0.2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        
        .feature-icon svg {
            width: 24px;
            height: 24px;
        }
        
        .feature-content h3 {
            font-size: 18px;
            margin-bottom: 8px;
        }
        
        .feature-content p {
            font-size: 14px;
            opacity: 0.9;
            line-height: 1.6;
        }
        
        /* 右侧表单区 */
        .form-section {
            flex: 1;
            padding: 60px 50px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .form-header {
            margin-bottom: 40px;
        }
        
        .form-title {
            font-size: 32px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
        }
        
        .form-subtitle {
            font-size: 15px;
            color: #64748b;
        }
        
        /* 步骤指示器 */
        .steps {
            display: flex;
            justify-content: space-between;
            margin-bottom: 40px;
            position: relative;
        }
        
        .steps::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            height: 2px;
            background: #e2e8f0;
            z-index: 0;
        }
        
        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            position: relative;
            z-index: 1;
        }
        
        .step-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #e2e8f0;
            color: #94a3b8;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s;
        }
        
        .step.active .step-circle {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            box-shadow: 0 4px 12px rgba(102,126,234,0.4);
        }
        
        .step.completed .step-circle {
            background: #10b981;
            color: #fff;
        }
        
        .step-label {
            font-size: 13px;
            color: #64748b;
            font-weight: 500;
        }
        
        .step.active .step-label {
            color: #667eea;
            font-weight: 600;
        }
        
        /* 表单样式 */
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
        }
        
        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
            font-family: inherit;
        }
        
        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102,126,234,0.1);
        }
        
        .input-group {
            position: relative;
        }
        
        .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        
        .input-icon svg {
            width: 20px;
            height: 20px;
        }
        
        .form-input.with-icon {
            padding-left: 48px;
        }
        
        .btn-send-code {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            padding: 6px 16px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-send-code:hover {
            transform: translateY(-50%) scale(1.05);
            box-shadow: 0 4px 12px rgba(102,126,234,0.4);
        }
        
        .btn-send-code:disabled {
            background: #cbd5e1;
            cursor: not-allowed;
            transform: translateY(-50%);
        }
        
        .btn-primary {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102,126,234,0.4);
        }
        
        .btn-primary:active {
            transform: translateY(0);
        }
        
        .form-footer {
            margin-top: 30px;
            text-align: center;
            font-size: 14px;
            color: #64748b;
        }
        
        .form-footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .form-footer a:hover {
            color: #764ba2;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: none;
        }
        
        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #10b981;
        }
        
        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #ef4444;
        }
        
        .alert-info {
            background: #dbeafe;
            color: #1e40af;
            border: 1px solid #3b82f6;
        }
        
        .step-content {
            display: none;
        }
        
        .step-content.active {
            display: block;
        }
        
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 13px;
            color: #94a3b8;
        }
        
        @media (max-width: 968px) {
            .info-section {
                display: none;
            }
            
            .container {
                max-width: 500px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 左侧信息区 -->
        <div class="info-section">
            <div class="logo" id="brandLogo">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 2L2 7l10 5 10-5-10-5z"/>
                    <path d="M2 17l10 5 10-5"/>
                    <path d="M2 12l10 5 10-5"/>
                </svg>
                信息科技学习平台
            </div>
            <p class="tagline">安全便捷的密码找回服务</p>
            
            <div class="features">
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </div>
                    <div class="feature-content">
                        <h3>安全验证</h3>
                        <p>通过邮箱验证码确保账号安全，保护您的个人信息</p>
                    </div>
                </div>
                
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                            <polyline points="22 4 12 14.01 9 11.01"/>
                        </svg>
                    </div>
                    <div class="feature-content">
                        <h3>快速找回</h3>
                        <p>简单三步即可完成密码重置，快速恢复账号访问</p>
                    </div>
                </div>
                
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                        </svg>
                    </div>
                    <div class="feature-content">
                        <h3>隐私保护</h3>
                        <p>所有操作均经过加密处理，确保您的密码安全</p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 右侧表单区 -->
        <div class="form-section">
            <div class="form-header">
                <h1 class="form-title">找回密码</h1>
                <p class="form-subtitle">请按照以下步骤重置您的密码</p>
            </div>
            
            <!-- 步骤指示器 -->
            <div class="steps">
                <div class="step active" id="step1Indicator">
                    <div class="step-circle">1</div>
                    <div class="step-label">验证身份</div>
                </div>
                <div class="step" id="step2Indicator">
                    <div class="step-circle">2</div>
                    <div class="step-label">验证邮箱</div>
                </div>
                <div class="step" id="step3Indicator">
                    <div class="step-circle">3</div>
                    <div class="step-label">重置密码</div>
                </div>
            </div>
            
            <!-- 提示信息 -->
            <div id="alertBox" class="alert"></div>
            
            <!-- 步骤1: 验证身份 -->
            <div id="step1" class="step-content active">
                <div class="form-group">
                    <label class="form-label">用户名</label>
                    <div class="input-group">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                <circle cx="12" cy="7" r="4"/>
                            </svg>
                        </span>
                        <input type="text" id="username" class="form-input with-icon" placeholder="请输入您的用户名">
                    </div>
                </div>
                
                <button type="button" class="btn-primary" onclick="goToStep2()">下一步</button>
            </div>
            
            <!-- 步骤2: 验证邮箱 -->
            <div id="step2" class="step-content">
                <div class="form-group">
                    <label class="form-label">邮箱地址</label>
                    <div class="input-group">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                                <polyline points="22,6 12,13 2,6"/>
                            </svg>
                        </span>
                        <input type="email" id="email" class="form-input with-icon" placeholder="请输入绑定的邮箱地址" readonly>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">验证码</label>
                    <div class="input-group">
                        <input type="text" id="verifyCode" class="form-input" placeholder="请输入6位验证码" maxlength="6">
                        <button type="button" class="btn-send-code" id="sendCodeBtn" onclick="sendVerifyCode()">发送验证码</button>
                    </div>
                </div>
                
                <button type="button" class="btn-primary" onclick="goToStep3()">验证并继续</button>
                <div class="form-footer">
                    <a href="javascript:void(0)" onclick="goToStep1()">返回上一步</a>
                </div>
            </div>
            
            <!-- 步骤3: 重置密码 -->
            <div id="step3" class="step-content">
                <div class="form-group">
                    <label class="form-label">新密码</label>
                    <div class="input-group">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                            </svg>
                        </span>
                        <input type="password" id="newPassword" class="form-input with-icon" placeholder="请输入新密码（至少6位）">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">确认密码</label>
                    <div class="input-group">
                        <span class="input-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                            </svg>
                        </span>
                        <input type="password" id="confirmPassword" class="form-input with-icon" placeholder="请再次输入新密码">
                    </div>
                </div>
                
                <button type="button" class="btn-primary" onclick="resetPassword()">重置密码</button>
                <div class="form-footer">
                    <a href="javascript:void(0)" onclick="goToStep2()">返回上一步</a>
                </div>
            </div>
            
            <div class="footer">
                © 2026 信息科技学习平台 · 保留所有权利
            </div>
        </div>
    </div>
    
    <script>
        var countdown = 60;
        var countdownTimer = null;
        var currentEmail = '';
        var sessionToken = '';
        
        function showAlert(message, type) {
            var alertBox = document.getElementById('alertBox');
            alertBox.textContent = message;
            alertBox.className = 'alert alert-' + type;
            alertBox.style.display = 'block';
            
            setTimeout(function() {
                alertBox.style.display = 'none';
            }, 5000);
        }
        
        function goToStep1() {
            document.getElementById('step1').classList.add('active');
            document.getElementById('step2').classList.remove('active');
            document.getElementById('step3').classList.remove('active');
            
            document.getElementById('step1Indicator').classList.add('active');
            document.getElementById('step2Indicator').classList.remove('active');
            document.getElementById('step3Indicator').classList.remove('active');
            
            document.getElementById('step1Indicator').classList.remove('completed');
            document.getElementById('step2Indicator').classList.remove('completed');
        }
        
        function goToStep2() {
            var username = document.getElementById('username').value.trim();
            if (!username) {
                showAlert('请输入用户名', 'error');
                return;
            }
            
            // 验证用户名并获取邮箱
            fetch('resetpasswordapi.ashx?action=checkuser&username=' + encodeURIComponent(username))
                .then(function(response) { 
                    if (!response.ok) {
                        throw new Error('服务器响应错误: ' + response.status);
                    }
                    return response.text();
                })
                .then(function(text) {
                    try {
                        var data = JSON.parse(text);
                        if (data.success) {
                            currentEmail = data.email;
                            sessionToken = data.token;
                            document.getElementById('email').value = maskEmail(currentEmail);
                            
                            document.getElementById('step1').classList.remove('active');
                            document.getElementById('step2').classList.add('active');
                            
                            document.getElementById('step1Indicator').classList.remove('active');
                            document.getElementById('step1Indicator').classList.add('completed');
                            document.getElementById('step2Indicator').classList.add('active');
                            
                            showAlert('已找到您的账号，请验证邮箱', 'success');
                        } else {
                            var msg = data.message || '用户名不存在或未绑定邮箱';
                            // 翻译英文错误信息
                            if (msg.indexOf('Config file not found') >= 0) msg = '系统配置文件不存在，请联系管理员';
                            if (msg.indexOf('Config read error') >= 0) msg = '配置读取失败: ' + msg.replace('Config read error: ', '');
                            if (msg.indexOf('SMTP server not configured') >= 0) msg = 'SMTP服务器未配置，请在管理后台配置';
                            if (msg.indexOf('Sender email not configured') >= 0) msg = '发件人邮箱未配置，请在管理后台配置';
                            if (msg.indexOf('Email password not configured') >= 0) msg = '邮箱密码未配置，请在管理后台配置';
                            if (msg.indexOf('Email send error') >= 0) msg = '邮件发送失败: ' + msg.replace('Email send error: ', '');
                            showAlert(msg, 'error');
                        }
                    } catch (e) {
                        showAlert('服务器返回数据格式错误: ' + text.substring(0, 100), 'error');
                    }
                })
                .catch(function(err) {
                    showAlert('请求失败: ' + err.message, 'error');
                });
        }
        
        function sendVerifyCode() {
            var btn = document.getElementById('sendCodeBtn');
            if (btn.disabled) return;
            
            var username = document.getElementById('username').value.trim();
            
            fetch('resetpasswordapi.ashx?action=sendcode&username=' + encodeURIComponent(username) + '&token=' + sessionToken)
                .then(function(response) { 
                    if (!response.ok) {
                        throw new Error('服务器响应错误: ' + response.status);
                    }
                    return response.text();
                })
                .then(function(text) {
                    try {
                        var data = JSON.parse(text);
                        if (data.success) {
                            showAlert('验证码已发送到您的邮箱', 'success');
                            startCountdown();
                        } else {
                            var msg = data.message || '发送失败，请稍后重试';
                            // 翻译英文错误信息
                            if (msg.indexOf('Email send error') >= 0) msg = '邮件发送失败: ' + msg.replace('Email send error: ', '');
                            if (msg.indexOf('SMTP server not configured') >= 0) msg = 'SMTP服务器未配置';
                            if (msg.indexOf('Sender email not configured') >= 0) msg = '发件人邮箱未配置';
                            if (msg.indexOf('Email password not configured') >= 0) msg = '邮箱密码未配置';
                            showAlert(msg, 'error');
                        }
                    } catch (e) {
                        showAlert('服务器返回数据格式错误: ' + text.substring(0, 100), 'error');
                    }
                })
                .catch(function(err) {
                    showAlert('请求失败: ' + err.message, 'error');
                });
        }
        
        function startCountdown() {
            var btn = document.getElementById('sendCodeBtn');
            btn.disabled = true;
            countdown = 60;
            
            countdownTimer = setInterval(function() {
                countdown--;
                btn.textContent = countdown + '秒后重发';
                
                if (countdown <= 0) {
                    clearInterval(countdownTimer);
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                }
            }, 1000);
        }
        
        function goToStep3() {
            var code = document.getElementById('verifyCode').value.trim();
            if (!code || code.length !== 6) {
                showAlert('请输入6位验证码', 'error');
                return;
            }
            
            var username = document.getElementById('username').value.trim();
            
            fetch('resetpasswordapi.ashx?action=verifycode&username=' + encodeURIComponent(username) + 
                  '&code=' + encodeURIComponent(code) + '&token=' + sessionToken)
                .then(function(response) { 
                    if (!response.ok) {
                        throw new Error('服务器响应错误: ' + response.status);
                    }
                    return response.text();
                })
                .then(function(text) {
                    try {
                        var data = JSON.parse(text);
                        if (data.success) {
                            document.getElementById('step2').classList.remove('active');
                            document.getElementById('step3').classList.add('active');
                            
                            document.getElementById('step2Indicator').classList.remove('active');
                            document.getElementById('step2Indicator').classList.add('completed');
                            document.getElementById('step3Indicator').classList.add('active');
                            
                            showAlert('验证成功，请设置新密码', 'success');
                        } else {
                            showAlert(data.message || '验证码错误', 'error');
                        }
                    } catch (e) {
                        showAlert('服务器返回数据格式错误: ' + text.substring(0, 100), 'error');
                    }
                })
                .catch(function(err) {
                    showAlert('请求失败: ' + err.message, 'error');
                });
        }
        
        function resetPassword() {
            var newPwd = document.getElementById('newPassword').value;
            var confirmPwd = document.getElementById('confirmPassword').value;
            
            if (!newPwd || newPwd.length < 6) {
                showAlert('密码至少需要6位', 'error');
                return;
            }
            
            if (newPwd !== confirmPwd) {
                showAlert('两次输入的密码不一致', 'error');
                return;
            }
            
            var username = document.getElementById('username').value.trim();
            var code = document.getElementById('verifyCode').value.trim();
            
            fetch('resetpasswordapi.ashx?action=reset&username=' + encodeURIComponent(username) + 
                  '&code=' + encodeURIComponent(code) + '&password=' + encodeURIComponent(newPwd) + 
                  '&token=' + sessionToken)
                .then(function(response) { 
                    if (!response.ok) {
                        throw new Error('服务器响应错误: ' + response.status);
                    }
                    return response.text();
                })
                .then(function(text) {
                    try {
                        var data = JSON.parse(text);
                        if (data.success) {
                            showAlert('密码重置成功！3秒后跳转到登录页...', 'success');
                            setTimeout(function() {
                                window.location.href = 'index.aspx';
                            }, 3000);
                        } else {
                            showAlert(data.message || '重置失败，请重试', 'error');
                        }
                    } catch (e) {
                        showAlert('服务器返回数据格式错误: ' + text.substring(0, 100), 'error');
                    }
                })
                .catch(function(err) {
                    showAlert('请求失败: ' + err.message, 'error');
                });
        }
        
        function maskEmail(email) {
            if (!email) return '';
            var parts = email.split('@');
            if (parts.length !== 2) return email;
            
            var username = parts[0];
            var domain = parts[1];
            
            if (username.length <= 2) {
                return username[0] + '***@' + domain;
            }
            
            return username[0] + '***' + username[username.length - 1] + '@' + domain;
        }
    </script>
    
    <script>
        // 加载网站Logo和名称
        (function() {
            function loadSiteConfig() {
                var logoElement = document.getElementById('brandLogo');
                if (!logoElement) {
                    console.log('Logo element not found, retrying...');
                    setTimeout(loadSiteConfig, 100);
                    return;
                }
                
                console.log('Loading site config...');
                var xhr = new XMLHttpRequest();
                xhr.open('GET', '../manager/getsiteconfig.ashx', true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        console.log('XHR status:', xhr.status);
                        if (xhr.status === 200) {
                            try {
                                console.log('Response:', xhr.responseText);
                                var data = JSON.parse(xhr.responseText);
                                if (data.success) {
                                    var html = '';
                                    if (data.logo && data.logo.length > 0) {
                                        console.log('Logo found:', data.logo);
                                        html += '<img src="../' + data.logo + '" alt="Logo" onerror="console.log(\'Logo load error\');this.style.display=\'none\'" />';
                                    } else {
                                        console.log('No logo, using default icon');
                                        html += '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">';
                                        html += '<path d="M12 2L2 7l10 5 10-5-10-5z"/>';
                                        html += '<path d="M2 17l10 5 10-5"/>';
                                        html += '<path d="M2 12l10 5 10-5"/>';
                                        html += '</svg>';
                                    }
                                    html += (data.siteName || '信息科技学习平台');
                                    logoElement.innerHTML = html;
                                    console.log('Logo updated successfully');
                                } else {
                                    console.log('API returned success=false');
                                }
                            } catch(e) {
                                console.error('Parse error:', e);
                            }
                        } else {
                            console.error('XHR failed with status:', xhr.status);
                        }
                    }
                };
                xhr.onerror = function() {
                    console.error('XHR error occurred');
                };
                xhr.send();
            }
            
            // DOM加载完成后执行
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', loadSiteConfig);
            } else {
                loadSiteConfig();
            }
        })();
    </script>
</body>
</html>
