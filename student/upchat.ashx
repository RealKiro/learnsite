<%@ WebHandler Language="C#" Class="upchat" %>

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