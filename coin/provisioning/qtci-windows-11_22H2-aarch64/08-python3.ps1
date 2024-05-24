# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

# Downloading https://www.python.org/ftp/python/3.11.9/python-3.11.9-arm64.exe
. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "9e0487af5f0472978b7b6d4f4d3d8fd56865ff97" "C:\Python311_64" "3.11.9" $true
