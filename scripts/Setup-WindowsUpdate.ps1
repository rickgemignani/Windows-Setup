param (
    [string]$UpdateFrequency,
    [string[]]$UpdateTypes
)

function Get-UpdateTypes {
    param (
        [string[]]$UpdateTypes
    )

    # Map update types to the corresponding Windows Update categories
    $categories = @()
    foreach ($type in $UpdateTypes) {
        switch ($type) {
            "Critical" { $categories += "Critical Updates" }
            "Security" { $categories += "Security Updates" }
            "Feature"  { $categories += "Feature Updates" }
        }
    }
    return $categories
}

function Check-And-Install-Updates {
    param (
        [string[]]$Categories
    )

    Write-Host "Checking for updates in the following categories: $($Categories -join ', ')..."

    # Import the Windows Update module if not already available
    Import-Module -Name PSWindowsUpdate -ErrorAction Stop

    # List available updates by category
    $updates = Get-WindowsUpdate -MicrosoftUpdate -Category $Categories -ErrorAction Stop

    if ($updates) {
        Write-Host "Updates found. Installing..."
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
    } else {
        Write-Host "No updates found."
    }
}

function Set-TaskScheduler {
    param (
        [string]$UpdateFrequency
    )

    # Set up a scheduled task for running the script
    $taskName = "AutomateWindowsUpdates"
    $scriptPath = "$PSScriptRoot\AutomateSystemUpdates.ps1"

    # Check if a scheduled task already exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "A scheduled task for updates already exists. Updating frequency to $UpdateFrequency."
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    # Define the frequency and time for the scheduled task
    switch ($UpdateFrequency) {
        "Daily"   { $trigger = New-ScheduledTaskTrigger -Daily -At 3am }
        "Weekly"  { $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 3am }
        "Monthly" { $trigger = New-ScheduledTaskTrigger -Monthly -DaysInterval 1 -At 3am }
    }

    # Create the scheduled task to run the update script
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`""
    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal

    Write-Host "Scheduled task for system updates has been set with $UpdateFrequency frequency."
}

# Main logic
$categories = Get-UpdateTypes -UpdateTypes $UpdateTypes
Check-And-Install-Updates -Categories $categories
Set-TaskScheduler -UpdateFrequency $UpdateFrequency
