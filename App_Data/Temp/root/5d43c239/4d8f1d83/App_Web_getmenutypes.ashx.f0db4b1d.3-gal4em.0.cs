#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\getmenutypes.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "049594C678BBE1AD05D5DD6E98430822"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\getmenutypes.ashx"


using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using System.Reflection;

public class GetMenuTypes : IHttpHandler
{
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo connField = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (connField != null)
                {
                    cs = connField.GetValue(null) as string;
                }
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        return cs;
    }
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        
        string cid = context.Request.QueryString["cid"];
        if (string.IsNullOrEmpty(cid))
        {
            context.Response.Write("{}");
            return;
        }
        
        try
        {
            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                context.Response.Write("{}");
                return;
            }
            StringBuilder sb = new StringBuilder("{");
            bool first = true;
            
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"
                    SELECT L.Lid, L.Ltype,
                           CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion SQ WHERE SQ.Qvid = L.Lxid) THEN 1 ELSE 0 END AS IsSurvey
                    FROM Listmenu L
                    WHERE L.Lcid=@cid AND L.Lshow=1
                    ORDER BY L.Lsort";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@cid", cid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                            string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "0";
                            bool isSurvey = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                            string ntype = NormalizeLtype(ltype);
                            if ((ntype == "1" || ntype == "2" || ntype == "3") && isSurvey)
                            {
                                ltype = "14";
                            }
                            
                            if (!first) sb.Append(",");
                            first = false;
                            // JSON key must be string
                            sb.AppendFormat("\"{0}\":\"{1}\"", lid, ltype.Replace("\"", "\\\""));
                        }
                    }
                }
            }
            
            sb.Append("}");
            context.Response.Write(sb.ToString());
        }
        catch
        {
            context.Response.Write("{}");
        }
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
    
    private string NormalizeLtype(string ltype)
    {
        if (string.IsNullOrEmpty(ltype)) return "0";
        ltype = ltype.Trim();
        switch (ltype)
        {
            case "活动": return "1";
            case "主题": return "2";
            case "练习": return "3";
            case "积木":
            case "积木编程": return "4";
            case "Python":
            case "代码":
            case "仓库": return "5";
            case "测评": return "6";
            case "流程":
            case "流程图": return "7";
            case "应用":
            case "像素":
            case "拼图":
            case "绘图": return "8";
            case "Html":
            case "网页": return "9";
            case "导图":
            case "脑图": return "10";
            case "表格": return "11";
            case "课件": return "12";
            case "讨论": return "13";
            case "调查":
            case "调查问卷": return "14";
            case "填表": return "15";
            default: return ltype;
        }
    }
}


#line default
#line hidden
