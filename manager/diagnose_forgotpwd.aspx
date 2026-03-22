<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<!DOCTYPE html>
<html>
<head>
    <title>找回密码功能诊断</title>
    <meta charset="utf-8" />
    <style>
        body { font-family: 'Microsoft YaHei', Arial; padding: 20px; background: #f8fafc; }
        .box { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h2 { color: #1e293b; margin-top: 0; }
        .ok { color: #10b981; font-weight: bold; }
        .err { color: #ef4444; font-weight: bold; }
        .info { color: #6366f1; }
        pre { background: #f1f5f9; padding: 12px; border-radius: 6px; overflow-x: auto; }
        .btn { display: inline-block; padding: 10px 20px; background: #6366f1; color: #fff; text-decoration: none; border-radius: 8px; margin-top: 10px; }
        .btn:hover { background: #4f46e5; }
    </style>
</head>
<body>
    <div class="box">
        <h2>找回密码功能诊断</h2>
        <%
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                Response.Write("<p class='ok'>✓ 数据库连接成功</p>");
                
                // 检查 EmailVerifyCode 表
                SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM sys.objects WHERE object_id = OBJECT_ID('dbo.EmailVerifyCode') AND type = 'U'", conn);
                int tableExists = (int)cmd.ExecuteScalar();
                
                if (tableExists > 0)
                {
                    Response.Write("<p class='ok'>✓ EmailVerifyCode 表存在</p>");
                    
                    // 检查表结构
                    SqlCommand cmd2 = new SqlCommand(@"
                        SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
                        FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE TABLE_NAME = 'EmailVerifyCode'
                        ORDER BY ORDINAL_POSITION", conn);
                    SqlDataReader reader = cmd2.ExecuteReader();
                    Response.Write("<p class='info'>表结构：</p><pre>");
                    while (reader.Read())
                    {
                        Response.Write(string.Format("{0} ({1}", reader["COLUMN_NAME"], reader["DATA_TYPE"]));
                        if (reader["CHARACTER_MAXIMUM_LENGTH"] != DBNull.Value)
                            Response.Write("(" + reader["CHARACTER_MAXIMUM_LENGTH"] + ")");
                        Response.Write(") " + (reader["IS_NULLABLE"].ToString() == "YES" ? "NULL" : "NOT NULL") + "\n");
                    }
                    reader.Close();
                    Response.Write("</pre>");
                    
                    // 检查记录数
                    SqlCommand cmd3 = new SqlCommand("SELECT COUNT(*) FROM EmailVerifyCode", conn);
                    int count = (int)cmd3.ExecuteScalar();
                    Response.Write("<p class='info'>验证码记录数：" + count + "</p>");
                }
                else
                {
                    Response.Write("<p class='err'>✗ EmailVerifyCode 表不存在</p>");
                    Response.Write("<p>需要执行数据库升级脚本：<code>sql/upgrade_profile_email.sql</code></p>");
                    Response.Write("<p>或者手动创建表：</p>");
                    Response.Write("<pre>CREATE TABLE [dbo].[EmailVerifyCode](\n");
                    Response.Write("    [Id] [int] IDENTITY(1,1) NOT NULL,\n");
                    Response.Write("    [Email] [nvarchar](100) NOT NULL,\n");
                    Response.Write("    [Code] [nvarchar](10) NOT NULL,\n");
                    Response.Write("    [Hname] [nvarchar](50) NULL,\n");
                    Response.Write("    [CreatedAt] [datetime] NOT NULL DEFAULT(GETDATE()),\n");
                    Response.Write("    [Used] [bit] NOT NULL DEFAULT(0),\n");
                    Response.Write("PRIMARY KEY CLUSTERED ([Id] ASC)\n");
                    Response.Write(") ON [PRIMARY];</pre>");
                }
                
                // 检查 Teacher 表的 Hemail 字段
                SqlCommand cmd4 = new SqlCommand(@"
                    SELECT COUNT(*) FROM sys.columns 
                    WHERE object_id = OBJECT_ID('dbo.Teacher') AND name = 'Hemail'", conn);
                int emailFieldExists = (int)cmd4.ExecuteScalar();
                
                if (emailFieldExists > 0)
                {
                    Response.Write("<p class='ok'>✓ Teacher.Hemail 字段存在</p>");
                    
                    // 统计绑定邮箱的教师数
                    SqlCommand cmd5 = new SqlCommand("SELECT COUNT(*) FROM Teacher WHERE Hemail IS NOT NULL AND Hemail != ''", conn);
                    int emailCount = (int)cmd5.ExecuteScalar();
                    Response.Write("<p class='info'>已绑定邮箱的教师数：" + emailCount + "</p>");
                }
                else
                {
                    Response.Write("<p class='err'>✗ Teacher.Hemail 字段不存在</p>");
                    Response.Write("<p>需要执行：<code>ALTER TABLE Teacher ADD Hemail nvarchar(100) NULL</code></p>");
                }
                
                // 检查 SMTP 配置
                string xmlPath = Server.MapPath("~/website.xml");
                if (System.IO.File.Exists(xmlPath))
                {
                    System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                    doc.Load(xmlPath);
                    
                    string smtpHost = "";
                    string smtpUser = "";
                    
                    System.Xml.XmlNode hostNode = doc.SelectSingleNode("//add[@key='SmtpHost']");
                    if (hostNode != null && hostNode.Attributes["value"] != null)
                        smtpHost = hostNode.Attributes["value"].Value;
                    
                    System.Xml.XmlNode userNode = doc.SelectSingleNode("//add[@key='SmtpUser']");
                    if (userNode != null && userNode.Attributes["value"] != null)
                        smtpUser = userNode.Attributes["value"].Value;
                    
                    if (!string.IsNullOrEmpty(smtpHost) && !string.IsNullOrEmpty(smtpUser))
                    {
                        Response.Write("<p class='ok'>✓ SMTP 配置已设置</p>");
                        Response.Write("<p class='info'>SMTP主机：" + smtpHost + "</p>");
                        Response.Write("<p class='info'>SMTP用户：" + smtpUser + "</p>");
                    }
                    else
                    {
                        Response.Write("<p class='err'>✗ SMTP 配置未完成</p>");
                        Response.Write("<p>请前往 <a href='emailsetting.aspx'>邮箱设置</a> 配置SMTP</p>");
                    }
                }
                else
                {
                    Response.Write("<p class='err'>✗ website.xml 配置文件不存在</p>");
                }
            }
            
            Response.Write("<hr/>");
            Response.Write("<h3>测试步骤：</h3>");
            Response.Write("<ol>");
            Response.Write("<li>确保 EmailVerifyCode 表已创建</li>");
            Response.Write("<li>确保 Teacher.Hemail 字段已添加</li>");
            Response.Write("<li>确保至少有一个教师绑定了邮箱</li>");
            Response.Write("<li>确保 SMTP 邮箱服务已配置</li>");
            Response.Write("<li>访问 <a href='forgotpwd.aspx'>找回密码页面</a> 进行测试</li>");
            Response.Write("</ol>");
        }
        catch (Exception ex)
        {
            Response.Write("<p class='err'>✗ 错误：" + Server.HtmlEncode(ex.Message) + "</p>");
            Response.Write("<pre>" + Server.HtmlEncode(ex.StackTrace) + "</pre>");
        }
        %>
        <a href="forgotpwd.aspx" class="btn">前往找回密码页面</a>
        <a href="index.aspx" class="btn" style="background:#94a3b8;">返回管理后台</a>
    </div>
</body>
</html>
