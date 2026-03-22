<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_workcheck, LearnSite" %>
<script runat="server">
    // 修复 ShowDoneWorks() 中 int.Parse(DDLmid.SelectedValue) 无安全检查的 bug
    // 当 DDLmid/DDLclass 为空时，PostBack 事件处理器会抛出 FormatException
    // 此处在 OnLoad（事件处理器执行前）注入防护，确保 DDL 有可解析的值
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (IsPostBack)
        {
            if (DDLmid.Items.Count == 0 || string.IsNullOrEmpty(DDLmid.SelectedValue))
            {
                DDLmid.Items.Insert(0, new ListItem("--", "0"));
                DDLmid.SelectedIndex = 0;
            }
            if (DDLclass.Items.Count == 0 || string.IsNullOrEmpty(DDLclass.SelectedValue))
            {
                DDLclass.Items.Insert(0, new ListItem("--", "0"));
                DDLclass.SelectedIndex = 0;
            }
        }
    }

    /// <summary>
    /// 评分后同步学分：根据当前班级重新计算所有学生的 Sscore
    /// </summary>
    private void SyncClassScores()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (string.IsNullOrEmpty(cs)) return;

        // 从 URL 获取 grade 参数
        string gradeStr = Request.QueryString["grade"];
        int grade = 0;
        if (!string.IsNullOrEmpty(gradeStr)) int.TryParse(gradeStr, out grade);
        int cls = 0;
        if (DDLclass != null && DDLclass.Items.Count > 0)
            int.TryParse(DDLclass.SelectedValue, out cls);
        if (grade <= 0 || cls <= 0) return;

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = @"UPDATE Students SET Sscore = ISNULL((
                    SELECT SUM(ISNULL(w.Wscore,0) + ISNULL(w.Wdscore,0))
                    FROM Works w WHERE w.Wnum = Students.Snum AND w.Wscore > 0
                ), 0) WHERE Sgrade=@g AND Sclass=@c";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@g", grade);
                    cmd.Parameters.AddWithValue("@c", cls);
                    cmd.CommandTimeout = 10;
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        base.OnLoadComplete(e);
        // 每次 PostBack（评分操作）后同步学分
        if (IsPostBack)
        {
            SyncClassScores();
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <!-- 保留隐藏控件供代码后台字段兼容 -->
    <asp:Image ID="Imagelogo" runat="server" ImageUrl="~/images/learnsite.gif" style="display:none" />

    <style>
        /* ===== 白色背景覆盖母版页 ===== */
        .content-area { background: #fff !important; }

        /* ===== 作品评价页面 ===== */
        .wc-page { max-width: 1400px; margin: 0 auto; }

        /* 页面标题 */
        .page-title-bar {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 18px;
        }
        .page-title-bar h2 {
            font-size: 20px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .page-title-bar h2 .title-icon {
            width: 34px; height: 34px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .page-title-bar h2 .title-icon svg {
            width: 18px; height: 18px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .page-title-bar .title-desc {
            font-size: 13px; color: #94a3b8; font-weight: 400; margin-left: 4px;
        }

        /* 卡片容器 */
        .wc-card {
            background: #fff; border-radius: 14px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05), 0 4px 16px rgba(0,0,0,0.03);
            border: 1px solid #e2e8f0; overflow: hidden;
            margin-bottom: 18px;
        }

        /* 评分说明 - 折叠紧凑 */
        .guide-panel {
            padding: 10px 20px; background: #fff;
            border-bottom: 1px solid #f1f5f9;
            display: flex; align-items: center; flex-wrap: wrap; gap: 10px;
        }
        .guide-panel .guide-title {
            font-size: 12px; font-weight: 600; color: #64748b;
            display: flex; align-items: center; gap: 5px; margin-right: 4px;
        }
        .guide-panel .guide-title svg {
            width: 14px; height: 14px; stroke: #94a3b8; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .guide-grades {
            display: flex; flex-wrap: wrap; gap: 5px;
        }
        .guide-grades .grade-chip {
            display: inline-flex; align-items: center; gap: 3px;
            padding: 2px 8px; border-radius: 5px; font-size: 11px; font-weight: 600;
            background: #f8fafc; border: 1px solid #e2e8f0;
        }
        .grade-chip .gl { color: #475569; font-weight: 500; }
        .grade-chip .gv { color: #6366f1; font-weight: 700; }
        .grade-chip.g-g { border-color: #e9d5ff; background: #faf5ff; }
        .grade-chip.g-a { border-color: #c7d2fe; background: #eef2ff; }
        .grade-chip.g-b { border-color: #a7f3d0; background: #f0fdf4; }
        .grade-chip.g-c { border-color: #fde68a; background: #fffbeb; }
        .grade-chip.g-d { border-color: #fed7aa; background: #fff7ed; }
        .grade-chip.g-e { border-color: #fecaca; background: #fef2f2; }
        .guide-tips {
            font-size: 11px; color: #94a3b8; display: flex; gap: 12px; margin-left: auto;
        }
        .guide-tips span { white-space: nowrap; }

        /* 筛选栏 */
        .filter-bar {
            display: flex; align-items: center; flex-wrap: wrap; gap: 12px;
            padding: 14px 20px; background: #fff;
            border-bottom: 1px solid #f1f5f9;
        }
        .filter-group {
            display: flex; align-items: center; gap: 6px;
            font-size: 13px; color: #475569;
        }
        .filter-group .filter-label {
            font-weight: 600; color: #334155; white-space: nowrap;
        }
        .filter-bar select,
        .filter-group select {
            height: 34px; padding: 0 10px; border: 1px solid #d1d5db;
            border-radius: 8px; background: #fff; font-size: 13px; color: #334155;
            outline: none; cursor: pointer; transition: all 0.2s;
        }
        .filter-bar select:hover, .filter-group select:hover { border-color: #818cf8; }
        .filter-bar select:focus, .filter-group select:focus {
            border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        }
        .filter-spacer { flex: 1; }
        .course-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 14px; background: #eef2ff; border: 1px solid #c7d2fe;
            border-radius: 20px; font-size: 13px; color: #4f46e5; font-weight: 600;
        }
        .course-badge .cb-icon {
            width: 16px; height: 16px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .course-badge .cb-label { color: #818cf8; font-size: 12px; font-weight: 500; }

        /* 按钮组 */
        .btn-row {
            display: flex; align-items: center; flex-wrap: wrap; gap: 6px;
            padding: 12px 20px; border-bottom: 1px solid #f1f5f9;
        }
        .wc-page .btn-outline {
            height: 30px; padding: 0 12px; border-radius: 6px; font-size: 12px;
            font-weight: 500; cursor: pointer; transition: all 0.2s;
            border: 1px solid #d1d5db; background: #fff; color: #475569;
            white-space: nowrap;
        }
        .wc-page .btn-outline:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
        }
        .wc-page .btn-primary {
            height: 30px; padding: 0 12px; border: none; border-radius: 6px;
            font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.15s;
            background: #6366f1; color: #fff !important; white-space: nowrap;
        }
        .wc-page .btn-primary:hover {
            background: #4f46e5; box-shadow: 0 2px 8px rgba(99,102,241,0.3);
        }
        .wc-page .btn-warn {
            height: 30px; padding: 0 12px; border: none; border-radius: 6px;
            font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.15s;
            background: #f59e0b; color: #fff !important; white-space: nowrap;
        }
        .wc-page .btn-warn:hover {
            background: #d97706; box-shadow: 0 2px 8px rgba(245,158,11,0.3);
        }
        .btn-sep {
            width: 1px; height: 18px; background: #e2e8f0; margin: 0 2px;
        }
        .btn-row input[type="image"] { height: 22px; vertical-align: middle; }
        /* 展播链接 */
        .play-links { display: inline-flex; gap: 5px; margin-left: 2px; }
        .play-links a {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 11px; color: #6366f1; text-decoration: none !important; font-weight: 600;
            padding: 4px 10px; border-radius: 6px; transition: all 0.15s;
            background: #eef2ff; border: 1px solid #c7d2fe; cursor: pointer;
        }
        .play-links a:hover { color: #4338ca; background: #e0e7ff; }
        .play-links a img { height: 14px; vertical-align: middle; }
        .play-links .play-auto::after { content: '个人展播'; }
        .play-links .play-group::after { content: '小组展播'; }

        /* 信息栏 */
        .info-row {
            display: flex; align-items: center; flex-wrap: wrap; gap: 14px;
            padding: 10px 20px; border-bottom: 1px solid #f1f5f9;
            font-size: 13px; color: #475569;
        }
        .info-row .legend-item {
            display: inline-flex; align-items: center; gap: 5px; font-size: 12px; color: #64748b;
        }
        .info-row .stat-item {
            display: inline-flex; align-items: center; gap: 4px; font-size: 13px;
            padding: 3px 12px; background: #f0fdf4; border-radius: 16px; border: 1px solid #bbf7d0;
        }
        .info-row .stat-item .stat-label { color: #16a34a; font-size: 12px; font-weight: 500; }
        .info-row .stat-item .stat-val { font-weight: 700; color: #15803d; }
        .info-row .msg-text { color: #ef4444; font-size: 12px; }

        /* 排序栏 */
        .sort-row {
            display: flex; align-items: center; flex-wrap: wrap; gap: 2px;
            padding: 10px 20px; border-bottom: 1px solid #f1f5f9;
            font-size: 12px; color: #64748b; background: #fafbfc;
        }
        .sort-row .sort-label {
            font-weight: 600; color: #334155; margin-right: 8px;
            display: flex; align-items: center; gap: 4px;
        }
        .sort-row .sort-label svg {
            width: 14px; height: 14px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .sort-row input[type="radio"] { margin-right: 2px; accent-color: #6366f1; }
        .sort-row label { cursor: pointer; padding: 3px 10px; border-radius: 6px; transition: all 0.15s; font-size: 12px; }
        .sort-row label:hover { background: #eef2ff; color: #4f46e5; }

        /* 作品网格区域 */
        .works-grid {
            padding: 20px;
        }
        .works-grid .section-title {
            font-size: 14px; font-weight: 600; color: #334155;
            margin-bottom: 16px; display: flex; align-items: center; gap: 8px;
        }
        .works-grid .section-title .sec-icon {
            width: 28px; height: 28px; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
        }
        .works-grid .section-title .sec-icon svg {
            width: 16px; height: 16px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .works-grid .section-title .sec-desc {
            font-size: 12px; color: #94a3b8; font-weight: 400; margin-left: 4px;
        }

        /* DataList 容器 - 使用 flexbox 横向布局 */
        .works-grid table {
            display: flex !important;
            flex-wrap: wrap !important;
            gap: 10px !important;
            border-collapse: separate;
            border-spacing: 0 !important;
            width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        .works-grid table tbody {
            display: contents !important;
        }
        .works-grid table tr {
            display: contents !important;
            width: auto !important;
        }
        .works-grid table td {
            display: block !important;
            padding: 0 !important;
            border: none !important;
            margin: 0 !important;
            width: auto !important;
            float: none !important;
        }

        /* 个人作品卡片 - 横向排列 */
        .works-grid .divscore {
            background: #fff; border: 1px solid #e8ecf1; border-radius: 10px;
            padding: 10px 8px; text-align: center; 
            width: 120px; min-width: 120px; max-width: 120px;
            flex-shrink: 0; flex-grow: 0;
            transition: all 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            display: inline-block;
            vertical-align: top;
            box-sizing: border-box;
        }
        .works-grid .divscore:hover {
            border-color: #c7d2fe; box-shadow: 0 4px 12px rgba(99,102,241,0.1);
            transform: translateY(-2px);
        }
        .works-grid .workname {
            display: inline-block; background: linear-gradient(135deg, #eef2ff, #e0e7ff);
            color: #4f46e5; text-decoration: none; border-radius: 6px;
            padding: 2px 8px; font-size: 12px; font-weight: 600;
            width: auto; height: auto; line-height: 1.6;
            transition: all 0.15s;
        }
        .works-grid .workname:hover {
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe); color: #4338ca;
        }

        /* 评分按钮 */
        .works-grid .wscored {
            display: inline-block; width: 26px; height: 22px; line-height: 22px;
            text-align: center; font-size: 11px; font-weight: 700;
            border-radius: 5px; cursor: pointer; transition: all 0.15s;
            text-decoration: none;
            background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0;
        }
        .works-grid .wscored:hover {
            background: #eef2ff; color: #4f46e5; border-color: #c7d2fe;
            transform: scale(1.1);
        }

        /* 票数/互评/组评数字 */
        .works-grid .divscore .score-stats {
            font-size: 11px; color: #94a3b8; margin: 4px 0;
        }
        .works-grid .divscore .score-stats span { margin: 0 2px; }

        /* 小组作品卡片 - 横向排列 */
        .works-grid .divgroupscore {
            background: #fff; border: 1px solid #e8ecf1; border-radius: 10px;
            padding: 10px 8px; text-align: center; 
            width: 140px; min-width: 140px; max-width: 140px;
            flex-shrink: 0; flex-grow: 0;
            transition: all 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            display: inline-block;
            vertical-align: top;
            box-sizing: border-box;
        }
        .works-grid .divgroupscore:hover {
            border-color: #bbf7d0; box-shadow: 0 4px 12px rgba(34,197,94,0.1);
            transform: translateY(-2px);
        }
        .works-grid .groupname {
            display: inline-block; background: linear-gradient(135deg, #f0fdf4, #dcfce7);
            color: #16a34a; text-decoration: none; border-radius: 6px;
            padding: 2px 8px; font-size: 12px; font-weight: 600;
            width: auto; height: auto; line-height: 1.6;
            margin: 0; transition: all 0.15s;
        }
        .works-grid .groupname:hover {
            background: linear-gradient(135deg, #dcfce7, #bbf7d0); color: #15803d;
        }

        /* 未提交学生 - 标签流式布局 */
        .nowork-section {
            padding: 16px 20px;
            border-top: 1px solid #f1f5f9;
        }
        .nowork-section .section-title {
            font-size: 13px; font-weight: 600; color: #64748b;
            margin-bottom: 10px; display: flex; align-items: center; gap: 6px;
        }
        .nowork-section .section-title .sec-icon {
            width: 22px; height: 22px; border-radius: 6px; background: #fff1f2;
            display: flex; align-items: center; justify-content: center;
        }
        .nowork-section .section-title .sec-icon svg {
            width: 12px; height: 12px; stroke: #fb7185; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .nowork-section .section-title .sec-desc {
            font-size: 11px; color: #94a3b8; font-weight: 400;
        }
        /* 覆盖 DataList 表格为流式布局 */
        .nowork-grid table { border-collapse: collapse; border-spacing: 0; }
        .nowork-grid table,
        .nowork-grid table tbody,
        .nowork-grid table tr,
        .nowork-grid table td {
            display: inline; border: none; padding: 0; margin: 0; background: none;
        }
        .nowork-grid table td > div {
            display: inline-flex; align-items: center; gap: 6px;
            margin: 3px; padding: 5px 12px 5px 5px;
            background: #fff; border: 1px solid #e2e8f0; border-radius: 8px;
            transition: all 0.15s;
        }
        .nowork-grid table td > div:hover {
            border-color: #c7d2fe; background: #f5f3ff;
            box-shadow: 0 2px 6px rgba(99,102,241,0.1);
        }
        .nowork-grid table td > div::before {
            content: '';
            width: 24px; height: 24px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, #fda4af, #fb7185);
        }
        .nowork-grid table td span {
            font-size: 12px; font-weight: 500; color: #334155;
            width: auto !important; height: auto !important;
        }

        /* 底部操作 */
        .bottom-bar {
            display: flex; align-items: center; gap: 12px;
            margin-top: 14px; padding-bottom: 20px;
        }
        .wc-page .btn-close {
            height: 34px; padding: 0 18px; border-radius: 8px; font-size: 13px;
            font-weight: 500; cursor: pointer; transition: all 0.2s;
            border: 1px solid #e2e8f0; background: #fff; color: #64748b;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .wc-page .btn-close:hover { background: #f1f5f9; color: #334155; border-color: #cbd5e1; }

        /* 响应式布局 - 小屏幕自适应 */
        @media (max-width: 768px) {
            .works-grid .divscore {
                width: calc(50% - 5px);
                min-width: calc(50% - 5px);
            }
            .works-grid .divgroupscore {
                width: calc(50% - 5px);
                min-width: calc(50% - 5px);
            }
        }
        @media (min-width: 769px) and (max-width: 1200px) {
            .works-grid .divscore {
                width: calc(33.333% - 7px);
                min-width: calc(33.333% - 7px);
            }
            .works-grid .divgroupscore {
                width: calc(33.333% - 7px);
                min-width: calc(33.333% - 7px);
            }
        }
    </style>

    <div class="wc-page">
        <!-- 页面标题 -->
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                </span>
                作品评价
            </h2>
        </div>

        <!-- 主卡片 -->
        <div class="wc-card">
            <!-- 评分说明栏 - 单行紧凑 -->
            <div class="guide-panel">
                <div class="guide-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    评分：
                </div>
                <div class="guide-grades">
                    <span class="grade-chip g-g"><span class="gl">G</span><span class="gv">12</span></span>
                    <span class="grade-chip g-a"><span class="gl">A</span><span class="gv">10</span></span>
                    <span class="grade-chip g-b"><span class="gl">B</span><span class="gv">8</span></span>
                    <span class="grade-chip g-c"><span class="gl">C</span><span class="gv">6</span></span>
                    <span class="grade-chip g-d"><span class="gl">D</span><span class="gv">4</span></span>
                    <span class="grade-chip g-e"><span class="gl">E</span><span class="gv">2</span></span>
                </div>
                <div class="guide-tips">
                    <span>✔ 已评=不可重交</span>
                    <span>✖ 未评=可重交</span>
                    <span>🔄 30s刷新</span>
                </div>
            </div>

            <!-- 筛选栏 -->
            <div class="filter-bar">
                <div class="filter-group">
                    <asp:Label ID="Labelshow" runat="server" Font-Bold="True" Font-Size="14px" ForeColor="#1e293b"></asp:Label>
                </div>
                <div class="filter-group">
                    <span class="filter-label">班级</span>
                    <asp:DropDownList ID="DDLclass" runat="server" Font-Size="9pt"
                        Width="50px" AutoPostBack="True"
                        onselectedindexchanged="DDLclass_SelectedIndexChanged" Font-Bold="True">
                    </asp:DropDownList>
                </div>
                <div class="filter-group">
                    <asp:Label ID="Labeltxt" runat="server" Font-Bold="True" Font-Size="14px" ForeColor="#1e293b"></asp:Label>
                </div>
                <span class="filter-spacer"></span>
                <span class="course-badge">
                    <svg class="cb-icon" viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    <asp:Label ID="Labeltitle" runat="server"></asp:Label>
                </span>
            </div>

            <!-- 活动选择 + 操作按钮 -->
            <div class="btn-row">
                <div class="filter-group">
                    <span class="filter-label">活动</span>
                    <asp:DropDownList ID="DDLmid" runat="server" Font-Names="Arial"
                        Font-Size="9pt" AutoPostBack="True" Width="220px"
                        onselectedindexchanged="DDLmid_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
                <div class="btn-sep"></div>
                <asp:ImageButton ID="BtnCheck" runat="server" onclick="BtnCheck_Click" 
                    ImageUrl="~/images/check.png" ToolTip="将本班自动得分作品全部设置为已评" />
                <asp:Button ID="BtnA" runat="server" Text="一键评A" CssClass="btn-primary"
                    onclick="BtnA_Click" ToolTip="将本班该活动未评的作品，全部评为A" />
                <asp:Button ID="BtnB" runat="server" Text="一键评B" CssClass="btn-outline"
                    onclick="BtnB_Click" ToolTip="将本班该活动未评的作品，全部评为B" />
                <asp:Button ID="BtnCk" runat="server" Text="一键已评" CssClass="btn-outline"
                    onclick="BtnCk_Click" ToolTip="不用给分的作品，一健全评为０" />
                <asp:Button ID="BtnWp" runat="server" Text="一键未评" CssClass="btn-warn"
                    onclick="BtnWp_Click" ToolTip="所有作品一键未评" />
                <span class="play-links">
                    <asp:HyperLink ID="HLautoplay" runat="server" Target="_blank" 
                        ToolTip="个人作品自动展播" CssClass="play-auto"></asp:HyperLink>
                    <asp:HyperLink ID="HLgroupplay" runat="server" Target="_blank" 
                        ToolTip="小组作品自动展播" CssClass="play-group"></asp:HyperLink>
                </span>
            </div>

            <!-- 信息栏 -->
            <div class="info-row">
                <span class="legend-item">
                    <asp:Label ID="Labelcolor" runat="server" BackColor="#CDE2FE" Width="12px" Height="12px"
                        style="display:inline-block;border-radius:3px;"></asp:Label>
                    作品标志
                </span>
                <span class="legend-item">
                    <asp:Label ID="Labelscore" runat="server" BackColor="#FFCC99" Width="12px" Height="12px"
                        style="display:inline-block;border-radius:3px;"></asp:Label>
                    评价等级
                </span>
                <span class="stat-item">
                    <span class="stat-label">作品总数：</span>
                    <span class="stat-val"><asp:Label ID="Labelcounts" runat="server"></asp:Label></span>
                </span>
                <asp:Image ID="ImageType" runat="server" style="height:16px;vertical-align:middle;" />
                <span class="msg-text"><asp:Label ID="Labelmsg" runat="server"></asp:Label></span>
                <asp:ImageButton ID="ImgBtnFlasherror" runat="server" 
                    ImageUrl="~/images/flasherror.png" onclick="ImgBtnFlasherror_Click" 
                    ToolTip="Office文档转换异常标志清除重新转换" style="height:16px;vertical-align:middle;" />
            </div>

            <!-- 排序栏 -->
            <div class="sort-row">
                <span class="sort-label">
                    <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                    排序方式
                </span>
                <asp:RadioButtonList ID="RBsort" runat="server" AutoPostBack="True" 
                    Font-Size="9pt" onselectedindexchanged="RBsort_SelectedIndexChanged" 
                    RepeatDirection="Horizontal" RepeatLayout="Flow">
                    <Items>
                        <asp:ListItem Value="0" Selected="True">时间排序</asp:ListItem>
                        <asp:ListItem Value="1">学号排序</asp:ListItem>
                        <asp:ListItem Value="2">IP 排序</asp:ListItem>
                        <asp:ListItem Value="3">小组排序</asp:ListItem>
                        <asp:ListItem Value="4">投票排序</asp:ListItem>
                    </Items>
                </asp:RadioButtonList>
            </div>

            <!-- 个人作品区域 -->
            <div class="works-grid">
                <div class="section-title">
                    <span class="sec-icon" style="background:linear-gradient(135deg,#6366f1,#818cf8);">
                        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </span>
                    个人作品
                    <span class="sec-desc">— 点击姓名查看作品，点击字母评分</span>
                </div>
                <asp:DataList ID="DataListworks" runat="server" RepeatDirection="Horizontal" 
                    RepeatColumns="8" DataKeyField="Wid" CellPadding="2" 
                    onitemdatabound="DataListworks_ItemDataBound" 
                    onitemcommand="DataListworks_ItemCommand" CellSpacing="2">
                    <ItemTemplate>
                        <div class="divscore">
                            <div>
                                <asp:HyperLink ID="HyperLink1" runat="server" Text='<%# Eval("Sname") %>' 
                                    ToolTip='<%# HttpUtility.HtmlDecode(Eval("Wself").ToString()) %>' Target="_blank" CssClass="workname"></asp:HyperLink>
                                <asp:CheckBox ID="CB" runat="server" Checked='<%# Eval("Wcheck") %>' 
                                    EnableTheming="True" ToolTip="评价状态：取消则评分为0并可重新提交，选中则初始评分为0并不可重新提交" 
                                    oncheckedchanged="CB_CheckedChanged" AutoPostBack="True" BorderStyle="None" />
                            </div>
                            <div class="score-stats">
                                <asp:Label ID="Wv" runat="server" Text='<%# Eval("Wvote") %>' ToolTip="票数"></asp:Label>&nbsp;
                                <asp:Label ID="Wf" runat="server" Text='<%# Eval("Wfscore") %>' ToolTip="互评"></asp:Label>&nbsp;
                                <asp:Label ID="Wl" runat="server" Text='<%# Eval("Wlscore") %>' ToolTip="组评" ForeColor="#6366f1"></asp:Label>
                                <asp:HyperLink ID="Hlflash" runat="server" Height="12px" Target="_blank" ImageUrl="~/images/flashview.png" ToolTip="Flash格式预览" Visible="False"></asp:HyperLink>
                            </div>
                            <div>
                                <asp:LinkButton ID="LG" runat="server" CommandArgument="Wid" CommandName="G" ToolTip="收藏12分" CssClass="wscored">G</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="LA" runat="server" CommandArgument="Wid" CommandName="A" ToolTip="优秀10分" CssClass="wscored">A</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="LB" runat="server" CommandArgument="Wid" CommandName="B" ToolTip="良好8分" CssClass="wscored">B</asp:LinkButton>
                            </div>
                            <div>
                                <asp:LinkButton ID="LC" runat="server" CommandArgument="Wid" CommandName="C" ToolTip="一般6分" CssClass="wscored">C</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="LD" runat="server" CommandArgument="Wid" CommandName="D" ToolTip="落后4分" CssClass="wscored">D</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="LE" runat="server" CommandArgument="Wid" CommandName="E" ToolTip="不及格2分" CssClass="wscored">E</asp:LinkButton>
                            </div>
                            <asp:Label ID="Labelscore" runat="server" Text='<%# Eval("Wscore") %>' Visible="False"></asp:Label>
                            <asp:Label ID="Labelurl" runat="server" Text='<%# Eval("Wurl") %>' Visible="False"></asp:Label>
                            <asp:Label ID="Labelwid" runat="server" Text='<%# Eval("Wid") %>' Visible="False"></asp:Label>
                            <asp:CheckBox ID="Checkwflash" runat="server" Checked='<%# Eval("Wflash") %>' Visible="False" />
                            <asp:CheckBox ID="Checkwerror" runat="server" Checked='<%# Eval("Werror") %>' Visible="False" />
                            <asp:Label ID="Labelwlemotion" runat="server" Text='<%# Eval("Wlemotion") %>' Visible="False"></asp:Label>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>

            <!-- 小组作品区域 -->
            <div class="works-grid" style="border-top: 1px solid #e8ecf1;">
                <div class="section-title">
                    <span class="sec-icon" style="background:linear-gradient(135deg,#059669,#34d399);">
                        <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </span>
                    小组作品
                    <span class="sec-desc">— 小组协作完成的作品，评分范围 12~20</span>
                </div>
                <asp:DataList ID="DataListgroup" runat="server" RepeatDirection="Horizontal" 
                    RepeatColumns="6" DataKeyField="Gid" CellPadding="2" 
                    CellSpacing="2" onitemcommand="DataListgroup_ItemCommand" 
                    onitemdatabound="DataListgroup_ItemDataBound">
                    <ItemTemplate>
                        <div class="divgroupscore">
                            <div>
                                <asp:HyperLink ID="HyperLinkg1" runat="server" Text='<%# Eval("Sgtitle") %>' 
                                    ToolTip='<%# Eval("Gnote") %>' Target="_blank" CssClass="groupname"></asp:HyperLink>
                            </div>
                            <div class="score-stats">
                                <asp:Label ID="Wvg" runat="server" Text='<%# Eval("Gvote") %>' ToolTip="票数"></asp:Label>
                                <asp:CheckBox ID="CBg" runat="server" AutoPostBack="True" BorderStyle="None" 
                                    Checked='<%# Eval("Gcheck") %>' EnableTheming="True" 
                                    oncheckedchanged="CBg_CheckedChanged" 
                                    ToolTip="评价状态：取消则评分为0并可重新提交，选中则初始评分为0并不可重新提交" />
                            </div>
                            <div>
                                <asp:LinkButton ID="L20" runat="server" CommandArgument="Gid" CommandName="20" ToolTip="20学分" CssClass="wscored">A+</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="L19" runat="server" CommandArgument="Gid" CommandName="19" ToolTip="19学分" CssClass="wscored">A</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="L18" runat="server" CommandArgument="Gid" CommandName="18" ToolTip="18学分" CssClass="wscored">A-</asp:LinkButton>
                            </div>
                            <div>
                                <asp:LinkButton ID="L17" runat="server" CommandArgument="Gid" CommandName="17" ToolTip="17学分" CssClass="wscored">B+</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="L16" runat="server" CommandArgument="Gid" CommandName="16" ToolTip="16学分" CssClass="wscored">B</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="L15" runat="server" CommandArgument="Gid" CommandName="15" ToolTip="15学分" CssClass="wscored">B-</asp:LinkButton>
                            </div>
                            <div>
                                <asp:LinkButton ID="L14" runat="server" CommandArgument="Gid" CommandName="14" ToolTip="14学分" CssClass="wscored">C+</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="L13" runat="server" CommandArgument="Gid" CommandName="13" ToolTip="13学分" CssClass="wscored">C</asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="L12" runat="server" CommandArgument="Gid" CommandName="12" ToolTip="12学分" CssClass="wscored">C-</asp:LinkButton>
                            </div>
                            <asp:Label ID="Labelgscore" runat="server" Text='<%# Eval("Gscore") %>' Visible="False"></asp:Label>
                            <asp:Label ID="Labelgurl" runat="server" Text='<%# Eval("Gurl") %>' Visible="False"></asp:Label>
                            <asp:Label ID="Labelgid" runat="server" Text='<%# Eval("Gid") %>' Visible="False"></asp:Label>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>

            <!-- 未提交学生 -->
            <div class="nowork-section">
                <div class="section-title">
                    <span class="sec-icon">
                        <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="18" y1="8" x2="23" y2="13"/><line x1="23" y1="8" x2="18" y2="13"/></svg>
                    </span>
                    未提交
                    <span class="sec-desc">— 以下学生尚未提交该活动的作品</span>
                </div>
                <div class="nowork-grid">
                    <asp:DataList ID="DataListNoworks" runat="server" RepeatDirection="Horizontal" 
                        RepeatColumns="8" CellPadding="1">
                        <ItemTemplate>
                            <div>
                                <asp:Label ID="Label1" runat="server" Height="18px" Text='<%# Eval("Sname") %>' 
                                    ToolTip='<%# Eval("Sscore") %>' Width="80px"></asp:Label>
                            </div>
                        </ItemTemplate>
                    </asp:DataList>
                </div>
            </div>
        </div>

        <!-- 底部操作 -->
        <div class="bottom-bar">
            <asp:Button ID="Btnreturn" runat="server" Text="← 关闭页面" CssClass="btn-close" />
        </div>
    </div>

    <asp:ImageButton ID="Btnreflash" runat="server" ImageUrl="~/images/refresh.gif" onclick="Btnreflash_Click" style="display:none" />

    <script type="text/javascript">
        function myrefresh() {
            document.getElementById("<%= Btnreflash.ClientID %>").click();
        }
        setTimeout("myrefresh()", 30000);

        // 客户端防护：DOMContentLoaded 确保 __doPostBack 已定义后再拦截
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof __doPostBack === 'function') {
                var origPostBack = __doPostBack;
                __doPostBack = function(target, arg) {
                    if (target && (target.indexOf('RBsort') >= 0 || target.indexOf('DDLclass') >= 0 || target.indexOf('DDLmid') >= 0)) {
                        var dc = document.getElementById('<%= DDLclass.ClientID %>');
                        var dm = document.getElementById('<%= DDLmid.ClientID %>');
                        if (!dc || dc.options.length === 0 || dc.value === '' ||
                            !dm || dm.options.length === 0 || dm.value === '') {
                            return;
                        }
                    }
                    origPostBack(target, arg);
                };
            }
        });
    </script>
</asp:Content>
