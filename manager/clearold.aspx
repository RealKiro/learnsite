<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Manager_clearold, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cl-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .cl-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .cl-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#ef4444,#f87171);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(239,68,68,.25);flex-shrink:0;}
    .cl-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .cl-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .cl-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .cl-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:24px;}
    .cl-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .cl-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .cl-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .cl-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .cl-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .ci.rose{background:#fff1f2;} .ci.rose svg{stroke:#f43f5e;}
    .cl-card-bd{padding:22px;display:flex;flex-direction:column;gap:16px;}
    .cl-row{display:flex;align-items:center;gap:10px;flex-wrap:wrap;justify-content:center;}
    .cl-label{font-size:13px;color:#64748b;}
    .cl-card select,.cl-card input[type="text"]{padding:6px 12px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:13px;font-family:inherit;background:#f8fafc;transition:border-color .2s;outline:none;}
    .cl-card select:focus,.cl-card input[type="text"]:focus{border-color:#818cf8;background:#fff;}
    .cl-card input[type="checkbox"]{width:17px;height:17px;accent-color:#ef4444;cursor:pointer;vertical-align:middle;}
    .cl-card input[type="checkbox"]+label{cursor:pointer;color:#475569;font-size:13px;user-select:none;vertical-align:middle;margin-left:4px;}
    .btn-amber{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 22px;background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(245,158,11,.3);}
    .btn-amber:hover{box-shadow:0 4px 14px rgba(245,158,11,.4);transform:translateY(-1px);}
    .btn-emerald{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 22px;background:linear-gradient(135deg,#10b981,#059669);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(16,185,129,.3);}
    .btn-emerald:hover{box-shadow:0 4px 14px rgba(16,185,129,.4);transform:translateY(-1px);}
    .btn-rose{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 22px;background:linear-gradient(135deg,#f43f5e,#e11d48);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(244,63,94,.3);}
    .btn-rose:hover{box-shadow:0 4px 14px rgba(244,63,94,.4);transform:translateY(-1px);}
    .cl-hint{font-size:12px;color:#94a3b8;text-align:center;}
    .cl-warn{background:#fef2f2;border:1px solid #fecaca;border-radius:10px;padding:12px 16px;font-size:12.5px;color:#dc2626;text-align:center;font-weight:500;margin-top:8px;}
</style>

<div class="cl-page">
    <div class="cl-hd">
        <div class="cl-hd-icon"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg></div>
        <div class="cl-hd-text"><h1>数据清理</h1><p>清理历史记录、打字成绩或指定班级数据</p></div>
    </div>

    <div class="cl-grid">

    <!-- 历史数据 -->
    <div class="cl-card">
        <div class="cl-card-hd">
            <span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
            清理历史数据
        </div>
        <div class="cl-card-bd">
            <div class="cl-row">
                <span class="cl-label">请选择清理</span>
                <asp:DropDownList ID="DDLyear" runat="server">
                    <asp:ListItem Selected="True" Value="3">三年前</asp:ListItem>
                    <asp:ListItem Value="5">五年前</asp:ListItem>
                </asp:DropDownList>
                <span class="cl-label">的数据</span>
            </div>
            <asp:Button ID="ButtonClear" runat="server" Text="执行清理" CssClass="btn-amber"
                ToolTip="提示：将指定年前的作品记录、签到记录、讨论记录删除！" onclick="ButtonClear_Click" />
            <div class="cl-hint">包括：作品记录、签到记录和测验记录</div>
        </div>
    </div>

    <!-- 打字成绩 -->
    <div class="cl-card">
        <div class="cl-card-hd">
            <span class="ci emerald"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></span>
            清除打字成绩
        </div>
        <div class="cl-card-bd">
            <asp:Button ID="ButtonClearTyper" runat="server" Text="清除全校中文打字成绩" CssClass="btn-emerald"
                ToolTip="提示：将清除全校中文打字成绩！" onclick="ButtonClearTyper_Click" />
            <asp:Button ID="ButtonClearFinger" runat="server" Text="清除全校指法练习成绩" CssClass="btn-emerald"
                ToolTip="提示：将清除全校指法练习成绩！" onclick="ButtonClearFinger_Click" />
        </div>
    </div>

    <!-- 清空班级 -->
    <div class="cl-card">
        <div class="cl-card-hd">
            <span class="ci rose"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
            清空班级数据
        </div>
        <div class="cl-card-bd">
            <div class="cl-row">
                <span class="cl-label">请选择：</span>
                <asp:DropDownList ID="DDLgrade" runat="server" Width="50px" AutoPostBack="True" 
                    onselectedindexchanged="DDLgrade_SelectedIndexChanged"></asp:DropDownList>
                <span class="cl-label">年级</span>
                <asp:DropDownList ID="DDLclass" runat="server" Width="50px" AutoPostBack="True" 
                    onselectedindexchanged="DDLclass_SelectedIndexChanged"></asp:DropDownList>
                <span class="cl-label">班级</span>
            </div>
            <div class="cl-row">
                <span class="cl-label">当前学生数：</span>
                <asp:TextBox ID="TextBoxcount" runat="server" Width="60px" ReadOnly="True"></asp:TextBox>
                <asp:CheckBox ID="CheckBoxDel" runat="server" Text="确认操作" />
            </div>
            <asp:Button ID="ButtonClearStudent" runat="server" Text="清空该班级所有学生" CssClass="btn-rose"
                ToolTip="提示：将清空该班级的所有学生及其作品、签到、调查、讨论等记录，无法恢复！" onclick="ButtonClearStudent_Click" />
        </div>
    </div>

    </div>

    <div class="cl-warn">
        ⚠ <asp:Label ID="Labelmsg" runat="server">清理前注意备份数据库！</asp:Label>
    </div>
</div>
</asp:Content>
