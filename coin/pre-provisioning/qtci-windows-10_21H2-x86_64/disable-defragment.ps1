#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# Windows 7 does not have Get-ScheduledTask and Unregister-ScheduledTask
# thus needing its own version.
Write-Host "Disabling defragmentation"
$version = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
if ($version -like '*Windows 7*'){
    $pi = New-Object System.Diagnostics.ProcessStartInfo
    $pi.FileName = "C:\Windows\System32\schtasks.exe"
    $pi.RedirectStandardError = $true
    $pi.UseShellExecute  = $false
    $pi.Arguments = "/Delete /TN `"\Microsoft\Windows\Defrag\ScheduledDefrag`" /F"
    $prog = New-Object System.Diagnostics.Process
    $prog.StartInfo = $pi
    $prog.Start() | Out-Null
    $err = $prog.StandardError.ReadToEnd()
    $prog.WaitForExit()
    if ($prog.ExitCode -eq 0){
        Write-Host "Scheduled defragmentation removed"
    } else {
        if ($err -like '*cannot find the file*'){
            Write-Host "No scheduled defragmentation task found"
            exit 0
        } else {
            Write-Host "Error while deleting scheduled defragmentation task: $err"
        }
    }
}
else {
    try {
        $state = (Get-ScheduledTask -ErrorAction Stop -TaskName "ScheduledDefrag").State
        Write-Host "Scheduled defragmentation task found in state: $state"
    }
    catch {
        Write-Host "No scheduled defragmentation task found"
        exit 0
    }
    Write-Host "Unregistering scheduled defragmentation task"
    Unregister-ScheduledTask -ErrorAction Stop -Confirm:$false -TaskName ScheduledDefrag
    Write-Host "Scheduled Defragmentation task was cancelled"
}
