<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadQuizData();
        }
    }
    
    protected void Btnreturn_Click(object sender, EventArgs e)
    {
        Response.Redirect("myquiz.aspx");
    }
    
    private void LoadQuizData()
    {
        string qid = Request.QueryString["qid"];
        
        string connStr = GetConnectionString();
        if (string.IsNullOrEmpty(connStr))
        {
            Labelmsg.Text = "数据库配置错误";
            return;
        }
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 如果没有qid参数，获取今天的测验
                if (string.IsNullOrEmpty(qid))
                {
                    // 获取当前学生信息
                    string currentSid = GetStudentIdFromCookie();
                    string currentGrade = "";
                    string currentClass = "";
                    
                    if (!string.IsNullOrEmpty(currentSid))
                    {
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                            "SELECT Sgrade, Sclass FROM Students WHERE Snum=@snum", conn))
                        {
                            cmd.Parameters.AddWithValue("@snum", currentSid);
                            using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    currentGrade = reader["Sgrade"].ToString();
                                    currentClass = reader["Sclass"].ToString();
                                }
                            }
                        }
                    }
                    
                    // 查找今天的测验（根据年级和班级）
                    string todayQuery = @"
                        SELECT TOP 1 qg.Qid 
                        FROM QuizGrade qg
                        WHERE CONVERT(date, GETDATE()) = CONVERT(date, GETDATE())";
                    
                    if (!string.IsNullOrEmpty(currentGrade))
                    {
                        todayQuery += " AND (qg.Qclass LIKE '%' + @grade + '%' OR qg.Qclass IS NULL)";
                    }
                    
                    todayQuery += " ORDER BY qg.Qid DESC";
                    
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(todayQuery, conn))
                    {
                        if (!string.IsNullOrEmpty(currentGrade))
                        {
                            cmd.Parameters.AddWithValue("@grade", currentGrade);
                        }
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            qid = result.ToString();
                        }
                        else
                        {
                            // 如果没有今天的测验，获取最近的测验
                            using (System.Data.SqlClient.SqlCommand cmd2 = new System.Data.SqlClient.SqlCommand(
                                "SELECT TOP 1 Qid FROM QuizGrade ORDER BY Qid DESC", conn))
                            {
                                result = cmd2.ExecuteScalar();
                                if (result != null)
                                {
                                    qid = result.ToString();
                                }
                            }
                        }
                    }
                }
                
                if (string.IsNullOrEmpty(qid))
                {
                    Labelmsg.Text = "暂无测验数据";
                    Labeltitle.Text = "测验排行榜";
                    PanelNoUntest.Visible = true;
                    return;
                }
                
                // 获取测验标题 - QuizGrade表存储测验信息
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Qobj FROM QuizGrade WHERE Qid=@qid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", qid);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        Labeltitle.Text = "测验 #" + qid + " - 排行榜";
                    }
                    else
                    {
                        Labeltitle.Text = "测验排行榜";
                    }
                }
                
                // 获取已测验学生排行（按成绩降序）- JOIN Students表获取学生信息
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    @"SELECT s.Sgrade, s.Sclass, s.Snum, s.Sname, r.Rscore, r.Rdate
                      FROM Result r
                      INNER JOIN Students s ON r.Rnum = s.Snum
                      WHERE r.Rsid=@qid 
                      ORDER BY r.Rscore DESC, r.Rdate ASC", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", qid);
                    using (System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd))
                    {
                        System.Data.DataTable dt = new System.Data.DataTable();
                        da.Fill(dt);
                        
                        if (dt.Rows.Count > 0)
                        {
                            // 添加序号列
                            dt.Columns.Add("RowNum", typeof(int));
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                dt.Rows[i]["RowNum"] = i + 1;
                            }
                            
                            GridViewclass.DataSource = dt;
                            GridViewclass.DataBind();
                            
                            Labelmsg.Text = string.Format("共有 {0} 位同学参加了测验", dt.Rows.Count);
                        }
                        else
                        {
                            Labelmsg.Text = "暂无同学参加测验";
                        }
                    }
                }
                
                // 获取未测验学生列表
                LoadUntestedStudents(conn, qid);
            }
        }
        catch (Exception ex)
        {
            Labelmsg.Text = "加载数据失败: " + ex.Message;
        }
    }
    
    private void LoadUntestedStudents(System.Data.SqlClient.SqlConnection conn, string qid)
    {
        try
        {
            // 获取当前学生的年级和班级
            string currentSid = GetStudentIdFromCookie();
            string currentGrade = "";
            string currentClass = "";
            
            if (!string.IsNullOrEmpty(currentSid))
            {
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Sgrade, Sclass FROM Students WHERE Snum=@snum", conn))
                {
                    cmd.Parameters.AddWithValue("@snum", currentSid);
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            currentGrade = reader["Sgrade"].ToString();
                            currentClass = reader["Sclass"].ToString();
                        }
                    }
                }
            }
            
            // 查询同年级同班级但未参加测验的学生
            string query = @"
                SELECT s.Snum, s.Sname, s.Sgrade, s.Sclass 
                FROM Students s
                WHERE NOT EXISTS (
                    SELECT 1 FROM Result r 
                    WHERE r.Rsid=@qid AND r.Rnum=s.Snum
                )";
            
            // 如果能获取到当前学生的年级班级，只显示同班同学
            if (!string.IsNullOrEmpty(currentGrade) && !string.IsNullOrEmpty(currentClass))
            {
                query += " AND s.Sgrade=@grade AND s.Sclass=@class";
            }
            
            query += " ORDER BY s.Sgrade, s.Sclass, s.Snum";
            
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@qid", qid);
                if (!string.IsNullOrEmpty(currentGrade) && !string.IsNullOrEmpty(currentClass))
                {
                    cmd.Parameters.AddWithValue("@grade", currentGrade);
                    cmd.Parameters.AddWithValue("@class", currentClass);
                }
                
                using (System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd))
                {
                    System.Data.DataTable dt = new System.Data.DataTable();
                    da.Fill(dt);
                    
                    if (dt.Rows.Count > 0)
                    {
                        RepUntest.DataSource = dt;
                        RepUntest.DataBind();
                        PanelNoUntest.Visible = false;
                    }
                    else
                    {
                        PanelNoUntest.Visible = true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // 如果查询未测验学生失败，显示空状态
            PanelNoUntest.Visible = true;
        }
    }
    
    protected void GridViewclass_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
    {
        if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
        {
            // 设置序号
            if (e.Row.DataItem != null)
            {
                System.Data.DataRowView drv = e.Row.DataItem as System.Data.DataRowView;
                if (drv != null && drv.Row.Table.Columns.Contains("RowNum"))
                {
                    e.Row.Cells[0].Text = drv["RowNum"].ToString();
                }
            }
        }
    }
    
    private string GetConnectionString()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                    cs = connField.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try
            {
                cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }
    
    private string GetStudentIdFromCookie()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    
                    // 尝试获取Snum（学号）
                    System.Reflection.PropertyInfo pSnum = ct.GetProperty("Snum");
                    if (pSnum != null)
                    {
                        object v = pSnum.GetValue(m, null);
                        if (v != null && !string.IsNullOrEmpty(v.ToString())) return v.ToString();
                    }
                    
                    // 如果没有Snum，尝试获取Sid
                    System.Reflection.PropertyInfo pSid = ct.GetProperty("Sid");
                    if (pSid != null)
                    {
                        object v = pSid.GetValue(m, null);
                        if (v != null && !string.IsNullOrEmpty(v.ToString())) return v.ToString();
                    }
                }
            }
        }
        catch { }
        return "";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .qr-page, .qr-page * { margin-right: unset !important; margin-left: unset !important; }
    .qr-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .qr-page { width: 100%; max-width: 1400px; margin: 0 auto !important; padding: 20px; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: qrFadeIn .4s ease; }
    @keyframes qrFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 两栏布局 */
    .qr-layout { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }

    /* 卡片 */
    .qr-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .qr-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .qr-card-head .qr-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; background: linear-gradient(135deg, #fef3c7, #fde68a) !important; }
    .qr-head-icon svg { width: 18px; height: 18px; fill: none; stroke: #d97706 !important; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .qr-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .qr-card-body { padding: 18px 22px; }

    /* 标题标签 */
    .qr-title-wrap { text-align: center; margin-bottom: 18px; }
    .qr-title-wrap .qr-title-label { display: inline-block; padding: 8px 28px; border-radius: 10px; background: linear-gradient(135deg, #f59e0b, #d97706) !important; color: #fff !important; font-size: 15px !important; font-weight: 700; letter-spacing: 1px; box-shadow: 0 2px 8px rgba(217,119,6,.18); }

    /* 表格 */
    .qr-page .qr-card-body table { width: 100% !important; border-collapse: collapse !important; border-spacing: 0 !important; border: none !important; }
    .qr-page .qr-card-body table th { padding: 11px 14px !important; font-size: 12px !important; font-weight: 600 !important; color: #64748b !important; text-align: left !important; letter-spacing: .3px; background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important; border-top: none !important; border-left: none !important; border-right: none !important; font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important; }
    .qr-page .qr-card-body table td { padding: 10px 14px !important; font-size: 13px !important; color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important; border-top: none !important; border-left: none !important; border-right: none !important; background-color: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; vertical-align: middle !important; }
    .qr-page .qr-card-body table tr { background-color: #fff !important; transition: all .12s; }
    .qr-page .qr-card-body table tr:hover td { background-color: #fffbeb !important; }
    .qr-card-body table tr:last-child td { border-bottom: none !important; }

    /* 右侧栏 */
    .qr-sidebar { position: sticky; top: 20px; }
    .qr-sidebar .qr-card-head .qr-head-icon { background: linear-gradient(135deg, #fee2e2, #fecaca) !important; }
    .qr-sidebar .qr-head-icon svg { stroke: #dc2626 !important; }
    
    /* 未测验名单 */
    .qr-untested-list { max-height: 500px; overflow-y: auto; }
    .qr-untested-list::-webkit-scrollbar { width: 5px; }
    .qr-untested-list::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    .qr-untested-item { padding: 12px 16px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 12px; transition: all .15s; }
    .qr-untested-item:hover { background: #fef2f2; margin: 0 -16px; padding: 12px 32px; }
    .qr-untested-item:last-child { border-bottom: none; }
    .qr-untested-avatar { width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #fca5a5, #f87171); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 13px; flex-shrink: 0; }
    .qr-untested-info { flex: 1; }
    .qr-untested-name { font-size: 14px; font-weight: 600; color: #1e293b; }
    .qr-untested-meta { font-size: 12px; color: #94a3b8; margin-top: 2px; }
    .qr-empty { text-align: center; padding: 40px 20px; color: #94a3b8; font-size: 13px; }

    /* 消息 */
    .qr-msg { padding: 10px 0 6px; font-size: 12px; color: #94a3b8; text-align: center; }

    /* 关闭按钮 */
    .qr-actions { text-align: center; padding: 6px 0 2px; }
    .qr-btn-close { display: inline-flex !important; align-items: center; justify-content: center; gap: 6px; padding: 10px 36px !important; border-radius: 10px !important; border: none !important; background: linear-gradient(135deg, #6366f1, #4f46e5) !important; color: #fff !important; font-size: 14px !important; font-weight: 600 !important; cursor: pointer; transition: all .15s; box-shadow: 0 4px 14px rgba(99,102,241,.25); font-family: 'Microsoft YaHei',sans-serif !important; letter-spacing: .5px; }
    .qr-btn-close:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(99,102,241,.35); }
    
    @media (max-width: 1024px) {
        .qr-layout { grid-template-columns: 1fr; }
        .qr-sidebar { position: relative; top: 0; }
    }
</style>

<div class="qr-page">
    <!-- 标题 -->
    <div class="qr-title-wrap">
        <span class="qr-title-label">
            <asp:Label ID="Labeltitle" runat="server" Font-Bold="True"></asp:Label>
        </span>
    </div>

    <!-- 两栏布局 -->
    <div class="qr-layout">
        <!-- 左侧：排行榜 -->
        <div class="qr-main">
            <div class="qr-card">
                <div class="qr-card-head">
                    <span class="qr-head-icon"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                    <h3>测验排行榜</h3>
                </div>
                <div class="qr-card-body">
                    <asp:GridView ID="GridViewclass" runat="server" 
                        AutoGenerateColumns="False"                         
                        OnRowDataBound="GridViewclass_RowDataBound" 
                        Width="100%" TabIndex="1" CellPadding="3" 
                        BackColor="White" BorderColor="#CCCCCC" 
                        BorderStyle="None" BorderWidth="1px" Font-Names="Arial" 
                        Font-Size="9pt" HorizontalAlign="Center" EnableModelValidation="True">
                        <RowStyle ForeColor="#000066" />
                        <Columns>
                            <asp:BoundField HeaderText="序号" />
                            <asp:BoundField DataField="Sgrade" HeaderText="年级" />
                            <asp:BoundField DataField="Sclass" HeaderText="班级" />
                            <asp:BoundField DataField="Snum" HeaderText="学号" />
                            <asp:BoundField DataField="Sname" HeaderText="姓名" />
                            <asp:BoundField DataField="Rscore" HeaderText="成绩" />
                        </Columns>  
                        <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                        <HeaderStyle BackColor="#406B8C" Font-Bold="True" ForeColor="White" />                          
                    </asp:GridView>
                </div>
            </div>
            
            <!-- 消息 & 关闭 -->
            <div class="qr-msg">
                <asp:Label ID="Labelmsg" runat="server" Font-Size="9pt"></asp:Label>
            </div>
            <div class="qr-actions">
                <asp:Button ID="Btnreturn" runat="server" Text="关闭" CssClass="qr-btn-close" OnClick="Btnreturn_Click" />
            </div>
        </div>
        
        <!-- 右侧：未测验同学 -->
        <div class="qr-sidebar">
            <div class="qr-card">
                <div class="qr-card-head">
                    <span class="qr-head-icon"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                    <h3>未测验同学</h3>
                </div>
                <div class="qr-card-body">
                    <div class="qr-untested-list">
                        <asp:Repeater ID="RepUntest" runat="server">
                            <ItemTemplate>
                                <div class="qr-untested-item">
                                    <div class="qr-untested-avatar"><%# Eval("Sname").ToString().Substring(0, 1) %></div>
                                    <div class="qr-untested-info">
                                        <div class="qr-untested-name"><%# Eval("Sname") %></div>
                                        <div class="qr-untested-meta"><%# Eval("Sgrade") %>年级<%# Eval("Sclass") %>班 · <%# Eval("Snum") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="PanelNoUntest" runat="server" Visible="false">
                            <div class="qr-empty">✓ 全部同学已完成测验</div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>
