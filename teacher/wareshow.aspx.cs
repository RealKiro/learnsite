using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearnSite
{
    public partial class teacher_wareshow : System.Web.UI.Page
    {
        // 使用 codefile 时 ASP.NET 自动生成控件字段，无需手动声明

        private string wareUrl = "";
        private int missionIdField = 0;
        private int courseIdField = 0;
        private int lidField = 0;

        /// <summary>课件预览 URL，供 ASPX 模板 &lt;%= WareUrl %&gt; 使用</summary>
        public string WareUrl
        {
            get { return wareUrl; }
        }

        /// <summary>Mission ID</summary>
        public string Mid
        {
            get { return missionIdField.ToString(); }
        }

        /// <summary>列表菜单 ID（Listmenu.Lid），来自 URL 参数 lid</summary>
        public string Lid
        {
            get { return lidField.ToString(); }
        }

        /// <summary>
        /// 学生端课件页面 URL（../student/ware.aspx?lid=…&amp;mid=…&amp;mcid=…）。
        /// lid=0 时返回空字符串（隐藏按钮）。
        /// </summary>
        public string StudentUrl
        {
            get
            {
                if (lidField > 0 && missionIdField > 0 && courseIdField > 0)
                    return string.Format("../student/ware.aspx?lid={0}&mid={1}&mcid={2}",
                        lidField, missionIdField, courseIdField);
                return "";
            }
        }

        /// <summary>
        /// 课件所属课程 ID（Mission.Mcid）。
        /// wareadd/wareedit 用它作为 store 文件夹的 cid，
        /// wareshow 加载文件列表时必须用相同的字段。
        /// </summary>
        public string CourseId
        {
            get { return courseIdField.ToString(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int missionId = 0;
                string mid = Request.QueryString["mid"];
                if (!string.IsNullOrEmpty(mid))
                    int.TryParse(mid, out missionId);

                // 读取 lid 参数，供学生端预览链接使用
                string lidParam = Request.QueryString["lid"];
                if (!string.IsNullOrEmpty(lidParam))
                    int.TryParse(lidParam, out lidField);

                if (missionId > 0)
                {
                    missionIdField = missionId;
                    LoadWareInfo(missionId);
                }
            }
        }

        /// <summary>从 Mission 表读取课件信息并填充页面控件</summary>
        private void LoadWareInfo(int missionId)
        {
            string connStr;
            try
            {
                connStr = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("DB Config Error: " + ex.Message);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    const string sql = "SELECT Mtitle, Mdate, Mfiletype, Mpublish, Mexample, Mcontent, Mcid FROM Mission WHERE Mid = @Mid";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Mid", missionId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // 课件标题
                                if (LabelMtitle != null)
                                    LabelMtitle.Text = reader["Mtitle"] != DBNull.Value ? reader["Mtitle"].ToString() : "";

                                // 日期
                                if (LabelMdate != null && reader["Mdate"] != DBNull.Value)
                                {
                                    DateTime date;
                                    if (DateTime.TryParse(reader["Mdate"].ToString(), out date))
                                        LabelMdate.Text = date.ToString("yyyy-MM-dd");
                                }

                                // 文件类型
                                string filetype = reader["Mfiletype"] != DBNull.Value
                                    ? reader["Mfiletype"].ToString()
                                    : "ware";
                                if (LabelMfiletype != null)
                                    LabelMfiletype.Text = filetype;
                                if (ImageType != null)
                                    ImageType.ImageUrl = "~/images/filetype/" + filetype.ToLower() + ".gif";

                                // 发布状态
                                if (CheckPublish != null && reader["Mpublish"] != DBNull.Value)
                                    CheckPublish.Checked = Convert.ToBoolean(reader["Mpublish"]);

                                // 课件首页 URL：优先取 Mexample（与 student/iframe.aspx 一致），
                                // 若为空则尝试 Mcontent（兼容旧版本可能将 URL 存入 Mcontent）
                                string mexample = reader["Mexample"] != DBNull.Value
                                    ? reader["Mexample"].ToString().Trim()
                                    : "";
                                string mcontent = reader["Mcontent"] != DBNull.Value
                                    ? reader["Mcontent"].ToString().Trim()
                                    : "";
                                // 判断是否是有效 URL（路径或 http 开头）
                                bool isUrl = mcontent.StartsWith("../") || mcontent.StartsWith("/")
                                             || mcontent.StartsWith("http");
                                wareUrl = !string.IsNullOrEmpty(mexample) ? mexample
                                        : (isUrl ? mcontent : "");

                                // 课程 ID（与 wareadd/wareedit 中 store 文件夹保持一致）
                                if (reader["Mcid"] != DBNull.Value)
                                    courseIdField = Convert.ToInt32(reader["Mcid"]);

                                if (HyperLinkHtml != null)
                                {
                                    HyperLinkHtml.NavigateUrl = wareUrl;
                                    HyperLinkHtml.Text = "课件首页";
                                }

                                Page.Title = (LabelMtitle != null && LabelMtitle.Text.Length > 0)
                                    ? LabelMtitle.Text
                                    : "课件详情";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadWareInfo Error: " + ex.Message);
            }
        }

        /// <summary>点击"修改课件"跳转到 wareedit.aspx</summary>
        protected void BtnEdit_Click(object sender, ImageClickEventArgs e)
        {
            string mid  = Request.QueryString["mid"]  ?? "0";
            string mcid = Request.QueryString["mcid"] ?? Request.QueryString["cid"] ?? "0";
            string lid  = Request.QueryString["lid"]  ?? "0";
            Response.Redirect(string.Format("wareedit.aspx?mid={0}&mcid={1}&lid={2}", mid, mcid, lid));
        }

        /// <summary>点击"返回列表"跳转到 courseshow.aspx</summary>
        protected void BtnReturnSmall_Click(object sender, ImageClickEventArgs e)
        {
            string mcid = Request.QueryString["mcid"] ?? Request.QueryString["cid"] ?? "0";
            int courseId = 0;
            if (int.TryParse(mcid, out courseId) && courseId > 0)
                Response.Redirect("courseshow.aspx?cid=" + courseId);
            else
                Response.Redirect("course.aspx");
        }
    }
}
