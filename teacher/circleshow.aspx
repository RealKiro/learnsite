<%@ page language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" stylesheettheme="Teacher" codebehind="circleshow.aspx.cs" inherits="Teacher_circleshow, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <style>
        /* ===== 循环展播页面美化 ===== */
        .circleshow-page {
            max-width: 1600px;
            margin: 0 auto;
            padding: 0;
        }

        /* 页面标题栏 */
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            padding: 20px 24px;
            border-radius: 12px 12px 0 0;
            margin-bottom: 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }
        .page-header h1 {
            font-size: 20px;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .page-header h1 .title-icon {
            width: 40px;
            height: 40px;
            background: rgba(255,255,255,0.2);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .page-header h1 .title-icon svg {
            width: 24px;
            height: 24px;
            stroke: #fff;
            fill: none;
            stroke-width: 2;
        }

        /* 控制栏 */
        .control-bar {
            background: #fff;
            padding: 16px 24px;
            border-bottom: 1px solid #e8ecf1;
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }
        .control-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .control-group-label {
            font-size: 14px;
            font-weight: 600;
            color: #334155;
            white-space: nowrap;
        }
        .control-bar .btn-group {
            display: flex;
            gap: 8px;
        }
        .control-bar .btn-group button,
        .control-bar .btn-group .btn {
            height: 38px;
            padding: 0 18px;
            border: none;
            border-radius: 10px;
            background: #f1f5f9;
            color: #334155;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        .control-bar .btn-group button:hover,
        .control-bar .btn-group .btn:hover {
            background: #e2e8f0;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .control-bar .btn-group button:active,
        .control-bar .btn-group .btn:active {
            background: #cbd5e1;
            transform: translateY(0);
        }
        .control-bar .btn-primary {
            background: #4f46e5;
            color: #fff;
        }
        .control-bar .btn-primary:hover {
            background: #4338ca;
        }
        .control-bar .nav-arrows {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .control-bar .nav-arrows img {
            width: 24px;
            height: 24px;
            cursor: pointer;
            opacity: 0.6;
            transition: all 0.2s;
            padding: 4px;
            border-radius: 6px;
        }
        .control-bar .nav-arrows img:hover {
            opacity: 1;
            background: #f1f5f9;
        }
        .control-bar select {
            height: 38px;
            padding: 0 14px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            background: #fff;
            font-size: 14px;
            color: #334155;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            min-width: 120px;
        }
        .control-bar select:hover {
            border-color: #94a3b8;
            box-shadow: 0 0 0 3px rgba(148,163,184,0.1);
        }
        .control-bar select:focus {
            outline: none;
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        }
        .page-counter {
            font-size: 13px;
            color: #64748b;
            font-weight: 600;
            padding: 0 12px;
        }

        /* 学生姓名显示 */
        .student-name-display {
            display: none;
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            border-radius: 12px;
            margin: 16px 24px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .student-name-display.show {
            display: block;
            animation: slideDown 0.3s ease;
        }
        .student-name-display label {
            font-size: 32px;
            font-weight: 700;
            color: #92400e;
            margin: 0;
        }
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 评分栏 */
        .rating-bar {
            background: #fff;
            padding: 20px 24px;
            border-bottom: 1px solid #e8ecf1;
        }
        .rating-bar-top {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 16px;
        }
        .rating-bar-bottom {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .rating-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .rating-group-label {
            font-size: 14px;
            font-weight: 600;
            color: #334155;
            white-space: nowrap;
        }
        .rating-group img {
            width: 24px;
            height: 24px;
            cursor: pointer;
            transition: transform 0.2s;
            opacity: 0.7;
        }
        .rating-group img:hover {
            transform: scale(1.1);
            opacity: 1;
        }
        .rating-group input[type="text"],
        .rating-group input[type="text"]:focus,
        .rating-group .comment-input,
        .rating-group .score-input {
            height: 40px !important;
            padding: 0 16px !important;
            border: none !important;
            border-radius: 10px !important;
            background: #3b82f6 !important;
            font-size: 14px !important;
            color: #fff !important;
            transition: all 0.2s !important;
            font-weight: 500 !important;
            box-sizing: border-box !important;
        }
        .rating-group input[type="text"]::placeholder,
        .rating-group .comment-input::placeholder,
        .rating-group .score-input::placeholder {
            color: rgba(255,255,255,0.7) !important;
        }
        .rating-group input[type="text"]:focus,
        .rating-group .comment-input:focus,
        .rating-group .score-input:focus {
            outline: none !important;
            background: #2563eb !important;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.2) !important;
        }
        .rating-group .score-input {
            width: 70px !important;
            text-align: center !important;
            font-weight: 600 !important;
            font-size: 15px !important;
        }
        .rating-group .comment-input {
            min-width: 300px !important;
            flex: 1 !important;
            max-width: 500px !important;
        }

        /* 等级选择 */
        .grade-selector {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .grade-selector label {
            font-size: 14px;
            font-weight: 600;
            color: #334155;
            margin: 0;
        }
        .grade-selector input[type="radio"] {
            width: 22px;
            height: 22px;
            cursor: pointer;
            margin: 0 4px;
            accent-color: #6366f1;
        }
        .grade-selector input[type="radio"] + label {
            font-size: 16px;
            font-weight: 600;
            color: #475569;
            cursor: pointer;
            padding: 6px 10px;
            border-radius: 8px;
            transition: all 0.2s;
            margin-left: 2px;
        }
        .grade-selector input[type="radio"]:checked + label {
            background: #6366f1;
            color: #fff;
        }
        .grade-selector input[type="radio"]:hover + label {
            background: #f1f5f9;
        }
        .grade-selector input[type="radio"]:checked:hover + label {
            background: #4f46e5;
        }

        /* 操作按钮组 */
        .action-buttons {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .action-buttons img {
            width: 24px;
            height: 24px;
            cursor: pointer;
            opacity: 0.7;
            transition: all 0.2s;
            padding: 6px;
            border-radius: 8px;
        }
        .action-buttons img:hover {
            opacity: 1;
            background: #f1f5f9;
            transform: scale(1.1);
        }
        .action-buttons select {
            height: 36px;
            padding: 0 12px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            background: #fff;
            font-size: 13px;
            color: #334155;
            cursor: pointer;
            transition: all 0.2s;
        }
        .action-buttons select:hover {
            border-color: #94a3b8;
        }
        .action-buttons select:focus {
            outline: none;
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
        }
        /* 绿色勾选图标特殊样式 */
        .action-buttons img[src*="check.png"] {
            width: 28px;
            height: 28px;
            opacity: 1;
            background: #10b981;
            border-radius: 50%;
            padding: 4px;
        }
        .action-buttons img[src*="check.png"]:hover {
            background: #059669;
            transform: scale(1.05);
        }

        /* 筛选选项 */
        .filter-options {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filter-options .filter-checkbox {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            background: #f1f5f9;
            border-radius: 10px;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        .filter-options .filter-checkbox:hover {
            background: #e2e8f0;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .filter-options .filter-checkbox input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #6366f1;
            margin: 0;
        }
        .filter-options .filter-checkbox label {
            font-size: 13px;
            font-weight: 500;
            color: #334155;
            cursor: pointer;
            margin: 0;
        }
        .filter-options img {
            width: 20px;
            height: 20px;
            cursor: pointer;
            opacity: 0.6;
            transition: all 0.2s;
            padding: 4px;
            border-radius: 6px;
        }
        .filter-options img:hover {
            opacity: 1;
            background: #fee2e2;
            transform: scale(1.1);
        }

        /* 作品展示区 */
        .works-display {
            background: #fff;
            min-height: calc(80vh - 200px);
            padding: 24px;
            border-radius: 0 0 12px 12px;
            overflow: auto;
        }
        .works-display::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        .works-display::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }
        .works-display::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }

        /* 底部链接 */
        .footer-link {
            text-align: center;
            padding: 16px;
        }
        .footer-link a {
            color: #6366f1;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: color 0.2s;
        }
        .footer-link a:hover {
            color: #4f46e5;
            text-decoration: underline;
        }

        /* 响应式设计 */
        @media (max-width: 1200px) {
            .control-bar {
                flex-direction: column;
                align-items: stretch;
            }
            .control-group {
                width: 100%;
                justify-content: space-between;
            }
            .rating-bar {
                flex-direction: column;
                align-items: stretch;
            }
            .rating-group {
                width: 100%;
                justify-content: space-between;
            }
        }
    </style>

    <div class="circleshow-page">
        <!-- 页面标题 -->
        <div class="page-header">
            <h1>
                <span class="title-icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/>
                        <polyline points="10 9 9 9 8 9"/>
                    </svg>
                </span>
                <asp:Label ID="LabeMtitle" runat="server"></asp:Label>
            </h1>
        </div>

        <!-- 控制栏 -->
        <div class="control-bar">
            <div class="control-group">
                <span class="control-group-label">播放控制</span>
                <div class="btn-group">
                    <asp:Button ID="Btnflash" runat="server" Text="刷新" onclick="Btnflash_Click" 
                        SkinID="BtnSmall" CssClass="btn" />
                    <asp:Button ID="Btnrestart" runat="server" Text="重新" onclick="Btnrestart_Click" 
                        SkinID="BtnSmall" CssClass="btn" />
                    <asp:Button ID="Btnstop" runat="server" Text="继续" onclick="Btnstop_Click" 
                        SkinID="BtnSmall" CssClass="btn btn-primary" />
                </div>
            </div>

            <div class="control-group">
                <span class="control-group-label">作品导航</span>
                <div class="nav-arrows">
                    <asp:ImageButton ID="ImgBtnLeft" runat="server" ImageUrl="~/images/left.png" 
                        onclick="ImgBtnLeft_Click" />
                </div>
                <asp:DropDownList ID="DDLstore" runat="server" 
                    Font-Bold="True" Width="120px" AutoPostBack="True" Font-Size="13px" 
                    onselectedindexchanged="DDLstore_SelectedIndexChanged">
                    <asp:ListItem></asp:ListItem>
                </asp:DropDownList>
                <div class="nav-arrows">
                    <asp:ImageButton ID="ImgBtnright" runat="server" 
                        ImageUrl="~/images/right.png" onclick="ImgBtnright_Click" />
                </div>
                <asp:Label ID="Labelnum" runat="server" Font-Names="Arial" Font-Size="12px" CssClass="page-counter"></asp:Label>
            </div>
        </div>

        <!-- 学生姓名显示 -->
        <div id="stuname" class="student-name-display">
            <asp:Label ID="Labelname" runat="server"></asp:Label>
        </div>
        <asp:Label ID="lbcurindex" runat="server" Text="0" Visible="False"></asp:Label>

        <!-- 评分栏 -->
        <div class="rating-bar">
            <div class="rating-bar-top">
                <div class="rating-group">
                    <asp:ImageButton ID="ImgBtnTextbox" runat="server" CommandName="v" 
                        ImageUrl="~/images/peer_review.png" onclick="ImgBtnTextbox_Click" />
                    <span class="rating-group-label">教师评语：</span>
                <asp:TextBox ID="TextBoxWself" runat="server" 
                    CssClass="comment-input"></asp:TextBox>
                </div>

                <div class="rating-group">
                    <asp:Image ID="Image2" runat="server" ImageUrl="~/images/token.png" />
                    <span class="rating-group-label">加分：</span>
                <asp:TextBox ID="TextBoxWdsocre" runat="server" MaxLength="2" 
                    SkinID="TextBoxNum" CssClass="score-input">0</asp:TextBox>
                </div>

                <div class="grade-selector">
                    <asp:RadioButtonList ID="RBLselect" runat="server" RepeatDirection="Horizontal" 
                        Visible="True" Font-Size="18px" AutoPostBack="True" 
                        onselectedindexchanged="RBLselect_SelectedIndexChanged" RepeatLayout="Flow" 
                        CellPadding="0" CellSpacing="12">
                        <asp:ListItem>G</asp:ListItem>
                        <asp:ListItem>A</asp:ListItem>
                        <asp:ListItem>B</asp:ListItem>
                        <asp:ListItem>C</asp:ListItem>
                        <asp:ListItem>D</asp:ListItem>
                        <asp:ListItem>E</asp:ListItem>
                        <asp:ListItem>O</asp:ListItem>
                    </asp:RadioButtonList>
                </div>

                <div class="action-buttons" style="margin-left: auto;">
                    <asp:ImageButton ID="ImgBtn" runat="server" ImageUrl="~/images/refresh.gif" 
                        onclick="ImgBtn_Click" ToolTip="循环展播专用刷新" />
                    <asp:ImageButton ID="BtnCheck" runat="server" onclick="BtnCheck_Click" 
                        ImageUrl="~/images/check.png" ToolTip="将自动得分作品设置为已评" />
                    <img id="showname" src="../images/help.png" alt="显示姓名" />
                    <asp:DropDownList ID="DDLname" runat="server" AutoPostBack="True" 
                        Width="80px" onselectedindexchanged="DDLname_SelectedIndexChanged">
                        <asp:ListItem></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="rating-bar-bottom">
                <div class="filter-options">
                    <div class="filter-checkbox">
                        <asp:CheckBox ID="CkselectG" runat="server" Text="筛Ｇ评" 
                            ToolTip="推荐作品筛选" AutoPostBack="True" 
                            oncheckedchanged="CkselectG_CheckedChanged" />
                    </div>
                    <div class="filter-checkbox">
                        <asp:CheckBox ID="CheckselectA" runat="server" Text="筛A评" 
                            ToolTip="优秀作品筛选" AutoPostBack="True" 
                            oncheckedchanged="CheckselectA_CheckedChanged" />
                    </div>
                    <div class="filter-checkbox">
                        <asp:CheckBox ID="CheckBoxW" runat="server" Text="筛未评" 
                            ToolTip="未评作品筛选" AutoPostBack="True" 
                            oncheckedchanged="CheckBoxW_CheckedChanged" />
                    </div>
                    <asp:ImageButton ID="ImageBtnDel" runat="server" ImageUrl="~/images/delete.gif" 
                        onclick="ImageBtnDel_Click" ToolTip="删除作品" />
                </div>
            </div>
        </div>

        <!-- 作品展示区 -->
        <div class="works-display">
            <asp:Literal ID="Literal1" runat="server"></asp:Literal>
        </div>

        <!-- 底部链接 -->
        <div class="footer-link">
            <asp:HyperLink ID="Hlcode" runat="server" Font-Size="13px" Target="_blank" 
                Visible="False" CssClass="HyperlinkNormal">查看脚本</asp:HyperLink>
        </div>
    </div>

    <script type="text/javascript">
        function myrefresh() {
            var stxt = document.getElementById("<%= Btnstop.ClientID %>").value;
            if (stxt == "暂停") {
                document.getElementById("<%= ImgBtn.ClientID %>").click();
            }
        }
        setTimeout("myrefresh()", 8000); //指定8秒刷新一次作品
        
        $("#showname").click(function () {
            $("#stuname").toggleClass("show");
        });
    </script>
</asp:Content>
