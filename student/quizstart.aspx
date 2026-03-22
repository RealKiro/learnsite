<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_quizstart, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* ===== Quiz Start Page ===== */
    .qs-page, .qs-page * { margin-right: unset !important; margin-left: unset !important; }
    .qs-page { width: 100%; max-width: 1200px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: qsFadeIn .4s ease; }
    @keyframes qsFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* Grid: questions left, sidebar right */
    .qs-grid { display: grid; grid-template-columns: 1fr 300px; gap: 22px; align-items: start; }

    /* Card */
    .qs-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .qs-card-head { padding: 14px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .qs-card-head .qs-head-icon { width: 32px; height: 32px; border-radius: 8px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .qs-head-icon svg { width: 16px; height: 16px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .qs-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .qs-icon-blue svg { stroke: #2563eb !important; }
    .qs-icon-green { background: linear-gradient(135deg, #dcfce7, #bbf7d0) !important; }
    .qs-icon-green svg { stroke: #16a34a !important; }
    .qs-icon-amber { background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .qs-icon-amber svg { stroke: #d97706 !important; }
    .qs-icon-teal { background: linear-gradient(135deg, #ccfbf1, #99f6e4) !important; }
    .qs-icon-teal svg { stroke: #0d9488 !important; }
    .qs-icon-violet { background: linear-gradient(135deg, #ede9fe, #ddd6fe) !important; }
    .qs-icon-violet svg { stroke: #7c3aed !important; }
    .qs-icon-rose { background: linear-gradient(135deg, #ffe4e6, #fecdd3) !important; }
    .qs-icon-rose svg { stroke: #e11d48 !important; }
    .qs-card-head h3 { font-size: 14px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .qs-card-body { padding: 4px 12px 12px; }

    /* Question items */
    .qs-page .quizone { display: flex; align-items: flex-start; padding: 14px 16px; margin: 0; border-radius: 10px; transition: background .12s; border-bottom: 1px solid #f8fafc; }
    .qs-page .quizone:last-child { border-bottom: none; }
    .qs-page .quizone:hover { background: #f8fafc; }
    .qs-page .quizleftnum { float: none !important; width: 28px !important; height: 28px; min-width: 28px; border-radius: 50%; background: #f1f5f9; display: flex !important; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; color: #64748b; margin-right: 12px !important; flex-shrink: 0; line-height: 28px !important; }
    .qs-page .quizleftquestion { float: none !important; width: auto !important; flex: 1; font-size: 14px; color: #334155; line-height: 1.7 !important; padding-left: 0 !important; text-align: left; }
    .qs-page .quizleftquestion img { max-width: 100%; height: auto; border-radius: 8px; margin: 6px 0; }
    .qs-page .quizleftanswer { float: none !important; width: 0 !important; overflow: hidden; }
    .qs-page .quizleftup { float: none !important; width: auto !important; flex-shrink: 0; margin-left: 12px !important; display: flex; align-items: center; }

    /* Radio / Checkbox options */
    .qs-page .quizleftup table { border: none !important; }
    .qs-page .quizleftup td { border: none !important; padding: 0 2px !important; }
    .qs-page .quizleftup input[type="radio"],
    .qs-page .quizleftup input[type="checkbox"] { display: none; }
    .qs-page .quizleftup label {
        display: inline-flex !important; align-items: center; justify-content: center;
        min-width: 36px; height: 36px; padding: 0 10px;
        border-radius: 8px; border: 2px solid #e2e8f0 !important;
        background: #fff !important; color: #64748b !important;
        font-size: 13px; font-weight: 600; cursor: pointer;
        transition: all .15s; margin: 2px !important; line-height: 1;
    }
    .qs-page .quizleftup label:hover { border-color: #6366f1 !important; color: #6366f1 !important; background: #eef2ff !important; }
    .qs-page .quizleftup input[type="radio"]:checked + label,
    .qs-page .quizleftup input[type="checkbox"]:checked + label {
        background: #6366f1 !important; border-color: #6366f1 !important; color: #fff !important;
        box-shadow: 0 2px 8px rgba(99,102,241,.3);
    }

    /* Sidebar */
    .qs-sidebar { position: sticky; top: 20px; }

    /* Timer - digital flip style */
    .qs-timer-wrap { text-align: center; padding: 22px 18px 18px; }
    .qs-timer-digits { display: flex; align-items: center; justify-content: center; gap: 6px; }
    .qs-digit-box { background: linear-gradient(180deg, #1e1b4b 0%, #312e81 100%); border-radius: 10px; padding: 10px 0; min-width: 56px; position: relative; overflow: hidden; box-shadow: 0 4px 12px rgba(30,27,75,.3), inset 0 1px 0 rgba(255,255,255,.08); }
    .qs-digit-box::after { content: ''; position: absolute; top: 50%; left: 0; right: 0; height: 1px; background: rgba(0,0,0,.25); box-shadow: 0 1px 0 rgba(255,255,255,.05); }
    .qs-digit-val { font-family: 'Courier New', 'Consolas', monospace; font-size: 28px; font-weight: 800; color: #c7d2fe; line-height: 1; letter-spacing: 2px; text-shadow: 0 0 12px rgba(165,180,252,.5); }
    .qs-digit-label { font-size: 10px; color: #818cf8; margin-top: 4px; font-weight: 500; letter-spacing: 1px; text-transform: uppercase; }
    .qs-digit-sep { font-size: 24px; font-weight: 800; color: #6366f1; line-height: 1; animation: qsBlink 1s step-end infinite; margin-top: -6px; }
    @keyframes qsBlink { 0%,100% { opacity:1; } 50% { opacity:.2; } }
    .qs-page .quiztime { position: absolute !important; width: 1px !important; height: 1px !important; overflow: hidden !important; clip: rect(0,0,0,0) !important; border: none !important; }
    .qs-timer-status { display: inline-flex; align-items: center; gap: 6px; margin-top: 14px; padding: 5px 14px; border-radius: 20px; background: #f0fdf4; font-size: 12px; color: #16a34a; font-weight: 600; }
    .qs-timer-dot { width: 6px; height: 6px; border-radius: 50%; background: #22c55e; animation: qsDotPulse 1.5s ease-in-out infinite; }
    @keyframes qsDotPulse { 0%,100% { opacity:1; transform:scale(1); } 50% { opacity:.5; transform:scale(.7); } }

    /* Score card */
    .qs-score-area { text-align: center; padding: 16px 18px; }
    .qs-page .quizmyscore { width: 100% !important; border: none !important; margin: 0 !important; }
    .qs-page .quizmyhead { margin: 0 !important; border: none; height: auto !important; font-size: 0 !important; overflow: hidden; }
    .qs-score-num { display: block; font-size: 40px; font-weight: 800; color: #6366f1; line-height: 1.1; margin: 8px 0 4px; }
    .qs-score-unit { font-size: 12px; color: #94a3b8; }
    .qs-score-label { font-size: 13px; color: #64748b; font-weight: 500; margin-bottom: 6px; }

    /* Message */
    .qs-msg { padding: 8px 18px; font-size: 12px; text-align: center; }

    /* Scope detail */
    .qs-scope { padding: 0 18px 12px; }
    .qs-scope div { text-align: left !important; margin: 0 !important; width: 100% !important; font-size: 13px; color: #475569; line-height: 1.8; }

    /* Buttons */
    .qs-btn-submit { display: inline-flex !important; align-items: center; justify-content: center; gap: 8px; width: 100% !important; padding: 14px 20px !important; border-radius: 12px !important; border: none !important; background: linear-gradient(135deg, #6366f1, #4f46e5) !important; color: #fff !important; font-size: 15px !important; font-weight: 600 !important; cursor: pointer; transition: all .15s; box-shadow: 0 4px 14px rgba(99,102,241,.3); font-family: 'Microsoft YaHei',sans-serif !important; letter-spacing: 1px; }
    .qs-btn-submit:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(99,102,241,.4); }
    .qs-btn-answer { display: inline-flex !important; align-items: center; justify-content: center; gap: 6px; padding: 10px 24px !important; border-radius: 10px !important; border: none !important; background: linear-gradient(135deg, #14b8a6, #0d9488) !important; color: #fff !important; font-size: 13px !important; font-weight: 600 !important; text-decoration: none !important; transition: all .15s; box-shadow: 0 3px 10px rgba(13,148,136,.25); width: auto !important; }
    .qs-btn-answer:hover { transform: translateY(-1px); box-shadow: 0 5px 16px rgba(13,148,136,.35); }
    .qs-actions { text-align: center; padding: 6px 18px 14px; }
    .qs-divider { height: 1px; background: #f1f5f9; margin: 0 18px; }

    /* Override old layout */
    .qs-page #student { margin: 0 !important; padding: 0 !important; text-align: left !important; font-size: 13px !important; }
    .qs-page .left, .qs-page .right { float: none !important; width: 100% !important; text-align: left !important; overflow: visible !important; }
    .qs-page .quizresult { width: 100% !important; margin: 0 !important; }
    .qs-page center { text-align: center; display: block; }

    /* Responsive */
    @media (max-width: 900px) {
        .qs-grid { grid-template-columns: 1fr; }
        .qs-sidebar { position: static; }
    }
</style>

<div class="qs-page">
<div id="student">
<div class="qs-grid">
    <!-- ===== Left: Questions ===== -->
    <div class="left">
        <!-- 单选题 -->
        <div class="qs-card">
            <div class="qs-card-head">
                <span class="qs-head-icon qs-icon-blue"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M8 12l2.5 2.5L16 9"/></svg></span>
                <h3>单选题</h3>
            </div>
            <div class="qs-card-body">
                <asp:DataList ID="DataListonly" runat="server" DataKeyField="Qid" 
                    RepeatColumns="1"  width="100%">
                    <ItemTemplate>
                        <div class="quizone">
                            <div class="quizleftnum">
                                <asp:Label ID="Labelnum" Text='<%# Container.ItemIndex + 1%> ' runat="server" ></asp:Label>
                                </div>
                            <div class="quizleftquestion">
                                <asp:Label ID="Labelquestion" runat="server" Text='<%# HttpUtility.HtmlDecode( Eval("Question").ToString()) %>'></asp:Label>
                                </div>
                            <div  class="quizleftanswer">
                                <asp:Label ID="Labelanswer" runat="server" Text='<%# Eval("Qanswer") %>' 
                                    Visible="False"></asp:Label>
                                <asp:Label ID="Labelscore" runat="server" Text='<%# Eval("Qscore") %>' 
                                    Visible="False"></asp:Label>
                            </div>
                            <div class="quizleftup">
                                <asp:RadioButtonList ID="RBLselect" runat="server" 
                                    RepeatDirection="Horizontal" Visible="True">
                                    <asp:ListItem>A</asp:ListItem>
                                    <asp:ListItem>B</asp:ListItem>
                                    <asp:ListItem>C</asp:ListItem>
                                    <asp:ListItem>D</asp:ListItem>
                                </asp:RadioButtonList>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
        </div>

        <!-- 多选题 -->
        <div class="qs-card">
            <div class="qs-card-head">
                <span class="qs-head-icon qs-icon-green"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><path d="M8 12l2.5 2.5L16 9"/></svg></span>
                <h3>多选题</h3>
            </div>
            <div class="qs-card-body">
                <asp:DataList ID="DataListmore" runat="server" DataKeyField="Qid" 
                    RepeatColumns="1" width="100%">
                    <ItemTemplate>
                            <div class="quizone" >
                                <div class="quizleftnum">
                                    <asp:Label ID="Labelnumm" runat="server" Text="<%# Container.ItemIndex + 1%> "></asp:Label>
                                </div>
                                <div class="quizleftquestion">
                                    <asp:Label ID="Labelquestionm" runat="server" 
                                        Text='<%# HttpUtility.HtmlDecode( Eval("Question").ToString()) %>'></asp:Label>
                                </div>
                                <div class="quizleftanswer">
                                    <asp:Label ID="Labelanswerm" runat="server" Text='<%# Eval("Qanswer") %>' 
                                        Visible="False"></asp:Label>
                                        <asp:Label ID="Labelscorem" runat="server" Text='<%# Eval("Qscore") %>' 
                                    Visible="False"></asp:Label>
                                </div>
                                <div class="quizleftup">
                                    <asp:CheckBoxList ID="CBLselect" runat="server" RepeatDirection="Horizontal" 
                                        Visible="True">
                                        <asp:ListItem>A</asp:ListItem>
                                        <asp:ListItem>B</asp:ListItem>
                                        <asp:ListItem>C</asp:ListItem>
                                        <asp:ListItem>D</asp:ListItem>
                                    </asp:CheckBoxList>
                                </div>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
        </div>

        <!-- 判断题 -->
        <div class="qs-card">
            <div class="qs-card-head">
                <span class="qs-head-icon qs-icon-amber"><svg viewBox="0 0 24 24"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"/><path d="M12 8v4"/><path d="M12 16h.01"/></svg></span>
                <h3>判断题</h3>
            </div>
            <div class="qs-card-body">
            <asp:DataList ID="DataListjudge" runat="server" DataKeyField="Qid" 
                    RepeatColumns="1"  width="100%">
                    <ItemTemplate>
                            <div class="quizone" >
                                <div class="quizleftnum">
                                    <asp:Label ID="Labelnumj" runat="server" Text="<%# Container.ItemIndex + 1%> "></asp:Label>
                                </div>
                                <div class="quizleftquestion">
                                    <asp:Label ID="Labelquestionj" runat="server" 
                                        Text='<%# HttpUtility.HtmlDecode( Eval("Question").ToString()) %>'></asp:Label>
                                </div>
                                <div class="quizleftanswer">
                                    <asp:Label ID="Labelanswerj" runat="server" Text='<%# Eval("Qanswer") %>' 
                                        Visible="False"></asp:Label>
                                        <asp:Label ID="Labelscorej" runat="server" Text='<%# Eval("Qscore") %>' 
                                    Visible="False"></asp:Label>
                                </div>
                                <div class="quizleftup">
                                    <asp:RadioButtonList ID="RBLjudge" runat="server" RepeatDirection="Horizontal" 
                                        Visible="True" >
                                    <asp:ListItem>对</asp:ListItem>
                                    <asp:ListItem>错</asp:ListItem>
                                    </asp:RadioButtonList>
                                </div>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
        </div>

        <!-- 提交按钮卡片 -->
        <div class="qs-card">
            <div class="qs-card-body" style="padding: 18px 22px;">
                <asp:Button ID="Btnquiz" runat="server" OnClick="Btnquiz_Click"
                    Text="✦ 提交成绩" CausesValidation="False" CssClass="qs-btn-submit" 
                BorderStyle="None"/>
            </div>
        </div>
    </div>

    <!-- ===== Right: Sidebar ===== -->
    <div class="qs-sidebar right">
        <!-- 计时器 -->
        <div class="qs-card">
            <div class="qs-card-head">
                <span class="qs-head-icon qs-icon-violet"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                <h3>答题计时</h3>
            </div>
            <div class="qs-timer-wrap">
                <input id="TextTime" class="quiztime" type="text" maxlength="30" readonly="readOnly" name="TypeText7" />
                <div class="qs-timer-digits">
                    <div class="qs-digit-box">
                        <div class="qs-digit-val" id="qsHour">00</div>
                        <div class="qs-digit-label">时</div>
                    </div>
                    <span class="qs-digit-sep">:</span>
                    <div class="qs-digit-box">
                        <div class="qs-digit-val" id="qsMin">00</div>
                        <div class="qs-digit-label">分</div>
                    </div>
                    <span class="qs-digit-sep">:</span>
                    <div class="qs-digit-box">
                        <div class="qs-digit-val" id="qsSec">00</div>
                        <div class="qs-digit-label">秒</div>
                    </div>
                </div>
                <div class="qs-timer-status"><span class="qs-timer-dot"></span> 答题中</div>
            </div>
        </div>

        <!-- 成绩单 -->
        <div class="qs-card">
            <div class="qs-card-head">
                <span class="qs-head-icon qs-icon-rose"><svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg></span>
                <h3>我的成绩单</h3>
            </div>
            <div class="qs-score-area">
                <div class="quizresult">
                    <div class="quizmyscore">
                        <div class="quizmyhead">我的成绩单</div>
                        <div class="qs-score-label">本次测验总得分</div>
                        <span class="qs-score-num"><asp:Label ID="Labelallscore" runat="server"></asp:Label></span>
                        <div class="qs-score-unit">分</div>
                    </div>
                </div>
            </div>
            <div class="qs-divider"></div>
            <div class="qs-msg">
                <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
            </div>
            <div class="qs-actions">
                <asp:HyperLink ID="HLanswer" runat="server" Width="80px" 
                    NavigateUrl="~/student/quizview.aspx" Enabled="False" 
                    Visible="False" CssClass="qs-btn-answer" Target="_blank">📋 查看答案</asp:HyperLink>
            </div>
            <div class="qs-scope">
                <div id="showscope" runat="server" 
                    style="text-align: left; margin: auto; width: 90%;"></div>
            </div>
        </div>
    </div>
</div>
</div>
</div>
<script src="../js/QuizClock.js" type="text/javascript"></script>
<script type="text/javascript">
    function syncDigits() {
        var v = document.getElementById('TextTime').value || '';
        var parts = v.replace(/\s/g,'').split(':');
        if (parts.length >= 3) {
            document.getElementById('qsHour').textContent = parts[0].length < 2 ? '0'+parts[0] : parts[0];
            document.getElementById('qsMin').textContent = parts[1].length < 2 ? '0'+parts[1] : parts[1];
            document.getElementById('qsSec').textContent = parts[2].length < 2 ? '0'+parts[2] : parts[2];
        }
    }
    setInterval(syncDigits, 500);
</script>
</asp:Content>

