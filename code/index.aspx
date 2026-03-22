<%@ page title="" language="C#" autoeventwireup="true" inherits="index, LearnSite" %>

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
        return "信息科技学习网站";
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

    protected string GetLoginImageUrl()
    {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
        foreach (string ext in exts)
        {
            string path = Server.MapPath("~/images/loginbg" + ext);
            if (System.IO.File.Exists(path))
                return ResolveUrl("~/images/loginbg" + ext) + "?v=" + System.IO.File.GetLastWriteTime(path).Ticks;
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title><%= GetSiteTitle() %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <%= GetFaviconLinkTag() %>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700;900&amp;display=swap" rel="stylesheet" />
    <style>
        /* ===== Reset & Base ===== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; width: 100%; }
        body {
            font-family: 'Noto Sans SC', 'Microsoft YaHei', Arial, sans-serif;
            background: linear-gradient(135deg, #e0e7ff 0%, #dbeafe 25%, #e8d5f5 50%, #fce7f3 75%, #fef3c7 100%) !important;
            background-image: linear-gradient(135deg, #e0e7ff 0%, #dbeafe 25%, #e8d5f5 50%, #fce7f3 75%, #fef3c7 100%) !important;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            overflow: hidden;
            position: relative;
        }
        /* ===== Animated background blobs ===== */
        body::before, body::after {
            content: '';
            position: fixed;
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.45;
            z-index: 0;
            animation: blobFloat 8s ease-in-out infinite alternate;
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

        /* ===== Glassmorphism Card ===== */
        .login-card {
            position: relative;
            z-index: 1;
            display: flex;
            width: 960px;
            max-width: 96vw;
            min-height: 580px;
            background: rgba(255, 255, 255, 0.45);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border-radius: 28px;
            border: 1px solid rgba(255, 255, 255, 0.6);
            box-shadow:
                0 8px 32px rgba(99, 102, 241, 0.12),
                0 2px 8px rgba(0, 0, 0, 0.06),
                inset 0 1px 0 rgba(255,255,255,0.8);
            overflow: hidden;
        }

        /* ===== Left: Illustration Panel ===== */
        .login-left {
            flex: 1;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            overflow: hidden;
        }
        .login-left .brand {
            position: absolute;
            top: 28px; left: 32px;
            font-size: 17px;
            font-weight: 700;
            color: #1e1b4b;
            letter-spacing: 0.5px;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .login-left .brand span { color: #6366f1; }
        .brand-logo {
            height: 36px;
            max-width: 160px;
            object-fit: contain;
            border-radius: 4px;
        }
        .brand-text {
            font-size: 17px;
            font-weight: 700;
            color: #1e1b4b;
        }

        /* Floating geometric shapes */
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

        /* SVG illustration */
        .illustration-wrapper {
            width: 100%; max-width: 380px; z-index: 1;
        }
        .illustration-wrapper svg {
            width: 100%; height: auto;
            filter: drop-shadow(0 4px 12px rgba(99,102,241,0.15));
        }
        .illustration-wrapper img.login-bg-img {
            width: 100%; max-height: 400px;
            object-fit: contain;
            border-radius: 12px;
            filter: drop-shadow(0 4px 12px rgba(99,102,241,0.15));
        }

        /* ===== Right: Form Panel ===== */
        .login-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 48px 44px;
            position: relative;
        }
        .login-right::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(160deg, rgba(255,255,255,0.5) 0%, rgba(255,255,255,0.15) 50%, rgba(249,168,212,0.1) 100%);
            pointer-events: none;
        }

        /* Header */
        .form-header { position: relative; margin-bottom: 32px; }
        .form-header .welcome {
            font-size: 15px; color: #64748b; font-weight: 400; margin-bottom: 4px;
        }
        .form-header .welcome strong { color: #1e1b4b; font-weight: 700; }
        .form-header h1 {
            font-size: 38px; font-weight: 900; color: #1e1b4b;
            line-height: 1.2; letter-spacing: -0.5px;
        }
        .signup-link {
            position: absolute; top: 0; right: 0;
            text-align: right; font-size: 13px; color: #94a3b8;
        }
        .signup-link a {
            display: block; color: #6366f1 !important; text-decoration: none;
            font-weight: 500; margin-top: 2px; transition: color 0.2s;
        }
        .signup-link a:hover { color: #4f46e5 !important; text-decoration: underline; }

        /* Form fields */
        .form-group { position: relative; margin-bottom: 20px; }
        .form-group label {
            display: block; font-size: 13px; font-weight: 500;
            color: #1e293b; margin-bottom: 8px;
        }
        .form-group input[type="text"],
        .form-group input[type="password"] {
            width: 100% !important;
            height: 48px !important;
            padding: 0 16px !important;
            font-size: 14px !important;
            font-family: 'Noto Sans SC', Arial, sans-serif !important;
            color: #1e293b !important;
            background: rgba(255, 255, 255, 0.75) !important;
            background-color: rgba(255, 255, 255, 0.75) !important;
            border: 1.5px solid rgba(203, 213, 225, 0.6) !important;
            border-radius: 12px !important;
            outline: none !important;
            transition: all 0.25s ease !important;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;
        }
        .form-group input[type="text"]:focus,
        .form-group input[type="password"]:focus {
            border-color: #818cf8 !important;
            box-shadow: 0 0 0 3px rgba(129,140,248,0.15), 0 1px 3px rgba(0,0,0,0.04) !important;
            background: rgba(255, 255, 255, 0.9) !important;
            background-color: rgba(255, 255, 255, 0.9) !important;
        }
        .form-group input::placeholder { color: #a0aec0; }

        /* Error message */
        .msg-area { min-height: 24px; margin-bottom: 4px; position: relative; }
        .msg-area span { font-size: 13px; color: #ef4444; font-weight: 500; }

        /* Login button */
        .btn-login {
            width: 100% !important;
            height: 50px !important;
            border: none !important;
            border-radius: 14px !important;
            background: linear-gradient(135deg, #818cf8 0%, #7c3aed 50%, #a78bfa 100%) !important;
            background-image: linear-gradient(135deg, #818cf8 0%, #7c3aed 50%, #a78bfa 100%) !important;
            color: #fff !important;
            font-size: 16px !important;
            font-weight: 600 !important;
            font-family: 'Noto Sans SC', Arial, sans-serif !important;
            cursor: pointer;
            letter-spacing: 2px;
            transition: all 0.3s ease !important;
            box-shadow: 0 4px 16px rgba(124, 58, 237, 0.3) !important;
        }
        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 24px rgba(124, 58, 237, 0.4) !important;
            filter: brightness(1.05);
        }
        .btn-login:active { transform: translateY(0); }

        /* Divider */
        .divider {
            display: flex; align-items: center;
            margin: 22px 0 18px; position: relative;
        }
        .divider::before, .divider::after {
            content: ''; flex: 1; height: 1px;
            background: linear-gradient(90deg, transparent, rgba(148,163,184,0.3), transparent);
        }
        .divider span {
            padding: 0 14px; font-size: 12px;
            color: #94a3b8; font-weight: 400;
        }

        /* Quick links */
        .quick-links {
            display: flex; gap: 10px;
            justify-content: center; position: relative;
        }
        .quick-links a,
        .quick-links a:link,
        .quick-links a:visited {
            flex: 1;
            display: flex !important;
            align-items: center;
            justify-content: center;
            gap: 6px;
            height: 44px;
            background: rgba(255,255,255,0.6) !important;
            background-image: none !important;
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
            text-align: center !important;
        }
        .quick-links a:hover {
            background: rgba(255,255,255,0.85) !important;
            border-color: #818cf8 !important;
            color: #6366f1 !important;
            box-shadow: 0 2px 8px rgba(99,102,241,0.1);
        }
        .quick-links .link-icon { font-size: 16px; }

        /* Footer */
        .login-footer {
            position: relative;
            margin-top: 22px;
            padding: 10px 16px;
            background: linear-gradient(135deg, rgba(238,242,255,0.5) 0%, rgba(245,234,255,0.4) 100%);
            border: 1px solid rgba(165,180,252,0.2);
            border-radius: 12px;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            box-shadow: 0 2px 8px rgba(99,102,241,0.05), inset 0 1px 0 rgba(255,255,255,0.5);
            transition: all 0.3s ease;
        }
        .login-footer:hover {
            border-color: rgba(165,180,252,0.4);
            box-shadow: 0 3px 12px rgba(99,102,241,0.08), inset 0 1px 0 rgba(255,255,255,0.5);
        }
        .login-footer .footer-row {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            white-space: nowrap;
        }
        .login-footer .footer-item {
            display: inline-flex;
            align-items: center;
            gap: 3px;
            font-size: 11px;
            color: #64748b;
            font-weight: 400;
        }
        .login-footer .footer-item.mode-item {
            background: linear-gradient(135deg, rgba(129,140,248,0.1), rgba(167,139,250,0.1));
            border: 1px solid rgba(129,140,248,0.25);
            border-radius: 6px;
            padding: 2px 8px;
            color: #6366f1;
            font-weight: 500;
        }
        .login-footer .footer-item svg {
            flex-shrink: 0;
        }
        .login-footer .footer-dot {
            width: 2.5px; height: 2.5px;
            border-radius: 50%;
            background: rgba(148,163,184,0.45);
            flex-shrink: 0;
            margin: 0 2px;
        }
        .login-footer .footer-timing {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 3px;
            margin-top: 5px;
            font-size: 10px;
            color: #a0aec0;
            font-style: italic;
        }
        .login-footer .footer-timing svg {
            flex-shrink: 0;
        }
        .login-footer a { color: #6366f1; text-decoration: none; font-weight: 500; }
        .login-footer a:hover { text-decoration: underline; }

        /* ===== Responsive ===== */
        @media (max-width: 768px) {
            .login-card { flex-direction: column; min-height: auto; width: 94vw; }
            .login-left { display: none; }
            .login-right { padding: 36px 28px; }
            .form-header h1 { font-size: 28px; }
            .quick-links { flex-direction: column; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="login-card">
        <!-- ========== Left: Illustration ========== -->
        <div class="login-left">
            <div class="brand">
                <% string logoUrl = GetSiteLogoUrl(); %>
                <% if (!string.IsNullOrEmpty(logoUrl)) { %>
                    <img src="<%= logoUrl %>" alt="Logo" class="brand-logo" />
                <% } %>
                <span class="brand-text"><%= GetSiteTitle() %></span>
            </div>
            <div class="geo-shape geo-diamond"></div>
            <div class="geo-shape geo-diamond2"></div>
            <div class="geo-shape geo-square"></div>
            <div class="geo-shape geo-circle"></div>
            <div class="geo-shape geo-tri"></div>

            <div class="illustration-wrapper">
                <% string loginImgUrl = GetLoginImageUrl(); %>
                <% if (!string.IsNullOrEmpty(loginImgUrl)) { %>
                    <img src="<%= loginImgUrl %>" alt="登录插画" class="login-bg-img" />
                <% } else { %>
                <svg viewBox="0 0 480 400" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <!-- Ground shadow -->
                    <ellipse cx="240" cy="345" rx="195" ry="32" fill="url(#grd1)" opacity="0.2"/>

                    <!-- Curved screen glow -->
                    <path d="M80 130 Q240 70 400 130 L390 260 Q240 210 90 260 Z" fill="url(#screenCurve)" opacity="0.12" />

                    <!-- Main monitor -->
                    <rect x="165" y="155" width="150" height="100" rx="8" fill="#1e1b4b" stroke="#6366f1" stroke-width="2"/>
                    <rect x="172" y="162" width="136" height="80" rx="4" fill="url(#screenGrd)"/>
                    <!-- Code lines -->
                    <rect x="182" y="175" width="50" height="4" rx="2" fill="rgba(255,255,255,0.6)"/>
                    <rect x="182" y="185" width="80" height="4" rx="2" fill="rgba(255,255,255,0.3)"/>
                    <rect x="182" y="195" width="35" height="4" rx="2" fill="#34d399" opacity="0.8"/>
                    <rect x="222" y="195" width="55" height="4" rx="2" fill="rgba(255,255,255,0.25)"/>
                    <rect x="182" y="205" width="65" height="4" rx="2" fill="rgba(255,255,255,0.2)"/>
                    <rect x="182" y="215" width="40" height="4" rx="2" fill="#818cf8" opacity="0.7"/>
                    <rect x="227" y="215" width="50" height="4" rx="2" fill="rgba(255,255,255,0.2)"/>
                    <rect x="182" y="225" width="28" height="4" rx="2" fill="#fbbf24" opacity="0.6"/>
                    <rect x="215" y="225" width="42" height="4" rx="2" fill="rgba(255,255,255,0.15)"/>
                    <!-- Cursor blink -->
                    <rect x="182" y="234" width="2" height="7" rx="1" fill="#fbbf24" opacity="0.9">
                        <animate attributeName="opacity" values="0.9;0.1;0.9" dur="1s" repeatCount="indefinite"/>
                    </rect>
                    <!-- Monitor stand -->
                    <rect x="226" y="255" width="28" height="8" rx="2" fill="#a5b4fc"/>
                    <rect x="216" y="260" width="48" height="5" rx="2" fill="#c7d2fe"/>

                    <!-- Right monitor (charts) -->
                    <rect x="332" y="175" width="95" height="72" rx="6" fill="#1e1b4b" stroke="#6366f1" stroke-width="1.5"/>
                    <rect x="338" y="181" width="83" height="54" rx="3" fill="url(#screenGrd2)"/>
                    <!-- Pie chart -->
                    <circle cx="362" cy="208" r="14" fill="none" stroke="rgba(255,255,255,0.15)" stroke-width="7"/>
                    <circle cx="362" cy="208" r="14" fill="none" stroke="#818cf8" stroke-width="7" stroke-dasharray="22 66" opacity="0.8"/>
                    <circle cx="362" cy="208" r="14" fill="none" stroke="#34d399" stroke-width="7" stroke-dasharray="18 70" stroke-dashoffset="-22" opacity="0.7"/>
                    <circle cx="362" cy="208" r="14" fill="none" stroke="#fbbf24" stroke-width="7" stroke-dasharray="12 76" stroke-dashoffset="-40" opacity="0.6"/>
                    <!-- Bar chart -->
                    <rect x="389" y="218" width="6" height="14" rx="1" fill="#818cf8" opacity="0.7"/>
                    <rect x="398" y="212" width="6" height="20" rx="1" fill="#34d399" opacity="0.7"/>
                    <rect x="407" y="215" width="6" height="17" rx="1" fill="#fbbf24" opacity="0.6"/>
                    <!-- Right monitor stand -->
                    <rect x="372" y="247" width="16" height="6" rx="2" fill="#a5b4fc"/>

                    <!-- Left monitor (small) -->
                    <rect x="58" y="185" width="85" height="65" rx="6" fill="#1e1b4b" stroke="#6366f1" stroke-width="1.5"/>
                    <rect x="64" y="191" width="73" height="48" rx="3" fill="url(#screenGrd3)"/>
                    <!-- Wave chart -->
                    <polyline points="72,220 82,212 92,218 102,205 112,215 122,210 130,214" fill="none" stroke="#34d399" stroke-width="2" opacity="0.8"/>
                    <polyline points="72,225 82,220 92,228 102,218 112,222 122,219 130,224" fill="none" stroke="#818cf8" stroke-width="1.5" opacity="0.5"/>
                    <!-- Left monitor stand -->
                    <rect x="93" y="250" width="14" height="6" rx="2" fill="#a5b4fc"/>

                    <!-- Desk surface -->
                    <path d="M55 268 L425 268 L435 280 L45 280 Z" fill="#c7d2fe" stroke="#a5b4fc" stroke-width="0.5" opacity="0.7"/>
                    <!-- Desk legs -->
                    <rect x="75" y="280" width="10" height="52" rx="2" fill="#a5b4fc" opacity="0.7"/>
                    <rect x="395" y="280" width="10" height="52" rx="2" fill="#a5b4fc" opacity="0.7"/>

                    <!-- Keyboard -->
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
                    <!-- Mouse -->
                    <ellipse cx="315" cy="275" rx="9" ry="7" fill="#e0e7ff" stroke="#c7d2fe" stroke-width="0.8"/>

                    <!-- Chair -->
                    <ellipse cx="160" cy="340" rx="26" ry="5" fill="#4338ca" opacity="0.2"/>
                    <rect x="140" y="290" width="40" height="36" rx="10" fill="#4338ca"/>
                    <rect x="136" y="264" width="48" height="32" rx="10" fill="#4f46e5"/>
                    <rect x="155" y="326" width="10" height="16" rx="3" fill="#6366f1"/>
                    <circle cx="145" cy="342" r="4" fill="#6366f1" stroke="#4338ca" stroke-width="1"/>
                    <circle cx="175" cy="342" r="4" fill="#6366f1" stroke="#4338ca" stroke-width="1"/>

                    <!-- Person -->
                    <circle cx="178" cy="238" r="16" fill="#fcd34d"/>
                    <path d="M164 234 Q170 222 182 222 Q194 222 196 234" fill="#1e293b"/>
                    <rect x="166" y="253" width="24" height="34" rx="8" fill="#ef4444"/>
                    <path d="M166 258 L190 258 L190 262 L186 268 L186 262 L166 262 Z" fill="#dc2626" opacity="0.6"/>
                    <path d="M190 263 Q210 272 218 275" stroke="#fcd34d" stroke-width="6" stroke-linecap="round" fill="none"/>
                    <path d="M166 266 Q155 280 152 292" stroke="#fcd34d" stroke-width="5" stroke-linecap="round" fill="none"/>
                    <path d="M172 287 Q168 300 164 310" stroke="#1e3a5f" stroke-width="6" stroke-linecap="round" fill="none"/>
                    <path d="M184 287 Q188 300 190 310" stroke="#1e3a5f" stroke-width="6" stroke-linecap="round" fill="none"/>

                    <!-- Coffee mug -->
                    <rect x="348" y="257" width="14" height="14" rx="3" fill="#fbbf24" opacity="0.7"/>
                    <path d="M362 261 Q368 261 368 267 Q368 271 362 271" stroke="#fbbf24" stroke-width="1.5" fill="none" opacity="0.7"/>
                    <path d="M352 254 Q354 247 352 240" stroke="#cbd5e1" stroke-width="1.2" fill="none" opacity="0.4">
                        <animate attributeName="d" values="M352 254 Q354 247 352 240;M352 254 Q350 247 352 240;M352 254 Q354 247 352 240" dur="2s" repeatCount="indefinite"/>
                    </path>
                    <path d="M357 254 Q355 246 358 240" stroke="#cbd5e1" stroke-width="1.2" fill="none" opacity="0.3">
                        <animate attributeName="d" values="M357 254 Q355 246 358 240;M357 254 Q359 246 358 240;M357 254 Q355 246 358 240" dur="2.5s" repeatCount="indefinite"/>
                    </path>

                    <!-- Books stack -->
                    <rect x="410" y="258" width="24" height="5" rx="1" fill="#6366f1" opacity="0.45"/>
                    <rect x="412" y="253" width="22" height="5" rx="1" fill="#34d399" opacity="0.45"/>
                    <rect x="408" y="248" width="26" height="5" rx="1" fill="#f59e0b" opacity="0.45"/>

                    <!-- Plant -->
                    <rect x="40" y="305" width="18" height="22" rx="4" fill="#7c3aed" opacity="0.35"/>
                    <path d="M46 305 Q42 292 49 282 Q50 292 56 288 Q54 298 49 305" fill="#34d399" opacity="0.6"/>
                    <path d="M52 305 Q56 295 50 286" stroke="#059669" stroke-width="1" fill="none" opacity="0.4"/>

                    <!-- Floating badges -->
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
                <% } %>
            </div>
        </div>

        <!-- ========== Right: Login Form ========== -->
        <div class="login-right">
            <div class="form-header">
                <div class="signup-link">
                    还没有账号？
                    <asp:HyperLink ID="HyperLinkReg" runat="server"
                        NavigateUrl="~/student/register.aspx" Target="_self">学员注册</asp:HyperLink>
                </div>
                <p class="welcome">欢迎来到 <strong><%= GetSiteTitle() %></strong></p>
                <h1>登 录</h1>
            </div>

            <div class="form-group">
                <label>请输入学号</label>
                <asp:TextBox ID="TextBoxuser" runat="server"
                    EnableViewState="False"
                    placeholder="请输入学号"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>请输入密码</label>
                <asp:TextBox ID="TextBoxpwd" runat="server"
                    TextMode="Password"
                    EnableViewState="False"
                    AutoCompleteType="Disabled"
                    placeholder="请输入密码"></asp:TextBox>
            </div>

            <div class="msg-area">
                <asp:Label ID="Labelmsg" runat="server"></asp:Label>
            </div>

            <asp:Button ID="Btnlogin" runat="server" OnClick="Btnlogin_Click" Text="登 录"
                BorderStyle="None" CssClass="btn-login" />

            <div class="divider"><span>更多入口</span></div>

            <div class="quick-links">
                <asp:HyperLink ID="HyperLinkSnum" runat="server"
                    NavigateUrl="~/student/mynum.aspx" Target="_self"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg> 学号查询</asp:HyperLink>
                <asp:HyperLink ID="HyperLinkrule" runat="server"
                    NavigateUrl="~/student/myrule.aspx"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/><line x1="9" y1="12" x2="15" y2="12"/><line x1="9" y1="16" x2="13" y2="16"/></svg> 课堂守则</asp:HyperLink>
                <asp:HyperLink ID="HLTeacher" runat="server"
                    NavigateUrl="~/teacher/index.aspx" Target="_blank"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg> 教师平台</asp:HyperLink>
                <a href="manager/forgotpwd.aspx"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg> 忘记密码</a>
            </div>

            <div class="login-footer">
                <div class="footer-row">
                    <span class="footer-item mode-item">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                        <asp:Label ID="Labelversion" runat="server" Font-Size="8pt"></asp:Label>
                    </span>
                    <span class="footer-dot"></span>
                    <span class="footer-item">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#818cf8" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                        IP: <asp:Label ID="Labelip" runat="server" Font-Size="8pt"></asp:Label>
                    </span>
                    <span class="footer-dot"></span>
                    <span class="footer-item">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#818cf8" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                        <asp:Label ID="Labelhostname" runat="server" Font-Size="8pt"></asp:Label>
                    </span>
                    <span class="footer-dot"></span>
                    <span class="footer-item">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#818cf8" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        第<asp:Label ID="Labelterm" runat="server" Font-Size="8pt"></asp:Label>学期
                    </span>
                </div>
                <div class="footer-timing">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    <asp:Label ID="Labelloadtime" runat="server" Font-Size="7pt"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function doubleCheck() {
            if (window.document.readyState != null &&
                window.document.readyState != 'complete') {
                alert("正在处理，请等待！");
                return false;
            }
            return true;
        }
        // Subtle focus animation
        document.addEventListener('DOMContentLoaded', function () {
            var inputs = document.querySelectorAll('.form-group input');
            inputs.forEach(function (input) {
                input.addEventListener('focus', function () {
                    this.parentElement.style.transform = 'translateX(2px)';
                    this.parentElement.style.transition = 'transform 0.2s ease';
                });
                input.addEventListener('blur', function () {
                    this.parentElement.style.transform = 'translateX(0)';
                });
            });
            // Auto-focus first input
            var first = document.querySelector('.form-group input[type="text"]');
            if (first) first.focus();
        });
    </script>
    </form>
</body>
</html>
