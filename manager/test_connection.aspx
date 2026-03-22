<%@ Page Language="C#" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<html>
<head>
    <title>数据库连接测试</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial; padding: 20px; background: #f5f5f5; }
        .box { background: white; padding: 20px; border-radius: 8px; margin: 10px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .ok { color: #059669; }
        .err { color: #dc2626; }
        pre { background: #f8fafc; padding: 10px; border-radius: 4px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>数据库连接诊断</h1>
    
    <div class="box">
        <h3>1. 检查连接字符串配置</h3>
        <%
        try
        {
            if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
            {
                string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
                if (string.IsNullOrEmpty(connStr))
                {
                    Response.Write("<p class='err'>✗ 连接字符串存在但为空</p>");
                }
                else
                {
                    Response.Write("<p class='ok'>✓ 连接字符串已配置</p>");
                    // 隐藏密码显示
                    string display = connStr;
                    if (display.ToLower().Contains("password="))
                    {
                        int start = display.ToLower().IndexOf("password=");
                        int end = display.IndexOf(";", start);
                        if (end < 0) end = display.Length;
                        display = display.Substring(0, start) + "Password=***" + (end < display.Length ? display.Substring(end) : "");
                    }
                    Response.Write("<pre>" + Server.HtmlEncode(display) + "</pre>");
                }
            }
            else
            {
                Response.Write("<p class='err'>✗ 未找到 SqlServer 连接字符串配置</p>");
                Response.Write("<p>请检查 Web.config 文件中是否包含：</p>");
                Response.Write("<pre>&lt;connectionStrings&gt;\n  &lt;add name=\"SqlServer\" connectionString=\"...\" /&gt;\n&lt;/connectionStrings&gt;</pre>");
            }
        }
        catch (Exception ex)
        {
            Response.Write("<p class='err'>✗ 读取配置出错：" + Server.HtmlEncode(ex.Message) + "</p>");
        }
        %>
    </div>

    <div class="box">
        <h3>2. 测试数据库连接</h3>
        <%
        try
        {
            if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
            {
                string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
                if (!string.IsNullOrEmpty(connStr))
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        Response.Write("<p class='ok'>✓ 数据库连接成功</p>");
                        
                        SqlCommand cmd = new SqlCommand("SELECT @@VERSION", conn);
                        string version = cmd.ExecuteScalar().ToString();
                        Response.Write("<p>数据库版本：</p><pre>" + Server.HtmlEncode(version.Substring(0, Math.Min(200, version.Length))) + "</pre>");
                    }
                }
                else
                {
                    Response.Write("<p class='err'>连接字符串为空，无法测试</p>");
                }
            }
            else
            {
                Response.Write("<p class='err'>连接字符串未配置，无法测试</p>");
            }
        }
        catch (Exception ex)
        {
            Response.Write("<p class='err'>✗ 数据库连接失败：" + Server.HtmlEncode(ex.Message) + "</p>");
        }
        %>
    </div>

    <div class="box">
        <h3>3. 检查 Teacher 表</h3>
        <%
        try
        {
            if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
            {
                string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
                if (!string.IsNullOrEmpty(connStr))
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        
                        // 检查表是否存在
                        SqlCommand checkTable = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Teacher'", conn);
                        int tableExists = (int)checkTable.ExecuteScalar();
                        
                        if (tableExists > 0)
                        {
                            Response.Write("<p class='ok'>✓ Teacher 表存在</p>");
                            
                            // 检查是否有 Hemail 字段
                            SqlCommand checkCol = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Teacher' AND COLUMN_NAME='Hemail'", conn);
                            int colExists = (int)checkCol.ExecuteScalar();
                            
                            if (colExists > 0)
                            {
                                Response.Write("<p class='ok'>✓ Hemail 字段存在</p>");
                                
                                // 统计有邮箱的教师数量
                                SqlCommand countCmd = new SqlCommand("SELECT COUNT(*) FROM Teacher WHERE Hemail IS NOT NULL AND Hemail != ''", conn);
                                int emailCount = (int)countCmd.ExecuteScalar();
                                Response.Write("<p>已绑定邮箱的教师数量：" + emailCount + "</p>");
                            }
                            else
                            {
                                Response.Write("<p class='err'>✗ Hemail 字段不存在</p>");
                            }
                        }
                        else
                        {
                            Response.Write("<p class='err'>✗ Teacher 表不存在</p>");
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("<p class='err'>✗ 检查失败：" + Server.HtmlEncode(ex.Message) + "</p>");
        }
        %>
    </div>

    <div class="box">
        <h3>4. 测试用户查询</h3>
        <%
        try
        {
            if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
            {
                string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
                if (!string.IsNullOrEmpty(connStr))
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand("SELECT TOP 1 Hname, Hemail FROM Teacher WHERE Hemail IS NOT NULL AND Hemail != ''", conn);
                        SqlDataReader reader = cmd.ExecuteReader();
                        
                        if (reader.Read())
                        {
                            string username = reader["Hname"].ToString();
                            string email = reader["Hemail"].ToString();
                            Response.Write("<p class='ok'>✓ 找到测试用户</p>");
                            Response.Write("<p>用户名：" + Server.HtmlEncode(username) + "</p>");
                            Response.Write("<p>邮箱：" + Server.HtmlEncode(email) + "</p>");
                        }
                        else
                        {
                            Response.Write("<p class='err'>✗ 没有找到已绑定邮箱的用户</p>");
                        }
                        reader.Close();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("<p class='err'>✗ 查询失败：" + Server.HtmlEncode(ex.Message) + "</p>");
        }
        %>
    </div>

    <div class="box">
        <p><a href="forgotpwd.aspx">返回找回密码页面</a></p>
    </div>
</body>
</html>
