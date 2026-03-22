<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_mysex, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
    .sx-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; max-width: 720px; }
    .sx-card-head { padding: 20px 28px; border-bottom: 1px solid #f1f5f9; display: flex !important; align-items: center; gap: 12px; }
    .sx-card-head .sx-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; background: linear-gradient(135deg, #fce7f3, #fbcfe8); }
    .sx-icon svg { width: 18px; height: 18px; fill: none; stroke: #db2777; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sx-card-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .sx-card-body { padding: 28px; }
    .sx-row { display: flex; align-items: center; margin-bottom: 22px; gap: 14px; font-size: 14px; color: #334155; }
    .sx-label { width: 80px; color: #64748b; font-weight: 500; flex-shrink: 0; }
    .sx-row select { padding: 10px 16px !important; border: 1.5px solid #e2e8f0 !important; border-radius: 12px !important; font-size: 14px !important; font-family: 'Microsoft YaHei',sans-serif !important; background: #f9fafb !important; width: 100px !important; }
    .sx-row select:focus { border-color: #ec4899 !important; outline: none !important; box-shadow: 0 0 0 3px rgba(236,72,153,.12) !important; }
    .sx-submit { text-align: center; padding-top: 6px; }

    /* 确认修改按钮 */
    input.sx-btn {
        display: inline-block !important;
        padding: 14px 52px !important;
        border-radius: 50px !important;
        border: none !important;
        background: linear-gradient(135deg, #ec4899 0%, #db2777 100%) !important;
        color: #fff !important;
        font-size: 16px !important;
        font-weight: 700 !important;
        cursor: pointer !important;
        font-family: 'Microsoft YaHei',sans-serif !important;
        letter-spacing: 2px !important;
        box-shadow: 0 6px 20px rgba(219,39,119,.3) !important;
        transition: all .3s cubic-bezier(.4,0,.2,1) !important;
        height: auto !important;
        width: auto !important;
        min-width: 200px !important;
        background-image: linear-gradient(135deg, #ec4899 0%, #db2777 100%) !important;
        line-height: 1.5 !important;
        text-indent: 0 !important;
        overflow: visible !important;
        -webkit-appearance: none !important;
        appearance: none !important;
        text-shadow: 0 1px 2px rgba(0,0,0,.15) !important;
    }
    input.sx-btn:hover {
        transform: translateY(-3px) scale(1.02) !important;
        box-shadow: 0 10px 30px rgba(219,39,119,.4) !important;
        background: linear-gradient(135deg, #f472b6 0%, #ec4899 100%) !important;
    }
    input.sx-btn:active {
        transform: translateY(-1px) scale(1) !important;
    }
    /* 禁用状态 */
    input.sx-btn[disabled],
    input.sx-btn:disabled {
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

    .sx-msg { padding: 14px 0 0; font-size: 13px; text-align: center; }
</style>

<div class="sx-card">
    <div class="sx-card-head">
        <span class="sx-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
        <h3>性别修改</h3>
    </div>
    <div class="sx-card-body">
        <div class="sx-row">
            <span class="sx-label">选择性别</span>
            <asp:DropDownList ID="DDLsex" runat="server" Font-Size="9pt" Width="60px" BackColor="Cornsilk"></asp:DropDownList>
        </div>
        <div class="sx-submit">
            <asp:Button ID="Btnsex" runat="server" OnClick="Btnsex_Click" Text="确认修改" TabIndex="2" CssClass="sx-btn" />
        </div>
        <div class="sx-msg"><asp:Label ID="Labelstr" runat="server" SkinID="LabelMsgRed"></asp:Label></div>
    </div>
</div>
</asp:Content>

