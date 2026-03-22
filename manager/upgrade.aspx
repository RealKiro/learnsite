<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_upgrade, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ug-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .ug-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .ug-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#f59e0b,#fbbf24);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(245,158,11,.25);flex-shrink:0;}
    .ug-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .ug-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .ug-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .ug-grid{display:flex;flex-direction:column;gap:24px;}
    .ug-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .ug-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .ug-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .ug-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .ug-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .ci.rose{background:#fff1f2;} .ci.rose svg{stroke:#f43f5e;}
    .ug-card-bd{padding:22px;}
    .ug-notice{list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:14px;}
    .ug-notice li{display:flex;align-items:flex-start;gap:10px;font-size:13px;color:#334155;line-height:1.7;}
    .ug-notice li .ni{width:24px;height:24px;border-radius:7px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:11px;font-weight:700;}
    .ni.warn{background:#fef3c7;color:#b45309;}
    .ni.info{background:#e0f2fe;color:#0369a1;}
    .ni.err{background:#fee2e2;color:#dc2626;}
    .ug-highlight{margin-top:16px;background:#fefce8;border:1px solid #fde68a;border-radius:10px;padding:12px 16px;font-size:13px;font-weight:600;color:#92400e;text-align:center;}
    .ug-action-row{display:flex;align-items:center;gap:20px;flex-wrap:wrap;}
    .ug-year{display:inline-flex;align-items:center;gap:8px;padding:8px 16px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;font-size:14px;color:#1e293b;font-weight:600;}
    .ug-year span{color:#94a3b8;font-weight:400;font-size:13px;}
    .btn-warning{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 28px;background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff!important;border:none;border-radius:9px;font-size:14px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(245,158,11,.3);}
    .btn-warning:hover{box-shadow:0 4px 16px rgba(245,158,11,.4);transform:translateY(-1px);}
    .ug-msg{margin-top:14px;font-size:13px;}
    #Loading{text-align:center;font-size:13px;color:#ef4444;padding:10px 0;}
</style>

<div class="ug-page">
    <div class="ug-hd">
        <div class="ug-hd-icon"><svg viewBox="0 0 24 24"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg></div>
        <div class="ug-hd-text"><h1>学年升班</h1><p>新学年开始时，将全校学生年级统一升一级</p></div>
    </div>

    <div class="ug-grid">

    <!-- 执行操作（置顶） -->
    <div class="ug-card">
        <div class="ug-card-hd">
            <span class="ci rose"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
            执行升班
        </div>
        <div class="ug-card-bd">
            <div class="ug-action-row">
                <div class="ug-year">
                    <span>当前学年：</span>
                    <asp:TextBox ID="Textthisyear" runat="server" BorderStyle="None" Width="120px" ReadOnly="True" Font-Size="14px" Font-Bold="True" style="background:transparent;"></asp:TextBox>
                </div>
                <asp:Button ID="Btnupgrade" runat="server" Text="学年升班" CssClass="btn-warning" onclick="Btnupgrade_Click" />
            </div>
            <div id="Loading" style="display:none;">
                <asp:Image ID="Image2" runat="server" ImageUrl="~/images/load2.gif" />
                <input id="Textcmd" style="border-style:none" type="text" />
            </div>
            <div class="ug-msg">
                <asp:Label ID="Labelmsg" runat="server" ForeColor="Red"></asp:Label>
            </div>
        </div>
    </div>

    <!-- 注意事项 -->
    <div class="ug-card">
        <div class="ug-card-hd">
            <span class="ci amber"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
            注意事项
        </div>
        <div class="ug-card-bd">
            <ul class="ug-notice">
                <li><span class="ni warn">！</span>班级设置中的班级列表必须为<strong>全校完整班级列表</strong>，以防缺班而误删升上来的班级</li>
                <li><span class="ni info">→</span><strong>升班效果：</strong>学生表所有年级均升一年，然后删除班级表中不存在班级的学生。若班级未设置，升班按钮将失效</li>
                <li><span class="ni err">✗</span><strong>意外处理：</strong>操作前请先在「数据备份」菜单中备份数据库。若高年级班级数缺少，可在班级列表中手动添加，不影响数据</li>
            </ul>
            <div class="ug-highlight">⚠ 请学年升班后再进行新生导入！</div>
        </div>
    </div>

    </div>
</div>
</asp:Content>

