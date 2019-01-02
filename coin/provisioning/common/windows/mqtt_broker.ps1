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

. "$PSScriptRoot\helpers.ps1"

Write-Host "MQTT: Downloading Paho test broker..."
$zip = Get-DownloadLocation "pahotest.zip"
$commitSHA = "20bad2475c27a6e1d24a56d90a9fceb40963261e"
$sha1 = "a0ac88715c2aebb9573a113dc13925a90da19233"

$internalUrl = "http://ci-files01-hki.intra.qt.io/input/mqtt_broker/paho.mqtt.testing-$commitSHA.zip"
$externalUrl = "https://github.com/eclipse/paho.mqtt.testing/archive/$commitSHA.zip"

Download $externalUrl $internalUrl $zip
Verify-Checksum $zip $sha1

Write-Host "MQTT: Installing $zip..."
Extract-7Zip $zip C:\Utils
Remove-Item -Path $zip

Set-EnvironmentVariable "MQTT_TEST_BROKER_LOCATION" "C:\Utils\paho.mqtt.testing-$commitSHA\interoperability\startbroker.py"
