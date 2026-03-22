<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    protected string currentVersion = "";
    protected string serverUrl = "http://ls.lequw.net/manager/updates/learnsite";
    protected string serverPath = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCurrentVersion();
            LoadSettings();
        }
    }
    
    private void LoadCurrentVersion()
    {
        try
        {
            string xmlPath = Server.MapPath("~/changelog.xml");
            if (File.Exists(xmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(xmlPath);
                XmlNode firstVersion = doc.SelectSingleNode("//changelog/version");
                if (firstVersion != null && firstVersion.Attributes["ver"] != null)
                {
                    currentVersion = firstVersion.Attributes["ver"].Value;
                }
            }
        }
        catch { }
        
        if (string.IsNullOrEmpty(currentVersion))
        {
            currentVersion = "v1.0.0";
        }
    }
    
    private void LoadSettings()
    {
        try
        {
            string settingsPath = Server.MapPath("~/App_Data/update_settings.xml");
            if (File.Exists(settingsPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(settingsPath);
                
                XmlNode urlNode = doc.SelectSingleNode("//settings/serverUrl");
                if (urlNode != null && !string.IsNullOrEmpty(urlNode.InnerText))
                {
                    serverUrl = urlNode.InnerText;
                }
                
                XmlNode pathNode = doc.SelectSingleNode("//settings/serverPath");
                if (pathNode != null && !string.IsNullOrEmpty(pathNode.InnerText))
                {
                    serverPath = pathNode.InnerText;
                }
            }
        }
        catch { }
    }
    
    private void SaveSettings()
    {
        try
        {
            string settingsPath = Server.MapPath("~/App_Data/update_settings.xml");
            string appDataPath = Server.MapPath("~/App_Data");
            
            if (!Directory.Exists(appDataPath))
            {
                Directory.CreateDirectory(appDataPath);
            }
            
            XmlDocument doc = new XmlDocument();
            XmlDeclaration declaration = doc.CreateXmlDeclaration("1.0", "utf-8", null);
            doc.AppendChild(declaration);
            
            XmlElement root = doc.CreateElement("settings");
            doc.AppendChild(root);
            
            XmlElement urlElement = doc.CreateElement("serverUrl");
            urlElement.InnerText = txtServerUrl.Text.Trim();
            root.AppendChild(urlElement);
            
            XmlElement pathElement = doc.CreateElement("serverPath");
            pathElement.InnerText = txtServerPath.Text.Trim();
            root.AppendChild(pathElement);
            
            doc.Save(settingsPath);
        }
        catch { }
    }
    
    protected void BtnBuild_Click(object sender, EventArgs e)
    {
        try
        {
            lblStatus.Text = "正在打包更新文件...";
            lblStatus.ForeColor = System.Drawing.Color.FromArgb(59, 130, 246);
            
            // 保存设置
            SaveSettings();
            
            // 优先使用简化版脚本（避免编码问题）
            string scriptPath = Server.MapPath("~/build_update_simple.ps1");
            if (!File.Exists(scriptPath))
            {
                scriptPath = Server.MapPath("~/build_update_v2.ps1");
            }
            if (!File.Exists(scriptPath))
            {
                scriptPath = Server.MapPath("~/build_update.ps1");
            }
            
            if (!File.Exists(scriptPath))
            {
                lblStatus.Text = "错误：找不到打包脚本文件";
                lblStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            string output = ExecutePowerShell(scriptPath, "");
            
            // 检查是否成功
            if (output.Contains("Package Complete") || output.Contains("打包完成") || output.Contains("成功"))
            {
                StringBuilder result = new StringBuilder();
                result.AppendLine(output);
                result.AppendLine();
                result.AppendLine("===============================================================");
                
                lblStatus.Text = "打包成功！";
                lblStatus.ForeColor = System.Drawing.Color.Green;
                
                // 显示下载按钮
                string zipFile = Server.MapPath("~/" + currentVersion + ".zip");
                if (File.Exists(zipFile))
                {
                    btnDownload.Visible = true;
                    btnDeploy.Visible = true;
                    
                    // 如果配置了服务器路径，自动复制到服务器
                    string serverPathValue = txtServerPath.Text.Trim();
                    if (!string.IsNullOrEmpty(serverPathValue))
                    {
                        result.AppendLine("正在复制文件到服务器路径...");
                        result.AppendLine("目标路径: " + serverPathValue);
                        result.AppendLine();
                        
                        try
                        {
                            // 创建服务器目录（如果不存在）
                            if (!Directory.Exists(serverPathValue))
                            {
                                result.AppendLine("创建目录: " + serverPathValue);
                                Directory.CreateDirectory(serverPathValue);
                            }
                            
                            // 复制 ZIP 文件
                            string destZip = Path.Combine(serverPathValue, currentVersion + ".zip");
                            result.AppendLine("复制文件: " + currentVersion + ".zip");
                            File.Copy(zipFile, destZip, true);
                            
                            FileInfo fi = new FileInfo(destZip);
                            double sizeKB = fi.Length / 1024.0;
                            result.AppendLine("OK 文件已复制 (" + sizeKB.ToString("F2") + " KB)");
                            
                            // 复制 version.json
                            string versionJsonNew = Server.MapPath("~/version.json.new");
                            if (File.Exists(versionJsonNew))
                            {
                                string destJson = Path.Combine(serverPathValue, "version.json");
                                result.AppendLine("复制文件: version.json");
                                File.Copy(versionJsonNew, destJson, true);
                                result.AppendLine("OK version.json 已更新");
                            }
                            
                            result.AppendLine();
                            result.AppendLine("===============================================================");
                            result.AppendLine("文件已自动复制到服务器路径！");
                            result.AppendLine("===============================================================");
                            result.AppendLine();
                            result.AppendLine("部署位置: " + serverPathValue);
                            result.AppendLine("  - " + currentVersion + ".zip");
                            result.AppendLine("  - version.json");
                            result.AppendLine();
                            
                            lblStatus.Text = "打包成功并已复制到服务器！";
                            lblStatus.ForeColor = System.Drawing.Color.Green;
                        }
                        catch (Exception ex)
                        {
                            result.AppendLine();
                            result.AppendLine("警告：复制到服务器失败");
                            result.AppendLine("错误: " + ex.Message);
                            result.AppendLine();
                            result.AppendLine("您可以：");
                            result.AppendLine("  1. 检查服务器路径是否正确");
                            result.AppendLine("  2. 检查是否有写入权限");
                            result.AppendLine("  3. 点击'部署到服务器'按钮重试");
                            result.AppendLine("  4. 或点击'下载更新包'手动上传");
                            result.AppendLine();
                            
                            lblStatus.Text = "打包成功，但复制到服务器失败";
                            lblStatus.ForeColor = System.Drawing.Color.Orange;
                        }
                    }
                    else
                    {
                        result.AppendLine("提示：未配置服务器路径");
                        result.AppendLine("如需自动部署，请填写'服务器文件路径'");
                        result.AppendLine();
                    }
                }
                
                txtOutput.Text = result.ToString();
            }
            else
            {
                lblStatus.Text = "打包失败，请查看输出信息";
                lblStatus.ForeColor = System.Drawing.Color.Red;
                txtOutput.Text = output;
            }
        }
        catch (Exception ex)
        {
            lblStatus.Text = "打包失败：" + ex.Message;
            lblStatus.ForeColor = System.Drawing.Color.Red;
            txtOutput.Text = ex.ToString();
        }
    }
    
    protected void BtnDeploy_Click(object sender, EventArgs e)
    {
        try
        {
            lblStatus.Text = "正在部署到服务器...";
            lblStatus.ForeColor = System.Drawing.Color.FromArgb(59, 130, 246);
            
            // 保存设置
            SaveSettings();
            
            string serverPathValue = txtServerPath.Text.Trim();
            
            if (string.IsNullOrEmpty(serverPathValue))
            {
                lblStatus.Text = "错误：请输入服务器路径";
                lblStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }
            
            // 尝试直接上传（不使用 PowerShell）
            bool useDirectUpload = true;
            
            if (useDirectUpload)
            {
                StringBuilder output = new StringBuilder();
                output.AppendLine("===============================================================");
                output.AppendLine("LearnSite Deploy to Server");
                output.AppendLine("===============================================================");
                output.AppendLine("Version: " + currentVersion);
                output.AppendLine("Server Path: " + serverPathValue);
                output.AppendLine("Time: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                output.AppendLine("===============================================================");
                output.AppendLine();
                
                string zipFile = Server.MapPath("~/" + currentVersion + ".zip");
                string versionJsonNew = Server.MapPath("~/version.json.new");
                
                // 检查文件是否存在
                if (!File.Exists(zipFile))
                {
                    lblStatus.Text = "错误：找不到更新包文件，请先打包";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    output.AppendLine("ERROR: ZIP file not found: " + zipFile);
                    txtOutput.Text = output.ToString();
                    return;
                }
                
                if (!File.Exists(versionJsonNew))
                {
                    lblStatus.Text = "错误：找不到 version.json.new，请先打包";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    output.AppendLine("ERROR: version.json.new not found");
                    txtOutput.Text = output.ToString();
                    return;
                }
                
                // 创建服务器目录（如果不存在）
                if (!Directory.Exists(serverPathValue))
                {
                    output.AppendLine("Creating server directory...");
                    try
                    {
                        Directory.CreateDirectory(serverPathValue);
                        output.AppendLine("OK Directory created");
                    }
                    catch (Exception ex)
                    {
                        lblStatus.Text = "错误：无法创建服务器目录";
                        lblStatus.ForeColor = System.Drawing.Color.Red;
                        output.AppendLine("ERROR: Failed to create directory");
                        output.AppendLine(ex.Message);
                        txtOutput.Text = output.ToString();
                        return;
                    }
                }
                
                // 上传 ZIP 文件
                output.AppendLine();
                output.AppendLine("Uploading files...");
                try
                {
                    string destZip = Path.Combine(serverPathValue, currentVersion + ".zip");
                    output.AppendLine("Uploading " + currentVersion + ".zip...");
                    File.Copy(zipFile, destZip, true);
                    output.AppendLine("OK ZIP file uploaded");
                }
                catch (Exception ex)
                {
                    lblStatus.Text = "错误：上传 ZIP 文件失败";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    output.AppendLine("ERROR: Failed to upload ZIP file");
                    output.AppendLine(ex.Message);
                    txtOutput.Text = output.ToString();
                    return;
                }
                
                // 上传 version.json
                try
                {
                    string destJson = Path.Combine(serverPathValue, "version.json");
                    output.AppendLine("Updating version.json...");
                    File.Copy(versionJsonNew, destJson, true);
                    output.AppendLine("OK version.json updated");
                }
                catch (Exception ex)
                {
                    lblStatus.Text = "错误：更新 version.json 失败";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    output.AppendLine("ERROR: Failed to update version.json");
                    output.AppendLine(ex.Message);
                    txtOutput.Text = output.ToString();
                    return;
                }
                
                // 验证部署
                output.AppendLine();
                output.AppendLine("Verifying deployment...");
                
                string deployedZip = Path.Combine(serverPathValue, currentVersion + ".zip");
                string deployedJson = Path.Combine(serverPathValue, "version.json");
                
                bool allOk = true;
                
                if (File.Exists(deployedZip))
                {
                    FileInfo fi = new FileInfo(deployedZip);
                    double sizeKB = fi.Length / 1024.0;
                    output.AppendLine("OK ZIP file exists (" + sizeKB.ToString("F2") + " KB)");
                }
                else
                {
                    output.AppendLine("ERROR: ZIP file not found on server");
                    allOk = false;
                }
                
                if (File.Exists(deployedJson))
                {
                    output.AppendLine("OK version.json exists");
                    
                    // 验证 JSON 格式
                    try
                    {
                        string jsonText = File.ReadAllText(deployedJson);
                        // 简单验证版本号
                        if (jsonText.Contains("\"version\": \"" + currentVersion + "\""))
                        {
                            output.AppendLine("OK Version matches: " + currentVersion);
                        }
                        else
                        {
                            output.AppendLine("ERROR: Version mismatch in version.json");
                            allOk = false;
                        }
                    }
                    catch (Exception ex)
                    {
                        output.AppendLine("ERROR: Invalid JSON format");
                        output.AppendLine(ex.Message);
                        allOk = false;
                    }
                }
                else
                {
                    output.AppendLine("ERROR: version.json not found on server");
                    allOk = false;
                }
                
                output.AppendLine();
                
                if (allOk)
                {
                    output.AppendLine("===============================================================");
                    output.AppendLine("Deploy Successful!");
                    output.AppendLine("===============================================================");
                    output.AppendLine();
                    output.AppendLine("Files deployed to: " + serverPathValue);
                    output.AppendLine("  - " + currentVersion + ".zip");
                    output.AppendLine("  - version.json");
                    output.AppendLine();
                    output.AppendLine("Next steps:");
                    output.AppendLine("  1. Test update server URL in browser");
                    output.AppendLine("  2. Configure update server in client");
                    output.AppendLine("  3. Click 'Check Update' to test");
                    output.AppendLine();
                    
                    lblStatus.Text = "部署成功！";
                    lblStatus.ForeColor = System.Drawing.Color.Green;
                }
                else
                {
                    output.AppendLine("===============================================================");
                    output.AppendLine("Deploy Failed!");
                    output.AppendLine("===============================================================");
                    output.AppendLine();
                    output.AppendLine("Please check:");
                    output.AppendLine("  1. Server path is correct");
                    output.AppendLine("  2. You have write permission");
                    output.AppendLine("  3. Files are not locked");
                    output.AppendLine();
                    
                    lblStatus.Text = "部署失败，请查看输出信息";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                }
                
                txtOutput.Text = output.ToString();
                return;
            }
            
            // 备用方案：使用 PowerShell 脚本
            string scriptPath = Server.MapPath("~/deploy_to_server_simple.ps1");
            
            if (!File.Exists(scriptPath))
            {
                // 尝试使用旧脚本
                scriptPath = Server.MapPath("~/deploy_to_server.ps1");
                if (!File.Exists(scriptPath))
                {
                    lblStatus.Text = "错误：找不到部署脚本文件";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }
            }
            
            string args = string.Format("-version \"{0}\" -serverPath \"{1}\"", 
                currentVersion, serverPathValue);
            
            string psOutput = ExecutePowerShell(scriptPath, args);
            
            // 检查是否成功
            if (psOutput.Contains("部署成功") || psOutput.Contains("Deploy Successful"))
            {
                lblStatus.Text = "部署成功！";
                lblStatus.ForeColor = System.Drawing.Color.Green;
                txtOutput.Text = psOutput;
            }
            else
            {
                lblStatus.Text = "部署失败，请查看输出信息";
                lblStatus.ForeColor = System.Drawing.Color.Red;
                txtOutput.Text = psOutput;
            }
        }
        catch (Exception ex)
        {
            lblStatus.Text = "部署失败：" + ex.Message;
            lblStatus.ForeColor = System.Drawing.Color.Red;
            txtOutput.Text = ex.ToString();
        }
    }
    
    protected void BtnDownload_Click(object sender, EventArgs e)
    {
        try
        {
            string zipFile = Server.MapPath("~/" + currentVersion + ".zip");
            
            if (File.Exists(zipFile))
            {
                Response.Clear();
                Response.ContentType = "application/zip";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + currentVersion + ".zip");
                Response.TransmitFile(zipFile);
                Response.End();
            }
            else
            {
                lblStatus.Text = "错误：找不到更新包文件";
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }
        catch (Exception ex)
        {
            lblStatus.Text = "下载失败：" + ex.Message;
            lblStatus.ForeColor = System.Drawing.Color.Red;
        }
    }
    
    private string ExecutePowerShell(string scriptPath, string arguments)
    {
        try
        {
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = string.Format("-ExecutionPolicy Bypass -File \"{0}\" {1}", 
                scriptPath, arguments);
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.WorkingDirectory = Server.MapPath("~/");
            
            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
            
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();
            
            process.WaitForExit();
            
            if (!string.IsNullOrEmpty(error))
            {
                output += "\n\n错误信息：\n" + error;
            }
            
            return output;
        }
        catch (Exception ex)
        {
            return "执行失败：" + ex.Message + "\n\n" + ex.ToString();
        }
    }

</script>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LearnSite 更新包构建器</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Microsoft YaHei', 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
            animation: fadeInDown 0.6s ease;
        }
        
        .header h1 {
            font-size: 36px;
            font-weight: 700;
            margin-bottom: 8px;
            text-shadow: 0 2px 20px rgba(0,0,0,0.2);
        }
        
        .header p {
            font-size: 16px;
            opacity: 0.95;
        }
        
        .main-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        @media (max-width: 1024px) {
            .main-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            animation: fadeInUp 0.6s ease;
        }
        
        .card-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 20px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .card-icon {
            font-size: 28px;
        }
        
        .card-title {
            font-size: 20px;
            font-weight: 600;
        }
        
        .card-body {
            padding: 24px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 8px;
        }
        
        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            font-family: 'Consolas', monospace;
            transition: all 0.3s;
        }
        
        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-hint {
            font-size: 12px;
            color: #64748b;
            margin-top: 6px;
            line-height: 1.5;
        }
        
        .info-box {
            background: #f8fafc;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 16px;
            margin-bottom: 20px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            font-size: 14px;
            color: #64748b;
        }
        
        .info-value {
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
            font-family: 'Consolas', monospace;
        }
        
        .btn-group {
            display: flex;
            gap: 12px;
            margin-top: 20px;
        }
        
        .btn {
            flex: 1;
            padding: 14px 24px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
        }
        
        .btn-info {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        }
        
        .btn-info:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
        }
        
        .status-box {
            background: #f8fafc;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 16px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 15px;
            font-weight: 500;
        }
        
        .output-box {
            background: #1e293b;
            color: #e2e8f0;
            border-radius: 10px;
            padding: 20px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 13px;
            line-height: 1.6;
            max-height: 400px;
            overflow-y: auto;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        
        .alert {
            padding: 14px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .alert-icon {
            font-size: 20px;
            flex-shrink: 0;
        }
        
        .alert-info {
            background: #eff6ff;
            border: 2px solid #bfdbfe;
            color: #1e40af;
        }
        
        .alert-warning {
            background: #fffbeb;
            border: 2px solid #fde68a;
            color: #92400e;
        }
        
        .feature-list {
            list-style: none;
            padding: 0;
        }
        
        .feature-list li {
            padding: 10px 0;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid #f1f5f9;
        }
        
        .feature-list li:last-child {
            border-bottom: none;
        }
        
        .feature-icon {
            font-size: 18px;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <form runat="server">
        <div class="container">
            <div class="header">
                <h1>🚀 LearnSite 更新包构建器</h1>
                <p>一键打包、一键部署，轻松管理系统更新</p>
            </div>
            
            <div class="main-grid">
                <!-- 左侧：配置和操作 -->
                <div>
                    <!-- 版本信息卡片 -->
                    <div class="card" style="margin-bottom: 20px;">
                        <div class="card-header">
                            <span class="card-icon">📦</span>
                            <span class="card-title">版本信息</span>
                        </div>
                        <div class="card-body">
                            <div class="info-box">
                                <div class="info-row">
                                    <span class="info-label">当前版本：</span>
                                    <span class="info-value"><%= currentVersion %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">打包时间：</span>
                                    <span class="info-value" id="buildTime">-</span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">文件大小：</span>
                                    <span class="info-value" id="fileSize">-</span>
                                </div>
                            </div>
                            
                            <div class="alert alert-info">
                                <span class="alert-icon">💡</span>
                                <div>
                                    版本号从 <strong>changelog.xml</strong> 自动读取。
                                    如需修改版本号，请先更新 changelog.xml 文件。
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 服务器配置卡片 -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-icon">⚙️</span>
                            <span class="card-title">服务器配置</span>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <label class="form-label">更新服务器 URL：</label>
                                <asp:TextBox ID="txtServerUrl" runat="server" CssClass="form-input" 
                                             placeholder="http://ls.lequw.net/manager/updates/learnsite"></asp:TextBox>
                                <div class="form-hint">
                                    客户端将从此地址检查更新和下载更新包
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">服务器文件路径：</label>
                                <asp:TextBox ID="txtServerPath" runat="server" CssClass="form-input" 
                                             placeholder="\\ls.lequw.net\updates\learnsite 或 C:\inetpub\wwwroot\..."></asp:TextBox>
                                <div class="form-hint">
                                    <strong>打包时自动复制：</strong>填写此路径后，点击"打包更新"将自动复制文件到此位置。支持 UNC 路径或本地路径。
                                </div>
                            </div>
                            
                            <div class="alert alert-warning">
                                <span class="alert-icon">⚠️</span>
                                <div>
                                    <strong>权限要求：</strong>IIS 应用程序池账户需要有执行 PowerShell 脚本和访问服务器路径的权限。
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 右侧：操作按钮和输出 -->
                <div>
                    <!-- 操作卡片 -->
                    <div class="card" style="margin-bottom: 20px;">
                        <div class="card-header">
                            <span class="card-icon">🎯</span>
                            <span class="card-title">操作面板</span>
                        </div>
                        <div class="card-body">
                            <div class="status-box">
                                <asp:Label ID="lblStatus" runat="server" Text="就绪，等待操作..."></asp:Label>
                            </div>
                            
                            <div class="btn-group">
                                <asp:Button ID="btnBuild" runat="server" Text="📦 打包更新" 
                                            CssClass="btn btn-primary" OnClick="BtnBuild_Click" />
                                <asp:Button ID="btnDeploy" runat="server" Text="🚀 部署到服务器" 
                                            CssClass="btn btn-success" OnClick="BtnDeploy_Click" />
                                <asp:Button ID="btnDownload" runat="server" Text="💾 下载更新包" 
                                            CssClass="btn btn-info" OnClick="BtnDownload_Click" />
                            </div>
                            
                            <ul class="feature-list" style="margin-top: 20px;">
                                <li>
                                    <span class="feature-icon">✅</span>
                                    <span>自动从 changelog.xml 读取版本号</span>
                                </li>
                                <li>
                                    <span class="feature-icon">✅</span>
                                    <span>支持多种压缩方法，自动选择最佳</span>
                                </li>
                                <li>
                                    <span class="feature-icon">✅</span>
                                    <span>自动计算 MD5 校验值</span>
                                </li>
                                <li>
                                    <span class="feature-icon">✅</span>
                                    <span>自动生成 version.json 配置</span>
                                </li>
                                <li>
                                    <span class="feature-icon">✅</span>
                                    <span>打包完成自动复制到服务器路径</span>
                                </li>
                                <li>
                                    <span class="feature-icon">✅</span>
                                    <span>支持手动部署和下载更新包</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                    
                    <!-- 输出日志卡片 -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-icon">📋</span>
                            <span class="card-title">执行日志</span>
                        </div>
                        <div class="card-body">
                            <asp:TextBox ID="txtOutput" runat="server" TextMode="MultiLine" 
                                         CssClass="output-box" ReadOnly="true" 
                                         placeholder="执行日志将显示在这里..."></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    
    <script>
        // 更新当前时间
        document.getElementById('buildTime').textContent = new Date().toLocaleString('zh-CN');
        
        // 页面加载时设置默认值
        window.onload = function() {
            var serverUrlInput = document.getElementById('<%= txtServerUrl.ClientID %>');
            var serverPathInput = document.getElementById('<%= txtServerPath.ClientID %>');
            
            if (serverUrlInput && !serverUrlInput.value) {
                serverUrlInput.value = '<%= serverUrl %>';
            }
            
            if (serverPathInput && !serverPathInput.value) {
                serverPathInput.value = '<%= serverPath %>';
            }
        };
    </script>
</body>
</html>
