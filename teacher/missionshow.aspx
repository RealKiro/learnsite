<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_missionshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link href="show-common.css" rel="stylesheet" type="text/css" />
<link href="../kindeditor/plugins/code/prettify.css" rel="stylesheet" type="text/css" />
<script src="../kindeditor/plugins/code/prettify.js" type="text/javascript"></script>

<script type="text/javascript">
    window.onload = function() {
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
    <!-- 渐变标题栏 -->
    <div class="show-title-card">
        <div class="show-title-icon">
            <svg viewBox="0 0 24 24">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
        </div>
        <div class="show-title-text">
            <h1 class="show-title"><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
            <p class="show-title-sub">查看学案活动详情，包括提交要求和评价标准</p>
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
            </div>
            <div class="show-info-row">
                <div class="show-info-item">
                    <asp:CheckBox ID="CkMupload" runat="server" Text="是否提交" Enabled="false" />
                </div>
                <div class="show-info-item">
                    <asp:CheckBox ID="CheckMicoWorld" runat="server" Text="上次作品" Enabled="False" />
                </div>
                <div class="show-info-item">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Enabled="False" />
                </div>
                <div class="show-info-item">
                    <asp:CheckBox ID="CheckGroup" runat="server" Text="小组合作" Enabled="false" />
                </div>
                <div class="show-info-item">
                    <asp:HyperLink ID="HLMgid" runat="server">评价标准</asp:HyperLink>
                </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="show-actions">
                <asp:ImageButton ID="BtnEdit" runat="server" 
                    onclick="BtnEdit_Click" 
                    ImageUrl="~/images/edit.gif" 
                    CssClass="show-btn show-btn-primary"
                    AlternateText="修改任务" />
                <asp:ImageButton ID="BtnReturnSmall" runat="server" 
                    onclick="BtnReturnSmall_Click" 
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
            <svg viewBox="0 0 24 24" style="width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;">
                <line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>
            </svg>
            返回学案
        </asp:LinkButton>
    </div>
</div>

<!-- 原始内容（隐藏） -->
<div class="courseshow">
    <br />
    <div class="missiontitle">
        <asp:Label ID="LabelMtitle_old" runat="server"></asp:Label>
    </div><br />
    <div class="courseother">
       日期：<asp:Label ID="LabelMdate_old" runat="server"></asp:Label>
        &nbsp;作品类型：<asp:Image ID="ImageType_old" runat="server" />
        <asp:Label ID="LabelMfiletype_old" runat="server"></asp:Label>
        <asp:CheckBox ID="CkMupload_old" runat="server" Text="是否提交" Enabled="false" /> 
        <asp:CheckBox ID="CheckMicoWorld_old" runat="server" Text="上次作品" Enabled="False" />
        <asp:CheckBox ID="CheckPublish_old" runat="server" Text="是否发布" Enabled="False" />
        <asp:CheckBox ID="CheckGroup_old" runat="server" Text="小组合作" Enabled="false" />
        &nbsp;<asp:HyperLink ID="HLMgid_old" runat="server">评价标准</asp:HyperLink>
    </div>
    <div id="Mcontent_old" class="coursecontent" runat="server"></div>
    <br />
    <asp:LinkButton ID="LinkBtn_old" runat="server" OnClick="LinkBtn_Click" SkinID="LinkBtn">返回学案</asp:LinkButton>
    <br /><br />
</div> 
<br />
</asp:Content>

