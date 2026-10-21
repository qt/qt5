# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

# Downloading https://www.python.org/ftp/python/3.14.3/python-3.14.3-arm64.exe
. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "1465dedffbc0756f2a66af30e9fbb770a6e55dc7" "C:\Python314" "3.14.3" $true
& "$PSScriptRoot\..\common\windows\python-pip-security.ps1" "C:\Python314"
