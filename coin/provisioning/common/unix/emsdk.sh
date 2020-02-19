#!/usr/bin/env bash
#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

# shellcheck source=./InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/InstallFromCompressedFileFromURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"
# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

version="1.39.8"
urlCache="http://ci-files01-hki.intra.qt.io/input/emsdk"
targetFolder="/opt/emsdk"

# cross-platform emscripten SDK
urlEmscriptenExternal="https://github.com/emscripten-core/emscripten/archive/$version.tar.gz"
urlEmscriptenCache="$urlCache/emscripten.$version.tar.gz"
sha1Emscripten="a593ea3b4ab7e3d57e1232b19a903ccf8f137d2f"

# platform-specific toolchain and node binaries. urls obtained from "emsdk install"
if uname -a |grep -q Darwin; then
    urlWasmBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/mac/9e60f34accb4627d7358223862a7e74291886ab6/wasm-binaries.tbz2"
    urlWasmBinariesCache="$urlCache/macos/wasm-binaries.$version.tbz2"
    sha1WasmBinaries="aedb30fb07d565c35305af0920ab072ae743895d"

    urlNodeBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v12.9.1-darwin-x64.tar.gz"
    urlNodeBinariesCache="$urlCache/mac/node-v12.9.1-darwin-x64.tar.gz"
    sha1NodeBinaries="f5976321ded091e70358e406b223f6fd64e35a43"
    pathNodeExecutable='node-v12.9.1-darwin-x64/bin/node'
else
    urlWasmBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/9e60f34accb4627d7358223862a7e74291886ab6/wasm-binaries.tbz2"
    urlWasmBinariesCache="$urlCache/linux/wasm-binaries.$version.tbz2"
    sha1WasmBinaries="eb7fc94aa79a6e215272e2586173515aa37c3141"

    urlNodeBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v12.9.1-linux-x64.tar.xz"
    urlNodeBinariesCache="$urlCache/linux/node-v12.9.1-linux-x64.tar.xz"
    sha1NodeBinaries="cde96023b468d593c50de27470dd714c8cfda9aa"
    pathNodeExecutable='node-v12.9.1-linux-x64/bin/node'
fi

sudo mkdir "$targetFolder"

InstallFromCompressedFileFromURL "$urlEmscriptenCache" "$urlEmscriptenExternal" "$sha1Emscripten" "$targetFolder" ""
InstallFromCompressedFileFromURL "$urlWasmBinariesCache" "$urlWasmBinariesExternal" "$sha1WasmBinaries" "$targetFolder" ""
InstallFromCompressedFileFromURL "$urlNodeBinariesCache" "$urlNodeBinariesExternal" "$sha1NodeBinaries" "$targetFolder" ""

sudo chmod -R a+rwx "$targetFolder"

echo "Writing $targetFolder/.emscripten"
cat <<EOM >"$targetFolder/.emscripten"
EMSCRIPTEN_ROOT='$targetFolder/emscripten-$version'
LLVM_ROOT='$targetFolder/install/bin'
BINARYEN_ROOT='$targetFolder/install'
NODE_JS='$targetFolder/$pathNodeExecutable'
TEMP_DIR = '/tmp'
EOM

SetEnvVar "PATH" "\"\$PATH:$targetFolder/emscripten-$version/\""
SetEnvVar "EMSCRIPTEN" "$targetFolder/emscripten-$version"
SetEnvVar "EM_CONFIG" "$targetFolder/.emscripten"

echo "Emsdk = $version" >> ~/versions.txt
