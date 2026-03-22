#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\learnrate.aspx.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "B394D1CB535DDB02B1171884D5FC895A"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\learnrate.aspx.cs"
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Reflection;

namespace LearnSite
{
    public partial class teacher_learnrate : System.Web.UI.Page
    {
        // 移除手动声明的控件字段，使用 CodeFile 时 ASP.NET 会自动生成
        // protected Label LabelGradeClass;
        // protected DropDownList DDLCid;
        // protected Label Label1;
        // protected Anthem.GridView GridViewclass;
        // protected ImageButton Btnreflash;
        // protected Label Labelmsg;
        
        private int wgrade = 0;
        private int wclass = 0;
        private int wcid = 0;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            // 获取参数
            string grade = Request.QueryString["wgrade"];
            string cls = Request.QueryString["wclass"];
            string cid = Request.QueryString["wcid"];
            
            if (!string.IsNullOrEmpty(grade) && int.TryParse(grade, out wgrade))
            {
                if (!string.IsNullOrEmpty(cls) && int.TryParse(cls, out wclass))
                {
                    if (!string.IsNullOrEmpty(cid) && int.TryParse(cid, out wcid))
                    {
                        if (!IsPostBack)
                        {
                            LoadCourseList();
                            if (DDLCid != null && DDLCid.Items.Count > 0)
                            {
                                DDLCid.SelectedValue = wcid.ToString();
                            }
                        }
                    }
                }
            }
            
            if (!IsPostBack)
            {
                showrate();
            }
        }
        
        // 加载课程列表
        private void LoadCourseList()
        {
            if (DDLCid == null) return;
            
            string connectionString = "";
            try
            {
                connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch
            {
                return;
            }
            
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string sql = @"
                        SELECT Cid, Ctitle 
                        FROM Courses 
                        WHERE Cdelete = 0 OR Cdelete IS NULL
                        ORDER BY Cid DESC
                    ";
                    
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            DDLCid.Items.Clear();
                            while (reader.Read())
                            {
                                ListItem item = new ListItem();
                                item.Value = reader["Cid"].ToString();
                                item.Text = reader["Ctitle"] != DBNull.Value ? reader["Ctitle"].ToString() : "未命名课程";
                                DDLCid.Items.Add(item);
                            }
                        }
                    }
                }
            }
            catch { }
        }
        
        // 显示学习进度
        protected void showrate()
        {
            if (GridViewclass == null) return;
            
            try
            {
                // 获取当前选中的课程ID
                int cid = wcid;
                if (DDLCid != null && !string.IsNullOrEmpty(DDLCid.SelectedValue))
                {
                    if (!int.TryParse(DDLCid.SelectedValue, out cid))
                    {
                        cid = wcid;
                    }
                }
                
                if (cid == 0) return;
                
                // 获取年级和班级
                int sgrade = wgrade;
                int sclass = wclass;
                
                // 直接使用备用方法获取数据，避免 BLL 层的重复列问题
                // BLL.Courses.CourseRate 方法存在重复列的问题，暂时跳过
                DataTable dt = GetCourseRateData(cid, sgrade, sclass);
                
                // 确保数据表没有重复列
                if (dt != null)
                {
                    dt = FixDuplicateColumns(dt);
                    
                    if (LabelGradeClass != null)
                    {
                        LabelGradeClass.Text = string.Format(" {0}年级 {1}班 ", sgrade, sclass);
                    }
                    
                    GridViewclass.DataSource = dt;
                    GridViewclass.DataBind();
                }
            }
            catch (Exception ex)
            {
                if (Labelmsg != null)
                {
                    Labelmsg.Text = "加载数据时出错: " + ex.Message;
                    Labelmsg.ForeColor = System.Drawing.Color.Red;
                }
            }
        }
        
        // 修复重复列的问题 - .NET 2.0 兼容版本
        private DataTable FixDuplicateColumns(DataTable dt)
        {
            if (dt == null) return null;
            
            // 检查是否有重复的列名 - 使用 Dictionary 代替 HashSet（.NET 2.0 兼容）
            System.Collections.Generic.Dictionary<string, bool> columnNames = new System.Collections.Generic.Dictionary<string, bool>();
            System.Collections.Generic.List<string> duplicateColumns = new System.Collections.Generic.List<string>();
            
            foreach (DataColumn col in dt.Columns)
            {
                if (columnNames.ContainsKey(col.ColumnName))
                {
                    duplicateColumns.Add(col.ColumnName);
                }
                else
                {
                    columnNames.Add(col.ColumnName, true);
                }
            }
            
            // 如果没有重复列，直接返回原表
            if (duplicateColumns.Count == 0)
            {
                return dt;
            }
            
            // 如果有重复列，创建新表并移除重复
            DataTable newDt = new DataTable();
            
            // 添加唯一的列
            foreach (DataColumn col in dt.Columns)
            {
                if (!newDt.Columns.Contains(col.ColumnName))
                {
                    DataColumn newCol = new DataColumn(col.ColumnName, col.DataType);
                    newCol.AllowDBNull = col.AllowDBNull;
                    newCol.DefaultValue = col.DefaultValue;
                    newCol.MaxLength = col.MaxLength;
                    newDt.Columns.Add(newCol);
                }
            }
            
            // 复制数据
            foreach (DataRow row in dt.Rows)
            {
                DataRow newRow = newDt.NewRow();
                foreach (DataColumn col in newDt.Columns)
                {
                    if (dt.Columns.Contains(col.ColumnName))
                    {
                        try
                        {
                            newRow[col.ColumnName] = row[col.ColumnName];
                        }
                        catch
                        {
                            // 如果复制失败，跳过
                        }
                    }
                }
                newDt.Rows.Add(newRow);
            }
            
            return newDt;
        }
        
        // 学生信息类（.NET 2.0 兼容）
        private class StudentInfo
        {
            public int Hid;      // 实际存储 Students.Sid（为了保持字段名一致性，虽然叫 Hid 但存的是 Sid）
            public string Snum;  // 学号
            public string Sname; // 姓名
            
            public StudentInfo(int sid, string snum, string sname)
            {
                this.Hid = sid;   // 存储 Students.Sid
                this.Snum = snum;
                this.Sname = sname;
            }
        }
        
        // 备用方法：直接从数据库获取学习进度数据
        private DataTable GetCourseRateData(int cid, int sgrade, int sclass)
        {
            string connectionString = "";
            try
            {
                connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch
            {
                return null;
            }
            
            DataTable dt = new DataTable();
            
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    
                    // 首先获取该课程的所有任务（Listmenu）
                    System.Collections.Generic.List<System.Collections.Generic.KeyValuePair<int, string>> tasks = 
                        new System.Collections.Generic.List<System.Collections.Generic.KeyValuePair<int, string>>();
                    
                    string taskSql = @"
                        SELECT Lid, Ltitle 
                        FROM Listmenu 
                        WHERE Lcid = @Cid 
                        AND (lshow = 'True' OR lshow = 1 OR lshow = '1')
                        ORDER BY Lid
                    ";
                    
                    using (SqlCommand cmd = new SqlCommand(taskSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Cid", cid);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                                string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "";
                                if (lid > 0 && !string.IsNullOrEmpty(ltitle))
                                {
                                    tasks.Add(new System.Collections.Generic.KeyValuePair<int, string>(lid, ltitle));
                                }
                            }
                        }
                    }
                    
                    // 创建 DataTable 结构
                    dt.Columns.Add("学号", typeof(string));
                    dt.Columns.Add("姓名", typeof(string));
                    
                    // 为每个任务添加一列，使用字典存储任务ID到列名的映射，确保列名唯一
                    System.Collections.Generic.Dictionary<int, string> taskColumnMap = 
                        new System.Collections.Generic.Dictionary<int, string>();
                    System.Collections.Generic.Dictionary<string, bool> columnNames = 
                        new System.Collections.Generic.Dictionary<string, bool>();
                    
                    // 先添加已有的列名到字典中
                    columnNames.Add("学号", true);
                    columnNames.Add("姓名", true);
                    
                    foreach (System.Collections.Generic.KeyValuePair<int, string> task in tasks)
                    {
                        string columnName = task.Value;
                        // 如果列名为空或只有空格，使用默认名称（.NET 2.0 兼容）
                        if (string.IsNullOrEmpty(columnName) || columnName.Trim().Length == 0)
                        {
                            columnName = "任务" + task.Key.ToString();
                        }
                        
                        // 如果列名已存在，添加后缀使其唯一
                        int suffix = 1;
                        string uniqueColumnName = columnName;
                        while (columnNames.ContainsKey(uniqueColumnName))
                        {
                            uniqueColumnName = columnName + "_" + suffix.ToString();
                            suffix++;
                        }
                        columnNames.Add(uniqueColumnName, true);
                        taskColumnMap[task.Key] = uniqueColumnName;
                        dt.Columns.Add(uniqueColumnName, typeof(string));
                    }
                    
                    // 添加总计列
                    dt.Columns.Add("完成数", typeof(int));
                    dt.Columns.Add("总任务数", typeof(int));
                    
                    // 获取所有学生 - 先读取到列表中，避免嵌套 DataReader 问题
                    // 注意：需要获取 Sid（学生ID）而不是 Hid
                    string studentSql = @"
                        SELECT S.Sid, S.Snum, S.Sname 
                        FROM Students S
                        WHERE S.Sgrade = @Sgrade AND S.Sclass = @Sclass
                        ORDER BY S.Snum
                    ";
                    
                    // 使用 StudentInfo 存储：Sid, Snum, Sname
                    System.Collections.Generic.List<StudentInfo> students = 
                        new System.Collections.Generic.List<StudentInfo>();
                    
                    using (SqlCommand cmd = new SqlCommand(studentSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Sgrade", sgrade);
                        cmd.Parameters.AddWithValue("@Sclass", sclass);
                        
                        try
                        {
                            using (SqlDataReader studentReader = cmd.ExecuteReader())
                            {
                                while (studentReader.Read())
                                {
                                    int sid = studentReader["Sid"] != DBNull.Value ? Convert.ToInt32(studentReader["Sid"]) : 0;
                                    string snum = studentReader["Snum"] != DBNull.Value ? studentReader["Snum"].ToString() : "";
                                    string sname = studentReader["Sname"] != DBNull.Value ? studentReader["Sname"].ToString() : "";
                                    
                                    if (sid > 0 && !string.IsNullOrEmpty(snum))
                                    {
                                        students.Add(new StudentInfo(sid, snum, sname));
                                    }
                                }
                            }
                        }
                        catch (SqlException ex)
                        {
                            // 如果查询失败，显示错误
                            if (Labelmsg != null)
                            {
                                Labelmsg.Text = "查询学生数据失败: " + ex.Message;
                                Labelmsg.ForeColor = System.Drawing.Color.Red;
                            }
                            return dt;
                        }
                    }
                    
                    // 现在处理每个学生的数据
                    foreach (StudentInfo student in students)
                    {
                        int sid = student.Hid;  // Hid 字段实际存储的是 Sid
                        string snum = student.Snum;
                        string sname = student.Sname;
                        
                        DataRow row = dt.NewRow();
                        row["学号"] = snum;
                        row["姓名"] = sname;
                        
                        // 查询每个学生的任务完成情况
                        int completedCount = 0;
                        foreach (System.Collections.Generic.KeyValuePair<int, string> task in tasks)
                        {
                            // 使用正确的列名：Shid（学生ID，对应 Students.Sid）和 Smid（任务ID）
                            string checkSql = @"
                                SELECT COUNT(*) 
                                FROM Summary
                                WHERE Shid = @Shid 
                                AND Smid = @Smid
                                AND (Sshow = 1 OR Sshow IS NULL)
                            ";
                            
                            try
                            {
                                using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                                {
                                    checkCmd.Parameters.AddWithValue("@Shid", sid);
                                    checkCmd.Parameters.AddWithValue("@Smid", task.Key);
                                    object result = checkCmd.ExecuteScalar();
                                    int count = result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
                                    
                                    // 使用映射获取列名
                                    string columnName = taskColumnMap[task.Key];
                                    
                                    row[columnName] = count > 0 ? "√" : "";
                                    if (count > 0) completedCount++;
                                }
                            }
                            catch (SqlException ex)
                            {
                                // 如果查询失败，显示错误
                                if (Labelmsg != null && Labelmsg.Text.Length < 200)
                                {
                                    Labelmsg.Text = "查询任务完成情况失败: " + ex.Message;
                                    Labelmsg.ForeColor = System.Drawing.Color.Red;
                                }
                                // 跳过这个任务
                                row[taskColumnMap[task.Key]] = "";
                            }
                        }
                        
                        row["完成数"] = completedCount;
                        row["总任务数"] = tasks.Count;
                        
                        dt.Rows.Add(row);
                    }
                }
            }
            catch (Exception ex)
            {
                // 记录错误但不抛出异常
                if (Labelmsg != null)
                {
                    Labelmsg.Text = "获取数据时出错: " + ex.Message;
                    Labelmsg.ForeColor = System.Drawing.Color.Red;
                }
                return null;
            }
            
            return dt;
        }
        
        // 课程下拉框选择改变事件
        protected void DDLCid_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(DDLCid.SelectedValue))
            {
                int.TryParse(DDLCid.SelectedValue, out wcid);
            }
            showrate();
        }
        
        // GridView 行数据绑定
        protected void GridViewclass_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // 可以在这里添加行数据绑定的逻辑
        }
        
        // 刷新按钮点击事件
        protected void Btnreflash_Click(object sender, ImageClickEventArgs e)
        {
            showrate();
        }
    }
}



#line default
#line hidden
