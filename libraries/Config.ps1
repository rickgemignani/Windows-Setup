# Ensure the powershell-yaml module is installed and imported
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Install-Module -Name powershell-yaml -Scope CurrentUser -Force
}
Import-Module powershell-yaml

# Function to load YAML configuration file
function Load-ConfigFromYaml {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigFilePath
    )

    # Check if the config file exists
    if (-not (Test-Path $ConfigFilePath)) {
        Write-Error "Configuration file not found at path '$ConfigFilePath'."
        return $null
    }

    try {
        # Load and parse the YAML content
        $config = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Yaml -ErrorAction Stop
        return $config
    } catch {
        Write-Error "Failed to load or parse the YAML configuration file: $_"
        return $null
    }
}
