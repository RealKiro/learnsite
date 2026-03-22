<%@ Page Title="" Language="C#" MasterPageFile="~/manager/Manage.master" %>

<script runat="server">
    protected string currentVersion = "1.0.0";
    protected string latestVersion = "";
    protected string updateLog = "";
    protected bool hasUpdate = false;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // 每次加载都读取当前版本号，确保显示最新值
        LoadCurrentVersion();
        if (!IsPostBack)
        {
            // 预填官方更新地址，方便一键检测
            txtUpdateUrl.Text = "https://gitee.com/lequw/ls";
            if (Request.QueryString["autoupdate"] == "1")
            {
                hdnDirectUrl.Value = "auto";
                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "autoupdate",
                    "window.setTimeout(function(){var b=document.getElementById('" + btnCheckUpdate.ClientID + "');if(b)b.click();},300);",
                    true
                );
            }
        }
    }
    
    private void LoadCurrentVersion()
    {
        try
        {
            // 从 changelog.xml 读取当前版本号（与 index.aspx 保持一致）
            string xmlPath = Server.MapPath("~/changelog.xml");
            if (System.IO.File.Exists(xmlPath))
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(xmlPath);
                
                // 获取第一个 version 节点（最新版本）
                System.Xml.XmlNode firstVersion = doc.SelectSingleNode("//changelog/version");
                if (firstVersion != null && firstVersion.Attributes["ver"] != null)
                {
                    string ver = firstVersion.Attributes["ver"].Value;
                    if (!string.IsNullOrEmpty(ver))
                    {
                        currentVersion = ver;
                        return; // 成功读取，直接返回
                    }
                }
            }
            
            // 如果 changelog.xml 不存在或没有版本信息，尝试从 version.txt 读取
            string versionFile = Server.MapPath("~/version.txt");
            if (System.IO.File.Exists(versionFile))
            {
                string ver = System.IO.File.ReadAllText(versionFile).Trim();
                if (!string.IsNullOrEmpty(ver))
                {
                    currentVersion = ver;
                    return;
                }
            }
            
            // 如果都读取失败，保持默认值 1.0.0
        }
        catch (Exception ex)
        {
            // 调试：可以记录错误
            // lblMessage.Text = "读取版本号失败：" + ex.Message;
        }
    }
    
    protected void BtnCheckUpdate_Click(object sender, EventArgs e)
    {
        // 截取并清除直接更新标志（由弹窗「立即检查并更新」按鈕设置）
        string autoDownloadUrl = hdnDirectUrl.Value;
        hdnDirectUrl.Value = "";
        try
        {
            lblMessage.Text = "正在检查更新...";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(59, 130, 246);
            
            // 从远程服务器检查更新
            string updateUrl = txtUpdateUrl.Text.Trim();
            
            // 如果用户输入的是旧的不可用地址，清空它
            if (updateUrl == "http://update.lequw.net/learnsite/version.json" || 
                updateUrl == "https://update.lequw.net/learnsite/version.json")
            {
                updateUrl = "";
                txtUpdateUrl.Text = "";
            }
            
            // ── 自动识别并转换 Gitee / GitHub 仓库地址 ──
            if (!string.IsNullOrEmpty(updateUrl))
            {
                string normalizedUrl = NormalizeUpdateUrl(updateUrl);
                if (normalizedUrl != updateUrl)
                {
                    lblResolvedUrl.Text = "→ 实际请求地址：<strong>" + normalizedUrl + "</strong>";
                    lblResolvedUrl.Visible = true;
                    updateUrl = normalizedUrl;
                }
                else { lblResolvedUrl.Visible = false; }
            }
            
            if (string.IsNullOrEmpty(updateUrl))
            {
                // 使用本地的 version.json 作为默认（如果存在）
                string localVersionFile = Server.MapPath("~/version.json");
                if (System.IO.File.Exists(localVersionFile))
                {
                    try
                    {
                        string jsonData = System.IO.File.ReadAllText(localVersionFile, System.Text.Encoding.UTF8);
                        ProcessVersionData(jsonData);
                        return;
                    }
                    catch { }
                }
                
                // 如果本地文件不存在，提示用户
                lblMessage.Text = "请配置更新服务器地址，或将 version.json 文件放置在网站根目录。<br/><br/>" +
                                 "您可以：<br/>" +
                                 "1. 搭建自己的更新服务器（推荐）<br/>" +
                                 "2. 使用GitHub托管更新文件<br/>" +
                                 "3. 将 version.json 放在网站根目录进行本地更新<br/><br/>" +
                                 "详细说明请查看：manager/系统更新故障排查指南.md";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(245, 158, 11);
                divUpdateInfo.Visible = false;
                btnDownloadUpdate.Visible = false;
                return;
            }
            
            // 启用 TLS 1.2（修复 HTTPS 连接问题）
            try
            {
                // SecurityProtocolType.Tls12 = 3072
                System.Net.ServicePointManager.SecurityProtocol = (System.Net.SecurityProtocolType)3072;
            }
            catch
            {
                // 如果不支持 TLS 1.2，尝试使用所有可用协议
                try
                {
                    System.Net.ServicePointManager.SecurityProtocol = 
                        System.Net.SecurityProtocolType.Ssl3 | 
                        System.Net.SecurityProtocolType.Tls | 
                        (System.Net.SecurityProtocolType)768 | // Tls11
                        (System.Net.SecurityProtocolType)3072; // Tls12
                }
                catch
                {
                    System.Net.ServicePointManager.SecurityProtocol = 
                        System.Net.SecurityProtocolType.Ssl3 | 
                        System.Net.SecurityProtocolType.Tls;
                }
            }
            
            // 设置超时时间
            System.Net.WebClient client = new System.Net.WebClient();
            client.Encoding = System.Text.Encoding.UTF8;
            
            // 添加User-Agent避免被服务器拒绝
            client.Headers.Add("User-Agent", "LearnSite-UpdateChecker/1.0");
            
            string jsonData2 = "";
            try
            {
                // 设置超时时间（30秒）
                System.Net.HttpWebRequest request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(updateUrl);
                request.Timeout = 30000;
                request.UserAgent = "LearnSite-UpdateChecker/1.0";
                request.Method = "GET";
                
                using (System.Net.HttpWebResponse response = (System.Net.HttpWebResponse)request.GetResponse())
                {
                    using (System.IO.StreamReader reader = new System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.UTF8))
                    {
                        jsonData2 = reader.ReadToEnd();
                    }
                }
            }
            catch (System.Net.WebException webEx)
            {
                string errorMsg = "连接更新服务器失败：<br/><br/>";
                
                // 详细的错误信息
                if (webEx.Status == System.Net.WebExceptionStatus.ProtocolError && webEx.Response != null)
                {
                    System.Net.HttpWebResponse response = (System.Net.HttpWebResponse)webEx.Response;
                    errorMsg += "<strong>HTTP错误：</strong>" + ((int)response.StatusCode) + " - " + response.StatusDescription + "<br/><br/>";
                    
                    // 如果是404，提供更详细的说明
                    if (response.StatusCode == System.Net.HttpStatusCode.NotFound)
                    {
                        errorMsg += "<strong>可能的原因：</strong><br/>" +
                                   "• 更新服务器地址不正确<br/>" +
                                   "• 版本文件不存在<br/>" +
                                   "• 服务器配置问题<br/><br/>";
                    }
                }
                else
                {
                    // 其他网络错误
                    errorMsg += "<strong>错误类型：</strong>" + webEx.Status.ToString() + "<br/>";
                    errorMsg += "<strong>错误信息：</strong>" + webEx.Message + "<br/>";
                    
                    if (webEx.InnerException != null)
                    {
                        errorMsg += "<strong>详细信息：</strong>" + webEx.InnerException.Message + "<br/>";
                    }
                    
                    errorMsg += "<br/><strong>常见原因：</strong><br/>";
                    
                    if (webEx.Status == System.Net.WebExceptionStatus.Timeout)
                    {
                        errorMsg += "• 连接超时，请检查网络连接<br/>";
                        errorMsg += "• 服务器响应过慢<br/>";
                    }
                    else if (webEx.Status == System.Net.WebExceptionStatus.NameResolutionFailure)
                    {
                        errorMsg += "• 无法解析域名，请检查DNS设置<br/>";
                        errorMsg += "• 服务器地址可能不正确<br/>";
                    }
                    else if (webEx.Status == System.Net.WebExceptionStatus.ConnectFailure)
                    {
                        errorMsg += "• 无法连接到服务器<br/>";
                        errorMsg += "• 服务器可能未运行或防火墙阻止<br/>";
                    }
                    else if (webEx.Status == System.Net.WebExceptionStatus.TrustFailure || 
                             webEx.Status == System.Net.WebExceptionStatus.SecureChannelFailure)
                    {
                        errorMsg += "• SSL/TLS证书验证失败<br/>";
                        errorMsg += "• 服务器证书可能过期或不受信任<br/>";
                        errorMsg += "• 尝试使用HTTP而非HTTPS<br/>";
                    }
                    else
                    {
                        errorMsg += "• 网络连接问题<br/>";
                        errorMsg += "• 防火墙或代理服务器阻止<br/>";
                        errorMsg += "• 服务器暂时不可用<br/>";
                    }
                }
                
                errorMsg += "<br/><strong>解决方案：</strong><br/>" +
                           "1. <strong>使用本地更新</strong>（推荐）：清空地址框，将 version.json 放在网站根目录<br/>" +
                           "2. <strong>检查网络</strong>：确认服务器可以访问外网<br/>" +
                           "3. <strong>检查地址</strong>：确认更新服务器地址正确且可访问<br/>" +
                           "4. <strong>手动更新</strong>：下载更新包手动安装<br/><br/>" +
                           "详细说明：manager/系统更新快速修复.txt";
                
                lblMessage.Text = errorMsg;
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                divUpdateInfo.Visible = false;
                btnDownloadUpdate.Visible = false;
                return;
            }
            catch (System.UriFormatException uriEx)
            {
                lblMessage.Text = "更新服务器地址格式错误：<br/><br/>" + 
                                 uriEx.Message + "<br/><br/>" +
                                 "<strong>正确格式示例：</strong><br/>" +
                                 "• http://192.168.1.100/updates/version.json<br/>" +
                                 "• https://example.com/learnsite/version.json<br/><br/>" +
                                 "或清空地址框使用本地 version.json 文件";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                divUpdateInfo.Visible = false;
                btnDownloadUpdate.Visible = false;
                return;
            }
            
            ProcessVersionData(jsonData2);
            
            // 如果弹窗点击了「立即检查并更新」，且确实有新版本，自动触发下载
            if (!string.IsNullOrEmpty(autoDownloadUrl) && hasUpdate)
            {
                BtnDownloadUpdate_Click(sender, e);
            }
        }
        catch (Exception ex)
        {
            string errorMsg = "检查更新失败：" + ex.Message;
            if (ex.InnerException != null)
            {
                errorMsg += "<br/>详细信息：" + ex.InnerException.Message;
            }
            errorMsg += "<br/><br/>请检查：<br/>" +
                       "1. 网络连接是否正常<br/>" +
                       "2. 更新服务器地址是否正确<br/>" +
                       "3. 服务器防火墙是否允许访问外部网络<br/><br/>" +
                       "或使用手动更新方式，详见：manager/系统更新快速修复.txt";
            
            lblMessage.Text = errorMsg;
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
            divUpdateInfo.Visible = false;
            btnDownloadUpdate.Visible = false;
        }
    }
    
    private void ProcessVersionData(string jsonData)
    {
        if (string.IsNullOrEmpty(jsonData))
        {
            lblMessage.Text = "更新服务器返回空数据";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
            divUpdateInfo.Visible = false;
            btnDownloadUpdate.Visible = false;
            return;
        }
        
        // 解析JSON（简单解析）
        latestVersion = ExtractJsonValue(jsonData, "version");
        updateLog = ExtractJsonValue(jsonData, "changelog");
        string downloadUrl = ExtractJsonValue(jsonData, "downloadUrl");
        
        if (string.IsNullOrEmpty(latestVersion))
        {
            lblMessage.Text = "无法解析版本信息，请检查更新服务器返回的数据格式<br/><br/>" +
                             "version.json 格式示例请查看：version.json.example";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
            divUpdateInfo.Visible = false;
            btnDownloadUpdate.Visible = false;
            return;
        }
        
        ViewState["LatestVersion"] = latestVersion;
        ViewState["UpdateLog"] = updateLog;
        ViewState["DownloadUrl"] = downloadUrl;
        
        if (CompareVersion(latestVersion, currentVersion) > 0)
        {
            hasUpdate = true;
            lblMessage.Text = "发现新版本 " + latestVersion + "，可以更新！";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(34, 197, 94);
            divUpdateInfo.Visible = true;
            litLatestVersion.Text = latestVersion;
            litUpdateLog.Text = string.IsNullOrEmpty(updateLog) ? "暂无更新说明" : updateLog.Replace("\n", "<br/>");
            
            if (!string.IsNullOrEmpty(downloadUrl))
            {
                lnkManualDownload.NavigateUrl = downloadUrl;
                string fileName = downloadUrl.Contains("/") ? downloadUrl.Substring(downloadUrl.LastIndexOf('/') + 1) : "update.zip";
                lnkManualDownload.Text = "手动下载更新包 (" + fileName + ")";
                lnkManualDownload.Visible = true;
                btnDownloadUpdate.Visible = true;
            }
            else
            {
                lnkManualDownload.Visible = false;
                btnDownloadUpdate.Visible = false;
                lblMessage.Text += "<br/><span style='color:#f59e0b;'>注意：未提供下载地址，请手动更新</span>";
            }
        }
        else
        {
            lblMessage.Text = "当前已是最新版本！";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(100, 116, 139);
            divUpdateInfo.Visible = false;
            btnDownloadUpdate.Visible = false;
        }
    }
    
    protected void BtnDownloadUpdate_Click(object sender, EventArgs e)
    {
        try
        {
            string downloadUrl = ViewState["DownloadUrl"] as string;
            
            // 严格检查下载地址
            if (string.IsNullOrEmpty(downloadUrl))
            {
                lblMessage.Text = "下载地址无效：未配置下载地址<br/><br/>" +
                                 "<strong>原因：</strong><br/>" +
                                 "version.json 文件中的 downloadUrl 字段为空<br/><br/>" +
                                 "<strong>解决方案：</strong><br/>" +
                                 "1. <strong>手动更新</strong>（推荐）：从官方渠道下载更新包，手动解压安装<br/>" +
                                 "2. <strong>配置下载地址</strong>：在 version.json 中添加有效的 downloadUrl<br/>" +
                                 "3. <strong>联系管理员</strong>：获取更新包下载地址<br/><br/>" +
                                 "详细说明：manager/系统更新快速修复.txt";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                divUpdateInfo.Visible = false;
                btnDownloadUpdate.Visible = false;
                return;
            }
            
            // 验证URL格式
            try
            {
                System.Uri uri = new System.Uri(downloadUrl);
                if (uri.Scheme != "http" && uri.Scheme != "https")
                {
                    lblMessage.Text = "下载地址格式错误：只支持 HTTP 或 HTTPS 协议<br/><br/>" +
                                     "当前地址：" + downloadUrl + "<br/><br/>" +
                                     "请使用手动更新方式。";
                    lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                    return;
                }
            }
            catch (System.UriFormatException)
            {
                lblMessage.Text = "下载地址格式错误：<br/><br/>" +
                                 "当前地址：" + downloadUrl + "<br/><br/>" +
                                 "请检查 version.json 中的 downloadUrl 格式是否正确。";
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                return;
            }
            
            // 显示进度区域
            divProgress.Visible = true;
            UpdateProgress("正在准备下载...", 0);
            
            // 启用 TLS 1.2（修复 HTTPS 下载问题）
            try
            {
                System.Net.ServicePointManager.SecurityProtocol = (System.Net.SecurityProtocolType)3072;
            }
            catch
            {
                try
                {
                    System.Net.ServicePointManager.SecurityProtocol = 
                        System.Net.SecurityProtocolType.Ssl3 | 
                        System.Net.SecurityProtocolType.Tls | 
                        (System.Net.SecurityProtocolType)768 | // Tls11
                        (System.Net.SecurityProtocolType)3072; // Tls12
                }
                catch
                {
                    System.Net.ServicePointManager.SecurityProtocol = 
                        System.Net.SecurityProtocolType.Ssl3 | 
                        System.Net.SecurityProtocolType.Tls;
                }
            }
            
            // 下载更新包
            string tempPath = Server.MapPath("~/App_Data/Temp");
            if (!System.IO.Directory.Exists(tempPath))
                System.IO.Directory.CreateDirectory(tempPath);
            
            string zipFile = System.IO.Path.Combine(tempPath, "update.zip");
            
            UpdateProgress("正在下载更新包...", 10);
            
            try
            {
                // 使用HttpWebRequest下载，更好的错误处理
                System.Net.HttpWebRequest request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(downloadUrl);
                request.Timeout = 300000; // 5分钟超时
                request.UserAgent = "LearnSite-UpdateChecker/1.0";
                request.Method = "GET";
                
                using (System.Net.HttpWebResponse response = (System.Net.HttpWebResponse)request.GetResponse())
                {
                    long totalBytes = response.ContentLength;
                    long receivedBytes = 0;
                    
                    using (System.IO.Stream responseStream = response.GetResponseStream())
                    {
                        using (System.IO.FileStream fileStream = new System.IO.FileStream(zipFile, System.IO.FileMode.Create))
                        {
                            byte[] buffer = new byte[8192];
                            int bytesRead;
                            while ((bytesRead = responseStream.Read(buffer, 0, buffer.Length)) > 0)
                            {
                                fileStream.Write(buffer, 0, bytesRead);
                                receivedBytes += bytesRead;
                                
                                // 更新下载进度
                                if (totalBytes > 0)
                                {
                                    int progress = (int)((receivedBytes * 40) / totalBytes) + 10; // 10-50%
                                    UpdateProgress(string.Format("正在下载... {0:F1} MB / {1:F1} MB", 
                                        receivedBytes / 1024.0 / 1024.0, 
                                        totalBytes / 1024.0 / 1024.0), progress);
                                }
                            }
                        }
                    }
                }
            }
            catch (System.Net.WebException webEx)
            {
                divProgress.Visible = false;
                string errorMsg = "下载更新包失败：<br/><br/>";
                
                if (webEx.Status == System.Net.WebExceptionStatus.ProtocolError && webEx.Response != null)
                {
                    System.Net.HttpWebResponse response = (System.Net.HttpWebResponse)webEx.Response;
                    errorMsg += "HTTP " + ((int)response.StatusCode) + " - " + response.StatusDescription;
                }
                else
                {
                    errorMsg += webEx.Status.ToString() + ": " + webEx.Message;
                    if (webEx.InnerException != null)
                    {
                        errorMsg += "<br/>详细信息：" + webEx.InnerException.Message;
                    }
                }
                
                errorMsg += "<br/><br/>请尝试手动下载更新包并安装。";
                
                lblMessage.Text = errorMsg;
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
                return;
            }
            
            UpdateProgress("下载完成！正在解压更新包...", 55);
            
            // 解压更新包（使用Shell.Application COM对象，兼容.NET 2.0）
            string extractPath = System.IO.Path.Combine(tempPath, "update");
            if (System.IO.Directory.Exists(extractPath))
                System.IO.Directory.Delete(extractPath, true);
            System.IO.Directory.CreateDirectory(extractPath);
            
            UnzipFile(zipFile, extractPath);
            
            UpdateProgress("解压完成！正在分析更新文件...", 70);
            
            // 获取更新文件列表
            System.Collections.ArrayList updateFiles = GetUpdateFilesList(extractPath);
            DisplayUpdateFiles(updateFiles);
            
            UpdateProgress("正在应用更新...", 75);
            
            // 应用更新（复制文件）
            int totalFiles = updateFiles.Count;
            int processedFiles = 0;
            
            foreach (string file in updateFiles)
            {
                processedFiles++;
                int progress = 75 + (int)((processedFiles * 20.0) / totalFiles); // 75-95%
                UpdateProgress(string.Format("正在更新文件 ({0}/{1})...", processedFiles, totalFiles), progress);
            }
            
            CopyDirectory(extractPath, Server.MapPath("~/"));
            
            UpdateProgress("正在更新版本信息...", 96);
            
            // 更新版本号到 changelog.xml（与 index.aspx 保持一致）
            string newVersion = ViewState["LatestVersion"] as string;
            UpdateChangelogVersion(newVersion);
            
            // 同时更新 version.txt（向后兼容）
            string versionFile = Server.MapPath("~/version.txt");
            System.IO.File.WriteAllText(versionFile, newVersion);
            
            UpdateProgress("正在清理临时文件...", 98);
            
            // 清理临时文件
            try
            {
                System.IO.File.Delete(zipFile);
                System.IO.Directory.Delete(extractPath, true);
            }
            catch { } // 忽略清理错误
            
            UpdateProgress("更新完成！", 100);
            
            // 重新加载版本号，确保显示最新版本
            LoadCurrentVersion();
            
            lblMessage.Text = "更新成功！当前版本：" + currentVersion + "<br/>页面将在 3 秒后自动刷新...";
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(34, 197, 94);
            
            divUpdateInfo.Visible = false;
            btnDownloadUpdate.Visible = false;
            
            // 3秒后刷新页面
            Response.AddHeader("Refresh", "3;URL=" + Request.Url.AbsolutePath);
        }
        catch (Exception ex)
        {
            divProgress.Visible = false;
            lblMessage.Text = "更新失败：" + ex.Message;
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(239, 68, 68);
        }
    }
    
    private void UpdateProgress(string message, int percent)
    {
        litProgressText.Text = message;
        litProgressPercent.Text = percent.ToString() + "%";
        
        // 更新进度条宽度（通过内联样式）
        string progressBarStyle = string.Format("width:{0}%;background:linear-gradient(90deg,#3b82f6,#8b5cf6);height:100%;border-radius:6px;transition:width 0.3s ease;", percent);
        litProgressBar.Text = "<div style=\"" + progressBarStyle + "\"></div>";
    }
    
    private System.Collections.ArrayList GetUpdateFilesList(string directory)
    {
        System.Collections.ArrayList files = new System.Collections.ArrayList();
        GetFilesRecursive(directory, directory, files);
        return files;
    }
    
    private void GetFilesRecursive(string baseDir, string currentDir, System.Collections.ArrayList files)
    {
        System.IO.DirectoryInfo dir = new System.IO.DirectoryInfo(currentDir);
        
        foreach (System.IO.FileInfo file in dir.GetFiles())
        {
            string relativePath = file.FullName.Substring(baseDir.Length + 1);
            files.Add(relativePath);
        }
        
        foreach (System.IO.DirectoryInfo subdir in dir.GetDirectories())
        {
            GetFilesRecursive(baseDir, subdir.FullName, files);
        }
    }
    
    private void DisplayUpdateFiles(System.Collections.ArrayList files)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<div style='max-height:200px;overflow-y:auto;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;padding:12px;margin-top:12px;'>");
        sb.Append("<div style='font-size:13px;font-weight:600;color:#334155;margin-bottom:8px;'>更新文件列表（共 " + files.Count + " 个文件）：</div>");
        sb.Append("<ul style='list-style:none;padding:0;margin:0;font-size:12px;color:#64748b;line-height:1.8;'>");
        
        foreach (string file in files)
        {
            sb.Append("<li style='padding:2px 0;'>");
            sb.Append("<span style='color:#22c55e;margin-right:6px;'>✓</span>");
            sb.Append(System.Web.HttpUtility.HtmlEncode(file));
            sb.Append("</li>");
        }
        
        sb.Append("</ul></div>");
        litFileList.Text = sb.ToString();
    }
    
    private void UnzipFile(string zipPath, string extractPath)
    {
        try
        {
            // 方法1：使用Shell.Application COM对象（Windows内置）
            Type shellType = Type.GetTypeFromProgID("Shell.Application");
            object shell = Activator.CreateInstance(shellType);
            
            object zipFolder = shellType.InvokeMember("NameSpace",
                System.Reflection.BindingFlags.InvokeMethod, null, shell,
                new object[] { zipPath });
            
            object destFolder = shellType.InvokeMember("NameSpace",
                System.Reflection.BindingFlags.InvokeMethod, null, shell,
                new object[] { extractPath });
            
            object items = zipFolder.GetType().InvokeMember("Items",
                System.Reflection.BindingFlags.InvokeMethod, null, zipFolder, null);
            
            destFolder.GetType().InvokeMember("CopyHere",
                System.Reflection.BindingFlags.InvokeMethod, null, destFolder,
                new object[] { items, 20 }); // 20 = 不显示对话框 + 覆盖已存在文件
            
            // 等待解压完成
            System.Threading.Thread.Sleep(2000);
        }
        catch
        {
            // 方法2：如果COM方法失败，尝试使用ICSharpCode.SharpZipLib（如果已安装）
            try
            {
                System.Reflection.Assembly zipLib = System.Reflection.Assembly.Load("ICSharpCode.SharpZipLib");
                if (zipLib != null)
                {
                    Type fastZipType = zipLib.GetType("ICSharpCode.SharpZipLib.Zip.FastZip");
                    object fastZip = Activator.CreateInstance(fastZipType);
                    fastZipType.InvokeMember("ExtractZip",
                        System.Reflection.BindingFlags.InvokeMethod, null, fastZip,
                        new object[] { zipPath, extractPath, null });
                }
            }
            catch
            {
                throw new Exception("无法解压更新包。请确保系统支持ZIP解压功能，或手动安装更新。");
            }
        }
    }
    
    private void CopyDirectory(string sourceDir, string targetDir)
    {
        System.IO.DirectoryInfo dir = new System.IO.DirectoryInfo(sourceDir);
        System.IO.DirectoryInfo[] dirs = dir.GetDirectories();
        
        if (!System.IO.Directory.Exists(targetDir))
            System.IO.Directory.CreateDirectory(targetDir);
        
        System.IO.FileInfo[] files = dir.GetFiles();
        foreach (System.IO.FileInfo file in files)
        {
            string targetFile = System.IO.Path.Combine(targetDir, file.Name);
            try
            {
                file.CopyTo(targetFile, true);
            }
            catch { } // 跳过无法覆盖的文件
        }
        
        foreach (System.IO.DirectoryInfo subdir in dirs)
        {
            string targetSubDir = System.IO.Path.Combine(targetDir, subdir.Name);
            CopyDirectory(subdir.FullName, targetSubDir);
        }
    }
    
    private string ExtractJsonValue(string json, string key)
    {
        try
        {
            string pattern = "\"" + key + "\"\\s*:\\s*\"([^\"]+)\"";
            System.Text.RegularExpressions.Match match = System.Text.RegularExpressions.Regex.Match(json, pattern);
            if (match.Success)
                return match.Groups[1].Value;
        }
        catch { }
        return "";
    }
    
    private int CompareVersion(string v1, string v2)
    {
        try
        {
            // 移除 'v' 前缀
            v1 = v1.TrimStart('v', 'V');
            v2 = v2.TrimStart('v', 'V');
            
            string[] parts1 = v1.Split('.');
            string[] parts2 = v2.Split('.');
            int maxLen = System.Math.Max(parts1.Length, parts2.Length);
            
            for (int i = 0; i < maxLen; i++)
            {
                int num1 = i < parts1.Length ? int.Parse(parts1[i]) : 0;
                int num2 = i < parts2.Length ? int.Parse(parts2[i]) : 0;
                
                if (num1 > num2) return 1;
                if (num1 < num2) return -1;
            }
            return 0;
        }
        catch
        {
            return 0;
        }
    }
    
    private void UpdateChangelogVersion(string newVersion)
    {
        try
        {
            string xmlPath = Server.MapPath("~/changelog.xml");
            if (!System.IO.File.Exists(xmlPath))
            {
                // 如果 changelog.xml 不存在，创建一个基本的
                CreateBasicChangelog(xmlPath, newVersion);
                return;
            }
            
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(xmlPath);
            
            System.Xml.XmlNode root = doc.SelectSingleNode("//changelog");
            if (root == null)
            {
                CreateBasicChangelog(xmlPath, newVersion);
                return;
            }
            
            // 检查是否已存在该版本
            System.Xml.XmlNode existingVersion = root.SelectSingleNode("version[@ver='" + newVersion + "']");
            if (existingVersion != null)
            {
                // 版本已存在，不需要添加
                return;
            }
            
            // 创建新版本节点
            System.Xml.XmlElement versionEl = doc.CreateElement("version");
            versionEl.SetAttribute("ver", newVersion);
            versionEl.SetAttribute("tag", "new");
            versionEl.SetAttribute("date", System.DateTime.Now.ToString("yyyy年M月"));
            
            // 添加更新说明
            string updateLogText = ViewState["UpdateLog"] as string;
            if (!string.IsNullOrEmpty(updateLogText))
            {
                string[] lines = updateLogText.Split(new char[] { '\r', '\n' }, System.StringSplitOptions.RemoveEmptyEntries);
                foreach (string line in lines)
                {
                    string trimmed = line.Trim();
                    if (!string.IsNullOrEmpty(trimmed))
                    {
                        System.Xml.XmlElement itemEl = doc.CreateElement("item");
                        // 移除行首的数字序号和点号
                        trimmed = System.Text.RegularExpressions.Regex.Replace(trimmed, @"^\d+[\.\、]\s*", "");
                        itemEl.InnerText = trimmed;
                        versionEl.AppendChild(itemEl);
                    }
                }
            }
            else
            {
                // 如果没有更新日志，添加默认说明
                System.Xml.XmlElement itemEl = doc.CreateElement("item");
                itemEl.InnerText = "系统自动更新到版本 " + newVersion;
                versionEl.AppendChild(itemEl);
            }
            
            // 插入到第一个位置（最新版本在最前面）
            if (root.FirstChild != null)
                root.InsertBefore(versionEl, root.FirstChild);
            else
                root.AppendChild(versionEl);
            
            doc.Save(xmlPath);
        }
        catch { }
    }
    
    private void CreateBasicChangelog(string xmlPath, string version)
    {
        try
        {
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            System.Xml.XmlDeclaration declaration = doc.CreateXmlDeclaration("1.0", "utf-8", null);
            doc.AppendChild(declaration);
            
            System.Xml.XmlElement root = doc.CreateElement("changelog");
            doc.AppendChild(root);
            
            System.Xml.XmlElement versionEl = doc.CreateElement("version");
            versionEl.SetAttribute("ver", version);
            versionEl.SetAttribute("tag", "new");
            versionEl.SetAttribute("date", System.DateTime.Now.ToString("yyyy年M月"));
            
            System.Xml.XmlElement itemEl = doc.CreateElement("item");
            itemEl.InnerText = "系统初始化版本";
            versionEl.AppendChild(itemEl);
            
            root.AppendChild(versionEl);
            doc.Save(xmlPath);
        }
        catch { }
    }

    // 自动识别 Gitee / GitHub 仓库主页地址并转换为 version.json 直链
    private string NormalizeUpdateUrl(string url)
    {
        if (string.IsNullOrEmpty(url)) return url;
        url = url.TrimEnd('/').TrimEnd();
        
        // Gitee 仓库主页：https://gitee.com/owner/repo
        System.Text.RegularExpressions.Match m = System.Text.RegularExpressions.Regex.Match(
            url, @"^https?://gitee\.com/([^/\s]+)/([^/\s\.]+)$");
        if (m.Success)
        {
            return "https://gitee.com/" + m.Groups[1].Value + "/" + m.Groups[2].Value + "/raw/master/version.json";
        }
        
        // GitHub 仓库主页：https://github.com/owner/repo
        m = System.Text.RegularExpressions.Regex.Match(
            url, @"^https?://github\.com/([^/\s]+)/([^/\s\.]+)$");
        if (m.Success)
        {
            return "https://raw.githubusercontent.com/" + m.Groups[1].Value + "/" + m.Groups[2].Value + "/master/version.json";
        }
        
        // 其他地址原样返回
        return url;
    }
</script>


<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .su-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    /* ===== 页头标题区 ===== */
    .su-hd{display:flex;align-items:center;gap:18px;margin-bottom:26px;}
    .su-hd-icon{
        width:54px;height:54px;
        background:linear-gradient(135deg,#3b82f6 0%,#6366f1 100%);
        border-radius:16px;
        display:flex;align-items:center;justify-content:center;
        box-shadow:0 6px 20px rgba(99,102,241,.28),0 0 0 5px rgba(99,102,241,.08);
        flex-shrink:0;position:relative;overflow:hidden;
    }
    .su-hd-icon::after{
        content:'';position:absolute;top:0;left:0;right:0;bottom:0;
        background:linear-gradient(150deg,rgba(255,255,255,.22) 0%,transparent 55%);
        pointer-events:none;
    }
    .su-hd-icon svg{width:28px;height:28px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;position:relative;z-index:1;}
    .su-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 3px;}
    .su-hd-text p{font-size:13px;color:#94a3b8;margin:0;}
    /* ===== 卡片布局 ===== */
    .su-grid{display:flex;flex-direction:column;gap:24px;}
    .su-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;}
    .su-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    /* ===== 卡头图标 ===== */
    .su-card-hd .ci{
        width:36px;height:36px;border-radius:10px;
        display:flex;align-items:center;justify-content:center;flex-shrink:0;
    }
    .su-card-hd .ci svg{width:20px;height:20px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.blue{background:linear-gradient(135deg,#eff6ff,#dbeafe);box-shadow:0 2px 8px rgba(59,130,246,.14);}
    .ci.blue svg{stroke:#3b82f6;}
    .ci.green{background:linear-gradient(135deg,#f0fdf4,#dcfce7);box-shadow:0 2px 8px rgba(34,197,94,.14);}
    .ci.green svg{stroke:#16a34a;}
    .ci.amber{background:linear-gradient(135deg,#fffbeb,#fef3c7);box-shadow:0 2px 8px rgba(245,158,11,.14);}
    .ci.amber svg{stroke:#d97706;}
    .ci.violet{background:linear-gradient(135deg,#faf5ff,#ede9fe);box-shadow:0 2px 8px rgba(139,92,246,.14);}
    .ci.violet svg{stroke:#7c3aed;}
    /* ===== 卡片内容 ===== */
    .su-card-bd{padding:24px 26px;}
    /* 版本显示面板 */
    .su-ver-panel{
        display:flex;align-items:center;justify-content:space-between;
        background:linear-gradient(135deg,#eff6ff 0%,#eef2ff 100%);
        border:1px solid #c7d7f9;border-radius:12px;
        padding:16px 20px;margin-bottom:24px;
    }
    .su-ver-left{display:flex;align-items:center;gap:14px;}
    .su-ver-icon{
        width:40px;height:40px;border-radius:10px;
        background:linear-gradient(135deg,#3b82f6,#6366f1);
        display:flex;align-items:center;justify-content:center;
        box-shadow:0 3px 10px rgba(99,102,241,.25);flex-shrink:0;
    }
    .su-ver-icon svg{width:20px;height:20px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .su-ver-info .su-ver-lbl{font-size:12px;color:#6366f1;font-weight:600;letter-spacing:.3px;margin-bottom:2px;}
    .su-ver-info .su-ver-num{font-size:22px;font-weight:900;color:#1e1b4b;letter-spacing:-0.5px;line-height:1;}
    .su-ver-right{display:flex;align-items:center;gap:8px;}
    .su-ver-status{
        display:inline-flex;align-items:center;gap:6px;
        padding:5px 12px;border-radius:20px;
        font-size:12px;font-weight:600;
        background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;
    }
    .su-ver-status-dot{
        width:7px;height:7px;border-radius:50%;background:#22c55e;
        box-shadow:0 0 0 2px rgba(34,197,94,.25);
        animation:su-pulse 2.4s ease-in-out infinite;
    }
    @keyframes su-pulse{
        0%,100%{box-shadow:0 0 0 2px rgba(34,197,94,.25);}
        50%{box-shadow:0 0 0 4px rgba(34,197,94,.12);}
    }
    /* URL 输入区域 */
    .su-field-lbl{
        display:flex;align-items:center;gap:8px;
        font-size:14px;font-weight:700;color:#1e293b;
        margin-bottom:10px;
    }
    .su-field-lbl svg{width:16px;height:16px;stroke:#6366f1;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0;}
    .su-opt-chip{
        font-size:10px;font-weight:600;color:#6366f1;
        background:#eef2ff;border:1px solid #c7d2fe;
        border-radius:20px;padding:1px 8px;margin-left:2px;
    }
    .su-url-row{display:flex;align-items:center;gap:8px;margin-bottom:12px;}
    .su-url-row input[type="text"]{
        flex:1;padding:10px 14px;
        border:1.5px solid #e2e8f0;border-radius:9px;
        font-size:14px;font-family:inherit;
        transition:all .2s;background:#fff;
        box-shadow:0 1px 3px rgba(0,0,0,.04);
    }
    .su-url-row input[type="text"]:focus{
        outline:none;border-color:#6366f1;
        box-shadow:0 0 0 3px rgba(99,102,241,.1),0 1px 3px rgba(0,0,0,.04);
    }
    /* 格式提示盒子 */
    .su-hint-box{
        background:#f8fafc;border:1px solid #e8ecf0;
        border-radius:10px;padding:14px 16px;margin-bottom:20px;
    }
    .su-hint-title{
        display:flex;align-items:center;gap:6px;
        font-size:11px;font-weight:700;color:#64748b;
        text-transform:uppercase;letter-spacing:.6px;margin-bottom:12px;
    }
    .su-hint-title::before{
        content:'';display:block;width:3px;height:12px;
        background:linear-gradient(135deg,#6366f1,#3b82f6);
        border-radius:2px;
    }
    .su-hint-list{display:flex;flex-direction:column;gap:9px;}
    .su-hint-item{display:flex;align-items:flex-start;gap:8px;font-size:12px;color:#475569;line-height:1.6;}
    .su-hint-tag{
        display:inline-flex;align-items:center;padding:2px 8px;
        border-radius:4px;font-size:10px;font-weight:700;flex-shrink:0;margin-top:1px;
    }
    .su-hint-tag.gitee{background:#fff1f0;color:#cf4500;border:1px solid #ffd8bf;}
    .su-hint-tag.raw{background:#eff6ff;color:#2563eb;border:1px solid #bfdbfe;}
    .su-hint-tag.local{background:#f0fdf4;color:#16a34a;border:1px solid #bbf7d0;}
    .su-hint-item code{
        background:#e2e8f0;color:#334155;padding:1px 5px;
        border-radius:4px;font-size:10.5px;font-family:'Courier New',monospace;
    }
    /* JSON 示例代码块 */
    .su-code-block{
        background:#1e293b;border-radius:10px;
        padding:14px 16px;margin-bottom:20px;position:relative;
    }
    .su-code-block-title{
        display:flex;align-items:center;gap:6px;
        font-size:10px;font-weight:600;color:#64748b;
        letter-spacing:.6px;text-transform:uppercase;margin-bottom:8px;
    }
    .su-code-block-title::before{content:'&#123;&#125;';color:#475569;font-family:monospace;font-size:11px;}
    .su-code-block-dots{display:flex;gap:5px;margin-bottom:10px;}
    .su-code-block-dots span{
        width:10px;height:10px;border-radius:50%;
    }
    .su-code-block-dots span:nth-child(1){background:#ef4444;opacity:.7;}
    .su-code-block-dots span:nth-child(2){background:#f59e0b;opacity:.7;}
    .su-code-block-dots span:nth-child(3){background:#22c55e;opacity:.7;}
    .su-code-block code{
        font-size:11.5px;color:#94a3b8;
        font-family:'Courier New','Consolas',monospace;
        line-height:1.6;display:block;word-break:break-all;
    }
    .su-code-block code .ck{color:#93c5fd;} /* key */
    .su-code-block code .cv{color:#86efac;} /* string value */
    /* 按钮组 */
    .su-btn-group{display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
    .btn-primary{
        display:inline-flex;align-items:center;justify-content:center;gap:8px;
        height:42px;padding:0 28px;
        background:linear-gradient(135deg,#3b82f6,#2563eb);
        color:#fff!important;border:none;border-radius:10px;
        font-size:14px;font-family:inherit;font-weight:600;
        cursor:pointer;transition:all .2s;
        box-shadow:0 3px 10px rgba(59,130,246,.35);
    }
    .btn-primary svg{width:16px;height:16px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .btn-primary:hover{box-shadow:0 6px 18px rgba(59,130,246,.45);transform:translateY(-1px);}
    .btn-success{background:linear-gradient(135deg,#22c55e,#16a34a);box-shadow:0 3px 10px rgba(34,197,94,.35);}
    .btn-success:hover{box-shadow:0 6px 18px rgba(34,197,94,.45);}
    .su-message{margin-top:16px;padding:12px 16px;border-radius:9px;font-size:13px;font-weight:500;}
    .su-update-info{background:linear-gradient(135deg,#f0f9ff,#e0f2fe);border:1px solid #bae6fd;border-radius:12px;padding:20px;margin-top:18px;}
    .su-update-info h3{font-size:15px;font-weight:700;color:#0c4a6e;margin:0 0 12px;}
    .su-update-info .version{font-size:20px;font-weight:800;color:#0369a1;margin-bottom:12px;letter-spacing:-0.5px;}
    .su-update-info .changelog{font-size:13px;color:#334155;line-height:1.8;}
    /* ===== 使用说明列表 ===== */
    .su-notice{list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:2px;}
    .su-notice li{
        display:flex;align-items:flex-start;gap:12px;
        font-size:13px;color:#334155;line-height:1.7;
        padding:10px 12px;border-radius:10px;
        transition:background .15s;
    }
    .su-notice li:hover{background:#f8fafc;}
    .su-notice .ni-sep{
        height:1px;
        background:linear-gradient(90deg,transparent,#e2e8f0,transparent);
        margin:6px 4px;padding:0 !important;
        display:block !important;
    }
    /* 通用图标小方块 */
    .su-notice li .ni{
        width:28px;height:28px;border-radius:8px;
        display:flex;align-items:center;justify-content:center;
        flex-shrink:0;margin-top:1px;
    }
    .ni svg{width:15px;height:15px;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    /* 步骤在1–小数字 蓝臲紫渐变 */
    .ni.s1{background:linear-gradient(135deg,#eff6ff,#dbeafe);color:#2563eb;font-size:12px;font-weight:800;}
    .ni.s2{background:linear-gradient(135deg,#f0fdf4,#d1fae5);color:#16a34a;font-size:12px;font-weight:800;}
    .ni.s3{background:linear-gradient(135deg,#faf5ff,#ede9fe);color:#7c3aed;font-size:12px;font-weight:800;}
    /* 警告图标 璐色 */
    .ni.warn{background:linear-gradient(135deg,#fffbeb,#fef3c7);}
    .ni.warn svg{stroke:#d97706;}
    /* 提示图标 绿色 */
    .ni.tip{background:linear-gradient(135deg,#f0fdf4,#dcfce7);}
    .ni.tip svg{stroke:#16a34a;}
    /* ===== 自动检测状态条 ===== */
    .su-ac{display:flex;align-items:center;gap:10px;padding:11px 16px;border-radius:10px;margin-bottom:22px;font-size:13px;min-height:44px;}
    .su-ac.loading{background:#f8fafc;border:1px solid #e2e8f0;color:#64748b;}
    .su-ac.ok{background:linear-gradient(135deg,#f0fdf4,#dcfce7);border:1px solid #bbf7d0;color:#15803d;}
    .su-ac.upd{background:linear-gradient(135deg,#fffbeb,#fef9c3);border:1px solid #fde68a;color:#92400e;}
    .su-ac.err{background:#f8fafc;border:1px solid #e2e8f0;color:#94a3b8;}
    .su-ac .spin{flex-shrink:0;animation:su-spin .75s linear infinite;}
    @keyframes su-spin{to{transform:rotate(360deg);}}
    .su-ac .ac-msg{flex:1;font-weight:500;}
    .su-ac.ok .ac-msg,.su-ac.upd .ac-msg{font-weight:600;}
    .su-new-tag{flex-shrink:0;padding:3px 11px;border-radius:20px;font-size:11px;font-weight:700;background:#fef3c7;border:1px solid #fcd34d;color:#b45309;cursor:pointer;}
    /* ===== 新版本弹窗 ===== */
    .su-overlay{display:none;position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(15,23,42,.5);-webkit-backdrop-filter:blur(4px);backdrop-filter:blur(4px);z-index:99900;overflow-y:auto;}
    .su-overlay.show{display:flex;align-items:center;justify-content:center;}
    .su-dialog{background:#fff;border-radius:20px;width:440px;max-width:calc(100vw - 32px);max-height:calc(100vh - 48px);display:flex;flex-direction:column;box-shadow:0 32px 80px rgba(0,0,0,.2);animation:dlg-in .35s cubic-bezier(.22,.68,0,1.25);overflow:hidden;margin:16px auto;}
    @keyframes dlg-in{from{opacity:0;transform:scale(.88) translateY(22px);}to{opacity:1;transform:none;}}
    .su-dlg-hd{padding:26px 26px 20px;border-bottom:1px solid #f1f5f9;flex-shrink:0;}
    .su-dlg-chip{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;background:linear-gradient(135deg,#fef3c7,#fffbeb);border:1px solid #fcd34d;border-radius:20px;font-size:11px;font-weight:800;color:#b45309;letter-spacing:.4px;margin-bottom:14px;}
    .su-dlg-chip::before{content:'';width:7px;height:7px;border-radius:50%;background:#f59e0b;animation:su-pulse 1.5s infinite;}
    .su-dlg-ver{font-size:32px;font-weight:900;color:#0f172a;letter-spacing:-1.5px;line-height:1;margin-bottom:8px;}
    .su-dlg-sub{font-size:13px;color:#64748b;line-height:1.5;}
    .su-dlg-bd{padding:20px 26px;flex:1;overflow-y:auto;min-height:0;}
    .su-dlg-log{max-height:200px;overflow-y:auto;padding:12px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;font-size:13px;color:#334155;line-height:1.85;}
    .su-dlg-ft{padding:16px 26px;border-top:1px solid #f1f5f9;display:flex;gap:10px;flex-shrink:0;}
    .su-dlg-go{flex:1;display:inline-flex;align-items:center;justify-content:center;gap:8px;height:44px;background:linear-gradient(135deg,#3b82f6,#6366f1);color:#fff;border:none;border-radius:11px;font-size:14px;font-weight:700;cursor:pointer;font-family:inherit;box-shadow:0 4px 14px rgba(99,102,241,.38);transition:box-shadow .2s;}
    .su-dlg-go:hover{box-shadow:0 8px 24px rgba(99,102,241,.52);}
    .su-dlg-cancel{display:inline-flex;align-items:center;justify-content:center;height:44px;padding:0 22px;background:#f1f5f9;color:#64748b;border:none;border-radius:11px;font-size:14px;font-weight:500;cursor:pointer;font-family:inherit;transition:background .15s;}
    .su-dlg-cancel:hover{background:#e2e8f0;}
</style>

<div class="su-page">
    <div class="su-hd">
        <div class="su-hd-icon">
            <svg viewBox="0 0 24 24"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
        </div>
        <div class="su-hd-text"><h1>系统更新</h1><p>检查版本并一键升级到最新版本</p></div>
    </div>

    <div class="su-grid">
        <!-- 版本信息 -->
        <div class="su-card">
            <div class="su-card-hd">
                <span class="ci blue"><svg viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg></span>
                版本信息
            </div>
            <div class="su-card-bd">

                <!-- 版本显示面板 -->
                <div class="su-ver-panel">
                    <div class="su-ver-left">
                        <div class="su-ver-icon">
                            <svg viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                        </div>
                        <div class="su-ver-info">
                            <div class="su-ver-lbl">CURRENT VERSION</div>
                            <div class="su-ver-num"><%= currentVersion %></div>
                        </div>
                    </div>
                    <div class="su-ver-right">
                        <div class="su-ver-status">
                            <span class="su-ver-status-dot"></span>
                            运行正常
                        </div>
                    </div>
                </div>

                <!-- JS 自动检测状态条 -->
                <div id="suAcBar" class="su-ac loading">
                    <svg class="spin" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2.5" stroke-linecap="round"><path d="M12 3a9 9 0 0 1 9 9"/></svg>
                    <span class="ac-msg">正在自动检测最新版本…</span>
                </div>

                <!-- 更新服务器地址输入 -->
                <div class="su-field-lbl">
                    <svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                    更新服务器地址
                    <span class="su-opt-chip">可选</span>
                </div>
                <div class="su-url-row">
                    <asp:TextBox ID="txtUpdateUrl" runat="server" placeholder="示例：https://gitee.com/用户名/仓库名"></asp:TextBox>
                    <a href="javascript:void(0)"
                       onclick="document.getElementById('<%= txtUpdateUrl.ClientID %>').value='https://gitee.com/lequw/ls';return false;"
                       title="填入官方 Gitee 仓库地址"
                       style="white-space:nowrap;display:inline-flex;align-items:center;gap:6px;padding:0 16px;height:42px;background:linear-gradient(135deg,#c7553a,#e8522b);color:#fff;text-decoration:none;border-radius:10px;font-size:13px;font-weight:700;flex-shrink:0;box-shadow:0 3px 10px rgba(200,85,58,.35);transition:all .2s;"
                       onmouseover="this.style.boxShadow='0 6px 18px rgba(200,85,58,.5)';this.style.transform='translateY(-1px)';"
                       onmouseout="this.style.boxShadow='0 3px 10px rgba(200,85,58,.35)';this.style.transform='';"
                    ><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>官方地址</a>
                </div>
                <asp:Label ID="lblResolvedUrl" runat="server" Visible="false" style="display:block;margin-bottom:12px;font-size:12px;color:#0369a1;padding:6px 10px;background:#e0f2fe;border-radius:6px;border:1px solid #bae6fd;"></asp:Label>

                <!-- 地址格式提示盒 -->
                <div class="su-hint-box">
                    <div class="su-hint-title">支持的地址格式</div>
                    <div class="su-hint-list">
                        <div class="su-hint-item">
                            <span class="su-hint-tag gitee">Gitee</span>
                            <span>直接粘贴仓库主页地址，自动读取 master 分支下的&nbsp;<code>version.json</code>&nbsp;——「<strong>推荐</strong>」</span>
                        </div>
                        <div class="su-hint-item">
                            <span class="su-hint-tag raw">Raw</span>
                            <span>直接填写文件原始链接，如&nbsp;<code>https://gitee.com/用户名/仓库名/raw/master/version.json</code></span>
                        </div>
                        <div class="su-hint-item">
                            <span class="su-hint-tag local">本地</span>
                            <span>留空此框，将&nbsp;<code>version.json</code>&nbsp;放在网站根目录即可离线检测</span>
                        </div>
                    </div>
                </div>

                <!-- JSON 格式示例 -->
                <div class="su-code-block">
                    <div class="su-code-block-dots"><span></span><span></span><span></span></div>
                    <div class="su-code-block-title">&nbsp;version.json 格式示例</div>
                    <code>&#123;&nbsp;<span class="ck">&quot;version&quot;</span>:&nbsp;<span class="cv">&quot;2.0.0&quot;</span>,&nbsp;<span class="ck">&quot;changelog&quot;</span>:&nbsp;<span class="cv">&quot;1.新功能
2.修复&quot;</span>,&nbsp;<span class="ck">&quot;downloadUrl&quot;</span>:&nbsp;<span class="cv">&quot;https://gitee.com/.../archive/v2.0.0.zip&quot;</span>&nbsp;&#125;</code>
                </div>

                <!-- 操作按鈕 -->
                <div class="su-btn-group">
                    <asp:Button ID="btnCheckUpdate" runat="server" Text="检查更新" CssClass="btn-primary" OnClick="BtnCheckUpdate_Click" />
                    <asp:Button ID="btnDownloadUpdate" runat="server" Text="&#x2B07; 立即更新" CssClass="btn-primary btn-success" OnClick="BtnDownloadUpdate_Click" Visible="false" />
                </div>
                <asp:HiddenField ID="hdnDirectUrl" runat="server" />
                
                <div class="su-message">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </div>
                
                <!-- 进度显示区域 -->
                <div id="divProgress" runat="server" visible="false" style="margin-top:18px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:18px;">
                    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                        <span style="font-size:14px;font-weight:600;color:#334155;">
                            <asp:Literal ID="litProgressText" runat="server">正在准备...</asp:Literal>
                        </span>
                        <span style="font-size:14px;font-weight:700;color:#3b82f6;">
                            <asp:Literal ID="litProgressPercent" runat="server">0%</asp:Literal>
                        </span>
                    </div>
                    <div style="width:100%;height:12px;background:#e2e8f0;border-radius:6px;overflow:hidden;">
                        <asp:Literal ID="litProgressBar" runat="server">
                            <div style="width:0%;background:linear-gradient(90deg,#3b82f6,#8b5cf6);height:100%;border-radius:6px;transition:width 0.3s ease;"></div>
                        </asp:Literal>
                    </div>
                    <!-- 文件列表 -->
                    <asp:Literal ID="litFileList" runat="server"></asp:Literal>
                </div>
                
                <div id="divUpdateInfo" runat="server" class="su-update-info" visible="false">
                    <h3>发现新版本</h3>
                    <div class="version">v<asp:Literal ID="litLatestVersion" runat="server"></asp:Literal></div>
                    <div class="changelog">
                        <strong>更新内容：</strong><br/>
                        <asp:Literal ID="litUpdateLog" runat="server"></asp:Literal>
                    </div>
                    <div style="margin-top:14px;font-size:12px;color:#64748b;">
                        <asp:HyperLink ID="lnkManualDownload" runat="server" Target="_blank" style="color:#3b82f6;text-decoration:underline;">手动下载更新包</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <!-- 使用说明 -->
        <div class="su-card">
            <div class="su-card-hd">
                <span class="ci amber"><svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></span>
                使用说明
            </div>
            <div class="su-card-bd">
                <ul class="su-notice">
                    <li>
                        <span class="ni s1">1</span>
                        点击「检查更新」按钮，系统将连接到更新服务器检查是否有新版本
                    </li>
                    <li>
                        <span class="ni s2">2</span>
                        如果有新版本，系统会显示更新内容和版本号
                    </li>
                    <li>
                        <span class="ni s3">3</span>
                        点击「立即更新」按钮，系统将自动下载并安装更新
                    </li>
                    <li class="ni-sep"></li>
                    <li>
                        <span class="ni warn"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                        更新前建议先在「数据备份」菜单中备份数据库
                    </li>
                    <li>
                        <span class="ni warn"><svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
                        更新过程中请勿关闭浏览器或刷新页面
                    </li>
                    <li>
                        <span class="ni tip"><svg viewBox="0 0 24 24"><path d="M9 18h6"/><path d="M10 22h4"/><path d="M15.09 14c.18-.98.65-1.74 1.41-2.5A4.65 4.65 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .23 2.23 1.5 3.5A4.61 4.61 0 0 1 8.91 14"/></svg></span>
                        如果自动更新失败，可以手动下载更新包解压后覆盖到网站目录
                    </li>
                </ul>
            </div>
        </div>
    </div>
</div>
                <!-- 发现新版本弹窗 -->
                <div id="suOverlay" class="su-overlay" onclick="if(event.target===this)suDlgClose()">
                    <div class="su-dialog">
                        <div class="su-dlg-hd">
                            <div class="su-dlg-chip">NEW VERSION AVAILABLE</div>
                            <div class="su-dlg-ver" id="suDlgVer"></div>
                            <div class="su-dlg-sub">发现系统新版本，建议及时更新以获取最新功能和安全修复</div>
                        </div>
                        <div class="su-dlg-bd">
                            <div class="su-dlg-log" id="suDlgLog">加载中…</div>
                        </div>
                        <div class="su-dlg-ft">
                            <button type="button" class="su-dlg-go" onclick="suDlgClose();setTimeout(function(){var hf=document.getElementById('<%= hdnDirectUrl.ClientID %>');if(hf&&!hf.value)hf.value='auto';var b=document.getElementById('<%= btnCheckUpdate.ClientID %>');if(b)b.click();},150);">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>
                                立即检查并更新
                            </button>
                            <button type="button" class="su-dlg-cancel" onclick="suDlgClose()">稍后再说</button>
                        </div>
                    </div>
                </div>

<script type="text/javascript">
function suDlgClose(){document.getElementById('suOverlay').classList.remove('show');}

(function(){
    var bar = document.getElementById('suAcBar');
    var btnId = '<%= btnCheckUpdate.ClientID %>';
    // postback 时不执行自动检测，避免更新操作进行中反复弹出对话框
    if (<%= IsPostBack ? "true" : "false" %>) { bar.style.display='none'; return; }

    function h(s){ var d=document.createElement('div');d.appendChild(document.createTextNode(s));return d.innerHTML; }

    function setOk(cur){
        bar.className='su-ac ok';
        bar.innerHTML='<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><polyline points="20 6 9 17 4 12"/></svg>'
            +'<span class="ac-msg">当前已是最新版本（'+h(cur)+'）</span>';
    }

    function setUpd(cur, ver, log, dlUrl){
        // 将 downloadUrl 存入隐藏字段，供「立即检查并更新」按钮使用
        // 若 version.json 未提供 downloadUrl，用 'auto' 作为非空标记，确保服务端能触发自动更新
        var hf = document.getElementById('<%= hdnDirectUrl.ClientID %>');
        if (hf) hf.value = dlUrl || 'auto';
        bar.className='su-ac upd';
        bar.style.cursor='pointer';
        bar.onclick=function(){var b=document.getElementById(btnId);if(b)b.click();};
        bar.innerHTML='<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>'
            +'<span class="ac-msg">检测到新版本&nbsp;<strong>'+h(ver)+'</strong>&nbsp;（当前&nbsp;'+h(cur)+'）</span>'
            +'<span class="su-new-tag">点击立即升级</span>';
        // 填充弹窗
        document.getElementById('suDlgVer').textContent = ver;
        var logEl = document.getElementById('suDlgLog');
        logEl.innerHTML = log ? log.replace(/\\n/g,'<br>').replace(/\n/g,'<br>') : '暂无更新说明';
        document.getElementById('suOverlay').classList.add('show');
    }

    function setErr(){
        bar.className='su-ac err';
        bar.innerHTML='<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>'
            +'<span class="ac-msg">自动检测暂时不可用，请手动点击「检查更新」</span>';
    }

    var xhr = new XMLHttpRequest();
    xhr.open('GET', '<%= ResolveUrl("~/manager/checkupdate.ashx") %>?_=' + Date.now(), true);
    xhr.timeout = 15000;
    xhr.onload = function(){
        if(xhr.status === 200){
            try{
                var r = JSON.parse(xhr.responseText);
                if(r && r.success){
                    if(r.hasUpdate) setUpd(r.currentVersion, r.latestVersion, r.changelog, r.downloadUrl || '');
                    else           setOk(r.currentVersion);
                    return;
                }
            }catch(e){}
        }
        setErr();
    };
    xhr.onerror = xhr.ontimeout = setErr;
    xhr.send();
}());
</script>

</asp:Content>

