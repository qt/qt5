#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

version="3.1.37"
versionNode="v14.18.2"
tarBallVersion=$(sed "s/\./\_/g" <<<"$version")
if uname -a |grep -q Darwin; then
    tarBallPackage="emsdk_macos_${tarBallVersion}.tar.gz"
    sha="fe9900b0f27ada608f25552dbd4a58bf62c6f05b"
else
    tarBallPackage="emsdk_linux_${tarBallVersion}.tar.gz"
    sha="000bbd5666d8fc1afbf2dce1a7938ef0efeeab3f"
fi
cacheUrl="https://ci-files01-hki.intra.qt.io/input/emsdk/${tarBallPackage}"
target="/tmp/${tarBallPackage}"

mkdir -p /opt
cd /opt
echo "URL: $cacheUrl"

if DownloadURL "$cacheUrl" "" "$sha" "$target"; then
    sudo tar -xzf "$target" -C /opt/
    sudo rm -f "$target"
else
    echo "Emsdk isn't cached. Cloning it"
    sudo git clone https://github.com/emscripten-core/emsdk.git
    cd emsdk
    sudo ./emsdk install "$version"
    sudo ./emsdk activate "$version"
fi

# platform-specific toolchain and node binaries. urls obtained from "emsdk install"
if uname -a |grep -q Darwin; then
    pathNodeExecutable="node-$versionNode-darwin-x64/bin/node"
else
    pathNodeExecutable="node-$versionNode-linux-x64/bin/node"
fi

emsdkPath="/opt/emsdk/"
emscriptenPath="${emsdkPath}upstream/emscripten/"

SetEnvVar "PATH" "\"\$PATH:${emscriptenPath}\""
SetEnvVar "EMSCRIPTEN" "${emscriptenPath}"
SetEnvVar "EMSDK" "${emsdkPath}"
SetEnvVar "EMSDK_NODE" "${emsdkPath}${pathNodeExecutable}"

echo "Emsdk = $version" >> ~/versions.txt
