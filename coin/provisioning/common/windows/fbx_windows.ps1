# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install FBX SDK

$version = "2016.1.2"

$name = "fbx20161_2_fbxsdk_vs2015_win_nospace"
$packageName = "$name.7z"
$installerName = "$name.exe"
$cacheUrl = "\\ci-files01-hki.ci.qt.io\provisioning\fbx\$packageName"
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

