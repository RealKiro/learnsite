<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_signin, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        /* ===== 签到页面美化 ===== */
        .signin-page { max-width: 100%; margin: 0 auto; padding: 0; }

        /* 页面标题 */
        .signin-page-header {
            display: flex; align-items: center; gap: 14px;
            margin-bottom: 24px;
        }
        .signin-page-header .page-icon {
            width: 48px; height: 48px; border-radius: 14px;
            background: linear-gradient(135deg, #6366f1, #818cf8);
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
            box-shadow: 0 4px 12px rgba(99,102,241,0.25);
        }
        .signin-page-header .page-icon svg { width: 24px; height: 24px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
        .signin-page-header h2 { font-size: 22px; font-weight: 700; color: #1e293b; margin: 0; }
        .signin-page-header .page-desc { font-size: 13px; color: #94a3b8; margin: 3px 0 0; line-height: 1.5; }

        /* 提示横幅 */
        .signin-banner {
            background: linear-gradient(135deg, #eef2ff, #e8eaff);
            border: 1px solid #ddd6fe;
            border-radius: 14px; padding: 16px 22px;
            margin-bottom: 20px;
            display: flex; align-items: flex-start; gap: 14px;
        }
        .signin-banner .banner-icon {
            width: 36px; height: 36px; border-radius: 10px;
            background: #fff; display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; box-shadow: 0 1px 3px rgba(99,102,241,0.12);
        }
        .signin-banner .banner-icon svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
        .signin-banner .banner-content { flex: 1; }
        .signin-banner .banner-title { font-size: 13px; font-weight: 700; color: #4338ca; margin: 0 0 4px; }
        .signin-banner .banner-text { font-size: 12px; color: #6366f1; line-height: 1.7; margin: 0; }
        .signin-banner .banner-text span { display: inline-block; margin-right: 16px; }

        /* 统计卡片行 */
        .signin-stats-row {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: #fff; border-radius: 14px; padding: 20px;
            border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            display: flex; align-items: flex-start; gap: 14px;
            transition: all 0.2s;
        }
        .stat-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.06); transform: translateY(-1px); }
        .stat-card .stat-icon {
            width: 40px; height: 40px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .stat-card .stat-icon svg { width: 20px; height: 20px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
        .stat-card .stat-info { flex: 1; }
        .stat-card .stat-label { font-size: 12px; color: #94a3b8; font-weight: 500; margin: 0 0 4px; }
        .stat-card .stat-title { font-size: 14px; color: #1e293b; font-weight: 600; margin: 0 0 2px; }
        .stat-card .stat-desc { font-size: 11px; color: #94a3b8; line-height: 1.5; margin: 0; }
        .stat-icon-blue { background: #eff6ff; }
        .stat-icon-blue svg { stroke: #3b82f6; }
        .stat-icon-green { background: #ecfdf5; }
        .stat-icon-green svg { stroke: #10b981; }
        .stat-icon-amber { background: #fffbeb; }
        .stat-icon-amber svg { stroke: #f59e0b; }

        /* 筛选卡片 */
        .signin-filter-card {
            background: #fff; border-radius: 14px; padding: 18px 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.06);
            border: 1px solid #e8ecf1; margin-bottom: 20px;
            display: flex; align-items: center; flex-wrap: wrap; gap: 16px;
        }
        .filter-group { display: flex; align-items: center; gap: 8px; }
        .filter-label {
            font-size: 13px; font-weight: 600; color: #475569; white-space: nowrap;
        }
        .filter-label .filter-label-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 28px; height: 28px; border-radius: 8px; background: #f1f5f9;
            margin-right: 6px; vertical-align: middle;
        }
        .filter-label .filter-label-icon svg { width: 15px; height: 15px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

        /* 下拉框美化 */
        .signin-filter-card select {
            appearance: none; -webkit-appearance: none; -moz-appearance: none;
            background: #f8fafc url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E") no-repeat right 10px center;
            border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 8px 32px 8px 14px; font-size: 13px; color: #334155;
            font-weight: 500; min-width: 72px; cursor: pointer;
            transition: all 0.2s ease; outline: none;
        }
        .signin-filter-card select:hover { border-color: #cbd5e1; background-color: #fff; }
        .signin-filter-card select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); background-color: #fff; }

        .filter-unit { font-size: 13px; color: #94a3b8; font-weight: 500; }
        .filter-divider { width: 1px; height: 28px; background: #e2e8f0; margin: 0 4px; }

        /* 导出按钮美化 */
        .filter-actions { display: flex; gap: 10px; margin-left: auto; flex-wrap: wrap; }
        .signin-filter-card input[type="submit"] {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9) !important;
            border: 1px solid #e2e8f0 !important; border-radius: 10px !important;
            padding: 8px 18px !important; font-size: 13px !important;
            font-weight: 600 !important; color: #475569 !important;
            cursor: pointer; transition: all 0.2s ease;
            display: inline-flex; align-items: center; gap: 6px;
            height: auto !important; line-height: 1.4 !important;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
        }
        .signin-filter-card input[type="submit"]:hover {
            background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
            border-color: #c7d2fe !important; color: #4338ca !important;
            box-shadow: 0 2px 6px rgba(99,102,241,0.12);
            transform: translateY(-1px);
        }
        .signin-filter-card input[type="submit"]:active { transform: translateY(0); }

        /* 表格卡片 */
        .signin-table-card {
            background: #fff; border-radius: 14px; overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.06);
            border: 1px solid #e8ecf1; margin-bottom: 20px;
        }
        .signin-table-header {
            padding: 18px 24px 14px; border-bottom: 1px solid #f1f5f9;
            display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;
        }
        .signin-table-header .table-title-group { display: flex; align-items: center; gap: 10px; }
        .signin-table-header .table-title-icon {
            width: 32px; height: 32px; border-radius: 8px; background: #f1f5f9;
            display: flex; align-items: center; justify-content: center;
        }
        .signin-table-header .table-title-icon svg { width: 16px; height: 16px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
        .signin-table-header h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
        .signin-table-header .table-desc { font-size: 12px; color: #94a3b8; }

        /* 底部帮助区 */
        .signin-help-section {
            background: #fff; border-radius: 14px; padding: 20px 24px;
            border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .signin-help-section .help-title {
            font-size: 14px; font-weight: 700; color: #1e293b;
            display: flex; align-items: center; gap: 8px; margin: 0 0 14px;
        }
        .signin-help-section .help-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
        .signin-help-list { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px 24px; }
        .help-item {
            display: flex; align-items: flex-start; gap: 10px;
            font-size: 12px; color: #64748b; line-height: 1.6;
        }
        .help-item .help-num {
            width: 20px; height: 20px; border-radius: 6px; background: #f1f5f9;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
            font-size: 11px; font-weight: 700; color: #6366f1;
        }

        /* GridView 表格美化 */
        .signin-table-card table { width: 100%; border-collapse: collapse; }
        .signin-table-card table th {
            background: #f8fafc !important; color: #475569 !important;
            font-size: 12px !important; font-weight: 600 !important;
            text-transform: uppercase; letter-spacing: 0.5px;
            padding: 14px 16px !important; border-bottom: 2px solid #e8ecf1;
            text-align: left; white-space: nowrap;
        }
        .signin-table-card table td {
            padding: 13px 16px !important; font-size: 13px; color: #334155;
            border-bottom: 1px solid #f1f5f9; transition: background 0.15s;
        }
        .signin-table-card table tr:last-child td { border-bottom: none; }
        .signin-table-card table tr:hover td { background: #fafbfe; }
        .signin-table-card table tr[style*="background-color"] td,
        .signin-table-card table .aspNetAlternate td {
            background-color: #fafbfd !important;
        }
        .signin-table-card table tr[style*="background-color"]:hover td,
        .signin-table-card table .aspNetAlternate:hover td {
            background-color: #f5f6ff !important;
        }

        /* "详细" 链接美化 */
        .signin-table-card table td a {
            display: inline-flex; align-items: center; gap: 4px;
            color: #6366f1; font-weight: 600; text-decoration: none;
            padding: 4px 12px; border-radius: 6px; font-size: 12px;
            background: #eef2ff; transition: all 0.2s;
        }
        .signin-table-card table td a:hover {
            background: #e0e7ff; color: #4338ca;
            transform: translateX(2px);
        }

        /* 分页美化 */
        .signin-table-card table tr:last-child > td[colspan] {
            background: #fafbfc !important; padding: 12px 16px !important;
            border-top: 1px solid #e8ecf1;
        }
        .signin-pager {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 6px; width: 100%; height: auto !important;
            font-size: 13px; color: #64748b;
        }
        .signin-pager .pager-info {
            margin-right: auto; font-size: 12px; color: #94a3b8; font-weight: 500;
        }
        .signin-pager .pager-info span { color: #6366f1; font-weight: 700; }
        .signin-pager a {
            display: inline-flex !important; align-items: center; justify-content: center;
            padding: 6px 14px !important; border-radius: 8px !important;
            background: #f1f5f9 !important; border: 1px solid #e2e8f0 !important;
            color: #475569 !important; font-size: 12px !important;
            font-weight: 600 !important; text-decoration: none !important;
            transition: all 0.2s !important; cursor: pointer;
            height: auto !important; width: auto !important; line-height: 1.4 !important;
        }
        .signin-pager a:hover {
            background: #eef2ff !important; border-color: #c7d2fe !important;
            color: #4338ca !important;
        }

        /* 空状态 */
        .signin-empty {
            text-align: center; padding: 60px 20px; color: #94a3b8;
        }
        .signin-empty svg { width: 48px; height: 48px; stroke: #cbd5e1; fill: none; stroke-width: 1.5; margin-bottom: 12px; }
        .signin-empty p { font-size: 14px; margin: 0; }

        /* 日期查询输入框 */
        .signin-filter-card input[type="text"] {
            appearance: none; -webkit-appearance: none; -moz-appearance: none;
            background: #f8fafc;
            border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 8px 14px; font-size: 13px; color: #334155;
            font-weight: 500; min-width: 150px; cursor: text;
            transition: all 0.2s ease; outline: none;
        }
        .signin-filter-card input[type="text"]::placeholder { color: #94a3b8; font-weight: 400; }
        .signin-filter-card input[type="text"]:hover { border-color: #cbd5e1; background-color: #fff; }
        .signin-filter-card input[type="text"]:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); background-color: #fff; }

        /* 重置按钮 */
        .client-filter-reset-btn {
            background: #f1f5f9; border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 8px 14px; font-size: 13px; font-weight: 600; color: #64748b;
            cursor: pointer; transition: all 0.2s ease; line-height: 1.4;
            display: inline-flex; align-items: center; gap: 5px;
        }
        .client-filter-reset-btn:hover { background: #e2e8f0; color: #475569; border-color: #cbd5e1; transform: translateY(-1px); }
        .client-filter-reset-btn:active { transform: translateY(0); }

        /* 筛选结果计数徽章 */
        .filter-count-badge {
            display: none; align-items: center; gap: 4px;
            padding: 3px 10px; border-radius: 20px;
            background: #eef2ff; color: #4338ca;
            font-size: 12px; font-weight: 600;
            border: 1px solid #c7d2fe;
        }
        .filter-count-badge.active { display: inline-flex; }

        /* 响应式 */
        @media (max-width: 900px) {
            .signin-stats-row { grid-template-columns: 1fr; }
            .signin-help-list { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .signin-filter-card { flex-direction: column; align-items: flex-start; gap: 12px; }
            .filter-actions { margin-left: 0; width: 100%; }
            .filter-divider { display: none; }
            .signin-page-header h2 { font-size: 17px; }
            .signin-banner { flex-direction: column; }
        }
    </style>

    <div class="signin-page">
        <!-- 页面标题 -->
        <div class="signin-page-header">
            <div class="page-icon">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/><path d="M9 16l2 2 4-4"/></svg>
            </div>
            <div>
                <h2>学生签到管理</h2>
                <p class="page-desc">查看和管理各班级学生的课堂签到记录，支持按年级、班级筛选和导出数据</p>
            </div>
        </div>

        <!-- 提示横幅 -->
        <div class="signin-banner">
            <div class="banner-icon">
                <svg viewBox="0 0 24 24"><line x1="9" y1="18" x2="15" y2="18"/><path d="M10 22h4"/><path d="M12 2v1"/><path d="M12 7a4 4 0 0 1 4 4c0 1.5-.8 2.8-2 4h-4c-1.2-1.2-2-2.5-2-4a4 4 0 0 1 4-4z"/><path d="M20 5l-1.5 1.5"/><path d="M4 5l1.5 1.5"/><path d="M22 12h-2"/><path d="M4 12H2"/></svg>
            </div>
            <div class="banner-content">
                <p class="banner-title">签到说明</p>
                <p class="banner-text">
                    <span>▸ 学生通过课堂平台完成签到，系统自动记录签到时间和状态</span>
                    <span>▸ 可将签到或缺席数据导出为 Excel 进行统计分析</span>
                    <span>▸ 点击「详细」查看单次签到的完整学生名单</span>
                </p>
            </div>
        </div>

        <!-- 功能说明卡片 -->
        <div class="signin-stats-row">
            <div class="stat-card">
                <div class="stat-icon stat-icon-blue">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                </div>
                <div class="stat-info">
                    <p class="stat-label">签到记录</p>
                    <p class="stat-title">查看签到详情</p>
                    <p class="stat-desc">选择年级和班级后，可查看该班所有签到记录，点击「详细」查看每次签到的学生名单</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon-green">
                    <svg viewBox="0 0 24 24"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg>
                </div>
                <div class="stat-info">
                    <p class="stat-label">数据导出</p>
                    <p class="stat-title">导出 Excel 报表</p>
                    <p class="stat-desc">支持导出签到记录和缺席记录两种 Excel 报表，方便进行学期出勤统计</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon-amber">
                    <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="17" y1="8" x2="23" y2="8"/></svg>
                </div>
                <div class="stat-info">
                    <p class="stat-label">缺席追踪</p>
                    <p class="stat-title">关注缺席情况</p>
                    <p class="stat-desc">导出缺席 Excel 可快速定位未签到学生，及时了解学生出勤异常情况</p>
                </div>
            </div>
        </div>

        <!-- 筛选条件卡片 -->
        <div class="signin-filter-card">
            <div class="filter-group">
                <span class="filter-label">
                    <span class="filter-label-icon"><svg viewBox="0 0 24 24"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/></svg></span>
                    筛选
                </span>
            </div>
            <div class="filter-group">
                <asp:DropDownList ID="DDLgrade" runat="server" 
                    Width="72px" EnableTheming="True" AutoPostBack="True" 
                    onselectedindexchanged="DDLgrade_SelectedIndexChanged">
                </asp:DropDownList>
                <span class="filter-unit">年级</span>
            </div>
            <div class="filter-group">
                <asp:DropDownList ID="DDLclass" runat="server" 
                    Width="72px" EnableTheming="True" AutoPostBack="True" 
                    onselectedindexchanged="DDLclass_SelectedIndexChanged">
                </asp:DropDownList>
                <span class="filter-unit">班级</span>
            </div>
            <div class="filter-divider"></div>
            <div class="filter-group">
                <span class="filter-label" style="font-size:12px;">
                    <span class="filter-label-icon">
                        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    </span>
                    日期
                </span>
            </div>
            <div class="filter-group">
                <select id="clientFilterYear" onchange="applySigninFilter()">
                    <option value="">全部</option>
                </select>
                <span class="filter-unit">年</span>
            </div>
            <div class="filter-group">
                <select id="clientFilterMonth" onchange="applySigninFilter()">
                    <option value="">全部</option>
                </select>
                <span class="filter-unit">月</span>
            </div>
            <div class="filter-divider"></div>
            <div class="filter-group">
                <input type="text" id="clientFilterKeyword" placeholder="关键词搜索…" oninput="applySigninFilter()" />
            </div>
            <button type="button" class="client-filter-reset-btn" onclick="resetSigninFilter()">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                重置
            </button>
            <div class="filter-divider"></div>
            <div class="filter-actions">
                <asp:Button ID="BtnExcel" runat="server" OnClick="BtnExcel_Click" 
                    Text="⬇ 导出签到Excel" SkinID="BtnLong" ToolTip="将本学期本班签到以Excel表格导出"
                    Width="140px" />
                <asp:Button ID="BtnExcelNoSign" runat="server" OnClick="BtnExcelNoSign_Click" 
                    Text="⬇ 导出缺席Excel" SkinID="BtnLong" ToolTip="将本学期本班缺席以Excel表格导出"
                    Width="140px" />
            </div>
        </div>

        <!-- 签到记录表格 -->
        <div class="signin-table-card">
            <div class="signin-table-header">
                <div class="table-title-group">
                    <div class="table-title-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                    </div>
                    <div>
                        <h3>签到记录列表</h3>
                        <span class="table-desc">展示所选班级的历次签到汇总，点击「详细」查看学生名单</span>
                        <span class="filter-count-badge" id="filterCountBadge">已筛选 0 条</span>
                    </div>
                </div>
            </div>
            <asp:GridView ID="GVSignin" runat="server" AllowPaging="True"
                AutoGenerateColumns="False" PageSize="20" Width="100%" 
                onpageindexchanging="GVSignin_PageIndexChanging" SkinID="GridViewInfo"
                onrowdatabound="GVSignin_RowDataBound" CellPadding="5"> 
                <Columns>
                    <asp:BoundField HeaderText="序号" />
                    <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                    <asp:BoundField DataField="Sclass" HeaderText="班级" />
                    <asp:BoundField DataField="Qyear" HeaderText="年份" />
                    <asp:BoundField DataField="Qmonth" HeaderText="月份" />
                    <asp:BoundField DataField="Qday" HeaderText="日期" />
                    <asp:HyperLinkField DataNavigateUrlFields="Sgrade,Sclass,Qyear,Qmonth,Qday" 
                        DataNavigateUrlFormatString="signshow.aspx?sgrade={0}&amp;&amp;sclass={1}&amp;&amp;qyear={2}&amp;&amp;qmonth={3}&amp;&amp;qday={4}" 
                        Text="详细" HeaderText="操作" />
                </Columns>
                <PagerTemplate>
                    <div class="signin-pager">
                        <span class="pager-info">
                            第 <asp:Label ID="lblPageIndex" runat="server" 
                                Text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1 %>"></asp:Label>
                            页，共 <asp:Label ID="lblPageCount" runat="server" 
                                Text="<%# ((GridView)Container.Parent.Parent).PageCount %>"></asp:Label> 页
                        </span>
                        <asp:LinkButton ID="btnFirst" runat="server" CausesValidation="False" 
                            CommandArgument="First" CommandName="Page" Font-Underline="False" 
                            ForeColor="Black" Text="首页"></asp:LinkButton>
                        <asp:LinkButton ID="btnPrev" runat="server" CausesValidation="False" 
                            CommandArgument="Prev" CommandName="Page" Font-Underline="False" 
                            ForeColor="Black" Text="上一页"></asp:LinkButton>
                        <asp:LinkButton ID="btnNext" runat="server" CausesValidation="False" 
                            CommandArgument="Next" CommandName="Page" Font-Underline="False" 
                            ForeColor="Black" Text="下一页"></asp:LinkButton>
                        <asp:LinkButton ID="btnLast" runat="server" CausesValidation="False" 
                            CommandArgument="Last" CommandName="Page" Font-Underline="False" 
                            ForeColor="Black" Text="尾页"></asp:LinkButton>
                    </div>
                </PagerTemplate>
            </asp:GridView>
        </div>

        <!-- 底部帮助说明 -->
        <div class="signin-help-section">
            <p class="help-title">
                <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                使用帮助
            </p>
            <div class="signin-help-list">
                <div class="help-item">
                    <span class="help-num">1</span>
                    <span>先选择<b>年级</b>，系统会自动加载该年级下的班级列表</span>
                </div>
                <div class="help-item">
                    <span class="help-num">2</span>
                    <span>再选择<b>班级</b>，下方表格将自动显示该班本学期的签到记录</span>
                </div>
                <div class="help-item">
                    <span class="help-num">3</span>
                    <span>点击每行末尾的<b>「详细」</b>链接，可查看该次签到的学生详细名单</span>
                </div>
                <div class="help-item">
                    <span class="help-num">4</span>
                    <span>使用<b>「导出签到Excel」</b>可导出全部签到记录，<b>「导出缺席Excel」</b>可导出缺席情况</span>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
    (function () {
        /* 从当前页表格数据中抽取可选年份和月份，填充下拉框 */
        function initSigninFilter() {
            var table = document.querySelector('.signin-table-card table');
            var yearSel = document.getElementById('clientFilterYear');
            var monthSel = document.getElementById('clientFilterMonth');
            if (!table || !yearSel || !monthSel) return;

            var years = [], months = [];
            var rows = table.querySelectorAll('tr');
            for (var i = 0; i < rows.length; i++) {
                var cells = rows[i].querySelectorAll('td');
                if (cells.length < 6) continue; // 跳过表头行(th)和分页行(colspan)
                var yr = (cells[3].textContent || '').trim();
                var mo = (cells[4].textContent || '').trim();
                if (yr && years.indexOf(yr) < 0) years.push(yr);
                if (mo && months.indexOf(mo) < 0) months.push(mo);
            }

            yearSel.innerHTML = '<option value="">全部年份</option>';
            monthSel.innerHTML = '<option value="">全部月份</option>';

            years.sort();
            for (var j = 0; j < years.length; j++) {
                var o1 = document.createElement('option');
                o1.value = years[j]; o1.textContent = years[j] + ' 年';
                yearSel.appendChild(o1);
            }

            months.sort(function (a, b) { return parseInt(a, 10) - parseInt(b, 10); });
            for (var k = 0; k < months.length; k++) {
                var o2 = document.createElement('option');
                o2.value = months[k]; o2.textContent = months[k] + ' 月';
                monthSel.appendChild(o2);
            }
        }

        /* 按年份、月份、关键词三个维度过滤表格行 */
        function applySigninFilter() {
            var year    = ((document.getElementById('clientFilterYear')    || {}).value || '').trim();
            var month   = ((document.getElementById('clientFilterMonth')   || {}).value || '').trim();
            var keyword = ((document.getElementById('clientFilterKeyword') || {}).value || '').trim().toLowerCase();

            var table = document.querySelector('.signin-table-card table');
            if (!table) return;

            var rows = table.querySelectorAll('tr');
            var total = 0, visible = 0;

            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var cells = row.querySelectorAll('td');
                if (cells.length < 6) continue; // 表头或分页行，不参与过滤

                total++;
                var rowYear  = (cells[3].textContent || '').trim();
                var rowMonth = (cells[4].textContent || '').trim();
                var rowText  = (row.textContent || '').toLowerCase();

                var show = true;
                if (year    && rowYear  !== year)               show = false;
                if (month   && rowMonth !== month)              show = false;
                if (keyword && rowText.indexOf(keyword) < 0)   show = false;

                row.style.display = show ? '' : 'none';
                if (show) visible++;
            }

            // 更新计数徽章
            var badge = document.getElementById('filterCountBadge');
            if (badge) {
                var hasFilter = year || month || keyword;
                if (hasFilter) {
                    badge.textContent = '筛选: ' + visible + ' / ' + total + ' 条';
                    badge.className = 'filter-count-badge active';
                } else {
                    badge.className = 'filter-count-badge';
                }
            }
        }

        /* 清除所有筛选条件 */
        function resetSigninFilter() {
            var yr = document.getElementById('clientFilterYear');
            var mo = document.getElementById('clientFilterMonth');
            var kw = document.getElementById('clientFilterKeyword');
            if (yr) yr.value = '';
            if (mo) mo.value = '';
            if (kw) kw.value = '';
            applySigninFilter();
        }

        // 暴露到全局作用域供内联事件调用
        window.applySigninFilter = applySigninFilter;
        window.resetSigninFilter = resetSigninFilter;

        // 页面就绪后初始化（每次 PostBack 重载后也会重新执行）
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initSigninFilter);
        } else {
            initSigninFilter();
        }
    })();
    </script>
</asp:Content>

