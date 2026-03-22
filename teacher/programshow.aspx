<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_programshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">

    <link href="show-common.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        window.onload = function () {
            var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
            if (btnEdit) {
                btnEdit.value = '修改任务';
                btnEdit.style.width = 'auto';
                btnEdit.style.height = 'auto';
            }

            var btnReturn = document.getElementById('<%= BtnReturnSmall.ClientID %>');
            if (btnReturn) {
                btnReturn.value = '返回列表';
                btnReturn.style.width = 'auto';
                btnReturn.style.height = 'auto';
            }
        };
    </script>

    <div class="show-container">
        <!-- 渐变标题栏（绿色统一风格） -->
        <div class="show-title-card">
            <div class="show-title-icon">
                <svg viewBox="0 0 24 24">
                    <rect x="3" y="4" width="7" height="4" rx="1" />
                    <rect x="3" y="10" width="7" height="4" rx="1" />
                    <rect x="3" y="16" width="7" height="4" rx="1" />
                    <path d="M13 6h8" />
                    <path d="M13 12h8" />
                    <path d="M13 18h8" />
                </svg>
            </div>
            <div class="show-title-text">
                <h1 class="show-title">
                    <asp:Label ID="LabelMtitle" runat="server"></asp:Label>
                </h1>
                <p class="show-title-sub">查看编程任务，指导学生完成创意作品</p>
            </div>
        </div>

        <!-- 信息卡片 -->
        <div class="show-info-card">
            <div class="show-card-head">
                <span class="show-dot"></span>
                <h3>
                    <svg viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="10" />
                        <line x1="12" y1="16" x2="12" y2="12" />
                        <line x1="12" y1="8" x2="12.01" y2="8" />
                    </svg>
                    任务信息
                </h3>
            </div>
            <div class="show-card-body">
                <div class="show-info-row">
                    <div class="show-info-item">
                        <label>日期：</label>
                        <asp:Label ID="LabelMdate" runat="server"></asp:Label>
                    </div>
                    <div class="show-info-item">
                        <label>作品类型：</label>
                        <asp:Image ID="ImageType" runat="server" />
                        <asp:Label ID="LabelMfiletype" runat="server"></asp:Label>
                    </div>
                    <div class="show-info-item">
                        <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Enabled="False" />
                    </div>
                    <div class="show-info-item">
                        <asp:CheckBox ID="CheckMicoWorld" runat="server" Text="作品继承"
                            ToolTip="加载上一节的编程作品，适合项目学习"
                            Enabled="False" />
                    </div>
                    <div class="show-info-item">
                        <label>实例：</label>
                        <asp:HyperLink ID="Hlexample" runat="server">查看实例</asp:HyperLink>
                    </div>
                    <div class="show-info-item">
                        <asp:HyperLink ID="HLMgid" runat="server">评价标准</asp:HyperLink>
                    </div>
                </div>

                <!-- 操作按钮 -->
                <div class="show-actions">
                    <asp:ImageButton ID="BtnEdit" runat="server"
                        OnClick="BtnEdit_Click"
                        ImageUrl="~/images/edit.gif"
                        CssClass="show-btn show-btn-primary"
                        AlternateText="修改任务" />
                    <asp:ImageButton ID="BtnReturnSmall" runat="server"
                        OnClick="BtnReturnSmall_Click"
                        ImageUrl="~/images/return.gif"
                        CssClass="show-btn"
                        AlternateText="返回列表" />
                </div>
            </div>
        </div>

        <!-- 内容卡片 -->
        <div class="show-content-card">
            <div id="Mcontent" class="show-content" runat="server"></div>
        </div>

        <!-- 底部返回按钮 -->
        <div class="show-footer">
            <asp:LinkButton ID="LinkBtn" runat="server" OnClick="LinkBtn_Click" CssClass="show-footer-btn">
                <svg viewBox="0 0 24 24">
                    <line x1="19" y1="12" x2="5" y2="12" />
                    <polyline points="12 19 5 12 12 5" />
                </svg>
                返回学案
            </asp:LinkButton>
        </div>
    </div>

    <!-- 原始内容（隐藏占位，保持结构一致） -->
    <div class="courseshow"></div>
</asp:Content>
