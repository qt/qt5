#############################################################################
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

. "$PSScriptRoot\helpers.ps1"


# This script will install squish package for Windows.
# Squish is need by Release Test Automation (RTA)

$version = "6.3.0"
# Qt branch without dot (*.*)
$qtBranch = "59x"
$targetDir = "C:\Utils\squish"
$squishUrl = "\\ci-files01-hki.intra.qt.io\provisioning\squish\coin"
$squishBranchUrl = "$squishUrl\$qtBranch"

# Squish license
$licensePackage = ".squish-3-license"

$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# This can be removed when using vanilla os
if ((Test-Path -Path "$targetDir" )) {
    try {
        Write-Host "Renaming old Squish"
        Write-Host "Rename-Item -ErrorAction 'Stop' $targetDir $targetDir_deleted"
        Rename-Item -ErrorAction 'Stop' "$targetDir" squish_deleted
    } catch {}
}

Function DownloadAndInstallSquish {

    Param (
        [string]$version,
        [string]$squishBranchUrl,
        [string]$qtBranch,
        [string]$bit,
        [string]$targetDir,
        [string]$squishPackage
    )

    $SquishUrl = $squishBranchUrl + "\squish-" + $version + "-qt" + $qtBranch + "-" + $bit + "-" + $squishPackage + ".exe"
    $SquishInstaller = "$targetDir\$squishPackage.exe"
    $SquishParameters = "unattended=1 targetdir=$targetDir\$squishPackage"

    Write-Host "Fetching from URL $squishUrl"
    Copy-Item "$SquishUrl" "$SquishInstaller"
    Write-Host "Installing Squish"
    Run-Executable "$SquishInstaller" "$SquishParameters"
    Remove-Item -Path $SquishInstaller
}

Function DownloadSquishLicence {

    Param (
        [string]$licensePackage,
        [string]$squishUrl,
        [string]$targetDir
    )

    # This can be removed when using vanilla os
    if ($Env:SQUISH_LICENSEKEY_DIR) {
        Write-Host "Removing SQUISH_LICENSEKEY_DIR env variable"
        Remove-Item Env:\SQUISH_LICENSEKEY_DIR
    }

    Write-Host "Installing Squish license to home directory"
    Copy-Item $squishUrl\$licensePackage ~\$licensePackage
}

Write-Host "Creating $targetDir"
New-Item -ErrorAction Ignore -ItemType directory -Path "$targetDir"

DownloadSquishLicence $licensePackage $squishUrl $targetDir

if (($OSVersion -eq "Windows 10 Enterprise") -or ($OSVersion -eq "Windows 8.1 Enterprise")) {
    # Squish for MinGW
    $squishPackageMingw = "mingw_gcc53_posix_dwarf"
    Write-Host "Installing $squishPackageMingw"
    DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win32 $targetDir $squishPackageMingw
    mv $targetDir\$squishPackageMingw $targetDir\mingw

    # Squish for Visual Studio 2015
    $squishPackage = "msvc14"
    $squishPackage64bit = "msvc14_64"

    if (Is64BitWinHost) {
        Write-Host "Installing $squishPackage64bit"
        DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win64 $targetDir $squishPackage
        Rename-Item $targetDir\$squishPackage $targetDir\$squishPackage64bit
    }

    Write-Host "Installing $squishPackage"
    DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win32 $targetDir $squishPackage
}
if ($OSVersion -eq "Windows 8.1 Enterprise") {
    # Squish for Visual Studio 2013
    $squishPackage64bit = "msvc12_64"

    if (Is64BitWinHost) {
        Write-Host "Installing $squishPackage_64"
        DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win64 $targetDir $squishPackage
        Rename-Item $targetDir\$squishPackage $targetDir\$squishPackage64bit
    } else {
        Write-Host "Change secret file to normal one"
        Run-Executable "attrib.exe" "-h C:\Users\qt\.squish-3-license"
    }
}
if  ($OSVersion -eq "Windows 7 Enterprise") {
    # Squish for MinGW
    $squishPackageMingw = "mingw_gcc53_posix_dwarf"
    Write-Host "Installing $squishPackageMingw"
    DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win32 $targetDir $squishPackageMingw
    Rename-Item $targetDir\$squishPackageMingw $targetDir\mingw

    # Squish for Visual Studio 2015
    $squishPackage = "msvc14"
    $squishPackage64bit = "msvc14_64"

    Write-Host "Installing $squishPackage"
    DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win32 $targetDir $squishPackage

    if (Is64BitWinHost) {
        Write-Host "Installing $squishPackage64bit"
        DownloadAndInstallSquish $version $squishBranchUrl $qtBranch win64 $targetDir $squishPackage
        Rename-Item $targetDir\$squishPackage $targetDir\$squishPackage64bit
    }
}
