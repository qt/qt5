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

# Install Cumulative Servicing Release Visual Studio 2015 update 3
# Original download page: https://msdn.microsoft.com/en-us/library/mt752379.aspx

$version = "2015 update3 (KB3165756)"
$packagePath = "C:\Windows\Temp"
$package = $packagePath + "\vs14-kb3165756.exe"
$url_cache = "http://ci-files01-hki.intra.qt.io/input/windows/vs14-kb3165756.exe"
$url_official = "http://go.microsoft.com/fwlink/?LinkID=816878"
$sha1 = "6a21d9b291ca75d44baad95e278fdc0d05d84c02"
$preparedPackage = "\\ci-files01-hki.intra.qt.io\provisioning\windows\vs14-kb3165756-update"

if (Test-Path $preparedPackage) {
    # The prepared package contains updated packages so that not everything has to be downloaded
    Write-Host "Using prepared package"
    Copy-Item -Recurse $preparedPackage $packagePath
    # Remove the whole downloaded folder
    $toRemove = $packagePath + "\vs14-kb3165756-update"
    $executable = "$toRemove\vs14-kb3165756.exe"
} else {
    Write-Host "Fetching patch for Visual Studio $version..."
    Download $url_official $url_cache $package
    $executable = $package
    # Remove the downloaded executable
    $toRemove = $executable
}

Verify-Checksum $executable $sha1
Write-Host "Installing patch for Visual Studio $version..."
Run-Executable $executable "/norestart /passive"

Remove-Item -Force -Recurse -Path $toRemove

Write-Output "Visual Studio = $version" >> ~\versions.txt
