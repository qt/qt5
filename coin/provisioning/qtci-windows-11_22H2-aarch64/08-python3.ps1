# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

# Downloading https://www.python.org/ftp/python/3.12.3/python-3.12.3-arm64.exe
. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "a7fe973fd406c0db2b982d83e9feb30f8fde704f" "C:\Python312_64" "3.12.3" $true
