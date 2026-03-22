<%@ page title="" language="C#" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_studentedit, LearnSite" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>编辑学生信息</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
            background: #fff;
            margin: 0; padding: 0;
        }
        #form1 { width: 100%; }

        .modal-card {
            background: #fff;
            overflow: hidden;
        }
        .modal-header {
            background: linear-gradient(135deg, #059669 0%, #34d399 100%);
            padding: 14px 20px;
            display: flex; align-items: center; gap: 10px;
        }
        .modal-header-icon {
            width: 36px; height: 36px;
            background: rgba(255,255,255,0.2);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
        }
        .modal-header-icon svg {
            width: 22px; height: 22px;
            stroke: #fff; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
        }
        .modal-header-text h2 { font-size: 15px; font-weight: 600; color: #fff; margin: 0; }
        .modal-header-text p { font-size: 12px; color: rgba(255,255,255,0.8); margin: 2px 0 0; }

        .modal-body { padding: 16px 20px; }
        .form-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px 16px;
        }
        .form-group { display: flex; flex-direction: column; gap: 4px; }
        .form-group.full-width { grid-column: 1 / -1; }
        .form-group label {
            font-size: 12px; font-weight: 600; color: #64748b;
            display: flex; align-items: center; gap: 4px;
        }
        .form-group label svg {
            width: 14px; height: 14px;
            stroke: #94a3b8; fill: none; stroke-width: 2;
        }
        .form-group input[type="text"],
        .form-group select {
            width: 100% !important;
            padding: 8px 10px !important;
            border: 1px solid #e2e8f0 !important;
            border-radius: 8px !important;
            font-size: 13px !important;
            color: #334155 !important;
            background: #fff !important;
            transition: all 0.2s !important;
            outline: none !important;
        }
        .form-group input[type="text"]:focus,
        .form-group select:focus {
            border-color: #34d399 !important;
            box-shadow: 0 0 0 3px rgba(52,211,153,0.1) !important;
        }
        .form-group input.editable {
            background: #fffbeb !important;
            border-color: #fde68a !important;
        }
        .form-group input.editable:focus {
            border-color: #f59e0b !important;
            box-shadow: 0 0 0 3px rgba(245,158,11,0.1) !important;
        }
        .form-group input.readonly {
            background: #f8fafc !important;
            color: #94a3b8 !important;
            cursor: not-allowed;
        }
        .form-group select {
            cursor: pointer;
            background: #fffbeb !important;
            border-color: #fde68a !important;
        }

        .modal-footer {
            padding: 12px 20px;
            background: #f8fafc;
            border-top: 1px solid #f1f5f9;
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
        }
        .modal-footer .hint {
            font-size: 11px; color: #94a3b8;
            display: flex; align-items: center; gap: 4px;
        }
        .modal-footer .hint svg {
            width: 14px; height: 14px;
            stroke: #94a3b8; fill: none; stroke-width: 2;
        }
        .btn-success {
            display: inline-flex !important; align-items: center; justify-content: center; gap: 6px;
            padding: 10px 28px !important;
            background: linear-gradient(135deg, #059669, #34d399) !important;
            color: #fff !important; border: none !important; border-radius: 8px !important;
            font-size: 14px !important; font-weight: 600 !important;
            cursor: pointer; transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(5,150,105,0.3);
        }
        .btn-success:hover {
            background: linear-gradient(135deg, #047857, #059669) !important;
            box-shadow: 0 4px 16px rgba(5,150,105,0.4);
            transform: translateY(-1px);
        }
        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="modal-card">
            <div class="modal-header">
                <div class="modal-header-icon">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                </div>
                <div class="modal-header-text">
                    <h2>编辑学生信息</h2>
                    <p>修改学生的基本资料信息</p>
                </div>
            </div>

            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            学号
                        </label>
                        <asp:TextBox ID="Tsnum" runat="server" CssClass="readonly" ReadOnly="True" ToolTip="学号不可修改"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            姓名
                        </label>
                        <asp:TextBox ID="Tsname" runat="server" CssClass="editable"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            入学年度
                        </label>
                        <asp:TextBox ID="Tsyear" runat="server" CssClass="readonly" ReadOnly="True"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                            年级
                        </label>
                        <asp:DropDownList ID="DDLgrade" runat="server" Enabled="False"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            班级
                        </label>
                        <asp:DropDownList ID="DDLclass" runat="server"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            班主任
                        </label>
                        <asp:TextBox ID="Tsheadtheacher" runat="server" CssClass="editable"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            密码
                        </label>
                        <asp:TextBox ID="Tspwd" runat="server" CssClass="editable" ToolTip="可修改密码"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>
                            性别
                        </label>
                        <asp:DropDownList ID="DDLsex" runat="server"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            父母姓名
                        </label>
                        <asp:TextBox ID="Tsparents" runat="server" CssClass="editable"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            表现分
                        </label>
                        <asp:TextBox ID="Tsattitude" runat="server" CssClass="readonly" ReadOnly="True" ToolTip="表现分不可修改"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            成绩
                        </label>
                        <asp:TextBox ID="Tsscore" runat="server" CssClass="readonly" ReadOnly="True" ToolTip="成绩不可修改"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                            联系电话
                        </label>
                        <asp:TextBox ID="Tsphone" runat="server" CssClass="editable"></asp:TextBox>
                    </div>

                    <div class="form-group full-width">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                            家庭地址
                        </label>
                        <asp:TextBox ID="Tsaddress" runat="server" CssClass="editable"></asp:TextBox>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <div class="hint">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <span>黄色输入框为可编辑项，灰色为不可修改项</span>
                </div>
                <asp:Button ID="Btnsedit" runat="server" OnClick="BtnsEdit_Click" Text="✔ 保存修改" CssClass="btn-success" />
            </div>
        </div>
    </form>
</body>
</html>

