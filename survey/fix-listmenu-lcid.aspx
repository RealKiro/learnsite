<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string connStr = "";
        try
        {
            connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch (Exception ex)
        {
            Response.Write("<p style='color:red;'>数据库配置错误: " + Server.HtmlEncode(ex.Message) + "</p>");
            return;
        }
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                Response.Write("<h2>🔧 修复 Listmenu 表的 Lcid 字段</h2>");
                Response.Write("<p>将调查问卷任务的课程ID与SurveyQuestion表中的Qcid字段同步</p>");
                Response.Write("<hr/>");
                
                // 步骤1：查看当前状态
                Response.Write("<h3>步骤1：当前状态</h3>");
                string checkSql = @"
                    SELECT 
                        L.Lid,
                        L.Lcid AS CurrentCid,
                        L.Lxid AS Qvid,
                        L.Ltitle,
                        Q.Qcid AS CorrectCid
                    FROM Listmenu L
                    LEFT JOIN (
                        SELECT DISTINCT Qvid, Qcid 
                        FROM SurveyQuestion
                    ) Q ON L.Lxid = Q.Qvid
                    WHERE L.Ltype = '14'
                    ORDER BY L.Lid
                ";
                
                Response.Write("<table border='1' cellpadding='5' style='border-collapse:collapse;'>");
                Response.Write("<tr style='background:#f0f0f0;'><th>Lid</th><th>当前Lcid</th><th>问卷ID</th><th>标题</th><th>正确的Qcid</th><th>状态</th></tr>");
                
                int totalCount = 0;
                int wrongCount = 0;
                
                using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                {
                    using (SqlDataReader reader = checkCmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            totalCount++;
                            int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                            int currentCid = reader["CurrentCid"] != DBNull.Value ? Convert.ToInt32(reader["CurrentCid"]) : 0;
                            int qvid = reader["Qvid"] != DBNull.Value ? Convert.ToInt32(reader["Qvid"]) : 0;
                            int correctCid = reader["CorrectCid"] != DBNull.Value ? Convert.ToInt32(reader["CorrectCid"]) : 0;
                            
                            string ltitle = "";
                            if (reader["Ltitle"] != DBNull.Value)
                            {
                                byte[] bytes = reader["Ltitle"] as byte[];
                                if (bytes != null)
                                    ltitle = System.Text.Encoding.Unicode.GetString(bytes);
                                else
                                    ltitle = reader["Ltitle"].ToString();
                            }
                            
                            bool isCorrect = (currentCid == correctCid && currentCid > 0);
                            if (!isCorrect) wrongCount++;
                            
                            string statusColor = isCorrect ? "green" : "red";
                            string statusText = isCorrect ? "✓ 正确" : "✗ 需要修复";
                            
                            Response.Write("<tr>");
                            Response.Write("<td>" + lid + "</td>");
                            Response.Write("<td>" + currentCid + "</td>");
                            Response.Write("<td>" + qvid + "</td>");
                            Response.Write("<td>" + Server.HtmlEncode(ltitle) + "</td>");
                            Response.Write("<td>" + correctCid + "</td>");
                            Response.Write("<td style='color:" + statusColor + ";font-weight:bold;'>" + statusText + "</td>");
                            Response.Write("</tr>");
                        }
                    }
                }
                Response.Write("</table>");
                Response.Write("<p><strong>统计：</strong> 总记录数: " + totalCount + ", 需要修复: " + wrongCount + "</p>");
                
                if (wrongCount == 0)
                {
                    Response.Write("<p style='color:green;font-size:18px;'><strong>✓ 所有记录都正确，无需修复！</strong></p>");
                    return;
                }
                
                // 步骤2：执行修复
                Response.Write("<hr/>");
                Response.Write("<h3>步骤2：执行修复</h3>");
                
                string updateSql = @"
                    UPDATE L
                    SET L.Lcid = Q.Qcid
                    FROM Listmenu L
                    INNER JOIN (
                        SELECT DISTINCT Qvid, Qcid 
                        FROM SurveyQuestion
                    ) Q ON L.Lxid = Q.Qvid
                    WHERE L.Ltype = '14'
                      AND (L.Lcid IS NULL OR L.Lcid <> Q.Qcid)
                ";
                
                using (SqlCommand updateCmd = new SqlCommand(updateSql, conn))
                {
                    int affectedRows = updateCmd.ExecuteNonQuery();
                    Response.Write("<p style='color:green;'><strong>✓ 修复完成！</strong> 更新了 " + affectedRows + " 条记录</p>");
                }
                
                // 步骤3：验证修复结果
                Response.Write("<hr/>");
                Response.Write("<h3>步骤3：验证修复结果</h3>");
                
                Response.Write("<table border='1' cellpadding='5' style='border-collapse:collapse;'>");
                Response.Write("<tr style='background:#f0f0f0;'><th>Lid</th><th>Lcid</th><th>问卷ID</th><th>标题</th><th>Qcid</th><th>状态</th></tr>");
                
                int verifyCorrect = 0;
                int verifyWrong = 0;
                
                using (SqlCommand verifyCmd = new SqlCommand(checkSql, conn))
                {
                    using (SqlDataReader reader = verifyCmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                            int currentCid = reader["CurrentCid"] != DBNull.Value ? Convert.ToInt32(reader["CurrentCid"]) : 0;
                            int qvid = reader["Qvid"] != DBNull.Value ? Convert.ToInt32(reader["Qvid"]) : 0;
                            int correctCid = reader["CorrectCid"] != DBNull.Value ? Convert.ToInt32(reader["CorrectCid"]) : 0;
                            
                            string ltitle = "";
                            if (reader["Ltitle"] != DBNull.Value)
                            {
                                byte[] bytes = reader["Ltitle"] as byte[];
                                if (bytes != null)
                                    ltitle = System.Text.Encoding.Unicode.GetString(bytes);
                                else
                                    ltitle = reader["Ltitle"].ToString();
                            }
                            
                            bool isCorrect = (currentCid == correctCid && currentCid > 0);
                            if (isCorrect) verifyCorrect++; else verifyWrong++;
                            
                            string statusColor = isCorrect ? "green" : "red";
                            string statusText = isCorrect ? "✓ 正确" : "✗ 错误";
                            
                            Response.Write("<tr>");
                            Response.Write("<td>" + lid + "</td>");
                            Response.Write("<td>" + currentCid + "</td>");
                            Response.Write("<td>" + qvid + "</td>");
                            Response.Write("<td>" + Server.HtmlEncode(ltitle) + "</td>");
                            Response.Write("<td>" + correctCid + "</td>");
                            Response.Write("<td style='color:" + statusColor + ";font-weight:bold;'>" + statusText + "</td>");
                            Response.Write("</tr>");
                        }
                    }
                }
                Response.Write("</table>");
                
                Response.Write("<hr/>");
                Response.Write("<h3>✓ 修复完成！</h3>");
                Response.Write("<p><strong>验证结果：</strong> 正确: " + verifyCorrect + ", 错误: " + verifyWrong + "</p>");
                
                if (verifyWrong == 0)
                {
                    Response.Write("<p style='color:green;font-size:18px;'><strong>🎉 所有记录已修复成功！</strong></p>");
                    Response.Write("<p><a href='../student/surveyshow.aspx?sid=2&cid=4'>测试问卷页面</a></p>");
                }
                else
                {
                    Response.Write("<p style='color:red;font-size:18px;'><strong>⚠ 仍有 " + verifyWrong + " 条记录未修复</strong></p>");
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("<h2 style='color:red;'>✗ 错误</h2>");
            Response.Write("<p style='color:red;'>" + Server.HtmlEncode(ex.Message) + "</p>");
            Response.Write("<pre>" + Server.HtmlEncode(ex.StackTrace) + "</pre>");
        }
    }
</script>

<!DOCTYPE html>
<html>
<head>
    <title>修复 Listmenu 的 Lcid 字段</title>
    <style>
        body {
            font-family: 'Microsoft YaHei', Arial, sans-serif;
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        table {
            margin: 10px 0;
            width: 100%;
        }
        th {
            background: #f0f0f0;
            text-align: left;
            padding: 8px;
        }
        td {
            padding: 8px;
        }
        hr {
            margin: 20px 0;
            border: none;
            border-top: 2px solid #e0e0e0;
        }
    </style>
</head>
<body>
</body>
</html>
