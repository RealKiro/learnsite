<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_worknoscore, LearnSite" %>

<script runat="server">
    private string WnsGetConnStr()
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

    /// <summary>
    /// 评分后同步学生学分：根据 Labelnum (学号) 更新该学生的 Sscore
    /// </summary>
    private void SyncCurrentStudentScore()
    {
        string snum = Labelnum != null ? Labelnum.Text.Trim() : "";
        if (string.IsNullOrEmpty(snum)) return;
        string cs = WnsGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = @"UPDATE Students SET Sscore = ISNULL((
                    SELECT SUM(ISNULL(w.Wscore,0) + ISNULL(w.Wdscore,0))
                    FROM Works w WHERE w.Wnum = Students.Snum AND w.Wscore > 0
                ), 0) WHERE Snum=@snum";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@snum", snum);
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
        // 每次 PostBack（评分操作）后同步该学生学分
        if (IsPostBack)
        {
            SyncCurrentStudentScore();
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .wns-page { max-width: 1000px; width: 96%; margin: 0 auto; padding: 10px 0; }

    /* === 页面头部 === */
    .wns-header {
        display: flex; align-items: center; gap: 20px;
        margin-bottom: 24px; padding: 24px 28px;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%);
        border-radius: 16px; position: relative; overflow: hidden;
        box-shadow: 0 8px 30px rgba(99,102,241,0.25);
    }
    .wns-header::before {
        content: ''; position: absolute; top: -50%; right: -10%;
        width: 300px; height: 300px; border-radius: 50%;
        background: rgba(255,255,255,0.06);
    }
    .wns-header-icon {
        width: 48px; height: 48px; background: rgba(255,255,255,0.2);
        backdrop-filter: blur(8px); border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        position: relative; z-index: 1;
    }
    .wns-header-icon svg { width: 24px; height: 24px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .wns-header-info { position: relative; z-index: 1; flex: 1; }
    .wns-header-title { font-size: 20px; font-weight: 800; color: #fff; margin-bottom: 4px; }
    .wns-header-sub { font-size: 13px; color: rgba(255,255,255,0.75); }

    /* === 卡片 === */
    .wns-card {
        background: #fff; border-radius: 16px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.05);
        overflow: hidden; margin-bottom: 20px;
    }

    /* === 导航栏 === */
    .wns-nav {
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9;
        background: linear-gradient(135deg, #fafbfc, #f8fafc);
    }
    .wns-nav-label {
        font-size: 14px; font-weight: 700; color: #334155;
        display: flex; align-items: center; gap: 8px;
    }
    .wns-nav-label svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .wns-nav select {
        height: 38px; padding: 0 14px; border-radius: 10px;
        border: 1.5px solid #e2e8f0; background: #fff; font-size: 14px;
        color: #334155; font-weight: 600; outline: none; cursor: pointer;
        transition: all 0.2s;
    }
    .wns-nav select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.12); }
    .wns-nav-arrow {
        display: inline-flex; align-items: center; justify-content: center;
        width: 36px; height: 36px; border-radius: 10px;
        border: 1.5px solid #e2e8f0; background: #fff;
        cursor: pointer; transition: all 0.2s;
    }
    .wns-nav-arrow:hover {
        border-color: #6366f1; background: #eef2ff;
        box-shadow: 0 2px 8px rgba(99,102,241,0.12);
    }
    .wns-nav-arrow input[type="image"] { width: 16px; height: 16px; }
    .wns-badge {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 5px 14px; background: #eef2ff; border: 1px solid #c7d2fe;
        border-radius: 20px; font-size: 13px; color: #4f46e5; font-weight: 600;
    }

    /* === 评分区域 === */
    .wns-score-panel {
        padding: 20px 24px;
        background: linear-gradient(135deg, #f8f9ff 0%, #eef2ff 100%);
        border-bottom: 1px solid #e0e7ff;
    }
    .wns-score-row {
        display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
    }
    .wns-score-field {
        display: flex; align-items: center; gap: 8px;
    }
    .wns-score-field .wns-field-label {
        font-size: 13px; font-weight: 600; color: #475569;
        display: flex; align-items: center; gap: 5px; white-space: nowrap;
    }
    .wns-score-field .wns-field-label svg {
        width: 16px; height: 16px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .wns-score-field input[type="text"] {
        height: 38px; border-radius: 10px; border: 1.5px solid #c7d2fe;
        background: #fff; color: #4f46e5; font-size: 15px; font-weight: 700;
        padding: 0 14px; outline: none; text-align: center;
        transition: all 0.2s;
    }
    .wns-score-field input[type="text"]:focus {
        border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.15);
    }

    /* === 评分按钮组 === */
    .wns-grade-group {
        display: flex; align-items: center; gap: 0;
        background: #ffffff; border: 2px solid #e0e7ff; border-radius: 14px;
        padding: 4px; box-shadow: 0 2px 8px rgba(99,102,241,0.08);
    }
    .wns-grade-group label {
        display: inline-flex !important; align-items: center; justify-content: center;
        cursor: pointer; white-space: nowrap;
        background: transparent; border: none; border-radius: 10px;
        padding: 10px 18px; font-size: 16px; color: #64748b; font-weight: 700;
        transition: all 0.25s ease; user-select: none; margin: 0;
        position: relative; min-width: 48px;
    }
    .wns-grade-group label:not(:last-child)::after {
        content: ''; position: absolute; right: 0; top: 50%;
        transform: translateY(-50%); width: 1px; height: 60%;
        background: #e0e7ff;
    }
    .wns-grade-group label:hover { background: #f5f3ff; color: #4338ca; }
    .wns-grade-group input[type="radio"] { display: none !important; }
    .wns-grade-group label:has(input[type="radio"]:checked) {
        background: linear-gradient(135deg, #6366f1, #7c3aed) !important;
        color: #fff !important; font-weight: 800;
        box-shadow: 0 4px 14px rgba(99,102,241,0.3);
    }
    .wns-grade-group label:has(input[type="radio"]:checked)::after { display: none; }

    /* === 工具栏 === */
    .wns-tools {
        display: flex; align-items: center; gap: 10px;
        padding: 12px 24px; border-bottom: 1px solid #f1f5f9;
    }
    .wns-tools .wns-refresh {
        display: inline-flex; align-items: center; justify-content: center;
        width: 34px; height: 34px; border-radius: 8px;
        border: 1.5px solid #e2e8f0; background: #f8fafc;
        cursor: pointer; transition: all 0.2s;
    }
    .wns-tools .wns-refresh:hover {
        border-color: #818cf8; background: #eef2ff;
        box-shadow: 0 2px 8px rgba(99,102,241,0.12);
    }
    .wns-tools .wns-refresh input[type="image"] { width: 16px; height: 16px; }
    .wns-count-badge {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 4px 12px; background: #f0fdf4; border-radius: 16px;
        border: 1px solid #bbf7d0; font-size: 12px; color: #16a34a; font-weight: 600;
    }

    /* === 作品预览区域 === */
    .wns-preview {
        padding: 24px; min-height: 200px;
    }
    .wns-preview-content {
        font-size: 14px; color: #334155; line-height: 1.8;
    }
    .wns-preview-content img { max-width: 100%; border-radius: 8px; }
    .wns-preview-content iframe {
        max-width: 100%; border-radius: 8px;
        border: 1px solid #e2e8f0;
    }

    /* === 底部操作 === */
    .wns-footer {
        display: flex; align-items: center; gap: 12px;
        padding: 16px 24px; border-top: 1px solid #f1f5f9;
        background: #fafbfc;
    }
    .wns-footer .wns-code-link {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 10px;
        background: #eef2ff; color: #4f46e5;
        font-size: 13px; font-weight: 600;
        text-decoration: none; transition: all 0.2s;
        border: 1px solid #c7d2fe;
    }
    .wns-footer .wns-code-link:hover {
        background: #e0e7ff; color: #4338ca;
        box-shadow: 0 2px 8px rgba(99,102,241,0.12);
    }
    .wns-footer input[type="submit"] {
        height: 38px; padding: 0 20px; border-radius: 10px;
        border: 1.5px solid #e2e8f0; background: #fff; color: #64748b;
        font-size: 13px; font-weight: 600; cursor: pointer;
        transition: all 0.2s;
    }
    .wns-footer input[type="submit"]:hover {
        background: #f1f5f9; color: #334155;
        border-color: #cbd5e1;
    }

    /* 隐藏元素 */
    .wns-hidden { display: none !important; }
</style>

<div class="wns-page">
    <!-- 页面头部 -->
    <div class="wns-header">
        <div class="wns-header-icon">
            <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        </div>
        <div class="wns-header-info">
            <div class="wns-header-title">
                <asp:Label ID="LabeCtitle" runat="server" Font-Bold="True"></asp:Label>
                <asp:DropDownList ID="DDLclass" runat="server" Font-Size="9pt" Width="50px" AutoPostBack="True"
                    onselectedindexchanged="DDLclass_SelectedIndexChanged" Font-Bold="True" Height="24px"
                    style="height:32px;border-radius:8px;border:1px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.88);color:#312e81;font-size:13px;font-weight:600;padding:0 8px;">
                </asp:DropDownList>
                班 未评作品
            </div>
            <div class="wns-header-sub">
                <asp:Label ID="LabelMtitle" runat="server" Font-Bold="True"></asp:Label>
            </div>
        </div>
    </div>

    <!-- 主卡片 -->
    <div class="wns-card">
        <!-- 作品导航 -->
        <div class="wns-nav">
            <span class="wns-nav-label">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                作品选择
            </span>
            <span class="wns-nav-arrow">
                <asp:ImageButton ID="ImgBtnLeft" runat="server" ImageUrl="~/images/left.png"
                    onclick="ImgBtnLeft_Click" Width="16px" />
            </span>
            <asp:DropDownList ID="DDLstore" runat="server"
                Font-Bold="True" Width="200px" AutoPostBack="True" Font-Size="12pt"
                onselectedindexchanged="DDLstore_SelectedIndexChanged">
                <asp:ListItem></asp:ListItem>
            </asp:DropDownList>
            <span class="wns-nav-arrow">
                <asp:ImageButton ID="ImgBtnright" runat="server"
                    ImageUrl="~/images/right.png" onclick="ImgBtnright_Click" />
            </span>
            <asp:Label ID="lbcurindex" runat="server" Text="0" Visible="False"></asp:Label>
            <asp:Label ID="LabelMid" runat="server" Font-Names="Arial" Font-Size="9pt" Visible="False"></asp:Label>
            <asp:Label ID="Labelnum" runat="server" Font-Names="Arial" Font-Size="9pt" Visible="False"></asp:Label>
        </div>

        <!-- 评分面板 -->
        <div class="wns-score-panel">
            <div class="wns-score-row">
                <div class="wns-score-field">
                    <span class="wns-field-label">
                        <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                        评语
                    </span>
                    <asp:TextBox ID="TextBoxWself" runat="server" Width="220px"
                        ToolTip="少于80个汉字，超过自动裁剪。"
                        style="height:38px;border-radius:10px;border:1.5px solid #c7d2fe;background:#fff;color:#334155;font-size:13px;padding:0 14px;outline:none;"></asp:TextBox>
                </div>
                <div class="wns-score-field">
                    <span class="wns-field-label">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>
                        加分
                    </span>
                    <asp:TextBox ID="TextBoxWdsocre" runat="server" MaxLength="2" Width="50px"
                        SkinID="TextBoxNum"
                        style="height:38px;border-radius:10px;border:1.5px solid #c7d2fe;background:#fff;color:#4f46e5;font-size:15px;font-weight:700;padding:0 14px;text-align:center;outline:none;">0</asp:TextBox>
                </div>
                <div class="wns-grade-group">
                    <asp:RadioButtonList ID="RBLselect" runat="server" RepeatDirection="Horizontal" Visible="True"
                        AutoPostBack="True" onselectedindexchanged="RBLselect_SelectedIndexChanged"
                        RepeatLayout="Flow">
                        <Items>
                            <asp:ListItem>G</asp:ListItem>
                            <asp:ListItem>A</asp:ListItem>
                            <asp:ListItem>B</asp:ListItem>
                            <asp:ListItem>C</asp:ListItem>
                            <asp:ListItem>D</asp:ListItem>
                            <asp:ListItem>E</asp:ListItem>
                            <asp:ListItem>O</asp:ListItem>
                        </Items>
                    </asp:RadioButtonList>
                </div>
            </div>
        </div>

        <!-- 工具栏 -->
        <div class="wns-tools">
            <span class="wns-refresh">
                <asp:ImageButton ID="ImgBtn" runat="server" ImageUrl="~/images/refresh.gif"
                    onclick="ImgBtn_Click" ToolTip="循环展播专用刷新" />
            </span>
            <span class="wns-count-badge">
                <asp:Label ID="lbcount" runat="server"></asp:Label>
            </span>
        </div>

        <!-- 作品预览 -->
        <div class="wns-preview">
            <div class="wns-preview-content">
                <asp:Literal ID="Literal1" runat="server"></asp:Literal>
            </div>
        </div>

        <!-- 底部操作 -->
        <div class="wns-footer">
            <asp:HyperLink ID="Hlcode" runat="server" Font-Size="11pt" Target="_blank"
                Visible="False" CssClass="wns-code-link">查看脚本</asp:HyperLink>
            <asp:Button ID="Btnback" runat="server" Text="← 返回"
                OnClick="Btnback_Click" SkinID="BtnSmall" />
        </div>
    </div>

    <!-- 隐藏的原始控件（保持兼容） -->
    <asp:Image ID="Image1" runat="server" ImageUrl="~/images/peer_review.png" style="display:none" />
    <asp:Image ID="Image2" runat="server" ImageUrl="~/images/token.png" style="display:none" />
</div>
</asp:Content>

