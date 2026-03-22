<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_courseanalyse, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <style>
        .analyse-page { max-width: 1400px; margin: 0 auto; padding: 0 20px; }
        .analyse-page .page-title-bar {
            display: flex; align-items: center; margin-bottom: 20px;
        }
        .analyse-page .page-title-bar h2 {
            font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .analyse-page .page-title-bar h2 .title-icon {
            width: 36px; height: 36px; background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .analyse-page .page-title-bar h2 .title-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        /* 说明板块 */
        .analyse-info-panel {
            background: linear-gradient(135deg, #eff6ff 0%, #f5f3ff 100%);
            border: 1px solid #c7d2fe; border-radius: 12px;
            padding: 20px 28px; margin-bottom: 20px;
            display: flex; gap: 16px; align-items: flex-start;
        }
        .analyse-info-panel .info-icon {
            width: 40px; height: 40px; min-width: 40px;
            background: linear-gradient(135deg, #6366f1, #818cf8);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
        }
        .analyse-info-panel .info-icon svg {
            width: 20px; height: 20px; stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .analyse-info-panel .info-body h4 {
            font-size: 15px; font-weight: 700; color: #3730a3; margin: 0 0 8px 0;
        }
        .analyse-info-panel .info-body p {
            font-size: 13px; color: #4338ca; line-height: 1.7; margin: 0;
        }
        .analyse-info-panel .info-tips {
            display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px;
        }
        .analyse-info-panel .info-tips .tip-tag {
            display: inline-flex; align-items: center; gap: 4px;
            background: #fff; border: 1px solid #c7d2fe; border-radius: 6px;
            padding: 4px 10px; font-size: 12px; color: #4f46e5; font-weight: 500;
        }
        .analyse-info-panel .info-tips .tip-tag svg {
            width: 12px; height: 12px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .analyse-card {
            background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            overflow: hidden;
        }
        .analyse-header {
            padding: 20px 28px; border-bottom: 1px solid #f1f5f9;
            text-align: center;
        }
        .analyse-header .course-title {
            font-size: 18px; font-weight: 700; color: #1e293b; margin-bottom: 8px;
        }
        .analyse-header .course-dist {
            font-size: 13px; color: #64748b;
        }
        .analyse-nav {
            display: flex; align-items: center; justify-content: center;
            gap: 12px; padding: 14px 28px; background: #f8fafc;
            border-bottom: 1px solid #f1f5f9;
        }
        .analyse-nav .nav-btn {
            width: 32px; height: 32px; border: 1px solid #d1d5db; border-radius: 8px;
            background: #fff; cursor: pointer; display: flex; align-items: center;
            justify-content: center; transition: all 0.2s; padding: 0;
        }
        .analyse-nav .nav-btn:hover {
            border-color: #818cf8; background: #f5f3ff;
        }
        .analyse-nav .nav-btn img { width: 14px; height: 14px; }
        .analyse-nav select {
            height: 34px; padding: 0 12px; border: 1px solid #d1d5db;
            border-radius: 8px; background: #fff; font-size: 14px; font-weight: 600;
            color: #334155; outline: none; cursor: pointer; transition: all 0.2s;
        }
        .analyse-nav select:hover { border-color: #818cf8; }
        .analyse-nav select:focus {
            border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        }
        .analyse-nav .nav-count {
            font-size: 12px; color: #94a3b8; margin-left: 4px;
        }
        .analyse-return {
            display: flex; justify-content: center; padding: 12px 28px;
            border-bottom: 1px solid #f1f5f9;
        }
        .analyse-return .btn-return {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 16px; border: 1px solid #d1d5db; border-radius: 8px;
            background: #fff; color: #475569; font-size: 13px; font-weight: 500;
            cursor: pointer; text-decoration: none; transition: all 0.2s;
        }
        .analyse-return .btn-return:hover {
            border-color: #818cf8; color: #4f46e5; background: #f5f3ff;
        }
        .analyse-return .btn-return img { width: 14px; height: 14px; }
        .analyse-content {
            padding: 28px; font-size: 14px; color: #334155;
            text-align: center;
        }
        /* 分析内容中的表格美化 */
        .analyse-content table {
            border-collapse: collapse; margin: 0 auto; width: 100%;
        }
        .analyse-content table td {
            padding: 10px 16px; font-size: 13px; color: #334155;
            border-bottom: 1px solid #f1f5f9;
        }
        .analyse-content table tr:hover td {
            background: #f8fafc;
        }
        .analyse-content a {
            color: #6366f1; text-decoration: none; font-weight: 500;
        }
        .analyse-content a:hover { color: #4f46e5; text-decoration: underline; }
        .analyse-content img { vertical-align: middle; }
    </style>

    <div class="analyse-page">
        <div class="page-title-bar">
            <h2>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24"><path d="M21 12V7H5a2 2 0 0 1 0-4h14v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-5"/><path d="M18 12a2 2 0 0 0 0 4h4v-4z"/></svg>
                </span>
                作品分析
            </h2>
        </div>

        <div class="analyse-info-panel">
            <div class="info-icon">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            </div>
            <div class="info-body">
                <h4>功能说明</h4>
                <p>本页面用于查看和分析学生提交的课程作品。您可以通过左右导航按钮或下拉列表逐一浏览每位学生的作品，了解作品完成情况与提交详情。点击返回按钮可回到课程列表。</p>
                <div class="info-tips">
                    <span class="tip-tag">
                        <svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                        逐一浏览学生作品
                    </span>
                    <span class="tip-tag">
                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        查看提交详情
                    </span>
                    <span class="tip-tag">
                        <svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg>
                        分析完成情况
                    </span>
                </div>
            </div>
        </div>

        <div class="analyse-card">
            <div class="analyse-header">
                <div class="course-title">
                    <asp:Label ID="Labeltitle" runat="server" Font-Bold="True"></asp:Label>
                </div>
                <div class="course-dist">
                    <asp:Label ID="Labeldistribution" runat="server"></asp:Label>
                </div>
            </div>

            <div id="divview" runat="server" visible="false" class="analyse-nav">
                <asp:ImageButton ID="ImgBtnLeft" runat="server" ImageUrl="~/images/left.png" 
                    onclick="ImgBtnLeft_Click" Width="16px" CssClass="nav-btn" />
                <asp:DropDownList ID="DDLstore" runat="server" 
                    Font-Bold="True" Width="100px" AutoPostBack="True"
                    onselectedindexchanged="DDLstore_SelectedIndexChanged">
                    <asp:ListItem></asp:ListItem>
                </asp:DropDownList>
                <asp:ImageButton ID="ImgBtnright" runat="server" 
                    ImageUrl="~/images/right.png" onclick="ImgBtnright_Click" 
                    Width="16px" CssClass="nav-btn" />
                <span class="nav-count">
                    <asp:Label ID="lbcount" runat="server"></asp:Label>
                </span>
            </div>

            <div class="analyse-return">
                <asp:ImageButton ID="ImageButton1" runat="server" 
                    ImageUrl="~/images/return.gif" Width="16px" onclick="ImageButton1_Click" 
                    CssClass="btn-return" ToolTip="返回" />
            </div>

            <div class="analyse-content">
                <asp:Literal ID="Literal1" runat="server"></asp:Literal>
            </div>
        </div>
    </div>
</asp:Content>

