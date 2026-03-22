#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\uploadtopic.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "6E82EE841692A17D5A21FA22A7B957AB"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\uploadtopic.ashx"


using System;
using System.Web;

public class uploadpixel : IHttpHandler {

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
                    bll.SaveTopic(id);
                    context.Response.Write("保存成功！");
                }
                else
                    context.Response.Write("请重新登录，保存失败！");
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
