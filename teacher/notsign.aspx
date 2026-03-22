<%@ page title="" language="C#" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_notsign, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<title></title>
<style type="text/css">
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
    background: transparent;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}
.modal {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 24px 64px rgba(0,0,0,0.13), 0 4px 16px rgba(0,0,0,0.06);
    width: 500px;
    overflow: hidden;
    animation: modalIn 0.32s cubic-bezier(0.21,1.02,0.73,1) both;
}
@keyframes modalIn {
    from { opacity: 0; transform: scale(0.9) translateY(16px); }
    to   { opacity: 1; transform: scale(1) translateY(0); }
}
/* ---- header ---- */
.modal-head {
    background: linear-gradient(135deg, #f97316 0%, #fb923c 60%, #fbbf24 100%);
    padding: 20px 22px 18px;
    display: flex;
    align-items: center;
    gap: 14px;
    position: relative;
    overflow: hidden;
}
.modal-head::before {
    content: '';
    position: absolute;
    top: -40%;
    right: -10%;
    width: 180px;
    height: 180px;
    border-radius: 50%;
    background: rgba(255,255,255,0.1);
    pointer-events: none;
}
.mh-icon {
    width: 46px;
    height: 46px;
    background: rgba(255,255,255,0.22);
    border: 2px solid rgba(255,255,255,0.35);
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    position: relative;
    z-index: 1;
}
.mh-icon svg {
    width: 24px; height: 24px;
    stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}
.mh-text { flex: 1; position: relative; z-index: 1; }
.mh-text .title {
    font-size: 17px; font-weight: 700; color: #fff;
    line-height: 1.25; display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
}
.mh-text .title .sname {
    background: rgba(255,255,255,0.25);
    border-radius: 20px;
    padding: 1px 10px;
    font-size: 16px;
}
.mh-text .sub {
    font-size: 12px;
    color: rgba(255,255,255,0.82);
    margin-top: 4px;
    display: flex;
    align-items: center;
    gap: 5px;
}
.mh-text .sub svg {
    width: 12px; height: 12px;
    stroke: rgba(255,255,255,0.8); fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}
/* ---- body ---- */
.modal-body { padding: 22px 22px 0; }
.field-row {
    display: flex; align-items: center; gap: 7px;
    font-size: 13px; font-weight: 600; color: #374151;
    margin-bottom: 10px;
}
.field-row svg {
    width: 15px; height: 15px;
    stroke: #9ca3af; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}
.ns-textarea {
    width: 100% !important;
    height: 132px !important;
    padding: 12px 14px !important;
    border: 2px solid #e5e7eb !important;
    border-radius: 12px !important;
    font-size: 13px !important;
    font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif !important;
    color: #374151 !important;
    background: #fafafa !important;
    resize: none !important;
    transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
    outline: none !important;
    display: block !important;
    line-height: 1.6 !important;
}
.ns-textarea:focus {
    border-color: #f97316 !important;
    background: #fff !important;
    box-shadow: 0 0 0 3px rgba(249,115,22,0.12) !important;
}
.msg-row {
    min-height: 22px;
    font-size: 12px;
    color: #10b981;
    font-weight: 500;
    margin-top: 8px;
    display: flex;
    align-items: center;
    gap: 5px;
}
/* ---- footer ---- */
.modal-footer {
    padding: 16px 22px 22px;
    display: flex;
    gap: 10px;
}
.ns-btn {
    flex: 1;
    height: 44px;
    border: none;
    border-radius: 12px;
    background: linear-gradient(135deg, #f97316 0%, #fb923c 100%);
    color: #fff;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
    box-shadow: 0 4px 14px rgba(249,115,22,0.35);
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    letter-spacing: 0.5px;
}
.ns-btn:hover {
    box-shadow: 0 6px 22px rgba(249,115,22,0.45);
    transform: translateY(-1px);
}
.ns-btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 8px rgba(249,115,22,0.3);
}
</style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="modal">
        <!-- Header -->
        <div class="modal-head">
            <div class="mh-icon">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
            </div>
            <div class="mh-text">
                <div class="title">
                    对&nbsp;<span class="sname"><asp:Label ID="Labelname" runat="server" Font-Bold="True" ForeColor="White"></asp:Label></span>&nbsp;同学
                </div>
                <div class="sub">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    缺席备注记录
                </div>
            </div>
        </div>
        <!-- Body -->
        <div class="modal-body">
            <div class="field-row">
                <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                缺席原因
            </div>
            <asp:TextBox ID="TextBox1" runat="server" Width="100%" Height="132px"
                TextMode="MultiLine" CssClass="ns-textarea"
                EnableTheming="False"></asp:TextBox>
            <div class="msg-row"><asp:Label ID="Labelmsg" runat="server"></asp:Label></div>
        </div>
        <!-- Footer -->
        <div class="modal-footer">
            <asp:Button ID="Btnnotsign" runat="server" Text="确认添加备注"
                CssClass="ns-btn" EnableTheming="False"
                onclick="Btnnotsign_Click" />
        </div>
    </div>
    </form>
</body>
</html>

