#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\uploadpython.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "3B7F3AD22972B766C01C5B12608CC503"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\uploadpython.ashx"


using System;
using System.Web;

public class uploadpython : IHttpHandler
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
                    bll.SavePython(id);
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
