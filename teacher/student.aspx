<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_student, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        /* ===== 学生管理页面美化 ===== */
        .stu-page { width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif; }

        /* 页面标题栏 */
        .stu-page-header {
            display: flex; align-items: center; flex-wrap: wrap; gap: 12px;
            margin-bottom: 16px;
        }
        .stu-page-title {
            font-size: 22px; font-weight: 700; color: #1e293b;
            display: flex; align-items: center; gap: 10px; margin: 0;
            flex-shrink: 0; white-space: nowrap;
        }
        .stu-page-title svg { color: #6366f1; flex-shrink: 0; }

        /* 通用卡片 */
        .stu-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            border: 1px solid #e8ecf1; padding: 16px 20px; margin-bottom: 14px;
        }

        /* 筛选区 */
        .stu-filter-bar {
            display: flex; align-items: center; flex-wrap: wrap; gap: 10px;
            margin-left: auto;
        }
        .stu-filter-bar > label {
            font-size: 13px; font-weight: 600; color: #475569;
            line-height: 1; white-space: nowrap;
        }
        .stu-filter-bar > span {
            font-size: 13px; color: #64748b; line-height: 1; white-space: nowrap;
        }
        .stu-filter-bar select {
            padding: 6px 12px; border: 1px solid #d1d5db; border-radius: 8px;
            font-size: 13px; color: #334155; background: #f8fafc;
            outline: none; transition: all 0.2s; cursor: pointer;
            appearance: auto; min-width: 60px;
        }
        .stu-filter-bar select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        .stu-filter-info { font-size: 13px; color: #64748b; white-space: nowrap; }
        .stu-btn-add {
            display: inline-flex !important; align-items: center; gap: 6px;
            padding: 8px 18px !important; background: linear-gradient(135deg, #6366f1, #818cf8) !important;
            color: #fff !important; border-radius: 8px !important; font-size: 13px !important; font-weight: 600 !important;
            text-decoration: none !important; transition: all 0.2s; border: none !important; cursor: pointer;
            box-shadow: 0 2px 8px rgba(99,102,241,0.25);
            white-space: nowrap; flex-shrink: 0;
            width: auto !important; height: auto !important;
            line-height: 1.4 !important; text-align: center;
        }
        .stu-btn-add:hover { background: linear-gradient(135deg, #4f46e5, #6366f1) !important; box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px); }
        .stu-btn-add svg { width: 16px; height: 16px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; flex-shrink: 0; vertical-align: middle; }

        /* ===== 工具栏全新设计 ===== */
        .stu-toolbar-panel {
            display: flex; flex-direction: column; gap: 0;
            background: #fff; border-radius: 12px;
            border: 1px solid #e8ecf1; margin-bottom: 14px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        /* 操作按钮行 */
        .stu-tb-actions {
            display: flex; align-items: stretch; flex-wrap: wrap;
            border-bottom: 1px solid #f1f5f9;
        }
        .stu-tb-group {
            display: flex; align-items: center; gap: 8px;
            padding: 12px 18px;
            border-right: 1px solid #f1f5f9;
            position: relative;
        }
        .stu-tb-group:last-child { border-right: none; }
        .stu-tb-group-icon {
            width: 30px; height: 30px; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .stu-tb-group-icon svg {
            width: 16px; height: 16px; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .stu-tb-group-icon.blue { background: #eef2ff; }
        .stu-tb-group-icon.blue svg { stroke: #6366f1; }
        .stu-tb-group-icon.emerald { background: #ecfdf5; }
        .stu-tb-group-icon.emerald svg { stroke: #059669; }
        .stu-tb-group-icon.amber { background: #fffbeb; }
        .stu-tb-group-icon.amber svg { stroke: #d97706; }
        .stu-tb-group label {
            font-size: 12px; color: #64748b; white-space: nowrap;
        }

        /* 工具栏按钮 — 用 !important 覆盖主题样式 */
        .stu-tb-group input[type="submit"] {
            padding: 6px 14px !important; border: none !important; border-radius: 6px !important;
            font-size: 12px !important; font-weight: 600 !important; cursor: pointer;
            transition: all 0.15s; white-space: nowrap;
            line-height: 1.4 !important; vertical-align: middle;
            height: auto !important; margin: 0 !important;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .stu-toolbar-panel .btn-blue {
            background: #eef2ff !important; color: #4f46e5 !important;
        }
        .stu-toolbar-panel .btn-blue:hover { background: #e0e7ff !important; }
        .stu-toolbar-panel .btn-emerald {
            background: #ecfdf5 !important; color: #047857 !important;
        }
        .stu-toolbar-panel .btn-emerald:hover { background: #d1fae5 !important; }
        .stu-toolbar-panel .btn-amber {
            background: #fffbeb !important; color: #b45309 !important;
        }
        .stu-toolbar-panel .btn-amber:hover { background: #fef3c7 !important; }

        .stu-tb-group input[type="text"] {
            padding: 5px 8px !important; border: 1px solid #e2e8f0 !important; border-radius: 6px !important;
            font-size: 12px !important; color: #334155; background: #fffbeb !important;
            outline: none; transition: border 0.2s; width: 70px !important;
            text-align: center; line-height: 1.4 !important; vertical-align: middle;
            height: auto !important; margin: 0 !important;
        }
        .stu-tb-group input[type="text"]:focus {
            border-color: #818cf8; box-shadow: 0 0 0 2px rgba(99,102,241,0.1);
        }
        .stu-tb-group select {
            padding: 5px 8px !important; border: 1px solid #e2e8f0 !important; border-radius: 6px !important;
            font-size: 12px !important; color: #334155; background: #f8fafc !important;
            outline: none; cursor: pointer;
            line-height: 1.4 !important; vertical-align: middle;
            height: auto !important; margin: 0 !important;
        }
        .stu-tb-group label {
            font-size: 12px; color: #64748b; white-space: nowrap;
            line-height: 30px; vertical-align: middle;
        }

        /* 设置行 */
        .stu-tb-settings {
            display: flex; align-items: center; flex-wrap: wrap; gap: 14px;
            padding: 10px 18px;
            background: linear-gradient(180deg, #fafbfc, #f8fafc);
        }
        .stu-tb-settings .stbs-tag {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;
            white-space: nowrap;
        }
        .stu-tb-settings .stbs-tag.tag-indigo {
            background: #eef2ff; color: #4f46e5;
        }
        .stu-tb-settings .stbs-tag.tag-slate {
            background: #f1f5f9; color: #475569;
        }
        .stu-tb-settings .stbs-tag svg {
            width: 13px; height: 13px; stroke: currentColor;
            fill: none; stroke-width: 2; stroke-linecap: round;
        }
        .stu-tb-settings .stbs-sep {
            width: 1px; height: 16px; background: #e2e8f0;
        }
        .stu-tb-settings input[type="checkbox"] {
            width: 14px; height: 14px; accent-color: #6366f1;
            cursor: pointer; vertical-align: middle; margin-right: 1px;
        }
        .stu-tb-settings label {
            cursor: pointer; font-size: 12px; color: #475569;
            white-space: nowrap;
        }
        .stu-tb-settings span { font-size: 12px; color: #64748b; }

        /* 表格区 */
        .stu-table-wrap { overflow-x: auto; }
        .stu-table-wrap table {
            width: 100%; border-collapse: separate; border-spacing: 0;
            font-size: 13px;
        }
        .stu-table-wrap table th {
            background: linear-gradient(180deg, #f8fafc, #f1f5f9) !important; color: #475569 !important;
            font-weight: 600; font-size: 12px;
            letter-spacing: 0.3px; padding: 12px 16px !important;
            border-bottom: 2px solid #e2e8f0 !important;
            text-align: center; white-space: nowrap;
            position: sticky; top: 0; z-index: 2;
        }
        .stu-table-wrap table td {
            padding: 10px 16px !important; color: #334155;
            border-bottom: 1px solid #f1f5f9 !important;
            text-align: center; vertical-align: middle;
            background: transparent !important;
            transition: background 0.1s;
        }
        .stu-table-wrap table tr:hover td {
            background: #f8fafc !important;
        }
        .stu-table-wrap table tr:last-child td { border-bottom: none !important; }
        .stu-table-wrap table a {
            color: #6366f1 !important; text-decoration: none; font-weight: 500;
            transition: color 0.15s;
        }
        .stu-table-wrap table a:hover { color: #4f46e5 !important; text-decoration: underline; }

        /* 分页 */
        .stu-pager {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 6px; padding: 10px 16px; font-size: 13px; color: #64748b;
        }
        .stu-pager a {
            display: inline-flex; align-items: center; justify-content: center;
            padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 500;
            color: #475569 !important; background: #fff; border: 1px solid #e2e8f0;
            text-decoration: none !important; transition: all 0.15s; cursor: pointer;
        }
        .stu-pager a:hover {
            background: #eef2ff; border-color: #c7d2fe; color: #4f46e5 !important;
        }
        .stu-pager span { color: #6366f1; font-weight: 600; }

        /* 消息 */
        .stu-msg { margin-top: 10px; font-size: 13px; color: #059669; font-weight: 500; text-align: center; }

        /* ===== 修改密码弹窗 ===== */
        .chpwd-overlay {
            display: none; position: fixed;
            top: 0; right: 0; bottom: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,.48); backdrop-filter: blur(3px);
            z-index: 9999; align-items: center; justify-content: center;
        }
        .chpwd-modal {
            width: 380px; max-width: 92vw;
            background: #fff; border-radius: 16px;
            box-shadow: 0 24px 64px rgba(0,0,0,.22);
            overflow: hidden;
            animation: chpwdIn .26s cubic-bezier(.34,1.4,.64,1);
        }
        @keyframes chpwdIn {
            from { opacity:0; transform:scale(.88) translateY(12px); }
            to   { opacity:1; transform:scale(1) translateY(0); }
        }
        .chpwd-head {
            background: linear-gradient(135deg,#6366f1,#818cf8);
            padding: 18px 20px; display: flex; align-items: center; gap: 14px;
        }
        .chpwd-head-ico {
            width: 42px; height: 42px; border-radius: 12px; flex-shrink: 0;
            background: rgba(255,255,255,.2); border: 1.5px solid rgba(255,255,255,.3);
            display: flex; align-items: center; justify-content: center;
        }
        .chpwd-head-ico svg {
            width: 22px; height: 22px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .chpwd-head-info { flex: 1; }
        .chpwd-head-title { font-size: 16px; font-weight: 700; color: #fff; }
        .chpwd-head-sub { font-size: 12px; color: rgba(255,255,255,.85); margin-top: 3px; }
        .chpwd-head-sub strong { color: #fff; }
        .chpwd-close-btn {
            width: 30px; height: 30px; border-radius: 8px; border: none;
            background: rgba(255,255,255,.15); cursor: pointer; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center; transition: background .15s;
        }
        .chpwd-close-btn:hover { background: rgba(255,255,255,.3); }
        .chpwd-close-btn svg { width: 16px; height: 16px; stroke: #fff; fill: none; stroke-width: 2.5; stroke-linecap: round; }
        .chpwd-body { padding: 20px; display: flex; flex-direction: column; gap: 14px; }
        .chpwd-field { display: flex; flex-direction: column; gap: 5px; }
        .chpwd-field label { font-size: 12px; font-weight: 600; color: #374151; }
        .chpwd-field input {
            padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; font-family: inherit; outline: none; color: #1e293b;
            transition: border-color .2s, box-shadow .2s; width: 100%; box-sizing: border-box;
        }
        .chpwd-field input:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
        .chpwd-msg-area { min-height: 18px; font-size: 12px; font-weight: 500; }
        .chpwd-msg-ok  { color: #059669; }
        .chpwd-msg-err { color: #dc2626; }
        .chpwd-foot {
            padding: 14px 20px; border-top: 1px solid #f1f5f9;
            display: flex; justify-content: flex-end; gap: 10px;
        }
        .chpwd-btn {
            padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 600;
            font-family: inherit; cursor: pointer; border: none; transition: all .15s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .chpwd-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
        .chpwd-btn-cancel { background: #f1f5f9; color: #64748b; }
        .chpwd-btn-cancel:hover { background: #e2e8f0; }
        .chpwd-btn-save {
            background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
            box-shadow: 0 2px 8px rgba(99,102,241,.3);
        }
        .chpwd-btn-save:hover { box-shadow: 0 4px 12px rgba(99,102,241,.4); transform: translateY(-1px); }
        .chpwd-btn-save:disabled { background: #c7d2fe; box-shadow: none; transform: none; cursor: not-allowed; }
        /* 列按钮 */
        .stu-chpwd-link {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 9px; border-radius: 6px; font-size: 12px; font-weight: 600;
            color: #6366f1 !important; background: #eef2ff;
            border: 1px solid #c7d2fe; cursor: pointer; text-decoration: none !important;
            transition: all .15s; white-space: nowrap;
        }
        .stu-chpwd-link:hover { background: #e0e7ff; border-color: #818cf8; color: #4f46e5 !important; }
        .stu-chpwd-link svg { width: 12px; height: 12px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    </style>

    <div class="stu-page">
        <!-- 页面标题 + 筛选 -->
        <div class="stu-page-header">
            <div class="stu-page-title">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
                学生管理
            </div>
            <div class="stu-filter-bar">
                <label>班级筛选</label>
                <asp:DropDownList ID="DDLgrade" runat="server"
                    Width="60px" EnableTheming="True" AutoPostBack="True"
                    onselectedindexchanged="DDLgrade_SelectedIndexChanged" />
                <span style="font-size:13px;color:#64748b;">年级</span>
                <asp:DropDownList ID="DDLclass" runat="server"
                    Width="60px" EnableTheming="True" AutoPostBack="True"
                    onselectedindexchanged="DDLclass_SelectedIndexChanged" />
                <span style="font-size:13px;color:#64748b;">班级</span>
                <asp:Label ID="Label1" runat="server" CssClass="stu-filter-info"></asp:Label>
                <asp:HyperLink ID="HkaddStu" runat="server" CssClass="stu-btn-add" SkinID="HyperLinkBtn">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    添加学生
                </asp:HyperLink>
            </div>
        </div>

        <!-- 操作工具栏 + 权限设置 -->
        <div class="stu-toolbar-panel">
            <div class="stu-tb-actions">
                <!-- 密码管理 -->
                <div class="stu-tb-group">
                    <div class="stu-tb-group-icon blue">
                        <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    </div>
                    <asp:Button ID="BtnSpwdInit" runat="server" OnClick="BtnSpwdInit_Click" CssClass="btn-blue"
                        Text="初始化密码" SkinID="BtnNormal" ToolTip="将本班所有学生的密码初始为12345(或右侧自定义密码)" />
                    <asp:TextBox ID="TextBoxPwd" runat="server" SkinID="TextBoxNum"
                        Width="70px">12345</asp:TextBox>
                    <asp:Button ID="BtnSpell" runat="server" OnClick="BtnSpell_Click" CssClass="btn-blue"
                        Text="转拼音" SkinID="BtnNormal" ToolTip="将当前为原初始化密码的学生密码转换为其姓名拼音缩写" />
                </div>
                <!-- 分组管理 -->
                <div class="stu-tb-group">
                    <div class="stu-tb-group-icon emerald">
                        <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                    <label>上限</label>
                    <asp:DropDownList ID="DDLgroupMax" runat="server"
                        Width="46px" EnableTheming="True" AutoPostBack="True"
                        onselectedindexchanged="DDLgroupMax_SelectedIndexChanged">
                        <asp:ListItem>0</asp:ListItem>
                        <asp:ListItem>1</asp:ListItem>
                        <asp:ListItem>2</asp:ListItem>
                        <asp:ListItem>3</asp:ListItem>
                        <asp:ListItem>4</asp:ListItem>
                        <asp:ListItem>5</asp:ListItem>
                        <asp:ListItem Selected="True">6</asp:ListItem>
                        <asp:ListItem>7</asp:ListItem>
                        <asp:ListItem>8</asp:ListItem>
                        <asp:ListItem></asp:ListItem>
                    </asp:DropDownList>
                    <asp:Button ID="BtnNoGroup" runat="server" OnClick="BtnNoGroup_Click" CssClass="btn-emerald"
                        Text="解除分组" SkinID="BtnNormal" ToolTip="一键将本班所有学生解除分组" />
                    <asp:Button ID="Btngroups" runat="server" SkinID="BtnNormal" CssClass="btn-emerald"
                        Text="分组管理" onclick="Btngroups_Click" />
                </div>
                <!-- 导出/恢复 -->
                <div class="stu-tb-group">
                    <div class="stu-tb-group-icon amber">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    </div>
                    <asp:Button ID="BtnExcel" runat="server" OnClick="BtnExcel_Click" CssClass="btn-amber"
                        Text="导出学生" SkinID="BtnNormal" ToolTip="将所有学生的基本信息导出Excel" />
                    <asp:Button ID="BtnRevive" runat="server" SkinID="BtnNormal" CssClass="btn-amber"
                        Text="恢复学生" onclick="BtnRevive_Click" />
                </div>
            </div>
            <!-- 设置行 -->
            <div class="stu-tb-settings">
                <span class="stbs-tag tag-indigo">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                    注册
                </span>
                <asp:CheckBox ID="Ckreg" runat="server" Text="允许在线注册"
                    oncheckedchanged="Ckreg_CheckedChanged" AutoPostBack="True" />
                <div class="stbs-sep"></div>
                <span class="stbs-tag tag-slate">
                    <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    权限
                </span>
                <asp:CheckBox ID="Ckclass" runat="server" Text="班级"
                    ToolTip="允许学生修改个人资料中的班级" oncheckedchanged="Ckclass_CheckedChanged"
                    AutoPostBack="True" />
                <asp:CheckBox ID="Ckphoto" runat="server" Text="相片"
                    ToolTip="允许学生修改个人资料中的相片" oncheckedchanged="Ckphoto_CheckedChanged"
                    AutoPostBack="True" />
                <asp:CheckBox ID="Cksex" runat="server" Text="性别" ToolTip="允许学生修改个人资料中的性别"
                    oncheckedchanged="Cksex_CheckedChanged" AutoPostBack="True" />
                <asp:CheckBox ID="Ckname" runat="server" Text="姓名" ToolTip="允许学生修改个人资料中的姓名"
                    oncheckedchanged="Ckname_CheckedChanged" AutoPostBack="True" />
            </div>
        </div>

        <!-- 学生列表卡片 -->
        <div class="stu-card" style="padding:0;">
            <div class="stu-table-wrap">
            <asp:GridView ID="GVStudent" runat="server" AutoGenerateColumns="False" Width="100%"
                CellPadding="3" PageSize="15"
                OnRowDataBound="GVStudent_RowDataBound" EnableModelValidation="True" DataKeyNames="Sid"
                onrowcommand="GVStudent_RowCommand"
                ForeColor="#334155" GridLines="None" AllowPaging="True"
                onpageindexchanging="GVStudent_PageIndexChanging"
                Font-Names="'Microsoft YaHei', Arial" Font-Size="13px" >
                <AlternatingRowStyle BackColor="Transparent" />
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:BoundField DataField="Snum" HeaderText="学号">
                        <ControlStyle Width="30px" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="密码">
                        <ItemTemplate>
                            <asp:Label ID="Labelpwd" runat="server" Text='******' ToolTip='<%# Bind("Spwd") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:ImageButton ID="ImageButton1" runat="server" CausesValidation="False"
                                CommandArgument='<%# Eval("Sid") %>' CommandName="ChangePwd"
                                ImageUrl="~/images/refresh.gif" Text="更新" ToolTip="自动更新密码" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="修改密码">
                        <ItemTemplate>
                            <a class="stu-chpwd-link" href="javascript:void(0)"
                               data-sid='<%# Eval("Sid") %>'
                               data-name='<%# Eval("Sname") %>'
                               onclick="chpwdOpenFrom(this)">
                                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                修改密码
                            </a>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                    <asp:BoundField DataField="Sclass" HeaderText="班级" />
                    <asp:TemplateField HeaderText="姓名">
                        <ItemTemplate>
                            <asp:HyperLink ID="Hlname" runat="server"
                                Text='<%# Eval("Sname") %>' ToolTip='<%# Eval("Sid") %>' ForeColor="#6366f1"></asp:HyperLink>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="Sex" HeaderText="性别" />
                    <asp:TemplateField ShowHeader="False" HeaderText="小组">
                        <ItemTemplate>
                            <asp:ImageButton ID="ImageBtnGroup" runat="server" CausesValidation="False"
                                CommandArgument='<%# Eval("Sid") %>' CommandName="ChangeGroup"
                                ImageUrl="~/images/gcard.gif" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="组号" ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkBtnQuit" runat="server" CausesValidation="false"
                                CommandArgument='<%# Eval("Sid") %>' CommandName="QuitGroup" Text='<%# Eval("Sgroup") %>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:HyperLinkField DataNavigateUrlFields="Snum"
                        DataNavigateUrlFormatString="studentwork.aspx?snum={0}" DataTextField="Sscore"
                        HeaderText="成绩" Target="_blank" />
                    <asp:HyperLinkField DataNavigateUrlFields="Snum"
                        DataNavigateUrlFormatString="studentworks.aspx?snum={0}" Text="浏览"
                        HeaderText="作品" Target="_blank" />
                    <asp:BoundField DataField="Sattitude" HeaderText="表现" />
                    <asp:HyperLinkField DataNavigateUrlFields="Sid,Sgrade,Sclass" DataNavigateUrlFormatString="studentdel.aspx?sid={0}&amp;sgrade={1}&amp;sclass={2}"
                        Text="删除" />
                    <asp:TemplateField Visible="False">
                        <ItemTemplate>
                            <asp:Label ID="LabelSleader" runat="server" Text='<%# Bind("Sleader") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle BackColor="#f8fafc" ForeColor="#475569" HorizontalAlign="Center" />
                <pagertemplate>
                    <div class="stu-pager">
                        第 <span><asp:Label ID="lblPageIndex" runat="server"
                            text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1  %>" /></span>
                        页 / 共 <span><asp:Label ID="lblPageCount" runat="server"
                            text="<%# ((GridView)Container.Parent.Parent).PageCount  %>" /></span> 页
                        <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False"
                            commandargument="First" commandname="Page" Font-Underline="False"
                            text="首页" />
                        <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False"
                            commandargument="Prev" commandname="Page" Font-Underline="False"
                            text="上一页" />
                        <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False"
                            commandargument="Next" commandname="Page" Font-Underline="False"
                            text="下一页" />
                        <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False"
                            commandargument="Last" commandname="Page" Font-Underline="False"
                            text="尾页" />
                    </div>
                </pagertemplate>
                <FooterStyle BackColor="#f8fafc" Font-Bold="True" ForeColor="#64748b" />
                <HeaderStyle BackColor="#f8fafc" Font-Bold="True" ForeColor="#64748b" />
                <RowStyle BackColor="Transparent" />
                <SelectedRowStyle BackColor="#eef2ff" Font-Bold="True" ForeColor="#4f46e5" />
            </asp:GridView>
            </div>
        </div>

        <!-- 消息提示 -->
        <div class="stu-msg">
            <asp:Label ID="Labelmsg" runat="server"></asp:Label>
        </div>
    </div>

    <!-- 修改密码弹窗 -->
    <div class="chpwd-overlay" id="chpwdOverlay" onclick="if(event.target===this)chpwdClose()">
        <div class="chpwd-modal">
            <div class="chpwd-head">
                <div class="chpwd-head-ico">
                    <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <div class="chpwd-head-info">
                    <div class="chpwd-head-title">修改密码</div>
                    <div class="chpwd-head-sub">为 <strong id="chpwdStuName">--</strong> 设置新密码</div>
                </div>
                <button class="chpwd-close-btn" onclick="chpwdClose()" title="关闭">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
            </div>
            <div class="chpwd-body">
                <div class="chpwd-field">
                    <label for="chpwdNew">新密码</label>
                    <input type="password" id="chpwdNew" placeholder="请输入新密码（至少3位）" autocomplete="new-password" />
                </div>
                <div class="chpwd-field">
                    <label for="chpwdConfirm">确认密码</label>
                    <input type="password" id="chpwdConfirm" placeholder="再次输入新密码" autocomplete="new-password" />
                </div>
                <div class="chpwd-msg-area" id="chpwdMsg"></div>
            </div>
            <div class="chpwd-foot">
                <button class="chpwd-btn chpwd-btn-cancel" onclick="chpwdClose()">取消</button>
                <button class="chpwd-btn chpwd-btn-save" id="chpwdSaveBtn" onclick="chpwdSave()">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    保存
                </button>
            </div>
        </div>
    </div>

    <link href="../js/tinybox.css?v=2" rel="stylesheet" type="text/css" />
    <script src="../js/tinybox.js?v=2" type="text/javascript"></script>
    <script type="text/javascript">
        function stuShow(d, g, c) {
            var urlat = "../teacher/studentshow.aspx?sid=" + d + "&sgrade=" + g + "&sclass=" + c;
            TINY.box.show({ iframe: urlat, boxid: 'frameless', width: 660, height: 380, fixed: true, animate: 0, mask: 0, closejs: function () { closeJS() } })
        }
        function stuAdd(g, c) {
            var urlad = "../teacher/studentadd.aspx?sgrade=" + g + "&sclass=" + c;
TINY.box.show({ iframe: urlad, boxid: 'frameless', width: 660, height: 560, fixed: true, animate: 0, mask: 0, closejs: function () { closeJS() } })
        }

        // ===== 修改密码弹窗 =====
        var _chpwdSid = 0;

        function chpwdOpenFrom(el) {
            chpwdOpen(el.getAttribute('data-sid'), el.getAttribute('data-name'));
        }
        function chpwdOpen(sid, name) {
            _chpwdSid = sid;
            document.getElementById('chpwdStuName').textContent = name || '--';
            document.getElementById('chpwdNew').value = '';
            document.getElementById('chpwdConfirm').value = '';
            chpwdSetMsg('', '');
            var btn = document.getElementById('chpwdSaveBtn');
            btn.disabled = false;
            btn.innerHTML = '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg> 保存';
            var ov = document.getElementById('chpwdOverlay');
            if (ov.parentNode !== document.body) document.body.appendChild(ov);
            ov.style.display = 'flex';
            setTimeout(function () { document.getElementById('chpwdNew').focus(); }, 60);
        }
        function chpwdClose() {
            document.getElementById('chpwdOverlay').style.display = 'none';
        }
        function chpwdSetMsg(text, type) {
            var el = document.getElementById('chpwdMsg');
            el.textContent = text;
            el.className = 'chpwd-msg-area' + (type ? ' chpwd-msg-' + type : '');
        }
        function chpwdSave() {
            var newpwd = document.getElementById('chpwdNew').value;
            var confirm = document.getElementById('chpwdConfirm').value;
            if (!newpwd || newpwd.trim().length === 0) { chpwdSetMsg('请输入新密码', 'err'); return; }
            if (newpwd.trim().length < 3) { chpwdSetMsg('密码至少3位', 'err'); return; }
            if (newpwd !== confirm) { chpwdSetMsg('两次密码输入不一致', 'err'); return; }
            var btn = document.getElementById('chpwdSaveBtn');
            btn.disabled = true;
            btn.textContent = '保存中...';
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'changestupwd.ashx', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) return;
                btn.disabled = false;
                btn.innerHTML = '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg> 保存';
                try {
                    var res = JSON.parse(xhr.responseText);
                    if (res.ok) {
                        chpwdSetMsg('密码修改成功！', 'ok');
                        setTimeout(chpwdClose, 1200);
                    } else {
                        chpwdSetMsg(res.msg || '保存失败', 'err');
                    }
                } catch (e) {
                    chpwdSetMsg('请求失败，请重试', 'err');
                }
            };
            xhr.send('sid=' + encodeURIComponent(_chpwdSid) + '&newpwd=' + encodeURIComponent(newpwd.trim()));
        }
        // Enter 键提交
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && document.getElementById('chpwdOverlay').style.display === 'flex') {
                chpwdSave();
            }
            if (e.key === 'Escape') chpwdClose();
        });
    </script>
</asp:Content>

