#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\attitudecatajax.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "BB4D9EAA8066C2918D6A1600F5CBAD52"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\attitudecatajax.ashx"


using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Web;

/*
 * File-based category storage: ~/App_Data/attitudecats.dat
 * Format per line: id<TAB>name<TAB>color<TAB>sort
 * Compatible with .NET Framework 2.0+ (no var, no object initializers).
 */
public class attitudecatajax : IHttpHandler
{
    private static readonly object _lk = new object();

    private class Cat
    {
        public int Id;
        public string Name;
        public string Color;
        public int Sort;
    }

    private void WriteJson(HttpContext ctx, string json)
    {
        ctx.Response.StatusCode = 200;
        ctx.Response.ContentType = "application/json";
        ctx.Response.ContentEncoding = Encoding.UTF8;
        ctx.Response.Write(json);
    }

    private string Esc(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }

    private string DataFile(HttpContext ctx)
    {
        string dir = ctx.Server.MapPath("~/App_Data");
        try { if (!Directory.Exists(dir)) Directory.CreateDirectory(dir); } catch { }
        return Path.Combine(dir, "attitudecats.dat");
    }

    private List<Cat> Load(string path)
    {
        List<Cat> list = new List<Cat>();
        if (!File.Exists(path)) return list;
        try
        {
            string[] lines = File.ReadAllLines(path, Encoding.UTF8);
            foreach (string line in lines)
            {
                if (string.IsNullOrEmpty(line.Trim())) continue;
                string[] p = line.Split('\t');
                if (p.Length < 3) continue;
                int id = 0;
                int sort = 0;
                if (!int.TryParse(p[0], out id) || id <= 0) continue;
                if (p.Length >= 4) int.TryParse(p[3], out sort);
                Cat cat = new Cat();
                cat.Id = id;
                cat.Name = p[1];
                cat.Color = p[2];
                cat.Sort = sort;
                list.Add(cat);
            }
        }
        catch { }
        return list;
    }

    private void Save(string path, List<Cat> cats)
    {
        StringBuilder sb = new StringBuilder();
        foreach (Cat c in cats)
            sb.AppendLine(c.Id.ToString() + "\t" + c.Name.Replace("\t", "") + "\t" + c.Color + "\t" + c.Sort.ToString());
        File.WriteAllText(path, sb.ToString(), Encoding.UTF8);
    }

    public void ProcessRequest(HttpContext ctx)
    {
        try
        {
            HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc == null || string.IsNullOrEmpty(tc.Value))
            { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u8bf7\u5148\u767b\u5f55\"}"); return; }

            string action = ctx.Request["action"];
            if (action == null) action = "";
            string dataPath = DataFile(ctx);

            // ---- LIST ----
            if (action == "list")
            {
                List<Cat> cats = Load(dataPath);
                cats.Sort(delegate(Cat a, Cat b) {
                    int r = a.Sort.CompareTo(b.Sort);
                    return r != 0 ? r : a.Id.CompareTo(b.Id);
                });
                StringBuilder sb = new StringBuilder("[");
                bool first = true;
                foreach (Cat c in cats)
                {
                    if (!first) sb.Append(",");
                    sb.Append("{\"id\":");
                    sb.Append(c.Id.ToString());
                    sb.Append(",\"name\":\"");
                    sb.Append(Esc(c.Name));
                    sb.Append("\",\"color\":\"");
                    sb.Append(Esc(c.Color));
                    sb.Append("\"}");
                    first = false;
                }
                sb.Append("]");
                WriteJson(ctx, "{\"success\":true,\"data\":" + sb.ToString() + "}");
                return;
            }

            // ---- ADD ----
            if (action == "add")
            {
                string name = ctx.Request.Form["name"];
                if (name == null) name = "";
                name = name.Trim();
                if (name.Length == 0) { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u540d\u79f0\u4e0d\u80fd\u4e3a\u7a7a\"}"); return; }
                if (name.Length > 50) name = name.Substring(0, 50);
                string color = ctx.Request.Form["color"];
                if (color == null) color = "#6366f1";
                color = color.Trim();
                if (color.Length == 0 || !color.StartsWith("#") || color.Length > 20) color = "#6366f1";
                int newId = 0;
                lock (_lk)
                {
                    List<Cat> cats = Load(dataPath);
                    int maxId = 0;
                    int maxSort = 0;
                    foreach (Cat c in cats)
                    {
                        if (c.Id > maxId) maxId = c.Id;
                        if (c.Sort > maxSort) maxSort = c.Sort;
                    }
                    newId = maxId + 1;
                    Cat newCat = new Cat();
                    newCat.Id = newId;
                    newCat.Name = name;
                    newCat.Color = color;
                    newCat.Sort = maxSort + 1;
                    cats.Add(newCat);
                    Save(dataPath, cats);
                }
                WriteJson(ctx, "{\"success\":true,\"id\":" + newId.ToString() + ",\"name\":\"" + Esc(name) + "\",\"color\":\"" + Esc(color) + "\"}");
                return;
            }

            // ---- DELETE ----
            if (action == "del")
            {
                int catId = 0;
                string idStr = ctx.Request["id"];
                if (idStr == null || !int.TryParse(idStr, out catId))
                { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u53c2\u6570\u9519\u8bef\"}"); return; }
                lock (_lk)
                {
                    List<Cat> cats = Load(dataPath);
                    cats.RemoveAll(delegate(Cat c) { return c.Id == catId; });
                    Save(dataPath, cats);
                }
                WriteJson(ctx, "{\"success\":true}");
                return;
            }

            // ---- UPDATE ----
            if (action == "upd")
            {
                int catId = 0;
                string idStr = ctx.Request.Form["id"];
                if (idStr == null || !int.TryParse(idStr, out catId))
                { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u53c2\u6570\u9519\u8bef\"}"); return; }
                string name = ctx.Request.Form["name"];
                if (name == null) name = "";
                name = name.Trim();
                if (name.Length == 0) { WriteJson(ctx, "{\"success\":false,\"msg\":\"\u540d\u79f0\u4e0d\u80fd\u4e3a\u7a7a\"}"); return; }
                if (name.Length > 50) name = name.Substring(0, 50);
                string color = ctx.Request.Form["color"];
                if (color == null) color = "#6366f1";
                color = color.Trim();
                if (color.Length == 0 || !color.StartsWith("#") || color.Length > 20) color = "#6366f1";
                lock (_lk)
                {
                    List<Cat> cats = Load(dataPath);
                    foreach (Cat c in cats)
                    {
                        if (c.Id == catId)
                        {
                            c.Name = name;
                            c.Color = color;
                        }
                    }
                    Save(dataPath, cats);
                }
                WriteJson(ctx, "{\"success\":true,\"name\":\"" + Esc(name) + "\",\"color\":\"" + Esc(color) + "\"}");
                return;
            }

            // ---- LIST_TYPES ----
            if (action == "list_types")
            {
                string conStr = null;
                try
                {
                    System.Configuration.ConnectionStringSettings cs =
                        System.Configuration.ConfigurationManager.ConnectionStrings["constr"];
                    if (cs == null)
                        cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"];
                    if (cs != null) conStr = cs.ConnectionString;
                }
                catch { }
                StringBuilder sb = new StringBuilder("[");
                bool tfirst = true;
                if (!string.IsNullOrEmpty(conStr))
                {
                    try
                    {
                        using (System.Data.SqlClient.SqlConnection conn =
                            new System.Data.SqlClient.SqlConnection(conStr))
                        {
                            conn.Open();
                            using (System.Data.SqlClient.SqlCommand cmd =
                                new System.Data.SqlClient.SqlCommand(
                                    "SELECT Tid, ISNULL(Tname,'') AS Tname, ISNULL(Tscore,0) AS Tscore," +
                                    " ISNULL(Tactive,1) AS Tactive, ISNULL(Tcolor,'#6366f1') AS Tcolor" +
                                    " FROM AttitudeType ORDER BY ISNULL(Tsort,0), Tid", conn))
                            {
                                using (System.Data.SqlClient.SqlDataReader rd = cmd.ExecuteReader())
                                {
                                    while (rd.Read())
                                    {
                                        if (!tfirst) sb.Append(",");
                                        bool act = true;
                                        try { act = Convert.ToBoolean(rd["Tactive"]); } catch { }
                                        sb.Append("{\"id\":" + rd["Tid"] +
                                            ",\"name\":\"" + Esc(rd["Tname"].ToString()) + "\"" +
                                            ",\"score\":" + rd["Tscore"] +
                                            ",\"active\":" + (act ? "true" : "false") +
                                            ",\"color\":\"" + Esc(rd["Tcolor"].ToString()) + "\"}");
                                        tfirst = false;
                                    }
                                }
                            }
                        }
                    }
                    catch { }
                }
                sb.Append("]");
                WriteJson(ctx, "{\"success\":true,\"data\":" + sb.ToString() + "}");
                return;
            }

            WriteJson(ctx, "{\"success\":false,\"msg\":\"\u672a\u77e5\u64cd\u4f5c\"}");
        }
        catch (Exception ex)
        {
            try
            {
                ctx.Response.StatusCode = 200;
                ctx.Response.ContentType = "application/json";
                ctx.Response.ContentEncoding = Encoding.UTF8;
                ctx.Response.Write("{\"success\":false,\"msg\":\"" + Esc(ex.Message) + "\"}");
            }
            catch { }
        }
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
