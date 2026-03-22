<%@ WebHandler Language="C#" Class="feedback_handler" %>

using System;
using System.IO;
using System.Web;
using System.Text;
using System.Xml;

public class feedback_handler : IHttpHandler
{
    private void WriteJson(HttpContext context, string json)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        byte[] data = Encoding.UTF8.GetBytes(json);
        context.Response.OutputStream.Write(data, 0, data.Length);
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }

    /// <summary>
    /// 从学生 cookie 中解析用户信息
    /// </summary>
    private void GetStudentInfo(HttpContext context, out string studentName, out string studentNum)
    {
        studentName = "";
        studentNum = "";
        try
        {
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); }
                    catch { }
                }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public |
                        System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                    System.Reflection.PropertyInfo pName = ct.GetProperty("Sname");
                    if (pName != null)
                    {
                        object v = pName.GetValue(m, null);
                        if (v != null) studentName = v.ToString();
                        if (!string.IsNullOrEmpty(studentName) && studentName.Contains("%"))
                        {
                            try { studentName = HttpUtility.UrlDecode(studentName, Encoding.UTF8); } catch { }
                        }
                    }

                    System.Reflection.PropertyInfo pNum = ct.GetProperty("Snum");
                    if (pNum != null)
                    {
                        object v = pNum.GetValue(m, null);
                        if (v != null) studentNum = v.ToString();
                    }
                }
            }
        }
        catch { }

        // 尝试教师 cookie
        if (string.IsNullOrEmpty(studentName))
        {
            try
            {
                HttpCookie tc = context.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
                if (tc != null && !string.IsNullOrEmpty(tc.Value))
                {
                    string cookieVal = tc.Value;
                    if (cookieVal.Contains("%"))
                    {
                        try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); }
                        catch { }
                    }
                    Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                    if (ct != null)
                    {
                        object m = Activator.CreateInstance(ct);
                        System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                            System.Reflection.BindingFlags.Public |
                            System.Reflection.BindingFlags.NonPublic |
                            System.Reflection.BindingFlags.Instance);
                        if (mi != null) mi.Invoke(m, new object[] { cookieVal });

                        System.Reflection.PropertyInfo pName = ct.GetProperty("Hname");
                        if (pName != null)
                        {
                            object v = pName.GetValue(m, null);
                            if (v != null) studentName = v.ToString();
                            if (!string.IsNullOrEmpty(studentName) && studentName.Contains("%"))
                            {
                                try { studentName = HttpUtility.UrlDecode(studentName, Encoding.UTF8); } catch { }
                            }
                        }
                    }
                }
            }
            catch { }

            if (!string.IsNullOrEmpty(studentName))
                studentNum = "教师";
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        string action = context.Request.QueryString["action"] ?? "";

        switch (action)
        {
            case "submit":
                HandleSubmit(context);
                break;
            case "list":
                HandleList(context);
                break;
            default:
                WriteJson(context, "{\"success\":0,\"message\":\"未知操作\"}");
                break;
        }
    }

    private void HandleSubmit(HttpContext context)
    {
        try
        {
            string type = (context.Request.Form["type"] ?? context.Request.QueryString["type"] ?? "").Trim();
            string content = (context.Request.Form["content"] ?? context.Request.QueryString["content"] ?? "").Trim();

            if (string.IsNullOrEmpty(type))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"请选择问题类型\"}");
                return;
            }
            if (string.IsNullOrEmpty(content))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"请填写问题描述\"}");
                return;
            }
            if (content.Length > 2000)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"内容过长，请控制在2000字以内\"}");
                return;
            }

            string studentName, studentNum;
            GetStudentInfo(context, out studentName, out studentNum);
            if (string.IsNullOrEmpty(studentName)) studentName = "匿名用户";
            if (string.IsNullOrEmpty(studentNum)) studentNum = "";

            string xmlPath = context.Server.MapPath("~/App_Data/feedback.xml");
            string dir = Path.GetDirectoryName(xmlPath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            // 加锁保证并发安全
            lock (typeof(feedback_handler))
            {
                XmlDocument doc = new XmlDocument();
                if (File.Exists(xmlPath))
                {
                    doc.Load(xmlPath);
                }
                else
                {
                    doc.AppendChild(doc.CreateXmlDeclaration("1.0", "utf-8", null));
                    doc.AppendChild(doc.CreateElement("feedbacks"));
                }

                XmlNode root = doc.SelectSingleNode("//feedbacks");
                if (root == null)
                {
                    root = doc.CreateElement("feedbacks");
                    doc.AppendChild(root);
                }

                // 生成唯一 ID
                string id = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100, 999).ToString();

                XmlElement item = doc.CreateElement("item");
                item.SetAttribute("id", id);
                item.SetAttribute("type", type);
                item.SetAttribute("studentName", studentName);
                item.SetAttribute("studentNum", studentNum);
                item.SetAttribute("submitDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                item.SetAttribute("status", "pending");

                XmlElement contentEl = doc.CreateElement("content");
                contentEl.AppendChild(doc.CreateCDataSection(content));
                item.AppendChild(contentEl);

                XmlElement replyEl = doc.CreateElement("reply");
                item.AppendChild(replyEl);

                // 插入到最前面（最新的在前）
                if (root.FirstChild != null)
                    root.InsertBefore(item, root.FirstChild);
                else
                    root.AppendChild(item);

                doc.Save(xmlPath);
            }

            WriteJson(context, "{\"success\":1,\"message\":\"反馈提交成功，感谢你的意见！\"}");
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"提交失败：" + EscapeJson(ex.Message) + "\"}");
        }
    }

    private void HandleList(HttpContext context)
    {
        try
        {
            string studentName, studentNum;
            GetStudentInfo(context, out studentName, out studentNum);
            if (string.IsNullOrEmpty(studentName))
            {
                WriteJson(context, "{\"success\":0,\"message\":\"请先登录\"}");
                return;
            }

            string xmlPath = context.Server.MapPath("~/App_Data/feedback.xml");
            if (!File.Exists(xmlPath))
            {
                WriteJson(context, "{\"success\":1,\"data\":[]}");
                return;
            }

            StringBuilder sb = new StringBuilder();
            sb.Append("{\"success\":1,\"data\":[");

            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNodeList items = doc.SelectNodes("//feedbacks/item");
            bool first = true;
            if (items != null)
            {
                foreach (XmlNode node in items)
                {
                    string itemName = node.Attributes["studentName"] != null ? node.Attributes["studentName"].Value : "";
                    if (!string.IsNullOrEmpty(itemName) && itemName.Contains("%"))
                    {
                        try { itemName = HttpUtility.UrlDecode(itemName, Encoding.UTF8); } catch { }
                    }
                    string itemNum = node.Attributes["studentNum"] != null ? node.Attributes["studentNum"].Value : "";

                    // 匹配当前用户
                    if (itemName != studentName) continue;
                    if (studentNum != "教师" && itemNum != studentNum) continue;

                    if (!first) sb.Append(",");
                    first = false;

                    string id = node.Attributes["id"] != null ? node.Attributes["id"].Value : "";
                    string type = node.Attributes["type"] != null ? node.Attributes["type"].Value : "";
                    string submitDate = node.Attributes["submitDate"] != null ? node.Attributes["submitDate"].Value : "";
                    string status = node.Attributes["status"] != null ? node.Attributes["status"].Value : "pending";

                    XmlNode contentNode = node.SelectSingleNode("content");
                    string content = contentNode != null ? contentNode.InnerText : "";

                    XmlNode replyNode = node.SelectSingleNode("reply");
                    string reply = replyNode != null ? replyNode.InnerText : "";
                    string replyDate = replyNode != null && replyNode.Attributes["date"] != null ? replyNode.Attributes["date"].Value : "";

                    sb.Append("{");
                    sb.Append("\"id\":\"" + EscapeJson(id) + "\"");
                    sb.Append(",\"type\":\"" + EscapeJson(type) + "\"");
                    sb.Append(",\"content\":\"" + EscapeJson(content) + "\"");
                    sb.Append(",\"submitDate\":\"" + EscapeJson(submitDate) + "\"");
                    sb.Append(",\"status\":\"" + EscapeJson(status) + "\"");
                    sb.Append(",\"reply\":\"" + EscapeJson(reply) + "\"");
                    sb.Append(",\"replyDate\":\"" + EscapeJson(replyDate) + "\"");
                    sb.Append("}");
                }
            }

            sb.Append("]}");
            WriteJson(context, sb.ToString());
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"加载失败：" + EscapeJson(ex.Message) + "\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
