#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/macos/install-commandlinetools.sh
source "${BASH_SOURCE%/*}/../common/macos/install-commandlinetools.sh"
version="26_beta_2"
packageName="Command_Line_Tools_for_Xcode_$version.dmg"
url="http://ci-files01-hki.ci.qt.io/input/mac/$packageName"
sha1="c6ab42d538fc02f0ddf229db54d6dd0178a2718a"

InstallCommandLineTools $url $url $sha1 $packageName $version
