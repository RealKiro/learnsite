#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\judgesave.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "2B615400E8CFE2AD86E7C568513B2BA7"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\judgesave.ashx"


using System;
using System.Web;

public class judgesave : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        if (context.Request.QueryString["id"] != null)
        {
            string id = context.Request.QueryString["id"].ToString();
            LearnSite.BLL.JudgeArg jbll = new LearnSite.BLL.JudgeArg();
            try
            {
                if (context.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname] != null)
                {

                    LearnSite.Model.TeaCook tcook = new LearnSite.Model.TeaCook();
                    int newid= jbll.Addsave(Int32.Parse(id),tcook.Hid);
                    context.Response.Write(newid);
                }
                else
                    context.Response.Write(-1);

            }
            catch(Exception ex)
            {
                context.Response.Write(ex.ToString());
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}

#line default
#line hidden
