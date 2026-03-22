#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\uploadmedia.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "9068065B2B0F51AAC1974D22CE9BB7A7"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\uploadmedia.ashx"


using System;
using System.Web;
using Newtonsoft.Json;
using System.IO;

public class uploadmedia : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
        Message result = new Message();
        result.url="";
        result.size ="";
        if (cook.IsExist())
        {
            DateTime Wdate = DateTime.Now;
            string mediacenter = "~/mediacenter/";
            string stumedia = "~/mediacenter/" + cook.Snum + "/";
            string mediapath = HttpContext.Current.Server.MapPath(mediacenter);
            string stupath = HttpContext.Current.Server.MapPath(stumedia);
            if (!Directory.Exists(mediapath))
            {
                Directory.CreateDirectory(mediapath);
            }
            else
            {
                if (!Directory.Exists(stupath))
                {
                    Directory.CreateDirectory(stupath);
                }
            }
            try
            {
                HttpPostedFile mediafile = HttpContext.Current.Request.Files["file"];
                if (mediafile.ContentLength > 0)
                {
                    string fname = mediafile.FileName;
                    fname = LearnSite.Common.WordProcess.FilterFName(fname);
                    string flen = (mediafile.ContentLength / 1024).ToString();
                    string saveUrl = stumedia + fname;
                    string savePath = HttpContext.Current.Server.MapPath(saveUrl);
                    mediafile.SaveAs(savePath);
                    result.url = saveUrl.Replace("~","..");
                    result.size = flen;
                    string jsonstring = JsonConvert.SerializeObject(result);
                    context.Response.Write(jsonstring);
                }
            }
            catch (Exception ec)
            {
                LearnSite.Common.Log.Addlog("保存出错信息", ec.StackTrace);// ec.StackTrace可以出详细信息
            }
        }
        else
        {
            string jsonstr = JsonConvert.SerializeObject(result);
            context.Response.Write(jsonstr);
        }
    }

    public class Message
    {
        public string url;
        public string size;
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}

#line default
#line hidden
