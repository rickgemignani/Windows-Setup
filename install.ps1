<#
.SYNOPSIS
Automates the installation or updating of packages using winget, choco, scoop, or executes custom scripts.

.DESCRIPTION
This script reads a list of packages and scripts from a packages file and installs them using the specified package manager.
It supports winget, choco, scoop, and custom scripts. The script determines the execution context (admin or user) based on current privileges.

.PARAMETER PackagesFile
Optional path to the packages file. If not specified, it uses the path from the configuration file.

.PARAMETER ConfigFile
Optional path to the configuration file. If not specified, it defaults to './config.yaml'.

.PARAMETER Incremental
When specified, the script will process only changed lines from the packages file compared to the last successful run.

.PARAMETER Help
Displays this help message.

.EXAMPLE
.\InstallPackages.ps1

Runs the script using the default configuration and packages files.

.EXAMPLE
.\InstallPackages.ps1 -PackagesFile ".\my_packages.txt" -ConfigFile ".\my_config.yaml"

Runs the script using the specified packages and configuration files.

.EXAMPLE
.\InstallPackages.ps1 -Incremental

Runs the script in incremental mode, only processing changed packages.
#>

param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$PackagesFile,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ConfigFile = ".\config.yaml",

    [Parameter(Mandatory = $false, HelpMessage = "Runs in incremental mode.")]
    [switch]$Incremental,

    [Parameter(Mandatory = $false, HelpMessage = "Displays help information.")]
    [switch]$Help
)

if ($Help) {
    Get-Help -Detailed $MyInvocation.MyCommand.Path
    exit
}

# Import the library
$libraryPath = Join-Path $PSScriptRoot "libraries"
. "$libraryPath\PowerShell.ps1"
. "$libraryPath\Config.ps1"
. "$libraryPath\Install.ps1"

# Test if we are in PowerShell7
if (-not (Test-PowerShell7 -VerboseCheck)) {
    exit
}

# Load Config
$configFilePath = if ($ConfigFile) { Resolve-Path -Path $ConfigFile } else { "$PSScriptRoot\config.yaml" }
$config = Load-ConfigFromYaml -ConfigFilePath $configFilePath

# Resolve the packages file path
$packagesFilePath = if ($PackagesFile) { Resolve-Path -Path $PackagesFile } else { $config.packages.package_file_path }

# Main execution logic
Install-AllPackages -PackagesFilePath $packagesFilePath -Incremental:$Incremental
