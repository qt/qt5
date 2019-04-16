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

$version = "1.38.27"
$versionNode = "8.9.1"
$versionWinPython = "2.7.13"
$versionJre = "8_update_152"

$urlOfficialMozilla = "https://s3.amazonaws.com/mozilla-games/emscripten/packages"
$urlCache = "http://ci-files01-hki.intra.qt.io/input/emsdk"

$urlOfficialEmscriptenLlvm = "$urlOfficialMozilla/llvm/tag/win_64bit/emscripten-llvm-e$version.zip"
$urlCacheEmscriptenLlvm = "$urlCache/windows/emscripten-llvm-e$version.zip"
$sha1EmscriptenLlvm = "1cd950feec50f1f3265f04ab01fb270250eb4232"

$urlOfficialNode = "$urlOfficialMozilla/node-v$versionNode-win-x64.zip"
$urlCacheNode = "$urlCache/windows/node-v$versionNode-win-x64.zip"
$sha1Node = "249c840f7b953e4cb7ac9db89aa92a98daa1dc63"

$urlOfficialWinPython = "$urlOfficialMozilla/WinPython-64bit-$versionWinPython.1Zero.zip"
$urlCacheWinPython = "$urlCache/windows/WinPython-64bit-$versionWinPython.1Zero.zip"
$sha1WinPython = "7e5a021878e0165ba0603e995b013e244d6e10cb"

$urlOfficialProtableJre = "$urlOfficialMozilla/portable_jre_${versionJre}_64bit.zip"
$urlCacheProtableJre = "$urlCache/windows/portable_jre_${versionJre}_64bit.zip"
$sha1ProtableJre = "6830524ec8b16742f956897abb6b6f5ef890a1c2"

$urlOfficialEmscripten = "https://github.com/kripken/emscripten/archive/$version.zip"
$urlCacheEmscripten = "$urlCache/windows/emscripten-$version.zip"
$sha1Emscripten = "22d78a0af48b50271ab183fd3d8ea2f9ba311ee7"

$installLocationEmsdk = "C:\\Utils\\emsdk"
$temp = "C:\Windows\Temp"

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

Install $urlOfficialEmscriptenLlvm $urlCacheEmscriptenLlvm $sha1EmscriptenLlvm "$temp\emscripten-llvm-e$version.zip" "$installLocationEmsdk\emscripten-llvm-e$version"
Install $urlOfficialNode $urlCacheNode $sha1Node "$temp\node-v$versionNode-win-x64.zip" "$installLocationEmsdk"
Install $urlOfficialWinPython $urlCacheWinPython $sha1WinPython "$temp\WinPython-64bit-$versionWinPython.1Zero.zip" "$installLocationEmsdk"
Install $urlOfficialProtableJre $urlCacheProtableJre $sha1ProtableJre "$temp\portable_jre_$versionJre_64bit.zip" "$installLocationEmsdk"
Install $urlOfficialEmscripten $urlCacheEmscripten $sha1Emscripten "$temp\emscripten-$version.zip" "$installLocationEmsdk"

cd $installLocationEmsdk
"LLVM_ROOT='$installLocationEmsdk\\emscripten-llvm-e$version'" | Out-File '.emscripten' -Encoding ASCII
"EMSCRIPTEN_NATIVE_OPTIMIZER='$installLocationEmsdk\\emscripten-llvm-e$version\\optimizer'" | Out-File '.emscripten' -Append -Encoding ASCII
"BINARYEN_ROOT='$installLocationEmsdk\\emscripten-llvm-e$version\\binaryen'" | Out-File '.emscripten' -Append -Encoding ASCII
"NODE_JS='$installLocationEmsdk\\node-v$versionNode-win-x64\\bin\\node'" | Out-File '.emscripten' -Append -Encoding ASCII
"EMSCRIPTEN_ROOT='$installLocationEmsdk\emscripten-$version'" | Out-File '.emscripten' -Append -Encoding ASCII
"SPIDERMONKEY_ENGINE = ''" | Out-File '.emscripten' -Append -Encoding ASCII
"V8_ENGINE = ''" | Out-File '.emscripten' -Append -Encoding ASCII
"TEMP_DIR = '/tmp'" | Out-File '.emscripten' -Append -Encoding ASCII
"COMPILER_ENGINE = NODE_JS" | Out-File '.emscripten' -Append -Encoding ASCII
"JS_ENGINES = [NODE_JS]" | Out-File '.emscripten' -Append -Encoding ASCII

Set-EnvironmentVariable "EMSDK" "$installLocationEmsdk"
Set-EnvironmentVariable "EM_CONFIG" "$installLocationEmsdk\.emscripten"
Set-EnvironmentVariable "EMSDK_LLVM_ROOT" "$installLocationEmsdk\emscripten-llvm-e$version"
Set-EnvironmentVariable "EMSCRIPTEN_NATIVE_OPTIMIZER" "$installLocationEmsdk\emscripten-llvm-e$version\optimizer.exe"
Set-EnvironmentVariable "BINARYEN_ROOT" "$installLocationEmsdk\emscripten-llvm-e$version\binaryen"
Set-EnvironmentVariable "EMSDK_NODE" "$installLocationEmsdk\node$versionNode-win-x64\bin\node.exe"
Set-EnvironmentVariable "EMSDK_PYTHON" "$installLocationEmsdk\WinPython-64bit-$versionWinPython.1Zero\python-$versionWinPython.amd64\python.exe"
Set-EnvironmentVariable "EMSDK_JAVA_HOME" "$installLocationEmsdk\java64"
Set-EnvironmentVariable "EMSCRIPTEN" "$installLocationEmsdk\emscripten-$version"
Set-EnvironmentVariable "EMSCRIPTEN_ROOT" "$installLocationEmsdk\emscripten-$version"
Set-EnvironmentVariable "EMSDK_PATH" "$installLocationEmsdk\emscripten-$version;$installLocationEmsdk;$installLocationEmsdk\node$versionNode-win-x64\bin;$installLocationEmsdk\emscripten-llvm-e$version;$installLocationEmsdk\WinPython-64bit-$versionWinPython.1Zero\python-$versionWinPython.amd64;$installLocationEmsdk\java64\bin"

Write-Output "emsdk = $version" >> ~/versions.txt
Write-Output "emsdk llvm = $version" >> ~/versions.txt
Write-Output "emsdk NodeJs = $versionNode" >> ~/versions.txt
Write-Output "emsdk WinPython 64bit = $versionWinPython" >> ~/versions.txt
Write-Output "emsdk portable jre = $versionJre" >> ~/versions.txt
