<%@ Page Title="课程表" Language="C#" MasterPageFile="~/teacher/Teach.master" %>

<script runat="server">
    protected string currentScheduleUrl = "";
    protected string scheduleData = "{}";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCurrentSchedule();
            LoadScheduleData();
        }
    }
    
    private void LoadCurrentSchedule()
    {
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf" };
        foreach (string ext in exts)
        {
            string path = Server.MapPath("~/images/schedule" + ext);
            if (System.IO.File.Exists(path))
            {
                currentScheduleUrl = ResolveUrl("~/images/schedule" + ext) + "?v=" + System.IO.File.GetLastWriteTime(path).Ticks;
                break;
            }
        }
    }
    
    private void LoadScheduleData()
    {
        try
        {
            string jsonPath = Server.MapPath("~/App_Data/schedule.json");
            if (System.IO.File.Exists(jsonPath))
            {
                scheduleData = System.IO.File.ReadAllText(jsonPath, System.Text.Encoding.UTF8);
            }
        }
        catch { }
    }
    
    protected void BtnUpload_Click(object sender, EventArgs e)
    {
        try
        {
            if (!FileUploadSchedule.HasFile)
            {
                lblMessage.Text = "请选择要上传的课程表文件";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                return;
            }
            
            HttpPostedFile file = FileUploadSchedule.PostedFile;
            string ext = System.IO.Path.GetExtension(file.FileName).ToLower();
            
            string[] allowedExts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf" };
            bool isAllowed = false;
            foreach (string allowedExt in allowedExts)
            {
                if (ext == allowedExt) { isAllowed = true; break; }
            }
            
            if (!isAllowed)
            {
                lblMessage.Text = "只支持 PNG、JPG、GIF、WebP、PDF 格式的文件";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                return;
            }
            
            if (file.ContentLength > 10 * 1024 * 1024)
            {
                lblMessage.Text = "文件大小不能超过 10MB";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                return;
            }
            
            string[] oldExts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf" };
            foreach (string oldExt in oldExts)
            {
                string oldPath = Server.MapPath("~/images/schedule" + oldExt);
                if (System.IO.File.Exists(oldPath))
                {
                    try { System.IO.File.Delete(oldPath); } catch { }
                }
            }
            
            string savePath = Server.MapPath("~/images/schedule" + ext);
            file.SaveAs(savePath);
            
            lblMessage.Text = "课程表上传成功！";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(34, 197, 94);
            LoadCurrentSchedule();
            Response.AddHeader("Refresh", "2;URL=" + Request.Url.AbsolutePath);
        }
        catch (Exception ex)
        {
            lblMessage.Text = "上传失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
        }
    }
    
    protected void BtnDelete_Click(object sender, EventArgs e)
    {
        try
        {
            bool deleted = false;
            string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf" };
            foreach (string ext in exts)
            {
                string path = Server.MapPath("~/images/schedule" + ext);
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                    deleted = true;
                }
            }
            
            if (deleted)
            {
                lblMessage.Text = "课程表已删除";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(34, 197, 94);
                currentScheduleUrl = "";
                Response.AddHeader("Refresh", "2;URL=" + Request.Url.AbsolutePath);
            }
            else
            {
                lblMessage.Text = "没有找到课程表文件";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "删除失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
        }
    }
</script>


<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .schedule-page {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0;
        font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
    }
    
    .page-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 28px;
    }
    .page-header-left {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .page-header-icon {
        width: 48px; height: 48px;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(99,102,241,0.25);
        flex-shrink: 0;
    }
    .page-header-icon svg {
        width: 26px; height: 26px;
        stroke: #fff; fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    .page-header-text h1 {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 2px;
    }
    .page-header-text p {
        font-size: 13px;
        color: #94a3b8;
        margin: 0;
    }
    
    /* Tab navigation */
    .tab-nav {
        display: flex;
        gap: 8px;
        background: #f8fafc;
        padding: 6px;
        border-radius: 12px;
    }
    .tab-btn {
        padding: 8px 20px;
        background: transparent;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        color: #64748b;
        cursor: pointer;
        transition: all 0.2s;
    }
    .tab-btn:hover {
        background: #e0e7ff;
        color: #6366f1;
    }
    .tab-btn.active {
        background: #fff;
        color: #6366f1;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        font-weight: 600;
    }
    
    /* Tab content */
    .tab-content {
        display: none;
    }
    .tab-content.active {
        display: block;
        animation: fadeIn 0.3s ease;
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* Schedule card */
    .schedule-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        overflow: hidden;
        margin-bottom: 24px;
    }
    .schedule-card-header {
        padding: 16px 22px;
        font-size: 15px;
        font-weight: 600;
        color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .schedule-card-body {
        padding: 22px;
    }
    
    /* Editor header */
    .editor-header {
        display: flex;
        gap: 12px;
        margin-bottom: 20px;
        flex-wrap: wrap;
    }
    .editor-input {
        flex: 1;
        min-width: 200px;
        padding: 10px 14px;
        border: 1.5px solid #e2e8f0;
        border-radius: 9px;
        font-size: 13.5px;
        font-family: inherit;
        background: #f8fafc;
        transition: all 0.2s;
    }
    .editor-input:focus {
        outline: none;
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.08);
        background: #fff;
    }
    
    /* Schedule table */
    .schedule-table-wrap {
        overflow-x: auto;
        border-radius: 10px;
        border: 1px solid #e2e8f0;
    }
    .schedule-table {
        width: 100%;
        border-collapse: collapse;
        background: #fff;
        min-width: 800px;
        table-layout: fixed;
    }
    .schedule-table th,
    .schedule-table td {
        border: 1px solid #e2e8f0;
        padding: 12px;
        text-align: center;
        font-size: 13px;
        vertical-align: middle;
    }
    .schedule-table th {
        background: linear-gradient(135deg, #f8fafc, #f1f5f9);
        font-weight: 600;
        color: #475569;
        white-space: nowrap;
    }
    .schedule-table th.time-col {
        width: 140px;
        min-width: 140px;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        color: #6366f1;
        white-space: normal;
    }
    .schedule-table tbody th {
        width: 140px;
        min-width: 140px;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        color: #6366f1;
        font-weight: 600;
        white-space: normal;
        padding: 8px;
    }
    .schedule-table tbody th > div:first-child {
        font-weight: 600;
        margin-bottom: 4px;
        font-size: 13px;
    }
    .schedule-table tbody th > div:last-child {
        font-size: 11px;
        color: #94a3b8;
        font-weight: 400;
    }
    .schedule-table td {
        position: relative;
        height: 60px;
        vertical-align: middle;
        width: auto;
    }
    .schedule-table td input {
        width: 100%;
        border: none;
        background: transparent;
        text-align: center;
        font-size: 13px;
        font-family: inherit;
        padding: 8px;
        transition: all 0.2s;
    }
    .schedule-table td input:focus {
        outline: none;
        background: #f0f9ff;
        border-radius: 6px;
    }
    .schedule-table td input:not(:placeholder-shown) {
        font-weight: 500;
        color: #1e293b;
    }
    
    /* Buttons */
    .btn-primary {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        height: 40px;
        padding: 0 24px;
        background: linear-gradient(135deg, #6366f1, #7c3aed);
        color: #fff !important;
        border: none;
        border-radius: 9px;
        font-size: 13px;
        font-family: inherit;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 6px rgba(99,102,241,0.3);
    }
    .btn-primary:hover {
        box-shadow: 0 4px 14px rgba(99,102,241,0.4);
        transform: translateY(-1px);
    }
    .btn-success {
        background: linear-gradient(135deg, #22c55e, #16a34a);
        box-shadow: 0 2px 6px rgba(34,197,94,0.3);
    }
    .btn-success:hover {
        box-shadow: 0 4px 14px rgba(34,197,94,0.4);
    }
    .btn-danger {
        background: linear-gradient(135deg, #ef4444, #dc2626);
        box-shadow: 0 2px 6px rgba(239,68,68,0.3);
    }
    .btn-danger:hover {
        box-shadow: 0 4px 14px rgba(239,68,68,0.4);
    }
    
    /* Message */
    .message {
        margin-top: 14px;
        padding: 12px 16px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        min-height: 18px;
    }
    
    /* Upload area */
    .upload-row {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 16px;
    }
    .upload-row input[type="file"] {
        flex: 1;
        min-width: 200px;
        padding: 10px 14px;
        border: 1.5px solid #e2e8f0;
        border-radius: 9px;
        font-size: 13.5px;
        font-family: inherit;
        background: #f8fafc;
    }
    
    /* Info box */
    .info-box {
        background: #f0f9ff;
        border: 1px solid #bae6fd;
        border-radius: 10px;
        padding: 14px 16px;
        font-size: 12px;
        color: #0c4a6e;
        line-height: 1.7;
    }
    
    /* Schedule display */
    .schedule-display {
        margin-top: 20px;
        text-align: center;
    }
    .schedule-display img {
        max-width: 100%;
        height: auto;
        border-radius: 10px;
        box-shadow: 0 4px 16px rgba(0,0,0,0.08);
        border: 1px solid #e2e8f0;
    }
    .schedule-display iframe {
        width: 100%;
        height: 800px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
    }
    .no-schedule {
        padding: 60px 20px;
        text-align: center;
        color: #94a3b8;
    }
    .no-schedule svg {
        width: 64px;
        height: 64px;
        stroke: #cbd5e1;
        fill: none;
        stroke-width: 1.5;
        margin-bottom: 16px;
    }
    
    /* Print styles */
    @media print {
        .page-header, .tab-nav, .btn-primary, .upload-row, .info-box, .message, .period-manager {
            display: none !important;
        }
        .schedule-card {
            box-shadow: none;
            border: none;
        }
        .schedule-table {
            page-break-inside: avoid;
        }
    }
    
    /* Period Manager Inline */
    .period-manager {
        margin-top: 32px;
        padding-top: 24px;
        border-top: 2px dashed #e2e8f0;
    }
    .period-manager-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
    }
    .period-manager-header h4 {
        font-size: 16px;
        font-weight: 600;
        color: #1e293b;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .period-manager-header h4::before {
        content: '';
        width: 4px;
        height: 20px;
        background: linear-gradient(180deg, #6366f1, #8b5cf6);
        border-radius: 2px;
    }
    .btn-add-period-inline {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        background: linear-gradient(135deg, #6366f1, #7c3aed);
        color: #fff;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 6px rgba(99,102,241,0.3);
    }
    .btn-add-period-inline:hover {
        box-shadow: 0 4px 14px rgba(99,102,241,0.4);
        transform: translateY(-1px);
    }
    .btn-add-period-inline svg {
        width: 16px;
        height: 16px;
    }
    
    /* Period List Inline */
    .period-list-inline {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 16px;
    }
    
    /* Period Item Inline */
    .period-item-inline {
        position: relative;
        background: linear-gradient(135deg, #ffffff, #f8fafc);
        border-radius: 12px;
        border: 2px solid #e2e8f0;
        overflow: hidden;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .period-item-inline:hover {
        border-color: #c7d2fe;
        box-shadow: 0 4px 12px rgba(99,102,241,0.15);
        transform: translateY(-2px);
    }
    .period-item-inline::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: 4px;
        background: linear-gradient(180deg, #6366f1, #8b5cf6);
    }
    .period-item-header {
        display: flex;
        align-items: center;
        padding: 12px 16px;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        border-bottom: 1px solid #e2e8f0;
    }
    .period-item-number {
        width: 32px;
        height: 32px;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        font-weight: 700;
        font-size: 14px;
        margin-right: 12px;
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(99,102,241,0.3);
    }
    .period-item-title {
        flex: 1;
        font-weight: 600;
        font-size: 13px;
        color: #4f46e5;
    }
    .period-item-body {
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .period-input-group-inline {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .period-input-label-inline {
        font-size: 11px;
        font-weight: 600;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .period-item-inline input {
        width: 100%;
        padding: 10px 14px;
        border: 1.5px solid #e2e8f0;
        border-radius: 8px;
        font-size: 13px;
        font-family: inherit;
        background: #fff;
        transition: all 0.2s;
    }
    .period-item-inline input:focus {
        outline: none;
        border-color: #6366f1;
        box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        background: #f8fafc;
    }
    .period-item-inline input::placeholder {
        color: #cbd5e1;
    }
    .period-item-footer {
        padding: 12px 16px;
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        display: flex;
        justify-content: flex-end;
    }
    .btn-delete-inline {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: #fff;
        border: 1.5px solid #fecaca;
        border-radius: 6px;
        color: #ef4444;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-delete-inline:hover {
        background: #fef2f2;
        border-color: #ef4444;
        transform: scale(1.05);
    }
    .btn-delete-inline svg {
        width: 14px;
        height: 14px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
    }
    
    /* Empty state inline */
    .period-empty-inline {
        text-align: center;
        padding: 40px 20px;
        color: #94a3b8;
        grid-column: 1 / -1;
    }
    .period-empty-inline svg {
        width: 48px;
        height: 48px;
        stroke: #cbd5e1;
        margin-bottom: 12px;
    }
    .period-empty-inline p {
        font-size: 14px;
        margin: 0;
    }
    
    /* Modal styles */
</style>

<div class="schedule-page">
    <!-- Page header -->
    <div class="page-header">
        <div class="page-header-left">
            <div class="page-header-icon">
                <svg viewBox="0 0 24 24">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                    <line x1="16" y1="2" x2="16" y2="6"/>
                    <line x1="8" y1="2" x2="8" y2="6"/>
                    <line x1="3" y1="10" x2="21" y2="10"/>
                </svg>
            </div>
            <div class="page-header-text">
                <h1>课程表管理</h1>
                <p>在线编辑课程表或上传图片/PDF格式</p>
            </div>
        </div>
        <div class="tab-nav">
            <button type="button" class="tab-btn active" onclick="switchTab('editor')">在线编辑</button>
            <button type="button" class="tab-btn" onclick="switchTab('upload')">上传文件</button>
        </div>
    </div>
    
    <!-- Tab 1: Online Editor -->
    <div class="tab-content active" id="tab-editor">
        <div class="schedule-card">
            <div class="schedule-card-header">
                <span>课程表编辑器</span>
                <div style="display:flex;gap:8px;">
                    <button type="button" class="btn-primary btn-success" onclick="saveSchedule()">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        保存
                    </button>
                    <button type="button" class="btn-primary" onclick="window.print()">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                        打印
                    </button>
                </div>
            </div>
            <div class="schedule-card-body">
                <div class="editor-header">
                    <input type="text" id="scheduleTitle" class="editor-input" placeholder="课程表标题" value="课程表" />
                    <input type="text" id="scheduleSubtitle" class="editor-input" placeholder="学期信息" value="2026年春季学期" />
                </div>
                
                <div class="schedule-table-wrap">
                    <table class="schedule-table" id="scheduleTable">
                        <thead>
                            <tr>
                                <th class="time-col">节次/时间</th>
                                <th>星期一</th>
                                <th>星期二</th>
                                <th>星期三</th>
                                <th>星期四</th>
                                <th>星期五</th>
                            </tr>
                        </thead>
                        <tbody id="scheduleBody">
                            <!-- 动态生成 -->
                        </tbody>
                    </table>
                </div>
                
                <div class="period-manager">
                    <div class="period-manager-header">
                        <h4>节次管理</h4>
                        <button type="button" class="btn-add-period-inline" onclick="addPeriodInline()">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <line x1="12" y1="5" x2="12" y2="19"/>
                                <line x1="5" y1="12" x2="19" y2="12"/>
                            </svg>
                            添加节次
                        </button>
                    </div>
                    <div id="periodListInline" class="period-list-inline"></div>
                </div>
                
                <div class="message" id="editorMessage"></div>
            </div>
        </div>
    </div>
    
    <!-- Tab 2: Upload File -->
    <div class="tab-content" id="tab-upload">
        <div class="schedule-card">
            <div class="schedule-card-header">上传课程表文件</div>
            <div class="schedule-card-body">
                <div class="upload-row">
                    <asp:FileUpload ID="FileUploadSchedule" runat="server" />
                    <asp:Button ID="BtnUpload" runat="server" Text="上传" CssClass="btn-primary" OnClick="BtnUpload_Click" />
                    <asp:Button ID="BtnDelete" runat="server" Text="删除" CssClass="btn-primary btn-danger" OnClick="BtnDelete_Click" OnClientClick="return confirm('确定要删除当前课程表吗？');" />
                </div>
                
                <div class="info-box">
                    <strong>📌 上传说明：</strong>支持 PNG、JPG、GIF、WebP、PDF 格式，最大 10MB
                </div>
                
                <div class="message">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </div>
                
                <div class="schedule-display">
                    <% if (!string.IsNullOrEmpty(currentScheduleUrl)) { %>
                        <% if (currentScheduleUrl.ToLower().EndsWith(".pdf")) { %>
                            <iframe src="<%= currentScheduleUrl %>"></iframe>
                        <% } else { %>
                            <img src="<%= currentScheduleUrl %>" alt="课程表" />
                        <% } %>
                    <% } else { %>
                        <div class="no-schedule">
                            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <p>暂无课程表，请先上传</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
// Tab switching
function switchTab(tabName) {
    var tabs = document.querySelectorAll('.tab-content');
    var btns = document.querySelectorAll('.tab-btn');
    
    for (var i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove('active');
    }
    for (var j = 0; j < btns.length; j++) {
        btns[j].classList.remove('active');
    }
    
    document.getElementById('tab-' + tabName).classList.add('active');
    event.target.classList.add('active');
    
    try {
        localStorage.setItem('scheduleActiveTab', tabName);
    } catch(e) {}
}

// Restore tab
(function() {
    try {
        var savedTab = localStorage.getItem('scheduleActiveTab');
        if (savedTab && savedTab === 'upload') {
            switchTab('upload');
        }
    } catch(e) {}
})();

// Schedule data
var scheduleData = {
    title: '课程表',
    subtitle: '2026年春季学期',
    periods: [
        {name: '第一节', time: '08:00-08:45'},
        {name: '第二节', time: '08:55-09:40'},
        {name: '第三节', time: '10:00-10:45'},
        {name: '第四节', time: '10:55-11:40'},
        {name: '第五节', time: '14:00-14:45'},
        {name: '第六节', time: '14:55-15:40'},
        {name: '第七节', time: '15:50-16:35'}
    ],
    days: ['星期一', '星期二', '星期三', '星期四', '星期五'],
    courses: {}
};

// Load schedule
function loadSchedule() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'scheduleapi.ashx?action=load&t=' + new Date().getTime(), true);
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                scheduleData = JSON.parse(xhr.responseText);
                renderSchedule();
            } catch(e) {
                console.error('Parse error:', e);
            }
        }
    };
    xhr.send();
}


// Render schedule table
function renderSchedule() {
    var titleEl = document.getElementById('scheduleTitle');
    var subtitleEl = document.getElementById('scheduleSubtitle');
    var tbody = document.getElementById('scheduleBody');
    
    if (titleEl) titleEl.value = scheduleData.title || '课程表';
    if (subtitleEl) subtitleEl.value = scheduleData.subtitle || '2026年春季学期';
    
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    for (var i = 0; i < scheduleData.periods.length; i++) {
        var period = scheduleData.periods[i];
        var tr = document.createElement('tr');
        
        var th = document.createElement('th');
        th.className = 'time-col';
        
        // 创建节次名称div
        var nameDiv = document.createElement('div');
        nameDiv.style.fontWeight = '600';
        nameDiv.style.marginBottom = '4px';
        nameDiv.style.fontSize = '13px';
        nameDiv.textContent = period.name;
        
        // 创建时间div
        var timeDiv = document.createElement('div');
        timeDiv.style.fontSize = '11px';
        timeDiv.style.color = '#94a3b8';
        timeDiv.style.fontWeight = '400';
        timeDiv.textContent = period.time;
        
        th.appendChild(nameDiv);
        th.appendChild(timeDiv);
        tr.appendChild(th);
        
        for (var j = 0; j < scheduleData.days.length; j++) {
            var td = document.createElement('td');
            var input = document.createElement('input');
            input.type = 'text';
            input.placeholder = '点击输入';
            input.setAttribute('data-period', i);
            input.setAttribute('data-day', j);
            
            var key = i + '-' + j;
            if (scheduleData.courses[key]) {
                input.value = scheduleData.courses[key];
            }
            
            input.addEventListener('input', function() {
                var p = this.getAttribute('data-period');
                var d = this.getAttribute('data-day');
                var k = p + '-' + d;
                if (this.value.trim()) {
                    scheduleData.courses[k] = this.value.trim();
                } else {
                    delete scheduleData.courses[k];
                }
            });
            
            td.appendChild(input);
            tr.appendChild(td);
        }
        
        tbody.appendChild(tr);
    }
    
    // 同时更新节次列表
    renderPeriodListInline();
}

// Save schedule
function saveSchedule() {
    var titleEl = document.getElementById('scheduleTitle');
    var subtitleEl = document.getElementById('scheduleSubtitle');
    var msgEl = document.getElementById('editorMessage');
    
    scheduleData.title = titleEl.value.trim() || '课程表';
    scheduleData.subtitle = subtitleEl.value.trim() || '2026年春季学期';
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'scheduleapi.ashx?action=save', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var res = JSON.parse(xhr.responseText);
                if (res.success === 1) {
                    msgEl.innerHTML = '✅ ' + res.message;
                    msgEl.style.color = '#22c55e';
                    setTimeout(function() { msgEl.innerHTML = ''; }, 3000);
                } else {
                    msgEl.innerHTML = '❌ ' + res.message;
                    msgEl.style.color = '#ef4444';
                }
            } catch(e) {
                msgEl.innerHTML = '❌ 保存失败';
                msgEl.style.color = '#ef4444';
            }
        }
    };
    xhr.send('data=' + encodeURIComponent(JSON.stringify(scheduleData)));
}

// Initialize
window.addEventListener('DOMContentLoaded', function() {
    loadSchedule();
    renderPeriodListInline();
});

// Period Manager Inline
function renderPeriodListInline() {
    var listEl = document.getElementById('periodListInline');
    if (!listEl) return;
    
    listEl.innerHTML = '';
    
    if (scheduleData.periods.length === 0) {
        listEl.innerHTML = '<div class="period-empty-inline">' +
            '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">' +
            '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>' +
            '<line x1="16" y1="2" x2="16" y2="6"/>' +
            '<line x1="8" y1="2" x2="8" y2="6"/>' +
            '<line x1="3" y1="10" x2="21" y2="10"/>' +
            '</svg>' +
            '<p>暂无节次，点击上方按钮添加</p>' +
            '</div>';
        return;
    }
    
    for (var i = 0; i < scheduleData.periods.length; i++) {
        var period = scheduleData.periods[i];
        var div = document.createElement('div');
        div.className = 'period-item-inline';
        
        // Period header
        var header = document.createElement('div');
        header.className = 'period-item-header';
        
        var numberBadge = document.createElement('div');
        numberBadge.className = 'period-item-number';
        numberBadge.textContent = (i + 1);
        
        var title = document.createElement('div');
        title.className = 'period-item-title';
        title.textContent = '节次 ' + (i + 1);
        
        header.appendChild(numberBadge);
        header.appendChild(title);
        
        // Period body
        var body = document.createElement('div');
        body.className = 'period-item-body';
        
        // Name input group
        var nameGroup = document.createElement('div');
        nameGroup.className = 'period-input-group-inline';
        
        var nameLabel = document.createElement('div');
        nameLabel.className = 'period-input-label-inline';
        nameLabel.textContent = '节次名称';
        
        var nameInput = document.createElement('input');
        nameInput.type = 'text';
        nameInput.placeholder = '例如：第一节';
        nameInput.value = period.name || '';
        nameInput.setAttribute('data-index', i);
        nameInput.addEventListener('change', function() {
            var idx = parseInt(this.getAttribute('data-index'));
            scheduleData.periods[idx].name = this.value.trim();
            renderSchedule();
        });
        
        nameGroup.appendChild(nameLabel);
        nameGroup.appendChild(nameInput);
        
        // Time input group
        var timeGroup = document.createElement('div');
        timeGroup.className = 'period-input-group-inline';
        
        var timeLabel = document.createElement('div');
        timeLabel.className = 'period-input-label-inline';
        timeLabel.textContent = '上课时间';
        
        var timeInput = document.createElement('input');
        timeInput.type = 'text';
        timeInput.placeholder = '例如：08:00-08:45';
        timeInput.value = period.time || '';
        timeInput.setAttribute('data-index', i);
        timeInput.addEventListener('change', function() {
            var idx = parseInt(this.getAttribute('data-index'));
            scheduleData.periods[idx].time = this.value.trim();
            renderSchedule();
        });
        
        timeGroup.appendChild(timeLabel);
        timeGroup.appendChild(timeInput);
        
        body.appendChild(nameGroup);
        body.appendChild(timeGroup);
        
        // Period footer
        var footer = document.createElement('div');
        footer.className = 'period-item-footer';
        
        var deleteBtn = document.createElement('button');
        deleteBtn.type = 'button';
        deleteBtn.className = 'btn-delete-inline';
        deleteBtn.setAttribute('data-index', i);
        deleteBtn.innerHTML = '<svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg> 删除';
        deleteBtn.addEventListener('click', function() {
            var idx = parseInt(this.getAttribute('data-index'));
            deletePeriodInline(idx);
        });
        
        footer.appendChild(deleteBtn);
        
        // Assemble the card
        div.appendChild(header);
        div.appendChild(body);
        div.appendChild(footer);
        
        listEl.appendChild(div);
    }
}

function addPeriodInline() {
    var num = scheduleData.periods.length + 1;
    var chineseNum = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二'];
    var name = '第' + (num <= 12 ? chineseNum[num - 1] : num) + '节';
    
    scheduleData.periods.push({
        name: name,
        time: '00:00-00:00'
    });
    
    renderSchedule();
    renderPeriodListInline();
    
    var msgEl = document.getElementById('editorMessage');
    if (msgEl) {
        msgEl.innerHTML = '✅ 已添加新节次，请记得保存';
        msgEl.style.color = '#f59e0b';
        setTimeout(function() { msgEl.innerHTML = ''; }, 3000);
    }
}

function deletePeriodInline(index) {
    if (!confirm('确定要删除这个节次吗？相关的课程数据也会被删除。')) {
        return;
    }
    
    scheduleData.periods.splice(index, 1);
    
    // 清理相关课程数据
    var newCourses = {};
    for (var key in scheduleData.courses) {
        var parts = key.split('-');
        var periodIndex = parseInt(parts[0]);
        if (periodIndex < index) {
            newCourses[key] = scheduleData.courses[key];
        } else if (periodIndex > index) {
            var newKey = (periodIndex - 1) + '-' + parts[1];
            newCourses[newKey] = scheduleData.courses[key];
        }
    }
    scheduleData.courses = newCourses;
    
    renderSchedule();
    renderPeriodListInline();
    
    var msgEl = document.getElementById('editorMessage');
    if (msgEl) {
        msgEl.innerHTML = '✅ 已删除节次，请记得保存';
        msgEl.style.color = '#f59e0b';
        setTimeout(function() { msgEl.innerHTML = ''; }, 3000);
    }
}
</script>

</asp:Content>
