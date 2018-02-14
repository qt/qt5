. "$PSScriptRoot\helpers.ps1"

# Disable the windows search indexing service
Run-Executable "sc.exe" "config WSearch start= disabled"
