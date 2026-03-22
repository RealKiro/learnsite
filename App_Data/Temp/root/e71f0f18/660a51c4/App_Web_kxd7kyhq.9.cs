#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\SaveChinese.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "661AC4F7BB5E8FACD5A65CEA4837C0C8"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\LearnSite信息学习平台2026-1-5\student\SaveChinese.ashx"


using System;
using System.Web;

public class SaveChinese : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string Ptotal = context.Request.QueryString["Apples"].ToString();
        string Pspeed = context.Request.QueryString["Speed"].ToString();
        int result = 0;

        LearnSite.BLL.Pchinese pcbll = new LearnSite.BLL.Pchinese();
        //更新一条记录，如是不存在，则插入一条记录
        result = pcbll.UpdateChineseType(Int32.Parse(Ptotal), Int32.Parse(Pspeed));
        
        context.Response.Write(result.ToString());
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

#line default
#line hidden
