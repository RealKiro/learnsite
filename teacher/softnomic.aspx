<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_softnomic, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .sn-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .sn-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .sn-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .sn-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .sn-title .sn-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#10b981,#34d399);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .sn-title .sn-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sn-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .sn-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .sn-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .sn-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .sn-card-title svg { width: 18px; height: 18px; stroke: #10b981; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sn-card-body { padding: 20px 24px; }

    /* 筛选行 */
    .sn-filter-row {
        display: flex; align-items: center; gap: 20px; margin-bottom: 16px; flex-wrap: wrap;
    }
    .sn-filter-group { display: flex; align-items: center; gap: 8px; }
    .sn-filter-group label { font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap; }
    .sn-select {
        padding: 7px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; cursor: pointer; font-family: inherit;
    }
    .sn-select:focus { border-color: #6ee7b7; box-shadow: 0 0 0 3px rgba(16,185,129,.1); }

    /* 控制栏 */
    .sn-controls {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        padding: 14px 20px; background: #f0fdf4; border: 1px solid #d1fae5;
        border-radius: 10px; margin-bottom: 16px;
    }
    .sn-controls .sn-divider { width: 1px; height: 24px; background: #bbf7d0; }
    .sn-controls .sn-label-num { font-size: 13px; color: #065f46; font-weight: 500; }

    .sn-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 5px;
        padding: 7px 16px; border-radius: 8px; font-size: 12px; font-weight: 500;
        border: 1px solid #d1fae5; background: #fff; color: #065f46;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .sn-btn:hover { background: #ecfdf5; border-color: #6ee7b7; box-shadow: 0 1px 4px rgba(16,185,129,.1); }
    .sn-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sn-btn-danger {
        border-color: #fecaca; color: #991b1b; background: #fef2f2;
    }
    .sn-btn-danger:hover { background: #fee2e2; border-color: #fca5a5; }

    .sn-nav-btn {
        display: inline-flex; align-items: center; justify-content: center;
        width: 30px; height: 30px; border-radius: 6px; border: 1px solid #d1fae5;
        background: #fff; cursor: pointer; transition: all .15s;
    }
    .sn-nav-btn:hover { background: #ecfdf5; border-color: #6ee7b7; }
    .sn-nav-btn img { width: 16px; height: 16px; }

    /* 评价区 */
    .sn-eval-row {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 14px 20px; background: #fffbeb; border: 1px solid #fde68a;
        border-radius: 10px; margin-bottom: 16px;
    }
    .sn-eval-row label { font-size: 13px; font-weight: 500; color: #92400e; white-space: nowrap; }
    .sn-eval-row .sn-divider { width: 1px; height: 24px; background: #fde68a; }
    .sn-eval-row span label { font-size: 12px; }

    /* 作品展示区 */
    .sn-preview {
        min-height: 200px; padding: 20px; text-align: center;
        border: 1px solid #f1f5f9; border-radius: 10px;
        background: #fafbfc;
    }
    .sn-preview img, .sn-preview object, .sn-preview embed, .sn-preview iframe {
        max-width: 100%; border-radius: 6px;
    }

    /* 隐藏的刷新按钮 */
    .sn-hidden-refresh { position: absolute; left: -9999px; }
    .sn-hidden-label { display: none; }
</style>

<div class="sn-page">
    <!-- 页面标题 -->
    <div class="sn-header">
        <div class="sn-title-wrap">
            <div class="sn-title">
                <span class="sn-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                </span>
                自学作品评价与展示
            </div>
            <div class="sn-subtitle">浏览学生自学作品，进行评分和评语，支持自动循环展播</div>
        </div>
    </div>

    <!-- 筛选卡片 -->
    <div class="sn-card">
        <div class="sn-card-header">
            <div class="sn-card-title">
                <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
                资源筛选
            </div>
        </div>
        <div class="sn-card-body">
            <div class="sn-filter-row">
                <div class="sn-filter-group">
                    <label>资源分类：</label>
                    <asp:DropDownList ID="DDLCategory" runat="server" 
                        Width="300px" AutoPostBack="True" CssClass="sn-select"
                        onselectedindexchanged="DDLCategory_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
            </div>
            <div class="sn-filter-row">
                <div class="sn-filter-group">
                    <label>资源标题：</label>
                    <asp:DropDownList ID="DDLsoft" runat="server" Width="300px" 
                        AutoPostBack="True" CssClass="sn-select"
                        onselectedindexchanged="DDLsoft_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>

    <!-- 控制与评价卡片 -->
    <div class="sn-card">
        <div class="sn-card-header">
            <div class="sn-card-title">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                播放控制与评价
            </div>
        </div>
        <div class="sn-card-body">
            <!-- 播放控制栏 -->
            <div class="sn-controls">
                <asp:Button ID="Btnflash" runat="server" Text="刷新" onclick="Btnflash_Click" 
                    CssClass="sn-btn" />
                <asp:Button ID="Btnrestart" runat="server" Text="重新" onclick="Btnrestart_Click" 
                    CssClass="sn-btn" />
                <asp:Button ID="Btnstop" runat="server" Text="继续" onclick="Btnstop_Click" 
                    CssClass="sn-btn" />
                <div class="sn-divider"></div>
                <asp:ImageButton ID="ImgBtnLeft" runat="server" ImageUrl="~/images/left.png" 
                    onclick="ImgBtnLeft_Click" Width="16px" CssClass="sn-nav-btn" />
                <asp:DropDownList ID="DDLstore" runat="server" 
                    Font-Bold="True" Width="100px" AutoPostBack="True" Font-Size="12pt" CssClass="sn-select"
                    onselectedindexchanged="DDLstore_SelectedIndexChanged">
                    <asp:ListItem></asp:ListItem>
                </asp:DropDownList>
                <asp:ImageButton ID="ImgBtnright" runat="server" 
                    ImageUrl="~/images/right.png" onclick="ImgBtnright_Click" CssClass="sn-nav-btn" />
                <asp:Label ID="Labelnum" runat="server" Font-Names="Arial" Font-Size="9pt" CssClass="sn-label-num"></asp:Label>
            </div>

            <asp:Label ID="lbcurindex" runat="server" Text="0" Visible="False" CssClass="sn-hidden-label"></asp:Label>

            <!-- 评价栏 -->
            <div class="sn-eval-row">
                <label>教师评语：</label>
                <asp:TextBox ID="TextBoxWself" runat="server" Width="350px" 
                    BorderColor="Silver" BorderStyle="Dashed" BorderWidth="1px" 
                    BackColor="#FFF9E1"></asp:TextBox>
                <div class="sn-divider"></div>
                <asp:RadioButtonList ID="RBLselect" runat="server" RepeatDirection="Horizontal" Visible="True" 
                    Font-Size="9pt" AutoPostBack="True" onselectedindexchanged="RBLselect_SelectedIndexChanged" RepeatLayout="Flow" 
                    CellPadding="3" CellSpacing="3">
                    <asp:ListItem>G</asp:ListItem>
                    <asp:ListItem>A</asp:ListItem>
                    <asp:ListItem>B</asp:ListItem>
                    <asp:ListItem>C</asp:ListItem>
                    <asp:ListItem>D</asp:ListItem>
                    <asp:ListItem>E</asp:ListItem>
                    <asp:ListItem>O</asp:ListItem>
                </asp:RadioButtonList>
                <div class="sn-divider"></div>
                <asp:CheckBox ID="CkFlash" runat="server" 
                    oncheckedchanged="CkFlash_CheckedChanged" Text="FlashLoop" 
                    ToolTip="Flash播放循环设置" AutoPostBack="True" />
                <asp:Button ID="Btndel" runat="server" Text="删除" onclick="Btndel_Click" 
                    CssClass="sn-btn sn-btn-danger" ToolTip="删除该作品，不可恢复！" />
            </div>
        </div>
    </div>

    <!-- 作品展示卡片 -->
    <div class="sn-card">
        <div class="sn-card-header">
            <div class="sn-card-title">
                <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                作品预览
            </div>
        </div>
        <div class="sn-card-body">
            <div class="sn-preview">
                <asp:Literal ID="Literal1" runat="server"></asp:Literal>
            </div>
        </div>
    </div>
</div>

<!-- 隐藏的循环展播刷新按钮 -->
<div class="sn-hidden-refresh">
    <asp:ImageButton ID="ImgBtn" runat="server" ImageUrl="~/images/refresh.gif" 
        onclick="ImgBtn_Click" ToolTip="循环展播专用刷新" />
</div>

<script type="text/javascript">
    function myrefresh() {
        var stxt = document.getElementById("<%= Btnstop.ClientID %>").value;
        if (stxt == "暂停") {
            document.getElementById("<%= ImgBtn.ClientID %>").click();
        }
    }
    setTimeout("myrefresh()", 8000);
</script>
</asp:Content>
