#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

$zip = Get-DownloadLocation "uasdkcpp.zip"
$sha1 = "e1927dbd5d8bb459b468fa70a70b1de51a4ce022"
$installLocation = "C:\Utils\uacpp"

Write-Host "UACPPSDK: Downloading Unified Automation CPP installer..."
$internalUrl = "http://ci-files01-hki.ci.local/input/opcua_uacpp/uasdkcppbundle-bin-EVAL-win32-x86-vs2015-v1.5.6-361.zip"
# No public download link exists
$externalUrl = $internalUrl

Download $externalUrl $internalUrl $zip
Verify-Checksum $zip $sha1

Write-Host "UACPPSDK: Installing $zip..."
Extract-7Zip $zip (Get-DefaultDownloadLocation)
Remove-Item -Path $zip

$executable = (Get-DefaultDownloadLocation) + "uasdkcppbundle-bin-EVAL-win32-x86-vs2015-v1.5.6-361.exe"
$arguments = "/S /D=$installLocation"
Run-Executable $executable $arguments
Write-Host "UACPPSDK: Installer done."
Remove-Item $executable

Write-Host "Set environment variable for COIN to locate SDK"
Set-EnvironmentVariable "CI_UACPP_msvc2015_x86_PREFIX" "$installLocation"
