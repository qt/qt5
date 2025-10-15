#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs openapi generator

# openapi is needed for qtopenapi playground project
source "${BASH_SOURCE%/*}/DownloadURL.sh"
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

version="7.15.0"
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/qtopenapi/openapi_client_generators/openapi-generator-cli-$version.jar"
AltUrl="https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$version/openapi-generator-cli-$version.jar"
SHA1="bb58e257f724fb46b7f2b309a9fa98e63fd7199f"
targetFolder="/opt/qt-openapi/"
targetFile="openapi-generator-cli.jar"

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFile"

sudo mkdir -p "$targetFolder"
sudo mv "$targetFile" "$targetFolder"

SetEnvVar "PATH" "$targetFolder:\$PATH"

