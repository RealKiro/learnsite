<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    private string GetConnStr()
    {
        string cs = null;
        // Use DbHelperSQL.connectionString from DLL (same as compiled pages)
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                {
                    cs = connField.GetValue(null) as string;
                }
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        // Add connection timeout to avoid long hangs when DB is unreachable (default 15s -> 5s)
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
        {
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        }
        return cs;
    }

    // ViewState-backed property so DB status persists across postbacks
    private bool dbAvailable
    {
        get { object o = ViewState["dbAvail"]; return o == null ? true : (bool)o; }
        set { ViewState["dbAvail"] = value; }
    }

    private string MaskConnStr(string cs)
    {
        if (string.IsNullOrEmpty(cs)) return "(empty)";
        return Server.HtmlEncode(Regex.Replace(cs, @"(pwd|password)\s*=\s*[^;]+", "$1=******", RegexOptions.IgnoreCase));
    }

    /// <summary>
    /// 确保 DbUpgradeLog 表存在
    /// </summary>
    private void EnsureLogTable()
    {
        string sql = @"
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DbUpgradeLog') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[DbUpgradeLog](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [ScriptName] [nvarchar](200) NOT NULL,
        [ExecutedAt] [datetime] NOT NULL DEFAULT(GETDATE()),
        [Success] [bit] NOT NULL,
        [Message] [nvarchar](max) NULL,
        [BatchCount] [int] NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC))
END";
        using (SqlConnection conn = new SqlConnection(GetConnStr()))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }
    }

    /// <summary>
    /// 记录执行日志
    /// </summary>
    private void WriteLog(string scriptName, bool success, string message, int batchCount)
    {
        string sql = "INSERT INTO DbUpgradeLog(ScriptName, ExecutedAt, Success, Message, BatchCount) VALUES(@name, GETDATE(), @ok, @msg, @cnt)";
        using (SqlConnection conn = new SqlConnection(GetConnStr()))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@name", scriptName);
                cmd.Parameters.AddWithValue("@ok", success);
                cmd.Parameters.AddWithValue("@msg", message ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@cnt", batchCount);
                cmd.ExecuteNonQuery();
            }
        }
    }

    /// <summary>
    /// 获取SQL脚本列表
    /// </summary>
    private DataTable GetScriptList()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("FileName", typeof(string));
        dt.Columns.Add("FileSize", typeof(string));
        dt.Columns.Add("ModifyTime", typeof(string));

        string sqlDir = Server.MapPath("~/sql/");
        if (Directory.Exists(sqlDir))
        {
            DirectoryInfo di = new DirectoryInfo(sqlDir);
            FileInfo[] files = di.GetFiles("*.sql");
            Array.Sort(files, delegate(FileInfo a, FileInfo b) { return b.LastWriteTime.CompareTo(a.LastWriteTime); });
            foreach (FileInfo fi in files)
            {
                DataRow row = dt.NewRow();
                row["FileName"] = fi.Name;
                row["FileSize"] = FormatSize(fi.Length);
                row["ModifyTime"] = fi.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss");
                dt.Rows.Add(row);
            }
        }
        return dt;
    }

    private string FormatSize(long bytes)
    {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1048576) return (bytes / 1024.0).ToString("F1") + " KB";
        return (bytes / 1048576.0).ToString("F2") + " MB";
    }

    /// <summary>
    /// 获取执行历史
    /// </summary>
    private DataTable GetUpgradeLog()
    {
        DataTable dt = new DataTable();
        try
        {
            string sql = "SELECT TOP 50 Id, ScriptName, ExecutedAt, Success, Message, BatchCount FROM DbUpgradeLog ORDER BY Id DESC";
            using (SqlConnection conn = new SqlConnection(GetConnStr()))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                {
                    da.Fill(dt);
                }
            }
        }
        catch { }
        return dt;
    }

    /// <summary>
    /// 判断是否为「对象已存在」类幂等性错误，遇到此类错误时应跳过而非报失败
    /// SQL Server 错误编号：
    ///   2714 = 对象名已存在
    ///   1913 = 索引已存在
    ///   2705 = 列名重复
    /// </summary>
    private bool IsAlreadyExistsError(Exception ex)
    {
        SqlException sqlEx = ex as SqlException;
        if (sqlEx == null) return false;
        foreach (SqlError err in sqlEx.Errors)
        {
            if (err.Number == 2714 || err.Number == 1913 || err.Number == 2705)
                return true;
        }
        return false;
    }

    /// <summary>
    /// 按 GO 分割SQL脚本
    /// </summary>
    private string[] SplitByGo(string script)
    {
        // 按独立行的 GO 分割
        string[] batches = Regex.Split(script, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase);
        System.Collections.Generic.List<string> result = new System.Collections.Generic.List<string>();
        foreach (string batch in batches)
        {
            string trimmed = batch.Trim();
            if (!string.IsNullOrEmpty(trimmed))
            {
                result.Add(trimmed);
            }
        }
        return result.ToArray();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Test DB connectivity first
            try
            {
                EnsureLogTable();
                dbAvailable = true;
            }
            catch
            {
                dbAvailable = false;
            }
            BindScriptList();
            if (dbAvailable)
            {
                BindLogList();
            }
        }
    }

    private void BindScriptList()
    {
        RptScripts.DataSource = GetScriptList();
        RptScripts.DataBind();
    }

    private void BindLogList()
    {
        RptLog.DataSource = GetUpgradeLog();
        RptLog.DataBind();
    }

    /// <summary>
    /// 预览SQL脚本
    /// </summary>
    protected void BtnPreview_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        string fileName = btn.CommandArgument;
        string filePath = Server.MapPath("~/sql/" + fileName);
        if (File.Exists(filePath))
        {
            string content = File.ReadAllText(filePath, System.Text.Encoding.UTF8);
            // 若 UTF-8 读出为空或乱码，尝试 Unicode
            if (content == null || content.Trim().Length == 0)
            {
                content = File.ReadAllText(filePath, System.Text.Encoding.Unicode);
            }
            LabelPreviewTitle.Text = fileName;
            LiteralPreview.Text = Server.HtmlEncode(content);
            PanelPreview.Visible = true;
        }
    }

    /// <summary>
    /// 关闭预览
    /// </summary>
    protected void BtnClosePreview_Click(object sender, EventArgs e)
    {
        PanelPreview.Visible = false;
    }

    /// <summary>
    /// Test database connection
    /// </summary>
    protected void BtnTestConn_Click(object sender, EventArgs e)
    {
        string connStr = GetConnStr();
        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string ver = "";
                using (SqlCommand cmd = new SqlCommand("SELECT @@VERSION", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        ver = result.ToString();
                        if (ver.Length > 120) ver = ver.Substring(0, 120) + "...";
                    }
                }
                dbAvailable = true;
                try { EnsureLogTable(); } catch { }
                try { BindLogList(); } catch { }
                LabelMsg.Text = "✓ 数据库连接成功！<br/>服务器版本：" + Server.HtmlEncode(ver);
                LabelMsg.ForeColor = System.Drawing.Color.FromArgb(0x05, 0x96, 0x69);
            }
        }
        catch (Exception ex)
        {
            dbAvailable = false;
            LabelMsg.Text = "无法连接数据库<br/>连接串：" + MaskConnStr(connStr) + "<br/>错误：" + Server.HtmlEncode(ex.Message);
            LabelMsg.ForeColor = System.Drawing.Color.Red;
        }
    }

    /// <summary>
    /// 执行SQL脚本
    /// </summary>
    protected void BtnExecute_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        string fileName = btn.CommandArgument;
        string filePath = Server.MapPath("~/sql/" + fileName);

        if (!File.Exists(filePath))
        {
            LabelMsg.Text = "脚本文件不存在：" + fileName;
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            return;
        }

        // 读取文件内容，先尝试 UTF-8 再尝试 Unicode
        string content = File.ReadAllText(filePath, System.Text.Encoding.UTF8);
        if (content == null || content.Trim().Length == 0)
        {
            content = File.ReadAllText(filePath, System.Text.Encoding.Unicode);
        }

        string[] batches = SplitByGo(content);
        int successCount = 0;
        int errorCount = 0;
        int skipCount = 0;
        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        try
        {
            using (SqlConnection conn = new SqlConnection(GetConnStr()))
            {
                conn.Open();
                foreach (string batch in batches)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(batch, conn))
                        {
                            cmd.CommandTimeout = 300;
                            cmd.ExecuteNonQuery();
                        }
                        successCount++;
                    }
                    catch (Exception ex)
                    {
                        if (IsAlreadyExistsError(ex))
                        {
                            skipCount++;
                            sb.AppendLine("批次 " + (successCount + skipCount + errorCount) + " 已存在（跳过）：" + ex.Message);
                        }
                        else
                        {
                            errorCount++;
                            sb.AppendLine("批次 " + (successCount + skipCount + errorCount) + " 执行出错：" + ex.Message);
                        }
                    }
                }
            }
        }
        catch (Exception connEx)
        {
            dbAvailable = false;
            LabelMsg.Text = "无法连接数据库<br/>连接串：" + MaskConnStr(GetConnStr()) + "<br/>错误信息：" + Server.HtmlEncode(connEx.Message);
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            return;
        }

        dbAvailable = true;
        bool allSuccess = (errorCount == 0);
        string msg;
        if (allSuccess && skipCount == 0)
        {
            msg = "✓ 脚本 [" + fileName + "] 执行成功！共 " + batches.Length + " 个批次全部完成。";
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(0x05, 0x96, 0x69);
        }
        else if (allSuccess)
        {
            msg = "✓ 脚本 [" + fileName + "] 执行成功！" + successCount + " 个批次完成，" + skipCount + " 个批次对象已存在（已跳过）。\n" + sb.ToString();
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(0x05, 0x96, 0x69);
        }
        else
        {
            msg = "脚本 [" + fileName + "] 执行完毕。成功 " + successCount + " 个批次"
                + (skipCount > 0 ? "，跳过 " + skipCount + " 个批次" : "")
                + "，失败 " + errorCount + " 个批次。\n" + sb.ToString();
            LabelMsg.ForeColor = System.Drawing.Color.Red;
        }
        LabelMsg.Text = msg.Replace("\n", "<br/>");

        try
        {
            WriteLog(fileName, allSuccess, allSuccess ? (skipCount > 0 ? "成功（含 " + skipCount + " 个已存在跳过）" : "全部成功") : sb.ToString(), batches.Length);
        }
        catch { }

        try { BindLogList(); } catch { }
    }

    /// <summary>
    /// 执行自定义SQL
    /// </summary>
    protected void BtnRunCustom_Click(object sender, EventArgs e)
    {
        string customSql = TxtCustomSql.Text.Trim();
        if (string.IsNullOrEmpty(customSql))
        {
            LabelMsg.Text = "请输入要执行的SQL语句。";
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            return;
        }

        string[] batches = SplitByGo(customSql);
        int successCount = 0;
        int errorCount = 0;
        int skipCount = 0;
        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        try
        {
            using (SqlConnection conn = new SqlConnection(GetConnStr()))
            {
                conn.Open();
                foreach (string batch in batches)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(batch, conn))
                        {
                            cmd.CommandTimeout = 300;
                            cmd.ExecuteNonQuery();
                        }
                        successCount++;
                    }
                    catch (Exception ex)
                    {
                        if (IsAlreadyExistsError(ex))
                        {
                            skipCount++;
                            sb.AppendLine("批次 " + (successCount + skipCount + errorCount) + " 已存在（跳过）：" + ex.Message);
                        }
                        else
                        {
                            errorCount++;
                            sb.AppendLine("批次 " + (successCount + skipCount + errorCount) + " 出错：" + ex.Message);
                        }
                    }
                }
            }
        }
        catch (Exception connEx)
        {
            dbAvailable = false;
            LabelMsg.Text = "无法连接数据库<br/>连接串：" + MaskConnStr(GetConnStr()) + "<br/>错误信息：" + Server.HtmlEncode(connEx.Message);
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            return;
        }

        dbAvailable = true;
        bool allSuccess = (errorCount == 0);
        string msg;
        if (allSuccess && skipCount == 0)
        {
            msg = "✓ 自定义SQL执行成功！共 " + batches.Length + " 个批次全部完成。";
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(0x05, 0x96, 0x69);
        }
        else if (allSuccess)
        {
            msg = "✓ 自定义SQL执行成功！" + successCount + " 个批次完成，" + skipCount + " 个批次对象已存在（已跳过）。\n" + sb.ToString();
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(0x05, 0x96, 0x69);
        }
        else
        {
            msg = "自定义SQL执行完毕。成功 " + successCount + " 个批次"
                + (skipCount > 0 ? "，跳过 " + skipCount + " 个批次" : "")
                + "，失败 " + errorCount + " 个批次。\n" + sb.ToString();
            LabelMsg.ForeColor = System.Drawing.Color.Red;
        }
        LabelMsg.Text = msg.Replace("\n", "<br/>");

        try
        {
            string brief = customSql.Length > 100 ? customSql.Substring(0, 100) + "..." : customSql;
            WriteLog("[自定义SQL]", allSuccess, (allSuccess ? "全部成功：" : "") + brief, batches.Length);
        }
        catch { }

        try { BindLogList(); } catch { }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .du-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .du-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .du-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#0ea5e9,#38bdf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(14,165,233,.25);flex-shrink:0;}
    .du-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .du-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .du-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    .du-grid{display:flex;flex-direction:column;gap:24px;}
    .du-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s,transform .25s;}
    .du-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);transform:translateY(-2px);}
    .du-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .du-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .du-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .ci.purple{background:#eef2ff;} .ci.purple svg{stroke:#6366f1;}
    .ci.rose{background:#fff1f2;} .ci.rose svg{stroke:#f43f5e;}
    .du-card-bd{padding:22px;}

    /* 消息区域 */
    .du-msg-box{padding:14px 18px;border-radius:10px;font-size:13px;line-height:1.7;margin-bottom:20px;background:#f8fafc;border:1px solid #e2e8f0;min-height:20px;}

    /* 脚本列表表格 */
    .du-table{width:100%;border-collapse:collapse;font-size:13px;}
    .du-table th{background:#f8fafc;padding:10px 14px;text-align:left;font-weight:600;color:#475569;border-bottom:2px solid #e2e8f0;font-size:12px;text-transform:uppercase;letter-spacing:.5px;}
    .du-table td{padding:10px 14px;border-bottom:1px solid #f1f5f9;color:#334155;vertical-align:middle;}
    .du-table tr:hover td{background:#fafbfc;}
    .du-table .fname{font-weight:600;color:#1e293b;}
    .du-table .fmeta{color:#94a3b8;font-size:12px;}

    /* 按钮 */
    .btn-sm{display:inline-flex;align-items:center;justify-content:center;height:32px;padding:0 16px;border:none;border-radius:7px;font-size:12px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;gap:4px;}
    .btn-view{background:#f0f9ff;color:#0284c7;} .btn-view:hover{background:#e0f2fe;}
    .btn-run{background:#ecfdf5;color:#059669;} .btn-run:hover{background:#d1fae5;}
    .btn-run-warn{background:#fef3c7;color:#d97706;} .btn-run-warn:hover{background:#fde68a;}
    .btn-close{background:#f1f5f9;color:#64748b;height:36px;padding:0 24px;font-size:13px;border-radius:9px;} .btn-close:hover{background:#e2e8f0;color:#334155;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 28px;background:linear-gradient(135deg,#0ea5e9,#0284c7);color:#fff !important;border:none;border-radius:9px;font-size:14px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;box-shadow:0 2px 8px rgba(14,165,233,.3);}
    .btn-primary:hover{box-shadow:0 4px 16px rgba(14,165,233,.4);transform:translateY(-1px);}

    /* 预览面板 */
    .du-preview{margin-top:16px;background:#0f172a;border-radius:12px;overflow:hidden;}
    .du-preview-hd{display:flex;align-items:center;justify-content:space-between;padding:12px 18px;background:#1e293b;border-bottom:1px solid #334155;}
    .du-preview-hd span{color:#94a3b8;font-size:13px;font-weight:600;}
    .du-preview-bd{padding:18px;max-height:400px;overflow:auto;}
    .du-preview-bd pre{margin:0;font-size:12.5px;line-height:1.7;color:#e2e8f0;font-family:'Cascadia Code','Fira Code',Consolas,'Courier New',monospace;white-space:pre-wrap;word-break:break-all;}
    .du-preview-bd::-webkit-scrollbar{width:6px;} .du-preview-bd::-webkit-scrollbar-thumb{background:#475569;border-radius:3px;}

    /* 自定义SQL区 */
    .du-custom-sql{width:100%;min-height:120px;padding:14px;border:1.5px solid #e2e8f0;border-radius:10px;font-size:13px;font-family:'Cascadia Code','Fira Code',Consolas,'Courier New',monospace;line-height:1.7;background:#f8fafc;resize:vertical;outline:none;transition:border-color .2s,box-shadow .2s;}
    .du-custom-sql:focus{border-color:#0ea5e9;box-shadow:0 0 0 3px rgba(14,165,233,.08);background:#fff;}

    /* 日志列表 */
    .du-log-table{width:100%;border-collapse:collapse;font-size:13px;}
    .du-log-table th{background:#f8fafc;padding:10px 14px;text-align:left;font-weight:600;color:#475569;border-bottom:2px solid #e2e8f0;font-size:12px;}
    .du-log-table td{padding:10px 14px;border-bottom:1px solid #f1f5f9;color:#334155;vertical-align:top;}
    .du-log-table tr:hover td{background:#fafbfc;}
    .log-ok{display:inline-flex;align-items:center;gap:4px;padding:2px 10px;border-radius:6px;font-size:11px;font-weight:600;background:#ecfdf5;color:#059669;}
    .log-fail{display:inline-flex;align-items:center;gap:4px;padding:2px 10px;border-radius:6px;font-size:11px;font-weight:600;background:#fef2f2;color:#dc2626;}
    .log-msg{max-width:400px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px;color:#94a3b8;}

    /* 注意事项 */
    .du-notice{list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:14px;}
    .du-notice li{display:flex;align-items:flex-start;gap:10px;font-size:13px;color:#334155;line-height:1.7;}
    .du-notice li .ni{width:24px;height:24px;border-radius:7px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:11px;font-weight:700;}
    .ni.warn{background:#fef3c7;color:#b45309;}
    .ni.info{background:#e0f2fe;color:#0369a1;}
    .ni.err{background:#fee2e2;color:#dc2626;}

    .du-empty{text-align:center;padding:24px;color:#94a3b8;font-size:13px;}
    .db-warn{background:#fef3c7;border:1px solid #fbbf24;border-radius:10px;padding:12px 18px;margin-bottom:18px;display:flex;align-items:center;gap:10px;font-size:13px;color:#92400e;}
    .db-warn svg{width:20px;height:20px;stroke:#f59e0b;fill:none;stroke-width:2;flex-shrink:0;}
</style>

<div class="du-page">
    <div class="du-hd">
        <div class="du-hd-icon"><svg viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/><path d="M21 5v7"/><path d="M3 5v7"/><line x1="12" y1="15" x2="12" y2="19"/><polyline points="9 17 12 14 15 17"/></svg></div>
        <div class="du-hd-text"><h1>数据库升级</h1><p>在线执行SQL脚本升级数据库，支持脚本预览、执行和日志记录</p></div>
    </div>

    <% if (!dbAvailable) { %>
    <div class="db-warn">
        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        &#x6570;&#x636E;&#x5E93;&#x8FDE;&#x63A5;&#x4E0D;&#x53EF;&#x7528;&#xFF0C;&#x811A;&#x672C;&#x5217;&#x8868;&#x53EF;&#x6B63;&#x5E38;&#x67E5;&#x770B;&#xFF0C;&#x4F46;&#x6267;&#x884C;&#x64CD;&#x4F5C;&#x548C;&#x65E5;&#x5FD7;&#x8BB0;&#x5F55;&#x9700;&#x8981;&#x6570;&#x636E;&#x5E93;&#x8FDE;&#x63A5;&#x6B63;&#x5E38;&#x540E;&#x624D;&#x80FD;&#x4F7F;&#x7528;&#x3002;
    </div>
    <% } %>

    <!-- 消息提示 -->
    <div class="du-msg-box">
        <asp:Label ID="LabelMsg" runat="server" Text="就绪。请选择SQL脚本进行操作。" ForeColor="#64748b"></asp:Label>
    </div>

    <div class="du-grid">

    <!-- SQL脚本列表 -->
    <div class="du-card">
        <div class="du-card-hd">
            <span class="ci sky"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
            SQL 升级脚本
        </div>
        <div class="du-card-bd">
            <table class="du-table">
                <thead>
                    <tr><th>文件名</th><th>大小</th><th>修改时间</th><th style="text-align:center;">操作</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="RptScripts" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="fname"><%# Eval("FileName") %></td>
                                <td class="fmeta"><%# Eval("FileSize") %></td>
                                <td class="fmeta"><%# Eval("ModifyTime") %></td>
                                <td style="text-align:center;">
                                    <asp:Button ID="BtnPreview" runat="server" Text="预览" CssClass="btn-sm btn-view"
                                        CommandArgument='<%# Eval("FileName") %>' OnClick="BtnPreview_Click" />
                                    <asp:Button ID="BtnExecute" runat="server" Text="执行" CssClass="btn-sm btn-run"
                                        CommandArgument='<%# Eval("FileName") %>'
                                        OnClick="BtnExecute_Click"
                                        OnClientClick="return confirm('确定要执行此SQL脚本吗？\n\n请确保已提前备份数据库！');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <!-- SQL预览面板 -->
    <asp:Panel ID="PanelPreview" runat="server" Visible="false">
    <div class="du-card">
        <div class="du-card-hd">
            <span class="ci purple"><svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></span>
            脚本预览：<asp:Label ID="LabelPreviewTitle" runat="server" ForeColor="#6366f1"></asp:Label>
        </div>
        <div class="du-card-bd" style="padding:0;">
            <div class="du-preview">
                <div class="du-preview-hd">
                    <span>SQL 内容</span>
                    <asp:Button ID="BtnClosePreview" runat="server" Text="关闭预览" CssClass="btn-sm btn-close" OnClick="BtnClosePreview_Click" />
                </div>
                <div class="du-preview-bd">
                    <pre><asp:Literal ID="LiteralPreview" runat="server"></asp:Literal></pre>
                </div>
            </div>
        </div>
    </div>
    </asp:Panel>

    <!-- 自定义SQL执行 -->
    <div class="du-card">
        <div class="du-card-hd">
            <span class="ci emerald"><svg viewBox="0 0 24 24"><polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/></svg></span>
            自定义 SQL 执行
        </div>
        <div class="du-card-bd">
            <asp:TextBox ID="TxtCustomSql" runat="server" TextMode="MultiLine" CssClass="du-custom-sql"
                placeholder="在此输入SQL语句...&#10;支持 GO 分隔的多批次语句&#10;例如：ALTER TABLE [dbo].[Students] ADD [NewCol] nvarchar(50) NULL"></asp:TextBox>
            <div style="margin-top:14px;">
                <asp:Button ID="BtnRunCustom" runat="server" Text="执行自定义SQL" CssClass="btn-primary" OnClick="BtnRunCustom_Click"
                    OnClientClick="return confirm('确定要执行自定义SQL吗？\n\n请确保SQL语句正确且已备份数据库！');" />
            </div>
        </div>
    </div>

    <!-- 执行历史 -->
    <div class="du-card">
        <div class="du-card-hd">
            <span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></span>
            执行历史记录
        </div>
        <div class="du-card-bd">
            <table class="du-log-table">
                <thead>
                    <tr><th>#</th><th>脚本名称</th><th>执行时间</th><th>状态</th><th>批次</th><th>消息</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="RptLog" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("Id") %></td>
                                <td class="fname"><%# Eval("ScriptName") %></td>
                                <td class="fmeta"><%# ((DateTime)Eval("ExecutedAt")).ToString("yyyy-MM-dd HH:mm:ss") %></td>
                                <td>
                                    <%# (bool)Eval("Success") ? "<span class='log-ok'>✓ 成功</span>" : "<span class='log-fail'>✗ 失败</span>" %>
                                </td>
                                <td style="text-align:center;"><%# Eval("BatchCount") %></td>
                                <td><div class="log-msg" title='<%# Server.HtmlEncode(Eval("Message") == DBNull.Value ? "" : Eval("Message").ToString()) %>'><%# Server.HtmlEncode(Eval("Message") == DBNull.Value ? "" : Eval("Message").ToString()) %></div></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 注意事项 -->
    <div class="du-card">
        <div class="du-card-hd">
            <span class="ci rose"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
            注意事项
        </div>
        <div class="du-card-bd">
            <ul class="du-notice">
                <li><span class="ni err">！</span><strong>备份优先：</strong>执行任何升级脚本前，请先到「数据备份」菜单备份当前数据库</li>
                <li><span class="ni warn">⚠</span><strong>脚本来源：</strong>仅执行可信来源的SQL脚本，升级脚本通常使用 IF NOT EXISTS 模式，可安全重复执行</li>
                <li><span class="ni info">ℹ</span><strong>脚本位置：</strong>升级脚本存放在网站 sql 目录下，新增脚本请通过FTP上传到该目录</li>
                <li><span class="ni info">ℹ</span><strong>执行方式：</strong>脚本按 GO 语句自动分批执行，每个批次独立运行，个别批次失败不影响其他批次</li>
            </ul>
        </div>
    </div>

    </div>
</div>
</asp:Content>
