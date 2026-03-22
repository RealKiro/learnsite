<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_termscores, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        /* ===== 学期总评页面美化 ===== */
        .term-page { max-width: 1400px; margin: 0 auto; }

        /* 页面标题 */
        .page-title-bar {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px;
        }
        .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }

        /* 卡片容器 */
        .term-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            border: 1px solid #e8ecf1; overflow: hidden;
            margin-bottom: 16px;
        }

        /* 筛选栏 */
        .filter-bar {
            display: flex; align-items: center; flex-wrap: wrap; gap: 12px;
            padding: 16px 20px; background: #f8fafc;
            border-bottom: 1px solid #e8ecf1;
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
        .term-badge {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 4px 12px; border-radius: 16px; font-size: 12px; font-weight: 600;
            background: #eef2ff; color: #4f46e5; border: 1px solid #c7d2fe;
        }

        /* 按钮组 */
        .btn-group {
            display: flex; align-items: center; flex-wrap: wrap; gap: 8px;
            padding: 14px 20px; border-bottom: 1px solid #e8ecf1;
        }
        .term-page .btn-outline {
            height: 34px; padding: 0 16px; border-radius: 8px; font-size: 13px;
            font-weight: 500; cursor: pointer; transition: all 0.2s;
            border: 1px solid #d1d5db; background: #fff; color: #475569;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
            white-space: nowrap;
        }
        .term-page .btn-outline:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
            box-shadow: 0 2px 8px rgba(99,102,241,0.12);
        }
        .term-page .btn-primary {
            height: 34px; padding: 0 18px; border: none; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff !important;
            box-shadow: 0 1px 3px rgba(99,102,241,0.3);
            white-space: nowrap;
        }
        .term-page .btn-primary:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px);
        }
        .term-page .btn-success {
            height: 34px; padding: 0 18px; border: none; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            background: linear-gradient(135deg, #059669, #34d399); color: #fff !important;
            box-shadow: 0 1px 3px rgba(5,150,105,0.3);
            white-space: nowrap;
        }
        .term-page .btn-success:hover {
            background: linear-gradient(135deg, #047857, #059669);
            box-shadow: 0 4px 12px rgba(5,150,105,0.35); transform: translateY(-1px);
        }
        .term-page .btn-back {
            height: 34px; padding: 0 16px; border-radius: 8px; font-size: 13px;
            font-weight: 500; cursor: pointer; transition: all 0.2s;
            border: 1px solid #e2e8f0; background: #f8fafc; color: #64748b;
            white-space: nowrap;
        }
        .term-page .btn-back:hover {
            background: #e2e8f0; color: #334155;
        }

        /* 权重设置区 */
        .weight-section {
            padding: 16px 20px; background: #fff;
            border-bottom: 1px solid #e8ecf1;
        }
        .weight-title {
            font-size: 13px; font-weight: 600; color: #334155;
            margin-bottom: 12px; display: flex; align-items: center; gap: 8px;
        }
        .weight-title svg {
            width: 16px; height: 16px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .weight-grid {
            display: flex; flex-wrap: wrap; gap: 12px; align-items: center;
        }
        .weight-item {
            display: flex; align-items: center; gap: 6px;
            padding: 6px 12px; background: #f8fafc; border-radius: 8px;
            border: 1px solid #e8ecf1;
        }
        .weight-item .w-label {
            font-size: 12px; color: #64748b; font-weight: 500; white-space: nowrap;
        }
        .weight-item select {
            height: 30px; padding: 0 8px; border: 1px solid #d1d5db;
            border-radius: 6px; background: #fff; font-size: 12px; color: #334155;
            outline: none; cursor: pointer; transition: all 0.2s; width: 60px;
        }
        .weight-item select:hover { border-color: #818cf8; }
        .weight-item select:focus {
            border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        }

        /* 提示信息 */
        .info-bar {
            padding: 12px 20px; background: #fffbeb;
            border-bottom: 1px solid #fde68a;
            font-size: 12px; color: #92400e;
            display: flex; align-items: center; gap: 8px;
        }
        .info-bar svg {
            width: 16px; height: 16px; stroke: #d97706; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
            flex-shrink: 0;
        }
        .msg-bar {
            padding: 10px 20px; font-size: 13px;
        }

        /* GridView 表格 */
        .table-wrap { padding: 0; overflow-x: auto; }
        .table-wrap table { width: 100%; border-collapse: collapse; }
        .table-wrap th {
            background: #f8fafc !important; color: #64748b !important;
            font-size: 11px !important; font-weight: 600 !important;
            text-transform: uppercase; letter-spacing: 0.3px;
            padding: 10px 8px !important; border-bottom: 2px solid #e8ecf1 !important;
            white-space: nowrap; vertical-align: middle !important;
            text-align: center !important;
        }
        .table-wrap td {
            padding: 9px 8px !important; font-size: 13px; color: #334155;
            border-bottom: 1px solid #f1f5f9 !important;
            vertical-align: middle !important; text-align: center;
            white-space: nowrap;
        }
        .table-wrap tr { background: #fff !important; transition: background 0.15s; }
        .table-wrap tbody tr:hover { background: #f8fafc !important; }
        .table-wrap tr:nth-child(even) { background: #fafbfc !important; }
        .table-wrap tr:nth-child(even):hover { background: #f1f5f9 !important; }

        /* 表格链接 */
        .table-wrap a {
            color: #6366f1; text-decoration: none; font-weight: 500; transition: color 0.15s;
        }
        .table-wrap a:hover { color: #4f46e5; text-decoration: underline; }

        /* 数值单元格 */
        .table-wrap td {
            font-variant-numeric: tabular-nums;
        }
    </style>

    <div class="term-page">
        <!-- 页面标题 -->
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                </span>
                学期总评
            </h2>
        </div>

        <!-- 主卡片 -->
        <div class="term-card">
            <!-- 筛选栏 -->
            <div class="filter-bar">
                <div class="filter-group">
                    <span class="filter-label">年级</span>
                    <asp:DropDownList ID="DDLgrade" runat="server" 
                        Width="70px" AutoPostBack="True"
                        onselectedindexchanged="DDLgrade_SelectedIndexChanged" />
                </div>
                <div class="filter-group">
                    <span class="filter-label">班级</span>
                    <asp:DropDownList ID="DDLclass" runat="server"
                        Width="70px" AutoPostBack="True" 
                        onselectedindexchanged="DDLclass_SelectedIndexChanged" />
                </div>
                <span class="term-badge">
                    第 <asp:Label ID="Lbterm" runat="server"></asp:Label> 学期
                </span>
                <span class="filter-spacer"></span>
                <asp:Button ID="Btnback" runat="server" Text="← 返回" OnClick="Btnback_Click" CssClass="btn-back" />
            </div>

            <!-- 操作按钮组 -->
            <div class="btn-group">
                <asp:Button ID="BtnScoresNo" runat="server" OnClick="BtnScoresNo_Click" 
                    Text="未评设置C" CssClass="btn-outline" ToolTip="所教班级未评作品全部设置为C，即分值6" />
                <asp:Button ID="BtnScores" runat="server" OnClick="BtnScore_Click" 
                    Text="总分折算" CssClass="btn-primary" ToolTip="先统计总分，再得出折算总分" />
                <asp:Button ID="Btnape" runat="server" onclick="Btnape_Click" Text="期末总评" 
                    CssClass="btn-success" />
                <asp:Button ID="BtnExcel" runat="server" OnClick="BtnExcel_Click" 
                    Text="导出 Excel" CssClass="btn-outline" ToolTip="将学生期末成绩以Excel表格导出" />
                <asp:Button ID="Btntermview" runat="server" Text="学期查询" OnClick="Btntermview_Click" 
                    CssClass="btn-outline" />
            </div>

            <!-- 权重设置 -->
            <div class="weight-section">
                <div class="weight-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                    总分折算比例设置
                </div>
                <div class="weight-grid">
                    <div class="weight-item">
                        <span class="w-label">作品+小组+讨论+表单+测评</span>
                        <asp:DropDownList ID="DDLwork" runat="server" Width="60px">
                            <asp:ListItem Selected="True">100</asp:ListItem>
                            <asp:ListItem>90</asp:ListItem>
                            <asp:ListItem>80</asp:ListItem>
                            <asp:ListItem>70</asp:ListItem>
                            <asp:ListItem>60</asp:ListItem>
                            <asp:ListItem>50</asp:ListItem>
                            <asp:ListItem>40</asp:ListItem>
                            <asp:ListItem>30</asp:ListItem>
                            <asp:ListItem>20</asp:ListItem>
                            <asp:ListItem>10</asp:ListItem>
                            <asp:ListItem>0</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="weight-item">
                        <span class="w-label">调查</span>
                        <asp:DropDownList ID="DDLsurvey" runat="server" Width="60px">
                            <asp:ListItem Selected="True">100</asp:ListItem>
                            <asp:ListItem>90</asp:ListItem>
                            <asp:ListItem>80</asp:ListItem>
                            <asp:ListItem>70</asp:ListItem>
                            <asp:ListItem>60</asp:ListItem>
                            <asp:ListItem>50</asp:ListItem>
                            <asp:ListItem>40</asp:ListItem>
                            <asp:ListItem>30</asp:ListItem>
                            <asp:ListItem>20</asp:ListItem>
                            <asp:ListItem>10</asp:ListItem>
                            <asp:ListItem>0</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="weight-item">
                        <span class="w-label">测验</span>
                        <asp:DropDownList ID="DDLquiz" runat="server" Width="60px">
                            <asp:ListItem>100</asp:ListItem>
                            <asp:ListItem>90</asp:ListItem>
                            <asp:ListItem>80</asp:ListItem>
                            <asp:ListItem>70</asp:ListItem>
                            <asp:ListItem>60</asp:ListItem>
                            <asp:ListItem>50</asp:ListItem>
                            <asp:ListItem>40</asp:ListItem>
                            <asp:ListItem>30</asp:ListItem>
                            <asp:ListItem Selected="True">20</asp:ListItem>
                            <asp:ListItem>10</asp:ListItem>
                            <asp:ListItem>0</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="weight-item">
                        <span class="w-label">中英文</span>
                        <asp:DropDownList ID="DDLtyper" runat="server" Width="60px">
                            <asp:ListItem>100</asp:ListItem>
                            <asp:ListItem>90</asp:ListItem>
                            <asp:ListItem>80</asp:ListItem>
                            <asp:ListItem>70</asp:ListItem>
                            <asp:ListItem>60</asp:ListItem>
                            <asp:ListItem>50</asp:ListItem>
                            <asp:ListItem>40</asp:ListItem>
                            <asp:ListItem>30</asp:ListItem>
                            <asp:ListItem>20</asp:ListItem>
                            <asp:ListItem Selected="True">10</asp:ListItem>
                            <asp:ListItem>0</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="weight-item">
                        <span class="w-label">表现</span>
                        <asp:DropDownList ID="DDLattitude" runat="server" Width="60px">
                            <asp:ListItem Selected="True">100</asp:ListItem>
                            <asp:ListItem>90</asp:ListItem>
                            <asp:ListItem>80</asp:ListItem>
                            <asp:ListItem>70</asp:ListItem>
                            <asp:ListItem>60</asp:ListItem>
                            <asp:ListItem>50</asp:ListItem>
                            <asp:ListItem>40</asp:ListItem>
                            <asp:ListItem>30</asp:ListItem>
                            <asp:ListItem>20</asp:ListItem>
                            <asp:ListItem>10</asp:ListItem>
                            <asp:ListItem>0</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <!-- 提示信息 -->
            <div class="info-bar">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                期末总评每个班级的分数比重：优秀 &gt; 80%、良好 &gt; 60%、及格 &gt; 30%、不及格 = 0%
            </div>

            <!-- 消息提示 -->
            <div class="msg-bar">
                <asp:Label ID="Labelmsg" runat="server" ForeColor="Red"></asp:Label>
            </div>

            <!-- 数据表格 -->
            <div class="table-wrap">
                <asp:GridView ID="GVCourse" runat="server" AutoGenerateColumns="False"
                    DataKeyNames="Sid" OnRowDataBound="GVCourse_RowDataBound"
                    PageSize="25" Width="100%" EnableModelValidation="True"
                    CellPadding="0" ForeColor="#334155" GridLines="None">
                    <Columns>
                        <asp:BoundField HeaderText="编号" />
                        <asp:BoundField DataField="Snum" HeaderText="学号" />
                        <asp:BoundField DataField="Sgradeclass" HeaderText="班级" />
                        <asp:HyperLinkField DataNavigateUrlFields="Snum" 
                            DataNavigateUrlFormatString="studentwork.aspx?snum={0}" DataTextField="Sname" 
                            HeaderText="姓名" Target="_blank" />
                        <asp:BoundField DataField="Sscore" HeaderText="作品" />
                        <asp:BoundField DataField="Sgscore" HeaderText="小组" />
                        <asp:BoundField DataField="Spscore" HeaderText="讨论" />
                        <asp:BoundField DataField="Stxtform" HeaderText="表单" />
                        <asp:BoundField DataField="Svscore" HeaderText="调查" />
                        <asp:BoundField DataField="Squiz" HeaderText="测验" />
                        <asp:BoundField DataField="Schinese" HeaderText="拼音" />
                        <asp:BoundField DataField="Sfscore" HeaderText="英语" />
                        <asp:BoundField DataField="Stscore" HeaderText="中文" />
                        <asp:BoundField DataField="Sidle" HeaderText="测评" />
                        <asp:BoundField DataField="Sattitude" HeaderText="表现" />
                        <asp:BoundField DataField="Sallscore" HeaderText="总分" />
                        <asp:BoundField DataField="Sape" HeaderText="评定" />
                        <asp:BoundField DataField="Stenscore" HeaderText="评定" />
                    </Columns>
                    <HeaderStyle BackColor="#f8fafc" Font-Bold="True" ForeColor="#64748b" />
                    <RowStyle BackColor="#ffffff" />
                    <AlternatingRowStyle BackColor="#fafbfc" />
                    <SelectedRowStyle BackColor="#eef2ff" Font-Bold="True" ForeColor="#4f46e5" />
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

