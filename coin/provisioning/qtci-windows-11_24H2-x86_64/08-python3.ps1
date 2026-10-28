# Copyright (C) 2025 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Parameters:
#  - Arch 32/64
#  - installer sha1
#  - install target dir
#  - version
#  - Optional true/false if set as default with PYTHON3/PIP3_PATH variables, default false

. "$PSScriptRoot\..\common\windows\python3.ps1" 64 "a24ea4573b87718cb52f8fbd7b28930f007e8e35" "C:\Python314_64" "3.14.10" $true
& "$PSScriptRoot\..\common\windows\python-pip-security.ps1" "C:\Python314_64"
