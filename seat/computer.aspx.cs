using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Seat_computer : System.Web.UI.Page
{
    protected string firstshow = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        LearnSite.Common.CookieHelp.JudgeIsAdmin();
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
        if (!IsPostBack)
        {
            firstshow = getHseat();
            showOld();
        }
    }
    public string getHid()
    {
        if (Request.QueryString["Hid"] != null)
            return Request.QueryString["Hid"].ToString();
        else
            return "0";
    }
    private string getHseat()
    {
        if (Request.QueryString["Hid"] != null)
        {
            string hid = Request.QueryString["Hid"].ToString();
            int hidValue;
            if (Int32.TryParse(hid, out hidValue))
            {
                string connStr = GetConnStr();
                if (!String.IsNullOrEmpty(connStr))
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        using (SqlCommand cmd = new SqlCommand("SELECT Hseat FROM House WHERE Hid=@Hid", conn))
                        {
                            cmd.Parameters.Add("@Hid", SqlDbType.Int).Value = hidValue;
                            object value = cmd.ExecuteScalar();
                            if (value != null && value != DBNull.Value)
                            {
                                return value.ToString();
                            }
                        }
                    }
                }
            }
        }
        return "";
    }

    private void showOld()
    {
        if (firstshow.Length > 10)
        {
            string[] old_collects = firstshow.Split('-');
            if (old_collects.Length >= 3)
            {
                string slnum = old_collects[0];
                string sallnum = old_collects[1];
                string ssortway = old_collects[2];
                int lnum, allnum;
                if (Int32.TryParse(slnum, out lnum) && Int32.TryParse(sallnum, out allnum) && lnum > 0 && allnum > 0)
                {
                    try { ddll.SelectedValue = slnum; } catch { }
                    TextBoxall.Text = sallnum;
                    try { RadioBtnSelect.SelectedValue = ssortway; } catch { }
                    myhouse.Text = createseats(lnum, allnum, ssortway);
                    return;
                }
            }
        }
        // 默认兜底：6列30台纵向布局
        myhouse.Text = createseats(6, 30, "0");
    }
    protected void Buttoninit_Click(object sender, EventArgs e)
    {
        firstshow = "";
        LearnSite.Common.Others.ClearClientPageCache();
        string sort = RadioBtnSelect.SelectedValue;
        if (LearnSite.Common.WordProcess.IsNum(ddll.SelectedValue) && LearnSite.Common.WordProcess.IsNum(TextBoxall.Text))
        {
            int lnum = Int32.Parse(ddll.SelectedValue);
            int allnum = Int32.Parse(TextBoxall.Text);
            int limitnum = 150;
            if (allnum < limitnum)
            {
                myhouse.Text = createseats(lnum, allnum, sort);
            }
            else
            {
                myhouse.Text = "电脑总数上限为" + limitnum + "台！";
            }
        }
    }

    private string createseats(int lnum, int allnum, string sort)
    {
        string context = "";
        int hnum = allnum / lnum;

        if (hnum == 0)
            lnum = 1;
        int cmp = 0;
        for (int i = 0; i < lnum; i++)
        {
            context += "<div class=\"computer-place\">\r\n";
            for (int j = 0; j < hnum; j++)
            {
                cmp++;
                if (cmp > allnum)
                {
                    break;
                }
                else
                {
                    int cname = 888;
                    if (sort == "0")
                        cname = i * hnum + j + 1;
                    else
                    {
                        cname = j * lnum + i + 1;
                    }
                    context += "<div class=\"computer\" id=\"" + cname + "\">" + cname + "</div>\r\n";
                }
            }
            if (i == lnum - 1 && cmp < allnum)
            {
                int leftnum = allnum - hnum * lnum;
                if (leftnum > 0)
                {
                    for (int k = 0; k < leftnum; k++)
                    {
                        cmp++;
                        context += "<div class=\"computer\" id=\"" + cmp + "\">" + cmp + "</div>\r\n";
                    }
                }
            }
            context += "</div>\r\n";
        }
        return context;
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo f = dbType.GetField("connectionString", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (f != null)
                {
                    cs = f.GetValue(null) as string;
                }
            }
        }
        catch { }
        if (String.IsNullOrEmpty(cs))
        {
            try
            {
                ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["SqlServer"];
                if (settings != null)
                {
                    cs = settings.ConnectionString;
                }
            }
            catch { }
        }
        if (!String.IsNullOrEmpty(cs) && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
        {
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        }
        return cs;
    }
}
