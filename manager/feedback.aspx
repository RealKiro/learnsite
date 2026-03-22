<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    protected class FeedbackItem
    {
        public string Id;
        public string Type;
        public string Content;
        public string StudentName;
        public string StudentNum;
        public string SubmitDate;
        public string Status;
        public string Reply;
        public string ReplyDate;
    }

    protected List<FeedbackItem> feedbackList = new List<FeedbackItem>();
    protected int totalCount = 0;
    protected int pendingCount = 0;
    protected int repliedCount = 0;

    private string xmlPath;

    protected void Page_Load(object sender, EventArgs e)
    {
        xmlPath = Server.MapPath("~/App_Data/feedback.xml");
        LoadFeedback();
    }

    private void LoadFeedback()
    {
        feedbackList.Clear();
        totalCount = 0;
        pendingCount = 0;
        repliedCount = 0;

        try
        {
            if (!File.Exists(xmlPath)) return;

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNodeList items = doc.SelectNodes("//feedbacks/item");
            if (items == null) return;

            foreach (XmlNode node in items)
            {
                FeedbackItem item = new FeedbackItem();
                item.Id = node.Attributes["id"] != null ? node.Attributes["id"].Value : "";
                item.Type = node.Attributes["type"] != null ? node.Attributes["type"].Value : "";
                item.StudentName = node.Attributes["studentName"] != null ? node.Attributes["studentName"].Value : "";
                if (!string.IsNullOrEmpty(item.StudentName) && item.StudentName.Contains("%"))
                {
                    try { item.StudentName = System.Web.HttpUtility.UrlDecode(item.StudentName, System.Text.Encoding.UTF8); } catch { }
                }
                item.StudentNum = node.Attributes["studentNum"] != null ? node.Attributes["studentNum"].Value : "";
                item.SubmitDate = node.Attributes["submitDate"] != null ? node.Attributes["submitDate"].Value : "";
                item.Status = node.Attributes["status"] != null ? node.Attributes["status"].Value : "pending";

                XmlNode contentNode = node.SelectSingleNode("content");
                item.Content = contentNode != null ? contentNode.InnerText : "";

                XmlNode replyNode = node.SelectSingleNode("reply");
                item.Reply = replyNode != null ? replyNode.InnerText : "";
                item.ReplyDate = replyNode != null && replyNode.Attributes["date"] != null ? replyNode.Attributes["date"].Value : "";

                feedbackList.Add(item);
                totalCount++;
                if (item.Status == "replied")
                    repliedCount++;
                else
                    pendingCount++;
            }
        }
        catch { }
    }

    protected string GetTypeLabel(string type)
    {
        switch (type)
        {
            case "bug": return "功能异常";
            case "help": return "操作求助";
            case "suggest": return "功能建议";
            case "other": return "其他问题";
            default: return type;
        }
    }

    protected string GetTypeCss(string type)
    {
        switch (type)
        {
            case "bug": return "fb-tag-bug";
            case "help": return "fb-tag-help";
            case "suggest": return "fb-tag-suggest";
            case "other": return "fb-tag-other";
            default: return "fb-tag-other";
        }
    }

    protected void BtnReply_Click(object sender, EventArgs e)
    {
        try
        {
            string id = HiddenReplyId.Value.Trim();
            string replyText = TxtReply.Text.Trim();

            if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(replyText))
            {
                LabelMsg.ForeColor = System.Drawing.Color.Red;
                LabelMsg.Text = "请输入回复内容";
                return;
            }

            if (!File.Exists(xmlPath)) return;

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNode target = doc.SelectSingleNode("//feedbacks/item[@id='" + id.Replace("'", "") + "']");
            if (target == null)
            {
                LabelMsg.ForeColor = System.Drawing.Color.Red;
                LabelMsg.Text = "未找到该反馈记录";
                return;
            }

            // 更新 status
            if (target.Attributes["status"] != null)
                target.Attributes["status"].Value = "replied";
            else
            {
                XmlAttribute attr = doc.CreateAttribute("status");
                attr.Value = "replied";
                target.Attributes.Append(attr);
            }

            // 更新 reply
            XmlNode replyNode = target.SelectSingleNode("reply");
            if (replyNode == null)
            {
                replyNode = doc.CreateElement("reply");
                target.AppendChild(replyNode);
            }
            replyNode.InnerText = "";
            replyNode.AppendChild(doc.CreateCDataSection(replyText));

            XmlAttribute dateAttr = replyNode.Attributes["date"];
            if (dateAttr == null)
            {
                dateAttr = doc.CreateAttribute("date");
                replyNode.Attributes.Append(dateAttr);
            }
            dateAttr.Value = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            doc.Save(xmlPath);

            // Clear form
            HiddenReplyId.Value = "";
            TxtReply.Text = "";

            // Reload
            LoadFeedback();

            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "&#10004; 回复成功";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "回复失败: " + Server.HtmlEncode(ex.Message);
        }
    }

    protected void BtnDelete_Click(object sender, EventArgs e)
    {
        try
        {
            string id = HiddenDeleteId.Value.Trim();
            if (string.IsNullOrEmpty(id)) return;

            if (!File.Exists(xmlPath)) return;

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNode root = doc.SelectSingleNode("//feedbacks");
            if (root == null) return;

            XmlNode target = root.SelectSingleNode("item[@id='" + id.Replace("'", "") + "']");
            if (target != null)
            {
                root.RemoveChild(target);
                doc.Save(xmlPath);

                LoadFeedback();

                LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
                LabelMsg.Text = "&#10004; 已删除该反馈";
            }
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "删除失败: " + Server.HtmlEncode(ex.Message);
        }
    }

    protected void BtnBatchDelete_Click(object sender, EventArgs e)
    {
        try
        {
            string ids = HiddenBatchDeleteIds.Value.Trim();
            if (string.IsNullOrEmpty(ids)) return;

            if (!File.Exists(xmlPath)) return;

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNode root = doc.SelectSingleNode("//feedbacks");
            if (root == null) return;

            string[] idArr = ids.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            int deletedCount = 0;

            foreach (string rawId in idArr)
            {
                string id = rawId.Trim().Replace("'", "");
                if (string.IsNullOrEmpty(id)) continue;

                XmlNode target = root.SelectSingleNode("item[@id='" + id + "']");
                if (target != null)
                {
                    root.RemoveChild(target);
                    deletedCount++;
                }
            }

            if (deletedCount > 0)
            {
                doc.Save(xmlPath);
                LoadFeedback();

                LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
                LabelMsg.Text = "&#10004; 已批量删除 " + deletedCount + " 条反馈";
            }

            HiddenBatchDeleteIds.Value = "";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "批量删除失败: " + Server.HtmlEncode(ex.Message);
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .fb-page { max-width:100%; padding:8px 8px 40px; font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .fb-hd { display:flex; align-items:center; gap:16px; margin-bottom:24px; }
    .fb-hd-icon { width:48px; height:48px; background:linear-gradient(135deg,#7c3aed,#a78bfa); border-radius:14px; display:flex; align-items:center; justify-content:center; box-shadow:0 4px 12px rgba(124,58,237,.25); flex-shrink:0; }
    .fb-hd-icon svg { width:26px; height:26px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .fb-hd h1 { font-size:22px; font-weight:700; color:#0f172a; margin:0 0 2px; }
    .fb-hd p { font-size:13px; color:#94a3b8; margin:0; }

    /* 统计卡片 */
    .fb-stats { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:24px; }
    @media(max-width:640px) { .fb-stats { grid-template-columns:1fr; } }
    .fb-stat-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); padding:20px 24px; display:flex; align-items:center; gap:16px; transition:all .2s; }
    .fb-stat-card:hover { box-shadow:0 8px 24px rgba(0,0,0,.07); transform:translateY(-2px); }
    .fb-stat-icon { width:48px; height:48px; border-radius:12px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
    .fb-stat-icon svg { width:24px; height:24px; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .fsi-total { background:linear-gradient(135deg,#eef2ff,#e0e7ff); } .fsi-total svg { stroke:#6366f1; }
    .fsi-pending { background:linear-gradient(135deg,#fff7ed,#ffedd5); } .fsi-pending svg { stroke:#ea580c; }
    .fsi-replied { background:linear-gradient(135deg,#ecfdf5,#d1fae5); } .fsi-replied svg { stroke:#059669; }
    .fb-stat-num { font-size:28px; font-weight:700; color:#1e293b; line-height:1; }
    .fb-stat-label { font-size:13px; color:#94a3b8; margin-top:4px; }

    /* 反馈列表 */
    .fb-list-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; }
    .fb-list-hd { padding:16px 22px; font-size:15px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:12px; }
    .fb-list-hd .ci { width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; background:#ede9fe; }
    .fb-list-hd .ci svg { width:19px; height:19px; stroke:#7c3aed; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; fill:none; }
    .fb-list-bd { padding:0; }

    .fb-item { padding:20px 22px; border-bottom:1px solid #f1f5f9; transition:background .15s; }
    .fb-item:last-child { border-bottom:none; }
    .fb-item:hover { background:#fafbff; }

    .fb-item-top { display:flex; align-items:center; gap:10px; margin-bottom:10px; flex-wrap:wrap; }
    .fb-tag { display:inline-flex; align-items:center; height:24px; padding:0 10px; border-radius:6px; font-size:12px; font-weight:600; }
    .fb-tag-bug { background:#fef2f2; color:#dc2626; }
    .fb-tag-help { background:#eff6ff; color:#2563eb; }
    .fb-tag-suggest { background:#ecfdf5; color:#059669; }
    .fb-tag-other { background:#f8fafc; color:#64748b; }
    .fb-status { display:inline-flex; align-items:center; height:24px; padding:0 10px; border-radius:6px; font-size:12px; font-weight:600; }
    .fb-status-pending { background:#fff7ed; color:#ea580c; }
    .fb-status-replied { background:#ecfdf5; color:#059669; }
    .fb-user { font-size:13px; color:#475569; font-weight:600; }
    .fb-user-num { font-size:12px; color:#94a3b8; font-weight:400; }
    .fb-date { font-size:12px; color:#94a3b8; margin-left:auto; }

    .fb-content { font-size:13.5px; color:#334155; line-height:1.8; margin-bottom:10px; word-break:break-word; white-space:pre-wrap; background:#f8fafc; padding:12px 16px; border-radius:10px; border:1px solid #f1f5f9; }

    .fb-reply-box { background:linear-gradient(135deg,#f0fdf4,#ecfdf5); border:1px solid #bbf7d0; border-radius:10px; padding:12px 16px; margin-bottom:10px; }
    .fb-reply-label { font-size:12px; font-weight:600; color:#059669; margin-bottom:6px; display:flex; align-items:center; gap:6px; }
    .fb-reply-label svg { width:14px; height:14px; stroke:#059669; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .fb-reply-text { font-size:13px; color:#334155; line-height:1.8; white-space:pre-wrap; word-break:break-word; }
    .fb-reply-date { font-size:11px; color:#94a3b8; margin-top:6px; }

    .fb-actions { display:flex; align-items:center; gap:8px; }
    .fb-btn { display:inline-flex; align-items:center; gap:5px; height:32px; padding:0 14px; border-radius:8px; font-size:12px; font-family:inherit; font-weight:600; cursor:pointer; transition:all .15s; border:none; }
    .fb-btn-reply { background:linear-gradient(135deg,#7c3aed,#6d28d9); color:#fff; box-shadow:0 2px 6px rgba(124,58,237,.25); }
    .fb-btn-reply:hover { box-shadow:0 4px 12px rgba(124,58,237,.35); transform:translateY(-1px); }
    .fb-btn-delete { background:#fff; color:#ef4444; border:1px solid #fecaca !important; }
    .fb-btn-delete:hover { background:#fef2f2; border-color:#fca5a5 !important; }
    .fb-btn svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }

    /* 回复弹窗 */
    .fb-reply-form { margin-top:12px; padding:16px; background:#f8fafc; border:1.5px solid #e2e8f0; border-radius:12px; }
    .fb-reply-form textarea { display:block !important; width:100% !important; min-height:80px; padding:10px 14px; border:1.5px solid #e2e8f0; border-radius:8px; font-size:13px; font-family:'Microsoft YaHei',sans-serif; color:#334155; outline:none; resize:vertical; box-sizing:border-box !important; transition:border-color .15s, box-shadow .15s; }
    .fb-reply-form textarea:focus { border-color:#7c3aed; box-shadow:0 0 0 3px rgba(124,58,237,.1); }
    .fb-reply-form-actions { display:flex; align-items:center; gap:10px; margin-top:10px; }

    .fb-empty { padding:60px 20px; text-align:center; }
    .fb-empty-icon { font-size:48px; margin-bottom:16px; }
    .fb-empty-text { font-size:14px; color:#94a3b8; }

    .fb-msg { font-size:13px; margin-left:auto; }

    /* 批量操作栏 */
    .fb-batch-bar { display:flex; align-items:center; gap:12px; padding:12px 22px; border-bottom:1px solid #f1f5f9; background:#fafbff; }
    .fb-batch-bar label { display:inline-flex; align-items:center; gap:6px; font-size:13px; font-weight:600; color:#475569; cursor:pointer; }
    .fb-batch-bar input[type=checkbox] { width:16px; height:16px; accent-color:#6366f1; cursor:pointer; }
    .fb-batch-count { font-size:12px; color:#94a3b8; }
    .fb-btn-batch-del { display:none; align-items:center; gap:5px; height:32px; padding:0 14px; border-radius:8px; font-size:12px; font-family:inherit; font-weight:600; cursor:pointer; transition:all .15s; border:none; background:#fef2f2; color:#ef4444; border:1px solid #fecaca !important; margin-left:auto; }
    .fb-btn-batch-del:hover { background:#fee2e2; border-color:#fca5a5 !important; }
    .fb-btn-batch-del.show { display:inline-flex !important; }
    .fb-btn-batch-del svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .fb-item-check { display:inline-flex; align-items:center; margin-right:6px; }
    .fb-item-check input[type=checkbox] { width:16px; height:16px; accent-color:#6366f1; cursor:pointer; }
</style>

<div class="fb-page">
    <div class="fb-hd">
        <div class="fb-hd-icon"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
        <div><h1>意见反馈</h1><p>查看和回复用户通过帮助中心提交的反馈信息</p></div>
        <span class="fb-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></span>
    </div>

    <!-- 统计 -->
    <div class="fb-stats">
        <div class="fb-stat-card">
            <div class="fb-stat-icon fsi-total"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
            <div>
                <div class="fb-stat-num"><%= totalCount %></div>
                <div class="fb-stat-label">反馈总数</div>
            </div>
        </div>
        <div class="fb-stat-card">
            <div class="fb-stat-icon fsi-pending"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
            <div>
                <div class="fb-stat-num"><%= pendingCount %></div>
                <div class="fb-stat-label">待回复</div>
            </div>
        </div>
        <div class="fb-stat-card">
            <div class="fb-stat-icon fsi-replied"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
            <div>
                <div class="fb-stat-num"><%= repliedCount %></div>
                <div class="fb-stat-label">已回复</div>
            </div>
        </div>
    </div>

    <!-- 隐藏字段和按钮 -->
    <div style="display:none;position:absolute;width:0;height:0;overflow:hidden;">
        <asp:HiddenField ID="HiddenReplyId" runat="server" Value="" />
        <asp:HiddenField ID="HiddenDeleteId" runat="server" Value="" />
        <asp:HiddenField ID="HiddenBatchDeleteIds" runat="server" Value="" />
        <asp:TextBox ID="TxtReply" runat="server" TextMode="MultiLine" />
        <asp:Button ID="BtnReply" runat="server" Text="reply" OnClick="BtnReply_Click" />
        <asp:Button ID="BtnDelete" runat="server" Text="delete" OnClick="BtnDelete_Click" />
        <asp:Button ID="BtnBatchDelete" runat="server" Text="batchdelete" OnClick="BtnBatchDelete_Click" />
    </div>

    <!-- 反馈列表 -->
    <div class="fb-list-card">
        <div class="fb-list-hd">
            <span class="ci"><svg viewBox="0 0 24 24"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg></span>
            反馈列表
        </div>
        <div class="fb-batch-bar" id="batchBar" style="<%= feedbackList.Count == 0 ? "display:none;" : "" %>">
            <label><input type="checkbox" id="chkSelectAll" onchange="fbToggleAll(this)" />全选</label>
            <span class="fb-batch-count" id="batchCount"></span>
            <button type="button" class="fb-btn-batch-del" id="btnBatchDel" onclick="fbBatchDelete()">
                <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                批量删除
            </button>
        </div>
        <div class="fb-list-bd">
            <% if (feedbackList.Count == 0) { %>
            <div class="fb-empty">
                <div class="fb-empty-icon">📭</div>
                <div class="fb-empty-text">暂无反馈信息</div>
            </div>
            <% } else { %>
            <% foreach (FeedbackItem item in feedbackList) { %>
            <div class="fb-item" id="fb_<%= Server.HtmlEncode(item.Id) %>">
                <div class="fb-item-top">
                    <span class="fb-item-check"><input type="checkbox" class="fb-chk" value="<%= Server.HtmlEncode(item.Id) %>" onchange="fbUpdateBatch()" /></span>
                    <span class="fb-tag <%= GetTypeCss(item.Type) %>"><%= Server.HtmlEncode(GetTypeLabel(item.Type)) %></span>
                    <span class="fb-status <%= item.Status == "replied" ? "fb-status-replied" : "fb-status-pending" %>">
                        <%= item.Status == "replied" ? "已回复" : "待回复" %>
                    </span>
                    <span class="fb-user"><%= Server.HtmlEncode(item.StudentName) %> <span class="fb-user-num"><%= Server.HtmlEncode(item.StudentNum) %></span></span>
                    <span class="fb-date"><%= Server.HtmlEncode(item.SubmitDate) %></span>
                </div>
                <div class="fb-content"><%= Server.HtmlEncode(item.Content) %></div>
                <% if (item.Status == "replied" && !string.IsNullOrEmpty(item.Reply)) { %>
                <div class="fb-reply-box">
                    <div class="fb-reply-label">
                        <svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                        管理员回复
                    </div>
                    <div class="fb-reply-text"><%= Server.HtmlEncode(item.Reply) %></div>
                    <div class="fb-reply-date"><%= Server.HtmlEncode(item.ReplyDate) %></div>
                </div>
                <% } %>
                <div class="fb-actions">
                    <button type="button" class="fb-btn fb-btn-reply" onclick="fbShowReply('<%= Server.HtmlEncode(item.Id).Replace("'", "") %>')">
                        <svg viewBox="0 0 24 24"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>
                        <%= item.Status == "replied" ? "修改回复" : "回复" %>
                    </button>
                    <button type="button" class="fb-btn fb-btn-delete" onclick="fbDelete('<%= Server.HtmlEncode(item.Id).Replace("'", "") %>')">
                        <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                        删除
                    </button>
                </div>
                <div class="fb-reply-form" id="replyForm_<%= Server.HtmlEncode(item.Id) %>" style="display:none;">
                    <textarea id="replyText_<%= Server.HtmlEncode(item.Id) %>" placeholder="请输入回复内容..." style="display:block;width:100%;min-height:80px;box-sizing:border-box;"><%= Server.HtmlEncode(item.Reply) %></textarea>
                    <div class="fb-reply-form-actions">
                        <button type="button" class="fb-btn fb-btn-reply" onclick="fbSubmitReply('<%= Server.HtmlEncode(item.Id).Replace("'", "") %>')">
                            <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                            提交回复
                        </button>
                        <button type="button" class="fb-btn fb-btn-delete" onclick="fbHideReply('<%= Server.HtmlEncode(item.Id).Replace("'", "") %>')" style="border-color:#e2e8f0 !important; color:#64748b;">
                            取消
                        </button>
                    </div>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>
    </div>
</div>

<script type="text/javascript">
    function fbShowReply(id) {
        // 隐藏其他打开的回复表单
        var forms = document.querySelectorAll('.fb-reply-form');
        for (var i = 0; i < forms.length; i++) {
            forms[i].style.display = 'none';
        }
        var form = document.getElementById('replyForm_' + id);
        if (form) {
            form.style.display = 'block';
            var ta = document.getElementById('replyText_' + id);
            if (ta) ta.focus();
        }
    }

    function fbHideReply(id) {
        var form = document.getElementById('replyForm_' + id);
        if (form) form.style.display = 'none';
    }

    function fbSubmitReply(id) {
        var ta = document.getElementById('replyText_' + id);
        if (!ta || !ta.value.trim()) {
            alert('请输入回复内容');
            return;
        }
        document.getElementById('<%= HiddenReplyId.ClientID %>').value = id;
        document.getElementById('<%= TxtReply.ClientID %>').value = ta.value.trim();
        document.getElementById('<%= BtnReply.ClientID %>').click();
    }

    function fbDelete(id) {
        if (!confirm('确定要删除这条反馈吗？')) return;
        document.getElementById('<%= HiddenDeleteId.ClientID %>').value = id;
        document.getElementById('<%= BtnDelete.ClientID %>').click();
    }

    function fbToggleAll(master) {
        var checks = document.querySelectorAll('.fb-chk');
        for (var i = 0; i < checks.length; i++) {
            checks[i].checked = master.checked;
        }
        fbUpdateBatch();
    }

    function fbUpdateBatch() {
        var checks = document.querySelectorAll('.fb-chk');
        var selected = 0;
        for (var i = 0; i < checks.length; i++) {
            if (checks[i].checked) selected++;
        }
        var countEl = document.getElementById('batchCount');
        var btnEl = document.getElementById('btnBatchDel');
        var masterEl = document.getElementById('chkSelectAll');
        if (selected > 0) {
            countEl.textContent = '已选择 ' + selected + ' 条';
            btnEl.classList.add('show');
        } else {
            countEl.textContent = '';
            btnEl.classList.remove('show');
        }
        if (masterEl) {
            masterEl.checked = checks.length > 0 && selected === checks.length;
        }
    }

    function fbBatchDelete() {
        var checks = document.querySelectorAll('.fb-chk');
        var ids = [];
        for (var i = 0; i < checks.length; i++) {
            if (checks[i].checked) ids.push(checks[i].value);
        }
        if (ids.length === 0) {
            alert('请先选择要删除的反馈');
            return;
        }
        if (!confirm('确定要删除选中的 ' + ids.length + ' 条反馈吗？')) return;
        document.getElementById('<%= HiddenBatchDeleteIds.ClientID %>').value = ids.join(',');
        document.getElementById('<%= BtnBatchDelete.ClientID %>').click();
    }
</script>
</asp:Content>
