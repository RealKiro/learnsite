<%@ Page Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
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

    protected int ResourceId
    {
        get
        {
            int rid = 0;
            if (Request.QueryString["rid"] != null)
                int.TryParse(Request.QueryString["rid"], out rid);
            return rid;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (ResourceId == 0)
        {
            Response.Write("资源ID无效");
            Response.End();
            return;
        }

        if (!IsPostBack)
        {
            LoadResourceInfo();
            LoadChapters();
        }
    }

    protected void LoadResourceInfo()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = "SELECT ResourceName, Description FROM Files WHERE FileId = @FileId";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@FileId", ResourceId);
            
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                lblResourceName.Text = reader["ResourceName"].ToString();
                lblResourceDesc.Text = reader["Description"].ToString();
            }
            reader.Close();
        }
    }

    protected void LoadChapters()
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string sql = @"SELECT ChapterId, ChapterTitle, ChapterOrder, FilePath, 
                          Duration, Credits, IsFree, CreateTime
                          FROM ResourceChapters 
                          WHERE ResourceId = @ResourceId 
                          ORDER BY ChapterOrder, ChapterId";
            
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            da.SelectCommand.Parameters.AddWithValue("@ResourceId", ResourceId);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            rptChapters.DataSource = dt;
            rptChapters.DataBind();
            
            lblChapterCount.Text = dt.Rows.Count.ToString();
        }
    }

    protected void btnAddChapter_Click(object sender, EventArgs e)
    {
        string chapterTitle = txtChapterTitle.Text.Trim();
        if (string.IsNullOrEmpty(chapterTitle))
        {
            ShowMessage("请输入章节标题", "error");
            return;
        }

        if (!fileUploadChapter.HasFile)
        {
            ShowMessage("请上传章节文件", "error");
            return;
        }

        try
        {
            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                ShowMessage("数据库连接失败", "error");
                return;
            }

            string chapterDir = Server.MapPath("~/uploads/chapters/");
            if (!Directory.Exists(chapterDir)) Directory.CreateDirectory(chapterDir);

            string chapterExt = Path.GetExtension(fileUploadChapter.FileName);
            string chapterFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + System.Guid.NewGuid().ToString("N").Substring(0, 8) + chapterExt;
            string chapterPhysicalPath = Path.Combine(chapterDir, chapterFileName);
            fileUploadChapter.SaveAs(chapterPhysicalPath);
            string chapterRelativePath = "/uploads/chapters/" + chapterFileName;

            int chapterOrder = 0;
            int.TryParse(txtChapterOrder.Text.Trim(), out chapterOrder);
            
            int credits = 0;
            int.TryParse(txtChapterCredits.Text.Trim(), out credits);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"INSERT INTO ResourceChapters (ResourceId, ChapterTitle, ChapterOrder, FilePath, Credits, IsFree, CreateTime)
                              VALUES (@ResourceId, @ChapterTitle, @ChapterOrder, @FilePath, @Credits, @IsFree, @CreateTime)";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ResourceId", ResourceId);
                cmd.Parameters.AddWithValue("@ChapterTitle", chapterTitle);
                cmd.Parameters.AddWithValue("@ChapterOrder", chapterOrder);
                cmd.Parameters.AddWithValue("@FilePath", chapterRelativePath);
                cmd.Parameters.AddWithValue("@Credits", credits);
                cmd.Parameters.AddWithValue("@IsFree", chkIsFree.Checked);
                cmd.Parameters.AddWithValue("@CreateTime", DateTime.Now);
                
                cmd.ExecuteNonQuery();
            }

            txtChapterTitle.Text = "";
            txtChapterOrder.Text = "0";
            txtChapterCredits.Text = "0";
            chkIsFree.Checked = false;

            ShowMessage("章节添加成功！", "success");
            LoadChapters();
        }
        catch (Exception ex)
        {
            ShowMessage("添加失败：" + ex.Message, "error");
        }
    }

    protected void btnDeleteChapter_Click(object sender, EventArgs e)
    {
        System.Web.UI.WebControls.Button btn = (System.Web.UI.WebControls.Button)sender;
        string chapterId = btn.CommandArgument;

        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = "DELETE FROM ResourceChapters WHERE ChapterId = @ChapterId";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@ChapterId", chapterId);
            cmd.ExecuteNonQuery();
        }

        ShowMessage("删除成功！", "success");
        LoadChapters();
    }

    private void ShowMessage(string message, string type)
    {
        string script = string.Format("showToast('{0}', '{1}');", message.Replace("'", "\\'"), type);
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
    }

    protected string FormatDate(object date)
    {
        if (date == null || date == DBNull.Value) return "";
        DateTime dt = Convert.ToDateTime(date);
        return dt.ToString("yyyy-MM-dd HH:mm");
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<style>
    * { box-sizing: border-box; }
    .chapters-container { max-width: 1600px; margin: 0 auto; }
    
    .page-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 20px; padding: 40px; margin-bottom: 32px;
        color: white; box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
        position: relative; overflow: hidden;
    }
    .page-header::before {
        content: ''; position: absolute; top: -50%; right: -10%;
        width: 400px; height: 400px; border-radius: 50%;
        background: rgba(255,255,255,0.1);
    }
    .page-header-content { position: relative; z-index: 1; }
    .page-header h1 { 
        margin: 0 0 12px 0; font-size: 32px; font-weight: 700;
        display: flex; align-items: center; gap: 12px;
    }
    .page-header p { 
        margin: 0; opacity: 0.95; font-size: 15px;
    }
    .back-btn {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 20px; background: rgba(255,255,255,0.2);
        border: 2px solid rgba(255,255,255,0.3);
        border-radius: 12px; color: white; text-decoration: none;
        font-size: 14px; font-weight: 600; transition: all 0.3s;
        margin-top: 16px;
    }
    .back-btn:hover {
        background: rgba(255,255,255,0.3);
        border-color: rgba(255,255,255,0.5);
        transform: translateX(-4px);
    }
    .back-btn svg {
        width: 18px; height: 18px; stroke: currentColor;
    }

    .stats-bar {
        background: white; border-radius: 16px; padding: 24px 32px;
        margin-bottom: 32px; box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        display: flex; align-items: center; gap: 32px;
    }
    .stat-item {
        display: flex; align-items: center; gap: 12px;
    }
    .stat-icon {
        width: 48px; height: 48px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 24px;
    }
    .stat-info h3 {
        margin: 0 0 4px 0; font-size: 24px; font-weight: 800;
        color: #1e293b;
    }
    .stat-info p {
        margin: 0; font-size: 13px; color: #64748b; font-weight: 500;
    }

    .content-grid {
        display: grid; grid-template-columns: 1fr 400px; gap: 32px;
    }

    .chapters-list-card {
        background: white; border-radius: 20px; padding: 32px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    }
    .card-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 24px; padding-bottom: 20px;
        border-bottom: 2px solid #f1f5f9;
    }
    .card-header h2 {
        margin: 0; font-size: 20px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 10px;
    }
    .card-header h2 svg {
        width: 24px; height: 24px; stroke: #667eea;
    }

    .chapter-item {
        background: #f8fafc; border: 2px solid #e2e8f0;
        border-radius: 16px; padding: 20px 24px; margin-bottom: 16px;
        transition: all 0.3s; position: relative;
    }
    .chapter-item:hover {
        border-color: #667eea;
        box-shadow: 0 4px 16px rgba(102, 126, 234, 0.15);
        transform: translateX(4px);
    }
    .chapter-header {
        display: flex; align-items: center; gap: 16px;
        margin-bottom: 12px;
    }
    .chapter-number {
        width: 40px; height: 40px; border-radius: 10px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; display: flex; align-items: center;
        justify-content: center; font-size: 16px; font-weight: 700;
        flex-shrink: 0;
    }
    .chapter-title {
        flex: 1; font-size: 16px; font-weight: 700;
        color: #1e293b; min-width: 0;
    }
    .chapter-badges {
        display: flex; gap: 8px; flex-wrap: wrap;
    }
    .badge {
        padding: 4px 12px; border-radius: 6px;
        font-size: 12px; font-weight: 600;
        display: inline-flex; align-items: center; gap: 4px;
    }
    .badge-free {
        background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
        color: #15803d;
    }
    .badge-credits {
        background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
        color: #92400e;
    }
    .chapter-meta {
        display: flex; gap: 20px; font-size: 13px;
        color: #64748b; margin-top: 12px;
    }
    .chapter-meta-item {
        display: flex; align-items: center; gap: 6px;
    }
    .chapter-meta-item svg {
        width: 14px; height: 14px; stroke: currentColor;
    }
    .chapter-actions {
        display: flex; gap: 8px; margin-top: 12px;
    }
    .btn-action {
        padding: 8px 16px; border-radius: 8px;
        font-size: 13px; font-weight: 600;
        cursor: pointer; transition: all 0.3s;
        border: none; display: inline-flex;
        align-items: center; gap: 6px;
    }
    .btn-delete {
        background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
        color: #dc2626; border: 2px solid #fca5a5;
    }
    .btn-delete:hover {
        background: linear-gradient(135deg, #fecaca 0%, #fca5a5 100%);
        transform: translateY(-2px);
    }

    .add-chapter-card {
        background: white; border-radius: 20px; padding: 28px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        position: sticky; top: 20px;
    }
    .add-chapter-card h3 {
        margin: 0 0 20px 0; font-size: 18px; font-weight: 700;
        color: #1e293b; display: flex; align-items: center; gap: 10px;
    }
    .add-chapter-card h3 svg {
        width: 22px; height: 22px; stroke: #667eea;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-group label {
        display: block; margin-bottom: 8px; font-size: 14px;
        font-weight: 600; color: #475569;
    }
    .form-group label .required {
        color: #ef4444; margin-left: 4px;
    }
    .form-control {
        width: 100%; padding: 12px 16px; border: 2px solid #e2e8f0;
        border-radius: 10px; font-size: 14px; transition: all 0.3s;
        font-family: inherit; background: #f8fafc;
    }
    .form-control:focus {
        outline: none; border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        background: white;
    }
    .form-row {
        display: grid; grid-template-columns: 1fr 1fr; gap: 12px;
    }
    .file-upload-compact {
        border: 2px dashed #cbd5e1; border-radius: 10px;
        padding: 20px; text-align: center; background: #f8fafc;
        cursor: pointer; transition: all 0.3s;
    }
    .file-upload-compact:hover {
        border-color: #667eea; background: #f1f5f9;
    }
    .file-upload-compact-text {
        font-size: 13px; color: #64748b; font-weight: 500;
    }
    .checkbox-wrapper {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 16px; background: #f8fafc;
        border-radius: 10px; border: 2px solid #e2e8f0;
        cursor: pointer; transition: all 0.3s;
    }
    .checkbox-wrapper:hover {
        border-color: #cbd5e1; background: #f1f5f9;
    }
    .checkbox-wrapper input[type="checkbox"] {
        width: 20px; height: 20px; cursor: pointer;
        accent-color: #667eea;
    }
    .checkbox-wrapper label {
        margin: 0 !important; font-size: 14px;
        font-weight: 600; color: #475569;
        cursor: pointer; flex: 1;
    }
    .btn-add {
        width: 100%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; border: none; padding: 14px 24px;
        border-radius: 12px; font-size: 15px; font-weight: 700;
        cursor: pointer; transition: all 0.3s;
        box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
        display: flex; align-items: center; justify-content: center; gap: 8px;
    }
    .btn-add:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 24px rgba(102, 126, 234, 0.5);
    }
    .btn-add svg {
        width: 20px; height: 20px;
    }

    .empty-state {
        text-align: center; padding: 60px 20px;
        color: #94a3b8;
    }
    .empty-state-icon {
        font-size: 64px; margin-bottom: 16px;
        opacity: 0.5;
    }
    .empty-state-text {
        font-size: 16px; font-weight: 600;
    }

    .toast {
        position: fixed; top: 24px; right: 24px; background: white;
        padding: 18px 28px; border-radius: 16px;
        box-shadow: 0 12px 48px rgba(0,0,0,0.2); z-index: 10000;
        display: none; align-items: center; gap: 14px;
        animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        border-left: 4px solid;
    }
    @keyframes slideIn {
        from { transform: translateX(400px); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    .toast.success { border-left-color: #10b981; }
    .toast.error { border-left-color: #ef4444; }
    .toast-icon { font-size: 24px; }
    .toast-message { font-size: 15px; font-weight: 500; color: #1e293b; }
</style>

<div class="chapters-container">
    <div class="page-header">
        <div class="page-header-content">
            <h1>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:32px;height:32px">
                    <path d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                </svg>
                <asp:Label ID="lblResourceName" runat="server" Text="资源章节管理"></asp:Label>
            </h1>
            <p><asp:Label ID="lblResourceDesc" runat="server" Text="管理资源的各个章节内容"></asp:Label></p>
            <a href="resourcemanage.aspx" class="back-btn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
                </svg>
                返回资源管理
            </a>
        </div>
    </div>

    <div class="stats-bar">
        <div class="stat-item">
            <div class="stat-icon" style="background: linear-gradient(135deg, #dbeafe 0%, #93c5fd 100%); color: #1e40af;">
                📚
            </div>
            <div class="stat-info">
                <h3><asp:Label ID="lblChapterCount" runat="server" Text="0"></asp:Label></h3>
                <p>章节总数</p>
            </div>
        </div>
    </div>

    <div class="content-grid">
        <div class="chapters-list-card">
            <div class="card-header">
                <h2>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 6h16M4 10h16M4 14h16M4 18h16"/>
                    </svg>
                    章节列表
                </h2>
            </div>

            <asp:Repeater ID="rptChapters" runat="server">
                <ItemTemplate>
                    <div class="chapter-item">
                        <div class="chapter-header">
                            <div class="chapter-number"><%# Eval("ChapterOrder") %></div>
                            <div class="chapter-title"><%# Eval("ChapterTitle") %></div>
                        </div>
                        <div class="chapter-badges">
                            <%# Convert.ToBoolean(Eval("IsFree")) ? 
                                "<span class='badge badge-free'>🎁 免费</span>" : 
                                "<span class='badge badge-credits'>💰 " + Eval("Credits") + " 积分</span>" %>
                        </div>
                        <div class="chapter-meta">
                            <div class="chapter-meta-item">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                                <span><%# FormatDate(Eval("CreateTime")) %></span>
                            </div>
                        </div>
                        <div class="chapter-actions">
                            <asp:Button ID="btnDelete" runat="server" Text="删除" CssClass="btn-action btn-delete"
                                        CommandArgument='<%# Eval("ChapterId") %>' OnClick="btnDeleteChapter_Click"
                                        OnClientClick="return confirm('确定要删除这个章节吗？');" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:PlaceHolder ID="phEmpty" runat="server" Visible='<%# rptChapters.Items.Count == 0 %>'>
                <div class="empty-state">
                    <div class="empty-state-icon">📝</div>
                    <div class="empty-state-text">还没有添加章节，请在右侧添加</div>
                </div>
            </asp:PlaceHolder>
        </div>

        <div class="add-chapter-card">
            <h3>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 4v16m8-8H4"/>
                </svg>
                添加章节
            </h3>

            <div class="form-group">
                <label>章节标题 <span class="required">*</span></label>
                <asp:TextBox ID="txtChapterTitle" runat="server" CssClass="form-control" 
                             placeholder="例如：第1章 Python基础"></asp:TextBox>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>章节序号</label>
                    <asp:TextBox ID="txtChapterOrder" runat="server" CssClass="form-control" 
                                 Text="0" placeholder="排序"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>获得积分</label>
                    <asp:TextBox ID="txtChapterCredits" runat="server" CssClass="form-control" 
                                 Text="0" placeholder="积分"></asp:TextBox>
                </div>
            </div>

            <div class="form-group">
                <label>章节文件 <span class="required">*</span></label>
                <div class="file-upload-compact" onclick="document.getElementById('<%= fileUploadChapter.ClientID %>').click();">
                    <div class="file-upload-compact-text">📎 点击选择章节文件</div>
                </div>
                <asp:FileUpload ID="fileUploadChapter" runat="server" style="display: none;" />
            </div>

            <div class="form-group">
                <div class="checkbox-wrapper" onclick="toggleChapterCheckbox()">
                    <asp:CheckBox ID="chkIsFree" runat="server" />
                    <label>该章节免费</label>
                </div>
            </div>

            <asp:Button ID="btnAddChapter" runat="server" CssClass="btn-add" OnClick="btnAddChapter_Click" Text="添加章节" />
        </div>
    </div>
</div>

<div id="toast" class="toast">
    <span class="toast-icon" id="toastIcon"></span>
    <span class="toast-message" id="toastMessage"></span>
</div>

<script type="text/javascript">
    function showToast(message, type) {
        var toast = document.getElementById('toast');
        var icon = document.getElementById('toastIcon');
        var msg = document.getElementById('toastMessage');
        toast.className = 'toast ' + type;
        icon.textContent = type === 'success' ? '✅' : '❌';
        msg.textContent = message;
        toast.style.display = 'flex';
        setTimeout(function() { toast.style.display = 'none'; }, 3000);
    }

    function toggleChapterCheckbox() {
        var checkbox = document.getElementById('<%= chkIsFree.ClientID %>');
        if (checkbox) {
            checkbox.checked = !checkbox.checked;
        }
    }
</script>
</asp:Content>
