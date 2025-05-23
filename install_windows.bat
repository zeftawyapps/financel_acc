@echo off
echo Installing Financial Accounting System...
echo ========================================

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installation requires administrator privileges.
    echo Please right-click on this file and select "Run as administrator".
    pause
    exit /b 1
)

REM Create installation directory
if not exist "%LOCALAPPDATA%\FinancialAcc" mkdir "%LOCALAPPDATA%\FinancialAcc"
echo Created installation directory

REM Copy executable files
xcopy /s /y .\build\windows\x64\runner\Release\* "%LOCALAPPDATA%\FinancialAcc\"
echo Copied application files

REM Copy README.txt
copy /y .\README.txt "%LOCALAPPDATA%\FinancialAcc\"
echo Copied documentation

REM Create desktop shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%USERPROFILE%\Desktop\Financial Accounting.lnk" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "%LOCALAPPDATA%\FinancialAcc\financel_acc.exe" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%LOCALAPPDATA%\FinancialAcc\" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "Financial Accounting System" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"
cscript /nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"
echo Created desktop shortcut

echo.
echo Installation Complete!
echo You can now run the application from your desktop or from:
echo %LOCALAPPDATA%\FinancialAcc\financel_acc.exe
echo.
pause
