@echo off
echo ========================================
echo 部署修复文件到服务器
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
echo   4. teacher\learnrate.aspx (修改为使用 CodeFile)
echo   5. teacher\learnrate.aspx.cs (修复重复列问题)
echo.
echo 按任意键开始部署，或按 Ctrl+C 取消...
pause > nul

echo.
echo [1/5] 备份现有文件...
if exist "%SERVER_PATH%\teacher\learnrate.aspx.cs" (
    copy "%SERVER_PATH%\teacher\learnrate.aspx.cs" "%SERVER_PATH%\teacher\learnrate.aspx.cs.backup" > nul
    echo   ✓ 已备份 learnrate.aspx.cs
)

echo.
echo [2/5] 复制 web.config...
copy /Y "web.config" "%SERVER_PATH%\web.config"
if %errorlevel% equ 0 (
    echo   ✓ web.config 已部署
) else (
    echo   ✗ web.config 部署失败
)

echo.
echo [3/5] 复制 showcourse 相关文件...
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
echo [4/6] 复制 learnrate.aspx (修改为使用 CodeFile)...
copy /Y "teacher\learnrate.aspx" "%SERVER_PATH%\teacher\learnrate.aspx"
if %errorlevel% equ 0 (
    echo   ✓ learnrate.aspx 已部署
) else (
    echo   ✗ learnrate.aspx 部署失败
)

echo.
echo [5/6] 复制 learnrate.aspx.cs (修复重复列问题)...
copy /Y "teacher\learnrate.aspx.cs" "%SERVER_PATH%\teacher\learnrate.aspx.cs"
if %errorlevel% equ 0 (
    echo   ✓ learnrate.aspx.cs 已部署
) else (
    echo   ✗ learnrate.aspx.cs 部署失败
)

echo.
echo [6/6] 重启 IIS 应用程序池...
%systemroot%\system32\inetsrv\appcmd stop apppool /apppool.name:"ls"
timeout /t 2 /nobreak > nul
%systemroot%\system32\inetsrv\appcmd start apppool /apppool.name:"ls"
echo   ✓ 应用程序池已重启

echo.
echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 修复内容：
echo   1. showcourse.aspx - 课程展示页面现在可以正常显示数据
echo   2. learnrate.aspx - 修复了"名为'测试'的列已属于此 DataTable"错误
echo.
echo 现在可以访问以下地址测试：
echo   - http://ls.lequw.net/student/showcourse.aspx?cid=3
echo   - http://ls.lequw.net/teacher/learnrate.aspx?wgrade=3^&wclass=1^&wcid=3
echo.
pause
