#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

OS_STATE_DIR="/var/lib/qtciid"
OS_STATE_FILE="$OS_STATE_DIR/os-version"

get_os_id() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        # os-release contains ID of the distro (e.g. 'ubuntu')
        # VERSION e.g. '24.04.1 LTS (Noble Numbat)'
        if [[ -n "${ID:-}" && -n "${VERSION:-}" ]]; then
            echo "${ID}:${VERSION}"
            return 0
        fi
    fi

    echo "unknown:unknown"
    return 1
}

record_os_version() {
    local os_id

    os_id="$(get_os_id)"

    if [[ "$os_id" == "unknown:unknown" ]]; then
        echo "ERROR: Unable to determine OS version"
        exit 1
    fi

    sudo mkdir -p "$OS_STATE_DIR"
    echo "$os_id" | sudo tee "$OS_STATE_FILE" > /dev/null

    echo "OS version: $os_id"
}

verify_os_version_unchanged() {
    if [[ ! -f "$OS_STATE_FILE" ]]; then
        echo "ERROR: OS version state file missing: $OS_STATE_FILE"
        exit 1
    fi

    local start_version current_version

    start_version="$(cat "$OS_STATE_FILE")"
    current_version="$(get_os_id)"

    if [[ "$current_version" == "unknown:unknown" ]]; then
        echo "ERROR: Unable to determine current OS version"
        exit 1
    fi

    if [[ "$start_version" != "$current_version" ]]; then
        echo "ERROR: OS version changed during provisioning!"
        echo "  Start version : $start_version"
        echo "  End version   : $current_version"
        exit 1
    fi

    echo "OS version unchanged ($current_version)"
}
