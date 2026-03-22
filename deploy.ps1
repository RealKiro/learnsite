#Requires -Version 5.1
<#
.SYNOPSIS
    LearnSite 信息学习平台 — 一键自动部署脚本 v1.0

.DESCRIPTION
    自动完成 IIS 安装、网站部署、数据库初始化、管理员账号设置。
    必须以管理员身份运行。

.PARAMETER DbServer
    SQL Server 地址（默认 localhost）

.PARAMETER DbName
    数据库名称（默认 learnsite）

.PARAMETER DbUser
    数据库账号（默认 sa）

.PARAMETER DbPassword
    数据库 SA 密码（必填）

.PARAMETER AdminUser
    管理员账号（默认 admin）

.PARAMETER AdminPwd
    管理员密码（默认 12345）

.PARAMETER SitePath
    网站部署目录（默认 C:\inetpub\wwwroot\LearnSite）

.PARAMETER SiteName
    IIS 站点名称（默认 LearnSite）

.PARAMETER Port
    HTTP 端口（默认 80）

.PARAMETER SkipIIS
    跳过 IIS 安装/配置（IIS 已就绪时使用）

.PARAMETER SkipDB
    跳过数据库初始化（数据库已存在时使用）

.PARAMETER NoConfirm
    跳过确认提示，直接部署

.EXAMPLE
    .\deploy.ps1
    # 交互式输入所有参数

.EXAMPLE
    .\deploy.ps1 -DbPassword "MyPass123" -AdminPwd "Admin@2026"

.EXAMPLE
    .\deploy.ps1 -DbServer "192.168.1.100" -DbPassword "xx" -AdminPwd "xx" -Port 8080 -NoConfirm
#>

[CmdletBinding()]
param(
    [string]$DbServer   = "localhost",
    [string]$DbName     = "learnsite",
    [string]$DbUser     = "sa",
    [string]$DbPassword = "",
    [string]$AdminUser  = "admin",
    [string]$AdminPwd   = "",
    [string]$SitePath   = "",
    [string]$SiteName   = "LearnSite",
    [int]   $Port       = 80,
    [switch]$SkipIIS,
    [switch]$SkipDB,
    [switch]$NoConfirm
)

$ErrorActionPreference = "Stop"
$SourceDir = $PSScriptRoot

# ════════════════════════════════════════════════════════════════
# UI 辅助函数
# ════════════════════════════════════════════════════════════════

function Write-Banner {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║      LearnSite 信息学习平台  ·  一键部署向导  v1.0   ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step([int]$n, [string]$msg) {
    Write-Host ""
    Write-Host "  ─── 步骤 $n/6  $msg ───" -ForegroundColor Yellow
    Write-Host ""
}

function Write-OK  ([string]$m) { Write-Host "     ✓  $m" -ForegroundColor Green  }
function Write-Info([string]$m) { Write-Host "     →  $m" -ForegroundColor Cyan   }
function Write-Warn([string]$m) { Write-Host "     ⚠  $m" -ForegroundColor Yellow }
function Write-Fail([string]$m) { Write-Host "     ✗  $m" -ForegroundColor Red    }

function Read-SecureValue([string]$label) {
    Write-Host "     $label : " -ForegroundColor White -NoNewline
    $secure = Read-Host -AsSecureString
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}

function Read-Value([string]$label, [string]$default = "") {
    $hint = if ($default) { " [默认: $default]" } else { "" }
    Write-Host "     $label$hint : " -ForegroundColor White -NoNewline
    $val = Read-Host
    if ([string]::IsNullOrWhiteSpace($val)) { return $default }
    return $val
}

function Get-NormalizedPath([string]$path) {
    if ([string]::IsNullOrWhiteSpace($path)) { return "" }
    return [System.IO.Path]::GetFullPath($path).TrimEnd('\','/')
}

function Test-UrlRewriteInstalled {
    $rewriteDlls = @(
        "$env:SystemRoot\System32\inetsrv\rewrite.dll",
        "$env:SystemRoot\SysWOW64\inetsrv\rewrite.dll"
    )
    return ($rewriteDlls | Where-Object { Test-Path $_ } | Select-Object -First 1) -ne $null
}

function Get-LocalUrlRewriteInstaller {
    $patterns = @("rewrite_*.msi", "*url*rewrite*.msi", "*rewrite*.msi")
    foreach ($pattern in $patterns) {
        $match = Get-ChildItem -Path $SourceDir -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue |
            Sort-Object FullName |
            Select-Object -First 1
        if ($match) { return $match.FullName }
    }
    return ""
}

function Get-UrlRewriteDownloadUrl {
    $pageUrls = @(
        "https://www.iis.net/downloads/microsoft/url-rewrite",
        "https://learn.iis.net/downloads/microsoft/url-rewrite"
    )
    $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "x86" }
    $culture = ""
    try { $culture = (Get-Culture).Name } catch {}
    $preferredLocales = @($culture, "zh-CN", "en-US") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

    foreach ($pageUrl in $pageUrls) {
        try {
            Write-Info "正在解析 URL Rewrite 官方下载页..."
            $resp = Invoke-WebRequest -Uri $pageUrl -UseBasicParsing -ErrorAction Stop
            $content = [string]$resp.Content
            $urls = [regex]::Matches($content, 'https://download\.microsoft\.com/download/[^"''<>\s]+rewrite_(?:amd64|x86)_[A-Za-z]{2}-[A-Za-z]{2}\.msi') |
                ForEach-Object { $_.Value } |
                Select-Object -Unique

            if (-not $urls -or $urls.Count -eq 0) { continue }

            $archUrls = $urls | Where-Object { $_ -match "rewrite_${arch}_" }
            if (-not $archUrls -or $archUrls.Count -eq 0) { $archUrls = $urls }

            foreach ($locale in $preferredLocales) {
                $hit = $archUrls | Where-Object { $_ -match [regex]::Escape("_${locale}.msi") } | Select-Object -First 1
                if ($hit) { return $hit }
            }

            return ($archUrls | Select-Object -First 1)
        } catch {
            Write-Warn "下载页访问失败：$pageUrl"
        }
    }

    return ""
}

function Install-UrlRewriteModule {
    if (Test-UrlRewriteInstalled) {
        Write-OK "IIS URL Rewrite 模块已安装"
        return $true
    }

    Write-Info "检测到 URL Rewrite 未安装，开始自动安装..."

    $installerPath = Get-LocalUrlRewriteInstaller
    if ($installerPath) {
        Write-Info "使用本地安装包：$installerPath"
    } else {
        $downloadUrl = Get-UrlRewriteDownloadUrl
        if (-not $downloadUrl) {
            Write-Warn "未能解析到 URL Rewrite 官方安装包链接"
            Write-Warn "请手动下载：https://www.iis.net/downloads/microsoft/url-rewrite"
            return $false
        }

        $fileName = Split-Path $downloadUrl -Leaf
        if ([string]::IsNullOrWhiteSpace($fileName)) {
            $fileName = if ([Environment]::Is64BitOperatingSystem) { "rewrite_amd64.msi" } else { "rewrite_x86.msi" }
        }
        $installerPath = Join-Path $env:TEMP $fileName
        Write-Info "正在下载安装包：$downloadUrl"
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop
        } catch {
            Write-Warn "安装包下载失败：$($_.Exception.Message)"
            Write-Warn "请手动下载：https://www.iis.net/downloads/microsoft/url-rewrite"
            return $false
        }
    }

    if (-not (Test-Path $installerPath)) {
        Write-Warn "URL Rewrite 安装包不存在：$installerPath"
        return $false
    }

    Write-Info "正在静默安装 URL Rewrite 模块..."
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait -PassThru
    if ($proc.ExitCode -notin @(0, 1641, 3010)) {
        Write-Warn "URL Rewrite 安装返回代码：$($proc.ExitCode)"
        Write-Warn "请手动下载：https://www.iis.net/downloads/microsoft/url-rewrite"
        return $false
    }

    Start-Sleep -Seconds 2
    if (Test-UrlRewriteInstalled) {
        if ($proc.ExitCode -in @(1641, 3010)) {
            Write-Warn "URL Rewrite 已安装，系统提示可能需要重启后完全生效"
        } else {
            Write-OK "URL Rewrite 模块安装成功"
        }
        return $true
    }

    Write-Warn "URL Rewrite 安装结束，但未检测到 rewrite.dll"
    Write-Warn "请手动确认：https://www.iis.net/downloads/microsoft/url-rewrite"
    return $false
}

# ════════════════════════════════════════════════════════════════
# 管理员权限检查
# ════════════════════════════════════════════════════════════════

function Assert-AdminRights {
    $cur = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $cur.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Fail "请以管理员身份运行 PowerShell，再执行本脚本！"
        Write-Fail "右键 PowerShell 图标 → 以管理员身份运行"
        Write-Host ""
        exit 1
    }
    Write-OK "已确认管理员权限"
}

# ════════════════════════════════════════════════════════════════
# 交互式参数收集
# ════════════════════════════════════════════════════════════════

function Get-Config {
    Write-Host "  请填写部署参数（直接回车使用默认值）：" -ForegroundColor White
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "  【数据库配置】" -ForegroundColor Cyan
    $script:DbServer   = Read-Value  "  SQL Server 地址" $DbServer
    $script:DbName     = Read-Value  "  数据库名称"      $DbName
    $script:DbUser     = Read-Value  "  数据库账号"      $DbUser
    while ([string]::IsNullOrWhiteSpace($script:DbPassword)) {
        $script:DbPassword = Read-SecureValue "  数据库密码 *"
        if ([string]::IsNullOrWhiteSpace($script:DbPassword)) { Write-Fail "数据库密码不能为空" }
    }

    Write-Host ""
    Write-Host "  【管理员账号】" -ForegroundColor Cyan
    $script:AdminUser  = Read-Value  "  管理员账号"      $AdminUser
    $script:AdminPwd   = Read-SecureValue "  管理员密码（留空则为 12345）"
    if ([string]::IsNullOrWhiteSpace($script:AdminPwd)) { $script:AdminPwd = "12345" }

    Write-Host ""
    Write-Host "  【网站配置】" -ForegroundColor Cyan
    if (-not $script:SitePath) { $script:SitePath = "C:\inetpub\wwwroot\LearnSite" }
    $script:SitePath   = Read-Value  "  网站目录"        $SitePath
    $script:SiteName   = Read-Value  "  IIS 站点名称"    $SiteName
    $portStr           = Read-Value  "  HTTP 端口"        $Port.ToString()
    $script:Port       = [int]$portStr
}

# ════════════════════════════════════════════════════════════════
# 步骤 1 — IIS 功能安装
# ════════════════════════════════════════════════════════════════

function Install-IISFeatures {
    Write-Step 1 "安装 IIS 与 ASP.NET 组件"

    # 判断是服务器版还是客户端版
    $osType = (Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue).ProductType
    $isServer = ($osType -eq 2 -or $osType -eq 3)

    if ($isServer) {
        # Windows Server — 使用 Install-WindowsFeature
        try {
            Import-Module ServerManager -ErrorAction Stop
            $features = @(
                "Web-Server",
                "Web-Asp-Net",       # ASP.NET 2.0/3.5（CLR v2.0）
                "Web-Net-Ext",       # .NET 扩展 3.5
                "Web-ISAPI-Ext", "Web-ISAPI-Filter",
                "Web-Default-Doc", "Web-Static-Content",
                "Web-Http-Errors", "Web-Http-Logging"
            )
            foreach ($f in $features) {
                $r = Install-WindowsFeature -Name $f -ErrorAction SilentlyContinue
                if ($r -and $r.Success) { Write-OK "已安装: $f" }
                else                    { Write-OK "已存在: $f" }
            }
        } catch {
            Write-Warn "ServerManager 模块调用失败，请手动确认 IIS 已启用"
        }
    } else {
        # Windows 客户端 — 使用 Enable-WindowsOptionalFeature
        $features = @(
            "IIS-WebServerRole", "IIS-WebServer",
            "IIS-ASPNET",              # ASP.NET 2.0/3.5（CLR v2.0）
            "IIS-NetFxExtensibility",  # .NET 扩展 3.5
            "IIS-ISAPIExtensions", "IIS-ISAPIFilter",
            "IIS-DefaultDocument", "IIS-StaticContent",
            "IIS-HttpErrors", "IIS-HttpLogging",
            "NetFx3"                   # .NET 3.5（含 2.0/3.0）
        )
        foreach ($f in $features) {
            try {
                $state = (Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue).State
                if ($state -ne "Enabled") {
                    Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart -ErrorAction SilentlyContinue | Out-Null
                    Write-OK "已启用: $f"
                } else {
                    Write-OK "已存在: $f"
                }
            } catch {
                Write-Warn "跳过: $f"
            }
        }
    }

    if (-not (Install-UrlRewriteModule)) {
        Write-Warn "IIS URL Rewrite 模块仍未安装成功，无扩展名 URL 可能无法正常使用"
        Write-Warn "下载地址：https://www.iis.net/downloads/microsoft/url-rewrite"
    }
}

# ════════════════════════════════════════════════════════════════
# 步骤 2 — 复制网站文件
# ════════════════════════════════════════════════════════════════

function Deploy-Files {
    Write-Step 2 "部署网站文件"

    if (-not (Test-Path $SitePath)) {
        New-Item -ItemType Directory -Path $SitePath -Force | Out-Null
        Write-OK "已创建目录: $SitePath"
    } else {
        Write-OK "目录已存在: $SitePath"
    }

    $sourceFull = Get-NormalizedPath $SourceDir
    $siteFull   = Get-NormalizedPath $SitePath

    if ($sourceFull -eq $siteFull) {
        Write-Warn "部署目录与当前脚本目录相同，跳过文件复制，直接使用当前目录作为网站目录"
        Write-OK "当前目录已作为网站目录: $SitePath"
    } else {
        Write-Info "正在复制文件，请稍候..."
        $items = Get-ChildItem $SourceDir | Where-Object {
            $_.Name -ne "deploy.ps1" -and (Get-NormalizedPath $_.FullName) -ne $siteFull
        }
        $total = $items.Count
        $i = 0
        $copied = 0

        foreach ($item in $items) {
            $i++
            $dest = Join-Path $SitePath $item.Name
            $itemFull = Get-NormalizedPath $item.FullName
            $destFull = Get-NormalizedPath $dest
            if ($itemFull -eq $destFull) {
                Write-Warn "跳过自复制项: $($item.Name)"
                continue
            }

            if ($item.PSIsContainer) {
                Copy-Item $item.FullName $dest -Recurse -Force
            } else {
                Copy-Item $item.FullName $dest -Force
            }
            $copied++
            $pct = if ($total -gt 0) { [int](($i / $total) * 100) } else { 100 }
            Write-Progress -Activity "复制文件" -Status "$i / $total : $($item.Name)" -PercentComplete $pct
        }
        Write-Progress -Activity "复制文件" -Completed
        Write-OK "文件已复制至 $SitePath（共 $copied 项）"
    }

    # 设置权限
    Write-Info "配置文件夹权限..."
    $result = icacls $SitePath /grant "Everyone:(OI)(CI)M" /T /Q 2>&1
    Write-OK "已授予 Everyone 修改权限（IIS 写入作品/日志所必需）"
}

# ════════════════════════════════════════════════════════════════
# 步骤 3 — 配置 IIS 站点
# ════════════════════════════════════════════════════════════════

function New-IISSite {
    Write-Step 3 "配置 IIS 站点与 MIME 类型"

    try {
        Import-Module WebAdministration -ErrorAction Stop
    } catch {
        Write-Fail "WebAdministration 模块加载失败，IIS 可能未正确安装"
        throw
    }

    # 应用程序池
    if (-not (Test-Path "IIS:\AppPools\$SiteName")) {
        New-WebAppPool -Name $SiteName | Out-Null
        Write-OK "已创建应用程序池: $SiteName"
    } else {
        Write-OK "应用程序池已存在: $SiteName"
    }
    Set-ItemProperty "IIS:\AppPools\$SiteName" -Name managedRuntimeVersion -Value "v2.0"
    Set-ItemProperty "IIS:\AppPools\$SiteName" -Name managedPipelineMode   -Value 1  # 1 = Classic
    Write-OK "应用程序池: .NET CLR v2.0（经典模式）"

    # 网站
    if (Test-Path "IIS:\Sites\$SiteName") {
        Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath    -Value $SitePath
        Set-ItemProperty "IIS:\Sites\$SiteName" -Name applicationPool -Value $SiteName
        Write-OK "已更新站点配置: $SiteName"
    } else {
        New-WebSite -Name $SiteName -Port $Port -PhysicalPath $SitePath -ApplicationPool $SiteName | Out-Null
        Write-OK "已创建站点: $SiteName（端口 $Port）"
    }

    # 启动站点
    try { Start-WebSite -Name $SiteName -ErrorAction SilentlyContinue } catch {}
    Write-OK "IIS 站点已启动"

    # MIME 类型
    Write-Info "添加 MIME 类型..."
    $mimes = [ordered]@{
        ".sb3"  = "application/octet-stream"
        ".py"   = "text/plain"
        ".woff2"= "application/font-woff2"
        ".woff" = "application/font-woff"
        ".mp4"  = "video/mp4"
        ".ogg"  = "audio/ogg"
        ".svg"  = "image/svg+xml"
        ".webp" = "image/webp"
        ".bin"  = "application/octet-stream"
        ".dms"  = "application/octet-stream"
        "."     = "application/octet-stream"
    }
    foreach ($ext in $mimes.Keys) {
        try {
            Add-WebConfigurationProperty `
                -PSPath "IIS:\Sites\$SiteName" `
                -Filter "system.webServer/staticContent" `
                -Name "." `
                -Value @{ fileExtension = $ext; mimeType = $mimes[$ext] } `
                -ErrorAction SilentlyContinue | Out-Null
        } catch {
            # 已存在则忽略
        }
    }
    Write-OK "已添加 $($mimes.Count) 种 MIME 类型"
}

# ════════════════════════════════════════════════════════════════
# 步骤 4 — 更新 web.config
# ════════════════════════════════════════════════════════════════

function Update-WebConfig {
    Write-Step 4 "更新数据库连接字符串"

    $configPath = Join-Path $SitePath "web.config"
    $tempDir    = Join-Path $SitePath "App_Data\Temp"
    if (-not (Test-Path $configPath)) {
        Write-Fail "web.config 不存在: $configPath"
        throw "web.config missing"
    }

    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Write-OK "已创建编译临时目录: $tempDir"
    }

    [xml]$xml  = Get-Content $configPath -Encoding UTF8
    $node = $xml.configuration.connectionStrings.add |
            Where-Object { $_.name -eq "SqlServer" }
    $compilationNode = $xml.configuration.'system.web'.compilation

    if ($node) {
        $node.connectionString = "Data Source=$DbServer;Initial Catalog=$DbName;uid=$DbUser;pwd=$DbPassword;"
        Write-OK "连接字符串已更新: $DbServer > $DbName"
    } else {
        Write-Warn "未在 web.config 中找到 SqlServer 节点，请手动检查"
    }

    if (-not $compilationNode) {
        $systemWebNode = $xml.configuration.'system.web'
        if (-not $systemWebNode) {
            $systemWebNode = $xml.CreateElement("system.web")
            [void]$xml.configuration.AppendChild($systemWebNode)
        }

        $compilationNode = $xml.CreateElement("compilation")
        $debugAttr = $xml.CreateAttribute("debug")
        $debugAttr.Value = "false"
        [void]$compilationNode.Attributes.Append($debugAttr)
        [void]$systemWebNode.AppendChild($compilationNode)
    }

    $tempAttr = $compilationNode.Attributes["tempDirectory"]
    if (-not $tempAttr) {
        $tempAttr = $xml.CreateAttribute("tempDirectory")
        [void]$compilationNode.Attributes.Append($tempAttr)
    }
    $tempAttr.Value = $tempDir
    Write-OK "编译临时目录已更新: $tempDir"

    $xml.Save($configPath)
}

# ════════════════════════════════════════════════════════════════
# 步骤 5 — 初始化数据库
# ════════════════════════════════════════════════════════════════

function Get-SqlConn([string]$Database = "") {
    Add-Type -AssemblyName System.Data
    $cs = "Server=$DbServer;User ID=$DbUser;Password=$DbPassword;Connect Timeout=15;Encrypt=False;"
    if ($Database) { $cs += "Database=$Database;" }
    $c = New-Object System.Data.SqlClient.SqlConnection $cs
    $c.Open()
    return $c
}

function Invoke-SqlScript(
    [System.Data.SqlClient.SqlConnection]$Conn,
    [string]$Path,
    [string]$FileEncoding = "Default"
) {
    if (-not (Test-Path $Path)) { Write-Warn "脚本不存在，已跳过: $Path"; return }

    $raw = if ($FileEncoding -eq "Unicode") {
        Get-Content $Path -Encoding Unicode -Raw
    } else {
        Get-Content $Path -Encoding UTF8 -Raw
    }
    if (-not $raw) { $raw = Get-Content $Path -Raw }

    # 按 GO 分割批次（忽略大小写、允许前后有空白）
    $batches = [regex]::Split($raw.Trim(), '(?m)^\s*GO\s*$',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    $cmd = $Conn.CreateCommand()
    $cmd.CommandTimeout = 300
    $warns = 0

    foreach ($b in $batches) {
        $b = $b.Trim()
        if ($b.Length -eq 0) { continue }
        try {
            $cmd.CommandText = $b
            $cmd.ExecuteNonQuery() | Out-Null
        } catch {
            $msg = $_.Exception.Message
            # 忽略"已存在"类错误（幂等脚本正常现象）
            $isHarmless = $msg -match "already exists|Column names in each table must be unique|There is already an object named|Duplicate column|object already exist"
            if (-not $isHarmless) {
                $warns++
                if ($warns -le 5) { Write-Warn "  SQL: $($msg.Split("`n")[0])" }
            }
        }
    }
    if ($warns -gt 0) { Write-Warn "  共 $warns 处 SQL 警告（通常是重复执行导致，可忽略）" }
}

function Get-PasswordHash([string]$Password, [string]$Salt) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Password + $Salt)
    $md5   = [System.Security.Cryptography.MD5]::Create()
    return ($md5.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""
}

function New-RandomSalt {
    $bytes = New-Object byte[] 16
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $rng.GetBytes($bytes)
    return [Convert]::ToBase64String($bytes)
}

function Test-ColumnExists(
    [System.Data.SqlClient.SqlConnection]$Conn,
    [string]$TableName,
    [string]$ColumnName
) {
    $cmd = $Conn.CreateCommand()
    $cmd.CommandText = @"
SELECT COUNT(1)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table AND COLUMN_NAME = @column
"@
    $cmd.Parameters.AddWithValue("@table", $TableName) | Out-Null
    $cmd.Parameters.AddWithValue("@column", $ColumnName) | Out-Null
    return ([int]$cmd.ExecuteScalar()) -gt 0
}

function Ensure-AdminTeacherAccount(
    [System.Data.SqlClient.SqlConnection]$Conn,
    [string]$TargetAdminUser,
    [string]$TargetAdminPwd
) {
    $hasSaltColumn = Test-ColumnExists -Conn $Conn -TableName "Teacher" -ColumnName "Hsalt"
    $salt = if ($hasSaltColumn) { New-RandomSalt } else { "" }
    $passwordValue = if ($hasSaltColumn) { Get-PasswordHash $TargetAdminPwd $salt } else { $TargetAdminPwd }

    $findCmd = $Conn.CreateCommand()
    $findCmd.CommandText = "SELECT TOP 1 Hid FROM Teacher WHERE Hname=@name ORDER BY Hid ASC"
    $findCmd.Parameters.AddWithValue("@name", $TargetAdminUser) | Out-Null
    $existingId = $findCmd.ExecuteScalar()

    if ($existingId -ne $null -and $existingId -ne [DBNull]::Value) {
        $updateCmd = $Conn.CreateCommand()
        if ($hasSaltColumn) {
            $updateCmd.CommandText = @"
UPDATE Teacher
SET Hname=@name,
    Hpwd=@pwd,
    Hsalt=@salt,
    Hpermiss=1,
    Hdelete=0,
    Hnote=CASE WHEN ISNULL(Hnote,'')='' THEN N'管理员' ELSE Hnote END,
    Hnick=CASE WHEN ISNULL(Hnick,'')='' THEN @name ELSE Hnick END
WHERE Hid=@hid
"@
            $updateCmd.Parameters.AddWithValue("@salt", $salt) | Out-Null
        } else {
            $updateCmd.CommandText = @"
UPDATE Teacher
SET Hname=@name,
    Hpwd=@pwd,
    Hpermiss=1,
    Hdelete=0,
    Hnote=CASE WHEN ISNULL(Hnote,'')='' THEN N'管理员' ELSE Hnote END,
    Hnick=CASE WHEN ISNULL(Hnick,'')='' THEN @name ELSE Hnick END
WHERE Hid=@hid
"@
        }
        $updateCmd.Parameters.AddWithValue("@name", $TargetAdminUser) | Out-Null
        $updateCmd.Parameters.AddWithValue("@pwd", $passwordValue) | Out-Null
        $updateCmd.Parameters.AddWithValue("@hid", [int]$existingId) | Out-Null
        [void]$updateCmd.ExecuteNonQuery()
        return "updated-existing"
    }

    $legacyCmd = $Conn.CreateCommand()
    $legacyCmd.CommandText = "SELECT TOP 1 Hid FROM Teacher WHERE Hname=N'admin' ORDER BY Hid ASC"
    $legacyId = $legacyCmd.ExecuteScalar()

    if ($legacyId -ne $null -and $legacyId -ne [DBNull]::Value) {
        $renameCmd = $Conn.CreateCommand()
        if ($hasSaltColumn) {
            $renameCmd.CommandText = @"
UPDATE Teacher
SET Hname=@name,
    Hpwd=@pwd,
    Hsalt=@salt,
    Hpermiss=1,
    Hdelete=0,
    Hnote=N'管理员',
    Hnick=@name
WHERE Hid=@hid
"@
            $renameCmd.Parameters.AddWithValue("@salt", $salt) | Out-Null
        } else {
            $renameCmd.CommandText = @"
UPDATE Teacher
SET Hname=@name,
    Hpwd=@pwd,
    Hpermiss=1,
    Hdelete=0,
    Hnote=N'管理员',
    Hnick=@name
WHERE Hid=@hid
"@
        }
        $renameCmd.Parameters.AddWithValue("@name", $TargetAdminUser) | Out-Null
        $renameCmd.Parameters.AddWithValue("@pwd", $passwordValue) | Out-Null
        $renameCmd.Parameters.AddWithValue("@hid", [int]$legacyId) | Out-Null
        [void]$renameCmd.ExecuteNonQuery()
        return "renamed-default-admin"
    }

    $insertCmd = $Conn.CreateCommand()
    if ($hasSaltColumn) {
        $insertCmd.CommandText = @"
INSERT INTO Teacher (Hname, Hpwd, Hsalt, Hpermiss, Hnote, Hdelete, Hcount, Hnick, Hroom)
VALUES (@name, @pwd, @salt, 1, N'管理员', 0, 0, @name, N'')
"@
        $insertCmd.Parameters.AddWithValue("@salt", $salt) | Out-Null
    } else {
        $insertCmd.CommandText = @"
INSERT INTO Teacher (Hname, Hpwd, Hpermiss, Hnote, Hdelete, Hcount, Hnick, Hroom)
VALUES (@name, @pwd, 1, N'管理员', 0, 0, @name, N'')
"@
    }
    $insertCmd.Parameters.AddWithValue("@name", $TargetAdminUser) | Out-Null
    $insertCmd.Parameters.AddWithValue("@pwd", $passwordValue) | Out-Null
    [void]$insertCmd.ExecuteNonQuery()
    return "inserted-new-admin"
}

function Initialize-Database {
    Write-Step 5 "初始化数据库"

    # 测试连接
    Write-Info "连接 SQL Server: $DbServer ..."
    try {
        $master = Get-SqlConn
        Write-OK "SQL Server 连接成功"
    } catch {
        Write-Fail "连接失败：$($_.Exception.Message)"
        Write-Warn "请确认："
        Write-Warn "  1) SQL Server 服务正在运行"
        Write-Warn "  2) 已开启混合验证（SA 登录）"
        Write-Warn "  3) SA 密码正确"
        Write-Warn "  4) 防火墙开放 1433 端口（跨机器部署时）"
        throw
    }

    # 创建数据库
    try {
        $cmd = $master.CreateCommand()
        $cmd.CommandText = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'$DbName')
BEGIN
    CREATE DATABASE [$DbName] COLLATE Chinese_PRC_CI_AS
    PRINT 'Database created'
END
ELSE
    PRINT 'Database already exists'
"@
        $cmd.ExecuteNonQuery() | Out-Null
        Write-OK "数据库: $DbName"
    } catch {
        Write-Fail "创建数据库失败: $($_.Exception.Message)"
        $master.Close()
        throw
    }
    $master.Close()

    # 连接目标数据库
    $db = Get-SqlConn -Database $DbName

    # 执行主初始化脚本
    $sqlDir = Join-Path $SitePath "sql"
    Write-Info "执行主初始化脚本: learnsite.sql ..."
    Invoke-SqlScript -Conn $db -Path (Join-Path $sqlDir "learnsite.sql") -FileEncoding "Unicode"
    Write-OK "主脚本执行完成"

    # 执行升级脚本（均为幂等，按需顺序执行）
    $upgrades = @(
        "upgrade_password_encryption.sql",
        "upgrade_badge.sql",
        "upgrade_profile_email.sql",
        "upgrade_teacher_profile.sql",
        "add_semail_column.sql",
        "add_room_ai_discuss_columns.sql",
        "add_questionbank_option_images.sql",
        "create_attitudetype.sql",
        "fix_badge_points.sql"
    )
    foreach ($s in $upgrades) {
        $p = Join-Path $sqlDir $s
        if (Test-Path $p) {
            Write-Info "升级脚本: $s"
            Invoke-SqlScript -Conn $db -Path $p
        }
    }
    Write-OK "升级脚本全部执行完成"

    # 设置或创建管理员账号
    Write-Info "配置管理员账号 ($AdminUser)..."
    try {
        $adminResult = Ensure-AdminTeacherAccount -Conn $db -TargetAdminUser $AdminUser -TargetAdminPwd $AdminPwd
        switch ($adminResult) {
            "updated-existing" {
                Write-OK "管理员账号已更新并写入密码"
            }
            "renamed-default-admin" {
                Write-OK "默认 admin 账号已迁移为 '$AdminUser' 并写入密码"
            }
            "inserted-new-admin" {
                Write-OK "已创建管理员账号 '$AdminUser' 并写入密码"
            }
            default {
                Write-Warn "管理员账号处理结果未知：$adminResult"
            }
        }
    } catch {
        Write-Warn "管理员账号写入失败: $($_.Exception.Message)"
    }

    $db.Close()
}

# ════════════════════════════════════════════════════════════════
# 步骤 6 — 完成，输出汇总
# ════════════════════════════════════════════════════════════════

function Show-Summary {
    # 尝试获取本机内网 IP
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
           Where-Object { $_.IPAddress -notmatch "^127\." -and $_.PrefixOrigin -ne "WellKnown" } |
           Select-Object -First 1).IPAddress
    if (-not $ip) { $ip = "服务器IP" }

    $portSuffix = if ($Port -eq 80) { "" } else { ":$Port" }

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║        ✓  部署完成！LearnSite 信息学习平台已就绪        ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  访问地址" -ForegroundColor White
    Write-Host "  ──────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "    学生端   ：http://$ip$portSuffix/" -ForegroundColor Cyan
    Write-Host "    教师端   ：http://$ip$portSuffix/teacher/" -ForegroundColor Cyan
    Write-Host "    管理后台 ：http://$ip$portSuffix/manager/login.aspx" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  管理员登录" -ForegroundColor White
    Write-Host "  ──────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "    账号：$AdminUser" -ForegroundColor White
    if ($AdminPwd -eq "12345") {
        Write-Host "    密码：12345  ← 请登录后立即修改！" -ForegroundColor Yellow
    } else {
        Write-Host "    密码：（您设置的密码）" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  部署路径：$SitePath" -ForegroundColor DarkGray
    Write-Host "  数据库  ：$DbServer → $DbName" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  如遇问题，请查阅 说明必读\ 目录或加入 QQ 群：565444740" -ForegroundColor DarkGray
    Write-Host ""
}

# ════════════════════════════════════════════════════════════════
# 主流程
# ════════════════════════════════════════════════════════════════

Write-Banner
Assert-AdminRights

# 交互式收集（参数未填写时）
if (-not $DbPassword -or -not $AdminPwd) {
    Get-Config
}
if (-not $SitePath) { $SitePath = "C:\inetpub\wwwroot\LearnSite" }

# 确认部署
if (-not $NoConfirm) {
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │  部署配置确认                                       │" -ForegroundColor White
    Write-Host "  │                                                     │" -ForegroundColor DarkGray
    Write-Host "  │  网站目录  : $($SitePath.PadRight(35))│" -ForegroundColor White
    Write-Host "  │  HTTP 端口 : $("$Port ($SiteName)".PadRight(35))│" -ForegroundColor White
    Write-Host "  │  SQL Server: $("$DbServer / $DbName".PadRight(35))│" -ForegroundColor White
    Write-Host "  │  管理员    : $($AdminUser.PadRight(35))│" -ForegroundColor White
    Write-Host "  └─────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    $confirm = Read-Host "  确认开始部署？(Y/n)"
    if ($confirm -match "^[nN]") {
        Write-Warn "已取消部署。"
        exit 0
    }
}

try {
    if (-not $SkipIIS) { Install-IISFeatures }
                         Deploy-Files
    if (-not $SkipIIS) { New-IISSite }
                         Update-WebConfig
    if (-not $SkipDB)  { Initialize-Database }

    Write-Step 6 "部署完成"
    Show-Summary
} catch {
    Write-Host ""
    Write-Fail "部署失败：$($_.Exception.Message)"
    Write-Fail "请根据上方提示检查配置，或查阅 说明必读\ 目录中的文档"
    Write-Host ""
    exit 1
}
