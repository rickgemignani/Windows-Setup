# Windows Setup Scripts 🚀

Welcome to my **first ever** attempt at writing PowerShell scripts! 🎉 Having spent most of my time working with macOS and Linux, I decided to take a leap into the Windows world and, well... here we are! 😅

## What's This All About? 🤔

This repository contains a collection of PowerShell scripts that automate the setup and configuration of Windows systems. With these scripts, you can easily install software, customize your system, and keep everything up to date.

Oh, and the main reason I’m doing this? I have a feeling I’ll need to reinstall Windows a few times to get things just right. So I figured I’d make life a little easier on myself by automating the process! 😅

My inspiration for this project comes from several great repositories and tools focused on Windows bootstrapping, including:

- [jayharris/dotfiles-windows](https://github.com/jayharris/dotfiles-windows)
- [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) (for streamlining Windows customization and tweaks)
- [simeononsecurity/Windows-Optimize-Harden-Debloat](https://github.com/simeononsecurity/Windows-Optimize-Harden-Debloat) (for optimizing and hardening Windows installations)
- [majkinetor/au](https://github.com/majkinetor/au) (Automated updates for Windows applications using Chocolatey)
- [bmatzelle/gow](https://github.com/bmatzelle/gow) (Gnu On Windows, for using Unix tools natively in Windows)
- [felixrieseberg/windows-build-tools](https://github.com/felixrieseberg/windows-build-tools) (Great for setting up Node development environments)
- [farag2/Sophia-Script-for-Windows](https://github.com/farag2/Sophia-Script-for-Windows) (For powerful system tweaking and customization)

These tools and repos helped me figure out how to build a flexible Windows setup that works for my needs, and I hope they inspire you too!

## Features 🎯

- **Automated Package Installation**: Easily install software using `winget`, `choco`, or `scoop`. It’s like homebrew for Windows... but with more choices!
- **Custom Script Execution**: Run your own PowerShell scripts during setup (or just steal mine, I won’t mind!).
- **System Update Automation**: Because who likes manually checking for updates? Not me, that’s for sure. 😅
- **Configurable Settings**: Manage and customize the installation process through a configuration file.
- **Logging**: Provides detailed logs, because PowerShell might need some serious detective work sometimes! 🔍

## Usage Instructions 📋

### Step 1: Get the Software

There are a few ways to get the setup scripts onto your machine:

- **Option 1**: Run the `bootstrap.ps1` script to download and unpack the repository:
  ```powershell
  Invoke-Expression "& { $(Invoke-RestMethod 'https://your-repo-link/Windows-Setup/bootstrap.ps1') }"
  ```
- **Option 2**: Clone the repository using `git`:
  ```bash
  git clone https://github.com/rickgemignani/Windows-Setup.git
  cd Windows-Setup
  ```
- **Option 3**: If you're using OneDrive, just save the repository there. That way, it’s ready to go when you reinstall Windows. You’ll thank yourself later! 😎

### Step 2: Configure Your Packages

Edit the `packages.txt` file to include the software you want to install. We support `winget`, `choco`, and `scoop`. Each line should follow this format:
```
[user|admin] <packageManager> <packageName> [options]
```

Example:
```txt
admin winget Microsoft.VisualStudioCode
user choco googlechrome
admin scoop 7zip
admin script ConfigureSystemSettings.ps1
```

### Step 3: Customize the Configuration

Now, open the `config.yaml` file and tweak the settings to match your preferences. You can configure:

- Paths for custom scripts.
- Default parameters for package managers like `winget`, `choco`, and `scoop`.
- Logging options, including where logs are saved.

Example configuration snippet:
```yaml
# Configuration for Package Install Script

paths:
  scripts_folder_path: "./scripts"

winget:
  default_parameters:
    - "--silent"
    - "--accept-package-agreements"
    - "--accept-source-agreements"

choco:
  default_parameters:
    - "-y"

scoop:
  default_parameters: []

logging:
  level: "Info"
  log_file_path: "./install_log.txt"
```

### Step 4: Run the Installation Script

You’ll need to run the `install.ps1` script twice:

1. **First run**: From an **elevated shell** (admin) to install system-level software:
   ```powershell
   .\install.ps1
   ```

2. **Second run**: From a **user shell** to install user-space software:
   ```powershell
   .\install.ps1
   ```

And that's it! The scripts will take care of the rest. 🎉

## Contributions? Yes, Please! 🙌

I’m new to PowerShell, so if you spot something that could be better (or not break everything 🫣), feel free to contribute! Check out the [CONTRIBUTING.md](CONTRIBUTING.md) file for how to get involved.

### License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for more details.

---

### Contact Me 📬

Have questions? Want to point out all the things I’m doing wrong in PowerShell? (Be gentle, it's my first time 😉). Feel free to [open an issue](https://github.com/rickgemignani/Windows-Setup/issues) or reach out!

Happy scripting! 😎
