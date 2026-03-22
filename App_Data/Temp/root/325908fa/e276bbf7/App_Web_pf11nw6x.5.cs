#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\uploadproject.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "A7D1B32033B3651DA9C5697A72508C1C"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\uploadproject.ashx"


using System;
using System.Web;
using System.IO;

public class GenericHandler1 : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.QueryString["id"] != null)
        {
            string id = context.Request.QueryString["id"].ToString();
            LearnSite.BLL.Works bll = new LearnSite.BLL.Works();
            try
            {
                if (context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname] != null)
                {
                    bll.SaveProject(id);
                    context.Response.Write("保存成功！");
                }
                else
                    context.Response.Write("保存失败！");
            }
            catch
            {
                context.Response.Write("保存失败！");
            }
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}

#line default
#line hidden
