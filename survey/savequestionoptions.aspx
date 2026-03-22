<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%
    Response.ContentType = "application/json";
    Response.Charset = "UTF-8";
    
    string GetConnStr()
    {
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
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }
    
    try
    {
        // 读取POST数据
        System.IO.StreamReader reader = new System.IO.StreamReader(Request.InputStream);
        string jsonData = reader.ReadToEnd();
        
        if (string.IsNullOrEmpty(jsonData))
        {
            Response.Write("{\"success\":false,\"message\":\"没有接收到数据\"}");
            Response.End();
            return;
        }
        
        // 解析JSON
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        Dictionary<string, object> data = serializer.Deserialize<Dictionary<string, object>>(jsonData);
        
        int qid = Convert.ToInt32(data["qid"]);
        int vid = Convert.ToInt32(data["vid"]);
        int cid = Convert.ToInt32(data["cid"]);
        string optionsJson = data["options"].ToString();
        
        Dictionary<string, object> optionsData = serializer.Deserialize<Dictionary<string, object>>(optionsJson);
        
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            Response.Write("{\"success\":false,\"message\":\"数据库连接失败\"}");
            Response.End();
            return;
        }
        
        using (SqlConnection conn = new SqlConnection(cs))
        {
            conn.Open();
            SqlTransaction trans = conn.BeginTransaction();
            
            try
            {
                // 先删除该题目的所有选项
                string sqlDelete = "DELETE FROM SurveyItem WHERE Mqid=@qid";
                using (SqlCommand cmdDel = new SqlCommand(sqlDelete, conn, trans))
                {
                    cmdDel.Parameters.AddWithValue("@qid", qid);
                    cmdDel.ExecuteNonQuery();
                }
                
                // 插入新选项
                if (optionsData.ContainsKey("options"))
                {
                    object[] options = (object[])optionsData["options"];
                    
                    foreach (object optObj in options)
                    {
                        Dictionary<string, object> opt = (Dictionary<string, object>)optObj;
                        
                        string optContent = opt.ContainsKey("content") ? opt["content"].ToString() : "";
                        int optScore = 0;
                        bool optCorrect = opt.ContainsKey("correct") ? Convert.ToBoolean(opt["correct"]) : false;
                        
                        // 如果有score字段，使用它；否则根据correct设置
                        if (opt.ContainsKey("score"))
                        {
                            optScore = Convert.ToInt32(opt["score"]);
                        }
                        else if (optCorrect)
                        {
                            string qType = optionsData.ContainsKey("type") ? optionsData["type"].ToString() : "single";
                            optScore = (qType == "multiple") ? 2 : 5;
                        }
                        
                        if (!string.IsNullOrEmpty(optContent))
                        {
                            string sqlItem = "INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack) VALUES (@qid, @vid, @item, @score, 0, @cid, 0)";
                            using (SqlCommand cmdItem = new SqlCommand(sqlItem, conn, trans))
                            {
                                cmdItem.Parameters.AddWithValue("@qid", qid);
                                cmdItem.Parameters.AddWithValue("@vid", vid);
                                cmdItem.Parameters.Add("@item", SqlDbType.NText).Value = optContent;
                                cmdItem.Parameters.AddWithValue("@score", optScore);
                                cmdItem.Parameters.AddWithValue("@cid", cid);
                                cmdItem.ExecuteNonQuery();
                            }
                        }
                    }
                }
                
                trans.Commit();
                Response.Write("{\"success\":true,\"message\":\"选项保存成功\"}");
            }
            catch (Exception exTrans)
            {
                trans.Rollback();
                Response.Write("{\"success\":false,\"message\":\"保存失败: " + exTrans.Message.Replace("\"", "\\\"") + "\"}");
            }
        }
    }
    catch (Exception ex)
    {
        Response.Write("{\"success\":false,\"message\":\"操作失败: " + ex.Message.Replace("\"", "\\\"") + "\"}");
    }
%>
