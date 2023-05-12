#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Squish Coco

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"


version="4.2.2"
sha1="a44f0f039f3712c715eea63c4021d08bf17a44c6"
package="SquishCocoSetup_${version}_Linux_x86_64.run"
url="http://ci-files01-hki.ci.qt.io/input/coco//$package"

echo "Enable license for  Coco"

DownloadURL  "$url" "$url" "$sha1" "/tmp/$package"
sudo chmod 755 "/tmp/$package"
echo 1 | sudo "/tmp/$package" "--nox11"

/opt/SquishCoco/bin/cocolic --license-server=Qt-SRV-33.intra.qt.io:49344

echo "export PATH=/opt/SquishCoco/bin/:$PATH" >> ~/.bashrc

