#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\FingerHandler.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "C32B9DBE573D098B0599FF8472FDFC5A"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\FingerHandler.ashx"


using System;
using System.Web;

public class FingerHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string myelevel = context.Request.QueryString["MyElevel"].ToString();
        string eh = "";
        if (!string.IsNullOrEmpty(myelevel))
        {
            LearnSite.BLL.English bl = new LearnSite.BLL.English();
            eh = bl.GetLevelwords(Int32.Parse(myelevel));
        }
        context.Response.Write(eh);
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
