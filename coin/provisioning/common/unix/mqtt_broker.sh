#!/bin/bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

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
