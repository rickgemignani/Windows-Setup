<#
.SYNOPSIS
    Installs Lenovo System Update Tool on a Lenovo machine, if it's not already installed.
.DESCRIPTION
    This script will check if Lenovo System Update is installed on a Lenovo device. 
    If not installed, it will download and install the Lenovo System Update Tool.
.NOTES
    This script requires administrator privileges.
#>

# Check if Lenovo System Update folder exists
$systemUpdateFolder = "C:\Program Files (x86)\Lenovo\System Update\"
If (Test-Path $systemUpdateFolder) {
    Write-Host "Lenovo System Update is already installed. Skipping installation." -ForegroundColor Green
    Exit 0
}

# Define the download URL for the Lenovo System Update tool
$lenovoUpdateUrl = "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe"
$installerPath = "$env:TEMP\system_update_5.08.03.59.exe"

# Download the Lenovo System Update installer if not already installed
Write-Host "Downloading Lenovo System Update Tool..."
Invoke-WebRequest -Uri $lenovoUpdateUrl -OutFile $installerPath

# Check if the download was successful
If (-Not (Test-Path $installerPath))
{
    Write-Error "Failed to download Lenovo System Update Tool."
    Exit 1
}

# Install Lenovo System Update Tool
Write-Host "Installing Lenovo System Update Tool..."
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

# Verify the installation was successful
$installedApp = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Lenovo System Update*" }
If ($null -eq $installedApp)
{
    Write-Error "Lenovo System Update Tool installation failed."
    Exit 1
}

Write-Host "Lenovo System Update Tool installed successfully." -ForegroundColor Green

# Clean up the installer file
Remove-Item -Path $installerPath -Force
