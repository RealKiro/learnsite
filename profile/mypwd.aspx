<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mypwd, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
    /* ===== mypwd 密码修改 ===== */
    .pw-wrap { max-width: 720px; animation: pw-fadeIn .4s ease; }
    @keyframes pw-fadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

    .pw-card { background: #fff; border-radius: 20px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 8px 24px rgba(0,0,0,.04); overflow: hidden; }

    /* 顶部渐变横幅 */
    .pw-banner { background: linear-gradient(135deg, #f59e0b, #d97706, #b45309); padding: 28px 28px 24px; position: relative; overflow: hidden; }
    .pw-banner::before { content: ''; position: absolute; top: -30px; right: -30px; width: 120px; height: 120px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .pw-banner::after { content: ''; position: absolute; bottom: -40px; left: 20px; width: 80px; height: 80px; border-radius: 50%; background: rgba(255,255,255,.06); }
    .pw-banner-inner { display: flex; align-items: center; gap: 14px; position: relative; z-index: 1; }
    .pw-banner-icon { width: 44px; height: 44px; background: rgba(255,255,255,.2); border-radius: 12px; display: flex !important; align-items: center; justify-content: center; backdrop-filter: blur(4px); flex-shrink: 0; }
    .pw-banner-icon svg { width: 22px; height: 22px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pw-banner h3 { margin: 0; font-size: 17px; font-weight: 700; color: #fff; letter-spacing: .5px; }
    .pw-banner p { margin: 4px 0 0; font-size: 12px; color: rgba(255,255,255,.8); }

    /* 表单区 */
    .pw-body { padding: 28px; }
    .pw-field { margin-bottom: 20px; }
    .pw-field-label { display: flex; align-items: center; gap: 6px; margin-bottom: 8px; font-size: 13px; font-weight: 600; color: #374151; }
    .pw-field-label svg { width: 15px; height: 15px; fill: none; stroke: #9ca3af; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pw-field-input { position: relative; }
    .pw-field-input input[type="password"],
    .pw-field-input input[type="text"] {
        width: 100% !important; padding: 11px 16px !important; border: 1.5px solid #e5e7eb !important;
        border-radius: 12px !important; font-size: 14px !important; font-family: 'Microsoft YaHei',sans-serif !important;
        background: #f9fafb !important; transition: all .2s ease !important; box-sizing: border-box !important;
    }
    .pw-field-input input:focus {
        border-color: #f59e0b !important; outline: none !important;
        box-shadow: 0 0 0 3px rgba(245,158,11,.12) !important; background: #fff !important;
    }

    /* 安全提示 */
    .pw-tip { display: flex; align-items: flex-start; gap: 8px; padding: 12px 14px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; margin-bottom: 22px; }
    .pw-tip svg { width: 16px; height: 16px; fill: none; stroke: #d97706; stroke-width: 2; flex-shrink: 0; margin-top: 1px; }
    .pw-tip span { font-size: 12px; color: #92400e; line-height: 1.5; }

    /* 提交按钮 */
    .pw-action { text-align: center; padding-top: 4px; }
    input.pw-btn {
        display: inline-block !important;
        padding: 14px 52px !important; 
        border-radius: 50px !important; 
        border: none !important;
        background: linear-gradient(135deg, #f59e0b 0%, #ea580c 100%) !important; 
        color: #fff !important;
        font-size: 16px !important; 
        font-weight: 700 !important; 
        cursor: pointer !important;
        font-family: 'Microsoft YaHei',sans-serif !important; 
        letter-spacing: 2px !important;
        box-shadow: 0 6px 20px rgba(234,88,12,.3) !important; 
        transition: all .3s cubic-bezier(.4,0,.2,1) !important;
        height: auto !important; 
        width: auto !important; 
        min-width: 200px !important;
        background-image: linear-gradient(135deg, #f59e0b 0%, #ea580c 100%) !important; 
        line-height: 1.5 !important;
        text-indent: 0 !important; 
        overflow: visible !important;
        -webkit-appearance: none !important; 
        appearance: none !important;
        text-shadow: 0 1px 2px rgba(0,0,0,.15) !important;
        position: relative !important;
    }
    input.pw-btn:hover { 
        transform: translateY(-3px) scale(1.02) !important; 
        box-shadow: 0 10px 30px rgba(234,88,12,.4) !important; 
        background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%) !important;
    }
    input.pw-btn:active { 
        transform: translateY(-1px) scale(1) !important; 
    }
    /* 禁用状态按钮 */
    input.pw-btn[disabled],
    input.pw-btn:disabled {
        display: inline-block !important;
        padding: 14px 52px !important; 
        border-radius: 50px !important; 
        border: 2px dashed #d1d5db !important;
        background: #f3f4f6 !important; 
        background-image: none !important;
        color: #9ca3af !important;
        font-size: 16px !important; 
        font-weight: 600 !important; 
        cursor: not-allowed !important;
        font-family: 'Microsoft YaHei',sans-serif !important; 
        letter-spacing: 2px !important;
        box-shadow: none !important; 
        height: auto !important; 
        width: auto !important; 
        min-width: 200px !important;
        line-height: 1.5 !important;
        text-indent: 0 !important; 
        overflow: visible !important;
        -webkit-appearance: none !important; 
        appearance: none !important;
        text-shadow: none !important;
        opacity: 1 !important;
    }

    .pw-msg { text-align: center; padding-top: 14px; font-size: 13px; }
    .pw-msg span { padding: 6px 16px; border-radius: 8px; }
</style>

<div class="pw-wrap">
<div class="pw-card">
    <div class="pw-banner">
        <div class="pw-banner-inner">
            <span class="pw-banner-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/><circle cx="12" cy="16" r="1"/></svg></span>
            <div><h3>密码修改</h3><p>定期更换密码，保护账号安全</p></div>
        </div>
    </div>
    <div class="pw-body">
        <div class="pw-field">
            <div class="pw-field-label">
                <svg viewBox="0 0 24 24"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                旧密码
            </div>
            <div class="pw-field-input">
                <asp:TextBox ID="TextBoxoldpwd" runat="server" TextMode="Password" TabIndex="1" SkinID="TextBox" ToolTip="旧密码确认框"></asp:TextBox>
            </div>
        </div>
        <div class="pw-field">
            <div class="pw-field-label">
                <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                新密码
            </div>
            <div class="pw-field-input">
                <asp:TextBox ID="TextBoxpwd" runat="server" TextMode="Password" TabIndex="1" SkinID="TextBox" ToolTip="新密码"></asp:TextBox>
            </div>
        </div>
        <div class="pw-field">
            <div class="pw-field-label">
                <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                确认新密码
            </div>
            <div class="pw-field-input">
                <asp:TextBox ID="TextBoxpwd0" runat="server" TextMode="Password" TabIndex="1" SkinID="TextBox" ToolTip="新密码"></asp:TextBox>
            </div>
        </div>
        <div class="pw-tip">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            <span>密码长度建议6位以上，包含字母和数字组合更安全</span>
        </div>
        <div class="pw-action">
            <asp:Button ID="Btnedit" runat="server" OnClick="Btnedit_Click" Text="确认修改" TabIndex="2" CssClass="pw-btn" Enabled="False" />
        </div>
        <div class="pw-msg"><asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label></div>
    </div>
</div>
</div>
</asp:Content>

