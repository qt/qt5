param(
    [Int32]$archVer=32,
    [string]$toolchain="vs2015",
    [bool]$setDefault=$true
)
. "$PSScriptRoot\helpers.ps1"

# PySide versions following 5.6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 3.9 or higher is required for building.

# Starting from Qt 5.11 QDoc requires Clang to parse C++

Get-Content "$PSScriptRoot\..\shared\sw_versions.txt" | Foreach-Object {
    $var = $_.Split('=')
    New-Variable -Name $var[0] -Value $var[1] -Force
    $libclang_version = $libclang_version -replace '["."]'
}

$zip = Get-DownloadLocation "libclang.7z"
$baseDestination = "C:\Utils\libclang-" + $libclang_version + "-" + $toolchain

function setURL() {
    $script:url = "https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_$libclang_version-windows-$toolchain`_$archVer.7z"
}

$toolchainSuffix = ""

if ( $toolchain -eq "vs2015" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "37afa18d243a50c05bee5c6e16b409ed526ec17a"
        $destination = $baseDestination + "-64"

        setURL
        Download $url $url $zip
        Verify-Checksum $zip $sha1

        Extract-7Zip $zip C:\Utils\
        Rename-Item C:\Utils\libclang $destination
        Remove-Item -Force -Path $zip
    }

    $archVer=32
    $sha1 = "812b6089c6da99ced9ebebbd42923bd96590519d"
    $destination = $baseDestination + "-32"

    setURL
    Download $url $url $zip
    Verify-Checksum $zip $sha1

    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove-Item -Force -Path $zip
    $toolchainSuffix = "msvc"
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "1233e6c008b90d89483df0291a597a0bac426d29"
        $destination = $baseDestination + "-64"

        setURL
        Download $url $url $zip
        Verify-Checksum $zip $sha1

        Extract-7Zip $zip C:\Utils\
        Rename-Item C:\Utils\libclang $destination
        Remove-Item -Force -Path $zip
    }

    $archVer=32
    $sha1 = "2d6ceab0e1a05e2b19fe615c57b64d36977b4933"
    $destination = $baseDestination + "-32"

    setURL
    Download $url $url $zip
    Verify-Checksum $zip $sha1

    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove-Item -Force -Path $zip
    $toolchainSuffix = "mingw"
}

if ( $setDefault ) {
    Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-_ARCH_")
}
Set-EnvironmentVariable ("LLVM_INSTALL_DIR_" + $toolchainSuffix) ($baseDestination + "-_ARCH_")
Write-Output "libClang = $libclang_version" >> ~/versions.txt

if ( $libclang_version -eq "60" ) {
    # This is a hacked static build of libclang which requires special
    # handling on the qdoc side.
    Set-EnvironmentVariable "QDOC_USE_STATIC_LIBCLANG" "1"
}
