<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" CodeFile="knowledge.aspx.cs" Inherits="LearnSite.Teacher_knowledge" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .kb-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .kb-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .kb-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .kb-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .kb-title .kb-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .kb-title .kb-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .kb-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    /* 卡片 */
    .kb-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .kb-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .kb-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .kb-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .kb-card-body { padding: 24px; }

    /* 上传表单 */
    .kb-upload-form { display: flex; flex-direction: column; gap: 16px; }
    .kb-form-row { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .kb-form-group { display: flex; align-items: center; gap: 8px; }
    .kb-form-group label {
        font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap; min-width: 70px;
    }
    .kb-form-group input[type="text"] {
        padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; font-family: inherit; min-width: 360px;
    }
    .kb-form-group input[type="text"]:focus {
        border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1);
    }
    .kb-form-group select {
        padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; font-family: inherit; min-width: 140px;
    }
    .kb-form-group select:focus {
        border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1);
    }
    .kb-upload-area {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 16px 20px; background: #f8fafc; border: 1px dashed #d1d5db;
        border-radius: 10px;
    }
    .kb-upload-area label { font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap; min-width: 70px; }

    /* 按钮 */
    .kb-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 24px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .kb-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .kb-btn-primary {
        background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff;
        border-color: #6366f1; box-shadow: 0 2px 8px rgba(99,102,241,.2);
    }
    .kb-btn-primary:hover { background: linear-gradient(135deg,#4f46e5,#6366f1); border-color: #4f46e5; box-shadow: 0 4px 12px rgba(99,102,241,.3); color: #fff; }
    .kb-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 消息 */
    .kb-msg { font-size: 13px; margin-top: 8px; display: block; min-height: 20px; }
    .kb-msg-success { color: #16a34a; }
    .kb-msg-error { color: #ef4444; }

    /* 说明 */
    .kb-info-box {
        background: linear-gradient(135deg, #eef2ff, #f5f3ff);
        border: 1px solid #e0e7ff; border-radius: 12px;
        padding: 20px 24px; margin-bottom: 24px;
        display: flex; align-items: flex-start; gap: 14px;
    }
    .kb-info-icon {
        width: 40px; height: 40px; border-radius: 10px;
        background: linear-gradient(135deg,#6366f1,#818cf8);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .kb-info-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .kb-info-content h4 { font-size: 14px; font-weight: 600; color: #4338ca; margin: 0 0 8px; }
    .kb-info-content ul {
        margin: 6px 0 0; padding-left: 16px;
        font-size: 13px; color: #6366f1; line-height: 1.8;
    }

    /* 工具栏 */
    .kb-toolbar {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 16px 24px; background: #fafbfc; border-bottom: 1px solid #f1f5f9;
    }
    .kb-toolbar-group { display: flex; align-items: center; gap: 8px; }
    .kb-toolbar-group label { font-size: 13px; color: #64748b; font-weight: 500; white-space: nowrap; }
    .kb-toolbar-divider { width: 1px; height: 24px; background: #e2e8f0; }
    .kb-count { font-size: 13px; color: #94a3b8; }
    .kb-select {
        padding: 8px 16px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; cursor: pointer; font-family: inherit;
        min-width: 160px;
    }
    .kb-select:focus { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }

    /* 文件列表 */
    .kb-file-table { width: 100%; border-collapse: collapse; }
    .kb-file-table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 16px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
        white-space: nowrap;
    }
    .kb-file-table td {
        padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
        transition: background .1s;
        white-space: nowrap;
    }
    .kb-file-table tr:hover td { background: #f8fafc; }
    .kb-file-table tr:last-child td { border-bottom: none; }

    .kb-file-name {
        display: flex; align-items: center; gap: 10px; font-weight: 500;
    }
    .kb-file-icon {
        width: 32px; height: 32px; border-radius: 8px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        background: #f1f5f9;
    }
    .kb-file-icon svg {
        width: 16px; height: 16px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .kb-file-title { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
    .kb-file-title .name { color: #1e293b; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .kb-file-title .original { font-size: 11px; color: #94a3b8; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .kb-file-title .kb-desc { font-size: 11px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-style: italic; }

    /* 分类标签 */
    .kb-badge {
        display: inline-flex; align-items: center; padding: 3px 10px;
        border-radius: 6px; font-size: 12px; font-weight: 500;
    }
    .kb-badge-book { background: #dbeafe; color: #1d4ed8; }
    .kb-badge-plan { background: #dcfce7; color: #15803d; }
    .kb-badge-slide { background: #fef3c7; color: #b45309; }
    .kb-badge-exam { background: #fce7f3; color: #be185d; }
    .kb-badge-media { background: #e0e7ff; color: #4338ca; }
    .kb-badge-other { background: #f1f5f9; color: #64748b; }

    /* 操作按钮 */
    .kb-action-link {
        display: inline-flex; align-items: center; gap: 4px;
        font-size: 12px; color: #6366f1; text-decoration: none; font-weight: 500;
        padding: 4px 10px; border-radius: 6px; transition: all .15s;
    }
    .kb-action-link:hover { background: #eef2ff; color: #4f46e5; }
    .kb-action-link svg {
        width: 14px; height: 14px; stroke: currentColor; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .kb-delete-btn {
        background: none; border: none; cursor: pointer;
        display: inline-flex; align-items: center; gap: 4px;
        font-size: 12px; color: #ef4444; font-weight: 500;
        padding: 4px 10px; border-radius: 6px; transition: all .15s;
        font-family: inherit;
    }
    .kb-delete-btn:hover { background: #fef2f2; color: #dc2626; }
    .kb-delete-btn svg {
        width: 14px; height: 14px; stroke: currentColor; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    .kb-empty {
        text-align: center; padding: 60px 20px; color: #94a3b8; font-size: 14px;
    }
    .kb-empty svg {
        width: 48px; height: 48px; stroke: #d1d5db; fill: none;
        stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round;
        margin-bottom: 12px;
    }

    /* 统计卡片 */
    .kb-stats {
        display: flex; gap: 16px; margin-bottom: 24px;
    }
    .kb-stat-item {
        flex: 1; padding: 16px 20px; border-radius: 10px;
        border: 1px solid #e8ecf1; background: #fff;
        display: flex; align-items: center; gap: 14px;
        box-shadow: 0 1px 3px rgba(0,0,0,.03);
    }
    .kb-stat-icon {
        width: 42px; height: 42px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .kb-stat-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .kb-stat-icon.purple { background: linear-gradient(135deg,#6366f1,#a78bfa); }
    .kb-stat-icon.blue { background: linear-gradient(135deg,#3b82f6,#60a5fa); }
    .kb-stat-icon.green { background: linear-gradient(135deg,#10b981,#34d399); }
    .kb-stat-icon.orange { background: linear-gradient(135deg,#f59e0b,#fbbf24); }
    .kb-stat-icon.pink { background: linear-gradient(135deg,#ec4899,#f472b6); }
    .kb-stat-info { display: flex; flex-direction: column; }
    .kb-stat-label { font-size: 12px; color: #94a3b8; margin-bottom: 2px; }
    .kb-stat-value { font-size: 13px; font-weight: 600; color: #1e293b; }
</style>

<div class="kb-page">
    <!-- 页面标题 -->
    <div class="kb-header">
        <div class="kb-title-wrap">
            <div class="kb-title">
                <span class="kb-icon">
                    <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                </span>
                知识库
            </div>
            <div class="kb-subtitle">上传和管理电子课本、教案、课件、试卷等教学资料</div>
        </div>
    </div>

    <!-- 说明板块 -->
    <div class="kb-info-box">
        <div class="kb-info-icon">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        </div>
        <div class="kb-info-content">
            <h4>使用说明</h4>
            <ul>
                <li>支持上传电子课本（PDF）、教案（Word）、课件（PPT）、试卷、素材等各类教学资料</li>
                <li>支持的文件格式：PDF、Word、PPT、Excel、图片、音视频、压缩包等</li>
                <li>单个文件大小限制为 100MB，上传后可随时下载或删除</li>
                <li>可通过分类筛选快速查找所需资料</li>
            </ul>
        </div>
    </div>

    <!-- 分类统计 -->
    <div class="kb-stats">
        <div class="kb-stat-item">
            <div class="kb-stat-icon purple">
                <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
            </div>
            <div class="kb-stat-info">
                <span class="kb-stat-label">电子课本</span>
                <span class="kb-stat-value">教材、参考书等</span>
            </div>
        </div>
        <div class="kb-stat-item">
            <div class="kb-stat-icon green">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            </div>
            <div class="kb-stat-info">
                <span class="kb-stat-label">教案</span>
                <span class="kb-stat-value">教学设计、教案文档</span>
            </div>
        </div>
        <div class="kb-stat-item">
            <div class="kb-stat-icon orange">
                <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
            </div>
            <div class="kb-stat-info">
                <span class="kb-stat-label">课件</span>
                <span class="kb-stat-value">PPT、演示文稿</span>
            </div>
        </div>
        <div class="kb-stat-item">
            <div class="kb-stat-icon pink">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
            </div>
            <div class="kb-stat-info">
                <span class="kb-stat-label">试卷 / 素材</span>
                <span class="kb-stat-value">习题、图片、音视频等</span>
            </div>
        </div>
    </div>

    <!-- 上传卡片 -->
    <div class="kb-card">
        <div class="kb-card-header">
            <div class="kb-card-title">
                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                上传资料
            </div>
        </div>
        <div class="kb-card-body">
            <div class="kb-upload-form">
                <div class="kb-form-row">
                    <div class="kb-form-group">
                        <label>资料名称</label>
                        <asp:TextBox ID="Texttitle" runat="server" CssClass="kb-input" MaxLength="200" placeholder="请输入资料名称"></asp:TextBox>
                    </div>
                    <div class="kb-form-group">
                        <label>资料分类</label>
                        <asp:DropDownList ID="DDLcategory" runat="server">
                            <asp:ListItem Selected="True">电子课本</asp:ListItem>
                            <asp:ListItem>教案</asp:ListItem>
                            <asp:ListItem>课件</asp:ListItem>
                            <asp:ListItem>试卷</asp:ListItem>
                            <asp:ListItem>素材</asp:ListItem>
                            <asp:ListItem>其他</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="kb-form-group" style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; white-space: normal;">资料说明（可选）</label>
                    <asp:TextBox ID="TxtDescription" runat="server" TextMode="MultiLine" Rows="4" 
                        MaxLength="500" placeholder="如：适用年级、章节、知识点等"
                        style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;font-family:'Microsoft YaHei',Arial,sans-serif;resize:vertical;min-height:100px;line-height:1.8;"></asp:TextBox>
                    <div style="font-size:11px;color:#94a3b8;margin-top:4px;">💡 提示：添加说明可以帮助其他教师更好地了解和使用这份资料（最多500字）</div>
                </div>
                <div class="kb-upload-area">
                    <label>选择文件</label>
                    <asp:FileUpload ID="FUknowledge" runat="server" />
                </div>
                <div class="kb-form-row">
                    <asp:Button ID="Btnupload" runat="server" Text="上 传" OnClick="Btnupload_Click" CssClass="kb-btn kb-btn-primary" />
                    <asp:Label ID="Labelmsg" runat="server" CssClass="kb-msg"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <!-- 文件列表卡片 -->
    <div class="kb-card">
        <div class="kb-card-header">
            <div class="kb-card-title">
                <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                资料列表
            </div>
            <span class="kb-count">共 <asp:Label ID="LabelCount" runat="server" Text="0"></asp:Label> 个资料</span>
        </div>
        <!-- 筛选工具栏 -->
        <div class="kb-toolbar">
            <div class="kb-toolbar-group">
                <label>分类筛选：</label>
                <asp:DropDownList ID="DDLfilter" runat="server" AutoPostBack="True"
                    OnSelectedIndexChanged="DDLfilter_SelectedIndexChanged" CssClass="kb-select">
                    <asp:ListItem Selected="True">全部</asp:ListItem>
                    <asp:ListItem>电子课本</asp:ListItem>
                    <asp:ListItem>教案</asp:ListItem>
                    <asp:ListItem>课件</asp:ListItem>
                    <asp:ListItem>试卷</asp:ListItem>
                    <asp:ListItem>素材</asp:ListItem>
                    <asp:ListItem>其他</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <!-- 列表 -->
        <div class="kb-card-body" style="padding: 0;">
            <asp:Repeater ID="RptFiles" runat="server" OnItemCommand="RptFiles_ItemCommand">
                <HeaderTemplate>
                    <table class="kb-file-table">
                        <thead>
                            <tr>
                                <th style="width:50px">#</th>
                                <th>资料名称</th>
                                <th style="width:90px">分类</th>
                                <th style="width:80px">大小</th>
                                <th style="width:100px">上传者</th>
                                <th style="width:150px">上传时间</th>
                                <th style="width:140px">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("Index") %></td>
                        <td>
                            <div class="kb-file-name">
                                <div class="kb-file-icon"><%# GetFileIcon(Eval("Ext").ToString()) %></div>
                                <div class="kb-file-title">
                                    <span class="name"><%# Server.HtmlEncode(Eval("Title").ToString()) %></span>
                                    <span class="original"><%# Server.HtmlEncode(Eval("OriginalName").ToString()) %></span>
                                    <%# !string.IsNullOrEmpty(Eval("Description").ToString()) ? "<span class='kb-desc' title='" + Server.HtmlEncode(Eval("Description").ToString()) + "'>📝 " + Server.HtmlEncode(Eval("Description").ToString()) + "</span>" : "" %>
                                </div>
                            </div>
                        </td>
                        <td><span class="kb-badge <%# GetCategoryBadgeClass(Eval("Category").ToString()) %>"><%# Server.HtmlEncode(Eval("Category").ToString()) %></span></td>
                        <td><%# Eval("SizeText") %></td>
                        <td><%# Server.HtmlEncode(Eval("Uploader").ToString()) %></td>
                        <td><%# Eval("UploadTime") %></td>
                        <td>
                            <a href='<%# Eval("DownloadUrl") %>' target="_blank" class="kb-action-link">
                                <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                下载
                            </a>
                            <asp:LinkButton ID="BtnDelete" runat="server" CommandName="DeleteFile"
                                CommandArgument='<%# Eval("Id") %>' CssClass="kb-delete-btn"
                                OnClientClick="return confirm('确定要删除这个资料吗？');">
                                <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                删除
                            </asp:LinkButton>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>

<script type="text/javascript">
    // 文件选择后自动填充文件名
    (function () {
        var fileInput = document.querySelector('[id$="FUknowledge"]');
        var titleInput = document.querySelector('[id$="Texttitle"]');
        
        if (fileInput && titleInput) {
            fileInput.addEventListener('change', function () {
                if (this.files && this.files.length > 0) {
                    var fileName = this.files[0].name;
                    // 移除文件扩展名
                    var nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.')) || fileName;
                    // 只在标题为空时自动填充
                    if (!titleInput.value || titleInput.value.trim() === '') {
                        titleInput.value = nameWithoutExt;
                    }
                }
            });
        }
    })();

    // 上传成功/失败消息样式
    (function () {
        var msgEl = document.querySelector('.kb-msg');
        if (msgEl && msgEl.textContent) {
            var txt = msgEl.textContent.trim();
            if (txt.indexOf('成功') >= 0 || txt.indexOf('已删除') >= 0) {
                msgEl.classList.add('kb-msg-success');
            } else if (txt.length > 0) {
                msgEl.classList.add('kb-msg-error');
            }
        }
    })();
</script>
</asp:Content>
