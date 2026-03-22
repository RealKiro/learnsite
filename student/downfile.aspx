<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_downfile, LearnSite" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            EnsureTables();
            LoadResourceData();
            LoadRelatedResources();
        }
    }
    
    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(LabelFid.Text))
        {
            LoadLikeCount();
            LoadFavoriteCount();
            CheckUserActions();
        }
    }
    
    // 加载资源数据
    private void LoadResourceData()
    {
        string fid = Request.QueryString["fid"];
        if (string.IsNullOrEmpty(fid))
        {
            ShowError("缺少资源ID参数", "请在URL中提供 fid 参数，例如：downfile.aspx?fid=1");
            return;
        }
        
        LabelFid.Text = fid;
        
        // 调试模式
        bool debugMode = Request.QueryString["debug"] == "1";
        System.Text.StringBuilder debugInfo = new System.Text.StringBuilder();
        
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                if (debugMode)
                {
                    debugInfo.Append("<div style='background: #fef3c7; border: 1px solid #fde68a; padding: 16px; margin: 16px 0; border-radius: 8px;'>");
                    debugInfo.Append("<h3 style='margin: 0 0 12px 0; color: #92400e;'>🔍 调试信息</h3>");
                    debugInfo.Append("<p style='margin: 4px 0; color: #92400e;'><strong>请求的资源ID:</strong> " + fid + "</p>");
                }
                
                // 获取所有表
                System.Collections.Generic.List<string> allTables = new System.Collections.Generic.List<string>();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            allTables.Add(reader["TABLE_NAME"].ToString());
                        }
                    }
                }
                
                if (debugMode)
                {
                    debugInfo.Append("<p style='margin: 4px 0; color: #92400e;'><strong>数据库中的所有表:</strong> " + string.Join(", ", allTables.ToArray()) + "</p>");
                }
                
                // 尝试多个可能的表和字段组合
                bool found = false;
                System.Collections.Generic.List<string> attemptedTables = new System.Collections.Generic.List<string>();
                
                // 定义要尝试的表和字段映射
                string[][] tableMappings = new string[][] {
                    new string[] { "Files", "FileId", "FileName", "FileSize", "CreateTime", "RelativePath", "UserSnum", "FolderId" },
                    new string[] { "Filelist", "Fid", "Ftitle", "Fsize", "Fdate", "Furl", "Fauthor", "Fclass" },
                    new string[] { "Downfile", "Did", "Dtitle", "Dsize", "Ddate", "Durl", "Dauthor", "Dtype" },
                    new string[] { "Resources", "Rid", "Rtitle", "Rsize", "Rdate", "Rurl", "Rauthor", "Rtype" },
                    new string[] { "Homework", "Hid", "Htitle", "Hsize", "Hdate", "Hurl", "Hauthor", "Htype" },
                    new string[] { "Works", "Wid", "Wtitle", "Wsize", "Wdate", "Wurl", "Wauthor", "Wtype" },
                    // 添加更多可能的表结构
                    new string[] { "OnlineResources", "id", "title", "size", "date", "url", "author", "type" },
                    new string[] { "OnlineResource", "id", "title", "size", "date", "url", "author", "type" },
                    new string[] { "Zaixian", "id", "title", "size", "date", "url", "author", "type" },
                    new string[] { "Resource", "id", "title", "size", "date", "url", "author", "category" },
                    // 通用ID字段的表
                    new string[] { "GenericTable", "id", "name", "size", "createtime", "path", "user", "folder" }
                };
                
                foreach (string[] mapping in tableMappings)
                {
                    string tableName = mapping[0];
                    string idField = mapping[1];
                    
                    if (!TableExists(conn, tableName)) continue;
                    
                    attemptedTables.Add(tableName);
                    
                    if (debugMode)
                    {
                        // 检查表中的记录数
                        int recordCount = 0;
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                            "SELECT COUNT(*) FROM [" + tableName + "]", conn))
                        {
                            recordCount = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                        debugInfo.Append("<p style='margin: 4px 0; color: #92400e;'><strong>检查表 " + tableName + ":</strong> " + recordCount + " 条记录</p>");
                    }
                    
                    found = TryLoadFromTableWithMapping(conn, fid, mapping, debugMode, debugInfo);
                    
                    if (found)
                    {
                        if (debugMode)
                        {
                            debugInfo.Append("<p style='margin: 4px 0; color: #16a34a; font-weight: 600;'>✅ 成功从表 " + tableName + " 加载资源！</p>");
                            debugInfo.Append("</div>");
                            
                            // 在页面顶部显示调试信息
                            System.Web.UI.LiteralControl debugControl = new System.Web.UI.LiteralControl(debugInfo.ToString());
                            this.Page.Form.Controls.AddAt(0, debugControl);
                        }
                        break;
                    }
                }
                
                // 如果预定义的表都没找到，尝试自动发现表
                if (!found)
                {
                    if (debugMode)
                    {
                        debugInfo.Append("<p style='margin: 4px 0; color: #f59e0b; font-weight: 600;'>⚠️ 预定义表中未找到，尝试自动发现...</p>");
                    }
                    
                    found = TryAutoDiscoverTable(conn, fid, debugMode, debugInfo, attemptedTables);
                    
                    if (found && debugMode)
                    {
                        debugInfo.Append("<p style='margin: 4px 0; color: #16a34a; font-weight: 600;'>✅ 自动发现成功！</p>");
                        debugInfo.Append("</div>");
                        System.Web.UI.LiteralControl debugControl = new System.Web.UI.LiteralControl(debugInfo.ToString());
                        this.Page.Form.Controls.AddAt(0, debugControl);
                    }
                }
                
                if (!found)
                {
                    if (debugMode)
                    {
                        debugInfo.Append("<p style='margin: 4px 0; color: #dc2626; font-weight: 600;'>❌ 未找到资源</p>");
                        debugInfo.Append("<p style='margin: 4px 0; color: #92400e;'><strong>已尝试的表:</strong> " + string.Join(", ", attemptedTables.ToArray()) + "</p>");
                        debugInfo.Append("</div>");
                    }
                    
                    ShowResourceNotFoundError(conn, fid, debugMode ? debugInfo.ToString() : "");
                }
            }
        }
        catch (Exception ex)
        {
            string errorMsg = ex.Message + "<br/><br/>堆栈跟踪：<br/>" + ex.StackTrace.Replace("\n", "<br/>");
            if (debugMode && debugInfo.Length > 0)
            {
                errorMsg = debugInfo.ToString() + "<br/><br/>" + errorMsg;
            }
            ShowError("加载失败", errorMsg);
        }
    }
    
    // 尝试从指定表加载数据（使用字段映射）
    private bool TryLoadFromTableWithMapping(System.Data.SqlClient.SqlConnection conn, string fid, 
        string[] mapping, bool debugMode, System.Text.StringBuilder debugInfo)
    {
        string tableName = mapping[0];
        string idField = mapping[1];
        
        try
        {
            // 获取表的所有列
            System.Collections.Generic.List<string> columns = new System.Collections.Generic.List<string>();
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@tableName", conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        columns.Add(reader["COLUMN_NAME"].ToString());
                    }
                }
            }
            
            if (debugMode)
            {
                debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #92400e; font-size: 13px;'>表 " + tableName + " 的列: " + string.Join(", ", columns.ToArray()) + "</p>");
            }
            
            // 检查ID字段是否存在
            bool hasIdField = false;
            foreach (string col in columns)
            {
                if (col.Equals(idField, StringComparison.OrdinalIgnoreCase))
                {
                    hasIdField = true;
                    break;
                }
            }
            
            if (!hasIdField)
            {
                if (debugMode)
                {
                    debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #dc2626; font-size: 13px;'>❌ 表中没有ID字段: " + idField + "</p>");
                }
                return false;
            }
            
            // 查询数据
            string query = "SELECT * FROM [" + tableName + "] WHERE [" + idField + "]=@fid";
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@fid", fid);
                
                if (debugMode)
                {
                    debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #92400e; font-size: 13px;'>执行查询: " + query.Replace("@fid", fid) + "</p>");
                }
                
                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        BindResourceDataFromReader(reader, tableName);
                        return true;
                    }
                    else
                    {
                        if (debugMode)
                        {
                            debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #dc2626; font-size: 13px;'>❌ 查询无结果</p>");
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            if (debugMode)
            {
                debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #dc2626; font-size: 13px;'>❌ 错误: " + ex.Message + "</p>");
            }
            System.Diagnostics.Debug.WriteLine("尝试从表 " + tableName + " 加载失败: " + ex.Message);
        }
        
        return false;
    }
    
    // 检查表是否存在
    private bool TableExists(System.Data.SqlClient.SqlConnection conn, string tableName)
    {
        try
        {
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@tableName", conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    // 从 DataReader 绑定数据（智能字段匹配）
    private void BindResourceDataFromReader(System.Data.SqlClient.SqlDataReader reader, string tableName)
    {
        try
        {
            // 文件名字段
            string[] nameFields = new string[] { "FileName", "Ftitle", "Dtitle", "Rtitle", "Title", "Name" };
            foreach (string field in nameFields)
            {
                if (HasColumn(reader, field) && reader[field] != DBNull.Value)
                {
                    spanFileName.InnerText = reader[field].ToString();
                    break;
                }
            }
            
            // 文件大小字段
            string[] sizeFields = new string[] { "FileSize", "Fsize", "Dsize", "Rsize", "Size" };
            foreach (string field in sizeFields)
            {
                if (HasColumn(reader, field) && reader[field] != DBNull.Value)
                {
                    long size = Convert.ToInt64(reader[field]);
                    spanFileSize.InnerText = FormatFileSize(size);
                    break;
                }
            }
            
            // 创建时间字段
            string[] dateFields = new string[] { "CreateTime", "Fdate", "Ddate", "Rdate", "Date", "CreateDate", "UploadDate" };
            foreach (string field in dateFields)
            {
                if (HasColumn(reader, field) && reader[field] != DBNull.Value)
                {
                    spanCreateTime.InnerText = Convert.ToDateTime(reader[field]).ToString("yyyy-MM-dd HH:mm");
                    break;
                }
            }
            
            // 文件夹/分类字段
            string[] folderFields = new string[] { "FolderId", "Fclass", "Dtype", "Rtype", "Category", "Type" };
            foreach (string field in folderFields)
            {
                if (HasColumn(reader, field) && reader[field] != DBNull.Value)
                {
                    spanFolderId.InnerText = reader[field].ToString();
                    break;
                }
            }
            
            // 上传者字段
            string[] authorFields = new string[] { "UserSnum", "Fauthor", "Dauthor", "Rauthor", "Author", "Uploader" };
            foreach (string field in authorFields)
            {
                if (HasColumn(reader, field) && reader[field] != DBNull.Value)
                {
                    spanUploader.InnerText = reader[field].ToString();
                    break;
                }
            }
            
            // 下载路径字段
            string[] urlFields = new string[] { "RelativePath", "Furl", "Durl", "Rurl", "Url", "Path", "FilePath" };
            foreach (string field in urlFields)
            {
                if (HasColumn(reader, field) && reader[field] != DBNull.Value)
                {
                    string path = reader[field].ToString();
                    if (!string.IsNullOrEmpty(path))
                    {
                        HLDownload.NavigateUrl = path.StartsWith("/") ? path : "/" + path;
                        HLDownload.Visible = true;
                        
                        // 获取文件扩展名
                        string ext = System.IO.Path.GetExtension(path).ToLower();
                        spanFileType.InnerText = GetFileTypeIcon(ext);
                        break;
                    }
                }
            }
            
            // 如果没有找到文件类型，使用默认图标
            if (string.IsNullOrEmpty(spanFileType.InnerText))
            {
                spanFileType.InnerText = "📄";
            }
            
            divPanelResource.Visible = true;
            divPanelError.Visible = false;
            
            System.Diagnostics.Debug.WriteLine("成功从表 " + tableName + " 加载资源");
        }
        catch (Exception ex)
        {
            ShowError("数据绑定失败", ex.Message);
        }
    }
    
    // 检查列是否存在
    private bool HasColumn(System.Data.SqlClient.SqlDataReader reader, string columnName)
    {
        try
        {
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (reader.GetName(i).Equals(columnName, StringComparison.OrdinalIgnoreCase))
                    return true;
            }
        }
        catch { }
        return false;
    }
    
    // 自动发现包含指定ID的表
    private bool TryAutoDiscoverTable(System.Data.SqlClient.SqlConnection conn, string fid, 
        bool debugMode, System.Text.StringBuilder debugInfo, System.Collections.Generic.List<string> attemptedTables)
    {
        try
        {
            // 获取所有表
            System.Collections.Generic.List<string> allTables = new System.Collections.Generic.List<string>();
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME", conn))
            {
                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string tableName = reader["TABLE_NAME"].ToString();
                        // 跳过已经尝试过的表
                        if (!attemptedTables.Contains(tableName))
                        {
                            allTables.Add(tableName);
                        }
                    }
                }
            }
            
            // 遍历所有表
            foreach (string tableName in allTables)
            {
                try
                {
                    // 获取表的列
                    System.Collections.Generic.List<string> columns = new System.Collections.Generic.List<string>();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@tableName ORDER BY ORDINAL_POSITION", conn))
                    {
                        cmd.Parameters.AddWithValue("@tableName", tableName);
                        using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                columns.Add(reader["COLUMN_NAME"].ToString());
                            }
                        }
                    }
                    
                    if (columns.Count == 0) continue;
                    
                    // 查找可能的ID字段
                    string idField = null;
                    string[] possibleIdFields = new string[] { "id", "Id", "ID", "序号", "编号" };
                    foreach (string possibleId in possibleIdFields)
                    {
                        foreach (string col in columns)
                        {
                            if (col.Equals(possibleId, StringComparison.OrdinalIgnoreCase) ||
                                col.EndsWith("id", StringComparison.OrdinalIgnoreCase) ||
                                col.EndsWith("Id") ||
                                col.EndsWith("ID"))
                            {
                                idField = col;
                                break;
                            }
                        }
                        if (idField != null) break;
                    }
                    
                    // 如果没有找到ID字段，使用第一列
                    if (idField == null && columns.Count > 0)
                    {
                        idField = columns[0];
                    }
                    
                    if (debugMode)
                    {
                        debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #92400e; font-size: 13px;'>尝试表 " + tableName + " (ID字段: " + idField + ")</p>");
                    }
                    
                    // 尝试查询
                    string query = "SELECT * FROM [" + tableName + "] WHERE [" + idField + "]=@fid";
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@fid", fid);
                        using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                if (debugMode)
                                {
                                    debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #16a34a; font-size: 13px;'>✅ 在表 " + tableName + " 中找到记录！</p>");
                                }
                                
                                BindResourceDataFromReader(reader, tableName);
                                return true;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (debugMode)
                    {
                        debugInfo.Append("<p style='margin: 4px 0 4px 20px; color: #dc2626; font-size: 13px;'>❌ 表 " + tableName + " 错误: " + ex.Message + "</p>");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            if (debugMode)
            {
                debugInfo.Append("<p style='margin: 4px 0; color: #dc2626;'>自动发现失败: " + ex.Message + "</p>");
            }
        }
        
        return false;
    }
    
    // 显示资源不存在错误，并列出可用资源
    private void ShowResourceNotFoundError(System.Data.SqlClient.SqlConnection conn, string requestedFid, string debugInfo)
    {
        System.Text.StringBuilder errorMsg = new System.Text.StringBuilder();
        errorMsg.Append("<div style='text-align: left;'>");
        
        // 如果有调试信息，先显示
        if (!string.IsNullOrEmpty(debugInfo))
        {
            errorMsg.Append(debugInfo);
        }
        
        errorMsg.Append("<p style='margin-bottom: 20px;'>未找到ID为 <strong>" + requestedFid + "</strong> 的资源。</p>");
        
        try
        {
            bool foundAnyResources = false;
            
            // 尝试从多个表中查找资源
            string[] tables = new string[] { "Files", "Filelist", "Downfile", "Resources" };
            string[] idFields = new string[] { "FileId", "Fid", "Did", "Rid" };
            string[] nameFields = new string[] { "FileName", "Ftitle", "Dtitle", "Rtitle" };
            string[] dateFields = new string[] { "CreateTime", "Fdate", "Ddate", "Rdate" };
            
            for (int i = 0; i < tables.Length; i++)
            {
                if (!TableExists(conn, tables[i])) continue;
                
                try
                {
                    // 检查表中是否有数据
                    string countQuery = "SELECT COUNT(*) FROM [" + tables[i] + "]";
                    using (System.Data.SqlClient.SqlCommand countCmd = new System.Data.SqlClient.SqlCommand(countQuery, conn))
                    {
                        int count = Convert.ToInt32(countCmd.ExecuteScalar());
                        if (count == 0) continue;
                    }
                    
                    // 获取资源列表
                    string query = "SELECT TOP 10 * FROM [" + tables[i] + "] ORDER BY 1 DESC";
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                    {
                        using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                if (!foundAnyResources)
                                {
                                    errorMsg.Append("<p style='font-weight: 600; color: #1e293b; margin-bottom: 12px;'>📋 可用的资源：</p>");
                                    errorMsg.Append("<div style='background: #f8fafc; border-radius: 8px; padding: 16px; border: 1px solid #e2e8f0;'>");
                                    foundAnyResources = true;
                                }
                                
                                errorMsg.Append("<p style='font-size: 13px; color: #667eea; font-weight: 600; margin: 12px 0 8px 0;'>来自表: " + tables[i] + "</p>");
                                
                                int resourceCount = 0;
                                while (reader.Read() && resourceCount < 10)
                                {
                                    resourceCount++;
                                    
                                    // 获取ID
                                    string fileId = "";
                                    if (HasColumn(reader, idFields[i]))
                                        fileId = reader[idFields[i]].ToString();
                                    else if (reader.FieldCount > 0)
                                        fileId = reader[0].ToString();
                                    
                                    // 获取文件名
                                    string fileName = "";
                                    if (HasColumn(reader, nameFields[i]))
                                        fileName = reader[nameFields[i]].ToString();
                                    else if (HasColumn(reader, "Title"))
                                        fileName = reader["Title"].ToString();
                                    else if (HasColumn(reader, "Name"))
                                        fileName = reader["Name"].ToString();
                                    
                                    // 获取日期
                                    string createTime = "";
                                    if (HasColumn(reader, dateFields[i]) && reader[dateFields[i]] != DBNull.Value)
                                    {
                                        createTime = Convert.ToDateTime(reader[dateFields[i]]).ToString("yyyy-MM-dd");
                                    }
                                    
                                    if (string.IsNullOrEmpty(fileName))
                                        fileName = "未命名资源";
                                    
                                    errorMsg.Append("<div style='padding: 10px; margin-bottom: 8px; background: #fff; border-radius: 6px; border: 1px solid #e2e8f0;'>");
                                    errorMsg.Append("<a href='downfile.aspx?fid=" + fileId + "' style='color: #667eea; text-decoration: none; font-weight: 600; display: block; margin-bottom: 4px;'>");
                                    errorMsg.Append("📄 " + fileName);
                                    errorMsg.Append("</a>");
                                    errorMsg.Append("<span style='font-size: 12px; color: #64748b;'>ID: " + fileId);
                                    if (!string.IsNullOrEmpty(createTime))
                                    {
                                        errorMsg.Append(" | 创建时间: " + createTime);
                                    }
                                    errorMsg.Append("</span>");
                                    errorMsg.Append("</div>");
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("查询表 " + tables[i] + " 失败: " + ex.Message);
                }
            }
            
            if (foundAnyResources)
            {
                errorMsg.Append("</div>");
            }
            else
            {
                errorMsg.Append("<div style='background: #fef3c7; border: 1px solid #fde68a; border-radius: 8px; padding: 16px; margin-top: 16px;'>");
                errorMsg.Append("<p style='color: #92400e; margin: 0;'><strong>⚠️ 提示：</strong>数据库中没有找到任何资源数据。</p>");
                errorMsg.Append("<p style='color: #92400e; margin: 8px 0 0 0;'>请先在数据库中添加资源数据，或联系管理员。</p>");
                errorMsg.Append("<p style='color: #92400e; margin: 8px 0 0 0; font-size: 12px;'>已检查的表: Files, Filelist, Downfile, Resources</p>");
                errorMsg.Append("</div>");
            }
        }
        catch (Exception ex)
        {
            errorMsg.Append("<p style='color: #dc2626; margin-top: 12px;'>获取资源列表失败: " + ex.Message + "</p>");
        }
        
        errorMsg.Append("<div style='margin-top: 24px; text-align: center;'>");
        errorMsg.Append("<a href='myfile.aspx' style='display: inline-block; padding: 10px 24px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; border-radius: 8px; text-decoration: none; font-weight: 600;'>← 返回资源列表</a>");
        errorMsg.Append("</div>");
        errorMsg.Append("</div>");
        
        ShowError("资源不存在", errorMsg.ToString());
    }

    
    // 格式化文件大小
    private string FormatFileSize(long bytes)
    {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024.0).ToString("F2") + " KB";
        if (bytes < 1024 * 1024 * 1024) return (bytes / 1024.0 / 1024.0).ToString("F2") + " MB";
        return (bytes / 1024.0 / 1024.0 / 1024.0).ToString("F2") + " GB";
    }
    
    // 获取文件类型图标
    private string GetFileTypeIcon(string ext)
    {
        switch (ext)
        {
            case ".pdf": return "📄 PDF文档";
            case ".doc": case ".docx": return "📝 Word文档";
            case ".xls": case ".xlsx": return "📊 Excel表格";
            case ".ppt": case ".pptx": return "📽️ PPT演示";
            case ".zip": case ".rar": case ".7z": return "📦 压缩文件";
            case ".jpg": case ".jpeg": case ".png": case ".gif": return "🖼️ 图片文件";
            case ".mp4": case ".avi": case ".mov": return "🎬 视频文件";
            case ".mp3": case ".wav": return "🎵 音频文件";
            case ".txt": return "📃 文本文件";
            case ".html": case ".htm": return "🌐 网页文件";
            default: return "📁 " + ext.TrimStart('.');
        }
    }
    
    // 显示错误
    private void ShowError(string title, string message)
    {
        spanErrorTitle.InnerText = title;
        spanErrorMessage.InnerHtml = message;
        divPanelError.Visible = true;
        divPanelResource.Visible = false;
    }
    
    // 加载相关资源
    private void LoadRelatedResources()
    {
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 尝试从多个表中加载资源
                System.Collections.Generic.List<RelatedResource> resources = new System.Collections.Generic.List<RelatedResource>();
                
                // 定义表和字段映射
                string[][] tableMappings = new string[][] {
                    new string[] { "Files", "FileId", "FileName", "CreateTime" },
                    new string[] { "Filelist", "Fid", "Ftitle", "Fdate" },
                    new string[] { "Downfile", "Did", "Dtitle", "Ddate" },
                    new string[] { "Resources", "Rid", "Rtitle", "Rdate" },
                    new string[] { "Homework", "Hid", "Htitle", "Hdate" },
                    new string[] { "Works", "Wid", "Wtitle", "Wdate" }
                };
                
                foreach (string[] mapping in tableMappings)
                {
                    string tableName = mapping[0];
                    string idField = mapping[1];
                    string nameField = mapping[2];
                    string dateField = mapping[3];
                    
                    if (!TableExists(conn, tableName)) continue;
                    
                    try
                    {
                        // 检查字段是否存在
                        System.Collections.Generic.List<string> columns = new System.Collections.Generic.List<string>();
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@tableName", conn))
                        {
                            cmd.Parameters.AddWithValue("@tableName", tableName);
                            using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    columns.Add(reader["COLUMN_NAME"].ToString());
                                }
                            }
                        }
                        
                        // 检查必需字段是否存在
                        bool hasIdField = false;
                        bool hasNameField = false;
                        foreach (string col in columns)
                        {
                            if (col.Equals(idField, StringComparison.OrdinalIgnoreCase))
                                hasIdField = true;
                            if (col.Equals(nameField, StringComparison.OrdinalIgnoreCase))
                                hasNameField = true;
                        }
                        
                        if (!hasIdField || !hasNameField) continue;
                        
                        // 构建查询
                        string orderBy = "";
                        foreach (string col in columns)
                        {
                            if (col.Equals(dateField, StringComparison.OrdinalIgnoreCase))
                            {
                                orderBy = " ORDER BY [" + dateField + "] DESC";
                                break;
                            }
                        }
                        
                        if (string.IsNullOrEmpty(orderBy))
                        {
                            orderBy = " ORDER BY [" + idField + "] DESC";
                        }
                        
                        string query = "SELECT TOP 10 [" + idField + "] as FileId, [" + nameField + "] as FileName FROM [" + tableName + "]" + orderBy;
                        
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                        {
                            using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    RelatedResource resource = new RelatedResource();
                                    resource.FileId = reader["FileId"].ToString();
                                    resource.FileName = reader["FileName"].ToString();
                                    resources.Add(resource);
                                }
                            }
                        }
                        
                        // 如果已经找到资源，就不再查询其他表
                        if (resources.Count > 0) break;
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("从表 " + tableName + " 加载相关资源失败: " + ex.Message);
                    }
                }
                
                // 绑定数据
                if (resources.Count > 0)
                {
                    RptRelated.DataSource = resources;
                    RptRelated.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("加载相关资源失败: " + ex.Message);
        }
    }
    
    // 相关资源类
    public class RelatedResource
    {
        private string fileId;
        private string fileName;
        
        public string FileId
        {
            get { return fileId; }
            set { fileId = value; }
        }
        
        public string FileName
        {
            get { return fileName; }
            set { fileName = value; }
        }
    }
    
    // 点赞
    protected void BtnLike_Click(object sender, EventArgs e)
    {
        string sid = GetStudentId();
        if (string.IsNullOrEmpty(sid))
        {
            spanActionMsg.InnerText = "请先登录";
            divActionMsg.Visible = true;
            return;
        }
        
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查是否已点赞
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM ResourceLikes WHERE Fid=@fid AND Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                    {
                        spanActionMsg.InnerText = "您已经点赞过了";
                        divActionMsg.Visible = true;
                        return;
                    }
                }
                
                // 添加点赞
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "INSERT INTO ResourceLikes (Fid, Sid, Ldate) VALUES (@fid, @sid, GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    cmd.ExecuteNonQuery();
                }
            }
            
            LoadLikeCount();
            BtnLike.Enabled = false;
            BtnLike.Text = "✓ 已点赞";
            spanActionMsg.InnerText = "点赞成功！";
            divActionMsg.Visible = true;
        }
        catch (Exception ex)
        {
            spanActionMsg.InnerText = "点赞失败：" + ex.Message;
            divActionMsg.Visible = true;
        }
    }
    
    // 收藏
    protected void BtnFavorite_Click(object sender, EventArgs e)
    {
        string sid = GetStudentId();
        if (string.IsNullOrEmpty(sid))
        {
            spanActionMsg.InnerText = "请先登录";
            divActionMsg.Visible = true;
            return;
        }
        
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查是否已收藏
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM ResourceFavorites WHERE Fid=@fid AND Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                    {
                        spanActionMsg.InnerText = "您已经收藏过了";
                        divActionMsg.Visible = true;
                        return;
                    }
                }
                
                // 添加收藏
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "INSERT INTO ResourceFavorites (Fid, Sid, Fdate) VALUES (@fid, @sid, GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    cmd.ExecuteNonQuery();
                }
            }
            
            LoadFavoriteCount();
            BtnFavorite.Enabled = false;
            BtnFavorite.Text = "★ 已收藏";
            spanActionMsg.InnerText = "收藏成功！";
            divActionMsg.Visible = true;
        }
        catch (Exception ex)
        {
            spanActionMsg.InnerText = "收藏失败：" + ex.Message;
            divActionMsg.Visible = true;
        }
    }
    
    // 加载点赞数
    private void LoadLikeCount()
    {
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM ResourceLikes WHERE Fid=@fid", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    spanLikeCount.InnerText = cmd.ExecuteScalar().ToString();
                }
            }
        }
        catch { spanLikeCount.InnerText = "0"; }
    }
    
    // 加载收藏数
    private void LoadFavoriteCount()
    {
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM ResourceFavorites WHERE Fid=@fid", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    spanFavCount.InnerText = cmd.ExecuteScalar().ToString();
                }
            }
        }
        catch { spanFavCount.InnerText = "0"; }
    }
    
    // 检查用户操作状态
    private void CheckUserActions()
    {
        string sid = GetStudentId();
        if (string.IsNullOrEmpty(sid)) return;
        
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 检查点赞
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM ResourceLikes WHERE Fid=@fid AND Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                    {
                        BtnLike.Enabled = false;
                        BtnLike.Text = "✓ 已点赞";
                    }
                }
                
                // 检查收藏
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM ResourceFavorites WHERE Fid=@fid AND Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@fid", LabelFid.Text);
                    cmd.Parameters.AddWithValue("@sid", sid);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                    {
                        BtnFavorite.Enabled = false;
                        BtnFavorite.Text = "★ 已收藏";
                    }
                }
            }
        }
        catch { }
    }
    
    // 确保表存在
    private void EnsureTables()
    {
        try
        {
            string connStr = GetConnectionString();
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 创建点赞表
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ResourceLikes' AND xtype='U')
                    CREATE TABLE ResourceLikes (
                        Lid INT IDENTITY(1,1) PRIMARY KEY,
                        Fid INT NOT NULL,
                        Sid VARCHAR(50) NOT NULL,
                        Ldate DATETIME NOT NULL
                    )", conn))
                {
                    cmd.ExecuteNonQuery();
                }
                
                // 创建收藏表
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ResourceFavorites' AND xtype='U')
                    CREATE TABLE ResourceFavorites (
                        Fvid INT IDENTITY(1,1) PRIMARY KEY,
                        Fid INT NOT NULL,
                        Sid VARCHAR(50) NOT NULL,
                        Fdate DATETIME NOT NULL
                    )", conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }
    
    // 获取数据库连接字符串
    private string GetConnectionString()
    {
        try
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        catch
        {
            return "";
        }
    }
    
    // 获取学生ID
    private string GetStudentId()
    {
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%"))
                {
                    try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); }
                    catch { }
                }
                
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic |
                        System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    
                    System.Reflection.PropertyInfo pSnum = ct.GetProperty("Snum");
                    if (pSnum != null)
                    {
                        object v = pSnum.GetValue(m, null);
                        if (v != null && !string.IsNullOrEmpty(v.ToString()))
                            return v.ToString();
                    }
                    
                    System.Reflection.PropertyInfo pSid = ct.GetProperty("Sid");
                    if (pSid != null)
                    {
                        object v = pSid.GetValue(m, null);
                        if (v != null && !string.IsNullOrEmpty(v.ToString()))
                            return v.ToString();
                    }
                }
            }
        }
        catch { }
        return "";
    }
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }

.resource-page {
    min-height: 100vh;
    background: #f8fafc;
    padding: 30px 20px;
    font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
}

.resource-container {
    max-width: 1400px;
    margin: 0 auto;
}

.resource-header {
    text-align: center;
    margin-bottom: 30px;
    padding: 30px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
    animation: fadeInDown 0.6s ease;
}

.resource-header h1 {
    font-size: 32px;
    font-weight: 700;
    margin-bottom: 8px;
    color: #fff;
    text-shadow: 0 2px 10px rgba(0,0,0,0.2);
}

.resource-header p {
    font-size: 15px;
    color: #fff;
    opacity: 0.95;
}

.resource-grid {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 24px;
    align-items: start;
}

.resource-main {
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    overflow: hidden;
    animation: fadeInUp 0.6s ease;
}

.resource-card {
    padding: 40px;
}

.file-icon {
    width: 100px;
    height: 100px;
    margin: 0 auto 24px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 48px;
    box-shadow: 0 8px 24px rgba(102, 126, 234, 0.25);
}

.file-name {
    font-size: 26px;
    font-weight: 700;
    color: #1e293b;
    text-align: center;
    margin-bottom: 24px;
    line-height: 1.4;
}

.file-meta {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    margin-bottom: 24px;
    padding: 24px;
    background: #f8fafc;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
}

.meta-item {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.meta-label {
    font-size: 12px;
    color: #64748b;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.meta-value {
    font-size: 15px;
    color: #1e293b;
    font-weight: 600;
}

.action-buttons {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    padding: 24px;
    background: #f8fafc;
    border-top: 1px solid #e2e8f0;
}

.btn {
    flex: 1;
    min-width: 130px;
    padding: 12px 24px;
    border: none;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-decoration: none;
    font-family: inherit;
}

.btn-download {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff !important;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.btn-download:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

.btn-like {
    background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
    color: #fff !important;
    box-shadow: 0 4px 12px rgba(251, 191, 36, 0.3);
}

.btn-like:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(251, 191, 36, 0.4);
}

.btn-like:disabled {
    background: #e2e8f0;
    color: #94a3b8 !important;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
}

.btn-favorite {
    background: linear-gradient(135deg, #ec4899 0%, #be185d 100%);
    color: #fff !important;
    box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);
}

.btn-favorite:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(236, 72, 153, 0.4);
}

.btn-favorite:disabled {
    background: #e2e8f0;
    color: #94a3b8 !important;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
}

.stat-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    background: #fff;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
    border: 1px solid #e2e8f0;
}

.action-msg {
    padding: 12px 20px;
    background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
    color: #065f46;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    text-align: center;
    margin-top: 12px;
}

.resource-sidebar {
    display: flex;
    flex-direction: column;
    gap: 20px;
    position: sticky;
    top: 20px;
}

.sidebar-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    animation: fadeInRight 0.6s ease;
}

.sidebar-title {
    font-size: 17px;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 2px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 8px;
}

.sidebar-title::before {
    content: '📋';
    font-size: 20px;
}

.related-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    max-height: 500px;
    overflow-y: auto;
}

.related-item {
    padding: 12px 14px;
    background: #f8fafc;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
    transition: all 0.2s ease;
}

.related-item:hover {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-color: transparent;
    transform: translateX(4px);
    box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.related-item a {
    color: #475569;
    text-decoration: none;
    font-size: 14px;
    font-weight: 500;
    display: block;
    line-height: 1.5;
}

.related-item:hover a {
    color: #fff;
}

.error-card {
    background: #fff;
    border-radius: 16px;
    padding: 60px 40px;
    text-align: center;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    animation: fadeInUp 0.6s ease;
}

.error-icon {
    width: 80px;
    height: 80px;
    margin: 0 auto 24px;
    background: linear-gradient(135deg, #fecaca 0%, #f87171 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
}

.error-title {
    font-size: 24px;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 12px;
}

.error-message {
    font-size: 15px;
    color: #64748b;
    line-height: 1.6;
    margin-bottom: 24px;
}

.btn-back {
    display: inline-block;
    padding: 12px 28px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff !important;
    border-radius: 10px;
    text-decoration: none;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.btn-back:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

@keyframes fadeInDown {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes fadeInRight {
    from {
        opacity: 0;
        transform: translateX(20px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@media (max-width: 1024px) {
    .resource-grid {
        grid-template-columns: 1fr;
    }
    
    .resource-sidebar {
        position: relative;
        top: 0;
    }
}

@media (max-width: 768px) {
    .resource-page {
        padding: 20px 15px;
    }
    
    .resource-header {
        padding: 20px 15px;
    }
    
    .resource-header h1 {
        font-size: 24px;
    }
    
    .resource-card {
        padding: 24px;
    }
    
    .file-meta {
        grid-template-columns: 1fr;
    }
    
    .action-buttons {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
    }
}
</style>

<div class="resource-page">
    <div class="resource-container">
        <!-- 页面标题 -->
        <div class="resource-header">
            <h1>📚 资源详情</h1>
            <p>查看和下载学习资源</p>
        </div>
        
        <!-- 错误提示面板 -->
        <div id="divPanelError" runat="server" visible="false">
            <div class="error-card">
                <div class="error-icon">❌</div>
                <h2 class="error-title">
                    <span id="spanErrorTitle" runat="server"></span>
                </h2>
                <div class="error-message">
                    <span id="spanErrorMessage" runat="server"></span>
                </div>
                <a href="myfile.aspx" class="btn-back">← 返回资源列表</a>
            </div>
        </div>
        
        <!-- 资源内容面板 -->
        <div id="divPanelResource" runat="server" visible="false">
            <div class="resource-grid">
                <!-- 主内容区 -->
                <div class="resource-main">
                    <div class="resource-card">
                        <!-- 文件图标 -->
                        <div class="file-icon">
                            <span id="spanFileType" runat="server"></span>
                        </div>
                        
                        <!-- 文件名 -->
                        <h1 class="file-name">
                            <span id="spanFileName" runat="server"></span>
                        </h1>
                        
                        <!-- 文件元信息 -->
                        <div class="file-meta">
                            <div class="meta-item">
                                <span class="meta-label">📦 文件大小</span>
                                <span class="meta-value">
                                    <span id="spanFileSize" runat="server"></span>
                                </span>
                            </div>
                            
                            <div class="meta-item">
                                <span class="meta-label">📅 创建时间</span>
                                <span class="meta-value">
                                    <span id="spanCreateTime" runat="server"></span>
                                </span>
                            </div>
                            
                            <div class="meta-item">
                                <span class="meta-label">📁 文件夹</span>
                                <span class="meta-value">
                                    <span id="spanFolderId" runat="server"></span>
                                </span>
                            </div>
                            
                            <div class="meta-item">
                                <span class="meta-label">👤 上传者</span>
                                <span class="meta-value">
                                    <span id="spanUploader" runat="server"></span>
                                </span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 操作按钮 -->
                    <div class="action-buttons">
                        <asp:HyperLink ID="HLDownload" runat="server" CssClass="btn btn-download" Visible="false">
                            ⬇️ 下载资源
                        </asp:HyperLink>
                        
                        <asp:Button ID="BtnLike" runat="server" Text="👍 点赞" 
                            OnClick="BtnLike_Click" CssClass="btn btn-like" />
                        
                        <span class="stat-badge">
                            <span id="spanLikeCount" runat="server">0</span> 赞
                        </span>
                        
                        <asp:Button ID="BtnFavorite" runat="server" Text="⭐ 收藏" 
                            OnClick="BtnFavorite_Click" CssClass="btn btn-favorite" />
                        
                        <span class="stat-badge">
                            <span id="spanFavCount" runat="server">0</span> 收藏
                        </span>
                    </div>
                    
                    <!-- 操作消息 -->
                    <div id="divActionMsg" runat="server" visible="false">
                        <div class="action-msg">
                            <span id="spanActionMsg" runat="server"></span>
                        </div>
                    </div>
                </div>
                
                <!-- 侧边栏 -->
                <div class="resource-sidebar">
                    <!-- 相关资源 -->
                    <div class="sidebar-card">
                        <h3 class="sidebar-title">相关资源</h3>
                        <div class="related-list">
                            <asp:Repeater ID="RptRelated" runat="server">
                                <ItemTemplate>
                                    <div class="related-item">
                                        <a href='downfile.aspx?fid=<%# Eval("FileId") %>'>
                                            <%# Eval("FileName") %>
                                        </a>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                    
                    <!-- 快捷链接 -->
                    <div class="sidebar-card">
                        <h3 class="sidebar-title">快捷操作</h3>
                        <div style="display: flex; flex-direction: column; gap: 12px;">
                            <a href="myfile.aspx" class="btn btn-download" style="width: 100%;">
                                📂 浏览所有资源
                            </a>
                            <a href="program.aspx" class="btn btn-like" style="width: 100%;">
                                🏠 返回首页
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 隐藏字段 -->
<asp:Label ID="LabelFid" runat="server" Visible="false"></asp:Label>

<script type="text/javascript">
    // 显示操作消息
    (function() {
        var msgDiv = document.getElementById('divActionMsg');
        if (msgDiv && msgDiv.style.display !== 'none') {
            // 3秒后自动隐藏
            setTimeout(function() {
                msgDiv.style.opacity = '0';
                msgDiv.style.transition = 'opacity 0.5s ease';
                setTimeout(function() {
                    msgDiv.style.display = 'none';
                }, 500);
            }, 3000);
        }
    })();
</script>

</asp:Content>
