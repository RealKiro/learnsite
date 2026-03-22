<%@ Page Language="C#" ContentType="application/json" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        Response.Clear();
        
        try
        {
            string hidStr = Request.QueryString["hid"];
            if (string.IsNullOrEmpty(hidStr))
            {
                Response.Write("{\"success\":false,\"message\":\"缺少教师ID\"}");
                Response.End();
                return;
            }
            
            int hid = 0;
            if (!int.TryParse(hidStr, out hid))
            {
                Response.Write("{\"success\":false,\"message\":\"无效的教师ID\"}");
                Response.End();
                return;
            }
            
            // 获取连接字符串
            ConnectionStringSettings connStrConfig = ConfigurationManager.ConnectionStrings["constr"];
            if (connStrConfig == null)
            {
                connStrConfig = ConfigurationManager.ConnectionStrings["SqlServer"];
            }
            
            if (connStrConfig == null)
            {
                Response.Write("{\"success\":false,\"message\":\"连接字符串未配置\"}");
                Response.End();
                return;
            }
            
            string connStr = connStrConfig.ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查 SchoolId 字段是否存在
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'SchoolId'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int columnExists = (int)cmdCheck.ExecuteScalar();
                
                if (columnExists == 0)
                {
                    Response.Write("{\"success\":true,\"schoolName\":null}");
                    Response.End();
                    return;
                }
                
                // 查询教师的学校
                string sql = @"SELECT S.SchoolName 
                    FROM Teacher T 
                    LEFT JOIN School S ON T.SchoolId = S.SchoolId 
                    WHERE T.hid = @TeacherId AND S.IsActive = 1";
                    
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@TeacherId", hid);
                
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    string schoolName = result.ToString().Replace("\"", "\\\"");
                    Response.Write("{\"success\":true,\"schoolName\":\"" + schoolName + "\"}");
                }
                else
                {
                    Response.Write("{\"success\":true,\"schoolName\":null}");
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
        
        Response.End();
    }
</script>
