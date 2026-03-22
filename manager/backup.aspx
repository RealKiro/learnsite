<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_backup, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .bk-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .bk-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .bk-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .bk-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .bk-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .bk-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .bk-grid{display:flex;flex-direction:column;gap:24px;}
    .bk-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .bk-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .bk-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .bk-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .bk-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.purple{background:#eef2ff;} .ci.purple svg{stroke:#6366f1;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .bk-card-bd{padding:22px;}
    .bk-action{display:flex;align-items:center;gap:16px;flex-wrap:wrap;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 28px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:14px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(99,102,241,.3);}
    .btn-primary:hover{box-shadow:0 4px 16px rgba(99,102,241,.4);transform:translateY(-1px);}
    .bk-info{list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:12px;}
    .bk-info li{display:flex;align-items:flex-start;gap:10px;font-size:13px;color:#334155;line-height:1.7;}
    .bk-info li .ni{width:24px;height:24px;border-radius:7px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .ni.db{background:#eef2ff;color:#6366f1;font-size:11px;font-weight:700;}
    .ni.rs{background:#fef3c7;color:#b45309;font-size:11px;font-weight:700;}
    .ni.mv{background:#e0f2fe;color:#0369a1;font-size:11px;font-weight:700;}
    .bk-dl{margin-top:4px;}
    .bk-dl table{width:100%;border-collapse:collapse;}
    .bk-dl td{padding:8px 12px;border-bottom:1px solid #f1f5f9;font-size:13px;color:#334155;}
    .bk-dl td:first-child{color:#94a3b8;width:30px;}
    .bk-dl a{color:#6366f1;text-decoration:none;font-weight:500;}
    .bk-dl a:hover{text-decoration:underline;}
    .bk-msg{margin-top:14px;font-size:13px;}
    #Loading{text-align:center;font-size:13px;color:#ef4444;padding:10px 0;}
</style>

<div class="bk-page">
    <div class="bk-hd">
        <div class="bk-hd-icon"><svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg></div>
        <div class="bk-hd-text"><h1>数据库备份与恢复</h1><p>备份当前数据库或恢复到之前的备份状态</p></div>
    </div>

    <div class="bk-grid">

    <!-- 执行备份 -->
    <div class="bk-card">
        <div class="bk-card-hd">
            <span class="ci purple"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg></span>
            执行备份
        </div>
        <div class="bk-card-bd">
            <div class="bk-action">
                <asp:Button ID="Btnbackup" runat="server" Text="开始备份" CssClass="btn-primary" onclick="Btnbackup_Click" />
            </div>
            <div id="Loading" style="display:none;">
                <asp:Image ID="Image2" runat="server" ImageUrl="~/images/load2.gif" />
                <input id="Textcmd" style="border-style:none" type="text" />
            </div>
            <div class="bk-msg">
                <asp:Label ID="Labelmsg" runat="server" ForeColor="Red"></asp:Label>
            </div>
        </div>
    </div>

    <!-- 备份列表 -->
    <div class="bk-card">
        <div class="bk-card-hd">
            <span class="ci sky"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
            当前备份列表
        </div>
        <div class="bk-card-bd">
            <div class="bk-dl">
                <asp:DataList ID="DlDbBackup" runat="server" 
                    RepeatColumns="3" RepeatDirection="Horizontal" 
                    CellPadding="6" CellSpacing="4" Width="100%"
                    onitemdatabound="DlDbBackup_ItemDataBound" 
                    onitemcommand="DlDbBackup_ItemCommand" EnableTheming="False">
                    <ItemTemplate>
                        <div style="padding:10px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;font-size:13px;display:flex;align-items:center;gap:8px;">
                            <asp:Label ID="Labelfid" runat="server" Text='<%# Eval("fid") %>' ForeColor="#94a3b8" Font-Size="12px"></asp:Label>
                            <asp:HyperLink ID="HLfname" runat="server" Target="_blank" Text='<%# Eval("fname") %>' ForeColor="#6366f1" Font-Size="13px"></asp:HyperLink>
                            <asp:Label ID="Labelfsize" runat="server" Text='<%# Eval("fsize") %>' ForeColor="#64748b" Font-Size="12px"></asp:Label>
                            <asp:Label ID="Labelfread" runat="server" Text='<%# Eval("fread") %>' ToolTip="是否只读（T：只读 | F：可写）" ForeColor="#10b981" Font-Size="12px"></asp:Label>
                            <asp:Label ID="Labelurl" runat="server" Text='<%# Eval("furl") %>' Visible="false"></asp:Label>
                            <asp:ImageButton ID="ImgBtnReStore" runat="server" CommandName="ReStore" 
                                ImageUrl="~/images/works.gif" ToolTip="提示：将当前数据库恢复到该备份日期状态" 
                                CommandArgument='<%# Eval("furl") %>' />
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
        </div>
    </div>

    <!-- 操作说明 -->
    <div class="bk-card">
        <div class="bk-card-hd">
            <span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>
            操作说明
        </div>
        <div class="bk-card-bd">
            <ul class="bk-info">
                <li><span class="ni db">↓</span><strong>备份：</strong>数据库以当前日期+时间为文件名保存到网站 BackupDb 文件夹。恢复前请先备份当前数据库，并自行妄善保存。</li>
                <li><span class="ni rs">↻</span><strong>恢复：</strong>数据库账号密码需与 master 一致，且备份文件与原数据库名称相同，否则请参考说明必读中的截图手工恢复。</li>
                <li><span class="ni mv">→</span><strong>迁移：</strong>将网站文件夹复制到新电脑（非 C 盘），去只读并加 everyone 权限，附加数据库并修改 web.config 连接字符串。</li>
            </ul>
        </div>
    </div>

    </div>
</div>
</asp:Content>

