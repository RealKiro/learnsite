#pragma checksum "C:\inetpub\wwwroot\LearnSite\App_Code\TopicDiscussParameterValidator.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "C6FF9A67D33A26B93AE51F7898BAD5D8"

#line 1 "C:\inetpub\wwwroot\LearnSite\App_Code\TopicDiscussParameterValidator.cs"
using System;
using System.Web;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// HTTP 模块：验证 topicdiscuss.aspx 页面的必需参数
/// 如果缺少 lid 或 tid 参数，重定向到错误页面或添加默认值
/// </summary>
public class TopicDiscussParameterValidator : IHttpModule
{
    public void Init(HttpApplication context)
    {
        context.BeginRequest += new EventHandler(OnBeginRequest);
    }

    private void OnBeginRequest(object sender, EventArgs e)
    {
        HttpApplication app = (HttpApplication)sender;
        HttpContext context = app.Context;
        
        try
        {
            // 只处理 topicdiscuss.aspx 页面
            string path = context.Request.Path.ToLower();
            if (path.Contains("/student/topicdiscuss.aspx"))
            {
                string lid = context.Request.QueryString["lid"];
                string tid = context.Request.QueryString["tid"];
                string cid = context.Request.QueryString["cid"];
                
                // 如果缺少必需的参数
                if (string.IsNullOrEmpty(lid) && string.IsNullOrEmpty(tid))
                {
                    // 如果只有 cid，尝试从数据库获取默认的讨论ID
                    if (!string.IsNullOrEmpty(cid))
                    {
                        try
                        {
                            string defaultLid = GetDefaultLidFromDatabase(cid);
                            if (!string.IsNullOrEmpty(defaultLid))
                            {
                                // 重定向到包含 lid 的 URL
                                string newUrl = context.Request.Path + "?cid=" + HttpUtility.UrlEncode(cid) + "&lid=" + HttpUtility.UrlEncode(defaultLid);
                                if (context.Request.QueryString.Count > 1)
                                {
                                    // 保留其他查询参数
                                    foreach (string key in context.Request.QueryString.AllKeys)
                                    {
                                        if (key != null && key != "cid" && key != "lid" && key != "tid")
                                        {
                                            string value = context.Request.QueryString[key];
                                            if (!string.IsNullOrEmpty(value))
                                            {
                                                newUrl += "&" + HttpUtility.UrlEncode(key) + "=" + HttpUtility.UrlEncode(value);
                                            }
                                        }
                                    }
                                }
                                context.Response.Redirect(newUrl, false);
                                context.ApplicationInstance.CompleteRequest();
                                return;
                            }
                        }
                        catch
                        {
                            // 数据库查询失败，继续显示错误页面
                        }
                    }
                    
                    // 如果无法获取默认值，显示错误页面
                    ShowErrorPage(context);
                    context.ApplicationInstance.CompleteRequest();
                }
            }
        }
        catch (Exception ex)
        {
            // 如果发生错误，记录但不阻止请求继续
            try
            {
                System.Diagnostics.Debug.WriteLine("TopicDiscussParameterValidator Error: " + ex.Message);
            }
            catch
            {
                // 忽略日志记录错误
            }
        }
    }
    
    private void ShowErrorPage(HttpContext context)
    {
        context.Response.Clear();
        context.Response.StatusCode = 400;
        context.Response.StatusDescription = "Bad Request";
        context.Response.ContentType = "text/html; charset=utf-8";
        context.Response.Write(@"
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
    <title>参数错误</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial, sans-serif; padding: 40px; background: #f5f5f5; }
        .error-box { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #d32f2f; margin-top: 0; }
        .info { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
        .code { background: #f5f5f5; padding: 10px; font-family: monospace; margin: 10px 0; border-radius: 4px; }
    </style>
</head>
<body>
    <div class='error-box'>
        <h1>⚠️ 参数错误</h1>
        <p>讨论页面需要 <strong>lid</strong>（讨论ID）或 <strong>tid</strong>（主题ID）参数。</p>
        <div class='info'>
            <strong>正确的URL格式：</strong>
            <div class='code'>topicdiscuss.aspx?lid=2&cid=3</div>
            或
            <div class='code'>topicdiscuss.aspx?tid=1&cid=3</div>
        </div>
        <p>当前URL：<code>" + HttpUtility.HtmlEncode(context.Request.RawUrl) + @"</code></p>
        <p><a href='javascript:history.back()'>返回上一页</a></p>
    </div>
</body>
</html>");
        context.Response.End();
    }
    
    /// <summary>
    /// 从数据库获取默认的讨论ID
    /// </summary>
    private string GetDefaultLidFromDatabase(string cid)
    {
        try
        {
            ConnectionStringSettings connSetting = ConfigurationManager.ConnectionStrings["SqlServer"];
            if (connSetting == null || string.IsNullOrEmpty(connSetting.ConnectionString))
            {
                return null;
            }
            
            using (SqlConnection conn = new SqlConnection(connSetting.ConnectionString))
            {
                conn.Open();
                // 查询该课程的第一个讨论任务
                string sql = @"
                    SELECT TOP 1 Lid 
                    FROM Listmenu 
                    WHERE Lcid = @Cid AND Ltype = '讨论' AND (Lshow = 1 OR Lshow IS NULL)
                    ORDER BY Lorder, Lid";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Cid", cid);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString();
                    }
                }
            }
        }
        catch
        {
            // 返回 null 表示无法获取
        }
        return null;
    }

    public void Dispose()
    {
        // 清理资源
    }
}



#line default
#line hidden
