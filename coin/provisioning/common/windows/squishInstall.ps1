# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will pre-installed squish package for Windows.
# Squish is need by Release Test Automation (RTA)

$version = "8.0.0"
$qtBranch = "67x"
$targetDir = "C:\Utils\squish"
$squishPackage = "C:\Utils\rta_squish"
$squishUrl = "\\ci-files01-hki.ci.qt.io\provisioning\squish\jenkins_build\stable"
$licenseBranch="squish_license"
$licenseUrl = "\\ci-files01-hki.ci.qt.io\provisioning\squish\coin\$licenseBranch"
$testSuiteUrl="\\ci-files01-hki.ci.qt.io\provisioning\squish\coin\suite_test_squish"

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
        $sha1 = "0f863c261f854ec38032815298f5636e99779bff"
    }
} else {
    $winVersion = "n/a"
}
$squishArchive = "prebuild-squish-$version-$qtBranch-$winVersion-$arch.zip"

Copy-Item "$squishUrl\$squishArchive" "C:\Utils"
Copy-Item -Recurse "$testSuiteUrl" "C:\Utils"
Verify-Checksum "C:\Utils\$squishArchive" $sha1
Extract-7Zip "C:\Utils\$squishArchive" "C:\Utils"

Remove-Item "C:\Utils\prebuild*"

Write-Host "Verifying Squish Installation for following targets:"
get-childitem "$targetDir" -Filter squishrunner.exe -Recurse | % { $_.FullName }
get-childitem "$targetDir" -Filter squishrunner.exe -Recurse | % { if (cmd /c $_.FullName --testsuite "C:\Utils\suite_test_squish" |Select-String -Pattern "Squish test run successfully") { Write-Host "Squish tested successfully"} else { [Environment]::Exit(1) } }
