<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" enableviewstatemac="false" inherits="Teacher_systeminfo, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .si-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .si-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .si-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .si-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .si-title .si-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .si-title .si-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .si-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    /* 统计卡片 */
    .si-stats {
        display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;
    }
    .si-stat {
        padding: 18px 20px; border-radius: 10px; border: 1px solid #e8ecf1;
        background: #fff; display: flex; align-items: center; gap: 14px;
        box-shadow: 0 1px 3px rgba(0,0,0,.03);
    }
    .si-stat-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .si-stat-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .si-stat-icon.c1 { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .si-stat-icon.c2 { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .si-stat-icon.c3 { background: linear-gradient(135deg,#10b981,#34d399); }
    .si-stat-icon.c4 { background: linear-gradient(135deg,#f59e0b,#fbbf24); }
    .si-stat-icon.c5 { background: linear-gradient(135deg,#ec4899,#f472b6); }
    .si-stat-icon.c6 { background: linear-gradient(135deg,#8b5cf6,#a78bfa); }
    .si-stat-info { display: flex; flex-direction: column; }
    .si-stat-label { font-size: 12px; color: #94a3b8; margin-bottom: 2px; }
    .si-stat-value { font-size: 20px; font-weight: 700; color: #1e293b; }

    /* 卡片 */
    .si-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .si-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .si-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .si-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .si-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .si-card-body { padding: 20px 24px; }

    /* 服务器信息表 */
    .si-info-grid {
        display: grid; grid-template-columns: 1fr 1fr; gap: 0;
    }
    .si-info-row {
        display: flex; padding: 12px 16px; border-bottom: 1px solid #f1f5f9;
    }
    .si-info-row:nth-child(odd) { background: #fafbfc; }
    .si-info-label {
        width: 140px; font-size: 13px; color: #64748b; font-weight: 500; flex-shrink: 0;
    }
    .si-info-value { font-size: 13px; color: #1e293b; font-weight: 500; }
    .si-info-value img { vertical-align: middle; margin-left: 6px; }

    /* 快捷链接 */
    .si-links {
        display: flex; gap: 12px; margin-bottom: 24px;
    }
    .si-link-item {
        flex: 1; padding: 16px 20px; border-radius: 10px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: center; gap: 12px;
        text-decoration: none; transition: all .18s; cursor: pointer;
        box-shadow: 0 1px 3px rgba(0,0,0,.03);
    }
    .si-link-item:hover { border-color: #c7d2fe; box-shadow: 0 4px 12px rgba(99,102,241,.1); }
    .si-link-icon {
        width: 38px; height: 38px; border-radius: 8px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .si-link-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .si-link-icon.blue { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .si-link-icon.purple { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .si-link-icon.red { background: linear-gradient(135deg,#ef4444,#f87171); }
    .si-link-info { display: flex; flex-direction: column; }
    .si-link-label { font-size: 12px; color: #94a3b8; }
    .si-link-name { font-size: 13px; font-weight: 600; color: #1e293b; }
</style>

<div class="si-page">
    <!-- 页面标题 -->
    <div class="si-header">
        <div class="si-title-wrap">
            <div class="si-title">
                <span class="si-icon">
                    <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                </span>
                系统状态
            </div>
            <div class="si-subtitle">查看网站统计数据和服务器运行状态信息</div>
        </div>
    </div>

    <!-- 统计数据 -->
    <div class="si-stats">
        <div class="si-stat">
            <div class="si-stat-icon c1"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></div>
            <div class="si-stat-info">
                <span class="si-stat-label">学案总数</span>
                <span class="si-stat-value"><asp:Label ID="Label15" runat="server"></asp:Label></span>
            </div>
        </div>
        <div class="si-stat">
            <div class="si-stat-icon c2"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
            <div class="si-stat-info">
                <span class="si-stat-label">作品总数</span>
                <span class="si-stat-value"><asp:Label ID="Label16" runat="server"></asp:Label></span>
            </div>
        </div>
        <div class="si-stat">
            <div class="si-stat-icon c3"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
            <div class="si-stat-info">
                <span class="si-stat-label">学生总数</span>
                <span class="si-stat-value"><asp:Label ID="Label17" runat="server"></asp:Label></span>
            </div>
        </div>
        <div class="si-stat">
            <div class="si-stat-icon c4"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
            <div class="si-stat-info">
                <span class="si-stat-label">签到次数</span>
                <span class="si-stat-value"><asp:Label ID="Label18" runat="server"></asp:Label></span>
            </div>
        </div>
        <div class="si-stat">
            <div class="si-stat-icon c5"><svg viewBox="0 0 24 24"><polyline points="4 7 4 4 20 4 20 7"/><line x1="9" y1="20" x2="15" y2="20"/><line x1="12" y1="4" x2="12" y2="20"/></svg></div>
            <div class="si-stat-info">
                <span class="si-stat-label">打字次数</span>
                <span class="si-stat-value"><asp:Label ID="Label19" runat="server"></asp:Label></span>
            </div>
        </div>
        <div class="si-stat">
            <div class="si-stat-icon c6"><svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></div>
            <div class="si-stat-info">
                <span class="si-stat-label">资源总数</span>
                <span class="si-stat-value"><asp:Label ID="Label20" runat="server"></asp:Label></span>
            </div>
        </div>
    </div>

    <!-- 快捷链接 -->
    <div class="si-links">
        <asp:HyperLink ID="HLcomputer" runat="server" NavigateUrl="~/teacher/computers.aspx" CssClass="si-link-item">
            <div class="si-link-icon blue"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
            <div class="si-link-info"><span class="si-link-label">网络管理</span><span class="si-link-name">机器名IP对应表</span></div>
        </asp:HyperLink>
        <asp:HyperLink ID="HLmythware" runat="server" NavigateUrl="~/teacher/mythware.aspx" CssClass="si-link-item">
            <div class="si-link-icon purple"><svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="2" ry="2"/><line x1="7" y1="2" x2="7" y2="22"/><line x1="17" y1="2" x2="17" y2="22"/><line x1="2" y1="12" x2="22" y2="12"/></svg></div>
            <div class="si-link-info"><span class="si-link-label">教室布局</span><span class="si-link-name">极域班级模型</span></div>
        </asp:HyperLink>
        <asp:HyperLink ID="HLsitelog" runat="server" NavigateUrl="~/teacher/sitelog.aspx" CssClass="si-link-item" Target="_blank">
            <div class="si-link-icon red"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
            <div class="si-link-info"><span class="si-link-label">异常监控</span><span class="si-link-name">网站异常记录查询</span></div>
        </asp:HyperLink>
    </div>

    <!-- 服务器状态卡片 -->
    <div class="si-card">
        <div class="si-card-header">
            <div>
                <div class="si-card-title">
                    <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>
                    <asp:Label ID="Labelcomputer" runat="server"></asp:Label> 服务器状态
                </div>
                <div class="si-card-desc">当前服务器的硬件、软件及运行时信息</div>
            </div>
        </div>
        <div class="si-card-body" style="padding:0;">
            <div class="si-info-grid">
                <div class="si-info-row">
                    <div class="si-info-label">服务器IP</div>
                    <div class="si-info-value"><asp:Label ID="Label1" runat="server"></asp:Label> <asp:Image ID="ImageLogin" runat="server" ImageUrl="~/images/green.gif" /></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">.NET引擎版本</div>
                    <div class="si-info-value"><asp:Label ID="Label8" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">服务器名称</div>
                    <div class="si-info-value"><asp:Label ID="Label2" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">脚本超时时间</div>
                    <div class="si-info-value"><asp:Label ID="Label9" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">操作系统</div>
                    <div class="si-info-value"><asp:Label ID="Label3" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">开机运行时长</div>
                    <div class="si-info-value"><asp:Label ID="Label10" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">CPU数量</div>
                    <div class="si-info-value"><asp:Label ID="Label4" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">进程开始时间</div>
                    <div class="si-info-value"><asp:Label ID="Label11" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">CPU类型</div>
                    <div class="si-info-value"><asp:Label ID="Label5" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">AspNet内存占用</div>
                    <div class="si-info-value"><asp:Label ID="Label12" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">信息服务软件</div>
                    <div class="si-info-value"><asp:Label ID="Label7" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">AspNet CPU时间</div>
                    <div class="si-info-value"><asp:Label ID="Label13" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">服务器区域语言</div>
                    <div class="si-info-value"><asp:Label ID="Label21" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">AspNet当前线程</div>
                    <div class="si-info-value"><asp:Label ID="Label14" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">网站平台版本</div>
                    <div class="si-info-value"><asp:Label ID="Label6" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">Session总数</div>
                    <div class="si-info-value"><asp:Label ID="Label22" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">全局变量数</div>
                    <div class="si-info-value"><asp:Label ID="Label23" runat="server"></asp:Label></div>
                </div>
                <div class="si-info-row">
                    <div class="si-info-label">网站异常记录</div>
                    <div class="si-info-value">
                        <a href="sitelog.aspx" target="_blank" style="color:#6366f1;text-decoration:none;font-weight:500;">点击查询 →</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>

