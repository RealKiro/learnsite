#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\knowledgeapi.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "19BB2DDFC5D4B5D96994624354066B57"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\knowledgeapi.ashx"


using System;
using System.IO;
using System.Text;
using System.Web;
using System.Xml;

public class knowledgeapi : IHttpHandler
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

            string xmlPath = context.Server.MapPath("~/App_Data/knowledge.xml");

            if (!File.Exists(xmlPath))
            {
                XmlDocument newDoc = new XmlDocument();
                newDoc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><KnowledgeBase></KnowledgeBase>");
                newDoc.Save(xmlPath);
            }
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);

            XmlNodeList nodes = doc.SelectNodes("//Item");

            StringBuilder sb = new StringBuilder();
            sb.Append("{\"items\":[");

            bool first = true;
            if (nodes != null)
            {
                for (int i = nodes.Count - 1; i >= 0; i--)
                {
                    XmlNode node = nodes[i];
                    string id = GetAttr(node, "id");
                    string title = GetAttr(node, "title");
                    string category = GetAttr(node, "category");
                    string originalName = GetAttr(node, "originalName");
                    string ext = GetAttr(node, "ext");
                    string uploadTime = GetAttr(node, "uploadTime");

                    if (!first) sb.Append(",");
                    first = false;

                    sb.Append("{");
                    sb.Append("\"id\":" + JsonEncode(id));
                    sb.Append(",\"title\":" + JsonEncode(title));
                    sb.Append(",\"category\":" + JsonEncode(category));
                    sb.Append(",\"originalName\":" + JsonEncode(originalName));
                    sb.Append(",\"ext\":" + JsonEncode(ext));
                    sb.Append(",\"uploadTime\":" + JsonEncode(uploadTime));
                    sb.Append("}");
                }
            }

            sb.Append("]}");
            context.Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"items\":[],\"error\":" + JsonEncode(ex.Message) + "}");
        }
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
