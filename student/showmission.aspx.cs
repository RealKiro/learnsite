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
    public partial class Student_showmission_new : System.Web.UI.Page
    {
        // 控件引用
        private HtmlGenericControl _mcontent;
        
        // 递归查找控件
        private Control FindControlRecursive(Control root, string id)
        {
            if (root == null) return null;
            
            if (root.ID == id)
                return root;
            
            foreach (Control child in root.Controls)
            {
                Control found = FindControlRecursive(child, id);
                if (found != null)
                    return found;
            }
            
            return null;
        }
        
        // 初始化控件引用
        private void InitializeControls()
        {
            _mcontent = FindControlRecursive(this, "Mcontent") as HtmlGenericControl;
        }
        
        protected void Page_Load(object sender, EventArgs e)
    {
        // 初始化控件引用
        InitializeControls();
        
        if (!IsPostBack)
        {
            try
            {
                // 加载任务内容
                LoadMissionContent();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Page_Load Error: " + ex.ToString());
            }
        }
        }
        
        // 加载任务内容
        private void LoadMissionContent()
    {
        string lid = Request.QueryString["lid"];
        string mid = Request.QueryString["mid"];
        string mcid = Request.QueryString["mcid"];
        
        if (string.IsNullOrEmpty(lid))
        {
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>未提供任务ID参数</div>";
            return;
        }
        
        int listId;
        if (!int.TryParse(lid, out listId))
        {
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>无效的任务ID</div>";
            return;
        }
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch (Exception ex)
        {
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: red; padding: 20px;'>数据库配置错误: " + Server.HtmlEncode(ex.Message) + "</div>";
            return;
        }
        
        SqlConnection conn = null;
        SqlCommand cmd = null;
        SqlDataReader reader = null;
        
        try
        {
            conn = new SqlConnection(connectionString);
            conn.Open();
            
            // 查询任务信息
            string sql = @"
                SELECT L.Lid, L.Ltitle, L.Lxid, L.Ltype, L.Lcid,
                       M.Mid, M.Mtitle, M.Mcontent, M.Mupload, M.Mgroup, M.Mfiletype, M.Msort
                FROM Listmenu L
                LEFT JOIN Mission M ON L.Lxid = M.Mid
                WHERE L.Lid = @Lid
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lid", listId);
            
            reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                // 判断任务类型，如果是"讨论"，直接跳转到专用讨论页面
                string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString() : string.Empty;
                string courseIdFromDb = reader["Lcid"] != DBNull.Value ? reader["Lcid"].ToString() : string.Empty;

                // 兼容数值型(13)和中文型(讨论)两种写法
                if (ltype == "13" || ltype == "讨论")
                {
                    // 优先使用数据库中的课程ID，其次使用查询字符串中的 mcid
                    string mcidParam = !string.IsNullOrEmpty(courseIdFromDb)
                        ? courseIdFromDb
                        : (Request.QueryString["mcid"] ?? string.Empty);

                    // 构造跳转到学生讨论页面的地址
                    string redirectUrl;
                    if (!string.IsNullOrEmpty(mcidParam))
                    {
                        redirectUrl = string.Format("~/student/topicdiscuss.aspx?lid={0}&cid={1}", listId, mcidParam);
                    }
                    else
                    {
                        redirectUrl = string.Format("~/student/topicdiscuss.aspx?lid={0}", listId);
                    }

                    // 使用 Redirect 并立即结束当前请求
                    Response.Redirect(redirectUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                // 设置任务标题
                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "未命名任务";
                if (LabelMtitle != null)
                    LabelMtitle.Text = ltitle;
                
                // 设置隐藏字段
                if (LabelLid != null)
                    LabelLid.Text = listId.ToString();
                
                if (LabelMid != null && reader["Mid"] != DBNull.Value)
                    LabelMid.Text = reader["Mid"].ToString();
                
                if (LabelMcid != null && reader["Lcid"] != DBNull.Value)
                    LabelMcid.Text = reader["Lcid"].ToString();
                
                if (LabelMsort != null && reader["Msort"] != DBNull.Value)
                    LabelMsort.Text = reader["Msort"].ToString();
                
                // 设置复选框
                if (CkMupload != null && reader["Mupload"] != DBNull.Value)
                    CkMupload.Checked = Convert.ToBoolean(reader["Mupload"]);
                
                if (CkMgroup != null && reader["Mgroup"] != DBNull.Value)
                    CkMgroup.Checked = Convert.ToBoolean(reader["Mgroup"]);
                
                // 设置文件类型
                if (LabelMfiletype != null && reader["Mfiletype"] != DBNull.Value)
                    LabelMfiletype.Text = reader["Mfiletype"].ToString();
                
                // 加载任务内容
                if (_mcontent != null)
                {
                    string content = reader["Mcontent"] != DBNull.Value ? reader["Mcontent"].ToString() : "";
                    
                    if (string.IsNullOrEmpty(content))
                    {
                        _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>暂无任务内容</div>";
                    }
                    else
                    {
                        _mcontent.InnerHtml = content;
                    }
                }
                
                // 设置页面标题
                Page.Title = ltitle + " - 任务详情";
                
                // 加载作品信息
                LoadWorkInfo();
                
                // 加载小组作品信息
                if (CkMgroup != null && CkMgroup.Checked)
                {
                    LoadGroupWorkInfo();
                }
            }
            else
            {
                if (_mcontent != null)
                    _mcontent.InnerHtml = "<div style='color: #999; text-align: center; padding: 40px;'>未找到任务记录</div>";
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadMissionContent Error: " + ex.ToString());
            if (_mcontent != null)
                _mcontent.InnerHtml = "<div style='color: red; padding: 20px;'>加载任务内容时出错: " + Server.HtmlEncode(ex.Message) + "</div>";
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
        }
        
        // 加载作品信息
        private void LoadWorkInfo()
    {
        if (LabelLid == null || string.IsNullOrEmpty(LabelLid.Text))
            return;
        
        int lid;
        if (!int.TryParse(LabelLid.Text, out lid))
            return;
        
        // 获取学生学号
        string snum = "";
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) 
                { 
                    try { cookieVal = System.Web.HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } 
                    catch { } 
                }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel", 
                        System.Reflection.BindingFlags.Public | 
                        System.Reflection.BindingFlags.NonPublic | 
                        System.Reflection.BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    
                    System.Reflection.PropertyInfo pn = ct.GetProperty("Snum");
                    if (pn != null)
                    {
                        object v = pn.GetValue(m, null);
                        if (v != null) snum = v.ToString();
                    }
                }
            }
        }
        catch { }
        
        if (string.IsNullOrEmpty(snum))
            return;
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch
        {
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
                SELECT TOP 1 Wurl, Wtype
                FROM Work
                WHERE Wlid = @Lid AND Wnum = @Snum
                ORDER BY Wid DESC
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lid", lid);
            cmd.Parameters.AddWithValue("@Snum", snum);
            
            reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                string wurl = reader["Wurl"] != DBNull.Value ? reader["Wurl"].ToString() : "";
                string wtype = reader["Wtype"] != DBNull.Value ? reader["Wtype"].ToString() : "";
                
                if (!string.IsNullOrEmpty(wurl))
                {
                    if (upFileUrl != null)
                    {
                        upFileUrl.NavigateUrl = wurl;
                        upFileUrl.Text = "查看已提交作品";
                        upFileUrl.Visible = true;
                    }
                    
                    if (upFileType != null && !string.IsNullOrEmpty(wtype))
                    {
                        upFileType.ImageUrl = "~/images/" + wtype.ToLower() + ".gif";
                        upFileType.Visible = true;
                    }
                }
            }
        }
        catch { }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
        }
        
        // 加载小组作品信息
        private void LoadGroupWorkInfo()
    {
        if (LabelLid == null || string.IsNullOrEmpty(LabelLid.Text))
            return;
        
        int lid;
        if (!int.TryParse(LabelLid.Text, out lid))
            return;
        
        string connectionString = "";
        try
        {
            connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch
        {
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
                SELECT W.Wid, W.Wurl, W.Wtype, S.Sname, W.Wlscore
                FROM Work W
                LEFT JOIN Students S ON W.Wnum = S.Snum
                WHERE W.Wlid = @Lid AND W.Wgroup = 1
                ORDER BY W.Wid DESC
            ";
            
            cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@Lid", lid);
            
            reader = cmd.ExecuteReader();
            
            DataTable dt = new DataTable();
            dt.Columns.Add("wid");
            dt.Columns.Add("Sname");
            dt.Columns.Add("Wurl");
            dt.Columns.Add("Wlscore");
            
            while (reader.Read())
            {
                DataRow row = dt.NewRow();
                row["wid"] = reader["Wid"] != DBNull.Value ? reader["Wid"].ToString() : "";
                row["Sname"] = reader["Sname"] != DBNull.Value ? reader["Sname"].ToString() : "未知";
                row["Wurl"] = reader["Wurl"] != DBNull.Value ? reader["Wurl"].ToString() : "";
                row["Wlscore"] = reader["Wlscore"] != DBNull.Value ? reader["Wlscore"].ToString() : "";
                dt.Rows.Add(row);
            }
            
            if (GVgwork != null)
            {
                GVgwork.DataSource = dt;
                GVgwork.DataBind();
            }
        }
        catch { }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
        }
        
        // GridView 事件处理方法
        protected void GVgwork_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // 处理小组作品评价命令
            // 这里可以根据需要实现具体的评价逻辑
        }
        
        protected void GVgwork_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // 绑定数据时的处理
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // 可以在这里设置行的样式或处理数据
            }
        }
    }
}
