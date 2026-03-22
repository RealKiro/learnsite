<%@ page title="" language="C#" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_studentadd, LearnSite" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>添加学生</title>
    <style>
        /* ===== 弹窗基础样式 ===== */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif;
            background: #fff;
            margin: 0;
            padding: 0;
        }
        #form1 {
            width: 100%;
        }

        /* ===== 卡片容器 ===== */
        .modal-card {
            background: #fff;
            overflow: hidden;
        }

        /* ===== 卡片头部 ===== */
        .modal-header {
            background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%);
            padding: 14px 20px;
            display: flex;
            align-items: center;
            gap: 10px;
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
        .modal-header-text h2 {
            font-size: 15px;
            font-weight: 600;
            color: #fff;
            margin: 0;
        }
        .modal-header-text p {
            font-size: 12px;
            color: rgba(255,255,255,0.8);
            margin: 2px 0 0;
        }

        /* ===== 表单区域 ===== */
        .modal-body {
            padding: 16px 20px;
        }
        .form-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px 16px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        .form-group label {
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .form-group label .required {
            color: #ef4444;
            font-weight: 700;
        }
        .form-group label svg {
            width: 14px; height: 14px;
            stroke: #94a3b8; fill: none;
            stroke-width: 2;
        }

        /* ===== 输入框美化 ===== */
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
            border-color: #818cf8 !important;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.1) !important;
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

        /* ===== 底部操作栏 ===== */
        .modal-footer {
            padding: 12px 20px;
            background: #f8fafc;
            border-top: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }
        .modal-footer .hint {
            font-size: 11px;
            color: #94a3b8;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .modal-footer .hint svg {
            width: 14px; height: 14px;
            stroke: #94a3b8; fill: none;
            stroke-width: 2;
        }
        .modal-footer .msg {
            font-size: 12px;
            color: #059669;
            font-weight: 500;
        }

        /* ===== 按钮美化 ===== */
        .btn-primary {
            display: inline-flex !important;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 10px 28px !important;
            background: linear-gradient(135deg, #6366f1, #818cf8) !important;
            color: #fff !important;
            border: none !important;
            border-radius: 8px !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(99,102,241,0.3);
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
            box-shadow: 0 4px 16px rgba(99,102,241,0.4);
            transform: translateY(-1px);
        }

        /* ===== 响应式 ===== */
        @media (max-width: 600px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .modal-footer {
                flex-direction: column;
                align-items: stretch;
                gap: 8px;
            }
        }
    </style>

<script runat="server">
    private string GetConnStr()
    {
        System.Configuration.ConnectionStringSettings cfg =
            System.Configuration.ConfigurationManager.ConnectionStrings["constr"]
            ?? System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"];
        return cfg != null ? cfg.ConnectionString : null;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // 初始加载或刷新校区下拉列表
        if (!IsPostBack || DDLSchool.Items.Count <= 1)
            LoadSchoolDropdown();

        // 学生添加成功后保存所选校区
        if (IsPostBack && !string.IsNullOrEmpty(HfSavedSnum.Value))
        {
            int schoolId;
            if (int.TryParse(DDLSchool.SelectedValue, out schoolId) && schoolId > 0)
                SaveStudentSchool(HfSavedSnum.Value, schoolId);
            HfSavedSnum.Value = ""; // 清除，避免重复保存
        }
    }

    private void LoadSchoolDropdown()
    {
        DDLSchool.Items.Clear();
        DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem("— 不指定校区 —", "0"));
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='School'", conn))
                { if (Convert.ToInt32(chk.ExecuteScalar()) == 0) return; }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT SchoolId, SchoolName FROM School WHERE ISNULL(IsActive,1)=1 ORDER BY SchoolId", conn))
                using (System.Data.SqlClient.SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                        DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem(
                            r["SchoolName"].ToString(), r["SchoolId"].ToString()));
                }
            }
        }
        catch { }
    }

    private void SaveStudentSchool(string snum, int schoolId)
    {
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // 检测 SchoolId 字段是否存在
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Students' AND COLUMN_NAME='SchoolId'", conn))
                { if (Convert.ToInt32(chk.ExecuteScalar()) == 0) return; }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "UPDATE Students SET SchoolId=@schId WHERE Snum=@snum", conn))
                {
                    cmd.Parameters.AddWithValue("@schId", schoolId);
                    cmd.Parameters.AddWithValue("@snum", snum);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }
</script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="modal-card">
            <!-- 头部 -->
            <div class="modal-header">
                <div class="modal-header-icon">
                    <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                </div>
                <div class="modal-header-text">
                    <h2>添加学生</h2>
                    <p>填写学生基本信息，带 * 为必填项</p>
                </div>
            </div>

            <!-- 表单区域 -->
            <div class="modal-body">
                <div class="form-grid">
                    <!-- 第一行 -->
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            学号
                        </label>
                        <asp:TextBox ID="Tsnum" runat="server" CssClass="readonly" ReadOnly="true" ToolTip="自动生成"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <span class="required">*</span> 姓名
                        </label>
                        <asp:TextBox ID="Tsname" runat="server" CssClass="editable"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            入学年度
                        </label>
                        <asp:DropDownList ID="DDLyear" runat="server"></asp:DropDownList>
                    </div>

                    <!-- 校区行（年级前）——选校区、年级、班级排列一行 -->
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            所属校区
                        </label>
                        <asp:DropDownList ID="DDLSchool" runat="server"></asp:DropDownList>
                    </div>

                    <!-- 第二行 -->
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                            <span class="required">*</span> 年级
                        </label>
                        <asp:DropDownList ID="DDLgrade" runat="server"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            <span class="required">*</span> 班级
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

                    <!-- 第三行 -->
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            密码
                        </label>
                        <asp:TextBox ID="Tspwd" runat="server" CssClass="readonly" ReadOnly="True" ToolTip="默认密码 12345">12345</asp:TextBox>
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

                    <!-- 第四行 -->
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            表现分
                        </label>
                        <asp:TextBox ID="Tsattitude" runat="server" CssClass="readonly" ReadOnly="True" ToolTip="表现分不可修改">0</asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                            成绩
                        </label>
                        <asp:TextBox ID="Tsscore" runat="server" CssClass="readonly" ReadOnly="True" ToolTip="成绩不可修改">0</asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                            联系电话
                        </label>
                        <asp:TextBox ID="Tsphone" runat="server" CssClass="editable"></asp:TextBox>
                    </div>

                    <!-- 地址（整行） -->
                    <div class="form-group full-width">
                        <label>
                            <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                            家庭地址
                        </label>
                        <asp:TextBox ID="Tsaddress" runat="server" CssClass="editable"></asp:TextBox>
                    </div>
                </div>
            </div>

            <!-- 底部 -->
            <div class="modal-footer">
                <div class="hint">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <span>黄色输入框为可编辑项，灰色为自动生成</span>
                </div>
                <asp:Label ID="Labelmsg" runat="server" CssClass="msg"></asp:Label>
                <asp:Button ID="Btnadd" runat="server" OnClick="Btnadd_Click" Text="➕ 添加学生" CssClass="btn-primary" />
            </div>
        </div>
        <asp:HiddenField ID="HfSavedSnum" runat="server" />
    </form>

    <script type="text/javascript">
        // 点击添加按钮前，将当前学号捕获到隐藏字段中，供校区保存使用
        (function () {
            var btn = document.getElementById('<%= Btnadd.ClientID %>');
            if (btn) {
                btn.addEventListener('click', function () {
                    var snumEl = document.getElementById('<%= Tsnum.ClientID %>');
                    var hfEl   = document.getElementById('<%= HfSavedSnum.ClientID %>');
                    if (snumEl && hfEl) hfEl.value = snumEl.value;
                });
            }
        })();
    </script>
</body>
</html>

