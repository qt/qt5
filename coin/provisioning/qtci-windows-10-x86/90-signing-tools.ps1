# Copyright (C) 2017 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# Signing tools are needed to sign offline installers when releasing

$url = "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/sign.zip"
$destination = "C:\Windows\temp\sign.zip"

Download $url $url $destination
Extract-7Zip "$destination" "C:\Utils"
Remove "$destination"
