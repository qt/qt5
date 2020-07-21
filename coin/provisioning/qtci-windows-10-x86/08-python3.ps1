# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

. "$PSScriptRoot\..\common\windows\python3.ps1" 32 "76c50b747237a0974126dd8b32ea036dd77b2ad1" "C:\Python36" "3.6.1" $true
