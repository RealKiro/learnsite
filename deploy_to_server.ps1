# LearnSite 更新部署脚本
# 自动打包并部署到更新服务器

param(
    [Parameter(Mandatory=$false)]
    [string]$version = "",
    
    [Parameter(Mandatory=$false)]
    [string]$serverPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$serverUrl = "http://ls.lequw.net/manager/updates/learnsite"
)

$ErrorActionPreference = "Stop"

Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  LearnSite 更新部署工具" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 步骤 1：打包更新文件
Write-Host "[1/4] 打包更新文件..." -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray

if (!(Test-Path "build_update.ps1")) {
    Write-Host "错误：找不到 build_update.ps1 脚本" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($version)) {
    & .\build_update.ps1
} else {
    & .\build_update.ps1 -version $version
}

# 从 changelog.xml 读取版本号（如果未指定）
if ([string]::IsNullOrEmpty($version)) {
    if (Test-Path "changelog.xml") {
        [xml]$changelog = Get-Content "changelog.xml"
        $version = $changelog.changelog.version[0].ver
    } else {
        Write-Host "错误：无法确定版本号" -ForegroundColor Red
        exit 1
    }
}

$zipFile = ".\$version.zip"
if (!(Test-Path $zipFile)) {
    Write-Host "错误：打包失败，找不到 $zipFile" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 步骤 2：配置服务器路径
Write-Host "[2/4] 配置服务器路径..." -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray

if ([string]::IsNullOrEmpty($serverPath)) {
    Write-Host "请输入服务器路径（留空跳过自动上传）：" -ForegroundColor Yellow
    Write-Host "示例：\\ls.lequw.net\updates\learnsite" -ForegroundColor Gray
    Write-Host "或：C:\inetpub\wwwroot\manager\updates\learnsite" -ForegroundColor Gray
    $serverPath = Read-Host "服务器路径"
}

if ([string]::IsNullOrEmpty($serverPath)) {
    Write-Host "跳过自动上传，请手动上传文件" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  手动部署步骤" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 上传文件到服务器：" -ForegroundColor White
    Write-Host "   $zipFile" -ForegroundColor Cyan
    Write-Host "   → $serverUrl/$version.zip" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. 更新 version.json 文件：" -ForegroundColor White
    Write-Host "   使用 version.json.new 的内容" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. 测试访问：" -ForegroundColor White
    Write-Host "   $serverUrl/version.json" -ForegroundColor Cyan
    Write-Host "   $serverUrl/$version.zip" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host "服务器路径：$serverPath" -ForegroundColor Cyan
Write-Host ""

# 步骤 3：上传文件
Write-Host "[3/4] 上传文件到服务器..." -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray

# 检查服务器路径是否存在
if (!(Test-Path $serverPath)) {
    Write-Host "警告：服务器路径不存在，尝试创建..." -ForegroundColor Yellow
    try {
        New-Item -ItemType Directory -Path $serverPath -Force | Out-Null
        Write-Host "✓ 已创建服务器目录" -ForegroundColor Green
    } catch {
        Write-Host "错误：无法创建服务器目录" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# 上传 ZIP 文件
try {
    Write-Host "正在上传 $version.zip..." -ForegroundColor Gray
    Copy-Item $zipFile -Destination "$serverPath\$version.zip" -Force
    Write-Host "✓ 已上传 ZIP 文件" -ForegroundColor Green
} catch {
    Write-Host "错误：上传 ZIP 文件失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 上传 version.json
if (Test-Path "version.json.new") {
    try {
        Write-Host "正在更新 version.json..." -ForegroundColor Gray
        Copy-Item "version.json.new" -Destination "$serverPath\version.json" -Force
        Write-Host "✓ 已更新 version.json" -ForegroundColor Green
    } catch {
        Write-Host "警告：更新 version.json 失败" -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
} else {
    Write-Host "警告：找不到 version.json.new，请手动更新 version.json" -ForegroundColor Yellow
}

Write-Host ""

# 步骤 4：验证部署
Write-Host "[4/4] 验证部署..." -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray

$deployedZip = "$serverPath\$version.zip"
$deployedJson = "$serverPath\version.json"

$allOk = $true

if (Test-Path $deployedZip) {
    $size = (Get-Item $deployedZip).Length / 1KB
    Write-Host "✓ ZIP 文件已部署 ($([math]::Round($size, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "✗ ZIP 文件未找到" -ForegroundColor Red
    $allOk = $false
}

if (Test-Path $deployedJson) {
    Write-Host "✓ version.json 已部署" -ForegroundColor Green
    
    # 验证 JSON 格式
    try {
        $jsonContent = Get-Content $deployedJson -Raw | ConvertFrom-Json
        if ($jsonContent.version -eq $version) {
            Write-Host "✓ 版本号匹配：$version" -ForegroundColor Green
        } else {
            Write-Host "✗ 版本号不匹配：期望 $version，实际 $($jsonContent.version)" -ForegroundColor Red
            $allOk = $false
        }
    } catch {
        Write-Host "✗ JSON 格式错误" -ForegroundColor Red
        $allOk = $false
    }
} else {
    Write-Host "✗ version.json 未找到" -ForegroundColor Red
    $allOk = $false
}

Write-Host ""

# 显示结果
if ($allOk) {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  部署成功！" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "更新地址：" -ForegroundColor White
    Write-Host "  $serverUrl/version.json" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "下载地址：" -ForegroundColor White
    Write-Host "  $serverUrl/$version.zip" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor White
    Write-Host "  1. 在浏览器中测试上述地址是否可访问" -ForegroundColor Gray
    Write-Host "  2. 在客户端配置更新服务器地址" -ForegroundColor Gray
    Write-Host "  3. 点击「检查更新」按钮测试" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  部署失败！" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查：" -ForegroundColor White
    Write-Host "  1. 服务器路径是否正确" -ForegroundColor Gray
    Write-Host "  2. 是否有写入权限" -ForegroundColor Gray
    Write-Host "  3. 文件是否被占用" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# 清理本地临时文件（可选）
Write-Host "是否清理本地临时文件？(Y/N)" -ForegroundColor Yellow
$cleanup = Read-Host
if ($cleanup -eq "Y" -or $cleanup -eq "y") {
    if (Test-Path $zipFile) {
        Remove-Item $zipFile -Force
        Write-Host "✓ 已删除 $zipFile" -ForegroundColor Green
    }
    if (Test-Path "version.json.new") {
        Remove-Item "version.json.new" -Force
        Write-Host "✓ 已删除 version.json.new" -ForegroundColor Green
    }
    Write-Host ""
}

Write-Host "部署完成！`n" -ForegroundColor Green
