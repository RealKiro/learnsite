<%@ WebHandler Language="C#" Class="bindemail_test" %>

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
