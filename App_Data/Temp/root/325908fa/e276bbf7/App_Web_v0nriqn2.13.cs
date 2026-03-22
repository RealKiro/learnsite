#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\uploadhtml.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "F81FBFE382A813E9B0AA300C147ECD51"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\uploadhtml.ashx"


using System;
using System.Web;

public class uploadhtml : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        if (context.Request.QueryString["id"] != null)
        {
            string id = context.Request.QueryString["id"].ToString();
            LearnSite.BLL.Works bll = new LearnSite.BLL.Works();
            try
            {
                if (context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname] != null)
                {
                    bll.SaveHtml(id);
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
