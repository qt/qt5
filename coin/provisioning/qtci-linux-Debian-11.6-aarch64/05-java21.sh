#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only


# This same script is used to provision java version 21 to linux Debian 11.6 aarch64

set -e

BASEDIR=$(dirname "$0")

source "$BASEDIR/../common/unix/SetEnvVar.sh"
source "$BASEDIR/../common/unix/DownloadURL.sh"



version="21.0.11"
url="https://ci-files01-hki.ci.qt.io/input/java/OpenJDK21U-jdk_aarch64_linux_hotspot_${version}_10.tar.gz"
url_cached="https://ci-files01-hki.ci.qt.io/input/java/OpenJDK21U-jdk_aarch64_linux_hotspot_${version}_10.tar.gz"
sha1="ae66135b46d114a234bbb692bf965c9f95368780 "

tar_package="/tmp/java21.tar.gz"
destination="/usr/lib/jvm"
mkdir -p "$destination"

DownloadURL $url_cached $url $sha1 $tar_package
sudo  tar -xzf $tar_package -C "$destination"
rm -rf "$tar_package"
sudo ln -snf "$destination/jdk-$version+10" "$destination/default"
JAVA21_HOME="$destination/default"
SetEnvVar "JAVA_HOME" "$JAVA21_HOME"
SetEnvVar "PATH" "$JAVA21_HOME/bin:$PATH"

