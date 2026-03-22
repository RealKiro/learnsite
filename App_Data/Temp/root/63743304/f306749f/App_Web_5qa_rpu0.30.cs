#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\scheduleapi.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "B8CB864103000F8DBE6F2FB0F7E3BCF9"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\scheduleapi.ashx"


using System;
using System.Web;
using System.IO;
using System.Text;

public class ScheduleAPI : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;
        
        string action = context.Request["action"];
        
        try
        {
            if (action == "load")
            {
                LoadSchedule(context);
            }
            else if (action == "save")
            {
                SaveSchedule(context);
            }
            else
            {
                context.Response.Write("{\"success\":0,\"message\":\"Invalid action\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":0,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
        }
    }
    
    private void LoadSchedule(HttpContext context)
    {
        string jsonPath = context.Server.MapPath("~/App_Data/schedule.json");
        
        if (File.Exists(jsonPath))
        {
            string data = File.ReadAllText(jsonPath, Encoding.UTF8);
            context.Response.Write(data);
        }
        else
        {
            // 返回默认空课程表
            context.Response.Write(GetDefaultSchedule());
        }
    }
    
    private void SaveSchedule(HttpContext context)
    {
        string data = context.Request["data"];
        
        if (string.IsNullOrEmpty(data))
        {
            context.Response.Write("{\"success\":0,\"message\":\"No data\"}");
            return;
        }
        
        string jsonPath = context.Server.MapPath("~/App_Data/schedule.json");
        File.WriteAllText(jsonPath, data, Encoding.UTF8);
        
        context.Response.Write("{\"success\":1,\"message\":\"保存成功\"}");
    }
    
    private string GetDefaultSchedule()
    {
        return @"{
            ""title"":""课程表"",
            ""subtitle"":""2026年春季学期"",
            ""periods"":[
                {""name"":""第一节"",""time"":""08:00-08:45""},
                {""name"":""第二节"",""time"":""08:55-09:40""},
                {""name"":""第三节"",""time"":""10:00-10:45""},
                {""name"":""第四节"",""time"":""10:55-11:40""},
                {""name"":""第五节"",""time"":""14:00-14:45""},
                {""name"":""第六节"",""time"":""14:55-15:40""},
                {""name"":""第七节"",""time"":""15:50-16:35""}
            ],
            ""days"":[""星期一"",""星期二"",""星期三"",""星期四"",""星期五""],
            ""courses"":{}
        }";
    }
    
    private string EscapeJson(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";
        return str.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }
    
    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
