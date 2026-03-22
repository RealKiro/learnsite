#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\submitexamanswers.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "F5F433EB5EB2A94650C236F21F2AC3DB"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\submitexamanswers.ashx"


using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Reflection;
using System.Text.RegularExpressions;

public class submitexamanswers : IHttpHandler
{
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
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

    private string CookProp(object m, string n)
    {
        if (m == null) return "";
        PropertyInfo p = m.GetType().GetProperty(n);
        if (p == null) return "";
        object v = p.GetValue(m, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, System.Text.Encoding.UTF8); } catch { } }
        return s;
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";

        // 验证学生登录
        LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
        if (!cook.IsExist())
        {
            context.Response.Write("未登录");
            return;
        }

        int sid = 0;
        int sgrade = 0;
        int sclass = 0;
        string s;
        s = CookProp(cook, "Sid"); if (!string.IsNullOrEmpty(s)) int.TryParse(s, out sid);
        s = CookProp(cook, "Sgrade"); if (!string.IsNullOrEmpty(s)) int.TryParse(s, out sgrade);
        s = CookProp(cook, "Sclass"); if (!string.IsNullOrEmpty(s)) int.TryParse(s, out sclass);

        if (sid <= 0)
        {
            context.Response.Write("学生信息无效");
            return;
        }

        // 读取参数
        string vidStr = context.Request.Form["vid"];
        string answersJson = context.Request.Form["answers"];
        if (string.IsNullOrEmpty(vidStr) || string.IsNullOrEmpty(answersJson))
        {
            context.Response.Write("参数不完整");
            return;
        }

        int vid = 0;
        if (!int.TryParse(vidStr, out vid) || vid <= 0)
        {
            context.Response.Write("参数无效");
            return;
        }

        // 解析答案JSON（简单解析，不依赖 System.Web.Extensions）
        List<Dictionary<string, string>> answers = new List<Dictionary<string, string>>();
        try
        {
            // 移除外层的 [ ]
            string json = answersJson.Trim();
            if (json.StartsWith("[")) json = json.Substring(1);
            if (json.EndsWith("]")) json = json.Substring(0, json.Length - 1);
            
            // 按 },{ 分割每个对象
            string[] items = json.Split(new string[] { "},{" }, StringSplitOptions.RemoveEmptyEntries);
            
            foreach (string item in items)
            {
                string obj = item.Trim();
                if (obj.StartsWith("{")) obj = obj.Substring(1);
                if (obj.EndsWith("}")) obj = obj.Substring(0, obj.Length - 1);
                
                Dictionary<string, string> dict = new Dictionary<string, string>();
                
                // 提取 qid 和 answer
                Match qidMatch = Regex.Match(obj, @"""qid""\s*:\s*(\d+)");
                Match ansMatch = Regex.Match(obj, @"""answer""\s*:\s*""([^""]*)""");
                
                if (qidMatch.Success)
                {
                    dict["qid"] = qidMatch.Groups[1].Value;
                    dict["answer"] = ansMatch.Success ? ansMatch.Groups[1].Value : "";
                    answers.Add(dict);
                }
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("JSON解析失败: " + ex.Message);
            return;
        }

        if (answers == null || answers.Count == 0)
        {
            context.Response.Write("答案为空");
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("数据库连接失败");
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 查找 ExamPublish 的 Eid
                int eid = 0;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 Eid FROM ExamPublish WHERE Epid=@pid AND Egrade=@grade AND Eclass=@class AND Estatus=1 ORDER BY Eid DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", vid);
                    cmd.Parameters.AddWithValue("@grade", sgrade);
                    cmd.Parameters.AddWithValue("@class", sclass);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out eid);
                }

                if (eid <= 0)
                {
                    // 尝试不限 Estatus
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT TOP 1 Eid FROM ExamPublish WHERE Epid=@pid AND Egrade=@grade AND Eclass=@class ORDER BY Eid DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", vid);
                        cmd.Parameters.AddWithValue("@grade", sgrade);
                        cmd.Parameters.AddWithValue("@class", sclass);
                        object v = cmd.ExecuteScalar();
                        if (v != null) int.TryParse(v.ToString(), out eid);
                    }
                }

                // 最终回退：不限 grade/class，只按 Epid 查找
                if (eid <= 0)
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT TOP 1 Eid FROM ExamPublish WHERE Epid=@pid ORDER BY Eid DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", vid);
                        object v = cmd.ExecuteScalar();
                        if (v != null) int.TryParse(v.ToString(), out eid);
                    }
                }

                if (eid <= 0)
                {
                    context.Response.Write("未找到对应的考试发布记录（Epid=" + vid + ", grade=" + sgrade + ", class=" + sclass + "）");
                    return;
                }

                // 检查是否已经存在该学生的 ExamAnswer 记录
                int existCount = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@eid", eid);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    existCount = Convert.ToInt32(cmd.ExecuteScalar());
                }

                if (existCount > 0)
                {
                    // 已有记录，更新而不是重复插入
                    int updateCount = 0;
                    foreach (Dictionary<string, string> ans in answers)
                    {
                        int qid = 0;
                        string answer = "";
                        if (ans.ContainsKey("qid")) int.TryParse(ans["qid"], out qid);
                        if (ans.ContainsKey("answer")) answer = ans["answer"] ?? "";
                        if (qid <= 0) continue;

                        try
                        {
                            // 检查该题是否已有记录
                            int recExists = 0;
                            using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamAnswer WHERE EAeid=@eid AND EAsid=@sid AND EAqid=@qid", conn))
                            {
                                chk.Parameters.AddWithValue("@eid", eid);
                                chk.Parameters.AddWithValue("@sid", sid);
                                chk.Parameters.AddWithValue("@qid", qid);
                                recExists = Convert.ToInt32(chk.ExecuteScalar());
                            }

                            if (recExists > 0)
                            {
                                using (SqlCommand upd = new SqlCommand(
                                    "UPDATE ExamAnswer SET EAanswer=@answer, EAdate=GETDATE() WHERE EAeid=@eid AND EAsid=@sid AND EAqid=@qid", conn))
                                {
                                    upd.Parameters.AddWithValue("@answer", answer ?? "");
                                    upd.Parameters.AddWithValue("@eid", eid);
                                    upd.Parameters.AddWithValue("@sid", sid);
                                    upd.Parameters.AddWithValue("@qid", qid);
                                    upd.ExecuteNonQuery();
                                    updateCount++;
                                }
                            }
                            else
                            {
                                using (SqlCommand ins = new SqlCommand(
                                    "INSERT INTO ExamAnswer(EAeid,EApid,EAsid,EAqid,EAanswer,EAscore,EAgraded,EAdate) VALUES(@eid,@pid,@sid,@qid,@answer,0,0,GETDATE())", conn))
                                {
                                    ins.Parameters.AddWithValue("@eid", eid);
                                    ins.Parameters.AddWithValue("@pid", vid);
                                    ins.Parameters.AddWithValue("@sid", sid);
                                    ins.Parameters.AddWithValue("@qid", qid);
                                    ins.Parameters.AddWithValue("@answer", answer ?? "");
                                    ins.ExecuteNonQuery();
                                    updateCount++;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            // 记录错误但继续处理其他题目
                            System.Diagnostics.Debug.WriteLine("更新题目 " + qid + " 失败: " + ex.Message);
                        }
                    }
                    if (updateCount == 0)
                    {
                        context.Response.Write("保存失败：没有成功更新任何答案");
                        return;
                    }
                }
                else
                {
                    // 首次提交，批量插入
                    int insertCount = 0;
                    foreach (Dictionary<string, string> ans in answers)
                    {
                        int qid = 0;
                        string answer = "";
                        if (ans.ContainsKey("qid")) int.TryParse(ans["qid"], out qid);
                        if (ans.ContainsKey("answer")) answer = ans["answer"] ?? "";
                        if (qid <= 0) continue;

                        try
                        {
                            using (SqlCommand ins = new SqlCommand(
                                "INSERT INTO ExamAnswer(EAeid,EApid,EAsid,EAqid,EAanswer,EAscore,EAgraded,EAdate) VALUES(@eid,@pid,@sid,@qid,@answer,0,0,GETDATE())", conn))
                            {
                                ins.Parameters.AddWithValue("@eid", eid);
                                ins.Parameters.AddWithValue("@pid", vid);
                                ins.Parameters.AddWithValue("@sid", sid);
                                ins.Parameters.AddWithValue("@qid", qid);
                                ins.Parameters.AddWithValue("@answer", answer ?? "");
                                ins.ExecuteNonQuery();
                                insertCount++;
                            }
                        }
                        catch (Exception ex)
                        {
                            // 记录错误但继续处理其他题目
                            System.Diagnostics.Debug.WriteLine("插入题目 " + qid + " 失败: " + ex.Message);
                        }
                    }
                    if (insertCount == 0)
                    {
                        context.Response.Write("保存失败：没有成功保存任何答案");
                        return;
                    }
                }
            }
            context.Response.Write("ok");
        }
        catch (Exception ex)
        {
            context.Response.Write("保存失败：" + ex.Message);
        }
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
