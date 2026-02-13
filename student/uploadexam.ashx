<%@ WebHandler Language="C#" Class="uploadexam" %>

using System;
using System.Web;

public class uploadexam : IHttpHandler
{    
    public void ProcessRequest (HttpContext context) {
        LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
        if (cook.IsExist())
        {
            string selectstr = HttpContext.Current.Request.Form["selectstr"];
            string score = HttpContext.Current.Request.Form["score"];
            string lidstr = HttpContext.Current.Request.Form["lidstr"];
            string cidstr = HttpContext.Current.Request.Form["cidstr"];
            string vidstr = HttpContext.Current.Request.Form["vidstr"];
            string vtypestr = HttpContext.Current.Request.Form["vtypestr"];

            string Wtime = cook.LoginTime;
            DateTime Wdate = DateTime.Now;
            LearnSite.Model.SurveyFeedback fmodel = new LearnSite.Model.SurveyFeedback();
            fmodel.Fnum = cook.Snum;
            fmodel.Fyear = cook.Syear;
            fmodel.Fgrade = cook.Sgrade;
            fmodel.Fclass = cook.Sclass;
            fmodel.Fterm = cook.ThisTerm;
            fmodel.Fcid = Int32.Parse(cidstr);
            fmodel.Fvid = Int32.Parse(vidstr);
            fmodel.Fvtype = Int32.Parse(vtypestr);
            fmodel.Fselect = selectstr;
            fmodel.Fscore = Int32.Parse(score);
            fmodel.Fdate = DateTime.Now;
            fmodel.Fsid = cook.Sid;
            fmodel.Flid = Int32.Parse(lidstr);

            LearnSite.BLL.SurveyFeedback fbll = new LearnSite.BLL.SurveyFeedback();
            if (fbll.Add(fmodel) > 0)
            {
                //添加课堂活动记录
                LearnSite.Model.MenuWorks kmodel = new LearnSite.Model.MenuWorks();
                kmodel.Klid = Int32.Parse(lidstr);
                kmodel.Ksid = cook.Sid;
                kmodel.Ktime = LearnSite.Common.Computer.GoneMinute(DateTime.Parse(Wtime), Wdate);
                kmodel.Kcheck = false;
                LearnSite.BLL.MenuWorks kbll = new LearnSite.BLL.MenuWorks();
                kbll.Add(kmodel);
                context.Response.Write("ok");
            }
            else
            {
                context.Response.Write("no");
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}