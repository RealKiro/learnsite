<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Configuration" %>
<!DOCTYPE html>
<html>
<head>
    <title>测试找回密码API</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial; padding: 20px; background: #f5f5f5; }
        .box { background: #fff; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h2 { color: #333; margin-top: 0; }
        .success { color: #10b981; }
        .error { color: #ef4444; }
        .info { color: #3b82f6; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>找回密码API诊断</h1>
    
    <%
    Response.Write("<div class='box'>");
    Response.Write("<h2>1. 数据库连接测试</h2>");
    
    string cs = null;
    try
    {
        Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
        if (dbType != null)
        {
            FieldInfo f = dbType.GetField("connectionString",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
            if (f != null) cs = f.GetValue(null) as string;
        }
    }
    catch { }
    
    if (string.IsNullOrEmpty(cs))
    {
        try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
        catch { }
    }
    
    if (string.IsNullOrEmpty(cs))
    {
        Response.Write("<p class='error'>❌ 无法获取数据库连接字符串</p>");
    }
    else
    {
        Response.Write("<p class='success'>✅ 数据库连接字符串已获取</p>");
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                Response.Write("<p class='success'>✅ 数据库连接成功</p>");
                
                // 检查Teacher表结构
                Response.Write("<h2>2. Teacher表结构检查</h2>");
                SqlCommand cmd = new SqlCommand("SELECT TOP 1 * FROM Teacher", conn);
                SqlDataReader dr = cmd.ExecuteReader();
                
                Response.Write("<p class='info'>Teacher表字段列表：</p><pre>");
                for (int i = 0; i < dr.FieldCount; i++)
                {
                    Response.Write(dr.GetName(i) + " (" + dr.GetFieldType(i).Name + ")\n");
                }
                Response.Write("</pre>");
                dr.Close();
                
                // 检查是否有Hname字段
                Response.Write("<h2>3. 查找用户名字段</h2>");
                cmd = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Teacher' AND COLUMN_NAME LIKE '%name%'", conn);
                dr = cmd.ExecuteReader();
                
                Response.Write("<p class='info'>包含'name'的字段：</p><pre>");
                bool hasHname = false;
                while (dr.Read())
                {
                    string colName = dr["COLUMN_NAME"].ToString();
                    Response.Write(colName + "\n");
                    if (colName == "Hname") hasHname = true;
                }
                Response.Write("</pre>");
                dr.Close();
                
                if (!hasHname)
                {
                    Response.Write("<p class='error'>❌ Teacher表中没有Hname字段</p>");
                    Response.Write("<p class='info'>建议：检查Teacher表的实际用户名字段名称</p>");
                }
                else
                {
                    Response.Write("<p class='success'>✅ Teacher表有Hname字段</p>");
                }
                
                // 测试查询
                Response.Write("<h2>4. 测试查询（用户名：lry）</h2>");
                try
                {
                    cmd = new SqlCommand("SELECT Hid, Hname, Hemail FROM Teacher WHERE Hname=@username", conn);
                    cmd.Parameters.AddWithValue("@username", "lry");
                    dr = cmd.ExecuteReader();
                    
                    if (dr.Read())
                    {
                        Response.Write("<p class='success'>✅ 找到用户</p>");
                        Response.Write("<pre>");
                        Response.Write("Hid: " + dr["Hid"] + "\n");
                        Response.Write("Hname: " + dr["Hname"] + "\n");
                        Response.Write("Hemail: " + (dr["Hemail"] != DBNull.Value ? dr["Hemail"].ToString() : "(未设置)") + "\n");
                        Response.Write("</pre>");
                    }
                    else
                    {
                        Response.Write("<p class='error'>❌ 未找到用户名为'lry'的教师</p>");
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    Response.Write("<p class='error'>❌ 查询失败: " + Server.HtmlEncode(ex.Message) + "</p>");
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("<p class='error'>❌ 数据库操作失败: " + Server.HtmlEncode(ex.Message) + "</p>");
        }
    }
    
    Response.Write("</div>");
    
    // 检查邮件配置
    Response.Write("<div class='box'>");
    Response.Write("<h2>5. 邮件配置检查</h2>");
    
    try
    {
        string xmlPath = Server.MapPath("~/website.xml");
        if (System.IO.File.Exists(xmlPath))
        {
            Response.Write("<p class='success'>✅ website.xml 文件存在</p>");
            
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            
            string[] keys = new string[] { "SmtpHost", "SmtpPort", "SmtpUser", "SmtpPass", "SmtpSsl", "SmtpFrom" };
            Response.Write("<p class='info'>SMTP配置：</p><pre>");
            
            foreach (string key in keys)
            {
                System.Xml.XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
                if (node != null && node.Attributes["value"] != null)
                {
                    string val = node.Attributes["value"].Value;
                    if (key == "SmtpPass" && !string.IsNullOrEmpty(val))
                        val = "******";
                    Response.Write(key + ": " + (string.IsNullOrEmpty(val) ? "(未设置)" : val) + "\n");
                }
                else
                {
                    Response.Write(key + ": (未配置)\n");
                }
            }
            Response.Write("</pre>");
        }
        else
        {
            Response.Write("<p class='error'>❌ website.xml 文件不存在</p>");
        }
    }
    catch (Exception ex)
    {
        Response.Write("<p class='error'>❌ 读取配置失败: " + Server.HtmlEncode(ex.Message) + "</p>");
    }
    
    Response.Write("</div>");
    %>
    
    <div class="box">
        <h2>6. 手动测试API</h2>
        <p>在浏览器中访问：</p>
        <pre>resetpasswordapi.ashx?action=checkuser&username=lry</pre>
        <p><a href="resetpasswordapi.ashx?action=checkuser&username=lry" target="_blank">点击测试</a></p>
    </div>
</body>
</html>
