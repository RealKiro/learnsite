#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\uploadgraph.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "2D0C0E37145099A0554C2561F41B2D4F"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\uploadgraph.ashx"


using System;
using System.Web;

public class uploadgraph : IHttpHandler
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
                    bll.SaveGraph(id);
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
