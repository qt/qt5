###########################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

# Turning off win defender.
#
# If disabled manually, windows will automatically enable it after
# some period of time. Disabling it speeds up the builds.
# NOTE! Windows Defender Antivirus needs to be turned off!
#     Open 'gpedit.msc': 'Computer Configuration' - 'Administrative Templates' - 'Windows Components' - 'Windows Defender Antivirus'
#     Edit 'Turn off Windows Defender Antivirus' > 'Enabled' > 'Apply'

. "$PSScriptRoot\..\..\provisioning\common\windows\helpers.ps1"

Run-Executable "reg.exe" "ADD `"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender`" /V DisableAntiSpyware /T REG_dWORD /D 1 /F"
Run-Executable "reg.exe" "ADD `"HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender`" /V DisableRoutinelyTakingAction /T REG_dWORD /D 1 /F"

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
