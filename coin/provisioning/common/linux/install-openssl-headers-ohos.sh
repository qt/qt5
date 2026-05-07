#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
#
# Install OpenSSL headers into the OHOS vcpkg installed directory.
# Qt for HarmonyOS uses -openssl-runtime, so only headers are needed at build
# time.  The headers come from the Qt ohos-openssl fork.

set -e

if [ -z "$VCPKG_OHOS_INSTALLED" ]; then
    echo "ERROR: VCPKG_OHOS_INSTALLED not set. Run install-vcpkg-ports-ohos.sh first." >&2
    exit 1
fi

opensslRepo="https://git.qt.io/jobor/ohos-openssl.git"
opensslTmpDir="/tmp/ohos-openssl"

echo "Installing OpenSSL headers for OHOS"
rm -rf "$opensslTmpDir"
git clone --depth 1 "$opensslRepo" "$opensslTmpDir"

mkdir -p "$VCPKG_OHOS_INSTALLED/include/openssl"
cp "$opensslTmpDir"/include/openssl/*.h "$VCPKG_OHOS_INSTALLED/include/openssl/"
rm -rf "$opensslTmpDir"

echo "OpenSSL headers installed to $VCPKG_OHOS_INSTALLED/include/openssl"
