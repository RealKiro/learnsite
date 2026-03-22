<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_index, LearnSite" %>

<script runat="server">
    // 将自定义登录背景图 URL 注入页面（不存在时返回空字符串，避免 JS 探测 404 噻声）
    protected string GetLoginBgUrl()
    {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg" };
        foreach (string ext in exts)
        {
            string path = Server.MapPath("~/images/loginbg" + ext);
            if (System.IO.File.Exists(path))
                return ResolveUrl("~/images/loginbg" + ext) + "?v=" + System.IO.File.GetLastWriteTime(path).Ticks;
        }
        return "";
    }

    /// <summary>
    /// 带验证码校验的登录入口，校验通过后才调用基类的 Btnlogin_Click
    /// </summary>
    protected void ValidatedLogin_Click(object sender, EventArgs e)
    {
        // 1. 获取用户输入的验证码
        string userCaptcha = TxtCaptcha.Text.Trim();
        
        // 2. 验证码不能为空
        if (string.IsNullOrEmpty(userCaptcha))
        {
            Labelmsg.Text = "请输入验证码";
            RefreshCaptchaSession();
            return;
        }
        
        // 3. 从 Session 读取正确的验证码
        object sessionObj = Session["TeacherCaptcha"];
        if (sessionObj == null)
        {
            Labelmsg.Text = "验证码已过期，请点击图片刷新后重新输入";
            RefreshCaptchaSession();
            return;
        }
        
        string correctCaptcha = sessionObj.ToString();
        
        // 4. 比较（忽略大小写）
        if (!string.Equals(userCaptcha, correctCaptcha, StringComparison.OrdinalIgnoreCase))
        {
            Labelmsg.Text = "验证码错误，请重新输入";
            TxtCaptcha.Text = "";
            RefreshCaptchaSession();
            return;
        }
        
        // 5. 验证通过，清除已用验证码（防止重放）
        Session.Remove("TeacherCaptcha");
        
        // 6. 调用基类原始的 Btnlogin_Click 执行真正的登录逻辑
        try
        {
            System.Type baseType = this.GetType().BaseType;
            System.Reflection.MethodInfo baseMethod = null;
            while (baseType != null && baseMethod == null)
            {
                baseMethod = baseType.GetMethod("Btnlogin_Click",
                    System.Reflection.BindingFlags.Instance |
                    System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Public |
                    System.Reflection.BindingFlags.DeclaredOnly);
                if (baseMethod == null)
                    baseType = baseType.BaseType;
            }
            
            if (baseMethod != null)
            {
                baseMethod.Invoke(this, new object[] { sender, e });
            }
            else
            {
                Labelmsg.Text = "系统错误：无法调用登录处理程序";
            }
        }
        catch (System.Reflection.TargetInvocationException ex)
        {
            // Response.Redirect 会抛出 ThreadAbortException，这是正常的
            if (ex.InnerException is System.Threading.ThreadAbortException)
            {
                throw ex.InnerException;
            }
            throw;
        }
    }
    
    /// <summary>
    /// 清除旧验证码，确保下次必须使用新验证码
    /// </summary>
    private void RefreshCaptchaSession()
    {
        Session.Remove("TeacherCaptcha");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style type="text/css">
    /* ===== 隐藏新母版页布局，全屏登录 ===== */
    .sidebar { display: none !important; }
    .top-header { display: none !important; }
    .layout-wrapper {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        height: 100vh !important;
        width: 100% !important;
        overflow: hidden !important;
    }
    .main-area {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        height: 100% !important;
        width: 100% !important;
        overflow: hidden !important;
        flex-direction: column !important;
    }
    .content-area {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0 !important;
        width: 100% !important;
        height: 100% !important;
        overflow: hidden !important;
    }
    /* 兼容旧母版页 */
    .mainhead, .mainleft, .mainrighttop { display: none !important; }
    .mainrightcontent { margin-left: 0 !important; }
    .mainright { left: 0 !important; position: static !important; }
    .mainarea { position: static !important; width: 100% !important; }

    /* ===== Reset & Base ===== */
    html, body { height: 100%; width: 100%; overflow: hidden !important; margin: 0 !important; padding: 0 !important; }
    body {
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
        background: linear-gradient(135deg, #e0e7ff 0%, #dbeafe 25%, #e8d5f5 50%, #fce7f3 75%, #fef3c7 100%) !important;
        background-image: linear-gradient(135deg, #e0e7ff 0%, #dbeafe 25%, #e8d5f5 50%, #fce7f3 75%, #fef3c7 100%) !important;
        min-height: 100vh;
        position: relative;
    }
    #form1 { width: 100%; height: 100%; margin: 0 !important; padding: 0 !important; }

    /* ===== 动态背景色块 ===== */
    body::before, body::after {
        content: '';
        position: fixed;
        border-radius: 50%;
        filter: blur(80px);
        opacity: 0.4;
        z-index: 0;
        animation: blobFloat 8s ease-in-out infinite alternate;
        pointer-events: none;
    }
    body::before {
        width: 500px; height: 500px;
        background: radial-gradient(circle, #a5b4fc, #818cf8);
        top: -120px; left: -100px;
    }
    body::after {
        width: 400px; height: 400px;
        background: radial-gradient(circle, #f9a8d4, #f472b6);
        bottom: -80px; right: -60px;
        animation-delay: 2s;
    }
    @keyframes blobFloat {
        0%   { transform: translate(0, 0) scale(1); }
        100% { transform: translate(40px, -30px) scale(1.08); }
    }

    /* ===== 毛玻璃卡片 ===== */
    .tlogin-card {
        position: relative;
        z-index: 1;
        display: flex;
        width: 920px;
        max-width: 96vw;
        min-height: 540px;
        background: rgba(255, 255, 255, 0.5);
        backdrop-filter: blur(28px) saturate(1.4);
        -webkit-backdrop-filter: blur(28px) saturate(1.4);
        border-radius: 28px;
        border: 1px solid rgba(255, 255, 255, 0.65);
        box-shadow:
            0 8px 40px rgba(99, 102, 241, 0.14),
            0 2px 10px rgba(0, 0, 0, 0.06),
            inset 0 1px 0 rgba(255,255,255,0.85);
        overflow: hidden;
        margin: 20px auto;
        animation: cardIn 0.6s ease-out;
    }
    @keyframes cardIn {
        from { opacity: 0; transform: translateY(24px) scale(0.97); }
        to { opacity: 1; transform: translateY(0) scale(1); }
    }

    /* ===== 左侧：插画面板 ===== */
    .tlogin-left {
        flex: 1;
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 40px;
        overflow: hidden;
        background: linear-gradient(160deg, rgba(238,242,255,0.4) 0%, rgba(224,231,255,0.2) 100%);
    }
    .tlogin-left .brand {
        position: absolute;
        top: 28px; left: 32px;
        font-size: 17px;
        font-weight: 700;
        color: #1e1b4b;
        letter-spacing: 0.5px;
        z-index: 2;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .tlogin-left .brand span { color: #6366f1; }

    /* 浮动几何装饰 */
    .geo-shape { position: absolute; opacity: 0.6; z-index: 1; }
    .geo-diamond {
        width: 14px; height: 14px;
        background: #f59e0b;
        transform: rotate(45deg);
        top: 22%; left: 8%;
        animation: floatDiamond 5s ease-in-out infinite;
    }
    .geo-diamond2 {
        width: 10px; height: 10px;
        background: #f97316;
        transform: rotate(45deg);
        bottom: 18%; left: 15%;
        animation: floatDiamond 4s ease-in-out infinite reverse;
    }
    .geo-square {
        width: 12px; height: 12px;
        border: 2.5px solid #8b5cf6;
        transform: rotate(15deg);
        top: 14%; right: 18%;
        animation: floatSquare 6s ease-in-out infinite;
    }
    .geo-circle {
        width: 10px; height: 10px;
        background: #06b6d4;
        border-radius: 50%;
        bottom: 28%; right: 12%;
        animation: floatCircle 4.5s ease-in-out infinite;
    }
    .geo-tri {
        width: 0; height: 0;
        border-left: 7px solid transparent;
        border-right: 7px solid transparent;
        border-bottom: 12px solid #10b981;
        top: 35%; right: 6%;
        animation: floatTri 5.5s ease-in-out infinite reverse;
    }
    @keyframes floatDiamond {
        0%, 100% { transform: translateY(0) rotate(45deg); }
        50% { transform: translateY(-12px) rotate(45deg); }
    }
    @keyframes floatSquare {
        0%, 100% { transform: translateY(0) rotate(15deg); }
        50% { transform: translateY(-10px) rotate(25deg); }
    }
    @keyframes floatCircle {
        0%, 100% { transform: translateY(0) scale(1); }
        50% { transform: translateY(-8px) scale(1.2); }
    }
    @keyframes floatTri {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-14px); }
    }

    /* 插画容器 */
    .illustration-wrapper {
        width: 100%; max-width: 360px; z-index: 1;
    }
    .illustration-wrapper svg {
        width: 100%; height: auto;
        filter: drop-shadow(0 4px 12px rgba(99,102,241,0.15));
    }
    .custom-login-img {
        display: none;
        width: 100%; max-width: 400px; z-index: 1;
    }
    .custom-login-img img {
        width: 100%; height: auto; max-height: 400px;
        object-fit: contain;
        filter: drop-shadow(0 4px 16px rgba(99,102,241,0.15));
    }

    /* ===== 右侧：表单面板 ===== */
    .tlogin-right {
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: center;
        padding: 48px 44px;
        position: relative;
    }
    .tlogin-right::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0; bottom: 0;
        background: linear-gradient(160deg, rgba(255,255,255,0.5) 0%, rgba(255,255,255,0.15) 50%, rgba(249,168,212,0.1) 100%);
        pointer-events: none;
    }

    /* 标题区 */
    .tform-header { position: relative; margin-bottom: 36px; z-index: 1; }
    .tform-header .welcome {
        font-size: 14px; color: #64748b; font-weight: 400; margin-bottom: 6px;
    }
    .tform-header .welcome strong { color: #4f46e5; font-weight: 700; }
    .tform-header h1 {
        font-size: 34px; font-weight: 900; color: #1e1b4b;
        line-height: 1.2; letter-spacing: -0.5px;
    }
    .tform-header h1::after {
        content: '';
        display: block;
        width: 40px; height: 4px;
        background: linear-gradient(135deg, #6366f1, #a78bfa);
        border-radius: 2px;
        margin-top: 12px;
    }

    /* 表单字段 */
    .tform-group { position: relative; margin-bottom: 20px; text-align: left; z-index: 1; }
    .tform-group label {
        display: block; font-size: 13px; font-weight: 500;
        color: #1e293b; margin-bottom: 8px; text-align: left;
    }
    .tform-group input[type="text"],
    .tform-group input[type="password"] {
        width: 100% !important;
        height: 48px !important;
        padding: 0 16px !important;
        font-size: 14px !important;
        font-family: 'Microsoft YaHei', Arial, sans-serif !important;
        color: #1e293b !important;
        background: rgba(255, 255, 255, 0.75) !important;
        border: 1.5px solid rgba(203, 213, 225, 0.6) !important;
        border-radius: 12px !important;
        outline: none !important;
        transition: all 0.25s ease !important;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;
        box-sizing: border-box !important;
    }
    .tform-group input[type="text"]:focus,
    .tform-group input[type="password"]:focus {
        border-color: #818cf8 !important;
        box-shadow: 0 0 0 3px rgba(129,140,248,0.15), 0 1px 3px rgba(0,0,0,0.04) !important;
        background: rgba(255, 255, 255, 0.9) !important;
    }
    .tform-group input::placeholder { color: #a0aec0; }

    /* 验证码样式 */
    .captcha-wrapper {
        width: 140px;
        height: 52px;
        border-radius: 14px;
        overflow: hidden;
        cursor: pointer;
        border: none;
        background: none;
        box-shadow: none;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
    }
    
    .captcha-wrapper::before {
        content: '🔄 点击刷新';
        position: absolute;
        top: -38px;
        left: 50%;
        transform: translateX(-50%) scale(0.9);
        font-size: 12px;
        color: #64748b;
        background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
        padding: 6px 14px;
        border-radius: 10px;
        box-shadow: 
            0 4px 16px rgba(99, 102, 241, 0.12),
            0 2px 4px rgba(0, 0, 0, 0.06);
        opacity: 0;
        pointer-events: none;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        white-space: nowrap;
        z-index: 10;
        border: 1px solid rgba(226, 232, 240, 0.8);
        font-weight: 500;
    }
    }
    
    .captcha-wrapper:hover::before {
        opacity: 1;
        top: -40px;
        transform: translateX(-50%) scale(1);
    }
    
    .captcha-wrapper:hover {
        transform: translateY(-3px) scale(1.05);
    }
    
    .captcha-wrapper:active {
        transform: translateY(-1px) scale(1);
    }
    
    .captcha-img {
        max-width: 100%;
        max-height: 100%;
        width: auto;
        height: auto;
        border-radius: 10px;
        transition: all 0.3s ease;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    
    .captcha-wrapper:hover .captcha-img {
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    }
        object-fit: contain;
        transition: transform 0.3s;
    }
    
    .captcha-wrapper:hover .captcha-img {
        transform: scale(1.05);
    }

    /* 错误信息 */
    .tmsg-area { min-height: 24px; margin-bottom: 4px; position: relative; z-index: 1; }
    .tmsg-area span { font-size: 13px; color: #ef4444 !important; font-weight: 500; }

    /* 登录按钮 */
    .tbtn-login {
        width: 100% !important;
        height: 52px !important;
        border: none !important;
        border-radius: 14px !important;
        background: linear-gradient(135deg, #6366f1 0%, #7c3aed 50%, #8b5cf6 100%) !important;
        color: #fff !important;
        font-size: 16px !important;
        font-weight: 600 !important;
        font-family: 'Microsoft YaHei', Arial, sans-serif !important;
        cursor: pointer;
        letter-spacing: 3px;
        transition: all 0.3s cubic-bezier(.4,0,.2,1) !important;
        box-shadow: 0 4px 16px rgba(99, 102, 241, 0.35) !important;
        position: relative;
        z-index: 1;
        overflow: hidden;
    }
    .tbtn-login:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 28px rgba(99, 102, 241, 0.45) !important;
        filter: brightness(1.06);
    }
    .tbtn-login:active { transform: translateY(0) scale(0.99); }

    /* 分割线 */
    .tdivider {
        display: flex; align-items: center;
        margin: 22px 0 18px; position: relative; z-index: 1;
    }
    .tdivider::before, .tdivider::after {
        content: ''; flex: 1; height: 1px;
        background: linear-gradient(90deg, transparent, rgba(148,163,184,0.3), transparent);
    }
    .tdivider span {
        padding: 0 14px; font-size: 12px;
        color: #94a3b8; font-weight: 400;
    }
    /* 快捷链接 */
    .tquick-links {
        display: flex; gap: 10px;
        justify-content: center; position: relative; z-index: 2;
    }
    .tquick-links a,
    .tquick-links a:link,
    .tquick-links a:visited {
        flex: 1;
        display: flex !important;
        align-items: center;
        justify-content: center;
        gap: 6px;
        height: 42px;
        background: rgba(255,255,255,0.6) !important;
        border: 1.5px solid rgba(203,213,225,0.4) !important;
        border-radius: 12px !important;
        font-size: 13px !important;
        font-weight: 500;
        color: #475569 !important;
        text-decoration: none !important;
        transition: all 0.25s ease;
        cursor: pointer;
        width: auto !important;
        line-height: normal !important;
    }
    .tquick-links a:hover {
        background: rgba(255,255,255,0.85) !important;
        border-color: #818cf8 !important;
        color: #6366f1 !important;
        box-shadow: 0 2px 8px rgba(99,102,241,0.1);
    }
    
    /* 忘记密码 */
    .tforgot-password {
        margin-top: 16px;
        text-align: center;
        position: relative;
        z-index: 2;
    }
    .tforgot-password a,
    .tforgot-password a:link,
    .tforgot-password a:visited {
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        gap: 6px;
        padding: 10px 20px;
        background: transparent !important;
        border: none !important;
        border-radius: 10px !important;
        font-size: 13px !important;
        font-weight: 500;
        color: #64748b !important;
        text-decoration: none !important;
        transition: all 0.25s ease;
        cursor: pointer;
        line-height: normal !important;
    }
    .tforgot-password a:hover {
        background: rgba(99, 102, 241, 0.08) !important;
        color: #6366f1 !important;
    }
    .tforgot-password a svg {
        transition: transform 0.25s ease;
    }
    .tforgot-password a:hover svg {
        transform: scale(1.1);
    }
    
    /* 页脚 */
    .tlogin-footer {
        position: relative;
        z-index: 1;
        margin-top: 24px;
        padding-top: 16px;
        border-top: 1px solid rgba(203,213,225,0.2);
        text-align: center;
        font-size: 11px;
        color: #94a3b8;
        line-height: 1.8;
        letter-spacing: 0.3px;
    }
    .tlogin-footer a { color: #6366f1; text-decoration: none; }

    /* 输入框图标 */
    .tform-icon {
        position: absolute;
        right: 14px; top: 50%; transform: translateY(-50%);
        pointer-events: none;
    }
    .tform-icon svg {
        width: 18px; height: 18px;
        stroke: #c7d2fe; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .tform-group:focus-within .tform-icon svg { stroke: #818cf8; }
    .tform-input-wrap { position: relative; }
    .tform-input-wrap input { padding-right: 42px !important; }

    /* ===== 响应式 ===== */
    @media (max-width: 768px) {
        .tlogin-card { flex-direction: column; min-height: auto; width: 94vw; }
        .tlogin-left { display: none; }
        .tlogin-right { padding: 36px 28px; }
        .tform-header h1 { font-size: 28px; }
        .tquick-links { flex-direction: column; }
    }
</style>

<div class="tlogin-card">
    <!-- ========== 左侧：插画区 ========== -->
    <div class="tlogin-left">
        <div class="brand" id="brandTitle"></div>
        <div class="geo-shape geo-diamond"></div>
        <div class="geo-shape geo-diamond2"></div>
        <div class="geo-shape geo-square"></div>
        <div class="geo-shape geo-circle"></div>
        <div class="geo-shape geo-tri"></div>

        <div class="custom-login-img" id="customImg">
            <img id="customImgTag" src="" alt="" />
        </div>
        <div class="illustration-wrapper" id="defaultSvg">
            <svg viewBox="0 0 480 400" fill="none" xmlns="http://www.w3.org/2000/svg">
                <!-- 地面阴影 -->
                <ellipse cx="240" cy="345" rx="195" ry="32" fill="url(#grd1)" opacity="0.2"/>
                <!-- 屏幕光晕 -->
                <path d="M80 130 Q240 70 400 130 L390 260 Q240 210 90 260 Z" fill="url(#screenCurve)" opacity="0.12" />
                <!-- 主显示器 -->
                <rect x="165" y="155" width="150" height="100" rx="8" fill="#1e1b4b" stroke="#6366f1" stroke-width="2"/>
                <rect x="172" y="162" width="136" height="80" rx="4" fill="url(#screenGrd)"/>
                <!-- 代码行 -->
                <rect x="182" y="175" width="50" height="4" rx="2" fill="rgba(255,255,255,0.6)"/>
                <rect x="182" y="185" width="80" height="4" rx="2" fill="rgba(255,255,255,0.3)"/>
                <rect x="182" y="195" width="35" height="4" rx="2" fill="#34d399" opacity="0.8"/>
                <rect x="222" y="195" width="55" height="4" rx="2" fill="rgba(255,255,255,0.25)"/>
                <rect x="182" y="205" width="65" height="4" rx="2" fill="rgba(255,255,255,0.2)"/>
                <rect x="182" y="215" width="40" height="4" rx="2" fill="#818cf8" opacity="0.7"/>
                <rect x="227" y="215" width="50" height="4" rx="2" fill="rgba(255,255,255,0.2)"/>
                <rect x="182" y="225" width="28" height="4" rx="2" fill="#fbbf24" opacity="0.6"/>
                <rect x="215" y="225" width="42" height="4" rx="2" fill="rgba(255,255,255,0.15)"/>
                <!-- 光标闪烁 -->
                <rect x="182" y="234" width="2" height="7" rx="1" fill="#fbbf24" opacity="0.9">
                    <animate attributeName="opacity" values="0.9;0.1;0.9" dur="1s" repeatCount="indefinite"/>
                </rect>
                <!-- 显示器支架 -->
                <rect x="226" y="255" width="28" height="8" rx="2" fill="#a5b4fc"/>
                <rect x="216" y="260" width="48" height="5" rx="2" fill="#c7d2fe"/>
                <!-- 右侧小屏 -->
                <rect x="332" y="175" width="95" height="72" rx="6" fill="#1e1b4b" stroke="#6366f1" stroke-width="1.5"/>
                <rect x="338" y="181" width="83" height="54" rx="3" fill="url(#screenGrd2)"/>
                <!-- 饼图 -->
                <circle cx="362" cy="208" r="14" fill="none" stroke="rgba(255,255,255,0.15)" stroke-width="7"/>
                <circle cx="362" cy="208" r="14" fill="none" stroke="#818cf8" stroke-width="7" stroke-dasharray="22 66" opacity="0.8"/>
                <circle cx="362" cy="208" r="14" fill="none" stroke="#34d399" stroke-width="7" stroke-dasharray="18 70" stroke-dashoffset="-22" opacity="0.7"/>
                <circle cx="362" cy="208" r="14" fill="none" stroke="#fbbf24" stroke-width="7" stroke-dasharray="12 76" stroke-dashoffset="-40" opacity="0.6"/>
                <!-- 柱状图 -->
                <rect x="389" y="218" width="6" height="14" rx="1" fill="#818cf8" opacity="0.7"/>
                <rect x="398" y="212" width="6" height="20" rx="1" fill="#34d399" opacity="0.7"/>
                <rect x="407" y="215" width="6" height="17" rx="1" fill="#fbbf24" opacity="0.6"/>
                <rect x="372" y="247" width="16" height="6" rx="2" fill="#a5b4fc"/>
                <!-- 左侧小屏 -->
                <rect x="58" y="185" width="85" height="65" rx="6" fill="#1e1b4b" stroke="#6366f1" stroke-width="1.5"/>
                <rect x="64" y="191" width="73" height="48" rx="3" fill="url(#screenGrd3)"/>
                <!-- 波形图 -->
                <polyline points="72,220 82,212 92,218 102,205 112,215 122,210 130,214" fill="none" stroke="#34d399" stroke-width="2" opacity="0.8"/>
                <polyline points="72,225 82,220 92,228 102,218 112,222 122,219 130,224" fill="none" stroke="#818cf8" stroke-width="1.5" opacity="0.5"/>
                <rect x="93" y="250" width="14" height="6" rx="2" fill="#a5b4fc"/>
                <!-- 桌面 -->
                <path d="M55 268 L425 268 L435 280 L45 280 Z" fill="#c7d2fe" stroke="#a5b4fc" stroke-width="0.5" opacity="0.7"/>
                <rect x="75" y="280" width="10" height="52" rx="2" fill="#a5b4fc" opacity="0.7"/>
                <rect x="395" y="280" width="10" height="52" rx="2" fill="#a5b4fc" opacity="0.7"/>
                <!-- 键盘 -->
                <rect x="185" y="270" width="110" height="11" rx="4" fill="#e0e7ff" stroke="#c7d2fe" stroke-width="0.8"/>
                <rect x="190" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="197" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="204" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="211" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="218" y="272.5" width="22" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="242" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="249" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="256" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="263" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="270" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <rect x="277" y="272.5" width="5" height="5.5" rx="1" fill="#c7d2fe"/>
                <!-- 鼠标 -->
                <ellipse cx="315" cy="275" rx="9" ry="7" fill="#e0e7ff" stroke="#c7d2fe" stroke-width="0.8"/>
                <!-- 椅子 -->
                <ellipse cx="160" cy="340" rx="26" ry="5" fill="#4338ca" opacity="0.2"/>
                <rect x="140" y="290" width="40" height="36" rx="10" fill="#4338ca"/>
                <rect x="136" y="264" width="48" height="32" rx="10" fill="#4f46e5"/>
                <rect x="155" y="326" width="10" height="16" rx="3" fill="#6366f1"/>
                <circle cx="145" cy="342" r="4" fill="#6366f1" stroke="#4338ca" stroke-width="1"/>
                <circle cx="175" cy="342" r="4" fill="#6366f1" stroke="#4338ca" stroke-width="1"/>
                <!-- 人物 -->
                <circle cx="178" cy="238" r="16" fill="#fcd34d"/>
                <path d="M164 234 Q170 222 182 222 Q194 222 196 234" fill="#1e293b"/>
                <rect x="166" y="253" width="24" height="34" rx="8" fill="#ef4444"/>
                <path d="M166 258 L190 258 L190 262 L186 268 L186 262 L166 262 Z" fill="#dc2626" opacity="0.6"/>
                <path d="M190 263 Q210 272 218 275" stroke="#fcd34d" stroke-width="6" stroke-linecap="round" fill="none"/>
                <path d="M166 266 Q155 280 152 292" stroke="#fcd34d" stroke-width="5" stroke-linecap="round" fill="none"/>
                <path d="M172 287 Q168 300 164 310" stroke="#1e3a5f" stroke-width="6" stroke-linecap="round" fill="none"/>
                <path d="M184 287 Q188 300 190 310" stroke="#1e3a5f" stroke-width="6" stroke-linecap="round" fill="none"/>
                <!-- 咖啡杯 -->
                <rect x="348" y="257" width="14" height="14" rx="3" fill="#fbbf24" opacity="0.7"/>
                <path d="M362 261 Q368 261 368 267 Q368 271 362 271" stroke="#fbbf24" stroke-width="1.5" fill="none" opacity="0.7"/>
                <path d="M352 254 Q354 247 352 240" stroke="#cbd5e1" stroke-width="1.2" fill="none" opacity="0.4">
                    <animate attributeName="d" values="M352 254 Q354 247 352 240;M352 254 Q350 247 352 240;M352 254 Q354 247 352 240" dur="2s" repeatCount="indefinite"/>
                </path>
                <!-- 书堆 -->
                <rect x="410" y="258" width="24" height="5" rx="1" fill="#6366f1" opacity="0.45"/>
                <rect x="412" y="253" width="22" height="5" rx="1" fill="#34d399" opacity="0.45"/>
                <rect x="408" y="248" width="26" height="5" rx="1" fill="#f59e0b" opacity="0.45"/>
                <!-- 植物 -->
                <rect x="40" y="305" width="18" height="22" rx="4" fill="#7c3aed" opacity="0.35"/>
                <path d="M46 305 Q42 292 49 282 Q50 292 56 288 Q54 298 49 305" fill="#34d399" opacity="0.6"/>
                <!-- 浮动徽章 -->
                <g opacity="0.75">
                    <circle cx="390" cy="160" r="9" fill="#34d399"/>
                    <text x="390" y="164" text-anchor="middle" fill="white" font-size="11" font-weight="bold">&#x2713;</text>
                    <animateTransform attributeName="transform" type="translate" values="0,0;0,-5;0,0" dur="3s" repeatCount="indefinite"/>
                </g>
                <g opacity="0.65">
                    <circle cx="95" cy="168" r="7" fill="#f472b6"/>
                    <text x="95" y="172" text-anchor="middle" fill="white" font-size="9" font-weight="bold">&#x2665;</text>
                    <animateTransform attributeName="transform" type="translate" values="0,0;0,-4;0,0" dur="2.5s" repeatCount="indefinite"/>
                </g>
                <g opacity="0.6">
                    <circle cx="440" cy="200" r="6" fill="#fbbf24"/>
                    <text x="440" y="203" text-anchor="middle" fill="white" font-size="8" font-weight="bold">&#x2605;</text>
                    <animateTransform attributeName="transform" type="translate" values="0,0;0,-3;0,0" dur="3.5s" repeatCount="indefinite"/>
                </g>
                <defs>
                    <linearGradient id="grd1" x1="45" y1="345" x2="435" y2="345">
                        <stop offset="0%" stop-color="#c7d2fe"/>
                        <stop offset="100%" stop-color="#ddd6fe"/>
                    </linearGradient>
                    <linearGradient id="screenGrd" x1="172" y1="162" x2="308" y2="242">
                        <stop offset="0%" stop-color="#312e81"/>
                        <stop offset="100%" stop-color="#1e1b4b"/>
                    </linearGradient>
                    <linearGradient id="screenGrd2" x1="338" y1="181" x2="421" y2="235">
                        <stop offset="0%" stop-color="#312e81"/>
                        <stop offset="100%" stop-color="#1e1b4b"/>
                    </linearGradient>
                    <linearGradient id="screenGrd3" x1="64" y1="191" x2="137" y2="239">
                        <stop offset="0%" stop-color="#312e81"/>
                        <stop offset="100%" stop-color="#1e1b4b"/>
                    </linearGradient>
                    <linearGradient id="screenCurve" x1="80" y1="130" x2="400" y2="260">
                        <stop offset="0%" stop-color="#06b6d4"/>
                        <stop offset="100%" stop-color="#8b5cf6"/>
                    </linearGradient>
                </defs>
            </svg>
        </div>
    </div>

    <!-- ========== 右侧：登录表单 ========== -->
    <div class="tlogin-right">
        <div class="tform-header">
            <p class="welcome">欢迎来到 <strong id="welcomeTitle"></strong></p>
            <h1 id="loginTitle">教师登录</h1>
        </div>

        <div class="tform-group">
            <label id="labelAccount">教师账号</label>
            <div class="tform-input-wrap">
                <asp:TextBox ID="Textname" runat="server" SkinID="TextBoxNormal" />
                <span class="tform-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            </div>
        </div>

        <div class="tform-group">
            <label>登录密码</label>
            <div class="tform-input-wrap">
                <asp:TextBox ID="Textpwd" runat="server" TextMode="Password" SkinID="TextBoxNormal" />
                <span class="tform-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
            </div>
        </div>

        <div class="tform-group">
            <label>验证码</label>
            <div style="display: flex; gap: 12px; align-items: center;">
                <div style="flex: 1;">
                    <asp:TextBox ID="TxtCaptcha" runat="server" SkinID="TextBoxNormal" MaxLength="4" placeholder="请输入验证码" />
                </div>
                <div class="captcha-wrapper" onclick="refreshCaptcha()" title="点击刷新验证码">
                    <img id="captchaImage" src="captcha.ashx?type=login" alt="验证码" class="captcha-img" />
                </div>
            </div>
        </div>

        <div class="tmsg-area">
            <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
        </div>

        <asp:Button ID="Btnlogin" runat="server" Text="登 录" SkinID="BtnNormal" onclick="ValidatedLogin_Click" CssClass="tbtn-login" />

        <div class="tdivider"><span>更多入口</span></div>

        <div class="tquick-links">
            <a href="../index.aspx" target="_self" onclick="window.location.href='../index.aspx';return true;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 1.66 2.69 3 6 3s6-1.34 6-3v-5"/></svg> 学生平台</a>
            <a href="../manager/login.aspx" target="_self"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg> 管理后台</a>
            <a href="resetpassword.aspx" target="_self"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg> 找回密码</a>
        </div>

        <div class="tlogin-footer" id="loginFooter">
            LearnSite &middot; 信息科技教师平台<br />
            <span id="loginClock" style="font-size:10px;color:#b4bcd0;"></span>
        </div>
    </div>
</div>

<script type="text/javascript">
    function CookieEnable() {
        var result = false;
        if (navigator.cookiesEnabled)
            return true;
        document.cookie = "testcookie=yes;";
        var cookieSet = document.cookie;
        if (cookieSet.indexOf("testcookie=yes") > -1)
            result = true;
        document.cookie = "";
        return result;
    }
    if (!CookieEnable()) {
        alert("对不起，您的浏览器的Cookie功能被禁用，请开启\n\n 开启方法：IE---工具---Internet选项---隐私---中");
    }
    
    // 刷新验证码
    function refreshCaptcha() {
        var img = document.getElementById('captchaImage');
        if (img) {
            // 添加加载动画
            img.style.opacity = '0.5';
            img.src = 'captcha.ashx?type=login&t=' + new Date().getTime();
            img.onload = function() {
                img.style.opacity = '1';
            };
        }
    }
    
        // 读取页面标题 & 检测自定义插画
        document.addEventListener('DOMContentLoaded', function () {
            var siteTitle = document.title.replace(/[\s\-\>]+$/g, '').trim() || 'LearnSite';
            var brandEl = document.getElementById('brandTitle');
            var welcomeEl = document.getElementById('welcomeTitle');
            if (brandEl) brandEl.textContent = siteTitle;
            if (welcomeEl) welcomeEl.textContent = siteTitle;

            // 自定义登录背景图 URL 由服务端直接提供，不再岝试全格式探测以避免 404 控制台噻声
            var loginBgUrl = '<%= GetLoginBgUrl() %>';
            if (loginBgUrl) {
                document.getElementById('customImgTag').src = loginBgUrl;
                document.getElementById('customImg').style.display = 'block';
                document.getElementById('defaultSvg').style.display = 'none';
            }

            var inputs = document.querySelectorAll('.tform-group input');
        inputs.forEach(function (input) {
            input.addEventListener('focus', function () {
                this.parentElement.style.transform = 'translateX(2px)';
                this.parentElement.style.transition = 'transform 0.2s ease';
            });
            input.addEventListener('blur', function () {
                this.parentElement.style.transform = 'translateX(0)';
            });
        });
        var first = document.querySelector('.tform-group input[type="text"]');
        if (first) first.focus();
    });
</script>
</asp:Content>

