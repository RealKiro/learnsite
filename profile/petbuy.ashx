<%@ WebHandler Language="C#" Class="PetBuy" %>

using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;

public class PetBuy : IHttpHandler
{
    private static readonly Dictionary<string, int>    COSTS;
    private static readonly Dictionary<string, string> NAMES;

    static PetBuy()
    {
        COSTS = new Dictionary<string, int>();
        COSTS.Add("snack",               5);
        COSTS.Add("toy",                10);
        COSTS.Add("gourmet",            15);
        COSTS.Add("cleaner",             8);
        COSTS.Add("potion",             20);
        COSTS.Add("gem",                25);
        COSTS.Add("costume_sunglasses", 30);
        COSTS.Add("costume_hat",        40);
        COSTS.Add("costume_bow",        35);
        COSTS.Add("costume_crown",      80);
        COSTS.Add("costume_wings",     100);
        COSTS.Add("costume_ghost",      60);
        COSTS.Add("costume_star",       50);

        NAMES = new Dictionary<string, string>();
        NAMES.Add("snack",               "零食");
        NAMES.Add("toy",                 "玩具");
        NAMES.Add("gourmet",             "美食");
        NAMES.Add("cleaner",             "清洁套装");
        NAMES.Add("potion",              "强化药水");
        NAMES.Add("gem",                 "经验宝石");
        NAMES.Add("costume_sunglasses",  "墨镜");
        NAMES.Add("costume_hat",         "礼帽");
        NAMES.Add("costume_bow",         "蝴蝶结");
        NAMES.Add("costume_crown",       "皇冠");
        NAMES.Add("costume_wings",       "天使翅膀");
        NAMES.Add("costume_ghost",       "南瓜幽灵");
        NAMES.Add("costume_star",        "流星披风");
    }

    public void ProcessRequest(HttpContext ctx)
    {
        ctx.Response.ContentType = "application/json";
        ctx.Response.ContentEncoding = System.Text.Encoding.UTF8;
        ctx.Response.Cache.SetNoStore();

        try
        {
            int sid = GetSid(ctx);
            if (sid <= 0) { Fail(ctx, "请先登录"); return; }

            string item = (ctx.Request.Form["item"] ?? "").Trim();
            int qty = 1;
            int.TryParse(ctx.Request.Form["qty"] ?? "1", out qty);
            if (qty < 1) qty = 1;
            if (qty > 99) qty = 99;

            if (!COSTS.ContainsKey(item)) { Fail(ctx, "道具不存在"); return; }

            int unitCost  = COSTS[item];
            int totalCost = unitCost * qty;
            string name   = NAMES.ContainsKey(item) ? NAMES[item] : item;

            string cs = GetConnStr();
            if (string.IsNullOrEmpty(cs)) { Fail(ctx, "数据库连接失败"); return; }

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int available = CalcAvailable(conn, sid);

                if (available < totalCost)
                {
                    ctx.Response.Write("{\"success\":false,\"msg\":\"学分不足，需要"
                        + totalCost + "学分，当前可用" + available + "学分\",\"available\":"
                        + available + "}");
                    return;
                }

                string note = "宠物道具:" + name + (qty > 1 ? " x" + qty : "");
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO BadgeExchange(Esid,Eitemid,Epoints,Edate,Estatus,Enote)" +
                    " VALUES(@sid,0,@pts,GETDATE(),1,@note)", conn))
                {
                    cmd.Parameters.AddWithValue("@sid",  sid);
                    cmd.Parameters.AddWithValue("@pts",  totalCost);
                    cmd.Parameters.AddWithValue("@note", note);
                    cmd.ExecuteNonQuery();
                }

                int newAvail = available - totalCost;
                ctx.Response.Write("{\"success\":true,\"available\":" + newAvail
                    + ",\"cost\":" + totalCost
                    + ",\"item\":\"" + Esc(item) + "\""
                    + ",\"qty\":" + qty + "}");
            }
        }
        catch (Exception ex)
        {
            string msg = ex.Message;
            if (msg.Length > 80) msg = msg.Substring(0, 80);
            ctx.Response.Write("{\"success\":false,\"msg\":\"服务器错误:" + Esc(msg) + "\"}");
        }
    }

    private static int CalcAvailable(SqlConnection conn, int sid)
    {
        int total = 0, used = 0;
        try
        {
            using (SqlCommand c = new SqlCommand("SELECT ISNULL(Sallscore,0) FROM Students WHERE Sid=@sid", conn))
            {
                c.Parameters.AddWithValue("@sid", sid);
                object r = c.ExecuteScalar();
                if (r != null && r != DBNull.Value) total = Convert.ToInt32(r);
            }
        }
        catch { }
        try
        {
            using (SqlCommand c = new SqlCommand(
                "SELECT ISNULL(SUM(ISNULL(Epoints,0)),0) FROM BadgeExchange WHERE Esid=@sid AND Estatus IN(0,1)", conn))
            {
                c.Parameters.AddWithValue("@sid", sid);
                object r = c.ExecuteScalar();
                if (r != null && r != DBNull.Value) used = Convert.ToInt32(r);
            }
        }
        catch { }
        return Math.Max(0, total - used);
    }

    private static int GetSid(HttpContext ctx)
    {
        try
        {
            HttpCookie sc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value)) return 0;
            string v = sc.Value;
            if (v.Contains("%")) { try { v = HttpUtility.UrlDecode(v); } catch { } }
            Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
            if (ct == null) return 0;
            object m = Activator.CreateInstance(ct);
            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
            if (mi != null) mi.Invoke(m, new object[] { v });
            System.Reflection.PropertyInfo p = m.GetType().GetProperty("Sid");
            if (p == null) return 0;
            int sid = 0;
            object pv = p.GetValue(m, null);
            if (pv != null) int.TryParse(pv.ToString(), out sid);
            return sid;
        }
        catch { return 0; }
    }

    private static string GetConnStr()
    {
        string cs = null;
        try
        {
            Type t = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (t != null)
            {
                System.Reflection.FieldInfo f = t.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private static void Fail(HttpContext ctx, string msg)
    {
        ctx.Response.Write("{\"success\":false,\"msg\":\"" + Esc(msg) + "\"}");
    }

    private static string Esc(string s)
    {
        return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"")
            .Replace("\r", "").Replace("\n", "");
    }

    public bool IsReusable { get { return false; } }
}
