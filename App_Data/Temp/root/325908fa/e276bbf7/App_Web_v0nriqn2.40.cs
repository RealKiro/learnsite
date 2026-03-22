#pragma checksum "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\ChineseHandler.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "913F7F3D527AC239B3C0DB26382C0016"

#line 1 "C:\Users\Administrator\Downloads\LearnSite2026-1-5\LearnSite2\student\ChineseHandler.ashx"


using System;
using System.Web;

public class ChineseHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string Nid = context.Request.QueryString["Nid"].ToString();
        string ChineseWords = GetWords(Nid);

        context.Response.Write(FormatWords(ChineseWords));
    }

    private string GetWords(string Nid)
    {
        LearnSite.BLL.Chinese cbll = new LearnSite.BLL.Chinese();
        return cbll.GetContent(Nid);
    }
    private string FormatWords(string words)
    {
        int wcount = words.Length;
        words = words.Trim();
        words = words.Replace('\r', ' ');
        words = words.Replace('\n', ' ');
        words = words.Replace("  ", " ");
        words = words.Replace("  ", " ");
        string[] sArray = words.Split(new char[] { '，', '。', '；', '？', '！','“','”', '：', ' ', '　' });
        string temp = "";
        foreach (string c in sArray)
        {
            if (LearnSite.Common.WordProcess.IsZh(c))
                temp = temp + c.Trim() + "|";
        }
        temp = temp.TrimEnd('|');
        return temp;
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
