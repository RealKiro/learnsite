<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_pythonshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== Python任务详情页面样式（教师端） ===== */
    * { box-sizing: border-box; }

    .py-container {
        max-width: 1500px;
        margin: 0 auto;
        padding: 20px;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
    }

    /* 任务标题区 */
    .py-header {
        background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 50%, #6d28d9 100%);
        color: #fff;
        padding: 32px;
        border-radius: 16px;
        margin-bottom: 24px;
        box-shadow: 0 4px 20px rgba(139, 92, 246, 0.25);
        position: relative;
        overflow: hidden;
    }
    .py-header::before {
        content: '';
        position: absolute;
        top: -40px;
        right: -40px;
        width: 140px;
        height: 140px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .py-header-icon {
        font-size: 42px;
        margin-bottom: 10px;
        position: relative;
        z-index: 1;
    }
    .py-header h1 {
        margin: 0;
        font-size: 26px;
        font-weight: 700;
        position: relative;
        z-index: 1;
    }
    .py-header .desc {
        margin-top: 8px;
        font-size: 14px;
        color: rgba(255,255,255,.85);
        position: relative;
        z-index: 1;
    }

    /* 任务信息卡片 */
    .py-info-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        padding: 24px;
        margin-bottom: 24px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }

    .py-info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 20px;
    }

    .py-info-item {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .py-info-icon {
        width: 44px;
        height: 44px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
    }

    .py-info-icon img {
        width: 20px;
        height: 20px;
    }

    .py-info-icon.date { background: #eff6ff; border-color: #bfdbfe; }
    .py-info-icon.type { background: #f5f3ff; border-color: #ddd6fe; }
    .py-info-icon.example { background: #f0fdf4; border-color: #bbf7d0; }
    .py-info-icon.standard { background: #fef3c7; border-color: #fde68a; }

    .py-info-content { flex: 1; }

    .py-info-label {
        font-size: 12px;
        color: #6b7280;
        font-weight: 600;
        margin-bottom: 4px;
    }

    .py-info-value {
        font-size: 14px;
        color: #1f2937;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }

    .py-info-value a {
        color: #8b5cf6;
        text-decoration: none;
        transition: all 0.2s;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }

    .py-info-value a:hover {
        color: #7c3aed;
        text-decoration: underline;
    }

    /* 功能选项 */
    .py-options {
        display: flex;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
        padding-top: 16px;
        border-top: 1px solid #e5e7eb;
    }

    .py-option-item {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        font-size: 13px;
        color: #475569;
        font-weight: 500;
    }

    .py-option-item input[type="checkbox"] {
        width: 16px;
        height: 16px;
        cursor: not-allowed;
    }

    /* 操作按钮区 */
    .py-actions {
        display: flex;
        align-items: center;
        gap: 12px;
        padding-top: 16px;
        border-top: 1px solid #e5e7eb;
        margin-top: 16px;
    }

    .py-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 20px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.2s;
        border: none;
        cursor: pointer;
    }

    .py-btn-primary {
        background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
        color: #fff;
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
    }

    .py-btn-primary:hover {
        box-shadow: 0 4px 14px rgba(139, 92, 246, 0.4);
        transform: translateY(-1px);
    }

    .py-btn-secondary {
        background: #fff;
        color: #475569;
        border: 1.5px solid #e2e8f0;
    }

    .py-btn-secondary:hover {
        border-color: #cbd5e1;
        background: #f8fafc;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    }

    .py-btn img {
        width: 16px;
        height: 16px;
    }

    /* 任务内容区 */
    .py-content-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        padding: 32px;
        min-height: 400px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }

    .py-content {
        font-size: 16px;
        color: #334155;
        line-height: 1.9;
    }

    .py-content h1,
    .py-content h2,
    .py-content h3 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 32px;
        margin-bottom: 16px;
        padding-left: 20px;
        border-left: 5px solid #8b5cf6;
    }

    .py-content h1 { font-size: 32px; }
    .py-content h2 { font-size: 26px; }
    .py-content h3 { font-size: 22px; }

    .py-content p { margin-bottom: 16px; }

    .py-content img {
        max-width: 100%;
        height: auto;
        border-radius: 12px;
        margin: 24px 0;
    }

    /* 底部返回按钮 */
    .py-footer {
        margin-top: 24px;
        text-align: center;
    }

    .py-footer .py-btn {
        min-width: 160px;
        justify-content: center;
    }

    /* 隐藏旧样式 */
    .courseshow { 
        padding: 0 !important;
        background: transparent !important;
    }
    .courseshow > br { display: none; }
    .missiontitle { display: none; }
    .courseother { display: none; }
    .coursecontent { display: none; }
</style>

<div class="py-container">
    <!-- 任务标题 -->
    <div class="py-header">
        <div class="py-header-icon">🐍</div>
        <h1><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
        <div class="desc">Python编程任务详情与管理</div>
    </div>

    <!-- 任务信息卡片 -->
    <div class="py-info-card">
        <div class="py-info-grid">
            <!-- 日期 -->
            <div class="py-info-item">
                <div class="py-info-icon date">
                    <svg style="width: 20px; height: 20px; stroke: #3b82f6; fill: none; stroke-width: 2;" viewBox="0 0 24 24">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8" y1="2" x2="8" y2="6"/>
                        <line x1="3" y1="10" x2="21" y2="10"/>
                    </svg>
                </div>
                <div class="py-info-content">
                    <div class="py-info-label">发布日期</div>
                    <div class="py-info-value">
                        <asp:Label ID="LabelMdate" runat="server"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- 作品类型 -->
            <div class="py-info-item">
                <div class="py-info-icon type">
                    <asp:Image ID="ImageType" runat="server" />
                </div>
                <div class="py-info-content">
                    <div class="py-info-label">作品类型</div>
                    <div class="py-info-value">
                        <asp:Label ID="LabelMfiletype" runat="server"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- 编程实例 -->
            <div class="py-info-item">
                <div class="py-info-icon example">
                    <img src="../images/python.png" alt="Python" />
                </div>
                <div class="py-info-content">
                    <div class="py-info-label">参考资源</div>
                    <div class="py-info-value">
                        <asp:HyperLink ID="HlExample" runat="server" Target="_blank">编程实例</asp:HyperLink>
                    </div>
                </div>
            </div>

            <!-- 评价标准 -->
            <div class="py-info-item">
                <div class="py-info-icon standard">
                    <svg style="width: 20px; height: 20px; stroke: #f59e0b; fill: none; stroke-width: 2;" viewBox="0 0 24 24">
                        <path d="M9 11l3 3L22 4"/>
                        <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                    </svg>
                </div>
                <div class="py-info-content">
                    <div class="py-info-label">评价标准</div>
                    <div class="py-info-value">
                        <asp:HyperLink ID="HLMgid" runat="server">查看标准</asp:HyperLink>
                        <asp:Image ID="Imgauto" runat="server" style="width: 18px; height: 18px;" />
                        <asp:HyperLink ID="HLauto" runat="server">自动批改</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <!-- 功能选项 -->
        <div class="py-options">
            <div class="py-option-item">
                <asp:CheckBox ID="CheckPublish" runat="server" Text="发布" Enabled="False" />
            </div>
            <div class="py-option-item">
                <asp:CheckBox ID="CheckBack" runat="server" Text="分步" Enabled="False" />
            </div>
            <div class="py-option-item">
                <asp:CheckBox ID="Checkhelp" runat="server" Text="绘图" Enabled="False" />
            </div>
            <div class="py-option-item">
                <asp:CheckBox ID="Checkblock" runat="server" Text="拼图" Enabled="False" />
            </div>
            <div class="py-option-item">
                <asp:CheckBox ID="Checkblockpy" runat="server" Text="积木" Enabled="False" />
            </div>
        </div>

        <!-- 操作按钮 -->
        <div class="py-actions">
            <asp:ImageButton ID="BtnEdit" runat="server" ToolTip="编辑任务" 
                ImageUrl="~/images/edit.gif" onclick="BtnEdit_Click" 
                CssClass="py-btn py-btn-primary" />
            <asp:ImageButton ID="BtnReturnSmall" runat="server" ToolTip="返回列表" 
                ImageUrl="~/images/return.gif" onclick="BtnReturnSmall_Click" 
                CssClass="py-btn py-btn-secondary" />
        </div>
    </div>

    <!-- 任务内容 -->
    <div class="py-content-card">
        <div id="Mcontent" class="py-content" runat="server"></div>
    </div>

    <!-- 底部返回按钮 -->
    <div class="py-footer">
        <asp:LinkButton ID="LinkBtn" runat="server" OnClick="LinkBtn_Click" CssClass="py-btn py-btn-secondary">
            <svg style="width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2;" viewBox="0 0 24 24">
                <line x1="19" y1="12" x2="5" y2="12"/>
                <polyline points="12 19 5 12 12 5"/>
            </svg>
            返回学案
        </asp:LinkButton>
    </div>
</div>

<!-- 保留原有结构（隐藏） -->
<div class="courseshow" style="display: none;">
    <div class="missiontitle">
        <asp:Label ID="LabelMtitle2" runat="server"></asp:Label>
    </div>
    <div class="courseother"></div>
    <div class="coursecontent"></div>
</div>
</asp:Content>

