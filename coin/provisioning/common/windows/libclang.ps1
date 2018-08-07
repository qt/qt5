param(
    [Int32]$archVer=32,
    [string]$toolchain="vs2015",
    [bool]$setDefault=$true
)
. "$PSScriptRoot\helpers.ps1"

$libclang_version="6.0"
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

    $script:OfficialUrl = "https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_$libclang_version-windows-$toolchain`_$archVer.7z"
    $script:CachedUrl = "http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_$libclang_version-windows-$toolchain`_$archVer.7z"

    Download $OfficialUrl $CachedUrl $zip
    Verify-Checksum $zip $sha1
    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove-Item -Force -Path $zip
}

$toolchainSuffix = ""

if ( $toolchain -eq "vs2015" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "a399af949271e6d3bfc578ea2c17ff1d6c6318b9"
        $destination = $baseDestination + "-64"

        install $sha1 $destination
    }

    $archVer=32
    $sha1 = "aa3f68f1cfa87780a4631a98ce883d3d9cb94330"
    $destination = $baseDestination + "-32"

    install $sha1 $destination
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "b382502f82d1cfa7d3cc3016d909d37edc19c22c"
        $destination = $baseDestination + "-64"

        install $sha1 $destination
    }

    $archVer=32
    $sha1 = "cbc68e0f93f4cb0ed7084a045b7c07a1980a2a44"
    $destination = $baseDestination + "-32"

    install $sha1 $destination
    $toolchainSuffix = "mingw"
}

if ( $setDefault ) {
    Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-_ARCH_")
}
Set-EnvironmentVariable ("LLVM_INSTALL_DIR_" + $toolchainSuffix) ($baseDestination + "-_ARCH_")

if ( $libclang_version -eq "60" ) {
    # This is a hacked static build of libclang which requires special
    # handling on the qdoc side.
    Set-EnvironmentVariable "QDOC_USE_STATIC_LIBCLANG" "1"
}
