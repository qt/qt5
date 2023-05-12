# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Visual Studios are pre-provisioned to tier1 images

# MSVC 2015 Update 3
Write-Output "Visual Studio 2015 = Version 14.0.25420.1 Update 3" >> ~\versions.txt

# MSVC 2019 and Build Tools are pre-provisioned, but the updating happens with "$PSScriptRoot\..\common\windows\update-msvc2019.ps1"

