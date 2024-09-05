# Disable Windows Module Installer (Trusted Installer).
# Trusted Installe enables installation, modification, and removal of Windows updates and optional components.
# If this service is disabled, install or uninstall of Windows updates might fail for this computer.
sc.exe config TrustedInstaller start=disabled
