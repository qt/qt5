. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\cmake-3.6.2-win32-x86.zip"

Download https://cmake.org/files/v3.6/cmake-3.6.2-win32-x86.zip http://ci-files01-hki.ci.local/input/cmake/cmake-3.6.2-win32-x86.zip $zip
Verify-Checksum $zip "541F6E7EFD228E46770B8631FFE57097576E4D4E"

Extract-Zip $zip C:
Remove-Item C:\CMake -Force -Recurse
Rename-Item C:\cmake-3.6.2-win32-x86 C:\CMake
