# This script will disable automatic disk cleanup

. "$PSScriptRoot\helpers.ps1"

Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy`" /V 04 /T REG_dWORD /D 0 /F"

# Maintenance task used by the system to launch a silent auto disk cleanup when running low on free disk space.
DisableSchedulerTask "DiskCleanup\SilentCleanup"
