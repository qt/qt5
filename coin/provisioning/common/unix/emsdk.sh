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

version="2.0.14"
versionTag="fc5562126762ab26c4757147a3b4c24e85a7289e"
versionNode="v14.15.5"
urlCache="http://ci-files01-hki.intra.qt.io/input/emsdk"
targetFolder="/opt/emsdk"

# cross-platform emscripten SDK
urlEmscriptenExternal="https://github.com/emscripten-core/emscripten/archive/$version.tar.gz"
urlEmscriptenCache="$urlCache/emscripten.$version.tar.gz"
sha1Emscripten="5fbdca8ed238b90ab8c3656831fcc5eb1ce08c58"

# platform-specific toolchain and node binaries. urls obtained from "emsdk install"
if uname -a |grep -q Darwin; then
    urlWasmBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/mac/$versionTag/wasm-binaries.tbz2"
    urlWasmBinariesCache="$urlCache/macos/wasm-binaries.$version.tbz2"
    sha1WasmBinaries="86dc16b299543cf593abc6f0137f8d0d723baddb"

    urlNodeBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-$versionNode-darwin-x64.tar.gz"
    urlNodeBinariesCache="$urlCache/mac/node-$versionNode-darwin-x64.tar.gz"
    sha1NodeBinaries="6db16d024ea9e5f2ebdd0c1ef07ea67c2004ce93"
    pathNodeExecutable="node-$versionNode-darwin-x64/bin/node"
else
    urlWasmBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/$versionTag/wasm-binaries.tbz2"
    urlWasmBinariesCache="$urlCache/linux/wasm-binaries.$version.tbz2"
    sha1WasmBinaries="9724185c06c461edec3495e37e034066479b9ccf"

    urlNodeBinariesExternal="https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-$versionNode-linux-x64.tar.xz"
    urlNodeBinariesCache="$urlCache/linux/node-$versionNode-linux-x64.tar.xz"
    sha1NodeBinaries="ca7ce363ceaf71b65e85243a71252c20cfd97982"
    pathNodeExecutable="node-$versionNode-linux-x64/bin/node"
fi

sudo mkdir "$targetFolder"

InstallFromCompressedFileFromURL "$urlEmscriptenCache" "$urlEmscriptenExternal" "$sha1Emscripten" "$targetFolder" ""
InstallFromCompressedFileFromURL "$urlWasmBinariesCache" "$urlWasmBinariesExternal" "$sha1WasmBinaries" "$targetFolder" ""
InstallFromCompressedFileFromURL "$urlNodeBinariesCache" "$urlNodeBinariesExternal" "$sha1NodeBinaries" "$targetFolder" ""

sudo chmod -R a+rwx "$targetFolder"

echo "Writing $targetFolder/.emscripten"
cat <<EOM >"$targetFolder/.emscripten"
emsdk_path = '$targetFolder'
EMSCRIPTEN_ROOT = emsdk_path + '/emscripten-$version'
LLVM_ROOT = emsdk_path + '/install/bin'
BINARYEN_ROOT = emsdk_path + '/install'
NODE_JS = emsdk_path + '/$pathNodeExecutable'
TEMP_DIR = '/tmp'
EOM

SetEnvVar "PATH" "\"\$PATH:$targetFolder/emscripten-$version/\""
SetEnvVar "EMSCRIPTEN" "$targetFolder/emscripten-$version"
SetEnvVar "EMSDK" "$targetFolder"
SetEnvVar "EMSDK_NODE" "$targetFolder/$pathNodeExecutable"

echo "Emsdk = $version" >> ~/versions.txt
