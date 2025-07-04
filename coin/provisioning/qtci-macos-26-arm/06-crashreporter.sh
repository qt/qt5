#!/usr/bin/env sh
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

defaults write com.apple.CrashReporter DialogType server

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

SetEnvVar "SWIFT_BACKTRACE" "enable=yes,output-to=stderr,preset=medium,interactive=false"
