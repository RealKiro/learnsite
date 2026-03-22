#pragma checksum "C:\inetpub\wwwroot\LearnSite\student\UpdateLearningProgress.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "91371EE9DC75419AE46A7F1035925350"

#line 1 "C:\inetpub\wwwroot\LearnSite\student\UpdateLearningProgress.ashx"


using System;
using System.Web;
using System.Data.SqlClient;

public class UpdateLearningProgress : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            int studentId = GetCurrentStudentId(context);
            if (studentId <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"未登录\"}");
                return;
            }
            
            string action = context.Request["action"];
            int resourceId = 0;
            int.TryParse(context.Request["resourceId"], out resourceId);
            
            if (resourceId <= 0)
            {
                context.Response.Write("{\"success\":false,\"message\":\"资源ID无效\"}");
                return;
            }
            
            if (action == "updateProgress")
            {
                int chapterId = 0;
                int.TryParse(context.Request["chapterId"], out chapterId);
                decimal progress = 0;
                decimal.TryParse(context.Request["progress"], out progress);
                int lastPosition = 0;
                int.TryParse(context.Request["lastPosition"], out lastPosition);
                
                UpdateProgress(studentId, resourceId, chapterId, progress, lastPosition);
                context.Response.Write("{\"success\":true}");
            }
            else if (action == "completeChapter")
            {
                int chapterId = 0;
                int.TryParse(context.Request["chapterId"], out chapterId);
                
                CompleteChapter(studentId, resourceId, chapterId);
                context.Response.Write("{\"success\":true}");
            }
            else if (action == "checkCompletion")
            {
                bool completed = CheckResourceCompletion(studentId, resourceId);
                if (completed)
                {
                    int credits = AwardCredits(studentId, resourceId);
                    context.Response.Write("{\"success\":true,\"completed\":true,\"credits\":" + credits + "}");
                }
                else
                {
                    context.Response.Write("{\"success\":true,\"completed\":false}");
                }
            }
            else
            {
                context.Response.Write("{\"success\":false,\"message\":\"无效的操作\"}");
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
    }
    
    private int GetCurrentStudentId(HttpContext context)
    {
        try
        {
            HttpCookie sc = context.Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Sid");
                    if (p != null)
                    {
                        object v = p.GetValue(m, null);
                        if (v != null)
                        {
                            int sid;
                            if (int.TryParse(v.ToString(), out sid)) return sid;
                        }
                    }
                }
            }
        }
        catch { }
        return 0;
    }
    
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
    
    private void UpdateProgress(int studentId, int resourceId, int chapterId, decimal progress, int lastPosition)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            string checkSql = "";
            SqlCommand checkCmd = null;
            
            if (chapterId > 0)
            {
                checkSql = @"SELECT ProgressId, IsCompleted FROM ResourceLearningProgress 
                           WHERE StudentId = @StudentId AND ChapterId = @ChapterId";
                checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@StudentId", studentId);
                checkCmd.Parameters.AddWithValue("@ChapterId", chapterId);
            }
            else
            {
                checkSql = @"SELECT ProgressId, IsCompleted FROM ResourceLearningProgress 
                           WHERE StudentId = @StudentId AND ResourceId = @ResourceId AND ChapterId IS NULL";
                checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@StudentId", studentId);
                checkCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            }
            
            using (SqlDataReader reader = checkCmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    int progressId = reader.GetInt32(0);
                    bool isCompleted = reader.GetBoolean(1);
                    reader.Close();
                    
                    // 如果已完成，保持100%进度，不更新
                    if (isCompleted)
                    {
                        string updateSql = @"UPDATE ResourceLearningProgress 
                                            SET LastPosition = @LastPosition, LastUpdateTime = GETDATE()
                                            WHERE ProgressId = @ProgressId";
                        
                        SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                        updateCmd.Parameters.AddWithValue("@LastPosition", lastPosition);
                        updateCmd.Parameters.AddWithValue("@ProgressId", progressId);
                        updateCmd.ExecuteNonQuery();
                    }
                    else
                    {
                        // 未完成时正常更新进度
                        string updateSql = @"UPDATE ResourceLearningProgress 
                                            SET Progress = @Progress, LastPosition = @LastPosition, 
                                            LastUpdateTime = GETDATE()
                                            WHERE ProgressId = @ProgressId";
                        
                        SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                        updateCmd.Parameters.AddWithValue("@Progress", progress);
                        updateCmd.Parameters.AddWithValue("@LastPosition", lastPosition);
                        updateCmd.Parameters.AddWithValue("@ProgressId", progressId);
                        updateCmd.ExecuteNonQuery();
                    }
                    return;
                }
                reader.Close();
            }
            
            // 没有记录，插入新记录
            string insertSql = @"INSERT INTO ResourceLearningProgress 
                                (StudentId, ResourceId, ChapterId, Progress, LastPosition, CreateTime, LastUpdateTime)
                                VALUES (@StudentId, @ResourceId, @ChapterId, @Progress, @LastPosition, GETDATE(), GETDATE())";
            
            SqlCommand insertCmd = new SqlCommand(insertSql, conn);
            insertCmd.Parameters.AddWithValue("@StudentId", studentId);
            insertCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            if (chapterId > 0)
                insertCmd.Parameters.AddWithValue("@ChapterId", chapterId);
            else
                insertCmd.Parameters.AddWithValue("@ChapterId", DBNull.Value);
            insertCmd.Parameters.AddWithValue("@Progress", progress);
            insertCmd.Parameters.AddWithValue("@LastPosition", lastPosition);
            insertCmd.ExecuteNonQuery();
        }
    }
    
    private void CompleteChapter(int studentId, int resourceId, int chapterId)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            string checkSql = "";
            SqlCommand checkCmd = null;
            
            if (chapterId > 0)
            {
                // 多章节资源
                checkSql = @"SELECT ProgressId, IsCompleted FROM ResourceLearningProgress 
                           WHERE StudentId = @StudentId AND ChapterId = @ChapterId";
                checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@StudentId", studentId);
                checkCmd.Parameters.AddWithValue("@ChapterId", chapterId);
            }
            else
            {
                // 单资源
                checkSql = @"SELECT ProgressId, IsCompleted FROM ResourceLearningProgress 
                           WHERE StudentId = @StudentId AND ResourceId = @ResourceId AND ChapterId IS NULL";
                checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@StudentId", studentId);
                checkCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            }
            
            using (SqlDataReader reader = checkCmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    int progressId = reader.GetInt32(0);
                    bool isCompleted = reader.GetBoolean(1);
                    reader.Close();
                    
                    // 只在未完成时更新为完成状态
                    if (!isCompleted)
                    {
                        string updateSql = @"UPDATE ResourceLearningProgress 
                                            SET Progress = 100, IsCompleted = 1, CompletedTime = GETDATE(), 
                                            LastUpdateTime = GETDATE()
                                            WHERE ProgressId = @ProgressId";
                        
                        SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                        updateCmd.Parameters.AddWithValue("@ProgressId", progressId);
                        updateCmd.ExecuteNonQuery();
                    }
                    return;
                }
                reader.Close();
            }
            
            // 没有记录，插入新记录
            string insertSql = @"INSERT INTO ResourceLearningProgress 
                                (StudentId, ResourceId, ChapterId, Progress, IsCompleted, CompletedTime, CreateTime, LastUpdateTime)
                                VALUES (@StudentId, @ResourceId, @ChapterId, 100, 1, GETDATE(), GETDATE(), GETDATE())";
            
            SqlCommand insertCmd = new SqlCommand(insertSql, conn);
            insertCmd.Parameters.AddWithValue("@StudentId", studentId);
            insertCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            if (chapterId > 0)
                insertCmd.Parameters.AddWithValue("@ChapterId", chapterId);
            else
                insertCmd.Parameters.AddWithValue("@ChapterId", DBNull.Value);
            insertCmd.ExecuteNonQuery();
        }
    }
    
    private bool CheckResourceCompletion(int studentId, int resourceId)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return false;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            // 先检查资源是否有章节
            string checkChaptersSql = "SELECT COUNT(*) FROM ResourceChapters WHERE ResourceId = @ResourceId";
            SqlCommand checkCmd = new SqlCommand(checkChaptersSql, conn);
            checkCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            int chapterCount = Convert.ToInt32(checkCmd.ExecuteScalar());
            
            if (chapterCount == 0)
            {
                // 单资源，检查是否已完成
                string checkSql = @"SELECT COUNT(*) FROM ResourceLearningProgress 
                                   WHERE StudentId = @StudentId AND ResourceId = @ResourceId 
                                   AND ChapterId IS NULL AND IsCompleted = 1";
                SqlCommand cmd = new SqlCommand(checkSql, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ResourceId", resourceId);
                
                int completed = Convert.ToInt32(cmd.ExecuteScalar());
                return completed > 0;
            }
            else
            {
                // 多章节资源，检查所有章节是否完成
                string sql = @"SELECT 
                              (SELECT COUNT(*) FROM ResourceChapters WHERE ResourceId = @ResourceId) as TotalChapters,
                              (SELECT COUNT(DISTINCT ChapterId) FROM ResourceLearningProgress 
                               WHERE StudentId = @StudentId 
                               AND ChapterId IN (SELECT ChapterId FROM ResourceChapters WHERE ResourceId = @ResourceId)
                               AND IsCompleted = 1) as CompletedChapters";
                
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@ResourceId", resourceId);
                
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int total = reader.GetInt32(0);
                        int completed = reader.GetInt32(1);
                        
                        return total > 0 && completed >= total;
                    }
                }
            }
        }
        
        return false;
    }
    
    private int AwardCredits(int studentId, int resourceId)
    {
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return 0;
        
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            
            // 检查资源是否有章节
            string checkChaptersSql = "SELECT COUNT(*) FROM ResourceChapters WHERE ResourceId = @ResourceId";
            SqlCommand checkChaptersCmd = new SqlCommand(checkChaptersSql, conn);
            checkChaptersCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            int chapterCount = Convert.ToInt32(checkChaptersCmd.ExecuteScalar());
            
            // 检查是否已经发放过积分
            string checkSql = "";
            if (chapterCount > 0)
            {
                // 多章节资源
                checkSql = @"SELECT TOP 1 CreditsAwarded 
                           FROM ResourceLearningProgress 
                           WHERE StudentId = @StudentId 
                           AND ChapterId IN (SELECT ChapterId FROM ResourceChapters WHERE ResourceId = @ResourceId)
                           AND CreditsAwarded = 1";
            }
            else
            {
                // 单资源
                checkSql = @"SELECT TOP 1 CreditsAwarded 
                           FROM ResourceLearningProgress 
                           WHERE StudentId = @StudentId AND ResourceId = @ResourceId 
                           AND ChapterId IS NULL AND CreditsAwarded = 1";
            }
            
            SqlCommand checkCmd = new SqlCommand(checkSql, conn);
            checkCmd.Parameters.AddWithValue("@StudentId", studentId);
            checkCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            
            object result = checkCmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return 0; // 已经发放过积分
            }
            
            // 获取观看积分
            string creditsSql = "SELECT ISNULL(ViewCredits, 0) FROM Files WHERE FileId = @ResourceId";
            SqlCommand creditsCmd = new SqlCommand(creditsSql, conn);
            creditsCmd.Parameters.AddWithValue("@ResourceId", resourceId);
            
            int credits = 0;
            object creditsResult = creditsCmd.ExecuteScalar();
            if (creditsResult != null && creditsResult != DBNull.Value)
            {
                credits = Convert.ToInt32(creditsResult);
            }
            
            if (credits > 0)
            {
                // 更新学生的学习积分和总积分
                string updateStudentSql = @"UPDATE Students 
                                           SET Slearnscore = ISNULL(Slearnscore, 0) + @Credits,
                                               Sallscore = ISNULL(Sallscore, 0) + @Credits 
                                           WHERE Sid = @StudentId";
                SqlCommand updateStudentCmd = new SqlCommand(updateStudentSql, conn);
                updateStudentCmd.Parameters.AddWithValue("@Credits", credits);
                updateStudentCmd.Parameters.AddWithValue("@StudentId", studentId);
                updateStudentCmd.ExecuteNonQuery();
                
                // 标记为已发放积分
                string markAwardedSql = "";
                if (chapterCount > 0)
                {
                    // 多章节资源
                    markAwardedSql = @"UPDATE ResourceLearningProgress 
                                     SET CreditsAwarded = 1 
                                     WHERE StudentId = @StudentId 
                                     AND ChapterId IN (SELECT ChapterId FROM ResourceChapters WHERE ResourceId = @ResourceId)";
                }
                else
                {
                    // 单资源
                    markAwardedSql = @"UPDATE ResourceLearningProgress 
                                     SET CreditsAwarded = 1 
                                     WHERE StudentId = @StudentId AND ResourceId = @ResourceId AND ChapterId IS NULL";
                }
                
                SqlCommand markCmd = new SqlCommand(markAwardedSql, conn);
                markCmd.Parameters.AddWithValue("@StudentId", studentId);
                markCmd.Parameters.AddWithValue("@ResourceId", resourceId);
                markCmd.ExecuteNonQuery();
            }
            
            return credits;
        }
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
