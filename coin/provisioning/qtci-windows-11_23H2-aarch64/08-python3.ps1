# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

# Downloading https://www.python.org/ftp/python/3.14.10/python-3.14.10-arm64.exe
. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "70b15480c9570526ac67f8e8e3daa90973172098" "C:\Python314" "3.14.10" $true
& "$PSScriptRoot\..\common\windows\python-pip-security.ps1" "C:\Python314"
