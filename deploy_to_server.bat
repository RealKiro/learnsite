@echo off
echo ========================================
echo 部署 showcourse.aspx 修复到服务器
echo ========================================
echo.

set SERVER_PATH=C:\inetpub\wwwroot\LearnSite

echo 检查服务器路径是否存在...
if not exist "%SERVER_PATH%" (
    echo 错误：服务器路径不存在: %SERVER_PATH%
    echo 请修改此脚本中的 SERVER_PATH 变量
    pause
    exit /b 1
)

echo 服务器路径: %SERVER_PATH%
echo.
echo 准备部署以下文件：
echo   1. web.config
echo   2. student\showcourse.aspx
echo   3. App_Code\showcourse.cs
echo.
echo 按任意键开始部署，或按 Ctrl+C 取消...
pause > nul

echo.
echo [1/4] 备份现有文件...
if exist "%SERVER_PATH%\web.config" (
    copy "%SERVER_PATH%\web.config" "%SERVER_PATH%\web.config.backup.%date:~0,4%%date:~5,2%%date:~8,2%" > nul
    echo   ✓ 已备份 web.config
)
if exist "%SERVER_PATH%\student\showcourse.aspx" (
    copy "%SERVER_PATH%\student\showcourse.aspx" "%SERVER_PATH%\student\showcourse.aspx.backup.%date:~0,4%%date:~5,2%%date:~8,2%" > nul
    echo   ✓ 已备份 showcourse.aspx
)

echo.
echo [2/4] 复制新文件到服务器...
copy /Y "web.config" "%SERVER_PATH%\web.config"
if %errorlevel% equ 0 (
    echo   ✓ web.config 已部署
) else (
    echo   ✗ web.config 部署失败
)

copy /Y "student\showcourse.aspx" "%SERVER_PATH%\student\showcourse.aspx"
if %errorlevel% equ 0 (
    echo   ✓ showcourse.aspx 已部署
) else (
    echo   ✗ showcourse.aspx 部署失败
)

if not exist "%SERVER_PATH%\App_Code" (
    mkdir "%SERVER_PATH%\App_Code"
    echo   ✓ 已创建 App_Code 目录
)

copy /Y "App_Code\showcourse.cs" "%SERVER_PATH%\App_Code\showcourse.cs"
if %errorlevel% equ 0 (
    echo   ✓ showcourse.cs 已部署
) else (
    echo   ✗ showcourse.cs 部署失败
)

echo.
echo [3/4] 删除旧的代码文件（如果存在）...
if exist "%SERVER_PATH%\student\showcourse.aspx.cs" (
    del "%SERVER_PATH%\student\showcourse.aspx.cs"
    echo   ✓ 已删除 showcourse.aspx.cs
) else (
    echo   - showcourse.aspx.cs 不存在，跳过
)

echo.
echo [4/4] 重启 IIS 应用程序池...
%systemroot%\system32\inetsrv\appcmd stop apppool /apppool.name:"ls"
timeout /t 2 /nobreak > nul
%systemroot%\system32\inetsrv\appcmd start apppool /apppool.name:"ls"
echo   ✓ 应用程序池已重启

echo.
echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 现在可以访问以下地址测试：
echo http://ls.lequw.net/student/showcourse.aspx?cid=3
echo.
echo 如果仍然出现错误，请查看 DEPLOY_INSTRUCTIONS.md
echo.
pause
