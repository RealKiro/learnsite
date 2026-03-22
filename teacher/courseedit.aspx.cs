using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

namespace LearnSite
{
    public partial class Teacher_courseedit : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox Texttitle;
        protected global::System.Web.UI.WebControls.DropDownList DDLclass;
        protected global::System.Web.UI.WebControls.DropDownList DDLcobj;
        protected global::System.Web.UI.WebControls.DropDownList DDLCterm;
        protected global::System.Web.UI.WebControls.DropDownList DDLCks;
        protected global::System.Web.UI.WebControls.CheckBox CheckPublish;
        protected global::System.Web.UI.WebControls.HyperLink HLbanner;
        protected global::System.Web.UI.WebControls.HyperLink HLbannerView;
        protected global::System.Web.UI.WebControls.FileUpload Fupload;
        protected global::System.Web.UI.WebControls.TextBox mcontent;
        protected global::System.Web.UI.WebControls.Label Labelmsg;
        protected global::System.Web.UI.WebControls.Button Btnedit;
        protected global::System.Web.UI.WebControls.Button Btnreturn;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl BannerPreview;
        protected global::System.Web.UI.HtmlControls.HtmlImage BannerPreviewImg;
        protected global::System.Web.UI.WebControls.HiddenField HdBannerPath;

        private int courseId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string cid = Request.QueryString["cid"];
                if (!string.IsNullOrEmpty(cid) && int.TryParse(cid, out courseId))
                {
                    LoadCourseData();
                }
                else
                {
                    Labelmsg.Text = "<span style='color: red;'>无效的课程ID</span>";
                }
            }
        }

        private void LoadCourseData()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string sql = @"
                    SELECT Cid, Ctitle, Cclass, Cobj, Cterm, Cks, Cbanner, Ccontent, Cpublish
                    FROM Courses
                    WHERE Cid = @Cid AND (Cdelete = 0 OR Cdelete IS NULL)
                ";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Cid", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (Texttitle != null)
                                Texttitle.Text = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "";
                            
                            if (DDLclass != null && reader["Cclass"] != DBNull.Value)
                            {
                                string cclass = reader["Cclass"].ToString();
                                if (DDLclass.Items.FindByValue(cclass) != null)
                                    DDLclass.SelectedValue = cclass;
                            }
                            
                            if (DDLcobj != null && reader["Cobj"] != DBNull.Value)
                            {
                                string cobj = reader["Cobj"].ToString();
                                if (DDLcobj.Items.FindByValue(cobj) != null)
                                    DDLcobj.SelectedValue = cobj;
                            }
                            
                            if (DDLCterm != null && reader["Cterm"] != DBNull.Value)
                            {
                                string cterm = reader["Cterm"].ToString();
                                if (DDLCterm.Items.FindByValue(cterm) != null)
                                    DDLCterm.SelectedValue = cterm;
                            }
                            
                            if (DDLCks != null && reader["Cks"] != DBNull.Value)
                            {
                                string cks = reader["Cks"].ToString();
                                if (DDLCks.Items.FindByValue(cks) != null)
                                    DDLCks.SelectedValue = cks;
                            }
                            
                            if (CheckPublish != null && reader["Cpublish"] != DBNull.Value)
                            {
                                CheckPublish.Checked = Convert.ToBoolean(reader["Cpublish"]);
                            }
                            
                            if (mcontent != null && reader["Ccontent"] != DBNull.Value)
                                mcontent.Text = reader["Ccontent"].ToString();
                            
                            // 设置横幅链接和预览
                            string bannerPath = reader["Cbanner"] != DBNull.Value ? reader["Cbanner"].ToString() : "";
                            if (!string.IsNullOrEmpty(bannerPath))
                            {
                                // 设置隐藏字段
                                if (HdBannerPath != null)
                                    HdBannerPath.Value = bannerPath;
                                
                                // 处理路径
                                string bannerUrl = bannerPath;
                                if (!bannerUrl.StartsWith("http") && !bannerUrl.StartsWith("/"))
                                    bannerUrl = "~/" + bannerUrl;
                                bannerUrl = ResolveUrl(bannerUrl);
                                
                                // 设置查看链接
                                if (HLbanner != null)
                                {
                                    HLbanner.NavigateUrl = bannerUrl;
                                    HLbanner.Text = "查看背景图";
                                }
                                if (HLbannerView != null)
                                {
                                    HLbannerView.NavigateUrl = bannerUrl;
                                }
                                
                                // 显示预览
                                if (BannerPreview != null)
                                {
                                    BannerPreview.Attributes["class"] = "ce-banner-preview has-image";
                                    BannerPreview.Style["display"] = "block";
                                }
                                if (BannerPreviewImg != null)
                                {
                                    BannerPreviewImg.Src = bannerUrl;
                                    BannerPreviewImg.Alt = "背景图预览";
                                }
                            }
                            else
                            {
                                // 没有背景图，隐藏预览
                                if (BannerPreview != null)
                                {
                                    BannerPreview.Attributes["class"] = "ce-banner-preview";
                                    BannerPreview.Style["display"] = "none";
                                }
                                if (HLbanner != null)
                                    HLbanner.Text = "学案背景";
                            }
                        }
                    }
                }
            }
        }

        protected void Btnedit_Click(object sender, EventArgs e)
        {
            string cid = Request.QueryString["cid"];
            if (string.IsNullOrEmpty(cid) || !int.TryParse(cid, out courseId))
            {
                Labelmsg.Text = "<span style='color: red;'>无效的课程ID</span>";
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            
            try
            {
                // 处理背景图片上传或删除
                string bannerPath = "";
                
                // 检查是否要删除背景图
                bool shouldDeleteBanner = false;
                string deleteBannerFlag = Request.Form["DeleteBanner"];
                if (!string.IsNullOrEmpty(deleteBannerFlag) && deleteBannerFlag == "1")
                {
                    shouldDeleteBanner = true;
                }
                else if (HdBannerPath != null && string.IsNullOrEmpty(HdBannerPath.Value.Trim()))
                {
                    // 如果隐藏字段被清空，也视为删除
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        string oldBannerSql = "SELECT Cbanner FROM Courses WHERE Cid = @Cid";
                        using (SqlCommand oldCmd = new SqlCommand(oldBannerSql, conn))
                        {
                            oldCmd.Parameters.AddWithValue("@Cid", courseId);
                            object oldBanner = oldCmd.ExecuteScalar();
                            if (oldBanner != null && oldBanner != DBNull.Value && !string.IsNullOrEmpty(oldBanner.ToString()))
                            {
                                shouldDeleteBanner = true;
                            }
                        }
                    }
                }
                
                if (shouldDeleteBanner)
                {
                    // 删除背景图文件
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        string oldBannerSql = "SELECT Cbanner FROM Courses WHERE Cid = @Cid";
                        using (SqlCommand oldCmd = new SqlCommand(oldBannerSql, conn))
                        {
                            oldCmd.Parameters.AddWithValue("@Cid", courseId);
                            object oldBanner = oldCmd.ExecuteScalar();
                            if (oldBanner != null && oldBanner != DBNull.Value && !string.IsNullOrEmpty(oldBanner.ToString()))
                            {
                                string oldPath = Server.MapPath("~/" + oldBanner.ToString());
                                if (File.Exists(oldPath))
                                {
                                    try { File.Delete(oldPath); } catch { }
                                }
                            }
                        }
                    }
                    bannerPath = ""; // 设置为空，表示删除
                }
                else if (Fupload != null && Fupload.HasFile)
                {
                    string fileName = Fupload.FileName;
                    string ext = Path.GetExtension(fileName).ToLower();
                    
                    // 验证文件类型
                    string[] allowedExts = { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };
                    if (Array.IndexOf(allowedExts, ext) == -1)
                    {
                        Labelmsg.Text = "<span style='color: red;'>仅支持 JPG、PNG、GIF、WEBP、BMP 格式的图片</span>";
                        return;
                    }
                    
                    // 验证文件大小（最大 5MB）
                    if (Fupload.PostedFile.ContentLength > 5 * 1024 * 1024)
                    {
                        Labelmsg.Text = "<span style='color: red;'>图片大小不能超过 5MB</span>";
                        return;
                    }
                    
                    // 创建上传目录
                    string uploadDir = Server.MapPath("~/images/coursebanner/");
                    if (!Directory.Exists(uploadDir))
                    {
                        Directory.CreateDirectory(uploadDir);
                    }
                    
                    // 生成唯一文件名
                    string newFileName = "banner_" + courseId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ext;
                    string savePath = Path.Combine(uploadDir, newFileName);
                    
                    // 保存文件
                    Fupload.SaveAs(savePath);
                    
                    // 保存相对路径到数据库
                    bannerPath = "images/coursebanner/" + newFileName;
                    
                    // 删除旧的背景图片（如果存在）
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        string oldBannerSql = "SELECT Cbanner FROM Courses WHERE Cid = @Cid";
                        using (SqlCommand oldCmd = new SqlCommand(oldBannerSql, conn))
                        {
                            oldCmd.Parameters.AddWithValue("@Cid", courseId);
                            object oldBanner = oldCmd.ExecuteScalar();
                            if (oldBanner != null && oldBanner != DBNull.Value && !string.IsNullOrEmpty(oldBanner.ToString()))
                            {
                                string oldPath = Server.MapPath("~/" + oldBanner.ToString());
                                if (File.Exists(oldPath))
                                {
                                    try { File.Delete(oldPath); } catch { }
                                }
                            }
                        }
                    }
                }
                else
                {
                    // 如果没有上传新文件，保持原有路径
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        string oldBannerSql = "SELECT Cbanner FROM Courses WHERE Cid = @Cid";
                        using (SqlCommand oldCmd = new SqlCommand(oldBannerSql, conn))
                        {
                            oldCmd.Parameters.AddWithValue("@Cid", courseId);
                            object oldBanner = oldCmd.ExecuteScalar();
                            if (oldBanner != null && oldBanner != DBNull.Value)
                                bannerPath = oldBanner.ToString();
                        }
                    }
                }
                
                // 更新数据库
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string sql = @"
                        UPDATE Courses 
                        SET Ctitle = @Ctitle, 
                            Cclass = @Cclass, 
                            Cobj = @Cobj, 
                            Cterm = @Cterm, 
                            Cks = @Cks, 
                            Ccontent = @Ccontent, 
                            Cpublish = @Cpublish,
                            Cbanner = @Cbanner
                        WHERE Cid = @Cid
                    ";
                    
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Cid", courseId);
                        cmd.Parameters.AddWithValue("@Ctitle", Texttitle != null ? Texttitle.Text : "");
                        cmd.Parameters.AddWithValue("@Cclass", DDLclass != null ? DDLclass.SelectedValue : "");
                        cmd.Parameters.AddWithValue("@Cobj", DDLcobj != null ? DDLcobj.SelectedValue : "");
                        cmd.Parameters.AddWithValue("@Cterm", DDLCterm != null ? DDLCterm.SelectedValue : "");
                        cmd.Parameters.AddWithValue("@Cks", DDLCks != null ? DDLCks.SelectedValue : "");
                        cmd.Parameters.AddWithValue("@Ccontent", mcontent != null ? mcontent.Text : "");
                        cmd.Parameters.AddWithValue("@Cpublish", CheckPublish != null ? CheckPublish.Checked : true);
                        cmd.Parameters.AddWithValue("@Cbanner", string.IsNullOrEmpty(bannerPath) ? (object)DBNull.Value : bannerPath);
                        
                        cmd.ExecuteNonQuery();
                    }
                }
                
                // 如果删除了背景图，重新加载数据以更新预览
                if (shouldDeleteBanner)
                {
                    LoadCourseData();
                    Labelmsg.Text = "<span style='color: green;'>✓ 背景图已删除，学案保存成功！</span>";
                }
                else
                {
                    Labelmsg.Text = "<span style='color: green;'>✓ 学案保存成功！</span>";
                }
            }
            catch (Exception ex)
            {
                Labelmsg.Text = "<span style='color: red;'>保存失败: " + Server.HtmlEncode(ex.Message) + "</span>";
            }
        }

        protected void Btnreturn_Click(object sender, EventArgs e)
        {
            Response.Redirect("course.aspx");
        }
    }
}

