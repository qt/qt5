. "$PSScriptRoot\helpers.ps1"

# Disable Windows Module Installer (Trusted Installer).
# Trusted Installe enables installation, modification, and removal of Windows updates and optional components.
# If this service is disabled, install or uninstall of Windows updates might fail for this computer.
Run-Executable "sc.exe" "config TrustedInstaller start=disabled"
