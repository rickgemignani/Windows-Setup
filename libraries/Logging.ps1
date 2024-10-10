# Define LogLevel enum
enum LogLevel {
    Debug = 0
    Info = 1
    Warning = 2
    Error = 3
}

# Function to log messages based on configuration and output to console
function Log-Message {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$LogLevel = "Info"
    )

    # Convert log levels to numeric values for comparison
    $logLevels = @{
        "Debug"   = [LogLevel]::Debug
        "Info"    = [LogLevel]::Info
        "Warning" = [LogLevel]::Warning
        "Error"   = [LogLevel]::Error
    }
    $currentLevel = $logLevels[$config.logging.level]

    # Output to console based on log level
    if ($logLevels[$LogLevel] -ge $currentLevel) {
        switch ($LogLevel) {
            "Debug"   { Write-Verbose $Message }
            "Info"    { Write-Host $Message }
            "Warning" { Write-Warning $Message }
            "Error"   { Write-Error $Message }
        }
    }

    # Log to file if the message's log level is equal to or higher than the configured level
    if ($logLevels[$LogLevel] -ge $currentLevel) {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        "$timestamp - $($LogLevel): $Message" | Out-File -Append -FilePath $config.logging.log_file_path -Encoding UTF8
    }
}
