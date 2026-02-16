#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

echo "Installing vcpkg ports"
echo "VCPKG_ROOT: ${VCPKG_ROOT}"
echo "ANDOID_NDK_HOME: ${ANDROID_NDK_HOME}"

# Installing common ports
BASEDIR=$(dirname "$0")
"$BASEDIR/../common/linux/install-vcpkg-ports.sh"

# Installing platform specific ports
"$BASEDIR/../common/linux/install-vcpkg-ports-android.sh"
