<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%
Response.ContentType = "application/json";
Response.Charset = "UTF-8";

try
{
    // 读取POST数据
    System.IO.StreamReader reader = new System.IO.StreamReader(Request.InputStream);
    string jsonData = reader.ReadToEnd();
    
    if (string.IsNullOrEmpty(jsonData))
    {
        Response.Write("{\"success\":false,\"message\":\"没有接收到数据\"}");
        return;
    }
    
    // 手动解析JSON
    string vid = "";
    string cid = "";
    List<string> qids = new List<string>();
    
    try
    {
        // 提取vid
        Match mVid = Regex.Match(jsonData, "\"vid\"\\s*:\\s*\"?([^,}\"]+)\"?");
        if (mVid.Success) vid = mVid.Groups[1].Value.Trim();
        
        // 提取cid
        Match mCid = Regex.Match(jsonData, "\"cid\"\\s*:\\s*\"?([^,}\"]+)\"?");
        if (mCid.Success) cid = mCid.Groups[1].Value.Trim();
        
        // 提取qids数组
        Match mQids = Regex.Match(jsonData, "\"qids\"\\s*:\\s*\\[([^\\]]+)\\]");
        if (mQids.Success)
        {
            string qidsStr = mQids.Groups[1].Value;
            MatchCollection qidMatches = Regex.Matches(qidsStr, "\"?([0-9]+)\"?");
            foreach (Match qidMatch in qidMatches)
            {
                qids.Add(qidMatch.Groups[1].Value);
            }
        }
    }
    catch (Exception exParse)
    {
        Response.Write("{\"success\":false,\"message\":\"JSON解析失败: " + exParse.Message.Replace("\"", "'") + "\"}");
        return;
    }
    
    if (qids.Count == 0)
    {
        Response.Write("{\"success\":false,\"message\":\"没有选择要删除的题目\"}");
        return;
    }
    
    // 获取数据库连接字符串
    string cs = null;
    try
    {
        Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
        if (dbType != null)
        {
            System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
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
    
    if (string.IsNullOrEmpty(cs))
    {
        Response.Write("{\"success\":false,\"message\":\"数据库连接字符串为空\"}");
        return;
    }
    
    SqlConnection conn = null;
    SqlTransaction trans = null;
    int deletedCount = 0;
    
    try
    {
        conn = new SqlConnection(cs);
        conn.Open();
        trans = conn.BeginTransaction();
        
        // 构建IN子句
        string qidsIn = string.Join(",", qids.ToArray());
        
        // 先删除选项
        string sqlDeleteItems = "DELETE FROM SurveyItem WHERE Mqid IN (" + qidsIn + ")";
        using (SqlCommand cmdItems = new SqlCommand(sqlDeleteItems, conn, trans))
        {
            cmdItems.ExecuteNonQuery();
        }
        
        // 再删除题目
        string sqlDeleteQuestions = "DELETE FROM SurveyQuestion WHERE Qid IN (" + qidsIn + ")";
        using (SqlCommand cmdQuestions = new SqlCommand(sqlDeleteQuestions, conn, trans))
        {
            deletedCount = cmdQuestions.ExecuteNonQuery();
        }
        
        trans.Commit();
        Response.Write("{\"success\":true,\"message\":\"删除成功\",\"deleted\":" + deletedCount.ToString() + "}");
    }
    catch (Exception exDb)
    {
        if (trans != null)
        {
            try { trans.Rollback(); } catch { }
        }
        string errMsg = exDb.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ");
        Response.Write("{\"success\":false,\"message\":\"数据库操作失败: " + errMsg + "\"}");
    }
    finally
    {
        if (conn != null && conn.State == ConnectionState.Open)
        {
            try { conn.Close(); } catch { }
        }
    }
}
catch (Exception ex)
{
    string errMsg = ex.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ");
    Response.Write("{\"success\":false,\"message\":\"操作失败: " + errMsg + "\"}");
}
%>
