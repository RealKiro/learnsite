<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="teacher_kitymindshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<script runat="server">
    // 生成学生端预览 URL（与 wareshow.aspx.cs 中 StudentUrl 逻辑一致）
    private string _kmStudentUrl = null;
    protected string KmStudentUrl
    {
        get
        {
            if (_kmStudentUrl != null) return _kmStudentUrl;
            string _lid  = Request.QueryString["lid"]  ?? "";
            string _mid  = Request.QueryString["mid"]  ?? "";
            string _mcid = Request.QueryString["mcid"] ?? Request.QueryString["cid"] ?? "";
            int lidVal = 0; int midVal = 0; int mcidVal = 0;
            int.TryParse(_lid,  out lidVal);
            int.TryParse(_mid,  out midVal);
            int.TryParse(_mcid, out mcidVal);
            if (lidVal > 0 && midVal > 0 && mcidVal > 0)
                _kmStudentUrl = string.Format("../student/program.aspx?lid={0}&mid={1}&mcid={2}", lidVal, midVal, mcidVal);
            else
                _kmStudentUrl = "";
            return _kmStudentUrl;
        }
    }
</script>

<link href="show-common.css" rel="stylesheet" type="text/css" />

<style>
/* 思维导图学生端预览按钮 */
.km-student-btn {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    padding: 7px 16px !important;
    background: linear-gradient(135deg, #ecfdf5, #d1fae5) !important;
    color: #059669 !important;
    border: 1px solid #6ee7b7 !important;
    border-radius: 8px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    text-decoration: none !important;
    transition: all .18s !important;
    font-family: 'Microsoft YaHei', sans-serif !important;
}
.km-student-btn:hover {
    background: linear-gradient(135deg, #d1fae5, #a7f3d0) !important;
    color: #047857 !important;
    border-color: #34d399 !important;
    transform: translateY(-1px) !important;
    box-shadow: 0 4px 10px rgba(5,150,105,.15) !important;
    text-decoration: none !important;
}
.km-student-btn svg {
    width: 14px; height: 14px;
    stroke: currentColor; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}
</style>

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
                <circle cx="12" cy="12" r="3"/>
                <path d="M12 1v6m0 6v6m-6-6h6m6 0h6"/>
            </svg>
        </div>
        <div class="show-title-text">
            <h1 class="show-title"><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
            <p class="show-title-sub">查看思维导图任务详情，培养思维能力</p>
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
                <div class="show-info-item">
                    <asp:CheckBox ID="CheckPublish" runat="server" Text="是否发布" Enabled="False" />
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
                    onclick="BtnEdit_Click" 
                    ImageUrl="~/images/edit.gif" 
                    CssClass="show-btn show-btn-primary"
                    AlternateText="修改任务" />
                <asp:ImageButton ID="BtnReturnSmall" runat="server" 
                    onclick="BtnReturnSmall_Click" 
                    ImageUrl="~/images/return.gif"
                    CssClass="show-btn"
                    AlternateText="返回列表" />
                <% if (!string.IsNullOrEmpty(KmStudentUrl)) { %>
                <a href="<%= KmStudentUrl %>" target="_blank" class="km-student-btn">
                    <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    学生端预览
                </a>
                <% } %>
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
        &nbsp;<asp:CheckBox ID="CheckPublish_old" runat="server" Text="是否发布" Enabled="False" />
        &nbsp;实例:<asp:HyperLink ID="Hlexample_old" runat="server"></asp:HyperLink>
        &nbsp;<asp:HyperLink ID="HLMgid_old" runat="server">评价标准</asp:HyperLink>
    </div>
    <div id="Mcontent_old" class="coursecontent" runat="server"></div>
    <br />
    <asp:LinkButton ID="LinkBtn_old" runat="server" OnClick="LinkBtn_Click" SkinID="LinkBtn">返回学案</asp:LinkButton>
    <br /><br />
</div> 
<br />
</asp:Content>

