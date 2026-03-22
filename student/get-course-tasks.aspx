<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Text" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json; charset=utf-8";
        Response.Clear();
        
        string cidStr = Request.QueryString["cid"];
        int cid = 0;
        
        if (string.IsNullOrEmpty(cidStr) || !int.TryParse(cidStr, out cid) || cid <= 0)
        {
            Response.Write("{\"success\":false,\"message\":\"无效的课程ID\"}");
            Response.End();
            return;
        }
        
        string connStr = "";
        try
        {
            connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\":false,\"message\":\"数据库配置错误\"}");
            Response.End();
            return;
        }
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 获取课程标题（如果Course表不存在，跳过）
                string courseTitle = "";
                try
                {
                    string courseSql = "SELECT Ctitle FROM Course WHERE Cid=@cid";
                    using (SqlCommand courseCmd = new SqlCommand(courseSql, conn))
                    {
                        courseCmd.Parameters.AddWithValue("@cid", cid);
                        object result = courseCmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            byte[] bytes = result as byte[];
                            if (bytes != null)
                                courseTitle = System.Text.Encoding.Unicode.GetString(bytes);
                            else
                                courseTitle = result.ToString();
                        }
                    }
                }
                catch
                {
                    // Course表不存在，使用默认标题
                    courseTitle = "课程任务";
                }
                
                // 获取任务列表
                string taskSql = @"
                    SELECT Lid, Lcid, Lxid, Ltype, Ltitle, Lsort, lshow
                    FROM Listmenu
                    WHERE Lcid=@cid AND lshow=1
                    ORDER BY Lsort, Lid
                ";
                
                StringBuilder json = new StringBuilder();
                json.Append("{\"success\":true,");
                json.Append("\"courseTitle\":\"").Append(JsonEscape(courseTitle)).Append("\",");
                json.Append("\"tasks\":[");
                
                using (SqlCommand taskCmd = new SqlCommand(taskSql, conn))
                {
                    taskCmd.Parameters.AddWithValue("@cid", cid);
                    using (SqlDataReader reader = taskCmd.ExecuteReader())
                    {
                        bool first = true;
                        while (reader.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            
                            int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                            int lcid = reader["Lcid"] != DBNull.Value ? Convert.ToInt32(reader["Lcid"]) : 0;
                            int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                            
                            string ltype = "";
                            if (reader["Ltype"] != DBNull.Value)
                            {
                                byte[] bytes = reader["Ltype"] as byte[];
                                if (bytes != null)
                                    ltype = System.Text.Encoding.Unicode.GetString(bytes);
                                else
                                    ltype = reader["Ltype"].ToString();
                            }
                            
                            string ltitle = "";
                            if (reader["Ltitle"] != DBNull.Value)
                            {
                                byte[] bytes = reader["Ltitle"] as byte[];
                                if (bytes != null)
                                    ltitle = System.Text.Encoding.Unicode.GetString(bytes);
                                else
                                    ltitle = reader["Ltitle"].ToString();
                            }
                            
                            json.Append("{");
                            json.Append("\"lid\":").Append(lid).Append(",");
                            json.Append("\"lcid\":").Append(lcid).Append(",");
                            json.Append("\"lxid\":").Append(lxid).Append(",");
                            json.Append("\"ltype\":\"").Append(JsonEscape(ltype)).Append("\",");
                            json.Append("\"ltitle\":\"").Append(JsonEscape(ltitle)).Append("\"");
                            json.Append("}");
                        }
                    }
                }
                
                json.Append("]}");
                
                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
        
        Response.End();
    }
    
    private string JsonEscape(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";
        return str.Replace("\\", "\\\\")
                  .Replace("\"", "\\\"")
                  .Replace("\r", "\\r")
                  .Replace("\n", "\\n")
                  .Replace("\t", "\\t");
    }
</script>
