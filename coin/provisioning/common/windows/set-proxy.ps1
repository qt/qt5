#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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
