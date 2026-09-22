#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euo pipefail

# Install no-overview gnome extension to prevent desktop overview at boot (QTBUG-132070)

readonly CI_USER="${CI_USER:-qt}"
readonly EXTENSION_UUID="no-overview@fthx"
readonly EXTENSION_URL="https://ci-files01-hki.ci.qt.io/input/linux/no-overviewfthx.v23.shell-extension.zip" # GNOME <50
readonly EXTENSION_ZIP="/tmp/${EXTENSION_UUID}.zip"
readonly EXTENSION_DIR="/usr/share/gnome-shell/extensions/${EXTENSION_UUID}"

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must run as root." >&2
    exit 1
fi

if ! id "$CI_USER" >/dev/null 2>&1; then
    echo "ERROR: User does not exist: $CI_USER" >&2
    exit 1
fi

ci_home="$(getent passwd "$CI_USER" | cut -d: -f6)"

echo "Installing No Overview GNOME extension"

wget --quiet --output-document="$EXTENSION_ZIP" "$EXTENSION_URL"

install -d -o root -g root -m 0755 "$EXTENSION_DIR"

unzip -q "$EXTENSION_ZIP" -d "$EXTENSION_DIR"

chown -R root:root "$EXTENSION_DIR"
find "$EXTENSION_DIR" -type d -exec chmod 0755 {} +
find "$EXTENSION_DIR" -type f -exec chmod 0644 {} +

# gnome-extensions writes the enabled state to the CI user's dconf database.
# Packer runs over SSH without a user session, so provide a temporary D-Bus.
sudo -H -u "$CI_USER" HOME="$ci_home" dbus-run-session -- gnome-extensions enable "$EXTENSION_UUID"

rm -f "$EXTENSION_ZIP"

echo "Installed and enabled: $EXTENSION_UUID"
echo "After a reboot, check with: gnome-extensions list --enabled"
