<%@ page language="C#" masterpagefile="~/student/Stud.master" autoeventwireup="true" inherits="Student_typerank, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .tr-page, .tr-page * { margin-right: unset !important; margin-left: unset !important; }
    .tr-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .tr-page { width: 100%; max-width: 1400px; margin: 0 auto !important; padding: 0 24px; box-sizing: border-box; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: trFadeIn .4s ease; }
    @keyframes trFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 顶部标题 */
    .tr-hero-banner { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 18px; padding: 28px 32px; margin-bottom: 22px; color: #fff; display: flex; align-items: center; gap: 18px; box-shadow: 0 4px 20px rgba(102,126,234,.25); }
    .tr-hero-banner .tr-banner-icon { width: 52px; height: 52px; background: rgba(255,255,255,.18); border-radius: 14px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .tr-banner-icon svg { width: 26px; height: 26px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tr-hero-banner h2 { font-size: 20px; font-weight: 700; margin: 0 0 4px !important; }
    .tr-hero-banner p { font-size: 13px; margin: 0 !important; opacity: .85; }

    /* 统计卡片行 */
    .tr-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 22px; }
    .tr-stat-card { background: #fff; border-radius: 14px; border: 1px solid #e5e7eb; padding: 18px 20px; display: flex; align-items: center; gap: 14px; box-shadow: 0 1px 3px rgba(0,0,0,.04); transition: transform .15s, box-shadow .15s; }
    .tr-stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,.06); }
    .tr-stat-icon { width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .tr-stat-icon svg { width: 20px; height: 20px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tr-stat-icon-green { background: linear-gradient(135deg, #dcfce7, #bbf7d0); }
    .tr-stat-icon-green svg { stroke: #16a34a; }
    .tr-stat-icon-indigo { background: linear-gradient(135deg, #e0e7ff, #c7d2fe); }
    .tr-stat-icon-indigo svg { stroke: #4f46e5; }
    .tr-stat-icon-amber { background: linear-gradient(135deg, #fef3c7, #fde68a); }
    .tr-stat-icon-amber svg { stroke: #d97706; }
    .tr-stat-info { flex: 1; }
    .tr-stat-label { font-size: 12px; color: #94a3b8; font-weight: 500; margin-bottom: 2px; }
    .tr-stat-value { font-size: 20px; font-weight: 700; color: #1e293b; }
    .tr-stat-unit { font-size: 12px; color: #94a3b8; font-weight: 400; margin-left: 3px; }

    /* 卡片 */
    .tr-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .tr-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .tr-card-head .tr-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .tr-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .tr-head-icon-green { background: linear-gradient(135deg, #dcfce7, #bbf7d0) !important; }
    .tr-head-icon-green svg { stroke: #16a34a !important; }
    .tr-head-icon-indigo { background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important; }
    .tr-head-icon-indigo svg { stroke: #4f46e5 !important; }
    .tr-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .tr-card-body { padding: 20px 22px; }

    /* 分区标签 */
    .tr-section-tag { display: inline-flex; align-items: center; gap: 5px; padding: 5px 14px; border-radius: 20px; font-size: 12px; font-weight: 600; margin-bottom: 14px; }
    .tr-tag-all { background: #fef3c7; color: #92400e; }
    .tr-tag-grade { background: #ede9fe; color: #5b21b6; }

    /* 人物卡片 - 内层 DataList 的 item */
    .tr-card-body table { border-collapse: separate !important; border-spacing: 0 !important; border: none !important; }
    .tr-card-body td { border: none !important; padding: 5px !important; vertical-align: top !important; }
    .tr-person { margin: 0; padding: 14px 10px 12px; border-radius: 14px; border: 1.5px solid #f1f5f9 !important; background: #fff !important; text-align: center; width: 110px; transition: all .15s; font-family: 'Microsoft YaHei',sans-serif !important; }
    .tr-person:hover { border-color: #c7d2fe !important; box-shadow: 0 4px 16px rgba(99,102,241,.1); transform: translateY(-2px); }
    .tr-person img { width: 64px !important; height: 64px !important; border-radius: 50% !important; object-fit: cover; border: 3px solid #f1f5f9; margin-bottom: 8px; transition: border-color .15s; }
    .tr-person:hover img { border-color: #c7d2fe; }
    .tr-person .tr-name { display: block; font-size: 13px; font-weight: 600; color: #1e293b; margin-bottom: 3px; }
    .tr-person .tr-class { display: block; font-size: 11px; color: #94a3b8; margin-bottom: 4px; }
    .tr-person .tr-speed { display: inline-block; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
    .tr-speed-cn { background: #dcfce7; color: #15803d; }
    .tr-speed-en { background: #e0e7ff; color: #4338ca; }

    /* 年级分区 */
    .tr-grade-section { margin-top: 18px; padding-top: 16px; border-top: 1px dashed #e5e7eb; }
    .tr-grade-section:first-child { margin-top: 0; padding-top: 0; border-top: none; }
    .tr-card-body .tr-grade-section span { font-size: 13px !important; font-weight: 600; color: #475569; }

    .tr-page .tr-card-body table { width: auto !important; }
    asp\:Label#Labeltop { display: none; }
</style>

<div class="tr-page">
    <!-- 标题横幅 -->
    <div class="tr-hero-banner">
        <div class="tr-banner-icon"><svg viewBox="0 0 24 24"><path d="M6 9l6 6 6-6"/><circle cx="12" cy="3" r="1"/><path d="M17 21H7l2-4h6l2 4z"/><path d="M12 12V3"/><path d="M3 17l3-6"/><path d="M21 17l-3-6"/></svg></div>
        <div>
            <h2>文字输入擂台榜</h2>
            <p>展示中文与英文输入的最佳选手，挑战自己的速度极限！</p>
        </div>
    </div>

    <!-- 统计卡片 -->
    <div class="tr-stats">
        <div class="tr-stat-card">
            <div class="tr-stat-icon tr-stat-icon-green"><svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg></div>
            <div class="tr-stat-info">
                <div class="tr-stat-label">擂台模式</div>
                <div class="tr-stat-value">中英<span class="tr-stat-unit">双擂台</span></div>
            </div>
        </div>
        <div class="tr-stat-card">
            <div class="tr-stat-icon tr-stat-icon-indigo"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
            <div class="tr-stat-info">
                <div class="tr-stat-label">参与范围</div>
                <div class="tr-stat-value">全校<span class="tr-stat-unit">+ 各年级</span></div>
            </div>
        </div>
        <div class="tr-stat-card">
            <div class="tr-stat-icon tr-stat-icon-amber"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
            <div class="tr-stat-info">
                <div class="tr-stat-label">每组上榜</div>
                <div class="tr-stat-value">TOP <asp:Label ID="Labeltop" runat="server" Text="8" Visible="true"></asp:Label></div>
            </div>
        </div>
    </div>

    <!-- 中文输入擂台 -->
    <div class="tr-card">
        <div class="tr-card-head">
            <span class="tr-head-icon tr-head-icon-green"><svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"/><path d="M9 20h6"/><path d="M12 4v16"/></svg></span>
            <h3>中文输入擂台</h3>
        </div>
        <div class="tr-card-body">
            <span class="tr-section-tag tr-tag-all">⭐ 全校榜单</span>
            <asp:DataList ID="DataList_allc" runat="server" 
                onitemdatabound="DataList_allc_ItemDataBound" RepeatColumns="12" 
                RepeatDirection="Horizontal">
                <ItemTemplate>
                    <div class="tr-person">
                        <asp:Image ID="allcImage1" runat="server" Height="64px" Width="64px" /><br />
                        <span class="tr-name"><asp:Label ID="allcLabelsname" runat="server" Text='<%# Eval("Sname") %>'></asp:Label></span>
                        <asp:Label ID="allcLabelpsnum" runat="server" Text='<%# Eval("Psnum") %>' Visible="false"></asp:Label>
                        <span class="tr-class"><asp:Label ID="allcLabelsgrade" runat="server" Text='<%# Eval("Sgrade") %>'></asp:Label>.<asp:Label ID="allcsclass" runat="server" Text='<%# Eval("Sclass") %>'></asp:Label>班</span>
                        <span class="tr-speed tr-speed-cn"><asp:Label ID="allcLabelpscore" runat="server" Text='<%# Eval("Pscore") %>'></asp:Label>字/分</span>
                    </div>
                </ItemTemplate>
            </asp:DataList>

            <asp:DataList ID="DataList_wai" runat="server" 
                onitemdatabound="DataList_wai_ItemDataBound">
                <ItemTemplate>
                    <div class="tr-grade-section">
                        <span class="tr-section-tag tr-tag-grade">🎓 <asp:Label ID="Labelgrade" runat="server" Text='<%# Eval("Rgrade") %>'></asp:Label></span>
                        <asp:DataList ID="DataList_li" runat="server" 
                            onitemdatabound="DataList_li_ItemDataBound" RepeatColumns="12" 
                            RepeatDirection="Horizontal">
                            <ItemTemplate>
                                <div class="tr-person">
                                    <asp:Image ID="Image1" runat="server" Height="64px" Width="64px" /><br />
                                    <span class="tr-name"><asp:Label ID="Labelsname" runat="server" Text='<%# Eval("Sname") %>'></asp:Label></span>
                                    <asp:Label ID="Labelpsnum" runat="server" Text='<%# Eval("Psnum") %>' Visible="false"></asp:Label>
                                    <span class="tr-class"><asp:Label ID="Labelsgrade" runat="server" Text='<%# Eval("Sgrade") %>'></asp:Label>.<asp:Label ID="sclass" runat="server" Text='<%# Eval("Sclass") %>'></asp:Label>班</span>
                                    <span class="tr-speed tr-speed-cn"><asp:Label ID="Labelpscore" runat="server" Text='<%# Eval("Pscore") %>'></asp:Label>字/分</span>
                                </div>
                            </ItemTemplate>
                        </asp:DataList>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- 英文输入擂台 -->
    <div class="tr-card">
        <div class="tr-card-head">
            <span class="tr-head-icon tr-head-icon-indigo"><svg viewBox="0 0 24 24"><path d="M5 7l5 5-5 5"/><line x1="12" y1="19" x2="19" y2="19"/></svg></span>
            <h3>英文输入擂台</h3>
        </div>
        <div class="tr-card-body">
            <span class="tr-section-tag tr-tag-all">⭐ 全校榜单</span>
            <asp:DataList ID="DataList_enall" runat="server" 
                onitemdatabound="DataList_enall_ItemDataBound" RepeatColumns="12" 
                RepeatDirection="Horizontal">
                <ItemTemplate>
                    <div class="tr-person">
                        <asp:Image ID="lenImage1" runat="server" Height="64px" Width="64px" /><br />
                        <span class="tr-name"><asp:Label ID="lenLabelsname" runat="server" Text='<%# Eval("Sname") %>'></asp:Label></span>
                        <asp:Label ID="lenLabelpsnum" runat="server" Text='<%# Eval("Psnum") %>' Visible="false"></asp:Label>
                        <span class="tr-class"><asp:Label ID="lenLabelsgrade" runat="server" Text='<%# Eval("Sgrade") %>'></asp:Label>.<asp:Label ID="lensclass" runat="server" Text='<%# Eval("Sclass") %>'></asp:Label>班</span>
                        <span class="tr-speed tr-speed-en"><asp:Label ID="lenLabelpspd" runat="server" Text='<%# Eval("Pspd") %>'></asp:Label>词/分</span>
                    </div>
                </ItemTemplate>
            </asp:DataList>

            <asp:DataList ID="DataList_enwai" runat="server" 
                onitemdatabound="DataList_enwai_ItemDataBound">
                <ItemTemplate>
                    <div class="tr-grade-section">
                        <span class="tr-section-tag tr-tag-grade">🎓 <asp:Label ID="enLabelgrade" runat="server" Text='<%# Eval("Rgrade") %>'></asp:Label></span>
                        <asp:DataList ID="DataList_enli" runat="server" 
                            onitemdatabound="DataList_enli_ItemDataBound" RepeatColumns="12" 
                            RepeatDirection="Horizontal">
                            <ItemTemplate>
                                <div class="tr-person">
                                    <asp:Image ID="enImage1" runat="server" Height="64px" Width="64px" /><br />
                                    <span class="tr-name"><asp:Label ID="enLabelsname" runat="server" Text='<%# Eval("Sname") %>'></asp:Label></span>
                                    <asp:Label ID="enLabelpsnum" runat="server" Text='<%# Eval("Psnum") %>' Visible="false"></asp:Label>
                                    <span class="tr-class"><asp:Label ID="enLabelsgrade" runat="server" Text='<%# Eval("Sgrade") %>'></asp:Label>.<asp:Label ID="ensclass" runat="server" Text='<%# Eval("Sclass") %>'></asp:Label>班</span>
                                    <span class="tr-speed tr-speed-en"><asp:Label ID="enLabelpspd" runat="server" Text='<%# Eval("Pspd") %>'></asp:Label>词/分</span>
                                </div>
                            </ItemTemplate>
                        </asp:DataList>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>
</div>
</asp:Content>
