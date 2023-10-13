# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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

$openssl_version = "3.0.7"
$ndk_version_latest = "r26b"
$ndk_version_default = "$ndk_version_latest"
$openssl_compressed = Get-DownloadLocation ("openssl-${openssl_version}.tar.gz")
$openssl_sha1 = "f20736d6aae36bcbfa9aba0d358c71601833bf27"
$prebuilt_sha1_ndk_latest = "ea925d5a5b696916fb3650403a2eb3189c52b5ce"
$prebuilt_sha1_ndk_default = "$prebuilt_sha1_ndk_latest"
$destination_prefix = "C:\Utils\prebuilt-openssl-${openssl_version}-for-android-ndk"

function Install($1, $2) {
        $ndk_version = $1
        $prebuilt_sha1 = $2

        # msys unix style paths
        $openssl_path = "/c/Utils/openssl-android-master"
        $ndk_path = "/c/Utils/Android/android-ndk-${ndk_version}"
        $cc_path = "$ndk_path/toolchains/llvm/prebuilt/windows-x86_64/bin"

        $prebuilt_url_openssl = "\\ci-files01-hki.ci.qt.io\provisioning\openssl\prebuilt-openssl-${openssl_version}-for-android-ndk-${ndk_version}.zip"
        $prebuilt_zip_openssl = Get-DownloadLocation ("prebuilt-openssl-${openssl_version}-for-android-ndk-${ndk_version}.zip")

    if ((Test-Path $prebuilt_url_openssl)) {
        Write-Host "Install prebuilt OpenSSL for Android"
        Download $prebuilt_url_openssl $prebuilt_url_openssl $prebuilt_zip_openssl
        Verify-Checksum $prebuilt_zip_openssl $prebuilt_sha1
        Extract-7Zip $prebuilt_zip_openssl C:\Utils
        Remove $prebuilt_zip_openssl
    } else {
        Write-Host "Build OpenSSL for Android from sources"
        # openssl-${openssl_version}_fixes-ndk_root.tar.gz package includes fixes from https://github.com/openssl/openssl/pull/17322 and string ANDROID_NDK_HOME is replaced with ANDROID_NDK_ROOT in Configurations/15-android.conf
        Download \\ci-files01-hki.ci.qt.io\provisioning\openssl\openssl-${openssl_version}.tar.gz \\ci-files01-hki.ci.qt.io\provisioning\openssl\openssl-${openssl_version}.tar.gz $openssl_compressed
        Verify-Checksum $openssl_compressed $openssl_sha1

        Extract-7Zip $openssl_compressed C:\Utils\tmp
        Extract-7Zip C:\Utils\tmp\openssl-${openssl_version}.tar C:\Utils\tmp
        Move-Item C:\Utils\tmp\openssl-${openssl_version} ${destination}-${ndk_version}
        Remove "$openssl_compressed"

        Write-Host "Configuring OpenSSL $openssl_version for Android..."
        Push-Location ${destination}-${ndk_version}
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

        # ANDROID_NDK_ROOT needs to be in environment variables before running this script
        # Set-EnvironmentVariable "ANDROID_NDK_ROOT" "C:\Utils\Android\android-ndk-r26b"

        $make_install = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys_bash" -ArgumentList ("-lc", "`"yes | pacman -S make`"")
        CheckExitCode $make_install

        $configure = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys_bash" -ArgumentList ("-lc", "`"pushd $openssl_path; ANDROID_NDK_ROOT=$ndk_path PATH=${cc_path}:`$PATH CC=clang $openssl_path/Configure shared android-arm`"")
        CheckExitCode $configure

        $make = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys_bash" -ArgumentList ("-lc", "`"pushd $openssl_path; ANDROID_NDK_ROOT=$ndk_path PATH=${cc_path}:`$PATH CC=clang make -f $openssl_path/Makefile build_generated`"")
        CheckExitCode $make

        Pop-Location
        Remove-item C:\Utils\tmp -Recurse -Confirm:$false
    }

}

# Install NDK Default version
Install $ndk_version_default $prebuilt_sha1_ndk_default

if (Test-Path -Path ${destination_prefix}-${ndk_version_latest}) {
    Write-Host "OpenSSL for Android Latest version is the same than Default. Installation done."
} else {
    # Install NDK Latest version
    Install $ndk_version_latest $prebuilt_sha1_ndk_latest
}

Set-EnvironmentVariable "OPENSSL_ANDROID_HOME_DEFAULT" "${destination_prefix}-${ndk_version_default}"
Set-EnvironmentVariable "OPENSSL_ANDROID_HOME_LATEST" "${destination_prefix}-${ndk_version_latest}"
Write-Output "Android OpenSSL = $openssl_version" >> ~/versions.txt
