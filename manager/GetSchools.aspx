<%@ Page Language="C#" ContentType="application/json" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        Response.Clear();
        
        try
        {
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
            System.Collections.ArrayList schools = new System.Collections.ArrayList();
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查 School 表是否存在
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                SqlCommand cmdCheck = new SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                if (tableExists > 0)
                {
                    string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    SqlDataReader reader = cmd.ExecuteReader();
                    
                    while (reader.Read())
                    {
                        System.Collections.Hashtable school = new System.Collections.Hashtable();
                        school["id"] = reader["SchoolId"].ToString();
                        school["name"] = reader["SchoolName"].ToString();
                        schools.Add(school);
                    }
                    reader.Close();
                }
            }
            
            // 构建 JSON 响应
            StringBuilder json = new StringBuilder();
            json.Append("{\"success\":true,\"schools\":[");
            
            for (int i = 0; i < schools.Count; i++)
            {
                System.Collections.Hashtable school = (System.Collections.Hashtable)schools[i];
                if (i > 0) json.Append(",");
                json.Append("{\"id\":\"");
                json.Append(school["id"]);
                json.Append("\",\"name\":\"");
                json.Append(school["name"]);
                json.Append("\"}");
            }
            
            json.Append("]}");
            Response.Write(json.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
        
        Response.End();
    }
</script>
