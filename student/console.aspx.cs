using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

public partial class Student_console : System.Web.UI.Page
{
    // ── 递归查找控件 ──────────────────────────────────────────
    private Control FindCtrl(Control root, string id)
    {
        if (root == null) return null;
        if (root.ID == id) return root;
        foreach (Control c in root.Controls)
        {
            Control f = FindCtrl(c, id);
            if (f != null) return f;
        }
        return null;
    }

    // ── 获取数据库连接字符串 ───────────────────────────────────
    private string GetConnStr()
    {
        try { return ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
        catch { return null; }
    }

    // ── 获取当前学生学号（优先Session，兼容Cookie） ─────────────
    private string GetSnum()
    {
        try { if (Session["Snum"] != null) return Session["Snum"].ToString(); }
        catch { }
        try
        {
            // 兼容基于 Cookie 的登录
            System.Web.HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string val = sc.Value;
                if (val.Contains("%"))
                    try { val = System.Web.HttpUtility.UrlDecode(val, System.Text.Encoding.UTF8); } catch { }
                var ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    var mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    if (mi != null) mi.Invoke(m, new object[] { val });
                    var pn = ct.GetProperty("Snum");
                    if (pn != null) { object v = pn.GetValue(m, null); if (v != null) return v.ToString(); }
                }
            }
        }
        catch { }
        return "";
    }

    // ── Page_Load ─────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
                LoadConsoleData();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Student_console Page_Load Error: " + ex);
        }
    }

    // ── 加载测评主数据 ─────────────────────────────────────────
    private void LoadConsoleData()
    {
        string lidParam = Request.QueryString["lid"];
        if (string.IsNullOrEmpty(lidParam)) return;
        int lid;
        if (!int.TryParse(lidParam, out lid)) return;

        // 取控件引用
        Label labelLid    = FindCtrl(this, "LabelLid")    as Label;
        Label labelCid    = FindCtrl(this, "LabelCid")    as Label;
        Label labelNid    = FindCtrl(this, "LabelNid")    as Label;
        Label labelMtitle = FindCtrl(this, "LabelMtitle") as Label;
        HtmlGenericControl mcontent = FindCtrl(this, "Mcontent") as HtmlGenericControl;
        Button     btnIdle  = FindCtrl(this, "BtnIdle")   as Button;
        ImageButton btnclock = FindCtrl(this, "Btnclock") as ImageButton;
        Image      imagepass = FindCtrl(this, "Imagepass") as Image;
        HyperLink  hlsolve  = FindCtrl(this, "Hlsolve")   as HyperLink;
        GridView   gvSolve  = FindCtrl(this, "GVSolve")   as GridView;

        if (labelLid != null) labelLid.Text = lid.ToString();

        // 默认隐藏通过图片
        if (imagepass != null) imagepass.Visible = false;

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return;

        SqlConnection conn = null;
        try
        {
            conn = new SqlConnection(cs);
            conn.Open();

            // 通过 Listmenu 联查 Noconsole 获取测评信息
            int    nid      = 0;
            int    cid      = 0;
            string ntitle   = "";
            string ncontent = "";
            bool   nclock   = false;

            using (SqlCommand cmd = new SqlCommand(
                @"SELECT L.Lxid, L.Lcid,
                         N.Ntitle, N.Ncontent, N.Nclock
                  FROM   Listmenu L
                  LEFT JOIN Noconsole N ON L.Lxid = N.Nid
                  WHERE  L.Lid = @Lid", conn))
            {
                cmd.Parameters.AddWithValue("@Lid", lid);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        nid      = r["Lxid"]     != DBNull.Value ? Convert.ToInt32(r["Lxid"])  : 0;
                        cid      = r["Lcid"]     != DBNull.Value ? Convert.ToInt32(r["Lcid"])  : 0;
                        ntitle   = r["Ntitle"]   != DBNull.Value ? r["Ntitle"].ToString()   : "";
                        ncontent = r["Ncontent"] != DBNull.Value ? r["Ncontent"].ToString() : "";
                        try { nclock = r["Nclock"] != DBNull.Value && Convert.ToBoolean(r["Nclock"]); }
                        catch { nclock = false; }
                    }
                    r.Close();
                }
            }

            // 设置隐藏标识 Label
            if (labelNid != null)    labelNid.Text    = nid.ToString();
            if (labelCid != null)    labelCid.Text    = cid.ToString();
            if (labelMtitle != null) labelMtitle.Text = ntitle;

            // 设置课程内容区
            if (mcontent != null)
                mcontent.InnerHtml = string.IsNullOrEmpty(ncontent)
                    ? "<div style='color:#999;text-align:center;padding:40px;'>暂无测评说明</div>"
                    : ncontent;

            // 时钟图片：开启=动画时钟，关闭=静态图
            if (btnclock != null)
            {
                btnclock.ImageUrl = nclock ? "~/images/clock.gif" : "~/images/clock.gif";
                btnclock.ToolTip  = nclock ? "测评进行中，点击刷新状态" : "测评尚未开放，点击刷新状态";
            }

            // 开始测评按钮：时钟未开启时禁用
            if (btnIdle != null)
            {
                btnIdle.Enabled = nclock;
                if (!nclock)
                    btnIdle.ToolTip = "测评尚未开放，请等待老师开启";
            }

            // 班级测评报告链接
            if (hlsolve != null)
                hlsolve.NavigateUrl = "~/student/classolve.aspx?nid=" + nid + "&lid=" + lid;

            // 加载题目得分列表
            if (nid > 0)
                LoadSolveScores(conn, nid, gvSolve, imagepass);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadConsoleData Error: " + ex);
        }
        finally
        {
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }

    // ── 加载题目与得分 ─────────────────────────────────────────
    private void LoadSolveScores(SqlConnection conn, int nid, GridView gvSolve, Image imagepass)
    {
        string snum = GetSnum();

        try
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT P.Pid, P.Ptitle, P.Pscore,
                         ISNULL(V.Vscore, -1) AS Vscore
                  FROM   Problem P
                  LEFT JOIN Solve V ON V.Vpid = P.Pid
                            AND V.Vsnum = @Snum
                  WHERE  P.Pnid = @Nid
                  ORDER  BY ISNULL(P.Psort, 9999), P.Pid", conn))
            {
                cmd.Parameters.AddWithValue("@Nid",  nid);
                cmd.Parameters.AddWithValue("@Snum", string.IsNullOrEmpty(snum) ? "" : snum);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (gvSolve != null)
            {
                gvSolve.DataSource = dt;
                gvSolve.DataBind();
            }

            // 判断是否全部通过
            if (imagepass != null && dt.Rows.Count > 0)
            {
                bool allPassed = true;
                foreach (DataRow row in dt.Rows)
                {
                    int vscore = row["Vscore"] != DBNull.Value ? Convert.ToInt32(row["Vscore"]) : -1;
                    int pscore = row["Pscore"] != DBNull.Value ? Convert.ToInt32(row["Pscore"]) : 1;
                    if (vscore < pscore) { allPassed = false; break; }
                }
                imagepass.Visible = allPassed;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadSolveScores Error: " + ex);
        }
    }

    // ── GVSolve 行数据绑定 ─────────────────────────────────────
    protected void GVSolve_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // 第一列显示题目序号
            e.Row.Cells[0].Text = (e.Row.RowIndex + 1).ToString();

            Label lbScore = e.Row.FindControl("Labelscore") as Label;
            Label lbFlag  = e.Row.FindControl("Labelflag")  as Label;

            if (lbScore != null && lbFlag != null)
            {
                int score;
                bool parsed = int.TryParse(lbScore.Text, out score);

                if (!parsed || score < 0)
                {
                    // 未作答
                    lbScore.Text = "—";
                    lbFlag.Text  = "—";
                    lbFlag.Style["color"] = "#94a3b8";
                }
                else if (score > 0)
                {
                    // 得分
                    lbFlag.Text = "✓";
                    lbFlag.Style["color"]       = "#16a34a";
                    lbFlag.Style["font-weight"] = "bold";
                }
                else
                {
                    // 得0分
                    lbFlag.Text = "✗";
                    lbFlag.Style["color"] = "#dc2626";
                }
            }
        }
    }

    // ── 开始测评 按钮 ──────────────────────────────────────────
    protected void BtnIdle_Click(object sender, EventArgs e)
    {
        try
        {
            Label labelLid = FindCtrl(this, "LabelLid") as Label;
            Label labelNid = FindCtrl(this, "LabelNid") as Label;
            Label labelCid = FindCtrl(this, "LabelCid") as Label;

            string lid = labelLid != null ? labelLid.Text : "";
            string nid = labelNid != null ? labelNid.Text : "";
            string cid = labelCid != null ? labelCid.Text : "";

            // 如果 ViewState 中的标识无效，从数据库重新取
            if (string.IsNullOrEmpty(nid) || nid == "0")
            {
                string lidParam = Request.QueryString["lid"];
                if (!string.IsNullOrEmpty(lidParam))
                {
                    int lidVal;
                    if (int.TryParse(lidParam, out lidVal))
                    {
                        string cs = GetConnStr();
                        if (!string.IsNullOrEmpty(cs))
                        {
                            using (SqlConnection conn = new SqlConnection(cs))
                            {
                                conn.Open();
                                using (SqlCommand cmd = new SqlCommand(
                                    "SELECT Lxid, Lcid FROM Listmenu WHERE Lid = @Lid", conn))
                                {
                                    cmd.Parameters.AddWithValue("@Lid", lidVal);
                                    using (SqlDataReader r = cmd.ExecuteReader())
                                    {
                                        if (r.Read())
                                        {
                                            nid = r["Lxid"] != DBNull.Value ? r["Lxid"].ToString() : "0";
                                            cid = r["Lcid"] != DBNull.Value ? r["Lcid"].ToString() : "0";
                                        }
                                        r.Close();
                                    }
                                }
                            }
                            lid = lidParam;
                        }
                    }
                }
            }

            if (!string.IsNullOrEmpty(nid) && nid != "0")
            {
                Response.Redirect(string.Format(
                    "~/student/pythonIdle.aspx?lid={0}&nid={1}&cid={2}", lid, nid, cid));
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("BtnIdle_Click Error: " + ex);
        }
    }

    // ── 时钟按钮（刷新测评状态） ───────────────────────────────
    protected void Btnclock_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            string lid = Request.QueryString["lid"];
            if (!string.IsNullOrEmpty(lid))
                Response.Redirect("~/student/console.aspx?lid=" + lid);
            else
                LoadConsoleData();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Btnclock_Click Error: " + ex);
        }
    }
}
