<%@ Page Language="C#" AutoEventWireup="true" CodeFile="password_migration.aspx.cs" Inherits="manager_password_migration" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>密码迁移工具</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
            background: #f0f2f5;
            padding: 40px 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            padding: 32px;
            border-radius: 16px 16px 0 0;
            text-align: center;
        }
        .header h1 {
            font-size: 28px;
            margin-bottom: 8px;
        }
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        .content {
            background: #fff;
            padding: 32px;
            border-radius: 0 0 16px 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }
        .alert {
            padding: 16px 20px;
            border-radius: 10px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .alert-info {
            background: #eff6ff;
            color: #1e40af;
            border: 1px solid #bfdbfe;
        }
        .alert-warning {
            background: #fffbeb;
            color: #92400e;
            border: 1px solid #fde68a;
        }
        .alert-success {
            background: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        .alert-error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }
        .alert svg {
            width: 20px;
            height: 20px;
            flex-shrink: 0;
        }
        .section {
            margin-bottom: 32px;
        }
        .section-title {
            font-size: 18px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title svg {
            width: 22px;
            height: 22px;
            stroke: #6366f1;
        }
        .card {
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 16px;
            transition: all 0.2s;
        }
        .card:hover {
            border-color: #cbd5e1;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }
        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: #334155;
        }
        .card-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-pending {
            background: #fef3c7;
            color: #92400e;
        }
        .badge-completed {
            background: #d1fae5;
            color: #065f46;
        }
        .card-body {
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 16px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 12px;
            margin-bottom: 16px;
        }
        .stat-item {
            background: #f8fafc;
            padding: 12px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-label {
            font-size: 12px;
            color: #94a3b8;
            margin-bottom: 4px;
        }
        .stat-value {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            font-family: inherit;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #6366f1, #818cf8);
            color: #fff;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            box-shadow: 0 4px 16px rgba(99, 102, 241, 0.4);
            transform: translateY(-2px);
        }
        .btn-primary:disabled {
            background: #cbd5e1;
            cursor: not-allowed;
            transform: none;
        }
        .btn svg {
            width: 16px;
            height: 16px;
        }
        .steps {
            list-style: none;
            counter-reset: step-counter;
        }
        .steps li {
            counter-increment: step-counter;
            padding-left: 40px;
            position: relative;
            margin-bottom: 16px;
            color: #475569;
            line-height: 1.6;
        }
        .steps li::before {
            content: counter(step-counter);
            position: absolute;
            left: 0;
            top: 0;
            width: 28px;
            height: 28px;
            background: #6366f1;
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
        }
        .footer {
            text-align: center;
            margin-top: 32px;
            padding-top: 24px;
            border-top: 1px solid #e2e8f0;
            color: #94a3b8;
            font-size: 13px;
        }
        .footer a {
            color: #6366f1;
            text-decoration: none;
        }
        .footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <!-- Header -->
            <div class="header">
                <h1>🔐 密码迁移工具</h1>
                <p>将明文密码迁移到加密存储，提升系统安全性</p>
            </div>
            
            <div class="content">
                <!-- 提示信息 -->
                <div class="alert alert-info">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>
                        <strong>重要提示：</strong>此工具将把所有明文密码迁移到MD5+Salt加密存储。迁移过程不会影响用户登录，系统会自动兼容新旧密码。
                    </div>
                </div>
                
                <!-- 消息显示 -->
                <asp:Panel ID="PanelMessage" runat="server" Visible="false">
                    <div id="messageAlert" class="alert" runat="server">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        <div><asp:Literal ID="LitMessage" runat="server" /></div>
                    </div>
                </asp:Panel>
                
                <!-- 教师密码迁移 -->
                <div class="section">
                    <h2 class="section-title">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                        教师密码迁移
                    </h2>
                    
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">教师账号密码加密</div>
                            <span class="card-badge" id="teacherBadge" runat="server">待迁移</span>
                        </div>
                        <div class="card-body">
                            将所有教师账号的明文密码迁移到加密存储。迁移后，教师使用原密码仍可正常登录。
                        </div>
                        <div class="stats">
                            <div class="stat-item">
                                <div class="stat-label">总教师数</div>
                                <div class="stat-value"><asp:Literal ID="LitTeacherTotal" runat="server" Text="0" /></div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-label">待迁移</div>
                                <div class="stat-value"><asp:Literal ID="LitTeacherPending" runat="server" Text="0" /></div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-label">已加密</div>
                                <div class="stat-value"><asp:Literal ID="LitTeacherCompleted" runat="server" Text="0" /></div>
                            </div>
                        </div>
                        <asp:Button ID="BtnMigrateTeacher" runat="server" Text="迁移教师密码" CssClass="btn btn-primary" OnClick="BtnMigrateTeacher_Click" />
                    </div>
                </div>
                
                <!-- 学生密码迁移 -->
                <div class="section">
                    <h2 class="section-title">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                        学生密码迁移
                    </h2>
                    
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">学生账号密码加密</div>
                            <span class="card-badge" id="studentBadge" runat="server">待迁移</span>
                        </div>
                        <div class="card-body">
                            将所有学生账号的明文密码迁移到加密存储。迁移后，学生使用原密码仍可正常登录。
                        </div>
                        <div class="stats">
                            <div class="stat-item">
                                <div class="stat-label">总学生数</div>
                                <div class="stat-value"><asp:Literal ID="LitStudentTotal" runat="server" Text="0" /></div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-label">待迁移</div>
                                <div class="stat-value"><asp:Literal ID="LitStudentPending" runat="server" Text="0" /></div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-label">已加密</div>
                                <div class="stat-value"><asp:Literal ID="LitStudentCompleted" runat="server" Text="0" /></div>
                            </div>
                        </div>
                        <asp:Button ID="BtnMigrateStudent" runat="server" Text="迁移学生密码" CssClass="btn btn-primary" OnClick="BtnMigrateStudent_Click" />
                    </div>
                </div>
                
                <!-- 使用说明 -->
                <div class="section">
                    <h2 class="section-title">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                        使用说明
                    </h2>
                    
                    <div class="alert alert-warning">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                        <div>
                            <strong>注意：</strong>建议在非高峰期进行迁移操作，迁移过程中用户可以正常登录。
                        </div>
                    </div>
                    
                    <ol class="steps">
                        <li>点击"迁移教师密码"按钮，系统将自动迁移所有教师账号的密码</li>
                        <li>点击"迁移学生密码"按钮，系统将自动迁移所有学生账号的密码</li>
                        <li>迁移完成后，查看统计数据确认迁移结果</li>
                        <li>测试登录功能，确保用户可以使用原密码正常登录</li>
                        <li>迁移完成后，系统会自动使用加密密码进行验证</li>
                    </ol>
                </div>
                
                <!-- Footer -->
                <div class="footer">
                    <p>密码加密使用 MD5 + Salt 算法 | <a href="../manager/">返回管理后台</a></p>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
