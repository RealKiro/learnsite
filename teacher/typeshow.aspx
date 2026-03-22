<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_typeshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ts-page,.ts-page *{box-sizing:border-box;}
    .ts-page{width:100%;padding:18px 0 30px;font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif;color:#0f172a;}
    .ts-shell{width:min(1480px,calc(100vw - 28px));margin:0 auto;padding:28px;border-radius:30px;background:radial-gradient(circle at top left,rgba(59,130,246,.12),transparent 28%),radial-gradient(circle at top right,rgba(16,185,129,.10),transparent 24%),linear-gradient(180deg,#f8fbff 0,#f8fafc 100%);box-shadow:0 20px 44px rgba(15,23,42,.08);}
    .ts-hero{display:grid;grid-template-columns:minmax(0,1.45fr) 320px;gap:20px;margin-bottom:24px;padding:28px 30px;border-radius:26px;border:1px solid rgba(148,163,184,.18);background:linear-gradient(135deg,#eff6ff 0,#f8fafc 48%,#ecfdf5 100%);overflow:hidden;position:relative;}
    .ts-hero:after{content:"";position:absolute;right:-56px;top:-64px;width:200px;height:200px;border-radius:50%;background:rgba(255,255,255,.46);}
    .ts-hero-main,.ts-hero-side{position:relative;z-index:1;}
    .ts-badge{display:inline-flex;align-items:center;padding:8px 12px;border-radius:999px;background:rgba(255,255,255,.8);border:1px solid rgba(59,130,246,.12);font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb;}
    .ts-hero h1{margin:14px 0 10px;font-size:32px;line-height:1.14;color:#0f172a;}
    .ts-hero p{margin:0;max-width:720px;font-size:15px;line-height:1.85;color:#475569;}
    .ts-meta{display:flex;flex-wrap:wrap;gap:10px;margin-top:18px;}
    .ts-meta span{display:inline-flex;align-items:center;padding:8px 12px;border-radius:999px;background:#fff;border:1px solid #dbe7f0;font-size:12px;font-weight:600;color:#475569;}
    .ts-side-card{padding:20px;border-radius:22px;background:rgba(255,255,255,.82);border:1px solid rgba(148,163,184,.18);box-shadow:0 10px 24px rgba(15,23,42,.05);}
    .ts-side-card h3{margin:0 0 12px;font-size:14px;font-weight:800;color:#0f172a;letter-spacing:.05em;text-transform:uppercase;}
    .ts-side-list{display:grid;gap:10px;}
    .ts-side-item{display:grid;grid-template-columns:30px minmax(0,1fr);gap:10px;align-items:start;font-size:13px;line-height:1.75;color:#475569;}
    .ts-side-item b{display:inline-flex;align-items:center;justify-content:center;width:30px;height:30px;border-radius:10px;background:linear-gradient(135deg,#dbeafe,#bfdbfe);color:#2563eb;font-size:12px;}
    .ts-main{display:grid;gap:18px;}
    .ts-toolbar{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:0 2px;}
    .ts-toolbar h2{margin:0;font-size:22px;color:#0f172a;}
    .ts-toolbar p{margin:6px 0 0;font-size:13px;color:#64748b;}
    .ts-count{display:inline-flex;align-items:center;padding:10px 14px;border-radius:999px;background:#fff;border:1px solid #dbe7f0;font-size:13px;font-weight:700;color:#2563eb;white-space:nowrap;}
    .ts-list{display:grid;gap:18px;}
    .ts-card{background:rgba(255,255,255,.94);border:1px solid #e2e8f0;border-radius:26px;overflow:hidden;box-shadow:0 14px 30px rgba(15,23,42,.05);}
    .ts-card-head{display:flex;align-items:flex-start;justify-content:space-between;gap:16px;padding:22px 24px 18px;border-bottom:1px solid #eef2f7;background:linear-gradient(180deg,rgba(255,255,255,.95),rgba(247,250,252,.95));}
    .ts-title-wrap{display:flex;align-items:flex-start;gap:14px;min-width:0;}
    .ts-icon{display:flex;align-items:center;justify-content:center;width:46px;height:46px;border-radius:14px;background:linear-gradient(135deg,#dbeafe,#bfdbfe);flex-shrink:0;}
    .ts-icon svg{width:22px;height:22px;fill:none;stroke:#2563eb;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .ts-title{min-width:0;}
    .ts-title h3{margin:0;font-size:22px;line-height:1.35;color:#0f172a;word-break:break-word;}
    .ts-title p{margin:6px 0 0;font-size:13px;color:#64748b;}
    .ts-edit{display:inline-flex;align-items:center;justify-content:center;width:42px;height:42px;border-radius:14px;border:1px solid #dbe7f0;background:#fff;transition:transform .15s,box-shadow .15s,border-color .15s;}
    .ts-edit:hover{transform:translateY(-1px);border-color:#60a5fa;box-shadow:0 10px 20px rgba(59,130,246,.12);}
    .ts-edit img{width:18px;height:18px;}
    .ts-card-body{padding:22px 24px 24px;}
    .ts-info{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin-bottom:16px;}
    .ts-info-item{padding:14px 16px;border-radius:18px;border:1px solid #e2e8f0;background:linear-gradient(180deg,#fff 0,#f8fafc 100%);}
    .ts-info-item b{display:block;margin-bottom:6px;font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:#64748b;}
    .ts-info-item span{display:block;font-size:15px;font-weight:700;color:#0f172a;word-break:break-all;}
    .ts-content{padding:18px 20px;border-radius:22px;background:linear-gradient(180deg,#ffffff 0,#f8fbff 100%);border:1px solid #dbe7f0;color:#334155;font-size:15px;line-height:2;word-break:break-word;white-space:pre-wrap;}
    .ts-footer{display:flex;justify-content:center;padding-top:8px;}
    .ts-return{min-width:140px!important;height:46px!important;padding:0 22px!important;border-radius:999px!important;border:1px solid #bfdbfe!important;background:linear-gradient(135deg,#eff6ff,#dbeafe)!important;color:#1d4ed8!important;font-weight:700!important;box-shadow:none!important;}
    @media (max-width:1080px){.ts-hero{grid-template-columns:1fr;}.ts-info{grid-template-columns:1fr;}}
    @media (max-width:768px){.ts-page{padding-top:10px}.ts-shell{width:min(100%,calc(100vw - 16px));padding:16px;border-radius:24px}.ts-hero{padding:20px;border-radius:22px}.ts-hero h1{font-size:26px}.ts-card-head,.ts-card-body{padding-left:18px;padding-right:18px}.ts-card-head,.ts-toolbar{flex-direction:column;align-items:flex-start}.ts-title h3{font-size:19px}}
</style>

<div class="ts-page">
    <div class="ts-shell">
        <div class="ts-hero">
            <div class="ts-hero-main">
                <span class="ts-badge">Teacher Typing Library</span>
                <h1>打字文章浏览</h1>
                <p>集中查看当前系统里的打字训练文章，快速核对篇目编号、分类、用途和正文内容。每篇文章都保留独立编辑入口，方便教师边看边维护。</p>
                <div class="ts-meta">
                    <span>支持快速浏览篇目</span>
                    <span>支持直接进入编辑</span>
                    <span>适合课堂训练前备课核查</span>
                </div>
            </div>
            <div class="ts-hero-side">
                <div class="ts-side-card">
                    <h3>使用建议</h3>
                    <div class="ts-side-list">
                        <div class="ts-side-item"><b>01</b><span>先看文章用途，再决定是否用于课堂测速、日常训练或专项巩固。</span></div>
                        <div class="ts-side-item"><b>02</b><span>发现标题、类型或正文不合适时，可直接点右上角编辑图标进入修改。</span></div>
                        <div class="ts-side-item"><b>03</b><span>长篇内容已做阅读优化，便于快速扫读和核对段落节奏。</span></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="ts-main">
            <div class="ts-toolbar">
                <div>
                    <h2>文章列表</h2>
                    <p>按卡片方式查看每篇打字文章的标题、元信息和正文。</p>
                </div>
                <span class="ts-count">可直接在卡片右上角编辑当前文章</span>
            </div>

            <div class="ts-list">
                <asp:Repeater ID="Repeater1" runat="server">
                    <ItemTemplate>
                        <div class="ts-card">
                            <div class="ts-card-head">
                                <div class="ts-title-wrap">
                                    <span class="ts-icon">
                                        <svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"></path><path d="M9 20h6"></path><path d="M12 4v16"></path></svg>
                                    </span>
                                    <div class="ts-title">
                                        <h3><%# Eval("Ttitle") %></h3>
                                        <p>教师可在此查看完整正文，并直接进入编辑维护。</p>
                                    </div>
                                </div>
                                <asp:ImageButton ID="BtnEdit" runat="server" ToolTip="点击修改" ImageUrl="~/images/edit.gif" onclick="BtnEdit_Click" CssClass="ts-edit" />
                            </div>
                            <div class="ts-card-body">
                                <div class="ts-info">
                                    <div class="ts-info-item">
                                        <b>文章编号</b>
                                        <span><%# Eval("Tid") %></span>
                                    </div>
                                    <div class="ts-info-item">
                                        <b>文章类型</b>
                                        <span><%# Eval("Ttype") %></span>
                                    </div>
                                    <div class="ts-info-item">
                                        <b>文章用途</b>
                                        <span><%# Eval("Tuse") %></span>
                                    </div>
                                </div>
                                <div class="ts-content"><%# Eval("Tcontent") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="ts-footer">
                <asp:Button ID="Btnreturn" runat="server" Text="返回" OnClick="Btnreturn_Click" SkinID="BtnNormal" CssClass="ts-return" />
            </div>
        </div>
    </div>
</div>
</asp:Content>

