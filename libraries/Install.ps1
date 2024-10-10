# Import the library
$libraryPath = $PSScriptRoot
. "$libraryPath\Logging.ps1"
. "$libraryPath\Authorization.ps1"

function Install-Package {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageLine
    )

    # Check for administrative privileges
    if (Test-Admin) {
        $PackageContext = "admin"
        Log-Message "Script is running with administrative privileges." -LogLevel "Info"
    } else {
        $PackageContext = "user"
        Log-Message "Script is running without administrative privileges." -LogLevel "Info"
    }

    # Define the regex pattern, ensure quotes remain preserved
    $pattern = '(".*?"|''.*?''|\S+)'

    # Split the line into components using regex
    $lineParts = [regex]::Matches($PackageLine, $pattern) | ForEach-Object { $_.Value }

    if ($lineParts.Count -lt 2) {
        Log-Message "Invalid package line format: '$PackageLine'. Expected format: '[admin|user] <packageManager> <packageName> [options]'" -LogLevel "Error"
        return
    }

    # Check if the first parameter is 'admin' or 'user'
    $firstParam = $lineParts[0].ToLower()
    if ($firstParam -in @("admin", "user")) {
        $linePackageContext = $firstParam
        $packageManager = $lineParts[1].ToLower()
        $packageDetails = $lineParts[2..($lineParts.Count - 1)]
    } else {
        # If not specified, assume 'admin'
        $linePackageContext = "admin"
        $packageManager = $firstParam
        $packageDetails = $lineParts[1..($lineParts.Count - 1)]
    }

    # Skip packages that don't match the current execution context
    if ($linePackageContext -ne $PackageContext) {
        return
    }

    if ($packageDetails.Count -lt 1) {
        Log-Message "Package name is missing in line: '$PackageLine'" -LogLevel "Error"
        return
    }
    $packageName = $packageDetails[0]
    $packageParams = @()
    if ($packageDetails.Count -gt 1) {
        $packageParams = $packageDetails[1..($packageDetails.Count - 1)]
    }

    # Set default parameters based on the package manager
    switch ($packageManager) {
        "winget" {
            $defaultParams = $config.winget.default_parameters
            $packageCmd = "winget"
        }
        "choco" {
            $defaultParams = $config.choco.default_parameters
            $packageCmd = "choco"
        }
        "scoop" {
            $defaultParams = $config.scoop.default_parameters
            $packageCmd = "scoop"
        }
        "script" {
            $defaultParams = @()
        }
        default {
            Log-Message "Unsupported package manager: $packageManager" -LogLevel "Error"
            return
        }
    }

    # Combine default and specific parameters
    $packageParams = $defaultParams + $packageParams

    try {
        switch ($packageManager) {
            "winget" {
                $arguments = @("install", "--id", $packageName) + $packageParams
                Log-Message "Installing $packageName using $packageManager with parameters: $packageParams" -LogLevel "Info"
                & $packageCmd @arguments
            }
            "choco" {
                $arguments = @("install", $packageName) + $packageParams
                Log-Message "Installing $packageName using $packageManager with parameters: $packageParams" -LogLevel "Info"
                & $packageCmd @arguments
            }
            "scoop" {
                $arguments = @("install", $packageName) + $packageParams
                Log-Message "Installing $packageName using $packageManager with parameters: $packageParams" -LogLevel "Info"
                & $packageCmd @arguments
            }
            "script" {
                # Execute the script from the specified scripts folder
                $scriptsFolderPath = $config.paths.scripts_folder_path
                if (-not $scriptsFolderPath) {
                    Log-Message "Scripts folder path is not specified in the configuration file." -LogLevel "Error"
                    return
                }
                if (-not (Test-Path $scriptsFolderPath)) {
                    Log-Message "Scripts folder not found at path: $scriptsFolderPath" -LogLevel "Error"
                    return
                }
                $scriptPath = Join-Path -Path $scriptsFolderPath -ChildPath ($packageName + ".ps1")
                if (-not (Test-Path $scriptPath)) {
                    Log-Message "Script file not found: $scriptPath" -LogLevel "Error"
                    return
                }
                Log-Message "Executing script $scriptPath with parameters: $packageParams" -LogLevel "Info"

                # Join the package parameters into a string and ensure safe quoting
                $scriptArguments = $packageParams -join ' '
                # Construct the argument list for the script
                $argumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $scriptArguments"
                # Run the script using Start-Process, hiding the window, and capturing the output
                Start-Process powershell.exe `
                    -ArgumentList $argumentList `
                    -NoNewWindow `
                    -Wait
            }
        }

        Log-Message "$packageName processed successfully using $packageManager." -LogLevel "Info"

    } catch {
        Log-Message "Error during installation of $packageName using $($packageManager): $($_.Exception.Message)" -LogLevel "Error"
        throw
        return
    }
}

# Function to install all packages from the unified package file
function Install-AllPackages {
    [CmdletBinding()]
    param ()

    # Load variables from configuration or parameters
    if ($PackagesFile) {
        $packagesFilePath = Resolve-Path -Path $PackagesFile -ErrorAction Stop
    } else {
        $packagesFilePath = Resolve-Path -Path $config.packages.package_file_path -ErrorAction Stop
    }

    # Check if the package file exists
    if (-not (Test-Path $packagesFilePath)) {
        Log-Message "The specified package file '$packagesFilePath' does not exist." -LogLevel "Error"
        return
    }

    # Read the packages from the file with correct encoding
    $packages = Get-Content -Path $packagesFilePath -Encoding UTF8

    # Loop through each package in the file
    foreach ($package in $packages) {
        # Skip empty or whitespace-only lines
        if ([string]::IsNullOrWhiteSpace($package) -or $package.Trim().StartsWith("#")) {
            continue
        }
        try {
            Install-Package -PackageLine $package
        } catch {
            Log-Message "Failed to process package from line '$package': $($_.Exception.Message)" -LogLevel "Error"
        }
    }

    Log-Message "All applicable packages have been processed." -LogLevel "Info"
}
