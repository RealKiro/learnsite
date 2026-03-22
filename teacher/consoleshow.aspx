<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_consoleshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link href="show-common.css" rel="stylesheet" type="text/css" />

<style>
    /* ===== 测评页面特殊样式 ===== */
    .console-grid-card {
        background: #fff !important;
        border-radius: 14px !important;
        border: 1px solid #e8ecf1 !important;
        box-shadow: 0 1px 4px rgba(0,0,0,.04) !important;
        margin-bottom: 20px !important;
        overflow: hidden !important;
    }
    
    .console-grid-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,.06) !important;
    }
    
    /* GridView 样式优化 */
    .console-grid-card .GridViewInfo {
        width: 100% !important;
        border: none !important;
        border-collapse: separate !important;
        border-spacing: 0 !important;
    }
    
    .console-grid-card .GridViewInfo th {
        background: linear-gradient(180deg, #fafbfc 0%, #f7f8fa 100%) !important;
        color: #334155 !important;
        font-weight: 600 !important;
        font-size: 13px !important;
        padding: 14px 16px !important;
        text-align: left !important;
        border-bottom: 2px solid #e5e7eb !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    
    .console-grid-card .GridViewInfo td {
        padding: 14px 16px !important;
        border-bottom: 1px solid #f1f5f9 !important;
        color: #475569 !important;
        font-size: 14px !important;
        vertical-align: middle !important;
    }
    
    .console-grid-card .GridViewInfo tr:hover td {
        background: #f8fafc !important;
    }
    
    .console-grid-card .GridViewInfo tr:last-child td {
        border-bottom: none !important;
    }
    
    .console-grid-card .GridViewInfo a {
        color: #10b981 !important;
        text-decoration: none !important;
        font-weight: 600 !important;
        padding: 6px 12px !important;
        border-radius: 6px !important;
        transition: all 0.2s ease !important;
        display: inline-block !important;
    }
    
    .console-grid-card .GridViewInfo a:hover {
        background: #d1fae5 !important;
        color: #059669 !important;
    }
    
    /* 预览链接样式 */
    .console-preview {
        display: inline-flex !important;
        align-items: center !important;
        gap: 8px !important;
        padding: 12px 24px !important;
        background: linear-gradient(135deg, #6366f1, #8b5cf6) !important;
        color: #fff !important;
        border-radius: 10px !important;
        text-decoration: none !important;
        font-weight: 600 !important;
        font-size: 14px !important;
        transition: all 0.3s ease !important;
        box-shadow: 0 4px 12px rgba(99,102,241,0.3) !important;
    }
    
    .console-preview:hover {
        background: linear-gradient(135deg, #4f46e5, #7c3aed) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 20px rgba(99,102,241,0.4) !important;
        color: #fff !important;
    }
    
    .console-preview svg {
        width: 18px !important;
        height: 18px !important;
        stroke: currentColor !important;
        fill: none !important;
        stroke-width: 2 !important;
    }
    
    /* 按钮组样式 */
    .console-button-group {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 12px !important;
        margin: 24px 0 !important;
    }
    
    .console-button-group .show-btn {
        min-width: 120px !important;
    }
</style>

<script type="text/javascript">
    window.onload = function() {
        var btnEdit = document.getElementById('<%= BtnEdit.ClientID %>');
        if (btnEdit) {
            btnEdit.value = '修改测评';
            btnEdit.style.width = 'auto';
            btnEdit.style.height = 'auto';
        }
        
        var btnClock = document.getElementById('<%= Btnclock.ClientID %>');
        if (btnClock) {
            btnClock.value = '计时管理';
            btnClock.style.width = 'auto';
            btnClock.style.height = 'auto';
        }
    };
</script>

<div class="show-container">
    <!-- 渐变标题栏 -->
    <div class="show-title-card">
        <div class="show-title-icon">
            <svg viewBox="0 0 24 24">
                <path d="M9 11l3 3L22 4"/>
                <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
            </svg>
        </div>
        <div class="show-title-text">
            <h1 class="show-title"><asp:Label runat="server" ID="Lbtitle"></asp:Label></h1>
            <p class="show-title-sub">查看测评详情，管理试题和计时设置</p>
        </div>
    </div>
    
    <!-- 信息卡片 -->
    <div class="show-info-card">
        <div class="show-card-head">
            <span class="show-dot"></span>
            <h3>
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                测评信息
            </h3>
        </div>
        <div class="show-card-body">
            <div class="show-info-row">
                <div class="show-info-item">
                    <label>日期：</label>
                    <asp:Label runat="server" ID="Lbdate"></asp:Label>
                </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="show-actions">
                <asp:ImageButton ID="BtnEdit" runat="server" 
                    onclick="BtnEdit_Click" 
                    ImageUrl="~/images/edit.gif" 
                    CssClass="show-btn show-btn-primary"
                    AlternateText="修改测评" />
                <asp:ImageButton ID="Btnclock" runat="server" 
                    onclick="Btnclock_Click" 
                    ImageUrl="~/images/clock.gif"
                    CssClass="show-btn"
                    AlternateText="计时管理"
                    ToolTip="测评启用或停止" />
            </div>
        </div>
    </div>
    
    <!-- 内容卡片 -->
    <div class="show-content-card">
        <div id="vcontent" runat="server" class="show-content"></div>
    </div>
    
    <!-- 按钮组 -->
    <div class="console-button-group">
        <asp:Button ID="Btnadd" runat="server" 
            onclick="Btnadd_Click" 
            SkinID="BtnNormal" 
            Text="添加试题"
            CssClass="show-btn show-btn-primary" />
        <asp:Button ID="Btnreturn" runat="server" 
            onclick="Btnreturn_Click" 
            SkinID="BtnNormal" 
            Text="返回"
            CssClass="show-btn" />
    </div>
    
    <!-- 试题列表卡片 -->
    <div class="console-grid-card">
        <asp:GridView ID="GVProblem" runat="server" 
            SkinID="GridViewInfo"
            AutoGenerateColumns="False" 
            Width="100%" 
            CellPadding="5" 
            Font-Size="11pt" 
            EnableModelValidation="True" 
            HorizontalAlign="Center" 
            onrowcommand="GVProblem_RowCommand" 
            onrowdatabound="GVProblem_RowDataBound" 
            DataKeyNames="Pid"
            CssClass="GridViewInfo">
            <Columns>
                <asp:BoundField HeaderText="序号">
                    <HeaderStyle Width="60px" />
                </asp:BoundField>
                <asp:TemplateField HeaderText="试题">
                    <ItemTemplate>
                        <asp:Label ID="LabelPtitle" runat="server" 
                            Text='<%# HttpUtility.HtmlDecode(DataBinder.Eval(Container.DataItem,"Ptitle").ToString()) %>'>
                        </asp:Label>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Left" />
                </asp:TemplateField>
                <asp:TemplateField ShowHeader="False" HeaderText="排序">
                    <ItemTemplate>
                        <asp:LinkButton ID="ImageBtnTop" runat="server" 
                            CausesValidation="False" 
                            CommandName="Top" 
                            CommandArgument='<%# ((GridViewRow) Container).RowIndex %>'
                            Text="↑" 
                            ToolTip="向上移" 
                            Font-Underline="False">
                        </asp:LinkButton>
                        <asp:LinkButton ID="ImageBtnBottom" runat="server" 
                            CausesValidation="False" 
                            CommandName="Bottom" 
                            CommandArgument='<%# ((GridViewRow) Container).RowIndex %>'
                            Text="↓" 
                            ToolTip="向下移" 
                            Font-Underline="False">
                        </asp:LinkButton>
                    </ItemTemplate>
                    <ItemStyle Width="60px" HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:BoundField DataField="Pscore" HeaderText="分值">
                    <HeaderStyle Width="60px" />
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:TemplateField HeaderText="操作">
                    <ItemTemplate>
                        <asp:HyperLink ID="HyperLinkPid" runat="server" Text="编辑"></asp:HyperLink>
                    </ItemTemplate>
                    <HeaderStyle Width="60px" />
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:LinkButton ID="BtnDel" runat="server" 
                            CausesValidation="false" 
                            CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' 
                            CommandName="Del" 
                            Text="删除">
                        </asp:LinkButton>
                    </ItemTemplate>
                    <HeaderStyle Width="60px" />
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
    
    <!-- 预览按钮 -->
    <div class="show-footer">
        <asp:HyperLink ID="Hkconsole" runat="server" 
            NavigateUrl="#" 
            Target="_blank"
            CssClass="console-preview">
            <svg viewBox="0 0 24 24">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                <circle cx="12" cy="12" r="3"/>
            </svg>
            预览效果
        </asp:HyperLink>
    </div>
</div>

<!-- 原始内容（隐藏） -->
<div style="display: none;">
    <div>
        <br />
        测评名称：<asp:Label runat="server" ID="Lbtitle_old" Font-Bold="True"></asp:Label>
        <br /><br />
        <div style="border-width: 1px; border-color: #808080; border-bottom-style: dashed; padding-bottom: 2px;">
            日期：<asp:Label runat="server" ID="Lbdate_old"></asp:Label>
        </div>
        <br />
        <div id="vcontent_old" runat="server" style="margin: auto; padding: 6px; text-align: left; width: 800px;"></div>
        <br />
    </div>
</div>

</asp:Content>

