<%@ WebHandler Language="C#" Class="PetCardExchange" %>

using System;
using System.Web;
using System.Text;

public class PetCardExchange : IHttpHandler
{
    public void ProcessRequest(HttpContext ctx)
    {
        ctx.Response.ContentType = "application/json";
        ctx.Response.ContentEncoding = Encoding.UTF8;
        ctx.Response.Cache.SetNoStore();

        if (ctx.Request.HttpMethod != "POST")
        {
            ctx.Response.Write("{\"success\":false,\"msg\":\"Method Not Allowed\"}");
            return;
        }

        // Read student identity from cookie
        int sid = 0, grade = 0, cls = 0;
        try
        {
            string cookieName = LearnSite.Common.CookieHelp.stuCookieNname;
            HttpCookie sc = ctx.Request.Cookies[cookieName];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string val = sc.Value;
                if (val.Contains("%")) try { val = HttpUtility.UrlDecode(val, Encoding.UTF8); } catch { }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    var mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { val });
                    string sidStr = GetProp(m, "Sid");
                    string gradeStr = GetProp(m, "Sgrade");
                    string classStr = GetProp(m, "Sclass");
                    if (!string.IsNullOrEmpty(sidStr)) int.TryParse(sidStr, out sid);
                    if (!string.IsNullOrEmpty(gradeStr)) int.TryParse(gradeStr, out grade);
                    if (!string.IsNullOrEmpty(classStr)) int.TryParse(classStr, out cls);
                }
            }
        }
        catch { }

        if (sid <= 0)
        {
            ctx.Response.Write("{\"success\":false,\"msg\":\"请先登录学生账号\"}");
            return;
        }

        int itemId = 0;
        int.TryParse(ctx.Request.Form["itemId"] ?? "", out itemId);
        if (itemId <= 0)
        {
            ctx.Response.Write("{\"success\":false,\"msg\":\"参数错误\"}");
            return;
        }

        int cardCost = 1;
        int.TryParse(ctx.Request.Form["cardCost"] ?? "1", out cardCost);
        if (cardCost < 1) cardCost = 1;

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            ctx.Response.Write("{\"success\":false,\"msg\":\"数据库未配置\"}");
            return;
        }

        try
        {
            using (var conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();

                // Get item info
                string itemName = "";
                int stock = -1;
                using (var cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Sname, ISNULL(Sstock,-1) FROM BadgeShopItem WHERE Sid=@id AND ISNULL(Sactive,1)=1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", itemId);
                    cmd.CommandTimeout = 5;
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            itemName = r.IsDBNull(0) ? "" : r.GetString(0);
                            stock = r.GetInt32(1);
                        }
                        else
                        {
                            ctx.Response.Write("{\"success\":false,\"msg\":\"商品不存在或已下架\"}");
                            return;
                        }
                    }
                }

                // Check stock
                if (stock == 0)
                {
                    ctx.Response.Write("{\"success\":false,\"msg\":\"该商品已售罄\"}");
                    return;
                }

                // Record the exchange (Epoints stores card cost for teacher reference)
                using (var cmd = new System.Data.SqlClient.SqlCommand(
                    "INSERT INTO BadgeExchange(Esid,Eitemid,Epoints,Estatus,Edate,Egrade,Eclass) VALUES(@sid,@itemid,@pts,0,GETDATE(),@grade,@class)", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sid);
                    cmd.Parameters.AddWithValue("@itemid", itemId);
                    cmd.Parameters.AddWithValue("@pts", cardCost);
                    cmd.Parameters.AddWithValue("@grade", grade);
                    cmd.Parameters.AddWithValue("@class", cls);
                    cmd.CommandTimeout = 5;
                    cmd.ExecuteNonQuery();
                }

                string safe = itemName.Replace("\\", "\\\\").Replace("\"", "\\\"");
                ctx.Response.Write("{\"success\":true,\"msg\":\"兑换申请已提交，等待老师审核\",\"itemName\":\"" + safe + "\"}");
            }
        }
        catch (Exception ex)
        {
            string safeErr = ex.Message.Replace("\\", "\\\\").Replace("\"", "\\\"");
            ctx.Response.Write("{\"success\":false,\"msg\":\"兑换失败: " + safeErr + "\"}");
        }
    }

    private string GetProp(object model, string propName)
    {
        if (model == null) return "";
        var p = model.GetType().GetProperty(propName);
        if (p == null) return "";
        object v = p.GetValue(model, null);
        return v == null ? "" : v.ToString();
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                var f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    public bool IsReusable { get { return false; } }
}
