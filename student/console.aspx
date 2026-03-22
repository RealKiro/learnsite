<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" inherits="Student_console, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
    <asp:Label ID="LabelCid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="LabelNid" runat="server" Visible="False"></asp:Label>

    <link href="../kindeditor/themes/me/me.css" rel="stylesheet" type="text/css" />
    <script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
    <script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>

    <style>
        /* ===== console.aspx 页面专属样式 ===== */

        /* 修复：StyleSheet.css 中 .placeauto 被 calc(100%-180px) 双重压缩，
           此处强制撑满 body 内容区，让 console-wrapper 获得完整宽度 */
        .placeauto {
            max-width: 100% !important;
            width: 100% !important;
            box-sizing: border-box !important;
        }

        .console-wrapper {
            display: flex;
            gap: 28px;
            max-width: 100%;
            margin: 16px auto;
            padding: 0 12px;
            align-items: flex-start;
            animation: consoleFadeIn 0.5s ease;
        }
        @keyframes consoleFadeIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* 左栏 - 课程内容 */
        .console-left {
            flex: 1;
            min-width: 0;
        }
        .console-left .cl-title-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px 16px 0 0;
            padding: 32px 36px;
            color: #fff;
            position: relative;
            overflow: hidden;
        }
        .console-left .cl-title-card::before {
            content: '';
            position: absolute;
            top: -40%; left: -40%;
            width: 180%; height: 180%;
            background: radial-gradient(circle, rgba(255,255,255,0.12) 0%, transparent 65%);
            pointer-events: none;
        }
        .console-left .cl-title-card .cl-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 40px; height: 40px;
            background: rgba(255,255,255,0.2);
            border-radius: 10px;
            margin-bottom: 14px;
        }
        .console-left .cl-title-card .cl-icon svg {
            width: 22px; height: 22px;
            stroke: #fff; fill: none;
            stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
        }
        .console-left .cl-title-card h2 {
            margin: 0;
            font-size: 22px;
            font-weight: 700;
            font-family: "Microsoft YaHei", "微软雅黑", sans-serif;
            position: relative;
            z-index: 1;
        }

        .console-left .cl-content-card {
            background: #fff;
            border-radius: 0 0 16px 16px;
            padding: 36px 40px;
            border: 1px solid #e8ecf1;
            min-height: 420px;
            line-height: 1.85;
            font-size: 15.5px;
            color: #334155;
            word-wrap: break-word;
            font-family: "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
        }
        .console-left .cl-content-card img {
            max-width: 100%; height: auto;
            border-radius: 8px;
            margin: 12px 0;
        }
        .console-left .cl-content-card table {
            width: 100%; border-collapse: collapse;
            margin: 16px 0; border-radius: 8px;
            overflow: hidden;
        }
        .console-left .cl-content-card table td,
        .console-left .cl-content-card table th {
            padding: 10px 14px; border: 1px solid #e2e8f0;
        }
        .console-left .cl-content-card table th {
            background: #f8fafc; font-weight: 600; color: #1e293b;
        }

        /* 右栏 - 测评面板 */
        .console-right {
            width: 440px;
            flex-shrink: 0;
        }

        /* 测评卡片 */
        .cr-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid #e8ecf1;
            overflow: hidden;
            margin-bottom: 20px;
        }
        .cr-card-header {
            background: linear-gradient(135deg, #f0f4ff 0%, #faf5ff 100%);
            padding: 18px 22px;
            border-bottom: 1px solid #e8ecf1;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .cr-card-header .cr-hicon {
            width: 32px; height: 32px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .cr-card-header .cr-hicon svg {
            width: 16px; height: 16px;
            stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .cr-card-header h3 {
            margin: 0; font-size: 15px; font-weight: 700;
            color: #1e293b;
            font-family: "Microsoft YaHei", "微软雅黑", sans-serif;
        }
        .cr-card-body {
            padding: 20px 22px;
        }

        /* GridView 美化 */
        .cr-card-body .cr-grid-wrap {
            border-radius: 10px;
            overflow: hidden;
            border: 1px solid #e5e7eb;
            margin-bottom: 20px;
        }
        .cr-card-body table {
            width: 100%;
            border-collapse: collapse;
        }
        .cr-card-body table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            font-size: 13px;
            font-weight: 600;
            padding: 11px 14px;
            text-align: center;
            border: none;
        }
        .cr-card-body table td {
            padding: 10px 14px;
            font-size: 13.5px;
            color: #334155;
            border-bottom: 1px solid #f1f5f9;
            text-align: center;
        }
        .cr-card-body table tr:last-child td {
            border-bottom: none;
        }
        .cr-card-body table tr:hover td {
            background: #fafaff;
        }

        /* 操作按钮区 */
        .cr-actions {
            text-align: center;
            padding: 6px 0 4px;
        }
        .cr-actions input[type="submit"] {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
            color: #fff !important;
            border: none !important;
            border-radius: 10px;
            padding: 12px 36px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            font-family: "Microsoft YaHei", "微软雅黑", sans-serif;
        }
        .cr-actions input[type="submit"]:hover {
            transform: translateY(-2px);
            opacity: 0.9;
        }

        /* 状态卡片 */
        .cr-status-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid #e8ecf1;
            padding: 24px;
            text-align: center;
            margin-bottom: 20px;
        }
        .cr-status-card .cr-clock-wrap {
            margin-bottom: 16px;
        }
        .cr-status-card .cr-clock-wrap input[type="image"] {
            transition: transform 0.2s;
        }
        .cr-status-card .cr-clock-wrap input[type="image"]:hover {
            transform: scale(1.05);
        }
        .cr-status-card .cr-pass-wrap img {
            max-width: 160px;
            height: auto;
            margin: 8px 0;
        }

        /* 报告链接 */
        .cr-report-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid #e8ecf1;
            padding: 20px;
            text-align: center;
        }
        .cr-report-card a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, #f0f4ff 0%, #faf5ff 100%);
            color: #5b21b6 !important;
            text-decoration: none !important;
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s;
            border: 1px solid #e0e7ff;
        }
        .cr-report-card a:hover {
            background: linear-gradient(135deg, #e0e7ff 0%, #f3e8ff 100%);
            transform: translateY(-1px);
        }

        /* 响应式 */
        @media (max-width: 1100px) {
            .console-wrapper {
                flex-direction: column;
                padding: 0 10px;
            }
            .console-right {
                width: 100%;
            }
        }
    </style>

    <div class="console-wrapper">
        <!-- 左栏：课程内容 -->
        <div class="console-left">
            <div class="cl-title-card">
                <div class="cl-icon">
                    <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                </div>
                <h2><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h2>
            </div>
            <div class="cl-content-card">
                <div id="Mcontent" class="coursecontent" runat="server" style="padding:0; box-shadow:none; border:none; min-height:auto;"></div>
            </div>
        </div>

        <!-- 右栏：测评面板 -->
        <div class="console-right">
            <!-- 测评成绩卡片 -->
            <div class="cr-card">
                <div class="cr-card-header">
                    <div class="cr-hicon">
                        <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                    </div>
                    <h3>测评成绩</h3>
                </div>
                <div class="cr-card-body">
                    <div class="cr-grid-wrap">
                        <asp:GridView ID="GVSolve" runat="server" EnableModelValidation="True"
                            AutoGenerateColumns="False" onrowdatabound="GVSolve_RowDataBound"
                            Font-Size="11pt" GridLines="None" Width="100%">
                            <Columns>
                                <asp:BoundField HeaderText="题目" />
                                <asp:TemplateField HeaderText="得分">
                                    <ItemTemplate>
                                        <asp:Label ID="Labelscore" runat="server" Text='<%# Bind("Vscore") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Label ID="Labelflag" runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div class="cr-actions">
                        <asp:Button ID="BtnIdle" runat="server" Font-Bold="True"
                            Text="开始测评" onclick="BtnIdle_Click" />
                    </div>
                </div>
            </div>

            <!-- 测评状态卡片 -->
            <div class="cr-status-card">
                <div class="cr-clock-wrap">
                    <asp:ImageButton ID="Btnclock" runat="server" ImageUrl="~/images/clock.gif"
                        onclick="Btnclock_Click" />
                </div>
                <div class="cr-pass-wrap">
                    <asp:Image ID="Imagepass" runat="server" ImageUrl="~/images/pass.png" />
                </div>
            </div>

            <!-- 班级报告卡片 -->
            <div class="cr-report-card">
                <asp:HyperLink ID="Hlsolve" runat="server" Target="_blank" Font-Size="11pt">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    班级测评报告
                </asp:HyperLink>
            </div>
        </div>
    </div>
</asp:Content>

