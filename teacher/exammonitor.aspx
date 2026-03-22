<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;

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
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private void LoadTeacher()
    {
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out myHid); }
                }
            }
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadTeacher();
        if (!IsPostBack)
        {
            LoadExams();
        }
    }

    private void LoadExams()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT ep.Eid, p.Ptitle, ep.Egrade, ep.Eclass, ep.Estart, ep.Eend, ep.Estatus
                    FROM ExamPublish ep
                    INNER JOIN Paper p ON ep.Epid = p.Pid
                    WHERE ep.Ehid = @hid AND ep.Estatus = 1
                    ORDER BY ep.Eid DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLExam.Items.Clear();
                    DDLExam.Items.Add(new System.Web.UI.WebControls.ListItem("-- 请选择考试 --", "0"));

                    while (dr.Read())
                    {
                        string text = dr["Ptitle"].ToString() + " (" +
                            dr["Egrade"] + "年级" + dr["Eclass"] + "班)";
                        DDLExam.Items.Add(new System.Web.UI.WebControls.ListItem(text, dr["Eid"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .em-page { max-width: 1400px; margin: 0 auto; padding: 24px; font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif; }
    
    .em-header { margin-bottom: 28px; }
    .em-title { font-size: 28px; font-weight: 700; color: #1e293b; margin: 0 0 8px 0; display: flex; align-items: center; gap: 12px; }
    .em-title svg { width: 32px; height: 32px; stroke: #6366f1; fill: none; stroke-width: 2; }
    .em-subtitle { font-size: 14px; color: #64748b; margin: 0; }
    
    .em-filters { background: #fff; border-radius: 16px; padding: 20px 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); border: 1px solid #e5e7eb; }
    .em-filter-row { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .em-filter-group { display: flex; align-items: center; gap: 10px; }
    .em-filter-label { font-size: 14px; font-weight: 600; color: #475569; white-space: nowrap; }
    .em-filter-select { padding: 8px 36px 8px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 14px; color: #1e293b; background: #fff; cursor: pointer; transition: all .2s; appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 12px center; min-width: 280px; }
    .em-filter-select:hover { border-color: #6366f1; }
    .em-filter-select:focus { outline: none; border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .em-filter-btn { padding: 8px 20px; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 6px; background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; box-shadow: 0 2px 8px rgba(99,102,241,.3); }
    .em-filter-btn:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99,102,241,.4); }
    .em-filter-btn svg { width: 16px; height: 16px; }
    
    .em-stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 28px; }
    .em-stat-card { background: #fff; border-radius: 14px; padding: 22px 24px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); transition: all .2s; position: relative; overflow: hidden; }
    .em-stat-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; background: linear-gradient(90deg, var(--card-color-1), var(--card-color-2)); }
    .em-stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,.08); }
    .em-stat-card-blue { --card-color-1: #3b82f6; --card-color-2: #2563eb; }
    .em-stat-card-green { --card-color-1: #10b981; --card-color-2: #059669; }
    .em-stat-card-red { --card-color-1: #ef4444; --card-color-2: #dc2626; }
    .em-stat-card-orange { --card-color-1: #f59e0b; --card-color-2: #d97706; }
    .em-stat-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
    .em-stat-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
    .em-stat-icon svg { width: 22px; height: 22px; stroke-width: 2; }
    .em-stat-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe); }
    .em-stat-icon-blue svg { stroke: #2563eb; }
    .em-stat-icon-green { background: linear-gradient(135deg, #d1fae5, #a7f3d0); }
    .em-stat-icon-green svg { stroke: #059669; }
    .em-stat-icon-red { background: linear-gradient(135deg, #fecaca, #fca5a5); }
    .em-stat-icon-red svg { stroke: #dc2626; }
    .em-stat-icon-orange { background: linear-gradient(135deg, #fed7aa, #fdba74); }
    .em-stat-icon-orange svg { stroke: #d97706; }
    .em-stat-label { font-size: 13px; color: #64748b; font-weight: 500; margin-bottom: 6px; }
    .em-stat-value { font-size: 32px; font-weight: 800; color: #1e293b; line-height: 1; }
    .em-stat-unit { font-size: 16px; font-weight: 600; color: #64748b; margin-left: 4px; }
    
    .em-table-card { background: #fff; border-radius: 16px; padding: 24px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 24px; }
    .em-table-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 2px solid #f1f5f9; }
    .em-table-title { font-size: 18px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 10px; }
    .em-table-title svg { width: 22px; height: 22px; stroke: #6366f1; fill: none; stroke-width: 2; }
    
    .em-table { width: 100%; border-collapse: separate; border-spacing: 0; }
    .em-table thead th { background: linear-gradient(135deg, #f8fafc, #f1f5f9); padding: 14px 16px; text-align: left; font-size: 13px; font-weight: 700; color: #475569; border-bottom: 2px solid #e2e8f0; white-space: nowrap; }
    .em-table thead th:first-child { border-radius: 10px 0 0 0; }
    .em-table thead th:last-child { border-radius: 0 10px 0 0; }
    .em-table tbody tr { transition: all .15s; }
    .em-table tbody tr:hover { background: #f8fafc; }
    .em-table tbody td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155; }
    .em-table tbody tr:last-child td { border-bottom: none; }
    
    .em-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .em-badge-success { background: #d1fae5; color: #065f46; }
    .em-badge-danger { background: #fee2e2; color: #991b1b; }
    
    .em-empty { text-align: center; padding: 60px 20px; color: #94a3b8; }
    .em-empty svg { width: 64px; height: 64px; stroke: #cbd5e1; margin-bottom: 16px; }
    .em-empty-text { font-size: 16px; font-weight: 500; }
    
    /* 弹窗样式 */
    .em-modal { display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); animation: emFadeIn 0.2s ease; }
    @keyframes emFadeIn { from { opacity: 0; } to { opacity: 1; } }
    .em-modal-content { position: relative; background: #fff; margin: 5% auto; padding: 0; width: 90%; max-width: 800px; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); animation: emSlideIn 0.3s ease; }
    @keyframes emSlideIn { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .em-modal-header { padding: 24px 28px; border-bottom: 2px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between; }
    .em-modal-title { font-size: 20px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; margin: 0; }
    .em-modal-title svg { width: 24px; height: 24px; stroke-width: 2; }
    .em-modal-close { width: 36px; height: 36px; border: none; background: #f1f5f9; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
    .em-modal-close:hover { background: #e2e8f0; transform: rotate(90deg); }
    .em-modal-close svg { width: 20px; height: 20px; stroke: #64748b; stroke-width: 2; }
    .em-modal-body { padding: 24px 28px; max-height: 500px; overflow-y: auto; }
    .em-modal-table { width: 100%; border-collapse: separate; border-spacing: 0; }
    .em-modal-table thead th { background: linear-gradient(135deg, #f8fafc, #f1f5f9); padding: 12px 16px; text-align: left; font-size: 13px; font-weight: 700; color: #475569; border-bottom: 2px solid #e2e8f0; position: sticky; top: 0; z-index: 1; }
    .em-modal-table thead th:first-child { border-radius: 10px 0 0 0; }
    .em-modal-table thead th:last-child { border-radius: 0 10px 0 0; }
    .em-modal-table tbody tr { transition: all .15s; }
    .em-modal-table tbody tr:hover { background: #f8fafc; }
    .em-modal-table tbody td { padding: 14px 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155; }
    .em-modal-table tbody tr:last-child td { border-bottom: none; }
    .em-modal-empty { text-align: center; padding: 40px 20px; color: #94a3b8; }
    
    /* 学生名单网格 */
    .em-student-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 12px; }
    .em-student-item { padding: 12px 16px; background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 8px; text-align: center; font-size: 14px; font-weight: 500; color: #1e293b; transition: all .2s; }
    .em-student-item:hover { background: #eff6ff; border-color: #3b82f6; transform: translateY(-2px); box-shadow: 0 2px 8px rgba(59,130,246,0.2); }
    .em-student-item.submitted { background: #d1fae5; border-color: #10b981; color: #065f46; }
    .em-student-item.submitted:hover { background: #a7f3d0; border-color: #059669; }
    .em-student-item.unsubmitted { background: #fee2e2; border-color: #ef4444; color: #991b1b; }
    .em-student-item.unsubmitted:hover { background: #fecaca; border-color: #dc2626; }
    .em-stat-card { cursor: pointer; }
    .em-stat-card:active { transform: translateY(-2px) scale(0.98); }
    
    /* 自动刷新指示器 */
    .em-auto-refresh { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748b; }
    .em-auto-refresh-dot { width: 8px; height: 8px; border-radius: 50%; background: #10b981; animation: emPulse 2s ease-in-out infinite; }
    @keyframes emPulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.5; transform: scale(0.8); } }
    .em-auto-refresh-text { font-weight: 500; }
    .em-countdown { font-weight: 600; color: #6366f1; }
    .em-refresh-toggle { padding: 6px 14px; border: 1.5px solid #e2e8f0; border-radius: 6px; background: #fff; font-size: 13px; font-weight: 600; color: #475569; cursor: pointer; transition: all .2s; }
    .em-refresh-toggle:hover { border-color: #6366f1; color: #6366f1; background: #eff6ff; }
    .em-refresh-toggle.active { border-color: #10b981; color: #10b981; background: #d1fae5; }
</style>

<div class="em-page">
    <div class="em-header">
        <h1 class="em-title">
            <svg viewBox="0 0 24 24"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
            考试监考
        </h1>
        <p class="em-subtitle">实时监控考试进度，查看学生提交状态</p>
    </div>

    <div class="em-filters">
        <div class="em-filter-row">
            <div class="em-filter-group">
                <label class="em-filter-label">选择考试</label>
                <asp:DropDownList ID="DDLExam" runat="server" CssClass="em-filter-select"></asp:DropDownList>
            </div>
            <button type="button" class="em-filter-btn" onclick="loadMonitorData()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                刷新数据
            </button>
            <div class="em-auto-refresh" id="autoRefreshIndicator" style="display:none;">
                <span class="em-auto-refresh-dot"></span>
                <span class="em-auto-refresh-text">自动刷新: <span class="em-countdown" id="countdown">30</span>秒</span>
            </div>
            <button type="button" class="em-refresh-toggle" id="toggleAutoRefresh">
                开启自动刷新
            </button>
        </div>
    </div>

    <div id="statsContainer" style="display:none;">
        <div class="em-stats-grid">
            <div class="em-stat-card em-stat-card-blue" onclick="showAllStudents()">
                <div class="em-stat-header">
                    <div class="em-stat-icon em-stat-icon-blue">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                </div>
                <div class="em-stat-label">应考人数</div>
                <div class="em-stat-value" id="totalCount">0<span class="em-stat-unit">人</span></div>
            </div>
            
            <div class="em-stat-card em-stat-card-green" onclick="showSubmittedModal()">
                <div class="em-stat-header">
                    <div class="em-stat-icon em-stat-icon-green">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><polyline points="20 6 9 17 4 12"/></svg>
                    </div>
                </div>
                <div class="em-stat-label">已提交</div>
                <div class="em-stat-value" id="submittedCount">0<span class="em-stat-unit">人</span></div>
            </div>
            
            <div class="em-stat-card em-stat-card-red" onclick="showUnsubmittedModal()">
                <div class="em-stat-header">
                    <div class="em-stat-icon em-stat-icon-red">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    </div>
                </div>
                <div class="em-stat-label">未提交</div>
                <div class="em-stat-value" id="unsubmittedCount">0<span class="em-stat-unit">人</span></div>
            </div>
            
            <div class="em-stat-card em-stat-card-orange">
                <div class="em-stat-header">
                    <div class="em-stat-icon em-stat-icon-orange">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                </div>
                <div class="em-stat-label">提交率</div>
                <div class="em-stat-value" id="submitRate">0<span class="em-stat-unit">%</span></div>
            </div>
        </div>
    </div>

    <div id="tablesContainer" style="display:none;">
        <div class="em-table-card">
            <div class="em-table-header">
                <h3 class="em-table-title">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    已提交学生名单
                </h3>
            </div>
            <div id="submittedTableContainer"></div>
        </div>

        <div class="em-table-card">
            <div class="em-table-header">
                <h3 class="em-table-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    未提交学生名单
                </h3>
            </div>
            <div id="unsubmittedTableContainer"></div>
        </div>
    </div>

    <div id="emptyState" class="em-empty">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <div class="em-empty-text">请选择考试后点击"刷新数据"查看监考信息</div>
    </div>
</div>

<!-- 弹窗 -->
<div id="studentModal" class="em-modal">
    <div class="em-modal-content">
        <div class="em-modal-header">
            <h3 class="em-modal-title" id="modalTitle">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                学生名单
            </h3>
            <button class="em-modal-close" onclick="closeModal()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="em-modal-body" id="modalBody">
            <!-- 动态内容 -->
        </div>
    </div>
</div>

<script>
var currentData = null;
var autoRefreshEnabled = false;
var autoRefreshTimer = null;
var countdownTimer = null;
var countdownSeconds = 30;
var refreshInterval = 30; // 30秒自动刷新

function loadMonitorData() {
    var eid = document.getElementById('<%= DDLExam.ClientID %>').value;
    if (!eid || eid === '0') {
        alert('请先选择考试');
        return;
    }
    
    var url = 'exammonitorapi.ashx?eid=' + eid;
    
    fetch(url)
        .then(function(response) {
            if (!response.ok) {
                throw new Error('HTTP ' + response.status + ': ' + response.statusText);
            }
            return response.text();
        })
        .then(function(text) {
            try {
                var data = JSON.parse(text);
                if (!data.success) {
                    alert(data.message || '加载失败');
                    return;
                }
                
                currentData = data;
                
                document.getElementById('emptyState').style.display = 'none';
                document.getElementById('statsContainer').style.display = 'block';
                document.getElementById('tablesContainer').style.display = 'block';
                
                var total = data.totalCount || 0;
                var submitted = data.submittedCount || 0;
                var unsubmitted = data.unsubmittedCount || 0;
                var rate = total > 0 ? Math.round((submitted / total) * 100) : 0;
                
                document.getElementById('totalCount').innerHTML = total + '<span class="em-stat-unit">人</span>';
                document.getElementById('submittedCount').innerHTML = submitted + '<span class="em-stat-unit">人</span>';
                document.getElementById('unsubmittedCount').innerHTML = unsubmitted + '<span class="em-stat-unit">人</span>';
                document.getElementById('submitRate').innerHTML = rate + '<span class="em-stat-unit">%</span>';
                
                renderTable('submittedTableContainer', data.submitted, true);
                renderTable('unsubmittedTableContainer', data.unsubmitted, false);
                
                // 重置倒计时（如果自动刷新已开启）
                if (autoRefreshEnabled) {
                    countdownSeconds = refreshInterval;
                    updateCountdown();
                }
            } catch (e) {
                alert('数据解析失败: ' + e.message + '\n\n返回内容:\n' + text.substring(0, 500));
            }
        })
        .catch(function(err) {
            alert('加载失败: ' + err.message);
        });
}

function toggleAutoRefresh() {
    autoRefreshEnabled = !autoRefreshEnabled;
    var btn = document.getElementById('toggleAutoRefresh');
    var indicator = document.getElementById('autoRefreshIndicator');
    
    if (autoRefreshEnabled) {
        btn.textContent = '关闭自动刷新';
        btn.classList.add('active');
        indicator.style.display = 'flex';
        
        // 检查是否已选择考试
        var eid = document.getElementById('<%= DDLExam.ClientID %>').value;
        if (!eid || eid === '0') {
            alert('请先选择考试');
            autoRefreshEnabled = false;
            btn.textContent = '开启自动刷新';
            btn.classList.remove('active');
            indicator.style.display = 'none';
            return;
        }
        
        // 立即加载一次数据
        loadMonitorData();
        
        // 启动自动刷新
        startAutoRefresh();
    } else {
        btn.textContent = '开启自动刷新';
        btn.classList.remove('active');
        indicator.style.display = 'none';
        
        // 停止自动刷新
        stopAutoRefresh();
    }
}

function startAutoRefresh() {
    stopAutoRefresh(); // 先清除已有的定时器
    
    countdownSeconds = refreshInterval;
    updateCountdown();
    
    // 倒计时定时器（每秒更新）
    countdownTimer = setInterval(function() {
        countdownSeconds--;
        updateCountdown();
        
        if (countdownSeconds <= 0) {
            // 倒计时结束，触发刷新
            loadMonitorData();
            countdownSeconds = refreshInterval;
        }
    }, 1000);
}

function stopAutoRefresh() {
    if (autoRefreshTimer) {
        clearInterval(autoRefreshTimer);
        autoRefreshTimer = null;
    }
    if (countdownTimer) {
        clearInterval(countdownTimer);
        countdownTimer = null;
    }
}

function updateCountdown() {
    var countdownEl = document.getElementById('countdown');
    if (countdownEl) {
        countdownEl.textContent = countdownSeconds;
    }
}

function renderTable(containerId, students, isSubmitted) {
    var container = document.getElementById(containerId);
    if (!students || students.length === 0) {
        container.innerHTML = '<div class="em-empty"><div class="em-empty-text">暂无数据</div></div>';
        return;
    }
    
    var html = '<table class="em-table"><thead><tr>';
    html += '<th>序号</th><th>学号</th><th>姓名</th>';
    if (isSubmitted) {
        html += '<th>提交时间</th>';
    }
    html += '<th>状态</th></tr></thead><tbody>';
    
    for (var i = 0; i < students.length; i++) {
        var s = students[i];
        html += '<tr>';
        html += '<td>' + (i + 1) + '</td>';
        html += '<td>' + (s.snum || '') + '</td>';
        html += '<td>' + (s.sname || '') + '</td>';
        if (isSubmitted) {
            html += '<td>' + (s.submitTime || '') + '</td>';
        }
        html += '<td><span class="em-badge ' + (isSubmitted ? 'em-badge-success' : 'em-badge-danger') + '">';
        html += isSubmitted ? '已提交' : '未提交';
        html += '</span></td>';
        html += '</tr>';
    }
    
    html += '</tbody></table>';
    container.innerHTML = html;
}

function showAllStudents() {
    if (!currentData) {
        alert('请先刷新数据');
        return;
    }
    
    var allStudents = [];
    var submittedMap = {};
    
    for (var i = 0; i < currentData.submitted.length; i++) {
        var s = currentData.submitted[i];
        allStudents.push({
            snum: s.snum,
            sname: s.sname,
            status: '已提交',
            submitTime: s.submitTime,
            isSubmitted: true
        });
        submittedMap[s.snum] = true;
    }
    
    for (var j = 0; j < currentData.unsubmitted.length; j++) {
        var u = currentData.unsubmitted[j];
        allStudents.push({
            snum: u.snum,
            sname: u.sname,
            status: '未提交',
            submitTime: '',
            isSubmitted: false
        });
    }
    
    allStudents.sort(function(a, b) {
        return a.snum.localeCompare(b.snum);
    });
    
    showModal('应考学生名单 (' + allStudents.length + '人)', allStudents, true);
}

function showSubmittedModal() {
    if (!currentData) {
        alert('请先刷新数据');
        return;
    }
    
    var students = [];
    for (var i = 0; i < currentData.submitted.length; i++) {
        var s = currentData.submitted[i];
        students.push({
            snum: s.snum,
            sname: s.sname,
            status: '已提交',
            submitTime: s.submitTime,
            isSubmitted: true
        });
    }
    
    showModal('已提交学生名单 (' + students.length + '人)', students, true);
}

function showUnsubmittedModal() {
    if (!currentData) {
        alert('请先刷新数据');
        return;
    }
    
    var students = [];
    for (var i = 0; i < currentData.unsubmitted.length; i++) {
        var u = currentData.unsubmitted[i];
        students.push({
            snum: u.snum,
            sname: u.sname,
            status: '未提交',
            submitTime: '',
            isSubmitted: false
        });
    }
    
    showModal('未提交学生名单 (' + students.length + '人)', students, false);
}

function showModal(title, students, showTime) {
    document.getElementById('modalTitle').innerHTML = 
        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>' + 
        title;
    
    var html = '';
    if (!students || students.length === 0) {
        html = '<div class="em-modal-empty">暂无数据</div>';
    } else {
        html = '<div class="em-student-grid">';
        
        for (var i = 0; i < students.length; i++) {
            var s = students[i];
            var statusClass = s.isSubmitted ? 'submitted' : 'unsubmitted';
            html += '<div class="em-student-item ' + statusClass + '">';
            html += (s.sname || '未知');
            html += '</div>';
        }
        
        html += '</div>';
    }
    
    document.getElementById('modalBody').innerHTML = html;
    document.getElementById('studentModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('studentModal').style.display = 'none';
}

window.onclick = function(event) {
    var modal = document.getElementById('studentModal');
    if (event.target == modal) {
        closeModal();
    }
}

// 页面卸载时清理定时器
window.onbeforeunload = function() {
    stopAutoRefresh();
}

// 页面加载完成后绑定事件
document.addEventListener('DOMContentLoaded', function() {
    var toggleBtn = document.getElementById('toggleAutoRefresh');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', toggleAutoRefresh);
    }
});
</script>
</asp:Content>
