#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

version="4.0.7"
versionNode="v20.18.0"
tarBallVersion="${version//./_}"
if uname -a | grep -q Darwin; then
    tarBallPackage="emsdk_macos_${tarBallVersion}.tar.gz"
    sha="c3d2df45685b68e5d69e09017084d26783eda2dd"
else
    tarBallPackage="emsdk_linux_${tarBallVersion}.tar.gz"
    sha="20f7782ca4a9088fe91405b16c6fed630e91dcd6"
fi
cacheUrl="https://ci-files01-hki.ci.qt.io/input/emsdk/${tarBallPackage}"
target="/tmp/${tarBallPackage}"

mkdir -p /opt
cd /opt || exit
echo "URL: $cacheUrl"

if DownloadURL "$cacheUrl" "" "$sha" "$target"; then
    sudo tar -xzf "$target" -C /opt/
    sudo rm -f "$target"
else
    echo "Emsdk isn't cached. Cloning it"
    sudo git clone https://github.com/emscripten-core/emsdk.git
    cd emsdk || exit
    if ! sudo ./emsdk install "$version"; then
        echo "Error: emsdk installation failed"
        exit 1
    fi
    sudo ./emsdk activate "$version"
fi

# platform-specific toolchain and node binaries. urls obtained from "emsdk install"
if uname -a | grep -q Darwin; then
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
SetEnvVar "EMSDK_PYTHON" "$PYTHON3_EXECUTABLE"

echo "Emsdk = $version" >> ~/versions.txt
