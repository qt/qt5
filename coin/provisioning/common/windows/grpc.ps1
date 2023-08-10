# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# Here we build gRPC libraries for MinGW and MSVC.
# Since it's a c++ library we need both msvc and mingw because they mangle symbols differently.
# For MSVC it builds with both debug and release configurations because of the visual c++ runtime.
# For MinGW we only need one, so we only build with release.
# The function below takes care of the common part of building - invoking cmake,
# calling ninja and installing it to a directory which we set an environment variable to.
# Because we have two compilers we also have two env. vars. and then each
# config in CI has the gRPC_ROOT set to the appropriate one.
function build-install-grpc {
    param(
        [string]$CC,
        [string]$CXX,
        [string]$BuildType,
        [string]$Postfix # Used for install-path and the environment variable name
    )
    $installPrefix = "C:\Utils\grpc"
    $installPath = "${installPrefix}-$Postfix"
    $envVariableName = "Protobuf_ROOT_$Postfix"
    $protobufRoot = (Get-Item -Path "Env:$envVariableName").Value
    Write-Output "Configuring and building gRPC for $CXX"
    $oldCC = $env:CC
    $oldCXX = $env:CXX
    $env:CC = $CC
    $env:CXX = $CXX
    Remove build-grpc
    mkdir build-grpc
    Push-Location build-grpc
    $configureOptions = @(
        # add postfix for multi-config
        "-DCMAKE_DEBUG_POSTFIX=d"
        "-DCMAKE_RELWITHDEBINFO_POSTFIX=rd"
        # plugins
        "-DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF"
        "-DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF"
        "-DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF"
        "-DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF"
        "-DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF"
        "-DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF"
        # extensions
        "-DgRPC_BUILD_CSHARP_EXT=OFF"
        # general
        "-DgRPC_BUILD_TESTS=OFF"
        "-DgRPC_PROTOBUF_PROVIDER=package"
        "-DgRPC_SSL_PROVIDER=package"
        # protobuf
        "-DProtobuf_USE_STATIC_LIBS=ON"
        "-DCMAKE_PREFIX_PATH=$protobufRoot"
    )
    cmake .. -G"Ninja Multi-Config" -DCMAKE_CONFIGURATION_TYPES="$BuildType" -DCMAKE_INSTALL_PREFIX="$installPath" $extraCMakeArgs $configureOptions
    $result = $LASTEXITCODE
    if ($result -eq 0) {
        # ninja install:all # This is broken and does not work
        foreach ($config in $BuildType.split(";")) {
            ninja -f "build-$config.ninja" install
        }
        $result = $LASTEXITCODE
    }
    $env:CC = $oldCC
    $env:CXX = $oldCXX
    Set-EnvironmentVariable "gRPC_ROOT_$Postfix" "$installPath"
    Pop-Location
    Remove build-grpc
    if ($result -ne 0) {
        throw "Build exited with $result"
    }
}


# Ensures a tool is in path or adds it to path if the $Path supplied to it
# contains it. Will throw if it's not found at all
function Find-Tool {
    param(
        [string]$Name,
        [string]$Path
    )
    # Is tool missing from path?
    if (!(Get-Command $Name -ErrorAction SilentlyContinue)) {
        # Is tool in the $Path directory?
        if (Test-Path "$Path\$Name" -ErrorAction SilentlyContinue) {
            $env:Path += ";$Path"
        }
        else {
            throw "Cannot find $Name in path or $Name in $Path, something is configured wrong"
        }
    }
}
# This script is fairly late in provisioning so both of these should be present!
Find-Tool -Name "cmake.exe" -Path "C:\CMake\bin"
Find-Tool -Name "ninja.exe" -Path "C:\Utils\Ninja"

$version="1.50.1"
$sha1="be1b0c3dbfbc9714824921f50dffb7cf044da5ab"
$internalUrl="http://ci-files01-hki.ci.qt.io/input/automotive_suite/grpc-all-$version.zip"
$externalUrl=""

$basedir = "$env:HOMEDRIVE\$env:HOMEPATH\grpc"
mkdir $basedir
$targetDir = "$basedir\grpc-$version"
$targetFile = "$targetDir.zip"
Download  $externalUrl $internalUrl $targetFile
Verify-Checksum $targetFile $sha1
Extract-7Zip $targetFile $basedir
Remove $targetFile

Push-Location $targetDir

### gRPC supports only MSVC compiler

EnterVSDevShell

# We pass along an extra argument to stop gRPC linking with the static runtime to match Protobuf config
build-install-grpc -CC "cl" -CXX "cl" -BuildType "Release;RelWithDebInfo;Debug" -Postfix "msvc" -ExtraArguments @("-DgRPC_MSVC_STATIC_RUNTIME=OFF")

Pop-Location
Remove $basedir

Write-Output "gRPC = $version" >> ~/versions.txt
