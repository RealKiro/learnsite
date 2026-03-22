<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" validaterequest="false" autoeventwireup="true" inherits="Student_downwork, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .dw-page, .dw-page * { margin-right: unset !important; margin-left: unset !important; }
    .dw-page { width: 100%; max-width: 1400px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: dwFadeIn .4s ease; }
    @keyframes dwFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* Card */
    .dw-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 20px; overflow: hidden; }
    .dw-card-head { padding: 18px 28px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .dw-card-head .dw-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .dw-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .dw-icon-violet { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .dw-icon-violet svg { stroke: #7c3aed !important; }
    .dw-icon-teal { background: linear-gradient(135deg, #ccfbf1, #99f6e4) !important; }
    .dw-icon-teal svg { stroke: #0d9488 !important; }
    .dw-icon-amber { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .dw-icon-amber svg { stroke: #d97706 !important; }
    .dw-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .dw-icon-blue svg { stroke: #2563eb !important; }
    .dw-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .dw-card-head .dw-mission-tag { display: inline-flex; align-items: center; gap: 4px; padding: 4px 12px; border-radius: 20px; background: #f0fdf4; color: #16a34a; font-size: 12px; font-weight: 600; flex-shrink: 0; }
    .dw-card-body { padding: 24px 28px; }

    /* File row */
    .dw-file-row { display: flex; align-items: center; gap: 16px; padding: 16px; background: #f8fafc; border-radius: 12px; margin-bottom: 18px; }
    .dw-file-icon { width: 48px; height: 48px; display: flex !important; align-items: center; justify-content: center; background: #eef2ff; border-radius: 12px; flex-shrink: 0; }
    .dw-file-icon img { max-width: 30px; max-height: 30px; }
    .dw-file-body { flex: 1; min-width: 0; }
    .dw-file-name { font-size: 15px; font-weight: 600; color: #1e293b; margin-bottom: 6px; }
    .dw-file-name a { color: #6366f1 !important; text-decoration: none !important; transition: color .15s; }
    .dw-file-name a:hover { color: #4f46e5 !important; text-decoration: underline !important; }
    .dw-file-meta { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
    .dw-meta-tag { display: inline-flex; align-items: center; gap: 5px; font-size: 12px; color: #64748b; }
    .dw-meta-tag svg { width: 13px; height: 13px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }

    /* Score grid */
    .dw-scores { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 18px; }
    .dw-score-box { text-align: center; padding: 16px 10px; border-radius: 12px; background: #f8fafc; border: 1px solid #f1f5f9; }
    .dw-score-label { font-size: 12px; color: #94a3b8; font-weight: 500; margin-bottom: 6px; }
    .dw-score-val { font-size: 28px; font-weight: 800; line-height: 1.1; }
    .dw-score-val.s-green { color: #10b981; }
    .dw-score-val.s-amber { color: #f59e0b; }
    .dw-score-val.s-indigo { color: #6366f1; }

    /* Comment */
    .dw-comment { padding: 16px 18px; background: linear-gradient(135deg, #fefce8, #fef9c3); border-radius: 12px; border-left: 4px solid #eab308; }
    .dw-comment-head { display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 700; color: #a16207; margin-bottom: 8px; }
    .dw-comment-head svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .dw-comment-body { font-size: 14px; color: #854d0e; line-height: 1.7; }

    /* Content area */
    .dw-content-inner { padding: 26px 28px; line-height: 1.8; font-size: 14px; color: #334155; word-break: break-word; }
    .dw-content-inner img { max-width: 100%; height: auto; border-radius: 8px; margin: 8px 0; }
    .dw-content-inner a { color: #6366f1; text-decoration: none; }
    .dw-content-inner a:hover { text-decoration: underline; }

    @media (max-width: 640px) {
        .dw-scores { grid-template-columns: 1fr; }
        .dw-file-row { flex-direction: column; align-items: flex-start; }
    }
</style>

<div class="dw-page">
    <!-- 作品详情卡片 -->
    <div class="dw-card">
        <div class="dw-card-head">
            <span class="dw-head-icon dw-icon-violet"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg></span>
            <h3>作品下载</h3>
            <span class="dw-mission-tag">〖<asp:Label ID="Labelmission" runat="server"></asp:Label>〗</span>
        </div>
        <div class="dw-card-body">
            <!-- 文件信息 -->
            <div class="dw-file-row">
                <div class="dw-file-icon">
                    <asp:Image ID="ImageType" runat="server" />
                </div>
                <div class="dw-file-body">
                    <div class="dw-file-name">
                        <asp:HyperLink ID="HLfile" runat="server" Visible="False" Target="_blank" Font-Underline="True">作品</asp:HyperLink>
                        <asp:Label ID="Labelmsg" runat="server" Font-Bold="False"></asp:Label>
                    </div>
                    <div class="dw-file-meta">
                        <span class="dw-meta-tag">
                            <svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
                            <asp:Label ID="Labelsize" runat="server"></asp:Label>
                        </span>
                        <span class="dw-meta-tag">
                            <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                            <asp:Image ID="Imagegood" runat="server" ImageUrl="~/images/good16.png" Width="16px" style="display:none;" />
                            <asp:Label ID="Labelgood" runat="server"></asp:Label>
                        </span>
                        <span class="dw-meta-tag">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                            <asp:Label ID="LabelWdate" runat="server"></asp:Label>
                        </span>
                    </div>
                </div>
            </div>

            <!-- 评分 -->
            <div class="dw-scores">
                <div class="dw-score-box">
                    <div class="dw-score-label">作品评分</div>
                    <div class="dw-score-val s-green"><asp:Label ID="LbWscore" runat="server"></asp:Label></div>
                </div>
                <div class="dw-score-box">
                    <div class="dw-score-label">作品加分</div>
                    <div class="dw-score-val s-amber"><asp:Label ID="LbWdscore" runat="server"></asp:Label></div>
                </div>
                <div class="dw-score-box">
                    <div class="dw-score-label">互评得分</div>
                    <div class="dw-score-val s-indigo"><asp:Label ID="LbWfscore" runat="server"></asp:Label></div>
                </div>
            </div>

            <!-- 教师评语 -->
            <div class="dw-comment">
                <div class="dw-comment-head">
                    <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    教师评语
                </div>
                <div class="dw-comment-body">
                    <asp:Label ID="LbWself" runat="server" ForeColor="#3399FF"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <!-- 作品内容 -->
    <div class="dw-card">
        <div class="dw-card-head">
            <span class="dw-head-icon dw-icon-blue"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
            <h3>作品内容</h3>
        </div>
        <div class="dw-content-inner">
            <asp:Literal ID="Literal1" runat="server"></asp:Literal>
        </div>
    </div>

    <!-- 隐藏字段 -->
    <asp:Label ID="Labelwid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="Labeltype" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="Labelwurl" runat="server" Visible="False"></asp:Label>
</div>
</asp:Content>
