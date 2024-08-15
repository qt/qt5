# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

$n = Get-Content "$PSScriptRoot\..\shared\http_proxy.txt"
$n = $n.Split('=')
New-Variable -Name $n[0] -Value $n[1]

if ([string]::IsNullOrEmpty($proxy)) {
    Write-Host "No proxy is defined."
} else {
    Write-Host "Checking proxy @ $proxy"
    $proxy = $proxy -replace '"', ""
    $webclient = New-Object System.Net.WebClient
    $proxy_obj = New-Object System.Net.WebProxy($proxy)
    $webclient.proxy = $proxy_obj
    try {
        $webpage = $webclient.DownloadData("http://proxy.intra.qt.io")
    } catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $iserror = $true
    }
    if ($iserror -eq $true) {
        Write-Host "Testing download with proxy does not work: $ErrorMessage, $FailedItem. Not setting proxy."
    } else {
        Write-Host "Setting proxy to: $proxy"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "$proxy"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyOverride -Value 10.215
    }
}
