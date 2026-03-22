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

    protected string GetSiteLogoUrl()
    {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
        foreach (string ext in exts)
        {
            string path = Server.MapPath("~/images/site-logo" + ext);
            if (System.IO.File.Exists(path))
                return ResolveUrl("~/images/site-logo" + ext) + "?v=" + System.IO.File.GetLastWriteTime(path).Ticks;
        }
        return "";
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

    // 验证码相关
    protected int captchaA, captchaB;
    protected string captchaOp;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            GenerateCaptcha();
        }
        else
        {
            string eventArg = Request["__EVENTARGUMENT"];
            if (eventArg == "refreshCaptcha")
            {
                GenerateCaptcha();
            }
            else
            {
                // PostBack 时从 Session 读取当前验证码显示值（用于前端重绘）
                captchaA = Session["captchaA"] != null ? (int)Session["captchaA"] : 0;
                captchaB = Session["captchaB"] != null ? (int)Session["captchaB"] : 0;
                captchaOp = Session["captchaOp"] != null ? Session["captchaOp"].ToString() : "+";
            }
        }
    }

    private void GenerateCaptcha()
    {
        Random rnd = new Random();
        captchaA = rnd.Next(1, 20);
        captchaB = rnd.Next(1, 20);
        // 随机选择加法或乘法
        int opType = rnd.Next(0, 3);
        int answer = 0;
        if (opType == 0) { captchaOp = "+"; answer = captchaA + captchaB; }
        else if (opType == 1)
        {
            captchaOp = "-";
            // 确保结果为正
            if (captchaA < captchaB) { int tmp = captchaA; captchaA = captchaB; captchaB = tmp; }
            answer = captchaA - captchaB;
        }
        else { captchaOp = "\u00d7"; captchaA = rnd.Next(1, 10); captchaB = rnd.Next(1, 10); answer = captchaA * captchaB; }

        Session["captchaAnswer"] = answer;
        Session["captchaA"] = captchaA;
        Session["captchaB"] = captchaB;
        Session["captchaOp"] = captchaOp;
    }

    protected void Btnlogin_Click(object sender, EventArgs e)
    {
        string username = Textname.Text.Trim();
        string password = Textpwd.Text.Trim();
        string captchaInput = Textcaptcha.Text.Trim();

        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            Labelmsg.Text = "<span>&#9888; 请输入账号和密码</span>";
            GenerateCaptcha();
            return;
        }

        // 验证码校验
        int inputNum = -1;
        try { inputNum = int.Parse(captchaInput); } catch { }
        int correctAnswer = Session["captchaAnswer"] != null ? (int)Session["captchaAnswer"] : -999;
        if (inputNum != correctAnswer)
        {
            Labelmsg.Text = "<span>&#9888; 验证码错误，请重新计算</span>";
            GenerateCaptcha();
            return;
        }

        try
        {
            LearnSite.BLL.Teacher bll = new LearnSite.BLL.Teacher();
            LearnSite.Model.Teacher model = bll.GetTeacherModel(username, password);
            if (model != null)
            {
                if (model.Hpermiss)
                {
                    LearnSite.Common.CookieHelp.SetTMCookies(model, true);
                    Response.Redirect("dashboard.aspx", false);
                }
                else
                {
                    Labelmsg.Text = "<span>&#9888; 该账号没有管理员权限</span>";
                }
            }
            else
            {
                Labelmsg.Text = "<span>&#9888; 账号或密码错误，请重新输入</span>";
            }
        }
        catch
        {
            Labelmsg.Text = "<span>&#9888; 登录失败，请检查数据库连接</span>";
        }
        GenerateCaptcha();
    }
</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%= GetSiteTitle() %> - 管理后台登录</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <%= GetFaviconLinkTag() %>
    <style>
        /* ===== Reset & Base ===== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; width: 100%; }
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
            background: #f8fafc !important;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            overflow: hidden;
            position: relative;
        }

        /* ===== 柔和背景光晕 ===== */
        body::before, body::after {
            content: '';
            position: fixed;
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.35;
            z-index: 0;
            animation: blobFloat 10s ease-in-out infinite alternate;
        }
        body::before {
            width: 500px; height: 500px;
            background: radial-gradient(circle, #c7d2fe, #a5b4fc);
            top: -180px; left: -120px;
        }
        body::after {
            width: 400px; height: 400px;
            background: radial-gradient(circle, #e9d5ff, #ddd6fe);
            bottom: -120px; right: -80px;
            animation-delay: 3s;
        }
        @keyframes blobFloat {
            0%   { transform: translate(0, 0) scale(1); }
            100% { transform: translate(40px, -30px) scale(1.08); }
        }

        /* 网格背景 */
        .grid-bg {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background-image:
                linear-gradient(rgba(99,102,241,0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(99,102,241,0.03) 1px, transparent 1px);
            background-size: 48px 48px;
            z-index: 0;
            pointer-events: none;
        }

        /* ===== 卡片 ===== */
        .admin-card {
            position: relative;
            z-index: 1;
            display: flex;
            width: 940px;
            max-width: 96vw;
            min-height: 560px;
            background: #fff;
            border-radius: 24px;
            border: 1px solid #e2e8f0;
            box-shadow:
                0 4px 32px rgba(99, 102, 241, 0.08),
                0 1px 4px rgba(0, 0, 0, 0.04);
            overflow: hidden;
            animation: cardIn 0.6s ease-out;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(24px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* ===== 左侧：插画面板 ===== */
        .admin-left {
            flex: 1;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            overflow: hidden;
            background: linear-gradient(160deg, #eef2ff 0%, #e0e7ff 50%, #ede9fe 100%);
            border-right: 1px solid #e2e8f0;
        }
        .admin-left .brand {
            position: absolute;
            top: 28px; left: 32px;
            font-size: 16px;
            font-weight: 700;
            color: #1e1b4b;
            letter-spacing: 0.5px;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .brand-logo {
            height: 32px;
            max-width: 140px;
            object-fit: contain;
            border-radius: 4px;
        }

        /* 浮动几何装饰 */
        .geo-shape { position: absolute; opacity: 0.55; z-index: 1; }
        .geo-diamond {
            width: 14px; height: 14px;
            background: #818cf8;
            transform: rotate(45deg);
            top: 20%; left: 10%;
            animation: floatDiamond 5s ease-in-out infinite;
        }
        .geo-diamond2 {
            width: 10px; height: 10px;
            background: #a78bfa;
            transform: rotate(45deg);
            bottom: 22%; left: 12%;
            animation: floatDiamond 4s ease-in-out infinite reverse;
        }
        .geo-square {
            width: 12px; height: 12px;
            border: 2.5px solid #818cf8;
            transform: rotate(15deg);
            top: 15%; right: 15%;
            animation: floatSquare 6s ease-in-out infinite;
        }
        .geo-circle {
            width: 10px; height: 10px;
            background: #34d399;
            border-radius: 50%;
            bottom: 25%; right: 10%;
            animation: floatCircle 4.5s ease-in-out infinite;
        }
        .geo-tri {
            width: 0; height: 0;
            border-left: 7px solid transparent;
            border-right: 7px solid transparent;
            border-bottom: 12px solid #fbbf24;
            top: 38%; right: 8%;
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

        /* 插画 */
        .illustration-wrapper {
            width: 100%; max-width: 340px; z-index: 1;
        }
        .illustration-wrapper svg {
            width: 100%; height: auto;
            filter: drop-shadow(0 4px 16px rgba(99,102,241,0.12));
        }

        /* 左侧底部标语 */
        .admin-left-footer {
            position: absolute;
            bottom: 28px; left: 32px; right: 32px;
            z-index: 2;
        }
        .admin-left-footer h3 {
            font-size: 16px;
            font-weight: 700;
            color: #1e1b4b;
            margin-bottom: 6px;
        }
        .admin-left-footer p {
            font-size: 12px;
            color: #94a3b8;
            line-height: 1.6;
        }

        /* ===== 右侧：表单面板 ===== */
        .admin-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 48px 44px;
            position: relative;
            background: #fff;
        }
        .admin-right::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(160deg, rgba(255,255,255,0.6) 0%, rgba(238,242,255,0.15) 100%);
            pointer-events: none;
        }

        /* 标题区 */
        .aform-header { position: relative; margin-bottom: 32px; z-index: 1; }
        .aform-header .admin-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            height: 28px;
            padding: 0 12px;
            background: linear-gradient(135deg, #eef2ff, #ede9fe);
            border: 1px solid #c7d2fe;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            color: #6366f1;
            margin-bottom: 16px;
            letter-spacing: 0.5px;
        }
        .aform-header .admin-badge svg {
            width: 14px; height: 14px;
            stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .aform-header h1 {
            font-size: 32px; font-weight: 900; color: #0f172a;
            line-height: 1.2; letter-spacing: -0.5px;
        }
        .aform-header h1::after {
            content: '';
            display: block;
            width: 40px; height: 4px;
            background: linear-gradient(135deg, #6366f1, #a78bfa);
            border-radius: 2px;
            margin-top: 12px;
        }
        .aform-header .subtitle {
            font-size: 13px; color: #94a3b8;
            margin-top: 10px;
        }

        /* 表单字段 */
        .aform-group { position: relative; margin-bottom: 20px; z-index: 1; }
        .aform-group label {
            display: block; font-size: 13px; font-weight: 500;
            color: #1e293b; margin-bottom: 8px;
        }
        .aform-input-wrap { position: relative; }
        .aform-input-wrap input { padding-right: 42px !important; }
        .aform-group input[type="text"],
        .aform-group input[type="password"] {
            width: 100% !important;
            height: 48px !important;
            padding: 0 16px !important;
            font-size: 14px !important;
            font-family: 'Microsoft YaHei', Arial, sans-serif !important;
            color: #1e293b !important;
            background: #f8fafc !important;
            border: 1.5px solid #e2e8f0 !important;
            border-radius: 12px !important;
            outline: none !important;
            transition: all 0.25s ease !important;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04) !important;
            box-sizing: border-box !important;
        }
        .aform-group input[type="text"]:focus,
        .aform-group input[type="password"]:focus {
            border-color: #818cf8 !important;
            box-shadow: 0 0 0 3px rgba(129,140,248,0.12), 0 1px 2px rgba(0,0,0,0.04) !important;
            background: #fff !important;
        }
        .aform-group input::placeholder { color: #a0aec0 !important; }
        .aform-icon {
            position: absolute;
            right: 14px; top: 50%; transform: translateY(-50%);
            pointer-events: none;
        }
        .aform-icon svg {
            width: 18px; height: 18px;
            stroke: #cbd5e1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .aform-group:focus-within .aform-icon svg { stroke: #818cf8; }

        /* 验证码 */
        .captcha-row {
            display: flex; align-items: center; gap: 12px;
            position: relative; z-index: 1; margin-bottom: 20px;
        }
        .captcha-row label {
            display: block; font-size: 13px; font-weight: 500;
            color: #1e293b; margin-bottom: 8px;
        }
        .captcha-input-col { flex: 1; }
        .captcha-input-col input {
            width: 100% !important;
            height: 48px !important;
            padding: 0 16px !important;
            font-size: 16px !important;
            font-weight: 600 !important;
            font-family: 'Microsoft YaHei', Arial, sans-serif !important;
            color: #1e293b !important;
            background: #f8fafc !important;
            border: 1.5px solid #e2e8f0 !important;
            border-radius: 12px !important;
            outline: none !important;
            transition: all 0.25s ease !important;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04) !important;
            box-sizing: border-box !important;
            letter-spacing: 4px;
        }
        .captcha-input-col input:focus {
            border-color: #818cf8 !important;
            box-shadow: 0 0 0 3px rgba(129,140,248,0.12), 0 1px 2px rgba(0,0,0,0.04) !important;
            background: #fff !important;
        }
        .captcha-input-col input::placeholder { color: #a0aec0 !important; letter-spacing: 0; font-weight: 400; font-size: 14px !important; }
        .captcha-canvas-wrap {
            flex-shrink: 0;
            cursor: pointer;
            border-radius: 12px;
            overflow: hidden;
            border: 1.5px solid #e2e8f0;
            transition: all 0.2s;
            display: flex;
            align-items: flex-end;
        }
        .captcha-canvas-wrap:hover {
            border-color: #818cf8;
            box-shadow: 0 2px 8px rgba(99,102,241,0.1);
        }
        .captcha-canvas-wrap canvas {
            display: block;
        }
        .captcha-refresh {
            font-size: 11px; color: #94a3b8; text-align: center;
            margin-top: 4px; cursor: pointer;
        }
        .captcha-refresh:hover { color: #6366f1; }

        /* 错误信息 */
        .amsg-area {
            min-height: 28px; margin-bottom: 4px;
            position: relative; z-index: 1;
        }
        .amsg-area span {
            font-size: 13px; color: #ef4444 !important; font-weight: 500;
            display: inline-flex; align-items: center; gap: 6px;
        }

        /* 登录按钮 */
        .abtn-login {
            width: 100% !important;
            height: 50px !important;
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
            box-shadow: 0 4px 16px rgba(99, 102, 241, 0.3) !important;
            position: relative;
            z-index: 1;
            overflow: hidden;
        }
        .abtn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(99, 102, 241, 0.4) !important;
            filter: brightness(1.06);
        }
        .abtn-login:active { transform: translateY(0) scale(0.99); }

        /* 分割线 */
        .adivider {
            display: flex; align-items: center;
            margin: 24px 0 18px; position: relative; z-index: 1;
        }
        .adivider::before, .adivider::after {
            content: ''; flex: 1; height: 1px;
            background: linear-gradient(90deg, transparent, #e2e8f0, transparent);
        }
        .adivider span {
            padding: 0 14px; font-size: 12px;
            color: #94a3b8; font-weight: 400;
        }

        /* 快捷链接 */
        .aquick-links {
            display: flex; gap: 10px;
            justify-content: center; position: relative; z-index: 2;
        }
        .aquick-links a,
        .aquick-links a:link,
        .aquick-links a:visited {
            flex: 1;
            display: flex !important;
            align-items: center;
            justify-content: center;
            gap: 6px;
            height: 42px;
            background: #f8fafc !important;
            border: 1.5px solid #e2e8f0 !important;
            border-radius: 12px !important;
            font-size: 13px !important;
            font-weight: 500;
            color: #64748b !important;
            text-decoration: none !important;
            transition: all 0.25s ease;
            cursor: pointer;
        }
        .aquick-links a:hover {
            background: #eef2ff !important;
            border-color: #818cf8 !important;
            color: #6366f1 !important;
            box-shadow: 0 2px 8px rgba(99,102,241,0.1);
        }

        /* 页脚 */
        .alogin-footer {
            position: relative;
            z-index: 1;
            margin-top: 24px;
            padding-top: 16px;
            border-top: 1px solid #f1f5f9;
            text-align: center;
            font-size: 11px;
            color: #94a3b8;
            line-height: 1.8;
        }

        /* ===== 响应式 ===== */
        @media (max-width: 768px) {
            .admin-card { flex-direction: column; min-height: auto; width: 94vw; }
            .admin-left { display: none; }
            .admin-right { padding: 36px 28px; }
            .aform-header h1 { font-size: 26px; }
            .aquick-links { flex-direction: column; }
        }
    </style>
</head>
<body>
    <div class="grid-bg"></div>
    <form id="form1" runat="server">
    <div class="admin-card">
        <!-- ========== 左侧：插画区 ========== -->
        <div class="admin-left">
            <div class="brand">
                <% string logoUrl = GetSiteLogoUrl(); %>
                <% if (!string.IsNullOrEmpty(logoUrl)) { %>
                    <img src="<%= logoUrl %>" alt="Logo" class="brand-logo" />
                <% } %>
                <span><%= GetSiteTitle() %></span>
            </div>
            <div class="geo-shape geo-diamond"></div>
            <div class="geo-shape geo-diamond2"></div>
            <div class="geo-shape geo-square"></div>
            <div class="geo-shape geo-circle"></div>
            <div class="geo-shape geo-tri"></div>

            <div class="illustration-wrapper">
                <svg viewBox="0 0 400 380" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <!-- 底部阴影 -->
                    <ellipse cx="200" cy="340" rx="160" ry="24" fill="url(#grdShadow)" opacity="0.15"/>

                    <!-- 服务器机架 -->
                    <rect x="130" y="120" width="140" height="200" rx="12" fill="#f1f5f9" stroke="#c7d2fe" stroke-width="1.5"/>
                    <rect x="130" y="120" width="140" height="200" rx="12" fill="url(#grdServer)" opacity="0.5"/>

                    <!-- 服务器单元 1 -->
                    <rect x="144" y="136" width="112" height="36" rx="6" fill="#fff" stroke="#e0e7ff" stroke-width="1"/>
                    <circle cx="160" cy="154" r="4" fill="#34d399" opacity="0.9">
                        <animate attributeName="opacity" values="0.9;0.4;0.9" dur="2s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="174" cy="154" r="4" fill="#34d399" opacity="0.7">
                        <animate attributeName="opacity" values="0.7;0.3;0.7" dur="2.5s" repeatCount="indefinite"/>
                    </circle>
                    <rect x="196" y="148" width="48" height="3" rx="1.5" fill="#a5b4fc" opacity="0.6"/>
                    <rect x="196" y="155" width="32" height="3" rx="1.5" fill="#c7d2fe" opacity="0.5"/>

                    <!-- 服务器单元 2 -->
                    <rect x="144" y="182" width="112" height="36" rx="6" fill="#fff" stroke="#e0e7ff" stroke-width="1"/>
                    <circle cx="160" cy="200" r="4" fill="#fbbf24" opacity="0.8">
                        <animate attributeName="opacity" values="0.8;0.3;0.8" dur="3s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="174" cy="200" r="4" fill="#34d399" opacity="0.7"/>
                    <rect x="196" y="194" width="48" height="3" rx="1.5" fill="#a5b4fc" opacity="0.6"/>
                    <rect x="196" y="201" width="40" height="3" rx="1.5" fill="#c7d2fe" opacity="0.5"/>

                    <!-- 服务器单元 3 -->
                    <rect x="144" y="228" width="112" height="36" rx="6" fill="#fff" stroke="#e0e7ff" stroke-width="1"/>
                    <circle cx="160" cy="246" r="4" fill="#34d399" opacity="0.9"/>
                    <circle cx="174" cy="246" r="4" fill="#34d399" opacity="0.6">
                        <animate attributeName="opacity" values="0.6;0.2;0.6" dur="1.8s" repeatCount="indefinite"/>
                    </circle>
                    <rect x="196" y="240" width="44" height="3" rx="1.5" fill="#a5b4fc" opacity="0.6"/>
                    <rect x="196" y="247" width="36" height="3" rx="1.5" fill="#c7d2fe" opacity="0.5"/>

                    <!-- 服务器底板 -->
                    <rect x="144" y="274" width="112" height="36" rx="6" fill="#fff" stroke="#e0e7ff" stroke-width="1"/>
                    <circle cx="160" cy="292" r="4" fill="#34d399" opacity="0.5"/>
                    <circle cx="174" cy="292" r="4" fill="#cbd5e1" opacity="0.4"/>
                    <rect x="196" y="286" width="48" height="3" rx="1.5" fill="#c7d2fe" opacity="0.4"/>
                    <rect x="196" y="293" width="28" height="3" rx="1.5" fill="#c7d2fe" opacity="0.3"/>

                    <!-- 盾牌 -->
                    <g transform="translate(200, 68)">
                        <path d="M0 -38 L-32 -22 L-32 8 C-32 28 0 48 0 48 C0 48 32 28 32 8 L32 -22 Z"
                              fill="url(#grdShield)" stroke="#818cf8" stroke-width="1.5" opacity="0.9"/>
                        <path d="M0 -28 L-22 -16 L-22 4 C-22 18 0 34 0 34 C0 34 22 18 22 4 L22 -16 Z"
                              fill="#eef2ff" opacity="0.7"/>
                        <!-- 锁图标 -->
                        <rect x="-8" y="-4" width="16" height="13" rx="3" fill="none" stroke="#6366f1" stroke-width="2"/>
                        <path d="M-4 -4 L-4 -10 C-4 -16 4 -16 4 -10 L4 -4" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round"/>
                        <circle cx="0" cy="4" r="2" fill="#6366f1"/>
                        <animateTransform attributeName="transform" type="translate" values="200,68;200,64;200,68" dur="4s" repeatCount="indefinite"/>
                    </g>

                    <!-- 连接线 - 左 -->
                    <path d="M130 180 L80 160 L60 160" stroke="#a5b4fc" stroke-width="1" stroke-dasharray="4 3" opacity="0.5"/>
                    <circle cx="56" cy="160" r="6" fill="#eef2ff" stroke="#818cf8" stroke-width="1" opacity="0.7"/>
                    <circle cx="56" cy="160" r="2.5" fill="#6366f1" opacity="0.6">
                        <animate attributeName="opacity" values="0.6;0.2;0.6" dur="2s" repeatCount="indefinite"/>
                    </circle>

                    <!-- 连接线 - 右 -->
                    <path d="M270 200 L320 185 L340 185" stroke="#a5b4fc" stroke-width="1" stroke-dasharray="4 3" opacity="0.5"/>
                    <circle cx="344" cy="185" r="6" fill="#eef2ff" stroke="#818cf8" stroke-width="1" opacity="0.7"/>
                    <circle cx="344" cy="185" r="2.5" fill="#6366f1" opacity="0.6">
                        <animate attributeName="opacity" values="0.6;0.2;0.6" dur="2.5s" repeatCount="indefinite"/>
                    </circle>

                    <!-- 连接线 - 左下 -->
                    <path d="M130 260 L70 280 L50 280" stroke="#a5b4fc" stroke-width="1" stroke-dasharray="4 3" opacity="0.4"/>
                    <circle cx="46" cy="280" r="6" fill="#ecfdf5" stroke="#34d399" stroke-width="1" opacity="0.7"/>
                    <circle cx="46" cy="280" r="2.5" fill="#34d399" opacity="0.5">
                        <animate attributeName="opacity" values="0.5;0.1;0.5" dur="3s" repeatCount="indefinite"/>
                    </circle>

                    <!-- 连接线 - 右下 -->
                    <path d="M270 250 L330 270 L350 270" stroke="#a5b4fc" stroke-width="1" stroke-dasharray="4 3" opacity="0.4"/>
                    <circle cx="354" cy="270" r="6" fill="#fef3c7" stroke="#fbbf24" stroke-width="1" opacity="0.7"/>
                    <circle cx="354" cy="270" r="2.5" fill="#f59e0b" opacity="0.5">
                        <animate attributeName="opacity" values="0.5;0.1;0.5" dur="2.2s" repeatCount="indefinite"/>
                    </circle>

                    <!-- 浮动粒子 -->
                    <circle cx="90" cy="130" r="3" fill="#818cf8" opacity="0.35">
                        <animateTransform attributeName="transform" type="translate" values="0,0;0,-8;0,0" dur="3s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="310" cy="140" r="2.5" fill="#a78bfa" opacity="0.35">
                        <animateTransform attributeName="transform" type="translate" values="0,0;0,-6;0,0" dur="3.5s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="75" cy="220" r="2" fill="#34d399" opacity="0.3">
                        <animateTransform attributeName="transform" type="translate" values="0,0;0,-5;0,0" dur="4s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="330" cy="230" r="2" fill="#fbbf24" opacity="0.3">
                        <animateTransform attributeName="transform" type="translate" values="0,0;0,-6;0,0" dur="2.8s" repeatCount="indefinite"/>
                    </circle>

                    <defs>
                        <linearGradient id="grdShadow" x1="40" y1="340" x2="360" y2="340">
                            <stop offset="0%" stop-color="#a5b4fc" stop-opacity="0"/>
                            <stop offset="50%" stop-color="#a5b4fc"/>
                            <stop offset="100%" stop-color="#a5b4fc" stop-opacity="0"/>
                        </linearGradient>
                        <linearGradient id="grdServer" x1="130" y1="120" x2="270" y2="320">
                            <stop offset="0%" stop-color="#e0e7ff" stop-opacity="0.5"/>
                            <stop offset="100%" stop-color="#f1f5f9" stop-opacity="0"/>
                        </linearGradient>
                        <linearGradient id="grdShield" x1="-32" y1="-38" x2="32" y2="48">
                            <stop offset="0%" stop-color="#818cf8"/>
                            <stop offset="100%" stop-color="#6366f1"/>
                        </linearGradient>
                    </defs>
                </svg>
            </div>

            <div class="admin-left-footer">
                <h3>系统管理中心</h3>
                <p>管理班级、教师、学生及系统配置</p>
            </div>
        </div>

        <!-- ========== 右侧：登录表单 ========== -->
        <div class="admin-right">
            <div class="aform-header">
                <div class="admin-badge">
                    <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    ADMINISTRATOR
                </div>
                <h1>管理后台登录</h1>
                <p class="subtitle">请使用管理员账号登录系统管理中心</p>
            </div>

            <div class="aform-group">
                <label>管理员账号</label>
                <div class="aform-input-wrap">
                    <asp:TextBox ID="Textname" runat="server" placeholder="请输入管理员账号" />
                    <span class="aform-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
                </div>
            </div>

            <div class="aform-group">
                <label>登录密码</label>
                <div class="aform-input-wrap">
                    <asp:TextBox ID="Textpwd" runat="server" TextMode="Password" placeholder="请输入密码" />
                    <span class="aform-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                </div>
            </div>

            <div class="captcha-row">
                <div class="captcha-input-col">
                    <label>验证码</label>
                    <asp:TextBox ID="Textcaptcha" runat="server" placeholder="计算结果" MaxLength="4" autocomplete="off" />
                </div>
                <div style="padding-top:22px;">
                    <div class="captcha-canvas-wrap" onclick="refreshCaptcha()" title="点击刷新验证码">
                        <canvas id="captchaCanvas" width="140" height="48"></canvas>
                    </div>
                    <div class="captcha-refresh" onclick="refreshCaptcha()">点击刷新</div>
                </div>
            </div>

            <div class="amsg-area">
                <asp:Label ID="Labelmsg" runat="server"></asp:Label>
            </div>

            <asp:Button ID="Btnlogin" runat="server" Text="登 录" onclick="Btnlogin_Click" CssClass="abtn-login" />

            <div class="adivider"><span>更多入口</span></div>

            <div class="aquick-links">
                <a href="../index.aspx" target="_self">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 1.66 2.69 3 6 3s6-1.34 6-3v-5"/></svg>
                    学生平台
                </a>
                <a href="../teacher/index.aspx" target="_self">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    教师平台
                </a>
                <a href="forgotpwd.aspx">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>
                    忘记密码
                </a>
            </div>

            <div class="alogin-footer">
                LearnSite &middot; 系统管理中心<br />
                <span id="loginClock" style="font-size:10px;"></span>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // Cookie 检测
        function CookieEnable() {
            var result = false;
            if (navigator.cookiesEnabled) return true;
            document.cookie = "testcookie=yes;";
            var cookieSet = document.cookie;
            if (cookieSet.indexOf("testcookie=yes") > -1) result = true;
            document.cookie = "";
            return result;
        }
        if (!CookieEnable()) {
            alert("对不起，您的浏览器的Cookie功能被禁用，请开启\n\n 开启方法：IE---工具---Internet选项---隐私---中");
        }

        // 时钟
        function updateClock() {
            var now = new Date();
            var h = now.getHours().toString().padStart(2, '0');
            var m = now.getMinutes().toString().padStart(2, '0');
            var d = (now.getMonth() + 1) + '月' + now.getDate() + '日';
            var el = document.getElementById('loginClock');
            if (el) el.textContent = d + ' ' + h + ':' + m;
        }
        updateClock();
        setInterval(updateClock, 30000);

        // 表单交互
        document.addEventListener('DOMContentLoaded', function () {
            var inputs = document.querySelectorAll('.aform-group input');
            inputs.forEach(function (input) {
                input.addEventListener('focus', function () {
                    this.closest('.aform-group').style.transform = 'translateX(2px)';
                    this.closest('.aform-group').style.transition = 'transform 0.2s ease';
                });
                input.addEventListener('blur', function () {
                    this.closest('.aform-group').style.transform = 'translateX(0)';
                });
            });
            // 自动聚焦
            var first = document.querySelector('.aform-group input[type="text"]');
            if (first) first.focus();
        });

        // 防重复提交
        function doubleCheck() {
            if (window.document.readyState != null && window.document.readyState != 'complete') {
                alert("正在处理，请等待！");
                return false;
            }
            return true;
        }

        // 验证码绘制
        var captchaA = <%= captchaA %>;
        var captchaB = <%= captchaB %>;
        var captchaOp = '<%= captchaOp %>';

        function drawCaptcha() {
            var canvas = document.getElementById('captchaCanvas');
            if (!canvas) return;
            var ctx = canvas.getContext('2d');
            var w = canvas.width, h = canvas.height;

            // 背景
            ctx.fillStyle = '#f1f5f9';
            ctx.fillRect(0, 0, w, h);

            // 随机圆点装饰
            for (var i = 0; i < 30; i++) {
                ctx.beginPath();
                ctx.arc(Math.random() * w, Math.random() * h, Math.random() * 3 + 1, 0, Math.PI * 2);
                var colors = ['#c7d2fe','#ddd6fe','#a5b4fc','#e0e7ff','#bfdbfe'];
                ctx.fillStyle = colors[Math.floor(Math.random() * colors.length)];
                ctx.fill();
            }

            // 干扰线
            for (var j = 0; j < 3; j++) {
                ctx.beginPath();
                ctx.moveTo(Math.random() * w, Math.random() * h);
                ctx.bezierCurveTo(
                    Math.random() * w, Math.random() * h,
                    Math.random() * w, Math.random() * h,
                    Math.random() * w, Math.random() * h
                );
                ctx.strokeStyle = 'rgba(148,163,184,0.3)';
                ctx.lineWidth = 1;
                ctx.stroke();
            }

            // 算式文本
            var text = captchaA + ' ' + captchaOp + ' ' + captchaB + ' = ?';
            ctx.font = 'bold 22px Microsoft YaHei, Arial';
            ctx.textBaseline = 'middle';

            // 文字阴影
            ctx.fillStyle = 'rgba(99,102,241,0.1)';
            ctx.fillText(text, 15, h / 2 + 2);

            // 每个字符随机偏移和旋转
            var startX = 14;
            for (var k = 0; k < text.length; k++) {
                ctx.save();
                var charColors = ['#4f46e5','#6366f1','#7c3aed','#4338ca','#5b21b6'];
                ctx.fillStyle = charColors[Math.floor(Math.random() * charColors.length)];
                var offsetY = (Math.random() - 0.5) * 6;
                var angle = (Math.random() - 0.5) * 0.15;
                ctx.translate(startX, h / 2 + offsetY);
                ctx.rotate(angle);
                ctx.fillText(text[k], 0, 0);
                ctx.restore();
                startX += ctx.measureText(text[k]).width + 1;
            }
        }

        function refreshCaptcha() {
            // 刷新时做一次 postback 来重新生成算式
            __doPostBack('', 'refreshCaptcha');
        }

        drawCaptcha();
    </script>
    </form>
</body>
</html>
