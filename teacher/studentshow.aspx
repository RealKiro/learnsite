<%@ page title="" language="C#" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_studentshow, LearnSite" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>学生基本信息</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif; background: #fff; margin: 0; padding: 0; }
        #form1 { width: 100%; }
        .modal-card { background: #fff; overflow: hidden; }
        .modal-header { background: linear-gradient(135deg, #0ea5e9, #38bdf8); padding: 10px 18px; display: flex; align-items: center; gap: 10px; }
        .modal-header svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; flex-shrink: 0; }
        .modal-header h2 { font-size: 14px; margin: 0; font-weight: 600; color: #fff; }
        .modal-body { padding: 14px 18px; }
        .info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 7px 10px; }
        .kv { background: #f8fafc; border: 1px solid #eef2f7; border-radius: 6px; padding: 6px 9px; }
        .kv .k { font-size: 10px; color: #94a3b8; line-height: 1; }
        .kv .v { font-size: 13px; color: #1e293b; font-weight: 600; margin-top: 2px; word-break: break-all; }
        .kv.full { grid-column: 1 / -1; }
        .footer-bar { padding: 8px 18px; font-size: 11px; color: #94a3b8; border-top: 1px solid #f1f5f9; background: #f8fafc; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:Repeater ID="Repeater1" runat="server">
    <ItemTemplate>
        <div class="modal-card">
            <div class="modal-header">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <h2>学生基本信息</h2>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="kv"><div class="k">姓名</div><div class="v"><%# Eval("Sname") %></div></div>
                    <div class="kv"><div class="k">学号</div><div class="v"><%# Eval("Snum") %></div></div>
                    <div class="kv"><div class="k">性别</div><div class="v"><%# Eval("Sex") %></div></div>
                    <div class="kv"><div class="k">年级</div><div class="v"><%# Eval("Sgrade") %></div></div>
                    <div class="kv"><div class="k">班级</div><div class="v"><%# Eval("Sclass") %></div></div>
                    <div class="kv"><div class="k">入学</div><div class="v"><%# Eval("Syear") %></div></div>
                    <div class="kv"><div class="k">班主任</div><div class="v"><%# Eval("Sheadtheacher") %></div></div>
                    <div class="kv"><div class="k">表现</div><div class="v"><%# Eval("Sattitude") %></div></div>
                    <div class="kv"><div class="k">成绩</div><div class="v"><%# Eval("Sscore") %></div></div>
                    <div class="kv"><div class="k">父母</div><div class="v"><%# Eval("Sparents") %></div></div>
                    <div class="kv"><div class="k">电话</div><div class="v"><%# Eval("Sphone") %></div></div>
                    <div class="kv"><div class="k">密码</div><div class="v">******</div></div>
                    <div class="kv full"><div class="k">地址</div><div class="v"><%# Eval("Saddress") %></div></div>
                </div>
            </div>
            <div class="footer-bar">提示：密码已隐藏；如需修改请在编辑页操作</div>
        </div>
    </ItemTemplate>
    </asp:Repeater>
</form>
</body>
</html>

