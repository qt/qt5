#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Distribution-specific build settings.
# For another distro/version, copy the bundle and change these values first.

DISTRO_NAME="ubuntu"
DISTRO_VERSION="26.04"
ISO_PATH="/tmp/ubuntu-26.04-desktop-amd64.iso"
# ISO_CHECKSUM_FILE="/tmp/SHA256SUMS"

# Usually reusable without changes.
IMAGE_PREFIX="qtci-linux"
ARCH="x86_64"
MINIMAL_INDEX="50"
CUSTOM_INDEX="51"
DISK_SIZE="500G"
CPUS="8"
MEMORY_MB="16184"
SSH_USERNAME="qt"
SSH_PASSWORD="$(cat /tmp/PASS)"

PROJECT_DIR="/tmp/packer-linux"
ARTIFACT_DIR="/tmp/output-linux-images"
