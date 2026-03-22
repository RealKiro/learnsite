#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\App_Code\SecurityHelper.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "19F531A12075B68A1D4F141D7812E34F"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\App_Code\SecurityHelper.cs"
using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

/// <summary>
/// 安全辅助类 - 提供密码加密、验证、登录保护等功能
/// </summary>
public class SecurityHelper
{
    #region 密码加密

    /// <summary>
    /// 生成随机盐值
    /// </summary>
    public static string GenerateSalt()
    {
        byte[] saltBytes = new byte[16];
        RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
        rng.GetBytes(saltBytes);
        return Convert.ToBase64String(saltBytes);
    }

        /// <summary>
        /// 使用MD5+Salt加密密码
        /// </summary>
        /// <param name="password">明文密码</param>
        /// <param name="salt">盐值</param>
        /// <returns>加密后的密码</returns>
        public static string HashPassword(string password, string salt)
        {
            if (string.IsNullOrEmpty(password))
                return string.Empty;

            string saltedPassword = password + salt;
            using (MD5 md5 = MD5.Create())
            {
                byte[] inputBytes = Encoding.UTF8.GetBytes(saltedPassword);
                byte[] hashBytes = md5.ComputeHash(inputBytes);
                
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }

        /// <summary>
        /// 验证密码
        /// </summary>
        /// <param name="password">用户输入的密码</param>
        /// <param name="hashedPassword">数据库中的加密密码</param>
        /// <param name="salt">盐值</param>
        /// <returns>是否匹配</returns>
        public static bool VerifyPassword(string password, string hashedPassword, string salt)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(hashedPassword))
                return false;

            string hash = HashPassword(password, salt);
            return hash.Equals(hashedPassword, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// 兼容旧密码验证（明文）
        /// </summary>
        public static bool VerifyPasswordCompat(string password, string storedPassword, string salt)
        {
            // 如果盐值为空，说明是旧密码（明文）
            if (string.IsNullOrEmpty(salt))
            {
                return password == storedPassword;
            }
            
            // 新密码（加密）
            return VerifyPassword(password, storedPassword, salt);
        }

        #endregion

        #region 密码强度验证

        /// <summary>
        /// 验证密码强度
        /// </summary>
        /// <param name="password">密码</param>
        /// <param name="minLength">最小长度</param>
        /// <param name="requireUpperCase">是否需要大写字母</param>
        /// <param name="requireLowerCase">是否需要小写字母</param>
        /// <param name="requireDigit">是否需要数字</param>
        /// <param name="requireSpecialChar">是否需要特殊字符</param>
        /// <returns>错误消息，为空表示验证通过</returns>
        public static string ValidatePasswordStrength(string password)
        {
            return ValidatePasswordStrength(password, 6, false, false, false, false);
        }

        public static string ValidatePasswordStrength(string password, int minLength)
        {
            return ValidatePasswordStrength(password, minLength, false, false, false, false);
        }

        public static string ValidatePasswordStrength(
            string password,
            int minLength,
            bool requireUpperCase,
            bool requireLowerCase,
            bool requireDigit,
            bool requireSpecialChar)
        {
            if (string.IsNullOrEmpty(password))
                return "密码不能为空";

            if (password.Length < minLength)
                return string.Format("密码长度至少{0}位", minLength);

            if (requireUpperCase && !System.Text.RegularExpressions.Regex.IsMatch(password, "[A-Z]"))
                return "密码必须包含大写字母";

            if (requireLowerCase && !System.Text.RegularExpressions.Regex.IsMatch(password, "[a-z]"))
                return "密码必须包含小写字母";

            if (requireDigit && !System.Text.RegularExpressions.Regex.IsMatch(password, "[0-9]"))
                return "密码必须包含数字";

            if (requireSpecialChar && !System.Text.RegularExpressions.Regex.IsMatch(password, "[^a-zA-Z0-9]"))
                return "密码必须包含特殊字符";

            return string.Empty;
        }

        #endregion

        #region 登录保护

        private const string LOGIN_ATTEMPTS_KEY = "LoginAttempts_";
        private const string LOGIN_LOCKOUT_KEY = "LoginLockout_";
        private const int MAX_LOGIN_ATTEMPTS = 5;
        private const int LOCKOUT_MINUTES = 15;

        /// <summary>
        /// 记录登录失败
        /// </summary>
        /// <param name="username">用户名</param>
        /// <returns>剩余尝试次数</returns>
        public static int RecordLoginFailure(string username)
        {
            if (string.IsNullOrEmpty(username))
                return MAX_LOGIN_ATTEMPTS;

            string key = LOGIN_ATTEMPTS_KEY + username;
            int attempts = 0;

            if (HttpContext.Current.Session[key] != null)
            {
                attempts = (int)HttpContext.Current.Session[key];
            }

            attempts++;
            HttpContext.Current.Session[key] = attempts;
            HttpContext.Current.Session.Timeout = 30; // 30分钟过期

            // 如果达到最大尝试次数，锁定账号
            if (attempts >= MAX_LOGIN_ATTEMPTS)
            {
                string lockoutKey = LOGIN_LOCKOUT_KEY + username;
                HttpContext.Current.Session[lockoutKey] = DateTime.Now.AddMinutes(LOCKOUT_MINUTES);
            }

            return MAX_LOGIN_ATTEMPTS - attempts;
        }

        /// <summary>
        /// 清除登录失败记录
        /// </summary>
        public static void ClearLoginFailures(string username)
        {
            if (string.IsNullOrEmpty(username))
                return;

            string key = LOGIN_ATTEMPTS_KEY + username;
            string lockoutKey = LOGIN_LOCKOUT_KEY + username;

            HttpContext.Current.Session.Remove(key);
            HttpContext.Current.Session.Remove(lockoutKey);
        }

        /// <summary>
        /// 检查账号是否被锁定
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="remainingMinutes">剩余锁定分钟数</param>
        /// <returns>是否被锁定</returns>
        public static bool IsAccountLocked(string username, out int remainingMinutes)
        {
            remainingMinutes = 0;

            if (string.IsNullOrEmpty(username))
                return false;

            string lockoutKey = LOGIN_LOCKOUT_KEY + username;
            
            if (HttpContext.Current.Session[lockoutKey] != null)
            {
                DateTime lockoutTime = (DateTime)HttpContext.Current.Session[lockoutKey];
                
                if (DateTime.Now < lockoutTime)
                {
                    TimeSpan remaining = lockoutTime - DateTime.Now;
                    remainingMinutes = (int)Math.Ceiling(remaining.TotalMinutes);
                    return true;
                }
                else
                {
                    // 锁定时间已过，清除记录
                    ClearLoginFailures(username);
                }
            }

            return false;
        }

        /// <summary>
        /// 获取剩余登录尝试次数
        /// </summary>
        public static int GetRemainingAttempts(string username)
        {
            if (string.IsNullOrEmpty(username))
                return MAX_LOGIN_ATTEMPTS;

            string key = LOGIN_ATTEMPTS_KEY + username;
            
            if (HttpContext.Current.Session[key] != null)
            {
                int attempts = (int)HttpContext.Current.Session[key];
                return Math.Max(0, MAX_LOGIN_ATTEMPTS - attempts);
            }

            return MAX_LOGIN_ATTEMPTS;
        }

        #endregion

        #region 数据库密码迁移

        /// <summary>
        /// 迁移教师密码到加密存储
        /// </summary>
        /// <returns>迁移的记录数</returns>
        public static int MigrateTeacherPasswords()
        {
            int count = 0;
            string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 查找所有未加密的密码（Hsalt为空或NULL）
                string selectSql = "SELECT Hid, Hpwd FROM Teacher WHERE Hsalt IS NULL OR Hsalt = ''";
                SqlCommand selectCmd = new SqlCommand(selectSql, conn);
                
                DataTable dt = new DataTable();
                SqlDataAdapter adapter = new SqlDataAdapter(selectCmd);
                adapter.Fill(dt);

                foreach (DataRow row in dt.Rows)
                {
                    int hid = Convert.ToInt32(row["Hid"]);
                    string plainPassword = row["Hpwd"].ToString();

                    // 生成盐值和加密密码
                    string salt = GenerateSalt();
                    string hashedPassword = HashPassword(plainPassword, salt);

                    // 更新数据库
                    string updateSql = "UPDATE Teacher SET Hpwd=@Hpwd, Hsalt=@Hsalt WHERE Hid=@Hid";
                    SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                    updateCmd.Parameters.AddWithValue("@Hpwd", hashedPassword);
                    updateCmd.Parameters.AddWithValue("@Hsalt", salt);
                    updateCmd.Parameters.AddWithValue("@Hid", hid);
                    updateCmd.ExecuteNonQuery();

                    count++;
                }
            }

            return count;
        }

        /// <summary>
        /// 迁移学生密码到加密存储
        /// </summary>
        /// <returns>迁移的记录数</returns>
        public static int MigrateStudentPasswords()
        {
            int count = 0;
            string connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 查找所有未加密的密码（Ssalt为空或NULL）
                string selectSql = "SELECT Sid, Spwd FROM Students WHERE Ssalt IS NULL OR Ssalt = ''";
                SqlCommand selectCmd = new SqlCommand(selectSql, conn);
                
                DataTable dt = new DataTable();
                SqlDataAdapter adapter = new SqlDataAdapter(selectCmd);
                adapter.Fill(dt);

                foreach (DataRow row in dt.Rows)
                {
                    int sid = Convert.ToInt32(row["Sid"]);
                    string plainPassword = row["Spwd"].ToString();

                    // 生成盐值和加密密码
                    string salt = GenerateSalt();
                    string hashedPassword = HashPassword(plainPassword, salt);

                    // 更新数据库
                    string updateSql = "UPDATE Students SET Spwd=@Spwd, Ssalt=@Ssalt WHERE Sid=@Sid";
                    SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                    updateCmd.Parameters.AddWithValue("@Spwd", hashedPassword);
                    updateCmd.Parameters.AddWithValue("@Ssalt", salt);
                    updateCmd.Parameters.AddWithValue("@Sid", sid);
                    updateCmd.ExecuteNonQuery();

                    count++;
                }
            }

            return count;
        }

        #endregion

        #region XSS防护

        /// <summary>
        /// HTML编码（防XSS）
        /// </summary>
        public static string HtmlEncode(string text)
        {
            if (string.IsNullOrEmpty(text))
                return string.Empty;

            return HttpUtility.HtmlEncode(text);
        }

        /// <summary>
        /// JavaScript编码（防XSS）
        /// </summary>
        public static string JavaScriptEncode(string text)
        {
            if (string.IsNullOrEmpty(text))
                return string.Empty;

            return text.Replace("\\", "\\\\")
                       .Replace("'", "\\'")
                       .Replace("\"", "\\\"")
                       .Replace("\r", "\\r")
                       .Replace("\n", "\\n")
                       .Replace("<", "\\x3c")
                       .Replace(">", "\\x3e");
        }

        #endregion

        #region SQL注入防护

        /// <summary>
        /// 验证SQL参数（防止SQL注入）
        /// </summary>
        public static bool IsSafeSqlParameter(string parameter)
        {
            if (string.IsNullOrEmpty(parameter))
                return true;

            // 检查危险字符
            string[] dangerousPatterns = { 
                "--", ";--", "/*", "*/", "xp_", "sp_", 
                "exec", "execute", "drop", "create", "alter",
                "insert", "update", "delete", "select"
            };

            string lowerParam = parameter.ToLower();
            foreach (string pattern in dangerousPatterns)
            {
                if (lowerParam.Contains(pattern))
                    return false;
            }

            return true;
        }

        #endregion
    }



#line default
#line hidden
