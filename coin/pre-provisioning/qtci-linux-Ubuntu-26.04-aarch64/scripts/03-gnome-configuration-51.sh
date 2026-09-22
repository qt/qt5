#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euo pipefail

readonly CI_USER="${CI_USER:-qt}"

log() {
    printf '\n[gnome-configuration] %s\n' "$*"
}

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must run as root." >&2
    exit 1
fi

if ! id "$CI_USER" >/dev/null 2>&1; then
    echo "ERROR: User does not exist: $CI_USER" >&2
    exit 1
fi

ci_home="$(getent passwd "$CI_USER" | cut -d: -f6)"

if [[ -z "$ci_home" || ! -d "$ci_home" ]]; then
    echo "ERROR: Cannot determine home directory for $CI_USER" >&2
    exit 1
fi

log "Applying GNOME preferences for ${CI_USER}"

# GNOME preferences are stored per user in the dconf database. Packer runs this
# provisioner as root over SSH, without a graphical login or user D-Bus session.
# Run gsettings as the CI user inside a temporary D-Bus session so the values
# are written to the CI user's dconf database rather than root's configuration.

sudo -H -u "$CI_USER" HOME="$ci_home" dbus-run-session -- bash <<'GNOME_SETTINGS'
set -euo pipefail

schema_exists() {
    local schema="$1"

    gsettings list-schemas |
        grep -Fx "$schema" >/dev/null
}

key_exists() {
    local schema="$1"
    local key="$2"

    gsettings list-keys "$schema" |
        grep -Fx "$key" >/dev/null
}

set_setting() {
    local schema="$1"
    local key="$2"
    local value="$3"

    if ! schema_exists "$schema"; then
        echo "ERROR: Missing GSettings schema: $schema" >&2
        exit 1
    fi

    if ! key_exists "$schema" "$key"; then
        echo "ERROR: Missing GSettings key: $schema $key" >&2
        exit 1
    fi

    echo "Setting: $schema $key = $value"
    gsettings set "$schema" "$key" "$value"

    actual="$(gsettings get "$schema" "$key")"
    echo "Result:  $schema $key = $actual"
}

set_setting \
    org.gnome.desktop.notifications \
    show-banners \
    false

set_setting \
    org.gnome.desktop.notifications \
    show-in-lock-screen \
    false

set_setting \
    org.gnome.desktop.screensaver \
    lock-enabled \
    false

if key_exists \
    org.gnome.desktop.screensaver \
    ubuntu-lock-on-suspend; then

    set_setting \
        org.gnome.desktop.screensaver \
        ubuntu-lock-on-suspend \
        false
fi

set_setting \
    org.gnome.desktop.privacy \
    remember-recent-files \
    false

rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/recently-used.xbel"

set_setting \
    org.gnome.desktop.session \
    idle-delay \
    'uint32 0'

set_setting \
    org.gnome.settings-daemon.plugins.power \
    sleep-inactive-ac-type \
    "'nothing'"

set_setting \
    org.gnome.settings-daemon.plugins.power \
    sleep-inactive-battery-type \
    "'nothing'"

set_setting \
    org.gnome.settings-daemon.plugins.power \
    sleep-inactive-ac-timeout \
    0

set_setting \
    org.gnome.settings-daemon.plugins.power \
    sleep-inactive-battery-timeout \
    0

set_setting \
    org.gnome.shell.extensions.dash-to-dock \
    dock-fixed \
    true

set_setting \
    org.gnome.shell.extensions.dash-to-dock \
    autohide \
    false

set_setting \
    org.gnome.shell.extensions.dash-to-dock \
    intellihide \
    false
GNOME_SETTINGS

log "GNOME preferences applied successfully"
