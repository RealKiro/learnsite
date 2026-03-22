#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\getpo.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "56B6087B18287BCCDD8CDD8DFA6354DB"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\getpo.ashx"


using System;
using System.Web;

public class getpo : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        if (context.Request.QueryString["lang"] != null)
        {
            string lang = context.Request.QueryString["lang"].ToString();
            string pofile = "~/Statics/locale/" + lang + ".po";
            string popath = context.Server.MapPath(pofile);
            //获取文件的二进制数据。
            string datas = System.IO.File.ReadAllText(popath);
            //将二进制数据写入到输出流中。
            HttpContext.Current.Response.Write(datas);
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
