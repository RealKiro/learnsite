<%@ Page Language="C#" %><%
    Response.Clear();
    Response.ContentType = "application/javascript";
    Response.Write(System.IO.File.ReadAllText(Server.MapPath("qrcanvas3.js")));
    Response.Flush();
    HttpContext.Current.ApplicationInstance.CompleteRequest();
%>
