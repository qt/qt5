#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

echo "Installing vcpkg OHOS ports"

# The vcpkg OHOS toolchain expects OHOS_SDK_ROOT; CI sets HARMONYOS_SDK_ROOT.
ohosSdkRoot="${OHOS_SDK_ROOT:-$HARMONYOS_SDK_ROOT}"

if [ -z "$ohosSdkRoot" ]; then
    echo "ERROR: Neither OHOS_SDK_ROOT nor HARMONYOS_SDK_ROOT is set." >&2
    exit 1
fi

# On Linux, HARMONYOS_SDK_ROOT points at the command-line-tools root; the vcpkg
# toolchain needs the openharmony native SDK inside it. On macOS it already
# points there, so only descend when the nested SDK exists.
if [ -d "$ohosSdkRoot/sdk/default/openharmony/native" ]; then
    ohosSdkRoot="$ohosSdkRoot/sdk/default/openharmony"
fi

export OHOS_SDK_ROOT="$ohosSdkRoot"

# Coin sets TARGET=hdb in the environment. GNU Make imports env vars as make
# variables, which breaks ICU's Makefile (it defines its own TARGET variable
# for the library path). Unset it before invoking vcpkg.
unset TARGET

installOhosTriplet() {
    local triplet=$1
    local var=$2
    "${BASH_SOURCE%/*}/../unix/install-vcpkg-ports.sh" "$triplet"
    SetEnvVar "$var" "$VCPKG_ROOT/installed/$triplet"
    export "$var=$VCPKG_ROOT/installed/$triplet"
    echo "OHOS vcpkg ports installed to $VCPKG_ROOT/installed/$triplet"
}

installOhosTriplet arm64-ohos-qt VCPKG_OHOS_INSTALLED
installOhosTriplet x64-ohos-qt VCPKG_OHOS_INSTALLED_X64
