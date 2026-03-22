<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_mychinese, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
 <link href="../images/fingering/finger.css" rel="stylesheet" type="text/css" />
 <script src="../js/jquery.cookie.js" type="text/javascript"></script>
<style>
    .mc-page,.mc-page *{box-sizing:border-box;margin-right:unset!important;margin-left:unset!important;}
    .mc-page table{border-collapse:collapse!important;border-color:transparent!important;}
    .mc-page .buttonimg,.mc-page .buttonnone{background-image:none!important;border-width:0!important;width:auto!important;height:auto!important;}
    .mc-page{display:flex;justify-content:center;width:100%;padding:20px 0 34px;font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif!important;color:#0f172a;animation:mcFadeIn .45s ease;}
    @keyframes mcFadeIn{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
    .mc-shell{position:relative;flex:0 1 1560px;width:min(1560px,calc(100vw - 24px));margin:0 auto;padding:30px;border-radius:30px;overflow:hidden;background:radial-gradient(circle at top left,rgba(168,85,247,.14),transparent 32%),radial-gradient(circle at top right,rgba(244,114,182,.14),transparent 24%),linear-gradient(180deg,#fbf8ff 0,#f8fafc 100%);box-shadow:0 20px 45px rgba(15,23,42,.08);}
    .mc-shell:before{content:"";position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.62),rgba(255,255,255,0));pointer-events:none;}
    .mc-hero,.mc-grid{position:relative;z-index:1;}
    .mc-hero{display:grid;grid-template-columns:minmax(0,1.5fr) 340px;gap:22px;margin-bottom:24px;padding:30px;border-radius:26px;background:linear-gradient(135deg,#fdf4ff 0,#f5f3ff 45%,#eff6ff 100%);color:#0f172a;border:1px solid rgba(148,163,184,.18);overflow:hidden;}
    .mc-hero:after{content:"";position:absolute;top:-72px;right:-64px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.42);}
    .mc-hero-main,.mc-hero-side{position:relative;z-index:1;}
    .mc-badge{display:inline-flex;align-items:center;padding:8px 12px;border-radius:999px;border:1px solid rgba(147,51,234,.12);background:rgba(255,255,255,.72);font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#7c3aed;}
    .mc-hero h1{margin:14px 0 10px;font-size:32px;line-height:1.12;color:#0f172a;}
    .mc-hero p{margin:0;max-width:660px;font-size:15px;line-height:1.8;color:#475569;}
    .mc-current{display:inline-flex;flex-wrap:wrap;align-items:center;gap:14px;margin-top:22px;padding:14px 16px;border-radius:18px;background:rgba(255,255,255,.76);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .mc-current-label{font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#9333ea;}
    .mc-current-value{display:flex;flex-wrap:wrap;gap:8px;font-size:18px;font-weight:700;color:#0f172a;}
    .mc-hero-side{padding:22px;border-radius:22px;background:rgba(255,255,255,.78);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .mc-side-title{margin:0 0 14px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#db2777;}
    .mc-steps{display:grid;gap:12px;}
    .mc-step{display:flex;align-items:flex-start;gap:10px;font-size:14px;line-height:1.7;color:#334155;}
    .mc-step strong{display:inline-flex;align-items:center;justify-content:center;width:28px;height:28px;border-radius:10px;background:rgba(147,51,234,.10);color:#9333ea;font-size:12px;flex-shrink:0;}
    .mc-grid{display:grid!important;grid-template-columns:minmax(0,1fr) 380px;gap:26px;align-items:start;}
    .mc-main,.mc-sidebar{min-width:0;}
    .mc-sidebar{display:flex!important;flex-direction:column;gap:18px;}
    .mc-card{background:rgba(255,255,255,.94)!important;border:1px solid #e2e8f0!important;border-radius:24px;box-shadow:0 14px 30px rgba(15,23,42,.05);overflow:hidden;}
    .mc-card-head{display:flex!important;gap:14px;align-items:flex-start;padding:22px 24px 18px;border-bottom:1px solid #eef2f7!important;background:linear-gradient(180deg,rgba(255,255,255,.94),rgba(247,250,252,.94))!important;}
    .mc-head-icon{width:44px;height:44px;border-radius:14px;display:flex!important;align-items:center;justify-content:center;flex-shrink:0;}
    .mc-head-icon svg,.mc-link-icon svg,.mc-game-icon svg{fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .mc-head-icon svg{width:21px;height:21px;}
    .mc-ico-type{background:linear-gradient(135deg,#f3e8ff,#e9d5ff)} .mc-ico-type svg{stroke:#7c3aed;}
    .mc-ico-nav{background:linear-gradient(135deg,#dbeafe,#bfdbfe)} .mc-ico-nav svg{stroke:#2563eb;}
    .mc-ico-rank{background:linear-gradient(135deg,#fef3c7,#fde68a)} .mc-ico-rank svg{stroke:#d97706;}
    .mc-ico-link{background:linear-gradient(135deg,#ede9fe,#ddd6fe)} .mc-ico-link svg{stroke:#6d28d9;}
    .mc-ico-note{background:linear-gradient(135deg,#fee2e2,#fecaca)} .mc-ico-note svg{stroke:#dc2626;}
    .mc-card-title h3{margin:0!important;font-size:17px!important;font-weight:700;color:#0f172a!important;}
    .mc-card-title p{margin:5px 0 0!important;font-size:13px!important;line-height:1.65;color:#64748b!important;}
    .mc-card-body{padding:22px 24px 24px;}
    .mc-section{display:flex;align-items:flex-end;justify-content:space-between;gap:14px;margin-bottom:14px;}
    .mc-section-label{display:inline-block;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#7c3aed;}
    .mc-section h4{margin:6px 0 0;font-size:20px;color:#0f172a;}
    .mc-chip,.mc-pill{display:inline-flex;align-items:center;padding:7px 11px;border-radius:999px;border:1px solid #e2e8f0;background:#fff;font-size:12px;color:#64748b;white-space:nowrap;}
    .mc-list{padding:14px;border:1px solid #e2e8f0;border-radius:18px;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);max-height:152px;overflow:auto;}
    .mc-page .hand{display:inline-flex!important;align-items:center;justify-content:center;padding:8px 14px!important;margin:4px!important;border-radius:10px;border:1px solid #dbe4ee!important;background:#fff!important;color:#475569!important;font-size:12px!important;font-weight:700!important;cursor:pointer;transition:transform .15s,border-color .15s,box-shadow .15s,color .15s,background .15s;font-family:'Microsoft YaHei','Segoe UI',sans-serif!important;}
    .mc-page .hand:hover{transform:translateY(-1px);border-color:#c084fc!important;background:#faf5ff!important;color:#7e22ce!important;box-shadow:0 10px 18px rgba(168,85,247,.10);}
    .mc-work{display:grid;grid-template-columns:minmax(0,.78fr) minmax(560px,1.22fr);gap:20px;margin-top:18px;align-items:start;}
    .mc-panel{padding:18px;border:1px solid #e2e8f0;border-radius:20px;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .mc-panel-head{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;}
    .mc-panel-title{font-size:16px;font-weight:700;color:#0f172a;}
    .mc-page #inputdiv{width:auto!important;max-width:none;margin:0!important;padding:0!important;}
    .mc-page .typepy{min-height:42px;padding:6px 0;font-family:Arial!important;font-size:26px!important;font-weight:700;text-align:center!important;color:#7c3aed!important;letter-spacing:1px;}
    .mc-page .typecn{min-height:66px;padding:4px 0 14px;font-size:44px!important;font-weight:700;text-align:center!important;color:#0f172a!important;line-height:1.25;}
    .mc-page .typewd{display:block!important;width:100%!important;height:68px!important;margin:0 auto!important;border:1px solid #c084fc!important;border-radius:18px!important;background:linear-gradient(180deg,#fdf4ff 0,#faf5ff 100%)!important;font-size:34px!important;font-weight:700;color:#0f172a!important;text-align:center!important;outline:none!important;transition:border-color .2s,box-shadow .2s;font-family:'Microsoft YaHei',sans-serif!important;}
    .mc-page .typewd:focus{border-color:#9333ea!important;box-shadow:0 0 0 4px rgba(147,51,234,.14)!important;}
    .mc-panel-note{margin-top:12px;padding:12px 14px;border-radius:14px;background:#f8fafc;border:1px solid #e2e8f0;font-size:13px;line-height:1.7;color:#64748b;}
    .mc-keyboard-wrap{display:flex;flex-direction:column;align-items:center;justify-content:flex-start;width:100%;min-height:260px;overflow:hidden;}
    .mc-page #keyboard{width:483px!important;max-width:none!important;margin:0 auto!important;padding:12px!important;background:#f8fafc;border-radius:18px;border:1px solid #e8ecf1;box-shadow:inset 0 1px 0 rgba(255,255,255,.8);}
    .mc-mini-list,.mc-nav,.mc-games{display:grid!important;gap:10px;}
    .mc-mini{display:grid!important;grid-template-columns:64px minmax(0,1fr);align-items:center;column-gap:16px;padding:16px;border-radius:18px;border:1px solid #e2e8f0;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .mc-mini > div{min-width:0;padding-top:2px;}
    .mc-mini-no{position:relative;display:grid!important;place-items:center!important;width:48px;height:48px;min-width:48px;padding:0!important;margin:0 auto;border-radius:16px;background:transparent!important;color:#b91c1c;font-size:18px;font-weight:800;line-height:1!important;text-align:center!important;flex-shrink:0;justify-self:center;isolation:isolate;overflow:hidden;}
    .mc-mini-no:before{content:"";position:absolute;inset:0;border-radius:inherit;background:linear-gradient(135deg,#fee2e2,#fecaca);z-index:-1;}
    .mc-mini strong,.mc-link-copy strong,.mc-game-copy strong{display:block;color:#0f172a;}
    .mc-mini strong{margin-bottom:4px;font-size:14px;} .mc-mini span{display:block;font-size:12px;line-height:1.7;color:#64748b;}
    .mc-link{display:flex!important;align-items:center;gap:12px;padding:14px!important;border-radius:16px;border:1.5px solid #e2e8f0!important;background:#fff!important;text-decoration:none!important;transition:transform .15s,box-shadow .15s,border-color .15s,background .15s;width:auto!important;height:auto!important;}
    .mc-link:hover,.mc-game:hover{transform:translateY(-2px);box-shadow:0 10px 20px rgba(15,23,42,.08);}
    .mc-link-icon,.mc-game-icon{display:flex!important;align-items:center;justify-content:center;flex-shrink:0;border-radius:12px;}
    .mc-link-icon{width:40px;height:40px;} .mc-link-icon svg{width:20px;height:20px;}
    .mc-link-copy,.mc-game-copy{display:flex;flex-direction:column;gap:3px;min-width:0;}
    .mc-link-copy strong,.mc-game-copy strong{font-size:14px;}
    .mc-link-copy em,.mc-mode-note,.mc-game-copy em{font-style:normal;font-size:12px;line-height:1.7;color:#64748b;}
    .mc-link-amber .mc-link-icon{background:linear-gradient(135deg,#fef3c7,#fde68a)} .mc-link-amber .mc-link-icon svg{stroke:#d97706;} .mc-link-amber:hover{border-color:#f59e0b!important;background:#fffbeb!important;}
    .mc-link-blue .mc-link-icon{background:linear-gradient(135deg,#dbeafe,#bfdbfe)} .mc-link-blue .mc-link-icon svg{stroke:#2563eb;} .mc-link-blue:hover{border-color:#60a5fa!important;background:#eff6ff!important;}
    .mc-link-current{border-color:#c084fc!important;background:#faf5ff!important;box-shadow:0 10px 20px rgba(168,85,247,.10);} .mc-link-current .mc-link-icon{background:linear-gradient(135deg,#f3e8ff,#d8b4fe)} .mc-link-current .mc-link-icon svg{stroke:#7c3aed;}
    .mc-mode-note{margin-top:14px;padding:12px 14px;border-radius:14px;border:1px solid #f5d0fe;background:linear-gradient(135deg,#fdf4ff,#faf5ff);color:#86198f;}
    .mc-stats-header{display:flex!important;align-items:center;gap:12px;margin-bottom:12px;}
    .mc-stats-header h3{margin:0!important;font-size:15px!important;font-weight:700;color:#0f172a!important;}
    .mc-progress-wrap{display:none;margin:12px 0 14px;}
    .mc-progress-label{display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;font-size:12px;color:#64748b;}
    .mc-progress-value{font-weight:700;color:#9333ea;}
    .mc-progress-bar{width:100%;height:10px;background:#f1f5f9;border-radius:999px;overflow:hidden;}
    .mc-progress-fill{height:100%;background:linear-gradient(90deg,#d8b4fe,#9333ea);border-radius:999px;transition:width .3s ease;}
    .mc-apple-stat{display:flex;align-items:center;gap:8px;padding:12px 14px;border-radius:14px;border:1px solid #e2e8f0;background:#fff;font-size:13px;font-weight:600;color:#475569;}
    .mc-apple-stat img{width:20px;height:20px;}
    .mc-page #apples{padding:10px 0 4px;font-size:13px;color:#7c3aed;min-height:24px;}
    .mc-page #msg,.mc-page #debug{padding:12px 14px;border-radius:14px;border:1px solid #e2e8f0;background:#f8fafc;font-size:12px;line-height:1.7;color:#64748b;min-height:44px;}
    .mc-page #debug{margin-top:10px;}
    .mc-page #keyboard .keyCom,.mc-page #keyboard .keyText,.mc-page #keyboard .tab,.mc-page #keyboard .cap,.mc-page #keyboard .shift,.mc-page #keyboard .ctrl,.mc-page #keyboard .alt,.mc-page #keyboard .enterup1,.mc-page #keyboard .enterup2,.mc-page #keyboard .key2,.mc-page #keyboard .keymic,.mc-page #keyboard .space{box-sizing:border-box;}
    .mc-game{display:flex!important;align-items:center;gap:12px;padding:14px 16px!important;border-radius:16px!important;border:1.5px solid #e2e8f0!important;background:linear-gradient(180deg,#fff 0,#f8fafc 100%)!important;text-decoration:none!important;transition:transform .15s,box-shadow .15s,border-color .15s,background .15s;width:auto!important;height:auto!important;cursor:pointer;}
    .mc-game:hover{border-color:#c7d2fe!important;background:#f8faff!important;}
    .mc-game-icon{width:36px;height:36px;} .mc-game-icon svg{width:16px;height:16px;}
    .mc-game-all{background:#ede9fe;} .mc-game-all svg{stroke:#7c3aed;}
    @media (min-width:1081px){.mc-sidebar{position:sticky!important;top:18px;}}
    @media (max-width:1080px){.mc-hero,.mc-grid,.mc-work{grid-template-columns:1fr!important;}}
    @media (max-width:768px){.mc-page{padding-top:10px}.mc-shell{padding:16px;border-radius:22px}.mc-hero{padding:20px;border-radius:20px}.mc-hero h1{font-size:26px}.mc-card-head,.mc-card-body{padding-left:18px;padding-right:18px}.mc-section,.mc-panel-head{flex-direction:column;align-items:flex-start}.mc-page .typecn{font-size:36px!important}.mc-page .typewd{font-size:30px!important;height:62px!important}}
</style>

<div class="mc-page">
    <div class="mc-shell">
        <div class="mc-hero">
            <div class="mc-hero-main">
                <span class="mc-badge">LearnSite Typing Lab</span>
                <h1>拼音打字练习</h1>
                <p>通过拼音提示、词语显示和即时录入，把输入节奏稳下来。练习时会自动统计苹果数量，适合做拼音输入热身和基础巩固。</p>
                <div class="mc-current">
                    <span class="mc-current-label">当前模式</span>
                    <span class="mc-current-value">拼音输入训练 · 键盘联动提示</span>
                </div>
            </div>
            <div class="mc-hero-side">
                <p class="mc-side-title">练习节奏</p>
                <div class="mc-steps">
                    <div class="mc-step"><strong>01</strong><span>先选择词库，再看上方拼音和汉字提示。</span></div>
                    <div class="mc-step"><strong>02</strong><span>边看边打，尽量保持连续，不要频繁停顿。</span></div>
                    <div class="mc-step"><strong>03</strong><span>完成后查看苹果数量变化，积累自己的输入稳定度。</span></div>
                </div>
            </div>
        </div>

        <div class="mc-grid">
            <div class="mc-main">
                <div class="mc-card">
                    <div class="mc-card-head">
                        <span class="mc-head-icon mc-ico-type"><svg viewBox="0 0 24 24"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg></span>
                        <div class="mc-card-title">
                            <h3>开始练习</h3>
                            <p>词库切换、拼音提示、汉字显示和输入区集中在同一块区域，便于连续练习。</p>
                        </div>
                    </div>
                    <div class="mc-card-body">
                        <div class="mc-section">
                            <div>
                                <span class="mc-section-label">词库目录</span>
                                <h4>选择当前训练内容</h4>
                            </div>
                            <span class="mc-chip">点击标题即可切换</span>
                        </div>
                        <div class="mc-list">
                            <asp:DataList ID="DataList1" runat="server" CellPadding="3" HorizontalAlign="Center" onitemdatabound="DataList1_ItemDataBound" RepeatDirection="Horizontal" RepeatLayout="Flow" CellSpacing="3">
                                <ItemTemplate>
                                    <asp:Label ID="Lbtitle" runat="server" Text='<%# Eval("Ntitle") %>' CssClass="hand"></asp:Label>
                                    <asp:Label ID="Lbid" runat="server" Text='<%# Eval("nid") %>' Visible="false"></asp:Label>
                                </ItemTemplate>
                            </asp:DataList>
                        </div>

                        <div class="mc-work">
                            <div class="mc-panel">
                                <div class="mc-panel-head">
                                    <span class="mc-panel-title">词语提示区</span>
                                    <span class="mc-pill">拼音 + 汉字同步显示</span>
                                </div>
                                <div id="inputdiv">
                                    <asp:Label ID="Lbnid" runat="server" Text="0" CssClass="unsee"></asp:Label>
                                    <div id="Typepingyin" class="typepy"></div>
                                    <div id="Typechinese" class="typecn"></div>
                                    <input id="InputWord" class="typewd" type="text" onpaste="return false;" ondragenter="return false;" ondrop="return false;" tabindex="0" autocomplete="off" />
                                </div>
                                <div class="mc-panel-note">建议先把拼音完整看清，再开始录入。这样更容易兼顾准确率和速度。</div>
                            </div>

                            <div class="mc-panel">
                                <div class="mc-panel-head">
                                    <span class="mc-panel-title">键盘提示区</span>
                                    <span class="mc-pill">保持指法节奏</span>
                                </div>
                                <div class="mc-keyboard-wrap">
                                    <div id="keyboard">
<!--第一行-->
	<div class="keyCom" id="keyDHSY">~<br />`</div><div class="keyCom" id="key1">!<br />1</div>
	<div class="keyCom" id="key2">@<br />2</div><div class="keyCom" id="key3">#<br />3</div>
	<div class="keyCom" id="key4">$<br />4</div><div class="keyCom" id="key5">%<br />5</div>
	<div class="keyCom" id="key6">^<br />6</div><div class="keyCom" id="key7">&amp;<br />7</div>
	<div class="keyCom" id="key8">*<br />8</div><div class="keyCom" id="key9">(<br />9</div>
	<div class="keyCom" id="key0">)<br />0</div><div class="keyCom" id="keyJHSX">_<br />-</div>
	<div class="keyCom" id="keyDHJH">+<br />=</div><div class="keyCom" id="keyXXSX">|<br />\</div>
	<div class="key2 keyText">←</div>
<!--第二行-->
	<div class="tab keyText">Tab</div><div class="keyCom" id="keyQ">q</div>
	<div class="keyCom" id="keyW">w</div><div class="keyCom" id="keyE">e</div>
	<div class="keyCom" id="keyR">r</div><div class="keyCom" id="keyT">t</div>
	<div class="keyCom" id="keyY">y</div><div class="keyCom" id="keyU">u</div>
	<div class="keyCom" id="keyI">i</div><div class="keyCom" id="keyO">o</div>
	<div class="keyCom" id="keyP">p</div><div class="keyCom" id="keyZKH">{<br />[</div>
	<div class="keyCom" id="keyYKH">}<br />]</div><div class="enterup1 keyText"></div>
<!--第三行-->
	<div class="cap keyText">Caps</div><div class="keyCom" id="keyA">a</div>
	<div class="keyCom" id="keyS">s</div><div class="keyCom" id="keyD">d</div>
	<div class="keyCom" id="keyF">f</div><div class="keyCom" id="keyG">g</div>
	<div class="keyCom" id="keyH">h</div><div class="keyCom" id="keyJ">j</div>
	<div class="keyCom" id="keyK">k</div><div class="keyCom" id="keyL">l</div>
	<div class="keyCom" id="keyFHMH">:<br />;</div><div class="keyCom" id="keyDYSY">"<br />'</div>
	<div class="enterup2 keyText">Enter</div>
<!--第四行-->
	<div class="shift keyText" id="shiftl">Shift</div><div class="keyCom" id="keyZ">z</div>
	<div class="keyCom" id="keyX">x</div><div class="keyCom" id="keyC">c</div>
	<div class="keyCom" id="keyV">v</div><div class="keyCom" id="keyB">b</div>
	<div class="keyCom" id="keyN">n</div><div class="keyCom" id="keyM">m</div>
	<div class="keyCom" id="keyDHXY">&lt;<br />,</div><div class="keyCom" id="keyJHDY">&gt;<br />.</div>
	<div class="keyCom" id="keyXXWH">?<br />/</div><div class="shift keyText" id="shiftr">Shift</div>
<!--第五行-->
	<div class="ctrl keyText">Ctrl</div><div class="keymic keyText"></div>
	<div class="alt keyText">Alt</div><div class="space keyText" id="keyKG"></div>
	<div class="alt keyText">Alt</div><div class="keymic keyText"></div><div class="ctrl keyText">Ctrl</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mc-sidebar">
                <div class="mc-card">
                    <div class="mc-card-head">
                        <span class="mc-head-icon mc-ico-note"><svg viewBox="0 0 24 24"><path d="M12 8v4"></path><path d="M12 16h.01"></path><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path></svg></span>
                        <div class="mc-card-title">
                            <h3>练习建议</h3>
                            <p>拼音输入更适合先准后快，别急着抢速度。</p>
                        </div>
                    </div>
                    <div class="mc-card-body">
                        <div class="mc-mini-list">
                            <div class="mc-mini"><span class="mc-mini-no">1</span><div><strong>先看拼音</strong><span>先把拼音串读顺，再下手输入，错误会明显减少。</span></div></div>
                            <div class="mc-mini"><span class="mc-mini-no">2</span><div><strong>短词多轮</strong><span>同一组词多练几轮，比一次练很久更容易形成手感。</span></div></div>
                            <div class="mc-mini"><span class="mc-mini-no">3</span><div><strong>关注苹果数</strong><span>苹果数量能直观看出你这轮练习的稳定度和完成度。</span></div></div>
                        </div>
                    </div>
                </div>

                <div class="mc-card">
                    <div class="mc-card-head">
                        <span class="mc-head-icon mc-ico-nav"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg></span>
                        <div class="mc-card-title">
                            <h3>打字模式</h3>
                            <p>在三种打字入口之间快速切换，同时保留本页练习统计。</p>
                        </div>
                    </div>
                    <div class="mc-card-body">
                        <div class="mc-nav">
                            <asp:HyperLink ID="HChinese" runat="server" NavigateUrl="~/student/mychinese.aspx" CssClass="mc-link mc-link-current">
                                <span class="mc-link-icon"><svg viewBox="0 0 24 24"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg></span>
                                <span class="mc-link-copy"><strong>拼音模式</strong><em>适合拼音输入和词语联想训练</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HkFinger" runat="server" NavigateUrl="~/student/myfinger.aspx" CssClass="mc-link mc-link-blue">
                                <span class="mc-link-icon"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2"></rect><path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M8 12h.01M12 12h.01M16 12h.01M7 16h10"></path></svg></span>
                                <span class="mc-link-copy"><strong>英文模式</strong><em>适合键位与英文单词训练</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HTyper" runat="server" NavigateUrl="~/student/mytype.aspx" CssClass="mc-link mc-link-amber">
                                <span class="mc-link-icon"><svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"></path><path d="M9 20h6"></path><path d="M12 4v16"></path></svg></span>
                                <span class="mc-link-copy"><strong>中文模式</strong><em>适合篇章跟打和速度提升</em></span>
                            </asp:HyperLink>
                        </div>

                        <div class="mc-stats-header" style="margin-top:18px;">
                            <span class="mc-head-icon mc-ico-link"><svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg></span>
                            <h3>练习统计</h3>
                        </div>
                        <div class="mc-progress-wrap" id="appleProgress">
                            <div class="mc-progress-label">
                                <span>收集进度</span>
                                <span class="mc-progress-value" id="appleValue">0个苹果</span>
                            </div>
                            <div class="mc-progress-bar">
                                <div class="mc-progress-fill" id="appleFill" style="width:0%"></div>
                            </div>
                        </div>
                        <div id="oldspd" class="mc-apple-stat">
                            <img src="../images/apple.gif" alt="" />收集的苹果数：<span id="totalapples"></span>
                        </div>
                        <div id="apples" class="applecss"></div>
                        <div id="msg"></div>
                        <div id="debug"></div>
                        <div class="mc-mode-note">苹果数量会随着练习变化自动刷新，适合做一轮轮短时拼音输入挑战。</div>
                    </div>
                </div>

                <div class="mc-card">
                    <div class="mc-card-head">
                        <span class="mc-head-icon mc-ico-rank"><svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg></span>
                        <div class="mc-card-title">
                            <h3>更多活动</h3>
                            <p>继续查看拼音输入排行，看看自己的整体表现。</p>
                        </div>
                    </div>
                    <div class="mc-card-body">
                        <div class="mc-games">
                            <asp:HyperLink ID="HLfinger" runat="server" NavigateUrl="~/student/allchinese.aspx" Target="_blank" CssClass="mc-game">
                                <span class="mc-game-icon mc-game-all"><svg viewBox="0 0 24 24"><path d="M12 15l-2 5-1.5-3.5L5 15l3.5-1.5L12 8l3.5 5.5L19 15l-3.5 1.5L14 20z"></path></svg></span>
                                <span class="mc-game-copy"><strong>拼音输入英雄榜</strong><em>查看全站拼音输入成绩排行</em></span>
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
    <script src="../js/pydic.js" type="text/javascript"></script>
    <script src="../js/Chinese.js" type="text/javascript"></script>
    <script type="text/javascript">
    function updateAppleProgress() {
        var totalApplesElem = document.getElementById('totalapples');
        if (totalApplesElem && totalApplesElem.textContent) {
            var appleCount = parseInt(totalApplesElem.textContent, 10) || 0;
            var progressWrap = document.getElementById('appleProgress');
            var progressValue = document.getElementById('appleValue');
            var progressFill = document.getElementById('appleFill');

            if (progressWrap && progressValue && progressFill && appleCount > 0) {
                progressWrap.style.display = 'block';
                progressValue.textContent = appleCount + '个苹果';
                var maxApples = 100;
                var percentage = Math.min((appleCount / maxApples) * 100, 100);
                progressFill.style.width = percentage + '%';

                if (appleCount >= 80) {
                    progressFill.style.background = 'linear-gradient(90deg, #c084fc, #9333ea)';
                    progressValue.style.color = '#9333ea';
                } else if (appleCount >= 40) {
                    progressFill.style.background = 'linear-gradient(90deg, #d8b4fe, #c084fc)';
                    progressValue.style.color = '#a855f7';
                } else {
                    progressFill.style.background = 'linear-gradient(90deg, #e9d5ff, #d8b4fe)';
                    progressValue.style.color = '#c084fc';
                }
            }
        }
    }

    if (typeof MutationObserver !== 'undefined') {
        var observer = new MutationObserver(function() {
            updateAppleProgress();
        });

        var totalApplesElement = document.getElementById('totalapples');
        if (totalApplesElement) {
            observer.observe(totalApplesElement, {
                childList: true,
                characterData: true,
                subtree: true
            });
        }
    }

    setTimeout(updateAppleProgress, 500);
    setInterval(updateAppleProgress, 2000);
    </script>
</asp:Content>
