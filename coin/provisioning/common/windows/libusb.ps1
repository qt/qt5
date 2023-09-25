# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# libusb-1.0 is needed by qt-apps/qdb

. "$PSScriptRoot\helpers.ps1"

$archive = Get-DownloadLocation "libusb-1.0.26.7z"

$libusb_location = "C:\Utils\libusb-1.0"

Copy-Item \\ci-files01-hki.ci.qt.io\provisioning\libusb-1.0\libusb-1.0.26.7z $archive
Verify-Checksum $archive "89b50c7d6085350ed809a12b19131ff4f608b2f2"

Extract-7Zip $archive $libusb_location

# Tell qt-apps/qdb build system where to find libusb
Set-EnvironmentVariable "LIBUSB_PATH" $libusb_location

Write-Output "libusb = libusb-1.0.26" >> ~/versions.txt
