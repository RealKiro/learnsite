<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<!DOCTYPE html>
<html>
<head>
    <title>教师编辑调试</title>
</head>
<body>
    <h1>教师编辑调试页面</h1>
    
    <form runat="server">
        <div style="padding: 20px; background: #f0f0f0; margin: 20px;">
            <h2>调试信息</h2>
            <asp:Label ID="lblDebug" runat="server"></asp:Label>
        </div>
        
        <div style="padding: 20px;">
            <h2>教师信息</h2>
            <p>姓名：<asp:TextBox ID="txtName" runat="server"></asp:TextBox></p>
            <p>昵称：<asp:TextBox ID="txtNick" runat="server"></asp:TextBox></p>
            <p>邮箱：<asp:TextBox ID="txtEmail" runat="server"></asp:TextBox></p>
            <p><asp:Button ID="btnTest" runat="server" Text="测试加载" OnClick="BtnTest_Click" /></p>
        </div>
    </form>
    
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                System.Text.StringBuilder debug = new System.Text.StringBuilder();
                
                // 检查 QueryString
                debug.Append("<p><strong>QueryString hid:</strong> ");
                debug.Append(Request.QueryString["hid"] ?? "(null)");
                debug.Append("</p>");
                
                // 检查数据库连接
                try
                {
                    // 尝试多个连接字符串名称
                    ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
                    if (connStrConfig == null)
                    {
                        connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
                    }
                    
                    if (connStrConfig == null)
                    {
                        debug.Append("<p style='color:red;'><strong>✗ 错误: 未找到数据库连接字符串配置</strong></p>");
                        debug.Append("<p>请检查 Web.config 文件中的 &lt;connectionStrings&gt; 配置</p>");
                        debug.Append("<p>需要配置名为 'constr' 或 'SqlServer' 的连接字符串</p>");
                        
                        // 列出所有可用的连接字符串
                        debug.Append("<p><strong>当前可用的连接字符串:</strong></p><ul>");
                        if (ConfigurationManager.ConnectionStrings.Count > 0)
                        {
                            foreach (ConnectionStringSettings css in ConfigurationManager.ConnectionStrings)
                            {
                                debug.Append("<li>" + css.Name + "</li>");
                            }
                        }
                        else
                        {
                            debug.Append("<li>(无)</li>");
                        }
                        debug.Append("</ul>");
                        
                        lblDebug.Text = debug.ToString();
                        return;
                    }
                    
                    string connStr = connStrConfig.ConnectionString;
                    debug.Append("<p><strong>使用连接字符串:</strong> " + connStrConfig.Name + "</p>");
                    debug.Append("<p><strong>连接字符串内容:</strong> " + connStr.Substring(0, Math.Min(50, connStr.Length)) + "...</p>");
                    
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        debug.Append("<p style='color:green;'><strong>✓ 数据库连接成功</strong></p>");
                        
                        // 检查 Teacher 表
                        SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Teacher", conn);
                        int count = (int)cmd.ExecuteScalar();
                        debug.Append("<p><strong>Teacher 表记录数:</strong> " + count + "</p>");
                        
                        // 检查 Hemail 字段
                        SqlCommand cmdCheck = new SqlCommand(@"
                            SELECT COUNT(*) 
                            FROM INFORMATION_SCHEMA.COLUMNS 
                            WHERE TABLE_NAME = 'Teacher' 
                            AND COLUMN_NAME = 'Hemail'", conn);
                        int hasEmail = (int)cmdCheck.ExecuteScalar();
                        debug.Append("<p><strong>Hemail 字段:</strong> " + (hasEmail > 0 ? "存在" : "不存在") + "</p>");
                        
                        // 检查 Hdelete 字段
                        SqlCommand cmdCheckDelete = new SqlCommand(@"
                            SELECT COUNT(*) 
                            FROM INFORMATION_SCHEMA.COLUMNS 
                            WHERE TABLE_NAME = 'Teacher' 
                            AND COLUMN_NAME = 'Hdelete'", conn);
                        int hasDelete = (int)cmdCheckDelete.ExecuteScalar();
                        debug.Append("<p><strong>Hdelete 字段:</strong> " + (hasDelete > 0 ? "存在" : "不存在") + "</p>");
                        
                        // 尝试读取指定教师
                        int hid = 0;
                        if (Request.QueryString["hid"] != null)
                        {
                            int.TryParse(Request.QueryString["hid"], out hid);
                        }
                        
                        if (hid > 0)
                        {
                            // 首先查询不带 Hdelete 过滤的记录
                            string sqlAll = hasEmail > 0 
                                ? "SELECT Hid, Hname, Hnick, Hemail" + (hasDelete > 0 ? ", Hdelete" : "") + " FROM Teacher WHERE Hid=@hid"
                                : "SELECT Hid, Hname, Hnick" + (hasDelete > 0 ? ", Hdelete" : "") + " FROM Teacher WHERE Hid=@hid";
                            
                            debug.Append("<p><strong>SQL 查询（不过滤）:</strong> " + sqlAll + "</p>");
                            
                            SqlCommand cmdAll = new SqlCommand(sqlAll, conn);
                            cmdAll.Parameters.AddWithValue("@hid", hid);
                            
                            SqlDataReader readerAll = cmdAll.ExecuteReader();
                            if (readerAll.Read())
                            {
                                debug.Append("<p style='color:blue;'><strong>✓ 找到教师记录（不过滤删除标志）</strong></p>");
                                debug.Append("<p><strong>Hid:</strong> " + readerAll["Hid"] + "</p>");
                                debug.Append("<p><strong>Hname:</strong> " + readerAll["Hname"] + "</p>");
                                debug.Append("<p><strong>Hnick:</strong> " + (readerAll["Hnick"] != DBNull.Value ? readerAll["Hnick"].ToString() : "(null)") + "</p>");
                                if (hasEmail > 0)
                                {
                                    debug.Append("<p><strong>Hemail:</strong> " + (readerAll["Hemail"] != DBNull.Value ? readerAll["Hemail"].ToString() : "(null)") + "</p>");
                                }
                                if (hasDelete > 0)
                                {
                                    object deleteVal = readerAll["Hdelete"];
                                    debug.Append("<p><strong>Hdelete:</strong> " + (deleteVal != DBNull.Value ? deleteVal.ToString() : "(null)") + "</p>");
                                    
                                    if (deleteVal != DBNull.Value && Convert.ToBoolean(deleteVal))
                                    {
                                        debug.Append("<p style='color:orange;'><strong>⚠ 该教师已被标记为删除！</strong></p>");
                                    }
                                }
                            }
                            else
                            {
                                debug.Append("<p style='color:red;'><strong>✗ 数据库中不存在 Hid=" + hid + " 的记录</strong></p>");
                            }
                            readerAll.Close();
                            
                            // 再查询带 Hdelete 过滤的记录
                            string sql = hasEmail > 0 
                                ? "SELECT Hid, Hname, Hnick, Hemail FROM Teacher WHERE Hid=@hid"
                                : "SELECT Hid, Hname, Hnick FROM Teacher WHERE Hid=@hid";
                            
                            // 如果有 Hdelete 字段，添加过滤条件
                            if (hasDelete > 0)
                            {
                                sql += " AND (Hdelete=0 OR Hdelete IS NULL)";
                            }
                            
                            debug.Append("<p><strong>SQL 查询（过滤删除）:</strong> " + sql + "</p>");
                            
                            SqlCommand cmdGet = new SqlCommand(sql, conn);
                            cmdGet.Parameters.AddWithValue("@hid", hid);
                            
                            SqlDataReader reader = cmdGet.ExecuteReader();
                            if (reader.Read())
                            {
                                debug.Append("<p style='color:green;'><strong>✓ 找到有效教师记录（未删除）</strong></p>");
                                debug.Append("<p><strong>Hid:</strong> " + reader["Hid"] + "</p>");
                                debug.Append("<p><strong>Hname:</strong> " + reader["Hname"] + "</p>");
                                debug.Append("<p><strong>Hnick:</strong> " + (reader["Hnick"] != DBNull.Value ? reader["Hnick"].ToString() : "(null)") + "</p>");
                                if (hasEmail > 0)
                                {
                                    debug.Append("<p><strong>Hemail:</strong> " + (reader["Hemail"] != DBNull.Value ? reader["Hemail"].ToString() : "(null)") + "</p>");
                                }
                                
                                // 填充表单
                                txtName.Text = reader["Hname"].ToString();
                                txtNick.Text = reader["Hnick"] != DBNull.Value ? reader["Hnick"].ToString() : "";
                                if (hasEmail > 0)
                                {
                                    txtEmail.Text = reader["Hemail"] != DBNull.Value ? reader["Hemail"].ToString() : "";
                                }
                            }
                            else
                            {
                                debug.Append("<p style='color:red;'><strong>✗ 未找到有效的教师记录（可能已被删除）</strong></p>");
                            }
                            reader.Close();
                        }
                    }
                }
                catch (Exception ex)
                {
                    debug.Append("<p style='color:red;'><strong>错误:</strong> " + ex.Message + "</p>");
                    debug.Append("<p><strong>堆栈:</strong> " + ex.StackTrace + "</p>");
                }
                
                lblDebug.Text = debug.ToString();
            }
        }
        
        protected void BtnTest_Click(object sender, EventArgs e)
        {
            lblDebug.Text = "<p style='color:blue;'>测试按钮被点击</p>" +
                           "<p>姓名: " + txtName.Text + "</p>" +
                           "<p>昵称: " + txtNick.Text + "</p>" +
                           "<p>邮箱: " + txtEmail.Text + "</p>";
        }
    </script>
</body>
</html>
