<#
.SYNOPSIS
    This script creates a local user on Windows and optionally adds the user to the Administrators group.
.DESCRIPTION
    The script accepts parameters for the username, password, and optionally a full name. It can also make the user an administrator.
.PARAMETER UserName
    The username for the new local user.
.PARAMETER Password
    The password for the new local user.
.PARAMETER FullName
    The full name of the user (optional).
.PARAMETER IsAdmin
    Optional switch to determine if the user should be added to the Administrators group.
.EXAMPLE
    .\CreateUser.ps1 -UserName "JohnDoe" -Password "P@ssword123" -IsAdmin
.EXAMPLE
    .\CreateUser.ps1 -UserName "JaneDoe" -Password "P@ssword123" -FullName "Jane Doe"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$UserName,

    [Parameter(Mandatory=$true)]
    [string]$Password,

    [Parameter(Mandatory=$false)]
    [string]$FullName = $UserName, # Default to UserName if FullName is not provided

    [switch]$IsAdmin
)

Import-Module Microsoft.PowerShell.Security
Import-Module Microsoft.PowerShell.LocalAccounts

# Ensure the username is valid and not too long
if ($UserName.Length -gt 20) {
    throw "Username cannot exceed 20 characters."
}

# Convert the password to SecureString
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

try {
    # Create the new user
    Write-Verbose "Creating user $UserName with full name $FullName..."
    New-LocalUser -Name $UserName -Password $securePassword -FullName $FullName -Description "User created via PowerShell script"

    # Add the user to the default Users group
    Write-Verbose "Adding $UserName to Users group..."
    Add-LocalGroupMember -Group "Users" -Member $UserName

    # Add to Administrators group if IsAdmin is set
    if ($IsAdmin) {
        Write-Verbose "Adding $UserName to Administrators group..."
        Add-LocalGroupMember -Group "Administrators" -Member $UserName
    }

    Write-Output "User $UserName created successfully."
}
catch {
    Write-Error "An error occurred: $_"
}
