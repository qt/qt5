#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euo pipefail

# Initial Coin configuration for the customized image (-51).

readonly CI_USER="${CI_USER:-qt}"
readonly GRUB_GFXMODE_VALUE="${GRUB_GFXMODE_VALUE:-1280x800}"

export DEBIAN_FRONTEND=noninteractive

log() {
    printf '\n[51-coin-configuration] %s\n' "$*"
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "ERROR: This script must run as root." >&2
        exit 1
    fi
}

require_user() {
    if ! id "$CI_USER" >/dev/null 2>&1; then
        echo "ERROR: Required CI user does not exist: $CI_USER" >&2
        exit 1
    fi
}

require_root
require_user

log "Installing required base packages"
apt-get update
apt-get install -y \
    openssh-server \
    ufw

# Remove GNOME welcome window at boot
log "Removing gnome-initial-setup"
apt-get purge -y gnome-initial-setup

# No sudo PW
log "Configuring passwordless sudo for ${CI_USER}"
cat > "/etc/sudoers.d/${CI_USER}" <<EOF
${CI_USER} ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 "/etc/sudoers.d/${CI_USER}"
visudo --check

# UTC
log "Setting the system timezone to UTC"
timedatectl set-timezone UTC

# Enable SSH
log "Enabling SSH"
# Current Ubuntu releases may use socket activation. Enabling both units is
# harmless and keeps the image compatible with service- and socket-based SSH.
systemctl enable ssh.service
systemctl enable ssh.socket 2>/dev/null || true

# Enable QEMU GA
log "Enabling QEMU guest agent"
systemctl enable qemu-guest-agent

# Disable firewall
log "Disabling UFW"
ufw --force disable
systemctl disable ufw.service 2>/dev/null || true

# Set resolution
log "Configuring GRUB graphics mode: ${GRUB_GFXMODE_VALUE}"
if grep -qE '^GRUB_GFXMODE=' /etc/default/grub; then
    sed -i "s/^GRUB_GFXMODE=.*/GRUB_GFXMODE=${GRUB_GFXMODE_VALUE}/" /etc/default/grub
else
    printf '\nGRUB_GFXMODE=%s\n' "$GRUB_GFXMODE_VALUE" >> /etc/default/grub
fi
update-grub

# Disable auto upgrade/update
log "Disabling periodic APT update checks"
cat > /etc/apt/apt.conf.d/99-qtci-no-periodic-updates << EOF
APT::Periodic "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

sudo systemctl disable --now \
    apt-daily.timer \
    apt-daily-upgrade.timer

sudo systemctl mask \
    apt-daily.service \
    apt-daily-upgrade.service \
    apt-daily.timer \
    apt-daily-upgrade.timer

log "Disabling release-upgrade notifications"
if [[ -f /etc/update-manager/release-upgrades ]]; then
    if grep -qE '^Prompt=' /etc/update-manager/release-upgrades; then
        sed -i 's/^Prompt=.*/Prompt=never/' \
            /etc/update-manager/release-upgrades
    else
        printf '\nPrompt=never\n' >> /etc/update-manager/release-upgrades
    fi
fi

# GDM Auto login
log "Configuring GDM for ${CI_USER}"
if [[ -d /etc/gdm3 ]]; then
    gdm_config="/etc/gdm3/custom.conf"
    touch "$gdm_config"

    if ! grep -qE '^\[daemon\]' "$gdm_config"; then
        printf '\n[daemon]\n' >> "$gdm_config"
    fi
    sed -i \
        '/^AutomaticLoginEnable=/d; /^AutomaticLogin=/d; /^InitialSetupEnable=/d' \
        "$gdm_config"
    sed -i \
        "/^\[daemon\]/a InitialSetupEnable=False\nAutomaticLogin=${CI_USER}\nAutomaticLoginEnable=True" \
        "$gdm_config"
else
    log "GDM is not installed; skipping GDM configuration"
fi

# Run Coin-setup
log "Downloading and running coin-setup"

coin_setup_url="https://ci-files01-hki.ci.qt.io/input/linux/coin-setup-linux-amd64.zip"
coin_setup_zip="/tmp/coin-setup-linux-amd64.zip"
coin_setup_dir="/tmp/coin-setup-linux-amd64"
coin_setup_binary="${coin_setup_dir}/coin-setup"

rm -rf "$coin_setup_dir"
rm -f "$coin_setup_zip"
mkdir -p "$coin_setup_dir"

wget --quiet --output-document="$coin_setup_zip" "$coin_setup_url"

unzip -q "$coin_setup_zip" -d "$coin_setup_dir"

if [[ ! -f "$coin_setup_binary" ]]; then
    echo "ERROR: coin-setup binary was not found at ${coin_setup_binary}" >&2
    echo "Archive contents:" >&2
    unzip -l "$coin_setup_zip" >&2
    exit 1
fi

chmod 0755 "$coin_setup_binary"

sudo -H -u "$CI_USER" "$coin_setup_binary"

rm -rf "$coin_setup_dir"
rm -f "$coin_setup_zip"

log "coin-setup completed successfully"

# Clean apt
log "Cleaning APT metadata"
apt-get clean
rm -rf /var/lib/apt/lists/*

log "Configuration completed successfully"
echo "A reboot is required for all GRUB and login-manager changes to take effect."
