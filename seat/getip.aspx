<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //（温州水乡 Learnsite学习平台机房布置专用）
            myip.InnerText = Page.Request.UserHostAddress;//取客户机IP
            myhostname.InnerText = System.Net.Dns.GetHostName();//取客户机主机名
            mytime.InnerText = DateTime.Now.ToLongTimeString().ToString();
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .getip-page{max-width:720px;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .getip-hd{display:flex;align-items:center;gap:16px;margin-bottom:28px;}
    .getip-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .getip-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .getip-hd h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .getip-hd p{font-size:13px;color:#94a3b8;margin:0;}
    .getip-grid{display:flex;flex-direction:column;gap:20px;}
    /* Card */
    .getip-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);padding:24px 28px;overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .getip-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .getip-card-label{display:flex;align-items:center;gap:10px;margin-bottom:14px;}
    .getip-card-label .ci{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .getip-card-label .ci svg{width:20px;height:20px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.blue{background:#f0f9ff;}.ci.blue svg{stroke:#0ea5e9;}
    .ci.purple{background:#eef2ff;}.ci.purple svg{stroke:#6366f1;}
    .ci.amber{background:#fffbeb;}.ci.amber svg{stroke:#f59e0b;}
    .getip-card-label .label-text{font-size:12px;font-weight:600;color:#94a3b8;text-transform:uppercase;letter-spacing:.5px;}
    /* Value */
    .getip-val{font-family:'Cascadia Code','Fira Code','Consolas',monospace;font-weight:700;text-align:center;word-break:break-all;line-height:1.2;}
    .getip-val.hostname{font-size:30px;color:#6366f1;}
    .getip-val.ip{font-size:48px;background:linear-gradient(135deg,#0ea5e9,#6366f1);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
    .getip-val.time{font-size:36px;color:#f59e0b;}
    /* Footer */
    .getip-footer{text-align:center;font-size:12px;color:#cbd5e1;padding-top:4px;}
    @media(max-width:480px){
        .getip-val.ip{font-size:32px;}.getip-val.hostname{font-size:22px;}.getip-val.time{font-size:26px;}.getip-card{padding:18px;}
    }
</style>

<div class="getip-page">
    <div class="getip-hd">
        <div class="getip-hd-icon"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
        <div><h1>本机信息</h1><p>LearnSite 机房布置 · 客户端信息</p></div>
    </div>
    <div class="getip-grid">
        <!-- Hostname -->
        <div class="getip-card">
            <div class="getip-card-label">
                <span class="ci purple"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></span>
                <span class="label-text">主机名 Hostname</span>
            </div>
            <div id="myhostname" class="getip-val hostname" runat="server" title="本机主机名"></div>
        </div>
        <!-- IP -->
        <div class="getip-card">
            <div class="getip-card-label">
                <span class="ci blue"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2z"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg></span>
                <span class="label-text">IP 地址</span>
            </div>
            <div id="myip" class="getip-val ip" runat="server" title="本机IP"></div>
        </div>
        <!-- Time -->
        <div class="getip-card">
            <div class="getip-card-label">
                <span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
                <span class="label-text">当前时间</span>
            </div>
            <div id="mytime" class="getip-val time" runat="server" title="本机时间"></div>
        </div>
    </div>
    <div class="getip-footer">LearnSite 信息学习平台</div>
</div>
</asp:Content>
