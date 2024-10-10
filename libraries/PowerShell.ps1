function Test-PowerShell7 {
    param (
        [Parameter(Mandatory = $false)]
        [switch]$VerboseCheck
    )
    
    # Check if running in PowerShell 7 or higher
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        return $true
    } else {
        if ($VerboseCheck) {
            Write-Host "This script requires PowerShell 7 or higher." -ForegroundColor Yellow
            Write-Host ""

            # Provide installation options
            Write-Host "You can install PowerShell 7 using one of the following methods:" -ForegroundColor Cyan
            Write-Host ""

            # Option 1: Using winget
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Host "Option 1: Install PowerShell 7 using winget." -ForegroundColor Green
                Write-Host "Run the following command in an elevated PowerShell session:" -ForegroundColor Cyan
                Write-Host "winget install --id Microsoft.PowerShell --source winget" -ForegroundColor White
            } else {
                Write-Host "winget is not available on this system." -ForegroundColor Yellow
            }
            
            Write-Host ""

            # Option 2: Using the official one-line installer
            Write-Host "Option 2: Install PowerShell 7 using the official one-line installer." -ForegroundColor Green
            Write-Host "Run the following command in an elevated PowerShell session:" -ForegroundColor Cyan
            Write-Host "Invoke-Expression \"`& { `$ (Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -UseMSI\"" -ForegroundColor White
            Write-Host ""
            Write-Host "After installing, close this terminal and start a new one in PowerShell 7." -ForegroundColor Yellow
        }

        return $false
    }
}

