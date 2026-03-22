#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\savechat.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "25EAD870BC68779188BAF6D8A82DA8ED"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\savechat.ashx"


using System;
using System.Web;

public class savechat : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";

        string dic = HttpContext.Current.Request.Form["dic"];
        string result = LearnSite.Common.chathistory.add(dic).ToString();

        context.Response.Write(result);//返回内存表记录数
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}

#line default
#line hidden
