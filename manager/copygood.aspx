<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Manager_copygood, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .cg-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .cg-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .cg-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#8b5cf6,#a78bfa);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(139,92,246,.25);flex-shrink:0;}
    .cg-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .cg-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .cg-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .cg-card{max-width:600px;background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;}
    .cg-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .cg-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:#f5f3ff;}
    .cg-card-hd .ci svg{width:19px;height:19px;stroke:#8b5cf6;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .cg-card-bd{padding:22px;}
    .cg-info{background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:16px 18px;font-size:13px;color:#334155;line-height:1.8;margin-bottom:20px;}
    .cg-info strong{color:#1e293b;}
    .btn-purple{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 28px;background:linear-gradient(135deg,#8b5cf6,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:14px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(139,92,246,.3);}
    .btn-purple:hover{box-shadow:0 4px 16px rgba(139,92,246,.4);transform:translateY(-1px);}
    .cg-msg{margin-top:16px;font-size:13px;color:#10b981;}
</style>

<div class="cg-page">
    <div class="cg-hd">
        <div class="cg-hd-icon"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
        <div class="cg-hd-text"><h1>优秀作品备份</h1><p>将所有推荐的优秀作品备份保存</p></div>
    </div>

    <div class="cg-card">
        <div class="cg-card-hd">
            <span class="ci"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg></span>
            备份操作
        </div>
        <div class="cg-card-bd">
            <div class="cg-info">
                <strong>操作说明：</strong><br/>
                • 将所有 <strong>12 分的推荐作品</strong>复制到网站 GoodStore 目录下<br/>
                • 按入学年度、学案分级保存，方便提取独立展示
            </div>
            <asp:Button ID="Btnbackup" runat="server" Text="备份优秀作品" CssClass="btn-purple" onclick="Btnbackup_Click" />
            <div class="cg-msg">
                <asp:Label ID="Labelmsg" runat="server"></asp:Label>
            </div>
        </div>
    </div>
</div>
</asp:Content>

