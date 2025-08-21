param(
    [Int32]$archVer=32,
    [string]$toolchain="vs2019",
    [bool]$setDefault=$true
)
. "$PSScriptRoot\helpers.ps1"

$libclang_version="10.0"
Write-Output "libClang for QtForPython = $libclang_version" >> ~/versions.txt

# PySide versions following Qt6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 8.0 or higher is required for building.

# Starting from Qt 5.11 QDoc requires Clang to parse C++

$baseDestination = "C:\Utils\libclang-" + $libclang_version + "-dynlibs-" + $toolchain
$libclang_version = $libclang_version -replace '["."]'

function install() {

    param(
        [string]$sha1=$1,
        [string]$destination=$2
    )

    $zip = "c:\users\qt\downloads\libclang-dyn.7z"

    $script:OfficialUrl = "https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_$libclang_version-based-windows-$toolchain`_$archVer.7z"
    $script:CachedUrl = "http://ci-files01-hki.ci.qt.io/input/libclang/dynamic/libclang-release_$libclang_version-based-windows-$toolchain`_$archVer.7z"

    Download $OfficialUrl $CachedUrl $zip
    Verify-Checksum $zip $sha1
    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove-Item -Force -Path $zip
}

if ( $toolchain -eq "vs2019" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "B2C4F24B2388AEBAA6B8FCE3AE4E63D34D1517FE"
    }
    else {
        $sha1 = "b970f51df255a27e0fdb7b665e70ed5281257f40"
    }
}

install $sha1 $baseDestination-$archVer

Set-EnvironmentVariable "LLVM_DYNAMIC_LIBS_100" ($baseDestination + "-_ARCH_")

