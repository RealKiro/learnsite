<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_works, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <link href="../js/tinybox.css?v=20260212" rel="stylesheet" type="text/css" />
    <script src="../js/tinybox.js?v=20260212" type="text/javascript"></script>
    <style>
        /* ===== 作品管理页面美化 ===== */
        .works-page { max-width: 1400px; margin: 0 auto; }

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
        .works-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            border: 1px solid #e8ecf1; overflow: hidden;
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
        .filter-msg { font-size: 12px; color: #94a3b8; }
        .filter-spacer { flex: 1; }

        /* 操作按钮 */
        .works-page .btn-action {
            height: 34px; padding: 0 16px; border: 1px solid #d1d5db; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            white-space: nowrap; display: inline-flex; align-items: center; gap: 6px;
            background: #fff; color: #475569;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
        }
        .works-page .btn-action:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
            box-shadow: 0 2px 8px rgba(99,102,241,0.12);
        }
        .works-page .btn-primary {
            height: 34px; padding: 0 18px; border: none; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            white-space: nowrap; display: inline-flex; align-items: center; gap: 6px;
            background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff !important;
            box-shadow: 0 1px 3px rgba(99,102,241,0.3);
        }
        .works-page .btn-primary:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            box-shadow: 0 4px 12px rgba(99,102,241,0.35); transform: translateY(-1px);
        }

        /* GridView 表格 */
        .table-wrap { padding: 0; }
        .table-wrap table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .table-wrap th {
            background: #f8fafc !important; color: #64748b !important;
            font-size: 12px !important; font-weight: 600 !important;
            text-transform: uppercase; letter-spacing: 0.3px;
            padding: 12px 16px !important; border-bottom: 2px solid #e8ecf1 !important;
            white-space: nowrap; vertical-align: middle !important;
            text-align: center !important;
        }
        .table-wrap td {
            padding: 12px 16px !important; font-size: 13px; color: #334155;
            border-bottom: 1px solid #f1f5f9 !important;
            vertical-align: middle !important; text-align: center;
            white-space: nowrap;
        }
        .table-wrap td:nth-child(2) { text-align: left; overflow: hidden; text-overflow: ellipsis; }
        .table-wrap th:nth-child(2) { text-align: left !important; }
        /* 列宽分配（学案列弹性填充，其余固定） */
        .table-wrap th:nth-child(1) { width: 58px !important; }
        .table-wrap th:nth-child(3) { width: 90px !important; }
        .table-wrap th:nth-child(4) { width: 76px !important; }
        /* 列 5/6 （已交/未交）由 .wstat-th-s/ns 控制宽度 */
        /* 列 7/8 （评价/日期）在 JS 注入后通过 inline style 设定 */
        .table-wrap tr { background: #fff !important; transition: background 0.15s; }
        .table-wrap tbody tr:hover { background: #f8fafc !important; }
        .table-wrap tr:nth-child(even) { background: #fafbfc !important; }
        .table-wrap tr:nth-child(even):hover { background: #f1f5f9 !important; }

        /* 表格链接 */
        .table-wrap a {
            color: #6366f1; text-decoration: none; font-weight: 500; transition: color 0.15s;
        }
        .table-wrap a:hover { color: #4f46e5; text-decoration: underline; }

        /* 已交/未交 注入列 */
        .wstat-th-s  { background: #f0fdf4 !important; color: #059669 !important; width: 68px; }
        .wstat-th-ns { background: #fef2f2 !important; color: #dc2626 !important; width: 68px; }
        .wstat-td    { font-size: 13px; text-align: center !important; }
        .wstat-s     { color: #059669; font-weight: 700; }
        .wstat-ns    { color: #dc2626; font-weight: 700; }
        .wstat-ns-zero { color: #94a3b8; font-weight: 600; }
        .wstat-total { color: #94a3b8; font-size: 11px; }
        /* 大屏展示主按钮 */
        .works-page .btn-bigscreen {
            height: 34px; padding: 0 16px; border: 1.5px solid #a78bfa; border-radius: 8px;
            font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;
            white-space: nowrap; display: inline-flex; align-items: center; gap: 6px;
            background: linear-gradient(135deg, #f5f3ff, #ede9fe); color: #5b21b6;
            box-shadow: 0 1px 3px rgba(109,40,217,0.12);
        }
        .works-page .btn-bigscreen:hover {
            background: linear-gradient(135deg, #ede9fe, #ddd6fe);
            border-color: #7c3aed; color: #4c1d95;
            box-shadow: 0 4px 12px rgba(109,40,217,0.2); transform: translateY(-1px);
        }
        .works-page .btn-bigscreen svg { width: 15px; height: 15px; stroke: currentColor;
            fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }


        /* 分页器 */
        .pager-bar {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 6px; padding: 14px 20px; background: #f8fafc;
            border-top: 1px solid #e8ecf1; font-size: 13px; color: #64748b;
        }
        .pager-bar a {
            padding: 5px 12px; border-radius: 6px; font-size: 12px;
            color: #475569 !important; text-decoration: none !important; border: 1px solid #d1d5db;
            background: #fff; cursor: pointer; transition: all 0.15s;
            font-weight: 500; display: inline-block; line-height: 1.5;
        }
        .pager-bar a:hover {
            background: #f5f3ff; border-color: #818cf8; color: #6366f1 !important;
        }
        .pager-info {
            font-size: 12px; color: #94a3b8; margin-right: 8px;
        }
    </style>

    <div class="works-page">
        <!-- 页面标题 -->
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                </span>
                作品管理
            </h2>
        </div>

        <!-- 主卡片 -->
        <div class="works-card">
            <!-- 筛选栏 -->
            <div class="filter-bar">
                <div class="filter-group">
                    <span class="filter-label">年级</span>
                    <asp:DropDownList ID="DDLgrade" runat="server" 
                        EnableTheming="True" AutoPostBack="True" 
                        onselectedindexchanged="DDLgrade_SelectedIndexChanged" Width="80px" />
                </div>
                <span class="filter-msg">
                    <asp:Label ID="Labelmsg" runat="server"></asp:Label>
                </span>
                <span class="filter-spacer"></span>
                <button type="button" class="btn-bigscreen" id="btnBigScreen" onclick="openBigScreen()">
                    <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    大屏展示
                </button>
                <button type="button" class="btn-action" onclick="package()">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    作品打包
                </button>
                <asp:Button ID="Btnterm" runat="server" Text="学期总评" CssClass="btn-primary"
                    onclick="Btnterm_Click" ToolTip="跳转到学期总评页面" />
            </div>

            <!-- 数据表格 -->
            <div class="table-wrap">
                <asp:GridView ID="GVCourse" runat="server" AllowPaging="True" 
                    AutoGenerateColumns="False" DataKeyNames="Cid" CellPadding="0"
                    PageSize="20" Width="100%" 
                    onpageindexchanging="GVCourse_PageIndexChanging" 
                    onrowdatabound="GVCourse_RowDataBound" EnableModelValidation="True"
                    ForeColor="#334155" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="Cid" HeaderText="序号" InsertVisible="False" 
                            ReadOnly="True" SortExpression="Cid" >
                            <ItemStyle Width="60px" />
                        </asp:BoundField>
                        <asp:HyperLinkField 
                            DataTextField="Ctitle" HeaderText="学案" >
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:HyperLinkField>
                        <asp:BoundField DataField="Cclass" HeaderText="类型" SortExpression="Cclass" >
                            <ItemStyle Width="80px" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="未评数">
                            <ItemTemplate>
                                <asp:HyperLink ID="HlNoCheck" runat="server" ></asp:HyperLink>
                            </ItemTemplate>
                            <ItemStyle Font-Bold="True" Width="80px" />
                        </asp:TemplateField>
                        <asp:HyperLinkField DataNavigateUrlFields="Cid,Cobj" 
                            DataNavigateUrlFormatString="workcheck.aspx?cid={0}&amp;grade={1}" 
                            Text="查看" HeaderText="评价" Target="_blank">
                            <ItemStyle Width="80px" />
                        </asp:HyperLinkField>
                        <asp:BoundField DataField="Cdate" HeaderText="日期" SortExpression="Cdate" >
                            <ItemStyle Width="140px" />
                        </asp:BoundField>
                    </Columns>
                    <HeaderStyle BackColor="#f8fafc" Font-Bold="True" ForeColor="#64748b" />
                    <RowStyle BackColor="#ffffff" />
                    <AlternatingRowStyle BackColor="#fafbfc" />
                    <SelectedRowStyle BackColor="#eef2ff" Font-Bold="True" ForeColor="#4f46e5" />
                    <PagerStyle BackColor="#f8fafc" ForeColor="#475569" HorizontalAlign="Right" />
                    <pagertemplate>
                        <div class="pager-bar">
                            <span class="pager-info">
                                第 <asp:Label ID="lblPageIndex" runat="server" 
                                    text="<%# ((GridView)Container.Parent.Parent).PageIndex + 1  %>" /> 页
                                / 共 <asp:Label ID="lblPageCount" runat="server" 
                                    text="<%# ((GridView)Container.Parent.Parent).PageCount  %>" /> 页
                            </span>
                            <asp:LinkButton ID="btnFirst" runat="server" causesvalidation="False" 
                                commandargument="First" commandname="Page" Font-Underline="False" 
                                text="首页" />
                            <asp:LinkButton ID="btnPrev" runat="server" causesvalidation="False" 
                                commandargument="Prev" commandname="Page" Font-Underline="False" 
                                text="上一页" />
                            <asp:LinkButton ID="btnNext" runat="server" causesvalidation="False" 
                                commandargument="Next" commandname="Page" Font-Underline="False" 
                                text="下一页" />
                            <asp:LinkButton ID="btnLast" runat="server" causesvalidation="False" 
                                commandargument="Last" commandname="Page" Font-Underline="False" 
                                text="尾页" />
                        </div>
                    </pagertemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function package() {
            var urlpg = "../teacher/workpackage.aspx";
            TINY.box.show({ iframe: urlpg, boxid: 'frameless', width: 480, height: 360, fixed: true, mask: 1, maskopacity: 40, closejs: function () { closeJS() } });
        }

        // ── 大屏展示（按年级，不指定课程） ─────────────────────────
        function openBigScreen() {
            var sel = document.querySelector('select[name*="DDLgrade"],select[id*="DDLgrade"]');
            var grade = sel ? sel.value : '';
            var url = '../teacher/worksbigscreen.aspx' + (grade ? '?grade=' + encodeURIComponent(grade) : '');
            window.open(url, '_blank', 'width=1400,height=900,resizable=yes,scrollbars=yes');
        }

        // ── 注入 已交 / 未交 列 ──────────────────────────────────
        (function () {
            function run() {
                var table = document.querySelector('.table-wrap table');
                if (!table) return;

                var rows = table.rows;
                var headerRow = null;
                var dataRows = [];

                for (var i = 0; i < rows.length; i++) {
                    var r = rows[i];
                    // 有 th 的行 = 表头
                    if (r.cells.length > 0 && r.cells[0].tagName === 'TH') {
                        headerRow = r;
                    // 6 个 td 的行 = 数据行
                    } else if (r.cells.length === 6 && r.cells[0].tagName === 'TD') {
                        dataRows.push(r);
                    }
                }
                if (!headerRow || dataRows.length === 0) return;

                // ── 插入表头两列（已交 / 未交）─ 在 评价(index 4) 前 ──
                var refTh = headerRow.cells[4]; // 评价

                function mkTh(text, cls) {
                    var th = document.createElement('th');
                    th.textContent = text;
                    th.className = cls;
                    return th;
                }
                headerRow.insertBefore(mkTh('未交', 'wstat-th-ns'), refTh);
                headerRow.insertBefore(mkTh('已交', 'wstat-th-s'),  headerRow.cells[4]);
                // 评价、日期列经注入后分别移至第 7/8 列，在这里固定宽度
                if (headerRow.cells.length >= 8) {
                    headerRow.cells[6].style.width = '78px';   // 评价
                    headerRow.cells[7].style.width = '150px';  // 日期
                }

                // ── 各数据行
                var cidMap   = {}; // rowIdx -> cid
                var gradeMap = {}; // rowIdx -> grade
                var allCids  = [];

                for (var j = 0; j < dataRows.length; j++) {
                    var tr   = dataRows[j];
                    // 评价列 = 原 index 4，现在还未插入 td，所以仍是 4
                    var evalCell = tr.cells[4];
                    var link = evalCell ? evalCell.querySelector('a') : null;
                    var cid = 0, grade = 0;
                    if (link) {
                        var href = link.getAttribute('href') || '';
                        var mc = href.match(/[?&]cid=(\d+)/i);
                        var mg = href.match(/[?&]grade=(\d+)/i);
                        if (mc) cid   = parseInt(mc[1]);
                        if (mg) grade = parseInt(mg[1]);
                    }

                    var refTd = tr.cells[4]; // 评价 td（原位）

                    // 未交 td（先插，占住位置）
                    var tdNs = document.createElement('td');
                    tdNs.className = 'wstat-td';
                    tdNs.id = 'wns-' + j;
                    tdNs.innerHTML = '<span style="opacity:.4;font-size:11px;">…</span>';

                    // 已交 td
                    var tdS = document.createElement('td');
                    tdS.className = 'wstat-td';
                    tdS.id = 'ws-' + j;
                    tdS.innerHTML = '<span style="opacity:.4;font-size:11px;">…</span>';

                    tr.insertBefore(tdNs, refTd);         // [..., 未交, 评价]
                    tr.insertBefore(tdS,  tr.cells[4]);   // [..., 已交, 未交, 评价]

                    if (cid > 0) {
                        cidMap[j] = cid;
                        gradeMap[j] = grade;
                        if (allCids.indexOf(cid) < 0) allCids.push(cid);
                    } else {
                        document.getElementById('ws-'  + j).textContent = '-';
                        document.getElementById('wns-' + j).textContent = '-';
                    }
                }

                if (allCids.length === 0) return;

                // ── AJAX 请求 worksstat.ashx ────────────────────────────
                var xhr = new XMLHttpRequest();
                xhr.open('GET', '../teacher/worksstat.ashx?cids=' + allCids.join(','), true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState !== 4) return;
                    try {
                        var t = xhr.responseText || '';
                        if (t.charCodeAt(0) === 0xFEFF) t = t.slice(1);
                        var data = JSON.parse(t);
                        if (!data.ok) return;
                        for (var idx = 0; idx < dataRows.length; idx++) {
                            var cid = cidMap[idx];
                            var els  = document.getElementById('ws-' + idx);
                            var elns = document.getElementById('wns-' + idx);
                            if (!els || !elns) continue;
                            if (!cid || !data.data[String(cid)]) {
                                els.textContent = '-'; elns.textContent = '-'; continue;
                            }
                            var d = data.data[String(cid)];
                            // 已交
                            els.innerHTML = '<span class="wstat-s">' + d.s + '</span>'
                                + (d.t > 0 ? '<span class="wstat-total">/' + d.t + '</span>' : '');
                            // 未交
                            if (d.ns > 0) {
                                elns.innerHTML = '<span class="wstat-ns">' + d.ns + '</span>';
                            } else {
                                elns.innerHTML = '<span class="wstat-ns-zero">0</span>';
                            }
                        }
                    } catch (e) {}
                };
                xhr.send();
            }

            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', run);
            } else {
                run();
            }
        })();
    </script>

</asp:Content>

