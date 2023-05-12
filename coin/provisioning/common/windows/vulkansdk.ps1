# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Vulkan SDK
# Original Download page: https://vulkan.lunarg.com/sdk/home#windows

$version = "1.2.182.0"
$vulkanPackage = "C:\Windows\Temp\vulkan-installer-$version.exe"
$sha1 = "1b662f338bfbfdd00fb9b0c09113eacb94f68a0e"
Download "https://sdk.lunarg.com/sdk/download/1.2.182.0/windows/VulkanSDK-$version-Installer.exe" "\\ci-files01-hki.ci.qt.io\provisioning\windows\VulkanSDK-$version-Installer.exe" $vulkanPackage
Verify-Checksum "$vulkanPackage" "$sha1"

Run-Executable $vulkanPackage "/S"

Write-Host "Cleaning $vulkanPackage.."
Remove "$vulkanPackage"

Write-Output "Vulkan SDK = $version" >> ~\versions.txt
