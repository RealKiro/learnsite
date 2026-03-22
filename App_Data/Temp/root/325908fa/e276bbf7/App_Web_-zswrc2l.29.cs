#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\SaveHandler.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "7218437A2CBE22DE5BC416A3E87F9D48"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\SaveHandler.ashx"

using System;
using System.Web;

public class SaveHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string mspd = HttpContext.Current.Request.Form["mspd"];
        string rstr = "0";
        LearnSite.BLL.Pfinger pbll = new LearnSite.BLL.Pfinger();
        if (pbll.saveSpd(mspd))
            rstr = "1";
        context.Response.Write(rstr);
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
