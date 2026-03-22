#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\gamepurchase.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "037ED96FFA35901F93576466C88AEDE1"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\gamepurchase.ashx"


using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Data.SqlClient;

public class gamepurchase : IHttpHandler
{
    private void WriteJson(HttpContext ctx, string json)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        byte[] b = Encoding.UTF8.GetBytes(json);
        ctx.Response.OutputStream.Write(b, 0, b.Length);
    }

    private string Esc(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "").Replace("\n", "\\n");
    }

    private string GetConnStr(HttpContext ctx)
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private int GetStudentSid(HttpContext ctx)
    {
        try
        {
            HttpCookie sc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value)) return 0;
            string cookieVal = sc.Value;
            if (cookieVal.Contains("%"))
            {
                try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); } catch { }
            }
            Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
            if (ct == null) return 0;
            object m = Activator.CreateInstance(ct);
            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
            if (mi != null) mi.Invoke(m, new object[] { cookieVal });
            System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
            if (p == null) return 0;
            object v = p.GetValue(m, null);
            if (v == null) return 0;
            int sid = 0;
            int.TryParse(v.ToString(), out sid);
            return sid;
        }
        catch { return 0; }
    }

    private void EnsureTable(SqlConnection conn)
    {
        try
        {
            using (SqlCommand cmd = new SqlCommand(@"
                IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name='GamePurchase' AND xtype='U')
                CREATE TABLE GamePurchase (
                    GPid     INT IDENTITY(1,1) PRIMARY KEY,
                    GPsid    INT NOT NULL,
                    GPgameid NVARCHAR(100) NOT NULL,
                    GPcost   INT NOT NULL DEFAULT 0,
                    GPdate   DATETIME NOT NULL DEFAULT GETDATE()
                )", conn))
            {
                cmd.CommandTimeout = 10;
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private string GetJsonField(string objJson, string key)
    {
        // String field
        Match m = Regex.Match(objJson, "\"" + key + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        if (m.Success) return m.Groups[1].Value;
        // Number / bool field
        Match mb = Regex.Match(objJson, "\"" + key + "\"\\s*:\\s*([\\d\\.]+|true|false)");
        if (mb.Success) return mb.Groups[1].Value;
        return "";
    }

    // Read creditCost and gameName for a given gameId from games.json
    private int ReadGameCost(HttpContext ctx, string gameId, out string gameName)
    {
        gameName = "";
        try
        {
            string path = ctx.Server.MapPath("~/App_Data/games.json");
            if (!File.Exists(path)) return -1; // file not found

            string json = File.ReadAllText(path, Encoding.UTF8);

            // Extract games array
            Match am = Regex.Match(json, "\"games\"\\s*:\\s*(\\[.*\\])", RegexOptions.Singleline);
            if (!am.Success) return -1;
            string arr = am.Groups[1].Value;

            // Walk objects
            int depth = 0, start = -1;
            for (int i = 0; i < arr.Length; i++)
            {
                char c = arr[i];
                if (c == '{') { if (depth == 0) start = i; depth++; }
                else if (c == '}')
                {
                    depth--;
                    if (depth == 0 && start >= 0)
                    {
                        string obj = arr.Substring(start, i - start + 1);
                        if (GetJsonField(obj, "id") == gameId)
                        {
                            // Check game is enabled
                            if (GetJsonField(obj, "enabled") != "true") return -1;
                            gameName = GetJsonField(obj, "name");
                            // Unescape unicode escapes in name
                            gameName = Regex.Replace(gameName, @"\\u([0-9a-fA-F]{4})",
                                m2 => ((char)Convert.ToInt32(m2.Groups[1].Value, 16)).ToString());
                            string costStr = GetJsonField(obj, "creditCost");
                            int cost = 0;
                            if (!string.IsNullOrEmpty(costStr)) int.TryParse(costStr, out cost);
                            return cost;
                        }
                        start = -1;
                    }
                }
            }
        }
        catch { }
        return -1; // game not found
    }

    public void ProcessRequest(HttpContext ctx)
    {
        int sid = GetStudentSid(ctx);
        if (sid <= 0)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"请先登录学生账号\"}");
            return;
        }

        string action = ctx.Request.Form["action"] ?? ctx.Request.QueryString["action"] ?? "";
        string cs = GetConnStr(ctx);
        if (string.IsNullOrEmpty(cs))
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"数据库连接失败\"}");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                EnsureTable(conn);

                if (action == "status")
                    DoStatus(ctx, conn, sid);
                else if (action == "buy")
                    DoBuy(ctx, conn, sid);
                else
                    WriteJson(ctx, "{\"ok\":false,\"msg\":\"未知操作\"}");
            }
        }
        catch (Exception ex)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"" + Esc(ex.Message) + "\"}");
        }
    }

    private void DoStatus(HttpContext ctx, SqlConnection conn, int sid)
    {
        // Purchased game IDs
        StringBuilder sb = new StringBuilder("[");
        bool first = true;
        using (SqlCommand cmd = new SqlCommand(
            "SELECT GPgameid FROM GamePurchase WHERE GPsid=@sid", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    if (!first) sb.Append(",");
                    sb.Append("\"" + Esc(dr[0].ToString()) + "\"");
                    first = false;
                }
            }
        }
        sb.Append("]");

        // Earned score
        int sscore = 0;
        using (SqlCommand cmd = new SqlCommand(
            "SELECT ISNULL(Sscore,0) FROM Students WHERE Sid=@sid", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            object r = cmd.ExecuteScalar();
            if (r != null && r != DBNull.Value) sscore = Convert.ToInt32(r);
        }

        // Total spent on games
        int totalSpent = 0;
        using (SqlCommand cmd = new SqlCommand(
            "SELECT ISNULL(SUM(GPcost),0) FROM GamePurchase WHERE GPsid=@sid", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            object r = cmd.ExecuteScalar();
            if (r != null && r != DBNull.Value) totalSpent = Convert.ToInt32(r);
        }

        int available = Math.Max(0, sscore - totalSpent);
        WriteJson(ctx, "{\"ok\":true,\"purchased\":" + sb.ToString() +
            ",\"sscore\":" + sscore + ",\"spent\":" + totalSpent + ",\"available\":" + available + "}");
    }

    private void DoBuy(HttpContext ctx, SqlConnection conn, int sid)
    {
        string gameId = (ctx.Request.Form["gameId"] ?? "").Trim();
        if (string.IsNullOrEmpty(gameId))
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"缺少游戏ID\"}");
            return;
        }

        // Get game credit cost
        string gameName = "";
        int creditCost = ReadGameCost(ctx, gameId, out gameName);
        if (creditCost < 0)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"未找到该游戏或游戏已禁用\"}");
            return;
        }
        if (creditCost == 0)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"该游戏无需兑换，可直接游玩\"}");
            return;
        }

        // Check if already purchased
        using (SqlCommand cmd = new SqlCommand(
            "SELECT COUNT(*) FROM GamePurchase WHERE GPsid=@sid AND GPgameid=@gid", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            cmd.Parameters.AddWithValue("@gid", gameId);
            int cnt = Convert.ToInt32(cmd.ExecuteScalar());
            if (cnt > 0)
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"您已兑换过该游戏\"}");
                return;
            }
        }

        // Get student earned score
        int sscore = 0;
        using (SqlCommand cmd = new SqlCommand(
            "SELECT ISNULL(Sscore,0) FROM Students WHERE Sid=@sid", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            object r = cmd.ExecuteScalar();
            if (r != null && r != DBNull.Value) sscore = Convert.ToInt32(r);
        }

        // Get total already spent on games
        int totalSpent = 0;
        using (SqlCommand cmd = new SqlCommand(
            "SELECT ISNULL(SUM(GPcost),0) FROM GamePurchase WHERE GPsid=@sid", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            object r = cmd.ExecuteScalar();
            if (r != null && r != DBNull.Value) totalSpent = Convert.ToInt32(r);
        }

        int available = Math.Max(0, sscore - totalSpent);
        if (available < creditCost)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"学分不足，需要 " + creditCost +
                " 学分，当前可用 " + available + " 学分\"}");
            return;
        }

        // Insert purchase record
        using (SqlCommand cmd = new SqlCommand(
            "INSERT INTO GamePurchase(GPsid,GPgameid,GPcost,GPdate) VALUES(@sid,@gid,@cost,GETDATE())", conn))
        {
            cmd.Parameters.AddWithValue("@sid", sid);
            cmd.Parameters.AddWithValue("@gid", gameId);
            cmd.Parameters.AddWithValue("@cost", creditCost);
            cmd.ExecuteNonQuery();
        }

        int newAvailable = Math.Max(0, available - creditCost);
        WriteJson(ctx, "{\"ok\":true,\"gameName\":\"" + Esc(gameName) +
            "\",\"cost\":" + creditCost + ",\"newAvailable\":" + newAvailable + "}");
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
