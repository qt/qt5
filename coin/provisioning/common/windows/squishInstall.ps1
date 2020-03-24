#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

. "$PSScriptRoot\helpers.ps1"

# This script will pre-installed squish package for Windows.
# Squish is need by Release Test Automation (RTA)

$version = "6.5.2"
$qtBranch = "514x"
$targetDir = "C:\Utils\squish"
$squishPackage = "C:\Utils\rta_squish"
$squishUrl = "\\ci-files01-hki.intra.qt.io\provisioning\squish\jenkins_build"
$licenseUrl = "\\ci-files01-hki.intra.qt.io\provisioning\squish\coin"

# Squish license
$licensePackage = ".squish-3-license"

Write-Host "Installing Squish license to home directory"
Copy-Item $licenseUrl\$licensePackage ~\$licensePackage

if (Is64BitWinHost) {
     $arch = "x64"
} else {
    $arch = "x86"
}

$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

if ($OSVersion -eq "Windows 10 Enterprise") {
    $winVersion = "win10"
    if (Is64BitWinHost) {
        $sha1 = "9262d3b749483094024c74986f93e9340afbdb62"
    } else {
        $sha1 = "0763b344afa327e6c374971492021c5e923be892"
    }
} elseif ($OSVersion -eq "Windows 7 Enterprise") {
    $winVersion = "win7"
    $sha1 = "01b3529459da948cfde319d60becc666da0e1c4d"
}
$squishArchive = "prebuild-squish-$version-$qtBranch-$winVersion-$arch.zip"

Copy-Item "\\ci-files01-hki.intra.qt.io\provisioning\squish\jenkins_build\stable\$squishArchive" "C:\Utils"
Verify-Checksum "C:\Utils\$squishArchive" $sha1
Extract-7Zip "C:\Utils\$squishArchive" "C:\Utils"
Rename-Item "$squishPackage" "$targetDir"

Write-Host "Verifying Squish Installation for following targets:"
get-childitem "$targetDir" -Filter squishrunner.exe -Recurse | % { $_.FullName }
get-childitem "$targetDir" -Filter squishrunner.exe -Recurse | % { if (cmd /c $_.FullName --testsuite "$targetDir\suite_test_squish" |Select-String -Pattern "Squish test run successfully") { Write-Host "Squish tested successfully"} else { [Environment]::Exit(1) } }
