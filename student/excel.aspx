<%@ page language="C#" autoeventwireup="true" validaterequest="false" enableviewstatemac="false" inherits="student_excel, LearnSite" %>

<script runat="server">
    // ── 连接字符串辅助方法（inline，不依赖基类） ───────────────────
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly
                              .GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public |
                    System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager
                           .ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        return cs;
    }

    // ── 数据加载：按需初始化，弹性覆盖DLL基类属性 ────────────────
    private bool   _dataReady;
    private string _myTitles, _myFpage, _myOwner, _mySvrIp,
                   _myCodefile, _myExurl, _myId;

    private void EnsurePageDataLoaded()
    {
        if (_dataReady) return;
        _dataReady = true;
        _myTitles = ""; _myFpage = ""; _myOwner = "";
        _mySvrIp  = ""; _myCodefile = ""; _myExurl = ""; _myId = "";
        try
        {
            string lidStr = Request.QueryString["lid"] ?? "";
            int lid;
            if (!int.TryParse(lidStr, out lid) || lid <= 0) return;

            string snum = GetStudentSnum();
            _myOwner = snum;

            string cs = GetConnStr();
            if (string.IsNullOrEmpty(cs)) return;

            int lxid = 0, lcid = 0;
            using (System.Data.SqlClient.SqlConnection conn =
                   new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();

                // 任务标题 / 示例URL (Mexample 是示例文件路径; Mupload 是 bit 字段表示是否允许上传)
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                    SELECT L.Ltitle, L.Lxid, L.Lcid, M.Mtitle, M.Mexample
                    FROM   Listmenu L
                    LEFT JOIN Mission M ON M.Mid = L.Lxid
                    WHERE  L.Lid = @Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string lt = r["Ltitle"] != DBNull.Value ? r["Ltitle"].ToString().Trim() : "";
                            string mt = r["Mtitle"] != DBNull.Value ? r["Mtitle"].ToString().Trim() : "";
                            _myTitles = !string.IsNullOrEmpty(lt) ? lt : mt;
                            lxid = r["Lxid"] != DBNull.Value ? Convert.ToInt32(r["Lxid"]) : 0;
                            lcid = r["Lcid"] != DBNull.Value ? Convert.ToInt32(r["Lcid"]) : 0;
                            _myExurl = r["Mexample"] != DBNull.Value ? r["Mexample"].ToString().Trim() : "";
                        }
                    }
                }

                string midP  = Request.QueryString["mid"]  ?? lxid.ToString();
                string mcidP = Request.QueryString["mcid"];
                if (string.IsNullOrEmpty(mcidP))
                    mcidP = lcid > 0 ? lcid.ToString() : "0";

                _myFpage = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, midP, mcidP);
                _myId    = string.Format("{0}-{1}-{2}", mcidP, midP, lid);

                try
                {
                    _mySvrIp = System.Configuration.ConfigurationManager
                                   .AppSettings["LuckysheetServer"] ?? "";
                }
                catch { _mySvrIp = ""; }

                // 加载学生已保存的表格 JSON
                if (!string.IsNullOrEmpty(snum))
                {
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                        SELECT TOP 1 Wcode, Wdict FROM Works
                        WHERE  Wlid = @Lid AND Wnum = @Snum
                        ORDER  BY Wid DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@Lid",  lid);
                        cmd.Parameters.AddWithValue("@Snum", snum);
                        using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string wc = "", wd = "";
                                try { if (r["Wcode"] != DBNull.Value) wc = r["Wcode"].ToString(); } catch { }
                                try { if (r["Wdict"] != DBNull.Value) wd = r["Wdict"].ToString(); } catch { }
                                string saved = !string.IsNullOrEmpty(wc) ? wc : wd;
                                if (!string.IsNullOrEmpty(saved))
                                {
                                    string t2 = saved.TrimStart();
                                    if (t2.StartsWith("{") || t2.StartsWith("["))
                                        _myCodefile = Uri.EscapeDataString(saved);
                                }
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }

    private string GetStudentSnum()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string val = sc.Value;
                if (val.Contains("%"))
                { try { val = HttpUtility.UrlDecode(val, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly
                              .GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public |
                        System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { val });
                    System.Reflection.PropertyInfo pn = ct.GetProperty("Snum");
                    if (pn != null) { object v = pn.GetValue(m, null); if (v != null) return v.ToString(); }
                }
            }
        }
        catch { }
        return "";
    }

    // ── 覆盖DLL基类属性（new = 有意隐藏基类空属性，不改变API） ────────
    new protected string Titles     { get { EnsurePageDataLoaded(); return _myTitles   ?? ""; } }
    new protected string Fpage      { get { EnsurePageDataLoaded(); return _myFpage    ?? ""; } }
    new protected string Owner      { get { EnsurePageDataLoaded(); return _myOwner    ?? ""; } }
    new protected string serverIp   { get { EnsurePageDataLoaded(); return _mySvrIp   ?? ""; } }
    new protected string codefile   { get { EnsurePageDataLoaded(); return _myCodefile ?? ""; } }
    new protected string Exampleurl { get { EnsurePageDataLoaded(); return _myExurl   ?? ""; } }
    new protected string Id         { get { EnsurePageDataLoaded(); return _myId      ?? ""; } }

    // ── Helper: normalise Ltype string/number to numeric string ────────────
    private static string NormalizeLtypeInline(string ltype)
    {
        if (string.IsNullOrEmpty(ltype)) return "0";
        ltype = ltype.Trim();
        switch (ltype)
        {
            case "活动": return "1";
            case "主题": return "2";
            case "练习": return "3";
            case "积木": case "积木编程": return "4";
            case "Python": case "代码": case "仓库": return "5";
            case "测评": return "6";
            case "流程": case "流程图": return "7";
            case "应用": case "像素": case "拼图": case "绘图": return "8";
            case "Html": case "网页": return "9";
            case "导图": case "脑图": return "10";
            case "表格": return "11";
            case "课件": return "12";
            case "讨论": return "13";
            case "调查": case "调查问卷": return "14";
            case "填表": return "15";
            default: return ltype;
        }
    }

    private static bool IsPixelSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        int n; if (!int.TryParse(msort.Trim(), out n)) return false;
        return n == 11 || (n >= 17 && n <= 37);
    }

    private static string GetRedirectPage(string ltype, int lid, int lxid, int cid)
    {
        switch (ltype)
        {
            case "1": case "2": case "3":
                return string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
            case "6": return string.Format("console.aspx?lid={0}", lid);
            case "13": return string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, cid);
            case "14": return string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, cid);
            case "15": return string.Format("txtform.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
            default:   return string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
        }
    }

    // ── OnPreInit: redirect non-excel tasks to their correct pages ──────────
    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);
        try
        {
            string lidText  = Request.QueryString["lid"]  ?? "";
            string midText  = Request.QueryString["mid"]  ?? "";
            string mcidText = Request.QueryString["mcid"] ?? "";
            int lid = 0;
            if (!int.TryParse(lidText, out lid) || lid <= 0) return;

            string cs = GetConnStr();
            if (string.IsNullOrEmpty(cs)) return;

            using (System.Data.SqlClient.SqlConnection conn =
                   new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd =
                       new System.Data.SqlClient.SqlCommand(@"
                    SELECT L.Ltype, L.Lxid, L.Lcid, M.Mfiletype, M.Msort
                    FROM   Listmenu L
                    LEFT JOIN Mission M ON M.Mid = L.Lxid
                    WHERE  L.Lid = @Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    using (System.Data.SqlClient.SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) return;

                        string ltype    = rdr["Ltype"]    != DBNull.Value ? rdr["Ltype"].ToString().Trim()             : "";
                        string mft      = rdr["Mfiletype"] != DBNull.Value ? rdr["Mfiletype"].ToString().Trim().ToLower() : "";
                        string msort    = rdr["Msort"]    != DBNull.Value ? rdr["Msort"].ToString().Trim()             : "";
                        int    lxid     = rdr["Lxid"]     != DBNull.Value ? Convert.ToInt32(rdr["Lxid"])               : 0;
                        int    lcid     = rdr["Lcid"]     != DBNull.Value ? Convert.ToInt32(rdr["Lcid"])               : 0;

                        string norm = NormalizeLtypeInline(ltype);

                        bool isExcel = norm == "11" ||
                                       mft == "xls" || mft == "xlsx" || mft == "et"  ||
                                       mft == "ett" || mft == "csv"  || mft == "excel" ||
                                       mft == "sheet" || mft == "luckysheet";

                        // Pixel/app sub-types masquerade as Ltype 11 — redirect them away
                        if (!isExcel && IsPixelSubtype(msort)) norm = "8";

                        if (!isExcel)
                        {
                            int cid  = lcid > 0 ? lcid
                                     : (string.IsNullOrEmpty(mcidText) ? 0
                                     : Convert.ToInt32(mcidText));
                            int tmid = string.IsNullOrEmpty(midText) ? lxid
                                     : Convert.ToInt32(midText);
                            Response.Redirect(GetRedirectPage(norm, lid, tmid, cid), true);
                        }
                    }
                }
            }
        }
        catch { }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%=Titles %> - 表格编辑</title>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/pluginsCss.css'/>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/plugins.css'/>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/luckysheet.css'/>
    <link rel='stylesheet' href='../../Plugins/luckysheet/static/iconfont.css'/>
    <script type="text/javascript" src="../../Plugins/luckysheet/static/plugin.js"></script>
    <script type="text/javascript" src="../../Plugins/luckysheet/static/luckysheet.umd.js"></script>
    <script type="text/javascript" src="../../Plugins/luckysheet/static/luckyexcel.umd.js"></script>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; overflow: hidden; background: #f1f5f9; font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif; }

        /* ===== 顶部工具栏 ===== */
        .excel-toolbar {
            position: fixed;
            top: 0; left: 0; right: 0;
            height: 52px;
            background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 50%, #2563eb 100%);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
            z-index: 9999;
            box-shadow: 0 2px 12px rgba(30, 64, 175, 0.35);
            gap: 12px;
        }
        .excel-toolbar-left,
        .excel-toolbar-right {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-shrink: 0;
        }
        .excel-toolbar-center {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            min-width: 0;
            overflow: hidden;
        }
        .excel-toolbar-icon {
            width: 28px; height: 28px;
            background: rgba(255,255,255,0.15);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .excel-toolbar-icon svg {
            width: 16px; height: 16px;
            stroke: #fff; fill: none;
            stroke-width: 2;
            stroke-linecap: round; stroke-linejoin: round;
        }
        .excel-toolbar-title {
            font-size: 15px;
            font-weight: 600;
            color: #fff;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 400px;
        }
        .excel-toolbar-badge {
            font-size: 11px;
            padding: 2px 8px;
            background: rgba(255,255,255,0.18);
            color: rgba(255,255,255,0.9);
            border-radius: 99px;
            border: 1px solid rgba(255,255,255,0.25);
            flex-shrink: 0;
        }

        /* 工具栏按钮 */
        .excel-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            transition: all 0.18s ease;
            white-space: nowrap;
            line-height: 1;
        }
        .excel-btn svg {
            width: 15px; height: 15px;
            stroke: currentColor; fill: none;
            stroke-width: 2;
            stroke-linecap: round; stroke-linejoin: round;
            flex-shrink: 0;
        }
        .excel-btn-back {
            background: rgba(255,255,255,0.15);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.25);
        }
        .excel-btn-back:hover {
            background: rgba(255,255,255,0.28);
            border-color: rgba(255,255,255,0.45);
            transform: translateX(-2px);
        }
        .excel-btn-save {
            background: #fff;
            color: #1d4ed8;
        }
        .excel-btn-save:hover {
            background: #eff6ff;
            box-shadow: 0 2px 8px rgba(255,255,255,0.3);
            transform: translateY(-1px);
        }
        .excel-btn-save:active {
            transform: translateY(0);
        }
        .excel-btn-save.saving {
            opacity: 0.7;
            cursor: not-allowed;
            pointer-events: none;
        }

        /* 保存状态提示 */
        .excel-save-toast {
            position: fixed;
            top: 64px;
            right: 20px;
            padding: 10px 18px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            z-index: 99999;
            opacity: 0;
            transform: translateY(-8px);
            transition: all 0.25s ease;
            pointer-events: none;
        }
        .excel-save-toast.show {
            opacity: 1;
            transform: translateY(0);
        }
        .excel-save-toast.success {
            background: #ecfdf5;
            color: #065f46;
            border: 1px solid #6ee7b7;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
        }
        .excel-save-toast.error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fca5a5;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.15);
        }

        /* Luckysheet 容器 */
        #lucky {
            position: fixed;
            top: 52px;
            left: 0; right: 0; bottom: 0;
        }
    </style>
</head>
<body>
<script>
// 立即检查任务类型，避免页面闪烁后再跳转
(function() {
    var m = window.location.search.substr(1).match(/(?:^|&)lid=([^&]*)/);
    var lid = m ? m[1] : '';
    if (!lid || window.location.search.indexOf('debug=1') >= 0) return;
    var mid = (window.location.search.match(/(?:^|&)mid=([^&]*)/) || [])[1] || '';
    var mcid = (window.location.search.match(/(?:^|&)mcid=([^&]*)/) || [])[1] || '';
    try {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'excel-fix.ashx?lid=' + lid + '&mid=' + mid + '&mcid=' + mcid, false);
        xhr.send();
        if (xhr.status === 200) {
            var d = (new Function('return ' + xhr.responseText))();
            if (d.typeMismatch && d.correctPageForType) {
                window.location.replace(d.correctPageForType);
            }
        }
    } catch(e) {}
})();
</script>

<!-- 顶部工具栏 -->
<div class="excel-toolbar">
    <div class="excel-toolbar-left">
        <button type="button" onclick="returnurl()" class="excel-btn excel-btn-back">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
            返回学案
        </button>
    </div>
    <div class="excel-toolbar-center">
        <div class="excel-toolbar-icon">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
        </div>
        <span class="excel-toolbar-title" id="toolbarTitle">表格编辑</span>
        <span class="excel-toolbar-badge">在线表格</span>
    </div>
    <div class="excel-toolbar-right">
        <button type="button" onclick="save()" id="saveBtn" class="excel-btn excel-btn-save">
            <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            保存
        </button>
    </div>
</div>

<!-- 保存状态提示 -->
<div id="saveToast" class="excel-save-toast"></div>

<!-- Luckysheet 容器 -->
<div id="lucky"></div>

</body>

<script type="text/javascript">

    var port = ":8180"; // 端口
    // 自动适配 HTTPS 页面使用 wss:// / https://
    var wsProto   = location.protocol === 'https:' ? 'wss:'   : 'ws:';
    var httpProto = location.protocol === 'https:' ? 'https:' : 'http:';
    var str = location.host + port;
    var lor = location.origin + port;

    var title = "<%=Titles %>".trim();
    var reurl = "<%=Fpage %>".trim();
    var user = "<%=Owner%>";
    var serverip = "<%=serverIp %>";
    if (serverip !== "") {
        str = serverip + port;
        lor = httpProto + "//" + serverip + port;
    }

    // 更新标题栏
    if (title) {
        document.getElementById('toolbarTitle').textContent = title;
        document.title = title + ' - 表格编辑';
    }

    var options = {
        userInfo: user,
        container: 'lucky',
        title: title,
        lang: 'zh',
        plugins: ['chart'],
        showsheetbar: false,
        myFolderUrl: "#",
        allowUpdate: true,
        loadUrl: lor + "/load",
        updateUrl: wsProto + "//" + str + "/update?name=" + user
    };

    // 返回学案：优先使用 Fpage，其次从 URL 参数构造 program.aspx，最后 history.back()
    function returnurl() {
        if (reurl) {
            window.location.href = reurl;
            return;
        }
        function qp(name) {
            var rx = new RegExp('(?:^|[?&])' + name + '=([^&]*)');
            var m2 = window.location.search.match(rx);
            return m2 ? decodeURIComponent(m2[1]) : '';
        }
        var lid = qp('lid');
        if (lid) {
            var mid = qp('mid');
            var mcid = qp('mcid');
            var url = 'program.aspx?lid=' + encodeURIComponent(lid);
            if (mid)  url += '&mid='  + encodeURIComponent(mid);
            if (mcid) url += '&mcid=' + encodeURIComponent(mcid);
            window.location.href = url;
        } else {
            history.back();
        }
    }

    // 显示保存状态提示
    function showToast(msg, type) {
        var toast = document.getElementById('saveToast');
        toast.textContent = msg;
        toast.className = 'excel-save-toast ' + type + ' show';
        setTimeout(function() {
            toast.className = 'excel-save-toast ' + type;
        }, 2200);
    }

    function save() {
        var btn = document.getElementById('saveBtn');
        btn.classList.add('saving');
        btn.querySelector('svg').innerHTML = '<circle cx="12" cy="12" r="3"/>';
        try {
            window.luckysheet.exitEditMode();
            var excel = window.luckysheet.toJson();
            var id = "<%=Id %>";
            var urls = 'uploadexcel.ashx?id=' + id;
            var formData = new FormData();
            excel = encodeURIComponent(JSON.stringify(excel));
            formData.append('title', title);
            formData.append('excel', excel);
            $.ajax({
                url: urls,
                type: 'POST',
                cache: false,
                data: formData,
                processData: false,
                contentType: false
            }).done(function() {
                showToast('✓ 保存成功', 'success');
            }).fail(function() {
                showToast('✗ 保存失败，请重试', 'error');
            }).always(function() {
                btn.classList.remove('saving');
                btn.querySelector('svg').innerHTML = '<path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>';
            });
        } catch(e) {
            showToast('✗ 保存失败：' + e.message, 'error');
            btn.classList.remove('saving');
        }
    }

    window.onload = function () {
        var codefile = "<%=codefile %>";
        var example = "<%=Exampleurl %>";
        var _lsInited = false;
        var offlineInit = function() {
            if (_lsInited) return;
            _lsInited = true;
            if (codefile !== "") {
                try {
                    codefile = decodeURIComponent(codefile);
                    codefile = JSON.parse(codefile);
                    window.luckysheet.create(codefile);
                } catch(e) {
                    window.luckysheet.create(options);
                }
            } else if (example !== "") {
                loadHandler(example);
            } else {
                window.luckysheet.create(options);
            }
        };
        var xhr = new XMLHttpRequest();
        var liveurl = location.origin + port + "/islive";
        xhr.open("GET", liveurl, true);
        xhr.timeout = 2000; // 2秒超时，避免服务未启动时长时间卡顿
        xhr.ontimeout = offlineInit;
        xhr.onreadystatechange = function() {
            if (_lsInited) return;
            if (xhr.readyState === 4 && xhr.status === 200 && xhr.responseText) {
                _lsInited = true;
                options['allowUpdate'] = true;
                options['loadUrl'] = lor + "/load";
                options['updateUrl'] = wsProto + "//" + str + "/update?name=" + user;
                window.luckysheet.create(options);
            } else if (xhr.readyState === 4) {
                offlineInit();
            }
        };
        xhr.send();

        function loadHandler(url) {
            if (!url) return;
            LuckyExcel.transformExcelToLuckyByUrl(url, "", function(exportJson) {
                if (!exportJson.sheets || exportJson.sheets.length === 0) {
                    alert('只支持xlsx格式文档!');
                    return;
                }
                options['data'] = exportJson.sheets;
                window.luckysheet.create(options);
            });
        }
    };
</script>
</html>
