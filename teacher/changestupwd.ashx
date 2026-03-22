<%@ WebHandler Language="C#" Class="changestupwd" %>

using System;
using System.Text;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;

public class changestupwd : IHttpHandler
{
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

    private string GetConnStr()
    {
        ConnectionStringSettings cfg = ConfigurationManager.ConnectionStrings["constr"]
            ?? ConfigurationManager.ConnectionStrings["SqlServer"];
        return cfg != null ? cfg.ConnectionString : null;
    }

    public void ProcessRequest(HttpContext ctx)
    {
        try
        {
            // 验证教师登录
            HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc == null || string.IsNullOrEmpty(tc.Value))
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"请先登录\"}");
                return;
            }

            string sidStr = ctx.Request.Form["sid"];
            string newpwd = ctx.Request.Form["newpwd"];

            if (string.IsNullOrEmpty(sidStr) || string.IsNullOrEmpty(newpwd))
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"参数错误\"}");
                return;
            }

            int sid;
            if (!int.TryParse(sidStr, out sid) || sid <= 0)
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"学生ID无效\"}");
                return;
            }

            newpwd = newpwd.Trim();
            if (newpwd.Length < 3)
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"密码至少3位\"}");
                return;
            }
            if (newpwd.Length > 50)
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"密码不超过50位\"}");
                return;
            }

            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                WriteJson(ctx, "{\"ok\":false,\"msg\":\"数据库连接失败\"}");
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 检测是否有 Ssalt 字段（MD5+Salt 加密版本）
                bool hasSalt = false;
                using (SqlCommand chk = new SqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Students' AND COLUMN_NAME='Ssalt'", conn))
                {
                    hasSalt = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                }

                // 更新密码，若有 Salt 字段则一并清除（使系统回退到明文验证）
                string sql = hasSalt
                    ? "UPDATE Students SET Spwd=@pwd, Ssalt=NULL WHERE Sid=@sid"
                    : "UPDATE Students SET Spwd=@pwd WHERE Sid=@sid";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@pwd", newpwd);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                        WriteJson(ctx, "{\"ok\":true}");
                    else
                        WriteJson(ctx, "{\"ok\":false,\"msg\":\"学生不存在\"}");
                }
            }
        }
        catch (Exception ex)
        {
            try { WriteJson(ctx, "{\"ok\":false,\"msg\":\"" + Esc(ex.Message) + "\"}"); } catch { }
        }
    }

    public bool IsReusable { get { return false; } }
}
