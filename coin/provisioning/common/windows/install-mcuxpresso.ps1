# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs NXP MCUXpresso IDE
# MCUXpresso IDE provides the tools for flashing and onboard debugging

$version = "11.2.0_4120"
$url = "http://ci-files01-hki.ci.qt.io/input/windows/MCUXpressoIDE_$version.zip"
$zip = "C:\Windows\Temp\MCUXpressoIDE_$version.zip"

Download $url $url $zip
Extract-7Zip $zip C:
Rename-Item C:\MCUXpressoIDE_$version C:\MCUXpressoIDE
Write-Output "MCUXpresso IDE = $version" >> ~/versions.txt
