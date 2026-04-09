#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SourceEnvVars.sh
source "${BASH_SOURCE%/*}/../unix/SourceEnvVars.sh"

echo "Caching Gradle distribution and dependencies"
gradleCacheFileName="gradle_9.3.1_darwin_cache.tar.gz"
gradleCacheUrl="http://ci-files01-hki.ci.qt.io/input/gradle/$gradleCacheFileName"
gradleCacheSha1="0009b1f55269461071b8650ee60427b66e265c4b"
gradleCacheFile="/tmp/$gradleCacheFileName"
DownloadURL "$gradleCacheUrl" "$gradleCacheUrl" "$gradleCacheSha1" "$gradleCacheFile"
mkdir -p "$HOME/.gradle"
tar -xzf "$gradleCacheFile" -C "$HOME/.gradle" --strip-components=1
rm "$gradleCacheFile"

gradle_project_source="${BASH_SOURCE%/*}/../shared/gradle/project"
cp -r "$gradle_project_source" /tmp/gradle_project
cd /tmp/gradle_project
chmod +x gradlew
sh gradlew build
