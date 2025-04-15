# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
