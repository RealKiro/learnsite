<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_infomation, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .db-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    /* 欢迎横幅 */
    .db-banner {
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
        border-radius: 16px; padding: 32px 40px; color: #fff;
        display: flex; align-items: center; justify-content: space-between;
        box-shadow: 0 8px 32px rgba(99,102,241,.22);
        margin-bottom: 24px; position: relative; overflow: hidden;
    }
    .db-banner::after {
        content: ''; position: absolute; top: -60px; right: -60px;
        width: 220px; height: 220px; border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .db-banner::before {
        content: ''; position: absolute; bottom: -50px; right: 80px;
        width: 150px; height: 150px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .db-banner-left { display: flex; align-items: center; gap: 20px; position: relative; z-index: 1; }
    .db-banner-icon {
        width: 64px; height: 64px; background: rgba(255,255,255,.18);
        border-radius: 16px; display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; backdrop-filter: blur(4px);
    }
    .db-banner-icon svg { width: 32px; height: 32px; stroke: #fff; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .db-banner-text .db-welcome { font-size: 24px; font-weight: 700; line-height: 1.3; }
    .db-banner-text .db-welcome-sub { font-size: 14px; opacity: .8; margin-top: 6px; }
    .db-banner-right { position: relative; z-index: 1; }
    .db-banner-time {
        font-size: 13px; opacity: .85;
        display: flex; align-items: center; gap: 8px;
    }
    .db-banner-time svg { width: 16px; height: 16px; stroke: #fff; fill: none; stroke-width: 2; }

    /* 统计卡片行 */
    .db-stats {
        display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px;
    }
    .db-stat-card {
        padding: 20px 24px; border-radius: 14px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: center; gap: 16px;
        box-shadow: 0 2px 8px rgba(0,0,0,.03);
        transition: all .2s;
    }
    .db-stat-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); transform: translateY(-2px); }
    .db-stat-icon {
        width: 52px; height: 52px; border-radius: 14px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .db-stat-icon svg { width: 26px; height: 26px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .db-stat-icon.purple { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .db-stat-icon.blue { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .db-stat-icon.green { background: linear-gradient(135deg,#10b981,#34d399); }
    .db-stat-icon.amber { background: linear-gradient(135deg,#f59e0b,#fbbf24); }
    .db-stat-info { display: flex; flex-direction: column; }
    .db-stat-label { font-size: 12px; color: #94a3b8; margin-bottom: 4px; }
    .db-stat-value { font-size: 22px; font-weight: 700; color: #1e293b; }

    /* 快捷操作网格 */
    .db-quick-grid {
        display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 16px; margin-bottom: 24px;
    }
    .db-quick-card {
        min-height: 118px; padding: 20px 18px; border-radius: 14px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: flex-start; gap: 16px;
        text-decoration: none; transition: all .2s;
        box-shadow: 0 1px 4px rgba(0,0,0,.03);
    }
    .db-quick-card:hover {
        border-color: #c7d2fe; box-shadow: 0 6px 20px rgba(99,102,241,.1);
        transform: translateY(-2px);
    }
    .db-quick-icon {
        width: 44px; height: 44px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .db-quick-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .db-quick-icon.indigo { background: linear-gradient(135deg,#6366f1,#818cf8); }
    .db-quick-icon.blue { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .db-quick-icon.green { background: linear-gradient(135deg,#10b981,#34d399); }
    .db-quick-icon.amber { background: linear-gradient(135deg,#f59e0b,#fbbf24); }
    .db-quick-icon.rose { background: linear-gradient(135deg,#f43f5e,#fb7185); }
    .db-quick-icon.cyan { background: linear-gradient(135deg,#06b6d4,#22d3ee); }
    .db-quick-icon.pink { background: linear-gradient(135deg,#ec4899,#f472b6); }
    .db-quick-info { display: flex; flex-direction: column; }
    .db-quick-title { font-size: 14px; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
    .db-quick-desc { font-size: 12px; color: #94a3b8; line-height: 1.5; }

    /* 卡片 */
    .db-card {
        background: #fff; border-radius: 14px; border: 1px solid #e8ecf1;
        box-shadow: 0 2px 8px rgba(0,0,0,.03); margin-bottom: 20px; overflow: hidden;
    }
    .db-card-header {
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .db-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 10px; }
    .db-card-title svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .db-card-link {
        font-size: 13px; color: #6366f1; text-decoration: none; font-weight: 500;
        display: flex; align-items: center; gap: 4px;
    }
    .db-card-link:hover { color: #4f46e5; text-decoration: underline; }
    .db-card-link svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; }
    .db-card-body { padding: 20px 24px; }

    /* 班级网格 */
    .db-class-grid { width: 100%; overflow-x: auto; overflow-y: hidden; }
    .db-class-grid table {
        width: 100% !important;
        min-width: 1200px;
        border: none !important;
        border-collapse: collapse;
        table-layout: fixed;
    }
    .db-class-grid td {
        width: 10%;
        border: none !important;
        padding: 0 !important;
        vertical-align: top;
    }
    .db-class-grid div[style] {
        width: 100% !important;
        padding: 6px !important;
        box-sizing: border-box;
    }
    .db-class-grid a {
        display: flex !important; align-items: center; justify-content: center;
        width: 100% !important; min-width: 0 !important; height: 56px !important;
        padding: 0 10px !important;
        background: #f8fafc !important; border: 1.5px solid #e2e8f0 !important;
        border-radius: 14px !important;
        font-size: 14px !important; font-weight: 700 !important; color: #475569 !important;
        text-decoration: none !important; transition: all .2s ease !important; cursor: pointer;
        box-sizing: border-box;
    }
    .db-class-grid a:hover {
        background: #eef2ff !important; border-color: #818cf8 !important;
        color: #4f46e5 !important; box-shadow: 0 3px 12px rgba(99,102,241,.12) !important;
        transform: translateY(-2px);
    }

    /* 消息 */
    .db-msg { font-size: 13px; color: #64748b; margin-top: 12px; min-height: 18px; }

    @media (max-width: 1600px) {
        .db-quick-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    }
    @media (max-width: 1280px) {
        .db-quick-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    }
    @media (max-width: 900px) {
        .db-quick-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }
    @media (max-width: 640px) {
        .db-quick-grid { grid-template-columns: 1fr; }
    }
</style>

<div class="db-page">
    <!-- 欢迎横幅 -->
    <div class="db-banner">
        <div class="db-banner-left">
            <div class="db-banner-icon">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            </div>
            <div class="db-banner-text">
                <div class="db-welcome">
                    <asp:Label ID="Labelwelcome" runat="server" ForeColor="White" Font-Bold="True"></asp:Label>
                </div>
                <div class="db-welcome-sub">欢迎回到教师工作台，今天也要加油哦！</div>
            </div>
        </div>
        <div class="db-banner-right">
            <div class="db-banner-time">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                <span id="dbDateTime"></span>
            </div>
        </div>
    </div>

    <!-- 统计卡片行 -->
    <div class="db-stats">
        <div class="db-stat-card">
            <div class="db-stat-icon purple">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            </div>
            <div class="db-stat-info">
                <span class="db-stat-label">当前学期</span>
                <span class="db-stat-value"><asp:Label ID="Labelterm" runat="server"></asp:Label></span>
            </div>
        </div>
        <div class="db-stat-card">
            <div class="db-stat-icon blue">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div class="db-stat-info">
                <span class="db-stat-label">我的班级</span>
                <span class="db-stat-value" id="dbClassCount">--</span>
            </div>
        </div>
        <div class="db-stat-card">
            <div class="db-stat-icon green">
                <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            </div>
            <div class="db-stat-info">
                <span class="db-stat-label">平台状态</span>
                <span class="db-stat-value">运行中</span>
            </div>
        </div>
        <div class="db-stat-card">
            <div class="db-stat-icon amber">
                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div class="db-stat-info">
                <span class="db-stat-label">今日任务</span>
                <span class="db-stat-value">已就绪</span>
            </div>
        </div>
    </div>

    <!-- 快捷操作网格 -->
    <div class="db-quick-grid">
        <a href="start.aspx" class="db-quick-card">
            <div class="db-quick-icon indigo">
                <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">开始上课</span>
                <span class="db-quick-desc">选择班级和课程，开始今天的教学</span>
            </div>
        </a>
        <a href="course.aspx" class="db-quick-card">
            <div class="db-quick-icon blue">
                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">课程备课</span>
                <span class="db-quick-desc">创建和管理课程内容</span>
            </div>
        </a>
        <a href="works.aspx" class="db-quick-card">
            <div class="db-quick-icon green">
                <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">作品管理</span>
                <span class="db-quick-desc">查看和评价学生作品</span>
            </div>
        </a>
        <a href="signin.aspx" class="db-quick-card">
            <div class="db-quick-icon amber">
                <svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">签到管理</span>
                <span class="db-quick-desc">查看学生签到记录</span>
            </div>
        </a>
        <a href="student.aspx" class="db-quick-card">
            <div class="db-quick-icon rose">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">学生管理</span>
                <span class="db-quick-desc">管理学生信息和成绩</span>
            </div>
        </a>
        <a href="soft.aspx" class="db-quick-card">
            <div class="db-quick-icon cyan">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">资源中心</span>
                <span class="db-quick-desc">管理教学资源和文件</span>
            </div>
        </a>
        <a href="petmanage.aspx" class="db-quick-card">
            <div class="db-quick-icon pink">
                <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            </div>
            <div class="db-quick-info">
                <span class="db-quick-title">宠物管理</span>
                <span class="db-quick-desc">班级宠物激励、规则与事件</span>
            </div>
        </a>
    </div>

    <!-- 班级列表卡片 -->
    <div class="db-card">
        <div class="db-card-header">
            <div class="db-card-title">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                我的班级列表
            </div>
            <a href="student.aspx" class="db-card-link">
                管理学生
                <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
        </div>
        <div class="db-card-body">
            <div class="db-class-grid">
                <asp:DataList ID="DLmyclass" runat="server" RepeatColumns="10"
                    RepeatDirection="Horizontal" CellPadding="0" CellSpacing="0"
                    onitemdatabound="DLmyclass_ItemDataBound">
                    <ItemTemplate>
                        <div style="padding: 6px;">
                            <asp:HyperLink ID="HyperRgradeclass" runat="server" Font-Underline="False"
                                Text='<%# Eval("Rgradeclass") %>'></asp:HyperLink>
                            <asp:Label ID="LabelRset" runat="server" Text='<%# Eval("Rset") %>' Visible="False"></asp:Label>
                            <asp:Label ID="LabelRreg" runat="server" Text='<%# Eval("Rreg") %>' Visible="False"></asp:Label>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
            <div class="db-msg">
                <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgBlack"></asp:Label>
            </div>
        </div>
    </div>

    <asp:Button ID="Btnlogout" runat="server" Text="退出登录" onclick="Btnlogout_Click" style="display:none" />
</div>

<script type="text/javascript">
    // 更新日期时间
    function updateDateTime() {
        var now = new Date();
        var y = now.getFullYear();
        var m = (now.getMonth() + 1).toString().padStart(2, '0');
        var d = now.getDate().toString().padStart(2, '0');
        var h = now.getHours().toString().padStart(2, '0');
        var mi = now.getMinutes().toString().padStart(2, '0');
        var weeks = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
        var el = document.getElementById('dbDateTime');
        if (el) el.textContent = y + '年' + m + '月' + d + '日 ' + weeks[now.getDay()] + ' ' + h + ':' + mi;
    }
    updateDateTime();
    setInterval(updateDateTime, 30000);

    // 统计班级数量
    document.addEventListener('DOMContentLoaded', function () {
        var links = document.querySelectorAll('.db-class-grid a');
        var el = document.getElementById('dbClassCount');
        if (el) el.textContent = links.length > 0 ? links.length + ' 个' : '0';

    });

    // Auto-logout
    document.addEventListener('DOMContentLoaded', function() {
        if (window.location.search.indexOf('logout=1') !== -1) {
            var btn = document.querySelectorAll('input[type="submit"][id*="Btnlogout"]');
            if (btn.length > 0) btn[0].click();
        }
    });
</script>
</asp:Content>

