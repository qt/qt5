#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# Enables the usage of temporary keychains for SSL autotests
SetEnvVar "QT_SSL_USE_TEMPORARY_KEYCHAIN" "1"
