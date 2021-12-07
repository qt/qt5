############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script will install FBX SDK

$version = "2016.1.2"

$name = "fbx20161_2_fbxsdk_vs2015_win_nospace"
$packageName = "$name.7z"
$installerName = "$name.exe"
$cacheUrl = "\\ci-files01-hki.intra.qt.io\provisioning\fbx\$packageName"
$sha1 = "de80edc255ffd5ce86ba25869dad72b4c809fd41"

# The executable is an interactive installer only. We can't run it in a script silently.
# $officialUrl = "http://download.autodesk.com/us/fbx_release_older/2016.1.2/$installerName"
# This sha is for the executable
# $sha1 = "54f581c7c19cf5a08cf5e7bc62b8cc7f0617558e"

#$targetFile = "C:\Windows\Temp\$packageName"
$targetFolder = "C:\Utils\"

#Write-Host "Downloading '$installerName'"
#Download $officialUrl $cacheUrl $targetFile
#Verify-Checksum $targetFile $sha1

Write-Host "Extracting '$cacheUrl'"
Extract-7Zip $cacheUrl $targetFolder

#Remove-Item -Recurse -Force "$packageName"

Set-EnvironmentVariable "FBXSDK" "$targetFolder\Autodesk\FBX\FBX_SDK\2016.1.2"

Write-Output "FBX SDK = $version" >> ~\versions.txt

