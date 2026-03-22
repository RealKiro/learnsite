<%@ page title="作品互评" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" validaterequest="false" autoeventwireup="true" inherits="Student_myevaluate, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<script language="javascript" type="text/javascript">
    document.oncontextmenu = new Function('event.returnValue=false;');
    document.onselectstart = new Function('event.returnValue=false;');
    
    function check() {
        var inputs = document.getElementById("<%=DataListGauge.ClientID%>").getElementsByTagName("input");
        var s = 0;
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].checked) {
                s++;
            }
        }
        if (s > 3) {
            alert("您最多只能选3项！");
            return false;
        }
        else {
            return true;
        }
    }
</script>

<style type="text/css">
    html, body {
        overflow-x: hidden !important;
        padding-left: 0 !important;
        margin-left: 0 !important;
    }
    body:has(.menu) {
        padding-left: 0 !important;
    }
    .studmasterhead,
    .studmasterhead .stu,
    .studmasterhead .placeauto,
    .stu center,
    .stu .path {
        width: 100% !important;
        max-width: none !important;
        margin: 0 !important;
        padding-left: 0 !important;
        padding-right: 0 !important;
        box-sizing: border-box !important;
        text-align: left !important;
    }
    .stu center {
        display: block !important;
    }
    .stu .placeauto {
        width: auto !important;
        max-width: none !important;
        margin: 0 12px 0 194px !important;
        padding: 0 !important;
        box-sizing: border-box !important;
    }
    .evaluate-container {
        display: block !important;
        width: 100% !important;
        max-width: none !important;
        margin: 0 !important;
        padding: 20px 12px 20px 8px !important;
        box-sizing: border-box !important;
    }
    .icon-hidden { display: none !important; }
    .css-icon {
        width: 18px;
        height: 18px;
        display: inline-block;
        vertical-align: middle;
        background-repeat: no-repeat;
        background-size: contain;
        background-position: center;
    }
    .css-icon-vote { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23ffffff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9A2 2 0 0 0 19.66 9z'/%3E%3Cpath d='M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3'/%3E%3C/svg%3E"); }
    .css-icon-file { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%234f46e5' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/%3E%3Cpolyline points='14 2 14 8 20 8'/%3E%3Cline x1='16' y1='13' x2='8' y2='13'/%3E%3Cline x1='16' y1='17' x2='8' y2='17'/%3E%3C/svg%3E"); }
    .css-icon-smile { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2310b981' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cpath d='M8 15s1.5 2 4 2 4-2 4-2'/%3E%3Cline x1='9' y1='9' x2='9.01' y2='9'/%3E%3Cline x1='15' y1='9' x2='15.01' y2='9'/%3E%3C/svg%3E"); }
    .css-icon-good { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2310b981' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9A2 2 0 0 0 19.66 9z'/%3E%3Cpath d='M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3'/%3E%3C/svg%3E"); }
    
    .evaluate-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 12px;
        padding: 20px 30px;
        margin-bottom: 20px;
        color: #fff;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    }
    
    .evaluate-header h2 {
        margin: 0 0 15px 0;
        font-size: 22px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .evaluate-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        font-size: 14px;
        margin-top: 10px;
    }
    
    .evaluate-meta-item {
        display: flex;
        align-items: center;
        gap: 5px;
        background: rgba(255, 255, 255, 0.2);
        padding: 5px 12px;
        border-radius: 20px;
    }
    
    .works-list {
        background: #fff;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
    }
    
    .works-list-title {
        font-size: 16px;
        font-weight: bold;
        margin-bottom: 15px;
        color: #333;
        padding-bottom: 10px;
        border-bottom: 2px solid #f0f0f0;
    }
    
    .evaluate-criteria {
        background: #E8F3FF;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
    }
    
    .evaluate-criteria-title {
        font-size: 16px;
        font-weight: bold;
        margin-bottom: 15px;
        color: #333;
    }
    
    .evaluate-actions {
        background: #fff;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
    }
    
    .evaluate-message {
        margin-bottom: 15px;
        padding: 10px;
        border-radius: 6px;
    }
    
    .evaluate-actions-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 15px;
        flex-wrap: wrap;
    }
    
    .preview-area {
        min-height: 400px;
        background: #f9f9f9;
        border-radius: 12px;
        padding: 20px;
        margin-top: 20px;
        border: 1px solid #e0e0e0;
    }
    @media (max-width: 1200px) {
        .stu .placeauto {
            width: 100% !important;
            margin: 0 !important;
        }
        .evaluate-container {
            width: 100% !important;
            padding: 16px 8px 20px 4px !important;
        }
    }
</style>

<div class="evaluate-container">
    <!-- 页面标题和统计信息 -->
    <div class="evaluate-header">
        <h2>
            <span class="css-icon css-icon-vote"></span>
            <asp:Image ID="Image2" runat="server" ImageUrl="~/images/wvote.png" CssClass="icon-hidden" />
            <asp:Label ID="Labelscope" runat="server" Font-Bold="True"></asp:Label>
            <strong>作品互评：</strong>
            <asp:Label ID="Labelmtitle" runat="server" Font-Bold="True"></asp:Label>
        </h2>
        <asp:Label ID="Labelwmid" runat="server" Visible="false"></asp:Label>
        <asp:Label ID="LabelMgid" runat="server" Visible="false"></asp:Label>
        <asp:Label ID="Labelwdate" runat="server" Visible="false"></asp:Label>
        
        <div class="evaluate-meta">
            <span class="css-icon css-icon-file"></span>
            <asp:Image ID="ImageWtype" runat="server" CssClass="icon-hidden" />
            <asp:Label ID="LabelWtype" runat="server"></asp:Label>
            <div class="evaluate-meta-item">
                <span>作品总数：</span>
                <strong><asp:Label ID="Labelhow" runat="server"></asp:Label></strong>
            </div>
            <div class="evaluate-meta-item">
                <span>可投次数：</span>
                <strong><asp:Label ID="Labelegg" runat="server"></asp:Label></strong>
            </div>
            <div class="evaluate-meta-item">
                <span>我的得票：</span>
                <strong><asp:Label ID="Labelme" runat="server"></asp:Label></strong>
            </div>
            <div class="evaluate-meta-item">
                <span>互评得分：</span>
                <strong><asp:Label ID="Labelwfscore" runat="server"></asp:Label></strong>
            </div>
        </div>
    </div>
    
    <!-- 作品列表 -->
    <div class="works-list">
        <div class="works-list-title">作品列表（点击预览）</div>
        <asp:DataList ID="DataListvote" runat="server" RepeatDirection="Horizontal" 
            RepeatColumns="15" DataKeyField="wid" OnItemCommand="DataListvote_ItemCommand" 
            CellPadding="5" Font-Size="11pt" 
            onitemdatabound="DataListvote_ItemDataBound">
            <ItemTemplate>
                <div style="width: 60px; text-align: center;">
                    <div>
                        <asp:LinkButton ID="lBtnSname" runat="server" CommandArgument='<%# Eval("Wurl") %>' CommandName="S" 
                            ToolTip="点击预览我的作品！" Text='<%# Eval("Wname") %>' ForeColor="#0000CC" 
                            style="text-decoration: none; display: inline-block; padding: 5px; border-radius: 4px; transition: background 0.3s;">
                        </asp:LinkButton>
                    </div>
                    <asp:Label ID="LabelWflash" runat="server" Text='<%# Eval("Wflash") %>' Visible="False"></asp:Label>
                    <asp:Label ID="LabelWid" runat="server" Text='<%# Eval("wid") %>' Visible="False"></asp:Label>
                    <asp:Label ID="LabelWnum" runat="server" Text='<%# Eval("Wnum") %>' Visible="False"></asp:Label>
                </div>
            </ItemTemplate>
        </asp:DataList>
    </div>
    
    <!-- 评价标准 -->
    <div class="evaluate-criteria">
        <div class="evaluate-criteria-title">评价标准（最多选择3项）</div>
        <asp:DataList ID="DataListGauge" runat="server" Font-Size="11pt" 
            CellPadding="10" RepeatColumns="2" 
            onitemdatabound="DataListGauge_ItemDataBound" HorizontalAlign="Center" 
            RepeatDirection="Horizontal" CellSpacing="4" Width="100%">
            <ItemTemplate>
                <div style="padding: 8px;">
                    <asp:CheckBox ID="RbMitem" runat="server" Text='<%# Eval("Mitem") %>' />
                    <asp:Label ID="LabelCount" runat="server"></asp:Label>
                    <span class="css-icon css-icon-smile"></span>
                    <asp:Image ID="Image3" runat="server" ImageUrl="~/images/smile16.gif" CssClass="icon-hidden" />
                    <asp:Label ID="LbMid" runat="server" Text='<%# Eval("mid") %>' Visible="False"></asp:Label>
                    <asp:Label ID="LbMscore" runat="server" Text='<%# Eval("Mscore") %>' Visible="False"></asp:Label>
                </div>
            </ItemTemplate>
        </asp:DataList>
    </div>
    
    <!-- 操作按钮 -->
    <div class="evaluate-actions">
        <div class="evaluate-message">
            <asp:Label ID="Labelmsg" runat="server" Font-Bold="False"></asp:Label>
        </div>
        <div class="evaluate-actions-row">
            <span class="css-icon css-icon-good"></span>
            <asp:Image ID="ImageDown0" runat="server" ImageUrl="~/images/good16.png" CssClass="icon-hidden" />
            <asp:CheckBox ID="CheckBoxGood" runat="server" Text="推荐" />
            <asp:Button ID="BtnVote" runat="server" onclick="BtnVote_Click" 
                SkinID="buttonSkinPink" Text="请投我一票" Width="100px" 
                OnClientClick="return check();" />
        </div>
    </div>
    
    <!-- 作品预览区域 -->
    <div class="preview-area">
        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
        <asp:Label ID="Labelwname" runat="server" Visible="False"></asp:Label>
        <asp:Label ID="lbMyFeedback" runat="server" Visible="False"></asp:Label>
    </div>
</div>
</asp:Content>

