# Script to set PowerShell 7 as the default shell in Windows Terminal

# Function to get the path to the Windows Terminal settings file
function Get-TerminalSettingsPath {
    $appData = [Environment]::GetFolderPath('LocalApplicationData')
    $settingsPath = Join-Path -Path $appData -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    return $settingsPath
}

# Function to get the GUID of the PowerShell 7 profile
function Get-PowerShell7ProfileGuid {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Settings,

        [Parameter(Mandatory = $true)]
        [string]$ProfileName
    )

    # Handle different schema versions
    if ($Settings.profiles.list) {
        $profilesList = $Settings.profiles.list
    } elseif ($Settings.profiles.profiles) {
        $profilesList = $Settings.profiles.profiles
    } elseif ($Settings.profiles) {
        $profilesList = $Settings.profiles
    } else {
        throw "Could not find profiles in settings."
    }

    foreach ($profile in $profilesList) {
        if ($profile.name -eq $ProfileName) {
            return $profile.guid
        }
    }

    throw "Profile '$ProfileName' not found in Windows Terminal settings."
}

try {
    # Get the path to the settings file
    $settingsFilePath = Get-TerminalSettingsPath

    # Check if the settings file exists
    if (-not (Test-Path $settingsFilePath)) {
        throw "Windows Terminal settings file not found at path '$settingsFilePath'. Ensure Windows Terminal is installed and has been launched at least once."
    }

    # Read the settings file
    $settingsJson = Get-Content -Path $settingsFilePath -Raw -ErrorAction Stop

    # Convert JSON to a PowerShell object
    $settings = $settingsJson | ConvertFrom-Json -ErrorAction Stop

    # Prompt for the profile name
    $defaultProfileName = "PowerShell"
    $profileName = Read-Host "Enter the exact name of your PowerShell 7 profile (default is '$defaultProfileName')"
    if ([string]::IsNullOrWhiteSpace($profileName)) {
        $profileName = $defaultProfileName
    }

    # Get the GUID of the PowerShell 7 profile
    $pwsh7Guid = Get-PowerShell7ProfileGuid -Settings $settings -ProfileName $profileName

    # Set PowerShell 7 as the default profile
    $settings.defaultProfile = $pwsh7Guid

    # Convert the settings back to JSON with proper formatting
    $newSettingsJson = $settings | ConvertTo-Json -Depth 5

    # Backup the existing settings file
    Copy-Item -Path $settingsFilePath -Destination "$settingsFilePath.bak" -Force

    # Write the new settings to the file
    Set-Content -Path $settingsFilePath -Value $newSettingsJson -Encoding UTF8 -Force

    Write-Host "Profile '$profileName' has been set as the default shell in Windows Terminal."

} catch {
    Write-Error "An error occurred: $_"
}
