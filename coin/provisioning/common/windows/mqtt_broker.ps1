# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

Write-Host "MQTT: Downloading Paho test broker..."
$zip = Get-DownloadLocation "pahotest.zip"
$commitSHA = "9d7bb80bb8b9d9cfc0b52f8cb4c1916401281103"
$sha1 = "c31cfd5de9329dcd25e28b306f94dccf632cc318"

$internalUrl = "http://ci-files01-hki.ci.qt.io/input/mqtt_broker/paho.mqtt.testing-$commitSHA.zip"
$externalUrl = "https://github.com/eclipse/paho.mqtt.testing/archive/$commitSHA.zip"

Download $externalUrl $internalUrl $zip
Verify-Checksum $zip $sha1

Write-Host "MQTT: Installing $zip..."
Extract-7Zip $zip C:\Utils
Remove "$zip"

Set-EnvironmentVariable "MQTT_TEST_BROKER_LOCATION" "C:\Utils\paho.mqtt.testing-$commitSHA\interoperability\startbroker.py"
