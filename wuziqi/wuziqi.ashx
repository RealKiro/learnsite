<%@ WebHandler Language="C#" Class="wuziqi" %>

using System;
using System.Web;

public class wuziqi : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string Title = context.Request.QueryString["Title"].ToString();
        string Level = context.Request.QueryString["Mode"].ToString();
        string Step = context.Request.QueryString["Rounds"].ToString();
        string Note = HttpContext.Current.Request.Form["History"];
        string myLevel = HttpContext.Current.Request.Form["Mode"];
        string myUndo = HttpContext.Current.Request.Form["Undo"];

        LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
        LearnSite.BLL.Game bll = new LearnSite.BLL.Game();

        LearnSite.Model.Game model = new LearnSite.Model.Game();
        model.Gsid = cook.Sid;
        model.Gsname = HttpUtility.UrlDecode(cook.Sname);
        model.Gtitle = Title;
        model.Gsave = 0;
        switch (myLevel)
        {
            case "novice":
                model.Gsave = 1;
                break;
            case "medium":
                model.Gsave = 2;
                break;
            case "expert":
                model.Gsave = 3;
                break;
        }
        model.Gnote = Note;
        model.Gnum = Int32.Parse(Step);
        model.Gdate = DateTime.Now;
        model.Gscore = Int32.Parse(myUndo); ;

        bll.Add(model);

        context.Response.Write("ok");
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}