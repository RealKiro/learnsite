<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_txtformresult, LearnSite" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Register Assembly="Anthem" Namespace="Anthem" TagPrefix="anthem" %>
<script runat="server">
    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);

        string lid = Request.QueryString["lid"] ?? "";
        string mid = Request.QueryString["mid"] ?? "";
        string mcid = Request.QueryString["mcid"] ?? "";
        if (string.IsNullOrEmpty(lid)) return;

        try
        {
            string cs = null;
            try
            {
                Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
                if (dbType != null)
                {
                    FieldInfo connField = dbType.GetField("connectionString", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                    if (connField != null)
                        cs = connField.GetValue(null) as string;
                }
            }
            catch { }
            if (string.IsNullOrEmpty(cs))
            {
                try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
                catch { }
            }

            int listId = 0;
            if (string.IsNullOrEmpty(cs) || !int.TryParse(lid, out listId) || listId <= 0) return;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 1 L.Ltype, M.Mfiletype
                    FROM Listmenu L
                    LEFT JOIN Mission M ON M.Mid = L.Lxid
                    WHERE L.Lid=@Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            string mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim().ToLower() : "";
                            bool isMindMap =
                                ltype == "10" ||
                                ltype == "导图" ||
                                ltype == "脑图" ||
                                mfiletype == "km" ||
                                mfiletype == "mm" ||
                                mfiletype == "mindmap" ||
                                mfiletype == "kitymind";

                            if (isMindMap)
                            {
                                Response.Redirect("program.aspx?lid=" + Server.UrlEncode(lid) + "&mid=" + Server.UrlEncode(mid) + "&mcid=" + Server.UrlEncode(mcid), true);
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<style>
    .survey-layout {
        max-width: 1500px;
        margin: 0 auto;
        padding: 20px;
        font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
        animation: fadeIn 0.4s ease;
    }
    .survey-sidebar { display: none; }
    .survey-show-page { width: 100%; }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .survey-header {
        background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 50%, #6d28d9 100%);
        border-radius: 16px;
        padding: 32px;
        margin-bottom: 24px;
        box-shadow: 0 4px 20px rgba(139,92,246,.25);
        position: relative;
        overflow: hidden;
    }
    .survey-header::before {
        content: '';
        position: absolute;
        top: -40px;
        right: -40px;
        width: 140px;
        height: 140px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .survey-header-icon {
        font-size: 42px;
        margin-bottom: 10px;
        position: relative;
        z-index: 1;
    }
    .survey-header-title {
        font-size: 26px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 6px;
        position: relative;
        z-index: 1;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .survey-header-title img { width: 30px; height: 30px; filter: brightness(0) invert(1); }
    .survey-header-desc {
        font-size: 14px;
        color: rgba(255,255,255,.85);
        position: relative;
        z-index: 1;
    }
    .survey-msg {
        padding: 14px 20px;
        border-radius: 10px;
        font-size: 14px;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .survey-msg-info {
        background: #faf5ff;
        border: 1px solid #e9d5ff;
        color: #6b21a8;
    }
    .survey-toolbar {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 14px 18px;
        margin-bottom: 18px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        flex-wrap: wrap;
    }
    .survey-toolbar .topicleft,
    .survey-toolbar .topicright {
        float: none !important;
        width: auto !important;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }
    .survey-toolbar .topicleft { color: #334155; font-weight: 600; }
    .survey-toolbar .topicleft #Labelreplycount { color: #7c3aed; font-weight: 700; }
    .survey-toolbar img { transition: transform .15s ease; border-radius: 4px; }
    .survey-toolbar img:hover { transform: scale(1.1); }
    #GVtxtform {
        width: 100% !important;
        border-collapse: separate !important;
        border-spacing: 0 16px !important;
    }
    #GVtxtform td {
        border: none !important;
        padding: 0 !important;
        background: transparent !important;
    }
    #GVtxtform .topichead {
        padding: 14px 18px !important;
        background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%) !important;
        border-bottom: 1px solid #e9d5ff !important;
        border-radius: 12px 12px 0 0;
        height: auto !important;
        display: flex !important;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        flex-wrap: wrap;
    }
    #GVtxtform .topichead .topicleft,
    #GVtxtform .topichead .topicright {
        float: none !important;
        width: auto !important;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }
    #GVtxtform .topichead [id*='Labelscore'] {
        background: linear-gradient(135deg, #f59e0b, #f97316);
        color: #fff !important;
        border-radius: 10px;
        padding: 3px 10px;
        font-size: 12px;
        font-weight: 600;
    }
    #GVtxtform > tbody > tr > td > div {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,.04);
        overflow: hidden;
        transition: all .2s ease;
    }
    #GVtxtform > tbody > tr > td > div:hover {
        border-color: #d8b4fe;
        box-shadow: 0 4px 16px rgba(139,92,246,.12);
        transform: translateY(-1px);
    }
    #GVtxtform > tbody > tr > td > div > div:not(.topichead) {
        padding: 18px 20px;
        color: #334155;
        line-height: 1.85;
        font-size: 14px;
    }
    .survey-bottom {
        margin-top: 16px;
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 12px 16px;
        display: flex;
        justify-content: flex-end;
        align-items: center;
        gap: 8px;
    }
    .survey-bottom img { transition: transform .15s ease; border-radius: 4px; }
    .survey-bottom img:hover { transform: scale(1.1); }
    #Labelnostu {
        display: block;
        margin-top: 16px;
        text-align: center;
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        color: #64748b !important;
        padding: 26px 12px;
        font-size: 14px;
    }
    @media (max-width: 768px) {
        .survey-layout { padding: 12px; }
        .survey-header { padding: 24px 18px; }
        .survey-header-title { font-size: 22px; }
        .survey-toolbar { padding: 12px 14px; }
        #GVtxtform .topichead { padding: 12px 14px !important; }
        #GVtxtform > tbody > tr > td > div > div:not(.topichead) { padding: 14px 14px; }
    }
</style>
<div class="survey-layout">
    <div class="survey-sidebar"></div>
    <div class="survey-show-page">
        <div id="topper"></div>
        <div class="survey-header">
            <div class="survey-header-icon">📋</div>
            <div class="survey-header-title">
                <anthem:Image ID="Image2" runat="server" ImageUrl="~/images/inquiry.png" />
                <anthem:Label ID="LbMtitle" runat="server" Font-Size="12pt" Font-Bold="True" Font-Names="宋体,Arial,Helvetica,sans-serif"></anthem:Label>
            </div>
            <div class="survey-header-desc">填表作业结果展示与评分区</div>
        </div>
        <div class="survey-toolbar">
            <div class="topicleft">
                当前列表：<anthem:Label ID="Labelreplycount" runat="server"></anthem:Label>
                <anthem:ImageButton ID="ImageBtngoodall" runat="server" ImageUrl="~/images/right.gif" onclick="ImageBtngoodall_Click" ToolTip="给所有未评分的填表加6分" Visible="False" />
                <anthem:ImageButton ID="ImageBtngood2" runat="server" ImageUrl="~/images/right.gif" onclick="ImageBtngood2_Click" ToolTip="给所有未评分的填表加2分" Visible="False" />
            </div>
            <div class="topicright">
                <anthem:ImageButton ID="ImageBtnFresh" runat="server" ImageUrl="~/images/refresh2.gif" onclick="ImageBtnFresh_Click" />
                <anthem:HyperLink ID="HLbottom" runat="server" BorderStyle="None" BorderWidth="0px" ImageUrl="~/images/bottom.png" NavigateUrl="#bottom" ToolTip="跳到底部"></anthem:HyperLink>
            </div>
        </div>
        <anthem:GridView ID="GVtxtform" runat="server" AutoGenerateColumns="False" CellPadding="1" Width="100%" onrowdatabound="GVtxtform_RowDataBound" DataKeyNames="rid" PageSize="5" CellSpacing="1" ShowHeader="False" GridLines="None" onrowcommand="GVtxtform_RowCommand">
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <div style="text-align: left;">
                            <div class="topichead">
                                <div class="topicleft">
                                    <anthem:Image ID="Imageflag" runat="server" ImageUrl="~/images/topicnormal.png" />
                                    <anthem:Label ID="Labelfloor" runat="server"></anthem:Label>楼
                                    <anthem:Label ID="Labelsname" runat="server" Text='<%# Bind("Sname") %>' Font-Bold="True"></anthem:Label>
                                    ：<anthem:Label ID="Labeldate" runat="server" Text='<%# Bind("Rtime") %>'></anthem:Label>
                                    学分：<anthem:Label ID="Labelscore" runat="server" Text='<%# Bind("Rscore") %>' ToolTip="学分" ForeColor="#333333"></anthem:Label>
                                    <anthem:Image ID="Imageagree" runat="server" Visible="False" ImageUrl="~/images/good16.png" />
                                    <anthem:Label ID="Labelsnum" runat="server" Text='<%# Bind("Rsnum") %>' Visible="False"></anthem:Label>
                                </div>
                                <div class="topicright">
                                    <anthem:ImageButton ID="ImageButtonGood" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Good" ImageUrl="~/images/right.gif" ToolTip="加2分"></anthem:ImageButton>
                                    <anthem:ImageButton ID="ImageButtonless" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Less" ImageUrl="~/images/ban.gif" ToolTip="减2分"></anthem:ImageButton>
                                    赞(<anthem:Label ID="Labelagree" runat="server" Text='<%# Bind("Ragree") %>'></anthem:Label>)
                                    <anthem:ImageButton ID="ImageButtonAgree" runat="server" CausesValidation="false" CommandArgument='<%# Bind("rid") %>' CommandName="Agree" ImageUrl="~/images/good24.gif" ToolTip="点赞"></anthem:ImageButton>
                                </div>
                            </div>
                            <div>
                                <div>
                                    <%# UnEdit(HttpUtility.HtmlDecode(Eval("Rwords").ToString()))%>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <HeaderStyle Font-Bold="False" />
        </anthem:GridView>
        <div id="bottom"></div>
        <div class="survey-bottom">
            <anthem:ImageButton ID="ImageBtnFreshtwo" runat="server" ImageUrl="~/images/refresh2.gif" onclick="ImageBtnFresh_Click" />
            <anthem:HyperLink ID="HLtop" runat="server" BorderStyle="None" BorderWidth="0px" ImageUrl="~/images/top.png" NavigateUrl="#topper" ToolTip="跳到顶部"></anthem:HyperLink>
        </div>
        <anthem:Label ID="Labelnostu" runat="server" ForeColor="#7D7D7D"></anthem:Label>
    </div>
</div>
</asp:Content>
