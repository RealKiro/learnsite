<%@ page language="C#" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_workpackage, LearnSite" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>班级作品打包</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
            background: #ffffff;
            color: #1a1a2e;
            margin: 0;
            overflow: hidden;
        }
        #form1 { width: 100%; height: 100%; display: flex; flex-direction: column; }

        /* ── 顶部横幅 ── */
        .pkg-banner {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 22px 28px;
            position: relative;
            overflow: hidden;
        }
        .pkg-banner::before {
            content: '';
            position: absolute;
            top: -30px; right: -20px;
            width: 120px; height: 120px;
            background: rgba(255,255,255,0.08);
            border-radius: 50%;
        }
        .pkg-banner::after {
            content: '';
            position: absolute;
            bottom: -40px; left: 30%;
            width: 80px; height: 80px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
        }
        .pkg-banner h3 {
            font-size: 17px;
            font-weight: 700;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 10px;
            position: relative;
            z-index: 1;
        }
        .pkg-banner h3 svg {
            width: 22px; height: 22px;
            stroke: rgba(255,255,255,0.9);
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        .pkg-banner .banner-sub {
            font-size: 12px;
            color: rgba(255,255,255,0.7);
            margin-top: 4px;
            position: relative;
            z-index: 1;
        }

        /* ── 主体内容 ── */
        .pkg-body {
            flex: 1;
            padding: 20px 24px 16px;
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        /* 选择器行 */
        .pkg-selectors {
            display: flex;
            gap: 12px;
            align-items: stretch;
        }
        .sel-card {
            flex: 1;
            background: #f7f8fc;
            border: 1px solid #ebebf3;
            border-radius: 10px;
            padding: 10px 12px;
            display: flex;
            flex-direction: column;
            gap: 4px;
            transition: all 0.2s;
        }
        .sel-card:hover {
            border-color: #b8c0f0;
            background: #f0f1fb;
        }
        .sel-card .sel-label {
            font-size: 11px;
            font-weight: 600;
            color: #8b8fa8;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .sel-card select {
            width: 100%;
            height: 30px;
            border: none;
            background: transparent;
            font-size: 14px;
            font-weight: 600;
            color: #1a1a2e;
            outline: none;
            cursor: pointer;
            font-family: inherit;
            -webkit-appearance: none;
            appearance: none;
            padding-right: 4px;
        }

        /* 操作区 */
        .pkg-action-row {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .pkg-action-row input[type="submit"],
        .btn-pack {
            flex: 1;
            height: 42px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.25s;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            font-family: inherit;
            letter-spacing: 1px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.35);
        }
        .pkg-action-row input[type="submit"]:hover,
        .btn-pack:hover {
            box-shadow: 0 6px 24px rgba(102, 126, 234, 0.5);
            transform: translateY(-2px);
        }
        .pkg-action-row input[type="submit"]:active,
        .btn-pack:active {
            transform: translateY(0);
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
        }

        /* ── 结果状态卡片 ── */
        .pkg-status {
            background: #f7f8fc;
            border: 1px solid #ebebf3;
            border-radius: 10px;
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: all 0.2s;
        }
        .pkg-status:hover {
            border-color: #c5c9ef;
        }
        .status-icon {
            width: 40px; height: 40px;
            border-radius: 10px;
            background: linear-gradient(135deg, #e0e3ff, #f0e6ff);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .status-icon svg {
            width: 20px; height: 20px;
            stroke: #764ba2;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        .status-info {
            flex: 1;
            min-width: 0;
        }
        .status-info a {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #667eea;
            text-decoration: none;
            transition: color 0.15s;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .status-info a:hover { color: #4c5fd7; text-decoration: underline; }
        .status-info span {
            display: block;
            font-size: 11px;
            color: #9a9cb8;
            margin-top: 2px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- 顶部渐变横幅 -->
        <div class="pkg-banner">
            <h3>
                <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                班级作品打包
            </h3>
            <div class="banner-sub">选择班级和学案，一键打包下载全部学生作品</div>
        </div>

        <!-- 主体 -->
        <div class="pkg-body">
            <!-- 三列选择器 -->
            <div class="pkg-selectors">
                <div class="sel-card">
                    <span class="sel-label">年级</span>
                    <asp:DropDownList ID="DDLgrade" runat="server"
                        EnableTheming="True" AutoPostBack="True"
                        onselectedindexchanged="DDLgrade_SelectedIndexChanged" />
                </div>
                <div class="sel-card">
                    <span class="sel-label">班级</span>
                    <asp:DropDownList ID="DDLclass" runat="server"
                        EnableTheming="True" AutoPostBack="True"
                        onselectedindexchanged="DDLclass_SelectedIndexChanged" />
                </div>
                <div class="sel-card" style="flex:2">
                    <span class="sel-label">学案名称</span>
                    <asp:DropDownList ID="DDLCid" runat="server" Font-Names="Arial"
                        AutoPostBack="True"
                        onselectedindexchanged="DDLCid_SelectedIndexChanged" />
                </div>
            </div>

            <asp:Label ID="Labelyear" runat="server" Visible="False" />

            <!-- 打包按钮 -->
            <div class="pkg-action-row">
                <asp:Button ID="Button1" runat="server" Text="⬇  开始打包"
                    onclick="Button1_Click" CssClass="btn-pack" />
            </div>

            <!-- 状态卡片 -->
            <div class="pkg-status">
                <div class="status-icon">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                </div>
                <div class="status-info">
                    <asp:HyperLink ID="HyperLink1" runat="server">本学案作品包下载</asp:HyperLink>
                    <asp:Label ID="Labelmsg" runat="server">打包时请耐心等待几秒</asp:Label>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
