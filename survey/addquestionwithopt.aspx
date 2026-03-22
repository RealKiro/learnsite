<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
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
    
    // 手动解析JSON（因为.NET 2.0没有JavaScriptSerializer）
    string vid = "";
    string cid = "";
    string questionContent = "";
    bool isBlank = false;
    string optionsJson = "";
    
    try
    {
        // 提取vid
        Match mVid = Regex.Match(jsonData, "\"vid\"\\s*:\\s*\"?([^,}\"]+)\"?");
        if (mVid.Success) vid = mVid.Groups[1].Value.Trim();
        
        // 提取cid
        Match mCid = Regex.Match(jsonData, "\"cid\"\\s*:\\s*\"?([^,}\"]+)\"?");
        if (mCid.Success) cid = mCid.Groups[1].Value.Trim();
        
        // 提取content（处理HTML内容）
        Match mContent = Regex.Match(jsonData, "\"content\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"", RegexOptions.Singleline);
        if (mContent.Success)
        {
            questionContent = mContent.Groups[1].Value;
            // 解码JSON转义字符
            questionContent = questionContent.Replace("\\\"", "\"").Replace("\\\\", "\\").Replace("\\n", "\n").Replace("\\r", "\r").Replace("\\t", "\t");
        }
        
        // 提取isBlank
        Match mBlank = Regex.Match(jsonData, "\"isBlank\"\\s*:\\s*(true|false)");
        if (mBlank.Success) isBlank = mBlank.Groups[1].Value == "true";
        
        // 提取options（这是一个嵌套的JSON字符串）
        Match mOptions = Regex.Match(jsonData, "\"options\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"", RegexOptions.Singleline);
        if (mOptions.Success)
        {
            optionsJson = mOptions.Groups[1].Value;
            // 解码JSON转义字符
            optionsJson = optionsJson.Replace("\\\"", "\"").Replace("\\\\", "\\");
        }
    }
    catch (Exception exParse)
    {
        Response.Write("{\"success\":false,\"message\":\"JSON解析失败: " + exParse.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ") + "\"}");
        return;
    }
    
    if (string.IsNullOrEmpty(vid) || string.IsNullOrEmpty(cid))
    {
        Response.Write("{\"success\":false,\"message\":\"缺少必需参数vid或cid\"}");
        return;
    }
    
    int vidInt = int.Parse(vid);
    int cidInt = int.Parse(cid);
    
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
    int optionsSaved = 0;
    
    try
    {
        conn = new SqlConnection(cs);
        conn.Open();
        trans = conn.BeginTransaction();
        
        // 插入题目
        string sqlQuestion = "INSERT INTO SurveyQuestion (Qvid, Qcid, Qtitle, Qblack, Qcount) VALUES (@vid, @cid, @title, @black, 0); SELECT SCOPE_IDENTITY();";
        int newQid = 0;
        
        using (SqlCommand cmdQ = new SqlCommand(sqlQuestion, conn, trans))
        {
            cmdQ.Parameters.AddWithValue("@vid", vidInt);
            cmdQ.Parameters.AddWithValue("@cid", cidInt);
            cmdQ.Parameters.Add("@title", SqlDbType.NText).Value = questionContent;
            cmdQ.Parameters.AddWithValue("@black", isBlank ? 1 : 0);
            
            object result = cmdQ.ExecuteScalar();
            newQid = Convert.ToInt32(Convert.ToDecimal(result));
        }
        
        // 如果有选项数据，插入选项
        string debugInfo = "";
        if (!string.IsNullOrEmpty(optionsJson) && !isBlank)
        {
            debugInfo = "optionsJson length: " + optionsJson.Length.ToString() + "; ";
            
            // 解析选项JSON（手动解析）
            // optionsJson格式: {"type":"single","options":[{"label":"A","content":"...","score":5,"correct":true},...]
            
            // 使用正则表达式提取所有选项对象
            // 匹配 {"label":"...","content":"...","score":...,"correct":...}
            MatchCollection optMatches = Regex.Matches(optionsJson, "\\{[^{}]*\"label\"[^{}]*\\}", RegexOptions.Singleline);
            debugInfo += "matches found: " + optMatches.Count.ToString() + "; ";
            
            foreach (Match optMatch in optMatches)
            {
                string optStr = optMatch.Value;
                
                // 提取选项内容
                Match mOptContent = Regex.Match(optStr, "\"content\"\\s*:\\s*\"([^\"]*)\"");
                string optContent = mOptContent.Success ? mOptContent.Groups[1].Value : "";
                
                // 提取分值
                Match mScore = Regex.Match(optStr, "\"score\"\\s*:\\s*(\\d+)");
                int optScore = mScore.Success ? int.Parse(mScore.Groups[1].Value) : 0;
                
                debugInfo += "opt[" + optionsSaved.ToString() + "]: content=" + optContent + ", score=" + optScore.ToString() + "; ";
                
                if (!string.IsNullOrEmpty(optContent))
                {
                    string sqlItem = "INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack) VALUES (@qid, @vid, @item, @score, 0, @cid, 0)";
                    using (SqlCommand cmdItem = new SqlCommand(sqlItem, conn, trans))
                    {
                        cmdItem.Parameters.AddWithValue("@qid", newQid);
                        cmdItem.Parameters.AddWithValue("@vid", vidInt);
                        cmdItem.Parameters.Add("@item", SqlDbType.NText).Value = optContent;
                        cmdItem.Parameters.AddWithValue("@score", optScore);
                        cmdItem.Parameters.AddWithValue("@cid", cidInt);
                        cmdItem.ExecuteNonQuery();
                        optionsSaved++;
                    }
                }
            }
        }
        else
        {
            debugInfo = "optionsJson is " + (string.IsNullOrEmpty(optionsJson) ? "empty" : "not empty") + ", isBlank=" + isBlank.ToString();
        }
        
        trans.Commit();
        Response.Write("{\"success\":true,\"message\":\"题目和选项添加成功\",\"qid\":" + newQid.ToString() + ",\"optionsSaved\":" + optionsSaved.ToString() + ",\"debug\":\"" + debugInfo.Replace("\"", "'") + "\"}");
    }
    catch (Exception exDb)
    {
        if (trans != null)
        {
            try { trans.Rollback(); } catch { }
        }
        string errMsg = exDb.Message.Replace("\"", "'").Replace("\r", "").Replace("\n", " ");
        Response.Write("{\"success\":false,\"message\":\"数据库操作失败: " + errMsg + "\",\"optionsJson\":\"" + optionsJson.Replace("\"", "'").Substring(0, Math.Min(100, optionsJson.Length)) + "\"}");
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
