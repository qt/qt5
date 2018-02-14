. "$PSScriptRoot\helpers.ps1"

# Disable the NTP from syncing
Run-Executable "w32tm.exe" "/config /syncfromflags:NO"
