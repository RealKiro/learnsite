#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\saveform.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "FA5D3E65435C36BEDA3099674634A398"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\saveform.ashx"


using System;
using System.Web;

public class saveform : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        string result = savemyform();
        context.Response.Write(result);
    }

    private string savemyform()
    {
        LearnSite.BLL.TxtFormBack tkbll = new LearnSite.BLL.TxtFormBack();
        return tkbll.SaveFormContent();
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}

#line default
#line hidden
