#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e
set -o pipefail

export PROVISIONING_DIR="${BASH_SOURCE%/*}/../"
source "$PROVISIONING_DIR"/common/unix/install-mosquitto-mqtt.sh
