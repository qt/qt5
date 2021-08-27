############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# This script will install Vulkan SDK
# Original Download page: https://vulkan.lunarg.com/sdk/home#windows

$version = "1.2.182.0"
$vulkanPackage = "C:\Windows\Temp\vulkan-installer-$version.exe"
$sha1 = "1b662f338bfbfdd00fb9b0c09113eacb94f68a0e"
Download "https://sdk.lunarg.com/sdk/download/1.2.182.0/windows/VulkanSDK-$version-Installer.exe" "\\ci-files01-hki.intra.qt.io\provisioning\windows\VulkanSDK-$version-Installer.exe" $vulkanPackage
Verify-Checksum "$vulkanPackage" "$sha1"

Run-Executable $vulkanPackage "/S"

Write-Host "Cleaning $vulkanPackage.."
Remove "$vulkanPackage"

Write-Output "Vulkan SDK = $version" >> ~\versions.txt
