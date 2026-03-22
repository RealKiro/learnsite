using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LearnSite
{
    public partial class Teacher_circleshow : System.Web.UI.Page
    {
        // ===== 控件声明 =====
        protected global::System.Web.UI.WebControls.Label LabeMtitle;
        protected global::System.Web.UI.WebControls.Button Btnflash;
        protected global::System.Web.UI.WebControls.Button Btnrestart;
        protected global::System.Web.UI.WebControls.Button Btnstop;
        protected global::System.Web.UI.WebControls.ImageButton ImgBtnLeft;
        protected global::System.Web.UI.WebControls.DropDownList DDLstore;
        protected global::System.Web.UI.WebControls.ImageButton ImgBtnright;
        protected global::System.Web.UI.WebControls.Label Labelnum;
        protected global::System.Web.UI.WebControls.Label Labelname;
        protected global::System.Web.UI.WebControls.Label lbcurindex;
        protected global::System.Web.UI.WebControls.ImageButton ImgBtnTextbox;
        protected global::System.Web.UI.WebControls.TextBox TextBoxWself;
        protected global::System.Web.UI.WebControls.TextBox TextBoxWdsocre;
        protected global::System.Web.UI.WebControls.Image Image2;
        protected global::System.Web.UI.WebControls.RadioButtonList RBLselect;
        protected global::System.Web.UI.WebControls.ImageButton ImgBtn;
        protected global::System.Web.UI.WebControls.ImageButton BtnCheck;
        protected global::System.Web.UI.WebControls.DropDownList DDLname;
        protected global::System.Web.UI.WebControls.CheckBox CkselectG;
        protected global::System.Web.UI.WebControls.CheckBox CheckselectA;
        protected global::System.Web.UI.WebControls.CheckBox CheckBoxW;
        protected global::System.Web.UI.WebControls.ImageButton ImageBtnDel;
        protected global::System.Web.UI.WebControls.Literal Literal1;
        protected global::System.Web.UI.WebControls.HyperLink Hlcode;

        // ===== 评分映射：RadioButtonList 值 ↔ Wgrade 整数 =====
        private static readonly Dictionary<string, int> GradeToInt = new Dictionary<string, int>
        {
            {"G", 7}, {"A", 6}, {"B", 5}, {"C", 4}, {"D", 3}, {"E", 2}, {"O", 1}
        };
        private static readonly Dictionary<int, string> IntToGrade = new Dictionary<int, string>
        {
            {7, "G"}, {6, "A"}, {5, "B"}, {4, "C"}, {3, "D"}, {2, "E"}, {1, "O"}
        };

        // ===== URL 参数 =====
        private int _sg = 0;    // 学生组号 (sg)
        private int _sc = 1;    // 起始位置  (sc)
        private int _ci = 0;    // 班级/圈子 ID (ci)
        private int _mi = 0;    // 任务 ID    (mi)
        private string _ty = "";// 文件类型   (ty)

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
        }

        // ===== Page_Load =====
        protected void Page_Load(object sender, EventArgs e)
        {
            ParseParams();
            if (!IsPostBack)
            {
                LoadMissionTitle();
                BindWorks();
                int startIdx = Math.Max(0, _sc - 1);
                lbcurindex.Text = startIdx.ToString();
                ShowWork(startIdx);
            }
        }

        // 解析 URL 参数
        private void ParseParams()
        {
            int.TryParse(Request.QueryString["sg"] ?? "0", out _sg);
            int.TryParse(Request.QueryString["sc"] ?? "1", out _sc);
            int.TryParse(Request.QueryString["ci"] ?? "0", out _ci);
            int.TryParse(Request.QueryString["mi"] ?? "0", out _mi);
            _ty = (Request.QueryString["ty"] ?? "").Trim();
        }

        // 加载任务标题
        private void LoadMissionTitle()
        {
            if (_mi <= 0) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var cmd = new SqlCommand("SELECT Mtitle FROM Mission WHERE Mid = @Mid", conn);
                    cmd.Parameters.AddWithValue("@Mid", _mi);
                    var result = cmd.ExecuteScalar();
                    if (LabeMtitle != null && result != null && result != DBNull.Value)
                        LabeMtitle.Text = result.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadMissionTitle error: " + ex.Message);
            }
        }

        // ===== 核心查询：返回符合条件的作品列表 =====
        private DataTable GetWorks()
        {
            var sql = new StringBuilder();
            sql.Append(@"
                SELECT W.Wid,
                       ISNULL(NULLIF(W.Wname,''), S.Sname) AS Sname,
                       W.Wurl, W.Wtype, W.Wgrade, W.Wself,
                       W.Wscore, W.Wdscore, W.Wnum, W.Wcheck,
                       W.Wcode, W.Wflash, W.Woffice, W.Wlid
                FROM Works W
                LEFT JOIN Students S ON W.Wsid = S.Sid
                WHERE W.Wcid = @ci
                  AND W.Wmid = @mi
                  AND W.Wtype = @ty");

            if (_sg > 0)
                sql.Append(" AND S.Sgroup = @sg");

            // 筛选过滤
            if (CkselectG != null && CkselectG.Checked)
                sql.Append(" AND W.Wgrade = " + GradeToInt["G"]);
            else if (CheckselectA != null && CheckselectA.Checked)
                sql.Append(" AND W.Wgrade = " + GradeToInt["A"]);
            else if (CheckBoxW != null && CheckBoxW.Checked)
                sql.Append(" AND (W.Wgrade IS NULL OR W.Wgrade = 0)");

            sql.Append(" ORDER BY W.Wnum, W.Wid");

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var cmd = new SqlCommand(sql.ToString(), conn);
                    cmd.Parameters.AddWithValue("@ci", _ci);
                    cmd.Parameters.AddWithValue("@mi", _mi);
                    cmd.Parameters.AddWithValue("@ty", _ty);
                    if (_sg > 0)
                        cmd.Parameters.AddWithValue("@sg", _sg);

                    var adapter = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("GetWorks error: " + ex.Message);
                return new DataTable();
            }
        }

        // 绑定作品下拉列表
        private void BindWorks()
        {
            var dt = GetWorks();
            DDLstore.Items.Clear();
            DDLname.Items.Clear();
            DDLname.Items.Add(new ListItem("姓名", ""));

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                var row = dt.Rows[i];
                string wid    = row["Wid"].ToString();
                string sname  = row["Sname"] != DBNull.Value ? row["Sname"].ToString() : row["Wnum"].ToString();
                int gradeInt  = row["Wgrade"] != DBNull.Value ? Convert.ToInt32(row["Wgrade"]) : 0;
                string grade  = IntToGrade.ContainsKey(gradeInt) ? IntToGrade[gradeInt] : "";

                // 已评价则显示评分前缀，否则显示姓名
                string display = string.IsNullOrEmpty(grade) ? sname : grade + " " + sname;
                DDLstore.Items.Add(new ListItem(display, wid));
                DDLname.Items.Add(new ListItem(sname, wid));
            }

            Labelnum.Text = "0/" + dt.Rows.Count;
        }

        // 显示指定位置的作品
        private void ShowWork(int index)
        {
            var dt = GetWorks();
            int total = dt.Rows.Count;

            if (total == 0)
            {
                Literal1.Text = "<div style='text-align:center;padding:60px 0;color:#94a3b8;font-size:15px;'>暂无作品</div>";
                Labelnum.Text  = "0/0";
                Labelname.Text = "";
                return;
            }

            // 边界处理（循环）
            if (index < 0)      index = total - 1;
            if (index >= total) index = 0;

            lbcurindex.Text = index.ToString();

            if (DDLstore.Items.Count > index)
                DDLstore.SelectedIndex = index;

            Labelnum.Text = (index + 1) + "/" + total;

            var row     = dt.Rows[index];
            string wid    = row["Wid"].ToString();
            string sname  = row["Sname"] != DBNull.Value ? row["Sname"].ToString() : "";
            string wurl   = row["Wurl"]  != DBNull.Value ? row["Wurl"].ToString()  : "";
            string wtype  = row["Wtype"] != DBNull.Value ? row["Wtype"].ToString() : _ty;
            int gradeInt  = row["Wgrade"] != DBNull.Value ? Convert.ToInt32(row["Wgrade"]) : 0;
            string grade  = IntToGrade.ContainsKey(gradeInt) ? IntToGrade[gradeInt] : "";
            string wself  = row["Wself"]   != DBNull.Value ? row["Wself"].ToString()   : "";
            string wdscore= row["Wdscore"] != DBNull.Value ? row["Wdscore"].ToString() : "0";
            string wcode  = row["Wcode"]   != DBNull.Value ? row["Wcode"].ToString()   : "";
            string wlid   = row["Wlid"]    != DBNull.Value ? row["Wlid"].ToString()    : "";

            Labelname.Text = sname;

            if (TextBoxWself   != null) TextBoxWself.Text   = wself;
            if (TextBoxWdsocre != null) TextBoxWdsocre.Text = string.IsNullOrEmpty(wdscore) ? "0" : wdscore;

            // 恢复评级选中状态
            if (RBLselect != null)
            {
                RBLselect.ClearSelection();
                if (!string.IsNullOrEmpty(grade))
                {
                    var item = RBLselect.Items.FindByValue(grade);
                    if (item != null) item.Selected = true;
                }
            }

            // 渲染作品内容
            Literal1.Text = RenderWork(wid, wurl, wtype, wcode, wlid);
        }

        // 渲染作品 HTML
        private string RenderWork(string wid, string wurl, string wtype, string wcode, string wlid)
        {
            string safeUrl = string.IsNullOrEmpty(wurl) ? "" : Server.HtmlEncode(wurl);
            string type    = (wtype ?? "").ToLower().Trim();

            switch (type)
            {
                case "mp4":
                case "webm":
                case "ogg":
                    if (string.IsNullOrEmpty(wurl))
                        return EmptyMsg("此作品无视频文件");
                    return string.Format(
                        @"<div style='text-align:center;padding:8px 0;'>
                            <video controls autoplay style='max-width:100%;max-height:68vh;border-radius:8px;background:#000;'>
                                <source src='{0}' type='video/{1}' />
                                <p style='color:#94a3b8;'>浏览器不支持 HTML5 视频播放</p>
                            </video>
                          </div>",
                        safeUrl, type);

                case "swf":
                    if (string.IsNullOrEmpty(wurl))
                        return EmptyMsg("此作品无 Flash 文件");
                    return string.Format(
                        @"<div style='text-align:center;padding:8px 0;'>
                            <script>RufflePlayer=window.RufflePlayer||{{}};RufflePlayer.config={{autoplay:'on',unmuteOverlay:'hidden'}};</script>
                            <script src='../js/ruffle.js'></script>
                            <div id='flashWrap{0}' style='width:640px;height:480px;margin:auto;'></div>
                            <script>
                            (function(){{
                                var r=window.RufflePlayer.newest();
                                var p=r.createPlayer();
                                var el=document.getElementById('flashWrap{0}');
                                el.appendChild(p);
                                p.style.cssText='width:640px;height:480px;';
                                p.load('{1}');
                            }})();
                            </script>
                          </div>",
                        wid, safeUrl);

                case "zip":
                case "rar":
                case "7z":
                    return string.Format(
                        @"<div style='text-align:center;padding:40px;'>
                            <a href='{0}' target='_blank' style='font-size:15px;color:#4f46e5;text-decoration:none;'>
                                <img src='../images/{1}.gif' alt='{1}'
                                     style='width:28px;height:28px;vertical-align:middle;margin-right:6px;'
                                     onerror='this.style.display=&quot;none&quot;' />
                                下载作品文件
                            </a>
                          </div>",
                        safeUrl, type);

                default:
                    // 通用：iframe 预览
                    if (!string.IsNullOrEmpty(wurl))
                        return string.Format(
                            @"<div style='text-align:center;'>
                                <iframe src='{0}' style='width:100%;height:68vh;border:none;border-radius:8px;'
                                        allowfullscreen></iframe>
                              </div>",
                            safeUrl);

                    // 代码型作品
                    if (!string.IsNullOrEmpty(wcode))
                        return string.Format(
                            @"<pre style='background:#1e293b;color:#e2e8f0;padding:20px;border-radius:8px;
                                          overflow:auto;font-size:13px;line-height:1.6;'>{0}</pre>",
                            Server.HtmlEncode(wcode));

                    return EmptyMsg("此作品无可显示内容");
            }
        }

        private string EmptyMsg(string msg)
        {
            return string.Format(
                "<div style='text-align:center;padding:60px;color:#94a3b8;font-size:15px;'>{0}</div>",
                Server.HtmlEncode(msg));
        }

        // ===== 评分 / 保存 =====
        private void SaveGrade(string wid, string gradeText)
        {
            int gradeInt = GradeToInt.ContainsKey(gradeText) ? GradeToInt[gradeText] : 0;
            int widInt;
            if (!int.TryParse(wid, out widInt)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var cmd = new SqlCommand(
                        "UPDATE Works SET Wgrade = @grade WHERE Wid = @wid", conn);
                    cmd.Parameters.AddWithValue("@grade", gradeInt);
                    cmd.Parameters.AddWithValue("@wid", widInt);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveGrade error: " + ex.Message);
            }
        }

        private void SaveRating(string wid)
        {
            int widInt;
            if (!int.TryParse(wid, out widInt)) return;
            int dscore;
            int.TryParse(TextBoxWdsocre != null ? TextBoxWdsocre.Text : "0", out dscore);
            string self    = TextBoxWself != null ? TextBoxWself.Text.Trim() : "";
            string gradeTxt= RBLselect   != null ? (RBLselect.SelectedValue ?? "") : "";
            int gradeInt   = GradeToInt.ContainsKey(gradeTxt) ? GradeToInt[gradeTxt] : 0;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var cmd = new SqlCommand(
                        @"UPDATE Works SET Wgrade = @grade, Wself = @self, Wdscore = @dscore
                          WHERE Wid = @wid", conn);
                    cmd.Parameters.AddWithValue("@grade",  gradeInt);
                    cmd.Parameters.AddWithValue("@self",   self);
                    cmd.Parameters.AddWithValue("@dscore", dscore);
                    cmd.Parameters.AddWithValue("@wid",    widInt);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveRating error: " + ex.Message);
            }
        }

        private void DeleteWork(string wid)
        {
            int widInt;
            if (!int.TryParse(wid, out widInt)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var cmd = new SqlCommand("DELETE FROM Works WHERE Wid = @wid", conn);
                    cmd.Parameters.AddWithValue("@wid", widInt);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("DeleteWork error: " + ex.Message);
            }
        }

        // ===== 事件处理器 =====

        // 刷新当前作品
        protected void Btnflash_Click(object sender, EventArgs e)
        {
            ParseParams();
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            BindWorks();
            ShowWork(idx);
        }

        // 重置到第一个作品
        protected void Btnrestart_Click(object sender, EventArgs e)
        {
            ParseParams();
            lbcurindex.Text = "0";
            BindWorks();
            ShowWork(0);
        }

        // 暂停 / 继续切换
        protected void Btnstop_Click(object sender, EventArgs e)
        {
            ParseParams();
            if (Btnstop.Text == "继续")
                Btnstop.Text = "暂停";
            else
                Btnstop.Text = "继续";
        }

        // 上一个作品
        protected void ImgBtnLeft_Click(object sender, ImageClickEventArgs e)
        {
            ParseParams();
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            BindWorks();
            ShowWork(idx - 1);
        }

        // 下一个作品
        protected void ImgBtnright_Click(object sender, ImageClickEventArgs e)
        {
            ParseParams();
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            BindWorks();
            ShowWork(idx + 1);
        }

        // 下拉列表直接跳转
        protected void DDLstore_SelectedIndexChanged(object sender, EventArgs e)
        {
            ParseParams();
            int idx = DDLstore.SelectedIndex;
            lbcurindex.Text = idx.ToString();
            ShowWork(idx);
        }

        // 切换评语输入框显示
        protected void ImgBtnTextbox_Click(object sender, ImageClickEventArgs e)
        {
            if (TextBoxWself != null)
                TextBoxWself.Visible = !TextBoxWself.Visible;
        }

        // 评级选择变更（实时保存）
        protected void RBLselect_SelectedIndexChanged(object sender, EventArgs e)
        {
            ParseParams();
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            var dt = GetWorks();
            if (idx < dt.Rows.Count)
            {
                string wid   = dt.Rows[idx]["Wid"].ToString();
                string grade = RBLselect.SelectedValue ?? "";
                SaveGrade(wid, grade);
            }
            BindWorks();
            ShowWork(idx);
        }

        // 循环展播专用刷新（保存评分后前进）
        protected void ImgBtn_Click(object sender, ImageClickEventArgs e)
        {
            ParseParams();
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            var dt = GetWorks();
            if (idx < dt.Rows.Count)
                SaveRating(dt.Rows[idx]["Wid"].ToString());
            BindWorks();
            ShowWork(idx + 1);
        }

        // 将已自动评分的作品设为已评
        protected void BtnCheck_Click(object sender, ImageClickEventArgs e)
        {
            ParseParams();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var sql = @"UPDATE Works SET Wcheck = 1
                                WHERE Wcid = @ci AND Wmid = @mi AND Wtype = @ty
                                  AND (Wscore > 0 OR (Wgrade IS NOT NULL AND Wgrade > 0))";
                    var cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@ci", _ci);
                    cmd.Parameters.AddWithValue("@mi", _mi);
                    cmd.Parameters.AddWithValue("@ty", _ty);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("BtnCheck error: " + ex.Message);
            }
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            BindWorks();
            ShowWork(idx);
        }

        // 姓名下拉选择跳转
        protected void DDLname_SelectedIndexChanged(object sender, EventArgs e)
        {
            ParseParams();
            string selectedWid = DDLname.SelectedValue;
            var dt = GetWorks();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i]["Wid"].ToString() == selectedWid)
                {
                    lbcurindex.Text = i.ToString();
                    if (DDLstore.Items.Count > i)
                        DDLstore.SelectedIndex = i;
                    ShowWork(i);
                    return;
                }
            }
        }

        // 筛 G 评
        protected void CkselectG_CheckedChanged(object sender, EventArgs e)
        {
            ParseParams();
            if (CkselectG.Checked)
            {
                CheckselectA.Checked = false;
                CheckBoxW.Checked    = false;
            }
            BindWorks();
            ShowWork(0);
        }

        // 筛 A 评
        protected void CheckselectA_CheckedChanged(object sender, EventArgs e)
        {
            ParseParams();
            if (CheckselectA.Checked)
            {
                CkselectG.Checked = false;
                CheckBoxW.Checked = false;
            }
            BindWorks();
            ShowWork(0);
        }

        // 筛未评
        protected void CheckBoxW_CheckedChanged(object sender, EventArgs e)
        {
            ParseParams();
            if (CheckBoxW.Checked)
            {
                CkselectG.Checked    = false;
                CheckselectA.Checked = false;
            }
            BindWorks();
            ShowWork(0);
        }

        // 删除作品
        protected void ImageBtnDel_Click(object sender, ImageClickEventArgs e)
        {
            ParseParams();
            int idx;
            int.TryParse(lbcurindex.Text, out idx);
            var dt = GetWorks();
            if (idx < dt.Rows.Count)
                DeleteWork(dt.Rows[idx]["Wid"].ToString());
            BindWorks();
            ShowWork(Math.Max(0, idx - 1));
        }
    }
}
