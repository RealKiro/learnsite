<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    private string imgDir;
    private string imgVirtualDir = "~/images/";
    private string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg" };

    protected void Page_Load(object sender, EventArgs e)
    {
        imgDir = Server.MapPath(imgVirtualDir);
        if (!IsPostBack)
        {
            ShowCurrentImage();
        }
    }

    private string GetLoginImageUrl()
    {
        foreach (string ext in exts)
        {
            string path = Path.Combine(imgDir, "loginbg" + ext);
            if (File.Exists(path))
                return ResolveUrl(imgVirtualDir + "loginbg" + ext) + "?v=" + File.GetLastWriteTime(path).Ticks;
        }
        return "";
    }

    private void ShowCurrentImage()
    {
        string url = GetLoginImageUrl();
        if (!string.IsNullOrEmpty(url))
        {
            ImgPreview.ImageUrl = url;
            ImgPreview.Visible = true;
            LabelStatus.Text = "<span style='color:#10b981'>&#10004; 当前已设置自定义登录插画</span>";
            BtnDelete.Visible = true;
        }
        else
        {
            ImgPreview.Visible = false;
            LabelStatus.Text = "<span style='color:#94a3b8'>未设置自定义图片，登录页将显示默认 SVG 插画</span>";
            BtnDelete.Visible = false;
        }
    }

    protected void BtnUpload_Click(object sender, EventArgs e)
    {
        if (!FileUpload1.HasFile)
        {
            LabelMsg.Text = "<span style='color:#ef4444'>请选择一张图片文件</span>";
            return;
        }

        string ext = Path.GetExtension(FileUpload1.FileName).ToLower();
        bool valid = false;
        foreach (string e2 in exts) { if (ext == e2) { valid = true; break; } }

        if (!valid)
        {
            LabelMsg.Text = "<span style='color:#ef4444'>仅支持 png/jpg/jpeg/gif/webp/svg 格式</span>";
            return;
        }

        foreach (string e3 in exts)
        {
            string oldPath = Path.Combine(imgDir, "loginbg" + e3);
            if (File.Exists(oldPath)) { try { File.Delete(oldPath); } catch { } }
        }

        string savePath = Path.Combine(imgDir, "loginbg" + ext);
        FileUpload1.SaveAs(savePath);

        LabelMsg.Text = "<span style='color:#10b981'>&#10004; 上传成功！</span>";
        ShowCurrentImage();
    }

    protected void BtnDelete_Click(object sender, EventArgs e)
    {
        foreach (string e2 in exts)
        {
            string oldPath = Path.Combine(imgDir, "loginbg" + e2);
            if (File.Exists(oldPath)) { try { File.Delete(oldPath); } catch { } }
        }
        LabelMsg.Text = "<span style='color:#eab308'>已删除自定义图片，将恢复默认 SVG 插画</span>";
        ShowCurrentImage();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .li-card {
        background: #fff;
        border-radius: 14px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 1px 4px rgba(0,0,0,.04);
        overflow: hidden;
        margin-bottom: 20px;
        max-width: 100%;
    }
    .li-card-hd {
        padding: 16px 22px;
        font-size: 15px; font-weight: 600; color: #1e293b;
        border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; gap: 8px;
    }
    .li-card-bd { padding: 24px; }

    .li-page-hd {
        display: flex; align-items: center; gap: 16px;
        margin-bottom: 24px; max-width: 100%;
    }
    .li-page-icon {
        width: 48px; height: 48px;
        background: linear-gradient(135deg, #6366f1, #a78bfa);
        border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 4px 12px rgba(99,102,241,.25);
        flex-shrink: 0;
    }
    .li-page-icon svg {
        width: 26px; height: 26px;
        stroke: #fff; fill: none;
        stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
    }
    .li-page-hd h2 { font-size: 20px; font-weight: 700; color: #0f172a; margin: 0; }
    .li-page-hd p { font-size: 13px; color: #94a3b8; margin: 2px 0 0; }

    .li-preview {
        text-align: center;
        padding: 24px;
        background: linear-gradient(135deg, #e0e7ff 0%, #dbeafe 25%, #e8d5f5 50%, #fce7f3 75%, #fef3c7 100%);
        border-radius: 12px;
        margin-bottom: 16px;
        min-height: 160px;
        display: flex; align-items: center; justify-content: center;
    }
    .li-preview img {
        max-width: 100%; max-height: 360px;
        border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,.1);
    }
    .li-status { font-size: 13px; margin-bottom: 16px; text-align: center; }

    .li-upload-row {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
    }
    .li-btn-primary {
        display: inline-flex; align-items: center; justify-content: center;
        height: 42px; padding: 0 28px;
        background: linear-gradient(135deg, #6366f1, #7c3aed);
        color: #fff !important; border: none; border-radius: 10px;
        font-size: 14px; font-family: inherit; font-weight: 600;
        cursor: pointer; transition: all .2s;
        box-shadow: 0 2px 8px rgba(99,102,241,.3);
    }
    .li-btn-primary:hover {
        box-shadow: 0 4px 16px rgba(99,102,241,.4);
        transform: translateY(-1px);
    }
    .li-btn-danger {
        display: inline-flex; align-items: center; justify-content: center;
        height: 42px; padding: 0 28px;
        background: #fff; color: #ef4444;
        border: 1.5px solid #fecaca; border-radius: 10px;
        font-size: 14px; font-family: inherit; font-weight: 600;
        cursor: pointer; transition: all .2s;
    }
    .li-btn-danger:hover { background: #fef2f2; border-color: #f87171; }
    .li-msg { font-size: 13px; margin-top: 14px; text-align: center; }
    .li-tips {
        font-size: 12px; color: #94a3b8; line-height: 1.8; margin-top: 14px;
    }
</style>

<div class="li-page-hd">
    <div class="li-page-icon">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
    </div>
    <div>
        <h2>登录页插画管理</h2>
        <p>上传自定义图片替换教师登录页左侧的默认插画</p>
    </div>
</div>

<div class="li-card">
    <div class="li-card-hd">&#128247; 当前插画预览</div>
    <div class="li-card-bd">
        <div class="li-preview">
            <asp:Image ID="ImgPreview" runat="server" Visible="false" />
        </div>
        <div class="li-status">
            <asp:Label ID="LabelStatus" runat="server"></asp:Label>
        </div>
    </div>
</div>

<div class="li-card">
    <div class="li-card-hd">&#128228; 上传新图片</div>
    <div class="li-card-bd">
        <div class="li-upload-row">
            <asp:FileUpload ID="FileUpload1" runat="server" />
            <asp:Button ID="BtnUpload" runat="server" Text="上传并应用" CssClass="li-btn-primary" OnClick="BtnUpload_Click" />
            <asp:Button ID="BtnDelete" runat="server" Text="删除恢复默认" CssClass="li-btn-danger" OnClick="BtnDelete_Click" Visible="false" />
        </div>
        <div class="li-msg">
            <asp:Label ID="LabelMsg" runat="server"></asp:Label>
        </div>
        <div class="li-tips">
            &#128161; 建议：上传 PNG/JPG/SVG 格式，推荐尺寸 480×400 像素，透明背景效果更佳。<br />
            上传后图片将自动应用到教师登录页左侧插画区域。
        </div>
    </div>
</div>
</asp:Content>