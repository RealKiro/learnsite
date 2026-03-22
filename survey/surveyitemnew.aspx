<%@ Page Title="" Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myQid = 0;
    protected int myVid = 0;
    protected int myCid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";
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

    protected void Page_Load(object sender, EventArgs e)
    {
        // 获取URL参数
        if (!string.IsNullOrEmpty(Request.QueryString["qid"]))
            int.TryParse(Request.QueryString["qid"], out myQid);
        if (!string.IsNullOrEmpty(Request.QueryString["qvid"]))
            int.TryParse(Request.QueryString["qvid"], out myVid);
        if (!string.IsNullOrEmpty(Request.QueryString["qcid"]))
            int.TryParse(Request.QueryString["qcid"], out myCid);

        if (!IsPostBack)
        {
            LoadQuestionTitle();
            BindItems();
        }
    }

    private void LoadQuestionTitle()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || myQid <= 0) return;
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Qtitle FROM SurveyQuestion WHERE Qid=@qid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@qid", myQid);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        byte[] bytes = result as byte[];
                        string title = bytes != null ? System.Text.Encoding.Unicode.GetString(bytes) : result.ToString();
                        TxtQuestionTitle.Text = title;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            pageMsg = "加载题目失败: " + ex.Message;
            pageMsgType = "error";
        }
    }

    private void BindItems()
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || myQid <= 0) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Mid, Mitem, Mscore, Mcount FROM SurveyItem WHERE Mqid=@qid ORDER BY Mid";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@qid", myQid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                // 处理ntext字段
                foreach (DataRow row in dt.Rows)
                {
                    if (row["Mitem"] != DBNull.Value)
                    {
                        byte[] bytes = row["Mitem"] as byte[];
                        if (bytes != null)
                            row["Mitem"] = System.Text.Encoding.Unicode.GetString(bytes);
                    }
                }
                
                RptItems.DataSource = dt;
                RptItems.DataBind();
                PanelEmpty.Visible = (dt.Rows.Count == 0);
            }
        }
        catch (Exception ex)
        {
            pageMsg = "加载选项失败: " + ex.Message;
            pageMsgType = "error";
        }
    }

    protected void BtnAdd_Click(object sender, EventArgs e)
    {
        string content = TxtContent.Text.Trim();
        if (string.IsNullOrEmpty(content))
        {
            pageMsg = "请输入选项内容";
            pageMsgType = "error";
            return;
        }

        int score = 0;
        int.TryParse(DDLScore.SelectedValue, out score);
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack) VALUES (@qid, @vid, @item, @score, 0, @cid, 0)";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@qid", myQid);
                    cmd.Parameters.AddWithValue("@vid", myVid);
                    cmd.Parameters.Add("@item", SqlDbType.NText).Value = content;
                    cmd.Parameters.AddWithValue("@score", score);
                    cmd.Parameters.AddWithValue("@cid", myCid);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "选项添加成功！";
            pageMsgType = "success";
            TxtContent.Text = "";
        }
        catch (Exception ex)
        {
            pageMsg = "添加失败: " + ex.Message;
            pageMsgType = "error";
        }
        BindItems();
    }

    protected void BtnQuickAdd_Click(object sender, EventArgs e)
    {
        string type = DDLQuickType.SelectedValue;
        string correctAnswer = TxtCorrectAnswer.Text.Trim().ToUpper();
        
        if (string.IsNullOrEmpty(correctAnswer))
        {
            pageMsg = "请输入正确答案";
            pageMsgType = "error";
            BindItems();
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                
                if (type == "judge")
                {
                    // 判断题：正确/错误
                    string[] options = { "正确", "错误" };
                    foreach (string opt in options)
                    {
                        int score = (correctAnswer == "正确" && opt == "正确") || (correctAnswer == "错误" && opt == "错误") ? 5 : 0;
                        string sql = "INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack) VALUES (@qid, @vid, @item, @score, 0, @cid, 0)";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@qid", myQid);
                            cmd.Parameters.AddWithValue("@vid", myVid);
                            cmd.Parameters.Add("@item", SqlDbType.NText).Value = opt;
                            cmd.Parameters.AddWithValue("@score", score);
                            cmd.Parameters.AddWithValue("@cid", myCid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    pageMsg = "判断题选项添加成功！";
                }
                else
                {
                    // 单选题或多选题：ABCD
                    string[] options = { "A", "B", "C", "D" };
                    foreach (string opt in options)
                    {
                        int score = 0;
                        if (type == "single")
                        {
                            // 单选题：只有一个正确答案
                            score = correctAnswer == opt ? 5 : 0;
                        }
                        else
                        {
                            // 多选题：可能有多个正确答案
                            score = correctAnswer.Contains(opt) ? 2 : 0;
                        }
                        
                        string sql = "INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack) VALUES (@qid, @vid, @item, @score, 0, @cid, 0)";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@qid", myQid);
                            cmd.Parameters.AddWithValue("@vid", myVid);
                            cmd.Parameters.Add("@item", SqlDbType.NText).Value = opt;
                            cmd.Parameters.AddWithValue("@score", score);
                            cmd.Parameters.AddWithValue("@cid", myCid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    pageMsg = (type == "single" ? "单选题" : "多选题") + "选项添加成功！";
                }
                
                pageMsgType = "success";
                TxtCorrectAnswer.Text = "";
                BindItems();
            }
        }
        catch (Exception ex)
        {
            pageMsg = "快速添加失败: " + ex.Message;
            pageMsgType = "error";
        }
    }


    protected void RptItems_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DropDownList ddl = e.Item.FindControl("DDLEditScore") as DropDownList;
            if (ddl != null)
            {
                DataRowView row = e.Item.DataItem as DataRowView;
                if (row != null)
                {
                    string scoreVal = row["Mscore"].ToString();
                    ListItem li = ddl.Items.FindByValue(scoreVal);
                    if (li != null)
                        ddl.SelectedValue = scoreVal;
                }
            }
        }
    }

    protected void BtnSaveTitle_Click(object sender, EventArgs e)
    {
        string newTitle = TxtQuestionTitle.Text.Trim();
        if (string.IsNullOrEmpty(newTitle))
        {
            pageMsg = "题目内容不能为空";
            pageMsgType = "error";
            BindItems();
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs) || myQid <= 0) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "UPDATE SurveyQuestion SET Qtitle=@title WHERE Qid=@qid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@title", SqlDbType.NText).Value = newTitle;
                    cmd.Parameters.AddWithValue("@qid", myQid);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "题目已更新";
            pageMsgType = "success";
        }
        catch (Exception ex)
        {
            pageMsg = "更新题目失败: " + ex.Message;
            pageMsgType = "error";
        }
        BindItems();
    }

    protected void RptItems_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int mid = 0;
        int.TryParse(e.CommandArgument.ToString(), out mid);
        if (mid <= 0) return;

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        if (e.CommandName == "UpdateItem")
        {
            TextBox txtContent = e.Item.FindControl("TxtEditContent") as TextBox;
            DropDownList ddlScore = e.Item.FindControl("DDLEditScore") as DropDownList;

            if (txtContent != null && ddlScore != null)
            {
                string content = txtContent.Text.Trim();
                if (string.IsNullOrEmpty(content))
                {
                    pageMsg = "选项内容不能为空";
                    pageMsgType = "error";
                    return;
                }

                int score = 0;
                int.TryParse(ddlScore.SelectedValue, out score);

                try
                {
                    using (SqlConnection conn = new SqlConnection(cs))
                    {
                        conn.Open();
                        string sql = "UPDATE SurveyItem SET Mitem=@item, Mscore=@score WHERE Mid=@mid";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@mid", mid);
                            cmd.Parameters.Add("@item", SqlDbType.NText).Value = content;
                            cmd.Parameters.AddWithValue("@score", score);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    pageMsg = "选项已更新";
                    pageMsgType = "success";
                    BindItems();
                }
                catch (Exception ex)
                {
                    pageMsg = "更新失败: " + ex.Message;
                    pageMsgType = "error";
                }
            }
        }
        else if (e.CommandName == "DelItem")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = "DELETE FROM SurveyItem WHERE Mid=@mid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@mid", mid);
                        cmd.ExecuteNonQuery();
                    }
                }
                pageMsg = "选项已删除";
                pageMsgType = "success";
                BindItems();
            }
            catch (Exception ex)
            {
                pageMsg = "删除失败: " + ex.Message;
                pageMsgType = "error";
            }
        }
    }

    protected void BtnReturn_Click(object sender, EventArgs e)
    {
        // 通知父窗口关闭弹窗
        Response.Write("<script type='text/javascript'>if(window.parent!==window){window.parent.postMessage('closeModal','*');}else{window.history.back();}<" + "/script>");
        Response.End();
    }
</script>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>编辑题目和选项</title>
<link href="../teacher/show-common.css" rel="stylesheet" type="text/css" />

<style>
    .sin-page {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
        animation: fadeIn 0.4s ease;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    /* 页面标题 */
    .sin-header {
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
        border-radius: 16px;
        padding: 28px 32px;
        margin-bottom: 28px;
        box-shadow: 0 4px 20px rgba(5,150,105,.25);
        position: relative;
        overflow: hidden;
    }
    
    .sin-header::before {
        content: '';
        position: absolute;
        top: -30px;
        right: -30px;
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    
    .sin-header-title {
        font-size: 22px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 4px;
        position: relative;
        z-index: 1;
    }
    
    .sin-header-sub {
        font-size: 13px;
        color: rgba(255,255,255,.75);
        position: relative;
        z-index: 1;
    }
    
    /* 消息提示 */
    .sin-msg {
        padding: 12px 18px;
        border-radius: 10px;
        font-size: 13px;
        margin-bottom: 18px;
        display: flex;
        align-items: center;
        gap: 8px;
        animation: slideDown 0.3s ease;
    }
    
    @keyframes slideDown {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .sin-msg-success {
        background: #f0fdf4;
        border: 1px solid #bbf7d0;
        color: #166534;
    }
    
    .sin-msg-error {
        background: #fef2f2;
        border: 1px solid #fecaca;
        color: #991b1b;
    }
    
    /* 题目卡片 */
    .sin-question {
        background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
        border: 2px solid #bbf7d0;
        border-radius: 14px;
        padding: 20px 28px;
        margin-bottom: 24px;
        box-shadow: 0 2px 8px rgba(5,150,105,.1);
    }
    
    .sin-question-label {
        font-size: 12px;
        font-weight: 600;
        color: #047857;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 8px;
    }
    
    .sin-question-text {
        font-size: 16px;
        font-weight: 600;
        color: #065f46;
        line-height: 1.6;
    }
    
    /* 卡片 */
    .sin-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e8ecf1;
        box-shadow: 0 2px 8px rgba(0,0,0,.04);
        margin-bottom: 20px;
        overflow: hidden;
    }
    
    .sin-card-head {
        padding: 18px 24px;
        border-bottom: 1px solid #f1f5f9;
        background: linear-gradient(180deg, #fafbfc, #f8f9fb);
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .sin-card-body {
        padding: 24px;
    }
    
    /* 选项列表 */
    .sin-items {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    
    .sin-item {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px 20px;
        background: #fff;
        border: 1.5px solid #e2e8f0;
        border-radius: 10px;
        transition: all 0.2s;
    }
    
    .sin-item:hover {
        border-color: #10b981;
        box-shadow: 0 2px 8px rgba(16,185,129,.1);
        transform: translateY(-1px);
    }
    
    .sin-item-num {
        width: 32px;
        height: 32px;
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 14px;
        flex-shrink: 0;
    }
    
    .sin-item-content {
        flex: 1;
        font-size: 14px;
        color: #475569;
        line-height: 1.6;
    }
    
    .sin-item-score {
        padding: 4px 12px;
        background: #f0fdf4;
        color: #059669;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        flex-shrink: 0;
    }
    
    .sin-item-actions {
        display: flex;
        gap: 6px;
        flex-shrink: 0;
    }
    
    .sin-btn-del {
        padding: 6px 14px;
        background: #fff;
        color: #ef4444;
        border: 1px solid #fecaca;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.15s;
        text-decoration: none;
        font-family: inherit;
    }
    
    .sin-btn-del:hover {
        background: #fef2f2;
        transform: translateY(-1px);
    }
    
    /* 表单 */
    .sin-form-group {
        margin-bottom: 18px;
    }
    
    .sin-form-label {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 8px;
        display: block;
    }
    
    .sin-form-input {
        width: 100%;
        padding: 12px 16px;
        border: 1.5px solid #e2e8f0;
        border-radius: 10px;
        font-size: 14px;
        color: #334155;
        font-family: inherit;
        transition: all 0.2s;
        box-sizing: border-box;
    }
    
    .sin-form-input:focus {
        outline: none;
        border-color: #10b981;
        box-shadow: 0 0 0 4px rgba(16,185,129,.1);
    }
    
    .sin-form-textarea {
        min-height: 100px;
        resize: vertical;
    }
    
    .sin-form-select {
        padding: 10px 36px 10px 14px;
        border-radius: 10px;
        border: 1.5px solid #e2e8f0;
        font-size: 13px;
        color: #334155;
        background: #fff;
        cursor: pointer;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2310b981' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 12px center;
        font-family: inherit;
        transition: all 0.2s;
    }
    
    .sin-form-select:focus {
        outline: none;
        border-color: #10b981;
        box-shadow: 0 0 0 4px rgba(16,185,129,.1);
    }
    
    /* 按钮 */
    .sin-actions {
        display: flex;
        gap: 12px;
        margin-top: 20px;
    }
    
    .sin-btn {
        padding: 11px 28px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        transition: all 0.2s;
        font-family: inherit;
    }
    
    .sin-btn-primary {
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff;
        box-shadow: 0 3px 12px rgba(5,150,105,.25);
    }
    
    .sin-btn-primary:hover {
        background: linear-gradient(135deg, #047857, #059669);
        box-shadow: 0 6px 20px rgba(5,150,105,.35);
        transform: translateY(-1px);
    }
    
    .sin-btn-secondary {
        background: #fff;
        color: #475569;
        border: 1.5px solid #e2e8f0;
    }
    
    .sin-btn-secondary:hover {
        background: #f8fafc;
        border-color: #cbd5e1;
        transform: translateY(-1px);
    }
    
    /* 空状态 */
    .sin-empty {
        text-align: center;
        padding: 60px 20px;
    }
    
    .sin-empty-icon {
        font-size: 48px;
        margin-bottom: 16px;
        opacity: 0.5;
    }
    
    .sin-empty-text {
        font-size: 15px;
        color: #64748b;
        font-weight: 500;
    }
    
    .sin-empty-hint {
        font-size: 13px;
        color: #94a3b8;
        margin-top: 6px;
    }
    
    /* 快速添加功能样式 */
    .sin-quick-info {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 12px 16px;
        background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
        border: 1px solid #bfdbfe;
        border-radius: 10px;
        margin-bottom: 20px;
    }
    
    .sin-quick-info span {
        font-size: 13px;
        color: #1e40af;
        line-height: 1.6;
    }
    
    .sin-form-row {
        display: flex;
        gap: 16px;
        margin-bottom: 18px;
    }
    
    .sin-quick-examples {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        padding: 16px;
        margin-bottom: 20px;
    }
    
    .sin-quick-example-title {
        font-size: 13px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 12px;
    }
    
    .sin-quick-example-items {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    
    .sin-quick-example-item {
        font-size: 13px;
        color: #64748b;
        line-height: 1.6;
    }
    
    .sin-quick-example-item strong {
        color: #334155;
        font-weight: 600;
    }
    
    .sin-quick-example-item code {
        background: #fff;
        padding: 2px 8px;
        border-radius: 4px;
        font-family: 'Consolas', 'Monaco', monospace;
        font-size: 12px;
        color: #059669;
        font-weight: 600;
        border: 1px solid #e2e8f0;
    }
    
    @media (max-width: 768px) {
        .sin-form-row {
            flex-direction: column;
        }
    }
</style>
</head>
<body>
<form id="form1" runat="server">
<div class="sin-page">
    <!-- 页面标题 -->
    <div class="sin-header">
        <div class="sin-header-title">📝 编辑题目和选项</div>
        <div class="sin-header-sub">编辑题目内容，管理选项及分值设置</div>
    </div>
    
    <!-- 消息提示 -->
    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="sin-msg sin-msg-<%= pageMsgType %>">
        <%= Server.HtmlEncode(pageMsg) %>
    </div>
    <% } %>
    
    <!-- 题目信息（可编辑） -->
    <div class="sin-question">
        <div class="sin-question-label">当前题目</div>
        <div style="display: flex; align-items: center; gap: 12px; margin-top: 8px;">
            <asp:TextBox ID="TxtQuestionTitle" runat="server" CssClass="sin-form-input" 
                style="flex: 1; font-size: 15px; font-weight: 600; color: #065f46;" />
            <asp:Button ID="BtnSaveTitle" runat="server" Text="保存题目" OnClick="BtnSaveTitle_Click" 
                CssClass="sin-btn sin-btn-primary" style="white-space: nowrap; padding: 10px 20px;" />
        </div>
    </div>
    
    <!-- 选项列表 -->
    <div class="sin-card">
        <div class="sin-card-head">
            📋 已有选项
        </div>
        <div class="sin-card-body">
            <asp:Repeater ID="RptItems" runat="server" OnItemCommand="RptItems_ItemCommand" OnItemDataBound="RptItems_ItemDataBound">
                <HeaderTemplate><div class="sin-items"></HeaderTemplate>
                <ItemTemplate>
                    <div class="sin-item">
                        <div class="sin-item-num"><%# Container.ItemIndex + 1 %></div>
                        <asp:TextBox ID="TxtEditContent" runat="server" CssClass="sin-form-input" 
                            Text='<%# Eval("Mitem") %>' style="flex: 1; padding: 8px 12px; font-size: 13px;" />
                        <asp:DropDownList ID="DDLEditScore" runat="server" CssClass="sin-form-select" style="min-width: 80px;">
                            <asp:ListItem Value="10">10分</asp:ListItem>
                            <asp:ListItem Value="5">5分</asp:ListItem>
                            <asp:ListItem Value="4">4分</asp:ListItem>
                            <asp:ListItem Value="3">3分</asp:ListItem>
                            <asp:ListItem Value="2">2分</asp:ListItem>
                            <asp:ListItem Value="1">1分</asp:ListItem>
                            <asp:ListItem Value="0">0分</asp:ListItem>
                            <asp:ListItem Value="-1">-1分</asp:ListItem>
                        </asp:DropDownList>
                        <div class="sin-item-actions">
                            <asp:LinkButton runat="server" CssClass="sin-btn sin-btn-primary" 
                                style="padding: 6px 14px; font-size: 12px;" 
                                CommandName="UpdateItem" CommandArgument='<%# Eval("Mid") %>'>
                                保存
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="sin-btn-del" CommandName="DelItem" 
                                CommandArgument='<%# Eval("Mid") %>' OnClientClick="return confirm('确定要删除此选项吗？');">
                                删除
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>
            
            <asp:Panel ID="PanelEmpty" runat="server" Visible='<%# RptItems.Items.Count == 0 %>'>
                <div class="sin-empty">
                    <div class="sin-empty-icon">📝</div>
                    <div class="sin-empty-text">还没有添加任何选项</div>
                    <div class="sin-empty-hint">在下方表单中添加第一个选项</div>
                </div>
            </asp:Panel>
        </div>
    </div>
    
    <!-- 快速添加选项 -->
    <div class="sin-card">
        <div class="sin-card-head">
            ⚡ 快速添加标准选项
        </div>
        <div class="sin-card-body">
            <div class="sin-quick-info">
                <svg viewBox="0 0 24 24" style="width: 18px; height: 18px; stroke: #3b82f6; fill: none; stroke-width: 2;">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                <span>快速添加标准格式的选项，系统会自动创建ABCD或判断题选项</span>
            </div>
            
            <div class="sin-form-row">
                <div class="sin-form-group" style="flex: 1;">
                    <label class="sin-form-label">题目类型</label>
                    <asp:DropDownList ID="DDLQuickType" runat="server" CssClass="sin-form-select">
                        <asp:ListItem Value="single">单选题（ABCD四个选项）</asp:ListItem>
                        <asp:ListItem Value="multiple">多选题（ABCD四个选项）</asp:ListItem>
                        <asp:ListItem Value="judge">判断题（正确/错误）</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="sin-form-group" style="flex: 1;">
                    <label class="sin-form-label">正确答案 *</label>
                    <asp:TextBox ID="TxtCorrectAnswer" runat="server" CssClass="sin-form-input" 
                        placeholder="单选：A  多选：AB  判断：正确"></asp:TextBox>
                </div>
            </div>
            
            <div class="sin-quick-examples">
                <div class="sin-quick-example-title">示例：</div>
                <div class="sin-quick-example-items">
                    <div class="sin-quick-example-item">
                        <strong>单选题：</strong>输入 <code>A</code> 表示A是正确答案，其他为0分
                    </div>
                    <div class="sin-quick-example-item">
                        <strong>多选题：</strong>输入 <code>AB</code> 表示A和B是正确答案，每个2分
                    </div>
                    <div class="sin-quick-example-item">
                        <strong>判断题：</strong>输入 <code>正确</code> 或 <code>错误</code>
                    </div>
                </div>
            </div>
            
            <div class="sin-actions">
                <asp:Button ID="BtnQuickAdd" runat="server" Text="快速添加" OnClick="BtnQuickAdd_Click" CssClass="sin-btn sin-btn-primary" />
            </div>
        </div>
    </div>
    
    <!-- 自定义添加选项 -->
    <div class="sin-card">
        <div class="sin-card-head">
            ➕ 自定义添加选项
        </div>
        <div class="sin-card-body">
            <div class="sin-form-group">
                <label class="sin-form-label">选项内容 *</label>
                <asp:TextBox ID="TxtContent" runat="server" CssClass="sin-form-input sin-form-textarea" 
                    TextMode="MultiLine" placeholder="请输入选项内容，例如：A. 选项内容"></asp:TextBox>
            </div>
            
            <div class="sin-form-group">
                <label class="sin-form-label">分值</label>
                <asp:DropDownList ID="DDLScore" runat="server" CssClass="sin-form-select">
                    <asp:ListItem Value="5">5分（正确答案）</asp:ListItem>
                    <asp:ListItem Value="4">4分</asp:ListItem>
                    <asp:ListItem Value="3">3分</asp:ListItem>
                    <asp:ListItem Value="2">2分</asp:ListItem>
                    <asp:ListItem Value="1">1分</asp:ListItem>
                    <asp:ListItem Value="0" Selected="True">0分（错误答案）</asp:ListItem>
                    <asp:ListItem Value="-1">-1分</asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="sin-actions">
                <asp:Button ID="BtnAdd" runat="server" Text="添加选项" OnClick="BtnAdd_Click" CssClass="sin-btn sin-btn-primary" />
                <asp:Button ID="BtnReturn" runat="server" Text="返回题目列表" OnClick="BtnReturn_Click" CssClass="sin-btn sin-btn-secondary" />
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    // 检测是否在iframe中
    if (window.parent !== window) {
        // 在iframe中，隐藏不需要的元素
        window.addEventListener('load', function() {
            // 隐藏绿色标题栏
            var header = document.querySelector('.sin-header');
            if (header) {
                header.style.display = 'none';
            }
            
            // 隐藏左侧菜单
            var leftMenu = document.querySelector('.sidebar, .left-menu, #sidebar, [class*="sidebar"], [class*="menu"]');
            if (leftMenu) {
                leftMenu.style.display = 'none';
            }
            
            // 隐藏右上角用户信息
            var userInfo = document.querySelector('.user-info, .header-user, [class*="user"], .top-right');
            if (userInfo) {
                userInfo.style.display = 'none';
            }
            
            // 通用方法：隐藏所有可能的导航元素
            var style = document.createElement('style');
            style.textContent = `
                /* 隐藏Master Page的左侧菜单 */
                body > form > div:first-child,
                body > form > table:first-child,
                body > form > div[style*="float:left"],
                body > form > div[style*="position:absolute"][style*="left"],
                .master-sidebar,
                .master-menu {
                    display: none !important;
                }
                
                /* 隐藏右上角用户信息 */
                body > form > div[style*="float:right"],
                body > form > div[style*="position:absolute"][style*="right"],
                .master-header-right,
                .master-user-info {
                    display: none !important;
                }
                
                /* 让内容区域占满全宽 */
                body > form > div,
                .content-wrapper,
                .main-content {
                    width: 100% !important;
                    margin-left: 0 !important;
                    margin-right: 0 !important;
                }
            `;
            document.head.appendChild(style);
            
            // 修改返回按钮行为
            var returnBtn = document.getElementById('<%= BtnReturn.ClientID %>');
            if (returnBtn) {
                returnBtn.onclick = function(e) {
                    e.preventDefault();
                    // 通知父窗口关闭弹窗
                    window.parent.postMessage('closeModal', '*');
                    return false;
                };
            }
        });
    }
</script>

</form>
</body>
</html>
