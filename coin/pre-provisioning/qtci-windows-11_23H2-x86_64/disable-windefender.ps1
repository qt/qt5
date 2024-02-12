# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Turning off win defender.
#
# If disabled manually, windows will automatically enable it after
# some period of time. Disabling it speeds up the builds.
# NOTE! Windows Defender Antivirus needs to be turned off!
#     Open 'gpedit.msc': 'Computer Configuration' - 'Administrative Templates' - 'Windows Components' - 'Windows Defender Antivirus'
#     Edit 'Turn off Windows Defender Antivirus' > 'Enabled' > 'Apply'

. "$PSScriptRoot\helpers.ps1"

Run-Executable "reg.exe" "ADD `"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender`" /V DisableAntiSpyware /T REG_dWORD /D 1 /F"
Run-Executable "reg.exe" "ADD `"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender`" /V DisableRoutinelyTakingAction /T REG_dWORD /D 1 /F"

# Disable 'QueueReporting' - "Windows Error Reporting task to process queued reports."
DisableSchedulerTask "Windows Error Reporting\QueueReporting"

# Disable WindowsUpdate from Task Scheduler
DisableSchedulerTask "WindowsUpdate\Scheduled Start"
