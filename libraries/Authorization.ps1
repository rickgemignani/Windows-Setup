# Function to check for administrative privileges
function Test-Admin {
    [CmdletBinding()]
    param ()
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
