# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Turning off win defender.
#
# If disabled manually, windows will automatically enable it after
# some period of time. Disabling it speeds up the builds.

. "$PSScriptRoot\helpers.ps1"

Run-Executable "reg.exe" "ADD `"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender`" /V DisableAntiSpyware /T REG_dWORD /D 1 /F"

# 'Windows Defender Cache Maintenance' - "Periodic maintenance task."
DisableSchedulerTask "Windows Defender\Windows Defender Cache Maintenance"

# 'Windows Defender Cleanup' - "Periodic cleanup task."
DisableSchedulerTask "Windows Defender\Windows Defender Cleanup"

# 'Windows Defender Scheduled Scan' - "Periodic scan task."
DisableSchedulerTask "Windows Defender\Windows Defender Scheduled Scan"

# 'Windows Defender Verification' - "Periodic verification task."
DisableSchedulerTask "Windows Defender\Windows Defender Verification"

# Disable 'QueueReporting' - "Windows Error Reporting task to process queued reports."
DisableSchedulerTask "Windows Error Reporting\QueueReporting"

# Disable WindowsUpdate from Task Scheduler
DisableSchedulerTask "WindowsUpdate\Scheduled Start"
