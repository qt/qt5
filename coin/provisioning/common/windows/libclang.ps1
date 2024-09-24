param(
    [string]$archVer="32",
    [string]$toolchain="vs2019",
    [bool]$setDefault=$true
)
. "$PSScriptRoot\helpers.ps1"

$libclang_version="18.1.7"
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
    $script:CachedUrl = "http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_$libclang_version-based-windows-$toolchain`_$archVer.7z"

    Download $OfficialUrl $CachedUrl $zip
    Verify-Checksum $zip $sha1
    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove "$zip"
}

$toolchainSuffix = ""

if ( $toolchain -eq "vs2022" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "7e51f0eabdfe8eea17aaf1dce7b2ffe1ea064f66"
    }
    elseif ( $archVer -eq "arm64" ) {
        $sha1 = "986d4d0f253de505ef499345238c101dac1ca3a6"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "vs2019" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "8e0862386caef7e4537599ef980eeb6ebee8767f"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "a23cbb0822cf2eb8d1cecf26e8614ef37a7611e3"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "mingw"
}


if ( $toolchain -eq "llvm-mingw" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "9c34f99eb575b42c2befe27829c08e6d3f01ae58"
    }
    else {
        $sha1 = ""
    }
    # Due to COIN-1137 forced to use a '_' instead of '-'
    $toolchainSuffix = "llvm_mingw"
}


install $sha1 $baseDestination-$archVer

if ( $setDefault ) {
    Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-$archVer")
}
Set-EnvironmentVariable ("LLVM_INSTALL_DIR_${toolchainSuffix}") ($baseDestination + "-$archVer")
