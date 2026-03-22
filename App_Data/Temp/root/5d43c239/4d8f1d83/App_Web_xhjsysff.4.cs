#pragma checksum "C:\inetpub\wwwroot\LearnSite\seat\saveseat.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "05E3487376E5666ADD7E4D26B3D0BC17"

#line 1 "C:\inetpub\wwwroot\LearnSite\seat\saveseat.ashx"


using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Web;

public class saveseat : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        string rstr = "0";
        bool isok = false;
        string myhid = context.Request["Hid"];
        string mycollects = context.Request["Collects"];
        if (HttpContext.Current.Request.Cookies[LearnSite.Common.CookieHelp.mngCookieNname] != null
            && IsValidRequest(myhid, mycollects))//如果是管理员则
        {
            isok = savehouse(myhid, mycollects);
        }
        if (isok)
        {
            rstr = "1";
        }
        context.Response.Write(rstr);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

    private bool savehouse(string hid,string hseat)
    {
        int hidValue;
        if (!Int32.TryParse(hid, out hidValue))
        {
            return false;
        }
        string connStr = GetConnStr();
        if (String.IsNullOrEmpty(connStr))
        {
            return false;
        }
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = "UPDATE House SET Hseat=@Hseat WHERE Hid=@Hid";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@Hseat", SqlDbType.NText).Value = hseat;
                cmd.Parameters.Add("@Hid", SqlDbType.Int).Value = hidValue;
                int rows = cmd.ExecuteNonQuery();
                if (rows <= 0)
                {
                    return false;
                }
            }
            using (SqlCommand verifyCmd = new SqlCommand("SELECT Hseat FROM House WHERE Hid=@Hid", conn))
            {
                verifyCmd.Parameters.Add("@Hid", SqlDbType.Int).Value = hidValue;
                object value = verifyCmd.ExecuteScalar();
                return value != null && value != DBNull.Value && value.ToString() == hseat;
            }
        }
    }

    private bool IsValidRequest(string hid, string collects)
    {
        int hidValue;
        if (!Int32.TryParse(hid, out hidValue))
        {
            return false;
        }
        if (hidValue <= 0)
        {
            return false;
        }
        if (String.IsNullOrEmpty(collects))
        {
            return false;
        }
        return collects.Length <= 20000;
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (f != null)
                {
                    cs = f.GetValue(null) as string;
                }
            }
        }
        catch { }
        if (String.IsNullOrEmpty(cs))
        {
            try
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["SqlServer"];
                if (settings != null)
                {
                    cs = settings.ConnectionString;
                }
            }
            catch { }
        }
        if (!String.IsNullOrEmpty(cs) && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
        {
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        }
        return cs;
    }
}

#line default
#line hidden
