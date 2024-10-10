# Install-Chocolatey.ps1
# This script checks if Chocolatey is installed and installs it for all users if not already present.

function Install-Chocolatey {
    param()

    # Check if Chocolatey is already installed
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Chocolatey for all users..." -ForegroundColor Yellow

    # Ensure the script is running in an elevated (administrator) context
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        Write-Error "This script requires administrative privileges. Please run PowerShell as Administrator."
        exit 1
    }

    # Bypass execution policy and run Chocolatey installation script
    Set-ExecutionPolicy Bypass -Scope Process -Force

    # Install Chocolatey via official installation script
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Check if installation was successful
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey installed successfully for all users." -ForegroundColor Green
    } else {
        Write-Error "Chocolatey installation failed. Please check the installation logs for more details."
    }
}

# Call the Install-Chocolatey function
Install-Chocolatey
