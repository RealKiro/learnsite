# LearnSite 更新包打包脚本
# 使用方法：.\build_update.ps1 -version "v2026.3.2-3"

param(
    [Parameter(Mandatory=$false)]
    [string]$version = ""
)

$ErrorActionPreference = "Stop"

# 如果没有指定版本号，从 changelog.xml 读取
if ([string]::IsNullOrEmpty($version)) {
    Write-Host "未指定版本号，正在从 changelog.xml 读取..." -ForegroundColor Yellow
    
    if (Test-Path "changelog.xml") {
        try {
            $changelog = New-Object System.Xml.XmlDocument
            $changelog.Load((Resolve-Path "changelog.xml"))
            $latestVersion = $changelog.changelog.version[0].ver
            if (![string]::IsNullOrEmpty($latestVersion)) {
                $version = $latestVersion
                Write-Host "读取到版本号：$version" -ForegroundColor Green
            } else {
                Write-Host "错误：无法从 changelog.xml 读取版本号" -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "错误：解析 changelog.xml 失败 - $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "错误：changelog.xml 文件不存在" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  LearnSite 更新包打包工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "版本：$version" -ForegroundColor White
Write-Host "时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# 创建临时目录
$tempDir = ".\temp_update_$version"
if (Test-Path $tempDir) {
    Write-Host "清理旧的临时目录..." -ForegroundColor Gray
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# 定义需要打包的文件列表
# 根据实际修改的文件调整此列表
$files = @(
    # 教师端文件
    "teacher\questionbank.aspx",
    
    # 管理端文件
    "manager\systemupdate.aspx",
    
    # SQL 脚本
    "sql\add_questionbank_option_images.sql",
    "sql\add_questionbank_link_field.sql",
    "sql\add_semail_column.sql",
    
    # 文档文件
    "changelog.xml",
    "README.md"
)

Write-Host "正在复制文件..." -ForegroundColor Green
$copiedCount = 0
$skippedCount = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        $destDir = Join-Path $tempDir (Split-Path $file -Parent)
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $file -Destination (Join-Path $tempDir $file) -Force
        Write-Host "  ✓ $file" -ForegroundColor Gray
        $copiedCount++
    } else {
        Write-Host "  ✗ $file (文件不存在，跳过)" -ForegroundColor Yellow
        $skippedCount++
    }
}

Write-Host "`n文件统计：" -ForegroundColor Cyan
Write-Host "  已复制：$copiedCount 个文件" -ForegroundColor Green
if ($skippedCount -gt 0) {
    Write-Host "  已跳过：$skippedCount 个文件" -ForegroundColor Yellow
}

# 创建 ZIP 文件
Write-Host "`n正在创建 ZIP 文件..." -ForegroundColor Green
$zipFile = ".\$version.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFile -Force

# 清理临时目录
Write-Host "正在清理临时文件..." -ForegroundColor Gray
Remove-Item $tempDir -Recurse -Force

# 显示结果
$fileInfo = Get-Item $zipFile
$fileSize = $fileInfo.Length / 1MB
$fileSizeKB = $fileInfo.Length / 1KB

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  打包完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "文件名：$($fileInfo.Name)" -ForegroundColor Cyan
Write-Host "路径：$($fileInfo.FullName)" -ForegroundColor Cyan

if ($fileSize -ge 1) {
    Write-Host "大小：$([math]::Round($fileSize, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "大小：$([math]::Round($fileSizeKB, 2)) KB" -ForegroundColor Cyan
}

# 计算 MD5
Write-Host "`n正在计算 MD5..." -ForegroundColor Gray
$md5 = (Get-FileHash $zipFile -Algorithm MD5).Hash
Write-Host "MD5：$md5" -ForegroundColor Cyan

# 生成 version.json 内容建议
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  version.json 配置建议" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# 从 changelog.xml 读取更新日志
$changelogText = ""
if (Test-Path "changelog.xml") {
    try {
        $changelog = New-Object System.Xml.XmlDocument
        $changelog.Load((Resolve-Path "changelog.xml"))
        $versionNode = $changelog.changelog.version | Where-Object { $_.ver -eq $version } | Select-Object -First 1
        if ($versionNode) {
            $items = $versionNode.item
            if ($items) {
                $changelogLines = @()
                $index = 1
                foreach ($item in $items) {
                    $changelogLines += "$index. $($item.'#text')"
                    $index++
                }
                $changelogText = $changelogLines -join "\n"
            }
        }
    } catch {
        Write-Host "警告：无法读取 changelog.xml 中的更新日志" -ForegroundColor Yellow
    }
}

if ([string]::IsNullOrEmpty($changelogText)) {
    $changelogText = "1. 系统更新\n2. Bug修复\n3. 性能优化"
}

$versionJsonSample = @"
{
  "version": "$version",
  "changelog": "$changelogText",
  "downloadUrl": "http://ls.lequw.net/manager/updates/learnsite/$version.zip",
  "releaseDate": "$(Get-Date -Format 'yyyy-MM-dd')",
  "minVersion": "v2026.1.0",
  "fileSize": "$([math]::Round($fileSize, 2)) MB",
  "md5": "$md5"
}
"@

Write-Host $versionJsonSample -ForegroundColor White

# 保存到文件
$versionJsonFile = ".\version.json.new"
$versionJsonSample | Out-File $versionJsonFile -Encoding UTF8 -Force
Write-Host "`n已保存到：$versionJsonFile" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  下一步操作" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. 将 $version.zip 上传到更新服务器" -ForegroundColor White
Write-Host "2. 更新服务器上的 version.json 文件" -ForegroundColor White
Write-Host "3. 在客户端测试更新功能" -ForegroundColor White
Write-Host "`n详细说明请查看：manager\在线更新部署指南.md`n" -ForegroundColor Gray
