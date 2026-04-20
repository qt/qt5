#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script verifies that all installed packages originate from the current release version and not from newer releases.
# The caller provides a regex that matches the allowed release version and excludes packages from newer releases.

set -ex

verify_release_packages() {
    local regex_verify="$1"

    if rpm -qa --queryformat="%{NAME} %{RELEASE}\n" | grep -E " .*$regex_verify" >/dev/null; then
        echo "Found packages that belong to other RHEL release, aborting"
        exit 1
    else
        echo "All package versions checked OK"
    fi
}

