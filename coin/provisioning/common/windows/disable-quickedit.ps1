# Disabling cmd.exe and powershell QuickEdit && InsertMode
#
# These two can freeze console window on win10 sometimes
# manual recovery is pressing enter on console window

. "$PSScriptRoot\helpers.ps1"

Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Console`" /V QuickEdit /T REG_dWORD /D 0 /F"
Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Console`" /V InsertMode /T REG_dWORD /D 0 /F"
Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe`" /V QuickEdit /T REG_dWORD /D 0 /F"
Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe`" /V InsertMode /T REG_dWORD /D 0 /F"
Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe`" /V QuickEdit /T REG_dWORD /D 0 /F"
Run-Executable "reg.exe" "ADD `"HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe`" /V InsertMode /T REG_dWORD /D 0 /F"
