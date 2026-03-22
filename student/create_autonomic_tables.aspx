<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<html>
<head>
    <title>创建作品分类表</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
        h2 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        .success { background: #e8f5e9; padding: 15px; border-radius: 5px; margin: 10px 0; color: #2e7d32; }
        .error { background: #ffebee; padding: 15px; border-radius: 5px; margin: 10px 0; color: #c62828; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .btn { display: inline-block; padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
        .btn:hover { background: #45a049; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🔧 创建作品分类表</h2>
        
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
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查表是否存在
                string checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='AutonomicCategory'";
                using (SqlCommand cmd = new SqlCommand(checkTableSql, conn))
                {
                    int tableExists = (int)cmd.ExecuteScalar();
                    
                    if (tableExists > 0)
                    {
                        Response.Write("<div class='info'>ℹ️ AutonomicCategory表已存在</div>");
                    }
                    else
                    {
                        // 创建AutonomicCategory表
                        string createTableSql = @"
                            CREATE TABLE AutonomicCategory (
                                Yid INT IDENTITY(1,1) PRIMARY KEY,
                                Ytitle NVARCHAR(100) NOT NULL,
                                Yorder INT DEFAULT 0
                            )
                        ";
                        
                        using (SqlCommand createCmd = new SqlCommand(createTableSql, conn))
                        {
                            createCmd.ExecuteNonQuery();
                            Response.Write("<div class='success'>✓ 成功创建AutonomicCategory表</div>");
                        }
                        
                        // 插入示例分类数据
                        string[] categories = new string[] {
                            "Scratch作品", "Python作品", "C++作品", "网页设计", 
                            "图形设计", "视频制作", "音乐创作", "其他作品"
                        };
                        
                        for (int i = 0; i < categories.Length; i++)
                        {
                            string insertSql = "INSERT INTO AutonomicCategory (Ytitle, Yorder) VALUES (@title, @order)";
                            using (SqlCommand insertCmd = new SqlCommand(insertSql, conn))
                            {
                                insertCmd.Parameters.AddWithValue("@title", categories[i]);
                                insertCmd.Parameters.AddWithValue("@order", i + 1);
                                insertCmd.ExecuteNonQuery();
                            }
                        }
                        
                        Response.Write("<div class='success'>✓ 成功插入 " + categories.Length + " 个示例分类</div>");
                    }
                }
                
                // 显示当前分类
                Response.Write("<h3>📁 当前作品分类列表</h3>");
                Response.Write("<table style='width:100%; border-collapse:collapse; margin:20px 0;'>");
                Response.Write("<tr style='background:#4CAF50; color:white;'><th style='padding:10px; text-align:left;'>ID</th><th style='padding:10px; text-align:left;'>分类名称</th><th style='padding:10px; text-align:left;'>排序</th></tr>");
                
                string selectSql = "SELECT Yid, Ytitle, Yorder FROM AutonomicCategory ORDER BY Yorder";
                using (SqlCommand cmd = new SqlCommand(selectSql, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Response.Write("<tr style='border-bottom:1px solid #ddd;'>");
                            Response.Write("<td style='padding:10px;'>" + reader["Yid"] + "</td>");
                            Response.Write("<td style='padding:10px;'>" + reader["Ytitle"] + "</td>");
                            Response.Write("<td style='padding:10px;'>" + reader["Yorder"] + "</td>");
                            Response.Write("</tr>");
                        }
                    }
                }
                Response.Write("</table>");
            }
            
            Response.Write("<div class='success'>✓ 操作完成！现在可以使用作品分类功能了。</div>");
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
        
        <div style="margin-top: 20px;">
            <a href="test_autonomic_data.aspx?yid=1" class="btn">📊 测试数据页面</a>
            <a href="autonomiccategory.aspx?yid=1" class="btn">🏠 查看作品分类</a>
            <a href="autonomic.aspx" class="btn">🎨 作品园</a>
        </div>
    </div>
</body>
</html>
