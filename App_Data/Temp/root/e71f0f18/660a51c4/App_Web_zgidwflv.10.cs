#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\upchat.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "B72D537C90F259EA3038E08BDDF4E98D"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\upchat.ashx"


using System;
using System.Web;

public class upchat : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        string result = LearnSite.Common.chathistory.UpChatFile();
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
