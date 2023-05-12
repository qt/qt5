#!/bin/bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs paho testing broker

# shellcheck source=./InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/InstallFromCompressedFileFromURL.sh"
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

CommitSHA="2873885d7e840b4e06483f36f170c609eb30527d"
PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mqtt_broker/paho.mqtt.testing-$CommitSHA.zip"
AltUrl="https://github.com/eclipse/paho.mqtt.testing/archive/$CommitSHA.zip"
SHA1="1fcc4e61b12f11a1421cc8c3f379276d732e62b7"
targetFolder="/opt/paho_broker"
appPrefix="paho.mqtt.testing-$CommitSHA"

sudo rm -fr "$targetFolder"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFolder" "$appPrefix"

echo "Adding MQTT broker path to environment"
SetEnvVar "MQTT_TEST_BROKER_LOCATION" "$targetFolder/interoperability/startbroker.py"

echo "MQTT_BROKER = $CommitSHA" >> ~/versions.txt
