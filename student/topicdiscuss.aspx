<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" validaterequest="false" autoeventwireup="true" inherits="Student_topicdiscuss, LearnSite" %>
<%@ Register Assembly="Anthem" Namespace="Anthem" TagPrefix="anthem" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
    <asp:Label ID="LabelCid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="LabelTid" runat="server" Visible="False"></asp:Label>
    <style>
        #student {
            font-family: "Microsoft YaHei", "Segoe UI", Arial, sans-serif;
            color: #1f2937;
            min-height: 100vh;
            background:
                radial-gradient(circle at top left, rgba(59, 130, 246, 0.10), transparent 24%),
                radial-gradient(circle at right center, rgba(34, 197, 94, 0.08), transparent 20%),
                linear-gradient(180deg, #f4f8ff 0%, #edf5ff 100%);
        }

        /* 放宽页面容器宽度并取消默认 placeauto 限制 */
        .placeauto {
            max-width: 100% !important;
        }

        .td-page {
            width: 100%;
            max-width: 1860px;
            margin: 0 auto;
            padding: 24px 24px 48px;
        }

        /* 收窄左侧菜单与正文的间距，覆盖全局样式 */
        .menu {
            width: 180px !important;
            min-width: 180px !important;
        }

        body:has(.menu) {
            padding-left: 180px !important;
        }

        .studmasterhead:has(.menu),
        .stu:has(~ .menu),
        .stu:has(+ .menu) {
            margin-left: 180px !important;
            padding-left: 0 !important;
        }

        body:has(.menu) .placeauto {
            max-width: calc(100% - 180px) !important;
        }

        .td-shell {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .td-card {
            background: rgba(255, 255, 255, 0.96);
            border: 1px solid rgba(226, 234, 245, 0.95);
            border-radius: 24px;
            box-shadow: 0 18px 42px rgba(15, 23, 42, 0.08);
            overflow: hidden;
        }

        .td-hero {
            padding: 30px 34px;
            background: linear-gradient(135deg, #1d4ed8 0%, #4338ca 48%, #0f766e 100%);
            color: #ffffff;
            position: relative;
            overflow: hidden;
        }

        .td-hero:before,
        .td-hero:after {
            content: "";
            position: absolute;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.12);
        }

        .td-hero:before {
            width: 220px;
            height: 220px;
            right: -70px;
            top: -100px;
        }

        .td-hero:after {
            width: 160px;
            height: 160px;
            right: 180px;
            bottom: -90px;
        }

        .td-hero-inner {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 22px;
        }

        .td-hero-title {
            display: flex;
            flex-direction: column;
            gap: 12px;
            text-align: left;
        }

        .td-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            width: fit-content;
            padding: 7px 13px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.14);
            font-size: 12px;
            letter-spacing: 1px;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.16);
        }

        .td-kicker svg,
        .td-badge svg,
        .td-title-icon svg,
        .td-word-stat svg,
        .td-foot-meta svg,
        .td-absent-badge svg {
            width: 16px;
            height: 16px;
            fill: none;
            stroke: currentColor;
            stroke-width: 1.9;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .td-topic-label {
            font-size: 30px;
            font-weight: 700;
            line-height: 1.38;
            color: #ffffff;
            text-shadow: 0 10px 30px rgba(15, 23, 42, 0.22);
        }

        .td-hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            padding-top: 2px;
        }

        .td-icon-btn,
        .td-anchor-btn {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.18);
            backdrop-filter: blur(6px);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.18), 0 10px 20px rgba(15, 23, 42, 0.16);
            transition: transform .18s ease, box-shadow .18s ease, background-color .18s ease;
            box-sizing: border-box;
        }

        .td-icon-btn {
            display: inline-block;
            padding: 10px !important;
            vertical-align: middle;
            object-fit: contain;
            object-position: center;
            appearance: none;
            -webkit-appearance: none;
        }

        .td-anchor-btn {
            position: relative;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            vertical-align: middle;
            font-size: 0;
            line-height: 0;
        }

        .td-icon-btn:hover,
        .td-anchor-btn:hover {
            transform: translateY(-1px);
            background: rgba(255, 255, 255, 0.22);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.22), 0 14px 24px rgba(15, 23, 42, 0.18);
        }

        .td-icon-btn[disabled] {
            opacity: 0.58;
            cursor: not-allowed;
            box-shadow: none;
        }

        .td-hero-tip {
            margin-top: 2px;
            max-width: 720px;
            color: rgba(255, 255, 255, 0.92);
            font-size: 14px;
            text-align: left;
            line-height: 1.8;
        }

        .td-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr);
            gap: 18px;
        }

        .td-panel {
            padding: 24px 26px;
        }

        .td-panel-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 14px;
        }

        .td-heading,
        .td-toolbar-label,
        .td-editor-title {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .td-title-icon {
            width: 40px;
            height: 40px;
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.45);
        }

        .td-title-icon-indigo { background: linear-gradient(135deg, #dbeafe, #c7d2fe); color: #3730a3; }
        .td-title-icon-cyan { background: linear-gradient(135deg, #cffafe, #dbeafe); color: #0f766e; }
        .td-title-icon-violet { background: linear-gradient(135deg, #ede9fe, #ddd6fe); color: #6d28d9; }
        .td-title-icon-emerald { background: linear-gradient(135deg, #dcfce7, #d1fae5); color: #047857; }
        .td-title-icon-amber { background: linear-gradient(135deg, #ffedd5, #fde68a); color: #c2410c; }

        .td-panel-title h3 {
            margin: 0;
            font-size: 18px;
            color: #111827;
            display: inline-flex;
            align-items: center;
            gap: 12px;
        }

        .td-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            border-radius: 999px;
            background: #eff6ff;
            color: #2563eb;
            font-size: 13px;
            font-weight: 600;
            white-space: nowrap;
        }

        #Topics,
        #TopicsResult {
            text-align: left;
            font-size: 15px;
            line-height: 1.9;
            color: #334155;
        }

        #Topics {
            background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
            border: 1px solid #e0ecff;
            border-radius: 18px;
            padding: 20px 22px;
            margin: 0;
            box-shadow: inset 0 1px 0 rgba(255,255,255,.7);
        }

        #TopicsResult {
            margin-top: 14px;
            padding: 18px 20px;
            border-radius: 16px;
            background: #fffaf0;
            border: 1px dashed #f7c978;
        }

        .td-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 0 2px;
            margin-bottom: 14px;
        }

        .topicleft,
        .topicright {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .td-toolbar-title,
        .td-reply-title {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .td-toolbar-title strong,
        .td-reply-title strong {
            color: inherit;
        }

        .td-list-card {
            padding: 24px 26px;
        }

        .td-list-wrap {
            border-radius: 20px;
            overflow: hidden;
            background: linear-gradient(180deg, rgba(248, 250, 252, 0.92) 0%, rgba(255,255,255,0.98) 100%);
            border: 1px solid #e5edf7;
            padding: 14px;
        }

        .td-list-wrap table {
            width: 100% !important;
        }

        .td-post {
            margin: 0 0 14px 0;
            border: 1px solid #e6edf5;
            border-radius: 20px;
            background: #ffffff;
            overflow: hidden;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.05);
            position: relative;
        }

        .td-post:before {
            content: "";
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: linear-gradient(180deg, #3b82f6 0%, #22c55e 100%);
        }

        .td-post-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 18px 20px 16px 22px;
            background: linear-gradient(180deg, #fbfdff 0%, #f5f9ff 100%);
            border-bottom: 1px solid #e8eef6;
        }

        .td-post-user {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .imgstu {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            opacity: 0.92;
            border: 2px solid rgba(255, 255, 255, 0.95);
            box-shadow: 0 8px 18px rgba(59, 130, 246, 0.18);
        }

        .imgstu:hover {
            opacity: 1;
        }

        .td-user-meta {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 0;
        }

        .td-user-name {
            font-size: 16px;
            font-weight: 700;
            color: #111827;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .td-user-sub {
            font-size: 12px;
            color: #64748b;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .td-post-tools {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            flex-wrap: wrap;
            font-size: 13px;
            color: #475569;
        }

        .td-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 11px;
            border-radius: 999px;
            background: #eef2ff;
            color: #4338ca;
            font-weight: 600;
            border: 1px solid rgba(191, 219, 254, 0.88);
        }

        .td-chip-score {
            background: #ecfdf5;
            color: #059669;
        }

        .td-score-icon {
            width: 16px;
            height: 16px;
            opacity: 0.92;
            vertical-align: middle;
        }

        .td-row-icon,
        .td-flag-icon,
        .td-agree-icon {
            width: 18px;
            height: 18px;
            opacity: 0.94;
            vertical-align: middle;
        }

        .td-agree-icon {
            width: 16px;
            height: 16px;
        }

        .td-anchor-btn img {
            position: absolute;
            left: 50%;
            top: 50%;
            width: 18px !important;
            height: 18px !important;
            display: block;
            transform: translate(-50%, -50%);
        }

        .td-chip-floor {
            background: #fff7ed;
            color: #ea580c;
        }

        .td-tool-group {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .td-row-icon,
        .td-icon-btn,
        .td-anchor-btn {
            cursor: pointer;
        }

        .td-row-icon {
            width: 32px !important;
            height: 32px !important;
            padding: 6px;
            border-radius: 10px;
            background: #ffffff;
            border: 1px solid #d9e3ef;
            box-shadow: 0 6px 14px rgba(15, 23, 42, 0.08);
            box-sizing: border-box;
            transition: transform .16s ease, box-shadow .16s ease, border-color .16s ease, background-color .16s ease;
        }

        .td-row-icon:hover {
            transform: translateY(-1px);
            background: #f8fbff;
            border-color: #bfdbfe;
            box-shadow: 0 10px 18px rgba(59, 130, 246, 0.14);
        }

        .topictext {
            user-select: none;
            padding: 20px 22px 16px;
            text-align: left;
            background: #ffffff;
            transition: background-color 0.2s ease;
            line-height: 1.95;
            color: #334155;
        }

        .topictext:hover {
            background-color: #fffdf7;
        }

        .topictext img {
            max-width: 100%;
            height: auto;
            max-height: 260px;
            border-radius: 14px;
            -webkit-user-drag: none;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(15, 23, 42, 0.12);
            margin: 8px 0;
        }

        .td-post-foot {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 18px;
            flex-wrap: wrap;
            padding: 0 22px 18px;
            font-size: 12px;
            color: #94a3b8;
        }

        .td-foot-meta {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .td-editor-card {
            padding: 24px 26px;
        }

        .td-editor-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 16px;
        }

        .td-editor-desc {
            color: #64748b;
            font-size: 13px;
            margin-top: 6px;
        }

        .td-editor-box {
            padding: 16px;
            border-radius: 18px;
            background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
            border: 1px solid #dde7f2;
            box-shadow: inset 0 1px 0 rgba(255,255,255,.82);
        }

        .td-editor-box .ke-container {
            width: 100% !important;
            border: 1px solid #d9e3f0 !important;
            border-radius: 16px !important;
            overflow: hidden;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
        }

        .td-editor-box .ke-toolbar {
            background: linear-gradient(180deg, #ffffff 0%, #f8fbff 100%) !important;
            border-bottom: 1px solid #e6edf5 !important;
            padding: 10px 12px !important;
        }

        .td-editor-box .ke-statusbar {
            background: #f8fbff !important;
            border-top: 1px solid #e6edf5 !important;
        }

        .td-editor-meta {
            margin-top: 16px;
            text-align: center;
            font-size: 14px;
            color: #475569;
        }

        .td-word-stat {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            font-weight: 600;
        }

        .td-editor-actions {
            margin-top: 18px;
            text-align: center;
        }

        .td-submit {
            width: 120px !important;
            height: 40px !important;
            border-radius: 999px;
            background: linear-gradient(135deg, #2563eb 0%, #4f46e5 100%) !important;
            color: #ffffff;
            font-size: 14px !important;
            font-weight: 700;
            box-shadow: 0 10px 24px rgba(37, 99, 235, 0.22);
        }

        .td-submit:hover {
            color: #ffffff;
            font-weight: 700;
            transform: translateY(-1px);
        }

        .td-empty-note {
            padding: 18px 22px;
            border-radius: 16px;
            background: #f8fafc;
            color: #64748b;
            text-align: center;
        }

        /* 未参与人员样式 */
        .td-absent-card {
            margin-top: 18px;
            padding: 20px 22px;
            border-radius: 18px;
            background: linear-gradient(180deg, #f9fbff 0%, #ffffff 100%);
            border: 1px solid #e3ebf6;
            box-shadow: 0 10px 28px rgba(15, 23, 42, 0.06);
        }

        .td-absent-head {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
            font-weight: 700;
            color: #0f172a;
        }

        .td-absent-meta {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .td-absent-meta > span:last-child {
            font-size: 13px;
            font-weight: 500;
            color: #64748b;
        }

        .td-absent-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 999px;
            background: #fff7ed;
            color: #c2410c;
            font-size: 13px;
            font-weight: 700;
            width: fit-content;
        }

        .td-absent-list {
            padding: 12px 14px;
            border-radius: 14px;
            background: #f8fafc;
            border: 1px dashed #d8e3f0;
            color: #475569;
            line-height: 1.8;
            font-size: 15px;
            white-space: normal;
            word-break: break-word;
        }

        .td-absent-list:before {
            content: none;
        }

        #outerdiv {
            position: fixed;
            top: 0;
            left: 0;
            background: rgba(15, 23, 42, 0.86);
            z-index: 9999;
            width: 100%;
            height: 100%;
            display: none;
            backdrop-filter: blur(2px);
        }

        #innerdiv {
            position: absolute;
        }

        #bigimg {
            pointer-events: none;
            border-radius: 16px;
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.35);
        }

        @media (max-width: 900px) {
            .td-page {
                padding: 16px 12px 28px;
            }

            .td-hero,
            .td-panel,
            .td-list-card,
            .td-editor-card {
                padding-left: 16px;
                padding-right: 16px;
            }

            .td-hero-inner,
            .td-post-head,
            .td-toolbar,
            .td-editor-head {
                flex-direction: column;
                align-items: flex-start;
            }

            .td-post-tools {
                justify-content: flex-start;
            }

            .td-post-foot {
                justify-content: flex-start;
            }
        }
    </style>
    <div id="student">
        <div class="td-page">
            <div class="td-shell">
                <div id="topper" class="td-card td-hero">
                    <div class="td-hero-inner">
                        <div class="td-hero-title">
                            <span class="td-kicker">
                                <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                                话题讨论区
                            </span>
                            <anthem:Label ID="Labeltopic" runat="server" CssClass="td-topic-label" Font-Size="16pt" Font-Bold="True" Font-Names="宋体, Arial, Helvetica, sans-serif"></anthem:Label>
                            <div class="td-hero-tip">围绕主题自由表达观点，查看同学回复，发布自己的想法。</div>
                        </div>
                        <div class="td-hero-actions">
                            <asp:ImageButton ID="Btnclock" runat="server" ImageUrl="~/images/svg/topic/clock.svg" onclick="Btnclock_Click" Enabled="False" CssClass="td-icon-btn" />
                            <anthem:CheckBox ID="TcloseCheck" runat="server" Visible="False" />
                        </div>
                    </div>
                </div>

                <div class="td-grid">
                    <div class="td-card td-panel">
                        <div class="td-panel-title">
                            <h3 class="td-heading">
                                <span class="td-title-icon td-title-icon-cyan">
                                    <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 1 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                </span>
                                <span>讨论主题</span>
                            </h3>
                            <span class="td-badge">
                                <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 1 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                阅读后再参与讨论
                            </span>
                        </div>
                        <div ID="Topics" runat="server"></div>
                        <div ID="TopicsResult" runat="server" class="topictext"></div>
                    </div>

                    <div class="td-card td-list-card">
                        <div class="td-toolbar">
                            <div class="topicleft td-toolbar-title">
                                <span class="td-toolbar-label">
                                    <span class="td-title-icon td-title-icon-indigo">
                                        <svg viewBox="0 0 24 24"><path d="M8 12h8"/><path d="M8 8h8"/><path d="M8 16h5"/><rect x="3" y="4" width="18" height="16" rx="2"/></svg>
                                    </span>
                                    <strong>帖子列表</strong>
                                </span>
                                <span class="td-badge">
                                    <svg viewBox="0 0 24 24"><path d="M8 12h8"/><path d="M8 8h8"/><path d="M8 16h5"/><rect x="3" y="4" width="18" height="16" rx="2"/></svg>
                                    共 <anthem:Label ID="Labelreplycount" runat="server"></anthem:Label> 条
                                </span>
                                <anthem:ImageButton ID="ImageBtngoodall" runat="server" ImageUrl="~/images/svg/topic/score-plus.svg" onclick="ImageBtngoodall_Click" ToolTip="给所有未评分的帖子加2分" Visible="False" CssClass="td-row-icon" />
                                <anthem:ImageButton ID="ImageBtngood2" runat="server" ImageUrl="~/images/svg/topic/score-plus.svg" onclick="ImageBtngood2_Click" ToolTip="给所有未评分的帖子加6分" Visible="False" CssClass="td-row-icon" />
                            </div>
                            <div class="topicright">
                                <anthem:ImageButton ID="ImageBtnFresh" runat="server" ImageUrl="~/images/svg/topic/refresh.svg" onclick="ImageBtnFresh_Click" ToolTip="刷新贴子" CssClass="td-icon-btn" />
                                <anthem:HyperLink ID="HLbottom" runat="server" BorderStyle="None" BorderWidth="0px" ImageUrl="~/images/svg/topic/arrow-down.svg" NavigateUrl="#bottom" ToolTip="跳到底部" CssClass="td-anchor-btn"></anthem:HyperLink>
                            </div>
                        </div>

                        <div class="td-list-wrap">
                            <anthem:GridView ID="GVtopicDiscuss" runat="server" AutoGenerateColumns="False" CellPadding="0" Width="100%" onrowdatabound="GVtopicDiscuss_RowDataBound" DataKeyNames="rid" PageSize="5" CellSpacing="1" ShowHeader="False" GridLines="None" onrowcommand="GVtopicDiscuss_RowCommand">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <div class="td-post">
                                                <div class="td-post-head">
                                                    <div class="td-post-user">
                                                        <anthem:Image ID="Imagestu" runat="server" CssClass="imgstu" />
                                                        <div class="td-user-meta">
                                                            <div class="td-user-name">
                                                                <anthem:Label ID="Labelsname" runat="server" Text='<%# Bind("Sname") %>'></anthem:Label>
                                                                <anthem:Image ID="Imageagree" runat="server" Visible="False" ImageUrl="~/images/svg/topic/agree-mark.svg" CssClass="td-agree-icon" />
                                                            </div>
                                                            <div class="td-user-sub">
                                                                参与讨论中
                                                                <anthem:CheckBox ID="Ckedit" runat="server" Checked='<%# Bind("Redit") %>' Visible="False" />
                                                                <anthem:Label ID="Labelsnum" runat="server" Text='<%# Bind("Rsnum") %>' Visible="False"></anthem:Label>
                                                                <anthem:CheckBox ID="CheckSleader" runat="server" Checked='<%# Bind("Sleader") %>' Visible="False" />
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="td-post-tools">
                                                        <span class="td-chip td-chip-score">
                                                            <anthem:Image ID="Imagegroup" runat="server" ImageUrl="~/images/svg/topic/credit-card.svg" CssClass="td-score-icon" />
                                                            <anthem:Label ID="Labelscore" runat="server" Text='<%# Bind("Rscore") %>' ToolTip="学分" ForeColor="#333333"></anthem:Label> 学分
                                                        </span>
                                                        <span class="td-chip">
                                                            <anthem:ImageButton ID="ImageButtonAgree" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Agree" ImageUrl="~/images/svg/topic/agree-action.svg" ToolTip="点赞" CssClass="td-row-icon"></anthem:ImageButton>
                                                            <anthem:Label ID="Labelagree" runat="server" Text='<%# Bind("Ragree") %>'></anthem:Label> 点赞
                                                        </span>
                                                        <span class="td-chip td-chip-floor">
                                                            <anthem:Image ID="Imageflag" runat="server" ImageUrl="~/images/svg/topic/floor-flag.svg" CssClass="td-flag-icon" />
                                                            <anthem:Label ID="Labelfloor" runat="server"></anthem:Label> 楼
                                                        </span>
                                                        <span class="td-tool-group">
                                                            <anthem:ImageButton ID="ImageButtonEdit" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Reply" ImageUrl="~/images/svg/topic/reply.svg" ToolTip="回复" CssClass="td-row-icon"></anthem:ImageButton>
                                                            <anthem:ImageButton ID="ImageButtonGood" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Good" ImageUrl="~/images/svg/topic/score-plus.svg" ToolTip="加2分" CssClass="td-row-icon" />
                                                            <anthem:ImageButton ID="ImageButtonless" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Less" ImageUrl="~/images/svg/topic/score-minus.svg" ToolTip="减2分" CssClass="td-row-icon" />
                                                            <anthem:ImageButton ID="ImageButtonDel" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Del" ImageUrl="~/images/svg/topic/delete.svg" ToolTip="删除" CssClass="td-row-icon"></anthem:ImageButton>
                                                        </span>
                                                    </div>
                                                </div>

                                                <div class="topictext">
                                                    <%# HttpUtility.HtmlDecode(Eval("Rwords").ToString())%>
                                                </div>

                                                <div class="td-post-foot">
                                                    <span class="td-foot-meta">
                                                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                                        时间：<anthem:Label ID="Labeldate" runat="server" Text='<%# Bind("Rtime") %>'></anthem:Label>
                                                    </span>
                                                    <span class="td-foot-meta">
                                                        <svg viewBox="0 0 24 24"><path d="M12 2 4 5v6c0 5 3.5 9 8 11 4.5-2 8-6 8-11V5l-8-3Z"/><path d="M9 12h6"/><path d="M12 9v6"/></svg>
                                                        IP：<anthem:Label ID="Labelip" runat="server" Text='<%# Bind("Rip") %>'></anthem:Label>
                                                    </span>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <HeaderStyle Font-Bold="False" />
                            </anthem:GridView>
                        </div>

                        <div id="bottom" style="height: 1px;"></div>

                        <div class="td-toolbar" style="margin-top: 18px;">
                            <div class="topicleft td-reply-title">
                                <span class="td-toolbar-label">
                                    <span class="td-title-icon td-title-icon-emerald">
                                        <svg viewBox="0 0 24 24"><path d="M9 17 4 12l5-5"/><path d="M20 18v-2a4 4 0 0 0-4-4H4"/></svg>
                                    </span>
                                    <strong>讨论回复</strong>
                                </span>
                                <span class="td-badge">
                                    <svg viewBox="0 0 24 24"><path d="M9 17 4 12l5-5"/><path d="M20 18v-2a4 4 0 0 0-4-4H4"/></svg>
                                    当前 <asp:Label ID="Labelreplycountbtm" runat="server"></asp:Label> 条
                                </span>
                            </div>
                            <div class="topicright">
                                <anthem:ImageButton ID="ImageBtnFreshtwo" runat="server" ImageUrl="~/images/svg/topic/refresh.svg" onclick="ImageBtnFresh_Click" ToolTip="刷新贴子" CssClass="td-icon-btn" />
                                <anthem:HyperLink ID="HLtop" runat="server" BorderStyle="None" BorderWidth="0px" ImageUrl="~/images/svg/topic/arrow-up.svg" NavigateUrl="#topper" ToolTip="跳到顶部" CssClass="td-anchor-btn"></anthem:HyperLink>
                            </div>
                        </div>
                    </div>

                    <div id="plant" runat="server" class="td-card td-editor-card">
                        <div class="td-editor-head">
                            <div>
                                <div class="td-toolbar-title td-editor-title">
                                    <span class="td-title-icon td-title-icon-violet">
                                        <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 1 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                    </span>
                                    <span>发表你的观点</span>
                                </div>
                                <div class="td-editor-desc">支持文字与图片内容，建议围绕主题简洁表达，便于同学阅读与互动。</div>
                            </div>
                            <span class="td-badge">
                                <svg viewBox="0 0 24 24"><path d="M22 10v6"/><path d="M2 10v6"/><path d="M6 14h12"/><path d="M12 2v4"/><path d="M7 5h10"/></svg>
                                至少 2 个汉字，最多 300 个汉字
                            </span>
                        </div>

                        <div class="td-editor-box">
                            <textarea name="textareaWord" style="width: 100%; height: 260px;"></textarea>
                        </div>

                        <script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
                        <script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>
                        <script src="../code/jquery.min.js" type="text/javascript"></script>
                        <script type="text/javascript">
                            var editor;
                            var ty = "Topic";
                            var cid = "<%=myCid %>";
                            var upjs = "../kindeditor/aspnet/upload_json.aspx?cid=" + cid + "&ty=" + ty;

                            KindEditor.ready(function (K) {
                                editor = K.create('textarea[name="textareaWord"]', {
                                    filterMode: false,
                                    resizeType: 1,
                                    pasteType: 1,
                                    newlineTag: "br",
                                    allowPreviewEmoticons: false,
                                    uploadJson: upjs,
                                    allowImageUpload: true,
                                    items: ['formatblock', 'fontname', 'fontsize', '|', 'bold', 'italic', 'forecolor', 'hilitecolor', 'removeformat', '|', 'justifyleft', 'justifycenter', 'justifyright', 'image'],
                                    afterChange: function () {
                                        K('.word_count').html(this.count('text'));
                                    }
                                });
                            });

                            function bindTopicImages() {
                                $(".topictext img").each(function () {
                                    $(this).attr("oncontextmenu", "return false;");
                                });
                            }

                            $(document).on("click", ".topictext img", function () {
                                imgShow("#outerdiv", "#innerdiv", "#bigimg", $(this));
                            });

                            function imgShow(outerdiv, innerdiv, bigimg, currentImage) {
                                var src = currentImage.attr("src");
                                $(bigimg).attr("src", src);
                                $("<img/>").attr("src", src).on("load", function () {
                                    var windowW = $(window).width();
                                    var windowH = $(window).height();
                                    var realWidth = this.width;
                                    var realHeight = this.height;
                                    var imgWidth;
                                    var imgHeight;
                                    var scale = 0.8;

                                    if (realWidth > windowW * scale) {
                                        imgWidth = windowW * scale;
                                        imgHeight = imgWidth / realWidth * realHeight;
                                    } else if (realHeight > windowH * scale) {
                                        imgHeight = windowH * scale;
                                        imgWidth = imgHeight / realHeight * realWidth;
                                    } else {
                                        imgWidth = realWidth;
                                        imgHeight = realHeight;
                                    }

                                    $(bigimg).css({
                                        width: imgWidth,
                                        height: imgHeight
                                    });

                                    var w = (windowW - imgWidth) / 2;
                                    var h = (windowH - imgHeight) / 2;
                                    $(innerdiv).css({ top: h, left: w });
                                    $(outerdiv).fadeIn("fast");
                                });
                            }

                            $(document).ready(function () {
                                bindTopicImages();
                                $("#outerdiv").on("click", function () {
                                    $(this).fadeOut("fast");
                                });
                            });
                        </script>

                        <div class="td-editor-meta">
                            <span class="td-word-stat">
                                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                                您当前输入了 <span class="word_count">0</span> 个文字
                            </span>
                        </div>

                        <div class="td-editor-actions">
                            <asp:Button ID="Btnword" runat="server" Text="发表讨论" onclick="Btnword_Click" BorderStyle="None" CssClass="buttonimg td-submit" Width="80px" />
                            <div style="margin-top: 14px;">
                                <anthem:Label ID="Labeldiscuss" runat="server" SkinID="LabelMsgRed"></anthem:Label>
                            </div>
                        </div>
                    </div>

                    <div class="td-card td-absent-card">
                        <div class="td-absent-head">
                            <span class="td-title-icon td-title-icon-amber">
                                <svg viewBox="0 0 24 24"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                            </span>
                            <div class="td-absent-meta">
                                <span class="td-absent-badge">
                                    <svg viewBox="0 0 24 24"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                    未参与
                                </span>
                                <span>以下同学尚未参与讨论</span>
                            </div>
                        </div>
                        <div class="td-absent-list">
                            <anthem:Label ID="Labelnostu" runat="server"></anthem:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="outerdiv">
        <div id="innerdiv">
            <img id="bigimg" src="" alt="" />
        </div>
    </div>
</asp:Content>
