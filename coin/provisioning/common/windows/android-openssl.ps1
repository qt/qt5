############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
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

# Requires: 7z, perl and msys

. "$PSScriptRoot\helpers.ps1"

if (Is64BitWinHost) {
    $msys_bash = "C:\Utils\msys64\usr\bin\bash"
} else {
    $msys_bash = "C:\Utils\msys32\usr\bin\bash"
}

# OpenSSL need to be configured from sources for Android build in windows 7
# Msys need to be installed to target machine
# More info and building instructions can be found from http://doc.qt.io/qt-5/opensslsupport.html

$version = "1.1.1m"
$zip = Get-DownloadLocation ("openssl-$version.tar.gz")
$prebuilt_zip = Get-DownloadLocation ("prebuilt-openssl-${version}-fixes-ndk_root-windows.zip")
$sha1 = "c9638d25b9709eda1ac52591c0993af52d6d1206"
$prebuilt_sha1 = "2bf5354b2264ed80e85fea3705ba434a38fe563e"
$destination = "C:\Utils\openssl-android-master"
$prebuilt_url = "\\ci-files01-hki.intra.qt.io\provisioning\openssl\prebuilt-openssl-${version}-fixes-ndk_root-windows.zip"

# msys unix style paths
$ndkPath = "/c/Utils/Android/android-ndk-r20"
$openssl_path = "/c/Utils/openssl-android-master"
$cc_path = "$ndkPath/toolchains/llvm/prebuilt/windows-x86_64/bin"

if ((Test-Path $prebuilt_url)) {
    Download $prebuilt_url $prebuilt_url $prebuilt_zip
    Verify-Checksum $prebuilt_zip $prebuilt_sha1
    Extract-7Zip $prebuilt_zip C:\Utils
    Remove $prebuilt_zip
} else {
    # openssl-${version}_fixes-ndk_root.tar.gz package includes fixes from https://github.com/openssl/openssl/pull/17322 and string ANDROID_NDK_HOME is replaced with ANDROID_NDK_ROOT in Configurations/15-android.conf
    Download \\ci-files01-hki.intra.qt.io\provisioning\openssl\openssl-${version}_fixes-ndk_root.tar.gz \\ci-files01-hki.intra.qt.io\provisioning\openssl\openssl-${version}_fixes-ndk_root.tar.gz $zip
    Verify-Checksum $zip $sha1
    Extract-7Zip $zip C:\Utils\tmp
    Extract-7Zip C:\Utils\tmp\openssl-$version.tar C:\Utils\tmp
    Move-Item C:\Utils\tmp\openssl-${version} $destination
    Remove-Item -Path $zip

    Write-Host "Configuring OpenSSL $version for Android..."
    Push-Location $destination
    # $ must be escaped in powershell...

    function CheckExitCode {

        param (
            $p
        )

        if ($p.ExitCode) {
            Write-host "Process failed with exit code: $($p.ExitCode)"
            exit 1
        }
    }

    $configure = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys_bash" -ArgumentList ("-lc", "`"pushd $openssl_path; ANDROID_NDK_HOME=$ndkPath PATH=${cc_path}:`$PATH CC=clang $openssl_path/Configure shared android-arm`"")
    CheckExitCode $configure

    $make = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys_bash" -ArgumentList ("-lc", "`"pushd $openssl_path; ANDROID_NDK_HOME=$ndkPath PATH=${cc_path}:`$PATH CC=clang make -f $openssl_path/Makefile build_generated`"")
    CheckExitCode $make

    Pop-Location
    Remove-item C:\Utils\tmp -Recurse -Confirm:$false
}

Set-EnvironmentVariable "OPENSSL_ANDROID_HOME" "$destination"
Write-Output "Android OpenSSL = $version" >> ~/versions.txt
