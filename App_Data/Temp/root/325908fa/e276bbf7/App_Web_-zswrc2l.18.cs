#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\share.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "14A69CA54BE48F97E4A6BEBF3E4748FE"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\share.ashx"


using System;
using System.Web;

public class share : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {

        string result = "";
        if (context.Request.QueryString["isweb"] != null)
        {
            string isweb = context.Request.QueryString["isweb"].ToString();
            result = LearnSite.Common.ShareDisk.SaveWebNew();
        }
        if (context.Request.QueryString["isgroup"] != null && context.Request.QueryString["iscommon"]!=null)
        {
            string isgroup = context.Request.QueryString["isgroup"].ToString();
            string iscommon = context.Request.QueryString["iscommon"].ToString();
            result = LearnSite.Common.ShareDisk.SaveFileNew(bool.Parse(isgroup), bool.Parse(iscommon));
        }
        context.Response.Write(result);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}

#line default
#line hidden
