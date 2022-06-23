#############################################################################
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

# This script will pre-installed squish package for Windows.
# Squish is need by Release Test Automation (RTA)

$version = "7.0.1"
$qtBranch = "63x"
$targetDir = "C:\Utils\squish"
$squishPackage = "C:\Utils\rta_squish"
$squishUrl = "\\ci-files01-hki.intra.qt.io\provisioning\squish\jenkins_build\stable"
$licenseUrl = "\\ci-files01-hki.intra.qt.io\provisioning\squish\coin\$qtBranch"

# Squish license
$licensePackage = ".squish-license"

Write-Host "Installing Squish license to home directory"
Copy-Item $licenseUrl\$licensePackage ~\$licensePackage

if (Is64BitWinHost) {
    $arch = "x64"
} else {
    $arch = "x86"
}

$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

if (($OSVersion -eq "Windows 10 Enterprise") -or ($OSVersion -eq "Windows 10 Pro")) {
    # In Windows 11 case $OSVersion is 'Windows 10 Pro'
    $winVersion = "win10"
    if (Is64BitWinHost) {
        $sha1 = "9c1554ba55f3d4927f89d0d939a52988272d5494"
    }
} else {
    $winVersion = "n/a"
}
$squishArchive = "prebuild-squish-$version-$qtBranch-$winVersion-$arch.zip"

Copy-Item "$squishUrl\$squishArchive" "C:\Utils"
Verify-Checksum "C:\Utils\$squishArchive" $sha1
Extract-7Zip "C:\Utils\$squishArchive" "C:\Utils"
Rename-Item "$squishPackage" "$targetDir"
Remove-Item "C:\Utils\prebuild*"

Write-Host "Verifying Squish Installation for following targets:"
get-childitem "$targetDir" -Filter squishrunner.exe -Recurse | % { $_.FullName }
get-childitem "$targetDir" -Filter squishrunner.exe -Recurse | % { if (cmd /c $_.FullName --testsuite "$targetDir\suite_test_squish" |Select-String -Pattern "Squish test run successfully") { Write-Host "Squish tested successfully"} else { [Environment]::Exit(1) } }
