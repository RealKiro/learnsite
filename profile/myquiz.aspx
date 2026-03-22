<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_myquiz, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .mq-page, .mq-page * { margin-right: unset !important; margin-left: unset !important; }
    .mq-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .mq-page { width: 100%; max-width: 1200px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: mqFadeIn .4s ease; }
    @keyframes mqFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .mq-grid { display: grid; grid-template-columns: 1fr 300px; gap: 22px; align-items: start; }

    /* 卡片 */
    .mq-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .mq-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .mq-card-head .mq-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .mq-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mq-head-icon-teal { background: linear-gradient(135deg, #ccfbf1, #99f6e4) !important; }
    .mq-head-icon-teal svg { stroke: #0d9488 !important; }
    .mq-head-icon-amber { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .mq-head-icon-amber svg { stroke: #d97706 !important; }
    .mq-head-icon-violet { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .mq-head-icon-violet svg { stroke: #7c3aed !important; }
    .mq-head-icon-rose { background: linear-gradient(135deg, #ffe4e6, #fecdd3) !important; }
    .mq-head-icon-rose svg { stroke: #e11d48 !important; }
    .mq-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .mq-card-body { padding: 18px 22px; }

    /* 左侧双栏 */
    .mq-rank-row { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }

    /* 表格 */
    .mq-page .mq-card-body table { width: 100% !important; border-collapse: collapse !important; border-spacing: 0 !important; border: none !important; }
    .mq-page .mq-card-body table th { padding: 11px 14px !important; font-size: 12px !important; font-weight: 600 !important; color: #64748b !important; text-align: left !important; letter-spacing: .3px; background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important; border-top: none !important; border-left: none !important; border-right: none !important; font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important; }
    .mq-page .mq-card-body table td { padding: 10px 14px !important; font-size: 13px !important; color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important; border-top: none !important; border-left: none !important; border-right: none !important; background-color: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; vertical-align: middle !important; }
    .mq-page .mq-card-body table tr { background-color: #fff !important; transition: all .12s; }
    .mq-page .mq-card-body table tr:hover td { background-color: #f0fdfa !important; }
    .mq-card-body table tr:last-child td { border-bottom: none !important; }
    .mq-card-body table caption { caption-side: top; text-align: left; font-size: 0; height: 0; overflow: hidden; }
    .mq-card-body .pagediv, .mq-card-body div[style*="text-align:center"] { padding: 12px 14px 8px !important; font-size: 12px !important; color: #94a3b8 !important; display: flex !important; align-items: center; gap: 6px; flex-wrap: wrap; border-top: 1px solid #f1f5f9 !important; background: #fff !important; text-align: left !important; }
    .mq-card-body .pagediv a, .mq-card-body div[style*="text-align:center"] a { color: #0d9488 !important; text-decoration: none !important; font-size: 12px !important; padding: 4px 10px; border-radius: 6px; transition: all .12s; }
    .mq-card-body .pagediv a:hover, .mq-card-body div[style*="text-align:center"] a:hover { background: #f0fdfa !important; }
    .mq-page .mq-card-body table a { color: #0d9488 !important; text-decoration: none !important; font-weight: 600; transition: color .12s; }
    .mq-page .mq-card-body table a:hover { color: #0f766e !important; }

    /* 成绩环 */
    .mq-score-ring { position: relative; width: 120px; height: 120px; margin: 16px auto 12px; }
    .mq-score-ring svg { width: 120px; height: 120px; transform: rotate(-90deg); }
    .mq-score-ring .mq-ring-bg { fill: none; stroke: #f0fdf9; stroke-width: 8; }
    .mq-score-ring .mq-ring-fg { fill: none; stroke: url(#mqGrad); stroke-width: 8; stroke-linecap: round; stroke-dasharray: 314; stroke-dashoffset: 314; transition: stroke-dashoffset 1s ease; }
    .mq-score-center { position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; }
    .mq-score-num { font-size: 32px; font-weight: 800; color: #0d9488; line-height: 1; }
    .mq-score-unit { font-size: 11px; color: #94a3b8; margin-top: 2px; }
    .mq-score-label { font-size: 13px; color: #64748b; font-weight: 500; text-align: center; margin-bottom: 4px; }

    /* 按钮 */
    .mq-btn-start { display: inline-flex !important; align-items: center; justify-content: center; gap: 8px; width: 100% !important; padding: 13px 20px !important; border-radius: 12px !important; border: none !important; background: linear-gradient(135deg, #14b8a6, #0d9488) !important; color: #fff !important; font-size: 15px !important; font-weight: 600 !important; cursor: pointer; transition: all .15s; box-shadow: 0 4px 14px rgba(13,148,136,.25); font-family: 'Microsoft YaHei',sans-serif !important; letter-spacing: 1px; }
    .mq-btn-start:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(13,148,136,.35); }
    .mq-msg { padding: 10px 0 6px; font-size: 12px; color: #94a3b8; text-align: center; }
    .mq-link-rank { display: inline-flex; align-items: center; gap: 8px; padding: 11px 22px; border-radius: 12px; background: linear-gradient(135deg, #f59e0b, #d97706); color: #fff !important; font-size: 14px !important; font-weight: 600; text-decoration: none !important; transition: all .15s; box-shadow: 0 4px 14px rgba(217,119,6,.25); letter-spacing: .5px; }
    .mq-link-rank:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(217,119,6,.35); }
    .mq-link-rank svg { width: 16px; height: 16px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mq-actions { text-align: center; padding: 6px 0; }
    .mq-divider { height: 1px; background: #f1f5f9; margin: 14px 0; }

    /* 侧边栏 */
    .mq-sidebar { position: sticky; top: 20px; }

    /* 覆盖主题 */
    .mq-page #student { margin: 0 !important; padding: 0 !important; text-align: left !important; font-size: 13px !important; }
    .mq-page .left, .mq-page .right { float: none !important; width: 100% !important; text-align: left !important; overflow: visible !important; }
    .mq-page .quizscoreheight { float: none !important; width: 100% !important; }
    .mq-page .divquizscore { width: 100% !important; margin: 0 !important; }
    .mq-page .quizresult { width: 100% !important; margin: 0 !important; }
    .mq-page .quizresult, .mq-page .quizinfo { width: 100% !important; border: none !important; margin: 0 !important; text-align: center !important; }
    .mq-page .quizhead { border: none !important; font-size: 0 !important; height: 0 !important; overflow: hidden !important; }
    .mq-page .mq-btn-start.buttonimg { background: linear-gradient(135deg, #14b8a6, #0d9488) !important; color: #fff !important; width: 100% !important; }
    .mq-page .buttonimg:not(.mq-btn-start) { background: none !important; width: auto !important; }
    .mq-page .mq-score-ring { display: block !important; margin-left: auto !important; margin-right: auto !important; }
</style>

<div class="mq-page">
<div id="student">
<div class="mq-grid">
    <!-- 左侧主内容 -->
    <div class="left">
        <div class="mq-rank-row">
            <!-- 年级成绩榜 -->
            <div id="divscore" class="quizscoreheight">
                <div class="mq-card">
                    <div class="mq-card-head">
                        <span class="mq-head-icon mq-head-icon-teal"><svg viewBox="0 0 24 24"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg></span>
                        <h3>年级成绩榜</h3>
                    </div>
                    <div class="mq-card-body">
                        <div class="divquizscore">
                        <asp:GridView ID="GridViewgrade" runat="server" AllowPaging="True" Width="100%"  
                            SkinID="GridViewInfo" AutoGenerateColumns="False" PageSize="20" 
                            onpageindexchanging="GridViewgrade_PageIndexChanging" 
                            onrowdatabound="GridViewgrade_RowDataBound" Caption="年级成绩榜">
                            <Columns>
                                <asp:BoundField HeaderText="编号" />
                                <asp:BoundField DataField="Sgradeclass" HeaderText="班级" />
                                <asp:BoundField DataField="Sname" HeaderText="姓名" />
                                <asp:BoundField DataField="Squiz" HeaderText="学分" />
                            </Columns>
                            <PagerTemplate>
                                <div class="pagediv">
                                    第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>
                                    页 共<asp:Label ID="lblPageCount" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                                    <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上一页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下一页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                                </div>
                            </PagerTemplate>
                        </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 班级成绩榜 -->
            <div id="divwork" class="quizscoreheight">
                <div class="mq-card">
                    <div class="mq-card-head">
                        <span class="mq-head-icon mq-head-icon-violet"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></span>
                        <h3>班级成绩榜</h3>
                    </div>
                    <div class="mq-card-body">
                        <div class="divquizscore">
                        <asp:GridView ID="GridViewclass" runat="server" AllowPaging="True" Width="100%"  
                            SkinID="GridViewInfo" AutoGenerateColumns="False" PageSize="20" 
                            onpageindexchanging="GridViewclass_PageIndexChanging" 
                            onrowdatabound="GridViewclass_RowDataBound" Caption="班级成绩榜">
                            <Columns>
                                <asp:BoundField HeaderText="编号" />
                                <asp:BoundField DataField="Sgradeclass" HeaderText="班级" />
                                <asp:BoundField DataField="Sname" HeaderText="姓名" />
                                <asp:BoundField DataField="Squiz" HeaderText="学分" />
                            </Columns>
                            <PagerTemplate>
                                <div class="pagediv">
                                    第<asp:Label ID="lblPageIndex" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>
                                    页 共<asp:Label ID="lblPageCount" runat="server" ForeColor="Black" Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label>页
                                    <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上一页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下一页"></asp:LinkButton>
                                    <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                                </div>
                            </PagerTemplate>
                        </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 右侧边栏 -->
    <div class="mq-sidebar right">
        <!-- 平均成绩 + 操作 -->
        <div class="mq-card">
            <div class="mq-card-head">
                <span class="mq-head-icon mq-head-icon-rose"><svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg></span>
                <h3>我的测验</h3>
            </div>
            <div class="mq-card-body">
                <div class="quizresult">
                    <div class="quizinfo">
                        <div class="quizhead">我的测验平均成绩</div>
                        <div class="mq-score-label">平均成绩</div>
                        <div class="mq-score-ring">
                            <svg viewBox="0 0 120 120">
                                <defs><linearGradient id="mqGrad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#14b8a6"/><stop offset="100%" stop-color="#0d9488"/></linearGradient></defs>
                                <circle class="mq-ring-bg" cx="60" cy="60" r="50"/>
                                <circle class="mq-ring-fg" cx="60" cy="60" r="50"/>
                            </svg>
                            <div class="mq-score-center">
                                <span class="mq-score-num"><asp:Label ID="LabelSquiz" runat="server"></asp:Label></span>
                                <span class="mq-score-unit">分</span>
                            </div>
                        </div>
                    </div>
                    <div class="mq-actions">
                        <asp:Button ID="Btnquiz" runat="server" OnClick="Btnquiz_Click"
                            Text="✦ 开始测验" CssClass="buttonimg mq-btn-start" Font-Bold="False" BorderStyle="None" />
                    </div>
                    <div class="mq-msg"><asp:Label ID="Labelmsg" runat="server" Font-Size="9pt"></asp:Label></div>
                    <div class="mq-divider"></div>
                    <div class="mq-actions">
                        <asp:HyperLink ID="HyperLink1" runat="server" 
                            NavigateUrl="~/student/quizrank.aspx" Target="_blank" CssClass="mq-link-rank"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>今天测验排行榜</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <!-- 测验记录 -->
        <div class="mq-card">
            <div class="mq-card-head">
                <span class="mq-head-icon mq-head-icon-amber"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></span>
                <h3>我的测验记录</h3>
            </div>
            <div class="mq-card-body">
                <asp:GridView ID="GVmyScore" runat="server" AllowPaging="True"  
                    Caption="我的测验记录" CellPadding="2"         
                    onpageindexchanging="GVmyScore_PageIndexChanging"
                    OnRowDataBound="GVmyScore_RowDataBound" Width="100%" SkinID="GridViewInfo" 
                    AutoGenerateColumns="False" EnableModelValidation="True">
                    <Columns>
                        <asp:BoundField HeaderText="日期" DataField="Rdate" />
                        <asp:HyperLinkField DataNavigateUrlFields="rid" 
                            DataNavigateUrlFormatString="quizview.aspx?Rid={0}" Target="_blank" 
                            DataTextField="Rscore" HeaderText="成绩" />
                    </Columns>
                    <PagerTemplate>
                        <div style="color: black; text-align:center">
                            <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" CommandArgument="First" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="首页"></asp:LinkButton>
                            <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" CommandArgument="Prev" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="上页"></asp:LinkButton>
                            <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" CommandArgument="Next" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="下页"></asp:LinkButton>
                            <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" CommandArgument="Last" CommandName="Page" Font-Underline="False" ForeColor="Black" Text="尾页"></asp:LinkButton>
                        </div>
                    </PagerTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</div>
</div>
</div>
<script type="text/javascript">
    (function(){
        var el = document.querySelector('.mq-score-num');
        if(!el) return;
        var v = parseFloat(el.innerText) || 0;
        var pct = Math.min(v, 100) / 100;
        var ring = document.querySelector('.mq-ring-fg');
        if(ring){
            var total = 2 * Math.PI * 50; // 314
            setTimeout(function(){ ring.style.strokeDashoffset = total * (1 - pct); }, 200);
        }
    })();
</script>
</asp:Content>
