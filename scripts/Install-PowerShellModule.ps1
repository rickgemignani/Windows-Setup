param (
    [Parameter(Mandatory = $true)]
    [string[]]$ModuleNames
)

foreach ($moduleName in $ModuleNames) {
    # Check if the module is already installed
    if (Get-Module -ListAvailable -Name $moduleName) {
        Write-Host "Module '$moduleName' is already installed."
    } else {
        Write-Host "Module '$moduleName' is not installed. Installing..."
        try {
            Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber
            Write-Host "Module '$moduleName' installed successfully."
        } catch {
            Write-Error "Failed to install module '$moduleName': $_"
        }
    }
}
