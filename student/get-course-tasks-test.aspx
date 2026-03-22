<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json; charset=utf-8";
        Response.Clear();
        
        try
        {
            string cidStr = Request.QueryString["cid"];
            int cid = 0;
            
            if (string.IsNullOrEmpty(cidStr) || !int.TryParse(cidStr, out cid) || cid <= 0)
            {
                Response.Write("{\"success\":false,\"message\":\"无效的课程ID: " + cidStr + "\"}");
                Response.End();
                return;
            }
            
            string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                // 简单测试：只返回任务数量
                string sql = "SELECT COUNT(*) FROM Listmenu WHERE Lcid=@cid AND lshow=1";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@cid", cid);
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    Response.Write("{\"success\":true,\"cid\":" + cid + ",\"taskCount\":" + count + ",\"message\":\"测试成功\"}");
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\":false,\"message\":\"错误: " + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
        
        Response.End();
    }
</script>
