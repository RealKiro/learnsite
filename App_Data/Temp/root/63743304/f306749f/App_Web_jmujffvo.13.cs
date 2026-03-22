#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\uploadmqtt.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "C741A3B747A8DBE20DDE1F61B242078D"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\uploadmqtt.ashx"


using System;
using System.Web;

public class uploadmqtt : IHttpHandler {

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
                    bll.SaveMqtt(id);
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
