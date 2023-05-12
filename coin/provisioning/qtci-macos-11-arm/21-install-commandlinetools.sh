#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/macos/install-commandlinetools.sh
source "${BASH_SOURCE%/*}/../common/macos/install-commandlinetools.sh"
version="13.2"
packageName="Command_Line_Tools_for_Xcode_$version.dmg"
url="http://ci-files01-hki.ci.qt.io/input/mac/$packageName"
sha1="b3a0b597435cfbc5c09ad5772cf7313c87032252"

InstallCommandLineTools $url $url $sha1 $packageName $version
