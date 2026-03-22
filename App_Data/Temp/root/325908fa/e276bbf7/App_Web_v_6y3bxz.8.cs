#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\teacher\getproject.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "BC3CB4C821033E47FC3E5C722CEF8371"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\teacher\getproject.ashx"


using System;
using System.Web;
using System.IO;
public class getproject : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.QueryString["id"] != null)
        {
            string id=context.Request.QueryString["id"].ToString();
            LearnSite.BLL.Works bll = new LearnSite.BLL.Works();
            bll.SworkToBytes(id);           
        }
        else
            context.Response.BinaryWrite(null);
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
