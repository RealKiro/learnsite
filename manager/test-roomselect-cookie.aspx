<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>班级选择Cookie测试</title>
    <meta charset="utf-8">
    <style>
        body { font-family: 'Microsoft YaHei', Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #6366f1; padding-bottom: 10px; }
        .section { margin: 20px 0; padding: 15px; background: #f8fafc; border-radius: 8px; border-left: 4px solid #6366f1; }
        .section h2 { margin-top: 0; color: #6366f1; font-size: 18px; }
        .info { background: #e0e7ff; padding: 10px; border-radius: 5px; margin: 10px 0; }
        .success { background: #dcfce7; color: #166534; }
        .error { background: #fee2e2; color: #991b1b; }
        .warning { background: #fef3c7; color: #92400e; }
        pre { background: #1e293b; color: #e2e8f0; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .btn { display: inline-block; padding: 10px 20px; background: #6366f1; color: white; text-decoration: none; border-radius: 5px; margin: 5px; cursor: pointer; border: none; font-size: 14px; }
        .btn:hover { background: #4f46e5; }
        .btn-danger { background: #ef4444; }
        .btn-danger:hover { background: #dc2626; }
        input[type="text"] { width: 100%; padding: 8px; border: 1px solid #e2e8f0; border-radius: 5px; font-size: 14px; }
        label { display: block; margin: 10px 0 5px; font-weight: 600; color: #475569; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🍪 班级选择Cookie测试工具</h1>
        
        <div class="section">
            <h2>当前Cookie状态</h2>
            <%
                System.Web.HttpCookie cookie = Request.Cookies["TeacherRoomSelection"];
                if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
                {
            %>
                <div class="info success">
                    <strong>✅ Cookie存在</strong><br/>
                    <strong>名称:</strong> TeacherRoomSelection<br/>
                    <strong>值:</strong> <%= Server.HtmlEncode(cookie.Value) %><br/>
                    <strong>过期时间:</strong> <%= cookie.Expires.ToString("yyyy-MM-dd HH:mm:ss") %><br/>
                    <strong>路径:</strong> <%= cookie.Path %>
                </div>
                
                <h3>解析后的班级列表：</h3>
                <pre><%
                    string[] rooms = cookie.Value.Split(',');
                    int index = 1;
                    foreach (string room in rooms)
                    {
                        if (!string.IsNullOrEmpty(room))
                        {
                            string[] parts = room.Split('|');
                            if (parts.Length >= 3)
                            {
                                Response.Write(string.Format("{0}. Rid={1}, 年级={2}, 班级={3}\n", 
                                    index++, parts[0], parts[1], parts[2]));
                            }
                            else if (parts.Length >= 1)
                            {
                                Response.Write(string.Format("{0}. Rid={1}\n", index++, parts[0]));
                            }
                        }
                    }
                    if (index == 1)
                    {
                        Response.Write("(Cookie值为空或格式错误)");
                    }
                %></pre>
            <%
                }
                else
                {
            %>
                <div class="info warning">
                    <strong>⚠️ Cookie不存在</strong><br/>
                    还没有保存任何班级选择，或者Cookie已过期。
                </div>
            <%
                }
            %>
        </div>
        
        <div class="section">
            <h2>手动设置Cookie</h2>
            <form method="post">
                <label>Cookie值（格式: Rid|Grade|Class,Rid|Grade|Class,...）</label>
                <input type="text" name="cookieValue" placeholder="例如: 101|1|1,102|1|2,201|2|1" 
                    value="<%= Request.Form["cookieValue"] ?? "" %>" />
                
                <label>有效期（天）</label>
                <input type="text" name="expireDays" placeholder="默认7天" value="7" style="width: 100px;" />
                
                <button type="submit" name="action" value="set" class="btn">💾 设置Cookie</button>
                <button type="submit" name="action" value="clear" class="btn btn-danger">🗑️ 清除Cookie</button>
            </form>
            
            <%
                if (Request.Form["action"] == "set")
                {
                    string cookieValue = Request.Form["cookieValue"];
                    int expireDays = 7;
                    try { expireDays = int.Parse(Request.Form["expireDays"]); } catch { }
                    
                    if (!string.IsNullOrEmpty(cookieValue))
                    {
                        System.Web.HttpCookie newCookie = new System.Web.HttpCookie("TeacherRoomSelection", cookieValue);
                        newCookie.Expires = DateTime.Now.AddDays(expireDays);
                        Response.Cookies.Add(newCookie);
            %>
                        <div class="info success" style="margin-top: 15px;">
                            ✅ Cookie已设置！页面将在2秒后刷新...
                            <script>setTimeout(function(){ location.reload(); }, 2000);</script>
                        </div>
            <%
                    }
                    else
                    {
            %>
                        <div class="info error" style="margin-top: 15px;">
                            ❌ Cookie值不能为空
                        </div>
            <%
                    }
                }
                else if (Request.Form["action"] == "clear")
                {
                    System.Web.HttpCookie clearCookie = new System.Web.HttpCookie("TeacherRoomSelection");
                    clearCookie.Expires = DateTime.Now.AddDays(-1);
                    Response.Cookies.Add(clearCookie);
            %>
                    <div class="info success" style="margin-top: 15px;">
                        ✅ Cookie已清除！页面将在2秒后刷新...
                        <script>setTimeout(function(){ location.reload(); }, 2000);</script>
                    </div>
            <%
                }
            %>
        </div>
        
        <div class="section">
            <h2>所有Cookie列表</h2>
            <pre><%
                if (Request.Cookies.Count > 0)
                {
                    foreach (string cookieName in Request.Cookies.AllKeys)
                    {
                        System.Web.HttpCookie c = Request.Cookies[cookieName];
                        Response.Write(string.Format("{0} = {1}\n", 
                            cookieName, 
                            Server.HtmlEncode(c.Value.Length > 100 ? c.Value.Substring(0, 100) + "..." : c.Value)));
                    }
                }
                else
                {
                    Response.Write("(没有Cookie)");
                }
            %></pre>
        </div>
        
        <div class="section">
            <h2>快速操作</h2>
            <a href="roomselect.aspx" class="btn">📋 打开班级选择页面</a>
            <a href="test-roomselect-cookie.aspx" class="btn">🔄 刷新此页面</a>
        </div>
        
        <div class="section">
            <h2>使用说明</h2>
            <ol style="line-height: 1.8;">
                <li>在班级选择页面选择班级后，点击"确定选择"按钮</li>
                <li>返回此页面查看Cookie是否已保存</li>
                <li>如果Cookie存在，说明保存成功</li>
                <li>刷新班级选择页面，检查选中状态是否恢复</li>
                <li>可以使用"手动设置Cookie"功能测试不同的值</li>
            </ol>
        </div>
        
        <div class="section">
            <h2>故障排查</h2>
            <ul style="line-height: 1.8;">
                <li><strong>Cookie不存在：</strong>检查Btnselect_Click方法是否正确执行</li>
                <li><strong>Cookie存在但选中状态未恢复：</strong>检查RestoreRoomSelection或DLroom_ItemDataBound方法</li>
                <li><strong>颜色没有变化：</strong>检查浏览器控制台的JavaScript错误</li>
                <li><strong>点击"确定选择"后没有反应：</strong>检查服务器日志中的异常</li>
            </ul>
        </div>
    </div>
</body>
</html>
