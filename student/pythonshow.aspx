<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" stylesheettheme="Student" CodeFile="pythonshow.aspx.cs" inherits="Student_pythonshow" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<%
    // 所有Python任务统一重定向到program.aspx
    string _lid = Request.QueryString["lid"] ?? "";
    if (!string.IsNullOrEmpty(_lid))
    {
        string midParam = Request.QueryString["mid"] ?? "";
        string mcidParam = Request.QueryString["mcid"] ?? "";
        string redirectUrl = "program.aspx?lid=" + Server.UrlEncode(_lid);
        if (!string.IsNullOrEmpty(midParam)) redirectUrl += "&mid=" + Server.UrlEncode(midParam);
        if (!string.IsNullOrEmpty(mcidParam)) redirectUrl += "&mcid=" + Server.UrlEncode(mcidParam);
        Response.Redirect(redirectUrl, true);
    }
%>
<link href="../kindeditor/themes/me/me.css" rel="stylesheet" type="text/css" />
<script charset="utf-8" src="../kindeditor/kindeditor-min.js"></script>
<script charset="utf-8" src="../kindeditor/lang/zh_CN.js"></script>
<style>
    /* ===== Python任务详情页面样式 ===== */
    * { box-sizing: border-box; }

    .mission-container {
        max-width: 1500px;
        margin: 0 auto;
        padding: 20px;
    }

    /* 任务标题 */
    .mission-header {
        background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 50%, #6d28d9 100%);
        color: #fff;
        padding: 32px;
        border-radius: 16px;
        margin-bottom: 24px;
        box-shadow: 0 4px 20px rgba(139, 92, 246, 0.25);
        position: relative;
        overflow: hidden;
    }
    .mission-header::before {
        content: '';
        position: absolute;
        top: -40px;
        right: -40px;
        width: 140px;
        height: 140px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }

    .mission-header h1 {
        margin: 0;
        font-size: 26px;
        font-weight: 700;
        position: relative;
        z-index: 1;
    }
    .mission-header .desc {
        margin-top: 8px;
        font-size: 14px;
        color: rgba(255,255,255,.85);
        position: relative;
        z-index: 1;
    }

    /* 内容布局 */
    .mission-layout {
        display: grid;
        grid-template-columns: 1fr 300px;
        gap: 24px;
        align-items: start;
    }

    /* 任务内容区 */
    .mission-content {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        padding: 32px;
        min-height: 400px;
    }

    /* 任务信息卡片 */
    .py-task-info {
        background: #f8fafc;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 24px;
        border: 1px solid #e5e7eb;
    }

    .py-task-info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
    }

    .py-task-info-item {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .py-task-info-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        background: #fff;
        border: 1px solid #e5e7eb;
    }

    .py-task-info-icon svg {
        width: 18px;
        height: 18px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
    }

    .py-task-info-icon.date { color: #3b82f6; }
    .py-task-info-icon.type { color: #8b5cf6; }
    .py-task-info-icon.example { color: #10b981; }
    .py-task-info-icon.standard { color: #f59e0b; }

    .py-task-info-content { flex: 1; }

    .py-task-info-label {
        font-size: 12px;
        color: #6b7280;
        font-weight: 600;
        margin-bottom: 2px;
    }

    .py-task-info-value {
        font-size: 14px;
        color: #1f2937;
        font-weight: 600;
    }

    .py-task-info-value a {
        color: #8b5cf6;
        text-decoration: none;
        transition: all 0.2s;
    }

    .py-task-info-value a:hover {
        color: #7c3aed;
        text-decoration: underline;
    }

    /* 隐藏文件类型图片 */
    .py-task-info-item img,
    img[id*="ImageType"] {
        display: none !important;
    }

    /* 任务内容 */
    .py-task-content {
        font-size: 16px;
        color: #334155;
        line-height: 1.9;
    }

    .py-task-content h1,
    .py-task-content h2,
    .py-task-content h3 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 32px;
        margin-bottom: 16px;
        padding-left: 20px;
        border-left: 5px solid #8b5cf6;
    }

    .py-task-content h1 { font-size: 32px; }
    .py-task-content h2 { font-size: 26px; }
    .py-task-content h3 { font-size: 22px; }

    .py-task-content p { margin-bottom: 16px; }

    .py-task-content img {
        max-width: 100%;
        height: auto;
        border-radius: 12px;
        margin: 24px 0;
    }

    /* 侧边栏 */
    .mission-sidebar {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        padding: 24px;
        position: sticky;
        top: 20px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }

    /* 按钮通用样式 */
    .btn {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        width: 100%;
        height: 48px;
        border-radius: 12px;
        font-size: 15px;
        font-weight: 600;
        margin-bottom: 14px;
        cursor: pointer;
        border: none;
        text-decoration: none;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s;
    }

    .btn:hover::before { left: 100%; }

    .btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
    }

    .btn:active {
        transform: translateY(-1px);
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.12);
    }

    .btn-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        border-radius: 6px;
        flex-shrink: 0;
    }

    .btn-icon svg {
        width: 16px;
        height: 16px;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    /* 网盘按钮 */
    .btn-disk {
        background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
        color: #fff;
        font-weight: 700;
        letter-spacing: 1px;
    }

    .btn-disk .btn-icon { background: rgba(255, 255, 255, 0.2); }
    .btn-disk .btn-icon svg { stroke: #fff; }
    .btn-disk {
        background-image:
            url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z'/%3E%3C/svg%3E"),
            linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
        background-repeat: no-repeat, no-repeat;
        background-position: 20px center, center;
        background-size: 18px 18px, cover;
        padding-left: 48px;
    }

    /* 上传按钮 */
    .btn-upload {
        background: linear-gradient(135deg, #a78bfa 0%, #8b5cf6 100%);
        color: #fff;
        font-size: 18px;
        height: 64px;
        box-shadow: 0 4px 20px rgba(139, 92, 246, 0.35);
        position: relative;
        overflow: hidden;
        border: none;
        font-weight: 700;
        letter-spacing: 2px;
        cursor: pointer;
    }

    .btn-upload .btn-icon {
        width: 32px;
        height: 32px;
        background: rgba(255, 255, 255, 0.2);
    }

    .btn-upload .btn-icon svg {
        width: 18px;
        height: 18px;
        stroke: #fff;
    }

    .btn-upload:hover {
        box-shadow: 0 8px 30px rgba(139, 92, 246, 0.5);
        background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
        transform: translateY(-2px);
    }
    .btn-upload {
        background-image:
            url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'/%3E%3Cpolyline points='17 8 12 3 7 8'/%3E%3Cline x1='12' y1='3' x2='12' y2='15'/%3E%3C/svg%3E"),
            linear-gradient(135deg, #a78bfa 0%, #8b5cf6 100%);
        background-repeat: no-repeat, no-repeat;
        background-position: 20px center, center;
        background-size: 20px 20px, cover;
        padding-left: 52px;
    }

    /* 互评按钮 */
    .btn-vote {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        color: #fff;
        font-weight: 700;
        letter-spacing: 1px;
    }

    .btn-vote .btn-icon { background: rgba(255, 255, 255, 0.2); }
    .btn-vote .btn-icon svg { stroke: #fff; fill: #fff; }

    /* 分隔线 */
    .divider {
        height: 1px;
        background: linear-gradient(90deg, transparent, #e5e7eb, transparent);
        margin: 24px 0;
        position: relative;
    }

    .divider::before {
        content: '作品管理';
        position: absolute;
        top: -10px;
        left: 50%;
        transform: translateX(-50%);
        background: #fff;
        padding: 0 12px;
        font-size: 12px;
        color: #94a3b8;
        font-weight: 500;
    }

    /* 文件信息 */
    .file-info {
        padding: 14px 16px;
        background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        border-radius: 10px;
        margin-bottom: 14px;
        font-size: 13px;
        color: #64748b;
        border: 1px solid #e2e8f0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .file-info img {
        width: 20px;
        height: 20px;
        vertical-align: middle;
    }

    .file-info::before {
        content: '';
        display: inline-block;
        width: 20px;
        height: 20px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/%3E%3Cpolyline points='14 2 14 8 20 8'/%3E%3Cline x1='16' y1='13' x2='8' y2='13'/%3E%3Cline x1='16' y1='17' x2='8' y2='17'/%3E%3Cpolyline points='10 9 9 9 8 9'/%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        flex-shrink: 0;
    }

    .file-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 14px 16px;
        background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
        border: 2px solid #86efac;
        border-radius: 10px;
        color: #16a34a;
        text-decoration: none;
        margin-bottom: 14px;
        font-size: 14px;
        font-weight: 600;
        transition: all 0.3s;
    }

    .file-link:hover {
        background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
        border-color: #4ade80;
        transform: translateX(3px);
    }

    .file-link::before {
        content: '';
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        background: #16a34a;
        border-radius: 50%;
        flex-shrink: 0;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='20 6 9 17 4 12'/%3E%3C/svg%3E");
        background-size: 16px 16px;
        background-repeat: no-repeat;
        background-position: center;
    }

    /* 提示信息 */
    .tip {
        padding: 12px 14px;
        background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
        border-left: 4px solid #f59e0b;
        border-radius: 8px;
        font-size: 13px;
        color: #92400e;
        margin-bottom: 14px;
        line-height: 1.6;
        display: flex;
        align-items: flex-start;
        gap: 8px;
    }

    .tip::before {
        content: '';
        display: inline-block;
        width: 18px;
        height: 18px;
        margin-top: 2px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23f59e0b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cpath d='M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3'/%3E%3Cline x1='12' y1='17' x2='12.01' y2='17'/%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        flex-shrink: 0;
    }

    /* 响应式 */
    @media (max-width: 1024px) {
        .mission-layout {
            grid-template-columns: 1fr;
        }
        .mission-sidebar {
            position: static;
        }
    }

    /* 隐藏原有的混乱元素 */
    #showcontent > br,
    .courseother {
        display: none !important;
    }
</style>

<div class="mission-container">
    <!-- 任务标题 -->
    <div class="mission-header">
        <h1><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
        <div class="desc">Python任务详情与作品提交</div>
    </div>

    <!-- 隐藏字段 -->
    <div style="display: none;">
        <asp:Label ID="LabelSnum" runat="server"></asp:Label>
        <asp:Label ID="LabelMdate" runat="server"></asp:Label>
        <asp:CheckBox ID="CkMupload" runat="server" />
        <asp:CheckBox ID="CheckPublish" runat="server" />
        <asp:CheckBox ID="CheckBack" runat="server" />
        <asp:CheckBox ID="Checkhelp" runat="server" />
        <asp:CheckBox ID="Checkblock" runat="server" />
        <asp:CheckBox ID="Checkblockpy" runat="server" />
        <asp:Image ID="ImageType" runat="server" Visible="False" />
        <asp:Label ID="LabelMfiletype" runat="server"></asp:Label>
        <asp:HyperLink ID="Hlexample" runat="server" Target="_blank"></asp:HyperLink>
        <asp:HyperLink ID="HLMgid" runat="server"></asp:HyperLink>
        <asp:Label ID="LabelMid" runat="server"></asp:Label>
        <asp:Label ID="LabelUploadType" runat="server"></asp:Label>
        <asp:Label ID="LabelMcid" runat="server"></asp:Label>
        <asp:Label ID="LabelMsort" runat="server"></asp:Label>
        <asp:Label ID="LabelLid" runat="server"></asp:Label>
        <asp:Label ID="LabelLtype" runat="server"></asp:Label>
    </div>

    <!-- 内容布局 -->
    <div class="mission-layout">
        <!-- 左侧：任务内容 -->
        <div class="mission-content">

            <!-- 任务内容 -->
            <div id="Mcontent" class="py-task-content" runat="server"></div>
        </div>

        <!-- 右侧：操作面板 -->
        <div class="mission-sidebar">
            <!-- 网盘按钮 -->
            <input type="button" class="btn btn-disk" value="我的网盘" onclick="showShare()" />

            <!-- 作品互评按钮 -->
            <asp:HyperLink ID="VoteLink" runat="server" Target="_blank" CssClass="btn btn-vote">
                <span class="btn-icon">
                    <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                </span>
                作品互评
            </asp:HyperLink>

            <div class="divider"></div>

            <!-- 个人作品上传面板 -->
            <asp:Panel ID="Panelworks" runat="server" Visible="false">
                <!-- 已提交作品显示 -->
                <div id="submittedWork" runat="server" visible="false">
                    <asp:HyperLink ID="upFileUrl" runat="server" Target="_blank" CssClass="file-link">
                        <asp:Image ID="upFileType" runat="server" style="display:none;" />
                        查看已提交作品
                    </asp:HyperLink>
                    <div class="tip">
                        <asp:Label ID="Labelmsg" runat="server" Text="已提交作品，可重新提交覆盖"></asp:Label>
                    </div>
                </div>

                <!-- 上传按钮 -->
                <asp:Panel ID="Panelswfupload" runat="server" Visible="false">
                    <input type="button" id="uploadButton" class="btn btn-upload" value="提交作品" />
                    <div style="text-align: center; margin-top: 10px; font-size: 12px; color: #94a3b8;">
                        点击上传Python文件
                    </div>
                </asp:Panel>

                <!-- 文件格式提示 -->
                <div class="file-info">
                    <asp:Image ID="ImageFileType" runat="server" />
                    <span>支持格式：<asp:Label ID="LabelFileType" runat="server"></asp:Label></span>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>

<!-- KindEditor 上传组件 -->
<script type="text/javascript">
    var lid = "<%=LabelLid.Text %>";
    var urlstr = "uploadworkm.aspx?lid=" + lid;

    KindEditor.ready(function (K) {
        var uploadBtn = document.getElementById('uploadButton');
        if (uploadBtn) {
            var uploadbutton = K.uploadbutton({
                button: uploadBtn,
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
            uploadbutton.fileBox.change(function (e) {
                uploadbutton.submit();
            });
        }
    });

</script>

</asp:Content>
