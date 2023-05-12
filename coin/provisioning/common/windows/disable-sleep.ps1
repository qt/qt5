# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script prevents Windows from going to sleep

Run-Executable "powercfg.exe" "-change -monitor-timeout-ac 0"
Run-Executable "powercfg.exe" "-change -standby-timeout-ac 0"
Run-Executable "powercfg.exe" "-change -disk-timeout-ac 0"
Run-Executable "powercfg.exe" "-change -hibernate-timeout-ac 0"
