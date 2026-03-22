#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\uploadblock.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "334EFADE3990BA3DF0742A69BA88B43B"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\uploadblock.ashx"


using System;
using System.Web;

public class uploadblock : IHttpHandler {

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
                    bll.SaveBlock(id);
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
