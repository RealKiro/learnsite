<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";
    protected int editBankId = 0;

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private void LoadTeacher()
    {
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out myHid); }
                }
            }
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadTeacher();
        if (!IsPostBack)
        {
            EnsureTables();
            string mode = Request.QueryString["mode"];
            string bidStr = Request.QueryString["bid"];
            if (mode == "edit" && !string.IsNullOrEmpty(bidStr))
            {
                int.TryParse(bidStr, out editBankId);
                PanelList.Visible = false;
                PanelEdit.Visible = true;
                LoadBankForEdit(editBankId);
                BindQuestions(editBankId);
            }
            else
            {
                PanelList.Visible = true;
                PanelEdit.Visible = false;
                BindBanks();
            }
        }
        else
        {
            if (HiddenBankId.Value != "")
                int.TryParse(HiddenBankId.Value, out editBankId);
        }
    }

    private void EnsureTables()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='QuestionBankList' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[QuestionBankList](
                            [Bid] [int] IDENTITY(1,1) NOT NULL,
                            [Btitle] [nvarchar](200) NULL,
                            [Bdesc] [nvarchar](500) NULL,
                            [Btype] [nvarchar](20) NULL DEFAULT('mixed'),
                            [Bhid] [int] NULL,
                            [Bcount] [int] NULL DEFAULT(0),
                            [Bdate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([Bid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
                // 为已存在的表添加 Btype 列
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankList') AND name='Btype') ALTER TABLE QuestionBankList ADD [Btype] [nvarchar](20) NULL DEFAULT('mixed')", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='QuestionBankItem' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[QuestionBankItem](
                            [Qid] [int] IDENTITY(1,1) NOT NULL,
                            [Qbid] [int] NULL,
                            [Qtype] [nvarchar](20) NULL,
                            [Qcontent] [nvarchar](2000) NULL,
                            [Qoption_a] [nvarchar](500) NULL,
                            [Qoption_b] [nvarchar](500) NULL,
                            [Qoption_c] [nvarchar](500) NULL,
                            [Qoption_d] [nvarchar](500) NULL,
                            [Qanswer] [nvarchar](500) NULL,
                            [Qscore] [int] NULL DEFAULT(5),
                            [Qsort] [int] NULL DEFAULT(0),
                            [Qfile] [nvarchar](500) NULL,
                            [Qdate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([Qid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
                // 为已存在的 QuestionBankItem 表添加 Qfile 列
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qfile') ALTER TABLE QuestionBankItem ADD [Qfile] [nvarchar](500) NULL", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
                // 为已存在的 QuestionBankItem 表添加 Qimage 列
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qimage') ALTER TABLE QuestionBankItem ADD [Qimage] [nvarchar](500) NULL", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
                // 为已存在的 QuestionBankItem 表添加选项图片列
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_a_img') ALTER TABLE QuestionBankItem ADD [Qoption_a_img] [nvarchar](500) NULL", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_b_img') ALTER TABLE QuestionBankItem ADD [Qoption_b_img] [nvarchar](500) NULL", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_c_img') ALTER TABLE QuestionBankItem ADD [Qoption_c_img] [nvarchar](500) NULL", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
                try
                {
                    using (SqlCommand addCol = new SqlCommand("IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_d_img') ALTER TABLE QuestionBankItem ADD [Qoption_d_img] [nvarchar](500) NULL", conn))
                    { addCol.ExecuteNonQuery(); }
                }
                catch { }
            }
        }
        catch { }
    }

    private void BindBanks()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Bid,Btitle,Bdesc,Btype,Bcount,Bdate FROM QuestionBankList WHERE Bhid=@hid ORDER BY Bdate DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@hid", myHid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptBanks.DataSource = dt;
                RptBanks.DataBind();
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; pageMsgType = "error"; }
    }

    protected void BtnCreateBank_Click(object sender, EventArgs e)
    {
        string title = TxtNewTitle.Text.Trim();
        if (string.IsNullOrEmpty(title)) { pageMsg = "请输入题单标题"; pageMsgType = "error"; BindBanks(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            int newBid = 0;
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string btype = DDLNewType.SelectedValue;
                string sql = "INSERT INTO QuestionBankList(Btitle,Bdesc,Btype,Bhid,Bcount,Bdate) VALUES(@title,@desc,@btype,@hid,0,GETDATE());SELECT SCOPE_IDENTITY()";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", TxtNewDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@btype", btype);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    object v = cmd.ExecuteScalar();
                    if (v != null) int.TryParse(v.ToString(), out newBid);
                }
            }
            if (newBid > 0)
                Response.Redirect("questionbank.aspx?mode=edit&bid=" + newBid);
            else
            {
                pageMsg = "创建成功"; pageMsgType = "success";
                TxtNewTitle.Text = ""; TxtNewDesc.Text = "";
                BindBanks();
            }
        }
        catch (Exception ex) { pageMsg = "创建失败: " + ex.Message; pageMsgType = "error"; BindBanks(); }
    }

    protected void RptBanks_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "DelBank")
        {
            int bid = 0; int.TryParse(e.CommandArgument.ToString(), out bid);
            if (bid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // 先查询所有题目的图片路径
                    using (SqlCommand cmdImg = new SqlCommand("SELECT Qimage FROM QuestionBankItem WHERE Qbid=@bid AND Qimage IS NOT NULL AND Qimage != ''", conn))
                    {
                        cmdImg.Parameters.AddWithValue("@bid", bid);
                        using (SqlDataReader reader = cmdImg.ExecuteReader())
                        {
                            System.Collections.Generic.List<string> imagePaths = new System.Collections.Generic.List<string>();
                            while (reader.Read())
                            {
                                imagePaths.Add(reader["Qimage"].ToString());
                            }
                            reader.Close();
                            // 删除所有图片文件
                            foreach (string imgPath in imagePaths)
                            {
                                try
                                {
                                    string fp = Server.MapPath("~/" + imgPath);
                                    if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                                }
                                catch { }
                            }
                        }
                    }
                    // 删除题单的题目和题单本身
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM QuestionBankItem WHERE Qbid=@bid", conn))
                    { cmd.Parameters.AddWithValue("@bid", bid); cmd.ExecuteNonQuery(); }
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM QuestionBankList WHERE Bid=@bid AND Bhid=@hid", conn))
                    { cmd.Parameters.AddWithValue("@bid", bid); cmd.Parameters.AddWithValue("@hid", myHid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "题单已删除"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; pageMsgType = "error"; }
            BindBanks();
        }
    }

    private void LoadBankForEdit(int bid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM QuestionBankList WHERE Bid=@bid", conn))
                {
                    cmd.Parameters.AddWithValue("@bid", bid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            TxtEditTitle.Text = reader["Btitle"] != DBNull.Value ? reader["Btitle"].ToString() : "";
                            TxtEditDesc.Text = reader["Bdesc"] != DBNull.Value ? reader["Bdesc"].ToString() : "";
                            string btype = "mixed";
                            try { if (reader["Btype"] != DBNull.Value && reader["Btype"].ToString().Trim().Length > 0) btype = reader["Btype"].ToString().Trim(); } catch { }
                            if (DDLEditType.Items.FindByValue(btype) != null) DDLEditType.SelectedValue = btype;
                            HiddenBankId.Value = bid.ToString();
                            editBankId = bid;
                        }
                    }
                }
            }
        }
        catch { }
    }

    protected void BtnSaveBank_Click(object sender, EventArgs e)
    {
        int bid = 0; int.TryParse(HiddenBankId.Value, out bid);
        if (bid <= 0) return;
        string title = TxtEditTitle.Text.Trim();
        if (string.IsNullOrEmpty(title)) { pageMsg = "请输入题单标题"; pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("UPDATE QuestionBankList SET Btitle=@t,Bdesc=@d,Btype=@btype WHERE Bid=@bid AND Bhid=@hid", conn))
                {
                    cmd.Parameters.AddWithValue("@t", title);
                    cmd.Parameters.AddWithValue("@d", TxtEditDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@btype", DDLEditType.SelectedValue);
                    cmd.Parameters.AddWithValue("@bid", bid);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "题单信息已保存"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "保存失败: " + ex.Message; pageMsgType = "error"; }
        editBankId = bid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(bid);
    }

    protected void BtnBackToList_Click(object sender, EventArgs e)
    {
        Response.Redirect("questionbank.aspx");
    }

    private void BindQuestions(int bid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter("SELECT Qid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qfile,Qimage,Qoption_a_img,Qoption_b_img,Qoption_c_img,Qoption_d_img FROM QuestionBankItem WHERE Qbid=@bid ORDER BY Qsort,Qid", conn);
                da.SelectCommand.Parameters.AddWithValue("@bid", bid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptQuestions.DataSource = dt;
                RptQuestions.DataBind();
                using (SqlCommand cmd = new SqlCommand("UPDATE QuestionBankList SET Bcount=@c WHERE Bid=@bid", conn))
                {
                    cmd.Parameters.AddWithValue("@c", dt.Rows.Count);
                    cmd.Parameters.AddWithValue("@bid", bid);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    // 判断是否为编程类题型
    private bool IsProgramType(string qtype)
    {
        if (string.IsNullOrEmpty(qtype)) return false;
        return qtype == "scratch" || qtype == "python" || qtype == "web" || qtype == "cpp" || qtype == "program";
    }

    // 允许上传的编程文件扩展名
    private string[] allowedProgramExts = { ".sb3", ".sb2", ".py", ".pyw", ".html", ".htm", ".css", ".js",
        ".c", ".cpp", ".h", ".java", ".zip", ".rar", ".7z", ".ino", ".xml", ".json", ".txt" };

    private bool IsAllowedProgramFile(string fileName)
    {
        string ext = System.IO.Path.GetExtension(fileName).ToLower();
        foreach (string a in allowedProgramExts)
        { if (ext == a) return true; }
        return false;
    }

    // 保存编程附件，返回相对路径
    private string SaveProgramFile(int bid, System.Web.UI.WebControls.FileUpload fu)
    {
        if (fu == null || !fu.HasFile) return "";
        if (!IsAllowedProgramFile(fu.FileName)) return "";
        string dir = Server.MapPath("~/upload/questionbank/" + bid);
        if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
        string ext = System.IO.Path.GetExtension(fu.FileName).ToLower();
        string newName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + new Random().Next(1000, 9999) + ext;
        string filePath = System.IO.Path.Combine(dir, newName);
        fu.SaveAs(filePath);
        return "upload/questionbank/" + bid + "/" + newName;
    }

    // 保存选项图片，返回相对路径
    private string SaveOptionImage(int bid, System.Web.UI.WebControls.FileUpload fu, string optionName)
    {
        if (fu == null || !fu.HasFile) return "";
        
        // 验证文件格式
        string ext = System.IO.Path.GetExtension(fu.FileName).ToLower();
        string[] allowedExts = { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };
        bool isAllowed = false;
        foreach (string allowedExt in allowedExts)
        {
            if (ext == allowedExt)
            {
                isAllowed = true;
                break;
            }
        }
        if (!isAllowed) return "";
        
        // 验证文件大小（2MB）
        if (fu.PostedFile.ContentLength > 2 * 1024 * 1024) return "";
        
        // 创建目录
        string dir = Server.MapPath("~/upload/questionbank/" + bid + "/options");
        if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
        
        // 生成文件名
        string newName = "opt_" + optionName + "_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ext;
        string filePath = System.IO.Path.Combine(dir, newName);
        fu.SaveAs(filePath);
        
        return "upload/questionbank/" + bid + "/options/" + newName;
    }

    protected void BtnAddQuestion_Click(object sender, EventArgs e)
    {
        int bid = 0; int.TryParse(HiddenBankId.Value, out bid);
        if (bid <= 0) return;
        string content = TxtQContent.Text.Trim();
        if (string.IsNullOrEmpty(content)) { pageMsg = "请输入题目内容"; pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return; }
        string qtype = DDLQType.SelectedValue;

        // 处理编程题文件上传
        string qfile = "";
        if (IsProgramType(qtype) && FileUploadProgram.HasFile)
        {
            if (!IsAllowedProgramFile(FileUploadProgram.FileName))
            {
                pageMsg = "不支持的文件类型，允许：" + string.Join(", ", allowedProgramExts);
                pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return;
            }
            if (FileUploadProgram.PostedFile.ContentLength > 10 * 1024 * 1024)
            {
                pageMsg = "文件大小不能超过 10MB"; pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return;
            }
            qfile = SaveProgramFile(bid, FileUploadProgram);
        }

        // 处理题目图片上传
        string qimage = "";
        if (FileUploadQuestionImage.HasFile)
        {
            string ext = System.IO.Path.GetExtension(FileUploadQuestionImage.FileName).ToLower();
            string[] allowedImageExts = { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };
            if (System.Array.IndexOf(allowedImageExts, ext) == -1)
            {
                pageMsg = "不支持的图片类型，允许：" + string.Join(", ", allowedImageExts);
                pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return;
            }
            if (FileUploadQuestionImage.PostedFile.ContentLength > 5 * 1024 * 1024)
            {
                pageMsg = "图片大小不能超过 5MB"; pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return;
            }
            string uploadDir = Server.MapPath("~/upload/questionbank/" + bid + "/");
            if (!System.IO.Directory.Exists(uploadDir))
            {
                System.IO.Directory.CreateDirectory(uploadDir);
            }
            string newFileName = "question_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + new System.Random().Next(1000, 9999) + ext;
            string savePath = System.IO.Path.Combine(uploadDir, newFileName);
            FileUploadQuestionImage.SaveAs(savePath);
            qimage = "upload/questionbank/" + bid + "/" + newFileName;
        }

        // 处理选项图片上传
        string optAImg = SaveOptionImage(bid, FileOptA, "A");
        string optBImg = SaveOptionImage(bid, FileOptB, "B");
        string optCImg = SaveOptionImage(bid, FileOptC, "C");
        string optDImg = SaveOptionImage(bid, FileOptD, "D");

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int maxSort = 0;
                using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM QuestionBankItem WHERE Qbid=@bid", conn))
                { cmdMax.Parameters.AddWithValue("@bid", bid); object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }
                int qScore = 5; int.TryParse(TxtQScore.Text.Trim(), out qScore);
                if (qScore <= 0) qScore = 5;
                using (SqlCommand cmd = new SqlCommand("INSERT INTO QuestionBankItem(Qbid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qfile,Qimage,Qoption_a_img,Qoption_b_img,Qoption_c_img,Qoption_d_img,Qdate) VALUES(@bid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,@file,@image,@aimg,@bimg,@cimg,@dimg,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@bid", bid);
                    cmd.Parameters.AddWithValue("@type", qtype);
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@a", TxtOptA.Text.Trim());
                    cmd.Parameters.AddWithValue("@b", TxtOptB.Text.Trim());
                    cmd.Parameters.AddWithValue("@c", TxtOptC.Text.Trim());
                    cmd.Parameters.AddWithValue("@d", TxtOptD.Text.Trim());
                    cmd.Parameters.AddWithValue("@ans", TxtQAnswer.Text.Trim());
                    cmd.Parameters.AddWithValue("@score", qScore);
                    cmd.Parameters.AddWithValue("@sort", maxSort + 1);
                    cmd.Parameters.AddWithValue("@file", qfile);
                    cmd.Parameters.AddWithValue("@image", qimage);
                    cmd.Parameters.AddWithValue("@aimg", optAImg);
                    cmd.Parameters.AddWithValue("@bimg", optBImg);
                    cmd.Parameters.AddWithValue("@cimg", optCImg);
                    cmd.Parameters.AddWithValue("@dimg", optDImg);
                    cmd.ExecuteNonQuery();
                }
            }
            TxtQContent.Text = ""; TxtOptA.Text = ""; TxtOptB.Text = ""; TxtOptC.Text = ""; TxtOptD.Text = "";
            TxtQAnswer.Text = ""; TxtQScore.Text = "5";
            pageMsg = "题目添加成功";
            if (!string.IsNullOrEmpty(qfile)) pageMsg += "（已上传附件）";
            pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "添加失败: " + ex.Message; pageMsgType = "error"; }
        editBankId = bid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(bid);
    }

    private void LoadQuestionForEdit(int bid, int qid)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT Qid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qfile,Qimage,Qoption_a_img,Qoption_b_img,Qoption_c_img,Qoption_d_img FROM QuestionBankItem WHERE Qid=@qid AND Qbid=@bid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", qid);
                    cmd.Parameters.AddWithValue("@bid", bid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            HiddenEditQid.Value = reader["Qid"].ToString();
                            DDLEditQType.SelectedValue = reader["Qtype"].ToString();
                            TxtEditQContent.Text = reader["Qcontent"].ToString();
                            TxtEditOptA.Text = reader["Qoption_a"] != DBNull.Value ? reader["Qoption_a"].ToString() : "";
                            TxtEditOptB.Text = reader["Qoption_b"] != DBNull.Value ? reader["Qoption_b"].ToString() : "";
                            TxtEditOptC.Text = reader["Qoption_c"] != DBNull.Value ? reader["Qoption_c"].ToString() : "";
                            TxtEditOptD.Text = reader["Qoption_d"] != DBNull.Value ? reader["Qoption_d"].ToString() : "";
                            TxtEditQAnswer.Text = reader["Qanswer"].ToString();
                            TxtEditQScore.Text = reader["Qscore"].ToString();
                            
                            // 显示当前题目图片
                            string qimage = reader["Qimage"] != DBNull.Value ? reader["Qimage"].ToString() : "";
                            if (!string.IsNullOrEmpty(qimage))
                            {
                                editImagePreviewImg.ImageUrl = ResolveUrl("~/" + qimage);
                                editImagePreviewImg.Visible = true;
                                chkDeleteImage.Checked = false;
                            }
                            else
                            {
                                editImagePreviewImg.Visible = false;
                            }
                            
                            // 显示选项图片（通过JavaScript）
                            int optAImgCol = -1, optBImgCol = -1, optCImgCol = -1, optDImgCol = -1;
                            try { optAImgCol = reader.GetOrdinal("Qoption_a_img"); } catch { }
                            try { optBImgCol = reader.GetOrdinal("Qoption_b_img"); } catch { }
                            try { optCImgCol = reader.GetOrdinal("Qoption_c_img"); } catch { }
                            try { optDImgCol = reader.GetOrdinal("Qoption_d_img"); } catch { }
                            
                            string optAImg = (optAImgCol >= 0 && reader[optAImgCol] != DBNull.Value) ? reader[optAImgCol].ToString() : "";
                            string optBImg = (optBImgCol >= 0 && reader[optBImgCol] != DBNull.Value) ? reader[optBImgCol].ToString() : "";
                            string optCImg = (optCImgCol >= 0 && reader[optCImgCol] != DBNull.Value) ? reader[optCImgCol].ToString() : "";
                            string optDImg = (optDImgCol >= 0 && reader[optDImgCol] != DBNull.Value) ? reader[optDImgCol].ToString() : "";
                            
                            string script = "openEditModal();";
                            if (!string.IsNullOrEmpty(optAImg)) script += "showExistingOptImage('previewEditOptA','" + ResolveUrl("~/" + optAImg) + "');";
                            if (!string.IsNullOrEmpty(optBImg)) script += "showExistingOptImage('previewEditOptB','" + ResolveUrl("~/" + optBImg) + "');";
                            if (!string.IsNullOrEmpty(optCImg)) script += "showExistingOptImage('previewEditOptC','" + ResolveUrl("~/" + optCImg) + "');";
                            if (!string.IsNullOrEmpty(optDImg)) script += "showExistingOptImage('previewEditOptD','" + ResolveUrl("~/" + optDImg) + "');";
                            ClientScript.RegisterStartupScript(this.GetType(), "openEditModal", script, true);
                            return;
                        }
                    }
                }
            }
            ClientScript.RegisterStartupScript(this.GetType(), "openEditModal", "openEditModal();", true);
        }
        catch (Exception ex) { pageMsg = "加载题目失败: " + ex.Message; pageMsgType = "error"; }
    }

    protected void BtnSaveEdit_Click(object sender, EventArgs e)
    {
        int qid = 0; int.TryParse(HiddenEditQid.Value, out qid);
        int bid = 0; int.TryParse(HiddenBankId.Value, out bid);
        if (qid <= 0 || bid <= 0) return;
        
        string content = TxtEditQContent.Text.Trim();
        if (string.IsNullOrEmpty(content)) { pageMsg = "请输入题目内容"; pageMsgType = "error"; return; }
        
        string qtype = DDLEditQType.SelectedValue;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        
        try
        {
            // 处理编程题文件上传
            string qfile = "";
            if (IsProgramType(qtype) && FileUploadEditProgram.HasFile)
            {
                if (!IsAllowedProgramFile(FileUploadEditProgram.FileName))
                {
                    pageMsg = "不支持的文件类型，允许：" + string.Join(", ", allowedProgramExts);
                    pageMsgType = "error"; return;
                }
                if (FileUploadEditProgram.PostedFile.ContentLength > 10 * 1024 * 1024)
                {
                    pageMsg = "文件大小不能超过 10MB"; pageMsgType = "error"; return;
                }
                qfile = SaveProgramFile(bid, FileUploadEditProgram);
            }
            
            // 处理题目图片上传
            string qimage = "";
            bool deleteImage = chkDeleteImage.Checked;
            string oldImage = "";
            
            if (FileUploadEditImage.HasFile)
            {
                string ext = System.IO.Path.GetExtension(FileUploadEditImage.FileName).ToLower();
                string[] allowedImageExts = { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };
                if (System.Array.IndexOf(allowedImageExts, ext) == -1)
                {
                    pageMsg = "不支持的图片类型，允许：" + string.Join(", ", allowedImageExts);
                    pageMsgType = "error"; return;
                }
                if (FileUploadEditImage.PostedFile.ContentLength > 5 * 1024 * 1024)
                {
                    pageMsg = "图片大小不能超过 5MB"; pageMsgType = "error"; return;
                }
                string uploadDir = Server.MapPath("~/upload/questionbank/" + bid + "/");
                if (!System.IO.Directory.Exists(uploadDir))
                {
                    System.IO.Directory.CreateDirectory(uploadDir);
                }
                string newFileName = "question_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + new System.Random().Next(1000, 9999) + ext;
                string savePath = System.IO.Path.Combine(uploadDir, newFileName);
                FileUploadEditImage.SaveAs(savePath);
                qimage = "upload/questionbank/" + bid + "/" + newFileName;
            }
            
            // 处理选项图片上传
            string optAImg = SaveOptionImage(bid, FileEditOptA, "A");
            string optBImg = SaveOptionImage(bid, FileEditOptB, "B");
            string optCImg = SaveOptionImage(bid, FileEditOptC, "C");
            string optDImg = SaveOptionImage(bid, FileEditOptD, "D");
            
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // 获取旧图片路径（题目图片和选项图片）
                string oldOptAImg = "", oldOptBImg = "", oldOptCImg = "", oldOptDImg = "";
                if (deleteImage || !string.IsNullOrEmpty(qimage) || !string.IsNullOrEmpty(optAImg) || !string.IsNullOrEmpty(optBImg) || !string.IsNullOrEmpty(optCImg) || !string.IsNullOrEmpty(optDImg))
                {
                    using (SqlCommand cmdOld = new SqlCommand("SELECT Qimage,Qoption_a_img,Qoption_b_img,Qoption_c_img,Qoption_d_img FROM QuestionBankItem WHERE Qid=@qid", conn))
                    {
                        cmdOld.Parameters.AddWithValue("@qid", qid);
                        using (SqlDataReader reader = cmdOld.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                if (reader["Qimage"] != DBNull.Value) oldImage = reader["Qimage"].ToString();
                                
                                int optAImgCol = -1, optBImgCol = -1, optCImgCol = -1, optDImgCol = -1;
                                try { optAImgCol = reader.GetOrdinal("Qoption_a_img"); } catch { }
                                try { optBImgCol = reader.GetOrdinal("Qoption_b_img"); } catch { }
                                try { optCImgCol = reader.GetOrdinal("Qoption_c_img"); } catch { }
                                try { optDImgCol = reader.GetOrdinal("Qoption_d_img"); } catch { }
                                
                                if (optAImgCol >= 0 && reader[optAImgCol] != DBNull.Value) oldOptAImg = reader[optAImgCol].ToString();
                                if (optBImgCol >= 0 && reader[optBImgCol] != DBNull.Value) oldOptBImg = reader[optBImgCol].ToString();
                                if (optCImgCol >= 0 && reader[optCImgCol] != DBNull.Value) oldOptCImg = reader[optCImgCol].ToString();
                                if (optDImgCol >= 0 && reader[optDImgCol] != DBNull.Value) oldOptDImg = reader[optDImgCol].ToString();
                            }
                        }
                    }
                }
                
                // 更新题目
                string sql = "UPDATE QuestionBankItem SET Qtype=@type,Qcontent=@content,Qoption_a=@a,Qoption_b=@b,Qoption_c=@c,Qoption_d=@d,Qanswer=@ans,Qscore=@score";
                if (!string.IsNullOrEmpty(qfile)) sql += ",Qfile=@file";
                if (deleteImage) sql += ",Qimage=NULL";
                else if (!string.IsNullOrEmpty(qimage)) sql += ",Qimage=@image";
                if (!string.IsNullOrEmpty(optAImg)) sql += ",Qoption_a_img=@aimg";
                if (!string.IsNullOrEmpty(optBImg)) sql += ",Qoption_b_img=@bimg";
                if (!string.IsNullOrEmpty(optCImg)) sql += ",Qoption_c_img=@cimg";
                if (!string.IsNullOrEmpty(optDImg)) sql += ",Qoption_d_img=@dimg";
                sql += " WHERE Qid=@qid AND Qbid=@bid";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@type", qtype);
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@a", TxtEditOptA.Text.Trim());
                    cmd.Parameters.AddWithValue("@b", TxtEditOptB.Text.Trim());
                    cmd.Parameters.AddWithValue("@c", TxtEditOptC.Text.Trim());
                    cmd.Parameters.AddWithValue("@d", TxtEditOptD.Text.Trim());
                    cmd.Parameters.AddWithValue("@ans", TxtEditQAnswer.Text.Trim());
                    int qScore = 5; int.TryParse(TxtEditQScore.Text.Trim(), out qScore);
                    if (qScore <= 0) qScore = 5;
                    cmd.Parameters.AddWithValue("@score", qScore);
                    if (!string.IsNullOrEmpty(qfile)) cmd.Parameters.AddWithValue("@file", qfile);
                    if (!string.IsNullOrEmpty(qimage)) cmd.Parameters.AddWithValue("@image", qimage);
                    if (!string.IsNullOrEmpty(optAImg)) cmd.Parameters.AddWithValue("@aimg", optAImg);
                    if (!string.IsNullOrEmpty(optBImg)) cmd.Parameters.AddWithValue("@bimg", optBImg);
                    if (!string.IsNullOrEmpty(optCImg)) cmd.Parameters.AddWithValue("@cimg", optCImg);
                    if (!string.IsNullOrEmpty(optDImg)) cmd.Parameters.AddWithValue("@dimg", optDImg);
                    cmd.Parameters.AddWithValue("@qid", qid);
                    cmd.Parameters.AddWithValue("@bid", bid);
                    cmd.ExecuteNonQuery();
                }
                
                // 删除旧题目图片
                if (deleteImage && !string.IsNullOrEmpty(oldImage))
                {
                    try
                    {
                        string fp = Server.MapPath("~/" + oldImage);
                        if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                    }
                    catch { }
                }
                else if (!string.IsNullOrEmpty(qimage) && !string.IsNullOrEmpty(oldImage))
                {
                    try
                    {
                        string fp = Server.MapPath("~/" + oldImage);
                        if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                    }
                    catch { }
                }
                
                // 删除旧选项图片
                if (!string.IsNullOrEmpty(optAImg) && !string.IsNullOrEmpty(oldOptAImg))
                {
                    try
                    {
                        string fp = Server.MapPath("~/" + oldOptAImg);
                        if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                    }
                    catch { }
                }
                if (!string.IsNullOrEmpty(optBImg) && !string.IsNullOrEmpty(oldOptBImg))
                {
                    try
                    {
                        string fp = Server.MapPath("~/" + oldOptBImg);
                        if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                    }
                    catch { }
                }
                if (!string.IsNullOrEmpty(optCImg) && !string.IsNullOrEmpty(oldOptCImg))
                {
                    try
                    {
                        string fp = Server.MapPath("~/" + oldOptCImg);
                        if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                    }
                    catch { }
                }
                if (!string.IsNullOrEmpty(optDImg) && !string.IsNullOrEmpty(oldOptDImg))
                {
                    try
                    {
                        string fp = Server.MapPath("~/" + oldOptDImg);
                        if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                    }
                    catch { }
                }
            }
            
            pageMsg = "题目修改成功";
            pageMsgType = "success";
            ClientScript.RegisterStartupScript(this.GetType(), "closeEditModal", "closeEditModal();", true);
        }
        catch (Exception ex) { pageMsg = "修改失败: " + ex.Message; pageMsgType = "error"; }
        
        BindQuestions(bid);
    }

    protected void RptQuestions_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int bid = 0; int.TryParse(HiddenBankId.Value, out bid);
        if (bid <= 0) return;
        if (e.CommandName == "DelQuestion")
        {
            int qid = 0; int.TryParse(e.CommandArgument.ToString(), out qid);
            if (qid <= 0) return;
            string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // 先查询关联文件路径
                    string qfile = "";
                    string qimage = "";
                    string optAImg = "", optBImg = "", optCImg = "", optDImg = "";
                    using (SqlCommand cmdF = new SqlCommand("SELECT Qfile, Qimage, Qoption_a_img, Qoption_b_img, Qoption_c_img, Qoption_d_img FROM QuestionBankItem WHERE Qid=@qid AND Qbid=@bid", conn))
                    {
                        cmdF.Parameters.AddWithValue("@qid", qid); cmdF.Parameters.AddWithValue("@bid", bid);
                        using (SqlDataReader reader = cmdF.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                if (reader["Qfile"] != DBNull.Value) qfile = reader["Qfile"].ToString();
                                if (reader["Qimage"] != DBNull.Value) qimage = reader["Qimage"].ToString();
                                
                                int optAImgCol = -1, optBImgCol = -1, optCImgCol = -1, optDImgCol = -1;
                                try { optAImgCol = reader.GetOrdinal("Qoption_a_img"); } catch { }
                                try { optBImgCol = reader.GetOrdinal("Qoption_b_img"); } catch { }
                                try { optCImgCol = reader.GetOrdinal("Qoption_c_img"); } catch { }
                                try { optDImgCol = reader.GetOrdinal("Qoption_d_img"); } catch { }
                                
                                if (optAImgCol >= 0 && reader[optAImgCol] != DBNull.Value) optAImg = reader[optAImgCol].ToString();
                                if (optBImgCol >= 0 && reader[optBImgCol] != DBNull.Value) optBImg = reader[optBImgCol].ToString();
                                if (optCImgCol >= 0 && reader[optCImgCol] != DBNull.Value) optCImg = reader[optCImgCol].ToString();
                                if (optDImgCol >= 0 && reader[optDImgCol] != DBNull.Value) optDImg = reader[optDImgCol].ToString();
                            }
                        }
                    }
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM QuestionBankItem WHERE Qid=@qid AND Qbid=@bid", conn))
                    { cmd.Parameters.AddWithValue("@qid", qid); cmd.Parameters.AddWithValue("@bid", bid); cmd.ExecuteNonQuery(); }
                    // 删除关联文件
                    if (!string.IsNullOrEmpty(qfile))
                    {
                        try
                        {
                            string fp = Server.MapPath("~/" + qfile);
                            if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                        }
                        catch { }
                    }
                    // 删除关联图片
                    if (!string.IsNullOrEmpty(qimage))
                    {
                        try
                        {
                            string fp = Server.MapPath("~/" + qimage);
                            if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                        }
                        catch { }
                    }
                    // 删除选项图片
                    if (!string.IsNullOrEmpty(optAImg))
                    {
                        try
                        {
                            string fp = Server.MapPath("~/" + optAImg);
                            if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                        }
                        catch { }
                    }
                    if (!string.IsNullOrEmpty(optBImg))
                    {
                        try
                        {
                            string fp = Server.MapPath("~/" + optBImg);
                            if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                        }
                        catch { }
                    }
                    if (!string.IsNullOrEmpty(optCImg))
                    {
                        try
                        {
                            string fp = Server.MapPath("~/" + optCImg);
                            if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                        }
                        catch { }
                    }
                    if (!string.IsNullOrEmpty(optDImg))
                    {
                        try
                        {
                            string fp = Server.MapPath("~/" + optDImg);
                            if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp);
                        }
                        catch { }
                    }
                }
                pageMsg = "题目已删除"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; pageMsgType = "error"; }
        }
        else if (e.CommandName == "MoveUp" || e.CommandName == "MoveDown")
        {
            int qid = 0; int.TryParse(e.CommandArgument.ToString(), out qid);
            if (qid <= 0) return;
            MoveQuestion(bid, qid, e.CommandName == "MoveUp" ? -1 : 1);
        }
        else if (e.CommandName == "EditQuestion")
        {
            int qid = 0; int.TryParse(e.CommandArgument.ToString(), out qid);
            if (qid <= 0) return;
            LoadQuestionForEdit(bid, qid);
        }
        editBankId = bid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(bid);
    }

    private void MoveQuestion(int bid, int qid, int direction)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter("SELECT Qid,Qsort FROM QuestionBankItem WHERE Qbid=@bid ORDER BY Qsort,Qid", conn))
                { da.SelectCommand.Parameters.AddWithValue("@bid", bid); da.Fill(dt); }
                int idx = -1;
                for (int i = 0; i < dt.Rows.Count; i++)
                { if (Convert.ToInt32(dt.Rows[i]["Qid"]) == qid) { idx = i; break; } }
                int target = idx + direction;
                if (idx < 0 || target < 0 || target >= dt.Rows.Count) return;
                int qid1 = Convert.ToInt32(dt.Rows[idx]["Qid"]);
                int sort1 = Convert.ToInt32(dt.Rows[idx]["Qsort"]);
                int qid2 = Convert.ToInt32(dt.Rows[target]["Qid"]);
                int sort2 = Convert.ToInt32(dt.Rows[target]["Qsort"]);
                if (sort1 == sort2) sort2 = sort1 + direction;
                using (SqlCommand cmd = new SqlCommand("UPDATE QuestionBankItem SET Qsort=@s WHERE Qid=@qid", conn))
                { cmd.Parameters.AddWithValue("@s", sort2); cmd.Parameters.AddWithValue("@qid", qid1); cmd.ExecuteNonQuery(); }
                using (SqlCommand cmd = new SqlCommand("UPDATE QuestionBankItem SET Qsort=@s WHERE Qid=@qid", conn))
                { cmd.Parameters.AddWithValue("@s", sort1); cmd.Parameters.AddWithValue("@qid", qid2); cmd.ExecuteNonQuery(); }
            }
        }
        catch { }
    }

    protected void BtnImportQuestions_Click(object sender, EventArgs e)
    {
        int bid = 0; int.TryParse(HiddenBankId.Value, out bid);
        if (bid <= 0) return;
        if (!FileUploadImport.HasFile) { pageMsg = "请选择要导入的文件"; pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return; }
        string ext = System.IO.Path.GetExtension(FileUploadImport.FileName).ToLower();
        if (ext != ".txt" && ext != ".csv") { pageMsg = "仅支持 .txt 或 .csv 文件"; pageMsgType = "error"; editBankId = bid; PanelList.Visible = false; PanelEdit.Visible = true; BindQuestions(bid); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            string content = System.Text.Encoding.UTF8.GetString(FileUploadImport.FileBytes);
            if (content.Length > 0 && content[0] == '\uFEFF') content = content.Substring(1);
            string[] lines = content.Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
            int added = 0;
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int maxSort = 0;
                using (SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(Qsort),0) FROM QuestionBankItem WHERE Qbid=@bid", conn))
                { cmdMax.Parameters.AddWithValue("@bid", bid); object v = cmdMax.ExecuteScalar(); if (v != null && v != DBNull.Value) maxSort = Convert.ToInt32(v); }

                string curType = "single", curContent = "", curA = "", curB = "", curC = "", curD = "", curAnswer = "";
                int curScore = 5;
                bool inBlock = false;

                for (int i = 0; i <= lines.Length; i++)
                {
                    string line = (i < lines.Length) ? lines[i].Trim() : "";
                    if (string.IsNullOrEmpty(line) || i == lines.Length)
                    {
                        if (inBlock && !string.IsNullOrEmpty(curContent))
                        {
                            maxSort++;
                            using (SqlCommand cmd = new SqlCommand("INSERT INTO QuestionBankItem(Qbid,Qtype,Qcontent,Qoption_a,Qoption_b,Qoption_c,Qoption_d,Qanswer,Qscore,Qsort,Qdate) VALUES(@bid,@type,@content,@a,@b,@c,@d,@ans,@score,@sort,GETDATE())", conn))
                            {
                                cmd.Parameters.AddWithValue("@bid", bid);
                                cmd.Parameters.AddWithValue("@type", curType);
                                cmd.Parameters.AddWithValue("@content", curContent);
                                cmd.Parameters.AddWithValue("@a", curA);
                                cmd.Parameters.AddWithValue("@b", curB);
                                cmd.Parameters.AddWithValue("@c", curC);
                                cmd.Parameters.AddWithValue("@d", curD);
                                cmd.Parameters.AddWithValue("@ans", curAnswer);
                                cmd.Parameters.AddWithValue("@score", curScore);
                                cmd.Parameters.AddWithValue("@sort", maxSort);
                                cmd.ExecuteNonQuery();
                                added++;
                            }
                        }
                        curType = "single"; curContent = ""; curA = ""; curB = ""; curC = ""; curD = ""; curAnswer = ""; curScore = 5;
                        inBlock = false;
                        continue;
                    }
                    inBlock = true;
                    if (line.StartsWith("题型:") || line.StartsWith("题型：")) { curType = line.Substring(3).Trim(); }
                    else if (line.StartsWith("题目:") || line.StartsWith("题目：")) { curContent = line.Substring(3).Trim(); }
                    else if (line.StartsWith("A:") || line.StartsWith("A：")) { curA = line.Substring(2).Trim(); }
                    else if (line.StartsWith("B:") || line.StartsWith("B：")) { curB = line.Substring(2).Trim(); }
                    else if (line.StartsWith("C:") || line.StartsWith("C：")) { curC = line.Substring(2).Trim(); }
                    else if (line.StartsWith("D:") || line.StartsWith("D：")) { curD = line.Substring(2).Trim(); }
                    else if (line.StartsWith("答案:") || line.StartsWith("答案：")) { curAnswer = line.Substring(3).Trim(); }
                    else if (line.StartsWith("分值:") || line.StartsWith("分值：")) { int.TryParse(line.Substring(3).Trim(), out curScore); if (curScore <= 0) curScore = 5; }
                }
                using (SqlCommand cmdCnt = new SqlCommand("UPDATE QuestionBankList SET Bcount=(SELECT COUNT(*) FROM QuestionBankItem WHERE Qbid=@bid) WHERE Bid=@bid", conn))
                { cmdCnt.Parameters.AddWithValue("@bid", bid); cmdCnt.ExecuteNonQuery(); }
            }
            pageMsg = "成功导入 " + added + " 道题目"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "导入失败: " + ex.Message; pageMsgType = "error"; }
        editBankId = bid;
        PanelList.Visible = false;
        PanelEdit.Visible = true;
        BindQuestions(bid);
    }

    protected string GetTypeName(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "未知";
        switch (typeVal.ToString())
        {
            case "single": return "单选题";
            case "multiple": return "多选题";
            case "truefalse": return "判断题";
            case "fill": return "填空题";
            case "essay": return "简答题";
            case "scratch": return "Scratch编程";
            case "python": return "Python编程";
            case "pythonblock": return "Python拼图";
            case "web": return "Web编程";
            case "cpp": return "C/C++编程";
            case "program": return "编程题";
            default: return typeVal.ToString();
        }
    }
    protected string GetTypeColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "#94a3b8";
        switch (typeVal.ToString())
        {
            case "single": return "#6366f1";
            case "multiple": return "#8b5cf6";
            case "truefalse": return "#0891b2";
            case "fill": return "#059669";
            case "essay": return "#d97706";
            case "scratch": return "#f97316";
            case "python": return "#3b82f6";
            case "pythonblock": return "#047857";
            case "web": return "#ec4899";
            case "cpp": return "#6366f1";
            case "program": return "#f97316";
            default: return "#94a3b8";
        }
    }
    protected string GetTypeBgColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value) return "#f1f5f9";
        switch (typeVal.ToString())
        {
            case "single": return "#eef2ff";
            case "multiple": return "#f5f3ff";
            case "truefalse": return "#ecfeff";
            case "fill": return "#ecfdf5";
            case "essay": return "#fffbeb";
            case "scratch": return "#fff7ed";
            case "python": return "#eff6ff";
            case "pythonblock": return "#ecfdf5";
            case "web": return "#fdf2f8";
            case "cpp": return "#eef2ff";
            case "program": return "#fff7ed";
            default: return "#f1f5f9";
        }
    }
    protected string GetFileDisplayName(object fileVal)
    {
        if (fileVal == null || fileVal == DBNull.Value) return "";
        string path = fileVal.ToString();
        if (string.IsNullOrEmpty(path)) return "";
        int idx = path.LastIndexOf('/');
        return idx >= 0 ? path.Substring(idx + 1) : path;
    }
    protected string GetFileUrl(object fileVal)
    {
        if (fileVal == null || fileVal == DBNull.Value) return "";
        string path = fileVal.ToString();
        if (string.IsNullOrEmpty(path)) return "";
        return ResolveUrl("~/" + path);
    }
    protected bool HasFile(object fileVal)
    {
        if (fileVal == null || fileVal == DBNull.Value) return false;
        return fileVal.ToString().Trim().Length > 0;
    }
    protected bool HasImage(object imageVal)
    {
        if (imageVal == null || imageVal == DBNull.Value) return false;
        return imageVal.ToString().Trim().Length > 0;
    }
    protected string GetImageUrl(object imageVal)
    {
        if (imageVal == null || imageVal == DBNull.Value) return "";
        string path = imageVal.ToString();
        if (string.IsNullOrEmpty(path)) return "";
        return ResolveUrl("~/" + path);
    }
    protected string FormatDate(object dateVal)
    {
        if (dateVal == null || dateVal == DBNull.Value) return "";
        try { return Convert.ToDateTime(dateVal).ToString("yyyy-MM-dd HH:mm"); } catch { return ""; }
    }
    protected string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }
    protected string GetBankTypeName(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value || typeVal.ToString().Trim().Length == 0) return "综合题库";
        switch (typeVal.ToString())
        {
            case "mixed": return "综合题库";
            case "choice": return "选择题";
            case "truefalse": return "判断题";
            case "fill": return "填空题";
            case "program": return "编程题";
            case "essay": return "简答题";
            default: return typeVal.ToString();
        }
    }
    protected string GetBankTypeColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value || typeVal.ToString().Trim().Length == 0) return "#059669";
        switch (typeVal.ToString())
        {
            case "mixed": return "#059669";
            case "choice": return "#6366f1";
            case "truefalse": return "#0891b2";
            case "fill": return "#d97706";
            case "program": return "#f97316";
            case "essay": return "#8b5cf6";
            default: return "#94a3b8";
        }
    }
    protected string GetBankTypeBgColor(object typeVal)
    {
        if (typeVal == null || typeVal == DBNull.Value || typeVal.ToString().Trim().Length == 0) return "#ecfdf5";
        switch (typeVal.ToString())
        {
            case "mixed": return "#ecfdf5";
            case "choice": return "#eef2ff";
            case "truefalse": return "#ecfeff";
            case "fill": return "#fffbeb";
            case "program": return "#fff7ed";
            case "essay": return "#f5f3ff";
            default: return "#f1f5f9";
        }
    }
    protected string FormatOptions(object a, object b, object c, object d)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        if (a != null && a != DBNull.Value && a.ToString().Trim().Length > 0) sb.Append("A. " + Server.HtmlEncode(a.ToString()) + "&emsp;");
        if (b != null && b != DBNull.Value && b.ToString().Trim().Length > 0) sb.Append("B. " + Server.HtmlEncode(b.ToString()) + "&emsp;");
        if (c != null && c != DBNull.Value && c.ToString().Trim().Length > 0) sb.Append("C. " + Server.HtmlEncode(c.ToString()) + "&emsp;");
        if (d != null && d != DBNull.Value && d.ToString().Trim().Length > 0) sb.Append("D. " + Server.HtmlEncode(d.ToString()));
        return sb.ToString();
    }
    
    protected string FormatOptionsWithImages(object a, object b, object c, object d, object aImg, object bImg, object cImg, object dImg)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<div style='display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;'>");
        
        if (a != null && a != DBNull.Value && a.ToString().Trim().Length > 0)
        {
            sb.Append("<div style='display:flex;flex-direction:column;gap:6px;'>");
            sb.Append("<div style='font-weight:600;color:#059669;'>A. " + Server.HtmlEncode(a.ToString()) + "</div>");
            if (aImg != null && aImg != DBNull.Value && aImg.ToString().Trim().Length > 0)
            {
                sb.Append("<img src='" + ResolveUrl("~/" + aImg.ToString()) + "' style='max-width:100%;max-height:120px;border-radius:6px;border:1px solid #e2e8f0;' />");
            }
            sb.Append("</div>");
        }
        
        if (b != null && b != DBNull.Value && b.ToString().Trim().Length > 0)
        {
            sb.Append("<div style='display:flex;flex-direction:column;gap:6px;'>");
            sb.Append("<div style='font-weight:600;color:#059669;'>B. " + Server.HtmlEncode(b.ToString()) + "</div>");
            if (bImg != null && bImg != DBNull.Value && bImg.ToString().Trim().Length > 0)
            {
                sb.Append("<img src='" + ResolveUrl("~/" + bImg.ToString()) + "' style='max-width:100%;max-height:120px;border-radius:6px;border:1px solid #e2e8f0;' />");
            }
            sb.Append("</div>");
        }
        
        if (c != null && c != DBNull.Value && c.ToString().Trim().Length > 0)
        {
            sb.Append("<div style='display:flex;flex-direction:column;gap:6px;'>");
            sb.Append("<div style='font-weight:600;color:#059669;'>C. " + Server.HtmlEncode(c.ToString()) + "</div>");
            if (cImg != null && cImg != DBNull.Value && cImg.ToString().Trim().Length > 0)
            {
                sb.Append("<img src='" + ResolveUrl("~/" + cImg.ToString()) + "' style='max-width:100%;max-height:120px;border-radius:6px;border:1px solid #e2e8f0;' />");
            }
            sb.Append("</div>");
        }
        
        if (d != null && d != DBNull.Value && d.ToString().Trim().Length > 0)
        {
            sb.Append("<div style='display:flex;flex-direction:column;gap:6px;'>");
            sb.Append("<div style='font-weight:600;color:#059669;'>D. " + Server.HtmlEncode(d.ToString()) + "</div>");
            if (dImg != null && dImg != DBNull.Value && dImg.ToString().Trim().Length > 0)
            {
                sb.Append("<img src='" + ResolveUrl("~/" + dImg.ToString()) + "' style='max-width:100%;max-height:120px;border-radius:6px;border:1px solid #e2e8f0;' />");
            }
            sb.Append("</div>");
        }
        
        sb.Append("</div>");
        return sb.ToString();
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .pp-page { max-width: 1400px; width: 100%; margin: 0 auto; }
    .pp-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; }
    .pp-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .pp-title-icon { width: 42px; height: 42px; background: linear-gradient(135deg, #059669, #10b981); border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(5,150,105,0.25); }
    .pp-title-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 54px; }
    .pp-msg { padding: 12px 18px; border-radius: 10px; font-size: 13px; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .pp-msg svg { width: 18px; height: 18px; flex-shrink: 0; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-msg-info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
    .pp-msg-info svg { stroke: #3b82f6; fill: none; }
    .pp-msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .pp-msg-success svg { stroke: #22c55e; fill: none; }
    .pp-msg-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .pp-msg-error svg { stroke: #ef4444; fill: none; }
    .pp-card { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.02); margin-bottom: 20px; overflow: hidden; }
    .pp-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; background: linear-gradient(180deg, #fafbfc, #f8f9fb); font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 10px; }
    .pp-card-head svg { width: 20px; height: 20px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-card-body { padding: 24px; }
    .pp-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 20px; }
    .pp-form-full { grid-column: 1 / -1; }
    .pp-form-group { display: flex; flex-direction: column; gap: 8px; position:relative; }
    .pp-form-group label { 
        font-size: 13px; 
        font-weight: 600; 
        color: #475569; 
        letter-spacing: 0.2px;
        display:flex;
        align-items:center;
        gap:6px;
    }
    .pp-form-group label::before {
        content:'';
        width:3px;
        height:14px;
        background:linear-gradient(180deg, #3b82f6, #8b5cf6);
        border-radius:2px;
    }
    .pp-form-group input[type="text"], .pp-form-group textarea, .pp-form-group select {
        padding: 12px 16px; 
        border-radius: 12px; 
        border: 2px solid #e2e8f0; 
        font-size: 14px; 
        color: #1e293b;
        background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); 
        outline: none; 
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
        font-family: inherit; 
        resize: vertical;
        box-shadow: 0 1px 3px rgba(0,0,0,0.02);
    }
    .pp-form-group input[type="text"]:hover, .pp-form-group textarea:hover, .pp-form-group select:hover {
        border-color: #cbd5e1;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
    .pp-form-group input[type="text"]:focus, .pp-form-group textarea:focus, .pp-form-group select:focus {
        border-color: #3b82f6; 
        background: #fff; 
        box-shadow: 0 0 0 4px rgba(59,130,246,0.1), 0 4px 12px rgba(59,130,246,0.15);
        transform: translateY(-1px);
    }
    .pp-form-group textarea { min-height: 90px; line-height:1.6; }
    .pp-btn { 
        display: inline-flex; 
        align-items: center; 
        justify-content: center; 
        gap: 8px; 
        padding: 12px 28px; 
        border-radius: 12px; 
        font-size: 14px; 
        font-weight: 600; 
        border: none; 
        cursor: pointer; 
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
        font-family: inherit; 
        text-decoration: none;
        position:relative;
        overflow:hidden;
    }
    .pp-btn::before {
        content:'';
        position:absolute;
        top:50%;
        left:50%;
        width:0;
        height:0;
        border-radius:50%;
        background:rgba(255,255,255,0.3);
        transform:translate(-50%, -50%);
        transition:width 0.6s, height 0.6s;
    }
    .pp-btn:hover::before {
        width:300px;
        height:300px;
    }
    .pp-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.15); }
    .pp-btn:active { transform: translateY(0); }
    .pp-btn-primary { background: linear-gradient(135deg, #059669, #10b981); color: #fff; box-shadow: 0 4px 14px rgba(5,150,105,0.3); }
    .pp-btn-primary:hover { box-shadow: 0 8px 24px rgba(5,150,105,0.4); }
    .pp-btn-success { background: linear-gradient(135deg, #059669, #10b981); color: #fff; box-shadow: 0 4px 14px rgba(5,150,105,0.3); }
    .pp-list { display: flex; flex-direction: column; gap: 12px; }
    .pp-item { display: flex; align-items: center; padding: 18px 22px; border-radius: 12px; border: 1px solid #f1f5f9; background: #fff; transition: all 0.2s; gap: 20px; }
    .pp-item:hover { border-color: #a7f3d0; box-shadow: 0 4px 16px rgba(5,150,105,0.08); transform: translateY(-1px); }
    .pp-item-icon { width: 48px; height: 48px; background: linear-gradient(135deg, #ecfdf5, #d1fae5); border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .pp-item-icon svg { width: 24px; height: 24px; stroke: #059669; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
    .pp-item-info { flex: 1; min-width: 0; }
    .pp-item-title { font-size: 15px; font-weight: 600; color: #1e293b; margin-bottom: 6px; }
    .pp-item-meta { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .pp-item-meta-tag { font-size: 12px; color: #64748b; display: flex; align-items: center; gap: 4px; }
    .pp-item-meta-tag svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-item-actions { display: flex; gap: 6px; flex-shrink: 0; align-items: center; }
    .pp-act-btn { display: inline-flex; align-items: center; justify-content: center; gap: 4px; padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.15s; text-decoration: none; font-family: inherit; }
    .pp-act-btn:hover { background: #f1f5f9; border-color: #cbd5e1; }
    .pp-act-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-act-btn-edit { color: #059669; border-color: #a7f3d0; }
    .pp-act-btn-edit:hover { background: #ecfdf5; }
    .pp-act-btn-del { color: #ef4444; border-color: #fecaca; }
    .pp-act-btn-del:hover { background: #fef2f2; }
    .pp-empty { text-align: center; padding: 60px 20px; }
    .pp-empty-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #f1f5f9, #e2e8f0); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
    .pp-empty-icon svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .pp-empty-text { font-size: 15px; color: #64748b; font-weight: 500; }
    .pp-empty-hint { font-size: 13px; color: #94a3b8; margin-top: 6px; }
    .pp-back-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 500; color: #64748b; background: #f1f5f9; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.15s; margin-bottom: 16px; text-decoration: none; font-family: inherit; }
    .pp-back-btn:hover { background: #e2e8f0; color: #334155; }
    .pp-back-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-list { display: flex; flex-direction: column; gap: 14px; }
    .pp-q-item { padding: 18px 22px; border-radius: 12px; border: 1px solid #f1f5f9; background: #fafbfc; transition: all 0.2s; }
    .pp-q-item:hover { border-color: #d1fae5; background: #fff; }
    .pp-q-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; }
    .pp-q-num { display: inline-flex; align-items: center; gap: 8px; }
    .pp-q-badge { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
    .pp-q-score-tag { font-size: 12px; font-weight: 700; color: #f59e0b; background: #fffbeb; padding: 2px 10px; border-radius: 6px; }
    .pp-q-content { font-size: 14px; color: #1e293b; line-height: 1.7; margin-bottom: 8px; word-break: break-word; }
    .pp-q-options { font-size: 13px; color: #475569; line-height: 1.8; padding: 8px 14px; background: #f8fafc; border-radius: 8px; margin-bottom: 8px; }
    .pp-q-answer { font-size: 12px; color: #059669; background: #ecfdf5; padding: 6px 12px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px; }
    .pp-q-answer svg { width: 14px; height: 14px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-file { display: inline-flex; align-items: center; gap: 6px; margin-top: 8px; padding: 5px 12px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 6px; }
    .pp-q-file a:hover { text-decoration: underline; }
    .pp-q-actions { display: flex; gap: 4px; }
    .pp-q-act { display: inline-flex; align-items: center; justify-content: center; width: 30px; height: 30px; border-radius: 6px; border: 1px solid #e2e8f0; background: #fff; color: #64748b; cursor: pointer; transition: all 0.15s; text-decoration: none; font-size: 12px; }
    .pp-q-act:hover { background: #f1f5f9; border-color: #cbd5e1; color: #334155; transform: translateY(-1px); box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    .pp-q-act svg { stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-q-act-del { color: #ef4444; border-color: #fecaca; }
    .pp-q-act-del:hover { background: #fef2f2; border-color: #f87171; }
    .pp-q-act-edit { color: #3b82f6; border-color: #bfdbfe; }
    .pp-q-act-edit:hover { background: #eff6ff; border-color: #60a5fa; }
    .pp-q-act-up { color: #10b981; border-color: #a7f3d0; }
    .pp-q-act-up:hover { background: #ecfdf5; border-color: #34d399; }
    .pp-q-act-down { color: #f59e0b; border-color: #fde68a; }
    .pp-q-act-down:hover { background: #fffbeb; border-color: #fbbf24; }
    .pp-add-q-area { padding: 24px; background: linear-gradient(180deg, #f8f9fb, #f1f5f9); border-top: 1px solid #e8ecf1; }
    .pp-add-q-title { font-size: 15px; font-weight: 600; color: #334155; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .pp-add-q-title svg { width: 20px; height: 20px; stroke: #059669; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-opt-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .pp-opt-img-btn { 
        display: inline-flex; align-items: center; justify-content: center; 
        width: 24px; height: 24px; padding: 0; 
        background: linear-gradient(135deg, #fef3c7, #fde68a); 
        border: 1.5px solid #fbbf24; border-radius: 6px; 
        cursor: pointer; transition: all 0.2s; 
    }
    .pp-opt-img-btn svg { stroke: #f59e0b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-opt-img-btn:hover { 
        background: linear-gradient(135deg, #fde68a, #fcd34d); 
        border-color: #f59e0b; 
        transform: scale(1.1); 
        box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3); 
    }
    .pp-opt-preview { 
        margin-top: 8px; padding: 8px; 
        background: #fffbeb; border: 1.5px dashed #fbbf24; border-radius: 8px; 
        display: none; position: relative; 
    }
    .pp-opt-preview.active { display: block; }
    .pp-opt-preview img { 
        max-width: 100%; height: auto; max-height: 120px; 
        border-radius: 6px; display: block; margin: 0 auto; 
    }
    .pp-opt-preview-close { 
        position: absolute; top: 4px; right: 4px; 
        width: 20px; height: 20px; 
        background: #ef4444; color: #fff; 
        border: none; border-radius: 50%; 
        cursor: pointer; font-size: 14px; line-height: 1; 
        display: flex; align-items: center; justify-content: center; 
        transition: all 0.2s; 
    }
    .pp-opt-preview-close:hover { background: #dc2626; transform: scale(1.1); }
    .pp-tool-row { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
    .pp-tool-btn { display: inline-flex; align-items: center; gap: 6px; padding: 10px 20px; border-radius: 10px; font-size: 13px; font-weight: 600; border: 1.5px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.2s; font-family: inherit; }
    .pp-tool-btn:hover { border-color: #34d399; color: #059669; background: #ecfdf5; transform: translateY(-1px); }
    .pp-tool-btn svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-tool-btn-ai { border-color: #c084fc; color: #7c3aed; }
    .pp-tool-btn-ai:hover { border-color: #a855f7; background: #faf5ff; color: #6d28d9; }
    .pp-tool-btn-paper { border-color: #93c5fd; color: #2563eb; }
    .pp-tool-btn-paper:hover { border-color: #60a5fa; background: #eff6ff; color: #1d4ed8; }
    .pp-tool-btn-excel { border-color: #86efac; color: #059669; }
    .pp-tool-btn-excel:hover { border-color: #4ade80; background: #f0fdf4; color: #047857; }
    .pp-panel { padding: 20px; border-radius: 12px; border: 1.5px solid #e2e8f0; margin-bottom: 18px; width: 100%; box-sizing: border-box; }
    .pp-panel-import { background: linear-gradient(135deg, #f0fdf4, #ecfdf5); border-color: #86efac; }
    .pp-panel-ai { background: linear-gradient(135deg, #faf5ff, #f5f3ff); border-color: #c4b5fd; }
    .pp-panel-excel { background: linear-gradient(135deg, #f0fdf4, #ecfdf5); border-color: #86efac; }
    .pp-panel-topaper { background: linear-gradient(135deg, #eff6ff, #dbeafe); border-color: #93c5fd; }
    .pp-panel-title { font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 14px; display: flex; align-items: center; gap: 8px; white-space: nowrap; }
    .pp-panel-title svg { width: 18px; height: 18px; min-width: 18px; flex-shrink: 0; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-import-hint { font-size: 12px; color: #64748b; line-height: 1.8; background: #fff; padding: 12px 16px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 14px; }
    .pp-import-hint code { background: #f1f5f9; padding: 1px 6px; border-radius: 4px; font-size: 11px; color: #334155; }
    .pp-ai-result { margin-top: 14px; padding: 14px; background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; max-height: 300px; overflow-y: auto; display: none; }
    .pp-ai-result-item { padding: 8px 12px; border-radius: 8px; background: #f8fafc; margin-bottom: 6px; font-size: 13px; color: #334155; border: 1px solid #f1f5f9; }
    .pp-ai-loading { display: none; align-items: center; gap: 6px; padding: 0; margin: 0; font-size: 13px; color: #7c3aed; white-space: nowrap; background: none !important; border: none !important; box-shadow: none !important; }
    .pp-ai-loading.show { display: inline-flex; }
    .pp-ai-spinner { width: 16px; height: 16px; min-width: 16px; flex-shrink: 0; border: 2px solid #e9d5ff; border-top-color: #7c3aed; border-radius: 50%; animation: pp-spin 0.8s linear infinite; background: transparent !important; box-shadow: none !important; box-sizing: border-box; }
    @keyframes pp-spin { to { transform: rotate(360deg); } }
    .pp-kw-list { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 12px; }
    .pp-kw-tag { display: inline-flex; align-items: center; padding: 5px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; background: #f5f3ff; border: 1px solid #ddd6fe; color: #7c3aed; cursor: pointer; transition: all 0.15s; }
    .pp-kw-tag:hover { background: #ede9fe; border-color: #c4b5fd; }
    .pp-kw-tag.active { background: #7c3aed; color: #fff; border-color: #7c3aed; }
    /* 知识库选择 */
    .pp-kb-area { margin-bottom: 16px; }
    .pp-kb-label { font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.3px; margin-bottom: 8px; display: flex; align-items: center; gap: 6px; }
    .pp-kb-label svg { width: 15px; height: 15px; stroke: #7c3aed; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .pp-kb-tags { display: flex; flex-wrap: wrap; gap: 6px; }
    .pp-kb-tag { display: inline-flex; align-items: center; gap: 5px; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; background: #fff; border: 1.5px solid #e2e8f0; color: #475569; cursor: pointer; transition: all 0.18s; user-select: none; }
    .pp-kb-tag:hover { border-color: #c4b5fd; background: #faf5ff; color: #7c3aed; }
    .pp-kb-tag.selected { border-color: #7c3aed; background: #f5f3ff; color: #7c3aed; font-weight: 600; }
    .pp-kb-tag.selected::before { content: '\2713'; font-size: 11px; font-weight: 700; color: #7c3aed; }
    .pp-kb-tag .pp-kb-ext { font-size: 10px; padding: 1px 5px; border-radius: 4px; background: #f1f5f9; color: #94a3b8; font-weight: 500; }
    .pp-kb-tag.selected .pp-kb-ext { background: #ede9fe; color: #7c3aed; }
    .pp-kb-empty { font-size: 12px; color: #94a3b8; font-style: italic; padding: 8px 0; }
    .pp-kb-loading { font-size: 12px; color: #7c3aed; display: flex; align-items: center; gap: 6px; padding: 8px 0; }
    /* 导入到试卷对话框 */
    .pp-modal-mask { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:9998; }
    .pp-modal-mask { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15,23,42,0.6); backdrop-filter:blur(8px); z-index:9998; animation:fadeIn 0.3s ease; }
    .pp-modal-mask.show { display:flex; align-items:center; justify-content:center; }
    .pp-modal { 
        background:linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); 
        border-radius:24px; 
        width:700px; 
        max-width:90vw; 
        max-height:85vh; 
        overflow:hidden; 
        box-shadow:0 25px 80px rgba(0,0,0,0.2), 0 0 1px rgba(0,0,0,0.1); 
        border:1px solid rgba(255,255,255,0.8);
        animation:modalSlideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        position:relative;
    }
    .pp-modal::before {
        content:'';
        position:absolute;
        top:0;
        left:0;
        right:0;
        height:4px;
        background:linear-gradient(90deg, #3b82f6, #8b5cf6, #ec4899, #f59e0b);
        background-size:200% 100%;
        animation:gradientShift 3s ease infinite;
    }
    .pp-modal-hd { 
        padding:24px 28px; 
        background:linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
        border-bottom:1px solid #e2e8f0; 
        font-size:18px; 
        font-weight:700; 
        color:#0f172a; 
        display:flex; 
        align-items:center; 
        justify-content:space-between;
        position:relative;
    }
    .pp-modal-hd::after {
        content:'';
        position:absolute;
        bottom:-1px;
        left:28px;
        right:28px;
        height:2px;
        background:linear-gradient(90deg, transparent, #3b82f6, transparent);
        opacity:0.3;
    }
    .pp-modal-close { 
        width:36px; 
        height:36px; 
        border-radius:10px; 
        border:none; 
        background:linear-gradient(135deg, #f1f5f9, #e2e8f0); 
        color:#64748b; 
        cursor:pointer; 
        font-size:20px; 
        display:flex; 
        align-items:center; 
        justify-content:center;
        transition:all 0.2s;
        box-shadow:0 2px 8px rgba(0,0,0,0.05);
    }
    .pp-modal-close:hover { 
        background:linear-gradient(135deg, #ef4444, #dc2626); 
        color:#fff;
        transform:rotate(90deg) scale(1.1);
        box-shadow:0 4px 12px rgba(239,68,68,0.3);
    }
    .pp-modal-bd { 
        padding:28px; 
        max-height:calc(85vh - 180px); 
        overflow-y:auto;
        background:#ffffff;
    }
    .pp-modal-bd::-webkit-scrollbar { width:8px; }
    .pp-modal-bd::-webkit-scrollbar-track { background:#f1f5f9; border-radius:4px; }
    .pp-modal-bd::-webkit-scrollbar-thumb { background:linear-gradient(180deg, #cbd5e1, #94a3b8); border-radius:4px; }
    .pp-modal-bd::-webkit-scrollbar-thumb:hover { background:linear-gradient(180deg, #94a3b8, #64748b); }
    .pp-modal-ft { 
        padding:20px 28px; 
        background:linear-gradient(135deg, #fafbfc 0%, #f8fafc 100%);
        border-top:1px solid #e2e8f0; 
        display:flex; 
        justify-content:flex-end; 
        gap:12px;
        box-shadow:0 -4px 12px rgba(0,0,0,0.02);
    }
    @keyframes fadeIn {
        from { opacity:0; }
        to { opacity:1; }
    }
    @keyframes modalSlideUp {
        from { 
            opacity:0; 
            transform:translateY(30px) scale(0.95); 
        }
        to { 
            opacity:1; 
            transform:translateY(0) scale(1); 
        }
    }
    @keyframes gradientShift {
        0%, 100% { background-position:0% 50%; }
        50% { background-position:100% 50%; }
    }
    .pp-paper-select { width:100%; padding:10px 14px; border-radius:10px; border:1.5px solid #e2e8f0; font-size:13.5px; margin-bottom:14px; outline:none; }
    .pp-paper-select:focus { border-color:#60a5fa; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }
    .pp-qsel-list { max-height:300px; overflow-y:auto; }
    .pp-qsel-item { display:flex; align-items:flex-start; gap:10px; padding:10px 12px; border-radius:8px; border:1px solid #f1f5f9; margin-bottom:6px; font-size:13px; cursor:pointer; transition:all 0.15s; }
    .pp-qsel-item:hover { background:#f8fafc; border-color:#e2e8f0; }
    .pp-qsel-item input[type="checkbox"] { margin-top:2px; accent-color:#2563eb; }
    .pp-qsel-item-type { font-size:11px; font-weight:600; padding:2px 8px; border-radius:4px; white-space:nowrap; }
    @media (max-width: 768px) {
        .pp-form-grid { grid-template-columns: 1fr; }
        .pp-opt-grid { grid-template-columns: 1fr; }
        .pp-item { flex-direction: column; align-items: flex-start; }
        .pp-item-actions { width: 100%; justify-content: flex-end; margin-top: 10px; }
    }
</style>

<div class="pp-page">
    <asp:HiddenField ID="HiddenBankId" runat="server" Value="" />

    <div class="pp-header">
        <div>
            <div class="pp-title">
                <span class="pp-title-icon">
                    <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>
                </span>
                题库管理
            </div>
            <div class="pp-subtitle">创建和管理题单，批量添加题目，支持 AI 智能出题和多格式导入</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="pp-msg pp-msg-<%= pageMsgType %>">
        <% if (pageMsgType == "success") { %>
        <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <% } else if (pageMsgType == "error") { %>
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <% } else { %>
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <% } %>
        <%= Server.HtmlEncode(pageMsg) %>
    </div>
    <% } %>

    <!-- ========== 题单列表面板 ========== -->
    <asp:Panel ID="PanelList" runat="server" Visible="true">
        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                创建新题单
            </div>
            <div class="pp-card-body">
                <div class="pp-form-grid">
                    <div class="pp-form-group pp-form-full">
                        <label>题单标题 *</label>
                        <asp:TextBox ID="TxtNewTitle" runat="server" MaxLength="200" placeholder="请输入题单标题，如：Python基础语法题库" />
                    </div>
                    <div class="pp-form-group">
                        <label>题单类型</label>
                        <asp:DropDownList ID="DDLNewType" runat="server">
                            <asp:ListItem Value="mixed" Text="综合题库" />
                            <asp:ListItem Value="choice" Text="选择题" />
                            <asp:ListItem Value="truefalse" Text="判断题" />
                            <asp:ListItem Value="fill" Text="填空题" />
                            <asp:ListItem Value="program" Text="编程题" />
                            <asp:ListItem Value="essay" Text="简答题" />
                        </asp:DropDownList>
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>题单描述</label>
                        <asp:TextBox ID="TxtNewDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="简要描述题单内容（选填）" />
                    </div>
                </div>
                <asp:Button ID="BtnCreateBank" runat="server" Text="创建题单" OnClick="BtnCreateBank_Click" CssClass="pp-btn pp-btn-primary" />
            </div>
        </div>

        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>
                我的题单
            </div>
            <div class="pp-card-body">
                <asp:Repeater ID="RptBanks" runat="server" OnItemCommand="RptBanks_ItemCommand">
                    <HeaderTemplate><div class="pp-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="pp-item">
                            <div class="pp-item-icon">
                                <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>
                            </div>
                            <div class="pp-item-info">
                                <div class="pp-item-title">
                                    <span class="pp-q-badge" style="background:<%# GetBankTypeBgColor(Eval("Btype")) %>;color:<%# GetBankTypeColor(Eval("Btype")) %>;margin-right:8px;font-size:11px;padding:2px 10px;"><%# GetBankTypeName(Eval("Btype")) %></span>
                                    <%# Server.HtmlEncode(Eval("Btitle") == DBNull.Value ? "" : Eval("Btitle").ToString()) %>
                                </div>
                                <div class="pp-item-meta">
                                    <span class="pp-item-meta-tag">
                                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                        <%# Eval("Bcount") %> 题
                                    </span>
                                    <span class="pp-item-meta-tag">
                                        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                        <%# FormatDate(Eval("Bdate")) %>
                                    </span>
                                </div>
                            </div>
                            <div class="pp-item-actions">
                                <a href='questionbank.aspx?mode=edit&bid=<%# Eval("Bid") %>' class="pp-act-btn pp-act-btn-edit">
                                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    编辑
                                </a>
                                <asp:LinkButton runat="server" CssClass="pp-act-btn pp-act-btn-del" CausesValidation="false"
                                    CommandName="DelBank" CommandArgument='<%# Eval("Bid") %>'
                                    OnClientClick="return confirm('确定要删除该题单吗？删除后题单及其所有题目都将被永久删除！');">
                                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                    删除
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="PanelEmpty" runat="server" Visible='<%# RptBanks.Items.Count == 0 %>'>
                    <div class="pp-empty">
                        <div class="pp-empty-icon">
                            <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>
                        </div>
                        <div class="pp-empty-text">还没有创建任何题单</div>
                        <div class="pp-empty-hint">在上方填写信息创建你的第一个题单吧</div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <!-- ========== 编辑题单面板 ========== -->
    <asp:Panel ID="PanelEdit" runat="server" Visible="false">
        <asp:Button ID="BtnBackToList" runat="server" Text="" OnClick="BtnBackToList_Click" CssClass="pp-back-btn" style="display:none;" />
        <a href="questionbank.aspx" class="pp-back-btn">
            <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
            返回题单列表
        </a>

        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
                题单设置
            </div>
            <div class="pp-card-body">
                <div class="pp-form-grid">
                    <div class="pp-form-group pp-form-full">
                        <label>题单标题 *</label>
                        <asp:TextBox ID="TxtEditTitle" runat="server" MaxLength="200" placeholder="题单标题" />
                    </div>
                    <div class="pp-form-group">
                        <label>题单类型</label>
                        <asp:DropDownList ID="DDLEditType" runat="server">
                            <asp:ListItem Value="mixed" Text="综合题库" />
                            <asp:ListItem Value="choice" Text="选择题" />
                            <asp:ListItem Value="truefalse" Text="判断题" />
                            <asp:ListItem Value="fill" Text="填空题" />
                            <asp:ListItem Value="program" Text="编程题" />
                            <asp:ListItem Value="essay" Text="简答题" />
                        </asp:DropDownList>
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>题单描述</label>
                        <asp:TextBox ID="TxtEditDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="题单描述（选填）" />
                    </div>
                </div>
                <asp:Button ID="BtnSaveBank" runat="server" Text="保存设置" OnClick="BtnSaveBank_Click" CssClass="pp-btn pp-btn-primary" />
            </div>
        </div>

        <!-- 批量添题工具栏 -->
        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
                批量添题工具
            </div>
            <div class="pp-card-body">
                <div class="pp-tool-row">
                    <button type="button" class="pp-tool-btn" onclick="togglePanel('importPanel')">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        文本导入
                    </button>
                    <button type="button" class="pp-tool-btn pp-tool-btn-excel" onclick="togglePanel('excelPanel')">
                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                        Excel/Word导入
                    </button>
                    <button type="button" class="pp-tool-btn pp-tool-btn-ai" onclick="togglePanel('aiPanel')">
                        <svg viewBox="0 0 24 24"><path d="M12 2a4 4 0 014 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0112 2z"/><circle cx="12" cy="6" r="1"/></svg>
                        AI 智能出题
                    </button>
                    <button type="button" class="pp-tool-btn pp-tool-btn-paper" onclick="openImportToPaper()">
                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="18" x2="12" y2="12"/><line x1="9" y1="15" x2="15" y2="15"/></svg>
                        导入到试卷
                    </button>
                </div>
            </div>
        </div>

        <!-- 文本导入面板 -->
        <div id="importPanel" class="pp-panel pp-panel-import" style="display:none;">
            <div class="pp-panel-title">
                <svg viewBox="0 0 24 24" stroke="#059669"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                从文本文件导入题目
            </div>
            <div class="pp-import-hint">
                <strong>文件格式说明：</strong>每道题之间用<strong>空行</strong>分隔，每行一个字段：<br/>
                <code>题型:single</code> 题型可选：single(单选) / multiple(多选) / truefalse(判断) / fill(填空) / essay(简答) / scratch(Scratch) / python(Python) / pythonblock(Python拼图)<br/>
                <code>题目:题目内容</code><br/>
                <code>A:选项A</code> <code>B:选项B</code> <code>C:选项C</code> <code>D:选项D</code>（选择题需要）<br/>
                <code>答案:A</code><br/>
                <code>分值:5</code>（可选，默认5分）
            </div>
            <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                <asp:FileUpload ID="FileUploadImport" runat="server" />
                <asp:Button ID="BtnImportQuestions" runat="server" Text="开始导入" OnClick="BtnImportQuestions_Click" CssClass="pp-btn pp-btn-success" style="padding:8px 18px;font-size:13px;" />
                <button type="button" class="pp-btn" style="padding:8px 18px;font-size:13px;background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;" onclick="downloadTxtTemplate()">
                    <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:4px;"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    下载文本模板
                </button>
            </div>
        </div>

        <!-- Excel/Word导入面板 -->
        <div id="excelPanel" class="pp-panel pp-panel-excel" style="display:none;">
            <div class="pp-panel-title">
                <svg viewBox="0 0 24 24" stroke="#059669"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                从 Excel/Word 文件导入题目
            </div>
            <div class="pp-import-hint">
                <strong>Excel (.xlsx) 格式：</strong>第一行为表头（自动跳过），从第二行开始，列顺序：<br/>
                A列=题型 &emsp; B列=题目内容 &emsp; C列=选项A &emsp; D列=选项B &emsp; E列=选项C &emsp; F列=选项D &emsp; G列=答案 &emsp; H列=分值<br/><br/>
                <strong>Word (.docx) 格式：</strong>同文本导入格式，每题之间用空行分隔。
            </div>
            <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                <input type="file" id="fileExcelInput" accept=".xlsx,.docx" style="font-size:13px;" />
                <button type="button" id="btnExcelImport" class="pp-btn pp-btn-success" style="padding:8px 18px;font-size:13px;" onclick="excelImport()">开始导入</button>
                <button type="button" class="pp-btn" style="padding:8px 18px;font-size:13px;background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;" onclick="downloadExcelTemplate()">
                    <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:4px;"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    下载Excel模板
                </button>
            </div>
            <div id="excelImportStatus" style="margin-top:10px;font-size:13px;color:#64748b;display:none;"></div>
        </div>

        <!-- AI 出题面板 -->
        <div id="aiPanel" class="pp-panel pp-panel-ai" style="display:none;">
            <div class="pp-panel-title">
                <svg viewBox="0 0 24 24" stroke="#7c3aed"><path d="M12 2a4 4 0 014 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0112 2z"/><circle cx="12" cy="6" r="1"/></svg>
                AI 智能出题
            </div>
            <div id="aiKeywordsArea" class="pp-kw-list" style="display:none;"></div>
            <div class="pp-kb-area" id="aiKbArea">
                <div class="pp-kb-label">
                    <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>
                    知识库参考（可选，可多选，AI将扫描选中内容出题）
                </div>
                <div class="pp-kb-tags" id="aiKbTags">
                    <div class="pp-kb-loading"><span class="pp-ai-spinner"></span> 加载知识库...</div>
                </div>
                <!-- 关键词输入框 -->
                <div id="aiKbKeywordArea" style="display:none;margin-top:12px;">
                    <div class="pp-kb-label" style="margin-bottom:6px;">
                        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
                        关键词（可选，帮助AI更精准地从知识库中提取相关内容）
                    </div>
                    <input type="text" id="aiKbKeyword" placeholder="如：变量、循环、函数、数组等关键词，多个关键词用空格分隔" 
                        style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;" />
                    <div style="font-size:11px;color:#94a3b8;margin-top:4px;">💡 提示：输入关键词后，AI将重点关注知识库中包含这些关键词的内容进行出题</div>
                </div>
            </div>
            <div class="pp-form-grid">
                <div class="pp-form-group pp-form-full">
                    <label>出题主题/知识点 *</label>
                    <input type="text" id="aiTopic" placeholder="如：Python基础语法、Scratch动画制作、计算机网络基础" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;" />
                </div>
                <div class="pp-form-group">
                    <label>题目类型</label>
                    <select id="aiQType" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;">
                        <option value="mixed">混合题型</option>
                        <option value="single">单选题</option>
                        <option value="multiple">多选题</option>
                        <option value="truefalse">判断题</option>
                        <option value="fill">填空题</option>
                        <option value="essay">简答题</option>
                        <option value="scratch">Scratch编程</option>
                        <option value="python">Python编程</option>
                        <option value="pythonblock">Python拼图</option>
                    </select>
                </div>
                <div class="pp-form-group">
                    <label>出题数量</label>
                    <input type="text" id="aiCount" value="5" placeholder="5" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;width:100%;box-sizing:border-box;" />
                </div>
                <div class="pp-form-group">
                    <label>难度</label>
                    <select id="aiDiff" style="padding:10px 14px;border-radius:10px;border:1.5px solid #e2e8f0;font-size:13.5px;color:#334155;background:#fff;outline:none;">
                        <option value="简单">简单</option>
                        <option value="中等" selected>中等</option>
                        <option value="困难">困难</option>
                    </select>
                </div>
            </div>
            <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                <button type="button" id="btnAiGenerate" class="pp-btn" style="background:linear-gradient(135deg,#7c3aed,#a855f7);color:#fff;box-shadow:0 4px 14px rgba(124,58,237,0.3);" onclick="aiGenerate()">
                    <svg viewBox="0 0 24 24" width="16" height="16" stroke="#fff" fill="none" stroke-width="2" style="margin-right:4px;"><path d="M12 2a4 4 0 014 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0112 2z"/><circle cx="12" cy="6" r="1"/></svg>
                    开始生成
                </button>
                <div class="pp-ai-loading" id="aiLoading">
                    <div class="pp-ai-spinner"></div>
                    <span id="aiLoadingText">AI 正在生成题目，请稍候...</span>
                </div>
            </div>
            <div class="pp-ai-result" id="aiResult">
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                    <span style="font-size:13px;font-weight:600;color:#334155;">生成结果 (<span id="aiResultCount">0</span> 题)</span>
                    <button type="button" id="btnAiSave" class="pp-btn pp-btn-success" style="padding:6px 16px;font-size:12px;" onclick="aiSaveAll()">全部添加到题单</button>
                </div>
                <div id="aiResultList"></div>
            </div>
        </div>

        <!-- 题目列表 -->
        <div class="pp-card">
            <div class="pp-card-head">
                <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                题目列表
            </div>
            <div class="pp-card-body">
                <asp:Repeater ID="RptQuestions" runat="server" OnItemCommand="RptQuestions_ItemCommand">
                    <HeaderTemplate><div class="pp-q-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="pp-q-item">
                            <div class="pp-q-header">
                                <div class="pp-q-num">
                                    <span class="pp-q-badge" style="background:<%# GetTypeBgColor(Eval("Qtype")) %>;color:<%# GetTypeColor(Eval("Qtype")) %>;">
                                        <%# GetTypeName(Eval("Qtype")) %>
                                    </span>
                                </div>
                                <div class="pp-q-actions">
                                    <asp:LinkButton runat="server" CssClass="pp-q-act pp-q-act-up" CausesValidation="false" CommandName="MoveUp" CommandArgument='<%# Eval("Qid") %>' ToolTip="上移">
                                        <svg viewBox="0 0 24 24" width="14" height="14"><polyline points="18 15 12 9 6 15"/></svg>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CssClass="pp-q-act pp-q-act-down" CausesValidation="false" CommandName="MoveDown" CommandArgument='<%# Eval("Qid") %>' ToolTip="下移">
                                        <svg viewBox="0 0 24 24" width="14" height="14"><polyline points="6 9 12 15 18 9"/></svg>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CssClass="pp-q-act pp-q-act-edit" CausesValidation="false" CommandName="EditQuestion" CommandArgument='<%# Eval("Qid") %>' ToolTip="编辑">
                                        <svg viewBox="0 0 24 24" width="14" height="14"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CssClass="pp-q-act pp-q-act-del" CausesValidation="false" CommandName="DelQuestion" CommandArgument='<%# Eval("Qid") %>' OnClientClick="return confirm('确定删除此题吗？');" ToolTip="删除">
                                        <svg viewBox="0 0 24 24" width="14" height="14"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                                    </asp:LinkButton>
                                </div>
                            </div>
                            <div class="pp-q-content"><%# Server.HtmlEncode(SafeStr(Eval("Qcontent"))) %></div>
                            <asp:Panel runat="server" Visible='<%# HasImage(Eval("Qimage")) %>'>
                                <div class="pp-q-image" style="margin:10px 0;">
                                    <img src='<%# GetImageUrl(Eval("Qimage")) %>' alt="题目图片" style="max-width:100%;max-height:300px;border-radius:8px;border:1px solid #e2e8f0;" />
                                </div>
                            </asp:Panel>
                            <asp:Panel runat="server" Visible='<%# Eval("Qtype").ToString() == "single" || Eval("Qtype").ToString() == "multiple" %>'>
                                <div class="pp-q-options"><%# FormatOptionsWithImages(Eval("Qoption_a"), Eval("Qoption_b"), Eval("Qoption_c"), Eval("Qoption_d"), Eval("Qoption_a_img"), Eval("Qoption_b_img"), Eval("Qoption_c_img"), Eval("Qoption_d_img")) %></div>
                            </asp:Panel>
                            <div class="pp-q-answer">
                                <svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                答案：<%# Server.HtmlEncode(SafeStr(Eval("Qanswer"))) %>
                            </div>
                            <asp:Panel runat="server" Visible='<%# HasFile(Eval("Qfile")) %>'>
                                <div class="pp-q-file">
                                    <svg viewBox="0 0 24 24" width="14" height="14" stroke="#3b82f6" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                                    <a href='<%# GetFileUrl(Eval("Qfile")) %>' target="_blank" style="color:#3b82f6;text-decoration:none;font-size:12px;font-weight:500;"><%# Server.HtmlEncode(GetFileDisplayName(Eval("Qfile"))) %></a>
                                </div>
                            </asp:Panel>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>

                <% if (RptQuestions.Items.Count == 0) { %>
                    <div class="pp-empty" style="padding:40px 20px;">
                        <div class="pp-empty-icon" style="width:60px;height:60px;border-radius:14px;">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        </div>
                        <div class="pp-empty-text">还没有添加题目</div>
                        <div class="pp-empty-hint">在下方添加第一道题目</div>
                    </div>
                <% } %>
            </div>

            <div class="pp-add-q-area">
                <div class="pp-add-q-title">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    添加新题目
                </div>
                <div class="pp-form-grid">
                    <div class="pp-form-group">
                        <label>题目类型</label>
                        <asp:DropDownList ID="DDLQType" runat="server">
                            <asp:ListItem Value="single" Text="单选题" />
                            <asp:ListItem Value="multiple" Text="多选题" />
                            <asp:ListItem Value="truefalse" Text="判断题" />
                            <asp:ListItem Value="fill" Text="填空题" />
                            <asp:ListItem Value="essay" Text="简答题" />
                            <asp:ListItem Value="scratch" Text="Scratch编程" />
                            <asp:ListItem Value="python" Text="Python编程" />
                            <asp:ListItem Value="pythonblock" Text="Python拼图" />
                            <asp:ListItem Value="web" Text="Web编程" />
                            <asp:ListItem Value="cpp" Text="C/C++编程" />
                        </asp:DropDownList>
                    </div>
                    <div class="pp-form-group">
                        <label>分值</label>
                        <asp:TextBox ID="TxtQScore" runat="server" MaxLength="5" Text="5" placeholder="5" />
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>题目内容 *</label>
                        <asp:TextBox ID="TxtQContent" runat="server" MaxLength="2000" TextMode="MultiLine" Rows="3" placeholder="请输入题目内容" />
                    </div>
                    <div class="pp-form-group pp-form-full">
                        <label>题目图片（可选）</label>
                        <div style="display:flex;align-items:center;gap:12px;padding:14px 18px;background:linear-gradient(135deg,#fef3c7,#fde68a);border:1.5px dashed #f59e0b;border-radius:10px;">
                            <svg viewBox="0 0 24 24" width="24" height="24" stroke="#f59e0b" fill="none" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            <div style="flex:1;">
                                <asp:FileUpload ID="FileUploadQuestionImage" runat="server" accept=".jpg,.jpeg,.png,.gif,.webp,.bmp" style="font-size:13px;" />
                                <div style="font-size:11px;color:#64748b;margin-top:4px;">支持格式：JPG、PNG、GIF、WEBP、BMP，最大 5MB</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="optionsArea" style="margin-bottom:18px;">
                    <label style="font-size:12px;font-weight:600;color:#64748b;display:block;margin-bottom:8px;">选项（选择题填写，其他题型可留空）</label>
                    <div class="pp-opt-grid">
                        <div class="pp-form-group">
                            <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                                <span>A</span>
                                <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileOptA').click()" title="上传选项图片">
                                    <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                </button>
                            </label>
                            <asp:TextBox ID="TxtOptA" runat="server" MaxLength="500" placeholder="选项A" />
                            <asp:FileUpload ID="FileOptA" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewOptA')" />
                            <div id="previewOptA" class="pp-opt-preview"></div>
                        </div>
                        <div class="pp-form-group">
                            <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                                <span>B</span>
                                <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileOptB').click()" title="上传选项图片">
                                    <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                </button>
                            </label>
                            <asp:TextBox ID="TxtOptB" runat="server" MaxLength="500" placeholder="选项B" />
                            <asp:FileUpload ID="FileOptB" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewOptB')" />
                            <div id="previewOptB" class="pp-opt-preview"></div>
                        </div>
                        <div class="pp-form-group">
                            <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                                <span>C</span>
                                <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileOptC').click()" title="上传选项图片">
                                    <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                </button>
                            </label>
                            <asp:TextBox ID="TxtOptC" runat="server" MaxLength="500" placeholder="选项C" />
                            <asp:FileUpload ID="FileOptC" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewOptC')" />
                            <div id="previewOptC" class="pp-opt-preview"></div>
                        </div>
                        <div class="pp-form-group">
                            <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                                <span>D</span>
                                <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileOptD').click()" title="上传选项图片">
                                    <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                                </button>
                            </label>
                            <asp:TextBox ID="TxtOptD" runat="server" MaxLength="500" placeholder="选项D" />
                            <asp:FileUpload ID="FileOptD" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewOptD')" />
                            <div id="previewOptD" class="pp-opt-preview"></div>
                        </div>
                    </div>
                </div>
                <div class="pp-form-group" style="margin-bottom:20px;">
                    <label>正确答案 *</label>
                    <asp:TextBox ID="TxtQAnswer" runat="server" MaxLength="500" placeholder="单选填A/B/C/D，多选填AB/AC等，判断填对/错，填空/简答/编程填参考答案" />
                </div>
                <div id="programFileArea" style="margin-bottom:20px;display:none;">
                    <label style="font-size:12px;font-weight:600;color:#64748b;display:block;margin-bottom:8px;">编程附件上传（可选）</label>
                    <div style="display:flex;align-items:center;gap:12px;padding:14px 18px;background:linear-gradient(135deg,#eff6ff,#dbeafe);border:1.5px dashed #93c5fd;border-radius:10px;">
                        <svg viewBox="0 0 24 24" width="24" height="24" stroke="#3b82f6" fill="none" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                        <div style="flex:1;">
                            <asp:FileUpload ID="FileUploadProgram" runat="server" style="font-size:13px;" />
                            <div style="font-size:11px;color:#64748b;margin-top:4px;">支持格式：.sb3 .sb2 .py .html .htm .css .js .c .cpp .java .zip .rar .ino 等，最大 10MB</div>
                        </div>
                    </div>
                </div>
                <asp:Button ID="BtnAddQuestion" runat="server" Text="添加题目" OnClick="BtnAddQuestion_Click" CssClass="pp-btn pp-btn-success" />
            </div>
        </div>
    </asp:Panel>
</div>

<!-- 编辑题目对话框 -->
<div class="pp-modal-mask" id="editQuestionModal">
    <div class="pp-modal" style="max-width:750px;">
        <div class="pp-modal-hd">
            <div style="display:flex;align-items:center;gap:12px;">
                <div style="width:40px;height:40px;background:linear-gradient(135deg,#3b82f6,#8b5cf6);border-radius:10px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(59,130,246,0.3);">
                    <svg viewBox="0 0 24 24" width="20" height="20" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                </div>
                <span>编辑题目</span>
            </div>
            <button class="pp-modal-close" onclick="closeEditModal()">&times;</button>
        </div>
        <div class="pp-modal-bd">
            <asp:HiddenField ID="HiddenEditQid" runat="server" Value="" />
            <div class="pp-form-grid">
                <div class="pp-form-group">
                    <label>题目类型</label>
                    <asp:DropDownList ID="DDLEditQType" runat="server">
                        <asp:ListItem Value="single" Text="单选题" />
                        <asp:ListItem Value="multiple" Text="多选题" />
                        <asp:ListItem Value="truefalse" Text="判断题" />
                        <asp:ListItem Value="fill" Text="填空题" />
                        <asp:ListItem Value="essay" Text="简答题" />
                        <asp:ListItem Value="scratch" Text="Scratch编程" />
                        <asp:ListItem Value="python" Text="Python编程" />
                        <asp:ListItem Value="pythonblock" Text="Python拼图" />
                        <asp:ListItem Value="web" Text="Web编程" />
                        <asp:ListItem Value="cpp" Text="C/C++编程" />
                    </asp:DropDownList>
                </div>
                <div class="pp-form-group">
                    <label>分值</label>
                    <asp:TextBox ID="TxtEditQScore" runat="server" MaxLength="5" Text="5" placeholder="5" />
                </div>
                <div class="pp-form-group pp-form-full">
                    <label>题目内容 *</label>
                    <asp:TextBox ID="TxtEditQContent" runat="server" MaxLength="2000" TextMode="MultiLine" Rows="3" placeholder="请输入题目内容" />
                </div>
            </div>
            <div id="editOptionsArea" style="margin-bottom:20px;">
                <label style="font-size:13px;font-weight:600;color:#475569;display:flex;align-items:center;gap:6px;margin-bottom:12px;">
                    <div style="width:3px;height:14px;background:linear-gradient(180deg,#f59e0b,#f97316);border-radius:2px;"></div>
                    选项（选择题填写，其他题型可留空）
                </label>
                <div class="pp-opt-grid">
                    <div class="pp-form-group">
                        <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                            <span>A</span>
                            <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileEditOptA').click()" title="上传选项图片">
                                <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            </button>
                        </label>
                        <asp:TextBox ID="TxtEditOptA" runat="server" MaxLength="500" placeholder="选项A" />
                        <asp:FileUpload ID="FileEditOptA" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewEditOptA')" />
                        <div id="previewEditOptA" class="pp-opt-preview"></div>
                    </div>
                    <div class="pp-form-group">
                        <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                            <span>B</span>
                            <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileEditOptB').click()" title="上传选项图片">
                                <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            </button>
                        </label>
                        <asp:TextBox ID="TxtEditOptB" runat="server" MaxLength="500" placeholder="选项B" />
                        <asp:FileUpload ID="FileEditOptB" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewEditOptB')" />
                        <div id="previewEditOptB" class="pp-opt-preview"></div>
                    </div>
                    <div class="pp-form-group">
                        <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                            <span>C</span>
                            <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileEditOptC').click()" title="上传选项图片">
                                <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            </button>
                        </label>
                        <asp:TextBox ID="TxtEditOptC" runat="server" MaxLength="500" placeholder="选项C" />
                        <asp:FileUpload ID="FileEditOptC" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewEditOptC')" />
                        <div id="previewEditOptC" class="pp-opt-preview"></div>
                    </div>
                    <div class="pp-form-group">
                        <label style="color:#059669;display:flex;align-items:center;justify-content:space-between;">
                            <span>D</span>
                            <button type="button" class="pp-opt-img-btn" onclick="document.getElementById('FileEditOptD').click()" title="上传选项图片">
                                <svg viewBox="0 0 24 24" width="14" height="14"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            </button>
                        </label>
                        <asp:TextBox ID="TxtEditOptD" runat="server" MaxLength="500" placeholder="选项D" />
                        <asp:FileUpload ID="FileEditOptD" runat="server" style="display:none;" accept="image/*" onchange="previewOptImage(this, 'previewEditOptD')" />
                        <div id="previewEditOptD" class="pp-opt-preview"></div>
                    </div>
                </div>
            </div>
            <div class="pp-form-group" style="margin-bottom:20px;">
                <label>正确答案 *</label>
                <asp:TextBox ID="TxtEditQAnswer" runat="server" MaxLength="500" placeholder="单选填A/B/C/D，多选填AB/AC等，判断填对/错，填空/简答/编程填参考答案" />
            </div>
            <div id="editProgramFileArea" style="margin-bottom:24px;display:none;">
                <label style="font-size:13px;font-weight:600;color:#475569;display:flex;align-items:center;gap:6px;margin-bottom:12px;">
                    <div style="width:3px;height:14px;background:linear-gradient(180deg,#3b82f6,#8b5cf6);border-radius:2px;"></div>
                    编程附件上传（可选）
                </label>
                <div style="display:flex;align-items:center;gap:14px;padding:16px 20px;background:linear-gradient(135deg,#eff6ff 0%,#dbeafe 100%);border:2px dashed #93c5fd;border-radius:14px;">
                    <div style="width:48px;height:48px;background:linear-gradient(135deg,#3b82f6,#2563eb);border-radius:12px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(59,130,246,0.3);">
                        <svg viewBox="0 0 24 24" width="24" height="24" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                    </div>
                    <div style="flex:1;">
                        <asp:FileUpload ID="FileUploadEditProgram" runat="server" style="font-size:13px;" />
                        <div style="font-size:11px;color:#64748b;margin-top:6px;">支持格式：.sb3 .sb2 .py .html .css .js .c .cpp .java .zip .rar 等，最大 10MB</div>
                    </div>
                </div>
            </div>
            <div class="pp-form-group pp-form-full">
                <label>题目图片（可选）</label>
                <div style="display:flex;align-items:center;gap:14px;padding:16px 20px;background:linear-gradient(135deg,#fef3c7 0%,#fde68a 100%);border:2px dashed #f59e0b;border-radius:14px;">
                    <div style="width:48px;height:48px;background:linear-gradient(135deg,#f59e0b,#f97316);border-radius:12px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(245,158,11,0.3);">
                        <svg viewBox="0 0 24 24" width="24" height="24" stroke="#fff" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    </div>
                    <div style="flex:1;">
                        <asp:FileUpload ID="FileUploadEditImage" runat="server" accept=".jpg,.jpeg,.png,.gif,.webp,.bmp" style="font-size:13px;" />
                        <div style="font-size:11px;color:#64748b;margin-top:6px;">支持格式：JPG、PNG、GIF、WEBP、BMP，最大 5MB</div>
                    </div>
                </div>
            </div>
            <div id="editImagePreview" style="margin-bottom:20px;display:none;">
                <label style="font-size:13px;font-weight:600;color:#475569;display:flex;align-items:center;gap:6px;margin-bottom:12px;">
                    <div style="width:3px;height:14px;background:linear-gradient(180deg,#10b981,#059669);border-radius:2px;"></div>
                    当前图片
                </label>
                <div style="padding:12px;background:#f8fafc;border-radius:12px;border:2px solid #e2e8f0;">
                    <asp:Image ID="editImagePreviewImg" runat="server" AlternateText="当前图片" style="max-width:100%;max-height:200px;border-radius:10px;border:1px solid #e2e8f0;display:block;" />
                    <div style="margin-top:12px;padding:10px;background:#fff;border-radius:8px;">
                        <label style="font-size:13px;color:#64748b;cursor:pointer;display:flex;align-items:center;gap:8px;">
                            <asp:CheckBox ID="chkDeleteImage" runat="server" style="accent-color:#ef4444;" /> 
                            <span>删除当前图片</span>
                        </label>
                    </div>
                </div>
            </div>
        </div>
        <div class="pp-modal-ft">
            <button type="button" class="pp-btn" style="background:linear-gradient(135deg,#f1f5f9,#e2e8f0);color:#475569;border:2px solid #cbd5e1;box-shadow:0 2px 8px rgba(0,0,0,0.05);" onclick="closeEditModal()">
                <svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                取消
            </button>
            <asp:Button ID="BtnSaveEdit" runat="server" Text="💾 保存修改" OnClick="BtnSaveEdit_Click" CssClass="pp-btn" style="background:linear-gradient(135deg,#2563eb,#3b82f6);color:#fff;box-shadow:0 4px 14px rgba(37,99,235,0.4);border:none;" />
        </div>
    </div>
</div>

<!-- 导入到试卷对话框 -->
<div class="pp-modal-mask" id="toPaperModal">
    <div class="pp-modal">
        <div class="pp-modal-hd">
            从题库导入到试卷
            <button class="pp-modal-close" onclick="closeToPaperModal()">&times;</button>
        </div>
        <div class="pp-modal-bd">
            <label style="font-size:13px;font-weight:600;color:#475569;display:block;margin-bottom:6px;">选择目标试卷</label>
            <select id="toPaperSelect" class="pp-paper-select">
                <option value="">-- 加载中 --</option>
            </select>
            <label style="font-size:13px;font-weight:600;color:#475569;display:block;margin-bottom:6px;">选择要导入的题目</label>
            <div style="margin-bottom:8px;">
                <label style="font-size:12px;color:#64748b;cursor:pointer;"><input type="checkbox" id="toPaperSelectAll" onchange="toggleSelectAllQuestions(this)" /> 全选</label>
            </div>
            <div class="pp-qsel-list" id="toPaperQuestionList">
                <div style="text-align:center;color:#94a3b8;padding:20px;">加载中...</div>
            </div>
        </div>
        <div class="pp-modal-ft">
            <button type="button" class="pp-btn" style="background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;" onclick="closeToPaperModal()">取消</button>
            <button type="button" class="pp-btn" style="background:linear-gradient(135deg,#2563eb,#3b82f6);color:#fff;box-shadow:0 4px 14px rgba(37,99,235,0.3);" onclick="doImportToPaper()">导入选中题目</button>
        </div>
    </div>
</div>

<script src="../plugins/luckysheet/js/xlsx.full.min.js"></script>
<script src="../plugins/docx/dist/jszip.min.js"></script>
<script type="text/javascript">
    var programTypes = ['scratch', 'python', 'pythonblock', 'web', 'cpp', 'program'];
    $(function () {
        var ddl = $('[id$="DDLQType"]');
        var editDdl = $('[id$="DDLEditQType"]');
        function toggleOptions() {
            var val = ddl.val();
            if (val === 'single' || val === 'multiple') {
                $('#optionsArea').slideDown(200);
            } else {
                $('#optionsArea').slideUp(200);
            }
            // 编程题显示文件上传区域
            if ($.inArray(val, programTypes) >= 0) {
                $('#programFileArea').slideDown(200);
            } else {
                $('#programFileArea').slideUp(200);
            }
        }
        function toggleEditOptions() {
            var val = editDdl.val();
            if (val === 'single' || val === 'multiple') {
                $('#editOptionsArea').slideDown(200);
            } else {
                $('#editOptionsArea').slideUp(200);
            }
            // 编程题显示文件上传区域
            if ($.inArray(val, programTypes) >= 0) {
                $('#editProgramFileArea').slideDown(200);
            } else {
                $('#editProgramFileArea').slideUp(200);
            }
        }
        ddl.on('change', toggleOptions);
        editDdl.on('change', toggleEditOptions);
        toggleOptions();
        toggleEditOptions();
        // 加载AI出题配置
        loadQuizConfig();
    });

    function togglePanel(id) {
        var $panel = $('#' + id);
        if ($panel.is(':visible')) {
            $panel.slideUp(250);
        } else {
            $('.pp-panel:visible').slideUp(250);
            $panel.slideDown(250);
        }
    }

    // ========== 选项图片预览 ==========
    function previewOptImage(input, previewId) {
        var preview = document.getElementById(previewId);
        if (!preview) return;
        
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                preview.innerHTML = '<img src="' + e.target.result + '" />' +
                    '<button type="button" class="pp-opt-preview-close" onclick="clearOptImage(\'' + input.id + '\', \'' + previewId + '\')" title="删除图片">&times;</button>';
                preview.className = 'pp-opt-preview active';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
    
    function clearOptImage(inputId, previewId) {
        var input = document.getElementById(inputId);
        var preview = document.getElementById(previewId);
        if (input) input.value = '';
        if (preview) {
            preview.innerHTML = '';
            preview.className = 'pp-opt-preview';
        }
    }
    
    function showExistingOptImage(previewId, imageUrl) {
        var preview = document.getElementById(previewId);
        if (!preview) return;
        
        preview.innerHTML = '<img src="' + imageUrl + '" />' +
            '<button type="button" class="pp-opt-preview-close" onclick="clearOptImage(\'' + previewId.replace('preview', 'File') + '\', \'' + previewId + '\')" title="删除图片">&times;</button>';
        preview.className = 'pp-opt-preview active';
    }

    // ========== 模板下载 ==========
    function downloadTxtTemplate() {
        var lines = [
            '题型:single',
            '题目:Python中用于定义函数的关键字是？',
            'A:def',
            'B:func',
            'C:function',
            'D:define',
            '答案:A',
            '分值:5',
            '',
            '题型:truefalse',
            '题目:Python是一种解释型编程语言',
            '答案:对',
            '分值:5',
            '',
            '题型:fill',
            '题目:Python中使用___关键字导入模块',
            '答案:import',
            '分值:5',
            '',
            '题型:multiple',
            '题目:以下哪些是Python的数据类型？',
            'A:int',
            'B:str',
            'C:goto',
            'D:list',
            '答案:ABD',
            '分值:5',
            '',
            '题型:essay',
            '题目:简述Python中列表和元组的区别',
            '答案:列表是可变序列，元组是不可变序列。列表用方括号[]\uff0c元组用圆括号()',
            '分值:10'
        ];
        var content = lines.join('\r\n');
        var blob = new Blob(['\ufeff' + content], { type: 'text/plain;charset=utf-8' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = '题目导入模板.txt';
        a.click();
        URL.revokeObjectURL(a.href);
    }

    function downloadExcelTemplate() {
        if (typeof XLSX === 'undefined') { alert('Excel组件加载中，请稍后重试'); return; }
        var data = [
            ['题型', '题目内容', '选项A', '选项B', '选项C', '选项D', '答案', '分值'],
            ['single', 'Python中用于定义函数的关键字是？', 'def', 'func', 'function', 'define', 'A', 5],
            ['multiple', '以下哪些是Python的数据类型？', 'int', 'str', 'goto', 'list', 'ABD', 5],
            ['truefalse', 'Python是一种解释型编程语言', '', '', '', '', '对', 5],
            ['fill', 'Python中使用___关键字导入模块', '', '', '', '', 'import', 5],
            ['essay', '简述Python中列表和元组的区别', '', '', '', '', '列表可变，元组不可变', 10]
        ];
        var ws = XLSX.utils.aoa_to_sheet(data);
        ws['!cols'] = [
            { wch: 10 }, { wch: 40 }, { wch: 15 }, { wch: 15 }, { wch: 15 }, { wch: 15 }, { wch: 20 }, { wch: 8 }
        ];
        var wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, '题目导入模板');
        XLSX.writeFile(wb, '题目导入模板.xlsx');
    }

    // ========== AI 出题配置 ==========
    var quizConfig = {};
    function loadQuizConfig() {
        $.getJSON('questionbankapi.ashx?action=getquizconfig', function (data) {
            quizConfig = data;
            if (data.keywords) {
                var kws = data.keywords.split(',');
                var html = '';
                for (var i = 0; i < kws.length; i++) {
                    var kw = kws[i].trim();
                    if (kw) html += '<span class="pp-kw-tag" onclick="selectKeyword(this)">' + escapeHtml(kw) + '</span>';
                }
                if (html) {
                    document.getElementById('aiKeywordsArea').innerHTML = '<span style="font-size:12px;color:#64748b;margin-right:6px;">快捷选题：</span>' + html;
                    document.getElementById('aiKeywordsArea').style.display = 'flex';
                }
            }
        });
        // 加载知识库列表
        loadKbList();
    }

    // ========== 知识库加载和选择 ==========
    var kbItems = [];
    var selectedKbIds = [];
    function loadKbList() {
        $.getJSON('questionbankapi.ashx?action=listkb', function (data) {
            if (data.success && data.items && data.items.length > 0) {
                kbItems = data.items;
                var html = '';
                for (var i = 0; i < data.items.length; i++) {
                    var item = data.items[i];
                    html += '<span class="pp-kb-tag" data-id="' + escapeHtml(item.id) + '" onclick="toggleKbTag(this)">';
                    html += escapeHtml(item.title);
                    if (item.ext) html += ' <span class="pp-kb-ext">' + escapeHtml(item.ext) + '</span>';
                    html += '</span>';
                }
                document.getElementById('aiKbTags').innerHTML = html;
            } else {
                document.getElementById('aiKbTags').innerHTML = '<span class="pp-kb-empty">暂无知识库资料，请先在「知识库管理」中上传</span>';
            }
        }).fail(function() {
            document.getElementById('aiKbTags').innerHTML = '<span class="pp-kb-empty">知识库加载失败</span>';
        });
    }
    function toggleKbTag(el) {
        var id = el.getAttribute('data-id');
        if (el.classList.contains('selected')) {
            el.classList.remove('selected');
            selectedKbIds = selectedKbIds.filter(function(x) { return x !== id; });
        } else {
            el.classList.add('selected');
            selectedKbIds.push(id);
        }
        // 显示或隐藏关键词输入框
        var keywordArea = document.getElementById('aiKbKeywordArea');
        if (keywordArea) {
            keywordArea.style.display = selectedKbIds.length > 0 ? 'block' : 'none';
        }
    }
    function selectKeyword(el) {
        var tags = document.querySelectorAll('.pp-kw-tag');
        for (var i = 0; i < tags.length; i++) tags[i].classList.remove('active');
        el.classList.add('active');
        document.getElementById('aiTopic').value = el.textContent;
    }

    // ========== AI 出题 ==========
    var aiQuestions = [];
    function getTypeName(t) {
        var map = { single: '单选题', multiple: '多选题', truefalse: '判断题', fill: '填空题', essay: '简答题', scratch: 'Scratch编程', python: 'Python编程', pythonblock: 'Python拼图', web: 'Web编程', cpp: 'C/C++编程', program: '编程题' };
        return map[t] || t;
    }
    function getTypeColor(t) {
        var map = { single: '#6366f1', multiple: '#8b5cf6', truefalse: '#0891b2', fill: '#059669', essay: '#d97706', scratch: '#f97316', python: '#3b82f6', pythonblock: '#047857', web: '#ec4899', cpp: '#6366f1', program: '#f97316' };
        return map[t] || '#94a3b8';
    }
    function escapeHtml(s) {
        if (!s) return '';
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function aiGenerate() {
        var topic = document.getElementById('aiTopic').value.trim();
        if (!topic) { alert('请输入出题主题/知识点'); return; }
        var qtype = document.getElementById('aiQType').value;
        var count = parseInt(document.getElementById('aiCount').value) || 5;
        var score = 5;
        var diff = document.getElementById('aiDiff').value;
        if (count < 1) count = 1;
        if (count > 20) count = 20;

        // 获取关键词
        var keyword = '';
        if (selectedKbIds.length > 0) {
            var keywordInput = document.getElementById('aiKbKeyword');
            if (keywordInput) {
                keyword = keywordInput.value.trim();
            }
        }

        // 如果选择了知识库，先获取内容再生成
        if (selectedKbIds.length > 0) {
            document.getElementById('aiLoading').className = 'pp-ai-loading show';
            document.getElementById('aiLoadingText').textContent = '正在读取知识库内容...';
            document.getElementById('aiResult').style.display = 'none';
            document.getElementById('btnAiGenerate').disabled = true;
            document.getElementById('btnAiGenerate').style.display = 'none';
            
            var url = 'questionbankapi.ashx?action=getkbcontent&ids=' + encodeURIComponent(selectedKbIds.join(','));
            if (keyword) {
                url += '&keyword=' + encodeURIComponent(keyword);
            }
            
            $.getJSON(url, function(data) {
                if (data.success && data.content) {
                    doAiGenerate(topic, qtype, count, score, diff, data.content, keyword);
                } else {
                    doAiGenerate(topic, qtype, count, score, diff, '', keyword);
                }
            }).fail(function() {
                doAiGenerate(topic, qtype, count, score, diff, '', keyword);
            });
        } else {
            doAiGenerate(topic, qtype, count, score, diff, '', keyword);
        }
    }

    function doAiGenerate(topic, qtype, count, score, diff, kbContent, keyword) {
        var typeDesc = qtype === 'mixed' ? '混合题型（包含单选题、多选题、判断题、填空题等）' : getTypeName(qtype);

        var prompt = '';
        if (kbContent) {
            prompt += '以下是知识库参考资料';
            if (keyword) {
                prompt += '（重点关注关键词：' + keyword + '）';
            }
            prompt += '，请基于这些内容出题：\n' + kbContent + '\n\n';
            if (keyword) {
                prompt += '【重要】请特别关注上述资料中与「' + keyword + '」相关的内容，围绕这些关键词出题。\n\n';
            }
        }
        prompt += '请你作为一位专业的信息技术教师，围绕「' + topic + '」这个知识点，出 ' + count + ' 道' + typeDesc + '试题。\n'
            + '难度要求：' + diff + '\n'
            + '每题分值：' + score + '分\n\n'
            + '【重要】请严格按照以下JSON格式返回，不要添加任何其他文字、解释或markdown标记，只返回纯JSON数组：\n'
            + '[\n';
        if (qtype === 'single' || qtype === 'mixed') {
            prompt += '  {"type":"single","content":"题目内容","option_a":"选项A","option_b":"选项B","option_c":"选项C","option_d":"选项D","answer":"A","score":' + score + '},\n';
        }
        if (qtype === 'truefalse' || qtype === 'mixed') {
            prompt += '  {"type":"truefalse","content":"题目内容","option_a":"","option_b":"","option_c":"","option_d":"","answer":"对","score":' + score + '},\n';
        }
        if (qtype === 'fill' || qtype === 'mixed') {
            prompt += '  {"type":"fill","content":"题目内容（用___表示空）","option_a":"","option_b":"","option_c":"","option_d":"","answer":"标准答案","score":' + score + '},\n';
        }
        if (qtype === 'multiple') {
            prompt += '  {"type":"multiple","content":"题目内容","option_a":"选项A","option_b":"选项B","option_c":"选项C","option_d":"选项D","answer":"AB","score":' + score + '},\n';
        }
        if (qtype === 'essay') {
            prompt += '  {"type":"essay","content":"题目内容","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考答案","score":' + score + '},\n';
        }
        if (qtype === 'scratch') {
            prompt += '  {"type":"scratch","content":"编程题目要求","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考思路","score":' + score + '},\n';
        }
        if (qtype === 'python' || qtype === 'mixed') {
            prompt += '  {"type":"python","content":"Python编程题目要求","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考代码","score":' + score + '},\n';
        }
        if (qtype === 'pythonblock') {
            prompt += '  {"type":"pythonblock","content":"Python拼图编程题目要求","option_a":"","option_b":"","option_c":"","option_d":"","answer":"参考思路","score":' + score + '},\n';
        }
        prompt += ']\n请确保返回的是合法的JSON数组，每个对象必须包含type,content,option_a,option_b,option_c,option_d,answer,score这些字段。';

        if (!document.getElementById('btnAiGenerate').disabled) {
            document.getElementById('aiLoading').className = 'pp-ai-loading show';
            document.getElementById('btnAiGenerate').disabled = true;
            document.getElementById('btnAiGenerate').style.display = 'none';
        }
        document.getElementById('aiResult').style.display = 'none';
        aiQuestions = [];

        var fullResponse = '';
        fetch('questionbankapi.ashx?action=aichat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ messages: [{ role: 'user', content: prompt }] })
        }).then(function(response) {
            var reader = response.body.getReader();
            var decoder = new TextDecoder();
            var buffer = '';
            function read() {
                return reader.read().then(function(result) {
                    if (result.done) { parseAiResponse(fullResponse); return; }
                    buffer += decoder.decode(result.value, { stream: true });
                    var lines = buffer.split('\n');
                    for (var i = 0; i < lines.length - 1; i++) {
                        var line = lines[i].trim();
                        if (!line) continue;
                        var jsonStr = line.startsWith('data: ') ? line.substring(6) : line;
                        if (jsonStr === '[DONE]') continue;
                        try { var chunk = JSON.parse(jsonStr); if (chunk.content) fullResponse += chunk.content; } catch(e) {}
                    }
                    buffer = lines[lines.length - 1];
                    document.getElementById('aiLoadingText').textContent = 'AI 正在生成题目... (' + fullResponse.length + ' 字)';
                    return read();
                });
            }
            return read();
        }).catch(function(err) {
            alert('AI 请求失败: ' + err.message);
            document.getElementById('aiLoading').className = 'pp-ai-loading';
            document.getElementById('btnAiGenerate').disabled = false;
            document.getElementById('btnAiGenerate').style.display = '';
        });
    }

    function parseAiResponse(text) {
        document.getElementById('aiLoading').className = 'pp-ai-loading';
        document.getElementById('btnAiGenerate').disabled = false;
        document.getElementById('btnAiGenerate').style.display = '';
        var jsonText = text.replace(/```json\s*/gi, '').replace(/```\s*/g, '').trim();
        var start = jsonText.indexOf('[');
        var end = jsonText.lastIndexOf(']');
        if (start >= 0 && end > start) jsonText = jsonText.substring(start, end + 1);
        try {
            aiQuestions = JSON.parse(jsonText);
            if (!Array.isArray(aiQuestions)) aiQuestions = [aiQuestions];
        } catch(e) {
            alert('AI 返回的内容无法解析为题目格式，请重试。\n\n原始内容：\n' + text.substring(0, 500));
            aiQuestions = [];
            return;
        }
        var html = '';
        for (var i = 0; i < aiQuestions.length; i++) {
            var q = aiQuestions[i];
            html += '<div class="pp-ai-result-item">';
            html += '<strong style="color:' + getTypeColor(q.type) + ';">[' + getTypeName(q.type) + ']</strong> ';
            html += escapeHtml(q.content || '');
            if ((q.type === 'single' || q.type === 'multiple') && q.option_a) {
                html += '<br/><span style="color:#64748b;font-size:12px;">A.' + escapeHtml(q.option_a) + '&emsp;B.' + escapeHtml(q.option_b || '') + '&emsp;C.' + escapeHtml(q.option_c || '') + '&emsp;D.' + escapeHtml(q.option_d || '') + '</span>';
            }
            html += '<br/><span style="color:#059669;font-size:12px;">答案：' + escapeHtml(q.answer || '') + ' | ' + (q.score || 5) + '分</span>';
            html += '</div>';
        }
        document.getElementById('aiResultList').innerHTML = html;
        document.getElementById('aiResultCount').textContent = aiQuestions.length;
        document.getElementById('aiResult').style.display = 'block';
    }

    function aiSaveAll() {
        if (!aiQuestions || aiQuestions.length === 0) { alert('没有可保存的题目'); return; }
        var bid = $('[id$="HiddenBankId"]').val();
        if (!bid) { alert('题单ID丢失'); return; }
        document.getElementById('btnAiSave').disabled = true;
        document.getElementById('btnAiSave').textContent = '保存中...';
        $.ajax({
            url: 'questionbankapi.ashx?action=addquestions',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ bid: parseInt(bid), questions: aiQuestions }),
            success: function(res) {
                if (res.success) { alert(res.message); location.reload(); }
                else { alert('保存失败: ' + res.message); document.getElementById('btnAiSave').disabled = false; document.getElementById('btnAiSave').textContent = '全部添加到题单'; }
            },
            error: function() { alert('请求失败，请重试'); document.getElementById('btnAiSave').disabled = false; document.getElementById('btnAiSave').textContent = '全部添加到题单'; }
        });
    }

    // ========== Excel/Word 前端导入 ==========
    function excelImport() {
        var fileInput = document.getElementById('fileExcelInput');
        if (!fileInput.files || fileInput.files.length === 0) { alert('请选择要导入的文件'); return; }
        var file = fileInput.files[0];
        var ext = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
        if (ext !== '.xlsx' && ext !== '.docx') { alert('仅支持 .xlsx 或 .docx 文件'); return; }
        var bid = $('[id$="HiddenBankId"]').val();
        if (!bid) { alert('题单ID丢失'); return; }
        var statusEl = document.getElementById('excelImportStatus');
        statusEl.style.display = 'block';
        statusEl.style.color = '#64748b';
        statusEl.textContent = '正在解析文件...';
        document.getElementById('btnExcelImport').disabled = true;
        var reader = new FileReader();
        reader.onload = function(e) {
            var data = e.target.result;
            var questions = [];
            try {
                if (ext === '.xlsx') {
                    questions = parseXlsxClient(new Uint8Array(data));
                } else {
                    parseDocxClient(data, bid, statusEl);
                    return;
                }
            } catch(err) {
                statusEl.style.color = '#dc2626';
                statusEl.textContent = '解析失败: ' + err.message;
                document.getElementById('btnExcelImport').disabled = false;
                return;
            }
            if (questions.length === 0) {
                statusEl.style.color = '#dc2626';
                statusEl.textContent = '未解析到有效题目，请检查文件格式';
                document.getElementById('btnExcelImport').disabled = false;
                return;
            }
            statusEl.textContent = '解析到 ' + questions.length + ' 道题目，正在保存...';
            saveImportedQuestions(parseInt(bid), questions, statusEl);
        };
        reader.onerror = function() {
            statusEl.style.color = '#dc2626';
            statusEl.textContent = '文件读取失败';
            document.getElementById('btnExcelImport').disabled = false;
        };
        reader.readAsArrayBuffer(file);
    }

    function parseXlsxClient(arrayData) {
        var workbook = XLSX.read(arrayData, { type: 'array' });
        var sheetName = workbook.SheetNames[0];
        var sheet = workbook.Sheets[sheetName];
        var rows = XLSX.utils.sheet_to_json(sheet, { header: 1 });
        var questions = [];
        for (var i = 1; i < rows.length; i++) {
            var row = rows[i];
            if (!row || row.length < 2) continue;
            var content = (row[1] || '').toString().trim();
            if (!content) continue;
            var qtype = (row[0] || 'single').toString().trim();
            var score = parseInt(row[7]) || 5;
            if (score <= 0) score = 5;
            questions.push({
                type: qtype,
                content: content,
                option_a: (row[2] || '').toString().trim(),
                option_b: (row[3] || '').toString().trim(),
                option_c: (row[4] || '').toString().trim(),
                option_d: (row[5] || '').toString().trim(),
                answer: (row[6] || '').toString().trim(),
                score: score
            });
        }
        return questions;
    }

    function parseDocxClient(arrayData, bid, statusEl) {
        JSZip.loadAsync(arrayData).then(function(zip) {
            var docFile = zip.file('word/document.xml');
            if (!docFile) { throw new Error('无法读取 Word 文档内容'); }
            return docFile.async('string');
        }).then(function(xmlStr) {
            var parser = new DOMParser();
            var xmlDoc = parser.parseFromString(xmlStr, 'application/xml');
            var body = xmlDoc.getElementsByTagName('w:body')[0];
            if (!body) { throw new Error('Word 文档结构不正确'); }
            var paragraphs = body.getElementsByTagName('w:p');
            var lines = [];
            for (var i = 0; i < paragraphs.length; i++) {
                var texts = paragraphs[i].getElementsByTagName('w:t');
                var lineText = '';
                for (var j = 0; j < texts.length; j++) lineText += texts[j].textContent;
                lines.push(lineText);
            }
            var questions = parseDocxLines(lines);
            if (questions.length === 0) {
                statusEl.style.color = '#dc2626';
                statusEl.textContent = '未解析到有效题目，请检查文件格式';
                document.getElementById('btnExcelImport').disabled = false;
                return;
            }
            statusEl.textContent = '解析到 ' + questions.length + ' 道题目，正在保存...';
            saveImportedQuestions(parseInt(bid), questions, statusEl);
        }).catch(function(err) {
            statusEl.style.color = '#dc2626';
            statusEl.textContent = '解析失败: ' + err.message;
            document.getElementById('btnExcelImport').disabled = false;
        });
    }

    function parseDocxLines(lines) {
        var questions = [];
        var curType = 'single', curContent = '', curA = '', curB = '', curC = '', curD = '', curAnswer = '', curScore = 5;
        var inBlock = false;
        for (var i = 0; i <= lines.length; i++) {
            var line = (i < lines.length) ? lines[i].trim() : '';
            if (!line || i === lines.length) {
                if (inBlock && curContent) {
                    questions.push({ type: curType, content: curContent, option_a: curA, option_b: curB, option_c: curC, option_d: curD, answer: curAnswer, score: curScore });
                }
                curType = 'single'; curContent = ''; curA = ''; curB = ''; curC = ''; curD = ''; curAnswer = ''; curScore = 5;
                inBlock = false;
                continue;
            }
            inBlock = true;
            if (line.indexOf('\u9898\u578b:') === 0 || line.indexOf('\u9898\u578b\uff1a') === 0) { curType = line.substring(3).trim(); }
            else if (line.indexOf('\u9898\u76ee:') === 0 || line.indexOf('\u9898\u76ee\uff1a') === 0) { curContent = line.substring(3).trim(); }
            else if (line.indexOf('A:') === 0 || line.indexOf('A\uff1a') === 0) { curA = line.substring(2).trim(); }
            else if (line.indexOf('B:') === 0 || line.indexOf('B\uff1a') === 0) { curB = line.substring(2).trim(); }
            else if (line.indexOf('C:') === 0 || line.indexOf('C\uff1a') === 0) { curC = line.substring(2).trim(); }
            else if (line.indexOf('D:') === 0 || line.indexOf('D\uff1a') === 0) { curD = line.substring(2).trim(); }
            else if (line.indexOf('\u7b54\u6848:') === 0 || line.indexOf('\u7b54\u6848\uff1a') === 0) { curAnswer = line.substring(3).trim(); }
            else if (line.indexOf('\u5206\u503c:') === 0 || line.indexOf('\u5206\u503c\uff1a') === 0) { var sv = parseInt(line.substring(3).trim()); curScore = (sv > 0) ? sv : 5; }
        }
        return questions;
    }

    function saveImportedQuestions(bid, questions, statusEl) {
        $.ajax({
            url: 'questionbankapi.ashx?action=addquestions',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ bid: bid, questions: questions }),
            success: function(res) {
                if (res.success) {
                    statusEl.style.color = '#059669';
                    statusEl.textContent = res.message;
                    setTimeout(function() { location.reload(); }, 1000);
                } else {
                    statusEl.style.color = '#dc2626';
                    statusEl.textContent = '保存失败: ' + res.message;
                    document.getElementById('btnExcelImport').disabled = false;
                }
            },
            error: function() {
                statusEl.style.color = '#dc2626';
                statusEl.textContent = '请求失败，请重试';
                document.getElementById('btnExcelImport').disabled = false;
            }
        });
    }

    // ========== 导入到试卷 ==========
    function openImportToPaper() {
        document.getElementById('toPaperModal').classList.add('show');
        // 加载试卷列表
        $.getJSON('questionbankapi.ashx?action=listpapers', function (data) {
            if (data.success && data.papers) {
                var html = '<option value="">-- 请选择试卷 --</option>';
                for (var i = 0; i < data.papers.length; i++) {
                    var p = data.papers[i];
                    html += '<option value="' + p.pid + '">' + escapeHtml(p.title) + ' (' + p.count + '题)</option>';
                }
                document.getElementById('toPaperSelect').innerHTML = html;
            } else {
                document.getElementById('toPaperSelect').innerHTML = '<option value="">-- 暂无试卷 --</option>';
            }
        });
        // 加载当前题单的题目
        var bid = $('[id$="HiddenBankId"]').val();
        if (bid) {
            $.getJSON('questionbankapi.ashx?action=listquestions&bid=' + bid, function (data) {
                if (data.success && data.questions) {
                    var html = '';
                    for (var i = 0; i < data.questions.length; i++) {
                        var q = data.questions[i];
                        html += '<div class="pp-qsel-item"><input type="checkbox" class="qsel-chk" value="' + q.qid + '" />';
                        html += '<span class="pp-qsel-item-type" style="background:' + getTypeBgColor(q.type) + ';color:' + getTypeColor(q.type) + ';">' + getTypeName(q.type) + '</span>';
                        html += '<span style="flex:1;">' + escapeHtml(q.content) + '</span></div>';
                    }
                    document.getElementById('toPaperQuestionList').innerHTML = html || '<div style="text-align:center;color:#94a3b8;padding:20px;">题单中暂无题目</div>';
                }
            });
        }
    }
    function getTypeBgColor(t) {
        var map = { single: '#eef2ff', multiple: '#f5f3ff', truefalse: '#ecfeff', fill: '#ecfdf5', essay: '#fffbeb', scratch: '#fff7ed', python: '#eff6ff', web: '#fdf2f8', cpp: '#eef2ff', program: '#fff7ed' };
        return map[t] || '#f1f5f9';
    }
    function closeToPaperModal() { document.getElementById('toPaperModal').classList.remove('show'); }
    function openEditModal() { document.getElementById('editQuestionModal').classList.add('show'); }
    function closeEditModal() { document.getElementById('editQuestionModal').classList.remove('show'); }
    function toggleSelectAllQuestions(el) {
        var chks = document.querySelectorAll('.qsel-chk');
        for (var i = 0; i < chks.length; i++) chks[i].checked = el.checked;
    }
    function doImportToPaper() {
        var pid = document.getElementById('toPaperSelect').value;
        if (!pid) { alert('请选择目标试卷'); return; }
        var qids = [];
        var chks = document.querySelectorAll('.qsel-chk:checked');
        for (var i = 0; i < chks.length; i++) qids.push(parseInt(chks[i].value));
        if (qids.length === 0) { alert('请选择要导入的题目'); return; }
        $.ajax({
            url: 'questionbankapi.ashx?action=importtopaper',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ pid: parseInt(pid), qids: qids }),
            success: function(res) {
                if (res.success) { alert(res.message); closeToPaperModal(); }
                else { alert('导入失败: ' + res.message); }
            },
            error: function() { alert('请求失败，请重试'); }
        });
    }
</script>
</asp:Content>
