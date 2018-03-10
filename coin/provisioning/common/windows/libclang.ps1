param(
    [Int32]$archVer=32,
    [string]$toolchain="vs2015"
)
. "$PSScriptRoot\helpers.ps1"

# PySide versions following 5.6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 3.9 or higher is required for building.

# Starting from Qt 5.11 QDoc requires Clang to parse C++

Get-Content "$PSScriptRoot\..\shared\sw_versions.txt" | Foreach-Object {
    $var = $_.Split('=')
    New-Variable -Name $var[0] -Value $var[1]
    $libclang_version = $libclang_version -replace '["."]'
}

$zip = "c:\users\qt\downloads\libclang.7z"
$baseDestination = "C:\Utils\libclang-" + $libclang_version

function setURL() {
    $script:url = "https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_$libclang_version-windows-$toolchain`_$archVer.7z"
}

if ( $toolchain -eq "vs2015" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "dc42beb0efff130c4d7dfef3c97adf26f1ab04e0"
        $destination = $baseDestination + "-64"

        setURL
        Download $url $url $zip
        Verify-Checksum $zip $sha1

        Extract-7Zip $zip C:\Utils\
        Rename-Item C:\Utils\libclang $destination
        Remove-Item -Force -Path $zip
    }

    $archVer=32
    $sha1 = "64e826c00ae632fbb28655e6e1fa9194980e1205"
    $destination = $baseDestination + "-32"

    setURL
    Download $url $url $zip
    Verify-Checksum $zip $sha1

    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove-Item -Force -Path $zip
}

if ( $toolchain -eq "mingw" ) {
    if ( $archVer -eq 64 ) {
        $sha1 = "3e318f70a1e76c14365ced65f4fa7031bb730818"
        $destination = $baseDestination + "-64"

        setURL
        Download $url $url $zip
        Verify-Checksum $zip $sha1

        Extract-7Zip $zip C:\Utils\
        Rename-Item C:\Utils\libclang $destination
        Remove-Item -Force -Path $zip
    }

    $archVer=32
    $sha1 = "a9973192a01a9c16976ed0cc6ef6dac3dbc4a2d3"
    $destination = $baseDestination + "-32"

    setURL
    Download $url $url $zip
    Verify-Checksum $zip $sha1

    Extract-7Zip $zip C:\Utils\
    Rename-Item C:\Utils\libclang $destination
    Remove-Item -Force -Path $zip
}

Set-EnvironmentVariable "LLVM_INSTALL_DIR" ($baseDestination + "-_ARCH_")
Write-Output "libClang = $libclang_version" >> ~/versions.txt
