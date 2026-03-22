<%@ WebHandler Language="C#" Class="CheckUpdate" %>

public class CheckUpdate : System.Web.IHttpHandler
{
    private const string RAW_URL   = "https://gitee.com/lequw/ls/raw/master/version.json";
    private const string CACHE_KEY = "LS_UpdCache_v1";
    private const int    CACHE_MIN = 60; // 缓存 1 小时

    public void ProcessRequest(System.Web.HttpContext ctx)
    {
        try
        {
            ctx.Response.ContentType = "application/json";
            ctx.Response.Charset = "utf-8";
            ctx.Response.TrySkipIisCustomErrors = true;
            ctx.Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            ctx.Response.AddHeader("Access-Control-Allow-Origin", "*");

            string cur = GetCurrent(ctx);

            // 命中应用级缓存时直接返回
            try
            {
                UpdCache cached = ctx.Application[CACHE_KEY] as UpdCache;
                if (cached != null && (System.DateTime.Now - cached.Time).TotalMinutes < CACHE_MIN)
                {
                    Emit(ctx, cur, cached.Ver, cached.Dl, cached.Log);
                    return;
                }
            }
            catch { /* Application state 不可用时跳过缓存 */ }

            string ver = "", dl = "", log = "";
            try
            {
                // 启用 TLS 1.2
                System.Net.ServicePointManager.SecurityProtocol =
                    (System.Net.SecurityProtocolType)3072;
                // 忽略证书验证问题
                System.Net.ServicePointManager.ServerCertificateValidationCallback =
                    delegate { return true; };
                System.Net.HttpWebRequest req =
                    (System.Net.HttpWebRequest)System.Net.WebRequest.Create(RAW_URL);
                req.Timeout   = 8000;
                req.UserAgent = "LearnSite-UpdateChecker/1.0";
                req.Method    = "GET";

                using (System.Net.HttpWebResponse res =
                           (System.Net.HttpWebResponse)req.GetResponse())
                using (System.IO.StreamReader sr =
                           new System.IO.StreamReader(
                               res.GetResponseStream(), System.Text.Encoding.UTF8))
                {
                    string j = sr.ReadToEnd();
                    ver = JStr(j, "version");
                    dl  = JStr(j, "downloadUrl");
                    log = JStr(j, "changelog");
                }
            }
            catch { /* 网络不可达时静默失败 */ }

            if (!string.IsNullOrEmpty(ver))
            {
                try
                {
                    UpdCache newCache = new UpdCache();
                    newCache.Time = System.DateTime.Now;
                    newCache.Ver  = ver;
                    newCache.Dl   = dl;
                    newCache.Log  = log;
                    ctx.Application[CACHE_KEY] = newCache;
                }
                catch { /* Application state 不可用时跳过缓存写入 */ }
            }

            Emit(ctx, cur, ver, dl, log);
        }
        catch (System.Exception ex)
        {
            try
            {
                ctx.Response.ContentType = "application/json";
                ctx.Response.TrySkipIisCustomErrors = true;
                ctx.Response.Write("{\"success\":false,\"msg\":" + Q(ex.Message) + "}");
            }
            catch { }
        }
    }

    // 输出 JSON 响应
    private void Emit(System.Web.HttpContext ctx,
                      string cur, string ver, string dl, string log)
    {
        bool has = !string.IsNullOrEmpty(ver) && Cmp(ver, cur) > 0;
        ctx.Response.Write(
            "{\"success\":true"                                  +
            ",\"hasUpdate\":"      + (has ? "true" : "false")  +
            ",\"currentVersion\":" + Q(cur)                    +
            ",\"latestVersion\":"  + Q(ver)                    +
            ",\"downloadUrl\":"    + Q(dl)                     +
            ",\"changelog\":"      + Q(log)                    + "}");
    }

    // 从 changelog.xml 读取当前版本号
    private string GetCurrent(System.Web.HttpContext ctx)
    {
        try
        {
            string path = ctx.Server.MapPath("~/changelog.xml");
            if (System.IO.File.Exists(path))
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(path);
                System.Xml.XmlNode node = doc.SelectSingleNode("//changelog/version[1]");
                if (node != null && node.Attributes["ver"] != null)
                    return node.Attributes["ver"].Value;
            }
        }
        catch { }
        return "v1.0.0";
    }

    // 从 JSON 字符串中提取字符串字段值
    private string JStr(string json, string key)
    {
        System.Text.RegularExpressions.Match m =
            System.Text.RegularExpressions.Regex.Match(
                json, "\"" + key + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        return m.Success ? m.Groups[1].Value : "";
    }

    // 语义化版本比较：a > b 返回 1，a < b 返回 -1，相等返回 0
    private int Cmp(string a, string b)
    {
        try
        {
            string[] p1 = a.TrimStart('v', 'V').Split('.');
            string[] p2 = b.TrimStart('v', 'V').Split('.');
            int n = System.Math.Max(p1.Length, p2.Length);
            for (int i = 0; i < n; i++)
            {
                int x = i < p1.Length ? int.Parse(p1[i]) : 0;
                int y = i < p2.Length ? int.Parse(p2[i]) : 0;
                if (x > y) return  1;
                if (x < y) return -1;
            }
        }
        catch { }
        return 0;
    }

    // JSON 字符串安全编码
    private string Q(string s)
    {
        if (s == null) return "null";
        return "\"" + s
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\n",  "\\n")
            .Replace("\r",  "\\r")
            .Replace("<",   "\\u003c")
            .Replace(">",   "\\u003e") + "\"";
    }

    public bool IsReusable { get { return false; } }
}

// 应用级缓存数据结构
public class UpdCache
{
    public System.DateTime Time;
    public string Ver;
    public string Dl;
    public string Log;
}
