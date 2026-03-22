<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" StylesheetTheme="Teacher" ValidateRequest="false" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myCid = 0;
    protected int myVid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";

    private string GetConnStr()
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

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(Request.QueryString["cid"]))
            int.TryParse(Request.QueryString["cid"], out myCid);
        if (!string.IsNullOrEmpty(Request.QueryString["vid"]))
            int.TryParse(Request.QueryString["vid"], out myVid);
    }

    protected void Btnadd_Click(object sender, EventArgs e)
    {
        string content = mcontent.Value.Trim();
        if (string.IsNullOrEmpty(content))
        {
            pageMsg = "请输入试题描述";
            pageMsgType = "error";
            return;
        }

        string optionsDataJson = HiddenOptionsData.Value;
        bool isBlank = QBlack.Checked;
        
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            pageMsg = "数据库连接失败";
            pageMsgType = "error";
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                SqlTransaction trans = conn.BeginTransaction();
                
                try
                {
                    // 1. 插入题目
                    string sqlQuestion = "INSERT INTO SurveyQuestion (Qvid, Qcid, Qtitle, Qblack, Qcount) VALUES (@vid, @cid, @title, @black, 0); SELECT SCOPE_IDENTITY();";
                    int newQid = 0;
                    
                    using (SqlCommand cmd = new SqlCommand(sqlQuestion, conn, trans))
                    {
                        cmd.Parameters.AddWithValue("@vid", myVid);
                        cmd.Parameters.AddWithValue("@cid", myCid);
                        cmd.Parameters.Add("@title", SqlDbType.NText).Value = content;
                        cmd.Parameters.AddWithValue("@black", isBlank ? 1 : 0);
                        
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            newQid = Convert.ToInt32(result);
                        }
                    }
                    
                    if (newQid <= 0)
                    {
                        trans.Rollback();
                        pageMsg = "添加题目失败";
                        pageMsgType = "error";
                        return;
                    }
                    
                    // 2. 解析并插入选项
                    if (!string.IsNullOrEmpty(optionsDataJson) && !isBlank)
                    {
                        try
                        {
                            // 手动解析JSON（兼容.NET 2.0）
                            optionsDataJson = optionsDataJson.Trim();
                            if (optionsDataJson.StartsWith("{") && optionsDataJson.Contains("\"options\""))
                            {
                                // 提取options数组
                                int optionsStart = optionsDataJson.IndexOf("\"options\"");
                                int arrayStart = optionsDataJson.IndexOf("[", optionsStart);
                                int arrayEnd = optionsDataJson.LastIndexOf("]");
                                
                                if (arrayStart > 0 && arrayEnd > arrayStart)
                                {
                                    string optionsArray = optionsDataJson.Substring(arrayStart + 1, arrayEnd - arrayStart - 1);
                                    
                                    // 分割每个选项对象
                                    string[] optionObjects = optionsArray.Split(new string[] { "},{" }, StringSplitOptions.RemoveEmptyEntries);
                                    
                                    foreach (string optObj in optionObjects)
                                    {
                                        string obj = optObj.Trim().TrimStart('{').TrimEnd('}');
                                        
                                        // 提取字段值
                                        string optContent = ExtractJsonValue(obj, "content");
                                        string optScoreStr = ExtractJsonValue(obj, "score");
                                        string optCorrectStr = ExtractJsonValue(obj, "correct");
                                        
                                        int optScore = 0;
                                        bool optCorrect = false;
                                        
                                        if (!string.IsNullOrEmpty(optScoreStr))
                                        {
                                            int.TryParse(optScoreStr, out optScore);
                                        }
                                        
                                        if (!string.IsNullOrEmpty(optCorrectStr))
                                        {
                                            optCorrect = optCorrectStr.ToLower() == "true";
                                        }
                                        
                                        // 如果是正确答案但分值为0，自动设置分值
                                        if (optCorrect && optScore == 0)
                                        {
                                            string qType = ExtractJsonValue(optionsDataJson, "type");
                                            optScore = (qType == "multiple") ? 2 : 5;
                                        }
                                        
                                        if (!string.IsNullOrEmpty(optContent))
                                        {
                                            string sqlItem = "INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack) VALUES (@qid, @vid, @item, @score, 0, @cid, 0)";
                                            using (SqlCommand cmdItem = new SqlCommand(sqlItem, conn, trans))
                                            {
                                                cmdItem.Parameters.AddWithValue("@qid", newQid);
                                                cmdItem.Parameters.AddWithValue("@vid", myVid);
                                                cmdItem.Parameters.Add("@item", SqlDbType.NText).Value = optContent;
                                                cmdItem.Parameters.AddWithValue("@score", optScore);
                                                cmdItem.Parameters.AddWithValue("@cid", myCid);
                                                cmdItem.ExecuteNonQuery();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch (Exception exJson)
                        {
                            // JSON解析失败，继续但不添加选项
                            System.Diagnostics.Debug.WriteLine("JSON解析失败: " + exJson.Message);
                        }
                    }
                    
                    trans.Commit();
                    pageMsg = "试题添加成功！";
                    pageMsgType = "success";
                    
                    // 清空表单
                    mcontent.Value = "";
                    QBlack.Checked = false;
                    HiddenOptionsData.Value = "";
                }
                catch (Exception exTrans)
                {
                    trans.Rollback();
                    pageMsg = "添加失败: " + exTrans.Message;
                    pageMsgType = "error";
                }
            }
        }
        catch (Exception ex)
        {
            pageMsg = "操作失败: " + ex.Message;
            pageMsgType = "error";
        }
    }
    
    private string ExtractJsonValue(string json, string key)
    {
        try
        {
            string searchKey = "\"" + key + "\"";
            int keyIndex = json.IndexOf(searchKey);
            if (keyIndex < 0) return "";
            
            int colonIndex = json.IndexOf(":", keyIndex);
            if (colonIndex < 0) return "";
            
            int valueStart = colonIndex + 1;
            while (valueStart < json.Length && (json[valueStart] == ' ' || json[valueStart] == '\t'))
                valueStart++;
            
            if (valueStart >= json.Length) return "";
            
            // 处理字符串值
            if (json[valueStart] == '"')
            {
                int valueEnd = json.IndexOf('"', valueStart + 1);
                if (valueEnd < 0) return "";
                return json.Substring(valueStart + 1, valueEnd - valueStart - 1);
            }
            // 处理布尔值和数字
            else
            {
                int valueEnd = valueStart;
                while (valueEnd < json.Length && json[valueEnd] != ',' && json[valueEnd] != '}')
                    valueEnd++;
                return json.Substring(valueStart, valueEnd - valueStart).Trim();
            }
        }
        catch
        {
            return "";
        }
    }

    protected void BtnSurvey_Click(object sender, EventArgs e)
    {
        Response.Redirect("survey.aspx?cid=" + myCid + "&vid=" + myVid);
    }
    
    public int myCid()
    {
        return myCid;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">

<link href="../teacher/show-common.css" rel="stylesheet" type="text/css" />
