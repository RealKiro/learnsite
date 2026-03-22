<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_package, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        .pkg-page { max-width: 1400px; margin: 0 auto; }
        .pkg-page .page-title-bar {
            display: flex; align-items: center; margin-bottom: 20px;
        }
        .pkg-page .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .pkg-page .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .pkg-page .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }

        /* 双栏布局 */
        .pkg-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
            margin-bottom: 20px;
        }
        @media (max-width: 900px) {
            .pkg-grid { grid-template-columns: 1fr; }
        }

        /* 卡片通用 */
        .pkg-card {
            background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            overflow: hidden;
        }

        /* 左侧：学案信息卡片 */
        .pkg-hero {
            padding: 28px; display: flex; flex-direction: column; height: 100%;
        }
        .pkg-hero .hero-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 20px;
            background: #eef2ff; color: #6366f1;
            font-size: 12px; font-weight: 600; width: fit-content;
            margin-bottom: 16px;
        }
        .pkg-hero .hero-badge svg {
            width: 14px; height: 14px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .pkg-hero .hero-title {
            font-size: 20px; font-weight: 700; color: #1e293b;
            margin-bottom: 6px; word-break: break-all;
        }
        .pkg-hero .hero-id {
            font-size: 13px; color: #94a3b8; margin-bottom: 20px;
        }
        .pkg-hero .hero-id strong { color: #64748b; font-weight: 600; }
        .pkg-hero .hero-actions {
            display: flex; align-items: center; gap: 12px;
            margin-top: auto; padding-top: 16px;
            border-top: 1px solid #f1f5f9;
        }
        .pkg-hero .pkg-download-panel {
            margin-top: 16px; padding: 14px 18px;
            background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px;
        }
        .pkg-hero .pkg-download-panel span { font-size: 13px; color: #166534; }
        .pkg-hero .pkg-msg { font-size: 13px; margin-top: 10px; }

        /* 右侧：操作指南卡片 */
        .pkg-guide {
            padding: 28px; display: flex; flex-direction: column; height: 100%;
        }
        .pkg-guide h3 {
            font-size: 16px; font-weight: 700; color: #1e293b; margin: 0 0 16px;
            display: flex; align-items: center; gap: 8px;
        }
        .pkg-guide h3 svg {
            width: 20px; height: 20px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .pkg-guide .step-list { list-style: none; margin: 0; padding: 0; }
        .pkg-guide .step-item {
            display: flex; gap: 14px; margin-bottom: 16px;
            position: relative;
        }
        .pkg-guide .step-item:last-child { margin-bottom: 0; }
        .pkg-guide .step-num {
            width: 28px; height: 28px; border-radius: 50%;
            background: linear-gradient(135deg, #eef2ff, #e0e7ff);
            color: #6366f1; font-size: 13px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .pkg-guide .step-item:not(:last-child)::after {
            content: ''; position: absolute;
            left: 13px; top: 32px; bottom: -12px;
            width: 2px; background: #e8ecf1;
        }
        .pkg-guide .step-text {
            font-size: 13px; color: #475569; line-height: 1.7;
            padding-top: 3px;
        }
        .pkg-guide .step-text strong { color: #334155; }
        .pkg-guide .step-text .text-indigo { color: #6366f1; font-weight: 600; }
        .pkg-guide .step-text .text-green { color: #059669; font-weight: 600; }

        /* 按钮 */
        .pkg-page .btn-primary {
            height: 38px; padding: 0 24px; border: none; border-radius: 8px;
            font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff !important;
            box-shadow: 0 1px 3px rgba(99,102,241,0.3);
        }
        .pkg-page .btn-primary:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px);
        }
        .pkg-page .btn-outline {
            height: 38px; padding: 0 24px; border-radius: 8px; font-size: 14px;
            font-weight: 600; cursor: pointer; transition: all 0.2s;
            border: 1px solid #d1d5db; background: #fff; color: #475569;
        }
        .pkg-page .btn-outline:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
        }
        .pkg-page .btn-download {
            height: 36px; padding: 0 20px; border: none; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            background: linear-gradient(135deg, #059669, #10b981); color: #fff !important;
            box-shadow: 0 1px 3px rgba(5,150,105,0.3); margin-top: 12px;
        }
        .pkg-page .btn-download:hover {
            background: linear-gradient(135deg, #047857, #059669);
            box-shadow: 0 4px 12px rgba(5,150,105,0.35); transform: translateY(-1px);
        }

        /* 资源列表卡片 */
        .pkg-filelist-card {
            background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            overflow: hidden;
        }
        .pkg-filelist-card .fl-header {
            display: flex; align-items: center; gap: 10px;
            padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        }
        .pkg-filelist-card .fl-header .fl-icon {
            width: 32px; height: 32px; border-radius: 8px;
            background: #eef2ff; display: flex; align-items: center; justify-content: center;
        }
        .pkg-filelist-card .fl-header .fl-icon svg {
            width: 16px; height: 16px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .pkg-filelist-card .fl-header .fl-title {
            font-size: 15px; font-weight: 700; color: #1e293b;
        }
        .pkg-filelist-card .fl-body { padding: 16px 24px; }
        .pkg-filelist-card table { width: 100%; }
        .pkg-filelist-card td { padding: 0; }
        .pkg-filelist-card .file-item {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 14px; border-radius: 8px;
            border: 1px solid #f1f5f9; margin-bottom: 6px;
            background: #fafbfc; font-size: 13px; transition: all 0.15s;
        }
        .pkg-filelist-card .file-item:hover { background: #f1f5f9; border-color: #e2e8f0; }
        .pkg-filelist-card .file-item span { color: #94a3b8; font-size: 12px; }
        .pkg-filelist-card .file-item a {
            color: #6366f1; text-decoration: none; font-weight: 500;
        }
        .pkg-filelist-card .file-item a:hover { color: #4f46e5; text-decoration: underline; }
        .pkg-filelist-card .fl-empty {
            text-align: center; padding: 40px 20px; color: #94a3b8; font-size: 13px;
        }
        .pkg-filelist-card .fl-empty svg {
            width: 40px; height: 40px; stroke: #d1d5db; fill: none;
            stroke-width: 1.5; display: block; margin: 0 auto 10px;
        }
    </style>

    <div class="pkg-page">
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                </span>
                学案打包
            </h2>
        </div>

        <!-- 双栏布局：左侧信息 + 右侧指南 -->
        <div class="pkg-grid">
            <div class="pkg-card">
                <div class="pkg-hero">
                    <div class="hero-badge">
                        <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                        学案信息
                    </div>
                    <div class="hero-title"><asp:Label ID="LabelCtitle" runat="server"></asp:Label></div>
                    <div class="hero-id">ID：<strong><asp:Label ID="LabelCid" runat="server"></asp:Label></strong></div>

                    <asp:Panel ID="Panelinfo" runat="server" Visible="False" CssClass="pkg-download-panel">
                        <asp:Label ID="Labelinfo" runat="server"></asp:Label>
                        <br />
                        <asp:Button ID="Btndown" runat="server" onclick="Btndown_Click" 
                            Text="下载打包文件" ToolTip="点击下载" CssClass="btn-download" />
                    </asp:Panel>

                    <div class="pkg-msg">
                        <asp:Label ID="Labelmsg" runat="server" ForeColor="#ef4444"></asp:Label>
                    </div>

                    <div class="hero-actions">
                        <asp:Button ID="BtnZip" runat="server" Text="开始打包" onclick="BtnZip_Click" 
                            ToolTip="点击开始学案打包" CssClass="btn-primary" />
                        <asp:Button ID="Btnreturn" runat="server" Text="← 返回" onclick="Btnreturn_Click" 
                            CssClass="btn-outline" />
                    </div>
                </div>
            </div>

            <div class="pkg-card">
                <div class="pkg-guide">
                    <h3>
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        操作指南
                    </h3>
                    <ol class="step-list">
                        <li class="step-item">
                            <span class="step-num">1</span>
                            <span class="step-text">点击左侧<span class="text-indigo">「开始打包」</span>按钮，系统将自动压缩学案目录下的所有资源文件。</span>
                        </li>
                        <li class="step-item">
                            <span class="step-num">2</span>
                            <span class="step-text">打包完成后会出现<span class="text-green">绿色下载区域</span>，点击即可下载 ZIP 压缩包。</span>
                        </li>
                        <li class="step-item">
                            <span class="step-num">3</span>
                            <span class="step-text">下方资源列表可查看当前学案包含的所有文件，点击文件名可预览。</span>
                        </li>
                        <li class="step-item">
                            <span class="step-num">4</span>
                            <span class="step-text">文件标记 <strong>T</strong> 表示只读、<strong>F</strong> 表示可写，打包会包含所有文件。</span>
                        </li>
                    </ol>
                </div>
            </div>
        </div>

        <!-- 资源列表 -->
        <div class="pkg-filelist-card">
            <div class="fl-header">
                <div class="fl-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                </div>
                <span class="fl-title">本学案目录内资源列表</span>
            </div>
            <div class="fl-body">
                <asp:DataList ID="Dlfilelist" runat="server" 
                    RepeatColumns="2" RepeatDirection="Horizontal"
                    CellPadding="3" CellSpacing="3" 
                    onitemdatabound="Dlfilelist_ItemDataBound" Width="100%" >
                    <ItemTemplate>
                        <div class="file-item">
                            <asp:Label ID="Labelfid" runat="server" Text='<%# Eval("fid") %>'></asp:Label>
                            <asp:HyperLink ID="HLfname" runat="server" Target="_blank" Text='<%# Eval("fname") %>' />
                            <asp:Label ID="Labelfsize" runat="server" Text='<%# Eval("fsize") %>' />
                            <asp:Label ID="Labelfread" runat="server" Text='<%# Eval("fread") %>' 
                                ToolTip="是否只读（T：只读 | F：可写）" ForeColor="#059669" />
                            <asp:Label ID="Labelurl" runat="server" Text='<%# Eval("furl") %>' Visible="false" />
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
        </div>
    </div>
</asp:Content>

