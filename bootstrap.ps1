<#
.SYNOPSIS
Bootstrap script to download and set up the dotfiles-windows repository.

.DESCRIPTION
This script downloads the dotfiles-windows repository from GitHub as a ZIP file, extracts it to a specified directory, and prepares it for execution.

.PARAMETER RepositoryUrl
The URL of the GitHub repository to download.

.PARAMETER DestinationPath
The path where the repository will be extracted.

.EXAMPLE
.\bootstrap.ps1

Downloads and extracts the repository to the default path.

#>

[CmdletBinding()]
param (
    [string]$RepositoryUrl = 'https://github.com/yourusername/dotfiles-windows/archive/refs/heads/main.zip',
    [string]$DestinationPath = "$env:USERPROFILE\dotfiles-windows"
)

function Download-And-ExtractRepo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepoUrl,
        [Parameter(Mandatory = $true)]
        [string]$ExtractPath
    )

    # Create temporary directory
    $tempPath = [System.IO.Path]::GetTempPath()
    $zipFile = Join-Path $tempPath "dotfiles-windows.zip"

    try {
        # Download the ZIP file
        Write-Host "Downloading repository from $RepoUrl..."
        Invoke-WebRequest -Uri $RepoUrl -OutFile $zipFile -UseBasicParsing

        # Create the destination directory if it doesn't exist
        if (-not (Test-Path -Path $ExtractPath)) {
            New-Item -ItemType Directory -Path $ExtractPath -Force | Out-Null
        }

        # Extract the ZIP file
        Write-Host "Extracting repository to $ExtractPath..."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $ExtractPath)

        # Clean up the ZIP file
        Remove-Item $zipFile -Force

        # Move contents up if necessary
        $extractedFolder = Join-Path $ExtractPath 'dotfiles-windows-main'
        if (Test-Path $extractedFolder) {
            Get-ChildItem -Path $extractedFolder -Force | Move-Item -Destination $ExtractPath -Force
            Remove-Item $extractedFolder -Force -Recurse
        }

        Write-Host "Repository downloaded and extracted successfully."

    } catch {
        Write-Error "An error occurred: $_"
        exit 1
    }
}

Download-And-ExtractRepo -RepoUrl $RepositoryUrl -ExtractPath $DestinationPath

# Change directory to the destination path
Set-Location $DestinationPath

# Optionally, run the main installation script
Write-Host "Starting installation..."
.\InstallPackages.ps1
