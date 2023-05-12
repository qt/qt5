# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Squish Coco for RTA

. "$PSScriptRoot\helpers.ps1"


$coco_version="4.2.2"
$url="http://ci-files01-hki.ci.qt.io/input/coco/SquishCocoSetup_" + $coco_version + "_Windows_x64.exe"
$sha1="d6f9f3c20df086ec9a7e13a068f4446442ae5d51"
$installer="C:\Windows\Temp\SquishCocoSetup_" + $coco_version + "_Windows_x64.exe"

Download $url $url $installer
Verify-Checksum $installer $sha1
Run-Executable $installer "/S"
Run-Executable "C:\Program Files\squishcoco\cocolic.exe" "--license-server=Qt-SRV-33.intra.qt.io:49344"
Remove "$installer"
