<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%
    Response.ContentType = "application/json";
    Response.Charset = "UTF-8";
    
    try
    {
        // 获取 cid 参数
        string cidParam = Request.QueryString["cid"];
        if (string.IsNullOrEmpty(cidParam))
        {
            Response.Write("{\"success\":false,\"message\":\"缺少 cid 参数\"}");
            Response.End();
            return;
        }
        
        int cid = 0;
        if (!int.TryParse(cidParam, out cid))
        {
            Response.Write("{\"success\":false,\"message\":\"cid 参数格式错误\"}");
            Response.End();
            return;
        }
        
        // 连接数据库
        string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            string sql = @"SELECT Lid, Lxid, Ltype, Lsort, Ltitle, lshow 
                          FROM Listmenu 
                          WHERE Lcid = @Lcid AND (CONVERT(nvarchar(10), lshow) IN ('1','True','true'))
                          ORDER BY Lsort";
            
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Lcid", cid);
                
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
                
                // 手动构建 JSON（兼容 .NET 2.0）
                StringBuilder json = new StringBuilder();
                json.Append("{\"success\":true,\"count\":");
                json.Append(dt.Rows.Count);
                json.Append(",\"data\":[");
                
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    DataRow row = dt.Rows[i];
                    if (i > 0) json.Append(",");
                    
                    json.Append("{");
                    json.Append("\"Lid\":\"").Append(row["Lid"].ToString().Replace("\"", "\\\"")).Append("\",");
                    json.Append("\"Lxid\":\"").Append(row["Lxid"].ToString().Replace("\"", "\\\"")).Append("\",");
                    json.Append("\"Ltype\":\"").Append(row["Ltype"].ToString().Replace("\"", "\\\"")).Append("\",");
                    json.Append("\"Lsort\":\"").Append(row["Lsort"].ToString().Replace("\"", "\\\"")).Append("\",");
                    json.Append("\"Ltitle\":\"").Append(row["Ltitle"].ToString().Replace("\"", "\\\"")).Append("\",");
                    json.Append("\"lshow\":\"").Append(row["lshow"].ToString().Replace("\"", "\\\"")).Append("\"");
                    json.Append("}");
                }
                
                json.Append("]}");
                Response.Write(json.ToString());
            }
        }
    }
    catch (Exception ex)
    {
        Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
    }
%>
