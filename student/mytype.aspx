<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_mytype, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
    <link href="../js/Typer.css" rel="stylesheet" type="text/css" />
<style>
    .mt-page,.mt-page *{box-sizing:border-box;margin-right:unset!important;margin-left:unset!important;}
    .mt-page table{border-collapse:collapse!important;border-color:transparent!important;}
    .mt-page .buttonimg,.mt-page .buttonnone{background-image:none!important;border-width:0!important;width:auto!important;height:auto!important;}
    .mt-page{display:flex;justify-content:center;width:100%;padding:20px 0 34px;font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif!important;color:#0f172a;animation:mtFadeIn .45s ease;}
    @keyframes mtFadeIn{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
    .mt-shell{position:relative;flex:0 1 1560px;width:min(1560px,calc(100vw - 24px));margin:0 auto;padding:30px;border-radius:30px;overflow:hidden;background:radial-gradient(circle at top left,rgba(14,165,233,.14),transparent 30%),radial-gradient(circle at top right,rgba(250,204,21,.16),transparent 24%),linear-gradient(180deg,#f8fbff 0,#f3f8f4 100%);box-shadow:0 20px 45px rgba(15,23,42,.08);}
    .mt-shell:before{content:"";position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.62),rgba(255,255,255,0));pointer-events:none;}
    .mt-hero,.mt-grid{position:relative;z-index:1;}
    .mt-hero{display:grid;grid-template-columns:minmax(0,1.5fr) 340px;gap:22px;margin-bottom:24px;padding:30px;border-radius:26px;background:linear-gradient(135deg,#ecfdf5 0,#eff6ff 52%,#fff7ed 100%);color:#0f172a;border:1px solid rgba(148,163,184,.18);overflow:hidden;}
    .mt-hero:after{content:"";position:absolute;top:-72px;right:-64px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.42);}
    .mt-hero-main,.mt-hero-side{position:relative;z-index:1;}
    .mt-badge{display:inline-flex;align-items:center;padding:8px 12px;border-radius:999px;border:1px solid rgba(15,118,110,.12);background:rgba(255,255,255,.72);font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#0f766e;}
    .mt-hero h1{margin:14px 0 10px;font-size:32px;line-height:1.12;color:#0f172a;}
    .mt-hero p{margin:0;max-width:660px;font-size:15px;line-height:1.8;color:#475569;}
    .mt-current{display:inline-flex;flex-wrap:wrap;align-items:center;gap:14px;margin-top:22px;padding:14px 16px;border-radius:18px;background:rgba(255,255,255,.76);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .mt-current-label{font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#0f766e;}
    .mt-current-value{display:flex;flex-wrap:wrap;gap:8px;font-size:18px;font-weight:700;color:#0f172a;}
    .mt-hero-side{padding:22px;border-radius:22px;background:rgba(255,255,255,.78);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .mt-side-title{margin:0 0 14px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#d97706;}
    .mt-steps{display:grid;gap:12px;}
    .mt-step{display:flex;align-items:flex-start;gap:10px;font-size:14px;line-height:1.7;color:#334155;}
    .mt-step strong{display:inline-flex;align-items:center;justify-content:center;width:28px;height:28px;border-radius:10px;background:rgba(15,118,110,.10);color:#0f766e;font-size:12px;flex-shrink:0;}
    .mt-grid{display:grid!important;grid-template-columns:minmax(0,1fr) 380px;gap:26px;align-items:start;}
    .mt-main,.mt-sidebar{min-width:0;}
    .mt-sidebar{display:flex!important;flex-direction:column;gap:18px;}
    .mt-card{background:rgba(255,255,255,.94)!important;border:1px solid #e2e8f0!important;border-radius:24px;box-shadow:0 14px 30px rgba(15,23,42,.05);overflow:hidden;}
    .mt-card-head{display:flex!important;gap:14px;align-items:flex-start;padding:22px 24px 18px;border-bottom:1px solid #eef2f7!important;background:linear-gradient(180deg,rgba(255,255,255,.94),rgba(247,250,252,.94))!important;}
    .mt-head-icon{width:44px;height:44px;border-radius:14px;display:flex!important;align-items:center;justify-content:center;flex-shrink:0;}
    .mt-head-icon svg,.mt-link-icon svg,.mt-game-icon svg{fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .mt-head-icon svg{width:21px;height:21px;}
    .mt-ico-type{background:linear-gradient(135deg,#d1fae5,#a7f3d0)} .mt-ico-type svg{stroke:#0f766e;}
    .mt-ico-nav{background:linear-gradient(135deg,#dbeafe,#bfdbfe)} .mt-ico-nav svg{stroke:#2563eb;}
    .mt-ico-rank{background:linear-gradient(135deg,#fef3c7,#fde68a)} .mt-ico-rank svg{stroke:#d97706;}
    .mt-ico-link{background:linear-gradient(135deg,#ede9fe,#ddd6fe)} .mt-ico-link svg{stroke:#6d28d9;}
    .mt-ico-note{background:linear-gradient(135deg,#fee2e2,#fecaca)} .mt-ico-note svg{stroke:#dc2626;}
    .mt-card-title h3{margin:0!important;font-size:17px!important;font-weight:700;color:#0f172a!important;}
    .mt-card-title p{margin:5px 0 0!important;font-size:13px!important;line-height:1.65;color:#64748b!important;}
    .mt-card-body{padding:22px 24px 24px;}
    .mt-section{display:flex;align-items:flex-end;justify-content:space-between;gap:14px;margin-bottom:14px;}
    .mt-section-label{display:inline-block;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#0f766e;}
    .mt-section h4{margin:6px 0 0;font-size:20px;color:#0f172a;}
    .mt-chip,.mt-pill{display:inline-flex;align-items:center;padding:7px 11px;border-radius:999px;border:1px solid #e2e8f0;background:#fff;font-size:12px;color:#64748b;white-space:nowrap;}
    .mt-list{padding:14px;border:1px solid #e2e8f0;border-radius:18px;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);max-height:152px;overflow:auto;}
    .mt-tid-wrap{display:flex;flex-wrap:wrap;gap:8px;}
    .mt-tid-wrap a{display:inline-flex!important;align-items:center;justify-content:center;min-width:34px;height:34px;padding:0 10px!important;border-radius:10px;border:1px solid #dbe4ee!important;background:#fff!important;color:#475569!important;font-size:12px!important;font-weight:700;text-decoration:none!important;transition:transform .15s,border-color .15s,box-shadow .15s,color .15s,background .15s;}
    .mt-tid-wrap a:hover{transform:translateY(-1px);border-color:#34d399!important;background:#ecfdf5!important;color:#047857!important;box-shadow:0 10px 18px rgba(16,185,129,.10);}
    .mt-work{display:grid;grid-template-columns:1fr;gap:20px;margin-top:18px;align-items:start;}
    .mt-panel{padding:18px;border:1px solid #e2e8f0;border-radius:20px;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .mt-panel-head{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;}
    .mt-panel-title{font-size:16px;font-weight:700;color:#0f172a;}
    .mt-page .typecontent{width:auto!important;min-height:380px!important;height:380px!important;max-height:380px!important;padding:22px 24px!important;border-radius:18px!important;background:radial-gradient(circle at top,#164e63 0,#0f172a 72%)!important;color:#e2e8f0!important;font-size:16px!important;line-height:1.8!important;letter-spacing:0!important;white-space:pre-wrap!important;word-break:break-all!important;overflow:auto!important;box-shadow:inset 0 1px 0 rgba(255,255,255,.08);}
    .mt-page .truechar{color:rgba(226,232,240,.56)!important;} .mt-page .typechar{border-bottom:2px solid #67e8f9!important;color:#fff!important;} .mt-page .falsechar{background:#f43f5e!important;color:#fff!important;border-radius:4px;}
    .mt-page .mt-over-limit{color:#fca5a5!important;}
    .mt-page .truechar.mt-over-limit{color:rgba(252,165,165,.58)!important;}
    .mt-page .typechar.mt-over-limit{color:#fff1f2!important;border-bottom-color:#fb7185!important;background:rgba(244,63,94,.14)!important;border-radius:4px;}
    .mt-page .falsechar.mt-over-limit{background:#be123c!important;color:#fff!important;}
    .mt-stats{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin-bottom:14px;}
    .mt-stat{padding:14px;border:1px solid #dbe7f0;border-radius:16px;background:#fff;box-shadow:0 8px 18px rgba(15,23,42,.04);}
    .mt-stat b{display:block;margin-bottom:8px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#64748b;}
    .mt-page .text7,.mt-page .text3{width:100%!important;padding:0!important;border:none!important;background:transparent!important;font-family:'Microsoft YaHei',sans-serif!important;text-align:left!important;font-weight:700!important;color:#0f172a!important;}
    .mt-page .text7{font-size:26px!important;} .mt-page .text3{font-size:20px!important;color:#0f766e!important;}
    .mt-page .textareacss{width:100%!important;height:242px!important;padding:18px!important;border:1px solid #86efac!important;border-radius:18px!important;background:linear-gradient(180deg,#fafffb 0,#f0fdf4 100%)!important;color:#0f172a!important;font-family:'Microsoft YaHei',sans-serif!important;font-size:22px!important;line-height:1.85!important;letter-spacing:4px!important;outline:none!important;resize:none!important;box-shadow:inset 0 1px 0 rgba(255,255,255,.78);transition:border-color .18s,box-shadow .18s;}
    .mt-page .textareacss:focus{border-color:#10b981!important;box-shadow:0 0 0 4px rgba(16,185,129,.15)!important;}
    .mt-page .divcenter{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:12px;padding:12px 14px;border-radius:14px;border:1px dashed #cbd5e1;background:#fff;font-size:13px;color:#64748b;}
    .mt-page #Labelmsg{color:#0f172a;font-weight:600;}
    .mt-mini-list,.mt-nav,.mt-games{display:grid!important;gap:10px;}
    .mt-mini{display:grid!important;grid-template-columns:64px minmax(0,1fr);align-items:center;column-gap:16px;padding:16px;border-radius:18px;border:1px solid #e2e8f0;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .mt-mini > div{min-width:0;padding-top:2px;}
    .mt-mini-no{position:relative;display:inline-flex!important;align-items:center!important;justify-content:center!important;width:48px;height:48px;min-width:48px;padding:0!important;margin:0 auto;border-radius:16px;background:transparent!important;flex-shrink:0;justify-self:center;overflow:hidden;}
    .mt-mini-no:before{content:"";position:absolute;inset:0;border-radius:inherit;background:linear-gradient(135deg,#fee2e2,#fecaca);}
    .mt-mini-no i{position:relative;z-index:1;display:flex!important;align-items:center!important;justify-content:center!important;width:100%;height:100%;margin:0!important;padding:0!important;font-style:normal!important;color:#b91c1c!important;font-size:18px!important;font-weight:800!important;line-height:1!important;text-align:center!important;text-indent:0!important;}
    .mt-mini strong,.mt-link-copy strong,.mt-game-copy strong{display:block;color:#0f172a;}
    .mt-mini strong{margin-bottom:4px;font-size:14px;} .mt-mini span{display:block;font-size:12px;line-height:1.7;color:#64748b;}
    .mt-link{display:flex!important;align-items:center;gap:12px;padding:14px!important;border-radius:16px;border:1.5px solid #e2e8f0!important;background:#fff!important;text-decoration:none!important;transition:transform .15s,box-shadow .15s,border-color .15s,background .15s;width:auto!important;height:auto!important;}
    .mt-link:hover,.mt-game:hover{transform:translateY(-2px);box-shadow:0 10px 20px rgba(15,23,42,.08);}
    .mt-link-icon,.mt-game-icon{display:flex!important;align-items:center;justify-content:center;flex-shrink:0;border-radius:12px;}
    .mt-link-icon{width:40px;height:40px;} .mt-link-icon svg{width:20px;height:20px;}
    .mt-link-copy{display:flex;flex-direction:column;gap:3px;} .mt-link-copy strong{font-size:14px;} .mt-link-copy em,.mt-mode-note,.mt-game-copy em{font-style:normal;font-size:12px;line-height:1.7;color:#64748b;}
    .mt-link-amber .mt-link-icon{background:linear-gradient(135deg,#fef3c7,#fde68a)} .mt-link-amber .mt-link-icon svg{stroke:#d97706;} .mt-link-amber:hover{border-color:#f59e0b!important;background:#fffbeb!important;}
    .mt-link-blue .mt-link-icon{background:linear-gradient(135deg,#dbeafe,#bfdbfe)} .mt-link-blue .mt-link-icon svg{stroke:#2563eb;} .mt-link-blue:hover{border-color:#60a5fa!important;background:#eff6ff!important;}
    .mt-link-current{border-color:#34d399!important;background:#ecfdf5!important;box-shadow:0 10px 20px rgba(16,185,129,.10);} .mt-link-current .mt-link-icon{background:linear-gradient(135deg,#d1fae5,#86efac)} .mt-link-current .mt-link-icon svg{stroke:#047857;}
    .mt-mode-note{margin-top:14px;padding:12px 14px;border-radius:14px;border:1px solid #fed7aa;background:linear-gradient(135deg,#fff7ed,#fffbeb);color:#9a3412;}
    .mt-card-body table{width:100%!important;border:none!important;border-collapse:separate!important;border-spacing:0!important;}
    .mt-card-body table caption{display:none!important;}
    .mt-page .mt-card-body table th{padding:12px 14px!important;border:none!important;background:#f8fafc!important;font-size:12px!important;font-weight:700!important;letter-spacing:.05em;text-align:left!important;color:#64748b!important;text-transform:uppercase;font-family:'Microsoft YaHei','Segoe UI',sans-serif!important;}
    .mt-page .mt-card-body table td{padding:12px 14px!important;border-top:1px solid #eef2f7!important;border-right:none!important;border-bottom:none!important;border-left:none!important;background:#fff!important;font-size:13px!important;color:#334155!important;font-family:'Microsoft YaHei','Segoe UI',sans-serif!important;}
    .mt-page .mt-card-body table tr:first-child td{border-top:none!important;}
    .mt-page .mt-card-body table td:first-child{width:64px;font-weight:700;color:#0f766e!important;}
    .mt-page .mt-card-body table tr:hover td{background:#f8fffc!important;}
    .mt-card-body table a{display:inline-flex;align-items:center;justify-content:center;padding:6px 10px;border-radius:999px;background:#eef2ff;color:#4338ca!important;font-size:12px!important;font-weight:700;text-decoration:none!important;}
    .mt-page .mt-card-body table tr[style*='Font-Size'] div,.mt-page .mt-card-body table tr[align] div{display:flex!important;align-items:center;justify-content:center;gap:8px;padding:10px 0;}
    .mt-page .mt-card-body table tr[style*='Font-Size'] a,.mt-page .mt-card-body table tr[align] a{background:#fff;border:1px solid #e2e8f0;color:#475569!important;}
    .mt-game{display:flex!important;align-items:center;gap:12px;padding:14px 16px!important;border-radius:16px!important;border:1.5px solid #e2e8f0!important;background:linear-gradient(180deg,#fff 0,#f8fafc 100%)!important;text-decoration:none!important;transition:transform .15s,box-shadow .15s,border-color .15s,background .15s;width:auto!important;height:auto!important;cursor:pointer;}
    .mt-game:hover{border-color:#c7d2fe!important;background:#f8faff!important;}
    .mt-game-icon{width:36px;height:36px;} .mt-game-icon svg{width:16px;height:16px;} .mt-game-all{background:#d1fae5;} .mt-game-all svg{stroke:#059669;} .mt-game-class{background:#dbeafe;} .mt-game-class svg{stroke:#2563eb;}
    .mt-game-copy{display:flex;flex-direction:column;gap:4px;min-width:0;} .mt-game-copy strong{font-size:14px;} .mt-game-copy em{color:#64748b;}
    @media (min-width:1081px){.mt-sidebar{position:sticky!important;top:18px;}}
    @media (max-width:1080px){.mt-hero,.mt-grid,.mt-work{grid-template-columns:1fr!important;}}
    @media (max-width:768px){.mt-page{padding-top:10px}.mt-shell{padding:16px;border-radius:22px}.mt-hero{padding:20px;border-radius:20px}.mt-hero h1{font-size:26px}.mt-card-head,.mt-card-body{padding-left:18px;padding-right:18px}.mt-section,.mt-panel-head,.mt-page .divcenter{flex-direction:column;align-items:flex-start}.mt-stats{grid-template-columns:1fr}.mt-page .typecontent{min-height:332px!important;height:332px!important;max-height:332px!important;font-size:15px!important;line-height:1.76!important;letter-spacing:0!important}.mt-page .textareacss{font-size:20px!important;line-height:1.75!important}}
</style>

<div class="mt-page">
    <div class="mt-shell">
        <div class="mt-hero">
            <div class="mt-hero-main">
                <span class="mt-badge">LearnSite Typing Lab</span>
                <h1>中文打字练习</h1>
                <p>把跟打训练做成更清晰的学习流：先选篇目，再看原文，再在下方实时录入，速度、正确数和拼音提示会同步反馈，适合课堂热身和日常巩固。</p>
                <div class="mt-current">
                    <span class="mt-current-label">当前篇目</span>
                    <span class="mt-current-value">
                        <asp:Label ID="LTid" runat="server"></asp:Label>
                        <asp:Label ID="Ttitle" runat="server"></asp:Label>
                    </span>
                </div>
            </div>
            <div class="mt-hero-side">
                <p class="mt-side-title">练习节奏</p>
                <div class="mt-steps">
                    <div class="mt-step"><strong>01</strong><span>先点击编号切换篇目，确定自己要练的内容。</span></div>
                    <div class="mt-step"><strong>02</strong><span>跟着高亮字位输入，先稳住节奏，再逐步提速。</span></div>
                    <div class="mt-step"><strong>03</strong><span>练完即可去右侧英雄榜看本篇速度排名。</span></div>
                </div>
            </div>
        </div>

        <div class="mt-grid">
            <div class="mt-main">
                <div class="mt-card">
                    <div class="mt-card-head">
                        <span class="mt-head-icon mt-ico-type"><svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"></path><path d="M9 20h6"></path><path d="M12 4v16"></path></svg></span>
                        <div class="mt-card-title">
                            <h3>开始跟打</h3>
                            <p>篇章目录、原文区和输入区集中在这里，练习过程更聚焦。</p>
                        </div>
                    </div>
                    <div class="mt-card-body">
                        <div class="mt-section">
                            <div>
                                <span class="mt-section-label">篇章目录</span>
                                <h4>选择训练内容</h4>
                            </div>
                            <span class="mt-chip">点击编号即可切换</span>
                        </div>
                        <div class="mt-list">
                            <div class="mt-tid-wrap">
                                <asp:DataList ID="DLTid" runat="server" ForeColor="#333333" RepeatColumns="36" RepeatDirection="Horizontal" RepeatLayout="Flow" CellPadding="0" CellSpacing="0">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="id" runat="server" NavigateUrl='<%# "mytype.aspx?Tid="+Eval("tid") %>' Text='<%# Eval("tid") %>' ToolTip='<%# Eval("Ttitle") %>' Font-Underline="False" ForeColor="#333333"></asp:HyperLink>
                                    </ItemTemplate>
                                </asp:DataList>
                            </div>
                        </div>

                        <div class="mt-work">
                            <div class="mt-panel">
                                <div class="mt-panel-head">
                                    <span class="mt-panel-title">原文内容</span>
                                    <span class="mt-pill">逐字高亮定位</span>
                                </div>
                                <div id="Tcontent" class="typecontent"><asp:Literal ID="Literal1" runat="server"></asp:Literal></div>
                            </div>

                            <div class="mt-panel">
                                <div class="mt-panel-head">
                                    <span class="mt-panel-title">实时录入</span>
                                    <span class="mt-pill">禁止粘贴，专注跟打</span>
                                </div>
                                <div class="mt-stats">
                                    <div class="mt-stat"><b>正确</b><input id="Text4" class="text7" type="text" hidefocus="hideFocus" maxlength="30" readonly="readOnly" unselectable="on" value="0" name="TypeText4" /></div>
                                    <div class="mt-stat"><b>速度</b><input id="Text6" class="text7" type="text" hidefocus="hideFocus" maxlength="30" readonly="readOnly" unselectable="on" name="Typeresult" value="0" /></div>
                                    <div class="mt-stat"><b>拼音</b><input id="Textpy" class="text3" type="text" hidefocus="hideFocus" maxlength="30" readonly="readOnly" unselectable="on" /></div>
                                </div>
                                <textarea id="InputText" class="textareacss" cols="6" onpaste="return false;" ondragenter="return false;" ondrop="return false;" rows="6"></textarea>
                                <div class="divcenter">
                                    <label id="Labelmsg"></label>
                                    <asp:Label ID="Labeltids" runat="server" Visible="False"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-sidebar">
                <div class="mt-card">
                    <div class="mt-card-head">
                        <span class="mt-head-icon mt-ico-note"><svg viewBox="0 0 24 24"><path d="M12 8v4"></path><path d="M12 16h.01"></path><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path></svg></span>
                        <div class="mt-card-title">
                            <h3>练习建议</h3>
                            <p>先稳准确率，再拉速度，效果会更明显。</p>
                        </div>
                    </div>
                    <div class="mt-card-body">
                        <div class="mt-mini-list">
                            <div class="mt-mini"><span class="mt-mini-no"><i>1</i></span><div><strong>先看后打</strong><span>先扫一遍原文内容，熟悉词组和节奏，再开始录入。</span></div></div>
                            <div class="mt-mini"><span class="mt-mini-no"><i>2</i></span><div><strong>纠错别抢</strong><span>如果连续出错，放慢半拍，先把当前位置重新对准。</span></div></div>
                            <div class="mt-mini"><span class="mt-mini-no"><i>3</i></span><div><strong>多轮短练</strong><span>同一篇反复练 2 到 3 次，通常比一次长练更有效。</span></div></div>
                        </div>
                    </div>
                </div>

                <div class="mt-card">
                    <div class="mt-card-head">
                        <span class="mt-head-icon mt-ico-nav"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg></span>
                        <div class="mt-card-title">
                            <h3>打字模式</h3>
                            <p>不同练习入口统一成卡片按钮，切换更直观。</p>
                        </div>
                    </div>
                    <div class="mt-card-body">
                        <div class="mt-nav">
                            <asp:HyperLink ID="HChinese" runat="server" NavigateUrl="~/student/mychinese.aspx" CssClass="mt-link mt-link-amber">
                                <span class="mt-link-icon"><svg viewBox="0 0 24 24"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg></span>
                                <span class="mt-link-copy"><strong>拼音模式</strong><em>适合拼音输入基础训练</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HkFinger" runat="server" NavigateUrl="~/student/myfinger.aspx" CssClass="mt-link mt-link-blue">
                                <span class="mt-link-icon"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2"></rect><path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M8 12h.01M12 12h.01M16 12h.01M7 16h10"></path></svg></span>
                                <span class="mt-link-copy"><strong>英文模式</strong><em>适合键位和指法巩固</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HTyper" runat="server" NavigateUrl="~/student/mytype.aspx" CssClass="mt-link mt-link-current">
                                <span class="mt-link-icon"><svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"></path><path d="M9 20h6"></path><path d="M12 4v16"></path></svg></span>
                                <span class="mt-link-copy"><strong>中文模式</strong><em>适合篇章跟打与速度提升</em></span>
                            </asp:HyperLink>
                        </div>
                        <div>
                            <script src="../js/Backcolor.js" type="text/javascript"></script>
                            <script type="text/javascript">WriteBg();</script>
                        </div>
                        <div class="mt-mode-note">练习时建议全程使用键盘录入，不要频繁切换窗口，能更稳定地观察速度变化。</div>
                    </div>
                </div>

                <div class="mt-card">
                    <div class="mt-card-head">
                        <span class="mt-head-icon mt-ico-rank"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg></span>
                        <div class="mt-card-title">
                            <h3>英雄榜</h3>
                            <p>查看当前篇目的速度表现和练习次数。</p>
                        </div>
                    </div>
                    <div class="mt-card-body">
                        <asp:GridView ID="GVTyper" runat="server" AllowPaging="True" CellPadding="2" onpageindexchanging="GVTyper_PageIndexChanging" PageSize="20" OnRowDataBound="GVTyper_RowDataBound" Width="100%" SkinID="GridViewInfo">
                            <Columns>
                                <asp:BoundField HeaderText="名次" />
                                <asp:BoundField DataField="Sname" HeaderText="姓名"><ItemStyle HorizontalAlign="Left" /></asp:BoundField>
                                <asp:BoundField DataField="Pscore" HeaderText="速度"><ItemStyle HorizontalAlign="Left" /></asp:BoundField>
                                <asp:BoundField DataField="Ptype" HeaderText="次数" />
                            </Columns>
                            <PagerTemplate>
                                <div style="color:black; text-align:center">
                                    <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                                </div>
                            </PagerTemplate>
                            <PagerStyle Font-Size="9pt" />
                        </asp:GridView>
                    </div>
                </div>

                <div class="mt-card">
                    <div class="mt-card-head">
                        <span class="mt-head-icon mt-ico-link"><svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg></span>
                        <div class="mt-card-title">
                            <h3>更多活动</h3>
                            <p>继续查看排行或跳转到本篇班级榜单。</p>
                        </div>
                    </div>
                    <div class="mt-card-body">
                        <div class="mt-games">
                            <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/student/alltyper.aspx" Target="_self" CssClass="mt-game">
                                <span class="mt-game-icon mt-game-all"><svg viewBox="0 0 24 24"><path d="M12 15l-2 5-1.5-3.5L5 15l3.5-1.5L12 8l3.5 5.5L19 15l-3.5 1.5L14 20z"></path></svg></span>
                                <span class="mt-game-copy"><strong>中文输入英雄榜</strong><em>查看全站中文输入成绩排行</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HyperLink2" runat="server" Target="_self" CssClass="mt-game">
                                <span class="mt-game-icon mt-game-class"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></span>
                                <span class="mt-game-copy"><strong>本篇班内英雄榜</strong><em>查看当前篇目在班级内的成绩表现</em></span>
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
    <script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
    <script src="../js/Typer.js?v=20260320b" type="text/javascript"></script>
    <script src="../js/pydic.js" type="text/javascript"></script>
    <script src="../js/wbdic.js" type="text/javascript"></script>
    <script type="text/javascript">
        (function () {
            var limitIndex = 210;

            function escapeHtml(text) {
                return text
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;");
            }

            function applyLimitColor() {
                var box = document.getElementById("Tcontent");
                if (!box) {
                    return;
                }

                var colored = box.querySelectorAll("span.truechar, span.falsechar, span.typechar");
                if (colored.length) {
                    for (var i = 0; i < colored.length; i++) {
                        if (i >= limitIndex) {
                            colored[i].classList.add("mt-over-limit");
                        } else {
                            colored[i].classList.remove("mt-over-limit");
                        }
                    }
                    return;
                }

                var raw = box.textContent || "";
                if (!raw) {
                    return;
                }

                var html = "";
                for (var j = 0; j < raw.length; j++) {
                    var cls = j >= limitIndex ? " class=\"mt-over-limit\"" : "";
                    html += "<span" + cls + ">" + escapeHtml(raw.charAt(j)) + "</span>";
                }
                box.innerHTML = html;
            }

            function getNormalizedInputValue($input) {
                var raw = $input.val() || "";
                var normalized;
                if (typeof normalizeTyperText === "function") {
                    normalized = normalizeTyperText(raw);
                } else {
                    normalized = raw.replace(/[a-zA-Z]/g, "").replace(/[\r\n\t\f\v \u00A0\u3000]/g, "");
                }
                if (raw !== normalized) {
                    $input.val(normalized);
                }
                return normalized;
            }

            function syncTypeHighlight() {
                if (typeof checktype !== "function") {
                    applyLimitColor();
                    return;
                }
                var $input = $("#InputText");
                var normalized = getNormalizedInputValue($input);
                checktype(normalized);
                applyLimitColor();
            }

            $(function () {
                var $input = $("#InputText");
                if (!$input.length) {
                    applyLimitColor();
                    return;
                }

                $input.on("keydown", function (event) {
                    var key = event.which || event.keyCode || 0;
                    if (key === 32) {
                        event.preventDefault();
                        $("#Labelmsg").html("空格不会计为正确，请直接输入正文字符。");
                        setTimeout(syncTypeHighlight, 0);
                        return false;
                    }
                });

                $input.on("keyup input propertychange compositionend", function () {
                    setTimeout(syncTypeHighlight, 0);
                });

                setTimeout(syncTypeHighlight, 60);
                setTimeout(applyLimitColor, 80);
            });
        })();
    </script>
</asp:Content>
