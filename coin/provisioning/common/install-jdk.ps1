############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

. "$PSScriptRoot\..\common\helpers.ps1"

# This script will install Java SE

$installdir = "C:\Program Files\Java\jdk1.8.0_144"

$version = "8u144"
if( (is64bitWinHost) -eq 1 ) {
    $arch = "x64"
    $sha1 = "adb03bc3f4b40bcb3227687860798981d58e1858"
}
else {
    $arch = "i586"
    $sha1 = "3b9ab95914514eaefd72b815c5d9dd84c8e216fc"
}

$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\jdk-" + $version + "-windows-" + $arch + ".exe"
$official_url = "http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-" + $version + "-windows-" + $arch + ".exe"
$javaPackage = "C:\Windows\Temp\jdk-$version.exe"

echo "Fetching Java SE $version..."
$ProgressPreference = 'SilentlyContinue'
try {
    echo "...from local cache"
    Invoke-WebRequest -UseBasicParsing $url_cache -OutFile $javaPackage
} catch {
    echo "...from oracle.com"
    $client = new-object System.Net.WebClient
    $cookie = "oraclelicense=accept-securebackup-cookie"
    $client.Headers.Add("Cookie", $cookie)
    $client.DownloadFile($official_url, $javaPackage)

    Invoke-WebRequest -UseBasicParsing $official_url -OutFile $javaPackage
}

Verify-Checksum $javaPackage $sha1

cmd /c "$javaPackage /s SPONSORS=0"
echo "Cleaning $javaPackage.."
Remove-Item -Recurse -Force "$javaPackage"

[Environment]::SetEnvironmentVariable("JAVA_HOME", "$installdir", [EnvironmentVariableTarget]::Machine)
Add-Path "$installdir\bin"

echo "Java SE = $version $arch" >> ~\versions.txt
