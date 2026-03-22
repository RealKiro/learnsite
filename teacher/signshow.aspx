<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_signshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">  
    <style>
        /* ===== 签到展示页面美化 ===== */
        .signshow-page {
            max-width: 1600px;
            margin: 0 auto;
            padding: 20px;
            background: #f8fafc;
            min-height: 100vh;
        }

        /* 页面标题区域 */
        .signshow-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px;
            padding: 24px 28px;
            margin-bottom: 24px;
            box-shadow: 0 4px 20px rgba(102, 126, 234, 0.15);
            color: #fff;
        }
        .signshow-header h1 {
            font-size: 24px;
            font-weight: 700;
            margin: 0 0 8px 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .signshow-header .header-icon {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(10px);
        }
        .signshow-header .header-icon svg {
            width: 22px;
            height: 22px;
            stroke: #fff;
            fill: none;
            stroke-width: 2.5;
        }
        .signshow-header .header-subtitle {
            font-size: 14px;
            opacity: 0.9;
            margin-left: 52px;
        }

        /* 统计卡片 */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
        }
        .stat-card.signed {
            border-left: 4px solid #10b981;
        }
        .stat-card.unsigned {
            border-left: 4px solid #f59e0b;
        }
        .stat-card-label {
            font-size: 13px;
            color: #64748b;
            font-weight: 500;
            margin-bottom: 8px;
        }
        .stat-card-value {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
        }
        .stat-card.signed .stat-card-value {
            color: #10b981;
        }
        .stat-card.unsigned .stat-card-value {
            color: #f59e0b;
        }

        /* 表格卡片容器 */
        .table-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            border: 1px solid #e2e8f0;
            margin-bottom: 24px;
            overflow: hidden;
        }
        .table-card-header {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            padding: 18px 24px;
            border-bottom: 2px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .table-card-header.signed {
            border-left: 4px solid #10b981;
        }
        .table-card-header.unsigned {
            border-left: 4px solid #f59e0b;
        }
        .table-card-title {
            font-size: 18px;
            font-weight: 700;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .table-card-title svg {
            width: 20px;
            height: 20px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2.5;
        }
        .table-card-title.signed svg {
            stroke: #10b981;
        }
        .table-card-title.unsigned svg {
            stroke: #f59e0b;
        }
        .table-card-count {
            font-size: 14px;
            color: #64748b;
            font-weight: 500;
            background: #fff;
            padding: 4px 12px;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
        }

        /* 美化 GridView 表格 */
        .table-card .GridViewInfo {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin: 0;
        }
        .table-card .GridViewInfo thead {
            background: #f8fafc;
        }
        .table-card .GridViewInfo th {
            padding: 14px 12px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            color: #475569;
            border-bottom: 2px solid #e2e8f0;
            white-space: nowrap;
        }
        .table-card .GridViewInfo td {
            padding: 12px;
            font-size: 13px;
            color: #334155;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
        }
        .table-card .GridViewInfo tbody tr {
            transition: all 0.2s ease;
        }
        .table-card .GridViewInfo tbody tr:hover {
            background: #f8fafc;
            transform: scale(1.01);
        }
        .table-card .GridViewInfo tbody tr:last-child td {
            border-bottom: none;
        }

        /* 已签到表格特殊样式 */
        .table-card.signed-card .GridViewInfo tbody tr:hover {
            background: #f0fdf4;
        }

        /* 未签到表格特殊样式 */
        .table-card.unsigned-card .GridViewInfo tbody tr:hover {
            background: #fffbeb;
        }

        /* 排序区域 */
        .sort-area {
            background: #fff;
            border-radius: 12px;
            padding: 16px 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            border: 1px solid #e2e8f0;
        }

        /* 美化单选按钮组 */
        .sort-area .radio-group {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .sort-area .radio-group > label {
            font-size: 14px;
            font-weight: 600;
            color: #475569;
            margin-right: 12px;
        }
        .sort-area .radio-list {
            display: flex;
            align-items: center;
            gap: 20px;
            margin: 0;
            padding: 0;
        }
        .sort-area .radio-list label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 14px;
            font-weight: 500;
            color: #64748b;
            cursor: pointer;
            padding: 6px 12px;
            border-radius: 8px;
            transition: all 0.2s ease;
        }
        .sort-area .radio-list label:hover {
            background: #f1f5f9;
            color: #475569;
        }
        .sort-area .radio-list input[type="radio"] {
            width: 18px;
            height: 18px;
            margin: 0;
            cursor: pointer;
            accent-color: #667eea;
        }
        .sort-area .radio-list input[type="radio"]:checked + span {
            color: #667eea;
            font-weight: 600;
        }

        /* 返回按钮区域 */
        .return-area {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 24px;
            padding: 20px 0;
        }

        /* 美化返回按钮 */
        .btn-return {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
            color: #fff !important;
            border: none !important;
            /* 统一尺寸，避免被皮肤样式挤压导致文字被裁剪 */
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            box-sizing: border-box !important;
            padding: 0 32px !important;
            min-width: 140px !important;
            height: 44px !important;
            border-radius: 999px !important;
            font-size: 16px !important;
            font-weight: 600 !important;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
            line-height: 1 !important;
            overflow: visible !important;
        }
        .btn-return:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%) !important;
        }
        .btn-return:active {
            transform: translateY(0);
        }
        .btn-return:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.2);
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .signshow-page {
                padding: 12px;
            }
            .signshow-header {
                padding: 18px;
            }
            .signshow-header h1 {
                font-size: 20px;
            }
            .stats-cards {
                grid-template-columns: 1fr;
            }
            .table-card-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }
            .sort-area {
                padding: 12px 16px;
            }
            .sort-area .radio-group {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }
            .table-card .GridViewInfo {
                font-size: 12px;
            }
            .table-card .GridViewInfo th,
            .table-card .GridViewInfo td {
                padding: 8px 6px;
            }
        }

        /* 空状态提示 */
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #94a3b8;
        }
        .empty-state svg {
            width: 64px;
            height: 64px;
            margin-bottom: 16px;
            opacity: 0.5;
        }
    </style>
    <script type="text/javascript">
        // 同步显示统计数字
        function syncCounts() {
            var signinLabel = document.getElementById('<%= Labelsignin.ClientID %>');
            var nosignLabel = document.getElementById('<%= Labelnosign.ClientID %>');
            var signinDisplay = document.getElementById('SigninCountDisplay');
            var nosignDisplay = document.getElementById('NoSignCountDisplay');
            
            if (signinLabel && signinDisplay) {
                signinDisplay.textContent = signinLabel.textContent + ' 人';
            }
            if (nosignLabel && nosignDisplay) {
                nosignDisplay.textContent = nosignLabel.textContent + ' 人';
            }
        }
        
        // 页面加载完成后同步
        if (window.addEventListener) {
            window.addEventListener('load', syncCounts);
        } else if (window.attachEvent) {
            window.attachEvent('onload', syncCounts);
        }
    </script>

    <div class="signshow-page">
        <!-- 页面标题 -->
        <div class="signshow-header">
            <h1>
                <span class="header-icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M9 11l3 3L22 4M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
                    </svg>
                </span>
                签到记录查看
            </h1>
            <div class="header-subtitle">查看学生的签到情况和详细信息</div>
        </div>

        <!-- 统计卡片 -->
        <div class="stats-cards">
            <div class="stat-card signed">
                <div class="stat-card-label">已签到人数</div>
                <div class="stat-card-value">
                    <asp:Label ID="Labelsignin" runat="server" Font-Size="9pt" Text="0"></asp:Label>
                </div>
            </div>
            <div class="stat-card unsigned">
                <div class="stat-card-label">未签到人数</div>
                <div class="stat-card-value">
                    <asp:Label ID="Labelnosign" runat="server" Font-Size="9pt" Text="0"></asp:Label>
                </div>
            </div>
        </div>

        <!-- 排序方式 -->
        <div class="sort-area">
            <div class="radio-group">
                <label>排序方式：</label>
                <asp:RadioButtonList ID="RBtnList" runat="server" AutoPostBack="True" 
                    onselectedindexchanged="RBtnList_SelectedIndexChanged" 
                    RepeatDirection="Horizontal" RepeatLayout="Flow"
                    CssClass="radio-list">
                    <asp:ListItem Selected="True" Value="0">学号排序</asp:ListItem>
                    <asp:ListItem Value="1">IP地址排序</asp:ListItem>
                </asp:RadioButtonList>
            </div>
        </div>

        <!-- 已签到列表 -->
        <div class="table-card signed-card">
            <div class="table-card-header signed">
                <div class="table-card-title signed">
                    <svg viewBox="0 0 24 24">
                        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    已签到列表
                </div>
                <span class="table-card-count" id="SigninCountDisplay">0 人</span>
            </div>
            <div style="overflow-x: auto;">
                <asp:GridView ID="GVSignin" runat="server" AutoGenerateColumns="False"            
                    CellPadding="2" PageSize="15"
                    Width="100%" ToolTip="已签到的记录"  SkinID="GridViewInfo"
                    onrowdatabound="GVSignin_RowDataBound" EnableModelValidation="True"
                    CssClass="GridViewInfo">
                    <FooterStyle BackColor="White" ForeColor="#333333" />
                    <Columns>
                        <asp:BoundField />
                        <asp:BoundField DataField="Qnum" HeaderText="学号" />
                        <asp:BoundField DataField="Qgrade" HeaderText="年级" />
                        <asp:BoundField DataField="Qclass" HeaderText="班级" />
                        <asp:BoundField DataField="Qname" HeaderText="姓名" >
                        <ItemStyle HorizontalAlign="Left" />
                        </asp:BoundField>
                        <asp:BoundField DataField="Qwork" HeaderText="作品" />
                        <asp:BoundField DataField="Qattitude" HeaderText="表现" />
                        <asp:BoundField DataField="Qnote" HeaderText="备注" />
                        <asp:BoundField DataField="Qgroup" HeaderText="组评" />
                        <asp:BoundField DataField="Qgscore" HeaderText="分值" />
                        <asp:BoundField DataField="Qip" HeaderText="IP地址" />
                        <asp:BoundField DataField="Qdate" HeaderText="日期" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- 未签到列表 -->
        <div class="table-card unsigned-card">
            <div class="table-card-header unsigned">
                <div class="table-card-title unsigned">
                    <svg viewBox="0 0 24 24">
                        <path d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    未签到列表
                </div>
                <span class="table-card-count" id="NoSignCountDisplay">0 人</span>
            </div>
            <div style="overflow-x: auto;">
                <asp:GridView ID="GVNoSign" runat="server" AutoGenerateColumns="False"
                   CellPadding="2"  Width="100%"  ToolTip="未签到列表"  SkinID="GridViewInfo"
                    onrowdatabound="GVNoSign_RowDataBound" DataKeyNames="Snum"
                    CssClass="GridViewInfo">
                    <Columns>
                        <asp:BoundField />
                        <asp:BoundField DataField="Snum" HeaderText="学号" />
                        <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                        <asp:BoundField DataField="Sclass" HeaderText="班级" />
                        <asp:BoundField DataField="Sname" HeaderText="姓名" >
                        <ItemStyle HorizontalAlign="Left" />
                        </asp:BoundField>
                        <asp:BoundField DataField="Sattitude" HeaderText="表现" />
                        <asp:BoundField DataField="Sheadtheacher" HeaderText="班主任" />
                        <asp:BoundField DataField="Sparents" HeaderText="父母" />
                        <asp:BoundField DataField="Saddress" HeaderText="家庭地址" />
                        <asp:BoundField DataField="Sphone" HeaderText="联系电话" />
                        <asp:BoundField HeaderText="缺席原因" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- 返回按钮 -->
        <div class="return-area">
            <asp:Button ID="ButtonReturn" runat="server" onclick="ButtonReturn_Click" 
                Text="返回" SkinID="BtnNormal" CssClass="btn-return" />
        </div>
    </div>
</asp:Content>

