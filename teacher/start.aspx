<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_start, LearnSite" %>
<%@ Register Assembly="Anthem" Namespace="Anthem" TagPrefix="anthem" %>

<script runat="server">
    private string SyncGetConnStr()
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

    /// <summary>
    /// 校区选择改变事件：重新加载年级列表
    /// </summary>
    protected void DDLSchool_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（如果存在）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("DDLSchool_SelectedIndexChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 重新加载年级列表（根据选中的校区筛选）
            LoadGradesBySchool();
        }
        catch { }
    }
    
    /// <summary>
    /// 年级选择改变事件：重新加载班级列表
    /// 同时捕获基类 showLock() 可能的 NullReferenceException（roomModel 为 null 时）
    /// </summary>
    protected void DDLgrade_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（showClass/showLock/showkc/ShowSigin 等）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("DDLgrade_SelectedIndexChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 按校区重新过滤班级列表（确保与 createroom.aspx 数据同步）
            LoadClassesBySchoolAndGrade();
        }
        catch { }
    }

    private static bool MenuIconContains(string text, string token)
    {
        return !string.IsNullOrEmpty(text) &&
            text.IndexOf(token, StringComparison.OrdinalIgnoreCase) >= 0;
    }

    private string ResolveMenuIconType(object titleObj, object imgUrlObj)
    {
        string title = titleObj == null ? "" : titleObj.ToString();
        string imgUrl = imgUrlObj == null ? "" : imgUrlObj.ToString();
        string text = (title + " " + imgUrl).ToLowerInvariant();

        if (MenuIconContains(text, "思维") || MenuIconContains(text, "导图") || MenuIconContains(text, "mind"))
            return "mind";
        if (MenuIconContains(text, "填表") || MenuIconContains(text, "表单") || MenuIconContains(text, "form"))
            return "form";
        if (MenuIconContains(text, "问卷") || MenuIconContains(text, "survey"))
            return "survey";
        if (MenuIconContains(text, "excel") || MenuIconContains(text, "xls") || MenuIconContains(text, "表格"))
            return "sheet";
        if (MenuIconContains(text, "python") || MenuIconContains(text, "py") || MenuIconContains(text, "编程"))
            return "code";
        if (MenuIconContains(text, "测试") || MenuIconContains(text, "测验") || MenuIconContains(text, "quiz") || MenuIconContains(text, "exam"))
            return "quiz";
        if (MenuIconContains(text, "活动") || MenuIconContains(text, "任务") || MenuIconContains(text, "project"))
            return "activity";
        if (MenuIconContains(text, "学案") || MenuIconContains(text, "lesson") || MenuIconContains(text, "课程") || MenuIconContains(text, "课件"))
            return "lesson";

        return "generic";
    }

    protected string GetMenuSvg(object titleObj, object imgUrlObj)
    {
        string type = ResolveMenuIconType(titleObj, imgUrlObj);
        string svg = "";

        switch (type)
        {
            case "lesson":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M5 4.5h11a3 3 0 0 1 3 3V19H8a3 3 0 0 0-3 3z'/><path d='M8 4.5v17.5'/><path d='M11 8h5'/><path d='M11 11h5'/></svg>";
                break;
            case "quiz":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M9 3h6l4 4v13a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z'/><path d='M9 12l2 2 4-4'/><path d='M15 3v4h4'/></svg>";
                break;
            case "mind":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><circle cx='6' cy='12' r='2'/><circle cx='18' cy='6' r='2'/><circle cx='18' cy='18' r='2'/><circle cx='12' cy='12' r='2'/><path d='M8 12h2'/><path d='M14 11l2.5-3'/><path d='M14 13l2.5 3'/></svg>";
                break;
            case "form":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='5' y='4' width='14' height='16' rx='2'/><path d='M8 8h8'/><path d='M8 12h5'/><path d='M8 16h6'/></svg>";
                break;
            case "survey":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M7 3h7l5 5v13H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z'/><path d='M14 3v5h5'/><path d='M9 15l2 2 4-5'/></svg>";
                break;
            case "sheet":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='4' y='3' width='16' height='18' rx='2'/><path d='M4 9h16'/><path d='M10 9v12'/><path d='M16 9v12'/><path d='M4 15h16'/></svg>";
                break;
            case "code":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><rect x='3' y='4' width='18' height='16' rx='2'/><path d='M8 10l-2 2 2 2'/><path d='M12 16l2-8'/><path d='M16 10l2 2-2 2'/></svg>";
                break;
            case "activity":
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M12 3l2.7 5.5L21 9.4l-4.5 4.3 1.1 6.3L12 17.1 6.4 20l1.1-6.3L3 9.4l6.3-.9z'/></svg>";
                break;
            default:
                svg = "<svg viewBox='0 0 24 24' aria-hidden='true'><path d='M7 3h7l5 5v13H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z'/><path d='M14 3v5h5'/><path d='M9 13h6'/><path d='M9 17h4'/></svg>";
                break;
        }

        return "<span class='sp-menu-icon sp-menu-icon-" + type + "'>" + svg + "</span>";
    }

    private string GetCurrentSortValue()
    {
        if (RBsort != null && !string.IsNullOrEmpty(RBsort.SelectedValue))
        {
            return RBsort.SelectedValue;
        }
        return "1";
    }

    protected bool IsSeatViewMode()
    {
        return GetCurrentSortValue() == "3";
    }

    protected string GetSortModeText()
    {
        switch (GetCurrentSortValue())
        {
            case "3": return "机房座位视图";
            case "0": return "主机排序";
            case "2": return "小组排序";
            default: return "学号排序";
        }
    }

    protected string GetSortModeHint()
    {
        switch (GetCurrentSortValue())
        {
            case "3": return "当前按机房座位布局展示，便于查看整机房在线分布。";
            case "0": return "当前按主机号顺序展示，适合按设备位置快速定位学生。";
            case "2": return "当前按小组顺序展示，适合查看协作分组状态。";
            default: return "当前按学号顺序展示，适合点名和常规巡课。";
        }
    }

    protected string GetSortModeClass()
    {
        switch (GetCurrentSortValue())
        {
            case "3": return "mode-seat";
            case "0": return "mode-host";
            case "2": return "mode-group";
            default: return "mode-number";
        }
    }

    protected string GetOnlineCardCssClass()
    {
        return IsSeatViewMode() ? "sp-card sp-card-seat-mode" : "sp-card";
    }

    protected string GetControlsCssClass()
    {
        return IsSeatViewMode() ? "sp-controls sp-controls-seat-mode" : "sp-controls";
    }

    private static bool IsZeroLike(string value)
    {
        if (string.IsNullOrEmpty(value) || value.Trim().Length == 0)
        {
            return true;
        }

        value = value.Trim();
        return value == "0" || value == "00" || value == "000";
    }

    private string GetSeatFrameUrl(bool embed)
    {
        string url = ResolveUrl("~/teacher/myseat.aspx");
        string joiner = url.IndexOf('?') >= 0 ? "&" : "?";
        if (embed)
        {
            url += joiner + "embed=1";
            joiner = "&";
        }
        if (DDLhouse != null && !string.IsNullOrEmpty(DDLhouse.SelectedValue))
        {
            url += joiner + "hid=" + Server.UrlEncode(DDLhouse.SelectedValue);
        }
        return url;
    }

    private void ClearStudentPanels()
    {
        if (DLonline != null)
        {
            DLonline.DataSource = null;
            DLonline.DataBind();
            DLonline.Visible = true;
        }
        if (DLnotline != null)
        {
            DLnotline.DataSource = null;
            DLnotline.DataBind();
        }
        if (Labelsigin != null) Labelsigin.Text = "0";
        if (Labelsigno != null) Labelsigno.Text = "0";
        if (PlaceHolderSeatView != null) PlaceHolderSeatView.Visible = false;
    }

    private void RefreshSeatViewLink()
    {
        if (HyperLinkSeat != null)
        {
            HyperLinkSeat.NavigateUrl = GetSeatFrameUrl(false);
        }
    }

    private void RefreshStudentPanels()
    {
        RefreshSeatViewLink();

        if (DDLgrade == null || DDLgrade.Items.Count == 0 || DDLclass == null || DDLclass.Items.Count == 0)
        {
            ClearStudentPanels();
            return;
        }

        try
        {
            int sgrade = int.Parse(DDLgrade.SelectedValue);
            int sclass = int.Parse(DDLclass.SelectedValue);

            if (!ValidateClassBelongsToSchool(sgrade, sclass))
            {
                ClearStudentPanels();
                return;
            }

            DateTime now = DateTime.Now;
            string sortValue = GetCurrentSortValue();
            string dataSort = sortValue == "3" ? "0" : sortValue;

            LearnSite.BLL.Signin signin = new LearnSite.BLL.Signin();
            DLonline.DataSource = signin.StartSignClass(sgrade, sclass, now.Year, now.Month, now.Day, dataSort);
            DLonline.DataBind();
            DLonline.RepeatColumns = 9;
            DLonline.Visible = (sortValue != "3");

            if (Labelsigin != null)
            {
                Labelsigin.Text = DLonline.Items.Count.ToString();
            }
            if (PlaceHolderSeatView != null)
            {
                PlaceHolderSeatView.Visible = (sortValue == "3");
            }

            LearnSite.BLL.Students stuBll = new LearnSite.BLL.Students();
            int syear = stuBll.GetYear(sgrade, sclass);
            DLnotline.DataSource = signin.StartNoSignClassTwo(sgrade, sclass, syear, now.Year, now.Month, now.Day);
            DLnotline.DataBind();
            if (Labelsigno != null)
            {
                Labelsigno.Text = DLnotline.Items.Count.ToString();
            }
        }
        catch (Exception refreshEx)
        {
            ClearStudentPanels();
            if (Labelsigno != null)
            {
                Labelsigno.Text = "ERR:" + refreshEx.Message;
            }
        }
    }

    protected void RBsort_SelectedIndexChanged(object sender, EventArgs e)
    {
        RefreshStudentPanels();
    }
    
    /// <summary>
    /// 加载校区下拉列表（与 manager/studentlist.aspx 保持一致）
    /// </summary>
    private void LoadSchoolDropdown()
    {
        if (DDLSchool == null) return;
        
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 检查 School 表是否存在
                string checkSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                System.Data.SqlClient.SqlCommand cmdCheck = new System.Data.SqlClient.SqlCommand(checkSql, conn);
                int tableExists = (int)cmdCheck.ExecuteScalar();
                
                DDLSchool.Items.Clear();
                DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem("全部校区", ""));
                
                if (tableExists > 0)
                {
                    // 使用 School 表（与 studentlist.aspx 一致）
                    string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive=1 ORDER BY SchoolId";
                    
                    System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader();
                    
                    while (reader.Read())
                    {
                        string schoolId = reader["SchoolId"].ToString();
                        string schoolName = reader["SchoolName"].ToString();
                        
                        DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem(schoolName, schoolId));
                    }
                    reader.Close();
                }
                else
                {
                    // 如果 School 表不存在，使用 Students.Scampus 作为备用
                    string sql = @"
                        SELECT DISTINCT Scampus 
                        FROM Students 
                        WHERE Scampus IS NOT NULL AND Scampus <> ''
                        ORDER BY Scampus";
                    
                    System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn);
                    System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader();
                    
                    while (reader.Read())
                    {
                        string campus = reader["Scampus"].ToString();
                        DDLSchool.Items.Add(new System.Web.UI.WebControls.ListItem(campus, campus));
                    }
                    reader.Close();
                }
            }
            
            // 默认选中"全部校区"
            if (DDLSchool.Items.Count > 0)
            {
                DDLSchool.SelectedIndex = 0;
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 根据选中的校区加载年级列表（通过Room.SchoolId筛选，与 manager/createroom.aspx 保持一致）
    /// </summary>
    private void LoadGradesBySchool()
    {
        if (DDLSchool == null || DDLgrade == null) return;
        
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 检查 Room 表是否有 SchoolId 字段（与 createroom.aspx 保持一致）
                string checkSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Room' AND COLUMN_NAME = 'SchoolId'";
                
                bool roomHasSchoolId = false;
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkSql, conn))
                {
                    checkCmd.CommandTimeout = 5;
                    int fieldCount = (int)checkCmd.ExecuteScalar();
                    roomHasSchoolId = (fieldCount > 0);
                }
                
                string sql = "";
                
                // 如果选择了特定校区且Room表有SchoolId字段，通过Room表筛选年级（与 createroom.aspx 保持一致）
                if (roomHasSchoolId && !string.IsNullOrEmpty(DDLSchool.SelectedValue))
                {
                    sql = @"
                        SELECT DISTINCT Rgrade 
                        FROM Room 
                        WHERE SchoolId = @SchoolId
                        ORDER BY Rgrade";
                }
                else
                {
                    // 否则显示所有年级（从Room表获取）
                    sql = @"
                        SELECT DISTINCT Rgrade 
                        FROM Room 
                        ORDER BY Rgrade";
                }
                
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    if (roomHasSchoolId && !string.IsNullOrEmpty(DDLSchool.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@SchoolId", int.Parse(DDLSchool.SelectedValue));
                    }
                    cmd.CommandTimeout = 5;
                    
                    DDLgrade.Items.Clear();
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string grade = dr[0].ToString();
                            DDLgrade.Items.Add(new System.Web.UI.WebControls.ListItem(grade, grade));
                        }
                    }
                }
            }
            
            // 触发年级改变事件，重新加载班级
            if (DDLgrade.Items.Count > 0)
            {
                LoadClassesBySchoolAndGrade();
            }
            else
            {
                // 清空班级列表
                if (DDLclass != null)
                {
                    DDLclass.Items.Clear();
                }
                
                // 清空学生列表
                try
                {
                    if (DLonline != null)
                    {
                        DLonline.DataSource = null;
                        DLonline.DataBind();
                    }
                    if (DLnotline != null)
                    {
                        DLnotline.DataSource = null;
                        DLnotline.DataBind();
                    }
                    if (Labelsigin != null) Labelsigin.Text = "0";
                    if (Labelsigno != null) Labelsigno.Text = "0";
                }
                catch { }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 根据选中的校区和年级加载班级列表（通过Room.SchoolId筛选，与 manager/createroom.aspx 保持一致）
    /// </summary>
    private void LoadClassesBySchoolAndGrade()
    {
        if (DDLSchool == null || DDLgrade == null || DDLclass == null) return;
        if (DDLgrade.Items.Count == 0) return;
        
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 检查 Room 表是否有 SchoolId 字段（与 createroom.aspx 保持一致）
                string checkSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Room' AND COLUMN_NAME = 'SchoolId'";
                
                bool roomHasSchoolId = false;
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkSql, conn))
                {
                    checkCmd.CommandTimeout = 5;
                    int fieldCount = (int)checkCmd.ExecuteScalar();
                    roomHasSchoolId = (fieldCount > 0);
                }
                
                string sql = "";
                
                // 如果选择了特定校区且Room表有SchoolId字段，通过Room表筛选班级（与 createroom.aspx 保持一致）
                if (roomHasSchoolId && !string.IsNullOrEmpty(DDLSchool.SelectedValue))
                {
                    sql = @"
                        SELECT DISTINCT Rclass 
                        FROM Room 
                        WHERE SchoolId = @SchoolId AND Rgrade = @Rgrade
                        ORDER BY Rclass";
                }
                else
                {
                    // 否则显示该年级的所有班级（从Room表获取）
                    sql = @"
                        SELECT DISTINCT Rclass 
                        FROM Room 
                        WHERE Rgrade = @Rgrade
                        ORDER BY Rclass";
                }
                
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    if (roomHasSchoolId && !string.IsNullOrEmpty(DDLSchool.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@SchoolId", int.Parse(DDLSchool.SelectedValue));
                        cmd.Parameters.AddWithValue("@Rgrade", int.Parse(DDLgrade.SelectedValue));
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Rgrade", int.Parse(DDLgrade.SelectedValue));
                    }
                    cmd.CommandTimeout = 5;
                    
                    DDLclass.Items.Clear();
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string cls = dr[0].ToString();
                            DDLclass.Items.Add(new System.Web.UI.WebControls.ListItem(cls, cls));
                        }
                    }
                }
            }
            
            // 触发班级改变事件，重新加载学生
            if (DDLclass.Items.Count > 0)
            {
                try
                {
                    // 调用基类的 DDLclass_SelectedIndexChanged 方法
                    System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("DDLclass_SelectedIndexChanged",
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                    if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                    {
                        baseMethod.Invoke(this, new object[] { DDLclass, EventArgs.Empty });
                    }
                }
                catch { }
            }
            else
            {
                // 清空学生列表
                try
                {
                    if (DLonline != null)
                    {
                        DLonline.DataSource = null;
                        DLonline.DataBind();
                    }
                    if (DLnotline != null)
                    {
                        DLnotline.DataSource = null;
                        DLnotline.DataBind();
                    }
                    if (Labelsigin != null) Labelsigin.Text = "0";
                    if (Labelsigno != null) Labelsigno.Text = "0";
                }
                catch { }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 验证指定的班级是否属于当前选中的校区（通过Room.SchoolId判断，与 manager/createroom.aspx 保持一致）
    /// </summary>
    private bool ValidateClassBelongsToSchool(int grade, int cls)
    {
        // 如果没有选择特定校区（全部校区），则不需要验证
        if (DDLSchool == null || string.IsNullOrEmpty(DDLSchool.SelectedValue))
        {
            return true;
        }
        
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return true;
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 检查 Room 表是否有 SchoolId 字段（与 createroom.aspx 保持一致）
                string checkSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Room' AND COLUMN_NAME = 'SchoolId'";
                
                bool roomHasSchoolId = false;
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkSql, conn))
                {
                    checkCmd.CommandTimeout = 5;
                    int fieldCount = (int)checkCmd.ExecuteScalar();
                    roomHasSchoolId = (fieldCount > 0);
                }
                
                // 如果字段不存在，默认允许（向后兼容）
                if (!roomHasSchoolId)
                {
                    return true;
                }
                
                // 检查该班级是否属于选中的校区（通过Room表）
                string sql = @"
                    SELECT COUNT(*) 
                    FROM Room 
                    WHERE Rgrade = @Rgrade 
                    AND Rclass = @Rclass 
                    AND SchoolId = @SchoolId";
                
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Rgrade", grade);
                    cmd.Parameters.AddWithValue("@Rclass", cls);
                    cmd.Parameters.AddWithValue("@SchoolId", int.Parse(DDLSchool.SelectedValue));
                    cmd.CommandTimeout = 5;
                    
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
        }
        catch
        {
            // 如果验证失败，默认允许（向后兼容）
            return true;
        }
    }

    /// <summary>
    /// 同步学生学分：先汇总课堂评分到 Students.Sattitude，再同步到 Students.Sscore
    /// </summary>
    private void SyncStudentScores(int grade, int cls)
    {
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string syncAttitudeSql = @"UPDATE Students
                    SET Sattitude = ISNULL((
                        SELECT SUM(ISNULL(si.Qattitude,0))
                        FROM Signin si
                        WHERE si.Qnum = Students.Snum
                          AND ISNULL(si.Qgrade,0) = Students.Sgrade
                          AND ISNULL(si.Qclass,0) = Students.Sclass
                    ), 0)
                    WHERE Sgrade=@g AND Sclass=@c";
                using (System.Data.SqlClient.SqlCommand cmdAttitude = new System.Data.SqlClient.SqlCommand(syncAttitudeSql, conn))
                {
                    cmdAttitude.Parameters.AddWithValue("@g", grade);
                    cmdAttitude.Parameters.AddWithValue("@c", cls);
                    cmdAttitude.CommandTimeout = 10;
                    cmdAttitude.ExecuteNonQuery();
                }

                // 学分总分 = 作品分 + 课堂表现分，保持与 creditscore.aspx 一致
                string sql = @"UPDATE Students
                    SET Sscore = ISNULL((
                        SELECT SUM(ISNULL(w.Wscore,0) + ISNULL(w.Wdscore,0))
                        FROM Works w
                        WHERE w.Wnum = Students.Snum AND w.Wscore > 0
                    ), 0) + ISNULL(Students.Sattitude,0)
                    WHERE Sgrade=@g AND Sclass=@c";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@g", grade);
                    cmd.Parameters.AddWithValue("@c", cls);
                    cmd.CommandTimeout = 10;
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    /// <summary>
    /// 加载机房下拉列表（从House表获取）
    /// </summary>
    private void LoadHouseDropdown()
    {
        if (DDLhouse == null) return;
        
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                string sql = "SELECT Hid, Hname FROM House ORDER BY Hid";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 5;
                    DDLhouse.Items.Clear();
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string hid = dr["Hid"].ToString();
                            string hname = dr["Hname"].ToString();
                            DDLhouse.Items.Add(new System.Web.UI.WebControls.ListItem(hname, hid));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    protected override void OnLoad(EventArgs e)
    {
        try
        {
            // 首次加载时初始化校区下拉列表
            if (!IsPostBack && DDLSchool != null)
            {
                LoadSchoolDropdown();
            }
            
            base.OnLoad(e);
        }
        catch (Exception)
        {
            // Page_Load may have partially executed before throwing
            // (e.g. Showkc/showLock throws NullRef, preventing ShowSigin/ShowNoSigin from running)
        }
        
        // 恢复机房下拉列表：如果基类未能加载，则手动从House表加载
        try
        {
            if (DDLhouse != null && DDLhouse.Items.Count == 0)
            {
                LoadHouseDropdown();
            }
        }
        catch { }

        // 同步学分：每次加载页面时按“作品分 + 表现分”重算 Sscore
        try
        {
            if (DDLgrade != null && DDLgrade.Items.Count > 0
                && DDLclass != null && DDLclass.Items.Count > 0)
            {
                int syncGrade = int.Parse(DDLgrade.SelectedValue);
                int syncClass = int.Parse(DDLclass.SelectedValue);
                
                // 验证当前班级是否属于选中的校区
                if (ValidateClassBelongsToSchool(syncGrade, syncClass))
                {
                    SyncStudentScores(syncGrade, syncClass);
                }
            }
        }
        catch { }

        RefreshStudentPanels();

        // Recover showLock settings
        try
        {
            if (string.IsNullOrEmpty(TBpwd.Text))
            {
                int rgrade = int.Parse(DDLgrade.SelectedValue);
                int rclass = int.Parse(DDLclass.SelectedValue);
                LearnSite.BLL.Room roomBll = new LearnSite.BLL.Room();
                LearnSite.Model.Room roomModel = roomBll.GetModel(rgrade, rclass);
                if (roomModel != null)
                {
                    CheckBoxip.Checked = roomModel.Rlock;
                    CheckBoxOpen.Checked = roomModel.Ropen;
                    CheckBoxRgauge.Checked = roomModel.Rgauge;
                    CheckBoxPwd.Checked = roomModel.Rpwdsee;
                    CheckBoxShare.Checked = roomModel.Rshare;
                    CheckBoxGroupShare.Checked = roomModel.Rgroupshare;
                    CheckBoxScratch.Checked = roomModel.Rscratch;
                    CheckBoxLogin.Checked = roomModel.Rlogin;
                    CheckBoxPass.Checked = roomModel.Rpass;
                    TBpwd.Text = roomModel.Rpwd;
                    
                    // 设置游戏开关状态（默认为开启）
                    try
                    {
                        System.Reflection.PropertyInfo gameProp = roomModel.GetType().GetProperty("Rgame");
                        if (gameProp != null)
                        {
                            object gameValue = gameProp.GetValue(roomModel, null);
                            if (gameValue != null && gameValue != DBNull.Value)
                            {
                                CheckBoxGame.Checked = Convert.ToBoolean(gameValue);
                            }
                            else
                            {
                                CheckBoxGame.Checked = true; // 默认开启
                            }
                        }
                        else
                        {
                            // DLL模型中没有Rgame属性，直接从数据库读取
                            CheckBoxGame.Checked = ReadRoomBoolColumn(rgrade, rclass, "Rgame", true);
                        }
                    }
                    catch
                    {
                        CheckBoxGame.Checked = true; // 出错时默认开启
                    }
                    
                    // 设置小组讨论开关状态（默认为开启）
                    try
                    {
                        System.Reflection.PropertyInfo discussProp = roomModel.GetType().GetProperty("Rdiscuss");
                        if (discussProp != null)
                        {
                            object discussValue = discussProp.GetValue(roomModel, null);
                            if (discussValue != null && discussValue != DBNull.Value)
                            {
                                CheckBoxDiscuss.Checked = Convert.ToBoolean(discussValue);
                            }
                            else
                            {
                                CheckBoxDiscuss.Checked = true; // 默认开启
                            }
                        }
                        else
                        {
                            // DLL模型中没有Rdiscuss属性，直接从数据库读取
                            CheckBoxDiscuss.Checked = ReadRoomBoolColumn(rgrade, rclass, "Rdiscuss", true);
                        }
                    }
                    catch
                    {
                        CheckBoxDiscuss.Checked = true; // 出错时默认开启
                    }
                    
                    // 设置AI对话开关状态（默认为开启）
                    try
                    {
                        System.Reflection.PropertyInfo aiProp = roomModel.GetType().GetProperty("Rai");
                        if (aiProp != null)
                        {
                            object aiValue = aiProp.GetValue(roomModel, null);
                            if (aiValue != null && aiValue != DBNull.Value)
                            {
                                CheckBoxAI.Checked = Convert.ToBoolean(aiValue);
                            }
                            else
                            {
                                CheckBoxAI.Checked = true; // 默认开启
                            }
                        }
                        else
                        {
                            // DLL模型中没有Rai属性，直接从数据库读取
                            CheckBoxAI.Checked = ReadRoomBoolColumn(rgrade, rclass, "Rai", true);
                        }
                    }
                    catch
                    {
                        CheckBoxAI.Checked = true; // 出错时默认开启
                    }
                }
            }
        }
        catch { }
        // Fallback: ensure quick-link HyperLinks have NavigateUrl
        try
        {
            string cid = DDLCid != null && DDLCid.SelectedValue != null ? DDLCid.SelectedValue : "";
            string qCid = !string.IsNullOrEmpty(cid) ? "?cid=" + cid : "";

            if (HLrate != null && string.IsNullOrEmpty(HLrate.NavigateUrl))
                HLrate.NavigateUrl = "~/teacher/learnrate.aspx" + qCid;
            if (HLworkshow != null && string.IsNullOrEmpty(HLworkshow.NavigateUrl))
                HLworkshow.NavigateUrl = "~/teacher/workshow.aspx" + qCid;
            if (HLtotal != null && string.IsNullOrEmpty(HLtotal.NavigateUrl))
                HLtotal.NavigateUrl = "~/teacher/coursetotal.aspx" + qCid;
        }
        catch { }
    }
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        
        // 控制班级密码显示：当启用个人模式或密码不可见时，隐藏密码
        ShowClassPassword();
        
        // 在线学生卡片上的状态徽标：主机排序/机房视图时显示主机号，其余模式显示学分
        try
        {
            if (DDLgrade == null || DDLclass == null || DDLgrade.Items.Count == 0 || DDLclass.Items.Count == 0) return;
            int grade = int.Parse(DDLgrade.SelectedValue);
            int cls = int.Parse(DDLclass.SelectedValue);
            string cs = SyncGetConnStr();
            if (string.IsNullOrEmpty(cs)) return;

            System.Collections.Generic.Dictionary<string, int> creditMap = new System.Collections.Generic.Dictionary<string, int>();
            System.Collections.Generic.Dictionary<string, string> signinMachineMap = new System.Collections.Generic.Dictionary<string, string>();
            System.Collections.Generic.Dictionary<string, string> computerMachineMap = new System.Collections.Generic.Dictionary<string, string>();
            DateTime now = DateTime.Now;
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Snum, ISNULL(Sscore,0) FROM Students WHERE Sgrade=@g AND Sclass=@c", conn))
                {
                    cmd.Parameters.AddWithValue("@g", grade);
                    cmd.Parameters.AddWithValue("@c", cls);
                    cmd.CommandTimeout = 5;
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            creditMap[dr[0].ToString()] = Convert.ToInt32(dr[1]);
                    }
                }

                using (System.Data.SqlClient.SqlCommand cmdSignin = new System.Data.SqlClient.SqlCommand(
                    "SELECT Qnum, ISNULL(Qmachine,'') FROM Signin WHERE Qgrade=@g AND Qclass=@c AND Qyear=@y AND Qmonth=@m AND Qday=@d ORDER BY Qid", conn))
                {
                    cmdSignin.Parameters.AddWithValue("@g", grade);
                    cmdSignin.Parameters.AddWithValue("@c", cls);
                    cmdSignin.Parameters.AddWithValue("@y", now.Year);
                    cmdSignin.Parameters.AddWithValue("@m", now.Month);
                    cmdSignin.Parameters.AddWithValue("@d", now.Day);
                    cmdSignin.CommandTimeout = 5;
                    using (System.Data.SqlClient.SqlDataReader drSignin = cmdSignin.ExecuteReader())
                    {
                        while (drSignin.Read())
                        {
                            string snumKey = drSignin[0].ToString();
                            string machineValue = drSignin[1].ToString();
                            signinMachineMap[snumKey] = machineValue;
                        }
                    }
                }

                using (System.Data.SqlClient.SqlCommand cmdComputer = new System.Data.SqlClient.SqlCommand(
                    "SELECT Pnum, ISNULL(Pmachine,'') FROM Computers WHERE Pnum IS NOT NULL AND Pnum<>''", conn))
                {
                    cmdComputer.CommandTimeout = 5;
                    using (System.Data.SqlClient.SqlDataReader drComputer = cmdComputer.ExecuteReader())
                    {
                        while (drComputer.Read())
                        {
                            string snumKey = drComputer[0].ToString();
                            if (!computerMachineMap.ContainsKey(snumKey))
                            {
                                computerMachineMap[snumKey] = drComputer[1].ToString();
                            }
                        }
                    }
                }
            }

            foreach (System.Web.UI.WebControls.DataListItem item in DLonline.Items)
            {
                if (item.ItemType != System.Web.UI.WebControls.ListItemType.Item &&
                    item.ItemType != System.Web.UI.WebControls.ListItemType.AlternatingItem) continue;
                System.Web.UI.WebControls.Label lblNum = item.FindControl("Labelqnum") as System.Web.UI.WebControls.Label;
                System.Web.UI.WebControls.Label lblMachine = item.FindControl("LabelQmachine") as System.Web.UI.WebControls.Label;
                System.Web.UI.WebControls.Label lblCredit = item.FindControl("LabelCredit") as System.Web.UI.WebControls.Label;
                if (lblNum != null && lblCredit != null)
                {
                    string snum = lblNum.Text.Trim();
                    string machineText = lblMachine != null ? lblMachine.Text.Trim() : "";
                    int score = 0;
                    if (creditMap.ContainsKey(snum)) score = creditMap[snum];

                    if (IsZeroLike(machineText) && signinMachineMap.ContainsKey(snum))
                    {
                        machineText = signinMachineMap[snum];
                    }
                    if (IsZeroLike(machineText) && computerMachineMap.ContainsKey(snum))
                    {
                        machineText = computerMachineMap[snum];
                    }

                    if (GetCurrentSortValue() == "0" || GetCurrentSortValue() == "3")
                    {
                        if (IsZeroLike(machineText))
                        {
                            lblCredit.Text = "未设主机";
                            lblCredit.ToolTip = "当前学生没有绑定主机号";
                            lblCredit.CssClass = "stu-credit-badge badge-host-empty";
                        }
                        else
                        {
                            lblCredit.Text = "主机 " + machineText;
                            lblCredit.ToolTip = "当前主机号：" + machineText;
                            lblCredit.CssClass = "stu-credit-badge badge-host";
                        }
                    }
                    else
                    {
                        lblCredit.Text = "学分 " + score.ToString();
                        lblCredit.ToolTip = "当前学分：" + score.ToString();
                        lblCredit.CssClass = score > 0 ? "stu-credit-badge badge-credit badge-credit-has" : "stu-credit-badge badge-credit";
                    }
                }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 控制班级密码显示：当班级启用个人模式（Rlogin=true）或密码不可见（Rpwdsee=false）时，不显示班级密码
    /// </summary>
    private void ShowClassPassword()
    {
        try
        {
            if (TBpwd == null || DDLgrade == null || DDLclass == null) return;
            if (DDLgrade.Items.Count == 0 || DDLclass.Items.Count == 0) return;
            
            int grade = int.Parse(DDLgrade.SelectedValue);
            int cls = int.Parse(DDLclass.SelectedValue);
            
            LearnSite.BLL.Room roomBll = new LearnSite.BLL.Room();
            LearnSite.Model.Room roomModel = roomBll.GetModel(grade, cls);
            
            if (roomModel != null)
            {
                // 当启用个人模式（Rlogin=true）或密码不可见（Rpwdsee=false）时，隐藏密码
                bool shouldHidePassword = roomModel.Rlogin || !roomModel.Rpwdsee;
                
                if (shouldHidePassword)
                {
                    TBpwd.Text = "****";
                    TBpwd.ToolTip = "班级已启用个人模式或密码已隐藏";
                }
                else
                {
                    // 显示实际密码
                    TBpwd.Text = roomModel.Rpwd;
                    TBpwd.ToolTip = "班级密码";
                }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 游戏开关复选框状态改变事件
    /// </summary>
    protected void CheckBoxGame_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（如果存在）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("CheckBoxGame_CheckedChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 更新游戏开关状态到数据库
            if (CheckBoxGame != null)
            {
                UpdateRoomSetting("Rgame", CheckBoxGame.Checked);
                // 同步写入 games.json 全局开关，供游戏管理页显示
                UpdateGlobalGameEnabled(CheckBoxGame.Checked);
                string gameMsg = CheckBoxGame.Checked ? "游戏已开启" : "游戏已关闭";
                string gameOn = CheckBoxGame.Checked ? "true" : "false";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "gameAlert", "showToast('" + gameMsg + "'," + gameOn + ");", true);
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 小组讨论开关复选框状态改变事件
    /// </summary>
    protected void CheckBoxDiscuss_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（如果存在）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("CheckBoxDiscuss_CheckedChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 更新小组讨论开关状态到数据库
            if (CheckBoxDiscuss != null)
            {
                UpdateRoomSetting("Rdiscuss", CheckBoxDiscuss.Checked);
                string discussMsg = CheckBoxDiscuss.Checked ? "小组讨论已开启" : "小组讨论已关闭";
                string discussOn = CheckBoxDiscuss.Checked ? "true" : "false";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "discussAlert", "showToast('" + discussMsg + "'," + discussOn + ");", true);
            }
        }
        catch { }
    }
    
    /// <summary>
    /// AI对话开关复选框状态改变事件
    /// </summary>
    protected void CheckBoxAI_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（如果存在）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("CheckBoxAI_CheckedChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 更新AI对话开关状态到数据库
            if (CheckBoxAI != null)
            {
                UpdateRoomSetting("Rai", CheckBoxAI.Checked);
                string aiMsg = CheckBoxAI.Checked ? "AI对话已开启" : "AI对话已关闭";
                string aiOn = CheckBoxAI.Checked ? "true" : "false";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "aiAlert", "showToast('" + aiMsg + "'," + aiOn + ");", true);
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 班级密码复选框状态改变事件：当选中时，自动取消个人模式
    /// </summary>
    protected void CheckBoxPwd_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（如果存在）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("CheckBoxPwd_CheckedChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 互斥逻辑：当选中班级密码时，自动取消个人模式
            if (CheckBoxPwd != null && CheckBoxLogin != null)
            {
                if (CheckBoxPwd.Checked)
                {
                    CheckBoxLogin.Checked = false;
                    // 同步更新数据库
                    UpdateRoomSetting("Rlogin", false);
                }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 个人模式复选框状态改变事件：当选中时，自动取消班级密码
    /// </summary>
    protected void CheckBoxLogin_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            // 调用基类方法（如果存在）
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("CheckBoxLogin_CheckedChanged",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null && baseMethod.DeclaringType != this.GetType())
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
            }
            catch { }
            
            // 互斥逻辑：当选中个人模式时，自动取消班级密码
            if (CheckBoxLogin != null && CheckBoxPwd != null)
            {
                if (CheckBoxLogin.Checked)
                {
                    CheckBoxPwd.Checked = false;
                    // 同步更新数据库
                    UpdateRoomSetting("Rpwdsee", false);
                }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 更新班级设置到数据库
    /// </summary>
    private void UpdateRoomSetting(string fieldName, bool value)
    {
        try
        {
            if (DDLgrade == null || DDLclass == null) return;
            if (DDLgrade.Items.Count == 0 || DDLclass.Items.Count == 0) return;
            
            int grade = int.Parse(DDLgrade.SelectedValue);
            int cls = int.Parse(DDLclass.SelectedValue);
            
            string cs = SyncGetConnStr();
            if (string.IsNullOrEmpty(cs)) return;
            
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // 对于新增开关字段（Rai/Rdiscuss/Rgame），自动创建列（若不存在）
                EnsureRoomBoolColumn(conn, fieldName);
                string sql = string.Format("UPDATE Room SET [{0}]=@Value WHERE Rgrade=@Grade AND Rclass=@Class", fieldName);
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Value", value);
                    cmd.Parameters.AddWithValue("@Grade", grade);
                    cmd.Parameters.AddWithValue("@Class", cls);
                    cmd.CommandTimeout = 5;
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 同步更新 games.json 的 globalEnabled 字段，使游戏管理页可读取当前游戏开关状态
    /// </summary>
    private void UpdateGlobalGameEnabled(bool enabled)
    {
        try
        {
            string gamesPath = Server.MapPath("~/App_Data/games.json");
            if (!System.IO.File.Exists(gamesPath)) return;
            string json = System.IO.File.ReadAllText(gamesPath, System.Text.Encoding.UTF8);
            string newJson;
            System.Text.RegularExpressions.Match m =
                System.Text.RegularExpressions.Regex.Match(json, "\"globalEnabled\"\\s*:\\s*(true|false)");
            if (m.Success)
            {
                newJson = json.Substring(0, m.Index)
                    + "\"globalEnabled\":" + (enabled ? "true" : "false")
                    + json.Substring(m.Index + m.Length);
            }
            else
            {
                // 若字段不存在则插入到 JSON 对象开头
                int brace = json.IndexOf('{');
                if (brace < 0) return;
                newJson = json.Substring(0, brace + 1)
                    + "\"globalEnabled\":" + (enabled ? "true" : "false") + ","
                    + json.Substring(brace + 1);
            }
            System.IO.File.WriteAllText(gamesPath, newJson, System.Text.Encoding.UTF8);
        }
        catch { }
    }

    /// <summary>
    /// 自动在Room表中创建指定布尔列（仅限已知新增开关列：Rai/Rdiscuss/Rgame）
    /// </summary>
    private void EnsureRoomBoolColumn(System.Data.SqlClient.SqlConnection conn, string columnName)
    {
        if (columnName != "Rai" && columnName != "Rdiscuss" && columnName != "Rgame") return;
        try
        {
            string sql = "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID(N'[dbo].[Room]') AND name='" 
                + columnName + "') "
                + "ALTER TABLE [dbo].[Room] ADD [" + columnName + "] bit NOT NULL DEFAULT 1";
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }
    
    /// <summary>
    /// 从数据库直接读取Room表中的布尔列值（当编译DLL的Room模型中没有该属性时使用）
    /// </summary>
    private bool ReadRoomBoolColumn(int grade, int cls, string columnName, bool defaultValue)
    {
        string cs = SyncGetConnStr();
        if (string.IsNullOrEmpty(cs)) return defaultValue;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT ISNULL([" + columnName + "],1) FROM Room WHERE Rgrade=@Grade AND Rclass=@Class";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Grade", grade);
                    cmd.Parameters.AddWithValue("@Class", cls);
                    cmd.CommandTimeout = 5;
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        return Convert.ToBoolean(result);
                }
            }
        }
        catch { }
        return defaultValue;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ===== Start Page Global ===== */
    .sp { width: 100%; margin: 0 auto; font-size: 13px; color: #334155; }
    .sp *, .sp *::before, .sp *::after { box-sizing: border-box; }

    /* Card base */
    .sp-card {
        background: #fff; 
        border-radius: 16px; 
        border: 1px solid #e5e7eb;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.02);
        margin-bottom: 20px; 
        overflow: hidden;
    }
    .sp-card-head {
        display: flex; 
        align-items: center; 
        gap: 12px;
        padding: 16px 24px; 
        border-bottom: 1px solid #f1f5f9;
        font-size: 15px; 
        font-weight: 600; 
        color: #1e293b;
        background: linear-gradient(135deg, #fafbfc 0%, #f8fafc 100%);
    }
    .sp-card-head .sp-icon {
        width: 36px; 
        height: 36px; 
        border-radius: 10px;
        display: flex; 
        align-items: center; 
        justify-content: center; 
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    }
    .sp-card-head .sp-icon svg { 
        width: 20px; 
        height: 20px; 
        fill: none; 
        stroke-width: 2; 
        stroke-linecap: round; 
        stroke-linejoin: round; 
    }
    .sp-card-head .sp-badge {
        font-size: 12px; 
        font-weight: 500; 
        border-radius: 20px;
        padding: 3px 12px; 
        margin-left: 6px;
    }
    .sp-card-body { 
        padding: 20px 24px; 
    }

    /* ===== Toolbar ===== */
    .sp-toolbar {
        display: flex; align-items: center; flex-wrap: nowrap; gap: 5px;
        padding: 12px 16px;
        background: linear-gradient(135deg, #6366f1 0%, #7c3aed 50%, #8b5cf6 100%);
        border-radius: 14px; margin-bottom: 16px;
        box-shadow: 0 4px 20px rgba(99,102,241,0.22), inset 0 1px 0 rgba(255,255,255,0.1);
        position: relative;
        z-index: 1;
        overflow-x: auto;
        overflow-y: hidden;
        -webkit-overflow-scrolling: touch;
    }
    .sp-toolbar::-webkit-scrollbar {
        height: 4px;
    }
    .sp-toolbar::-webkit-scrollbar-track {
        background: rgba(255,255,255,0.1);
        border-radius: 2px;
    }
    .sp-toolbar::-webkit-scrollbar-thumb {
        background: rgba(255,255,255,0.3);
        border-radius: 2px;
    }
    .sp-toolbar::-webkit-scrollbar-thumb:hover {
        background: rgba(255,255,255,0.5);
    }
    .sp-toolbar::before {
        content: ''; position: absolute; top: -40%; right: -10%; width: 220px; height: 220px;
        background: radial-gradient(circle, rgba(255,255,255,0.08) 0%, transparent 70%);
        pointer-events: none;
        z-index: 0;
    }
    .sp-toolbar > * {
        position: relative;
        z-index: 2;
    }
    .sp-toolbar .sp-tb-label {
        font-size: 12.5px; font-weight: 700; color: #fff; margin-right: 3px;
        display: flex; align-items: center; gap: 5px; position: relative;
        white-space: nowrap; flex-shrink: 0;
    }
    .sp-toolbar .sp-tb-label svg { width: 16px; height: 16px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sp-toolbar select {
        height: 32px !important; border-radius: 8px !important;
        border: 1px solid rgba(255,255,255,0.3) !important;
        background: rgba(255,255,255,0.88) !important; color: #312e81 !important;
        font-size: 11.5px !important; font-weight: 500 !important;
        padding: 0 8px !important; outline: none !important;
        box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        flex-shrink: 0;
    }
    .sp-toolbar select option { color: #312e81 !important; background: #fff !important; }
    .sp-toolbar select option:checked { background: #eef2ff !important; }
    .sp-toolbar select:focus { border-color: rgba(255,255,255,0.6) !important; box-shadow: 0 0 0 2px rgba(255,255,255,0.2); }
    .sp-toolbar input[type="submit"] {
        height: 32px !important; border-radius: 8px !important; border: 1px solid rgba(255,255,255,0.25) !important;
        background: rgba(255,255,255,0.18) !important; color: #fff !important;
        font-size: 11.5px !important; font-weight: 600 !important; padding: 0 12px !important;
        cursor: pointer !important; transition: all 0.2s !important; white-space: nowrap;
        backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
        position: relative !important; z-index: 10 !important;
        pointer-events: auto !important;
        -webkit-appearance: none !important;
        appearance: none !important;
        flex-shrink: 0;
    }
    .sp-toolbar input[type="submit"]:hover { 
        background: rgba(255,255,255,0.32) !important; 
        transform: translateY(-1px);
        box-shadow: 0 2px 8px rgba(0,0,0,0.15) !important;
    }
    .sp-toolbar input[type="submit"]:active { 
        transform: translateY(0);
        background: rgba(255,255,255,0.25) !important;
    }
    .sp-toolbar input[type="submit"]:disabled {
        opacity: 0.5 !important;
        cursor: not-allowed !important;
    }
    .sp-toolbar input[type="text"] {
        height: 32px !important; border-radius: 8px !important; border: 1px solid rgba(255,255,255,0.25) !important;
        background: rgba(255,255,255,0.12) !important; color: #fff !important;
        font-size: 11.5px !important; padding: 0 6px !important; width: 60px !important;
        text-align: center !important; letter-spacing: 1px;
        flex-shrink: 0;
    }
    .sp-tb-sep { width: 1px; height: 24px; background: rgba(255,255,255,0.18); margin: 0 3px; flex-shrink: 0; }
    .sp-toolbar a, .sp-toolbar a:link, .sp-toolbar a:visited {
        display: inline-flex !important; align-items: center; height: 32px;
        padding: 0 10px !important; border-radius: 8px !important;
        background: rgba(255,255,255,0.1) !important; color: #fff !important;
        font-size: 11.5px !important; text-decoration: none !important; font-weight: 500;
        transition: all 0.2s; white-space: nowrap;
        width: auto !important; border: 1px solid rgba(255,255,255,0.15) !important;
        position: relative; z-index: 1; cursor: pointer;
        flex-shrink: 0;
    }
    .sp-toolbar a:hover { background: rgba(255,255,255,0.25) !important; border-color: rgba(255,255,255,0.3) !important; }

    /* 游戏开关样式 - 与链接按钮保持一致 */
    .sp-toolbar .sp-game-switch {
        display: inline-flex !important; align-items: center; height: 32px;
        padding: 0 8px !important; border-radius: 8px !important;
        background: rgba(255,255,255,0.1) !important; color: #fff !important;
        font-size: 11.5px !important; font-weight: 500;
        transition: all 0.2s; white-space: nowrap;
        border: 1px solid rgba(255,255,255,0.15) !important;
        position: relative; z-index: 1; cursor: pointer;
        margin: 0 !important;
        flex-shrink: 0;
    }
    .sp-toolbar .sp-game-switch:hover {
        background: rgba(255,255,255,0.25) !important;
        border-color: rgba(255,255,255,0.3) !important;
    }
    .sp-toolbar .sp-game-switch input[type="checkbox"] {
        margin: 0 4px 0 0 !important;
        cursor: pointer;
        width: 14px;
        height: 14px;
        accent-color: #fff;
        flex-shrink: 0;
    }
    .sp-toolbar .sp-game-switch label {
        cursor: pointer;
        margin: 0 !important;
        color: #fff !important;
        font-size: 11.5px !important;
        font-weight: 500;
        white-space: nowrap;
    }

    /* ===== Menu ===== */
    .sp-menu-wrap { 
        display: flex; 
        flex-wrap: wrap; 
        gap: 10px; 
        align-items: flex-start;
        padding: 14px 16px;
        -webkit-overflow-scrolling: touch;
    }
    /* DataList RepeatLayout="Flow" wraps each item in <span> */
    .sp-menu-wrap > span {
        display: inline-flex !important;
        flex-shrink: 0;
    }
    /* Card for each activity item */
    .sp-menu-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 6px;
        padding: 10px 9px 9px;
        background: #fff;
        border: 1.5px solid #e5e7eb;
        border-radius: 12px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(.4,0,.2,1);
        min-width: 72px;
        width: auto;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 2px 8px rgba(0,0,0,0.02);
        position: relative;
        overflow: hidden;
    }
    .sp-menu-item::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 2px;
        background: linear-gradient(90deg, #6366f1, #8b5cf6);
        border-radius: 12px 12px 0 0;
        opacity: 0;
        transition: opacity 0.2s;
    }
    .sp-menu-item:hover {
        border-color: #a5b4fc;
        background: linear-gradient(145deg, #f5f3ff, #eff6ff);
        box-shadow: 0 6px 20px rgba(99,102,241,0.15), 0 2px 8px rgba(0,0,0,0.04);
        transform: translateY(-2px);
    }
    .sp-menu-item:hover::before { opacity: 1; }
    .sp-menu-body {
        position: relative;
        z-index: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 6px;
        pointer-events: none;
    }
    .sp-menu-trigger {
        position: absolute !important;
        inset: 0;
        width: 100% !important;
        height: 100% !important;
        opacity: 0;
        cursor: pointer;
        z-index: 2;
        margin: 0 !important;
        border: none !important;
    }
    .sp-menu-icon {
        width: 40px;
        height: 40px;
        border-radius: 11px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(145deg, #f8fafc, #eef2ff);
        border: 1px solid #e2e8f0;
        color: #6366f1;
        box-shadow: 0 2px 8px rgba(15,23,42,0.08);
        transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
    }
    .sp-menu-icon svg {
        width: 21px;
        height: 21px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }
    .sp-menu-item:hover .sp-menu-icon {
        transform: translateY(-1px);
        border-color: rgba(99,102,241,0.3);
        box-shadow: 0 6px 16px rgba(99,102,241,0.16);
    }
    .sp-menu-icon-lesson { background: linear-gradient(145deg, #eef2ff, #e0e7ff); color: #4f46e5; }
    .sp-menu-icon-quiz { background: linear-gradient(145deg, #eff6ff, #dbeafe); color: #2563eb; }
    .sp-menu-icon-mind { background: linear-gradient(145deg, #ecfeff, #cffafe); color: #0891b2; }
    .sp-menu-icon-form { background: linear-gradient(145deg, #fef3c7, #fde68a); color: #d97706; }
    .sp-menu-icon-survey { background: linear-gradient(145deg, #fef2f2, #fee2e2); color: #dc2626; }
    .sp-menu-icon-sheet { background: linear-gradient(145deg, #ecfdf5, #d1fae5); color: #16a34a; }
    .sp-menu-icon-code { background: linear-gradient(145deg, #ede9fe, #ddd6fe); color: #7c3aed; }
    .sp-menu-icon-activity { background: linear-gradient(145deg, #fff7ed, #fed7aa); color: #ea580c; }
    .sp-menu-icon-generic { background: linear-gradient(145deg, #f8fafc, #e2e8f0); color: #475569; }
    .sp-menu-title {
        font-size: 11px !important;
        font-weight: 600 !important;
        color: #475569 !important;
        text-align: center !important;
        white-space: normal !important;
        line-height: 1.3 !important;
        max-width: 68px !important;
        word-break: break-all;
        display: block !important;
    }
    .sp-menu-item:hover .sp-menu-title { color: #4338ca !important; }

    /* ===== Legend ===== */
    .sp-legend {
        display: flex; align-items: center; flex-wrap: wrap; gap: 6px;
        padding: 12px 20px; background: linear-gradient(135deg, #f8fafc 0%, #eef2ff 100%);
        border-bottom: 1px solid #e0e7ff; font-size: 11.5px; color: #64748b;
    }
    .sp-legend-item {
        display: inline-flex; align-items: center; gap: 5px;
        background: #fff; border: 1px solid #e2e8f0; border-radius: 20px;
        padding: 4px 10px 4px 7px; font-size: 11px; color: #475569;
        transition: all 0.15s; cursor: default;
    }
    .sp-legend-item:hover { border-color: #a5b4fc; box-shadow: 0 1px 6px rgba(99,102,241,0.1); }
    .sp-legend-dot {
        display: inline-block !important; width: 14px !important; height: 14px !important;
        border-radius: 4px !important; box-shadow: 0 1px 3px rgba(0,0,0,0.12);
    }
    .sp-legend .sp-stat {
        margin-left: auto; font-weight: 600; color: #6366f1; font-size: 12.5px;
        background: #fff; border: 1.5px solid #c7d2fe; border-radius: 20px;
        padding: 5px 16px; display: inline-flex; align-items: center; gap: 6px;
    }
    .sp-legend .sp-stat::before {
        content: ''; display: inline-block; width: 7px; height: 7px;
        background: #22c55e; border-radius: 50%; box-shadow: 0 0 0 2px rgba(34,197,94,0.2);
        animation: sp-pulse 2s ease-in-out infinite;
    }
    @keyframes sp-pulse { 0%,100% { opacity: 1; box-shadow: 0 0 0 2px rgba(34,197,94,0.2); } 50% { opacity: 0.5; box-shadow: 0 0 0 4px rgba(34,197,94,0.1); } }

    /* ===== Student Grid ===== */
    .sp-student-grid { text-align: center; padding: 16px 20px; }
    .sp-student-grid table { margin: 0 auto; }
    .sp-student-grid .divonline {
        background: #ffffff !important;
        border: none !important; 
        border-radius: 16px !important;
        padding: 0 !important; 
        margin: 7px !important; 
        min-width: 120px;
        width: auto !important; 
        transition: all 0.3s cubic-bezier(.4,0,.2,1); 
        position: relative;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(100,100,180,0.1), 0 1px 3px rgba(0,0,0,0.04);
    }
    .sp-student-grid .divonline:hover {
        box-shadow: 0 12px 32px rgba(99,102,241,0.2), 0 4px 12px rgba(0,0,0,0.06);
        transform: translateY(-4px);
    }
    /* 学号行 */
    .sp-student-grid .divonline > div:first-child {
        position: relative; z-index: 1;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
        padding: 10px 12px;
        margin-bottom: 0;
        font-size: 11px; 
        color: #fff; 
        font-weight: 700; 
        letter-spacing: 1px;
        text-align: center;
        font-family: 'Consolas', 'Monaco', monospace;
    }
    /* 姓名行 */
    .sp-student-grid .divonline > div:nth-child(2) {
        position: relative; z-index: 1;
        margin: 0; padding: 14px 12px 10px;
        text-align: center;
    }
    /* 机器信息行 */
    .sp-student-grid .divonline > div:nth-child(3) {
        font-size: 10px;
        color: #94a3b8;
        padding: 0 12px;
        text-align: center;
    }
    /* 操作行 */
    .sp-student-grid .divonline > div:nth-child(4) {
        padding: 8px 12px 12px;
        display: flex; align-items: center; justify-content: center; gap: 6px;
        border-top: 1px solid #f1f5f9;
        margin-top: 6px;
    }
    /* 小旗子图片替换为CSS图标 */
    .sp-student-grid .divonline > div:nth-child(4) > a:first-child {
        display: inline-flex !important; align-items: center; justify-content: center;
        width: 24px !important; height: 24px !important;
        background: linear-gradient(135deg, #fef3c7, #fde68a) !important;
        border: none !important; border-radius: 50% !important;
        text-decoration: none !important; font-size: 0 !important;
        color: transparent !important; overflow: hidden;
        transition: all 0.2s; flex-shrink: 0;
    }
    .sp-student-grid .divonline > div:nth-child(4) > a:first-child img {
        display: none !important;
    }
    .sp-student-grid .divonline > div:nth-child(4) > a:first-child::before {
        content: '';
        display: block; width: 14px; height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23d97706' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z'/%3E%3Cline x1='4' y1='22' x2='4' y2='15'/%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat; background-position: center;
    }
    .sp-student-grid .divonline > div:nth-child(4) > a:first-child:hover {
        background: linear-gradient(135deg, #fde68a, #fbbf24) !important;
        transform: scale(1.15);
    }
    /* 隐藏数据行 */
    .sp-student-grid .divonline > div:nth-child(5) {
        display: none;
    }
    .sp-student-grid .divunline {
        background: #ffffff !important;
        border: 2px solid #fde68a !important; 
        border-radius: 12px !important;
        padding: 14px 12px 12px !important; 
        margin: 6px !important; 
        min-width: 110px;
        width: auto !important; 
        transition: all 0.25s ease;
        position: relative; 
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .sp-student-grid .divunline::before {
        content: ''; 
        position: absolute; 
        top: 0; 
        left: 0; 
        right: 0; 
        height: 4px;
        background: linear-gradient(90deg, #f59e0b, #f97316); 
        border-radius: 12px 12px 0 0;
    }
    .sp-student-grid .divunline:hover {
        border-color: #fbbf24 !important;
        box-shadow: 0 8px 24px rgba(245,158,11,0.18), 0 2px 6px rgba(0,0,0,0.06);
        transform: translateY(-3px);
    }
    .sp-student-grid .divunline .stu-num {
        font-size: 11px; 
        color: #9ca3af; 
        font-weight: 500; 
        letter-spacing: 0.3px;
        margin-bottom: 8px;
        font-family: 'Consolas', 'Monaco', monospace;
    }
    .sp-student-grid .divunline .stu-avatar {
        width: 42px; 
        height: 42px; 
        border-radius: 50%; 
        margin: 0 auto 8px;
        background: linear-gradient(135deg, #fef3c7, #fde68a);
        display: flex; 
        align-items: center; 
        justify-content: center;
        font-size: 16px; 
        color: #d97706; 
        font-weight: 700;
        box-shadow: 0 2px 8px rgba(217,119,6,0.15);
    }
    .sp-student-grid .divunline .stu-score {
        display: inline-block; 
        font-size: 11px; 
        color: #6b7280;
        background: #fef3c7; 
        border: 1px solid #fde68a;
        border-radius: 12px; 
        padding: 3px 10px; 
        margin-top: 6px;
        font-weight: 500;
    }
    .sp-student-grid .divunline .labelname {
        background: linear-gradient(135deg, #fffbeb, #fef3c7) !important;
        border: 1px solid #fde68a !important; 
        color: #92400e !important;
    }

    /* Override theme labelname */
    .sp-student-grid .labelname {
        display: inline-block !important; 
        background: linear-gradient(135deg, #eef2ff, #e8ecff) !important;
        border: none !important; 
        border-radius: 20px !important;
        color: #4338ca !important; 
        font-size: 13px !important; 
        font-weight: 700 !important;
        padding: 5px 16px !important; 
        height: auto !important; 
        width: auto !important;
        min-width: 56px; 
        line-height: 20px !important; 
        text-align: center;
        transition: all 0.2s;
    }
    .sp-student-grid .divonline:hover .labelname {
        background: linear-gradient(135deg, #e0e7ff, #c7d2fe) !important;
    }
    .sp-seat-view {
        width: 100%;
        padding: 8px 0 0;
    }
    .sp-seat-view-note {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin: 0 0 12px;
        padding: 8px 12px;
        border-radius: 999px;
        background: linear-gradient(135deg, #eff6ff, #dbeafe);
        color: #1d4ed8;
        font-size: 12px;
        font-weight: 600;
    }
    .sp-seat-view-note::before {
        content: '';
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #2563eb;
        box-shadow: 0 0 0 4px rgba(37,99,235,0.12);
    }
    .sp-seat-frame {
        width: 100%;
        min-height: 720px;
        border: 1px solid #dbeafe;
        border-radius: 18px;
        background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.7), 0 10px 24px rgba(37,99,235,0.08);
        overflow: hidden;
    }
    .sp-seat-frame iframe {
        display: block;
        width: 100%;
        min-height: 720px;
        height: 720px;
        border: 0;
        background: transparent;
    }
    .sp-card-head .sp-mode-badge {
        margin-left: auto;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 12px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 700;
        line-height: 1;
        border: 1px solid transparent;
        white-space: nowrap;
    }
    .sp-card-head .sp-mode-badge::before {
        content: '';
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: currentColor;
        box-shadow: 0 0 0 4px rgba(255,255,255,0.45);
    }
    .sp-mode-badge.mode-seat {
        color: #1d4ed8;
        background: linear-gradient(135deg, #eff6ff, #dbeafe);
        border-color: #bfdbfe;
    }
    .sp-mode-badge.mode-host {
        color: #7c2d12;
        background: linear-gradient(135deg, #fff7ed, #fed7aa);
        border-color: #fdba74;
    }
    .sp-mode-badge.mode-number {
        color: #4338ca;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        border-color: #c7d2fe;
    }
    .sp-mode-badge.mode-group {
        color: #047857;
        background: linear-gradient(135deg, #ecfdf5, #d1fae5);
        border-color: #a7f3d0;
    }
    .sp-card-seat-mode {
        border-color: #bfdbfe;
        box-shadow: 0 14px 34px rgba(37,99,235,0.12), 0 2px 10px rgba(37,99,235,0.06);
    }
    .sp-card-seat-mode .sp-card-head {
        background: linear-gradient(135deg, #eff6ff 0%, #f8fbff 100%);
        border-bottom: 1px solid #dbeafe;
    }
    /* Override theme lockbtn */
    .sp-student-grid .lockbtn {
        display: inline-flex !important; 
        align-items: center; justify-content: center;
        width: 24px !important; 
        height: 24px !important;
        background: #fef2f2 !important; 
        border: none !important;
        border-radius: 50% !important; 
        font-size: 10px !important; 
        text-align: center !important;
        line-height: 1 !important; 
        color: #ef4444 !important; 
        text-decoration: none !important;
        transition: all 0.2s;
    }
    .sp-student-grid .lockbtn:hover { 
        background: #fee2e2 !important; 
        box-shadow: 0 2px 8px rgba(239,68,68,0.2);
        transform: scale(1.15);
    }
    /* Override theme groupscore */
    .sp-student-grid .groupscore {
        display: inline-flex !important; 
        align-items: center; justify-content: center;
        font-size: 11px !important; 
        font-weight: 700 !important;
        width: auto !important; 
        min-width: 24px; height: 24px;
        color: #6366f1 !important;
        background: #eef2ff !important;
        border: none !important;
        border-radius: 20px !important;
        padding: 0 8px !important;
    }
    /* Credit badge for online students */
    .sp-student-grid .stu-credit-badge {
        display: inline-block;
        font-size: 10px;
        font-weight: 700;
        border-radius: 999px;
        padding: 4px 10px;
        line-height: 1.2;
        letter-spacing: 0.2px;
        border: 1px solid transparent;
        box-shadow: 0 2px 6px rgba(15,23,42,0.05);
    }
    .sp-student-grid .stu-credit-badge.badge-credit {
        color: #64748b;
        background: linear-gradient(135deg, #f8fafc, #eef2f7);
        border-color: #e2e8f0;
    }
    .sp-student-grid .stu-credit-badge.badge-credit-has {
        color: #4338ca;
        background: linear-gradient(135deg, #eef2ff, #e0e7ff);
        border-color: #c7d2fe;
    }
    .sp-student-grid .stu-credit-badge.badge-host {
        color: #9a3412;
        background: linear-gradient(135deg, #fff7ed, #ffedd5);
        border-color: #fdba74;
    }
    .sp-student-grid .stu-credit-badge.badge-host-empty {
        color: #b45309;
        background: linear-gradient(135deg, #fffbeb, #fef3c7);
        border-color: #fcd34d;
    }

    /* ===== Control Panel ===== */
    .sp-controls {
        display: flex; 
        align-items: center; 
        flex-wrap: nowrap; 
        gap: 16px;
        padding: 16px 24px; 
        border-top: 1px solid #f1f5f9;
        font-size: 13px; 
        color: #475569;
        background: linear-gradient(135deg, #fafbfc 0%, #f5f3ff 50%, #eef2ff 100%);
        overflow-x: auto;
    }
    .sp-controls-seat-mode {
        background: linear-gradient(135deg, #eff6ff 0%, #f8fbff 60%, #eef2ff 100%);
        border-top-color: #dbeafe;
    }
    @media (max-width: 1200px) {
        .sp-controls {
            gap: 12px;
        }
    }
    
    /* 排序区域 */
    .sp-controls-sort {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 0 0 auto;
    }
    
    .sp-controls .sp-ctrl-group-title {
        font-size: 13px; 
        font-weight: 700; 
        color: #6366f1; 
        display: inline-flex; 
        align-items: center; 
        gap: 8px; 
        white-space: nowrap;
        margin-right: 0;
    }
    .sp-controls .sp-ctrl-group-title svg {
        width: 18px; 
        height: 18px; 
        stroke: #6366f1; 
        fill: none; 
        stroke-width: 2.5;
        stroke-linecap: round; 
        stroke-linejoin: round;
    }
    
    .sp-controls .sp-ctrl-group {
        display: inline-flex; 
        align-items: center; 
        gap: 0;
        background: #ffffff; 
        border: 2px solid #e0e7ff; 
        border-radius: 12px;
        padding: 4px; 
        box-shadow: 0 2px 8px rgba(99,102,241,0.1);
    }
    .sp-controls .sp-ctrl-group > span {
        position: relative;
        display: inline-flex;
        align-items: stretch;
    }
    
    /* Radio group as segmented control */
    .sp-controls .sp-ctrl-group label {
        display: inline-flex; 
        align-items: center; 
        justify-content: center;
        gap: 0; 
        cursor: pointer; 
        white-space: nowrap;
        background: transparent; 
        border: none; 
        border-radius: 8px;
        padding: 8px 14px; 
        font-size: 12.5px; 
        color: #64748b; 
        font-weight: 500;
        transition: all 0.25s ease; 
        user-select: none;
        margin: 0;
        position: relative;
    }
    .sp-controls .sp-ctrl-group label:not(:last-child)::after {
        content: '';
        position: absolute;
        right: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 1px;
        height: 60%;
        background: #e0e7ff;
    }
    .sp-controls .sp-ctrl-group label:hover { 
        background: #f5f3ff; 
        color: #4338ca; 
    }
    .sp-controls .sp-ctrl-group input[type="radio"] {
        position: absolute;
        opacity: 0;
        width: 1px;
        height: 1px;
        margin: 0;
        pointer-events: none;
    }
    .sp-controls .sp-ctrl-group input[type="radio"]:checked + label,
    .sp-controls .sp-ctrl-group label.is-active {
        background: linear-gradient(135deg, #6366f1, #7c3aed) !important;
        color: #fff !important; 
        font-weight: 600;
        box-shadow: 0 2px 8px rgba(99,102,241,0.25);
    }
    .sp-controls .sp-ctrl-group input[type="radio"]:checked + label::after,
    .sp-controls .sp-ctrl-group label.is-active::after {
        display: none;
    }
    
    /* 分隔线 */
    .sp-ctrl-sep {
        width: 1.5px; 
        height: 40px; 
        border-radius: 1px;
        background: linear-gradient(180deg, transparent, #c7d2fe, transparent);
        flex-shrink: 0;
        margin: 0;
    }
    
    /* 功能区域 */
    .sp-controls-func {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 1 1 auto;
        min-width: 0;
    }
    
    /* Checkbox as toggle switches */
    .sp-controls .sp-switch-group {
        display: flex; 
        align-items: center; 
        flex-wrap: nowrap; 
        gap: 14px;
        flex: 1 1 auto;
    }
    
    @media (max-width: 768px) {
        .sp-controls .sp-switch-group {
            gap: 12px;
        }
        .sp-controls .sp-switch-group span {
            flex: 0 0 calc(50% - 6px);
        }
    }
    .sp-controls .sp-switch-group span {
        display: inline-flex !important; 
        align-items: center !important;
        gap: 8px;
    }
    .sp-controls .sp-switch-group label {
        display: inline !important; 
        cursor: pointer;
        white-space: nowrap; 
        font-size: 13px !important; 
        color: #475569 !important;
        font-weight: 500; 
        transition: color 0.2s ease; 
        user-select: none;
        background: transparent !important; 
        border: none !important;
        padding: 0 !important; 
        line-height: 20px;
        margin: 0 !important;
    }
    .sp-controls .sp-switch-group label:hover {
        color: #1e293b !important;
    }
    .sp-controls .sp-switch-group input[type="checkbox"]:checked + label {
        color: #1e293b !important; font-weight: 600;
    }
    
    /* Custom toggle switch */
    .sp-controls .sp-switch-group input[type="checkbox"] {
        appearance: none; 
        -webkit-appearance: none;
        width: 40px; 
        min-width: 40px; 
        height: 22px;
        margin: 0 !important; 
        cursor: pointer;
        background: #e2e8f0; 
        border-radius: 11px;
        position: relative; 
        transition: background 0.3s ease;
        flex-shrink: 0; 
        vertical-align: middle;
        border: 1px solid #cbd5e1;
    }
    .sp-controls .sp-switch-group input[type="checkbox"]::before {
        content: ''; 
        position: absolute; 
        top: 2px; 
        left: 2px;
        width: 18px; 
        height: 18px; 
        border-radius: 50%;
        background: #fff; 
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .sp-controls .sp-switch-group input[type="checkbox"]:checked {
        background: linear-gradient(135deg, #6366f1, #7c3aed);
        border-color: #6366f1;
    }
    .sp-controls .sp-switch-group input[type="checkbox"]:checked::before {
        transform: translateX(18px);
    }
    .sp-controls .sp-switch-group input[type="checkbox"]:hover {
        background: #cbd5e1;
        border-color: #94a3b8;
    }
    .sp-controls .sp-switch-group input[type="checkbox"]:checked:hover {
        background: linear-gradient(135deg, #4f46e5, #6d28d9);
        border-color: #4f46e5;
    }

    /* ===== Tools Bar ===== */
    .sp-tools {
        display: flex; align-items: center; flex-wrap: wrap; gap: 8px;
        padding: 14px 20px; font-size: 12px; color: #475569;
        border-bottom: 1px solid #f1f5f9;
        background: #fff;
    }
    .sp-tools select {
        height: 34px; border-radius: 8px; border: 1.5px solid #e2e8f0;
        font-size: 12px; padding: 0 12px; background: #f8fafc; transition: all 0.2s;
        color: #374151; font-weight: 500;
    }
    .sp-tools select:hover { border-color: #6366f1; }
    .sp-tools select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.1); outline: none; }
    .sp-tools a, .sp-tools a:link, .sp-tools a:visited {
        color: #6366f1 !important; text-decoration: none !important; font-weight: 600;
        padding: 6px 14px; border-radius: 8px; transition: all 0.2s;
        font-size: 12px;
    }
    .sp-tools a:hover { background: #eef2ff !important; }
    .sp-tools label {
        display: inline-flex; align-items: center; white-space: nowrap;
        padding: 0; background: transparent;
        border: none; border-radius: 0;
        cursor: pointer; font-size: 13px; color: #475569; font-weight: 500;
        transition: color 0.2s ease;
    }
    .sp-tools label:hover { background: transparent; color: #1e293b; }
    .sp-tools input[type="checkbox"] {
        appearance: none; -webkit-appearance: none;
        width: 36px; min-width: 36px; height: 20px;
        margin: 0 6px 0 0 !important; cursor: pointer;
        background: #e2e8f0; border-radius: 10px;
        position: relative; transition: background 0.25s ease;
        flex-shrink: 0; vertical-align: middle;
    }
    .sp-tools input[type="checkbox"]::before {
        content: ''; position: absolute; top: 2px; left: 2px;
        width: 16px; height: 16px; border-radius: 50%;
        background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.15);
        transition: transform 0.25s ease;
    }
    .sp-tools input[type="checkbox"]:checked {
        background: #6366f1;
    }
    .sp-tools input[type="checkbox"]:checked::before {
        transform: translateX(16px);
    }
    .sp-tools input[type="checkbox"]:hover {
        background: #cbd5e1;
    }
    .sp-tools input[type="checkbox"]:checked:hover {
        background: #4f46e5;
    }
    .sp-tools input[type="checkbox"]:checked + label,
    .sp-tools label:has(input:checked) {
        color: #1e293b; font-weight: 600;
    }
    /* Icon button wrappers */
    .sp-tools .sp-icon-btn {
        display: inline-flex; align-items: center; justify-content: center;
        width: 34px; height: 34px; border-radius: 8px;
        border: 1.5px solid #e2e8f0; background: #f8fafc;
        transition: all 0.2s; cursor: pointer; position: relative;
    }
    .sp-tools .sp-icon-btn:hover {
        border-color: #818cf8; background: #eef2ff;
        box-shadow: 0 2px 8px rgba(99,102,241,0.12);
        transform: translateY(-1px);
    }
    .sp-tools .sp-icon-btn input[type="image"],
    .sp-tools .sp-icon-btn img {
        width: 18px; height: 18px; border-radius: 2px;
    }
    .sp-tools input[type="image"] {
        border-radius: 4px; transition: all 0.2s;
    }
    /* Disk SVG icon buttons */
    .sp-tools .sp-disk-btn {
        display: inline-flex !important; align-items: center; gap: 6px;
        height: 34px; border-radius: 8px !important;
        border: 1.5px solid #e2e8f0 !important; background: #f8fafc !important;
        padding: 0 12px !important; transition: all 0.2s; cursor: pointer;
        font-size: 11px !important; font-weight: 600; color: #475569 !important;
        text-decoration: none !important;
    }
    .sp-tools .sp-disk-btn:hover {
        border-color: #818cf8 !important; background: #eef2ff !important;
        color: #4338ca !important;
        box-shadow: 0 2px 8px rgba(99,102,241,0.12);
        transform: translateY(-1px);
    }
    .sp-tools .sp-disk-btn svg {
        width: 16px; height: 16px; stroke-width: 2;
        stroke-linecap: round; stroke-linejoin: round; fill: none;
    }
    .sp-tools .sp-disk-btn.stu-disk svg { stroke: #6366f1; }
    .sp-tools .sp-disk-btn.group-disk svg { stroke: #8b5cf6; }

    /* ===== Course Progress ===== */
    .sp-course { text-align: left; padding: 20px !important; }
    .sp-course-label {
        font-size: 13px; font-weight: 700; color: #374151; margin: 18px 0 12px;
        display: inline-flex; align-items: center; gap: 8px;
        padding: 7px 16px 7px 12px; border-radius: 20px;
    }
    .sp-course-label::before {
        content: ''; display: inline-block; width: 8px; height: 8px;
        border-radius: 50%; flex-shrink: 0;
    }
    .sp-course-label:first-child { margin-top: 0; }
    .sp-course-label.done {
        background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0;
    }
    .sp-course-label.done::before {
        background: #10b981;
        box-shadow: 0 0 0 3px rgba(16,185,129,0.2);
    }
    .sp-course-label.undone {
        background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa;
    }
    .sp-course-label.undone::before {
        background: #f97316;
        box-shadow: 0 0 0 3px rgba(249,115,22,0.2);
    }
    .sp-course .doneksdiv {
        display: inline-flex !important; align-items: center; gap: 6px;
        margin: 4px !important; vertical-align: middle;
        width: auto !important; float: none !important;
        background: #fff; border: 1.5px solid #e5e7eb; border-radius: 10px;
        padding: 6px 10px; transition: all 0.25s;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    }
    .sp-course .doneksdiv:hover {
        border-color: #818cf8; box-shadow: 0 4px 14px rgba(99,102,241,0.12);
        transform: translateY(-2px);
    }
    /* Override theme donekc/newkc */
    .sp-course .donekc {
        display: inline-flex !important; align-items: center; justify-content: center;
        background: linear-gradient(135deg, #ecfdf5, #d1fae5) !important;
        color: #047857 !important; font-weight: 700 !important; font-size: 12px !important;
        border-radius: 8px !important; padding: 4px 14px !important;
        height: 28px !important; width: auto !important; min-width: 28px;
        text-align: center; text-decoration: none !important;
        border: 1px solid #6ee7b7; transition: all 0.2s;
    }
    .sp-course .donekc:hover { background: #d1fae5 !important; border-color: #34d399; box-shadow: 0 2px 6px rgba(16,185,129,0.2); }
    .sp-course .newkc {
        display: inline-flex !important; align-items: center; justify-content: center;
        background: linear-gradient(135deg, #fff7ed, #ffedd5) !important;
        color: #c2410c !important; font-weight: 700 !important; font-size: 12px !important;
        border-radius: 8px !important; padding: 4px 14px !important;
        height: 28px !important; width: auto !important; min-width: 28px;
        text-align: center; text-decoration: none !important;
        border: 1px solid #fdba74; transition: all 0.2s;
    }
    .sp-course .newkc:hover { background: #ffedd5 !important; border-color: #fb923c; box-shadow: 0 2px 6px rgba(249,115,22,0.2); }
    .sp-course .doneksdiv input[type="checkbox"] {
        accent-color: #6366f1; width: 16px; height: 16px;
    }
    .sp-course .doneksdiv input[type="image"] {
        width: 20px; height: 20px;
        padding: 2px; border-radius: 4px; transition: all 0.2s; vertical-align: middle;
        border: 1px solid #e5e7eb; background: #f9fafb;
    }
    .sp-course .doneksdiv input[type="image"]:hover {
        border-color: #818cf8; background: #eef2ff;
    }

    /* ===== Toast Notification ===== */
    .sp-toast-overlay {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        z-index: 99998;
        background: rgba(0,0,0,0.18);
        backdrop-filter: blur(2px);
        -webkit-backdrop-filter: blur(2px);
        animation: spOverlayIn 0.3s ease forwards;
    }
    .sp-toast-overlay.hide {
        animation: spOverlayOut 0.35s ease forwards;
    }
    .sp-toast-wrap {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        z-index: 99999;
        display: flex;
        align-items: center;
        justify-content: center;
        pointer-events: none;
    }
    .sp-toast {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 14px;
        padding: 36px 48px 28px;
        border-radius: 22px;
        color: #fff;
        box-shadow: 0 20px 60px rgba(0,0,0,0.25), 0 4px 16px rgba(0,0,0,0.1);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        animation: spToastIn 0.5s cubic-bezier(0.21,1.02,0.73,1) forwards;
        pointer-events: auto;
        overflow: hidden;
        min-width: 200px;
    }
    .sp-toast.on {
        background: linear-gradient(145deg, rgba(16,185,129,0.92), rgba(5,150,105,0.95));
        border: 1px solid rgba(255,255,255,0.2);
    }
    .sp-toast.off {
        background: linear-gradient(145deg, rgba(244,63,94,0.92), rgba(225,29,72,0.95));
        border: 1px solid rgba(255,255,255,0.2);
    }
    .sp-toast .sp-toast-icon {
        width: 56px;
        height: 56px;
        border-radius: 50%;
        background: rgba(255,255,255,0.2);
        border: 2px solid rgba(255,255,255,0.3);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        animation: spIconPop 0.5s 0.15s cubic-bezier(0.34,1.56,0.64,1) both;
    }
    .sp-toast .sp-toast-icon svg {
        width: 28px;
        height: 28px;
        stroke: #fff;
        stroke-width: 2.5;
        stroke-linecap: round;
        stroke-linejoin: round;
        fill: none;
    }
    .sp-toast.on .sp-toast-icon svg polyline {
        stroke-dasharray: 30;
        stroke-dashoffset: 30;
        animation: spCheck 0.4s 0.35s ease forwards;
    }
    .sp-toast.off .sp-toast-icon svg line {
        stroke-dasharray: 20;
        stroke-dashoffset: 20;
        animation: spCross 0.3s 0.35s ease forwards;
    }
    .sp-toast .sp-toast-msg {
        font-size: 17px;
        font-weight: 700;
        letter-spacing: 0.5px;
        text-shadow: 0 1px 3px rgba(0,0,0,0.15);
    }
    .sp-toast .sp-toast-sub {
        font-size: 12px;
        font-weight: 500;
        opacity: 0.75;
        margin-top: -8px;
    }
    .sp-toast .sp-toast-bar {
        position: absolute;
        bottom: 0; left: 0;
        height: 3px;
        background: rgba(255,255,255,0.5);
        border-radius: 0 0 22px 22px;
        animation: spBar 2s linear forwards;
    }
    .sp-toast.hide {
        animation: spToastOut 0.35s cubic-bezier(0.4,0,1,1) forwards;
    }
    @keyframes spOverlayIn {
        from { opacity: 0; }
        to   { opacity: 1; }
    }
    @keyframes spOverlayOut {
        from { opacity: 1; }
        to   { opacity: 0; }
    }
    @keyframes spToastIn {
        from { opacity: 0; transform: scale(0.75) translateY(20px); }
        to   { opacity: 1; transform: scale(1) translateY(0); }
    }
    @keyframes spToastOut {
        from { opacity: 1; transform: scale(1) translateY(0); }
        to   { opacity: 0; transform: scale(0.85) translateY(10px); }
    }
    @keyframes spIconPop {
        from { transform: scale(0); }
        to   { transform: scale(1); }
    }
    @keyframes spCheck {
        to { stroke-dashoffset: 0; }
    }
    @keyframes spCross {
        to { stroke-dashoffset: 0; }
    }
    @keyframes spBar {
        from { width: 100%; }
        to   { width: 0%; }
    }

    /* ===== Footer ===== */
    .sp-footer {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 12px 20px; font-size: 12px; color: #94a3b8;
    }
    .sp-footer input[type="submit"] {
        height: 34px; border-radius: 8px; border: 1.5px solid #fecaca;
        background: #fff; color: #ef4444; font-size: 12px; font-weight: 600;
        padding: 0 18px; cursor: pointer; transition: all 0.2s;
    }
    .sp-footer input[type="submit"]:hover { background: #fef2f2; border-color: #f87171; box-shadow: 0 2px 8px rgba(239,68,68,0.1); }
</style>

<div class="sp">
    <!-- ===== Toolbar ===== -->
    <div class="sp-toolbar">
        <span class="sp-tb-label">
            <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg> 上课选择
        </span>
        <asp:DropDownList ID="DDLSchool" runat="server" Font-Size="9pt" Width="130px"
            EnableTheming="True" AutoPostBack="True"
            onselectedindexchanged="DDLSchool_SelectedIndexChanged" />
        <span style="color:rgba(255,255,255,0.7);font-size:11px;">校区</span>
        <asp:DropDownList ID="DDLgrade" runat="server" Font-Size="9pt" Width="45px"
            EnableTheming="True" AutoPostBack="True"
            onselectedindexchanged="DDLgrade_SelectedIndexChanged" />
        <span style="color:rgba(255,255,255,0.7);font-size:11px;">年级</span>
        <asp:DropDownList ID="DDLclass" runat="server" Font-Size="9pt" Width="45px"
            AutoPostBack="True" onselectedindexchanged="DDLclass_SelectedIndexChanged" />
        <span style="color:rgba(255,255,255,0.7);font-size:11px;">班</span>
        <asp:DropDownList ID="DDLCid" runat="server" Font-Size="9pt" Width="160px"
            AutoPostBack="True" onselectedindexchanged="DDLCid_SelectedIndexChanged" />
        <asp:Button ID="Btnset" runat="server" Text="开始上课" SkinID="BtnNormal"
            onclick="Btnset_Click" ToolTip="设置上课班级登录密码" 
            UseSubmitBehavior="True" CausesValidation="False" />
        <asp:Button ID="Btnstudent" runat="server" Text="模拟学生" SkinID="BtnNormal"
            ToolTip="模拟本班级学生角色登录学生平台" onclick="Btnstudent_Click" Enabled="False" />
        <asp:TextBox ID="TBpwd" runat="server" ReadOnly="True" Width="55px" SkinID="TextBoxNum" Height="20px" />
        <div class="sp-tb-sep"></div>
        <asp:HyperLink ID="HLrate" runat="server" BorderStyle="None" Font-Underline="False" Target="_blank">学习进度</asp:HyperLink>
        <asp:HyperLink ID="HLworkshow" runat="server" BorderStyle="None" Font-Underline="False" Target="_blank">作品展示</asp:HyperLink>
        <asp:HyperLink ID="HLtotal" runat="server" BorderStyle="None" Font-Underline="False" Target="_blank">学习汇总</asp:HyperLink>
        <span class="sp-game-switch">
            <asp:CheckBox ID="CheckBoxGame" runat="server" Text="游戏开关" AutoPostBack="True" 
                OnCheckedChanged="CheckBoxGame_CheckedChanged" ToolTip="控制学生是否可以访问游戏" />
        </span>
        <span class="sp-game-switch">
            <asp:CheckBox ID="CheckBoxDiscuss" runat="server" Text="小组讨论" AutoPostBack="True" 
                OnCheckedChanged="CheckBoxDiscuss_CheckedChanged" ToolTip="控制学生是否可以访问小组讨论" />
        </span>
        <span class="sp-game-switch">
            <asp:CheckBox ID="CheckBoxAI" runat="server" Text="AI对话" AutoPostBack="True" 
                OnCheckedChanged="CheckBoxAI_CheckedChanged" ToolTip="控制学生是否可以访问AI对话" />
        </span>
    </div>

    <!-- ===== Menu ===== -->
    <div class="sp-card">
        <div class="sp-card-head">
            <div class="sp-icon" style="background:linear-gradient(135deg,#eef2ff,#e0e7ff);"><svg viewBox="0 0 24 24" style="stroke:#6366f1;"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg></div>
            <span>学案活动</span>
        </div>
        <div class="sp-card-body sp-menu-wrap">
            <asp:DataList ID="DataListMenu" runat="server" RepeatLayout="Flow"
                RepeatDirection="Horizontal" onitemdatabound="DataListMenu_ItemDataBound"
                DataKeyField="Lid" onitemcommand="DataListMenu_ItemCommand">
                <ItemTemplate>
                    <div class="sp-menu-item">
                        <div class="sp-menu-body">
                            <asp:Literal ID="litMenuIcon" runat="server" Text='<%# GetMenuSvg(Eval("Ltitle"), Eval("Limgurl")) %>' />
                            <asp:Label ID="lableTitle" runat="server" Text='<%# Eval("Ltitle") %>' CssClass="sp-menu-title" />
                        </div>
                        <asp:ImageButton ID="imgBtn" runat="server" CssClass="sp-menu-trigger" ImageUrl='<%# Eval("Limgurl") %>' CommandArgument="Lid" CommandName="P" AlternateText='<%# Eval("Ltitle") %>' ToolTip='<%# Eval("Ltitle") %>' />
                        <asp:CheckBox ID="CheckBoxShow" Checked='<%# Eval("Lshow") %>' runat="server" Visible="false" />
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- ===== Online Students ===== -->
    <div class="<%= GetOnlineCardCssClass() %>">
        <div class="sp-card-head">
            <div class="sp-icon" style="background:linear-gradient(135deg,#ecfdf5,#d1fae5);"><svg viewBox="0 0 24 24" style="stroke:#10b981;"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
            <span>在线学生</span>
            <span class="sp-mode-badge <%= GetSortModeClass() %>"><%= GetSortModeText() %></span>
        </div>
        <div class="sp-legend">
            <span class="sp-legend-item"><asp:Label ID="Labelnocolor" runat="server" BackColor="#E8E8E8" Width="14px" Height="14px" EnableViewState="False" ToolTip="没有作品" CssClass="sp-legend-dot" />0件</span>
            <span class="sp-legend-item"><asp:Label ID="Labelone" runat="server" BackColor="#B1D2FE" Width="14px" Height="14px" EnableViewState="False" ToolTip="单个作品" CssClass="sp-legend-dot" />1件</span>
            <span class="sp-legend-item"><asp:Label ID="Labeltwo" runat="server" BackColor="#4F98FB" Width="14px" Height="14px" EnableViewState="False" ToolTip="两个作品" CssClass="sp-legend-dot" />2件</span>
            <span class="sp-legend-item"><asp:Label ID="Labelthree" runat="server" BackColor="#CDE7CF" Width="14px" Height="14px" EnableViewState="False" ToolTip="三个作品" CssClass="sp-legend-dot" />3件</span>
            <span class="sp-legend-item"><asp:Label ID="Labelfour" runat="server" BackColor="#9BC47D" Width="14px" Height="14px" EnableViewState="False" ToolTip="四个作品" CssClass="sp-legend-dot" />4件</span>
            <span class="sp-legend-item"><asp:Label ID="Labelmore" runat="server" BackColor="#BCADE4" Width="14px" Height="14px" EnableViewState="False" ToolTip="多个作品" CssClass="sp-legend-dot" />多件</span>
            <asp:Label ID="Labelcount" runat="server" Font-Names="Arial" Font-Size="9pt" EnableViewState="False" />
            <span class="sp-stat">已签到：<asp:Label ID="Labelsigin" runat="server" /> 位</span>
        </div>
        <div class="sp-card-body sp-student-grid">
            <asp:PlaceHolder ID="PlaceHolderSeatView" runat="server" Visible="false">
                <div class="sp-seat-view">
                    <div class="sp-seat-view-note">机房视图已启用，当前按照机房座位布局显示</div>
                    <div class="sp-seat-frame">
                        <iframe src="<%= GetSeatFrameUrl(true) %>" title="机房视图"></iframe>
                    </div>
                </div>
            </asp:PlaceHolder>
            <asp:DataList ID="DLonline" runat="server" RepeatColumns="9" onitemdatabound="DLonline_ItemDataBound"
                DataKeyField="Qid" onitemcommand="DLonline_ItemCommand" RepeatDirection="Vertical" HorizontalAlign="Center">
                <ItemTemplate>
                    <div class="divonline">
                        <div><asp:Label ID="Labelqnum" runat="server" Text='<%# Eval("Qnum") %>' Font-Size="8pt" /></div>
                        <div><asp:Label ID="HyperSname" runat="server" Text='<%# Eval("Qname") %>' CssClass="labelname" /></div>
                        <div><asp:Label ID="LabelQmachine" runat="server" Text='<%# Eval("QmachineShort") %>' Font-Size="8pt" Visible="false" /><asp:Label ID="LabelCredit" runat="server" Text="" CssClass="stu-credit-badge" /></div>
                        <div>
                            <asp:HyperLink ID="Groupflag" runat="server">g</asp:HyperLink>
                            <asp:Label ID="Labelcolor" runat="server" Text='<%# Eval("Qgscore") %>' ToolTip='<%# "组评语："+Eval("Qgroup") %>' CssClass="groupscore" />
                            <asp:LinkButton ID="Lunlock" runat="server" CommandArgument="Qid" CommandName="UnLock" ToolTip="单击执行：让该学生重新登录！" CssClass="lockbtn" />
                        </div>
                        <div>
                            <asp:Label ID="Labelwork" runat="server" Text='<%# Eval("Qwork") %>' Visible="false" />
                            <asp:Label ID="Labelattitude" runat="server" Text='<%# Eval("Qattitude") %>' Visible="false" />
                            <asp:Label ID="Labelnote" runat="server" Text='<%# Eval("Qnote") %>' Visible="false" />
                            <asp:Label ID="LabelSleader" runat="server" Text='<%# Eval("Sleader") %>' Visible="false" />
                            <asp:Label ID="LabelSgroup" runat="server" Text='<%# Eval("Sgroup") %>' Visible="false" />
                            <asp:Label ID="LabelSgtitle" runat="server" Text='<%# Eval("Sgtitle") %>' Visible="false" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
        <div class="<%= GetControlsCssClass() %>">
            <!-- 排序区域 -->
            <div class="sp-controls-sort">
                <span class="sp-ctrl-group-title">
                    <svg viewBox="0 0 24 24">
                        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
                    </svg>
                    排序
                </span>
                <span class="sp-ctrl-group">
                    <anthem:RadioButtonList ID="RBsort" runat="server" AutoPostBack="True"
                        Font-Size="9pt" onselectedindexchanged="RBsort_SelectedIndexChanged"
                        RepeatDirection="Horizontal" RepeatLayout="Flow">
                        <Items>
                            <asp:ListItem Value="3">机房视图</asp:ListItem>
                            <asp:ListItem Value="0">主机排序</asp:ListItem>
                            <asp:ListItem Value="1" Selected="True">学号排序</asp:ListItem>
                            <asp:ListItem Value="2">小组排序</asp:ListItem>
                        </Items>
                    </anthem:RadioButtonList>
                </span>
            </div>
            <!-- 分隔线 -->
            <span class="sp-ctrl-sep"></span>
            
            <!-- 功能区域 -->
            <div class="sp-controls-func">
                <span class="sp-ctrl-group-title">
                    <svg viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="3"/>
                        <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                    </svg>
                    功能
                </span>
                <span class="sp-switch-group">
                    <span>
                        <anthem:CheckBox ID="CheckBoxScratch" runat="server" Text="编程控制" AutoPostBack="True" ToolTip="提示：编程开关控制，选中表示可以进入编程页面" oncheckedchanged="CheckBoxScratch_CheckedChanged" />
                    </span>
                    <span>
                        <anthem:CheckBox ID="CheckBoxRgauge" runat="server" Text="作品互评" AutoPostBack="True" oncheckedchanged="CheckBoxRgauge_CheckedChanged" ToolTip="提示：作品互评控制，选中表示开启" />
                    </span>
                    <span>
                        <anthem:CheckBox ID="CheckBoxip" runat="server" Text="IP锁定" AutoPostBack="True" oncheckedchanged="CheckBoxip_CheckedChanged" ToolTip="提示：根据上次登录的IP进行锁定登录" />
                    </span>
                    <span>
                        <anthem:CheckBox ID="CheckBoxPass" runat="server" Text="闯关模式" AutoPostBack="True" oncheckedchanged="CheckBoxPass_CheckedChanged" ToolTip="提示：当前学案活动依次完成后解锁下一个活动！" />
                    </span>
                    <span>
                        <anthem:CheckBox ID="CheckBoxOpen" runat="server" Text="快速模式" AutoPostBack="True" oncheckedchanged="CheckBoxOpen_CheckedChanged" ToolTip="提示：本班学生登录后，直接进入当前学案学案导航！" />
                    </span>
                    <span>
                        <anthem:CheckBox ID="CheckBoxPwd" runat="server" Text="班级密码" AutoPostBack="True" oncheckedchanged="CheckBoxPwd_CheckedChanged" ToolTip="提示：选中表示公开显示班级密码，未选表示隐藏班级密码！" />
                    </span>
                    <span>
                        <anthem:CheckBox ID="CheckBoxLogin" runat="server" Text="个人模式" AutoPostBack="True" ToolTip="提示：选中表示允许本班单独个人模式登录，未选表示使用后台统一模式登录！" oncheckedchanged="CheckBoxLogin_CheckedChanged" />
                    </span>
                </span>
            </div>
        </div>
    </div>

    <!-- ===== Offline Students ===== -->
    <div class="sp-card">
        <div class="sp-card-head">
            <div class="sp-icon" style="background:linear-gradient(135deg,#fefce8,#fef9c3);"><svg viewBox="0 0 24 24" style="stroke:#eab308;"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="23" y1="11" x2="17" y2="11"/></svg></div>
            <span>未签到学生</span>
            <asp:Label ID="Label2" runat="server" Width="16px" Height="16px" ForeColor="White" />
            <span class="sp-badge" style="background:#fef9c3;color:#a16207;border:1px solid #fde68a;">共 <asp:Label ID="Labelsigno" runat="server" /> 位</span>
        </div>
        <div class="sp-card-body sp-student-grid">
            <asp:DataList ID="DLnotline" runat="server" RepeatColumns="9"
                RepeatDirection="Horizontal" onitemdatabound="DLnotline_ItemDataBound" HorizontalAlign="Center">
                <ItemTemplate>
                    <div class="divunline">
                        <div class="stu-num"><asp:Label ID="LabelNnum" runat="server" Text='<%# Eval("Snum") %>' /></div>
                        <div class="stu-avatar"><%# Eval("Sname").ToString().Substring(0,1) %></div>
                        <div><asp:Label ID="lbQname" runat="server" Text='<%# Eval("Sname") %>' CssClass="labelname" /></div>
                        <div class="stu-score">学分 <asp:Label ID="LabelSscore" runat="server" Text='<%# Eval("Sscore") %>' ToolTip="总学分" /></div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- ===== Tools & Course Progress ===== -->
    <div class="sp-card">
        <div class="sp-card-head">
            <div class="sp-icon" style="background:linear-gradient(135deg,#f0fdf4,#dcfce7);"><svg viewBox="0 0 24 24" style="stroke:#16a34a;"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></div>
            <span>工具 & 课程进度</span>
        </div>
        <div class="sp-tools">
            <asp:Label ID="Labelfresh" runat="server" Font-Names="Arial" Font-Size="9pt" />
            <asp:DropDownList ID="DDLhouse" runat="server" Font-Size="9pt" Width="100px"
                AutoPostBack="True" onselectedindexchanged="DDLhouse_SelectedIndexChanged" />
            <asp:HyperLink ID="HyperLinkSeat" runat="server" Target="_blank">座位表</asp:HyperLink>
            <span class="sp-icon-btn"><asp:ImageButton ID="Btnrefresh" runat="server" onclick="Btnrefresh_Click" Enabled="False" ImageUrl="~/images/refresh.gif" /></span>
            <span class="sp-ctrl-sep"></span>
            <asp:CheckBox ID="CheckBoxShare" runat="server" Text="网盘开关" AutoPostBack="True" oncheckedchanged="CheckBoxShare_CheckedChanged" ToolTip="提示：选中表示网盘启用，未选表示网盘禁用！" />
            <asp:CheckBox ID="CheckBoxGroupShare" runat="server" Text="小组网盘" AutoPostBack="True" oncheckedchanged="CheckBoxGroupShare_CheckedChanged" ToolTip="提示：选中表示小组网盘启用" />
            <asp:HyperLink ID="HylkDiskstu" runat="server" Target="_blank" ToolTip="查看学生网盘存档情况" CssClass="sp-disk-btn stu-disk"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/><line x1="12" y1="11" x2="12" y2="17"/><polyline points="9 14 12 11 15 14"/></svg>学生网盘</asp:HyperLink>
            <asp:HyperLink ID="HylkDiskGroup" runat="server" Target="_blank" ToolTip="查看小组网盘存档情况" CssClass="sp-disk-btn group-disk"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>小组网盘</asp:HyperLink>
        </div>
        <div class="sp-card-body sp-course">
            <div class="sp-course-label done">已学学案</div>
            <asp:DataList ID="DLdonekc" runat="server" ForeColor="Black"
                RepeatDirection="Horizontal" RepeatLayout="Flow" CellPadding="0" CellSpacing="0"
                DataKeyField="Cid" onitemdatabound="DLdonekc_ItemDataBound">
                <ItemTemplate>
                    <div class="doneksdiv">
                        <div><asp:HyperLink ID="ks" runat="server" Text='<%# Eval("Cks") %>' ToolTip='<%# Eval("Ctitle") %>' CssClass="donekc" /></div>
                        <div><asp:Label ID="wk" runat="server" ToolTip="作品总数" /></div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
            <div class="sp-course-label undone">未学学案</div>
            <asp:DataList ID="DLnewkc" runat="server" ForeColor="Black"
                RepeatDirection="Horizontal" RepeatLayout="Flow" CellPadding="0" CellSpacing="0"
                onitemdatabound="DLnewkc_ItemDataBound" onitemcommand="DLnewkc_ItemCommand" DataKeyField="Cid">
                <ItemTemplate>
                    <div class="doneksdiv">
                        <div><asp:HyperLink ID="ks" runat="server" Text='<%# Eval("Cks") %>' ToolTip='<%# Eval("Ctitle") %>' CssClass="newkc" /></div>
                        <div><asp:CheckBox ID="Ck" runat="server" Checked='<%# Eval("Cpublish") %>' Enabled="False" /></div>
                        <div><asp:ImageButton runat="server" ID="PubSet" CommandArgument="Cid" CommandName="P" ImageUrl="~/images/cardsmall.gif" /></div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
    </div>

    <!-- ===== Footer ===== -->
    <div class="sp-card">
        <div class="sp-footer">
            <asp:Button ID="BtnaAllQuit" runat="server" Text="全班下线" SkinID="BtnSmall"
                onclick="BtnaAllQuit_Click" Visible="False" EnableViewState="False" />
            <asp:Label ID="LabelToday" runat="server" Font-Size="9pt"
                ToolTip="*服务器日期校准：作品、签到日期以此为准*" Font-Bold="False" />
        </div>
    </div>
</div>

    <script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
    <link href="../js/tooltip.css" rel="stylesheet" type="text/css" />
    <script src="../js/spanToolTip.js" type="text/javascript"></script>
    <link href="../js/tinybox.css" rel="stylesheet" type="text/css" />
    <script src="../js/tinybox.js" type="text/javascript"></script>
    <script type="text/javascript">
        // 确保"开始上课"按钮可以正常点击
        $(document).ready(function() {
            var btnSet = document.getElementById("<%= Btnset.ClientID %>");
            if (btnSet) {
                // 确保按钮没有被禁用
                if (btnSet.disabled) {
                    btnSet.disabled = false;
                }
                // 确保按钮可见
                btnSet.style.display = '';
                btnSet.style.visibility = 'visible';
                // 添加点击事件监听（作为备用）
                $(btnSet).off('click.btnset').on('click.btnset', function(e) {
                    // 如果按钮被禁用，阻止默认行为
                    if (this.disabled) {
                        e.preventDefault();
                        e.stopPropagation();
                        return false;
                    }
                    // 确保表单可以提交
                    var form = $(this).closest('form');
                    if (form.length > 0) {
                        // 移除可能阻止提交的事件监听器
                        form.off('submit.prevent');
                    }
                });
            }

            syncSortSelectionUI();

            $(document).off('change.rbsort').on('change.rbsort', '#' + "<%= RBsort.ClientID %>" + ' input[type="radio"]', function() {
                syncSortSelectionUI();
            });

            $(document).off('click.rbsort').on('click.rbsort', '#' + "<%= RBsort.ClientID %>" + ' label', function() {
                var label = this;
                setTimeout(function() {
                    syncSortSelectionUI();
                    if (!label.classList.contains('is-active')) {
                        label.classList.add('is-active');
                    }
                }, 0);
            });
        });

        function syncSortSelectionUI() {
            var sortRoot = document.getElementById("<%= RBsort.ClientID %>");
            if (!sortRoot) {
                return;
            }

            var labels = sortRoot.getElementsByTagName('label');
            for (var i = 0; i < labels.length; i++) {
                labels[i].classList.remove('is-active');
            }

            var radios = sortRoot.querySelectorAll('input[type="radio"]');
            for (var j = 0; j < radios.length; j++) {
                var radio = radios[j];
                var label = null;

                if (radio.nextElementSibling && radio.nextElementSibling.tagName &&
                    radio.nextElementSibling.tagName.toLowerCase() === 'label') {
                    label = radio.nextElementSibling;
                }
                else if (radio.id) {
                    label = sortRoot.querySelector('label[for="' + radio.id + '"]');
                }
                else {
                    var parent = radio.parentNode;
                    if (parent && parent.tagName && parent.tagName.toLowerCase() === 'label') {
                        label = parent;
                    }
                }

                if (label && radio.checked) {
                    label.classList.add('is-active');
                }
            }
        }
        
        function myrefresh() {
            document.getElementById("<%= Btnrefresh.ClientID %>").click();
        }
        setTimeout("myrefresh()", 120000);

        function notsg(n, g, m) {
            var urlsg = "../teacher/notsign.aspx?nnum=" + n + "&ngrade=" + g + "&qname=" + m;
            TINY.box.show({ iframe: urlsg, boxid: 'frameless', width: 560, height: 420, fixed: false, maskopacity: 60, close: true })
        }
        function closeAttitudeDialog() {
            if (window.__attitudeScoreChanged) {
                window.__attitudeScoreChanged = false;
                window.location.reload();
            }
        }
        function attitude(q, m, a, c) {
            var urlat = "../teacher/attitude.aspx?qid=" + q + "&qname=" + m + "&qattitude=" + a + "&qcid=" + c;
            TINY.box.show({ iframe: urlat, boxid: 'frameless', width: 700, height: 760, fixed: false, maskopacity: 60, close: true, closejs: function () { closeAttitudeDialog() } })
        }
        function attitudegroup(g, m, q, c) {
            var urlat = "../teacher/attitudegroup.aspx?sg=" + g + "&ld=" + m + "&qd=" + q + "&qcid=" + c;
            TINY.box.show({ iframe: urlat, boxid: 'frameless', width: 460, height: 280, fixed: false, maskopacity: 60, close: true })
        }

        // 美化开关提示 Toast
        function showToast(msg, isOn) {
            // 清理旧的
            var oldWrap = document.getElementById('spToastWrap');
            var oldOv = document.getElementById('spToastOverlay');
            if (oldWrap) oldWrap.remove();
            if (oldOv) oldOv.remove();

            // 遮罩
            var ov = document.createElement('div');
            ov.id = 'spToastOverlay';
            ov.className = 'sp-toast-overlay';
            document.body.appendChild(ov);

            // 容器
            var wrap = document.createElement('div');
            wrap.id = 'spToastWrap';
            wrap.className = 'sp-toast-wrap';
            document.body.appendChild(wrap);

            var iconSvg = isOn
                ? "<svg viewBox='0 0 24 24'><polyline points='20 6 9 17 4 12'/></svg>"
                : "<svg viewBox='0 0 24 24'><line x1='18' y1='6' x2='6' y2='18'/><line x1='6' y1='6' x2='18' y2='18'/></svg>";
            var subText = isOn ? '功能已成功开启' : '功能已成功关闭';

            wrap.innerHTML = "<div class='sp-toast " + (isOn ? "on" : "off") + "'>"
                + "<div class='sp-toast-icon'>" + iconSvg + "</div>"
                + "<div class='sp-toast-msg'>" + msg + "</div>"
                + "<div class='sp-toast-sub'>" + subText + "</div>"
                + "<div class='sp-toast-bar'></div>"
                + "</div>";

            // 点击遮罩可提前关闭
            ov.addEventListener('click', function() { dismissToast(); });

            // 自动关闭
            setTimeout(dismissToast, 2200);

            function dismissToast() {
                var t = wrap.querySelector('.sp-toast');
                if (t && !t.classList.contains('hide')) {
                    t.classList.add('hide');
                    ov.classList.add('hide');
                    setTimeout(function() {
                        if (wrap.parentNode) wrap.remove();
                        if (ov.parentNode) ov.remove();
                    }, 400);
                }
            }
        }
    </script>
</asp:Content>
