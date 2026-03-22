<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";
    protected string pageMsgType = "info";

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
            LoadPapers();
            LoadGrades();
            if (DDLgrade.Items.Count > 0)
                LoadClasses();
            LoadEditDropdowns();
            BindPublished();
        }
    }

    // ========== 自动建表 ==========
    private void EnsureTables()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM sysobjects WHERE name='ExamPublish' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0)
                    {
                        string sql = @"CREATE TABLE [dbo].[ExamPublish](
                            [Eid] [int] IDENTITY(1,1) NOT NULL,
                            [Epid] [int] NULL,
                            [Ehid] [int] NULL,
                            [Egrade] [int] NULL,
                            [Eclass] [int] NULL,
                            [Estart] [datetime] NULL,
                            [Eend] [datetime] NULL,
                            [Estatus] [int] NULL DEFAULT(1),
                            [Edate] [datetime] NULL,
                            PRIMARY KEY CLUSTERED ([Eid] ASC))";
                        using (SqlCommand cmd = new SqlCommand(sql, conn)) { cmd.ExecuteNonQuery(); }
                    }
                }
            }
        }
        catch { }
    }

    // ========== 加载试卷列表 ==========
    private void LoadPapers()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT Pid, Ptitle, Pcount, Ptime, Pscore FROM Paper WHERE Phid=@hid ORDER BY Pdate DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLpaper.Items.Clear();
                    DDLpaper.Items.Add(new System.Web.UI.WebControls.ListItem("-- 请选择试卷 --", "0"));
                    while (dr.Read())
                    {
                        string text = dr["Ptitle"].ToString() + " (" + dr["Pcount"] + "题 / " + dr["Ptime"] + "分钟 / " + dr["Pscore"] + "分)";
                        DDLpaper.Items.Add(new System.Web.UI.WebControls.ListItem(text, dr["Pid"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    // ========== 加载年级 ==========
    private void LoadGrades()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade>0 ORDER BY Sgrade";
                if (myHid > 0)
                    sql = "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade IN (SELECT DISTINCT Rgrade FROM Room WHERE Rhid=" + myHid + ") ORDER BY Sgrade";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLgrade.Items.Clear();
                    while (dr.Read())
                    {
                        DDLgrade.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Sgrade"].ToString() + "年级", dr["Sgrade"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    // ========== 加载班级 ==========
    private void LoadClasses()
    {
        if (DDLgrade.Items.Count == 0) return;
        int grade = int.Parse(DDLgrade.SelectedValue);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade + " ORDER BY Sclass";
                if (myHid > 0)
                    sql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade +
                          " AND Sclass IN (SELECT DISTINCT Rclass FROM Room WHERE Rhid=" + myHid + " AND Rgrade=" + grade + ") ORDER BY Sclass";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataReader dr = cmd.ExecuteReader();
                    DDLclass.Items.Clear();
                    while (dr.Read())
                    {
                        DDLclass.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Sclass"].ToString() + "班", dr["Sclass"].ToString()));
                    }
                    dr.Close();
                }
            }
        }
        catch { }
    }

    // ========== 加载编辑弹窗下拉列表 ==========
    private void LoadEditDropdowns()
    {
        // 复制试卷列表到编辑弹窗
        DDLeditPaper.Items.Clear();
        foreach (System.Web.UI.WebControls.ListItem item in DDLpaper.Items)
        { DDLeditPaper.Items.Add(new System.Web.UI.WebControls.ListItem(item.Text, item.Value)); }
        // 复制年级列表到编辑弹窗
        DDLeditGrade.Items.Clear();
        foreach (System.Web.UI.WebControls.ListItem item in DDLgrade.Items)
        { DDLeditGrade.Items.Add(new System.Web.UI.WebControls.ListItem(item.Text, item.Value)); }
    }

    protected void DDLgrade_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadClasses();
        BindPublished();
    }

    // ========== 发布考试 ==========
    protected void BtnPublish_Click(object sender, EventArgs e)
    {
        int pid = 0; int.TryParse(DDLpaper.SelectedValue, out pid);
        if (pid <= 0) { pageMsg = "请选择要发布的试卷"; pageMsgType = "error"; BindPublished(); return; }
        if (DDLgrade.Items.Count == 0 || DDLclass.Items.Count == 0) { pageMsg = "请选择年级和班级"; pageMsgType = "error"; BindPublished(); return; }

        DateTime startTime, endTime;
        if (!DateTime.TryParse(TxtStart.Text.Trim(), out startTime))
        { pageMsg = "请输入正确的开始时间"; pageMsgType = "error"; BindPublished(); return; }
        if (!DateTime.TryParse(TxtEnd.Text.Trim(), out endTime))
        { pageMsg = "请输入正确的结束时间"; pageMsgType = "error"; BindPublished(); return; }
        if (endTime <= startTime)
        { pageMsg = "结束时间必须大于开始时间"; pageMsgType = "error"; BindPublished(); return; }

        int grade = int.Parse(DDLgrade.SelectedValue);
        int cls = int.Parse(DDLclass.SelectedValue);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                // 检查是否已发布相同试卷到同一班级
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamPublish WHERE Epid=@pid AND Egrade=@g AND Eclass=@c AND Ehid=@hid", conn))
                {
                    chk.Parameters.AddWithValue("@pid", pid);
                    chk.Parameters.AddWithValue("@g", grade);
                    chk.Parameters.AddWithValue("@c", cls);
                    chk.Parameters.AddWithValue("@hid", myHid);
                    int cnt = Convert.ToInt32(chk.ExecuteScalar());
                    if (cnt > 0)
                    { pageMsg = "该试卷已发布到此班级，请勿重复发布"; pageMsgType = "error"; BindPublished(); return; }
                }
                using (SqlCommand cmd = new SqlCommand("INSERT INTO ExamPublish(Epid,Ehid,Egrade,Eclass,Estart,Eend,Estatus,Edate) VALUES(@pid,@hid,@g,@c,@start,@end,1,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", pid);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.Parameters.AddWithValue("@g", grade);
                    cmd.Parameters.AddWithValue("@c", cls);
                    cmd.Parameters.AddWithValue("@start", startTime);
                    cmd.Parameters.AddWithValue("@end", endTime);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "考试发布成功！"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "发布失败: " + ex.Message; pageMsgType = "error"; }
        BindPublished();
    }

    // ========== 批量发布（全年级） ==========
    protected void BtnPublishAll_Click(object sender, EventArgs e)
    {
        int pid = 0; int.TryParse(DDLpaper.SelectedValue, out pid);
        if (pid <= 0) { pageMsg = "请选择要发布的试卷"; pageMsgType = "error"; BindPublished(); return; }
        if (DDLgrade.Items.Count == 0) { pageMsg = "没有可选年级"; pageMsgType = "error"; BindPublished(); return; }

        DateTime startTime, endTime;
        if (!DateTime.TryParse(TxtStart.Text.Trim(), out startTime))
        { pageMsg = "请输入正确的开始时间"; pageMsgType = "error"; BindPublished(); return; }
        if (!DateTime.TryParse(TxtEnd.Text.Trim(), out endTime))
        { pageMsg = "请输入正确的结束时间"; pageMsgType = "error"; BindPublished(); return; }
        if (endTime <= startTime)
        { pageMsg = "结束时间必须大于开始时间"; pageMsgType = "error"; BindPublished(); return; }

        int grade = int.Parse(DDLgrade.SelectedValue);
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int added = 0;

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                DataTable dtClasses = new DataTable();
                // 修改：查询该年级的所有班级，不限制教师授课班级
                string classSql = "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=" + grade + " AND Sclass > 0 ORDER BY Sclass";
                using (SqlDataAdapter da = new SqlDataAdapter(classSql, conn)) { da.Fill(dtClasses); }

                foreach (DataRow row in dtClasses.Rows)
                {
                    int cls = Convert.ToInt32(row["Sclass"]);
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamPublish WHERE Epid=@pid AND Egrade=@g AND Eclass=@c AND Ehid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", pid);
                        chk.Parameters.AddWithValue("@g", grade);
                        chk.Parameters.AddWithValue("@c", cls);
                        chk.Parameters.AddWithValue("@hid", myHid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0) continue;
                    }
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO ExamPublish(Epid,Ehid,Egrade,Eclass,Estart,Eend,Estatus,Edate) VALUES(@pid,@hid,@g,@c,@start,@end,1,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.Parameters.AddWithValue("@g", grade);
                        cmd.Parameters.AddWithValue("@c", cls);
                        cmd.Parameters.AddWithValue("@start", startTime);
                        cmd.Parameters.AddWithValue("@end", endTime);
                        cmd.ExecuteNonQuery();
                        added++;
                    }
                }
            }
            if (added > 0)
            { pageMsg = "成功发布到 " + grade + "年级的 " + added + " 个班级（包含非授课班级）！"; pageMsgType = "success"; }
            else
            { pageMsg = "所有班级均已发布过此试卷"; pageMsgType = "info"; }
        }
        catch (Exception ex) { pageMsg = "批量发布失败: " + ex.Message; pageMsgType = "error"; }
        BindPublished();
    }

    // ========== 已发布考试列表 ==========
    private void BindPublished()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"SELECT ep.Eid, ep.Epid, ep.Egrade, ep.Eclass, ep.Estart, ep.Eend, ep.Estatus, ep.Edate,
                    ISNULL(p.Ptitle,'[已删除]') AS Ptitle, ISNULL(p.Pcount,0) AS Pcount, ISNULL(p.Ptime,0) AS Ptime, ISNULL(p.Pscore,0) AS Pscore
                    FROM ExamPublish ep LEFT JOIN Paper p ON ep.Epid=p.Pid
                    WHERE ep.Ehid=@hid ORDER BY ep.Edate DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@hid", myHid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                RptPublished.DataSource = dt;
                RptPublished.DataBind();
            }
        }
        catch (Exception ex) { pageMsg = "加载失败: " + ex.Message; pageMsgType = "error"; }
    }

    // ========== 操作 ==========
    protected void RptPublished_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int eid = 0; int.TryParse(e.CommandArgument.ToString(), out eid);
        if (eid <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;

        if (e.CommandName == "ToggleStatus")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("UPDATE ExamPublish SET Estatus=CASE WHEN ISNULL(Estatus,0)=1 THEN 0 ELSE 1 END WHERE Eid=@eid AND Ehid=@hid", conn))
                    { cmd.Parameters.AddWithValue("@eid", eid); cmd.Parameters.AddWithValue("@hid", myHid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "状态已切换"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "操作失败: " + ex.Message; pageMsgType = "error"; }
        }
        else if (e.CommandName == "DelExam")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ExamPublish WHERE Eid=@eid AND Ehid=@hid", conn))
                    { cmd.Parameters.AddWithValue("@eid", eid); cmd.Parameters.AddWithValue("@hid", myHid); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "已删除该发布记录"; pageMsgType = "success";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; pageMsgType = "error"; }
        }
        BindPublished();
    }

    // ========== 批量删除 ==========
    protected void BtnBatchDelete_Click(object sender, EventArgs e)
    {
        string ids = HfBatchIds.Value;
        if (string.IsNullOrEmpty(ids)) { pageMsg = "请先勾选要删除的记录"; pageMsgType = "error"; BindPublished(); return; }
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        int deleted = 0;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string[] idArr = ids.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string idStr in idArr)
                {
                    int eid = 0;
                    if (int.TryParse(idStr.Trim(), out eid) && eid > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand("DELETE FROM ExamPublish WHERE Eid=@eid AND Ehid=@hid", conn))
                        {
                            cmd.Parameters.AddWithValue("@eid", eid);
                            cmd.Parameters.AddWithValue("@hid", myHid);
                            deleted += cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            pageMsg = "成功删除 " + deleted + " 条发布记录"; pageMsgType = "success";
        }
        catch (Exception ex) { pageMsg = "批量删除失败: " + ex.Message; pageMsgType = "error"; }
        HfBatchIds.Value = "";
        BindPublished();
    }

    // ========== 保存编辑 ==========
    protected void BtnSaveEdit_Click(object sender, EventArgs e)
    {
        int eid = 0; int.TryParse(HfEditId.Value, out eid);
        if (eid <= 0) { pageMsg = "无效的编辑记录"; pageMsgType = "error"; BindPublished(); return; }

        int editPid = 0; int.TryParse(DDLeditPaper.SelectedValue, out editPid);
        if (editPid <= 0) { pageMsg = "请选择试卷"; pageMsgType = "error"; BindPublished(); return; }

        DateTime editStart, editEnd;
        if (!DateTime.TryParse(TxtEditStart.Text.Trim(), out editStart))
        { pageMsg = "请输入正确的开始时间"; pageMsgType = "error"; BindPublished(); return; }
        if (!DateTime.TryParse(TxtEditEnd.Text.Trim(), out editEnd))
        { pageMsg = "请输入正确的结束时间"; pageMsgType = "error"; BindPublished(); return; }
        if (editEnd <= editStart)
        { pageMsg = "结束时间必须大于开始时间"; pageMsgType = "error"; BindPublished(); return; }

        int editGrade = int.Parse(DDLeditGrade.SelectedValue);
        
        // 获取选中的班级列表
        string selectedClasses = HfSelectedClasses.Value;
        if (string.IsNullOrEmpty(selectedClasses))
        { pageMsg = "请至少选择一个班级"; pageMsgType = "error"; BindPublished(); return; }

        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                
                string[] classArr = selectedClasses.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (classArr.Length == 0)
                { pageMsg = "请至少选择一个班级"; pageMsgType = "error"; BindPublished(); return; }
                
                // 更新第一个班级到原记录
                int firstClass = int.Parse(classArr[0].Trim());
                
                // 检查是否与其他记录冲突（排除自身）
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamPublish WHERE Epid=@pid AND Egrade=@g AND Eclass=@c AND Ehid=@hid AND Eid<>@eid", conn))
                {
                    chk.Parameters.AddWithValue("@pid", editPid);
                    chk.Parameters.AddWithValue("@g", editGrade);
                    chk.Parameters.AddWithValue("@c", firstClass);
                    chk.Parameters.AddWithValue("@hid", myHid);
                    chk.Parameters.AddWithValue("@eid", eid);
                    int cnt = Convert.ToInt32(chk.ExecuteScalar());
                    if (cnt > 0)
                    { pageMsg = "该试卷已发布到" + firstClass + "班，不能重复"; pageMsgType = "error"; BindPublished(); return; }
                }
                
                using (SqlCommand cmd = new SqlCommand("UPDATE ExamPublish SET Epid=@pid, Egrade=@g, Eclass=@c, Estart=@start, Eend=@end WHERE Eid=@eid AND Ehid=@hid", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", editPid);
                    cmd.Parameters.AddWithValue("@g", editGrade);
                    cmd.Parameters.AddWithValue("@c", firstClass);
                    cmd.Parameters.AddWithValue("@start", editStart);
                    cmd.Parameters.AddWithValue("@end", editEnd);
                    cmd.Parameters.AddWithValue("@eid", eid);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.ExecuteNonQuery();
                }
                
                // 如果选择了多个班级，为其他班级创建新记录
                int added = 0;
                for (int i = 1; i < classArr.Length; i++)
                {
                    int cls = int.Parse(classArr[i].Trim());
                    
                    // 检查是否已存在
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM ExamPublish WHERE Epid=@pid AND Egrade=@g AND Eclass=@c AND Ehid=@hid", conn))
                    {
                        chk.Parameters.AddWithValue("@pid", editPid);
                        chk.Parameters.AddWithValue("@g", editGrade);
                        chk.Parameters.AddWithValue("@c", cls);
                        chk.Parameters.AddWithValue("@hid", myHid);
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0) continue;
                    }
                    
                    // 创建新记录
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO ExamPublish(Epid,Ehid,Egrade,Eclass,Estart,Eend,Estatus,Edate) VALUES(@pid,@hid,@g,@c,@start,@end,1,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", editPid);
                        cmd.Parameters.AddWithValue("@hid", myHid);
                        cmd.Parameters.AddWithValue("@g", editGrade);
                        cmd.Parameters.AddWithValue("@c", cls);
                        cmd.Parameters.AddWithValue("@start", editStart);
                        cmd.Parameters.AddWithValue("@end", editEnd);
                        cmd.ExecuteNonQuery();
                        added++;
                    }
                }
                
                if (added > 0)
                { pageMsg = "编辑保存成功！已为其他 " + added + " 个班级创建新发布记录"; pageMsgType = "success"; }
                else
                { pageMsg = "编辑保存成功！"; pageMsgType = "success"; }
            }
        }
        catch (Exception ex) { pageMsg = "保存失败: " + ex.Message; pageMsgType = "error"; }
        HfEditId.Value = "";
        BindPublished();
    }

    // ========== 辅助方法 ==========
    protected string GetTimeStatus(object startObj, object endObj, object statusObj)
    {
        if (statusObj == null || statusObj == DBNull.Value || Convert.ToInt32(statusObj) == 0)
            return "已暂停";
        DateTime now = DateTime.Now;
        if (startObj != null && startObj != DBNull.Value && endObj != null && endObj != DBNull.Value)
        {
            DateTime start = Convert.ToDateTime(startObj);
            DateTime end = Convert.ToDateTime(endObj);
            if (now < start) return "未开始";
            if (now > end) return "已结束";
            return "考试中";
        }
        return "未知";
    }
    protected string GetTimeStatusClass(object startObj, object endObj, object statusObj)
    {
        string ts = GetTimeStatus(startObj, endObj, statusObj);
        switch (ts)
        {
            case "考试中": return "ep-ts-active";
            case "未开始": return "ep-ts-pending";
            case "已结束": return "ep-ts-ended";
            case "已暂停": return "ep-ts-paused";
            default: return "ep-ts-paused";
        }
    }
    protected string FormatDate(object dateVal)
    {
        if (dateVal == null || dateVal == DBNull.Value) return "";
        try { return Convert.ToDateTime(dateVal).ToString("yyyy-MM-dd HH:mm"); } catch { return ""; }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/airbnb.css" />
<style>
    .ep-page { max-width: 1400px; width: 100%; margin: 0 auto; }
    .ep-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; }
    .ep-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .ep-title-icon { width: 42px; height: 42px; background: linear-gradient(135deg, #6366f1, #818cf8); border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(99,102,241,0.25); }
    .ep-title-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ep-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 54px; }

    /* 消息提示 */
    .ep-msg { padding: 12px 18px; border-radius: 10px; font-size: 13px; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
    .ep-msg svg { width: 18px; height: 18px; flex-shrink: 0; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ep-msg-info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
    .ep-msg-info svg { stroke: #3b82f6; fill: none; }
    .ep-msg-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }
    .ep-msg-success svg { stroke: #22c55e; fill: none; }
    .ep-msg-error { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }
    .ep-msg-error svg { stroke: #ef4444; fill: none; }

    /* 卡片 */
    .ep-card { background: #fff; border-radius: 14px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.02); margin-bottom: 20px; overflow: hidden; }
    .ep-card-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; background: linear-gradient(180deg, #fafbfc, #f8f9fb); font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 10px; }
    .ep-card-head svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ep-card-body { padding: 24px; }

    /* 表单 */
    .ep-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 20px; }
    .ep-form-full { grid-column: 1 / -1; }
    .ep-form-group { display: flex; flex-direction: column; gap: 6px; }
    .ep-form-group label { font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.3px; }
    .ep-form-group select, .ep-form-group input[type="text"] {
        padding: 10px 14px; border-radius: 10px; border: 1.5px solid #e2e8f0; font-size: 13.5px; color: #334155;
        background: #f8fafc; outline: none; transition: all 0.2s; font-family: inherit; width: 100%; box-sizing: border-box;
    }
    .ep-form-group select:focus, .ep-form-group input[type="text"]:focus {
        border-color: #818cf8; background: #fff; box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
    }
    .ep-form-hint { font-size: 11px; color: #94a3b8; margin-top: 2px; }

    /* 按钮 */
    .ep-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 22px; border-radius: 10px; font-size: 13.5px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; font-family: inherit; text-decoration: none; }
    .ep-btn:hover { transform: translateY(-1px); }
    .ep-btn-primary { background: linear-gradient(135deg, #6366f1, #818cf8); color: #fff; box-shadow: 0 4px 14px rgba(99,102,241,0.3); }
    .ep-btn-primary:hover { box-shadow: 0 6px 20px rgba(99,102,241,0.4); }
    .ep-btn-outline { background: #fff; color: #475569; border: 1.5px solid #e2e8f0; box-shadow: none; }
    .ep-btn-outline:hover { border-color: #818cf8; color: #6366f1; background: #f5f3ff; }
    .ep-btn-row { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }

    /* 列表 */
    .ep-list { display: flex; flex-direction: column; gap: 12px; }
    .ep-item { display: flex; align-items: center; padding: 18px 22px; border-radius: 12px; border: 1px solid #f1f5f9; background: #fff; transition: all 0.2s; gap: 18px; }
    .ep-item:hover { border-color: #c7d2fe; box-shadow: 0 4px 16px rgba(99,102,241,0.08); transform: translateY(-1px); }
    .ep-item-icon { width: 52px; height: 52px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .ep-item-icon svg { width: 26px; height: 26px; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; fill: none; }
    .ep-item-icon-active { background: linear-gradient(135deg, #ecfdf5, #d1fae5); }
    .ep-item-icon-active svg { stroke: #059669; }
    .ep-item-icon-paused { background: linear-gradient(135deg, #fef3c7, #fde68a); }
    .ep-item-icon-paused svg { stroke: #d97706; }

    .ep-item-info { flex: 1; min-width: 0; }
    .ep-item-title { font-size: 15px; font-weight: 600; color: #1e293b; margin-bottom: 6px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .ep-item-meta { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .ep-item-meta-tag { font-size: 12px; color: #64748b; display: flex; align-items: center; gap: 4px; }
    .ep-item-meta-tag svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    .ep-item-time { display: flex; flex-direction: column; gap: 4px; font-size: 12px; color: #64748b; min-width: 160px; flex-shrink: 0; }
    .ep-item-time-row { display: flex; align-items: center; gap: 6px; }
    .ep-item-time-row svg { width: 14px; height: 14px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
    .ep-item-time-label { color: #94a3b8; font-weight: 500; width: 30px; }

    .ep-item-actions { display: flex; gap: 6px; flex-shrink: 0; align-items: center; }

    /* 时间状态标签 */
    .ep-ts { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
    .ep-ts-active { background: #dcfce7; color: #166534; }
    .ep-ts-active::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: #22c55e; animation: ep-pulse 2s infinite; }
    .ep-ts-pending { background: #eff6ff; color: #1e40af; }
    .ep-ts-ended { background: #f1f5f9; color: #64748b; }
    .ep-ts-paused { background: #fef3c7; color: #92400e; }
    @keyframes ep-pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }

    /* 操作按钮 */
    .ep-act-btn { display: inline-flex; align-items: center; justify-content: center; gap: 4px; padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.15s; text-decoration: none; font-family: inherit; }
    .ep-act-btn:hover { background: #f1f5f9; border-color: #cbd5e1; }
    .ep-act-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ep-act-btn-toggle { color: #d97706; border-color: #fde68a; }
    .ep-act-btn-toggle:hover { background: #fffbeb; }
    .ep-act-btn-del { color: #ef4444; border-color: #fecaca; }
    .ep-act-btn-del:hover { background: #fef2f2; }
    .ep-act-btn-edit { color: #6366f1; border-color: #c7d2fe; }
    .ep-act-btn-edit:hover { background: #f5f3ff; }

    /* 批量操作工具栏 */
    .ep-batch-bar { display: flex; align-items: center; gap: 14px; padding: 14px 22px; background: linear-gradient(180deg, #f8f9fb, #f1f5f9); border-bottom: 1px solid #e8ecf1; flex-wrap: wrap; }
    .ep-batch-bar label { font-size: 13px; color: #475569; display: flex; align-items: center; gap: 6px; cursor: pointer; user-select: none; font-weight: 500; }
    .ep-batch-bar input[type="checkbox"] { width: 16px; height: 16px; accent-color: #6366f1; cursor: pointer; }
    .ep-batch-count { font-size: 12px; color: #94a3b8; }
    .ep-btn-batch-del { display: inline-flex; align-items: center; gap: 5px; padding: 7px 16px; border-radius: 8px; font-size: 12.5px; font-weight: 600; border: none; cursor: pointer; background: #fef2f2; color: #ef4444; border: 1px solid #fecaca; transition: all 0.15s; font-family: inherit; }
    .ep-btn-batch-del:hover { background: #fee2e2; }
    .ep-btn-batch-del:disabled { opacity: 0.5; cursor: not-allowed; }
    .ep-btn-batch-del svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }

    /* 行内复选框 */
    .ep-item-cb { display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .ep-item-cb input[type="checkbox"] { width: 18px; height: 18px; accent-color: #6366f1; cursor: pointer; }

    /* 编辑表单面板 */
    .ep-edit-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15,23,42,0.4); z-index: 1000; align-items: center; justify-content: center; }
    .ep-edit-overlay.ep-show { display: flex; }
    .ep-edit-panel { background: #fff; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.15); width: 560px; max-width: 95vw; max-height: 90vh; overflow-y: auto; }
    .ep-edit-head { padding: 20px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between; }
    .ep-edit-head-title { font-size: 16px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 8px; }
    .ep-edit-head-title svg { width: 20px; height: 20px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ep-edit-close { width: 32px; height: 32px; border-radius: 8px; border: none; background: #f1f5f9; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s; }
    .ep-edit-close:hover { background: #e2e8f0; }
    .ep-edit-close svg { width: 16px; height: 16px; stroke: #64748b; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .ep-edit-body { padding: 24px; }
    .ep-edit-foot { padding: 16px 24px; border-top: 1px solid #f1f5f9; display: flex; justify-content: flex-end; gap: 10px; }

    /* 空状态 */
    .ep-empty { text-align: center; padding: 60px 20px; }
    .ep-empty-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #f1f5f9, #e2e8f0); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
    .ep-empty-icon svg { width: 40px; height: 40px; stroke: #94a3b8; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
    .ep-empty-text { font-size: 15px; color: #64748b; font-weight: 500; }
    .ep-empty-hint { font-size: 13px; color: #94a3b8; margin-top: 6px; }

    /* 班级选择器 */
    .ep-class-selector { border: 1.5px solid #e2e8f0; border-radius: 10px; background: #f8fafc; overflow: hidden; }
    .ep-class-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; background: #fff; border-bottom: 1px solid #e2e8f0; }
    .ep-class-all { display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; }
    .ep-class-all input[type="checkbox"] { width: 18px; height: 18px; accent-color: #6366f1; cursor: pointer; margin: 0; }
    .ep-class-actions { display: flex; gap: 8px; }
    .ep-class-actions button { padding: 4px 12px; border-radius: 6px; font-size: 12px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all 0.15s; font-family: inherit; }
    .ep-class-actions button:hover { background: #f1f5f9; border-color: #cbd5e1; }
    .ep-class-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 8px; padding: 16px; max-height: 200px; overflow-y: auto; }
    .ep-class-item { display: flex; align-items: center; gap: 6px; padding: 8px 12px; background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; cursor: pointer; transition: all 0.15s; }
    .ep-class-item:hover { background: #f5f3ff; border-color: #c7d2fe; }
    .ep-class-item input[type="checkbox"] { width: 16px; height: 16px; accent-color: #6366f1; cursor: pointer; margin: 0; }
    .ep-class-item label { font-size: 13px; color: #475569; cursor: pointer; user-select: none; margin: 0; }

    /* 时间输入美化 */
    .ep-datetime-wrap { position: relative; }
    .ep-datetime-wrap input { padding-right: 36px !important; cursor: pointer; }
    .ep-datetime-icon { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); pointer-events: none; }
    .ep-datetime-icon svg { width: 16px; height: 16px; stroke: #94a3b8; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    /* flatpickr 补充样式 */
    .flatpickr-calendar { font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, Arial, sans-serif !important; z-index: 10001 !important; }
    .flatpickr-day.selected, .flatpickr-day.selected:hover { background: #6366f1 !important; border-color: #6366f1 !important; }
    .flatpickr-day.today { border-color: #818cf8 !important; }
    .flatpickr-day:hover { background: #e0e7ff !important; }
    .flatpickr-months .flatpickr-month { height: 40px; }
    .flatpickr-current-month { font-size: 14px !important; }
    .flatpickr-time input { font-size: 14px !important; }
    .flatpickr-time .flatpickr-am-pm { display: none; }

    @media (max-width: 768px) {
        .ep-form-grid { grid-template-columns: 1fr; }
        .ep-item { flex-direction: column; align-items: flex-start; }
        .ep-item-actions { width: 100%; justify-content: flex-end; margin-top: 10px; }
        .ep-item-time { flex-direction: row; gap: 16px; }
    }
</style>

<div class="ep-page">
    <div class="ep-header">
        <div>
            <div class="ep-title">
                <span class="ep-title-icon">
                    <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                </span>
                考试发布
            </div>
            <div class="ep-subtitle">将试卷发布到指定班级，管理考试时间和状态</div>
        </div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="ep-msg ep-msg-<%= pageMsgType %>">
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

    <!-- ========== 发布考试 ========== -->
    <div class="ep-card">
        <div class="ep-card-head">
            <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
            发布新考试
        </div>
        <div class="ep-card-body">
            <div class="ep-form-grid">
                <div class="ep-form-group ep-form-full">
                    <label>选择试卷 *</label>
                    <asp:DropDownList ID="DDLpaper" runat="server" />
                    <span class="ep-form-hint">请先在「试卷管理」中创建试卷并添加试题</span>
                </div>
                <div class="ep-form-group">
                    <label>年级 *</label>
                    <asp:DropDownList ID="DDLgrade" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DDLgrade_SelectedIndexChanged" />
                </div>
                <div class="ep-form-group">
                    <label>班级 *</label>
                    <asp:DropDownList ID="DDLclass" runat="server" />
                </div>
                <div class="ep-form-group">
                    <label>开始时间 *</label>
                    <div class="ep-datetime-wrap">
                        <asp:TextBox ID="TxtStart" runat="server" placeholder="2026-02-25 08:00" />
                        <span class="ep-datetime-icon"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></span>
                    </div>
                    <span class="ep-form-hint">格式：yyyy-MM-dd HH:mm</span>
                </div>
                <div class="ep-form-group">
                    <label>结束时间 *</label>
                    <div class="ep-datetime-wrap">
                        <asp:TextBox ID="TxtEnd" runat="server" placeholder="2026-02-25 09:00" />
                        <span class="ep-datetime-icon"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></span>
                    </div>
                    <span class="ep-form-hint">格式：yyyy-MM-dd HH:mm</span>
                </div>
            </div>
            <div class="ep-btn-row">
                <asp:Button ID="BtnPublish" runat="server" Text="发布到该班级" OnClick="BtnPublish_Click" CssClass="ep-btn ep-btn-primary" />
                <asp:Button ID="BtnPublishAll" runat="server" Text="发布到该年级所有班级" OnClick="BtnPublishAll_Click" CssClass="ep-btn ep-btn-outline"
                    OnClientClick="return confirm('确定要将此试卷发布到该年级的所有班级吗？');" />
            </div>
        </div>
    </div>

    <!-- 隐藏字段 -->
    <asp:HiddenField ID="HfBatchIds" runat="server" />
    <asp:HiddenField ID="HfEditId" runat="server" />

    <!-- ========== 已发布考试列表 ========== -->
    <div class="ep-card">
        <div class="ep-card-head">
            <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            已发布考试
        </div>
        <!-- 批量操作工具栏 -->
        <div class="ep-batch-bar">
            <label><input type="checkbox" id="cbSelectAll" onclick="epToggleAll(this)" /> 全选</label>
            <span class="ep-batch-count" id="spanBatchCount">已选 0 项</span>
            <asp:Button ID="BtnBatchDelete" runat="server" Text="批量删除" CssClass="ep-btn-batch-del" OnClick="BtnBatchDelete_Click"
                OnClientClick="return epBeforeBatchDel();" />
        </div>
        <div class="ep-card-body">
            <asp:Repeater ID="RptPublished" runat="server" OnItemCommand="RptPublished_ItemCommand">
                <HeaderTemplate><div class="ep-list"></HeaderTemplate>
                <ItemTemplate>
                    <div class="ep-item">
                        <div class="ep-item-cb">
                            <input type="checkbox" class="ep-row-cb" value='<%# Eval("Eid") %>' onclick="epUpdateCount()" />
                        </div>
                        <div class='ep-item-icon <%# Convert.ToInt32(Eval("Estatus")) == 1 ? "ep-item-icon-active" : "ep-item-icon-paused" %>'>
                            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        </div>
                        <div class="ep-item-info">
                            <div class="ep-item-title">
                                <%# Server.HtmlEncode(Eval("Ptitle").ToString()) %>
                                <span class='ep-ts <%# GetTimeStatusClass(Eval("Estart"), Eval("Eend"), Eval("Estatus")) %>'>
                                    <%# GetTimeStatus(Eval("Estart"), Eval("Eend"), Eval("Estatus")) %>
                                </span>
                            </div>
                            <div class="ep-item-meta">
                                <span class="ep-item-meta-tag">
                                    <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                                    <%# Eval("Egrade") %>年级 <%# Eval("Eclass") %>班
                                </span>
                                <span class="ep-item-meta-tag">
                                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                    <%# Eval("Pcount") %> 题
                                </span>
                                <span class="ep-item-meta-tag">
                                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    <%# Eval("Ptime") %> 分钟
                                </span>
                                <span class="ep-item-meta-tag">
                                    <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                                    <%# Eval("Pscore") %> 分
                                </span>
                            </div>
                        </div>
                        <div class="ep-item-time">
                            <div class="ep-item-time-row">
                                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                <span class="ep-item-time-label">开始</span>
                                <%# FormatDate(Eval("Estart")) %>
                            </div>
                            <div class="ep-item-time-row">
                                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                <span class="ep-item-time-label">结束</span>
                                <%# FormatDate(Eval("Eend")) %>
                            </div>
                        </div>
                        <div class="ep-item-actions">
                            <a href="javascript:void(0)" class="ep-act-btn ep-act-btn-edit"
                                onclick='epOpenEdit(<%# Eval("Eid") %>, "<%# Eval("Epid") %>", "<%# Eval("Egrade") %>", "<%# Eval("Eclass") %>", "<%# FormatDate(Eval("Estart")) %>", "<%# FormatDate(Eval("Eend")) %>")'>
                                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                编辑
                            </a>
                            <asp:LinkButton runat="server" CssClass="ep-act-btn ep-act-btn-toggle" CausesValidation="false"
                                CommandName="ToggleStatus" CommandArgument='<%# Eval("Eid") %>'>
                                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                                <%# Convert.ToInt32(Eval("Estatus")) == 1 ? "暂停" : "启用" %>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="ep-act-btn ep-act-btn-del" CausesValidation="false"
                                CommandName="DelExam" CommandArgument='<%# Eval("Eid") %>'
                                OnClientClick="return confirm('确定要删除此发布记录吗？');">
                                <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                删除
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>

            <asp:Panel ID="PanelEmpty" runat="server" Visible='<%# RptPublished.Items.Count == 0 %>'>
                <div class="ep-empty">
                    <div class="ep-empty-icon">
                        <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                    </div>
                    <div class="ep-empty-text">还没有发布任何考试</div>
                    <div class="ep-empty-hint">在上方选择试卷并设置时间后即可发布考试</div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>

<!-- ========== 编辑弹窗 ========== -->
<div class="ep-edit-overlay" id="epEditOverlay">
    <div class="ep-edit-panel">
        <div class="ep-edit-head">
            <span class="ep-edit-head-title">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                编辑发布记录
            </span>
            <button type="button" class="ep-edit-close" onclick="epCloseEdit()">
                <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="ep-edit-body">
            <div class="ep-form-grid">
                <div class="ep-form-group ep-form-full">
                    <label>选择试卷 *</label>
                    <asp:DropDownList ID="DDLeditPaper" runat="server" />
                </div>
                <div class="ep-form-group">
                    <label>年级 *</label>
                    <asp:DropDownList ID="DDLeditGrade" runat="server" />
                </div>
                <div class="ep-form-group ep-form-full">
                    <label>班级选择 *</label>
                    <div class="ep-class-selector">
                        <div class="ep-class-header">
                            <label class="ep-class-all">
                                <input type="checkbox" id="chkAllGrade" onchange="epToggleAllGrade(this)" />
                                <span>全年级</span>
                            </label>
                            <div class="ep-class-actions">
                                <button type="button" onclick="epSelectAllClasses()">全选</button>
                                <button type="button" onclick="epClearAllClasses()">清空</button>
                            </div>
                        </div>
                        <div class="ep-class-list" id="epClassList">
                            <!-- 动态生成班级复选框 -->
                        </div>
                    </div>
                    <span class="ep-form-hint">可以选择多个班级，或勾选"全年级"选择所有班级</span>
                    <asp:HiddenField ID="HfSelectedClasses" runat="server" />
                </div>
                <div class="ep-form-group">
                    <label>开始时间 *</label>
                    <div class="ep-datetime-wrap">
                        <asp:TextBox ID="TxtEditStart" runat="server" placeholder="2026-02-25 08:00" />
                        <span class="ep-datetime-icon"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></span>
                    </div>
                </div>
                <div class="ep-form-group">
                    <label>结束时间 *</label>
                    <div class="ep-datetime-wrap">
                        <asp:TextBox ID="TxtEditEnd" runat="server" placeholder="2026-02-25 09:00" />
                        <span class="ep-datetime-icon"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></span>
                    </div>
                </div>
            </div>
        </div>
        <div class="ep-edit-foot">
            <button type="button" class="ep-btn ep-btn-outline" onclick="epCloseEdit()">取消</button>
            <asp:Button ID="BtnSaveEdit" runat="server" Text="保存修改" CssClass="ep-btn ep-btn-primary" OnClick="BtnSaveEdit_Click" />
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/zh.js"></script>
<script type="text/javascript">
    // ========== flatpickr 日期时间选择器 ==========
    var epFpConfig = {
        locale: 'zh',
        enableTime: true,
        time_24hr: true,
        dateFormat: 'Y-m-d H:i',
        minuteIncrement: 5,
        allowInput: true,
        disableMobile: true
    };
    var fpStart, fpEnd, fpEditStart, fpEditEnd;
    $(function () {
        // 发布表单的开始/结束时间
        var startEl = $('[id$="TxtStart"]').not('[id$="TxtEditStart"]')[0];
        var endEl = $('[id$="TxtEnd"]').not('[id$="TxtEditEnd"]')[0];
        if (startEl) {
            fpStart = flatpickr(startEl, $.extend({}, epFpConfig, {
                defaultDate: startEl.value || new Date(),
                onChange: function (dates) {
                    if (fpEnd && dates[0]) {
                        fpEnd.set('minDate', dates[0]);
                    }
                }
            }));
        }
        if (endEl) {
            var defEnd = endEl.value || new Date(new Date().getTime() + 60 * 60 * 1000);
            fpEnd = flatpickr(endEl, $.extend({}, epFpConfig, {
                defaultDate: defEnd,
                minDate: fpStart ? fpStart.selectedDates[0] : null
            }));
        }
        // 自动填充默认时间
        if (startEl && !startEl.value && fpStart) {
            fpStart.setDate(new Date(), true);
        }
        if (endEl && !endEl.value && fpEnd) {
            fpEnd.setDate(new Date(new Date().getTime() + 60 * 60 * 1000), true);
        }

        // 编辑弹窗的开始/结束时间
        var editStartEl = $('[id$="TxtEditStart"]')[0];
        var editEndEl = $('[id$="TxtEditEnd"]')[0];
        if (editStartEl) {
            fpEditStart = flatpickr(editStartEl, $.extend({}, epFpConfig, {
                onChange: function (dates) {
                    if (fpEditEnd && dates[0]) {
                        fpEditEnd.set('minDate', dates[0]);
                    }
                }
            }));
        }
        if (editEndEl) {
            fpEditEnd = flatpickr(editEndEl, $.extend({}, epFpConfig));
        }
    });

    // ========== 批量选择 ==========
    function epToggleAll(master) {
        var cbs = document.querySelectorAll('.ep-row-cb');
        for (var i = 0; i < cbs.length; i++) { cbs[i].checked = master.checked; }
        epUpdateCount();
    }
    function epUpdateCount() {
        var cbs = document.querySelectorAll('.ep-row-cb:checked');
        var span = document.getElementById('spanBatchCount');
        if (span) span.textContent = '已选 ' + cbs.length + ' 项';
        var all = document.querySelectorAll('.ep-row-cb');
        var master = document.getElementById('cbSelectAll');
        if (master) master.checked = all.length > 0 && cbs.length === all.length;
    }
    function epBeforeBatchDel() {
        var cbs = document.querySelectorAll('.ep-row-cb:checked');
        if (cbs.length === 0) { alert('请先勾选要删除的记录'); return false; }
        if (!confirm('确定要删除选中的 ' + cbs.length + ' 条发布记录吗？')) return false;
        var ids = [];
        for (var i = 0; i < cbs.length; i++) { ids.push(cbs[i].value); }
        var hf = document.querySelector('[id$="HfBatchIds"]');
        if (hf) hf.value = ids.join(',');
        return true;
    }

    // ========== 班级选择器 ==========
    function epLoadClassesForEdit(grade) {
        var classList = document.getElementById('epClassList');
        if (!classList) return;
        
        classList.innerHTML = '<div style="padding: 20px; text-align: center; color: #94a3b8;">加载中...</div>';
        
        setTimeout(function() {
            var ddlClass = document.querySelector('[id$="DDLclass"]');
            if (!ddlClass) {
                classList.innerHTML = '<div style="padding: 20px; text-align: center; color: #ef4444;">无法加载班级列表</div>';
                return;
            }
            
            classList.innerHTML = '';
            var hasClasses = false;
            for (var i = 0; i < ddlClass.options.length; i++) {
                var opt = ddlClass.options[i];
                var cls = opt.value;
                if (!cls || cls === '0') continue;
                
                hasClasses = true;
                var div = document.createElement('div');
                div.className = 'ep-class-item';
                div.innerHTML = 
                    '<input type="checkbox" id="chkClass' + cls + '" value="' + cls + '" onchange="epUpdateClassSelection()" />' +
                    '<label for="chkClass' + cls + '">' + opt.text + '</label>';
                classList.appendChild(div);
            }
            
            if (!hasClasses) {
                classList.innerHTML = '<div style="padding: 20px; text-align: center; color: #94a3b8;">该年级暂无班级</div>';
            }
        }, 100);
    }

    function epToggleAllGrade(checkbox) {
        var checkboxes = document.querySelectorAll('.ep-class-list input[type="checkbox"]');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checkbox.checked;
        }
        epUpdateClassSelection();
    }

    function epSelectAllClasses() {
        var checkboxes = document.querySelectorAll('.ep-class-list input[type="checkbox"]');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = true;
        }
        epUpdateClassSelection();
    }

    function epClearAllClasses() {
        var checkboxes = document.querySelectorAll('.ep-class-list input[type="checkbox"]');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }
        document.getElementById('chkAllGrade').checked = false;
        epUpdateClassSelection();
    }

    function epUpdateClassSelection() {
        var checkboxes = document.querySelectorAll('.ep-class-list input[type="checkbox"]');
        var checked = document.querySelectorAll('.ep-class-list input[type="checkbox"]:checked');
        var allGrade = document.getElementById('chkAllGrade');
        
        if (allGrade) {
            allGrade.checked = checked.length > 0 && checked.length === checkboxes.length;
        }
        
        // 更新隐藏字段
        var selectedClasses = [];
        for (var i = 0; i < checked.length; i++) {
            selectedClasses.push(checked[i].value);
        }
        var hf = document.querySelector('[id$="HfSelectedClasses"]');
        if (hf) hf.value = selectedClasses.join(',');
    }

    // ========== 编辑弹窗 ==========
    function epOpenEdit(eid, epid, egrade, eclass, estart, eend) {
        var hf = document.querySelector('[id$="HfEditId"]');
        if (hf) hf.value = eid;
        
        // 设置试卷下拉框
        var ddlPaper = document.querySelector('[id$="DDLeditPaper"]');
        if (ddlPaper) ddlPaper.value = epid;
        
        // 设置年级下拉框
        var ddlGrade = document.querySelector('[id$="DDLeditGrade"]');
        if (ddlGrade) ddlGrade.value = egrade;
        
        // 加载班级列表
        epLoadClassesForEdit(egrade);
        
        // 选中当前班级（支持多个班级，逗号分隔）
        setTimeout(function() {
            var classes = eclass.toString().split(',');
            for (var i = 0; i < classes.length; i++) {
                var cls = classes[i].trim();
                var cb = document.getElementById('chkClass' + cls);
                if (cb) cb.checked = true;
            }
            epUpdateClassSelection();
        }, 200);
        
        // 设置时间（使用 flatpickr API）
        if (fpEditStart) fpEditStart.setDate(estart, true);
        if (fpEditEnd) fpEditEnd.setDate(eend, true);
        
        document.getElementById('epEditOverlay').classList.add('ep-show');
    }

    function epCloseEdit() {
        document.getElementById('epEditOverlay').classList.remove('ep-show');
    }
    
    // 点击遮罩关闭
    $(function () {
        $('#epEditOverlay').on('click', function (e) {
            if (e.target === this) epCloseEdit();
        });
    });
</script>
</asp:Content>
