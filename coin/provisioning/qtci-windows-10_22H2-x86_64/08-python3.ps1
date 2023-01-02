# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "3ee4e92a8ef94c70fb56859503fdc805d217d689" "C:\Python310_64" "3.10.0"
# default ones
. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "a8ac14ee5486547caf84abdf151be22d9d069c0a" "C:\Python38_64" "3.8.1" $true
. "$PSScriptRoot\..\common\windows\python3.ps1" 32 "14ff2c2e5538b03a012cb4c9d519d970444ebd42" "C:\Python38_32" "3.8.1" $true
