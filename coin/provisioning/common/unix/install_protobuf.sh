#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# Extract cmake path from the environment
if uname -a |grep -q "Ubuntu"; then
    if lsb_release -a |grep "Ubuntu 22.04"; then
        source ~/.bash_profile
    else
        source ~/.profile
    fi
else
    source ~/.bashrc
fi

# This script will install Google's Protocal Buffers

version="21.9"
sha1="3226a0e49d048759b702ae524da79387c59f05cc"
internalUrl="http://ci-files01-hki.ci.qt.io/input/automotive_suite/protobuf-all-$version.zip"
externalUrl="https://github.com/protocolbuffers/protobuf/releases/download/v$version/protobuf-all-$version.zip"

targetDir="$HOME/protobuf-$version"
targetFile="$targetDir.zip"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
unzip "$targetFile" -d "$HOME"
sudo rm "$targetFile"

cd $targetDir

if uname -a |grep -q "Ubuntu"; then
    echo 'diff --git a/cmake/conformance.cmake b/cmake/conformance.cmake
index d6c435ac3..d6fb3a7df 100644
--- a/cmake/conformance.cmake
+++ b/cmake/conformance.cmake
@@ -24,6 +24,8 @@ add_executable(conformance_test_runner
   ${protobuf_SOURCE_DIR}/conformance/conformance.pb.cc
   ${protobuf_SOURCE_DIR}/conformance/conformance_test.cc
   ${protobuf_SOURCE_DIR}/conformance/conformance_test_runner.cc
+  ${protobuf_SOURCE_DIR}/conformance/conformance_test_main.cc
+  ${protobuf_SOURCE_DIR}/conformance/text_format_conformance_suite.cc
   ${protobuf_SOURCE_DIR}/conformance/third_party/jsoncpp/json.h
   ${protobuf_SOURCE_DIR}/conformance/third_party/jsoncpp/jsoncpp.cpp
   ${protobuf_SOURCE_DIR}/src/google/protobuf/test_messages_proto2.pb.cc
@@ -36,6 +38,10 @@ add_executable(conformance_cpp
   ${protobuf_SOURCE_DIR}/src/google/protobuf/test_messages_proto2.pb.cc
   ${protobuf_SOURCE_DIR}/src/google/protobuf/test_messages_proto3.pb.cc
 )
+install(TARGETS conformance_test_runner
+    RUNTIME DESTINATION  COMPONENT conformance
+    LIBRARY DESTINATION  COMPONENT conformance
+    ARCHIVE DESTINATION  COMPONENT conformance)

 target_include_directories(
   conformance_test_runner' | patch -p1
    extraCMakeArgs=("-Dprotobuf_BUILD_CONFORMANCE=ON")
fi

# devtoolset is needed when running configuration
if uname -a |grep -qv "Darwin"; then
    export PATH="/opt/rh/devtoolset-7/root/usr/bin:$PATH"
fi

echo "Configuring and building protobuf"

installPrefix="/usr/local"
if uname -a |grep -q Darwin; then
    extraCMakeArgs=("-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64" -DCMAKE_OSX_DEPLOYMENT_TARGET=12)
    SetEnvVar PATH "\$PATH:$installPrefix/bin"
fi

buildDir="$HOME/build-protobuf-$version"
mkdir "$buildDir"
cd "$buildDir"
cmake "$targetDir" -G"Ninja Multi-Config" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_INSTALL_PREFIX=$installPrefix \
    "${extraCMakeArgs[@]}" \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -Dprotobuf_WITH_ZLIB=OFF \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug;RelWithDebugInfo" \
    -DCMAKE_CROSS_CONFIGS=all \
    -DCMAKE_DEFAULT_CONFIGS=all
ninja all:all
sudo env "PATH=$PATH" ninja install:all

# Refresh shared library cache if OS isn't macOS
if uname -a |grep -qv "Darwin"; then
    sudo ldconfig
fi

sudo rm -r "$targetDir"
sudo rm -r "$buildDir"
