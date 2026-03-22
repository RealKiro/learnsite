#pragma checksum "C:\inetpub\wwwroot\LearnSite\manager\password_migration.aspx.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "75F0318D95C5DDD5D3EF131BCD910E1B"

#line 1 "C:\inetpub\wwwroot\LearnSite\manager\password_migration.aspx.cs"
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

public partial class manager_password_migration : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadStatistics();
        }
    }

    private void LoadStatistics()
    {
        string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // 教师统计
            string teacherSql = @"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN Hsalt IS NULL OR Hsalt = '' THEN 1 ELSE 0 END) as Pending,
                    SUM(CASE WHEN Hsalt IS NOT NULL AND Hsalt != '' THEN 1 ELSE 0 END) as Completed
                FROM Teacher";

            SqlCommand teacherCmd = new SqlCommand(teacherSql, conn);
            SqlDataReader teacherReader = teacherCmd.ExecuteReader();

            if (teacherReader.Read())
            {
                int total = Convert.ToInt32(teacherReader["Total"]);
                int pending = Convert.ToInt32(teacherReader["Pending"]);
                int completed = Convert.ToInt32(teacherReader["Completed"]);

                LitTeacherTotal.Text = total.ToString();
                LitTeacherPending.Text = pending.ToString();
                LitTeacherCompleted.Text = completed.ToString();

                // 更新状态标签
                if (pending == 0 && total > 0)
                {
                    teacherBadge.Attributes["class"] = "card-badge badge-completed";
                    teacherBadge.InnerText = "已完成";
                    BtnMigrateTeacher.Enabled = false;
                    BtnMigrateTeacher.Text = "已完成迁移";
                }
                else
                {
                    teacherBadge.Attributes["class"] = "card-badge badge-pending";
                    teacherBadge.InnerText = "待迁移";
                }
            }
            teacherReader.Close();

            // 学生统计
            string studentSql = @"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN Ssalt IS NULL OR Ssalt = '' THEN 1 ELSE 0 END) as Pending,
                    SUM(CASE WHEN Ssalt IS NOT NULL AND Ssalt != '' THEN 1 ELSE 0 END) as Completed
                FROM Students";

            SqlCommand studentCmd = new SqlCommand(studentSql, conn);
            SqlDataReader studentReader = studentCmd.ExecuteReader();

            if (studentReader.Read())
            {
                int total = Convert.ToInt32(studentReader["Total"]);
                int pending = Convert.ToInt32(studentReader["Pending"]);
                int completed = Convert.ToInt32(studentReader["Completed"]);

                LitStudentTotal.Text = total.ToString();
                LitStudentPending.Text = pending.ToString();
                LitStudentCompleted.Text = completed.ToString();

                // 更新状态标签
                if (pending == 0 && total > 0)
                {
                    studentBadge.Attributes["class"] = "card-badge badge-completed";
                    studentBadge.InnerText = "已完成";
                    BtnMigrateStudent.Enabled = false;
                    BtnMigrateStudent.Text = "已完成迁移";
                }
                else
                {
                    studentBadge.Attributes["class"] = "card-badge badge-pending";
                    studentBadge.InnerText = "待迁移";
                }
            }
            studentReader.Close();
        }
    }

    protected void BtnMigrateTeacher_Click(object sender, EventArgs e)
    {
        try
        {
            int count = SecurityHelper.MigrateTeacherPasswords();
            ShowMessage("success", string.Format("成功迁移 {0} 个教师账号的密码！", count));
            LoadStatistics();
        }
        catch (Exception ex)
        {
            ShowMessage("error", "迁移失败：" + ex.Message);
        }
    }

    protected void BtnMigrateStudent_Click(object sender, EventArgs e)
    {
        try
        {
            int count = SecurityHelper.MigrateStudentPasswords();
            ShowMessage("success", string.Format("成功迁移 {0} 个学生账号的密码！", count));
            LoadStatistics();
        }
        catch (Exception ex)
        {
            ShowMessage("error", "迁移失败：" + ex.Message);
        }
    }

    private void ShowMessage(string type, string message)
    {
        PanelMessage.Visible = true;
        LitMessage.Text = message;

        if (type == "success")
        {
            messageAlert.Attributes["class"] = "alert alert-success";
        }
        else if (type == "error")
        {
            messageAlert.Attributes["class"] = "alert alert-error";
        }
        else
        {
            messageAlert.Attributes["class"] = "alert alert-info";
        }
    }
}


#line default
#line hidden
