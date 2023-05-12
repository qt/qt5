# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$auth_file = "C:\Users\qt\work\influxdb\coin_vms_writer.auth"

# Provisioning should run even without the secrets repository
if (Test-Path $auth_file) {
    $auth_content = Get-Content $auth_file
    $influxdb_password = $auth_content.Substring($auth_content.LastIndexOf(':') + 1)
    Remove "$auth_file"
} else {
    $influxdb_password = "no_password_provided"
}

$telegraf_conf = "C:\telegraf-coin.conf"
(Get-Content $telegraf_conf) | ForEach-Object { $_.Replace("COIN_VMS_WRITER_PASS", $influxdb_password) } | Out-File -Encoding UTF8 $telegraf_conf
