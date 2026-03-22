<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_mythware, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .mw-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .mw-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .mw-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .mw-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .mw-title .mw-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#10b981,#34d399);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .mw-title .mw-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mw-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .mw-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .mw-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .mw-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .mw-card-title svg { width: 18px; height: 18px; stroke: #10b981; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mw-card-body { padding: 20px 24px; }

    /* 文件列表 */
    .mw-filelist { padding: 16px 24px; }
    .mw-filelist table { border: none !important; }
    .mw-filelist td { border: none !important; padding: 6px 10px !important; font-size: 13px; color: #334155; }
    .mw-filelist a { color: #10b981; text-decoration: none; font-weight: 500; }
    .mw-filelist a:hover { color: #059669; text-decoration: underline; }

    .mw-download-btn {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 6px 14px; border-radius: 6px; background: #ecfdf5;
        border: 1px solid #d1fae5; color: #065f46; font-size: 12px; font-weight: 500;
        cursor: pointer; transition: all .15s; text-decoration: none;
    }
    .mw-download-btn:hover { background: #d1fae5; border-color: #6ee7b7; }
    .mw-download-btn img { width: 14px; height: 14px; }

    /* 表单 */
    .mw-form-row {
        display: flex; align-items: center; gap: 14px; margin-bottom: 18px; flex-wrap: wrap;
    }
    .mw-form-group { display: flex; align-items: center; gap: 8px; }
    .mw-form-group label {
        font-size: 13px; font-weight: 500; color: #475569; white-space: nowrap;
    }
    .mw-form-group select {
        padding: 7px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; font-family: inherit;
    }
    .mw-form-group select:focus { border-color: #6ee7b7; box-shadow: 0 0 0 3px rgba(16,185,129,.1); }
    .mw-form-group input[type="text"] {
        padding: 7px 14px; border-radius: 8px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fff; outline: none;
        transition: border-color .15s; width: 80px;
    }
    .mw-form-group input[type="text"]:focus { border-color: #6ee7b7; box-shadow: 0 0 0 3px rgba(16,185,129,.1); }
    .mw-form-checks { font-size: 13px; color: #475569; }
    .mw-form-checks span label { font-size: 13px; }

    /* 上传区 */
    .mw-upload-area {
        display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        padding: 14px 18px; background: #f0fdf4; border: 1px dashed #86efac;
        border-radius: 10px; margin-bottom: 18px;
    }
    .mw-upload-area label { font-size: 13px; font-weight: 500; color: #065f46; white-space: nowrap; }

    /* 按钮 */
    .mw-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 9px 24px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .mw-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .mw-btn-primary {
        background: linear-gradient(135deg,#10b981,#34d399); color: #fff;
        border-color: #10b981; box-shadow: 0 2px 8px rgba(16,185,129,.18);
    }
    .mw-btn-primary:hover { background: linear-gradient(135deg,#059669,#10b981); border-color: #059669; box-shadow: 0 4px 12px rgba(16,185,129,.25); color: #fff; }

    .mw-msg { font-size: 13px; color: #ef4444; margin: 12px 0; display: block; }
    .mw-preview-link {
        display: inline-flex; align-items: center; gap: 6px;
        font-size: 13px; color: #10b981; text-decoration: none; font-weight: 500;
    }
    .mw-preview-link:hover { color: #059669; text-decoration: underline; }
    .mw-preview-link img { width: 16px; height: 16px; }

    .mw-tip {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 16px; border-radius: 8px;
        background: #ecfdf5; border: 1px solid #d1fae5; color: #065f46;
        font-size: 12px; line-height: 1.5;
    }
    .mw-tip svg { width: 16px; height: 16px; stroke: #10b981; fill: none; stroke-width: 2; flex-shrink: 0; }
</style>

<div class="mw-page">
    <!-- 页面标题 -->
    <div class="mw-header">
        <div class="mw-title-wrap">
            <div class="mw-title">
                <span class="mw-icon">
                    <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>
                </span>
                极域班级模型
            </div>
            <div class="mw-subtitle">生成任教班级的极域 ClassModel 模型文件，支持打包下载</div>
        </div>
    </div>

    <!-- 模型文件列表卡片 -->
    <div class="mw-card">
        <div class="mw-card-header">
            <div class="mw-card-title">
                <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                最新模型文件
            </div>
            <asp:ImageButton ID="ImgBtnDown" runat="server" 
                ImageUrl="~/images/down.gif" onclick="ImgBtnDown_Click" ToolTip="点击打包下载" 
                CssClass="mw-download-btn" style="width: 16px" />
        </div>
        <div class="mw-filelist">
            <asp:DataList ID="Dlfilelist" runat="server" 
                RepeatColumns="3" RepeatDirection="Horizontal" CellPadding="3" CellSpacing="3" Width="100%">
                <ItemTemplate>
                    <div style="text-align: left;">
                        <asp:Label ID="Labelfid" runat="server" Text='<%# Eval("fid") %>'></asp:Label>&nbsp;
                        <asp:HyperLink ID="HLfname" runat="server" Target="_blank" Text='<%# Eval("fname") %>'></asp:HyperLink>&nbsp;
                        <asp:Label ID="Labelfsize" runat="server" Text='<%# Eval("fsize") %>'></asp:Label>
                        <asp:Label ID="Labelfread" runat="server" Text='<%# Eval("fread") %>' ToolTip="是否只读（T：只读 | F：可写）" ForeColor="#00A279"></asp:Label>
                        <asp:Label ID="Labelurl" runat="server" Text='<%# Eval("furl") %>' Visible="false"></asp:Label>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <asp:Label ID="Labeldirhid" runat="server" Visible="False"></asp:Label>
    <asp:Label ID="Labeldir" runat="server" Visible="False"></asp:Label>

    <!-- 生成设置卡片 -->
    <div class="mw-card">
        <div class="mw-card-header">
            <div class="mw-card-title">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9V12"/></svg>
                生成设置
            </div>
        </div>
        <div class="mw-card-body">
            <!-- 上传原有模型 -->
            <div class="mw-upload-area">
                <label>上传原有班级模型（xml/cls）：</label>
                <asp:FileUpload ID="FuClassModel" runat="server" Font-Size="9pt" />
            </div>

            <!-- 选项 -->
            <div class="mw-form-row">
                <div class="mw-form-checks">
                    <asp:CheckBox ID="CkMachine" runat="server" Text="空余学生机是否预处理为主机名" 
                        ToolTip="主机名与IP对应表有记录则有效" Checked="True" />
                </div>
            </div>

            <div class="mw-form-row">
                <div class="mw-form-group">
                    <label>签到时间范围：</label>
                    <asp:DropDownList ID="DDLmonth" runat="server" Font-Size="9pt">
                        <asp:ListItem Value="1" Selected="True">1周内</asp:ListItem>
                        <asp:ListItem Value="2">2周内</asp:ListItem>
                        <asp:ListItem Value="3">3周内</asp:ListItem>
                        <asp:ListItem Value="4">4周内</asp:ListItem>
                        <asp:ListItem Value="5">5周内</asp:ListItem>
                        <asp:ListItem Value="6">6周内</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="mw-form-row">
                <div class="mw-form-group">
                    <asp:HyperLink ID="Hlkroom" runat="server" ImageUrl="~/images/zoom.gif" 
                        NavigateUrl="~/teacher/myseat.aspx" Target="_blank" ToolTip="机房视图预览" 
                        CssClass="mw-preview-link">HyperLink</asp:HyperLink>
                    <label>电脑室名称：</label>
                    <asp:TextBox ID="TextBoxRoom" runat="server" Width="80px"></asp:TextBox>
                </div>
            </div>

            <div style="margin-top: 24px;">
                <asp:Button ID="BtnBuild" runat="server" onclick="BtnBuild_Click" 
                    CssClass="mw-btn mw-btn-primary" Text="生成任教班级模型" />
            </div>

            <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed" Width="98%" CssClass="mw-msg"></asp:Label>
        </div>
    </div>

    <!-- 提示 -->
    <div class="mw-tip">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        根据最近几周内的签到表的姓名与IP对应，生成所教班级模型，可点击打包按钮下载
    </div>
</div>
</asp:Content>

