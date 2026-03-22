<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_myfinger, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
    <link href="../images/fingering/finger.css" rel="stylesheet" type="text/css" />
<style>
    .mf-page,.mf-page *{box-sizing:border-box;margin-right:unset!important;margin-left:unset!important;}
    .mf-page table{border-collapse:collapse!important;border-color:transparent!important;}
    .mf-page .buttonimg,.mf-page .buttonnone{background-image:none!important;border-width:0!important;width:auto!important;height:auto!important;}
    .mf-page{display:flex;justify-content:center;width:100%;padding:20px 0 34px;font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif!important;color:#0f172a;animation:mfFadeIn .45s ease;}
    @keyframes mfFadeIn{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
    .mf-shell{position:relative;flex:0 1 1560px;width:min(1560px,calc(100vw - 24px));margin:0 auto;padding:30px;border-radius:30px;overflow:hidden;background:radial-gradient(circle at top left,rgba(59,130,246,.14),transparent 32%),radial-gradient(circle at top right,rgba(14,165,233,.16),transparent 24%),linear-gradient(180deg,#f7fbff 0,#f8fafc 100%);box-shadow:0 20px 45px rgba(15,23,42,.08);}
    .mf-shell:before{content:"";position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.62),rgba(255,255,255,0));pointer-events:none;}
    .mf-hero,.mf-grid{position:relative;z-index:1;}
    .mf-hero{display:grid;grid-template-columns:minmax(0,1.5fr) 340px;gap:22px;margin-bottom:24px;padding:30px;border-radius:26px;background:linear-gradient(135deg,#eff6ff 0,#f0f9ff 45%,#f8fafc 100%);color:#0f172a;border:1px solid rgba(148,163,184,.18);overflow:hidden;}
    .mf-hero:after{content:"";position:absolute;top:-72px;right:-64px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.42);}
    .mf-hero-main,.mf-hero-side{position:relative;z-index:1;}
    .mf-badge{display:inline-flex;align-items:center;padding:8px 12px;border-radius:999px;border:1px solid rgba(37,99,235,.12);background:rgba(255,255,255,.72);font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb;}
    .mf-hero h1{margin:14px 0 10px;font-size:32px;line-height:1.12;color:#0f172a;}
    .mf-hero p{margin:0;max-width:660px;font-size:15px;line-height:1.8;color:#475569;}
    .mf-current{display:inline-flex;flex-wrap:wrap;align-items:center;gap:14px;margin-top:22px;padding:14px 16px;border-radius:18px;background:rgba(255,255,255,.76);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .mf-current-label{font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb;}
    .mf-current-value{display:flex;flex-wrap:wrap;gap:8px;font-size:18px;font-weight:700;color:#0f172a;}
    .mf-hero-side{padding:22px;border-radius:22px;background:rgba(255,255,255,.78);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .mf-side-title{margin:0 0 14px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#ea580c;}
    .mf-steps{display:grid;gap:12px;}
    .mf-step{display:flex;align-items:flex-start;gap:10px;font-size:14px;line-height:1.7;color:#334155;}
    .mf-step strong{display:inline-flex;align-items:center;justify-content:center;width:28px;height:28px;border-radius:10px;background:rgba(37,99,235,.10);color:#2563eb;font-size:12px;flex-shrink:0;}
    .mf-grid{display:grid!important;grid-template-columns:minmax(0,1fr) 380px;gap:26px;align-items:start;}
    .mf-main,.mf-sidebar{min-width:0;}
    .mf-sidebar{display:flex!important;flex-direction:column;gap:18px;}
    .mf-card{background:rgba(255,255,255,.94)!important;border:1px solid #e2e8f0!important;border-radius:24px;box-shadow:0 14px 30px rgba(15,23,42,.05);overflow:hidden;}
    .mf-card-head{display:flex!important;gap:14px;align-items:flex-start;padding:22px 24px 18px;border-bottom:1px solid #eef2f7!important;background:linear-gradient(180deg,rgba(255,255,255,.94),rgba(247,250,252,.94))!important;}
    .mf-head-icon{width:44px;height:44px;border-radius:14px;display:flex!important;align-items:center;justify-content:center;flex-shrink:0;}
    .mf-head-icon svg,.mf-link-icon svg,.mf-game-icon svg{fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .mf-head-icon svg{width:21px;height:21px;}
    .mf-ico-type{background:linear-gradient(135deg,#dbeafe,#bfdbfe)} .mf-ico-type svg{stroke:#2563eb;}
    .mf-ico-nav{background:linear-gradient(135deg,#ede9fe,#ddd6fe)} .mf-ico-nav svg{stroke:#6d28d9;}
    .mf-ico-rank{background:linear-gradient(135deg,#fef3c7,#fde68a)} .mf-ico-rank svg{stroke:#d97706;}
    .mf-ico-link{background:linear-gradient(135deg,#d1fae5,#a7f3d0)} .mf-ico-link svg{stroke:#059669;}
    .mf-ico-note{background:linear-gradient(135deg,#fee2e2,#fecaca)} .mf-ico-note svg{stroke:#dc2626;}
    .mf-card-title h3{margin:0!important;font-size:17px!important;font-weight:700;color:#0f172a!important;}
    .mf-card-title p{margin:5px 0 0!important;font-size:13px!important;line-height:1.65;color:#64748b!important;}
    .mf-card-body{padding:22px 24px 24px;}
    .mf-section{display:flex;align-items:flex-end;justify-content:space-between;gap:14px;margin-bottom:14px;}
    .mf-section-label{display:inline-block;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb;}
    .mf-section h4{margin:6px 0 0;font-size:20px;color:#0f172a;}
    .mf-chip,.mf-pill{display:inline-flex;align-items:center;padding:7px 11px;border-radius:999px;border:1px solid #e2e8f0;background:#fff;font-size:12px;color:#64748b;white-space:nowrap;}
    .mf-work{display:grid;grid-template-columns:minmax(0,.82fr) minmax(560px,1.18fr);gap:20px;margin-top:18px;align-items:start;}
    .mf-panel{padding:18px;border:1px solid #e2e8f0;border-radius:20px;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .mf-panel-head{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;}
    .mf-panel-title{font-size:16px;font-weight:700;color:#0f172a;}
    .mf-page #inputdiv{width:auto!important;max-width:520px;margin:0 auto!important;padding:0!important;}
    .mf-page .showtxt{min-height:66px;padding:6px 0 8px;font-family:Georgia,'Times New Roman',serif!important;font-size:42px!important;font-weight:700;text-align:center!important;color:#0f172a!important;line-height:1.2;letter-spacing:2px;}
    .mf-page .wrongchar{color:#ef4444!important;}
    .mf-page .meandiv{width:auto!important;max-width:420px;min-height:54px;margin:0 auto 12px!important;padding:12px 16px!important;border:1px solid #dbe7f0!important;border-radius:16px!important;background:#fff!important;color:#64748b!important;font-size:13px!important;line-height:1.7;text-align:center!important;}
    .mf-page .inputtxt{display:block!important;width:100%!important;height:66px!important;margin:0 auto!important;padding:0 18px!important;border:1px solid #93c5fd!important;border-radius:18px!important;background:linear-gradient(180deg,#f8fbff 0,#eff6ff 100%)!important;font-family:Georgia,'Times New Roman',serif!important;font-size:34px!important;font-weight:700;color:#0f172a!important;text-align:center!important;outline:none!important;transition:border-color .2s,box-shadow .2s;}
    .mf-page .inputtxt:focus{border-color:#2563eb!important;box-shadow:0 0 0 4px rgba(37,99,235,.14)!important;}
    .mf-panel-note{margin-top:12px;padding:12px 14px;border-radius:14px;background:#f8fafc;border:1px solid #e2e8f0;font-size:13px;line-height:1.7;color:#64748b;}
    .mf-keyboard-wrap{display:flex;flex-direction:column;align-items:center;justify-content:flex-start;gap:14px;width:100%;min-height:280px;overflow:hidden;}
    .mf-page #keyhand{width:483px!important;max-width:none!important;height:233px!important;margin:0 auto;background-size:483px 233px;background-repeat:no-repeat;background-position:center top;}
    .mf-page #keyboard{width:483px!important;max-width:none!important;margin:0 auto!important;padding:12px!important;background:#f8fafc;border-radius:18px;border:1px solid #e8ecf1;box-shadow:inset 0 1px 0 rgba(255,255,255,.8);}
    .mf-mini-list,.mf-nav,.mf-games{display:grid!important;gap:10px;}
    .mf-mini{display:grid!important;grid-template-columns:64px minmax(0,1fr);align-items:center;column-gap:16px;padding:16px;border-radius:18px;border:1px solid #e2e8f0;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .mf-mini > div{min-width:0;padding-top:2px;}
    .mf-mini-no{position:relative;display:grid!important;place-items:center!important;width:48px;height:48px;min-width:48px;padding:0!important;margin:0 auto;border-radius:16px;background:transparent!important;color:#1d4ed8;font-size:18px;font-weight:800;line-height:1!important;text-align:center!important;flex-shrink:0;justify-self:center;isolation:isolate;overflow:hidden;}
    .mf-mini-no:before{content:"";position:absolute;inset:0;border-radius:inherit;background:linear-gradient(135deg,#dbeafe,#bfdbfe);z-index:-1;}
    .mf-mini strong,.mf-link-copy strong,.mf-game-copy strong{display:block;color:#0f172a;}
    .mf-mini strong{margin-bottom:4px;font-size:14px;} .mf-mini span{display:block;font-size:12px;line-height:1.7;color:#64748b;}
    .mf-link{display:flex!important;align-items:center;gap:12px;padding:14px!important;border-radius:16px;border:1.5px solid #e2e8f0!important;background:#fff!important;text-decoration:none!important;transition:transform .15s,box-shadow .15s,border-color .15s,background .15s;width:auto!important;height:auto!important;}
    .mf-link:hover,.mf-game:hover{transform:translateY(-2px);box-shadow:0 10px 20px rgba(15,23,42,.08);}
    .mf-link-icon,.mf-game-icon{display:flex!important;align-items:center;justify-content:center;flex-shrink:0;border-radius:12px;}
    .mf-link-icon{width:40px;height:40px;} .mf-link-icon svg{width:20px;height:20px;}
    .mf-link-copy,.mf-game-copy{display:flex;flex-direction:column;gap:3px;min-width:0;}
    .mf-link-copy strong,.mf-game-copy strong{font-size:14px;}
    .mf-link-copy em,.mf-mode-note,.mf-game-copy em{font-style:normal;font-size:12px;line-height:1.7;color:#64748b;}
    .mf-link-violet .mf-link-icon{background:linear-gradient(135deg,#f3e8ff,#e9d5ff)} .mf-link-violet .mf-link-icon svg{stroke:#9333ea;} .mf-link-violet:hover{border-color:#c084fc!important;background:#faf5ff!important;}
    .mf-link-blue .mf-link-icon{background:linear-gradient(135deg,#dbeafe,#bfdbfe)} .mf-link-blue .mf-link-icon svg{stroke:#2563eb;} .mf-link-blue:hover{border-color:#60a5fa!important;background:#eff6ff!important;}
    .mf-link-green .mf-link-icon{background:linear-gradient(135deg,#dcfce7,#bbf7d0)} .mf-link-green .mf-link-icon svg{stroke:#16a34a;} .mf-link-green:hover{border-color:#4ade80!important;background:#f0fdf4!important;}
    .mf-link-current{border-color:#60a5fa!important;background:#eff6ff!important;box-shadow:0 10px 20px rgba(59,130,246,.10);} .mf-link-current .mf-link-icon{background:linear-gradient(135deg,#dbeafe,#93c5fd)} .mf-link-current .mf-link-icon svg{stroke:#1d4ed8;}
    .mf-mode-note{margin-top:14px;padding:12px 14px;border-radius:14px;border:1px solid #bfdbfe;background:linear-gradient(135deg,#eff6ff,#f8fbff);color:#1d4ed8;}
    .mf-stats{display:grid;gap:10px;}
    .mf-page .letter{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:12px 14px;border-radius:14px;border:1px solid #e2e8f0;background:#fff;font-size:13px;font-weight:600;color:#475569;line-height:1.6;min-height:48px;}
    .mf-page .letter:empty{display:none!important;}
    .mf-page #oldspd{color:#2563eb!important;}
    .mf-progress-wrap{display:none;margin-bottom:12px;}
    .mf-progress-label{display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;font-size:12px;color:#64748b;}
    .mf-progress-value{font-weight:700;color:#2563eb;}
    .mf-progress-bar{width:100%;height:10px;background:#f1f5f9;border-radius:999px;overflow:hidden;}
    .mf-progress-fill{height:100%;background:linear-gradient(90deg,#93c5fd,#2563eb);border-radius:999px;transition:width .3s ease;}
    .mf-page #msg{padding:12px 14px;border-radius:14px;border:1px solid #e2e8f0;background:#f8fafc;font-size:12px;line-height:1.7;color:#64748b;min-height:44px;}
    .mf-page #victory{text-align:center;padding:8px 0 0;}
    .mf-page #victory img{max-width:108px;border-radius:10px;}
    .mf-page #keyboard .keyCom,.mf-page #keyboard .keyText,.mf-page #keyboard .tab,.mf-page #keyboard .cap,.mf-page #keyboard .shift,.mf-page #keyboard .ctrl,.mf-page #keyboard .alt,.mf-page #keyboard .enterup1,.mf-page #keyboard .enterup2,.mf-page #keyboard .key2,.mf-page #keyboard .keymic,.mf-page #keyboard .space{box-sizing:border-box;}
    .mf-game{display:flex!important;align-items:center;gap:12px;padding:14px 16px!important;border-radius:16px!important;border:1.5px solid #e2e8f0!important;background:linear-gradient(180deg,#fff 0,#f8fafc 100%)!important;text-decoration:none!important;transition:transform .15s,box-shadow .15s,border-color .15s,background .15s;width:auto!important;height:auto!important;cursor:pointer;}
    .mf-game:hover{border-color:#c7d2fe!important;background:#f8faff!important;}
    .mf-game-icon{width:36px;height:36px;} .mf-game-icon svg{width:16px;height:16px;}
    .mf-game-rank{background:#dbeafe;} .mf-game-rank svg{stroke:#2563eb;}
    .mf-game-space{background:#fef3c7;} .mf-game-space svg{stroke:#d97706;}
    .mf-game-box{background:#ffedd5;} .mf-game-box svg{stroke:#ea580c;}
    .mf-game-chess{background:#d1fae5;} .mf-game-chess svg{stroke:#059669;}
    .mf-game-more{background:#ede9fe;} .mf-game-more svg{stroke:#7c3aed;}
    .mf-game-disabled,.mf-game-disabled:hover{
        background:linear-gradient(180deg,#f3f4f6 0,#e5e7eb 100%)!important;
        border-color:#d1d5db!important;
        box-shadow:none!important;
        transform:none!important;
        cursor:not-allowed!important;
        pointer-events:none!important;
        filter:grayscale(1);
        opacity:.82;
    }
    .mf-game-disabled .mf-game-copy strong,
    .mf-game-disabled .mf-game-copy em{color:#6b7280!important;}
    .mf-game-disabled .mf-game-icon{background:#e5e7eb!important;}
    .mf-game-disabled .mf-game-icon svg{stroke:#9ca3af!important;}
    .mf-game-disabled-note{
        margin-top:12px;
        padding:12px 14px;
        border-radius:14px;
        border:1px dashed #cbd5e1;
        background:#f8fafc;
        font-size:12px;
        line-height:1.7;
        color:#64748b;
        display:none;
    }
    @media (min-width:1081px){.mf-sidebar{position:sticky!important;top:18px;}}
    @media (max-width:1080px){.mf-hero,.mf-grid,.mf-work{grid-template-columns:1fr!important;}}
    @media (max-width:768px){.mf-page{padding-top:10px}.mf-shell{padding:16px;border-radius:22px}.mf-hero{padding:20px;border-radius:20px}.mf-hero h1{font-size:26px}.mf-card-head,.mf-card-body{padding-left:18px;padding-right:18px}.mf-section,.mf-panel-head,.mf-progress-label{flex-direction:column;align-items:flex-start}.mf-page .showtxt{font-size:34px!important}.mf-page .inputtxt{font-size:28px!important;height:60px!important}}
</style>

<div class="mf-page">
    <div class="mf-shell">
        <div class="mf-hero">
            <div class="mf-hero-main">
                <span class="mf-badge">LearnSite Typing Lab</span>
                <h1>英文打字练习</h1>
                <p>把英文单词训练、键位提示和速度统计整合在一页里。练习时会自动朗读当前单词、记录正确率和一分钟速度，适合英语输入、编程单词和课堂热身。</p>
                <div class="mf-current">
                    <span class="mf-current-label">当前训练</span>
                    <span class="mf-current-value">英文单词输入 · 键盘联动提示 · 自动统计速度</span>
                </div>
            </div>
            <div class="mf-hero-side">
                <p class="mf-side-title">练习节奏</p>
                <div class="mf-steps">
                    <div class="mf-step"><strong>01</strong><span>先选择级别，再看单词和释义，确认本轮练习范围。</span></div>
                    <div class="mf-step"><strong>02</strong><span>对照键位提示连续输入，先求稳，再慢慢提速。</span></div>
                    <div class="mf-step"><strong>03</strong><span>右侧会实时显示正确率、最快速度和累计打字时间。</span></div>
                </div>
            </div>
        </div>

        <div class="mf-grid">
            <div class="mf-main">
                <div class="mf-card">
                    <div class="mf-card-head">
                        <span class="mf-head-icon mf-ico-type"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M8 12h.01M12 12h.01M16 12h.01M7 16h10"/></svg></span>
                        <div class="mf-card-title">
                            <h3>练习工作台</h3>
                            <p>上方显示英文单词和释义，下方给出手型或键盘提示，输入框会按当前字符同步校验。</p>
                        </div>
                    </div>
                    <div class="mf-card-body">
                        <div class="mf-section">
                            <div>
                                <span class="mf-section-label">Practice</span>
                                <h4>单词输入区</h4>
                            </div>
                            <span class="mf-pill">自动朗读开启后会跟随新单词播放</span>
                        </div>

                        <div class="mf-work">
                            <div class="mf-panel">
                                <div class="mf-panel-head">
                                    <span class="mf-panel-title">当前单词</span>
                                    <span class="mf-chip">输入完成后自动切换下一词</span>
                                </div>
                                <div id="inputdiv">
                                    <div id="TextWord" class="showtxt"></div>
                                    <div id="Meanword" class="meandiv"></div>
                                    <input id="InputWord" type="text" class="inputtxt" onpaste="return false;" ondragenter="return false;" ondrop="return false;" tabindex="0" autocomplete="off" />
                                </div>
                                <div class="mf-panel-note">建议用实体键盘练习。单词会按字符位置给出高亮键位，输错的字母会在上方单词中直接标红。</div>
                            </div>

                            <div class="mf-panel">
                                <div class="mf-panel-head">
                                    <span class="mf-panel-title">键位提示</span>
                                    <span class="mf-chip">首轮显示手型，随后切换到完整键盘</span>
                                </div>
                                <div class="mf-keyboard-wrap">
                                    <div id="keyhand"></div>
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
	<div class="tab keyText">Tab</div><div class="keyCom" id="keyQ">Q</div>
	<div class="keyCom" id="keyW">W</div><div class="keyCom" id="keyE">E</div>
	<div class="keyCom" id="keyR">R</div><div class="keyCom" id="keyT">T</div>
	<div class="keyCom" id="keyY">Y</div><div class="keyCom" id="keyU">U</div>
	<div class="keyCom" id="keyI">I</div><div class="keyCom" id="keyO">O</div>
	<div class="keyCom" id="keyP">P</div><div class="keyCom" id="keyZKH">{<br />[</div>
	<div class="keyCom" id="keyYKH">}<br />]</div><div class="enterup1 keyText"></div>
<!--第三行-->
	<div class="cap keyText">Caps</div><div class="keyCom" id="keyA">A</div>
	<div class="keyCom" id="keyS">S</div><div class="keyCom" id="keyD">D</div>
	<div class="keyCom" id="keyF">F</div><div class="keyCom" id="keyG">G</div>
	<div class="keyCom" id="keyH">H</div><div class="keyCom" id="keyJ">J</div>
	<div class="keyCom" id="keyK">K</div><div class="keyCom" id="keyL">L</div>
	<div class="keyCom" id="keyFHMH">:<br />;</div><div class="keyCom" id="keyDYSY">"<br />'</div>
	<div class="enterup2 keyText">Enter</div>
<!--第四行-->
	<div class="shift keyText" id="shiftl">Shift</div><div class="keyCom" id="keyZ">Z</div>
	<div class="keyCom" id="keyX">X</div><div class="keyCom" id="keyC">C</div>
	<div class="keyCom" id="keyV">V</div><div class="keyCom" id="keyB">B</div>
	<div class="keyCom" id="keyN">N</div><div class="keyCom" id="keyM">M</div>
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

            <div class="mf-sidebar">
                <div class="mf-card">
                    <div class="mf-card-head">
                        <span class="mf-head-icon mf-ico-nav"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></span>
                        <div class="mf-card-title">
                            <h3>训练设置</h3>
                            <p>在三种输入模式之间切换，并设置当前英文词库级别。</p>
                        </div>
                    </div>
                    <div class="mf-card-body">
                        <div class="mf-nav">
                            <asp:HyperLink ID="HChinese" runat="server" NavigateUrl="~/student/mychinese.aspx" CssClass="mf-link mf-link-violet">
                                <span class="mf-link-icon"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg></span>
                                <span class="mf-link-copy"><strong>拼音输入</strong><em>练拼音和词语联动输入</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HkFinger" runat="server" NavigateUrl="~/student/myfinger.aspx" CssClass="mf-link mf-link-blue mf-link-current">
                                <span class="mf-link-icon"><svg viewBox="0 0 24 24"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M8 12h.01M12 12h.01M16 12h.01M7 16h10"/></svg></span>
                                <span class="mf-link-copy"><strong>英文输入</strong><em>当前页面，带键位和速度统计</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="HTyper" runat="server" NavigateUrl="~/student/mytype.aspx" CssClass="mf-link mf-link-green">
                                <span class="mf-link-icon"><svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"/><path d="M9 20h6"/><path d="M12 4v16"/></svg></span>
                                <span class="mf-link-copy"><strong>中文输入</strong><em>跟打整篇内容，查看速度排行</em></span>
                            </asp:HyperLink>
                        </div>
                        <div class="mf-mode-note">建议先从“编程英语”或自己熟悉的词库开始，稳定后再提升难度。</div>
                        <div style="height:16px"></div>
                        <div class="mf-section">
                            <div>
                                <span class="mf-section-label">Level</span>
                                <h4>选择词库</h4>
                            </div>
                        </div>
                        <select name="ls" id="levelselect" onchange="changelevel()">
                            <option value="0">小学英语</option>
                            <option value="1">中考英语</option>
                            <option value="2">高考英语</option>
                            <option value="3" selected="selected">编程英语</option>
                        </select>
                    </div>
                </div>

                <div class="mf-card">
                    <div class="mf-card-head">
                        <span class="mf-head-icon mf-ico-link"><svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg></span>
                        <div class="mf-card-title">
                            <h3>练习统计</h3>
                            <p>速度、正确率和最佳成绩都会在这里实时刷新。</p>
                        </div>
                    </div>
                    <div class="mf-card-body">
                        <div id="snum" style="display:none"><%=this.mysnum%></div>
                        <div class="mf-progress-wrap" id="mfAccuracyWrap">
                            <div class="mf-progress-label">
                                <span>正确率进度</span>
                                <span class="mf-progress-value" id="mfAccuracyValue">0%</span>
                            </div>
                            <div class="mf-progress-bar">
                                <div class="mf-progress-fill" id="mfAccuracyFill" style="width:0%"></div>
                            </div>
                        </div>
                        <div class="mf-stats">
                            <div id="lrpe" class="letter"></div>
                            <div id="lnum" class="letter"></div>
                            <div id="lrig" class="letter"></div>
                            <div id="lwrg" class="letter"></div>
                            <div id="wnum" class="letter"></div>
                            <div id="lspd" class="letter"></div>
                            <div id="wspd" class="letter"></div>
                            <div id="lsec" class="letter"></div>
                            <div id="weid" class="letter"></div>
                            <div id="oldspd" runat="server" class="letter"></div>
                        </div>
                        <div style="height:10px"></div>
                        <div id="msg"></div>
                        <div id="victory" style="display:none">
                            <img src="../js/images/v.gif" alt="" />
                        </div>
                    </div>
                </div>

                <div class="mf-card">
                    <div class="mf-card-head">
                        <span class="mf-head-icon mf-ico-note"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M12 4h9"/><path d="M4 9h16"/><path d="M4 15h10"/></svg></span>
                        <div class="mf-card-title">
                            <h3>训练建议</h3>
                            <p>保持节奏比一开始追求速度更重要。</p>
                        </div>
                    </div>
                    <div class="mf-card-body">
                        <div class="mf-mini-list">
                            <div class="mf-mini"><span class="mf-mini-no">01</span><div><strong>先盯正确率</strong><span>当正确率稳定在 95% 左右，再去追一分钟单词速度。</span></div></div>
                            <div class="mf-mini"><span class="mf-mini-no">02</span><div><strong>看键位不看手</strong><span>用页面手型和键盘提示建立肌肉记忆，减少低头找键。</span></div></div>
                            <div class="mf-mini"><span class="mf-mini-no">03</span><div><strong>短时高频练</strong><span>每次练 5 到 10 分钟，比一次练很久更容易形成稳定节奏。</span></div></div>
                        </div>
                    </div>
                </div>

                <div class="mf-card">
                    <div class="mf-card-head">
                        <span class="mf-head-icon mf-ico-rank"><svg viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg></span>
                        <div class="mf-card-title">
                            <h3>更多活动</h3>
                            <p>继续查看排行，或者切到其他训练和小游戏。</p>
                        </div>
                    </div>
                    <div class="mf-card-body">
                        <div class="mf-games">
                            <asp:HyperLink ID="HLfinger" runat="server" NavigateUrl="~/student/allfinger.aspx" Target="_self" CssClass="mf-game">
                                <span class="mf-game-icon mf-game-rank"><svg viewBox="0 0 24 24"><path d="M12 15l-2 5-1.5-3.5L5 15l3.5-1.5L12 8l3.5 5.5L19 15l-3.5 1.5L14 20z"/></svg></span>
                                <span class="mf-game-copy"><strong>英文输入英雄榜</strong><em>查看当前系统里的速度排行</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="Hlztype" runat="server" NavigateUrl="~/ztype/index.html" Target="_blank" CssClass="mf-game">
                                <span class="mf-game-icon mf-game-space"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polygon points="10 8 16 12 10 16 10 8"/></svg></span>
                                <span class="mf-game-copy"><strong>太空打字游戏</strong><em>换一种节奏做键盘反应训练</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="Hlbox" runat="server" NavigateUrl="~/sokoban/index.aspx" Target="_blank" CssClass="mf-game">
                                <span class="mf-game-icon mf-game-box"><svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg></span>
                                <span class="mf-game-copy"><strong>推箱子游戏</strong><em>课后放松，也训练空间感和操作节奏</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="Hlwuziqi" runat="server" NavigateUrl="~/wuziqi/index.aspx" Target="_blank" CssClass="mf-game">
                                <span class="mf-game-icon mf-game-chess"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="3"/></svg></span>
                                <span class="mf-game-copy"><strong>AI 五子棋</strong><em>完成练习后切换到策略小游戏</em></span>
                            </asp:HyperLink>
                            <asp:HyperLink ID="Hlgamelist" runat="server" NavigateUrl="~/student/gamelist.aspx" Target="_self" CssClass="mf-game">
                                <span class="mf-game-icon mf-game-more"><svg viewBox="0 0 24 24"><circle cx="5" cy="12" r="1.5"></circle><circle cx="12" cy="12" r="1.5"></circle><circle cx="19" cy="12" r="1.5"></circle><path d="M4 6h16"></path><path d="M4 18h16"></path></svg></span>
                                <span class="mf-game-copy"><strong>更多游戏</strong><em>进入游戏页面查看全部可用小游戏</em></span>
                            </asp:HyperLink>
                        </div>
                        <div id="mfGameDisabledNote" class="mf-game-disabled-note">当前班级的游戏功能已被老师关闭，小游戏和“更多游戏”入口暂时不可使用，开启后会自动恢复。</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
<script src="../js/Finger.js" type="text/javascript"></script>
<script type="text/javascript">
    $(document).ready(function () {
        if ('speechSynthesis' in window) {
            try {
                window.speechSynthesis.getVoices();
            } catch (e) {
            }
        }
        updateAccuracyProgress();
    });

    function updateAccuracyProgress() {
        var text = $('#lrpe').text() || '';
        var match = text.match(/([\d.]+)%/);
        if (!match) {
            $('#mfAccuracyWrap').hide();
            return;
        }
        var value = parseFloat(match[1]);
        if (isNaN(value)) {
            $('#mfAccuracyWrap').hide();
            return;
        }
        value = Math.max(0, Math.min(100, value));
        $('#mfAccuracyWrap').show();
        $('#mfAccuracyValue').text(value.toFixed(2) + '%');
        $('#mfAccuracyFill').css('width', value + '%');
    }

    var mfAccuracyNode = document.getElementById('lrpe');
    if (mfAccuracyNode && window.MutationObserver) {
        new MutationObserver(updateAccuracyProgress).observe(mfAccuracyNode, {
            childList: true,
            characterData: true,
            subtree: true
        });
    }

    setTimeout(updateAccuracyProgress, 500);

    (function () {
        function setGameCardState(enabled) {
            var ids = [
                '<%= Hlztype.ClientID %>',
                '<%= Hlbox.ClientID %>',
                '<%= Hlwuziqi.ClientID %>',
                '<%= Hlgamelist.ClientID %>'
            ];
            var note = document.getElementById('mfGameDisabledNote');
            for (var i = 0; i < ids.length; i++) {
                var el = document.getElementById(ids[i]);
                if (!el) {
                    continue;
                }
                if (!el.getAttribute('data-href')) {
                    el.setAttribute('data-href', el.getAttribute('href') || '');
                }
                if (enabled) {
                    el.classList.remove('mf-game-disabled');
                    el.setAttribute('href', el.getAttribute('data-href'));
                    el.removeAttribute('aria-disabled');
                    el.removeAttribute('title');
                } else {
                    el.classList.add('mf-game-disabled');
                    el.setAttribute('href', 'javascript:void(0);');
                    el.setAttribute('aria-disabled', 'true');
                    el.setAttribute('title', '游戏功能已关闭');
                }
            }
            if (note) {
                note.style.display = enabled ? 'none' : 'block';
            }
        }

        $.ajax({
            url: '../student/checkgame.aspx',
            dataType: 'json',
            cache: false,
            success: function (res) {
                setGameCardState(!res || res.gameEnabled !== false);
            },
            error: function () {
                setGameCardState(true);
            }
        });
    })();
</script>
<div id="tempdiv" style="display:none"></div>
</asp:Content>
