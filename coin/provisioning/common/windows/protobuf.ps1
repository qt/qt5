# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# Here we build protobuf libraries for MinGW and MSVC.
# Since it's a c++ library we need both msvc and mingw because they mangle symbols differently.
# For MSVC it builds with both debug and release configurations because of the visual c++ runtime.
# For MinGW we only need one, so we only build with release.
# The function below takes care of the common part of building - invoking cmake,
# calling ninja and installing it to a directory which we set an environment variable to.
# Because we have two compilers we also have two env. vars. and then each
# config in CI has the Protobuf_ROOT set to the appropriate one.
function build-install-protobuf {
    param(
        [string]$CC,
        [string]$CXX,
        [string]$BuildType,
        [string]$Postfix, # Used for install-path and the environment variable name
        [string[]]$ExtraArguments = @()
    )
    $installPrefix = "C:\Utils\protobuf"
    $installPath = "${installPrefix}-$Postfix"
    Write-Output "Configuring and building protobuf for $CXX"
    $oldCC = $env:CC
    $oldCXX = $env:CXX
    $env:CC = $CC
    $env:CXX = $CXX
    mkdir build
    Push-Location build
    cmake .. -G"Ninja Multi-Config" -DCMAKE_CONFIGURATION_TYPES="$BuildType" -DCMAKE_INSTALL_PREFIX="$installPath" -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_WITH_ZLIB=OFF -DCMAKE_DEBUG_POSTFIX="d" -DCMAKE_RELWITHDEBINFO_POSTFIX="rd" $ExtraArguments
    # ninja install:all # This is broken and does not work
    foreach ($config in $BuildType.split(";")) {
        ninja -f "build-$config.ninja" install
    }
    $env:CC = $oldCC
    $env:CXX = $oldCXX
    Set-EnvironmentVariable "Protobuf_ROOT_$Postfix" "$installPath"
    # Set environment variable without "Machine" scope to be used by grpc.ps1 script
    [Environment]::SetEnvironmentVariable("Protobuf_ROOT_$Postfix", "$installPath")
    Pop-Location
    Remove build
}

function Find-Tool {
    param(
        [string]$Name,
        [string]$Path
    )
    # Is tool missing from path?
    if (!(Get-Command $Name -ErrorAction SilentlyContinue)) {
        # Is tool in the $Path directory?
        if (Test-Path "$Path\$Name") {
            $env:Path += ";$Path"
        }
        else {
            throw "Cannot find $Name in path or $Name in $Name, something is configured wrong"
        }
    }
}
# This script is fairly late in provisioning so both of these should be present!
Find-Tool -Name "cmake.exe" -Path "C:\CMake\bin"
Find-Tool -Name "ninja.exe" -Path "C:\Utils\Ninja"

$version = "21.9"
$sha1 = "3226a0e49d048759b702ae524da79387c59f05cc"
$internalUrl = "http://ci-files01-hki.ci.qt.io/input/protobuf/protobuf-all-$version.zip"
$externalUrl = "https://github.com/protocolbuffers/protobuf/releases/download/v$version/protobuf-all-$version.zip"

$targetDir = "$env:HOMEDRIVE\$env:HOMEPATH\protobuf-$version"
$targetFile = "$targetDir.zip"
Download  $externalUrl $internalUrl $targetFile
Verify-Checksum $targetFile $sha1
Extract-7Zip $targetFile (Join-Path $env:HOMEDRIVE $env:HOMEPATH)
Remove $targetFile


# cd into the cmake directory where the CMakeLists.txt file is located
# then we build in a build\ subfolder there for simplicity's sake
Push-Location $targetDir

### MinGW

# Check if mingw is where we expect it to be and add it to path:
$mingwPath = [System.Environment]::GetEnvironmentVariable("MINGW_PATH", [System.EnvironmentVariableTarget]::Machine) + "\bin"
if (!(Test-Path $mingwPath)) {
    throw "Cannot find mingw in $mingwPath, something is configured wrong"
}

$oldPath = $env:Path
$env:Path = "$mingwPath;$env:Path"
build-install-protobuf -CC "gcc" -CXX "g++" -BuildType "Release;RelWithDebInfo;Debug" -Postfix "mingw"
$env:Path = $oldPath

### LLVM MinGW

$llvmMingwPath = "C:\llvm-mingw"
if (!(Test-Path $llvmMingwPath)) {
    throw "Cannot find llvm-mingw in $llvmMingwPath, something is configured wrong"
}

$oldPath = $env:Path
$env:Path = "$llvmMingwPath\bin;$env:Path"
build-install-protobuf -CC "clang" -CXX "clang++" -BuildType "Release;RelWithDebInfo;Debug" -Postfix "llvm_mingw"
$env:Path = $oldPath

### MSVC

EnterVSDevShell

# We pass along an extra argument to stop protobuf linking with the static runtime
build-install-protobuf -CC "cl" -CXX "cl" -BuildType "Release;RelWithDebInfo;Debug" -Postfix "msvc" -ExtraArguments @("-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")

$env:Path = $oldPath
Pop-Location
Remove $targetDir

Write-Output "Protobuf = $version" >> ~/versions.txt
