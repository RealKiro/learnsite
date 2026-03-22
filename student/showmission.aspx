<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" stylesheettheme="Student" inherits="Student_showmission, LearnSite" %>

<script runat="server">
    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11": // 像素画
            case "17": // 二维码 → 重定向到 program.aspx
                return true;
            case "36": // 素材库 → 经 program.aspx 展示任务说明再跳转
            case "37": // 网站设计 → 经 program.aspx 展示任务说明再跳转
            default:
                return false;
        }
    }
    protected override void OnPreInit(EventArgs e)
    {
        // 注意：所有重定向检查必须在 base.OnPreInit(e) 之前执行
        // 因为 base（DLL Student_showmission.OnPreInit）可能调用 Response.Redirect(..., true)
        // 抛出 ThreadAbortException，导致后续的 ware/program 重定向代码无法执行。
        
        string _lid = Request.QueryString["lid"];
        string _mid = Request.QueryString["mid"];
        string _mcid = Request.QueryString["mcid"];
        
        // 已知的积木编程任务硬编码跳转
        bool _forceScratchProgram =
            (_lid == "46" && _mcid == "10") ||
            (_lid == "53" && _mcid == "11") ||
            (_lid == "58" && _mcid == "12");
        bool _forceProgramForSpecificTask =
            (_lid == "111" && _mcid == "16");
        if (_forceScratchProgram)
        {
            Response.Redirect("program.aspx?lid=" + Server.UrlEncode(_lid ?? "") + "&mid=" + Server.UrlEncode(_mid ?? "") + "&mcid=" + Server.UrlEncode(_mcid ?? ""), true);
            return;
        }
        if (_forceProgramForSpecificTask)
        {
            Response.Redirect("program.aspx?lid=" + Server.UrlEncode(_lid ?? "") + "&mid=" + Server.UrlEncode(_mid ?? "") + "&mcid=" + Server.UrlEncode(_mcid ?? ""), true);
            return;
        }
        
        // teacher/pixeladd.aspx 的应用子类型、应用类型(8)和表格类型(11)的任务应跳转到 program.aspx 页面
        if (!string.IsNullOrEmpty(_lid))
        {
            try
            {
                string _cs = null;
                try
                {
                    System.Reflection.Assembly _lsAsm = null;
                    foreach (System.Reflection.Assembly _a in AppDomain.CurrentDomain.GetAssemblies())
                    {
                        if (_a.GetType("LearnSite.DBUtility.DbHelperSQL") != null) { _lsAsm = _a; break; }
                    }
                    Type _dbType = _lsAsm != null ? _lsAsm.GetType("LearnSite.DBUtility.DbHelperSQL") : null;
                    if (_dbType != null)
                    {
                        System.Reflection.FieldInfo _cf = _dbType.GetField("connectionString",
                            System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                        if (_cf != null) _cs = _cf.GetValue(null) as string;
                    }
                }
                catch { }
                if (string.IsNullOrEmpty(_cs))
                {
                    try { _cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
                }
                if (!string.IsNullOrEmpty(_cs))
                {
                    int _listId;
                    if (int.TryParse(_lid, out _listId) && _listId > 0)
                    {
                        using (System.Data.SqlClient.SqlConnection _conn = new System.Data.SqlClient.SqlConnection(_cs))
                        {
                            _conn.Open();
                            using (System.Data.SqlClient.SqlCommand _cmd = new System.Data.SqlClient.SqlCommand(
                                "SELECT L.Ltype, L.Lxid, L.Lcid, M.Mfiletype, M.Msort FROM Listmenu L LEFT JOIN Mission M ON L.Lxid=M.Mid WHERE L.Lid=@Lid", _conn))
                            {
                                _cmd.Parameters.AddWithValue("@Lid", _listId);
                                using (System.Data.SqlClient.SqlDataReader _rdr = _cmd.ExecuteReader())
                                {
                                    if (_rdr.Read())
                                    {
                                        string _ltype = _rdr["Ltype"] != DBNull.Value ? _rdr["Ltype"].ToString().Trim() : "";
                                        string _lxid = _rdr["Lxid"] != DBNull.Value ? _rdr["Lxid"].ToString() : "0";
                                        string _lcid = _rdr["Lcid"] != DBNull.Value ? _rdr["Lcid"].ToString() : "";
                                        string _mfiletype = _rdr["Mfiletype"] != DBNull.Value ? _rdr["Mfiletype"].ToString().Trim().ToLower() : "";
                                        string _msort = _rdr["Msort"] != DBNull.Value ? _rdr["Msort"].ToString().Trim() : "";
                                        // Msort 18-37 专属任务类型：统一跳转到 program.aspx 展示任务说明，永不显示 showmission.aspx
                                        // 包括：素材库(36)、网站设计(37)，均先过 program.aspx 再由「开始创作」跳编辑器
                                        int _msortN;
                                        if (int.TryParse(_msort, out _msortN) && _msortN >= 18 && _msortN <= 37)
                                        {
                                            _rdr.Close();
                                            string _targetMcid = !string.IsNullOrEmpty(_lcid) ? _lcid : (_mcid ?? "");
                                            string _targetMid = !string.IsNullOrEmpty(_mid) ? _mid : _lxid;
                                            Response.Redirect("program.aspx?lid=" + Server.UrlEncode(_lid) +
                                                "&mid=" + Server.UrlEncode(_targetMid) +
                                                "&mcid=" + Server.UrlEncode(_targetMcid) +
                                                "&msort=" + Server.UrlEncode(_msort), false);
                                            Context.ApplicationInstance.CompleteRequest();
                                            return;
                                        }
                                        if (_ltype == "应用" || _ltype == "像素" || _ltype == "拼图" || _ltype == "绘图") _ltype = "8";
                                        if (_ltype == "表格") _ltype = "11";
                                        if (_ltype == "课件") _ltype = "12";
                                        // 课件类型必须跳转到 ware.aspx，绝不展示 showmission.aspx
                                        // 双重判断：Ltype="12"/"课件" 或 Mfiletype="ware"（DLL 将 Mission.Mfiletype 设为 "ware"）
                                        if (_ltype == "12" || _mfiletype == "ware")
                                        {
                                            _rdr.Close();
                                            string _targetMcid = !string.IsNullOrEmpty(_lcid) ? _lcid : (_mcid ?? "");
                                            string _targetMid = !string.IsNullOrEmpty(_mid) ? _mid : _lxid;
                                            Response.Redirect("ware.aspx?lid=" + Server.UrlEncode(_lid) +
                                                "&mid=" + Server.UrlEncode(_targetMid) +
                                                "&mcid=" + Server.UrlEncode(_targetMcid), false);
                                            Context.ApplicationInstance.CompleteRequest();
                                            return;
                                        }
                                        bool _isProgramMission =
                                            _ltype == "8" ||
                                            _ltype == "11" ||
                                            IsPixelAddProgramSubtype(_msort);
                                        bool _isExcelMission =
                                            _ltype == "11" ||
                                            _mfiletype == "xls" ||
                                            _mfiletype == "xlsx" ||
                                            _mfiletype == "et" ||
                                            _mfiletype == "ett" ||
                                            _mfiletype == "csv" ||
                                            _mfiletype == "excel" ||
                                            _mfiletype == "sheet" ||
                                            _mfiletype == "luckysheet";
                                        if (_isProgramMission || _isExcelMission)
                                        {
                                            string _targetMcid = !string.IsNullOrEmpty(_lcid) ? _lcid : (_mcid ?? "");
                                            string _targetMid = !string.IsNullOrEmpty(_mid) ? _mid : _lxid;
                                            Response.Redirect("program.aspx?lid=" + Server.UrlEncode(_lid) +
                                                "&mid=" + Server.UrlEncode(_targetMid) +
                                                "&mcid=" + Server.UrlEncode(_targetMcid), true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch { }
        }
        // 所有重定向检查均未触发，才调用 base（DLL Student_showmission.OnPreInit）
        base.OnPreInit(e);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<script type="text/javascript">
    window.setTimeout(function () {
        function q(name) {
            var m = window.location.search.match(new RegExp('(?:^|&)' + name + '=([^&]*)'));
            return m ? decodeURIComponent(m[1]) : '';
        }
        var lid = q('lid');
        if (!lid) return;
        try {
            var ft = document.getElementById('<%=LabelMfiletype.ClientID %>');
            var mid = q('mid') || (document.getElementById('<%=LabelMid.ClientID %>') || {}).innerText || '';
            var mcid = q('mcid') || (document.getElementById('<%=LabelMcid.ClientID %>') || {}).innerText || '';
            var val = ft ? (ft.innerText || ft.textContent || '').replace(/^\s+|\s+$/g, '').toLowerCase() : '';
            if (val === 'xls' || val === 'xlsx' || val === 'et' || val === 'ett' || val === 'csv' || val === 'excel' || val === 'sheet' || val === 'luckysheet') {
                window.location.replace('program.aspx?lid=' + encodeURIComponent(lid) + '&mid=' + encodeURIComponent(mid) + '&mcid=' + encodeURIComponent(mcid));
            }
        } catch (e) { }
    }, 0);
</script>
<style type="text/css">
    .studmasterhead,
    .studmasterhead .stu,
    .studmasterhead .placeauto,
    .stu center,
    .stu .path {
        width: 100% !important;
        max-width: none !important;
        margin: 0 !important;
        text-align: left !important;
        box-sizing: border-box !important;
    }
    html, body {
        overflow-x: hidden !important;
    }
    .stu center {
        display: block !important;
    }
    .stu .placeauto {
        width: calc(100vw - 180px) !important;
        max-width: none !important;
        margin: 0 0 0 188px !important;
        padding: 0 !important;
        box-sizing: border-box !important;
    }
    #showcontent.sm-page {
        display: block !important;
        width: calc(100vw - 180px) !important;
        max-width: none !important;
        margin: 0 !important;
        padding: 12px 16px 40px 16px !important;
        background: transparent !important;
        font-family: "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
        box-sizing: border-box !important;
    }
    #showcontent.sm-page,
    #showcontent.sm-page .sm-shell,
    #showcontent.sm-page .sm-grid,
    #showcontent.sm-page .sm-main,
    #showcontent.sm-page .sm-card,
    #showcontent.sm-page .sm-card-body,
    #showcontent.sm-page #Mcontent {
        box-sizing: border-box !important;
    }
    .sm-shell {
        width: 100% !important;
        max-width: none !important;
        margin: 0 !important;
        padding: 0 !important;
    }
    .sm-hero {
        position: relative;
        overflow: hidden;
        margin-bottom: 24px;
        padding: 32px 36px;
        border-radius: 24px;
        background: linear-gradient(135deg, #1d4ed8 0%, #4f46e5 55%, #7c3aed 100%);
        color: #fff;
        box-shadow: 0 18px 40px rgba(79, 70, 229, 0.24);
    }
    .sm-hero:before,
    .sm-hero:after {
        content: "";
        position: absolute;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.12);
        pointer-events: none;
    }
    .sm-hero:before {
        width: 220px;
        height: 220px;
        right: -80px;
        top: -80px;
    }
    .sm-hero:after {
        width: 160px;
        height: 160px;
        right: 140px;
        bottom: -70px;
    }
    .sm-hero-inner {
        position: relative;
        z-index: 1;
    }
    .sm-badge {
        display: inline-block;
        padding: 6px 14px;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.16);
        color: #e0e7ff;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 1px;
    }
    .sm-hero .missiontitle {
        margin: 14px 0 0 !important;
        padding: 0 !important;
        background: transparent !important;
        box-shadow: none !important;
        border: none !important;
        text-align: left !important;
    }
    .sm-hero .missiontitle:before {
        display: none !important;
    }
    .sm-hero .missiontitle label,
    .sm-hero .missiontitle span {
        color: #ffffff !important;
        font-size: 24pt !important;
        font-weight: 700 !important;
        line-height: 1.4;
        text-shadow: none !important;
    }
    .sm-subtitle {
        margin-top: 10px;
        color: rgba(255, 255, 255, 0.84);
        font-size: 14px;
        line-height: 1.8;
    }
    .sm-grid {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 340px;
        gap: 16px;
        align-items: start;
    }
    .sm-main {
        min-width: 0;
        width: 100%;
    }
    .sm-card {
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 22px;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
        width: 100%;
    }
    .sm-card-head {
        padding: 22px 30px 0;
    }
    .sm-card-title {
        display: inline-block;
        padding: 8px 14px;
        border-radius: 999px;
        background: #eef2ff;
        color: #4338ca;
        font-size: 13px;
        font-weight: 700;
    }
    .sm-card-body {
        padding: 10px 30px 30px;
    }
    .sm-main .taskcontent {
        margin: 0 !important;
        padding: 12px 0 0 !important;
        background: transparent !important;
        box-shadow: none !important;
        border: none !important;
        min-height: 320px !important;
    }
    .sm-main .taskcontent > *:first-child {
        margin-top: 0 !important;
    }
    .sm-side {
        position: sticky;
        top: 96px;
    }
    .sm-side .sidebar {
        position: static !important;
        width: auto !important;
        top: auto !important;
        right: auto !important;
        padding: 0 !important;
        background: transparent !important;
        box-shadow: none !important;
        border: none !important;
    }
    .sm-side .sidebar:before {
        display: none !important;
    }
    .sm-panel {
        margin-bottom: 18px;
        padding: 22px 20px;
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 20px;
        box-shadow: 0 10px 28px rgba(15, 23, 42, 0.06);
        text-align: center;
    }
    .sm-panel-title {
        margin-bottom: 14px;
        color: #0f172a;
        font-size: 16px;
        font-weight: 700;
    }
    .sm-actions {
        padding: 0;
        overflow: hidden;
        text-align: left;
    }
    .sm-actions-top {
        padding: 22px 20px 18px;
        background: linear-gradient(135deg, #eff6ff 0%, #eef2ff 52%, #f5f3ff 100%);
        border-bottom: 1px solid #e2e8f0;
    }
    .sm-actions-kicker {
        display: inline-block;
        padding: 5px 12px;
        border-radius: 999px;
        background: #dbeafe;
        color: #1d4ed8;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: .6px;
    }
    .sm-actions .sm-panel-title {
        margin: 12px 0 8px;
        font-size: 18px;
    }
    .sm-actions-desc {
        color: #475569;
        font-size: 13px;
        line-height: 1.8;
    }
    .sm-actions-body {
        padding: 18px 20px 20px;
    }
    .sm-action-list {
        display: grid;
        gap: 12px;
    }
    .sm-action-item {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 12px 14px;
        border-radius: 16px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
    }
    .sm-action-icon {
        flex: 0 0 40px;
        width: 40px;
        height: 40px;
        border-radius: 12px;
        background: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
        color: #fff;
        font-size: 18px;
        line-height: 40px;
        text-align: center;
        box-shadow: 0 8px 18px rgba(79, 70, 229, 0.18);
    }
    .sm-action-text {
        min-width: 0;
    }
    .sm-action-name {
        color: #0f172a;
        font-size: 14px;
        font-weight: 700;
        line-height: 1.5;
    }
    .sm-action-tip {
        margin-top: 2px;
        color: #64748b;
        font-size: 12px;
        line-height: 1.7;
    }
    .sm-action-buttons {
        display: grid;
        gap: 12px;
        margin-top: 16px;
    }
    .sm-drive-btn {
        display: flex;
        align-items: center;
        gap: 14px;
        width: 100%;
        padding: 14px 16px;
        min-height: 82px;
        border: none !important;
        border-radius: 18px !important;
        background: linear-gradient(135deg, #2563eb 0%, #4f46e5 55%, #7c3aed 100%) !important;
        background-image: linear-gradient(135deg, #2563eb 0%, #4f46e5 55%, #7c3aed 100%) !important;
        color: #ffffff !important;
        cursor: pointer;
        text-align: left;
        box-shadow: 0 14px 26px rgba(79, 70, 229, 0.26);
        transition: transform .22s ease, box-shadow .22s ease, filter .22s ease;
        appearance: none;
        -webkit-appearance: none;
        overflow: hidden;
        position: relative;
        font-family: "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
    }
    .sm-drive-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 18px 32px rgba(79, 70, 229, 0.32);
        filter: saturate(1.05);
    }
    .sm-drive-btn:active {
        transform: translateY(0);
    }
    .sm-drive-btn-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 48px;
        height: 48px;
        border-radius: 16px;
        background: rgba(255, 255, 255, 0.16);
        box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.18);
        font-size: 22px;
        line-height: 1;
        flex: 0 0 48px;
    }
    .sm-drive-btn-text {
        min-width: 0;
        flex: 1;
    }
    .sm-drive-btn-title {
        display: block;
        color: #ffffff !important;
        font-size: 16px;
        font-weight: 700;
        line-height: 1.4;
        letter-spacing: .3px;
    }
    .sm-drive-btn-subtitle {
        display: block;
        margin-top: 2px;
        color: rgba(255, 255, 255, 0.82) !important;
        font-size: 12px;
        line-height: 1.6;
    }
    .sm-drive-btn-arrow {
        color: rgba(255, 255, 255, 0.92) !important;
        font-size: 20px;
        line-height: 1;
        flex: 0 0 auto;
    }
    .sm-drive-btn span {
        position: relative;
        z-index: 1;
    }
    .sm-side .sm-actions .sharedisk,
    .sm-side .sm-actions a.txtszcenter {
        margin: 0 !important;
    }
    .sm-actions-footer {
        margin-top: 16px;
        padding: 12px 14px;
        border-radius: 14px;
        background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        color: #475569;
        font-size: 12px;
        line-height: 1.8;
        border: 1px dashed #cbd5e1;
        text-align: left;
    }
    .sm-works {
        padding: 0;
        overflow: hidden;
        text-align: left;
    }
    .sm-works-top {
        padding: 22px 20px 18px;
        background: linear-gradient(135deg, #effaf5 0%, #f0fdf4 55%, #ecfeff 100%);
        border-bottom: 1px solid #dcfce7;
    }
    .sm-works-kicker {
        display: inline-block;
        padding: 5px 12px;
        border-radius: 999px;
        background: #dcfce7;
        color: #15803d;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: .6px;
    }
    .sm-works .sm-panel-title {
        margin: 12px 0 8px;
        font-size: 18px;
    }
    .sm-works-desc {
        color: #475569;
        font-size: 13px;
        line-height: 1.8;
    }
    .sm-works-body {
        padding: 18px 20px 20px;
    }
    .sm-work-status {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 14px;
        border-radius: 18px;
        background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
        border: 1px solid #e2e8f0;
        box-shadow: inset 0 1px 0 rgba(255,255,255,.9);
    }
    .sm-work-status-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 46px;
        height: 46px;
        border-radius: 14px;
        background: linear-gradient(135deg, #10b981 0%, #14b8a6 100%);
        color: #fff;
        font-size: 20px;
        line-height: 1;
        flex: 0 0 46px;
        box-shadow: 0 10px 22px rgba(20, 184, 166, 0.22);
    }
    .sm-work-status-text {
        min-width: 0;
        flex: 1;
    }
    .sm-work-status-title {
        color: #0f172a;
        font-size: 15px;
        font-weight: 700;
        line-height: 1.5;
    }
    .sm-work-status-tip {
        margin-top: 2px;
        color: #64748b;
        font-size: 12px;
        line-height: 1.7;
    }
    .sm-work-file {
        margin-top: 14px;
        padding: 14px;
        border-radius: 16px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        text-align: center;
    }
    .sm-work-file img {
        max-width: 34px;
        max-height: 34px;
        margin-bottom: 6px;
    }
    .sm-work-file .sm-link {
        display: block;
        margin-top: 4px;
        font-size: 14px;
    }
    .sm-work-file.sm-empty {
        display: none !important;
    }
    .sm-upload-card {
        margin-top: 16px;
        padding: 16px 14px 14px;
        border-radius: 18px;
        background: linear-gradient(135deg, #eff6ff 0%, #f8fbff 100%);
        border: 1px solid #dbeafe;
    }
    .sm-upload-card-title {
        color: #1e3a8a;
        font-size: 14px;
        font-weight: 700;
        line-height: 1.5;
    }
    .sm-upload-card-tip {
        margin-top: 4px;
        color: #64748b;
        font-size: 12px;
        line-height: 1.7;
    }
    .sm-upload-card input[type="file"],
    .sm-upload-card input[type="text"],
    .sm-upload-card input[type="date"],
    .sm-upload-card iframe,
    .sm-upload-card object {
        position: absolute !important;
        left: -9999px !important;
        top: auto !important;
        width: 1px !important;
        height: 1px !important;
        opacity: 0.01 !important;
        visibility: hidden !important;
        pointer-events: none !important;
        overflow: hidden !important;
    }
    .sm-upload-card #uploadButton,
    .sm-upload-card #uploadgroupButton {
        display: block !important;
        width: 180px;
        height: 46px;
        padding: 0 18px;
        border: 0;
        border-radius: 14px;
        background: linear-gradient(135deg, #f97316 0%, #ef4444 100%);
        color: #fff;
        font-size: 16px;
        font-weight: 700;
        letter-spacing: .5px;
        cursor: pointer;
        box-shadow: 0 10px 24px rgba(239, 68, 68, 0.24);
        transition: transform .2s ease, box-shadow .2s ease, filter .2s ease;
    }
    .sm-upload-card #uploadButton:hover,
    .sm-upload-card #uploadgroupButton:hover {
        transform: translateY(-1px);
        box-shadow: 0 14px 28px rgba(239, 68, 68, 0.28);
        filter: saturate(1.05);
    }
    .sm-upload-card #uploadButton:active,
    .sm-upload-card #uploadgroupButton:active {
        transform: translateY(0);
    }
    .sm-upload-card .ke-upload-file {
        position: absolute !important;
        left: -9999px !important;
        top: auto !important;
        width: 1px !important;
        height: 1px !important;
        opacity: 0.01 !important;
        visibility: hidden !important;
        pointer-events: none !important;
    }
    .sm-works .sm-meta {
        justify-content: flex-start;
        margin-top: 16px;
        margin-bottom: 0;
    }
    .sm-works .LabelMsgRed:empty,
    .sm-works .sm-msg-empty {
        display: none !important;
    }
    .sm-meta {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        margin: 14px 0 8px;
        padding: 12px 14px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        color: #475569;
        font-size: 14px;
        line-height: 1.6;
        word-break: break-all;
    }
    .sm-meta img {
        max-width: 24px;
        max-height: 24px;
    }
    .sm-link {
        display: inline-block;
        margin-top: 8px;
        color: #2563eb;
        font-weight: 600;
        text-decoration: none;
    }
    .sm-link:hover {
        text-decoration: underline;
    }
    .sm-upload-wrap {
        margin-top: 14px;
    }
    .sm-group .GridViewInfo,
    .sm-group table {
        width: 100% !important;
        margin: 0 !important;
    }
    .sm-group .GridViewInfo caption {
        caption-side: top;
        padding: 0 0 12px;
        color: #334155;
        font-weight: 700;
    }
    .sm-note {
        margin-top: 10px;
        color: #64748b;
        font-size: 12px;
        line-height: 1.7;
    }
    .sm-hidden {
        display: none;
    }
    @media (max-width: 1200px) {
        .stu .placeauto {
            width: 100% !important;
            margin: 0 !important;
            padding-left: 0 !important;
            padding-right: 0 !important;
        }
        #showcontent.sm-page {
            width: 100% !important;
            padding: 16px 10px 32px 10px !important;
            margin: 0 !important;
            overflow-x: hidden !important;
        }
        .sm-shell {
            width: 100%;
        }
        .sm-grid {
            grid-template-columns: 1fr;
            width: 100% !important;
        }
        .sm-side {
            position: static;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
        }
        .sm-side .sidebar,
        .sm-panel,
        .sm-actions,
        .sm-works,
        .sm-action-item,
        .sm-drive-btn,
        .sm-actions-footer,
        .sm-work-status,
        .sm-work-file,
        .sm-meta,
        .sm-upload-card {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
        }
    }
    @media (max-width: 768px) {
        .sm-hero {
            padding: 24px 20px;
            border-radius: 18px;
        }
        .sm-hero .missiontitle label,
        .sm-hero .missiontitle span {
            font-size: 18pt !important;
        }
        .sm-card-head,
        .sm-card-body,
        .sm-panel {
            padding-left: 16px;
            padding-right: 16px;
        }
        .sm-actions-top,
        .sm-actions-body,
        .sm-works-top,
        .sm-works-body {
            padding-left: 16px;
            padding-right: 16px;
        }
        .sm-action-item,
        .sm-work-status,
        .sm-upload-card {
            border-radius: 16px;
        }
        .sm-side .sidebar {
            width: 100% !important;
        }
    }
</style>
<div id="showcontent" class="sm-page">
    <link href="../kindeditor/themes/me/me.css" rel="stylesheet" type="text/css" />
    <script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
    <script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
    <div class="sm-shell">
        <div class="sm-hero">
            <div class="sm-hero-inner">
                <span class="sm-badge">MISSION</span>
                <div class="missiontitle">
                    <asp:Label ID="LabelMtitle" runat="server"></asp:Label>
                </div>
                <div class="sm-subtitle">查看任务要求、提交个人作品，并在需要时参与小组协作与作品互评。</div>
            </div>
        </div>
        <div class="courseother sm-hidden">
            <asp:Label ID="LabelSnum" runat="server" Visible="False"></asp:Label>
            <asp:CheckBox ID="CkMupload" runat="server" Enabled="false" Visible="False" />
            <asp:CheckBox ID="CkMgroup" runat="server" Enabled="false" Visible="False" />
            <asp:Label ID="LabelMid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelUploadType" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelMcid" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelMsort" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
        </div>
        <div class="sm-grid">
            <div class="sm-main">
                <div class="sm-card">
                    <div class="sm-card-head">
                        <span class="sm-card-title">任务内容</span>
                    </div>
                    <div class="sm-card-body">
                        <div id="Mcontent" class="taskcontent" runat="server">
                        </div>
                    </div>
                </div>
            </div>
            <div class="sm-side">
                <div class="sidebar">
                    <div class="sm-panel sm-actions">
                        <div class="sm-actions-top">
                            <span class="sm-actions-kicker">QUICK ACTIONS</span>
                            <div class="sm-panel-title">快捷操作</div>
                            <div class="sm-actions-desc">常用入口集中在这里，先准备素材，再提交作品或参与互评会更顺手。</div>
                        </div>
                        <div class="sm-actions-body">
                            <div class="sm-action-list">
                                <div class="sm-action-item">
                                    <div class="sm-action-icon">盘</div>
                                    <div class="sm-action-text">
                                        <div class="sm-action-name">我的网盘</div>
                                        <div class="sm-action-tip">查看个人资源、下载素材或整理提交前需要的文件。</div>
                                    </div>
                                </div>
                                <div class="sm-action-item">
                                    <div class="sm-action-icon">评</div>
                                    <div class="sm-action-text">
                                        <div class="sm-action-name">作品互评</div>
                                        <div class="sm-action-tip">浏览同学作品，进行评价与交流，获取更多完成思路。</div>
                                    </div>
                                </div>
                            </div>
                            <div class="sm-action-buttons">
                                <button type="button" class="sm-drive-btn" id="share" onclick="showShare()">
                                    <span class="sm-drive-btn-icon">☁</span>
                                    <span class="sm-drive-btn-text">
                                        <span class="sm-drive-btn-title">打开我的网盘</span>
                                        <span class="sm-drive-btn-subtitle">快速进入资源空间，查找素材与已保存文件</span>
                                    </span>
                                    <span class="sm-drive-btn-arrow">›</span>
                                </button>
                                <asp:HyperLink ID="VoteLink" runat="server" Target="_blank" CssClass="txtszcenter" SkinID="HyperLinkPink">作品互评</asp:HyperLink>
                            </div>
                            <div class="sm-actions-footer">建议先确认任务要求和提交格式，再从这里进入对应操作，能减少重复上传和格式错误。</div>
                        </div>
                    </div>
                    <asp:Panel ID="Panelworks" runat="server">
                        <div class="sm-panel sm-works">
                            <div class="sm-works-top">
                                <span class="sm-works-kicker">MY WORK</span>
                                <div class="sm-panel-title">个人作品</div>
                                <div class="sm-works-desc">这里可以查看自己的提交状态、确认文件格式，并重新上传最新作品。</div>
                            </div>
                            <div class="sm-works-body">
                                <div class="sm-work-status">
                                    <div class="sm-work-status-icon">作</div>
                                    <div class="sm-work-status-text">
                                        <div class="sm-work-status-title">当前作品状态</div>
                                        <div class="sm-work-status-tip">如果已经提交，可直接打开查看；如需修改，重新上传即可覆盖最新版本。</div>
                                    </div>
                                </div>
                                <div class="sm-work-file" id="submittedWork" runat="server">
                                    <asp:Image runat="server" ID="upFileType" Visible="False" />
                                    <asp:HyperLink ID="upFileUrl" runat="server" Height="16px" Visible="False" Target="_blank" CssClass="sm-link">[upFileUrl]</asp:HyperLink>
                                </div>
                                <div class="sm-meta">
                                    <asp:Image ID="ImageType" runat="server" />
                                    <span>提交格式：<asp:Label ID="LabelMfiletype" runat="server"></asp:Label></span>
                                </div>
                                <asp:Panel ID="Panelswfupload" runat="server">
                                <div class="sm-upload-card">
                                    <div class="sm-upload-card-title">上传新作品</div>
                                    <div class="sm-upload-card-tip">请根据任务要求选择正确格式的文件，上传后页面会自动刷新。</div>
                                <div id="swfu_container" class="sm-upload-wrap">
                                    <script type="text/javascript">
                                        var lid = "<%=LabelLid.Text %>";
                                        var urlstr = "uploadworkm.aspx?lid=" + lid;
                                        KindEditor.ready(function (K) {
                                            var buttonEl = K('#uploadButton')[0];
                                            var uploadbutton = K.uploadbutton({
                                                button: buttonEl,
                                                fieldName: 'imgFile',
                                                url: urlstr,
                                                afterUpload: function (data) {
                                                    if (data.error === 0) {
                                                        alert("作品已经提交成功！");
                                                        location.reload();
                                                    } else {
                                                        alert(data.message);
                                                    }
                                                },
                                                afterError: function (str) {
                                                    alert('出错信息: ' + str);
                                                }
                                            });
                                            if (buttonEl && uploadbutton.fileBox && uploadbutton.fileBox[0]) {
                                                var fileInput = uploadbutton.fileBox[0];
                                                fileInput.setAttribute('tabindex', '-1');
                                                fileInput.setAttribute('aria-hidden', 'true');
                                                buttonEl.value = '上传文件';
                                                buttonEl.onclick = function (ev) {
                                                    ev = ev || window.event;
                                                    if (ev.preventDefault) ev.preventDefault();
                                                    fileInput.click();
                                                    return false;
                                                };
                                            }
                                            uploadbutton.fileBox.change(function (e) {
                                                uploadbutton.submit();
                                            });
                                        });
                                    </script>
                                    <input type="button" id="uploadButton" value="上传文件" />
                                </div>
                                </div>
                            </asp:Panel>
                            <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
                        </div>
                    </asp:Panel>
                    <asp:Panel ID="Panelgroup" runat="server">
                        <div class="sm-panel sm-group">
                            <div class="sm-panel-title">小组合作</div>
                            <asp:GridView ID="GVgwork" runat="server"
                                AutoGenerateColumns="False" CellPadding="3" DataKeyNames="wid"
                                EnableModelValidation="True"
                                OnRowCommand="GVgwork_RowCommand"
                                onrowdatabound="GVgwork_RowDataBound" PageSize="15" SkinID="GridViewInfo"
                                Width="100%" Caption="小组合作面板">
                                <Columns>
                                    <asp:TemplateField HeaderText="作品">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="HyperLinkWurl" runat="server" Target="_blank" Text='<%# Eval("Sname") %>'
                                                ToolTip='<%# Eval("Wurl") %>'></asp:HyperLink>
                                        </ItemTemplate>
                                        <ControlStyle Width="60px" />
                                    </asp:TemplateField>
                                    <asp:TemplateField ShowHeader="False">
                                        <ItemTemplate>
                                            <asp:Label ID="Label4" runat="server" Text='<%# Bind("Wlscore") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="评" ShowHeader="False">
                                        <ControlStyle Width="16px" />
                                        <ItemTemplate>
                                            <asp:LinkButton ID="LinkButtonA" runat="server" CausesValidation="false"
                                                CommandArgument='<%# Bind("wid") %>' CommandName="A" Text="A"></asp:LinkButton>
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="价" ShowHeader="False">
                                        <ControlStyle Width="16px" />
                                        <ItemTemplate>
                                            <asp:LinkButton ID="LinkButtonP" runat="server" CausesValidation="false"
                                                CommandArgument='<%# Bind("wid") %>' CommandName="P" Text="P"></asp:LinkButton>
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField ShowHeader="False">
                                        <ControlStyle Width="16px" />
                                        <ItemTemplate>
                                            <asp:LinkButton ID="LinkButtonE" runat="server" CausesValidation="false"
                                                CommandArgument='<%# Bind("wid") %>' CommandName="E" Text="E"></asp:LinkButton>
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                            <div class="sm-meta">
                                <asp:Image ID="upFileTypeGroup" runat="server" Visible="False" />
                                <asp:HyperLink ID="upFileUrlGroup" runat="server" Height="16px" Target="_blank"
                                    Visible="False" CssClass="sm-link">[upFileUrlGroup]</asp:HyperLink>
                            </div>
                            <asp:Panel ID="PanelGroupUp" runat="server">
                                <div id="swfu_containerTwo" class="sm-upload-wrap">
                                    <script type="text/javascript">
                                        var lid = "<%=LabelLid.Text %>";
                                        var gurlstr = "uploadgroupm.aspx?lid=" + lid;
                                        KindEditor.ready(function (K) {
                                            var groupButtonEl = K('#uploadgroupButton')[0];
                                            var uploadgroupbutton = K.uploadbutton({
                                                button: groupButtonEl,
                                                fieldName: 'imgFilegroup',
                                                url: gurlstr,
                                                afterUpload: function (data) {
                                                    if (data.error === 0) {
                                                        alert("小组作品已经提交成功！");
                                                        location.reload(true);//重新刷新ctrl+F5
                                                    } else {
                                                        alert(data.message);
                                                    }
                                                },
                                                afterError: function (str) {
                                                    alert('出错信息: ' + str);
                                                }
                                            });
                                            if (groupButtonEl && uploadgroupbutton.fileBox && uploadgroupbutton.fileBox[0]) {
                                                var groupFileInput = uploadgroupbutton.fileBox[0];
                                                groupFileInput.setAttribute('tabindex', '-1');
                                                groupFileInput.setAttribute('aria-hidden', 'true');
                                                groupButtonEl.value = '上传文件';
                                                groupButtonEl.onclick = function (ev) {
                                                    ev = ev || window.event;
                                                    if (ev.preventDefault) ev.preventDefault();
                                                    groupFileInput.click();
                                                    return false;
                                                };
                                            }
                                            uploadgroupbutton.fileBox.change(function (e) {
                                                uploadgroupbutton.submit();
                                            });
                                        });
                                    </script>
                                    <input type="button" id="uploadgroupButton" value="上传文件" />
                                </div>
                            </asp:Panel>
                            <asp:Label ID="Labelgroupmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        function jsCopy(contentid) {
            var e = document.getElementById(contentid); //对象是content 
            e.select(); //选择对象 
            document.execCommand("Copy"); //执行浏览器复制命令 
        }
        (function () {
            function trimText(el) {
                return el ? ((el.textContent || el.innerText || '').replace(/^\s+|\s+$/g, '')) : '';
            }
            function resetShowMissionLayoutOffsets() {
                var page = document.getElementById('showcontent');
                if (!page) return;
                var menu = document.getElementsByClassName ? document.getElementsByClassName('menu')[0] : null;
                var menuWidth = 180;
                var viewportWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth || 0;
                var isNarrow = viewportWidth > 0 && viewportWidth <= 1200;
                if (menu) {
                    menuWidth = menu.offsetWidth || menu.clientWidth || 180;
                }

                try {
                    document.body.style.paddingLeft = '0';
                    document.body.style.marginLeft = '0';
                } catch (e) { }

                var node = page.parentNode;
                while (node && node.nodeType === 1) {
                    var cls = node.className || '';
                    if (typeof cls === 'string' && (cls.indexOf('placeauto') > -1 || cls.indexOf('stu') > -1 || cls.indexOf('studmasterhead') > -1)) {
                        node.style.marginLeft = '0';
                        node.style.paddingLeft = '0';
                        node.style.maxWidth = 'none';
                        node.style.width = '100%';
                        node.style.textAlign = 'left';
                    }
                    if (node.tagName && node.tagName.toLowerCase() === 'center') {
                        node.style.display = 'block';
                        node.style.margin = '0';
                        node.style.padding = '0';
                        node.style.textAlign = 'left';
                    }
                    node = node.parentNode;
                }

                var placeauto = document.getElementsByClassName ? document.getElementsByClassName('placeauto') : [];
                if (placeauto && placeauto.length) {
                    for (var p = 0; p < placeauto.length; p++) {
                        if (isNarrow) {
                            placeauto[p].style.marginLeft = '0';
                            placeauto[p].style.width = '100%';
                        } else {
                            placeauto[p].style.marginLeft = (menuWidth + 8) + 'px';
                            placeauto[p].style.width = 'calc(100vw - ' + menuWidth + 'px)';
                        }
                        placeauto[p].style.maxWidth = 'none';
                        placeauto[p].style.paddingLeft = '0';
                        placeauto[p].style.paddingRight = '0';
                    }
                }

                var shell = page.getElementsByClassName ? page.getElementsByClassName('sm-shell')[0] : null;
                if (shell) {
                    shell.style.marginLeft = '0';
                    shell.style.width = '100%';
                    shell.style.maxWidth = 'none';
                }
                page.style.width = isNarrow ? '100%' : ('calc(100vw - ' + menuWidth + 'px)');
                page.style.marginLeft = '0';
                page.style.paddingLeft = isNarrow ? '10px' : '16px';
                page.style.paddingRight = isNarrow ? '10px' : '16px';
                page.style.overflowX = 'hidden';
            }
            function hideBrokenPersonalWorkBits() {
                var workWrap = document.getElementById('submittedWork');
                var workLink = document.getElementById('<%=upFileUrl.ClientID %>');
                var workImg = document.getElementById('<%=upFileType.ClientID %>');
                if (workWrap) {
                    var hasLink = !!(workLink && trimText(workLink) && workLink.style.display !== 'none');
                    var hasImg = !!(workImg && workImg.getAttribute('src') && workImg.style.display !== 'none');
                    if (!hasLink && !hasImg) {
                        workWrap.className += (workWrap.className ? ' ' : '') + 'sm-empty';
                    }
                }

                var msg = document.getElementById('<%=Labelmsg.ClientID %>');
                if (msg) {
                    var msgText = trimText(msg);
                    if (!msgText || /^\d{4}-\d{1,2}-\d{1,2}$/.test(msgText) || /^\d{4}\/\d{1,2}\/\d{1,2}$/.test(msgText)) {
                        msg.style.display = 'none';
                        msg.className += (msg.className ? ' ' : '') + 'sm-msg-empty';
                    }
                }

                var uploadArea = document.getElementById('swfu_container');
                if (uploadArea) {
                    var inputs = uploadArea.getElementsByTagName('input');
                    for (var i = 0; i < inputs.length; i++) {
                        var input = inputs[i];
                        if (input.id !== 'uploadButton' && input.type !== 'button') {
                            if (input.type === 'file') {
                                input.style.display = 'block';
                                input.style.visibility = 'hidden';
                                input.style.position = 'absolute';
                                input.style.left = '-9999px';
                                input.style.width = '1px';
                                input.style.height = '1px';
                                input.style.opacity = '0.01';
                                continue;
                            }
                            input.style.display = 'none';
                            input.style.visibility = 'hidden';
                            input.style.position = 'absolute';
                            input.style.left = '-9999px';
                        }
                    }
                }
            }
            function runShowMissionFixes() {
                resetShowMissionLayoutOffsets();
                hideBrokenPersonalWorkBits();
            }
            if (window.addEventListener) {
                window.addEventListener('load', runShowMissionFixes);
            } else {
                window.attachEvent('onload', runShowMissionFixes);
            }
        })();
    </script>
</div>
</asp:Content>

