# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "3ee4e92a8ef94c70fb56859503fdc805d217d689" "C:\Python310_64" "3.10.0" $true
& "$PSScriptRoot\..\common\windows\python-pip-security.ps1" "C:\Python310_64"
