using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using LearnSite.Common;
using LearnSite.Model;

public partial class Teacher_index : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // 检查是否已经登录
            HttpCookie tc = Request.Cookies[CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                // 已登录，跳转到信息页
                Response.Redirect("infomation.aspx");
                return;
            }
        }
    }

    protected void Btnlogin_Click(object sender, EventArgs e)
    {
        string teacherNum = Textname.Text.Trim();
        string password = Textpwd.Text.Trim();
        string captcha = TxtCaptcha.Text.Trim();

        // 验证输入
        if (string.IsNullOrEmpty(teacherNum))
        {
            Labelmsg.Text = "请输入工号";
            return;
        }

        if (string.IsNullOrEmpty(password))
        {
            Labelmsg.Text = "请输入密码";
            return;
        }

        if (string.IsNullOrEmpty(captcha))
        {
            Labelmsg.Text = "请输入验证码";
            return;
        }

        // 验证验证码
        string sessionCaptcha = Session["TeacherCaptcha"] as string;
        if (string.IsNullOrEmpty(sessionCaptcha))
        {
            Labelmsg.Text = "验证码已过期，请刷新后重试";
            return;
        }

        if (!captcha.Equals(sessionCaptcha, StringComparison.OrdinalIgnoreCase))
        {
            Labelmsg.Text = "验证码错误";
            // 清除验证码
            Session.Remove("TeacherCaptcha");
            return;
        }

        // 清除验证码（无论登录成功与否）
        Session.Remove("TeacherCaptcha");

        // 验证教师账号
        string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string sql = "SELECT Hid, Hname, Hnum, Hpwd, Hsalt FROM Teacher WHERE Hnum=@Hnum";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Hnum", teacherNum);

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (!reader.Read())
                {
                    Labelmsg.Text = "工号不存在";
                    return;
                }

                int hid = Convert.ToInt32(reader["Hid"]);
                string hname = reader["Hname"].ToString();
                string hnum = reader["Hnum"].ToString();
                string hpwd = reader["Hpwd"].ToString();
                string hsalt = reader["Hsalt"] != DBNull.Value ? reader["Hsalt"].ToString() : "";

                reader.Close();

                // 验证密码（支持新旧密码）
                bool passwordValid = false;
                if (string.IsNullOrEmpty(hsalt))
                {
                    // 旧密码（明文）
                    passwordValid = (hpwd == password);
                }
                else
                {
                    // 新密码（加密）
                    passwordValid = SecurityHelper.VerifyPassword(password, hpwd, hsalt);
                }

                if (!passwordValid)
                {
                    Labelmsg.Text = "密码错误";
                    return;
                }

                // 登录成功，创建Cookie
                // 直接构造Cookie值，格式：Hid|Hname|Hnum
                string cookieValue = string.Format("{0}|{1}|{2}", hid, hname, hnum);
                
                HttpCookie cookie = new HttpCookie(CookieHelp.teaCookieNname);
                cookie.Value = Server.UrlEncode(cookieValue);
                cookie.Expires = DateTime.Now.AddDays(7); // 7天有效期
                Response.Cookies.Add(cookie);

                // 跳转到信息页
                Response.Redirect("infomation.aspx");
            }
            catch (Exception ex)
            {
                Labelmsg.Text = "登录失败：" + ex.Message;
            }
        }
    }
}