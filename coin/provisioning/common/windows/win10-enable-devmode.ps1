# Turning on developer mode.
#
# In order to run auto tests for UWP, we have to enable developer mode on Windows 10 machines.
# https://docs.microsoft.com/en-us/windows/uwp/get-started/enable-your-device-for-development

. "$PSScriptRoot\helpers.ps1"

if (Is64BitWinHost) {
    $bitness = "/reg:64"
} else {
    $bitness = "/reg:32"
}

Run-Executable "reg.exe" "ADD `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock`" /V  AllowDevelopmentWithoutDevLicense /T REG_DWORD /D 1 /F $bitness"
