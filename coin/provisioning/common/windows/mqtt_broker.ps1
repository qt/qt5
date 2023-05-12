# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

Write-Host "MQTT: Downloading Paho test broker..."
$zip = Get-DownloadLocation "pahotest.zip"
$commitSHA = "20bad2475c27a6e1d24a56d90a9fceb40963261e"
$sha1 = "a0ac88715c2aebb9573a113dc13925a90da19233"

$internalUrl = "http://ci-files01-hki.ci.qt.io/input/mqtt_broker/paho.mqtt.testing-$commitSHA.zip"
$externalUrl = "https://github.com/eclipse/paho.mqtt.testing/archive/$commitSHA.zip"

Download $externalUrl $internalUrl $zip
Verify-Checksum $zip $sha1

Write-Host "MQTT: Installing $zip..."
Extract-7Zip $zip C:\Utils
Remove "$zip"

Set-EnvironmentVariable "MQTT_TEST_BROKER_LOCATION" "C:\Utils\paho.mqtt.testing-$commitSHA\interoperability\startbroker.py"
