<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<!DOCTYPE html>
<html>
<head>
    <title>测试教师数据</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .error { background: #ffebee; padding: 15px; border-radius: 5px; margin-bottom: 20px; color: #c62828; }
    </style>
</head>
<body>
    <h1>教师数据测试页面</h1>
    
<%
    try
    {
        ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
        if (connStrConfig == null)
        {
            connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
        }
        
        if (connStrConfig == null)
        {
            Response.Write("<div class='error'>错误：未找到数据库连接配置</div>");
            return;
        }
        
        string connStr = connStrConfig.ConnectionString;
        Response.Write("<div class='info'><strong>连接字符串：</strong>" + Server.HtmlEncode(connStr) + "</div>");
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            Response.Write("<div class='info'><strong>数据库连接：</strong>成功</div>");
            
            // 查询教师总数
            string countSql = "SELECT COUNT(*) FROM Teacher";
            SqlCommand cmdCount = new SqlCommand(countSql, conn);
            int totalCount = (int)cmdCount.ExecuteScalar();
            Response.Write("<div class='info'><strong>教师总数：</strong>" + totalCount + "</div>");
            
            // 查询教师数据
            string sql = "SELECT TOP 20 Hid, Hname, Hnick, Hpwd, Hpermiss, Hnote, Hcount FROM Teacher ORDER BY Hid";
            SqlCommand cmd = new SqlCommand(sql, conn);
            SqlDataReader reader = cmd.ExecuteReader();
            
            Response.Write("<h2>教师列表（前20条）</h2>");
            Response.Write("<table>");
            Response.Write("<tr><th>Hid</th><th>Hname</th><th>Hnick</th><th>Hpwd</th><th>Hpermiss</th><th>Hnote</th><th>Hcount</th></tr>");
            
            int count = 0;
            while (reader.Read())
            {
                count++;
                Response.Write("<tr>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hid"].ToString()) + "</td>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hname"].ToString()) + "</td>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hnick"] != DBNull.Value ? reader["Hnick"].ToString() : "") + "</td>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hpwd"].ToString()) + "</td>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hpermiss"] != DBNull.Value ? reader["Hpermiss"].ToString() : "") + "</td>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hnote"] != DBNull.Value ? reader["Hnote"].ToString() : "") + "</td>");
                Response.Write("<td>" + Server.HtmlEncode(reader["Hcount"] != DBNull.Value ? reader["Hcount"].ToString() : "0") + "</td>");
                Response.Write("</tr>");
            }
            
            Response.Write("</table>");
            
            if (count == 0)
            {
                Response.Write("<div class='error'>警告：Teacher 表中没有数据！</div>");
            }
            
            reader.Close();
        }
    }
    catch (Exception ex)
    {
        Response.Write("<div class='error'><strong>错误：</strong>" + Server.HtmlEncode(ex.Message) + "<br><br>");
        Response.Write("<strong>堆栈跟踪：</strong><pre>" + Server.HtmlEncode(ex.StackTrace) + "</pre></div>");
    }
%>

    <p><a href="teacher.aspx">返回教师管理页面</a></p>
</body>
</html>
