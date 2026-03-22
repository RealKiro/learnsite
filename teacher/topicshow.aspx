<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_topicshow, LearnSite" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        // 讨论类型（Ltype=13）应直接跳转到学生端讨论页面
        if (!IsPostBack)
        {
            try
            {
                string lid = Request.QueryString["lid"];
                if (!string.IsNullOrEmpty(lid))
                {
                    string connStr = null;
                    try { connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
                    if (string.IsNullOrEmpty(connStr))
                    {
                        try { connStr = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString; } catch { }
                    }
                    
                    if (!string.IsNullOrEmpty(connStr))
                    {
                        using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
                        {
                            conn.Open();
                            string sql = "SELECT Ltype, Lcid FROM Listmenu WHERE Lid = @Lid";
                            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                            {
                                cmd.Parameters.AddWithValue("@Lid", lid);
                                cmd.CommandTimeout = 5;
                                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                                        string lcid = reader["Lcid"] != DBNull.Value ? reader["Lcid"].ToString() : "";
                                        
                                        if (ltype == "13" || ltype == "讨论")
                                        {
                                            string cid = !string.IsNullOrEmpty(lcid) ? lcid : (Request.QueryString["mcid"] ?? "");
                                            string url = !string.IsNullOrEmpty(cid)
                                                ? string.Format("../student/topicdiscuss.aspx?lid={0}&cid={1}", Server.UrlEncode(lid), Server.UrlEncode(cid))
                                                : string.Format("../student/topicdiscuss.aspx?lid={0}", Server.UrlEncode(lid));
                                            Response.Redirect(url, false);
                                            Context.ApplicationInstance.CompleteRequest();
                                            return;
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
        
        base.OnLoad(e);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<style>
    /* ===== 主题讨论展示页面 (参照 topicadd) ===== */
    .ts-container {
        max-width: 1440px !important;
        width: 100% !important;
        margin: 0 auto !important;
        padding: 0 !important;
        font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important;
        animation: tsFadeIn 0.5s ease;
    }
    
    @keyframes tsFadeIn {
        from { opacity: 0; transform: translateY(12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* ===== 渐变标题栏 (绿色主题) ===== */
    .ts-title-card {
        display: flex !important;
        align-items: center !important;
        gap: 20px !important;
        margin-bottom: 28px !important;
        padding: 28px 32px !important;
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%) !important;
        border-radius: 16px !important;
        position: relative !important;
        overflow: hidden !important;
        box-shadow: 0 4px 20px rgba(5,150,105,.25) !important;
    }
    
    .ts-title-card::before {
        content: '' !important;
        position: absolute !important;
        top: -30px !important;
        right: -30px !important;
        width: 120px !important;
        height: 120px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.08) !important;
    }
    
    .ts-title-card::after {
        content: '' !important;
        position: absolute !important;
        bottom: -40px !important;
        right: 60px !important;
        width: 160px !important;
        height: 160px !important;
        border-radius: 50% !important;
        background: rgba(255,255,255,.05) !important;
    }
    
    .ts-title-icon {
        width: 52px !important;
        height: 52px !important;
        background: rgba(255,255,255,.18) !important;
        border-radius: 14px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        backdrop-filter: blur(10px) !important;
        flex-shrink: 0 !important;
        position: relative !important;
        z-index: 1 !important;
    }
    
    .ts-title-icon svg {
        width: 26px !important;
        height: 26px !important;
        stroke: #fff !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .ts-title-text {
        position: relative !important;
        z-index: 1 !important;
        flex: 1 !important;
    }
    
    .ts-title {
        font-size: 22px !important;
        font-weight: 700 !important;
        color: #fff !important;
        margin: 0 0 4px 0 !important;
        line-height: 1.3 !important;
    }
    
    .ts-title-sub {
        font-size: 13px !important;
        color: rgba(255,255,255,.75) !important;
        margin: 0 !important;
    }
    
    /* ===== 信息卡片 ===== */
    .ts-info-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
        transition: box-shadow .2s, transform .2s !important;
    }
    
    .ts-info-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
        transform: translateY(-1px) !important;
    }
    
    .ts-card-head {
        padding: 16px 24px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        display: flex !important;
        align-items: center !important;
        gap: 10px !important;
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%) !important;
    }
    
    .ts-card-head .ts-dot {
        width: 8px !important;
        height: 8px !important;
        border-radius: 50% !important;
        background: linear-gradient(135deg, #059669, #34d399) !important;
        flex-shrink: 0 !important;
    }
    
    .ts-card-head h3 {
        font-size: 15px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        margin: 0 !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        flex: 1 !important;
    }
    
    .ts-card-head h3 svg {
        width: 18px !important;
        height: 18px !important;
        stroke: #059669 !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    .ts-card-body {
        padding: 24px 28px !important;
    }
    
    .ts-info-grid {
        display: flex !important;
        align-items: stretch !important;
        gap: 24px !important;
        margin-bottom: 0 !important;
        flex-wrap: wrap !important;
    }
    
    .ts-info-item {
        flex: 1 !important;
        min-width: 200px !important;
        display: flex !important;
        flex-direction: column !important;
        gap: 12px !important;
        padding: 20px !important;
        background: #f9fafb !important;
        border-radius: 10px !important;
        border: 1px solid #e5e7eb !important;
        transition: all 0.2s ease !important;
    }
    
    .ts-info-item:hover {
        border-color: #10b981 !important;
        box-shadow: 0 4px 12px rgba(16,185,129,0.1) !important;
        background: #f0fdf4 !important;
    }
    
    .ts-info-icon {
        width: 48px !important;
        height: 48px !important;
        border-radius: 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        flex-shrink: 0 !important;
        transition: all 0.2s ease !important;
    }
    
    .ts-info-icon.date {
        background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important;
    }
    
    .ts-info-icon.course {
        background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important;
    }
    
    .ts-info-icon svg {
        width: 24px !important;
        height: 24px !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
        fill: none !important;
    }
    
    .ts-info-icon.date svg { stroke: #2563eb !important; }
    .ts-info-icon.course svg { stroke: #059669 !important; }
    
    .ts-info-content {
        flex: 1 !important;
    }
    
    .ts-info-label {
        font-size: 12px !important;
        color: #64748b !important;
        font-weight: 600 !important;
        margin-bottom: 6px !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    
    .ts-info-value {
        font-size: 18px !important;
        color: #1e293b !important;
        font-weight: 700 !important;
    }
    
    /* ===== 操作按钮 ===== */
    .ts-actions {
        display: flex !important;
        align-items: center !important;
        gap: 12px !important;
        padding-top: 20px !important;
        border-top: 1px solid #f1f5f9 !important;
        margin-top: 20px !important;
    }
    
    .ts-btn {
        position: relative !important;
        padding: 10px 28px !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        text-decoration: none !important;
        transition: all 0.2s ease !important;
        border: 1.5px solid #e2e8f0 !important;
        background: #fff !important;
        color: #475569 !important;
        cursor: pointer !important;
        text-indent: 0 !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
    }
    
    .ts-btn:hover {
        background: #f8fafc !important;
        border-color: #cbd5e1 !important;
        transform: translateY(-1px) !important;
    }
    
    .ts-btn-primary {
        background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
        color: #fff !important;
        border-color: transparent !important;
        box-shadow: 0 3px 12px rgba(5,150,105,.25) !important;
    }
    
    .ts-btn-primary:hover {
        background: linear-gradient(135deg, #047857 0%, #059669 100%) !important;
        box-shadow: 0 6px 20px rgba(5,150,105,.35) !important;
        transform: translateY(-1px) !important;
        color: #fff !important;
    }
    
    /* ===== 内容卡片 ===== */
    .ts-content-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        padding: 44px !important;
        margin-bottom: 24px !important;
        transition: all 0.3s ease;
        position: relative;
    }
    
    .ts-content-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #10b981, #34d399);
        border-radius: 14px 14px 0 0;
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .ts-content-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,0.08), 0 8px 24px rgba(0,0,0,0.04) !important;
    }
    
    .ts-content-card:hover::before {
        opacity: 1;
    }
    
    .ts-content {
        font-size: 16px !important;
        color: #334155 !important;
        line-height: 1.9 !important;
    }
    
    /* 内容排版优化 */
    .ts-content h1,
    .ts-content h2,
    .ts-content h3,
    .ts-content h4,
    .ts-content h5,
    .ts-content h6 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 20px;
        line-height: 1.3;
        padding-left: 20px;
        border-left: 5px solid #10b981;
        position: relative;
    }
    
    .ts-content h1::before,
    .ts-content h2::before,
    .ts-content h3::before {
        content: '';
        position: absolute;
        left: -5px;
        top: 0;
        bottom: 0;
        width: 5px;
        background: linear-gradient(180deg, #10b981, #34d399);
        border-radius: 0 3px 3px 0;
    }
    
    .ts-content h1 { font-size: 34px; border-left-width: 6px; }
    .ts-content h2 { font-size: 28px; }
    .ts-content h3 { font-size: 24px; }
    .ts-content h4 { font-size: 20px; border-left-width: 4px; }
    
    .ts-content p {
        margin-bottom: 18px;
        line-height: 1.9;
    }
    
    .ts-content ul,
    .ts-content ol {
        margin: 20px 0;
        padding-left: 32px;
    }
    
    .ts-content li {
        margin-bottom: 10px;
        line-height: 1.9;
        position: relative;
    }
    
    .ts-content ul li::marker {
        color: #10b981;
        font-size: 1.2em;
    }
    
    .ts-content ol li::marker {
        color: #10b981;
        font-weight: 700;
    }
    
    .ts-content img {
        max-width: 100%;
        height: auto;
        border-radius: 14px;
        box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        margin: 32px 0;
        transition: all 0.4s ease;
        display: block;
        border: 3px solid #f1f5f9;
    }
    
    .ts-content img:hover {
        box-shadow: 0 12px 32px rgba(0,0,0,0.15);
        transform: translateY(-4px) scale(1.01);
        border-color: #10b981;
    }
    
    .ts-content a {
        color: #10b981;
        text-decoration: none;
        border-bottom: 1px solid transparent;
        transition: all 0.2s ease;
    }
    
    .ts-content a:hover {
        color: #059669;
        border-bottom-color: #10b981;
    }
    
    .ts-content code {
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #92400e;
        padding: 3px 10px;
        border-radius: 6px;
        font-size: 14px;
        font-family: 'Consolas', 'Monaco', monospace;
        font-weight: 600;
        border: 1px solid #fde68a;
    }
    
    .ts-content pre {
        background: linear-gradient(135deg, #1e293b, #334155);
        color: #e2e8f0;
        padding: 24px;
        border-radius: 14px;
        overflow-x: auto;
        margin: 32px 0;
        box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        border: 1px solid #475569;
        position: relative;
    }
    
    .ts-content pre::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #10b981, #34d399, #6ee7b7);
        border-radius: 14px 14px 0 0;
    }
    
    .ts-content pre code {
        background: transparent;
        color: inherit;
        padding: 0;
        font-size: 14px;
        border: none;
    }
    
    /* ===== 底部返回按钮 ===== */
    .ts-footer {
        text-align: center !important;
        padding: 24px 0 !important;
    }
    
    .ts-footer-btn {
        display: inline-flex !important;
        align-items: center !important;
        gap: 10px !important;
        padding: 16px 42px !important;
        background: linear-gradient(135deg, #10b981, #059669) !important;
        color: #ffffff !important;
        border: none !important;
        border-radius: 14px !important;
        font-size: 16px !important;
        font-weight: 700 !important;
        text-decoration: none !important;
        cursor: pointer !important;
        transition: all 0.3s ease !important;
        box-shadow: 0 6px 20px rgba(16,185,129,0.35) !important;
        position: relative;
        overflow: hidden;
        font-family: 'Microsoft YaHei', sans-serif !important;
    }
    
    .ts-footer-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .ts-footer-btn:hover::before {
        left: 100%;
    }
    
    .ts-footer-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 32px rgba(16,185,129,0.45) !important;
        color: #ffffff !important;
        background: linear-gradient(135deg, #059669, #047857) !important;
    }
    
    .ts-footer-btn:active {
        transform: translateY(-1px);
    }
    
    /* ===== 响应式设计 ===== */
    @media (max-width: 768px) {
        .ts-container {
            padding: 20px 16px !important;
        }
        
        .ts-title-card,
        .ts-info-card,
        .ts-content-card {
            padding: 28px 24px !important;
            border-radius: 16px !important;
        }
        
        .ts-title {
            font-size: 24px !important;
        }
        
        .ts-info-grid {
            grid-template-columns: 1fr !important;
        }
        
        .ts-actions {
            flex-direction: column !important;
        }
        
        .ts-btn {
            width: 100% !important;
            text-align: center !important;
        }
        
        .ts-footer-btn {
            width: 100% !important;
            justify-content: center !important;
        }
    }
    
    /* ===== 查看讨论按钮 ===== */
    .ts-btn-discuss {
        display: inline-flex !important;
        align-items: center !important;
        gap: 8px !important;
        padding: 10px 24px !important;
        background: linear-gradient(135deg, #2563eb 0%, #3b82f6 100%) !important;
        color: #fff !important;
        border: none !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        text-decoration: none !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        box-shadow: 0 3px 12px rgba(37,99,235,.25) !important;
        font-family: 'Microsoft YaHei', sans-serif !important;
    }
    
    .ts-btn-discuss:hover {
        background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%) !important;
        box-shadow: 0 6px 20px rgba(37,99,235,.35) !important;
        transform: translateY(-1px) !important;
        color: #fff !important;
    }
    
    .ts-btn-discuss svg {
        width: 16px !important;
        height: 16px !important;
        stroke: #fff !important;
        fill: none !important;
        stroke-width: 2 !important;
        stroke-linecap: round !important;
        stroke-linejoin: round !important;
    }
    
    /* ===== 隐藏旧样式元素 ===== */
    .courseshow {
        display: none !important;
    }
</style>

<script type="text/javascript">
    // 页面加载后美化按钮
    window.onload = function() {
        // 时钟按钮
        var btnClock = document.getElementById('<%= Btnclock.ClientID %>');
        if (btnClock) {
            btnClock.value = '计时管理';
            btnClock.style.width = 'auto';
            btnClock.style.height = 'auto';
        }
        
        // 编辑按钮
        var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
        if (btnEdit) {
            btnEdit.value = '修改主题';
            btnEdit.style.width = 'auto';
            btnEdit.style.height = 'auto';
        }
    };
</script>

<div class="ts-container">
    <!-- 渐变标题栏 -->
    <div class="ts-title-card">
        <div class="ts-title-icon">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </div>
        <div class="ts-title-text">
            <h1 class="ts-title"><asp:Label ID="LabelTtitle" runat="server"></asp:Label></h1>
            <p class="ts-title-sub">查看主题讨论详情，参与课堂交流与讨论</p>
        </div>
    </div>
    
    <!-- 信息卡片 -->
    <div class="ts-info-card">
        <div class="ts-card-head">
            <span class="ts-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                基本信息
            </h3>
        </div>
        <div class="ts-card-body">
            <div class="ts-info-grid">
            <!-- 日期 -->
            <div class="ts-info-item">
                <div class="ts-info-icon date">
                    <svg viewBox="0 0 24 24">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8" y1="2" x2="8" y2="6"/>
                        <line x1="3" y1="10" x2="21" y2="10"/>
                    </svg>
                </div>
                <div class="ts-info-content">
                    <div class="ts-info-label">日期</div>
                    <div class="ts-info-value">
                        <asp:Label ID="LabelTdate" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
            
            <!-- 学案编号 -->
            <div class="ts-info-item">
                <div class="ts-info-icon course">
                    <svg viewBox="0 0 24 24">
                        <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>
                        <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
                    </svg>
                </div>
                <div class="ts-info-content">
                    <div class="ts-info-label">学案编号</div>
                    <div class="ts-info-value">
                        <asp:Label ID="LabelMcid" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="ts-actions">
                <asp:ImageButton ID="Btnclock" runat="server" 
                    ImageUrl="~/images/clock.gif" 
                    onclick="Btnclock_Click"
                    CssClass="ts-btn"
                    AlternateText="计时管理" />
                <asp:ImageButton ID="BtnEdit" runat="server" 
                    ToolTip="点击修改" 
                    ImageUrl="~/images/edit.gif" 
                    onclick="BtnEdit_Click"
                    CssClass="ts-btn ts-btn-primary"
                    AlternateText="修改主题" />
                <a href="../student/topicdiscuss.aspx?lid=<%= Server.UrlEncode(Request.QueryString["lid"] ?? "") %>&cid=<%= Server.UrlEncode(Request.QueryString["mcid"] ?? "") %>" class="ts-btn-discuss">
                    <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    查看讨论
                </a>
            </div>
        </div>
    </div>
    
    <!-- 内容卡片 -->
    <div class="ts-content-card">
        <div id="Tcontent" class="ts-content" runat="server"></div>
    </div>
    
    <!-- 底部返回按钮 -->
    <div class="ts-footer">
        <asp:Button ID="Btnreturn" runat="server" 
            Text="返回学案" 
            OnClick="Btnreturn_Click" 
            CssClass="ts-footer-btn" />
    </div>
    
    <!-- 隐藏字段 -->
    <asp:Label ID="Labeltid" runat="server" Visible="false"></asp:Label>
</div>

<!-- 原始内容（隐藏） -->
<div class="courseshow" style="display: none;">
    <br />
    <asp:ImageButton ID="Btnclock_old" runat="server" ImageUrl="~/images/clock.gif" 
        onclick="Btnclock_Click" />       
    <asp:Label ID="Labeltid_old" runat="server" Visible="false"></asp:Label>
    主题讨论名称：<asp:Label ID="LabelTtitle_old" runat="server"></asp:Label>
    <br /><br />
    <div>
        &nbsp;&nbsp;日期：
        <asp:Label ID="LabelTdate_old" runat="server"></asp:Label>
        &nbsp;&nbsp;学案编号：
        <asp:Label ID="LabelMcid_old" runat="server"></asp:Label>
        &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="BtnEdit_old" runat="server" ToolTip="点击修改" 
            ImageUrl="~/images/edit.gif" onclick="BtnEdit_Click" 
            style="width: 16px" />
    </div>   
    <div id="Tcontent_old" class="coursecontent" runat="server"></div>
    <br />
    <br />
    <asp:Button ID="Btnreturn_old" runat="server" Text="返回" OnClick="Btnreturn_Click" SkinID="BtnNormal" />
</div> 
<br />

</asp:Content>
