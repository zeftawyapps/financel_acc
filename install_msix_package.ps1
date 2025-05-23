# Install Financial Accounting MSIX Package
# This script helps install the MSIX package directly

$msixPath = "setup_app\WindowsStore\FinancialAccounting.msix"

Write-Host "Financial Accounting System - MSIX Package Installer" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if the MSIX file exists
if (Test-Path $msixPath) {
    Write-Host "MSIX package found: $msixPath" -ForegroundColor Green
    
    $choice = Read-Host "Would you like to install the Financial Accounting System? (Y/N)"
    
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "Installing MSIX package..." -ForegroundColor Cyan
        
        try {
            # Get the full path to the MSIX file
            $fullPath = (Get-Item $msixPath).FullName
            
            # Install the MSIX package
            Add-AppxPackage -Path $fullPath
            
            Write-Host "Installation completed successfully!" -ForegroundColor Green
            Write-Host "You can now launch Financial Accounting System from your Start menu." -ForegroundColor White
        }
        catch {
            Write-Host "Error during installation: $_" -ForegroundColor Red
            Write-Host "You may need administrator privileges or to enable developer mode." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
    }
}
else {
    Write-Host "Error: MSIX package not found at $msixPath" -ForegroundColor Red
    
    # Check if we need to create the MSIX package
    $choice = Read-Host "Would you like to create the MSIX package now? (Y/N)"
    
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "Creating MSIX package..." -ForegroundColor Cyan
        
        # Create the WindowsStore directory if it doesn't exist
        if (-not (Test-Path "setup_app\WindowsStore")) {
            New-Item -Path "setup_app\WindowsStore" -ItemType Directory -Force | Out-Null
        }
        
        # Run the MSIX creation command
        flutter pub run msix:create --output-path="setup_app\WindowsStore" --output-name=FinancialAccounting --install-certificate
        
        # Check if the MSIX was created successfully
        if (Test-Path $msixPath) {
            Write-Host "MSIX package created successfully at: $msixPath" -ForegroundColor Green
            
            $installChoice = Read-Host "Would you like to install the package now? (Y/N)"
            
            if ($installChoice -eq "Y" -or $installChoice -eq "y") {
                # Get the full path to the MSIX file
                $fullPath = (Get-Item $msixPath).FullName
                
                # Install the MSIX package
                Add-AppxPackage -Path $fullPath
                
                Write-Host "Installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch Financial Accounting System from your Start menu." -ForegroundColor White
            }
        }
        else {
            Write-Host "Failed to create the MSIX package." -ForegroundColor Red
        }
    }
}
