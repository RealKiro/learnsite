#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\App_Code\showmission_new.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "823629DFE0F14EB6560E31E5DE1CA41E"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\App_Code\showmission_new.cs"
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;

public class Student_showmission_new : Page
{
    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11":
            case "17":
            case "18":
            case "19":
            case "20":
            case "21":
            case "22":
            case "23":
            case "24":
            case "25":
            case "26":
            case "27":
            case "28":
            case "29":
            case "30":
            case "31":
            case "32":
            case "33":
            case "34":
            case "35":
            case "36":
            case "37":
                return true;
            default:
                return false;
        }
    }
    // 控件引用
    private HtmlGenericControl _mcontent;
    private Label _labelMtitle;
    private Label _labelLid;
    private Label _labelMid;
    private Label _labelMcid;
    private Label _labelMsort;
    private CheckBox _ckMupload;
    private CheckBox _ckMgroup;
    private Label _labelMfiletype;
    private HyperLink _upFileUrl;
    private Image _upFileType;
    private HyperLink _upFileUrlGroup;
    private Image _upFileTypeGroup;
    private GridView _gVgwork;
    private HyperLink _voteLink;
    private Panel _panelworks;
    private Panel _panelswfupload;
    private Panel _panelGroupUp;
    private Panel _panelgroup;
    private Label _labelmsg;
    private Label _labelgroupmsg;
    private Label _labelSnum;
    private Label _labelUploadType;
    private Image _imageType;
    private HtmlGenericControl _submittedWork;
    private HtmlGenericControl _submittedGroupWork;

    // 递归查找控件
    private Control FindControlRecursive(Control root, string id)
    {
        if (root == null) return null;
        if (root.ID == id) return root;
        foreach (Control child in root.Controls)
        {
            Control found = FindControlRecursive(child, id);
            if (found != null) return found;
        }
        return null;
    }

    // 初始化控件引用
    private void InitializeControls()
    {
        _mcontent = FindControlRecursive(this, "Mcontent") as HtmlGenericControl;
        _labelMtitle = FindControlRecursive(this, "LabelMtitle") as Label;
        _labelLid = FindControlRecursive(this, "LabelLid") as Label;
        _labelMid = FindControlRecursive(this, "LabelMid") as Label;
        _labelMcid = FindControlRecursive(this, "LabelMcid") as Label;
        _labelMsort = FindControlRecursive(this, "LabelMsort") as Label;
        _ckMupload = FindControlRecursive(this, "CkMupload") as CheckBox;
        _ckMgroup = FindControlRecursive(this, "CkMgroup") as CheckBox;
        _labelMfiletype = FindControlRecursive(this, "LabelMfiletype") as Label;
        _upFileUrl = FindControlRecursive(this, "upFileUrl") as HyperLink;
        _upFileType = FindControlRecursive(this, "upFileType") as Image;
        _upFileUrlGroup = FindControlRecursive(this, "upFileUrlGroup") as HyperLink;
        _upFileTypeGroup = FindControlRecursive(this, "upFileTypeGroup") as Image;
        _gVgwork = FindControlRecursive(this, "GVgwork") as GridView;
        _voteLink = FindControlRecursive(this, "VoteLink") as HyperLink;
        _panelworks = FindControlRecursive(this, "Panelworks") as Panel;
        _panelswfupload = FindControlRecursive(this, "Panelswfupload") as Panel;
        _panelGroupUp = FindControlRecursive(this, "PanelGroupUp") as Panel;
        _panelgroup = FindControlRecursive(this, "Panelgroup") as Panel;
        _labelmsg = FindControlRecursive(this, "Labelmsg") as Label;
        _labelgroupmsg = FindControlRecursive(this, "Labelgroupmsg") as Label;
        _labelSnum = FindControlRecursive(this, "LabelSnum") as Label;
        _labelUploadType = FindControlRecursive(this, "LabelUploadType") as Label;
        _imageType = FindControlRecursive(this, "ImageType") as Image;
        _submittedWork = FindControlRecursive(this, "submittedWork") as HtmlGenericControl;
        _submittedGroupWork = FindControlRecursive(this, "submittedGroupWork") as HtmlGenericControl;
    }

    // 获取学生学号（从Cookie）
    private string GetStudentSnum()
    {
        string snum = "";
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, Encoding.UTF8); }
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
        return snum;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        InitializeControls();

        if (!IsPostBack)
        {
            try
            {
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
                // 判断任务类型，如果是"讨论"，跳转到讨论页面
                string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString() : string.Empty;
                string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString() : string.Empty;
                string courseIdFromDb = reader["Lcid"] != DBNull.Value ? reader["Lcid"].ToString() : string.Empty;
                if (listId == 111 && courseIdFromDb == "16")
                    ltype = "8";
                if (IsPixelAddProgramSubtype(msort))
                {
                    string lxidStr = reader["Lxid"] != DBNull.Value ? reader["Lxid"].ToString() : "0";
                    string redirectMcid = !string.IsNullOrEmpty(courseIdFromDb) ? courseIdFromDb : (mcid ?? "");
                    reader.Close();
                    reader = null;
                    string redirectUrl = string.Format("~/student/program.aspx?lid={0}&mid={1}&mcid={2}", listId, lxidStr, redirectMcid);
                    Response.Redirect(redirectUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (ltype == "13" || ltype == "讨论")
                {
                    string mcidParam = !string.IsNullOrEmpty(courseIdFromDb)
                        ? courseIdFromDb
                        : (Request.QueryString["mcid"] ?? string.Empty);
                    string redirectUrl = !string.IsNullOrEmpty(mcidParam)
                        ? string.Format("~/student/topicdiscuss.aspx?lid={0}&cid={1}", listId, mcidParam)
                        : string.Format("~/student/topicdiscuss.aspx?lid={0}", listId);
                    Response.Redirect(redirectUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                // 设置任务标题
                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "未命名任务";
                if (_labelMtitle != null)
                    _labelMtitle.Text = ltitle;

                // 设置隐藏字段
                if (_labelLid != null)
                    _labelLid.Text = listId.ToString();

                if (_labelMid != null && reader["Mid"] != DBNull.Value)
                    _labelMid.Text = reader["Mid"].ToString();

                if (_labelMcid != null && reader["Lcid"] != DBNull.Value)
                    _labelMcid.Text = reader["Lcid"].ToString();

                if (_labelMsort != null && reader["Msort"] != DBNull.Value)
                    _labelMsort.Text = reader["Msort"].ToString();

                // 设置复选框
                bool mupload = false;
                if (reader["Mupload"] != DBNull.Value)
                {
                    mupload = Convert.ToBoolean(reader["Mupload"]);
                    if (_ckMupload != null) _ckMupload.Checked = mupload;
                }

                bool mgroup = false;
                if (reader["Mgroup"] != DBNull.Value)
                {
                    mgroup = Convert.ToBoolean(reader["Mgroup"]);
                    if (_ckMgroup != null) _ckMgroup.Checked = mgroup;
                }

                // 设置文件类型
                string mfiletype = "";
                if (reader["Mfiletype"] != DBNull.Value)
                {
                    mfiletype = reader["Mfiletype"].ToString();
                    if (_labelMfiletype != null) _labelMfiletype.Text = mfiletype;
                }

                // 设置文件类型图标
                if (_imageType != null && !string.IsNullOrEmpty(mfiletype))
                {
                    _imageType.ImageUrl = "~/images/filetype/" + mfiletype.ToLower() + ".gif";
                }

                // 加载任务内容
                if (_mcontent != null)
                {
                    string content = reader["Mcontent"] != DBNull.Value ? reader["Mcontent"].ToString() : "";
                    _mcontent.InnerHtml = string.IsNullOrEmpty(content)
                        ? "<div style='color: #999; text-align: center; padding: 40px;'>暂无任务内容</div>"
                        : content;
                }

                Page.Title = ltitle + " - 任务详情";

                reader.Close();
                reader = null;

                // 控制上传面板可见性
                System.Diagnostics.Debug.WriteLine("Mupload=" + mupload + ", Mgroup=" + mgroup);
                
                if (_panelworks != null)
                {
                    _panelworks.Visible = mupload;
                    System.Diagnostics.Debug.WriteLine("Panelworks.Visible=" + _panelworks.Visible);
                }

                // 控制上传按钮面板可见性
                if (_panelswfupload != null)
                {
                    _panelswfupload.Visible = mupload;
                    System.Diagnostics.Debug.WriteLine("Panelswfupload.Visible=" + _panelswfupload.Visible);
                }

                if (_panelgroup != null)
                {
                    _panelgroup.Visible = mgroup;
                    System.Diagnostics.Debug.WriteLine("Panelgroup.Visible=" + _panelgroup.Visible);
                }

                // 控制小组上传按钮面板可见性
                if (_panelGroupUp != null)
                {
                    _panelGroupUp.Visible = mgroup;
                    System.Diagnostics.Debug.WriteLine("PanelGroupUp.Visible=" + _panelGroupUp.Visible);
                }

                // 加载已提交作品信息
                LoadWorkInfo(conn, listId);

                // 加载小组作品
                if (mgroup)
                    LoadGroupWorkInfo(conn, listId);
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

    // 加载已提交的作品信息
    private void LoadWorkInfo(SqlConnection conn, int lid)
    {
        string snum = GetStudentSnum();
        if (string.IsNullOrEmpty(snum)) return;

        if (_labelSnum != null) _labelSnum.Text = snum;

        SqlCommand cmd = null;
        SqlDataReader reader = null;

        try
        {
            string sql = @"
                SELECT TOP 1 Wurl, Wtype
                FROM Works
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
                    // 显示已提交作品区域
                    if (_submittedWork != null)
                        _submittedWork.Visible = true;

                    if (_upFileUrl != null)
                    {
                        _upFileUrl.NavigateUrl = wurl;
                        _upFileUrl.Text = "📄 查看已提交作品";
                        _upFileUrl.Visible = true;
                    }

                    if (_upFileType != null && !string.IsNullOrEmpty(wtype))
                    {
                        _upFileType.ImageUrl = "~/images/filetype/" + wtype.ToLower() + ".gif";
                        _upFileType.Visible = true;
                    }

                    if (_labelmsg != null)
                        _labelmsg.Text = "已提交作品，可重新提交覆盖";
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadWorkInfo Error: " + ex.ToString());
        }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
        }
    }

    // 加载小组作品信息
    private void LoadGroupWorkInfo(SqlConnection conn, int lid)
    {
        SqlCommand cmd = null;
        SqlDataReader reader = null;

        try
        {
            string sql = @"
                SELECT W.Wid, W.Wurl, W.Wtype, W.Wname as Sname, W.Wlscore
                FROM Works W
                WHERE W.Wlid = @Lid
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

            if (_gVgwork != null && dt.Rows.Count > 0)
            {
                _gVgwork.DataSource = dt;
                _gVgwork.DataBind();
            }
        }
        catch { }
        finally
        {
            if (reader != null && !reader.IsClosed) reader.Close();
            if (cmd != null) cmd.Dispose();
        }
    }

    // GridView 事件处理方法
    protected void GVgwork_RowCommand(object sender, GridViewCommandEventArgs e)
    {
    }

    protected void GVgwork_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HyperLink link = e.Row.FindControl("HyperLinkWurl") as HyperLink;
            if (link != null && !string.IsNullOrEmpty(link.ToolTip))
            {
                link.NavigateUrl = link.ToolTip;
            }
        }
    }
}


#line default
#line hidden
