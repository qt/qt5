#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/macos/install-commandlinetools.sh
source "${BASH_SOURCE%/*}/../common/macos/install-commandlinetools.sh"
version="15.3"
packageName="Command_Line_Tools_for_Xcode_$version.dmg"
url="http://ci-files01-hki.ci.qt.io/input/mac/$packageName"
sha1="e7149414aff0e3d6c85245683e77ddde2f410ec0"

InstallCommandLineTools $url $url $sha1 $packageName $version
