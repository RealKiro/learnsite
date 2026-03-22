#pragma checksum "C:\inetpub\wwwroot\LearnSite\manager\bindemail_test.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "7B868D4C5F25E2E59CEEAFB67C4D7586"

#line 1 "C:\inetpub\wwwroot\LearnSite\manager\bindemail_test.ashx"


using System;
using System.Web;
using System.Web.SessionState;

public class bindemail_test : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        
        try
        {
            string action = context.Request.QueryString["action"];
            
            if (string.IsNullOrEmpty(action))
            {
                context.Response.Write("{\"success\":false,\"message\":\"No action specified\",\"test\":\"API is working\"}");
                return;
            }
            
            if (action == "sendcode")
            {
                context.Response.Write("{\"success\":false,\"message\":\"Test mode - sendcode endpoint\"}");
            }
            else if (action == "bind")
            {
                context.Response.Write("{\"success\":false,\"message\":\"Test mode - bind endpoint\"}");
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"Invalid action: " + action + "\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"Error: " + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    public bool IsReusable 
    { 
        get { return false; } 
    }
}


#line default
#line hidden
