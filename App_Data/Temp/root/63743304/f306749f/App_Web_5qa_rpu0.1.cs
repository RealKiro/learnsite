#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\gamesave.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "ACD2C74C794EE92B5C5C7C78525D3B61"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\gamesave.ashx"


using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Collections.Generic;

public class gamesave : IHttpHandler
{
    private static readonly object _lk = new object();

    // ── HTTP ─────────────────────────────────────────────────────────────

    private void Write(HttpContext ctx, string json)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        byte[] b = Encoding.UTF8.GetBytes(json);
        ctx.Response.OutputStream.Write(b, 0, b.Length);
    }
    private void OK(HttpContext ctx)  { Write(ctx, "{\"ok\":true}"); }
    private void Err(HttpContext ctx, string msg)
    { Write(ctx, "{\"ok\":false,\"msg\":\"" + J(msg) + "\"}"); }

    // ── JSON 转义 ─────────────────────────────────────────────────────────

    private string J(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "").Replace("\n", "\\n");
    }

    // ── games.json 读写 ──────────────────────────────────────────────────

    private string Load(HttpContext ctx)
    {
        string p = ctx.Server.MapPath("~/App_Data/games.json");
        if (!File.Exists(p)) return "{\"games\":[]}";
        try { return File.ReadAllText(p, Encoding.UTF8); }
        catch { return "{\"games\":[]}"; }
    }

    private void Save(HttpContext ctx, string json)
    {
        string p = ctx.Server.MapPath("~/App_Data/games.json");
        string d = Path.GetDirectoryName(p);
        if (!Directory.Exists(d)) Directory.CreateDirectory(d);
        lock (_lk) { File.WriteAllText(p, json, Encoding.UTF8); }
    }

    // ── JSON 解析助手 ────────────────────────────────────────────────────

    private string GamesArr(string full)
    {
        Match m = Regex.Match(full, "\"games\"\\s*:\\s*(\\[.*\\])", RegexOptions.Singleline);
        return m.Success ? m.Groups[1].Value : "[]";
    }

    private bool GlobalOn(string full)
    {
        Match m = Regex.Match(full, "\"globalEnabled\"\\s*:\\s*(true|false)");
        return !m.Success || m.Groups[1].Value == "true";
    }

    private List<string> ParseObjs(string arr)
    {
        List<string> list = new List<string>();
        int depth = 0, start = -1;
        for (int i = 0; i < arr.Length; i++)
        {
            if (arr[i] == '{') { if (depth++ == 0) start = i; }
            else if (arr[i] == '}' && --depth == 0 && start >= 0)
            { list.Add(arr.Substring(start, i - start + 1)); start = -1; }
        }
        return list;
    }

    private string Field(string obj, string key)
    {
        string ek = Regex.Escape(key);
        Match m = Regex.Match(obj, "\"" + ek + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        if (m.Success) return m.Groups[1].Value;
        Match m2 = Regex.Match(obj, "\"" + ek + "\"\\s*:\\s*([^,}\\s]+)");
        if (m2.Success) return m2.Groups[1].Value;
        return "";
    }

    // ── 构造 / 重建 ───────────────────────────────────────────────────────

    private string BuildObj(string id, string name, bool enabled,
        string url, string desc, string date, int cost)
    {
        return "{\"id\":\"" + J(id) + "\",\"name\":\"" + J(name) +
               "\",\"enabled\":" + (enabled ? "true" : "false") +
               ",\"url\":\"" + J(url) + "\",\"description\":\"" + J(desc) +
               "\",\"addedDate\":\"" + J(date) + "\",\"creditCost\":" +
               (cost < 0 ? 0 : cost) + "}";
    }

    private string Rebuild(List<string> items, bool globalOn)
    {
        StringBuilder sb = new StringBuilder("{\"globalEnabled\":")
            .Append(globalOn ? "true" : "false").Append(",\"games\":[");
        for (int i = 0; i < items.Count; i++) { if (i > 0) sb.Append(","); sb.Append(items[i]); }
        return sb.Append("]}").ToString();
    }

    private string NewId()
    {
        return DateTime.Now.Ticks.ToString("x") + new Random().Next(1000, 9999).ToString();
    }

    // ── 主入口 ────────────────────────────────────────────────────────────

    public void ProcessRequest(HttpContext ctx)
    {
        try
        {
            HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc == null || string.IsNullOrEmpty(tc.Value)) { Err(ctx, "请先登录"); return; }
        }
        catch (Exception ex) { try { Err(ctx, "auth:" + ex.Message); } catch { } return; }

        string act = (ctx.Request.Form["action"] ?? ctx.Request.QueryString["action"] ?? "").Trim();
        try
        {
            if      (act == "toggle")       DoToggle(ctx);
            else if (act == "delete")       DoDelete(ctx);
            else if (act == "addlink")      DoAddLink(ctx);
            else if (act == "edit")         DoEdit(ctx);
            else if (act == "globalToggle") DoGlobalToggle(ctx);
            else if (act == "list")         DoList(ctx);
            else Err(ctx, "unknown action");
        }
        catch (Exception ex) { try { Err(ctx, ex.GetType().Name + ":" + ex.Message); } catch { } }
    }

    // ── 各操作 ────────────────────────────────────────────────────────────

    private void DoToggle(HttpContext ctx)
    {
        string id = (ctx.Request.Form["id"] ?? "").Trim();
        if (id == "") { Err(ctx, "缺少id"); return; }

        string full = Load(ctx);
        List<string> list = ParseObjs(GamesArr(full));
        bool found = false, next = false;
        for (int i = 0; i < list.Count; i++)
        {
            if (Field(list[i], "id") == id)
            {
                next = Field(list[i], "enabled") != "true";
                list[i] = Regex.Replace(list[i],
                    "\"enabled\"\\s*:\\s*(true|false)",
                    "\"enabled\":" + (next ? "true" : "false"));
                found = true; break;
            }
        }
        if (!found) { Err(ctx, "未找到该游戏"); return; }
        Save(ctx, Rebuild(list, GlobalOn(full)));
        Write(ctx, "{\"ok\":true,\"enabled\":" + (next ? "true" : "false") + "}");
    }

    private void DoDelete(HttpContext ctx)
    {
        string id = (ctx.Request.Form["id"] ?? "").Trim();
        if (id == "") { Err(ctx, "缺少id"); return; }

        string full = Load(ctx);
        List<string> list = ParseObjs(GamesArr(full));
        int n = list.Count;
        for (int i = n - 1; i >= 0; i--)
            if (Field(list[i], "id") == id) { list.RemoveAt(i); break; }
        if (list.Count == n) { Err(ctx, "未找到该游戏"); return; }
        Save(ctx, Rebuild(list, GlobalOn(full)));
        OK(ctx);
    }

    private void DoAddLink(HttpContext ctx)
    {
        string name = (ctx.Request.Form["name"] ?? "").Trim();
        string url  = (ctx.Request.Form["url"]  ?? "").Trim();
        string desc = (ctx.Request.Form["desc"]  ?? "").Trim();
        int cost = 0;
        int.TryParse(ctx.Request.Form["creditCost"] ?? "0", out cost);
        if (cost < 0) cost = 0;
        if (name == "") { Err(ctx, "请填写游戏名称"); return; }
        if (url  == "") { Err(ctx, "请填写游戏链接"); return; }

        string full = Load(ctx);
        List<string> list = ParseObjs(GamesArr(full));
        string id = NewId();
        list.Add(BuildObj(id, name, true, url, desc, DateTime.Now.ToString("yyyy-MM-dd"), cost));
        Save(ctx, Rebuild(list, GlobalOn(full)));
        Write(ctx, "{\"ok\":true,\"id\":\"" + J(id) + "\"}");
    }

    private void DoEdit(HttpContext ctx)
    {
        string id   = (ctx.Request.Form["id"]   ?? "").Trim();
        string name = (ctx.Request.Form["name"] ?? "").Trim();
        string url  = (ctx.Request.Form["url"]  ?? "").Trim();
        string desc = (ctx.Request.Form["desc"]  ?? "").Trim();
        if (id   == "") { Err(ctx, "缺少id"); return; }
        if (name == "") { Err(ctx, "请填写游戏名称"); return; }
        if (url  == "") { Err(ctx, "请填写游戏链接"); return; }

        string full = Load(ctx);
        List<string> list = ParseObjs(GamesArr(full));
        bool found = false;
        for (int i = 0; i < list.Count; i++)
        {
            if (Field(list[i], "id") == id)
            {
                bool enabled = Field(list[i], "enabled") == "true";
                string date  = Field(list[i], "addedDate");
                int cost = 0;
                string cs = (ctx.Request.Form["creditCost"] ?? "").Trim();
                if (cs != "") int.TryParse(cs, out cost);
                else int.TryParse(Field(list[i], "creditCost"), out cost);
                if (cost < 0) cost = 0;
                list[i] = BuildObj(id, name, enabled, url, desc, date, cost);
                found = true; break;
            }
        }
        if (!found) { Err(ctx, "未找到该游戏"); return; }
        Save(ctx, Rebuild(list, GlobalOn(full)));
        OK(ctx);
    }

    private void DoGlobalToggle(HttpContext ctx)
    {
        string full = Load(ctx);
        bool newState = !GlobalOn(full);
        List<string> list = ParseObjs(GamesArr(full));
        Save(ctx, Rebuild(list, newState));
        Write(ctx, "{\"ok\":true,\"globalEnabled\":" + (newState ? "true" : "false") + "}");
    }

    private void DoList(HttpContext ctx) { Write(ctx, Load(ctx)); }

    public bool IsReusable { get { return false; } }
}

#line default
#line hidden
