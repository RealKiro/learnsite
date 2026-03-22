<%@ WebHandler Language="C#" Class="getsiteconfig" %>

using System;
using System.Web;
using System.Xml;

public class getsiteconfig : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string xmlPath = context.Server.MapPath("~/website.xml");
            string siteName = "信息科技学习平台";
            string logo = "";
            
            // 读取网站名称
            if (System.IO.File.Exists(xmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(xmlPath);
                
                XmlNode nameNode = doc.SelectSingleNode("//add[@key='SiteName']");
                if (nameNode != null && nameNode.Attributes["value"] != null)
                {
                    string val = nameNode.Attributes["value"].Value;
                    if (!string.IsNullOrEmpty(val)) siteName = val;
                }
            }
            
            // 查找Logo文件（按照setting.aspx的逻辑）
            string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp" };
            foreach (string ext in exts)
            {
                string logoPath = context.Server.MapPath("~/images/site-logo" + ext);
                if (System.IO.File.Exists(logoPath))
                {
                    logo = "images/site-logo" + ext;
                    break;
                }
            }
            
            context.Response.Write("{\"success\":true,\"siteName\":\"" + JsonEscape(siteName) + "\",\"logo\":\"" + JsonEscape(logo) + "\"}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + JsonEscape(ex.Message) + "\"}");
        }
    }
    
    private string JsonEscape(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";
        return str.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n").Replace("\t", "\\t");
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}
