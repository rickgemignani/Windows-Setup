# Check if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Error "Chocolatey is not installed. Please install Chocolatey to use this script."
    exit 1
}

# List all outdated Chocolatey packages
$outdatedPackages = choco outdated

if ($outdatedPackages -match "No packages found") {
    Write-Host "All Chocolatey packages are already up to date."
} else {
    Write-Host "Upgrading all outdated Chocolatey packages..."
    
    try {
        # Upgrade all Chocolatey packages
        choco upgrade all -y

        Write-Host "All Chocolatey packages have been successfully upgraded."
    } catch {
        Write-Error "An error occurred while upgrading packages: $_"
    }
}
