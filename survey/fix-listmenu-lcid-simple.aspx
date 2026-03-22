<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "text/html; charset=utf-8";
        Response.Write("<!DOCTYPE html><html><head><meta charset='utf-8'><title>修复Lcid</title>");
        Response.Write("<style>body{font-family:'Microsoft YaHei';padding:20px;}table{border-collapse:collapse;width:100%;margin:10px 0;}th,td{border:1px solid #ddd;padding:8px;text-align:left;}th{background:#f0f0f0;}</style>");
        Response.Write("</head><body>");
        
        string connStr = "";
        try
        {
            connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch (Exception ex)
        {
            Response.Write("<h2 style='color:red;'>数据库配置错误</h2><p>" + Server.HtmlEncode(ex.Message) + "</p></body></html>");
            Response.End();
            return;
        }
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                
                Response.Write("<h1>修复 Listmenu 的 Lcid 字段</h1>");
                
                // 执行修复
                string updateSql = @"
                    UPDATE L
                    SET L.Lcid = Q)
                  using (SqlCommand updateCmd = new SqlCommand(updateSql, conn)uestion
                    ) Q ON L.Lxid = Q.Qvid
                    WHERE L.Ltype = '14'
                      AND (L.Lcid IS NULL OR L.Lcid <> Q.Qcid)
                ";
                
       NER JOIN (
                        SELECT DISTINCT Qvid, Qcid 
                        FROM SurveyQ.Qcid
                    FROM Listmenu L
                    IN