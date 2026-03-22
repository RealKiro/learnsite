<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_typeedit, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .te-page,.te-page *{box-sizing:border-box}
    .te-page{width:min(1480px,100%);margin:0 auto;padding:24px 20px 36px;font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif;color:#0f172a}
    .te-shell{position:relative;padding:26px;border-radius:28px;background:radial-gradient(circle at top left,rgba(59,130,246,.12),transparent 26%),radial-gradient(circle at top right,rgba(20,184,166,.12),transparent 24%),linear-gradient(180deg,#f8fbff,#f6f9fc);box-shadow:0 18px 36px rgba(15,23,42,.07);overflow:hidden}
    .te-shell:before{content:"";position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.68),rgba(255,255,255,0));pointer-events:none}
    .te-hero,.te-card{position:relative;z-index:1}
    .te-hero{display:grid;grid-template-columns:minmax(0,1.35fr) 280px;gap:18px;margin-bottom:22px;padding:28px;border-radius:24px;background:linear-gradient(135deg,#f7fbff 0%,#eef6ff 52%,#edfdf8 100%);color:#0f172a;overflow:hidden;border:1px solid #dbe7f3}
    .te-hero:after{content:"";position:absolute;right:-68px;top:-54px;width:220px;height:220px;border-radius:50%;background:rgba(37,99,235,.08)}
    .te-hero-main,.te-hero-side{position:relative;z-index:1}
    .te-tag{display:inline-flex;align-items:center;padding:8px 12px;border-radius:999px;background:#ffffff;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb;border:1px solid #dbe7f3}
    .te-hero h2{margin:14px 0 10px;font-size:30px;line-height:1.15;color:#0f172a}
    .te-hero p{margin:0;max-width:640px;font-size:15px;line-height:1.8;color:#475569}
    .te-meta{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin-top:20px}
    .te-meta-item{padding:14px 16px;border-radius:18px;background:rgba(255,255,255,.86);border:1px solid #dbe7f3;box-shadow:0 8px 18px rgba(37,99,235,.06)}
    .te-meta-item span{display:block;font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:#64748b}
    .te-meta-item strong{display:block;margin-top:6px;font-size:18px;color:#0f172a}
    .te-hero-side{padding:20px;border-radius:20px;background:rgba(255,255,255,.78);border:1px solid #dbe7f3}
    .te-side-title{margin:0 0 12px;font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#2563eb}
    .te-tip{display:flex;gap:10px;align-items:flex-start;margin-top:10px;font-size:13px;line-height:1.75;color:#475569}
    .te-tip b{display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:9px;background:#eff6ff;color:#2563eb;font-size:11px;flex-shrink:0}
    .te-card{background:#fff;border:1px solid #e2e8f0;border-radius:24px;box-shadow:0 14px 28px rgba(15,23,42,.05);overflow:hidden}
    .te-head{display:flex;gap:14px;align-items:flex-start;padding:20px 24px 16px;border-bottom:1px solid #eef2f7;background:linear-gradient(180deg,#fff,#f8fafc)}
    .te-icon{width:44px;height:44px;display:flex;align-items:center;justify-content:center;flex-shrink:0;border-radius:14px;background:linear-gradient(135deg,#dbeafe,#bfdbfe);color:#2563eb}
    .te-icon svg{width:21px;height:21px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
    .te-head h3{margin:0;font-size:17px;color:#0f172a}
    .te-head p{margin:5px 0 0;font-size:13px;line-height:1.7;color:#64748b}
    .te-body{padding:22px 24px 24px}
    .te-grid{display:grid;grid-template-columns:minmax(0,1.4fr) 160px 120px;gap:16px;align-items:end}
    .te-field label{display:flex;align-items:center;gap:8px;margin-bottom:9px;font-size:14px;font-weight:700;color:#334155}
    .te-field input[type=text],.te-field select,.te-field textarea{width:100%;padding:13px 14px;border:1px solid #d7e1ea;border-radius:14px;background:linear-gradient(180deg,#fff,#f8fafc);font-size:14px;color:#0f172a;font-family:inherit;transition:border-color .18s,box-shadow .18s,background .18s}
    .te-field input[type=text]:focus,.te-field select:focus,.te-field textarea:focus{outline:none;border-color:#2563eb;background:#fff;box-shadow:0 0 0 4px rgba(37,99,235,.12)}
    .te-field textarea{min-height:260px;resize:vertical;line-height:1.8}
    .te-mini{margin-top:8px;font-size:12px;line-height:1.7;color:#64748b}
    .te-inline{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
    .te-inline .te-btn{flex-shrink:0}
    .te-validator{color:#dc2626;font-weight:700}
    .te-note{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin:18px 0}
    .te-note-item{padding:14px 16px;border-radius:16px;border:1px solid #dbe6f2;background:linear-gradient(135deg,#fff,#f8fbff)}
    .te-note-item strong{display:block;font-size:13px;color:#0f172a}
    .te-note-item span{display:block;margin-top:6px;font-size:12px;line-height:1.7;color:#64748b}
    .te-actions{display:flex;align-items:center;justify-content:space-between;gap:16px;padding:18px 20px;border-radius:20px;background:linear-gradient(135deg,#f7fbff 0%,#eef5ff 60%,#edfdf8 100%);color:#334155;border:1px solid #dbe7f3}
    .te-actions h4{margin:0 0 6px;font-size:16px;color:#0f172a}
    .te-actions p{margin:0;font-size:13px;line-height:1.75;color:#64748b}
    .te-btns{display:flex;gap:12px;flex-wrap:wrap;align-items:center}
    .te-btn,
    input.te-btn,
    input[type="submit"].te-btn,
    input[type="button"].te-btn{
        display:inline-block!important;
        min-width:120px;
        height:42px;
        padding:0 24px!important;
        line-height:40px!important;
        text-align:center!important;
        vertical-align:middle;
        border-radius:999px!important;
        font-size:14px!important;
        font-weight:700!important;
        cursor:pointer;
        transition:transform .15s,box-shadow .15s,background .15s,border-color .15s;
        border:1px solid transparent!important;
        background-image:none!important;
        text-indent:0!important;
        white-space:nowrap;
        font-family:'Microsoft YaHei','Segoe UI',Arial,sans-serif!important;
        appearance:none;
        -webkit-appearance:none;
        box-shadow:none;
    }
    #<%= BtnNoSet.ClientID %>,
    #<%= BtnEdit.ClientID %>,
    #<%= Btnreturn.ClientID %>{
        width:160px!important;
        min-width:160px!important;
        height:42px!important;
        line-height:40px!important;
        padding:0 18px!important;
        margin:0!important;
        text-align:center!important;
        text-indent:0!important;
        letter-spacing:0!important;
        background-image:none!important;
        box-sizing:border-box!important;
        overflow:visible!important;
    }
    #<%= BtnNoSet.ClientID %>{
        width:180px!important;
        min-width:180px!important;
    }
    .te-btn:hover,
    input.te-btn:hover,
    input[type="submit"].te-btn:hover,
    input[type="button"].te-btn:hover{transform:translateY(-1px)}
    .te-btn-primary,
    input.te-btn-primary{
        background:linear-gradient(135deg,#22c55e,#16a34a)!important;
        color:#fff!important;
        border-color:#16a34a!important;
        box-shadow:0 10px 20px rgba(34,197,94,.22)!important;
    }
    .te-btn-secondary,
    input.te-btn-secondary{
        background:linear-gradient(135deg,#ffffff,#f8fafc)!important;
        color:#475569!important;
        border-color:#d7e1ea!important;
        box-shadow:0 8px 16px rgba(15,23,42,.06)!important;
    }
    .te-msg{margin-top:14px;padding:14px 16px;border-radius:16px;border:1px dashed #cbd5e1;background:#fff;font-size:13px;line-height:1.75;color:#475569;min-height:52px}
    @media (max-width:1024px){.te-hero,.te-grid,.te-actions{grid-template-columns:1fr}.te-hero{grid-template-columns:1fr}.te-actions{display:block}.te-btns{margin-top:14px}}
    @media (max-width:768px){.te-page{padding:14px}.te-shell{padding:16px}.te-hero{padding:20px}.te-hero h2{font-size:26px}.te-meta,.te-note,.te-grid{grid-template-columns:1fr}.te-head,.te-body{padding-left:18px;padding-right:18px}.te-btns{flex-direction:column}.te-btn{width:100%}}
</style>
<div class="te-page">
    <div class="te-shell">
        <div class="te-hero">
            <div class="te-hero-main">
                <span class="te-tag">Typing Article Editor</span>
                <h2>打字文章编辑</h2>
                <p>在这里统一修改文章标题、用途、范围和正文内容。页面改成了更适合教师编辑的结构，录入区更清楚，操作按钮也更集中。</p>
                <div class="te-meta">
                    <div class="te-meta-item"><span>内容上限</span><strong>300 字符</strong></div>
                    <div class="te-meta-item"><span>中文建议</span><strong>210 汉字内</strong></div>
                    <div class="te-meta-item"><span>适用场景</span><strong>练习 / 比赛</strong></div>
                </div>
            </div>
            <div class="te-hero-side">
                <p class="te-side-title">编辑提示</p>
                <div class="te-tip"><b>01</b><span>标题尽量简短明确，便于学生快速识别文章主题。</span></div>
                <div class="te-tip"><b>02</b><span>如果正文是从别处复制来的，先用“清除格式”再检查内容排版。</span></div>
                <div class="te-tip"><b>03</b><span>保存前确认用途和范围，避免练习内容误发到比赛分类。</span></div>
            </div>
        </div>

        <div class="te-card">
            <div class="te-head">
                <span class="te-icon"><svg viewBox="0 0 24 24"><path d="M4 7V4h16v3"></path><path d="M9 20h6"></path><path d="M12 4v16"></path></svg></span>
                <div>
                    <h3>文章信息</h3>
                    <p>保留原有编辑逻辑，只重做布局和视觉层级，让内容编辑更顺手。</p>
                </div>
            </div>

            <div class="te-body">
                <div class="te-grid">
                    <div class="te-field">
                        <label>文章标题 <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="*" ControlToValidate="Ttitle" CssClass="te-validator"></asp:RequiredFieldValidator></label>
                        <asp:TextBox ID="Ttitle" runat="server" SkinID="TextBoxNormal"></asp:TextBox>
                    </div>
                    <div class="te-field">
                        <label>文章用途</label>
                        <asp:DropDownList ID="DDLuse" runat="server">
                            <asp:ListItem Selected="True" Value="11">中文练习</asp:ListItem>
                            <asp:ListItem Value="12">中文比赛</asp:ListItem>
                            <asp:ListItem Value="21">英文练习</asp:ListItem>
                            <asp:ListItem Value="22">英文比赛</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="te-field">
                        <label>文章范围</label>
                        <asp:DropDownList ID="DDLtype" runat="server">
                            <asp:ListItem>0</asp:ListItem>
                            <asp:ListItem>1</asp:ListItem>
                            <asp:ListItem>2</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="te-note">
                    <div class="te-note-item">
                        <strong>用途说明</strong>
                        <span>练习类适合平时训练，比赛类适合正式测速或竞赛场景。</span>
                    </div>
                    <div class="te-note-item">
                        <strong>范围说明</strong>
                        <span>文章范围决定内容归类，请按当前教学安排准确设置。</span>
                    </div>
                    <div class="te-note-item">
                        <strong>格式说明</strong>
                        <span>遇到复制内容样式混乱时，可先清除格式再做正文修订。</span>
                    </div>
                </div>

                <div class="te-field">
                    <div class="te-inline" style="justify-content:space-between;margin-bottom:9px;">
                        <label style="margin:0;">文章正文</label>
                        <asp:Button ID="BtnNoSet" runat="server" Text="清除格式" OnClick="BtnNoSet_Click" SkinID="BtnNormal" CssClass="te-btn te-btn-secondary" ToolTip="系统限制汉字长度为210个" />
                    </div>
                    <asp:TextBox ID="Tcontent" runat="server" MaxLength="300" TextMode="MultiLine" BorderColor="#DFDFDF" BorderStyle="Solid" BorderWidth="1px" BackColor="White"></asp:TextBox>
                    <div class="te-mini">系统限制总长度为 300 字符；中文内容建议控制在 210 个汉字以内，便于学生练习。</div>
                </div>

                <div class="te-actions">
                    <div>
                        <h4>提交修改</h4>
                        <p>确认标题、用途、范围和正文无误后，再提交保存。如果暂时不改，可以直接返回上一页。</p>
                    </div>
                    <div class="te-btns">
                        <asp:Button ID="BtnEdit" runat="server" Text="修改" OnClick="BtnEdit_Click" SkinID="BtnNormal" CssClass="te-btn te-btn-primary" />
                        <asp:Button ID="Btnreturn" runat="server" Text="返回" OnClick="Btnreturn_Click" SkinID="BtnNormal" CssClass="te-btn te-btn-secondary" />
                    </div>
                </div>

                <div class="te-msg">
                    <asp:Label ID="Labelmsg" runat="server"></asp:Label>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>
