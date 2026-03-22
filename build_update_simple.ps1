# LearnSite Update Package Builder - Simple Version
# No Chinese characters to avoid encoding issues
# Usage: .\build_update_simple.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$version = ""
)

$ErrorActionPreference = "Stop"

# Read version from changelog.xml
if ([string]::IsNullOrEmpty($version)) {
    if (Test-Path "changelog.xml") {
        try {
            $changelog = New-Object System.Xml.XmlDocument
            $changelog.Load((Resolve-Path "changelog.xml"))
            $version = $changelog.changelog.version[0].ver
            Write-Host "Version: $version" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Failed to parse changelog.xml - $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "ERROR: changelog.xml not found" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n=== LearnSite Update Builder ===" -ForegroundColor Cyan
Write-Host "Version: $version" -ForegroundColor White
Write-Host "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "================================`n" -ForegroundColor Cyan

# Create temp directory
$tempDir = ".\temp_update_$version"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Files to package
$files = @(
    "teacher\questionbank.aspx",
    "manager\systemupdate.aspx",
    "manager\update-builder.aspx",
    "manager\update-deploy-guide.html",
    "sql\add_questionbank_option_images.sql",
    "sql\add_questionbank_link_field.sql",
    "sql\add_semail_column.sql",
    "changelog.xml",
    "README.md"
)

Write-Host "Copying files..." -ForegroundColor Green
$copiedCount = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        $destDir = Join-Path $tempDir (Split-Path $file -Parent)
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $file -Destination (Join-Path $tempDir $file) -Force
        Write-Host "  [OK] $file" -ForegroundColor Gray
        $copiedCount++
    }
}

Write-Host "`nCopied: $copiedCount files" -ForegroundColor Green

# Create ZIP
Write-Host "`nCreating ZIP..." -ForegroundColor Green
$zipFile = ".\$version.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# Try .NET Framework first
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFile, 'Optimal', $false)
    Write-Host "[OK] .NET Framework compression" -ForegroundColor Green
} catch {
    # Fallback to PowerShell
    try {
        Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFile -Force
        Write-Host "[OK] PowerShell compression" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Compression failed" -ForegroundColor Red
        exit 1
    }
}

# Clean temp
Remove-Item $tempDir -Recurse -Force

# Results
$fileInfo = Get-Item $zipFile
$fileSize = $fileInfo.Length / 1MB

Write-Host "`n=== Package Complete ===" -ForegroundColor Green
Write-Host "File: $($fileInfo.Name)" -ForegroundColor Cyan
Write-Host "Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Cyan

# MD5
$md5 = (Get-FileHash $zipFile -Algorithm MD5).Hash
Write-Host "MD5: $md5" -ForegroundColor Cyan

# Generate version.json
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
        # Ignore errors
    }
}

$versionJson = @"
{
  "version": "$version",
  "changelog": "$changelogText",
  "downloadUrl": "http://ls.lequw.net/manager/updates/learnsite/$version.zip",
  "releaseDate": "$(Get-Date -Format 'yyyy-MM-dd')",
  "fileSize": "$([math]::Round($fileSize, 2)) MB",
  "md5": "$md5"
}
"@

Write-Host "`n=== version.json ===" -ForegroundColor Yellow
Write-Host $versionJson -ForegroundColor White

$versionJson | Out-File ".\version.json.new" -Encoding UTF8 -Force
Write-Host "`nSaved to: version.json.new" -ForegroundColor Green

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Upload $version.zip to server" -ForegroundColor White
Write-Host "2. Update version.json on server" -ForegroundColor White
Write-Host "3. Test update on client`n" -ForegroundColor White
