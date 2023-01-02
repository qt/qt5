. "$PSScriptRoot\..\common\windows\helpers.ps1"
# Needed by packaging scripts
$scriptsPath = [System.Environment]::GetEnvironmentVariable('PIP3_PATH', [System.EnvironmentVariableTarget]::Machine)
Run-Executable "$scriptsPath\pip3.exe" "install bs4"
