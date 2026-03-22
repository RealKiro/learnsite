<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_myclass, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
    /* ===== myclass 班级修改 ===== */
    .cl-wrap { max-width: 720px; animation: cl-fadeIn .4s ease; }
    @keyframes cl-fadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

    .cl-card { background: #fff; border-radius: 20px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 8px 24px rgba(0,0,0,.04); overflow: hidden; }

    /* 顶部渐变横幅 */
    .cl-banner { background: linear-gradient(135deg, #3b82f6, #2563eb, #1d4ed8); padding: 28px 28px 24px; position: relative; overflow: hidden; }
    .cl-banner::before { content: ''; position: absolute; top: -30px; right: -30px; width: 120px; height: 120px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .cl-banner::after { content: ''; position: absolute; bottom: -40px; left: 20px; width: 80px; height: 80px; border-radius: 50%; background: rgba(255,255,255,.06); }
    .cl-banner-inner { display: flex; align-items: center; gap: 14px; position: relative; z-index: 1; }
    .cl-banner-icon { width: 44px; height: 44px; background: rgba(255,255,255,.2); border-radius: 12px; display: flex !important; align-items: center; justify-content: center; backdrop-filter: blur(4px); flex-shrink: 0; }
    .cl-banner-icon svg { width: 22px; height: 22px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cl-banner h3 { margin: 0; font-size: 17px; font-weight: 700; color: #fff; letter-spacing: .5px; }
    .cl-banner p { margin: 4px 0 0; font-size: 12px; color: rgba(255,255,255,.8); }

    /* 内容区 */
    .cl-body { padding: 28px; }

    /* 当前班级展示 */
    .cl-current { display: flex; align-items: center; gap: 14px; padding: 16px 18px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 14px; margin-bottom: 22px; }
    .cl-current-icon { width: 38px; height: 38px; background: linear-gradient(135deg, #3b82f6, #2563eb); border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .cl-current-icon svg { width: 18px; height: 18px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cl-current-info { flex: 1; }
    .cl-current-label { font-size: 11px; color: #6b7280; font-weight: 500; text-transform: uppercase; letter-spacing: .5px; }
    .cl-current-value { font-size: 18px; font-weight: 700; color: #1e40af; margin-top: 2px; }
    .cl-current-value span { font-size: 18px !important; font-weight: 700 !important; color: #1e40af !important; }

    /* 选择区域 */
    .cl-select-area { margin-bottom: 22px; }
    .cl-select-label { display: flex; align-items: center; gap: 6px; margin-bottom: 10px; font-size: 13px; font-weight: 600; color: #374151; }
    .cl-select-label svg { width: 15px; height: 15px; fill: none; stroke: #9ca3af; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cl-select-area select {
        padding: 11px 36px 11px 16px !important; border: 1.5px solid #e5e7eb !important;
        border-radius: 12px !important; font-size: 14px !important; font-weight: 500 !important;
        font-family: 'Microsoft YaHei',sans-serif !important; background: #f9fafb !important;
        width: 120px !important; cursor: pointer !important; transition: all .2s ease !important;
        appearance: auto !important; color: #1e293b !important;
    }
    .cl-select-area select:focus { border-color: #3b82f6 !important; outline: none !important; box-shadow: 0 0 0 3px rgba(59,130,246,.12) !important; background: #fff !important; }

    /* 分隔线 */
    .cl-divider { height: 1px; background: #f1f5f9; margin-bottom: 22px; }

    /* 提交按钮 */
    .cl-action { text-align: center; padding-top: 4px; }
    input.cl-btn {
        display: inline-block !important;
        padding: 14px 52px !important; 
        border-radius: 50px !important; 
        border: none !important;
        background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%) !important; 
        color: #fff !important;
        font-size: 16px !important; 
        font-weight: 700 !important; 
        cursor: pointer !important;
        font-family: 'Microsoft YaHei',sans-serif !important; 
        letter-spacing: 2px !important;
        box-shadow: 0 6px 20px rgba(37,99,235,.3) !important; 
        transition: all .3s cubic-bezier(.4,0,.2,1) !important;
        height: auto !important; 
        width: auto !important; 
        min-width: 200px !important;
        background-image: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%) !important; 
        line-height: 1.5 !important;
        text-indent: 0 !important; 
        overflow: visible !important;
        -webkit-appearance: none !important; 
        appearance: none !important;
        text-shadow: 0 1px 2px rgba(0,0,0,.15) !important;
    }
    input.cl-btn:hover { 
        transform: translateY(-3px) scale(1.02) !important; 
        box-shadow: 0 10px 30px rgba(37,99,235,.4) !important; 
        background: linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%) !important;
    }
    input.cl-btn:active { 
        transform: translateY(-1px) scale(1) !important; 
    }
    /* 禁用状态按钮 */
    input.cl-btn[disabled],
    input.cl-btn:disabled {
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

    .cl-msg { text-align: center; padding-top: 14px; font-size: 13px; }
    .cl-msg span { padding: 6px 16px; border-radius: 8px; }
</style>

<div class="cl-wrap">
<div class="cl-card">
    <div class="cl-banner">
        <div class="cl-banner-inner">
            <span class="cl-banner-icon"><svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></span>
            <div><h3>班级修改</h3><p>选择新的班级完成调整</p></div>
        </div>
    </div>
    <div class="cl-body">
        <div class="cl-current">
            <span class="cl-current-icon"><svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></span>
            <div class="cl-current-info">
                <div class="cl-current-label">当前班级</div>
                <div class="cl-current-value"><asp:Label ID="Labelclass" runat="server"></asp:Label></div>
            </div>
        </div>
        <div class="cl-select-area">
            <div class="cl-select-label">
                <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><polyline points="17 11 19 13 23 9"/></svg>
                选择新班级
            </div>
            <asp:DropDownList ID="DDLclass" runat="server" Font-Size="9pt" Width="50px"></asp:DropDownList>
        </div>
        <div class="cl-divider"></div>
        <div class="cl-action">
            <asp:Button ID="Btnclass" runat="server" OnClick="Btnclass_Click" Text="确认修改" TabIndex="2" CssClass="cl-btn" Enabled="False" />
        </div>
        <div class="cl-msg"><asp:Label ID="Labelstr" runat="server" SkinID="LabelMsgRed"></asp:Label></div>
    </div>
</div>
</div>
</asp:Content>

