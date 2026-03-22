#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\templateapi.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "225625A0C53CAD2F473CC647D6BB4F6F"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\templateapi.ashx"


using System;
using System.IO;
using System.Text;
using System.Web;
using System.Xml;

public class templateapi : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AddHeader("Cache-Control", "no-cache");
        context.Response.Charset = "utf-8";

        try
        {
            string appDataDir = context.Server.MapPath("~/App_Data/");
            if (!Directory.Exists(appDataDir))
                Directory.CreateDirectory(appDataDir);

            string xmlPath = context.Server.MapPath("~/App_Data/coursetemplates.xml");

            if (!File.Exists(xmlPath))
            {
                InitBuiltinTemplates(xmlPath);
            }
            else
            {
                XmlDocument chk = new XmlDocument();
                chk.Load(xmlPath);
                if (chk.SelectNodes("//Template").Count == 0)
                    InitBuiltinTemplates(xmlPath);
            }
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            // 如果请求特定模板详情
            string templateId = context.Request.QueryString["id"];
            if (!string.IsNullOrEmpty(templateId))
            {
                XmlNode node = doc.SelectSingleNode("//Template[@id='" + templateId.Replace("'", "") + "']");
                if (node != null)
                {
                    string content = node.InnerText;
                    context.Response.Write("{\"id\":" + JsonEncode(GetAttr(node, "id"))
                        + ",\"name\":" + JsonEncode(GetAttr(node, "name"))
                        + ",\"content\":" + JsonEncode(content) + "}");
                }
                else
                {
                    context.Response.Write("{\"error\":\"模板不存在\"}");
                }
                return;
            }

            // 返回模板列表
            XmlNodeList nodes = doc.SelectNodes("//Template");

            StringBuilder sb = new StringBuilder();
            sb.Append("{\"templates\":[");

            bool first = true;
            if (nodes != null)
            {
                for (int i = 0; i < nodes.Count; i++)
                {
                    XmlNode node = nodes[i];
                    string id = GetAttr(node, "id");
                    string name = GetAttr(node, "name");
                    string type = GetAttr(node, "type");

                    if (!first) sb.Append(",");
                    first = false;

                    sb.Append("{");
                    sb.Append("\"id\":" + JsonEncode(id));
                    sb.Append(",\"name\":" + JsonEncode(name));
                    sb.Append(",\"type\":" + JsonEncode(type));
                    sb.Append("}");
                }
            }

            sb.Append("]}");
            context.Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"templates\":[],\"error\":" + JsonEncode(ex.Message) + "}");
        }
    }

    private void InitBuiltinTemplates(string xmlPath)
    {
        XmlDocument doc = new XmlDocument();
        doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><Templates></Templates>");

        AddTpl(doc, "\u65b0\u6388\u8bfe\u5b66\u6848\u6a21\u677f",
            "<h2 style=\"text-align:center;color:#1e293b;\">\u3010\u5b66\u6848\u540d\u79f0\u3011</h2><hr/>"
            + "<h3>\u4e00\u3001\u5b66\u4e60\u76ee\u6807</h3><ol><li>\u77e5\u8bc6\u4e0e\u6280\u80fd\uff1a</li><li>\u8fc7\u7a0b\u4e0e\u65b9\u6cd5\uff1a</li><li>\u60c5\u611f\u6001\u5ea6\u4e0e\u4ef7\u503c\u89c2\uff1a</li></ol>"
            + "<h3>\u4e8c\u3001\u5b66\u4e60\u91cd\u96be\u70b9</h3><p><strong>\u91cd\u70b9\uff1a</strong></p><p><strong>\u96be\u70b9\uff1a</strong></p>"
            + "<h3>\u4e09\u3001\u8bfe\u524d\u9884\u4e60</h3><p>\u8bf7\u540c\u5b66\u4eec\u9884\u4e60\u4ee5\u4e0b\u5185\u5bb9\uff1a</p><ol><li></li></ol>"
            + "<h3>\u56db\u3001\u8bfe\u5802\u63a2\u7a76</h3><h4>\u63a2\u7a76\u6d3b\u52a8\u4e00\uff1a</h4><p></p><h4>\u63a2\u7a76\u6d3b\u52a8\u4e8c\uff1a</h4><p></p>"
            + "<h3>\u4e94\u3001\u8bfe\u5802\u7ec3\u4e60</h3><ol><li></li></ol>"
            + "<h3>\u516d\u3001\u8bfe\u5802\u5c0f\u7ed3</h3><p></p>"
            + "<h3>\u4e03\u3001\u8bfe\u540e\u4f5c\u4e1a</h3><ol><li></li></ol>");

        AddTpl(doc, "\u590d\u4e60\u8bfe\u5b66\u6848\u6a21\u677f",
            "<h2 style=\"text-align:center;color:#1e293b;\">\u3010\u590d\u4e60\u8bfe\u4e3b\u9898\u3011</h2><hr/>"
            + "<h3>\u4e00\u3001\u590d\u4e60\u76ee\u6807</h3><ol><li></li></ol>"
            + "<h3>\u4e8c\u3001\u77e5\u8bc6\u68b3\u7406</h3><h4>\u77e5\u8bc6\u70b9\u4e00\uff1a</h4><p></p><h4>\u77e5\u8bc6\u70b9\u4e8c\uff1a</h4><p></p>"
            + "<h3>\u4e09\u3001\u5178\u578b\u4f8b\u9898</h3><h4>\u4f8b\u98981\uff1a</h4><p></p><p><strong>\u89e3\u6790\uff1a</strong></p>"
            + "<h3>\u56db\u3001\u5de9\u56fa\u7ec3\u4e60</h3><ol><li></li></ol>"
            + "<h3>\u4e94\u3001\u603b\u7ed3\u5f52\u7eb3</h3><p></p>");

        AddTpl(doc, "\u5b9e\u8df5\u8bfe\u5b66\u6848\u6a21\u677f",
            "<h2 style=\"text-align:center;color:#1e293b;\">\u3010\u5b9e\u8df5\u8bfe\u4e3b\u9898\u3011</h2><hr/>"
            + "<h3>\u4e00\u3001\u5b9e\u8df5\u76ee\u6807</h3><ol><li></li></ol>"
            + "<h3>\u4e8c\u3001\u5b9e\u8df5\u51c6\u5907</h3><p><strong>\u5de5\u5177\u4e0e\u6750\u6599\uff1a</strong></p><ul><li></li></ul>"
            + "<h3>\u4e09\u3001\u5b9e\u8df5\u6b65\u9aa4</h3><h4>\u6b65\u9aa4\u4e00\uff1a</h4><p></p><h4>\u6b65\u9aa4\u4e8c\uff1a</h4><p></p><h4>\u6b65\u9aa4\u4e09\uff1a</h4><p></p>"
            + "<h3>\u56db\u3001\u6ce8\u610f\u4e8b\u9879</h3><ul><li></li></ul>"
            + "<h3>\u4e94\u3001\u6210\u679c\u5c55\u793a</h3><p></p>"
            + "<h3>\u516d\u3001\u5b9e\u8df5\u53cd\u601d</h3><p></p>");

        AddTpl(doc, "\u4fe1\u606f\u79d1\u6280\u8bfe\u5b66\u6848\u6a21\u677f",
            "<h2 style=\"text-align:center;color:#1e293b;\">\u3010\u8bfe\u9898\u540d\u79f0\u3011</h2><hr/>"
            + "<h3>\u4e00\u3001\u5b66\u4e60\u76ee\u6807</h3><ol><li>\u4e86\u89e3\uff1a</li><li>\u638c\u63e1\uff1a</li><li>\u80fd\u591f\uff1a</li></ol>"
            + "<h3>\u4e8c\u3001\u77e5\u8bc6\u8bb2\u89e3</h3><h4>1. \u57fa\u672c\u6982\u5ff5</h4><p></p><h4>2. \u64cd\u4f5c\u65b9\u6cd5</h4><p></p>"
            + "<h3>\u4e09\u3001\u64cd\u4f5c\u4efb\u52a1</h3>"
            + "<h4>\u4efb\u52a1\u4e00\uff1a\u57fa\u7840\u64cd\u4f5c</h4><p><strong>\u8981\u6c42\uff1a</strong></p><ol><li></li></ol>"
            + "<h4>\u4efb\u52a1\u4e8c\uff1a\u8fdb\u9636\u64cd\u4f5c</h4><p><strong>\u8981\u6c42\uff1a</strong></p><ol><li></li></ol>"
            + "<h4>\u4efb\u52a1\u4e09\uff1a\u521b\u610f\u62d3\u5c55\uff08\u9009\u505a\uff09</h4><p><strong>\u8981\u6c42\uff1a</strong></p><ol><li></li></ol>"
            + "<h3>\u56db\u3001\u5b66\u4e60\u8bc4\u4ef7</h3><p>\u8bf7\u5bf9\u81ea\u5df1\u672c\u8282\u8bfe\u7684\u5b66\u4e60\u60c5\u51b5\u8fdb\u884c\u8bc4\u4ef7\uff1a</p>"
            + "<ul><li>\u57fa\u7840\u64cd\u4f5c\u5b8c\u6210\u60c5\u51b5\uff1a\u2606\u2606\u2606\u2606\u2606</li>"
            + "<li>\u8fdb\u9636\u64cd\u4f5c\u5b8c\u6210\u60c5\u51b5\uff1a\u2606\u2606\u2606\u2606\u2606</li></ul>"
            + "<h3>\u4e94\u3001\u8bfe\u5802\u5c0f\u7ed3</h3><p></p>");

        doc.Save(xmlPath);
    }

    private void AddTpl(XmlDocument doc, string name, string content)
    {
        XmlElement tpl = doc.CreateElement("Template");
        tpl.SetAttribute("id", Guid.NewGuid().ToString("N"));
        tpl.SetAttribute("name", name);
        tpl.SetAttribute("type", "builtin");
        tpl.SetAttribute("createTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
        tpl.SetAttribute("creator", "\u7cfb\u7edf");
        XmlCDataSection cdata = doc.CreateCDataSection(content);
        tpl.AppendChild(cdata);
        doc.DocumentElement.AppendChild(tpl);
    }

    private string GetAttr(XmlNode node, string name)
    {
        if (node.Attributes[name] != null)
            return node.Attributes[name].Value;
        return "";
    }

    private string JsonEncode(string s)
    {
        if (s == null) return "\"\"";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t") + "\"";
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
