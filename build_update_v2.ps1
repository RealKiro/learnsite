# LearnSite Update Package Builder V2
# Multi-method compression support
# Usage: .\build_update_v2.ps1 -version "v2026.3.2-7"

param(
    [Parameter(Mandatory=$false)]
    [string]$version = "",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Auto", "DotNet", "PowerShell", "SevenZip", "WinRAR")]
    [string]$method = "Auto"
)

$ErrorActionPreference = "Stop"

# Read version from changelog.xml if not specified
if ([string]::IsNullOrEmpty($version)) {
    Write-Host "Version not specified, reading from changelog.xml..." -ForegroundColor Yellow
    
    if (Test-Path "changelog.xml") {
        try {
            $changelog = New-Object System.Xml.XmlDocument
            $changelog.Load((Resolve-Path "changelog.xml"))
            $latestVersion = $changelog.changelog.version[0].ver
            if (![string]::IsNullOrEmpty($latestVersion)) {
                $version = $latestVersion
                Write-Host "Version found: $version" -ForegroundColor Green
            } else {
                Write-Host "ERROR: Cannot read version from changelog.xml" -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "ERROR: Failed to parse changelog.xml - $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "ERROR: changelog.xml not found" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n" -NoNewline
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  LearnSite Update Package Builder V2" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Version: $version" -ForegroundColor White
Write-Host "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "Method: $method" -ForegroundColor White
Write-Host "===============================================================`n" -ForegroundColor Cyan

# Create temp directory
$tempDir = ".\temp_update_$version"
if (Test-Path $tempDir) {
    Write-Host "Cleaning old temp directory..." -ForegroundColor Gray
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Define files to package
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
$skippedCount = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        $destDir = Join-Path $tempDir (Split-Path $file -Parent)
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $file -Destination (Join-Path $tempDir $file) -Force
        Write-Host "  OK $file" -ForegroundColor Gray
        $copiedCount++
    } else {
        Write-Host "  SKIP $file (not found)" -ForegroundColor Yellow
        $skippedCount++
    }
}

Write-Host "`nFile statistics:" -ForegroundColor Cyan
Write-Host "  Copied: $copiedCount files" -ForegroundColor Green
if ($skippedCount -gt 0) {
    Write-Host "  Skipped: $skippedCount files" -ForegroundColor Yellow
}

# Compression functions
function Compress-WithDotNet {
    param($source, $destination)
    
    Write-Host "Using .NET Framework compression..." -ForegroundColor Cyan
    
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($source, $destination, 'Optimal', $false)
        return $true
    } catch {
        Write-Host "  .NET Framework compression failed: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

function Compress-WithPowerShell {
    param($source, $destination)
    
    Write-Host "Using PowerShell Compress-Archive..." -ForegroundColor Cyan
    
    try {
        Compress-Archive -Path "$source\*" -DestinationPath $destination -Force
        return $true
    } catch {
        Write-Host "  PowerShell compression failed: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

function Compress-WithSevenZip {
    param($source, $destination)
    
    Write-Host "Using 7-Zip compression..." -ForegroundColor Cyan
    
    $sevenZipPaths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe",
        "$env:ProgramFiles\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )
    
    $sevenZip = $null
    foreach ($path in $sevenZipPaths) {
        if (Test-Path $path) {
            $sevenZip = $path
            break
        }
    }
    
    if ($sevenZip) {
        try {
            & $sevenZip a -tzip $destination "$source\*" -r | Out-Null
            return $true
        } catch {
            Write-Host "  7-Zip compression failed: $($_.Exception.Message)" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "  7-Zip not found" -ForegroundColor Yellow
        return $false
    }
}

function Compress-WithWinRAR {
    param($source, $destination)
    
    Write-Host "Using WinRAR compression..." -ForegroundColor Cyan
    
    $winRARPaths = @(
        "C:\Program Files\WinRAR\WinRAR.exe",
        "C:\Program Files (x86)\WinRAR\WinRAR.exe",
        "$env:ProgramFiles\WinRAR\WinRAR.exe",
        "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe"
    )
    
    $winRAR = $null
    foreach ($path in $winRARPaths) {
        if (Test-Path $path) {
            $winRAR = $path
            break
        }
    }
    
    if ($winRAR) {
        try {
            & $winRAR a -afzip -r $destination "$source\*" | Out-Null
            return $true
        } catch {
            Write-Host "  WinRAR compression failed: $($_.Exception.Message)" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "  WinRAR not found" -ForegroundColor Yellow
        return $false
    }
}

# Create ZIP file
Write-Host "`nCreating ZIP file..." -ForegroundColor Green
$zipFile = ".\$version.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

$success = $false

if ($method -eq "Auto") {
    Write-Host "Auto-selecting compression method..." -ForegroundColor Cyan
    
    if (Compress-WithDotNet $tempDir $zipFile) {
        $success = $true
        $usedMethod = ".NET Framework"
    } elseif (Compress-WithPowerShell $tempDir $zipFile) {
        $success = $true
        $usedMethod = "PowerShell"
    } elseif (Compress-WithSevenZip $tempDir $zipFile) {
        $success = $true
        $usedMethod = "7-Zip"
    } elseif (Compress-WithWinRAR $tempDir $zipFile) {
        $success = $true
        $usedMethod = "WinRAR"
    }
} else {
    switch ($method) {
        "DotNet" {
            $success = Compress-WithDotNet $tempDir $zipFile
            $usedMethod = ".NET Framework"
        }
        "PowerShell" {
            $success = Compress-WithPowerShell $tempDir $zipFile
            $usedMethod = "PowerShell"
        }
        "SevenZip" {
            $success = Compress-WithSevenZip $tempDir $zipFile
            $usedMethod = "7-Zip"
        }
        "WinRAR" {
            $success = Compress-WithWinRAR $tempDir $zipFile
            $usedMethod = "WinRAR"
        }
    }
}

if (!$success) {
    Write-Host "`nERROR: All compression methods failed" -ForegroundColor Red
    Write-Host "Please try:" -ForegroundColor Yellow
    Write-Host "1. Install 7-Zip: https://www.7-zip.org/" -ForegroundColor Gray
    Write-Host "2. Update PowerShell to latest version" -ForegroundColor Gray
    Write-Host "3. Manually compress $tempDir directory" -ForegroundColor Gray
    exit 1
}

Write-Host "OK Compression successful! Method: $usedMethod" -ForegroundColor Green

# Clean temp directory
Write-Host "`nCleaning temp files..." -ForegroundColor Gray
Remove-Item $tempDir -Recurse -Force

# Display results
$fileInfo = Get-Item $zipFile
$fileSize = $fileInfo.Length / 1MB
$fileSizeKB = $fileInfo.Length / 1KB

Write-Host "`n" -NoNewline
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "  Package Complete!" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "Filename: $($fileInfo.Name)" -ForegroundColor Cyan
Write-Host "Path: $($fileInfo.FullName)" -ForegroundColor Cyan

if ($fileSize -ge 1) {
    Write-Host "Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "Size: $([math]::Round($fileSizeKB, 2)) KB" -ForegroundColor Cyan
}

Write-Host "Method: $usedMethod" -ForegroundColor Cyan

# Calculate MD5
Write-Host "`nCalculating MD5..." -ForegroundColor Gray
$md5 = (Get-FileHash $zipFile -Algorithm MD5).Hash
Write-Host "MD5: $md5" -ForegroundColor Cyan

# Generate version.json
Write-Host "`n" -NoNewline
Write-Host "===============================================================" -ForegroundColor Yellow
Write-Host "  version.json Configuration" -ForegroundColor Yellow
Write-Host "===============================================================" -ForegroundColor Yellow

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
        Write-Host "Warning: Cannot read changelog from changelog.xml" -ForegroundColor Yellow
    }
}

if ([string]::IsNullOrEmpty($changelogText)) {
    $changelogText = "1. System update\n2. Bug fixes\n3. Performance improvements"
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

$versionJsonFile = ".\version.json.new"
$versionJsonSample | Out-File $versionJsonFile -Encoding UTF8 -Force
Write-Host "`nSaved to: $versionJsonFile" -ForegroundColor Green

Write-Host "`n" -NoNewline
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "1. Upload $version.zip to update server" -ForegroundColor White
Write-Host "2. Update version.json on server" -ForegroundColor White
Write-Host "3. Test update on client" -ForegroundColor White
Write-Host "`nFor details: manager\online-update-guide.md`n" -ForegroundColor Gray
