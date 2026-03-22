<%@ page language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_workshow, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<!-- Hidden legacy control for code-behind compatibility (same ID as master page's Imagelogo) -->
<asp:Image ID="Imagelogo" runat="server" ImageUrl="~/images/learnsite.gif" style="display:none" />

<style>
    .ws { width: 98%; margin: 0 auto; padding: 8px 0; }
    .ws-card {
        background: #fff; border-radius: 16px; border: 1px solid #e2e8f0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.04), 0 8px 16px rgba(0,0,0,0.03);
        overflow: hidden; margin-bottom: 20px;
    }
    .ws-head {
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        padding: 18px 24px; border-bottom: 1px solid #f1f5f9;
        background: linear-gradient(135deg, #fafbfc, #ffffff);
    }
    .ws-head .ws-icon {
        width: 36px; height: 36px; border-radius: 10px;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        box-shadow: 0 2px 4px rgba(99,102,241,0.2);
    }
    .ws-head .ws-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
    .ws-head .ws-title { font-size: 16px; font-weight: 700; color: #1e293b; letter-spacing: -0.3px; }
    .ws-head #Labelshow { font-size: 14px; color: #64748b; font-weight: 500; }
    .ws-head select {
        height: 36px; border-radius: 10px; border: 1.5px solid #e2e8f0;
        font-size: 13px; padding: 0 12px; background: #fff;
        color: #334155; font-weight: 500; cursor: pointer;
        transition: all 0.2s ease; min-width: 120px;
    }
    .ws-head select:hover { border-color: #818cf8; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
    .ws-head select:focus { outline: none; border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.15); }
    .ws-body { 
        padding: 28px 24px; text-align: center; 
        background: linear-gradient(135deg, #fafbfc 0%, #ffffff 100%);
    }
    .ws-body table { border-collapse: separate; border-spacing: 10px; margin: 0 auto; }
    .ws-body table td { padding: 0; vertical-align: top; }
    .ws-body table caption {
        caption-side: top; text-align: left; padding: 16px 0 12px 0;
        font-size: 15px; font-weight: 700; color: #1e293b;
        border-bottom: 3px solid #f1f5f9; margin-bottom: 16px;
        position: relative;
    }
    .ws-body table caption::after {
        content: ''; position: absolute; bottom: -3px; left: 0; width: 60px;
        height: 3px; background: linear-gradient(90deg, #6366f1, #8b5cf6);
        border-radius: 2px;
    }

    /* 工具栏 */
    .ws-toolbar {
        display: flex; align-items: center; flex-wrap: wrap; gap: 10px;
        padding: 14px 24px; border-bottom: 1px solid #f1f5f9;
        background: linear-gradient(135deg, #f8fafc, #f1f5f9); font-size: 13px;
    }
    .ws-toolbar .ws-legend-dot {
        display: inline-block; width: 14px; height: 14px; border-radius: 4px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.15); vertical-align: middle;
        border: 1px solid rgba(255,255,255,0.5);
    }
    .ws-toolbar input[type="submit"] {
        height: 32px; border-radius: 8px; border: 1.5px solid #e2e8f0;
        background: #fff; color: #475569; font-size: 12px; font-weight: 600;
        padding: 0 14px; cursor: pointer; transition: all 0.2s ease;
        box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }
    .ws-toolbar input[type="submit"]:hover { 
        border-color: #6366f1; background: linear-gradient(135deg, #eef2ff, #e0e7ff); 
        color: #4338ca; box-shadow: 0 2px 4px rgba(99,102,241,0.15);
        transform: translateY(-1px);
    }
    .ws-toolbar input[type="submit"]:active { transform: translateY(0); }
    .ws-toolbar a { 
        color: #6366f1; text-decoration: none; font-weight: 600;
        padding: 6px 12px; border-radius: 8px; transition: all 0.2s;
        background: rgba(99,102,241,0.05);
    }
    .ws-toolbar a:hover { 
        background: rgba(99,102,241,0.1); text-decoration: none;
        box-shadow: 0 2px 4px rgba(99,102,241,0.1);
    }
    .ws-toolbar label {
        display: inline-flex; align-items: center; gap: 6px; cursor: pointer; white-space: nowrap;
        background: #fff; border: 1.5px solid #e2e8f0; border-radius: 20px;
        padding: 6px 14px 6px 10px; transition: all 0.2s ease;
        font-weight: 500; color: #475569;
    }
    .ws-toolbar label:hover { border-color: #818cf8; background: #eef2ff; }
    .ws-toolbar input[type="radio"] { 
        accent-color: #6366f1; width: 16px; height: 16px; margin: 0;
        cursor: pointer;
    }
    .ws-toolbar input[type="radio"]:checked + span { color: #6366f1; font-weight: 600; }
    .ws-toolbar #BtnCheck {
        border-radius: 8px; padding: 6px; transition: all 0.2s;
        background: rgba(99,102,241,0.05);
    }
    .ws-toolbar #BtnCheck:hover {
        background: rgba(99,102,241,0.15); transform: scale(1.1);
    }

    /* 作品卡片 */
    .ws-body .divscore {
        border: 1.5px solid #e2e8f0 !important; border-radius: 16px !important;
        padding: 14px 10px !important; margin: 8px !important; text-align: center;
        background: linear-gradient(135deg, #ffffff, #f8fafc) !important;
        width: 125px !important; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
        vertical-align: top; position: relative; overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04),
                    inset 0 1px 0 rgba(255,255,255,0.8);
    }
    .ws-body .divscore::before {
        content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
        background: linear-gradient(90deg, #6366f1, #8b5cf6, #a855f7);
        opacity: 0; transition: opacity 0.3s ease;
    }
    .ws-body .divscore:hover { 
        border-color: #818cf8 !important; 
        box-shadow: 0 8px 24px rgba(99,102,241,0.2), 0 4px 12px rgba(99,102,241,0.15) !important;
        transform: translateY(-4px) scale(1.02);
        background: linear-gradient(135deg, #ffffff, #f0f4ff) !important;
    }
    .ws-body .divscore:hover::before {
        opacity: 1;
    }
    .ws-body .workname {
        display: inline-block !important; background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
        border: 1.5px solid #c7d2fe; border-radius: 10px !important;
        color: #3730a3 !important; font-size: 12px !important; font-weight: 700 !important;
        padding: 6px 10px !important; height: auto !important; width: auto !important;
        min-width: 65px; line-height: 18px !important; text-decoration: none !important;
        box-shadow: 0 2px 4px rgba(99,102,241,0.15), inset 0 1px 0 rgba(255,255,255,0.5);
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative; overflow: hidden;
    }
    .ws-body .workname::after {
        content: ''; position: absolute; top: 50%; left: 50%; width: 0; height: 0;
        background: rgba(255,255,255,0.3); border-radius: 50%;
        transform: translate(-50%, -50%); transition: width 0.4s, height 0.4s;
    }
    .ws-body .workname:hover {
        background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important;
        transform: scale(1.08) translateY(-1px);
        box-shadow: 0 4px 8px rgba(99,102,241,0.25), inset 0 1px 0 rgba(255,255,255,0.6);
        border-color: #818cf8 !important;
    }
    .ws-body .workname:hover::after {
        width: 200px; height: 200px;
    }
    .ws-body .wscored {
        display: inline-block !important; background: linear-gradient(135deg, #ffffff, #f8fafc) !important;
        border: 1.5px solid #e2e8f0 !important; border-radius: 8px !important;
        color: #475569 !important; font-size: 11px !important; font-weight: 700 !important;
        padding: 5px 9px !important; height: auto !important; width: auto !important;
        min-width: 28px; text-decoration: none !important; transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1); 
        margin: 3px 2px !important; box-shadow: 0 2px 4px rgba(0,0,0,0.08), inset 0 1px 0 rgba(255,255,255,0.6);
        position: relative; overflow: hidden;
    }
    .ws-body .wscored::before {
        content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
        transition: left 0.5s;
    }
    .ws-body .wscored:hover { 
        border-color: #6366f1 !important; color: #6366f1 !important; 
        background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
        transform: scale(1.12) translateY(-1px); 
        box-shadow: 0 4px 12px rgba(99,102,241,0.25), inset 0 1px 0 rgba(255,255,255,0.7);
    }
    .ws-body .wscored:hover::before {
        left: 100%;
    }
    .ws-body .wscored:active { 
        transform: scale(1.0) translateY(0); 
        box-shadow: 0 1px 3px rgba(99,102,241,0.2);
    }

    /* 小组作品 */
    .ws-body .divgroupscore {
        border: 1.5px solid #e2e8f0 !important; border-radius: 16px !important;
        padding: 14px 10px !important; margin: 8px !important; text-align: center;
        background: linear-gradient(135deg, #fffbeb, #fef3c7) !important;
        width: 135px !important; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
        vertical-align: top; position: relative; overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04),
                    inset 0 1px 0 rgba(255,255,255,0.6);
    }
    .ws-body .divgroupscore::before {
        content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
        background: linear-gradient(90deg, #f59e0b, #fbbf24, #fcd34d);
        opacity: 0; transition: opacity 0.3s ease;
    }
    .ws-body .divgroupscore:hover { 
        border-color: #f59e0b !important; 
        box-shadow: 0 8px 24px rgba(245,158,11,0.2), 0 4px 12px rgba(245,158,11,0.15) !important;
        transform: translateY(-4px) scale(1.02);
        background: linear-gradient(135deg, #fff7ed, #fffbeb) !important;
    }
    .ws-body .divgroupscore:hover::before {
        opacity: 1;
    }
    .ws-body #Wvg {
        display: inline-block; padding: 5px 10px; border-radius: 12px;
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #92400e; font-size: 11px; font-weight: 700;
        border: 1.5px solid #fcd34d; margin: 6px 0;
        box-shadow: 0 2px 4px rgba(245,158,11,0.2), inset 0 1px 0 rgba(255,255,255,0.5);
        transition: all 0.25s ease;
    }
    .ws-body #Wvg:hover {
        transform: scale(1.1);
        box-shadow: 0 4px 8px rgba(245,158,11,0.3), inset 0 1px 0 rgba(255,255,255,0.6);
    }
    .ws-body .groupname {
        display: inline-block !important; background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important;
        border: 1.5px solid #c7d2fe; border-radius: 10px !important;
        color: #3730a3 !important; font-size: 12px !important; font-weight: 700 !important;
        padding: 6px 10px !important; height: auto !important; width: auto !important;
        min-width: 70px; line-height: 18px !important; text-decoration: none !important;
        box-shadow: 0 2px 4px rgba(99,102,241,0.15), inset 0 1px 0 rgba(255,255,255,0.5);
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative; overflow: hidden;
    }
    .ws-body .groupname::after {
        content: ''; position: absolute; top: 50%; left: 50%; width: 0; height: 0;
        background: rgba(255,255,255,0.3); border-radius: 50%;
        transform: translate(-50%, -50%); transition: width 0.4s, height 0.4s;
    }
    .ws-body .groupname:hover {
        background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important;
        transform: scale(1.08) translateY(-1px);
        box-shadow: 0 4px 8px rgba(99,102,241,0.25), inset 0 1px 0 rgba(255,255,255,0.6);
        border-color: #818cf8 !important;
    }
    .ws-body .groupname:hover::after {
        width: 200px; height: 200px;
    }

    /* 未提交列表 */
    .ws-nowork {
        background: #fff; border-radius: 16px; border: 1px solid #e2e8f0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 20px;
    }
    .ws-nowork-head {
        display: flex; align-items: center; gap: 10px;
        padding: 14px 24px; border-bottom: 1px solid #f1f5f9;
        font-size: 14px; font-weight: 700; color: #dc2626;
        background: linear-gradient(135deg, #fef2f2, #fee2e2);
    }
    .ws-nowork-head::before {
        content: "⚠"; margin-right: 4px; font-size: 16px;
    }
    .ws-nowork-body { 
        padding: 20px 24px; text-align: center; 
        background: linear-gradient(135deg, #fafbfc, #ffffff);
    }
    .ws-nowork-body div {
        display: inline-block; margin: 4px 8px; padding: 6px 12px;
        background: #fff; border: 1px solid #e2e8f0; border-radius: 8px;
        font-size: 13px; color: #64748b; font-weight: 500;
        transition: all 0.2s;
    }
    .ws-nowork-body div:hover {
        border-color: #fca5a5; background: #fef2f2; color: #dc2626;
        transform: translateY(-1px); box-shadow: 0 2px 4px rgba(220,38,38,0.1);
    }

    /* 评分标签样式 */
    .ws-body #Wf, .ws-body #Wl {
        display: inline-block; padding: 4px 8px; border-radius: 8px;
        font-size: 11px; font-weight: 700; margin: 0 3px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1), inset 0 1px 0 rgba(255,255,255,0.5);
        transition: all 0.25s ease;
    }
    .ws-body #Wf {
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        color: #92400e; border: 1.5px solid #fcd34d;
    }
    .ws-body #Wf:hover {
        transform: scale(1.1);
        box-shadow: 0 4px 8px rgba(245,158,11,0.25), inset 0 1px 0 rgba(255,255,255,0.6);
    }
    .ws-body #Wl {
        background: linear-gradient(135deg, #dbeafe, #bfdbfe);
        color: #1e40af; border: 1.5px solid #93c5fd;
    }
    .ws-body #Wl:hover {
        transform: scale(1.1);
        box-shadow: 0 4px 8px rgba(59,130,246,0.25), inset 0 1px 0 rgba(255,255,255,0.6);
    }

    /* 复选框样式 */
    .ws-body input[type="checkbox"] {
        width: 20px; height: 20px; cursor: pointer;
        accent-color: #6366f1;
        border-radius: 4px;
        transition: all 0.2s ease;
    }
    .ws-body input[type="checkbox"]:hover {
        transform: scale(1.1);
        box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    
    /* Flash预览图标美化 */
    .ws-body a[href*="flash"] img {
        border-radius: 6px; transition: all 0.25s ease;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .ws-body a[href*="flash"]:hover img {
        transform: scale(1.15) rotate(5deg);
        box-shadow: 0 4px 8px rgba(99,102,241,0.2);
    }

    /* 第二工具栏 */
    .ws-toolbar:last-of-type {
        background: linear-gradient(135deg, rgba(248,250,252,0.5), rgba(241,245,249,0.3)); 
        padding-top: 14px; padding-bottom: 14px;
        border-top: 1px solid #f1f5f9;
    }
    .ws-toolbar #ImageType {
        border-radius: 6px; padding: 4px;
    }
    .ws-toolbar #Labelmsg {
        color: #64748b; font-size: 12px; font-weight: 500;
    }
    .ws-toolbar #ImgBtnFlasherror {
        border-radius: 6px; padding: 4px; transition: all 0.2s;
    }
    .ws-toolbar #ImgBtnFlasherror:hover {
        background: rgba(220,38,38,0.1); transform: scale(1.1);
    }

    /* RadioButtonList 样式优化 */
    .ws-toolbar #RBsort {
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .ws-toolbar #RBsort label {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 6px 14px; margin: 0;
        background: #fff; border: 1.5px solid #e2e8f0;
        border-radius: 20px; cursor: pointer;
        font-size: 12px; font-weight: 500; color: #475569;
        transition: all 0.2s ease;
    }
    .ws-toolbar #RBsort input[type="radio"] {
        margin: 0; width: 16px; height: 16px;
        accent-color: #6366f1;
    }
    .ws-toolbar #RBsort input[type="radio"]:checked + span,
    .ws-toolbar #RBsort label:has(input[type="radio"]:checked) {
        border-color: #6366f1; background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        color: #4338ca; font-weight: 600;
    }
    .ws-toolbar #RBsort label:hover {
        border-color: #818cf8; background: #f8fafc;
    }
</style>
</style>

<div class="ws">
    <!-- 主卡片 -->
    <div class="ws-card">
        <div class="ws-head">
            <div class="ws-icon"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></div>
            <span class="ws-title">作品展示</span>
            <asp:Label ID="Labelshow" runat="server" Font-Bold="True" Font-Names="Arial" Font-Size="13px" />
        </div>
        <div class="ws-toolbar">
            学案：<asp:DropDownList ID="DDLCid" runat="server" Font-Names="Arial" Font-Size="9pt" AutoPostBack="True"
                onselectedindexchanged="DDLCid_SelectedIndexChanged" />
            &nbsp;活动：<asp:DropDownList ID="DDLmid" runat="server" Font-Names="Arial" Font-Size="9pt" AutoPostBack="True"
                onselectedindexchanged="DDLmid_SelectedIndexChanged" />
            &nbsp;
            <asp:Label ID="Labelcolor" runat="server" BackColor="#CDE2FE" Width="12px" Height="12px" CssClass="ws-legend-dot" />&nbsp;作品
            <asp:Label ID="Labelscore" runat="server" BackColor="#FFCC99" Width="11px" Height="11px" CssClass="ws-legend-dot" />&nbsp;评价
            &nbsp;共<asp:Label ID="Labelcounts" runat="server" />件
            &nbsp;
            <asp:ImageButton ID="BtnCheck" runat="server" onclick="BtnCheck_Click"
                ImageUrl="~/images/check.png" ToolTip="将本班自动得分作品全部设置为已评" style="width:18px" />
            <asp:Button ID="BtnA" runat="server" Text="一键评A" SkinID="BtnSmall" onclick="BtnA_Click" ToolTip="将本班该活动未评的作品，全部评为A" />
            <asp:Button ID="BtnB" runat="server" Text="一键评B" SkinID="BtnSmall" onclick="BtnB_Click" ToolTip="将本班该活动未评的作品，全部评为B" />
            <asp:Button ID="BtnCk" runat="server" Text="一键已评" SkinID="BtnSmall" onclick="BtnCk_Click" ToolTip="不用给分的作品，一健全评为０" />
            <asp:Button ID="BtnWp" runat="server" Text="一键未评" SkinID="BtnSmall" onclick="BtnWp_Click" ToolTip="所有作品一键未评" />
            <asp:HyperLink ID="HLautoplay" runat="server" Target="_blank" ToolTip="个人作品自动展播">[展播]</asp:HyperLink>
            <asp:HyperLink ID="HLgroupplay" runat="server" Target="_blank" ToolTip="小组作品自动展播">[组播]</asp:HyperLink>
        </div>
        <div class="ws-toolbar" style="background:transparent; border-bottom:none; padding-top:8px;">
            <asp:Image ID="ImageType" runat="server" />
            <asp:Label ID="Labelmsg" runat="server" />
            <asp:ImageButton ID="ImgBtnFlasherror" runat="server"
                ImageUrl="~/images/flasherror.png" onclick="ImgBtnFlasherror_Click"
                ToolTip="Office文档转换异常标志清除重新转换" />
            <asp:RadioButtonList ID="RBsort" runat="server" AutoPostBack="True"
                Font-Size="9pt" onselectedindexchanged="RBsort_SelectedIndexChanged"
                RepeatDirection="Horizontal" RepeatLayout="Flow">
                <Items>
                    <asp:ListItem Value="0" Selected="True">时间排序</asp:ListItem>
                    <asp:ListItem Value="1">学号排序</asp:ListItem>
                    <asp:ListItem Value="2">IP 排序</asp:ListItem>
                    <asp:ListItem Value="3">小组排序</asp:ListItem>
                    <asp:ListItem Value="4">投票排序</asp:ListItem>
                </Items>
            </asp:RadioButtonList>
        </div>

        <!-- 个人作品 -->
        <div class="ws-body" style="background: linear-gradient(135deg, #fafbfc 0%, #ffffff 50%, #f8fafc 100%);">
            <asp:DataList ID="DataListworks" runat="server" RepeatDirection="Horizontal"
                RepeatColumns="8" DataKeyField="Wid" CellPadding="2"
                onitemdatabound="DataListworks_ItemDataBound"
                onitemcommand="DataListworks_ItemCommand" CellSpacing="2">
                <ItemTemplate>
                    <div class="divscore">
                        <div>
                            <asp:HyperLink ID="HyperLink1" runat="server" Text='<%# Eval("Sname") %>'
                                ToolTip='<%# HttpUtility.HtmlDecode(Eval("Wself").ToString()) %>' Target="_blank" CssClass="workname" />
                            <asp:CheckBox ID="CB" runat="server" Checked='<%# Eval("Wcheck") %>'
                                EnableTheming="True" ToolTip="评价状态" oncheckedchanged="CB_CheckedChanged" AutoPostBack="True" BorderStyle="None" />
                        </div>
                        <div>
                            <asp:Label ID="Wf" runat="server" Text='<%# Eval("Wfscore") %>' ToolTip="互评" />&nbsp;
                            <asp:Label ID="Wl" runat="server" Text='<%# Eval("Wlscore") %>' ToolTip="组评" ForeColor="#0066FF" />&nbsp;
                            <asp:HyperLink ID="Hlflash" runat="server" Height="12px" Target="_blank" ImageUrl="~/images/flashview.png" ToolTip="Flash格式预览" Visible="False" />
                        </div>
                        <div>
                            <asp:LinkButton ID="LG" runat="server" CommandArgument="Wid" CommandName="G" ToolTip="收藏12分" CssClass="wscored">G</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="LA" runat="server" CommandArgument="Wid" CommandName="A" ToolTip="优秀10分" CssClass="wscored">A</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="LB" runat="server" CommandArgument="Wid" CommandName="B" ToolTip="良好8分" CssClass="wscored">B</asp:LinkButton>
                        </div>
                        <div>
                            <asp:LinkButton ID="LC" runat="server" CommandArgument="Wid" CommandName="C" ToolTip="一般6分" CssClass="wscored">C</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="LD" runat="server" CommandArgument="Wid" CommandName="D" ToolTip="落后4分" CssClass="wscored">D</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="LE" runat="server" CommandArgument="Wid" CommandName="E" ToolTip="不及格2分" CssClass="wscored">E</asp:LinkButton>
                        </div>
                        <asp:Label ID="Labelscore" runat="server" Text='<%# Eval("Wscore") %>' Visible="False" />
                        <asp:Label ID="Labelurl" runat="server" Text='<%# Eval("Wurl") %>' Visible="False" />
                        <asp:Label ID="Labelwid" runat="server" Text='<%# Eval("Wid") %>' Visible="False" />
                        <asp:CheckBox ID="Checkwflash" runat="server" Checked='<%# Eval("Wflash") %>' Visible="False" />
                        <asp:CheckBox ID="Checkwerror" runat="server" Checked='<%# Eval("Werror") %>' Visible="False" />
                        <asp:Label ID="Labelwlemotion" runat="server" Text='<%# Eval("Wlemotion") %>' Visible="False" />
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>

        <!-- 小组作品 -->
        <div class="ws-body" style="border-top:2px solid #f1f5f9; background: linear-gradient(135deg, #fffbf0 0%, #fffbeb 50%, #fef3c7 100%);">
            <asp:DataList ID="DataListgroup" runat="server" RepeatDirection="Horizontal"
                RepeatColumns="6" DataKeyField="Gid" CellPadding="2" CellSpacing="2"
                onitemcommand="DataListgroup_ItemCommand" onitemdatabound="DataListgroup_ItemDataBound" Caption="小组作品">
                <ItemTemplate>
                    <div class="divgroupscore">
                        <div>
                            <asp:HyperLink ID="HyperLinkg1" runat="server" Text='<%# Eval("Sgtitle") %>'
                                ToolTip='<%# Eval("Gnote") %>' Target="_blank" CssClass="groupname" />
                        </div>
                        <asp:Label ID="Wvg" runat="server" Text='<%# Eval("Gvote") %>' ToolTip="票数" />
                        <asp:CheckBox ID="CBg" runat="server" AutoPostBack="True" BorderStyle="None"
                            Checked='<%# Eval("Gcheck") %>' EnableTheming="True" oncheckedchanged="CBg_CheckedChanged"
                            ToolTip="评价状态" />
                        <div>
                            <asp:LinkButton ID="L20" runat="server" CommandArgument="Gid" CommandName="20" ToolTip="20学分" CssClass="wscored">A+</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="L19" runat="server" CommandArgument="Gid" CommandName="19" ToolTip="19学分" CssClass="wscored">A</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="L18" runat="server" CommandArgument="Gid" CommandName="18" ToolTip="18学分" CssClass="wscored">A-</asp:LinkButton>
                        </div>
                        <div>
                            <asp:LinkButton ID="L17" runat="server" CommandArgument="Gid" CommandName="17" ToolTip="17学分" CssClass="wscored">B+</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="L16" runat="server" CommandArgument="Gid" CommandName="16" ToolTip="16学分" CssClass="wscored">B</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="L15" runat="server" CommandArgument="Gid" CommandName="15" ToolTip="15学分" CssClass="wscored">B-</asp:LinkButton>
                        </div>
                        <div>
                            <asp:LinkButton ID="L14" runat="server" CommandArgument="Gid" CommandName="14" ToolTip="14学分" CssClass="wscored">C+</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="L13" runat="server" CommandArgument="Gid" CommandName="13" ToolTip="13学分" CssClass="wscored">C</asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="L12" runat="server" CommandArgument="Gid" CommandName="12" ToolTip="12学分" CssClass="wscored">C-</asp:LinkButton>
                        </div>
                        <asp:Label ID="Labelgscore" runat="server" Text='<%# Eval("Gscore") %>' Visible="False" />
                        <asp:Label ID="Labelgurl" runat="server" Text='<%# Eval("Gurl") %>' Visible="False" />
                        <asp:Label ID="Labelgid" runat="server" Text='<%# Eval("Gid") %>' Visible="False" />
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- 未提交列表 -->
    <div class="ws-nowork">
        <div class="ws-nowork-head">未提交作品学生</div>
        <div class="ws-nowork-body">
            <asp:DataList ID="DataListNoworks" runat="server" RepeatDirection="Horizontal"
                RepeatColumns="8" CellPadding="1">
                <ItemTemplate>
                    <div>
                        <asp:Label ID="Label1" runat="server" Height="18px" Text='<%# Eval("Sname") %>'
                            ToolTip='<%# Eval("Sscore") %>' Width="80px" />
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <asp:ImageButton ID="Btnreflash" runat="server" ImageUrl="~/images/refresh.gif" onclick="Btnreflash_Click" style="display:none" />
</div>

<script type="text/javascript">
    function myrefresh() {
        document.getElementById("<%= Btnreflash.ClientID %>").click();
    }
    setTimeout("myrefresh()", 30000);
</script>
</asp:Content>
