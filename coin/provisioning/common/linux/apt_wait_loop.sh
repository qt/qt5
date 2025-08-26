#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

function waitLoop {
    while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        echo "Waiting for other software managers to finish... 1/2"
        sleep 0.5
    done

    while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
        echo "Waiting for other software managers to finish... 2/2"
        sleep 0.5
    done
}
