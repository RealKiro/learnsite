<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<html>
<head>
    <title>测试作品数据</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
        h2 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #4CAF50; color: white; }
        tr:hover { background: #f5f5f5; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .error { background: #ffebee; padding: 15px; border-radius: 5px; margin: 10px 0; color: #c62828; }
        .success { background: #e8f5e9; padding: 15px; border-radius: 5px; margin: 10px 0; color: #2e7d32; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🔍 作品数据测试页面</h2>
        
        <%
        string connStr = "";
        try
        {
            // 获取连接字符串
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                    connStr = connField.GetValue(null) as string;
            }
            if (string.IsNullOrEmpty(connStr))
            {
                connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            
            Response.Write("<div class='success'>✓ 数据库连接字符串获取成功</div>");
            
            // 获取URL参数
            string yid = Request.QueryString["yid"];
            Response.Write("<div class='info'><strong>URL参数 yid:</strong> " + (string.IsNullOrEmpty(yid) ? "(空)" : yid) + "</div>");
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                Response.Write("<div class='success'>✓ 数据库连接成功</div>");
                
                // 先查询所有表名
                Response.Write("<h3>📊 数据库中的所有表</h3>");
                string sqlTables = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME LIKE '%utonomic%' OR TABLE_NAME LIKE '%category%' ORDER BY TABLE_NAME";
                using (SqlCommand cmd = new SqlCommand(sqlTables, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Response.Write("<table><tr><th>表名</th></tr>");
                        while (reader.Read())
                        {
                            Response.Write("<tr><td>" + reader["TABLE_NAME"] + "</td></tr>");
                        }
                        Response.Write("</table>");
                    }
                }
                
                // 尝试查询可能的表名
                string[] possibleTables = new string[] { 
                    "AutonomicCategory", "Autonomic_Category", "autonomiccategory", 
                    "YCategory", "Ycategory", "Category", "FileCategory"
                };
                
                foreach (string tableName in possibleTables)
                {
                    try
                    {
                        string testSql = "SELECT TOP 1 * FROM " + tableName;
                        using (SqlCommand cmd = new SqlCommand(testSql, conn))
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                Response.Write("<div class='success'>✓ 找到表: " + tableName + "</div>");
                                break;
                            }
                        }
                    }
                    catch { }
                }
                
                // 查询Autonomic表结构
                Response.Write("<h3>📋 Autonomic表结构</h3>");
                string sqlColumns = "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Autonomic' ORDER BY ORDINAL_POSITION";
                using (SqlCommand cmd = new SqlCommand(sqlColumns, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Response.Write("<table><tr><th>列名</th><th>数据类型</th></tr>");
                        while (reader.Read())
                        {
                            Response.Write("<tr><td>" + reader["COLUMN_NAME"] + "</td><td>" + reader["DATA_TYPE"] + "</td></tr>");
                        }
                        Response.Write("</table>");
                    }
                }
                
                // 查询Autonomic表的前10条数据
                Response.Write("<h3>📄 Autonomic表数据示例</h3>");
                string sqlData = "SELECT TOP 10 * FROM Autonomic ORDER BY Aid DESC";
                using (SqlCommand cmd = new SqlCommand(sqlData, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            Response.Write("<table><tr>");
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                Response.Write("<th>" + reader.GetName(i) + "</th>");
                            }
                            Response.Write("</tr>");
                            
                            while (reader.Read())
                            {
                                Response.Write("<tr>");
                                for (int i = 0; i < reader.FieldCount; i++)
                                {
                                    Response.Write("<td>" + (reader.IsDBNull(i) ? "NULL" : reader[i].ToString()) + "</td>");
                                }
                                Response.Write("</tr>");
                            }
                            Response.Write("</table>");
                        }
                        else
                        {
                            Response.Write("<div class='info'>Autonomic表中没有数据</div>");
                        }
                    }
                }
                
                // 查询作品分类表
                Response.Write("<h3>📁 作品分类表 (AutonomicCategory)</h3>");
                string sql1 = "SELECT TOP 10 * FROM AutonomicCategory ORDER BY Yid";
                using (SqlCommand cmd = new SqlCommand(sql1, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            Response.Write("<table><tr><th>Yid</th><th>Ytitle</th><th>Yorder</th></tr>");
                            while (reader.Read())
                            {
                                Response.Write("<tr>");
                                Response.Write("<td>" + reader["Yid"] + "</td>");
                                Response.Write("<td>" + reader["Ytitle"] + "</td>");
                                Response.Write("<td>" + (reader["Yorder"] != DBNull.Value ? reader["Yorder"].ToString() : "NULL") + "</td>");
                                Response.Write("</tr>");
                            }
                            Response.Write("</table>");
                        }
                        else
                        {
                            Response.Write("<div class='info'>表存在但没有数据</div>");
                        }
                    }
                }
                
                // 如果有yid参数，查询该分类下的作品
                if (!string.IsNullOrEmpty(yid))
                {
                    Response.Write("<h3>📄 分类 " + yid + " 下的作品</h3>");
                    // 先检查Autonomic表中有哪些列
                    string sqlCheckColumns = "SELECT TOP 1 * FROM Autonomic";
                    try
                    {
                        using (SqlCommand cmdCheck = new SqlCommand(sqlCheckColumns, conn))
                        {
                            using (SqlDataReader readerCheck = cmdCheck.ExecuteReader())
                            {
                                if (readerCheck.Read())
                                {
                                    Response.Write("<div class='info'>Autonomic表的列: ");
                                    for (int i = 0; i < readerCheck.FieldCount; i++)
                                    {
                                        Response.Write(readerCheck.GetName(i) + " ");
                                    }
                                    Response.Write("</div>");
                                }
                                else
                                {
                                    Response.Write("<div class='info'>Autonomic表中没有数据</div>");
                                }
                            }
                        }
                        
                        // 使用实际存在的列名查询
                        string sql2 = "SELECT TOP 10 Aid, Aname, Adate FROM Autonomic WHERE Ayid=" + yid + " ORDER BY Aid DESC";
                        using (SqlCommand cmd = new SqlCommand(sql2, conn))
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows)
                                {
                                    Response.Write("<table><tr><th>Aid</th><th>姓名</th><th>日期</th></tr>");
                                    while (reader.Read())
                                    {
                                        Response.Write("<tr>");
                                        Response.Write("<td>" + reader["Aid"] + "</td>");
                                        Response.Write("<td>" + (reader["Aname"] != DBNull.Value ? HttpUtility.UrlDecode(reader["Aname"].ToString()) : "") + "</td>");
                                        Response.Write("<td>" + (reader["Adate"] != DBNull.Value ? reader["Adate"].ToString() : "") + "</td>");
                                        Response.Write("</tr>");
                                    }
                                    Response.Write("</table>");
                                }
                                else
                                {
                                    Response.Write("<div class='info'>该分类下没有作品</div>");
                                }
                            }
                        }
                    }
                    catch (Exception ex2)
                    {
                        Response.Write("<div class='error'>查询作品时出错: " + ex2.Message + "</div>");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("<div class='error'><strong>错误:</strong> " + ex.Message + "</div>");
            if (ex.InnerException != null)
            {
                Response.Write("<div class='error'><strong>内部错误:</strong> " + ex.InnerException.Message + "</div>");
            }
        }
        %>
        
        <div style="margin-top: 20px; padding: 15px; background: #f5f5f5; border-radius: 5px;">
            <strong>测试链接:</strong><br/>
            <a href="?yid=1" style="color: #2196F3; text-decoration: none;">测试 yid=1</a> | 
            <a href="?yid=2" style="color: #2196F3; text-decoration: none;">测试 yid=2</a> | 
            <a href="autonomiccategory.aspx?yid=1" style="color: #4CAF50; text-decoration: none;">打开 autonomiccategory.aspx?yid=1</a>
        </div>
    </div>
</body>
</html>
