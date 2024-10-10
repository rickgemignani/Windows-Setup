param (
    [string]$GitUsername,
    [string]$GitEmail
)

# Ensure parameters are provided
if (-not $GitUsername -or -not $GitEmail) {
    Write-Host "You must provide both a Git username and email." -ForegroundColor Red
    exit 1
}

# Ensure Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Please install Git from https://git-scm.com/download/win and rerun this script." -ForegroundColor Red
    exit
}

# Set Git username and email for GitHub
Write-Host "Setting Git username and email for GitHub..."
git config --global user.name "$GitUsername"
git config --global user.email "$GitEmail"
Write-Host git config --global user.name "$GitUsername"
Write-Host git config --global user.email "$GitEmail"
Write-Host "Git username and email set successfully." -ForegroundColor Green

# Generate SSH key
$sshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
if (-not (Test-Path $sshKeyPath)) {
    Write-Host "Generating a new SSH key..."
    ssh-keygen -t ed25519 -C "$GitEmail" -f "$sshKeyPath" -N ""
    Write-Host "SSH key generated at $sshKeyPath." -ForegroundColor Green
} else {
    Write-Host "SSH key already exists at $sshKeyPath." -ForegroundColor Yellow
}

# Try to start the SSH agent service
Write-Host "Starting SSH agent service..."
try {
    Set-Service -Name ssh-agent -StartupType Automatic
    Start-Service ssh-agent
    Write-Host "SSH agent service started." -ForegroundColor Green
} catch {
    Write-Host "Failed to start SSH agent service. Trying to run it manually..." -ForegroundColor Yellow

    # Try to run ssh-agent manually in the current session
    try {
        $sshAgentOutput = & ssh-agent
        Write-Host "SSH agent started manually." -ForegroundColor Green
    } catch {
        Write-Host "Failed to manually start ssh-agent: $_" -ForegroundColor Red
        exit
    }
}

# Add the SSH key to the agent
try {
    ssh-add "$sshKeyPath"
    Write-Host "SSH key added to the SSH agent." -ForegroundColor Green
} catch {
    Write-Host "Failed to add SSH key to the agent: $_" -ForegroundColor Red
    exit
}

# Display the SSH public key
Write-Host "Your SSH public key is:"
Get-Content "$sshKeyPath.pub"
Write-Host "Copy the SSH public key above and add it to your GitHub account: https://github.com/settings/keys"

# Test SSH connection to GitHub
Write-Host "Testing SSH connection to GitHub..."
try {
    ssh -T git@github.com
    Write-Host "SSH connection to GitHub successful." -ForegroundColor Green
} catch {
    Write-Host "SSH connection to GitHub failed: $_" -ForegroundColor Red
}

# Confirm the setup is complete
Write-Host "GitHub setup complete! You can now use Git with SSH on GitHub." -ForegroundColor Green
