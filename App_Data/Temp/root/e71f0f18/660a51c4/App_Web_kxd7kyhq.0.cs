#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\Savetype.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "CB4571069A34DBC6FA244EAB420EC7C5"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\Savetype.ashx"


using System;
using System.Web;

public class Savetype : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string Ptid = context.Request.QueryString["Ptid"].ToString();
        string TypeScore = context.Request.Form["Ts"].ToString();

        LearnSite.BLL.Ptyper bll = new LearnSite.BLL.Ptyper();
        context.Response.Write(bll.Savemytype(Ptid, TypeScore));
    } 
        
    public bool IsReusable {
        get {
            return false;
        }
    }    

}

#line default
#line hidden
