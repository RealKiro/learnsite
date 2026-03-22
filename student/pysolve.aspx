<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_pysolve, LearnSite" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected string schoolMapJson = "{}";

    private string GetConnStr()
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
        return cs;
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        BuildSchoolMap();
    }

    private void BuildSchoolMap()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 检查 School 表和 SchoolId 字段是否存在
                string chk = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='School'";
                using (SqlCommand c1 = new SqlCommand(chk, conn))
                { if ((int)c1.ExecuteScalar() == 0) return; }
                string chk2 = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Students' AND COLUMN_NAME='SchoolId'";
                using (SqlCommand c2 = new SqlCommand(chk2, conn))
                { if ((int)c2.ExecuteScalar() == 0) return; }

                string sql = @"SELECT CAST(st.Sgrade AS NVARCHAR) AS G, CAST(st.Sclass AS NVARCHAR) AS C,
                    st.Sname AS N, ISNULL(s.SchoolName,'') AS S
                    FROM Students st LEFT JOIN School s ON st.SchoolId=s.SchoolId";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    System.Text.StringBuilder sb = new System.Text.StringBuilder("{");
                    bool first = true;
                    while (reader.Read())
                    {
                        string key = reader["G"].ToString().Trim() + "|" + reader["C"].ToString().Trim() + "|" + reader["N"].ToString().Trim();
                        string val = reader["S"].ToString();
                        if (!first) sb.Append(",");
                        sb.Append("\"");
                        sb.Append(key.Replace("\\", "\\\\").Replace("\"", "\\\""));
                        sb.Append("\":\"");
                        sb.Append(val.Replace("\\", "\\\\").Replace("\"", "\\\""));
                        sb.Append("\"");
                        first = false;
                    }
                    sb.Append("}");
                    schoolMapJson = sb.ToString();
                }
            }
        }
        catch { schoolMapJson = "{}"; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    /* === 覆盖Student主题冲突 === */
    .ps-page, .ps-page * { margin-right: unset !important; margin-left: unset !important; }
    .ps-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .ps-page table[cellpadding] { border: none !important; }

    /* === 页面布局 === */
    .ps-page {
        width: 100%; max-width: 1200px; margin: 0 auto !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: psFadeIn .4s ease;
    }
    @keyframes psFadeIn { 
        from { opacity: 0; transform: translateY(8px); } 
        to { opacity: 1; transform: translateY(0); } 
    }

    /* === 页面标题 === */
    .ps-header {
        margin-bottom: 24px;
        text-align: center;
    }
    .ps-title {
        font-size: 24px !important; font-weight: 700 !important; 
        color: #1e293b !important; margin: 0 auto 8px auto !important;
        display: inline-flex !important; align-items: center; gap: 12px;
        padding-bottom: 16px; border-bottom: 2px solid #e8ecf1;
        justify-content: center;
    }
    .ps-title::before {
        content: ''; width: 4px; height: 24px;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        border-radius: 2px; flex-shrink: 0;
    }

    /* === 主卡片容器 === */
    .ps-card {
        background: #fff !important; border-radius: 16px; 
        border: 1px solid #e5e7eb !important;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02);
        overflow: hidden; margin-bottom: 24px;
        transition: transform .2s ease, box-shadow .2s ease;
        padding: 0 !important;
    }
    .ps-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04);
    }

    /* === GridView 容器 === */
    .ps-card-inner {
        padding: 0;
        overflow-x: auto;
    }

    /* === GridView 美化 === */
    .ps-card table,
    .ps-card .ps-card-inner table {
        width: 100% !important; min-width: 600px;
        border-collapse: collapse !important;
        border-spacing: 0 !important; border: none !important;
        margin: 0 !important;
    }
    .ps-page .ps-card table th,
    .ps-card table th {
        padding: 14px 24px !important; font-size: 14px !important; 
        font-weight: 600 !important; color: #475569 !important; 
        text-align: center !important; letter-spacing: .3px;
        background: linear-gradient(180deg, #f8fafc, #f1f5f9) !important; 
        border-bottom: 2px solid #e8ecf1 !important;
        border-top: none !important; border-left: none !important; 
        border-right: none !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        white-space: nowrap;
    }
    /* 校区徽章样式 */
    .ps-card table td:nth-child(1) {
        text-align: center !important;
    }
    .ps-card table td:nth-child(1) span {
        display: inline-block;
        padding: 6px 16px;
        border-radius: 16px;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        color: #fff;
        font-weight: 600;
        font-size: 13px;
        min-width: 40px;
    }
    /* 年级和班级徽章样式 */
    .ps-card table td:nth-child(2),
    .ps-card table td:nth-child(3) {
        text-align: center !important;
    }
    .ps-card table td:nth-child(2) span,
    .ps-card table td:nth-child(3) span {
        display: inline-block;
        padding: 6px 16px;
        border-radius: 16px;
        background: linear-gradient(135deg, #fb923c, #f97316);
        color: #fff;
        font-weight: 600;
        font-size: 13px;
        min-width: 40px;
    }
    /* 姓名列样式 */
    .ps-card table td:nth-child(4) {
        text-align: center !important;
        font-weight: 500;
        color: #1e293b !important;
    }
    .ps-page .ps-card table td,
    .ps-card table td {
        padding: 16px 24px !important; font-size: 14px !important; 
        color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important;
        border-top: none !important; border-left: none !important; 
        border-right: none !important; background-color: #fff !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        vertical-align: middle !important;
        text-align: center !important;
    }
    .ps-page .ps-card table td:first-child {
        padding-left: 24px !important;
    }
    .ps-page .ps-card table td:last-child {
        padding-right: 24px !important;
    }
    .ps-page .ps-card table tr,
    .ps-card table tr {
        transition: all .15s ease;
        background-color: #fff !important; background: #fff !important;
        font-size: 13px !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
    }
    .ps-page .ps-card table tr:hover td,
    .ps-card table tr:hover td {
        background-color: #f8faff !important;
    }
    .ps-card table tr:last-child td { border-bottom: none !important; }

    /* 得分标签美化 */
    .ps-score {
        display: inline-block; padding: 4px 12px; border-radius: 12px;
        font-size: 13px; font-weight: 700; min-width: 50px;
        text-align: center;
    }
    .ps-score-full {
        background: linear-gradient(135deg, #10b981, #059669);
        color: #fff;
    }
    .ps-score-partial {
        background: linear-gradient(135deg, #f59e0b, #d97706);
        color: #fff;
    }
    .ps-score-zero {
        background: #f1f5f9;
        color: #64748b;
    }

    /* 状态图标美化 */
    .ps-status {
        display: inline-flex; align-items: center; justify-content: center;
        width: 24px; height: 24px; border-radius: 50%;
    }
    .ps-status-pass {
        background: linear-gradient(135deg, #10b981, #059669);
        color: #fff;
    }
    .ps-status-pass::after {
        content: '✓'; font-size: 14px; font-weight: bold;
    }
    .ps-status-fail {
        background: #f1f5f9;
        color: #64748b;
    }
    .ps-status-fail::after {
        content: '○'; font-size: 14px;
    }

    /* 链接样式 */
    .ps-card table a {
        color: #4f46e5 !important; text-decoration: none !important; 
        font-weight: 500; transition: color .12s; font-size: 13px !important;
    }
    .ps-card table a:hover { 
        color: #818cf8 !important; text-decoration: underline !important; 
    }

    /* === 空状态 === */
    .ps-empty {
        padding: 60px 20px !important; text-align: center !important; 
        color: #94a3b8 !important; background: #fff !important;
    }
    .ps-empty-icon {
        font-size: 48px; margin-bottom: 16px; opacity: 0.5;
    }
    .ps-empty-text {
        font-size: 14px; color: #64748b;
    }

    /* GridView 空数据行 */
    .ps-card table tr td[colspan] {
        padding: 60px 20px !important; text-align: center !important;
        color: #94a3b8 !important; font-size: 14px !important;
    }

    /* === 响应式 === */
    @media (max-width: 768px) {
        .ps-page { padding: 0 12px; }
        .ps-title { font-size: 20px !important; }
        .ps-card table,
        .ps-card .ps-card-inner table {
            min-width: 100%;
        }
        .ps-card table th, .ps-card table td {
            padding: 12px 16px !important; font-size: 13px !important;
        }
        .ps-card table td:nth-child(1) span,
        .ps-card table td:nth-child(2) span,
        .ps-card table td:nth-child(3) span {
            padding: 4px 12px;
            font-size: 12px;
        }
    }
</style>

<div class="ps-page">
    <!-- 页面标题 -->
    <div class="ps-header">
        <h1 class="ps-title">
            <asp:Label ID="Labeltitle" runat="server"></asp:Label>
        </h1>
    </div>

    <!-- 主内容卡片 -->
    <div class="ps-card">
        <div class="ps-card-inner">
            <asp:GridView ID="GVsolve" runat="server" Font-Size="11pt" 
                HorizontalAlign="Center" CssClass="ps-gridview"
                AutoGenerateColumns="True" 
                EmptyDataText="暂无数据"
                EmptyDataRowStyle-CssClass="ps-empty"
                GridLines="None"
                CellPadding="0"
                CellSpacing="0">
            </asp:GridView>
        </div>
    </div>
</div>

<script type="text/javascript">
    // 校区数据映射（服务端生成）
    var __schoolMap = <%= schoolMapJson %>;

    // 美化表格显示 + 插入校区列
    (function() {
        var gridView = document.getElementById('<%= GVsolve.ClientID %>');
        if (!gridView) return;
        
        // 获取表头，确定列索引
        var headerRow = gridView.querySelector('thead tr') || gridView.querySelector('tr:first-child');
        if (!headerRow) return;
        
        var headers = headerRow.querySelectorAll('th, td');
        var gradeIndex = -1, classIndex = -1, nameIndex = -1;
        
        headers.forEach(function(header, index) {
            var text = header.textContent.trim();
            if (text.indexOf('年级') >= 0 || text === '年级') gradeIndex = index;
            if (text.indexOf('班级') >= 0 || text === '班级') classIndex = index;
            if (text.indexOf('姓名') >= 0 || text === '姓名') nameIndex = index;
        });
        
        // 如果没找到表头，根据列数推断
        if (gradeIndex === -1 && headers.length >= 3) {
            gradeIndex = 0;
            classIndex = 1;
            nameIndex = 2;
        }
        
        // === 插入校区列（在年级前面） ===
        var insertAt = gradeIndex >= 0 ? gradeIndex : 0;
        
        // 插入表头
        var th = document.createElement(headerRow.querySelector('th') ? 'th' : 'td');
        th.textContent = '校区';
        if (headerRow.cells.length > insertAt) {
            headerRow.insertBefore(th, headerRow.cells[insertAt]);
        } else {
            headerRow.appendChild(th);
        }
        
        // 插入后更新索引
        if (gradeIndex >= 0) gradeIndex += 1;
        if (classIndex >= 0) classIndex += 1;
        if (nameIndex >= 0) nameIndex += 1;
        var campusIndex = insertAt;
        
        // 为每个数据行插入校区单元格
        var rows = gridView.querySelectorAll('tbody tr, tr:not(:first-child)');
        rows.forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells.length === 0) return;
            
            // 跳过合并单元格行（空数据行）
            if (cells.length === 1 && cells[0].getAttribute('colspan')) return;
            
            // 查找学生的校区
            var grade = (gradeIndex >= 0 && cells[gradeIndex - 1]) ? cells[gradeIndex - 1].textContent.trim() : '';
            var cls = (classIndex >= 0 && cells[classIndex - 1]) ? cells[classIndex - 1].textContent.trim() : '';
            var name = (nameIndex >= 0 && cells[nameIndex - 1]) ? cells[nameIndex - 1].textContent.trim() : '';
            var key = grade + '|' + cls + '|' + name;
            var campus = __schoolMap[key] || '';
            
            var td = document.createElement('td');
            td.innerHTML = campus ? '<span>' + campus + '</span>' : '';
            if (cells.length > insertAt) {
                row.insertBefore(td, cells[insertAt]);
            } else {
                row.appendChild(td);
            }
        });
        
        // === 美化数据行 ===
        rows = gridView.querySelectorAll('tbody tr, tr:not(:first-child)');
        rows.forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells.length <= 1) return;
            
            // 美化年级列
            if (gradeIndex >= 0 && cells[gradeIndex]) {
                var gradeText = cells[gradeIndex].textContent.trim();
                if (gradeText && !cells[gradeIndex].querySelector('span')) {
                    cells[gradeIndex].innerHTML = '<span>' + gradeText + '</span>';
                }
            }
            
            // 美化班级列
            if (classIndex >= 0 && cells[classIndex]) {
                var classText = cells[classIndex].textContent.trim();
                if (classText && !cells[classIndex].querySelector('span')) {
                    cells[classIndex].innerHTML = '<span>' + classText + '</span>';
                }
            }
        });
        
        // 查找所有得分单元格并美化
        var allCells = gridView.querySelectorAll('td');
        allCells.forEach(function(cell) {
            var ci = Array.prototype.indexOf.call(cell.parentElement.children, cell);
            // 跳过校区/年级/班级/姓名列
            if (ci === campusIndex || ci === gradeIndex || ci === classIndex || ci === nameIndex) return;
            var text = cell.textContent.trim();
            if (/^\d+$/.test(text) || /^\d+\/\d+$/.test(text)) {
                if (!cell.querySelector('span')) {
                    var score = parseInt(text.split('/')[0] || text);
                    var total = parseInt(text.split('/')[1] || 100);
                    var percentage = total > 0 ? (score / total) : 0;
                    
                    cell.innerHTML = '<span class="ps-score ' + 
                        (percentage >= 1 ? 'ps-score-full' : 
                         percentage > 0 ? 'ps-score-partial' : 'ps-score-zero') + 
                        '">' + text + '</span>';
                }
            }
        });
        
        // 查找状态图标并美化
        var images = gridView.querySelectorAll('img');
        images.forEach(function(img) {
            var src = img.src.toLowerCase();
            var parent = img.parentElement;
            if (parent.tagName === 'TD') {
                if (src.indexOf('pass') >= 0 || src.indexOf('success') >= 0 || src.indexOf('check') >= 0) {
                    parent.innerHTML = '<span class="ps-status ps-status-pass"></span>';
                } else if (src.indexOf('fail') >= 0 || src.indexOf('error') >= 0 || src.indexOf('close') >= 0) {
                    parent.innerHTML = '<span class="ps-status ps-status-fail"></span>';
                }
            }
        });
    })();
</script>
</asp:Content>
