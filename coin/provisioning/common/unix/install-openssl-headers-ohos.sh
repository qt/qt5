#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
#
# Install OpenSSL headers into the OHOS vcpkg installed directory.
# Qt for HarmonyOS uses -openssl-runtime, so only headers are needed at build
# time.  The headers come from the Qt ohos-openssl fork.

set -e

# The headers are architecture independent, so install them into every OHOS
# vcpkg installed directory the port script set up.
installedDirs=()
[ -n "$VCPKG_OHOS_INSTALLED" ] && installedDirs+=("$VCPKG_OHOS_INSTALLED")
[ -n "$VCPKG_OHOS_INSTALLED_X64" ] && installedDirs+=("$VCPKG_OHOS_INSTALLED_X64")

if [ ${#installedDirs[@]} -eq 0 ]; then
    echo "ERROR: No VCPKG_OHOS_INSTALLED* set. Run install-vcpkg-ports-ohos.sh first." >&2
    exit 1
fi

opensslRepo="https://git.qt.io/jobor/ohos-openssl.git"
opensslTmpDir="/tmp/ohos-openssl"

echo "Installing OpenSSL headers for OHOS"
rm -rf "$opensslTmpDir"
git clone --depth 1 "$opensslRepo" "$opensslTmpDir"

for installedDir in "${installedDirs[@]}"; do
    mkdir -p "$installedDir/include/openssl"
    cp "$opensslTmpDir"/include/openssl/*.h "$installedDir/include/openssl/"
    echo "OpenSSL headers installed to $installedDir/include/openssl"
done

rm -rf "$opensslTmpDir"
