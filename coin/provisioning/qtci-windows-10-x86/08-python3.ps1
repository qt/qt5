# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

. "$PSScriptRoot\..\common\windows\python3.ps1" 32 "cd9744b142eca832f9534390676e6cfb84bf655d" "C:\Python36" "3.6.2" $true
