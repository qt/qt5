param(
    [Int32]$archVer=32,
    [string]$toolchain="vs2019",
    [bool]$setDefault=$true
)
. "$PSScriptRoot\helpers.ps1"

$libclang_version="15.0.0"
Write-Output "libClang = $libclang_version" >> ~/versions.txt

# PySide versions following 5.6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 3.9 or higher is required for building.

# Starting from Qt 5.11 QDoc requires Clang to parse C++

$baseDestination = "C:\Utils\libclang-" + $libclang_version + "-" + $toolchain

function install() {

    param(
        [string]$sha1=$1,
        [string]$destination=$2
    )

    $zip = "c:\users\qt\downloads\libclang.7z"

    $script:OfficialUrl = "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_$libclang_version-based-windows-$toolchain`_$archVer.7z"
    $script:CachedUrl = "http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_$libclang_version-based-windows-$toolchain`_$archVer.7z"

    Download $OfficialUrl $CachedUrl $zip
    Verify-Checksum $zip $sha1
    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove "$zip"
}

$toolchainSuffix = ""

if ( $toolchain -eq "vs2019" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "e7c2d27f0e99d63e49225cb1be18c76a1e2a124b"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "6c9300051533d5648ffe3e8ae1eb00decae8e6bf"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "mingw"
}

install $sha1 $baseDestination-$archVer

if ( $setDefault ) {
    Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-$archVer")
}
Set-EnvironmentVariable ("LLVM_INSTALL_DIR_${toolchainSuffix}") ($baseDestination + "-$archVer")

if ( $libclang_version -eq "15.0.0" ) {
    # This is a hacked static build of libclang which requires special
    # handling on the qdoc side.
    Set-EnvironmentVariable "QDOC_USE_STATIC_LIBCLANG" "1"
}
