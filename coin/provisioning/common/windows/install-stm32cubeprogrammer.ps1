# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install STM32CubeProgrammer software needed by MCU RTA
# Official donwload from https://www.st.com/en/development-tools/stm32cubeprog.html

$version ="2_5_0"
$url = "http://ci-files01-hki.ci.qt.io/input/windows/STMicroelectronics_v${version}.zip"
$zip = "C:\Windows\Temp\STMicroelectronics_v${version}.zip"

Download $url $url $zip
Extract-7Zip $zip "C:\Program Files"
Remove-Item -Recurse -Force -Path $zip

Write-Output "STM32CubeProgrammer = $version" >> ~/versions.txt



