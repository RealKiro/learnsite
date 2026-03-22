<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    private string filePath;

    protected void Page_Load(object sender, EventArgs e)
    {
        filePath = Server.MapPath("~/App_Data/classroomrules.txt");
        if (!IsPostBack)
        {
            LoadRules();
        }
    }

    private void LoadRules()
    {
        try
        {
            if (File.Exists(filePath))
            {
                string content = File.ReadAllText(filePath, System.Text.Encoding.UTF8);
                if (content.Trim().Length > 0)
                {
                    TextBoxRules.Text = content;
                    return;
                }
            }
        }
        catch { }

        // Default rules
        TextBoxRules.Text = "无请假缺席：每人**扣1分**\n" +
            "迟到：每人**扣0.1分**\n" +
            "吃零食带饮料：每人**扣0.1分**\n" +
            "乱丢垃圾：每人**扣0.1分**且负责拖地一次\n" +
            "未经老师允许玩游戏：每人**扣0.1分**\n" +
            "带存储设备（mp3、U盘）并使用：每人**扣0.1分**\n" +
            "故意搞乱电脑硬件：**扣1分**\n" +
            "未经老师允许，私自下座位或换座位：**扣1分**";
    }

    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string dir = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            string text = TextBoxRules.Text.Trim();
            string[] lines = text.Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0; i < lines.Length; i++)
            {
                if (i > 0) sb.Append("\n");
                sb.Append(lines[i].Trim());
            }

            File.WriteAllText(filePath, sb.ToString(), System.Text.Encoding.UTF8);

            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "&#10004; 课堂守则已保存，共 " + lines.Length + " 条规则";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "保存失败: " + ex.Message;
        }
    }

    protected int GetRuleCount()
    {
        string text = TextBoxRules.Text.Trim();
        if (string.IsNullOrEmpty(text)) return 0;
        return text.Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries).Length;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cr-page { max-width: 100%; padding: 28px 32px 40px; font-family: 'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .cr-hd { display:flex; align-items:center; gap:16px; margin-bottom:28px; }
    .cr-hd-icon { width:48px; height:48px; background:linear-gradient(135deg,#f59e0b,#d97706); border-radius:14px; display:flex; align-items:center; justify-content:center; box-shadow:0 4px 12px rgba(245,158,11,.25); flex-shrink:0; }
    .cr-hd-icon svg { width:26px; height:26px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .cr-hd h1 { font-size:22px; font-weight:700; color:#0f172a; margin:0 0 2px; }
    .cr-hd p { font-size:13px; color:#94a3b8; margin:0; }

    .cr-grid { display:grid; grid-template-columns:1fr 320px; gap:20px; }
    @media (max-width:960px) { .cr-grid { grid-template-columns:1fr; } }

    .cr-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; }
    .cr-card:hover { box-shadow:0 8px 24px rgba(0,0,0,.07); }
    .cr-card-hd { padding:16px 22px; font-size:15px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:12px; }
    .cr-card-hd .ci { width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
    .cr-card-hd .ci svg { width:19px; height:19px; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; fill:none; }
    .ci.amber { background:#fffbeb; } .ci.amber svg { stroke:#f59e0b; }
    .ci.sky { background:#f0f9ff; } .ci.sky svg { stroke:#0ea5e9; }
    .ci.emerald { background:#ecfdf5; } .ci.emerald svg { stroke:#10b981; }
    .cr-card-bd { padding:22px; }

    .cr-textarea {
        width:100%; min-height:400px; padding:16px; border:1.5px solid #e2e8f0; border-radius:12px;
        font-size:14px; font-family:'Microsoft YaHei',monospace; line-height:2; color:#334155;
        background:#f8fafc; outline:none; resize:vertical;
        transition: border-color .2s, box-shadow .2s;
    }
    .cr-textarea:focus { border-color:#f59e0b; box-shadow:0 0 0 3px rgba(245,158,11,.1); background:#fff; }

    .cr-hint { font-size:12px; color:#94a3b8; margin-top:10px; line-height:1.8; }
    .cr-hint code { background:#f1f5f9; padding:1px 6px; border-radius:4px; font-size:11.5px; color:#64748b; }

    .cr-actions { padding:16px 22px; border-top:1px solid #f1f5f9; display:flex; align-items:center; gap:14px; }
    .btn-save {
        display:inline-flex; align-items:center; justify-content:center; gap:6px;
        height:40px; padding:0 28px;
        background:linear-gradient(135deg,#f59e0b,#d97706); color:#fff!important;
        border:none; border-radius:10px; font-size:14px; font-family:inherit; font-weight:600;
        cursor:pointer; transition:all .2s; box-shadow:0 2px 8px rgba(245,158,11,.3);
    }
    .btn-save:hover { box-shadow:0 4px 16px rgba(245,158,11,.4); transform:translateY(-1px); }
    .cr-msg { font-size:13px; }

    .cr-count { font-size:13px; color:#64748b; }
    .cr-count strong { color:#f59e0b; font-weight:700; }

    /* Preview section */
    .cr-preview-list { padding:0; }
    .cr-pv-item { display:flex; align-items:flex-start; gap:10px; padding:10px 12px; border-radius:10px; margin-bottom:6px; transition:all .15s; }
    .cr-pv-item:hover { background:#fffbeb; }
    .cr-pv-num { width:26px; height:26px; border-radius:8px; background:linear-gradient(135deg,#fef3c7,#fde68a); display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; color:#92400e; flex-shrink:0; }
    .cr-pv-text { font-size:13px; color:#475569; line-height:1.6; padding-top:3px; }

    /* Side panel */
    .cr-side-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:16px; }
    .cr-side-hd { padding:14px 18px; font-size:14px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:10px; }
    .cr-side-bd { padding:16px 18px; font-size:13px; color:#64748b; line-height:2; }
    .cr-side-bd li { margin-bottom:4px; }

    .cr-tip-card { background:linear-gradient(135deg,#fffbeb,#fef3c7); border:1px solid #fde68a; border-radius:14px; padding:18px; }
    .cr-tip-card h4 { font-size:14px; color:#92400e; margin:0 0 8px; display:flex; align-items:center; gap:8px; }
    .cr-tip-card p { font-size:12.5px; color:#a16207; line-height:1.8; margin:0; }
</style>

<div class="cr-page">
    <div class="cr-hd">
        <div class="cr-hd-icon"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
        <div><h1>课堂守则设置</h1><p>编辑课堂守则内容，保存后学生端将自动更新显示</p></div>
    </div>

    <div class="cr-grid">
        <!-- 左侧：编辑区 -->
        <div>
            <div class="cr-card">
                <div class="cr-card-hd">
                    <span class="ci amber"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></span>
                    编辑守则内容
                    <span class="cr-count" style="margin-left:auto;">共 <strong><%= GetRuleCount() %></strong> 条规则</span>
                </div>
                <div class="cr-card-bd">
                    <asp:TextBox ID="TextBoxRules" runat="server" TextMode="MultiLine" CssClass="cr-textarea" />
                    <div class="cr-hint">
                        每行一条守则，空行将自动忽略<br/>
                        使用 <code>**文字**</code> 标记重点内容（如扣分项），学生端将以<strong style="color:#dc2626">红色加粗</strong>显示
                    </div>
                </div>
                <div class="cr-actions">
                    <asp:Button ID="BtnSave" runat="server" Text="保存守则" CssClass="btn-save" OnClick="BtnSave_Click" />
                    <span class="cr-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></span>
                </div>
            </div>
        </div>

        <!-- 右侧：说明面板 -->
        <div>
            <div class="cr-side-card">
                <div class="cr-side-hd">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    编辑说明
                </div>
                <div class="cr-side-bd">
                    <ul style="padding-left:16px;">
                        <li>每行输入一条守则规则</li>
                        <li>保存后学生端 <strong>课堂守则</strong> 页面会自动更新</li>
                        <li>用 <code style="background:#f1f5f9;padding:1px 6px;border-radius:3px;font-size:12px;">**扣1分**</code> 标记重点</li>
                        <li>修改即时生效，无需重启</li>
                    </ul>
                </div>
            </div>

            <div class="cr-tip-card">
                <h4>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#92400e" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    温馨提示
                </h4>
                <p>守则内容将展示在学生登录后的"课堂守则"页面中。建议规则简洁明了，扣分标准清晰，方便学生理解和遵守。</p>
            </div>
        </div>
    </div>
</div>
</asp:Content>
