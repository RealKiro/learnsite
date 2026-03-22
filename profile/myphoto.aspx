<%@ page title="" language="C#" masterpagefile="~/profile/Pf.master" stylesheettheme="Student" autoeventwireup="true" inherits="Profile_myphoto, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" Runat="Server">
<style>
    .ph-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; max-width: 720px; animation: phFade .4s ease; }
    @keyframes phFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .ph-card-head { padding: 20px 28px; border-bottom: 1px solid #f1f5f9; display: flex !important; align-items: center; gap: 12px; }
    .ph-card-head .ph-icon { width: 38px; height: 38px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; background: linear-gradient(135deg, #e0e7ff, #c7d2fe); }
    .ph-icon svg { width: 18px; height: 18px; fill: none; stroke: #6366f1; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ph-card-head h3 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; }
    .ph-card-body { padding: 28px; }

    /* 头像预览 */
    .ph-preview-wrap { display: flex; flex-direction: column; align-items: center; margin-bottom: 24px; }
    .ph-preview-frame {
        position: relative; width: 140px; height: 140px; border-radius: 50% !important;
        background: linear-gradient(135deg, #6366f1, #a78bfa, #c084fc);
        padding: 4px; box-shadow: 0 4px 20px rgba(99,102,241,.2);
    }
    .ph-preview-frame-inner {
        width: 100%; height: 100%; border-radius: 50% !important; overflow: hidden;
        background: #f8fafc; display: flex !important; align-items: center; justify-content: center;
    }
    .ph-preview-frame-inner img {
        width: 132px !important; height: 132px !important; max-width: 132px !important; max-height: 132px !important;
        border-radius: 50% !important; object-fit: cover; border: none !important;
    }
    .ph-preview-label { margin-top: 12px; font-size: 13px; color: #94a3b8; }

    /* 上传区域 */
    .ph-upload-zone {
        padding: 20px; background: #fafbfe; border-radius: 14px; border: 2px dashed #d4d8f0;
        margin-bottom: 16px; transition: all .2s; text-align: center;
    }
    .ph-upload-zone:hover { border-color: #a5b4fc; background: #f5f6ff; }
    .ph-upload-icon { margin-bottom: 10px; color: #a5b4fc; }
    .ph-upload-icon svg { width: 32px; height: 32px; stroke: #a5b4fc; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .ph-upload-text { font-size: 13px; color: #64748b; margin-bottom: 12px; }
    .ph-upload-row { display: flex; align-items: center; justify-content: center; gap: 12px; flex-wrap: wrap; }
    .ph-upload-zone input[type="file"] { font-size: 13px !important; font-family: 'Microsoft YaHei',sans-serif !important; color: #64748b; }
    
    /* 上传按钮 - 正常状态 */
    input.ph-btn {
        display: inline-block !important;
        padding: 12px 36px !important; 
        border-radius: 50px !important; 
        border: none !important;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important; 
        color: #fff !important;
        font-size: 15px !important; 
        font-weight: 700 !important; 
        cursor: pointer !important;
        font-family: 'Microsoft YaHei',sans-serif !important; 
        letter-spacing: 2px !important;
        box-shadow: 0 6px 20px rgba(99,102,241,.3) !important; 
        transition: all .3s cubic-bezier(.4,0,.2,1) !important;
        height: auto !important; 
        width: auto !important; 
        min-width: 160px !important;
        background-image: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important; 
        line-height: 1.5 !important;
        text-indent: 0 !important; 
        overflow: visible !important;
        -webkit-appearance: none !important; 
        appearance: none !important;
        text-shadow: 0 1px 2px rgba(0,0,0,.15) !important;
    }
    input.ph-btn:hover { 
        transform: translateY(-3px) scale(1.02) !important; 
        box-shadow: 0 10px 30px rgba(99,102,241,.4) !important; 
        background: linear-gradient(135deg, #818cf8 0%, #a78bfa 100%) !important;
    }
    input.ph-btn:active { 
        transform: translateY(-1px) scale(1) !important; 
    }
    /* 上传按钮 - 禁用状态 */
    input.ph-btn[disabled],
    input.ph-btn:disabled {
        display: inline-block !important;
        padding: 12px 36px !important; 
        border-radius: 50px !important; 
        border: 2px dashed #d1d5db !important;
        background: #f3f4f6 !important; 
        background-image: none !important;
        color: #9ca3af !important;
        font-size: 15px !important; 
        font-weight: 600 !important; 
        cursor: not-allowed !important;
        font-family: 'Microsoft YaHei',sans-serif !important; 
        letter-spacing: 2px !important;
        box-shadow: none !important; 
        height: auto !important; 
        width: auto !important; 
        min-width: 160px !important;
        line-height: 1.5 !important;
        text-indent: 0 !important; 
        overflow: visible !important;
        -webkit-appearance: none !important; 
        appearance: none !important;
        text-shadow: none !important;
        opacity: 1 !important;
    }
    
    .ph-msg { padding: 12px 0; font-size: 13px; text-align: center; }

    /* 提示 */
    .ph-hint-box {
        display: flex; align-items: flex-start; gap: 10px; padding: 14px 16px;
        background: #fffbeb; border-radius: 10px; border: 1px solid #fde68a;
    }
    .ph-hint-icon { flex-shrink: 0; width: 18px; height: 18px; color: #f59e0b; margin-top: 1px; }
    .ph-hint-icon svg { width: 18px; height: 18px; fill: none; stroke: #f59e0b; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ph-hint-text { font-size: 12.5px; color: #92400e; line-height: 1.7; }
</style>

<div class="ph-card">
    <div class="ph-card-head">
        <span class="ph-icon"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg></span>
        <h3>修改相片</h3>
    </div>
    <div class="ph-card-body">
        <asp:Panel ID="Panel1" runat="server">
            <div class="ph-preview-wrap">
                <div class="ph-preview-frame">
                    <div class="ph-preview-frame-inner">
                        <asp:Image ID="Imageface" runat="server" style="border-width:0px;" />
                    </div>
                </div>
                <span class="ph-preview-label">当前头像</span>
            </div>
            <div class="ph-upload-zone">
                <div class="ph-upload-icon"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></div>
                <div class="ph-upload-text">选择一张图片作为你的头像</div>
                <div class="ph-upload-row">
                    <asp:FileUpload ID="PhotoFileUpload" runat="server" Font-Size="9pt" Width="240px" />
<asp:Button ID="Btnphoto" runat="server" Enabled="True" onclick="Btnphoto_Click" CssClass="ph-btn" Text="上传头像" />
                </div>
            </div>
            <div class="ph-msg"><asp:Label ID="Labelstr" runat="server" SkinID="LabelMsgRed"></asp:Label></div>
        </asp:Panel>
        <div class="ph-hint-box">
            <span class="ph-hint-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></span>
            <span class="ph-hint-text">支持 JPG、JPEG、PNG 格式，大小不超过 2MB，过大会自动缩小为宽度 320px。</span>
        </div>
    </div>
</div>
</asp:Content>

