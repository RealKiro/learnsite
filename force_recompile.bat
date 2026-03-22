@echo off
echo ========================================
echo 强制重新编译 learnrate.aspx
echo ========================================
echo.

set SERVER_PATH=C:\inetpub\wwwroot\LearnSite

echo [1/3] 复制最新的 learnrate.aspx.cs 到服务器...
copy /Y "teacher\learnrate.aspx.cs" "%SERVER_PATH%\teacher\learnrate.aspx.cs"
if %errorlevel% equ 0 (
    echo   ✓ 文件已复制
) else (
    echo   ✗ 文件复制失败
    pause
    exit /b 1
)

echo.
echo [2/3] 删除服务器上的编译缓存...
if exist "%SERVER_PATH%\teacher\learnrate.aspx.cs.compiled" (
    del "%SERVER_PATH%\teacher\learnrate.aspx.cs.compiled"
    echo   ✓ 已删除编译缓存
)

echo.
echo [3/3] 重启 IIS 应用程序池...
%systemroot%\system32\inetsrv\appcmd stop apppool /apppool.name:"ls"
timeout /t 2 /nobreak > nul
%systemroot%\system32\inetsrv\appcmd start apppool /apppool.name:"ls"
echo   ✓ 应用程序池已重启

echo.
echo ========================================
echo 完成！
echo ========================================
echo.
echo 现在刷新页面测试：
echo http://ls.lequw.net/teacher/learnrate.aspx?wgrade=3^&wclass=1^&wcid=3
echo.
echo 如果还是显示旧错误，请：
echo 1. 检查服务器文件是否真的更新了
echo 2. 尝试运行 iisreset 完全重启 IIS
echo 3. 清除浏览器缓存
echo.
pause
