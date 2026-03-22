<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <title>邮件发送测试</title>
    <meta charset="utf-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft YaHei', sans-serif; background: #f0f2f5; padding: 40px 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; padding: 30px; box-shadow: 0 4px 24px rgba(0,0,0,.1); }
        h1 { color: #1e293b; margin-bottom: 20px; font-size: 24px; }
        .info { background: #eff6ff; padding: 15px; border-radius: 8px; margin-bottom: 20px; color: #1e40af; font-size: 14px; line-height: 1.6; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: #374151; font-size: 14px; }
        input[type="email"] { width: 100%; padding: 12px 16px; border: 1.5px solid #e5e7eb; border-radius: 12px; font-size: 14px; font-family: inherit; background: #f9fafb; transition: all .2s; }
        input[type="email"]:focus { border-color: #3b82f6; outline: none; box-shadow: 0 0 0 3px rgba(59,130,246,.12); background: white; }
        .btn { display: inline-block; padding: 12px 40px; border-radius: 50px; border: none; background: linear-gradient(135deg, #3b82f6, #1d4ed8); color: white; font-size: 15px; font-weight: 700; cursor: pointer; font-family: inherit; letter-spacing: 1px; box-shadow: 0 4px 14px rgba(37,99,235,.25); transition: all .2s; }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(37,99,235,.35); }
        .result { margin-top: 20px; padding: 15px; border-radius: 8px; display: none; }
        .result.success { background: #d1fae5; border: 1px solid #6ee7b7; color: #065f46; display: block; }
        .result.error { background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; display: block; }
        .config-status { margin-top: 20px; padding: 15px; border-radius: 8px; background: #f3f4f6; }
        .config-item { margin: 8px 0; font-size: 14px; color: #475569; }
        .config-item strong { color: #1e293b; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📧 邮件发送功能测试</h1>

        <div class="info">
            <strong>使用说明：</strong><br>
            1. 确保已配置 App_Data/emailconfig.xml 文件<br>
            2. 输入接收测试邮件的邮箱地址<br>
            3. 点击发送按钮测试邮件功能
        </div>

        <div class="config-status">
            <h3 style="margin-bottom: 10px; color: #1e293b;">配置状态</h3>
            <%
                string configPath = Server.MapPath("~/App_Data/emailconfig.xml");
                bool configExists = System.IO.File.Exists(configPath);

                if (configExists)
                {
                    try
                    {
                        System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                        doc.Load(configPath);

                        string smtpServer = GetXmlValue(doc, "smtpServer");
                        string smtpPort = GetXmlValue(doc, "smtpPort");
                        string fromEmail = GetXmlValue(doc, "fromEmail");
                        string fromPassword = GetXmlValue(doc, "fromPassword");
                        string fromName = GetXmlValue(doc, "fromName");

                        Response.Write("<div class='config-item'><strong>配置文件：</strong>✅ 已找到</div>");
                        Response.Write("<div class='config-item'><strong>SMTP服务器：</strong>" + Server.HtmlEncode(smtpServer) + "</div>");
                        Response.Write("<div class='config-item'><strong>端口：</strong>" + Server.HtmlEncode(smtpPort) + "</div>");
                        Response.Write("<div class='config-item'><strong>发件人邮箱：</strong>" + Server.HtmlEncode(fromEmail) + "</div>");
                        Response.Write("<div class='config-item'><strong>发件人名称：</strong>" + Server.HtmlEncode(fromName) + "</div>");

                        if (string.IsNullOrEmpty(fromPassword))
                        {
                            Response.Write("<div class='config-item' style='color: #dc2626;'><strong>⚠️ 警告：</strong>未配置授权码，邮件将无法发送</div>");
                        }
                        else
                        {
                            Response.Write("<div class='config-item' style='color: #059669;'><strong>授权码：</strong>✅ 已配置</div>");
                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write("<div class='config-item' style='color: #dc2626;'><strong>❌ 配置错误：</strong>" + Server.HtmlEncode(ex.Message) + "</div>");
                    }
                }
                else
                {
                    Response.Write("<div class='config-item' style='color: #dc2626;'><strong>❌ 配置文件不存在</strong></div>");
                    Response.Write("<div class='config-item'>请复制 emailconfig.xml.example 为 emailconfig.xml 并配置</div>");
                }
            %>
        </div>

        <form id="testForm" onsubmit="return false;">
            <div class="form-group">
                <label for="testEmail">测试邮箱地址</label>
                <input type="email" id="testEmail" placeholder="请输入接收测试邮件的邮箱" required>
            </div>

            <button type="button" class="btn" onclick="sendTestEmail()">发送测试邮件</button>
        </form>

        <div id="result" class="result"></div>
    </div>

    <script>
        function sendTestEmail() {
            var emailInput = document.getElementById('testEmail');
            var resultDiv = document.getElementById('result');
            var email = emailInput.value.trim();

            if (!email) {
                showResult('请输入邮箱地址', false);
                return;
            }

            var emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
            if (!emailRegex.test(email)) {
                showResult('请输入有效的邮箱地址', false);
                return;
            }

            resultDiv.innerHTML = '正在发送...';
            resultDiv.className = 'result';
            resultDiv.style.display = 'block';

            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'SendEmailCode.ashx', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            showResult(response.message, response.success);

                            if (response.success) {
                                resultDiv.innerHTML += '<br><br><strong>提示：</strong>如未收到邮件，请检查垃圾邮件箱';
                            }
                        } catch (e) {
                            showResult('发送失败：' + e.message, false);
                        }
                    } else {
                        showResult('网络错误：' + xhr.status, false);
                    }
                }
            };

            xhr.send('email=' + encodeURIComponent(email));
        }

        function showResult(message, success) {
            var resultDiv = document.getElementById('result');
            resultDiv.innerHTML = message;
            resultDiv.className = 'result ' + (success ? 'success' : 'error');
            resultDiv.style.display = 'block';
        }
    </script>
</body>
</html>

<script runat="server">
    protected string GetXmlValue(System.Xml.XmlDocument doc, string nodeName)
    {
        try
        {
            System.Xml.XmlNode node = doc.SelectSingleNode("//" + nodeName);
            if (node != null)
            {
                return node.InnerText;
            }
        }
        catch { }
        return "";
    }
</script>
