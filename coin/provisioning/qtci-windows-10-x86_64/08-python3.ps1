# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "a8ac14ee5486547caf84abdf151be22d9d069c0a" "C:\Python38_64" "3.8.1"
. "$PSScriptRoot\..\common\windows\python3.ps1" 32 "14ff2c2e5538b03a012cb4c9d519d970444ebd42" "C:\Python38_32" "3.8.1"
# default ones
. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "bf54252c4065b20f4a111cc39cf5215fb1edccff" "C:\Python36" "3.6.1" $true
. "$PSScriptRoot\..\common\windows\python3.ps1" 32 "76c50b747237a0974126dd8b32ea036dd77b2ad1" "C:\Python36_32" "3.6.1" $true
