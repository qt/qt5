param(
    [Int32]$archVer=32,
    [string]$toolchain="vs2019",
    [bool]$setDefault=$true
)
. "$PSScriptRoot\helpers.ps1"

$libclang_version="10.0"
Write-Output "libClang = $libclang_version" >> ~/versions.txt

# PySide versions following 5.6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 3.9 or higher is required for building.

# Starting from Qt 5.11 QDoc requires Clang to parse C++

$baseDestination = "C:\Utils\libclang-" + $libclang_version + "-" + $toolchain
$libclang_version = $libclang_version -replace '["."]'

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
    Remove-Item -Force -Path $zip
}

$toolchainSuffix = ""

if ( $toolchain -eq "vs2019" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "6e1b3e6d38803a3bf088e521f4f4feb1ca44bac3"
    }
    else {
        $sha1 = "36fcdc3155eef3636d99ed591f12e73d7a9a2e0c"
    }
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "34daf2324d190de49f8e4005afeb39a7d70c5842"
    }
    else {
        $sha1 = "3d7c809ab12c9293df8ffd9343cee68f184c8612"
    }
    $toolchainSuffix = "mingw"
}

install $sha1 $baseDestination-$archVer

if ( $setDefault ) {
    Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-_ARCH_")
}
Set-EnvironmentVariable ("LLVM_INSTALL_DIR_" + $toolchainSuffix) ($baseDestination + "-_ARCH_")

if ( $libclang_version -eq "100" ) {
    # This is a hacked static build of libclang which requires special
    # handling on the qdoc side.
    Set-EnvironmentVariable "QDOC_USE_STATIC_LIBCLANG" "1"
}
