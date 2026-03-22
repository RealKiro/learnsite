<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Manager_divide, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .dv-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .dv-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .dv-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#10b981,#34d399);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(16,185,129,.25);flex-shrink:0;}
    .dv-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .dv-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .dv-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .dv-grid{display:flex;flex-direction:column;gap:24px;}
    .dv-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .dv-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .dv-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .dv-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .dv-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .dv-card-bd{padding:22px;}
    .dv-steps{list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:12px;}
    .dv-steps li{display:flex;align-items:flex-start;gap:10px;font-size:13px;color:#334155;line-height:1.7;}
    .dv-steps li .sn{width:24px;height:24px;border-radius:50%;background:linear-gradient(135deg,#10b981,#34d399);color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:11px;font-weight:700;}
    .dv-action-row{display:flex;align-items:center;gap:16px;flex-wrap:wrap;margin-bottom:16px;}
    .dv-sample-inline{display:flex;align-items:flex-start;gap:24px;flex-wrap:wrap;margin-top:16px;}
    .dv-card input[type="file"]{font-size:12px;color:#475569;}
    .dv-card input[type="file"]::file-selector-button{height:32px;padding:0 14px;background:#f1f5f9;color:#334155;border:1.5px solid #e2e8f0;border-radius:8px;font-size:12px;cursor:pointer;transition:all .2s;margin-right:8px;}
    .dv-card input[type="file"]::file-selector-button:hover{background:#e2e8f0;border-color:#cbd5e1;}
    .btn-emerald{display:inline-flex;align-items:center;justify-content:center;height:38px;padding:0 24px;background:linear-gradient(135deg,#10b981,#059669);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(16,185,129,.3);}
    .btn-emerald:hover{box-shadow:0 4px 16px rgba(16,185,129,.4);transform:translateY(-1px);}
    .dv-msg{margin-top:14px;font-size:13px;}
    .dv-sample{margin-top:8px;}
    .dv-sample-title{font-size:13px;font-weight:600;color:#475569;margin-bottom:8px;}
    .dv-sample table{border-collapse:collapse;font-size:13px;width:100%;}
    .dv-sample th{background:#f8fafc;color:#475569;font-weight:600;padding:8px 14px;text-align:left;border:1px solid #e2e8f0;}
    .dv-sample td{padding:8px 14px;color:#334155;border:1px solid #f1f5f9;}
    .dv-warn{margin-top:14px;background:#fefce8;border:1px solid #fde68a;border-radius:8px;padding:10px 14px;font-size:12.5px;color:#92400e;}
</style>

<div class="dv-page">
    <div class="dv-hd">
        <div class="dv-hd-icon"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></div>
        <div class="dv-hd-text"><h1>重新分班</h1><p>上传Excel表格，根据新的分班方案更新学生班级</p></div>
    </div>

    <div class="dv-grid">

    <!-- 上传分班表（置顶） -->
    <div class="dv-card">
        <div class="dv-card-hd">
            <span class="ci sky"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></span>
            上传分班表
        </div>
        <div class="dv-card-bd">
            <div class="dv-action-row">
                <asp:FileUpload ID="FileUpload1" runat="server" />
                <asp:Button ID="Btndivide" runat="server" Text="重新分班" CssClass="btn-emerald" onclick="Btndivide_Click" />
            </div>
            <div class="dv-msg">
                <asp:Label ID="Labelmsg" runat="server"></asp:Label>
            </div>
            <div class="dv-sample-inline">
                <div class="dv-sample" style="flex:1;min-width:240px;">
                    <div class="dv-sample-title">Excel 表格格式示例：</div>
                    <table>
                        <tr><th>年级</th><th>班级</th><th>姓名</th></tr>
                        <tr><td>8</td><td>1</td><td>张三</td></tr>
                        <tr><td>8</td><td>1</td><td>李四</td></tr>
                    </table>
                </div>
                <div class="dv-warn" style="flex:1;min-width:240px;margin-top:0;align-self:flex-end;">⚠ 如果导入出错，请检查 Excel 中年级、班级列的格式是否为数字</div>
            </div>
        </div>
    </div>

    <!-- 分班说明 -->
    <div class="dv-card">
        <div class="dv-card-hd">
            <span class="ci emerald"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>
            分班说明
        </div>
        <div class="dv-card-bd">
            <ol class="dv-steps">
                <li><span class="sn">1</span>请在新学期学年升班后再进行操作</li>
                <li><span class="sn">2</span>上传该年级段重新分班后的 Excel 表格</li>
                <li><span class="sn">3</span>分班完成后，用所教班级的教师账号进行确认</li>
                <li><span class="sn">4</span>分班表中可能包含新插班生，需教师在学生管理中手动添加</li>
                <li><span class="sn">5</span>操作前请务必做好<strong>数据库备份</strong></li>
                <li><span class="sn">6</span>平台根据上传的学生班级替换原班级，<strong>同姓名学生不做分班处理</strong></li>
            </ol>
        </div>
    </div>

    </div>
</div>
</asp:Content>

