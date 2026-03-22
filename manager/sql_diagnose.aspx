<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Net.NetworkInformation" %>
<!DOCTYPE html>
<html>
<head>
    <title>SQL Server 连接诊断工具</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial; padding: 20px; background: #f5f5f5; }
        .panel { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .success { color: #16a34a; font-weight: bold; }
        .error { color: #ef4444; font-weight: bold; }
        .warning { color: #f59e0b; font-weight: bold; }
        .info { color: #3b82f6; }
        h1 { color: #1e293b; }
        h2 { color: #475569; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; }
        h3 { color: #64748b; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 10px; border: 1px solid #e2e8f0; text-align: left; }
        th { background: #f1f5f9; color: #334155; font-weight: bold; }
        pre { background: #1e293b; color: #e2e8f0; padding: 15px; border-radius: 8px; overflow-x: auto; font-size: 12px; }
        .code { background: #f8fafc; padding: 2px 6px; border-radius: 4px; font-family: 'Consolas', monospace; }
        .btn { display: inline-block; padding: 8px 16px; background: #3b82f6; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
        .btn:hover { background: #2563eb; }
    </style>
</head>
<body>
    <h1>🔍 SQL Server 连接诊断工具</h1>
    
    <%
    // 获取原始连接字符串（.NET 2.0 兼容语法）
    string originalConnStr = "";
    if (ConfigurationManager.ConnectionStrings["SqlServer"] != null)
    {
        originalConnStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
    }
    
    string serverIp = "10.0.0.9";
    string instanceName = "SQLEXPRESS";
    string database = "ls";
    string userId = "sa";
    string password = "198889009lry,.";
    
    Response.Write("<div class='panel'>");
    Response.Write("<h2>1. 当前连接字符串</h2>");
    Response.Write("<p><span class='code'>" + Server.HtmlEncode(originalConnStr.Replace("Password=" + password, "Password=***")) + "</span></p>");
    Response.Write("</div>");
    
    // 测试网络连通性
    Response.Write("<div class='panel'>");
    Response.Write("<h2>2. 网络连通性测试</h2>");
    try
    {
        Ping ping = new Ping();
        PingReply reply = ping.Send(serverIp, 3000);
        if (reply.Status == IPStatus.Success)
        {
            Response.Write("<p class='success'>✓ Ping " + serverIp + " 成功 (延迟: " + reply.RoundtripTime + "ms)</p>");
        }
        else
        {
            Response.Write("<p class='error'>✗ Ping " + serverIp + " 失败: " + reply.Status + "</p>");
        }
    }
    catch (Exception ex)
    {
        Response.Write("<p class='error'>✗ Ping 测试失败: " + Server.HtmlEncode(ex.Message) + "</p>");
    }
    Response.Write("</div>");
    
    // 测试 SQL Server 端口
    Response.Write("<div class='panel'>");
    Response.Write("<h2>3. SQL Server 端口测试</h2>");
    Response.Write("<p class='info'>正在测试常见端口...</p>");
    
    int[] commonPorts = { 1433, 1434, 14330, 14331 };
    bool portFound = false;
    foreach (int port in commonPorts)
    {
        try
        {
            using (System.Net.Sockets.TcpClient client = new System.Net.Sockets.TcpClient())
            {
                IAsyncResult result = client.BeginConnect(serverIp, port, null, null);
                bool success = result.AsyncWaitHandle.WaitOne(TimeSpan.FromSeconds(2));
                if (success && client.Connected)
                {
                    Response.Write("<p class='success'>✓ 端口 " + port + " 可访问</p>");
                    portFound = true;
                    client.EndConnect(result);
                }
                else
                {
                    Response.Write("<p class='warning'>✗ 端口 " + port + " 不可访问</p>");
                }
            }
        }
        catch
        {
            Response.Write("<p class='warning'>✗ 端口 " + port + " 不可访问</p>");
        }
    }
    if (!portFound)
    {
        Response.Write("<p class='error'>⚠ 未找到可访问的 SQL Server 端口。这可能是防火墙或 SQL Server 配置问题。</p>");
    }
    Response.Write("</div>");
    
    // 尝试多种连接字符串
    Response.Write("<div class='panel'>");
    Response.Write("<h2>4. 连接字符串测试</h2>");
    
    string[] connectionStrings = {
        // 原始连接字符串
        originalConnStr,
        
        // 尝试1: 使用逗号分隔的密码（用单引号包裹）
        string.Format("Data Source={0}\\{1};Initial Catalog={2};User ID={3};Password='{4}';Connection Timeout=10;", serverIp, instanceName, database, userId, password),
        
        // 尝试2: 使用标准端口 1433（如果实例使用固定端口）
        string.Format("Data Source={0},1433;Initial Catalog={2};User ID={3};Password='{4}';Connection Timeout=10;", serverIp, instanceName, database, userId, password),
        
        // 尝试3: 使用 localhost（如果服务器是本机）
        string.Format("Data Source=localhost\\{1};Initial Catalog={2};User ID={3};Password='{4}';Connection Timeout=10;", serverIp, instanceName, database, userId, password),
        
        // 尝试4: 使用 .\SQLEXPRESS（本机格式）
        string.Format("Data Source=.\\{1};Initial Catalog={2};User ID={3};Password='{4}';Connection Timeout=10;", serverIp, instanceName, database, userId, password),
        
        // 尝试5: 使用 (local)\SQLEXPRESS
        string.Format("Data Source=(local)\\{1};Initial Catalog={2};User ID={3};Password='{4}';Connection Timeout=10;", serverIp, instanceName, database, userId, password),
        
        // 尝试6: 使用服务器名称而不是 IP（如果知道）
        // string.Format("Data Source=你的服务器名\\{1};Initial Catalog={2};User ID={3};Password='{4}';Connection Timeout=10;", serverIp, instanceName, database, userId, password),
    };
    
    string[] connStrNames = {
        "原始连接字符串",
        "方案1: 密码用单引号包裹",
        "方案2: 指定端口1433",
        "方案3: 使用localhost",
        "方案4: 使用.\\SQLEXPRESS",
        "方案5: 使用(local)\\SQLEXPRESS",
        "方案6: 使用服务器名"
    };
    
    Response.Write("<table>");
    Response.Write("<tr><th>方案</th><th>连接字符串（隐藏密码）</th><th>测试结果</th></tr>");
    
    int successIndex = -1;
    for (int i = 0; i < connectionStrings.Length; i++)
    {
        if (string.IsNullOrEmpty(connectionStrings[i])) continue;
        
        Response.Write("<tr>");
        Response.Write("<td><strong>" + connStrNames[i] + "</strong></td>");
        Response.Write("<td><span class='code'>" + Server.HtmlEncode(connectionStrings[i].Replace("Password=" + password, "Password=***").Replace("Password='" + password + "'", "Password='***'")) + "</span></td>");
        
        try
        {
            using (SqlConnection conn = new SqlConnection(connectionStrings[i]))
            {
                conn.Open();
                Response.Write("<td class='success'>✓ 连接成功<br/>数据库: " + conn.Database + "<br/>服务器: " + conn.DataSource + "</td>");
                if (successIndex == -1) successIndex = i;
                conn.Close();
            }
        }
        catch (SqlException sqlEx)
        {
            string errorMsg = sqlEx.Message;
            if (errorMsg.Length > 100) errorMsg = errorMsg.Substring(0, 100) + "...";
            Response.Write("<td class='error'>✗ 失败<br/><small>" + Server.HtmlEncode(errorMsg) + "</small></td>");
        }
        catch (Exception ex)
        {
            string errorMsg = ex.Message;
            if (errorMsg.Length > 100) errorMsg = errorMsg.Substring(0, 100) + "...";
            Response.Write("<td class='error'>✗ 失败<br/><small>" + Server.HtmlEncode(errorMsg) + "</small></td>");
        }
        
        Response.Write("</tr>");
    }
    
    Response.Write("</table>");
    
    if (successIndex >= 0)
    {
        Response.Write("<div style='margin-top: 20px; padding: 15px; background: #dcfce7; border-radius: 8px;'>");
        Response.Write("<h3 class='success'>✓ 找到可用的连接字符串！</h3>");
        Response.Write("<p><strong>推荐使用的连接字符串：</strong></p>");
        Response.Write("<pre>" + Server.HtmlEncode(connectionStrings[successIndex].Replace("Password=" + password, "Password=***").Replace("Password='" + password + "'", "Password='***'")) + "</pre>");
        Response.Write("<p>请将 web.config 中的连接字符串更新为上述值。</p>");
        Response.Write("</div>");
    }
    else
    {
        Response.Write("<div style='margin-top: 20px; padding: 15px; background: #fef3c7; border-radius: 8px;'>");
        Response.Write("<h3 class='warning'>⚠ 所有连接字符串都失败了</h3>");
        Response.Write("<p>请检查以下项目：</p>");
        Response.Write("<ul>");
        Response.Write("<li>SQL Server 服务是否正在运行</li>");
        Response.Write("<li>SQL Server Browser 服务是否正在运行（命名实例必需）</li>");
        Response.Write("<li>SQL Server 是否启用了 TCP/IP 协议</li>");
        Response.Write("<li>防火墙是否允许 SQL Server 端口</li>");
        Response.Write("<li>服务器 IP 地址是否正确</li>");
        Response.Write("</ul>");
        Response.Write("</div>");
    }
    
    Response.Write("</div>");
    
    // 诊断建议
    Response.Write("<div class='panel'>");
    Response.Write("<h2>5. 诊断建议</h2>");
    Response.Write("<h3>错误 26 的常见原因和解决方案：</h3>");
    Response.Write("<ol>");
    Response.Write("<li><strong>SQL Server Browser 服务未运行</strong><br/>");
    Response.Write("命名实例（如 SQLEXPRESS）需要 SQL Server Browser 服务来解析实例名称。<br/>");
    Response.Write("检查方法：打开“服务”（services.msc），查找“SQL Server Browser”，确保状态为“正在运行”。</li>");
    Response.Write("<li><strong>SQL Server 服务未运行</strong><br/>");
    Response.Write("检查“SQL Server (SQLEXPRESS)”服务是否正在运行。</li>");
    Response.Write("<li><strong>TCP/IP 协议未启用</strong><br/>");
    Response.Write("打开 SQL Server Configuration Manager → SQL Server 网络配置 → SQLEXPRESS 的协议 → 启用 TCP/IP，然后重启 SQL Server 服务。</li>");
    Response.Write("<li><strong>防火墙阻止连接</strong><br/>");
    Response.Write("确保 Windows 防火墙允许 SQL Server 和 SQL Server Browser 的通信。</li>");
    Response.Write("<li><strong>网络无法访问</strong><br/>");
    Response.Write("如果服务器在远程，确保网络路由正常，且 SQL Server 配置为允许远程连接。</li>");
    Response.Write("</ol>");
    Response.Write("</div>");
    
    // 快速修复建议
    Response.Write("<div class='panel'>");
    Response.Write("<h2>6. 快速修复步骤</h2>");
    Response.Write("<ol>");
    Response.Write("<li>打开“服务”（Win+R → services.msc）</li>");
    Response.Write("<li>找到并启动以下服务：<ul>");
    Response.Write("<li>SQL Server (SQLEXPRESS)</li>");
    Response.Write("<li>SQL Server Browser</li>");
    Response.Write("</ul></li>");
    Response.Write("<li>打开 SQL Server Configuration Manager</li>");
    Response.Write("<li>展开“SQL Server 网络配置” → “SQLEXPRESS 的协议”</li>");
    Response.Write("<li>右键“TCP/IP” → 属性 → 确保“已启用”为“是”</li>");
    Response.Write("<li>如果修改了协议，重启 SQL Server 服务</li>");
    Response.Write("<li>如果服务器是本机，尝试使用 localhost 或 .\\SQLEXPRESS 代替 IP 地址</li>");
    Response.Write("</ol>");
    Response.Write("</div>");
    %>
    
    <div class="panel">
        <h2>7. 其他资源</h2>
        <p>
            <a href="test_db.aspx" class="btn">测试数据库连接</a>
            <a href="dashboard.aspx" class="btn">返回管理面板</a>
        </p>
    </div>
    
    <hr/>
    <p style="color:#94a3b8;font-size:11px;">诊断工具 - 使用完毕后建议删除此文件以确保安全</p>
</body>
</html>

