#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\profile.aspx.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "0F50066A12EB918262176E8E5D8A45A5"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\profile.aspx.cs"
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearnSite.Common;
using LearnSite.Model;

public partial class teacher_profile : System.Web.UI.Page
{
    protected int myHid = 0;
    protected string myHname = "";
    protected string myHnum = "";
    protected string myEmail = "";
    protected string myAvatarUrl = "";
    protected string myInitial = "师";
    protected string myCampus = "";
    protected string mySchool = "";

    private static readonly System.Reflection.BindingFlags TFlags =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    protected void Page_Load(object sender, EventArgs e)
    {
        // 验证登录（与 Teach.master 使用相同的 TeaCook.ToModel 解析）
        HttpCookie tc = Request.Cookies[CookieHelp.teaCookieNname];
        if (tc == null || string.IsNullOrEmpty(tc.Value))
        {
            Response.Redirect(ResolveUrl("~/teacher/index.aspx"));
            return;
        }

        try
        {
            Type cookType = typeof(CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
            if (cookType == null) { Response.Redirect(ResolveUrl("~/teacher/index.aspx")); return; }
            object model = Activator.CreateInstance(cookType);
            System.Reflection.MethodInfo toModel = cookType.GetMethod("ToModel", TFlags);
            if (toModel == null) { Response.Redirect(ResolveUrl("~/teacher/index.aspx")); return; }
            toModel.Invoke(model, new object[] { tc.Value });

            System.Reflection.PropertyInfo hidProp = cookType.GetProperty("Hid");
            System.Reflection.PropertyInfo hnameProp = cookType.GetProperty("Hname");
            System.Reflection.PropertyInfo hnumProp = cookType.GetProperty("Hnum");
            if (hidProp != null) { object v = hidProp.GetValue(model, null); if (v != null) int.TryParse(v.ToString(), out myHid); }
            if (hnameProp != null) { object v = hnameProp.GetValue(model, null); if (v != null) myHname = v.ToString(); }
            if (hnumProp != null) { object v = hnumProp.GetValue(model, null); if (v != null) myHnum = v.ToString(); }

            if (myHid <= 0) { Response.Redirect(ResolveUrl("~/teacher/index.aspx")); return; }
        }
        catch
        {
            Response.Redirect(ResolveUrl("~/teacher/index.aspx"));
            return;
        }

        // 仅首次加载时从数据库读取，避免回发时覆盖用户已填写的表单值
        if (!IsPostBack)
        {
            LoadTeacherInfo();
        }
    }

    private void LoadTeacherInfo()
    {
        // 从数据库加载教师信息：依次尝试 Teacher / Teachers，哪个表存在且有记录就用哪个
        string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        string[] tableCandidates = { "Teacher", "Teachers" };

        foreach (string table in tableCandidates)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                try
                {
                    conn.Open();
                    
                    // 先查询基本信息（Hname, Hemail 是必有字段）
                    string sql = "SELECT Hname, Hemail FROM " + table + " WHERE Hid=@Hid";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Hid", myHid);
                    
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            myHname = reader["Hname"].ToString();
                            myEmail = reader["Hemail"] != DBNull.Value ? reader["Hemail"].ToString() : "";
                            reader.Close();
                            
                            // 尝试查询校区信息（CampusId 字段可能不存在）
                            try
                            {
                                string campusSql = "SELECT CampusId FROM " + table + " WHERE Hid=@Hid";
                                SqlCommand campusCmd = new SqlCommand(campusSql, conn);
                                campusCmd.Parameters.AddWithValue("@Hid", myHid);
                                
                                object campusIdObj = campusCmd.ExecuteScalar();
                                if (campusIdObj != null && campusIdObj != DBNull.Value)
                                {
                                    int campusId = 0;
                                    if (int.TryParse(campusIdObj.ToString(), out campusId) && campusId > 0)
                                    {
                                        // 查询校区名称
                                        try
                                        {
                                            string campusNameSql = "SELECT CampusName FROM Campus WHERE CampusId=@CampusId";
                                            SqlCommand campusNameCmd = new SqlCommand(campusNameSql, conn);
                                            campusNameCmd.Parameters.AddWithValue("@CampusId", campusId);
                                            
                                            object campusNameObj = campusNameCmd.ExecuteScalar();
                                            if (campusNameObj != null && campusNameObj != DBNull.Value)
                                            {
                                                myCampus = campusNameObj.ToString();
                                            }
                                        }
                                        catch (Exception ex)
                                        {
                                            System.Diagnostics.Debug.WriteLine("LoadCampusName Error: " + ex.Message);
                                        }
                                    }
                                }
                            }
                            catch (SqlException ex)
                            {
                                // CampusId 字段不存在，忽略错误
                                System.Diagnostics.Debug.WriteLine("CampusId field not found in " + table + ": " + ex.Message);
                            }
                            
                            // 尝试查询学校信息（SchoolId 字段可能不存在）
                            try
                            {
                                string schoolSql = "SELECT SchoolId FROM " + table + " WHERE Hid=@Hid";
                                SqlCommand schoolCmd = new SqlCommand(schoolSql, conn);
                                schoolCmd.Parameters.AddWithValue("@Hid", myHid);
                                
                                object schoolIdObj = schoolCmd.ExecuteScalar();
                                if (schoolIdObj != null && schoolIdObj != DBNull.Value)
                                {
                                    int schoolId = 0;
                                    if (int.TryParse(schoolIdObj.ToString(), out schoolId) && schoolId > 0)
                                    {
                                        // 查询学校名称
                                        try
                                        {
                                            string schoolNameSql = "SELECT SchoolName FROM School WHERE SchoolId=@SchoolId AND IsActive=1";
                                            SqlCommand schoolNameCmd = new SqlCommand(schoolNameSql, conn);
                                            schoolNameCmd.Parameters.AddWithValue("@SchoolId", schoolId);
                                            
                                            object schoolNameObj = schoolNameCmd.ExecuteScalar();
                                            if (schoolNameObj != null && schoolNameObj != DBNull.Value)
                                            {
                                                mySchool = schoolNameObj.ToString();
                                            }
                                        }
                                        catch (Exception ex)
                                        {
                                            System.Diagnostics.Debug.WriteLine("LoadSchoolName Error: " + ex.Message);
                                        }
                                    }
                                }
                            }
                            catch (SqlException ex)
                            {
                                // SchoolId 字段不存在，忽略错误
                                System.Diagnostics.Debug.WriteLine("SchoolId field not found in " + table + ": " + ex.Message);
                            }
                            
                            // 找到了有效记录，直接跳出循环
                            break;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    // 可能是表不存在 / 字段不存在，继续尝试下一个候选表
                    System.Diagnostics.Debug.WriteLine("LoadTeacherInfo table " + table + " error: " + ex.Message);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("LoadTeacherInfo Error: " + ex.Message);
                }
            }
        }

        // 检查头像文件
        string[] exts = { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
        foreach (string ext in exts)
        {
            string filePath = Server.MapPath("~/images/avatars/" + myHid + ext);
            if (File.Exists(filePath))
            {
                myAvatarUrl = ResolveUrl("~/images/avatars/" + myHid + ext) + "?t=" + File.GetLastWriteTime(filePath).Ticks;
                break;
            }
        }

        // 设置初始字母
        if (!string.IsNullOrEmpty(myHname))
        {
            myInitial = myHname.Substring(0, 1);
        }

        // 更新页面显示
        LitTeacherName.Text = Server.HtmlEncode(myHname);
        LitTeacherEmail.Text = !string.IsNullOrEmpty(myEmail) ? Server.HtmlEncode(myEmail) : "未绑定邮箱";
        LitSchoolDisplay.Text = !string.IsNullOrEmpty(mySchool) ? Server.HtmlEncode(mySchool) : "未设置学校";
        LitCampusDisplay.Text = !string.IsNullOrEmpty(myCampus) ? Server.HtmlEncode(myCampus) : "未设置校区";
        TxtEmail.Text = myEmail;
        
        // 控制校区标签的可见性：只有设置了校区才显示
        if (campusTag != null)
        {
            campusTag.Visible = !string.IsNullOrEmpty(myCampus);
        }
        
        // 控制学校标签的可见性：只有设置了学校才显示
        if (schoolTag != null)
        {
            schoolTag.Visible = !string.IsNullOrEmpty(mySchool);
        }

        // 邮箱绑定区域显示逻辑：已绑定只显示邮箱+修改按钮，不再显示绑定窗口
        bool hasEmail = !string.IsNullOrEmpty(myEmail);
        if (PnlEmailSummary != null) PnlEmailSummary.Visible = hasEmail;
        if (PnlEmailForm != null) PnlEmailForm.Visible = !hasEmail;
        if (LblBoundEmail != null)
        {
            LblBoundEmail.Text = hasEmail ? Server.HtmlEncode(myEmail) : "未绑定邮箱";
        }

        // 头像显示
        if (!string.IsNullOrEmpty(myAvatarUrl))
        {
            LitHeaderAvatar.Text = "<img src=\"" + myAvatarUrl + "\" />";
            LitAvatarPreview.Text = "<img src=\"" + myAvatarUrl + "\" />";
        }
        else
        {
            LitHeaderAvatar.Text = Server.HtmlEncode(myInitial);
            LitAvatarPreview.Text = Server.HtmlEncode(myInitial);
        }
    }

    // 上传头像
    protected void BtnUploadAvatar_Click(object sender, EventArgs e)
    {
        if (!FileAvatar.HasFile)
        {
            ShowMessage("avatar", "error", "请选择要上传的图片");
            return;
        }

        // 验证文件类型
        string ext = Path.GetExtension(FileAvatar.FileName).ToLower();
        if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif" && ext != ".webp")
        {
            ShowMessage("avatar", "error", "只支持 JPG、PNG、GIF、WebP 格式的图片");
            return;
        }

        // 验证文件大小（2MB）
        if (FileAvatar.PostedFile.ContentLength > 2 * 1024 * 1024)
        {
            ShowMessage("avatar", "error", "图片大小不能超过 2MB");
            return;
        }

        try
        {
            // 确保目录存在
            string avatarDir = Server.MapPath("~/images/avatars/");
            if (!Directory.Exists(avatarDir))
            {
                Directory.CreateDirectory(avatarDir);
            }

            // 删除旧头像
            string[] oldExts = { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
            foreach (string oldExt in oldExts)
            {
                string oldFile = Path.Combine(avatarDir, myHid + oldExt);
                if (File.Exists(oldFile))
                {
                    File.Delete(oldFile);
                }
            }

            // 保存新头像
            string newFileName = myHid + ext;
            string savePath = Path.Combine(avatarDir, newFileName);
            FileAvatar.SaveAs(savePath);

            // 重新加载教师信息，刷新头像等显示
            LoadTeacherInfo();

            // 直接在当前页面显示成功提示（不再二次重定向导致异常）
            ShowMessage("avatar", "success", "头像上传成功！");
        }
        catch (Exception ex)
        {
            ShowMessage("avatar", "error", "上传失败：" + ex.Message);
        }
    }

    // 修改密码
    protected void BtnChangePassword_Click(object sender, EventArgs e)
    {
        string oldPwd = TxtOldPassword.Text.Trim();
        string newPwd = TxtNewPassword.Text.Trim();
        string confirmPwd = TxtConfirmPassword.Text.Trim();

        // 验证输入
        if (string.IsNullOrEmpty(oldPwd))
        {
            ShowMessage("password", "error", "请输入当前密码");
            return;
        }
        if (string.IsNullOrEmpty(newPwd))
        {
            ShowMessage("password", "error", "请输入新密码");
            return;
        }
        if (newPwd.Length < 6)
        {
            ShowMessage("password", "error", "新密码长度至少6位");
            return;
        }
        if (newPwd != confirmPwd)
        {
            ShowMessage("password", "error", "两次输入的新密码不一致");
            return;
        }

        // 验证当前密码
        string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            string sql = "SELECT Hpwd, Hsalt FROM Teacher WHERE Hid=@Hid";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Hid", myHid);

            try
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                
                if (!reader.Read())
                {
                    ShowMessage("password", "error", "用户不存在");
                    return;
                }

                string currentPwd = reader["Hpwd"].ToString();
                string currentSalt = reader["Hsalt"] != DBNull.Value ? reader["Hsalt"].ToString() : "";
                reader.Close();

                // 验证当前密码（支持新旧密码）
                bool passwordValid = false;
                if (string.IsNullOrEmpty(currentSalt))
                {
                    // 旧密码（明文）
                    passwordValid = (currentPwd == oldPwd);
                }
                else
                {
                    // 新密码（加密）
                    passwordValid = SecurityHelper.VerifyPassword(oldPwd, currentPwd, currentSalt);
                }

                if (!passwordValid)
                {
                    ShowMessage("password", "error", "当前密码错误");
                    return;
                }

                // 生成新的盐值和加密密码
                string newSalt = SecurityHelper.GenerateSalt();
                string hashedPassword = SecurityHelper.HashPassword(newPwd, newSalt);

                // 更新密码
                string updateSql = "UPDATE Teacher SET Hpwd=@NewPwd, Hsalt=@NewSalt WHERE Hid=@Hid";
                SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                updateCmd.Parameters.AddWithValue("@NewPwd", hashedPassword);
                updateCmd.Parameters.AddWithValue("@NewSalt", newSalt);
                updateCmd.Parameters.AddWithValue("@Hid", myHid);
                updateCmd.ExecuteNonQuery();

                // 清空输入框
                TxtOldPassword.Text = "";
                TxtNewPassword.Text = "";
                TxtConfirmPassword.Text = "";

                // 显示成功提示
                ShowMessage("password", "success", "密码修改成功！");
            }
            catch (Exception ex)
            {
                ShowMessage("password", "error", "修改失败：" + ex.Message);
            }
        }
    }

    // 绑定邮箱
    protected void BtnBindEmail_Click(object sender, EventArgs e)
    {
        string email = TxtEmail.Text.Trim();
        // 兼容：有些部署环境里 aspx 控件字段未生成/未同步会导致 CS0103（找不到 TxtEmailCaptcha）
        // 这里通过表单提交值获取，避免对强类型字段的编译期依赖。
        string captcha = GetPostedValueByIdSuffix("TxtEmailCaptcha").Trim();

        // 验证邮箱格式
        if (string.IsNullOrEmpty(email))
        {
            ShowMessage("email", "error", "请输入邮箱地址");
            return;
        }

        // 简单的邮箱格式验证
        if (!email.Contains("@") || !email.Contains("."))
        {
            ShowMessage("email", "error", "邮箱格式不正确");
            return;
        }

        // 验证邮箱验证码
        if (string.IsNullOrEmpty(captcha))
        {
            ShowMessage("email", "error", "请输入邮箱验证码");
            return;
        }

        string sessionCode = Session["EmailVerifyCode"] as string;
        string sessionEmail = Session["EmailVerifyCodeEmail"] as string;
        object sessionExpiry = Session["EmailVerifyCodeTime"];

        if (string.IsNullOrEmpty(sessionCode) || sessionExpiry == null)
        {
            ShowMessage("email", "error", "验证码已过期，请重新发送");
            return;
        }

        // 检查是否过期
        DateTime expiry = (DateTime)sessionExpiry;
        if (DateTime.Now > expiry)
        {
            Session.Remove("EmailVerifyCode");
            Session.Remove("EmailVerifyCodeEmail");
            Session.Remove("EmailVerifyCodeTime");
            ShowMessage("email", "error", "验证码已过期，请重新发送");
            return;
        }

        // 检查验证码是否与当前邮箱匹配
        if (!string.IsNullOrEmpty(sessionEmail) && !email.Equals(sessionEmail, StringComparison.OrdinalIgnoreCase))
        {
            ShowMessage("email", "error", "验证码与当前邮箱不匹配，请重新发送");
            return;
        }

        if (!captcha.Equals(sessionCode, StringComparison.OrdinalIgnoreCase))
        {
            ShowMessage("email", "error", "验证码错误");
            return;
        }

        // 清除验证码
        Session.Remove("EmailVerifyCode");
        Session.Remove("EmailVerifyCodeEmail");
        Session.Remove("EmailVerifyCodeTime");

        // 更新邮箱：依次尝试在 Teacher / Teachers 表中更新，哪个表中有该教师记录就写入哪个
        string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        string[] tableCandidates = { "Teacher", "Teachers" };
        int totalAffected = 0;
        bool updateSuccess = false;
        string successTable = "";

        foreach (string table in tableCandidates)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                try
                {
                    conn.Open();
                    
                    // 先检查记录是否存在
                    string checkSql = "SELECT COUNT(*) FROM " + table + " WHERE Hid=@Hid";
                    SqlCommand checkCmd = new SqlCommand(checkSql, conn);
                    checkCmd.Parameters.AddWithValue("@Hid", myHid);
                    int count = (int)checkCmd.ExecuteScalar();
                    
                    if (count > 0)
                    {
                        // 记录存在，执行更新
                        string sql = "UPDATE " + table + " SET Hemail=@Email WHERE Hid=@Hid";
                        SqlCommand cmd = new SqlCommand(sql, conn);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Hid", myHid);
                        
                        int affected = cmd.ExecuteNonQuery();
                        totalAffected += affected;

                        if (affected > 0)
                        {
                            updateSuccess = true;
                            successTable = table;
                            System.Diagnostics.Debug.WriteLine("Email updated successfully in table: " + table);
                            break;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    // 表不存在 / 字段不存在等，继续尝试下一个候选表
                    System.Diagnostics.Debug.WriteLine("BindEmail update table " + table + " error: " + ex.Message);
                }
                catch (Exception ex)
                {
                    ShowMessage("email", "error", "绑定失败：" + ex.Message);
                    return;
                }
            }
        }

        if (!updateSuccess || totalAffected <= 0)
        {
            ShowMessage("email", "error", "绑定失败：未找到对应的教师记录");
            return;
        }

        // 绑定成功，更新内存中的邮箱值
        myEmail = email;

        // 更新页面显示（不调用 LoadTeacherInfo 避免重复数据库查询）
        LitTeacherEmail.Text = Server.HtmlEncode(email);
        if (LblBoundEmail != null) LblBoundEmail.Text = Server.HtmlEncode(email);
        
        // 切换显示状态：隐藏表单，显示已绑定摘要
        if (PnlEmailForm != null) PnlEmailForm.Visible = false;
        if (PnlEmailSummary != null) PnlEmailSummary.Visible = true;

        // 成功提示
        ShowMessage("email", "success", "邮箱绑定成功！");
        System.Diagnostics.Debug.WriteLine("Email binding completed. Table: " + successTable + ", Email: " + email);
    }


    // “修改邮箱”按钮：切换回绑定窗口
    protected void BtnEditEmail_Click(object sender, EventArgs e)
    {
        // 显示表单，隐藏摘要
        if (PnlEmailSummary != null) PnlEmailSummary.Visible = false;
        if (PnlEmailForm != null) PnlEmailForm.Visible = true;

        // 表单中预填当前邮箱（使用内存中的值，避免重复查询）
        TxtEmail.Text = myEmail;
    }


    // 一键保存：同时处理头像上传和邮箱绑定
    protected void BtnSaveAll_Click(object sender, EventArgs e)
    {
        // 如果选择了头像文件，则尝试上传头像
        if (FileAvatar.HasFile)
        {
            BtnUploadAvatar_Click(sender, e);
        }

        // 如果当前处于“未绑定 / 正在修改”状态，则尝试绑定邮箱
        //（已绑定且不在修改时，PnlEmailForm 通常为不可见，此时不重复绑定）
        if (PnlEmailForm != null && PnlEmailForm.Visible)
        {
            BtnBindEmail_Click(sender, e);
        }
    }

    private void ShowMessage(string target, string type, string message)
    {
        // 为前端 JS 生成安全的字符串
        if (message == null) message = string.Empty;
        string safeMessage = message.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");

        // 直接调用 profile.aspx 中的 showAlert(type, message, containerId)
        string script = string.Format(
            "showAlert('{0}', '{1}', '{2}');",
            type,
            safeMessage,
            target + "Alert"
        );

        // 在页面尾部输出脚本，确保 showAlert 已定义
        ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage_" + target, script, true);
    }

    private string GetPostedValueByIdSuffix(string id)
    {
        if (Request == null || Request.Form == null) return string.Empty;
        // 先尝试直接取（极少数情况下会存在）
        string v = Request.Form[id];
        if (!string.IsNullOrEmpty(v)) return v;

        // 再尝试匹配命名容器 UniqueID（例如：ctl00$Content$TxtEmailCaptcha）
        string suffix = "$" + id;
        string[] keys = Request.Form.AllKeys;
        if (keys == null) return string.Empty;
        for (int i = 0; i < keys.Length; i++)
        {
            string k = keys[i];
            if (string.IsNullOrEmpty(k)) continue;
            if (k.EndsWith(suffix, StringComparison.Ordinal))
            {
                return Request.Form[k] ?? string.Empty;
            }
        }
        return string.Empty;
    }
}


#line default
#line hidden
