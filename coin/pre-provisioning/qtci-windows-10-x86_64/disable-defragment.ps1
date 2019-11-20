#############################################################################
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
