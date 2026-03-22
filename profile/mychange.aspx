<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mychange, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
    .mc-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; animation: mcFade .4s ease; }
    @keyframes mcFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .mc-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex !important; align-items: center; gap: 12px; }
    .mc-card-head .mc-icon { width: 38px; height: 38px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; background: linear-gradient(135deg, #fef9c3, #fde68a); }
    .mc-icon svg { width: 18px; height: 18px; fill: none; stroke: #ca8a04; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mc-card-head h3 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; }
    .mc-card-head .mc-desc { font-size: 12.5px; color: #94a3b8; margin-left: auto; }
    .mc-card-body { padding: 20px 24px; }

    .mc-card-body table { width: 100% !important; border-collapse: separate !important; border-spacing: 12px !important; border: none !important; }
    .mc-card-body table td { padding: 0 !important; border: none !important; background: none !important; vertical-align: top !important; }
    .mc-card-body table caption { display: none; }

    .mc-stu-card {
        border: 1px solid #e5e7eb !important; border-radius: 12px !important;
        padding: 16px 14px !important; margin: 0 !important; text-align: center;
        background: #fff !important; transition: all .2s; width: auto !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.03);
    }
    .mc-stu-card:hover {
        border-color: #c7d2fe !important;
        box-shadow: 0 4px 16px rgba(99,102,241,.1);
        transform: translateY(-2px);
    }

    .mc-card-body .onlinebg {
        display: flex !important; flex-direction: column; align-items: center; gap: 4px;
        padding: 0 !important; margin: 0 0 8px !important; background: none !important;
    }
    .mc-card-body .onlinebg a {
        font-size: 14px !important; font-weight: 600 !important; color: #1e293b !important;
        text-decoration: none !important; line-height: 1.4; height: auto !important;
    }
    .mc-card-body .onlinebg input[type="image"] { display: none !important; }

    .mc-vote-wrap { display: flex; flex-direction: column; align-items: center; gap: 8px; margin-top: 4px; }
    .mc-vote-count { display: flex; flex-direction: column; align-items: center; gap: 2px; }
    .mc-vote-num { font-size: 22px; font-weight: 800; color: #6366f1; line-height: 1; }
    .mc-vote-text { font-size: 11px; color: #94a3b8; font-weight: 500; }
    .mc-vote-btn {
        position: relative; width: 100%; height: 34px;
        border-radius: 8px; overflow: hidden;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        box-shadow: 0 2px 6px rgba(99,102,241,.2);
        display: flex; align-items: center; justify-content: center;
        transition: all .15s;
    }
    .mc-vote-btn:hover { box-shadow: 0 4px 12px rgba(99,102,241,.3); transform: translateY(-1px); }
    .mc-vote-btn-label {
        font-size: 12px; font-weight: 600; color: #fff;
        pointer-events: none; display: flex; align-items: center; gap: 4px;
    }
    .mc-vote-btn-label svg { width: 14px; height: 14px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mc-vote-btn input[type="image"] {
        position: absolute !important; inset: 0; width: 100% !important; height: 100% !important;
        opacity: 0 !important; cursor: pointer !important; z-index: 2;
    }
    .mc-hidden-data { display: none !important; }
    /* ===== Rank Chart ===== */
    .mc-rank { margin-bottom: 20px; background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; animation: mcFade .4s ease; }
    .mc-rank-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex !important; align-items: center; gap: 12px; }
    .mc-rank-head .mc-rk-icon { width: 38px; height: 38px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; background: linear-gradient(135deg, #e0e7ff, #c7d2fe); }
    .mc-rk-icon svg { width: 18px; height: 18px; fill: none; stroke: #6366f1; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mc-rank-head h3 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; }
    .mc-rank-body { padding: 20px 24px; }
    .mc-rank-empty { text-align: center; padding: 20px; color: #94a3b8; font-size: 13px; }
    .mc-rank-item {
        display: flex; align-items: center; gap: 12px; margin-bottom: 10px;
        animation: mcBarIn .5s ease both;
    }
    @keyframes mcBarIn { from { opacity:0; transform:translateX(-12px); } to { opacity:1; transform:translateX(0); } }
    .mc-rank-pos {
        width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center;
        justify-content: center; font-size: 12px; font-weight: 700; flex-shrink: 0;
        background: #f1f5f9; color: #64748b;
    }
    .mc-rank-item:nth-child(1) .mc-rank-pos { background: linear-gradient(135deg, #fbbf24, #f59e0b); color: #fff; box-shadow: 0 2px 6px rgba(245,158,11,.3); }
    .mc-rank-item:nth-child(2) .mc-rank-pos { background: linear-gradient(135deg, #94a3b8, #64748b); color: #fff; }
    .mc-rank-item:nth-child(3) .mc-rank-pos { background: linear-gradient(135deg, #f97316, #ea580c); color: #fff; }
    .mc-rank-name { width: 56px; font-size: 13.5px; font-weight: 600; color: #1e293b; flex-shrink: 0; text-align: right; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .mc-rank-bar-wrap { flex: 1; height: 26px; background: #f1f5f9; border-radius: 13px; overflow: hidden; position: relative; }
    .mc-rank-bar {
        height: 100%; border-radius: 13px; min-width: 8px;
        background: linear-gradient(90deg, #818cf8, #6366f1);
        transition: width .8s cubic-bezier(.4,0,.2,1);
        position: relative;
    }
    .mc-rank-item:nth-child(1) .mc-rank-bar { background: linear-gradient(90deg, #fbbf24, #f59e0b); }
    .mc-rank-item:nth-child(2) .mc-rank-bar { background: linear-gradient(90deg, #94a3b8, #64748b); }
    .mc-rank-item:nth-child(3) .mc-rank-bar { background: linear-gradient(90deg, #fb923c, #f97316); }
    .mc-rank-val {
        width: 40px; font-size: 14px; font-weight: 800; color: #6366f1; flex-shrink: 0; text-align: left;
    }
    .mc-rank-item:nth-child(1) .mc-rank-val { color: #d97706; }
    .mc-rank-item:nth-child(2) .mc-rank-val { color: #64748b; }
    .mc-rank-item:nth-child(3) .mc-rank-val { color: #ea580c; }
</style>

<!-- Rank Chart -->
<div class="mc-rank" id="mcRankChart">
    <div class="mc-rank-head">
        <span class="mc-rk-icon"><svg viewBox="0 0 24 24"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg></span>
        <h3>实时排行榜</h3>
    </div>
    <div class="mc-rank-body" id="mcRankBody">
        <div class="mc-rank-empty">加载中...</div>
    </div>
</div>

<div class="mc-card">
    <div class="mc-card-head">
        <span class="mc-icon"><svg viewBox="0 0 24 24"><path d="M2 4l3 12h14l3-12-5 4-5-4-5 4z"/><path d="M5 16h14v4H5z"/></svg></span>
        <h3>推荐组长</h3>
        <span class="mc-desc">点击推荐按钮为同学投票</span>
    </div>
    <div class="mc-card-body">
        <asp:Image ID="Image1" runat="server" ImageUrl="~/images/profile.gif" style="display:none !important;" />
        <asp:DataList ID="DataListstu" runat="server" DataKeyField="Sid" 
            RepeatColumns="6" Width="100%" onitemcommand="DataListstu_ItemCommand" 
            onitemdatabound="DataListstu_ItemDataBound">
                <ItemTemplate>
                    <div class="mc-stu-card">
                    <div class="onlinebg">
                        <asp:HyperLink ID="HyperQname" runat="server" Font-Underline="False"
                            Text='<%# Eval("Sname") %>'></asp:HyperLink>
                        <asp:ImageButton ID="ImageBtnGroup" runat="server" CausesValidation="False" 
                            CommandArgument='<%# Eval("Sid") %>' CommandName="ChangeGroup" 
                            ImageUrl="~/images/gcard.gif" />
                    </div>
                    <div class="mc-vote-wrap">
                        <div class="mc-vote-count">
                            <span class="mc-vote-num"><asp:Label ID="Labelvote" runat="server" Text='<%# Eval("Steam") %>' ToolTip="组长票数！"></asp:Label></span>
                            <span class="mc-vote-text">票</span>
                        </div>
                        <asp:Label ID="LabelSleader" runat="server" Text='<%# Bind("Sleader") %>' CssClass="mc-hidden-data"></asp:Label>
                        <asp:Label ID="LabelSnum" runat="server" Text='<%# Bind("Snum") %>' CssClass="mc-hidden-data"></asp:Label>
                        <div class="mc-vote-btn">
                            <span class="mc-vote-btn-label"><svg viewBox="0 0 24 24"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3H14z"/><path d="M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"/></svg>推荐</span>
                            <asp:ImageButton ID="LinkBtnVote" runat="server" CommandArgument='<%# Eval("Sid") %>' 
                                CommandName="Vote" ToolTip="点击推荐组长！" ImageUrl="~/images/good.png" CausesValidation="False" CssClass="leadvote" />
                        </div>
                    </div>
                    </div>
                </ItemTemplate>
        </asp:DataList>
    </div>
</div>

<script type="text/javascript">
(function(){
    var cards = document.querySelectorAll('.mc-stu-card');
    if (!cards.length) { document.getElementById('mcRankBody').innerHTML = '<div class="mc-rank-empty">暂无数据</div>'; return; }

    // 收集所有学生数据
    var all = [];
    cards.forEach(function(c){
        var nameEl = c.querySelector('.onlinebg a');
        var voteEl = c.querySelector('.mc-vote-num span, .mc-vote-num');
        var leaderEls = c.querySelectorAll('.mc-hidden-data');
        if (!nameEl) return;
        var name = nameEl.innerText.trim();
        var vote = 0;
        if (voteEl) { vote = parseInt(voteEl.innerText.trim()) || 0; }
        // leaderEls[0] = Sleader(组长标识), leaderEls[1] = Snum(学号)
        var sleader = leaderEls.length > 0 ? leaderEls[0].innerText.trim() : '';
        var snum = leaderEls.length > 1 ? leaderEls[1].innerText.trim() : '';
        all.push({ name: name, vote: vote, sleader: sleader, snum: snum });
    });

    // 按组分组，取每组最高票
    var groups = {};
    all.forEach(function(s){
        var gk = s.sleader || s.snum || s.name; // 组键
        if (!groups[gk] || s.vote > groups[gk].vote) {
            groups[gk] = s;
        }
    });
    var data = [];
    for (var k in groups) { data.push(groups[k]); }
    data.sort(function(a,b){ return b.vote - a.vote; });

    var maxV = data.length ? data[0].vote : 1;
    if (maxV < 1) maxV = 1;
    var html = '';
    for (var i = 0; i < data.length; i++) {
        var pct = Math.max(4, (data[i].vote / maxV) * 100);
        html += '<div class="mc-rank-item" style="animation-delay:' + (i * 0.06) + 's">';
        html += '<span class="mc-rank-pos">' + (i+1) + '</span>';
        html += '<span class="mc-rank-name">' + data[i].name + '</span>';
        html += '<div class="mc-rank-bar-wrap"><div class="mc-rank-bar" style="width:0%" data-w="' + pct + '%"></div></div>';
        html += '<span class="mc-rank-val">' + data[i].vote + '</span>';
        html += '</div>';
    }
    document.getElementById('mcRankBody').innerHTML = html;
    setTimeout(function(){
        var bars = document.querySelectorAll('.mc-rank-bar');
        bars.forEach(function(b){ b.style.width = b.getAttribute('data-w'); });
    }, 60);
})();
</script>
</asp:Content>

