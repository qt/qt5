#!/bin/bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs QNX 7.

targetFolder="/opt/"
sourceFile="/net/ci-files01-hki.ci.qt.io/hdd/www/input/qnx/qnx700-20190325-2-macos.tar.xz"
folderName="qnx700"

sudo mkdir -p "$targetFolder"

echo "Extracting QNX 7"
sudo tar -C "$targetFolder" -Jxf $sourceFile

sudo chown -R qt:wheel "$targetFolder"/"$folderName"

# Verify that we have last file in zip
if [ ! -f $targetFolder/$folderName/qnxsdp-env.sh ]; then
    exit 1
fi

# Set env variables
echo "export QNX_700=$targetFolder/$folderName" >> ~/.bashrc
echo "QNX SDP = 7.0.0" >> ~/versions.txt
