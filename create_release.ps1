# Release packaging script for Financial Accounting System
# This script creates a ZIP package with all necessary files for distribution

$ErrorActionPreference = "Stop"

Write-Host "Financial Accounting System - Release Packager" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Verify that we're in the right directory
if (-not (Test-Path ".\pubspec.yaml")) {
                    Write-Host "Error: This script must be run from the root of the project." -ForegroundColor Red
                    exit 1
}

# Get version from pubspec.yaml
$version = (Get-Content .\pubspec.yaml | Select-String -Pattern "version: (.+)").Matches.Groups[1].Value.Trim()
Write-Host "Building release package for version $version" -ForegroundColor Cyan

# Create a temporary directory for packaging
$tempDir = ".\release_package"
if (Test-Path $tempDir) {
                    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null
Write-Host "Created temporary packaging directory" -ForegroundColor Gray

# Copy Windows release build
if (-not (Test-Path ".\build\windows\x64\runner\Release\financel_acc.exe")) {
                    Write-Host "Windows build not found. Building now..." -ForegroundColor Yellow
                    flutter build windows --release
                    if ($LASTEXITCODE -ne 0) {
                                        Write-Host "Error: Flutter build failed." -ForegroundColor Red
                                        exit 1
                    }
}

New-Item -ItemType Directory -Path "$tempDir\FinancialAcc" | Out-Null
Copy-Item -Recurse ".\build\windows\x64\runner\Release\*" -Destination "$tempDir\FinancialAcc"
Write-Host "Copied Windows build files" -ForegroundColor Gray

# Copy additional files
Copy-Item ".\install_windows.bat" -Destination $tempDir
Copy-Item ".\README.txt" -Destination $tempDir
Copy-Item ".\LICENSE" -Destination $tempDir
Write-Host "Copied additional files" -ForegroundColor Gray

# Create zip file
$zipFileName = "FinancialAccounting_v$version.zip"
Compress-Archive -Path "$tempDir\*" -DestinationPath ".\$zipFileName"
Write-Host "Created package: $zipFileName" -ForegroundColor Green

# Clean up
Remove-Item -Recurse -Force $tempDir
Write-Host "Cleaned up temporary files" -ForegroundColor Gray

Write-Host "`nPackage created successfully!" -ForegroundColor Green
Write-Host "You can now distribute: $zipFileName" -ForegroundColor Cyan
