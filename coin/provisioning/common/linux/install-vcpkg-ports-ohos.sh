#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

echo "Installing vcpkg OHOS ports"

# The vcpkg OHOS toolchain expects OHOS_SDK_ROOT; CI sets HARMONYOS_SDK_ROOT.
export OHOS_SDK_ROOT="${OHOS_SDK_ROOT:-$HARMONYOS_SDK_ROOT}"

if [ -z "$OHOS_SDK_ROOT" ]; then
    echo "ERROR: Neither OHOS_SDK_ROOT nor HARMONYOS_SDK_ROOT is set." >&2
    exit 1
fi

# Coin sets TARGET=hdb in the environment. GNU Make imports env vars as make
# variables, which breaks ICU's Makefile (it defines its own TARGET variable
# for the library path). Unset it before invoking vcpkg.
unset TARGET

"${BASH_SOURCE%/*}/../unix/install-vcpkg-ports.sh" arm64-ohos

SetEnvVar "VCPKG_OHOS_INSTALLED" "$VCPKG_ROOT/installed/arm64-ohos"
export VCPKG_OHOS_INSTALLED="$VCPKG_ROOT/installed/arm64-ohos"

echo "OHOS vcpkg ports installed to $VCPKG_OHOS_INSTALLED"
