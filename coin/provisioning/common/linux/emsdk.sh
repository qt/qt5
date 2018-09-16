#!/usr/bin/env bash
#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

version="1.38.1"
version_node="8.9.1"
urlEmscriptenCache="http://ci-files01-hki.intra.qt.io/input/emsdk/emscripten-$version.tar.gz"
urlEmscriptenExternal="https://github.com/kripken/emscripten/archive/$version.tar.gz"
urlEmscriptenLlvmCache="http://ci-files01-hki.intra.qt.io/input/emsdk/emscripten-llvm-e$version.tar.gz"
urlEmscriptenLlvmExternal="https://s3.amazonaws.com/mozilla-games/emscripten/packages/llvm/tag/linux_64bit/emscripten-llvm-e$version.tar.gz"
urlNodeCache="http://ci-files01-hki.intra.qt.io/input/emsdk/node-v$version_node-linux-x64.tar.xz"
urlNodeExternal="https://s3.amazonaws.com/mozilla-games/emscripten/packages/node-v$version_node-linux-x64.tar.xz"
sha1Emscripten="62243b4219f6ad7f6d4bd5ae4abb27aecb87ffb3"
sha1EmscriptenLlvm="933ea5feab3aa5acc5c1e15a0deccf0e3fbeb0a7"
sha1Node="eaec5de2af934f7ebc7f9597983e71c5d5a9a726"
targetFolder="/opt/emsdk"
sudo mkdir "$targetFolder"

InstallFromCompressedFileFromURL "$urlEmscriptenCache" "$urlEmscriptenExternal" "$sha1Emscripten" "$targetFolder" ""
InstallFromCompressedFileFromURL "$urlEmscriptenLlvmCache" "$urlEmscriptenLlvmExternal" "$sha1EmscriptenLlvm" "$targetFolder" ""
InstallFromCompressedFileFromURL "$urlNodeCache" "$urlNodeExternal" "$sha1Node" "$targetFolder" ""

sudo chmod -R a+rwx "$targetFolder"

echo "Writing $targetFolder/.emscripten"
cat <<EOM >"$targetFolder/.emscripten"
LLVM_ROOT='$targetFolder/emscripten-llvm-e$version/'
EMSCRIPTEN_NATIVE_OPTIMIZER='$targetFolder/emscripten-llvm-e$version/optimizer'
BINARYEN_ROOT='$targetFolder/emscripten-llvm-e$version/binaryen'
NODE_JS='$targetFolder/node-v$version_node-linux-x64/bin/node'
EMSCRIPTEN_ROOT='$targetFolder/emscripten-$version'
SPIDERMONKEY_ENGINE = ''
V8_ENGINE = ''
TEMP_DIR = '/tmp'
COMPILER_ENGINE = NODE_JS
JS_ENGINES = [NODE_JS]
EOM

SetEnvVar "PATH" "\"$targetFolder/emscripten-llvm-e$version/:$targetFolder/node-v$version_node-linux-x64/bin:$targetFolder/emscripten-$version:\$PATH\""
SetEnvVar "EMSCRIPTEN" "$targetFolder/emscripten-$version"
SetEnvVar "EM_CONFIG" "$targetFolder/.emscripten"
