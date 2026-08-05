#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euo pipefail

failures=0

pass() {
    printf 'PASS: %s\n' "$1"
}

fail() {
    printf 'FAIL: %s\n' "$1"
    failures=$((failures + 1))
}

echo "=== Image -51 verification ==="

# No PW prompt
if sudo -n true 2>/dev/null; then
    pass "passwordless sudo"
else
    fail "passwordless sudo"
fi

if sudo visudo --check >/dev/null 2>&1; then
    pass "sudoers syntax"
else
    fail "sudoers syntax"
fi

# Timezone
timezone="$(timedatectl show --property=Timezone --value)"

if [[ "$timezone" == "UTC" || "$timezone" == "Etc/UTC" ]]; then
    pass "timezone is UTC"
else
    fail "timezone is '$timezone', expected UTC"
fi

# SSH
if dpkg-query -W -f='${db:Status-Abbrev}' openssh-server 2>/dev/null | grep -q '^ii'; then
    pass "openssh-server installed"
else
    fail "openssh-server installed"
fi

if systemctl is-active --quiet ssh.socket || systemctl is-active --quiet ssh.service; then
    pass "SSH listener active"
else
    fail "SSH listener active"
fi

if sudo ss -ltn |
   grep -qE 'LISTEN.+:22[[:space:]]'; then
    pass "TCP port 22 listening"
else
    fail "TCP port 22 listening"
fi

# QEMU GA
if dpkg-query -W -f='${db:Status-Abbrev}' qemu-guest-agent 2>/dev/null | grep -q '^ii'; then
    pass "qemu-guest-agent installed"
else
    fail "qemu-guest-agent installed"
fi

if systemctl is-enabled --quiet qemu-guest-agent; then
    pass "qemu-guest-agent enabled"
else
    fail "qemu-guest-agent enabled"
fi

# UFW
if sudo ufw status | grep -Fxq 'Status: inactive'; then
    pass "UFW inactive"
else
    fail "UFW inactive"
fi

# Resolution
if grep -Fxq 'GRUB_GFXMODE=1280x800' /etc/default/grub; then
    pass "GRUB graphics mode"
else
    fail "GRUB graphics mode"
fi

# Auto update/upgrade disabled
if apt-config dump | grep -i 'APT::Periodic \"0\";'; then
    pass "APT periodic processing disabled"
else
    apt-config dump | grep -i APT::Periodic
    fail "APT periodic processing enabled"
fi

if apt-config dump | grep -i 'APT::Periodic::Unattended-Upgrade \"0\";'; then
    pass "APT unattended upgrades disabled"
else
    apt-config dump | grep -i APT::Periodic
    fail "APT unattended upgrades enabled"
fi

if grep -Fxq 'Prompt=never' /etc/update-manager/release-upgrades; then
    pass "release-upgrade notifications disabled"
else
    fail "release-upgrade notifications enabled"
fi

# Auto login
if sudo grep -Fxq 'AutomaticLoginEnable=True' /etc/gdm3/custom.conf && sudo grep -Fxq 'AutomaticLogin=qt' /etc/gdm3/custom.conf; then
    pass "GDM automatic login configured"
else
    fail "GDM automatic login configured"
fi

# Broken packages
if [[ -z "$(sudo dpkg --audit)" ]]; then
    pass "dpkg audit"
else
    fail "dpkg audit"
fi

# GNOME initial setup executable removed
if [[ ! -x /usr/libexec/gnome-initial-setup ]]; then
    pass "GNOME initial setup executable is absent"
else
    fail "/usr/libexec/gnome-initial-setup exists. There might be a welcome window popup"
fi

# Summary
echo
if (( failures == 0 )); then
    echo "All conf checks passed."
else
    echo "${failures} check(s) failed."
    # exit 1
fi
