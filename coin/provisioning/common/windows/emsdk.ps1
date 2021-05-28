############################################################################
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
############################################################################

. "$PSScriptRoot\helpers.ps1"

# This script will install emscripten needed by WebAssembly

$version = "2.0.14"
$versionTag="fc5562126762ab26c4757147a3b4c24e85a7289e"
$versionNode = "14.15.5"
$versionWinPython = "3.7.4"
$versionJre = "8_update_152"

$urlEmscripten = "https://storage.googleapis.com/webassembly/emscripten-releases-builds"

# cross-platform emscripten SDK
$urlEmscriptenExternal="https://github.com/emscripten-core/emscripten/archive/$version.zip"
$urlCache = "http://ci-files01-hki.intra.qt.io/input/emsdk"

$urlEmscriptenCache="$urlCache/emscripten.$version.zip"

$urlWasmBinariesExternal="$urlEmscripten/win/$versionTag/wasm-binaries.zip"
$urlWasmBinariesCache="$urlCache/windows/wasm-binaries.$version.zip"
$sha1WasmBinaries="a6f3f49df50fe7c8a0e61065b80fd885b8266bf3"

$urlOfficialNode = "$urlEmscripten/deps/node-v$versionNode-win-x64.zip"
$urlCacheNode = "$urlCache/windows/node-v$versionNode-win-x64.zip"
$sha1Node = "7df0af8aa3c128cff43d77dd6f3a163d405d0469"

$urlOfficialWinPython = "$urlEmscripten/deps/python-$versionWinPython-embed-amd64-patched.zip"
$urlCacheWinPython = "$urlCache/windows/python-$versionWinPython-embed-amd64-patched.zip"
$sha1WinPython = "27C5A465390167FC03F3DD9075E3FDAAD9FBE104"

$urlOfficialProtableJre = "$urlEmscripten/deps/portable_jre_${versionJre}_64bit.zip"
$urlCacheProtableJre = "$urlCache/windows/portable_jre_${versionJre}_64bit.zip"
$sha1ProtableJre = "6830524ec8b16742f956897abb6b6f5ef890a1c2"

$installLocationEmsdk = "C:\\Utils\\emsdk"
$temp = "C:\\Windows\\Temp"

function Install {

    Param (
        [string] $urlOfficial = $(BadParam("Official url path")),
        [string] $urlCache = $(BadParam("Cached url path")),
        [string] $sha1 = $(BadParam("SHA1 checksum of the file")),
        [string] $location = $(BadParam("Download location")),
        [string] $installLocation = $(BadParam("Install location"))
    )

    Download $urlOfficial $urlCache $location
    Verify-Checksum $location $sha1
    Extract-7Zip $location $installLocation

}

New-Item -ItemType directory -Force -Path "$installLocationEmsdk"

Install $urlWasmBinariesExternal $urlWasmBinariesCache $sha1WasmBinaries "$temp\wasm-binaries.$version.zip" "$installLocationEmsdk\emscripten-llvm-e$version"
Install $urlOfficialNode $urlCacheNode $sha1Node "$temp\node-v$versionNode-win-x64.zip" "$installLocationEmsdk"
Install $urlOfficialWinPython $urlCacheWinPython $sha1WinPython "$temp\python-$versionWinPython-embed-amd64-patched.zip" "$installLocationEmsdk\python-$versionWinPython-embed-amd64-patched"
Install $urlOfficialProtableJre $urlCacheProtableJre $sha1ProtableJre "$temp\portable_jre_$versionJre_64bit.zip" "$installLocationEmsdk"

cd $installLocationEmsdk\emscripten-llvm-e$version\install\emscripten
"emsdk_path = '$installLocationEmsdk'"| Out-File '.emscripten' -Append -Encoding ascii
"LLVM_ROOT = emsdk_path + '/emscripten-llvm-e$version/install/bin'" | Out-File '.emscripten' -Append -Encoding ascii
"BINARYEN_ROOT = emsdk_path + '/emscripten-llvm-e$version/install'" | Out-File '.emscripten' -Append -Encoding ascii
"PYTHON = emsdk_path + '/python-$versionWinPython-embed-amd64-patched/python.exe'" | Out-File '.emscripten' -Append -Encoding ascii
"NODE_JS = emsdk_path + '/node-v$versionNode-win-x64/bin/node.exe'" | Out-File '.emscripten' -Append -Encoding ascii
"EMSCRIPTEN_ROOT = emsdk_path +'' " | Out-File '.emscripten' -Append -Encoding ascii
"JAVA = emsdk_path + '/Java64'" | Out-File '.emscripten' -Append -Encoding ascii
"TEMP_DIR = '/tmp'" | Out-File '.emscripten' -Append -Encoding ascii
"COMPILER_ENGINE = NODE_JS" | Out-File '.emscripten' -Append -Encoding ascii
"JS_ENGINES = [NODE_JS]" | Out-File '.emscripten' -Append -Encoding ascii

Set-EnvironmentVariable "EMSDK" "$installLocationEmsdk\emscripten-llvm-e$version\install\emscripten"
Set-EnvironmentVariable "EM_CONFIG" "$installLocationEmsdk\emscripten-llvm-e$version\install\emscripten\.emscripten"
Set-EnvironmentVariable "EMSDK_CACHE" "$installLocationEmsdk\emscripten-llvm-e$version\install\emscripten\cache"
Set-EnvironmentVariable "EMSDK_NODE" "$installLocationEmsdk\node$versionNode-win-x64\bin\node.exe"
Set-EnvironmentVariable "EMSDK_PYTHON" "$installLocationEmsdk\python-$versionWinPython-embed-amd64-patched\python.exe"
Set-EnvironmentVariable "EMSDK_JAVA_HOME" "$installLocationEmsdk\java64"
Set-EnvironmentVariable "EMSDK_PATH" "$installLocationEmsdk\emscripten-llvm-e$version\install\emscripten;$installLocationEmsdk\node$versionNode-win-x64\bin;$installLocationEmsdk\emscripten-llvm-e$version\install\bin;$installLocationEmsdk\python-$versionWinPython-embed-amd64-patched;$installLocationEmsdk\java64\bin;$PATH"

Add-Path "$env:EMSDK_PATH"

Write-Output "emsdk = $version" >> ~/versions.txt
Write-Output "emsdk llvm = $version" >> ~/versions.txt
Write-Output "emsdk NodeJs = $versionNode" >> ~/versions.txt
Write-Output "emsdk WinPython 64bit = $versionWinPython" >> ~/versions.txt
Write-Output "emsdk portable jre = $versionJre" >> ~/versions.txt
