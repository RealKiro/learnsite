using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;

namespace LearnSite
{
    public partial class Teacher_courseshow : System.Web.UI.Page
    {
        // 控件声明
        protected global::System.Web.UI.WebControls.Label LabelCtitle;
        protected global::System.Web.UI.WebControls.Image Imagebanner;
        protected global::System.Web.UI.WebControls.Label LabelCdate;
        protected global::System.Web.UI.WebControls.Label LabelCclass;
        protected global::System.Web.UI.WebControls.Label LabelCobj;
        protected global::System.Web.UI.WebControls.Label LabelCterm;
        protected global::System.Web.UI.WebControls.Label LabelCks;
        protected global::System.Web.UI.WebControls.ImageButton BtnEdit;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnReturn;
        protected global::System.Web.UI.WebControls.GridView GVlistmenu;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl Ccontent;
        
        // 工具栏按钮
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnAdd;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnAddTopic;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnAddSurvey;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnAddTxtForm;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnProgram;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnPython;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtnConsole;
        protected global::System.Web.UI.WebControls.LinkButton LinkButtonGraph;
        protected global::System.Web.UI.WebControls.LinkButton LinkButtonPixel;
        protected global::System.Web.UI.WebControls.LinkButton LinkButtonHtml;
        protected global::System.Web.UI.WebControls.LinkButton LinkButtonKm;
        protected global::System.Web.UI.WebControls.LinkButton LinkButtonExcel;
        protected global::System.Web.UI.WebControls.LinkButton LinkButtonware;
        
        private int courseId = 0;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 获取课程ID
                string cid = Request.QueryString["cid"];
                if (string.IsNullOrEmpty(cid) || !int.TryParse(cid, out courseId))
                {
                    ShowError("无效的课程ID参数");
                    return;
                }
                
                LoadCourseInfo();
                LoadCourseContent();
                LoadListMenu();
            }
        }
        
        // 加载课程基本信息
        private void LoadCourseInfo()
        {
            string connectionString = "";
            try
            {
                connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch (Exception ex)
            {
                ShowError("数据库配置错误: " + ex.Message);
                return;
            }
            
            SqlConnection conn = null;
            SqlCommand cmd = null;
            SqlDataReader reader = null;
            
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                
                string sql = @"
                    SELECT C.Cid, C.Ctitle, C.Cdate, C.Cclass, C.Cobj, C.Cterm, C.Cks, C.Cbanner, C.Chid
                    FROM Courses C
                    WHERE C.Cid = @Cid AND (C.Cdelete = 0 OR C.Cdelete IS NULL)
                ";
                
                cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Cid", courseId);
                
                reader = cmd.ExecuteReader();
                
                if (reader.Read())
                {
                    // 填充课程标题
                    if (LabelCtitle != null)
                    {
                        LabelCtitle.Text = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "未命名课程";
                    }
                    
                    // 填充日期
                    if (LabelCdate != null)
                    {
                        if (reader["Cdate"] != DBNull.Value)
                        {
                            DateTime date;
                            if (DateTime.TryParse(reader["Cdate"].ToString(), out date))
                            {
                                LabelCdate.Text = date.ToString("yyyy-MM-dd");
                            }
                            else
                            {
                                LabelCdate.Text = reader["Cdate"].ToString();
                            }
                        }
                        else
                        {
                            LabelCdate.Text = "";
                        }
                    }
                    
                    // 填充类型
                    if (LabelCclass != null)
                    {
                        LabelCclass.Text = reader["Cclass"] != DBNull.Value ? reader["Cclass"].ToString() : "";
                    }
                    
                    // 填充年级
                    if (LabelCobj != null)
                    {
                        LabelCobj.Text = reader["Cobj"] != DBNull.Value ? reader["Cobj"].ToString() : "";
                    }
                    
                    // 填充学期
                    if (LabelCterm != null)
                    {
                        LabelCterm.Text = reader["Cterm"] != DBNull.Value ? reader["Cterm"].ToString() : "";
                    }
                    
                    // 填充课次
                    if (LabelCks != null)
                    {
                        LabelCks.Text = reader["Cks"] != DBNull.Value ? reader["Cks"].ToString() : "";
                    }
                    
                    // 填充横幅图片
                    if (Imagebanner != null)
                    {
                        if (reader["Cbanner"] != DBNull.Value && !string.IsNullOrEmpty(reader["Cbanner"].ToString()))
                        {
                            string bannerPath = reader["Cbanner"].ToString();
                            if (!bannerPath.StartsWith("http") && !bannerPath.StartsWith("/"))
                            {
                                bannerPath = "~/" + bannerPath;
                            }
                            Imagebanner.ImageUrl = bannerPath;
                            Imagebanner.Visible = true;
                        }
                        else
                        {
                            Imagebanner.Visible = false;
                        }
                    }
                    
                    // 设置页面标题
                    Page.Title = LabelCtitle != null ? LabelCtitle.Text : "课程详情";
                }
                else
                {
                    ShowError("未找到课程记录");
                }
            }
            catch (Exception ex)
            {
                ShowError("加载课程信息时出错: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("LoadCourseInfo Error: " + ex.ToString());
            }
            finally
            {
                if (reader != null && !reader.IsClosed) reader.Close();
                if (cmd != null) cmd.Dispose();
                if (conn != null && conn.State == ConnectionState.Open) conn.Close();
            }
        }
        
        // 加载课程内容
        private void LoadCourseContent()
        {
            string connectionString = "";
            try
            {
                connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch (Exception ex)
            {
                if (Ccontent != null)
                {
                    Ccontent.InnerHtml = "<div style='color: red;'>数据库配置错误: " + Server.HtmlEncode(ex.Message) + "</div>";
                }
                return;
            }
            
            SqlConnection conn = null;
            SqlCommand cmd = null;
            SqlDataReader reader = null;
            
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                
                string sql = @"
                    SELECT Ccontent 
                    FROM Courses 
                    WHERE Cid = @Cid AND (Cdelete = 0 OR Cdelete IS NULL)
                ";
                
                cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Cid", courseId);
                
                reader = cmd.ExecuteReader();
                
                if (reader.Read() && Ccontent != null)
                {
                    if (reader["Ccontent"] != DBNull.Value && !string.IsNullOrEmpty(reader["Ccontent"].ToString()))
                    {
                        Ccontent.InnerHtml = reader["Ccontent"].ToString();
                    }
                    else
                    {
                        Ccontent.InnerHtml = "<div style='text-align: center; padding: 40px; color: #999;'>暂无课程内容</div>";
                    }
                }
            }
            catch (Exception ex)
            {
                if (Ccontent != null)
                {
                    Ccontent.InnerHtml = "<div style='color: red;'>加载课程内容时出错: " + Server.HtmlEncode(ex.Message) + "</div>";
                }
                System.Diagnostics.Debug.WriteLine("LoadCourseContent Error: " + ex.ToString());
            }
            finally
            {
                if (reader != null && !reader.IsClosed) reader.Close();
                if (cmd != null) cmd.Dispose();
                if (conn != null && conn.State == ConnectionState.Open) conn.Close();
            }
        }
        
        // 加载导航栏目列表
        private void LoadListMenu()
        {
            string connectionString = "";
            try
            {
                connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch (Exception ex)
            {
                if (GVlistmenu != null)
                {
                    GVlistmenu.Visible = false;
                }
                System.Diagnostics.Debug.WriteLine("LoadListMenu ConnectionString Error: " + ex.Message);
                return;
            }
            
            SqlConnection conn = null;
            SqlCommand cmd = null;
            SqlDataAdapter adapter = null;
            DataTable dt = null;
            
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                
                string sql = @"
                    SELECT Lid, Lxid, Ltype, Ltitle, Lsort, lshow
                    FROM Listmenu 
                    WHERE Lcid = @Lcid
                    ORDER BY Lsort
                ";
                
                cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Lcid", courseId);
                
                adapter = new SqlDataAdapter(cmd);
                dt = new DataTable();
                adapter.Fill(dt);
                
                if (GVlistmenu != null)
                {
                    GVlistmenu.DataSource = dt;
                    GVlistmenu.DataBind();
                }
            }
            catch (Exception ex)
            {
                if (GVlistmenu != null)
                {
                    GVlistmenu.Visible = false;
                }
                System.Diagnostics.Debug.WriteLine("LoadListMenu Error: " + ex.ToString());
            }
            finally
            {
                if (adapter != null) adapter.Dispose();
                if (cmd != null) cmd.Dispose();
                if (conn != null && conn.State == ConnectionState.Open) conn.Close();
            }
        }
        
        // GridView 行数据绑定事件
        protected void GVlistmenu_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView rowView = (DataRowView)e.Row.DataItem;
                
                // 设置类型图标和文本
                Label Label4 = (Label)e.Row.FindControl("Label4");
                Image Image4 = (Image)e.Row.FindControl("Image4");
                Label LabelLtype = (Label)e.Row.FindControl("LabelLtype");
                
                if (LabelLtype != null && Label4 != null)
                {
                    string ltype = LabelLtype.Text;
                    string typeName = GetTypeName(ltype);
                    Label4.Text = typeName;
                    
                    // 设置图标
                    if (Image4 != null)
                    {
                        Image4.ImageUrl = GetTypeIcon(ltype);
                    }
                }
                
                // 设置导航链接
                HyperLink HlLtitle = (HyperLink)e.Row.FindControl("HlLtitle");
                Label LabelLid = (Label)e.Row.FindControl("LabelLid");
                Label LabelLxid = (Label)e.Row.FindControl("LabelLxid");
                
                if (HlLtitle != null && LabelLid != null && LabelLxid != null)
                {
                    string lid = LabelLid.Text;
                    string lxid = LabelLxid.Text;
                    string url = GetNavigateUrl(LabelLtype.Text, lid, lxid);
                    HlLtitle.NavigateUrl = url;
                }
                
                // 设置发布状态显示
                LinkButton LinkBtnShow = (LinkButton)e.Row.FindControl("LinkBtnShow");
                if (LinkBtnShow != null && rowView["lshow"] != DBNull.Value)
                {
                    object lshow = rowView["lshow"];
                    if (lshow.ToString() == "True" || lshow.ToString() == "1" || lshow.ToString() == "true")
                    {
                        LinkBtnShow.Text = "显示";
                        LinkBtnShow.CssClass = "link-show";
                    }
                    else
                    {
                        LinkBtnShow.Text = "隐藏";
                        LinkBtnShow.CssClass = "link-hide";
                    }
                }
            }
        }
        
        // GridView 行命令事件
        protected void GVlistmenu_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Top" || e.CommandName == "Bottom")
            {
                // 上移/下移逻辑
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                // TODO: 实现排序逻辑
                LoadListMenu();
            }
            else if (e.CommandName == "P")
            {
                // 切换发布状态
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = GVlistmenu.Rows[rowIndex];
                Label LabelLid = (Label)row.FindControl("LabelLid");
                
                if (LabelLid != null)
                {
                    int lid = Convert.ToInt32(LabelLid.Text);
                    TogglePublishStatus(lid);
                    LoadListMenu();
                }
            }
            else if (e.CommandName == "D")
            {
                // 删除逻辑
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = GVlistmenu.Rows[rowIndex];
                Label LabelLid = (Label)row.FindControl("LabelLid");
                
                if (LabelLid != null)
                {
                    int lid = Convert.ToInt32(LabelLid.Text);
                    DeleteListMenu(lid);
                    LoadListMenu();
                }
            }
        }
        
        // 获取类型名称
        private string GetTypeName(string ltype)
        {
            switch (ltype)
            {
                case "1": return "活动";
                case "2": return "主题";
                case "3": return "练习";
                case "4": return "积木编程";
                case "5": return "Python";
                case "6": return "测评";
                case "7": return "流程图";
                case "8": return "应用";
                case "9": return "Html";
                case "10": return "导图";
                case "11": return "表格";
                case "12": return "课件";
                case "13": return "讨论";
                case "14": return "调查";
                case "15": return "填表";
                default: return "未知";
            }
        }
        
        // 获取类型图标
        private string GetTypeIcon(string ltype)
        {
            // 返回默认图标路径，可以根据类型返回不同图标
            return "~/images/new_none.gif";
        }
        
        // 获取导航URL
        private string GetNavigateUrl(string ltype, string lid, string lxid)
        {
            string baseUrl = "";
            switch (ltype)
            {
                case "1": baseUrl = "missionshow.aspx"; break;
                case "2": baseUrl = "topicshow.aspx"; break;
                case "3": baseUrl = "missionshow.aspx"; break;
                case "4": baseUrl = "programshow.aspx"; break;
                case "5": baseUrl = "pythonshow.aspx"; break;
                case "6": baseUrl = "consoleshow.aspx"; break;
                case "7": baseUrl = "graphshow.aspx"; break;
                case "8": baseUrl = "pixelshow.aspx"; break;
                case "9": baseUrl = "htmlshow.aspx"; break;
                case "10": baseUrl = "kitymindshow.aspx"; break;
                case "11": baseUrl = "excelshow.aspx"; break;
                case "12": baseUrl = "wareshow.aspx"; break;
                case "13": baseUrl = "topicshow.aspx"; break;
                case "14": baseUrl = "missionshow.aspx"; break;
                case "15": baseUrl = "txtformshow.aspx"; break;
                default: baseUrl = "missionshow.aspx"; break;
            }
            
            return string.Format("{0}?lid={1}&mid={2}&mcid={3}", baseUrl, lid, lxid, courseId);
        }
        
        // 切换发布状态
        private void TogglePublishStatus(int lid)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string sql = @"
                    UPDATE Listmenu 
                    SET lshow = CASE WHEN lshow = 'True' OR lshow = 1 OR lshow = '1' THEN 'False' ELSE 'True' END
                    WHERE Lid = @Lid
                ";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        
        // 删除导航栏目
        private void DeleteListMenu(int lid)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string sql = "DELETE FROM Listmenu WHERE Lid = @Lid";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        
        // 编辑按钮点击事件
        protected void BtnEdit_Click(object sender, ImageClickEventArgs e)
        {
            Response.Redirect("courseedit.aspx?cid=" + courseId);
        }
        
        // 返回按钮点击事件
        protected void LinkBtnReturn_Click(object sender, EventArgs e)
        {
            Response.Redirect("course.aspx");
        }
        
        // 添加活动
        protected void LinkBtnAdd_Click(object sender, EventArgs e)
        {
            Response.Redirect("missionadd.aspx?cid=" + courseId);
        }
        
        // 添加讨论
        protected void LinkBtnAddTopic_Click(object sender, EventArgs e)
        {
            Response.Redirect("topicadd.aspx?cid=" + courseId);
        }
        
        // 添加调查
        protected void LinkBtnAddSurvey_Click(object sender, EventArgs e)
        {
            Response.Redirect("missionadd.aspx?cid=" + courseId + "&type=survey");
        }
        
        // 添加填表
        protected void LinkBtnAddTxtForm_Click(object sender, EventArgs e)
        {
            Response.Redirect("txtformadd.aspx?cid=" + courseId);
        }
        
        // 添加积木编程
        protected void LinkBtnProgram_Click(object sender, EventArgs e)
        {
            Response.Redirect("programadd.aspx?cid=" + courseId);
        }
        
        // 添加Python
        protected void LinkBtnPython_Click(object sender, EventArgs e)
        {
            Response.Redirect("pythonadd.aspx?cid=" + courseId);
        }
        
        // 添加测评
        protected void LinkBtnConsole_Click(object sender, EventArgs e)
        {
            Response.Redirect("consoleadd.aspx?cid=" + courseId);
        }
        
        // 添加流程图
        protected void LinkBtnGraph_Click(object sender, EventArgs e)
        {
            Response.Redirect("graphadd.aspx?cid=" + courseId);
        }
        
        // 添加应用
        protected void LinkButtonPixel_Click(object sender, EventArgs e)
        {
            Response.Redirect("pixeladd.aspx?cid=" + courseId);
        }
        
        // 添加Html
        protected void LinkButtonHtml_Click(object sender, EventArgs e)
        {
            Response.Redirect("htmladd.aspx?cid=" + courseId);
        }
        
        // 添加导图
        protected void LinkButtonKm_Click(object sender, EventArgs e)
        {
            Response.Redirect("kitymindadd.aspx?cid=" + courseId);
        }
        
        // 添加表格
        protected void LinkButtonExcel_Click(object sender, EventArgs e)
        {
            Response.Redirect("exceladd.aspx?cid=" + courseId);
        }
        
        // 添加课件
        protected void LinkButtonware_Click(object sender, EventArgs e)
        {
            Response.Redirect("wareadd.aspx?cid=" + courseId);
        }
        
        // 显示错误信息
        private void ShowError(string message)
        {
            if (LabelCtitle != null)
            {
                LabelCtitle.Text = "加载错误";
            }
            
            if (Ccontent != null)
            {
                Ccontent.InnerHtml = string.Format(
                    @"<div style='padding: 20px; background: #fee2e2; border: 1px solid #fca5a5; border-radius: 8px; color: #991b1b;'>
                        <h3>⚠️ 错误</h3>
                        <p>{0}</p>
                    </div>",
                    Server.HtmlEncode(message)
                );
            }
        }
    }
}

