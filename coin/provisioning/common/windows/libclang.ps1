param(
    [string]$archVer="32",
    [string]$toolchain="vs2022",
    [bool]$setDefault=$true,
    [bool]$useArchInToolchainSuffix=$false
)
. "$PSScriptRoot\helpers.ps1"

$libclang_version="20.1.0"
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

    $script:OfficialUrl = "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-$libclang_version-windows-$toolchain`_$archVer.7z"
    $script:CachedUrl = "http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-$libclang_version-windows-$toolchain`_$archVer.7z"

    Download $OfficialUrl $CachedUrl $zip
    Verify-Checksum $zip $sha1
    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove "$zip"
}

$toolchainSuffix = ""

if ( $toolchain -eq "vs2022" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "60c840e627b5bb03663f00db17bf249b37936428"
    }
    elseif ( $archVer -eq "arm64" ) {
        $sha1 = "68ead0e3135dfccae21b226f187fc305803ede3d"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "2180859572dd6ad2029ecffffcc785cba334e037"
    }
    else {
        $sha1 = ""
    }
    $toolchainSuffix = "mingw"
}


if ( $toolchain -eq "llvm-mingw" ) {
    if ( $archVer -eq "64" ) {
        $sha1 = "3e917d002f363c225e5ee2b7d8999a3cabd8b467"
    }
    else {
        $sha1 = ""
    }
    # Due to COIN-1137 forced to use a '_' instead of '-'
    $toolchainSuffix = "llvm_mingw"
}

if ( $useArchInToolchainSuffix ) {
    $toolchainSuffix += "_$archVer"
}

install $sha1 $baseDestination-$archVer

if ( $setDefault ) {
    Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-$archVer")
}
Set-EnvironmentVariable ("LLVM_INSTALL_DIR_${toolchainSuffix}") ($baseDestination + "-$archVer")
