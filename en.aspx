<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="en, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .en-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .en-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .en-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .en-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .en-title .en-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#3b82f6,#60a5fa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .en-title .en-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .en-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }
    .en-back {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none; font-family: inherit; height: 36px;
    }
    .en-back:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .en-back svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .en-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .en-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .en-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .en-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .en-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .en-card-body { padding: 20px 24px; }

    /* 级别表格 */
    .en-level-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    .en-level-table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        padding: 10px 16px; border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .en-level-table td {
        padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
    }
    .en-level-table tr:hover td { background: #f8fafc; }
    .en-level-badge {
        display: inline-flex; align-items: center; justify-content: center;
        width: 28px; height: 28px; border-radius: 8px; font-size: 13px; font-weight: 700;
    }
    .en-level-badge.l0 { background: #ecfdf5; color: #10b981; }
    .en-level-badge.l1 { background: #eef2ff; color: #6366f1; }
    .en-level-badge.l2 { background: #fef3c7; color: #f59e0b; }
    .en-level-badge.l3 { background: #fee2e2; color: #ef4444; }

    .en-tip {
        display: flex; align-items: flex-start; gap: 10px;
        padding: 12px 16px; border-radius: 8px; margin-bottom: 16px;
        font-size: 13px; line-height: 1.6;
    }
    .en-tip svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; margin-top: 1px; }
    .en-tip-blue { background: #eef2ff; border: 1px solid #e0e7ff; color: #4338ca; }
    .en-tip-blue svg { stroke: #6366f1; }
    .en-tip-green { background: #ecfdf5; border: 1px solid #d1fae5; color: #065f46; }
    .en-tip-green svg { stroke: #10b981; }
    .en-tip-amber { background: #fffbeb; border: 1px solid #fef3c7; color: #92400e; }
    .en-tip-amber svg { stroke: #f59e0b; }
    .en-tip-red { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .en-tip-red svg { stroke: #ef4444; }

    .en-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 10px 28px; border-radius: 8px; font-size: 14px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; text-decoration: none;
        font-family: inherit; height: 40px; line-height: 1;
    }
    .en-btn:hover { background: #f8fafc; border-color: #cbd5e1; box-shadow: 0 1px 4px rgba(0,0,0,.06); color: #1e293b; }
    .en-btn-danger {
        background: linear-gradient(135deg,#ef4444,#f87171); color: #fff;
        border-color: #ef4444; box-shadow: 0 2px 8px rgba(239,68,68,.18);
    }
    .en-btn-danger:hover { background: linear-gradient(135deg,#dc2626,#ef4444); border-color: #dc2626; box-shadow: 0 4px 12px rgba(239,68,68,.28); color: #fff; }
    .en-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .en-action-area {
        display: flex; flex-direction: column; align-items: center; gap: 16px;
        padding: 30px 20px; background: #f8fafc; border-radius: 10px;
        border: 1px solid #f1f5f9;
    }
    .en-action-icon {
        width: 56px; height: 56px; border-radius: 14px; background: linear-gradient(135deg,#3b82f6,#60a5fa);
        display: flex; align-items: center; justify-content: center;
    }
    .en-action-icon svg { width: 28px; height: 28px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .en-action-text { font-size: 14px; color: #64748b; text-align: center; }
    .en-msg { min-height: 20px; margin-top: 10px; text-align: center; }

    /* 步骤说明 */
    .en-steps { display: flex; gap: 16px; margin-bottom: 20px; }
    .en-step {
        flex: 1; padding: 16px 18px; border-radius: 10px; background: #f8fafc;
        border: 1px solid #f1f5f9;
    }
    .en-step-num {
        display: inline-flex; align-items: center; justify-content: center;
        width: 26px; height: 26px; border-radius: 50%; font-size: 12px; font-weight: 700;
        margin-bottom: 8px;
    }
    .en-step-num.s1 { background: #eef2ff; color: #6366f1; }
    .en-step-num.s2 { background: #ecfdf5; color: #10b981; }
    .en-step-num.s3 { background: #fef3c7; color: #f59e0b; }
    .en-step-title { font-size: 13px; font-weight: 600; color: #1e293b; margin-bottom: 4px; }
    .en-step-text { font-size: 12px; color: #64748b; line-height: 1.5; }
</style>

<div class="en-page">
    <!-- 页面标题 -->
    <div class="en-header">
        <div class="en-title-wrap">
            <div class="en-title">
                <span class="en-icon">
                    <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                </span>
                指法英文字典管理
            </div>
            <div class="en-subtitle">管理指法练习使用的英文单词字典，支持重新导入自定义字典文件</div>
        </div>
        <a href="teacher/typer.aspx" class="en-back">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回打字管理
        </a>
    </div>

    <!-- 字典级别说明卡片 -->
    <div class="en-card">
        <div class="en-card-header">
            <div>
                <div class="en-card-title">
                    <svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                    英语级别说明
                </div>
                <div class="en-card-desc">字典文件 en.xls 中 Elevel 字段对应的英语级别含义</div>
            </div>
        </div>
        <div class="en-card-body">
            <table class="en-level-table">
                <thead>
                    <tr>
                        <th style="width:100px;">Elevel 值</th>
                        <th>英语级别</th>
                        <th>说明</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span class="en-level-badge l0">0</span></td>
                        <td>小学英语</td>
                        <td>适合小学生的基础英文单词</td>
                    </tr>
                    <tr>
                        <td><span class="en-level-badge l1">1</span></td>
                        <td>初中英语</td>
                        <td>适合初中生的中等难度单词</td>
                    </tr>
                    <tr>
                        <td><span class="en-level-badge l2">2</span></td>
                        <td>高中英语</td>
                        <td>适合高中生的较高难度单词</td>
                    </tr>
                    <tr>
                        <td><span class="en-level-badge l3">3</span></td>
                        <td>编程英语</td>
                        <td>编程相关的英文关键词和术语</td>
                    </tr>
                </tbody>
            </table>

            <div class="en-tip en-tip-green">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div>可以根据需要自行修改或添加 <strong>en.xls</strong> 中的 Elevel 值，并在 <strong>myfinger.aspx</strong> 的下拉列表中做相应的级别配置。</div>
            </div>
        </div>
    </div>

    <!-- 导入操作卡片 -->
    <div class="en-card">
        <div class="en-card-header">
            <div>
                <div class="en-card-title">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    重新导入字典
                </div>
                <div class="en-card-desc">用新的 en.xls 文件替换当前英文字典数据</div>
            </div>
        </div>
        <div class="en-card-body">
            <!-- 操作步骤 -->
            <div class="en-steps">
                <div class="en-step">
                    <div class="en-step-num s1">1</div>
                    <div class="en-step-title">准备字典文件</div>
                    <div class="en-step-text">按照上方级别说明，编辑好新的 en.xls 文件，确保 Elevel 字段正确。</div>
                </div>
                <div class="en-step">
                    <div class="en-step-num s2">2</div>
                    <div class="en-step-title">替换文件</div>
                    <div class="en-step-text">将新的 en.xls 文件上传到网站根目录，覆盖原有文件。</div>
                </div>
                <div class="en-step">
                    <div class="en-step-num s3">3</div>
                    <div class="en-step-title">点击导入</div>
                    <div class="en-step-text">点击下方「英文字典重新导入」按钮，系统将清空旧字典并导入新数据。</div>
                </div>
            </div>

            <!-- 警告提示 -->
            <div class="en-tip en-tip-red" style="margin-bottom:20px;">
                <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                <div>此操作将 <strong>清空原有字典数据</strong> 并导入新字典，不可恢复！请确保已将新的 en.xls 文件放置在网站根目录。本页面只能在服务器上操作，以防误操作。</div>
            </div>

            <!-- 操作区 -->
            <div class="en-action-area">
                <div class="en-action-icon">
                    <svg viewBox="0 0 24 24"><polyline points="16 16 12 12 8 16"/><line x1="12" y1="12" x2="12" y2="21"/><path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3"/><polyline points="16 16 12 12 8 16"/></svg>
                </div>
                <div class="en-action-text">确认已替换根目录下的 en.xls 文件后，点击下方按钮导入</div>
                <asp:Button ID="Buttonen" runat="server" onclick="Buttonen_Click"
                    Text="英文字典重新导入" CssClass="en-btn en-btn-danger"
                    ToolTip="将清空原字典，请导入新字典！"
                    OnClientClick="return confirm('确定要清空并重新导入英文字典吗？\n此操作将清除所有现有字典数据！');" />
                <div class="en-msg">
                    <asp:Label ID="Labelmsg" runat="server" ForeColor="#ef4444" Font-Size="13px"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <!-- 常见问题卡片 -->
    <div class="en-card">
        <div class="en-card-header">
            <div>
                <div class="en-card-title">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    常见问题
                </div>
            </div>
        </div>
        <div class="en-card-body">
            <div class="en-tip en-tip-blue" style="margin-bottom:12px;">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div><strong>问：en.xls 文件在哪里？</strong><br/>在网站根目录下，与 default.aspx 同级目录。你可以通过 FTP 或服务器文件管理器访问。</div>
            </div>
            <div class="en-tip en-tip-blue" style="margin-bottom:12px;">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div><strong>问：可以添加自定义级别吗？</strong><br/>可以。在 en.xls 中新增 Elevel 值（如 4、5 等），同时在 myfinger.aspx 的下拉菜单中添加对应的选项即可。</div>
            </div>
            <div class="en-tip en-tip-blue">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div><strong>问：为什么点击导入按钮没有反应？</strong><br/>本页面只能在服务器本地浏览时操作。如果你是通过远程访问，请登录到服务器桌面后再操作。</div>
            </div>
        </div>
    </div>
</div>
</asp:Content>
