# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will set the network test server IP in to hosts file

$n = Get-Content "$PSScriptRoot\..\shared\network_test_server_ip.txt"
$n = $n.Split('=')
New-Variable -Name $n[0] -Value $n[1]

Add-Content -Path C:\Windows\System32\drivers\etc\hosts. -Value "$network_test_server_ip  qt-test-server  qt-test-server.qt-test-net"
