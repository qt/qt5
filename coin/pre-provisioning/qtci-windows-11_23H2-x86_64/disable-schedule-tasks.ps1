. "$PSScriptRoot\helpers.ps1"

# This script will remove unneeded Tasks from Task Scheduler

# Application Experience 'Microsoft Compatibility Appraiser' - "Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program."
DisableSchedulerTask "Application Experience\Microsoft Compatibility Appraiser"

# Application Experience 'ProgramDataUpdater' - "Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program"
DisableSchedulerTask "Application Experience\ProgramDataUpdater"

# Autochk 'Proxy' - "This task collects and uploads autochk SQM data if opted-in to the Microsoft Customer Experience Improvement Program."
DisableSchedulerTask "Autochk\Proxy"

# Chkdsk 'ProactiveScan' - "NTFS Volume Health Scan"
DisableSchedulerTask "Chkdsk\ProactiveScan"

# Chkdsk 'SyspartRepair'
DeleteSchedulerTask "Chkdsk\SyspartRepair"

# Customer Experience Improvement Program 'Consolidator' - "If the user has consented to participate in the Windows Customer Experience Improvement Program, this job collects and sends usage data to Microsoft."
DisableSchedulerTask "Customer Experience Improvement Program\Consolidator"

# Customer Experience Improvement Program 'sbCeip' - "The USB CEIP (Customer Experience Improvement Program) task collects Universal Serial Bus related statistics and information about your machine and sends it to the Windows Device Connectivity engineering group at Microsoft.  The information received is used to help improve the reliability, stability, and overall functionality of USB in Windows.  If the user has not consented to participate in Windows CEIP, this task does not do anything."
DisableSchedulerTask "Customer Experience Improvement Program\UsbCeip"

# Device Information 'Device'
DisableSchedulerTask "Device Information\Device"

# Diagnosis 'Scheduled' - "The Windows Scheduled Maintenance Task performs periodic maintenance of the computer system by fixing problems automatically or reporting them through Security and Maintenance."
DisableSchedulerTask "Diagnosis\Scheduled"

# DiskDiagnostic 'Microsoft-Windows-DiskDiagnosticDataCollector' - "The Windows Disk Diagnostic reports general disk and system information to Microsoft for users participating in the Customer Experience Program."
DisableSchedulerTask "DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"

# ExploitGuard 'ExploitGuard MDM policy Refresh' - "Task for applying changes to the machine's Exploit Protection settings."
DisableSchedulerTask "ExploitGuard\ExploitGuard MDM policy Refresh"

# Feedback/Siuf 'DmClient'
DisableSchedulerTask "Feedback\Siuf\DmClient"

# Feedback/Siuf 'DmClient'OnScenarioDownload'
DisableSchedulerTask "Feedback\Siuf\DmClientOnScenarioDownload"

# File Classification Infrastructure 'Property Definition Sync'
DisableSchedulerTask "File Classification Infrastructure\Property Definition Sync"

# InstallService 'ScanForUpdates'
DisableSchedulerTask "InstallService\ScanForUpdates"

# InstallService 'ScanForUpdatesAsUser'
DisableSchedulerTask "InstallService\ScanForUpdatesAsUser"

# LanguageComponentsInstaller  'Installation' - "Install language components that match the user's language list."
DisableSchedulerTask "LanguageComponentsInstaller\Installation"

# LanguageComponentsInstaller 'ReconcileLanguageResources' - "Install language components that match the user's language list."
DisableSchedulerTask "LanguageComponentsInstaller\ReconcileLanguageResources"

# PI 'Secure-Boot-Update' - "This task updates the Secure Boot variables."
DisableSchedulerTask "PI\Secure-Boot-Update"

# PI 'Sqm-Tasks' - "This task gathers information about the Trusted Platform Module (TPM), Secure Boot, and Measured Boot."
DisableSchedulerTask "PI\Sqm-Tasks"

# Power Efficiency Diagnotics 'AnalyzeSystem' - "This task analyzes the system looking for conditions that may cause high energy use."
DisableSchedulerTask "PushToInstall\Registration"

# Servicing 'StartComponentCleanup'
DisableSchedulerTask "Servicing\StartComponentCleanup"

# SoftwareProtectionPlatform 'SvcRestartTaskNetwork' - "This task restarts the Software Protection Platform service when a new network is detected"
DisableSchedulerTask "SoftwareProtectionPlatform\SvcRestartTaskNetwork"
