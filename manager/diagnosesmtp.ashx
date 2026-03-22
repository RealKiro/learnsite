<%@ WebHandler Language="C#" Class="DiagnoseSmtp" %>

using System;
using System.Web;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Xml;

public class DiagnoseSmtp : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            // 读取配置
            string xmlPath = context.Server.MapPath("~/website.xml");
            if (!System.IO.File.Exists(xmlPath))
            {
                context.Response.Write("{\"success\":0,\"message\":\"配置文件不存在\"}");
                return;
            }

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            string host = GetValue(doc, "SmtpHost");
            string portStr = GetValue(doc, "SmtpPort");
            string sslStr = GetValue(doc, "SmtpSsl");

            if (string.IsNullOrEmpty(host))
            {
                context.Response.Write("{\"success\":0,\"message\":\"SMTP主机未配置\"}");
                return;
            }

            int port = 587;
            if (!string.IsNullOrEmpty(portStr))
            {
                int.TryParse(portStr, out port);
            }
            
            bool ssl = false;
            if (!string.IsNullOrEmpty(sslStr))
            {
                ssl = sslStr.ToLower() == "true";
            }

            StringBuilder result = new StringBuilder();
            result.Append("诊断结果：\\n\\n");
            result.Append("SMTP主机：" + host + "\\n");
            result.Append("端口：" + port + "\\n");
            result.Append("SSL：" + (ssl ? "启用" : "未启用") + "\\n\\n");

            // 测试DNS解析
            try
            {
                IPHostEntry hostEntry = Dns.GetHostEntry(host);
                result.Append("✓ DNS解析成功\\n");
                if (hostEntry.AddressList.Length > 0)
                {
                    result.Append("  IP地址：" + hostEntry.AddressList[0].ToString() + "\\n");
                }
            }
            catch (Exception ex)
            {
                result.Append("✗ DNS解析失败：" + ex.Message + "\\n");
                context.Response.Write("{\"success\":0,\"message\":\"" + result.ToString() + "\"}");
                return;
            }

            // 测试端口连接
            result.Append("\\n正在测试端口连接...\\n");
            TcpClient client = null;
            try
            {
                client = new TcpClient();
                IAsyncResult ar = client.BeginConnect(host, port, null, null);
                System.Threading.WaitHandle wh = ar.AsyncWaitHandle;
                
                if (!ar.AsyncWaitHandle.WaitOne(TimeSpan.FromSeconds(5), false))
                {
                    client.Close();
                    result.Append("✗ 端口连接超时（5秒）\\n\\n");
                    result.Append("可能原因：\\n");
                    result.Append("1. 端口号错误\\n");
                    result.Append("2. 防火墙阻止连接\\n");
                    result.Append("3. 服务器网络限制\\n");
                    result.Append("4. SMTP服务器不可用\\n\\n");
                    result.Append("建议：\\n");
                    if (port == 587)
                    {
                        result.Append("- 尝试使用端口 465（SSL）\\n");
                    }
                    else if (port == 465)
                    {
                        result.Append("- 尝试使用端口 587（TLS）\\n");
                    }
                    result.Append("- 检查服务器防火墙设置\\n");
                    result.Append("- 联系服务器管理员确认网络策略\\n");
                    
                    context.Response.Write("{\"success\":0,\"message\":\"" + result.ToString() + "\"}");
                    return;
                }
                
                client.EndConnect(ar);
                result.Append("✓ 端口连接成功\\n\\n");
                
                // 检查SSL配置是否匹配
                bool configError = false;
                if (port == 465 && !ssl)
                {
                    result.Append("⚠ 配置错误：端口465必须启用SSL！\\n\\n");
                    result.Append("请在上方勾选"启用 SSL"并保存配置。\\n");
                    configError = true;
                }
                else if (port == 25 && ssl)
                {
                    result.Append("⚠ 配置警告：端口25通常不使用SSL\\n\\n");
                    result.Append("建议取消勾选"启用 SSL"。\\n");
                    configError = true;
                }
                
                if (!configError)
                {
                    result.Append("✓ SSL配置正确\\n\\n");
                    result.Append("网络连接正常，SMTP配置应该可以工作。\\n");
                    result.Append("如果发送仍然失败，请检查：\\n");
                    result.Append("1. 用户名和密码是否正确\\n");
                    result.Append("2. 是否需要使用授权码（QQ/163邮箱）\\n");
                    result.Append("3. 发件人邮箱地址是否正确\\n");
                }
                
                client.Close();
                context.Response.Write("{\"success\":" + (configError ? "0" : "1") + ",\"message\":\"" + result.ToString() + "\"}");
            }
            catch (Exception ex)
            {
                if (client != null) client.Close();
                result.Append("✗ 端口连接失败：" + ex.Message + "\\n");
                context.Response.Write("{\"success\":0,\"message\":\"" + result.ToString() + "\"}");
            }
        }
        catch (Exception ex)
        {
            string msg = ex.Message.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
            context.Response.Write("{\"success\":0,\"message\":\"诊断失败：" + msg + "\"}");
        }
    }

    private string GetValue(XmlDocument doc, string key)
    {
        try
        {
            XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
            if (node != null && node.Attributes["value"] != null)
                return node.Attributes["value"].Value ?? "";
        }
        catch { }
        return "";
    }

    public bool IsReusable { get { return false; } }
}
