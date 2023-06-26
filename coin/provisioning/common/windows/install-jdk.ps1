############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

. "$PSScriptRoot\helpers.ps1"

# This script will install Java SE

if (Is64BitWinHost) {
    $version = "11.0.12"
    $arch = "x64"
    $sha1 = "135ffd1c350509729551876232a5354070732e92"
    $installdir = "C:\Program Files\Java\jdk-$version"
    $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\jdk-" + $version + "-windows-" + $arch + ".exe"
} else {
    $version = "11.0.11.9"
    $arch = "x86-32"
    $sha1 = "a861e994208ee85bf83a76105f6858feeb6fbb33"
    $installdir = "C:\Program Files\AdoptOpenJDK\jdk-$version-hotspot"
    $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\OpenJDK11U-jdk_x86-32_windows_hotspot_11.0.11_9.msi"
}

# NOTE! Official URL is behind login portal. It can't be used whit this script instead it need to be fetched to $url_cache first
# java 11: https://www.oracle.com/java/technologies/downloads/#java11-windows
# java 8: $official_url = "http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-" + $version + "-windows-" + $arch + ".exe"
if (Is64BitWinHost) {
    $javaPackage = "C:\Windows\Temp\jdk-$version.exe"
} else {
    $javaPackage = "C:\Windows\Temp\jdk-$version.msi"
}

Write-Host "Fetching Java SE $version..."
$ProgressPreference = 'SilentlyContinue'
Write-Host "...from local cache"
Download $url_cache $url_cache $javaPackage
Verify-Checksum $javaPackage $sha1

if (Is64BitWinHost) {
    Run-Executable "$javaPackage" "/s SPONSORS=0"
} else {
    Run-Executable "msiexec" "/quiet /i $javaPackage"
}
Remove "$javaPackage"

Write-Host "Remove Java update from startup"
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

Set-EnvironmentVariable "JAVA_HOME" "$installdir"
Add-Path "$installdir\bin"

Write-Output "Java SE = $version $arch" >> ~\versions.txt
