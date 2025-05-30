@echo off
echo Financial Accounting System - Setup Files
echo =========================================
echo.

:: Create empty lines for better readability
echo.
echo Available packages:
echo.
echo 1. Windows Store MSIX Package
echo.

set /p choice=Would you like to open the Windows Store package folder? (Y/N): 

if /i "%choice%"=="Y" (
    echo Opening Windows Store package folder...
    start "" "setup_app\WindowsStore"
    exit /b 0
)

echo.
echo Thank you for using Financial Accounting System!
echo You can manually access the MSIX file at:
echo setup_app\WindowsStore\FinancialAccounting.msix
echo.
